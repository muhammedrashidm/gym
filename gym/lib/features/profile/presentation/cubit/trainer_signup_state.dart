import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../auth/domain/entities/auth_token.dart';

part 'trainer_signup_state.freezed.dart';

@freezed
class TrainerSignupState with _$TrainerSignupState {
  const factory TrainerSignupState.initial({
    @Default([]) List<PlatformFile> certificates,
    @Default([]) List<String> selectedSpecializations,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
    String? errorMessage,
    AuthToken? token,
  }) = _TrainerSignupState;
}
