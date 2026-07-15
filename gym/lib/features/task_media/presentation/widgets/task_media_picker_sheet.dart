import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/task_media.dart';
import '../cubit/add_task_media_cubit.dart';
import '../cubit/task_media_picker_cubit.dart';
import '../cubit/task_media_picker_state.dart';
import '../pages/add_task_media_page.dart';

/// Bottom-sheet picker to search and multi-select library [TaskMedia]. Expects
/// a [TaskMediaPickerCubit] provided above it (pre-seeded with any already
/// attached media). Pops with the selected `List<TaskMedia>` on ATTACH.
class TaskMediaPickerSheet extends StatefulWidget {
  const TaskMediaPickerSheet({super.key});

  @override
  State<TaskMediaPickerSheet> createState() => _TaskMediaPickerSheetState();
}

class _TaskMediaPickerSheetState extends State<TaskMediaPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<TaskMediaPickerCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAddMedia(BuildContext context) async {
    final pickerCubit = context.read<TaskMediaPickerCubit>();
    final created = await Navigator.of(context).push<TaskMedia>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AddTaskMediaCubit(getIt<Mediator>()),
          child: const AddTaskMediaPage(),
        ),
      ),
    );
    if (created != null) {
      pickerCubit.addLocallyCreated(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black;
    final mutedCol = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    final cubit = context.read<TaskMediaPickerCubit>();

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
                      'TASK MEDIA LIBRARY',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textCol,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openAddMedia(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: textCol),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: textCol),
                          const SizedBox(width: 4),
                          Text(
                            'ADD MEDIA',
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
                  hintText: 'Search assets…',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: mutedCol),
                  prefixIcon: Icon(Icons.search, size: 18, color: mutedCol),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── MY ASSETS ONLY filter ───────────────────────────────────────
            BlocBuilder<TaskMediaPickerCubit, TaskMediaPickerState>(
              buildWhen: (p, c) => p.mineOnly != c.mineOnly,
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: state.mineOnly,
                        onChanged: (_) => cubit.toggleMineOnly(),
                        activeColor: textCol,
                        checkColor: cardColor,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        'MY ASSETS ONLY',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: textCol,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 4),

            // ── Results list ────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<TaskMediaPickerCubit, TaskMediaPickerState>(
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
                      label: 'NO MEDIA FOUND',
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
                      final media = state.items[i];
                      return _MediaRow(
                        media: media,
                        selected: state.isSelected(media.id),
                        textCol: textCol,
                        mutedCol: mutedCol,
                        cardColor: cardColor,
                        borderCol: borderCol,
                        isDark: isDark,
                        onTap: () => cubit.toggleSelect(media),
                      );
                    },
                  );
                },
              ),
            ),

            // ── ATTACH (n) button ───────────────────────────────────────────
            BlocBuilder<TaskMediaPickerCubit, TaskMediaPickerState>(
              buildWhen: (p, c) => p.selectedCount != c.selectedCount,
              builder: (context, state) {
                final count = state.selectedCount;
                final enabled = count > 0;
                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: GestureDetector(
                      onTap: enabled
                          ? () => Navigator.of(context).pop(state.selected.values.toList())
                          : null,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        color: enabled ? textCol : textCol.withValues(alpha: 0.1),
                        alignment: Alignment.center,
                        child: Text(
                          'ATTACH ($count)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: enabled ? cardColor : textCol.withValues(alpha: 0.3),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MediaRow extends StatelessWidget {
  final TaskMedia media;
  final bool selected;
  final Color textCol;
  final Color mutedCol;
  final Color cardColor;
  final Color borderCol;
  final bool isDark;
  final VoidCallback onTap;

  const _MediaRow({
    required this.media,
    required this.selected,
    required this.textCol,
    required this.mutedCol,
    required this.cardColor,
    required this.borderCol,
    required this.isDark,
    required this.onTap,
  });

  IconData get _typeIcon {
    switch (media.type.toUpperCase()) {
      case 'VIDEO':
        return Icons.videocam_outlined;
      case 'GIF':
        return Icons.gif_box_outlined;
      default:
        return Icons.image_outlined;
    }
  }

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
            // Leading checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                activeColor: textCol,
                checkColor: cardColor,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),

            // Thumbnail
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: thumbBg,
                border: Border.all(color: borderCol),
                borderRadius: BorderRadius.zero,
              ),
              clipBehavior: Clip.hardEdge,
              child: media.type.toUpperCase() == 'VIDEO'
                  ? Icon(_typeIcon, size: 20, color: mutedCol)
                  : Image.network(
                      media.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(_typeIcon, size: 20, color: mutedCol),
                    ),
            ),
            const SizedBox(width: 12),

            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    media.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textCol,
                    ),
                  ),
                  if (media.description != null && media.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      media.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 10, color: mutedCol),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Badge(
                  label: media.type.toUpperCase(),
                  bg: thumbBg,
                  fg: mutedCol,
                ),
                if (media.isPrivate) ...[
                  const SizedBox(height: 4),
                  _Badge(
                    label: 'PRIVATE',
                    bg: textCol,
                    fg: cardColor,
                    icon: Icons.lock,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _Badge({required this.label, required this.bg, required this.fg, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: bg,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
