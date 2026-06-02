# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 (seed catalog landed; loop paused before milestone A on env + framework decisions) |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `b32e7a46a5b8390f9d5ed1616e41dee7f701729c` (`b32e7a4`) — in sync, clean |
| **Commit chain (Slice 1)** | `b2836ca` → `ce141da` → `1d4e888` → `25f1dbb` → `7a4e19b` → `b32e7a4` |

## Last confirmed commits (planner-verified)
```
b32e7a4 feat(care-engine): add Slice 1 seed PlantProfile catalog
7a4e19b test(care-engine): add Slice 1 seed-catalog failing tests
```
Verified: only 2 new files since `25f1dbb` (`care-engine/seed-profiles.ts`,
`tests/care-engine/seed-catalog.test.ts`); engine/schemas/existing tests/package.json
untouched. `7a4e19b` red → `b32e7a4` green. `npm test` = **50/50**.

## Current phase
**Backend Slice 1 unit/contract layer COMPLETE & green (50 tests):** schema validation
(#1–#6), deterministic care-engine (#7–#14), seed catalog + schema-valid-CareTask. No
DB tables, no HTTP server, no Android source yet.

## Next step — milestone A IN FLIGHT (owner chose Supabase CLI)

Owner chose **(i) Supabase CLI** (D-03). Framework for A2 = Fastify (planner's call +
ADR). A decomposed into **A1** (in flight) → **A2**.
- **A1 (in flight):** published exchange handoff **`0004-db-garden-spaces`** — stand up
  Supabase local dev + `garden_spaces` table + RLS, proven by a red→green integration
  test (`npm run test:int`). Three commits (deps+init, red test, green migration).
  Deliberately minimal to de-risk the first CLI install / Docker image pull.
- **A2 (next):** Fastify + ADR, remaining tables (`plant_profiles` seeded read-only,
  `containers`, `plant_instances`, `care_tasks`) + RLS + `POST /plants` → care-engine +
  integration tests #15–#20.

Exchange: `0001`✓ `0002`✓ `0003`✓ `0004-db-garden-spaces` (in flight).

## (superseded) earlier pause note
Owner pre-approved A (API integration tests #15–#20 against a local Postgres/Supabase).
Read-only env check (2026-06-02) shows A can't start yet:
- **Supabase CLI: NOT installed** (Docker IS up). `supabase/` has only the extensions
  migration; no `config.toml` (not initialized). `psql`: not installed.
- **No web framework / server** in `backend/` (no `src/`, no express/fastify/hono/pg/
  supabase-js deps). The framework is an **un-pinned** decision (D-01 only pins Node+TS).
Two real decisions before A can run (asked the owner):
1. **DB approach / tool install** — (i) install Supabase CLI (matches D-03; pulls
   Docker images), (ii) lighter Dockerized plain Postgres + `pg` client (deviates from
   D-03), (iii) defer A.
2. **Web framework** for the endpoints (planner can decide + ADR; recommend on ask).
Planner proposes decomposing A into **A1** (migrations: create tables + RLS + a
DB-apply test) then **A2** (framework + server + endpoints + integration tests #15–#20).

Exchange handoffs: `0001-option-b` ✓, `0002-care-engine-green` ✓, `0003-seed-catalog` ✓.
No prompt pending, no watcher armed — resumes when the owner answers the A decisions.

## Autonomous loop
Planner + impl Claude ping-pong via `exchange/` with in-session `run_in_background`
watchers (impl runs `--dangerously-skip-permissions`). Paused at the A decision above.
