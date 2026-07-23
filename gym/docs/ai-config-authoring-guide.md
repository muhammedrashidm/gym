# `aiConfigJson` Authoring Guide

**The single source of truth for writing exercise configs that the Kinetic on-device AI coach can actually run.**

This spec describes ONLY what the implemented engine supports (`lib/features/exercise_ai/`). Anything not listed here is ignored by the parser or silently no-ops at runtime. If you follow the **Rules** and the **8-step recipe**, you can author a config for any exercise without touching Dart.

> Golden principle: **the app has zero exercise-specific code.** Every threshold, state, angle, rule, and cue is data in `aiConfigJson`. New exercise = new config. Retune = edit config. No app release.

---

## 0. Mental model — the funnel

Each frame flows through an ordered pipeline. Every block downstream references angles **by id**:

```
analyzerType ─▶ picks the pipeline (which stages run)
   │
poseRequirements ─▶ VALIDATION gate (bad pose → skip analysis, show framing cue)
   │
angles[] ─▶ compute joint angles by id        ← the vocabulary everything else uses
   │
stateMachine ─▶ MOVEMENT: angle conditions drive state transitions
   │
repRules ─▶ REP: count + measure reps from a state cycle
   │
formRules[] ─▶ FORM: per-frame pass/fail checks on angles
   │
tempo ─▶ score eccentric/concentric timing per rep
   │
scoring ─▶ fuse rep/form/tempo/rom → 0..100
   │
feedbackRules[] + voice ─▶ pick one spoken cue under cooldown/priority
```

---

## 1. Choose the analyzer type

`analyzerType` selects the default pipeline. Pick by movement pattern:

| `analyzerType` | Use for | Default pipeline (stages run) | Counts reps? |
|---|---|---|---|
| `DYNAMIC_REP` | Single-joint cyclic reps: squat, push-up, curl, press, lunge | validation, angles, movement, rep, form, tempo, scoring | ✅ |
| `COMPOUND_MOVEMENT` | Multi-phase / multi-joint lifts: deadlift, clean, bench | validation, angles, movement, rep, form, tempo, scoring | ✅ |
| `CARDIO_MOVEMENT` | Rhythmic cadence: jumping jacks, high knees, mountain climbers | validation, angles, movement, rep, scoring | ✅ (no form/tempo) |
| `STATIC_HOLD` | Timed holds: plank, wall-sit, hollow hold | validation, angles, form, scoring | ❌ (see §9 limitation) |
| `STATIC_POSE` | Match a target posture: yoga asana | validation, angles, form, scoring | ❌ |

`DYNAMIC_REP` and `COMPOUND_MOVEMENT` are functionally identical in V1 — both run the full pipeline. Use `COMPOUND_MOVEMENT` as a label for lifts with >4 phases or multiple driving angles.

You may override the stage list explicitly:
```json
"pipeline": { "stageIds": ["validation","angles","movement","rep","form","tempo","scoring"] }
```
Only these ids exist: `validation, angles, movement, rep, form, tempo, scoring`. Unknown ids are ignored. Omit `pipeline` to accept the default for your type.

---

## 2. The 8-step authoring recipe (do these in order)

1. **Pick `analyzerType`** (§1) and the **camera view** the exercise is judged from (SIDE for sagittal movements like squat/push-up; FRONT for symmetry/lateral movements).
2. **List the driving landmark(s)** — the joint whose angle opens/closes through the rep. Put its angle **first** in `angles[]`.
3. **Define `angles[]`** — the driving angle + any form angles (§4).
4. **Set `poseRequirements.requiredLandmarks`** to the *minimum reliably-visible* landmarks the driving angle needs (§3 Rules).
5. **Build the `stateMachine`** — the phase cycle, using the driving angle in conditions (§5).
6. **Define `repRules`** — top/bottom states + `countOn` transition + duration bounds (§6).
7. **Add `formRules[]`** referencing angle ids (§7), then `scoring` weights (§8).
8. **Add `feedbackRules[]` + `voice`** and run the **pre-flight checklist** (§11).

---

## 3. Landmarks & camera

**Valid landmark names** (case-insensitive; all these resolve to the same point):
`KNEE_L` = `L_KNEE` = `LEFT_KNEE` = `KNEE_LEFT` = `leftKnee`.

Bases (each has `_L` / `_R`): `SHOULDER, ELBOW, WRIST, HIP, KNEE, ANKLE, HEEL, EAR, EYE, FOOT_INDEX`. Singletons: `NOSE`. (Full BlazePose 33 also work by camelCase name.)

```json
"camera": {
  "position": "SIDE",                    // SIDE | FRONT (free-text; only "FRONT" flips the overlay & selects front camera)
  "instruction": "Phone at hip height, 2 m to your side, full body in frame.",
  "fullBodyRequired": true,
  "minimumDistanceCm": 180
},
"poseRequirements": {
  "requiredLandmarks": ["HIP_L","KNEE_L","ANKLE_L","SHOULDER_L"],
  "minimumVisibilityScore": 0.6,         // 0..1 per-landmark visibility gate
  "minimumLandmarkConfidence": 0.5       // 0..1 per-landmark confidence gate
}
```

**Rules**
- **R1 — Require only what you must.** Validation short-circuits the whole pipeline when *any* required landmark is missing/low-confidence. List only the landmarks the **driving angle** needs. Occlusion-prone points (`FOOT_INDEX`, `EAR`, `WRIST` behind torso) should be used in *bonus* angles but **not** required.
- **R2 — Angles degrade gracefully.** An angle whose landmark is missing is skipped that frame, and any form rule referencing it returns "not applicable" (no false failure). So optional angles are safe.
- **R3 — Position "FRONT"** is the only value with behavior (selects the front camera + mirrors the overlay). Everything else reads as side/back.

---

## 4. `angles[]` — the vocabulary

An angle is the **interior angle at `vertexLandmark`** between the rays to `aLandmark` and `bLandmark` (0–180°; `180°` = straight limb).

```json
"angles": [
  { "id": "kneeAngle", "vertexLandmark": "KNEE_L", "aLandmark": "HIP_L", "bLandmark": "ANKLE_L" },
  { "id": "hipAngle",  "vertexLandmark": "HIP_L",  "aLandmark": "SHOULDER_L", "bLandmark": "KNEE_L", "signed": false }
]
```

| field | required | notes |
|---|---|---|
| `id` | ✅ | unique key referenced everywhere else |
| `vertexLandmark` | ✅ | the joint (corner) |
| `aLandmark`, `bLandmark` | ✅ | the two ray endpoints |
| `signed` | optional | `true` → −180..180 (direction-sensitive: valgus/varus). Default `false` (0..180). |

**Rules**
- **R4 — Driving angle first.** The engine auto-selects the **ROM-tracked angle** as the one used in the transition *into* the `bottomStateId`; if none, it uses `angles[0]`. Put your main movement angle first and/or reference it in the bottom transition.
- **R5 — Angle confidence = min of its 3 landmarks' visibility.** Choose the most reliably-visible triplet that captures the movement.

---

## 5. `stateMachine` — the movement cycle

Exercise-agnostic FSM. States are your names; transitions fire when an angle **condition** is met.

```json
"stateMachine": {
  "initialState": "STANDING",
  "states": ["STANDING","DESCENDING","BOTTOM","ASCENDING"],
  "transitions": [
    { "from": "STANDING",   "to": "DESCENDING", "condition": { "angleId": "kneeAngle", "op": "falling", "value": 160, "windowMs": 300 } },
    { "from": "DESCENDING", "to": "BOTTOM",     "condition": { "angleId": "kneeAngle", "op": "<", "value": 95 } },
    { "from": "BOTTOM",     "to": "ASCENDING",  "condition": { "angleId": "kneeAngle", "op": "rising", "value": 100, "windowMs": 300 } },
    { "from": "ASCENDING",  "to": "STANDING",   "condition": { "angleId": "kneeAngle", "op": ">", "value": 168 } }
  ]
}
```

### Condition operators (only these exist)

| `op` (aliases) | Meaning | Uses |
|---|---|---|
| `<` (`lt`, `lessThan`) | angle < `value` | instantaneous threshold |
| `>` (`gt`, `greaterThan`) | angle > `value` | instantaneous threshold |
| `between` | `value` ≤ angle ≤ `value2` | in a band |
| `falling` | angle decreasing over `windowMs` **and** ≤ `value` | start of eccentric |
| `rising` | angle increasing over `windowMs` **and** ≥ `value` | start of concentric |
| `heldFor` | angle within [`value`,`value2`] for the whole `windowMs` | static/pose states |

`windowMs` defaults to `300`. `rising`/`falling` need a slope larger than jitter (~0.5°) across the window.

**Rules**
- **R6 — `initialState` MUST be in `states`; every transition `from`/`to` MUST be in `states`.** Otherwise the parser throws and Watch Me shows "unavailable."
- **R7 — Only one transition fires per frame** (first match in array order, from the current state). Order transitions from a state so the intended one wins.
- **R8 — Encode hysteresis in thresholds, not code.** Use a gap between opposing transitions (descend at `<160`, stand at `>168`) so the state doesn't chatter at the boundary. Keep ≥5°.
- **R9 — Use `rising`/`falling` for phase *entry*, `<`/`>` for hard landmarks (bottom/top).** A rep faster than ~`windowMs` per phase won't register `rising`/`falling` — that's intentional (ignores twitching). Real reps are >700 ms.
- **R10 — `STATIC_HOLD` may omit `stateMachine`** entirely (defaults to a single `HOLD` state). `DYNAMIC_REP`/`COMPOUND_MOVEMENT`/`CARDIO_MOVEMENT` **must** provide one.

### State-machine patterns

- **Cyclic 4-phase (most reps):** `TOP → DESCENDING → BOTTOM → ASCENDING → TOP`.
- **2-phase (simple open/close, e.g. jumping jacks):** `CLOSED → OPEN → CLOSED`.
- **Multi-phase lift (deadlift):** `SETUP → PULL → LOCKOUT → LOWER → SETUP` (drive different transitions with `hipAngle` vs `kneeAngle`).

---

## 6. `repRules` — counting & measuring

```json
"repRules": {
  "topStateId": "STANDING",
  "bottomStateId": "BOTTOM",
  "countOn": "ASCENDING->STANDING",     // "FROM->TO"; must be a real transition
  "minimumRepDurationMs": 700,
  "maximumRepDurationMs": 6000
}
```

**How a rep is measured (engine behavior you tune against):**
- Rep **starts** when a transition leaves `topStateId`.
- The moment the machine **enters `bottomStateId`** splits eccentric vs concentric (for tempo).
- Rep **closes** on the `countOn` transition (or, if `countOn` is omitted, on returning to `topStateId`).
- Rep is **valid** iff it reached the bottom state **and** `minimumRepDurationMs ≤ duration ≤ maximumRepDurationMs`. Invalid reps count in `totalReps` but not `validReps`.
- **ROM** = max−min of the auto-selected driving angle (R4) during the rep.

**Rules**
- **R11 — `countOn` must name an existing transition** (`"FROM->TO"` with the `->` separator). Otherwise counting falls back to "returned to top," which may double-count on jittery tops.
- **R12 — `topStateId` and `bottomStateId` must be real states** and should match the transition into bottom (so ROM tracking picks the right angle, R4).
- **R13 — Set duration bounds to real human speed.** Too-low `minimumRepDurationMs` lets bounces count as valid; too-high blocks fast athletes. Squat ~700–6000 ms; push-up ~600–5000 ms.

---

## 7. `formRules[]` — the form-check cookbook

Each rule references an angle id and produces a pass/fail per frame. **Only these 4 primitive `type`s exist.** Unknown types are ignored.

```json
"formRules": [
  { "id": "depth", "type": "romDepth",
    "params": { "angleId": "kneeAngle", "minAngle": 95 },
    "severity": "HIGH", "message": "Go deeper" }
]
```

| `type` | params | Passes when | Use for |
|---|---|---|---|
| `angleThreshold` | `angleId`, `min?`, `max?` | `min ≤ angle ≤ max` (either bound optional) | back posture, elbow flare, lockout |
| `romDepth` | `angleId`, `minAngle`, `atState?` | at the bottom state, `angle ≤ minAngle` | squat/push-up depth |
| `alignment` | `angleId`, `toleranceDeg?` (def 15) | angle is near-straight: `|180 − angle| ≤ tol` | straight body / neutral spine |
| `symmetry` | `leftAngleId`, `rightAngleId`, `toleranceDeg?` (def 15) | `|L − R| ≤ tol` | even limbs (FRONT view) |

`severity` ∈ `CRITICAL, HIGH, MEDIUM, LOW, INFO`.

**Rules**
- **R14 — `romDepth` only evaluates at `bottomStateId`** (or `params.atState`). Elsewhere it's "not applicable." Don't use it for whole-rep checks — use `angleThreshold`.
- **R15 — Severity is a scoring dial**, not just labeling. Per-frame form-score penalty for a *failed* rule: CRITICAL −50, HIGH −30, MEDIUM −18, LOW −8, INFO 0. Calibrate so a genuinely bad rep lands meaningfully below 100, but a minor wobble doesn't tank it.
- **R16 — A rule on a missing angle is skipped, not failed.** Safe to include form angles that need occasionally-hidden landmarks.

---

## 8. `scoring` — fusing sub-scores

```json
"scoring": { "repWeight": 0.4, "formWeight": 0.4, "tempoWeight": 0.1, "romWeight": 0.1 }
```

Sub-scores (0..100), then weighted + normalized by the sum of weights:
- **rep** = `validReps / totalReps × 100`
- **form** = average of each rep's form score (rep form = mean of per-frame form scores during that rep)
- **tempo** = average of per-rep tempo scores (100 if no `tempo` block)
- **rom** = each rep's ROM relative to the session's best ROM

**Rules**
- **R17 — Weights are relative** (they're normalized), but keep them intentional. Form-focused exercise → raise `formWeight`. Skill/cadence exercise → raise `repWeight`.
- **R18 — `mlFormWeight` defaults to 0.** Leave it out until a V2 model exists; setting it now has no effect (no classifier yet).
- **R19 — `tempo` is optional.** Omit it and tempo scores 100 (neutral). Include it only when tempo matters:
  ```json
  "tempo": { "eccentricDurationMs": 2000, "concentricDurationMs": 1000, "toleranceMs": 600 }
  ```
  `toleranceMs` is the free window before points are deducted.

---

## 9. `feedbackRules[]` + `voice`

```json
"feedbackRules": [
  { "id": "backPosture", "when": "formFinding:backPosture failed", "message": "Chest up", "priority": 0 },
  { "id": "depth",       "when": "formFinding:depth failed",       "message": "Deeper!",  "priority": 1 },
  { "id": "goodRep",     "when": "rep completed AND repScore>80",  "message": "Great rep!","priority": 3 },
  { "id": "milestone",   "when": "repCount==10",                   "message": "Halfway!",  "priority": 2 }
],
"voice": { "enabled": true, "coolDownMs": 2500, "maximumFeedbacksPerRep": 1 }
```

### `when` grammar (clauses joined by ` AND `)
| clause form | true when |
|---|---|
| `rep completed` | a rep closed this frame |
| `formFinding:<ruleId> failed` / `passed` | that form rule failed / passed this frame |
| `<metric> <op> <number>` | comparison holds |

**Metrics:** `repScore` (avg of the just-completed rep's form+tempo; only valid on a rep-completed frame), `formScore`, `tempoScore`, `overallScore`, `repCount`, `validReps`.
**Ops:** `>` `<` `>=` `<=` `==`.

**Rules**
- **R20 — Priority ladder:** `0` = safety (interrupts, **bypasses cooldown and per-rep cap**), `1` = form correction, `2` = tempo/pace, `3` = encouragement (dropped first under pressure). Reserve `0` for genuine safety.
- **R21 — One cue max per tick**, filtered by `coolDownMs` (global gap), a category dedupe window, and `maximumFeedbacksPerRep`. So keep messages short; don't rely on many firing at once.
- **R22 — Reference real ids/metrics.** `formFinding:<id>` must match a `formRules[].id`. A metric typo makes the clause silently false.
- `coolDownMs` (alias `cooldownMs`) and `enabled`, `maximumFeedbacksPerRep` are the only voice fields.

---

## 10. Canonical template (copy, then fill)

```json
{
  "analyzerType": "DYNAMIC_REP",
  "camera": { "position": "SIDE", "instruction": "", "fullBodyRequired": true, "minimumDistanceCm": 180 },
  "poseRequirements": { "requiredLandmarks": [], "minimumVisibilityScore": 0.6, "minimumLandmarkConfidence": 0.5 },
  "angles": [
    { "id": "primaryAngle", "vertexLandmark": "", "aLandmark": "", "bLandmark": "" }
  ],
  "stateMachine": {
    "initialState": "TOP",
    "states": ["TOP", "DESCENDING", "BOTTOM", "ASCENDING"],
    "transitions": [
      { "from": "TOP", "to": "DESCENDING", "condition": { "angleId": "primaryAngle", "op": "falling", "value": 0, "windowMs": 300 } },
      { "from": "DESCENDING", "to": "BOTTOM", "condition": { "angleId": "primaryAngle", "op": "<", "value": 0 } },
      { "from": "BOTTOM", "to": "ASCENDING", "condition": { "angleId": "primaryAngle", "op": "rising", "value": 0, "windowMs": 300 } },
      { "from": "ASCENDING", "to": "TOP", "condition": { "angleId": "primaryAngle", "op": ">", "value": 0 } }
    ]
  },
  "repRules": { "topStateId": "TOP", "bottomStateId": "BOTTOM", "countOn": "ASCENDING->TOP", "minimumRepDurationMs": 600, "maximumRepDurationMs": 6000 },
  "tempo": { "eccentricDurationMs": 0, "concentricDurationMs": 0, "toleranceMs": 500 },
  "formRules": [],
  "scoring": { "repWeight": 0.4, "formWeight": 0.4, "tempoWeight": 0.1, "romWeight": 0.1 },
  "feedbackRules": [],
  "voice": { "enabled": true, "coolDownMs": 2500, "maximumFeedbacksPerRep": 1 }
}
```

---

## 11. Pre-flight checklist (must all pass before saving)

- [ ] `analyzerType` is one of the 5 supported values.
- [ ] At least **one** angle in `angles[]` (else the Watch Me button never shows — `isSupported` gate).
- [ ] Every `condition.angleId`, `formRules.params.angleId`, and `feedbackRules formFinding:<id>` references an id that **exists**.
- [ ] `stateMachine.initialState` ∈ `states`; every transition `from`/`to` ∈ `states` (dynamic/compound/cardio only).
- [ ] `repRules.countOn` names a transition that exists; `top`/`bottom` states exist.
- [ ] `requiredLandmarks` contains only reliably-visible points for the chosen `camera.position`.
- [ ] Opposing transitions have a hysteresis gap (≥5°).
- [ ] `minimum/maximumRepDurationMs` bracket realistic human speed.
- [ ] Severities calibrated (a bad rep should visibly lower the score; a minor wobble shouldn't).
- [ ] Cue `message`s are short; safety cues are `priority: 0`.

If the parser rejects a config it throws `AiConfigException` and the app shows "coaching unavailable — log manually" (never a crash). Fix the field it names.

---

## 12. Worked example — authoring a **standing dumbbell curl** from scratch

1. **Type & view:** single-joint rep → `DYNAMIC_REP`; judged from the `SIDE`.
2. **Driving landmark:** elbow (angle closes on the way up). → `elbowAngle` first.
3. **Angles:** `elbowAngle` (SHOULDER-ELBOW-WRIST) + form angle `upperArmDrift` (HIP-SHOULDER-ELBOW, detects the elbow swinging forward).
4. **Required landmarks:** `SHOULDER_L, ELBOW_L, WRIST_L` (all reliably visible side-on). Hip is only for the bonus drift angle → not required.
5. **State machine (note: curl is inverted — angle is LARGE at bottom/arm-extended, SMALL at top/contracted):**
   `DOWN → LIFTING → UP → LOWERING → DOWN`, driven by `elbowAngle` (`falling <150` to lift, `<40` at top, `rising >50` to lower, `>150` back to down).
6. **repRules:** top=`UP`, bottom=`DOWN`? — here the "bottom" (max ROM point) is the contracted `UP` state. Set `bottomStateId: "UP"` so ROM/tempo split at peak contraction; `topStateId: "DOWN"`, `countOn: "LOWERING->DOWN"`.
7. **formRules:** `romDepth {angleId:"elbowAngle", minAngle:40, atState:"UP"}` ("curl higher"); `angleThreshold {angleId:"upperArmDrift", max:15}` ("keep your elbow pinned").
8. **feedback + voice:** drift cue `priority:0` (it's the key fault), depth `priority:1`, `goodRep` `priority:3`.

The lesson: **"bottom" means "max-ROM / turnaround point," not literally lowest** — for a curl that's the top. Point `bottomStateId` and the `romDepth atState` at wherever peak contraction happens, and everything else (ROM, tempo split, depth cue) lines up.

---

*Keep this guide and the config in lock-step with the engine. If you add a new form-rule primitive, condition op, analyzer, or metric in `lib/features/exercise_ai/`, add it here the same PR — this document is the contract authors rely on.*
