class_name TermSheetTableScene
extends Control

# Term Sheet Table view. A humble full-screen dark-register view over
# TermSheetTableSystem: it paints the system's view_state through one _render() and routes
# clicks back into the system (select lever, push, sign, walk). ALL negotiation math lives in
# the system — this scene only paints and animates the dial. Built programmatically (like
# hunt_tab's cards) over a minimal .tscn root so the layout is authored in one pass.
#
# The .tscn root carries process_mode = ALWAYS (live on the paused tree), the full-rect anchors
# and the click-eating mouse filter. No default focus (all buttons FOCUS_NONE), number keys 1-3
# select a lever, a blind Enter/Space on open does nothing. Every table state is just a
# different view_state through _render.

signal closed()

var _portrait_tex: TextureRect
var _name_label: Label
var _archetype_label: Label
var _pip_box: HBoxContainer
var _lever_rows: Array = []          # [{id, root, name_label, value_label, odds_label, push_btn}]
var _dial: RadialDial
var _result_caption: Label
var _leverage_box: PanelContainer
var _leverage_label: Label
var _investor_box: PanelContainer    # the fund's own line after every move (reveals E's band)
var _investor_tag: Label
var _investor_line: Label
var _show_other_btn: Button          # show the other live Series A sheet, once per table
var _frank_label: Label
var _kasa_label: Label
var _counter_label: Label
var _sign_btn: Button
var _walk_btn: Button
var _investment_label: Label
var _derived_label: Label            # seed only: the implied post-money under the money row

var _spinning: bool = false
var _leave_mode: bool = false        # the fund walked out; the walk row now just leaves
var _pending_vs: Dictionary = {}


func _ready() -> void:
	_build()
	_dial.spin_finished.connect(_on_spin_finished)
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)
	# main open()s the system before mounting this scene, so it self-renders from it.
	_render(TermSheetTableSystem.view_state())


# ============================================================================
# Build (programmatic layout)
# ============================================================================

func _build() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UiTokens.DIALOGUE_BG              # from token, never inline (grep gate)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 56)
	root.add_theme_constant_override("margin_right", 56)
	root.add_theme_constant_override("margin_top", 36)
	root.add_theme_constant_override("margin_bottom", 30)
	add_child(root)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	root.add_child(col)

	col.add_child(_build_header())

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 28)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(columns)
	columns.add_child(_build_left_column())
	columns.add_child(_build_right_column())

	col.add_child(_build_footer())


func _build_header() -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogueCard"
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	panel.add_child(hb)

	# Compact 64×64 framed portrait (the shared DialoguePortraitCard is a 260×325 meeting bust,
	# too large for a header — build a small one with the same cream PortraitFrame).
	var frame := PanelContainer.new()
	frame.theme_type_variation = &"PortraitFrame"
	frame.clip_contents = true
	frame.custom_minimum_size = Vector2(64, 64)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_portrait_tex = TextureRect.new()
	_portrait_tex.custom_minimum_size = Vector2(64, 64)
	_portrait_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(_portrait_tex)
	hb.add_child(frame)

	var idcol := VBoxContainer.new()
	idcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	idcol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	idcol.add_theme_constant_override("separation", 2)
	hb.add_child(idcol)
	_name_label = UiFactory.make_label("", &"DialogueName")
	idcol.add_child(_name_label)
	_archetype_label = UiFactory.make_label("", &"DialogueRole")
	idcol.add_child(_archetype_label)

	var patcol := VBoxContainer.new()
	patcol.alignment = BoxContainer.ALIGNMENT_CENTER
	patcol.add_theme_constant_override("separation", 6)
	hb.add_child(patcol)
	var sabir := UiFactory.make_label(tr("TERM_PATIENCE"), &"ZoneLabel")
	sabir.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	patcol.add_child(sabir)
	_pip_box = HBoxContainer.new()
	_pip_box.alignment = BoxContainer.ALIGNMENT_END
	_pip_box.add_theme_constant_override("separation", 6)
	patcol.add_child(_pip_box)

	return panel


func _build_left_column() -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogueColumn"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.25
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	vb.add_child(UiFactory.make_label(tr("TERM_OFFER_HEADER"), &"ZoneLabel"))

	_lever_rows.clear()
	# levers(), NOT the LEVERS const: every row binds its lever id into its handlers here, and
	# the seed table's first row is a RAISE. main.gd opens the system before it instantiates
	# the scene, so the stage is already settled by the time this runs.
	for lever_id in TermSheetTableSystem.levers():
		vb.add_child(_build_lever_row(lever_id))

	return panel


func _build_lever_row(lever_id: String) -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogueCard"
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_lever_row_input.bind(lever_id))

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	var top := HBoxContainer.new()
	vb.add_child(top)
	var name_label := UiFactory.make_label("", &"ZoneLabel")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_label)
	var push_btn := _button(tr("TERM_PUSH"), &"CommitButton", _on_push_pressed.bind(lever_id))
	top.add_child(push_btn)

	var value_label := UiFactory.make_label("", &"DialogueName")
	vb.add_child(value_label)

	var odds_label := UiFactory.make_label("", &"DialogueOdds")
	vb.add_child(odds_label)

	_lever_rows.append({
		"id": lever_id, "root": panel, "name_label": name_label,
		"value_label": value_label, "odds_label": odds_label, "push_btn": push_btn,
	})
	return panel


func _build_right_column() -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogueColumn"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	panel.add_child(vb)

	vb.add_child(UiFactory.make_label(tr("TERM_RESULT_HEADER"), &"ZoneLabel"))

	_dial = RadialDial.new()
	vb.add_child(_dial)

	_result_caption = UiFactory.make_label("", &"QuoteSerifCream")
	_result_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_result_caption)

	# The investor speaks in the meeting's spoken-line grammar: amber-edged QuoteBox, speaker
	# tag above the line. Hidden until the fund has something to say.
	_investor_box = PanelContainer.new()
	_investor_box.theme_type_variation = &"QuoteBox"
	var inv_vb := VBoxContainer.new()
	inv_vb.add_theme_constant_override("separation", 4)
	_investor_box.add_child(inv_vb)
	_investor_tag = UiFactory.make_label("", &"DialogueTag")
	inv_vb.add_child(_investor_tag)
	_investor_line = UiFactory.make_label("", &"QuoteSerifCream")
	_investor_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inv_vb.add_child(_investor_line)
	_investor_box.visible = false
	vb.add_child(_investor_box)

	_leverage_box = PanelContainer.new()
	_leverage_box.theme_type_variation = &"QuoteBox"
	var lev_vb := VBoxContainer.new()
	_leverage_box.add_child(lev_vb)
	_leverage_label = UiFactory.make_label("", &"DialogueMonologue")
	_leverage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lev_vb.add_child(_leverage_label)
	vb.add_child(_leverage_box)

	_show_other_btn = _button(tr("TERM_SHOW_OTHER"), &"DialogueGhost", _on_show_other_pressed)
	_show_other_btn.visible = false
	vb.add_child(_show_other_btn)

	_frank_label = UiFactory.make_label("", &"DialogueMonologue")
	_frank_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_frank_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(_frank_label)

	return panel


func _build_footer() -> Control:
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)

	# Pressure strip: Kasa · Runway (left) — Kapanan masa (right).
	var strip := HBoxContainer.new()
	outer.add_child(strip)
	_kasa_label = UiFactory.make_label("", &"StatStripLabel")
	_kasa_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.add_child(_kasa_label)
	_counter_label = UiFactory.make_label("", &"DialogueTag")
	_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	strip.add_child(_counter_label)

	# Actions: MASADAN KALK (left) — $X yatırım (center) — İMZALA (right).
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 16)
	outer.add_child(actions)
	_walk_btn = _button(tr("TERM_WALK_OK"), &"DialogueGhost", _on_walk_pressed)
	actions.add_child(_walk_btn)

	# The money and its derived caption stack, so the seed table can say "$120.000 yatırım"
	# with "ima edilen değerleme $800.000" directly beneath it.
	var money_col := VBoxContainer.new()
	money_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	money_col.add_theme_constant_override("separation", 2)
	actions.add_child(money_col)
	_investment_label = Label.new()
	_investment_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_investment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_investment_label.add_theme_font_size_override("font_size", 24)
	_investment_label.add_theme_color_override("font_color", UiTokens.CREAM)
	money_col.add_child(_investment_label)

	# The seed table's derived readout: raise / dilution, under the money it is derived from.
	# A LABEL AND NOT A ROW, deliberately — the implied valuation is shown and never
	# negotiated, and having no lever row for it makes that structural rather than a guard
	# somebody can forget. DialogueTag is the closed-tables counter's variation, so the label
	# adds no theme surface.
	_derived_label = UiFactory.make_label("", &"DialogueTag")
	_derived_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_derived_label.visible = false
	money_col.add_child(_derived_label)

	_sign_btn = _button(tr("TERM_SIGN_OK"), &"CommitButton", _on_sign_pressed)
	_sign_btn.custom_minimum_size = Vector2(200, 0)
	actions.add_child(_sign_btn)

	return outer


func _button(text: String, variation: StringName, on_pressed: Callable) -> Button:
	var b := Button.new()
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE     # mouse only, no keyboard grab
	b.text = text
	b.pressed.connect(on_pressed)
	return b


# ============================================================================
# Render — the single paint of a view_state
# ============================================================================

func _render(vs: Dictionary) -> void:
	_name_label.text = UiTokens.tr_upper(String(vs.get("display_name", "")))
	_archetype_label.text = String(vs.get("archetype_line", ""))
	var pp: String = String(vs.get("portrait_path", ""))
	_portrait_tex.texture = load(pp) if (pp != "" and ResourceLoader.exists(pp)) else null
	_render_pips(vs.get("patience", {}))

	var levers: Array = vs.get("levers", [])
	var selected: String = String(vs.get("selected_lever", ""))
	for i in mini(_lever_rows.size(), levers.size()):
		var L: Dictionary = levers[i]
		var row: Dictionary = _lever_rows[i]
		var cur: String = String(L.get("current_text", ""))
		var ghost: String = String(L.get("ghost_text", ""))
		row.name_label.text = UiTokens.tr_upper(String(L.get("name_tr", "")))
		row.value_label.text = ("%s → %s" % [cur, ghost]) if ghost != "" else cur
		row.odds_label.text = String(L.get("odds", {}).get("split_text", ""))
		row.push_btn.disabled = (not bool(L.get("push_enabled", false))) or _spinning
		row.root.modulate = Color(1, 1, 1, 1.0) if String(L.get("id", "")) == selected else Color(1, 1, 1, 0.5)

	var dial: Dictionary = vs.get("dial", {})
	var result: String = String(dial.get("result", ""))
	if result == "":
		_dial.set_odds(float(dial.get("chance", 0.5)))
	else:
		_dial.show_result_rest(float(dial.get("chance", 0.5)), result == "success")

	_result_caption.text = String(vs.get("result_caption", ""))
	_result_caption.add_theme_color_override("font_color", _caption_color(result))

	var lev: Dictionary = vs.get("leverage", {})
	_leverage_box.visible = bool(lev.get("active", false))
	_leverage_label.text = String(lev.get("box_text", ""))
	_frank_label.text = String(vs.get("frank_line", ""))

	var inv_line: String = String(vs.get("investor_line", ""))
	_investor_box.visible = inv_line != ""
	_investor_line.text = inv_line
	_investor_tag.text = _name_label.text

	var so: Dictionary = vs.get("show_other", {})
	_show_other_btn.visible = bool(so.get("visible", false))
	_show_other_btn.disabled = (not bool(so.get("enabled", false))) or _spinning
	_show_other_btn.tooltip_text = tr("TERM_SHOW_OTHER_USED") if bool(so.get("used", false)) else ""

	var footer: Dictionary = vs.get("footer", {})
	_kasa_label.text = String(footer.get("kasa_runway_text", ""))
	_counter_label.text = String(footer.get("counter_text", ""))
	_investment_label.text = tr("TERM_INVESTMENT").format(
		{"amount": UiTokens.format_money(int(vs.get("money_raised", 0)))})
	_sign_btn.disabled = (not bool(vs.get("sign_enabled", false))) or _spinning
	_walk_btn.disabled = (not bool(vs.get("walk_enabled", false))) or _spinning
	# After the fund walked out the same row is the only exit, and it only leaves the room:
	# the closure was written when they stood up.
	_leave_mode = String(vs.get("walk_mode", "walk")) == "leave"
	_walk_btn.text = tr("TERM_LEAVE") if _leave_mode else tr("TERM_WALK_OK")
	# LOCKED-VISIBLE, the Frank-cheque grammar: the row stays on screen at half alpha and its
	# tooltip names the real shortfall, rather than the button quietly disappearing.
	var lock: Dictionary = vs.get("walk_lock", {})
	var locked: bool = bool(lock.get("locked", false))
	_walk_btn.modulate.a = 0.5 if locked else 1.0
	_walk_btn.tooltip_text = tr(String(lock.get("reason_key", ""))) if locked else ""
	var caption: String = String(vs.get("derived_caption", ""))
	_derived_label.text = caption
	_derived_label.visible = caption != ""


func _render_pips(p: Dictionary) -> void:
	for c in _pip_box.get_children():
		c.queue_free()
	var cur: int = int(p.get("current", 0))
	var mx: int = int(p.get("max", 0))
	for i in mx:
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(14, 14)
		dot.color = UiTokens.ACCENT if i < cur else UiTokens.CONVICTION_TRACK_BG
		_pip_box.add_child(dot)


func _caption_color(result: String) -> Color:
	match result:
		"success": return UiTokens.positive_bright()
		"failure": return UiTokens.negative_bright()
		_: return UiTokens.CREAM


# ============================================================================
# Interaction — route back into the system (select, push, show other, sign, walk, leave)
# ============================================================================

func _on_lever_row_input(event: InputEvent, lever_id: String) -> void:
	if _spinning:
		return
	if event is InputEventMouseButton and event.pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_render(TermSheetTableSystem.select_lever(lever_id))


func _on_push_pressed(lever_id: String) -> void:
	if _spinning:
		return
	TermSheetTableSystem.select_lever(lever_id)
	if not TermSheetTableSystem.can_push(lever_id):
		_render(TermSheetTableSystem.view_state())
		return
	var chance: float = float(TermSheetTableSystem.odds_for(lever_id).chance)  # pre-decay odds rolled
	_spinning = true
	for row in _lever_rows:
		row.push_btn.disabled = true               # double-fire guard while the dial spins
	_pending_vs = TermSheetTableSystem.push()      # already-settled result
	var passed: bool = String(_pending_vs.get("dial", {}).get("result", "")) == "success"
	_dial.spin(chance, passed)


func _on_spin_finished() -> void:
	_spinning = false
	_render(_pending_vs)


func _on_sign_pressed() -> void:
	if _spinning:
		return
	var vs: Dictionary = TermSheetTableSystem.view_state()
	EventBus.confirm_requested.emit({
		"title": tr("TERM_SIGN_Q"),
		"body": tr("TERM_SIGN_BODY").format({
			"amount": UiTokens.format_money(int(vs.get("money_raised", 0))),
			"terms": _terms_line(vs)}),
		"confirm_text": tr("TERM_SIGN_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_sign,
	})


func _do_sign() -> void:
	TermSheetTableSystem.sign()   # Series A fires the Hard Win ending; seed closes the round (no ending)
	closed.emit()


func _on_walk_pressed() -> void:
	if _spinning:
		return
	if _leave_mode:
		TermSheetTableSystem.leave()   # nothing to confirm: the fund already closed the door
		closed.emit()
		return
	EventBus.confirm_requested.emit({
		"title": tr("TERM_WALK_Q"),
		"body": tr("TERM_WALK_BODY"),
		"confirm_text": tr("TERM_WALK_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_walk,
	})


func _on_show_other_pressed() -> void:
	if _spinning:
		return
	_render(TermSheetTableSystem.show_other_offer())


func _do_walk() -> void:
	TermSheetTableSystem.walk()   # sheet destroyed, fund closed, others survive; the player's walk is not a rejection
	closed.emit()


func _terms_line(vs: Dictionary) -> String:
	var parts: Array = []
	for L in vs.get("levers", []):
		parts.append(String(L.get("current_text", "")))
	return " · ".join(parts)


func _input(event: InputEvent) -> void:
	# Number keys 1-3 select a lever; Enter/Space/ESC deliberately unbound (inert).
	if _spinning:
		return
	if not (event is InputEventKey and event.pressed and not (event as InputEventKey).echo):
		return
	var idx := -1
	match (event as InputEventKey).keycode:
		KEY_1, KEY_KP_1: idx = 0
		KEY_2, KEY_KP_2: idx = 1
		KEY_3, KEY_KP_3: idx = 2
	# The rows were built from levers(), so at seed key 1 is the raise row.
	if idx >= 0 and idx < _lever_rows.size():
		get_viewport().set_input_as_handled()
		_render(TermSheetTableSystem.select_lever(String(_lever_rows[idx].id)))
