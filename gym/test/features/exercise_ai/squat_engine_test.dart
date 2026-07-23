import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/exercise_ai/domain/config/ai_config.dart';
import 'package:gym/features/exercise_ai/domain/config/ai_config_parser.dart';
import 'package:gym/features/exercise_ai/domain/engine/analyzers.dart';
import 'package:gym/features/exercise_ai/domain/entities/landmark.dart';
import 'package:gym/features/exercise_ai/domain/entities/pose_frame.dart';

/// The squat config from the design doc (Appendix A), trimmed to the fields
/// the engine consumes. Condition windows are left at defaults.
Map<String, dynamic> squatConfig() => {
      'analyzerType': 'DYNAMIC_REP',
      'camera': {'position': 'SIDE', 'fullBodyRequired': true},
      'poseRequirements': {
        'requiredLandmarks': ['HIP_L', 'KNEE_L', 'ANKLE_L', 'SHOULDER_L'],
        'minimumVisibilityScore': 0.6,
        'minimumLandmarkConfidence': 0.5,
      },
      'angles': [
        {
          'id': 'kneeAngle',
          'vertexLandmark': 'KNEE_L',
          'aLandmark': 'HIP_L',
          'bLandmark': 'ANKLE_L'
        },
        {
          'id': 'hipAngle',
          'vertexLandmark': 'HIP_L',
          'aLandmark': 'SHOULDER_L',
          'bLandmark': 'KNEE_L'
        },
      ],
      'stateMachine': {
        'initialState': 'STANDING',
        'states': ['STANDING', 'DESCENDING', 'BOTTOM', 'ASCENDING'],
        'transitions': [
          {
            'from': 'STANDING',
            'to': 'DESCENDING',
            'condition': {'angleId': 'kneeAngle', 'op': 'falling', 'value': 160}
          },
          {
            'from': 'DESCENDING',
            'to': 'BOTTOM',
            'condition': {'angleId': 'kneeAngle', 'op': '<', 'value': 95}
          },
          {
            'from': 'BOTTOM',
            'to': 'ASCENDING',
            'condition': {'angleId': 'kneeAngle', 'op': 'rising', 'value': 100}
          },
          {
            'from': 'ASCENDING',
            'to': 'STANDING',
            'condition': {'angleId': 'kneeAngle', 'op': '>', 'value': 168}
          },
        ],
      },
      'repRules': {
        'topStateId': 'STANDING',
        'bottomStateId': 'BOTTOM',
        'countOn': 'ASCENDING->STANDING',
        'minimumRepDurationMs': 700,
        'maximumRepDurationMs': 6000,
      },
      'tempo': {
        'eccentricDurationMs': 2000,
        'concentricDurationMs': 1000,
        'toleranceMs': 600
      },
      'formRules': [
        {
          'id': 'depth',
          'type': 'romDepth',
          'params': {'angleId': 'kneeAngle', 'minAngle': 95},
          'severity': 'HIGH',
          'message': 'Go deeper'
        },
        {
          'id': 'backPosture',
          'type': 'angleThreshold',
          'params': {'angleId': 'hipAngle', 'min': 45},
          'severity': 'HIGH',
          'message': 'Chest up'
        },
      ],
      'scoring': {
        'repWeight': 0.4,
        'formWeight': 0.4,
        'tempoWeight': 0.1,
        'romWeight': 0.1
      },
      'feedbackRules': [
        {
          'id': 'goodRep',
          'when': 'rep completed AND repScore>80',
          'message': 'Great rep!',
          'priority': 3
        },
      ],
      'voice': {'enabled': true, 'coolDownMs': 2500, 'maximumFeedbacksPerRep': 1},
    };

/// Builds a side-on pose frame with a given knee angle (degrees). Only the
/// ankle moves; hip/knee/shoulder are fixed so hipAngle stays ~180 (posture OK).
///
/// The image size is square on purpose: the joints below are laid out in
/// isotropic normalized space, so a square frame is what makes the measured
/// knee angle come out as exactly [kneeDeg].
PoseFrame frameWithKnee(double kneeDeg, int tMs) {
  const knee = [0.5, 0.5];
  const hip = [0.5, 0.7];
  const shoulder = [0.5, 0.9];
  final rad = kneeDeg * math.pi / 180.0;
  final ankle = [0.5 + 0.2 * math.sin(rad), 0.5 + 0.2 * math.cos(rad)];

  Landmark lm(LandmarkType t, List<double> p) => Landmark(
        type: t,
        x: p[0],
        y: p[1],
        visibility: 1,
        presence: 1,
      );

  return PoseFrame(
    landmarks: [
      lm(LandmarkType.leftHip, hip),
      lm(LandmarkType.leftKnee, knee),
      lm(LandmarkType.leftAnkle, ankle),
      lm(LandmarkType.leftShoulder, shoulder),
    ],
    timestampMs: tMs,
    imageSize: const ImageSize(1000, 1000),
  );
}

void main() {
  group('AiConfigParser', () {
    test('parses the squat config without throwing', () {
      final config = AiConfigParser.parse(squatConfig());
      expect(config.analyzerType, AnalyzerType.dynamicRep);
      expect(config.angles.length, 2);
      expect(config.stateMachine.states, contains('BOTTOM'));
      expect(config.repRules?.countOnFrom, 'ASCENDING');
      expect(config.repRules?.countOnTo, 'STANDING');
    });

    test('isSupported gates on angles + analyzerType', () {
      expect(AiConfigParser.isSupported('DYNAMIC_REP', squatConfig()), isTrue);
      expect(AiConfigParser.isSupported('DYNAMIC_REP', {}), isFalse);
      expect(AiConfigParser.isSupported('NONSENSE', squatConfig()), isFalse);
    });

    test('throws on malformed angle landmark', () {
      final bad = squatConfig();
      (bad['angles'] as List)[0] = {
        'id': 'kneeAngle',
        'vertexLandmark': 'NOT_A_JOINT',
        'aLandmark': 'HIP_L',
        'bLandmark': 'ANKLE_L',
      };
      expect(() => AiConfigParser.parse(bad), throwsA(isA<AiConfigException>()));
    });
  });

  group('DynamicRepAnalyzer — squat', () {
    // Knee-angle waveform: stand → descend → hold bottom → ascend → stand.
    final wave = <double>[175, 168, 150, 120, 90, 90, 90, 90, 110, 150, 170, 175];

    test('counts one valid rep through the full state cycle', () {
      final config = AiConfigParser.parse(squatConfig());
      final analyzer = DynamicRepAnalyzer(config);

      final statesSeen = <String>{};
      for (var i = 0; i < wave.length; i++) {
        final r = analyzer.analyze(frameWithKnee(wave[i], i * 100));
        statesSeen.add(r.currentStateId);
      }

      // Visited every movement phase — proves the config-driven FSM works.
      expect(statesSeen, containsAll(['DESCENDING', 'BOTTOM', 'ASCENDING']));

      final result = analyzer.finalizeResult();
      expect(result.totalReps, 1);
      expect(result.validReps, 1);
      expect(result.reps.single.rom, greaterThan(50));
      expect(result.overallScore, greaterThan(0));
    });

    test('rejects a rep below minimumRepDurationMs', () {
      // Same ~800ms rep, but the config now demands >=2000ms per rep.
      final cfg = squatConfig();
      (cfg['repRules'] as Map)['minimumRepDurationMs'] = 2000;
      final analyzer = DynamicRepAnalyzer(AiConfigParser.parse(cfg));

      for (var i = 0; i < wave.length; i++) {
        analyzer.analyze(frameWithKnee(wave[i], i * 100));
      }

      final result = analyzer.finalizeResult();
      expect(result.totalReps, 1, reason: 'rep is still detected');
      expect(result.validReps, 0, reason: 'but flagged invalid: too fast');
    });

    test('counts two reps across two cycles', () {
      final config = AiConfigParser.parse(squatConfig());
      final analyzer = DynamicRepAnalyzer(config);

      var t = 0;
      for (var cycle = 0; cycle < 2; cycle++) {
        for (final a in wave) {
          analyzer.analyze(frameWithKnee(a, t));
          t += 100;
        }
      }
      expect(analyzer.finalizeResult().totalReps, 2);
    });

    // WatchMeCubit finalizes and resets the analyzer at every set boundary so
    // each set is scored on its own. This pins that the reset really does
    // isolate the sets rather than carrying reps forward.
    test('reset isolates one set from the next', () {
      final config = AiConfigParser.parse(squatConfig());
      final analyzer = DynamicRepAnalyzer(config);

      var t = 0;
      void runReps(int count) {
        for (var cycle = 0; cycle < count; cycle++) {
          for (final a in wave) {
            analyzer.analyze(frameWithKnee(a, t));
            t += 100;
          }
        }
      }

      runReps(2);
      final firstSet = analyzer.finalizeResult();
      expect(firstSet.totalReps, 2);

      analyzer.reset();
      runReps(3);
      final secondSet = analyzer.finalizeResult();
      expect(secondSet.totalReps, 3,
          reason: 'the second set counts only its own reps');
      expect(firstSet.totalReps, 2,
          reason: 'the banked first set is untouched by the reset');
    });
  });
}
