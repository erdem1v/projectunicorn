#!/usr/bin/env bash
# Renders build/<name>.html to <name>.png (and a copy into rounds/<round>/) with the menajer render.sh,
# at each frame's own logical size and scale (python tools/gen.py --sizes).
#   bash tools/render_all.sh <round> [name ...]
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
RENDER="$HERE/../../tools/render.sh"
ROUND="${1:-r1}"; shift || true
mkdir -p "$HERE/rounds/$ROUND"
SIZES="$(cd "$HERE/tools" && PYTHONIOENCODING=utf-8 python gen.py --sizes)"
if [ $# -eq 0 ]; then set -- $(echo "$SIZES" | awk '{print $1}'); fi
fail=0
for n in "$@"; do
	read -r _ w h s <<< "$(echo "$SIZES" | awk -v n="$n" '$1==n')"
	bash "$RENDER" "$HERE/build/$n.html" "$HERE/$n.png" "$w" "$h" "$s" >/dev/null || { echo "FAIL $n"; fail=1; continue; }
	cp "$HERE/$n.png" "$HERE/rounds/$ROUND/$n.png"
	echo "ok $n"
done
exit $fail
