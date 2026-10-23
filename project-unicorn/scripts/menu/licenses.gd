extends Control

## The legal text as one plain scrolled read, in its own language (English): read at run time from the
## engine and from the licence files the export packs, so it never goes stale against the shipped build.
## Back shows only when the opener listens for it (Credits); Settings opens it without.

signal back
signal dismissed

const HEIGHT := 920
const SCREEN_GAP := 52   # the room the window leaves above and below on a short screen (864 → 760)
const FONT_DIRS := ["archivo", "sans", "serif", "mono", "fallback"]
const LUCIDE := "res://assets/art/office/icons/LICENSE-lucide.txt"

@onready var _sections: VBoxContainer = %Sections
@onready var _back_btn: Button = %BackBtn
@onready var _close_btn: Button = %CloseBtn


func _ready() -> void:
	($Dimmer as ColorRect).color = UiTokens.D_SCRIM
	var half: float = minf(HEIGHT, get_viewport_rect().size.y - 2 * SCREEN_GAP) / 2.0
	%Panel.offset_top = -half
	%Panel.offset_bottom = half
	%TitleLabel.text = Fmt.upper(tr("CREDITS_LICENSES"))
	_back_btn.visible = not back.get_connections().is_empty()
	_back_btn.pressed.connect(func() -> void:
		back.emit()
		queue_free())
	_close_btn.pressed.connect(_close)
	_close_btn.grab_focus()
	var components := PackedStringArray([tr("LIC_GODOT_LOGO")])
	for c in Engine.get_copyright_info():
		var lines := PackedStringArray([c.name])
		for part in c.parts:
			lines.append("Copyright: %s · License: %s" % ["; ".join(part.copyright), part.license])
		components.append("\n".join(lines))
	var licenses: Dictionary = Engine.get_license_info()
	for id in licenses:
		components.append("%s\n%s" % [id, licenses[id]])
	var fonts := PackedStringArray()
	for dir in FONT_DIRS:
		fonts.append(FileAccess.get_file_as_string("res://assets/fonts/%s/OFL.txt" % dir))
	_add_section("", tr("LIC_GODOT_HEAD") + "\n\n" + Engine.get_license_text())
	_add_section("", tr("LIC_FREETYPE").format({"year": freetype_year()}))
	_add_section("LIC_THIRD_PARTY", "\n\n".join(components))
	_add_section("LIC_FONTS", "\n\n".join(fonts))
	_add_section("LIC_ICONS", FileAccess.get_file_as_string(LUCIDE))


## The end of FreeType's copyright range ("1996-2025, David Turner, …").
static func freetype_year() -> String:
	for c in Engine.get_copyright_info():
		if c.name == "The FreeType Project":
			return String(c.parts[0].copyright[0]).get_slice(",", 0).get_slice("-", 1)
	return ""


func _add_section(title_key: String, body: String) -> void:
	if title_key != "":
		_sections.add_child(UiFactory.make_label(tr(title_key), &"KeyLabel"))
	var label := UiFactory.make_label(body, &"MetaText")
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sections.add_child(label)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()
	# The text takes no focus: the up and down keys scroll it from the footer's buttons, a quarter page a press.
	elif event.is_action_pressed("ui_down", true) or event.is_action_pressed("ui_up", true):
		get_viewport().set_input_as_handled()
		var bar: VScrollBar = $Panel/Col/Scroll.get_v_scroll_bar()
		bar.value += bar.page / 4.0 * (1 if event.is_action("ui_down") else -1)


func _close() -> void:
	dismissed.emit()
	queue_free()
