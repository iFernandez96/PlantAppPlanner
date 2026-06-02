# Next Implementation Prompt — real sourced icons for the add-plant wizard (replace placeholders)

**Beginner UX, icon upgrade (owner: "do not create your own svg icons — find them online and
include them").** The wizard's hand-authored placeholder vectors are weak (the on-device review
found **all 6 pot options show the identical flowerpot**, and passion-fruit/tomatillo read poorly).
Replace them with **real, openly-licensed icons sourced online**:
- **Species (5):** **CC0** crop SVGs from `openfarmcc/open-crop-icons` (public domain — bundle
  freely): `tomato`, `basil`, `strawberry`, `tomatillo`, and `generic-plant` (the set has no passion
  fruit) → converted to Android vector drawables.
- **Pots (6) + locations (4):** **Material Symbols** (Apache-2.0) via the `material-icons-extended`
  Compose dependency — pick **distinct** glyphs so the six pot sizes are NOT identical.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`5f1e7ce102a3ad219cedd38bb75c186752da4b17` == `origin/master`, clean. `:feature-inventory` has the
wizard: `addplant/AddPlantWizard.kt`, `addplant/WizardIcons.kt`
(`speciesIconRes`/`locationIconRes`/`potIconRes` → `@DrawableRes`), and 11 hand-authored
placeholder drawables `res/drawable/ic_species_*`, `ic_loc_*`, `ic_pot.xml`. `AddPlantWizardModel`
has `POT_SIZES` (6) + `LOCATION_PRESETS` (4). Catalog ids: `solanum-lycopersicum`,
`ocimum-basilicum`, `fragaria-x-ananassa`, `passiflora-edulis`, `physalis-philadelphica`.
**Confirmed live:** `https://raw.githubusercontent.com/openfarmcc/open-crop-icons/mainline/icons/tomato/tomato.svg`
(CC0); folders `basil`, `strawberry`, `tomatillo`, `generic-plant` all exist on branch `mainline`.

Single logical change (swap placeholder icons for sourced real icons) → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Replace the
placeholder wizard icons with real, openly-licensed sourced icons. **Consult the Android "import
SVG as Vector Asset" / vector-drawable docs and the Material Symbols (`material-icons-extended`)
docs.**

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 5f1e7ce102a3ad219cedd38bb75c186752da4b17 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **Species icons — download the CC0 SVGs + convert to vector drawables** into
   `android/feature-inventory/src/main/res/drawable/`:
   ```bash
   B=https://raw.githubusercontent.com/openfarmcc/open-crop-icons/mainline/icons
   for c in tomato basil strawberry tomatillo generic-plant; do curl -fsSL "$B/$c/$c.svg" -o "/tmp/crop-$c.svg"; done
   ```
   Convert each `/tmp/crop-*.svg` to an Android `<vector>` drawable (use Android Studio's vector
   import, `vd-tool`, or a reliable SVG→vector-drawable converter; verify it renders — no missing
   paths). Name them `ic_species_tomato.xml`, `ic_species_basil.xml`, `ic_species_strawberry.xml`,
   `ic_species_tomatillo.xml`, `ic_species_passionfruit.xml` (← from `generic-plant.svg`) +
   keep/repoint `ic_species_default.xml` (use `generic-plant` too). If any download 404s or won't
   convert, **STOP and report** (don't hand-draw a replacement). These are CC0 — no attribution
   required, but record the source.
2. **Pots + locations — Material Symbols (no asset files):** add the dependency
   `androidx.compose.material:material-icons-extended` (add to `:feature-inventory` deps + the
   version catalog) and map to **distinct** `ImageVector`s. Requirement: the **six pot sizes must
   not all look identical** — e.g. small pots (4-inch/6-inch/1-gallon) → a potted-plant glyph,
   **5-gallon bucket** → a clearly different vessel glyph, **Window box** → a window/planter glyph,
   **Raised bed / in-ground** → a yard/grass/garden glyph. Locations → distinct glyphs (Windowsill →
   window/sunny, Balcony → balcony, Backyard → yard/grass/cottage, Indoors → home/sofa). Pick the
   nearest sensible Material symbols; it's fine to share one glyph among the 3 small pots (the label
   gives the size), but bucket/window-box/raised-bed must differ.
3. **Rework `WizardIcons.kt`** so species return drawable resources (`@DrawableRes
   speciesIconRes(profileId)` → the new crop drawables, `passiflora-edulis` → `ic_species_passionfruit`,
   fallback `ic_species_default`) and pots/locations return Material `ImageVector`s
   (`potIcon(label/index): ImageVector`, `locationIcon(kind): ImageVector`). Update
   `AddPlantWizard.kt` to render species via `Image(painterResource(...))` and pots/locations via
   `Icon(imageVector = ...)`. Keep all existing test tags + behavior.
4. **Delete the placeholder drawables** that are now unused (`ic_loc_*.xml`, `ic_pot.xml`, and any
   old hand-drawn `ic_species_*` you replaced). No orphans.
5. **License note:** add a short `android/feature-inventory/src/main/res/drawable/ICON_LICENSES.md`
   (or a repo `NOTICE`): species icons = open-crop-icons (CC0/public domain); pot/location icons =
   Material Symbols (Apache-2.0). (Apache requires preserving the license notice.)

### Forbidden
- **No emoji.** **Do NOT author/hand-draw your own icons** — use only the sourced CC0 crop icons +
  Material Symbols. No raster/PNG (vectors only — convert SVG→vector-drawable). No copied art from
  attribution-required/paid sets (only CC0 + Apache as specified). No `:network`/`:data`/`:domain`/
  backend/schema change. No litres/jargon surfaced. No camera/photos/GPS/AI. Don't commit
  `android/local.properties`; don't mount/repoint the SDK/Drive.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Expected: existing wizard/feature tests still pass (icon swap is presentation — update any
icon-resource references in tests, but the behavioral assertions stand) and `:app:assembleDebug`
compiles with `material-icons-extended` added. Report counts + assemble result.
**Expected (not a regression):** tests that referenced the old `ic_*` resource ids will need their
references updated to the new drawables — that's an expected edit, distinct from a real compile/test
failure. (Final icon look is
the owner's on-device call — the planner will rebuild + reinstall for a device review.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/gradle/libs.versions.toml
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): real sourced wizard icons (CC0 crop SVGs + Material Symbols) replacing placeholders"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The species drawables added (from open-crop-icons CC0, list them + note passion-fruit→generic-plant),
   the Material-Symbols mapping for the 6 pots (confirm bucket/window-box/raised-bed are visually
   distinct) + 4 locations, the `WizardIcons`/`AddPlantWizard` rework, deleted placeholders, and the
   license note.
2. `:feature-inventory:testDebugUnitTest` + `:app:assembleDebug` results.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `libs.versions.toml` changed; confirm no emoji, no hand-drawn
   icons, no raster.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; sourced CC0 + Material icons; pots visually distinct; license note; tests green;
assemble OK). Then **rebuild the LAN APK + reinstall** for an owner device-review of the new icons
(backend is still up). Then the **copy sweep** — which must also fix the **Plant detail screen** the
walkthrough flagged as the worst-for-novices: it shows the **scientific-name slug** (`solanum-lycopersicum`)
instead of "Tomato", the raw engine rationale ("base interval 2d adjusted by container factor 1;
baseline <ISO>"), the **"engine v0.1.0" badge**, and ISO timestamps — all developer-facing; plus
friendlier sign-in instructions, the confirm-screen should echo the pot choice, and friendly advisory
copy. Vision-check each.
