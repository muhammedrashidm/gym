import 'dart:async';

import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exercise_config.dart';
import '../../domain/usecases/manage_exercise_config.dart';
import 'exercise_config_picker_state.dart';

typedef _SearchResult = ({List<ExerciseConfig> items, int total, int page, int pageSize});

class ExerciseConfigPickerCubit extends Cubit<ExerciseConfigPickerState> {
  final Mediator _mediator;
  static const _pageSize = 20;

  Timer? _debounce;

  ExerciseConfigPickerCubit(
    this._mediator, {
    ExerciseConfig? preselected,
  }) : super(ExerciseConfigPickerState(selected: preselected));

  /// Initial / explicit search. Pass a [query] to update the search term;
  /// keystroke-driven calls are debounced, an initial no-arg call fires now.
  void search([String? query]) {
    if (query == null) {
      _fetch(reset: true);
      return;
    }
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _fetch(reset: true));
  }

  /// Single-select: replaces any prior selection outright.
  void selectSingle(ExerciseConfig config) {
    emit(state.copyWith(selected: config));
  }

  /// Tapping the already-selected row clears it — confirming "no config" is a
  /// valid outcome, so this is not a dead end.
  void clearSelection() {
    emit(state.copyWith(selected: null));
  }

  void loadMore() {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    if (reset) {
      emit(state.copyWith(isLoading: true, error: null, page: 1));
    } else {
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    final nextPage = reset ? 1 : state.page + 1;

    final result = await _mediator.sendCommand(
      SearchExerciseConfigQuery(
        search: state.query.trim().isEmpty ? null : state.query.trim(),
        page: nextPage,
        pageSize: _pageSize,
      ),
    ) as Either<Failure, _SearchResult>;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: _mapFailure(failure),
      )),
      (data) {
        final items = reset ? data.items : [...state.items, ...data.items];
        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          items: items,
          page: data.page,
          total: data.total,
          error: null,
        ));
      },
    );
  }

  String _mapFailure(Failure failure) => failure.maybeWhen(
        server: (_, msg) => msg,
        network: (msg) => msg ?? 'Network error.',
        unknown: (msg) => msg ?? 'Unknown error.',
        unauthorized: () => 'Unauthorized.',
        orElse: () => 'Unexpected error.',
      );

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
