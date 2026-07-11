import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Unit>> sendOtp({required String phoneNumber}) async {
    try {
      await _remoteDataSource.sendOtp(phoneNumber: phoneNumber);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final model = await _remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout({required String refreshToken}) async {
    try {
      await _remoteDataSource.logout(refreshToken: refreshToken);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        const Failure.network(),
      _ => switch (e.response?.statusCode) {
          401 => const Failure.unauthorized(),
          int code => Failure.server(
              statusCode: code,
              message: _parseErrorMessage(e.response?.data?['message']),
            ),
          null => Failure.unknown(message: e.message),
        },
    };
  }

  String _parseErrorMessage(dynamic messageData) {
    if (messageData is List) {
      return messageData.join(', ');
    }
    if (messageData is String) {
      return messageData;
    }
    return 'Server error';
  }
}
