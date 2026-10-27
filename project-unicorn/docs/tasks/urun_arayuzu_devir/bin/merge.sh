#!/usr/bin/env bash
# ORTAK_CALISMA §3 adım 2-3: yeni HEAD'in taze dışa aktarımına kendi değişikliklerimi üç yollu birleştirir.
# Taban = $S/base (kopyanın tabanı), bizimki = $S/work, onlarınki = yeni HEAD. Çıktı $S/m_<etiket>/project-unicorn (bozulmamış),
# üretilmiş kod haritası orada yeniden üretilir. Usage: merge.sh <yeni HEAD> <etiket> <değişen-liste dosyası> [<silinen-liste dosyası>]
# Listeler project-unicorn/'a göre yol taşır (satır başına bir yol). Çakışmada 1 ile çıkar; çakışan dosyada işaretler kalır.
. "$(dirname "$0")/env.sh"
head="$1"; tag="$2"; changed="$3"; deleted="${4:-}"
B="${BASE:-$S/base/project-unicorn}"; W="${WORK:-$S/work/project-unicorn}"; M="$S/m_$tag/project-unicorn"
bash "$S/bin/export.sh" "m_$tag" "$head" >/dev/null || exit 2
GEN="docs/kod_haritasi/DIZIN.md docs/kod_haritasi/SEMBOLLER.tsv docs/kod_haritasi/KALITE.md docs/EVENT_SIGNAL_MANIFEST.md docs/content/events_draft/_vocabulary.md"
conf=0
while read -r f; do
  [ -z "$f" ] && continue
  case " $GEN " in *" $f "*) echo "GENERATED-IN-LIST $f (çıkar)"; conf=1; continue ;; esac
  case "$f" in themes/*.tres|assets/fonts/variations/*.tres) echo "GENERATED-IN-LIST $f (temayı merged ağaçta üret)"; conf=1; continue ;; esac
  if [ ! -e "$B/$f" ]; then
    if [ -e "$M/$f" ] && ! cmp -s "$M/$f" "$W/$f"; then echo "BOTH-ADDED $f"; conf=1; fi
    mkdir -p "$(dirname "$M/$f")"; cp "$W/$f" "$M/$f"; echo "new   $f"; continue
  fi
  if [ ! -e "$M/$f" ]; then echo "THEY-DELETED $f"; conf=1; continue; fi
  if cmp -s "$B/$f" "$M/$f"; then cp "$W/$f" "$M/$f"; echo "take  $f"; continue; fi
  git merge-file -p "$M/$f" "$B/$f" "$W/$f" > "$M/$f.merged"; rc=$?
  mv "$M/$f.merged" "$M/$f"
  if [ $rc -ne 0 ]; then echo "CONFLICT($rc) $f"; conf=1; else echo "merge $f"; fi
done < "$changed"
if [ -n "$deleted" ]; then
  while read -r f; do
    [ -z "$f" ] && continue
    if [ -e "$M/$f" ]; then
      if cmp -s "$B/$f" "$M/$f"; then rm "$M/$f"; echo "del   $f"; else echo "DEL-CHANGED $f (onlar değiştirmiş)"; conf=1; fi
    else echo "del?  $f (yeni HEAD'de zaten yok)"; fi
  done < "$deleted"
fi
[ $conf -ne 0 ] && { echo "MERGE: çakışma var, elle çöz, sonra: regen.sh $tag"; exit 1; }
bash "$S/bin/regen.sh" "$tag"
