extends Control

# Yatırım (Series A Hunt) panel. Nested by FinanceTab as its "Yatırım" sub-page.
# Top: Frank strip in the title bar, the seed strip under it. Left: investor roster (5 cards
# incl. locked Tier-2) with per-vc_state badges + the schedule/prep actions. Right: Teklifler
# (active sheets + validity countdowns + the way into the Term Sheet Table), Bekleyen
# (pending meeting/prep), rejection counter.
# Humble UI: reads VCPitchSystem / InvestorRegistry / GameState, calls the system for
# actions (SalesTab pattern), rebuilds on the VC EventBus signals. Renders on the light body.

## Prep focus ids → their words. The ids stay ids; only the WORD localizes.
const FOCUS_KEYS := {"rakamlar": "HUNT_FOCUS_NUMBERS", "hikaye": "HUNT_FOCUS_STORY", "prova": "HUNT_FOCUS_REHEARSAL"}

@onready var _frank: Label = $Margin/Layout/TitleBar/FrankLabel
@onready var _roster: VBoxContainer = $Margin/Layout/Columns/RosterPanel/RVBox/RosterScroll/RosterList
@onready var _offers: VBoxContainer = $Margin/Layout/Columns/RightCol/OffersPanel/OVBox/OffersList
@onready var _pending: VBoxContainer = $Margin/Layout/Columns/RightCol/PendingPanel/PVBox/PendingList
@onready var _counter: Label = $Margin/Layout/Columns/RightCol/CounterLabel

var _signals: Array = []
var _advisory_active: bool = false   # a phone note has taken the strip over (see _on_advisory)
# The seed strip. BUILT IN CODE and inserted above the columns rather than added to
# HuntTab.tscn: everything else on this page is already programmatic, and the strip is
# entirely conditional — it is absent for most of a run.
var _seed_strip: VBoxContainer = null


func _ready() -> void:
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
	_seed_strip = VBoxContainer.new()
	_seed_strip.add_theme_constant_override("separation", 4)
	$Margin/Layout.add_child(_seed_strip)
	$Margin/Layout.move_child(_seed_strip, 2)   # under the title bar and its rule, above the columns
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_changed):
			sig.disconnect(_on_changed)
	if EventBus.mentor_advisory_changed.is_connected(_on_advisory):
		EventBus.mentor_advisory_changed.disconnect(_on_advisory)


func _on_changed(_arg = null) -> void:
	_refresh()


func _on_advisory(text: String) -> void:
	_advisory_active = true
	_frank.text = text
	_refresh()


func _refresh() -> void:
	# Once a phone advisory has taken the strip it keeps it; until then the line is re-read on
	# every refresh so {n} (tables already closed) follows vc_rejections.
	if not _advisory_active:
		_frank.text = tr("HUNT_FRANK_LINE").format({"n": GameState.vc_rejections})
	for box in [_seed_strip, _roster, _offers, _pending]:
		for c in box.get_children():
			c.queue_free()
	_refresh_seed()
	_refresh_roster()
	_refresh_offers()
	_refresh_pending()
	_refresh_counter()


# --- Seed rung (GDD v2 ch. 09 §3) ---

## Four exclusive arms, newest state first: the round is closed, an offer is waiting, the
## one meeting is spent, or the door is open. Anything else and the strip is not there.
func _refresh_seed() -> void:
	_seed_strip.visible = SeedRoundSystem.page_unlocked() and (GameState.seed_lead != ""
		or GameState.seed_sheet != null or GameState.seed_pitch_used or SeedRoundSystem.door_open())
	if not _seed_strip.visible:
		return
	_seed_strip.add_child(_label(tr("SEED_SECTION_TITLE"), UiTokens.INK, 14))

	if GameState.seed_lead != "":
		_seed_strip.add_child(_label(tr("SEED_DONE_LINE").format({
			"investor": _vc_name(GameState.seed_lead),
			"amount": Fmt.money_exact(GameState.run_seed_amount),
			"equity": Fmt.percent(GameState.run_seed_equity_pct, 0)}), UiTokens.INK_MUTED, 12))
		_seed_strip.add_child(_label(tr("SEED_EXPECT_LABEL"), UiTokens.INK_DIM, 11))
		_seed_strip.add_child(_seed_expectation_line())
		return

	var sheet: TermSheet = GameState.seed_sheet
	if sheet != null:
		_seed_strip.add_child(_label(tr("SEED_OFFER_LINE").format(
			{"investor": _vc_name(sheet.vc_id)}), UiTokens.INK, 12))
		_seed_strip.add_child(_label(tr("SEED_OFFER_TERMS").format(
			{"band": tr("SEED_BAND_" + sheet.band.to_upper())}), UiTokens.INK_DIM, 11))
		# NO WALK BUTTON, and not by omission: refusing the round is ZOR MOD, so the row
		# that refuses it lives at the TABLE where it can be rendered locked with its
		# reason. A second refusal path here would be an unlocked door beside a locked one.
		_seed_strip.add_child(_button(tr("SEED_SIT_DOWN"), EventBus.term_table_requested.emit.bind(sheet.vc_id)))
		return

	if GameState.seed_pitch_used:
		_seed_strip.add_child(_label(tr("SEED_PITCH_SPENT_LINE").format(
			{"investor": _vc_name(GameState.seed_lead)}), UiTokens.INK_DIM, 11, true))
		return

	_seed_strip.add_child(_label(tr("SEED_DOOR_LINE"), UiTokens.INK_MUTED, 11, true))
	_seed_strip.add_child(_label(tr("SEED_DOOR_HINT"), UiTokens.INK_DIM, 11, true))
	var row := _box(HBoxContainer.new(), 6)
	for inv in InvestorRegistry.get_active():
		var vc_id: String = String(inv.get("id", ""))
		# The blocked reason, when there is one, on the surface that would otherwise offer a
		# button that quietly does nothing (no fake choices).
		var blocked: String = SeedRoundSystem.pitch_blocked_reason(vc_id)
		# CONFIRMED, because it cannot be taken back: one seed pitch per run, and the
		# fund chosen here is the fund. Same grammar as walking a table.
		var b := _button(String(inv.get("display_name", "")), _confirm_seed_pitch.bind(vc_id),
			tr(blocked) if blocked != "" else tr("SEED_PITCH_BUTTON"))
		b.disabled = blocked != ""
		row.add_child(b)
	_seed_strip.add_child(row)


## The growth expectation, in one line. The threshold IS rendered here, unlike
## the door bar: the door is an appetite the player infers, but 10 % a month is a promise
## an investor made out loud, and a promise nobody states is not one.
func _seed_expectation_line() -> Label:
	var e: Dictionary = SeedRoundSystem.expectation()
	var args := {"days": e.grace_days_left, "avg": Fmt.percent(int(e.avg_pct), 0),
		"need": Fmt.percent(int(e.need_pct), 0)}
	match int(e.state):
		SeedConstants.EXPECT_GRACE:
			return _label(tr("SEED_EXPECT_GRACE").format(args), UiTokens.INK_DIM, 11, true)
		SeedConstants.EXPECT_ON_TRACK:
			return _label(tr("SEED_EXPECT_ON_TRACK").format(args), UiTokens.positive(), 11, true)
		SeedConstants.EXPECT_STALLED:
			return _label(tr("SEED_EXPECT_STALLED").format(args), UiTokens.negative(), 11, true)
	return _label(tr("SEED_EXPECT_UNKNOWN"), UiTokens.INK_DIM, 11, true)


func _confirm_seed_pitch(vc_id: String) -> void:
	if SeedRoundSystem.pitch_blocked_reason(vc_id) != "":
		return
	EventBus.confirm_requested.emit({
		"title": tr("SEED_PITCH_CONFIRM_TITLE"),
		"body": tr("SEED_PITCH_CONFIRM_BODY").format({"investor": _vc_name(vc_id)}),
		"confirm_text": tr("SEED_PITCH_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _act.bind(SeedRoundSystem.begin_pitch.bind(vc_id)),
	})


# --- Roster ---

func _refresh_roster() -> void:
	for inv in InvestorRegistry.get_all():
		var card: Control = _build_roster_card(inv)
		if GameState.pivot_used:
			card.modulate = Color(1, 1, 1, 0.4)
		_roster.add_child(card)


func _build_roster_card(inv: Dictionary) -> Control:
	var vc_id: String = String(inv.get("id", ""))
	var locked: bool = inv.get("locked", false)
	var card := _box(VBoxContainer.new(), 3)

	var head := _box(HBoxContainer.new(), 8)
	var name_l := _label(String(inv.get("display_name", "")), UiTokens.INK, 14)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_l)
	if not locked:
		head.add_child(_status_badge(vc_id))
	card.add_child(head)

	if locked:
		card.add_child(_label(tr("HUNT_LOCKED_SOON"), UiTokens.INK_DIM, 11))
		return card

	var meta := _box(HBoxContainer.new(), 8)
	meta.add_child(UiFactory.make_pill(InvestorRegistry.domain_chip(vc_id), UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP))
	var arc := _label(InvestorRegistry.archetype_line(vc_id), UiTokens.INK_MUTED, 11, true)
	arc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.add_child(arc)
	card.add_child(meta)

	if not GameState.pivot_used:
		var actions: Control = _build_roster_actions(vc_id)
		if actions != null:
			card.add_child(actions)
	return card


func _build_roster_actions(vc_id: String) -> Control:
	# TELEGRAPHED, NOT BLANK: the page is reachable in Traction once the seed door has opened,
	# and a row of four funds with no button and no sentence reads as a bug.
	if GameState.phase < 3:
		return _label(tr("FIN_SUBTAB_LOCKED"), UiTokens.INK_DIM, 11)
	var reason: String = VCPitchSystem.meeting_blocked_reason(vc_id)
	if reason == "closed":
		return null  # closed, or the offer lives in Teklifler — no roster action

	var st: Dictionary = GameState.vc_states.get(vc_id, {})
	var callback: bool = st.get("status", "open") == "callback"
	var condition: String = tr("HUNT_CONDITION").format({"condition": _callback_text(st.get("callback", {}))})
	var row := _box(VBoxContainer.new(), 3)
	if callback:
		row.add_child(_label(condition, UiTokens.INK_DIM, 11, true))

	if GameState.pending_meeting.get("vc_id", "") == vc_id:
		row.add_child(_label(tr("HUNT_MEETING_SET"), UiTokens.INK_MUTED, 11))
		if VCPitchSystem.can_move_meeting():
			row.add_child(_meeting_move_row())
		row.add_child(_prep_row(vc_id))
		return row

	var text: String = (tr("HUNT_REQUEST_AGAIN") if callback else tr("HUNT_REQUEST_MEETING")).format(
		{"n": PitchConstants.MEETING_LEAD_DAYS})
	# The system says why (no fake choices): the callback condition is the lock on a
	# callback fund, and it is already printed one line up, so the tooltip repeats it.
	var why: String = {"callback_unmet": condition, "cancelled_today": tr("HUNT_MEETING_CANCELLED_TODAY"),
		"busy": tr("HUNT_MEETING_BUSY")}.get(reason, "")
	var btn := _button(text, _act.bind(VCPitchSystem.request_meeting.bind(vc_id)), why)
	btn.disabled = reason != ""
	row.add_child(btn)
	return row


## Cancel or move the booked meeting. Only before its day; each costs a little of that
## fund's conviction at its next meeting, and the buttons say how much.
func _meeting_move_row() -> Control:
	var box := _box(HBoxContainer.new(), 4)
	box.add_child(_button(tr("HUNT_MEETING_RESCHEDULE").format({"n": PitchConstants.MEETING_LEAD_DAYS}),
		_act.bind(VCPitchSystem.reschedule_meeting),
		tr("HUNT_RESCHEDULE_TIP").format({"n": PitchConstants.MEETING_RESCHEDULE_PENALTY})))
	box.add_child(_button(tr("HUNT_MEETING_CANCEL"), _act.bind(VCPitchSystem.cancel_meeting),
		tr("HUNT_CANCEL_TIP").format({"n": PitchConstants.MEETING_CANCEL_PENALTY})))
	return box


func _prep_row(vc_id: String) -> Control:
	# 3 focus buttons if prep is allowed; the block reason otherwise (no fake choices).
	if not GameState.prep.is_empty():
		return _label(tr("HUNT_PREP_RUNNING"), UiTokens.INK_DIM, 11)
	var reason: String = VCPitchSystem.prep_blocked_reason(vc_id)
	if reason != "":
		return _label(tr("HUNT_PREP_REASON").format({"reason": reason}), UiTokens.INK_DIM, 11)
	var box := _box(HBoxContainer.new(), 4)
	for focus_id in FOCUS_KEYS:
		box.add_child(_button(tr(FOCUS_KEYS[focus_id]), _act.bind(VCPitchSystem.start_prep.bind(vc_id, focus_id))))
	return box


# --- Offers (Teklifler) ---

func _refresh_offers() -> void:
	var sheets: Array = GameState.active_sheets
	var queued: Array = []
	for inv in InvestorRegistry.get_active():
		if bool(GameState.vc_states.get(String(inv.id), {}).get("pending_sheet", false)):
			queued.append(String(inv.id))
	if VCPitchSystem.series_a_road_closed():
		# Every fund is closed and nothing is live: say it once, plainly, rather than an
		# empty-offers line that implies another meeting could still produce one.
		_offers.add_child(_label(tr("HUNT_ROAD_CLOSED"), UiTokens.INK_MUTED, 12, true))
	elif sheets.is_empty() and queued.is_empty():
		_offers.add_child(_label(tr("HUNT_NO_OFFERS"), UiTokens.INK_DIM, 11))
	for sheet in sheets:
		_offers.add_child(_build_offer_card(sheet))
	if sheets.size() < PitchConstants.MAX_SHEETS:
		var empty := _label(tr("HUNT_EMPTY_SLOT"), UiTokens.INK_DIM, 11)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_offers.add_child(empty)
	# The third sheet waits for a slot, and the player can see it waiting.
	for vc_id in queued:
		_offers.add_child(_label(tr("HUNT_QUEUED_OFFER").format({"investor": _vc_name(vc_id),
			"n": PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS}), UiTokens.INK_DIM, 11, true))


func _build_offer_card(sheet: TermSheet) -> Control:
	var vc_id: String = sheet.vc_id
	var card := _box(VBoxContainer.new(), 3)
	card.add_child(_label(_vc_name(vc_id), UiTokens.INK, 13))
	# An ESTIMATED range, never the number and never the board term - the table is where
	# the exact terms open up. The range is seeded per sheet, so it does not reroll.
	card.add_child(_label(tr("HUNT_TERMS").format({
		"valuation": VCPitchSystem.estimate_valuation_text(vc_id),
		"equity": VCPitchSystem.estimate_dilution_text(vc_id)}), UiTokens.INK_MUTED, 11, true))
	var due: bool = sheet.is_decision_due(GameState.day)
	if due:
		# The window has closed; the decision card is up (or about to be). The same two
		# answers live here so the page never shows a sheet with nothing to do about it.
		card.add_child(_label(tr("HUNT_DECISION_DUE"), UiTokens.negative(), 11, true))
	else:
		# Plain information in business days, amber → red at the warning threshold.
		var days: int = sheet.business_days_left(GameState.day)
		card.add_child(_label(tr("HUNT_VALIDITY").format({"n": days}),
			UiTokens.ACCENT_DEEP if days > PitchConstants.WARNING_DAYS else UiTokens.negative(), 11))
	var actions := _box(HBoxContainer.new(), 6)
	actions.add_child(_button(tr("HUNT_SIT_DOWN"), EventBus.term_table_requested.emit.bind(vc_id)))
	if due:
		actions.add_child(_button(tr("VC_EV_DECISION_DECLINE"),
			_act.bind(VCPitchSystem.decline_expired_sheet.bind(vc_id))))
	else:
		actions.add_child(_button(tr("HUNT_WALK_AWAY"), _confirm_walk.bind(vc_id)))
	card.add_child(actions)
	return card


func _confirm_walk(vc_id: String) -> void:
	EventBus.confirm_requested.emit({
		"title": tr("HUNT_WALK_CONFIRM_TITLE"),
		"body": tr("HUNT_WALK_CONFIRM_BODY"),
		"confirm_text": tr("HUNT_WALK_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _act.bind(VCPitchSystem.walk_table.bind(vc_id)),
	})


# --- Pending (Bekleyen) ---

func _refresh_pending() -> void:
	var pm: Dictionary = GameState.pending_meeting
	var pr: Dictionary = GameState.prep
	if not pm.is_empty():
		_pending.add_child(_label(tr("HUNT_MEETING_PENDING").format({"vc": _vc_name(String(pm.get("vc_id", ""))),
			"n": maxi(int(pm.get("day", 0)) - GameState.day, 0)}), UiTokens.INK, 12))
	if not pr.is_empty():
		var pd: int = int(pr.get("done_day", 0)) - GameState.day
		_pending.add_child(_label(tr("HUNT_PREP_PENDING").format({
			"focus": tr(FOCUS_KEYS.get(String(pr.get("focus", "")), "HUNT_CB_NONE")),
			"when": tr("HUNT_PREP_READY") if pd <= 0 else tr("HUNT_DAYS").format({"n": pd})}), UiTokens.INK, 12))
	if pm.is_empty() and pr.is_empty():
		_pending.add_child(_label(tr("HUNT_NONE_PENDING"), UiTokens.INK_DIM, 11))


# --- Rejection counter / pivot ---

func _refresh_counter() -> void:
	_counter.visible = GameState.pivot_used or GameState.vc_rejections > 0
	if GameState.pivot_used:
		_counter.text = tr("HUNT_COUNTER_PIVOT")
	else:
		_counter.text = tr("HUNT_COUNTER_TABLES").format({"closed": GameState.vc_rejections,
			"total": EndingsSystem.CASCADE_TABLES})


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


## Run a system action, then repaint: not every action emits a signal this page listens to.
func _act(action: Callable) -> void:
	action.call()
	_refresh()


func _button(text: String, on_press: Callable, tip: String = "") -> Button:
	var b := Button.new()
	b.text = text
	b.tooltip_text = tip
	b.pressed.connect(on_press)
	return b


func _box(box: BoxContainer, separation: int) -> BoxContainer:
	box.add_theme_constant_override("separation", separation)
	return box


func _label(content: String, color: Color, fsize: int, do_wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = content
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", fsize)
	if do_wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
