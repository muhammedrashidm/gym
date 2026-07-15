import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_media.dart';

abstract interface class TaskMediaRepository {
  /// Search the reusable library. Results always include the caller's own
  /// items plus other trainers' non-private items ([mine] restricts to own).
  Future<Either<Failure, ({List<TaskMedia> items, int total, int page, int pageSize})>> search({
    String? search,
    bool? mine,
    int page,
    int pageSize,
  });

  /// Upload a new library item (multipart). Creates the backing file + a
  /// searchable [TaskMedia]; not attached to any task.
  Future<Either<Failure, TaskMedia>> create({
    required PlatformFile file,
    required String name,
    String? description,
    List<String>? keywords,
    bool isPrivate,
  });
}
