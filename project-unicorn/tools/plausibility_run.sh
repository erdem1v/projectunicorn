#!/usr/bin/env bash
# Plausibility gate: the ledger of every card that reached the screen over the played runs,
# judged against the rules the v3 card schema is meant to make true (event engine v3, R13).
#
#   tools/plausibility_run.sh          40 runs x 16 weeks, then PLAUS LONG (4 x 60 weeks)
#   SEEDS=2 WEEKS=8 tools/plausibility_run.sh          a short sweep while iterating
#   JOBS=4 tools/plausibility_run.sh                   four runs at a time
#   LONG_SEEDS=0 tools/plausibility_run.sh             the short sweep alone
#
# WHY A RUN PER PROCESS, AND A USER DIRECTORY PER RUN: the tool is static state over the whole
# game, and user:// is one directory. APPDATA and HOME both move it with them - Godot reads the
# first on Windows, the second on macOS and Linux - so two runs cannot meet in a save slot and
# the owner's real saves are never in reach.
#
# THE LONG PHASE EXISTS because the tenure rules are unreachable in sixteen weeks: no employee
# can be 26 weeks old and no account 44. Only the early-hire variant is worth 60 weeks.
#
# R13 RULE 7 IS THE RUNNER'S: the error lines are a property of the log, and the log is the
# runner's. Two channels print there - the engine's (Parse Error, SCRIPT ERROR, ERROR:) and
# RunProbe's own PROBE ERROR, which a stuck player, a drained pool or an unknown preset raises
# without the engine noticing. Everything else is judged inside the run.
#
# Exit: 0 all green - 1 a rule failed or a run did not finish - 2 harness problem.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/gate_common.sh"
ENTRY="res://scripts/events/tools/plausibility_main.gd"
SEEDS="${SEEDS:-20}"
WEEKS="${WEEKS:-16}"
LONG_SEEDS="${LONG_SEEDS:-4}"
LONG_WEEKS="${LONG_WEEKS:-60}"
RUN_TIMEOUT="${RUN_TIMEOUT:-180}"
LONG_TIMEOUT="${LONG_TIMEOUT:-600}"
JOBS="${JOBS:-1}"

# Raised by plaus_phase, read by the exit status.
TOTAL_FAILS=0

## One run: <seed> <variant> <weeks> <timeout>. Prints the run's ledger and a PLAUS TALLY line
## the phase consumes.
plaus_run() {
  local seed="$1" variant="$2" weeks="$3" limit="$4"
  local log udir ex summary hits fires=0 fails=0
  log="$(mktemp)"
  udir="$(mktemp -d)"
  APPDATA="$udir" HOME="$udir" timeout "$limit" "$GODOT" --path "$HERE" --headless -s "$ENTRY" \
    -- "--event-plausibility-probe=seeds=${seed}-${seed}:weeks=${weeks}:variant=${variant}" \
    >"$log" 2>&1
  ex=$?

  echo "PLAUS RUN seed=$seed variant=$variant weeks=$weeks"
  grep -aE '^PLAUS (FIRE|DEFER|FAIL|RATE|ERROR)' "$log" | tr -d '\r'

  hits="$({ engine_errors "$log"; tr -d '\r' <"$log" | grep -a '^PROBE ERROR'; })"
  if [ -n "$hits" ]; then
    echo "PLAUS FAIL run_error seed=$seed variant=$variant: $(head -1 <<<"$hits")"
    fails=$((fails + $(wc -l <<<"$hits")))
  fi
  summary="$(grep -a '^PLAUS SUMMARY' "$log" | tail -1 | tr -d '\r')"
  if [ -z "$summary" ]; then
    echo "PLAUS FAIL run_incomplete seed=$seed variant=$variant exit=$ex"
    fails=$((fails + 1))
  else
    fires="$(sed -n 's/.*fires=\([0-9]*\).*/\1/p' <<<"$summary")"
    fails=$((fails + $(sed -n 's/.*fails=\([0-9]*\).*/\1/p' <<<"$summary")))
  fi
  echo "PLAUS TALLY fires=$fires fails=$fails"
  rm -rf "$log" "$udir"
}

## One phase: <summary label> <weeks> <timeout> <seeds> <variant>... Runs the whole matrix, JOBS
## at a time, into one file per run so parallel output cannot interleave.
plaus_phase() {
  local label="$1" weeks="$2" limit="$3" seeds="$4"
  shift 4
  local dir i=0 runs=0 fires=0 fails=0 start=$SECONDS line
  [ "$seeds" -gt 0 ] || return 0
  dir="$(mktemp -d)"
  for seed in $(seq 1 "$seeds"); do
    for variant in "$@"; do
      plaus_run "$seed" "$variant" "$weeks" "$limit" >"$dir/$(printf '%04d' $i)" 2>&1 &
      i=$((i + 1))
      [ $((i % JOBS)) -eq 0 ] && wait
    done
  done
  wait

  for f in "$dir"/*; do
    while IFS= read -r line; do
      case "$line" in
        "PLAUS TALLY "*)
          runs=$((runs + 1))
          fires=$((fires + $(sed -n 's/.*fires=\([0-9]*\).*/\1/p' <<<"$line")))
          fails=$((fails + $(sed -n 's/.*fails=\([0-9]*\).*/\1/p' <<<"$line")))
          ;;
        *) printf '%s\n' "$line" ;;
      esac
    done <"$f"
  done
  rm -rf "$dir"

  echo "$label runs=$runs fires=$fires fails=$fails secs=$((SECONDS - start))"
  TOTAL_FAILS=$((TOTAL_FAILS + fails))
}

plaus_phase "PLAUS SUMMARY" "$WEEKS" "$RUN_TIMEOUT" "$SEEDS" plain early
plaus_phase "PLAUS LONG" "$LONG_WEEKS" "$LONG_TIMEOUT" "$LONG_SEEDS" early

[ "$TOTAL_FAILS" -eq 0 ]
