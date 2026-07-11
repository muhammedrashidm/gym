import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/value_objects/draft_day_plan.dart';
import '../../../domain/entities/weekly_plan.dart';

part 'week_plan_creator_state.freezed.dart';

@freezed
class WeekPlanCreatorState with _$WeekPlanCreatorState {
  const factory WeekPlanCreatorState.editing({
    @Default('') String planName,
    @Default('') String planNotes,
    @Default(false) bool activateImmediately,
    @Default(0) int selectedDayIndex,
    required List<DraftDayPlan> days,
  }) = WeekPlanCreatorEditing;

  const factory WeekPlanCreatorState.saving() = WeekPlanCreatorSaving;
  const factory WeekPlanCreatorState.saved(WeeklyPlan plan) = WeekPlanCreatorSaved;
  const factory WeekPlanCreatorState.error({
    required String message,
    // Carry editing state so UI can restore without losing data
    required List<DraftDayPlan> days,
    @Default('') String planName,
    @Default('') String planNotes,
    @Default(false) bool activateImmediately,
    @Default(0) int selectedDayIndex,
  }) = WeekPlanCreatorError;
}
