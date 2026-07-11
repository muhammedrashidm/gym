// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSessionLogModel _$WorkoutSessionLogModelFromJson(
        Map<String, dynamic> json) =>
    WorkoutSessionLogModel(
      id: json['id'] as String,
      workoutProfileId: json['workoutProfileId'] as String,
      weeklyPlanId: json['weeklyPlanId'] as String?,
      weeklyPlanName: json['weeklyPlanName'] as String?,
      dayPlanId: json['dayPlanId'] as String?,
      dayPlanLabel: json['dayPlanLabel'] as String?,
      dayIndexAtTime: (json['dayIndexAtTime'] as num).toInt(),
      cycleNumberAtTime: (json['cycleNumberAtTime'] as num).toInt(),
      status: json['status'] as String,
      scheduledDate: json['scheduledDate'] as String?,
      completedDate: json['completedDate'] as String?,
      loggedByRole: json['loggedByRole'] as String,
      loggedByUserId: json['loggedByUserId'] as String,
      currentDayIndexAfter: (json['currentDayIndexAfter'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkoutSessionLogModelToJson(
        WorkoutSessionLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workoutProfileId': instance.workoutProfileId,
      'weeklyPlanId': instance.weeklyPlanId,
      'weeklyPlanName': instance.weeklyPlanName,
      'dayPlanId': instance.dayPlanId,
      'dayPlanLabel': instance.dayPlanLabel,
      'dayIndexAtTime': instance.dayIndexAtTime,
      'cycleNumberAtTime': instance.cycleNumberAtTime,
      'status': instance.status,
      'scheduledDate': instance.scheduledDate,
      'completedDate': instance.completedDate,
      'loggedByRole': instance.loggedByRole,
      'loggedByUserId': instance.loggedByUserId,
      'currentDayIndexAfter': instance.currentDayIndexAfter,
    };
