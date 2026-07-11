// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerifyModel _$OtpVerifyModelFromJson(Map<String, dynamic> json) =>
    OtpVerifyModel(
      phoneNumber: json['phoneNumber'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$OtpVerifyModelToJson(OtpVerifyModel instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'code': instance.code,
    };
