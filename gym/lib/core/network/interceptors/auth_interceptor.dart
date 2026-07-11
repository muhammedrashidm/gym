import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../di/injection.dart';
import '../../storage/secure_storage.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../token_refresh_result.dart';
import '../token_refresh_service.dart';

@singleton
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final TokenRefreshService _tokenRefreshService;

  bool _isRefreshing = false;
  final List<(RequestOptions, ErrorInterceptorHandler)> _pendingRequests = [];

  AuthInterceptor(this._secureStorage, this._tokenRefreshService);

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
      // Queue request until the in-flight refresh completes
      _pendingRequests.add((err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final result = await _tokenRefreshService.refresh();

      switch (result) {
        case RefreshSuccess(:final token):
          handler.resolve(await _retry(err.requestOptions, token.accessToken));
          for (final (options, pendingHandler) in _pendingRequests) {
            pendingHandler.resolve(await _retry(options, token.accessToken));
          }
        case RefreshRejected():
          // Server explicitly rejected the refresh token — this is the one
          // scenario that forces a logout.
          _rejectAll(err);
          handler.next(err);
          getIt<AuthCubit>().forceLogout();
        case RefreshTransientFailure():
          // Network/timeout error — leave the session untouched, just fail
          // this request (and any queued ones) so callers can retry later.
          _rejectAll(err);
          handler.next(err);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    // FormData is single-use — it gets finalized (its byte streams consumed)
    // the first time it's sent, so a retry must clone it or the request
    // fails with "The FormData has already been finalized."
    final data = options.data;
    final retryData = data is FormData ? data.clone() : data;

    return _tokenRefreshService.bareDio.request(
      options.path,
      data: retryData,
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
