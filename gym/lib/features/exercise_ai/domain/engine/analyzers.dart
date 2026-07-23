import '../entities/pose_frame.dart';
import '../entities/analysis.dart';
import '../config/ai_config.dart';
import 'pipeline.dart';
import 'scoring.dart';

/// Composes and runs an analysis pipeline for one exercise session.
///
/// A single [PipelineAnalyzer] can serve every exercise because the pipeline
/// composition and every threshold come from [AiConfig]. The typed subclasses
/// exist so behavior can be specialized per [AnalyzerType] WITHOUT modifying
/// existing analyzers (Open/Closed) — e.g. a future analyzer can override
/// [stageIds] or wrap [analyze].
abstract class ExerciseAnalyzer {
  AnalyzerType get type;
  AnalysisFrameResult analyze(PoseFrame frame);
  WorkoutAnalysisResult finalizeResult();
  void reset();
}

class PipelineAnalyzer implements ExerciseAnalyzer {
  @override
  final AnalyzerType type;
  final AiConfig config;
  final StageRegistry registry;
  final ScoringEngine _scoring;

  late AnalysisContext _ctx;
  late AnalysisPipeline _pipeline;

  PipelineAnalyzer({
    required this.type,
    required this.config,
    StageRegistry? registry,
    ScoringEngine? scoring,
  })  : registry = registry ?? StageRegistry(),
        _scoring = scoring ?? const ScoringEngine() {
    _rebuild();
  }

  /// Subclasses may override to customize the stage order/set.
  List<String> get stageIds => config.pipeline.stageIds;

  void _rebuild() {
    _ctx = AnalysisContext(config);
    _pipeline = registry.build(stageIds);
  }

  @override
  AnalysisFrameResult analyze(PoseFrame frame) =>
      _pipeline.run(_ctx, frame, frame.timestampMs);

  @override
  WorkoutAnalysisResult finalizeResult() => _scoring.finalize(
        _ctx.reps,
        config.scoring,
        _ctx.activeDuration,
        _ctx.topIssues,
      );

  @override
  void reset() => _rebuild();
}

class DynamicRepAnalyzer extends PipelineAnalyzer {
  DynamicRepAnalyzer(AiConfig config, {super.registry})
      : super(type: AnalyzerType.dynamicRep, config: config);
}

class StaticHoldAnalyzer extends PipelineAnalyzer {
  StaticHoldAnalyzer(AiConfig config, {super.registry})
      : super(type: AnalyzerType.staticHold, config: config);
}

class StaticPoseAnalyzer extends PipelineAnalyzer {
  StaticPoseAnalyzer(AiConfig config, {super.registry})
      : super(type: AnalyzerType.staticPose, config: config);
}

class CompoundMovementAnalyzer extends PipelineAnalyzer {
  CompoundMovementAnalyzer(AiConfig config, {super.registry})
      : super(type: AnalyzerType.compoundMovement, config: config);
}

class CardioMovementAnalyzer extends PipelineAnalyzer {
  CardioMovementAnalyzer(AiConfig config, {super.registry})
      : super(type: AnalyzerType.cardioMovement, config: config);
}

/// Creates the right analyzer for a config. Adding a new [AnalyzerType] means
/// adding one case here + one analyzer class — existing analyzers untouched.
class AnalyzerFactory {
  final StageRegistry registry;
  AnalyzerFactory({StageRegistry? registry})
      : registry = registry ?? StageRegistry();

  ExerciseAnalyzer create(AiConfig config) {
    switch (config.analyzerType) {
      case AnalyzerType.dynamicRep:
        return DynamicRepAnalyzer(config, registry: registry);
      case AnalyzerType.staticHold:
        return StaticHoldAnalyzer(config, registry: registry);
      case AnalyzerType.staticPose:
        return StaticPoseAnalyzer(config, registry: registry);
      case AnalyzerType.compoundMovement:
        return CompoundMovementAnalyzer(config, registry: registry);
      case AnalyzerType.cardioMovement:
        return CardioMovementAnalyzer(config, registry: registry);
    }
  }
}
