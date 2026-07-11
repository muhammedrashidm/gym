# Workout Plan API — Design Doc

**Module name:** `workout`
**Stack:** NestJS, Prisma, `class-validator` / `class-transformer` for DTOs, `@nestjs/swagger` for docs.
**Schema reference:** `prisma/schema/workout.prisma` (see accompanying file). All model/field names below match that file exactly — implement against it, do not rename fields.

This doc is written for direct implementation by a coding agent. Each endpoint specifies: route, auth/role, DTO shape, validation rules, response shape, and business logic notes. Where logic is non-obvious (cursor advancement, plan swap), the exact algorithm is given — implement it as written, do not reinterpret.

---

## 0. Core invariants (read this before writing any code)

1. **`daysPerWeek` is fixed at 7.** Every `WeeklyPlan` always has exactly 7 `DayPlan` rows, `dayIndex` 1 through 7, created atomically when the plan is created. There is no concept of a 4/5/6-day plan — unused days are marked `isRestDay: true` instead of omitted.
2. **`dayIndex` is never a weekday.** It is a template position. Do not map `dayIndex` 1 → Monday anywhere in code. Weekday is a presentational label only, computed client-side or omitted entirely.
3. **`WorkoutProfile.currentDayIndex` is the single source of truth for "what's next."** Resolving "today's plan" is always a direct lookup by this cursor — never computed from `Date.now()` or day-of-week.
4. **The cursor advances only on a `COMPLETED` session log**, via `nextIndex = (currentDayIndex % 7) + 1`. A `SKIPPED` log does not move the cursor.
5. **Exactly one `ACTIVE` `WeeklyPlan` per `WorkoutProfile`.** Enforced in service logic inside a transaction (see §3.3), not by a DB constraint, because Prisma does not portably support a partial unique index across all target databases. If the project's target DB is confirmed Postgres-only, a partial unique index may be added as a defense-in-depth migration — but the service-layer transaction is mandatory regardless.
6. **Plan edits never mutate history.** Updating an active plan's tasks edits the live rows in place (trainers fixing typos, swapping media, etc. — this is fine for the *current* plan). Replacing a plan entirely (a new training block) always creates a **new** `WeeklyPlan` and archives the old one; it never deletes the old plan or its `DayPlan`/`Task` rows, because `WorkoutSessionLog` rows reference them historically.

---

## 1. Module structure

```
src/workout/
  workout.module.ts
  controllers/
    workout-profile.controller.ts
    weekly-plan.controller.ts
    day-plan.controller.ts
    task.controller.ts
    session-log.controller.ts
  services/
    workout-profile.service.ts
    weekly-plan.service.ts
    day-plan.service.ts
    task.service.ts
    session-log.service.ts
  dto/
    workout-profile/
      create-workout-profile.dto.ts
      workout-profile-response.dto.ts
    weekly-plan/
      create-weekly-plan.dto.ts
      update-weekly-plan.dto.ts
      weekly-plan-response.dto.ts
    day-plan/
      day-plan-input.dto.ts        // used nested inside create-weekly-plan
      update-day-plan.dto.ts
      day-plan-response.dto.ts
    task/
      task-input.dto.ts            // used nested inside day-plan-input
      task-media-input.dto.ts
      update-task.dto.ts
      task-response.dto.ts
      reorder-tasks.dto.ts
    session-log/
      complete-session.dto.ts
      skip-session.dto.ts
      session-log-response.dto.ts
      task-completion-input.dto.ts
  entities/ (optional, if mapping Prisma models to domain classes separately from DTOs)
```

---

## 2. Common response conventions

All endpoints return a consistent envelope. Define once and reuse:

```ts
// src/common/dto/api-response.dto.ts
export class ApiResponseDto<T> {
  @ApiProperty() success: boolean;
  @ApiProperty() data: T;
  @ApiPropertyOptional() message?: string;
}

export class PaginatedResponseDto<T> {
  @ApiProperty() success: boolean;
  @ApiProperty({ isArray: true }) data: T[];
  @ApiProperty() meta: { total: number; page: number; pageSize: number };
}
```

All list endpoints accept standard pagination query params (`page`, `pageSize`, default `page=1`, `pageSize=20`, max `pageSize=100`) via a shared `PaginationQueryDto`.

Errors follow Nest's default `HttpException` JSON shape; do not customize the error envelope unless the rest of the codebase already has a global exception filter — if one exists, conform to it instead of this doc.

All DTOs must have `@ApiProperty()` / `@ApiPropertyOptional()` decorators for every field, and every controller method must have `@ApiOperation`, `@ApiResponse` (at minimum 200/201, 400, 404), and `@ApiBearerAuth()` if auth-protected. Use `@ApiTags('workout-profiles')` etc. per controller.

---

## 3. Endpoints

### 3.1 WorkoutProfile

#### `POST /workout-profiles`
**Role:** trainer
**Purpose:** Create a profile linking a trainer to a client. One profile per client (`clientId` unique).

DTO `CreateWorkoutProfileDto`:
| field | type | validation |
|---|---|---|
| clientProfileId | string | `@IsString() @IsNotEmpty()` |
| trainerProfileId | string | `@IsString() @IsNotEmpty()` |

Logic: reject with `409 Conflict` if a `WorkoutProfile` with `isActive: true` and `isDeleted: false` already exists for `clientProfileId` (where `isDeleted` is false).

Response: `WorkoutProfileResponseDto` — `id, clientProfileId, clientUserId, trainerProfileId, trainerUserId, activeWeeklyPlanId, currentDayIndex, isActive, isDeleted, createdAt, updatedAt`.

#### `GET /workout-profiles/:id`
**Role:** trainer or the owning client
Returns the profile. Include `activeWeeklyPlan` summary (id, name, status) via a nested optional field, not the full plan tree. Check context: user must be the client/trainer of the profile or admin.

#### `GET /workout-profiles/:id/today`
**Role:** client (own profile) or trainer
**This is the endpoint the app calls on open.** No date params accepted — the resolution is purely cursor-based per Invariant 3.

Logic:
```
1. Load WorkoutProfile by id. 404 if not found.
2. If activeWeeklyPlanId is null -> return 200 with data: null, message: "No active plan assigned".
3. Load DayPlan WHERE weeklyPlanId = activeWeeklyPlanId AND dayIndex = currentDayIndex.
4. Include tasks (ordered by sequenceIndex) and each task's media (ordered by sequenceIndex).
5. Return DayPlanResponseDto.
```
Response: `DayPlanResponseDto` (see §3.3) or `null` data with explanatory message.

---

### 3.2 WeeklyPlan

#### `POST /workout-profiles/:profileId/weekly-plans`
**Role:** trainer
**Purpose:** Create a new plan template. Always creates all 7 `DayPlan` rows in one transaction, regardless of how many the trainer actually filled in — unfilled days default to `isRestDay: true` with an empty task list.

DTO `CreateWeeklyPlanDto`:
| field | type | validation |
|---|---|---|
| name | string | `@IsString() @IsNotEmpty() @MaxLength(120)` |
| notes | string? | `@IsOptional() @IsString()` |
| activateImmediately | boolean | `@IsBoolean()`, default `false` via `@Transform` or service default |
| days | `DayPlanInputDto[]` | `@ValidateNested({ each: true }) @ArrayMinSize(0) @ArrayMaxSize(7) @Type(() => DayPlanInputDto)` |

`DayPlanInputDto`:
| field | type | validation |
|---|---|---|
| dayIndex | number | `@IsInt() @Min(1) @Max(7)` |
| label | string? | `@IsOptional() @IsString() @MaxLength(60)` |
| isRestDay | boolean | `@IsBoolean()`, default `false` |
| tasks | `TaskInputDto[]` | `@ValidateNested({ each: true }) @Type(() => TaskInputDto)`, required if `isRestDay` is false |

Custom validation (implement as a class-validator `@ValidatorConstraint` or service-layer check, not inline): **no duplicate `dayIndex` values** in the `days` array, and every `dayIndex` 1–7 must be represented exactly once if `days` is non-empty for that index — i.e., the incoming array, once defaulted, must produce exactly 7 `DayPlan` rows with `dayIndex` 1..7. Any `dayIndex` omitted from the request is filled in as an empty rest day by the service before persisting.

`TaskInputDto`:
| field | type | validation |
|---|---|---|
| sequenceIndex | number | `@IsInt() @Min(1)` |
| name | string | `@IsString() @IsNotEmpty() @MaxLength(160)` |
| description | string? | `@IsOptional() @IsString()` |
| machineDetails | string? | `@IsOptional() @IsString()` |
| notes | string? | `@IsOptional() @IsString()` |
| sets | number | `@IsInt() @Min(1)` |
| reps | string | `@IsString() @IsNotEmpty()` |
| restSeconds | number? | `@IsOptional() @IsInt() @Min(0)` |
| tempo | string? | `@IsOptional() @IsString()` |
| media | `TaskMediaInputDto[]` | `@IsOptional() @ValidateNested({ each: true }) @Type(() => TaskMediaInputDto)` |

`TaskMediaInputDto`:
| field | type | validation |
|---|---|---|
| type | enum | `@IsEnum(TaskMediaType)` |
| url | string | `@IsUrl()` |
| caption | string? | `@IsOptional() @IsString()` |
| sequenceIndex | number | `@IsInt() @Min(1)` |

Logic:
```
1. Validate profile exists.
2. Run in a single Prisma transaction:
   a. status = activateImmediately ? ACTIVE : UPCOMING
   b. If activateImmediately:
      - find any existing WeeklyPlan for this profile with status ACTIVE
      - if found: set its status to ARCHIVED, effectiveTo = now()
      - set new plan's effectiveFrom = now()
   c. Create WeeklyPlan.
   d. Create 7 DayPlan rows (defaulting missing dayIndex entries to isRestDay: true, tasks: []).
   e. For each DayPlan with tasks, bulk-create Task rows, then bulk-create TaskMedia rows.
   f. If activateImmediately: update WorkoutProfile.activeWeeklyPlanId = new plan id,
      and reset WorkoutProfile.currentDayIndex = 1 (see Invariant note in §3.2.1 below).
3. Return the full WeeklyPlanResponseDto (with nested days -> tasks -> media).
```

**§3.2.1 — Cursor reset on activation.** When a new plan becomes active (whether at creation or via the explicit activate endpoint below), `currentDayIndex` resets to `1`. This is a product decision baked into this doc: a new training block always starts at day 1 regardless of where the client's cursor was on the previous plan. If the product later wants "carry the cursor forward across plan swaps," that is a deliberate change to this rule — flag it back to product/design before implementing differently, do not silently change this default.

#### `GET /workout-profiles/:profileId/weekly-plans`
**Role:** trainer or client
List all plans for a profile (paginated), ordered `createdAt DESC`. Response includes only summary fields per plan (id, name, status, effectiveFrom, effectiveTo, dayPlans count) — not the full task tree, to keep payload small. Use `WeeklyPlanSummaryDto`.

#### `GET /weekly-plans/:id`
Full plan detail: `WeeklyPlanResponseDto` with nested `days` (7, ordered by `dayIndex`) → `tasks` (ordered by `sequenceIndex`) → `media` (ordered by `sequenceIndex`).

#### `PATCH /weekly-plans/:id`
**Role:** trainer
Edits metadata only (`name`, `notes`). Does **not** touch day/task structure — see §3.3/§3.4 for those. `UpdateWeeklyPlanDto` is a partial of `{ name, notes }`.

#### `POST /weekly-plans/:id/activate`
**Role:** trainer
**Purpose:** Promote an `UPCOMING` plan to `ACTIVE` for its profile (the plan-swap operation described in the conversation: "trainer designs a new plan, it becomes the active one").

Logic (transaction):
```
1. Load plan. 404 if not found. 409 if plan.status !== UPCOMING (cannot re-activate an ARCHIVED plan directly — create a new one instead; this is intentional, not an oversight).
2. Find current ACTIVE plan for the same workoutProfileId, if any:
   - set status = ARCHIVED, effectiveTo = now()
3. Set this plan: status = ACTIVE, effectiveFrom = now()
4. Update WorkoutProfile: activeWeeklyPlanId = this plan id, currentDayIndex = 1
5. Return updated WeeklyPlanResponseDto.
```

#### `DELETE /weekly-plans/:id`
**Role:** trainer
Only permitted if `status === UPCOMING` (never delete an `ACTIVE` or `ARCHIVED` plan — archived plans are historical record, active plans must be swapped via `/activate`, not deleted). Return `409` otherwise.

---

### 3.3 DayPlan

DayPlans are not created/deleted independently — they're always created as part of a `WeeklyPlan` (always exactly 7). Only their content is editable post-creation.

#### `GET /day-plans/:id`
Returns `DayPlanResponseDto`:
```ts
class DayPlanResponseDto {
  id: string;
  weeklyPlanId: string;
  dayIndex: number;       // 1..7
  label: string | null;
  isRestDay: boolean;
  tasks: TaskResponseDto[]; // ordered by sequenceIndex
}
```

#### `PATCH /day-plans/:id`
**Role:** trainer
`UpdateDayPlanDto`: `{ label?: string; isRestDay?: boolean }` — both optional, `@IsOptional()` on each.
Logic: if `isRestDay` is set to `true`, do **not** auto-delete existing tasks (trainer may toggle back and forth while editing) — leave tasks in place but the `/today` resolution and client-facing views must treat `isRestDay: true` as "no workout today" regardless of whether `tasks` is empty. Document this clearly in the Swagger description for this field.

---

### 3.4 Task

#### `POST /day-plans/:dayPlanId/tasks`
**Role:** trainer
`CreateTaskDto` = same shape as `TaskInputDto` above (reuse it). `sequenceIndex` must not collide with an existing task's `sequenceIndex` for that `dayPlanId` — if the requested index is already taken, shift subsequent tasks' `sequenceIndex` up by 1 in a transaction (insert-and-shift semantics), rather than rejecting the request. Document this insert behavior in the Swagger `@ApiOperation` description so frontend devs know they don't need to pre-compute gaps.

#### `PATCH /tasks/:id`
**Role:** trainer
`UpdateTaskDto` — partial of all `TaskInputDto` fields except `sequenceIndex` (reordering is a separate endpoint, see below, to avoid ambiguous partial-reorder semantics on a generic update).

#### `DELETE /tasks/:id`
**Role:** trainer
On delete, re-sequence remaining tasks in the same `dayPlanId` so `sequenceIndex` stays contiguous (1..n, no gaps). Do this in a transaction.

#### `PATCH /day-plans/:dayPlanId/tasks/reorder`
**Role:** trainer
**Purpose:** Explicit reorder endpoint (matches the drag-handle UI from the mockup).

`ReorderTasksDto`:
| field | type | validation |
|---|---|---|
| orderedTaskIds | string[] | `@IsArray() @ArrayMinSize(1) @IsString({ each: true })` |

Logic: validate that `orderedTaskIds` is exactly the set of task ids currently belonging to `dayPlanId` (same length, same set — no missing, no foreign ids) — `400` if not. Then assign `sequenceIndex = index + 1` for each id in array order, in a single transaction.

#### Task media sub-resource
- `POST /tasks/:taskId/media` — `CreateTaskMediaDto` = `TaskMediaInputDto`. Same insert-and-shift semantics on `sequenceIndex` collision as tasks.
- `DELETE /task-media/:id` — re-sequence remaining media for that task afterward.

---

### 3.5 Session logging (client progress + cursor advancement)

#### `POST /workout-profiles/:profileId/sessions/complete`
**Role:** client (own profile) — trainers should not call this on behalf of a client unless the product explicitly wants trainer-logged sessions; if so, allow trainer role too but log `loggedBy` (add this field only if needed — not in the base schema, flag to product if required).

`CompleteSessionDto`:
| field | type | validation |
|---|---|---|
| taskCompletions | `TaskCompletionInputDto[]?` | `@IsOptional() @ValidateNested({ each: true }) @Type(() => TaskCompletionInputDto)` |
| notes | string? | `@IsOptional() @IsString()` |

`TaskCompletionInputDto`:
| field | type | validation |
|---|---|---|
| taskId | string | `@IsString() @IsNotEmpty()` |
| actualSets | number? | `@IsOptional() @IsInt() @Min(0)` |
| actualReps | string? | `@IsOptional() @IsString()` |
| actualWeightKg | number? | `@IsOptional() @IsNumber() @Min(0)` |
| notes | string? | `@IsOptional() @IsString()` |

Logic (transaction — this is the core algorithm, implement exactly):
```
1. Load WorkoutProfile. 404 if not found. 409 if activeWeeklyPlanId is null
   ("cannot complete a session with no active plan").
2. currentIndex = workoutProfile.currentDayIndex
3. Load DayPlan WHERE weeklyPlanId = activeWeeklyPlanId AND dayIndex = currentIndex.
4. Create WorkoutSessionLog:
   - workoutProfileId, weeklyPlanId = activeWeeklyPlanId, dayPlanId = dayPlan.id
   - dayIndexAtTime = currentIndex
   - status = COMPLETED
   - completedDate = now()
5. If taskCompletions provided, bulk-create TaskCompletionLog rows linked to the new session log.
6. nextIndex = (currentIndex % 7) + 1
7. Update WorkoutProfile.currentDayIndex = nextIndex.
8. Return SessionLogResponseDto including the new currentDayIndex so the client
   can immediately know what's next without a second round trip.
```

#### `POST /workout-profiles/:profileId/sessions/skip`
**Role:** client (own profile) or trainer
`SkipSessionDto`: `{ reason?: string }` — `@IsOptional() @IsString()`.

Logic:
```
1. Load WorkoutProfile. 404 if not found.
2. Create WorkoutSessionLog:
   - dayIndexAtTime = currentDayIndex (unchanged)
   - status = SKIPPED
   - completedDate = null
   - scheduledDate = now() (or the date being skipped, if backfilling — see note)
3. Do NOT modify WorkoutProfile.currentDayIndex.
4. Return SessionLogResponseDto.
```
Note: this doc does not implement scheduled/automatic skip-detection (a cron marking missed `SCHEDULED` rows as `SKIPPED` at end of day) — that's an optional future addition per the original design discussion, not required for this version. Flag to product if needed; do not build it speculatively.

#### `GET /workout-profiles/:profileId/sessions`
Paginated session history, `createdAt DESC`. Useful for trainer adherence dashboards. Supports optional query filters `status`, `from`, `to` (date range on `createdAt`).

---

## 4. Response DTOs (shape reference)

```ts
class TaskMediaResponseDto {
  id: string;
  type: 'IMAGE' | 'GIF' | 'VIDEO';
  url: string;
  caption: string | null;
  sequenceIndex: number;
}

class TaskResponseDto {
  id: string;
  sequenceIndex: number;
  name: string;
  description: string | null;
  machineDetails: string | null;
  notes: string | null;
  sets: number;
  reps: string;
  restSeconds: number | null;
  tempo: string | null;
  media: TaskMediaResponseDto[];
}

class DayPlanResponseDto {
  id: string;
  weeklyPlanId: string;
  dayIndex: number;
  label: string | null;
  isRestDay: boolean;
  tasks: TaskResponseDto[];
}

class WeeklyPlanResponseDto {
  id: string;
  workoutProfileId: string;
  name: string;
  status: 'ACTIVE' | 'UPCOMING' | 'ARCHIVED';
  effectiveFrom: string | null; // ISO date
  effectiveTo: string | null;
  createdById: string;
  notes: string | null;
  days: DayPlanResponseDto[]; // always 7, ordered by dayIndex
  createdAt: string;
  updatedAt: string;
}

class WeeklyPlanSummaryDto {
  id: string;
  name: string;
  status: 'ACTIVE' | 'UPCOMING' | 'ARCHIVED';
  effectiveFrom: string | null;
  effectiveTo: string | null;
  createdById: string;
  dayPlanCount: number; // always 7, included for UI consistency, not a real variable
}

class WorkoutProfileResponseDto {
  id: string;
  clientProfileId: string;
  clientUserId: string | null;
  trainerProfileId: string;
  trainerUserId: string;
  activeWeeklyPlanId: string | null;
  currentDayIndex: number;
  isActive: boolean;
  isDeleted: boolean;
  createdAt: string;
  updatedAt: string;
}

class SessionLogResponseDto {
  id: string;
  workoutProfileId: string;
  weeklyPlanId: string;
  dayPlanId: string | null;
  dayIndexAtTime: number;
  status: 'SCHEDULED' | 'COMPLETED' | 'SKIPPED' | 'PARTIAL';
  scheduledDate: string | null;
  completedDate: string | null;
  currentDayIndexAfter?: number; // only present on the complete-session response
}
```

All response DTOs above must be decorated with `@ApiProperty()` and wired through Swagger via `@ApiOkResponse({ type: ... })` / `@ApiCreatedResponse({ type: ... })` on each controller method. Use Nest's `ClassSerializerInterceptor` + `@Exclude()`/`@Expose()` if the project already follows that pattern for entity-to-DTO mapping; otherwise map explicitly in the service return statement.

---

## 5. Authorization notes (implement per existing project auth, not specified here)

This doc assumes the project has an existing guard/decorator system (e.g. `@Roles()`, `@CurrentUser()`). Apply:
- **trainer-only** endpoints: all plan/day-plan/task create/update/delete, plan activation.
- **client-or-trainer** (client must own the profile; trainer must own the client relationship): `today`, `GET` endpoints, session completion/skip.

Do not implement a new auth system as part of this module — wire into whatever guard pattern already exists in the codebase. If none exists yet, flag this back rather than inventing one inline in this module.

---

## 6. Things intentionally out of scope for this version

Do not build these unless explicitly requested — they were discussed as possible extensions, not committed requirements:
- Per-client task overrides (swapping one exercise for an injured client without forking the whole plan).
- Automatic cron-based skip detection.
- Shared exercise/media library with reusable `TaskMedia` references (current model treats every `TaskMedia.url` as freeform/task-specific).
- Trainer-logs-on-behalf-of-client distinction (`loggedBy` field).

If implementing any of these, return to product/design for the schema implications first — each one changes the Prisma model, not just the API layer.
