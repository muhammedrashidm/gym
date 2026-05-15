import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Unit>> sendOtp({required String phoneNumber});
  Future<Either<Failure, AuthToken>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });
}
