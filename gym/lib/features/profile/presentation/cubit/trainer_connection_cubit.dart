import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trainer_connection.dart';
import '../../domain/usecases/connect_to_trainer_command.dart';
import 'trainer_connection_state.dart';

class TrainerConnectionCubit extends Cubit<TrainerConnectionState> {
  final Mediator _mediator;

  TrainerConnectionCubit(this._mediator) : super(const TrainerConnectionState.initial());

  Future<void> connectToTrainer(String qrToken) async {
    emit(const TrainerConnectionState.connecting());
    final result = await _mediator.sendCommand(ConnectToTrainerCommand(qrToken: qrToken))
        as Either<Failure, TrainerConnection>;
    result.fold(
      (failure) {
        final message = failure.maybeWhen(
          server: (_, msg) => msg,
          network: (msg) => msg ?? 'Network error.',
          unknown: (msg) => msg ?? 'Unknown error.',
          unauthorized: () => 'Unauthorized.',
          orElse: () => 'Unexpected error.',
        );
        emit(TrainerConnectionState.error(message));
      },
      (connection) => emit(TrainerConnectionState.connected(connection)),
    );
  }

  void reset() {
    emit(const TrainerConnectionState.initial());
  }
}
