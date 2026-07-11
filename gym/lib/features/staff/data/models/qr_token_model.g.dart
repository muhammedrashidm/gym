// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrTokenModel _$QrTokenModelFromJson(Map<String, dynamic> json) => QrTokenModel(
      qrToken: json['qrToken'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$QrTokenModelToJson(QrTokenModel instance) =>
    <String, dynamic>{
      'qrToken': instance.qrToken,
      'expiresAt': instance.expiresAt,
    };
