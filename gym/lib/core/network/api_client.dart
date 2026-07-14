import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

@singleton
class ApiClient {
  late final Dio _dio;

  ApiClient(AppConfig config, AuthInterceptor authInterceptor) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Platform': 'mobile',
        },
      ),
    );

    if (config.enableLogging) {
      _dio.interceptors.add(LoggerInterceptor());
    }

    // Retried requests are replayed on TokenRefreshService.bareDio (a
    // separate Dio instance, to avoid recursing back into this interceptor),
    // which attaches its own LoggerInterceptor — so they're logged there,
    // not by this chain's ordering.
    _dio.interceptors.add(authInterceptor);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete(path);
}
