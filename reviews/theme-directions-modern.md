# PlantApp MODERN theme directions (Codex CLI, 2026-06-02)

Owner pivot: "less about accessibility, more about a modern, thematic app." Generated via `codex exec` (read-only). Codex recommends **Verdant Glasshouse**. Owner picks; then `:design-system` (currently bare default M3) is built into the chosen theme (Color/Type/Shape/Theme + Google Fonts via the `google-fonts` Compose dep) and applied across screens. (Supersedes the earlier accessibility-framed directions in `theme-directions-codex.md`.)

---

## 1. Verdant Glasshouse

**Mood:** Lush indoor conservatory: glossy leaves, humid glass, warm sunlight, premium wellness.

| Role | Light | Dark |
|---|---:|---:|
| primary | `#1F6F4A` | `#7ED9A4` |
| onPrimary | `#FFFFFF` | `#062013` |
| primaryContainer | `#C9F2D8` | `#16472F` |
| secondary | `#8A6F3D` | `#DCC58A` |
| tertiary | `#2F7E8C` | `#8CDCE6` |
| background | `#F6F3E9` | `#07130D` |
| surface | `#FFFBF2` | `#0F1D16` |
| onSurface | `#1E241F` | `#E7F0E9` |

**Type:** `Fraunces` display + `Manrope` body.  
**Shape / Surface:** 24dp hero cards, 18dp content cards, 12dp controls; soft tonal elevation with olive-tinted shadows; translucent “greenhouse glass” surfaces using blurred leaf photography, vertical sunlight gradients, and subtle condensation/noise overlays.  
**Signature touches:**
- Full-width plant hero cards with macro leaf imagery, overlaid watering status chips, and a soft glass bottom sheet.
- Dew-drop progress indicators for “water in 2 days,” “new leaf,” and “repot soon.”
- Motion: cards breathe subtly on load; leaf silhouettes parallax behind task lists; watering action ripples outward in pale mint.

## 2. Midnight Botanical

**Mood:** Editorial, moody garden journal: dark florals, lacquered greens, candlelit amber, boutique-app polish.

| Role | Light | Dark |
|---|---:|---:|
| primary | `#496B2F` | `#B7E27A` |
| onPrimary | `#FFFFFF` | `#102006` |
| primaryContainer | `#DDEFC0` | `#2E451E` |
| secondary | `#A25C45` | `#F0B59F` |
| tertiary | `#6B5BA7` | `#C9BFFF` |
| background | `#FAF6EF` | `#0C0F0B` |
| surface | `#FFFDF8` | `#151A12` |
| onSurface | `#23251F` | `#ECEFE5` |

**Type:** `Cormorant Garamond` display + `Plus Jakarta Sans` body.  
**Shape / Surface:** 20dp asymmetric-feeling organic cards, 28dp image containers, 10dp compact controls; dark mode uses deep green-black surfaces, warm edge highlights, and low-gloss botanical texture rather than flat charcoal.  
**Signature touches:**
- Hero illustrations use dramatic botanical still-life compositions: dark backgrounds, high-detail leaves, terracotta pots, gold plant markers.
- “Today’s care” appears as a premium editorial stack with overlapping image cards and amber action buttons.
- Micro-interactions: checkmarks bloom into tiny line-art sprigs; plant health rings animate like opening petals.

## 3. Wildflower Pop

**Mood:** Fresh balcony garden: playful, colorful, optimistic, modern consumer-social energy without becoming childish.

| Role | Light | Dark |
|---|---:|---:|
| primary | `#2E7D5B` | `#82E0B2` |
| onPrimary | `#FFFFFF` | `#062116` |
| primaryContainer | `#BFEFD7` | `#174B36` |
| secondary | `#E0694F` | `#FFB6A3` |
| tertiary | `#6E73D9` | `#C3C6FF` |
| background | `#FFF8ED` | `#101217` |
| surface | `#FFFFFF` | `#1A1D24` |
| onSurface | `#24251F` | `#F0F1EA` |

**Type:** `Bricolage Grotesque` display + `DM Sans` body.  
**Shape / Surface:** 26dp rounded feature cards, 16dp task rows, circular plant avatars; brighter Material 3 tonal surfaces, sticker-like layered illustrations, soft colored shadows, playful gradients kept to small accents.  
**Signature touches:**
- Plant cards use cutout-style pot photos or illustrations on colored backplates with floating care badges.
- Seasonal UI accents: wildflower confetti on completed care streaks, animated seedling growth for onboarding.
- Swipe gestures feel tactile: drag a care card and the background shifts from coral to mint depending on action.

## Recommendation

Choose **Verdant Glasshouse**. It gives the app the strongest premium botanical identity, works especially well in dark mode, and maps cleanly to Compose with Material 3 tonal surfaces, photo-backed hero cards, blur, rounded shapes, and calm motion.

Sources checked for current font/icon availability: [Google Material Symbols](https://developers.google.com/fonts/docs/material_symbols), [Google Fonts references via current font listings](https://fonts.google.com/).