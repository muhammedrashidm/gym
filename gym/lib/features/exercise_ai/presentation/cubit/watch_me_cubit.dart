import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../exercise_config/domain/entities/exercise_config.dart';
import '../../data/camera/camera_source_impl.dart';
import '../../domain/config/ai_config.dart';
import '../../domain/config/ai_config_parser.dart';
import '../../domain/entities/analysis.dart';
import '../../domain/engine/analyzers.dart';
import '../../domain/feedback/feedback.dart';
import '../../domain/ports/ports.dart';
import '../../domain/session/set_coach.dart';
import '../../domain/session/set_plan.dart';
import 'watch_me_state.dart';

/// Orchestrates the live coaching loop: camera → pose → analyzer → UI + voice,
/// and the set/rest structure on top of it.
///
/// V1 runs the (cheap, <2ms) pure pipeline on the UI isolate and relies on ML
/// Kit's native threading plus frame-dropping backpressure to stay smooth. The
/// pipeline is pure Dart, so it can be moved into a worker isolate later
/// without touching the engine (see the architecture doc, §11).
class WatchMeCubit extends Cubit<WatchMeState> {
  final CameraSourceImpl _camera;
  final PoseDetector _detector;
  final VoiceOutput _voice;
  final AnalyzerFactory _analyzerFactory;

  ExerciseAnalyzer? _analyzer;
  FeedbackArbiter? _arbiter;
  FeedbackSource? _feedbackSource;
  SetCoach? _coach;
  StreamSubscription<CameraFrame>? _frameSub;
  Timer? _ticker;
  final List<WorkoutAnalysisResult> _setResults = [];
  bool _processing = false;
  bool _closed = false;

  /// True while the analyzer is accumulating a set that has not been finalized
  /// yet — guards against banking the same set twice on finish.
  bool _setOpen = true;

  /// Drives the rest countdown and the idle delay before rest starts. Fast
  /// enough for a smooth seconds display, cheap next to the camera stream.
  static const Duration _tickInterval = Duration(milliseconds: 500);

  WatchMeCubit({
    required CameraSourceImpl camera,
    required PoseDetector detector,
    required VoiceOutput voice,
    required AnalyzerFactory analyzerFactory,
  })  : _camera = camera,
        _detector = detector,
        _voice = voice,
        _analyzerFactory = analyzerFactory,
        super(const WatchMeState());

  CameraSourceImpl get camera => _camera;

  Future<void> start(ExerciseConfig exerciseConfig, SetPlan plan) async {
    // 1. Parse the pre-fetched config (pure, in-memory). No network.
    final AiConfig config;
    try {
      config = AiConfigParser.parse(
        exerciseConfig.aiConfigJson,
        analyzerType: exerciseConfig.analyzerType,
      );
    } on AiConfigException catch (e) {
      emit(state.copyWith(
          status: WatchMeStatus.unsupportedConfig, message: e.message));
      return;
    }

    final coach = SetCoach(plan);
    _coach = coach;
    emit(state.copyWith(
      status: WatchMeStatus.initializing,
      config: config,
      plan: plan,
      coach: coach.state,
    ));

    // 2. Camera permission.
    final granted = await _ensureCameraPermission();
    if (!granted) {
      emit(state.copyWith(status: WatchMeStatus.permissionDenied));
      return;
    }

    // 3. Build the analysis + coaching stack from config.
    _analyzer = _analyzerFactory.create(config);
    _feedbackSource = RuleFeedbackSource(config.feedbackRules);
    _arbiter = FeedbackArbiter.fromConfig(config.voice);

    // 4. Bring up voice + pose + camera.
    try {
      await _voice.init();
      await _detector.init(config.poseRequirements);
      // Always the selfie lens: the athlete has to see the skeleton and read
      // the cues while moving. `config.camera.position` is a phone-placement
      // instruction (FRONT | SIDE | ...) surfaced through `camera.instruction`,
      // not a lens selector.
      await _camera.start(frontFacing: true);
    } catch (e) {
      emit(state.copyWith(
          status: WatchMeStatus.error, message: 'Camera unavailable: $e'));
      return;
    }

    _frameSub = _camera.frames.listen(_onFrame);
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
    if (!_closed) emit(state.copyWith(status: WatchMeStatus.running));
  }

  Future<void> _onFrame(CameraFrame frame) async {
    if (_closed || _processing) return; // drop, don't queue (latest-wins)
    _processing = true;
    try {
      final pose = await _detector.detect(frame);
      final analyzer = _analyzer;
      final coach = _coach;
      if (pose == null || analyzer == null) return;

      // While resting, keep the skeleton alive so the athlete can re-frame, but
      // do not analyze: pacing around must not manufacture reps.
      if (coach != null && coach.state.isResting) {
        if (!_closed) emit(state.copyWith(pose: pose));
        return;
      }

      final result = analyzer.analyze(pose);
      if (_closed) return;

      final phaseBefore = coach?.state.phase;
      final cues = coach?.onRepCount(result.repCount, _now()) ?? const [];
      _onSetPhase(phaseBefore, coach);

      emit(state.copyWith(
        status: WatchMeStatus.running,
        frame: result,
        pose: pose,
        coach: coach?.state,
      ));

      _speak([...?_feedbackSource?.evaluate(result), ...cues], result.repCount);
      _maybeAutoFinish(coach);
    } finally {
      _processing = false;
    }
  }

  /// Advances the rest clock and the post-set idle delay.
  void _onTick() {
    final coach = _coach;
    if (_closed || coach == null) return;
    if (coach.state.phase == SetPhase.working) return;

    final phaseBefore = coach.state.phase;
    final cues = coach.tick(_now());
    _onSetPhase(phaseBefore, coach);

    emit(state.copyWith(coach: coach.state));
    _speak(cues, state.frame?.repCount ?? 0);
    _maybeAutoFinish(coach);
  }

  /// Banks and resets the analyzer whenever a set closes, so every set is
  /// scored on its own. [SetCoach] owns the phase; this owns the engine.
  void _onSetPhase(SetPhase? before, SetCoach? coach) {
    if (coach == null || before == null) return;
    final after = coach.state.phase;
    if (before == after) return;

    final closed = after == SetPhase.resting || after == SetPhase.allSetsComplete;
    if (closed && _setOpen) {
      _bankCurrentSet();
      _arbiter?.reset();
    }
    if (after == SetPhase.working) _setOpen = true;
  }

  void _bankCurrentSet() {
    final analyzer = _analyzer;
    if (analyzer == null) return;
    _setResults.add(analyzer.finalizeResult());
    analyzer.reset();
    _coach?.onAnalyzerReset(); // its rep counter restarts at 0
    _setOpen = false;
  }

  void _maybeAutoFinish(SetCoach? coach) {
    if (coach?.state.isFinished ?? false) unawaited(finish());
  }

  /// Skips the remaining rest and starts the next set immediately.
  void skipRest() => _advance((coach) => coach.startNextSet(_now()));

  /// Ends the current set now — for AMRAP sets, or an early stop.
  void endSet() => _advance((coach) => coach.endSet(_now()));

  /// Adds time to the current rest (the "+30s" button).
  void extendRest([Duration by = const Duration(seconds: 30)]) {
    final coach = _coach;
    if (coach == null || _closed) return;
    coach.extendRest(by, _now());
    emit(state.copyWith(coach: coach.state));
  }

  void _advance(List<CoachMessage> Function(SetCoach) action) {
    final coach = _coach;
    if (coach == null || _closed) return;
    final phaseBefore = coach.state.phase;
    final cues = action(coach);
    _onSetPhase(phaseBefore, coach);
    emit(state.copyWith(coach: coach.state));
    _speak(cues, state.frame?.repCount ?? 0);
    _maybeAutoFinish(coach);
  }

  void _speak(List<CoachMessage> candidates, int repIndex) {
    final arbiter = _arbiter;
    final cfg = state.config;
    if (arbiter == null || cfg == null || candidates.isEmpty) return;
    if (!cfg.voice.enabled) return;

    final chosen = arbiter.next(candidates, _now(), repIndex);
    if (chosen != null) _voice.speak(chosen);
  }

  /// Ends the session and returns the per-set results (also placed in state).
  Future<SessionAnalysisResult?> finish() async {
    if (state.status == WatchMeStatus.finished ||
        state.status == WatchMeStatus.finishing) {
      return state.result;
    }
    emit(state.copyWith(status: WatchMeStatus.finishing));
    _ticker?.cancel();
    _ticker = null;
    await _frameSub?.cancel();
    _frameSub = null;
    await _camera.stop();

    // Bank the set in progress, unless it closed on its own or never started.
    final analyzer = _analyzer;
    if (_setOpen && analyzer != null) {
      final inProgress = analyzer.finalizeResult();
      if (inProgress.totalReps > 0) _setResults.add(inProgress);
      _setOpen = false;
    }

    final result = SessionAnalysisResult(
      sets: List.unmodifiable(_setResults),
      plannedSets: state.plan?.totalSets ?? _setResults.length,
    );
    emit(state.copyWith(status: WatchMeStatus.finished, result: result));
    return result;
  }

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  @override
  Future<void> close() async {
    _closed = true;
    _ticker?.cancel();
    await _frameSub?.cancel();
    await _camera.dispose();
    await _detector.dispose();
    await _voice.dispose();
    return super.close();
  }
}
