# Next Implementation Prompt — Slice 3 opener: plan doc + deterministic `computeReminders`

**Backlog item (4) — Slice 3: deterministic watering reminders.** This opener does two things:
(1) a **Slice 3 plan doc** fixing scope + the red-first sequence + the explicit FCM STOP gate, and
(2) the **deterministic, pure reminder policy** (`computeReminders`) — the engine-style core that
decides *which pending tasks get a local reminder and when* — before any Android/WorkManager/
notification code. Local-only, dep-free, JVM-testable.

**Scope posture note:** Slice 3 introduces **local notifications/reminders**, which Slices 1–2
deliberately excluded (D-11/D-12: no notification permission yet). That exclusion was slice-scoped;
Slice 3 is where reminders land. **Push/FCM is still out of scope here** — the WorkManager *local*
path comes in later handoffs, and any Firebase/FCM work will **STOP for owner setup**. This handoff
adds **no** Android permission, **no** new dependency, **no** notification code — only a doc + a
pure function + its test.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`da020e3abdc3bd4ada2d2ec5c4ec39a8f1a53e58` == `origin/master`, clean. `:domain` is pure-Kotlin
(JVM; module test task `:domain:test`) and holds `CareTask(id, kind, dueAt, priority, rationale,
engineVersion, inputsHash, status)` — `dueAt` is an ISO-8601 UTC string; `status ∈ pending|done|
skipped|dismissed`. `minSdk = 26`, so `java.time` is available. Prior slice plans live in
`docs/slice-01-*.md` / `docs/slice-02-*.md`.

Single logical change (Slice 3 plan + the pure reminder policy) → one commit. Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the Slice 3
plan doc + a pure `computeReminders` policy in `:domain`. Red-first: write the test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect da020e3abdc3bd4ada2d2ec5c4ec39a8f1a53e58 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`docs/slice-03-reminders-plan.md`** (new) — concise plan:
   - **Goal:** local, deterministic watering **reminders** — surface a device notification at a
     pending `CareTask`'s `dueAt`. The care decision (`dueAt`) is already produced by the backend
     care engine (D-09: Android computes no care logic); Slice 3 only decides *reminder scheduling*
     and *delivers* the local notification.
   - **In scope:** (a) deterministic `computeReminders` policy [this handoff]; (b) a WorkManager
     **local** notification path (a Worker that posts a notification + a scheduler that enqueues from
     `computeReminders`) — adds WorkManager + `POST_NOTIFICATIONS` (Android 13+); (c) wiring to
     (re)schedule on app open / after task changes.
   - **Out of scope / STOP gates:** **Firebase/FCM push is deferred** — when reminders need push,
     STOP and ask the owner for a Firebase project + `google-services.json`. No weather/feeding
     reminders (later slices). No background location.
   - **Red-first sequence:** `computeReminders` (pure, `:domain`) → WorkManager Worker +
     scheduler (`:data`/`:feature`, new deps + permission) → app-open scheduling. Each step
     red-first + standalone-verified.
   - Note that Slice 3 intentionally relaxes the Slice-1/2 "no notifications" posture (D-11/D-12).
   - **Ratified decision (record explicitly in the doc, e.g. "D-13"):** local reminder
     **scheduling/delivery is an on-device concern** (WorkManager + local notification), while care
     **computation** (the `dueAt` schedule) **stays backend** (D-09 preserved); **server-triggered
     FCM push remains a later, owner-gated path**. This split is the owner-approved "WorkManager
     local path first, then STOP for Firebase/FCM" directive — state it so the boundary is durable,
     not implicit.
   - **Past-trigger note:** with a non-zero `leadTime` (or a due-soon/just-past task inside the
     stale window) `triggerAtUtc` may be **before** `now`; that is intentional — the later
     WorkManager step treats a past trigger as "fire immediately" (legitimate), **not** a bug.
2. **`android/domain/src/main/kotlin/dev/plantapp/domain/reminder/ReminderPolicy.kt`** (new) — pure
   Kotlin (no Android imports), using `java.time`:
   ```kotlin
   data class ReminderSpec(
       val taskId: String,
       val kind: String,
       val dueAt: String,        // ISO-8601 UTC, echoed from the task
       val triggerAtUtc: String, // when the local reminder should fire (ISO-8601 UTC)
   )
   /**
    * Pure, deterministic reminder-scheduling policy (NOT care computation — dueAt comes from the
    * backend engine; this only decides local reminder timing). Given the caller's CareTasks and the
    * current instant, returns one ReminderSpec per task that:
    *  - has status == "pending", and
    *  - is not more than [staleAfter] past due (so we don't remind about long-abandoned tasks).
    * triggerAtUtc = dueAt - [leadTime] (default zero → remind at due time). Deterministic: same
    * inputs → identical output (no Instant.now() inside; [now] is passed in). Output order follows
    * input order.
    */
   fun computeReminders(
       tasks: List<CareTask>,
       now: java.time.Instant,
       leadTime: java.time.Duration = java.time.Duration.ZERO,
       staleAfter: java.time.Duration = java.time.Duration.ofDays(7),
   ): List<ReminderSpec>
   ```
   Implementation: filter `status == "pending"`; parse `dueAt` with `Instant.parse`; **skip** tasks
   whose `dueAt` is before `now.minus(staleAfter)`; `triggerAt = Instant.parse(dueAt).minus(leadTime)`;
   emit `ReminderSpec(task.id, task.kind, task.dueAt, triggerAt.toString())`. No `Instant.now()` / no
   randomness inside (determinism). Tasks with an unparseable `dueAt` are skipped (defensive).

### Tests — `android/domain/src/test/kotlin/dev/plantapp/domain/ReminderPolicyTest.kt` (new)
Plain JUnit (`:domain` uses `kotlin-test-junit`):
- pending task due in the future → one spec, `triggerAtUtc == dueAt` (zero lead), `taskId`/`kind`
  echoed.
- non-pending tasks (`done`/`skipped`/`dismissed`) → excluded.
- a task due before `now - staleAfter` → excluded; one due just inside the window → included.
- non-zero `leadTime` (e.g. 1 hour) → `triggerAtUtc == dueAt - 1h`.
- **past trigger allowed**: a due-soon pending task where `dueAt - leadTime` is **before** `now` →
  still emitted (its `triggerAtUtc` is in the past; the WorkManager step will fire it immediately).
- **determinism**: two calls with identical args are equal; output order matches input order.

### Forbidden
- No Android dependency/import in `ReminderPolicy.kt` (`:domain` stays pure-Kotlin). No WorkManager,
  no notification code, no manifest/permission change, no new dependency — those are later Slice 3
  handoffs. No backend/schema/`:network`/`:data`/`:app` change. No `Instant.now()` inside the
  function. No AI/photos/GPS. Don't mount/repoint the SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test
```
Red→green: the new `ReminderPolicyTest` fails to compile/pass before `ReminderPolicy.kt` exists;
after, `:domain:test` passes (new tests green; `InventoryModelsTest` still green). Report the count
+ new test names. (Doc file needs no test — verify by diff.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add docs/slice-03-reminders-plan.md android/domain/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(domain): Slice 3 plan + deterministic computeReminders reminder policy"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The plan doc's scope + STOP gates; the `ReminderSpec`/`computeReminders` policy (filters,
   lead/stale, determinism).
2. `:domain:test` count before→after + new test names (all green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only the doc +
   `android/domain/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only the doc + `:domain`; pure/deterministic; `:domain:test` green). Then the
**WorkManager local-notification handoff**: a Worker that posts a reminder notification + a scheduler
that enqueues from `computeReminders` — this adds WorkManager + the `POST_NOTIFICATIONS` permission
(Android 13+) and a notification channel; **the planner will surface the WorkManager-dep +
notification-permission as an explicit decision/ground it against the manifest first**. Then
app-open scheduling wiring. **Then STOP and ask the owner for Firebase/FCM setup** before any push.
Vision-check each step (esp. the D-09 boundary: reminder *scheduling/delivery* on device is allowed;
care *computation* stays backend).
