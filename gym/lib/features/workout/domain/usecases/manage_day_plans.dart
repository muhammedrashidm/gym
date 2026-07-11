import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/day_plan.dart';
import '../repositories/workout_repository.dart';

// --- Get Day Plan Details Query ---
class GetDayPlanDetailsQuery extends ICommand<Future<Either<Failure, DayPlan>>> {
  final String dayPlanId;
   GetDayPlanDetailsQuery(this.dayPlanId);
}

@injectable
class GetDayPlanDetailsQueryHandler
    extends ICommandHandler<GetDayPlanDetailsQuery, Future<Either<Failure, DayPlan>>> {
  final WorkoutRepository _repository;
   GetDayPlanDetailsQueryHandler(this._repository);

  @override
  Future<Either<Failure, DayPlan>> handle(GetDayPlanDetailsQuery command) {
    return _repository.getDayPlanDetails(command.dayPlanId);
  }
}

// --- Update Day Plan Command ---
class UpdateDayPlanCommand extends ICommand<Future<Either<Failure, DayPlan>>> {
  final String dayPlanId;
  final String? label;
  final bool? isRestDay;

   UpdateDayPlanCommand({
    required this.dayPlanId,
    this.label,
    this.isRestDay,
  });
}

@injectable
class UpdateDayPlanCommandHandler
    extends ICommandHandler<UpdateDayPlanCommand, Future<Either<Failure, DayPlan>>> {
  final WorkoutRepository _repository;
   UpdateDayPlanCommandHandler(this._repository);

  @override
  Future<Either<Failure, DayPlan>> handle(UpdateDayPlanCommand command) {
    return _repository.updateDayPlan(
      dayPlanId: command.dayPlanId,
      label: command.label,
      isRestDay: command.isRestDay,
    );
  }
}
