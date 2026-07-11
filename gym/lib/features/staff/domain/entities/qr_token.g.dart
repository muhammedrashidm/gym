// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QrTokenImpl _$$QrTokenImplFromJson(Map<String, dynamic> json) =>
    _$QrTokenImpl(
      qrToken: json['qrToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$QrTokenImplToJson(_$QrTokenImpl instance) =>
    <String, dynamic>{
      'qrToken': instance.qrToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
