import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../domain/value_objects/draft_day_plan.dart';
import '../../domain/value_objects/draft_task.dart';
import '../cubit/week_plan_creator/week_plan_creator_cubit.dart';
import '../cubit/week_plan_creator/week_plan_creator_state.dart';
import 'protocol_form_page.dart';

class WeekPlanCreatorPage extends StatelessWidget {
  final String workoutProfileId;

  const WeekPlanCreatorPage({
    super.key,
    required this.workoutProfileId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeekPlanCreatorCubit(getIt<Mediator>()),
      child: _WeekPlanCreatorView(workoutProfileId: workoutProfileId),
    );
  }
}

class _WeekPlanCreatorView extends StatelessWidget {
  final String workoutProfileId;
  const _WeekPlanCreatorView({required this.workoutProfileId});

  static const _dayNames = ['DAY 1', 'DAY 2', 'DAY 3', 'DAY 4', 'DAY 5', 'DAY 6', 'DAY 7'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final textCol = isDark ? Colors.white : Colors.black;
    final mutedCol = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    return BlocConsumer<WeekPlanCreatorCubit, WeekPlanCreatorState>(
      listener: (context, state) {
        state.whenOrNull(
          saved: (plan) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PLAN "${plan.name.toUpperCase()}" SAVED SUCCESSFULLY'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(plan);
          },
          error: (message, days, planName, planNotes, activateImmediately, selectedDayIndex) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message.toUpperCase()),
                backgroundColor: const Color(0xFFBA1A1A),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<WeekPlanCreatorCubit>().resumeEditing();
          },
        );
      },
      builder: (context, state) {
        final isSaving = state is WeekPlanCreatorSaving;
        final editingState = _extractEditing(state);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: Icon(Icons.close, color: textCol, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              '= MONOLITH',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textCol,
                letterSpacing: 2,
              ),
            ),
          ),
          body: isSaving
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: textCol, strokeWidth: 2),
                      const SizedBox(height: 16),
                      Text(
                        'SAVING PLAN...',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: mutedCol,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildBody(context, editingState, textCol, mutedCol, cardColor, borderCol, isDark),
          bottomNavigationBar: isSaving
              ? null
              : _BottomActionBar(
                  workoutProfileId: workoutProfileId,
                  state: editingState,
                  textCol: textCol,
                  cardColor: cardColor,
                  borderCol: borderCol,
                ),
        );
      },
    );
  }

  WeekPlanCreatorEditing _extractEditing(WeekPlanCreatorState state) {
    return state.maybeWhen(
      editing: (name, notes, activate, dayIdx, days) => WeekPlanCreatorEditing(
        planName: name,
        planNotes: notes,
        activateImmediately: activate,
        selectedDayIndex: dayIdx,
        days: days,
      ),
      error: (message, days, planName, planNotes, activateImmediately, selectedDayIndex) => WeekPlanCreatorEditing(
        planName: planName,
        planNotes: planNotes,
        activateImmediately: activateImmediately,
        selectedDayIndex: selectedDayIndex,
        days: days,
      ),
      orElse: () => WeekPlanCreatorEditing(
        days: List.generate(7, (i) => DraftDayPlan(dayIndex: i + 1)),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeekPlanCreatorEditing s,
    Color textCol,
    Color mutedCol,
    Color cardColor,
    Color borderCol,
    bool isDark,
  ) {
    final cubit = context.read<WeekPlanCreatorCubit>();
    final selectedDay = s.days[s.selectedDayIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Plan header ─────────────────────────────────────────────────
          _PlanHeaderSection(
            planName: s.planName,
            planNotes: s.planNotes,
            activateImmediately: s.activateImmediately,
            textCol: textCol,
            mutedCol: mutedCol,
            isDark: isDark,
            borderCol: borderCol,
            cardColor: cardColor,
            onNameChanged: cubit.setPlanName,
            onNotesChanged: cubit.setPlanNotes,
            onActivateChanged: cubit.setActivateImmediately,
          ),

          const SizedBox(height: 16),

          // ── Day tab row (Scrollable) ─────────────────────────────────────
          _DayTabRow(
            days: s.days,
            selectedIndex: s.selectedDayIndex,
            dayNames: _dayNames,
            textCol: textCol,
            cardColor: cardColor,
            borderCol: borderCol,
            mutedCol: mutedCol,
            onSelect: cubit.selectDay,
          ),

          // ── Selected day config ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: _DayConfigRow(
              day: selectedDay,
              textCol: textCol,
              mutedCol: mutedCol,
              isDark: isDark,
              borderCol: borderCol,
              onToggleRest: (v) => cubit.toggleRestDay(selectedDay.dayIndex, v),
              onLabelChanged: (v) => cubit.setDayLabel(selectedDay.dayIndex, v),
            ),
          ),

          // ── Task list ────────────────────────────────────────────────────
          selectedDay.isRestDay
              ? _RestDayPlaceholder(mutedCol: mutedCol)
              : _TaskList(
                  day: selectedDay,
                  textCol: textCol,
                  mutedCol: mutedCol,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderCol: borderCol,
                  onEdit: (task) async {
                    final updated = await Navigator.of(context).push<DraftTask>(
                      MaterialPageRoute(
                        builder: (_) => ProtocolFormPage(
                          existingTask: task,
                          nextSequenceIndex: selectedDay.tasks.length + 1,
                        ),
                      ),
                    );
                    if (updated != null && context.mounted) {
                      cubit.updateTask(selectedDay.dayIndex, task.localId, updated);
                    }
                  },
                  onRemove: (task) => cubit.removeTask(selectedDay.dayIndex, task.localId),
                ),

          // ── ADD PROTOCOL button ──────────────────────────────────────────
          if (!selectedDay.isRestDay)
            _AddProtocolButton(
              day: selectedDay,
              textCol: textCol,
              borderCol: borderCol,
              onAdd: (task) => cubit.addTask(selectedDay.dayIndex, task),
            ),

          const SizedBox(height: 24),

          // ── PROJECTED INTENSITY Section ──────────────────────────────────
          _ProjectedIntensitySection(
            days: s.days,
            textCol: textCol,
            mutedCol: mutedCol,
            borderCol: borderCol,
            isDark: isDark,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan Header Section
// ─────────────────────────────────────────────────────────────────────────────

class _PlanHeaderSection extends StatefulWidget {
  final String planName;
  final String planNotes;
  final bool activateImmediately;
  final Color textCol;
  final Color mutedCol;
  final Color borderCol;
  final Color cardColor;
  final bool isDark;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<bool> onActivateChanged;

  const _PlanHeaderSection({
    required this.planName,
    required this.planNotes,
    required this.activateImmediately,
    required this.textCol,
    required this.mutedCol,
    required this.borderCol,
    required this.cardColor,
    required this.isDark,
    required this.onNameChanged,
    required this.onNotesChanged,
    required this.onActivateChanged,
  });

  @override
  State<_PlanHeaderSection> createState() => _PlanHeaderSectionState();
}

class _PlanHeaderSectionState extends State<_PlanHeaderSection> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.planName);
    _notesCtrl = TextEditingController(text: widget.planNotes);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.cardColor,
          border: Border.all(color: widget.borderCol),
          borderRadius: BorderRadius.zero,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PLAN CONFIGURATION',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: widget.mutedCol,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PLAN NAME',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: widget.textCol,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              onChanged: widget.onNameChanged,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.textCol,
              ),
              decoration: InputDecoration(
                hintText: 'E.G. ELITE STRENGTH PHASE I',
                hintStyle: GoogleFonts.inter(
                  fontSize: 11,
                  color: widget.mutedCol,
                ),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'DESCRIPTION',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: widget.textCol,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesCtrl,
              onChanged: widget.onNotesChanged,
              maxLines: 3,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: widget.textCol,
              ),
              decoration: InputDecoration(
                hintText: 'Focused hypertrophy cycle targeting peak adaptation...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 11,
                  color: widget.mutedCol,
                ),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'ACTIVATE IMMEDIATELY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: widget.textCol,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Checkbox(
                  value: widget.activateImmediately,
                  onChanged: (val) => widget.onActivateChanged(val ?? false),
                  activeColor: widget.textCol,
                  checkColor: widget.cardColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Tab Row
// ─────────────────────────────────────────────────────────────────────────────

class _DayTabRow extends StatelessWidget {
  final List<DraftDayPlan> days;
  final int selectedIndex;
  final List<String> dayNames;
  final Color textCol;
  final Color cardColor;
  final Color borderCol;
  final Color mutedCol;
  final ValueChanged<int> onSelect;

  const _DayTabRow({
    required this.days,
    required this.selectedIndex,
    required this.dayNames,
    required this.textCol,
    required this.cardColor,
    required this.borderCol,
    required this.mutedCol,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY PLAN • 7 FIXED DAYS',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: mutedCol,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (index) {
              final isSelected = index == selectedIndex;
              final day = days[index];
              final isRest = day.isRestDay;
              final taskCount = day.tasks.length;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? textCol : (isRest ? Colors.transparent : cardColor),
                      border: Border.all(
                        color: isSelected
                            ? textCol
                            : (isRest ? borderCol : borderCol.withValues(alpha: 0.5)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'D${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? cardColor : (isRest ? mutedCol : textCol),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isRest ? 'REST' : '$taskCount T',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? cardColor.withValues(alpha: 0.8) : mutedCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Config Row (label + rest toggle)
// ─────────────────────────────────────────────────────────────────────────────

class _DayConfigRow extends StatefulWidget {
  final DraftDayPlan day;
  final Color textCol;
  final Color mutedCol;
  final Color borderCol;
  final bool isDark;
  final ValueChanged<bool> onToggleRest;
  final ValueChanged<String> onLabelChanged;

  const _DayConfigRow({
    required this.day,
    required this.textCol,
    required this.mutedCol,
    required this.borderCol,
    required this.isDark,
    required this.onToggleRest,
    required this.onLabelChanged,
  });

  @override
  State<_DayConfigRow> createState() => _DayConfigRowState();
}

class _DayConfigRowState extends State<_DayConfigRow> {
  late TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.day.label ?? '');
  }

  @override
  void didUpdateWidget(_DayConfigRow old) {
    super.didUpdateWidget(old);
    if (old.day.dayIndex != widget.day.dayIndex) {
      _labelCtrl.text = widget.day.label ?? '';
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _labelCtrl,
            onFieldSubmitted: widget.onLabelChanged,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.textCol,
            ),
            decoration: InputDecoration(
              hintText: 'ADD LABEL (E.G. LEG DAY / PUSH DAY)...',
              hintStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: widget.mutedCol,
              ),
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => widget.onToggleRest(!widget.day.isRestDay),
          child: Row(
            children: [
              Checkbox(
                value: widget.day.isRestDay,
                onChanged: (val) => widget.onToggleRest(val ?? false),
                activeColor: widget.textCol,
                checkColor: cardColor,
              ),
              Text(
                'REST DAY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: widget.textCol,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task List
// ─────────────────────────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  final DraftDayPlan day;
  final Color textCol;
  final Color mutedCol;
  final Color cardColor;
  final Color borderCol;
  final bool isDark;
  final Future<void> Function(DraftTask) onEdit;
  final void Function(DraftTask) onRemove;

  const _TaskList({
    required this.day,
    required this.textCol,
    required this.mutedCol,
    required this.cardColor,
    required this.borderCol,
    required this.isDark,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (day.tasks.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          'NO TASKS FOR THIS DAY YET',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: mutedCol,
          ),
        ),
      );
    }

    // Sort tasks by sequenceIndex
    final sortedTasks = List<DraftTask>.from(day.tasks)
      ..sort((a, b) => a.sequenceIndex.compareTo(b.sequenceIndex));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sortedTasks.length,
      itemBuilder: (_, i) {
        final task = sortedTasks[i];
        return _TaskCard(
          task: task,
          textCol: textCol,
          mutedCol: mutedCol,
          cardColor: cardColor,
          borderCol: borderCol,
          isDark: isDark,
          onEdit: () => onEdit(task),
          onRemove: () => onRemove(task),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final DraftTask task;
  final Color textCol;
  final Color mutedCol;
  final Color cardColor;
  final Color borderCol;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _TaskCard({
    required this.task,
    required this.textCol,
    required this.mutedCol,
    required this.cardColor,
    required this.borderCol,
    required this.isDark,
    required this.onEdit,
    required this.onRemove,
  });

  String getCategoryTag(int index) {
    if (index == 1) return 'COMPOUND';
    if (index == 2) return 'POSTERIOR CHAIN';
    return 'ACCESSORY';
  }

  Color getTagBg(String tag, bool isDark) {
    if (tag == 'COMPOUND') return isDark ? const Color(0xFF1B3D2B) : const Color(0xFFDCFCE7);
    if (tag == 'POSTERIOR CHAIN') return isDark ? const Color(0xFF123F52) : const Color(0xFFECFEFF);
    return isDark ? const Color(0xFF453D1C) : const Color(0xFFFEF9C3);
  }

  Color getTagText(String tag, bool isDark) {
    if (tag == 'COMPOUND') return isDark ? const Color(0xFF5ED893) : const Color(0xFF15803D);
    if (tag == 'POSTERIOR CHAIN') return isDark ? const Color(0xFF4BD3E6) : const Color(0xFF0E7490);
    return isDark ? const Color(0xFFE6C84B) : const Color(0xFFA16207);
  }

  @override
  Widget build(BuildContext context) {
    final tag = getCategoryTag(task.sequenceIndex);
    final tagBg = getTagBg(tag, isDark);
    final tagText = getTagText(tag, isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Thumbnail Placeholder (Strict 0px)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : const Color(0xFFF1F1F1),
              border: Border.all(color: borderCol),
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(Icons.fitness_center, size: 20, color: mutedCol),
          ),
          const SizedBox(width: 12),

          // Center: Tag + Name + Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored tag
                Container(
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: tagText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.name.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: textCol,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${task.sets} Sets x ${task.reps} Reps'
                  '${task.tempo != null && task.tempo!.isNotEmpty ? " • Tempo ${task.tempo}" : ""}'
                  '${task.restSeconds != null ? " • Rest ${task.restSeconds}s" : ""}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: mutedCol,
                  ),
                ),
              ],
            ),
          ),

          // Right Side: Action Menu Button
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: mutedCol, size: 20),
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            onSelected: (val) {
              if (val == 'edit') {
                onEdit();
              } else if (val == 'remove') {
                onRemove();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(
                  'EDIT PROTOCOL',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: textCol),
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Text(
                  'REMOVE',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rest Day Placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _RestDayPlaceholder extends StatelessWidget {
  final Color mutedCol;
  const _RestDayPlaceholder({required this.mutedCol});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nightlight_round, size: 40, color: mutedCol),
            const SizedBox(height: 12),
            Text(
              'REST DAY • NO TASKS SCHEDULED',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: mutedCol,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Protocol Button
// ─────────────────────────────────────────────────────────────────────────────

class _AddProtocolButton extends StatelessWidget {
  final DraftDayPlan day;
  final Color textCol;
  final Color borderCol;
  final ValueChanged<DraftTask> onAdd;

  const _AddProtocolButton({
    required this.day,
    required this.textCol,
    required this.borderCol,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () async {
          final task = await Navigator.of(context).push<DraftTask>(
            MaterialPageRoute(
              builder: (_) => ProtocolFormPage(
                nextSequenceIndex: day.tasks.length + 1,
              ),
            ),
          );
          if (task != null) onAdd(task);
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: textCol),
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 16, color: textCol),
              const SizedBox(width: 6),
              Text(
                'ADD NEW PROTOCOL',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: textCol,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Projected Intensity Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectedIntensitySection extends StatelessWidget {
  final List<DraftDayPlan> days;
  final Color textCol;
  final Color mutedCol;
  final Color borderCol;
  final bool isDark;

  const _ProjectedIntensitySection({
    required this.days,
    required this.textCol,
    required this.mutedCol,
    required this.borderCol,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Generate height calculations for each day
    final heights = <double>[];
    for (int i = 0; i < 7; i++) {
      if (days[i].isRestDay) {
        heights.add(0.0);
      } else {
        // Base height on task count
        final tasks = days[i].tasks.length;
        if (tasks == 0) {
          heights.add(10.0);
        } else {
          final h = 15.0 + (tasks * 18.0);
          heights.add(h > 94.0 ? 94.0 : h);
        }
      }
    }

    // Peak volume logic: find index with maximum tasks, default to day 5 (index 4) if all equal
    int peakIndex = 4;
    double maxVal = -1;
    for (int i = 0; i < 7; i++) {
      if (heights[i] > maxVal) {
        maxVal = heights[i];
        peakIndex = i;
      }
    }

    final barColorUnselected = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);
    final barColorSelected = isDark ? const Color(0xFF22D3EE) : const Color(0xFF0E7490);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROJECTED INTENSITY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: mutedCol,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: borderCol),
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final isPeak = i == peakIndex;
                    final h = heights[i];

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 100,
                          alignment: Alignment.bottomCenter,
                          color: isDark ? const Color(0xFF181818) : const Color(0xFFF1F1F1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 14,
                            height: h,
                            color: isPeak ? barColorSelected : barColorUnselected,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'D${i + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isPeak ? barColorSelected : mutedCol,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  'PEAK VOLUME DETECTED ON DAY ${peakIndex + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: textCol,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Action Bar (Score & Save Button)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final String workoutProfileId;
  final WeekPlanCreatorEditing state;
  final Color textCol;
  final Color cardColor;
  final Color borderCol;

  const _BottomActionBar({
    required this.workoutProfileId,
    required this.state,
    required this.textCol,
    required this.cardColor,
    required this.borderCol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSave = state.planName.trim().isNotEmpty;
    final boltColor = isDark ? const Color(0xFF22C55E) : const Color(0xFF15803D);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(top: BorderSide(color: borderCol)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Left Side: Score & Lightning Icon
            Row(
              children: [
                Icon(Icons.bolt, color: boltColor, size: 24),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '94% EST',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textCol,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'METABOLIC LOAD',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: textCol.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // Right Side: Save Button (Strict 0px Solid Button)
            GestureDetector(
              onTap: canSave
                  ? () => context.read<WeekPlanCreatorCubit>().savePlan(workoutProfileId)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: canSave ? textCol : textCol.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'SAVE PLAN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: canSave ? cardColor : textCol.withValues(alpha: 0.3),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
