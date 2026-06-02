#!/usr/bin/env bash
# Planner-side background listener loop. Watches the implementation-inbox for READY
# reports and reacts:
#   - DONE    -> invoke a planner-scoped one-shot Claude task (verify + update state +
#                publish next prompt + commit/push planner). Autonomous, gated.
#   - BLOCKED -> publish an owner-needed packet, ping the owner, set the paused flag,
#                and stop acting until the owner answers (planner asks; impl never does).
# HARD RULES: never mutate PlantApp, never read .writing/, never execute prompts,
# only consume reports that have READY.json, deduplicate processed ids.
# See exchange/README.md, decisions/planner-decisions.md PD-06.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANNER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXCHANGE="$PLANNER_ROOT/exchange"
INBOX="$EXCHANGE/implementation-inbox"
POINTERS="$EXCHANGE/pointers"
LOGDIR="$PLANNER_ROOT/logs/watchers/planner"
STATEDIR="$PLANNER_ROOT/state/watchers"
META="$STATEDIR/planner-listener.json"
PROCESSED="$STATEDIR/processed-report-ids.txt"
PAUSED="$STATEDIR/paused.flag"
HEARTBEAT="$STATEDIR/planner-listener.heartbeat"

POLL="${PLANNER_POLL_SECONDS:-30}"
ONESHOT="${PLANNER_ONESHOT:-claude}"   # set PLANNER_ONESHOT=off to disable autonomous one-shot

mkdir -p "$LOGDIR" "$STATEDIR"
touch "$PROCESSED"

PID=$$
HOST="$(hostname 2>/dev/null || echo unknown)"

log(){ printf '%s  %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

write_meta(){
  local paused_val="false"; [ -f "$PAUSED" ] && paused_val="true"
  cat > "$META.tmp" <<EOF
{
  "role": "planner-listener",
  "pid": $PID,
  "pgid": $PID,
  "startedUtc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "log": "$LOGDIR/planner-listener.log",
  "watching": "$INBOX",
  "pollSeconds": $POLL,
  "oneShot": "$ONESHOT",
  "paused": $paused_val,
  "host": "$HOST"
}
EOF
  mv "$META.tmp" "$META"
}
write_meta

cleanup(){ log "listener stopping (pid $PID)"; rm -f "$HEARTBEAT" 2>/dev/null || true; }
trap cleanup EXIT
trap 'log "signal received; exiting"; exit 0' TERM INT

log "planner-listener started (pid $PID); watching $INBOX; poll ${POLL}s; oneShot=$ONESHOT"
if [ -f "$PAUSED" ]; then log "starting PAUSED: $(head -1 "$PAUSED" 2>/dev/null || true)"; fi

already_processed(){ grep -qxF "$1" "$PROCESSED" 2>/dev/null; }
mark_processed(){ printf '%s\n' "$1" >> "$PROCESSED"; }

handle_blocked(){
  local id="$1" dir="$INBOX/$1" pkt="$STATEDIR/owner-needed-$1.md"
  {
    echo "# Owner decision needed — $id"
    echo
    echo "The implementation Claude returned a BLOCKED report. The planner does not"
    echo "publish another implementation prompt until the owner answers (PD-06)."
    echo
    echo "## Blocker (verbatim from the report)"
    echo
    cat "$dir/BLOCKED.md" 2>/dev/null || echo "(BLOCKED.md unreadable)"
  } > "$pkt"
  "$SCRIPT_DIR/exchange-create-owner-needed.sh" "$id" "$pkt" >>"$LOGDIR/owner-needed.log" 2>&1 \
    || log "owner-needed publish skipped/failed for $id (may already exist)"
  "$SCRIPT_DIR/notify-owner.sh" "PlantAppPlanner: decision needed" "BLOCKED report $id — planner paused awaiting your answer" >>"$LOGDIR/owner-pings.log" 2>&1 || true
  printf 'blocked report %s at %s\n' "$id" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$PAUSED"
  write_meta
  log "BLOCKED $id handled: owner-needed published, owner pinged, listener PAUSED"
}

handle_done(){
  local id="$1" prompt
  if [ "$ONESHOT" = "off" ] || ! command -v "$ONESHOT" >/dev/null 2>&1; then
    log "DONE $id: one-shot disabled/unavailable ($ONESHOT); pausing + pinging owner for manual planner processing"
    "$SCRIPT_DIR/notify-owner.sh" "PlantAppPlanner: DONE report" "DONE report $id needs planner processing (one-shot unavailable)" >>"$LOGDIR/owner-pings.log" 2>&1 || true
    printf 'done report %s needs manual planner processing\n' "$id" > "$PAUSED"
    write_meta
    return 0
  fi
  log "DONE $id: invoking planner one-shot ($ONESHOT); see oneshot.$id.log"
  prompt="$(sed "s/__HANDOFF_ID__/$id/g" "$SCRIPT_DIR/planner-process-report.prompt.md" 2>/dev/null || true)"
  if [ -z "$prompt" ]; then
    log "DONE $id: missing one-shot prompt template; pausing + pinging owner"
    "$SCRIPT_DIR/notify-owner.sh" "PlantAppPlanner" "DONE $id: one-shot prompt template missing" >>"$LOGDIR/owner-pings.log" 2>&1 || true
    printf 'one-shot template missing for %s\n' "$id" > "$PAUSED"; write_meta; return 0
  fi
  # Headless, print-mode, planner-scoped, time-bounded. NO --dangerously-skip-permissions.
  if ( cd "$PLANNER_ROOT" && timeout 1200 "$ONESHOT" -p "$prompt" >>"$LOGDIR/oneshot.$id.log" 2>&1 ); then
    log "DONE $id: one-shot completed"
  else
    log "DONE $id: one-shot FAILED/timed out; pausing + pinging owner"
    "$SCRIPT_DIR/notify-owner.sh" "PlantAppPlanner: one-shot failed" "Planner one-shot for $id failed; paused" >>"$LOGDIR/owner-pings.log" 2>&1 || true
    printf 'one-shot failed for %s\n' "$id" > "$PAUSED"; write_meta
  fi
}

process_report(){
  local id="$1" dir status
  dir="$INBOX/$id"
  case "$id" in .writing|.writing/*) log "refusing .writing id '$id'"; return 0;; esac
  [ -f "$dir/READY.json" ] || { log "no READY.json for $id yet; not processing"; return 0; }
  if ! "$SCRIPT_DIR/exchange-read-latest-report.sh" "$id" >>"$LOGDIR/report.$id.log" 2>&1; then
    log "reader/checksum FAILED for $id; pausing + pinging owner"
    "$SCRIPT_DIR/notify-owner.sh" "PlantAppPlanner" "Report $id failed checksum/READY check" >>"$LOGDIR/owner-pings.log" 2>&1 || true
    printf 'checksum-or-ready failure for %s\n' "$id" > "$PAUSED"; write_meta
    mark_processed "$id"; return 0
  fi
  status="$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$dir/READY.json" | head -1 | sed 's/.*"\([^"]*\)"$/\1/' || true)"
  log "report $id status=${status:-unknown}"
  if [ "${status:-}" = "blocked" ]; then handle_blocked "$id"; else handle_done "$id"; fi
  mark_processed "$id"
}

# Main loop.
while true; do
  : > "$HEARTBEAT" 2>/dev/null || true
  if [ -f "$PAUSED" ]; then
    log "paused ($(head -1 "$PAUSED" 2>/dev/null || true)); not processing; remove $PAUSED to resume"
    sleep "$POLL"; continue
  fi
  if [ -f "$POINTERS/latest-ready-report" ]; then
    ID="$(cat "$POINTERS/latest-ready-report" 2>/dev/null || true)"
    if [ -n "${ID:-}" ] && ! already_processed "$ID"; then
      log "new READY report detected: $ID"
      process_report "$ID" || log "process_report error for $ID (loop continues)"
    fi
  fi
  sleep "$POLL"
done
