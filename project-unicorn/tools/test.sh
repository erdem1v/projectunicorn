#!/usr/bin/env bash
# The test layers, each run in its own Godot processes and user directories. Green prints one line per layer; red prints
# the first failure and where the full logs are, so nobody pipes the output through head and runs it again. A run that
# prints an engine error fails whatever its verdict said (gate_common.sh), as in smoke_run.sh.
#
#   tools/test.sh hizli   the K0 link check and every K2 player path (PlayerPaths' match table), all at once
#   tools/test.sh tam     hizli, then together: every smoke case (smoke_run.sh, P at a time), the event lint,
#                         loc_residue, run_gate.sh and plausibility_run.sh; a line per layer and a total
#   P=12 CASE_TIMEOUT=300 tools/test.sh tam      (the defaults: P=8, CASE_TIMEOUT=300)
#   SMOKE_CASES="a b" SEEDS=1 LONG_SEEDS=0 tools/test.sh tam   a short try of the script itself; WEEKS, SEEDS and
#                         RUN_TIMEOUT reach run_gate.sh and plausibility_run.sh as they are
#
# Exit: 0 green · 1 red · 2 harness problem.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/gate_common.sh"
MODE="${1:-}"
[ "$MODE" = hizli ] || [ "$MODE" = tam ] || { echo "usage: ${0##*/} hizli|tam" >&2; exit 2; }
CASE_TIMEOUT="${CASE_TIMEOUT:-300}"
P="${P:-8}"
LOGS="$(mktemp -d)"
start=$SECONDS

took() { echo "$(( ($1) / 60 )) dk $(( ($1) % 60 )) sn"; }

# One job: <name> <godot flag> <verdict prefix>. Writes <name>.log and <name>.verdict ("PASS", or the failure lines).
job() {
  local udir log ex hits
  udir="$(mktemp -d)"
  log="$LOGS/$1.log"
  APPDATA="$udir" HOME="$udir" timeout "$CASE_TIMEOUT" "$GODOT" --path "$HERE" --headless "$2" >"$log" 2>&1
  ex=$?
  rm -rf "$udir"
  hits="$(engine_errors "$log")"
  if [ -n "$hits" ]; then
    { echo "$1: engine error"; head -5 <<<"$hits"; } >"$LOGS/$1.verdict"
  elif [ "$ex" -eq 124 ]; then
    echo "$1: timed out after ${CASE_TIMEOUT}s" >"$LOGS/$1.verdict"
  elif grep -aq "^$3 PASS" "$log"; then
    echo PASS >"$LOGS/$1.verdict"
  elif grep -aq "^$3 FAIL" "$log"; then
    grep -a "^$3 " "$log" | tr -d '\r' >"$LOGS/$1.verdict"
  else
    echo "$1: no verdict (exit $ex)" >"$LOGS/$1.verdict"
  fi
}

# The hizli layer. Prints its line; on red also the first failure (30 lines at most). Returns 0 / 1 / 2.
hizli() {
  local cases total=0 red=0 first="" v t0=$SECONDS
  cases="$(awk '/^static func run\(/{on=1;next} on&&/^static func/{exit} on' "$HERE/scripts/debug/player_paths.gd" \
    | grep -oE '^\s*"[a-z0-9_]+":' | tr -d '\t ":')"
  [ -n "$cases" ] || { echo "${0##*/}: no K2 case found in player_paths.gd" >&2; return 2; }
  job k0 --k0-check K0 &
  for c in $cases; do job "k2_$c" "--player-path=$c" K2 & done
  wait
  for v in "$LOGS"/k0.verdict "$LOGS"/k2_*.verdict; do
    [ -e "$v" ] || continue
    total=$((total + 1))
    if [ "$(cat "$v")" != PASS ]; then
      red=$((red + 1))
      [ -n "$first" ] || first="$(head -30 "$v")"
    fi
  done
  [ "$total" -eq $(( $(wc -w <<<"$cases") + 1 )) ] || { echo "${0##*/}: a job left no verdict; logs in $LOGS" >&2; return 2; }
  if [ "$red" -eq 0 ]; then
    echo "✓ hizli · $total vaka · 0 hata · $(took $((SECONDS - t0)))"
    return 0
  fi
  echo "✗ hizli · $total vaka · $red hata · $(took $((SECONDS - t0)))"
  echo "$first"
  return 1
}

if [ "$MODE" = hizli ]; then
  hizli; rc=$?
  [ "$rc" -eq 0 ] && rm -rf "$LOGS"
  [ "$rc" -eq 1 ] && echo "tam log: $LOGS"
  exit "$rc"
fi

# ---------------------------------------------------------------- tam
# A whole tool in its own user directory: <name> <command...>. Writes <name>.log and <name>.exit.
tool() {
  local name="$1" udir t0=$SECONDS; shift
  udir="$(mktemp -d)"
  APPDATA="$udir" HOME="$udir" GODOT="$GODOT" "$@" >"$LOGS/$name.log" 2>&1
  echo $? >"$LOGS/$name.exit"
  echo $((SECONDS - t0)) >"$LOGS/$name.secs"
  rm -rf "$udir"
}

# One smoke case through smoke_run.sh, in its own user directory: its verdict line goes to smoke/<case>.out.
smoke_case() {
  local udir
  udir="$(mktemp -d)"
  APPDATA="$udir" HOME="$udir" GODOT="$GODOT" CASE_TIMEOUT="$CASE_TIMEOUT" SMOKE_LOG_DIR="$LOGS/smoke/logs" \
    bash "$HERE/tools/smoke_run.sh" "$1" \
    >"$LOGS/smoke/$1.out" 2>&1
  echo $? >>"$LOGS/smoke/$1.out"
  rm -rf "$udir"
}
export -f smoke_case
export LOGS HERE GODOT CASE_TIMEOUT

hizli_out="$(hizli)"; hizli_rc=$?
echo "$hizli_out" | head -1
[ "$hizli_rc" -eq 2 ] && exit 2

mkdir -p "$LOGS/smoke"
if [ -n "${SMOKE_CASES:-}" ]; then
  cases="$(tr ' ' '\n' <<<"$SMOKE_CASES" | sed '/^$/d')"
else
  cases="$(awk '/^\tmatch case_name:/{on=1;next} on&&/^\t\t_:/{exit} on' "$HERE/scripts/debug/endgame_smoke.gd" \
    | grep -oE '^\s*"[a-z0-9_]+":' | tr -d '\t ":')"
fi
[ -n "$cases" ] || { echo "${0##*/}: no smoke case found in endgame_smoke.gd" >&2; exit 2; }
tool run_gate bash "$HERE/tools/run_gate.sh" &
tool plausibility bash "$HERE/tools/plausibility_run.sh" &
tool lint "$GODOT" --path "$HERE" --headless --event-lint &
tool residue "$GODOT" --path "$HERE" --headless -s res://scripts/debug/loc_residue.gd &
t_smoke=$SECONDS
xargs -P "$P" -I{} bash -c 'smoke_case "$1"' _ {} <<<"$cases"
smoke_secs=$((SECONDS - t_smoke))
wait

red=0; [ "$hizli_rc" -eq 0 ] || red=1
first=""; [ "$hizli_rc" -eq 0 ] || first="$(echo "$hizli_out" | sed -n '2,31p')"
note() { red=1; [ -n "$first" ] || first="$1"; }

# smoke: a case passes when smoke_run.sh printed SMOKE PASS and exited 0
n=0; bad=()
for c in $cases; do
  n=$((n + 1))
  o="$LOGS/smoke/$c.out"
  if [ "$(tail -1 "$o")" != 0 ] || ! grep -aq '^SMOKE PASS' "$o"; then bad+=("$c"); fi
done
if [ ${#bad[@]} -eq 0 ]; then
  echo "✓ smoke · $n vaka · 0 hata · $(took "$smoke_secs") (P=$P)"
else
  echo "✗ smoke · $n vaka · ${#bad[@]} hata · $(took "$smoke_secs") (P=$P)"
  note "$(for c in "${bad[@]}"; do sed '$d' "$LOGS/smoke/$c.out" | grep -a 'SMOKE FAIL\|^    ' ; done | head -30)"
fi

# lint and loc_residue: their own verdict line, and no engine error
layer() {  # <name> <verdict regex> <label>
  local log="$LOGS/$1.log" hits line
  hits="$(engine_errors "$log")"
  line="$(grep -aE "$2" "$log" | tail -1 | tr -d '\r')"
  if [ "$(cat "$LOGS/$1.exit")" = 0 ] && [ -z "$hits" ] && [ -n "$line" ]; then
    echo "✓ $3 · $line · $(took "$(cat "$LOGS/$1.secs")")"
  else
    echo "✗ $3 · ${line:-sonuç satırı yok (çıkış $(cat "$LOGS/$1.exit"))} · $(took "$(cat "$LOGS/$1.secs")")"
    note "$( { echo "$3:"; [ -n "$hits" ] && head -5 <<<"$hits"; grep -aE '^(LINT|RESIDUE) ' "$log" | head -20; } | head -30)"
  fi
}
layer lint '^LINT (PASS|FAIL)' lint
layer residue '^LOC RESIDUE: ' loc_residue

# run_gate and plausibility print their own summary lines
gate() {  # <name> <summary regex> <label> <fail regex>
  local log="$LOGS/$1.log" line
  line="$(grep -aE "$2" "$log" | tr -d '\r' | paste -sd ' ' -)"
  if [ "$(cat "$LOGS/$1.exit")" = 0 ]; then
    echo "✓ $3 · $line · $(took "$(cat "$LOGS/$1.secs")")"
  else
    echo "✗ $3 · ${line:-özet satırı yok (çıkış $(cat "$LOGS/$1.exit"))} · $(took "$(cat "$LOGS/$1.secs")")"
    note "$( { echo "$3:"; grep -aE "$4" "$log" | tr -d '\r' | head -20; } | head -30)"
  fi
}
gate run_gate '^RUN SUMMARY' run_gate '^RUN FAIL|^    '
gate plausibility '^PLAUS (SUMMARY|LONG) runs=' plausibility '^PLAUS FAIL'

total="$(took $((SECONDS - start)))"
if [ "$red" -eq 0 ]; then
  echo "✓ tam · yeşil · $total"
  rm -rf "$LOGS"
  exit 0
fi
echo "✗ tam · kırmızı · $total"
echo "$first"
echo "tam log: $LOGS"
exit 1
