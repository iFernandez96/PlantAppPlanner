# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `369f2f0` — feat(android): request POST_NOTIFICATIONS at runtime for local reminders (Slice 3) |
| Local == origin/master? | ✅ yes (`369f2f0` both sides) |
| Uncommitted changes? | none (clean; git-ignored `android/local.properties` may exist) |
| CI / workflows / checks / PRs / issues | **none** — no CI, no open PRs, no open issues |
| Default branch | `master` |

**Backlog (1)(2)(3) complete; Slice 3 LOCAL path complete (`0037`).** On-device smoke (real S24
Ultra / Android 16) PASSed install/launch/gating/sign-in-UI/WorkManager; full-stack blocked at the
first network call (`CLEARTEXT to 10.0.2.2 not permitted`). See
`reviews/device-test-report-2026-06-02.md`.

**Owner chose "wire it & re-test".** On-device full-stack enablement in progress:
**`0038-backend-server-bootstrap` published & IN FLIGHT** — adds `backend/src/server.ts`
(`listen 0.0.0.0:PORT`) + `start` script (the Fastify app had no HTTP entry point, only
`app.inject()` in tests). Gate: build → boot (dummy env) → `GET /plants` → 401 → unit 72/72. Vision
N/A (infra/runnability); **no-mutation guardian PASS**. Watcher armed for `0038`. **Next:** Android
device-debug build (split LAN base URLs + cleartext NSC + rebuild) → run LAN Supabase+Fastify (owner
opens ufw 54321+3000) → reinstall + re-run the device agent suite.
