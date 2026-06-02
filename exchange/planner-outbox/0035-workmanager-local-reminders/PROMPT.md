# Next Implementation Prompt — Slice 3 (WorkManager local reminders): scheduler + Worker

**Slice 3, step 2 — local notification plumbing.** Turn `computeReminders` output (from `0034`)
into scheduled **local** device notifications via WorkManager: a `ReminderWorker` that posts a
notification + a `ReminderScheduler` that enqueues one delayed work request per `ReminderSpec`. This
is the **local path only** — **no Firebase/FCM** (that is a later, owner-gated STOP). This handoff
**adds a dependency (WorkManager) and the `POST_NOTIFICATIONS` permission** — both are inherent to
local reminders and within the owner-approved "WorkManager local path first" scope (Slice 3 plan
doc, D-13). The **runtime** permission request + app-open scheduling are the *next* handoff; this
one declares the permission, builds the channel/worker/scheduler, and unit-tests the scheduling.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`79944a53e76bf85a91b085fc78f030da41053e9f` == `origin/master`, clean. `:domain` has
`computeReminders(...) : List<ReminderSpec>` (`ReminderSpec(taskId, kind, dueAt, triggerAtUtc)`).
`:data` is an `android.library` (minSdk 26, Hilt, coroutines) — a good home for the Worker +
scheduler. `libs.versions.toml` has **no** WorkManager entry. The committed source manifest
`android/app/src/main/AndroidManifest.xml` declares **no** permissions. `minSdk = 26`,
`targetSdk = 35` (so `POST_NOTIFICATIONS`, API 33, is a runtime permission on 33+; auto-granted
< 33). No notification code exists yet.

Single logical change (WorkManager local-reminder scheduler + worker + dep/permission/channel) →
one commit. Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
WorkManager **local** reminder scheduler + worker. **Consult the WorkManager + WorkManagerTestInitHelper
docs.** Red-first: write the scheduler test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 79944a53e76bf85a91b085fc78f030da41053e9f == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`android/gradle/libs.versions.toml`** — add WorkManager + its Robolectric test helper:
   `androidx-work = "2.9.1"`; libraries `androidx-work-runtime-ktx = { module =
   "androidx.work:work-runtime-ktx", version.ref = "androidx-work" }` and `androidx-work-testing =
   { module = "androidx.work:work-testing", version.ref = "androidx-work" }`. (Use 2.9.1 unless a
   newer stable is already implied by the catalog; if 2.9.1 is unavailable, STOP and report rather
   than guessing.)
2. **`android/data/build.gradle.kts`** — `implementation(libs.androidx.work.runtime.ktx)` +
   `testImplementation(libs.androidx.work.testing)` + `testImplementation(libs.robolectric)` +
   `testImplementation(libs.androidx.test.ext.junit)` (Robolectric needs an Android context for the
   WorkManager test harness; mirror how other modules pull these). No other dep.
3. **`android/app/src/main/AndroidManifest.xml`** — add (above `<application>`):
   `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />`. No other manifest
   change. (The runtime *request* is the next handoff.)
4. **`:data` `.../reminder/ReminderNotifications.kt`** (new) — a small helper:
   `const val REMINDER_CHANNEL_ID = "plant_care_reminders"`; `fun ensureReminderChannel(context:
   Context)` that creates the `NotificationChannel` (importance default) on API 26+ (idempotent).
5. **`:data` `.../reminder/ReminderWorker.kt`** (new) — `class ReminderWorker(appContext: Context,
   params: WorkerParameters) : CoroutineWorker(appContext, params)`. `doWork()`: read
   `inputData` keys `KEY_TITLE`/`KEY_TEXT`/`KEY_NOTIFICATION_ID`; `ensureReminderChannel`; build a
   notification (`NotificationCompat.Builder`, a built-in `android.R.drawable` small icon) and post
   via `NotificationManagerCompat.from(applicationContext).notify(notificationId, …)` **guarded by a
   permission check** (`if (ActivityCompat.checkSelfPermission(... POST_NOTIFICATIONS) == GRANTED ||
   Build.VERSION.SDK_INT < 33)`; if not granted, return `Result.success()` without posting — no
   crash); return `Result.success()`. No repository/DI inside the worker (all content via
   `inputData`). Define the `KEY_*` consts in a companion.
6. **`:data` `.../reminder/ReminderScheduler.kt`** (new) — `class ReminderScheduler @Inject
   constructor(@ApplicationContext private val context: Context)`:
   `fun schedule(specs: List<ReminderSpec>, now: java.time.Instant)`: for each spec, compute
   `delayMs = max(0, Instant.parse(triggerAtUtc).toEpochMilli() - now.toEpochMilli())`, build a
   `OneTimeWorkRequestBuilder<ReminderWorker>().setInitialDelay(delayMs, MILLISECONDS)
   .setInputData(workDataOf(KEY_TITLE to "Plant care reminder", KEY_TEXT to "A '${spec.kind}' task
   is due", KEY_NOTIFICATION_ID to spec.taskId.hashCode())).addTag(TAG_REMINDER).build()`, and
   `WorkManager.getInstance(context).enqueueUniqueWork("reminder-${spec.taskId}",
   ExistingWorkPolicy.REPLACE, request)` (unique per task so re-scheduling replaces). Expose
   `const val TAG_REMINDER = "plant-reminder"`.

### Tests — `android/data/src/test/.../ReminderSchedulerTest.kt` (new, Robolectric)
Use `WorkManagerTestInitHelper` (`@RunWith(RobolectricTestRunner::class) @Config(sdk=[34])`):
- `@Before` initialize WorkManager for test:
  `WorkManagerTestInitHelper.initializeTestWorkManager(ApplicationProvider.getApplicationContext())`.
- `schedule enqueues one unique work per pending spec`: pass two `ReminderSpec`s (future
  `triggerAtUtc`) + `now`; assert `WorkManager.getInstance(ctx).getWorkInfosByTag(TAG_REMINDER).get()`
  has size 2 and state `ENQUEUED`.
- `re-scheduling the same taskId replaces (no duplicate)`: schedule the same spec twice; assert the
  tag query still returns exactly 1 work info for that task (unique work).
- (Optional: assert a past `triggerAtUtc` enqueues with zero/clamped delay — still ENQUEUED.)
Do **not** require a real notification to post in the unit test (that needs a device/permission);
the gate is the **scheduling** behavior.

### Forbidden
- **No Firebase/FCM, no `google-services.json`, no `com.google.gms` plugin** — local path only.
- No `:network`/`:domain`/backend/schema change. No new permission beyond `POST_NOTIFICATIONS`. No
  runtime-permission request UI or app-open scheduling (next handoff). No Hilt-WorkManager factory
  wiring (`@HiltWorker`/`Configuration.Provider`) — keep the worker DI-free (content via inputData).
  No camera/photos/GPS/AI. Don't mount/repoint the SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :app:assembleDebug
```
Red→green: `ReminderSchedulerTest` fails before the scheduler/worker exist; after, `:data` unit
tests pass (new scheduler tests green; prior `:data` tests still green) and `:app:assembleDebug`
compiles (WorkManager dep + the new permission merge cleanly). Report counts + new test names +
assemble result.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/gradle/libs.versions.toml android/data/ android/app/src/main/AndroidManifest.xml
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-data): WorkManager local reminder scheduler + worker (Slice 3)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The WorkManager dep + `POST_NOTIFICATIONS` declaration, the channel helper, `ReminderWorker`
   (inputData-driven, permission-guarded), and `ReminderScheduler` (unique work per task, delay
   from `triggerAtUtc`).
2. `:data:testDebugUnitTest` count before→after + new test names; `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `libs.versions.toml` + `android/data/**` + the `:app` manifest changed (not `local.properties`);
   confirm **no** Firebase/FCM/`google-services` anywhere.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; WorkManager dep + `POST_NOTIFICATIONS` only; scheduler/worker; `:data` green;
assemble OK; no FCM). Then the **app-open scheduling + runtime-permission handoff**: on app start
(post-sign-in), gather the caller's pending `CareTask`s, run `computeReminders`, call
`ReminderScheduler.schedule(...)`, and request `POST_NOTIFICATIONS` at runtime (Android 13+) via a
Compose permission flow + Robolectric tests. **Then STOP and ask the owner for Firebase/FCM setup**
(Firebase project + `google-services.json`) before any server-triggered push — that is the Slice 3
FCM gate. Vision-check each step.
