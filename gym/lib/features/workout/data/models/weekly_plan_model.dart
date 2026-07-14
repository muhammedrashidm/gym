import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/weekly_plan.dart';
import 'day_plan_model.dart';

part 'weekly_plan_model.g.dart';

@JsonSerializable()
class WeeklyPlanModel {
  final String id;
  final String name;
  final String? workoutProfileId;
  final String status;
  final String? notes;
  @JsonKey(name: 'days')
  final List<DayPlanModel> dayPlans;

  const WeeklyPlanModel({
    required this.id,
    required this.name,
     this.workoutProfileId,
    required this.status,
    this.notes,
    this.dayPlans = const [],
  });

  factory WeeklyPlanModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyPlanModelToJson(this);

  WeeklyPlan toDomain() {
    return WeeklyPlan(
      id: id,
      name: name,
      workoutProfileId: workoutProfileId ?? '',
      status: status,
      notes: notes,
      dayPlans: dayPlans.map((d) => d.toDomain()).toList(),
    );
  }
}
