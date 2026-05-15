import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';
import 'verify_otp_command.dart';

@injectable
class VerifyOtpCommandHandler
    extends ICommandHandler<VerifyOtpCommand, Future<Either<Failure, AuthToken>>> {
  final AuthRepository _repository;

  VerifyOtpCommandHandler(this._repository);

  @override
  Future<Either<Failure, AuthToken>> handle(VerifyOtpCommand command) =>
      _repository.verifyOtp(
        phoneNumber: command.phoneNumber,
        otp: command.otp,
      );
}
