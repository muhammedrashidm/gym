import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/weekly_plan.dart';

part 'day_plan_creator_state.freezed.dart';

@freezed
class DayPlanCreatorState with _$DayPlanCreatorState {
  const factory DayPlanCreatorState.initial() = _Initial;
  const factory DayPlanCreatorState.loading() = _Loading;
  const factory DayPlanCreatorState.loaded({
    required WeeklyPlan weeklyPlan,
    required int selectedDayIndex,
  }) = DayPlanCreatorLoaded;
  const factory DayPlanCreatorState.error(String message) = DayPlanCreatorError;
}
