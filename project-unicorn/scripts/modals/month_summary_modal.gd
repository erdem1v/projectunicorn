extends Control

# Month-End Summary modal ("Ay Sonu Özeti") — Spec 3 §5 / ENDGAME_DESIGN.md §1.1.
# Populated from MonthSummarySystem's summary_data (shape documented there).
# Scannable in <15s: 4 delta rows + runway, AYIN OLAYI, one Frank line, DEVAM ET.
#
# process_mode = ALWAYS in the .tscn (ledger 6) — mounts on a paused tree.
# Charcoal header/footer bands are StyleBoxFlat built HERE from UiTokens
# constants (no .tscn color overrides; no charcoal theme variation exists —
# event_modal's relationship pill is the precedent for code-built boxes).
#
# Mockup overrides honored (spec §5): 5th Runway row without delta chip; all
# currency via UiTokens.format_money (mockup's "$2.150" TR-thousands rejected);
# MRR chip = percent (absolute fallback when the month started at $0);
# phase display names match TopBar.

signal dismissed

@onready var _header_band: PanelContainer = %HeaderBand
@onready var _footer_band: PanelContainer = %FooterBand
@onready var _title: Label = %TitleLabel
@onready var _meta: Label = %MetaLabel
@onready var _rows_box: VBoxContainer = %RowsBox
@onready var _highlight_strip: PanelContainer = %HighlightStrip
@onready var _highlight_text: Label = %HighlightText
@onready var _frank_line: Label = %FrankLine
@onready var _continue_btn: Button = %ContinueBtn


func _ready() -> void:
	_apply_band_styles()
	_continue_btn.pressed.connect(_dismiss)
	# Ledger item 11 exception: the ONLY button, non-destructive continue —
	# it MAY take default focus (decision modals must not; this isn't one).
	_continue_btn.grab_focus()


func populate(data: Dictionary) -> void:
	# Idempotent: re-populating replaces the rows (debug repaint / safety).
	for child in _rows_box.get_children():
		child.queue_free()
	_title.text = String(data.get("month_title", ""))
	_meta.text = "%s · %s" % [String(data.get("day_range", "")), String(data.get("phase_name", ""))]
	_highlight_text.text = String(data.get("highlight", ""))
	_frank_line.text = "%s" % String(data.get("frank_line", ""))

	var mrr: Dictionary = data.get("mrr", {"from": 0, "to": 0})
	var cash: Dictionary = data.get("cash", {"from": 0, "to": 0})
	var team: Dictionary = data.get("team", {"from": 0, "to": 0})
	var brand: Dictionary = data.get("brand", {"from": 0, "to": 0})

	_add_row("MRR",
		"%s → %s" % [UiTokens.format_money(int(mrr.from)), UiTokens.format_money(int(mrr.to))],
		_mrr_chip(int(mrr.from), int(mrr.to)))
	_add_separator()
	_add_row("Kasa",
		"%s → %s" % [UiTokens.format_money(int(cash.from)), UiTokens.format_money(int(cash.to))],
		_money_chip(int(cash.to) - int(cash.from)))
	_add_separator()
	_add_row("Ekip", "%d → %d" % [int(team.from), int(team.to)],
		_int_chip(int(team.to) - int(team.from)))
	_add_separator()
	_add_row("Marka", "%d → %d" % [int(brand.from), int(brand.to)],
		_int_chip(int(brand.to) - int(brand.from)))
	_add_separator()
	_add_row("Runway", String(data.get("runway_text", "")), {})  # net runway (Package 5); no chip


# --- Row construction (code-built: values are dynamic, layout is uniform) ---

func _add_row(name_text: String, values_text: String, chip: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 46)
	row.add_theme_constant_override("separation", 12)
	var name_label := Label.new()
	name_label.theme_type_variation = &"BodySerif"
	name_label.custom_minimum_size = Vector2(96, 0)
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_label.text = name_text
	row.add_child(name_label)
	var values := Label.new()
	values.theme_type_variation = &"MetricValueInk"
	values.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	values.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	values.clip_text = true  # extreme values ("$999.9K → $1.2M") never overflow
	values.text = values_text
	row.add_child(values)
	if not chip.is_empty():
		row.add_child(_build_chip(chip))
	_rows_box.add_child(row)


func _add_separator() -> void:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.color = UiTokens.DIVIDER_LIGHT
	_rows_box.add_child(line)


func _build_chip(chip: Dictionary) -> PanelContainer:
	# {text, palette:{bg,fg}} → tinted pill (mockup delta chips).
	var pill := PanelContainer.new()
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = (chip.palette as Dictionary).bg
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	pill.add_theme_stylebox_override("panel", sb)
	var label := Label.new()
	label.theme_type_variation = &"BadgeLabel"
	label.add_theme_color_override("font_color", (chip.palette as Dictionary).fg)
	label.add_theme_font_size_override("font_size", 12)
	label.text = String(chip.text)
	pill.add_child(label)
	pill.custom_minimum_size = Vector2(88, 0)  # uniform chip column
	return pill


# --- Chip content rules (spec §5 override 3) ---

func _mrr_chip(from: int, to: int) -> Dictionary:
	var delta: int = to - from
	if from > 0 and delta != 0:
		var pct: int = int(round(abs(delta) / float(from) * 100.0))
		return _chip_for(delta, "%s%%%d %s" % ["+" if delta > 0 else "−", pct, _arrow(delta)])
	return _money_chip(delta)  # month started at $0 (or flat) → absolute fallback


func _money_chip(delta: int) -> Dictionary:
	if delta == 0:
		return _chip_for(0, "±0 —")
	var body: String = UiTokens.format_money(absi(delta))
	return _chip_for(delta, "%s%s %s" % ["+" if delta > 0 else "−", body, _arrow(delta)])


func _int_chip(delta: int) -> Dictionary:
	if delta == 0:
		return _chip_for(0, "±0 —")
	return _chip_for(delta, "%s%d %s" % ["+" if delta > 0 else "−", absi(delta), _arrow(delta)])


func _chip_for(delta: int, text: String) -> Dictionary:
	return {"text": text, "palette": UiTokens.badge_palette_for_delta(delta)}


func _arrow(delta: int) -> String:
	return "↑" if delta > 0 else "↓"


# --- Band styling (charcoal header/footer from UiTokens, code-built) ---

func _apply_band_styles() -> void:
	_header_band.add_theme_stylebox_override("panel", _band_stylebox(true))
	_footer_band.add_theme_stylebox_override("panel", _band_stylebox(false))
	var strip := StyleBoxFlat.new()
	strip.bg_color = UiTokens.BG_PANEL
	strip.set_corner_radius_all(4)
	strip.content_margin_left = 14
	strip.content_margin_right = 14
	strip.content_margin_top = 9
	strip.content_margin_bottom = 9
	_highlight_strip.add_theme_stylebox_override("panel", strip)
	# Charcoal bands carry cream text (UiTokens context rule).
	_title.add_theme_color_override("font_color", UiTokens.CREAM)
	_title.add_theme_font_size_override("font_size", 26)


func _band_stylebox(top: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.BG_TOPBAR
	# Match ModalPanel's outer radius on the flush edges only.
	sb.corner_radius_top_left = 6 if top else 0
	sb.corner_radius_top_right = 6 if top else 0
	sb.corner_radius_bottom_left = 0 if top else 6
	sb.corner_radius_bottom_right = 0 if top else 6
	sb.content_margin_left = 26
	sb.content_margin_right = 26
	sb.content_margin_top = 16 if top else 12
	sb.content_margin_bottom = 16 if top else 12
	return sb


# --- Dismiss (DEVAM ET / ESC — same non-destructive action) ---

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_dismiss()


func _dismiss() -> void:
	dismissed.emit()
	queue_free()
