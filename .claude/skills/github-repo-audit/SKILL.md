---
name: github-repo-audit
description: Planner-only. Produce an evidence-backed comparison of PlantApp local git state vs GitHub (origin/master, PRs, issues, status checks, workflows, default branch) before recommending the next prompt. Read-only; never mutates PlantApp.
---

# Skill: github-repo-audit

**Planner-only. PlantApp is READ-ONLY.** This skill never edits, commits, pushes,
installs, builds, or migrates anything in PlantApp. It only inspects and reports.

## When to use
Before producing or updating `prompts/next-implementation-prompt.md`, and any time
you need to confirm local↔remote alignment. Recommendations must never rest on
stale remote state.

## Inputs
- PlantApp path: `/home/israel/Documents/Development/PlantApp`
- GitHub repo: `iFernandez96/PlantApp` (public, default `master`)

## Checklist
1. `git -C <PlantApp> fetch origin` (read-only ref update).
2. `git -C <PlantApp> rev-parse HEAD` and `… origin/master`; equal?
3. `git -C <PlantApp> status --short` — clean?
4. `gh repo view iFernandez96/PlantApp --json defaultBranchRef,isPrivate,visibility`.
5. `gh pr list --state all` ; `gh issue list --state all`.
6. `gh api repos/iFernandez96/PlantApp/commits/<sha>/status` and `/check-runs`.
7. `gh api repos/iFernandez96/PlantApp/actions/workflows` — does CI exist at all?
8. Is HEAD the expected SHA from `state/current-state.md`, or newer?

## Output format → write to `github-checks/latest-github-check.md`
- A summary table: latest origin/master SHA+subject, local==remote?, uncommitted?,
  default branch, PR count, issue count, status-check state/count, workflow count,
  check-run count, "CI exists?", "newer than expected?".
- An "Interpretation" section (esp. distinguish *no CI* from *CI passed*).
- A "Raw evidence" block with the actual commands and their outputs.

## Guardrails
- Read-only `gh` only. Never open/close/comment PRs/issues; never trigger CI.
- Date-stamp every report.
