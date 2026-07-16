class_name TermSheetTableScene
extends Control

# Term Sheet Table view (Spec 6). A humble full-screen dark-register view over
# TermSheetTableSystem: it paints the system's view_state through one _render() and routes
# clicks back into the system (select lever, push, sign, walk). ALL negotiation math lives in
# the system — this scene only paints and animates the dial. Built programmatically (like
# hunt_tab's cards) over a minimal .tscn root so the layout is authored in one pass.
#
# process_mode = ALWAYS (.tscn) keeps it live on the paused tree (ledger 6/9). Ledger 11: no
# default focus (all buttons FOCUS_NONE), number keys 1-3 select a lever, a blind Enter/Space
# on open does nothing. The seven states (§3) are all just different view_states through _render.

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
var _frank_label: Label
var _kasa_label: Label
var _counter_label: Label
var _sign_btn: Button
var _walk_btn: Button
var _investment_label: Label

var _spinning: bool = false
var _pending_vs: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_dial.spin_finished.connect(_on_spin_finished)
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)
	# The system was open()ed by main before mount — self-render from it (humble view).
	_render(TermSheetTableSystem.view_state())


# ============================================================================
# Build (programmatic layout)
# ============================================================================

func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

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
	_name_label = Label.new()
	_name_label.theme_type_variation = &"DialogueName"
	idcol.add_child(_name_label)
	_archetype_label = Label.new()
	_archetype_label.theme_type_variation = &"DialogueRole"
	idcol.add_child(_archetype_label)

	var patcol := VBoxContainer.new()
	patcol.alignment = BoxContainer.ALIGNMENT_CENTER
	patcol.add_theme_constant_override("separation", 6)
	hb.add_child(patcol)
	var sabir := Label.new()
	sabir.theme_type_variation = &"ZoneLabel"
	sabir.text = "SABIR"
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

	var header := Label.new()
	header.theme_type_variation = &"ZoneLabel"
	header.text = "MASADAKİ TEKLİF"
	vb.add_child(header)

	_lever_rows.clear()
	for lever_id in TermSheetTableSystem.LEVERS:
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
	var name_label := Label.new()
	name_label.theme_type_variation = &"ZoneLabel"
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_label)
	var push_btn := Button.new()
	push_btn.theme_type_variation = &"CommitButton"
	push_btn.focus_mode = Control.FOCUS_NONE     # ledger 11 — mouse only, no keyboard grab
	push_btn.text = "İTİR"
	push_btn.pressed.connect(_on_push_pressed.bind(lever_id))
	top.add_child(push_btn)

	var value_label := Label.new()
	value_label.theme_type_variation = &"DialogueName"
	vb.add_child(value_label)

	var odds_label := Label.new()
	odds_label.theme_type_variation = &"DialogueOdds"
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

	var header := Label.new()
	header.theme_type_variation = &"ZoneLabel"
	header.text = "SONUÇ"
	vb.add_child(header)

	_dial = RadialDial.new()
	vb.add_child(_dial)

	_result_caption = Label.new()
	_result_caption.theme_type_variation = &"QuoteSerifCream"
	_result_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_result_caption)

	_leverage_box = PanelContainer.new()
	_leverage_box.theme_type_variation = &"QuoteBox"
	var lev_vb := VBoxContainer.new()
	_leverage_box.add_child(lev_vb)
	_leverage_label = Label.new()
	_leverage_label.theme_type_variation = &"DialogueMonologue"
	_leverage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lev_vb.add_child(_leverage_label)
	vb.add_child(_leverage_box)

	_frank_label = Label.new()
	_frank_label.theme_type_variation = &"DialogueMonologue"
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
	_kasa_label = Label.new()
	_kasa_label.theme_type_variation = &"StatStripLabel"
	_kasa_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.add_child(_kasa_label)
	_counter_label = Label.new()
	_counter_label.theme_type_variation = &"DialogueTag"
	_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	strip.add_child(_counter_label)

	# Actions: MASADAN KALK (left) — $X yatırım (center) — İMZALA (right).
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 16)
	outer.add_child(actions)
	_walk_btn = Button.new()
	_walk_btn.theme_type_variation = &"DialogueGhost"
	_walk_btn.focus_mode = Control.FOCUS_NONE
	_walk_btn.text = "MASADAN KALK"
	_walk_btn.pressed.connect(_on_walk_pressed)
	actions.add_child(_walk_btn)

	_investment_label = Label.new()
	_investment_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_investment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_investment_label.add_theme_font_size_override("font_size", 24)
	_investment_label.add_theme_color_override("font_color", UiTokens.CREAM)
	actions.add_child(_investment_label)

	_sign_btn = Button.new()
	_sign_btn.theme_type_variation = &"CommitButton"
	_sign_btn.focus_mode = Control.FOCUS_NONE
	_sign_btn.text = "İMZALA"
	_sign_btn.custom_minimum_size = Vector2(200, 0)
	_sign_btn.pressed.connect(_on_sign_pressed)
	actions.add_child(_sign_btn)

	return outer


# ============================================================================
# Render — the single paint of a view_state (anti-gap discipline)
# ============================================================================

func _render(vs: Dictionary) -> void:
	if vs.is_empty():
		return
	_name_label.text = String(vs.get("display_name", "")).to_upper()
	_archetype_label.text = String(vs.get("archetype_line", ""))
	var pp: String = String(vs.get("portrait_path", ""))
	_portrait_tex.texture = load(pp) if (pp != "" and ResourceLoader.exists(pp)) else null
	_render_pips(vs.get("patience", {}))

	var levers: Array = vs.get("levers", [])
	var selected: String = String(vs.get("selected_lever", ""))
	for i in _lever_rows.size():
		if i >= levers.size():
			continue
		var L: Dictionary = levers[i]
		var row: Dictionary = _lever_rows[i]
		var cur: String = String(L.get("current_text", ""))
		var ghost: String = String(L.get("ghost_text", ""))
		row.name_label.text = String(L.get("name_tr", "")).to_upper()
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

	var footer: Dictionary = vs.get("footer", {})
	_kasa_label.text = String(footer.get("kasa_runway_text", ""))
	_counter_label.text = String(footer.get("counter_text", ""))
	_investment_label.text = "%s yatırım" % UiTokens.format_money(int(vs.get("money_raised", 0)))
	_sign_btn.disabled = (not bool(vs.get("sign_enabled", false))) or _spinning
	_walk_btn.disabled = (not bool(vs.get("walk_enabled", false))) or _spinning


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
		"success": return UiTokens.POSITIVE_BRIGHT
		"failure": return UiTokens.NEGATIVE_BRIGHT
		_: return UiTokens.CREAM


# ============================================================================
# Interaction — route back into the system (S2 select, S3/S4/S5 push, S7 sign/walk)
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
	_set_pushes_enabled(false)                     # S3 — double-fire guard
	_pending_vs = TermSheetTableSystem.push()      # already-settled result
	var passed: bool = String(_pending_vs.get("dial", {}).get("result", "")) == "success"
	_dial.spin(chance, passed)


func _on_spin_finished() -> void:
	if not _spinning:
		return
	_spinning = false
	var vs: Dictionary = _pending_vs if not _pending_vs.is_empty() else TermSheetTableSystem.view_state()
	_pending_vs = {}
	_render(vs)


func _set_pushes_enabled(on: bool) -> void:
	for row in _lever_rows:
		row.push_btn.disabled = not on


func _on_sign_pressed() -> void:
	if _spinning:
		return
	var vs: Dictionary = TermSheetTableSystem.view_state()
	EventBus.confirm_requested.emit({
		"title": "İmzala?",
		"body": "%s yatırım · %s ile imzala? Bu turu kapatır." % [
			UiTokens.format_money(int(vs.get("money_raised", 0))), _terms_line(vs)],
		"confirm_text": "İMZALA",
		"cancel_text": "Vazgeç",
		"on_confirm": Callable(self, "_do_sign"),
	})


func _do_sign() -> void:
	TermSheetTableSystem.sign()   # fires the Series A Hard Win ending
	closed.emit()


func _on_walk_pressed() -> void:
	if _spinning:
		return
	EventBus.confirm_requested.emit({
		"title": "Masadan kalk?",
		"body": "Masadan kalkarsan bu teklif gider. Bu bir kapanan masa sayılır.",
		"confirm_text": "MASADAN KALK",
		"cancel_text": "Vazgeç",
		"on_confirm": Callable(self, "_do_walk"),
	})


func _do_walk() -> void:
	TermSheetTableSystem.walk()   # +1 rejection, sheet destroyed, others survive
	closed.emit()


func _terms_line(vs: Dictionary) -> String:
	var parts: Array = []
	for L in vs.get("levers", []):
		parts.append(String(L.get("current_text", "")))
	return " · ".join(parts)


func _initials(full_name: String) -> String:
	var out := ""
	for p in full_name.strip_edges().split(" ", false):
		if p.length() > 0:
			out += p[0]
		if out.length() >= 2:
			break
	return out.to_upper()


func _input(event: InputEvent) -> void:
	# Ledger 11: number keys 1-3 select a lever; Enter/Space/ESC deliberately unbound (inert).
	if _spinning:
		return
	if not (event is InputEventKey and event.pressed and not (event as InputEventKey).echo):
		return
	var idx := -1
	match (event as InputEventKey).keycode:
		KEY_1, KEY_KP_1: idx = 0
		KEY_2, KEY_KP_2: idx = 1
		KEY_3, KEY_KP_3: idx = 2
	if idx >= 0 and idx < TermSheetTableSystem.LEVERS.size():
		get_viewport().set_input_as_handled()
		_render(TermSheetTableSystem.select_lever(TermSheetTableSystem.LEVERS[idx]))
