extends Control

# Event modal — mounted into GameShell/ModalLayer by main.gd when EventManager
# emits modal_requested. Renders the event's header, art placeholder, character
# context strip (conditional), body with markdown→BBCode, and dynamic choice
# buttons with modifier preview badges. Locked choices use the disabled-card
# recipe established by onboarding's Coming Soon cards.
#
# Lifecycle: main.gd instances → populate(event) → wait for player click on a
# choice → EventManager.resolve_choice() applies modifiers + emits
# event_resolved → main.gd queue_frees this node.
#
# Tree pause behavior: process_mode = ALWAYS (set in .tscn) so input + buttons
# work while paused. main.gd paused the tree via speed_change_requested(0) just
# before instancing this scene.

const RELATIONSHIP_COLORS := {
	"ally":     Color(0.60, 0.85, 0.55),
	"friendly": Color(0.55, 0.80, 0.75),
	"neutral":  Color(0.65, 0.60, 0.50),
	"wary":     Color(0.85, 0.65, 0.40),
	"hostile":  Color(0.85, 0.45, 0.45),
}

const COLOR_GAIN := Color(0.65, 0.85, 0.55)
const COLOR_LOSS := Color(0.85, 0.55, 0.50)
const COLOR_NEUTRAL := Color(0.78, 0.72, 0.61)

var _event: GameEvent = null
var _resolved: bool = false  # one-shot: a modal resolves at most once (blocks double-click)

@onready var title_label: Label = $CenterPanel/Body/HeaderBand/TitleLabel
@onready var id_code_label: Label = $CenterPanel/Body/HeaderBand/IdCodeLabel
@onready var caption_label: Label = $CenterPanel/Body/ArtRegion/CaptionStrip
@onready var character_context: Control = $CenterPanel/Body/CharacterContext
@onready var name_role_label: Label = $CenterPanel/Body/CharacterContext/TextCol/NameRoleLabel
@onready var relationship_pill: Label = $CenterPanel/Body/CharacterContext/TextCol/RelationshipPill
@onready var traits_label: Label = $CenterPanel/Body/CharacterContext/TextCol/TraitsLabel
@onready var body_rich: RichTextLabel = $CenterPanel/Body/BodyRichText
@onready var choices_container: VBoxContainer = $CenterPanel/Body/ChoicesContainer


func populate(event: GameEvent) -> void:
	_event = event
	if not is_node_ready():
		await ready
	title_label.text = event.title
	id_code_label.text = "EV · %s" % _short_code(event.id)
	caption_label.text = event.subtitle
	body_rich.text = _markdown_to_bbcode(_drop_cap(event.body_text))
	_render_character_context()
	_render_choices()


# --- Character context ---

func _render_character_context() -> void:
	if _event.character_id == "":
		character_context.visible = false
		return
	var c: Character = CharacterRegistry.get_character(_event.character_id)
	if c == null:
		character_context.visible = false
		push_warning("[EventModal] event.character_id refers to unknown character: %s" % _event.character_id)
		return
	character_context.visible = true
	name_role_label.text = "%s · %s" % [c.character_name, c.role]
	_apply_relationship_pill(c.relationship)
	# First 1-2 traits joined; empty array renders empty label.
	var first_traits: Array = c.traits.slice(0, 2)
	traits_label.text = " · ".join(first_traits)


func _apply_relationship_pill(rel: String) -> void:
	relationship_pill.text = rel.to_upper()
	var color: Color = RELATIONSHIP_COLORS.get(rel, RELATIONSHIP_COLORS["neutral"])
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_right = 3
	sb.corner_radius_bottom_left = 3
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	relationship_pill.add_theme_stylebox_override("normal", sb)
	relationship_pill.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))


# --- Choice rendering ---

func _render_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()
	for idx in _event.choices.size():
		var choice: EventChoice = _event.choices[idx]
		var btn: Control = _build_choice_button(choice, idx)
		choices_container.add_child(btn)


func _build_choice_button(choice: EventChoice, idx: int) -> Control:
	var unlocked: bool = EventManager.is_condition_met(choice.unlock_condition)

	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(0, 56)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.165, 0.137, 0.106)
	sb.border_color = Color(0.35, 0.30, 0.24) if unlocked else Color(0.50, 0.42, 0.32)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_right = 4
	sb.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	row.anchor_right = 1.0
	row.anchor_bottom = 1.0
	row.offset_left = 14.0
	row.offset_right = -14.0
	row.offset_top = 8.0
	row.offset_bottom = -8.0
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)

	var label := Label.new()
	label.text = choice.label
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color(0.949, 0.898, 0.788))
	label.add_theme_font_size_override("font_size", 14)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)

	if unlocked:
		_add_modifier_badges(row, choice.modifiers)
		panel.gui_input.connect(_on_choice_input.bind(idx))
	else:
		# Locked recipe — mirrors onboarding's Coming Soon cards.
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.focus_mode = Control.FOCUS_NONE
		panel.modulate = Color(1, 1, 1, 0.45)
		var lock_label := Label.new()
		lock_label.text = "[%s]" % choice.unlock_reason_text if choice.unlock_reason_text != "" else "[Kilitli]"
		lock_label.add_theme_color_override("font_color", Color(0.78, 0.72, 0.61))
		lock_label.add_theme_font_size_override("font_size", 11)
		lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(lock_label)

	return panel


func _add_modifier_badges(row: HBoxContainer, modifiers: Array) -> void:
	for m in modifiers:
		if typeof(m) != TYPE_DICTIONARY:
			continue
		var badge := Label.new()
		badge.text = _format_modifier(m)
		badge.add_theme_color_override("font_color", _modifier_color(m))
		badge.add_theme_font_size_override("font_size", 12)
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(badge)


func _on_choice_input(event: InputEvent, idx: int) -> void:
	if _resolved:
		return  # already picked a choice; ignore further clicks (deferred free keeps buttons live)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_resolved = true
		EventManager.resolve_choice(_event.id, idx)


# --- Formatters ---

static func _short_code(id: String) -> String:
	# "ev_debug_001_engineer_workload" -> "001" (third token if present, else id)
	var parts: PackedStringArray = id.split("_")
	if parts.size() >= 3:
		return parts[2]
	return id


static func _markdown_to_bbcode(text: String) -> String:
	if text == "":
		return ""
	var bold := RegEx.new()
	bold.compile("\\*\\*(.+?)\\*\\*")
	var italic := RegEx.new()
	italic.compile("\\*(.+?)\\*")
	# Bold first so ** doesn't get half-consumed by italic.
	var out: String = bold.sub(text, "[b]$1[/b]", true)
	out = italic.sub(out, "[i]$1[/i]", true)
	return out


static func _drop_cap(text: String) -> String:
	if text.length() == 0:
		return text
	return "[font_size=28]%s[/font_size]%s" % [text.substr(0, 1), text.substr(1)]


static func _format_modifier(m: Dictionary) -> String:
	var t: String = m.get("type", "")
	var delta: int = int(m.get("delta", 0))
	match t:
		"cash":
			return "Cash %s" % _fmt_money_delta(delta)
		"mrr":
			return "MRR %s" % _fmt_money_delta(delta)
		"brand":
			return "Brand %s" % _fmt_signed(delta)
		"reputation":
			return "Rep %s" % _fmt_signed(delta)
		"morale":
			return "%s morale" % _fmt_signed(delta)
		"morale_all_employees":
			return "Tüm ekip %s morale" % _fmt_signed(delta)
	return t


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


func _modifier_color(m: Dictionary) -> Color:
	var delta: int = int(m.get("delta", 0))
	if delta > 0:
		return COLOR_GAIN
	if delta < 0:
		return COLOR_LOSS
	return COLOR_NEUTRAL
