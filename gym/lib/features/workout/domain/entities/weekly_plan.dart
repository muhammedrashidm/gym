import 'package:freezed_annotation/freezed_annotation.dart';
import 'day_plan.dart';

part 'weekly_plan.freezed.dart';

@freezed
class WeeklyPlan with _$WeeklyPlan {
  const factory WeeklyPlan({
    required String id,
    required String name,
    required String workoutProfileId,
    required String status, // ACTIVE, UPCOMING, ARCHIVED
    String? notes,
    required List<DayPlan> dayPlans,
  }) = _WeeklyPlan;
}
