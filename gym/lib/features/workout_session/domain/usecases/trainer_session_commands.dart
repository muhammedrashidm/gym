import 'package:collection/collection.dart';
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../workout/domain/entities/workout_profile.dart';
import '../../../workout/domain/repositories/workout_repository.dart';
import '../entities/workout_session_log.dart';
import '../entities/task_completion_draft.dart';
import '../entities/session_draft.dart';
import '../../data/datasources/workout_session_local_datasource.dart';

// ─── Get Workout Profile for a specific client ───────────────────────────────

class GetClientWorkoutProfileQuery
    extends ICommand<Future<Either<Failure, WorkoutProfile?>>> {
  final String clientProfileId;
  GetClientWorkoutProfileQuery(this.clientProfileId);
}

@injectable
class GetClientWorkoutProfileQueryHandler extends ICommandHandler<
    GetClientWorkoutProfileQuery, Future<Either<Failure, WorkoutProfile?>>> {
  final WorkoutRepository _repository;
  GetClientWorkoutProfileQueryHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutProfile?>> handle(
    GetClientWorkoutProfileQuery command,
  ) async {
    final result =
        await _repository.getWorkoutProfiles(command.clientProfileId);
    return result.map(
      (profiles) => profiles.where((p) => p.isActive).firstOrNull,
    );
  }
}

// ─── Complete Client Session (trainer on behalf of client) ───────────────────

class CompleteClientWorkoutSessionCommand
    extends ICommand<Future<Either<Failure, WorkoutSessionLog>>> {
  final String clientProfileId; // for guard check
  final String workoutProfileId;
  final List<TaskCompletionInput>? taskCompletions;
  final String? notes;

  CompleteClientWorkoutSessionCommand({
    required this.clientProfileId,
    required this.workoutProfileId,
    this.taskCompletions,
    this.notes,
  });
}

@injectable
class CompleteClientWorkoutSessionCommandHandler extends ICommandHandler<
    CompleteClientWorkoutSessionCommand,
    Future<Either<Failure, WorkoutSessionLog>>> {
  final WorkoutRepository _repository;
  CompleteClientWorkoutSessionCommandHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutSessionLog>> handle(
    CompleteClientWorkoutSessionCommand command,
  ) {
    return _repository.completeSession(
      command.workoutProfileId,
      taskCompletions: command.taskCompletions,
      notes: command.notes,
    );
  }
}

// ─── Skip Client Session ──────────────────────────────────────────────────────

class SkipClientWorkoutSessionCommand
    extends ICommand<Future<Either<Failure, WorkoutSessionLog>>> {
  final String clientProfileId;
  final String workoutProfileId;
  final String? reason;

  SkipClientWorkoutSessionCommand({
    required this.clientProfileId,
    required this.workoutProfileId,
    this.reason,
  });
}

@injectable
class SkipClientWorkoutSessionCommandHandler extends ICommandHandler<
    SkipClientWorkoutSessionCommand,
    Future<Either<Failure, WorkoutSessionLog>>> {
  final WorkoutRepository _repository;
  SkipClientWorkoutSessionCommandHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutSessionLog>> handle(
    SkipClientWorkoutSessionCommand command,
  ) {
    return _repository.skipSession(
      command.workoutProfileId,
      reason: command.reason,
    );
  }
}

// ─── Get Client Session Logs ──────────────────────────────────────────────────

class GetClientWorkoutSessionLogsQuery extends ICommand<
    Future<
        Either<
            Failure,
            ({
              List<WorkoutSessionLog> logs,
              int total,
              int page,
              int pageSize,
            })>>> {
  final String clientProfileId;
  final String workoutProfileId;
  final int page;
  final int pageSize;

  GetClientWorkoutSessionLogsQuery({
    required this.clientProfileId,
    required this.workoutProfileId,
    this.page = 1,
    this.pageSize = 20,
  });
}

@injectable
class GetClientWorkoutSessionLogsQueryHandler extends ICommandHandler<
    GetClientWorkoutSessionLogsQuery,
    Future<
        Either<
            Failure,
            ({
              List<WorkoutSessionLog> logs,
              int total,
              int page,
              int pageSize,
            })>>> {
  final WorkoutRepository _repository;
  GetClientWorkoutSessionLogsQueryHandler(this._repository);

  @override
  Future<
      Either<
          Failure,
          ({
            List<WorkoutSessionLog> logs,
            int total,
            int page,
            int pageSize,
          })>> handle(GetClientWorkoutSessionLogsQuery command) {
    return _repository.getSessionLogs(
      command.workoutProfileId,
      page: command.page,
      pageSize: command.pageSize,
    );
  }
}

// ─── Get All Active Trainer Drafts (local only) ───────────────────────────────

class GetTrainerActiveClientDraftsQuery
    extends ICommand<Stream<List<SessionDraft>>> {}

@injectable
class GetTrainerActiveClientDraftsQueryHandler extends ICommandHandler<
    GetTrainerActiveClientDraftsQuery, Stream<List<SessionDraft>>> {
  final WorkoutSessionLocalDataSource _localDataSource;
  GetTrainerActiveClientDraftsQueryHandler(this._localDataSource);

  @override
  Stream<List<SessionDraft>> handle(
    GetTrainerActiveClientDraftsQuery command,
  ) {
    return _localDataSource.watchAllActiveDrafts();
  }
}
