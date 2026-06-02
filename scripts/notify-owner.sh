#!/usr/bin/env bash
# Planner-only owner ping. Best-effort: appends to the owner-pings log and tries a
# desktop notification. Never fails the caller. NEVER touches the PlantApp app repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANNER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOGDIR="$PLANNER_ROOT/logs/watchers/planner"
mkdir -p "$LOGDIR"

TITLE="${1:-PlantAppPlanner}"
MSG="${2:-Owner attention needed}"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

printf '%s  %s — %s\n' "$NOW" "$TITLE" "$MSG" >> "$LOGDIR/owner-pings.log"

if command -v notify-send >/dev/null 2>&1; then
  notify-send -u critical "$TITLE" "$MSG" >/dev/null 2>&1 || true
fi

echo "owner pinged: $TITLE — $MSG"
