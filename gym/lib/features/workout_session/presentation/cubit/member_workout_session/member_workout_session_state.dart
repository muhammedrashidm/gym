import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../workout/domain/entities/workout_profile.dart';
import '../../../../workout/domain/entities/day_plan.dart';
import '../../../../workout/domain/entities/weekly_plan.dart';
import '../../../domain/entities/session_draft.dart';
import '../../../domain/entities/workout_session_log.dart';
import '../../../../../core/error/failures.dart';

part 'member_workout_session_state.freezed.dart';

@freezed
class MemberWorkoutSessionState with _$MemberWorkoutSessionState {
  const factory MemberWorkoutSessionState.initial() = MemberSessionInitial;
  const factory MemberWorkoutSessionState.loading() = MemberSessionLoading;
  const factory MemberWorkoutSessionState.loaded({
    required WorkoutProfile profile,
    required WeeklyPlan weeklyPlan,
    required DayPlan dayPlan,
    required SessionDraft draft,
    @Default(<int, WorkoutSessionLog>{}) Map<int, WorkoutSessionLog> dayLogs,
    @Default(1) int activeDayIndex,
  }) = MemberSessionLoaded;
  const factory MemberWorkoutSessionState.noPlan() = MemberSessionNoPlan;
  const factory MemberWorkoutSessionState.submitting({
    required WorkoutProfile profile,
    required WeeklyPlan weeklyPlan,
    required DayPlan dayPlan,
    required SessionDraft draft,
    @Default(<int, WorkoutSessionLog>{}) Map<int, WorkoutSessionLog> dayLogs,
    @Default(1) int activeDayIndex,
  }) = MemberSessionSubmitting;
  const factory MemberWorkoutSessionState.submitted({
    required WorkoutSessionLog sessionLog,
  }) = MemberSessionSubmitted;
  const factory MemberWorkoutSessionState.error({
    required Failure failure,
    // Preserve current data so user can retry without data loss
    WorkoutProfile? profile,
    WeeklyPlan? weeklyPlan,
    DayPlan? dayPlan,
    SessionDraft? draft,
    @Default(<int, WorkoutSessionLog>{}) Map<int, WorkoutSessionLog> dayLogs,
    @Default(1) int activeDayIndex,
  }) = MemberSessionError;
}
