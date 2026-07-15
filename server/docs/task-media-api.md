# Task Media Library API

Backend reference for building the frontend (Flutter `gym/`, React `owner/`) against the
reusable, searchable **Task Media** library and its attachment to workout tasks.

## Concept model

```
Task ──1:N──> TaskAttachment ──N:1──> TaskMedia ──1:1──> Media (object storage)
              (join row per            (reusable, searchable        (storageKey +
               media-on-a-task:         library item:                mimeType; URL is
               caption, order)          name/desc/keywords,          resolved fresh on
                                        isPrivate, type)             every read)
```

- **Media** — one uploaded file (image / gif / video) in object storage. The DB stores a
  `storageKey`, never a permanent URL. A usable `url` is resolved on every read (a signed,
  expiring URL when the protected S3 driver is active). **Never persist a `url`** returned by
  these endpoints — re-fetch to get a fresh one.
- **TaskMedia** — a reusable library entry wrapping exactly one `Media`, plus searchable
  metadata (`name`, `description`, `keywords`) and an `isPrivate` flag. Created **once**; then
  referenced from any number of tasks.
- **TaskAttachment** — links one `Task` to one library `TaskMedia`, with a per-attachment
  `caption` and `sequenceIndex`. A task can have many attachments; the same `TaskMedia` can be
  attached to many tasks.

## Conventions

- **Base URL**: all paths below are under the global prefix `/api/v1`.
- **Auth**: every endpoint requires `Authorization: Bearer <accessToken>`. All Task-Media and
  attachment endpoints additionally require a trainer-ish role: `trainer`, `staff`, `manager`,
  `owner`, or `admin`. A member-only token gets `403`.
- **Success envelope**:
  - Single resource: `{ "success": true, "data": <object> }`
  - Paginated list: `{ "success": true, "data": <array>, "meta": { "total", "page", "pageSize" } }`
  - Delete: `{ "success": true }`
- **Error envelope** (NestJS default): `{ "message": string | string[], "error": string, "statusCode": number }`.
- **Enums**:
  - `TaskMediaType`: `"IMAGE" | "GIF" | "VIDEO"` (inferred server-side from the uploaded file's
    MIME type — `image/gif` → `GIF`, other `image/*` → `IMAGE`, `video/*` → `VIDEO`; anything else
    is rejected `400`).
  - `MediaVisibility`: `"PUBLIC" | "PROTECTED"` (internal; task media is always `PROTECTED`).

## Shared response shapes

### `TaskMedia` object

```jsonc
{
  "id": "clx...",              // string
  "type": "VIDEO",             // TaskMediaType
  "name": "Barbell Squat Demo",
  "description": "Side-angle full rep" | null,
  "keywords": ["squat", "legs", "barbell"],   // string[]
  "isPrivate": false,
  "createdById": "user-uuid",  // uploader's user id
  "url": "http://.../uploads/ab12.mp4",        // freshly resolved; do NOT persist
  "createdAt": "2026-07-14T10:00:00.000Z",
  "updatedAt": "2026-07-14T10:00:00.000Z"
}
```

### `TaskAttachment` object

```jsonc
{
  "id": "cly...",
  "taskId": "task-cuid",
  "taskMediaId": "clx...",
  "caption": "Watch knee tracking" | null,
  "sequenceIndex": 1,          // 1-based order within the task
  "createdAt": "2026-07-14T10:05:00.000Z",
  "taskMedia": { /* TaskMedia object above, with a fresh url */ }
}
```

---

## 1. Upload a new library item

Creates a `Media` (file upload) + a `TaskMedia` (metadata) in one call. **Not** attached to any
task — attaching is a separate step (see §6 / §8).

```
POST /api/v1/task-media
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Form fields**

| field         | type            | required | notes |
|---------------|-----------------|----------|-------|
| `file`        | file            | yes      | image, gif, or video. Max 25 MB. |
| `name`        | string          | yes      | max 160 chars |
| `description` | string          | no       | |
| `keywords`    | string          | no       | comma-separated (`"squat,legs"`) or repeated field. Stored lowercased, trimmed, de-duplicated. |
| `isPrivate`   | boolean-ish     | no       | `"true"`/`"false"`/`"1"`; default `false`. |

**Response** `201`

```json
{ "success": true, "data": { /* TaskMedia object */ } }
```

**Errors**: `400` (no file / unsupported MIME / validation), `401`, `403`.

---

## 2. Search the library

```
GET /api/v1/task-media?search=<text>&mine=<bool>&page=<n>&pageSize=<n>
Authorization: Bearer <token>
```

**Query params**

| param      | type    | default | notes |
|------------|---------|---------|-------|
| `search`   | string  | —       | matches `name`/`description` (case-insensitive `contains`) OR any `keywords` token. |
| `mine`     | boolean | false   | `true` restricts to items created by the caller. |
| `page`     | int ≥1  | 1       | |
| `pageSize` | int ≥1  | 20      | |

**Visibility rule**: results always include the caller's own items plus other trainers'
**non-private** items. Another trainer's `isPrivate: true` items never appear unless `createdById`
is the caller.

**Response** `200`

```json
{
  "success": true,
  "data": [ { /* TaskMedia object */ }, ... ],
  "meta": { "total": 42, "page": 1, "pageSize": 20 }
}
```

---

## 3. Edit a library item

```
PATCH /api/v1/task-media/:id
Authorization: Bearer <token>
Content-Type: application/json
```

**Body** (all optional; only provided fields change)

```jsonc
{
  "name": "New name",
  "description": "…",
  "keywords": ["a", "b"],   // or comma-separated string; replaces the whole list
  "isPrivate": true
}
```

**Authorization**: only the creator or an admin. Others get `403`.

**Response** `200`: `{ "success": true, "data": { /* TaskMedia object */ } }`

**Errors**: `403`, `404`.

---

## 4. Delete a library item

```
DELETE /api/v1/task-media/:id
Authorization: Bearer <token>
```

Deletes the `TaskMedia` and its backing `Media`. Any `TaskAttachment` rows referencing it are
cascade-removed (so it also disappears from every task it was on). Creator or admin only.

**Response** `200`: `{ "success": true }` — **Errors**: `403`, `404`.

---

## 5. Attach an existing library item to a task

Links an already-existing `TaskMedia` to a specific task. `sequenceIndex` is auto-assigned
(appended to the end).

```
POST /api/v1/tasks/:taskId/attachments
Authorization: Bearer <token>
Content-Type: application/json
```

**Body**

```jsonc
{
  "taskMediaId": "clx...",     // required — an existing library item id
  "caption": "Front view"      // optional per-attachment caption
}
```

**Authorization**: caller must be the assigned trainer for the task's workout profile (or admin),
and the `taskMediaId` must be usable by the caller (own item, or a non-private item) — otherwise
`400`/`403`.

**Response** `201`: `{ "success": true, "data": { /* TaskAttachment object */ } }`

**Errors**: `400` (media id doesn't exist), `403`, `404` (task not found).

---

## 6. Detach media from a task

Removes the link only — the library `TaskMedia` and its `Media` survive for reuse elsewhere.
Remaining attachments on the task are re-sequenced to stay contiguous.

```
DELETE /api/v1/task-attachments/:id
Authorization: Bearer <token>
```

**Response** `200`: `{ "success": true }` — **Errors**: `403`, `404`.

---

## 7. Weekly-plan creation with attachments (primary authoring path)

When building a weekly plan, each task carries **references** to existing library items via an
`attachments` array (the library item must already exist — this endpoint never creates
`TaskMedia`). This replaces the old inline `media: [{ type, url }]` shape.

```
POST /api/v1/workout-profiles/:profileId/weekly-plans
Authorization: Bearer <token>
Content-Type: application/json
```

**Body** (`CreateWeeklyPlan`)

```jsonc
{
  "name": "Hypertrophy Cycle Phase 1",
  "notes": "…",                    // optional
  "activateImmediately": false,    // optional, default false
  "days": [                        // 0..7 entries; dayIndex 1..7, unique
    {
      "dayIndex": 1,
      "label": "Leg Day",          // optional
      "isRestDay": false,
      "tasks": [                   // required when !isRestDay
        {
          "sequenceIndex": 1,
          "name": "Barbell Back Squat",
          "description": "…",      // optional
          "machineDetails": "…",   // optional
          "notes": "…",            // optional
          "sets": 4,
          "reps": "8-12",
          "restSeconds": 90,       // optional
          "tempo": "3-0-1-0",      // optional
          "attachments": [         // optional — references to library TaskMedia
            {
              "taskMediaId": "clx...",   // required, must exist & be usable
              "caption": "Side view",     // optional
              "sequenceIndex": 1          // 1-based order within the task
            }
          ]
        }
      ]
    }
  ]
}
```

**Validation**: every `taskMediaId` across all days/tasks must exist and be usable by the caller;
otherwise the **entire request** fails (`400`/`403`) — nothing is created.

**Response** `201`: `{ "success": true, "data": <WeeklyPlan> }` where each task exposes
`attachments: TaskAttachment[]` (each with a nested `taskMedia` carrying a fresh `url`):

```jsonc
{
  "success": true,
  "data": {
    "id": "plan-cuid",
    "workoutProfileId": "wp-cuid",
    "name": "Hypertrophy Cycle Phase 1",
    "status": "UPCOMING",          // ACTIVE | UPCOMING | ARCHIVED
    "effectiveFrom": null,
    "effectiveTo": null,
    "createdById": "user-uuid",
    "notes": null,
    "days": [
      {
        "id": "dp-cuid",
        "weeklyPlanId": "plan-cuid",
        "dayIndex": 1,
        "label": "Leg Day",
        "isRestDay": false,
        "tasks": [
          {
            "id": "task-cuid",
            "dayPlanId": "dp-cuid",
            "sequenceIndex": 1,
            "name": "Barbell Back Squat",
            "description": null,
            "machineDetails": null,
            "notes": null,
            "sets": 4,
            "reps": "8-12",
            "restSeconds": 90,
            "tempo": "3-0-1-0",
            "attachments": [ { /* TaskAttachment object */ } ],
            "createdAt": "…",
            "updatedAt": "…"
          }
        ],
        "createdAt": "…",
        "updatedAt": "…"
      }
    ],
    "createdAt": "…",
    "updatedAt": "…"
  }
}
```

> The same nested `attachments` shape appears in every read of a plan/day/task:
> `GET /weekly-plans/:id`, `GET /day-plans/:id`, and the "today's plan" endpoint
> (`GET /workout-profiles/:profileId/today` → day plan whose `tasks[].attachments[]` include a
> resolved `taskMedia.url`). Individual task create/update also accept the same optional
> `attachments` array on `TaskInput`.

---

## 8. Typical frontend flows

**Attach media while authoring a plan**
1. `GET /task-media?search=squat` → let the trainer pick, or
2. `POST /task-media` (multipart) to upload a new one → get its `data.id`.
3. Include `{ taskMediaId, caption?, sequenceIndex }` in the task's `attachments` when calling
   `POST /workout-profiles/:profileId/weekly-plans`.

**Manage an existing task's media**
- Add: `POST /tasks/:taskId/attachments { taskMediaId }`.
- Remove: `DELETE /task-attachments/:attachmentId`.

**Render media**: always use the `url` from the latest response. Under the protected S3 driver it
is a short-lived signed URL — re-fetch the resource rather than caching the URL long-term.

## 9. Generic upload endpoint (unchanged for existing callers)

`POST /api/v1/media/upload` (multipart, field `file`) still exists for **public** assets
(avatars, logos). It now returns the media record plus a resolved `url`:
`{ id, storageKey, mimeType, sizeBytes, visibility: "PUBLIC", createdById, createdAt, url }`.
Existing callers that read `data.url` continue to work; the `url` is stable/persistable for
`PUBLIC` media. Prefer the dedicated `POST /task-media` for anything that should be searchable and
reusable on tasks.
