#!/usr/bin/env bash
# Planner-side reader. Prints the latest (or a given) READY report from the inbox.
# Reads ONLY implementation-inbox/<id>/ containing READY.json. Never reads .writing/.
# Verifies SHA256SUMS. Flags BLOCKED reports (planner alone asks the owner).
# NEVER touches the PlantApp app repo. See exchange/README.md (PD-06).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXCHANGE="$REPO_ROOT/exchange"
INBOX="$EXCHANGE/implementation-inbox"
POINTERS="$EXCHANGE/pointers"

die() { echo "ERROR: $*" >&2; exit 1; }

ID="${1:-}"
if [ -z "$ID" ]; then
  [ -f "$POINTERS/latest-ready-report" ] || die "no latest-ready-report pointer; no report yet"
  ID="$(cat "$POINTERS/latest-ready-report")"
fi
echo "$ID" | grep -Eq '^[A-Za-z0-9._-]+$' || die "invalid handoff-id '$ID'"
case "$ID" in .writing|.writing/*) die "refusing to read .writing (incomplete)";; esac

DIR="$INBOX/$ID"
[ -d "$DIR" ] || die "report dir not found: $DIR"
[ -f "$DIR/READY.json" ] || die "no READY.json in $DIR — report not ready; refusing to read"

( cd "$DIR" && sha256sum -c SHA256SUMS >/dev/null ) || die "checksum mismatch in $DIR — refusing to read"

echo "# READY report: $ID" >&2
if [ -f "$DIR/BLOCKED.md" ]; then
  echo "# STATUS: BLOCKED — planner must consume this and ask the owner (rule 12)." >&2
  cat "$DIR/BLOCKED.md"
else
  echo "# STATUS: done" >&2
  cat "$DIR/REPORT.md"
fi
