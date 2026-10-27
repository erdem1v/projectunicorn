#!/usr/bin/env bash
# Ortak kapılar: event-lint → loc_residue → loc_csv_integrity → all_scripts_load. Usage: common_gates.sh <ağaç/project-unicorn> <etiket>
. "$(dirname "$0")/env.sh"
tree="$1"; tag="$2"; out="$S/gates_$tag"; mkdir -p "$out"
gd "g_$tag" "$tree" --headless --path . --event-lint > "$out/lint.log" 2>&1; echo "lint rc=$? $(grep -a -iE 'summary|findings|error' "$out/lint.log" | tail -2 | tr '\n' ' ')"
gd "g_$tag" "$tree" --headless --path . -s res://scripts/debug/loc_residue.gd > "$out/residue.log" 2>&1; echo "loc_residue rc=$? $(tail -2 "$out/residue.log" | tr '\n' ' ')"
bash "$S/bin/smoke.sh" "$tree" "${tag}_common" loc_csv_integrity all_scripts_load | tail -3
