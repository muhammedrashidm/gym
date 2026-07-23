import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/exercise_ai/domain/config/ai_config.dart';
import 'package:gym/features/exercise_ai/domain/entities/analysis.dart';
import 'package:gym/features/exercise_ai/domain/feedback/feedback.dart';

AnalysisFrameResult resultWith({
  RepEvent? rep,
  int repCount = 0,
  LiveScores scores = const LiveScores(),
  List<FormFinding> findings = const [],
}) =>
    AnalysisFrameResult(
      poseValid: true,
      validation: PoseValidationReport.ok,
      angles: const {},
      currentStateId: 'STANDING',
      repCount: repCount,
      validRepCount: repCount,
      completedRep: rep,
      formFindings: findings,
      scores: scores,
    );

RepEvent goodRep(int i) => RepEvent(
    index: i,
    durationMs: 1500,
    rom: 80,
    valid: true,
    formScore: 90,
    tempoScore: 90);

void main() {
  group('RuleFeedbackSource', () {
    test('matches "rep completed AND repScore>80"', () {
      final source = const RuleFeedbackSource([
        FeedbackRuleSpec(
            id: 'goodRep',
            when: 'rep completed AND repScore>80',
            message: 'Great rep!',
            priority: 3),
      ]);
      final msgs = source.evaluate(resultWith(rep: goodRep(1), repCount: 1));
      expect(msgs.single.text, 'Great rep!');
    });

    test('does not match when no rep completed this frame', () {
      final source = const RuleFeedbackSource([
        FeedbackRuleSpec(
            id: 'goodRep', when: 'rep completed', message: 'x', priority: 3),
      ]);
      expect(source.evaluate(resultWith()), isEmpty);
    });

    test('matches formFinding:<id> failed', () {
      final source = const RuleFeedbackSource([
        FeedbackRuleSpec(
            id: 'depthCue',
            when: 'formFinding:depth failed',
            message: 'Deeper!',
            priority: 1),
      ]);
      final failing = resultWith(findings: const [
        FormFinding(
            ruleId: 'depth',
            severity: FormSeverity.high,
            passed: false,
            message: 'go deeper'),
      ]);
      expect(source.evaluate(failing).single.text, 'Deeper!');
      expect(source.evaluate(resultWith()), isEmpty);
    });
  });

  group('FeedbackArbiter', () {
    test('enforces cooldown between messages', () {
      final arb =
          FeedbackArbiter(cooldownMs: 2000, dedupeWindowMs: 0, maxPerRep: 5);
      final m = [const CoachMessage(id: 'a', category: 'a', text: 'A', priority: 2)];

      expect(arb.next(m, 1000, 1)?.text, 'A');
      expect(arb.next(m, 1500, 1), isNull, reason: 'within cooldown');
      expect(arb.next(m, 3100, 1)?.text, 'A', reason: 'cooldown elapsed');
    });

    test('prioritizes safety and lets critical bypass cooldown', () {
      final arb = FeedbackArbiter(cooldownMs: 5000, maxPerRep: 1);
      arb.next([
        const CoachMessage(id: 'e', category: 'e', text: 'ok', priority: 3)
      ], 0, 1);

      // A critical (priority 0) cue should fire despite cooldown + per-rep cap.
      final critical = arb.next([
        const CoachMessage(id: 's', category: 's', text: 'Back!', priority: 0),
        const CoachMessage(id: 't', category: 't', text: 'tempo', priority: 2),
      ], 100, 1);
      expect(critical?.text, 'Back!');
    });

    test('dedupes the same category within the window', () {
      final arb = FeedbackArbiter(
          cooldownMs: 0, dedupeWindowMs: 3000, maxPerRep: 99);
      final m = [const CoachMessage(id: 'd', category: 'depth', text: 'Deeper')];

      expect(arb.next(m, 0, 1)?.text, 'Deeper');
      expect(arb.next(m, 1000, 1), isNull, reason: 'same category, deduped');
      expect(arb.next(m, 3500, 1)?.text, 'Deeper', reason: 'window passed');
    });

    test('resets per-rep cap on rep boundary', () {
      final arb =
          FeedbackArbiter(cooldownMs: 0, dedupeWindowMs: 0, maxPerRep: 1);
      final m = [const CoachMessage(id: 'a', category: 'a', text: 'A')];

      expect(arb.next(m, 0, 1)?.text, 'A');
      expect(arb.next(m, 10, 1), isNull, reason: 'cap reached for rep 1');
      expect(arb.next(m, 20, 2)?.text, 'A', reason: 'new rep resets cap');
    });
  });
}
