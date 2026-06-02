# DONE — handoff 0014-slice2-foundation (S2.0, two commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** Slice 2 plan doc + `Advisory` shared schema added; advisory schema test
red→green; `npm test` 61/61. **One pre-existing finding surfaced** (`npm run
validate-schemas` is script-wide red — details below; NOT caused by this change).
Final `origin/master` = `06f581d029e191992214a1cd3ee0da0514c345e9`.

## Baseline precondition — matched
- HEAD = `a568a4d4ac746e3d3e9942263af32d5bf75356b2` == origin/master; clean.

## Commit 1 (RED) — `docs(slice-02): add Slice 2 plan + advisory schema-validation test (red)`
- Hash: `5e77801`
- `docs/slice-02-implementation-plan.md`: goal (deterministic, profile-driven advisories,
  no auto-created CareTasks), the three rules (container-size sev high; support;
  pollination with active-instance count), the no-auto-task invariant, decomposition
  (S2.0 schema → S2.1 engine → S2.2 API → S2.3 Android), the seed-data gap
  (`idealMin/MaxLiters` to enrich in S2.1), scope, and DOD (the five `@slice-2` scenarios).
- `backend/tests/schema/advisory.test.ts`: accepts a valid container-size/support/
  pollination advisory; rejects unknown `kind`, unknown `severity`, and each missing
  required field.
- `npm test` (RED): advisory test failed (ENOENT — `advisory.schema.json` not found); the
  other 50 passed. Intended red.
- `git show --stat`: 2 files, +178. Pushed `a568a4d..5e77801`.

## Commit 2 (GREEN) — `feat(schema): add Advisory shared schema (Slice 2 contract)`
- Hash: `06f581d`
- `shared-schemas/advisory.schema.json` (2020-12, `additionalProperties:false`): exactly
  the contract from the prompt — `kind` (container-size|support|pollination), `severity`
  (low|medium|high), `plantInstanceId` (uuid), `profileId`, `title`, `message`, optional
  `details` (free-form object), optional `createdAt`.
- `npm test` → **61 passed (61)** (the advisory test now green; prior 50 unchanged).
- `git show --stat`: 1 file, +19. Pushed `5e77801..06f581d`.

## Verification
- `cd backend && npm test`: RED at commit 1 (advisory test ENOENT; 50 pass) → GREEN at
  commit 2 (**61 passed**). The advisory schema validates via the Ajv test helper
  (`_helpers.ts`, strict 2020-12 + ajv-formats).
- `npm run typecheck` / lint: unaffected (no TS/source changes).

## ⚠️ Pre-existing finding — `npm run validate-schemas` is red (script-wide, NOT from this change)
`npm run validate-schemas` exits **1** and flags **all 8** shared schemas, e.g.:
```
schema ../shared-schemas/advisory.schema.json is invalid
  error: unknown format "uuid" ignored ... #/properties/plantInstanceId
schema ../shared-schemas/care-task.schema.json is invalid
  error: unknown format "uuid" ignored ... #/properties/id
schema ../shared-schemas/diagnosis-result.schema.json is invalid
  error: strict mode: missing type "array" for keyword "maxItems" ... (strictTypes)
... (container, garden-space, plant-instance, plant-profile, space-plan: same "unknown format uuid/uri")
```
Root cause (pre-existing since the first schema landed, unrelated to advisory): the script
`ajv compile --spec=draft2020 --all-errors --strict=true -s '../shared-schemas/*.schema.json'`
does **not** load `ajv-formats`, so under `--strict=true` the `uuid`/`uri`/`date-time`
formats are "unknown format … ignored" errors; `diagnosis-result.schema.json` additionally
trips `strictTypes` (a `maxItems` under a conditional `then` with no `type:"array"`). The
advisory schema is flagged for the **same** `uuid`-format reason as every other schema —
it is correct (it compiles and validates under the test helper, which adds ajv-formats;
`npm test` is 61 green).

I did **not** silently fix this: a full fix needs `package.json` (add `-c ajv-formats` to
the ajv-cli invocation) **and** a change to `diagnosis-result.schema.json` (a forbidden
"other schema" this handoff). Recommend a dedicated tooling-hygiene handoff (analogous to
the earlier lint-config fix): add `ajv-formats` to the `validate-schemas` command (it's
already a backend dependency — no new dep) and add `"type": "array"` to the
diagnosis-result conditional `then.properties.recommendations`. That would make
`validate-schemas` green across all schemas including advisory.

## Compliance
- No advisory engine/API/Android code (S2.1–S2.3). No new deps. `@slice-2` `.feature`
  scenarios untouched.
- `backend/care-engine/**`, `backend/src/**`, `supabase/**`, other shared schemas,
  migrations, and existing tests UNCHANGED (`git diff --quiet HEAD`). Only the plan doc,
  the advisory schema test, and `advisory.schema.json` were added.

## Commit hashes + titles
1. `5e77801` — docs(slice-02): add Slice 2 plan + advisory schema-validation test (red)
2. `06f581d` — feat(schema): add Advisory shared schema (Slice 2 contract)

Final `origin/master` SHA: `06f581d029e191992214a1cd3ee0da0514c345e9`

## Next (S2.1, per planner follow-up)
Deterministic `computeAdvisories(...)` engine (backend TS, pure; the 3 rules + no-auto-task
invariant; pollination needs the user's active-instance count for the profile), red-first
unit tests validating output against `advisory.schema.json`, and seed enrichment with
`idealMinLiters/idealMaxLiters` where the container-size advisory cites an ideal range
(e.g. passion fruit 95/190). Consider folding the `validate-schemas` tooling fix into a
small hygiene handoff so the schema-validation gate is meaningful again.
