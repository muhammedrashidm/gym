// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyPlanModel _$WeeklyPlanModelFromJson(Map<String, dynamic> json) =>
    WeeklyPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      workoutProfileId: json['workoutProfileId'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      dayPlans: (json['days'] as List<dynamic>?)
              ?.map((e) => DayPlanModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WeeklyPlanModelToJson(WeeklyPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'workoutProfileId': instance.workoutProfileId,
      'status': instance.status,
      'notes': instance.notes,
      'days': instance.dayPlans,
    };
