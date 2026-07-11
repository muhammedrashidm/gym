import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_token_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<void> sendOtp({required String phoneNumber});
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
  Future<void> sendOtp({required String phoneNumber}) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/auth/request-otp',
      data: {'phoneNumber': phoneNumber},
    );
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
