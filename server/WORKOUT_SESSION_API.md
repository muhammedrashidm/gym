# Workout Session API Documentation

## Overview

Log completion (or skip) of a client's workout day. A single call reports the whole day's result — overall status plus per-task actuals (sets/reps/weight/notes) — and the server advances the client's day/week cursor automatically.

This can be called by **either** the client themselves (logging their own workout) **or** their assigned trainer (logging on the client's behalf) — the server tells them apart automatically from the auth token, no request flag needed. Who actually submitted the log is recorded and returned (`loggedByRole` / `loggedByUserId`).

**Base URL:** `/api/v1/workout-profiles/:profileId/sessions`

`:profileId` is the client's `WorkoutProfile.id` (not their user/profile id) — obtained from `GET /workout-profiles/:id` or the trainer's client list.

---

## Endpoints Summary

| Method | Path | Auth | Who can call | Description |
|--------|------|------|---------------|-------------|
| POST | `/workout-profiles/:profileId/sessions/complete` | Bearer access | Client (own profile) or their assigned trainer | Mark today's day as completed, with per-task actuals |
| POST | `/workout-profiles/:profileId/sessions/skip` | Bearer access | Client (own profile) or their assigned trainer | Mark today's day as skipped |
| GET | `/workout-profiles/:profileId/sessions` | Bearer access | Client (own profile) or their assigned trainer | Paginated session history |

There is no separate "trainer" endpoint — same three routes serve both roles.

---

## 1. Complete a Session

Call this once, after the app has confirmed locally that every task for the day is done. The server resolves *which* day/week/program this is from the client's own progress cursor — you do not send `dayIndex`, `weekNumber`, or `weeklyPlanId` in the request; sending the wrong one is not possible by construction.

### Request
```http
POST /api/v1/workout-profiles/wp_abc123/sessions/complete
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "taskCompletions": [
    {
      "taskId": "task_001",
      "actualSets": 4,
      "actualReps": "10, 10, 8, 8",
      "actualWeightKg": 85.5,
      "notes": "Felt strong, could increase weight next week."
    },
    {
      "taskId": "task_002",
      "actualSets": 3,
      "actualReps": "12, 12, 10",
      "actualWeightKg": 20
    }
  ],
  "notes": "Great energy today, shoulder felt slightly tight but no pain."
}
```

`taskCompletions` is optional — omit it (or send `[]`) to log a plain completion with no per-task detail. `taskId` must belong to today's day plan; any id that doesn't returns `409 Conflict`.

### Response (201 Created)
```json
{
  "success": true,
  "data": {
    "id": "log_789",
    "workoutProfileId": "wp_abc123",
    "weeklyPlanId": "plan_456",
    "weeklyPlanName": "Push Pull Legs — Block 3",
    "dayPlanId": "day_003",
    "dayPlanLabel": "Push Day",
    "dayIndexAtTime": 3,
    "cycleNumberAtTime": 2,
    "status": "COMPLETED",
    "scheduledDate": null,
    "completedDate": "2026-07-11T06:32:10.000Z",
    "loggedByRole": "MEMBER",
    "loggedByUserId": "user_111",
    "currentDayIndexAfter": 4
  }
}
```

Read this as: **"Push Day" — day 3, week 2, of the "Push Pull Legs — Block 3" program**, logged by the member themselves. `currentDayIndexAfter` tells you what day the client is on now, so the app can immediately show "up next" without a second call.

If a trainer logs it instead, only `loggedByRole`/`loggedByUserId` differ:
```json
"loggedByRole": "TRAINER",
"loggedByUserId": "user_222"
```

---

## 2. Skip a Session

Same shape, no task completions, and the cursor does **not** advance (the client is still on the same day next time).

### Request
```http
POST /api/v1/workout-profiles/wp_abc123/sessions/skip
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "reason": "Sick / Travel / Rest required"
}
```
`reason` is optional.

### Response (201 Created)
```json
{
  "success": true,
  "data": {
    "id": "log_790",
    "workoutProfileId": "wp_abc123",
    "weeklyPlanId": "plan_456",
    "weeklyPlanName": "Push Pull Legs — Block 3",
    "dayPlanId": "day_003",
    "dayPlanLabel": "Push Day",
    "dayIndexAtTime": 3,
    "cycleNumberAtTime": 1,
    "status": "SKIPPED",
    "scheduledDate": null,
    "completedDate": "2026-07-11T06:32:10.000Z",
    "loggedByRole": "TRAINER",
    "loggedByUserId": "user_222",
    "currentDayIndexAfter": 3
  }
}
```
Note `currentDayIndexAfter` equals `dayIndexAtTime` here — the cursor didn't move.

---

## 3. List Session History

Paginated, most recent first. Useful for a progress/history screen or a trainer's client-adherence view.

### Request
```http
GET /api/v1/workout-profiles/wp_abc123/sessions?page=1&pageSize=20
Authorization: Bearer {accessToken}
```

| Query param | Type | Default | Notes |
|---|---|---|---|
| `page` | number | 1 | 1-indexed |
| `pageSize` | number | 20 | max 100 |

### Response (200 OK)
```json
{
  "success": true,
  "data": [
    {
      "id": "log_790",
      "workoutProfileId": "wp_abc123",
      "weeklyPlanId": "plan_456",
      "weeklyPlanName": "Push Pull Legs — Block 3",
      "dayPlanId": "day_003",
      "dayPlanLabel": "Push Day",
      "dayIndexAtTime": 3,
      "cycleNumberAtTime": 1,
      "status": "SKIPPED",
      "scheduledDate": null,
      "completedDate": "2026-07-11T06:32:10.000Z",
      "loggedByRole": "TRAINER",
      "loggedByUserId": "user_222"
    }
  ],
  "meta": { "total": 42, "page": 1, "pageSize": 20 }
}
```
`currentDayIndexAfter` is only present on the `complete`/`skip` responses, not in list results.

---

## 4. Data Structures

### CompleteWorkoutSessionDto
| Property | Type | Required | Description |
|---|---|---|---|
| `taskCompletions` | `TaskCompletionInputDto[]` | No | Per-task actuals for the day |
| `notes` | string | No | General session feedback |

### TaskCompletionInputDto
| Property | Type | Required | Description |
|---|---|---|---|
| `taskId` | string | Yes | Must belong to today's day plan |
| `actualSets` | number | No | Sets actually completed |
| `actualReps` | string | No | Free text — e.g. `"10, 10, 8, 8"` |
| `actualWeightKg` | number | No | Weight used, in kg |
| `notes` | string | No | Per-task feedback |

### SkipWorkoutSessionDto
| Property | Type | Required | Description |
|---|---|---|---|
| `reason` | string | No | Why the day was skipped |

### WorkoutSessionResponseDto
| Property | Type | Description |
|---|---|---|
| `id` | string | Session log id |
| `workoutProfileId` | string | The client's workout profile |
| `weeklyPlanId` | string | The program this day belongs to |
| `weeklyPlanName` | string | Program name, for display — no extra lookup needed |
| `dayPlanId` | string \| null | The specific day plan performed |
| `dayPlanLabel` | string \| null | e.g. `"Push Day"` — as it was at the time; may differ from the plan's current label if it was edited later |
| `dayIndexAtTime` | number | Template day position, 1–7 |
| `cycleNumberAtTime` | number | Which repetition of the 7-day cycle — "week N" of the program |
| `status` | enum | `SCHEDULED` \| `COMPLETED` \| `SKIPPED` \| `PARTIAL` |
| `scheduledDate` | string \| null | ISO date, if pre-scheduled |
| `completedDate` | string \| null | ISO date the log was written |
| `loggedByRole` | enum \| null | `MEMBER` \| `TRAINER` \| `STAFF` — who submitted this log |
| `loggedByUserId` | string \| null | The submitting user's id |
| `currentDayIndexAfter` | number | Only on `complete`/`skip` responses — the cursor's new value |

---

## 5. Enums

### SessionLogStatus
- `SCHEDULED` — not yet acted on (reserved for future auto-scheduling; not produced by these endpoints today)
- `COMPLETED` — logged via `/complete`
- `SKIPPED` — logged via `/skip`
- `PARTIAL` — reserved, not currently produced by these endpoints

### SessionLogActorRole
- `MEMBER` — the client logged their own session
- `TRAINER` — the assigned trainer logged it on the client's behalf
- `STAFF` — an admin logged it (not the client, not the assigned trainer)

---

## 6. Client Implementation (Flutter)

```dart
Future<Map<String, dynamic>> completeSession({
  required String profileId,
  required List<Map<String, dynamic>> taskCompletions,
  String? notes,
}) async {
  final token = await storage.read(key: 'accessToken');
  final response = await http.post(
    Uri.parse('$baseUrl/workout-profiles/$profileId/sessions/complete'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'taskCompletions': taskCompletions,
      if (notes != null) 'notes': notes,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body)['data'];
  }
  throw Exception('Failed to complete session: ${response.body}');
}
```

The same call works whether the token belongs to the member or their trainer — no client-side branching needed. Use the returned `currentDayIndexAfter` to advance whatever local "today's plan" state the app is showing, instead of re-deriving it from a local clock/counter.

---

## 7. Error Responses

| Status | Meaning |
|---|---|
| 400 | Validation failed (e.g., invalid `taskId` shape) |
| 401 | Missing or invalid Bearer token |
| 403 | Caller is neither the profile's client nor its assigned trainer/admin |
| 404 | Workout profile, or today's day plan, not found |
| 409 | No active weekly plan assigned to this profile, or a `taskId` doesn't belong to today's day plan |

---

## 8. Notes for Frontend

- **Day/week/program are never sent by the client** — they're always resolved server-side from the profile's cursor. Don't try to pass `dayIndex` or `weekNumber`; there's nowhere for them in the request DTOs.
- **`complete` always targets "today"** (the server's cursor), not an arbitrary past day. There is currently no backfill endpoint for logging a day that's no longer the current cursor — if a trainer needs to correct historical data, that's not yet supported by this API.
- A `SKIPPED` log does **not** advance `currentDayIndexAfter` — the client stays on the same day.
