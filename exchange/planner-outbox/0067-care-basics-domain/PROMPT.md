# Implementation prompt 0067 — care basics into the domain model (W2 detail enrichment, part 1/2)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
carry the catalog's beginner care basics (watering/feeding cadence, sun target,
frost sensitivity, common issues) from the network DTO into the `:domain`
`PlantProfile`, so part 2 (the detail-screen "Care basics" card) has data to
show. No UI changes in this slice.

The DTO already has everything (`PlantProfileDto` holds the jsonb profiles +
`commonIssues`); only the domain model (currently 4 fields) and the `:data`
mapper need extending.

## 1. Scope — one logical change

1. **`:domain` `InventoryModels.kt`** — extend `PlantProfile` with five OPTIONAL
   fields (defaults keep all 12 existing positional 4-arg constructor call sites
   in tests compiling).
2. **`:data` `DtoMappers.kt`** — extract the scalars from the DTO's
   `JsonObject`s.
3. **`:data` `InventoryRepositoryImplTest.kt`** — red-first mapping test.

IMPORTANT data note: intervals are `Double?`, NOT `Int?` — the catalog has at
least one non-integer cadence (basil waters every **1.5** days); `intOrNull`
would silently drop it.

## 2. Forbidden changes — do NOT touch

- `PlantProfileDto` / anything in `:network` (it already carries the data).
- Any UI (`:feature-inventory`, `:app`) — part 2 is a separate slice.
- `FakePlantAppApi.kt`'s existing fixture VALUES (the test asserts against the
  current fixture: wateringProfile.baseIntervalDays=2, feeding=7, sun=8,
  frostSensitive=true; commonIssues is absent → empty list).
- Backend, schemas, migrations, design-system. No new dependencies.
- Do NOT `git add` untracked `android/.kotlin/`.

## 3. Exact files to touch

1. `android/domain/src/main/kotlin/dev/plantapp/domain/model/InventoryModels.kt`
2. `android/data/src/main/kotlin/dev/plantapp/data/mapper/DtoMappers.kt`
3. `android/data/src/test/kotlin/dev/plantapp/data/InventoryRepositoryImplTest.kt`

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be 3243ae7fd756985a6a9ac45e9e5c2de4b5c22aac
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
```
Differs → **STOP, BLOCKED report.**

## 5. Exact changes

### 5a. `InventoryModels.kt`

Old:
```kotlin
data class PlantProfile(
    val id: String,
    val scientificName: String,
    val commonNames: List<String>,
    val category: String,
)
```
New:
```kotlin
data class PlantProfile(
    val id: String,
    val scientificName: String,
    val commonNames: List<String>,
    val category: String,
    /** Beginner care basics extracted from the catalog profile; null/empty = not provided.
     *  Intervals are Double — the catalog has non-integer cadences (e.g. basil 1.5 days).
     *  DISPLAY-ONLY: never compute schedules from these client-side (D-09) — the backend
     *  care engine is the sole scheduler. */
    val wateringIntervalDays: Double? = null,
    val feedingIntervalDays: Double? = null,
    val sunHoursTarget: Double? = null,
    val frostSensitive: Boolean? = null,
    val commonIssues: List<String> = emptyList(),
)
```

### 5b. `DtoMappers.kt`

Old:
```kotlin
fun PlantProfileDto.toDomain(): PlantProfile = PlantProfile(
    id = id,
    scientificName = scientificName,
    commonNames = commonNames,
    category = category,
)
```
New:
```kotlin
fun PlantProfileDto.toDomain(): PlantProfile = PlantProfile(
    id = id,
    scientificName = scientificName,
    commonNames = commonNames,
    category = category,
    wateringIntervalDays = wateringProfile["baseIntervalDays"]?.jsonPrimitive?.doubleOrNull,
    feedingIntervalDays = feedingProfile["baseIntervalDays"]?.jsonPrimitive?.doubleOrNull,
    sunHoursTarget = lightProfile["targetSunHours"]?.jsonPrimitive?.doubleOrNull,
    frostSensitive = temperatureProfile["frostSensitive"]?.jsonPrimitive?.booleanOrNull,
    commonIssues = commonIssues ?: emptyList(),
)
```
Add imports: `kotlinx.serialization.json.jsonPrimitive`,
`kotlinx.serialization.json.doubleOrNull`, `kotlinx.serialization.json.booleanOrNull`.
(`:data` already depends on kotlinx-serialization via `:network`'s DTOs — no
dependency change. If the compiler disagrees, STOP and write a BLOCKED report
rather than adding a dependency.)

NOTE on malformed values: `jsonPrimitive` THROWS if the element is a nested
object/array rather than a primitive. The catalog controls these fields (they
are schema-validated numbers), but to keep the mapper total, wrap each
extraction exactly like:
`wateringProfile["baseIntervalDays"]?.let { runCatching { it.jsonPrimitive.doubleOrNull }.getOrNull() }`
— apply the same `runCatching` shape to all four extractions.

### 5c. Red-first test — add to `InventoryRepositoryImplTest.kt`

Match the file's existing style (it builds `InventoryRepositoryImpl` over
`FakePlantAppApi`); the fake's catalog fixture is tomato with
wateringProfile.baseIntervalDays=2, feeding=7, targetSunHours=8,
frostSensitive=true and NO commonIssues:

```kotlin
    @Test
    fun `getPlantProfiles maps the care basics from the catalog dto`() = runTest {
        val profile = repository.getPlantProfiles().first()
        assertEquals(2.0, profile.wateringIntervalDays)
        assertEquals(7.0, profile.feedingIntervalDays)
        assertEquals(8.0, profile.sunHoursTarget)
        assertEquals(true, profile.frostSensitive)
        assertEquals(emptyList<String>(), profile.commonIssues)
    }
```
(Adapt the repository construction/assertion imports to the file's existing
pattern — ground in its current content. `assertEquals(Double, Double?)` overload
ambiguity: if the compiler complains, assert with `assertEquals(2.0, profile.wateringIntervalDays!!, 0.0)`
or compare boxed values — keep it simple and consistent with the file.)

## 6. Expected failure modes (not regressions)

- §7 step 1 RED: the new test FAILS TO COMPILE (`unresolved reference:
  wateringIntervalDays`) — for a purely additive model field there is no
  compiling-red; this compile failure is the stated, expected red. Capture the
  compiler error. Nothing else may fail.
- After implementation, all existing `:domain`/`:data`/`:feature-inventory`
  tests must stay green — the new fields have defaults, so the 12 existing
  positional `PlantProfile(...)` 4-arg call sites compile unchanged. If any
  existing test breaks, that IS a regression.
- Gradle deprecation warnings: pre-existing, ignore.

## 7. Standalone verification (red → green, objective)

From `/home/israel/Documents/Development/PlantApp/android`,
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

**Step 1 — RED:** add ONLY the §5c test, then:
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest --tests "dev.plantapp.data.InventoryRepositoryImplTest"
```
Expected: compilation fails with `unresolved reference` on the new field names.
If it compiles and passes, STOP — baseline mismatch (fields already exist?).

**Step 2 — implement** §5a + §5b.

**Step 3 — GREEN:**
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest :feature-inventory:testDebugUnitTest :app:assembleDebug
```
All suites green (report actual counts; `:feature-inventory` was 48 after 0066 —
must be unchanged) and the app assembles. NOTE the `:domain` test task is
`:domain:test` (JVM module), not testDebugUnitTest.

## 8. Commit title (Conventional Commits, exact)

```
feat(domain): carry catalog care basics into PlantProfile (watering, feeding, sun, frost, issues)
```

## 9. Push requirement

`git push origin master` — fast-forward from `3243ae7`. Confirm new `origin/master`.

## 10. Final report requirements

Report to `exchange/implementation-inbox/0067-care-basics-domain/` via the
report script. Include: scope confirmation (3 files) + `git show --stat HEAD`;
RED evidence (the compile error); GREEN counts for all four Gradle tasks; new
commit hash + push confirmation; deviations (or "none").
