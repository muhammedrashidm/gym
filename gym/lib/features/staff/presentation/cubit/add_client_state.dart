import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client_profile.dart';

part 'add_client_state.freezed.dart';

@freezed
class AddClientState with _$AddClientState {
  const factory AddClientState.initial() = _Initial;
  const factory AddClientState.submitting() = _Submitting;
  const factory AddClientState.success(ClientProfile profile) = _Success;
  const factory AddClientState.error(String message) = _Error;
}
