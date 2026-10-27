#!/usr/bin/env bash
# Sessiz PLANMS: sessiz kilidini alır, makinede Godot süreci kalmayana dek bekler (en çok 30 dk), sonra verilen ağaçlarda
# sırayla `--sprint-probe=hours=40:cards=2:ticks=60:team=50:market=b2b:planms=1` koşar (her biri 9 ölçüm), kilidi bırakır.
# Usage: quiet_planms.sh <etiket> <ad=ağaç/project-unicorn>... [REPS=n env: her ağaç kaç koşu]
. "$(dirname "$0")/env.sh"
tag="$1"; shift; out="$S/planms_$tag"; mkdir -p "$out"
until lock_take sessiz "planms $tag"; do sleep 10; done
trap 'lock_drop sessiz' EXIT
echo "sessiz alındı $(date +%T)"
godots() { tasklist 2>/dev/null | grep -ci "godot"; }
for _ in $(seq 180); do [ "$(godots)" = 0 ] && break; sleep 10; done
echo "godot süreçleri: $(godots) $(date +%T)"
for spec in "$@"; do
  name="${spec%%=*}"; tree="${spec#*=}"
  for r in $(seq "${REPS:-2}"); do
    d="$S/appdata_planms/$tag/$name$r"; mkdir -p "$d"
    ( cd "$tree" && APPDATA="$(cygpath -w "$d")" "$GODOT" --headless --path . \
      --sprint-probe=hours=40:cards=2:ticks=60:team=50:market=b2b:planms=1 > "$out/$name$r.log" 2>&1 )
    echo "== $name run$r rc=$? mismatch=$(grep -ac MISMATCH "$out/$name$r.log") ($(date +%T))"
    grep -a "PLANMS" "$out/$name$r.log" | sed 's/^SPRINTPROBE PLANMS|team=50|//'
  done
done
