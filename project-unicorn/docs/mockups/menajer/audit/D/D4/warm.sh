#!/usr/bin/env bash
# warm.sh <tree>: --import, restore project.godot, warm-up run; engine error counts.
set -uo pipefail
S="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad"
D="$S/d4"; GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
REPO="C:/Users/erdem/Desktop/project steam"
T="$1"
mkdir -p "$D/app_${T}_imp" "$D/app_${T}_warm"
cd "$D/$T/project-unicorn"
cp project.godot "$D/logs/${T}_project.godot.keep"
APPDATA="$(cygpath -w "$D/app_${T}_imp")" timeout 900 "$GODOT" --headless --path . --import > "$D/logs/${T}_import.log" 2>&1; echo "import exit=$?"
cp "$D/logs/${T}_project.godot.keep" project.godot
APPDATA="$(cygpath -w "$D/app_${T}_warm")" timeout 300 "$GODOT" --headless --path . --quit-after 120 > "$D/logs/${T}_warm.log" 2>&1; echo "warm exit=$?"
echo "engine errors: $(grep -cE 'SCRIPT ERROR|Parse Error|Compile Error|Failed to instantiate|Failed to load script' "$D/logs/${T}_import.log" "$D/logs/${T}_warm.log" | tr '\n' ' ')"
