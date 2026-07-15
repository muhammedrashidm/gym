import 'package:freezed_annotation/freezed_annotation.dart';
import 'task_completion_entry.dart';

part 'workout_session_log.freezed.dart';

enum SessionStatus { completed, skipped, inProgress, partial }

enum LoggedByRole { member, trainer }

@freezed
class WorkoutSessionLog with _$WorkoutSessionLog {
  const factory WorkoutSessionLog({
    required String id,
    required String workoutProfileId,
    String? weeklyPlanId,
    String? weeklyPlanName,
    String? dayPlanId,
    String? dayPlanLabel,
    required int dayIndexAtTime,
    required int cycleNumberAtTime,
    required SessionStatus status,
    String? scheduledDate,
    String? completedDate,
    required LoggedByRole loggedByRole,
    required String loggedByUserId,
    int? currentDayIndexAfter,
    @Default(<TaskCompletionEntry>[]) List<TaskCompletionEntry> taskCompletionLogs,
  }) = _WorkoutSessionLog;
}
