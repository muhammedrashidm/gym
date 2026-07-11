import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  final String dayPlanId;
  final int sequenceIndex;
  final String name;
  final String? description;
  final String? machineDetails;
  final String? notes;
  final int sets;
  final String reps;
  final int? restSeconds;
  final String? tempo;

  const TaskModel({
    required this.id,
    required this.dayPlanId,
    required this.sequenceIndex,
    required this.name,
    this.description,
    this.machineDetails,
    this.notes,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.tempo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  Task toDomain() {
    return Task(
      id: id,
      dayPlanId: dayPlanId,
      sequenceIndex: sequenceIndex,
      name: name,
      description: description,
      machineDetails: machineDetails,
      notes: notes,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      tempo: tempo,
    );
  }
}
