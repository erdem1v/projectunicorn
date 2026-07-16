extends Control

# Finance tab host (Spec 6 §7). A light-register shell with a segmented control switching two
# sub-pages under one parent (the product_tab _show_state visibility pattern):
#   * Özet    — a minimal cash / MRR / gider / runway summary (anchors the Finance tab).
#   * Yatırım — the Series A Hunt panel (nests HuntTab.tscn). PHASE-GATED: locked before phase 3
#     with the "Series A Hunt'ta açılır" telegraph, unlocked on phase_changed(3). This relocates
#     Spec 4's standalone Yatırım rail tab (the lock moved off the rail onto this selector).

const HUNT_TAB := preload("res://scenes/tabs/HuntTab.tscn")

var _ozet_btn: Button
var _yatirim_btn: Button
var _ozet_view: Control
var _yatirim_view: Control
var _current: String = "ozet"

var _kasa_val: Label
var _mrr_val: Label
var _burn_val: Label
var _runway_val: Label


func _ready() -> void:
	_build()
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.cash_changed.connect(_on_econ_changed)
	EventBus.mrr_changed.connect(_on_econ_changed)
	EventBus.burn_changed.connect(_on_econ_changed)
	_apply_phase_lock(GameState.phase < 3)
	_show_page("ozet")


func _exit_tree() -> void:
	if EventBus.phase_changed.is_connected(_on_phase_changed):
		EventBus.phase_changed.disconnect(_on_phase_changed)
	if EventBus.cash_changed.is_connected(_on_econ_changed):
		EventBus.cash_changed.disconnect(_on_econ_changed)
	if EventBus.mrr_changed.is_connected(_on_econ_changed):
		EventBus.mrr_changed.disconnect(_on_econ_changed)
	if EventBus.burn_changed.is_connected(_on_econ_changed):
		EventBus.burn_changed.disconnect(_on_econ_changed)


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)

	var seg := HBoxContainer.new()
	seg.add_theme_constant_override("separation", 8)
	col.add_child(seg)
	_ozet_btn = _make_segment("Özet", "ozet")
	_yatirim_btn = _make_segment("Yatırım", "yatirim")
	seg.add_child(_ozet_btn)
	seg.add_child(_yatirim_btn)

	# Sub-page host — siblings toggled by visibility (product_tab _show_state pattern).
	var host := Control.new()
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(host)

	_ozet_view = _build_ozet()
	_ozet_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(_ozet_view)

	_yatirim_view = HUNT_TAB.instantiate()
	_yatirim_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(_yatirim_view)


func _make_segment(label: String, id: String) -> Button:
	var b := Button.new()
	b.text = label
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(_show_page.bind(id))
	return b


func _build_ozet() -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"CardPanel"
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)
	vb.add_child(UiFactory.make_section_header("FİNANS ÖZETİ"))
	_kasa_val = _add_stat_row(vb, "Kasa")
	_mrr_val = _add_stat_row(vb, "MRR")
	_burn_val = _add_stat_row(vb, "Gider")
	_runway_val = _add_stat_row(vb, "Runway")
	return panel


func _add_stat_row(parent: VBoxContainer, label: String) -> Label:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_color_override("font_color", UiTokens.INK_DIM)
	row.add_child(l)
	var v := Label.new()
	v.add_theme_color_override("font_color", UiTokens.INK)
	row.add_child(v)
	parent.add_child(row)
	return v


func _refresh_ozet() -> void:
	if _kasa_val == null:
		return
	_kasa_val.text = UiTokens.format_money(GameState.cash)
	_mrr_val.text = UiTokens.format_money(GameState.mrr)
	_burn_val.text = "%s / gün" % UiTokens.format_money(GameState.daily_burn)
	_runway_val.text = UiTokens.net_runway_text(GameState.get_runway_months())


func _show_page(id: String) -> void:
	if id == "yatirim" and GameState.phase < 3:
		return  # locked — the disabled button + tooltip already tell the player why
	_current = id
	_ozet_view.visible = id == "ozet"
	_yatirim_view.visible = id == "yatirim"
	_ozet_btn.modulate = Color(1, 1, 1, 1) if id == "ozet" else Color(1, 1, 1, 0.6)
	if not _yatirim_btn.disabled:
		_yatirim_btn.modulate = Color(1, 1, 1, 1) if id == "yatirim" else Color(1, 1, 1, 0.6)
	if id == "ozet":
		_refresh_ozet()


func _apply_phase_lock(locked: bool) -> void:
	_yatirim_btn.disabled = locked
	_yatirim_btn.tooltip_text = "Series A Hunt'ta açılır" if locked else ""
	if locked:
		_yatirim_btn.modulate = Color(1, 1, 1, 0.4)
		if _current == "yatirim":
			_show_page("ozet")
	elif _current != "yatirim":
		_yatirim_btn.modulate = Color(1, 1, 1, 0.6)


func _on_phase_changed(new_phase: int) -> void:
	_apply_phase_lock(new_phase < 3)


func _on_econ_changed(_v = null) -> void:
	if _current == "ozet":
		_refresh_ozet()
