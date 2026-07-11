import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/workout_session_log.dart';

part 'workout_session_log_model.g.dart';

@JsonSerializable()
class WorkoutSessionLogModel {
  final String id;
  final String workoutProfileId;
  final String? weeklyPlanId;
  final String? weeklyPlanName;
  final String? dayPlanId;
  final String? dayPlanLabel;
  final int dayIndexAtTime;
  final int cycleNumberAtTime;
  final String status;
  final String? scheduledDate;
  final String? completedDate;
  final String loggedByRole;
  final String loggedByUserId;
  final int? currentDayIndexAfter;

  const WorkoutSessionLogModel({
    required this.id,
    required this.workoutProfileId,
    this.weeklyPlanId,
    this.weeklyPlanName,
    this.dayPlanId,
    this.dayPlanLabel,
    required this.dayIndexAtTime,
    required this.cycleNumberAtTime,
    required this.status,
    this.scheduledDate,
    this.completedDate,
    required this.loggedByRole,
    required this.loggedByUserId,
    this.currentDayIndexAfter,
  });

  factory WorkoutSessionLogModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSessionLogModelToJson(this);

  WorkoutSessionLog toDomain() {
    return WorkoutSessionLog(
      id: id,
      workoutProfileId: workoutProfileId,
      weeklyPlanId: weeklyPlanId,
      weeklyPlanName: weeklyPlanName,
      dayPlanId: dayPlanId,
      dayPlanLabel: dayPlanLabel,
      dayIndexAtTime: dayIndexAtTime,
      cycleNumberAtTime: cycleNumberAtTime,
      status: _parseStatus(status),
      scheduledDate: scheduledDate,
      completedDate: completedDate,
      loggedByRole: _parseRole(loggedByRole),
      loggedByUserId: loggedByUserId,
      currentDayIndexAfter: currentDayIndexAfter,
    );
  }

  static SessionStatus _parseStatus(String s) => switch (s.toUpperCase()) {
        'COMPLETED' => SessionStatus.completed,
        'SKIPPED' => SessionStatus.skipped,
        _ => SessionStatus.inProgress,
      };

  static LoggedByRole _parseRole(String r) => switch (r.toUpperCase()) {
        'TRAINER' => LoggedByRole.trainer,
        _ => LoggedByRole.member,
      };
}
