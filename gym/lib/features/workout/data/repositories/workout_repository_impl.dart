import 'package:dartz/dartz.dart' hide Task;
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/workout_profile.dart';
import '../../domain/entities/weekly_plan.dart';
import '../../domain/entities/day_plan.dart';
import '../../domain/entities/task.dart';
import '../../domain/value_objects/draft_day_plan.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_remote_datasource.dart';
import '../../../workout_session/domain/entities/workout_session_log.dart';
import '../../../workout_session/domain/entities/task_completion_draft.dart';

@Injectable(as: WorkoutRepository)
class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource _remoteDataSource;

  const WorkoutRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<WorkoutProfile>>> getWorkoutProfiles(String? clientProfileId) async {
    try {
      final models = await _remoteDataSource.getWorkoutProfiles(clientProfileId);
      final domains = models.map((m) => m.toDomain()).toList();
      return Right(domains);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutProfile>> createWorkoutProfile({
    required String clientProfileId,
    required String name,
    required String startDate,
  }) async {
    try {
      final model = await _remoteDataSource.createWorkoutProfile(
        clientProfileId: clientProfileId,
        name: name,
        startDate: startDate,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutProfile>> updateWorkoutProfile({
    required String id,
    bool? isActive,
    int? currentDayIndex,
  }) async {
    try {
      final model = await _remoteDataSource.updateWorkoutProfile(
        id: id,
        isActive: isActive,
        currentDayIndex: currentDayIndex,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeeklyPlan>> createWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
  }) async {
    try {
      final model = await _remoteDataSource.createWeeklyPlan(
        workoutProfileId: workoutProfileId,
        name: name,
        notes: notes,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeeklyPlan>> createFullWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
    bool activateImmediately = false,
    required List<DraftDayPlan> days,
  }) async {
    try {
      final model = await _remoteDataSource.createFullWeeklyPlan(
        workoutProfileId: workoutProfileId,
        name: name,
        notes: notes,
        activateImmediately: activateImmediately,
        days: days,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WeeklyPlan>>> getWeeklyPlans(String workoutProfileId) async {
    try {
      final models = await _remoteDataSource.getWeeklyPlans(workoutProfileId);
      final domains = models.map((m) => m.toDomain()).toList();
      return Right(domains);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeeklyPlan>> getWeeklyPlanDetails(String weeklyPlanId) async {
    try {
      final model = await _remoteDataSource.getWeeklyPlanDetails(weeklyPlanId);
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeeklyPlan>> activateWeeklyPlan(String weeklyPlanId) async {
    try {
      final model = await _remoteDataSource.activateWeeklyPlan(weeklyPlanId);
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DayPlan>> getDayPlanDetails(String dayPlanId) async {
    try {
      final model = await _remoteDataSource.getDayPlanDetails(dayPlanId);
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DayPlan?>> getTodayPlan(String workoutProfileId) async {
    try {
      final model = await _remoteDataSource.getTodayPlan(workoutProfileId);
      return Right(model?.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DayPlan>> updateDayPlan({
    required String dayPlanId,
    String? label,
    bool? isRestDay,
  }) async {
    try {
      final model = await _remoteDataSource.updateDayPlan(
        dayPlanId: dayPlanId,
        label: label,
        isRestDay: isRestDay,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final model = await _remoteDataSource.createTask(
        dayPlanId: dayPlanId,
        name: name,
        sets: sets,
        reps: reps,
        restSeconds: restSeconds,
        tempo: tempo,
        machineDetails: machineDetails,
        notes: notes,
        sequenceIndex: sequenceIndex,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final model = await _remoteDataSource.updateTask(
        taskId: taskId,
        name: name,
        sets: sets,
        reps: reps,
        restSeconds: restSeconds,
        tempo: tempo,
        machineDetails: machineDetails,
        notes: notes,
        sequenceIndex: sequenceIndex,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ─── Session submission ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, WorkoutSessionLog>> completeSession(
    String workoutProfileId, {
    List<TaskCompletionInput>? taskCompletions,
    String? notes,
  }) async {
    try {
      final model = await _remoteDataSource.completeSession(
        workoutProfileId,
        taskCompletions: taskCompletions,
        notes: notes,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionLog>> skipSession(
    String workoutProfileId, {
    String? reason,
  }) async {
    try {
      final model = await _remoteDataSource.skipSession(
        workoutProfileId,
        reason: reason,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<WorkoutSessionLog> logs, int total, int page, int pageSize})>>
      getSessionLogs(
    String workoutProfileId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getSessionLogs(
        workoutProfileId,
        page: page,
        pageSize: pageSize,
      );
      return Right((
        logs: result.logs.map((m) => m.toDomain()).toList(),
        total: result.total,
        page: result.page,
        pageSize: result.pageSize,
      ));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        const Failure.network(),
      _ => switch (e.response?.statusCode) {
          401 => const Failure.unauthorized(),
          int code => Failure.server(
              statusCode: code,
              message: _parseErrorMessage(e.response?.data?['message']),
            ),
          null => Failure.unknown(message: e.message),
        },
    };
  }

  String _parseErrorMessage(dynamic messageData) {
    if (messageData is List) {
      return messageData.join(', ');
    }
    if (messageData is String) {
      return messageData;
    }
    return 'Server error';
  }
}
