# Device Test Report — Full-Stack Journey (post INTERNET-permission fix)

- **Date:** 2026-06-02
- **Device:** Samsung SM-S928U1, Android 16 / SDK 36 (`adb -s 10.0.0.166:41027`)
- **App:** `dev.plantapp.android/.MainActivity` (freshly installed; API→`http://10.0.0.179:3000/`, auth→`http://10.0.0.179:54321/`, cleartext on, INTERNET granted)
- **Backend (pre-flight from host):** Supabase `/auth/v1/health` → **200**; Fastify `/plants` no-token → **401**; Mailpit `/api/v1/messages` → **200**; `/plant-profiles` no-token → **401** (auth-gated). All confirmed UP.
- **OTP email used:** `device-tester+1780420429@example.test`
- **OTP code used:** `941505`
- **Plant id created:** `9b511a20-abbc-48b3-8f1e-28602d2f41fa`

## Status table (steps 1–12)

| # | Step | Status | Key evidence |
|---|------|--------|--------------|
| 1 | Launch (force-stop first), sign-in screen, no crash | **PASS** | Focused `MainActivity`, "Sign in"/"Email"/"Send code" rendered. G01 |
| 2 | Request OTP — `POST /auth/v1/otp` | **PASS** | OkHttp `<-- 200 OK …/auth/v1/otp (147ms)`. No EPERM. G02a/G02b |
| 3 | Mailpit fetch + extract 6-digit code | **PASS** | Code `941505`; "Alternatively, enter the code: 941505" |
| 4 | Verify — `POST /auth/v1/verify` + `GET /plants` + nav | **PASS** | verify `<-- 200 OK (39ms)`; `GET /plants <-- 200 OK (2-byte body)` empty state. G04a–G04c |
| 5 | POST_NOTIFICATIONS permission | **PASS (already granted)** | `POST_NOTIFICATIONS: granted=true`. No runtime dialog shown (granted at install). |
| 6 | Add plant via selectors (profile/container/space) | **PASS** | `/plant-profiles 200 (2562b, non-empty)`; `POST /containers 201`; `POST /garden-spaces 201`; `POST /plants 201 (1123b)`. G06a–G06l |
| 7 | Detail — water CareTask + container-size advisory | **PASS** | Task "Next: water / Due Jun 3, 2026 / engine v0.1.0"; HIGH "Container is smaller than recommended". G07 |
| 8 | Accept advisory — `POST …/advisories/accept` | **PASS** | `<-- 201 Created (959b)`; tasks reload 830b→**1790b** (new task added). G08a/G08b |
| 9 | Reminder scheduling (WorkManager / jobscheduler) | **FAIL (feature absent)** | WM diagnostics list **only DiagnosticsWorker**; no `plant-reminder` work; no named reminder job in jobscheduler; no app alarm in AlarmManager. |
| 10 | Notification fires | **BLOCKED (no job/feature)** | No reminder job to run; `dumpsys notification` shows **0 posted notifications** for the app. |
| 11 | Channel `plant_care_reminders` importance | **FAIL (absent)** | No notification channel registered for `dev.plantapp.android`; `plant_care_reminders` not found. |
| 12 | Warm relaunch, no crash | **PASS** | Relaunched to Plant detail, session persisted, no FATAL. G12 |

## Per-step verbatim evidence

### Step 1 — Launch
`mCurrentFocus=Window{… dev.plantapp.android/dev.plantapp.android.MainActivity}`; no FATAL/AndroidRuntime in logcat. Sign-in UI: `text="Sign in"`, `text="Email"`, `text="Send code"`. Screenshot **G01-launch-signin.png**.

### Step 2 — Request OTP (THE INTERNET-FIX CHECK)
```
10:14:08.509 I okhttp.OkHttpClient: --> POST http://10.0.0.179:54321/auth/v1/otp (68-byte body)
10:14:08.657 I okhttp.OkHttpClient: <-- 200 OK http://10.0.0.179:54321/auth/v1/otp (147ms, 2-byte body)
```
**200 OK, no EPERM / SocketException / permission denial.** The INTERNET-permission bug is fixed. Screenshots **G02a-email-entered.png**, **G02b-code-sent.png**.

### Step 3 — Mailpit
Message ID `QxRGk88kcFS8KvfKvMiMPY`, Subject "Your Magic Link", To `device-tester+1780420429@example.test`. Raw body snippet:
```
Alternatively, enter the code: 941505
```
Code = **941505**.

### Step 4 — Verify + first /plants
```
10:15:11.874 --> POST http://10.0.0.179:54321/auth/v1/verify (81-byte body)
10:15:11.914 <-- 200 OK …/auth/v1/verify (39ms, unknown-length body)   <-- token issued
10:15:11.974 --> GET http://10.0.0.179:3000/plants
10:15:12.090 <-- 200 OK …/plants (115ms, 2-byte body)                   <-- [] empty state
```
Navigated to "My plants" → "No plants yet. Tap + to add your first plant." Screenshots **G04a-verify-screen.png**, **G04b-code-entered.png**, **G04c-plant-list-empty.png**.

### Step 5 — Notification permission
`android.permission.POST_NOTIFICATIONS: granted=true`. No runtime permission dialog appeared (granted at install time). State recorded.

### Step 6 — Add plant (selectors + select-or-create)
- `GET /plant-profiles <-- 200 OK (62ms, 2562-byte body)` — **non-empty**. Dropdown listed all 5 catalog species: **Strawberry, Basil, Passion fruit, Tomatillo, Tomato**.
- Selected **Passion fruit** → subtitle "Passiflora edulis".
- Container select-or-create: only "➕ Create new container" present → created name **Pot**, volume **19**, material **plastic**, drainage **good**:
  `POST /containers <-- 201 Created (154ms, 246-byte body)`.
- Garden space select-or-create: created name **Balcony**, kind **balcony**:
  `POST /garden-spaces <-- 201 Created (67ms, 189-byte body)`.
- Growth stage set to **vegetative**.
- Submit:
```
10:20:05.542 --> POST http://10.0.0.179:3000/plants (168-byte body)
10:20:05.626 <-- 201 Created …/plants (83ms, 1123-byte body)
10:20:05.676 --> GET …/plants                        <-- 200 OK (330b, now non-empty)
10:20:05.732 --> GET …/plants/9b51…/tasks            <-- 200 OK (830b)
10:20:05.783 --> GET …/plants/9b51…/advisories       <-- 200 OK (692b)
```
NB: a one-time typing-into-wrong-field glitch occurred (keyboard overlay caused concatenated text in the volume field); it was cleared and re-entered correctly before submission — **no app bug**, a UI-automation artifact. Screenshots **G06a**…**G06l**.

### Step 7 — Detail render
- **CareTask:** "Next: water", "Due Jun 3, 2026", rationale "Passion fruit: base interval 3d adjusted by container factor 0.5; baseline 2026-06-02T17:20:05.568Z", engine badge **"engine v0.1.0"**.
- **Container-size advisory (provoked by 19 L):** "HIGH · Container is smaller than recommended — Passion fruit prefers at least 95 L (ideal 95–190 L); this container is 19 L. Move it to a larger container of that target size."
- Bonus advisory: "MEDIUM · Needs support — Passion fruit needs a trellis, stake, or cage…".
Screenshot **G07-detail-task-advisory.png**.

### Step 8 — Accept advisory
```
10:20:34.491 --> POST http://10.0.0.179:3000/plants/9b51…/advisories/accept (25-byte body)
10:20:34.555 <-- 201 Created …/advisories/accept (64ms, 959-byte body)
10:20:34.612 --> GET …/plants/9b51…/tasks  <-- 200 OK (1790-byte body)   <-- grew from 830b: new task created
```
The tasks payload grew 830b → 1790b after accept, confirming a new task (repot, per spec) was created server-side. The detail "Next" slot continues to show the more-imminent water task (Jun 3); both advisory cards remain rendered (this build keeps the advisory card visible after accept rather than removing it). Screenshots **G08a-after-accept.png**, **G08b-detail-scrolled.png**.

### Step 9 — Reminder scheduling — FAIL (feature absent)
`am broadcast androidx.work.diagnostics.REQUEST_DIAGNOSTICS -p dev.plantapp.android` → `Broadcast completed: result=0`. WorkManager diagnostics dump (verbatim):
```
WM-DiagnosticsWrkr: Recently completed work:
  503f39aa… DiagnosticsWorker  SUCCEEDED  Tags: androidx.work.impl.workers.DiagnosticsWorker
  6b09ac8a… DiagnosticsWorker  SUCCEEDED  Tags: androidx.work.impl.workers.DiagnosticsWorker
WM-DiagnosticsWrkr: Running work:
  ad71a1d1… DiagnosticsWorker  RUNNING    Tags: androidx.work.impl.workers.DiagnosticsWorker
```
The **only** WorkManager work present is the diagnostics worker itself. `dumpsys jobscheduler | grep dev.plantapp` shows just `androidx.work.impl.background.systemjob.SystemJobService` (the diagnostics job `841b30c #u0a198/1`) — **no `plant-reminder` job**. `dumpsys alarm | grep dev.plantapp` — **no app reminder alarm**. The reminder-scheduling feature is not implemented in this build.

### Step 10 — Notification fires — BLOCKED
No reminder jobId exists to `cmd jobscheduler run`. `dumpsys notification --noredact` for the app shows `AppSettings: dev.plantapp.android importance=DEFAULT` but **zero posted notifications**. No "Plant care reminder" notification was or could be produced.

### Step 11 — Channel — FAIL (absent)
`dumpsys notification_manager | grep -i plant_care_reminders` → **no match**. No notification channel of any id is registered for `dev.plantapp.android` (the app has never created a channel). Importance: n/a.

### Step 12 — Warm relaunch
Home → relaunch (no force-stop). No FATAL/ANR. Focus returned to `MainActivity`; restored to Plant detail with task + advisories intact (session persisted). Screenshot **G12-warm-relaunch.png**.

## Overall summary

**How far it got:** The full **authenticated, full-stack online journey ran end-to-end through step 8** — sign-in via real email OTP, JWT verify, plant-list load, catalog-backed add-plant with select-or-create of container and garden space, deterministic care-task + advisory render, and advisory accept — all against the live Supabase + Fastify backend. Steps 9–11 (reminder scheduling, on-device notification firing, notification channel) **could not pass because that feature is not present in this build**. Step 12 (warm relaunch) passed.

**The INTERNET-permission bug is FIXED and verified:** the previously-failing `POST /auth/v1/otp` now returns **200 OK** with no EPERM — networking from the device works.

**Every HTTP status (verbatim):**
- `POST /auth/v1/otp` → **200**
- `POST /auth/v1/verify` → **200**
- `GET /plants` (first, empty) → **200** (`[]`)
- `GET /plant-profiles` → **200** (2562 bytes, non-empty, 5 species)
- `POST /containers` → **201**
- `POST /garden-spaces` → **201**
- `POST /plants` → **201**
- `GET /plants/{id}/tasks` → **200** (830b pre-accept → 1790b post-accept)
- `GET /plants/{id}/advisories` → **200** (692b)
- `POST /plants/{id}/advisories/accept` → **201**

**Care task rendered?** YES — water task, due Jun 3 2026, with rationale and "engine v0.1.0" badge.
**Advisory rendered?** YES — the provoked HIGH "Container is smaller than recommended" (95 L recommended vs 19 L), plus a MEDIUM "Needs support" advisory. Accept returned 201 and created a new task server-side (tasks payload grew 830→1790 bytes).

**Did a reminder notification actually appear on the device?** **NO.** No `plant-reminder` WorkManager job, no jobscheduler reminder job, no AlarmManager alarm, no notification channel, and zero posted notifications for the app. Reminder/notification scheduling is not implemented in this build. POST_NOTIFICATIONS is granted, so the absence is feature-not-built, not a permission block.

**Bugs / crashes:** No crashes, ANRs, or FATAL exceptions anywhere (cold launch, journey, warm relaunch all clean). No backend 5xx observed. The only anomaly is the **missing reminder/notification feature** (steps 9–11). One non-app UI-automation artifact (concatenated text in the volume field due to keyboard overlay) was self-corrected before submit.

---

## PLANNER ADDENDUM (2026-06-02, post-run correction of steps 9–11)

Steps 9–11 were marked FAIL/BLOCKED in the run above **only because the journey never returned to
the plant LIST after adding the plant** — `ReminderSync` runs on the list screen's load
(app-open), so it never saw the new tasks. On a **cold start back to the list** (force-stop →
launch → signed-in → LIST), the planner verified the reminder path **WORKS end-to-end**:

- WorkManager diagnostics show two `ReminderWorker` / `plant-reminder` works:
  - `reminder-934ac56e-…` → **SUCCEEDED** (the accepted *repot* task, dueAt≈now → ran immediately),
  - `reminder-e2ce038f-…` → **ENQUEUED** (the *water* task, dueAt=Jun 3 → future delay).
- A notification is **posted + active**: `NotificationRecord pkg=dev.plantapp.android
  channel=plant_care_reminders` (`cmd notification list` shows its key); the
  `plant_care_reminders` channel is registered (importance DEFAULT). Shade screenshot:
  `device-evidence/H-reminder-shade.png`.

**Corrected verdict: steps 9–11 PASS.** The full local reminder path (computeReminders →
ReminderScheduler → ReminderWorker → notification on `plant_care_reminders`) is functional on the
real device.

**Tracked UX note (not a bug):** reminders (re)schedule on **app-open / list-load**, not
immediately after add/accept. A user who adds a plant and never revisits the list won't get a
reminder scheduled until the next app open. Acceptable for the Slice-3 "schedule on app open"
design; candidate follow-up = also trigger a sync after add-plant / accept.
