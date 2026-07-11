// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProfileModel _$WorkoutProfileModelFromJson(Map<String, dynamic> json) =>
    WorkoutProfileModel(
      id: json['id'] as String,
      clientProfileId: json['clientProfileId'] as String,
      trainerProfileId: json['trainerProfileId'] as String,
      activeWeeklyPlanId: json['activeWeeklyPlanId'] as String?,
      currentDayIndex: (json['currentDayIndex'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      activeWeeklyPlan: json['activeWeeklyPlan'] == null
          ? null
          : WeeklyPlanModel.fromJson(
              json['activeWeeklyPlan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkoutProfileModelToJson(
        WorkoutProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientProfileId': instance.clientProfileId,
      'trainerProfileId': instance.trainerProfileId,
      'activeWeeklyPlanId': instance.activeWeeklyPlanId,
      'currentDayIndex': instance.currentDayIndex,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'activeWeeklyPlan': instance.activeWeeklyPlan,
    };
