# Implementation report — 0048-hearth-card-opacity

## Status: DONE

## What was done
Single-file retune of `android/design-system/src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt`
per §3:
1. Non-clickable overload container alpha: `0.64f/0.74f` → `0.90f else 0.94f`.
2. Clickable overload container alpha: `0.68f/0.78f` → `0.90f else 0.94f`.
3. KDoc added above the first overload:
   `/** Garden Hearth surface: mostly opaque warm card (decorative translucency only). */`

Unchanged: name `GlassCard`, both signatures/parameters, tint lerp fractions
(0.08/0.10 and 0.10/0.12), borders, elevations, disabled alphas (0.42f/0.38f), call sites.

## Baseline precondition
- HEAD before work: `05fba1c048591defa2744fca0080f3958cb1610a` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `7b5ba83327b5d85c1b58d9f5b10393ca4bae5b80`
- Title (exact): `feat(design): retune GlassCard to mostly-opaque Hearth surfaces (Wave 2 W1)`
- Pushed: `05fba1c..7b5ba83  master -> master` (fast-forward)
- New `origin/master`: `7b5ba83327b5d85c1b58d9f5b10393ca4bae5b80`

### git show --stat HEAD
```
 .../src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt           | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
```
Exactly GlassCard.kt. ✓

## Scope confirmation
- Only GlassCard.kt changed; no rename, no signature change, no call sites touched.
- `android/.kotlin/` left untracked (post-commit `git status --porcelain` shows only it).
- No installs, no dependencies, no forbidden paths.
