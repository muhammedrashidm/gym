import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/trainer_client_session/trainer_client_session_cubit.dart';
import '../cubit/trainer_client_session/trainer_client_session_state.dart';
import '../../../workout/domain/entities/task.dart';
import '../../../workout/domain/entities/weekly_plan.dart';
import '../../domain/entities/workout_session_log.dart';
import 'day_preview_page.dart';

class TrainerClientSessionPage extends StatefulWidget {
  final String clientId;
  final String clientName;

  const TrainerClientSessionPage({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<TrainerClientSessionPage> createState() =>
      _TrainerClientSessionPageState();
}

class _TrainerClientSessionPageState extends State<TrainerClientSessionPage> {
  @override
  void initState() {
    super.initState();
    context.read<TrainerClientSessionCubit>().loadSession(
          clientProfileId: widget.clientId,
          clientName: widget.clientName,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrainerClientSessionCubit, TrainerClientSessionState>(
      listener: (context, state) {
        state.maybeWhen(
          submitted: (sessionLog) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFF34D399),
              duration: const Duration(seconds: 3),
              content: Text(
                sessionLog.status.name == 'skipped'
                    ? 'SESSION SKIPPED FOR ${widget.clientName.toUpperCase()}.'
                    : 'SESSION LOGGED FOR ${widget.clientName.toUpperCase()}!',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF002114),
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ));
            context.pop();
          },
          error: (failure, clientName, profile, weeklyPlan, dayPlan, draft, dayLogs,
              activeDayIndex) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFFBA1A1A),
              content: Text(
                failure.maybeWhen(
                  server: (code, msg) => msg ?? 'Server error',
                  network: (msg) => msg ?? 'Network error. Check your connection.',
                  orElse: () => 'An error occurred.',
                ),
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 12),
              ),
            ));
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => _buildShell(context, _buildLoading(), clientName: widget.clientName),
          loading: () => _buildShell(context, _buildLoading(), clientName: widget.clientName),
          noPlan: (clientName) => _buildShell(
            context,
            _buildNoPlan(context, clientName),
            clientName: clientName,
          ),
          loaded: (profile, weeklyPlan, dayPlan, draft, clientName, dayLogs,
                  activeDayIndex) =>
              _buildShell(
            context,
            _buildContent(context, profile, weeklyPlan, dayPlan, draft, clientName,
                false, dayLogs, activeDayIndex),
            clientName: clientName,
          ),
          submitting: (profile, weeklyPlan, dayPlan, draft, clientName, dayLogs,
                  activeDayIndex) =>
              _buildShell(
            context,
            _buildContent(context, profile, weeklyPlan, dayPlan, draft, clientName,
                true, dayLogs, activeDayIndex),
            clientName: clientName,
          ),
          submitted: (_) => _buildShell(context, _buildLoading(), clientName: widget.clientName),
          error: (failure, clientName, profile, weeklyPlan, dayPlan, draft, dayLogs,
              activeDayIndex) {
            if (profile != null &&
                weeklyPlan != null &&
                dayPlan != null &&
                draft != null) {
              return _buildShell(
                context,
                _buildContent(context, profile, weeklyPlan, dayPlan, draft,
                    clientName ?? widget.clientName, false, dayLogs, activeDayIndex),
                clientName: clientName ?? widget.clientName,
              );
            }
            return _buildShell(
              context,
              Center(
                child: Text('Failed to load session.',
                    style: GoogleFonts.manrope(fontSize: 14)),
              ),
              clientName: clientName ?? widget.clientName,
            );
          },
        );
      },
    );
  }

  Widget _buildShell(BuildContext context, Widget body,
      {required String clientName}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD);
    final outlineColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);
    final bannerBg = isDark ? const Color(0xFF1C1B1B) : const Color(0xFFF0EDEC);

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
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
              child: Text(
                clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              clientName.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // "Editing on behalf of…" strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: bannerBg,
              border: Border(bottom: BorderSide(color: outlineColor, width: 1)),
            ),
            child: Text(
              'EDITING ON BEHALF OF ${clientName.toUpperCase()}',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: const Color(0xFF34D399),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildLoading() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildNoPlan(BuildContext context, String clientName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_outlined, size: 64, color: textSecondary),
            const SizedBox(height: 24),
            Text('NO ACTIVE PROGRAM',
                style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textPrimary)),
            const SizedBox(height: 12),
            Text(
              '$clientName doesn\'t have an active program assigned.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic profile,
    WeeklyPlan weeklyPlan,
    dynamic dayPlan,
    dynamic draft,
    String clientName,
    bool isSubmitting,
    Map<int, WorkoutSessionLog> dayLogs,
    int activeDayIndex,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const sinewGreen = Color(0xFF34D399);
    final slateDark = isDark ? const Color(0xFF0E0E0E) : const Color(0xFF111827);
    final outlineColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);
    final cardBg = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);

    final tasks = (dayPlan.tasks as List<Task>?) ?? [];
    final taskDrafts = draft.taskDrafts as List;
    final completedCount = taskDrafts.length;
    final completionPercent = tasks.isEmpty ? 0.0 : completedCount / tasks.length;
    final hasAnyActuals = taskDrafts.isNotEmpty;
    final canComplete = hasAnyActuals || dayPlan.isRestDay;

    return Column(
      children: [
        // Session header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft.weeklyPlanName?.toUpperCase() ?? 'CURRENT PLAN',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Day ${dayPlan.dayIndex}  ·  ${draft.dayPlanLabel ?? 'Today'}',
                style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 16),
              // Day strip
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, i) {
                    final dayIndex = i + 1;
                    final isToday = dayPlan.dayIndex == dayIndex;
                    final log = dayLogs[dayIndex];
                    final status = log?.status;
                    const skippedColor = Color(0xFFBA1A1A);

                    Color bg;
                    Color border;
                    Color fg;
                    IconData? icon;

                    if (isToday) {
                      bg = textPrimary;
                      border = outlineColor;
                      fg = isDark ? const Color(0xFF131313) : Colors.white;
                      icon = null;
                    } else if (status == SessionStatus.completed ||
                        status == SessionStatus.partial) {
                      bg = sinewGreen.withValues(alpha: 0.12);
                      border = sinewGreen;
                      fg = sinewGreen;
                      icon = Icons.check;
                    } else if (status == SessionStatus.skipped) {
                      bg = skippedColor.withValues(alpha: 0.10);
                      border = skippedColor;
                      fg = skippedColor;
                      icon = Icons.close;
                    } else {
                      bg = Colors.transparent;
                      border = outlineColor;
                      fg = textSecondary;
                      icon = null;
                    }

                    return InkWell(
                      onTap: isToday
                          ? null
                          : () {
                              final tappedDayPlan = weeklyPlan.dayPlans
                                  .firstWhereOrNull((d) => d.dayIndex == dayIndex);
                              if (tappedDayPlan == null) return;
                              context.push(
                                AppRoute.dayPreview.path,
                                extra: DayPreviewArgs(
                                  dayPlan: tappedDayPlan,
                                  log: log,
                                  isUpcoming:
                                      log == null && dayIndex >= activeDayIndex,
                                  weeklyPlanName: weeklyPlan.name,
                                  clientName: clientName,
                                ),
                              );
                            },
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(color: border, width: 1),
                        ),
                        child: icon != null
                            ? Icon(icon, size: 14, color: fg)
                            : Text(
                                'D$dayIndex',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: fg,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SESSION PROGRESS',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: textSecondary,
                    ),
                  ),
                  Text(
                    '$completedCount/${tasks.isEmpty ? '?' : tasks.length}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 6,
                color: outlineColor,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: completionPercent.clamp(0.0, 1.0),
                  child: Container(color: sinewGreen),
                ),
              ),
            ],
          ),
        ),

        // Task list
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Text('No tasks planned.',
                      style: GoogleFonts.inter(color: textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final taskDraft =
                        taskDrafts.where((d) => d.taskId == task.id).firstOrNull;
                    final isCompleted = taskDraft != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: outlineColor, width: 1),
                      ),
                      child: InkWell(
                        onTap: () {
                          _openInlineEditor(context, task, profile.id, taskDraft,
                              isDark, outlineColor, textPrimary, textSecondary);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.name.toUpperCase(),
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${task.sets} sets × ${task.reps} reps',
                                      style: GoogleFonts.inter(
                                          fontSize: 12, color: textSecondary),
                                    ),
                                    if (isCompleted && taskDraft.actualSets != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Actual: ${taskDraft.actualSets} sets × ${taskDraft.actualReps ?? '-'} reps${taskDraft.actualWeightKg != null ? ' @ ${taskDraft.actualWeightKg}kg' : ''}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: sinewGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                isCompleted ? Icons.check_circle : Icons.edit_outlined,
                                color: isCompleted ? sinewGreen : textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Bottom actions
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canComplete ? slateDark : const Color(0xFF6B7280),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              onPressed: isSubmitting || !canComplete
                  ? null
                  : () => context
                      .read<TrainerClientSessionCubit>()
                      .completeSession(),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'COMPLETE SESSION',
                      style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _openInlineEditor(
    BuildContext context,
    Task task,
    String workoutProfileId,
    dynamic existingDraft,
    bool isDark,
    Color outlineColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final setsCtrl = TextEditingController(
        text: existingDraft?.actualSets?.toString() ?? '');
    final repsCtrl =
        TextEditingController(text: existingDraft?.actualReps ?? '');
    final weightCtrl = TextEditingController(
        text: existingDraft?.actualWeightKg?.toString() ?? '');
    final notesCtrl =
        TextEditingController(text: existingDraft?.notes ?? '');

    final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBE7E7);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? const Color(0xFF1C1B1B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.name.toUpperCase(),
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: textPrimary),
              ),
              Text(
                'TARGET: ${task.sets} sets × ${task.reps}',
                style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _TrainerInputField(
                      label: 'ACTUAL SETS',
                      controller: setsCtrl,
                      inputBg: inputBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      outlineColor: outlineColor,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrainerInputField(
                      label: 'ACTUAL REPS',
                      controller: repsCtrl,
                      inputBg: inputBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      outlineColor: outlineColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrainerInputField(
                      label: 'WEIGHT (KG)',
                      controller: weightCtrl,
                      inputBg: inputBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      outlineColor: outlineColor,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TrainerInputField(
                label: 'TRAINER NOTES',
                controller: notesCtrl,
                inputBg: inputBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                outlineColor: outlineColor,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () {
                    context.read<TrainerClientSessionCubit>().upsertTaskCompletion(
                          workoutProfileId: workoutProfileId,
                          taskId: task.id,
                          actualSets: int.tryParse(setsCtrl.text),
                          actualReps: repsCtrl.text.isNotEmpty ? repsCtrl.text : null,
                          actualWeightKg: double.tryParse(weightCtrl.text),
                          notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                        );
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'SAVE',
                    style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _TrainerInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color inputBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color outlineColor;
  final TextInputType? keyboardType;
  final int maxLines;

  const _TrainerInputField({
    required this.label,
    required this.controller,
    required this.inputBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.outlineColor,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
              fontSize: 9, fontWeight: FontWeight.w800, color: textSecondary, letterSpacing: 1.5),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.manrope(fontSize: 14, color: textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
