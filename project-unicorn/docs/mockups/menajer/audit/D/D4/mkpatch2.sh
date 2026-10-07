#!/usr/bin/env bash
# mkpatch2.sh <tree> <out.patch>: <tree>'s changes against the repo's HEAD, through a private index.
set -euo pipefail
D="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/d4"
REPO="C:/Users/erdem/Desktop/project steam"
export GIT_INDEX_FILE="$D/mk2.idx"
rm -f "$GIT_INDEX_FILE"
git -C "$REPO" read-tree HEAD
git -C "$REPO" --work-tree="$D/$1" add -A -- project-unicorn ':!project-unicorn/project.godot'
git -C "$REPO" diff --cached --binary --no-renames HEAD > "$2"
git -C "$REPO" diff --cached --stat --no-renames HEAD
rm -f "$GIT_INDEX_FILE"
