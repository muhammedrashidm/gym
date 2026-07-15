import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../task_media/domain/entities/task_media.dart';
import '../../../task_media/presentation/cubit/task_media_picker_cubit.dart';
import '../../../task_media/presentation/widgets/task_media_picker_sheet.dart';
import '../../domain/value_objects/draft_task.dart';
import '../../domain/value_objects/draft_task_attachment.dart';

/// A push-and-return screen that collects task data.
/// Returns a [DraftTask] via [Navigator.pop] when the user taps SAVE TO PLAN.
/// Pass [existingTask] to pre-fill fields for editing.
class ProtocolFormPage extends StatefulWidget {
  final DraftTask? existingTask;
  final int nextSequenceIndex;

  const ProtocolFormPage({
    super.key,
    this.existingTask,
    required this.nextSequenceIndex,
  });

  @override
  State<ProtocolFormPage> createState() => _ProtocolFormPageState();
}

class _ProtocolFormPageState extends State<ProtocolFormPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _machineCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _setsCtrl;
  late final TextEditingController _repsCtrl;
  late final TextEditingController _restCtrl;
  late final TextEditingController _tempoCtrl;

  final _formKey = GlobalKey<FormState>();

  late List<DraftTaskAttachment> _attachments;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _machineCtrl = TextEditingController(text: t?.machineDetails ?? '');
    _notesCtrl = TextEditingController(text: t?.notes ?? '');
    _setsCtrl = TextEditingController(text: t != null ? '${t.sets}' : '0');
    _repsCtrl = TextEditingController(text: t?.reps ?? '8-12');
    _restCtrl = TextEditingController(text: t?.restSeconds != null ? '${t!.restSeconds}' : '90');
    _tempoCtrl = TextEditingController(text: t?.tempo ?? '3-0-1-0');
    _attachments = List<DraftTaskAttachment>.from(t?.attachments ?? const []);
  }

  Future<void> _openMediaPicker() async {
    final result = await showModalBottomSheet<List<TaskMedia>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => TaskMediaPickerCubit(
          getIt<Mediator>(),
          preselected: _attachments.map((a) => a.media).toList(),
        )..search(),
        child: const TaskMediaPickerSheet(),
      ),
    );
    if (result == null || !mounted) return;

    // Preserve any existing captions when the same media is re-confirmed,
    // and re-sequence 1-based to match the backend's TaskAttachmentInputDto.
    final prev = {for (final a in _attachments) a.taskMediaId: a};
    setState(() {
      _attachments = result
          .asMap()
          .entries
          .map((e) => DraftTaskAttachment(
                media: e.value,
                caption: prev[e.value.id]?.caption,
                sequenceIndex: e.key + 1,
              ))
          .toList();
    });
  }

  void _removeAttachment(String taskMediaId) {
    setState(() {
      final remaining = _attachments.where((a) => a.taskMediaId != taskMediaId).toList();
      _attachments = remaining
          .asMap()
          .entries
          .map((e) => e.value.copyWith(sequenceIndex: e.key + 1))
          .toList();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _machineCtrl.dispose();
    _notesCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _restCtrl.dispose();
    _tempoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final task = DraftTask(
      localId: widget.existingTask?.localId,
      sequenceIndex: widget.existingTask?.sequenceIndex ?? widget.nextSequenceIndex,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      machineDetails: _machineCtrl.text.trim().isEmpty ? null : _machineCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      sets: int.tryParse(_setsCtrl.text.trim()) ?? 0,
      reps: _repsCtrl.text.trim(),
      restSeconds: int.tryParse(_restCtrl.text.trim()),
      tempo: _tempoCtrl.text.trim().isEmpty ? null : _tempoCtrl.text.trim(),
      attachments: _attachments,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black;
    final mutedCol = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

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
          _isEditing ? 'EDIT PROTOCOL' : 'NEW PROTOCOL',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: textCol,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          // User Avatar Placeholder on Right
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: borderCol,
              child: Icon(Icons.person, size: 16, color: mutedCol),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── EXERCISE NAME ──────────────────────────────────────────────
              _SectionLabel('EXERCISE NAME', mutedCol),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'REQUIRED' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Pendulum Squat',
                  hintStyle: GoogleFonts.inter(fontSize: 11, color: mutedCol),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),

              // ── DESCRIPTION ────────────────────────────────────────────────
              _SectionLabel('DESCRIPTION', mutedCol),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                style: GoogleFonts.inter(fontSize: 13, color: textCol),
                decoration: InputDecoration(
                  hintText: 'Brief biomechanical intent...',
                  hintStyle: GoogleFonts.inter(fontSize: 11, color: mutedCol),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),

              // ── MACHINE DETAILS / SETUP ────────────────────────────────────
              _SectionLabel('MACHINE DETAILS / SETUP', mutedCol),
              const SizedBox(height: 6),
              TextFormField(
                controller: _machineCtrl,
                maxLines: 2,
                style: GoogleFonts.inter(fontSize: 13, color: textCol),
                decoration: InputDecoration(
                  hintText: 'Seat height: 4, Foot plate: Low, Safety pin: 2...',
                  hintStyle: GoogleFonts.inter(fontSize: 11, color: mutedCol),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),

              // ── TRAINER NOTES ──────────────────────────────────────────────
              _SectionLabel('TRAINER NOTES', mutedCol),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                style: GoogleFonts.inter(fontSize: 13, color: textCol),
                decoration: InputDecoration(
                  hintText: 'Focus on slow eccentric, pause at bottom, chin tucked...',
                  hintStyle: GoogleFonts.inter(fontSize: 11, color: mutedCol),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 24),

              // ── SET DETAILS GRID (2x2) ─────────────────────────────────────
              _SectionLabel('SET DETAILS', mutedCol),
              const SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SETS',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: textCol),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _setsCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: textCol),
                              validator: (v) => (int.tryParse(v ?? '') == null) ? 'NUMBER REQUIRED' : null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REPS',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: textCol),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _repsCtrl,
                              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: textCol),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'REQUIRED' : null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REST (SEC)',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: textCol),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _restCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: textCol),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TEMPO',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: textCol),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _tempoCtrl,
                              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: textCol),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── ATTACH MEDIA ───────────────────────────────────────────────
              Row(
                children: [
                  _SectionLabel('ATTACH MEDIA', mutedCol),
                  if (_attachments.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${_attachments.length})',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: textCol,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              if (_attachments.isNotEmpty) ...[
                ..._attachments.map((a) => _AttachmentCard(
                      attachment: a,
                      textCol: textCol,
                      mutedCol: mutedCol,
                      cardColor: cardColor,
                      borderCol: borderCol,
                      isDark: isDark,
                      onRemove: () => _removeAttachment(a.taskMediaId),
                    )),
                const SizedBox(height: 8),
              ],
              GestureDetector(
                onTap: _openMediaPicker,
                child: CustomPaint(
                  painter: _DashedBorderPainter(color: borderCol),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.add, size: 24, color: mutedCol),
                        const SizedBox(height: 10),
                        Text(
                          _attachments.isEmpty
                              ? 'SELECT EXERCISE REFERENCE PHOTOS OR VIDEOS'
                              : 'ADD OR EDIT ATTACHED MEDIA',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: textCol,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MP4, MOV, OR JPG',
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
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: GestureDetector(
            onTap: _submit,
            child: Container(
              height: 50,
              width: double.infinity,
              color: textCol,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(
                'SAVE TO PLAN',
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

class _AttachmentCard extends StatelessWidget {
  final DraftTaskAttachment attachment;
  final Color textCol;
  final Color mutedCol;
  final Color cardColor;
  final Color borderCol;
  final bool isDark;
  final VoidCallback onRemove;

  const _AttachmentCard({
    required this.attachment,
    required this.textCol,
    required this.mutedCol,
    required this.cardColor,
    required this.borderCol,
    required this.isDark,
    required this.onRemove,
  });

  IconData get _typeIcon {
    switch (attachment.media.type.toUpperCase()) {
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
    final media = attachment.media;
    final thumbBg = isDark ? const Color(0xFF121212) : const Color(0xFFF1F1F1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: thumbBg,
              border: Border.all(color: borderCol),
              borderRadius: BorderRadius.zero,
            ),
            clipBehavior: Clip.hardEdge,
            child: media.type.toUpperCase() == 'VIDEO'
                ? Icon(_typeIcon, size: 18, color: mutedCol)
                : Image.network(
                    media.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(_typeIcon, size: 18, color: mutedCol),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: textCol,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      media.type.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: mutedCol,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (media.isPrivate) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.lock, size: 9, color: mutedCol),
                      const SizedBox(width: 2),
                      Text(
                        'PRIVATE',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: mutedCol,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: mutedCol),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    // Draw top
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Draw right
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Draw bottom
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
    // Draw left
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
