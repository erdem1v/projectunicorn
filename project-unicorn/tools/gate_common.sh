# Shared by smoke_run.sh and run_gate.sh; sourced, runs nothing but the Godot lookup.
#
# ERR_TOKENS is what makes a Godot run "carry an error": a GDScript runtime or parse failure,
# or any line of the engine's ERROR channel (push_error, failed resource loads), which prints
# as "ERROR: ..." at column 0. WARNING lines are not gated. ERR_IGNORE is the engine's
# shutdown leak report, which the same code prints in some runs and not in others.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERR_TOKENS='^ERROR:|SCRIPT ERROR|Parse Error|Compile Error'
ERR_IGNORE='resources still in use at exit'

# The error lines of the Godot log in $1, carriage returns stripped.
engine_errors() { grep -aE "$ERR_TOKENS" "$1" | grep -avF -- "$ERR_IGNORE" | tr -d '\r'; }

if [ -z "${GODOT:-}" ]; then
  for c in "$(command -v godot || true)" \
           "$HOME/Desktop/Godot_v4.6.2-stable_win64_console.exe"; do
    [ -n "$c" ] && [ -x "$c" ] && GODOT="$c" && break
  done
fi
[ -n "${GODOT:-}" ] || { echo "${0##*/}: no Godot binary; set GODOT=<path>" >&2; exit 2; }
