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

    final dayPlanResult = await _mediator.sendCommand(
      GetTodayPlanQuery(profile.id),
    ) as Either<Failure, DayPlan?>;

    if (isClosed) return;

    final dayPlanFailure = dayPlanResult.fold((f) => f, (_) => null);
    if (dayPlanFailure != null) {
      emit(TrainerClientSessionState.error(
        failure: dayPlanFailure,
        clientName: clientName,
        profile: profile,
      ));
      return;
    }
    final dayPlan = dayPlanResult.fold((_) => null, (dp) => dp);
    if (dayPlan == null) {
      emit(TrainerClientSessionState.noPlan(clientName: clientName));
      return;
    }

    // Start or resume draft for this client's profile
    await _localDataSource.startOrResumeDraft(SessionDraft(
      workoutProfileId: profile.id,
      clientProfileId: clientProfileId,
      dayIndexAtTime: profile.currentDayIndex,
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
        ));
      }
    });
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
    String clientName
  })? _currentLoaded() {
    final current = state;
    if (current is TrainerSessionLoaded) {
      return (
        profile: current.profile,
        dayPlan: current.dayPlan,
        draft: current.draft,
        clientName: current.clientName,
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
