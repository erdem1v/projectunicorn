#!/usr/bin/env bash
# ORTAK_CALISMA §3 adım 3, temalar: THEME_STAMP = HEAD + 1 (m_ ve g_ ağaçlarında), build_theme kapı kopyasında (g_<etiket>)
# koşar, theme_check iki temada; üretilen themes/*.tres ve assets/fonts/variations/*.tres bozulmamış m_<etiket>'e kopyalanır,
# kod haritası yeniden üretilir. HEAD'den farklı üretilmiş yollar stdout'un "GEN <yol>" satırlarıdır. Usage: theme_regen.sh <etiket>
. "$(dirname "$0")/env.sh"
tag="$1"; M="$S/m_$tag/project-unicorn"; G="$S/g_$tag/project-unicorn"; PFX=project-unicorn
head_stamp=$(cd "$R" && git show HEAD:$PFX/scripts/theme/ui_tokens.gd | sed -n 's/^const THEME_STAMP := \([0-9]*\).*/\1/p')
[ -n "$head_stamp" ] || { echo "THEME FAIL: HEAD stamp okunamadı"; exit 3; }
new=$((head_stamp + 1))
for t in "$M" "$G"; do
  sed -i "s/^const THEME_STAMP := [0-9]*/const THEME_STAMP := $new/" "$t/scripts/theme/ui_tokens.gd"
done
echo "stamp $head_stamp -> $new"
gd "th_$tag" "$G" --headless --path . -s res://scripts/theme/build_theme.gd > "$S/g_$tag/build_theme.log" 2>&1 || { echo "THEME FAIL: build_theme"; tail -5 "$S/g_$tag/build_theme.log"; exit 4; }
for th in master_theme menajer_theme; do
  gd "th_$tag" "$G" --headless --path . -s res://scripts/theme/theme_check.gd --theme=res://themes/$th.tres > "$S/g_$tag/tc_$th.log" 2>&1 \
    || { echo "THEME FAIL: theme_check $th"; tail -5 "$S/g_$tag/tc_$th.log"; exit 5; }
done
echo "theme_check ok"
cd "$G" || exit 2
for f in themes/*.tres assets/fonts/variations/*.tres; do
  cmp -s "$f" "$M/$f" || { mkdir -p "$(dirname "$M/$f")"; cp "$f" "$M/$f"; }
  h=$(cd "$R" && git rev-parse -q --verify "HEAD:$PFX/$f")
  [ "$(cd "$R" && git hash-object --path="$PFX/$f" "$M/$f")" != "$h" ] && echo "GEN $f"
done
bash "$S/bin/regen.sh" "$tag" >/dev/null && echo "regen ok"
