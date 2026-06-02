# PlantApp — Real Full-Stack Device Test Report

- **Date:** 2026-06-02
- **Device:** Samsung SM-S928U1 (Galaxy S24 Ultra), Android 16 / SDK 36, adb `10.0.0.166:41027`
- **App under test:** `dev.plantapp.android` versionName `0.1.0`, versionCode `1`, minSdk 26, **targetSdk 35**, UID `10198`, installed/updated 2026-06-02 09:57:08 (LAN debug APK)
- **Backend (from host):** Supabase `http://10.0.0.179:54321` auth-health = **200**; Fastify `http://10.0.0.179:3000/plants` no-token = **401**; `plant-profiles` no-token = `{"error":"missing_bearer_token"}`; Mailpit `http://127.0.0.1:54324` = **200**.
- **Test email used:** `device-tester+1780419926@example.test`
- **OTP value used:** **none — never issued** (the request never left the device; see below).

## TL;DR

The end-to-end journey is **hard-blocked at Step 2 (Request OTP)** by an **app-side defect**, not a backend or network problem. The installed APK's manifest is **missing `android.permission.INTERNET`**. Android therefore denies the app process any network socket, and the very first backend call — `POST /auth/v1/otp` — fails instantly with `java.net.SocketException: socket failed: EPERM (Operation not permitted)`. The app surfaces this verbatim in red on the sign-in screen. No OTP was ever sent, so steps 3–11 (which all require a session token) are unreachable. Steps 1 and 12 (launch / relaunch stability) pass.

The backend is healthy and reachable: from the phone's own shell (a different UID that *does* have network), `curl http://10.0.0.179:54321/auth/v1/health` → **200** and `curl http://10.0.0.179:3000/plants` → **401**. So the fault is isolated to the app's missing INTERNET permission.

## Status table (Steps 1–12)

| # | Step | Status | Evidence |
|---|------|--------|----------|
| 1 | Launch + reach sign-in | **PASS** | Force-stop + launch, app focused, no crash, lands on "Sign in" with Email field + Send code button. F01-signin.png |
| 2 | Request OTP | **FAIL** | `--> POST http://10.0.0.179:54321/auth/v1/otp (68-byte body)` then `<-- HTTP FAILED: java.net.SocketException: socket failed: EPERM (Operation not permitted)`. UI shows red "socket failed: EPERM (Operation not permitted)". Root cause: app missing `INTERNET` permission. F02a, F02b. |
| 3 | Get code from Mailpit | **BLOCKED** | No email arrived for test address (request never left device). Mailpit `total:1` is a stale pre-existing message to `x@y.test`, not ours. |
| 4 | Verify OTP → list | **BLOCKED** | No code to enter; no `/auth/v1/verify`; no `GET /plants`. Depends on Step 2/3. |
| 5 | Notification permission | **N/A (observed)** | No dialog reachable (never past sign-in). State: `POST_NOTIFICATIONS: granted=true` already. |
| 6 | Add a plant via selectors | **BLOCKED** | Never reached authenticated UI. No `POST /plants`, no `GET /plant-profiles` from app. |
| 7 | Detail: CareTask + advisories | **BLOCKED** | Depends on Step 6. |
| 8 | Accept advisory → CareTask | **BLOCKED** | Depends on Step 7. No `POST /plants/:id/advisories/accept`. |
| 9 | Reminder scheduling | **BLOCKED** | No `plant-reminder` job in jobscheduler (only generic Android quota timers for the UID). Channel never created because scheduling path is gated behind auth. |
| 10 | Notification fires | **BLOCKED** | No job to run; no "Plant care reminder" notification. |
| 11 | Channel importance | **BLOCKED** | `dumpsys notification_manager | grep plant_care_reminders` → empty. Channel not created (lazily registered post-auth). |
| 12 | Stability (warm relaunch) | **PASS** | Relaunched, app re-focused, no FATAL / no `-b crash` entries from the app. F12-relaunch.png |

Legend: PASS = worked. FAIL = exercised and broke. BLOCKED = could not be exercised because an upstream step failed. N/A (observed) = step not reachable but its underlying state was still inspected.

## Per-step detailed evidence

### Step 1 — Launch + reach sign-in — PASS
- `am force-stop dev.plantapp.android` then `am start -n dev.plantapp.android/.MainActivity` → `Starting: Intent { cmp=dev.plantapp.android/.MainActivity }`.
- Window focus: `mCurrentFocus=Window{... dev.plantapp.android/dev.plantapp.android.MainActivity}`.
- Crash buffer (`logcat -b crash`) empty; no `FATAL`/`AndroidRuntime` from the app.
- UI tree: `TextView "Sign in"` [60,60][330,180]; `EditText` (Email) [60,225][1380,465]; clickable `Send code` container [60,510][1380,690] with `TextView "Send code"` [596,563][844,638].
- Screenshot: **F01-signin.png** (clean "Sign in" screen, Email field, purple Send code button).

### Step 2 — Request OTP — FAIL (root-cause defect)
- Tapped Email field (720,345), typed `device-tester+1780419926@example.test` (confirmed rendered in field — **F02a-email-entered.png**).
- Tapped Send code (720,600).
- **Verbatim logcat (the only two app network lines):**
  ```
  06-02 10:06:23.322 23391 23863 I okhttp.OkHttpClient: --> POST http://10.0.0.179:54321/auth/v1/otp (68-byte body)
  06-02 10:06:23.326 23391 23863 I okhttp.OkHttpClient: <-- HTTP FAILED: java.net.SocketException: socket failed: EPERM (Operation not permitted)
  ```
  Request fired once and failed 4 ms later at the socket layer — **no HTTP status returned** (no bytes left the device).
- **Verbatim UI error (red text on sign-in screen):** `socket failed: EPERM (Operation not permitted)` — **F02b-after-sendcode.png**.
- **Root cause (proven):** the installed package does **not** request `android.permission.INTERNET`. Full requested-permissions set per `dumpsys package dev.plantapp.android`:
  ```
  android.permission.POST_NOTIFICATIONS
  android.permission.FOREGROUND_SERVICE
  android.permission.RECEIVE_BOOT_COMPLETED
  android.permission.ACCESS_NETWORK_STATE
  android.permission.WAKE_LOCK
  ```
  `grep permission.INTERNET` → absent (`>>> INTERNET permission ABSENT from package <<<`). Without `INTERNET`, the Android kernel/netd denies `socket()` to the app's UID, producing exactly this `EPERM`. (The app does hold `ACCESS_NETWORK_STATE`, which only reads connectivity — it does **not** grant socket access.)
- **Network/backend exonerated:** from the phone's own shell (UID 2000, has network):
  ```
  auth-health=200   (curl http://10.0.0.179:54321/auth/v1/health)
  plants-notoken=401 (curl http://10.0.0.179:3000/plants)
  ```
  Backend + LAN + DNS/routing are all fine; only the app cannot open a socket.

### Step 3 — Get code from Mailpit — BLOCKED
- Polled Mailpit; `total:1` both before and after the tap. The single message is stale and for the wrong recipient:
  ```
  {"ID":"C9jyVmah4TAACoqsGJU2CA","From":{"Name":"Admin","Address":"admin@email.com"},
   "To":[{"Address":"x@y.test"}],"Subject":"Your Magic Link","Created":"2026-06-02T17:04:10.337Z",
   "Snippet":"... enter the code: 071768"}
  ```
  Recipient `x@y.test` ≠ our `device-tester+1780419926@example.test`; created before our tap. **No OTP was generated for our test** because the OTP request never reached Supabase. OTP value used downstream: **none**.

### Step 4 — Verify OTP → list — BLOCKED
- No code available; no `/auth/v1/verify` and no `GET 10.0.0.179:3000/plants` ever attempted by the app. Depends on Steps 2–3.

### Step 5 — Notification permission — N/A (state observed)
- No runtime dialog reachable (app never left sign-in). State already: `android.permission.POST_NOTIFICATIONS: granted=true` (USER_SENSITIVE flags present). Nothing to grant.

### Step 6 — Add a plant via selectors — BLOCKED
- Authenticated UI unreachable. No `POST /plants`, no `GET /plant-profiles` (catalog dropdown), no select-or-create for garden-space/container. Depends on Step 4.

### Step 7 — Detail: CareTask + advisories — BLOCKED
- No plant created; no water CareTask, no advisory rendered. Depends on Step 6.

### Step 8 — Accept advisory → CareTask — BLOCKED
- No advisory to accept; no `POST /plants/:id/advisories/accept`. Depends on Step 7.

### Step 9 — Reminder scheduling — BLOCKED
- `dumpsys jobscheduler | grep -A6 dev.plantapp` shows only generic Android quota/anr/timeout timers for UID 10198 (`::timeout-reg`, `::.schedulePersisted()`, `::anr`, `::timeout-total`) — **no `plant-reminder` job** (`countInWindow=0` everywhere). WorkManager diagnostics broadcast yields no enqueued plant-reminder work. The reminder-scheduling code path is gated behind a successful sign-in, which never occurred.

### Step 10 — Notification fires — BLOCKED
- No job id to run; no "Plant care reminder" notification posted. `dumpsys notification --noredact` shows nothing for the app.

### Step 11 — Channel importance — BLOCKED
- `dumpsys notification_manager | grep -i plant_care_reminders` → **empty**. The `plant_care_reminders` channel does not exist; it is created lazily by the post-auth scheduling path, which was never reached.

### Step 12 — Stability (warm relaunch) — PASS
- `am start -n dev.plantapp.android/.MainActivity` (warm) → re-focused: `mCurrentFocus=Window{... dev.plantapp.android/.MainActivity}`. No app `FATAL`/crash (the `AndroidRuntime` lines in logcat are uiautomator's own VM, uid 2000). Screenshot **F12-relaunch.png**.

## Screenshot inventory
- `reviews/device-evidence/F01-signin.png` — sign-in screen (Step 1).
- `reviews/device-evidence/F02a-email-entered.png` — test email typed into Email field (Step 2).
- `reviews/device-evidence/F02b-after-sendcode.png` — red "socket failed: EPERM (Operation not permitted)" after Send code (Step 2).
- `reviews/device-evidence/F12-relaunch.png` — warm relaunch (Step 12).

## Overall summary

**How far the real end-to-end journey got:** It reached the sign-in screen and successfully *attempted* the OTP request — and stopped there. The journey covered Step 1 (PASS) and Step 2 (FAIL); Step 12 (PASS) was verified independently. Steps 3–11 are all BLOCKED downstream of the Step 2 failure.

**Every HTTP status observed:**
- `POST /auth/v1/otp` (from app): **no HTTP status** — `SocketException: socket failed: EPERM` before any bytes sent.
- `/auth/v1/verify`: **never attempted**.
- `GET /plants` (from app): **never attempted**.
- `GET /plant-profiles` (from app): **never attempted**.
- `POST /plants/:id/advisories/accept`: **never attempted**.
- Control probes (NOT from the app): host → `auth/v1/health` **200**, host → `/plants` **401**, host → `/plant-profiles` 401-equivalent (`missing_bearer_token`); phone-shell → `auth/v1/health` **200**, phone-shell → `/plants` **401**. These confirm the backend is healthy and the LAN is reachable from the device — the failure is purely the app.

**Did a reminder notification actually appear on the device?** **No.** No `plant-reminder` job was ever scheduled, the `plant_care_reminders` channel was never created, and no notification was posted. (Unreachable behind sign-in.)

**Bug / crash (verbatim):** No crash. One blocking functional defect:

> The installed APK `dev.plantapp.android` v0.1.0 is **missing `android.permission.INTERNET`** in its manifest. All app network I/O fails with:
> `java.net.SocketException: socket failed: EPERM (Operation not permitted)`
> surfaced in the UI as `socket failed: EPERM (Operation not permitted)`.

**Recommended fix (for the implementation repo, not done here):** add `<uses-permission android:name="android.permission.INTERNET"/>` to the Android manifest, rebuild the debug APK, reinstall, and re-run this journey. (No PlantApp edit/build/install of a new APK was performed by this QA pass per the read-only boundary; the already-installed APK was used as instructed.)
