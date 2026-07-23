import '../config/ai_config.dart';

/// Scores how closely a rep's eccentric/concentric timing matched the target
/// tempo. Config-driven; no exercise knowledge.
class TempoAnalyzer {
  const TempoAnalyzer();

  /// Returns 0..100. If no tempo target is configured, tempo is not judged and
  /// a neutral 100 is returned (so it doesn't drag the score down).
  double scoreRep({
    required int eccentricMs,
    required int concentricMs,
    required TempoConfig? config,
  }) {
    if (config == null ||
        (config.eccentricDurationMs == 0 && config.concentricDurationMs == 0)) {
      return 100;
    }
    final ecc = _phaseScore(
        eccentricMs, config.eccentricDurationMs, config.toleranceMs);
    final con = _phaseScore(
        concentricMs, config.concentricDurationMs, config.toleranceMs);
    return ((ecc + con) / 2).clamp(0, 100).toDouble();
  }

  double _phaseScore(int actualMs, int targetMs, int toleranceMs) {
    if (targetMs <= 0) return 100;
    final error = (actualMs - targetMs).abs();
    if (error <= toleranceMs) return 100;
    // Linear falloff: each tolerance-window of overshoot costs ~40 points.
    final over = (error - toleranceMs) / toleranceMs;
    return (100 - over * 40).clamp(0, 100).toDouble();
  }
}
