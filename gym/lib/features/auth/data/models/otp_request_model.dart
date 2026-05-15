import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_request_model.freezed.dart';
part 'otp_request_model.g.dart';

@freezed
class OtpRequestModel with _$OtpRequestModel {
  const factory OtpRequestModel({
    required String phoneNumber,
  }) = _OtpRequestModel;

  factory OtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestModelFromJson(json);
}
