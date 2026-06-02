# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `e4ffe4b` — feat(care-engine): deterministic computeTaskFromAdvisory (accepted advisory -> CareTask) |
| Local == origin/master? | ✅ yes (`e4ffe4b` both sides) |
| `0029` commits | `e4ffe4b` (single commit; 2 new files `backend/care-engine/**` + test, +239) |
| Uncommitted changes? | none (clean; git-ignored `android/local.properties` may exist locally) |
| CI / workflows / checks / PRs / issues | **none** — no CI, no open PRs, no open issues |
| Default branch | `master` |

`0029` verified vs real git: `git diff e76ff8d e4ffe4b` = only `backend/care-engine/
task-from-advisory.ts` + its test; `index.ts`/`advisories.ts`/`src`/schemas/Android untouched.
Confirmed pure (`Date.now`/`random` appear only in a comment); not wired to any endpoint. `npm test`
67→72, `validate-schemas` green.

**"Do all" loop RUNNING.** (1)✅ (3a)✅ (3b)✅ (3c)✅ (3d-engine)✅. **3d-api
`0030-api-advisory-accept` published & IN FLIGHT:** `POST /plants/:id/advisories/accept {kind}` →
recompute advisories (RLS 404) → match applicable (400 if absent/unsupported) → deterministic
engine → persist one `care_tasks` row → return CareTask. Integration tests assert the
**GET-creates-nothing** invariant. Gate: `npm run test:int` (>31) + `npm test` 72. Vision ALIGNED
(reviewer verified columns/RLS vs the real repo; closes the `0016` no-CareTask DB-assert follow-up).
Watcher armed for `0030`. (3d-android follows, then e2e smoke, then Slice 3.)
