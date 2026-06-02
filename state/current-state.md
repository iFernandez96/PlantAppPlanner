# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 — **"do all" RUNNING; (1)✅ (3a)✅ (3b ALL)✅ (3c ALL)✅ (3d-engine/api)✅; (3d-android net+data) IN FLIGHT (`0031`)** |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `53d093e0ee570dcaf1e44a926dfb343935f6c7a8` (`53d093e`) — in sync, clean |

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
      assertion; verified vs real git (GET handler has no insert). **3d-android net+data IN FLIGHT
      (`0031`)** — `:network` `acceptAdvisory` + `AcceptAdvisoryRequest` DTO + `:domain`/`:data`
      repo method + `FakePlantAppApi` update + tests (net+data combined to avoid the interface-break
      across handoffs). → 3d-android-ui (detail-screen Accept action). **This is the last 3d step;
      after it, backlog (3) UX follow-ups COMPLETE.**
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
