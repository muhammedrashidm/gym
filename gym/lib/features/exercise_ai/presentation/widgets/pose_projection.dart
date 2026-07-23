import 'dart:math' as math;
import 'dart:ui';

/// Maps a normalized (0..1) point in the camera image onto the canvas the
/// preview is painted on.
///
/// The preview is laid out with `BoxFit.cover`, so it is scaled up until it
/// fills the canvas and the overflowing axis is cropped evenly on both sides.
/// The overlay has to reproduce that exact transform or the skeleton drifts
/// away from the body — on a 3:4 image over a tall phone screen the horizontal
/// crop alone is ~20% per side.
///
/// [mirror] means the *displayed* preview is flipped horizontally relative to
/// the raw sensor image (selfie view).
Offset projectNormalized(
  Offset point,
  Size imageSize,
  Size canvasSize, {
  required bool mirror,
}) {
  if (imageSize.width <= 0 || imageSize.height <= 0) return point;

  final scale = math.max(
    canvasSize.width / imageSize.width,
    canvasSize.height / imageSize.height,
  );
  final drawnWidth = imageSize.width * scale;
  final drawnHeight = imageSize.height * scale;
  final dx = (canvasSize.width - drawnWidth) / 2;
  final dy = (canvasSize.height - drawnHeight) / 2;

  final x = mirror ? (1 - point.dx) : point.dx;
  return Offset(dx + x * drawnWidth, dy + point.dy * drawnHeight);
}
