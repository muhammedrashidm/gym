/// The 33 BlazePose body landmarks, in the exact index order emitted by
/// ML Kit's `PoseLandmarkType`, so mapping from the detector is index-based.
///
/// This enum is the on-device vocabulary. Backend `aiConfigJson` references
/// landmarks by string name (e.g. `"KNEE_L"`, `"LEFT_KNEE"`, `"leftKnee"`);
/// [LandmarkType.fromConfig] normalizes all of those to a single value.
enum LandmarkType {
  nose,
  leftEyeInner,
  leftEye,
  leftEyeOuter,
  rightEyeInner,
  rightEye,
  rightEyeOuter,
  leftEar,
  rightEar,
  leftMouth,
  rightMouth,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftPinky,
  rightPinky,
  leftIndex,
  rightIndex,
  leftThumb,
  rightThumb,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftHeel,
  rightHeel,
  leftFootIndex,
  rightFootIndex;

  /// Resolves a config landmark name to a [LandmarkType], tolerating the
  /// naming styles the backend or authors may use. Returns `null` for unknown
  /// names so the parser can surface a precise validation error.
  static LandmarkType? fromConfig(String raw) {
    final key = raw.trim().toUpperCase().replaceAll(RegExp(r'[\s]+'), '_');
    return _aliases[key] ?? _byEnumName[key];
  }

  static final Map<String, LandmarkType> _byEnumName = {
    for (final v in LandmarkType.values) _screamingSnake(v.name): v,
  };

  static String _screamingSnake(String camel) => camel
      .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}')
      .toUpperCase()
      .replaceFirst(RegExp('^_'), '');

  /// Suffix-style aliases: `KNEE_L` / `L_KNEE` → leftKnee, etc.
  static final Map<String, LandmarkType> _aliases = () {
    final map = <String, LandmarkType>{};
    void add(String base, LandmarkType left, LandmarkType right) {
      map['${base}_L'] = left;
      map['L_$base'] = left;
      map['LEFT_$base'] = left;
      map['${base}_LEFT'] = left;
      map['${base}_R'] = right;
      map['R_$base'] = right;
      map['RIGHT_$base'] = right;
      map['${base}_RIGHT'] = right;
    }

    add('SHOULDER', LandmarkType.leftShoulder, LandmarkType.rightShoulder);
    add('ELBOW', LandmarkType.leftElbow, LandmarkType.rightElbow);
    add('WRIST', LandmarkType.leftWrist, LandmarkType.rightWrist);
    add('HIP', LandmarkType.leftHip, LandmarkType.rightHip);
    add('KNEE', LandmarkType.leftKnee, LandmarkType.rightKnee);
    add('ANKLE', LandmarkType.leftAnkle, LandmarkType.rightAnkle);
    add('HEEL', LandmarkType.leftHeel, LandmarkType.rightHeel);
    add('EAR', LandmarkType.leftEar, LandmarkType.rightEar);
    add('EYE', LandmarkType.leftEye, LandmarkType.rightEye);
    add('FOOT_INDEX', LandmarkType.leftFootIndex, LandmarkType.rightFootIndex);
    map['NOSE'] = LandmarkType.nose;
    return map;
  }();
}

/// A single detected body point in normalized image space (0..1), with an
/// optional depth [z] (relative, roughly hip-centered) and detector-provided
/// [visibility] / [presence] likelihoods in 0..1.
class Landmark {
  final LandmarkType type;
  final double x;
  final double y;
  final double z;
  final double visibility;
  final double presence;

  const Landmark({
    required this.type,
    required this.x,
    required this.y,
    this.z = 0,
    this.visibility = 0,
    this.presence = 0,
  });

  /// Combined confidence used by validation and angle weighting.
  double get confidence => visibility < presence ? visibility : presence;

  @override
  String toString() =>
      'Landmark(${type.name}, x:${x.toStringAsFixed(3)}, y:${y.toStringAsFixed(3)}, '
      'vis:${visibility.toStringAsFixed(2)})';
}
