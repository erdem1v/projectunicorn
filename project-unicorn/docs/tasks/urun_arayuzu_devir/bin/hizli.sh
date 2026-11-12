#!/usr/bin/env bash
# ORTAK_CALISMA §3 adım 4'ün hızlı katmanı (test planı T-2): birleşik ağacın kapı kopyasında `tools/test.sh hizli` (K0 +
# K2). Yeşilse `g_<etiket>/hizli.ok` yazılır: 1. satır birleştirmenin tabanı olan HEAD, 2. satır test.sh'in yeşil satırı.
# commit.sh bu kaydı ister; kayıt yoksa ya da başka bir HEAD'e aitse commit etmez.
# Kırmızıda kırmızının kimin olduğunu ayırır: aynı hizli HEAD'in taze dışa aktarımında da koşar. HEAD de kırmızıysa
# "KIRMIZI-HEAD" (kırık yapı: yardımcı yönetmene yazılır, HEAD'i kıranın düzeltmesi dışında kimse commit'lemez); yalnız
# birleşik ağaç kırmızıysa "KIRMIZI-BENIM" (oturum düzeltir).
# Kapı kilidi çağıranda olmalı; hizli başsızdır (§4: kapı tutarken yalnız başsız koşu), ekran kilidi gerekmez.
# Usage: hizli.sh <etiket> <birleştirmenin tabanı olan HEAD>      Exit: 0 yeşil · 1 kırmızı · 2 düzen sorunu
. "$(dirname "$0")/env.sh"
tag="$1"; head=$(git -C "$R" rev-parse "$2") || exit 2; G="$S/g_$tag/project-unicorn"
[ -d "$G" ] || { echo "hizli: kapı kopyası yok ($G); önce gate_copy.sh"; exit 2; }
rm -f "$S/g_$tag/hizli.ok"
out=$(cd "$G" && GODOT="$GODOT" bash tools/test.sh hizli 2>&1); rc=$?
echo "$out" > "$S/g_$tag/hizli.txt"
echo "$out" | head -1
if [ $rc -eq 0 ]; then
  printf '%s\n%s\n' "$head" "$(echo "$out" | head -1)" > "$S/g_$tag/hizli.ok"
  exit 0
fi
[ $rc -eq 2 ] && { echo "$out" | tail -5; exit 2; }
echo "$out" | sed -n '2,31p'
# Kimin kırmızısı: HEAD'in taze dışa aktarımında aynı hizli (kapı kopyasının .godot'u taban alınır, --import günceller).
H="$S/h_$tag/project-unicorn"
bash "$S/bin/export.sh" "h_$tag" "$head" > /dev/null || { echo "hizli: HEAD dışa aktarılamadı"; exit 2; }
cp -r "$G/.godot" "$H/.godot" || exit 2
gd "hc_$tag" "$H" --headless --path . --import > "$S/h_$tag/import.log" 2>&1
[ $? -eq 99 ] && { echo "hizli: sessiz başkasında, HEAD'in sınaması yapılmadı; kırmızının kimin olduğu belli değil"; exit 2; }
hout=$(cd "$H" && GODOT="$GODOT" bash tools/test.sh hizli 2>&1); hrc=$?
echo "$hout" > "$S/h_$tag/hizli.txt"
first=$(echo "$out" | sed -n '2p')
if [ $hrc -ne 0 ]; then
  echo "KIRMIZI-HEAD $(git -C "$R" rev-parse --short "$head"): $(echo "$hout" | sed -n '2p')"
else
  echo "KIRMIZI-BENIM $tag: $first"
fi
exit 1
