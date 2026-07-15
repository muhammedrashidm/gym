import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_attachment.dart';
import 'task_media_model.dart';

part 'task_attachment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TaskAttachmentModel {
  final String id;
  final String taskId;
  final String taskMediaId;
  final String? caption;
  final int sequenceIndex;
  final DateTime createdAt;
  final TaskMediaModel taskMedia;

  const TaskAttachmentModel({
    required this.id,
    required this.taskId,
    required this.taskMediaId,
    this.caption,
    required this.sequenceIndex,
    required this.createdAt,
    required this.taskMedia,
  });

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskAttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskAttachmentModelToJson(this);

  TaskAttachment toDomain() {
    return TaskAttachment(
      id: id,
      taskId: taskId,
      taskMediaId: taskMediaId,
      caption: caption,
      sequenceIndex: sequenceIndex,
      createdAt: createdAt,
      taskMedia: taskMedia.toDomain(),
    );
  }
}
