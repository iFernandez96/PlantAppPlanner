# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `ce59e5e` — feat(android-network): PlantProfileDto + list calls for profiles/spaces/containers |
| Local == origin/master? | ✅ yes (`ce59e5e` both sides) |
| `0021` commits | `ce59e5e` (single commit; 4 files `android/network/**`, +64) |
| Uncommitted changes? | none (clean; git-ignored `android/local.properties` may exist locally) |
| CI / workflows / checks / PRs / issues | **none** — no CI, no open PRs, no open issues |
| Default branch | `master` |

`0021` verified vs real git: `git diff c7b8c54 ce59e5e` = only `android/network/**` (Dtos.kt,
PlantAppApi.kt, DtoFixtures.kt, SchemaValidationTest.kt); `local.properties` not committed;
backend/`:data`/`:domain`/`:feature-inventory`/`:app` untouched. `:network` SchemaValidationTest
4→5 (new `plantProfileDtoConformsToSchema` green). (`0020` blocked on unmounted-Drive SDK; owner
re-mounted; `0021` re-ran green.)

**KNOWN (latent, being fixed):** `0021` added 3 abstract methods to `PlantAppApi` without
updating the `:data` test double `FakePlantAppApi`, so **`:data:testDebugUnitTest` compile is red
on `ce59e5e`**. Not caught by `0021`'s `:network`-only gate. **`0022-android-data-lists`**
(published, IN FLIGHT) fixes it red→green while adding the `:domain`/`:data` list layer. Vision
ALIGNED. Watcher armed for `0022`.
