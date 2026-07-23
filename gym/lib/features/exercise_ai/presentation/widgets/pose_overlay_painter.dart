import 'package:flutter/material.dart';

import '../../domain/entities/landmark.dart';
import '../../domain/entities/pose_frame.dart';
import 'pose_projection.dart';

/// Draws the detected skeleton over the camera preview.
///
/// Landmarks arrive in normalized 0..1 space relative to the upright camera
/// image; [imageSize] is that image's size, needed to reproduce the preview's
/// `BoxFit.cover` crop. [mirror] states whether the displayed preview is
/// horizontally flipped (selfie view) — the page owns that decision.
class PoseOverlayPainter extends CustomPainter {
  final PoseFrame? pose;
  final Size imageSize;
  final bool mirror;
  final Color color;

  PoseOverlayPainter({
    required this.pose,
    required this.imageSize,
    required this.mirror,
    required this.color,
  });

  static const List<List<LandmarkType>> _edges = [
    [LandmarkType.leftShoulder, LandmarkType.rightShoulder],
    [LandmarkType.leftShoulder, LandmarkType.leftElbow],
    [LandmarkType.leftElbow, LandmarkType.leftWrist],
    [LandmarkType.rightShoulder, LandmarkType.rightElbow],
    [LandmarkType.rightElbow, LandmarkType.rightWrist],
    [LandmarkType.leftShoulder, LandmarkType.leftHip],
    [LandmarkType.rightShoulder, LandmarkType.rightHip],
    [LandmarkType.leftHip, LandmarkType.rightHip],
    [LandmarkType.leftHip, LandmarkType.leftKnee],
    [LandmarkType.leftKnee, LandmarkType.leftAnkle],
    [LandmarkType.rightHip, LandmarkType.rightKnee],
    [LandmarkType.rightKnee, LandmarkType.rightAnkle],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final p = pose;
    if (p == null) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final jointPaint = Paint()..color = color;

    Offset? project(LandmarkType t) {
      final lm = p[t];
      if (lm == null || lm.confidence < 0.3) return null;
      return projectNormalized(
        Offset(lm.x, lm.y),
        imageSize,
        size,
        mirror: mirror,
      );
    }

    for (final edge in _edges) {
      final a = project(edge[0]);
      final b = project(edge[1]);
      if (a != null && b != null) canvas.drawLine(a, b, linePaint);
    }
    for (final lm in p.landmarks) {
      final o = project(lm.type);
      if (o != null) canvas.drawCircle(o, 5, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter old) =>
      old.pose != pose ||
      old.color != color ||
      old.mirror != mirror ||
      old.imageSize != imageSize;
}
