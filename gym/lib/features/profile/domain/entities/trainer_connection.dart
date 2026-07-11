import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_connection.freezed.dart';
part 'trainer_connection.g.dart';

@freezed
class TrainerConnection with _$TrainerConnection {
  const factory TrainerConnection({
    required String id,
    required String staffProfileId,
    required String clientProfileId,
    required bool isActive,
    required DateTime createdAt,
  }) = _TrainerConnection;

  factory TrainerConnection.fromJson(Map<String, dynamic> json) =>
      _$TrainerConnectionFromJson(json);
}
