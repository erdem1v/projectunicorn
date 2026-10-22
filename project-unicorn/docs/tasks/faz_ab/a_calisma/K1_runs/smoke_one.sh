#!/usr/bin/env bash
# usage: smoke_one.sh <case>  -- isolated APPDATA/HOME per case
cd "/c/Users/erdem/Desktop/Project Unicorn/project-unicorn" || exit 2
c="$1"; d="/c/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_ab/a_calisma/appdata_smoke/$c"
mkdir -p "$d/appdata" "$d/home"
APPDATA="$d/appdata" HOME="$d/home" CASE_TIMEOUT=300 GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe bash tools/smoke_run.sh "$c"
echo "CASE_EXIT $c $?"
