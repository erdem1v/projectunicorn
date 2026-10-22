#!/usr/bin/env bash
# usage: sprintprobe.sh <name> <spec-after-sprint-probe=>
export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
SP="/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad/b6m"
mkdir -p "$SP/logs_D"
cd "/c/Users/erdem/Desktop/Project Unicorn/project-unicorn" || exit 2
ad="$SP/ad_sprint_$1"; rm -rf "$ad"; mkdir -p "$ad"
start=$SECONDS
APPDATA="$ad" HOME="$ad" USERPROFILE="$ad" "$GODOT" --headless --path . --lang=tr --sprint-probe="$2" > "$SP/logs_D/$1.log" 2>&1
ex=$?
echo "DONE $1 exit=$ex $((SECONDS-start))s"
grep -a "SPRINTPROBE \(SUMMARY\|LOADSUM\|PAPERSUM\)" "$SP/logs_D/$1.log"
grep -aE '^ERROR:|SCRIPT ERROR|Parse Error|Compile Error' "$SP/logs_D/$1.log" | grep -av 'resources still in use' | head -5
rm -rf "$ad"
