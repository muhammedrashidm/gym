import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/workout_session/data/datasources/workout_session_local_datasource.dart';
import '../../features/workout_session/domain/entities/session_draft.dart';

/// Bridges the local session-draft store to a visible progress surface
/// (Android ongoing notification; iOS Live Activity is a follow-up native
/// addition — see workout-session-update-feature-plan.md §7).
///
/// The local draft store is the single source of truth: this service only
/// ever reads the same streams the session cubits write to, so there's no
/// separate state that can drift out of sync.
@singleton
class SessionSyncService {
  final WorkoutSessionLocalDataSource _localDataSource;
  final AuthCubit _authCubit;
  final FlutterLocalNotificationsPlugin _notifications;

  StreamSubscription<List<SessionDraft>>? _draftsSub;
  StreamSubscription<AuthState>? _authSub;
  Role? _lastRole;

  static const int _memberNotifId = 1001;
  static const int _trainerNotifId = 1002;
  static const String _channelId = 'gym_session_live';

  SessionSyncService(
    this._localDataSource,
    this._authCubit,
    this._notifications,
  ) {
    _init();
  }

  Future<void> _init() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(initSettings);

    _authSub = _authCubit.stream.listen(_onAuthChanged);
    _onAuthChanged(_authCubit.state);
  }

  void _onAuthChanged(AuthState state) {
    final role = state is AuthAuthenticated ? state.activeRole.roleEnum : null;
    if (role == _lastRole) return;
    _lastRole = role;

    _draftsSub?.cancel();
    _clearMemberNotification();
    _clearTrainerNotification();

    if (role == Role.member) {
      _draftsSub = _localDataSource
          .watchAllActiveDrafts()
          .listen(_updateMemberNotification);
    } else if (role == Role.staff) {
      _draftsSub = _localDataSource
          .watchAllActiveDrafts()
          .listen(_updateTrainerNotification);
    }
  }

  Future<void> _updateMemberNotification(List<SessionDraft> drafts) async {
    if (drafts.isEmpty) {
      await _clearMemberNotification();
      return;
    }
    final draft = drafts.first;
    final completed = draft.taskDrafts.length;
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Live Session',
      channelDescription: 'Tracks your active workout session',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showProgress: false,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
    );
    await _notifications.show(
      _memberNotifId,
      'WORKOUT IN PROGRESS',
      '$completed task${completed == 1 ? '' : 's'} logged · ${draft.dayPlanLabel ?? 'Today\'s Session'}',
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _updateTrainerNotification(List<SessionDraft> drafts) async {
    if (drafts.isEmpty) {
      await _clearTrainerNotification();
      return;
    }
    final totalCompleted =
        drafts.fold<int>(0, (sum, d) => sum + d.taskDrafts.length);
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Live Session',
      channelDescription: 'Tracks active client sessions',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showProgress: false,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
    );
    await _notifications.show(
      _trainerNotifId,
      '${drafts.length} ACTIVE CLIENT${drafts.length == 1 ? '' : 'S'}',
      '$totalCompleted total tasks logged',
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _clearMemberNotification() => _notifications.cancel(_memberNotifId);
  Future<void> _clearTrainerNotification() => _notifications.cancel(_trainerNotifId);

  void dispose() {
    _authSub?.cancel();
    _draftsSub?.cancel();
  }
}
