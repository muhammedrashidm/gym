class ServerException implements Exception {
  final int statusCode;
  final String message;

  const ServerException({required this.statusCode, required this.message});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String? message;

  const NetworkException({this.message});

  @override
  String toString() => 'NetworkException: ${message ?? 'No internet connection'}';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException';
}

class CacheException implements Exception {
  final String? message;

  const CacheException({this.message});

  @override
  String toString() => 'CacheException: ${message ?? 'Cache error'}';
}
