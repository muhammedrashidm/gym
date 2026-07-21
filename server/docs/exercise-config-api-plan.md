# Exercise Config API — Plan

Design for a new, admin-curated **Exercise Config** catalog: each row bundles the JSON payload an on-device pose analyzer needs, one video/gif demonstrating the movement, and search keywords. A trainer attaches **at most one** config to a `Task` (unlike `TaskMedia`, where many can be attached) — picked from a single-select bottom sheet, same interaction shape as the existing `TaskMediaPickerSheet` but returning one item instead of a list.

This is a plan only — no code yet. Mirrors the conventions already shipped for `task_media` (`server/src/workout/services/task-media.service.ts`, `server/src/workout/controllers/task-media.controller.ts`) wherever they apply, since that's the closest existing precedent: an admin/trainer-curated, searchable, reusable library item wrapping one `Media` row.

## Schema

### New model: `ExerciseConfig`

```prisma
enum AnalyzerType {
  DYNAMIC_REP         // e.g. squat, curl — rep counted via angle threshold crossings
  STATIC_HOLD         // e.g. plank — timed hold, no rep count
  COMPOUND_MOVEMENT    // e.g. burpee — multi-phase movement
  CARDIO_MOVEMENT      // e.g. jumping jacks — cadence-based
}

model ExerciseConfig {
  id           String       @id @default(cuid())

  name         String
  description  String?
  analyzerType AnalyzerType
  keywords     String[]     // lowercased/trimmed at write time, same convention as TaskMedia.keywords

  mediaId      String       @unique
  media        Media        @relation(fields: [mediaId], references: [id])   // the video/gif

  aiConfigJson Json         // landmarks/angles/thresholds/state-machine/feedback-rules payload
                             // — structure intentionally not fixed here; validated at the
                             // service layer per analyzerType, not by a rigid Prisma shape,
                             // so new exercises never need a migration.

  isActive     Boolean      @default(true)   // soft "retire" flag — false hides it from search
  createdById  String
  createdAt    DateTime     @default(now())
  updatedAt    DateTime     @updatedAt

  tasks        Task[]

  @@map("exercise_configs")
}
```

### `Task` gets one new nullable column

```prisma
model Task {
  // ...existing fields unchanged...
  exerciseConfigId String?
  exerciseConfig    ExerciseConfig? @relation(fields: [exerciseConfigId], references: [id], onDelete: SetNull)
}
```

`onDelete: SetNull` — deleting/retiring a config never breaks a task that already referenced it; the reference just clears. (An `isActive = false` soft-retire is the expected day-to-day path — see the admin DELETE endpoint below — hard delete is the exception.)

### Media visibility

Config media uses the **`PUBLIC`** storage profile (`MediaVisibility.PUBLIC`), not `PROTECTED` (which `TaskMedia` uses). Reasoning: these are admin-curated, non-private assets that need stable, cacheable URLs — a signed URL that can expire mid-cache is the wrong shape for something a client wants to download once and reuse offline during a workout. Zero new infra: this is exactly the `PUBLIC_STORAGE_SERVICE` token already built and wired in `server/src/media/storage/`.

### Migration

Purely additive: one new table, one nullable FK column, one new enum. No existing data touched — same low-risk shape as the `task_media` migration earlier this session. `npx prisma migrate dev` generates and applies cleanly against the current schema.

## Module structure

A new, standalone **`server/src/exercise-config/`** module — not folded into `WorkoutModule`. Admin-only authoring is a distinct concern from trainer-authored plan content, and keeping it separate means its role-gating (`ADMIN`/`OWNER` only) can't accidentally leak the looser `TRAINER_ROLES` pattern used everywhere else in `workout/`.

```
server/src/exercise-config/
├── controllers/
│   └── exercise-config.controller.ts   # all 5 endpoints below
├── services/
│   └── exercise-config.service.ts      # create/update/remove/search/findOne, @Inject(PUBLIC_STORAGE_SERVICE)
├── dto/
│   └── exercise-config.dto.ts          # CreateExerciseConfigDto, UpdateExerciseConfigDto,
│                                        # SearchExerciseConfigQueryDto, ExerciseConfigResponseDto,
│                                        # ExerciseConfigSummaryDto
└── exercise-config.module.ts           # imports [PrismaModule, AuthModule]; exports ExerciseConfigService
                                         # (exported so WorkoutModule's TaskService can inject it for the
                                         #  exerciseConfigId validation described below)
```

Registered in `AppModule` alongside `WorkoutModule`, `MediaModule`, etc. `WorkoutModule` gets `ExerciseConfigModule` added to its `imports` so `TaskService`/`WeeklyPlanService` can inject `ExerciseConfigService` for the existence/`isActive` check on `exerciseConfigId` (mirrors how those services already depend on `TaskMediaService` for the equivalent `assertUsable` check on attachments).

## API — Admin (create/manage configs)

Gated `@Roles(SYSTEM_ROLES.ADMIN, SYSTEM_ROLES.OWNER)` only — matches "creating a config is an admin-side task." Distinct from every other `@Roles(...)` list in `workout/`, which includes `TRAINER`/`STAFF`/`MANAGER` — configs are deliberately not trainer-authorable.

### 1. Create a config

```
POST /api/v1/exercise-configs
Content-Type: multipart/form-data
```

| field | type | required | notes |
|---|---|---|---|
| `file` | file | yes | video or gif |
| `name` | string | yes | |
| `description` | string | no | |
| `analyzerType` | enum | yes | `DYNAMIC_REP` \| `STATIC_HOLD` \| `COMPOUND_MOVEMENT` \| `CARDIO_MOVEMENT` |
| `keywords` | string | no | comma-separated or repeated field, same parsing as `task-media` |
| `aiConfigJson` | string (JSON) | yes | stringified JSON body; parsed + stored as-is |

Same upload shape as `TaskMediaController.create` — `FileInterceptor('file', { storage: memoryStorage(), limits: { fileSize: 25MB } })`, upload via `PUBLIC_STORAGE_SERVICE.upload(...)` first, then a `prisma.$transaction` creating `Media` (`visibility: PUBLIC`) then `ExerciseConfig`.

**Response** `201`: `{ "success": true, "data": ExerciseConfigResponseDto }` (full shape, including `aiConfigJson`, since the creator needs to confirm what was saved).

### 2. Update a config's metadata

```
PATCH /api/v1/exercise-configs/:id
Content-Type: application/json
```
Body (all optional): `name`, `description`, `analyzerType`, `keywords`, `aiConfigJson`, `isActive`. Does **not** accept a new file — swapping the video/gif means creating a new config (keeps this endpoint simple; revisit only if retuning-without-replacing-media turns out to be a common admin workflow).

**Response** `200`: `{ "success": true, "data": ExerciseConfigResponseDto }`.

### 3. Retire / delete a config

```
DELETE /api/v1/exercise-configs/:id
```
Hard-deletes the `ExerciseConfig` row **only** — its `Media` row is deliberately left in place, not cascaded (this is a departure from `TaskMediaService.remove`, which does delete the underlying `Media`). Reasoning: config media is `PUBLIC` and may be reused/relinked by a future config, or kept around for audit/reference even after the config entry itself is gone; there's no privacy pressure to scrub it the way there might be for user-uploaded protected media. The orphaned `Media` row is harmless — it's just an unreferenced storage object — and can be swept by a separate cleanup job later if needed, not by this endpoint. Any `Task.exerciseConfigId` pointing at the deleted config is set to `null` via `onDelete: SetNull`.

For the common case ("stop surfacing this in search, but don't break history"), prefer `PATCH { isActive: false }` instead — document this distinction in the endpoint description so admins default to soft-retire and treat hard delete as the rare exception.

**Response** `200`: `{ "success": true }`.

## API — Trainer-facing (distribution / selection)

Gated the same `TRAINER_ROLES` set used everywhere else in `workout/` (`TRAINER, STAFF, MANAGER, OWNER, ADMIN`) — read-only.

### 4. Search / browse configs

```
GET /api/v1/exercise-configs?search=<text>&analyzerType=<enum>&page=<n>&pageSize=<n>
```

| param | notes |
|---|---|
| `search` | matches `name`/`description` (contains, insensitive) OR `keywords` (token `hasSome`) — identical pattern to `task-media`'s search |
| `analyzerType` | optional exact filter |
| `page`/`pageSize` | shared `PaginationQueryDto` |

Always filters `isActive: true` — retired configs never appear here (admin endpoints above are the only way to see inactive ones).

**Response** `200`:
```jsonc
{
  "success": true,
  "data": [
    {
      "id": "clx...",
      "name": "Barbell Squat",
      "description": "Standard barbell back squat",
      "analyzerType": "DYNAMIC_REP",
      "keywords": ["squat", "legs", "barbell"],
      "mediaUrl": "https://.../squat.mp4"     // resolved via PUBLIC_STORAGE_SERVICE.getUrl — stable, cacheable
      // aiConfigJson deliberately omitted here — keeps browse/search payloads light
    }
  ],
  "meta": { "total": 42, "page": 1, "pageSize": 20 }
}
```

### 5. Fetch one config's full payload (incl. AI JSON)

```
GET /api/v1/exercise-configs/:id
```
This is the endpoint the **client app** calls right before opening the camera for Watch Me — not something the trainer-facing picker UI needs. Returns everything from #4 plus `aiConfigJson`. Keeping this separate from the search response is what lets the JSON stay technically reachable (it has to be, to run on-device analysis) while never being rendered anywhere in the trainer's plan-building UI — "hidden from trainers" is enforced by what the Flutter UI chooses to display, not by withholding the field from the API.

**Response** `200`: `{ "success": true, "data": ExerciseConfigResponseDto }` (full shape, same as #1's response).

## API — Task integration (extend existing endpoints, no new routes)

Both existing task-mutation surfaces need the field — confirmed this session that only one of the two currently carries `attachments`, and the same gap would otherwise repeat for configs:

- **`server/src/workout/dto/task.dto.ts`** — `TaskInputDto` (used by both standalone `CreateTaskDto` and nested inside `CreateWeeklyPlanDto`'s day/task tree) and `UpdateTaskDto` both gain:
  ```ts
  @ApiPropertyOptional({ description: 'Selected AI exercise config, if any' })
  @IsOptional()
  @IsString()
  exerciseConfigId?: string;
  ```
- **`TaskResponseDto`** gains:
  ```ts
  @ApiPropertyOptional({ type: ExerciseConfigSummaryDto, nullable: true })
  exerciseConfig: ExerciseConfigSummaryDto | null;
  ```
  where `ExerciseConfigSummaryDto` is the lightweight shape from endpoint #4 (no `aiConfigJson`) — same "light in list/detail views, full payload only on demand" split as `TaskMedia`.
- **Validation**: `TaskService.create`/`update` (and `WeeklyPlanService.create`'s nested path) validate `exerciseConfigId` exists and `isActive` before writing, mirroring `TaskMediaService.assertUsable(...)`'s role in the attachments flow — reject the whole request with `400` if it references a missing/retired config.

This closes the gap for the new field everywhere a task can be created or edited, rather than only in the flashier whole-plan-creation path.

## Resolved decisions

- **Hard delete does not cascade to `Media`** — see §3 above.
- **`aiConfigJson` validation** lives at the service layer, per `analyzerType` (a `class-validator` discriminated shape or a runtime schema check), not as a rigid Prisma-level shape — keeps the schema itself stable as new exercise types/rule shapes are added, no migration required to support them.
- **Module placement**: standalone `server/src/exercise-config/` module — see "Module structure" above.

## Next step

This plan is ready to implement: Prisma migration → `exercise-config` module (service/controller/DTOs) → extend `task.dto.ts`/`TaskService`/`WeeklyPlanService` for the `exerciseConfigId` field and validation, in that order (schema first, since the module and the Task-integration changes both depend on the new model existing).
