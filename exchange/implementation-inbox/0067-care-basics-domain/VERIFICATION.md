# Standalone verification — 0067

Type: red-first (compile-red, per §6 — purely additive model fields have no compiling-red)
→ green.

## 1. RED (mapping test only)
```
$ ./gradlew :data:testDebugUnitTest --tests "dev.plantapp.data.InventoryRepositoryImplTest"
> Task :data:compileDebugUnitTestKotlin FAILED
e: InventoryRepositoryImplTest.kt:18:35 Unresolved reference 'wateringIntervalDays'.
e: InventoryRepositoryImplTest.kt:19:35 Unresolved reference 'feedingIntervalDays'.
e: InventoryRepositoryImplTest.kt:20:35 Unresolved reference 'sunHoursTarget'.
e: InventoryRepositoryImplTest.kt:21:36 Unresolved reference 'frostSensitive'.
e: InventoryRepositoryImplTest.kt:22:51 Unresolved reference 'commonIssues'.
```

## 2. GREEN
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 18s
163 actionable tasks: 31 executed, 132 up-to-date
```
- domain: 9/0 (unchanged)
- data: 19/0 (+1: `getPlantProfilesMapsTheCareBasicsFromTheCatalogDto` — 2.0 / 7.0 / 8.0 /
  true / emptyList against the untouched FakePlantAppApi fixture)
- feature-inventory: 48/0 (unchanged — the existing positional 4-arg PlantProfile call
  sites compiled untouched thanks to the defaults)
- app assembles end-to-end.
