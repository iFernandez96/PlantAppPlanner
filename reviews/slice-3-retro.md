# Slice 3 Retro — Watering Reminders (local) + first on-device full-stack run

**Date:** 2026-06-02 · **Outcome:** local reminder path shipped **and verified on a real device**;
full product loop proven end-to-end on-device; FCM deferred (owner-gated).

## What shipped (handoffs `0034`–`0040`)
- **`0034`** deterministic `computeReminders` (`:domain`, pure) + Slice 3 plan doc (D-13: local
  scheduling/delivery on-device, care computation stays backend; FCM = later owner-gated).
- **`0035`** WorkManager local path — `ReminderScheduler` + `ReminderWorker` (inputData-driven,
  permission-guarded) + `POST_NOTIFICATIONS` + channel.
- **`0036`** `ReminderSync` (app-open: pending tasks → computeReminders → schedule) + trigger.
- **`0037`** runtime `POST_NOTIFICATIONS` request.
- **`0038`** backend HTTP server bootstrap (`server.ts` + `start`) — the app had only ever run via
  `app.inject()`; no `listen()` existed.
- **`0039`** device-debug build: base URLs → `BuildConfig` (`-P`-overridable), **API base corrected
  `:54321`→Fastify `:3000`** (latent misconfig), debug-only cleartext NSC.
- **`0040`** declared `android.permission.INTERNET` (the real on-device bug).

## On-device result (real Samsung S24 Ultra, Android 16) — 🎉 full-stack PASS
Email-OTP sign-in (code via Mailpit) → verify → plant list → add-plant via catalog dropdown +
select-or-create → water CareTask + container-size advisory → **Accept** → repot task → **reminder
notification posted** ("Plant care reminder / A 'repot' task is due"). All HTTP 200/201, no crashes.
Reports: `reviews/device-test-report-2026-06-02-fullstack.md` (+ `-pass.md`).

## What went well
- Deterministic-core discipline held: reminder *timing* is a pure function; care *scheduling* stays
  backend (D-09/D-13). Vision gate + no-mutation guardian ran on every handoff (zero drift).
- The on-device run **earned its keep**: it caught the missing `INTERNET` permission and the
  `:54321`→`:3000` API-base misconfig — **both invisible to all 200+ unit/integration/Robolectric
  tests** (none open a real socket / a real server). Confirms the "standalone verification + real
  run" doctrine.
- Atomic exchange + verify-vs-real-git caught a planner slip (an unpublished prompt claimed
  "published") — surfaced by the owner's "status?" and fixed immediately.

## What to improve / carry forward
- **Tests don't exercise real networking or a running server.** Add at least one real-HTTP smoke
  (or a connected/instrumented test) so socket/permission/base-URL regressions can't hide again.
- **Reminders schedule only on app-open/list-load** — a user who adds a plant and never returns to
  the list won't get a reminder until next open. MVP-acceptable; candidate: also sync after
  add-plant/accept.
- **Backend was never deployable** until `0038`; base URLs were emulator placeholders. Treat
  "runs as a real server, reachable, with correct base URLs" as part of done for client features.
- **HTTPS for prod** is a tracked requirement (release builds already block cleartext; local test
  used debug cleartext on the LAN).

## Open / deferred
- **FCM / server-triggered push** — owner-gated (needs a Firebase project + `google-services.json`
  + backend sender + token registration). Not started.
- **�high priority (new, 2026-06-02): beginner-first UX overhaul** — owner: the add-plant UX is
  "absolutely atrocious"; the MVP must be usable by an elderly/novice non-gardener. See
  `[[beginner-first-ux]]` memory + the UX plan below/next. This is now the top product priority,
  ahead of FCM.
