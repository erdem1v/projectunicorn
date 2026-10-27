#!/usr/bin/env bash
# Pencereli kareler, sırayla, ekran kilidiyle. Her satır "<bayrak> <dil> [ölçek]", ör. "--product-shot=live:a4_requests en 1.25".
# Usage: shots.sh <ağaç/project-unicorn> <etiket> <satır dosyası>. PNG ve log $S/shots_<etiket>/'e; özet results.txt.
. "$(dirname "$0")/env.sh"
tree="$1"; tag="$2"; list="$3"; out="$S/shots_$tag"; mkdir -p "$out"
until lock_take ekran "shots $tag"; do sleep 10; done
trap 'lock_drop ekran' EXIT
ad="$S/appdata_shots_$tag"; mkdir -p "$ad"; udir="$ad/Godot/app_userdata/Project Unicorn"
while read -r flag lang scale; do
  [ -z "$flag" ] && continue
  if [ -d "$K/sessiz" ] && ! grep -q '^URUN_ARAYUZU' "$K/sessiz/sahip" 2>/dev/null; then echo "STOP sessiz" | tee -a "$out/results.txt"; exit 99; fi
  name="$(echo "${flag#--}" | tr '=:' '__')_${lang}${scale:+_$scale}"
  extra=(--lang="$lang"); [ -n "$scale" ] && extra+=(--shot-scale="$scale")
  rm -f "$udir"/*.png
  ( cd "$tree" && APPDATA="$(cygpath -w "$ad")" timeout 300 "$GODOT" --path . --audio-driver Dummy "$flag" "${extra[@]}" > "$out/$name.log" 2>&1 ); rc=$?
  n=0; for f in "$udir"/*.png; do [ -e "$f" ] || continue; mv "$f" "$out/${name}__$(basename "$f")"; n=$((n+1)); done
  echo "SHOT|$name|rc=$rc|png=$n|script_err=$(grep -ac 'SCRIPT ERROR' "$out/$name.log")|err=$(grep -a '^ERROR' "$out/$name.log" | grep -vc 'resources still in use')|$(grep -a '^PRODUCTSHOT' "$out/$name.log" | tr -d '\r')" | tee -a "$out/results.txt"
done < "$list"
