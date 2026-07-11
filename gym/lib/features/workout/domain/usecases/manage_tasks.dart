import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/workout_repository.dart';

// --- Create Task Command ---
class CreateTaskCommand extends ICommand<Future<Either<Failure, Task>>> {
  final String dayPlanId;
  final String name;
  final int sets;
  final String reps;
  final int? restSeconds;
  final String? tempo;
  final String? machineDetails;
  final String? notes;
  final int sequenceIndex;

   CreateTaskCommand({
    required this.dayPlanId,
    required this.name,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.tempo,
    this.machineDetails,
    this.notes,
    required this.sequenceIndex,
  });
}

@injectable
class CreateTaskCommandHandler
    extends ICommandHandler<CreateTaskCommand, Future<Either<Failure, Task>>> {
  final WorkoutRepository _repository;
   CreateTaskCommandHandler(this._repository);

  @override
  Future<Either<Failure, Task>> handle(CreateTaskCommand command) {
    return _repository.createTask(
      dayPlanId: command.dayPlanId,
      name: command.name,
      sets: command.sets,
      reps: command.reps,
      restSeconds: command.restSeconds,
      tempo: command.tempo,
      machineDetails: command.machineDetails,
      notes: command.notes,
      sequenceIndex: command.sequenceIndex,
    );
  }
}

// --- Update Task Command ---
class UpdateTaskCommand extends ICommand<Future<Either<Failure, Task>>> {
  final String taskId;
  final String? name;
  final int? sets;
  final String? reps;
  final int? restSeconds;
  final String? tempo;
  final String? machineDetails;
  final String? notes;
  final int? sequenceIndex;

   UpdateTaskCommand({
    required this.taskId,
    this.name,
    this.sets,
    this.reps,
    this.restSeconds,
    this.tempo,
    this.machineDetails,
    this.notes,
    this.sequenceIndex,
  });
}

@injectable
class UpdateTaskCommandHandler
    extends ICommandHandler<UpdateTaskCommand, Future<Either<Failure, Task>>> {
  final WorkoutRepository _repository;
   UpdateTaskCommandHandler(this._repository);

  @override
  Future<Either<Failure, Task>> handle(UpdateTaskCommand command) {
    return _repository.updateTask(
      taskId: command.taskId,
      name: command.name,
      sets: command.sets,
      reps: command.reps,
      restSeconds: command.restSeconds,
      tempo: command.tempo,
      machineDetails: command.machineDetails,
      notes: command.notes,
      sequenceIndex: command.sequenceIndex,
    );
  }
}

// --- Delete Task Command ---
class DeleteTaskCommand extends ICommand<Future<Either<Failure, Unit>>> {
  final String taskId;
   DeleteTaskCommand(this.taskId);
}

@injectable
class DeleteTaskCommandHandler
    extends ICommandHandler<DeleteTaskCommand, Future<Either<Failure, Unit>>> {
  final WorkoutRepository _repository;
   DeleteTaskCommandHandler(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteTaskCommand command) {
    return _repository.deleteTask(command.taskId);
  }
}
