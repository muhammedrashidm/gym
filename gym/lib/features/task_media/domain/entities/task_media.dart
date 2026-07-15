import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_media.freezed.dart';

/// A reusable, searchable library item wrapping exactly one uploaded file
/// (image / gif / video) plus metadata. Mirrors the backend `TaskMedia`
/// response shape (see `server/docs/task-media-api.md`).
///
/// [url] is resolved fresh on every read (short-lived signed URL under the
/// protected S3 driver) — never persist it.
@freezed
class TaskMedia with _$TaskMedia {
  const factory TaskMedia({
    required String id,
    // "IMAGE" | "GIF" | "VIDEO"
    required String type,
    required String name,
    String? description,
    @Default(<String>[]) List<String> keywords,
    @Default(false) bool isPrivate,
    required String createdById,
    required String url,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskMedia;
}
