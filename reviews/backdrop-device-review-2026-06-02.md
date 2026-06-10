# Backdrop/glass (0045, `ae60aea`) on-device review — 2026-06-02

Device: Samsung SM-S928U1 (Android 16), `10.0.0.166:41027`. LAN debug APK rebuilt + reinstalled
(api `http://10.0.0.179:3000/`, auth `…:54321/`). Review agent walked sign-in → list → 3-step
wizard → confirm in light, then list + wizard in dark; cut off by a session limit before the
dark confirm/detail shots and its final write-up — verdicts below are from planner inspection of
the 13 captured screenshots (`reviews/device-evidence/backdrop-*.png`).

## Verdicts
| Item | Verdict |
|---|---|
| Immersive backdrop (gradient + radial glow) on every screen, both modes | ✅ PASS — visible behind list, wizard, sign-in; light = warm sage/cream wash, dark = deep green w/ glow |
| Glass surfaces (translucent cards/tiles over backdrop) | ✅ PASS — wizard tiles + sign-in fields read as glass in both modes |
| Wizard tiles fixed (big icon + plain name, no broken art) | ✅ PASS — species step shows real per-species icons (strawberry/basil/passion fruit/tomatillo/tomato); pot step shows the 6 "how pots are sold" options |
| Serif (Fraunces) app-bar titles | ✅ PASS — "My plants", "What are you growing?", "What's it planted in?", "All set?" all serif |
| Crashes / network errors | none observed in captures; full e2e add was not completed (agent cut off) |

## Issues found
1. **Dark-mode empty-state contrast (real issue):** "No plants yet. Tap + to add your first
   plant." renders dark-on-dark in dark mode (`backdrop-10-list-dark.png`) — near-invisible.
   Light mode is fine. Likely the empty-state text uses a fixed dark color instead of
   `onBackground`/theme color. → queue a small impl fix.
2. **Confirm-screen "Add" button looks washed out** in light mode (`backdrop-08/09`): pale grey
   pill, low affordance for the single most important action. May be the disabled state captured
   pre-selection — verify; if it's the enabled state, bump to a filled primary (deep green) button.
3. Coverage gaps (agent cut off): no dark confirm/detail captures; no post-add plant detail with
   live data. Re-verify in the next device pass.

## Disposition
Backdrop/glass 0045 is **visually confirmed on-device** ✅ with one real dark-mode contrast bug +
one button-prominence check → fold both into the next UI polish handoff (alongside the existing
copy-sweep backlog: scientific-slug leak, engine rationale, ISO timestamps on detail).
