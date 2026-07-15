import 'dart:math';
import 'entities/workout_session_log.dart';

/// Per-dayIndex log state for the weekly plan's still-in-progress 7-day
/// cycle, plus which day is active next.
class WeekProgress {
  final Map<int, WorkoutSessionLog> dayLogs;
  final int activeDayIndex;

  const WeekProgress({required this.dayLogs, required this.activeDayIndex});

  Map<int, SessionStatus> get weekDayStatus =>
      dayLogs.map((k, v) => MapEntry(k, v.status));
}

/// Walks a client's session-log history for the active weekly plan to
/// determine (a) which days in the still-in-progress cycle were logged
/// (and the log itself, for per-task detail), and (b) which day is
/// "active" next. This mirrors the server's own state machine
/// (workout-session.service.ts): only a completion advances the day (with
/// wraparound 7 -> 1); a skip leaves the same day active until it is
/// eventually completed. Grouping by `cycleNumberAtTime` is deliberately
/// avoided — the completion that wraps day 7 shares that field's value
/// with the next cycle's early days, so it can't be used to split cycles
/// reliably.
WeekProgress computeWeekProgress(
  List<WorkoutSessionLog> logs,
  String activeWeeklyPlanId,
) {
  final matching =
      logs.where((l) => l.weeklyPlanId == activeWeeklyPlanId).toList();
  if (matching.isEmpty) {
    return const WeekProgress(dayLogs: {}, activeDayIndex: 1);
  }

  // Logs are ordered completedDate desc from the server. If the most
  // recent action was the completion that wrapped day 7 -> 1, the
  // current cycle hasn't logged anything yet.
  final mostRecent = matching.first;
  if (mostRecent.status == SessionStatus.completed &&
      mostRecent.dayIndexAtTime == 7) {
    return const WeekProgress(dayLogs: {}, activeDayIndex: 1);
  }

  // Walk backward from the most recent log, collecting everything that
  // belongs to the still-in-progress cycle. A completed day-7 log marks
  // where the previous cycle ended -- stop there (exclusive).
  final currentCycleLogs = <WorkoutSessionLog>[];
  for (final log in matching) {
    if (log.status == SessionStatus.completed && log.dayIndexAtTime == 7) {
      break;
    }
    currentCycleLogs.add(log);
  }

  final dayLogs = <int, WorkoutSessionLog>{};
  for (final log in currentCycleLogs) {
    // Most recent action per day wins.
    dayLogs.putIfAbsent(log.dayIndexAtTime, () => log);
  }

  // Only completions advance the active day -- a skip leaves the
  // server's currentDayIndex unchanged.
  final completedIndices = currentCycleLogs
      .where((l) => l.status == SessionStatus.completed)
      .map((l) => l.dayIndexAtTime);
  final activeDayIndex =
      completedIndices.isEmpty ? 1 : (completedIndices.reduce(max) % 7) + 1;

  return WeekProgress(dayLogs: dayLogs, activeDayIndex: activeDayIndex);
}
