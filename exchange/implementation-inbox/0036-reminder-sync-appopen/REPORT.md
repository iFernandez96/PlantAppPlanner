# DONE — handoff 0036-reminder-sync-appopen (Slice 3 step 3, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `ReminderSync` coordinator — on a successful plant load (app open), it aggregates the
caller's pending CareTasks, runs `computeReminders`, and hands the specs to `ReminderScheduler`.
Still local-only — **no Firebase/FCM**, no runtime-permission UI (next handoff). `:data` +
`:feature-inventory` tests green; `:app:assembleDebug` OK. Final `origin/master` =
`e8aaeec50c0f1cb1114b3dc1b8186654d7fae091`.

## Baseline + unblock
- HEAD at start = `6f6f58b…` == origin/master; clean. `:feature-inventory` depends on `:data`
  (confirmed) — no re-placement needed.

## What was added
1. **`:data` `ReminderScheduler.kt`** — extracted seam `interface ReminderScheduling { fun
   schedule(specs, now) }`; `ReminderScheduler : ReminderScheduling` (`override` on its existing
   method). No behaviour change.
2. **`:data` `reminder/ReminderSync.kt`** (new) — `@Inject constructor(repository:
   InventoryRepository, scheduler: ReminderScheduling, clock: Clock)`; `suspend fun syncNow()`:
   `now = Instant.now(clock)`; `tasks = getPlants().flatMap { getPlantTasks(it.id) }`;
   `scheduler.schedule(computeReminders(tasks, now), now)`. Clock injected for determinism.
3. **`:data` `di/DataModule.kt`** — `@Provides @Singleton provideClock() = Clock.systemUTC()`;
   `RepositoryModule` `@Binds bindReminderScheduling(ReminderScheduler): ReminderScheduling`
   (`ReminderSync` is constructor-injected — no explicit binding).
4. **`:feature-inventory` `InventoryViewModels.kt`** — `PlantListViewModel` gains
   `reminderSync: ReminderSync`. On a **successful** load in `refresh()`, fire-and-forget
   `viewModelScope.launch { runCatching { reminderSync.syncNow() } }` — a scheduling failure never
   changes the list UI state, and it's not called on the error path.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 38s
```
- **`:data` `ReminderSyncTest`** (new, `runTest`): `syncNowGathersPendingTasksAndSchedulesThem` —
  a `FakeRepo` (1 plant; one `pending` future task + one `done`) + `FakeReminderScheduling` +
  `Clock.fixed(2026-06-01T00:00:00Z, UTC)`; asserts the scheduler received **only** the pending
  task's spec (`["pending-1"]`) and `now == the fixed instant`. `:data` total **14 → 15**.
- **`:feature-inventory`** stays 18 green — `NavSmokeTest` (2) updated to construct
  `PlantListViewModel(repo, reminderSync(repo))` via a new test helper (no-op scheduler), so the
  app-open sync is inert in the nav smoke.
- **`:app:assembleDebug` BUILD SUCCESSFUL** — the `PlantListViewModel`/`ReminderSync`/`Clock`/
  `ReminderScheduling` graph resolves via Hilt.

## Commit
- `e8aaeec` — feat(android): schedule local reminders on app open (ReminderSync, Slice 3)
- `git show --stat HEAD`: 7 files, +139 −4 — only `android/data/**` (DataModule, ReminderScheduler,
  ReminderSync, ReminderSyncTest) + `android/feature-inventory/**` (InventoryViewModels,
  NavSmokeFakes, NavSmokeTest). `local.properties` NOT committed (grep 0).

## Compliance
- **No Firebase/FCM/`google-services`** (grep clean). No runtime-permission UI (next handoff). No
  `:network`/backend/schema change. No new dependency. No change to `ReminderWorker`/enqueue logic
  (only the interface extraction). No camera/photos/GPS/AI. SDK/Drive untouched.

Final `origin/master` SHA: `e8aaeec50c0f1cb1114b3dc1b8186654d7fae091`

## Next (per planner follow-up — last LOCAL Slice 3 step)
Runtime `POST_NOTIFICATIONS` request (Android 13+): a Compose permission flow
(`rememberLauncherForActivityResult(RequestPermission)`) after sign-in + Robolectric test. **Then
STOP and ask the owner for Firebase/FCM setup** (Firebase project + `google-services.json`) before
any server-triggered push — the Slice 3 FCM gate.
