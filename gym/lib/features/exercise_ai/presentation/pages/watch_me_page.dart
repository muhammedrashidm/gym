import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../exercise_config/domain/entities/exercise_config.dart';
import '../../domain/session/set_coach.dart';
import '../../domain/session/set_plan.dart';
import '../cubit/watch_me_cubit.dart';
import '../cubit/watch_me_state.dart';
import '../widgets/pose_overlay_painter.dart';

/// Live AI form-coaching page. Receives the PRE-FETCHED [ExerciseConfig]
/// (aiConfigJson already populated) plus the athlete's [SetPlan] as navigation
/// extras — no fetch here.
///
/// NOTE: This is a functional instrument screen (full-screen preview + skeleton
/// overlay + rep/score HUD + rest panel). No matching design exists in
/// `stitch_screens.md`; the visual layout is derived from the app's existing
/// palette and should be refined against a real design when one is available.
class WatchMePage extends StatefulWidget {
  final ExerciseConfig config;
  final SetPlan plan;
  const WatchMePage({super.key, required this.config, required this.plan});

  @override
  State<WatchMePage> createState() => _WatchMePageState();
}

class _WatchMePageState extends State<WatchMePage> {
  static const _sinewGreen = Color(0xFF34D399);
  static const _amber = Color(0xFFFBBF24);

  /// Guards the auto-pop when the coach finishes the session on its own.
  bool _popped = false;

  /// Last phase seen by the listener, for edge-triggered haptics.
  SetPhase? _lastPhase;

  /// Whether the camera plugin *already* mirrors the front-lens preview.
  ///
  /// `camera_avfoundation` never mirrors. `camera_android_camerax` mirrors only
  /// on its `ImageReaderRotatedPreview` path and not on the
  /// `SurfaceTextureRotatedPreview` one, and the selector
  /// (`SurfaceProducer.handlesCropAndRotation`) is not exposed to Dart — so
  /// this cannot be derived, only observed. `false` matches every device tested
  /// so far; the debug double-tap below flips it for a 5-second check on a new
  /// device, and if a device needs `true` this constant is the only thing to
  /// change.
  bool _pluginFlipsPreview = false;

  @override
  void initState() {
    super.initState();
    // The screen instructs the athlete to stand the phone in front of them, and
    // locking portrait keeps the preview transform and the ML Kit rotation
    // compensation in a single, verified configuration.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    context.read<WatchMeCubit>().start(widget.config, widget.plan);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _finish() async {
    if (_popped) return;
    final result = await context.read<WatchMeCubit>().finish();
    if (!mounted || _popped) return;
    _popped = true;
    context.pop(result);
  }

  /// Physical alarm for the two moments the athlete may not be looking at the
  /// screen: the set closing, and rest running out.
  void _onCoachPhase(SetPhase? previous, SetPhase current) {
    if (previous == current) return;
    switch (current) {
      case SetPhase.setComplete:
      case SetPhase.allSetsComplete:
        HapticFeedback.heavyImpact();
      case SetPhase.working:
        // Only a rest→work transition is the "go" alarm; the first set isn't.
        if (previous == SetPhase.resting) HapticFeedback.heavyImpact();
      case SetPhase.resting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<WatchMeCubit, WatchMeState>(
        listenWhen: (prev, curr) =>
            prev.coach?.phase != curr.coach?.phase ||
            prev.status != curr.status,
        listener: (context, state) {
          final phase = state.coach?.phase;
          if (phase != null) _onCoachPhase(_lastPhase, phase);
          _lastPhase = phase;
          // The coach auto-finishes after the last set; hand the results back.
          if (state.status == WatchMeStatus.finished && !_popped) {
            _popped = true;
            context.pop(state.result);
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case WatchMeStatus.initializing:
            case WatchMeStatus.finishing:
              return _Centered(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: _sinewGreen),
                    const SizedBox(height: 16),
                    Text(widget.config.name.toUpperCase(),
                        style: _label(Colors.white70)),
                  ],
                ),
              );
            case WatchMeStatus.permissionDenied:
              return _Message(
                title: 'CAMERA ACCESS NEEDED',
                body:
                    'Grant camera permission to use the AI form coach. Frames never leave your device.',
                actionLabel: 'OPEN SETTINGS',
                onAction: openAppSettings,
                onBack: () => context.pop(),
              );
            case WatchMeStatus.unsupportedConfig:
              return _Message(
                title: 'COACHING UNAVAILABLE',
                body:
                    'This exercise isn\'t set up for AI coaching yet. You can log it manually.\n\n${state.message ?? ''}',
                onBack: () => context.pop(),
              );
            case WatchMeStatus.error:
              return _Message(
                title: 'SOMETHING WENT WRONG',
                body: state.message ?? 'Unknown error',
                onBack: () => context.pop(),
              );
            case WatchMeStatus.running:
            case WatchMeStatus.finished:
              return _buildLive(context, state);
          }
        },
      ),
    );
  }

  Widget _buildLive(BuildContext context, WatchMeState state) {
    final camera = context.read<WatchMeCubit>().camera;
    final controller = camera.controller;
    final ready = controller != null && controller.value.isInitialized;

    // The upright (portrait) size of the preview. `previewSize` is reported in
    // sensor orientation, i.e. landscape, so the axes are swapped. The same
    // value feeds the preview box and the overlay so the two cannot drift.
    final previewSize = controller?.value.previewSize;
    final imageSize = previewSize == null
        ? const Size(1080, 1920)
        : Size(previewSize.height, previewSize.width);

    // Selfie view: the athlete should see themselves as in a gym mirror.
    // `mirror` describes the preview as *displayed*, which is what the painter
    // needs; `appFlip` is the flip this widget has to add on top of whatever
    // the plugin already did to make that true.
    final mirror = camera.lensDirection == CameraLensDirection.front;
    final appFlip = mirror != _pluginFlipsPreview;

    final coach = state.coach;
    final valid = state.frame?.poseValid ?? false;
    final overlayColor = valid ? _sinewGreen : _amber;

    assert(() {
      final detected = state.pose?.imageSize;
      if (detected != null) {
        final previewAspect = imageSize.width / imageSize.height;
        final detectedAspect = detected.width / detected.height;
        if ((previewAspect - detectedAspect).abs() > 0.01) {
          debugPrint('WatchMe: preview aspect $previewAspect != detection '
              'aspect $detectedAspect — overlay alignment will be off.');
        }
      }
      return true;
    }());

    return Stack(
      fit: StackFit.expand,
      children: [
        if (ready)
          GestureDetector(
            // Debug-only escape hatch for verifying `_pluginFlipsPreview` on a
            // device whose preview backend mirrors differently.
            onDoubleTap: kDebugMode
                ? () => setState(
                    () => _pluginFlipsPreview = !_pluginFlipsPreview)
                : null,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: imageSize.width,
                height: imageSize.height,
                child: appFlip
                    ? Transform.scale(scaleX: -1, child: CameraPreview(controller))
                    : CameraPreview(controller),
              ),
            ),
          )
        else
          const ColoredBox(color: Colors.black),

        // Skeleton overlay
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: PoseOverlayPainter(
                pose: state.pose,
                imageSize: imageSize,
                mirror: mirror,
                color: overlayColor,
              ),
            ),
          ),
        ),

        // Rest countdown — dims the preview so it reads from across the room.
        if (coach != null && coach.isResting)
          Positioned.fill(child: _restPanel(coach)),

        // Top HUD: set, rep count + score
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (coach != null) ...[
                  _hudStat('SET', '${coach.setIndex}/${coach.totalSets}'),
                  const SizedBox(width: 20),
                ],
                _hudStat('REPS', _repsLabel(state)),
                const SizedBox(width: 20),
                _hudStat('SCORE', state.overallScore.toStringAsFixed(0)),
                const Spacer(),
                IconButton(
                  onPressed: _finish,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Guidance / instruction banner
        if (coach == null || !coach.isResting)
          Positioned(
            left: 16,
            right: 16,
            bottom: 110,
            child: _banner(state),
          ),

        // Actions: end the current set (the only way out of an AMRAP set) and
        // end the whole session.
        Positioned(
          left: 24,
          right: 24,
          bottom: 32,
          child: SafeArea(
            child: Row(
              children: [
                if (_canEndSet(coach)) ...[
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () =>
                            context.read<WatchMeCubit>().endSet(),
                        child: Text('END SET',
                            style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sinewGreen,
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      onPressed: _finish,
                      child: Text('FINISH WORKOUT',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// An explicit "end set" only makes sense while working a set that the coach
  /// won't close by itself — an untargeted (AMRAP) set, or one the athlete
  /// wants to cut short.
  bool _canEndSet(SetCoachState? coach) =>
      coach != null && coach.phase == SetPhase.working;

  /// Reps in the current set, against the target when there is one.
  String _repsLabel(WatchMeState state) {
    final coach = state.coach;
    if (coach == null) return '${state.repCount}';
    final target = coach.targetLabel;
    return target == null
        ? '${coach.repsThisSet}'
        : '${coach.repsThisSet}/$target';
  }

  /// Full-screen rest countdown. Deliberately loud and low-detail — the phone
  /// is propped up a few metres away.
  Widget _restPanel(SetCoachState coach) {
    final remaining = coach.restRemaining;
    final mmss = '${remaining.inMinutes.toString().padLeft(2, '0')}:'
        '${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
    final next = coach.nextSetIndex;

    return ColoredBox(
      color: const Color(0xD9000000),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('REST', style: _label(Colors.white60)),
              const SizedBox(height: 8),
              Text(
                mmss,
                style: GoogleFonts.manrope(
                  color: _sinewGreen,
                  fontSize: 88,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              if (next != null)
                Text('SET $next OF ${coach.totalSets} NEXT',
                    style: _label(Colors.white70)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _restAction(
                    '+30s',
                    () => context.read<WatchMeCubit>().extendRest(),
                    filled: false,
                  ),
                  const SizedBox(width: 16),
                  _restAction(
                    'SKIP REST',
                    () => context.read<WatchMeCubit>().skipRest(),
                    filled: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restAction(String label, VoidCallback onTap, {required bool filled}) {
    final style = GoogleFonts.manrope(
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
      fontSize: 13,
    );
    final shape = const RoundedRectangleBorder(borderRadius: BorderRadius.zero);
    return SizedBox(
      height: 48,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _sinewGreen,
                foregroundColor: Colors.black,
                shape: shape,
              ),
              onPressed: onTap,
              child: Text(label, style: style),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: shape,
              ),
              onPressed: onTap,
              child: Text(label, style: style),
            ),
    );
  }

  Widget _banner(WatchMeState state) {
    final coach = state.coach;
    final guidance = state.frame?.guidance;
    final issues = state.frame?.activeIssues ?? const [];
    final String text;
    final Color bg;
    // Set status outranks form feedback: "you're done, stop" is the most
    // useful thing to say once the target is hit.
    if (coach != null && coach.phase == SetPhase.setComplete) {
      text = coach.isOvershooting
          ? "That's ${coach.repsThisSet} — your target was ${coach.targetLabel}. "
              'Rack it and rest.'
          : 'Set ${coach.setIndex} of ${coach.totalSets} done. Rest starting…';
      bg = coach.isOvershooting
          ? const Color(0xCC7C2D12)
          : const Color(0xCC065F46);
    } else if (guidance != null) {
      text = guidance.message;
      bg = const Color(0xCCB45309);
    } else if (issues.isNotEmpty) {
      text = issues.first.message;
      bg = const Color(0xCC7C2D12);
    } else {
      text = state.config?.camera.instruction ?? '';
      bg = const Color(0x99000000);
    }
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bg,
      child: Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _hudStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0x66000000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _label(Colors.white60)),
          Text(value,
              style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  static TextStyle _label(Color c) => GoogleFonts.manrope(
      color: c, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5);
}

class _Centered extends StatelessWidget {
  final Widget child;
  const _Centered({required this.child});
  @override
  Widget build(BuildContext context) => Center(child: child);
}

class _Message extends StatelessWidget {
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onBack;

  const _Message({
    required this.title,
    required this.body,
    required this.onBack,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text(body,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 24),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            TextButton(
                onPressed: onBack,
                child: Text('GO BACK',
                    style: GoogleFonts.manrope(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
