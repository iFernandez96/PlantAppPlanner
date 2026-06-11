# Standalone verification — 0066

Type: red-first → green (Compose semantics + pure JVM filter tests).

## 1. RED (search UI test only, raw tag string, before any implementation)
```
$ ./gradlew :feature-inventory:testDebugUnitTest --tests "dev.plantapp.feature.inventory.AddPlantWizardTest"
AddPlantWizardTest > species step filters tiles by search text FAILED
    java.lang.AssertionError at AddPlantWizardTest.kt:126
5 tests completed, 1 failed
```
Failure detail: `could not find any node that satisfies: (TestTag = 'wizard_species_search')`
— the search field did not exist on baseline. Only the new test failed.

## 2. GREEN (after §5a–§5d + all §5e tests)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 10s
143 actionable tasks: 15 executed, 128 up-to-date
```
JUnit XML aggregate: **tests=48 failures+errors=0** (was 39; +9):
- UI: search filters tiles (tomato visible, basil gone on "toma"); houseplant chip hides
  the herb tile.
- Model: blank query returns all sorted by display name; "toma" matches common name
  case-insensitively; scientific-name match; category-only filter; query+category compose
  (incl. the cross-category empty result).
- DisplayText: friendly category labels; unknown category de-slug fallback.
All pre-existing wizard tests (walk-through, dedupe-on-back, error card, confirm copy,
preset kinds/phrases) still green — no order pins were present.

## 3. App assembles
`:app:assembleDebug` BUILD SUCCESSFUL (same invocation as the suite).
