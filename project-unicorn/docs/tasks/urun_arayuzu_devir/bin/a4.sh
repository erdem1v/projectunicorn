#!/usr/bin/env bash
# 23 live:a4_* dünyası, pencereli, sırayla; ekran kilidiyle. PNG ve log $S/a4_<etiket>/<dil>/'e. Satırlar results.txt'e.
# Usage: a4.sh <ağaç/project-unicorn> <etiket> <tr|en> [tür...]   (tür verilmezse 23'ü)
. "$(dirname "$0")/env.sh"
tree="$1"; tag="$2"; lang="$3"; shift 3
KINDS=(${@:-a4_solo a4_devs3 a4_six_hover a4_six_pm5 a4_six_pm2 a4_eleven a4_eleven_streak a4_two_pm a4_fifty a4_run_w2 a4_eleven_tip a4_twelve_dev a4_fourteen a4_requests a4_empty a4_run_end a4_next_prefilled a4_early a4_first_sprint a4_first_next a4_six_founder_off a4_six_meetings2 a4_run_table})
out="$S/a4_$tag/$lang"; mkdir -p "$out"
lock_take ekran "a4 $tag $lang" || { echo "EKRAN BUSY: $(cat "$K/ekran/sahip" 2>/dev/null)"; exit 97; }
trap 'lock_drop ekran' EXIT
ad="$S/appdata_a4_$tag"; mkdir -p "$ad"; udir="$ad/Godot/app_userdata/Project Unicorn"
for k in "${KINDS[@]}"; do
  if [ -d "$K/sessiz" ] && ! grep -q '^URUN_ARAYUZU' "$K/sessiz/sahip" 2>/dev/null; then echo "STOP sessiz before $k" | tee -a "$out/results.txt"; exit 99; fi
  mem_ok || { echo "STOP memory before $k" | tee -a "$out/results.txt"; exit 98; }
  rm -f "$udir"/*.png
  ( cd "$tree" && APPDATA="$(cygpath -w "$ad")" timeout 300 "$GODOT" --path . --audio-driver Dummy --product-shot=live:$k --lang=$lang > "$out/$k.log" 2>&1 ); rc=$?
  n=0; for f in "$udir"/*.png; do [ -e "$f" ] || continue; mv "$f" "$out/${k}__$(basename "$f")"; n=$((n+1)); done
  shot=$(grep -a "^PRODUCTSHOT" "$out/$k.log" | tr -d '\r' | tr '\n' ' ')
  echo "RESULT|$k|$lang|rc=$rc|png=$n|errors=$(grep -a -c 'SCRIPT ERROR\|^ERROR:' "$out/$k.log")|rid=$(grep -a -c 'RID allocations' "$out/$k.log")|${shot:-NO_PRODUCTSHOT}" | tee -a "$out/results.txt"
done
