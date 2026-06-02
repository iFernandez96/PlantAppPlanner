# Next Implementation Prompt — a3a: :domain + :data (repository over :network)

**Milestone a (Android UI), step a3a.** Build the `:domain` (pure-Kotlin models + a
repository port) and `:data` (repository impl over `:network`, DTO↔domain mapping,
DataStore for base URL + auth token) layers, JVM-tested. No Compose/UI yet (a3b). Android
treats backend tasks as **opaque domain values** (D-09 — no care logic on device).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `f6c8155` == `origin/master`,
clean. `:network` has camelCase DTOs + `PlantAppApi` (Retrofit) + factory, JVM-tested
(schema-validated). `:app:assembleDebug` builds. Build with
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`, no concurrent gradlew runs.

Two commits: (1) red `:domain`/`:data` tests; (2) green models + repository.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Build the
`:domain` and `:data` modules. **Consult the official Hilt + DataStore + kotlinx.coroutines
docs.** Build/test with `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect f6c8155ac6618e493d46c82d53ea9c8021d83161
git status --short                         # expect empty
```

### Scope
**`:domain`** (pure Kotlin/JVM — no Android, no serialization):
- Domain models for the Slice 1 inventory: e.g. `NewPlant` (input: profileId, containerId,
  gardenSpaceId, growthStage, optional nickname/cultivar/placement/lastWateredAt),
  `Plant`, `CareTask` (id, kind, dueAt, priority, rationale, engineVersion, inputsHash,
  status — treated as opaque, backend-computed), and minimal `GardenSpace`/`Container` as
  needed. Clean Kotlin types (no `@Serializable`).
- A repository **port** interface, e.g. `InventoryRepository`:
  `createGardenSpace(...)`, `createContainer(...)`, `addPlant(NewPlant): AddPlantResult`
  (plant + its initial CareTask), `getPlants()`, `getPlantTasks(plantId)`,
  `deletePlant(plantId)`. Suspend functions; return domain types or a small `Result` wrapper.

**`:data`** (android-library):
- `InventoryRepositoryImpl` implementing the port by calling `:network`'s `PlantAppApi`
  and **mapping DTO↔domain** (both directions). Map `CareTaskDto`→domain `CareTask`, etc.
- A DataStore (Preferences) holding the API **base URL** + **auth token** (provider the
  `:network` `AuthTokenProvider` reads). No hard-coded secrets.
- A **Hilt** module (`@Module`/`@InstallIn`) providing `PlantAppApi` (via the `:network`
  factory) + binding `InventoryRepository` → impl.
- **Defer Room** — Slice 1 reads live from the backend (in-app display only); no offline
  cache yet (add Room in a later slice when offline scheduling is needed). Do not add Room
  entities/DAOs now.

### Tests — `:domain/src/test` + `:data/src/test` (JVM unit; no emulator)
- `:domain`: any pure model/use-case logic (likely light).
- `:data`: `InventoryRepositoryImpl` mapping tests against a **fake** `PlantAppApi` (hand-
  written fake or MockK — if you use MockK, add it test-only to the catalog). Assert:
  `addPlant` maps `AddPlantResponse`→domain (plant + one water `CareTask` with
  engineVersion/inputsHash/dueAt/rationale), `getPlants`/`getPlantTasks` map lists,
  `deletePlant` calls the API. Use coroutines-test for suspend funcs.

### Forbidden
- No Compose/UI/ViewModels (that's a3b). No Room (deferred). No CameraX/FCM/WorkManager/
  AI SDK/Ktor/`:care-engine` module. No care-scheduling logic in Android (D-09 — tasks are
  opaque backend output). Don't touch `backend/**`, `shared-schemas/**`, `supabase/**`,
  `:network` source, or `:feature-inventory`.
- Production deps only from the existing catalog (Retrofit/OkHttp/kotlinx/Hilt/DataStore/
  coroutines). Test-only additions (MockK) are fine.

### Verify (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest --no-daemon
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug --no-daemon   # still BUILD SUCCESSFUL
```
Red-first: write the mapping tests first (red — models/repo don't exist), then implement →
green. If Hilt/KSP wiring fails for an environment reason, STOP and report.

### Commits
1. `test(android-data): add Slice 1 repository mapping tests` (RED)
2. `feat(android-domain-data): add inventory domain models + repository over :network` (GREEN)
Push after each.

### Final report
1. Commit hashes + titles; final `origin/master` SHA.
2. `:domain:test` / `:data:testDebugUnitTest` RED→GREEN counts; `:app:assembleDebug` OK.
3. `git show --stat` per commit; modules/files added; confirm no Compose/Room/forbidden
   deps, no care logic on device, and `backend/**`/`:network` source untouched.
4. The repository port operations + how the base URL/token flow via DataStore →
   `AuthTokenProvider` (for a3b wiring).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after a3a lands
Verify `:domain`/`:data` tests green + skeleton assembles. Then **a3b** (closes Slice 1):
`:feature-inventory` Compose screens — add-plant form, plant list, plant detail showing the
water task (rationale, engineVersion badge, formatted dueAt) — + ViewModels (Hilt) +
navigation, wired to `InventoryRepository`, with Compose UI tests **#21–#24** (empty state;
add-plant flow navigates to detail; detail shows the water task; missing-container
validation blocks navigation) — Robolectric-first to avoid an emulator. Vision-check a3b.
