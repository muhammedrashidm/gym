import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_token.freezed.dart';
part 'qr_token.g.dart';

@freezed
class QrToken with _$QrToken {
  const factory QrToken({
    required String qrToken,
    required DateTime expiresAt,
  }) = _QrToken;

  factory QrToken.fromJson(Map<String, dynamic> json) =>
      _$QrTokenFromJson(json);
}
