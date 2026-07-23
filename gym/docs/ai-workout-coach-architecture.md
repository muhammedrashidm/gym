# AI Workout Coach — Technical Design Document

**Module:** `exercise_ai` (on-device AI form coach for the Kinetic Flutter app)
**Author:** Staff Mobile + AI Engineering
**Status:** Design / Planning (no implementation)
**Date:** 2026-07-22

---

## 0. Reading Guide

This document specifies a **reusable, exercise-agnostic, backend-driven, offline-capable** on-device AI coaching SDK that plugs into the existing Kinetic app without violating its Clean Architecture, `dart_mediatr` CQRS flow, or `get_it`/`injectable` DI conventions.

The single most important design constraint:

> **The Flutter app contains ZERO exercise-specific logic.** Every threshold, landmark, angle, state, rep rule, tempo target, form check, score weight, and voice line is data read from `ExerciseConfig.aiConfigJson`. Adding a new exercise (or retuning an existing one) is a **backend config change**, never a client release.

The second constraint:

> **V2 (TFLite) and V3 (LLM coach agent) must slot in behind stable interfaces with no refactor of V1.** We achieve this with a *pipeline of pluggable stages* and a *strategy registry*, not inheritance trees.

---

## 1. High-Level Architecture

### 1.1 System context

```
┌──────────────────────────────────────────────────────────────────────┐
│ Backend (NestJS)                                                       │
│   ExerciseConfig { id, name, analyzerType, aiConfigJson, mediaUrl }    │
│   aiConfigJson is PRE-FETCHED upstream (day/task load), not at camera  │
└───────────────────────────────┬──────────────────────────────────────┘
                                 │  hydrated into Task.exerciseConfig
                                 │  before the session screen opens
┌────────────────────────────────▼──────────────────────────────────────┐
│ Flutter app  (feature: exercise_ai)                                    │
│                                                                        │
│  task_execution_page: taskData['aiConfig'] (ExerciseConfig, already    │
│      carrying a populated aiConfigJson)                                 │
│           │  [Watch Me] button → push WatchMePage(exerciseConfig)      │
│           ▼                                                             │
│  aiConfigJson ──► AiConfigParser ──► AiConfig (typed, validated)       │
│      (parsed ONCE in-memory at camera open — no network, no cache I/O) │
│                                    │                                   │
│         ┌──────────────────────────▼───────────────────────────┐      │
│         │  Analysis Pipeline (per-frame, runs off UI isolate)   │      │
│         │  Camera ► Pose ► Validate ► Angles ► Movement/State ►  │      │
│         │  Rep ► Form ► Tempo ► Score ► Feedback                 │      │
│         └──────────────────────────┬───────────────────────────┘      │
│                                    │ AnalysisFrameResult (stream)      │
│         ┌──────────────────────────▼───────────────────────────┐      │
│         │  Presentation (Cubit + CameraOverlay widgets)         │      │
│         └──────────────────────────┬───────────────────────────┘      │
│                                    │ WorkoutAnalysisResult (on finish) │
│         ┌──────────────────────────▼───────────────────────────┐      │
│         │  Mediator command ► persists to sqflite draft +       │      │
│         │  merges into workout_session TaskCompletionDraft      │      │
│         └───────────────────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Layered view (Clean Architecture, matching existing repo conventions)

```
presentation  →  domain  ←  data
     │             ▲          │
     │             │          │
     └────► Mediator (commands/queries) ────► repositories(iface) ◄── impl
                                                     │
                              ┌──────────────────────┴───────────────┐
                              │  exercise_ai/domain/engine  (PURE)    │
                              │  the CV/analysis brain — no Flutter,  │
                              │  no plugins, no I/O. Deterministic.   │
                              └───────────────────────────────────────┘
```

**Key architectural decision:** the analysis *engine* (angles, state machine, rep detection, form rules, scoring) lives in the **domain layer as pure Dart** — no `camera`, no `flutter`, no `ml_kit` imports. It consumes a normalized `PoseFrame` (list of landmarks) and a typed `AiConfig`, and emits `AnalysisFrameResult`. This is what makes it *ludicrously testable* (deterministic, replayable from recorded landmark JSON) and *portable* (the pose source and TTS are swappable adapters in the data layer).

### 1.3 The three seams that guarantee V1→V2→V3 without refactor

| Seam | Interface | V1 impl | V2 impl | V3 impl |
|---|---|---|---|---|
| **Pose source** | `PoseDetector` | ML Kit BlazePose | ML Kit (unchanged) | unchanged |
| **Analysis stages** | `AnalysisStage` (pipeline) | rule/math stages | + `TfliteFormStage`, `ExerciseClassifierStage` inserted into pipeline | unchanged |
| **Coaching brain** | `CoachStrategy` / `FeedbackSource` | rule-based `FeedbackEngine` | + ML score fusion | + `LlmCoachAgent` as an additional `FeedbackSource` |

Because every stage implements a common contract and is **selected by config** (`analyzerType` + `aiConfigJson.pipeline`), adding a stage is: (a) write the stage, (b) register it in the DI stage-registry, (c) reference it from backend config. No existing file changes.

---

## 2. Detailed Folder Structure

Follows the repo's `lib/features/<feature>/{data,domain,presentation}` convention. New feature: `exercise_ai`.

```
lib/features/exercise_ai/
│
├── domain/                         # PURE Dart. No Flutter, no plugins.
│   ├── entities/
│   │   ├── landmark.dart                 # Landmark {type, x, y, z, visibility, presence}
│   │   ├── pose_frame.dart               # PoseFrame {landmarks, timestampMs, imageSize}
│   │   ├── joint_angle.dart              # JointAngle {name, degrees, confidence}
│   │   ├── movement_state.dart           # MovementState (config-defined string id + kind)
│   │   ├── rep_event.dart                # RepEvent {index, durationMs, rom, tempo, formScore}
│   │   ├── form_finding.dart             # FormFinding {ruleId, severity, passed, message}
│   │   ├── analysis_frame_result.dart    # per-frame output (see §5)
│   │   └── workout_analysis_result.dart  # per-set/session aggregate output
│   │
│   ├── config/                     # Typed, validated view over aiConfigJson
│   │   ├── ai_config.dart                # root freezed model
│   │   ├── camera_config.dart
│   │   ├── pose_requirements.dart
│   │   ├── angle_spec.dart
│   │   ├── state_machine_config.dart     # states + transitions (declarative)
│   │   ├── rep_rules_config.dart
│   │   ├── tempo_config.dart
│   │   ├── form_rules_config.dart        # list of declarative FormRuleSpec
│   │   ├── scoring_config.dart
│   │   ├── feedback_config.dart
│   │   ├── voice_config.dart
│   │   ├── pipeline_config.dart          # ordered list of stage ids to run (V2 hook)
│   │   └── ai_config_parser.dart         # Map<String,dynamic> → AiConfig (+ AiConfigValidation)
│   │
│   ├── engine/                     # The analysis brain. Deterministic, unit-tested.
│   │   ├── pipeline/
│   │   │   ├── analysis_stage.dart       # abstract AnalysisStage (Chain-of-Responsibility)
│   │   │   ├── analysis_context.dart     # mutable per-frame + rolling session context
│   │   │   └── analysis_pipeline.dart    # runs ordered stages, short-circuits on invalid pose
│   │   ├── pose/
│   │   │   └── pose_normalizer.dart      # raw detector output → PoseFrame (scale/mirror/coord)
│   │   ├── validation/
│   │   │   ├── pose_validation_stage.dart
│   │   │   └── pose_validator.dart       # visibility/confidence/required-landmark gates
│   │   ├── angles/
│   │   │   ├── angle_stage.dart
│   │   │   ├── angle_calculator.dart     # 3-point angle, signed angle, vertical/horizontal ref
│   │   │   └── vector_math.dart          # dot/cross/norm helpers (pure)
│   │   ├── movement/
│   │   │   ├── movement_stage.dart
│   │   │   ├── state_machine.dart        # generic config-driven FSM (no exercise names)
│   │   │   └── movement_history.dart     # ring buffer of recent states/angles
│   │   ├── rep/
│   │   │   ├── rep_stage.dart
│   │   │   └── rep_detector.dart         # counts reps from state transitions + rules
│   │   ├── form/
│   │   │   ├── form_stage.dart
│   │   │   ├── form_rule_evaluator.dart  # evaluates declarative FormRuleSpec list
│   │   │   └── rules/                     # built-in rule primitives (angle<, angleBetween…)
│   │   │       ├── form_rule.dart         # abstract FormRule (registered by id)
│   │   │       └── builtin_rules.dart     # angleThreshold, alignment, romDepth, symmetry…
│   │   ├── tempo/
│   │   │   ├── tempo_stage.dart
│   │   │   └── tempo_analyzer.dart
│   │   ├── scoring/
│   │   │   ├── scoring_stage.dart
│   │   │   └── scoring_engine.dart       # weighted rep/form/tempo → 0..100
│   │   └── analyzers/                     # Strategy: composes stages per analyzerType
│   │       ├── exercise_analyzer.dart     # abstract ExerciseAnalyzer
│   │       ├── analyzer_factory.dart      # analyzerType → ExerciseAnalyzer (registry)
│   │       ├── dynamic_rep_analyzer.dart
│   │       ├── static_hold_analyzer.dart
│   │       ├── static_pose_analyzer.dart
│   │       ├── compound_movement_analyzer.dart
│   │       └── cardio_movement_analyzer.dart
│   │
│   ├── feedback/                   # Coaching brain (feedback selection & priority)
│   │   ├── feedback_source.dart          # abstract (rule-based now, LLM later — V3)
│   │   ├── rule_feedback_source.dart      # evaluates feedbackRules against results
│   │   ├── feedback_arbiter.dart          # cooldown, dedupe, priority, per-rep cap
│   │   └── coach_message.dart             # {text, priority, channel, ttlMs}
│   │
│   ├── ports/                      # Interfaces implemented in data layer (Hexagonal)
│   │   ├── pose_detector.dart            # abstract PoseDetector (Stream<PoseFrame>)
│   │   ├── camera_source.dart            # abstract CameraSource (frames + lifecycle)
│   │   ├── voice_output.dart             # abstract VoiceOutput (TTS)
│   │   └── ml_classifier.dart            # abstract MlClassifier (V2 TFLite hook)
│   │       # NOTE: no AnalysisConfigRepository — aiConfigJson is pre-fetched
│   │       # upstream and passed in via taskData['aiConfig']. Parsing is a
│   │       # pure in-memory transform (AiConfigParser), not an I/O port.
│   │
│   └── usecases/                   # dart_mediatr commands/queries
│       └── save_analysis_result.dart          # command → merges into workout_session draft
│           # No LoadAnalysisConfig query: config already in-context at launch.
│
├── data/
│   │   # No config remote/local datasource or repository here — the
│   │   # aiConfigJson fetch lives UPSTREAM (see §4.3), and exercise_ai only
│   │   # receives the already-hydrated ExerciseConfig via navigation.
│   ├── pose/
│   │   ├── mlkit_pose_detector.dart          # @Injectable(as: PoseDetector) — ML Kit
│   │   └── mlkit_landmark_mapping.dart        # ML Kit PoseLandmarkType → our LandmarkType
│   ├── camera/
│   │   └── camera_source_impl.dart           # `camera` plugin adapter, ImageFormat handling
│   ├── voice/
│   │   └── flutter_tts_voice_output.dart     # @Injectable(as: VoiceOutput)
│   ├── ml/
│   │   └── tflite_classifier.dart            # @Injectable(as: MlClassifier) — V2 (stub in V1)
│   └── isolate/
│       ├── analysis_isolate_worker.dart      # entrypoint run in isolate/compute
│       └── frame_codec.dart                  # cheap serialization for isolate boundary
│
└── presentation/
    ├── cubit/
    │   ├── watch_me_cubit.dart               # orchestrates camera↔pipeline↔feedback
    │   └── watch_me_state.dart               # freezed states
    ├── pages/
    │   └── watch_me_page.dart                # camera + overlay + rep/score HUD
    └── widgets/
        ├── pose_overlay_painter.dart         # CustomPainter draws skeleton
        ├── rep_counter_hud.dart
        ├── form_meter.dart
        └── camera_setup_coach.dart           # "step back", "full body", distance guidance
```

> **Note on placement:** `exercise_ai` is a sibling feature to `workout_session`. It does **not** own workout logging — on finish it hands a `WorkoutAnalysisResult` to a `workout_session` draft via a mediator command, keeping the existing local-first sqflite flow the single source of truth for session state.

---

## 3. Class Diagrams

### 3.1 Config layer (typed view over `aiConfigJson`)

```
AiConfig (freezed)
 ├─ analyzerType: AnalyzerType         (enum: dynamicRep|staticHold|compound|cardio|staticPose)
 ├─ camera: CameraConfig               { position, instruction, fullBodyRequired, minDistanceCm }
 ├─ poseRequirements: PoseRequirements { requiredLandmarks:[LandmarkType], minVisibility, minConfidence }
 ├─ angles: List<AngleSpec>            { id, vertexLandmark, aLandmark, bLandmark, signed }
 ├─ stateMachine: StateMachineConfig   { initialState, states:[StateSpec], transitions:[TransitionSpec] }
 ├─ repRules: RepRulesConfig           { topStateId, bottomStateId, minRepMs, maxRepMs, countOn }
 ├─ tempo: TempoConfig?                { eccentricMs, concentricMs, toleranceMs }
 ├─ formRules: List<FormRuleSpec>      { id, type, params:Map, severity, message }
 ├─ scoring: ScoringConfig             { repWeight, formWeight, tempoWeight, romWeight }
 ├─ feedbackRules: List<FeedbackRule>  { id, when(conditionExpr), message, priority }
 ├─ voice: VoiceConfig                 { enabled, cooldownMs, maxPerRep }
 └─ pipeline: PipelineConfig           { stageIds: [ 'validation','angles','movement','rep','form','tempo','scoring' ] }

TransitionSpec { from, to, condition: ConditionSpec }
ConditionSpec  { angleId, op(<,>,between,rising,falling), value, value2? }   // pure, declarative
```

`ConditionSpec` is the crux of "no hardcoded exercise logic": a squat's `STANDING→DESCENDING` transition is expressed as `{ angleId:"kneeAngle", op:"falling", value:160 }`. A pushup's `TOP→DESCENDING` is `{ angleId:"elbowAngle", op:"falling", value:160 }`. Same evaluator, different config.

### 3.2 Engine — pipeline & stages (Chain of Responsibility + Strategy)

```
                    ┌────────────────────┐
                    │  AnalysisStage      │◄── abstract
                    │  process(ctx)       │
                    └─────────▲──────────┘
      ┌───────────┬───────────┼───────────┬───────────┬───────────┐
 PoseValidation  Angle     Movement      Rep         Form       Tempo   Scoring
   Stage         Stage      Stage        Stage       Stage      Stage    Stage
                                                                 │
                                         (V2 inserts here:) TfliteFormStage, ClassifierStage

AnalysisPipeline
 ├─ stages: List<AnalysisStage>           (ordered per pipeline.stageIds)
 └─ run(PoseFrame, AiConfig) : AnalysisFrameResult
        for stage in stages:
           stage.process(ctx)             # short-circuits if pose invalid
        return ctx.buildResult()

AnalysisContext (mutable, per-session; frame-scoped fields reset each frame)
 ├─ config: AiConfig
 ├─ frame: PoseFrame
 ├─ angles: Map<String, JointAngle>
 ├─ stateMachine: StateMachine
 ├─ repDetector: RepDetector
 ├─ history: MovementHistory (ring buffer, ~2s)
 ├─ formFindings: List<FormFinding>
 └─ scores: RunningScores
```

### 3.3 Analyzer strategy (composes a pipeline per `analyzerType`)

```
ExerciseAnalyzer (abstract)
 ├─ buildPipeline(AiConfig) : AnalysisPipeline
 └─ analyze(PoseFrame) : AnalysisFrameResult      # delegates to pipeline

 ├── DynamicRepAnalyzer        # validation→angles→movement(FSM)→rep→form→tempo→scoring
 ├── StaticHoldAnalyzer        # validation→angles→holdTimer→form→scoring (no rep/FSM cycling)
 ├── StaticPoseAnalyzer        # validation→angles→poseMatch→form→scoring (yoga: match a target pose)
 ├── CompoundMovementAnalyzer  # multiple angle groups + multi-phase FSM (deadlift/bench)
 └── CardioMovementAnalyzer    # cadence/rhythm detection, rep=cycle, lighter form rules

AnalyzerFactory
 └─ create(AnalyzerType, AiConfig) : ExerciseAnalyzer     # registry map, DI-injected
```

Adding a new analyzer = new class + one registry entry. **Existing analyzers untouched** (Open/Closed).

### 3.4 Feedback (coaching brain)

```
FeedbackSource (abstract)
 └─ evaluate(AnalysisFrameResult, ctx) : List<CoachMessage>

 ├── RuleFeedbackSource     # V1: evaluates feedbackRules (ConditionSpec) → messages
 └── LlmCoachSource         # V3: async, summarizes trends → messages (additive source)

FeedbackArbiter
 ├─ sources: List<FeedbackSource>
 ├─ cooldownMs, maxPerRep, dedupeWindow
 └─ next(results) : CoachMessage?     # priority queue + cooldown + dedupe → 0/1 message/tick

VoiceOutput (port)  ◄── FlutterTtsVoiceOutput (data)
 └─ speak(CoachMessage)               # honors queue/interrupt policy
```

### 3.4b Session structure (sets, rest, alerts)

`domain/session/` sits *beside* the engine, not inside it: the analyzer counts reps and
knows nothing about sets. Both classes are pure Dart and clock-injected (`nowMs` arrives
as an argument, exactly like `FeedbackArbiter`), so the whole set/rest/overshoot behaviour
is unit-testable without a single timer — the caller owns the ticking.

```
SetPlan                                # the prescription for today
 ├─ totalSets, minReps, maxReps, restBetweenSets, repsLabel
 └─ SetPlan.fromTask(sets, reps, restSeconds)   # ← backend workout task ONLY

SetCoach                               # rep/set alert service
 ├─ state : SetCoachState { phase, setIndex, repsThisSet, restRemaining, overshootReps }
 ├─ onRepCount(cumulativeReps, nowMs) : List<CoachMessage>
 ├─ tick(nowMs)                        : List<CoachMessage>   # rest clock + post-set idle
 ├─ startNextSet / endSet / extendRest : List<CoachMessage>
 └─ onAnalyzerReset()                  # caller finalized+reset the analyzer

phases: working → setComplete → resting → working … → allSetsComplete
```

**The prescription comes from the backend task** (`Task.sets`, `Task.reps`,
`Task.restSeconds`), never from `aiConfigJson` — one source of truth for what the athlete
is supposed to do. Rest falls back to 90s only when the task omits it.

`SetCoach` emits ordinary `CoachMessage`s that the Cubit merges into the candidate list it
already hands to `FeedbackArbiter`, so no second voice path exists: priority 0 bypasses
cooldown and the per-rep cap, and `category` dedupe throttles the overshoot nag.

Two details worth keeping: reaching the rep target moves the phase to `setComplete`, **not**
straight to `resting` — rest only auto-starts once reps stop arriving, so extra reps re-cue
the overshoot alert instead of counting down against someone still lifting. And the Cubit
finalizes + resets the analyzer at each set boundary, giving one `WorkoutAnalysisResult`
per set inside a `SessionAnalysisResult`.

### 3.5 Ports & adapters (Hexagonal — keeps domain plugin-free)

```
domain/ports                          data adapters (@Injectable(as: …))
 PoseDetector          ◄────────────  MlkitPoseDetector
 CameraSource          ◄────────────  CameraSourceImpl (camera plugin)
 VoiceOutput           ◄────────────  FlutterTtsVoiceOutput
 MlClassifier          ◄────────────  TfliteClassifier (V2; no-op impl in V1)

 (No config-repo port: aiConfigJson is pre-fetched upstream and handed in via
  navigation; AiConfigParser turns it into AiConfig as a pure in-memory step.)
```

---

## 4. Dependency & Data-Flow Diagrams

### 4.1 Dependency direction (compile-time)

```
presentation ─────► domain (entities, usecases, ports, engine, config)
     │                 ▲
     │                 │  (implements ports, provides impls)
     └───► data ───────┘
data ─► plugins (camera, google_mlkit_pose_detection, flutter_tts, tflite_flutter, sqflite)

engine/*  depends ONLY on entities/ + config/   (no data, no plugins, no flutter)
```

Enforced by: engine files import nothing from `package:flutter`, `package:camera`, or `google_mlkit_*`. A lint/CI check (import boundary test) guards this.

### 4.2 Runtime data flow (per frame, steady state)

```
[Camera plugin]  30fps CameraImage (YUV/BGRA)
      │  UI isolate: only grabs frame + backpressure (drop if busy)
      ▼
[FrameThrottle]  keep ≤ target fps, drop stale frames  (frame-skipping)
      │  send bytes+meta across isolate boundary (transferable)
      ▼════════════════ ISOLATE BOUNDARY ════════════════
[PoseDetector.detect]  ML Kit → raw landmarks              (background isolate)
      ▼
[PoseNormalizer]  raw → PoseFrame (normalized coords, mirror correction)
      ▼
[AnalysisPipeline.run(PoseFrame, AiConfig)]
   validation → angles → movement/FSM → rep → form → tempo → scoring
      ▼
AnalysisFrameResult  (poseValid, angles, state, repCount, newRepEvent?, formFindings, scores)
      ▼════════════════ back to UI isolate ═══════════════
[WatchMeCubit]  emit state → overlay + HUD
      │
      ├─► [FeedbackArbiter.next()] → CoachMessage? → [VoiceOutput.speak]  (main isolate, TTS)
      │
      └─► on set/session end → WorkoutAnalysisResult
                 └─► Mediator SaveAnalysisResultCommand → sqflite draft → workout_session
```

### 4.3 Config injection flow (pre-fetched — no fetch at camera launch)

`aiConfigJson` is **pre-fetched upstream** and travels in-context to the camera. `exercise_ai` never performs a network call to obtain it, so the launch path has **zero I/O latency and zero failure modes**.

```
UPSTREAM (existing session load, before this feature is involved):
  Day/Task load hydrates Task.exerciseConfig.aiConfigJson  ── responsibility of the
     (the heavy analysis payload, backend endpoint #6)         loader that builds the plan

     (currently weekly_plan_page builds taskData with:
       'aiConfig': task.exerciseConfig  ← must carry a POPULATED aiConfigJson)

           │  push(taskExecution, extra: taskData)
           ▼
task_execution_page
   │  reads taskData['aiConfig'] as ExerciseConfig?
   │  Watch Me button shown ⇔ config != null && aiConfigJson.isNotEmpty && supported analyzerType
   │  [Watch Me] tap
           │  push(WatchMePage, extra: exerciseConfig)   ← in-memory object, no fetch
           ▼
WatchMePage / WatchMeCubit
   │  AiConfigParser.parse(exerciseConfig.aiConfigJson)   ← pure, synchronous, once
   ├─ ok      → AiConfig → build analyzer → start camera
   └─ invalid → AiConfigValidationFailure → show "coaching unavailable, log manually"
                (never crash; the manual logging form on the previous page is the fallback)
```

**Offline is now trivial:** because the config is an in-memory `Map` by the time Watch Me opens and all analysis is on-device math, the entire coaching experience runs with **no network** — no cache lookup, no staleness logic, nothing to fail. The only precondition is that the upstream loader hydrated `aiConfigJson`; if it didn't (empty map), Watch Me simply isn't offered.

> **Upstream prefetch gap to close (not this feature's code, but a dependency):** the task/day plan loader must populate `exerciseConfig.aiConfigJson` (via backend endpoint #6, ideally batched per day) so it is non-empty in `taskData['aiConfig']`. Today the picker path stores the *summary* shape (empty `aiConfigJson`). Treat "hydrate aiConfigJson before the session screen" as a prerequisite ticket. `exercise_ai` degrades gracefully if it's missing (button hidden), so the two can ship independently.

---

## 5. Core Data Contracts (the stable interfaces)

These are the frozen contracts that make the whole thing composable. (Signatures only — no bodies.)

```dart
// domain/entities/pose_frame.dart
class PoseFrame {
  final List<Landmark> landmarks;      // indexed by LandmarkType.index
  final int timestampMs;
  final Size imageSize;
  Landmark? operator [](LandmarkType t);
}

// domain/entities/analysis_frame_result.dart  (per-frame output — the pipeline's product)
class AnalysisFrameResult {
  final bool poseValid;
  final PoseValidationReport validation;      // why invalid (missing/low-vis landmarks)
  final Map<String, JointAngle> angles;
  final String currentStateId;
  final int repCount;
  final RepEvent? completedRep;               // non-null only on the frame a rep closes
  final List<FormFinding> formFindings;
  final LiveScores scores;                    // rolling rep/form/tempo/overall
  final CameraGuidance? guidance;             // "move back", "turn left", null when framed OK
}

// domain/entities/workout_analysis_result.dart (aggregate — persisted)
class WorkoutAnalysisResult {
  final int totalReps;
  final int validReps;
  final double formScore;      // 0..100
  final double tempoScore;
  final double romScore;
  final double overallScore;
  final List<RepEvent> reps;
  final List<FormFinding> topIssues;
  final Duration activeDuration;
}

// domain/ports/pose_detector.dart
abstract class PoseDetector {
  Future<void> init(PoseRequirements req);
  Future<PoseFrame?> detect(CameraFrame frame);   // called on background isolate
  Future<void> dispose();
}

// domain/engine/pipeline/analysis_stage.dart
abstract class AnalysisStage {
  String get id;
  void process(AnalysisContext ctx);   // reads/writes ctx; pure w.r.t. injected state
}
```

`AnalysisFrameResult` and `AiConfig` are the two contracts you must never break. Everything else can evolve behind them.

### 5.1 Launch / navigation contract (task_execution_page → Watch Me)

The camera page receives the **already-fetched** `ExerciseConfig` as a typed navigation `extra` — not a `configId`, not a `Map`. This keeps the fetch decision entirely upstream and makes the camera page a pure consumer.

```dart
// app_routes.dart — new route, root-level (pushed OVER the shell like clientSessionUpdate,
// so the bottom nav is hidden during live logging).
AppRoute.watchMe(path: '/member/train/watch-me', name: 'watch-me')

// app_router.dart — extra is the in-memory ExerciseConfig (aiConfigJson already populated)
GoRoute(
  path: AppRoute.watchMe.path,
  name: AppRoute.watchMe.name,
  pageBuilder: (context, state) => NoTransitionPage(
    child: WatchMePage(config: state.extra as ExerciseConfig),
  ),
);

// task_execution_page.dart — gate the button; parse is deferred to WatchMePage/Cubit.
bool get _canWatchMe {
  final cfg = widget.taskData['aiConfig'];            // ExerciseConfig? (pre-fetched)
  return cfg is ExerciseConfig
      && cfg.aiConfigJson.isNotEmpty                  // hydrated upstream
      && AiConfigParser.isSupported(cfg.analyzerType, cfg.aiConfigJson); // cheap, no throw
}
// on tap:  context.push(AppRoute.watchMe.path, extra: widget.taskData['aiConfig']);
```

**As implemented**, the `extra` is a `WatchMeArgs { ExerciseConfig config; SetPlan plan; }`: the config still arrives pre-fetched exactly as described above, and the `SetPlan` is built in `task_execution_page` from the backend task's `sets` / `reps` / `restSeconds` (the same three values the target row already displays). One Watch Me session then covers every prescribed set, with rest in between.

**On return**, Watch Me pops with a `SessionAnalysisResult?` — one `WorkoutAnalysisResult` per set worked. `task_execution_page` pre-fills `actualSets` from `completedSets` and `actualReps` from `repsPerSetLabel` ("12,12,10"), both user-editable, and appends a per-set summary to the notes — the manual form remains the source of truth the user can override. This preserves the existing autosave/`upsertTaskCompletion` flow unchanged.

> **Why pass `ExerciseConfig`, not `AiConfig`:** parsing/validation stays inside the feature (single place, testable, degrades gracefully), and the route contract doesn't couple callers to the internal typed config model. `analyzerType` + `mediaUrl` (demo loop) are also handy on the page directly.

---

## 6. Computer Vision Architecture (the 9 engines)

Each "engine" from the brief maps to a pipeline **stage** or a domain **service**. All are pure, config-driven, and independently unit-testable.

| # | Engine | Where | Responsibility | Config it reads |
|---|---|---|---|---|
| 1 | **Pose Detection** | `ports/PoseDetector` + `data/mlkit_pose_detector` + `pose_normalizer` | frame → landmarks + per-landmark confidence; normalization | `poseRequirements`, `camera` |
| 2 | **Angle** | `angles/angle_calculator` (+ `AngleStage`) | 3-point & reference-axis angles, per-angle confidence = min(landmark confidences) | `angles[]` |
| 3 | **Pose Validation** | `validation/pose_validator` (+ `PoseValidationStage`) | gate: required landmarks present, visibility ≥ min, confidence ≥ min; short-circuits pipeline | `poseRequirements` |
| 4 | **Movement** | `movement/state_machine` + `movement_history` | evaluate transitions from angle deltas, track state, keep rolling history | `stateMachine` |
| 5 | **Rep Detection** | `rep/rep_detector` | count reps on configured state cycle, measure rep duration & ROM, reject too-fast/slow | `repRules` |
| 6 | **Form Analysis** | `form/form_rule_evaluator` + `rules/*` | evaluate declarative form rules (depth, knee tracking, back posture, symmetry, custom) | `formRules[]` |
| 7 | **Tempo** | `tempo/tempo_analyzer` | measure eccentric/concentric durations vs targets, tolerance window | `tempo` |
| 8 | **Scoring** | `scoring/scoring_engine` | weighted fusion → rep/form/tempo/rom/overall | `scoring` |
| 9 | **Feedback** | `feedback/*` (+ `VoiceOutput` port) | select highest-priority message under cooldown/dedupe/per-rep caps | `feedbackRules`, `voice` |

**Angle engine details.** Provide three primitives (all pure, in `vector_math.dart`):
- `angleAt(vertex, a, b)` — interior angle at a joint (0–180).
- `signedAngle(a, b)` — signed angle for direction-sensitive checks (valgus/varus).
- `angleToVertical(a, b)` / `angleToHorizontal` — torso lean, shin angle vs gravity.

Angle **confidence** = min visibility/presence of the 3 landmarks involved; the pipeline drops angle-derived findings when confidence < config threshold rather than emitting garbage.

**Form rule primitives (built-in, referenced by `type` in config):**
`angleThreshold`, `angleBetween`, `alignment` (three points collinear within tolerance — knee-over-toe / hip-shoulder-ankle line), `romDepth` (min angle reached this rep), `symmetry` (left vs right angle delta), `stability` (landmark jitter variance), `staticHold` (angle held within band for N ms). Each is a registered `FormRule`; new primitives are additive.

---

## 7. State Machine Architecture (generic & config-driven)

A single `StateMachine` class, zero exercise names inside it.

```
StateMachine
 ├─ current: String                      (e.g. "STANDING")
 ├─ states:  Map<String, StateSpec>
 ├─ transitions: List<TransitionSpec>    (from, to, ConditionSpec)
 └─ update(Map<String,JointAngle> angles, MovementHistory h) : Transition?
       for t in transitions where t.from == current:
          if evaluate(t.condition, angles, h): current = t.to; return t
       return null
```

`ConditionSpec` operators: `<`, `>`, `between`, `rising`/`falling` (uses `MovementHistory` slope over a short window to require actual movement, not jitter), `heldFor(ms)` (for hold/pose states). Hysteresis is expressed by using distinct thresholds on the two opposing transitions (e.g. descend at knee<160, ascend at knee>168) — **encoded in config, not code**, which prevents chatter.

**Squat** and **Pushup** from the brief are literally the *same machine* with different config:

```
Squat:   STANDING→DESCENDING (kneeAngle falling <160)
         DESCENDING→BOTTOM   (kneeAngle < 95)
         BOTTOM→ASCENDING    (kneeAngle rising >100)
         ASCENDING→STANDING  (kneeAngle > 168)   ← rep counted here (repRules.countOn)

Pushup:  TOP→DESCENDING (elbowAngle falling <160) … BOTTOM (elbow<95) … TOP (elbow>165)
```

Multi-phase movements (deadlift: setup→pull→lockout→lower) are the same structure with more states; `CompoundMovementAnalyzer` just wires multiple angle groups into one machine.

---

## 8. Voice Feedback Architecture

```
Frame results ──► [FeedbackSource(s)] produce candidate CoachMessages
                        │  each has {text, priority(0..3), category, ttlMs}
                        ▼
                 [FeedbackArbiter]
                   • cooldown gate:   global cooldownMs since last spoken
                   • per-rep cap:     ≤ voice.maxPerRep messages within current rep window
                   • dedupe:          suppress same category within dedupeWindowMs
                   • priority queue:  safety/form-critical > tempo > encouragement
                   • collapse:        if higher-priority arrives, replace queued lower one
                        ▼ (0 or 1 message per tick)
                 [VoiceOutput (flutter_tts)]
                   • interrupt policy: critical interrupts; others queue then drop if stale (ttl)
                   • offline: on-device TTS engine (no network)
                   • ducking: lower media/music volume while speaking (platform)
```

**Priority tiers (config-assignable):** `0 safety` (e.g. "straighten your back") → interrupts; `1 formCorrection` → queued; `2 tempo` → queued, droppable; `3 encouragement` ("good rep!") → droppable first under pressure.

**Duplicate prevention** is two-layered: category dedupe within a window (don't say "go deeper" 5×/sec) *and* content dedupe (exact-string suppression). **Per-rep cap** resets on each `completedRep` boundary from the pipeline. All timings (`cooldownMs`, `maxPerRep`, `dedupeWindowMs`) come from `voice`/`feedbackRules` config. TTS is fully offline.

---

## 9. ML Architecture (pluggable, phased)

The pipeline is the extension point. ML enters as **additional stages** and **additional scoring/feedback sources**, never as a rewrite.

```
Phase 1 (V1):  MediaPipe/ML Kit ► rules ► math
    stages = [validation, angles, movement, rep, form(rules), tempo, scoring(weighted)]

Phase 2 (V2):  + on-device TFLite form classifier
    ML Kit landmarks ► FeatureExtractor (angles+normalized coords → feature vector)
                    ► TfliteClassifier.classify(features) → {good/bad, confidence}
    stages = [..., form(rules), TfliteFormStage, tempo, scoring(FUSION)]
    ScoringEngine gains a fusion input; weight comes from config (scoring.mlFormWeight),
    default 0 so V1 configs are unaffected until backend opts in.

Phase 3 (V3-a):  Exercise classification
    ExerciseClassifierStage runs a lightweight model to confirm the user is doing the
    configured exercise (guardrail / auto-detect), emits a FormFinding if mismatch.

Phase 4 (V3-b):  Movement-quality models (regression → smoothness/quality 0..1)
    MovementQualityStage feeds another scoring input.
```

**Pluggability mechanics:**
- `MlClassifier` is a domain **port**; V1 ships a no-op impl so DI graph is stable.
- Models are assets/downloaded blobs keyed by config (`aiConfigJson.pipeline.models[]`), loaded lazily and cached; missing model → stage becomes a no-op (graceful degradation).
- `FeatureExtractor` is pure and reuses the **same angles** the rule engine already computes → no duplicate CV work.
- Because stage order and presence come from `pipeline.stageIds`, a backend can enable ML per-exercise (progressive rollout / A-B) with zero client changes.

**Package for V2/V3 on-device inference:** `tflite_flutter` (+ `tflite_flutter_helper` for tensor ops) — GPU delegate on Android, Metal on iOS. Runs on the **same background isolate** as pose detection to avoid extra hops.

---

## 10. Package Recommendations

| Need | **Recommended** | Why | Alternatives (and why not) | Perf notes |
|---|---|---|---|---|
| Camera frames | **`camera`** (official) | Only mature stream-of-frames API (`startImageStream`); flavor/lifecycle battle-tested | `camerawesome` (heavier, opinionated UI); `CameraX` platform channel (reinvents) | Use lowest resolution that keeps pose accuracy (usually 480–720p); handle YUV420 (Android) / BGRA (iOS); throttle stream |
| Pose detection | **`google_mlkit_pose_detection`** | On-device BlazePose (33 landmarks, x/y/z + inFrameLikelihood), free, offline, fast, actively maintained; `accurate` vs `fast` modes | `flutter_mediapipe`/raw MediaPipe Tasks (more control, more native glue, less maintained in Flutter); `movenet`-via-tflite (17 keypoints, less rich, DIY) | `stream` mode; `fast` model on low-end devices; ~15–30fps achievable off-isolate |
| On-device ML (V2+) | **`tflite_flutter`** | Direct TFLite C API, GPU/NNAPI/Metal delegates, isolate-friendly | `tflite` (abandoned); `pytorch_lite` (larger runtime) | Quantized (int8) models; enable GPU delegate; reuse interpreter (pool) |
| Text-to-speech | **`flutter_tts`** | Offline platform TTS, queue + completion callbacks, volume/pitch/rate, ducking | `just_audio`+pre-rendered clips (no dynamic text, bigger bundle) | Warm up engine at session start; keep utterances short |
| Speech-to-text (V3) | **`speech_to_text`** | On-device where available, simple stream API | cloud STT (network, privacy) | Only session-scoped; not on hot path |
| State management | **`flutter_bloc` (Cubit)** | Repo standard; `WatchMeCubit` fits existing convention | (n/a — match repo) | Emit throttled/coalesced UI states, not every raw frame |
| DI | **`get_it` + `injectable`** | Repo standard; register adapters + stage registry | (n/a — match repo) | Register engine as factories; ports as singletons |
| CQRS dispatch | **`dart_mediatr`** | Repo standard for config load + result save | (n/a) | Only for load/save, **not** per-frame (too heavy for hot path) |
| Concurrency | **isolates** (`Isolate.run` / long-lived worker) | Keep CV off UI thread → smooth 60fps UI | `compute` (spawns per call — too costly per frame) | Use one **persistent** worker isolate; stream frames in, results out |
| Models | **`freezed` + `json_serializable`** | Repo standard; `AiConfig` + entities | (n/a) | keep `AiConfig` immutable; parse once per session |
| Local cache | **`sqflite`** | Repo standard (Drift excluded by analyzer conflict) | (n/a) | cache `aiConfigJson` + recorded sessions |
| Permissions | **`permission_handler`** | camera/mic runtime permissions, clean API | platform channels (DIY) | request before opening camera page |

> **Do not** put `dart_mediatr` or Cubit `emit` in the per-frame hot path. The mediator is for config load and final save only; the frame loop is a plain Dart stream through the isolate.

---

## 11. Performance Architecture

**Frame budget:** at 30fps you have ~33ms/frame. ML Kit pose ≈ 10–25ms on mid devices. So the pipeline math must be <2ms (it is — it's a few dozen angle/comparison ops) and **you must not block the UI isolate**.

### 11.1 Isolate split

| Runs on **UI isolate** | Runs on **background (worker) isolate** |
|---|---|
| Camera stream capture (plugin requirement) | Pose detection (ML Kit) |
| Frame throttle / backpressure (drop frames) | Pose normalization |
| Cheap serialize + `SendPort` to worker | Full analysis pipeline (angles→…→scoring) |
| Receive `AnalysisFrameResult`, coalesce, `emit` | Feature extraction + TFLite (V2) |
| `CustomPainter` overlay + HUD | (returns compact result, not the image) |
| TTS (`flutter_tts` — must be main isolate) | |

> ML Kit's plugin currently requires calling the detector from the platform side; if the plugin cannot run inside a spawned isolate on a given platform, the fallback is: run **detection** via the plugin on a dedicated background *thread the plugin manages*, and run **the pure pipeline** in `Isolate.run`. The pure pipeline is trivially isolate-safe because it's plain Dart over value objects. Validate this on both platforms during Sprint 1 (see Risks §14).

### 11.2 Frame-skipping strategy

- **Drop, don't queue:** if the worker is busy, drop the incoming frame (latest-wins). A stale pose is worse than a skipped one.
- **Adaptive fps:** target 20–30fps; if median processing time rises, lower target fps (config `camera` can set a ceiling). Reps still count correctly at 15fps for normal-speed movements.
- **Coalesce UI:** overlay repaint at display refresh; don't `emit` a new Cubit state for every worker result if it hasn't meaningfully changed.

### 11.3 Caching & pooling

- **Cache:** parsed `AiConfig` (parse JSON once per session, never per frame); ML Kit detector instance; TFLite interpreter; TTS engine (warm).
- **Pool:** reuse byte buffers for frame transfer; reuse the feature-vector `Float32List`; reuse `AnalysisContext` across frames (reset frame-scoped fields, keep session state) → near-zero per-frame allocation to avoid GC jank.
- **Skeleton overlay:** paint from the last result only; never hold camera images in memory beyond the current frame.

### 11.4 Memory & thermal

Close the camera + dispose detector/interpreter the moment the page pops. Watch Me is a short, high-intensity feature — long sessions cause thermal throttling; surface a "cool down / take a break" state and drop fps under sustained heat.

---

## 12. Clean Architecture Recommendations (repo-specific)

1. **Engine stays pure.** No `package:flutter`/plugin imports under `domain/engine`. Add a CI import-boundary test that fails the build if violated. This is the linchpin of testability and V2/V3 portability.
2. **Ports in domain, adapters in data,** wired by `@Injectable(as: Port)` exactly like existing repositories.
3. **Mediator only for save.** The one new handler, `SaveAnalysisResultCommandHandler`, must be **hand-registered in `lib/core/di/injection.dart`** (per the repo's documented gotcha — DI resolution alone won't dispatch them). There is **no config-load query** — config arrives in-context (§4.3/§5.1), so no fetch handler exists on the launch path.
4. **Config parsing is pure, not a repository.** `AiConfigParser.parse(Map) → AiConfig` (or `AiConfigValidationFailure`) is a synchronous domain transform with **no I/O** — do not wrap it in a repository/`Either`-over-Dio; the only failure is malformed JSON, handled in the Cubit.
5. **Consume the pre-fetched `ExerciseConfig`.** `Task.exerciseConfig` carries `analyzerType`, `id`, and (once the upstream prefetch ticket lands) a populated `aiConfigJson`. `exercise_ai` **does not fetch** — it receives this object via navigation. Keep the heavy `aiConfigJson` off the task *list* payloads; hydrate it in the day/task *detail* load that feeds the session screen.
6. **Config is the contract, not code.** Any PR that adds an `if (exerciseName == …)` or a hardcoded threshold in Dart is rejected in review. Thresholds live in `aiConfigJson`; new *primitives* (rule types, operators, analyzers) are the only Dart additions.
7. **Feature isolation.** `exercise_ai` depends on `exercise_config` (for the config id/type) and hands results to `workout_session` via a command — no reverse dependency.

---

## 13. Testing Strategy

| Layer | What | How |
|---|---|---|
| **Config parsing** | `aiConfigJson` → `AiConfig`; malformed/missing fields → typed validation errors, sensible defaults | golden JSON fixtures per `analyzerType`; property tests for optional fields |
| **Angle math** | `vector_math`, `angle_calculator` | pure unit tests with known geometry (right angle = 90°, collinear = 180°) |
| **State machine** | transitions, hysteresis, no-chatter | feed synthetic angle sequences; assert state path & rep-count-on transitions |
| **Rep detector** | counting, too-fast/slow rejection, ROM | synthetic rep waveforms (sine sweeps) at various speeds |
| **Form rules** | each primitive (depth/alignment/symmetry/stability) | crafted `PoseFrame`s; assert findings + severities |
| **Tempo/scoring** | weighted fusion, edge weights | table-driven cases; weights sum handling |
| **Analyzers** | end-to-end pipeline per type | **replay recorded landmark sessions** (JSON of PoseFrames captured from real reps) → assert rep count, score band, top issues. This is the crown-jewel test: deterministic, no camera, runs in CI. |
| **Feedback arbiter** | cooldown, dedupe, per-rep cap, priority | fake clock; assert exactly which messages emit and when |
| **Ports/adapters** | ML Kit mapping, TTS calls | mock plugins; contract tests |
| **Cubit** | state transitions, lifecycle, dispose | `bloc_test` |
| **ML (V2)** | classifier I/O shape, fusion weight=0 ⇒ no behavior change | golden feature vectors; regression test that V1 configs score identically with ML stage present-but-disabled |
| **Performance** | frame processing time, allocation | benchmark harness over recorded frames; assert p95 pipeline time < budget; allocation profiling |
| **Integration** | camera→pipeline→overlay→save on device | `integration_test` on physical devices (emulators lack real camera/pose) |

**Recorded-session fixtures** are the highest-ROI investment: build a debug capture mode that dumps `List<PoseFrame>` + config to JSON. Every real workout becomes a regression test. Analyzer correctness is then proven **without a camera or a human**.

---

## 14. Risks & Edge Cases

**Technical risks**
- **ML Kit + isolate viability** (highest): confirm early whether pose detection can run off the UI isolate on both platforms; if not, adopt the "detector on plugin thread + pure pipeline in isolate" split. *Spike in Sprint 1.*
- **Coordinate systems & mirroring:** front camera is mirrored; ML Kit coords are in image space with rotation. Normalize once in `PoseNormalizer`; get this wrong and every left/right form check inverts. Cover with fixtures.
- **Low-end device fps:** budget for 15fps floor; adaptive fps + `fast` model.
- **TFLite model size/download (V2):** lazy download + cache + graceful no-op if absent.

**CV / UX edge cases**
- Partial body / user too close / occlusion → `PoseValidationStage` short-circuits; `CameraGuidance` coaches framing instead of emitting bad reps.
- Poor lighting / cluttered background / multiple people → low confidence; drop to guidance mode, never fabricate a rep.
- Half-reps / paused reps / bouncing → `repRules` min/max duration + ROM depth reject invalid reps (count `validReps` separately from `totalReps`).
- Left-vs-right handed / camera on opposite side → `camera.position` guidance + symmetry rule tolerance.
- Mid-set app backgrounded / phone locked / call → persist partial result to sqflite; resume or finalize gracefully (mirror existing local-first session handling).
- Rapid config changes / stale cache → cache TTL + version field on `aiConfigJson`.

**Product risks**
- **Accuracy expectations:** 2D pose ≠ perfect biomechanics. Frame Watch Me as *coaching cues*, not medical assessment. Backend thresholds must be tuned conservatively to avoid false "bad form" nags (erodes trust fast).
- **Battery/thermal** on long sessions → session length caps + cooldown states.
- **Privacy:** camera frames never leave the device (all on-device). State this in UI copy; never upload images — only derived `WorkoutAnalysisResult`.

---

## 15. Future Scalability

- **New exercises:** backend `aiConfigJson` only. Zero client release.
- **New rule/operator/analyzer primitives:** additive Dart classes + one registry line; existing code untouched (Open/Closed).
- **V2 ML:** additional pipeline stages, enabled per-config; fusion weights default to 0.
- **V3 coach agent:** `LlmCoachSource` added as another `FeedbackSource`; consumes the same `WorkoutAnalysisResult` trend data. Recommendations/recovery/nutrition are new features that read the persisted results — they don't touch the CV engine.
- **Multi-model backends:** `pipeline.models[]` lets configs pin model versions; A/B and progressive rollout via backend flags.
- **Cross-platform reuse:** because the engine is pure Dart, it can run in a headless test harness, a server-side validator, or a future desktop build unchanged.

---

## 16. Step-by-Step Implementation Roadmap

**Milestone A — Foundations & config (no camera, no network)**
1. Scaffold `exercise_ai` feature folders; add packages (`camera`, `google_mlkit_pose_detection`, `flutter_tts`, `permission_handler`).
2. Define entities (`Landmark`, `PoseFrame`, `JointAngle`, results) + `AiConfig` freezed models + `AiConfigParser` (pure `Map → AiConfig`/`AiConfigValidationFailure`) + `AiConfigParser.isSupported(...)`. Unit-test parsing with per-`analyzerType` fixtures (valid, malformed, missing-field).
3. Add `watchMe` route (root-level, over the shell) + `WatchMePage(config: ExerciseConfig)`. Wire the **Watch Me button** into `task_execution_page`, gated by `_canWatchMe` (§5.1), reading the pre-fetched `taskData['aiConfig']` — no fetch.
4. **Dependency ticket (separate, upstream):** hydrate `Task.exerciseConfig.aiConfigJson` in the day/task detail load (backend endpoint #6, batched per day) so `taskData['aiConfig']` is non-empty. `exercise_ai` degrades gracefully (button hidden) until this lands, so it need not block Milestone A.

**Milestone B — Pure engine (no camera)**
5. `vector_math` + `angle_calculator` + `pose_validator`.
6. Generic `StateMachine` + `ConditionSpec` evaluator + `MovementHistory`.
7. `RepDetector`, `FormRuleEvaluator` + builtin rules, `TempoAnalyzer`, `ScoringEngine`.
8. `AnalysisStage` pipeline + `AnalysisContext`; the four+one analyzers + `AnalyzerFactory`.
9. **Recorded-session replay tests** for squat & pushup configs → prove rep count & scoring. (Capture fixtures with a throwaway script or hand-authored waveforms.)

**Milestone C — Live capture**
10. `CameraSource` adapter + `MlkitPoseDetector` + `PoseNormalizer`; permission flow.
11. Persistent worker isolate + frame throttle/drop; wire camera→isolate→pipeline→result stream.
12. `WatchMeCubit` + `WatchMePage` + overlay painter + rep/score HUD + camera-setup coach.
13. **Isolate viability spike sign-off** on real Android + iOS devices.

**Milestone D — Feedback & persistence**
14. `RuleFeedbackSource` + `FeedbackArbiter` + `FlutterTtsVoiceOutput`; cooldown/dedupe/priority tests.
15. `SaveAnalysisResultCommand` → merge `WorkoutAnalysisResult` into `workout_session` draft (sqflite); hand-register handler.
16. Wire Watch Me entry point from the task execution flow (`task_execution_page` / session).

**Milestone E — Hardening**
17. Adaptive fps, thermal/battery states, offline verification, edge-case handling.
18. Performance benchmark harness + p95 gates; device matrix pass.
19. Analytics/telemetry (rep accuracy vs manual, false-positive form rate) for backend threshold tuning.

**Later — V2 / V3 (design-complete, build-when-ready)**
20. `MlClassifier` real impl + `FeatureExtractor` + `TfliteFormStage` + fusion weight (default 0).
21. `LlmCoachSource` + recommendation features reading persisted results.

## 17. Suggested Milestones & Sprint Planning

Two-week sprints, mobile+AI engineer(s):

| Sprint | Focus | Exit criteria |
|---|---|---|
| **S1** | Milestone A + **isolate/ML-Kit spike** (parallel) | Watch Me button appears on tasks with hydrated config and routes to a stub page; parser tests green (per-type fixtures); spike decision documented |
| **S2** | Milestone B (engine) | Squat & pushup replay tests pass deterministically in CI; engine has zero flutter/plugin imports (CI-enforced) |
| **S3** | Milestone C (live camera) | On-device: skeleton overlay + live rep counting at ≥20fps on target device |
| **S4** | Milestone D (voice + save) | End-to-end Watch Me: do reps → hear cues → result saved into session draft |
| **S5** | Milestone E (hardening) | Perf gates pass; edge cases handled; ship V1 behind a flag to internal testers |
| **S6+** | Tuning + V2 groundwork | Backend threshold tuning from telemetry; `MlClassifier`/`FeatureExtractor` skeleton merged (disabled) |

## 18. Recommendations for Production Readiness

- **Feature flag** Watch Me per exercise (config presence) and globally (remote flag) for safe rollout.
- **Import-boundary CI test** guarding engine purity — this is what protects V2/V3 extensibility.
- **Golden replay corpus** grown from real sessions; run in CI as regression gate.
- **Telemetry** on rep-count agreement and form false-positive rate → feeds backend threshold tuning; treat thresholds as a *tuned product surface*, not a one-time guess.
- **Graceful degradation everywhere:** missing config field, missing model, low confidence, thermal throttle → coach/guidance mode, never crash, never fabricate reps.
- **Privacy copy + guarantee:** frames never leave device; only derived scores persist/sync.
- **Accessibility & UX honesty:** position Watch Me as coaching cues; conservative nagging; always allow manual logging fallback (existing `task_execution_page`).
- **Device support matrix** documented (min OS, camera, RAM); `fast` model fallback path verified.

---

## Appendix A — Example `aiConfigJson` (squat, illustrative)

```jsonc
{
  "analyzerType": "DYNAMIC_REP",
  "pipeline": { "stageIds": ["validation","angles","movement","rep","form","tempo","scoring"] },
  "camera": { "position": "SIDE", "instruction": "Place phone at hip height, 2m to your side",
              "fullBodyRequired": true, "minimumDistanceCm": 180 },
  "poseRequirements": { "requiredLandmarks": ["HIP_L","KNEE_L","ANKLE_L","SHOULDER_L"],
                         "minimumVisibilityScore": 0.6, "minimumLandmarkConfidence": 0.5 },
  "angles": [
    { "id": "kneeAngle", "vertexLandmark": "KNEE_L", "aLandmark": "HIP_L", "bLandmark": "ANKLE_L" },
    { "id": "hipAngle",  "vertexLandmark": "HIP_L",  "aLandmark": "SHOULDER_L", "bLandmark": "KNEE_L" }
  ],
  "stateMachine": {
    "initialState": "STANDING",
    "states": ["STANDING","DESCENDING","BOTTOM","ASCENDING"],
    "transitions": [
      { "from": "STANDING",   "to": "DESCENDING", "condition": { "angleId":"kneeAngle","op":"falling","value":160 } },
      { "from": "DESCENDING", "to": "BOTTOM",     "condition": { "angleId":"kneeAngle","op":"<","value":95 } },
      { "from": "BOTTOM",     "to": "ASCENDING",  "condition": { "angleId":"kneeAngle","op":"rising","value":100 } },
      { "from": "ASCENDING",  "to": "STANDING",   "condition": { "angleId":"kneeAngle","op":">","value":168 } }
    ]
  },
  "repRules": { "topStateId":"STANDING", "bottomStateId":"BOTTOM", "countOn":"ASCENDING->STANDING",
                "minimumRepDurationMs":700, "maximumRepDurationMs":6000 },
  "tempo": { "eccentricDurationMs":2000, "concentricDurationMs":1000, "toleranceMs":600 },
  "formRules": [
    { "id":"depth", "type":"romDepth", "params":{ "angleId":"kneeAngle","minAngle":95 },
      "severity":"HIGH", "message":"Go a little deeper" },
    { "id":"backPosture", "type":"angleThreshold", "params":{ "angleId":"hipAngle","min":45 },
      "severity":"HIGH", "message":"Keep your chest up" }
  ],
  "scoring": { "repWeight":0.4, "formWeight":0.4, "tempoWeight":0.1, "romWeight":0.1 },
  "feedbackRules": [
    { "id":"tooShallow", "when":"formFinding:depth failed", "message":"Deeper!", "priority":1 },
    { "id":"goodRep",    "when":"rep completed AND repScore>85", "message":"Great rep!", "priority":3 }
  ],
  "voice": { "enabled":true, "coolDownMs":2500, "maximumFeedbacksPerRep":1 }
}
```

This single JSON — with no matching Dart change — fully specifies squat coaching. Swap the angle ids, thresholds, and states and you have pushups, deadlifts, planks, or anything the backend dreams up. **That is the whole point of the architecture.**
