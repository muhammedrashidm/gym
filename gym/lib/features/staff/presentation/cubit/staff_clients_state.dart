import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client_profile.dart';

part 'staff_clients_state.freezed.dart';

@freezed
class StaffClientsState with _$StaffClientsState {
  const factory StaffClientsState.initial() = _Initial;
  const factory StaffClientsState.loading() = _Loading;
  const factory StaffClientsState.loaded(List<ClientProfile> clients) = _Loaded;
  const factory StaffClientsState.error(String message) = _Error;
}
