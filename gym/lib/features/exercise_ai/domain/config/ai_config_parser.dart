import 'ai_config.dart';

/// Pure, synchronous transform: `aiConfigJson` (Map) → typed [AiConfig].
///
/// This is NOT a repository — there is no I/O. The config is pre-fetched
/// upstream and handed in via navigation; the only failure mode is malformed
/// JSON, surfaced as [AiConfigException] and handled in the Cubit.
class AiConfigParser {
  const AiConfigParser._();

  /// Cheap gate used by the UI to decide whether to show the "Watch Me"
  /// button. Never throws.
  static bool isSupported(String? analyzerType, Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return false;
    final type = AnalyzerType.fromString(
        analyzerType ?? json['analyzerType']?.toString());
    if (type == null) return false;
    // Minimal viability: at least one angle and a state machine (for
    // rep-based types) OR a pose requirement set.
    final hasAngles = (json['angles'] as List?)?.isNotEmpty ?? false;
    return hasAngles;
  }

  /// Parses the config. Prefer passing [analyzerType] from the
  /// `ExerciseConfig` (source of truth); falls back to the json field.
  static AiConfig parse(
    Map<String, dynamic> json, {
    String? analyzerType,
  }) {
    final type = AnalyzerType.fromString(
        analyzerType ?? json['analyzerType']?.toString());
    if (type == null) {
      throw AiConfigException(
          'Unknown or missing analyzerType "${analyzerType ?? json['analyzerType']}"');
    }

    final angles = (json['angles'] as List? ?? const [])
        .map((e) => AngleSpec.fromJson(_map(e, 'angles[]')))
        .toList();

    final needsStateMachine =
        type == AnalyzerType.dynamicRep || type == AnalyzerType.compoundMovement || type == AnalyzerType.cardioMovement;

    final smRaw = json['stateMachine'];
    final stateMachine = smRaw is Map
        ? StateMachineConfig.fromJson(Map<String, dynamic>.from(smRaw))
        : (needsStateMachine
            ? throw AiConfigException(
                '$type requires a stateMachine')
            : StateMachineConfig.hold);

    final repRulesRaw = json['repRules'];
    final repRules = repRulesRaw is Map
        ? RepRulesConfig.fromJson(Map<String, dynamic>.from(repRulesRaw))
        : null;

    final tempoRaw = json['tempo'];
    final tempo = tempoRaw is Map
        ? TempoConfig.fromJson(Map<String, dynamic>.from(tempoRaw))
        : null;

    final formRules = (json['formRules'] as List? ?? const [])
        .map((e) => FormRuleSpec.fromJson(_map(e, 'formRules[]')))
        .toList();

    final feedbackRules = (json['feedbackRules'] as List? ?? const [])
        .map((e) => FeedbackRuleSpec.fromJson(_map(e, 'feedbackRules[]')))
        .toList();

    return AiConfig(
      analyzerType: type,
      pipeline: PipelineConfig.fromJson(
          _mapOrNull(json['pipeline']), type),
      camera: CameraConfig.fromJson(_mapOrNull(json['camera']) ?? const {}),
      poseRequirements: PoseRequirements.fromJson(
          _mapOrNull(json['poseRequirements']) ?? const {}),
      angles: angles,
      stateMachine: stateMachine,
      repRules: repRules,
      tempo: tempo,
      formRules: formRules,
      scoring: ScoringConfig.fromJson(
          _mapOrNull(json['scoring']) ?? const {}),
      feedbackRules: feedbackRules,
      voice: VoiceConfig.fromJson(_mapOrNull(json['voice']) ?? const {}),
    );
  }

  /// Convenience: parse but return null instead of throwing.
  static AiConfig? tryParse(Map<String, dynamic> json, {String? analyzerType}) {
    try {
      return parse(json, analyzerType: analyzerType);
    } on AiConfigException {
      return null;
    }
  }

  static Map<String, dynamic> _map(dynamic v, String ctx) {
    if (v is Map) return Map<String, dynamic>.from(v);
    throw AiConfigException('$ctx must be an object');
  }

  static Map<String, dynamic>? _mapOrNull(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;
}
