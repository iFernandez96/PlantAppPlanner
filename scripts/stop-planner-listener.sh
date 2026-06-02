#!/usr/bin/env bash
# Stop the planner-side background listener and any child one-shot. Kills the
# process group (the loop is a session leader). NEVER touches the PlantApp app repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANNER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATEDIR="$PLANNER_ROOT/state/watchers"
META="$STATEDIR/planner-listener.json"

[ -f "$META" ] || { echo "no listener metadata ($META); nothing to stop"; exit 0; }
pid="$(grep -o '"pid"[[:space:]]*:[[:space:]]*[0-9]*' "$META" 2>/dev/null | grep -o '[0-9]*' | head -1 || true)"
[ -n "${pid:-}" ] || { echo "no pid in $META; removing stale metadata"; rm -f "$META"; exit 0; }

if kill -0 "$pid" 2>/dev/null; then
  kill -TERM "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
  sleep 1
  kill -KILL "-$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null || true
  echo "stopped planner-listener PID $pid"
else
  echo "planner-listener PID $pid not running"
fi
rm -f "$META"
echo "removed $META"
