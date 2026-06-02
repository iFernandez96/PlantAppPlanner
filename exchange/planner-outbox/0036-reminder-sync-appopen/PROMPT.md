# Next Implementation Prompt — Slice 3 (app-open scheduling): `ReminderSync`

**Slice 3, step 3 — schedule reminders on app open.** Wire it together: when the signed-in user
opens the app, gather their pending `CareTask`s, run `computeReminders` (`0034`), and hand the specs
to `ReminderScheduler` (`0035`). **Still local-only — no Firebase/FCM.** The **runtime
`POST_NOTIFICATIONS` request UI** is the *next* handoff; this one does the aggregation + scheduling
trigger (the Worker already no-ops safely if the permission isn't granted yet).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`6f6f58b55ca85a27a99974c682831ce301cf9ee8` == `origin/master`, clean. `:domain`
`computeReminders(tasks, now, …): List<ReminderSpec>`. `:data` `ReminderScheduler @Inject
constructor(@ApplicationContext context)` with `fun schedule(specs: List<ReminderSpec>, now:
Instant)` (enqueues unique work per task). `InventoryRepository` has `getPlants(): List<Plant>` and
`getPlantTasks(plantId): List<CareTask>`. `PlantListViewModel @Inject constructor(repository:
InventoryRepository)` loads plants in `refresh()` (called from `init`). `:data` DI: `DataModule`
(@Provides) + `RepositoryModule` (@Binds). `:data` tests use hand fakes + `runTest`.

Single logical change (the `ReminderSync` coordinator + its DI + the app-open trigger) → one commit.
Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add a
`ReminderSync` coordinator + wire it to run on app open. Red-first: write the `ReminderSync` test
first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 6f6f58b55ca85a27a99974c682831ce301cf9ee8 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`:data` `.../reminder/ReminderScheduler.kt`** — extract a tiny **seam** for testability: add
   `interface ReminderScheduling { fun schedule(specs: List<ReminderSpec>, now: java.time.Instant) }`
   and make `ReminderScheduler : ReminderScheduling` (`override fun schedule(...)` — its existing
   method). No behavior change.
2. **`:data` `.../reminder/ReminderSync.kt`** (new) — `class ReminderSync @Inject constructor(
   private val repository: InventoryRepository, private val scheduler: ReminderScheduling, private
   val clock: java.time.Clock)`:
   ```kotlin
   suspend fun syncNow() {
       val now = java.time.Instant.now(clock)
       val tasks = repository.getPlants().flatMap { repository.getPlantTasks(it.id) }
       scheduler.schedule(computeReminders(tasks, now), now)
   }
   ```
   (import `computeReminders`/`ReminderSpec` from `:domain`.)
3. **`:data` `di/DataModule.kt`** — `@Provides @Singleton fun provideClock(): java.time.Clock =
   java.time.Clock.systemUTC()`; in `RepositoryModule` (the `@Binds` module) add `@Binds @Singleton
   abstract fun bindReminderScheduling(impl: ReminderScheduler): ReminderScheduling`. (`ReminderSync`
   itself is constructor-injected — no explicit binding needed.)
4. **`:feature-inventory` `InventoryViewModels.kt`** — `PlantListViewModel`: add a constructor param
   `private val reminderSync: ReminderSync` (import from `dev.plantapp.data.reminder` — note
   `:feature-inventory` already depends on `:data`? if **not**, instead inject `ReminderSync` only
   where `:data` is visible; **STOP and report** if `:feature-inventory` doesn't depend on `:data`
   so the planner can re-place this). After a **successful** plant load in `refresh()`, fire-and-forget:
   `viewModelScope.launch { runCatching { reminderSync.syncNow() } }` (a scheduling failure must NOT
   change the list UI state). Do not call it on the error path.

### Tests — `:data` `.../ReminderSyncTest.kt` (new, `runTest`)
- A `FakeReminderScheduling : ReminderScheduling` capturing the last `(specs, now)`.
- Reuse/extend a fake `InventoryRepository` (or a minimal local fake) returning 1 plant with 2
  tasks — one `pending` (future `dueAt`), one `done` — and a **fixed** `Clock`
  (`Clock.fixed(Instant.parse("2026-06-01T00:00:00Z"), ZoneOffset.UTC)`).
- `syncNow gathers pending tasks and schedules them`: call `ReminderSync(repo, fakeScheduler,
  fixedClock).syncNow()`; assert the fake scheduler received specs for **only** the pending task
  (1 spec, matching `taskId`), and `now` equals the fixed clock instant.

### Forbidden
- **No Firebase/FCM/`google-services`.** No runtime-permission request UI (next handoff). No
  `:network`/backend/schema change. No new dependency. No change to `ReminderWorker`/scheduling
  enqueue logic (only the interface extraction). No camera/photos/GPS/AI. Don't mount/repoint the
  SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: `ReminderSyncTest` fails before `ReminderSync`/the seam exist; after, `:data` +
`:feature-inventory` unit tests pass (new test green; prior green) and `:app:assembleDebug` compiles
(the `PlantListViewModel` injection resolves via Hilt). Report counts + new test name + assemble result.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/data/ android/feature-inventory/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android): schedule local reminders on app open (ReminderSync, Slice 3)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. `ReminderScheduling` seam, `ReminderSync.syncNow()` (aggregate pending tasks → computeReminders →
   schedule), the DI (clock + binding), and the `PlantListViewModel` app-open trigger (fire-and-forget,
   success-path only).
2. `:data` + `:feature-inventory` test counts before→after + new test name; `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only `android/data/**` +
   `android/feature-inventory/**` changed (not `local.properties`); confirm no FCM/google-services.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `:data`+`:feature-inventory`; `ReminderSync` + trigger; tests green;
assemble OK; no FCM). Then the **runtime `POST_NOTIFICATIONS` request handoff** (Android 13+): a
Compose permission flow (e.g. `rememberLauncherForActivityResult(RequestPermission)`) requested at
an appropriate point after sign-in, + Robolectric test. **That is the last LOCAL Slice 3 step —
then STOP and ask the owner for Firebase/FCM setup** (a Firebase project + `google-services.json`)
before any server-triggered push (the Slice 3 FCM gate). Vision-check each step.
