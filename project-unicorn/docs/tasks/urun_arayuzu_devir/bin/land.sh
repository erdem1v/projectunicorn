#!/usr/bin/env bash
# ORTAK_CALISMA §3'ün tamamı: kapıyı bekle ve al → yeni HEAD'e birleştir → kapı kopyasında --import + ısınma + smoke →
# özel index'le commit → senkron → kapıyı bırak. Çakışma ya da kapı düşerse kilidi bırakır, commit etmez.
# Usage: land.sh <etiket> <değişen-liste> <silinen-liste|-> <mesaj> <smoke-liste dosyası|->
. "$(dirname "$0")/env.sh"
tag="$1"; changed="$2"; deleted="$3"; msg="$4"; cases="$5"
[ "$deleted" = - ] && deleted=""
[ -d "$K/ekran" ] && grep -q '^URUN_ARAYUZU' "$K/ekran/sahip" 2>/dev/null && { echo "ABORT: ekran kilidi bende, kapı istenmez"; exit 2; }
until lock_take kapi "$tag commit"; do sleep 3; done
trap 'lock_drop kapi; echo "kapı bırakıldı"' EXIT
echo "kapı alındı $(date +%T)"
cd "$R" || exit 2
old=$(git rev-parse HEAD); echo "HEAD $old"
bash "$S/bin/merge.sh" "$old" "$tag" "$changed" $deleted || { echo "STOP: birleştirme çakıştı"; exit 3; }
bash "$S/bin/gate_copy.sh" "$tag"
G="$S/g_$tag/project-unicorn"
if [ "${THEME:-0}" = 1 ]; then
  bash "$S/bin/theme_regen.sh" "$tag" > "$S/theme_$tag.txt" || { cat "$S/theme_$tag.txt"; echo "STOP: tema üretimi düştü"; exit 7; }
  grep -v '^GEN ' "$S/theme_$tag.txt"
  { cat "$changed"; sed -n 's/^GEN //p' "$S/theme_$tag.txt"; } > "$S/changed_$tag.full"; changed="$S/changed_$tag.full"
fi
if [ "$cases" != - ]; then
  P=10 bash "$S/bin/smoke.sh" "$G" "land_$tag" @"$cases" | tail -5
  pass=$(grep -c 'SMOKE PASS' "$S/smoke_land_$tag/summary.txt"); all=$(grep -c . "$cases")
  [ "$pass" = "$all" ] || { echo "STOP: kapı smoke'u düştü ($pass/$all)"; exit 4; }
fi
[ "$(git rev-parse HEAD)" = "$old" ] || { echo "STOP: HEAD kıpırdadı, yeniden koş"; exit 5; }
bash "$S/bin/commit.sh" "$tag" "$old" "$msg" "$changed" $deleted || { echo "STOP: commit.sh düştü"; exit 6; }
echo "LANDED $(git rev-parse --short HEAD) $(date +%T)"
