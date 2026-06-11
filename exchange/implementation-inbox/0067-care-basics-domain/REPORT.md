# Implementation report — 0067-care-basics-domain

## Status: DONE

## 1. Scope confirmation + git show --stat HEAD
Exactly the 3 files:
```
 .../src/main/kotlin/dev/plantapp/data/mapper/DtoMappers.kt  | 13 +++++++++++++
 .../kotlin/dev/plantapp/data/InventoryRepositoryImplTest.kt | 10 ++++++++++
 .../kotlin/dev/plantapp/domain/model/InventoryModels.kt     |  9 +++++++++
 3 files changed, 32 insertions(+)
```
- `PlantProfile` extended with the five optional fields, KDoc verbatim (incl. the Double
  rationale — basil's 1.5-day cadence — and the D-09 display-only warning). Defaults keep all
  existing positional 4-arg constructor call sites compiling unchanged.
- `DtoMappers.kt` — the four scalar extractions, each wrapped in the prescribed
  `?.let { runCatching { it.jsonPrimitive.…OrNull }.getOrNull() }` shape (mapper stays total
  if the catalog ever ships a nested element); `commonIssues ?: emptyList()`. Three
  kotlinx.serialization.json imports added — compiled cleanly, no dependency change.
- Red-first mapping test added in the file's existing style (`repo(FakePlantAppApi())`,
  kotlin.test asserts). `FakePlantAppApi` fixture values untouched.
- `:network`, UI modules, backend, schemas, migrations untouched; `android/.kotlin/` left
  untracked.

## 2. RED evidence (§7 step 1 — test only; purely-additive field ⇒ compile-red, as §6 states)
```
> Task :data:compileDebugUnitTestKotlin FAILED
e: …/InventoryRepositoryImplTest.kt:18:35 Unresolved reference 'wateringIntervalDays'.
e: …/InventoryRepositoryImplTest.kt:19:35 Unresolved reference 'feedingIntervalDays'.
e: …/InventoryRepositoryImplTest.kt:20:35 Unresolved reference 'sunHoursTarget'.
e: …/InventoryRepositoryImplTest.kt:21:36 Unresolved reference 'frostSensitive'.
e: …/InventoryRepositoryImplTest.kt:22:51 Unresolved reference 'commonIssues'.
```
Nothing else failed.

## 3. GREEN (all four Gradle tasks in one invocation)
```
$ ./gradlew :domain:test :data:testDebugUnitTest :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 18s
163 actionable tasks: 31 executed, 132 up-to-date
```
JUnit XML aggregates:
- **domain: tests=9 failures+errors=0** (unchanged)
- **data: tests=19 failures+errors=0** (18 + 1 new mapping test — asserts 2.0/7.0/8.0/true/
  empty against the existing fixture; `assertEquals(Double, Double?)` compiled without
  ambiguity)
- **feature-inventory: tests=48 failures+errors=0** (unchanged from 0066, as required)
- `:app:assembleDebug` BUILD SUCCESSFUL (same invocation)

## 4. Commit + push
- New commit: `3a2f4c36b1483ebc6c21ed3b770fc7bf19f6e868`
- Title (exact): `feat(domain): carry catalog care basics into PlantProfile (watering, feeding, sun, frost, issues)`
- Pushed: `3243ae7..3a2f4c3  master -> master`; new `origin/master` =
  `3a2f4c36b1483ebc6c21ed3b770fc7bf19f6e868`.

## 5. Deviations
None.
