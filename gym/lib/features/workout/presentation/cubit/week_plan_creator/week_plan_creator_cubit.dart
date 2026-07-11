import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../../domain/value_objects/draft_day_plan.dart';
import '../../../domain/value_objects/draft_task.dart';
import '../../../domain/usecases/manage_weekly_plans.dart';
import 'week_plan_creator_state.dart';

class WeekPlanCreatorCubit extends Cubit<WeekPlanCreatorState> {
  final Mediator _mediator;

  WeekPlanCreatorCubit(this._mediator)
      : super(WeekPlanCreatorState.editing(
          days: List.generate(7, (i) => DraftDayPlan(dayIndex: i + 1)),
        ));

  // ─── Plan-level mutations ────────────────────────────────────────────────

  void setPlanName(String name) {
    _withEditing((s) => s.copyWith(planName: name));
  }

  void setPlanNotes(String notes) {
    _withEditing((s) => s.copyWith(planNotes: notes));
  }

  void setActivateImmediately(bool value) {
    _withEditing((s) => s.copyWith(activateImmediately: value));
  }

  void selectDay(int index) {
    _withEditing((s) => s.copyWith(selectedDayIndex: index));
  }

  // ─── Day-level mutations ─────────────────────────────────────────────────

  void toggleRestDay(int dayIndex, bool isRestDay) {
    _updateDay(dayIndex, (d) => d.copyWith(isRestDay: isRestDay));
  }

  void setDayLabel(int dayIndex, String label) {
    _updateDay(
      dayIndex,
      (d) => label.trim().isEmpty
          ? d.copyWith(clearLabel: true)
          : d.copyWith(label: label.trim()),
    );
  }

  // ─── Task-level mutations ────────────────────────────────────────────────

  void addTask(int dayIndex, DraftTask task) {
    _updateDay(dayIndex, (d) {
      final updated = List<DraftTask>.from(d.tasks)..add(task);
      return d.copyWith(tasks: updated);
    });
  }

  void updateTask(int dayIndex, String localId, DraftTask updated) {
    _updateDay(dayIndex, (d) {
      final tasks = d.tasks.map((t) => t.localId == localId ? updated : t).toList();
      return d.copyWith(tasks: tasks);
    });
  }

  void removeTask(int dayIndex, String localId) {
    _updateDay(dayIndex, (d) {
      final tasks = d.tasks.where((t) => t.localId != localId).toList();
      // Re-sequence after removal
      final resequenced = tasks
          .asMap()
          .entries
          .map((e) => e.value.copyWith(sequenceIndex: e.key + 1))
          .toList();
      return d.copyWith(tasks: resequenced);
    });
  }

  // ─── Save ────────────────────────────────────────────────────────────────

  Future<void> savePlan(String workoutProfileId) async {
    final current = state;
    if (current is! WeekPlanCreatorEditing) return;
    if (current.planName.trim().isEmpty) return;

    emit(const WeekPlanCreatorState.saving());

    final result = await _mediator.sendCommand(
      CreateFullWeeklyPlanCommand(
        workoutProfileId: workoutProfileId,
        name: current.planName.trim(),
        notes: current.planNotes.trim().isEmpty ? null : current.planNotes.trim(),
        activateImmediately: current.activateImmediately,
        days: current.days,
      ),
    ) as Either<Failure, WeeklyPlan>;

    result.fold(
      (failure) => emit(WeekPlanCreatorState.error(
        message: _mapFailure(failure),
        days: current.days,
        planName: current.planName,
        planNotes: current.planNotes,
        activateImmediately: current.activateImmediately,
        selectedDayIndex: current.selectedDayIndex,
      )),
      (plan) => emit(WeekPlanCreatorState.saved(plan)),
    );
  }

  void resumeEditing() {
    final current = state;
    if (current is WeekPlanCreatorError) {
      emit(WeekPlanCreatorState.editing(
        days: current.days,
        planName: current.planName,
        planNotes: current.planNotes,
        activateImmediately: current.activateImmediately,
        selectedDayIndex: current.selectedDayIndex,
      ));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _withEditing(WeekPlanCreatorEditing Function(WeekPlanCreatorEditing) fn) {
    final current = state;
    if (current is WeekPlanCreatorEditing) emit(fn(current));
  }

  void _updateDay(int dayIndex, DraftDayPlan Function(DraftDayPlan) fn) {
    _withEditing((s) {
      final days = s.days.map((d) => d.dayIndex == dayIndex ? fn(d) : d).toList();
      return s.copyWith(days: days);
    });
  }

  String _mapFailure(Failure failure) => failure.maybeWhen(
        server: (_, msg) => msg,
        network: (msg) => msg ?? 'Network error.',
        unknown: (msg) => msg ?? 'Unknown error.',
        unauthorized: () => 'Unauthorized.',
        orElse: () => 'Unexpected error.',
      );
}
