#!/usr/bin/env bash
# export.sh <dest> [patch]: HEAD tree (plus a patch applied through a private index) checked out to <dest>.
set -euo pipefail
DEST="$1"; PATCH="${2:-}"
REPO="C:/Users/erdem/Desktop/project steam"
IDX="$(mktemp -u)".idx
rm -rf "${DEST:?}"; mkdir -p "$DEST"
export GIT_INDEX_FILE="$IDX"
git -C "$REPO" read-tree HEAD
if [ -n "$PATCH" ]; then git -C "$REPO" apply --cached "$PATCH"; git -C "$REPO" diff --cached --stat HEAD | tail -1; fi
git -C "$REPO" checkout-index -a --prefix="$DEST/"
unset GIT_INDEX_FILE
rm -f "$IDX"
