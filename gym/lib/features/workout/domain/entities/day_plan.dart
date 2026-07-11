import 'package:freezed_annotation/freezed_annotation.dart';
import 'task.dart';

part 'day_plan.freezed.dart';

@freezed
class DayPlan with _$DayPlan {
  const factory DayPlan({
    required String id,
    required String weeklyPlanId,
    required int dayIndex,
    String? label,
    required bool isRestDay,
    required List<Task> tasks,
  }) = _DayPlan;
}
