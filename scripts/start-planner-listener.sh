#!/usr/bin/env bash
# Start the planner-side background listener (detached, survives this shell).
# Idempotent: if already running, prints the existing PID/log and exits 0.
# NEVER touches the PlantApp app repo. See exchange/README.md (PD-06).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANNER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATEDIR="$PLANNER_ROOT/state/watchers"
LOGDIR="$PLANNER_ROOT/logs/watchers/planner"
META="$STATEDIR/planner-listener.json"
LOG="$LOGDIR/planner-listener.log"
LOOP="$SCRIPT_DIR/watch-planner-loop.sh"

die() { echo "ERROR: $*" >&2; exit 1; }
mkdir -p "$STATEDIR" "$LOGDIR"
[ -f "$LOOP" ] || die "loop script missing: $LOOP"

read_pid(){ grep -o '"pid"[[:space:]]*:[[:space:]]*[0-9]*' "$META" 2>/dev/null | grep -o '[0-9]*' | head -1 || true; }

if [ -f "$META" ]; then
  oldpid="$(read_pid)"
  if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
    echo "planner-listener already running: PID $oldpid"
    echo "log:  $LOG"
    echo "meta: $META"
    exit 0
  fi
fi

# Detach into a new session so it outlives this shell; the loop self-registers its
# real PID into $META.
setsid bash "$LOOP" >>"$LOG" 2>&1 < /dev/null &

pid=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
  sleep 0.5
  if [ -f "$META" ]; then
    pid="$(read_pid)"
    if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then break; fi
  fi
done

[ -n "${pid:-}" ] || die "listener did not register a PID (check $LOG)"
kill -0 "$pid" 2>/dev/null || die "listener exited immediately (check $LOG)"

echo "planner-listener started: PID $pid"
echo "log:      $LOG"
echo "meta:     $META"
echo "watching: $PLANNER_ROOT/exchange/implementation-inbox"
