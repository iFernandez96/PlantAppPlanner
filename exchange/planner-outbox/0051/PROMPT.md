# Implementation prompt 0051 — HOTFIX: wizard location kinds violate the DB constraint (silent Add brick)

## 1. Scope (exactly one logical change)
**Bug (found in on-device review, blocker-grade):** 3 of the 4 wizard location presets send
`kind` values the database rejects. `WizardModel.kt` presets send `windowsill`, `yard`, `indoor`,
but `supabase/migrations/0002_slice1_garden_spaces.sql` only allows
`'balcony','patio','window-ledge','indoor-room','vertical-rack-zone','hanging-zone',
'grow-light-shelf','other'`. The space create 400s
(`garden_spaces_kind_check`), the wizard's Add button is gated on the created space id, and the
user sees a **permanently disabled Add with no error**. Reproduced live on-device; only Balcony
works.

**Fix (UI-side mapping; no migration):** make the presets send DB-allowed kinds — labels
unchanged:
- "Windowsill" → kind `window-ledge` (was `windowsill`)
- "Balcony" → `balcony` (unchanged)
- "Backyard" → kind `other` (was `yard`; no closer enum value — do NOT extend the DB constraint
  in this slice)
- "Indoors" → kind `indoor-room` (was `indoor`)

Red-first: add a model test asserting every preset kind is in the DB-allowed set — it fails on
current code, passes after the fix.

(Surfacing create-failures in the wizard UI is a separate follow-up slice — do NOT add it here.)

## 2. Forbidden changes
- Do NOT touch `supabase/**` (no constraint change), backend, schemas, `:domain`, `:data`,
  `:network`, `:app`, `:design-system`, gradle/manifest.
- Do NOT change preset labels, tile layout, icons' visual choices, or any other wizard logic.
- No new dependencies.

## 3. Exact files to touch (4, all under `android/feature-inventory/src/`)
1. `main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt` — `LOCATION_PRESETS`
   (lines 23–28): `"windowsill"`→`"window-ledge"`, `"yard"`→`"other"`, `"indoor"`→`"indoor-room"`.
2. `main/kotlin/dev/plantapp/feature/inventory/addplant/WizardIcons.kt` — `locationIcon` keys
   (lines 42–48): `"windowsill"`→`"window-ledge"` (WbSunny), `"yard"`→`"other"` (Cottage),
   `"indoor"`→`"indoor-room"` (Home); `else` branch stays.
3. `test/kotlin/dev/plantapp/feature/inventory/AddPlantWizardTest.kt` — lines 119 & 126:
   tile tag `+ "windowsill"` → `+ "window-ledge"` (line 88 `"balcony"` unchanged).
4. `test/kotlin/dev/plantapp/feature/inventory/AddPlantWizardModelTest.kt` — update the expected
   label→kind pairs (lines ~31–34) to the new kinds, and ADD (red-first) a test:
   ```kotlin
   @Test
   fun `location preset kinds are accepted by the garden_spaces DB constraint`() {
       val allowed = setOf(
           "balcony", "patio", "window-ledge", "indoor-room",
           "vertical-rack-zone", "hanging-zone", "grow-light-shelf", "other",
       ) // mirrors supabase/migrations/0002_slice1_garden_spaces.sql
       AddPlantWizardModel.LOCATION_PRESETS.forEach { preset ->
           check(preset.kind in allowed) { "preset '${preset.label}' sends invalid kind '${preset.kind}'" }
       }
   }
   ```

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `cbe520ba263c197e3609c3bf6f939f539f77cac2` (0050).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# 1) RED: add ONLY the new §3.4 constraint test, run:
cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
#    -> expect the new test to FAIL on 'windowsill' (capture the failure line)
# 2) GREEN: apply the §3.1–3.3 changes + the remaining §3.4 expected-pair updates, re-run the suite
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
Step 1 (red): exactly the new constraint test fails (`preset 'Windowsill' sends invalid kind
'windowsill'`). Any OTHER failure in step 1 is a pre-existing regression: STOP and report.
Step 2 (green): full suite passes; any failure is a regression: STOP, revert, report.

## 7. Standalone verification
- **Type:** red-first → green (the new constraint test is the standalone proof).
- **Commands & what they prove:**
  1. The red run output (new test failing on current kinds) — proves the test really guards the bug.
  2. The green run (full `:feature-inventory` suite passes) — proves the fix + no regression.
  3. `grep -c "window-ledge\|indoor-room" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt` → `2`; `grep -c "\"yard\"\|\"windowsill\"\|\"indoor\"" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardIcons.kt` → `0` for both files (old kinds gone).
  4. `:app:assembleDebug` → BUILD SUCCESSFUL.
- **Report:** red failure line, green test count, grep outputs, assemble result — verbatim.

## 8. Commit title (exact)
```
fix(wizard): map location presets to DB-allowed garden-space kinds (silent Add-button brick)
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0051/`: `git show --stat HEAD` (exactly the 4 files),
red+green evidence per §7, new commit hash, push confirmation (new `origin/master`), scope
confirmation (no supabase/backend changes; labels unchanged).
