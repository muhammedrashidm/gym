import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/exercise_ai/presentation/widgets/pose_projection.dart';

/// Regression cover for the overlay drifting off the body: the skeleton has to
/// go through the same `BoxFit.cover` transform as the preview it sits on.
void main() {
  // A 3:4 portrait camera image on a tall 1080x2400 phone screen — the real
  // case from the AI coach screen.
  const image = Size(480, 640);
  const canvas = Size(1080, 2400);

  group('projectNormalized', () {
    test('centre of the image lands at the centre of the canvas', () {
      final p = projectNormalized(
        const Offset(0.5, 0.5),
        image,
        canvas,
        mirror: false,
      );
      expect(p.dx, closeTo(540, 0.001));
      expect(p.dy, closeTo(1200, 0.001));
    });

    test('cover crops the overflowing axis evenly on both sides', () {
      // scale = max(1080/480, 2400/640) = 3.75 → drawn 1800x2400, so 360px of
      // image is cropped off each side and only x in [0.2, 0.8] is visible.
      final left = projectNormalized(
        const Offset(0, 0),
        image,
        canvas,
        mirror: false,
      );
      expect(left.dx, closeTo(-360, 0.001));
      expect(left.dy, closeTo(0, 0.001));

      final visibleLeftEdge = projectNormalized(
        const Offset(0.2, 1),
        image,
        canvas,
        mirror: false,
      );
      expect(visibleLeftEdge.dx, closeTo(0, 0.001));
      expect(visibleLeftEdge.dy, closeTo(2400, 0.001));
    });

    test('mirror reflects horizontally about the canvas centre, y untouched', () {
      const point = Offset(0.3, 0.42);
      final plain = projectNormalized(point, image, canvas, mirror: false);
      final mirrored = projectNormalized(point, image, canvas, mirror: true);

      expect(mirrored.dy, closeTo(plain.dy, 0.001));
      expect((plain.dx + mirrored.dx) / 2, closeTo(canvas.width / 2, 0.001));
    });

    test('a square image on a square canvas is an identity scale', () {
      final p = projectNormalized(
        const Offset(0.25, 0.75),
        const Size(100, 100),
        const Size(100, 100),
        mirror: false,
      );
      expect(p.dx, closeTo(25, 0.001));
      expect(p.dy, closeTo(75, 0.001));
    });

    test('a degenerate image size does not blow up', () {
      const point = Offset(0.5, 0.5);
      expect(
        projectNormalized(point, Size.zero, canvas, mirror: false),
        point,
      );
    });
  });
}
