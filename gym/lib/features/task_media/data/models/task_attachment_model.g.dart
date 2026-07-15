// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskAttachmentModel _$TaskAttachmentModelFromJson(Map<String, dynamic> json) =>
    TaskAttachmentModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      taskMediaId: json['taskMediaId'] as String,
      caption: json['caption'] as String?,
      sequenceIndex: (json['sequenceIndex'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      taskMedia:
          TaskMediaModel.fromJson(json['taskMedia'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaskAttachmentModelToJson(
        TaskAttachmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'taskMediaId': instance.taskMediaId,
      'caption': instance.caption,
      'sequenceIndex': instance.sequenceIndex,
      'createdAt': instance.createdAt.toIso8601String(),
      'taskMedia': instance.taskMedia.toJson(),
    };
