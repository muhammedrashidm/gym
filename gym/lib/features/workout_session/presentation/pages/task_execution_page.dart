import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/member_workout_session/member_workout_session_cubit.dart';
import '../../../../core/router/app_routes.dart';
import '../../../exercise_config/domain/entities/exercise_config.dart';
import '../../../exercise_ai/domain/config/ai_config_parser.dart';
import '../../../exercise_ai/domain/entities/analysis.dart';
import '../../../exercise_ai/domain/session/set_plan.dart';
import '../../../exercise_ai/presentation/pages/watch_me_args.dart';

class TaskExecutionPage extends StatefulWidget {
  final Map<String, dynamic> taskData;

  const TaskExecutionPage({
    super.key,
    required this.taskData,
  });

  @override
  State<TaskExecutionPage> createState() => _TaskExecutionPageState();
}

class _TaskExecutionPageState extends State<TaskExecutionPage> {
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing draft data if resuming
    final existing = widget.taskData['existingDraft'];
    if (existing != null) {
      _setsController.text = existing.actualSets?.toString() ?? '';
      _repsController.text = existing.actualReps ?? '';
      _weightController.text = existing.actualWeightKg?.toString() ?? '';
      _notesController.text = existing.notes ?? '';
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _autoSave() {
    final workoutProfileId = widget.taskData['workoutProfileId'] as String?;
    final taskId = widget.taskData['id'] as String?;
    if (workoutProfileId == null || taskId == null) return;

    context.read<MemberWorkoutSessionCubit>().upsertTaskCompletion(
          workoutProfileId: workoutProfileId,
          taskId: taskId,
          actualSets: int.tryParse(_setsController.text),
          actualReps: _repsController.text.isNotEmpty ? _repsController.text : null,
          actualWeightKg: double.tryParse(_weightController.text),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _handleSaveAndBack() {
    _autoSave();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.pop(true);
    });
  }

  /// The pre-fetched exercise config carried in `taskData['aiConfig']`. Non-null
  /// with a populated `aiConfigJson` only when the upstream loader hydrated it.
  ExerciseConfig? get _exerciseConfig {
    final cfg = widget.taskData['aiConfig'];
    return cfg is ExerciseConfig ? cfg : null;
  }

  /// Show the Watch Me button only when there is a usable, supported config.
  bool get _canWatchMe {
    final cfg = _exerciseConfig;
    if (cfg == null) return false;
    return AiConfigParser.isSupported(cfg.analyzerType, cfg.aiConfigJson);
  }

  /// Today's prescription, straight from the backend task. This is the only
  /// source of sets/reps/rest for the coach — the AI config says nothing about
  /// them.
  SetPlan get _setPlan => SetPlan.fromTask(
        sets: widget.taskData['sets'] as int?,
        reps: widget.taskData['reps'] as String?,
        restSeconds: widget.taskData['restSeconds'] as int?,
      );

  Future<void> _launchWatchMe() async {
    final cfg = _exerciseConfig;
    if (cfg == null) return;
    final result = await context.push(
      AppRoute.watchMe.path,
      extra: WatchMeArgs(config: cfg, plan: _setPlan),
    );
    if (!mounted || result is! SessionAnalysisResult) return;
    if (result.completedSets == 0) return;

    // Pre-fill logged actuals from the AI-measured sets (user can still edit).
    if (_setsController.text.isEmpty) {
      _setsController.text = '${result.completedSets}';
    }
    if (_repsController.text.isEmpty) {
      _repsController.text = result.repsPerSetLabel;
    }
    final scoreNote =
        'AI: ${result.completedSets}/${result.plannedSets} sets · '
        'reps ${result.repsPerSetLabel} '
        '(${result.validReps}/${result.totalReps} clean) · '
        'form ${result.formScore.toStringAsFixed(0)} · '
        'overall ${result.overallScore.toStringAsFixed(0)}';
    _notesController.text = _notesController.text.isEmpty
        ? scoreNote
        : '${_notesController.text}\n$scoreNote';
    _autoSave();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const sinewGreen = Color(0xFF34D399);
    final slateDark = isDark ? const Color(0xFF0E0E0E) : const Color(0xFF111827);
    final outlineColor = isDark ? const Color(0xFF444748) : const Color(0xFFE5E7EB);
    final cardBg = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE5E2E1) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);
    final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBE7E7);

    final String name = widget.taskData['name'] ?? 'Exercise Protocol';
    final int sets = widget.taskData['sets'] ?? 4;
    final String reps = widget.taskData['reps'] ?? '8-12';
    final int? restSeconds = widget.taskData['restSeconds'];
    final String? tempo = widget.taskData['tempo'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF7F9FD),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'LOG EXERCISE',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: textSecondary,
          ),
        ),
        actions: [
          if (_saved)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: sinewGreen, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'AUTOSAVED',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: sinewGreen,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise name
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Planned target ref
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: cardBg,
                  child: Row(
                    children: [
                      _TargetStat('TARGET SETS', '$sets',
                          textPrimary: textPrimary, textSecondary: textSecondary),
                      const SizedBox(width: 24),
                      _TargetStat('TARGET REPS', reps,
                          textPrimary: textPrimary, textSecondary: textSecondary),
                      if (restSeconds != null) ...[
                        const SizedBox(width: 24),
                        _TargetStat('REST', '${restSeconds}s',
                            textPrimary: textPrimary, textSecondary: textSecondary),
                      ],
                      if (tempo != null) ...[
                        const SizedBox(width: 24),
                        _TargetStat('TEMPO', tempo,
                            textPrimary: textPrimary, textSecondary: textSecondary),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // AI form coach entry point (only when a supported, hydrated
                // ExerciseConfig is present on this task).
                if (_canWatchMe)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _launchWatchMe,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: sinewGreen,
                        side: const BorderSide(color: sinewGreen, width: 1.5),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      icon: const Icon(Icons.videocam_outlined, size: 20),
                      label: Text(
                        'WATCH ME — AI FORM COACH',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                if (_canWatchMe) const SizedBox(height: 24),

                // Actual inputs
                Text(
                  'LOG ACTUALS',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Actual sets (stepper)
                _buildInputRow(
                  label: 'ACTUAL SETS',
                  child: Row(
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onTap: () {
                          final v = int.tryParse(_setsController.text) ?? 0;
                          if (v > 0) {
                            _setsController.text = '${v - 1}';
                            _autoSave();
                          }
                        },
                        outlineColor: outlineColor,
                        textPrimary: textPrimary,
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _setsController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputBg,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (_) => _autoSave(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StepperButton(
                        icon: Icons.add,
                        onTap: () {
                          final v = int.tryParse(_setsController.text) ?? 0;
                          _setsController.text = '${v + 1}';
                          _autoSave();
                        },
                        outlineColor: outlineColor,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  outlineColor: outlineColor,
                  cardBg: cardBg,
                ),
                const SizedBox(height: 12),

                // Actual reps
                _buildInputRow(
                  label: 'ACTUAL REPS',
                  helpText: 'e.g. 10,10,8,8 per set',
                  child: TextField(
                    controller: _repsController,
                    style: GoogleFonts.manrope(fontSize: 16, color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      border: InputBorder.none,
                      hintText: 'e.g. 10,10,8,8',
                      hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (_) => _autoSave(),
                  ),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  outlineColor: outlineColor,
                  cardBg: cardBg,
                ),
                const SizedBox(height: 12),

                // Actual weight
                _buildInputRow(
                  label: 'ACTUAL WEIGHT (KG)',
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.manrope(fontSize: 16, color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      border: InputBorder.none,
                      hintText: '0.0',
                      hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (_) => _autoSave(),
                  ),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  outlineColor: outlineColor,
                  cardBg: cardBg,
                ),
                const SizedBox(height: 12),

                // Notes
                _buildInputRow(
                  label: 'NOTES (OPTIONAL)',
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      border: InputBorder.none,
                      hintText: 'How did it feel? Any adjustments?',
                      hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (_) => _autoSave(),
                  ),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  outlineColor: outlineColor,
                  cardBg: cardBg,
                ),
              ],
            ),
          ),

          // Fixed bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: isDark
                  ? const Color(0xFF131313).withValues(alpha: 0.95)
                  : const Color(0xFFF7F9FD).withValues(alpha: 0.95),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: slateDark,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      elevation: 0,
                    ),
                    onPressed: _handleSaveAndBack,
                    child: Text(
                      'SAVE & BACK TO SESSION',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    String? helpText,
    required Widget child,
    required Color textPrimary,
    required Color textSecondary,
    required Color outlineColor,
    required Color cardBg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: outlineColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: textSecondary,
            ),
          ),
          if (helpText != null) ...[
            const SizedBox(height: 2),
            Text(helpText,
                style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TargetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  const _TargetStat(this.label, this.value,
      {required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.manrope(
                fontSize: 9, fontWeight: FontWeight.w800, color: textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.manrope(
                fontSize: 15, fontWeight: FontWeight.w800, color: textPrimary)),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color outlineColor;
  final Color textPrimary;
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.outlineColor,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: outlineColor, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: textPrimary),
      ),
    );
  }
}
