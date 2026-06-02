# PlantApp — On-Device Full-Stack Test Suite (queued 2026-06-02)

**Device:** Samsung SM-S928U1 (Galaxy S24 Ultra), **Android 16 / SDK 36**, wireless adb
`10.0.0.166:41027` (paired guid `adb-R5CX11MDTZK`). **Host LAN IP:** `10.0.0.179`.
**APK under test:** `/home/israel/Documents/Development/PlantApp/android/app/build/outputs/apk/debug/app-debug.apk`
(pre-built debug; record its build time + note it may trail HEAD `369f2f0`).
**App id:** `dev.plantapp.android`.

**Known prerequisite gap (full-stack):** the app's base URLs are `http://10.0.2.2:54321/`
(emulator loopback) for both the PlantApp API (`DataModule.DEFAULT_BASE_URL`) and Supabase auth
(`DEFAULT_AUTH_BASE_URL`). A physical device cannot reach `10.0.2.2`. Also the PlantApp REST
endpoints (`/plants`, `/plant-profiles`, …) are served by the **Fastify** backend, which is **not
running/wired** for device use. Therefore every network-dependent test (T4+) is expected **BLOCKED**
until: (a) the base URL(s) point at `10.0.0.179` (source change → implementation Claude), and (b)
Supabase + Fastify run bound to the LAN. Tests below are still listed in full so the same suite
re-runs green once those land.

**Per-test status vocabulary:** PASS · FAIL (regression/bug) · BLOCKED (precondition unmet, with
the exact reason + evidence) · SKIP (not applicable).

**Evidence the agent must capture for every test:** the exact command(s) run + raw output;
`adb exec-out screencap -p` screenshot saved per UI step; relevant `logcat` lines (filtered to the
app pid / WorkManager / AndroidRuntime); for network steps, the precise failure (DNS/connect/timeout
+ stack). Leave no detail unnoticed.

---

## T0 — Environment & connection
- Device shows `device` (not offline/unauthorized) on `10.0.0.166:41027`; capture model, Android
  release, SDK. Confirm host LAN IP. Confirm the APK file exists + its mtime/size.

## T1 — Install
- `adb -s <dev> install -r -g <apk>` (`-g` grants manifest perms where possible). Confirm `Success`;
  capture any warnings. Confirm `pm list packages --user 0 | grep dev.plantapp` shows it.

## T2 — Cold launch + gating
- Force-stop, then `am start` the launcher activity. Confirm no crash (logcat has no
  `FATAL EXCEPTION`/`AndroidRuntime` for the pid). Expected: lands on the **sign-in** screen
  (fresh install → no token → `SIGN_IN` start destination). Screenshot.

## T3 — Sign-in screen UI
- The email field + "Send code" button are visible (tags `field_signin_email`,
  `signin_send_code_button`). Screenshot. (Optional: drive via Maestro or `adb shell input`.)

## T4 — Request OTP  *(expected BLOCKED — backend/base-URL)*
- Enter an email, tap "Send code". Observe the call to GoTrue `…/auth/v1/otp`. Expected on a real
  device: the request to `10.0.2.2:54321` fails (no route to host / connect timeout). Capture the
  **exact** failure from logcat (OkHttp/retrofit) + any on-screen error (`signin_error`). This test
  documents the wiring gap precisely.

## T5 — Verify OTP → plant list  *(BLOCKED behind T4)*
- With a real code, "Verify" → token persisted → navigate to the plant list (`inventory_plant_list`
  or empty state). Record blocked-reason if T4 failed.

## T6 — Add-plant selectors  *(BLOCKED behind backend)*
- From the list, tap add → the **profile dropdown** lists catalog species (from `GET /plant-profiles`),
  garden-space/container **select-or-create** work; submit creates a plant. Screenshot each selector.

## T7 — Detail: care task + advisories + Accept  *(BLOCKED behind backend)*
- Open the new plant → a water CareTask renders (kind/dueAt/rationale/engine badge); any advisory
  shows; for a container-size/support advisory the **Accept** button creates a task (list/detail
  refresh). Screenshot.

## T8 — Reminder scheduling  *(BLOCKED behind backend)*
- After a plant with a pending task, app-open `ReminderSync` enqueues WorkManager work. Inspect:
  `adb shell am broadcast -a "androidx.work.diagnostics.REQUEST_DIAGNOSTICS" -p dev.plantapp.android`
  (debug build) → logcat shows scheduled/enqueued work; `adb shell dumpsys jobscheduler | grep -A6
  dev.plantapp` shows the job. Record the work tag `plant-reminder`.

## T9 — Runtime notification permission (SDK 33+)  *(testable once past sign-in)*
- On first reaching the list, the system `POST_NOTIFICATIONS` dialog appears (SDK 36). Capture the
  dialog (screenshot) + `adb shell dumpsys package dev.plantapp.android | grep -i POST_NOTIFICATIONS`
  before/after grant. (If sign-in is blocked, mark BLOCKED and note the launcher wiring is in the
  LIST route, so it only fires post-sign-in.)

## T10 — Notification fires  *(BLOCKED behind T8)*
- Force-run the reminder worker to avoid waiting for `dueAt`: from `dumpsys jobscheduler`, get the
  job id for `dev.plantapp.android`, then `adb shell cmd jobscheduler run -f dev.plantapp.android
  <jobId>`. Verify a notification posts: `adb shell dumpsys notification --noredact | grep -A8
  dev.plantapp` shows the "Plant care reminder" with the expected text. Screenshot the shade.

## T11 — Notification channel
- After any worker run, `adb shell dumpsys notification_manager | grep -i plant_care_reminders`
  (or `cmd notification`) shows the `plant_care_reminders` channel. Record importance.

## T12 — Stability / teardown
- Re-launch the app a second time (warm start) → no crash. Capture final logcat tail. Leave the app
  installed (owner may inspect) unless asked to uninstall.

---

### Agent execution rules (hard)
- **Read-only w.r.t. the PlantApp repo:** do **NOT** edit, build (`gradlew`), or commit any PlantApp
  file; do **NOT** start the Supabase/Fastify backend; do **NOT** change the base URL. Install only
  the **pre-built** APK and observe. If a test needs any of those, mark it **BLOCKED** with the exact
  precondition — do not work around it.
- Use only: `adb` (install/shell/logcat/screencap/dumpsys/input), Maestro (`~/.maestro/bin/maestro`)
  if helpful, and screenshots. No `sudo`.
- Save screenshots under `/home/israel/Documents/Development/PlantAppPlanner/reviews/device-evidence/`.
- Return an exhaustive report: per-test status + the raw evidence + an overall summary of exactly
  what was seen, including every error verbatim.
