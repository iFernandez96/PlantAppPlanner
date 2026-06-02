# DONE — handoff 0034-slice3-opener (Slice 3 opener, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** Slice 3 plan doc (scope + STOP gates + D-13) and the pure, deterministic
`computeReminders` reminder policy in `:domain`. No Android/WorkManager/notification/permission/dep
code — just a doc + a pure function + its test. `:domain:test` green. Final `origin/master` =
`79944a53e76bf85a91b085fc78f030da41053e9f`.

## Baseline + unblock
- HEAD at start = `da020e3…` == origin/master; clean. SDK resolves.

## Plan doc — `docs/slice-03-reminders-plan.md`
- **Goal:** local, deterministic watering reminders — fire a device notification at a pending
  `CareTask.dueAt`. `dueAt` comes from the backend engine (D-09); Slice 3 only schedules + delivers
  locally.
- **Scope posture:** Slice 3 relaxes the slice-scoped D-11/D-12 "no notifications" exclusion; this
  is where local reminders land. Push/FCM still excluded here.
- **In scope:** (a) `computeReminders` [this handoff]; (b) WorkManager local notification path
  (Worker + scheduler; adds WorkManager + `POST_NOTIFICATIONS` + a channel); (c) app-open
  (re)scheduling.
- **Out of scope / STOP gates:** Firebase/FCM push deferred — **STOP and ask the owner** for a
  Firebase project + `google-services.json` before push. No weather/feeding reminders, no
  background location.
- **Red-first sequence:** computeReminders → WorkManager Worker+scheduler (new dep + permission,
  planner-grounded) → app-open wiring; each red-first + standalone-verified.
- **D-13 (ratified, recorded explicitly):** local reminder *scheduling/delivery* is an on-device
  concern (WorkManager + local notification); care *computation* (`dueAt`) **stays backend** (D-09
  preserved); server-triggered FCM push is a later, owner-gated path.
- **Past-trigger note:** a non-zero lead (or due-soon/just-past task) can make `triggerAtUtc` <
  `now`; intentional — the WorkManager step fires a past trigger immediately, not a bug.

## The policy — `android/domain/.../reminder/ReminderPolicy.kt`
Pure Kotlin (no Android imports), `java.time`:
- `data class ReminderSpec(taskId, kind, dueAt, triggerAtUtc)`.
- `computeReminders(tasks, now, leadTime = ZERO, staleAfter = ofDays(7)): List<ReminderSpec>` —
  keeps tasks with `status == "pending"` and `dueAt >= now - staleAfter`; parses `dueAt` with
  `Instant.parse` (unparseable → skipped, defensive); `triggerAtUtc = (dueAt - leadTime)`.toString()
  (canonical ISO). No `Instant.now()` / no randomness — deterministic; output order = input order.

## Tests — `android/domain/.../ReminderPolicyTest.kt` (new, 7)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test
BUILD SUCCESSFUL in 7s
```
- pending future task → one spec, trigger == due instant (zero lead), taskId/kind echoed.
- non-pending (done/skipped/dismissed) → excluded.
- stale boundary: due 8 days before `now` excluded, ~6.98 days before included.
- 1h leadTime → triggerAtUtc == dueAt − 1h (`2026-06-03T06:00:00Z`).
- past trigger (due-soon + 1h lead) → still emitted, triggerAtUtc before `now`.
- unparseable `dueAt` → skipped.
- determinism: two calls equal; output order == input order (not sorted).
- `:domain` count **2 → 9** (ReminderPolicyTest 7 + InventoryModelsTest 2). All green.

## Implementation note
The zero-lead test asserts the trigger *instant* equals the due instant rather than raw-string
equality: `Instant.toString()` emits canonical ISO (`…07:00:00Z`), dropping the backend's `.000`
millis, so `triggerAtUtc` and `dueAt` are the same instant but not byte-identical strings. `dueAt`
is still echoed verbatim in the spec; only the computed `triggerAtUtc` is canonicalized.

## Commit
- `79944a5` — feat(domain): Slice 3 plan + deterministic computeReminders reminder policy
- `git show --stat HEAD`: 3 files, +222 — only `docs/slice-03-reminders-plan.md` +
  `android/domain/**` (ReminderPolicy.kt + ReminderPolicyTest.kt). `local.properties` NOT committed
  (grep 0).

## Compliance
- No Android dependency/import in `ReminderPolicy.kt` (`:domain` stays pure-Kotlin). No WorkManager,
  no notification code, no manifest/permission change, no new dependency. No
  backend/schema/`:network`/`:data`/`:app` change. No `Instant.now()` inside the function. No
  AI/photos/GPS. SDK/Drive untouched.

Final `origin/master` SHA: `79944a53e76bf85a91b085fc78f030da41053e9f`

## Next (per planner follow-up)
WorkManager local-notification handoff: a Worker posting a reminder + a scheduler enqueuing from
`computeReminders` (adds WorkManager + `POST_NOTIFICATIONS` + a channel — planner will ground the
dep/permission against the manifest). Then app-open scheduling. **Then STOP for owner Firebase/FCM
setup** before any push.
