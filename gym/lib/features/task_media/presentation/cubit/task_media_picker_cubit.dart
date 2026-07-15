import 'dart:async';

import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_media.dart';
import '../../domain/usecases/manage_task_media.dart';
import 'task_media_picker_state.dart';

typedef _SearchResult = ({List<TaskMedia> items, int total, int page, int pageSize});

class TaskMediaPickerCubit extends Cubit<TaskMediaPickerState> {
  final Mediator _mediator;
  static const _pageSize = 20;

  Timer? _debounce;

  TaskMediaPickerCubit(
    this._mediator, {
    List<TaskMedia> preselected = const [],
  }) : super(TaskMediaPickerState(
          selected: {for (final m in preselected) m.id: m},
        ));

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

  void toggleMineOnly() {
    emit(state.copyWith(mineOnly: !state.mineOnly));
    _fetch(reset: true);
  }

  void toggleSelect(TaskMedia media) {
    final next = Map<String, TaskMedia>.from(state.selected);
    if (next.containsKey(media.id)) {
      next.remove(media.id);
    } else {
      next[media.id] = media;
    }
    emit(state.copyWith(selected: next));
  }

  void loadMore() {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    _fetch(reset: false);
  }

  /// Called after a successful upload from the Add-Media screen: prepends the
  /// new item to the visible list and auto-selects it, without a re-fetch.
  void addLocallyCreated(TaskMedia media) {
    final items = [media, ...state.items.where((m) => m.id != media.id)];
    final selected = Map<String, TaskMedia>.from(state.selected)..[media.id] = media;
    emit(state.copyWith(
      items: items,
      selected: selected,
      total: state.total + 1,
    ));
  }

  Future<void> _fetch({required bool reset}) async {
    if (reset) {
      emit(state.copyWith(isLoading: true, error: null, page: 1));
    } else {
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    final nextPage = reset ? 1 : state.page + 1;

    final result = await _mediator.sendCommand(
      SearchTaskMediaQuery(
        search: state.query.trim().isEmpty ? null : state.query.trim(),
        mine: state.mineOnly ? true : null,
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
