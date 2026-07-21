import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../exercise_config/domain/entities/exercise_config.dart';
import '../../../task_media/domain/entities/task_attachment.dart';

part 'task.freezed.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String dayPlanId,
    required int sequenceIndex,
    required String name,
    String? description,
    String? machineDetails,
    String? notes,
    required int sets,
    required String reps,
    int? restSeconds,
    String? tempo,
    @Default(<TaskAttachment>[]) List<TaskAttachment> attachments,
    ExerciseConfig? exerciseConfig,
  }) = _Task;
}
