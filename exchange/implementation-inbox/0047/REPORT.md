# Implementation report — 0047-garden-hearth-tokens

## Status: DONE

## What was done
Token-value-only retune of `:design-system` to Garden Hearth (Wave 2 / W1 slice 1), exactly
per §3 of the prompt:

- **Color.kt** — all 16 `Verdant*` top-level palette values updated (the two `On*` values that
  were already correct — `VerdantOnPrimary`, `VerdantOnSurface`/`Dark` — unchanged per spec);
  4 inline literals changed in `VerdantLightColorScheme` (onPrimaryContainer, secondaryContainer,
  surfaceVariant, outline) and 6 in `VerdantDarkColorScheme` (onPrimaryContainer,
  secondaryContainer, onSecondaryContainer, surfaceVariant, outline, outlineVariant). All other
  fields (tertiaryContainer, error*, inverse*, scrim, …) untouched.
- **Type.kt** — `titleMedium` 16→17.sp (lineHeight stays 24), `bodyLarge` 16→17.sp / 26→28.sp,
  `labelLarge` 14→15.sp / 20→22.sp. Families/weights/other styles untouched.
- **Shape.kt** — small 12→10.dp, medium 18→16.dp, large 24→22.dp (extraSmall 8 / extraLarge 28
  unchanged); doc comment updated to `/** Garden Hearth: friendly, slightly tighter rounding. */`.
- **Background.kt** — glow line 37 replaced verbatim with the −40% alphas
  (`0.11f/0.12f` + `0.05f/0.06f`).

No renames — `VerdantLightColorScheme`/`VerdantDarkColorScheme` and every public `val` keep
their names. No component/screen/navigation/API changes; `Theme.kt`, `GlassCard.kt`, fonts
untouched. No new deps, no installs.

## Baseline precondition
- HEAD before work: `a5968a40b466d99a9e5597ce02e5cfa5e24b14ae` ✓
- Tree clean except untracked `android/.kotlin/` (expected; left untracked) ✓

## Commit + push
- New commit: `05fba1c048591defa2744fca0080f3958cb1610a`
- Title (exact): `feat(design): retune design-system tokens to Garden Hearth (Wave 2 W1)`
- Pushed: `a5968a4..05fba1c  master -> master` (fast-forward)
- New `origin/master`: `05fba1c048591defa2744fca0080f3958cb1610a`

### git show --stat HEAD
```
 .../kotlin/dev/plantapp/designsystem/Background.kt |  2 +-
 .../main/kotlin/dev/plantapp/designsystem/Color.kt | 42 +++++++++++-----------
 .../main/kotlin/dev/plantapp/designsystem/Shape.kt |  8 ++---
 .../main/kotlin/dev/plantapp/designsystem/Type.kt  |  6 ++--
 4 files changed, 29 insertions(+), 29 deletions(-)
```
Exactly the 4 design-system files. ✓

## Scope confirmation
- No files outside the 4 listed; no renames; `android/.kotlin/` left untracked
  (`git status --porcelain` after commit shows only `?? android/.kotlin/`).
- Forbidden paths untouched (Theme.kt, GlassCard.kt, fonts, other modules, backend, schemas,
  supabase, docs, tests, gradle/manifest).

## Note for the planner
Device APK not rebuilt (not requested). For the device re-screenshot, rebuild with the LAN
`-P` overrides (`-Pplantapp.apiBaseUrl=http://10.0.0.179:3000/`
`-Pplantapp.authBaseUrl=http://10.0.0.179:54321/`).
