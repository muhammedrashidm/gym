import '../entities/pose_frame.dart';
import '../entities/analysis.dart';
import '../config/ai_config.dart';
import 'math.dart';
import 'pose_validator.dart';
import 'state_machine.dart';
import 'rep_detector.dart';
import 'form.dart';
import 'scoring.dart';

/// Mutable per-session + per-frame state threaded through the pipeline stages.
///
/// Session state (state machine, rep detector, history, reps, scores) persists
/// across frames; frame-scoped fields are reset by [beginFrame].
class AnalysisContext {
  final AiConfig config;
  final MovementHistory history;
  final StateMachine stateMachine;
  final RepDetector repDetector;
  final List<RepEvent> reps = [];

  // --- session-persistent ---
  LiveScores scores = const LiveScores();
  int? sessionStartMs;
  int lastFrameMs = 0;
  final List<FormFinding> _worstByRule = [];

  // --- frame-scoped (reset each frame) ---
  late PoseFrame frame;
  int nowMs = 0;
  PoseValidationReport validation = PoseValidationReport.ok;
  bool poseValid = true;
  Map<String, JointAngle> angles = const {};
  Transition? lastTransition;
  List<FormFinding> frameFindings = const [];
  RepEvent? completedRep;
  CameraGuidance? guidance;

  // rep form accumulation
  double _repFormSum = 0;
  int _repFormCount = 0;

  AnalysisContext(this.config)
      : history = MovementHistory(),
        stateMachine = StateMachine(config.stateMachine),
        repDetector = RepDetector(
          config.repRules ??
              StateMachineDefaults.repRulesFor(config.stateMachine),
          primaryAngleId: _primaryAngleId(config),
        );

  double get avgRepForm =>
      _repFormCount == 0 ? 100 : _repFormSum / _repFormCount;

  void addFrameForm(double score) {
    _repFormSum += score;
    _repFormCount++;
  }

  void resetRepForm() {
    _repFormSum = 0;
    _repFormCount = 0;
  }

  void beginFrame(PoseFrame f, int now) {
    frame = f;
    nowMs = now;
    sessionStartMs ??= now;
    lastFrameMs = now;
    validation = PoseValidationReport.ok;
    poseValid = true;
    angles = const {};
    lastTransition = null;
    frameFindings = const [];
    completedRep = null;
    guidance = null;
  }

  /// Tracks the single worst (unresolved) finding per rule for the summary.
  void recordIssues(List<FormFinding> findings) {
    for (final f in findings) {
      if (f.passed) continue;
      final idx = _worstByRule.indexWhere((e) => e.ruleId == f.ruleId);
      if (idx < 0) {
        _worstByRule.add(f);
      } else if (f.severity.index > _worstByRule[idx].severity.index) {
        _worstByRule[idx] = f;
      }
    }
  }

  List<FormFinding> get topIssues {
    final sorted = [..._worstByRule]
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return sorted;
  }

  Duration get activeDuration => Duration(
      milliseconds: sessionStartMs == null ? 0 : lastFrameMs - sessionStartMs!);

  AnalysisFrameResult buildResult() => AnalysisFrameResult(
        poseValid: poseValid,
        validation: validation,
        angles: angles,
        currentStateId: stateMachine.current,
        repCount: repDetector.count,
        validRepCount: repDetector.validCount,
        completedRep: completedRep,
        formFindings: frameFindings,
        scores: scores,
        guidance: guidance,
      );

  static String? _primaryAngleId(AiConfig config) {
    // Prefer the angle referenced by the transition into the bottom state.
    final bottom = config.repRules?.bottomStateId;
    if (bottom != null) {
      for (final t in config.stateMachine.transitions) {
        if (t.to == bottom) return t.condition.angleId;
      }
    }
    return config.angles.isNotEmpty ? config.angles.first.id : null;
  }
}

/// Fallbacks for configs (hold/pose) that omit an explicit rep-rule block.
class StateMachineDefaults {
  static RepRulesConfig repRulesFor(StateMachineConfig sm) => RepRulesConfig(
        topStateId: sm.initialState,
        bottomStateId: sm.initialState,
      );
}

/// A single processing step. Stages read/write [AnalysisContext].
abstract class AnalysisStage {
  String get id;

  /// When true (default), the stage is skipped on frames with an invalid pose.
  bool get requiresValidPose => true;

  void process(AnalysisContext ctx);
}

class PoseValidationStage extends AnalysisStage {
  final PoseValidator _validator;
  PoseValidationStage([PoseValidator? v]) : _validator = v ?? const PoseValidator();

  @override
  String get id => 'validation';
  @override
  bool get requiresValidPose => false;

  @override
  void process(AnalysisContext ctx) {
    ctx.validation =
        _validator.validate(ctx.frame, ctx.config.poseRequirements);
    ctx.poseValid = ctx.validation.valid;
    if (!ctx.poseValid) {
      ctx.guidance = _validator.guidanceFor(ctx.validation);
    }
  }
}

class AngleStage extends AnalysisStage {
  @override
  String get id => 'angles';

  @override
  void process(AnalysisContext ctx) {
    ctx.angles = AngleCalculator.computeAll(ctx.frame, ctx.config.angles);
    ctx.history.add(ctx.nowMs, ctx.angles);
  }
}

class MovementStage extends AnalysisStage {
  @override
  String get id => 'movement';

  @override
  void process(AnalysisContext ctx) {
    ctx.lastTransition =
        ctx.stateMachine.update(ctx.angles, ctx.history, ctx.nowMs);
  }
}

class RepStage extends AnalysisStage {
  @override
  String get id => 'rep';

  @override
  void process(AnalysisContext ctx) {
    final rules = ctx.config.repRules;
    final t = ctx.lastTransition;
    if (t != null && rules != null && t.from == rules.topStateId) {
      ctx.resetRepForm(); // new rep begins
    }
    final rep = ctx.repDetector.update(
      transition: t,
      angles: ctx.angles,
      nowMs: ctx.nowMs,
      avgFrameFormScore: ctx.avgRepForm,
      tempoConfig: ctx.config.tempo,
    );
    if (rep != null) {
      ctx.completedRep = rep;
      ctx.reps.add(rep);
      ctx.resetRepForm();
    }
  }
}

class FormStage extends AnalysisStage {
  final FormRuleEvaluator _evaluator;
  FormStage([FormRuleEvaluator? e]) : _evaluator = e ?? FormRuleEvaluator();

  @override
  String get id => 'form';

  @override
  void process(AnalysisContext ctx) {
    final findings = _evaluator.evaluate(
      ctx.config.formRules,
      FormRuleContext(
        angles: ctx.angles,
        currentStateId: ctx.stateMachine.current,
        bottomStateId: ctx.config.repRules?.bottomStateId,
      ),
    );
    ctx.frameFindings = findings;
    ctx.recordIssues(findings);
    ctx.addFrameForm(FormRuleEvaluator.frameScore(findings));
  }
}

/// Tempo is measured per-rep inside [RepDetector]; this stage is a declared
/// no-op so configs may list `"tempo"` in their pipeline for clarity and so V2
/// can later slot a richer tempo model here without reordering.
class TempoStage extends AnalysisStage {
  @override
  String get id => 'tempo';
  @override
  void process(AnalysisContext ctx) {}
}

class ScoringStage extends AnalysisStage {
  final ScoringEngine _engine;
  ScoringStage([ScoringEngine? e]) : _engine = e ?? const ScoringEngine();

  @override
  String get id => 'scoring';
  @override
  bool get requiresValidPose => false;

  @override
  void process(AnalysisContext ctx) {
    ctx.scores = _engine.compute(ctx.reps, ctx.config.scoring);
  }
}

/// Runs an ordered list of stages over each frame. Stages that require a valid
/// pose are skipped on invalid frames (framing guidance is shown instead).
class AnalysisPipeline {
  final List<AnalysisStage> stages;
  const AnalysisPipeline(this.stages);

  AnalysisFrameResult run(AnalysisContext ctx, PoseFrame frame, int nowMs) {
    ctx.beginFrame(frame, nowMs);
    for (final stage in stages) {
      if (stage.requiresValidPose && !ctx.poseValid) continue;
      stage.process(ctx);
    }
    return ctx.buildResult();
  }
}

/// Maps stage ids (from `pipeline.stageIds`) to stage instances. New stages
/// (e.g. V2 `tfliteForm`) register here without touching existing code.
class StageRegistry {
  final Map<String, AnalysisStage Function()> _factories;

  StageRegistry([Map<String, AnalysisStage Function()>? extra])
      : _factories = {
          'validation': () => PoseValidationStage(),
          'angles': () => AngleStage(),
          'movement': () => MovementStage(),
          'rep': () => RepStage(),
          'form': () => FormStage(),
          'tempo': () => TempoStage(),
          'scoring': () => ScoringStage(),
          ...?extra,
        };

  bool supports(String id) => _factories.containsKey(id);

  AnalysisPipeline build(List<String> stageIds) {
    final stages = <AnalysisStage>[];
    for (final id in stageIds) {
      final f = _factories[id];
      if (f != null) stages.add(f()); // unknown ids ignored (forward-compat)
    }
    return AnalysisPipeline(stages);
  }
}
