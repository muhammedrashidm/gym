import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/workout_profile.dart';
import '../../../domain/entities/weekly_plan.dart';

part 'athlete_profile_state.freezed.dart';

@freezed
class AthleteProfileState with _$AthleteProfileState {
  const factory AthleteProfileState.initial() = _Initial;
  const factory AthleteProfileState.loading() = _Loading;
  const factory AthleteProfileState.loaded({
    required List<WorkoutProfile> profiles,
    WorkoutProfile? activeProfile,
    required List<WeeklyPlan> weeklyPlans,
  }) = AthleteProfileLoaded;
  const factory AthleteProfileState.error(String message) = AthleteProfileError;
}
