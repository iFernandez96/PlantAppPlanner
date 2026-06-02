# Next Implementation Prompt — fix `npm run validate-schemas` (tooling hygiene)

**Backlog item (1).** Make the `validate-schemas` gate green again. It's been red for all 8
shared schemas since the first schema landed — the `ajv` CLI is invoked without
`ajv-formats`, so `uuid`/`uri`/`date-time` are "unknown format" errors under `--strict`,
and `diagnosis-result.schema.json` trips `strictTypes` (a `maxItems`/array keyword without a
sibling `"type": "array"`). Config/schema-correctness only; no runtime behavior change.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `c4e4396` == `origin/master`,
clean. `ajv-formats` is already a backend dependency. `npm test` 67/67, `npm run test:int`
25/25. `npm run validate-schemas` currently exits non-zero.

Single logical change → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Make
`npm run validate-schemas` pass. **Consult the `ajv-cli` docs** for the formats flag.

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect c4e4396bde2470706abe04a29b53ed307e430028
git status --short                         # expect empty
cd backend && npm run validate-schemas     # expect FAIL (unknown format uuid/uri + strictTypes)
```

### The fix (two minimal changes)
1. `backend/package.json` — add the formats plugin to the `validate-schemas` script so
   `ajv` loads `ajv-formats` (e.g. add `-c ajv-formats` to the `ajv compile …` invocation).
   No new dependency (`ajv-formats` is already present). Don't change other scripts.
2. `shared-schemas/diagnosis-result.schema.json` — add the missing `"type": "array"` on the
   object that carries `maxItems` (the `strictTypes` error points to it; likely a
   conditional `then` array property). Smallest change that satisfies strict mode; do NOT
   alter the schema's intent or other schemas.

### Forbidden
- No change to other schemas, the engines, the API, migrations, Android, or any test
  assertion. No new deps. Don't relax `--strict`/`--all-errors` to mask the issue — fix the
  root cause (formats plugin + the one missing `type`).

### Standalone verification
```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm run validate-schemas   # expect: all 8 schemas compile, exit 0
npm test                    # still 67/67
npm run typecheck && npm run lint   # clean
```
This is the gate: `validate-schemas` goes red → green; nothing else changes.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/package.json shared-schemas/diagnosis-result.schema.json
git -C /home/israel/Documents/Development/PlantApp commit -m "chore(backend): make validate-schemas pass (ajv-formats + diagnosis-result type)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The exact `package.json` script change + the `diagnosis-result` `type` addition.
2. `npm run validate-schemas` before (error sample) → after (exit 0, 8 schemas);
   `npm test` 67/67; typecheck + lint clean.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only those 2
   files changed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify `validate-schemas` green + `npm test` 67/67. Then **backlog (3) UX follow-ups**,
decomposed: (3a) backend list endpoints needed by the form selectors — `GET /plant-profiles`
(catalog, read-only), `GET /garden-spaces`, `GET /containers` (RLS), schema-conformant +
integration tests; (3b) Android add-plant **selectors** (profile dropdown from the catalog;
container/garden-space select-or-create) replacing the id text fields, + UI tests; (3c) a
Supabase magic-link **sign-in** screen writing the token to DataStore; (3d) **advisory →
accept → CareTask** flow (a backend endpoint that creates a task from an advisory on
explicit user acceptance — routed through the engine, NOT auto-created — + Android action).
Then (2) an automated **emulator e2e smoke** (instrumented test booting the app against the
backend) — note the human "add my real plants on my device" acceptance stays with the owner.
Then (4) **Slice 3** (deterministic watering reminders; WorkManager local path first, then
**stop and ask the owner for Firebase/FCM setup** — needs a Firebase project + `google-services.json`).
Vision-check each product-surface step.
