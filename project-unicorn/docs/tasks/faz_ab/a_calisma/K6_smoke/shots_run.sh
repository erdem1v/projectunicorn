#!/usr/bin/env bash
# usage: shots_run.sh <n> <godot args...>
n="$1"; shift
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
cd "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn" || exit 2
A=docs/tasks/faz_ab/a_calisma/shots/K6
W="K6_shot_$n"
APD="C:/Users/erdem/AppData/Local/Temp/fazA/$W"
mkdir -p "/c/Users/erdem/AppData/Local/Temp/fazA/$W"
timeout 240 env APPDATA="$APD" HOME="$APD" "$GODOT" --path . "$@" > "$A/log_$n.txt" 2>&1
rc=$?
pngdir="/c/Users/erdem/AppData/Local/Temp/fazA/$W/Godot/app_userdata/Project Unicorn"
cnt=0
for p in "$pngdir"/*.png; do [ -f "$p" ] || continue; cnt=$((cnt+1)); cp "$p" "$A/${n}_$(basename "$p")"; done
err=$(grep -c "ERROR" "$A/log_$n.txt")
echo "shot $n rc=$rc png=$cnt errlines=$err :: $*"
