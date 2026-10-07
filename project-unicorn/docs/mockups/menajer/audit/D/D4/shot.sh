#!/usr/bin/env bash
# shot.sh <tree> <outdir> <tag> <lang> <args...>: one windowed run; new PNGs land in <outdir> as <tag>__<png>.
set -u
D="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/d4"
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
TREE="$1"; OUT="$2"; TAG="$3"; LANG_="$4"; shift 4
APP="$D/app_shot_$TREE"
USERDIR="$APP/Godot/app_userdata/Project Unicorn"
mkdir -p "$USERDIR" "$OUT" "$D/logs"
touch "$D/logs/.mark"; sleep 1
LOG="$D/logs/shot_${TREE}_$(basename "$OUT")_${TAG}_${LANG_}.log"
cd "$D/$TREE/project-unicorn"
APPDATA="$(cygpath -w "$APP")" timeout 300 "$GODOT" --path . "$@" --lang=$LANG_ --audio-driver Dummy > "$LOG" 2>&1
code=$?
errs=$(grep -cE "SCRIPT ERROR|^ERROR|Parse Error|Failed to load|WARNING: Nodes with" "$LOG")
n=0
while IFS= read -r -d '' f; do
  cp "$f" "$OUT/${TAG}__$(basename "$f")"; n=$((n+1))
done < <(find "$USERDIR" -maxdepth 1 -name "*.png" -newer "$D/logs/.mark" -print0)
echo "SHOT|$TREE|$TAG|$LANG_|exit=$code|errors=$errs|pngs=$n"
