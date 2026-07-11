import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/trainer_connection.dart';
import '../repositories/profile_repository.dart';

class ConnectToTrainerCommand extends ICommand<Future<Either<Failure, TrainerConnection>>> {
  final String qrToken;

  ConnectToTrainerCommand({required this.qrToken});
}

@injectable
class ConnectToTrainerCommandHandler
    extends ICommandHandler<ConnectToTrainerCommand, Future<Either<Failure, TrainerConnection>>> {
  final ProfileRepository _repository;

  ConnectToTrainerCommandHandler(this._repository);

  @override
  Future<Either<Failure, TrainerConnection>> handle(ConnectToTrainerCommand command) {
    return _repository.connectToTrainer(qrToken: command.qrToken);
  }
}
