#!/bin/bash
# ODA 3D spike — run the GLB export page in a dedicated FOREGROUND Chrome window.
#
# Same discipline as tools/oda_render_rig/run.sh: a background tab is frozen by
# Chrome (fetch().then() never fires; synchronous code still runs, so the freeze
# reads like a slow export). Own --user-data-dir (outside the repo) + --app window.
# Kills only its own Chrome (matched on that profile path), never the user's browser.
#
# usage: docs/tools/oda3d/run_export.sh [status_dir]
#   status_dir: where DONE.txt lands (default: $TMP/oda3d_status). Never inside the repo.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../../.." && pwd)"                       # project-unicorn
CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"
STATUS="${1:-${TMP:-/tmp}/oda3d_status}"
PROFILE="${TMP:-/tmp}/oda3d_chrome_profile"
PORT=8734
STAMP="$(date +%s)"
mkdir -p "$STATUS" "$PROFILE"
rm -f "$STATUS/DONE.txt"

kill_own_chrome() {
  powershell.exe -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -like '*oda3d_chrome_profile*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" >/dev/null 2>&1
}
kill_own_chrome; sleep 1

python "$HERE/serve_glb.py" --port "$PORT" --status "$STATUS" > "$STATUS/serve.log" 2>&1 &
SERVER_PID=$!
sleep 1

nohup "$CHROME" --user-data-dir="$PROFILE" --no-first-run --no-default-browser-check \
  --window-size=1280,760 \
  --app="http://127.0.0.1:$PORT/docs/tools/oda3d/export_glb.html?v=$STAMP" \
  > "$STATUS/chrome.log" 2>&1 &

for i in $(seq 1 60); do
  [ -f "$STATUS/DONE.txt" ] && { echo "DONE: $(cat "$STATUS/DONE.txt")"; break; }
  sleep 2
done
[ -f "$STATUS/DONE.txt" ] || echo "TIMEOUT after 120s"

kill_own_chrome
kill $SERVER_PID 2>/dev/null
ls -la "$ROOT/art/oda3d/" 2>/dev/null
cat "$STATUS/serve.log" 2>/dev/null | tail -5
