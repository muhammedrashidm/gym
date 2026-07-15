// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCompletionEntryModel _$TaskCompletionEntryModelFromJson(
        Map<String, dynamic> json) =>
    TaskCompletionEntryModel(
      taskId: json['taskId'] as String,
      actualSets: (json['actualSets'] as num?)?.toInt(),
      actualReps: json['actualReps'] as String?,
      actualWeightKg: (json['actualWeightKg'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TaskCompletionEntryModelToJson(
        TaskCompletionEntryModel instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'actualSets': instance.actualSets,
      'actualReps': instance.actualReps,
      'actualWeightKg': instance.actualWeightKg,
      'notes': instance.notes,
    };

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
      taskCompletionLogs: (json['taskCompletionLogs'] as List<dynamic>?)
          ?.map((e) =>
              TaskCompletionEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'taskCompletionLogs': instance.taskCompletionLogs,
    };
