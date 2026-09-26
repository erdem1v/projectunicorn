class_name DialoguePortraitCard
extends PanelContainer

# Cinematic-register portrait: a 4:5 bust in a thin frame (PortraitFrame variation).
# Renders whatever path it is given and falls back to a charcoal fill + initials when
# the file is missing, so the scene never breaks on absent art.
#
# PanelContainer fits every child to its content rect, so FallbackBg, Fallback and
# Portrait stack and the topmost visible one wins; clip_contents crops the
# covered-aspect texture to the frame.

@onready var _fallback_bg: ColorRect = $FallbackBg
@onready var _fallback: Label = $Fallback
@onready var _portrait: TextureRect = $Portrait


func _ready() -> void:
	_fallback_bg.color = UiTokens.DIALOGUE_BG


func set_portrait(path: String, fallback_initials: String = "") -> void:
	_fallback.text = fallback_initials
	var tex: Texture2D = load(path) as Texture2D if path != "" and ResourceLoader.exists(path) else null
	_portrait.texture = tex
	_portrait.visible = tex != null
	_fallback.visible = tex == null and fallback_initials != ""
	if tex == null and path != "":
		push_warning("[DialoguePortraitCard] portrait missing, using fallback: %s" % path)
