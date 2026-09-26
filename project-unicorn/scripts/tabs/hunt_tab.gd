extends Control

# Yatırım (Series A Hunt) panel. Nested by FinanceTab as its "Yatırım" sub-page.
# Left: investor roster (5 cards incl. locked Tier-2) with per-vc_state badges + the
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
var _frank_line: String = ""   # set in _ready from HUNT_FRANK_LINE (tr() needs the node ready)
var _advisory_active: bool = false   # a phone note has taken the strip over (see _on_advisory)
# The seed strip. BUILT IN CODE and inserted above the columns rather than added to
# HuntTab.tscn: everything else on this page is already programmatic, a scene edit would
# put player-visible text into a .tscn (which loc_residue then has to whitelist), and the
# strip is entirely conditional — it is absent for most of a run.
var _seed_strip: VBoxContainer = null


func _ready() -> void:
	# The default advisory line is a KEY, resolved here rather than at declaration: tr() is a
	# node method and the initializer runs before the node exists. A live advisory from
	# mentor_advisory_changed still overwrites it (see _on_advisory).
	# {n} = tables already closed. The shipped line was a static "dört masa; üçü kapanırsa yol
	# biter" - four is the roster, three is the rule, and read as one sentence it was neither
	# true nor moving while vc_rejections went 0 → 1 → 2 → 3 underneath it.
	_frank_line = tr("HUNT_FRANK_LINE").format({"n": GameState.vc_rejections})
	_signals = [
		EventBus.sheet_granted, EventBus.sheet_expired, EventBus.callback_ready,
		EventBus.meeting_day, EventBus.day_advanced, EventBus.mrr_changed,
		EventBus.pitch_finished, EventBus.sheet_walked,
	EventBus.seed_door_opened, EventBus.seed_sheet_granted, EventBus.seed_round_closed,
	# phase_changed too: the seed door SHUTS on entering the Series A Hunt, and the
	# Series A roster stops being telegraphed-locked on the same tick.
	EventBus.phase_changed,
	]
	for sig in _signals:
		sig.connect(_on_changed)
	EventBus.mentor_advisory_changed.connect(_on_advisory)
	_build_seed_strip()
	_refresh()


func _build_seed_strip() -> void:
	var layout: Node = $Margin/Layout
	_seed_strip = VBoxContainer.new()
	_seed_strip.add_theme_constant_override("separation", 4)
	layout.add_child(_seed_strip)
	# Directly under the title bar and its rule, above the two columns.
	layout.move_child(_seed_strip, 2)


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_changed):
			sig.disconnect(_on_changed)
	if EventBus.mentor_advisory_changed.is_connected(_on_advisory):
		EventBus.mentor_advisory_changed.disconnect(_on_advisory)


func _on_changed(_a = null, _b = null) -> void:
	_refresh()

func _on_advisory(text: String) -> void:
	_advisory_active = true
	_frank_line = text
	_refresh()


func _refresh() -> void:
	# An advisory from the phone still overwrites this (see _on_advisory); when it has not,
	# re-read the strip so the closed count follows the hunt instead of freezing at _ready.
	if not _advisory_active:
		_frank_line = tr("HUNT_FRANK_LINE").format({"n": GameState.vc_rejections})
	_frank.text = _frank_line
	_refresh_seed()
	_refresh_roster()
	_refresh_offers()
	_refresh_pending()
	_refresh_counter()


# --- Seed rung (GDD v2 ch. 09 §3) ---

## Four exclusive arms, newest state first: the round is closed, an offer is waiting, the
## one meeting is spent, or the door is open. Anything else and the strip is not there.
func _refresh_seed() -> void:
	for c in _seed_strip.get_children():
		c.queue_free()
	_seed_strip.visible = false
	if not SeedRoundSystem.page_unlocked():
		return
	_seed_strip.visible = true
	_seed_strip.add_child(_label(tr("SEED_SECTION_TITLE"), C_INK, 14))

	if GameState.seed_lead != "":
		_seed_strip.add_child(_label(tr("SEED_DONE_LINE").format({
			"investor": _vc_name(GameState.seed_lead),
			"amount": Fmt.money_exact(GameState.run_seed_amount),
			"equity": Fmt.percent(GameState.run_seed_equity_pct, 0)}), C_DIM, 12))
		_seed_strip.add_child(_label(tr("SEED_EXPECT_LABEL"), C_SUB, 11))
		_seed_strip.add_child(_seed_expectation_line())
		return

	if GameState.seed_sheet != null:
		var sheet: TermSheet = GameState.seed_sheet
		_seed_strip.add_child(_label(tr("SEED_OFFER_LINE").format(
			{"investor": _vc_name(String(sheet.vc_id))}), C_INK, 12))
		_seed_strip.add_child(_label(tr("SEED_OFFER_TERMS").format(
			{"band": tr("SEED_BAND_" + String(sheet.band).to_upper())}), C_SUB, 11))
		var sit := Button.new()
		sit.text = tr("SEED_SIT_DOWN")
		sit.pressed.connect(_open_table.bind(String(sheet.vc_id)))
		# NO WALK BUTTON, and not by omission: refusing the round is ZOR MOD, so the row
		# that refuses it lives at the TABLE where it can be rendered locked with its
		# reason. A second refusal path here would be an unlocked door beside a locked one.
		_seed_strip.add_child(sit)
		return

	if GameState.seed_pitch_used:
		_seed_strip.add_child(_label(tr("SEED_PITCH_SPENT_LINE").format(
			{"investor": _vc_name(GameState.seed_lead)}), C_SUB, 11, true))
		return

	if not SeedRoundSystem.door_open():
		return
	_seed_strip.add_child(_label(tr("SEED_DOOR_LINE"), C_DIM, 11, true))
	_seed_strip.add_child(_label(tr("SEED_DOOR_HINT"), C_SUB, 11, true))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	for inv in InvestorRegistry.get_active():
		var vc_id: String = String(inv.get("id", ""))
		var b := Button.new()
		b.text = String(inv.get("display_name", ""))
		# The blocked reason, when there is one, on the surface that would otherwise offer a
		# button that quietly does nothing (no fake choices).
		var blocked: String = SeedRoundSystem.pitch_blocked_reason(vc_id)
		b.disabled = blocked != ""
		b.tooltip_text = tr(blocked) if blocked != "" else tr("SEED_PITCH_BUTTON")
		# CONFIRMED, because it cannot be taken back: one seed pitch per run, and the
		# fund chosen here is the fund. Same grammar as walking a table.
		b.pressed.connect(_confirm_seed_pitch.bind(vc_id))
		row.add_child(b)
	_seed_strip.add_child(row)


## The growth expectation, in one line (ruling 7). The threshold IS rendered here, unlike
## the door bar: the door is an appetite the player infers, but 10 % a month is a promise
## an investor made out loud, and a promise nobody states is not one.
func _seed_expectation_line() -> Label:
	var e: Dictionary = SeedRoundSystem.expectation()
	var state: int = int(e.get("state", 0))
	var avg: int = int(e.get("avg_pct", 0))
	var need: String = Fmt.percent(int(e.get("need_pct", 0)), 0)
	match state:
		SeedConstants.EXPECT_GRACE:
			return _label(tr("SEED_EXPECT_GRACE").format(
				{"days": int(e.get("grace_days_left", 0))}), C_SUB, 11, true)
		SeedConstants.EXPECT_ON_TRACK:
			return _label(tr("SEED_EXPECT_ON_TRACK").format(
				{"avg": Fmt.percent(avg, 0), "need": need}), UiTokens.positive(), 11, true)
		SeedConstants.EXPECT_STALLED:
			return _label(tr("SEED_EXPECT_STALLED").format(
				{"avg": Fmt.percent(avg, 0), "need": need}), UiTokens.negative(), 11, true)
	return _label(tr("SEED_EXPECT_UNKNOWN"), C_SUB, 11, true)


func _confirm_seed_pitch(vc_id: String) -> void:
	var reason: String = SeedRoundSystem.pitch_blocked_reason(vc_id)
	if reason != "":
		return
	EventBus.confirm_requested.emit({
		"title": tr("SEED_PITCH_CONFIRM_TITLE"),
		"body": tr("SEED_PITCH_CONFIRM_BODY").format({"investor": _vc_name(vc_id)}),
		"confirm_text": tr("SEED_PITCH_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": Callable(self, "_begin_seed_pitch").bind(vc_id),
	})


func _begin_seed_pitch(vc_id: String) -> void:
	SeedRoundSystem.begin_pitch(vc_id)
	_refresh()


# --- Roster ---

func _refresh_roster() -> void:
	for c in _roster.get_children():
		c.queue_free()
	var pivoted: bool = GameState.pivot_used
	for inv in InvestorRegistry.get_all():
		var card: Control = _build_roster_card(inv, pivoted)
		if pivoted:
			card.modulate = Color(1, 1, 1, 0.4)  # whole roster greys after pivot
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
		card.add_child(_label(tr("HUNT_LOCKED_SOON"), C_SUB, 11))
		return card

	# Archetype line + domain chip.
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 8)
	meta.add_child(UiFactory.make_pill(
		InvestorRegistry.domain_chip(String(inv.get("id", ""))), UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP))
	# Tabloda `archetype_key` durur, kelime render anında çözülür (investor_registry.gd:141-146).
	# Buradaki okuma o taşımadan geri kalmıştı: `inv["archetype_line"]` diye bir alan YOK, o
	# yüzden dört kartın da altına boş bir genişleyen Label çiziliyordu. Bir üstteki domain
	# chip'i zaten accessor'ı doğru kullanıyor; satır ona hizalandı.
	var arc := _label(InvestorRegistry.archetype_line(vc_id), C_DIM, 11, true)
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
	# TELEGRAPHED, NOT BLANK (ruling 11). Before the seed rung this page was unreachable
	# below phase 3, so the roster never had to say why it was inert. It is reachable in
	# Traction now, and a row of four funds with no button and no sentence reads as a bug.
	if GameState.phase < 3:
		return _label(tr("FIN_SUBTAB_LOCKED"), C_SUB, 11)
	if status in ["rejected", "expired", "walked", "signed", "offered", "pending_sheet"]:
		return null  # closed, or the offer lives in Teklifler — no roster action

	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 3)

	# Callback progress line.
	if status == "callback":
		row.add_child(_label(tr("HUNT_CONDITION").format({"condition": _callback_text(st.get("callback", {}))}), C_SUB, 11, true))

	# Request-meeting availability.
	var pending_here: bool = GameState.pending_meeting.get("vc_id", "") == vc_id
	if pending_here:
		row.add_child(_label(tr("HUNT_MEETING_SET"), C_DIM, 11))
		var moves: Control = _meeting_move_row()
		if moves != null:
			row.add_child(moves)
		row.add_child(_prep_row(vc_id))
	else:
		var btn := Button.new()
		btn.text = (tr("HUNT_REQUEST_AGAIN") if status == "callback" else tr("HUNT_REQUEST_MEETING")).format(
			{"n": PitchConstants.MEETING_LEAD_DAYS})
		# The system says why (no fake choices): the callback condition is the lock on a
		# callback fund, and it is already printed one line up, so the tooltip repeats it.
		var reason: String = VCPitchSystem.meeting_blocked_reason(vc_id)
		btn.disabled = reason != ""
		if reason != "":
			btn.tooltip_text = _meeting_block_text(reason, st)
		btn.pressed.connect(func() -> void:
			VCPitchSystem.request_meeting(vc_id)
			_refresh())
		row.add_child(btn)
	return row


## Cancel or move the booked meeting. Only before its day; each costs a little of that
## fund's conviction at its next meeting, and the buttons say how much.
func _meeting_move_row() -> Control:
	if not VCPitchSystem.can_move_meeting():
		return null
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	var move := Button.new()
	move.text = tr("HUNT_MEETING_RESCHEDULE").format({"n": PitchConstants.MEETING_LEAD_DAYS})
	move.tooltip_text = tr("HUNT_RESCHEDULE_TIP").format({"n": PitchConstants.MEETING_RESCHEDULE_PENALTY})
	move.pressed.connect(func() -> void:
		VCPitchSystem.reschedule_meeting()
		_refresh())
	box.add_child(move)
	var cancel := Button.new()
	cancel.text = tr("HUNT_MEETING_CANCEL")
	cancel.tooltip_text = tr("HUNT_CANCEL_TIP").format({"n": PitchConstants.MEETING_CANCEL_PENALTY})
	cancel.pressed.connect(func() -> void:
		VCPitchSystem.cancel_meeting()
		_refresh())
	box.add_child(cancel)
	return box


func _meeting_block_text(reason: String, st: Dictionary) -> String:
	match reason:
		"callback_unmet":
			return tr("HUNT_CONDITION").format({"condition": _callback_text(st.get("callback", {}))})
		"cancelled_today":
			return tr("HUNT_MEETING_CANCELLED_TODAY")
		"busy":
			return tr("HUNT_MEETING_BUSY")
	return ""


func _prep_row(vc_id: String) -> Control:
	# 3 focus buttons if prep is allowed; the block reason otherwise (no fake choices).
	if not GameState.prep.is_empty():
		return _label(tr("HUNT_PREP_RUNNING"), C_SUB, 11)
	var reason: String = VCPitchSystem.prep_blocked_reason(vc_id)
	if reason != "":
		return _label(tr("HUNT_PREP_REASON").format({"reason": reason}), C_SUB, 11)
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	# Üç kimlik, üç kelime — ve kelimeler CSV'den gelir. Buradaki liste bir zamanlar
	# ["rakamlar", "Rakamlar"] gibi çiftler taşıyordu: kimlik ve GÖMÜLÜ TÜRKÇE etiket yan
	# yana. Aynı dosyanın altında zaten _focus_label() vardı ve aynı üç kimliği doğru
	# çeviriyordu; yani İngilizce derlemede bu üç düğme Türkçe yazıyor, iki satır aşağıdaki
	# "Bekleyen" satırı aynı kimliği İngilizce yazıyordu. Tek kaynak: _focus_label.
	for focus_id in ["rakamlar", "hikaye", "prova"]:
		var b := Button.new()
		b.text = _focus_label(focus_id)
		b.pressed.connect(func() -> void:
			VCPitchSystem.start_prep(vc_id, focus_id)
			_refresh())
		box.add_child(b)
	return box


# --- Offers (Teklifler) ---

func _refresh_offers() -> void:
	for c in _offers.get_children():
		c.queue_free()
	var sheets: Array = GameState.active_sheets
	var queued: Array = []
	for inv in InvestorRegistry.get_active():
		if bool(GameState.vc_states.get(String(inv.id), {}).get("pending_sheet", false)):
			queued.append(String(inv.id))
	if VCPitchSystem.series_a_road_closed():
		# Every fund is closed and nothing is live: say it once, plainly, rather than an
		# empty-offers line that implies another meeting could still produce one.
		_offers.add_child(_label(tr("HUNT_ROAD_CLOSED"), C_DIM, 12, true))
	elif sheets.is_empty() and queued.is_empty():
		_offers.add_child(_label(tr("HUNT_NO_OFFERS"), C_SUB, 11))
	for sheet in sheets:
		_offers.add_child(_build_offer_card(sheet))
	# Empty-slot outline while under the cap.
	if sheets.size() < PitchConstants.MAX_SHEETS:
		var empty := _label(tr("HUNT_EMPTY_SLOT"), C_SUB, 11)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_offers.add_child(empty)
	# The third sheet waits for a slot, and the player can see it waiting.
	for vc_id in queued:
		_offers.add_child(_label(tr("HUNT_QUEUED_OFFER").format({"investor": _vc_name(vc_id),
			"n": PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS}), C_SUB, 11, true))


func _build_offer_card(sheet) -> Control:
	var inv: Dictionary = InvestorRegistry.get_investor(sheet.vc_id)
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 3)
	card.add_child(_label(String(inv.get("display_name", "")), C_INK, 13))
	var vc_id: String = String(sheet.vc_id)
	# An ESTIMATED range, never the number and never the board term - the table is where
	# the exact terms open up. The range is seeded per sheet, so it does not reroll.
	card.add_child(_label(tr("HUNT_TERMS").format({
		"valuation": VCPitchSystem.estimate_valuation_text(vc_id),
		"equity": VCPitchSystem.estimate_dilution_text(vc_id)}), C_DIM, 11, true))
	var due: bool = (sheet as TermSheet).is_decision_due(GameState.day)
	if due:
		# The window has closed; the decision card is up (or about to be). The same two
		# answers live here so the page never shows a sheet with nothing to do about it.
		card.add_child(_label(tr("HUNT_DECISION_DUE"), UiTokens.negative(), 11, true))
	else:
		# Plain information in business days, amber → red at the warning threshold.
		var days: int = (sheet as TermSheet).business_days_left(GameState.day)
		card.add_child(_label(tr("HUNT_VALIDITY").format({"n": days}),
			UiTokens.ACCENT_DEEP if days > PitchConstants.WARNING_DAYS else UiTokens.negative(), 11))
	# Actions.
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	var sit := Button.new()
	sit.text = tr("HUNT_SIT_DOWN")
	sit.pressed.connect(_open_table.bind(vc_id))
	actions.add_child(sit)
	var walk := Button.new()
	if due:
		walk.text = tr("VC_EV_DECISION_DECLINE")
		walk.pressed.connect(_decline_due.bind(vc_id))
	else:
		walk.text = tr("HUNT_WALK_AWAY")
		walk.pressed.connect(_confirm_walk.bind(vc_id))
	actions.add_child(walk)
	card.add_child(actions)
	return card


func _decline_due(vc_id: String) -> void:
	VCPitchSystem.decline_expired_sheet(vc_id)
	_refresh()


func _open_table(vc_id: String) -> void:
	# Open the real push-your-luck Term Sheet Table. main.gd mounts the scene (which
	# opens TermSheetTableSystem for this VC); İMZALA / MASADAN KALK resolve there.
	EventBus.term_table_requested.emit(vc_id)


func _confirm_walk(vc_id: String) -> void:
	EventBus.confirm_requested.emit({
		"title": tr("HUNT_WALK_CONFIRM_TITLE"),
		"body": tr("HUNT_WALK_CONFIRM_BODY"),
		"confirm_text": tr("HUNT_WALK_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
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
		_pending.add_child(_label(tr("HUNT_MEETING_PENDING").format({"vc": _vc_name(String(pm.get("vc_id", ""))), "n": maxi(d, 0)}), C_INK, 12))
		any = true
	var pr: Dictionary = GameState.prep
	if not pr.is_empty():
		var pd: int = int(pr.get("done_day", 0)) - GameState.day
		var focus_tr: String = _focus_label(String(pr.get("focus", "")))
		_pending.add_child(_label(tr("HUNT_PREP_PENDING").format({"focus": focus_tr,
			"when": tr("HUNT_PREP_READY") if pd <= 0 else tr("HUNT_DAYS").format({"n": pd})}), C_INK, 12))
		any = true
	if not any:
		_pending.add_child(_label(tr("HUNT_NONE_PENDING"), C_SUB, 11))


# --- Rejection counter / pivot ---

func _refresh_counter() -> void:
	if GameState.pivot_used:
		_counter.visible = true
		_counter.text = tr("HUNT_COUNTER_PIVOT")
	elif GameState.vc_rejections > 0:
		_counter.visible = true
		_counter.text = tr("HUNT_COUNTER_TABLES").format({"closed": GameState.vc_rejections,
			"total": EndingsSystem.CASCADE_TABLES})
	else:
		_counter.visible = false


# --- Helpers ---

func _status_badge(vc_id: String) -> Control:
	var status: String = String(GameState.vc_states.get(vc_id, {}).get("status", "open"))
	match status:
		"offered": return UiFactory.make_badge(tr("HUNT_BADGE_OFFERED"), &"accent")
		"pending_sheet": return UiFactory.make_badge(tr("HUNT_BADGE_PENDING_SHEET"), &"accent")
		"callback": return UiFactory.make_badge(tr("HUNT_BADGE_CALLBACK"), &"accent")
		"rejected": return UiFactory.make_badge(tr("HUNT_BADGE_REJECTED"), &"negative")
		"expired": return UiFactory.make_badge(tr("HUNT_BADGE_EXPIRED"), &"negative")
		"walked": return UiFactory.make_badge(tr("HUNT_BADGE_WALKED"), &"neutral")
		"signed": return UiFactory.make_badge(tr("HUNT_BADGE_SIGNED"), &"positive")
		_: return UiFactory.make_badge(tr("HUNT_BADGE_OPEN"), &"neutral")


func _callback_text(cb: Dictionary) -> String:
	match String(cb.get("type", "")):
		"mrr_growth": return tr("HUNT_CB_MRR").format({"target": Fmt.money(int(cb.get("target", 0))),
			"current": Fmt.money(GameState.mrr)})
		"bugs_under": return tr("HUNT_CB_BUGS").format({"n": int(cb.get("target", 0))})
		"first_engineer": return tr("HUNT_CB_FIRST_ENGINEER")
		"scandal_resolved": return tr("HUNT_CB_SCANDAL")
		_: return tr("HUNT_CB_NONE")


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


## Prep-focus label. The ids (rakamlar/hikaye/prova) stay ids; only the WORD localizes.
func _focus_label(focus_id: String) -> String:
	match focus_id:
		"rakamlar": return tr("HUNT_FOCUS_NUMBERS")
		"hikaye": return tr("HUNT_FOCUS_STORY")
		"prova": return tr("HUNT_FOCUS_REHEARSAL")
		_: return tr("HUNT_CB_NONE")
