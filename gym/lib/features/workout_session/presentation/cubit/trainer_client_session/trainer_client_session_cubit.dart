import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/error/failures.dart';
import '../../../../workout/domain/entities/day_plan.dart';
import '../../../../workout/domain/entities/weekly_plan.dart';
import '../../../../workout/domain/entities/workout_profile.dart';
import '../../../../workout/domain/usecases/manage_weekly_plans.dart';
import '../../../domain/entities/session_draft.dart';
import '../../../domain/entities/task_completion_draft.dart';
import '../../../domain/entities/workout_session_log.dart';
import '../../../domain/usecases/trainer_session_commands.dart';
import '../../../data/datasources/workout_session_local_datasource.dart';
import 'trainer_client_session_state.dart';

@injectable
class TrainerClientSessionCubit extends Cubit<TrainerClientSessionState> {
  final Mediator _mediator;
  final WorkoutSessionLocalDataSource _localDataSource;
  static const _uuid = Uuid();

  StreamSubscription<SessionDraft?>? _draftSub;

  TrainerClientSessionCubit(this._mediator, this._localDataSource)
      : super(const TrainerClientSessionState.initial());

  Future<void> loadSession({
    required String clientProfileId,
    required String clientName,
  }) async {
    emit(const TrainerClientSessionState.loading());

    final profileResult = await _mediator.sendCommand(
      GetClientWorkoutProfileQuery(clientProfileId),
    ) as Either<Failure, WorkoutProfile?>;

    if (isClosed) return;

    final failure = profileResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(TrainerClientSessionState.error(
          failure: failure, clientName: clientName));
      return;
    }
    final profile = profileResult.fold((_) => null, (p) => p);
    if (profile == null) {
      emit(TrainerClientSessionState.noPlan(clientName: clientName));
      return;
    }

    // GetWeeklyPlanDetailsQuery needs a non-null id.
    final activeWeeklyPlanId = profile.activeWeeklyPlanId;
    if (activeWeeklyPlanId == null) {
      emit(TrainerClientSessionState.noPlan(clientName: clientName));
      return;
    }

    final results = await Future.wait([
      _mediator.sendCommand(GetWeeklyPlanDetailsQuery(activeWeeklyPlanId))
          as Future<Either<Failure, WeeklyPlan>>,
      _mediator.sendCommand(GetClientWorkoutSessionLogsQuery(
        clientProfileId: clientProfileId,
        workoutProfileId: profile.id,
        pageSize: 50,
      )) as Future<
          Either<Failure,
              ({List<WorkoutSessionLog> logs, int total, int page, int pageSize})>>,
    ]);

    if (isClosed) return;

    final weeklyPlanResult = results[0] as Either<Failure, WeeklyPlan>;
    final logsResult = results[1] as Either<Failure,
        ({List<WorkoutSessionLog> logs, int total, int page, int pageSize})>;

    final weeklyPlanFailure = weeklyPlanResult.fold((f) => f, (_) => null);
    if (weeklyPlanFailure != null) {
      emit(TrainerClientSessionState.error(
        failure: weeklyPlanFailure,
        clientName: clientName,
        profile: profile,
      ));
      return;
    }
    final weeklyPlan = weeklyPlanResult.fold((_) => null, (p) => p)!;

    // Log fetch is supplementary (day-strip status + active-day derivation)
    // — a failure here must not block the trainer from logging today's
    // session. Falling back to day 1 keeps the loaded state internally
    // consistent (empty strip paired with day 1 active).
    final progress = logsResult.fold(
      (_) => (weekDayStatus: <int, SessionStatus>{}, activeDayIndex: 1),
      (r) => _computeWeekProgress(r.logs, activeWeeklyPlanId),
    );

    final dayPlan = _resolveActiveDayPlan(weeklyPlan, progress.activeDayIndex);
    if (dayPlan == null) {
      // A plan is assigned but has no day plans configured — malformed
      // data, distinct from "no plan assigned" (noPlan).
      emit(TrainerClientSessionState.error(
        failure:
            const Failure.unknown(message: 'Weekly plan has no day plans configured.'),
        clientName: clientName,
        profile: profile,
      ));
      return;
    }

    assert(() {
      if (profile.currentDayIndex != dayPlan.dayIndex) {
        debugPrint(
          'TrainerClientSessionCubit: active day drifted from server '
          'cursor (computed=${dayPlan.dayIndex}, '
          'server=${profile.currentDayIndex}) for workoutProfileId=${profile.id}.',
        );
      }
      return true;
    }());

    // Start or resume draft for this client's profile
    await _localDataSource.startOrResumeDraft(SessionDraft(
      workoutProfileId: profile.id,
      clientProfileId: clientProfileId,
      dayIndexAtTime: dayPlan.dayIndex,
      dayPlanId: dayPlan.id,
      dayPlanLabel: dayPlan.label,
      weeklyPlanName: profile.activeWeeklyPlan?.name,
      startedAt: DateTime.now(),
      isTrainerInitiated: true,
    ));

    await _draftSub?.cancel();
    _draftSub = _localDataSource.watchDraft(profile.id).listen((draft) {
      if (draft != null && !isClosed && state is! TrainerSessionSubmitting) {
        emit(TrainerClientSessionState.loaded(
          profile: profile,
          dayPlan: dayPlan,
          draft: draft,
          clientName: clientName,
          weekDayStatus: progress.weekDayStatus,
        ));
      }
    });
  }

  /// Walks the client's session-log history for the active weekly plan to
  /// determine (a) which days in the still-in-progress cycle were logged as
  /// completed/skipped, and (b) which day is "active" next. This mirrors
  /// the server's own state machine (workout-session.service.ts): only a
  /// completion advances the day (with wraparound 7 -> 1); a skip leaves
  /// the same day active until it is eventually completed. Grouping by
  /// `cycleNumberAtTime` is deliberately avoided — the completion that
  /// wraps day 7 shares that field's value with the next cycle's early
  /// days, so it can't be used to split cycles reliably.
  ({Map<int, SessionStatus> weekDayStatus, int activeDayIndex}) _computeWeekProgress(
    List<WorkoutSessionLog> logs,
    String activeWeeklyPlanId,
  ) {
    final matching =
        logs.where((l) => l.weeklyPlanId == activeWeeklyPlanId).toList();
    if (matching.isEmpty) {
      return (weekDayStatus: <int, SessionStatus>{}, activeDayIndex: 1);
    }

    // Logs are ordered completedDate desc from the server. If the most
    // recent action was the completion that wrapped day 7 -> 1, the
    // current cycle hasn't logged anything yet.
    final mostRecent = matching.first;
    if (mostRecent.status == SessionStatus.completed &&
        mostRecent.dayIndexAtTime == 7) {
      return (weekDayStatus: <int, SessionStatus>{}, activeDayIndex: 1);
    }

    // Walk backward from the most recent log, collecting everything that
    // belongs to the still-in-progress cycle. A completed day-7 log marks
    // where the previous cycle ended -- stop there (exclusive).
    final currentCycleLogs = <WorkoutSessionLog>[];
    for (final log in matching) {
      if (log.status == SessionStatus.completed && log.dayIndexAtTime == 7) {
        break;
      }
      currentCycleLogs.add(log);
    }

    final weekDayStatus = <int, SessionStatus>{};
    for (final log in currentCycleLogs) {
      // Most recent action per day wins.
      weekDayStatus.putIfAbsent(log.dayIndexAtTime, () => log.status);
    }

    // Only completions advance the active day -- a skip leaves the
    // server's currentDayIndex unchanged.
    final completedIndices = currentCycleLogs
        .where((l) => l.status == SessionStatus.completed)
        .map((l) => l.dayIndexAtTime);
    final activeDayIndex =
        completedIndices.isEmpty ? 1 : (completedIndices.reduce(max) % 7) + 1;

    return (weekDayStatus: weekDayStatus, activeDayIndex: activeDayIndex);
  }

  /// Resolves the DayPlan for [activeDayIndex]. Falls back to the
  /// lowest-index day plan if the exact index isn't found (shouldn't
  /// happen given the 7-day invariant, but the plan is untrusted network
  /// input). Returns null only if the plan has zero day plans configured.
  DayPlan? _resolveActiveDayPlan(WeeklyPlan weeklyPlan, int activeDayIndex) {
    final exact = weeklyPlan.dayPlans
        .firstWhereOrNull((d) => d.dayIndex == activeDayIndex);
    if (exact != null) return exact;
    if (weeklyPlan.dayPlans.isEmpty) return null;
    final sorted = [...weeklyPlan.dayPlans]
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return sorted.first;
  }

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

  Future<void> completeSession() async {
    final loaded = _currentLoaded();
    if (loaded == null) return;

    emit(TrainerClientSessionState.submitting(
      profile: loaded.profile,
      dayPlan: loaded.dayPlan,
      draft: loaded.draft,
      clientName: loaded.clientName,
      weekDayStatus: loaded.weekDayStatus,
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
      CompleteClientWorkoutSessionCommand(
        clientProfileId: loaded.profile.clientProfileId,
        workoutProfileId: loaded.profile.id,
        taskCompletions: completions,
      ),
    ) as Either<Failure, WorkoutSessionLog>;

    await result.fold(
      (failure) async {
        emit(TrainerClientSessionState.error(
          failure: failure,
          clientName: loaded.clientName,
          profile: loaded.profile,
          dayPlan: loaded.dayPlan,
          draft: loaded.draft,
          weekDayStatus: loaded.weekDayStatus,
        ));
      },
      (sessionLog) async {
        await _localDataSource.clearDraft(loaded.profile.id);
        emit(TrainerClientSessionState.submitted(sessionLog: sessionLog));
      },
    );
  }

  Future<void> skipSession({String? reason}) async {
    final loaded = _currentLoaded();
    if (loaded == null) return;

    emit(TrainerClientSessionState.submitting(
      profile: loaded.profile,
      dayPlan: loaded.dayPlan,
      draft: loaded.draft,
      clientName: loaded.clientName,
      weekDayStatus: loaded.weekDayStatus,
    ));

    final result = await _mediator.sendCommand(
      SkipClientWorkoutSessionCommand(
        clientProfileId: loaded.profile.clientProfileId,
        workoutProfileId: loaded.profile.id,
        reason: reason,
      ),
    ) as Either<Failure, WorkoutSessionLog>;

    await result.fold(
      (failure) async {
        emit(TrainerClientSessionState.error(
          failure: failure,
          clientName: loaded.clientName,
          profile: loaded.profile,
          dayPlan: loaded.dayPlan,
          draft: loaded.draft,
          weekDayStatus: loaded.weekDayStatus,
        ));
      },
      (sessionLog) async {
        await _localDataSource.clearDraft(loaded.profile.id);
        emit(TrainerClientSessionState.submitted(sessionLog: sessionLog));
      },
    );
  }

  ({
    WorkoutProfile profile,
    DayPlan dayPlan,
    SessionDraft draft,
    String clientName,
    Map<int, SessionStatus> weekDayStatus,
  })? _currentLoaded() {
    final current = state;
    if (current is TrainerSessionLoaded) {
      return (
        profile: current.profile,
        dayPlan: current.dayPlan,
        draft: current.draft,
        clientName: current.clientName,
        weekDayStatus: current.weekDayStatus,
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
