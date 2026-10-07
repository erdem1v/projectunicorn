#!/usr/bin/env bash
# Parallel wrapper: renders every build/*.html (or the names given) with render_all.sh, N at a time.
#   bash tools/render_par.sh <round> [name ...]
HERE="$(cd "$(dirname "$0")/.." && pwd)"
ROUND="${1:-r1}"; shift || true
if [ $# -eq 0 ]; then set -- $(cd "$HERE/build" && ls *.html | sed 's/\.html$//'); fi
printf '%s\n' "$@" | xargs -P 4 -I{} bash "$HERE/tools/render_all.sh" "$ROUND" {}
