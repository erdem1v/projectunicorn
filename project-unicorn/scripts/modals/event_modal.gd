extends Control

# Event modal — mounted into GameShell/ModalLayer by main.gd when EventManager
# emits modal_requested. Editorial paper card: mono-caps header (source chip +
# "KARAR · GÜN N" + subtitle), serif headline and body, compact speaker strip,
# optional mentor quote row (event.mentor_line), choice cards with right-aligned
# effect chips, optional MENTOR TAVSİYESİ highlight (event.mentor_choice), mono
# footer. No countdown: the game pauses while open.
#
# Layout is built in code over a bare .tscn root. Colors come from UiTokens,
# styleboxes from master_theme.tres variations, widgets from UiFactory.
#
# Lifecycle: main.gd instances → populate(event) → player clicks a choice →
# EventGate.resolve() → event_resolved → main.gd frees this node.
# process_mode = ALWAYS (.tscn) so input works while the tree is paused.

## Effects a card carries deliberately and SILENTLY: bookkeeping with no player-visible
## consequence of its own. `event_chip_coverage` in the smoke suite fails on any card verb
## that is neither labelled in `_describe_modifier` nor listed here.
const SILENT_VERBS := [
	"set_flag", "set_game_flag", "stamp_day", "schedule_event", "cancel_scheduled",
	"start_arc", "advance_arc", "end_arc", "abort_arc", "set_arc_var",
	"mentor_advisory", "unlock_content", "spend_budget",
]

## Verbs whose chip is a fixed sentence: [CSV key, badge kind].
const FIXED_CHIPS := {
	"enter_development": ["EFFECT_DEV_BEGINS", &"neutral"],
	"enter_beta": ["EFFECT_BETA_BEGINS", &"neutral"],
	"open_term_table": ["EFFECT_TERM_TABLE", &"accent"],
	"open_seed_table": ["EFFECT_SEED_TABLE", &"accent"],
	"decline_offer": ["EFFECT_FUND_CLOSES", &"negative"],
	"trigger_ending": ["EFFECT_RUN_ENDS", &"accent"],
	"decline_buyout": ["EFFECT_VC_ROAD_CLOSES", &"negative"],
	"churn_customer": ["EFFECT_CHURN", &"negative"],
	"add_prospect": ["EFFECT_NEW_PROSPECT", &"positive"],
	"open_paid_tier": ["EFFECT_PAID_TIER", &"accent"],
	"promise_create": ["EFFECT_PROMISE_CREATE", &"accent"],
	"b2b_retain_delay": ["EFFECT_RETAIN_DELAY", &"neutral"],
	"b2b_retain_ignore": ["EFFECT_RETAIN_IGNORE", &"neutral"],
	"b2b_expand_decline": ["EFFECT_NO_CHANGE", &"neutral"],
	"advance_phase": ["EFFECT_PHASE_ADVANCE", &"accent"],
	"phase_gate_decline": ["EFFECT_PHASE_HOLD", &"neutral"],
	"ship_active_build": ["EFFECT_SHIP_LIVE", &"accent"],
	"start_vc_meeting": ["EFFECT_MEETING_STARTS", &"accent"],
	"goto_tab": ["EFFECT_TAKES_YOU_THERE", &"neutral"],
}

var _event: GameEvent = null
var _resolved: bool = false  # one-shot guard against double-click

var _header_row: HBoxContainer
var _title_label: Label
var _body_rich: RichTextLabel
var _speaker_row: HBoxContainer
var _mentor_row: HBoxContainer
var _choices_host: VBoxContainer
var _footer_rule: ColorRect
var _footer_label: Label


func _ready() -> void:
	_build_skeleton()


func populate(event: GameEvent) -> void:
	_event = event
	if not is_node_ready():
		await ready
	_fill_header()
	# Authored text resolves HERE, at render, not at load: the event cache is built once at
	# boot, so resolving earlier would freeze the boot locale into it.
	_title_label.text = Localization.pick(event.title, event.title_en)
	_body_rich.text = _markdown_to_bbcode(Localization.pick(event.body_text, event.body_text_en))
	_build_speaker_row()
	_build_mentor_row()
	_render_choices()
	var readout: bool = _is_readout()
	_footer_rule.visible = not readout
	_footer_label.visible = not readout
	_play_intro()


# Oda görünürken olay kartı TELEFONDAN doğar: 0.22 sn scale+translate tween'i. Oda
# görünmüyorsa (sekme açık / oda dışı mount) varsayılan anlık görünüm kalır. Koordinatlar
# düz ekran-uzayı (ModalLayer CanvasLayer'ının transformu kimlik). Pause altında çalışır:
# kök PROCESS_MODE_ALWAYS, create_tween onu izler.
func _play_intro() -> void:
	var anchor := get_tree().get_first_node_in_group("oda_phone_anchor") as Control
	if anchor == null or not anchor.is_visible_in_tree():
		return
	var panel: Control = get_node("CenterPanel")
	var dimmer: Control = get_node("Dimmer")
	await get_tree().process_frame  # panel boyutu ilk layout'tan sonra geçerli
	panel.pivot_offset = panel.size * 0.5
	var home: Vector2 = panel.position
	panel.scale = Vector2(0.25, 0.25)
	panel.position = home + anchor.get_global_rect().get_center() - panel.get_global_rect().get_center()
	dimmer.modulate.a = 0.0
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.22)
	tw.tween_property(panel, "position", home, 0.22)
	tw.tween_property(dimmer, "modulate:a", 1.0, 0.22)


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

	body.add_child(_rule())

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

	_mentor_row = HBoxContainer.new()
	_mentor_row.add_theme_constant_override("separation", 8)
	_mentor_row.visible = false
	body.add_child(_mentor_row)

	_choices_host = VBoxContainer.new()
	_choices_host.add_theme_constant_override("separation", 8)
	body.add_child(_choices_host)

	# Built always, SHOWN from `populate`: a readout hides the permanence warning (see
	# `_is_readout`), and there is no event to ask yet in `_ready()`.
	_footer_rule = _rule()
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


static func _rule() -> ColorRect:
	var r := ColorRect.new()
	r.custom_minimum_size = Vector2(0, 1)
	r.color = UiTokens.DIVIDER_LIGHT
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


# --- Header row ---

func _fill_header() -> void:
	for child in _header_row.get_children():
		child.queue_free()
	var tag: Dictionary = _source_tag(_event)
	_header_row.add_child(UiFactory.make_badge(String(tag.text), StringName(tag.kind)))
	var day_key: String = "EVENT_READOUT_DAY" if _is_readout() else "EVENT_DECISION_DAY"
	var meta := UiFactory.make_label(
		tr(day_key).format({"day": GameState.day}), &"SectionLabel")
	meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_header_row.add_child(meta)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header_row.add_child(spacer)
	var subtitle_text: String = Localization.pick(_event.subtitle, _event.subtitle_en)
	if subtitle_text != "":
		var sub := UiFactory.make_label(UiTokens.tr_upper(_live_subtitle(subtitle_text)), &"MicroLabel")
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


## {text, kind} for the header's source chip. Order matters: families that NAME their source
## (customer / team / phase gate / ship moment) first, then the speaker, then the generic
## `endgame` topic, then GÜNDEM. `endgame` is a topic, not a source, so a Frank card tagged
## `endgame` is still MENTOR; `ship_moment` beats the speaker because it is a product beat
## even when Frank narrates it. Static (smoke calls it on the script), hence TranslationServer.
static func _source_tag(ev: GameEvent) -> Dictionary:
	var pick: Array = []
	for s in ev.tags:
		if s.begins_with("b2b_"):
			pick = ["EVENT_TAG_CUSTOMER", &"accent"]
		elif s.begins_with("hr_"):
			pick = ["EVENT_TAG_TEAM", &"neutral"]
		elif s == "phase_gate":
			pick = ["EVENT_TAG_MENTOR", &"accent"]
		elif s == "ship_moment":
			pick = ["EVENT_TAG_PRODUCT", &"positive"]
		if not pick.is_empty():
			break
	if pick.is_empty():
		if ev.character_id == "char_mentor_frank":
			pick = ["EVENT_TAG_MENTOR", &"accent"]
		elif ev.tags.has("endgame"):
			pick = ["EVENT_TAG_MARKET", &"attention"]
		else:
			pick = ["EVENT_TAG_AGENDA", &"neutral"]
	return {"text": TranslationServer.translate(pick[0]), "kind": pick[1]}


# --- Speaker strip (compact single line) ---

func _build_speaker_row() -> void:
	for child in _speaker_row.get_children():
		child.queue_free()
	_speaker_row.visible = false
	if _event.character_id != "":
		_render_registry_character()
	elif _event.speaker_name != "":
		_render_synthetic_speaker()


func _render_registry_character() -> void:
	var c: Character = CharacterRegistry.get_character(_event.character_id)
	if c == null:
		push_warning("[EventModal] event.character_id refers to unknown character: %s" % _event.character_id)
		return
	_speaker_row.visible = true
	_speaker_row.add_child(_make_avatar(UiFactory.initials_of(c.character_name), c.portrait_path))
	# role is a TYPED id — resolve it to a display name so no internal code reaches the strip.
	_add_speaker_name("%s · %s" % [c.character_name, HRConstants.role_label(c.role)])
	var pal: Dictionary = UiTokens.relationship_palette(c.relationship)
	_speaker_row.add_child(UiFactory.make_pill(c.relationship, pal.bg, pal.fg))
	for t in c.traits.slice(0, 2):
		_speaker_row.add_child(UiFactory.make_badge(_trait_label(String(t)), &"neutral"))


# A non-Character speaker (e.g. a B2B customer talking in their own voice), rendered
# straight from the event's speaker_* fields — no registry lookup.
func _render_synthetic_speaker() -> void:
	_speaker_row.visible = true
	var initial: String = _event.speaker_initial if _event.speaker_initial != "" \
		else UiFactory.initials_of(_event.speaker_name)
	_speaker_row.add_child(_make_avatar(initial))
	if _event.speaker_role != "":
		_add_speaker_name("%s · %s" % [_event.speaker_name, _event.speaker_role])
	else:
		_add_speaker_name(_event.speaker_name)
	if _event.speaker_status != "":
		var pal: Dictionary = UiTokens.badge_palette(StringName(_event.speaker_status_kind))
		_speaker_row.add_child(UiFactory.make_pill(_event.speaker_status, pal.bg, pal.fg))
	for chip in _event.speaker_chips:
		if typeof(chip) == TYPE_DICTIONARY:
			_speaker_row.add_child(UiFactory.make_badge(
				String(chip.get("text", "")), StringName(String(chip.get("kind", "neutral")))))


func _add_speaker_name(text: String) -> void:
	var lbl := UiFactory.make_label(text, &"RowName")
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_speaker_row.add_child(lbl)


# Kart grameri tek (GDD 14 §7): her olay kartı kaynağının küçük yuvarlak avatarını gösterir —
# portre taşıyanlar portreleriyle, diğerleri baş harfleriyle. `Avatar` varyasyonu RADIUS_PILL,
# dolayısıyla clip_contents yuvarlak kırpmayı verir.
static func _make_avatar(initials_text: String, portrait_path: String = "") -> Panel:
	var avatar: Panel = UiFactory.make_avatar(initials_text)
	var tex: Texture2D = null
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		tex = load(portrait_path) as Texture2D
	if tex != null:
		avatar.get_child(0).free()  # the initials label
		avatar.clip_contents = true
		var pic := TextureRect.new()
		pic.texture = tex
		pic.set_anchors_preset(Control.PRESET_FULL_RECT)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		avatar.add_child(pic)
	return avatar


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


# --- Mentor quote row (only when the event carries mentor_line) ---

func _build_mentor_row() -> void:
	for child in _mentor_row.get_children():
		child.queue_free()
	var mentor_text: String = Localization.pick(_event.mentor_line, _event.mentor_line_en)
	_mentor_row.visible = mentor_text != ""
	if not _mentor_row.visible:
		return
	var mentor: Character = CharacterRegistry.get_mentor()
	if mentor != null:
		_mentor_row.add_child(_make_avatar(UiFactory.initials_of(mentor.character_name), mentor.portrait_path))
	else:
		_mentor_row.add_child(_make_avatar(""))
	var quote := UiFactory.make_label(mentor_text, &"QuoteSerif")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quote.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mentor_row.add_child(quote)


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
		# A mentor never endorses a locked path (avoids amber-on-dim conflict).
		var is_mentor_pick: bool = unlocked and _event.mentor_choice == idx
		var card: PanelContainer = _build_choice_card(choice, idx, unlocked, is_mentor_pick, ctx)
		_choices_host.add_child(_wrap_with_mentor_tab(card) if is_mentor_pick else card)


func _build_choice_card(choice: EventChoice, idx: int, unlocked: bool, is_mentor_pick: bool,
		ctx: Dictionary) -> PanelContainer:
	var root := PanelContainer.new()
	root.theme_type_variation = &"ChoiceCardMentor" if is_mentor_pick else &"ChoiceCard"
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
	var lbl := UiFactory.make_label(Localization.pick(choice.label, choice.label_en), &"ChoiceLabelStrong")
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(lbl)
	var desc_text: String = Localization.pick(choice.description, choice.description_en)
	if desc_text != "":
		var desc := UiFactory.make_label(desc_text, &"QuoteSerif")
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text_col.add_child(desc)

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
			var d: Dictionary = _describe_modifier(m)
			if not d.is_empty():
				var chip := UiFactory.make_badge(d.text, d.kind)
				chip.size_flags_horizontal = Control.SIZE_SHRINK_END
				chip_col.add_child(chip)
		root.gui_input.connect(_on_choice_input.bind(idx))
		if not is_mentor_pick:
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
		reason = tr(reason) if reason != "" \
			else Localization.pick(choice.unlock_reason_text, choice.unlock_reason_text_en)
		chip_col.add_child(UiFactory.make_badge(reason if reason != "" else tr("LOCK_CHIP"), &"neutral"))
	return root


# MENTOR TAVSİYESİ tab sitting ON the card's top edge: negative VBox separation pulls the
# card up under the chip; z_index lifts the chip above the card's border (later siblings
# draw over earlier ones otherwise).
func _wrap_with_mentor_tab(card: PanelContainer) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", -8)
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tab_row := HBoxContainer.new()
	tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(12, 0)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_row.add_child(pad)
	var tab := UiFactory.make_badge(tr("EVENT_MENTOR_ADVICE"), &"accent")
	tab.z_index = 1
	tab_row.add_child(tab)
	wrapper.add_child(tab_row)
	wrapper.add_child(card)
	return wrapper


func _on_choice_input(event: InputEvent, idx: int) -> void:
	if _resolved:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_resolved = true
		EventGate.resolve(_event.id, idx)


# --- Effect chips ---

## Player-facing badge {text, kind} for a card effect, or {} for a SILENT_VERBS row. Every
## number is computed the way `EvEffects` will apply it (same amount key order, same target
## resolution, same constants), so the chip cannot drift from the outcome.
func _describe_modifier(m) -> Dictionary:
	if typeof(m) != TYPE_DICTIONARY:
		return {}
	var t: String = String(m.get("verb", ""))
	if FIXED_CHIPS.has(t):
		return {"text": tr(FIXED_CHIPS[t][0]), "kind": FIXED_CHIPS[t][1]}
	var d: int = int(m.get("amount", m.get("delta", m.get("value", 0))))
	match t:
		"add_cash": return _chip("EFFECT_CASH", _fmt_money_delta(d), d)
		"add_brand": return _chip("EFFECT_BRAND", _fmt_signed(d), d)
		"add_reputation": return _chip("EFFECT_REPUTATION", _fmt_signed(d), d)
		"customer_mrr_delta": return _chip("EFFECT_CUSTOMER_MRR", _fmt_money_delta(d), d)
		"satisfaction_delta": return _chip("EFFECT_SATISFACTION", _fmt_signed(d), d)
		"seats": return _chip("EFFECT_SEATS", _fmt_signed(d), d)
		"morale_all": return _chip("EFFECT_TEAM", _fmt_signed(d), d)
		"bug_delta": return _chip("EFFECT_BUGS", _fmt_signed(d), -d)
		"delay_days":
			var days: int = int(m.get("days", 0))
			return _chip("EFFECT_DAYS", _fmt_signed(days), -days)
		"change_morale":
			var who: String = _first_name(_target(m, EvScope.TYPE_EMPLOYEE), tr("EFFECT_MORALE"))
			return {"text": tr("EFFECT_AXIS").format({"axis": who, "v": _fmt_signed(d)}), "kind": _kind(d)}
		"dimension_delta":
			var axis_id: String = String(m.get("axis", "innovation"))
			var label: String = ProductCatalog.axis_label(axis_id)
			if label == axis_id:
				label = tr("EFFECT_QUALITY")
			return {"text": tr("EFFECT_AXIS").format({"axis": label, "v": _fmt_signed(d)}), "kind": _kind(d)}
		"audience_delta":
			if m.has("pct"):
				# Fmt.percent is locale-aware (TR prefix, EN suffix); the sign rides the number.
				var pts: int = int(round(float(m.get("pct", 0.0)) * 100.0))
				var pct_txt: String = ("-" if pts < 0 else "+") + Fmt.percent(absi(pts), 0)
				return {"text": tr("EFFECT_AUDIENCE_PCT").format({"pct": pct_txt}), "kind": _kind(pts)}
			return _chip("EFFECT_AUDIENCE", _fmt_signed(d), d)
		"convert_audience":
			var conv: String = Fmt.percent(int(round(float(m.get("pct", 0.0)) * 100.0)), 0)
			return {"text": tr("EFFECT_CONVERT_AUDIENCE").format({"pct": conv}), "kind": &"positive"}
		# A person's name or the generic noun — never EFFECT_MORALE, which would read "Moral ayrılıyor".
		"employee_leaves":
			var leaver: String = _first_name(_target(m, EvScope.TYPE_EMPLOYEE), tr("EFFECT_AN_EMPLOYEE"))
			return {"text": tr("EFFECT_DEPARTURE").format({"who": leaver}), "kind": &"negative"}
		# The cut is derived at resolution time from the account's own MRR, exactly as the
		# `b2b_retain_discount` effect derives it.
		"b2b_retain_discount":
			var rc: Customer = CustomerRegistry.get_customer(_target(m, EvScope.TYPE_CUSTOMER))
			var cut: int = -int(round(float(rc.mrr) * B2BConstants.RETAIN_DISCOUNT_PCT)) if rc != null else 0
			return {"text": tr("EFFECT_RETAIN_DISCOUNT").format({"v": _fmt_money_delta(cut)}), "kind": &"negative"}
		# Seats and rate as `b2b_expand` → B2BSalesSystem.expand computes them (the account's own
		# seat price, the constant only as fallback). Satış §5.4.
		"b2b_expand":
			var ec: Customer = CustomerRegistry.get_customer(_target(m, EvScope.TYPE_CUSTOMER))
			var seats: int = 0
			var mrr: int = 0
			if ec != null:
				seats = B2BConstants.expansion_seats(ec.company_size)
				mrr = seats * (ec.seat_price if ec.seat_price > 0 else B2BConstants.EXPANSION_PER_SEAT_MRR)
			return {"text": tr("EFFECT_EXPAND").format({"seats": seats, "mrr": _fmt_money_delta(mrr)}), "kind": &"positive"}
		# Two facts on one chip: the cost of the decision is the equity, not the cash, so both
		# ride and the kind is "accent" (a trade) rather than "positive" (a gift).
		"angel_accept":
			return {"text": tr("ANGEL_CHIP_ACCEPT").format({
					"cash": _fmt_money_delta(AngelRoundSystem.CASH_AMOUNT),
					"equity": AngelRoundSystem.EQUITY_PCT}),
				"kind": &"accent"}
	if t != "" and not SILENT_VERBS.has(t):
		push_warning("[EventModal] effect '%s' renders no chip — add a label or list it in SILENT_VERBS" % t)
	return {}


func _chip(key: String, value_text: String, sign_delta: int) -> Dictionary:
	return {"text": tr(key).format({"v": value_text}), "kind": _kind(sign_delta)}


## The entity id an effect will act on, resolved by the executor's own rule against the
## card's frozen scope binding.
static func _target(m: Dictionary, want_type: String) -> String:
	return EvEffects._entity(m, EventGate.active_context(), want_type)


static func _kind(delta: int) -> StringName:
	if delta > 0: return &"positive"
	if delta < 0: return &"negative"
	return &"neutral"


## First name of a registry character, or `fallback` when the id resolves to nobody.
static func _first_name(id: String, fallback: String) -> String:
	var c: Character = CharacterRegistry.get_character(id) if id != "" else null
	return c.character_name.split(" ", false)[0] if c != null else fallback


static func _fmt_signed(value: int) -> String:
	return ("+%d" if value > 0 else "%d") % value


# This chip is the player's source of truth for what a decision costs, so it uses the
# locale-aware abbreviated money (Fmt.money_chip) with an explicit sign on both sides.
static func _fmt_money_delta(value: int) -> String:
	return ("+" if value >= 0 else "-") + Fmt.money_chip(absi(value))


static func _markdown_to_bbcode(text: String) -> String:
	var bold := RegEx.new()
	bold.compile("\\*\\*(.+?)\\*\\*")
	var italic := RegEx.new()
	italic.compile("\\*(.+?)\\*")
	return italic.sub(bold.sub(text, "[b]$1[/b]", true), "[i]$1[/i]", true)
