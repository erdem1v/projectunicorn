#!/usr/bin/env bash
# ORTAK_CALISMA §3 adım 5-7: özel index'le commit, karşılaştırmalı update-ref, paylaşılan index'i ve ağacı kendi yollarım için
# senkronlar. Kapı kilidi bende olmalı. Usage: commit.sh <etiket> <eski HEAD (birleştirmenin tabanı)> <mesaj dosyası>
#   <değişen-liste> [<silinen-liste>]   (yollar project-unicorn/'a göre; üretilmiş kod haritası kendiliğinden eklenir)
. "$(dirname "$0")/env.sh"
tag="$1"; old="$2"; msg="$3"; changed="$4"; deleted="${5:-}"
M="$S/m_$tag/project-unicorn"; X="$S/x_$tag"; PFX=project-unicorn
[ -f "$K/kapi/sahip" ] && grep -q '^URUN_ARAYUZU' "$K/kapi/sahip" || { echo "ABORT: kapı kilidi bende değil"; exit 2; }
cd "$R" || exit 2
oldfull=$(git rev-parse "$old") || exit 2
[ "$(git rev-parse HEAD)" = "$oldfull" ] || { echo "ABORT: HEAD $(git rev-parse --short HEAD) != $old; adım 2'ye dön"; exit 4; }
paths=$(cat "$changed"; for g in DIZIN.md SEMBOLLER.tsv KALITE.md; do
  f="docs/kod_haritasi/$g"; h=$(git rev-parse -q --verify "$oldfull:$PFX/$f") && [ "$(git hash-object --path="$PFX/$f" "$M/$f")" != "$h" ] && echo "$f"
done)
export GIT_INDEX_FILE="$S/idx_$tag"; rm -f "$GIT_INDEX_FILE"
git read-tree "$oldfull" || exit 5
for f in $paths; do
  b=$(git hash-object -w --path="$PFX/$f" "$M/$f") || exit 5
  mode=$(git ls-tree "$oldfull" -- "$PFX/$f" | cut -d' ' -f1); mode=${mode:-100644}
  git update-index --add --cacheinfo "$mode,$b,$PFX/$f" || exit 5
done
[ -n "$deleted" ] && while read -r f; do [ -n "$f" ] && { git update-index --force-remove "$PFX/$f" || exit 5; }; done < "$deleted"
want=$( { for f in $paths; do echo "$PFX/$f"; done; [ -n "$deleted" ] && sed "/^$/d; s|^|$PFX/|" "$deleted"; } | sort -u)
got=$(git diff --cached --name-only "$oldfull" | sort -u)
if [ "$want" != "$got" ]; then echo "ABORT doğrulama 1: liste farklı"; diff <(echo "$want") <(echo "$got"); unset GIT_INDEX_FILE; exit 6; fi
echo "doğrulama 1: $(echo "$got" | wc -l) yol bire bir"
rm -rf "$X"; mkdir -p "$X"
git -c core.longpaths=true checkout-index -a --prefix="$X/" || exit 7
if ! diff -r "$X/$PFX" "$M" > "$S/verify2_$tag.txt" 2>&1; then echo "ABORT doğrulama 2: checkout-index ≠ birleşik ağaç"; head -20 "$S/verify2_$tag.txt"; unset GIT_INDEX_FILE; exit 7; fi
echo "doğrulama 2: checkout-index = birleşik ağaç"
tree=$(git write-tree) || exit 8
new=$(git commit-tree "$tree" -p "$oldfull" -F "$msg") || exit 8
unset GIT_INDEX_FILE
git update-ref refs/heads/main "$new" "$oldfull" || { echo "ABORT: update-ref reddetti (HEAD kıpırdadı); adım 2'ye dön"; exit 9; }
echo "COMMIT $new"
# Adım 7: ortak index ve paylaşılan ağaç, yalnız kendi yollarım.
allp=$( { for f in $paths; do echo "$PFX/$f"; done; [ -n "$deleted" ] && sed "/^$/d; s|^|$PFX/|" "$deleted"; } )
git reset -q -- $allp
for p in $allp; do
  w="$R/$p"
  if git cat-file -e "$new:$p" 2>/dev/null; then
    if [ ! -e "$w" ]; then
      if git cat-file -e "$oldfull:$p" 2>/dev/null; then echo "LIST  $p (paylaşılan ağaçta yok)"; continue; fi
      mkdir -p "$(dirname "$w")"; git cat-file blob "$new:$p" > "$w"; echo "new   $p"; continue
    fi
    if git cat-file -e "$oldfull:$p" 2>/dev/null && [ "$(git hash-object --path="$p" "$w")" = "$(git rev-parse "$oldfull:$p")" ]; then
      git cat-file blob "$new:$p" > "$w"; echo "copy  $p"
    else
      echo "LIST  $p (paylaşılan ağaçta başkasının değişikliği; dokunulmadı)"
    fi
  else
    if [ -e "$w" ] && [ "$(git hash-object --path="$p" "$w")" = "$(git rev-parse "$oldfull:$p")" ]; then
      mv "$w" "$S/trash_$(echo "$p" | tr '/' '_')"; echo "del   $p"
    elif [ -e "$w" ]; then echo "LIST  $p (silinecekti ama paylaşılan ağaçta değişmiş)"; fi
  fi
done
echo "SYNC done; git status (yollarım):"; git status --short -- $allp
