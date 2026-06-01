# exchange/ — Atomic planner ↔ implementation handoff protocol

This directory is the **only** channel between the **planner** Claude (this repo)
and the **implementation** Claude (which edits the real PlantApp repo). Messages are
**immutable, completed directories** marked by a `READY.json` file. Nobody reads a
message that is still being written.

Decision of record: `../decisions/planner-decisions.md` **PD-06**.

## Layout

```
exchange/
  README.md                       this file
  planner-outbox/                 prompts the planner publishes (planner writes, impl reads)
    .writing/                     in-progress prompt builds — NEVER read this
    <handoff-id>/                 a published, immutable prompt (has READY.json)
  implementation-inbox/           reports the impl publishes (impl writes, planner reads)
    .writing/                     in-progress report builds — NEVER read this
    <handoff-id>/                 a published, immutable report (has READY.json)
  archive/
    planner-outbox/               consumed prompts moved here (optional housekeeping)
    implementation-inbox/         consumed reports moved here (optional housekeeping)
  pointers/
    latest-ready-prompt           text file: id of the newest READY prompt
    latest-ready-report           text file: id of the newest READY report
  locks/                          advisory mkdir locks held only during a write
```

## Message contents

- **Prompt** (`planner-outbox/<id>/`): `PROMPT.md`, `MANIFEST.json`, `SHA256SUMS`,
  `READY.json`.
- **Report** (`implementation-inbox/<id>/`): `REPORT.md`, `COMMANDS.log`,
  `VERIFICATION.md`, `READY.json` — **or**, if blocked, `BLOCKED.md` + `READY.json`.

`READY.json` is written **last** (inside `.writing/`) and the whole directory is then
**atomically renamed** into place. Its presence is the only "this is safe to read"
signal. `SHA256SUMS` lets the reader verify integrity.

## Protocol (PD-06)

1. Planner writes prompts only into `planner-outbox/.writing/<handoff-id>/`.
2. Planner writes `PROMPT.md`, `MANIFEST.json`, `SHA256SUMS`, then `READY.json`.
3. Planner moves the completed dir from `.writing/` to `planner-outbox/<handoff-id>/`
   atomically (single `mv` rename, same filesystem).
4. Planner updates `pointers/latest-ready-prompt` using a `.tmp` file then atomic `mv`.
5. Implementation may only read prompt folders that contain `READY.json`.
6. Implementation must never read from `.writing/`.
7. Implementation writes reports only into `implementation-inbox/.writing/<handoff-id>/`.
8. Implementation writes `REPORT.md`, `COMMANDS.log`, `VERIFICATION.md`, `READY.json`.
9. If blocked, implementation writes `BLOCKED.md` and `READY.json`, then stops.
10. Implementation moves the completed report dir atomically into
    `implementation-inbox/<handoff-id>/`.
11. Implementation must not edit planner `state/`, `reviews/`, `decisions/`,
    `prompts/`, or `planner-outbox/`.
12. The **planner is the only** instance allowed to ask the owner for decisions.
13. If implementation needs owner input, it writes a **BLOCKED** report and stops;
    the planner consumes it and asks the owner.

## Scripts (`../scripts/`)

| Script | Side | Purpose |
|---|---|---|
| `exchange-create-planner-prompt.sh <id> <prompt.md>` | planner | publish a prompt atomically + update pointer |
| `exchange-read-latest-prompt.sh [id]` | implementation | print the latest (or given) READY prompt |
| `exchange-create-implementation-report.sh <id> <src-dir> [--blocked]` | implementation | publish a report/blocker atomically + update pointer |
| `exchange-read-latest-report.sh [id]` | planner | print the latest (or given) READY report; flags BLOCKED |

All scripts use `set -euo pipefail`, refuse to read `.writing/`, reject a message
with no `READY.json`, write pointers via `.tmp`+`mv`, hold an advisory `locks/` lock
while writing, and **never touch the PlantApp app repo**.

## Hard boundaries

- Planner writes `planner-outbox/`; reads `implementation-inbox/`.
- Implementation reads `planner-outbox/`; writes `implementation-inbox/`.
- Neither side reads any `.writing/` directory.
- Published `<handoff-id>/` directories are **immutable** — never edit in place;
  supersede with a new id.
- Only the planner asks the owner for decisions (rule 12). Implementation surfaces
  decisions exclusively as a `BLOCKED.md` report.
