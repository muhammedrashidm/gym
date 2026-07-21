import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exercise_config.dart';
import '../../domain/repositories/exercise_config_repository.dart';
import '../datasources/exercise_config_remote_datasource.dart';

@Injectable(as: ExerciseConfigRepository)
class ExerciseConfigRepositoryImpl implements ExerciseConfigRepository {
  final ExerciseConfigRemoteDataSource _remoteDataSource;

  const ExerciseConfigRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ({List<ExerciseConfig> items, int total, int page, int pageSize})>> search({
    String? search,
    String? analyzerType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remoteDataSource.search(
        search: search,
        analyzerType: analyzerType,
        page: page,
        pageSize: pageSize,
      );
      return Right((
        items: result.items.map((m) => m.toDomain()).toList(),
        total: result.total,
        page: result.page,
        pageSize: result.pageSize,
      ));
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
