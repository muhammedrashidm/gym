import 'dart:async';
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/error/failures.dart';
import '../../../../workout/domain/entities/day_plan.dart';
import '../../../../workout/domain/entities/workout_profile.dart';
import '../../../domain/entities/session_draft.dart';
import '../../../domain/entities/task_completion_draft.dart';
import '../../../domain/entities/workout_session_log.dart';
import '../../../domain/usecases/get_today_plan_query.dart';
import '../../../domain/usecases/member_session_commands.dart';
import '../../../data/datasources/workout_session_local_datasource.dart';
import 'member_workout_session_state.dart';

@injectable
class MemberWorkoutSessionCubit extends Cubit<MemberWorkoutSessionState> {
  final Mediator _mediator;
  final WorkoutSessionLocalDataSource _localDataSource;
  static const _uuid = Uuid();

  StreamSubscription<SessionDraft?>? _draftSub;

  MemberWorkoutSessionCubit(this._mediator, this._localDataSource)
      : super(const MemberWorkoutSessionState.initial());

  /// Called when the Train page opens. Resolves the logged-in member's own
  /// active workout profile — no client id needed, the server infers it from
  /// the auth context.
  Future<void> loadSession() async {
    emit(const MemberWorkoutSessionState.loading());

    final profileResult = await _mediator.sendCommand(
      GetMemberActiveProfileQuery(),
    ) as Either<Failure, WorkoutProfile?>;

    if (isClosed) return;

    final failure = profileResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(MemberWorkoutSessionState.error(failure: failure));
      return;
    }
    final resolvedProfile = profileResult.fold((_) => null, (p) => p);

    if (resolvedProfile == null) {
      // Fetched successfully, but the member has no active program assigned.
      emit(const MemberWorkoutSessionState.noPlan());
      return;
    }
    final profile = resolvedProfile;

    final dayPlanResult = await _mediator.sendCommand(
      GetTodayPlanQuery(profile.id),
    ) as Either<Failure, DayPlan?>;

    final dayPlan = dayPlanResult.fold(
      (failure) {
        emit(MemberWorkoutSessionState.error(failure: failure, profile: profile));
        return null;
      },
      (dp) => dp,
    );
    if (isClosed) return;
    if (dayPlan == null) {
      emit(const MemberWorkoutSessionState.noPlan());
      return;
    }

    // Start or resume local draft
    await _localDataSource.startOrResumeDraft(SessionDraft(
      workoutProfileId: profile.id,
      clientProfileId: profile.clientProfileId,
      dayIndexAtTime: profile.currentDayIndex,
      dayPlanId: dayPlan.id,
      dayPlanLabel: dayPlan.label,
      weeklyPlanName: profile.activeWeeklyPlan?.name,
      startedAt: DateTime.now(),
      isTrainerInitiated: false,
    ));

    // Watch the local stream and forward updates to state
    await _draftSub?.cancel();
    _draftSub = _localDataSource.watchDraft(profile.id).listen((draft) {
      if (draft != null && !isClosed && state is! MemberSessionSubmitting) {
        emit(MemberWorkoutSessionState.loaded(
          profile: profile,
          dayPlan: dayPlan,
          draft: draft,
        ));
      }
    });
  }

  /// Save actuals for one task immediately to local storage.
  Future<void> upsertTaskCompletion({
    required String workoutProfileId,
    required String taskId,
    int? actualSets,
    String? actualReps,
    double? actualWeightKg,
    String? notes,
  }) async {
    await _localDataSource.upsertTaskCompletion(TaskCompletionDraft(
      id: _uuid.v4(),
      workoutProfileId: workoutProfileId,
      taskId: taskId,
      actualSets: actualSets,
      actualReps: actualReps,
      actualWeightKg: actualWeightKg,
      notes: notes,
    ));
  }

  /// Submit session as completed.
  Future<void> completeSession() async {
    final loaded = _currentLoaded();
    if (loaded == null) return;

    emit(MemberWorkoutSessionState.submitting(
      profile: loaded.profile,
      dayPlan: loaded.dayPlan,
      draft: loaded.draft,
    ));

    final completions = loaded.draft.taskDrafts
        .map((t) => TaskCompletionInput(
              taskId: t.taskId,
              actualSets: t.actualSets,
              actualReps: t.actualReps,
              actualWeightKg: t.actualWeightKg,
              notes: t.notes,
            ))
        .toList();

    final result = await _mediator.sendCommand(
      CompleteMemberWorkoutSessionCommand(
        workoutProfileId: loaded.profile.id,
        taskCompletions: completions,
      ),
    ) as Either<Failure, WorkoutSessionLog>;

    await result.fold(
      (failure) async {
        // Keep draft intact; user can retry
        emit(MemberWorkoutSessionState.error(
          failure: failure,
          profile: loaded.profile,
          dayPlan: loaded.dayPlan,
          draft: loaded.draft,
        ));
      },
      (sessionLog) async {
        await _localDataSource.clearDraft(loaded.profile.id);
        emit(MemberWorkoutSessionState.submitted(sessionLog: sessionLog));
      },
    );
  }

  /// Submit session as skipped.
  Future<void> skipSession({String? reason}) async {
    final loaded = _currentLoaded();
    if (loaded == null) return;

    emit(MemberWorkoutSessionState.submitting(
      profile: loaded.profile,
      dayPlan: loaded.dayPlan,
      draft: loaded.draft,
    ));

    final result = await _mediator.sendCommand(
      SkipMemberWorkoutSessionCommand(
        workoutProfileId: loaded.profile.id,
        reason: reason,
      ),
    ) as Either<Failure, WorkoutSessionLog>;

    await result.fold(
      (failure) async {
        emit(MemberWorkoutSessionState.error(
          failure: failure,
          profile: loaded.profile,
          dayPlan: loaded.dayPlan,
          draft: loaded.draft,
        ));
      },
      (sessionLog) async {
        await _localDataSource.clearDraft(loaded.profile.id);
        emit(MemberWorkoutSessionState.submitted(sessionLog: sessionLog));
      },
    );
  }

  ({WorkoutProfile profile, DayPlan dayPlan, SessionDraft draft})?
      _currentLoaded() {
    final current = state;
    if (current is MemberSessionLoaded) {
      return (
        profile: current.profile,
        dayPlan: current.dayPlan,
        draft: current.draft
      );
    }
    return null;
  }

  @override
  Future<void> close() {
    _draftSub?.cancel();
    return super.close();
  }
}
