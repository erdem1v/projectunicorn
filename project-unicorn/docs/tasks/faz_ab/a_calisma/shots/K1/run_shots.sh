#!/usr/bin/env bash
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
PROJ="/c/Users/erdem/Desktop/Project Unicorn/project-unicorn"
A="$PROJ/docs/tasks/faz_ab/a_calisma"
S="$A/shots/K1"
cd "$PROJ" || exit 2
CMDS=(
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
for c in "${CMDS[@]}"; do
  n=$((n+1))
  name=$(echo "$c" | sed -E 's/^--(product|office)-shot=//; s/--//g; s/=/-/g; s/ +/_/g; s/:/-/g')
  app="$S/appdata_$n"; mkdir -p "$app/home"
  APPDATA="$app" HOME="$app/home" timeout 300 "$GODOT" --path . $c > "$S/$n-$name.console.log" 2>&1
  ex=$?
  src="$app/Godot/app_userdata/Project Unicorn"
  cnt=0
  for f in "$src"/*.png; do
    [ -e "$f" ] || continue
    b=$(basename "$f"); cp "$f" "$S/$n-$name-$b"; cnt=$((cnt+1))
  done
  echo "$n [$c] exit=$ex png=$cnt errlines=$(grep -cE 'ERROR' "$S/$n-$name.console.log")" >> "$S/_shots_summary.txt"
done
echo SHOTS_DONE >> "$S/_shots_summary.txt"
