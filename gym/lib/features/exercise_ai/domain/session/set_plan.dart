/// The prescription a Watch Me session coaches against.
///
/// Everything here comes from the backend workout task (`Task.sets`,
/// `Task.reps`, `Task.restSeconds`) — the `aiConfigJson` deliberately says
/// nothing about sets or rest, so there is exactly one source of truth for what
/// the athlete is supposed to do.
class SetPlan {
  /// How many sets the task prescribes. Always >= 1.
  final int totalSets;

  /// Lower bound of the rep range, or null for an untargeted (AMRAP) set.
  final int? minReps;

  /// Upper bound of the rep range; equals [minReps] for a fixed count.
  final int? maxReps;

  /// Rest between sets. Falls back to [defaultRest] when the task omits it.
  final Duration restBetweenSets;

  /// The raw prescription string, shown in the HUD as-is (e.g. "8-12").
  final String repsLabel;

  const SetPlan({
    required this.totalSets,
    required this.minReps,
    required this.maxReps,
    required this.restBetweenSets,
    required this.repsLabel,
  });

  /// Used when the task leaves `restSeconds` null.
  static const Duration defaultRest = Duration(seconds: 90);

  /// Seconds-remaining marks at which the rest countdown is spoken. Tuning, not
  /// prescription, so it lives here rather than in the task.
  static const List<int> countdownCuesSeconds = [30, 10, 3];

  /// Extra reps past [maxReps] tolerated before the nag escalates.
  static const int overshootGraceReps = 2;

  /// Reps stop arriving for this long before rest auto-starts. Keeps the
  /// countdown from running against someone who is still lifting.
  static const int restAutoStartIdleMs = 2500;

  /// No rep target — count freely, the set ends only when the athlete says so.
  bool get isAmrap => minReps == null;

  /// True when the prescription is a range rather than a single number, i.e.
  /// there is a "you may keep going" band between [minReps] and [maxReps].
  bool get hasRepRange => minReps != null && maxReps != null && maxReps! > minReps!;

  /// Builds the plan from the three fields carried in `taskData`.
  factory SetPlan.fromTask({int? sets, String? reps, int? restSeconds}) {
    final target = RepTarget.parse(reps);
    return SetPlan(
      totalSets: (sets == null || sets < 1) ? 1 : sets,
      minReps: target?.min,
      maxReps: target?.max,
      restBetweenSets: (restSeconds == null || restSeconds <= 0)
          ? defaultRest
          : Duration(seconds: restSeconds),
      repsLabel: (reps == null || reps.trim().isEmpty) ? 'AMRAP' : reps.trim(),
    );
  }
}

/// A parsed rep prescription.
class RepTarget {
  final int min;
  final int max;
  const RepTarget(this.min, this.max);

  /// Matches "12", "8-12", "8 – 12" (en/em dash), "8 to 12", "8x12".
  static final RegExp _range =
      RegExp(r'^(\d+)\s*(?:-|–|—|to|x|\*)\s*(\d+)$', caseSensitive: false);
  static final RegExp _single = RegExp(r'^(\d+)$');

  /// A time-based prescription ("30s", "45 sec", "1 min") — counted as
  /// untargeted for now; timed holds belong to the STATIC_HOLD analyzer.
  static final RegExp _duration =
      RegExp(r'^\d+\s*(s|sec|secs|second|seconds|m|min|mins|minute|minutes)$',
          caseSensitive: false);

  /// Returns null for AMRAP / max / empty / duration-style prescriptions.
  static RepTarget? parse(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;
    if (_duration.hasMatch(text)) return null;

    final single = _single.firstMatch(text);
    if (single != null) {
      final n = int.parse(single.group(1)!);
      return n > 0 ? RepTarget(n, n) : null;
    }

    final range = _range.firstMatch(text);
    if (range != null) {
      final a = int.parse(range.group(1)!);
      final b = int.parse(range.group(2)!);
      if (a <= 0 || b <= 0) return null;
      return a <= b ? RepTarget(a, b) : RepTarget(b, a);
    }

    // "AMRAP", "max", "failure", "to failure", anything else we can't read.
    return null;
  }
}
