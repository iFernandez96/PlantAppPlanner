# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `4f3d76a` — feat(care-engine): add deterministic advisory engine (Slice 2) |
| Local == origin/master? | ✅ yes (`4f3d76a` both sides) |
| S2.1 commits | `1077764` (red advisory-engine tests) → `4f3d76a` (green `computeAdvisories`) |
| Uncommitted changes? | none (clean) |
| CI / workflows / checks / PRs / issues | none |
| Default branch | `master` |

S2.1 verified: `git diff 06f581d 4f3d76a` = 2 files (`care-engine/advisories.ts` +
`tests/care-engine/compute-advisories.test.ts`); `index.ts`/schemas/migrations/API/seed
untouched. Engine returns `Advisory[]` (no CareTask shape — invariant). `npm test` **67/67**,
typecheck + lint clean.

**KNOWN (pre-existing, tracked):** `npm run validate-schemas` red for all 8 schemas
(ajv-cli lacks `ajv-formats` + diagnosis-result strictTypes) — redundant/broken gate; real
gate `npm test` green. Tiny hygiene handoff candidate. Not blocking.

Next: S2.2 (`0016-advisories-api`) in flight — `GET /plants/:id/advisories` + migration 0004
ideal-range + integration tests.
