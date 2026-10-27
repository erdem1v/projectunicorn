#!/usr/bin/env bash
# Sessiz PLANMS, sıkı hâli: sessiz kilidini alır; her koşudan önce makinede Godot süreci kalmadığını üç ardışık okumayla (5 sn arayla)
# doğrular; koşu sürerken başka bir Godot görülürse koşuyu kirli sayar ve yeniden koşar (koşu başına en çok 4 deneme).
# Usage: quiet_planms2.sh <etiket> <ad=ağaç/project-unicorn>... [REPS=n env]
. "$(dirname "$0")/env.sh"
tag="$1"; shift; out="$S/planms_$tag"; mkdir -p "$out"
until lock_take sessiz "planms $tag"; do sleep 10; done
trap 'lock_drop sessiz' EXIT
echo "sessiz alındı $(date +%T)"
godots() { local n; n=$(tasklist //FI "IMAGENAME eq Godot_v4.6.2-stable_win64_console.exe" //NH 2>/dev/null | grep -ci "godot"); echo "${n:-0}"; }
quiet() {
  local ok=0 t=0
  while [ $ok -lt 3 ]; do
    if [ "$(godots)" = 0 ]; then ok=$((ok+1)); else ok=0; fi
    t=$((t+1)); [ $t -gt 720 ] && { echo "QUIET TIMEOUT"; return 1; }
    sleep 5
  done
}
for spec in "$@"; do
  name="${spec%%=*}"; tree="${spec#*=}"
  for r in $(seq "${REPS:-2}"); do
    for try in 1 2 3 4; do
      quiet || exit 9
      d="$S/appdata_planms/$tag/$name$r"; mkdir -p "$d"
      ( cd "$tree" && APPDATA="$(cygpath -w "$d")" "$GODOT" --headless --path . \
        --sprint-probe=hours=40:cards=2:ticks=60:team=50:market=b2b:planms=1 > "$out/$name$r.log" 2>&1 ) &
      pid=$!; dirty=0
      while kill -0 $pid 2>/dev/null; do [ "$(godots)" -gt 1 ] && dirty=1; sleep 2; done
      wait $pid; rc=$?
      if [ $dirty = 0 ]; then break; fi
      echo "-- $name run$r try$try kirli, yeniden"
    done
    echo "== $name run$r rc=$rc dirty=$dirty mismatch=$(grep -ac MISMATCH "$out/$name$r.log") ($(date +%T))"
    grep -a "PLANMS" "$out/$name$r.log" | sed 's/^SPRINTPROBE PLANMS|team=50|//' | grep -a 'screen'
  done
done
