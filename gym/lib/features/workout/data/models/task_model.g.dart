// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String,
      dayPlanId: json['dayPlanId'] as String,
      sequenceIndex: (json['sequenceIndex'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      machineDetails: json['machineDetails'] as String?,
      notes: json['notes'] as String?,
      sets: (json['sets'] as num).toInt(),
      reps: json['reps'] as String,
      restSeconds: (json['restSeconds'] as num?)?.toInt(),
      tempo: json['tempo'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) =>
                  TaskAttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'dayPlanId': instance.dayPlanId,
      'sequenceIndex': instance.sequenceIndex,
      'name': instance.name,
      'description': instance.description,
      'machineDetails': instance.machineDetails,
      'notes': instance.notes,
      'sets': instance.sets,
      'reps': instance.reps,
      'restSeconds': instance.restSeconds,
      'tempo': instance.tempo,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
    };
