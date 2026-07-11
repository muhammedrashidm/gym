import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qr_token.dart';
import '../../domain/usecases/get_qr_token_query.dart';
import 'staff_qr_state.dart';

class StaffQrCubit extends Cubit<StaffQrState> {
  final Mediator _mediator;

  StaffQrCubit(this._mediator) : super(const StaffQrState.initial());

  Future<void> generateQrToken() async {
    emit(const StaffQrState.loading());
    final result = await _mediator.sendCommand(GetQrTokenQuery())
        as Either<Failure, QrToken>;
    result.fold(
      (failure) {
        final message = failure.maybeWhen(
          server: (_, msg) => msg,
          network: (msg) => msg ?? 'Network error.',
          unknown: (msg) => msg ?? 'Unknown error.',
          unauthorized: () => 'Unauthorized.',
          orElse: () => 'Unexpected error.',
        );
        emit(StaffQrState.error(message));
      },
      (token) => emit(StaffQrState.loaded(token)),
    );
  }
}

