import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task_media.dart';

part 'task_media_picker_state.freezed.dart';

@freezed
class TaskMediaPickerState with _$TaskMediaPickerState {
  const TaskMediaPickerState._();

  const factory TaskMediaPickerState({
    @Default('') String query,
    @Default(false) bool mineOnly,
    @Default(<TaskMedia>[]) List<TaskMedia> items,
    // All currently-selected media, keyed by id — persists across searches,
    // pagination, and filter toggles so the final ATTACH list is complete.
    @Default(<String, TaskMedia>{}) Map<String, TaskMedia> selected,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    String? error,
    @Default(1) int page,
    @Default(0) int total,
  }) = _TaskMediaPickerState;

  bool get hasMore => items.length < total;
  int get selectedCount => selected.length;
  bool isSelected(String id) => selected.containsKey(id);
}
