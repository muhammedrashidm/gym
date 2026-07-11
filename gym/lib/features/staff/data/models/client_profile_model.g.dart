// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientProfileModel _$ClientProfileModelFromJson(Map<String, dynamic> json) =>
    ClientProfileModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String,
      isClaimed: json['isClaimed'] as bool,
      isActive: json['isActive'] as bool,
      userId: json['userId'] as String?,
      age: (json['age'] as num?)?.toInt(),
      sex: json['sex'] as String?,
      expLevel: json['expLevel'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bodyMetrics: (json['bodyMetrics'] as List<dynamic>?)
              ?.map((e) => BodyMetricsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ClientProfileModelToJson(ClientProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phoneNumber': instance.phoneNumber,
      'fullName': instance.fullName,
      'isClaimed': instance.isClaimed,
      'isActive': instance.isActive,
      'userId': instance.userId,
      'age': instance.age,
      'sex': instance.sex,
      'expLevel': instance.expLevel,
      'avatarUrl': instance.avatarUrl,
      'bodyMetrics': instance.bodyMetrics,
    };

BodyMetricsModel _$BodyMetricsModelFromJson(Map<String, dynamic> json) =>
    BodyMetricsModel(
      id: json['id'] as String,
      weight: json['weight'] as num,
      height: json['height'] as num,
      muscleMass: json['muscleMass'] as num?,
      bodyFatPct: json['bodyFatPct'] as num?,
    );

Map<String, dynamic> _$BodyMetricsModelToJson(BodyMetricsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weight': instance.weight,
      'height': instance.height,
      'muscleMass': instance.muscleMass,
      'bodyFatPct': instance.bodyFatPct,
    };
