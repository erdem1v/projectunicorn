#!/usr/bin/env bash
# Renders an HTML mockup to a PNG with headless Chrome, then checks the PNG.
#   render.sh <html> <png> [css_width css_height [scale]]
# Defaults: 1920 1080 1. The PNG is css_width*scale x css_height*scale. Each call uses its own
# throwaway Chrome profile, so parallel agents never share one. Exit 1 on a Chrome failure or a bad PNG.
set -u
if [ $# -ne 2 ] && [ $# -ne 4 ] && [ $# -ne 5 ]; then
	echo "usage: render.sh <html> <png> [css_width css_height [scale]]" >&2
	exit 2
fi
W="${3:-1920}"; H="${4:-1080}"; SCALE="${5:-1}"
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
PROFILE="$(mktemp -d)"
trap 'rm -rf "$PROFILE"' EXIT
mkdir -p "$(dirname "$2")"

HTML_ABS="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
PNG_ABS="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
URL="file:///$(cygpath -m "$HTML_ABS" | sed 's/ /%20/g')"
LOG="$PROFILE/render.log"
rm -f "$PNG_ABS"

timeout -k 5 90 "$CHROME" --headless=new --hide-scrollbars --force-device-scale-factor="$SCALE" \
	--window-size="$W,$H" --virtual-time-budget=10000 --no-first-run --no-default-browser-check \
	--user-data-dir="$(cygpath -w "$PROFILE")" --screenshot="$(cygpath -w "$PNG_ABS")" "$URL" \
	> "$LOG" 2>&1
CODE=$?
if [ ! -f "$PNG_ABS" ]; then
	echo "render.sh: no PNG written (chrome exit $CODE)" >&2
	tail -5 "$LOG" >&2
	exit 1
fi

PYTHONIOENCODING=utf-8 python - "$PNG_ABS" "$W" "$H" "$SCALE" <<'EOF' || exit 1
import sys
from PIL import Image
p, w, h, s = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), float(sys.argv[4])
im = Image.open(p).convert("RGB")
want = (round(w * s), round(h * s))
if im.size != want:
    sys.exit("render.sh: %s is %dx%d, want %dx%d" % (p, im.size[0], im.size[1], want[0], want[1]))
lo, hi = zip(*im.getextrema())
if lo == hi:
    sys.exit("render.sh: %s is a single colour %s" % (p, (lo,)))
EOF
echo "$PNG_ABS"
