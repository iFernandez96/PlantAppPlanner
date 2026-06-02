# Beginner-First Add-Plant Wizard — Spec (owner-approved 2026-06-02)

Replaces the current jargon form (`AddPlantScreen`). Driven by `[[beginner-first-ux]]`: usable by an
elderly / total-novice non-gardener. **No litres, no "material/drainage", no "growth stage", no ISO
dates shown.** Big icon+plain-name tappable tiles, smart defaults, plain language; the deterministic
engine derives technical values from simple choices. Owner choices: **3-step wizard · icon+name
tiles · add-plant first (then a copy sweep) · pot sizes labeled "how pots are sold".**

## Flow — one screen, internal step state (1 → 2 → 3 → confirm), Back/Next, big targets

### Step 1 — "What are you growing?"
- Grid of big tiles, one per catalog species from `getPlantProfiles()`: **icon (by category) +
  common name** (`commonNames.first()`). Search box if the list grows.
- **Icons (NO emoji). SUPERSEDED 2026-06-02:** owner directive after the device review — **"do not
  create your own svg icons; find them online and include them."** So instead of authoring originals
  (`0042`'s hand-drawn placeholders were weak — identical pot for all 6 sizes), `0043` sources **real
  openly-licensed icons**: **species (5)** from `openfarmcc/open-crop-icons` (**CC0**: tomato, basil,
  strawberry, tomatillo + `generic-plant` for passion fruit) → vector drawables; **pots (6) +
  locations (4)** from **Material Symbols** (Apache-2.0) via `material-icons-extended`, mapped to
  **distinct** glyphs (bucket/window-box/raised-bed must differ). `profileId → drawable` map,
  fallback for unknown. Emoji `categoryIcon` removed in `0042`. Owner approves the look on-device.
- Picks `profileId`.

### Step 2 — "Where will it live?"
- Tiles: any existing garden spaces, then presets (auto-create on pick via `createGardenSpace`):
  🪟 **Windowsill** (kind `windowsill`) · 🏞️ **Balcony** (`balcony`) · 🏡 **Backyard** (`yard`) ·
  🛋️ **Indoors** (`indoor`).
- Picks/creates `gardenSpaceId`.

### Step 3 — "What's it planted in?" (sizes = how pots are sold)
- Tiles, each → `volumeLiters` behind the scenes (user never sees litres):
  | Choice | volumeLiters |
  |---|---|
  | 4-inch pot | 0.5 |
  | 6-inch pot | 1.5 |
  | 1-gallon pot | 4 |
  | 5-gallon bucket | 19 |
  | Window box | 6 |
  | Raised bed / in-ground | 75 |
- Hidden defaults: `material = "plastic"`, `drainage = "good"`. Creates the container via
  `createContainer(name = "<species> – <size label>", volumeLiters, material, drainage)`.
- (These map into the existing care engine: container factor = clamp(vol/recommendedMin, .5, 1.5);
  the container-size advisory still fires when a chosen size < the species' recommended min —
  surfaced later in **friendly** copy.)

### Confirm — "Add your {Tomato} to the {Balcony}?"
- Big **Add** button → `addPlant(NewPlant(profileId, containerId, gardenSpaceId, growthStage =
  "seedling"))`. `growthStage` defaulted (hidden); `lastWateredAt` omitted (engine uses createdAt).
- On success: friendly confirmation (e.g., "🌱 Added! We'll remind you when it needs water.") →
  navigate to the plant detail.

## Out of scope here (later "sweep" pass)
- Friendlier sign-in / list / detail copy; **friendly advisory wording** (e.g. "This pot is a bit
  small for a passion fruit — a bigger one will help it thrive" instead of "prefers ≥95 L").
- Plant photos (emoji for now). Accessibility polish (large text/targets) baked in from the start.

## Build decomposition (red-first)
- **H1 (`0041`): pure wizard model** in `:feature-inventory` (or `:domain`) — `PotSizeOption`
  (label + volumeLiters), `LocationPreset` (label + kind), `categoryIcon(category)`. Pure +
  unit-tested. No UI.
- **H2 (`0042`): the `AddPlantWizard` composable** (3 steps + confirm) replacing `AddPlantScreen`,
  using H1 + the existing `AddPlantViewModel` (profiles/create/submit) + `:app` route wiring +
  Robolectric tests.
- Then the **copy sweep** epic (sign-in/list/detail + advisory wording).

## Open knobs (sensible defaults chosen; easy to tweak)
- The litres mapping above (esp. raised-bed = 75 L) and the 4 location presets — adjustable.
