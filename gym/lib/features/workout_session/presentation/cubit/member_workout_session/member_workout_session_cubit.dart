import 'dart:async';
import 'package:collection/collection.dart';
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
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
import '../../../domain/usecases/member_session_commands.dart';
import '../../../domain/week_progress_calculator.dart';
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

    final activeWeeklyPlanId = profile.activeWeeklyPlanId;
    if (activeWeeklyPlanId == null) {
      emit(const MemberWorkoutSessionState.noPlan());
      return;
    }

    final results = await Future.wait([
      _mediator.sendCommand(GetWeeklyPlanDetailsQuery(activeWeeklyPlanId))
          as Future<Either<Failure, WeeklyPlan>>,
      _mediator.sendCommand(GetMemberWorkoutSessionLogsQuery(
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
      emit(MemberWorkoutSessionState.error(
        failure: weeklyPlanFailure,
        profile: profile,
      ));
      return;
    }
    final weeklyPlan = weeklyPlanResult.fold((_) => null, (p) => p)!;

    // Log fetch is supplementary (day-strip status + active-day derivation)
    // — a failure here must not block the member from logging today's
    // session. Falling back to day 1 keeps the loaded state internally
    // consistent (empty strip paired with day 1 active).
    final progress = logsResult.fold(
      (_) => const WeekProgress(dayLogs: {}, activeDayIndex: 1),
      (r) => computeWeekProgress(r.logs, activeWeeklyPlanId),
    );

    final dayPlan = _resolveActiveDayPlan(weeklyPlan, progress.activeDayIndex);
    if (dayPlan == null) {
      // A plan is assigned but has no day plans configured — malformed
      // data, distinct from "no plan assigned" (noPlan).
      emit(MemberWorkoutSessionState.error(
        failure: const Failure.unknown(
            message: 'Weekly plan has no day plans configured.'),
        profile: profile,
      ));
      return;
    }

    // Start or resume local draft
    await _localDataSource.startOrResumeDraft(SessionDraft(
      workoutProfileId: profile.id,
      clientProfileId: profile.clientProfileId,
      dayIndexAtTime: dayPlan.dayIndex,
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
          weeklyPlan: weeklyPlan,
          dayPlan: dayPlan,
          draft: draft,
          dayLogs: progress.dayLogs,
          activeDayIndex: progress.activeDayIndex,
        ));
      }
    });
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
      weeklyPlan: loaded.weeklyPlan,
      dayPlan: loaded.dayPlan,
      draft: loaded.draft,
      dayLogs: loaded.dayLogs,
      activeDayIndex: loaded.activeDayIndex,
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
          weeklyPlan: loaded.weeklyPlan,
          dayPlan: loaded.dayPlan,
          draft: loaded.draft,
          dayLogs: loaded.dayLogs,
          activeDayIndex: loaded.activeDayIndex,
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
      weeklyPlan: loaded.weeklyPlan,
      dayPlan: loaded.dayPlan,
      draft: loaded.draft,
      dayLogs: loaded.dayLogs,
      activeDayIndex: loaded.activeDayIndex,
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
          weeklyPlan: loaded.weeklyPlan,
          dayPlan: loaded.dayPlan,
          draft: loaded.draft,
          dayLogs: loaded.dayLogs,
          activeDayIndex: loaded.activeDayIndex,
        ));
      },
      (sessionLog) async {
        await _localDataSource.clearDraft(loaded.profile.id);
        emit(MemberWorkoutSessionState.submitted(sessionLog: sessionLog));
      },
    );
  }

  ({
    WorkoutProfile profile,
    WeeklyPlan weeklyPlan,
    DayPlan dayPlan,
    SessionDraft draft,
    Map<int, WorkoutSessionLog> dayLogs,
    int activeDayIndex,
  })? _currentLoaded() {
    final current = state;
    if (current is MemberSessionLoaded) {
      return (
        profile: current.profile,
        weeklyPlan: current.weeklyPlan,
        dayPlan: current.dayPlan,
        draft: current.draft,
        dayLogs: current.dayLogs,
        activeDayIndex: current.activeDayIndex,
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
