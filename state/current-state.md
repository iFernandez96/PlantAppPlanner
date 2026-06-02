# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 (A2 core tables landed; A3a Fastify API in flight) |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `670ebaf9c68d5325de0058dcdc7ccf1eefce35b6` (`670ebaf`) — in sync, clean |
| **Slice 1 chain** | …`b32e7a4`→`661a135`→`8d1905a`→`e92bc0f`→`e2c3795`→`670ebaf` (50 unit + 12 integration green) |

## Where we are
**Backend Slice 1: unit layer complete (50 tests) + DB foundation started.**
- Schema validation (#1–#6), care-engine (#7–#14), seed catalog — all green (`npm test` 50/50).
- DB: Supabase local dev stood up (D-03); `garden_spaces` table + owner RLS; 3 integration
  tests green (`npm run test:int`). Verified at `e92bc0f`.

## Milestone A (owner-approved) — decomposition + status
- **A1 (done, verified):** `0004-db-garden-spaces` → `661a135` (pg dep + `supabase init`),
  `8d1905a` (red integration test), `e92bc0f` (green: `garden_spaces` + RLS migration 0002).
- **A2 (done, verified):** `0005-db-core-tables` → `e2c3795` (red) + `670ebaf` (green):
  4 tables + RLS + seeded `plant_profiles`; 12 integration tests green.
- **A3a (IN FLIGHT):** `0006-api-add-plant` — Fastify + ADRs (framework + JWT-forwarding
  auth) + `POST /garden-spaces|/containers|/plants` (→ care-engine → persist CareTask) +
  `GET /plants/:id/tasks` + integration tests #15–#18 (happy path + validation 400s).
- **A3b (next):** #19 RLS isolation (2 users) + #20 `DELETE /plants/:id` cascade.

Exchange: `0001`–`0005` ✓ · `0006-api-add-plant` (in flight).
DDL note for the API: snake_case; `care_tasks.source_inputs` jsonb; `user_id`
denormalized; engine camelCase→snake_case mapping in `POST /plants`.

## Local DB harness (for next steps)
`npx supabase` needs `npm_config_cache=/tmp/plantapp-npx-cache` (Drive symlink quirk).
Local DB URL `postgresql://postgres:postgres@127.0.0.1:54322/postgres`; integration tests =
`backend/tests/integration/*.integration.test.ts` via `npm run test:int`. See memory
`plantapp-local-db-harness`.

## Production behavior state
care-engine emits a deterministic water `CareTask`; `garden_spaces` table + RLS exist.
No HTTP server/endpoints yet; remaining tables in flight (A2). No Android source. No
AI/weather/photos/notifications.

## Autonomous loop
Planner + impl Claude ping-pong via `exchange/` with in-session `run_in_background`
watchers (impl runs `--dangerously-skip-permissions`). Owner pre-approved through A;
planner posts an update each round, stops only on a real blocker. A2 watcher armed.
