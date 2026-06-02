#!/usr/bin/env bash
# Show planner-listener status (PID, liveness, paused state, log path).
# NEVER touches the PlantApp app repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANNER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATEDIR="$PLANNER_ROOT/state/watchers"
LOGDIR="$PLANNER_ROOT/logs/watchers/planner"
META="$STATEDIR/planner-listener.json"
PAUSED="$STATEDIR/paused.flag"

if [ ! -f "$META" ]; then echo "no planner-listener registered"; exit 0; fi

pid="$(grep -o '"pid"[[:space:]]*:[[:space:]]*[0-9]*' "$META" 2>/dev/null | grep -o '[0-9]*' | head -1 || true)"
echo "=== planner-listener metadata ==="
cat "$META"
echo
if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
  echo "status: RUNNING (pid $pid)"
else
  echo "status: NOT running (stale metadata)"
fi
if [ -f "$PAUSED" ]; then
  echo "paused: YES — $(head -1 "$PAUSED" 2>/dev/null || true)"
else
  echo "paused: no"
fi
echo "log: $LOGDIR/planner-listener.log"
