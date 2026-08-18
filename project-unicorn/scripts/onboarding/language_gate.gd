extends Control

# FIRST-BOOT LANGUAGE GATE — the very first thing a new player sees, before onboarding.
#
# WHY A GATE AND NOT A ROW INSIDE ONBOARDING: it mounts before any tr() in the flow runs,
# so the whole onboarding builds in the chosen locale with ZERO re-render wiring. A
# language row inside CharacterStep would instead force the flow chrome to repaint, the
# current step to re-mount, and the half-filled draft to survive that re-mount — three
# problems bought for nothing.
#
# THE TWO LABELS ARE DELIBERATELY NOT KEYS. "Türkçe" and "English" are each written in
# their OWN language, because at this moment the player has not told us which one they
# read — an option that renders in the language you cannot read is not an option. This is
# the single sanctioned player-visible literal in the game, and loc_residue's SKIP list
# names this file for exactly that reason.
#
# The OS locale only PRESELECTS (focus + a quiet hint). The click is always explicit:
# guessing silently is how a player ends up in a language they did not choose and cannot
# navigate out of.

signal chosen(locale: String)

const TR_LABEL := "Türkçe"
const EN_LABEL := "English"

@onready var _background: Panel = $Background
@onready var _center: VBoxContainer = $Center
@onready var _buttons: HBoxContainer = $Center/Buttons

var _tr_btn: Button
var _en_btn: Button


func _ready() -> void:
	_apply_dark_register()
	_build()


func _apply_dark_register() -> void:
	# Threshold register, same recipe as OnboardingFlow: colors come from tokens in code,
	# never inline in the .tscn (UiTokens law).
	var bg := StyleBoxFlat.new()
	bg.bg_color = UiTokens.DIALOGUE_BG
	_background.add_theme_stylebox_override("panel", bg)


func _build() -> void:
	# The wordmark carries no language, so it can sit above a choice not yet made.
	var brand := UiFactory.make_label("Project Unicorn", &"DialogueName")
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center.add_child(brand)
	_center.move_child(brand, 0)

	_tr_btn = _make_option(TR_LABEL, "tr")
	_en_btn = _make_option(EN_LABEL, "en")
	_buttons.add_child(_tr_btn)
	_buttons.add_child(_en_btn)

	# Preselect from the OS, focus only — never auto-advance.
	var prefer_tr: bool = OS.get_locale_language() == "tr"
	(_tr_btn if prefer_tr else _en_btn).grab_focus()


func _make_option(label: String, locale: String) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"CommitButton"   # style from the theme, never inline here
	b.text = label
	b.custom_minimum_size = Vector2(220, 64)
	b.pressed.connect(_on_chosen.bind(locale))
	return b


func _on_chosen(locale: String) -> void:
	# Persistence is free: set_language writes Settings and emits language_changed, which
	# is also what makes is_first_boot() false from here on.
	Localization.set_language(locale)
	chosen.emit(locale)
