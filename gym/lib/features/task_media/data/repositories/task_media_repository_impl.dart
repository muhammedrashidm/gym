import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_media.dart';
import '../../domain/repositories/task_media_repository.dart';
import '../datasources/task_media_remote_datasource.dart';

@Injectable(as: TaskMediaRepository)
class TaskMediaRepositoryImpl implements TaskMediaRepository {
  final TaskMediaRemoteDataSource _remoteDataSource;

  const TaskMediaRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ({List<TaskMedia> items, int total, int page, int pageSize})>> search({
    String? search,
    bool? mine,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remoteDataSource.search(
        search: search,
        mine: mine,
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

  @override
  Future<Either<Failure, TaskMedia>> create({
    required PlatformFile file,
    required String name,
    String? description,
    List<String>? keywords,
    bool isPrivate = false,
  }) async {
    try {
      final model = await _remoteDataSource.create(
        file: file,
        name: name,
        description: description,
        keywords: keywords,
        isPrivate: isPrivate,
      );
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
