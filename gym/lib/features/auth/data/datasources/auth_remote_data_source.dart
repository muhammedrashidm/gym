import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_token_model.dart';
import '../models/otp_requested_model.dart';

abstract interface class AuthRemoteDataSource {
  /// Returns the plaintext OTP while the server still echoes it (no SMS
  /// provider yet), or null once it stops.
  Future<String?> sendOtp({required String phoneNumber});
  Future<AuthTokenModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  });
  Future<void> logout({required String refreshToken});
}

@Singleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String?> sendOtp({required String phoneNumber}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/request-otp',
      data: {'phoneNumber': phoneNumber},
    );
    return OtpRequestedModel.fromJson(response.data as Map<String, dynamic>)
        .code;
  }

  @override
  Future<AuthTokenModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {'phoneNumber': phoneNumber, 'code': otp},
    );
    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
