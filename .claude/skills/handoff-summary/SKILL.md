---
name: handoff-summary
description: Planner-only. Write the session-to-session handoff capturing one-line status, what changed, what the owner does next, what the next planner session does, open questions, and tripwires. Read-only w.r.t. PlantApp.
---

# Skill: handoff-summary

**Planner-only.** Writes only into this planner repo. Does not touch PlantApp.

## When to use
At the end of every planner session, after state/review/prompt files are updated.

## Checklist
1. One-line status (PlantApp HEAD + branch + sync + "production behavior?" +
   next step).
2. What this session did (bullet list).
3. What the **owner** does next (usually: paste the prompt into the impl Claude).
4. What the **next planner session** does (re-fetch, compare, branch on whether
   the last step landed, then update state + write the next prompt).
5. Open questions for the owner (non-blocking decisions, e.g. approve
   `npm install`? add a planner remote?).
6. Tripwires / do-not-assume list (e.g. "don't assume HEAD is still <sha>";
   "no CI exists, green ≠ tests passed").

## Output format → write to `handoffs/latest-handoff.md`
Use the headings above. Keep it skimmable; link to `state/current-state.md`,
`prompts/next-implementation-prompt.md`, and `decisions/planner-decisions.md`
rather than duplicating their contents.

## Guardrails
- Never put volatile SHAs as "trusted" — frame them as "as of <date>, re-verify."
- The handoff is a pointer to canonical files, not a replacement for them.
