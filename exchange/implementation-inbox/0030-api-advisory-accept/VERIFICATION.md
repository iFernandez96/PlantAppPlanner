# VERIFICATION — handoff 0030-api-advisory-accept (3d-api, red→green)

Gate: backend `test:int` (local stack up) + `test` + `validate-schemas` + `typecheck` + `lint`.

## RED driver
`advisory-accept.integration.test.ts` POSTs to `/plants/:id/advisories/accept`, which 404s
(unknown route) before the handler exists → the 201/400 expectations fail.

(Also caught a fixture bug mid-run: the "not applicable" case originally used tomato, which
*does* require support → 201; switched to strawberry in an in-range container, which has no
advisories. This was a test-fixture correction, not an endpoint change.)

## GREEN
```
$ set -a; eval "$(npx supabase status -o env)"; set +a
$ npm run test:int
 ✓ tests/integration/advisory-accept.integration.test.ts (4 tests)
 Test Files  8 passed (8)
      Tests  35 passed (35)
$ npm test                 Tests 72 passed (72)
$ npm run validate-schemas all schemas valid
$ npm run typecheck        tsc --noEmit, no errors
$ npm run lint             eslint ., no errors
```
- New `advisory-accept.integration.test.ts` — 4 tests, all pass:
  - container-size accept → 201, schema-valid, repot/high; **GET advisories created nothing**
    (`/tasks` count unchanged across two GETs, +1 only after the POST).
  - pollination → 400 (engine throw).
  - not-applicable (`support` on a strawberry with no advisories) → 400.
  - RLS: user B accept on user A's plant → 404.
- `test:int` count 31 → 35 (+4); unit unchanged 72/72; validate-schemas unchanged-green.

## Scope / integrity
- `git show --stat`: 2 files, +288 — only `backend/src/app.ts` (new POST handler + 1 import) +
  the new integration test. No care-engine/`advisories.ts`/schema/migration/Android/other-endpoint
  change. No new dependency. GET advisories remains create-nothing. RLS preserved (404). Only
  engine-returned task kinds (repot/support).

## Final repo state
- origin/master = `53d093e0ee570dcaf1e44a926dfb343935f6c7a8`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
