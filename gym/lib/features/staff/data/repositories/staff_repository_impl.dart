import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/entities/qr_token.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_datasource.dart';

@Injectable(as: StaffRepository)
class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource _remoteDataSource;

  const StaffRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, QrToken>> getQrToken() async {
    try {
      final model = await _remoteDataSource.getQrToken();
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClientProfile>>> listStaffClients() async {
    try {
      final models = await _remoteDataSource.listStaffClients();
      final domains = models.map((m) => m.toDomain()).toList();
      return Right(domains);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientProfile>> staffCreateProfile({
    required String phoneNumber,
    required String fullName,
    int? age,
    String? sex,
    String? expLevel,
    double? weight,
    double? height,
    double? muscleMass,
    double? bodyFatPct,
  }) async {
    try {
      final model = await _remoteDataSource.staffCreateProfile(
        phoneNumber: phoneNumber,
        fullName: fullName,
        age: age,
        sex: sex,
        expLevel: expLevel,
        weight: weight,
        height: height,
        muscleMass: muscleMass,
        bodyFatPct: bodyFatPct,
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
