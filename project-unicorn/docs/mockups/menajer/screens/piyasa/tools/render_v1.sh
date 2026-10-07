#!/usr/bin/env bash
# Renders build/<name>.html of the V1 set to <name>.png (and a copy into rounds/<round>/) with the menajer render.sh.
#   bash tools/render_v1.sh <round> [name ...]
# Sizes come from gen_v1.py --sizes (name width height scale).
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
RENDER="$HERE/../../tools/render.sh"
ROUND="${1:-r4}"; shift || true
mkdir -p "$HERE/rounds/$ROUND"
SIZES="$(cd "$HERE/tools" && python gen_v1.py --sizes)"
if [ $# -eq 0 ]; then set -- $(echo "$SIZES" | cut -d' ' -f1); fi
fail=0
for n in "$@"; do
	SZ="$(echo "$SIZES" | awk -v n="$n" '$1==n {print $2, $3, $4}')"
	bash "$RENDER" "$HERE/build/$n.html" "$HERE/$n.png" $SZ >/dev/null || { echo "FAIL $n"; fail=1; continue; }
	cp "$HERE/$n.png" "$HERE/rounds/$ROUND/$n.png"
	echo "ok $n"
done
exit $fail
