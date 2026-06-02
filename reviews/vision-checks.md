# Vision-alignment checks

Standing workflow (owner request, 2026-06-02): after publishing each implementation
prompt, run the `vision-alignment-reviewer` to sanity-check it against the product
vision — `../PlantApp/ChatHistory.md` (the owner's original brief) — and record the
verdict here. Revise or escalate to the owner on drift before the implementation
proceeds. Encoded in `CLAUDE.md` (step 6), `.claude/rules/prompt-contract.md`, and the
`implementation-prompt-writer` skill.

| Handoff | Date | Verdict | Note |
|---|---|---|---|
| `0006-api-add-plant` | 2026-06-02 | **ALIGNED** (ship as-is) | All 8 principles ok: GardenSpace+Container+PlantInstance first-class; deterministic engine **imported, not reimplemented**; data-driven profile loaded at runtime; backend-only, no keys; no premature AI/photos/space-optimizer; Fastify recorded as a new ADR (D-01 left the web framework unpinned). No scope drift. |
| `0007-api-read-delete` | 2026-06-02 | **ALIGNED** (ship as-is) | #19 RLS isolation + #20 cascade delete — both explicit Slice 1 plan items (impl-plan #19/#20); `GET/DELETE /plants` in plan backend scope; RLS test *strengthens* privacy; care-engine/migrations forbidden; no AI/photos/space-optimizer pulled in. No drift. |
| `0008-lint-config` | 2026-06-02 | **N/A (tooling chore)** | ESLint↔tsconfig config fix only — no product surface, no entity/feature/scope change, touches no `src/`/`care-engine/`/schema/migration logic. Vision-alignment has no dimension to assess; gate recorded N/A by the planner rather than spinning a subagent. |
| `0009-android-wrapper-build` | 2026-06-02 | **N/A (tooling chore)** | Generate the Gradle wrapper + assemble the existing 6-module skeleton; no Compose/feature code, no new deps (uses the committed `libs.versions.toml`, which already excludes CameraX/FCM/AI), no product surface. The real Android vision-check lands on a2 (Compose screens/tests). |
| `0010-api-contract-conformance` | 2026-06-02 | **ALIGNED** (planner-assessed) | *Strengthens* alignment: conforms API responses to the camelCase `shared-schemas/*` — the documented cross-boundary contract (principle: structured outputs / schemas shared by Android+backend+AI; D-06). No new product surface/scope/deps; adds Ajv response-validation tests. Conformance-to-existing-contract, so recorded by planner without spinning the subagent. |
| `0011-android-network` | 2026-06-02 | **ALIGNED** (agent-reviewed; ship as-is) | Android `:network` DTOs + Retrofit client. Confirms D-02 (Retrofit/OkHttp/kotlinx, not Ktor), D-06 (networknt in tests only; handwritten `@Serializable` DTOs), D-09 (no Android care-engine — `CareTaskDto` is a read-only carrier), D-11/D-12 (no CameraX/GPS), no FCM/WorkManager/AI deps, no Compose yet, camelCase matching the conformant API. No drift. |

_Earlier handoffs `0001`–`0005` predate this gate; they were aligned by construction
(schema validation, deterministic care-engine, seed catalog, DB foundation — all
core-vision items)._
