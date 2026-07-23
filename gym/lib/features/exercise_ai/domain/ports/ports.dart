import 'dart:typed_data';

import '../entities/pose_frame.dart';
import '../config/ai_config.dart';
import '../feedback/feedback.dart';

/// A raw camera image handed to the pose detector. Kept plugin-neutral so the
/// domain never imports `package:camera`.
class CameraFrame {
  final Uint8List bytes;
  final int width;
  final int height;
  final int rotationDegrees;
  final CameraImageFormat format;
  final int timestampMs;
  final bool isFrontCamera;
  final List<CameraPlane> planes;

  const CameraFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.rotationDegrees,
    required this.format,
    required this.timestampMs,
    required this.isFrontCamera,
    this.planes = const [],
  });
}

class CameraPlane {
  final Uint8List bytes;
  final int bytesPerRow;
  const CameraPlane(this.bytes, this.bytesPerRow);
}

enum CameraImageFormat { yuv420, nv21, bgra8888, unknown }

/// Turns camera frames into normalized [PoseFrame]s. V1 = ML Kit BlazePose.
abstract class PoseDetector {
  Future<void> init(PoseRequirements requirements);

  /// Returns null if no pose was found in the frame.
  Future<PoseFrame?> detect(CameraFrame frame);

  Future<void> dispose();
}

/// Provides a lifecycle-managed stream of camera frames.
abstract class CameraSource {
  Future<void> start({required bool frontFacing});
  Stream<CameraFrame> get frames;
  Future<void> stop();
  Future<void> dispose();
}

/// Speaks coaching messages. V1 = on-device `flutter_tts` (offline).
abstract class VoiceOutput {
  Future<void> init();
  Future<void> speak(CoachMessage message);
  Future<void> stop();
  Future<void> dispose();
}

/// V2 hook: on-device TFLite inference. V1 ships a no-op implementation so the
/// DI graph and pipeline are stable before any model exists.
abstract class MlClassifier {
  bool get isReady;
  Future<void> loadModel(String assetOrPath);

  /// Returns a class-probability vector for a feature vector, or empty if not
  /// ready (callers treat empty as "no ML signal").
  Future<List<double>> classify(List<double> features);

  Future<void> dispose();
}
