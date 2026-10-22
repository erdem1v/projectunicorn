#!/usr/bin/env bash
cd "/c/Users/erdem/Desktop/Project Unicorn/project-unicorn" || exit 2
P="$(pwd)"; G=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
S="$P/docs/tasks/faz_ab/a_calisma/shots/K1"; mkdir -p "$S"
ARGS=(
"--product-shot=edge:team_split"
"--product-shot=edge:team_split --lang=en"
"--product-shot=edge:team_split --palette=cb"
"--product-shot=edge:team_split --shot-scale=1.25"
"--product-shot=edge:team_none"
"--product-shot=edge:team_none --lang=en"
"--product-shot=edge:team_none --palette=cb"
"--product-shot=edge:team_none --shot-scale=1.25"
"--product-shot=edge:cap_zero"
"--product-shot=edge:cap_zero --lang=en"
"--product-shot=edge:cap_zero --palette=cb"
"--product-shot=edge:cap_zero --shot-scale=1.25"
"--product-shot=live:plan"
"--product-shot=live:plan --lang=en"
"--product-shot=live:plan --palette=cb"
"--product-shot=live:plan --shot-scale=1.25"
"--product-shot=live:rnd"
"--product-shot=live:rnd --lang=en"
"--product-shot=live:rnd --palette=cb"
"--product-shot=live:rnd --shot-scale=1.25"
"--office-shot=home:11:desk_shut"
"--office-shot=home:11:desk_shut --lang=en"
"--office-shot=home:11:desk_shut --palette=cb"
"--office-shot=home:11:desk_shut --shot-scale=1.25"
)
n=0
for a in "${ARGS[@]}"; do
  n=$((n+1)); d="$S/appdata_$n"; mkdir -p "$d/appdata" "$d/home"
  slug=$(echo "$a" | sed 's/^--//; s/--/_/g; s/[^A-Za-z0-9]\+/_/g; s/_$//')
  echo "=== SHOT $n: $a"
  APPDATA="$d/appdata" HOME="$d/home" timeout 300 "$G" --path . $a > "$S/console_$n.log" 2>&1
  echo "SHOT_EXIT $n $?"
  grep -aE "SCRIPT ERROR|ERROR" "$S/console_$n.log" | head -5 | sed "s/^/  ERRLINE $n: /"
  src="$d/appdata/Godot/app_userdata/Project Unicorn"
  for f in "$src"/*.png; do [ -f "$f" ] && cp "$f" "$S/shot_${n}_${slug}_$(basename "$f")"; done
done
echo SHOTS_DONE
