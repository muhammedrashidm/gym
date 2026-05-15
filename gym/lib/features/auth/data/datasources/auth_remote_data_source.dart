import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_token_model.dart';

@singleton
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSource(this._apiClient);

  /// POST /auth/request-otp
  /// Body: { "phoneNumber": "+1234567890" }
  /// Response: { "success": true }
  Future<void> sendOtp({required String phoneNumber}) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/auth/request-otp',
      data: {'phoneNumber': phoneNumber},
    );
  }

  /// POST /auth/verify-otp
  /// Body: { "phoneNumber": "+1234567890", "code": "1234" }
  /// Response: { "accessToken": "...", "refreshToken": "...", "user": {...} }
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

  /// POST /auth/logout
  /// Header: Authorization: Bearer {accessToken}
  /// Body: { "refreshToken": "uuid" }
  Future<void> logout({required String refreshToken}) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
