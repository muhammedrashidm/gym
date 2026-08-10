import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import 'send_otp_command.dart';

@injectable
class SendOtpCommandHandler extends ICommandHandler<SendOtpCommand, Future<Either<Failure, String?>>> {
  final AuthRepository _repository;

  SendOtpCommandHandler(this._repository);

  @override
  Future<Either<Failure, String?>> handle(SendOtpCommand command) async {
    return await _repository.sendOtp(phoneNumber: command.phoneNumber);
  }
}
