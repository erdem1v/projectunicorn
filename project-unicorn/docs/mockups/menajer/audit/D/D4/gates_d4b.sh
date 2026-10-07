#!/usr/bin/env bash
# gates.sh <patch>: tree "final2" = HEAD + patch through a private index; import, warm-up, theme regeneration
# (must be byte-identical), theme checks, contrast, glyphs, lint, loc gates, targeted smoke, signal manifest.
set -uo pipefail
D="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/d4"
GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
REPO="C:/Users/erdem/Desktop/project steam"
PATCH="$1"
echo "HEAD $(git -C "$REPO" rev-parse --short HEAD)"
bash "$D/prep.sh" final2 "$PATCH"
cd "$D/final2/project-unicorn"
A() { mkdir -p "$D/app_final2_$1"; echo "$(cygpath -w "$D/app_final2_$1")"; }
export GIT_INDEX_FILE="$D/final2.idx"; rm -f "$GIT_INDEX_FILE"; git -C "$REPO" read-tree HEAD; git -C "$REPO" apply --cached "$PATCH"
echo "tree vs HEAD+patch before gates: $(git -C "$REPO" --work-tree="$D/final2" diff --stat -- . ':!project-unicorn/project.godot' | wc -l) differing lines"
unset GIT_INDEX_FILE
rm -rf "$D/themes_before"; cp -r themes "$D/themes_before"; rm -rf "$D/fontvar_before"; cp -r assets/fonts/variations "$D/fontvar_before"
APPDATA="$(A gen)" timeout 300 "$GODOT" --headless --path . -s res://scripts/theme/build_theme.gd > "$D/logs/final2_build_theme.log" 2>&1; echo "build_theme exit=$? themes_diff=$(diff -r "$D/themes_before" themes | wc -l) fontvar_diff=$(diff -r "$D/fontvar_before" assets/fonts/variations | wc -l)"
APPDATA="$(A tc)" timeout 300 "$GODOT" --headless --path . -s res://scripts/theme/theme_check.gd --theme=res://themes/menajer_theme.tres > "$D/logs/final2_check_menajer.log" 2>&1; echo "theme_check menajer exit=$? $(grep RESULT "$D/logs/final2_check_menajer.log")"
APPDATA="$(A tc)" timeout 300 "$GODOT" --headless --path . -s res://scripts/theme/theme_check.gd > "$D/logs/final2_check_master.log" 2>&1; echo "theme_check master exit=$? $(grep RESULT "$D/logs/final2_check_master.log")"
APPDATA="$(A tc)" timeout 300 "$GODOT" --headless --path . --theme-contrast-audit > "$D/logs/final2_contrast.log" 2>&1; echo "contrast exit=$? $(grep RESULT "$D/logs/final2_contrast.log")"
APPDATA="$(A tc)" timeout 300 "$GODOT" --headless --path . -s res://scripts/debug/glyph_audit.gd > "$D/logs/final2_glyph.log" 2>&1; echo "glyph_audit exit=$? miss=$(grep -c 'GLYPH|MISS' "$D/logs/final2_glyph.log") $(grep -E 'RESULT|SUMMARY' "$D/logs/final2_glyph.log" | tail -1)"
APPDATA="$(A lint)" timeout 600 "$GODOT" --headless --path . --event-lint > "$D/logs/final2_lint.log" 2>&1; echo "event-lint exit=$?"
APPDATA="$(A res)" timeout 600 "$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd > "$D/logs/final2_residue.log" 2>&1; echo "loc_residue exit=$? $(grep -E 'RESIDUE|residue|TOTAL' "$D/logs/final2_residue.log" | tail -2 | tr '\n' ' ')"
for c in loc_csv_integrity rail_tabs_match_scene_order rnd_rail_open_with_waiting_page topbar_speed_cluster_four_rungs ui_scale_ladder_fits_settings all_scripts_load ending_paper_modes_on_screen frank_line_renders_outside_the_paper menu_has_one_path vacation_action_retired milestone_paper_under_card office_move_gates_and_save; do
  APPDATA="$(A $c)" CASE_TIMEOUT=300 GODOT="$GODOT" bash tools/smoke_run.sh $c > "$D/logs/final2_smoke_$c.log" 2>&1
  echo "smoke $c: $(tail -1 "$D/logs/final2_smoke_$c.log") engine_errors=$(grep -cE 'Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR' "$D/logs/final2_smoke_$c.log")"
done
cp docs/EVENT_SIGNAL_MANIFEST.md "$D/manifest_before.md"
PYTHONIOENCODING=utf-8 python tools/gen_signal_manifest.py > "$D/logs/final2_manifest.log" 2>&1
echo "signal manifest vs patch (date line excluded): $(diff <(grep -v '^Last generated' "$D/manifest_before.md") <(grep -v '^Last generated' docs/EVENT_SIGNAL_MANIFEST.md) | wc -l) lines"
cp "$D/manifest_before.md" docs/EVENT_SIGNAL_MANIFEST.md
export GIT_INDEX_FILE="$D/final2.idx"
echo "tree vs HEAD+patch after gates: $(git -C "$REPO" --work-tree="$D/final2" diff --stat -- . ':!project-unicorn/project.godot' | wc -l) differing lines"
unset GIT_INDEX_FILE; rm -f "$D/final2.idx"
