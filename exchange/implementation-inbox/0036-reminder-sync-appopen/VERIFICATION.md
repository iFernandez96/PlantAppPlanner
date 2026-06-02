# VERIFICATION — handoff 0036-reminder-sync-appopen (Slice 3 step 3, red→green)

Gate: `:data:testDebugUnitTest :feature-inventory:testDebugUnitTest :app:assembleDebug`.

## RED driver
`ReminderSyncTest` references `ReminderSync` + `ReminderScheduling` (the seam) — absent before the
change → compile-red. Adding `reminderSync: ReminderSync` to `PlantListViewModel` also breaks the
existing `NavSmokeTest` constructor call until updated.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 38s
```
Per-class (test-results XML):
- `:data` `ReminderSyncTest` — tests="1" failures="0": only the pending task is scheduled
  (`["pending-1"]`); `now` == the injected fixed clock instant.
- `:data` others unchanged (AuthRepositoryImplTest 2, InventoryAdvisoriesTest 1,
  InventoryRepositoryImplTest 8, ReminderSchedulerTest 3) → total 14 → 15.
- `:feature-inventory` — InventoryScreensTest 9, NavSmokeTest 2, PlantDetailAdvisoriesTest 4,
  SignInScreenTest 3 → 18, all green (NavSmokeTest updated for the new constructor arg, still 2/2).
- `:app:assembleDebug` — **BUILD SUCCESSFUL** (Hilt resolves PlantListViewModel ← ReminderSync ←
  {InventoryRepository, ReminderScheduling←ReminderScheduler, Clock}).

## No-FCM check
`grep -rin 'firebase|google-services|com.google.gms'` over `:data` + `:feature-inventory` → none.

## Scope / integrity
- `git show --stat`: 7 files, +139 −4 — only `android/data/**` (DataModule, ReminderScheduler,
  ReminderSync + ReminderSyncTest) + `android/feature-inventory/**` (InventoryViewModels,
  NavSmokeFakes, NavSmokeTest). No `:network`/backend/schema change. No new dependency. No
  ReminderWorker/enqueue change (only the `ReminderScheduling` extraction). No runtime-permission UI.
- `local.properties` not committed (grep 0).

## Final repo state
- origin/master = `e8aaeec50c0f1cb1114b3dc1b8186654d7fae091`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
