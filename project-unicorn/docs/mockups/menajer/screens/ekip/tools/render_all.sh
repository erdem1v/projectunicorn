#!/usr/bin/env bash
# Renders build/<name>.html to <name>.png (and a copy into rounds/<round>/) with the menajer render.sh.
# Frames listed in build/sizes.txt render at their logical size and scale (1536 864 1.25).
#   bash tools/render_all.sh <round> [name ...]
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
RENDER="$HERE/../../tools/render.sh"
ROUND="${1:-r1}"; shift || true
mkdir -p "$HERE/rounds/$ROUND"
if [ $# -eq 0 ]; then set -- $(cd "$HERE/build" && ls *.html | sed 's/\.html$//'); fi
fail=0
for n in "$@"; do
	size="$(grep "^$n " "$HERE/build/sizes.txt" 2>/dev/null | cut -d' ' -f2-)"
	bash "$RENDER" "$HERE/build/$n.html" "$HERE/$n.png" $size >/dev/null || { echo "FAIL $n"; fail=1; continue; }
	cp "$HERE/$n.png" "$HERE/rounds/$ROUND/$n.png"
	echo "ok $n"
done
exit $fail
