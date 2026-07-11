// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayPlanModel _$DayPlanModelFromJson(Map<String, dynamic> json) => DayPlanModel(
      id: json['id'] as String,
      weeklyPlanId: json['weeklyPlanId'] as String,
      dayIndex: (json['dayIndex'] as num).toInt(),
      label: json['label'] as String?,
      isRestDay: json['isRestDay'] as bool,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DayPlanModelToJson(DayPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weeklyPlanId': instance.weeklyPlanId,
      'dayIndex': instance.dayIndex,
      'label': instance.label,
      'isRestDay': instance.isRestDay,
      'tasks': instance.tasks,
    };
