extends Control

# Event modal — mounted into GameShell/ModalLayer by main.gd when EventManager
# emits modal_requested. Editorial paper card (approved mockup): mono-caps header
# (source chip + "KARAR · GÜN N" + subtitle slot), serif headline, serif body,
# compact speaker strip, optional mentor quote row (event.mentor_line), choice
# cards with right-aligned effect chips, optional MENTOR TAVSİYESİ highlight
# (event.mentor_choice), mono footer. No countdown: the game pauses while open.
#
# Layout is built in code over a bare .tscn root (ending_scene.gd idiom).
# Colors come from UiTokens, styleboxes from master_theme.tres variations,
# widgets from UiFactory.
#
# Lifecycle: main.gd instances → populate(event) → player clicks a choice →
# EventManager.resolve_choice() → event_resolved → main.gd frees this node.
# process_mode = ALWAYS (.tscn) so input works while the tree is paused.

var _event: GameEvent = null
var _resolved: bool = false  # one-shot guard against double-click
var _intro_played: bool = false  # ODA telefon-orijin girişi tek sefer oynar

var _header_row: HBoxContainer
var _title_label: Label
var _body_rich: RichTextLabel
var _speaker_row: HBoxContainer
var _mentor_row: HBoxContainer
var _choices_host: VBoxContainer


func _ready() -> void:
	_build_skeleton()


func populate(event: GameEvent) -> void:
	_event = event
	if not is_node_ready():
		await ready
	_fill_header()
	# Every authored string goes through Localization.pick, which returns the English
	# sibling when one exists and the locale is English, and the Turkish canonical text
	# otherwise. Resolution happens HERE, at render, not at load: the event cache is built
	# once at boot, so resolving earlier would freeze the boot locale into it.
	_title_label.text = Localization.pick(event.title, event.title_en)
	_body_rich.text = _markdown_to_bbcode(Localization.pick(event.body_text, event.body_text_en))
	_build_speaker_row()
	_build_mentor_row()
	_render_choices()
	_play_intro()


# ODA rework §6: oda görünürken olay kartı TELEFONDAN doğar — tek seferlik
# 0.22 sn scale+translate tween'i. Oda görünmüyorsa (sekme açık / oda dışı
# mount) hiçbir şey değişmez: varsayılan anlık görünüm. Koordinatlar düz
# ekran-uzayı (ModalLayer CanvasLayer'ının transformu kimlik). Pause altında
# çalışır: kök PROCESS_MODE_ALWAYS, create_tween pause-bound onu izler.
func _play_intro() -> void:
	if _intro_played:
		return
	_intro_played = true
	var anchor: Node = get_tree().get_first_node_in_group("oda_phone_anchor")
	if anchor == null or not (anchor is Control) or not (anchor as Control).is_visible_in_tree():
		return
	var panel: Control = get_node("CenterPanel")
	var dimmer: Control = get_node("Dimmer")
	await get_tree().process_frame  # panel boyutu ilk layout'tan sonra geçerli
	var from_center: Vector2 = (anchor as Control).get_global_rect().get_center()
	panel.pivot_offset = panel.size * 0.5
	var delta: Vector2 = from_center - panel.get_global_rect().get_center()
	var home: Vector2 = panel.position
	panel.scale = Vector2(0.25, 0.25)
	panel.position = home + delta
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
	# center anchor when the minimum size rises — mockup card, no fixed void).
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

	_body_rich = RichTextLabel.new()
	_body_rich.theme_type_variation = &"BodyRich"
	# fit_content sizes the label to its text (card hugs content); EXPAND_FILL
	# absorbs the slack when the card sits at its 420px floor instead.
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

	body.add_child(_rule())

	var footer := UiFactory.make_label(
		UiTokens.tr_upper("Seçim kalıcıdır · Oyun duraklatıldı"), &"MicroLabel")
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(footer)


static func _rule(height: int = 1) -> ColorRect:
	var r := ColorRect.new()
	r.custom_minimum_size = Vector2(0, height)
	r.color = UiTokens.DIVIDER_LIGHT
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


# --- Header row ---

func _fill_header() -> void:
	for child in _header_row.get_children():
		child.queue_free()
	var tag: Dictionary = _source_tag(_event)
	_header_row.add_child(UiFactory.make_badge(String(tag.text), StringName(tag.kind)))
	var meta := UiFactory.make_label("KARAR · GÜN %d" % GameState.day, &"SectionLabel")
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


# The " · HH:MM" in an event header used to be a STATIC string baked into the event's JSON,
# copied verbatim to the screen. The engine has no minute concept at all, and the TopBar
# renders the live hour in the same frame roughly 40 px away — so a modal could assert
# 11:14 beside a TopBar reading 09:00, off by as much as the event's whole allowed window.
#
# The authoring discipline itself is sound and is preserved: all thirteen windowed stamps
# sit inside their own `allowed_hours`, and the three clock-free deterministic beats
# correctly carry no clock. So this rewrites the HOUR from the live clock and keeps the
# authored minutes, which are the only part with any texture — the subtitle stays within
# the hour the TopBar is showing.
#
# OPT-IN, never unconditional: it fires only when the subtitle actually ends in " · HH:MM".
# Three debug fixtures carry a clock with no `allowed_hours` at all, and a subtitle that
# merely contains a colon (a time-less source tag) must be left exactly as written.
static func _live_subtitle(raw: String) -> String:
	var sep: int = raw.rfind(" · ")
	if sep < 0:
		return raw
	var tail: String = raw.substr(sep + 3)
	var colon: int = tail.find(":")
	if colon != 2 or tail.length() < 5:
		return raw
	var hh: String = tail.substr(0, 2)
	var mm: String = tail.substr(3, 2)
	if not (hh.is_valid_int() and mm.is_valid_int()):
		return raw
	# Anything after the stamp (e.g. a " [DEBUG]" marker) rides along untouched.
	var suffix: String = tail.substr(5)
	return "%s · %02d:%s%s" % [raw.substr(0, sep), GameState.current_hour, mm, suffix]


static func _source_tag(ev: GameEvent) -> Dictionary:
	# The ONE source-tag lookup: factory tags first, then the mentor's registry id,
	# then the generic fallback. Returns {text, kind} for UiFactory.make_badge.
	for t in ev.tags:
		var s := String(t)
		if s.begins_with("b2b_"):
			return {"text": "MÜŞTERİ", "kind": &"accent"}
		if s.begins_with("hr_"):
			return {"text": "EKİP", "kind": &"neutral"}
		if s == "endgame":
			return {"text": "PİYASA", "kind": &"attention"}
		if s == "phase_gate":
			return {"text": "MENTOR", "kind": &"accent"}
		if s == "ship_moment":
			return {"text": "ÜRÜN", "kind": &"positive"}
	if ev.character_id == "char_mentor_frank":
		return {"text": "MENTOR", "kind": &"accent"}
	return {"text": "GÜNDEM", "kind": &"neutral"}


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
	_speaker_row.add_child(_make_avatar(_initials(c.character_name)))
	# role is a TYPED id — resolve it to a display name so no internal code reaches
	# the speaker strip ("Frank Köseoğlu · Operating Partner").
	_add_speaker_name("%s · %s" % [c.character_name, HRConstants.role_label(c.role)])
	var pal: Dictionary = UiTokens.relationship_palette(c.relationship)
	_speaker_row.add_child(UiFactory.make_pill(c.relationship, pal.bg, pal.fg))
	for t in c.traits.slice(0, 2):
		_speaker_row.add_child(UiFactory.make_badge(_trait_label(String(t)), &"neutral"))


func _render_synthetic_speaker() -> void:
	# A non-Character speaker (e.g. a B2B customer talking in their own voice),
	# rendered straight from the event's speaker_* fields — no registry lookup.
	_speaker_row.visible = true
	var initial: String = _event.speaker_initial if _event.speaker_initial != "" else _initials(_event.speaker_name)
	_speaker_row.add_child(_make_avatar(initial))
	if _event.speaker_role != "":
		_add_speaker_name("%s · %s" % [_event.speaker_name, _event.speaker_role])
	else:
		_add_speaker_name(_event.speaker_name)
	if _event.speaker_status != "":
		var pal: Dictionary = UiTokens.badge_palette(StringName(String(_event.speaker_status_kind)))
		_speaker_row.add_child(UiFactory.make_pill(_event.speaker_status, pal.bg, pal.fg))
	for chip in _event.speaker_chips:
		if typeof(chip) == TYPE_DICTIONARY:
			_speaker_row.add_child(UiFactory.make_badge(
				String(chip.get("text", "")), StringName(String(chip.get("kind", "neutral")))))


func _add_speaker_name(text: String) -> void:
	var lbl := UiFactory.make_label(text, &"RowName")
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_speaker_row.add_child(lbl)


static func _make_avatar(initials_text: String) -> Panel:
	var avatar := Panel.new()
	avatar.theme_type_variation = &"Avatar"
	avatar.custom_minimum_size = Vector2(24, 24)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var initial := Label.new()
	initial.theme_type_variation = &"AvatarInitial"
	initial.text = initials_text
	initial.set_anchors_preset(Control.PRESET_FULL_RECT)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(initial)
	return avatar


func _trait_label(trait_id: String) -> String:
	# Employees and the founder draw from SEPARATE trait catalogs (employee labels are
	# literal Turkish in HRConstants; founder labels are CSV keys). Resolve against both
	# so a chip never renders a raw internal id.
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
	var initials_text: String = _initials(mentor.character_name) if mentor != null else ""
	_mentor_row.add_child(_make_avatar(initials_text))
	var quote := UiFactory.make_label(mentor_text, &"QuoteSerif")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quote.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mentor_row.add_child(quote)


# --- Choice rendering ---

func _render_choices() -> void:
	for child in _choices_host.get_children():
		child.queue_free()
	for idx in _event.choices.size():
		var choice: EventChoice = _event.choices[idx]
		var unlocked: bool = EventManager.is_condition_met(choice.unlock_condition)
		# A mentor never endorses a locked path (avoids amber-on-dim conflict).
		var is_mentor_pick: bool = unlocked and _event.mentor_choice == idx
		var card: PanelContainer = _build_choice_card(choice, idx, unlocked, is_mentor_pick)
		if is_mentor_pick:
			_choices_host.add_child(_wrap_with_mentor_tab(card))
		else:
			_choices_host.add_child(card)


func _build_choice_card(choice: EventChoice, idx: int, unlocked: bool, is_mentor_pick: bool) -> PanelContainer:
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
		for chip in _make_effect_chips(choice.modifiers):
			chip_col.add_child(chip)
		root.gui_input.connect(_on_choice_input.bind(idx))
		if not is_mentor_pick:
			root.mouse_entered.connect(func() -> void: root.theme_type_variation = &"ChoiceCardHover")
			root.mouse_exited.connect(func() -> void: root.theme_type_variation = &"ChoiceCard")
	else:
		root.modulate = Color(1, 1, 1, 0.5)
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.focus_mode = Control.FOCUS_NONE
		var reason_src: String = Localization.pick(choice.unlock_reason_text, choice.unlock_reason_text_en)
		var reason: String = reason_src if reason_src != "" else tr("LOCK_CHIP")
		chip_col.add_child(UiFactory.make_badge(reason, &"neutral"))
	return root


func _make_effect_chips(modifiers: Array) -> Array[Control]:
	var chips: Array[Control] = []
	for m in modifiers:
		var desc: Dictionary = _describe_modifier(m)
		if desc.is_empty():
			continue
		var chip := UiFactory.make_badge(desc.text, desc.kind)
		chip.size_flags_horizontal = Control.SIZE_SHRINK_END
		chips.append(chip)
	return chips


func _wrap_with_mentor_tab(card: PanelContainer) -> Control:
	# MENTOR TAVSİYESİ tab sitting ON the card's top edge: negative VBox separation
	# pulls the card up under the chip; z_index lifts the chip above the card's
	# border (later siblings draw over earlier ones otherwise).
	var wrapper := VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", -8)
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tab_row := HBoxContainer.new()
	tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(12, 0)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_row.add_child(pad)
	var tab := UiFactory.make_badge("MENTOR TAVSİYESİ", &"accent")
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
		EventManager.resolve_choice(_event.id, idx)


# --- Formatters ---

static func _initials(full_name: String) -> String:
	var out: String = ""
	for word in full_name.split(" ", false):
		if word.length() > 0:
			out += UiTokens.tr_upper(word.substr(0, 1))
		if out.length() >= 2:
			break
	return out


## Player-facing badge for a modifier, or {} to hide bookkeeping modifiers.
func _describe_modifier(m) -> Dictionary:
	if typeof(m) != TYPE_DICTIONARY:
		return {}
	var t: String = m.get("type", "")
	var d: int = int(m.get("delta", 0))
	match t:
		"cash": return {"text": "Nakit %s" % _fmt_money_delta(d), "kind": _kind(d)}
		"mrr": return {"text": "MRR %s" % _fmt_money_delta(d), "kind": _kind(d)}  # MRR: ruled accepted TR-tech term
		"brand": return {"text": "Marka %s" % _fmt_signed(d), "kind": _kind(d)}
		"reputation": return {"text": "İtibar %s" % _fmt_signed(d), "kind": _kind(d)}
		"morale": return {"text": "%s %s" % [_char_first(m.get("character_id", "")), _fmt_signed(d)], "kind": _kind(d)}
		"morale_all_employees": return {"text": "Ekip %s" % _fmt_signed(d), "kind": _kind(d)}
		"customer_mrr_delta": return {"text": "Müşteri MRR %s" % _fmt_money_delta(d), "kind": _kind(d)}
		"satisfaction_delta": return {"text": "Memnuniyet %s" % _fmt_signed(d), "kind": _kind(d)}
		"seats":
			var sa: int = int(m.get("amount", 0))
			return {"text": "Koltuk %s" % _fmt_signed(sa), "kind": _kind(sa)}
		"audience_delta": return {"text": "Kitle %s" % _fmt_signed(d), "kind": _kind(d)}
		"dimension_delta":
			var amt: int = int(m.get("amount", 0))
			var label: String = {"innovation": "İnovasyon", "stability": "Kararlılık", "experience": "Deneyim"}.get(String(m.get("axis", "innovation")), "Kalite")
			return {"text": "%s %s" % [label, _fmt_signed(amt)], "kind": _kind(amt)}
		"bug_delta":
			var bd: int = int(m.get("amount", 0))
			return {"text": "Hata %s" % _fmt_signed(bd), "kind": (&"negative" if bd > 0 else (&"positive" if bd < 0 else &"neutral"))}
		"delay_days":
			var dd: int = int(m.get("days", 0))
			return {"text": "%s gün" % _fmt_signed(dd), "kind": (&"negative" if dd > 0 else (&"positive" if dd < 0 else &"neutral"))}
		"quality_bonus": return {"text": "Kalite +%d" % int(m.get("amount", 0)), "kind": &"positive"}
		"speed_bonus":
			var sb: int = int(m.get("days", 0))
			return {"text": "%s gün" % _fmt_signed(sb), "kind": (&"negative" if sb > 0 else &"positive")}
		# İterasyon karar momenti (player-gated restore): süre bedeli / faz geçişi okunur olsun.
		"advance_iteration": return {"text": "Bir tasarım turu · %d gün" % ProductSystem.ITER_ROUND_DAYS, "kind": &"accent"}
		"enter_development": return {"text": "Geliştirme başlar", "kind": &"neutral"}
		# Player-facing effects that previously rendered no badge (choices were blind).
		"churn_customer": return {"text": "Müşteri kaybı", "kind": &"negative"}
		"add_prospect": return {"text": "Yeni aday", "kind": &"positive"}
		"convert_audience": return {"text": "Kitleden dönüşüm %%%d" % int(round(float(m.get("pct", 0.0)) * 100.0)), "kind": &"positive"}
		"open_paid_tier": return {"text": "Ücretli katman açılır", "kind": &"accent"}
		"add_character": return {"text": "Yeni ekip üyesi", "kind": &"positive"}
		# --- HR Core. A modifier with NO label here renders a blind card, so every new
		#     type gets one (CLAUDE.md EFFECT-VISIBILITY RULE). ---
		# Not _char_first here: its unknown-id fallback is the literal "Moral", which would
		# read as "Moral ayrılıyor". A departure badge needs a person or a generic noun.
		"hr_departure": return {"text": "%s ayrılıyor" % _char_name_or(String(m.get("character_id", "")), "Çalışan"), "kind": &"negative"}
		"hr_overtime_stop": return {"text": "Ek mesai durur", "kind": &"neutral"}
		"hr_overtime_continue": return {"text": "Mesai sürer · istifa riski artar", "kind": &"negative"}
		# --- B2B Sales System retention outcomes (badge + cost-line source of truth) ---
		"b2b_promise_create": return {"text": "Müşteri kalır · söz borcu", "kind": &"accent"}
		"b2b_retain_delay": return {"text": "Kısa vadeli hamle", "kind": &"neutral"}
		"b2b_retain_discount": return {"text": "Müşteri kalır · MRR %s" % _fmt_money_delta(int(m.get("mrr_delta", 0))), "kind": &"negative"}
		"b2b_retain_ignore": return {"text": "müdahale yok · sayaç işlemeye devam eder", "kind": &"neutral"}
		"b2b_cs_promise_honor": return {"text": "Müşteri kalır · söz borcu doğar · yol haritasına eklenir", "kind": &"accent"}
		"b2b_cs_promise_refuse": return {"text": "Müşteriyi kaybet", "kind": &"negative"}
		"b2b_expand":
			var es: int = int(m.get("add_seats", 0))
			var em: int = es * int(m.get("per_seat_mrr", 0))
			return {"text": "Koltuk +%d · MRR %s" % [es, _fmt_money_delta(em)], "kind": &"positive"}
		"b2b_expand_decline": return {"text": "Değişiklik yok", "kind": &"neutral"}
		"angel_accept":
			# Two facts on one chip (the b2b_expand precedent above). This chip is the
			# player's only source of truth for what the decision COSTS, and the cost is
			# the equity, not the cash — so both ride, and the kind is "accent" (a trade)
			# rather than "positive" (a gift).
			return {"text": tr("ANGEL_CHIP_ACCEPT").format({
					"cash": _fmt_money_delta(AngelRoundSystem.CASH_AMOUNT),
					"equity": AngelRoundSystem.EQUITY_PCT}),
				"kind": &"accent"}
	return {}  # set_flag / mentor_advisory / ship_active_build / endgame types — bookkeeping or self-describing, no badge


static func _kind(delta: int) -> StringName:
	if delta > 0: return &"positive"
	if delta < 0: return &"negative"
	return &"neutral"


static func _char_name_or(id: String, fallback: String) -> String:
	# First name when the character is still in the registry, otherwise the caller's noun.
	# Sibling of _char_first, which is morale-specific and falls back to the word "Moral".
	if id == "":
		return fallback
	var c: Character = CharacterRegistry.get_character(id)
	if c == null:
		return fallback
	return c.character_name.split(" ", false)[0]


static func _char_first(id: String) -> String:
	if id == "":
		return "Moral"
	var c: Character = CharacterRegistry.get_character(id)
	if c == null:
		return "Moral"
	return c.character_name.split(" ", false)[0]


static func _fmt_signed(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return "%d" % value


static func _fmt_money_delta(value: int) -> String:
	# Integer division TRUNCATED, so −$1.500 read "NAKİT -$1K" — the chip understated the
	# cost of a choice by up to a third, and per the EFFECT-VISIBILITY RULE this chip IS
	# the player's source of truth for what a decision costs. One decimal below $10K keeps
	# the difference legible without widening the chip; above that the rounding error is
	# already under a percent and the shorter form reads better.
	var sign_str: String = "+" if value >= 0 else "-"
	var abs_v: int = absi(value)
	if abs_v >= 10000:
		return "%s$%dK" % [sign_str, int(round(abs_v / 1000.0))]
	if abs_v >= 1000:
		return "%s$%sK" % [sign_str, String.num(abs_v / 1000.0, 1)]
	return "%s$%d" % [sign_str, abs_v]


static func _markdown_to_bbcode(text: String) -> String:
	if text == "":
		return ""
	var bold := RegEx.new()
	bold.compile("\\*\\*(.+?)\\*\\*")
	var italic := RegEx.new()
	italic.compile("\\*(.+?)\\*")
	var out: String = bold.sub(text, "[b]$1[/b]", true)
	out = italic.sub(out, "[i]$1[/i]", true)
	return out
