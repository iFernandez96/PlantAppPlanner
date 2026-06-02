# DONE — handoff 0018-validate-schemas-fix (single commit)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `npm run validate-schemas` is green again — all 8 shared schemas compile
(exit 0). `npm test` 67/67, typecheck + lint clean. Two-line config/schema fix; no runtime
behavior change.
Final `origin/master` = `392ba8640aea98f4091e8a61c4180495c4bbf0f9`.

## Baseline precondition — matched
- HEAD = `c4e4396bde2470706abe04a29b53ed307e430028` == origin/master; clean.
- `npm run validate-schemas` exited 1 with all 8 schemas flagged ("unknown format
  uuid/uri/date-time" + a `diagnosis-result` `strictTypes` error).

## The two minimal changes
1. **`backend/package.json`** — `validate-schemas` script: added `-c ajv-formats` so the
   ajv CLI loads the formats plugin (already a backend dependency; no new dep).
   - Before: `ajv compile --spec=draft2020 --all-errors --strict=true -s '../shared-schemas/*.schema.json'`
   - After:  `ajv compile --spec=draft2020 -c ajv-formats --all-errors --strict=true -s '../shared-schemas/*.schema.json'`
2. **`shared-schemas/diagnosis-result.schema.json`** — the conditional `then` property that
   carried `maxItems` now also declares its type (smallest change satisfying `strictTypes`):
   - Before: `"recommendations": { "maxItems": 0 }`
   - After:  `"recommendations": { "type": "array", "maxItems": 0 }`
   (Intent unchanged: when `status` is `out_of_scope`, `recommendations` must be an empty array.)

## Verification (the gate)
```
$ npm run validate-schemas    # before: exit 1, 8 "is invalid"
> ajv compile --spec=draft2020 -c ajv-formats --all-errors --strict=true -s '../shared-schemas/*.schema.json'
schema ../shared-schemas/advisory.schema.json is valid
schema ../shared-schemas/care-task.schema.json is valid
schema ../shared-schemas/container.schema.json is valid
schema ../shared-schemas/diagnosis-result.schema.json is valid
schema ../shared-schemas/garden-space.schema.json is valid
schema ../shared-schemas/plant-instance.schema.json is valid
schema ../shared-schemas/plant-profile.schema.json is valid
schema ../shared-schemas/space-plan.schema.json is valid
# exit 0
$ npm test           -> Test Files 10 passed (10); Tests 67 passed (67)
$ npm run typecheck  -> clean
$ npm run lint       -> LINT OK
```

## Compliance
- Only `backend/package.json` and `shared-schemas/diagnosis-result.schema.json` changed
  (`git show --stat`: 2 files, +2/−2). No other schema, engine, API, migration, Android,
  or test-assertion change. No new deps. `--strict`/`--all-errors` were NOT relaxed —
  fixed at the root cause (formats plugin + the one missing `type`).

## Commit
- `392ba86` — chore(backend): make validate-schemas pass (ajv-formats + diagnosis-result type)

Final `origin/master` SHA: `392ba8640aea98f4091e8a61c4180495c4bbf0f9`

## Next (per planner follow-up)
Backlog (3) UX follow-ups, decomposed: (3a) backend list endpoints (`GET /plant-profiles`,
`GET /garden-spaces`, `GET /containers`) + integration tests; (3b) Android add-plant
selectors; (3c) Supabase magic-link sign-in → DataStore token; (3d) advisory→accept→CareTask
flow. Then (2) emulator e2e smoke; then (4) Slice 3 (watering reminders; WorkManager local
first, then stop for owner Firebase/FCM setup).
