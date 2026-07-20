extends Control

# Event modal — mounted into GameShell/ModalLayer by main.gd when EventManager
# emits modal_requested. Renders the header band (§ + title + EV·code), an art
# placeholder frame, the character strip (avatar + name/role + relationship pill
# + trait chips), a drop-cap serif body, and choice cards whose effects render as
# tinted badges. Locked choices show a visible, dimmed row with an unlock chip.
#
# Visual language comes from master_theme.tres variations + UiFactory; this
# controller only wires data + runtime state.
#
# Lifecycle: main.gd instances → populate(event) → player clicks a choice →
# EventManager.resolve_choice() → event_resolved → main.gd frees this node.
# process_mode = ALWAYS (.tscn) so input works while the tree is paused.

var _event: GameEvent = null
var _resolved: bool = false  # one-shot guard against double-click

@onready var title_label: Label = $CenterPanel/Body/HeaderBand/Row/TitleLabel
@onready var id_code_label: Label = $CenterPanel/Body/HeaderBand/Row/IdCodeLabel
@onready var art_region: Panel = $CenterPanel/Body/ArtRegion
@onready var caption_label: Label = $CenterPanel/Body/ArtRegion/CaptionStrip
@onready var character_context: Control = $CenterPanel/Body/CharacterContext
@onready var portrait_initial: Label = $CenterPanel/Body/CharacterContext/PortraitPanel/Initial
@onready var name_role_label: Label = $CenterPanel/Body/CharacterContext/TextCol/NameRoleLabel
@onready var chips_row: HBoxContainer = $CenterPanel/Body/CharacterContext/TextCol/ChipsRow
@onready var relationship_pill: Label = $CenterPanel/Body/CharacterContext/TextCol/ChipsRow/RelationshipPill
@onready var body_rich: RichTextLabel = $CenterPanel/Body/BodyRichText
@onready var choices_container: VBoxContainer = $CenterPanel/Body/ChoicesContainer


func populate(event: GameEvent) -> void:
	_event = event
	if not is_node_ready():
		await ready
	title_label.text = "§  %s" % event.title
	id_code_label.text = "EV · %s" % _short_code(event.id)
	caption_label.text = event.subtitle
	# B2B Sales modals go header → speaker → in-voice body → options (no illustration
	# frame), which also frees the vertical room the taller cost-line rows need.
	art_region.visible = not _is_b2b_event()
	body_rich.text = _markdown_to_bbcode(_drop_cap(event.body_text))
	_render_character_context()
	_render_choices()


# --- Character context ---

func _render_character_context() -> void:
	# Clear any prior extra chips (leave the relationship/status pill node in place).
	for child in chips_row.get_children():
		if child != relationship_pill:
			child.queue_free()
	if _event.character_id != "":
		_render_registry_character()
	elif _event.speaker_name != "":
		_render_synthetic_speaker()
	else:
		character_context.visible = false


func _render_registry_character() -> void:
	var c: Character = CharacterRegistry.get_character(_event.character_id)
	if c == null:
		character_context.visible = false
		push_warning("[EventModal] event.character_id refers to unknown character: %s" % _event.character_id)
		return
	character_context.visible = true
	relationship_pill.visible = true
	name_role_label.text = "%s · %s" % [c.character_name, c.role]
	portrait_initial.text = _initials(c.character_name)
	_apply_relationship_pill(c.relationship)
	# Trait chips (first 2) appended after the relationship pill.
	for t in c.traits.slice(0, 2):
		chips_row.add_child(UiFactory.make_badge(String(t), &"neutral"))


func _render_synthetic_speaker() -> void:
	# A non-Character speaker (e.g. a B2B customer talking in their own voice), rendered
	# straight from the event's speaker_* fields — no CharacterRegistry lookup.
	character_context.visible = true
	if _event.speaker_role != "":
		name_role_label.text = "%s · %s" % [_event.speaker_name, _event.speaker_role]
	else:
		name_role_label.text = _event.speaker_name
	portrait_initial.text = _event.speaker_initial if _event.speaker_initial != "" else _initials(_event.speaker_name)
	if _event.speaker_status != "":
		relationship_pill.visible = true
		_apply_status_pill(_event.speaker_status, StringName(String(_event.speaker_status_kind)))
	else:
		relationship_pill.visible = false
	for chip in _event.speaker_chips:
		if typeof(chip) == TYPE_DICTIONARY:
			chips_row.add_child(UiFactory.make_badge(
				String(chip.get("text", "")), StringName(String(chip.get("kind", "neutral")))))


func _apply_status_pill(text: String, kind: StringName) -> void:
	# Status chip in the relationship-pill slot, tinted from a badge palette (kind).
	relationship_pill.text = UiTokens.tr_upper(text)
	var pal: Dictionary = UiTokens.badge_palette(kind)
	var sb := StyleBoxFlat.new()
	sb.bg_color = pal.bg
	sb.set_corner_radius_all(3)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	relationship_pill.add_theme_stylebox_override("normal", sb)
	relationship_pill.add_theme_color_override("font_color", pal.fg)


func _apply_relationship_pill(rel: String) -> void:
	relationship_pill.text = UiTokens.tr_upper(rel)
	var pal: Dictionary = UiTokens.relationship_palette(rel)
	var sb := StyleBoxFlat.new()
	sb.bg_color = pal.bg
	sb.set_corner_radius_all(3)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	relationship_pill.add_theme_stylebox_override("normal", sb)
	relationship_pill.add_theme_color_override("font_color", pal.fg)


# --- Choice rendering ---

func _render_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()
	for idx in _event.choices.size():
		choices_container.add_child(_build_choice_card(_event.choices[idx], idx))


func _build_choice_card(choice: EventChoice, idx: int) -> Control:
	var unlocked: bool = EventManager.is_condition_met(choice.unlock_condition)
	# Retention-family choices use the two-row cost-line layout (bold label + a dim cost
	# line beneath) instead of inline effect badges. The cost line is derived from the
	# SAME _describe_modifier used for badges, so label and cost can never desync.
	var use_cost_line: bool = _is_b2b_event()
	var cost_line: String = _cost_summary(choice.modifiers) if (unlocked and use_cost_line) else ""
	var card: Dictionary = UiFactory.make_choice_card(choice.label, not unlocked, cost_line)
	var root: PanelContainer = card.root
	var row: HBoxContainer = card.row
	if unlocked:
		if not use_cost_line:
			_add_modifier_badges(row, choice.modifiers)
		root.gui_input.connect(_on_choice_input.bind(idx))
	else:
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.focus_mode = Control.FOCUS_NONE
		var reason: String = choice.unlock_reason_text if choice.unlock_reason_text != "" else "KİLİTLİ"
		row.add_child(UiFactory.make_badge(reason, &"neutral"))
	return root


func _add_modifier_badges(row: HBoxContainer, modifiers: Array) -> void:
	for m in modifiers:
		var desc: Dictionary = _describe_modifier(m)
		if desc.is_empty():
			continue
		row.add_child(UiFactory.make_badge(desc.text, desc.kind))


func _cost_summary(modifiers: Array) -> String:
	# One readable-TR cost line built from the choice's modifiers via _describe_modifier
	# (single source of effect truth — costs are never hand-authored into the label).
	var parts: PackedStringArray = []
	for m in modifiers:
		var desc: Dictionary = _describe_modifier(m)
		if not desc.is_empty():
			parts.append(String(desc.text))
	return " · ".join(parts)


func _is_b2b_event() -> bool:
	# True for B2B Sales System modals (retention, escalation) — tagged "b2b_*".
	for t in _event.tags:
		if String(t).begins_with("b2b_"):
			return true
	return false


func _on_choice_input(event: InputEvent, idx: int) -> void:
	if _resolved:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_resolved = true
		EventManager.resolve_choice(_event.id, idx)


# --- Formatters ---

static func _short_code(id: String) -> String:
	var parts: PackedStringArray = id.split("_")
	if parts.size() >= 3:
		return parts[2]
	return id


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
		# Player-facing effects that previously rendered no badge (choices were blind).
		"churn_customer": return {"text": "Müşteri kaybı", "kind": &"negative"}
		"add_prospect": return {"text": "Yeni aday", "kind": &"positive"}
		"convert_audience": return {"text": "Kitleden dönüşüm %%%d" % int(round(float(m.get("pct", 0.0)) * 100.0)), "kind": &"positive"}
		"open_paid_tier": return {"text": "Ücretli katman açılır", "kind": &"accent"}
		"add_character": return {"text": "Yeni ekip üyesi", "kind": &"positive"}
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
	return {}  # set_flag / mentor_advisory / ship_active_build / endgame types — bookkeeping or self-describing, no badge


static func _kind(delta: int) -> StringName:
	if delta > 0: return &"positive"
	if delta < 0: return &"negative"
	return &"neutral"


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
	var sign_str: String = "+" if value >= 0 else "-"
	var abs_v: int = absi(value)
	if abs_v >= 1000:
		return "%s$%dK" % [sign_str, int(abs_v / 1000)]
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


static func _drop_cap(text: String) -> String:
	if text.length() == 0:
		return text
	# Only drop-cap a real leading letter (upper != lower keeps Turkish İ/ı/Ç…).
	# Wrapping a markdown marker or BBCode tag would interleave tags (Faz 1 bug 1.4).
	var first: String = text.substr(0, 1)
	if first.to_upper() == first.to_lower():
		return text
	return "[font_size=30]%s[/font_size]%s" % [first, text.substr(1)]
