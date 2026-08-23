#!/usr/bin/env bash
# Smoke gate for the endgame suite.
#
# WHY THIS EXISTS: EndgameSmoke.run_case decides PASS/FAIL with `if fail == ""`
# (endgame_smoke.gd:339). Every case function is declared `-> String`, and a GDScript
# runtime error inside one either aborts the body (returning "") or prints and continues
# with a null value — in BOTH shapes the case returns "" and prints SMOKE PASS while
# proving nothing. The suite documents one instance this happened to and was fixed
# (endgame_smoke.gd:4381-4387) and warns at :9361-9365 that the pattern recurs.
#
# GDScript cannot catch this in-process: there is no try/catch and no error hook exposed to
# scripts. The only place the evidence exists is the engine's stderr, so the gate has to
# live in the runner. A case that prints an error token FAILS here regardless of what it
# returned.
#
# INVOCATION NOTE: the flag must NOT sit behind a `--` separator. main.gd reads it from
# OS.get_cmdline_args() (main.gd:352-361); args after `--` land in get_cmdline_user_args()
# instead and the case silently never runs — the process just boots the game and hangs.
#
#   tools/smoke_run.sh <case_id>      run one case
#   tools/smoke_run.sh --all          run every case in the match table
#   GODOT=/path/to/godot tools/smoke_run.sh ...
#
# Exit: 0 all green · 1 one or more cases failed · 2 harness problem.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SMOKE="$HERE/scripts/debug/endgame_smoke.gd"
CASE_TIMEOUT="${CASE_TIMEOUT:-120}"
ERR_TOKENS='SCRIPT ERROR|Parse Error|Compile Error|Failed to instantiate|Failed to load script'

if [ -z "${GODOT:-}" ]; then
  for c in "$(command -v godot || true)" \
           "/c/Users/$USER/Desktop/Godot_v4.6.2-stable_win64_console.exe" \
           "$HOME/Desktop/Godot_v4.6.2-stable_win64_console.exe"; do
    [ -n "$c" ] && [ -x "$c" ] && GODOT="$c" && break
  done
fi
[ -n "${GODOT:-}" ] || { echo "smoke_run: no Godot binary; set GODOT=<path>" >&2; exit 2; }
[ -f "$SMOKE" ] || { echo "smoke_run: cannot find $SMOKE" >&2; exit 2; }

# The case list is the match table itself, so the runner can never drift from the suite.
list_cases() {
  awk '/^\tmatch case_name:/{on=1;next} on&&/^\t\t_:/{exit} on' "$SMOKE" \
    | grep -oE '^\s*"[a-z0-9_]+":' | tr -d '\t ":'
}

run_one() {
  local case_id="$1" log
  log="$(mktemp)"
  timeout "$CASE_TIMEOUT" "$GODOT" --path "$HERE" --headless --endgame-smoke="$case_id" >"$log" 2>&1
  local ex=$? verdict errs
  verdict="$(grep -aoE "SMOKE (PASS|FAIL).*" "$log" | head -1 | tr -d "\r")"
  errs="$(grep -cE "$ERR_TOKENS" "$log")"

  if [ "$errs" -gt 0 ]; then
    echo "SMOKE FAIL $case_id: $errs engine error line(s) — a throwing case is not a passing case"
    grep -E "$ERR_TOKENS" "$log" | head -3 | sed 's/^/    /'
    rm -f "$log"; return 1
  fi
  if [ "$ex" -eq 124 ]; then
    echo "SMOKE FAIL $case_id: timed out after ${CASE_TIMEOUT}s"; rm -f "$log"; return 1
  fi
  if [ -z "$verdict" ]; then
    echo "SMOKE FAIL $case_id: no verdict printed (exit $ex)"; rm -f "$log"; return 1
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
