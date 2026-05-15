import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../config/app_config.dart';
import '../../storage/secure_storage.dart';

@singleton
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  // A separate Dio instance used only for token refresh — avoids circular calls.
  late final Dio _refreshDio;

  bool _isRefreshing = false;
  final List<(RequestOptions, ErrorInterceptorHandler)> _pendingRequests = [];

  AuthInterceptor(this._secureStorage, AppConfig config) {
    _refreshDio = Dio(BaseOptions(baseUrl: config.baseUrl));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Queue request until refresh completes
      _pendingRequests.add((err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _rejectAll(err);
        handler.next(err);
        return;
      }

      // API: POST /auth/refresh with Authorization: Bearer {refreshToken}
      final response = await _refreshDio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String?;

      await _secureStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.saveRefreshToken(newRefreshToken);
      }

      // Retry original request
      handler.resolve(await _retry(err.requestOptions, newAccessToken));

      // Retry all queued requests
      for (final (options, pendingHandler) in _pendingRequests) {
        pendingHandler.resolve(await _retry(options, newAccessToken));
      }
    } catch (_) {
      await _secureStorage.clearTokens();
      _rejectAll(err);
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    return _refreshDio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {...options.headers, 'Authorization': 'Bearer $token'},
      ),
    );
  }

  void _rejectAll(DioException err) {
    for (final (_, handler) in _pendingRequests) {
      handler.next(err);
    }
  }
}
