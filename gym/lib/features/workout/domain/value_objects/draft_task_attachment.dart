import '../../../task_media/domain/entities/task_media.dart';

/// A locally-staged attachment on a draft task. Carries the full picked
/// [TaskMedia] for UI rendering (thumbnail, name, type, private badge), plus
/// the per-attachment [caption] and 1-based [sequenceIndex].
///
/// [toJson] emits **only** `{taskMediaId, caption?, sequenceIndex}` — matching
/// the backend's `TaskAttachmentInputDto` (see `server/docs/task-media-api.md`
/// §7). The media itself already exists in the library; the weekly-plan
/// endpoint only references it by id.
class DraftTaskAttachment {
  final TaskMedia media;
  final String? caption;
  final int sequenceIndex;

  const DraftTaskAttachment({
    required this.media,
    this.caption,
    required this.sequenceIndex,
  });

  String get taskMediaId => media.id;

  DraftTaskAttachment copyWith({
    TaskMedia? media,
    String? caption,
    int? sequenceIndex,
    bool clearCaption = false,
  }) {
    return DraftTaskAttachment(
      media: media ?? this.media,
      caption: clearCaption ? null : (caption ?? this.caption),
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'taskMediaId': media.id,
        if (caption != null && caption!.isNotEmpty) 'caption': caption,
        'sequenceIndex': sequenceIndex,
      };
}
