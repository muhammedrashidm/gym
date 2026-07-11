import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/trainer_connection.dart';

part 'trainer_connection_state.freezed.dart';

@freezed
class TrainerConnectionState with _$TrainerConnectionState {
  const factory TrainerConnectionState.initial() = _Initial;
  const factory TrainerConnectionState.connecting() = _Connecting;
  const factory TrainerConnectionState.connected(TrainerConnection connection) = _Connected;
  const factory TrainerConnectionState.error(String message) = _Error;
}
