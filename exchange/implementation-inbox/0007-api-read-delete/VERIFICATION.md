# VERIFICATION — handoff 0007-api-read-delete (red→green, objective evidence)

Integration command:
`set -a; eval "$(npx supabase status -o env)"; set +a; export SUPABASE_URL/ANON_KEY/SERVICE_ROLE_KEY; cd backend && npm run test:int`
(Fastify `app.inject()`; two users via service-role admin API; `pg` client for the
direct cascade check. Keys read at runtime; never committed.)

## Commit 1 (`cfb3751`) — RED (routes absent)
```
 FAIL  tests/integration/plants-rls-delete.integration.test.ts (3 tests)
 Test Files  1 failed | 3 passed (4)
      Tests  3 failed | 17 passed (20)
```
`GET /plants`, `GET /plants/:id`, `DELETE /plants/:id` don't exist → Fastify 404s make
A's own-plant read, the delete, and the post-delete survival assertions fail. Prior 17
pass. Exit non-zero — intended red.

## Commit 2 (`8f588af`) — GREEN
```
 ✓ tests/integration/garden-spaces-schema.integration.test.ts (3 tests)
 ✓ tests/integration/core-tables.integration.test.ts (9 tests)
 ✓ tests/integration/plants-api.integration.test.ts (5 tests)
 ✓ tests/integration/plants-rls-delete.integration.test.ts (3 tests)
 Test Files  4 passed (4)
      Tests  20 passed (20)
```

### #19 RLS isolation (green)
- `expect(idsB).not.toContain(plantId)` — B's `GET /plants` excludes A's plant.
- `expect(getB.statusCode).toBe(404)` — B's `GET /plants/:id` on A's plant → 404.
- B's `GET /plants/:id/tasks` on A's plant → 404/empty.
- A's own `GET /plants/:id` → 200 (sanity).

### #20 delete cascade (green)
- Direct DB before delete: `select count(*) from care_tasks where plant_instance_id=$1`
  = **1**.
- `expect(del.statusCode).toBe(204)`.
- Post-delete `GET /plants/:id` → 404; tasks → 404/empty.
- Direct DB after delete = **0** → `ON DELETE CASCADE` confirmed at the database.
- #20b: cross-user delete → 404; A's plant survives (200).

## Unit suite + typecheck
```
$ npm run typecheck  -> clean
$ npm test
 Test Files  8 passed (8)
      Tests  50 passed (50)
```

## Scope / integrity
- `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`, existing unit
  tests, `backend/src/auth.ts`, `backend/src/config.ts`, and the existing POST endpoints
  unchanged (`git diff --quiet HEAD`; app.ts diff additive +37/−0).
- No new deps; endpoints use the request-scoped user client (RLS authoritative), no
  service-role in handlers. Pre-existing lint-config issue left untouched (out of scope).

## Final repo state
- origin/master = `8f588af90c69b569db1abdeceb5d97020b56b6f6`; local == origin.
- Local Supabase stack left running. **Slice 1 backend DOD (#1–#20) met.**
