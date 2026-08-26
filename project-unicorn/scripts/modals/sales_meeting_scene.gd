class_name SalesMeetingScene
extends Control

# ACT 1's SURFACE (§5.1.1). A humble view over SalesMeetingSystem: it paints one view_state
# through `_render()` and routes clicks back. No rule lives here — the same split
# TermSheetTableScene uses, and the reason the headless suite can drive a whole meeting.
#
# §5.1.1 SEALS WHAT LIVES ON THIS SCREEN, and it is four things:
#   the customer header   name, star row, archetype in ONE line, the whale badge if any
#   the dialogue flow     the probe, plus the memory line and the budgeted inner voice
#   a QUIET needle        one percentage in the corner, hover for the reasons
#   this turn's answers   2-4 contextual rows, not a fixed palette
# There is NO product summary panel: "fiiller gerçeği süzer" — the answers are the product
# reading, and a panel beside them would let the player read the state without playing it.
#
# THE NEEDLE IS QUIET. It does not throw a badge per turn; it updates in the corner and the
# hover gives the whole list. The main feedback is the customer's own reaction line.
#
# process_mode = ALWAYS, in the .tscn AND re-asserted below. Speed 0 flips
# `get_tree().paused` (time_manager.gd:235); a paused Control still DRAWS but stops receiving
# `gui_input`, so every button here would render perfectly and swallow every click. It is
# invisible in the scene file and only a runtime click test finds it.
#
# ZERO NEW THEME ITEMS. Every variation used below already exists in build_theme.gd (the
# Dialogue* family the VC surface opened), so `UiTokens.THEME_STAMP` does not move. That is
# the sanctioned pattern rnd_ui_shared.gd:13-16 states: one-off shapes are built in code, not
# added to the theme.

signal closed()

const PAGE_MARGIN := 48
const COLUMN_MAX_W := 980

var _needle_label: Label = null
var _needle_box: Control = null
var _flow: VBoxContainer = null
var _answers: VBoxContainer = null
var _footer: HBoxContainer = null
var _header_right: VBoxContainer = null
var _header_left: VBoxContainer = null
var _negotiation: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_render(SalesMeetingSystem.view_state())


# ============================================================================
#  Build
# ============================================================================

func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UiTokens.DIALOGUE_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_top", PAGE_MARGIN)
	root.add_theme_constant_override("margin_bottom", PAGE_MARGIN)
	root.add_theme_constant_override("margin_left", UiTokens.SPACE_4XL)
	root.add_theme_constant_override("margin_right", UiTokens.SPACE_4XL)
	add_child(root)

	# A CENTRED COLUMN, NOT THE WHOLE SCREEN. A 1920-wide answer row is unreadable — the eye
	# has to travel the monitor to finish a sentence — and the acceptance gate's "no panel
	# larger than its content" is the same observation from the other side. The column is a
	# measure, and every row inside it inherits that measure rather than declaring its own.
	var centre := HBoxContainer.new()
	centre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(centre)
	centre.add_child(_grow())

	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(COLUMN_MAX_W, 0)
	col.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	# CONTENT-SIZED AND VERTICALLY CENTRED, not stretched. A stretched column pushes the
	# answers to the bottom of a 1080px screen and leaves a hole where the conversation
	# should be; a table is a few lines of talk, and it should look like a few lines of talk.
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	centre.add_child(col)
	centre.add_child(_grow())

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(header)

	_header_left = VBoxContainer.new()
	_header_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header_left.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	header.add_child(_header_left)

	# TOP-aligned, so the needle sits in the corner rather than drifting down beside the
	# archetype line and reading as part of the sentence.
	_header_right = VBoxContainer.new()
	_header_right.alignment = BoxContainer.ALIGNMENT_BEGIN
	_header_right.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_header_right.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	header.add_child(_header_right)

	col.add_child(_hairline())

	_flow = VBoxContainer.new()
	_flow.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(_flow)

	# The breathing room lives HERE, between what was said and what can be answered — a
	# measured gap rather than whatever is left over after the layout stretches.
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, UiTokens.SPACE_4XL)
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(gap)

	_answers = VBoxContainer.new()
	_answers.add_theme_constant_override("separation", UiTokens.SPACE_S)
	col.add_child(_answers)

	_footer = HBoxContainer.new()
	_footer.alignment = BoxContainer.ALIGNMENT_END
	_footer.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(_footer)


func _grow() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _hairline() -> Control:
	var line := Panel.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SEPARATOR
	line.add_theme_stylebox_override("panel", sb)
	return line


# ============================================================================
#  Render
# ============================================================================

func _render(vs: Dictionary) -> void:
	_render_header(vs)
	_render_flow(vs)
	_render_answers(vs)
	_render_footer(vs)


func _render_header(vs: Dictionary) -> void:
	var left: VBoxContainer = _header_left
	for c in left.get_children():
		c.queue_free()
	for c in _header_right.get_children():
		c.queue_free()

	left.add_child(UiFactory.make_label(String(vs.get("company_name", "")), &"DialogueName"))
	# Ekip §4.1's grammar, and the reason it is the shared component: the row ALWAYS draws
	# five glyphs, so the header does not shift width when a 1★ table follows a 3★ one.
	var stars := HBoxContainer.new()
	stars.add_theme_constant_override("separation", UiTokens.SPACE_S)
	stars.add_child(StarRating.make_stars(float(vs.get("star", 0)), 15))
	left.add_child(stars)
	var arch: String = String(vs.get("archetype_line", ""))
	if arch != "":
		left.add_child(UiFactory.make_label(arch, &"DialogueRole", UiTokens.INK_MUTED))

	# §8 — the whale's condition is TELEGRAPHED, and it was already on the card before the
	# founder sat down. Repeating it here is not noise: it is the thing the meeting is about.
	var cond: String = String(vs.get("whale_condition", ""))
	if cond != "":
		_header_right.add_child(UiFactory.make_badge(
			tr("SALES_WHALE_" + cond.to_upper()), "attention"))

	# THE QUIET NEEDLE (§5.1.1 + engine §9.6). A different tone says it is hoverable; the
	# reasons live in the hover and nowhere else, so the surface stays calm.
	var needle_col := VBoxContainer.new()
	needle_col.alignment = BoxContainer.ALIGNMENT_END
	needle_col.add_theme_constant_override("separation", 0)
	_needle_label = UiFactory.make_label(
		tr("SALES_ODDS").format({"n": int(round(float(vs.get("odds", 0.0)) * 100.0))}),
		&"DialogueOdds", UiTokens.ACCENT)
	_needle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	needle_col.add_child(_needle_label)
	# The affordance the engine's §9.6 asks for: the reading says, quietly, that there is more
	# behind it. The caption is what makes the hover discoverable without a badge per turn.
	var hint := UiFactory.make_label(tr("SALES_ODDS_HINT"), &"MicroLabel", UiTokens.INK_DIM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	needle_col.add_child(hint)

	_needle_box = PanelContainer.new()
	_needle_box.theme_type_variation = &"CardPanelTight"
	# PASS, not STOP: a tooltip host that eats clicks is a different bug, and this one sits
	# over nothing clickable anyway.
	_needle_box.mouse_filter = Control.MOUSE_FILTER_PASS
	_needle_box.tooltip_text = _tooltip_from(vs)
	_needle_box.add_child(needle_col)
	_header_right.add_child(_needle_box)


## engine §9.6 — signed, magnitude-sorted, NO NUMBERS, at most four lines with the remainder
## folded into one. The list arrives already shaped from EvDice.modifier_lines; all this does
## is join it.
func _tooltip_from(vs: Dictionary) -> String:
	var lines: Array = vs.get("modifier_lines", []) as Array
	if lines.is_empty():
		return ""
	var out: PackedStringArray = []
	for l in lines:
		var d: Dictionary = l as Dictionary
		out.append("%s %s" % [String(d.get("sign", "")), String(d.get("label", ""))])
	return "\n".join(out)


func _render_flow(vs: Dictionary) -> void:
	for c in _flow.get_children():
		c.queue_free()

	# §9 — the memory line. Only a company that actually walked out of a meeting has one.
	var memory: String = String(vs.get("memory_line", ""))
	if memory != "":
		var mem := UiFactory.make_label(memory, &"DialogueTag", UiTokens.INK_DIM)
		mem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_flow.add_child(mem)

	var body: String = ""
	if String(vs.get("outcome", "")) == "":
		body = tr(String(vs.get("probe_key", "")))
	else:
		body = tr(String(vs.get("closing_key", "")))
	var line := UiFactory.make_label(body, &"DialogueMonologue")
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_flow.add_child(line)

	# §5.1.1 — the inner voice is budgeted and conditional. When there is none, there is no
	# empty slot either: the absence is the design, not a gap to fill.
	var inner: String = String(vs.get("inner_voice", ""))
	if inner != "":
		var q := UiFactory.make_label(inner, &"QuoteSerif", UiTokens.INK_MUTED)
		q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_flow.add_child(q)


func _render_answers(vs: Dictionary) -> void:
	for c in _answers.get_children():
		c.queue_free()
	if String(vs.get("outcome", "")) != "":
		return
	for a in (vs.get("answers", []) as Array):
		_answers.add_child(_answer_row(a as Dictionary))


## §5.1.1 — the verbs are CONTEXTUAL: this row set belongs to this probe and no fixed palette
## is drawn every turn. A locked row is still an information sentence (§11.9): the reason
## names the game's real gap, and it is drawn only when it carries that information.
func _answer_row(a: Dictionary) -> Control:
	var open: bool = bool(a.get("open", false))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_XXS)

	var label: String = tr(String(a.get("text_key", "")))
	if open:
		var btn := Button.new()
		btn.text = label
		btn.theme_type_variation = &"DialogueChoice"
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 40)
		btn.focus_mode = Control.FOCUS_NONE   # no blind Enter/Space on open (ledger 11)
		btn.pressed.connect(_on_answer.bind(String(a.get("id", ""))))
		box.add_child(btn)
	else:
		var locked := UiFactory.make_label("🔒 " + label, &"LockedTelegraph", UiTokens.INK_DIM)
		locked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(locked)
		var reason_key: String = String(a.get("lock_key", ""))
		if reason_key != "":
			box.add_child(UiFactory.make_label(tr(reason_key), &"RowMeta", UiTokens.INK_DIM))
	return box


func _render_footer(vs: Dictionary) -> void:
	for c in _footer.get_children():
		c.queue_free()
	var outcome: String = String(vs.get("outcome", ""))
	if outcome == "":
		# §5.1.1 — "Teklife geç" opens from the SECOND probe and costs nothing but the ▲ the
		# remaining questions would have earned.
		if bool(vs.get("can_skip", false)):
			_footer.add_child(_button(tr("SALES_MEETING_SKIP"), _on_skip, &"DialogueGhost"))
		return
	if outcome == "won":
		_footer.add_child(_button(tr("SALES_MEETING_OPEN_OFFER"), _on_open_offer, &"CommitButton"))
	else:
		_footer.add_child(_button(tr("SALES_MEETING_CLOSE"), _on_close, &"DialogueGhost"))


func _button(text: String, cb: Callable, variation: StringName) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	return b


# ============================================================================
#  Routing
# ============================================================================

func _on_answer(answer_id: String) -> void:
	_render(SalesMeetingSystem.choose(answer_id))


func _on_skip() -> void:
	_render(SalesMeetingSystem.skip_to_offer())


func _on_close() -> void:
	closed.emit()


## §5.1.1 — "masa AYNI SAHNEDE Perde 2 moduna döner". Act 2 mounts over this scene rather
## than replacing it: the customer, the star row and the header stay exactly where they were,
## which is what makes it one sitting rather than two screens.
func _on_open_offer() -> void:
	if _negotiation != null:
		return
	var lead: Prospect = ProspectRegistry.get_prospect(SalesMeetingSystem.active_lead_id())
	if lead == null:
		closed.emit()
		return
	NegotiationSystem.open(NegotiationSystem.TYPE_B2B, {
		"account": lead.company_name,
		"lead_id": lead.id,
		"star": lead.star,
		"archetype": lead.archetype_id,
		"promised": SalesMeetingSystem.promised_feature(),
		"is_whale": lead.is_whale,
	})
	_negotiation = preload("res://scenes/modals/NegotiationScene.tscn").instantiate()
	_negotiation.closed.connect(_on_negotiation_closed)
	add_child(_negotiation)


func _on_negotiation_closed() -> void:
	if _negotiation != null:
		_negotiation.queue_free()
		_negotiation = null
	closed.emit()
