import '../../domain/ports/ports.dart';

/// V1 placeholder for the V2 TFLite hook. It is never "ready" and returns no
/// signal, so pipeline stages that consult it become no-ops. This keeps the DI
/// graph and pipeline contracts stable before any model exists — V2 swaps in a
/// real `TfliteClassifier` with zero changes to callers.
class NoopMlClassifier implements MlClassifier {
  @override
  bool get isReady => false;

  @override
  Future<void> loadModel(String assetOrPath) async {}

  @override
  Future<List<double>> classify(List<double> features) async => const [];

  @override
  Future<void> dispose() async {}
}
