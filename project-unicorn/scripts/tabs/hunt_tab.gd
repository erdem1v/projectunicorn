extends Control

# Yatırım (Series A Hunt) panel — Spec 4 §4. Nested by FinanceTab as its "Yatırım" sub-page
# (Spec 6 §7 relocation). Left: investor roster (5 cards incl. locked Tier-2) with per-vc_state badges + the
# schedule/prep actions. Right: Teklifler (active sheets + validity countdowns + the
# placeholder table modal), Bekleyen (pending meeting/prep), Frank strip, rejection counter.
# Humble UI: reads VCPitchSystem / InvestorRegistry / GameState, calls the system for
# actions (SalesTab pattern), rebuilds on the VC EventBus signals. Renders on the light body.

const C_INK := UiTokens.INK
const C_DIM := UiTokens.INK_MUTED
const C_SUB := UiTokens.INK_DIM

@onready var _frank: Label = $Margin/Layout/TitleBar/FrankLabel
@onready var _roster: VBoxContainer = $Margin/Layout/Columns/RosterPanel/RVBox/RosterScroll/RosterList
@onready var _offers: VBoxContainer = $Margin/Layout/Columns/RightCol/OffersPanel/OVBox/OffersList
@onready var _pending: VBoxContainer = $Margin/Layout/Columns/RightCol/PendingPanel/PVBox/PendingList
@onready var _counter: Label = $Margin/Layout/Columns/RightCol/CounterLabel

var _signals: Array = []
var _frank_line: String = "Av açık. Dört masa; üçü kapanırsa yol biter."


func _ready() -> void:
	_signals = [
		EventBus.sheet_granted, EventBus.sheet_expired, EventBus.callback_ready,
		EventBus.meeting_day, EventBus.day_advanced, EventBus.mrr_changed,
		EventBus.pitch_finished, EventBus.sheet_walked,
	]
	for sig in _signals:
		sig.connect(_on_changed)
	EventBus.mentor_advisory_changed.connect(_on_advisory)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_changed):
			sig.disconnect(_on_changed)
	if EventBus.mentor_advisory_changed.is_connected(_on_advisory):
		EventBus.mentor_advisory_changed.disconnect(_on_advisory)


func _on_changed(_a = null, _b = null) -> void:
	_refresh()

func _on_advisory(text: String) -> void:
	_frank_line = text
	_refresh()


func _refresh() -> void:
	_frank.text = _frank_line
	_refresh_roster()
	_refresh_offers()
	_refresh_pending()
	_refresh_counter()


# --- Roster ---

func _refresh_roster() -> void:
	for c in _roster.get_children():
		c.queue_free()
	var pivoted: bool = GameState.pivot_used
	for inv in InvestorRegistry.get_all():
		var card: Control = _build_roster_card(inv, pivoted)
		if pivoted:
			card.modulate = Color(1, 1, 1, 0.4)  # ledger 18 — whole roster greys after pivot
		_roster.add_child(card)


func _build_roster_card(inv: Dictionary, pivoted: bool) -> Control:
	var vc_id: String = String(inv.get("id", ""))
	var locked: bool = inv.get("locked", false)
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 3)

	# Header: name + status badge.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	var name_l := _label(String(inv.get("display_name", "")), C_INK, 14)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_l)
	if not locked:
		head.add_child(_status_badge(vc_id))
	card.add_child(head)

	if locked:
		card.add_child(_label("Yakında", C_SUB, 11))
		return card

	# Archetype line + domain chip.
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 8)
	meta.add_child(UiFactory.make_pill(String(inv.get("domain_chip", "")), UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP))
	var arc := _label(String(inv.get("archetype_line", "")), C_DIM, 11, true)
	arc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.add_child(arc)
	card.add_child(meta)

	if not pivoted:
		var actions: Control = _build_roster_actions(vc_id)
		if actions != null:
			card.add_child(actions)
	return card


func _build_roster_actions(vc_id: String) -> Control:
	var st: Dictionary = GameState.vc_states.get(vc_id, {})
	var status: String = String(st.get("status", "open"))
	if status in ["rejected", "expired", "walked", "signed", "offered", "pending_sheet"]:
		return null  # closed, or the offer lives in Teklifler — no roster action

	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 3)

	# Callback progress line.
	if status == "callback":
		row.add_child(_label("Koşul: %s" % _callback_text(st.get("callback", {})), C_SUB, 11, true))

	# Request-meeting availability.
	var pending_here: bool = GameState.pending_meeting.get("vc_id", "") == vc_id
	if pending_here:
		row.add_child(_label("Toplantı ayarlandı.", C_DIM, 11))
		row.add_child(_prep_row(vc_id))
	else:
		var btn := Button.new()
		btn.text = ("Tekrar iste (~%d gün)" if status == "callback" else "Toplantı iste (~%d gün)") % PitchConstants.MEETING_LEAD_DAYS
		var blocked: bool = not GameState.pending_meeting.is_empty()
		btn.disabled = blocked
		if blocked:
			btn.tooltip_text = "Başka bir toplantı bekliyor"
		btn.pressed.connect(func() -> void:
			VCPitchSystem.request_meeting(vc_id)
			_refresh())
		row.add_child(btn)
	return row


func _prep_row(vc_id: String) -> Control:
	# 3 focus buttons if prep is allowed; the block reason otherwise (no fake choices).
	if not GameState.prep.is_empty():
		return _label("Hazırlık sürüyor.", C_SUB, 11)
	var reason: String = VCPitchSystem.prep_blocked_reason(vc_id)
	if reason != "":
		return _label("Hazırlık: %s" % reason, C_SUB, 11)
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	for f in [["rakamlar", "Rakamlar"], ["hikaye", "Hikâye"], ["prova", "Prova"]]:
		var b := Button.new()
		b.text = f[1]
		b.pressed.connect(func() -> void:
			VCPitchSystem.start_prep(vc_id, f[0])
			_refresh())
		box.add_child(b)
	return box


# --- Offers (Teklifler) ---

func _refresh_offers() -> void:
	for c in _offers.get_children():
		c.queue_free()
	var sheets: Array = GameState.active_sheets
	if sheets.is_empty():
		_offers.add_child(_label("Henüz teklif yok.", C_SUB, 11))
	for sheet in sheets:
		_offers.add_child(_build_offer_card(sheet))
	# Empty-slot outline while under the cap.
	if sheets.size() < PitchConstants.MAX_SHEETS:
		var empty := _label("— boş slot —", C_SUB, 11)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_offers.add_child(empty)


func _build_offer_card(sheet) -> Control:
	var inv: Dictionary = InvestorRegistry.get_investor(sheet.vc_id)
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 3)
	card.add_child(_label(String(inv.get("display_name", "")), C_INK, 13))
	# Terms preview (mono-ish via RowMeta) + validity countdown, amber → red ≤3.
	var t: Dictionary = sheet.term_bands
	card.add_child(_label("Değerleme: %s · Seyrelme: %s · Board: %s" % [t.get("valuation", "—"), t.get("dilution", "—"), t.get("board", "—")], C_DIM, 11, true))
	var days: int = sheet.days_left(GameState.day)
	var dl := _label("Geçerlilik: %d gün" % days, UiTokens.ACCENT_DEEP if days > PitchConstants.WARNING_DAYS else UiTokens.NEGATIVE, 11)
	card.add_child(dl)
	# Actions.
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	var sit := Button.new()
	sit.text = "Masaya otur"
	sit.pressed.connect(_open_table.bind(String(sheet.vc_id)))
	actions.add_child(sit)
	var walk := Button.new()
	walk.text = "Masadan kalk"
	walk.pressed.connect(_confirm_walk.bind(String(sheet.vc_id)))
	actions.add_child(walk)
	card.add_child(actions)
	return card


func _open_table(vc_id: String) -> void:
	# Spec 6 — open the real push-your-luck Term Sheet Table. main.gd mounts the scene (which
	# opens TermSheetTableSystem for this VC); İMZALA / MASADAN KALK resolve there.
	EventBus.term_table_requested.emit(vc_id)


func _confirm_walk(vc_id: String) -> void:
	EventBus.confirm_requested.emit({
		"title": "Masadan kalkılsın mı?",
		"body": "Bu teklif yanar ve bir kapanan masa daha sayılır (+1 ret). Diğer teklifler durur.",
		"confirm_text": "Kalk",
		"cancel_text": "Vazgeç",
		"on_confirm": Callable(self, "_walk").bind(vc_id),
	})


func _walk(vc_id: String) -> void:
	VCPitchSystem.walk_table(vc_id)
	_refresh()


# --- Pending (Bekleyen) ---

func _refresh_pending() -> void:
	for c in _pending.get_children():
		c.queue_free()
	var any := false
	var pm: Dictionary = GameState.pending_meeting
	if not pm.is_empty():
		var d: int = int(pm.get("day", 0)) - GameState.day
		_pending.add_child(_label("Toplantı — %s · %d gün" % [_vc_name(String(pm.get("vc_id", ""))), maxi(d, 0)], C_INK, 12))
		any = true
	var pr: Dictionary = GameState.prep
	if not pr.is_empty():
		var pd: int = int(pr.get("done_day", 0)) - GameState.day
		var focus_tr: String = {"rakamlar": "Rakamlar", "hikaye": "Hikâye", "prova": "Prova"}.get(String(pr.get("focus", "")), "—")
		_pending.add_child(_label("Hazırlık — %s · %s" % [focus_tr, ("hazır" if pd <= 0 else "%d gün" % pd)], C_INK, 12))
		any = true
	if not any:
		_pending.add_child(_label("Bekleyen yok.", C_SUB, 11))


# --- Rejection counter / pivot ---

func _refresh_counter() -> void:
	if GameState.pivot_used:
		_counter.visible = true
		_counter.text = "Pivot — bootstrap yolu"
	elif GameState.vc_rejections > 0:
		_counter.visible = true
		_counter.text = "Kapanan masa: %d/%d" % [GameState.vc_rejections, PitchConstants.CASCADE_TABLES]
	else:
		_counter.visible = false


# --- Helpers ---

func _status_badge(vc_id: String) -> Control:
	var status: String = String(GameState.vc_states.get(vc_id, {}).get("status", "open"))
	match status:
		"offered": return UiFactory.make_badge("Teklif var", &"accent")
		"pending_sheet": return UiFactory.make_badge("Teklif bekliyor", &"accent")
		"callback": return UiFactory.make_badge("Callback", &"accent")
		"rejected": return UiFactory.make_badge("Reddetti", &"negative")
		"expired": return UiFactory.make_badge("Süresi doldu", &"negative")
		"walked": return UiFactory.make_badge("Masadan kalktın", &"neutral")
		"signed": return UiFactory.make_badge("İmzalandı", &"positive")
		_: return UiFactory.make_badge("Açık", &"neutral")


func _callback_text(cb: Dictionary) -> String:
	match String(cb.get("type", "")):
		"mrr_growth": return "MRR %s (%s/%s)" % [UiTokens.format_money(int(cb.get("target", 0))), UiTokens.format_money(GameState.mrr), UiTokens.format_money(int(cb.get("target", 0)))]
		"bugs_under": return "Aktif bug < %d" % int(cb.get("target", 0))
		"first_engineer": return "İlk mühendisi işe al"
		"scandal_resolved": return "Skandalı çöz"
		_: return "—"


func _vc_name(vc_id: String) -> String:
	return String(InvestorRegistry.get_investor(vc_id).get("display_name", vc_id))


func _label(content: String, color: Color, fsize: int, do_wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = content
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", fsize)
	if do_wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
