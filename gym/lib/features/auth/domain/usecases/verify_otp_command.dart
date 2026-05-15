import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';

class VerifyOtpCommand extends ICommand<Future<Either<Failure, AuthToken>>> {
  final String phoneNumber;
  final String otp;
  VerifyOtpCommand({required this.phoneNumber, required this.otp});
}
