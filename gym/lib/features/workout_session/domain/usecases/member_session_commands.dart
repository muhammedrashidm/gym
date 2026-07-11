import 'package:collection/collection.dart';
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../workout/domain/entities/workout_profile.dart';
import '../../../workout/domain/repositories/workout_repository.dart';
import '../entities/workout_session_log.dart';
import '../entities/task_completion_draft.dart';

// ─── Get Active Workout Profile (member's own) ───────────────────────────────

class GetMemberActiveProfileQuery
    extends ICommand<Future<Either<Failure, WorkoutProfile?>>> {
  /// Null resolves to the caller's own profile — see
  /// [WorkoutRepository.getWorkoutProfiles].
  GetMemberActiveProfileQuery([this.clientProfileId]);
  final String? clientProfileId;
}

@injectable
class GetMemberActiveProfileQueryHandler extends ICommandHandler<
    GetMemberActiveProfileQuery, Future<Either<Failure, WorkoutProfile?>>> {
  final WorkoutRepository _repository;
  GetMemberActiveProfileQueryHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutProfile?>> handle(
    GetMemberActiveProfileQuery command,
  ) async {
    final result =
        await _repository.getWorkoutProfiles(command.clientProfileId);
    return result.map(
      (profiles) => profiles.where((p) => p.isActive).firstOrNull,
    );
  }
}

// ─── Complete Member Session ──────────────────────────────────────────────────

class CompleteMemberWorkoutSessionCommand
    extends ICommand<Future<Either<Failure, WorkoutSessionLog>>> {
  final String workoutProfileId;
  final List<TaskCompletionInput>? taskCompletions;
  final String? notes;

  CompleteMemberWorkoutSessionCommand({
    required this.workoutProfileId,
    this.taskCompletions,
    this.notes,
  });
}

@injectable
class CompleteMemberWorkoutSessionCommandHandler extends ICommandHandler<
    CompleteMemberWorkoutSessionCommand,
    Future<Either<Failure, WorkoutSessionLog>>> {
  final WorkoutRepository _repository;
  CompleteMemberWorkoutSessionCommandHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutSessionLog>> handle(
    CompleteMemberWorkoutSessionCommand command,
  ) {
    return _repository.completeSession(
      command.workoutProfileId,
      taskCompletions: command.taskCompletions,
      notes: command.notes,
    );
  }
}

// ─── Skip Member Session ──────────────────────────────────────────────────────

class SkipMemberWorkoutSessionCommand
    extends ICommand<Future<Either<Failure, WorkoutSessionLog>>> {
  final String workoutProfileId;
  final String? reason;

  SkipMemberWorkoutSessionCommand({
    required this.workoutProfileId,
    this.reason,
  });
}

@injectable
class SkipMemberWorkoutSessionCommandHandler extends ICommandHandler<
    SkipMemberWorkoutSessionCommand,
    Future<Either<Failure, WorkoutSessionLog>>> {
  final WorkoutRepository _repository;
  SkipMemberWorkoutSessionCommandHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutSessionLog>> handle(
    SkipMemberWorkoutSessionCommand command,
  ) {
    return _repository.skipSession(
      command.workoutProfileId,
      reason: command.reason,
    );
  }
}

// ─── Get Member Session Logs ──────────────────────────────────────────────────

class GetMemberWorkoutSessionLogsQuery extends ICommand<
    Future<
        Either<
            Failure,
            ({
              List<WorkoutSessionLog> logs,
              int total,
              int page,
              int pageSize,
            })>>> {
  final String workoutProfileId;
  final int page;
  final int pageSize;

  GetMemberWorkoutSessionLogsQuery({
    required this.workoutProfileId,
    this.page = 1,
    this.pageSize = 20,
  });
}

@injectable
class GetMemberWorkoutSessionLogsQueryHandler extends ICommandHandler<
    GetMemberWorkoutSessionLogsQuery,
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
  GetMemberWorkoutSessionLogsQueryHandler(this._repository);

  @override
  Future<
      Either<
          Failure,
          ({
            List<WorkoutSessionLog> logs,
            int total,
            int page,
            int pageSize,
          })>> handle(GetMemberWorkoutSessionLogsQuery command) {
    return _repository.getSessionLogs(
      command.workoutProfileId,
      page: command.page,
      pageSize: command.pageSize,
    );
  }
}
