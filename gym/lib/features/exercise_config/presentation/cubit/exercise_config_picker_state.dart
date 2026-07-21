import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/exercise_config.dart';

part 'exercise_config_picker_state.freezed.dart';

@freezed
class ExerciseConfigPickerState with _$ExerciseConfigPickerState {
  const ExerciseConfigPickerState._();

  const factory ExerciseConfigPickerState({
    @Default('') String query,
    @Default(<ExerciseConfig>[]) List<ExerciseConfig> items,
    // The single currently-selected config — persists across searches and
    // pagination, and is null when the user has explicitly cleared it.
    ExerciseConfig? selected,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    String? error,
    @Default(1) int page,
    @Default(0) int total,
  }) = _ExerciseConfigPickerState;

  bool get hasMore => items.length < total;
  bool isSelected(String id) => selected?.id == id;
}
