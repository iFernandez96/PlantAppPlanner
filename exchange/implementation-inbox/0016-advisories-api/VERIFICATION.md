# VERIFICATION — handoff 0016-advisories-api (S2.2, red→green)

Gate: `npm run test:int` red→green on the advisories endpoint; the `@slice-2` BDD scenarios
covered; every returned advisory validates against `advisory.schema.json`.
DB: local Supabase, migrations 0001–0004 applied via `supabase db reset`.

## Commit 1 (`623c91f`) — RED
```
 FAIL  tests/integration/advisories-api.integration.test.ts
 Test Files  1 failed | 5 passed (6)
      Tests  3 failed | 22 passed (25)
```
`GET /plants/:id/advisories` route doesn't exist → Fastify 404 makes the 200-expecting
advisory tests fail; the 22 prior pass. Intended red.

## Commit 2 (`8d3e813`) — GREEN
```
 ✓ tests/integration/advisories-api.integration.test.ts (4 tests)
 Test Files  6 passed (6)
      Tests  25 passed (25)
$ npm test           -> 67 passed (67)
$ npm run typecheck  -> clean
$ npm run lint       -> LINT OK
```
BDD scenarios proven (presence-asserted, schema-validated):
- container-size: passion fruit in 19 L → a `container-size` advisory, `severity:"high"`,
  message contains `95` and `190` (ideal range from migration 0004 / seed enrichment).
- support: passion fruit (requiresSupport) with no supportRecorded → a `support` advisory.
- pollination single: one tomatillo → a `pollination` advisory; after adding a second
  tomatillo (same user) → the first plant's advisories no longer include `pollination`
  (RLS-scoped instance count reaches 2).
- RLS: user B → `GET /plants/{A's id}/advisories` → 404.

Migration apply (commit 2):
```
Applying migration 0001..0003 ...
Applying migration 0004_slice1_profile_ideal_range.sql ...
Finished supabase db reset
```

## Scope / integrity
- `computeAdvisories`, `computeInitialWaterTask`, all shared schemas, prior migrations
  (0001–0003), the auth hook, and the existing POST endpoints unchanged (`git diff
  --quiet HEAD`). No Android, no new deps. Endpoint creates no CareTask (reads + computes).

## Final repo state
- origin/master = `8d3e813cc35f37f6b2cbf592dfbfb47bd072b096`; local == origin; clean.
- Backend: integration 25/25, unit 67/67, typecheck + lint clean. (Pre-existing
  `validate-schemas` CLI failure unchanged — out of scope; pending its hygiene handoff.)
