import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/usecases/list_staff_clients_query.dart';
import 'staff_clients_state.dart';

class StaffClientsCubit extends Cubit<StaffClientsState> {
  final Mediator _mediator;

  StaffClientsCubit(this._mediator) : super(const StaffClientsState.initial());

  Future<void> loadClients() async {
    emit(const StaffClientsState.loading());
    final result = await _mediator.sendCommand(ListStaffClientsQuery())
        as Either<Failure, List<ClientProfile>>;
    result.fold(
      (failure) {
        final message = failure.maybeWhen(
          server: (_, msg) => msg,
          network: (msg) => msg ?? 'Network error.',
          unknown: (msg) => msg ?? 'Unknown error.',
          unauthorized: () => 'Unauthorized.',
          orElse: () => 'Unexpected error.',
        );
        emit(StaffClientsState.error(message));
      },
      (clients) => emit(StaffClientsState.loaded(clients)),
    );
  }
}
