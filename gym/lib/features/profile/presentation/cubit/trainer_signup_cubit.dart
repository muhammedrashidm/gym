import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/auth_token.dart';
import '../../domain/usecases/trainer_signup_command.dart';
import 'trainer_signup_state.dart';

class TrainerSignupCubit extends Cubit<TrainerSignupState> {
  final Mediator _mediator;

  TrainerSignupCubit(this._mediator) : super(const TrainerSignupState.initial());

  void addCertificates(List<PlatformFile> newFiles) {
    final updatedList = List<PlatformFile>.from(state.certificates)..addAll(newFiles);
    emit(state.copyWith(certificates: updatedList, errorMessage: null));
  }

  void removeCertificate(PlatformFile file) {
    final updatedList = List<PlatformFile>.from(state.certificates)..remove(file);
    emit(state.copyWith(certificates: updatedList, errorMessage: null));
  }

  void toggleSpecialization(String spec) {
    final updatedList = List<String>.from(state.selectedSpecializations);
    if (updatedList.contains(spec)) {
      updatedList.remove(spec);
    } else {
      updatedList.add(spec);
    }
    emit(state.copyWith(selectedSpecializations: updatedList, errorMessage: null));
  }

  Future<void> submit({
    required String name,
    required String bio,
    required int experienceYears,
  }) async {
    if (name.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter your name.'));
      return;
    }
    if (experienceYears <= 0) {
      emit(state.copyWith(errorMessage: 'Years of experience must be greater than 0.'));
      return;
    }
    if (state.certificates.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please upload at least one certificate/credential.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false));

    final result = await _mediator.sendCommand(TrainerSignupCommand(
      name: name,
      bio: bio,
      experienceYears: experienceYears,
      specializations: state.selectedSpecializations,
      certificates: state.certificates,
    )) as Either<Failure, AuthToken>;

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.toString(),
        ));
      },
      (token) {
        emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          token: token,
        ));
      },
    );
  }
}
