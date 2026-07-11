import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/session_draft.dart';
import '../../../../../core/error/failures.dart';

part 'trainer_live_clients_state.freezed.dart';

class ClientWithSessionStatus {
  final String clientProfileId;
  final String clientName;
  final String? clientAvatarUrl;
  final String? workoutProfileId;
  final SessionDraft? activeDraft;

  const ClientWithSessionStatus({
    required this.clientProfileId,
    required this.clientName,
    this.clientAvatarUrl,
    this.workoutProfileId,
    this.activeDraft,
  });

  bool get hasActiveSession => activeDraft != null;

  int get completedTasks => activeDraft?.taskDrafts.length ?? 0;
}

@freezed
class TrainerLiveClientsState with _$TrainerLiveClientsState {
  const factory TrainerLiveClientsState.initial() = LiveClientsInitial;
  const factory TrainerLiveClientsState.loading() = LiveClientsLoading;
  const factory TrainerLiveClientsState.loaded({
    required List<ClientWithSessionStatus> activeClients,
    required List<ClientWithSessionStatus> idleClients,
  }) = LiveClientsLoaded;
  const factory TrainerLiveClientsState.error({
    required Failure failure,
  }) = LiveClientsError;
}
