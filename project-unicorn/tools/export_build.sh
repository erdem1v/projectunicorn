#!/usr/bin/env bash
# Exports one preset of export_presets.cfg to <dir>/ProjectUnicorn.exe and writes LICENSES/ beside it. Needs the
# export templates of the running Godot version; keep <dir> outside the repo.
#   tools/export_build.sh "Windows Demo" C:/Users/erdem/Desktop/unicorn_build/demo
#   GODOT=/path/to/godot tools/export_build.sh "Windows EA" <dir>

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/gate_common.sh"
mkdir -p "$2"
OUT="$(cd "$2" && pwd -W)"
"$GODOT" --headless --path "$HERE" --export-release "$1" "$OUT/ProjectUnicorn.exe"
"$GODOT" --headless --path "$HERE" -s res://scripts/debug/write_licenses.gd -- "$OUT"
