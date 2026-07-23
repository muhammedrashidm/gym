import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/exercise_ai/domain/feedback/feedback.dart';
import 'package:gym/features/exercise_ai/domain/session/set_coach.dart';
import 'package:gym/features/exercise_ai/domain/session/set_plan.dart';

/// [SetCoach] is clock-injected, so the whole set/rest/overshoot behaviour can
/// be driven deterministically without a single timer.
void main() {
  SetPlan plan({
    int sets = 3,
    String reps = '8-12',
    int restSeconds = 60,
  }) =>
      SetPlan.fromTask(sets: sets, reps: reps, restSeconds: restSeconds);

  List<String> categories(List<CoachMessage> cues) =>
      cues.map((c) => c.category).toList();

  /// Feeds [count] reps one second apart starting at [startMs], returning every
  /// cue produced. Rep counts are cumulative, as the analyzer reports them.
  List<CoachMessage> repTo(SetCoach coach, int count,
      {int startMs = 0, int from = 1}) {
    final cues = <CoachMessage>[];
    for (var i = from; i <= count; i++) {
      cues.addAll(coach.onRepCount(i, startMs + i * 1000));
    }
    return cues;
  }

  group('rep counting', () {
    test('starts a set at zero reps in the working phase', () {
      final coach = SetCoach(plan());
      expect(coach.state.phase, SetPhase.working);
      expect(coach.state.setIndex, 1);
      expect(coach.state.repsThisSet, 0);
      expect(coach.state.totalSets, 3);
    });

    test('is idempotent — a repeated count produces no cues', () {
      final coach = SetCoach(plan());
      coach.onRepCount(1, 1000);
      expect(coach.onRepCount(1, 1100), isEmpty);
      expect(coach.onRepCount(1, 1200), isEmpty);
      expect(coach.state.repsThisSet, 1);
    });

    test('counts from the first rep, not the second', () {
      // The analyzer reports 0 for every frame before the first rep closes; the
      // coach must not swallow that first rep by adopting 1 as its baseline.
      final coach = SetCoach(plan());
      coach.onRepCount(0, 500);
      coach.onRepCount(1, 1000);
      expect(coach.state.repsThisSet, 1);
    });

    test('counts the first rep even with no idle frame beforehand', () {
      final coach = SetCoach(plan());
      coach.onRepCount(1, 1000);
      expect(coach.state.repsThisSet, 1);
    });
  });

  group('targets', () {
    test('cues at the bottom of the range, completes at the top', () {
      final coach = SetCoach(plan());

      final toEight = repTo(coach, 8);
      expect(categories(toEight), ['set.targetReached']);
      expect(coach.state.phase, SetPhase.working,
          reason: 'the range still has room, the set is not over');

      final toTwelve = repTo(coach, 12, from: 9);
      expect(categories(toTwelve), ['set.complete']);
      expect(coach.state.phase, SetPhase.setComplete);
      expect(coach.state.repsThisSet, 12);
    });

    test('the target cue fires once, not on every rep in the band', () {
      final coach = SetCoach(plan());
      final cues = repTo(coach, 11);
      expect(categories(cues).where((c) => c == 'set.targetReached').length, 1);
    });

    test('a fixed count completes without a "keep going" cue', () {
      final coach = SetCoach(plan(reps: '10'));
      final cues = repTo(coach, 10);
      expect(categories(cues), ['set.complete']);
      expect(coach.state.phase, SetPhase.setComplete);
    });

    test('set.complete is critical so it outranks any form cue', () {
      final coach = SetCoach(plan(reps: '10'));
      final complete =
          repTo(coach, 10).firstWhere((c) => c.category == 'set.complete');
      expect(complete.priority, 0);
    });
  });

  group('overshoot', () {
    test('every extra rep re-cues while the phase stays setComplete', () {
      final coach = SetCoach(plan());
      repTo(coach, 12);

      final extra = repTo(coach, 15, from: 13);
      expect(categories(extra),
          ['set.overshoot', 'set.overshoot', 'set.overshoot']);
      expect(coach.state.phase, SetPhase.setComplete,
          reason: 'extra reps must not push the session forward');
      expect(coach.state.overshootReps, 3);
      expect(coach.state.isOvershooting, isTrue);
    });

    test('the nag escalates once the grace reps are used up', () {
      final coach = SetCoach(plan());
      repTo(coach, 12);
      final extra = repTo(coach, 12 + SetPlan.overshootGraceReps + 1, from: 13);
      expect(extra.first.text, contains('target was'));
      expect(extra.last.text, contains('Stop'));
    });

    test('reps keep pushing rest out — the countdown waits for the athlete', () {
      final coach = SetCoach(plan());
      repTo(coach, 12); // last rep at t=12000

      // Almost at the idle threshold, then another rep resets the wait.
      expect(coach.tick(12000 + SetPlan.restAutoStartIdleMs - 1), isEmpty);
      expect(coach.state.phase, SetPhase.setComplete);
      coach.onRepCount(13, 14000);
      expect(coach.tick(14000 + SetPlan.restAutoStartIdleMs - 1), isEmpty);
      expect(coach.state.phase, SetPhase.setComplete);

      coach.tick(14000 + SetPlan.restAutoStartIdleMs);
      expect(coach.state.phase, SetPhase.resting);
    });

    test('AMRAP never completes or overshoots on its own', () {
      final coach = SetCoach(plan(reps: 'AMRAP'));
      final cues = repTo(coach, 40);
      expect(cues, isEmpty);
      expect(coach.state.phase, SetPhase.working);
      expect(coach.state.repsThisSet, 40);
      expect(coach.state.hasTarget, isFalse);
    });
  });

  group('rest', () {
    /// Drives a coach to the start of rest after set 1.
    SetCoach resting({int sets = 3, int restSeconds = 60}) {
      final coach = SetCoach(plan(sets: sets, reps: '10', restSeconds: restSeconds));
      repTo(coach, 10);
      coach.tick(10000 + SetPlan.restAutoStartIdleMs);
      expect(coach.state.phase, SetPhase.resting);
      return coach;
    }

    test('counts down from the task\'s rest, not a default', () {
      final coach = resting(restSeconds: 60);
      final start = 10000 + SetPlan.restAutoStartIdleMs;
      expect(coach.state.restTotal, const Duration(seconds: 60));
      coach.tick(start + 20000);
      expect(coach.state.restRemaining, const Duration(seconds: 40));
    });

    test('speaks each countdown mark once', () {
      final coach = resting(restSeconds: 60);
      final start = 10000 + SetPlan.restAutoStartIdleMs;

      expect(coach.tick(start + 20000), isEmpty, reason: '40s left');
      expect(categories(coach.tick(start + 30000)), ['rest.countdown']);
      expect(coach.tick(start + 30500), isEmpty, reason: 'already spoken');
      expect(categories(coach.tick(start + 50000)), ['rest.countdown']);
      expect(categories(coach.tick(start + 57500)), ['rest.countdown']);
      expect(coach.tick(start + 58000), isEmpty);
    });

    test('reps during rest are ignored', () {
      final coach = resting();
      expect(coach.onRepCount(99, 20000), isEmpty);
      expect(coach.state.phase, SetPhase.resting);
      expect(coach.state.repsThisSet, 10, reason: 'the closed set is untouched');
    });

    test('zero on the clock starts the next set with a go cue', () {
      final coach = resting(restSeconds: 60);
      final start = 10000 + SetPlan.restAutoStartIdleMs;

      final cues = coach.tick(start + 60000);
      expect(categories(cues), ['rest.go']);
      expect(cues.single.priority, 0);
      expect(coach.state.phase, SetPhase.working);
      expect(coach.state.setIndex, 2);
      expect(coach.state.repsThisSet, 0);
    });

    test('+30s pushes the clock out and re-arms the countdown cues', () {
      final coach = resting(restSeconds: 60);
      final start = 10000 + SetPlan.restAutoStartIdleMs;

      expect(categories(coach.tick(start + 30000)), ['rest.countdown']);
      coach.extendRest(const Duration(seconds: 30), start + 30000);
      expect(coach.state.restRemaining, const Duration(seconds: 60));
      expect(categories(coach.tick(start + 60000)), ['rest.countdown'],
          reason: 'the 30s mark is due again after the extension');
    });

    test('skip rest jumps straight into the next set', () {
      final coach = resting();
      final cues = coach.startNextSet(20000);
      expect(categories(cues), ['rest.go']);
      expect(coach.state.phase, SetPhase.working);
      expect(coach.state.setIndex, 2);
    });

    test('the next set re-baselines even when the analyzer keeps counting', () {
      final coach = resting();
      coach.startNextSet(20000);
      // Analyzer was NOT reset: it is still reporting cumulative reps.
      coach.onRepCount(10, 21000);
      expect(coach.state.repsThisSet, 0);
      coach.onRepCount(12, 22000);
      expect(coach.state.repsThisSet, 2);
    });

    test('the next set re-baselines when the analyzer was reset', () {
      final coach = resting();
      coach.onAnalyzerReset(); // what WatchMeCubit does at the set boundary
      coach.startNextSet(20000);
      coach.onRepCount(1, 21000);
      coach.onRepCount(2, 22000);
      expect(coach.state.repsThisSet, 2,
          reason: 'the first rep of the new set must not be swallowed');
    });
  });

  group('session end', () {
    test('the last set completes the session instead of resting', () {
      final coach = SetCoach(plan(sets: 1, reps: '10'));
      repTo(coach, 10);
      final cues = coach.tick(10000 + SetPlan.restAutoStartIdleMs);

      expect(categories(cues), ['session.complete']);
      expect(coach.state.phase, SetPhase.allSetsComplete);
      expect(coach.state.isFinished, isTrue);
    });

    test('walks all three sets and lands on complete', () {
      final coach = SetCoach(plan(sets: 3, reps: '10', restSeconds: 60));
      var t = 0;

      for (var set = 1; set <= 3; set++) {
        expect(coach.state.setIndex, set);
        for (var rep = 1; rep <= 10; rep++) {
          t += 1000;
          coach.onRepCount(rep, t);
        }
        t += SetPlan.restAutoStartIdleMs;
        coach.tick(t);
        // Mirrors WatchMeCubit: the analyzer is finalized and reset at the set
        // boundary, so the next set's counts start from 1 again.
        coach.onAnalyzerReset();
        if (set < 3) {
          expect(coach.state.phase, SetPhase.resting);
          t += 60000;
          coach.tick(t);
          expect(coach.state.phase, SetPhase.working);
        }
      }

      expect(coach.state.phase, SetPhase.allSetsComplete);
    });

    test('ending the last set early still finishes the session', () {
      final coach = SetCoach(plan(sets: 1, reps: 'AMRAP'));
      repTo(coach, 7);
      final cues = coach.endSet(9000);
      expect(categories(cues), ['session.complete']);
      expect(coach.state.phase, SetPhase.allSetsComplete);
    });

    test('nothing is emitted once the session is over', () {
      final coach = SetCoach(plan(sets: 1, reps: '10'));
      repTo(coach, 10);
      coach.tick(10000 + SetPlan.restAutoStartIdleMs);

      expect(coach.onRepCount(11, 20000), isEmpty);
      expect(coach.tick(30000), isEmpty);
      expect(coach.startNextSet(30000), isEmpty);
      expect(coach.state.phase, SetPhase.allSetsComplete);
    });
  });

  group('endSet', () {
    test('an AMRAP set ends on demand and rests', () {
      final coach = SetCoach(plan(sets: 2, reps: 'AMRAP', restSeconds: 60));
      repTo(coach, 15);
      coach.endSet(16000);
      expect(coach.state.phase, SetPhase.resting);
      expect(coach.state.restRemaining, const Duration(seconds: 60));
    });
  });

  group('reset', () {
    test('returns the coach to set 1, working, with no reps', () {
      final coach = SetCoach(plan());
      repTo(coach, 12);
      coach.tick(12000 + SetPlan.restAutoStartIdleMs);
      coach.reset();

      expect(coach.state.phase, SetPhase.working);
      expect(coach.state.setIndex, 1);
      expect(coach.state.repsThisSet, 0);
      expect(coach.state.overshootReps, 0);
    });
  });

  group('SetCoachState', () {
    test('labels the target the way the HUD shows it', () {
      expect(SetCoach(plan(reps: '8-12')).state.targetLabel, '8-12');
      expect(SetCoach(plan(reps: '10')).state.targetLabel, '10');
      expect(SetCoach(plan(reps: 'AMRAP')).state.targetLabel, isNull);
    });

    test('nextSetIndex is null on the last set', () {
      expect(SetCoach(plan(sets: 3)).state.nextSetIndex, 2);
      expect(SetCoach(plan(sets: 1)).state.nextSetIndex, isNull);
    });
  });
}
