extends Control

# Finans penceresinin Yatırım sayfası (Series A Hunt; GDD v2 ch. 09). Başlık satırında sayfanın adı ve Frank'in
# şeridi (av yolu kapanınca yok), altında seed kapısı açıkken seed turu. Solda yatırımcılar: fon başına lider
# ortağın yüzü ve adı, tarzı ve durumu, Series A'da toplantı ve hazırlık eylemleri; kilitli 2. kademe yuvası.
# Sağda teklifler (fon, kalan süre, tahmini değerleme ve pay, masaya otur ya da kalk; sıradaki teklif; boş yuva)
# ve bekleyen toplantı ya da hazırlık. Kapanan masa sayacı yatırımcıların başında.
# Humble UI: VCPitchSystem / InvestorRegistry / GameState okur, eylemleri sisteme verir, VC sinyallerinde
# yeniden kurulur. Karar beklerken eylemleri kapalıdır.

const CLOCK := "res://assets/icons/util/clock.svg"
const CALENDAR := "res://assets/icons/util/calendar.svg"
const TERM_SHEET := "res://assets/icons/world/term_sheet.svg"
## A fund's state → its tag's word and kind; a closed table reads neutral unless the fund said no.
const STATUS_TAGS := {
	"offered": ["HUNT_BADGE_OFFERED", &"pos"], "pending_sheet": ["HUNT_BADGE_PENDING_SHEET", &"neutral"],
	"callback": ["HUNT_BADGE_CALLBACK", &"warn"], "rejected": ["HUNT_BADGE_REJECTED", &"risk"],
	"expired": ["HUNT_BADGE_EXPIRED", &"neutral"], "walked": ["HUNT_BADGE_WALKED", &"neutral"],
	"signed": ["HUNT_BADGE_SIGNED", &"pos"], "open": ["HUNT_BADGE_OPEN", &""],
}
const CLOSED := ["rejected", "expired", "walked"]

## The page's parts, painted anew on every change; the window reads its height.
var content: VBoxContainer
var _frank_line := ""   # a phone advisory that has taken the strip (see _on_advisory)
var _signals: Array = []
# The two sitting gates (WorkHoursSystem.sitting_open) as the page was painted. The clock and a
# work-hours change (assignment_changed, which moves the founder's end) can flip either one,
# and a flip repaints the page.
var _pitch_open: bool = true
var _table_open: bool = true
var _off := false   # a decision waits: the page reads only
var _gate_signals: Array = []
var _stale := false


func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	content = SprintUiShared.column(UiTokens.SPACE_XL)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	_signals = [
		EventBus.sheet_granted, EventBus.sheet_expired, EventBus.callback_ready,
		EventBus.meeting_day, EventBus.day_advanced, EventBus.mrr_changed,
		EventBus.pitch_finished, EventBus.sheet_walked,
		EventBus.seed_door_opened, EventBus.seed_sheet_granted, EventBus.seed_round_closed,
		# phase_changed too: the seed door SHUTS on entering the Series A Hunt, and the
		# Series A roster stops being telegraphed-locked on the same tick.
		EventBus.phase_changed,
		EventBus.event_triggered, EventBus.event_resolved, EventBus.event_set_aside,
		# A held clock shuts the seed pitch, its reason under the buttons.
		TimeManager.hold_changed,
	]
	for sig in _signals:
		sig.connect(_on_changed)
	EventBus.mentor_advisory_changed.connect(_on_advisory)
	_gate_signals = [EventBus.hour_changed, EventBus.assignment_changed]
	for sig in _gate_signals:
		sig.connect(_on_gate_input)
	visibility_changed.connect(func() -> void:
		if _stale and is_visible_in_tree():
			_refresh())
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_changed):
			sig.disconnect(_on_changed)
	if EventBus.mentor_advisory_changed.is_connected(_on_advisory):
		EventBus.mentor_advisory_changed.disconnect(_on_advisory)
	for sig in _gate_signals:
		if sig.is_connected(_on_gate_input):
			sig.disconnect(_on_gate_input)


## A repaint rebuilds the whole page: out of view (Özet shown, or the trip's veil) a change only marks it stale,
## and it repaints once when it shows.
func _on_changed(_a = null, _b = null) -> void:
	if is_visible_in_tree():
		_refresh()
	else:
		_stale = true


## Once a phone advisory has taken the strip it keeps it; until then the line is re-read on every refresh so
## {n} (tables already closed) follows vc_rejections.
func _on_advisory(key: String, args: Dictionary) -> void:
	_frank_line = tr(key).format(args)
	_on_changed()


func _on_gate_input(_arg = null) -> void:
	if WorkHoursSystem.sitting_open(PitchConstants.MEETING_HOURS) != _pitch_open \
			or WorkHoursSystem.sitting_open(PitchConstants.TERM_TABLE_HOURS) != _table_open:
		_on_changed()


func _refresh() -> void:
	_stale = false
	_pitch_open = WorkHoursSystem.sitting_open(PitchConstants.MEETING_HOURS)
	_table_open = WorkHoursSystem.sitting_open(PitchConstants.TERM_TABLE_HOURS)
	_off = EventGate.active_id() != ""
	UiFactory.clear(content)
	var road_closed: bool = VCPitchSystem.series_a_road_closed()
	var top := SprintUiShared.box(UiTokens.SPACE_3XL)
	top.custom_minimum_size.y = UiTokens.D_H_HUNT_HEAD
	top.add_child(SprintUiShared.label(tr("HUNT_PAGE_TITLE"), &"TitleH2"))
	top.add_child(RnDUiShared.spacer())
	# "The hunt is on" is true only in the hunt and only while a fund is open; a phone advisory speaks for itself.
	if _frank_line != "" or (GameState.phase >= 3 and not road_closed):
		top.add_child(_frank_strip())
	content.add_child(top)
	_paint_seed()
	var cols := SprintUiShared.box(UiTokens.SPACE_XL)
	content.add_child(cols)
	var roster := UiFactory.D_card(cols)
	roster.get_parent().custom_minimum_size.x = UiTokens.D_W_INVESTORS
	roster.get_parent().size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_paint_roster(roster)
	var right := SprintUiShared.column(UiTokens.SPACE_XL)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(right)
	_paint_offers(UiFactory.D_card(right), road_closed)
	_paint_pending(UiFactory.D_card(right))


## Frank's line in the title row: his disc, his name, his words.
func _frank_strip() -> PanelContainer:
	var strip := PanelContainer.new()
	strip.theme_type_variation = &"FrankStrip"
	strip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	strip.add_child(row)
	row.add_child(UiFactory.make_mentor_avatar(UiTokens.D_AVATAR_DOC))
	var words := SprintUiShared.column(UiTokens.SPACE_XXS)
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	words.add_child(UiFactory.make_label(tr("MENTOR_NAME"), &"Caption"))
	words.add_child(UiFactory.make_label(_frank_line if _frank_line != "" \
		else tr("HUNT_FRANK_LINE").format({"n": GameState.vc_rejections}), &"FrankQuote", UiTokens.D_INK_1))
	row.add_child(words)
	return strip


# --- Seed rung (GDD v2 ch. 09 §3) ---

## Four exclusive arms, newest state first: the round is closed, an offer is waiting, the
## one meeting is spent, or the door is open. Anything else and the card is not there.
func _paint_seed() -> void:
	if not SeedRoundSystem.page_unlocked() or not (GameState.seed_lead != "" or GameState.seed_sheet != null
			or GameState.seed_pitch_used or SeedRoundSystem.door_open()):
		return
	var card := UiFactory.D_card(content)
	card.add_child(UiFactory.D_card_head(tr("SEED_SECTION_TITLE")))
	if GameState.seed_lead != "":
		card.add_child(SprintUiShared.prose(tr("SEED_DONE_LINE").format({
			"investor": _vc_name(GameState.seed_lead),
			"amount": Fmt.money_exact(GameState.run_seed_amount),
			"equity": Fmt.percent(GameState.run_seed_equity_pct, 0)}), &"DataText"))
		card.add_child(SprintUiShared.label(tr("SEED_EXPECT_LABEL"), &"Caption"))
		card.add_child(_seed_expectation_line())
		return

	var sheet: TermSheet = GameState.seed_sheet
	if sheet != null:
		card.add_child(SprintUiShared.prose(tr("SEED_OFFER_LINE").format({"investor": _vc_name(sheet.vc_id)}), &"DataText"))
		card.add_child(SprintUiShared.label(tr("SEED_OFFER_TERMS").format(
			{"band": tr("SEED_BAND_" + sheet.band.to_upper())}), &"Caption"))
		# NO WALK BUTTON, and not by omission: refusing the round is ZOR MOD, so the row
		# that refuses it lives at the TABLE where it can be rendered locked with its
		# reason. A second refusal path here would be an unlocked door beside a locked one.
		card.add_child(_with_reason(_sit_button(sheet.vc_id, PitchConstants.STAGE_SEED),
			"" if _table_open else tr("VC_BLOCK_LATE")))
		return

	if GameState.seed_pitch_used:
		card.add_child(SprintUiShared.prose(tr("SEED_PITCH_SPENT_LINE").format(
			{"investor": _vc_name(GameState.seed_lead)}), &"MetaMuted"))
		return

	card.add_child(SprintUiShared.prose(tr("SEED_DOOR_LINE"), &"DataText"))
	card.add_child(SprintUiShared.prose(tr("SEED_DOOR_HINT"), &"Caption"))
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	# The open funds share one lock (_seed_block); its reason sits under the buttons that would otherwise
	# quietly do nothing (no fake choices).
	var blocked: String = _seed_block(String(InvestorRegistry.get_active()[0].get("id", "")))
	for inv in InvestorRegistry.get_active():
		# CONFIRMED, because it cannot be taken back: one seed pitch per run, and the
		# fund chosen here is the fund. Same grammar as walking a table.
		var b := _button(String(inv.get("display_name", "")), _confirm_seed_pitch.bind(String(inv.get("id", ""))))
		b.tooltip_text = tr("SEED_PITCH_BUTTON")
		b.disabled = _off or blocked != ""
		row.add_child(b)
	card.add_child(row)
	if blocked != "":
		card.add_child(SprintUiShared.label(tr(blocked), &"Caption"))


## The seed pitch's lock reason: a held clock first, then the rung's own, then the sitting gate.
func _seed_block(vc_id: String) -> String:
	if TimeManager.is_clock_held():
		return TimeManager.hold_label()
	var why: String = SeedRoundSystem.pitch_blocked_reason(vc_id)
	return "VC_BLOCK_LATE" if why == "" and not _pitch_open else why


## The growth expectation, in one line. The threshold IS rendered here, unlike
## the door bar: the door is an appetite the player infers, but 10 % a month is a promise
## an investor made out loud, and a promise nobody states is not one.
func _seed_expectation_line() -> Label:
	var e: Dictionary = SeedRoundSystem.expectation()
	var weeks: int = int(e.grace_weeks_left)
	var args := {"weeks": weeks, "avg": Fmt.percent(int(e.avg_pct), 0), "need": Fmt.percent(int(e.need_pct), 0)}
	match int(e.state):
		SeedConstants.EXPECT_GRACE:
			# Past the grace weeks but still GRACE: too few closed months to read, so no count.
			if weeks > 0:
				return SprintUiShared.prose(tr(Fmt.count_key("SEED_EXPECT_GRACE", weeks)).format(args), &"Caption")
		SeedConstants.EXPECT_ON_TRACK:
			return SprintUiShared.prose(tr("SEED_EXPECT_ON_TRACK").format(args), &"DataText")
		SeedConstants.EXPECT_STALLED:
			var stalled := SprintUiShared.prose(tr("SEED_EXPECT_STALLED").format(args), &"DataText")
			stalled.add_theme_color_override("font_color", UiTokens.D_neg())
			return stalled
	return SprintUiShared.prose(tr("SEED_EXPECT_UNKNOWN"), &"Caption")


func _confirm_seed_pitch(vc_id: String) -> void:
	if _seed_block(vc_id) != "":
		return
	EventBus.confirm_requested.emit({
		"title": tr("SEED_PITCH_CONFIRM_TITLE"),
		"body": tr("SEED_PITCH_CONFIRM_BODY").format({"investor": _vc_name(vc_id)}),
		"confirm_text": tr("SEED_PITCH_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _act.bind(SeedRoundSystem.begin_pitch.bind(vc_id)),
	})


# --- Roster ---

## The funds, each on its row; the head counts the tables closed so far (or says the road is the pivot's).
func _paint_roster(card: VBoxContainer) -> void:
	var count := SprintUiShared.box(UiTokens.SPACE_M)
	if GameState.pivot_used:
		count.add_child(SprintUiShared.label(tr("HUNT_COUNTER_PIVOT"), &"MetaMuted"))
	else:
		count.add_child(SprintUiShared.label(tr("HUNT_COUNTER_TABLES").format({"closed": GameState.vc_rejections,
			"total": EndingsSystem.CASCADE_TABLES}), &"MetaMuted"))
		var pips := SprintUiShared.box(UiTokens.SPACE_XS)
		for i in EndingsSystem.CASCADE_TABLES:
			var pip := Panel.new()
			pip.theme_type_variation = UiTokens.D_variation(&"PipOn" if i < GameState.vc_rejections else &"PipOff")
			pip.custom_minimum_size = Vector2.ONE * UiTokens.D_PIP_TABLE
			pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			pips.add_child(pip)
		count.add_child(pips)
	card.add_child(UiFactory.D_card_head(tr("HUNT_SEC_INVESTORS"), count))
	var rows := SprintUiShared.column(0)
	card.add_child(rows)
	for inv in InvestorRegistry.get_all():
		rows.add_child(_fund_row(inv))


## A fund: its lead partner's face, its name and domain, its way in the room and the partner, its state; under
## them what the player can do with it now, so the face and the state stay beside the name. The locked slot is a
## disc round its lock and a word.
func _fund_row(inv: Dictionary) -> PanelContainer:
	var vc_id: String = String(inv.get("id", ""))
	var row := PanelContainer.new()
	row.theme_type_variation = &"TableRow"
	row.custom_minimum_size.y = UiTokens.D_H_FUND
	var stack := SprintUiShared.column(UiTokens.SPACE_XXS)
	var inset := SprintUiShared.pad(stack, Vector4i(UiTokens.SPACE_XS, UiTokens.SPACE_M, UiTokens.SPACE_L, UiTokens.SPACE_M))
	inset.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(inset)
	var line := SprintUiShared.box(UiTokens.SPACE_XL)
	stack.add_child(line)
	var body := SprintUiShared.column(UiTokens.SPACE_XXS)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if inv.get("locked", false):
		var disc := Panel.new()
		disc.theme_type_variation = &"LockDisc"
		disc.custom_minimum_size = Vector2.ONE * UiTokens.D_AVATAR_DOC
		disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var middle := CenterContainer.new()
		middle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		middle.add_child(UiFactory.make_glyph("res://assets/icons/util/lock.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_OFF))
		disc.add_child(middle)
		line.add_child(disc)
		body.add_child(UiFactory.make_label(String(inv.get("display_name", "")), &"SubjectLabel", UiTokens.D_INK_OFF))
		body.add_child(UiFactory.make_label(tr("HUNT_LOCKED_SOON"), &"Caption"))
		line.add_child(body)
		return row
	var status: String = String(GameState.vc_states.get(vc_id, {}).get("status", "open"))
	var closed: bool = status in CLOSED or GameState.pivot_used
	var lead: Dictionary = CounterpartSystem.lead(vc_id)
	line.add_child(UiFactory.make_person_avatar(lead.name, lead.look, UiTokens.D_AVATAR_DOC, closed))
	var l1 := SprintUiShared.box(UiTokens.SPACE_M)
	l1.add_child(UiFactory.make_label(String(inv.get("display_name", "")), &"SubjectLabel" if closed else &"SubjectStrong",
		UiTokens.D_INK_3 if closed else null))
	l1.add_child(UiFactory.D_tag(InvestorRegistry.domain_chip(vc_id)))
	body.add_child(l1)
	var arc := UiFactory.make_label(InvestorRegistry.archetype_line(vc_id), &"MetaMuted" if closed else &"MetaText")
	arc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	arc.clip_text = true
	body.add_child(arc)
	body.add_child(UiFactory.make_label("%s · %s" % [lead.name, CounterpartSystem.title(lead, vc_id)], &"Caption"))
	line.add_child(body)
	var tag: Array = STATUS_TAGS.get(status, STATUS_TAGS.open)
	line.add_child(UiFactory.D_tag(tr(tag[0]), tag[1]))
	if not GameState.pivot_used:
		var actions: Control = _roster_actions(vc_id)
		if actions != null:
			stack.add_child(SprintUiShared.pad(actions, Vector4i(UiTokens.D_AVATAR_DOC + UiTokens.SPACE_XL, 0, 0, 0)))
	return row


func _roster_actions(vc_id: String) -> Control:
	# TELEGRAPHED, NOT BLANK: the page is reachable in Traction once the seed door has opened,
	# and a row of four funds with no button and no sentence reads as a bug.
	if GameState.phase < 3:
		return SprintUiShared.label(tr("FIN_SUBTAB_LOCKED"), &"Caption")
	var reason: String = VCPitchSystem.meeting_blocked_reason(vc_id)
	if reason == "closed":
		return null  # closed, or the offer lives in Teklifler — no roster action

	var st: Dictionary = GameState.vc_states.get(vc_id, {})
	var callback: bool = st.get("status", "open") == "callback"
	var condition: String = ""
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	if callback:
		condition = tr("HUNT_CONDITION").format({"condition": VCPitchSystem.callback_text(st.get("callback", {}))})
		col.add_child(SprintUiShared.prose(condition, &"Caption"))

	if GameState.pending_meeting.get("vc_id", "") == vc_id:
		col.add_child(SprintUiShared.label(tr("HUNT_MEETING_SET"), &"CaptionPrimary"))
		if VCPitchSystem.can_move_meeting():
			col.add_child(_meeting_move_row())
		col.add_child(_prep_row(vc_id))
		return col

	var text: String = (tr("HUNT_REQUEST_AGAIN") if callback else tr("HUNT_REQUEST_MEETING")).format(
		{"when": _when(TimeModel.ticks(PitchConstants.MEETING_LEAD_WEEKS))})
	# The system says why (no fake choices): the callback condition is the lock on a
	# callback fund, and it is already printed one line up.
	var why: String = {"callback_unmet": "", "cancelled_this_week": tr("HUNT_MEETING_CANCELLED_THIS_WEEK"),
		"busy": tr("HUNT_MEETING_BUSY")}.get(reason, "")
	var btn := _button(text, _act.bind(VCPitchSystem.request_meeting.bind(vc_id)))
	btn.disabled = _off or reason != ""
	col.add_child(_with_reason(btn, why))
	return col


## Cancel or move the booked meeting. Only before its week; each costs a little of that
## fund's conviction at its next meeting, and the buttons say how much. The move button names
## the week the meeting would land in (VCPitchSystem.reschedule_meeting).
func _meeting_move_row() -> Control:
	var box := SprintUiShared.box(UiTokens.SPACE_M)
	var moved_to: int = int(GameState.pending_meeting.get("day", 0)) + TimeModel.ticks(PitchConstants.MEETING_LEAD_WEEKS)
	for row in [[tr("HUNT_MEETING_RESCHEDULE").format({"when": _when(moved_to - GameState.day)}),
			VCPitchSystem.reschedule_meeting, tr("HUNT_RESCHEDULE_TIP").format({"n": PitchConstants.MEETING_RESCHEDULE_PENALTY})],
			[tr("HUNT_MEETING_CANCEL"), VCPitchSystem.cancel_meeting,
			tr("HUNT_CANCEL_TIP").format({"n": PitchConstants.MEETING_CANCEL_PENALTY})]]:
		var b := _button(row[0], _act.bind(row[1]))
		b.tooltip_text = row[2]
		b.disabled = _off
		box.add_child(b)
	return box


func _prep_row(vc_id: String) -> Control:
	# 3 focus buttons if prep is allowed; the block reason otherwise (no fake choices).
	if not GameState.prep.is_empty():
		return SprintUiShared.label(tr("HUNT_PREP_RUNNING"), &"Caption")
	var reason: String = VCPitchSystem.prep_blocked_reason(vc_id)
	if reason != "":
		return SprintUiShared.prose(tr("HUNT_PREP_REASON").format({"reason": reason}), &"Caption")
	var box := SprintUiShared.box(UiTokens.SPACE_M)
	for focus_id in PitchConstants.FOCUS_KEYS:
		var b := _button(tr(PitchConstants.FOCUS_KEYS[focus_id]), _act.bind(VCPitchSystem.start_prep.bind(vc_id, focus_id)))
		b.disabled = _off
		box.add_child(b)
	return box


# --- Offers (Teklifler) ---

## The offers: the documents, the empty slot beside one and the queued ones; with none, the head's one line.
func _paint_offers(card: VBoxContainer, road_closed: bool) -> void:
	var sheets: Array = GameState.active_sheets
	var queued: Array = []
	for inv in InvestorRegistry.get_active():
		if bool(GameState.vc_states.get(String(inv.id), {}).get("pending_sheet", false)):
			queued.append(String(inv.id))
	var none: bool = not road_closed and sheets.is_empty() and queued.is_empty()
	card.add_child(UiFactory.D_card_head(tr("HUNT_SEC_OFFERS"),
		SprintUiShared.empty_line(tr("HUNT_NO_OFFERS"), TERM_SHEET, 0) if none else null))
	if none:
		return
	if road_closed:
		# Every fund is closed and nothing is live: say it once, plainly, with no empty-offers
		# line or empty slot that implies another meeting could still produce one.
		var line := SprintUiShared.box(UiTokens.SPACE_L)
		line.add_child(UiFactory.make_glyph(TERM_SHEET, UiTokens.D_ICON_CONTROL, UiTokens.D_INK_4))
		line.add_child(SprintUiShared.prose(tr("HUNT_ROAD_CLOSED"), &"DataText"))
		card.add_child(line)
		return
	var docs := SprintUiShared.column(UiTokens.SPACE_M)
	card.add_child(docs)
	for sheet in sheets:
		docs.add_child(_offer_doc(sheet))
	if sheets.size() < PitchConstants.MAX_SHEETS:
		docs.add_child(_dashed_note(SprintUiShared.label(tr("HUNT_EMPTY_SLOT"), &"Caption")))
	# The third sheet waits for a slot, and the player can see it waiting.
	for vc_id in queued:
		var line := SprintUiShared.box(UiTokens.SPACE_L)
		var glyph := UiFactory.make_glyph("res://assets/icons/util/queue.svg", UiTokens.D_ICON_BUTTON, UiTokens.D_INK_4)
		glyph.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		line.add_child(glyph)
		line.add_child(SprintUiShared.prose(tr("HUNT_QUEUED_OFFER").format({"investor": _vc_name(vc_id),
			"n": PitchConstants.SHEET_VALIDITY_WEEKS}), &"MetaMuted"))
		docs.add_child(_dashed_note(line))


## A box with a dashed edge round `child`: an offer that is not here yet.
func _dashed_note(child: Control) -> MarginContainer:
	var note := SprintUiShared.pad(child, Vector4i(UiTokens.SPACE_XL, UiTokens.SPACE_L, UiTokens.SPACE_XL, UiTokens.SPACE_L))
	HRUiShared.D_dashed(note)
	return note


## An offer, a document: the lead partner, the fund and the weeks it stands (the warning ink, red in its final
## weeks), the way to the table and away from it; under them the estimated valuation and equity, never the
## number and never the board term: the table is where the exact terms open up. The range is seeded per sheet,
## so it does not reroll.
func _offer_doc(sheet: TermSheet) -> PanelContainer:
	var vc_id: String = sheet.vc_id
	var doc := PanelContainer.new()
	doc.theme_type_variation = &"OfferDoc"
	var body := SprintUiShared.column(UiTokens.SPACE_M)
	doc.add_child(body)
	var head := SprintUiShared.box(UiTokens.SPACE_L)
	body.add_child(head)
	var lead: Dictionary = CounterpartSystem.lead(vc_id)
	head.add_child(UiFactory.make_person_avatar(lead.name, lead.look, UiTokens.D_AVATAR_ROW))
	var who := SprintUiShared.column(UiTokens.SPACE_XXS)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	who.add_child(UiFactory.make_label(_vc_name(vc_id), &"SubjectStrong"))
	var due: bool = sheet.is_decision_due(GameState.day)
	var weeks: int = sheet.weeks_left(GameState.day)
	var ink: Color = UiTokens.D_offer_reading(weeks).ink
	var left := SprintUiShared.box(UiTokens.SPACE_S)
	left.add_child(UiFactory.make_glyph(CLOCK, UiTokens.D_ICON_LINE, ink))
	# The window has closed; the decision card is up (or about to be). The same two answers live here so the
	# page never shows a sheet with nothing to do about it.
	left.add_child(SprintUiShared.label(tr("HUNT_DECISION_DUE") if due
		else tr(Fmt.count_key("HUNT_VALIDITY", weeks)).format({"n": weeks}), &"MetaText", ink))
	who.add_child(left)
	head.add_child(who)
	var away := _button(tr("VC_EV_DECISION_DECLINE") if due else tr("HUNT_WALK_AWAY"),
		_act.bind(VCPitchSystem.decline_expired_sheet.bind(vc_id)) if due else _confirm_walk.bind(vc_id), &"GhostButtonSmall")
	away.disabled = _off
	head.add_child(away)
	head.add_child(_sit_button(vc_id, PitchConstants.STAGE_SERIES_A))
	var parts := SprintUiShared.box(UiTokens.SPACE_3XL)
	parts.add_child(_part("HUNT_EST_VALUATION_KEY", VCPitchSystem.estimate_valuation_text(vc_id), ""))
	parts.add_child(VSeparator.new())
	parts.add_child(_part("HUNT_EST_EQUITY_KEY", VCPitchSystem.estimate_dilution_text(vc_id),
		"res://assets/icons/stake/equity.svg"))
	body.add_child(parts)
	if not _table_open:
		body.add_child(SprintUiShared.label(tr("VC_BLOCK_LATE"), &"Caption"))
	return doc


## An offer's figure: its key over its value, an equity slice before a cost.
func _part(key: String, value: String, glyph: String) -> VBoxContainer:
	var part := SprintUiShared.column(UiTokens.SPACE_XXS)
	part.add_child(UiFactory.make_label(tr(key), &"Caption"))
	var line := SprintUiShared.box(UiTokens.SPACE_M)
	if glyph != "":
		line.add_child(UiFactory.make_glyph(glyph, UiTokens.D_ICON_FIGURE, UiTokens.D_INK_3))
	line.add_child(SprintUiShared.label(value, &"ValueTextStrong"))
	part.add_child(line)
	return part


func _confirm_walk(vc_id: String) -> void:
	EventBus.confirm_requested.emit({
		"title": tr("HUNT_WALK_CONFIRM_TITLE"),
		"body": tr("HUNT_WALK_CONFIRM_BODY"),
		"confirm_text": tr("HUNT_WALK_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _act.bind(VCPitchSystem.walk_table.bind(vc_id)),
	})


# --- Pending (Bekleyen) ---

## The booked meeting and the prep under way; nothing pending is the head's one line.
func _paint_pending(card: VBoxContainer) -> void:
	var lines: Array = []
	var pm: Dictionary = GameState.pending_meeting
	var pr: Dictionary = GameState.prep
	if not pm.is_empty():
		lines.append(tr("HUNT_MEETING_PENDING").format({"vc": _vc_name(String(pm.get("vc_id", ""))),
			"when": _when(int(pm.get("day", 0)) - GameState.day)}))
	if not pr.is_empty():
		var pd: int = int(pr.get("done_day", 0)) - GameState.day
		lines.append(tr("HUNT_PREP_PENDING").format({
			"focus": tr(PitchConstants.FOCUS_KEYS.get(String(pr.get("focus", "")), "HUNT_CB_NONE")),
			"when": tr("HUNT_PREP_READY") if pd <= 0 else _when(pd)}))
	card.add_child(UiFactory.D_card_head(tr("HUNT_SEC_PENDING"),
		SprintUiShared.empty_line(tr("HUNT_NONE_PENDING"), CALENDAR, 0) if lines.is_empty() else null))
	for text in lines:
		var line := SprintUiShared.box(UiTokens.SPACE_M)
		line.add_child(UiFactory.make_glyph(CALENDAR, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
		line.add_child(SprintUiShared.label(text, &"DataText"))
		card.add_child(line)


# --- Helpers ---

func _vc_name(vc_id: String) -> String:
	return String(InvestorRegistry.get_investor(vc_id).get("display_name", vc_id))


## How far off a booking is, in words: this week, next week, or in n weeks.
func _when(weeks: int) -> String:
	if weeks <= 0:
		return tr("HUNT_THIS_WEEK")
	return tr("HUNT_NEXT_WEEK") if weeks == 1 else tr("HUNT_WEEKS").format({"n": weeks})


## "Masaya otur", locked with its reason while the table's sitting gate is shut.
func _sit_button(vc_id: String, stage: String) -> Button:
	var b := _button(tr("HUNT_SIT_DOWN"), EventBus.term_table_requested.emit.bind(vc_id, stage))
	b.disabled = _off or not _table_open
	return b


## A button and, while it is locked for a reason, the reason beside it.
func _with_reason(button: Button, why: String) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.add_child(button)
	if button.disabled and why != "":
		row.add_child(SprintUiShared.prose(why, &"Caption"))
	return row


## Run a system action, then repaint: not every action emits a signal this page listens to.
func _act(action: Callable) -> void:
	action.call()
	_refresh()


func _button(text: String, on_press: Callable, look: StringName = &"SecondaryButtonSmall") -> Button:
	var b := SprintUiShared.button(text, look, on_press)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return b
