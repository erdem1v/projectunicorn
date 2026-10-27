#!/usr/bin/env bash
# Paralel smoke: smoke.sh <ağaç/project-unicorn> <etiket> <vaka|@listedosyası>...  (P=6 varsayılan; her vaka kendi APPDATA'sı)
. "$(dirname "$0")/env.sh"
tree="$1"; tag="$2"; shift 2
out="$S/smoke_$tag"; rm -rf "$out"; mkdir -p "$out"
cases=(); for a in "$@"; do if [ "${a:0:1}" = @ ]; then mapfile -t -O "${#cases[@]}" cases < "${a:1}"; else cases+=("$a"); fi; done
if [ -d "$K/sessiz" ] && ! grep -q '^URUN_ARAYUZU' "$K/sessiz/sahip" 2>/dev/null; then echo "WAIT sessiz"; exit 99; fi
mem_ok || exit 98
run1() {
  c="$1"; d="$S/appdata_smoke/$tag/$c"; mkdir -p "$d"
  APPDATA="$(cygpath -w "$d")" CASE_TIMEOUT=300 GODOT="$GODOT" bash "$tree/tools/smoke_run.sh" "$c" > "$out/$c.log" 2>&1
  echo "$(tail -1 "$out/$c.log" | tr -d '\r') [$c]"
}
export -f run1; export S tag out tree GODOT
printf '%s\n' "${cases[@]}" | xargs -P "${P:-6}" -I{} bash -c 'run1 {}' | tee "$out/summary.txt" | grep -v "SMOKE PASS" 
echo "SMOKE $tag: $(grep -c 'SMOKE PASS' "$out/summary.txt")/${#cases[@]} pass"
