#!/usr/bin/env bash
# Runs capture_menajer.gd through the UI Lab wrapper against a HEAD snapshot of the project.
#   run_capture.sh <run_id> <timeout_s> <flags...>
# Why a snapshot: another session edits tracked scripts in the live checkout, and its
# uncommitted work in progress does not compile (game_state.gd / main.gd failed on 2026-10-02).
# The snapshot (scratchpad/snap/project-unicorn) is the live folder copied once with robocopy
# (docs, sandbox, GDDs left out) and every file `git diff --name-only HEAD` lists put back to its
# HEAD blob with `git show` (read only). This script copies the mockup tools into it before
# each run. Output paths in capture_menajer.gd are absolute, into docs/mockups/menajer.
set -u
SP="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad"
SNAP="$SP/snap/project-unicorn"
HERE="C:/Users/erdem/Desktop/project steam/project-unicorn/docs/mockups/menajer/tools"
RUN_ID="$1"; TMO="$2"; shift 2
mkdir -p "$SNAP/docs/mockups/menajer/tools"
cp "$HERE"/*.gd "$SNAP/docs/mockups/menajer/tools/"
UILAB_ALLOW='^\?\? project-unicorn/(sandbox/|docs/audits/|docs/mockups/)' bash "$SP/ui_lab/run_godot.sh" "$RUN_ID" "$TMO" menajer \
	"$SP/logs/$RUN_ID.log" --path "$SNAP" -s "$SNAP/docs/mockups/menajer/tools/capture_menajer.gd" "$@" \
	--windowed --resolution 1600x900 --audio-driver Dummy
CODE=$?
grep -E "MENAJER\||SCRIPT ERROR|^ERROR" "$SP/logs/$RUN_ID.log" | grep -v "MENAJER|SAVED" | head -60
exit $CODE
