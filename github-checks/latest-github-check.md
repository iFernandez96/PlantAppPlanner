# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `06f581d` — feat(schema): add Advisory shared schema (Slice 2 contract) |
| Local == origin/master? | ✅ yes (`06f581d` both sides) |
| S2.0 commits | `5e77801` (docs/plan + red advisory schema test) → `06f581d` (green `advisory.schema.json`) |
| Uncommitted changes? | none (clean) |
| CI / workflows / checks / PRs / issues | none |
| Default branch | `master` |

S2.0 verified: `git diff a568a4d 06f581d` = 3 files added (slice-02 plan doc,
`advisory.test.ts`, `advisory.schema.json`); care-engine/API/migrations/other schemas
untouched. `npm test` **61/61**.

**KNOWN ISSUE (pre-existing, tracked):** `npm run validate-schemas` is red for **all 8**
schemas — the `ajv-cli` invocation omits `ajv-formats` (so `uuid`/`uri`/`date-time` are
"unknown format" under `--strict`) + a `strictTypes` nit in `diagnosis-result`. It's a
redundant/broken gate (the real gate, `npm test`, validates schemas with ajv-formats and is
green). Fix = a tiny hygiene handoff (`-c ajv-formats` in `package.json` + `type:"array"` in
`diagnosis-result`). Not blocking Slice 2.

Next: S2.1 (`0015-advisory-engine`) in flight.
