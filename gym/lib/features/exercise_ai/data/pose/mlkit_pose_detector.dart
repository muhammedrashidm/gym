import 'dart:ui' show Size;

// google_mlkit_pose_detection re-exports google_mlkit_commons (InputImage etc.),
// so all ML Kit types are reached through the single `mlkit` prefix.
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;

import '../../domain/entities/landmark.dart';
import '../../domain/entities/pose_frame.dart';
import '../../domain/config/ai_config.dart' show PoseRequirements;
import '../../domain/ports/ports.dart';
import 'mlkit_landmark_mapping.dart';

/// [PoseDetector] backed by ML Kit BlazePose (on-device, offline).
///
/// Converts a plugin-neutral [CameraFrame] into an ML Kit `InputImage`, runs
/// stream-mode detection, and normalizes the result into a [PoseFrame] with
/// coordinates in 0..1 image space (angles are scale-invariant, so this is
/// purely for consistent overlay/rule behavior).
class MlkitPoseDetector implements PoseDetector {
  mlkit.PoseDetector? _detector;

  @override
  Future<void> init(PoseRequirements requirements) async {
    _detector = mlkit.PoseDetector(
      options: mlkit.PoseDetectorOptions(
        mode: mlkit.PoseDetectionMode.stream,
        model: mlkit.PoseDetectionModel.base,
      ),
    );
  }

  @override
  Future<PoseFrame?> detect(CameraFrame frame) async {
    final detector = _detector;
    if (detector == null) return null;

    final rotation = _rotationOf(frame);
    final input = _toInputImage(frame, rotation);
    if (input == null) return null;

    final poses = await detector.processImage(input);
    if (poses.isEmpty) return null;

    final pose = poses.first;
    // ML Kit reports landmarks in the coordinate space of the image *after* the
    // rotation in the metadata is applied, so a 90°/270° rotation swaps the
    // dimensions the coordinates are relative to.
    final upright = _uprightSize(frame, rotation);
    final w = upright.width;
    final h = upright.height;

    final landmarks = <Landmark>[];
    for (final entry in pose.landmarks.entries) {
      final type = mapMlkitLandmark(entry.key);
      if (type == null) continue;
      final lm = entry.value;
      // Deliberately unclamped: ML Kit extrapolates joints slightly outside the
      // frame, and snapping them to the edge would bend the angles computed
      // from them. Both the overlay and the engine tolerate out-of-range values.
      landmarks.add(Landmark(
        type: type,
        x: lm.x / w,
        y: lm.y / h,
        z: lm.z,
        visibility: lm.likelihood,
        presence: lm.likelihood,
      ));
    }
    if (landmarks.isEmpty) return null;

    return PoseFrame(
      landmarks: landmarks,
      timestampMs: frame.timestampMs,
      imageSize: ImageSize(w, h),
    );
  }

  mlkit.InputImageRotation _rotationOf(CameraFrame frame) =>
      mlkit.InputImageRotationValue.fromRawValue(frame.rotationDegrees) ??
      mlkit.InputImageRotation.rotation0deg;

  /// Dimensions of the frame once [rotation] has been applied — the space ML
  /// Kit's landmark coordinates live in.
  ImageSize _uprightSize(CameraFrame frame, mlkit.InputImageRotation rotation) {
    final w = frame.width == 0 ? 1.0 : frame.width.toDouble();
    final h = frame.height == 0 ? 1.0 : frame.height.toDouble();
    final swapped = rotation == mlkit.InputImageRotation.rotation90deg ||
        rotation == mlkit.InputImageRotation.rotation270deg;
    return swapped ? ImageSize(h, w) : ImageSize(w, h);
  }

  mlkit.InputImage? _toInputImage(
    CameraFrame frame,
    mlkit.InputImageRotation rotation,
  ) {
    final format = _mlkitFormat(frame.format);
    if (format == null) return null;

    final bytesPerRow =
        frame.planes.isNotEmpty ? frame.planes.first.bytesPerRow : frame.width;

    return mlkit.InputImage.fromBytes(
      bytes: frame.bytes,
      metadata: mlkit.InputImageMetadata(
        size: Size(frame.width.toDouble(), frame.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  mlkit.InputImageFormat? _mlkitFormat(CameraImageFormat f) {
    switch (f) {
      case CameraImageFormat.nv21:
        return mlkit.InputImageFormat.nv21;
      case CameraImageFormat.yuv420:
        return mlkit.InputImageFormat.yuv420;
      case CameraImageFormat.bgra8888:
        return mlkit.InputImageFormat.bgra8888;
      case CameraImageFormat.unknown:
        return null;
    }
  }

  @override
  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
  }
}
