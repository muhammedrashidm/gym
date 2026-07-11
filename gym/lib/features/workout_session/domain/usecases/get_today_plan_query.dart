import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../workout/domain/entities/day_plan.dart';
import '../../../workout/domain/repositories/workout_repository.dart';

/// Resolves the given profile's current-cursor DayPlan. Identical for both
/// the member and trainer flows (no role-specific behavior), so it's shared
/// rather than duplicated per role like the complete/skip/logs commands.
class GetTodayPlanQuery extends ICommand<Future<Either<Failure, DayPlan?>>> {
  GetTodayPlanQuery(this.workoutProfileId);
  final String workoutProfileId;
}

@injectable
class GetTodayPlanQueryHandler
    extends ICommandHandler<GetTodayPlanQuery, Future<Either<Failure, DayPlan?>>> {
  final WorkoutRepository _repository;
  GetTodayPlanQueryHandler(this._repository);

  @override
  Future<Either<Failure, DayPlan?>> handle(GetTodayPlanQuery command) {
    return _repository.getTodayPlan(command.workoutProfileId);
  }
}
