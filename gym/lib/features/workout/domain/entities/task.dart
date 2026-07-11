import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String dayPlanId,
    required int sequenceIndex,
    required String name,
    String? description,
    String? machineDetails,
    String? notes,
    required int sets,
    required String reps,
    int? restSeconds,
    String? tempo,
  }) = _Task;
}
