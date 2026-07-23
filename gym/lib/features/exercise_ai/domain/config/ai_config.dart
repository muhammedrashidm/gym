import '../entities/landmark.dart';
import '../entities/analysis.dart';

/// The kind of analysis to run. Maps from backend `analyzerType` strings.
enum AnalyzerType {
  dynamicRep,
  staticHold,
  staticPose,
  compoundMovement,
  cardioMovement;

  static AnalyzerType? fromString(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'DYNAMIC_REP':
        return AnalyzerType.dynamicRep;
      case 'STATIC_HOLD':
        return AnalyzerType.staticHold;
      case 'STATIC_POSE':
        return AnalyzerType.staticPose;
      case 'COMPOUND_MOVEMENT':
        return AnalyzerType.compoundMovement;
      case 'CARDIO_MOVEMENT':
        return AnalyzerType.cardioMovement;
      default:
        return null;
    }
  }
}

/// Comparison / temporal operators a [ConditionSpec] can express.
enum ConditionOp { lessThan, greaterThan, between, rising, falling, heldFor }

ConditionOp _opFromString(String raw) {
  switch (raw.trim().toLowerCase()) {
    case '<':
    case 'lt':
    case 'lessthan':
      return ConditionOp.lessThan;
    case '>':
    case 'gt':
    case 'greaterthan':
      return ConditionOp.greaterThan;
    case 'between':
      return ConditionOp.between;
    case 'rising':
      return ConditionOp.rising;
    case 'falling':
      return ConditionOp.falling;
    case 'heldfor':
    case 'held_for':
      return ConditionOp.heldFor;
    default:
      throw AiConfigException('Unknown condition op "$raw"');
  }
}

/// A declarative, exercise-agnostic condition evaluated against angles/history.
///
/// e.g. squat descend: `{angleId:"kneeAngle", op:"falling", value:160}`.
class ConditionSpec {
  final String angleId;
  final ConditionOp op;
  final double value;
  final double? value2; // upper bound for `between`
  final int windowMs; // slope/hold window for rising/falling/heldFor

  const ConditionSpec({
    required this.angleId,
    required this.op,
    required this.value,
    this.value2,
    this.windowMs = 300,
  });

  factory ConditionSpec.fromJson(Map<String, dynamic> j) {
    final angleId = j['angleId'] as String?;
    if (angleId == null || angleId.isEmpty) {
      throw AiConfigException('condition.angleId is required');
    }
    return ConditionSpec(
      angleId: angleId,
      op: _opFromString((j['op'] ?? '').toString()),
      value: _num(j['value'], 'condition.value'),
      value2: j['value2'] == null ? null : (j['value2'] as num).toDouble(),
      windowMs: (j['windowMs'] as num?)?.toInt() ?? 300,
    );
  }
}

class TransitionSpec {
  final String from;
  final String to;
  final ConditionSpec condition;

  const TransitionSpec({
    required this.from,
    required this.to,
    required this.condition,
  });

  factory TransitionSpec.fromJson(Map<String, dynamic> j) {
    final from = j['from'] as String?;
    final to = j['to'] as String?;
    if (from == null || to == null) {
      throw AiConfigException('transition requires from & to');
    }
    final cond = j['condition'];
    if (cond is! Map) {
      throw AiConfigException('transition $from->$to requires a condition');
    }
    return TransitionSpec(
      from: from,
      to: to,
      condition: ConditionSpec.fromJson(Map<String, dynamic>.from(cond)),
    );
  }
}

class StateMachineConfig {
  final String initialState;
  final List<String> states;
  final List<TransitionSpec> transitions;

  const StateMachineConfig({
    required this.initialState,
    required this.states,
    required this.transitions,
  });

  factory StateMachineConfig.fromJson(Map<String, dynamic> j) {
    final states =
        (j['states'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final initial = (j['initialState'] ?? (states.isNotEmpty ? states.first : ''))
        .toString();
    if (states.isEmpty) {
      throw AiConfigException('stateMachine.states must be non-empty');
    }
    if (!states.contains(initial)) {
      throw AiConfigException('initialState "$initial" not in states');
    }
    final transitions = (j['transitions'] as List? ?? const [])
        .map((e) => TransitionSpec.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    for (final t in transitions) {
      if (!states.contains(t.from) || !states.contains(t.to)) {
        throw AiConfigException(
            'transition ${t.from}->${t.to} references unknown state');
      }
    }
    return StateMachineConfig(
      initialState: initial,
      states: states,
      transitions: transitions,
    );
  }

  /// A permissive default single-state machine (used by hold/pose analyzers
  /// that don't cycle through movement phases).
  static const StateMachineConfig hold = StateMachineConfig(
    initialState: 'HOLD',
    states: ['HOLD'],
    transitions: [],
  );
}

class AngleSpec {
  final String id;
  final LandmarkType vertex;
  final LandmarkType a;
  final LandmarkType b;
  final bool signed;

  const AngleSpec({
    required this.id,
    required this.vertex,
    required this.a,
    required this.b,
    this.signed = false,
  });

  factory AngleSpec.fromJson(Map<String, dynamic> j) {
    LandmarkType lm(String key) {
      final raw = j[key];
      if (raw == null) throw AiConfigException('angle.$key is required');
      final t = LandmarkType.fromConfig(raw.toString());
      if (t == null) {
        throw AiConfigException('angle.$key: unknown landmark "$raw"');
      }
      return t;
    }

    final id = j['id'] as String?;
    if (id == null || id.isEmpty) throw AiConfigException('angle.id required');
    return AngleSpec(
      id: id,
      vertex: lm('vertexLandmark'),
      a: lm('aLandmark'),
      b: lm('bLandmark'),
      signed: j['signed'] == true,
    );
  }
}

class CameraConfig {
  final String position; // FRONT | SIDE | ...
  final String instruction;
  final bool fullBodyRequired;
  final double minimumDistanceCm;

  const CameraConfig({
    this.position = 'SIDE',
    this.instruction = '',
    this.fullBodyRequired = true,
    this.minimumDistanceCm = 0,
  });

  factory CameraConfig.fromJson(Map<String, dynamic> j) => CameraConfig(
        position: (j['position'] ?? 'SIDE').toString(),
        instruction: (j['instruction'] ?? '').toString(),
        fullBodyRequired: j['fullBodyRequired'] != false,
        minimumDistanceCm:
            (j['minimumDistanceCm'] as num?)?.toDouble() ?? 0,
      );
}

class PoseRequirements {
  final List<LandmarkType> requiredLandmarks;
  final double minimumVisibilityScore;
  final double minimumLandmarkConfidence;

  const PoseRequirements({
    this.requiredLandmarks = const [],
    this.minimumVisibilityScore = 0.5,
    this.minimumLandmarkConfidence = 0.5,
  });

  factory PoseRequirements.fromJson(Map<String, dynamic> j) {
    final required = <LandmarkType>[];
    for (final raw in (j['requiredLandmarks'] as List? ?? const [])) {
      final t = LandmarkType.fromConfig(raw.toString());
      if (t == null) {
        throw AiConfigException('poseRequirements: unknown landmark "$raw"');
      }
      required.add(t);
    }
    return PoseRequirements(
      requiredLandmarks: required,
      minimumVisibilityScore:
          (j['minimumVisibilityScore'] as num?)?.toDouble() ?? 0.5,
      minimumLandmarkConfidence:
          (j['minimumLandmarkConfidence'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

class RepRulesConfig {
  final String topStateId;
  final String bottomStateId;
  final String? countOnFrom; // transition that closes a rep
  final String? countOnTo;
  final int minimumRepDurationMs;
  final int maximumRepDurationMs;

  const RepRulesConfig({
    required this.topStateId,
    required this.bottomStateId,
    this.countOnFrom,
    this.countOnTo,
    this.minimumRepDurationMs = 500,
    this.maximumRepDurationMs = 8000,
  });

  factory RepRulesConfig.fromJson(Map<String, dynamic> j) {
    String? from;
    String? to;
    final countOn = j['countOn'];
    if (countOn is String && countOn.contains('->')) {
      final parts = countOn.split('->');
      from = parts[0].trim();
      to = parts[1].trim();
    }
    return RepRulesConfig(
      topStateId: (j['topStateId'] ?? '').toString(),
      bottomStateId: (j['bottomStateId'] ?? '').toString(),
      countOnFrom: from,
      countOnTo: to,
      minimumRepDurationMs:
          (j['minimumRepDurationMs'] as num?)?.toInt() ?? 500,
      maximumRepDurationMs:
          (j['maximumRepDurationMs'] as num?)?.toInt() ?? 8000,
    );
  }
}

class TempoConfig {
  final int eccentricDurationMs;
  final int concentricDurationMs;
  final int toleranceMs;

  const TempoConfig({
    required this.eccentricDurationMs,
    required this.concentricDurationMs,
    this.toleranceMs = 500,
  });

  factory TempoConfig.fromJson(Map<String, dynamic> j) => TempoConfig(
        eccentricDurationMs: (j['eccentricDurationMs'] as num?)?.toInt() ?? 0,
        concentricDurationMs:
            (j['concentricDurationMs'] as num?)?.toInt() ?? 0,
        toleranceMs: (j['toleranceMs'] as num?)?.toInt() ?? 500,
      );
}

class FormRuleSpec {
  final String id;
  final String type; // maps to a registered FormRule primitive
  final Map<String, dynamic> params;
  final FormSeverity severity;
  final String message;

  const FormRuleSpec({
    required this.id,
    required this.type,
    required this.params,
    required this.severity,
    required this.message,
  });

  factory FormRuleSpec.fromJson(Map<String, dynamic> j) {
    final id = j['id'] as String?;
    final type = j['type'] as String?;
    if (id == null || type == null) {
      throw AiConfigException('formRule requires id & type');
    }
    return FormRuleSpec(
      id: id,
      type: type,
      params: Map<String, dynamic>.from(j['params'] as Map? ?? const {}),
      severity: formSeverityFromString(j['severity'] as String?),
      message: (j['message'] ?? '').toString(),
    );
  }
}

class ScoringConfig {
  final double repWeight;
  final double formWeight;
  final double tempoWeight;
  final double romWeight;
  final double mlFormWeight; // V2 fusion hook — defaults to 0 (no effect)

  const ScoringConfig({
    this.repWeight = 0.4,
    this.formWeight = 0.4,
    this.tempoWeight = 0.1,
    this.romWeight = 0.1,
    this.mlFormWeight = 0,
  });

  factory ScoringConfig.fromJson(Map<String, dynamic> j) => ScoringConfig(
        repWeight: (j['repWeight'] as num?)?.toDouble() ?? 0.4,
        formWeight: (j['formWeight'] as num?)?.toDouble() ?? 0.4,
        tempoWeight: (j['tempoWeight'] as num?)?.toDouble() ?? 0.1,
        romWeight: (j['romWeight'] as num?)?.toDouble() ?? 0.1,
        mlFormWeight: (j['mlFormWeight'] as num?)?.toDouble() ?? 0,
      );

  double get total => repWeight + formWeight + tempoWeight + romWeight + mlFormWeight;
}

class FeedbackRuleSpec {
  final String id;
  final String when; // mini-expression, see RuleFeedbackSource
  final String message;
  final int priority; // 0 = highest (safety) .. 3 = lowest (encouragement)

  const FeedbackRuleSpec({
    required this.id,
    required this.when,
    required this.message,
    this.priority = 2,
  });

  factory FeedbackRuleSpec.fromJson(Map<String, dynamic> j) => FeedbackRuleSpec(
        id: (j['id'] ?? '').toString(),
        when: (j['when'] ?? j['rule'] ?? '').toString(),
        message: (j['message'] ?? '').toString(),
        priority: (j['priority'] as num?)?.toInt() ?? 2,
      );
}

class VoiceConfig {
  final bool enabled;
  final int cooldownMs;
  final int maximumFeedbacksPerRep;

  const VoiceConfig({
    this.enabled = true,
    this.cooldownMs = 2500,
    this.maximumFeedbacksPerRep = 1,
  });

  factory VoiceConfig.fromJson(Map<String, dynamic> j) => VoiceConfig(
        enabled: j['enabled'] != false,
        cooldownMs: (j['coolDownMs'] ?? j['cooldownMs'] as num?) is num
            ? (j['coolDownMs'] ?? j['cooldownMs']).toInt()
            : 2500,
        maximumFeedbacksPerRep:
            (j['maximumFeedbacksPerRep'] as num?)?.toInt() ?? 1,
      );
}

class PipelineConfig {
  final List<String> stageIds;
  const PipelineConfig({required this.stageIds});

  factory PipelineConfig.fromJson(Map<String, dynamic>? j, AnalyzerType type) {
    final ids = (j?['stageIds'] as List?)?.map((e) => e.toString()).toList();
    return PipelineConfig(stageIds: ids ?? defaultFor(type));
  }

  static List<String> defaultFor(AnalyzerType type) {
    switch (type) {
      case AnalyzerType.dynamicRep:
      case AnalyzerType.compoundMovement:
        return const [
          'validation',
          'angles',
          'movement',
          'rep',
          'form',
          'tempo',
          'scoring',
        ];
      case AnalyzerType.staticHold:
      case AnalyzerType.staticPose:
        return const ['validation', 'angles', 'form', 'scoring'];
      case AnalyzerType.cardioMovement:
        return const ['validation', 'angles', 'movement', 'rep', 'scoring'];
    }
  }
}

/// The fully typed, validated view over `ExerciseConfig.aiConfigJson`.
class AiConfig {
  final AnalyzerType analyzerType;
  final PipelineConfig pipeline;
  final CameraConfig camera;
  final PoseRequirements poseRequirements;
  final List<AngleSpec> angles;
  final StateMachineConfig stateMachine;
  final RepRulesConfig? repRules;
  final TempoConfig? tempo;
  final List<FormRuleSpec> formRules;
  final ScoringConfig scoring;
  final List<FeedbackRuleSpec> feedbackRules;
  final VoiceConfig voice;

  const AiConfig({
    required this.analyzerType,
    required this.pipeline,
    required this.camera,
    required this.poseRequirements,
    required this.angles,
    required this.stateMachine,
    required this.scoring,
    required this.voice,
    this.repRules,
    this.tempo,
    this.formRules = const [],
    this.feedbackRules = const [],
  });

  Map<String, AngleSpec> get angleById => {for (final a in angles) a.id: a};
}

/// Thrown by config parsing when `aiConfigJson` is malformed. Callers convert
/// this into a graceful "coaching unavailable" state — never a crash.
class AiConfigException implements Exception {
  final String message;
  AiConfigException(this.message);
  @override
  String toString() => 'AiConfigException: $message';
}

double _num(dynamic v, String field) {
  if (v is num) return v.toDouble();
  throw AiConfigException('$field must be a number');
}
