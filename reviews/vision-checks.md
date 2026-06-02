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

_Earlier handoffs `0001`–`0005` predate this gate; they were aligned by construction
(schema validation, deterministic care-engine, seed catalog, DB foundation — all
core-vision items)._
