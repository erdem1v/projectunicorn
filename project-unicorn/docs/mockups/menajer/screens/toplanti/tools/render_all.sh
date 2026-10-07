#!/usr/bin/env bash
# Renders build/<name>.html to <name>.png (and a copy into rounds/<round>/) with the menajer render.sh.
# 1536 frames render at 1536x864 logical, scale 1.25 (a 1920x1080 PNG).
#   bash tools/render_all.sh <round> [name ...]
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
RENDER="$HERE/../../tools/render.sh"
ROUND="${1:-r1}"; shift || true
mkdir -p "$HERE/rounds/$ROUND"
SIZES="$(cd "$HERE/tools" && python gen.py --sizes)"
if [ $# -eq 0 ]; then set -- $(echo "$SIZES" | awk '{print $1}'); fi
fail=0
for n in "$@"; do
	read -r W H <<<"$(echo "$SIZES" | awk -v n="$n" '$1==n {print $2, $3}')"
	if [ "$W" = "1536" ]; then ARGS="1536 864 1.25"; else ARGS="1920 1080"; fi
	bash "$RENDER" "$HERE/build/$n.html" "$HERE/$n.png" $ARGS >/dev/null || { echo "FAIL $n"; fail=1; continue; }
	cp "$HERE/$n.png" "$HERE/rounds/$ROUND/$n.png"
	echo "ok $n"
done
exit $fail
