# Exercise Config picker — Flutter implementation plan

Adds a single-select "Watch Me" exercise-config picker to the protocol/task form, mirroring the existing `task_media` feature almost file-for-file. Backend already ships (`server/src/exercise-config/`, see `server/docs/exercise-config-api-plan.md`). This plan is Flutter-only.

## API this consumes

Only the **trainer-facing search** endpoint — nothing else is needed client-side, since config *creation* is admin-only (no "add new" sub-flow, unlike `task_media`'s Add Media screen):

```
GET /api/v1/exercise-configs?search=<text>&analyzerType=<enum>&page=<n>&pageSize=<n>
Authorization: Bearer <token>
```
Response (`ExerciseConfigSummaryDto[]` — no `aiConfigJson`, that's only fetched later by the not-yet-built camera/analysis flow via `GET /exercise-configs/:id`):
```jsonc
{
  "success": true,
  "data": [
    {
      "id": "clx...",
      "name": "Barbell Squat",
      "description": "Standard barbell back squat",
      "analyzerType": "DYNAMIC_REP",   // DYNAMIC_REP | STATIC_HOLD | COMPOUND_MOVEMENT | CARDIO_MOVEMENT
      "keywords": ["squat", "legs", "barbell"],
      "mediaUrl": "https://.../squat.mp4"
    }
  ],
  "meta": { "total": 42, "page": 1, "pageSize": 20 }
}
```
And the task-attachment side (already shipped on the backend, nothing new to call — just a field to send/read): `TaskInputDto`/`UpdateTaskDto` accept `exerciseConfigId?: string`, `TaskResponseDto` returns `exerciseConfig: ExerciseConfigSummaryDto | null`.

## Key design decision: single-select needs a different pop-result shape than `task_media`

`TaskMediaPickerSheet` pops `List<TaskMedia>?` — `null` unambiguously means "dismissed, no change" and `[]` means "explicitly cleared to zero." A single nullable value can't make that distinction the same way (`null` would mean both "dismissed" and "explicitly cleared"). Fix: the sheet always pops a small wrapper on explicit confirm, and only a genuine dismiss (backdrop/back gesture) yields a bare `null`:
```dart
class ExerciseConfigSelection {
  final ExerciseConfig? config; // null = user explicitly cleared
  const ExerciseConfigSelection(this.config);
}
```
`showModalBottomSheet<ExerciseConfigSelection>(...)` — a raw `null` result (dismiss) leaves `ProtocolFormPage`'s state untouched; any `ExerciseConfigSelection` result (including one wrapping `null`) replaces the current selection.

## New feature: `gym/lib/features/exercise_config/`

Mirrors `task_media`'s layout exactly.

```
lib/features/exercise_config/
├── domain/
│   ├── entities/
│   │   └── exercise_config.dart          # @freezed: id, name, description?, analyzerType, keywords, mediaUrl
│   ├── repositories/
│   │   └── exercise_config_repository.dart
│   └── usecases/
│       └── manage_exercise_config.dart   # SearchExerciseConfigQuery + Handler (only)
├── data/
│   ├── models/
│   │   └── exercise_config_model.dart    # @JsonSerializable, toDomain()
│   ├── datasources/
│   │   └── exercise_config_remote_datasource.dart   # GET /exercise-configs
│   └── repositories/
│       └── exercise_config_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── exercise_config_picker_cubit.dart    # NOT @injectable — local getIt<Mediator>()
    │   └── exercise_config_picker_state.dart
    └── widgets/
        └── exercise_config_picker_sheet.dart
```

**`ExerciseConfig` entity** — `analyzerType` kept as the raw `String` from the wire (`"DYNAMIC_REP"` etc.), exactly like `TaskMedia.type` today (no Dart enum layer in this feature yet — matches the existing convention rather than introducing a new one).

**`SearchExerciseConfigQuery`/`Handler`** — identical shape to `SearchTaskMediaQuery`/`Handler`, `@injectable` on the handler, delegates to `ExerciseConfigRepository.search(search:, analyzerType:, page:, pageSize:)`. **Registered in `gym/lib/core/di/injection.dart`**: `mediator.registerCommandHandler(getIt<SearchExerciseConfigQueryHandler>());` under a new "Exercise Config" heading — required or the Mediator won't dispatch it, per this repo's standing rule (DI resolution alone is insufficient).

**`ExerciseConfigRemoteDataSourceImpl`** — one method, `search(...)`, same `_apiClient.get('/exercise-configs', queryParameters: {...})` + `data['data']`/`meta` unpacking as `TaskMediaRemoteDataSourceImpl.search`.

**`ExerciseConfigPickerCubit`** — constructed locally (`ExerciseConfigPickerCubit(getIt<Mediator>(), preselected: existing)`), not DI-registered, matching `TaskMediaPickerCubit`. Key differences from it:
- State holds `ExerciseConfig? selected` (not a `Map<String, T>`).
- `selectSingle(config)` replaces the selection outright (no toggle-into-set); tapping the already-selected row calls `clearSelection()`.
- No `mineOnly`/`toggleMineOnly()` — configs have no ownership/privacy concept, always admin-curated and visible to all trainers.
- No `addLocallyCreated()` — nothing creates configs from this app.
- `search()`/`loadMore()`/debounce logic otherwise identical to `TaskMediaPickerCubit`.

**`ExerciseConfigPickerSheet`** — same chrome as `TaskMediaPickerSheet` (grab handle, header, search field, paginated list, bottom action bar), with these deltas:
- Header: **"SELECT AI CONFIGURATION"**, no "ADD MEDIA" button (nothing to add from here).
- No "MY ASSETS ONLY" checkbox row.
- Row widget (`_ConfigRow`, analogous to `_MediaRow`): radio-style selection indicator instead of a checkbox (visually communicates single-select), thumbnail always shows the video-camera icon fallback (`Icons.videocam_outlined`) — configs are always video/gif, same `Image.network`-with-`errorBuilder` fallback pattern isn't needed since there's no still-image case; a badge shows `analyzerType` (small, muted) instead of `TaskMediaType`/`PRIVATE`.
- Bottom bar: **"SELECT"** (always enabled — confirming "no config" is valid) instead of "ATTACH (n)"; pops `Navigator.pop(context, ExerciseConfigSelection(state.selected))`.

## `workout` feature changes (extend, don't duplicate)

- **`domain/entities/task.dart`** — add `ExerciseConfig? exerciseConfig` field (nullable, singular — no join-list wrapper needed, unlike `attachments`/`DraftTaskAttachment`, since backend already models this as a plain FK).
- **`data/models/task_model.dart`** — parse the nested `exerciseConfig` object (nullable) via `ExerciseConfigModel.fromJson`/`toDomain()`, add to `TaskModel.toDomain()`.
- **`domain/value_objects/draft_task.dart`** — add `ExerciseConfig? exerciseConfig` field + `copyWith` param. `toJson()` gains `if (exerciseConfig != null) 'exerciseConfigId': exerciseConfig!.id`. No new `DraftTaskAttachment`-style wrapper class needed — store the entity directly (used for both UI display and id serialization), simpler than the media case precisely because this is single/direct rather than a many-to-many join.
- **`presentation/pages/protocol_form_page.dart`**:
  - `_selectedExerciseConfig` local field (nullable `ExerciseConfig`), initialized from `widget.existingTask?.exerciseConfig` in `initState`.
  - New `_openExerciseConfigPicker()` — same shape as `_openMediaPicker()`:
    ```dart
    final result = await showModalBottomSheet<ExerciseConfigSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => ExerciseConfigPickerCubit(
          getIt<Mediator>(),
          preselected: _selectedExerciseConfig,
        )..search(),
        child: const ExerciseConfigPickerSheet(),
      ),
    );
    if (result == null || !mounted) return; // dismissed — no change
    setState(() => _selectedExerciseConfig = result.config);
    ```
  - New **"AI CONFIGURATION"** section in the form body, placed directly below "ATTACH MEDIA" (same `_SectionLabel` + tap-target pattern): shows the selected config's name + a small "CHANGE"/"SELECT" affordance when none chosen, or a compact card (thumbnail placeholder + name + analyzer-type badge + a clear "×") when one is selected — visually parallel to the existing attachment cards, singular instead of a list.
  - `_submit()` passes `exerciseConfig: _selectedExerciseConfig` into the constructed `DraftTask`.

## Scope intentionally matched to `task_media`'s current state (not expanded)

Two things are **not** part of this plan, because the equivalent doesn't exist for `task_media` today either — adding them here first would be scope creep beyond "just like task media":
1. **`day_plan_creator_page.dart`'s `AlertDialog` single-task edit flow** (the other task-creation surface, used for editing tasks in an already-created plan) has no media picker today and won't get an exercise-config picker either. Both stay `ProtocolFormPage`-only for now.
2. **No admin-side "create config" UI** in this app — matches your confirmation that config authoring is admin-only and out of this app's scope.

## Files to touch

New: all 9 files listed under `lib/features/exercise_config/` above.
Modified: `gym/lib/core/di/injection.dart` (register the one new handler), `gym/lib/features/workout/domain/entities/task.dart`, `gym/lib/features/workout/data/models/task_model.dart`, `gym/lib/features/workout/domain/value_objects/draft_task.dart`, `gym/lib/features/workout/presentation/pages/protocol_form_page.dart`.

## Verification

1. `dart run build_runner build --delete-conflicting-outputs` (new `@freezed` entity/state + `@JsonSerializable` model + regenerated `injection.config.dart`).
2. `flutter analyze` — clean.
3. Manual: open Week Plan Creator → add/edit a protocol → "AI CONFIGURATION" section → search, select one, confirm it shows on the form → change selection → clear it → save the protocol → confirm the full weekly-plan submission (`CreateFullWeeklyPlanCommand`) carries `exerciseConfigId` on the task (check via `flutter run` request logs) → reload the plan and confirm the selected config round-trips back from `GET`.
