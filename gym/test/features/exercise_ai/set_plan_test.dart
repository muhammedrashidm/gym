import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/exercise_ai/domain/session/set_plan.dart';

/// The prescription comes from the backend task as free text, so parsing it is
/// the one place a bad string can silently mis-coach a whole workout.
void main() {
  group('RepTarget.parse', () {
    void expectRange(String? raw, int? min, int? max) {
      final t = RepTarget.parse(raw);
      if (min == null) {
        expect(t, isNull, reason: '"$raw" should be untargeted');
        return;
      }
      expect(t, isNotNull, reason: '"$raw" should parse');
      expect(t!.min, min, reason: '"$raw" min');
      expect(t.max, max, reason: '"$raw" max');
    }

    test('fixed counts', () {
      expectRange('12', 12, 12);
      expectRange('  8  ', 8, 8);
      expectRange('1', 1, 1);
    });

    test('ranges in every dash and word form', () {
      expectRange('8-12', 8, 12);
      expectRange('8 - 12', 8, 12);
      expectRange('8–12', 8, 12); // en dash
      expectRange('8—12', 8, 12); // em dash
      expectRange('8 to 12', 8, 12);
      expectRange('3x5', 3, 5);
    });

    test('a reversed range is normalized rather than rejected', () {
      expectRange('12-8', 8, 12);
    });

    test('untargeted prescriptions', () {
      expectRange('AMRAP', null, null);
      expectRange('amrap', null, null);
      expectRange('max', null, null);
      expectRange('to failure', null, null);
      expectRange('', null, null);
      expectRange('   ', null, null);
      expectRange(null, null, null);
    });

    test('duration prescriptions are untargeted for now', () {
      expectRange('30s', null, null);
      expectRange('45 sec', null, null);
      expectRange('2 min', null, null);
    });

    test('zero reps is not a target', () {
      expectRange('0', null, null);
      expectRange('0-0', null, null);
    });
  });

  group('SetPlan.fromTask', () {
    test('carries the task prescription through verbatim', () {
      final plan =
          SetPlan.fromTask(sets: 4, reps: '8-12', restSeconds: 60);
      expect(plan.totalSets, 4);
      expect(plan.minReps, 8);
      expect(plan.maxReps, 12);
      expect(plan.restBetweenSets, const Duration(seconds: 60));
      expect(plan.repsLabel, '8-12');
      expect(plan.hasRepRange, isTrue);
      expect(plan.isAmrap, isFalse);
    });

    test('falls back to 90s only when the task omits rest', () {
      expect(SetPlan.fromTask(sets: 3, reps: '10', restSeconds: null)
          .restBetweenSets, SetPlan.defaultRest);
      expect(SetPlan.fromTask(sets: 3, reps: '10', restSeconds: 0)
          .restBetweenSets, SetPlan.defaultRest);
      expect(SetPlan.defaultRest, const Duration(seconds: 90));
    });

    test('a fixed count is a degenerate range, not a band', () {
      final plan = SetPlan.fromTask(sets: 3, reps: '10', restSeconds: 60);
      expect(plan.minReps, 10);
      expect(plan.maxReps, 10);
      expect(plan.hasRepRange, isFalse);
    });

    test('missing or nonsensical sets collapse to a single set', () {
      expect(SetPlan.fromTask(sets: null, reps: '10').totalSets, 1);
      expect(SetPlan.fromTask(sets: 0, reps: '10').totalSets, 1);
      expect(SetPlan.fromTask(sets: -2, reps: '10').totalSets, 1);
    });

    test('an unreadable rep string coaches as AMRAP', () {
      final plan = SetPlan.fromTask(sets: 2, reps: 'AMRAP', restSeconds: 45);
      expect(plan.isAmrap, isTrue);
      expect(plan.maxReps, isNull);
      expect(plan.repsLabel, 'AMRAP');
      expect(SetPlan.fromTask(sets: 2, reps: null).repsLabel, 'AMRAP');
    });
  });
}
