#!/usr/bin/env bash
# Renders the sheet: ../build/page_NN.html -> ../pages/NN_<name>.png (one Chrome per page, four at a time), the two
# shell screens, the 1280x720 legibility checks, the colour-vision previews (page 8 embeds them, so page 8 is
# rendered twice) and the overflow report the full sheet writes into <pre id=report> (headless --dump-dom).
#   render_pages.sh [round_tag]     with a tag, also copies the pages to ../rounds/<tag>/
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
SYS="$(cd "$HERE/.." && pwd)"
RENDER="$SYS/../tools/render.sh"
mkdir -p "$SYS/pages"
NAMES=(01_renk 02_yazi 03_kontroller 04_veri 05_gelen_kutusu 06_karar 07_kabuk 08_renk_koru 09_yerlesim 10_portre 11_grafik 12_alan 13_toplanti_acilis 14_diyalog_metin 15_en_kabuk 16_en_ekip)
one() { i=$1; n=${NAMES[$((i-1))]}; bash "$RENDER" "$SYS/build/page_$(printf %02d "$i").html" "$SYS/pages/$n.png" 1920 1080 1 > /dev/null; }
export -f one 2>/dev/null || true
pids=()
for i in $(seq 1 ${#NAMES[@]}); do
	one "$i" & pids+=($!)
	if [ ${#pids[@]} -ge 4 ]; then wait "${pids[0]}"; pids=("${pids[@]:1}"); fi
done
wait
bash "$RENDER" "$SYS/build/screen_1920.html" "$SYS/pages/s1_ekran_1920.png" 1920 1080 1 > /dev/null
bash "$RENDER" "$SYS/build/screen_1536.html" "$SYS/pages/s2_ekran_1536.png" 1536 864 1 > /dev/null
bash "$RENDER" "$SYS/build/screen_city.html" "$SYS/pages/s3_ofis_katmani.png" 1920 1080 1 > /dev/null
PYTHONIOENCODING=utf-8 python "$HERE/simulate_cvd.py"
one 8
PYTHONIOENCODING=utf-8 python "$HERE/split_pages.py" "$SYS/pages" "${1:-}" "$SYS/rounds"

CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
PROFILE="$(mktemp -d)"
TMP="$(mktemp -d)"
trap 'rm -rf "$PROFILE" "$TMP"' EXIT
URL="file:///$(cygpath -m "$SYS/components.html" | sed 's/ /%20/g')"
timeout -k 5 120 "$CHROME" --headless=new --window-size=1920,1080 --virtual-time-budget=15000 --no-first-run \
	--user-data-dir="$(cygpath -w "$PROFILE")" --dump-dom "$URL" 2>/dev/null > "$TMP/dom.html" || true
PYTHONIOENCODING=utf-8 python - "$TMP/dom.html" <<'PYEOF'
import html, re, sys
d = open(sys.argv[1], encoding="utf-8", errors="replace").read()
m = re.search(r'<pre id="report"[^>]*>(.*?)</pre>', d, re.S)
print("overflow report:\n" + (html.unescape(m.group(1)) if m else "(no report: page did not finish)"))
PYEOF
