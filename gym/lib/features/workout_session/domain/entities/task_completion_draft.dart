import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_completion_draft.freezed.dart';

@freezed
class TaskCompletionDraft with _$TaskCompletionDraft {
  const factory TaskCompletionDraft({
    required String id,
    required String workoutProfileId,
    required String taskId,
    int? actualSets,
    String? actualReps,
    double? actualWeightKg,
    String? notes,
    DateTime? updatedAt,
  }) = _TaskCompletionDraft;
}

/// Input shape sent to the server on session completion.
class TaskCompletionInput {
  final String taskId;
  final int? actualSets;
  final String? actualReps;
  final double? actualWeightKg;
  final String? notes;

  const TaskCompletionInput({
    required this.taskId,
    this.actualSets,
    this.actualReps,
    this.actualWeightKg,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        if (actualSets != null) 'actualSets': actualSets,
        if (actualReps != null) 'actualReps': actualReps,
        if (actualWeightKg != null) 'actualWeightKg': actualWeightKg,
        if (notes != null) 'notes': notes,
      };
}
