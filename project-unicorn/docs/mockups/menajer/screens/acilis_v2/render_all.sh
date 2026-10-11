#!/usr/bin/env bash
D="$(cd "$(dirname "$0")" && pwd)"
R="$D/../../tools/render.sh"
names="$@"; [ -z "$names" ] && names=$(cd "$D" && ls [0-9]*.html | sed 's/\.html$//')
for n in $names; do
  if [[ "$n" == *_1536 ]]; then bash "$R" "$D/$n.html" "$D/$n.png" 1536 864 1.25 >/dev/null || echo "FAIL $n" &
  else bash "$R" "$D/$n.html" "$D/$n.png" 1920 1080 >/dev/null || echo "FAIL $n" & fi
done
wait
