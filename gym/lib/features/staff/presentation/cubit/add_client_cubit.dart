import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/usecases/staff_create_profile_command.dart';
import 'add_client_state.dart';

class AddClientCubit extends Cubit<AddClientState> {
  final Mediator _mediator;

  AddClientCubit(this._mediator) : super(const AddClientState.initial());

  Future<void> createClient({
    required String phoneNumber,
    required String fullName,
    int? age,
    String? sex,
    String? expLevel,
    double? weight,
    double? height,
    double? muscleMass,
    double? bodyFatPct,
  }) async {
    emit(const AddClientState.submitting());
    final result = await _mediator.sendCommand(StaffCreateProfileCommand(
      phoneNumber: phoneNumber,
      fullName: fullName,
      age: age,
      sex: sex,
      expLevel: expLevel,
      weight: weight,
      height: height,
      muscleMass: muscleMass,
      bodyFatPct: bodyFatPct,
    )) as Either<Failure, ClientProfile>;
    result.fold(
      (failure) {
        final message = failure.maybeWhen(
          server: (_, msg) => msg,
          network: (msg) => msg ?? 'Network error.',
          unknown: (msg) => msg ?? 'Unknown error.',
          unauthorized: () => 'Unauthorized.',
          orElse: () => 'Unexpected error.',
        );
        emit(AddClientState.error(message));
      },
      (profile) => emit(AddClientState.success(profile)),
    );
  }
}
