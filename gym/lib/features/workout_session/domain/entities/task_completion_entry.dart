import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_completion_entry.freezed.dart';

@freezed
class TaskCompletionEntry with _$TaskCompletionEntry {
  const factory TaskCompletionEntry({
    required String taskId,
    int? actualSets,
    String? actualReps,
    double? actualWeightKg,
    String? notes,
  }) = _TaskCompletionEntry;
}
