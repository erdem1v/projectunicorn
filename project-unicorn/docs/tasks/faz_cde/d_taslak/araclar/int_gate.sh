#!/usr/bin/env bash
# Faz B integration gate on the combined tree (B4, B7, B8, B5, B6a, B6b). One Godot at a time.
SP="C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad"
export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe
cd "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn" || exit 2
OUT="$SP/int_gate.out"
: > "$OUT"
say() { echo "$*" >> "$OUT"; }
ERR='Parse Error|Compile Error|SCRIPT ERROR|Failed to instantiate|Invalid call|Nonexistent function'

"$GODOT" --headless --path . --event-lint > "$SP/int_lint.log" 2>&1
say "LINT exit=$? $(grep -m1 'LINT ' "$SP/int_lint.log") errs=$(grep -cE "$ERR" "$SP/int_lint.log")"
"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd > "$SP/int_residue.log" 2>&1
say "RESIDUE exit=$? $(grep -m1 'LOC RESIDUE' "$SP/int_residue.log") errs=$(grep -cE "$ERR" "$SP/int_residue.log")"

pass=0; fail=0
for c in $(cat "$SP/int_cases.txt") promise_broken_penalty promise_orphan_no_brand_hit promise_no_duplicate_word promise_due_sprint_kept_when_shipped_next_sprint promise_due_sprint_breaks_after_close promise_relock_after_break promise_row_locked_after_break promise_row_locked_when_no_room; do
  CASE_TIMEOUT=300 bash tools/smoke_run.sh "$c" > "$SP/int_case.log" 2>&1
  rc=$?
  if [ $rc -eq 0 ] && grep -q "SMOKE PASS $c" "$SP/int_case.log"; then pass=$((pass+1)); else fail=$((fail+1)); say "CASE FAIL $c rc=$rc :: $(grep -E 'SMOKE|FAIL|ERROR' "$SP/int_case.log" | head -4 | tr '\n' ' ')"; cp "$SP/int_case.log" "$SP/int_fail_$c.log"; fi
done
say "CASES pass=$pass fail=$fail"

"$GODOT" --headless --path . --sprint-probe=hours=8:cards=2:ticks=24:events=1:market=b2b:team=4:fill=1 > "$SP/int_probe2.log" 2>&1
say "PROBE2 exit=$? $(grep -E 'PAPERSUM|SPRINTPROBE SUMMARY' "$SP/int_probe2.log" | tr '\n' ' ') errs=$(grep -cE "$ERR" "$SP/int_probe2.log")"
"$GODOT" --headless --path . --sprint-probe=hours=8:cards=2:ticks=24:events=1:market=b2b:team=4:fill=1:weeks=1 > "$SP/int_probe1.log" 2>&1
say "PROBE1 exit=$? $(grep -E 'PAPERSUM|SPRINTPROBE SUMMARY' "$SP/int_probe1.log" | tr '\n' ' ') errs=$(grep -cE "$ERR" "$SP/int_probe1.log")"

bash tools/run_gate.sh > "$SP/int_rungate.log" 2>&1
say "RUNGATE exit=$? $(grep -E 'RUN (OK|FAIL|SUMMARY)' "$SP/int_rungate.log" | tr '\n' ' ')"
JOBS=1 bash tools/plausibility_run.sh > "$SP/int_plaus.log" 2>&1
say "PLAUS exit=$? $(grep -E 'PLAUS (SUMMARY|LONG)' "$SP/int_plaus.log" | tr '\n' ' ')"

"$GODOT" --headless --path . --event-vocab > "$SP/int_vocab.log" 2>&1
say "VOCAB exit=$? $(grep -m1 'EvVocabGen' "$SP/int_vocab.log")"
python tools/gen_signal_manifest.py > "$SP/int_manifest.log" 2>&1
say "MANIFEST exit=$? $(tail -1 "$SP/int_manifest.log")"
say "INT_DONE"
