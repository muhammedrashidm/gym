import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/workout_profile.dart';

part 'initiate_program_state.freezed.dart';

@freezed
class InitiateProgramState with _$InitiateProgramState {
  const factory InitiateProgramState.initial() = _Initial;
  const factory InitiateProgramState.loading() = _Loading;
  const factory InitiateProgramState.success(WorkoutProfile profile) = _Success;
  const factory InitiateProgramState.error(String message) = _Error;
}
