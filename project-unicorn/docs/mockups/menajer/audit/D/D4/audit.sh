#!/usr/bin/env bash
# audit.sh <tree> <outdir> <spec...>: one windowed --theme-audit run per spec, sequential.
set -uo pipefail
D="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/d4"
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
TREE="$1"; OUT="$2"; shift 2
mkdir -p "$OUT"
for spec in "$@"; do
  name="${spec//:/_}"
  app="$D/app_audit_$TREE"; rm -rf "${app:?}"; mkdir -p "$app"
  if [ "$spec" = probe ]; then flag="--probe-shot"; elif [ "$spec" = probe_menajer ]; then flag="--probe-shot=menajer"; elif [ "$spec" = probe_kit ]; then flag="--probe-shot=kit"; else flag="--theme-audit=$spec"; fi
  (cd "$D/$TREE/project-unicorn" && APPDATA="$(cygpath -w "$app")" timeout 180 "$GODOT" --path . "$flag" --lang=tr --audio-driver Dummy > "$OUT/$name.log" 2>&1)
  ex=$?
  tr -d '\r' < "$OUT/$name.log" | awk '/^(AUDIT|PROBE)_BEGIN/{on=1} on{print} /^(AUDIT|PROBE)_END/{on=0}' > "$OUT/$name.txt"
  errs=$(grep -cE "SCRIPT ERROR|Parse Error|Compile Error|Failed to instantiate|Failed to load script" "$OUT/$name.log")
  echo "$spec exit=$ex lines=$(wc -l < "$OUT/$name.txt") engine_errors=$errs"
done
