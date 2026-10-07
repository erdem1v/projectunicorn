#!/usr/bin/env bash
# Played-run gate: three full runs must each reach an ending and carry no error line.
#
# RunProbe prints a ledger and exits 0 whatever happened, and its fixture presets (b2b_*, b2c*)
# legitimately finish with no ending, so "the run ended cleanly" is judged here, on the output.
# The ending id itself is not asserted; any ending is a finished run.
#
#   tools/run_gate.sh
#   WEEKS=5 tools/run_gate.sh        a run cut short has no ending, so all three FAIL
#   WEEKS=730 RUN_TIMEOUT=900 GODOT=/path/to/godot tools/run_gate.sh   (the defaults)
#
# Exit: 0 all green · 1 a run failed · 2 harness problem.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/gate_common.sh"
WEEKS="${WEEKS:-730}"
RUN_TIMEOUT="${RUN_TIMEOUT:-900}"
PRESETS=(full_run full_run_b2c full_run_vc_cautious)

ok=0
for p in "${PRESETS[@]}"; do
  log="$(mktemp)"
  start=$SECONDS
  timeout "$RUN_TIMEOUT" "$GODOT" --path "$HERE" --headless --run-log="$p:$WEEKS:sim" >"$log" 2>&1
  ex=$?
  secs=$((SECONDS - start))

  ends="$(grep -ac '^PROBE END' "$log")"
  read -r day ending < <(sed -n 's/^PROBE END day=\([0-9]*\) .* ending=\([a-z0-9_]*\) .*/\1 \2/p' "$log")
  hits="$({ engine_errors "$log"; tr -d '\r' <"$log" | grep -a '^PROBE ERROR'; })"
  errs=0; [ -z "$hits" ] || errs="$(wc -l <<<"$hits")"

  why=""
  if [ "$ex" -eq 124 ]; then why="timed out after ${RUN_TIMEOUT}s"
  elif [ "$ends" -ne 1 ]; then why="$ends PROBE END lines"
  elif [ -z "$ending" ]; then why="no ending"
  elif [ "$errs" -gt 0 ]; then why="error lines"
  fi

  if [ -z "$why" ]; then
    ok=$((ok+1)); echo "RUN OK $p day=$day ending=$ending errs=$errs ${secs}s"
  else
    echo "RUN FAIL $p day=$day ending=$ending errs=$errs ${secs}s ($why)"
    [ "$errs" -eq 0 ] || head -3 <<<"$hits" | sed 's/^/    /'
  fi
  rm -f "$log"
done

echo "RUN SUMMARY ${ok}/${#PRESETS[@]} ok"
[ "$ok" -eq "${#PRESETS[@]}" ]
