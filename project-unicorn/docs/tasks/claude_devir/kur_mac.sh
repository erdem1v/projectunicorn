#!/bin/bash
set -euo pipefail
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
HERE="$(cd "$(dirname "$0")" && pwd)"
SID=6d15b35f-66f1-4e87-b274-dc8c31d2f7b4
# This folder is <repo>/project-unicorn/docs/tasks/claude_devir.
REPO="$(cd "$HERE/../../../.." && pwd -P)"

# Claude Code names a project folder after its path with every non-alphanumeric character turned into '-'.
SLUG="$(printf '%s' "$REPO" | sed 's/[^A-Za-z0-9]/-/g')"
PROJ="$CLAUDE_DIR/projects/$SLUG"
mkdir -p "$PROJ/memory"
cp -R "$HERE/memory/." "$PROJ/memory/"
cp -R "$HERE/oturum/." "$PROJ/"

echo "Claude proje klasoru: $PROJ"
echo "Simdi: cd \"$REPO\" && claude --resume $SID"
