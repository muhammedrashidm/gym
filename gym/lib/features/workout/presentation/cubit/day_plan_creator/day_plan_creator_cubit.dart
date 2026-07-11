import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../../domain/entities/day_plan.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/manage_weekly_plans.dart';
import '../../../domain/usecases/manage_day_plans.dart';
import '../../../domain/usecases/manage_tasks.dart';
import 'day_plan_creator_state.dart';

class DayPlanCreatorCubit extends Cubit<DayPlanCreatorState> {
  final Mediator _mediator;

  DayPlanCreatorCubit(this._mediator) : super(const DayPlanCreatorState.initial());

  Future<void> loadPlan(String weeklyPlanId, {int defaultDayIndex = 0}) async {
    emit(const DayPlanCreatorState.loading());
    await _fetchPlanDetails(weeklyPlanId, defaultDayIndex);
  }

  void selectDay(int index) {
    final current = state;
    if (current is DayPlanCreatorLoaded) {
      emit(current.copyWith(selectedDayIndex: index));
    }
  }

  Future<void> toggleRestDay({
    required String dayPlanId,
    required bool isRestDay,
    required String weeklyPlanId,
  }) async {
    final current = state;
    final currentIndex = current is DayPlanCreatorLoaded ? current.selectedDayIndex : 0;

    final result = await _mediator.sendCommand(
      UpdateDayPlanCommand(
        dayPlanId: dayPlanId,
        isRestDay: isRestDay,
      ),
    ) as Either<Failure, DayPlan>;

    await result.fold(
      (failure) async {
        emit(DayPlanCreatorState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchPlanDetails(weeklyPlanId, currentIndex);
      },
    );
  }

  Future<void> updateDayLabel({
    required String dayPlanId,
    required String label,
    required String weeklyPlanId,
  }) async {
    final current = state;
    final currentIndex = current is DayPlanCreatorLoaded ? current.selectedDayIndex : 0;

    final result = await _mediator.sendCommand(
      UpdateDayPlanCommand(
        dayPlanId: dayPlanId,
        label: label,
      ),
    ) as Either<Failure, DayPlan>;

    await result.fold(
      (failure) async {
        emit(DayPlanCreatorState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchPlanDetails(weeklyPlanId, currentIndex);
      },
    );
  }

  Future<void> createTask({
    required String dayPlanId,
    required String name,
    required int sets,
    required String reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    required int sequenceIndex,
    required String weeklyPlanId,
  }) async {
    final current = state;
    final currentIndex = current is DayPlanCreatorLoaded ? current.selectedDayIndex : 0;

    final result = await _mediator.sendCommand(
      CreateTaskCommand(
        dayPlanId: dayPlanId,
        name: name,
        sets: sets,
        reps: reps,
        restSeconds: restSeconds,
        tempo: tempo,
        machineDetails: machineDetails,
        notes: notes,
        sequenceIndex: sequenceIndex,
      ),
    ) as Either<Failure, Task>;

    await result.fold(
      (failure) async {
        emit(DayPlanCreatorState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchPlanDetails(weeklyPlanId, currentIndex);
      },
    );
  }

  Future<void> updateTask({
    required String taskId,
    String? name,
    int? sets,
    String? reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    int? sequenceIndex,
    required String weeklyPlanId,
  }) async {
    final current = state;
    final currentIndex = current is DayPlanCreatorLoaded ? current.selectedDayIndex : 0;

    final result = await _mediator.sendCommand(
      UpdateTaskCommand(
        taskId: taskId,
        name: name,
        sets: sets,
        reps: reps,
        restSeconds: restSeconds,
        tempo: tempo,
        machineDetails: machineDetails,
        notes: notes,
        sequenceIndex: sequenceIndex,
      ),
    ) as Either<Failure, Task>;

    await result.fold(
      (failure) async {
        emit(DayPlanCreatorState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchPlanDetails(weeklyPlanId, currentIndex);
      },
    );
  }

  Future<void> deleteTask({
    required String taskId,
    required String weeklyPlanId,
  }) async {
    final current = state;
    final currentIndex = current is DayPlanCreatorLoaded ? current.selectedDayIndex : 0;

    final result = await _mediator.sendCommand(
      DeleteTaskCommand(taskId),
    ) as Either<Failure, Unit>;

    await result.fold(
      (failure) async {
        emit(DayPlanCreatorState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchPlanDetails(weeklyPlanId, currentIndex);
      },
    );
  }

  Future<void> _fetchPlanDetails(String weeklyPlanId, int dayIndex) async {
    final result = await _mediator.sendCommand(
      GetWeeklyPlanDetailsQuery(weeklyPlanId),
    ) as Either<Failure, WeeklyPlan>;

    result.fold(
      (failure) {
        emit(DayPlanCreatorState.error(_mapFailureToMessage(failure)));
      },
      (weeklyPlan) {
        emit(DayPlanCreatorState.loaded(
          weeklyPlan: weeklyPlan,
          selectedDayIndex: dayIndex,
        ));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.maybeWhen(
      server: (_, msg) => msg,
      network: (msg) => msg ?? 'Network error.',
      unknown: (msg) => msg ?? 'Unknown error.',
      unauthorized: () => 'Unauthorized.',
      orElse: () => 'Unexpected error.',
    );
  }
}
