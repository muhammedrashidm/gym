import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/qr_token.dart';

part 'qr_token_model.g.dart';

@JsonSerializable()
class QrTokenModel {
  final String qrToken;
  final String expiresAt;

  const QrTokenModel({
    required this.qrToken,
    required this.expiresAt,
  });

  factory QrTokenModel.fromJson(Map<String, dynamic> json) =>
      _$QrTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$QrTokenModelToJson(this);

  QrToken toDomain() => QrToken(
        qrToken: qrToken,
        expiresAt: DateTime.parse(expiresAt),
      );
}
