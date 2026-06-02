# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `8d3e813` — feat(api): add GET /plants/:id/advisories + seed ideal container range (Slice 2) |
| Local == origin/master? | ✅ yes (`8d3e813` both sides) |
| S2.2 commits | `623c91f` (red advisories integration tests) → `8d3e813` (green endpoint + migration 0004 + seed) |
| Uncommitted changes? | none (clean) |
| CI / workflows / checks / PRs / issues | none |
| Default branch | `master` |

S2.2 verified: `git diff 4f3d76a 8d3e813` = `src/app.ts`, `care-engine/seed-profiles.ts`,
new `advisories-api.integration.test.ts`, `docs/slice-02-implementation-plan.md`, new
migration `0004`. Engines (`computeAdvisories`/`computeInitialWaterTask`), advisory + other
schemas, prior migrations (0001–0003), auth hook, and POST endpoints UNTOUCHED; `0004` is an
additive jsonb merge. **integration 25/25, unit 67/67**, typecheck + lint clean. All 5
`@slice-2` scenarios green (passion fruit cites 95/190; pollination clears on 2nd tomatillo;
RLS 404).

**KNOWN (pre-existing, tracked):** `npm run validate-schemas` red (ajv-cli lacks
`ajv-formats`) — not blocking; tiny hygiene handoff candidate.

Next: S2.3 (`0017-android-advisories`) in flight — closes Slice 2.
