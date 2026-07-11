// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainerConnectionImpl _$$TrainerConnectionImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainerConnectionImpl(
      id: json['id'] as String,
      staffProfileId: json['staffProfileId'] as String,
      clientProfileId: json['clientProfileId'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TrainerConnectionImplToJson(
        _$TrainerConnectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staffProfileId': instance.staffProfileId,
      'clientProfileId': instance.clientProfileId,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
