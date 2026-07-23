import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/feedback/feedback.dart';
import '../../domain/ports/ports.dart';

/// [VoiceOutput] backed by on-device platform TTS (offline).
///
/// Critical (priority 0) cues interrupt whatever is speaking; lower-priority
/// cues are dropped if TTS is busy rather than queued stale.
class FlutterTtsVoiceOutput implements VoiceOutput {
  final FlutterTts _tts = FlutterTts();
  bool _busy = false;

  @override
  Future<void> init() async {
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => _busy = false);
    _tts.setCancelHandler(() => _busy = false);
    _tts.setErrorHandler((_) => _busy = false);
  }

  @override
  Future<void> speak(CoachMessage message) async {
    final isCritical = message.priority == 0;
    if (_busy && !isCritical) return; // drop, don't queue stale cues
    if (isCritical) await _tts.stop();
    _busy = true;
    await _tts.speak(message.text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _busy = false;
  }

  @override
  Future<void> dispose() async {
    await _tts.stop();
  }
}
