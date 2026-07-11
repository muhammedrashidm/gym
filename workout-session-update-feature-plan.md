# Workout Session Update Feature — Flutter Implementation Plan

Companion doc to [`workout-session-api.md`](workout-session-api.md) (the backend contract: `complete`/`skip`/`sessions` under `/workout-profiles/:profileId/sessions/...`). This doc plans the Flutter app side: two role-specific sub-features (member self-logging, trainer logging on behalf of a client) sharing one API-facing repository, plus a local Drift staging layer and a live-progress background surface (notification + iOS Live Activity/Dynamic Island).

**Confirmed scope decisions** (see §9 for why these matter):
- "Active clients" for the trainer's aggregate = clients with an **in-progress session currently staged on the trainer's own device** (local Drift state), *not* a gym check-in/attendance concept — no such concept exists in the backend or app today, and building one is out of scope here.
- iOS gets a **real native Live Activity / Dynamic Island** (WidgetKit extension via a plugin), not just a cross-platform notification fallback. Android gets an ongoing/foreground notification as its equivalent.

---

## 0. What exists today vs. what this plan builds

| Area | Current state | This plan |
|---|---|---|
| `gym/lib/features/workout/` | Trainer's **program-authoring** feature (profiles → weekly plans → day plans → tasks). Fully wired, real API, CQRS handlers, `WorkoutRepository`. | Extend `WorkoutRepository`/`WorkoutRemoteDataSource`/`WorkoutRepositoryImpl` with 3 new methods for `complete`/`skip`/`sessions` (§3). Not touched otherwise. |
| `gym/lib/features/workout_session/` | Member's "do today's workout" UI — **mockup only**. Hardcoded `Map` data, `setState`-only completion tracking, a `SnackBar` instead of a real API call ([`weekly_plan_page.dart:206`](gym/lib/features/workout_session/presentation/pages/weekly_plan_page.dart), [`task_execution_page.dart:25`](gym/lib/features/workout_session/presentation/pages/task_execution_page.dart)). No `data/`/`domain/`/cubit at all. | Rebuild as a real feature: `data/`, `domain/`, `presentation/cubit/` added; existing pages rewired to a real cubit instead of local mock state. Existing routes (`train`, `taskExecution`) are **reused**, not replaced. |
| Trainer "log for a client" | Doesn't exist in any form. | New sub-feature inside the same `workout_session` module: a live-clients list page + a client session page, both new routes under the staff shell. |
| Local persistence | `shared_preferences` (simple keys) + `flutter_secure_storage` (tokens) only. No Drift, no local DB. | Add `drift` + `sqlite3_flutter_libs` under `gym/lib/core/database/` — new shared infra, first consumer of Drift in the app. |
| Background progress surface | Nothing — no `flutter_local_notifications`, no `workmanager`, no live-activity plugin. | Add `flutter_local_notifications` (Android ongoing notification) + `live_activities` (iOS Live Activity/Dynamic Island) behind one `core/live_session/` service. |

---

## 1. Architecture overview

```
features/workout_session/
  data/
    datasources/
      workout_session_local_datasource.dart   (Drift-backed; task-completion staging)
    models/
      (reuses WorkoutSessionResponseDto shape via a WorkoutSessionLogModel)
  domain/
    entities/
      workout_session_log.dart                 (mirrors WorkoutSessionResponseDto)
      task_completion_draft.dart                (local staged row, pre-submission)
      session_draft.dart                        (aggregate: profileId + status + drafts)
  # NOTE: no new domain/repositories/ — see §3, this feature reuses WorkoutRepository
  presentation/
    cubit/
      member_workout_session/
        member_workout_session_cubit.dart
        member_workout_session_state.dart
      trainer_live_clients/
        trainer_live_clients_cubit.dart
        trainer_live_clients_state.dart
      trainer_client_session/
        trainer_client_session_cubit.dart
        trainer_client_session_state.dart
    pages/
      weekly_plan_page.dart        (existing — rewired, member)
      task_execution_page.dart     (existing — rewired, member)
      trainer_live_clients_page.dart   (new)
      trainer_client_session_page.dart (new)

core/database/
  app_database.dart                 (new — Drift @DriftDatabase)
  tables/
    session_drafts_table.dart
    task_completion_drafts_table.dart

core/live_session/
  live_session_notifier.dart         (abstract interface)
  live_session_notifier_impl.dart    (platform dispatch: iOS Live Activity vs Android notification)
  session_sync_service.dart          (bridges Drift streams -> notifier calls)
```

### 1.1 Why one feature folder, two role-specific cubit sets, one shared repository

- **Repository reuse (as requested): yes, and it's the right call.** Both flows hit the *exact same three server endpoints* — `POST .../complete`, `POST .../skip`, `GET .../sessions` — differing only in *which* `workoutProfileId` is passed (the member's own profile vs. a client's profile the trainer picked). The server already derives `loggedByRole` (`MEMBER`/`TRAINER`) from the auth token, never from the request body (see `workout-session-api.md` §2.1) — so there is no payload difference for the Flutter client to model. Splitting the repository/datasource per role would just duplicate the same three Dio calls twice for no behavioral gain. **Decision: extend the existing `WorkoutRepository`/`WorkoutRemoteDataSource`/`WorkoutRepositoryImpl`** (§3) rather than introducing a parallel `WorkoutSessionRepository` — this mirrors the backend design doc's own §0.1 reasoning ("same operation, different actor, don't split for that alone").
- **Cubit/query/command per sub-feature: yes, kept separate**, per your instruction, because the two flows *do* diverge above the repository line:
  - The member cubit resolves its own `workoutProfileId` from the logged-in user's session (no picker).
  - The trainer cubit resolves it from a `:clientId` route param the trainer explicitly selected, and needs a second cubit just to build that selection list (with local "in-progress" state the member flow has no equivalent of).
  - Keeping them as separate command/query classes (rather than one shared class both cubits call) leaves room for each side to diverge later (e.g., trainer-side analytics tagging, a confirmation step before logging on someone else's behalf) without reopening a shared file both roles depend on.
- Net result: **3 cubits, 6 command/query classes (3 member + 3 trainer), 1 repository.** Table in §4 spells out every class.

---

## 2. Local Drift schema (`core/database/`)

New package: `drift: ^2.20.0`, `drift_dev: ^2.20.0` (dev), `sqlite3_flutter_libs: ^0.5.24`, `path_provider: ^2.1.4` (for the DB file location), `path: ^1.9.0`.

Two tables, keyed by `workoutProfileId` so **multiple concurrent in-progress sessions can coexist on one device** — required for the trainer case (running several clients through workouts at the same time), and harmless for the member case (there's naturally only one row).

```dart
// core/database/tables/session_drafts_table.dart
class SessionDrafts extends Table {
  TextColumn get workoutProfileId => text()();      // PK
  TextColumn get clientProfileId => text()();        // who this session belongs to (== member's own profile id, for the member flow)
  IntColumn get dayIndexAtTime => integer()();        // snapshot of currentDayIndex when the session was opened
  TextColumn get dayPlanId => text().nullable()();
  TextColumn get dayPlanLabel => text().nullable()();
  TextColumn get weeklyPlanName => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  TextColumn get sessionNotes => text().nullable()();
  BoolColumn get isTrainerInitiated => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {workoutProfileId};
}

// core/database/tables/task_completion_drafts_table.dart
class TaskCompletionDrafts extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())(); // PK
  TextColumn get workoutProfileId => text().references(SessionDrafts, #workoutProfileId)();
  TextColumn get taskId => text()();
  IntColumn get actualSets => integer().nullable()();
  TextColumn get actualReps => text().nullable()();
  RealColumn get actualWeightKg => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

`AppDatabase` (`@DriftDatabase(tables: [SessionDrafts, TaskCompletionDrafts])`) is registered `@singleton` in DI (same pattern as `ApiClient`), opened once at app start via `NativeDatabase.createInBackground(file)` under the app's documents directory.

**Local data source** (`WorkoutSessionLocalDataSource`, `@Singleton`, wraps `AppDatabase`):

| Method | Purpose |
|---|---|
| `startOrResumeDraft(SessionDraft draft)` | Upsert a `SessionDrafts` row when a session page opens (idempotent — reopening an in-progress session resumes it) |
| `upsertTaskCompletion(TaskCompletionDraft draft)` | Called every time the user fills in/edits a task's actuals — this is the per-task "save to Drift" step from requirement 1 |
| `watchDraft(String workoutProfileId)` | `Stream<SessionDraftWithTasks?>` — drives both the cubit's live UI state and the live-activity/notification sync (§5) |
| `watchAllActiveDrafts()` | `Stream<List<SessionDraftWithTasks>>` — **all** in-progress drafts on the device, used only by the trainer's live-clients cubit and the trainer's aggregate notifier |
| `clearDraft(String workoutProfileId)` | Deletes the `SessionDrafts` row + cascades its `TaskCompletionDrafts` — called after a successful `complete`/`skip` API call |

This is a plain Drift-backed class, not wrapped in `Either<Failure, T>` — local disk I/O isn't a network failure mode, so cubits call it directly and let a Drift exception surface as a generic local-storage error state (rare, not worth modeling as a `Failure` variant).

---

## 3. Repository / remote data source changes (shared, reused by both roles)

Add to the **existing** `gym/lib/features/workout/domain/repositories/workout_repository.dart`:

```dart
Future<Either<Failure, WorkoutSessionLog>> completeSession(
  String workoutProfileId, {
  List<TaskCompletionInput>? taskCompletions,
  String? notes,
});

Future<Either<Failure, WorkoutSessionLog>> skipSession(
  String workoutProfileId, {
  String? reason,
});

Future<Either<Failure, ({List<WorkoutSessionLog> logs, int total, int page, int pageSize})>> getSessionLogs(
  String workoutProfileId, {
  int page = 1,
  int pageSize = 20,
});
```

`WorkoutRemoteDataSource` gets matching methods calling `ApiClient.post('/workout-profiles/$workoutProfileId/sessions/complete', ...)` / `.../sessions/skip` / `ApiClient.get('/workout-profiles/$workoutProfileId/sessions', queryParameters: {...})` — same nested-path convention already used for `/workout-profiles/$id/weekly-plans` (`workout_remote_datasource.dart`). Response parsing follows the existing ad hoc pattern (`WorkoutSessionLogModel.fromJson(response.data['data'])`, list variant for `getSessionLogs`), no new shared response wrapper needed.

`WorkoutRepositoryImpl` wraps all three in the existing `try { ... } on DioException catch (e) { return Left(_mapDioError(e)); }` block — **reuse `_mapDioError` verbatim** (`workout_repository_impl.dart:261-276`), no changes needed there.

New entity `WorkoutSessionLog` (domain, `@freezed`) mirrors `WorkoutSessionResponseDto` 1:1 (see `workout-session-api.md` §3 for the field table: `id`, `workoutProfileId`, `weeklyPlanId`, `weeklyPlanName`, `dayPlanId`, `dayPlanLabel`, `dayIndexAtTime`, `cycleNumberAtTime`, `status`, `scheduledDate`, `completedDate`, `loggedByRole`, `loggedByUserId`, `currentDayIndexAfter?`).

---

## 4. Domain layer — commands & queries (mediator pattern, `dart_mediatr`)

Both files below depend on the same `WorkoutRepository` (§3) — this is the reuse point. Everything above the repository call is role-specific.

**`domain/usecases/member_session_commands.dart`:**

| Class | Input | Delegates to |
|---|---|---|
| `CompleteMemberWorkoutSessionCommand` | `workoutProfileId`, `taskCompletions`, `notes` | `WorkoutRepository.completeSession` |
| `SkipMemberWorkoutSessionCommand` | `workoutProfileId`, `reason` | `WorkoutRepository.skipSession` |
| `GetMemberWorkoutSessionLogsQuery` | `workoutProfileId`, `page`, `pageSize` | `WorkoutRepository.getSessionLogs` |

**`domain/usecases/trainer_session_commands.dart`:**

| Class | Input | Delegates to |
|---|---|---|
| `CompleteClientWorkoutSessionCommand` | `clientProfileId`, `workoutProfileId`, `taskCompletions`, `notes` | `WorkoutRepository.completeSession` |
| `SkipClientWorkoutSessionCommand` | `clientProfileId`, `workoutProfileId`, `reason` | `WorkoutRepository.skipSession` |
| `GetClientWorkoutSessionLogsQuery` | `clientProfileId`, `workoutProfileId`, `page`, `pageSize` | `WorkoutRepository.getSessionLogs` |

`clientProfileId` is carried on the trainer commands even though the repository call itself only needs `workoutProfileId` — it's there for the handler to do a client-side sanity check against `StaffRepository.listStaffClients()` (the trainer is only ever shown clients assigned to them; this is a defense-in-depth UI guard, not a substitute for the server's own `checkProfileAccess`).

One more query, **local-only, no repository/API involvement**:

`GetTrainerActiveClientDraftsQuery` (`trainer_session_commands.dart`) → `WorkoutSessionLocalDataSource.watchAllActiveDrafts()`, feeds the trainer's live-clients list and the aggregate notifier (§5).

All six remote-backed handlers register in `injection.dart` under a new `// Workout Session Handlers` block, same manual-wiring step every other feature already requires (`mediator.registerCommandHandler(getIt<XHandler>())`).

---

## 5. Presentation layer

### 5.1 Member: `MemberWorkoutSessionCubit`

States (freezed union): `initial`, `loading`, `loaded(profile, dayPlan, draft, tasks)`, `submitting`, `submitted(sessionLog)`, `error(Failure)`.

Responsibilities:
1. On page open: fetch the member's `WorkoutProfile` + today's `DayPlan`/tasks (existing `WorkoutRepository` methods, no change needed there), then `WorkoutSessionLocalDataSource.startOrResumeDraft(...)` — if a draft already exists for this profile (app was killed mid-session), resume it instead of starting fresh.
2. On each task's actuals being filled in: `upsertTaskCompletion` — this is the "stored to Drift" step per requirement 1, happening continuously during the workout, not batched at the end.
3. Exposes a live `Stream` (via `watchDraft`) that the cubit forwards into its state, so the page always reflects the latest local staging — including from `SessionSyncService` if something else changed it (defensive, not expected in the member flow since only one page writes to it).
4. On "Complete Session" tap: read all staged `TaskCompletionDrafts` for this profile, dispatch `CompleteMemberWorkoutSessionCommand` with them mapped to the API shape, and on success: `clearDraft`, update local `currentDayIndex` from `currentDayIndexAfter` in the response (no need to refetch the profile), emit `submitted`.
5. On "Skip" tap: same shape via `SkipMemberWorkoutSessionCommand`, `clearDraft` after, no cursor update needed client-side (server doesn't move it either).
6. On failure: keep the Drift draft intact (nothing is lost) and emit `error` — user can retry without re-entering data.

Pages (**existing, rewired, not replaced**):
- `weekly_plan_page.dart` — replace the hardcoded `_daysWorkoutData`/`_completedTasks` with `BlocBuilder<MemberWorkoutSessionCubit, ...>`; the `_completeWorkoutSession()` `SnackBar`-only stub (`weekly_plan_page.dart:206`) becomes the real submit call.
- `task_execution_page.dart` — the `_handleComplete()` stub (`task_execution_page.dart:25`, currently just `context.pop(true)` after a `Future.delayed`) becomes a call into the cubit's `upsertTaskCompletion`, then pop with the real per-task result.

### 5.2 Trainer, page 1: `TrainerLiveClientsCubit` + `trainer_live_clients_page.dart` (new)

States: `initial`, `loading`, `loaded(List<ClientWithSessionStatus>)`, `error`.

`ClientWithSessionStatus` = `ClientProfile` (from `StaffRepository.listStaffClients()`, already implemented) joined client-side with the matching row (if any) from `GetTrainerActiveClientDraftsQuery`. A client shows as "active" purely because a local draft row exists for their `workoutProfileId` — **this list is a merge of one remote call (client roster) and one local stream (draft state), no new backend call**.

Sort: in-progress clients first (by `startedAt` ascending — oldest-started first, likely who's been waiting longest), then the rest of the assigned roster below a divider, consistent with `staff_clients_page.dart`'s existing filter-chip pattern (reuse that page's card layout/styling — see §7 brief).

Tapping a client with no active draft: starts a new one (calls into `TrainerClientSessionCubit.startOrResume` on the next page). Tapping one with an active draft: navigates straight into it, resuming where it left off.

### 5.3 Trainer, page 2: `TrainerClientSessionCubit` + `trainer_client_session_page.dart` (new)

Structurally the mirror of `MemberWorkoutSessionCubit` (§5.1) — same states, same Drift staging flow — except:
- `workoutProfileId`/`clientProfileId` come from the route (`:clientId` param, resolved to the client's `WorkoutProfile` via the existing `WorkoutRepository.getWorkoutProfiles`/lookup-by-client call), not from the logged-in user's own session.
- Dispatches `CompleteClientWorkoutSessionCommand`/`SkipClientWorkoutSessionCommand` (§4) instead of the member variants.
- Multiple instances of this cubit can be alive at once (one per open client tab/page) since Drift keys by `workoutProfileId` — the trainer can back out to the live-clients list, open a second client, and both drafts persist independently.

---

## 6. Routing changes

**Member — no new routes.** Reuse `AppRoute.train` and `AppRoute.taskExecution` (already inside `_memberShellNavigatorKey`'s shell, per `app_router.dart`/`app_routes.dart`) — only the pages' internals change (§5.1), not the router.

**Trainer — two new routes**, both under the existing `/staff/...` prefix (so `router_guard.dart`'s existing path-prefix check already covers them — no guard changes needed):

```dart
// app_routes.dart additions
staffLiveSessions(path: '/staff/live-sessions', name: 'staff-live-sessions'),
clientSessionUpdate(path: '/staff/clients/:clientId/session', name: 'client-session-update'),
```

- `staffLiveSessions` → `trainer_live_clients_page.dart`. **Recommendation: add as a 4th tab in `_StaffShell`** (alongside DASHBOARD/CLIENTS/PROFILE) rather than a push-over route — this is a primary, frequently-revisited trainer workflow (parallel to how the member's TRAIN tab is a primary shell tab, not a pushed page), and living in the shell means the trainer can flip to CLIENTS or DASHBOARD mid-session without losing the tab.
- `clientSessionUpdate` → `trainer_client_session_page.dart`, a **root-level route** (like `athleteWorkout`/`initiateProgram` today), pushed from either the live-clients list or from `staff_clients_page.dart`'s existing client card — pushing over the shell hides the staff bottom nav during an active logging session, consistent with how `weekPlanCreator`/`dayPlanCreator` already hide it during authoring flows.

---

## 7. Background progress surface (notification + Live Activity)

### 7.1 New core service: `core/live_session/`

```dart
abstract interface class LiveSessionNotifier {
  Future<void> updateMemberSession(MemberSessionProgress progress);
  Future<void> clearMemberSession();
  Future<void> updateTrainerAggregate(List<ClientSessionProgress> activeClients);
  Future<void> clearTrainerAggregate();
}

@Singleton(as: LiveSessionNotifier)
class LiveSessionNotifierImpl implements LiveSessionNotifier { ... }
```

Platform dispatch inside the impl:
- **iOS**: `live_activities` plugin (`^2.2.0`) drives a real Live Activity — Lock Screen + Dynamic Island compact/expanded views. Requires a native WidgetKit extension target added to the iOS Xcode project (Swift, `ActivityAttributes` struct mirroring `MemberSessionProgress`/`ClientSessionProgress` shape) — **this is native iOS work outside pure Dart**, not just a `pubspec.yaml` add. Flagging explicitly per your confirmation this is in scope.
- **Android**: `flutter_local_notifications` (`^18.0.0`) posts/updates an **ongoing** (non-dismissible while session active) notification with a progress bar (`AndroidNotificationDetails(ongoing: true, showProgress: true, ...)`), updated in place (same notification `id`) rather than re-posted, matching the Live Activity's "live-updating" feel as closely as Android's notification API allows.

`MemberSessionProgress` = `{ dayPlanLabel, tasksCompleted, tasksTotal, startedAt }`.
`ClientSessionProgress` = `{ clientName, tasksCompleted, tasksTotal }` per client; the trainer aggregate view is `{ activeClientCount, clients: List<ClientSessionProgress> }`.

### 7.2 Sync mechanism: `SessionSyncService`

A `@singleton` that owns two subscriptions, started once at app init (in `injection.dart`, same place `Mediator` is bootstrapped) and torn down never (lives for app lifetime, like the DB connection):

```dart
class SessionSyncService {
  SessionSyncService(this._localDataSource, this._notifier, this._authCubit) {
    _authCubit.stream.listen(_onAuthChanged); // switch behavior by active role
  }

  StreamSubscription? _memberSub;
  StreamSubscription? _trainerSub;

  void _onAuthChanged(AuthState state) {
    // Role.member -> watch this device's single draft (own profile) -> updateMemberSession
    // Role.staff  -> watch watchAllActiveDrafts() -> updateTrainerAggregate
    // logged out / other -> clear both
  }
}
```

This is the concrete answer to requirement 2's "all these data should be in sync with the background service": the **Drift stream is the single source of truth**; the cubits write to Drift, and the notifier only ever reads from the same Drift streams the cubits read from — there's no separate/parallel state to drift out of sync, by construction. A cubit never calls `LiveSessionNotifier` directly; it only ever touches Drift, and `SessionSyncService` is the one place that turns Drift changes into a visible notification/Live Activity update.

### 7.3 Known limitation (flag, don't silently gloss over)

Live Activity/notification updates only happen while the Flutter engine is alive (foregrounded or backgrounded-but-not-killed) — this covers the realistic case (glancing at the lock screen mid-session) but **not** a fully force-quit app. True killed-app updates would need server-pushed Live Activity updates via APNs, which requires backend work (a push token registration endpoint + server-side trigger) not covered by `workout-session-api.md` today. Out of scope for this pass — noted here so it isn't assumed to already work.

---

## 8. New dependencies summary (`pubspec.yaml` additions)

```yaml
dependencies:
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0
  flutter_local_notifications: ^18.0.0
  live_activities: ^2.2.0

dev_dependencies:
  drift_dev: ^2.20.0
```

(`uuid` is already a dependency — reused for Drift row ids.)

---

## 9. Stitch design briefs

Three new/changed pages need visual design. Each brief below is written to be pasted directly into Stitch. All three carry the same theming instruction — **do not restate colors/fonts as raw hex/font names in the Stitch prompt; reference the project's own theme system** so Stitch is told to match, not invent:

> Use this project's existing design system which is already defined in stich alos implemented in flutter app, not a generic one.

### 9.1 Member — Session Update page (rewiring `weekly_plan_page.dart` + `task_execution_page.dart`)

```
Design a mobile "today's workout session" flow for a fitness app, two connected screens.

Screen A — Day overview: header shows the program name and "Day {N} · Week {M}" (small
label style). Below it, a horizontal 7-day strip (day 1..7) showing which day is "today"
(highlighted) vs future/past days (muted) — this is a read-only cycle indicator, not a
calendar. Below that, a vertical list of today's tasks (exercise name, target sets/reps/
weight as planned), each row showing a completion state: not-started (outline only),
in-progress (partial fill, e.g. some sets logged), done (filled with the success accent
and a checkmark). Tapping a task row opens Screen B. Bottom of Screen A has two persistent
actions: a primary "Complete Session" button (disabled/de-emphasized state until at least
one task has actuals logged) and a secondary "Skip Today" text-button/link style action
that requires a short confirmation (skipping doesn't need per-task data).

Screen B — Task execution: full-screen single-task view. Shows the exercise name, the
planned target (sets/reps/weight) as reference text, then editable inputs for actual sets
(stepper/number input), actual reps (free text, since reps can vary per set — e.g. "10,10,8,8"),
actual weight (numeric, kg), and an optional notes field (multiline, short). A prominent
"Save & Next" action that returns to Screen A with that task now shown as done. Every field
change should read as being saved immediately/locally (subtle "saved" micro-state near the
field), not needing an explicit separate save step per field — the actual submission to the
server only happens later from Screen A's "Complete Session" button.

Both screens: flat cards/rows (no shadows, no rounded corners), clear light and dark variants.
Show an empty/error state for Screen A for when no active program day exists yet ("no plan
assigned" messaging, no CTA that implies the member can fix it themselves).
```

### 9.2 Trainer — Live Clients list page (new: `trainer_live_clients_page.dart`)

```
Design a mobile page for a personal trainer to see, at a glance, which of their clients
currently have an in-progress workout session open (started on the trainer's own device,
not yet submitted), so they can jump back into any of several clients they're running
through workouts concurrently.

Layout: a header section summarizing the aggregate — "{N} active sessions" plus a compact
combined progress indicator (e.g. total tasks completed across all active clients out of
total tasks planned). Below it, a list split into two groups with a visible divider: "Active
now" (clients with an in-progress session — each row shows client name/avatar, a per-client
progress indicator such as a thin progress bar or "3/6 tasks", and how long the session's
been open), and "Start a session" (the rest of the trainer's assigned client roster, tappable
to begin a new session for that client). Active-now rows should read as clearly "live"/
in-progress (use the success accent color proportionally to completion, not as a flat badge)
— distinguish this visually from a simple status badge like "ACTIVE/INACTIVE account" used
elsewhere in the app, since this is about a live session, not account status.

Include a search/filter field at the top (matching this app's existing client-list search
pattern), pull-to-refresh, and an empty state for "no active sessions right now, tap any
client below to start one." Flat list rows with outline borders, no cards/shadows, light and
dark variants.
```

### 9.3 Trainer — Client Session Update page (new: `trainer_client_session_page.dart`)

```
Design a mobile page, structurally near-identical to a member's own "today's workout session"
screen, but for a trainer logging a session on behalf of a specific client they're currently
training in person. Header must make the acting context unambiguous: client's name/avatar
prominently at the top (this is not the trainer's own workout), plus the same "Day {N} ·
Week {M} · {Program name}" line and 7-day cycle strip as the member version. Same task list
below (target vs actual, per-task completion state using the success accent), same task-detail
editing screen for entering actual sets/reps/weight/notes per task, same "Complete Session" /
"Skip Today" actions at the bottom.

Add one small but important affordance the member version doesn't need: a persistent, subtle
"Editing on behalf of {client name}" indicator/strip (not a blocking banner — a slim always-
visible label, e.g. pinned under the header) so the trainer can't lose track of whose session
they're editing if they've navigated between several clients back-to-back. Include a back
action that returns to the Live Clients list (screen 9.2), where this client's progress should
already reflect whatever was just saved.

Flat, no shadows, no rounded corners, light and dark variants, reusing the same task-row and
task-detail patterns as the member screens for visual consistency across both roles.
```

---

## 10. Build order (checklist)

1. **Data foundation** — add Drift deps, `core/database/` tables + `AppDatabase`, `WorkoutSessionLocalDataSource`. No UI yet; unit-test staging/clearing logic in isolation.
2. **Remote layer** — extend `WorkoutRepository`/`WorkoutRemoteDataSource`/`WorkoutRepositoryImpl` with `completeSession`/`skipSession`/`getSessionLogs` (§3); add `WorkoutSessionLog` entity. Verify against the live backend (already implemented per `workout-session-api.md`) with a manual smoke call before wiring cubits.
3. **Member vertical slice** — `member_session_commands.dart`, `MemberWorkoutSessionCubit`, rewire `weekly_plan_page.dart` + `task_execution_page.dart`. Ship and verify end-to-end (Drift staging → complete → server) before starting the trainer side.
4. **Trainer vertical slice** — `trainer_session_commands.dart`, both trainer cubits, both new pages, two new routes (§6).
5. **Background surface** — `core/live_session/`, `SessionSyncService`, Android notification first (lower lift), then iOS Live Activity/WidgetKit extension (higher lift, native iOS work — budget separately).
6. **Stitch designs** (§9) can run in parallel with steps 1–2 once this doc is agreed, since they don't depend on the data layer being finished.

## 11. Open items carried over from the API doc

- Backfilling a non-current day (`workout-session-api.md` §5) is still explicitly out of scope — none of the pages above should grow an "edit a past day" affordance.
- The trainer's "active client" concept here is **local-device-only** (per your confirmation) — if real gym check-in/attendance is ever wanted instead, that's a separate, larger feature (new backend concept) and would change §7's aggregate source from Drift to a server subscription.
