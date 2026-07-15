import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_media.dart';

part 'task_media_model.g.dart';

@JsonSerializable()
class TaskMediaModel {
  final String id;
  final String type;
  final String name;
  final String? description;
  @JsonKey(defaultValue: <String>[])
  final List<String> keywords;
  final bool isPrivate;
  final String createdById;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskMediaModel({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.keywords = const [],
    this.isPrivate = false,
    required this.createdById,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskMediaModel.fromJson(Map<String, dynamic> json) =>
      _$TaskMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskMediaModelToJson(this);

  TaskMedia toDomain() {
    return TaskMedia(
      id: id,
      type: type,
      name: name,
      description: description,
      keywords: keywords,
      isPrivate: isPrivate,
      createdById: createdById,
      url: url,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
