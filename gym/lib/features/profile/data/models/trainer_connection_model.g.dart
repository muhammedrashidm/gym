// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_connection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerConnectionModel _$TrainerConnectionModelFromJson(
        Map<String, dynamic> json) =>
    TrainerConnectionModel(
      id: json['id'] as String,
      staffProfileId: json['staffProfileId'] as String,
      clientProfileId: json['clientProfileId'] as String,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$TrainerConnectionModelToJson(
        TrainerConnectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staffProfileId': instance.staffProfileId,
      'clientProfileId': instance.clientProfileId,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
    };
