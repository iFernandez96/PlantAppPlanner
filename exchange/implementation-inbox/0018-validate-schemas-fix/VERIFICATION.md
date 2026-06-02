# VERIFICATION — handoff 0018-validate-schemas-fix

Gate: `npm run validate-schemas` red → green; nothing else changes.

## Before (HEAD c4e4396)
```
$ cd backend && npm run validate-schemas ; echo $?
... schema ../shared-schemas/<each> is invalid
  (unknown format "uuid"/"uri"/"date-time" ignored; diagnosis-result strictTypes)
1
```

## After (HEAD 392ba86)
```
$ npm run validate-schemas
schema ../shared-schemas/advisory.schema.json is valid
schema ../shared-schemas/care-task.schema.json is valid
schema ../shared-schemas/container.schema.json is valid
schema ../shared-schemas/diagnosis-result.schema.json is valid
schema ../shared-schemas/garden-space.schema.json is valid
schema ../shared-schemas/plant-instance.schema.json is valid
schema ../shared-schemas/plant-profile.schema.json is valid
schema ../shared-schemas/space-plan.schema.json is valid
# exit 0
```

## Unaffected
```
$ npm test           -> Test Files 10 passed (10); Tests 67 passed (67)
$ npm run typecheck  -> clean
$ npm run lint       -> LINT OK
```

## Root-cause fix (not masked)
- `-c ajv-formats` makes the ajv CLI recognize `uuid`/`uri`/`date-time` (plugin already a
  backend dep), instead of relaxing `--strict`.
- `diagnosis-result.schema.json` conditional `then.recommendations` now declares
  `"type": "array"` alongside `maxItems` (the exact `strictTypes` complaint), intent
  unchanged (out_of_scope ⇒ empty recommendations array).

## Scope / integrity
- `git show --stat HEAD`: 2 files changed, +2/−2 — only `backend/package.json` and
  `shared-schemas/diagnosis-result.schema.json`. No engine/API/migration/Android/test
  changes; no new deps; strict flags retained.

## Final repo state
- origin/master = `392ba8640aea98f4091e8a61c4180495c4bbf0f9`; local == origin; clean.
