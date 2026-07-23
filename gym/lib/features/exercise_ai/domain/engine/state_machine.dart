import '../entities/analysis.dart';
import '../config/ai_config.dart';

/// A short rolling history of angle samples, used to evaluate temporal
/// conditions (rising/falling/heldFor) without exercise-specific code.
class MovementHistory {
  final int retentionMs;
  final List<_Sample> _samples = [];

  MovementHistory({this.retentionMs = 2000});

  void add(int timestampMs, Map<String, JointAngle> angles) {
    _samples.add(_Sample(
      timestampMs,
      {for (final e in angles.entries) e.key: e.value.degrees},
    ));
    final cutoff = timestampMs - retentionMs;
    while (_samples.isNotEmpty && _samples.first.t < cutoff) {
      _samples.removeAt(0);
    }
  }

  /// Signed change of an angle over the last [windowMs]. Positive = rising.
  double slope(String angleId, int windowMs, int nowMs) {
    if (_samples.length < 2) return 0;
    final cutoff = nowMs - windowMs;
    double? earliest;
    double? latest;
    for (final s in _samples) {
      final v = s.angles[angleId];
      if (v == null) continue;
      if (s.t >= cutoff) {
        earliest ??= v;
      }
      latest = v;
    }
    if (earliest == null || latest == null) return 0;
    return latest - earliest;
  }

  /// Whether an angle stayed within [min]..[max] for the whole [windowMs].
  bool heldWithin(
      String angleId, double min, double max, int windowMs, int nowMs) {
    final cutoff = nowMs - windowMs;
    var sawSampleInWindow = false;
    for (final s in _samples) {
      if (s.t < cutoff) continue;
      final v = s.angles[angleId];
      if (v == null) return false;
      sawSampleInWindow = true;
      if (v < min || v > max) return false;
    }
    return sawSampleInWindow;
  }

  void clear() => _samples.clear();
}

class _Sample {
  final int t;
  final Map<String, double> angles;
  _Sample(this.t, this.angles);
}

/// Evaluates a declarative [ConditionSpec] — the single place that turns
/// config into a boolean, with zero exercise names inside.
class ConditionEvaluator {
  const ConditionEvaluator();

  bool evaluate(
    ConditionSpec cond,
    Map<String, JointAngle> angles,
    MovementHistory history,
    int nowMs,
  ) {
    final current = angles[cond.angleId]?.degrees;
    if (current == null) return false;

    switch (cond.op) {
      case ConditionOp.lessThan:
        return current < cond.value;
      case ConditionOp.greaterThan:
        return current > cond.value;
      case ConditionOp.between:
        final hi = cond.value2 ?? double.infinity;
        return current >= cond.value && current <= hi;
      case ConditionOp.rising:
        return history.slope(cond.angleId, cond.windowMs, nowMs) > _epsilon &&
            current >= cond.value;
      case ConditionOp.falling:
        return history.slope(cond.angleId, cond.windowMs, nowMs) < -_epsilon &&
            current <= cond.value;
      case ConditionOp.heldFor:
        final hi = cond.value2 ?? double.infinity;
        return history.heldWithin(
            cond.angleId, cond.value, hi, cond.windowMs, nowMs);
    }
  }

  static const double _epsilon = 0.5; // degrees — ignore jitter
}

/// A generic, config-driven finite state machine. It knows nothing about
/// squats or pushups — only states and declarative transitions.
class StateMachine {
  final StateMachineConfig config;
  final ConditionEvaluator _evaluator;
  String _current;

  StateMachine(this.config, {ConditionEvaluator? evaluator})
      : _evaluator = evaluator ?? const ConditionEvaluator(),
        _current = config.initialState;

  String get current => _current;

  /// Advances the machine given the latest angles. Returns the transition that
  /// fired this frame, or null. Evaluates at most one transition per frame
  /// (first matching, in config order) to keep behavior deterministic.
  Transition? update(
    Map<String, JointAngle> angles,
    MovementHistory history,
    int nowMs,
  ) {
    for (final t in config.transitions) {
      if (t.from != _current) continue;
      if (_evaluator.evaluate(t.condition, angles, history, nowMs)) {
        final fired = Transition(t.from, t.to, nowMs);
        _current = t.to;
        return fired;
      }
    }
    return null;
  }

  void reset() => _current = config.initialState;
}

class Transition {
  final String from;
  final String to;
  final int timestampMs;
  const Transition(this.from, this.to, this.timestampMs);

  bool matches(String? from, String? to) =>
      (from == null || from == this.from) && (to == null || to == this.to);
}
