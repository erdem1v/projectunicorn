#!/usr/bin/env bash
# usage: runset.sh <outdir> <logname-prefix-mode> spec...   spec = preset:seed[:logname]
export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
SP="/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad/b6m"
OUT="$1"; shift
mkdir -p "$OUT"
cd "/c/Users/erdem/Desktop/Project Unicorn/project-unicorn" || exit 2
for spec in "$@"; do
  IFS=: read -r preset seed logname <<<"$spec"
  logname="${logname:-${preset}_${seed}}"
  log="$OUT/$logname.log"
  if [ -f "$log" ] && grep -aq '^PROBE END' "$log"; then echo "SKIP (done) $logname"; continue; fi
  ad="$SP/ad_${preset}_${seed}"
  rm -rf "$ad"; mkdir -p "$ad"
  start=$SECONDS
  APPDATA="$ad" HOME="$ad" USERPROFILE="$ad" "$GODOT" --headless --path . --lang=tr --run-log="$preset:104:sim:$seed" > "$log" 2>&1
  ex=$?
  echo "DONE $logname exit=$ex $((SECONDS-start))s ends=$(grep -ac '^PROBE END' "$log") errs=$(grep -aE '^ERROR:|SCRIPT ERROR|Parse Error|Compile Error|^PROBE ERROR' "$log" | grep -avc 'resources still in use') fires=$(grep -ac '^PROBE FIRE' "$log")"
  rm -rf "$ad"
done
