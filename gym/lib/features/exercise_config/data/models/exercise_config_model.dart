import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/exercise_config.dart';

part 'exercise_config_model.g.dart';

@JsonSerializable()
class ExerciseConfigModel {
  final String id;
  final String name;
  final String? description;
  final String analyzerType;
  final Map<String, dynamic>? aiConfigJson;
  @JsonKey(defaultValue: <String>[])
  final List<String> keywords;
  final String mediaUrl;

  const ExerciseConfigModel({
    required this.id,
    required this.name,
    this.description,
    this.aiConfigJson,
    required this.analyzerType,
    this.keywords = const [],
    required this.mediaUrl,
  });

  factory ExerciseConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseConfigModelToJson(this);

  ExerciseConfig toDomain() {
    return ExerciseConfig(
      id: id,
      name: name,
      description: description,
      analyzerType: analyzerType,
      keywords: keywords,
      mediaUrl: mediaUrl,
      aiConfigJson: aiConfigJson ?? {},
    );
  }
}
