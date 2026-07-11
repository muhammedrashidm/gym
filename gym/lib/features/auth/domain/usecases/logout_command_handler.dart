import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import 'logout_command.dart';

@injectable
class LogoutCommandHandler extends ICommandHandler<LogoutCommand, Future<Either<Failure, Unit>>> {
  final AuthRepository _repository;

  LogoutCommandHandler(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(LogoutCommand command) async {
    return await _repository.logout(refreshToken: command.refreshToken);
  }
}
