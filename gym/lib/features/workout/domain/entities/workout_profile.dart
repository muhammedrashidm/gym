import 'package:freezed_annotation/freezed_annotation.dart';
import 'weekly_plan.dart';

part 'workout_profile.freezed.dart';

@freezed
class WorkoutProfile with _$WorkoutProfile {
  const factory WorkoutProfile({
    required String id,
    required String clientProfileId,
    required String trainerProfileId,
    String? activeWeeklyPlanId,
    required int currentDayIndex,
    required bool isActive,
    required DateTime createdAt,
    WeeklyPlan? activeWeeklyPlan,
  }) = _WorkoutProfile;
}
