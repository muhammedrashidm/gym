import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show DeviceOrientation;

import '../../domain/ports/ports.dart';

/// [CameraSource] backed by the official `camera` plugin.
///
/// Emits plugin-neutral [CameraFrame]s from `startImageStream`. Uses NV21 on
/// Android and BGRA8888 on iOS — the two formats ML Kit accepts directly.
class CameraSourceImpl implements CameraSource {
  CameraController? _controller;
  final StreamController<CameraFrame> _frames =
      StreamController<CameraFrame>.broadcast();
  bool _streaming = false;
  bool _frontFacing = false;

  @override
  Stream<CameraFrame> get frames => _frames.stream;

  /// The live controller, for building a `CameraPreview` in the UI. This is the
  /// one place a Flutter type is deliberately exposed — the preview cannot be
  /// abstracted behind the plugin-neutral port.
  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// The lens actually opened. The UI mirrors the preview off this rather than
  /// off config, so the two can never disagree.
  CameraLensDirection? get lensDirection =>
      _controller?.description.lensDirection;

  @override
  Future<void> start({required bool frontFacing}) async {
    _frontFacing = frontFacing;
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No cameras available on this device');
    }
    final camera = cameras.firstWhere(
      (c) =>
          c.lensDirection ==
          (frontFacing ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      camera,
      ResolutionPreset.medium, // 480p-ish: enough for pose, cheap to process
      enableAudio: false,
      fps: 15,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller = controller;
    await controller.initialize();

    await controller.startImageStream(_onImage);
    _streaming = true;
  }

  void _onImage(CameraImage image) {
    if (_frames.isClosed) return;
    final controller = _controller;
    if (controller == null) return;

    final format = _mapFormat(image.format.group);
    // For NV21/BGRA the first plane holds the full buffer ML Kit needs.
    final bytes =
        image.planes.isNotEmpty ? image.planes.first.bytes : Uint8List(0);

    _frames.add(CameraFrame(
      bytes: bytes,
      width: image.width,
      height: image.height,
      rotationDegrees: _rotationDegrees(controller),
      format: format,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      isFrontCamera: _frontFacing,
      planes: [
        for (final p in image.planes) CameraPlane(p.bytes, p.bytesPerRow),
      ],
    ));
  }

  static const Map<DeviceOrientation, int> _orientationDegrees = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// Rotation that turns the streamed buffer upright, as ML Kit expects.
  ///
  /// The raw sensor orientation is only correct in portrait-up; on Android it
  /// has to be compensated by the current device orientation, and the sign of
  /// that compensation flips for the front lens. iOS hands over buffers already
  /// in sensor orientation, so the sensor value is used as-is.
  int _rotationDegrees(CameraController controller) {
    final sensorOrientation = controller.description.sensorOrientation;
    if (!Platform.isAndroid) return sensorOrientation;

    final compensation =
        _orientationDegrees[controller.value.deviceOrientation] ?? 0;
    final isFront =
        controller.description.lensDirection == CameraLensDirection.front;
    return isFront
        ? (sensorOrientation + compensation) % 360
        : (sensorOrientation - compensation + 360) % 360;
  }

  CameraImageFormat _mapFormat(ImageFormatGroup group) {
    switch (group) {
      case ImageFormatGroup.nv21:
        return CameraImageFormat.nv21;
      case ImageFormatGroup.yuv420:
        return CameraImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return CameraImageFormat.bgra8888;
      default:
        return CameraImageFormat.unknown;
    }
  }

  @override
  Future<void> stop() async {
    if (_streaming && (_controller?.value.isStreamingImages ?? false)) {
      await _controller?.stopImageStream();
    }
    _streaming = false;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller?.dispose();
    _controller = null;
    if (!_frames.isClosed) await _frames.close();
  }
}
