# PlantApp — Current State

> Single source of truth. Refresh from real git + GitHub each session; re-verify SHAs.

| Field | Value |
|---|---|
| **Snapshot** | 2026-06-02 — **Slice 1 backend DOD complete (#1–#20)**; loop paused for owner decision |
| **PlantApp path** | `/home/israel/Documents/Development/PlantApp` |
| **Branch / default** | `master` |
| **Local HEAD / origin/master** | `d0ec682b1d3e086ea8d7d35d61a404a74dd45f21` (`d0ec682`) — in sync, clean |

## 🎉 Slice 1 backend is DOD-complete (#1–#20), all green
- Schema validation #1–#6 · deterministic care-engine #7–#14 · seed catalog · DB schema +
  RLS (`garden_spaces`, `plant_profiles` seeded, `containers`, `plant_instances`,
  `care_tasks`) · Fastify add-plant→CareTask API + auth (request-scoped client → RLS) ·
  add-plant + validation #15–#18 · RLS isolation #19 · delete cascade #20.
- `npm test` **50/50**, `npm run test:int` **20/20**, typecheck clean @ `8f588af`.
- Exchange handoffs `0001`–`0007` all ✓ (each since `0006` vision-checked ALIGNED).

## Next: "b, then a" — a1 done, PAUSED on an API-contract decision
- **b** ✓ (`603869e`) `npm run lint` passes (16→0).
- **a1** ✓ (`d0ec682`) Gradle wrapper committed + `:app:assembleDebug` BUILD SUCCESSFUL
  (compileSdk 35; `platforms;android-35` installed). Toolchain proven. Build with
  `GRADLE_USER_HOME=/tmp/plantapp-gradle-home` (`~/.gradle` is on the slow external Drive).
- **⚠️ PAUSED before a2 — API-contract decision (owner).** API responses don't conform to
  the camelCase shared-schemas: `GET /plants[/:id][/tasks]` return raw **snake_case** DB
  rows; `POST /plants` returns `task` camelCase (engine output) but `plant` snake_case — the
  same CareTask has two shapes. Shared-schemas (camelCase) are the stated cross-boundary
  contract (D-06: Android validates DTOs against them). Building Android DTOs now bakes in
  the inconsistency. Options:
  - **(A, recommended)** Conform all API responses to the camelCase shared-schemas (snake→
    camel mapping + integration tests validating responses against `shared-schemas/*` via
    Ajv). Then a2 builds on a clean contract.
  - **(B)** Make snake_case the wire contract (also make `POST` `task` snake_case for
    consistency; treat shared-schemas as DB-mirrors / add a separate wire schema).
  - **(C)** Proceed to a2 against the current API, mapping per-endpoint in Android (not
    recommended — bakes in the inconsistency).
  No prompt pending / no watcher armed until the owner chooses.
- **a2 (after decision):** `:network` Retrofit DTOs + Compose screens (`:feature-inventory`:
  add/list/detail) + UI tests #21–#24 (Robolectric). Vision-checked for real.

Original options (for reference):
- **(a) Android UI slice #21–#24** — completes Slice 1's "owner adds plants on a device"
  DOD. Env (read-only check): Java 21 ✓, `ANDROID_HOME=~/Android/Sdk` ✓, `adb` ✓, but the
  **Gradle wrapper is not committed** (and no Kotlin source). So step 1 would be
  generate the wrapper + build the skeleton, then Compose modules + UI tests. Feasible
  but a real lift; needs an emulator or Robolectric for Compose tests.
- **(b) Lint-config cleanup** — small handoff: fix the pre-existing ESLint↔`tsconfig`
  project mismatch so `npm run lint`/`just lint-backend` pass (`tests/**` not in the TS
  project). Pure hygiene; no behavior change.
- **(c) Close Slice 1 at the backend boundary** — declare the backend slice done; pause.

No prompt pending, no watcher armed until the owner chooses.

## Known issue (tracked)
`npm run lint` fails (pre-existing ESLint↔tsconfig project mismatch; `tests/**` + config
files not in the TS project; zero `src/**` errors). Not in the test gate. = option (b).

## Workflow
Autonomous in-session ping-pong (planner ↔ impl; `run_in_background` watchers; impl
`--dangerously-skip-permissions`). Each published prompt vision-checked vs
`../PlantApp/ChatHistory.md` (`reviews/vision-checks.md`). DB harness: memory
`plantapp-local-db-harness`. Planner stops only on a real blocker / owner decision (now).
