import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/workout_profile.dart';
import '../repositories/workout_repository.dart';

// --- Get Workout Profiles Query ---
class GetWorkoutProfilesQuery extends ICommand<Future<Either<Failure, List<WorkoutProfile>>>> {
  final String clientProfileId;
   GetWorkoutProfilesQuery(this.clientProfileId);
}

@injectable
class GetWorkoutProfilesQueryHandler
    extends ICommandHandler<GetWorkoutProfilesQuery, Future<Either<Failure, List<WorkoutProfile>>>> {
  final WorkoutRepository _repository;
   GetWorkoutProfilesQueryHandler(this._repository);

  @override
  Future<Either<Failure, List<WorkoutProfile>>> handle(GetWorkoutProfilesQuery command) {
    return _repository.getWorkoutProfiles(command.clientProfileId);
  }
}

// --- Create Workout Profile Command ---
class CreateWorkoutProfileCommand extends ICommand<Future<Either<Failure, WorkoutProfile>>> {
  final String clientProfileId;
  final String name;
  final String startDate;

   CreateWorkoutProfileCommand({
    required this.clientProfileId,
    required this.name,
    required this.startDate,
  });
}

@injectable
class CreateWorkoutProfileCommandHandler
    extends ICommandHandler<CreateWorkoutProfileCommand, Future<Either<Failure, WorkoutProfile>>> {
  final WorkoutRepository _repository;
   CreateWorkoutProfileCommandHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutProfile>> handle(CreateWorkoutProfileCommand command) {
    return _repository.createWorkoutProfile(
      clientProfileId: command.clientProfileId,
      name: command.name,
      startDate: command.startDate,
    );
  }
}

// --- Update Workout Profile Command ---
class UpdateWorkoutProfileCommand extends ICommand<Future<Either<Failure, WorkoutProfile>>> {
  final String id;
  final bool? isActive;
  final int? currentDayIndex;

   UpdateWorkoutProfileCommand({
    required this.id,
    this.isActive,
    this.currentDayIndex,
  });
}

@injectable
class UpdateWorkoutProfileCommandHandler
    extends ICommandHandler<UpdateWorkoutProfileCommand, Future<Either<Failure, WorkoutProfile>>> {
  final WorkoutRepository _repository;
   UpdateWorkoutProfileCommandHandler(this._repository);

  @override
  Future<Either<Failure, WorkoutProfile>> handle(UpdateWorkoutProfileCommand command) {
    return _repository.updateWorkoutProfile(
      id: command.id,
      isActive: command.isActive,
      currentDayIndex: command.currentDayIndex,
    );
  }
}
