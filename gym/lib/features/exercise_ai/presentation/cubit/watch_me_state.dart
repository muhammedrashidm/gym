import '../../domain/config/ai_config.dart';
import '../../domain/entities/analysis.dart';
import '../../domain/entities/pose_frame.dart';
import '../../domain/session/set_coach.dart';
import '../../domain/session/set_plan.dart';

enum WatchMeStatus {
  initializing,
  permissionDenied,
  unsupportedConfig,
  running,
  finishing,
  finished,
  error,
}

/// Immutable UI state for the Watch Me camera page. Plain class (hand-written
/// [copyWith]) to avoid adding a codegen dependency to this feature.
class WatchMeState {
  final WatchMeStatus status;
  final AiConfig? config;
  final SetPlan? plan;
  final SetCoachState? coach;
  final AnalysisFrameResult? frame;
  final PoseFrame? pose;
  final SessionAnalysisResult? result;
  final String? message; // error text or transient coaching banner

  const WatchMeState({
    this.status = WatchMeStatus.initializing,
    this.config,
    this.plan,
    this.coach,
    this.frame,
    this.pose,
    this.result,
    this.message,
  });

  bool get isLive => status == WatchMeStatus.running;
  bool get isResting => coach?.isResting ?? false;

  /// Reps in the *current* set once a plan is coaching; falls back to the
  /// analyzer's running count when there is no coach yet.
  int get repCount => coach?.repsThisSet ?? frame?.repCount ?? 0;
  double get overallScore => frame?.scores.overall ?? 0;

  WatchMeState copyWith({
    WatchMeStatus? status,
    AiConfig? config,
    SetPlan? plan,
    SetCoachState? coach,
    AnalysisFrameResult? frame,
    PoseFrame? pose,
    SessionAnalysisResult? result,
    String? message,
  }) {
    return WatchMeState(
      status: status ?? this.status,
      config: config ?? this.config,
      plan: plan ?? this.plan,
      coach: coach ?? this.coach,
      frame: frame ?? this.frame,
      pose: pose ?? this.pose,
      result: result ?? this.result,
      message: message,
    );
  }
}
