import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/auth_token.dart';
import '../../domain/entities/trainer_connection.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AuthToken>> trainerSignup({
    required String name,
    required String bio,
    required int experienceYears,
    required List<String> specializations,
    required List<PlatformFile> certificates,
  }) async {
    try {
      final model = await _remoteDataSource.trainerSignup(
        name: name,
        bio: bio,
        experienceYears: experienceYears,
        specializations: specializations,
        certificates: certificates,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrainerConnection>> connectToTrainer({
    required String qrToken,
  }) async {
    try {
      final model = await _remoteDataSource.connectToTrainer(qrToken);
      return Right(model.toDomain());
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
