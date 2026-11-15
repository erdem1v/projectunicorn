extends RefCounted

# Pazaryeri penceresinin sayfalarının ortak parçaları: tablo hücresi, adım düğmeli sayı seçici ("eski → yeni"), ipuçlu sonuç çipi,
# süreli kilit satırı ve parçalı seçimin bekleyen seçim çerçevesiyle boyası. Parçalar yalnız çizer; değeri ve eylemi çağıran verir.

const ICON := "res://assets/icons/util/%s.svg"
## The figure of a stepper: wide enough for "was → now" to keep the keys where they are.
const STEPPER_W := 80
const CHIP_ICONS := {&"gain": "tri_up", &"cost": "minus"}


## A row or a chip that opens a rich tip over itself when it has one (`build`); a table row with a tip lights while the pointer
## rests on it.
class TipRow extends PanelContainer:
	var build: Callable

	func _make_custom_tooltip(_for_text: String) -> Object:
		return build.call() if build.is_valid() else null

	func _notification(what: int) -> void:
		if build.is_valid() and theme_type_variation in [&"TableRow", &"TableRowHover"]:
			if what == NOTIFICATION_MOUSE_ENTER:
				theme_type_variation = &"TableRowHover"
			elif what == NOTIFICATION_MOUSE_EXIT:
				theme_type_variation = &"TableRow"


## A weekly order figure: one decimal under 10, so a small marketplace's gain does not read "+0"; grouped whole from there.
static func count(v: float) -> String:
	return Fmt.number(v, 1) if v < 10.0 else Fmt.group(roundi(v))


## A label of a fixed width: a column's cell in a table row.
static func cell(text: String, look: StringName, width: int, align: HorizontalAlignment, ink: Variant = null) -> Label:
	var label := SprintUiShared.label(text, look, ink)
	label.custom_minimum_size.x = width
	label.horizontal_alignment = align
	return label


## A stepper in its box: minus, the figure and plus between rules; `on_step` takes -1 or 1 and a key whose way is closed is
## disabled. While a change is pending the figure shows the value in force faint before the new one, "12% → 13%"; `was` is empty
## when nothing changes. The caller adds what sits at the row's far end.
static func stepper(value: String, was: String, can_down: bool, can_up: bool, on_step: Callable) -> PanelContainer:
	var figure := SprintUiShared.box(UiTokens.SPACE_M)
	figure.custom_minimum_size.x = STEPPER_W
	figure.alignment = BoxContainer.ALIGNMENT_CENTER
	if was != "":
		figure.add_child(SprintUiShared.label(was, &"CapFigure", UiTokens.D_INK_4))
		figure.add_child(UiFactory.make_glyph(SprintUiShared.ARROW, UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
	figure.add_child(SprintUiShared.label(value, &"CapFigure"))
	var keys := SprintUiShared.box(0)
	keys.add_child(_key("minus", "MP_LESS", can_down, on_step.bind(-1)))
	keys.add_child(_rule())
	keys.add_child(figure)
	keys.add_child(_rule())
	keys.add_child(_key("plus", "MP_MORE", can_up, on_step.bind(1)))
	var box := PanelContainer.new()
	box.theme_type_variation = &"StepperBox"
	box.add_child(keys)
	return box


static func _key(icon: String, tip_key: String, enabled: bool, on_press: Callable) -> Button:
	var key := Button.new()
	key.theme_type_variation = &"StepKey"
	key.icon = load(ICON % icon)
	key.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key.custom_minimum_size.x = UiTokens.D_H_KEY_SM
	key.focus_mode = Control.FOCUS_NONE   # the space bar is the speed key; focus must not swallow it
	key.tooltip_text = TranslationServer.translate(tip_key)
	key.disabled = not enabled
	if enabled:
		key.pressed.connect(on_press)
	return key


static func _rule() -> ColorRect:
	var rule := ColorRect.new()
	rule.color = UiTokens.D_LINE_1
	rule.custom_minimum_size.x = UiTokens.BORDER_HAIRLINE
	return rule


## A change's result chip: a sentence with its glyph in its tone (a gain green with an arrow up, a cost in the warning tone with a
## minus, a plain fact in ink), one step larger than a tag. A forecast's cost is a warning, not the events' plain ink: the player
## can still step back. `tip_lines` is the rich tip of what the figure is made of.
static func chip(text: String, kind: StringName, tip_lines: Array) -> TipRow:
	var box := TipRow.new()
	box.theme_type_variation = &"FxChip"
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ink: Color = {&"gain": UiTokens.D_pos(), &"cost": UiTokens.D_warn()}.get(kind, UiTokens.D_INK_2)
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	row.add_child(UiFactory.make_glyph(ICON % CHIP_ICONS.get(kind, "info"), UiTokens.D_ICON_PART, ink))
	row.add_child(UiFactory.make_label(text, &"KeyText", ink))
	box.add_child(row)
	box.build = _lines_tip.bind(tip_lines)
	box.tooltip_text = text
	HRUiShared.set_mouse_ignore(row)
	return box


## Chips side by side; they wrap when they do not fit.
static func chip_flow(chips: Array) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_M)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	for c: Control in chips:
		flow.add_child(c)
	return flow


## A tip of plain lines.
static func _lines_tip(lines: Array) -> Control:
	var tip := SprintUiShared.tip_column()
	tip.add_theme_constant_override("separation", UiTokens.SPACE_S)
	for line: String in lines:
		tip.add_child(SprintUiShared.prose(line, &"CaptionPrimary"))
	return tip


## What a change that stands holds still: a lock glyph and "4 weeks locked". `weeks` is how long it stands.
static func lock_row(weeks: int) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(UiFactory.make_glyph(UiFactory.LOCK_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_OFF))
	row.add_child(SprintUiShared.label(TranslationServer.translate("MP_LOCK_FOR").format({"weeks": Fmt.weeks(weeks)}),
		&"MetaMuted"))
	return row


## Apply with its lock row beside it: open only when there is a change to apply.
static func apply_cell(weeks: int, can_apply: bool, on_press: Callable) -> HBoxContainer:
	var cell := SprintUiShared.box(UiTokens.SPACE_L)
	cell.add_child(lock_row(weeks))
	var apply := SprintUiShared.button(TranslationServer.translate("MP_APPLY"), &"PrimaryButtonDarkSmall", on_press)
	apply.disabled = not can_apply
	cell.add_child(apply)
	return cell


## A choice made and not applied yet: its segment gets a frame (`restyle_segments` draws it). `pick` is a `D_seg_pick` box.
static func mark_pending(pick: Control, index: int) -> void:
	(pick.get_child(0).get_children().filter(func(n: Node) -> bool: return n is Button)[index] as Button).set_meta(&"pending", true)


## The chosen segment of a closed pick under `root` loses its fill, so a shut row does not read as open; the segment a pending
## choice is on gets a frame in every state the pointer can put it in. The theme's own boxes are copied, so sizes stay. The theme
## has no variation for these two states, so the window's segments are styled here, in script. Call it deferred after painting.
static func restyle_segments(root: Node) -> void:
	for b: Button in root.find_children("*", "Button", true, false):
		if b.disabled and b.theme_type_variation == &"SegPickOn":
			var dim := b.get_theme_stylebox(&"disabled").duplicate() as StyleBoxFlat
			dim.bg_color = Color.TRANSPARENT
			b.add_theme_stylebox_override(&"disabled", dim)
		if b.has_meta(&"pending"):
			for state in [&"normal", &"hover", &"pressed"]:
				var frame := b.get_theme_stylebox(state).duplicate() as StyleBoxFlat
				frame.border_color = UiTokens.D_INK_1
				frame.set_border_width_all(UiTokens.BORDER_HAIRLINE)
				b.add_theme_stylebox_override(state, frame)
