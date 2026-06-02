# PlantApp — On-Device Full-Stack Test Report (2026-06-02)

**Device:** Samsung SM-S928U1 (Galaxy S24 Ultra), Android **16** / SDK **36**, wireless adb `10.0.0.166:41027` (transport_id 3, product e3quew).
**Host LAN IP:** `10.0.0.179` (device→host ping OK, ~8–92 ms).
**APK under test (pre-built, NOT rebuilt):** `/home/israel/Documents/Development/PlantApp/android/app/build/outputs/apk/debug/app-debug.apk` — size 11,881,257 bytes, mtime **2026-06-02 09:05:56 -0700**.
**App id:** `dev.plantapp.android` · versionName **0.1.0** · versionCode 1 · minSdk 26 · **targetSdk 35** · launcher `dev.plantapp.android/.MainActivity`.
**Evidence dir:** `/home/israel/Documents/Development/PlantAppPlanner/reviews/device-evidence/`.

## Status table

| ID | Name | STATUS | Evidence |
|----|------|--------|----------|
| T0 | Environment & connection | **PASS** | Device `device` state; SM-S928U1 / rel 16 / SDK 36; host 10.0.0.179; APK exists (mtime 09:05:56). |
| T1 | Install | **PASS** | `install -r -g` → `Success`; `pm list packages --user 0` shows `dev.plantapp.android`. |
| T2 | Cold launch + gating | **PASS** | COLD launch 643 ms; no FATAL/AndroidRuntime; lands on **Sign in** screen. `T02-cold-launch.png`. |
| T3 | Sign-in screen UI | **PASS** | Email EditText `[60,225][1380,465]` + "Send code" Button `[60,510][1380,690]` visible. `T03-signin-ui.png`. |
| T4 | Request OTP | **BLOCKED** | `POST http://10.0.2.2:54321/auth/v1/otp` → `java.net.UnknownServiceException: CLEARTEXT communication to 10.0.2.2 not permitted by network security policy`; same text shown in-app. `T04-*.png`. |
| T5 | Verify OTP → plant list | **BLOCKED** | Behind T4 — no OTP can be sent, no code to verify, no token, list never reached. |
| T6 | Add-plant selectors | **BLOCKED** | Behind backend/T5 — list screen unreachable; `GET /plant-profiles` never issued. |
| T7 | Detail: care task + advisories + Accept | **BLOCKED** | Behind backend/T6 — no plant exists; detail/advisory/Accept unreachable. |
| T8 | Reminder scheduling | **BLOCKED** (partial PASS of WM infra) | WorkManager initialized & functional (DiagnosticsWorker ran SUCCESS) but **no `plant-reminder` work** — `ReminderSync` is post-sign-in, blocked behind T4. |
| T9 | Runtime notification permission | **BLOCKED** (perm granted at install) | `POST_NOTIFICATIONS granted=true` (via `-g` install). In-app runtime dialog fires in the LIST route (post-sign-in) → not exercised; blocked behind T4. |
| T10 | Notification fires | **BLOCKED** | Behind T8 — no `plant-reminder` job exists to force-run; nothing to post. |
| T11 | Notification channel | **BLOCKED** | `plant_care_reminders` channel **not yet created** (created on first reminder path run, post-sign-in). App-level importance DEFAULT. |
| T12 | Stability / teardown | **PASS** | Warm/HOT restart 40 ms, same pid, no crash; state preserved. App left installed. `T12-warm-start.png`. |

---

## Per-test detail

### T0 — Environment & connection — PASS
```
$ adb devices -l
10.0.0.166:41027  device product:e3quew model:SM_S928U1 device:e3q transport_id:3
$ adb -s … shell getprop ro.product.model   → SM-S928U1
$ … getprop ro.build.version.release         → 16
$ … getprop ro.build.version.sdk             → 36
host IP: 10.0.0.179
$ … shell ping -c 2 10.0.0.179 → 2 replies, time 7.97 ms / 91.6 ms (device can reach host on LAN)
APK: -rw-rw-r-- 11881257 bytes  2026-06-02 09:05:56.850 -0700
```

### T1 — Install — PASS
```
$ adb -s … install -r -g …/app-debug.apk
Performing Streamed Install
Success
$ adb -s … shell pm list packages --user 0 | grep dev.plantapp
package:dev.plantapp.android
```
No warnings. dumpsys: versionName=0.1.0, versionCode=1, minSdk=26, **targetSdk=35**, firstInstallTime/lastUpdateTime 2026-06-02 09:29:34.

### T2 — Cold launch + gating — PASS
```
$ adb -s … shell am force-stop dev.plantapp.android
$ adb -s … shell am start -W -n dev.plantapp.android/.MainActivity
Status: ok   LaunchState: COLD   TotalTime: 643   WaitTime: 644
pid = 8622
$ adb -s … logcat -d -b crash | grep -iE "FATAL|AndroidRuntime|dev.plantapp"  → (empty, no crash)
```
Screen: **"Sign in"** title, Email field, "Send code" button — i.e. fresh install → no token → SIGN_IN start destination, as expected. Screenshot `T02-cold-launch.png`. Benign noise only in log (qdgralloc interlaced-flag warnings, ProfileInstaller install, `com.google.android.as.oss REPLACED` ActivityThread notes — all unrelated to the app).

### T3 — Sign-in screen UI — PASS
uiautomator hierarchy (Compose strips testTags from the a11y tree, so `resource-id` is empty, but labels match the expected `field_signin_email` / `signin_send_code_button`):
- TextView "Sign in" `[60,60][330,180]`
- **EditText** (email) `[60,225][1380,465]`, clickable+focusable, child hint "Email"
- **Button** "Send code" `[60,510][1380,690]`, clickable
Screenshot `T03-signin-ui.png`.

### T4 — Request OTP — BLOCKED (network / build-time wiring), with a refined root cause
Drove the UI: tapped email field, typed `tester@example.test` (field accepted it), tapped "Send code". The button is responsive and fires the call. **Verbatim logcat (OkHttp):**
```
06-02 09:30:18.825  8622  9641 I okhttp.OkHttpClient: --> POST http://10.0.2.2:54321/auth/v1/otp (50-byte body)
06-02 09:30:18.830  8622  9641 I okhttp.OkHttpClient: <-- HTTP FAILED: java.net.UnknownServiceException: CLEARTEXT communication to 10.0.2.2 not permitted by network security policy
```
**On-screen `signin_error` (verbatim):** "CLEARTEXT communication to 10.0.2.2 not permitted by network security policy" (`T04-after-send.png`).

**Refinement vs. the suite's prediction:** the suite expected a connect failure (no route to host / connect timeout) to `10.0.2.2:54321`. The real failure is **earlier**: Android's default network-security policy blocks **cleartext HTTP**, so the request fails with `java.net.UnknownServiceException` **before any socket is opened** — it is not a `ConnectException`/`UnknownHostException`/timeout. Net effect is the same BLOCK (the device cannot complete OTP against the emulator-loopback base URL with no backend wired), but the proximate cause is the cleartext NSC, not connectivity. To go green this needs both (a) the base URL pointed at `10.0.0.179` and (b) either HTTPS or a cleartext allowance in the network-security-config — a source change owned by the implementation Claude, plus Supabase/Fastify bound to the LAN.

`adb reverse` experiment (read-only): `adb reverse --list` empty; would NOT help — the app targets literal `10.0.2.2` (not `localhost`/`127.0.0.1`) and is rejected by the cleartext policy before any socket, so port-reversing localhost is irrelevant. No app crash after the failure (crash buffer empty).

### T5 — Verify OTP → plant list — BLOCKED
Behind T4. No OTP delivered → no code to enter → "Verify" path unreachable → no token persisted → plant list (`inventory_plant_list` / empty state) never reached.

### T6 — Add-plant selectors — BLOCKED
Behind backend/T5. List screen unreachable; profile dropdown (`GET /plant-profiles`), garden-space/container select-or-create, and plant submit cannot be exercised.

### T7 — Detail: care task + advisories + Accept — BLOCKED
Behind backend/T6. No plant exists; water CareTask render, advisory display, and Accept-creates-task cannot be reached.

### T8 — Reminder scheduling — BLOCKED (WorkManager infra itself verified working)
```
$ adb -s … shell am broadcast -a "androidx.work.diagnostics.REQUEST_DIAGNOSTICS" -p dev.plantapp.android
Broadcast completed: result=0
logcat:
  WM-DiagnosticsWrkr: Running work:
  WM-DiagnosticsWrkr:  Id  Class Name  Job Id  State  Unique Name  Tags
  WM-DiagnosticsWrkr: 6b09ac8a-…  androidx.work.impl.workers.DiagnosticsWorker  0  RUNNING  …DiagnosticsWorker
  WM-WorkerWrapper: Worker result SUCCESS for Work [ id=6b09ac8a-…, tags={ …DiagnosticsWorker } ]
$ adb -s … shell dumpsys jobscheduler | grep -A6 dev.plantapp
  <0>dev.plantapp.android::.schedulePersisted(): countInWindow=0  (quota slot only; no enqueued plant-reminder)
```
**Finding:** WorkManager is correctly initialized and runs work (the diagnostics worker executed and reported SUCCESS). The work table shows **only** the DiagnosticsWorker — there is **no `plant-reminder` unique work** enqueued, because `ReminderSync` runs only once a signed-in user has a pending task, which is blocked behind T4. So T8's specific assertion (a `plant-reminder` job) is BLOCKED, though the underlying WorkManager machinery is healthy.

### T9 — Runtime notification permission — BLOCKED (permission granted at install)
```
$ adb -s … shell dumpsys package dev.plantapp.android | grep -i POST_NOTIFICATIONS
  android.permission.POST_NOTIFICATIONS: granted=true, flags=[ USER_SENSITIVE_WHEN_GRANTED|USER_SENSITIVE_WHEN_DENIED]
  android.permission.POST_NOTIFICATIONS: granted=true
```
`POST_NOTIFICATIONS` is **granted=true**, but via the `install -r -g` auto-grant in T1 — not via the in-app runtime dialog. The runtime-dialog UX is wired into the LIST route (post-sign-in), so it was not exercised; that path is BLOCKED behind T4. No before/after dialog screenshot possible.

### T10 — Notification fires — BLOCKED
Behind T8. `cmd jobscheduler get-jobs` is unsupported on this build (`Unknown command: get-jobs`); regardless, there is no `plant-reminder` job to force-run with `cmd jobscheduler run`. No reminder notification can be posted.

### T11 — Notification channel — BLOCKED
```
$ adb -s … shell dumpsys notification_manager | grep -iE "plant_care_reminders|plantapp"
  AppSettings: dev.plantapp.android (10198) importance=DEFAULT userSet=false
```
The `plant_care_reminders` channel does **not** exist yet — it is created when the reminder feature path first runs (post-sign-in), which is blocked. App-level notification importance is DEFAULT.

### T12 — Stability / teardown — PASS
```
$ adb -s … shell input keyevent KEYCODE_HOME
$ adb -s … shell am start -W -n dev.plantapp.android/.MainActivity
Status: ok   LaunchState: HOT   TotalTime: 40   WaitTime: 41
pid after warm start = 8622 (unchanged)
crash buffer: (empty)
```
Warm/HOT restart in 40 ms, same process, no crash. UI state preserved (sign-in screen with the typed email and the error still rendered) — `T12-warm-start.png`. App left installed for owner inspection.

### Cross-check (T2 note) — `pm list packages` user scoping
```
$ adb -s … shell pm list packages --user 0 | grep dev.plantapp   → package:dev.plantapp.android
$ adb -s … shell pm list packages --user 150
  Error: java.lang.SecurityException: Shell does not have permission to access user 150
```
Confirms the earlier "user 150" SecurityException is a user-scoping artifact; use `--user 0`.

---

## Overall summary

**What concretely works end-to-end on the device (PASS):**
- Wireless adb to the S24 Ultra (SDK 36) is stable; device reaches the host LAN (10.0.0.179).
- The pre-built debug APK installs cleanly (`install -r -g` → Success) and resolves launcher `MainActivity`.
- Cold launch (643 ms) and warm launch (40 ms) are crash-free; no `FATAL EXCEPTION`/`AndroidRuntime` in any run.
- Unauthenticated gating is correct: fresh install → no token → **Sign in** start destination.
- Sign-in UI renders correctly (Email field + "Send code" button); the email field accepts input and the button fires the auth call.
- The Compose UI, input handling, IME, and process lifecycle are all healthy.
- **WorkManager is initialized and functional** (DiagnosticsWorker executes and reports SUCCESS) — the reminder infra is sound even though no reminder is enqueued yet.
- `POST_NOTIFICATIONS` is granted (via install `-g`).

**Exact point the full-stack journey blocks, and why (verbatim):**
The journey blocks at **T4 (Request OTP)**, the first network call. Tapping "Send code" issues:
`POST http://10.0.2.2:54321/auth/v1/otp` which fails with
**`java.net.UnknownServiceException: CLEARTEXT communication to 10.0.2.2 not permitted by network security policy`**,
surfaced verbatim in the UI as the sign-in error. Everything downstream (T5 verify, T6 add-plant, T7 detail/advisories, T8 plant-reminder enqueue, T9 in-app permission dialog, T10 notification post, T11 channel creation) is consequently BLOCKED behind it. This is the **expected backend-wiring block**, caused by the build-time base URL `http://10.0.2.2:54321/` (emulator loopback, unreachable + cleartext-blocked on a physical device) for both the PlantApp API and Supabase auth, with no LAN-bound Supabase/Fastify backend running.

**Build-time note:** APK built **2026-06-02 09:05:56 -0700**, versionName 0.1.0, targetSdk 35 (device is SDK 36); it trails repo HEAD per the suite note. The base URLs are baked at build time to `10.0.2.2:54321`. Fixing the block needs a **source change by the implementation Claude** (base URL → `10.0.0.179`, plus HTTPS or a cleartext-permit in network-security-config) AND the Supabase + Fastify backends running bound to the LAN — none of which the planner/QA may do.

**Refinement worth flagging to the implementation Claude:** the failure is **not** a connectivity error (no `ConnectException`/timeout/`UnknownHostException`). It is an Android **network-security-policy cleartext rejection** that fires before any socket opens. So even after the base URL is repointed to `10.0.0.179`, plain `http://` will still be rejected unless the app either uses HTTPS or explicitly permits cleartext for that host in its network-security-config. Pointing the URL alone will not unblock T4.

**Unexpected bugs/crashes (distinct from the expected block):** **None.** No crashes, ANRs, or regressions were observed in any test. The only "surprise" is the cleartext NSC rejection described above, which is a configuration nuance, not a defect. Log noise (qdgralloc interlaced-flag warnings, Samsung SurfaceComposer/InsetsController spam, `com.google.android.as.oss REPLACED` ActivityThread notes) is all platform/OEM background and unrelated to the app.

**Evidence files:** `T02-cold-launch.png`, `T03-signin-ui.png`, `T04-email-entered.png`, `T04-after-send.png`, `T12-warm-start.png` under `reviews/device-evidence/`.
