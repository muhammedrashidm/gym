import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_media.dart';
import '../repositories/task_media_repository.dart';

// --- Search Task Media Query ---
class SearchTaskMediaQuery
    extends ICommand<Future<Either<Failure, ({List<TaskMedia> items, int total, int page, int pageSize})>>> {
  final String? search;
  final bool? mine;
  final int page;
  final int pageSize;

  SearchTaskMediaQuery({
    this.search,
    this.mine,
    this.page = 1,
    this.pageSize = 20,
  });
}

@injectable
class SearchTaskMediaQueryHandler extends ICommandHandler<SearchTaskMediaQuery,
    Future<Either<Failure, ({List<TaskMedia> items, int total, int page, int pageSize})>>> {
  final TaskMediaRepository _repository;
  SearchTaskMediaQueryHandler(this._repository);

  @override
  Future<Either<Failure, ({List<TaskMedia> items, int total, int page, int pageSize})>> handle(
    SearchTaskMediaQuery command,
  ) {
    return _repository.search(
      search: command.search,
      mine: command.mine,
      page: command.page,
      pageSize: command.pageSize,
    );
  }
}

// --- Create Task Media Command ---
class CreateTaskMediaCommand extends ICommand<Future<Either<Failure, TaskMedia>>> {
  final PlatformFile file;
  final String name;
  final String? description;
  final List<String>? keywords;
  final bool isPrivate;

  CreateTaskMediaCommand({
    required this.file,
    required this.name,
    this.description,
    this.keywords,
    this.isPrivate = false,
  });
}

@injectable
class CreateTaskMediaCommandHandler
    extends ICommandHandler<CreateTaskMediaCommand, Future<Either<Failure, TaskMedia>>> {
  final TaskMediaRepository _repository;
  CreateTaskMediaCommandHandler(this._repository);

  @override
  Future<Either<Failure, TaskMedia>> handle(CreateTaskMediaCommand command) {
    return _repository.create(
      file: command.file,
      name: command.name,
      description: command.description,
      keywords: command.keywords,
      isPrivate: command.isPrivate,
    );
  }
}
