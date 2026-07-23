import '../entities/landmark.dart';
import '../entities/pose_frame.dart';
import '../entities/analysis.dart';
import '../config/ai_config.dart';

/// Gates whether a frame's pose is trustworthy enough to analyze.
///
/// If it isn't, the pipeline short-circuits and the UI shows framing guidance
/// instead of fabricating reps from garbage landmarks.
class PoseValidator {
  const PoseValidator();

  PoseValidationReport validate(PoseFrame frame, PoseRequirements req) {
    final missing = <LandmarkType>[];
    final lowConf = <LandmarkType>[];

    for (final type in req.requiredLandmarks) {
      final lm = frame[type];
      if (lm == null) {
        missing.add(type);
        continue;
      }
      if (lm.visibility < req.minimumVisibilityScore ||
          lm.confidence < req.minimumLandmarkConfidence) {
        lowConf.add(type);
      }
    }

    final valid = missing.isEmpty && lowConf.isEmpty;
    return PoseValidationReport(
      valid: valid,
      missing: missing,
      lowConfidence: lowConf,
    );
  }

  /// Framing guidance derived from a failed validation report.
  CameraGuidance? guidanceFor(PoseValidationReport report) {
    if (report.valid) return null;
    if (report.missing.isNotEmpty) {
      return const CameraGuidance(
          'STEP_INTO_FRAME', 'Step back so your whole body is visible');
    }
    return const CameraGuidance(
        'IMPROVE_VISIBILITY', 'Move to better lighting and face the camera');
  }
}
