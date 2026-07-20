extends Node

# Formatter byte-diff probe (calibration constants centralization sweep, 2026-07-21).
# Run (normal boot so autoload identifiers compile; --script mode can't load top_bar.gd):
#   <godot> --headless --path <proj> res://scenes/debug/FmtProbe.tscn
# Prints one FMT|<surface>|<value>|<string> line per formatter per value; the
# pre-refactor and post-refactor outputs must byte-match (the formatter move is
# behavior-neutral). Dual-mode: while TopBar still owns _fmt_money/_fmt_cash_full
# it probes those; after the move it probes UiTokens.format_money_chip/exact.
# Values cover every branch boundary of both compact formatters plus negatives
# (which exercise the chip formatter's signed-value %f quirk).

const VALUES := [0, 7, 999, 1000, 2500, 9999, 10000, 12500, 50000, 350000,
	999999, 1000000, 1234567, 9999999, 10000000, 12000000, 22000000, 22500000,
	-500, -2500, -12500, -1234567]


func _ready() -> void:
	var tb = load("res://scripts/ui/components/top_bar.gd").new()  # untyped: dual-mode dynamic calls
	var ut = load("res://scripts/theme/ui_tokens.gd")
	var has_local: bool = tb.has_method("_fmt_money")
	for v in VALUES:
		var chip: String = tb._fmt_money(v) if has_local else ut.format_money_chip(v)
		var exact: String = tb._fmt_cash_full(v) if has_local else ut.format_money_exact(v)
		print("FMT|chip|%d|%s" % [v, chip])
		print("FMT|exact|%d|%s" % [v, exact])
		print("FMT|tokens|%d|%s" % [v, ut.format_money(v)])
	tb.free()
	get_tree().quit()
