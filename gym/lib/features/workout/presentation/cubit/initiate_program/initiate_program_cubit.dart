import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/workout_profile.dart';
import '../../../domain/usecases/manage_workout_profiles.dart';
import 'initiate_program_state.dart';

class InitiateProgramCubit extends Cubit<InitiateProgramState> {
  final Mediator _mediator;

  InitiateProgramCubit(this._mediator) : super(const InitiateProgramState.initial());

  Future<void> createProfile({
    required String clientId,
    required String name,
    required String startDate,
  }) async {
    emit(const InitiateProgramState.loading());

    final result = await _mediator.sendCommand(
      CreateWorkoutProfileCommand(
        clientProfileId: clientId,
        name: name,
        startDate: startDate,
      ),
    ) as Either<Failure, WorkoutProfile>;

    result.fold(
      (failure) {
        emit(InitiateProgramState.error(_mapFailureToMessage(failure)));
      },
      (profile) {
        emit(InitiateProgramState.success(profile));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.maybeWhen(
      server: (_, msg) => msg,
      network: (msg) => msg ?? 'Network error.',
      unknown: (msg) => msg ?? 'Unknown error.',
      unauthorized: () => 'Unauthorized.',
      orElse: () => 'Unexpected error.',
    );
  }
}
