#!/bin/bash
# Run the rig in a dedicated FOREGROUND Chrome window and wait for it to finish.
#
# Why not drive the page over the MCP browser bridge: Chrome froze that
# background tab, so toBlob() callbacks and fetch().then() never fired (measured
# with an 8x8 canvas — it never fired either). Synchronous evaluation still
# worked, which made the freeze look like a slow encode. A foreground window on
# its own profile is not frozen, and it keeps the real GPU, so the output
# matches the approved look instead of a software rasteriser.
#
# usage: ./run.sh "<query string>"   e.g. ./run.sh "auto=1&solve=1&proofonly=1"
set -u
R="$(cd "$(dirname "$0")" && pwd)"
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
Q="${1:-auto=1&solve=1&proofonly=1}"
STAMP="$(date +%s)"

# Close only OUR chrome (matched on the profile path), never the user's browser.
powershell.exe -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -like '*oda_render_rig*chrome-profile*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" >/dev/null 2>&1
sleep 1

rm -f "$R/out/DONE.txt" "$R/out/solve.json" "$R/out/anchors.json" \
      "$R/out/proof-day.png" "$R/out/proof-night.png"

nohup "$CHROME" --user-data-dir="$R/chrome-profile" --no-first-run \
  --no-default-browser-check --window-size=1280,760 \
  --app="http://127.0.0.1:8732/layers.html?${Q}&v=${STAMP}" \
  > "$R/chrome.log" 2>&1 &

for i in $(seq 1 90); do
  [ -f "$R/out/DONE.txt" ] && { echo "DONE: $(cat "$R/out/DONE.txt")"; break; }
  sleep 2
done
[ -f "$R/out/DONE.txt" ] || { echo "TIMEOUT after 180s"; exit 1; }

powershell.exe -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -like '*oda_render_rig*chrome-profile*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" >/dev/null 2>&1

python - "$R" <<'PY'
import sys, os
from PIL import Image
out = os.path.join(sys.argv[1], "out")
for n in ("proof-day", "proof-night"):
    p = os.path.join(out, n + ".png")
    if os.path.exists(p):
        Image.open(p).convert("RGB").resize((1600, 900), Image.LANCZOS) \
             .save(os.path.join(out, n + "_view.jpg"), quality=88)
        print("view:", n + "_view.jpg")
PY
