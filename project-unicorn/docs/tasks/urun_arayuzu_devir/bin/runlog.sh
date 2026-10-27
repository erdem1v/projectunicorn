#!/usr/bin/env bash
# İki 104 haftalık koşu paralel: full_run ve full_run_b2c, tohum 1, --lang=tr. Usage: runlog.sh <ağaç/project-unicorn> <etiket>
. "$(dirname "$0")/env.sh"
tree="$1"; tag="$2"; out="$S/runlog_$tag"; mkdir -p "$out"
one() { p="$1"; d="$S/appdata_rl/$tag/$p"; mkdir -p "$d"
  ( cd "$tree" && APPDATA="$(cygpath -w "$d")" timeout 3000 "$GODOT" --headless --path . --lang=tr --run-log=$p:104:sim:1 > "$out/$p.log" 2>&1 )
  e=$(grep -a '^PROBE END' "$out/$p.log" | head -1)
  echo "$p rc=$? end_lines=$(grep -ac '^PROBE END' "$out/$p.log") errors=$(grep -ac '^ERROR\|SCRIPT ERROR' "$out/$p.log") broken=$(grep -a '^PROBE PROMISE' "$out/$p.log" | grep -ac 'status=broken') :: ${e:0:300}"; }
export -f one; export S tag out tree GODOT
mem_ok || exit 98
printf '%s\n' full_run full_run_b2c | xargs -P 2 -I{} bash -c 'one {}'
