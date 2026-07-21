import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise_config.dart';

abstract interface class ExerciseConfigRepository {
  /// Search the admin-curated config library. Configs have no ownership or
  /// privacy concept — every active config is visible to every trainer.
  Future<Either<Failure, ({List<ExerciseConfig> items, int total, int page, int pageSize})>> search({
    String? search,
    String? analyzerType,
    int page,
    int pageSize,
  });
}
