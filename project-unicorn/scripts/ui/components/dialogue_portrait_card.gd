class_name DialoguePortraitCard
extends PanelContainer

# Shared cinematic-register component (Spec 5) — a 4:5 portrait bust in a thin cream
# rounded frame (PortraitFrame variation). Its consumer (MeetingScene / FrankPopup)
# anchors it to overlap the dialogue column's top edge — the signature move of the
# composition.
#
# Humble view: reads no autoloads except UiTokens; renders whatever path it is given
# and falls back gracefully (charcoal fill + initials) when the file is missing, so the
# scene never crashes on absent art (Frank's portrait is not authored yet — §1/§4).
#
# Godot concept: PanelContainer fits every child to its content rect, so FallbackBg,
# Fallback and Portrait stack; the topmost visible one wins. clip_contents crops the
# covered-aspect texture to the frame.

@onready var _fallback_bg: ColorRect = $FallbackBg
@onready var _fallback: Label = $Fallback
@onready var _portrait: TextureRect = $Portrait


func _ready() -> void:
	# Colors come from tokens (never inline in the .tscn) so grep stays clean.
	_fallback_bg.color = UiTokens.DIALOGUE_BG


func set_portrait(path: String, fallback_initials: String = "") -> void:
	_fallback.text = fallback_initials
	if path != "" and ResourceLoader.exists(path):
		var tex: Texture2D = load(path)
		if tex is Texture2D:
			_portrait.texture = tex
			_portrait.visible = true
			_fallback.visible = false
			return
	# Missing / unloadable — charcoal FallbackBg stays, show initials, warn once.
	_portrait.texture = null
	_portrait.visible = false
	_fallback.visible = fallback_initials != ""
	if path != "":
		push_warning("[DialoguePortraitCard] portrait missing, using fallback: %s" % path)
