import 'package:json_annotation/json_annotation.dart';

part 'otp_requested_model.g.dart';

/// Response of `POST /auth/request-otp`.
@JsonSerializable()
class OtpRequestedModel {
  @JsonKey(name: 'success')
  final bool success;

  /// TEMPORARY: the plaintext OTP, echoed by the server while SMS delivery is
  /// unavailable. The server stops sending it after its own cutoff date, so
  /// this must always be treated as nullable.
  @JsonKey(name: 'code')
  final String? code;

  const OtpRequestedModel({
    required this.success,
    this.code,
  });

  factory OtpRequestedModel.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestedModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpRequestedModelToJson(this);
}
