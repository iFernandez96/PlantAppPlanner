# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 — **Slice 1 DOD #1–#24 engineering-complete; loop paused for owner** |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `c4e4396bde2470706abe04a29b53ed307e430028` (`c4e4396`) — in sync, clean |

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
  - **(1) `validate-schemas` fix — IN FLIGHT (`0018`).**
  - **(3) UX follow-ups:** 3a backend list endpoints (`GET /plant-profiles|/garden-spaces|/containers`)
    → 3b Android form selectors → 3c Supabase sign-in screen → 3d advisory→accept→CareTask flow.
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

## Deferrals (tracked; not blockers)
Add-plant form = id text fields (no selectors yet); optional `nickname`/`placement` not in
the form; no sign-in UI (token via DataStore); no on-device run yet; Room deferred (Slice 3+);
ViewModels not unit-tested; lint-config fixed but **no CI** enforces the suites on GitHub.

## Workflow (durable)
Autonomous in-session ping-pong (planner ↔ impl via `exchange/` watchers; impl
`--dangerously-skip-permissions`). Gates: standalone-verification (PD-05), atomic exchange
(PD-06), vision-alignment vs `../PlantApp/ChatHistory.md` (`reviews/vision-checks.md`). DB +
gradle harness quirks (external-Drive symlinks): memory `plantapp-local-db-harness`.
