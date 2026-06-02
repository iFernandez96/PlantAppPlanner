# DONE — handoff 0035-workmanager-local-reminders (Slice 3 step 2, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** WorkManager **local** reminder plumbing — a `ReminderScheduler` that enqueues one
delayed, unique work request per `ReminderSpec` and a `ReminderWorker` that posts a local
notification. Local path only — **no Firebase/FCM**. Adds the WorkManager dep + `POST_NOTIFICATIONS`
(both inherent to local reminders; D-13 scope). `:data` unit tests green; `:app:assembleDebug` OK.
Final `origin/master` = `6f6f58b55ca85a27a99974c682831ce301cf9ee8`.

## Baseline + unblock
- HEAD at start = `79944a5…` == origin/master; clean. SDK resolves.

## What was added
1. **`libs.versions.toml`** — `androidx-work = "2.9.1"`; libs `androidx-work-runtime-ktx` +
   `androidx-work-testing` (both `version.ref = "androidx-work"`).
2. **`android/data/build.gradle.kts`** — `implementation(libs.androidx.work.runtime.ktx)` +
   `testImplementation`s `androidx.work.testing` / `robolectric` / `androidx.test.ext.junit`; and
   `testOptions { unitTests { isIncludeAndroidResources = true; all { useJUnit() } } }` (Robolectric
   WorkManager harness needs resources). No other dep.
3. **`android/app/src/main/AndroidManifest.xml`** — `<uses-permission
   android:name="android.permission.POST_NOTIFICATIONS" />` (runtime *request* is the next handoff).
4. **`:data/reminder/ReminderNotifications.kt`** — `REMINDER_CHANNEL_ID = "plant_care_reminders"`
   + `ensureReminderChannel(context)` (creates the IMPORTANCE_DEFAULT channel on API 26+,
   idempotent).
5. **`:data/reminder/ReminderWorker.kt`** — `CoroutineWorker`; `doWork()` reads
   `KEY_TITLE`/`KEY_TEXT`/`KEY_NOTIFICATION_ID` from `inputData`, ensures the channel, and posts via
   `NotificationManagerCompat.notify(...)` **guarded** by `POST_NOTIFICATIONS` (or SDK < 33) — if not
   granted, returns `Result.success()` without posting (no crash). DI-free; small icon
   `android.R.drawable.ic_dialog_info`. `KEY_*` in a companion.
6. **`:data/reminder/ReminderScheduler.kt`** — `@Inject constructor(@ApplicationContext context)`;
   `schedule(specs, now)`: `delayMs = max(0, Instant.parse(triggerAtUtc).toEpochMilli() -
   now.toEpochMilli())` (past trigger → fire asap), `OneTimeWorkRequestBuilder<ReminderWorker>` with
   that delay + `workDataOf(title/text/notificationId)` + `addTag(TAG_REMINDER)`, enqueued via
   `enqueueUniqueWork("reminder-${taskId}", REPLACE, request)` (unique per task → re-schedule
   replaces). `TAG_REMINDER = "plant-reminder"` in a companion.

## Tests — `android/data/.../ReminderSchedulerTest.kt` (new, Robolectric, `WorkManagerTestInitHelper`)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 15s
```
- `scheduleEnqueuesOneUniqueWorkPerPendingSpec` — two future specs → 2 work infos tagged
  `plant-reminder`, both `ENQUEUED`.
- `reSchedulingTheSameTaskIdReplacesWithoutDuplicate` — same spec scheduled twice → exactly 1 work
  info (unique work).
- `pastTriggerStillEnqueuesWithClampedDelay` — past `triggerAtUtc` → delay clamped to 0; one work
  enqueued and live (state ∈ ENQUEUED/RUNNING/SUCCEEDED).
- `:data` total **11 → 14** (ReminderSchedulerTest 3 + AuthRepositoryImplTest 2 +
  InventoryAdvisoriesTest 1 + InventoryRepositoryImplTest 8). All green.
- **`:app:assembleDebug` BUILD SUCCESSFUL** (WorkManager dep + the new permission merge cleanly).

## Implementation note
The past-trigger assertion was relaxed from a literal `ENQUEUED` to "live" (`ENQUEUED`/`RUNNING`/
`SUCCEEDED`): zero-delay work is picked up immediately by the test harness's synchronous executor,
so it transitions to `RUNNING` — the behavioural point (a past trigger still enqueues with clamped
delay) holds.

## Commit
- `6f6f58b` — feat(android-data): WorkManager local reminder scheduler + worker (Slice 3)
- `git show --stat HEAD`: 7 files, +208 −2 — only `android/gradle/libs.versions.toml` +
  `android/data/**` (build.gradle + 3 new main + 1 new test) + `android/app/src/main/AndroidManifest.xml`.
  `local.properties` NOT committed (grep 0).

## Compliance
- **No Firebase/FCM, no `google-services.json`, no `com.google.gms`** — verified by grep (the only
  "FCM" hit is a comment asserting its absence). No `:network`/`:domain`/backend/schema change. No
  permission beyond `POST_NOTIFICATIONS`. No runtime-permission UI / app-open scheduling (next
  handoff). No `@HiltWorker`/`Configuration.Provider` (worker DI-free; content via inputData). No
  camera/photos/GPS/AI. SDK/Drive untouched.

Final `origin/master` SHA: `6f6f58b55ca85a27a99974c682831ce301cf9ee8`

## Next (per planner follow-up)
App-open scheduling + runtime-permission handoff: on app start (post-sign-in) gather pending
CareTasks → `computeReminders` → `ReminderScheduler.schedule(...)`, and request `POST_NOTIFICATIONS`
at runtime (Android 13+) via a Compose flow + Robolectric tests. **Then STOP and ask the owner for
Firebase/FCM setup** before any server-triggered push (the Slice 3 FCM gate).
