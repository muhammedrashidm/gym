// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskMediaModel _$TaskMediaModelFromJson(Map<String, dynamic> json) =>
    TaskMediaModel(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPrivate: json['isPrivate'] as bool? ?? false,
      createdById: json['createdById'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TaskMediaModelToJson(TaskMediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'keywords': instance.keywords,
      'isPrivate': instance.isPrivate,
      'createdById': instance.createdById,
      'url': instance.url,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
