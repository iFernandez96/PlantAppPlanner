# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 — **Slice 1 DOD #1–#24 engineering-complete; loop paused for owner** |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `4f3d76a6d8c85b6f847e01b690590c0e54a98861` (`4f3d76a`) — in sync, clean |

## 🎉 Slice 1 complete (engineering) — #1–#24 green
- **Backend:** schema tests (#1–#6) · deterministic care-engine (#7–#14) · seed catalog ·
  Supabase schema + RLS · Fastify add-plant→CareTask API + auth(RLS) · #15–#18 · RLS
  isolation #19 · delete cascade #20 · all responses camelCase-conformant (Ajv-locked).
- **Android:** `:network` Retrofit DTOs (schema-validated) · `:domain`/`:data` repository ·
  `:feature-inventory` Compose add/list/detail + nav + UI tests #21–#24 (Robolectric).
- **Tests:** backend unit 50/50, integration 21/21, lint+typecheck clean; Android
  `:network` 10/10, `:domain` 2/2, `:data` 5/5, `:feature-inventory` 4/4; `:app:assembleDebug` OK.
- **Retro:** `reviews/slice-1-retro.md`. Exchange handoffs `0001`–`0013` all ✓.

## Slice 2 (advisories) — IN PROGRESS (owner chose option 3)
Deterministic, profile-driven advisories surfaced in the UI, **never auto-creating
CareTasks** (BDD: `features/container-health.feature` `@slice-2`).
- **S2.0 done (`06f581d`):** slice-02 plan + `advisory.schema.json` + schema test.
- **S2.1 done (`4f3d76a`):** deterministic `computeAdvisories` engine (3 rules + no-auto-task
  invariant), `npm test` 67/67.
- **S2.2 (IN FLIGHT):** `0016-advisories-api` — `GET /plants/:id/advisories` (RLS-scoped, creates
  no task) + migration `0004` ideal-range + seed enrichment + slice-02 plan-line fix + integration
  tests (5 `@slice-2` scenarios; passion fruit 95/190; RLS 404). Vision ALIGNED. Watcher armed.
- **Next:** S2.3 Android advisory display (`:network` DTO + repo `getAdvisories` + plant-detail)
  + Compose UI test (closes Slice 2).
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
