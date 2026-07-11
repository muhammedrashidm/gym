import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../entities/workout_profile.dart';
import '../value_objects/draft_day_plan.dart';
import '../entities/weekly_plan.dart';
import '../entities/day_plan.dart';
import '../entities/task.dart';
import '../../../workout_session/domain/entities/workout_session_log.dart';
import '../../../workout_session/domain/entities/task_completion_draft.dart';

abstract interface class WorkoutRepository {
  /// Pass `null` to resolve "my own" workout profiles (the caller's own
  /// client profile, or their assigned clients if a trainer) — the server
  /// infers this from the auth context when the filter is omitted.
  Future<Either<Failure, List<WorkoutProfile>>> getWorkoutProfiles(String? clientProfileId);

  Future<Either<Failure, WorkoutProfile>> createWorkoutProfile({
    required String clientProfileId,
    required String name,
    required String startDate,
  });

  Future<Either<Failure, WorkoutProfile>> updateWorkoutProfile({
    required String id,
    bool? isActive,
    int? currentDayIndex,
  });

  Future<Either<Failure, WeeklyPlan>> createWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
  });

  Future<Either<Failure, WeeklyPlan>> createFullWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
    bool activateImmediately = false,
    required List<DraftDayPlan> days,
  });

  Future<Either<Failure, List<WeeklyPlan>>> getWeeklyPlans(String workoutProfileId);

  Future<Either<Failure, WeeklyPlan>> getWeeklyPlanDetails(String weeklyPlanId);

  Future<Either<Failure, WeeklyPlan>> activateWeeklyPlan(String weeklyPlanId);

  Future<Either<Failure, DayPlan>> getDayPlanDetails(String dayPlanId);

  /// Today's DayPlan for [workoutProfileId], resolved server-side from the
  /// profile's current cursor. Null if no active weekly plan is assigned.
  Future<Either<Failure, DayPlan?>> getTodayPlan(String workoutProfileId);

  Future<Either<Failure, DayPlan>> updateDayPlan({
    required String dayPlanId,
    String? label,
    bool? isRestDay,
  });

  Future<Either<Failure, Task>> createTask({
    required String dayPlanId,
    required String name,
    required int sets,
    required String reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    required int sequenceIndex,
  });

  Future<Either<Failure, Task>> updateTask({
    required String taskId,
    String? name,
    int? sets,
    String? reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    int? sequenceIndex,
  });

  Future<Either<Failure, Unit>> deleteTask(String taskId);

  // ─── Session submission ──────────────────────────────────────────────────

  Future<Either<Failure, WorkoutSessionLog>> completeSession(
    String workoutProfileId, {
    List<TaskCompletionInput>? taskCompletions,
    String? notes,
  });

  Future<Either<Failure, WorkoutSessionLog>> skipSession(
    String workoutProfileId, {
    String? reason,
  });

  Future<
      Either<
          Failure,
          ({
            List<WorkoutSessionLog> logs,
            int total,
            int page,
            int pageSize,
          })>> getSessionLogs(
    String workoutProfileId, {
    int page = 1,
    int pageSize = 20,
  });
}
