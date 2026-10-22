#!/usr/bin/env bash
c="$1"
cd "/c/Users/erdem/Desktop/Project Unicorn/project-unicorn"
D="/c/Users/erdem/AppData/Local/Temp/fazA/K8_case_$c/appdata"
WD="C:\Users\erdem\AppData\Local\Temp\fazA\K8_case_$c\appdata"
mkdir -p "$D"
out="docs/tasks/faz_ab/a_calisma/K8_smoke/$c.log"
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe APPDATA="$WD" HOME="$WD" CASE_TIMEOUT=300 bash tools/smoke_run.sh "$c" > "$out" 2>&1
echo "$c rc=$? verdict=$(grep -a -o 'SMOKE PASS[^\r]*' "$out" | head -1)"
