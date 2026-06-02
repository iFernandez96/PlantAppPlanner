# Latest Handoff

**From:** "do all" backlog session · **Date:** 2026-06-02 · _(history below is older; see the
"Do all" section near the bottom + `state/current-state.md` for the live picture)_

## One-line status (2026-06-02)
"Do all" loop RUNNING. (1) `validate-schemas` ✅ (`0018`, `392ba86`). (3a) list endpoints ✅
(`0019`, `c7b8c54`) — 3 read-only endpoints + `toPlantProfile`, integration 31/31, verified vs
real git. (3b) Android selectors decomposed network→data→ui. 3b-network `0021` (`ce59e5e`) ✅; 3b-data
`0022` (`3fba718`) ✅ — `:domain` `PlantProfile` + repo list methods, `:data` 7/7 / `:domain` 2/2
(fixed `0021`'s latent `:data` compile-red). 3b-ui-a profile dropdown `0023` (`20f4e35`) ✅; garden-space `0024` (`5ce6f29`) ✅; container
`0025` (`8d51874`) ✅ — InventoryScreensTest 9/9, assemble OK. **3b (Android add-plant selectors)
COMPLETE — form fully selector-driven, no raw-id fields.** **3c sign-in: owner chose EMAIL OTP CODE.** net→data→ui. 3c-net `0026` (`a2f5e75`) ✅ — `:network`
GoTrue client (`SupabaseAuthApi` otp+verify + DTOs + factory, public apikey header, BASIC logging,
auth Json encodeDefaults=true); AuthDtoTest 3/3. 3c (sign-in) COMPLETE: 3c-net `0026`, 3c-data `0027`, 3c-ui `0028` (`e76ff8d`) — email-OTP screen
+ `:app` token-gating; `:feature-inventory` 14/14. **3d advisory→accept→CareTask: engine→api→android.**
3d-engine `0029` (`e4ffe4b`) ✅ — pure `computeTaskFromAdvisory` (container-size→repot,
support→support, pollination throws); `npm test` 67→72; verified pure & not endpoint-wired.
3d-api `0030` (`53d093e`) ✅ — `POST /plants/:id/advisories/accept {kind}` → engine → persist one
care_tasks row; `test:int` 31→35 incl. GET-creates-nothing; verified GET handler has no insert.
3d complete: net+data `0031` (`bfdd946`) ✅, UI `0032` (`d1bda81`) ✅ — per-advisory Accept button →
`acceptAdvisory` → reload; `:feature-inventory` 14→16. **🎉 Backlog (3) UX follow-ups COMPLETE**
(selector-driven add-plant · email-OTP sign-in + gating · advisory→accept→CareTask e2e). (2) e2e ✅ `0033` (`da020e3`), test-only Robolectric NavHost smoke (`:feature-inventory` 16→18).
**🎉 Backlog (1)+(2)+(3) COMPLETE.** **Slice 3 underway.** Opener `0034` (`79944a5`) ✅ — plan doc (D-13 + STOP gates) + pure
`computeReminders` in `:domain` (`:domain` 2→9). WorkManager local `0035` (`6f6f58b`) ✅ —
`ReminderScheduler`+`ReminderWorker`+WorkManager dep+`POST_NOTIFICATIONS`+channel; `:data` 11→14;
local-only (no FCM). app-open scheduling `0036` (`e8aaeec`) ✅ —
`ReminderSync` + `ReminderScheduling` seam + `Clock` + `PlantListViewModel` trigger; `:data` 14→15.
runtime `POST_NOTIFICATIONS` `0037` (`369f2f0`) ✅ — Compose `RequestPermission` launcher + pure
`shouldRequest` helper; `:feature-inventory` 18→22. **✅ LOCAL Slice 3 reminder path COMPLETE**
(`computeReminders` → WorkManager scheduling → app-open sync → runtime permission). **⏸ LOOP PAUSED
at the FCM STOP gate — owner question posted** (proceed with FCM server-push [needs Firebase project
+ `google-services.json` + a backend FCM sender + per-user token registration] vs defer / call
Slice 3 done at the local path). **No prompt published / no watcher armed until the owner decides.**
"Do all" backlog (1)(2)(3)(4) all delivered except the owner-gated FCM remainder. PlantApp HEAD
`369f2f0`. **Tripwire:** Drive mounted before any `gradlew`/npm/npx. **Gate note:** `:domain` →
`:domain:test`. **Owner manual check available:** run on a 33+ device, grant the permission, confirm
a reminder fires for a due task.

## On-device smoke (2026-06-02)
Owner directed a real-device test. Connected Samsung SM-S928U1 (Android 16/SDK36) over wireless adb
(`10.0.0.166:41027`; pair info from `FinanceWebsite/DEV.md`; Maestro 2.6.0 installed, scrcpy needs
sudo). Queued `reviews/device-test-suite.md`; QA agent ran T0–T12 → `reviews/device-test-report-2026-06-02.md`
+ `reviews/device-evidence/`. **✅ install · cold/warm launch (no crash) · unauth gating · sign-in UI
· WorkManager working · POST_NOTIFICATIONS granted. ⛔ full-stack BLOCKED at the first network call:
`CLEARTEXT … to 10.0.2.2 not permitted by network security policy`.** No crashes/regressions.
**To unblock on-device full-stack (3 prereqs, all impl-Claude/owner — planner can't):** (1) impl-Claude:
debug base URL → `10.0.0.179` **+** allow cleartext to it (debug `network-security-config` or HTTPS)
— repointing alone is insufficient; (2) run Supabase+Fastify on the LAN; (3) rebuild+reinstall, re-run
the agent. **Asked owner whether to proceed.** Loop still paused (FCM gate + this).

## On-device full-stack enablement — owner chose "wire it & re-test" (2026-06-02)
Discovered the Fastify backend has **no HTTP entry point** (only `app.inject()` in tests). Sequence:
**(1) backend server bootstrap — IN FLIGHT (`0038-backend-server-bootstrap`)** (`src/server.ts`
`listen 0.0.0.0:PORT` + `start` script; liveness gate: build → boot dummy-env → `GET /plants` 401;
vision N/A infra, guardian PASS). **(2) Android device-debug build** (split base URLs: auth→Supabase
`10.0.0.179:54321`, API→Fastify `10.0.0.179:3000`, debug-overridable; + debug cleartext
`network-security-config`; rebuild). **(3) run LAN stack** (planner owner-approved to run Supabase +
Fastify on the LAN; **owner opens ufw 54321+3000, sudo**) + reinstall + re-run the device agent suite.
PlantApp HEAD `e95c40e`. **(1) server bootstrap `0038` ✅** (`e95c40e`). **(2) Android device-debug
build IN FLIGHT (`0039-android-device-debug-build`)** — base URLs → BuildConfig (`-P`-overridable;
API corrected `:54321`→`:3000` Fastify, auth stays Supabase `:54321`) + debug-only cleartext NSC;
impl's `-P` assembleDebug = the device APK. Vision ALIGNED (repo-verified split) + guardian PASS.
**Transport decision:** owner chose **cleartext-on-LAN for the local test**; **release stays
HTTPS-only; prod-HTTPS is a tracked requirement.** Watcher armed for `0039`. **(3) LAN stack run + first full-stack attempt DONE:** Supabase+Fastify up on the LAN, 5 profiles
seeded, owner opened ufw, Kong restarted (post-reset 502). Real device agent run
(`reviews/device-test-report-2026-06-02-fullstack.md`) **found a REAL BUG: app manifest missing
`android.permission.INTERNET`** → all sockets `EPERM` on the first call; backend/LAN proven healthy
from the phone. Steps 1+12 PASS, 3–11 blocked downstream. **Fix `0040-android-internet-permission`
IN FLIGHT** (one-line: add INTERNET to `app/src/main/AndroidManifest.xml` + rebuild device APK;
vision N/A bugfix, guardian PASS). Watcher armed for `0040`. **Then:** reinstall + re-run device
agent Steps 2–12; teardown (re-close ufw, stop Fastify `bhdrygzdg`). Backend still UP. PlantApp HEAD
`a3cb50e`. **Tripwire:** Drive mounted before any
`gradlew`/npm/npx. **Gate note:** `:domain` → `:domain:test`. **Structural debt:** sign-in in `:feature-inventory` → `:feature-auth`
later. **Tripwire:** Drive mounted before any `gradlew`/npm/npx. **Gate note:** `:domain` →
`:domain:test`.

## What this session did
- Verified Option A on `origin/master` independently (`git show`/`diff`): one file,
  comment-only, fixture + assertions intact.
- Grounded the Option B test spec against the real schemas + existing fixtures.
- Asked the owner about `npm install`; they chose **"Install + commit lockfile."**
  Recorded as PD-04.
- Rewrote `prompts/next-implementation-prompt.md` as the **two-commit** Option B
  (install+lockfile, then tests-run-red). Confirmed `node_modules/` is git-ignored
  so the lockfile commit stays clean.
- Updated `state/current-state.md`, `state/known-history.md`,
  `github-checks/latest-github-check.md`, `reviews/latest-repo-review.md`,
  `decisions/planner-decisions.md` (PD-03 planner remote, PD-04 install).
- Committed + pushed the planner repo to its new remote
  (`git@github.com:iFernandez96/PlantAppPlanner.git`).
- **Hardening pass:** fixed the Option B test to load the engine via a dynamic
  import (a static named import of the missing export would abort the suite at
  collection rather than failing per-test). Commit `chore: tighten Option B prompt
  for predictable red failure`.

## What the OWNER does next
Paste the two-commit Option B prompt from `prompts/next-implementation-prompt.md`
into the implementation Claude. It will: `npm install` in backend/ → run `npm test`
(baseline) → commit lockfile → add the care-engine test file → run `npm test` →
confirm the 8 tests fail red → commit → push (two commits total).

## What the NEXT planner session does
1. Re-read `state/current-state.md` + this handoff; `git -C PlantApp fetch origin`
   and compare HEAD vs `origin/master` (expect `b2836ca` until Option B lands; then
   two new commits: a `chore(backend)` lockfile commit + a `test(care-engine)` commit).
2. Verify red-first intact: engine still `export {};`; the 8 tests present and (per
   the impl report) failing with `is not a function`.
3. **Record the first-ever test-run result** — did the pre-existing schema tests
   pass? Note it in `state/current-state.md` (this was their first real execution).
4. Write the **green** prompt: `feat(care-engine): implement computeInitialWaterTask`
   (sha256 + canonical-JSON of `sourceInputs`, D-10 formula, schema-valid `CareTask`).
   The test file needs no change for green — its dynamic import resolves to the real
   function once exported.

## Open questions for the owner
- None blocking. (Install decision resolved → PD-04.) Future gate: builds/migrations
  still need separate approval when a slice needs them.

## Tripwires / do-not-assume
- Re-verify SHAs every session; don't assume `b2836ca` is still HEAD.
- This is vitest's first run in PlantApp — pre-existing schema tests have never
  actually executed. Treat any pre-existing failure as a real finding, not noise.
- Keep `care-engine/index.ts` a placeholder during Option B; implementing it is the
  separate green commit.
- No CI on GitHub; PlantApp commits go straight to `master`.
- Planner repo: commit **and push** to its remote (PD-03).

## Standing policy update (2026-06-01) — PD-05
- **New policy:** every future feature prompt must include a **standalone
  verification** section (independently runnable, objective pass/fail). Encoded in
  CLAUDE.md, `.claude/rules/prompt-contract.md`, the `implementation-prompt-writer`
  skill, and the `prompt-writer` / `slice-planner` agents.
- The next implementation prompt should **still be Option B** — it now carries a
  Standalone verification section, so it satisfies the gate. Only revise it if that
  section were missing.

## File exchange protocol added (2026-06-01) — PD-06
- Planner ↔ implementation handoffs now go through `exchange/` (immutable
  `READY.json` message dirs; `scripts/exchange-*.sh`; spec `exchange/README.md`).
- Current Option B is published at `exchange/planner-outbox/0001-option-b/`.
- **Owner action:** either paste `prompts/next-implementation-prompt.md` as before,
  or point the implementation Claude at the exchange (it runs
  `scripts/exchange-read-latest-prompt.sh`).
- Implementation returns results via
  `scripts/exchange-create-implementation-report.sh <id> <src-dir>` (add `--blocked`
  with a `BLOCKED.md` if it needs an owner decision).

## Autonomous in-session ping-pong (2026-06-01)
- Planner (this session) and the implementation Claude run as two **live** sessions,
  each with a `run_in_background` watcher that wakes it when the other publishes to
  the exchange. **Not** a detached daemon; both windows must stay open.
- Impl side launches with `--dangerously-skip-permissions`; bootstrap prompt:
  `prompts/impl-claude-autonomy-bootstrap.md`. Planner stays on normal permissions.
- First handoff in flight: `0001-option-b` (two-commit Option B; the npm-cache
  blocker was resolved by mounting the external Drive). Planner posts a short update
  to the owner after each round and only stops to ask on a real blocker.
- **Round 1 done (2026-06-02):** impl Claude completed `0001-option-b` (commits
  `ce141da` + `1d4e888`, pushed; 8 care-engine tests red, 39 schema green). Planner
  verified against real git and published the green handoff `0002-care-engine-green`
  (implement `computeInitialWaterTask`). Watcher re-armed for the `0002` report.
- **Round 2 done (2026-06-02):** impl Claude completed `0002-care-engine-green`
  (`25f1dbb`, `npm test` 47/47; test file unchanged). care-engine #7–#14 complete.
  Planner **paused the loop** to ask the owner the next milestone — A: Postgres-gated
  API tests #15–#20 (needs approval); B: approval-free seed `PlantProfile` catalog +
  schema-valid-CareTask test (recommended); C: Android UI #21–#24; D: pause.
- **Owner chose "B, then A" (2026-06-02).** Round 3: published `0003-seed-catalog`
  (red→green seed catalog + schema-valid-CareTask test) and re-armed the watcher.
  **A is pre-approved** (local Postgres for API tests #15–#20) — planner proceeds to it
  after B without re-asking, stopping only if the DB environment isn't available.
- **Round 3 done (2026-06-02):** B landed (`7a4e19b` red + `b32e7a4` green; `npm test`
  50/50; planner-verified, only 2 new files). Toward A the planner found the **DB env
  not ready** and paused; owner chose **(i) Supabase CLI**, framework = Fastify (A3).
- **Round 4 (A1) done (2026-06-02):** `0004-db-garden-spaces` → `661a135`/`8d1905a`/
  `e92bc0f`. Supabase local up; `garden_spaces` + RLS (migration 0002); 3 integration
  tests green; unit 50/50; planner-verified. Harness recorded (memory
  `plantapp-local-db-harness`; note the `npm_config_cache=/tmp/plantapp-npx-cache` quirk).
- **Round 5 (A2) done (2026-06-02):** `0005-db-core-tables` → `e2c3795` (red) + `670ebaf`
  (green): 4 tables + RLS + seeded `plant_profiles`; 12 integration tests green; unit
  50/50; planner-verified.
- **Round 6 (A3a) done (2026-06-02):** `0006-api-add-plant` → `118660a`/`3b263d1`/`1cd2eac`:
  Fastify + ADRs 0005/0006 + add-plant→CareTask API + auth(RLS) + #15–#18; integration
  17/17, unit 50/50; planner-verified; vision-checked ALIGNED.
- **Round 7 (A3b) in flight:** published `0007-api-read-delete` (`GET /plants`,
  `GET /plants/:id`, `DELETE /plants/:id` + #19 RLS isolation + #20 cascade), vision-checked
  ALIGNED, watcher armed. Closes Slice 1 backend DOD (#1–#20).
- **Round 7 (A3b) done (2026-06-02):** `0007-api-read-delete` → `cfb3751`/`8f588af`:
  list/get/delete + #19 RLS isolation + #20 cascade; **Slice 1 backend DOD #1–#20
  complete** (test:int 20/20, unit 50/50); planner-verified (app.ts additive, protected
  paths untouched).
- **Owner chose "b, then a" (2026-06-02).** Round 8 (b) done: `603869e` — lint passes
  (16→0) via `tsconfig.eslint.json`; build tsconfig untouched; unit 50/50; verified.
- **Round 9 (a1) done (2026-06-02):** `0009-android-wrapper-build` → `d0ec682`: Gradle
  wrapper committed; `:app:assembleDebug` BUILD SUCCESSFUL (compileSdk 35; android-35
  installed); no feature code/forbidden deps; backend untouched. Build with
  `GRADLE_USER_HOME=/tmp/plantapp-gradle-home` (`~/.gradle` on the Drive).
- **PAUSED before a2 — API-contract decision (owner):** API responses don't conform to the
  camelCase shared-schemas — GET endpoints return snake_case DB rows; POST `task` is
  camelCase but `plant` snake_case (same CareTask, two shapes). Options: **(A, rec)** conform
  responses to camelCase shared-schemas (+ Ajv response-validation tests); (B) snake_case
  wire contract; (C) proceed + map in Android (not rec). The vision-alignment gate surfaced
  this. No prompt pending / no watcher armed until the owner picks.
- **Owner chose A (2026-06-02).** Round 10 (A) done: `0dca7f1`/`678a488` — `src/mappers.ts`
  conforms all responses to camelCase shared-schemas; Ajv integration tests lock it
  (21/21, unit 50/50, lint+typecheck clean); verified, protected paths untouched.
- **Round 11 (a2) done (2026-06-02):** `0011-android-network` → `e69f6a0`/`f6c8155`:
  `:network` DTOs + Retrofit + JVM tests 10/10 (networknt schema-valid); `:app:assembleDebug`
  OK; no forbidden deps; verified.
- **Round 12 (a3a) done (2026-06-02):** `0012-android-domain-data` → `0f8c596`/`a99cb75`:
  `:domain` models + `:data` repo over `:network` + DataStore + Hilt; `:domain` 2/2,
  `:data` 5/5; `:app:assembleDebug` OK; Room removed/deferred; verified.
- **Round 13 (a3b) in flight — CLOSES Slice 1:** published `0013-android-inventory-ui` —
  Compose add/list/detail screens + Hilt VMs + nav + UI tests #21–#24 (Robolectric).
  Vision-check ALIGNED (minor: plan's optional `nickname`/`placement` form fields not named
  — verify on landing; tiny follow-up only if dropped & wanted). Watcher armed.
- **After a3b:** Slice 1 DOD #1–#24 complete → STOP, write the one-page Slice 1 retro, and
  ask the owner the next direction (do NOT auto-start Slice 2).
- **Round 13 (a3b) done (2026-06-02) — SLICE 1 ENGINEERING-COMPLETE:** `0013-android-inventory-ui`
  → `da0eee0`/`a568a4d`: Compose add/list/detail + nav + UI tests #21–#24 (Robolectric 4/4);
  `:app:assembleDebug` OK; protected paths untouched. **Loop paused.** Retro written
  (`reviews/slice-1-retro.md`).
- **Owner decision pending (next session):** (1) device-acceptance run of the 5 real plants
  (needs API reachable — local Supabase base URL or a deploy); (2) UX follow-ups (real
  selectors, optional `nickname`/`placement`, sign-in screen); (3) Slice 2 advisories;
  (4) CI to enforce the suites on GitHub. No prompt pending / no watcher armed until chosen.
- **Next planner session:** re-fetch (expect `a568a4d`), read the retro, then act on the
  owner's choice. Resume the ping-pong only when there's a new approved handoff.
- **Owner chose option 3 — Slice 2 (advisories), 2026-06-02.** S2.0 in flight: published
  `0014-slice2-foundation` (slice-02 plan doc + `advisory.schema.json` + red→green schema
  test), vision-checked ALIGNED, watcher armed. Decomposition: S2.0 schema → S2.1
  `computeAdvisories` engine (red-first) → S2.2 `GET /plants/:id/advisories` API → S2.3
  Android display. BDD = `features/container-health.feature` `@slice-2`. Slice 1 device-
  acceptance run still recommended (not blocking).
- **S2.0 done (2026-06-02):** `5e77801`/`06f581d` — slice-02 plan + `advisory.schema.json` +
  schema test; `npm test` 61/61; verified. **S2.1 in flight:** published `0015-advisory-engine`
  (deterministic `computeAdvisories`, red→green; 3 rules + invariant; schema-validated),
  vision ALIGNED. Watcher armed. **Tracked issue:** `npm run validate-schemas` red for all 8
  schemas (pre-existing: ajv-cli missing `ajv-formats` + diagnosis-result strictTypes) — tiny
  hygiene handoff candidate; not blocking. **S2.2 to-do:** fix the stale slice-02 plan line
  (seed enrichment is S2.2, not S2.1).
- **S2.1 done (2026-06-02):** `1077764`/`4f3d76a` — deterministic `computeAdvisories`
  (3 rules + invariant), `npm test` 67/67, verified. **S2.2 in flight:** published
  `0016-advisories-api` (`GET /plants/:id/advisories` + migration 0004 ideal-range + seed
  enrichment + plan-doc fix + integration tests mapping the 5 `@slice-2` scenarios), vision
  ALIGNED. Watcher armed. **S2.3 next:** Android advisory display + UI test (closes Slice 2).
- **S2.2 done (2026-06-02):** `623c91f`/`8d3e813` — `GET /plants/:id/advisories` + migration
  0004 ideal-range + seed; integration 25/25, unit 67/67; all 5 `@slice-2` scenarios green;
  verified. **S2.3 in flight (closes Slice 2):** published `0017-android-advisories` (Android
  `:network` DTO + `:data` repo + `:feature-inventory` detail advisory display + UI test;
  informational-only, no advisory→task), vision ALIGNED. Watcher armed.
- **Tracked issue:** `npm run lint` fails (pre-existing ESLint↔tsconfig project mismatch;
  `tests/**` not in the TS project). Not gated; needs a small config handoff if wanted.
- **New gate:** every published prompt is vision-checked vs `../PlantApp/ChatHistory.md`
  (`reviews/vision-checks.md`); all handoffs since `0006` recorded ALIGNED (or N/A for
  tooling chores).

## SLICE 2 COMPLETE (2026-06-02) — loop PAUSED for owner
- **S2.3 done:** `63440be`/`c4e4396` — Android advisory display (severity-styled,
  informational-only, no advisory→task); module tests + UI green; `:app:assembleDebug` OK;
  backend untouched. **Slice 2 (advisories) complete end-to-end** (engine + API + Android),
  all 5 `@slice-2` scenarios exercised. Retro: `reviews/slice-2-retro.md`.
- **HEAD `c4e4396`.** Backend unit 67/67 + integration 25/25; Android green.
- **Owner decision pending — no prompt pending, no watcher armed.** Backlog: (1)
  `validate-schemas` tooling fix (pre-existing broken gate) · (2) on-device acceptance run
  (Slice 1+2) · (3) UX follow-ups (real selectors / sign-in / advisory→task flow) · (4)
  Slice 3 (deterministic watering reminders + notifications).
- **Next planner session:** re-fetch (expect `c4e4396`), read `reviews/slice-2-retro.md` +
  `reviews/slice-1-retro.md`, act on the owner's choice; resume the ping-pong on a new approved handoff.

## "Do all" backlog (2026-06-02) — loop RUNNING
Owner said **"do all"**. Order: **(1) validate-schemas fix [`0018` in flight] → (3) UX
follow-ups (3a `GET /plant-profiles|/garden-spaces|/containers` list endpoints → 3b Android
form selectors → 3c Supabase sign-in → 3d advisory→accept→CareTask flow) → (2) automated
emulator e2e smoke (human device-acceptance stays with the owner) → (4) Slice 3 (WorkManager
local first; STOP for Firebase/FCM creds + `google-services.json`).** Vision-check each
product-surface step; pause only on a real decision (notably FCM credentials).
