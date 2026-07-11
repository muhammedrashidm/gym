import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_model.g.dart';

@JsonSerializable()
class OtpVerifyModel {
  final String phoneNumber;
  final String code;

  const OtpVerifyModel({
    required this.phoneNumber,
    required this.code,
  });

  factory OtpVerifyModel.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyModelToJson(this);
}
