## 1. Garden Hearth

**Identity:** A warm, familiar “kitchen table garden planner” that keeps Verdant Glasshouse’s botanical soul but makes it calmer, clearer, and more tactile for beginners.

**Relationship To Verdant Glasshouse:** Evolves it. Keep the cream/green foundation, Fraunces + Manrope, and soft organic atmosphere, but reduce glassiness and make surfaces more opaque/readable.

**Color System**

Light:
- `primary`: `#2F6B45`
- `onPrimary`: `#FFFFFF`
- `primaryContainer`: `#D7EEDB`
- `onPrimaryContainer`: `#10351F`
- `secondary`: `#9A6B3F`
- `secondaryContainer`: `#F4DEC4`
- `tertiary`: `#3D7D87`
- `background`: `#F8F3E7`
- `surface`: `#FFFDF6`
- `surfaceVariant`: `#E7DED0`
- `outline`: `#8A8174`

Dark:
- `primary`: `#94D8AA`
- `onPrimary`: `#07331A`
- `primaryContainer`: `#245236`
- `secondary`: `#E7BE8E`
- `secondaryContainer`: `#5B3E22`
- `tertiary`: `#96D7DF`
- `background`: `#111711`
- `surface`: `#1B211B`
- `surfaceVariant`: `#42483F`
- `outline`: `#A39B8D`

Typography:
- Keep `Fraunces` for `headlineLarge/headlineMedium` only.
- Use `Manrope` everywhere else.
- Increase body defaults slightly for elderly users:
  - `bodyLarge`: `17sp / 28sp`
  - `titleMedium`: `17sp / 24sp`
  - `labelLarge`: `15sp / 22sp`

Shape Language:
- Friendly but less pillowy than current.
- `small`: `10.dp`
- `medium`: `16.dp`
- `large`: `22.dp`
- `extraLarge`: `28.dp`
- Use `CircleShape` only for plant avatars and completed checkmarks.

Surface Treatment:
- Replace “transparent glass card” with `HearthCard`: mostly opaque surface, subtle tint, soft shadow.
- Card alpha should be `0.94f` light, `0.90f` dark.
- Keep the backdrop gradient, but lower glow intensity by roughly 40%.
- Current `GlassCard` can become a compatibility wrapper over `HearthCard`.

**Navigation & Layout Patterns**

Bottom Bar:
- `NavigationBar` height `88.dp`.
- Opaque cream/charcoal surface, no blur.
- Selected item uses rounded `16.dp` indicator in `primaryContainer`.
- Labels always visible: `Today`, `My Garden`, `Spaces`, `Assistant`.
- Icons `28.dp`; touch targets minimum `64.dp`.

Today:
- First screen is a “Today” care dashboard.
- Header: “Good morning” + “3 small jobs today.”
- Large primary task card:
  - `HearthTaskCard`
  - height minimum `132.dp`
  - left plant thumbnail `72.dp`
  - title: “Water Basil”
  - plain copy: “Soak the soil until water drips from the bottom.”
  - action chip: “Done”
- Secondary tasks as stacked cards, not dense list rows.
- Use “Later today” and “This week” sections.

My Garden:
- Use a list by default, not a grid.
- Elderly novice users need names and plain status visible without interpreting thumbnails.
- `PlantListItem` height `104.dp`.
- Thumbnail `64.dp`, name, species, next care line, status chip.
- Optional grid toggle later, but not primary.

Spaces:
- Large illustrated cards:
  - `Balcony`
  - `Backyard`
  - `Windowsill`
  - `Patio`
- 2-column on wide screens, 1-column on phones.
- Card height `128.dp`.
- Each card says “5 plants” and “Sunny most of the day.”

Species Picker:
- Search field pinned at top:
  - height `60.dp`
  - leading search icon
  - placeholder: “Search tomato, basil, mint…”
- Category chips:
  - `Easy`
  - `Herbs`
  - `Vegetables`
  - `Flowers`
  - `Shade`
  - `Sunny`
- Chips are `40.dp` high, `12.dp` radius, selected background `primaryContainer`.
- Species rows use common name first, small scientific name second only if useful.

**Signature Components**

Task Chip / Checkmark:
- `CareDoneChip`
- Minimum size `112.dp x 52.dp`.
- Before tap: outlined chip with leaf/check icon and “Done.”
- On tap: spring scale `1.0 -> 0.94 -> 1.0`, check circle fills green, label changes to “Done today.”
- Use `spring(dampingRatio = 0.72f, stiffness = 420f)`.

Hero / Plant Cards:
- `PlantHeroCard` on detail screen:
  - plant name
  - beginner status: “Looks ready for water”
  - next care date
  - large plant image/icon area
- Avoid technical terms like `growthStage`; show “Still getting established” or “Growing well.”

Empty States:
- Warm, direct, non-judgmental.
- “No plants yet” becomes “Add your first plant.”
- Supporting copy: “Start with one easy plant. We’ll remind you what to do.”
- Primary button: “Choose a plant.”

Motion:
- Gentle, practical motion.
- Screen transitions: `fadeIn + slideInHorizontally` around `220ms`.
- Card press: `animateFloatAsState` scale to `0.98f`.
- Completed tasks move to “Done today” with `AnimatedVisibility`.

**Beginner Accessibility Notes**

- Minimum tap target `56.dp`; primary controls `60-64.dp`.
- No icon-only actions except standard back/search.
- Keep labels always visible in bottom nav.
- Avoid low-alpha text over gradients.
- Use plain verbs: “Water,” “Feed,” “Move to shade,” “Done.”
- Keep cards opaque enough for contrast; glass is decorative, not structural.

**Implementation Cost:** **M**

Main risks:
- Requires introducing bottom navigation and new route structure.
- Current list/detail/wizard are simple, so card and theme migration is straightforward.
- Need to replace current `+` FAB flow with bottom-tab-aware add actions.
- Lowest visual risk because it evolves existing assets and typography.

---

## 2. Pocket Almanac

**Identity:** A cheerful field-guide notebook: sturdy paper surfaces, botanical labels, tabbed browsing, and clear “what to do next” guidance.

**Relationship To Verdant Glasshouse:** Replaces it visually while keeping the beginner-friendly softness. This is a bolder departure from glasshouse luxury toward practical illustrated reference.

**Color System**

Light:
- `primary`: `#315F3C`
- `onPrimary`: `#FFFFFF`
- `primaryContainer`: `#CFE6C8`
- `onPrimaryContainer`: `#102A17`
- `secondary`: `#B25F3A`
- `secondaryContainer`: `#F7D2C0`
- `tertiary`: `#516A9C`
- `tertiaryContainer`: `#D9E2FF`
- `background`: `#F4EBD8`
- `surface`: `#FFF8E8`
- `surfaceVariant`: `#E5D5B9`
- `outline`: `#8C7D63`

Dark:
- `primary`: `#A9D29F`
- `onPrimary`: `#0B3016`
- `primaryContainer`: `#214C2C`
- `secondary`: `#F0B094`
- `secondaryContainer`: `#71391F`
- `tertiary`: `#B8C7FA`
- `background`: `#19150F`
- `surface`: `#242016`
- `surfaceVariant`: `#4C4435`
- `outline`: `#B3A58C`

Typography:
- Replace Fraunces with a friendlier slab/display option if adding fonts is acceptable:
  - Display: `Roboto Slab` or `Bree Serif`
  - Body: keep `Manrope`
- If avoiding new font files, keep `Fraunces` but reduce usage to headings and lower display sizes.
- Suggested:
  - `headlineSmall`: `26sp / 34sp`
  - `titleLarge`: `22sp / 30sp`
  - `bodyLarge`: `17sp / 28sp`

Shape Language:
- Practical notebook cards.
- `extraSmall`: `6.dp`
- `small`: `8.dp`
- `medium`: `12.dp`
- `large`: `16.dp`
- No heavy rounded glass forms.
- Use small clipped “label tabs” on section headers.

Surface Treatment:
- Remove glass entirely.
- Replace backdrop with warm paper background plus very subtle vertical gradient.
- Add `PaperCard`:
  - opaque `surface`
  - `1.dp` border `outline.copy(alpha = .28f)`
  - shadow `2.dp`
- Optional faint paper texture is possible later, but start with flat Compose colors.

**Navigation & Layout Patterns**

Bottom Bar:
- Styled like notebook tabs.
- Height `92.dp`.
- Selected destination has a small top tab marker, `4.dp` high, color `secondary`.
- Use icons with labels always on.
- Bottom bar background `surface`, top border `outlineVariant`.

Today:
- Layout like a daily checklist page.
- Top band: “Today’s garden jobs”
- `ChecklistTaskCard`:
  - left square date badge: “Today”
  - large task title
  - plant/location line
  - plain instruction snippet
  - bottom row: `Done` and `Remind me later`
- Grouping:
  - “Needs care”
  - “Already done”
  - “Coming up”

My Garden:
- Use compact illustrated grid.
- 2 columns, card min height `168.dp`.
- Each `SpecimenCard`:
  - large plant icon/photo area
  - plant nickname
  - “Water tomorrow”
  - small space label, e.g. “Kitchen window”
- This direction can support browsing like a reference book, so grid feels right.

Spaces:
- Cards look like labeled dividers.
- Each `SpaceDividerCard` includes:
  - simple illustration area
  - “Balcony”
  - “Sunny, windy”
  - “3 plants”
- Tapping opens a space detail with plants filtered by location.

Species Picker:
- Treat as a catalog.
- Search field resembles a library index card:
  - `OutlinedTextField`
  - `56.dp` height
  - rectangular `12.dp` corners
- Category chips as label tabs:
  - selected chip has bottom accent stripe.
- Species cards:
  - common name
  - “Good first plant” badge
  - `Sun`, `Water`, `Pot size` beginner icons
  - no dense scientific metadata in primary view.

**Signature Components**

Task Chip / Checkmark:
- `ChecklistStampButton`
- Before completion: square checkbox `32.dp` plus “Mark done.”
- After completion: stamped pill with `secondaryContainer`, text “Done.”
- Interaction: check draws in `180ms`, card background warms from `surface` to `primaryContainer.copy(alpha=.45f)`.

Hero / Plant Cards:
- `AlmanacPlantCard`
- Looks like a field-guide entry:
  - common name as heading
  - “Beginner level: Easy”
  - three fact chips: “Sun,” “Water,” “Pot”
  - status note: “Next: water Thursday”
- Detail page can use a large “care recipe” section:
  - “How to water”
  - “Where it should sit”
  - “What to watch for”

Empty States:
- Notebook-style prompt:
  - “Your garden notebook is empty.”
  - “Pick one easy plant to begin.”
- Primary CTA: “Browse easy plants.”
- Secondary CTA: “Add one I already own.”

Motion:
- Page-like transitions.
- `fadeIn` + slight vertical `slideInVertically(initialOffsetY = 24.dp)` at `240ms`.
- Chips use quick color tween `160ms`.
- Avoid elaborate glass/parallax motion.

**Beginner Accessibility Notes**

- Very readable because surfaces are opaque and contrast is stable.
- Use “Good first plant” instead of “beginner-friendly cultivar.”
- Keep cards visually rich but not translucent.
- `Remind me later` should be a full-width secondary button or large text button, not a tiny overflow item.
- Use consistent checklist behavior everywhere.

**Implementation Cost:** **L**

Main risks:
- New visual system means replacing `GlassCard` semantics across screens.
- New grid/catalog patterns need more UI work than the current simple wizard list.
- If adding a new display font, design-system resources and typography tests need updating.
- The notebook metaphor must be applied carefully so it does not become visually busy.

---

## 3. Sunroom Console

**Identity:** A modern, high-clarity gardening control panel: bright daylight surfaces, large status modules, and confident bottom-tab workflows.

**Relationship To Verdant Glasshouse:** Replaces the ornamental glasshouse with a cleaner “home dashboard” app. Still botanical, but less romantic and more operational.

**Color System**

Light:
- `primary`: `#006C58`
- `onPrimary`: `#FFFFFF`
- `primaryContainer`: `#AEEBDD`
- `onPrimaryContainer`: `#00251D`
- `secondary`: `#6E5E00`
- `secondaryContainer`: `#F6E57A`
- `tertiary`: `#7A4F00`
- `tertiaryContainer`: `#FFDDA6`
- `background`: `#F7FAF5`
- `surface`: `#FFFFFF`
- `surfaceVariant`: `#DDE8E1`
- `outline`: `#6F7973`
- `error`: `#BA1A1A`

Dark:
- `primary`: `#7FD8C5`
- `onPrimary`: `#00382D`
- `primaryContainer`: `#005143`
- `secondary`: `#D9C95F`
- `secondaryContainer`: `#534600`
- `tertiary`: `#F2C06D`
- `tertiaryContainer`: `#5D3B00`
- `background`: `#0E1512`
- `surface`: `#151D19`
- `surfaceVariant`: `#3F4944`
- `outline`: `#89938D`

Typography:
- Replace Fraunces usage with all-sans for clarity.
- Keep `Manrope` as the whole app family.
- Use heavier weights for scanability:
  - `headlineLarge`: Manrope `700`, `32sp / 40sp`
  - `headlineSmall`: Manrope `700`, `24sp / 32sp`
  - `titleLarge`: Manrope `700`, `21sp / 28sp`
  - `bodyLarge`: Manrope `500`, `17sp / 27sp`
- This is the most modern-app direction.

Shape Language:
- Controlled, modular, less soft.
- `extraSmall`: `6.dp`
- `small`: `8.dp`
- `medium`: `12.dp`
- `large`: `16.dp`
- `extraLarge`: `20.dp`
- Use consistent `8.dp` internal grid.

Surface Treatment:
- Remove radial glow and glass.
- Use clean daylight background with a faint top-to-bottom gradient:
  - light: `#F7FAF5 -> #EEF5F0`
  - dark: `#0E1512 -> #111B17`
- Cards are solid white/dark surfaces with `1.dp` border and restrained shadow.
- Introduce `StatusPanel`, `TaskPanel`, `PlantPanel`.

**Navigation & Layout Patterns**

Bottom Bar:
- Modern Material 3 bottom navigation, more compact than Garden Hearth.
- Height `80.dp`.
- Selected item uses filled tonal indicator `56.dp x 36.dp`, radius `18.dp`.
- Icons `26.dp`, labels `12sp`.
- Add plant action should not be a global FAB on every tab; use contextual “Add plant” button in My Garden and empty states.

Today:
- Dashboard layout.
- Top `TodaySummaryPanel`:
  - “2 due now”
  - “1 later”
  - “All plants okay”
- Task cards use priority color strip:
  - Water: `primary`
  - Feed: `secondary`
  - Move/protect: `tertiary`
- Each `TaskPanel` has:
  - task title
  - plant name
  - exact simple instruction
  - large trailing check button `56.dp`
- Include a “No jargon” task explainer line:
  - “Why: the top inch of soil dries quickly in small pots.”

My Garden:
- Hybrid list with status modules.
- Default: vertical list sorted by “needs care soon.”
- Each item:
  - name
  - space
  - next task
  - health/status badge
- Add segmented control:
  - `List`
  - `Photos`
- Photos mode can be a 2-column grid later.

Spaces:
- `SpaceStatusCard`
- More dashboard-like:
  - “Balcony”
  - “6 plants”
  - “Hot afternoon sun”
  - task count badge: “2 need water”
- Use horizontal icon/stat row for sun/wind/shade.

Species Picker:
- Strong utility treatment.
- Search field top pinned, filled surface:
  - height `58.dp`
  - radius `16.dp`
  - search icon + clear button
- Category chips become `FilterChip`s with large labels:
  - “Easy”
  - “Food”
  - “Flowers”
  - “Herbs”
  - “Sunny”
  - “Low light”
- Results in dense but readable rows:
  - thumbnail `56.dp`
  - common name
  - “Easy in pots”
  - right-side “Choose” button.

**Signature Components**

Task Chip / Checkmark:
- `TaskCompleteButton`
- Circular `56.dp` button on each task card.
- Before tap: outline circle with check icon.
- On tap:
  - circle fills `primary`
  - white check appears
  - task card collapses into “Done today” row after `350ms`
- Use `tween(180, easing = FastOutSlowInEasing)` for fill, then `AnimatedContent`.

Hero / Plant Cards:
- `PlantStatusHeader`
- Uses simple status tiles:
  - “Next water”
  - “Light”
  - “Pot”
- Plant detail becomes more task-oriented:
  - “What to do next”
  - “About this plant”
  - “Care history”

Empty States:
- Clean and direct.
- “No plants yet.”
- “Choose one easy plant and we’ll make a simple care plan.”
- Primary button: “Choose first plant.”
- Use a single friendly plant illustration/icon, not decorative glass.

Motion:
- Snappy dashboard motion.
- Bottom-tab transitions: `fadeIn` only, `150ms`.
- Card state changes: `AnimatedContent` + `animateColorAsState`.
- Avoid large page slides; elderly users can lose spatial context with too much motion.

**Beginner Accessibility Notes**

- Best for contrast and task clarity.
- Labels are literal and action-oriented.
- Keep `TaskCompleteButton` accompanied by text, not only an icon.
- Use high contrast status strips; never rely on color alone.
- Default body text at least `17sp`.
- Use stable layouts so cards do not jump when task counts change.

**Implementation Cost:** **M/L**

Main risks:
- Requires rethinking the app structure around Today-first navigation.
- All-sans typography is simple technically, but it changes the brand sharply.
- Dashboard components need new state models for task summaries, space summaries, and filters.
- Visual system is easier to implement than glass, but the information architecture work is larger.

---

## Recommendation

I would pick **Garden Hearth**. It gives PlantApp a meaningful redesign without throwing away the strongest parts of the current codebase: the centralized Material 3 theme, `PlantAppBackground`, `GlassCard`, Fraunces/Manrope, and the existing beginner wizard patterns. It also best fits the target user: warm, modern, thematic, but still readable and forgiving. I’d treat **Pocket Almanac** as the boldest brand option if the owner wants a memorable editorial identity, and **Sunroom Console** as the best choice only if the product is moving toward a more utility-heavy daily task app.