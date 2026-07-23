import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/exercise_ai/domain/engine/math.dart';
import 'package:gym/features/exercise_ai/domain/entities/landmark.dart';
import 'package:gym/features/exercise_ai/domain/entities/pose_frame.dart';

/// Angles are measured on landmarks normalized to 0..1, where x and y were
/// divided by different numbers. Measuring in that space bends the result by
/// the image aspect; these tests pin the aspect correction down.
void main() {
  Landmark at(LandmarkType t, double x, double y) =>
      Landmark(type: t, x: x, y: y, visibility: 1, presence: 1);

  /// A right angle laid out in *pixel* space, then normalized against
  /// [imageSize] — so it stays a right angle whatever the aspect is.
  ({Landmark vertex, Landmark a, Landmark b}) rightAngle(ImageSize imageSize) {
    Landmark px(LandmarkType t, double x, double y) =>
        at(t, x / imageSize.width, y / imageSize.height);
    return (
      vertex: px(LandmarkType.leftKnee, 200, 400),
      a: px(LandmarkType.leftHip, 200, 200), // straight up from the vertex
      b: px(LandmarkType.leftAnkle, 400, 400), // straight right of the vertex
    );
  }

  group('AngleCalculator.angleAt', () {
    test('reads 90° on a square image', () {
      const size = ImageSize(1000, 1000);
      final j = rightAngle(size);
      expect(AngleCalculator.angleAt(j.vertex, j.a, j.b, size), closeTo(90, 1e-6));
    });

    test('still reads 90° on a 3:4 image — the aspect distortion is gone', () {
      const size = ImageSize(480, 640);
      final j = rightAngle(size);
      expect(AngleCalculator.angleAt(j.vertex, j.a, j.b, size), closeTo(90, 1e-6));
    });

    test('a straight limb reads 180° regardless of aspect', () {
      const size = ImageSize(480, 640);
      final vertex = at(LandmarkType.leftKnee, 0.5, 0.5);
      final a = at(LandmarkType.leftHip, 0.5, 0.2);
      final b = at(LandmarkType.leftAnkle, 0.5, 0.8);
      expect(AngleCalculator.angleAt(vertex, a, b, size), closeTo(180, 1e-6));
    });
  });

  group('AngleCalculator.angleToVertical', () {
    test('a 45° segment in pixel space reads 45° on a non-square image', () {
      const size = ImageSize(480, 640);
      final from = at(LandmarkType.leftShoulder, 100 / 480, 100 / 640);
      final to = at(LandmarkType.leftHip, 200 / 480, 200 / 640);
      expect(AngleCalculator.angleToVertical(from, to, size), closeTo(45, 1e-6));
    });

    test('a vertical segment reads 0°', () {
      const size = ImageSize(480, 640);
      final from = at(LandmarkType.leftShoulder, 0.5, 0.2);
      final to = at(LandmarkType.leftHip, 0.5, 0.6);
      expect(AngleCalculator.angleToVertical(from, to, size), closeTo(0, 1e-6));
    });
  });

  group('AngleCalculator.signedAngleAt', () {
    test('flipping the two rays flips the sign', () {
      const size = ImageSize(480, 640);
      final j = rightAngle(size);
      final forward = AngleCalculator.signedAngleAt(j.vertex, j.a, j.b, size);
      final reversed = AngleCalculator.signedAngleAt(j.vertex, j.b, j.a, size);
      expect(forward.abs(), closeTo(90, 1e-6));
      expect(reversed, closeTo(-forward, 1e-6));
    });
  });
}
