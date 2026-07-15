import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../workout/domain/entities/workout_profile.dart';
import '../../../../workout/domain/entities/day_plan.dart';
import '../../../../workout/domain/entities/weekly_plan.dart';
import '../../../domain/entities/session_draft.dart';
import '../../../domain/entities/workout_session_log.dart';
import '../../../../../core/error/failures.dart';

part 'trainer_client_session_state.freezed.dart';

@freezed
class TrainerClientSessionState with _$TrainerClientSessionState {
  const factory TrainerClientSessionState.initial() = TrainerSessionInitial;
  const factory TrainerClientSessionState.loading() = TrainerSessionLoading;
  const factory TrainerClientSessionState.loaded({
    required WorkoutProfile profile,
    required WeeklyPlan weeklyPlan,
    required DayPlan dayPlan,
    required SessionDraft draft,
    required String clientName,
    @Default(<int, WorkoutSessionLog>{}) Map<int, WorkoutSessionLog> dayLogs,
    @Default(1) int activeDayIndex,
  }) = TrainerSessionLoaded;
  const factory TrainerClientSessionState.noPlan({
    required String clientName,
  }) = TrainerSessionNoPlan;
  const factory TrainerClientSessionState.submitting({
    required WorkoutProfile profile,
    required WeeklyPlan weeklyPlan,
    required DayPlan dayPlan,
    required SessionDraft draft,
    required String clientName,
    @Default(<int, WorkoutSessionLog>{}) Map<int, WorkoutSessionLog> dayLogs,
    @Default(1) int activeDayIndex,
  }) = TrainerSessionSubmitting;
  const factory TrainerClientSessionState.submitted({
    required WorkoutSessionLog sessionLog,
  }) = TrainerSessionSubmitted;
  const factory TrainerClientSessionState.error({
    required Failure failure,
    String? clientName,
    WorkoutProfile? profile,
    WeeklyPlan? weeklyPlan,
    DayPlan? dayPlan,
    SessionDraft? draft,
    @Default(<int, WorkoutSessionLog>{}) Map<int, WorkoutSessionLog> dayLogs,
    @Default(1) int activeDayIndex,
  }) = TrainerSessionError;
}
