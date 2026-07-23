import 'landmark.dart';

/// Severity of a form issue, ordered so `.index` can drive prioritization.
enum FormSeverity { info, low, medium, high, critical }

FormSeverity formSeverityFromString(String? raw) {
  switch ((raw ?? '').trim().toUpperCase()) {
    case 'CRITICAL':
      return FormSeverity.critical;
    case 'HIGH':
      return FormSeverity.high;
    case 'MEDIUM':
      return FormSeverity.medium;
    case 'LOW':
      return FormSeverity.low;
    default:
      return FormSeverity.info;
  }
}

/// A computed joint angle in degrees with a confidence derived from the
/// visibility of the three landmarks that produced it.
class JointAngle {
  final String id;
  final double degrees;
  final double confidence;

  const JointAngle({
    required this.id,
    required this.degrees,
    required this.confidence,
  });
}

/// Result of the pose-validation gate for one frame.
class PoseValidationReport {
  final bool valid;
  final List<LandmarkType> missing;
  final List<LandmarkType> lowConfidence;

  const PoseValidationReport({
    required this.valid,
    this.missing = const [],
    this.lowConfidence = const [],
  });

  static const PoseValidationReport ok = PoseValidationReport(valid: true);
}

/// Coaching cue to help the user frame themselves before/while exercising.
class CameraGuidance {
  final String code; // e.g. MOVE_BACK, STEP_INTO_FRAME, TURN_SIDE
  final String message;
  const CameraGuidance(this.code, this.message);
}

/// A single completed repetition and its measured qualities.
class RepEvent {
  final int index; // 1-based
  final int durationMs;
  final double rom; // range-of-motion metric (degrees swept), 0 if n/a
  final bool valid; // passed rep-rule duration/rom gates
  final double formScore; // 0..100 for this rep
  final double tempoScore; // 0..100 for this rep
  final int eccentricMs;
  final int concentricMs;

  const RepEvent({
    required this.index,
    required this.durationMs,
    required this.rom,
    required this.valid,
    required this.formScore,
    required this.tempoScore,
    this.eccentricMs = 0,
    this.concentricMs = 0,
  });
}

/// A form-rule evaluation for one frame.
class FormFinding {
  final String ruleId;
  final FormSeverity severity;
  final bool passed;
  final String message;

  const FormFinding({
    required this.ruleId,
    required this.severity,
    required this.passed,
    required this.message,
  });
}

/// Rolling scores maintained across the session (0..100).
class LiveScores {
  final double rep;
  final double form;
  final double tempo;
  final double rom;
  final double overall;

  const LiveScores({
    this.rep = 0,
    this.form = 100,
    this.tempo = 100,
    this.rom = 0,
    this.overall = 0,
  });
}

/// The product of running the analysis pipeline over ONE frame.
class AnalysisFrameResult {
  final bool poseValid;
  final PoseValidationReport validation;
  final Map<String, JointAngle> angles;
  final String currentStateId;
  final int repCount;
  final int validRepCount;
  final RepEvent? completedRep; // non-null only on the frame a rep closes
  final List<FormFinding> formFindings;
  final LiveScores scores;
  final CameraGuidance? guidance;

  const AnalysisFrameResult({
    required this.poseValid,
    required this.validation,
    required this.angles,
    required this.currentStateId,
    required this.repCount,
    required this.validRepCount,
    required this.scores,
    this.completedRep,
    this.formFindings = const [],
    this.guidance,
  });

  /// The findings that failed this frame, most severe first.
  List<FormFinding> get activeIssues {
    final failed = formFindings.where((f) => !f.passed).toList();
    failed.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return failed;
  }
}

/// Aggregate result for ONE set — the analyzer is finalized and reset at every
/// set boundary, so each of these covers a single working set. See
/// [SessionAnalysisResult] for the whole Watch Me session.
class WorkoutAnalysisResult {
  final int totalReps;
  final int validReps;
  final double formScore;
  final double tempoScore;
  final double romScore;
  final double overallScore;
  final List<RepEvent> reps;
  final List<FormFinding> topIssues;
  final Duration activeDuration;

  const WorkoutAnalysisResult({
    required this.totalReps,
    required this.validReps,
    required this.formScore,
    required this.tempoScore,
    required this.romScore,
    required this.overallScore,
    required this.reps,
    required this.topIssues,
    required this.activeDuration,
  });

  static const WorkoutAnalysisResult empty = WorkoutAnalysisResult(
    totalReps: 0,
    validReps: 0,
    formScore: 0,
    tempoScore: 0,
    romScore: 0,
    overallScore: 0,
    reps: [],
    topIssues: [],
    activeDuration: Duration.zero,
  );
}

/// Result of a whole Watch Me session: one [WorkoutAnalysisResult] per set
/// worked, plus how that compares to what was prescribed. This is what the
/// coaching screen hands back to the task screen.
class SessionAnalysisResult {
  /// One entry per set actually worked, in order.
  final List<WorkoutAnalysisResult> sets;

  /// Sets the task prescribed, for "3 of 4" style reporting.
  final int plannedSets;

  const SessionAnalysisResult({
    required this.sets,
    required this.plannedSets,
  });

  static const SessionAnalysisResult empty =
      SessionAnalysisResult(sets: [], plannedSets: 0);

  int get completedSets => sets.length;
  int get totalReps => sets.fold(0, (sum, s) => sum + s.totalReps);
  int get validReps => sets.fold(0, (sum, s) => sum + s.validReps);

  Duration get activeDuration => sets.fold(
        Duration.zero,
        (sum, s) => sum + s.activeDuration,
      );

  double get formScore => _mean((s) => s.formScore);
  double get tempoScore => _mean((s) => s.tempoScore);
  double get romScore => _mean((s) => s.romScore);
  double get overallScore => _mean((s) => s.overallScore);

  /// Valid reps per set, e.g. "12,12,10" — prefills the logged actuals.
  String get repsPerSetLabel => sets.map((s) => s.validReps).join(',');

  /// Every rep of the session, flattened.
  List<RepEvent> get allReps => [for (final s in sets) ...s.reps];

  double _mean(double Function(WorkoutAnalysisResult) pick) {
    if (sets.isEmpty) return 0;
    return sets.map(pick).reduce((a, b) => a + b) / sets.length;
  }
}
