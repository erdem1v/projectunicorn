#!/usr/bin/env bash
# prep.sh <tree> [patch]: export, seed .godot from d2fix/final, --import, restore project.godot, warm-up.
set -uo pipefail
S="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad"
D="$S/d4"; GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
REPO="C:/Users/erdem/Desktop/project steam"
T="$1"; PATCH="${2:-}"
bash "$D/export.sh" "$D/$T" $PATCH || exit 1
cp -r "$S/d3/fin3/project-unicorn/.godot" "$D/$T/project-unicorn/"
bash "$D/warm.sh" "$T"
