# Workout Session Update API — Design Doc (Gap-Closing Plan)

**NestJS module:** `WorkoutModule` (unchanged — `server/src/workout/workout.module.ts`). No new module is created by this doc.
**Sub-resource name:** `workout-session` (renamed in place from the current `session-log` naming — see §0.2)
**Stack:** NestJS, Prisma, `class-validator` / `class-transformer`, `@nestjs/swagger`.
**Schema reference:** `prisma/schema/workout.prisma`.

This is **not** a greenfield design — the mechanism this doc covers is already ~80% implemented in `server/src/workout/`. This doc specifies the remaining gaps needed to support **trainer-initiated session completion** (not just member self-logging) with full day/week/program attribution, a file/class rename for naming clarity, and a retrofit of the interface-first pattern already used by the `users` module. Both member logging and trainer logging continue to be served by the same controller/service/endpoints — see §0.1 for why this isn't split into a separate module.

---

## 0. Baseline — what already works today (read first)

Do not re-implement any of this; it's already correct:

- `WorkoutSessionLog` (day/program history) and `TaskCompletionLog` (per-task actuals: `actualSets`, `actualReps`, `actualWeightKg`, `notes`) already exist in `prisma/schema/workout.prisma` and already model "custom update per task — reps, weight."
- `POST /workout-profiles/:profileId/sessions/complete` already does the "single API call" job in one Prisma transaction: creates the session log, bulk-creates task completion rows, and advances `WorkoutProfile.currentDayIndex` per the cursor invariant (`nextIndex = (currentDayIndex % 7) + 1`).
- `checkProfileAccess()` in the current `session-log.service.ts` **already permits both** the owning client and the assigned trainer to call `complete` / `skip` — trainer access is not blocked today, it's just not attributed.

### 0.1 Architecture decision: rename in place, no new module

Two approaches were weighed:

1. **Update in place (chosen).** Keep `session-log.*` inside the existing `WorkoutModule`, rename files/classes to `workout-session.*` / `WorkoutSession*`, extend the existing service/controller with the gaps in §2–§5. Both member self-logging and trainer logging keep going through the same controller and service — they're the same operation with different actors, not two different feature sets.
2. **Extract to a new `WorkoutSessionModule`.** Move the session-log surface into its own top-level NestJS module, imported alongside `WorkoutModule`.

**Chosen: option 1.** Reasons:
- The four other sub-resources in `WorkoutModule` (`workout-profile`, `weekly-plan`, `day-plan`, `task`) are not split into their own modules either — they're grouped by domain under one feature module, matching how every other domain in this codebase (`users`, `auth`, `gym`, `media`) is organized as a single top-level module. Splitting only `session-log` out would be an inconsistent, one-off exception with no other sub-resource following it.
- Session logging is tightly coupled to `WorkoutProfile` at the data layer — cursor advancement (`currentDayIndex`, and the new `completedCycleCount`) is updated in the *same transaction* as the session log write. A separate NestJS module doesn't reduce this coupling (Prisma transactions aren't scoped by module boundaries); it would only add an import between two modules that already need to reach into the same rows.
- `WorkoutModule` already `exports` every service, so nothing outside the module is blocked from depending on session-logging behavior specifically — a consumer just imports `WorkoutModule` today, same as it would import a new `WorkoutSessionModule`.
- There's no current requirement (analytics service, reporting module, background job) that needs session-log capability *without* the rest of the workout domain — extracting a module preemptively for a consumer that doesn't exist yet is speculative.

If a real second consumer shows up later that needs session-log data without pulling in plan/task management, revisit this — but that's a future call, not a reason to split now.

### 0.2 Rename (files + classes only, same module)

Current names → target names. This is a pure rename, no behavior change, done as its own step before the functional changes below so the diff for the functional changes stays readable. `workout.module.ts` itself is edited only to update these import paths and provider/controller class names — its `imports`/`exports` arrays and overall shape are unchanged.

| Current | New |
|---|---|
| `controllers/session-log.controller.ts` | `controllers/workout-session.controller.ts` |
| `services/session-log.service.ts` | `services/workout-session.service.ts` |
| `dto/session-log.dto.ts` | `dto/workout-session.dto.ts` |
| `SessionLogController` | `WorkoutSessionController` |
| `SessionLogService` | `WorkoutSessionService` |
| `SessionLogResponseDto` | `WorkoutSessionResponseDto` |
| `CompleteSessionDto` | `CompleteWorkoutSessionDto` |
| `SkipSessionDto` | `SkipWorkoutSessionDto` |
| `TaskCompletionInputDto` | unchanged (already correctly named, not session-scoped) |

`WorkoutSessionLog` / `WorkoutSessionLogStatus`-style Prisma model/enum names are unchanged — the schema already says `WorkoutSessionLog`, so the rename brings the NestJS layer in line with the schema, not the other way around. Update `workout.module.ts` imports/providers/controllers accordingly. HTTP routes (`/workout-profiles/:profileId/sessions/...`) stay the same — only internal file/class names change, no client-facing break.

---

## 1. Gap analysis

| Gap | Problem today |
|---|---|
| **1. No actor identity on the log** | The log doesn't record *who* submitted it. A trainer and a member hitting the same endpoint produce an identical row — no way to distinguish "member logged their own set" from "trainer logged it on their behalf." |
| **2. No "week" concept** | `dayIndexAtTime` (1–7) is a template position that repeats forever (the plan cycles indefinitely). There's no counter for "which repetition of the 7-day cycle is this," so "day X of week Y of program Z" can't be reconstructed from history today. |
| **3. No interface layer for this module** | The `users` module follows `IUsersService` / `IUsersController` (interface-first; controller/service `implements` it). The `workout` module's controllers/services don't do this yet — a pre-existing gap, closed here for the piece being touched. |

"Program" maps 1:1 to `WeeklyPlan` — it's the only plan-grouping concept in the schema and the term isn't used elsewhere in the codebase, so no new entity is needed for "program."

---

## 2. Schema changes (`prisma/schema/workout.prisma`)

```prisma
enum SessionLogActorRole {
  MEMBER
  TRAINER
  STAFF
}

model WorkoutProfile {
  // ...existing fields...
  completedCycleCount Int @default(0)   // NEW — increments each time the 7-day cursor wraps 7 -> 1
}

model WorkoutSessionLog {
  // ...existing fields...
  cycleNumberAtTime   Int                   // NEW — "week N" of this WeeklyPlan, denormalized like dayIndexAtTime
  loggedByUserId      String                // NEW
  loggedByRole        SessionLogActorRole   // NEW — MEMBER / TRAINER / STAFF, actor at submission time
}
```

Notes:
- `completedCycleCount` is the running counter on `WorkoutProfile`; `cycleNumberAtTime` is the **snapshot** written onto each log at creation — same pattern the schema already uses for `dayIndexAtTime` (denormalized so history reads correctly even if the source row changes later).
- Week numbering starts at 1 and increments only when the cursor wraps from day 7 back to day 1 (i.e., a full week was just completed, not merely started).
- Migration is additive. `completedCycleCount` defaults to `0` for existing profiles. For existing `WorkoutSessionLog` rows, either:
  - backfill via migration script: `loggedByRole = MEMBER`, `loggedByUserId = workoutProfile.clientUserId`, `cycleNumberAtTime = 1` — **recommended**, keeps the audit trail clean, or
  - make the three new columns nullable if backfilling history isn't wanted.

**Open decision:** should `SKIPPED` logs also carry `loggedByRole` / `cycleNumberAtTime`? Recommend yes, for consistency — a trainer marking a day skipped on a client's behalf is the same attribution need as completing it.

---

## 3. Interface layer (new)

Mirror the `users` module exactly (`src/users/interfaces/users-service.interface.ts` / `users-controller.interface.ts`):

```
src/workout/interfaces/workout-session-service.interface.ts
src/workout/interfaces/workout-session-controller.interface.ts
```

```ts
// workout-session-service.interface.ts
import type { RequestContext } from '../../common/types/request-context.type';
import type { CompleteWorkoutSessionDto, SkipWorkoutSessionDto, WorkoutSessionResponseDto } from '../dto/workout-session.dto';
import type { PaginationMeta } from '../../common/dto/api-response.dto';

export interface IWorkoutSessionService {
  complete(
    profileId: string,
    dto: CompleteWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<WorkoutSessionResponseDto>;

  skip(
    profileId: string,
    dto: SkipWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<WorkoutSessionResponseDto>;

  findAll(
    profileId: string,
    page: number,
    pageSize: number,
    ctx: RequestContext,
  ): Promise<{ data: WorkoutSessionResponseDto[]; meta: PaginationMeta }>;
}
```

```ts
// workout-session-controller.interface.ts
import type { RequestContext } from '../../common/types/request-context.type';
import type { CompleteWorkoutSessionDto, SkipWorkoutSessionDto, WorkoutSessionResponseDto } from '../dto/workout-session.dto';
import type { PaginationQueryDto, ApiResponseDto, PaginatedResponseDto } from '../../common/dto/api-response.dto';

export interface IWorkoutSessionController {
  complete(
    profileId: string,
    dto: CompleteWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<ApiResponseDto<WorkoutSessionResponseDto>>;

  skip(
    profileId: string,
    dto: SkipWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<ApiResponseDto<WorkoutSessionResponseDto>>;

  findAll(
    profileId: string,
    query: PaginationQueryDto,
    ctx: RequestContext,
  ): Promise<PaginatedResponseDto<WorkoutSessionResponseDto>>;
}
```

`WorkoutSessionService implements IWorkoutSessionService`, `WorkoutSessionController implements IWorkoutSessionController` — same `import type { I... } from ...` + `implements` pattern as `users.controller.ts`.

Scope note: only `workout-session` gets interfaces in this pass, since it's the piece being touched. The other four workout controllers/services (`workout-profile`, `weekly-plan`, `day-plan`, `task`) remain without interfaces — tracked as separate pattern debt, not bundled into this change.

---

## 4. DTO changes (`dto/workout-session.dto.ts`, renamed from `session-log.dto.ts`)

No new **input** fields on `CompleteWorkoutSessionDto` / `TaskCompletionInputDto` — per-task reps/weight/sets/notes are already fully modeled. Actor identity and day/week/program context are **derived server-side from `RequestContext` and the profile's cursor, never accepted from the client** — this preserves the existing invariant that "today" is always resolved from `currentDayIndex`, never trusted from the request, and prevents a client from claiming a day that doesn't match the server's cursor.

`WorkoutSessionResponseDto` (renamed from `SessionLogResponseDto`) gains:

```ts
@ApiProperty({ enum: SessionLogActorRole })
loggedByRole: SessionLogActorRole;

@ApiProperty()
loggedByUserId: string;

@ApiProperty()
cycleNumberAtTime: number;   // "week N"

// Joined at read time, not stored — see note below.
@ApiProperty()
weeklyPlanName: string;      // "program" label

@ApiPropertyOptional({ nullable: true })
dayPlanLabel: string | null; // e.g. "Leg Day"
```

`weeklyPlanName` / `dayPlanLabel` are **not** persisted on the log — no schema change for them. They're joined from `weeklyPlan.name` / `dayPlan.label` at response-mapping time in `complete`/`skip`/`findAll`, same as any other read-side join. This gives a trainer-facing UI "Day 3, Week 2, Push Pull Program" in one response without a second round trip, while the immutable history (`dayIndexAtTime`, `cycleNumberAtTime`, `weeklyPlanId`) stays the source of truth.

---

## 5. Service logic changes (`workout-session.service.ts`)

`complete()` transaction, updated:

```
1. Load WorkoutProfile. 404 if not found.
2. checkProfileAccess(profile, ctx)  — unchanged; already allows client-owner or assigned trainer.
3. 409 if activeWeeklyPlanId is null.
4. currentIndex = profile.currentDayIndex
5. Load DayPlan @ (activeWeeklyPlanId, currentIndex).
6. actorRole = ctx.isStaff ? TRAINER : MEMBER
   — derived from ctx (RequestContext.isStaff / isMember), never from the request body.
   (STAFF vs TRAINER distinction: if a non-trainer staff/admin role can also log on behalf of
   a client, differentiate via ctx.roles; otherwise TRAINER covers all staff-side submissions.)
7. nextIndex = (currentIndex % 7) + 1
   cycleIncrement = nextIndex === 1 ? 1 : 0   // wrapped back to day 1 => a week just completed
8. Transaction:
   a. Create WorkoutSessionLog:
        ...existing fields...,
        cycleNumberAtTime: profile.completedCycleCount + cycleIncrement,
        loggedByUserId: ctx.userId,
        loggedByRole: actorRole,
   b. bulk-create TaskCompletionLog rows (unchanged validation: taskIds must belong to dayPlan.id).
   c. Update WorkoutProfile: currentDayIndex = nextIndex,
                              completedCycleCount = { increment: cycleIncrement }
9. Return WorkoutSessionResponseDto, joined with weeklyPlan.name / dayPlan.label.
```

`skip()` gets the same `loggedByUserId` / `loggedByRole` capture (cursor and `completedCycleCount` unchanged, matching existing "cursor doesn't move on skip" behavior).

`checkProfileAccess()` is unchanged — it's already resource-scoped (this specific trainer ↔ this specific client), which is stricter than a blanket `@Roles('trainer')` check and shouldn't be loosened to a role-only check.

---

## 6. Endpoint surface — no new routes

Reuse the existing three endpoints as-is (paths unchanged by the rename in §0.2):

- `POST /workout-profiles/:profileId/sessions/complete`
- `POST /workout-profiles/:profileId/sessions/skip`
- `GET /workout-profiles/:profileId/sessions`

The Flutter client (out of scope for this doc) calls `complete` from whichever role's session is active — trainer or member — the server tells them apart automatically via `RequestContext`, not via a request flag.

**Open decision — backfill / explicit day:** everything above assumes the actor (member or trainer) is always completing/skipping the client's **current cursor day**. If trainers also need to backfill a specific *past* day (e.g., correcting a paper log, or entering data for a day that's no longer the current cursor), that's a materially different operation — it would need an explicit `dayPlanId`/`weeklyPlanId` in the request instead of deriving from the cursor, and would not advance the cursor the same way. Not included here because nothing has confirmed it's a requirement yet — if needed, design it as a separate endpoint (e.g. `PATCH /workout-profiles/:profileId/sessions/backfill`) rather than overloading `complete`.

---

## 7. Migration / rollout checklist

1. Prisma migration: add `SessionLogActorRole` enum, `WorkoutProfile.completedCycleCount`, `WorkoutSessionLog.cycleNumberAtTime` / `loggedByUserId` / `loggedByRole` (+ optional backfill script for existing rows per §2).
2. Rename files/classes per §0.2 (same `WorkoutModule`, no new module); update `workout.module.ts` imports/providers/controllers.
3. Add `IWorkoutSessionService` / `IWorkoutSessionController` (§3); apply `implements` on both classes.
4. Extend `CompleteWorkoutSessionDto`/response DTOs, update service logic (§4–§5).
5. Update Swagger decorators (`@ApiOkResponse`, `@ApiCreatedResponse`, etc.) to reflect new response fields.
6. Regenerate Prisma client, run existing `session-log`-related specs (rename test files too), add coverage for: trainer-submitted completion sets `loggedByRole = TRAINER`; cycle increments only on 7→1 wrap; `cycleNumberAtTime` is stable historically after a later plan edit.

---

## 8. Out of scope

Per-client task overrides, cron-based auto-skip detection, shared exercise/media library, and backfill logging (pending the open decision in §6) — none of these are committed requirements; return to this doc if any become one.
