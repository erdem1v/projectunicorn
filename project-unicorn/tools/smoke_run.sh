#!/usr/bin/env bash
# Smoke gate for the endgame suite.
#
# EndgameSmoke.run_case passes a case whose `-> String` body returned "". A GDScript runtime
# error inside a case either aborts the body (returning "") or continues with a null value,
# so a throwing case prints SMOKE PASS while proving nothing. GDScript cannot catch this
# in-process (no try/catch, no error hook), so the gate lives here: a case whose output
# carries an engine error token FAILS regardless of what it returned.
#
# The flag must NOT sit behind a `--` separator: main.gd reads OS.get_cmdline_args(), and
# args after `--` never reach it — the process boots the game and hangs.
#
#   tools/smoke_run.sh <case_id>      run one case
#   tools/smoke_run.sh --all          run every case in the match table
#   GODOT=/path/to/godot tools/smoke_run.sh ...
#
# Exit: 0 all green · 1 one or more cases failed · 2 harness problem.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/gate_common.sh"
SMOKE="$HERE/scripts/debug/endgame_smoke.gd"
CASE_TIMEOUT="${CASE_TIMEOUT:-120}"
[ -f "$SMOKE" ] || { echo "smoke_run: cannot find $SMOKE" >&2; exit 2; }

# The case list is the match table itself, so the runner can never drift from the suite.
list_cases() {
  awk '/^\tmatch case_name:/{on=1;next} on&&/^\t\t_:/{exit} on' "$SMOKE" \
    | grep -oE '^\s*"[a-z0-9_]+":' | tr -d '\t ":'
}

# A case that breaks a rule on purpose says `# EXPECT-ERROR <message fragment>` on its match arm.
expected_error() {
  awk -v id="\"$1\":" '/^\tmatch case_name:/{on=1;next} on&&/^\t\t_:/{exit}
    on&&$1==id&&/# EXPECT-ERROR /{sub(/.*# EXPECT-ERROR /,"");print;exit}' "$SMOKE" | tr -d '\r'
}

run_one() {
  local case_id="$1" log want
  log="$(mktemp)"
  want="$(expected_error "$case_id")"
  timeout "$CASE_TIMEOUT" "$GODOT" --path "$HERE" --headless --endgame-smoke="$case_id" >"$log" 2>&1
  local ex=$? verdict hits
  verdict="$(grep -aoE "SMOKE (PASS|FAIL).*" "$log" | head -1 | tr -d "\r")"
  hits="$(engine_errors "$log")"
  # grep -v '' would drop every line, so only a declared fragment is exempt.
  [ -z "$want" ] || hits="$(grep -avF -- "$want" <<<"$hits")"

  if [ -n "$hits" ]; then
    echo "SMOKE FAIL $case_id: $(wc -l <<<"$hits") engine error line(s) — a throwing case is not a passing case"
    head -3 <<<"$hits" | sed 's/^/    /'
    rm -f "$log"; return 1
  fi
  if [ "$ex" -eq 124 ]; then
    echo "SMOKE FAIL $case_id: timed out after ${CASE_TIMEOUT}s"; rm -f "$log"; return 1
  fi
  if [ -z "$verdict" ]; then
    echo "SMOKE FAIL $case_id: no verdict printed (exit $ex)"; rm -f "$log"; return 1
  fi
  if [ -n "$want" ] && ! grep -aqF -- "$want" "$log"; then
    echo "SMOKE FAIL $case_id: EXPECT-ERROR '$want' never printed (stale marker)"; rm -f "$log"; return 1
  fi
  echo "$verdict"
  rm -f "$log"
  case "$verdict" in "SMOKE PASS"*) return 0 ;; *) return 1 ;; esac
}

if [ "${1:---all}" = "--all" ]; then
  pass=0; fail=0; failed=()
  while read -r c; do
    [ -z "$c" ] && continue
    if run_one "$c"; then pass=$((pass+1)); else fail=$((fail+1)); failed+=("$c"); fi
  done < <(list_cases)
  echo "----"
  echo "SMOKE SUMMARY ${pass}/$((pass+fail)) passed"
  [ "$fail" -gt 0 ] && { printf 'FAILED: %s\n' "${failed[*]}"; exit 1; }
  exit 0
fi

run_one "$1"
