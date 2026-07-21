// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseConfigModel _$ExerciseConfigModelFromJson(Map<String, dynamic> json) =>
    ExerciseConfigModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      aiConfigJson: json['aiConfigJson'] as Map<String, dynamic>?,
      analyzerType: json['analyzerType'] as String,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mediaUrl: json['mediaUrl'] as String,
    );

Map<String, dynamic> _$ExerciseConfigModelToJson(
        ExerciseConfigModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'analyzerType': instance.analyzerType,
      'aiConfigJson': instance.aiConfigJson,
      'keywords': instance.keywords,
      'mediaUrl': instance.mediaUrl,
    };
