# Kinetic (gym/) — Architecture Report

Generated from a full-codebase analysis. This document is a reference for the Clean Architecture + CQRS (`dart_mediatr`) pattern this Flutter app follows — read `CLAUDE.md` first for the short version; this is the exhaustive one.

## 1. Overview

**Stack**: `flutter_bloc`/`bloc` (state management), `go_router` (routing), `get_it`/`injectable` (DI), `dio` (networking), `dart_mediatr` (CQRS mediator), `sqflite` (local DB — chosen over Drift to avoid an `analyzer` version conflict with `dart_mediatr`), `freezed`/`json_serializable` (immutable models/codegen), `dartz` (`Either<Failure, T>` functional error handling), `google_fonts`, `file_picker`, `mobile_scanner`, `flutter_local_notifications`.

**Layering contract** (feature-first, under `lib/features/<feature>/{data,domain,presentation}`):

```
presentation/cubit → Mediator.sendCommand() → domain/usecases (ICommand/ICommandHandler)
  → domain/repositories (interface) → data/repositories (impl) → data/datasources → ApiClient (Dio)
```

`domain` must not depend on `data`/`presentation` (one deliberate exception documented in §12). Repositories return `Either<Failure, T>`; datasources throw, repositories catch `DioException` and map to `Failure`.

**Two critical, easy-to-miss rules** (both confirmed live in code):
- **DI success ≠ Mediator dispatch.** Every `ICommandHandler` must be both `@injectable`-annotated *and* manually added to `configureDependencies()`'s `mediator.registerCommandHandler(...)` list in `lib/core/di/injection.dart`, or the Mediator silently won't route to it even though `get_it` resolves it fine.
- **Cubit construction is a genuinely mixed pattern across this app** — some cubits are `@injectable` singletons resolved via `GetIt.I<X>()` at the router level; others are deliberately excluded from DI and constructed locally per-page as `XCubit(getIt<Mediator>())`. Both are legitimate, established conventions here — see the per-feature tables below before assuming either pattern for a new cubit.

## 2. Core layer (`lib/core/`)

### 2.1 Dependency Injection — `core/di/injection.dart` + generated `injection.config.dart`

`configureDependencies(AppConfig config)` (`@InjectableInit()`) runs in five ordered steps:

1. **Manual external registrations**: `AppConfig` (the flavor singleton), `FlutterSecureStorage`, an awaited `SharedPreferences` singleton, `FlutterLocalNotificationsPlugin`.
2. **`Mediator` singleton** created and registered *before* `getIt.init()` — required because `AuthCubit` (registered inside generated init) depends on it.
3. **`getIt.init()`** — the generated pass wiring every `@singleton`/`@injectable`/`@Injectable(as: X)` class across all features and core singletons (`ApiClient`, `AuthInterceptor`, `TokenRefreshService`, `AppDatabase`, `SecureStorage`, `PreferencesStorage`, `AppRouter`, `SessionSyncService`, etc.).
4. **Manual Mediator handler wiring** — every `ICommandHandler` in the app, **33 total**, grouped by feature:
   - **Auth/Profile (5)**: `SendOtpCommandHandler`, `VerifyOtpCommandHandler`, `LogoutCommandHandler`, `TrainerSignupCommandHandler`, `ConnectToTrainerCommandHandler`
   - **Staff (3)**: `GetQrTokenQueryHandler`, `ListStaffClientsQueryHandler`, `StaffCreateProfileCommandHandler`
   - **Workout (13)**: `GetWorkoutProfilesQueryHandler`, `CreateWorkoutProfileCommandHandler`, `UpdateWorkoutProfileCommandHandler`, `CreateWeeklyPlanCommandHandler`, `CreateFullWeeklyPlanCommandHandler`, `GetWeeklyPlansQueryHandler`, `GetWeeklyPlanDetailsQueryHandler`, `ActivateWeeklyPlanCommandHandler`, `GetDayPlanDetailsQueryHandler`, `UpdateDayPlanCommandHandler`, `CreateTaskCommandHandler`, `UpdateTaskCommandHandler`, `DeleteTaskCommandHandler`
   - **Task Media (2)**: `SearchTaskMediaQueryHandler`, `CreateTaskMediaCommandHandler`
   - **Workout Session — shared (1)**: `GetTodayPlanQueryHandler`
   - **Workout Session — Member (4)**: `GetMemberActiveProfileQueryHandler`, `CompleteMemberWorkoutSessionCommandHandler`, `SkipMemberWorkoutSessionCommandHandler`, `GetMemberWorkoutSessionLogsQueryHandler`
   - **Workout Session — Trainer (5)**: `GetClientWorkoutProfileQueryHandler`, `CompleteClientWorkoutSessionCommandHandler`, `SkipClientWorkoutSessionCommandHandler`, `GetClientWorkoutSessionLogsQueryHandler`, `GetTrainerActiveClientDraftsQueryHandler`
5. **Background service bootstrap** — `getIt<SessionSyncService>()` is called purely to instantiate the singleton and keep it alive for the app's lifetime.

### 2.2 Router — `core/router/app_router.dart`, `app_routes.dart`, `router_guard.dart`

`AppRoute` enum (`app_routes.dart`) defines 23 `(path, name)` pairs. `AppRouter` (`@singleton`) builds a `GoRouter` with `initialLocation: splash`, `redirect: guard.redirect`, and `refreshListenable: GoRouterAuthNotifier(_authCubit)` — a `ChangeNotifier` subscribed to `authCubit.stream` that forces GoRouter to re-run `redirect` on every auth change.

**Root-level routes** (outside any shell): `splash`, `login`, `otp`, `selectWorkspace`, `trainerSignup`, `staffQr`, `clientScanner`, `staffAddClient`, `athleteWorkout` (`:clientId`), `initiateProgram` (`:clientId`), `weekPlanCreator` (`:clientId`, `:workoutProfileId`), `dayPlanCreator`. Plus two redirect-only convenience routes: `member` → `explore`, `staff` → `staffDashboard`. And two routes deliberately pushed **over** the shells: `clientSessionUpdate` and `dayPreview` — root-level specifically so they hide the bottom nav during active session logging (explicit code comment).

**Member `ShellRoute`** (`_MemberShell`, custom SVG-icon bottom nav + centered FAB): `explore` (`ExplorePage`), `train` (`WeeklyPlanPage`, wrapped in `BlocProvider<MemberWorkoutSessionCubit>`), `taskExecution` (`TaskExecutionPage`, same cubit), `recovery` (`RecoveryPage`), `profile` (`profile` feature's `ProfilePage`, **not** `member`'s own).

**Staff `ShellRoute`** (`_StaffShell`, Material-icon bottom nav, sharp 0px borders): `staffDashboard`, `staffClients`, `staffProfile`, `staffLiveSessions` (`TrainerLiveClientsPage`, wrapped in `BlocProvider<TrainerLiveClientsCubit>`).

**`RouterGuard.redirect`** — the single point of all auth/role redirect logic, driven by `AuthCubit.state`:
- `Initial`/`CheckingToken` → forced to `splash`.
- `Unauthenticated`/`Error` → forced to `login` (unless already on `login`/`otp`).
- `OtpSent` → no redirect (page self-manages).
- `Authenticated`: `trainerSignup` route only reachable if the user has no staff role yet; `selectWorkspace` always allowed through; landing on an auth/splash route while authenticated bounces to `member`/`staff` based on `activeRole`; cross-workspace guard redirects `/member` paths if active role isn't member (and symmetric for `/staff`).

### 2.3 Network — `core/network/`

**`ApiClient`** (`@singleton`) wraps one `Dio` (`baseUrl` from `AppConfig`, 15s timeouts, `Content-Type: application/json`, `X-Client-Platform: mobile`). `LoggerInterceptor` (thin `pretty_dio_logger` subclass) attached first if `config.enableLogging`; `AuthInterceptor` always last. Exposes generic `get/post/put/patch/delete<T>`.

**`AuthInterceptor`** (`@singleton`): `onRequest` attaches `Authorization: Bearer <token>` from `SecureStorage`. `onError` only handles 401 — single-flight guarded (`_isRefreshing` + a `_pendingRequests` queue so concurrent 401s don't trigger duplicate refreshes), calls `TokenRefreshService.refresh()`, then branches on the sealed `RefreshResult`:
- `RefreshSuccess` → retries the original + all queued requests via `_resolveWithRetry`.
- `RefreshRejected` → rejects all queued, passes error through, calls `AuthCubit.forceLogout()` — the **only** scenario that forces logout.
- `RefreshTransientFailure` → rejects all queued, passes error through, but leaves the session intact (network blips must not log the user out).

Retries go through `TokenRefreshService.bareDio` (a separate `Dio` with no `AuthInterceptor`, avoiding recursion); `FormData` bodies are cloned before retry since `FormData` is single-use once finalized.

**`TokenRefreshService`** (`@singleton`): single-flight via `Future<RefreshResult>? _inFlight` (important since refresh tokens are rotating/single-use). `_doRefresh()` POSTs `/auth/refresh` with the refresh token as bearer, persists the new token pair, returns `RefreshResult.success`; 401 response → clears tokens, returns `rejected()`; anything else → `transientFailure()`.

**`RefreshResult`** — sealed `@freezed`: `success(AuthToken)`, `rejected()`, `transientFailure()` — the reject/transient distinction is load-bearing for the forced-logout decision.

**`NetworkInfo`** — stub, always returns `true`; not wired to real connectivity checking (comment notes `connectivity_plus` as the intended future replacement).

### 2.4 Database — `core/database/app_database.dart`

sqflite, `gym_session.db`, schema v1, two tables:
- `session_drafts` (PK `workout_profile_id`) — one row per in-progress session header.
- `task_completion_drafts` (PK `id`, FK → `session_drafts`) — one row per task's in-progress actuals.

This is the **local-first source of truth** for an active workout session (per `workout_session`, §12) — retains progress across app kill/relaunch and slow-network gym wifi without round-tripping every keystroke. Cleared only after a successful `completeSession`/`skipSession` server call.

### 2.5 Storage — `core/storage/`

**`SecureStorage`** (`@singleton`, wraps `FlutterSecureStorage`) — `access_token`, `refresh_token` only.
**`PreferencesStorage`** (`@singleton`, wraps `SharedPreferences`) — `is_onboarded` (bool), `active_role_id` (nullable int, last explicitly-selected role; falls back to JWT default if null). Theme preference (`theme_mode`) is stored separately by `ThemeManager` directly via raw `SharedPreferences`, not through this class.

### 2.6 Error handling — `core/error/`

**`Failure`** — sealed `@freezed`, exactly 4 variants: `server({statusCode, message})`, `network({message?})`, `unauthorized()`, `unknown({message?})`.
**`exceptions.dart`** — `ServerException`, `NetworkException`, `UnauthorizedException`, `CacheException`; in practice, datasources mostly let `DioException` propagate and repositories map it directly (e.g. `AuthRepositoryImpl._mapDioError`): connection error/timeout → `network()`; 401 → `unauthorized()`; other status → `server(statusCode, message)` (parsed from `response.data['message']`); no response → `unknown()`. This exact mapping shape is repeated per-feature in every repository impl.

### 2.7 Config — `core/config/app_config.dart`

`enum Flavor { dev, staging, prod }`, three static `AppConfig` instances:

| Flavor | `baseUrl` | `enableLogging` |
|---|---|---|
| dev | `http://192.168.0.11:3000/api/v1` | `true` |
| staging | `https://api.staging.kinetic.com/api/v1` | `true` |
| prod | `https://api.kinetic.com/api/v1` | `false` |

`enableLogging` gates whether `LoggerInterceptor` attaches to both `ApiClient`'s and `TokenRefreshService`'s Dio instances.

### 2.8 Live session service — `core/live_session/session_sync_service.dart`

`SessionSyncService` (`@singleton`) bridges the local session-draft store to a visible progress surface (Android ongoing notification today; iOS Live Activity noted as a native follow-up). Bootstrapped eagerly at DI-config time so it lives for the app's full lifetime. Subscribes to `AuthCubit.stream`; on role change, re-subscribes to `WorkoutSessionLocalDataSource.watchAllActiveDrafts()` — **the same stream the session cubits themselves write to**, deliberately, to avoid state drift — and renders either a member "workout in progress" notification or a trainer "N active clients" aggregate notification.

### 2.9 Theme — `lib/theme/`

`AppColors` — a "Slate & Sinew" neutral/monochrome Material 3 `ColorScheme` (light + dark), primary inverted black/white between modes. `AppTextTheme` (`google_fonts`) — **Manrope** for display/headline/title (weights 600–900, tight letter-spacing), **Inter** for body/label (label-small uses wide `letterSpacing: 2.0` for an eyebrow/tag look). `AppTheme` composes light/dark `ThemeData`, Material 3, **strict 0px border radius** and 0-elevation buttons app-wide (explicit "Strict 0px shape language" comment) — this sharp-edged convention also shows up directly in the shell nav bars.

### 2.10 App entry points

`bootstrap(AppConfig config)` — the real shared init: `WidgetsFlutterBinding.ensureInitialized()` → `configureDependencies(config)` → `runApp(App())`. `main_dev.dart`/`main_staging.dart`/`main_prod.dart` are one-liners calling `bootstrap(AppConfig.<flavor>)` — the actual flavor entry points used with `--flavor <x> -t lib/main_<x>.dart`. `main.dart` mirrors `main_dev.dart` and exists only so IDEs defaulting to `lib/main.dart` still work. `app.dart`'s `App` widget watches the global `themeManager`, resolves `AppRouter` from `getIt`, wraps `MultiBlocProvider` (`AuthCubit`, `ProfileCubit`) around `MaterialApp.router`. `globals.dart` declares `final themeManager = ThemeManager();` as the **one intentional exception** to DI-based access in this app, explicitly so any widget can reach it without going through `get_it`.

### 2.11 Key `pubspec.yaml` dependencies

State: `flutter_bloc ^9.1.1`, `bloc ^9.0.0`. Routing: `go_router ^15.1.2`. DI: `get_it ^8.0.3`, `injectable ^2.3.2`. Network: `dio ^5.8.0`, `pretty_dio_logger ^1.4.0`. Storage: `shared_preferences ^2.2.3`, `flutter_secure_storage ^9.2.4`. Local DB: `sqflite ^2.4.2`, `sqlite3_flutter_libs ^0.5.24` (chosen over Drift to avoid an `analyzer` conflict with `dart_mediatr`). Notifications: `flutter_local_notifications ^18.0.0`. Functional errors: `dartz ^0.10.1`. CQRS: `dart_mediatr ^1.0.5`. Codegen: `freezed_annotation ^2.4.1`, `json_annotation ^4.9.0`. Other: `flutter_svg`, `google_fonts`, `file_picker ^8.1.7`, `mobile_scanner 7.2.0`, `qr_flutter`, `jwt_decoder`, `uuid`.

---

## 3. Feature: `auth`

**Structure**:
```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart
│   ├── models/
│   │   ├── auth_token_model.dart (+.g.dart)
│   │   ├── otp_request_model.dart (+.g.dart)   # unused/dead
│   │   └── otp_verify_model.dart (+.g.dart)    # unused/dead
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── auth_token.dart (+.freezed.dart)
│   │   └── user_role.dart (+.freezed.dart, +.g.dart)
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── send_otp_command.dart
│       ├── send_otp_command_handler.dart
│       ├── verify_otp_command.dart
│       ├── verify_otp_command_handler.dart
│       ├── logout_command.dart
│       └── logout_command_handler.dart
└── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart
    │   └── auth_state.dart (+.freezed.dart)
    └── pages/
        ├── splash_page.dart
        ├── login_page.dart
        ├── otp_page.dart
        └── workspace_selection_page.dart
```

**Domain**: Entities — `AuthToken` (`{accessToken, refreshToken}`), `UserRole` (`{roleId, roleName, gymId?, isCurrent}` + `enum Role {member, staff, admin, owner}` + `roleEnum` mapping extension). Repository `AuthRepository` — `sendOtp`, `verifyOtp` → `AuthToken`, `logout`. Usecases — `SendOtpCommand`/`Handler`, `VerifyOtpCommand`/`Handler`, `LogoutCommand`/`Handler`.

**Data**: Models — `AuthTokenModel`; `OtpRequestModel`/`OtpVerifyModel` exist but are **unused/dead** (the datasource builds request maps inline instead). Datasource `AuthRemoteDataSourceImpl` — `sendOtp` → `POST /auth/request-otp`, `verifyOtp` → `POST /auth/verify-otp`, `logout` → `POST /auth/logout`. `AuthRepositoryImpl` — standard `DioException`→`Failure` mapping.

**Presentation**: `AuthCubit` (`@singleton`, DI-resolved everywhere via `getIt<AuthCubit>()`) — the single app-wide session-state cubit. States: `Initial`, `CheckingToken`, `Loading`, `OtpSent`, `Unauthenticated`, `Error`, `Authenticated(token, availableRoles, activeRole)`. Pages: `SplashPage`, `LoginPage`, `OtpPage`, `WorkspaceSelectionPage` — all wired only to `AuthCubit`.

**Cross-feature**: Foundational — imports nothing from other features; `AuthToken`/`UserRole` reused by `profile`, `staff`, router.

**DI**: All 3 handlers registered. ✅

---

## 4. Feature: `profile`

**Structure**:
```
lib/features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_remote_datasource.dart
│   ├── models/
│   │   └── trainer_connection_model.dart (+.g.dart)
│   └── repositories/
│       └── profile_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── profile.dart (+.freezed.dart, +.g.dart)
│   │   └── trainer_connection.dart (+.freezed.dart, +.g.dart)
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── trainer_signup_command.dart
│       ├── trainer_signup_command_handler.dart
│       └── connect_to_trainer_command.dart   # command + handler colocated
└── presentation/
    ├── cubit/
    │   ├── profile_cubit.dart                  # mock stub — see §12
    │   ├── profile_state.dart (+.freezed.dart)
    │   ├── trainer_connection_cubit.dart
    │   ├── trainer_connection_state.dart (+.freezed.dart)
    │   ├── trainer_signup_cubit.dart
    │   └── trainer_signup_state.dart (+.freezed.dart)
    └── pages/
        ├── profile_page.dart
        ├── trainer_signup_page.dart
        └── client_scanner_page.dart
```

**Domain**: Entities — `Profile` (`{id, phoneNumber, firstName?, lastName?, avatarUrl?}`), `TrainerConnection` (`{id, staffProfileId, clientProfileId, isActive, createdAt}`). Repository `ProfileRepository` — `trainerSignup(...)` → `auth`'s `AuthToken`, `connectToTrainer(qrToken)` → `TrainerConnection`. Usecases — `TrainerSignupCommand`/`Handler`, `ConnectToTrainerCommand`/`Handler`.

**Data**: Model `TrainerConnectionModel`; reuses `auth`'s `AuthTokenModel` directly for signup's response. Datasource — `trainerSignup` → `POST /users/trainer-signup` (multipart, certificates as `MultipartFile`), `connectToTrainer` → `POST /users/connect-trainer`. `ProfileRepositoryImpl` — standard mapping.

**Presentation**:

| Cubit | DI status |
|---|---|
| `ProfileCubit` | `@singleton`-annotated but **never resolved via `getIt`** — always constructed locally as `ProfileCubit()..loadProfile()`. `loadProfile()` is a **non-functional mock stub** (500ms delay, hardcoded `Profile`, no mediator call at all). |
| `TrainerConnectionCubit` | Not `@injectable` — local `TrainerConnectionCubit(getIt())` in `ClientScannerPage`. |
| `TrainerSignupCubit` | Not `@injectable` — local `TrainerSignupCubit(getIt())` in `TrainerSignupPage`. |

Pages: `ProfilePage` (member's own profile + "Connect to Trainer" + conditional "Become a Trainer"/"Switch to Trainer View"), `TrainerSignupPage`, `ClientScannerPage` (QR scan → `TrainerConnectionCubit`).

**Cross-feature**: Depends on `auth` (`AuthToken`, `AuthCubit`, `UserRole`/`Role`). Reused by `staff`: `StaffProfilePage` instantiates a **second independent** `ProfileCubit()` (same mock data, not shared state).

**DI**: Both handlers registered. ✅ (`ProfileCubit`'s mock behavior is orthogonal to Mediator wiring.)

---

## 5. Feature: `member`

**Structure**:
```
lib/features/member/
└── presentation/
    └── pages/
        ├── explore_page.dart      # routed (explore tab)
        ├── recovery_page.dart     # routed (recovery tab)
        └── profile_page.dart      # dead code — unrouted, see §12
```
No `domain/` or `data/` directory exists.

**No domain or data layer exists at all** — confirmed via directory listing, only `presentation/pages/` exists.

**Presentation**: No cubits. Three `StatelessWidget` pages, no mediator/cubit wiring:
- `ExplorePage` — static placeholder ("Find Nearby Gyms"), **routed** (`explore` tab).
- `RecoveryPage` — static placeholder ("Recovery Metrics"), **routed** (`recovery` tab).
- `ProfilePage` — static placeholder, **dead code**: never imported anywhere; the router's `profile` tab uses `profile` feature's `ProfilePage` instead.

**Cross-feature**: `member`'s "Train" tab is 100% backed by `workout_session` (`MemberWorkoutSessionCubit`, `@injectable`); its "Profile" tab is 100% backed by the `profile` feature. `member` itself functions purely as a route/page namespace for two static placeholders plus one orphaned page.

**DI**: N/A — no usecases exist to register.

---

## 6. Feature: `staff`

**Structure**:
```
lib/features/staff/
├── data/
│   ├── datasources/
│   │   └── staff_remote_datasource.dart
│   ├── models/
│   │   ├── client_profile_model.dart (+.g.dart)   # nests BodyMetricsModel
│   │   └── qr_token_model.dart (+.g.dart)
│   └── repositories/
│       └── staff_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── client_profile.dart (+.freezed.dart)
│   │   └── qr_token.dart (+.freezed.dart, +.g.dart)
│   ├── repositories/
│   │   └── staff_repository.dart
│   └── usecases/
│       ├── get_qr_token_query.dart
│       ├── list_staff_clients_query.dart
│       └── staff_create_profile_command.dart
└── presentation/
    ├── cubit/
    │   ├── add_client_cubit.dart
    │   ├── add_client_state.dart (+.freezed.dart)
    │   ├── staff_clients_cubit.dart
    │   ├── staff_clients_state.dart (+.freezed.dart)
    │   ├── staff_qr_cubit.dart
    │   └── staff_qr_state.dart (+.freezed.dart)
    └── pages/
        ├── staff_dashboard_page.dart   # fully static/mock, no cubit
        ├── staff_clients_page.dart
        ├── staff_profile_page.dart     # reuses profile's ProfileCubit
        ├── staff_qr_page.dart
        └── staff_add_client_page.dart
```

**Domain**: Entities — `ClientProfile` (flat entity: id, phoneNumber, fullName, isClaimed, isActive, plus optional body-metric fields), `QrToken` (`{qrToken, expiresAt}`). Repository `StaffRepository` — `getQrToken()`, `listStaffClients()`, `staffCreateProfile(...)`. Usecases — `GetQrTokenQuery`/`Handler`, `ListStaffClientsQuery`/`Handler`, `StaffCreateProfileCommand`/`Handler`.

**Data**: Models — `ClientProfileModel` (nests `List<BodyMetricsModel>`, `toDomain()` flattens the *first/latest* entry onto the flat entity), `BodyMetricsModel`, `QrTokenModel`. Datasource — `getQrToken` → `POST /users/staff/qr-token`, `listStaffClients` → `GET /users/staff/clients`, `staffCreateProfile` → `POST /users/manage/members`. `StaffRepositoryImpl` — standard mapping.

**Presentation**: All three cubits **not `@injectable`** — constructed locally as `XCubit(getIt())` (injecting just `Mediator`):
- `AddClientCubit` — sends `StaffCreateProfileCommand`.
- `StaffClientsCubit` — sends `ListStaffClientsQuery`.
- `StaffQrCubit` — sends `GetQrTokenQuery`.

Pages: `StaffDashboardPage` (fully static/mock stat cards, no cubit), `StaffClientsPage` (backed by `StaffClientsCubit`, links into `workout` feature routes), `StaffProfilePage` (reuses `profile`'s mock `ProfileCubit`), `StaffQrPage` (backed by `StaffQrCubit`), `StaffAddClientPage` (backed by `AddClientCubit`).

**Cross-feature**: Domain/data self-contained. Presentation reuses `auth` (`AuthCubit`, role switching/logout) and `profile` (`ProfileCubit`, mock data duplicated). `ClientProfile` consumed downstream by `workout` routes.

**DI**: All 3 handlers registered. ✅

---

## 7. Feature: `workout`

**Structure**:
```
lib/features/workout/
├── data/
│   ├── datasources/
│   │   └── workout_remote_datasource.dart
│   ├── models/
│   │   ├── workout_profile_model.dart (+.g.dart)
│   │   ├── weekly_plan_model.dart (+.g.dart)
│   │   ├── day_plan_model.dart (+.g.dart)
│   │   └── task_model.dart (+.g.dart)
│   └── repositories/
│       └── workout_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── workout_profile.dart (+.freezed.dart)
│   │   ├── weekly_plan.dart (+.freezed.dart)
│   │   ├── day_plan.dart (+.freezed.dart)
│   │   └── task.dart (+.freezed.dart)
│   ├── repositories/
│   │   └── workout_repository.dart          # also owns session-completion API — see §12
│   ├── usecases/
│   │   ├── manage_workout_profiles.dart     # 3 command/query + handler pairs
│   │   ├── manage_weekly_plans.dart         # 5 pairs
│   │   ├── manage_day_plans.dart            # 2 pairs
│   │   └── manage_tasks.dart                # 3 pairs
│   └── value_objects/
│       ├── draft_day_plan.dart
│       ├── draft_task.dart
│       └── draft_task_attachment.dart       # wraps a task_media TaskMedia
└── presentation/
    ├── cubit/
    │   ├── athlete_profile/
    │   │   ├── athlete_profile_cubit.dart
    │   │   └── athlete_profile_state.dart (+.freezed.dart)
    │   ├── day_plan_creator/
    │   │   ├── day_plan_creator_cubit.dart
    │   │   └── day_plan_creator_state.dart (+.freezed.dart)
    │   ├── initiate_program/
    │   │   ├── initiate_program_cubit.dart
    │   │   └── initiate_program_state.dart (+.freezed.dart)
    │   └── week_plan_creator/
    │       ├── week_plan_creator_cubit.dart
    │       └── week_plan_creator_state.dart (+.freezed.dart)
    └── pages/
        ├── athlete_profile_page.dart
        ├── day_plan_creator_page.dart
        ├── initiate_program_page.dart
        ├── week_plan_creator_page.dart      # large/monolithic, ~1100+ lines
        └── protocol_form_page.dart          # uses task_media's TaskMediaPickerCubit
```

**Domain**: Entities — `WorkoutProfile`, `WeeklyPlan` (`List<DayPlan>`), `DayPlan` (`List<Task>`), `Task` (`List<TaskAttachment>`, attachment entity actually owned by `task_media`). Value objects (plain, not freezed — client-side draft authoring before one-shot submission) — `DraftDayPlan`, `DraftTask` (`localId` via `uuid`), `DraftTaskAttachment` (wraps a picked `TaskMedia`, `toJson()` emits only `{taskMediaId, caption?, sequenceIndex}`). Repository `WorkoutRepository` (abstract interface class) — profile/plan/day-plan/task CRUD **plus** `completeSession`/`skipSession`/`getSessionLogs` (session-submission API deliberately lives here, not in `workout_session` — see §12). Usecases (13, all `@injectable`) across `manage_workout_profiles.dart`, `manage_weekly_plans.dart`, `manage_day_plans.dart`, `manage_tasks.dart` — full CRUD command/query set per entity.

**Data**: Models — `WorkoutProfileModel`, `WeeklyPlanModel` (`@JsonKey(name:'days')` → `dayPlans`), `DayPlanModel`, `TaskModel`. Datasource `WorkoutRemoteDataSourceImpl` — routes include `POST/GET /workout-profiles`, `PATCH /workout-profiles/:id`, `POST/GET /workout-profiles/:id/weekly-plans`, `GET /weekly-plans/:id`, `POST /weekly-plans/:id/activate`, `GET/PATCH /day-plans/:id`, `POST /day-plans/:id/tasks`, `PATCH/DELETE /tasks/:id`, `GET /workout-profiles/:id/today`, `POST /workout-profiles/:id/sessions/complete`, `POST /workout-profiles/:id/sessions/skip`, `GET /workout-profiles/:id/sessions`. `WorkoutRepositoryImpl` — standard mapping.

**Presentation**: All four cubits **not `@injectable`** — constructed locally, each taking only `Mediator`:

| Cubit | Page |
|---|---|
| `AthleteProfileCubit` | `AthleteProfilePage` |
| `DayPlanCreatorCubit` | `DayPlanCreatorPage` |
| `InitiateProgramCubit` | `InitiateProgramPage` |
| `WeekPlanCreatorCubit` | `WeekPlanCreatorPage` |

`ProtocolFormPage` has no cubit of its own — it uses `task_media`'s `TaskMediaPickerCubit` for its attachment picker. `week_plan_creator_page.dart` is a large monolithic file (~1100+ lines, many private widgets) — a candidate for future splitting, not a correctness issue.

**Cross-feature**: `workout` does not depend on `workout_session`'s entities, but `WorkoutRepository` imports `WorkoutSessionLog`/`TaskCompletionInput` from `workout_session/domain/entities` for its session endpoints — a **bidirectional coupling** between the two features (see §12).

**DI**: All 13 handlers registered. ✅

---

## 8. Feature: `workout_session`

**Structure**:
```
lib/features/workout_session/
├── data/
│   ├── datasources/
│   │   └── workout_session_local_datasource.dart   # local-only, sqflite-backed
│   └── models/
│       └── workout_session_log_model.dart (+.g.dart)   # includes TaskCompletionEntryModel
├── domain/
│   ├── entities/
│   │   ├── workout_session_log.dart (+.freezed.dart)   # + SessionStatus, LoggedByRole enums
│   │   ├── session_draft.dart (+.freezed.dart)
│   │   ├── task_completion_draft.dart (+.freezed.dart) # + TaskCompletionInput
│   │   └── task_completion_entry.dart (+.freezed.dart)
│   ├── usecases/
│   │   ├── get_today_plan_query.dart        # shared member/trainer
│   │   ├── member_session_commands.dart     # 4 pairs
│   │   └── trainer_session_commands.dart    # 5 pairs
│   └── week_progress_calculator.dart        # shared cycle-boundary algorithm — see §12
│                                             # (no domain/repositories/ folder — see §12)
└── presentation/
    ├── cubit/
    │   ├── member_workout_session/
    │   │   ├── member_workout_session_cubit.dart
    │   │   └── member_workout_session_state.dart (+.freezed.dart)
    │   ├── trainer_client_session/
    │   │   ├── trainer_client_session_cubit.dart
    │   │   └── trainer_client_session_state.dart (+.freezed.dart)
    │   └── trainer_live_clients/
    │       ├── trainer_live_clients_cubit.dart
    │       └── trainer_live_clients_state.dart (+.freezed.dart)
    └── pages/
        ├── weekly_plan_page.dart
        ├── task_execution_page.dart
        ├── day_preview_page.dart              # read-only, no cubit
        ├── trainer_client_session_page.dart
        └── trainer_live_clients_page.dart
```

**Domain**: Entities — `WorkoutSessionLog` (server-confirmed record: status/dayIndex/cycleNumber/logged-by/`List<TaskCompletionEntry>`) with inline `enum SessionStatus {completed, skipped, inProgress, partial}` and `enum LoggedByRole {member, trainer}`; `SessionDraft` (local in-progress state); `TaskCompletionDraft` (+ plain `TaskCompletionInput` wire-shape); `TaskCompletionEntry` (server-confirmed read-only counterpart). **No `domain/repositories/` folder** — usecases call `workout`'s `WorkoutRepository` directly for remote calls, and inject the concrete `WorkoutSessionLocalDataSource` (a data-layer class) directly for the one local-only handler — a deliberate but rule-bending shortcut, see §12.

Usecases (9, all `@injectable`): `GetTodayPlanQuery`/`Handler` (shared member/trainer logic); Member — `GetMemberActiveProfileQuery`, `CompleteMemberWorkoutSessionCommand`, `SkipMemberWorkoutSessionCommand`, `GetMemberWorkoutSessionLogsQuery`; Trainer — `GetClientWorkoutProfileQuery`, `CompleteClientWorkoutSessionCommand`, `SkipClientWorkoutSessionCommand`, `GetClientWorkoutSessionLogsQuery`, `GetTrainerActiveClientDraftsQuery` (the local-only one, returns `Stream<List<SessionDraft>>`).

**Data**: Model `WorkoutSessionLogModel`/`TaskCompletionEntryModel` only — no remote datasource (session-log network calls are served by `workout`'s datasource/repository) and no repository impl. **Local datasource** `WorkoutSessionLocalDataSource` (`@singleton`, sqflite-backed via `AppDatabase`) — `startOrResumeDraft`, `upsertTaskCompletion`, `watchDraft(id)` / `watchAllActiveDrafts()` (poll-on-write via a broadcast `StreamController`, since sqflite has no native change notification), `clearDraft`.

**Presentation**:

| Cubit | DI status |
|---|---|
| `MemberWorkoutSessionCubit` | **`@injectable`** — resolved via `GetIt.I<X>()` in the router (member shell). |
| `TrainerClientSessionCubit` | **`@injectable`** — resolved via `GetIt.I<X>()` in the router (`clientSessionUpdate` root route). |
| `TrainerLiveClientsCubit` | **`@injectable`** — resolved via `GetIt.I<X>()` in the router (staff shell). |

This is the **opposite** DI pattern from `workout`'s cubits — all three here are DI-registered and provided at the route level; pages just `context.read<XCubit>()`.

Pages: `WeeklyPlanPage` (member "Train" tab), `TaskExecutionPage` (per-task set/rep/weight entry), `DayPreviewPage` (read-only, no cubit — pure `StatelessWidget` driven by `DayPreviewArgs` route `extra:`), `TrainerClientSessionPage` (trainer live-logging), `TrainerLiveClientsPage` (trainer roster, merges `staff`'s `ListStaffClientsQuery` with `watchAllActiveDrafts()`).

**Cross-feature**: Imports `workout`'s `DayPlan`, `Task`, `WeeklyPlan`, `WorkoutProfile` entities extensively, and calls `workout`'s `WorkoutRepository` directly from most usecases.

**DI**: All 9 handlers registered. ✅

**Notable — `week_progress_calculator.dart`** (`computeWeekProgress`): reconstructs, client-side, which days of the still-in-progress 7-day cycle are logged and which day is active next, by walking the server-ordered (`completedDate` desc) log history backward and stopping at a `completed && dayIndexAtTime == 7` boundary (exclusive). Deliberately **does not** group by `cycleNumberAtTime` — that field is shared between the day that wraps a cycle and the next cycle's early days, making it unreliable for splitting cycles. Only completions advance the active day; skips leave it unchanged — mirroring the server's own state machine. Used identically by both member and trainer cubits; a subtly-wrong reimplementation would silently desync the client's day-strip from the server cursor.

---

## 9. Feature: `task_media`

*(Fully implemented — this was the feature planned in an earlier session, believed paused pending a Stitch MCP design connection. It's done; whether it visually matches an eventual Stitch design should be checked separately.)*

**Structure**:
```
lib/features/task_media/
├── data/
│   ├── datasources/
│   │   └── task_media_remote_datasource.dart
│   ├── models/
│   │   ├── task_media_model.dart (+.g.dart)
│   │   └── task_attachment_model.dart (+.g.dart)
│   └── repositories/
│       └── task_media_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── task_media.dart (+.freezed.dart)
│   │   └── task_attachment.dart (+.freezed.dart)
│   ├── repositories/
│   │   └── task_media_repository.dart
│   └── usecases/
│       └── manage_task_media.dart   # 2 pairs: Search query, Create command
└── presentation/
    ├── cubit/
    │   ├── task_media_picker_cubit.dart
    │   ├── task_media_picker_state.dart (+.freezed.dart)
    │   ├── add_task_media_cubit.dart
    │   └── add_task_media_state.dart (+.freezed.dart)
    ├── pages/
    │   └── add_task_media_page.dart
    └── widgets/
        └── task_media_picker_sheet.dart
```

**Domain**: Entities — `TaskMedia`, `TaskAttachment` (freezed). Repository `TaskMediaRepository`. Usecases — `manage_task_media.dart` containing `SearchTaskMediaQuery`/`Handler` and `CreateTaskMediaCommand`/`Handler` (both `@injectable`).

**Data**: Models — `TaskMediaModel`, `TaskAttachmentModel` (`@JsonSerializable` + generated `.g.dart`). Datasource `TaskMediaRemoteDataSource`. `TaskMediaRepositoryImpl`.

**Presentation**: Two cubits — `TaskMediaPickerCubit` (+ `TaskMediaPickerState`) backing `TaskMediaPickerSheet` (a bottom-sheet widget, used from `workout`'s `ProtocolFormPage`), and `AddTaskMediaCubit` (+ `AddTaskMediaState`) backing `AddTaskMediaPage` (full-screen upload flow: pick file, name/description/keywords/private toggle).

**Cross-feature**: Consumed by `workout` (`Task.attachments`, `DraftTaskAttachment`, `ProtocolFormPage`'s picker).

**DI**: Both handlers registered. ✅

---

## 10. Feature-to-route map (quick reference)

| Route (shell) | Page | Backing cubit | Feature |
|---|---|---|---|
| `explore` (member) | `ExplorePage` | none (static) | `member` |
| `train` (member) | `WeeklyPlanPage` | `MemberWorkoutSessionCubit` | `workout_session` |
| `recovery` (member) | `RecoveryPage` | none (static) | `member` |
| `profile` (member) | `ProfilePage` | `ProfileCubit` (mock) | `profile` |
| `staffDashboard` (staff) | `StaffDashboardPage` | none (static/mock) | `staff` |
| `staffClients` (staff) | `StaffClientsPage` | `StaffClientsCubit` | `staff` |
| `staffProfile` (staff) | `StaffProfilePage` | `ProfileCubit` (mock) | `staff`/`profile` |
| `staffLiveSessions` (staff) | `TrainerLiveClientsPage` | `TrainerLiveClientsCubit` | `workout_session` |
| `clientSessionUpdate` (root) | `TrainerClientSessionPage` | `TrainerClientSessionCubit` | `workout_session` |
| `weekPlanCreator`/`dayPlanCreator` (root) | `WeekPlanCreatorPage`/`DayPlanCreatorPage` | local cubits | `workout` |

## 11. Cubit DI-pattern reference (per the app's actual, mixed convention)

Every cubit in the app falls into exactly one of two buckets. This section exists to make that split auditable — see §11.3 for cubits worth re-examining.

### 11.1 Quick lists

**In DI** (`@injectable`/`@singleton`, resolved via `getIt<X>()`/`GetIt.I<X>()`) — 4 cubits:
- `AuthCubit` (`auth`)
- `MemberWorkoutSessionCubit` (`workout_session`)
- `TrainerClientSessionCubit` (`workout_session`)
- `TrainerLiveClientsCubit` (`workout_session`)

**Not in DI** (constructed locally per-page as `XCubit(getIt<Mediator>())` or `XCubit()`, handed to an inline `BlocProvider`) — 13 cubits:
- `AthleteProfileCubit`, `DayPlanCreatorCubit`, `InitiateProgramCubit`, `WeekPlanCreatorCubit` (`workout`)
- `AddClientCubit`, `StaffClientsCubit`, `StaffQrCubit` (`staff`)
- `TrainerConnectionCubit`, `TrainerSignupCubit`, `ProfileCubit` (`profile`)
- `TaskMediaPickerCubit`, `AddTaskMediaCubit` (`task_media`)

### 11.2 Detailed table

| Cubit | Feature | DI status | Constructor deps | Resolved/constructed at |
|---|---|---|---|---|
| `AuthCubit` | `auth` | ✅ `@singleton` | `Mediator, SecureStorage, PreferencesStorage, TokenRefreshService` | `getIt<AuthCubit>()` — reused across `App`'s `MultiBlocProvider`, `RouterGuard`/`GoRouterAuthNotifier`, `AuthInterceptor.forceLogout()`, `SessionSyncService`, every auth/profile/staff page |
| `MemberWorkoutSessionCubit` | `workout_session` | ✅ `@injectable` | `Mediator, WorkoutSessionLocalDataSource` | `GetIt.I<X>()` in `app_router.dart` — member shell (`train`, `taskExecution` routes) |
| `TrainerClientSessionCubit` | `workout_session` | ✅ `@injectable` | `Mediator, WorkoutSessionLocalDataSource` | `GetIt.I<X>()` in `app_router.dart` — root `clientSessionUpdate` route |
| `TrainerLiveClientsCubit` | `workout_session` | ✅ `@injectable` | `Mediator, WorkoutSessionLocalDataSource` (assumed, matches siblings) | `GetIt.I<X>()` in `app_router.dart` — staff shell (`staffLiveSessions` route) |
| `ProfileCubit` | `profile` | ⚠️ `@singleton`-annotated **but never resolved via `getIt`** | none (mock — `loadProfile()` never calls the mediator) | `ProfileCubit()..loadProfile()`, hand-constructed independently in both `profile/presentation/pages/profile_page.dart` and `staff/presentation/pages/staff_profile_page.dart` |
| `AthleteProfileCubit` | `workout` | ❌ not `@injectable` | `Mediator` | `AthleteProfileCubit(getIt())` in `athlete_profile_page.dart` |
| `DayPlanCreatorCubit` | `workout` | ❌ not `@injectable` | `Mediator` | `DayPlanCreatorCubit(getIt())` in `day_plan_creator_page.dart` |
| `InitiateProgramCubit` | `workout` | ❌ not `@injectable` | `Mediator` | `InitiateProgramCubit(getIt())` in `initiate_program_page.dart` |
| `WeekPlanCreatorCubit` | `workout` | ❌ not `@injectable` | `Mediator` | `WeekPlanCreatorCubit(getIt<Mediator>())` in `week_plan_creator_page.dart` |
| `AddClientCubit` | `staff` | ❌ not `@injectable` | `Mediator` | `AddClientCubit(getIt())` in `staff_add_client_page.dart` |
| `StaffClientsCubit` | `staff` | ❌ not `@injectable` | `Mediator` | `StaffClientsCubit(getIt())` in `staff_clients_page.dart` |
| `StaffQrCubit` | `staff` | ❌ not `@injectable` | `Mediator` | `StaffQrCubit(getIt())` in `staff_qr_page.dart` |
| `TrainerConnectionCubit` | `profile` | ❌ not `@injectable` | `Mediator` | `TrainerConnectionCubit(getIt())` in `client_scanner_page.dart` |
| `TrainerSignupCubit` | `profile` | ❌ not `@injectable` | `Mediator` | `TrainerSignupCubit(getIt())` in `trainer_signup_page.dart` |
| `TaskMediaPickerCubit` | `task_media` | ❌ not `@injectable` | `Mediator` | constructed inline where `TaskMediaPickerSheet` is opened (from `workout`'s `ProtocolFormPage`) |
| `AddTaskMediaCubit` | `task_media` | ❌ not `@injectable` | `Mediator` | constructed inline in `AddTaskMediaPage` |

There is no rule of thumb that predicts which pattern a given cubit uses beyond "check it individually" — both are established, coexisting conventions in this codebase. The one real pattern that *does* hold: every "not in DI" cubit takes only `Mediator` as a dependency and is scoped to exactly one page; every "in DI" cubit either needs a second dependency beyond `Mediator` (`SecureStorage`/`PreferencesStorage`/`TokenRefreshService`/`WorkoutSessionLocalDataSource`) or is genuinely referenced from outside its own page (`AuthCubit`).

### 11.3 Candidates worth reviewing

- **`MemberWorkoutSessionCubit`, `TrainerClientSessionCubit`, `TrainerLiveClientsCubit`** — all three are resolved via `GetIt.I<X>()` at exactly one route builder each and nothing else in the app holds a reference to them (unlike `AuthCubit`, which is genuinely needed as a singleton because `AuthInterceptor`, `SessionSyncService`, and `RouterGuard` all need the *same* instance/stream outside of any page). Each of these three also only takes `Mediator` + `WorkoutSessionLocalDataSource` — both already resolvable via `getIt` from inside a page. Worth asking: would `BlocProvider(create: (_) => XCubit(getIt(), getIt()))` at the route builder work identically to today, matching the "not in DI" convention used by every sibling cubit in `workout`/`staff`/`profile`/`task_media`? If nothing outside the route builder ever needs to reach these instances, DI registration may be unnecessary ceremony here.
- **`ProfileCubit`** — the `@singleton` annotation is dead weight: it's never once resolved via `getIt` anywhere in the codebase, so the generated DI registration for it is unused. Either it should actually be wired through `getIt<ProfileCubit>()` at its call sites (and its mock `loadProfile()` implementation replaced with a real mediator call), or the `@singleton` annotation should be removed to stop generating an unused registration. Right now it's in an inconsistent middle state — annotated for DI but used as if it weren't.

## 12. Notable architectural findings

- **`member` has no domain/data layer.** Two of its three pages are routed static placeholders; the third (`ProfilePage`) is dead code, superseded in the router by `profile`'s `ProfilePage`.
- **`ProfileCubit` is a non-functional mock.** `@singleton`-annotated but never resolved via `getIt`; `loadProfile()` never calls the mediator — it just delays 500ms and emits a hardcoded `Profile`. Both `profile` and `staff` instantiate independent copies of it.
- **`workout` ↔ `workout_session` bidirectional coupling.** `workout_session` has no repository of its own — it calls `workout`'s `WorkoutRepository` directly for all remote session operations and imports `workout`'s domain entities extensively. In the other direction, `WorkoutRepository` (owned by `workout`) imports `WorkoutSessionLog`/`TaskCompletionInput` from `workout_session`'s domain to expose `completeSession`/`skipSession`/`getSessionLogs`. This is a deliberate "one repository, no duplicated network code" choice, not an oversight — but it does mean `workout_session`'s domain layer breaks the "no data-layer dependency" rule once, injecting the concrete `WorkoutSessionLocalDataSource` directly into `GetTrainerActiveClientDraftsQueryHandler` (justified as the local-only, no-network exception).
- **`task_media` is fully implemented**, including its presentation layer (bottom sheet + upload page) — this was previously believed blocked/paused pending a Stitch MCP connection for the UI design step; it exists in the codebase now regardless.
- **The 7-day cycle-progress algorithm** (`week_progress_calculator.dart`, §8) is the single trickiest piece of business logic in the app and is shared verbatim between the member and trainer session cubits — worth extra care on any future change.
- **Sharp, zero-radius design language** is enforced globally via `AppTheme` (buttons) and repeated by convention in shell nav bars — a consistent, intentional visual identity, not per-page inconsistency.
