#!/usr/bin/env bash
# Implementation-side writer. Atomically publish a report into
# exchange/implementation-inbox/<id>/. Writes ONLY under implementation-inbox.
# Must NOT edit planner state/reviews/decisions/prompts/outbox, and NEVER touches
# the PlantApp app repo. If blocked, pass --blocked and provide BLOCKED.md in
# <source-dir>. See exchange/README.md (PD-06).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXCHANGE="$REPO_ROOT/exchange"
INBOX="$EXCHANGE/implementation-inbox"
WRITING="$INBOX/.writing"
POINTERS="$EXCHANGE/pointers"
LOCKS="$EXCHANGE/locks"

die() { echo "ERROR: $*" >&2; exit 1; }

BLOCKED=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --blocked) BLOCKED=1 ;;
    *) ARGS+=("$a") ;;
  esac
done
[ "${#ARGS[@]}" -eq 2 ] || die "usage: $(basename "$0") <handoff-id> <source-dir> [--blocked]"
ID="${ARGS[0]}"
SRCDIR="${ARGS[1]}"

echo "$ID" | grep -Eq '^[A-Za-z0-9._-]+$' || die "invalid handoff-id '$ID'"
[ -d "$SRCDIR" ] || die "source dir not found: $SRCDIR"

if [ "$BLOCKED" -eq 1 ]; then
  [ -f "$SRCDIR/BLOCKED.md" ] || die "blocked report requires $SRCDIR/BLOCKED.md"
  STATUS="blocked"
else
  for f in REPORT.md COMMANDS.log VERIFICATION.md; do
    [ -f "$SRCDIR/$f" ] || die "done report requires $SRCDIR/$f"
  done
  STATUS="done"
fi

DEST="$INBOX/$ID"
STAGE="$WRITING/$ID"
[ ! -e "$DEST" ] || die "inbox entry already exists (immutable): $DEST"
[ ! -e "$STAGE" ] || die "stale staging dir exists: $STAGE (remove it first)"

LOCK="$LOCKS/implementation-inbox.lock"
mkdir "$LOCK" 2>/dev/null || die "another report write is in progress ($LOCK)"
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p "$STAGE"

FILES=()
for f in REPORT.md COMMANDS.log VERIFICATION.md BLOCKED.md; do
  if [ -f "$SRCDIR/$f" ]; then cp "$SRCDIR/$f" "$STAGE/$f"; FILES+=("$f"); fi
done

FILES_JSON="$(printf '"%s",' "${FILES[@]}")"; FILES_JSON="[${FILES_JSON%,}]"
cat > "$STAGE/MANIFEST.json" <<EOF
{
  "id": "$ID",
  "kind": "report",
  "status": "$STATUS",
  "producer": "implementation",
  "createdUtc": "$NOW",
  "files": $FILES_JSON
}
EOF

( cd "$STAGE" && sha256sum "${FILES[@]}" MANIFEST.json > SHA256SUMS )

cat > "$STAGE/READY.json" <<EOF
{
  "id": "$ID",
  "kind": "report",
  "status": "$STATUS",
  "producer": "implementation",
  "createdUtc": "$NOW",
  "checksums": "SHA256SUMS"
}
EOF

mv "$STAGE" "$DEST"

printf '%s\n' "$ID" > "$POINTERS/latest-ready-report.tmp"
mv "$POINTERS/latest-ready-report.tmp" "$POINTERS/latest-ready-report"

echo "published report ($STATUS): $DEST"
echo "pointer updated: $POINTERS/latest-ready-report -> $ID"
if [ "$STATUS" = "blocked" ]; then
  echo "NOTE: BLOCKED report — the PLANNER consumes this and is the ONLY instance that asks the owner."
fi
exit 0
