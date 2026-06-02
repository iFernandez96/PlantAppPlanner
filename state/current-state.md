# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 — **Beginner wizard built (`0042`) + device-walkthrough done (first-run PASSed end-to-end). Owner: replace self-drawn icons with sourced ones → `0043` IN FLIGHT (CC0 crop SVGs + Material Symbols). Then a copy sweep (detail screen leaks dev data). Backend still UP for re-review. FCM deferred.** |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `369f2f06dcc6bc8019cf051b40228e01a0746b89` (`369f2f0`) — in sync, clean |

## 🎉 Slice 1 complete (engineering) — #1–#24 green
- **Backend:** schema tests (#1–#6) · deterministic care-engine (#7–#14) · seed catalog ·
  Supabase schema + RLS · Fastify add-plant→CareTask API + auth(RLS) · #15–#18 · RLS
  isolation #19 · delete cascade #20 · all responses camelCase-conformant (Ajv-locked).
- **Android:** `:network` Retrofit DTOs (schema-validated) · `:domain`/`:data` repository ·
  `:feature-inventory` Compose add/list/detail + nav + UI tests #21–#24 (Robolectric).
- **Tests:** backend unit 50/50, integration 21/21, lint+typecheck clean; Android
  `:network` 10/10, `:domain` 2/2, `:data` 5/5, `:feature-inventory` 4/4; `:app:assembleDebug` OK.
- **Retro:** `reviews/slice-1-retro.md`. Exchange handoffs `0001`–`0013` all ✓.

## Slice 2 (advisories) — COMPLETE end-to-end; loop PAUSED for owner
Deterministic, profile-driven advisories surfaced in the UI, **never auto-creating
CareTasks** — all 5 `@slice-2` scenarios exercised. Retro: `reviews/slice-2-retro.md`.
- S2.0–S2.3 done (`06f581d`→`4f3d76a`→`8d3e813`→`c4e4396`): advisory schema · deterministic
  `computeAdvisories` engine · `GET /plants/:id/advisories` (RLS, no task) · Android detail
  display. Backend unit **67/67** + integration **25/25**; Android module + UI tests green;
  `:app:assembleDebug` OK.
- **Owner chose "do all" (2026-06-02) — loop RUNNING through the backlog.** Order:
  - **(1) `validate-schemas` fix — ✅ DONE (`0018`, `392ba86`):** `-c ajv-formats` + one
    `type:"array"`; all 8 schemas compile, `npm test` 67/67. Verified against real git.
  - **(3) UX follow-ups:**
    - **3a backend list endpoints — ✅ DONE (`0019`, `c7b8c54`):** read-only `GET /plant-profiles`
      (catalog) + `GET /garden-spaces`/`/containers` (RLS) + `toPlantProfile` mapper; integration
      31/31, unit 67/67. Verified vs real git (3 files, protected paths untouched, read-only, RLS).
    - **3b Android selectors — decomposed network→data→ui:**
      **3b-network ✅ DONE (`0021`, `ce59e5e`)** — `:network` `PlantProfileDto` + `getPlantProfiles/
      getGardenSpaces/getContainers` + schema test; `:network` 5/5. (`0020` was blocked on the
      unmounted-Drive SDK; owner re-mounted; `0021` re-ran it green. Verified vs real git: only
      `android/network/**`.) **3b-data ✅ DONE (`0022`, `3fba718`)** — `:domain` `PlantProfile` +
      3 repo read methods, `:data` mapper/impl + `FakePlantAppApi` fix + tests; `:data` 7/7,
      `:domain` 2/2 (fixed `0021`'s latent `:data` compile-red). Verified vs real git (only
      `android/domain|data/**`). **3b-ui split a/b: 3b-ui-a IN FLIGHT (`0023`)** — replace add-plant
      **Profile id field** with a Material3 catalog **dropdown** (`getPlantProfiles()`) — ✅ DONE
      (`0023`, `20f4e35`): VM load + 1-line `:app` route wiring + Robolectric tests (InventoryScreensTest
      5/5, `:app:assembleDebug` OK); verified vs real git (`FIELD_PROFILE_ID` removed; only
      `feature-inventory|app/**`). **3b-ui-b IN FLIGHT (`0024`)** — Garden-space **select-or-create**
      (dropdown from `getGardenSpaces()` + inline create via `createGardenSpace(name,kind)`; create
      form is name+kind only — no location) — ✅ DONE (`0024`, `5ce6f29`): InventoryScreensTest 7/7,
      assemble OK; verified vs real git (`FIELD_GARDEN_SPACE_ID` removed). **3b-ui-c IN FLIGHT
      (`0025`)** — container **select-or-create** (dropdown from `getContainers()` + inline create
      via `createContainer(name,volumeLiters,material,drainage)`; validation moves onto selection)
      — ✅ DONE (`0025`, `8d51874`): InventoryScreensTest 9/9, assemble OK; verified vs real git
      (all 3 raw-id fields removed). **3b COMPLETE — add-plant fully selector-driven, no raw-id fields.**
    - **3c sign-in — owner chose EMAIL OTP CODE (2026-06-02):** email → GoTrue `/auth/v1/otp`
      (6-digit code) → enter code → `/auth/v1/verify` → token → existing `SettingsStore.setToken`
      plumbing. Dependency-free (Retrofit/OkHttp/kotlinx), no deep-link/manifest. Decomposed
      net→data→ui: **3c-net ✅ DONE (`0026`, `a2f5e75`)** — `:network` `SupabaseAuthApi` (otp+verify)
      + DTOs (`@SerialName`) + factory (public apikey header, BASIC logging; auth `Json`
      encodeDefaults=true so `create_user`/`type` are sent); `AuthDtoTest` 3/3, `:network` green.
      Verified vs real git (only `android/network/**`, no key/URL hard-coded). **3c-data ✅ DONE
      (`0027`, `28f69ea`)** — `:domain` `AuthRepository` + `:data` impl (verify → `SettingsStore.setToken`
      via `TokenWriter` seam) + DI/config (auth URL + **public** local anon key, overridable); `:data`
      10/10. Verified vs real git (committed key decodes role=anon, not service_role). **3c-ui IN
      FLIGHT (`0028`)** — stateless `SignInScreen` (email→send code→verify) + `SignInViewModel` over
      `AuthRepository` + `:app` gating (`tokenBlocking()`→start destination) + Robolectric tests —
      ✅ DONE (`0028`, `e76ff8d`): `:feature-inventory` 11→14, assemble OK; verified vs real git
      (gating + SignInScreen present, no secret). **3c (sign-in) COMPLETE.**
    - **3d advisory → accept → CareTask** — decomposed engine→api→android. **3d-engine ✅ DONE
      (`0029`, `e4ffe4b`)** — pure `computeTaskFromAdvisory` (container-size→repot, support→support,
      pollination throws; priority from severity; dueAt=clockUtc; deterministic inputsHash;
      schema-valid); `npm test` 67→72; verified pure (no Date.now/random) & not endpoint-wired.
      Mapping recorded in `reviews/vision-checks.md` 0029 (the decision 3d-api/Android inherit).
      **3d-api ✅ DONE (`0030`, `53d093e`)** — `POST /plants/:id/advisories/accept {kind}`:
      recompute advisories (RLS 404), match applicable (400 if absent/unsupported), engine →
      persist one care_tasks row → return CareTask; `test:int` 31→35 incl. GET-creates-nothing
      assertion; verified vs real git (GET handler has no insert). **3d-android net+data ✅ DONE
      (`0031`, `bfdd946`)** — `:network` `acceptAdvisory` + `AcceptAdvisoryRequest` + `:domain`/`:data`
      repo method + fake + tests (`:network` 16→17, `:data` 10→11); verified vs real git.
      **3d-android-ui ✅ DONE (`0032`, `d1bda81`)** — per-advisory **Accept** button on
      `PlantDetailScreen` (container-size/support only) → `PlantDetailViewModel.accept` →
      `acceptAdvisory` → reload + `:app` wiring; `:feature-inventory` 14→16, assemble OK; verified
      vs real git. **🎉 Backlog (3) UX follow-ups COMPLETE** (selector-driven add-plant · email-OTP
      sign-in + gating · advisory→accept→CareTask e2e).
    - **(2) e2e smoke — owner chose ROBOLECTRIC NavHost smoke (2026-06-02).** IN FLIGHT (`0033`):
      a `:feature-inventory` Robolectric test driving a real `NavController`/`NavHost` over the
      actual screens + ViewModels built from **fake** `InventoryRepository`/`AuthRepository`
      (no Hilt-test infra) — gated journey sign-in→list→detail→accept (+ add via selectors).
      Deterministic, JVM, no emulator/backend. Human "real plants on my device" acceptance stays
      with the owner. (Adds `navigation-compose` as a `:feature-inventory` testImpl.)
    - **(2) e2e ✅ DONE (`0033`, `da020e3`)** — test-only Robolectric NavHost smoke (`:feature-inventory`
      18 tests); verified test-only (no `src/main`). **Backlog (1)+(2)+(3) COMPLETE.**
    - **(4) Slice 3 — watering reminders.** opener `0034`✅ (plan doc + `computeReminders`); WM-local
      `0035`✅ (`6f6f58b`: `ReminderScheduler`+`ReminderWorker`+WorkManager dep+`POST_NOTIFICATIONS`+
      channel; `:data` 11→14; verified — local-only, no FCM). app-open scheduling
      `0036`✅ (`e8aaeec`: `ReminderSync` + `ReminderScheduling` seam + `Clock` + `PlantListViewModel`
      fire-and-forget trigger; `:data` 14→15). runtime `POST_NOTIFICATIONS` `0037`✅
      (`369f2f0`): Compose `RequestPermission` launcher + pure `shouldRequest` helper; `:feature-inventory`
      18→22; verified (no FCM). **✅ LOCAL Slice 3 reminder path COMPLETE** (computeReminders →
      WorkManager scheduling → app-open sync → runtime permission). **⏸ PAUSED at the FCM STOP gate:**
      server-triggered push needs an owner-provided **Firebase project + `google-services.json`** +
      go-ahead, plus a backend FCM sender + per-user token registration (a meaningful chunk). Owner
      can also manually verify on a 33+ device (grant permission → confirm a reminder fires). Slice 3
      relaxed the Slices-1/2 "no notifications" posture (D-11/D-12; ratified D-13) — owner-approved.
      (Gate note: `:domain` is a JVM module → `:domain:test`, not `:domain:testDebugUnitTest`.)
  - **(2) Automated emulator e2e smoke** (instrumented). **Human device-acceptance (real plants on
    a real phone) stays with the owner — I can't do that part.**
  - **(4) Slice 3** (watering reminders): WorkManager local path first, then **STOP to ask the owner
    for Firebase/FCM setup** (Firebase project + `google-services.json`).
  - Vision-check each product-surface step. No watcher gap — armed for `0018`.
- **Tracked (pre-existing, NOT blocking):** `npm run validate-schemas` red for all 8 schemas
  (ajv-cli lacks `ajv-formats`; `diagnosis-result` strictTypes). Real gate is `npm test` (green).
  Tiny hygiene handoff candidate (`-c ajv-formats` + one `type:"array"`).
- **Still recommended (Slice 1, not blocking):** on-device acceptance run of the 5 real
  plants (needs the API reachable). See `reviews/slice-1-retro.md`.

## On-device smoke (2026-06-02) — real Samsung SM-S928U1, Android 16 / SDK 36 (wireless adb `10.0.0.166`)
Ran the queued 13-test suite (`reviews/device-test-suite.md`) via a QA agent → report
`reviews/device-test-report-2026-06-02.md` + screenshots `reviews/device-evidence/`.
- **PASS:** T0 connect · T1 install · T2 cold launch (643ms, no crash) + correct unauth gating
  (fresh→Sign in) · T3 sign-in UI · T12 warm restart. **WorkManager verified working** (DiagnosticsWorker
  → SUCCESS); `POST_NOTIFICATIONS granted=true`. **No crashes/regressions.**
- **BLOCKED (full-stack):** T4–T11 behind the first network call. "Send code" → `POST
  http://10.0.2.2:54321/auth/v1/otp` fails with **`UnknownServiceException: CLEARTEXT communication
  to 10.0.2.2 not permitted by network security policy`** (shown in-app too).
- **Unblock path — owner chose "wire it & re-test" (2026-06-02); IN PROGRESS:**
  1. **Backend server bootstrap ✅ DONE (`0038`, `e95c40e`):** `src/server.ts` (`listen 0.0.0.0:PORT`)
     + `start` script; boots → `GET /plants` 401, unit 72/72. Verified vs real git.
  2. **Android device-debug build ✅ DONE (`0039`, `a3cb50e`):** base URLs → `BuildConfig` fields
     (`-P`-overridable; emulator defaults, **API corrected to Fastify `:3000`** vs the old `:54321`,
     auth stays Supabase `:54321`); device build passes `-Pplantapp.apiBaseUrl=http://10.0.0.179:3000/
     -Pplantapp.authBaseUrl=http://10.0.0.179:54321/`. + **debug-only `network-security-config`**
     permitting cleartext (the device blocker was cleartext-NSC, not connectivity). Impl's verification
     build = the device-ready APK.
  3. **Run LAN stack + re-test — IN PROGRESS (owner-approved this session):**
     - Supabase UP + LAN-reachable (`10.0.0.179:54321`→200); **`db reset` applied (5 profiles
       seeded; the `[]` via anon was an RLS artifact — confirmed 5 via service_role)**.
     - Fastify UP (background task `bhdrygzdg`): `node dist/src/server.js` `HOST=0.0.0.0 PORT=3000`,
       `SUPABASE_URL=127.0.0.1:54321`; `10.0.0.179:3000/plants`→401 from host.
     - LAN-baked device APK (`a3cb50e`, mtime 09:54) **installed** on the phone (`adb install -r` Success).
     - **BLOCKED on owner `ufw`** (host default-deny inbound blocks the phone): owner runs
       `sudo ufw allow from 10.0.0.0/24 to any port 54321 proto tcp` + `… port 3000 proto tcp`.
     - Then re-run the device agent suite. **OTP note:** local Supabase emails the code to **Mailpit**
       (`127.0.0.1:54324`); the agent reads the code from Mailpit's API to complete sign-in.
     - **Teardown after:** re-close ufw ports; stop Fastify (`bhdrygzdg`).
     - **ufw opened by owner ✅; Kong restarted to clear a post-`db reset` stale-upstream 502.**
       Phone→Supabase `/auth/v1/health` 200, phone→Fastify `/plants` 401 — reachability proven.
     - **1st full-stack agent run** (`reviews/device-test-report-2026-06-02-fullstack.md`) found a
       **REAL BUG: missing `android.permission.INTERNET`** → all sockets `EPERM` on `POST /auth/v1/otp`.
       Missed by every unit/integration/Robolectric test (none open a real socket). **Fixed by `0040`**
       (`786c12d`, one-line manifest add; verified; APK rebuilt+reinstalled).
     - **2nd full-stack agent run after the fix** (`reviews/device-test-report-2026-06-02-fullstack-pass.md`):
       **🎉 PASS end-to-end.** Real OTP sign-in (otp 200 → Mailpit code → verify 200 → token) →
       `GET /plants` 200 → add-plant via **catalog dropdown + select-or-create** (plant-profiles 200,
       containers/garden-spaces/plants 201) → water **CareTask** + HIGH container-size **advisory**
       render → **Accept** (`advisories/accept` 201 → repot task). No crashes.
     - **Reminder path verified by the planner** (the agent's steps 9–11 had only failed because it
       never returned to the LIST; `ReminderSync` runs on app-open/list-load): cold-start→list →
       two `plant-reminder` `ReminderWorker`s (repot **SUCCEEDED** immediately, water **ENQUEUED** for
       Jun 3) → **notification POSTED** on channel `plant_care_reminders`: **"Plant care reminder / A
       'repot' task is due"** (shade screenshot `device-evidence/H-reminder-shade.png`). **All 12
       steps PASS** (report addendum records the correction).
     - **UX note (tracked, not a bug):** reminders (re)schedule on app-open/list-load, not right after
       add/accept — candidate follow-up: also sync after those actions.
     - **Teardown:** owner chose tear-down. **Fastify stopped** (`:3000` free); Supabase left running
       (pre-existing); **owner to re-close ufw** (`sudo ufw delete allow … 54321/3000`). Slice 3 retro
       written (`reviews/slice-3-retro.md`).

## 🔴 TOP PRIORITY (new, 2026-06-02): beginner-first UX overhaul
Owner: **"The beginner UX is absolutely atrocious; the MVP must be usable by an elderly/novice
non-gardener."** This now outranks FCM. The add-plant flow exposes jargon/raw fields a novice can't
answer (container **liters/material/drainage**, free-text **growth stage**, **ISO last-watered**,
scientific-ish species dropdown, garden-space **"kind"**). Plan = redesign to plain-language,
picture-led, smart-defaulted, guided flow; the deterministic engine derives technical values from
simple choices. See memory `[[beginner-first-ux]]`. **Direction CONFIRMED by owner + build STARTED.** Owner choices: 3-step wizard · icon+plain-name
tiles · add-plant first (then copy sweep) · pot sizes labeled **"how pots are sold"** (4-inch/6-inch/
1-gal/5-gal bucket/window box/raised bed, mapped to litres internally; novice never sees litres).
Spec: `reviews/beginner-ux-addplant-spec.md`. Decomposition: **H1 `0041` ✅ DONE** (`12f0dbb`: pot-size→litres + location presets + hidden
defaults; verified, only `:feature-inventory`) → **H2 `0042` ✅ DONE (`5f1e7ce`)**: 3-step `AddPlantWizard` + confirm, 11 custom non-emoji vector
drawables, `AddPlantScreen` deleted, `WizardIcons` mapping, emoji `categoryIcon` removed; hardening
applied (reuse-not-duplicate, select-by-identity, Add disabled until ids resolve); `:feature-inventory`
20 tests green, assemble OK; verified vs real git. Icons are **simple placeholders** (refine later).
→ **device walkthrough DONE** (first-run, real S24 Ultra; backend re-stood-up: Fastify task
`bukr6ufh1`, ufw open): full flow PASSed (sign-in via Mailpit OTP 200 → empty list → wizard →
Tomato/Balcony/5-gal → CareTask + advisory → all 200/201; screenshots `device-evidence/W01–W12`).
→ **icon upgrade `0043` ✅ DONE (`c485afc`)**: CC0 open-crop-icons species (SVGO-inlined → real
fills) + Material Symbols pots/locations (distinct: bucket→Compost, window-box→Window, raised-bed→Grass);
`material-icons-extended` dep; placeholders deleted; ICON_LICENSES.md; `:feature-inventory` 20 green;
verified vs real git (scoped, no raster). Icon APK installed on the phone.
→ **NEW (owner 2026-06-02): modern/thematic UI overhaul.** Owner: make the app "highly thematic /
beautiful / modern" (pivoted away from accessibility-first framing — content stays beginner-plain,
but the LOOK is modern/premium). Using **Codex** (per owner; `[[using-codex-cli]]`): generated 3
modern directions (`reviews/theme-directions-modern.md`) — **Verdant Glasshouse** (codex rec:
conservatory glass/blur, Fraunces+Manrope), **Midnight Botanical** (editorial dark, Cormorant+Plus
Jakarta), **Wildflower Pop** (playful, Bricolage+DM Sans). **Awaiting owner pick**, then build the
`:design-system` theme (currently bare default M3) + apply across screens. `:design-system/Theme.kt`
today = `MaterialTheme(content)` only (no color/type/shape).
→ **copy sweep (queued)** — fixes from the walkthrough:
  - **Plant DETAIL leaks dev data (worst):** shows the scientific slug `solanum-lycopersicum` (not
    "Tomato"), raw engine rationale ("base interval 2d adjusted by container factor 1; baseline <ISO>"),
    an "engine v0.1.0" badge, ISO timestamps → hide/translate to plain ("Water by Jun 4").
  - Confirm screen should **echo the pot choice** (currently only species+location).
  - Sign-in: add a "we emailed you a 6-digit code" instruction + a send confirmation.
  - Advisory: drop the "MEDIUM ·" severity prefix; friendly wording.
  - (Icons handled by `0043`.)

## Device backend (left UP for the icon re-review) — teardown pending
Fastify `bukr6ufh1` on `0.0.0.0:3000`; Supabase running; ufw open (owner re-added). After the icon
re-review: stop Fastify + owner re-closes ufw. (FCM deferred/owner-gated.)
**Icons (owner decision): NO EMOJI — custom per-species vector drawables.** `0041` shipped an emoji
`categoryIcon`; **`0042` removes it** and bundles original, distinct, recognizable vector drawables
per species (+ pot/location icons), mapped `profileId→drawable`. (No open vector set covers these
species without being emoji art → author originals; owner approves look on-device.)
- **Transport decision (2026-06-02):** owner chose **cleartext-on-LAN for the local device test**
  (debug-only NSC). **Production stays HTTPS** — release builds keep Android's no-cleartext default;
  hosted Supabase is HTTPS; a deployed Fastify would be behind TLS. **Tracked requirement: prod = HTTPS.**
  (Local-HTTPS-via-owner-CA was the alternative; deferred — more setup, not needed for a functional smoke.)
- APK tested was the pre-built debug (mtime 09:05, targetSdk 35), trails HEAD `369f2f0` — fine for
  the smoke; rebuild for the real full-stack pass.

## Structural debt (tracked; not blockers)
- **Sign-in lives in `:feature-inventory`** (3c-ui, MVP pragmatism — no new Gradle module). Vision's
  module table implies a dedicated `:feature-auth`/`:feature-settings`. Migrate before later phases
  when `:feature-inventory` gets too broad. (Flagged by `0028` vision-check.)

## Deferrals (tracked; not blockers)
Add-plant form = id text fields (no selectors yet); optional `nickname`/`placement` not in
the form; no sign-in UI (token via DataStore); no on-device run yet; Room deferred (Slice 3+);
ViewModels not unit-tested; lint-config fixed but **no CI** enforces the suites on GitHub.

## Workflow (durable)
Autonomous in-session ping-pong (planner ↔ impl via `exchange/` watchers; impl
`--dangerously-skip-permissions`). Gates: standalone-verification (PD-05), atomic exchange
(PD-06), vision-alignment vs `../PlantApp/ChatHistory.md` (`reviews/vision-checks.md`). DB +
gradle harness quirks (external-Drive symlinks): memory `plantapp-local-db-harness`.
