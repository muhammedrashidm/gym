import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise_config.dart';
import '../repositories/exercise_config_repository.dart';

// --- Search Exercise Config Query ---
class SearchExerciseConfigQuery
    extends ICommand<Future<Either<Failure, ({List<ExerciseConfig> items, int total, int page, int pageSize})>>> {
  final String? search;
  final String? analyzerType;
  final int page;
  final int pageSize;

  SearchExerciseConfigQuery({
    this.search,
    this.analyzerType,
    this.page = 1,
    this.pageSize = 20,
  });
}

@injectable
class SearchExerciseConfigQueryHandler extends ICommandHandler<SearchExerciseConfigQuery,
    Future<Either<Failure, ({List<ExerciseConfig> items, int total, int page, int pageSize})>>> {
  final ExerciseConfigRepository _repository;
  SearchExerciseConfigQueryHandler(this._repository);

  @override
  Future<Either<Failure, ({List<ExerciseConfig> items, int total, int page, int pageSize})>> handle(
    SearchExerciseConfigQuery command,
  ) {
    return _repository.search(
      search: command.search,
      analyzerType: command.analyzerType,
      page: command.page,
      pageSize: command.pageSize,
    );
  }
}
