// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_requested_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpRequestedModel _$OtpRequestedModelFromJson(Map<String, dynamic> json) =>
    OtpRequestedModel(
      success: json['success'] as bool,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$OtpRequestedModelToJson(OtpRequestedModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
    };
