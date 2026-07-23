import 'landmark.dart';

/// Pixel dimensions of the source image the pose was detected in. Kept as a
/// plain value object so the pure engine never imports `dart:ui`.
class ImageSize {
  final double width;
  final double height;
  const ImageSize(this.width, this.height);
}

/// A normalized, engine-ready snapshot of a single detected pose.
///
/// Landmarks are stored sparsely in a map keyed by [LandmarkType]; a frame may
/// legitimately be missing points (occlusion), which [PoseValidator] handles.
class PoseFrame {
  final Map<LandmarkType, Landmark> _landmarks;
  final int timestampMs;
  final ImageSize imageSize;

  PoseFrame({
    required List<Landmark> landmarks,
    required this.timestampMs,
    required this.imageSize,
  }) : _landmarks = {for (final l in landmarks) l.type: l};

  Landmark? operator [](LandmarkType t) => _landmarks[t];

  bool has(LandmarkType t) => _landmarks.containsKey(t);

  Iterable<Landmark> get landmarks => _landmarks.values;

  int get length => _landmarks.length;
}
