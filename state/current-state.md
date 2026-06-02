# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 (A1 DB landed; A2 core-tables in flight) |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `e92bc0f7bebaf02a15acea13b7f7ecd90ff47c1a` (`e92bc0f`) — in sync, clean |
| **Slice 1 chain** | `b2836ca`→`ce141da`→`1d4e888`→`25f1dbb`→`7a4e19b`→`b32e7a4`→`661a135`→`8d1905a`→`e92bc0f` |

## Where we are
**Backend Slice 1: unit layer complete (50 tests) + DB foundation started.**
- Schema validation (#1–#6), care-engine (#7–#14), seed catalog — all green (`npm test` 50/50).
- DB: Supabase local dev stood up (D-03); `garden_spaces` table + owner RLS; 3 integration
  tests green (`npm run test:int`). Verified at `e92bc0f`.

## Milestone A (owner-approved) — decomposition + status
- **A1 (done, verified):** `0004-db-garden-spaces` → `661a135` (pg dep + `supabase init`),
  `8d1905a` (red integration test), `e92bc0f` (green: `garden_spaces` + RLS migration 0002).
- **A2 (IN FLIGHT):** `0005-db-core-tables` — `plant_profiles` (seeded read-only),
  `containers`, `plant_instances`, `care_tasks` + RLS, red→green integration test.
- **A3 (next):** Fastify (+ ADR), `POST /plants` → care-engine + `GET`/`DELETE` +
  integration tests #15–#20 (incl. RLS isolation + cascade delete).

Exchange: `0001`✓ `0002`✓ `0003`✓ `0004`✓ · `0005-db-core-tables` (in flight).

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
