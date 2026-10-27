#!/usr/bin/env bash
# git archive <rev> → $S/<name>/project-unicorn (+ paylaşılan ağacın .godot'u, --godot ile). Usage: export.sh <name> <rev> [--godot]
. "$(dirname "$0")/env.sh"
name="$1"; rev="$2"
rm -rf "$S/$name"; mkdir -p "$S/$name"
( cd "$R" && git -c core.longpaths=true archive "$rev" ) | tar -x -C "$S/$name" || exit 2
[ "${3:-}" = --godot ] && cp -r "$R/project-unicorn/.godot" "$S/$name/project-unicorn/.godot"
echo "exported $rev -> $S/$name"
