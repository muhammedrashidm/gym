import '../entities/analysis.dart';
import '../config/ai_config.dart';

/// A single coaching cue eligible to be spoken/shown.
class CoachMessage {
  final String id;
  final String category; // used for dedupe (e.g. the rule id)
  final String text;
  final int priority; // 0 = highest (safety) .. 3 = lowest
  final int ttlMs; // drop if not delivered within this window

  const CoachMessage({
    required this.id,
    required this.category,
    required this.text,
    this.priority = 2,
    this.ttlMs = 2500,
  });
}

/// Produces candidate messages for a frame. V3 adds an LLM-backed source
/// alongside this one without changing the arbiter.
abstract class FeedbackSource {
  List<CoachMessage> evaluate(AnalysisFrameResult result);
}

/// Evaluates declarative `feedbackRules[].when` mini-expressions.
///
/// Grammar (conditions joined by " AND "):
///   `rep completed`
///   `formFinding:{ruleId} failed | passed`
///   `{metric} {op} {number}` — metric: repScore, formScore, tempoScore,
///   overallScore, repCount, validReps; op: `>` `<` `>=` `<=` `==`
class RuleFeedbackSource implements FeedbackSource {
  final List<FeedbackRuleSpec> rules;
  const RuleFeedbackSource(this.rules);

  @override
  List<CoachMessage> evaluate(AnalysisFrameResult result) {
    final out = <CoachMessage>[];
    for (final rule in rules) {
      if (rule.message.isEmpty) continue;
      if (_matches(rule.when, result)) {
        out.add(CoachMessage(
          id: rule.id,
          category: rule.id,
          text: rule.message,
          priority: rule.priority,
        ));
      }
    }
    return out;
  }

  bool _matches(String expr, AnalysisFrameResult r) {
    if (expr.trim().isEmpty) return false;
    final clauses = expr.split(RegExp(r'\s+AND\s+', caseSensitive: false));
    for (final clause in clauses) {
      if (!_clause(clause.trim(), r)) return false;
    }
    return true;
  }

  bool _clause(String c, AnalysisFrameResult r) {
    final lower = c.toLowerCase();
    if (lower == 'rep completed' || lower == 'rep_completed') {
      return r.completedRep != null;
    }
    final ff = RegExp(r'^formFinding:(\S+)\s+(failed|passed)$',
            caseSensitive: false)
        .firstMatch(c);
    if (ff != null) {
      final id = ff.group(1)!;
      final wantPassed = ff.group(2)!.toLowerCase() == 'passed';
      final finding =
          r.formFindings.where((f) => f.ruleId == id).cast<FormFinding?>().firstWhere(
                (f) => true,
                orElse: () => null,
              );
      if (finding == null) return false;
      return finding.passed == wantPassed;
    }
    final metric = RegExp(r'^(\w+)\s*(>=|<=|==|>|<)\s*([\d.]+)$').firstMatch(c);
    if (metric != null) {
      final name = metric.group(1)!;
      final op = metric.group(2)!;
      final rhs = double.tryParse(metric.group(3)!) ?? 0;
      final lhs = _metric(name, r);
      if (lhs == null) return false;
      switch (op) {
        case '>':
          return lhs > rhs;
        case '<':
          return lhs < rhs;
        case '>=':
          return lhs >= rhs;
        case '<=':
          return lhs <= rhs;
        case '==':
          return lhs == rhs;
      }
    }
    return false;
  }

  double? _metric(String name, AnalysisFrameResult r) {
    switch (name.toLowerCase()) {
      case 'repscore':
        final rep = r.completedRep;
        return rep == null ? null : (rep.formScore + rep.tempoScore) / 2;
      case 'formscore':
        return r.scores.form;
      case 'temposcore':
        return r.scores.tempo;
      case 'overallscore':
        return r.scores.overall;
      case 'repcount':
        return r.repCount.toDouble();
      case 'validreps':
        return r.validRepCount.toDouble();
      default:
        return null;
    }
  }
}

/// Selects at most one message per tick under cooldown / dedupe / per-rep caps,
/// prioritizing safety over encouragement. Deterministic given a clock.
class FeedbackArbiter {
  final int cooldownMs;
  final int dedupeWindowMs;
  final int maxPerRep;

  int _lastSpokenMs = -1 << 30;
  int _currentRep = 0;
  int _spokenThisRep = 0;
  final Map<String, int> _lastCategoryMs = {};

  FeedbackArbiter({
    required this.cooldownMs,
    this.dedupeWindowMs = 4000,
    this.maxPerRep = 1,
  });

  factory FeedbackArbiter.fromConfig(VoiceConfig v) => FeedbackArbiter(
        cooldownMs: v.cooldownMs,
        maxPerRep: v.maximumFeedbacksPerRep,
      );

  /// Returns the message to deliver this tick, or null. [currentRepIndex] lets
  /// the per-rep cap reset on rep boundaries.
  CoachMessage? next(
    List<CoachMessage> candidates,
    int nowMs,
    int currentRepIndex,
  ) {
    if (currentRepIndex != _currentRep) {
      _currentRep = currentRepIndex;
      _spokenThisRep = 0;
    }
    if (candidates.isEmpty) return null;

    final sorted = [...candidates]
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final msg in sorted) {
      final isCritical = msg.priority == 0;

      // dedupe: same category spoken too recently
      final lastCat = _lastCategoryMs[msg.category];
      if (lastCat != null && nowMs - lastCat < dedupeWindowMs) continue;

      // cooldown + per-rep cap (critical safety cues bypass both)
      if (!isCritical) {
        if (nowMs - _lastSpokenMs < cooldownMs) continue;
        if (_spokenThisRep >= maxPerRep) continue;
      }

      _lastSpokenMs = nowMs;
      _lastCategoryMs[msg.category] = nowMs;
      _spokenThisRep++;
      return msg;
    }
    return null;
  }

  void reset() {
    _lastSpokenMs = -1 << 30;
    _currentRep = 0;
    _spokenThisRep = 0;
    _lastCategoryMs.clear();
  }
}
