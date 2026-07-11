import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_profile.dart';
import '../entities/qr_token.dart';

abstract interface class StaffRepository {
  Future<Either<Failure, QrToken>> getQrToken();
  Future<Either<Failure, List<ClientProfile>>> listStaffClients();
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
  });
}
