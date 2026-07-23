import '../entities/analysis.dart';
import '../config/ai_config.dart';
import 'state_machine.dart';
import 'tempo.dart';

/// Detects and measures repetitions from state-machine transitions.
///
/// Exercise-agnostic: it only knows "top state", "bottom state", and the
/// transition that closes a rep — all from [RepRulesConfig].
class RepDetector {
  final RepRulesConfig rules;
  final String? primaryAngleId; // tracked for ROM (min/max sweep)
  final TempoAnalyzer _tempo;

  int _count = 0;
  int _validCount = 0;

  bool _inProgress = false;
  int _startMs = 0;
  int? _bottomMs;
  double? _minAngle;
  double? _maxAngle;

  RepDetector(this.rules, {this.primaryAngleId, TempoAnalyzer? tempo})
      : _tempo = tempo ?? const TempoAnalyzer();

  int get count => _count;
  int get validCount => _validCount;

  /// Call once per frame after the state machine has updated.
  ///
  /// [avgFrameFormScore] is the running average of per-frame form scores
  /// accumulated during the current rep (0..100), used as the rep's form score.
  /// Returns a [RepEvent] on the frame a rep closes, else null.
  RepEvent? update({
    required Transition? transition,
    required Map<String, JointAngle> angles,
    required int nowMs,
    required double avgFrameFormScore,
    required TempoConfig? tempoConfig,
  }) {
    // Track ROM for the primary angle every frame while a rep is in progress.
    final primary =
        primaryAngleId == null ? null : angles[primaryAngleId!]?.degrees;
    if (_inProgress && primary != null) {
      _minAngle = _minAngle == null ? primary : (primary < _minAngle! ? primary : _minAngle!);
      _maxAngle = _maxAngle == null ? primary : (primary > _maxAngle! ? primary : _maxAngle!);
    }

    if (transition == null) return null;

    // Rep starts when leaving the top state.
    if (!_inProgress && transition.from == rules.topStateId) {
      _inProgress = true;
      _startMs = nowMs;
      _bottomMs = null;
      _minAngle = primary;
      _maxAngle = primary;
      return null;
    }

    // Record the moment the bottom is reached (splits eccentric/concentric).
    if (_inProgress && transition.to == rules.bottomStateId) {
      _bottomMs = nowMs;
      return null;
    }

    if (_inProgress && _closes(transition)) {
      return _closeRep(nowMs, avgFrameFormScore, tempoConfig);
    }
    return null;
  }

  bool _closes(Transition t) {
    if (rules.countOnFrom != null && rules.countOnTo != null) {
      return t.matches(rules.countOnFrom, rules.countOnTo);
    }
    // Default: rep closes on returning to the top state.
    return t.to == rules.topStateId;
  }

  RepEvent _closeRep(
      int nowMs, double avgFormScore, TempoConfig? tempoConfig) {
    _inProgress = false;
    _count++;

    final durationMs = nowMs - _startMs;
    final eccentricMs = _bottomMs == null ? 0 : (_bottomMs! - _startMs);
    final concentricMs = _bottomMs == null ? 0 : (nowMs - _bottomMs!);
    final rom = (_minAngle != null && _maxAngle != null)
        ? (_maxAngle! - _minAngle!)
        : 0.0;

    final reachedBottom = _bottomMs != null;
    final withinDuration = durationMs >= rules.minimumRepDurationMs &&
        durationMs <= rules.maximumRepDurationMs;
    final valid = reachedBottom && withinDuration;
    if (valid) _validCount++;

    final tempoScore = _tempo.scoreRep(
      eccentricMs: eccentricMs,
      concentricMs: concentricMs,
      config: tempoConfig,
    );

    return RepEvent(
      index: _count,
      durationMs: durationMs,
      rom: rom,
      valid: valid,
      formScore: avgFormScore.clamp(0, 100).toDouble(),
      tempoScore: tempoScore,
      eccentricMs: eccentricMs,
      concentricMs: concentricMs,
    );
  }

  void reset() {
    _count = 0;
    _validCount = 0;
    _inProgress = false;
    _bottomMs = null;
    _minAngle = null;
    _maxAngle = null;
  }
}
