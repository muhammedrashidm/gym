import '../entities/analysis.dart';
import '../config/ai_config.dart';

/// Fuses rep / form / tempo / rom sub-scores into 0..100 using config weights.
/// The ML fusion weight (`scoring.mlFormWeight`) defaults to 0, so adding a V2
/// classifier stage cannot change V1 results until the backend opts in.
class ScoringEngine {
  const ScoringEngine();

  LiveScores compute(List<RepEvent> reps, ScoringConfig config) {
    if (reps.isEmpty) {
      return const LiveScores(rep: 0, form: 100, tempo: 100, rom: 0, overall: 0);
    }

    final valid = reps.where((r) => r.valid).length;
    final repScore = (valid / reps.length) * 100;

    final formScore = _avg(reps.map((r) => r.formScore));
    final tempoScore = _avg(reps.map((r) => r.tempoScore));

    final maxRom = reps.map((r) => r.rom).fold<double>(0, (m, v) => v > m ? v : m);
    final romScore = maxRom <= 0
        ? 0.0
        : _avg(reps.map((r) => (r.rom / maxRom) * 100));

    final w = config;
    final weightSum = w.repWeight + w.formWeight + w.tempoWeight + w.romWeight;
    final overall = weightSum <= 0
        ? 0.0
        : (repScore * w.repWeight +
                formScore * w.formWeight +
                tempoScore * w.tempoWeight +
                romScore * w.romWeight) /
            weightSum;

    return LiveScores(
      rep: repScore,
      form: formScore,
      tempo: tempoScore,
      rom: romScore,
      overall: overall.clamp(0, 100).toDouble(),
    );
  }

  WorkoutAnalysisResult finalize(
    List<RepEvent> reps,
    ScoringConfig config,
    Duration activeDuration,
    List<FormFinding> topIssues,
  ) {
    final scores = compute(reps, config);
    return WorkoutAnalysisResult(
      totalReps: reps.length,
      validReps: reps.where((r) => r.valid).length,
      formScore: scores.form,
      tempoScore: scores.tempo,
      romScore: scores.rom,
      overallScore: scores.overall,
      reps: List.unmodifiable(reps),
      topIssues: topIssues,
      activeDuration: activeDuration,
    );
  }

  double _avg(Iterable<double> xs) {
    var sum = 0.0;
    var n = 0;
    for (final x in xs) {
      sum += x;
      n++;
    }
    return n == 0 ? 0 : sum / n;
  }
}
