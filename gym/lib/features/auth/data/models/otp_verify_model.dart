import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_verify_model.freezed.dart';
part 'otp_verify_model.g.dart';

@freezed
class OtpVerifyModel with _$OtpVerifyModel {
  const factory OtpVerifyModel({
    required String phoneNumber,
    required String code,
  }) = _OtpVerifyModel;

  factory OtpVerifyModel.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyModelFromJson(json);
}
