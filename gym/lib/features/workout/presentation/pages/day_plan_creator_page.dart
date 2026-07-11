import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../cubit/day_plan_creator/day_plan_creator_cubit.dart';
import '../cubit/day_plan_creator/day_plan_creator_state.dart';

class DayPlanCreatorPageProps{
  final String clientId;
  final String weeklyPlanId;

  DayPlanCreatorPageProps({required this.clientId, required this.weeklyPlanId});
}
class DayPlanCreatorPage extends StatelessWidget {
 final DayPlanCreatorPageProps pageProps;

  const DayPlanCreatorPage({
    super.key,
    required this.pageProps,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DayPlanCreatorCubit(getIt())..loadPlan(pageProps.weeklyPlanId),
      child: DayPlanCreatorView(clientId: pageProps.clientId, weeklyPlanId:pageProps. weeklyPlanId),
    );
  }
}

class DayPlanCreatorView extends StatefulWidget {
  final String clientId;
  final String weeklyPlanId;

  const DayPlanCreatorView({
    super.key,
    required this.clientId,
    required this.weeklyPlanId,
  });

  @override
  State<DayPlanCreatorView> createState() => _DayPlanCreatorViewState();
}

class _DayPlanCreatorViewState extends State<DayPlanCreatorView> {
  // Local state to keep track of expanded task IDs
  final Set<String> _expandedTaskIds = {};

  void _toggleExpand(String taskId) {
    setState(() {
      if (_expandedTaskIds.contains(taskId)) {
        _expandedTaskIds.remove(taskId);
      } else {
        _expandedTaskIds.add(taskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);
    final mutedColor = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'DAY PLAN CREATOR',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<DayPlanCreatorCubit, DayPlanCreatorState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ERROR LOADING PLAN',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 10, color: mutedColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: cardColor,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () => context.read<DayPlanCreatorCubit>().loadPlan(widget.weeklyPlanId),
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
            ),
            loaded: (weeklyPlan, selectedDayIndex) {
              final dayPlans = weeklyPlan.dayPlans;
              final selectedDayPlan = dayPlans[selectedDayIndex];
              final sortedTasks = List.from(selectedDayPlan.tasks)
                ..sort((a, b) => a.sequenceIndex.compareTo(b.sequenceIndex));

              return Column(
                children: [
                  // Day Tabs Row (7 Days)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEEKLY PLAN • 7 FIXED DAYS',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: mutedColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(7, (index) {
                            final dp = dayPlans[index];
                            final isSelected = selectedDayIndex == index;
                            final taskCount = dp.tasks.length;
                            final isRest = dp.isRestDay;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<DayPlanCreatorCubit>().selectDay(index),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? textColor
                                        : (isRest ? Colors.transparent : cardColor),
                                    border: Border.all(
                                      color: isSelected
                                          ? textColor
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
                                          color: isSelected
                                              ? cardColor
                                              : (isRest ? mutedColor : textColor),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isRest ? 'REST' : '$taskCount T',
                                        style: GoogleFonts.inter(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? cardColor.withValues(alpha: 0.8)
                                              : mutedColor,
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
                  ),

                  const SizedBox(height: 16),

                  // Day Config Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'DAY ${selectedDayIndex + 1}',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (selectedDayPlan.isRestDay)
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2),
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                child: Text(
                                  'REST DAY',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Rest Day Toggle
                        GestureDetector(
                          onTap: () {
                            context.read<DayPlanCreatorCubit>().toggleRestDay(
                                  dayPlanId: selectedDayPlan.id,
                                  isRestDay: !selectedDayPlan.isRestDay,
                                  weeklyPlanId: widget.weeklyPlanId,
                                );
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: selectedDayPlan.isRestDay,
                                onChanged: (val) {
                                  context.read<DayPlanCreatorCubit>().toggleRestDay(
                                        dayPlanId: selectedDayPlan.id,
                                        isRestDay: val ?? false,
                                        weeklyPlanId: widget.weeklyPlanId,
                                      );
                                },
                                activeColor: textColor,
                                checkColor: cardColor,
                              ),
                              Text(
                                'REST DAY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Day Label TextField (e.g. "Leg Day", "Push Day")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      initialValue: selectedDayPlan.label ?? '',
                      key: ValueKey('${selectedDayPlan.id}_label'),
                      onFieldSubmitted: (val) {
                        context.read<DayPlanCreatorCubit>().updateDayLabel(
                              dayPlanId: selectedDayPlan.id,
                              label: val.trim().isEmpty ? '' : val.trim(),
                              weeklyPlanId: widget.weeklyPlanId,
                            );
                      },
                      style: GoogleFonts.manrope(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ADD LABEL (E.G. LEG DAY / PUSH DAY)...',
                        hintStyle: GoogleFonts.inter(
                          color: mutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tasks or Rest Day Empty State
                  Expanded(
                    child: selectedDayPlan.isRestDay
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.nightlight_round, size: 40, color: mutedColor),
                                const SizedBox(height: 12),
                                Text(
                                  'REST DAY • NO TASKS SCHEDULED',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: mutedColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                context.read<DayPlanCreatorCubit>().loadPlan(widget.weeklyPlanId),
                            color: textColor,
                            backgroundColor: cardColor,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              children: [
                                if (sortedTasks.isEmpty) ...[
                                  Container(
                                    height: 150,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'NO TASKS FOR THIS DAY YET',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: mutedColor,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  ...sortedTasks.map((task) {
                                    final isExpanded = _expandedTaskIds.contains(task.id);
                                    return _buildTaskCard(
                                      context: context,
                                      task: task,
                                      isExpanded: isExpanded,
                                      cardColor: cardColor,
                                      textColor: textColor,
                                      mutedColor: mutedColor,
                                      borderCol: borderCol,
                                      isDark: isDark,
                                    );
                                  }),
                                ],
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => _showTaskDialog(context, dayPlanId: selectedDayPlan.id, nextSequence: sortedTasks.length + 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: textColor),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, size: 16, color: textColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ADD TASK',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: textColor,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required dynamic task,
    required bool isExpanded,
    required Color cardColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderCol,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          // Header Row (Clickable to toggle expand)
          GestureDetector(
            onTap: () => _toggleExpand(task.id),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.zero,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${task.sequenceIndex}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${task.sets} SETS × ${task.reps} REPS',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: mutedColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Details Section (Visible when expanded)
          if (isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderCol, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.tempo != null && task.tempo!.isNotEmpty) ...[
                    _buildDetailRow('TEMPO', task.tempo!, Icons.speed, mutedColor, textColor),
                    const SizedBox(height: 8),
                  ],
                  if (task.restSeconds != null && task.restSeconds! > 0) ...[
                    _buildDetailRow('REST TIME', '${task.restSeconds} SECONDS', Icons.timer, mutedColor, textColor),
                    const SizedBox(height: 8),
                  ],
                  _buildDetailRow('MACHINE / SETUP', task.machineDetails ?? 'N/A', Icons.settings, mutedColor, textColor),
                  if (task.notes != null && task.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('NOTES', task.notes!, Icons.notes, mutedColor, textColor),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showTaskDialog(context, task: task),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: textColor),
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text(
                              'EDIT TASK',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _confirmDeleteTask(context, task.id),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.redAccent),
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text(
                              'REMOVE',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color labelColor, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: labelColor),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: labelColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showTaskDialog(BuildContext context, {dynamic task, String? dayPlanId, int? nextSequence}) {
    final isEdit = task != null;
    final nameController = TextEditingController(text: isEdit ? task.name : '');
    final setsController = TextEditingController(text: isEdit ? '${task.sets}' : '3');
    final repsController = TextEditingController(text: isEdit ? task.reps : '10');
    final restController = TextEditingController(text: isEdit ? '${task.restSeconds ?? 60}' : '60');
    final tempoController = TextEditingController(text: isEdit ? (task.tempo ?? '') : '');
    final machineController = TextEditingController(text: isEdit ? (task.machineDetails ?? '') : '');
    final notesController = TextEditingController(text: isEdit ? (task.notes ?? '') : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          isEdit ? 'EDIT TASK' : 'ADD TASK',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'EXERCISE NAME',
                  labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'SETS',
                        labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      decoration: InputDecoration(
                        labelText: 'REPS',
                        labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: restController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'REST (SEC)',
                        labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: tempoController,
                      decoration: InputDecoration(
                        labelText: 'TEMPO (OPTIONAL)',
                        labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: machineController,
                decoration: InputDecoration(
                  labelText: 'MACHINE SETUP / STATION',
                  labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'NOTES',
                  labelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final sets = int.tryParse(setsController.text.trim()) ?? 3;
              final reps = repsController.text.trim();
              final rest = int.tryParse(restController.text.trim());
              final tempo = tempoController.text.trim();
              final machine = machineController.text.trim();
              final notes = notesController.text.trim();

              if (name.isNotEmpty && reps.isNotEmpty) {
                Navigator.pop(ctx);
                if (isEdit) {
                  context.read<DayPlanCreatorCubit>().updateTask(
                        taskId: task.id,
                        name: name,
                        sets: sets,
                        reps: reps,
                        restSeconds: rest,
                        tempo: tempo.isEmpty ? null : tempo,
                        machineDetails: machine.isEmpty ? null : machine,
                        notes: notes.isEmpty ? null : notes,
                        weeklyPlanId: widget.weeklyPlanId,
                      );
                } else {
                  context.read<DayPlanCreatorCubit>().createTask(
                        dayPlanId: dayPlanId!,
                        name: name,
                        sets: sets,
                        reps: reps,
                        restSeconds: rest,
                        tempo: tempo.isEmpty ? null : tempo,
                        machineDetails: machine.isEmpty ? null : machine,
                        notes: notes.isEmpty ? null : notes,
                        sequenceIndex: nextSequence ?? 1,
                        weeklyPlanId: widget.weeklyPlanId,
                      );
                }
              }
            },
            child: Text(
              isEdit ? 'SAVE' : 'ADD',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'REMOVE TASK',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to remove this task from the day plan?',
          style: GoogleFonts.inter(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DayPlanCreatorCubit>().deleteTask(
                    taskId: taskId,
                    weeklyPlanId: widget.weeklyPlanId,
                  );
            },
            child: Text(
              'REMOVE',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
