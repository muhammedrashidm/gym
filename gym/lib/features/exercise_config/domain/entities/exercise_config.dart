import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_config.freezed.dart';

/// An admin-curated "Watch Me" analysis configuration a trainer can attach to a
/// task. Mirrors the backend `ExerciseConfigSummaryDto` shape (see
/// `server/docs/exercise-config-api-plan.md`) — deliberately without
/// `aiConfigJson`, which is only fetched by the camera/analysis flow.
///
/// [mediaUrl] is a stable, cacheable URL (PUBLIC media driver).
@freezed
class ExerciseConfig with _$ExerciseConfig {
  const factory ExerciseConfig({
    required String id,
    required String name,
    String? description,
    // "DYNAMIC_REP" | "STATIC_HOLD" | "COMPOUND_MOVEMENT" | "CARDIO_MOVEMENT"
    required String analyzerType,
    required Map<String,dynamic> aiConfigJson,
    @Default(<String>[]) List<String> keywords,
    required String mediaUrl,
  }) = _ExerciseConfig;
}
