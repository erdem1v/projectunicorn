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
#
# THE STAGE IS NOT THIS FILE'S (rev 6.1 §5.1.1). The room, the scrim, the dialogue column and
# the identity block at its head belong to `SalesStage`; this scene owns only what happens
# INSIDE the column — the needle, the talk, the answers and the footer. That split is what
# lets Perde 2 take the same column without the background or the header moving.

signal closed()

var _stage: SalesStage = null
var _needle_label: Label = null
var _needle_box: Control = null
var _needle_row: HBoxContainer = null
var _flow: VBoxContainer = null
var _answers: VBoxContainer = null
var _footer: HBoxContainer = null
var _negotiation: Node = null
var _identity: Dictionary = {}


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

	# The room, the scrim, the column and the identity header all arrive with the stage. What
	# follows fills the region under that header, and nothing here knows where the column is.
	_stage = SalesStage.new()
	add_child(_stage)
	var col: Control = _stage.content_host()

	# THE QUIET NEEDLE, in the column's corner (§5.1.1). Right-aligned on its own row so it
	# sits above the talk rather than beside it — beside the archetype line it would read as
	# part of the sentence.
	_needle_row = HBoxContainer.new()
	_needle_row.alignment = BoxContainer.ALIGNMENT_END
	col.add_child(_needle_row)

	# THE CONVERSATION IS ONE BLOCK, CENTRED. Two equal spacers around it and a FIXED gap
	# inside: a question and the answers to it are one thought, and the leftover height of a
	# 1080px column belongs outside that thought, not between its halves. Both alternatives
	# were shot and read: everything top-aligned left 580px of void underneath, and spacing
	# the answers away from the probe put 260px between a question and its own replies.
	col.add_child(_flex(1.0))

	_flow = VBoxContainer.new()
	_flow.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(_flow)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, UiTokens.SPACE_XL)
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(gap)

	_answers = VBoxContainer.new()
	_answers.add_theme_constant_override("separation", UiTokens.SPACE_S)
	col.add_child(_answers)

	# The footer rides the column's bottom edge, the way the VC scene's beat label does, so
	# "Teklife geç" never wanders up into the talk.
	col.add_child(_flex(1.0))

	_footer = HBoxContainer.new()
	_footer.alignment = BoxContainer.ALIGNMENT_END
	_footer.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(_footer)


## An empty control that eats leftover height in proportion to `ratio`. Godot divides a
## container's spare space between EXPAND children by `size_flags_stretch_ratio`, which is what
## makes two of these a layout rather than a guess.
func _flex(ratio: float) -> Control:
	var c := Control.new()
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.size_flags_stretch_ratio = ratio
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


# ============================================================================
#  Render
# ============================================================================

func _render(vs: Dictionary) -> void:
	_render_header(vs)
	_render_flow(vs)
	_render_answers(vs)
	_render_footer(vs)


## The identity block is the STAGE's; this hands it the same four facts §5.1.1 names and then
## paints the one thing that belongs to the column's own corner.
##
## IT REMEMBERS WHO IS AT THE TABLE, and it has to. `_lose()` calls `ProspectRegistry.remove()`
## before returning its own view_state (sales_meeting_system.gd), so the closing frame arrives
## with no company, no star and no archetype — correct for the pipeline, absurd on screen: the
## customer would evaporate while still saying why they are leaving. The system is right and
## frozen; the view keeps the last identity it was given. Caught by reading the loss frame.
func _render_header(vs: Dictionary) -> void:
	var company: String = String(vs.get("company_name", ""))
	if company != "":
		_identity = {
			"portrait_path": _portrait_path_for(vs),
			"name": company,
			"star": int(vs.get("star", 0)),
			"archetype_line": String(vs.get("archetype_line", "")),
			"whale_condition": String(vs.get("whale_condition", "")),
		}
	if not _identity.is_empty():
		_stage.set_identity(_identity)
	_render_needle(vs)


## THE PORTRAIT SEAM, and it is deliberately the only one. §5.1.1 allows "portre ya da baş harf
## avatarı"; today it is always the avatar, because no customer record carries a portrait —
## `Prospect` has no such field and adding one would be a save-schema change. When customer art
## lands, it is read HERE and in no other place.
func _portrait_path_for(_vs: Dictionary) -> String:
	return ""


func _render_needle(vs: Dictionary) -> void:
	for c in _needle_row.get_children():
		_needle_row.remove_child(c)
		c.queue_free()

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

	# NO PANEL AROUND IT. `CardPanelTight` is terminal-card grammar and §5.1.1 bans that
	# grammar from this scene outright — "o gramer Satış sekmesinindir". The needle is two
	# lines of type in the column's corner; the hover is the affordance, not a frame.
	# PASS, not STOP: a tooltip host that eats clicks is a different bug, and this one sits
	# over nothing clickable anyway.
	_needle_box = needle_col
	_needle_box.mouse_filter = Control.MOUSE_FILTER_PASS
	_needle_box.tooltip_text = _tooltip_from(vs)
	_needle_row.add_child(_needle_box)


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


## §5.1.1 — "masa AYNI SAHNEDE Perde 2 moduna döner". Only the column's CONTENT changes: the
## room, the scrim, the portrait and the header are never touched, so there is no blink and no
## header jump to animate away. One sitting, not two screens, structurally.
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
	# Perde 1's rows go with the clear; the references would dangle, so they are dropped in
	# the same breath. Nothing re-renders Act 1 after this point.
	_stage.clear_content()
	_needle_row = null
	_needle_box = null
	_needle_label = null
	_flow = null
	_answers = null
	_footer = null
	_negotiation = preload("res://scenes/modals/NegotiationScene.tscn").instantiate()
	_negotiation.closed.connect(_on_negotiation_closed)
	_stage.content_host().add_child(_negotiation)


func _on_negotiation_closed() -> void:
	if _negotiation != null:
		_negotiation.queue_free()
		_negotiation = null
	closed.emit()
