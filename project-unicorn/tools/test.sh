#!/usr/bin/env bash
# The fast test layer: the K0 link check and every K2 player path (PlayerPaths' match table), each in its own Godot
# process and user directory, all at once. Green prints one line; red prints the first failure and where the full logs
# are, so nobody pipes the output through head and runs it again. A run that prints an engine error fails whatever its
# verdict said (gate_common.sh), as in smoke_run.sh.
#
#   tools/test.sh hizli
#
# Exit: 0 green · 1 red · 2 harness problem.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/gate_common.sh"
[ "${1:-}" = hizli ] || { echo "usage: ${0##*/} hizli" >&2; exit 2; }
CASE_TIMEOUT="${CASE_TIMEOUT:-300}"
LOGS="$(mktemp -d)"
start=$SECONDS

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

cases="$(awk '/^static func run\(/{on=1;next} on&&/^static func/{exit} on' "$HERE/scripts/debug/player_paths.gd" \
  | grep -oE '^\s*"[a-z0-9_]+":' | tr -d '\t ":')"
[ -n "$cases" ] || { echo "${0##*/}: no K2 case found in player_paths.gd" >&2; exit 2; }

job k0 --k0-check K0 &
for c in $cases; do job "k2_$c" "--player-path=$c" K2 & done
wait

total=0; red=0; first=""
for v in "$LOGS"/*.verdict; do
  total=$((total + 1))
  if [ "$(cat "$v")" != PASS ]; then
    red=$((red + 1))
    [ -n "$first" ] || first="$(head -30 "$v")"
  fi
done
[ "$total" -eq $(( $(wc -w <<<"$cases") + 1 )) ] || { echo "${0##*/}: a job left no verdict; logs in $LOGS" >&2; exit 2; }
took="$(( (SECONDS - start) / 60 )) dk $(( (SECONDS - start) % 60 )) sn"
if [ "$red" -eq 0 ]; then
  echo "✓ hizli · $total vaka · 0 hata · $took"
  rm -rf "$LOGS"
  exit 0
fi
echo "✗ hizli · $total vaka · $red hata · $took"
echo "$first"
echo "tam log: $LOGS"
exit 1
