# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `20f4e35` — feat(android-inventory): profile dropdown selector for add-plant |
| Local == origin/master? | ✅ yes (`20f4e35` both sides) |
| `0023` commits | `20f4e35` (single commit; 5 files `feature-inventory`+`app`, +86/−10) |
| Uncommitted changes? | none (clean; git-ignored `android/local.properties` may exist locally) |
| CI / workflows / checks / PRs / issues | **none** — no CI, no open PRs, no open issues |
| Default branch | `master` |

`0023` verified vs real git: `git diff 3fba718 20f4e35` = only `android/feature-inventory/**` +
`android/app/**` (MainActivity, AddPlantScreen, InventoryTestTags, InventoryViewModels,
InventoryScreensTest); `FIELD_PROFILE_ID` removed; `:network`/`:data`/`:domain`/backend untouched;
`local.properties` not committed. `InventoryScreensTest` 5/5 (updated #22/#24 + new dropdown test),
`:app:assembleDebug` BUILD SUCCESSFUL.

**"Do all" loop RUNNING.** (1)✅ (3a)✅ (3b-network)✅ (3b-data)✅ (3b-ui-a profile dropdown)✅.
**3b-ui-b `0024-android-gardenspace-selector` published & IN FLIGHT:** garden-space
select-or-create (dropdown from `getGardenSpaces()` + inline create via `createGardenSpace`,
name+kind only — no location) + VM + `:app` wiring + Robolectric tests. Gate:
`:feature-inventory:testDebugUnitTest` + `:app:assembleDebug`. Vision ALIGNED. Watcher armed for
`0024`.
