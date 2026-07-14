import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/domain/entities/auth_token.dart';
import 'interceptors/logger_interceptor.dart';
import 'token_refresh_result.dart';

/// Single source of truth for refreshing the access/refresh token pair.
///
/// Uses its own bare [Dio] (no [AuthInterceptor] attached) so a refresh call
/// never recurses into itself. Refresh attempts are single-flight: concurrent
/// callers await the one in-flight call instead of racing the server, which
/// rotates (single-uses) the refresh token on every successful call.
@singleton
class TokenRefreshService {
  final SecureStorage _secureStorage;
  final Dio _dio;

  Future<RefreshResult>? _inFlight;

  TokenRefreshService(this._secureStorage, AppConfig config)
      : _dio = Dio(BaseOptions(baseUrl: config.baseUrl)) {
    // No AuthInterceptor here (see class doc), but attach the logger so
    // refresh calls and retried requests are still visible in logs instead
    // of silently succeeding after a logged 401 from the original attempt.
    if (config.enableLogging) {
      _dio.interceptors.add(LoggerInterceptor());
    }
  }

  /// A bare Dio instance (no auth interceptor) for replaying requests after a
  /// successful refresh.
  Dio get bareDio => _dio;

  Future<RefreshResult> refresh() {
    return _inFlight ??= _doRefresh().whenComplete(() => _inFlight = null);
  }

  Future<RefreshResult> _doRefresh() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) {
      return const RefreshResult.rejected();
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final data = response.data!;
      final token = AuthToken(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );

      await _secureStorage.saveAccessToken(token.accessToken);
      await _secureStorage.saveRefreshToken(token.refreshToken);

      return RefreshResult.success(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.clearTokens();
        return const RefreshResult.rejected();
      }
      return const RefreshResult.transientFailure();
    } catch (_) {
      return const RefreshResult.transientFailure();
    }
  }
}
