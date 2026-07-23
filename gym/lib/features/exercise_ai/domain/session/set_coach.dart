import '../feedback/feedback.dart';
import 'set_plan.dart';

/// Where the athlete is in the prescription right now.
enum SetPhase {
  /// Repping. The analyzer is live and reps count toward the target.
  working,

  /// Target hit, but reps may still be arriving — rest has not started yet.
  setComplete,

  /// Counting down between sets. Reps are not counted.
  resting,

  /// Every prescribed set is done.
  allSetsComplete,
}

/// Immutable snapshot of the coach, rendered by the HUD and the rest panel.
class SetCoachState {
  final SetPhase phase;

  /// 1-based index of the set being worked (or the one that just closed).
  final int setIndex;
  final int totalSets;
  final int repsThisSet;
  final int? targetMinReps;
  final int? targetMaxReps;
  final Duration restRemaining;
  final Duration restTotal;

  /// Reps performed beyond [targetMaxReps] in the current set.
  final int overshootReps;

  const SetCoachState({
    required this.phase,
    required this.setIndex,
    required this.totalSets,
    required this.repsThisSet,
    required this.targetMinReps,
    required this.targetMaxReps,
    required this.restRemaining,
    required this.restTotal,
    required this.overshootReps,
  });

  bool get isResting => phase == SetPhase.resting;
  bool get isFinished => phase == SetPhase.allSetsComplete;
  bool get hasTarget => targetMaxReps != null;
  bool get isOvershooting => overshootReps > 0;

  /// The set the athlete is resting toward, or null on the last set.
  int? get nextSetIndex => setIndex < totalSets ? setIndex + 1 : null;

  /// "8-12", "12", or null when untargeted.
  String? get targetLabel {
    final min = targetMinReps;
    final max = targetMaxReps;
    if (max == null) return null;
    return (min == null || min == max) ? '$max' : '$min-$max';
  }
}

/// Tracks reps against the prescription, keeps the set count, runs the rest
/// clock, and produces the cues that alert the athlete.
///
/// Pure Dart and clock-injected — every method takes `nowMs` rather than
/// reading a clock, the same contract as [FeedbackArbiter], so the whole
/// behaviour is unit-testable without timers. The caller owns the ticking.
///
/// The cues returned here are ordinary [CoachMessage]s meant to be merged into
/// the candidate list handed to [FeedbackArbiter]: priority 0 bypasses the
/// cooldown and per-rep cap, and the `category` values throttle repeats (an
/// overshoot nag fires on every extra rep but is deduped to the arbiter's
/// window).
class SetCoach {
  final SetPlan plan;

  SetPhase _phase = SetPhase.working;
  int _setIndex = 1;
  int _repsThisSet = 0;
  int _overshootReps = 0;

  /// Cumulative rep count that marks the current set's zero: reps since the set
  /// began are `cumulative - _baseline`. A set starts from the last count seen,
  /// so the handoff is correct whether or not the caller resets the analyzer
  /// between sets — and if it does reset, the count drops below the baseline and
  /// [onRepCount] re-adopts it.
  int _baseline = 0;
  int _lastSeenCumulative = 0;

  int _lastRepMs = 0;
  int _restEndsAtMs = 0;
  int _nowMs = 0;
  final Set<int> _spokenCountdownCues = {};
  bool _targetReachedCued = false;

  SetCoach(this.plan);

  SetCoachState get state => SetCoachState(
        phase: _phase,
        setIndex: _setIndex,
        totalSets: plan.totalSets,
        repsThisSet: _repsThisSet,
        targetMinReps: plan.minReps,
        targetMaxReps: plan.maxReps,
        restRemaining: _restRemaining,
        restTotal: plan.restBetweenSets,
        overshootReps: _overshootReps,
      );

  Duration get _restRemaining {
    if (_phase != SetPhase.resting) return Duration.zero;
    final ms = _restEndsAtMs - _nowMs;
    return ms <= 0 ? Duration.zero : Duration(milliseconds: ms);
  }

  /// Feed the analyzer's **cumulative** rep count. Safe to call every frame:
  /// cues fire only when the count actually advances.
  List<CoachMessage> onRepCount(int cumulativeReps, int nowMs) {
    _nowMs = nowMs;
    if (_phase == SetPhase.resting || _phase == SetPhase.allSetsComplete) {
      return const [];
    }

    _lastSeenCumulative = cumulativeReps;
    // Re-adopt if the analyzer was reset under us and the count restarted.
    if (cumulativeReps < _baseline) _baseline = cumulativeReps;

    final reps = cumulativeReps - _baseline;
    if (reps <= _repsThisSet) return const [];

    _repsThisSet = reps;
    _lastRepMs = nowMs;

    final max = plan.maxReps;
    if (max == null) return const []; // AMRAP — nothing to compare against

    final cues = <CoachMessage>[];

    if (!_targetReachedCued && plan.hasRepRange && reps >= plan.minReps!) {
      _targetReachedCued = true;
      cues.add(CoachMessage(
        id: 'set.targetReached.$_setIndex',
        category: 'set.targetReached',
        text: 'Target reached — ${plan.minReps} reps. Keep going if you can.',
        priority: 1,
      ));
    }

    if (reps == max) {
      _phase = SetPhase.setComplete;
      cues.add(CoachMessage(
        id: 'set.complete.$_setIndex',
        category: 'set.complete',
        text: _setIndex >= plan.totalSets
            ? 'Set $_setIndex of ${plan.totalSets} done. That was the last one.'
            : 'Set $_setIndex of ${plan.totalSets} done. '
                'Rest ${plan.restBetweenSets.inSeconds} seconds.',
        priority: 0,
      ));
    } else if (reps > max) {
      _overshootReps = reps - max;
      cues.add(CoachMessage(
        id: 'set.overshoot.$_setIndex.$_overshootReps',
        category: 'set.overshoot',
        text: _overshootReps > SetPlan.overshootGraceReps
            ? 'Stop — set $_setIndex is done. Rack it and rest.'
            : "That's $reps. Your target was $max.",
        priority: 0,
      ));
    }

    return cues;
  }

  /// Advance the clock. Drives the rest countdown and the idle delay that
  /// starts rest once reps stop arriving.
  List<CoachMessage> tick(int nowMs) {
    _nowMs = nowMs;

    if (_phase == SetPhase.setComplete) {
      if (nowMs - _lastRepMs >= SetPlan.restAutoStartIdleMs) {
        return _closeSet(nowMs);
      }
      return const [];
    }

    if (_phase != SetPhase.resting) return const [];

    final remainingMs = _restEndsAtMs - nowMs;
    if (remainingMs <= 0) return _beginSet(_setIndex + 1, nowMs);

    final remainingSeconds = (remainingMs / 1000).ceil();
    final cues = <CoachMessage>[];
    for (final cue in SetPlan.countdownCuesSeconds) {
      if (remainingSeconds <= cue && _spokenCountdownCues.add(cue)) {
        cues.add(CoachMessage(
          id: 'rest.countdown.$_setIndex.$cue',
          category: 'rest.countdown',
          text: cue >= 10 ? '$cue seconds' : 'Get ready.',
          priority: 1,
        ));
        break; // one countdown cue per tick, the nearest one
      }
    }
    return cues;
  }

  /// End the current set now — the athlete tapped "end set", or an AMRAP set
  /// has no target to end it. Goes straight to rest, skipping the idle wait.
  List<CoachMessage> endSet(int nowMs) {
    _nowMs = nowMs;
    if (_phase == SetPhase.resting || _phase == SetPhase.allSetsComplete) {
      return const [];
    }
    return _closeSet(nowMs);
  }

  /// Skip the remaining rest and start the next set immediately.
  List<CoachMessage> startNextSet(int nowMs) {
    _nowMs = nowMs;
    if (_phase == SetPhase.allSetsComplete) return const [];
    if (_phase != SetPhase.resting) {
      final cues = _closeSet(nowMs);
      if (_phase != SetPhase.resting) return cues; // session ended
      return [...cues, ..._beginSet(_setIndex + 1, nowMs)];
    }
    return _beginSet(_setIndex + 1, nowMs);
  }

  /// Tell the coach the analyzer's rep counter was restarted (the caller
  /// finalizes and resets it at every set boundary). Without this the coach can
  /// only infer the restart from the count dropping, which costs a rep if the
  /// drop first shows up on a frame that already closed one.
  void onAnalyzerReset() {
    _lastSeenCumulative = 0;
    _baseline = 0;
  }

  /// Add time to the current rest (the "+30s" button). No-op outside rest.
  void extendRest(Duration by, int nowMs) {
    _nowMs = nowMs;
    if (_phase != SetPhase.resting) return;
    _restEndsAtMs += by.inMilliseconds;
    // Cues already spoken may become due again as the clock walks back down.
    _spokenCountdownCues
        .removeWhere((cue) => cue * 1000 < _restEndsAtMs - nowMs);
  }

  void reset() {
    _phase = SetPhase.working;
    _setIndex = 1;
    _repsThisSet = 0;
    _overshootReps = 0;
    _baseline = 0;
    _lastSeenCumulative = 0;
    _lastRepMs = 0;
    _restEndsAtMs = 0;
    _spokenCountdownCues.clear();
    _targetReachedCued = false;
  }

  /// Closes the current set: either into rest, or into the end of the session.
  List<CoachMessage> _closeSet(int nowMs) {
    if (_setIndex >= plan.totalSets) {
      _phase = SetPhase.allSetsComplete;
      return [
        CoachMessage(
          id: 'session.complete',
          category: 'session.complete',
          text: 'All ${plan.totalSets} sets complete. Great work.',
          priority: 0,
        ),
      ];
    }

    _phase = SetPhase.resting;
    _restEndsAtMs = nowMs + plan.restBetweenSets.inMilliseconds;
    _spokenCountdownCues.clear();
    return const [];
  }

  List<CoachMessage> _beginSet(int index, int nowMs) {
    _setIndex = index;
    _phase = SetPhase.working;
    _repsThisSet = 0;
    _overshootReps = 0;
    _baseline = _lastSeenCumulative; // reps from here on belong to the new set
    _lastRepMs = nowMs;
    _restEndsAtMs = 0;
    _spokenCountdownCues.clear();
    _targetReachedCued = false;
    return [
      CoachMessage(
        id: 'rest.go.$index',
        category: 'rest.go',
        text: 'Rest over. Set $index of ${plan.totalSets} — go.',
        priority: 0,
      ),
    ];
  }
}
