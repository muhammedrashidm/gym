import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../workout/domain/entities/day_plan.dart';
import '../../../workout/domain/entities/task.dart';
import '../../domain/entities/task_completion_entry.dart';
import '../../domain/entities/workout_session_log.dart';

/// Payload for the read-only day-preview route, pushed via `extra:`.
class DayPreviewArgs {
  final DayPlan dayPlan;
  final WorkoutSessionLog? log;
  final bool isUpcoming;
  final String weeklyPlanName;
  final String? clientName;

  const DayPreviewArgs({
    required this.dayPlan,
    required this.log,
    required this.isUpcoming,
    required this.weeklyPlanName,
    this.clientName,
  });
}

enum _TaskMark { done, missed, none }

/// View-only preview of a single day's tasks — no editing, no
/// complete/skip actions. Sourced from a [WorkoutSessionLog] (past day) or
/// nothing at all (upcoming day), never from local drafts.
class DayPreviewPage extends StatelessWidget {
  final DayPreviewArgs args;

  const DayPreviewPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const sinewGreen = Color(0xFF34D399);
    const missedRed = Color(0xFFBA1A1A);
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD);
    final cardBg = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    final outlineColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);
    final bannerBg = isDark ? const Color(0xFF1C1B1B) : const Color(0xFFF0EDEC);

    final dayPlan = args.dayPlan;
    final tasks = dayPlan.tasks;
    final log = args.log;
    final completedIds = {
      for (final e in log?.taskCompletionLogs ?? const <TaskCompletionEntry>[])
        e.taskId,
    };

    _TaskMark markFor(Task task) {
      if (log == null) {
        return args.isUpcoming ? _TaskMark.none : _TaskMark.missed;
      }
      if (log.status == SessionStatus.skipped) return _TaskMark.missed;
      return completedIds.contains(task.id) ? _TaskMark.done : _TaskMark.missed;
    }

    final statusText = _statusLabel(log, args.isUpcoming);
    final statusColor =
        _statusColor(log, args.isUpcoming, sinewGreen, missedRed, textSecondary);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'DAY ${dayPlan.dayIndex}',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          if (args.clientName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: bannerBg,
                border: Border(bottom: BorderSide(color: outlineColor, width: 1)),
              ),
              child: Text(
                'VIEWING ${args.clientName!.toUpperCase()}\'S DAY',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: sinewGreen,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args.weeklyPlanName.isEmpty
                      ? 'PLAN'
                      : args.weeklyPlanName.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day ${dayPlan.dayIndex}  ·  ${dayPlan.label ?? (dayPlan.isRestDay ? 'Rest Day' : 'Workout')}',
                  style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: dayPlan.isRestDay || tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.self_improvement,
                              size: 64, color: textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'REST DAY',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No protocols scheduled this day.',
                            textAlign: TextAlign.center,
                            style:
                                GoogleFonts.inter(fontSize: 13, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final mark = markFor(task);
                      final entry = mark == _TaskMark.done
                          ? log!.taskCompletionLogs
                              .firstWhereOrNull((e) => e.taskId == task.id)
                          : null;
                      return _ReadOnlyTaskRow(
                        task: task,
                        mark: mark,
                        entry: entry,
                        outlineColor: outlineColor,
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        sinewGreen: sinewGreen,
                        missedRed: missedRed,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(WorkoutSessionLog? log, bool isUpcoming) {
    if (log == null) return isUpcoming ? 'UPCOMING' : 'MISSED';
    return switch (log.status) {
      SessionStatus.completed => 'COMPLETED',
      SessionStatus.partial => 'PARTIALLY COMPLETED',
      SessionStatus.skipped => 'SKIPPED',
      SessionStatus.inProgress => 'IN PROGRESS',
    };
  }

  static Color _statusColor(WorkoutSessionLog? log, bool isUpcoming,
      Color green, Color red, Color neutral) {
    if (log == null) return isUpcoming ? neutral : red;
    return switch (log.status) {
      SessionStatus.completed => green,
      SessionStatus.partial => green,
      SessionStatus.skipped => red,
      SessionStatus.inProgress => neutral,
    };
  }
}

class _ReadOnlyTaskRow extends StatelessWidget {
  final Task task;
  final _TaskMark mark;
  final TaskCompletionEntry? entry;
  final Color outlineColor;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color sinewGreen;
  final Color missedRed;

  const _ReadOnlyTaskRow({
    required this.task,
    required this.mark,
    required this.entry,
    required this.outlineColor,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.sinewGreen,
    required this.missedRed,
  });

  @override
  Widget build(BuildContext context) {
    final markColor = switch (mark) {
      _TaskMark.done => sinewGreen,
      _TaskMark.missed => missedRed,
      _TaskMark.none => null,
    };
    final markIcon = switch (mark) {
      _TaskMark.done => Icons.check_circle,
      _TaskMark.missed => Icons.cancel,
      _TaskMark.none => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: outlineColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.name.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      decoration:
                          mark == _TaskMark.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (markIcon != null)
                  Icon(markIcon, color: markColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  label: 'SETS × REPS',
                  value: '${task.sets} × ${task.reps}',
                  outlineColor: outlineColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                if (task.restSeconds != null) ...[
                  const SizedBox(width: 12),
                  _StatChip(
                    label: 'REST',
                    value: '${task.restSeconds}s',
                    outlineColor: outlineColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ],
            ),
            if (mark == _TaskMark.done && entry != null) ...[
              const SizedBox(height: 12),
              Text(
                'Actual: ${entry!.actualSets ?? '-'} sets × ${entry!.actualReps ?? '-'} reps'
                '${entry!.actualWeightKg != null ? ' @ ${entry!.actualWeightKg}kg' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: sinewGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color outlineColor;
  final Color textPrimary;
  final Color textSecondary;

  const _StatChip({
    required this.label,
    required this.value,
    required this.outlineColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: outlineColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 9, fontWeight: FontWeight.w800, color: textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary)),
        ],
      ),
    );
  }
}
