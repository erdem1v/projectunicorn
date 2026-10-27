#!/usr/bin/env bash
# Z6: sprint probe 1/3/6/12/25/50 + b2b iki görüşme; ^SPRINTPROBE (PLANMS hariç) satırları. Paralel, her koşu kendi APPDATA'sı.
# Usage: z6.sh <ağaç/project-unicorn> <etiket>
. "$(dirname "$0")/env.sh"
tree="$1"; label="$2"; out="$S/z6_$label"; rm -rf "$out"; mkdir -p "$out"
mem_ok || exit 98
one() {
  n="$1"; t="$2"; ex="$3"; tag="$n${ex:+_b2b}"; d="$S/appdata_z6/$label/$tag"; mkdir -p "$d"
  ( cd "$tree" && APPDATA="$(cygpath -w "$d")" timeout 900 "$GODOT" --headless --path . --sprint-probe=hours=40:cards=2:ticks=$t:team=$n:fill=1:events=1$ex > "$out/probe_$tag.log" 2>&1 ); rc=$?
  grep -a '^SPRINTPROBE' "$out/probe_$tag.log" | grep -av '^SPRINTPROBE PLANMS' > "$out/lines_$tag.txt"
  echo "team=$tag rc=$rc lines=$(wc -l < "$out/lines_$tag.txt") script_err=$(grep -ac 'SCRIPT ERROR' "$out/probe_$tag.log") unnamed=$(grep -a MISMATCH "$out/probe_$tag.log" | grep -avc 'cause=')"
}
export -f one; export S label out tree GODOT
printf '%s\n' "1 60" "3 60" "6 60" "12 40" "25 30" "50 24" "3 60 :market=b2b:meetings=2" | xargs -P 7 -I{} bash -c 'one {}' | sort
