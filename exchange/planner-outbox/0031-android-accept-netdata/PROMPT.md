# Next Implementation Prompt — backlog (3d-android net+data): `acceptAdvisory` client + repo

**Backlog item (3) UX follow-ups, step 3d, part 3 (Android network+data).** Wire the `0030`
`POST /plants/:id/advisories/accept` into Android: a `:network` call + request DTO, a `:domain`
repository method, and the `:data` implementation (+ test fake update). **No UI** — the
detail-screen "Accept" button is the final handoff (3d-android-ui). Network+data are combined in
one commit because adding a method to the `PlantAppApi` interface breaks the `FakePlantAppApi` test
double until it's updated (the lesson from `0021`→`0022`).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`53d093e0ee570dcaf1e44a926dfb343935f6c7a8` == `origin/master`, clean. `:network` `PlantAppApi`
has the Slice-1/2 calls + `getPlantProfiles/getGardenSpaces/getContainers`; `Dtos.kt` has request
DTOs (`CreateGardenSpaceRequest`, `AddPlantRequest`, …) + `CareTaskDto`. `:domain`
`InventoryRepository` + `CareTaskDto.toDomain(): CareTask` (in `:data` `DtoMappers.kt`). `:data`
`InventoryRepositoryImpl` implements every port method; the test double
`FakePlantAppApi : PlantAppApi` (in `:data` test) implements every `PlantAppApi` method and has a
canned `task: CareTaskDto`. Backend `POST /plants/:id/advisories/accept` returns a `CareTask`
(`kind` `repot`/`support`).

Single logical change (the Android accept network+data path) → one commit. Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
`acceptAdvisory` network call + repository method (no UI). Red-first: write the tests first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 53d093e0ee570dcaf1e44a926dfb343935f6c7a8 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`:network` `Dtos.kt`** — add `@Serializable data class AcceptAdvisoryRequest(val kind: String)`
   (request body for the accept endpoint; matches `{ "kind": "<advisory kind>" }`).
2. **`:network` `PlantAppApi.kt`** — add:
   ```kotlin
   @POST("plants/{id}/advisories/accept")
   suspend fun acceptAdvisory(@Path("id") id: String, @Body body: AcceptAdvisoryRequest): CareTaskDto
   ```
3. **`:domain` `InventoryRepository.kt`** — add `suspend fun acceptAdvisory(plantId: String, kind:
   String): CareTask`.
4. **`:data` `InventoryRepositoryImpl.kt`** — `override suspend fun acceptAdvisory(plantId: String,
   kind: String): CareTask = api.acceptAdvisory(plantId, AcceptAdvisoryRequest(kind)).toDomain()`
   (import `AcceptAdvisoryRequest`).
5. **`:data` test `FakePlantAppApi.kt`** — implement the new override: record the last
   `(plantId, kind)` and return the existing canned `task` (`CareTaskDto`). e.g.
   `var lastAccept: Pair<String,String>? = null` and `override suspend fun acceptAdvisory(id, body)
   = task.also { lastAccept = id to body.kind }`.

### Tests
- **`:network` `AcceptAdvisoryDtoTest.kt`** (new, mirror `AuthDtoTest`/`DtoSerializationTest`):
  `AcceptAdvisoryRequest("container-size")` encodes to JSON containing `"kind":"container-size"`
  and round-trips.
- **`:data` `InventoryRepositoryImplTest.kt`** — add `acceptAdvisory maps the returned CareTask`:
  `repo.acceptAdvisory(api.plant.id, "container-size")` → the fake recorded `(plant.id,
  "container-size")` and the result is the domain `CareTask` (`kind`/`id` mapped from the fake's
  `task`).

### Forbidden
- No `:feature-inventory`/`:app`/backend/`shared-schemas`/`supabase` change (UI is the next
  handoff). No new dependency. No camera/photos/GPS/notifications/AI. No on-device care logic — the
  client just calls the backend; the deterministic task came from the engine server-side (D-09).
  Don't mount/repoint the SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest :domain:test :data:testDebugUnitTest
```
Red→green: before, the new tests + the `FakePlantAppApi` override don't exist (and `:data`
wouldn't compile against the new interface method); after, all three modules' unit tests pass (new
`:network` + `:data` accept tests green; prior tests green). Report counts + new test names.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/network/ android/domain/ android/data/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android): acceptAdvisory network call + repository method"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The `AcceptAdvisoryRequest` DTO, the `acceptAdvisory` API method + port + impl, and the
   `FakePlantAppApi` override.
2. `:network`/`:domain`/`:data` test results (counts before→after; new tests green; prior green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/network/**` + `android/domain/**` + `android/data/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only network/domain/data; accept method + fake; all three modules green). Then
**3d-android-ui** (final 3d step): a `PlantDetailScreen` **"Accept"** action per advisory →
`PlantDetailViewModel.accept(plantId, kind)` over `repository.acceptAdvisory` → on success reload
tasks/advisories; show only on acceptable kinds (`container-size`/`support`) or surface the 400 for
`pollination`; + Robolectric tests. **After it lands, backlog (3) UX follow-ups is COMPLETE.** Then
(2) emulator e2e smoke; then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM
setup). Vision-check each product-surface step.
