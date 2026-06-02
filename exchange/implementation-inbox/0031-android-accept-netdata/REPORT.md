# DONE — handoff 0031-android-accept-netdata (3d-android net+data, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the `0030` accept endpoint is wired into Android's network+data layers — a `:network`
`acceptAdvisory` call + request DTO, a `:domain` port method, the `:data` impl, and the test-fake
update. No UI (that is 3d-android-ui). Three modules' unit tests green. Final `origin/master` =
`bfdd946108ffb31b45f66e80177e9aff9734e949`.

## Baseline + unblock
- HEAD at start = `53d093e…` == origin/master; clean. SDK resolves (Drive mounted).

## What was added
1. **`:network` `Dtos.kt`** — `@Serializable data class AcceptAdvisoryRequest(val kind: String)`
   (body `{ "kind": "<advisory kind>" }`).
2. **`:network` `PlantAppApi.kt`** —
   `@POST("plants/{id}/advisories/accept") suspend fun acceptAdvisory(@Path("id") id: String,
   @Body body: AcceptAdvisoryRequest): CareTaskDto`.
3. **`:domain` `InventoryRepository.kt`** — `suspend fun acceptAdvisory(plantId: String, kind:
   String): CareTask` (KDoc: backend computes the deterministic task; D-09, no on-device care
   logic).
4. **`:data` `InventoryRepositoryImpl.kt`** — `override … acceptAdvisory(plantId, kind) =
   api.acceptAdvisory(plantId, AcceptAdvisoryRequest(kind)).toDomain()` (+ import).
5. **`:data` test `FakePlantAppApi.kt`** — `var lastAccept: Pair<String,String>? = null`;
   `override suspend fun acceptAdvisory(id, body) = task.also { lastAccept = id to body.kind }`
   (+ import). Keeps the fake implementing the full `PlantAppApi` so `:data` compiles against the
   new interface method (the 0021→0022 lesson).

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest :domain:test :data:testDebugUnitTest
BUILD SUCCESSFUL in 19s
```
- **`:network` `AcceptAdvisoryDtoTest`** (new): 1 test —
  `acceptAdvisoryRequestEncodesKindAndRoundTrips` (JSON contains `"kind":"container-size"`,
  round-trips). `:network` total **16 → 17**.
- **`:data` `InventoryRepositoryImplTest`** +1: `acceptAdvisoryMapsTheReturnedCareTask` —
  `repo.acceptAdvisory(plant.id, "container-size")` → fake recorded `(plant.id, "container-size")`
  and the result's `id`/`kind`/`engineVersion` map from the fake's canned `task`. File **7 → 8**;
  `:data` total **10 → 11**.
- **`:domain`** compiles against the new port; `InventoryModelsTest` 2/2 unchanged.
- All prior tests green.

## Commit
- `bfdd946` — feat(android): acceptAdvisory network call + repository method
- `git show --stat HEAD`: 7 files, +48 — only `android/network/**` (Dtos, PlantAppApi,
  AcceptAdvisoryDtoTest) + `android/domain/**` (InventoryRepository) + `android/data/**`
  (InventoryRepositoryImpl, FakePlantAppApi, InventoryRepositoryImplTest). `local.properties` NOT
  committed (grep 0).

## Compliance
- No `:feature-inventory`/`:app`/backend/`shared-schemas`/`supabase` change (UI is next). No new
  dependency. No camera/photos/GPS/notifications/AI. No on-device care logic — the client only
  calls the backend; the deterministic task is computed server-side (D-09). SDK/Drive untouched.

Final `origin/master` SHA: `bfdd946108ffb31b45f66e80177e9aff9734e949`

## Next (3d-android-ui, per planner follow-up — final 3d step)
`PlantDetailScreen` "Accept" action per advisory → `PlantDetailViewModel.accept(plantId, kind)`
over `repository.acceptAdvisory` → reload tasks/advisories on success; show only on acceptable
kinds (`container-size`/`support`) or surface the 400 for `pollination`; + Robolectric tests.
After it lands, backlog (3) UX follow-ups is complete.
