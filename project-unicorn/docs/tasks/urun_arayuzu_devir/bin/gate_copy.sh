#!/usr/bin/env bash
# Birleşik ağacın kapı kopyası (bozulmamış m_<etiket>'e dokunmadan): g_<etiket> = m_<etiket> + work'ün .godot'u, sonra --import
# ve ısınma koşusu. Usage: gate_copy.sh <etiket>
. "$(dirname "$0")/env.sh"
tag="$1"; G="$S/g_$tag/project-unicorn"
rm -rf "$S/g_$tag"; mkdir -p "$S/g_$tag"; cp -r "$S/m_$tag/project-unicorn" "$S/g_$tag/" || exit 2
cp -r "${WORK:-$S/work/project-unicorn}/.godot" "$G/.godot" || exit 2
# Yeni yüz ve tema dosyaları m_'de yok (üretilmiş; tema üretimi sonra kurar): ısınma onlarsız düşmesin diye WORK'ünküler g_'ye.
( cd "${WORK:-$S/work/project-unicorn}" && for f in themes/*.tres assets/fonts/variations/*.tres; do cp "$f" "$G/$f"; done )
gd "gc_$tag" "$G" --headless --path . --import > "$S/g_$tag/import.log" 2>&1; echo "import rc=$?"
gd "gc_$tag" "$G" --headless --path . --quit > "$S/g_$tag/warm.log" 2>&1; echo "warm rc=$? script_err=$(grep -ac 'SCRIPT ERROR\|Parse Error' "$S/g_$tag/warm.log")"
