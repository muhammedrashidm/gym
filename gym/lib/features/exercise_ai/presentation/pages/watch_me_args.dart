import '../../../exercise_config/domain/entities/exercise_config.dart';
import '../../domain/session/set_plan.dart';

/// Navigation payload for the Watch Me route.
///
/// Carries both halves of what the coach needs: [config] is the admin-curated
/// exercise AI config (how to analyze the movement), [plan] is the athlete's
/// prescription for today, built from the backend workout task.
class WatchMeArgs {
  final ExerciseConfig config;
  final SetPlan plan;

  const WatchMeArgs({required this.config, required this.plan});
}
