import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/trainer_connection.dart';

part 'trainer_connection_model.g.dart';

@JsonSerializable()
class TrainerConnectionModel {
  final String id;
  final String staffProfileId;
  final String clientProfileId;
  final bool isActive;
  final String createdAt;

  const TrainerConnectionModel({
    required this.id,
    required this.staffProfileId,
    required this.clientProfileId,
    required this.isActive,
    required this.createdAt,
  });

  factory TrainerConnectionModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerConnectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerConnectionModelToJson(this);

  TrainerConnection toDomain() => TrainerConnection(
        id: id,
        staffProfileId: staffProfileId,
        clientProfileId: clientProfileId,
        isActive: isActive,
        createdAt: DateTime.parse(createdAt),
      );
}
