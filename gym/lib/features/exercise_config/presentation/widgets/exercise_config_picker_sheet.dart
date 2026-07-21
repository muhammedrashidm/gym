import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/exercise_config.dart';
import '../cubit/exercise_config_picker_cubit.dart';
import '../cubit/exercise_config_picker_state.dart';

/// The sheet's confirm result. Wrapping the (nullable) choice is what lets the
/// caller tell "user confirmed no config" from "user dismissed the sheet": a
/// bare `null` pop result means dismissed, while an [ExerciseConfigSelection]
/// carrying a null [config] means explicitly cleared.
class ExerciseConfigSelection {
  final ExerciseConfig? config;
  const ExerciseConfigSelection(this.config);
}

/// Bottom-sheet picker to search and single-select an admin-curated
/// [ExerciseConfig]. Expects an [ExerciseConfigPickerCubit] provided above it
/// (pre-seeded with any already-selected config). Pops with an
/// [ExerciseConfigSelection] on SELECT.
class ExerciseConfigPickerSheet extends StatefulWidget {
  const ExerciseConfigPickerSheet({super.key});

  @override
  State<ExerciseConfigPickerSheet> createState() => _ExerciseConfigPickerSheetState();
}

class _ExerciseConfigPickerSheetState extends State<ExerciseConfigPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<ExerciseConfigPickerCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black;
    final mutedCol = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    final cubit = context.read<ExerciseConfigPickerCubit>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        color: bg,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Grab handle
            Container(width: 40, height: 4, color: borderCol),
            const SizedBox(height: 16),

            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'SELECT AI CONFIGURATION',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textCol,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search field ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: cubit.search,
                style: GoogleFonts.inter(fontSize: 13, color: textCol),
                decoration: InputDecoration(
                  hintText: 'Search configurations…',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: mutedCol),
                  prefixIcon: Icon(Icons.search, size: 18, color: mutedCol),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Results list ────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ExerciseConfigPickerCubit, ExerciseConfigPickerState>(
                builder: (context, state) {
                  if (state.isLoading && state.items.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(color: textCol, strokeWidth: 2),
                    );
                  }
                  if (state.error != null && state.items.isEmpty) {
                    return _EmptyState(
                      icon: Icons.error_outline,
                      label: state.error!.toUpperCase(),
                      mutedCol: mutedCol,
                    );
                  }
                  if (state.items.isEmpty) {
                    return _EmptyState(
                      icon: Icons.folder_open,
                      label: 'NO CONFIGURATIONS FOUND',
                      mutedCol: mutedCol,
                    );
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= state.items.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: mutedCol),
                            ),
                          ),
                        );
                      }
                      final config = state.items[i];
                      final selected = state.isSelected(config.id);
                      return _ConfigRow(
                        config: config,
                        selected: selected,
                        textCol: textCol,
                        mutedCol: mutedCol,
                        cardColor: cardColor,
                        borderCol: borderCol,
                        isDark: isDark,
                        // Re-tapping the selected row clears it.
                        onTap: () => selected
                            ? cubit.clearSelection()
                            : cubit.selectSingle(config),
                      );
                    },
                  );
                },
              ),
            ),

            // ── SELECT button (always enabled — "no config" is valid) ───────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(
                    ExerciseConfigSelection(cubit.state.selected),
                  ),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    color: textCol,
                    alignment: Alignment.center,
                    child: Text(
                      'SELECT',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: cardColor,
                        letterSpacing: 1.0,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────

class _ConfigRow extends StatelessWidget {
  final ExerciseConfig config;
  final bool selected;
  final Color textCol;
  final Color mutedCol;
  final Color cardColor;
  final Color borderCol;
  final bool isDark;
  final VoidCallback onTap;

  const _ConfigRow({
    required this.config,
    required this.selected,
    required this.textCol,
    required this.mutedCol,
    required this.cardColor,
    required this.borderCol,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbBg = isDark ? const Color(0xFF121212) : const Color(0xFFF1F1F1);
    final selectedTint = isDark
        ? textCol.withValues(alpha: 0.08)
        : textCol.withValues(alpha: 0.04);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected ? selectedTint : cardColor,
          border: Border.all(
            color: selected ? textCol : borderCol,
            width: selected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.zero,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading radio — single-select affordance
            SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? textCol : mutedCol,
              ),
            ),
            const SizedBox(width: 10),

            // Thumbnail — configs are always video/gif, so no still-image case
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: thumbBg,
                border: Border.all(color: borderCol),
                borderRadius: BorderRadius.zero,
              ),
              clipBehavior: Clip.hardEdge,
              child: Icon(Icons.videocam_outlined, size: 20, color: mutedCol),
            ),
            const SizedBox(width: 12),

            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    config.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textCol,
                    ),
                  ),
                  if (config.description != null && config.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      config.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 10, color: mutedCol),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Analyzer-type badge
            _Badge(
              label: analyzerTypeLabel(config.analyzerType),
              bg: thumbBg,
              fg: mutedCol,
            ),
          ],
        ),
      ),
    );
  }
}

/// "DYNAMIC_REP" → "DYNAMIC REP" — the wire enum is kept raw on the entity, so
/// the display formatting lives here.
String analyzerTypeLabel(String analyzerType) =>
    analyzerType.toUpperCase().replaceAll('_', ' ');

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: bg,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color mutedCol;

  const _EmptyState({required this.icon, required this.label, required this.mutedCol});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: mutedCol),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: mutedCol,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
