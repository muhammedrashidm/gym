import 'dart:async';
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../staff/domain/entities/client_profile.dart';
import '../../../../staff/domain/usecases/list_staff_clients_query.dart';
import '../../../domain/entities/session_draft.dart';
import '../../../data/datasources/workout_session_local_datasource.dart';
import 'trainer_live_clients_state.dart';

@injectable
class TrainerLiveClientsCubit extends Cubit<TrainerLiveClientsState> {
  final Mediator _mediator;
  final WorkoutSessionLocalDataSource _localDataSource;

  StreamSubscription<List<SessionDraft>>? _draftsSub;
  List<ClientProfile> _roster = [];

  TrainerLiveClientsCubit(this._mediator, this._localDataSource)
      : super(const TrainerLiveClientsState.initial());

  /// Fetch the trainer's assigned client roster, then merge it with local
  /// in-progress-session state (which client is "active" is purely local
  /// device state — see workout-session-update-feature-plan.md §9).
  Future<void> loadClients() async {
    emit(const TrainerLiveClientsState.loading());

    final result = await _mediator.sendCommand(ListStaffClientsQuery())
        as Either<Failure, List<ClientProfile>>;

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      if (!isClosed) emit(TrainerLiveClientsState.error(failure: failure));
      return;
    }

    _roster = result.fold((_) => <ClientProfile>[], (clients) => clients);
    if (isClosed) return;

    await _draftsSub?.cancel();
    _draftsSub =
        _localDataSource.watchAllActiveDrafts().listen(_onDraftsChanged);
  }

  void _onDraftsChanged(List<SessionDraft> drafts) {
    final draftMap = {for (final d in drafts) d.clientProfileId: d};

    final active = <ClientWithSessionStatus>[];
    final idle = <ClientWithSessionStatus>[];

    for (final client in _roster) {
      final draft = draftMap[client.id];
      final status = ClientWithSessionStatus(
        clientProfileId: client.id,
        clientName: client.fullName,
        clientAvatarUrl: client.avatarUrl,
        workoutProfileId: draft?.workoutProfileId,
        activeDraft: draft,
      );

      if (draft != null) {
        active.add(status);
      } else {
        idle.add(status);
      }
    }

    // Sort active by startedAt ascending (oldest session first)
    active.sort(
        (a, b) => (a.activeDraft!.startedAt).compareTo(b.activeDraft!.startedAt));

    if (!isClosed) {
      emit(TrainerLiveClientsState.loaded(
        activeClients: active,
        idleClients: idle,
      ));
    }
  }

  @override
  Future<void> close() {
    _draftsSub?.cancel();
    return super.close();
  }
}
