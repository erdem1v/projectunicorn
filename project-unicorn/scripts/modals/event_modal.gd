extends Control

# Event modal — mounted into GameShell/ModalLayer by main.gd when the engine
# emits modal_requested. Editorial paper card: mono-caps header (source chip +
# "KARAR · GÜN N" + subtitle), serif headline and body, compact speaker strip,
# choice cards with right-aligned effect chips, mono footer. No countdown: the
# game pauses while open.
#
# Layout is built in code over a bare .tscn root. Colors come from UiTokens,
# styleboxes from master_theme.tres variations, widgets from UiFactory.
#
# Lifecycle: main.gd instances → populate(event) → player clicks a choice →
# EventGate.resolve() → event_resolved → main.gd frees this node.
# process_mode = ALWAYS (.tscn) so input works while the tree is paused.

## A part's polarity as this card's badge: red is danger only, a cost reads in ink.
const BADGE_KIND := {"gain": &"positive", "cost": &"neutral", "danger": &"negative", "neutral": &"neutral"}

var _event: GameEvent = null
var _resolved: bool = false  # one-shot guard against double-click

var _header_row: HBoxContainer
var _title_label: Label
var _body_rich: RichTextLabel
var _speaker_row: HBoxContainer
var _choices_host: VBoxContainer
var _footer_rule: Panel
var _footer_label: Label


func _ready() -> void:
	_build_skeleton()


func populate(event: GameEvent) -> void:
	_event = event
	if not is_node_ready():
		await ready
	_fill_header()
	_title_label.text = event.title
	_body_rich.text = _markdown_to_bbcode(event.body_text)
	_build_speaker_row()
	_render_choices()
	var readout: bool = _is_readout()
	_footer_rule.visible = not readout
	_footer_label.visible = not readout


# --- Static frame (built once from _ready) ---

func _build_skeleton() -> void:
	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = UiTokens.SCRIM_MODAL
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)

	# Fixed 780 width; height hugs the content (grows symmetrically around the
	# center anchor when the minimum size rises).
	var panel := PanelContainer.new()
	panel.name = "CenterPanel"
	panel.theme_type_variation = &"ModalCard"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(780, 420)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(panel)

	var body := VBoxContainer.new()
	body.name = "Body"
	body.add_theme_constant_override("separation", 10)
	panel.add_child(body)

	_header_row = HBoxContainer.new()
	_header_row.add_theme_constant_override("separation", 8)
	body.add_child(_header_row)

	_title_label = UiFactory.make_label("", &"ModalTitleSerif")
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_title_label)

	body.add_child(HRUiShared.hairline())

	# fit_content sizes the label to its text (card hugs content); EXPAND_FILL
	# absorbs the slack when the card sits at its 420px floor instead.
	_body_rich = RichTextLabel.new()
	_body_rich.theme_type_variation = &"BodyRich"
	_body_rich.bbcode_enabled = true
	_body_rich.fit_content = true
	_body_rich.scroll_active = false
	_body_rich.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_rich.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_body_rich)

	_speaker_row = HBoxContainer.new()
	_speaker_row.add_theme_constant_override("separation", 8)
	_speaker_row.visible = false
	body.add_child(_speaker_row)

	_choices_host = VBoxContainer.new()
	_choices_host.add_theme_constant_override("separation", 8)
	body.add_child(_choices_host)

	# Built always, SHOWN from `populate`: a readout hides the permanence warning (see
	# `_is_readout`), and there is no event to ask yet in `_ready()`.
	_footer_rule = HRUiShared.hairline()
	body.add_child(_footer_rule)
	_footer_label = UiFactory.make_label(
		UiTokens.tr_upper(tr("EVENT_CHOICE_PERMANENT")), &"MicroLabel")
	_footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(_footer_label)


## True when this card decides nothing: one option, and it carries no modifiers (the shape
## §17.1 forces on an information card, e.g. the weekly sales summary's single "Kapat"). A
## readout wears no decision chrome: no "KARAR · GÜN N" stamp and no "SEÇİM KALICIDIR"
## warning, both of which would be false. `GameEvent` carries no card class, so the test is
## derived from the card's shape rather than declared.
func _is_readout() -> bool:
	return _event != null and _event.choices.size() == 1 \
		and (_event.choices[0] as EventChoice).modifiers.is_empty()


# --- Header row ---

func _fill_header() -> void:
	for child in _header_row.get_children():
		child.queue_free()
	var tag: Dictionary = EvChips.source_tag(_event)
	_header_row.add_child(UiFactory.make_badge(String(tag.text), StringName(tag.kind)))
	var day_key: String = "EVENT_READOUT_DAY" if _is_readout() else "EVENT_DECISION_DAY"
	var meta := UiFactory.make_label(UiTokens.tr_upper(
		tr(day_key).format({"date": Fmt.date_line(GameState.get_date_dict())})), &"SectionLabel")
	meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_header_row.add_child(meta)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header_row.add_child(spacer)
	if _event.subtitle != "":
		var sub := UiFactory.make_label(UiTokens.tr_upper(_live_subtitle(_event.subtitle)), &"MicroLabel")
		sub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_header_row.add_child(sub)


# A subtitle ending in " · HH:MM" gets its HOUR rewritten from the live clock, keeping the
# authored minutes: the engine has no minute concept and the TopBar shows the live hour a few
# pixels away, so a baked hour would contradict it. Opt-in by shape only: a subtitle without
# a trailing stamp (or with a colon elsewhere) stays exactly as written. Anything after the
# stamp (e.g. a " [DEBUG]" marker) rides along untouched.
static func _live_subtitle(raw: String) -> String:
	var sep: int = raw.rfind(" · ")
	if sep < 0:
		return raw
	var tail: String = raw.substr(sep + 3)
	if tail.length() < 5 or tail.find(":") != 2:
		return raw
	var mm: String = tail.substr(3, 2)
	if not (tail.substr(0, 2).is_valid_int() and mm.is_valid_int()):
		return raw
	return "%s · %02d:%s%s" % [raw.substr(0, sep), GameState.current_hour, mm, tail.substr(5)]


# --- Speaker strip (compact single line) ---

func _build_speaker_row() -> void:
	for child in _speaker_row.get_children():
		child.queue_free()
	_speaker_row.visible = false
	if _event.character_id == "":
		return
	var c: Character = CharacterRegistry.get_character(_event.character_id)
	if c == null:
		push_warning("[EventModal] event.character_id refers to unknown character: %s" % _event.character_id)
		return
	_speaker_row.visible = true
	# Kart grameri tek (GDD 14 §7): kaynağın küçük yuvarlak avatarı; Frank önceden render edilmiş
	# portresiyle, diğerleri büstleriyle (görünüşü olmayan baş harfleriyle).
	_speaker_row.add_child(UiFactory.make_mentor_avatar(24) if c.category == "mentor"
		else UiFactory.make_person_avatar(c.character_name, c.look, 24))
	# role is a TYPED id — resolve it to a display name so no internal code reaches the strip.
	var name_label := UiFactory.make_label(
		"%s · %s" % [c.character_name, HRConstants.role_label(c.role)], &"RowName")
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_speaker_row.add_child(name_label)
	var pal: Dictionary = UiTokens.relationship_palette(c.relationship)
	_speaker_row.add_child(UiFactory.make_pill(HRConstants.relationship_label(c.relationship), pal.bg, pal.fg))
	for t in c.traits.slice(0, 2):
		_speaker_row.add_child(UiFactory.make_badge(_trait_label(String(t)), &"neutral"))


# Employees and the founder draw from SEPARATE trait catalogs (employee labels live in
# HRConstants; founder labels are CSV keys). Resolve against both so a chip never renders
# a raw internal id.
func _trait_label(trait_id: String) -> String:
	if HRConstants.TRAITS.has(trait_id):
		return HRConstants.trait_label(trait_id)
	for entry in FounderConstants.TRAITS:
		if String(entry.get("id", "")) == trait_id:
			return tr(String(entry.get("name_key", trait_id)))
	return trait_id


# --- Choice rendering ---

func _render_choices() -> void:
	for child in _choices_host.get_children():
		child.queue_free()
	# The card's frozen context comes with the question: a lock on "this account has spent
	# both discounts" is about the account the card is ABOUT.
	var ctx: Dictionary = EventGate.active_context()
	for idx in _event.choices.size():
		var choice: EventChoice = _event.choices[idx]
		var unlocked: bool = EventGate.condition_met(choice.unlock_condition, ctx)
		_choices_host.add_child(_build_choice_card(choice, idx, unlocked, ctx))


func _build_choice_card(choice: EventChoice, idx: int, unlocked: bool, ctx: Dictionary) -> PanelContainer:
	var root := PanelContainer.new()
	root.theme_type_variation = &"ChoiceCard"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(row)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 2)
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_col)
	var lbl := UiFactory.make_label(choice.label, &"ChoiceLabelStrong")
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(lbl)

	# Right-aligned chip column: one chip per row so 2+ effects stack
	# deterministically (no flow-wrap jitter against the text column).
	var chip_col := VBoxContainer.new()
	chip_col.add_theme_constant_override("separation", 3)
	chip_col.size_flags_horizontal = Control.SIZE_SHRINK_END
	chip_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(chip_col)

	if unlocked:
		for m in choice.modifiers:
			for part in EvChips.describe(m, ctx, {}, false):
				var chip := UiFactory.make_badge(EvChips.text(part), BADGE_KIND[part.polarity])
				chip.size_flags_horizontal = Control.SIZE_SHRINK_END
				chip_col.add_child(chip)
		root.gui_input.connect(_on_choice_input.bind(idx))
		root.mouse_entered.connect(func() -> void: root.theme_type_variation = &"ChoiceCardHover")
		root.mouse_exited.connect(func() -> void: root.theme_type_variation = &"ChoiceCard")
	else:
		root.modulate = Color(1, 1, 1, 0.5)
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.focus_mode = Control.FOCUS_NONE
		# The live reason wins over the authored one: an option gated on several facts can only
		# author one sentence, while the condition tree knows which clause actually failed. The
		# authored line is the fallback for when the engine stays silent (two clauses failing
		# at once, which one sentence cannot honestly explain).
		var reason: String = EventGate.condition_reason(choice.unlock_condition, ctx)
		reason = tr(reason) if reason != "" else choice.unlock_reason_text
		chip_col.add_child(UiFactory.make_badge(reason if reason != "" else tr("LOCK_CHIP"), &"neutral"))
	return root


func _on_choice_input(event: InputEvent, idx: int) -> void:
	if _resolved:
		return
	if UiFactory.is_left_click(event):
		_resolved = true
		EventGate.resolve(_event.id, idx)


static func _markdown_to_bbcode(text: String) -> String:
	var bold := RegEx.new()
	bold.compile("\\*\\*(.+?)\\*\\*")
	var italic := RegEx.new()
	italic.compile("\\*(.+?)\\*")
	return italic.sub(bold.sub(text, "[b]$1[/b]", true), "[i]$1[/i]", true)
