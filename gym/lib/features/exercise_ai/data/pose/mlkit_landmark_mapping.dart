import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;

import '../../domain/entities/landmark.dart';

/// ML Kit's [mlkit.PoseLandmarkType] enumerates the 33 BlazePose points in the
/// same order as our [LandmarkType], so we can map by index. This helper keeps
/// that assumption in one guarded place.
LandmarkType? mapMlkitLandmark(mlkit.PoseLandmarkType type) {
  final i = type.index;
  if (i < 0 || i >= LandmarkType.values.length) return null;
  return LandmarkType.values[i];
}
