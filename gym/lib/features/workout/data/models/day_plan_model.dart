import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/day_plan.dart';
import 'task_model.dart';

part 'day_plan_model.g.dart';

@JsonSerializable()
class DayPlanModel {
  final String id;
  final String weeklyPlanId;
  final int dayIndex;
  final String? label;
  final bool isRestDay;
  final List<TaskModel> tasks;

  const DayPlanModel({
    required this.id,
    required this.weeklyPlanId,
    required this.dayIndex,
    this.label,
    required this.isRestDay,
    this.tasks = const [],
  });

  factory DayPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DayPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$DayPlanModelToJson(this);

  DayPlan toDomain() {
    return DayPlan(
      id: id,
      weeklyPlanId: weeklyPlanId,
      dayIndex: dayIndex,
      label: label,
      isRestDay: isRestDay,
      tasks: tasks.map((t) => t.toDomain()).toList(),
    );
  }
}
