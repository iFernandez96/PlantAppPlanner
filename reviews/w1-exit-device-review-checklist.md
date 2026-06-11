# W1-EXIT full device review — checklist (run after 0058 lands + per-slice check)

Stage-exit gate for Wave 2 W1 (wave2 plan: "full device walk (light+dark) screenshotted;
owner sign-off"). Device: Samsung SM-S928U1, serial
`adb-R5CX11MDTZK-qTD4xe._adb-tls-connect._tcp`, package `dev.plantapp.android`.
Backend: Fastify `10.0.0.179:3000` + Supabase `:54321` (env `/tmp/plantapp-fastify-env.sh`),
Mailpit `http://127.0.0.1:54324/api/v1/messages`. Account: reviewer@example.com.

Build: latest LAN APK (`-Pplantapp.apiBaseUrl=http://10.0.0.179:3000/
-Pplantapp.authBaseUrl=http://10.0.0.179:54321/`, `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`),
`adb install -r`.

## Walk (each screen in BOTH light and dark — `adb shell cmd uimode night no|yes`)

1. **Fresh sign-in** (`pm clear` first): Hearth welcome + helper copy, email keyboard,
   send disabled until email typed, "Sending…" busy state, code arrives (Mailpit),
   number keyboard on code field, friendly error on a deliberately wrong code, then
   successful sign-in.
2. **My Garden list**: Hearth rows (64dp species icons, friendly names, no slugs),
   quiet refresh on revisit, empty-state legible in dark (0046 fix holds).
3. **Plant detail**: friendly species name, plain-language care line, advisories
   severity-styled without "HIGH ·" prefix, accept-advisory → task appears.
4. **Add-plant wizard end-to-end**: species → space (create one — verify DB-valid kind) →
   pot → confirm (natural copy echoes pot choice) → save → plant visible in list
   WITHOUT force-stop. Error card shows if backend killed (optional re-check).
5. **Bottom nav**: Today/My Garden/Spaces tabs switch + preserve state; bar hidden on
   sign-in/wizard/detail; placeholders legible both modes.
6. **Token resilience (spot)**: app resumed after >1h idle (or skip — proven in 0057).
7. **No crashes** anywhere in the walk; logcat scan for FATAL.

## Evidence
- Screenshots → `reviews/device-evidence/w1exit-NN-<screen>-<light|dark>.png`.
- Verdict table appended to this file; key shots SendUserFile'd to owner with the
  Gates B + C questions (owner sign-off = W1 closed, W2 opens).

## Known-and-accepted (do NOT flag as new)
- Wizard/detail raw `e.message` errors (PD-13, early-W2 slice).
- Orphan spaces in pickers (PD-12, W4 management).
- Pre-0056 sessions land on sign-in once after upgrade (0057 migration note).
- Today/Spaces tabs are placeholders until W3/W4.
