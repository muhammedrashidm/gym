import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';

abstract interface class AuthRepository {
  /// Right holds the plaintext OTP while the server still echoes it back
  /// (no SMS provider yet), or null once it stops.
  Future<Either<Failure, String?>> sendOtp({required String phoneNumber});
  Future<Either<Failure, AuthToken>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });
  Future<Either<Failure, Unit>> logout({required String refreshToken});
}
