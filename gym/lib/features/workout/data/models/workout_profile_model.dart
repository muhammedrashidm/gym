import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/workout_profile.dart';
import 'weekly_plan_model.dart';

part 'workout_profile_model.g.dart';

@JsonSerializable()
class WorkoutProfileModel {
  final String id;
  final String clientProfileId;
  final String trainerProfileId;
  final String? activeWeeklyPlanId;
  final int currentDayIndex;
  final bool isActive;
  final String createdAt;
  final WeeklyPlanModel? activeWeeklyPlan;

  const WorkoutProfileModel({
    required this.id,
    required this.clientProfileId,
    required this.trainerProfileId,
    this.activeWeeklyPlanId,
    required this.currentDayIndex,
    required this.isActive,
    required this.createdAt,
    this.activeWeeklyPlan,
  });

  factory WorkoutProfileModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProfileModelToJson(this);

  WorkoutProfile toDomain() {
    return WorkoutProfile(
      id: id,
      clientProfileId: clientProfileId,
      trainerProfileId: trainerProfileId,
      activeWeeklyPlanId: activeWeeklyPlanId,
      currentDayIndex: currentDayIndex,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      activeWeeklyPlan: activeWeeklyPlan?.toDomain(),
    );
  }
}
