#!/bin/bash
# Runs tools/office3d/export_office.html in a dedicated FOREGROUND Chrome window: Chrome
# freezes a background tab (canvas.toBlob and fetch().then() never settle). Own
# --user-data-dir outside the repo + --app window. Kills only its own Chrome (matched on
# that profile path), never the user's browser.
#
# usage: bash tools/office3d/run_export.sh [status_dir] [query]
#   status_dir: progress.txt, DONE.txt, serve.log, chrome.log land here
#               (default $TMP/office3d_status). Never inside the repo.
#   query:      page flags, e.g. "only=loft,city&thumbs=0" (see tools/office3d/README.md)
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"                       # project-unicorn
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
STATUS="${1:-${TMP:-/tmp}/office3d_status}"
QUERY="${2:-}"
PROFILE="${TMP:-/tmp}/office3d_chrome_profile"
PORT=8735
STAMP="$(date +%s)"
mkdir -p "$STATUS" "$PROFILE"
rm -f "$STATUS/DONE.txt" "$STATUS/progress.txt"

kill_own_chrome() {
  powershell.exe -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -like '*office3d_chrome_profile*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" >/dev/null 2>&1
}
kill_own_chrome; sleep 1

python "$HERE/serve.py" --port "$PORT" --status "$STATUS" > "$STATUS/serve.log" 2>&1 &
SERVER_PID=$!
sleep 1

# The occlusion flags keep the window rendering when other windows cover it.
nohup "$CHROME" --user-data-dir="$PROFILE" --no-first-run --no-default-browser-check \
  --disable-background-timer-throttling --disable-renderer-backgrounding \
  --disable-backgrounding-occluded-windows --disable-features=CalculateNativeWinOcclusion \
  --window-size=1280,760 \
  --app="http://127.0.0.1:$PORT/tools/office3d/export_office.html?v=$STAMP${QUERY:+&$QUERY}" \
  > "$STATUS/chrome.log" 2>&1 &

for i in $(seq 1 150); do
  [ -f "$STATUS/DONE.txt" ] && { echo "DONE: $(cat "$STATUS/DONE.txt")"; break; }
  sleep 2
done
[ -f "$STATUS/DONE.txt" ] || echo "TIMEOUT after 300s"

kill_own_chrome
kill $SERVER_PID 2>/dev/null
ls -la "$ROOT/art/office3d/" "$ROOT/assets/art/office/" 2>/dev/null
tail -8 "$STATUS/progress.txt" 2>/dev/null
