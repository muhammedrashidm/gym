import 'dart:math' as math;

import '../entities/landmark.dart';
import '../entities/pose_frame.dart';
import '../entities/analysis.dart';
import '../config/ai_config.dart';

/// Pure 2D vector helpers. No Flutter, no plugins.
class Vec2 {
  final double x;
  final double y;
  const Vec2(this.x, this.y);

  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  double dot(Vec2 o) => x * o.x + y * o.y;
  double cross(Vec2 o) => x * o.y - y * o.x;
  double get length => math.sqrt(x * x + y * y);
}

/// Angle + geometry calculations over landmarks.
///
/// Every method takes the [ImageSize] the landmarks were normalized against.
/// Angles are scale-invariant but *not* aspect-invariant: landmark x and y are
/// divided by different numbers, so measuring in raw 0..1 space squashes the
/// plane by the image aspect and bends every result (on a 3:4 frame a true 90°
/// knee reads anywhere from ~80° to ~100°). Converting back to pixels first
/// removes that distortion.
class AngleCalculator {
  const AngleCalculator();

  /// Interior angle (0..180°) at [vertex] formed by rays to [a] and [b].
  static double angleAt(
    Landmark vertex,
    Landmark a,
    Landmark b,
    ImageSize imageSize,
  ) {
    final v1 = _px(a, imageSize) - _px(vertex, imageSize);
    final v2 = _px(b, imageSize) - _px(vertex, imageSize);
    final denom = v1.length * v2.length;
    if (denom == 0) return 0;
    final cos = (v1.dot(v2) / denom).clamp(-1.0, 1.0);
    return _deg(math.acos(cos));
  }

  /// Signed angle (-180..180°) — positive/negative distinguishes direction
  /// (e.g. knee valgus vs varus). Uses the cross product sign.
  static double signedAngleAt(
    Landmark vertex,
    Landmark a,
    Landmark b,
    ImageSize imageSize,
  ) {
    final v1 = _px(a, imageSize) - _px(vertex, imageSize);
    final v2 = _px(b, imageSize) - _px(vertex, imageSize);
    final angle = _deg(math.atan2(v2.cross(v1), v2.dot(v1)));
    return angle;
  }

  /// Angle of segment [from]→[to] relative to the vertical axis (0° = straight
  /// up/down), useful for torso lean / shin angle.
  static double angleToVertical(Landmark from, Landmark to, ImageSize imageSize) {
    final d = _px(to, imageSize) - _px(from, imageSize);
    return _deg(math.atan2(d.x.abs(), d.y.abs()));
  }

  /// Normalized landmark → pixel space of the source image.
  static Vec2 _px(Landmark l, ImageSize s) => Vec2(l.x * s.width, l.y * s.height);

  /// Computes all configured angles for a frame. Confidence of each angle is
  /// the minimum confidence of its three landmarks; angles with a missing
  /// landmark are omitted.
  static Map<String, JointAngle> computeAll(
    PoseFrame frame,
    List<AngleSpec> specs,
  ) {
    final out = <String, JointAngle>{};
    for (final s in specs) {
      final vertex = frame[s.vertex];
      final a = frame[s.a];
      final b = frame[s.b];
      if (vertex == null || a == null || b == null) continue;
      final degrees = s.signed
          ? signedAngleAt(vertex, a, b, frame.imageSize)
          : angleAt(vertex, a, b, frame.imageSize);
      final conf = [vertex.confidence, a.confidence, b.confidence]
          .reduce((x, y) => x < y ? x : y);
      out[s.id] = JointAngle(id: s.id, degrees: degrees, confidence: conf);
    }
    return out;
  }

  static double _deg(double rad) => rad * 180.0 / math.pi;
}
