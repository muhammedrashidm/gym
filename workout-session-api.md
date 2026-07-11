# Workout Session API — Frontend Integration Guide

Covers the three endpoints for logging a client's daily workout session (complete/skip) and reading history. Same endpoints serve **both** the member (logging their own session) and the assigned trainer (logging on the member's behalf) — the server tells the two apart automatically from the auth token, there is no role flag to send.

Base path: `/api/v1` (prepend to every path below).
Auth: `Authorization: Bearer <token>` on every request (`@ApiBearerAuth`).

---

## 1. Who can call these endpoints

For a given `:profileId` (a `WorkoutProfile` id):

- The **client who owns the profile**.
- The **trainer currently assigned** to that profile.
- Any **admin**.

Anyone else gets `403 Forbidden`. The app doesn't need to pass a role — just call the endpoint with the logged-in user's token, for whichever `profileId` is currently open in the UI.

---

## 2. Endpoints

### 2.1 Complete today's session

```
POST /workout-profiles/:profileId/sessions/complete
```

Logs today's session (the profile's current cursor day) as completed, records optional per-task actuals, and advances the day cursor. This is the "one call does everything" endpoint — don't call task-update endpoints separately for this flow.

**Request body** (`CompleteWorkoutSessionDto`, all fields optional):

```jsonc
{
  "taskCompletions": [
    {
      "taskId": "task-uuid",       // required per entry — must belong to today's DayPlan
      "actualSets": 4,              // optional, int >= 0
      "actualReps": "10, 10, 8, 8", // optional, free-text string (per-set reps)
      "actualWeightKg": 85.5,       // optional, number >= 0
      "notes": "Felt strong, could increase weight next week." // optional
    }
  ],
  "notes": "Great energy today, shoulder felt slightly tight but no pain." // optional, session-level
}
```

- `taskCompletions` can be omitted entirely, or include only some of today's tasks — no need to send a row for every task.
- Do **not** send which day/week/program this is, or who is logging it — the server derives all of that from the profile's cursor and the auth token. Sending a `dayPlanId` or actor role has no effect (there's no field for it).

**Response** — `201 Created`, `ApiResponseDto<WorkoutSessionResponseDto>`:

```jsonc
{
  "success": true,
  "data": {
    "id": "log-uuid",
    "workoutProfileId": "profile-uuid",
    "weeklyPlanId": "plan-uuid",
    "weeklyPlanName": "Push Pull Legs — Strength",
    "dayPlanId": "day-plan-uuid",
    "dayPlanLabel": "Leg Day",
    "dayIndexAtTime": 3,
    "cycleNumberAtTime": 2,
    "status": "COMPLETED",
    "scheduledDate": null,
    "completedDate": "2026-07-11T09:15:00.000Z",
    "loggedByRole": "MEMBER",       // or "TRAINER" / "STAFF"
    "loggedByUserId": "user-uuid",
    "currentDayIndexAfter": 4        // the profile's NEW cursor position, post-advance
  }
}
```

Use `currentDayIndexAfter` to update the "today" indicator in the UI immediately, without a re-fetch of the profile.

**Errors:**
| Status | Cause |
|---|---|
| `404` | `profileId` doesn't exist (or is soft-deleted) |
| `403` | Caller is neither the owning client, the assigned trainer, nor an admin |
| `409` | Profile has no `activeWeeklyPlanId` (no program assigned yet) |
| `404` | No `DayPlan` exists for the profile's current day index on the active plan |
| `409` | A `taskId` in `taskCompletions` doesn't belong to today's `DayPlan` |
| `400` | Body fails validation (wrong types, negative numbers, etc.) |

---

### 2.2 Skip today's session

```
POST /workout-profiles/:profileId/sessions/skip
```

Logs today's session as skipped. **Does not** advance the day cursor or the week counter — skipping doesn't move the plan forward.

**Request body** (`SkipWorkoutSessionDto`, fully optional):

```jsonc
{
  "reason": "Sick / Travel / Rest required" // optional, free text
}
```

**Response** — `201 Created`, same `WorkoutSessionResponseDto` shape as complete, except:
- `status: "SKIPPED"`
- `currentDayIndexAfter` is **not** present (cursor didn't move — keep using the value you already have from the profile).

**Errors:** same table as §2.1, minus the task-id validation case (skip has no task payload).

---

### 2.3 List session history

```
GET /workout-profiles/:profileId/sessions?page=1&pageSize=20
```

**Query params:** `page` (default `1`), `pageSize` (default `20`) — both optional integers ≥ 1.

**Response** — `200 OK`, `PaginatedResponseDto<WorkoutSessionResponseDto>`:

```jsonc
{
  "success": true,
  "data": [
    { /* WorkoutSessionResponseDto, same shape as above (no currentDayIndexAfter) */ }
  ],
  "meta": {
    "total": 42,
    "page": 1,
    "pageSize": 20
  }
}
```

Ordered newest-first (`completedDate desc`). Use `meta.total` + `meta.pageSize` to drive pagination controls.

**Errors:** `404` (bad profileId), `403` (no access).

---

## 3. `WorkoutSessionResponseDto` field reference

| Field | Type | Notes |
|---|---|---|
| `id` | `string` | Session log id |
| `workoutProfileId` | `string` | |
| `weeklyPlanId` | `string` | The program this log belongs to |
| `weeklyPlanName` | `string` | Program display name — joined at read time, safe to show directly ("Program: X") |
| `dayPlanId` | `string \| null` | |
| `dayPlanLabel` | `string \| null` | e.g. "Leg Day" — joined at read time, may be `null` if the day has no label |
| `dayIndexAtTime` | `number` | 1–7, the template day position at the time this was logged |
| `cycleNumberAtTime` | `number` | "Week N" of the program — stable historically even if the plan is edited later |
| `status` | `"SCHEDULED" \| "COMPLETED" \| "SKIPPED" \| "PARTIAL"` | Only `COMPLETED`/`SKIPPED` are produced by these two endpoints today |
| `scheduledDate` | `string \| null` (ISO datetime) | |
| `completedDate` | `string \| null` (ISO datetime) | When complete/skip was submitted |
| `loggedByRole` | `"MEMBER" \| "TRAINER" \| "STAFF" \| null` | Who submitted it — use to label entries "Logged by trainer" in a shared history view |
| `loggedByUserId` | `string \| null` | |
| `currentDayIndexAfter` | `number \| undefined` | **Only present on `complete` responses** |

Suggested UI label: build "Day {dayIndexAtTime} · Week {cycleNumberAtTime} · {weeklyPlanName}" from these three fields — the API always returns them together so no second request is needed to render it.

---

## 4. Typical frontend flow

1. On the workout-today screen, you already have the `WorkoutProfile` (with `currentDayIndex`) from the profile-fetch endpoint — use it to render today's `DayPlan` and its tasks.
2. Member (or trainer, viewing the same client's profile) fills in actuals per task and hits "Complete" → `POST .../complete` with whatever `taskCompletions` rows were filled in.
3. On success, replace the local `currentDayIndex` with `currentDayIndexAfter` from the response and move the UI to the next day.
4. If the user skips instead, call `POST .../skip` — do **not** update the local day cursor, since it doesn't change.
5. History/progress screens page through `GET .../sessions` and render each row using the fields in §3.

## 5. Not available yet (don't build for it)

- No endpoint to log/backfill a day other than the profile's *current* cursor day (e.g. correcting a past day). If a trainer needs to submit for a non-current day, that's not supported by this API today — flag it back to backend rather than working around it client-side.
- No request field lets the client claim which day/week/program a log belongs to, or who is submitting it — these are always server-derived. Don't add such fields to the request payload; they'll be silently ignored.
