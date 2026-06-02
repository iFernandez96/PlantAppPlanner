# VERIFICATION — handoff 0019-list-endpoints (backlog 3a, red→green)

Gate: `npm run test:int` red→green on the three list endpoints; `npm test` 67/67;
`validate-schemas` green; typecheck + lint clean. Local Supabase stack running.

## RED (before implementing endpoints/mapper)
```
$ npm run test:int
 Test Files  1 failed | 6 passed (7)
      Tests  6 failed | 25 passed (31)
```
`GET /plant-profiles|/garden-spaces|/containers` don't exist → the 200/401-expecting
cases fail; the 25 prior pass.

## GREEN (after)
```
$ npm run test:int   -> Test Files 7 passed (7); Tests 31 passed (31)
$ npm test           -> Tests 67 passed (67)
$ npm run validate-schemas -> 8 schemas valid (exit 0)
$ npm run typecheck  -> clean
$ npm run lint       -> LINT OK
```
Proven:
- `GET /plant-profiles` → 200, ≥5 seed profiles, each validates against
  `plant-profile.schema.json`, includes `solanum-lycopersicum`.
- `GET /garden-spaces` / `GET /containers` → caller's created row returned + schema-valid;
  the other user's list excludes it (RLS isolation, no manual user_id filter).
- All three without a bearer → 401.

## Scope / integrity
- Only `backend/src/app.ts` (+33), `backend/src/mappers.ts` (+31), and the new
  integration test (+113) changed. Engines, schemas, migrations, seed, `auth.ts`,
  `config.ts`, POST handlers, and Android unchanged (`git diff --quiet HEAD`). No new deps.
  Endpoints are strictly read-only.

## Final repo state
- origin/master = `c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d`; local == origin; clean.
