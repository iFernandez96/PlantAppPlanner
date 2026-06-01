#!/usr/bin/env bash
# Implementation-side reader. Prints the latest (or a given) READY prompt.
# Reads ONLY planner-outbox/<id>/ that contains READY.json. Never reads .writing/.
# Verifies SHA256SUMS. NEVER touches the PlantApp app repo. See exchange/README.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXCHANGE="$REPO_ROOT/exchange"
OUTBOX="$EXCHANGE/planner-outbox"
POINTERS="$EXCHANGE/pointers"

die() { echo "ERROR: $*" >&2; exit 1; }

ID="${1:-}"
if [ -z "$ID" ]; then
  [ -f "$POINTERS/latest-ready-prompt" ] || die "no latest-ready-prompt pointer; nothing published yet"
  ID="$(cat "$POINTERS/latest-ready-prompt")"
fi
echo "$ID" | grep -Eq '^[A-Za-z0-9._-]+$' || die "invalid handoff-id '$ID'"
case "$ID" in .writing|.writing/*) die "refusing to read .writing (incomplete)";; esac

DIR="$OUTBOX/$ID"
[ -d "$DIR" ] || die "prompt dir not found: $DIR"
[ -f "$DIR/READY.json" ] || die "no READY.json in $DIR — prompt is not ready; refusing to read"

( cd "$DIR" && sha256sum -c SHA256SUMS >/dev/null ) || die "checksum mismatch in $DIR — refusing to read"

echo "# READY prompt: $ID" >&2
echo "# path: $DIR/PROMPT.md" >&2
cat "$DIR/PROMPT.md"
