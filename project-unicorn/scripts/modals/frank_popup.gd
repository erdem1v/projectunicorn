class_name FrankPopup
extends Control

# Compact centered variant of the cinematic dialogue shell (Spec 5 §4) — the mentor
# register. Same PURE-VIEW contract and the SAME shared components as MeetingScene
# (DialoguePortraitCard, DialogueChoiceCard); it just omits the room art, İKNA track and
# stat strip and lays out a compact card over the dimmed game. Reads no autoloads except
# UiTokens; emits choice intents only.
#
# process_mode = ALWAYS (.tscn) — interactive on the paused tree (ledger 6). Ledger 11:
# no default focus; number keys 1-3 and mouse clicks select; blind Enter/Space inert.

signal choice_selected(id: String)
signal withdraw_requested()

const CHOICE_CARD := preload("res://scenes/ui/components/DialogueChoiceCard.tscn")

@onready var _dimmer: ColorRect = $Dimmer
@onready var _portrait: DialoguePortraitCard = $Card/Portrait
@onready var _name: Label = $Card/Body/Content/NameBlock/NameLabel
@onready var _role: Label = $Card/Body/Content/NameBlock/RoleLabel
@onready var _monologue_wrap: MarginContainer = $Card/Body/Content/MonologueWrap
@onready var _monologue: Label = $Card/Body/Content/MonologueWrap/MonologueLabel
@onready var _quote_box: PanelContainer = $Card/Body/Content/QuoteBox
@onready var _quote: Label = $Card/Body/Content/QuoteBox/QuoteVBox/QuoteLabel
@onready var _tag: Label = $Card/Body/Content/QuoteBox/QuoteVBox/TagLabel
@onready var _choices_box: VBoxContainer = $Card/Body/Content/Choices
@onready var _beat: Label = $Card/Body/Content/Footer/BeatLabel
@onready var _withdraw: Button = $Card/Body/Content/Footer/WithdrawBtn

var _cards: Array[DialogueChoiceCard] = []


func _ready() -> void:
	_dimmer.color = UiTokens.SCRIM_MODAL          # from token, never inline in the .tscn
	_withdraw.focus_mode = Control.FOCUS_NONE      # ledger 11 — no keyboard focus target
	_withdraw.pressed.connect(_on_withdraw_pressed)
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)


func populate(view_state: Dictionary) -> void:
	_portrait.set_portrait(
		String(view_state.get("portrait_path", "")),
		_initials(String(view_state.get("speaker_name", ""))))
	_name.text = UiTokens.tr_upper(String(view_state.get("speaker_name", "")))
	_role.text = UiTokens.tr_upper(String(view_state.get("speaker_role", "")))
	_apply_active_line(view_state.get("active_line", {}), String(view_state.get("monologue_text", "")))
	_build_choices(view_state.get("choices", []))
	_beat.text = UiTokens.tr_upper(String(view_state.get("beat_label", "")))
	_withdraw.visible = bool(view_state.get("can_withdraw", false))


func _apply_active_line(line: Dictionary, monologue_text: String) -> void:
	if bool(line.get("is_monologue", false)):
		_quote_box.visible = false
		_monologue_wrap.visible = true
		_monologue.text = String(line.get("text", ""))
	else:
		_quote_box.visible = true
		_quote.text = String(line.get("text", ""))
		_tag.text = UiTokens.tr_upper(String(line.get("speaker_tag", "")))
		_monologue_wrap.visible = monologue_text != ""
		_monologue.text = monologue_text


func _build_choices(choices: Array) -> void:
	for c in _cards:
		if is_instance_valid(c):
			c.queue_free()
	_cards.clear()
	for i in choices.size():
		var card: DialogueChoiceCard = CHOICE_CARD.instantiate()
		_choices_box.add_child(card)          # add before setup — @onready refs resolve here
		card.setup(i, choices[i])
		card.selected.connect(_on_choice_selected)
		_cards.append(card)


func _initials(full_name: String) -> String:
	var out := ""
	for p in full_name.strip_edges().split(" ", false):
		if p.length() > 0:
			out += p[0]
		if out.length() >= 2:
			break
	return UiTokens.tr_upper(out)


func _on_choice_selected(id: String) -> void:
	choice_selected.emit(id)


func _on_withdraw_pressed() -> void:
	withdraw_requested.emit()


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var idx := -1
	match (event as InputEventKey).keycode:
		KEY_1, KEY_KP_1: idx = 0
		KEY_2, KEY_KP_2: idx = 1
		KEY_3, KEY_KP_3: idx = 2
	if idx >= 0 and idx < _cards.size():
		get_viewport().set_input_as_handled()
		_cards[idx].select()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _withdraw.visible:
		get_viewport().set_input_as_handled()
		withdraw_requested.emit()


# --- Debug fixture (§6) — literal view_state, no autoload reads. ---

static func debug_fixture() -> Dictionary:
	return {
		# portrait_frank.webp is not authored yet — the guard renders the "FK" fallback
		# and this drops in the real portrait once it lands (§1/§4).
		"portrait_path": "res://assets/art/investors/portrait_frank.webp",
		"speaker_name": "Frank Köseoğlu",
		"speaker_role": "Mentor / Operating Partner, Ex-VC",
		"active_line": {
			"text": "\"Evlat, hepsi aynı sunumu yapıyor. Soğukkanlı kal. Savunma yapma, merak et. 'Haklısın, orası zayıf' demek seni zayıf göstermez, dürüst gösterir. Şimdi nefes al — en zor soruya en kısa cevabı ver.\"",
			"speaker_tag": "Frank — Sayla",
			"is_monologue": false,
		},
		"choices": [
			{"id": "understood", "text": "Anladım. Savunmayı bırakıp veriye döneceğim."},
			{"id": "rehearse", "text": "Bana o en zor sorunun provasını yaptırır mısın?"},
			{"id": "why_now", "text": "Kısa ve net: neden şimdi, neden biz, neden sana inanmalı?"},
		],
		"beat_label": "",
		"can_withdraw": false,
	}
