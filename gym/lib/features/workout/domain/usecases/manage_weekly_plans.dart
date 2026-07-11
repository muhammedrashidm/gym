import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/weekly_plan.dart';
import '../value_objects/draft_day_plan.dart';
import '../repositories/workout_repository.dart';

// --- Create Weekly Plan Command (name+notes only, no days) ---
class CreateWeeklyPlanCommand extends ICommand<Future<Either<Failure, WeeklyPlan>>> {
  final String workoutProfileId;
  final String name;
  final String? notes;

   CreateWeeklyPlanCommand({
    required this.workoutProfileId,
    required this.name,
    this.notes,
  });
}

// --- Create Full Weekly Plan Command (with nested days + tasks) ---
class CreateFullWeeklyPlanCommand extends ICommand<Future<Either<Failure, WeeklyPlan>>> {
  final String workoutProfileId;
  final String name;
  final String? notes;
  final bool activateImmediately;
  final List<DraftDayPlan> days;

  CreateFullWeeklyPlanCommand({
    required this.workoutProfileId,
    required this.name,
    this.notes,
    this.activateImmediately = false,
    required this.days,
  });
}

@injectable
class CreateWeeklyPlanCommandHandler
    extends ICommandHandler<CreateWeeklyPlanCommand, Future<Either<Failure, WeeklyPlan>>> {
  final WorkoutRepository _repository;
   CreateWeeklyPlanCommandHandler(this._repository);

  @override
  Future<Either<Failure, WeeklyPlan>> handle(CreateWeeklyPlanCommand command) {
    return _repository.createWeeklyPlan(
      workoutProfileId: command.workoutProfileId,
      name: command.name,
      notes: command.notes,
    );
  }
}

@injectable
class CreateFullWeeklyPlanCommandHandler
    extends ICommandHandler<CreateFullWeeklyPlanCommand, Future<Either<Failure, WeeklyPlan>>> {
  final WorkoutRepository _repository;
  CreateFullWeeklyPlanCommandHandler(this._repository);

  @override
  Future<Either<Failure, WeeklyPlan>> handle(CreateFullWeeklyPlanCommand command) {
    return _repository.createFullWeeklyPlan(
      workoutProfileId: command.workoutProfileId,
      name: command.name,
      notes: command.notes,
      activateImmediately: command.activateImmediately,
      days: command.days,
    );
  }
}

// --- Get Weekly Plans Query ---
class GetWeeklyPlansQuery extends ICommand<Future<Either<Failure, List<WeeklyPlan>>>> {
  final String workoutProfileId;
   GetWeeklyPlansQuery(this.workoutProfileId);
}

@injectable
class GetWeeklyPlansQueryHandler
    extends ICommandHandler<GetWeeklyPlansQuery, Future<Either<Failure, List<WeeklyPlan>>>> {
  final WorkoutRepository _repository;
   GetWeeklyPlansQueryHandler(this._repository);

  @override
  Future<Either<Failure, List<WeeklyPlan>>> handle(GetWeeklyPlansQuery command) {
    return _repository.getWeeklyPlans(command.workoutProfileId);
  }
}

// --- Get Weekly Plan Details Query ---
class GetWeeklyPlanDetailsQuery extends ICommand<Future<Either<Failure, WeeklyPlan>>> {
  final String weeklyPlanId;
   GetWeeklyPlanDetailsQuery(this.weeklyPlanId);
}

@injectable
class GetWeeklyPlanDetailsQueryHandler
    extends ICommandHandler<GetWeeklyPlanDetailsQuery, Future<Either<Failure, WeeklyPlan>>> {
  final WorkoutRepository _repository;
   GetWeeklyPlanDetailsQueryHandler(this._repository);

  @override
  Future<Either<Failure, WeeklyPlan>> handle(GetWeeklyPlanDetailsQuery command) {
    return _repository.getWeeklyPlanDetails(command.weeklyPlanId);
  }
}

// --- Activate Weekly Plan Command ---
class ActivateWeeklyPlanCommand extends ICommand<Future<Either<Failure, WeeklyPlan>>> {
  final String weeklyPlanId;
   ActivateWeeklyPlanCommand(this.weeklyPlanId);
}

@injectable
class ActivateWeeklyPlanCommandHandler
    extends ICommandHandler<ActivateWeeklyPlanCommand, Future<Either<Failure, WeeklyPlan>>> {
  final WorkoutRepository _repository;
   ActivateWeeklyPlanCommandHandler(this._repository);

  @override
  Future<Either<Failure, WeeklyPlan>> handle(ActivateWeeklyPlanCommand command) {
    return _repository.activateWeeklyPlan(command.weeklyPlanId);
  }
}
