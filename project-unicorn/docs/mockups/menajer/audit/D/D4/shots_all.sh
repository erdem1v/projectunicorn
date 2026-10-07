#!/usr/bin/env bash
# shots_all.sh <tree> <outdir>: the D acceptance matrix, one windowed run at a time.
D="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/d4"
TREE="$1"; OUT="$2"
for lang in tr en; do
  for spec in "office:ishani:11" "office:home:14" "office:plaza:11" "office:loft:11" "office:meet:11" "office:city:11:card" "tab:hr" "travel:ishani"; do
    kind="${spec%%:*}"; arg="${spec#*:}"
    flag="--${kind}-shot=${arg}"
    tag="$(echo "$arg" | tr ':' '_')"
    "$D/shot.sh" "$TREE" "$OUT/1920x1080" "$tag" $lang "$flag"
    "$D/shot.sh" "$TREE" "$OUT/1536x864" "$tag" $lang "$flag" --shot-scale=1.25
  done
  for spec in "office:ishani:11" "tab:hr"; do
    kind="${spec%%:*}"; arg="${spec#*:}"
    flag="--${kind}-shot=${arg}"
    tag="$(echo "$arg" | tr ':' '_')"
    "$D/shot.sh" "$TREE" "$OUT/1920x1200" "$tag" $lang "$flag" --shot-size=1920x1200
    "$D/shot.sh" "$TREE" "$OUT/1536x960" "$tag" $lang "$flag" --shot-size=1920x1200 --shot-scale=1.25
    "$D/shot.sh" "$TREE" "$OUT/2560x1080" "$tag" $lang "$flag" --shot-size=2560x1080
  done
done
