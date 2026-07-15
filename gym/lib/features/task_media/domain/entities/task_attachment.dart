import 'package:freezed_annotation/freezed_annotation.dart';
import 'task_media.dart';

part 'task_attachment.freezed.dart';

/// Links one workout `Task` to one library [TaskMedia], with a per-attachment
/// [caption] and 1-based [sequenceIndex]. Mirrors the backend `TaskAttachment`
/// response shape (see `server/docs/task-media-api.md`).
@freezed
class TaskAttachment with _$TaskAttachment {
  const factory TaskAttachment({
    required String id,
    required String taskId,
    required String taskMediaId,
    String? caption,
    required int sequenceIndex,
    required DateTime createdAt,
    required TaskMedia taskMedia,
  }) = _TaskAttachment;
}
