import '../entities/analysis.dart';
import '../config/ai_config.dart';

/// Everything a form rule needs to judge one frame, without exercise knowledge.
class FormRuleContext {
  final Map<String, JointAngle> angles;
  final String currentStateId;
  final String? bottomStateId;

  const FormRuleContext({
    required this.angles,
    required this.currentStateId,
    this.bottomStateId,
  });

  double? angle(String id) => angles[id]?.degrees;
}

/// A registered, reusable form-check primitive. New primitives are ADDITIVE —
/// register a new one; never modify existing evaluators (Open/Closed).
abstract class FormRule {
  String get type;

  /// Returns true = form OK, false = issue. Return null when the rule does not
  /// apply to this frame (e.g. depth only checked at the bottom).
  bool? check(FormRuleSpec spec, FormRuleContext ctx);
}

/// `angleThreshold` — angle must be within [min, max].
class AngleThresholdRule implements FormRule {
  @override
  String get type => 'angleThreshold';

  @override
  bool? check(FormRuleSpec spec, FormRuleContext ctx) {
    final id = spec.params['angleId'] as String?;
    if (id == null) return null;
    final a = ctx.angle(id);
    if (a == null) return null;
    final min = (spec.params['min'] as num?)?.toDouble();
    final max = (spec.params['max'] as num?)?.toDouble();
    if (min != null && a < min) return false;
    if (max != null && a > max) return false;
    return true;
  }
}

/// `romDepth` — at the bottom of the movement the angle must reach <= minAngle.
class RomDepthRule implements FormRule {
  @override
  String get type => 'romDepth';

  @override
  bool? check(FormRuleSpec spec, FormRuleContext ctx) {
    final id = spec.params['angleId'] as String?;
    if (id == null) return null;
    final atState = (spec.params['atState'] as String?) ?? ctx.bottomStateId;
    if (atState != null && ctx.currentStateId != atState) return null;
    final a = ctx.angle(id);
    if (a == null) return null;
    final minAngle = (spec.params['minAngle'] as num?)?.toDouble();
    if (minAngle == null) return null;
    return a <= minAngle;
  }
}

/// `alignment` — three points should be near-collinear (180°) within tolerance.
class AlignmentRule implements FormRule {
  @override
  String get type => 'alignment';

  @override
  bool? check(FormRuleSpec spec, FormRuleContext ctx) {
    final id = spec.params['angleId'] as String?;
    if (id == null) return null;
    final a = ctx.angle(id);
    if (a == null) return null;
    final tol = (spec.params['toleranceDeg'] as num?)?.toDouble() ?? 15;
    return (180 - a).abs() <= tol;
  }
}

/// `symmetry` — left/right angles should be within tolerance of each other.
class SymmetryRule implements FormRule {
  @override
  String get type => 'symmetry';

  @override
  bool? check(FormRuleSpec spec, FormRuleContext ctx) {
    final left = ctx.angle(spec.params['leftAngleId'] as String? ?? '');
    final right = ctx.angle(spec.params['rightAngleId'] as String? ?? '');
    if (left == null || right == null) return null;
    final tol = (spec.params['toleranceDeg'] as num?)?.toDouble() ?? 15;
    return (left - right).abs() <= tol;
  }
}

/// Evaluates all configured form rules for a frame and derives a per-frame form
/// score (100 minus severity-weighted penalties for failed rules).
class FormRuleEvaluator {
  final Map<String, FormRule> _rules;

  FormRuleEvaluator([List<FormRule>? rules])
      : _rules = {
          for (final r in (rules ?? _builtins)) r.type: r,
        };

  static final List<FormRule> _builtins = [
    AngleThresholdRule(),
    RomDepthRule(),
    AlignmentRule(),
    SymmetryRule(),
  ];

  bool supports(String type) => _rules.containsKey(type);

  List<FormFinding> evaluate(List<FormRuleSpec> specs, FormRuleContext ctx) {
    final findings = <FormFinding>[];
    for (final spec in specs) {
      final rule = _rules[spec.type];
      if (rule == null) continue; // unknown primitive → ignored (forward-compat)
      final result = rule.check(spec, ctx);
      if (result == null) continue; // not applicable this frame
      findings.add(FormFinding(
        ruleId: spec.id,
        severity: spec.severity,
        passed: result,
        message: spec.message,
      ));
    }
    return findings;
  }

  /// Per-frame form score from findings. Higher severity failures cost more.
  static double frameScore(List<FormFinding> findings) {
    var penalty = 0.0;
    for (final f in findings) {
      if (f.passed) continue;
      penalty += _severityPenalty(f.severity);
    }
    return (100 - penalty).clamp(0, 100).toDouble();
  }

  static double _severityPenalty(FormSeverity s) {
    switch (s) {
      case FormSeverity.critical:
        return 50;
      case FormSeverity.high:
        return 30;
      case FormSeverity.medium:
        return 18;
      case FormSeverity.low:
        return 8;
      case FormSeverity.info:
        return 0;
    }
  }
}
