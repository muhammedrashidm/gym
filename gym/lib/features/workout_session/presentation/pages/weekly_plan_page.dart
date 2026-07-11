import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/member_workout_session/member_workout_session_cubit.dart';
import '../cubit/member_workout_session/member_workout_session_state.dart';
import '../../../workout/domain/entities/task.dart';

class WeeklyPlanPage extends StatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  State<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage> {
  @override
  void initState() {
    super.initState();
    context.read<MemberWorkoutSessionCubit>().loadSession();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberWorkoutSessionCubit, MemberWorkoutSessionState>(
      listener: (context, state) {
        state.maybeWhen(
          submitted: (sessionLog) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFF34D399),
              duration: const Duration(seconds: 3),
              content: Text(
                sessionLog.status.name == 'skipped'
                    ? 'SESSION SKIPPED.'
                    : 'WORKOUT SESSION LOGGED! GREAT WORK.',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF002114),
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ));
            // Reload for next day
            context.read<MemberWorkoutSessionCubit>().loadSession();
          },
          error: (failure, profile, dayPlan, draft) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFFBA1A1A),
              content: Text(
                failure.maybeWhen(
                  server: (code, msg) => msg ?? 'Server error',
                  network: (msg) => msg ?? 'Network error. Check your connection.',
                  orElse: () => 'An error occurred. Please try again.',
                ),
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ));
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => const _LoadingScaffold(),
          loading: () => const _LoadingScaffold(),
          noPlan: () => const _NoPlanScaffold(),
          loaded: (profile, dayPlan, draft) => _LoadedScaffold(
            profile: profile,
            dayPlan: dayPlan,
            draft: draft,
          ),
          submitting: (profile, dayPlan, draft) => _LoadedScaffold(
            profile: profile,
            dayPlan: dayPlan,
            draft: draft,
            isSubmitting: true,
          ),
          submitted: (_) => const _LoadingScaffold(),
          error: (failure, profile, dayPlan, draft) {
            if (profile != null && dayPlan != null && draft != null) {
              return _LoadedScaffold(
                  profile: profile, dayPlan: dayPlan, draft: draft);
            }
            return _ErrorScaffold(message: failure.maybeWhen(
              server: (code, msg) => msg ?? 'Server error',
              orElse: () => 'Failed to load workout',
            ));
          },
        );
      },
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD),
      appBar: _buildAppBar(context, isDark, textPrimary),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD),
      appBar: _buildAppBar(context, isDark, textPrimary),
      body: Center(
        child: Text(message,
            style: GoogleFonts.manrope(color: textPrimary, fontSize: 14)),
      ),
    );
  }
}

// ─── No Plan ──────────────────────────────────────────────────────────────────

class _NoPlanScaffold extends StatelessWidget {
  const _NoPlanScaffold();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD),
      appBar: _buildAppBar(context, isDark, textPrimary),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center_outlined, size: 64, color: textSecondary),
              const SizedBox(height: 24),
              Text(
                'NO ACTIVE PROGRAM',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your trainer hasn\'t assigned a program yet. Check back soon.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loaded ───────────────────────────────────────────────────────────────────

class _LoadedScaffold extends StatelessWidget {
  final dynamic profile;
  final dynamic dayPlan;
  final dynamic draft;
  final bool isSubmitting;

  const _LoadedScaffold({
    required this.profile,
    required this.dayPlan,
    required this.draft,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const sinewGreen = Color(0xFF34D399);
    final slateDark = isDark ? const Color(0xFF0E0E0E) : const Color(0xFF111827);
    final outlineColor = isDark ? const Color(0xFF444748) : const Color(0xFFE5E7EB);
    final cardBg = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD);

    final tasks = (dayPlan.tasks as List<Task>?) ?? [];
    final taskDrafts = draft.taskDrafts as List;

    int completedCount = taskDrafts.length;
    double completionPercent = tasks.isEmpty ? 0 : completedCount / tasks.length;
    bool hasAnyActuals = taskDrafts.isNotEmpty;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context, isDark, textPrimary),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE PROGRAM',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  draft.weeklyPlanName?.toUpperCase() ?? 'CURRENT PLAN',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Day ${profile.currentDayIndex}  ·  ${draft.dayPlanLabel ?? dayPlan.label ?? 'Today'}',
                  style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 20),
                // Progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TODAY\'S COMPLETION',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: textPrimary,
                        )),
                    Text('${(completionPercent * 100).round()}%',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        )),
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

          // Day strip (7-day cycle indicator, read-only)
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: outlineColor, width: 1.0)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final isToday = profile.currentDayIndex == index + 1;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isToday ? textPrimary : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    'D${index + 1}',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isToday ? textPrimary : textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.self_improvement, size: 64, color: textSecondary),
                          const SizedBox(height: 16),
                          Text('REST DAY',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              )),
                          const SizedBox(height: 8),
                          Text(
                            'No protocols today. Focus on rest and recovery.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
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
                      final taskDraft = taskDrafts.where(
                        (d) => d.taskId == task.id,
                      ).firstOrNull;
                      final isCompleted = taskDraft != null;

                      return _TaskRow(
                        task: task,
                        isCompleted: isCompleted,
                        outlineColor: outlineColor,
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        sinewGreen: sinewGreen,
                        isDark: isDark,
                        onTap: () async {
                          final taskData = {
                            'id': task.id,
                            'name': task.name,
                            'sets': task.sets,
                            'reps': task.reps,
                            'restSeconds': task.restSeconds,
                            'tempo': task.tempo,
                            'machineDetails': task.machineDetails,
                            'notes': task.notes,
                            'workoutProfileId': profile.id,
                            'existingDraft': taskDraft,
                          };
                          await context.push(
                            AppRoute.taskExecution.path,
                            extra: taskData,
                          );
                        },
                      );
                    },
                  ),
          ),

          // Bottom actions
          if (tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: outlineColor, width: 1.5),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          foregroundColor: textPrimary,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () => _confirmSkip(context),
                        child: Text(
                          'SKIP TODAY',
                          style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasAnyActuals ? slateDark : const Color(0xFF6B7280),
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        onPressed: isSubmitting || !hasAnyActuals
                            ? null
                            : () => context
                                .read<MemberWorkoutSessionCubit>()
                                .completeSession(),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
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
              ),
            ),
        ],
      ),
    );
  }

  void _confirmSkip(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('SKIP TODAY?',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
        content: Text(
          'This will mark today\'s session as skipped. No task data will be recorded.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MemberWorkoutSessionCubit>().skipSession();
            },
            child: const Text('SKIP'),
          ),
        ],
      ),
    );
  }
}

// ─── Task Row Widget ──────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  final Task task;
  final bool isCompleted;
  final Color outlineColor;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color sinewGreen;
  final bool isDark;
  final VoidCallback onTap;

  const _TaskRow({
    required this.task,
    required this.isCompleted,
    required this.outlineColor,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.sinewGreen,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: outlineColor, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
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
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Icon(Icons.check_circle, color: sinewGreen, size: 20),
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
                  const SizedBox(width: 12),
                  if (task.restSeconds != null)
                    _StatChip(
                      label: 'REST',
                      value: '${task.restSeconds}s',
                      outlineColor: outlineColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                ],
              ),
            ],
          ),
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

// ─── Shared AppBar builder ────────────────────────────────────────────────────

AppBar _buildAppBar(BuildContext context, bool isDark, Color textPrimary) {
  return AppBar(
    backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
    elevation: 0.5,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: Icon(Icons.menu, color: textPrimary),
      onPressed: () {},
    ),
    title: Text(
      'KINETIC',
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFF111827),
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
      ),
    ],
  );
}
