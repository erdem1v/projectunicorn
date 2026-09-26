extends Control

# Month-End Summary modal ("Ay Sonu Özeti").
# Populated from MonthSummarySystem's summary_data (shape documented there).
# Scannable in <15s: 4 delta rows + runway, AYIN OLAYI, one Frank line, DEVAM ET.
#
# process_mode = ALWAYS in the .tscn — mounts on a paused tree.
# Charcoal header/footer bands are StyleBoxFlat built HERE from UiTokens
# constants (no .tscn color overrides; flush-edge radii, see _band_stylebox).
# All currency via UiTokens.format_money (the mockup's "$2.150" TR-thousands form was rejected).

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
	# Focus-rule exception: the ONLY button, non-destructive continue —
	# it MAY take default focus (decision modals must not; this isn't one).
	_continue_btn.grab_focus()


func populate(data: Dictionary) -> void:
	_title.text = data.month_title
	_meta.text = "%s · %s" % [data.day_range, data.phase_name]
	_highlight_text.text = data.highlight
	_frank_line.text = data.frank_line

	var mrr: Dictionary = data.mrr
	var cash: Dictionary = data.cash
	var team: Dictionary = data.team
	var brand: Dictionary = data.brand
	_add_row(tr("FIN_CAP_MRR"),
		"%s → %s" % [UiTokens.format_money(int(mrr.from)), UiTokens.format_money(int(mrr.to))],
		_mrr_chip(int(mrr.from), int(mrr.to)))
	_add_row(tr("MONTH_ROW_CASH"),
		"%s → %s" % [UiTokens.format_money(int(cash.from)), UiTokens.format_money(int(cash.to))],
		_money_chip(int(cash.to) - int(cash.from)))
	_add_row(tr("MONTH_ROW_TEAM"), "%d → %d" % [team.from, team.to],
		_int_chip(int(team.to) - int(team.from)))
	_add_row(tr("MONTH_ROW_BRAND"), "%d → %d" % [brand.from, brand.to],
		_int_chip(int(brand.to) - int(brand.from)))
	_add_row(tr("FIN_RUNWAY"), data.runway_text, {})  # net runway; no chip


# --- Row construction (code-built: values are dynamic, layout is uniform) ---

func _add_row(name_text: String, values_text: String, chip: Dictionary) -> void:
	if _rows_box.get_child_count() > 0:
		var line := ColorRect.new()
		line.custom_minimum_size = Vector2(0, 1)
		line.color = UiTokens.DIVIDER_LIGHT
		_rows_box.add_child(line)
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 46)
	row.add_theme_constant_override("separation", 12)
	var name_label := UiFactory.make_label(name_text, &"BodySerif")
	name_label.custom_minimum_size = Vector2(96, 0)
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(name_label)
	var values := UiFactory.make_label(values_text, &"MetricValueInk")
	values.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	values.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	values.clip_text = true  # extreme values ("$999.9K → $1.2M") never overflow
	row.add_child(values)
	if not chip.is_empty():
		row.add_child(_build_chip(chip))
	_rows_box.add_child(row)


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
	var label := UiFactory.make_label(String(chip.text), &"BadgeLabel", (chip.palette as Dictionary).fg)
	label.add_theme_font_size_override("font_size", 12)
	pill.add_child(label)
	pill.custom_minimum_size = Vector2(88, 0)  # uniform chip column
	return pill


# --- Chip content rules ---

func _mrr_chip(from: int, to: int) -> Dictionary:
	var delta: int = to - from
	if from > 0 and delta != 0:
		var pct: int = int(round(abs(delta) / float(from) * 100.0))
		return _delta_chip(delta, Fmt.percent(pct, 0))
	return _money_chip(delta)  # month started at $0 (or flat) → absolute fallback


func _money_chip(delta: int) -> Dictionary:
	return _delta_chip(delta, UiTokens.format_money(absi(delta)))


func _int_chip(delta: int) -> Dictionary:
	return _delta_chip(delta, "%d" % absi(delta))


func _delta_chip(delta: int, magnitude: String) -> Dictionary:
	# {text, palette}: U+2212 minus and "±0 —" when flat (not the plain "+N" helpers).
	var text: String = "±0 —"
	if delta != 0:
		text = "%s%s %s" % ["+" if delta > 0 else "−", magnitude, "↑" if delta > 0 else "↓"]
	return {"text": text, "palette": UiTokens.badge_palette_for_delta(delta)}


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
