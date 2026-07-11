import 'draft_task.dart';

class DraftDayPlan {
  final int dayIndex; // 1–7
  final String? label;
  final bool isRestDay;
  final List<DraftTask> tasks;

  const DraftDayPlan({
    required this.dayIndex,
    this.label,
    this.isRestDay = true,
    this.tasks = const [],
  });

  DraftDayPlan copyWith({
    String? label,
    bool? isRestDay,
    List<DraftTask>? tasks,
    bool clearLabel = false,
  }) {
    return DraftDayPlan(
      dayIndex: dayIndex,
      label: clearLabel ? null : (label ?? this.label),
      isRestDay: isRestDay ?? this.isRestDay,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'isRestDay': isRestDay,
        if (label != null && label!.isNotEmpty) 'label': label,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };
}
