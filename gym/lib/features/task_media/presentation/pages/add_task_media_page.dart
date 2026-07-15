import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/add_task_media_cubit.dart';
import '../cubit/add_task_media_state.dart';

/// Full-screen upload form. Expects an [AddTaskMediaCubit] provided above it.
/// Pops with the created `TaskMedia` on success.
class AddTaskMediaPage extends StatefulWidget {
  const AddTaskMediaPage({super.key});

  @override
  State<AddTaskMediaPage> createState() => _AddTaskMediaPageState();
}

class _AddTaskMediaPageState extends State<AddTaskMediaPage> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _keywordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _keywordCtrl.dispose();
    super.dispose();
  }

  void _submitKeyword(AddTaskMediaCubit cubit) {
    final text = _keywordCtrl.text.trim();
    if (text.isEmpty) return;
    cubit.addKeyword(text);
    _keywordCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black;
    final mutedCol = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    return BlocConsumer<AddTaskMediaCubit, AddTaskMediaState>(
      listenWhen: (prev, curr) => prev.created != curr.created || prev.error != curr.error,
      listener: (context, state) {
        if (state.created != null) {
          Navigator.of(context).pop(state.created);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!.toUpperCase()),
              backgroundColor: const Color(0xFFBA1A1A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddTaskMediaCubit>();

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textCol, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'ADD TASK MEDIA',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textCol,
                letterSpacing: 1.5,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── MEDIA PREVIEW / PICKER ──────────────────────────────────
                _MediaPreview(
                  file: state.file,
                  textCol: textCol,
                  mutedCol: mutedCol,
                  cardColor: cardColor,
                  borderCol: borderCol,
                  isDark: isDark,
                  onPick: cubit.pickFile,
                ),
                const SizedBox(height: 24),

                // ── NAME ────────────────────────────────────────────────────
                _SectionLabel('NAME *', mutedCol),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  onChanged: cubit.updateName,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textCol,
                  ),
                  decoration: _fieldDecoration('Enter media name', mutedCol),
                ),
                const SizedBox(height: 20),

                // ── DESCRIPTION ─────────────────────────────────────────────
                _SectionLabel('DESCRIPTION', mutedCol),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  onChanged: cubit.updateDescription,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 13, color: textCol),
                  decoration: _fieldDecoration('Brief explanation of the movement...', mutedCol),
                ),
                const SizedBox(height: 20),

                // ── KEYWORDS ────────────────────────────────────────────────
                _SectionLabel('KEYWORDS', mutedCol),
                const SizedBox(height: 8),
                if (state.keywords.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.keywords
                        .map((k) => _KeywordChip(
                              label: k,
                              textCol: textCol,
                              borderCol: borderCol,
                              onRemove: () => cubit.removeKeyword(k),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keywordCtrl,
                        onSubmitted: (_) => _submitKeyword(cubit),
                        textInputAction: TextInputAction.done,
                        style: GoogleFonts.inter(fontSize: 13, color: textCol),
                        decoration: _fieldDecoration('Add keyword…', mutedCol),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _submitKeyword(cubit),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: textCol),
                          borderRadius: BorderRadius.zero,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ADD TAG',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: textCol,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── MAKE PRIVATE ────────────────────────────────────────────
                GestureDetector(
                  onTap: cubit.toggleIsPrivate,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: state.isPrivate,
                        onChanged: (_) => cubit.toggleIsPrivate(),
                        activeColor: textCol,
                        checkColor: cardColor,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              'MAKE PRIVATE',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: textCol,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Private assets are only visible to your account.',
                              style: GoogleFonts.inter(fontSize: 11, color: mutedCol),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: GestureDetector(
                onTap: state.canSubmit ? cubit.submit : null,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  color: state.canSubmit ? textCol : textCol.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: state.isSubmitting
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: cardColor),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SAVE',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: state.canSubmit ? cardColor : textCol.withValues(alpha: 0.3),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: state.canSubmit ? cardColor : textCol.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _fieldDecoration(String hint, Color mutedCol) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 11, color: mutedCol),
      border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MediaPreview extends StatelessWidget {
  final PlatformFile? file;
  final Color textCol;
  final Color mutedCol;
  final Color cardColor;
  final Color borderCol;
  final bool isDark;
  final VoidCallback onPick;

  const _MediaPreview({
    required this.file,
    required this.textCol,
    required this.mutedCol,
    required this.cardColor,
    required this.borderCol,
    required this.isDark,
    required this.onPick,
  });

  bool get _isImage {
    final ext = file?.extension?.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'gif' || ext == 'webp';
  }

  String _sizeLabel(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    final f = file;
    if (f == null) {
      return GestureDetector(
        onTap: onPick,
        child: Container(
          width: double.infinity,
          height: 180,
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF1F1F1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 32, color: mutedCol),
              const SizedBox(height: 12),
              Text(
                'TAP TO SELECT IMAGE, VIDEO OR GIF',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: textCol,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'MP4, MOV, JPG, PNG OR GIF · MAX 25MB',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: mutedCol,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF1F1F1),
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isImage && f.path != null)
            Image.file(File(f.path!), fit: BoxFit.cover)
          else
            Center(
              child: Icon(
                _isImage ? Icons.image_outlined : Icons.videocam_outlined,
                size: 40,
                color: mutedCol,
              ),
            ),
          // File name + size chip (bottom-left)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textCol,
                    ),
                  ),
                  Text(
                    _sizeLabel(f.size),
                    style: GoogleFonts.inter(fontSize: 9, color: mutedCol),
                  ),
                ],
              ),
            ),
          ),
          // REPLACE button (bottom-right)
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: textCol,
                child: Text(
                  'REPLACE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: cardColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  final Color textCol;
  final Color borderCol;
  final VoidCallback onRemove;

  const _KeywordChip({
    required this.label,
    required this.textCol,
    required this.borderCol,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: textCol),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 1.5,
      ),
    );
  }
}
