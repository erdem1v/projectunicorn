extends Control

# Ending summary modal — placeholder framework per ENDGAME_DESIGN.md §6.
# One framework, seven content sets: title + Frank reflection + run summary,
# populated from EndingsSystem._build_ending_data. The newspaper-layout ending
# screens (Claude Design session) replace THIS presentation later; the
# run_ended → populate() seam stays.
#
# process_mode = ALWAYS in the .tscn (§7.6) — the run is over, the tree is
# paused, and this modal must stay clickable. There is deliberately no
# "dismiss back to gameplay" path: the world stopped (§7.3).
#
# Retry = process relaunch (Erdem 2026-07-13): OS.set_restart_on_exit
# relaunches the executable → all autoload state resets cleanly. The in-place
# reset seam is deferred to the SaveManager session.

const PHASE_NAMES := ["Bootstrap", "Traction", "Series A Hunt"]

@onready var _title: Label = %TitleLabel
@onready var _frank: Label = %FrankLabel
@onready var _stats_grid: GridContainer = %StatsGrid
@onready var _restart_btn: Button = %RestartBtn
@onready var _quit_btn: Button = %QuitBtn


func _ready() -> void:
	_restart_btn.pressed.connect(_on_restart)
	_quit_btn.pressed.connect(_on_quit)
	_restart_btn.grab_focus()


func populate(data: Dictionary) -> void:
	_title.text = String(data.get("title", ""))
	_title.add_theme_color_override("font_color", _tone_color(String(data.get("tone", "loss"))))
	_frank.text = "\"%s\"" % String(data.get("frank_line", ""))
	var phase_idx: int = clampi(int(data.get("phase", 1)) - 1, 0, PHASE_NAMES.size() - 1)
	var rows: Array = [
		["Gün", "%d / 180" % int(data.get("day", 0))],
		["Kasa", _fmt_money(int(data.get("cash", 0)))],
		["MRR", _fmt_money(int(data.get("mrr", 0)))],
		["Müşteri", "%d" % int(data.get("customers", 0))],
		["Marka", "%d" % int(data.get("brand", 0))],
		["Çalışan", "%d" % int(data.get("employees", 0))],
		["Ulaşılan faz", PHASE_NAMES[phase_idx]],
	]
	for row in rows:
		var caption := Label.new()
		caption.theme_type_variation = &"MetricCaption"
		caption.text = String(row[0]).to_upper()
		_stats_grid.add_child(caption)
		var value := Label.new()
		value.theme_type_variation = &"BodySerif"
		value.text = String(row[1])
		_stats_grid.add_child(value)


func _tone_color(tone: String) -> Color:
	# Light modal surface → INK-side palette (UiTokens header rule).
	match tone:
		"win": return UiTokens.POSITIVE
		"soft_win": return UiTokens.ACCENT_DEEP
		"soft_loss": return UiTokens.INK_MUTED
		_: return UiTokens.NEGATIVE


func _fmt_money(value: int) -> String:
	var a: int = absi(value)
	var s: String
	if a >= 1000000:
		s = "$%.1fM" % (a / 1000000.0)
	elif a >= 1000:
		s = "$%.1fK" % (a / 1000.0)
	else:
		s = "$%d" % a
	return ("-" + s) if value < 0 else s


func _on_restart() -> void:
	OS.set_restart_on_exit(true)
	get_tree().quit()


func _on_quit() -> void:
	get_tree().quit()
