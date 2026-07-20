class_name MeetingScene
extends Control

# Full-screen cinematic dialogue shell (Spec 5). A PURE VIEW: it renders a view_state
# dict and emits choice intents — nothing else. Reads no autoloads except UiTokens; all
# rules live in the future consumer (Spec 4's PitchSystem for VC pitches, later the B2B
# sales system). The same .tscn serves both because the view encodes no domain
# assumptions it never received — the reuse contract (§5).
#
# process_mode = ALWAYS (.tscn) so it stays interactive on the paused tree (ledger 6).
# Ledger 11: no default focus; number keys 1-4 and mouse clicks select; a blind
# Enter/Space on open does nothing.

signal choice_selected(id: String)
signal withdraw_requested()

const CHOICE_CARD := preload("res://scenes/ui/components/DialogueChoiceCard.tscn")

@onready var _room_fallback: ColorRect = $RoomFallback
@onready var _room_art: TextureRect = $RoomArt
@onready var _scrim: ColorRect = $Scrim
@onready var _stat_strip: PanelContainer = $StatStrip
@onready var _stat_label: Label = $StatStrip/StatLabel
@onready var _portrait: DialoguePortraitCard = $Column/Portrait
@onready var _name: Label = $Column/Body/Content/NameBlock/NameLabel
@onready var _role: Label = $Column/Body/Content/NameBlock/RoleLabel
@onready var _conviction: ConvictionTrack = $Column/Body/Content/Conviction
@onready var _monologue_wrap: MarginContainer = $Column/Body/Content/MonologueWrap
@onready var _monologue: Label = $Column/Body/Content/MonologueWrap/MonologueLabel
@onready var _quote_box: PanelContainer = $Column/Body/Content/QuoteBox
@onready var _quote: Label = $Column/Body/Content/QuoteBox/QuoteVBox/QuoteLabel
@onready var _tag: Label = $Column/Body/Content/QuoteBox/QuoteVBox/TagLabel
@onready var _choices_box: VBoxContainer = $Column/Body/Content/Choices
@onready var _beat: Label = $Column/Body/Content/Footer/BeatLabel
@onready var _withdraw: Button = $Column/Body/Content/Footer/WithdrawBtn

var _cards: Array[DialogueChoiceCard] = []


func _ready() -> void:
	# Colors from tokens (never inline in the .tscn) so the grep gate stays clean.
	_room_fallback.color = UiTokens.DIALOGUE_BG
	_scrim.color = UiTokens.SCRIM_ROOM
	_withdraw.focus_mode = Control.FOCUS_NONE          # ledger 11 — no keyboard focus target
	_withdraw.pressed.connect(_on_withdraw_pressed)
	# Simple fade-in on mount (anything richer is a later polish phase).
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)


func populate(view_state: Dictionary) -> void:
	_apply_room(String(view_state.get("background_path", "")))
	_portrait.set_portrait(
		String(view_state.get("portrait_path", "")),
		_initials(String(view_state.get("speaker_name", ""))))
	_name.text = UiTokens.tr_upper(String(view_state.get("speaker_name", "")))
	_role.text = UiTokens.tr_upper(String(view_state.get("speaker_role", "")))

	# İKNA — optional (FrankPopup and non-scored dialogues omit it → track hidden).
	if view_state.has("conviction"):
		var c: Dictionary = view_state.conviction
		_conviction.visible = true
		_conviction.set_value(int(c.get("value", 0)), c.get("zone_bounds", PitchConstants.ZONE_BOUNDS))
	else:
		_conviction.visible = false

	_apply_active_line(view_state.get("active_line", {}), String(view_state.get("monologue_text", "")))
	_build_choices(view_state.get("choices", []))

	_beat.text = UiTokens.tr_upper(String(view_state.get("beat_label", "")))
	_withdraw.visible = bool(view_state.get("can_withdraw", false))

	# Stat strip — optional, over the art (bottom-left).
	if view_state.has("stat_strip"):
		_stat_strip.visible = true
		_stat_label.text = String((view_state.stat_strip as Dictionary).get("left_text", ""))
	else:
		_stat_strip.visible = false


# --- rendering helpers ------------------------------------------------------

func _apply_room(path: String) -> void:
	# Covered-aspect fills the frame at any size; missing file → flat charcoal fallback.
	if path != "" and ResourceLoader.exists(path):
		var tex: Texture2D = load(path)
		if tex is Texture2D:
			_room_art.texture = tex
			return
	_room_art.texture = null
	if path != "":
		push_warning("[MeetingScene] room art missing, flat charcoal fallback: %s" % path)


func _apply_active_line(line: Dictionary, monologue_text: String) -> void:
	# Two registers (canon): a spoken line lives IN the amber-edged box with a speaker
	# tag; an interior-monologue line renders OUTSIDE the box — dimmer, italic, indented.
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


# --- input / signals --------------------------------------------------------

func _on_choice_selected(id: String) -> void:
	choice_selected.emit(id)


func _on_withdraw_pressed() -> void:
	withdraw_requested.emit()


func _input(event: InputEvent) -> void:
	# Deliberate number-key selection (1-4) — allowed by override §2.3. Enter/Space are
	# NOT bound, so a blind press does nothing.
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var idx := -1
	match (event as InputEventKey).keycode:
		KEY_1, KEY_KP_1: idx = 0
		KEY_2, KEY_KP_2: idx = 1
		KEY_3, KEY_KP_3: idx = 2
		KEY_4, KEY_KP_4: idx = 3
	if idx >= 0 and idx < _cards.size():
		get_viewport().set_input_as_handled()
		_cards[idx].select()


func _unhandled_input(event: InputEvent) -> void:
	# ESC withdraws only when withdrawal is offered; otherwise no keyboard escape.
	if event.is_action_pressed("ui_cancel") and _withdraw.visible:
		get_viewport().set_input_as_handled()
		withdraw_requested.emit()


# ============================================================================
# Debug fixtures (§6) — literal view_state dicts, no autoload reads. game_shell
# builds these and emits them through EventBus; main.gd mounts + populates.
# ============================================================================

static func debug_fixture_full() -> Dictionary:
	return {
		"background_path": "res://assets/art/rooms/room_anchor.webp",
		"portrait_path": "res://assets/art/investors/portrait_anchor.webp",
		"speaker_name": "Anchor Capital",
		"speaker_role": "Kıdemli Ortak",
		"active_line": {
			"text": "\"Dinle. Bize hikaye değil, matematik lazım. Son çeyrekte burn rate %31 artmış ama net retention aynı kalmış. Bu tabloyla Seri A'da masada kalamazsın.\"",
			"speaker_tag": "Anchor — Canlı",
			"is_monologue": false,
		},
		"monologue_text": "Gözleri rakamlarda, sende değil — bir kurucu değil, bir tablo görmek istiyor.",
		"conviction": {"value": 52, "zone_bounds": PitchConstants.ZONE_BOUNDS},
		"choices": [
			{"id": "retention", "text": "Retention stabil çünkü enterprise tarafa pivot ettik; burn artışı o geçişin yatırımı.", "odds_text": "Zorlu — %58", "marked": true, "marked_text": "PROVA EDİLDİ"},
			{"id": "plan", "text": "Haklısınız. Önümüzdeki 90 günde burn'ü %22 düşürecek planı devreye aldık.", "odds_text": "Güvenli — %81", "caption": "Düşük risk, düşük getiri."},
			{"id": "cohort", "text": "Rakamlar tek başına hikayeyi anlatmıyor. Size cohort detayını açayım.", "odds_text": "Riskli — %34", "caption": "Blöf sezilirse İKNA çöker.", "caption_danger": true},
			{"id": "walk", "text": "Bu şartlarda anlaşamayız. (bu tur kapalı)", "disabled": true},
		],
		"beat_label": "Sorgu · 3/4",
		"can_withdraw": true,
		"stat_strip": {"left_text": "Kasa: $8.2K · Runway: 19 gün · Gün 141"},
	}


static func debug_fixture_long() -> Dictionary:
	# Extreme-length strings — text-safety proof (verification 6). Nothing may overflow.
	return {
		"background_path": "res://assets/art/rooms/room_meridian.webp",
		"portrait_path": "res://assets/art/investors/portrait_meridian.webp",
		"speaker_name": "Meridian Growth Partners International",
		"speaker_role": "Büyümeden Sorumlu Yönetici Ortak ve Kurucu",
		"active_line": {
			"text": "\"Benim işim ölçek, senin işin ise bana bu çeyrekte hangi tek metriği ikiye katlayacağını, hangi kaldıraçla, hangi ekiple, hangi bütçeyle ve en önemlisi hangi kanıtla yapacağını tek nefeste, hikâye anlatmadan, doğrudan rakamla söylemen — çünkü whiteboard dolu, roadmap dolu, ama gerçekten kaldıraç olan tek bir şey var ve onu bulamayan her kurucu aynı yerde tıkanıp kalıyor.\"",
			"speaker_tag": "Meridian — Canlı",
			"is_monologue": false,
		},
		"monologue_text": "Bu çok uzun bir iç ses satırı: taşma testi için bilinçli olarak uzatılmış, kutunun dışında, daha soluk ve girintili render edilmeli ve hiçbir koşulda kolonun kenarından taşmamalı.",
		"conviction": {"value": 88, "zone_bounds": PitchConstants.ZONE_BOUNDS},
		"choices": [
			{"id": "pipeline", "text": "Qualified pipeline. Outbound'ı otomatikleştirdik, toplantı kapasitesini üçe katladık ve dönüşüm oranını çeyrek boyunca istikrarlı biçimde yukarı taşıdık.", "odds_text": "Zorlu — %61", "caption": "Uzun caption taşma testi: bu satır da bilinçli olarak uzun tutuldu ki kart içinde sarılsın, taşmasın.", "marked": true},
			{"id": "activation", "text": "Aktivasyon. İlk on dakikayı yeniden yazdık — 'aha' anı artık %40 daha erken geliyor.", "odds_text": "Güvenli — %79"},
			{"id": "expansion", "text": "Expansion revenue: mevcut hesaplara ikinci ürün modülünü açıyoruz.", "odds_text": "Riskli — %36", "caption": "Kanıtlanmadı — sezilirse geri teper.", "caption_danger": true},
		],
		"beat_label": "Kapanış · 4/4",
		"can_withdraw": false,
		"stat_strip": {"left_text": "Kasa: $1.24M · Runway: 402 gün · Gün 212 · MRR: $1.2M"},
	}
