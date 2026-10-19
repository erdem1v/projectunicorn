class_name SalesRepSystem
extends RefCounted

# THE SALES DESK (§7) — what an assigned Satış Temsilcisi actually does. Pure static logic,
# no scene dependency. Dispatched daily from B2BSalesSystem.daily_tick, LAST, after the
# faucet: a close creates a Customer and a same-day-signed account must not be lifecycle
# ticked on its own signing day.
#
# Supply is the faucet's (§3). A desk seller (a rep, or the founder on the Satış job) works ONE
# deal at a time and the pipeline says which one (§7.2). The ceiling is a STAR: a rep sells at or
# below their own Satış star and cannot reach above it (§7.1), a gate the player can see on the card.
#
# AN IN-LEAGUE DEAL SIGNS UNLESS THE PRODUCT LACKS WHAT THE CUSTOMER LOOKS AT (§7.6): a deal runs a plan of half weeks
# (SalesConstants.deal_halfweeks), stamped when it opens, and when the plan has run it signs, except that a prospect lacking
# an area it looks at rolls the product's close chance (ProductQuality.close_chance) on a die its own lead seeds. A lost deal
# is named after that area, takes the road a lost sitting takes (SalesFinalizer.lose) and reaches the founder as a mail from
# the seller, at most one a week, the rest as lines of the weekly summary. Premium stretches a desk plan and, on a
# price-sensitive archetype, produces the price-break moment (§7.6).
# The founder's table deals ride the same sweep (`sign_due`) and sign at their agreed terms
# (SalesFinalizer.sign_deal). A sweep runs in this daily slot and at noon (SalesSystem.hourly_tick),
# so a plan of an odd number of half weeks signs at noon.
#
# THE PRICE-BREAK CARD IS DEFINED AND INERT. Its behaviour and its trigger live here, and the
# moment publishes `rep_discount_requested`. What does NOT happen is `EventGate.request` — the
# wiring is the event package's (§18), and until it lands the deal closes at its own stance.
# That is a stated fallback, not an accident: an inert card must not be able to strand a deal.
#
# THE ADDITIVITY INVARIANT, desk half: with nobody on Satış the desk works nothing — a desk deal
# drops when its seller leaves the job, and no desk deal is started or closed.


# ============================================================================
#  Daily entry
# ============================================================================

static func daily_tick() -> void:
	_tick_weekly_summary()
	_tick_processing()
	_tick_assignment()


## The rep with this id if they are on the Satış job today, else null.
static func _assigned_rep(rep_id: String) -> Character:
	for c in HRSystem.assigned_to(HRConstants.AREA_SALES):
		if (c as Character).id == rep_id:
			return c as Character
	return null


static func _drop_processing(lead: Prospect) -> void:
	lead.worked_by = ""
	lead.work_started_day = -1
	lead.work_stance = ""
	lead.price_break_raised = false
	lead.deal_halfweeks = 0
	lead.deal_paused_halfweeks = 0
	# The lead returns to the ordinary waiting rules with a full clock — the freeze it enjoyed
	# while it was being worked was never time it spent waiting.
	lead.expires_on_day = GameState.day + TimeModel.ticks(SalesConstants.LEAD_LIFE_WEEKS)


# ============================================================================
#  §7.1 · The star gate and §7.2.2's band cap
# ============================================================================

## The highest star this rep may work. The GATE is their own Satış star (§7.1, hard); the CAP
## is the player's setting on top of it and can only ever LOWER the ceiling — "tavanı
## düşürmek temsilciyi alt bandın süpürgesine çevirir" (§7.2.1).
static func band_ceiling(rep: Character) -> int:
	var own: int = rep_star(rep)
	var cap: int = SalesLedger.rep_band_cap(rep.id)
	if cap == SalesConstants.BAND_CAP_OWN_LEAGUE:
		return own
	return mini(cap, own)


static func rep_star(rep: Character) -> int:
	return int(HRConstants.stars_for(HRSystem.skill(rep, HRConstants.AREA_SALES)))


## §7.2.2 — the selector's rungs for one rep: every full star step up to their own, plus
## "Kendi ligi". A 1★ rep has ONE rung, and a one-option selector is a fake choice, so the
## surface draws a plain information line instead. The rule lives here rather than in the tab
## so the tab cannot forget it.
static func band_cap_options(rep: Character) -> Array:
	var own: int = rep_star(rep)
	if own <= SalesConstants.STAR_MIN:
		return []
	var out: Array = range(SalesConstants.STAR_MIN, own + 1)
	out.append(SalesConstants.BAND_CAP_OWN_LEAGUE)
	return out


## §7.2.2 — "Band dışına düşen lead kartı hover'la nedenini söyler." "" when the rep could
## work this lead; otherwise the CSV key naming why not.
static func out_of_band_reason(rep: Character, lead: Prospect) -> String:
	if lead.star > rep_star(rep):
		return "SALES_BAND_ABOVE_REP"
	if lead.star > band_ceiling(rep):
		return "SALES_BAND_ABOVE_CAP"
	return ""


# ============================================================================
#  §7.2.1 · Selection
# ============================================================================

## "Seçim kuralı: bandındaki yönlendirilmemiş lead'lerden en yüksek yıldızlı; eşitlikte süresi
## bitmek üzere olan." Reserved leads are skipped outright — that desk is the founder's — and so is a returning one whose
## named loss has not moved since (the founder's door shuts on it too).
static func pick_lead_for(rep: Character) -> Prospect:
	var ceiling: int = band_ceiling(rep)
	var best: Prospect = null
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if lead.is_being_worked() or lead.star > ceiling or SalesLedger.repitch_blocked(lead):
			continue
		if lead.routing == SalesConstants.ROUTE_RESERVED:
			continue
		if best == null or _outranks(lead, best):
			best = lead
	return best


static func _outranks(a: Prospect, b: Prospect) -> bool:
	# "Temsilciye ver" puts a lead at the FRONT of the band queue (§7.2.1) — ahead of the
	# star rule, because it is the player saying which desk they want cleared.
	var a_routed: bool = a.routing == SalesConstants.ROUTE_REP
	var b_routed: bool = b.routing == SalesConstants.ROUTE_REP
	if a_routed != b_routed:
		return a_routed
	if a.star != b.star:
		return a.star > b.star
	if a.expires_on_day != b.expires_on_day:
		return a.expires_on_day < b.expires_on_day   # least time left first
	return a.id < b.id                               # deterministic tiebreak


static func _tick_assignment() -> void:
	for c in HRSystem.assigned_to(HRConstants.AREA_SALES):
		var rep: Character = c as Character
		if SalesLedger.rep_busy(rep.id) != "":
			continue
		var lead: Prospect = pick_lead_for(rep)
		if lead == null:
			continue
		_start_processing(rep, lead)


static func _start_processing(rep: Character, lead: Prospect) -> void:
	lead.worked_by = rep.id
	lead.work_started_day = GameState.day
	# §7.5 — the stance is STAMPED at the start: "İşlenmekte olan deal başladığı kadrandan
	# kapanır." Moving the dial mid-deal cannot retroactively reprice a conversation that is
	# already happening.
	lead.work_stance = SalesLedger.price_stance()
	lead.deal_halfweeks = _desk_halfweeks(rep, lead)
	# NO `lead_routed` HERE. That signal is the PLAYER's verb ("Temsilciye ver") and its one
	# publisher is SalesLedger.set_routing; a desk picking work up on its own is a different
	# event and borrowing the name would give one signal two meanings and two emitters (§14).


# ============================================================================
#  §7.2 · Processing
# ============================================================================

## A desk deal's plan, stamped when it opens: the stars' plan, Premium's +30 %, divided by the
## seller's productivity this week (morale share and event lines), never under the minimum.
static func _desk_halfweeks(rep: Character, lead: Prospect) -> int:
	var halfweeks: float = SalesConstants.deal_halfweeks(lead.star, rep_star(rep))
	if lead.work_stance == SalesConstants.STANCE_PREMIUM:
		halfweeks *= 1.0 + SalesConstants.PROCESS_PREMIUM_PENALTY
	return maxi(roundi(halfweeks / HRSystem.productivity(rep)), roundi(2.0 * SalesConstants.DEAL_MIN_WEEKS))


## The daily slot: a desk deal whose seller left the Satış job drops, then every due deal signs.
## `_tick_assignment` runs after it, so a seller who signs here opens the next deal in the same slot.
static func _tick_processing() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if not lead.is_being_worked() or lead.is_table_deal():
			continue
		var rep: Character = _assigned_rep(lead.worked_by)
		var seller: Character = CharacterRegistry.get_character(lead.worked_by)
		if rep != null:
			# §7.6 — the price-break moment of a Premium deal against a price-sensitive archetype,
			# read before the signature. It publishes and does NOT raise a card (see the header).
			_maybe_price_break(rep, lead)
		elif seller == null or not seller.assigned_jobs.has(HRConstants.AREA_SALES):
			# §12 — off the Satış job, fired or resigned: the deal drops and the lead returns to the
			# waiting rules. A seller on leave or training keeps it (`sign_due` pauses it).
			_drop_processing(lead)
	sign_due()


## Every deal whose plan has run signs: the founder's table deals at their agreed terms, a desk
## deal through its seller. A desk deal whose seller is off duty at a sweep waits that half week.
static func sign_due() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if lead.is_table_deal():
			if lead.deal_due():
				SalesFinalizer.sign_deal(lead)
			continue
		if not lead.is_being_worked():
			continue
		var rep: Character = _assigned_rep(lead.worked_by)
		if rep == null:
			lead.deal_paused_halfweeks += 1
		elif lead.deal_due():
			_close(rep, lead)


# ============================================================================
#  §7.6 · The close, and the price-break moment
# ============================================================================

## Would the price-break card drop on this deal? The whole predicate, so the event package can
## bind to one name when it wires the card.
static func price_break_due(lead: Prospect) -> bool:
	if lead.work_stance != SalesConstants.STANCE_PREMIUM:
		return false
	return SalesArchetypes.is_price_sensitive(lead.archetype_id)   # "Duyarsız arketip kartı üretmez."


static func _maybe_price_break(rep: Character, lead: Prospect) -> void:
	if not price_break_due(lead):
		return
	if lead.price_break_raised:
		return
	lead.price_break_raised = true
	# §18 — the card (SalesConstants.PRICE_BREAK_CARD_ID) is not requested here; see the header.
	EventBus.rep_discount_requested.emit(rep.id, lead.id)


## The area a due desk deal is lost over, "" when it signs. A prospect lacking nothing it looks at always signs; one lacking an
## area signs by a die the lead itself seeds (run seed, lead, archetype), so a reload cannot reroll it, against the product as it
## stands now: a product that grew while the plan ran can only turn a loss into a signature.
static func lost_area(lead: Prospect) -> String:
	var roll: float = SalesConstants.mix_unit(lead.id + "|" + lead.archetype_id, SalesConstants.SALT_REP_CLOSE)
	return "" if roll < ProductQuality.close_chance(lead) else ProductQuality.prospect_fit(lead).loss_area


## The deal is lost: it takes the road a lost sitting takes, the seller tells the founder, and the desk moves to its next lead.
static func _lose(rep: Character, lead: Prospect, area: String) -> void:
	SalesFinalizer.lose(lead.id, lead.company_name, SalesConstants.LOSS_WEAK_AREA, area, SalesConstants.RETURN_LOCK_WEEKS)
	# The first loss of a week is a mail from the seller; the week's others wait for the summary's lines, and so does every loss of
	# the founder at the desk, who would be writing to himself.
	if rep.category == "founder" or int(GameState.get_flag("sales_loss_mail_day", 0)) == GameState.day:
		SalesLedger.record_loss(rep.character_name, lead.company_name, area)
	else:
		GameState.set_flag("sales_loss_mail_day", GameState.day)
		MessageSystem.post("sales_loss", "SALES_REP_LOST_TITLE",
			{"rep": rep.character_name, "company": lead.company_name, "area": area})
	EventBus.rep_deal_lost.emit(rep.id, lead.id, area)


static func _close(rep: Character, lead: Prospect) -> void:
	var lost: String = lost_area(lead)
	if lost != "":
		_lose(rep, lead, lost)
		return
	# §7.5 — the rep closes at THE DIAL's price. Their star does not touch it: "Temsilci
	# kadrandan kapatır; yıldızı fiyata dokunmaz."
	var seat_price: int = SalesLedger.seat_price_anchor(lead.work_stance)
	var seats: int = _seats_for(lead)
	var c: Customer = SalesSystem.add_b2b_customer(lead, seats, seat_price,
		SalesSystem.signing_satisfaction_seed(), "sales_rep:%s" % rep.id)
	ProspectRegistry.remove(lead.id)
	SalesLedger.record_close(c, rep.character_name)
	SalesSystem.record_sales_event("auto_close", rep.character_name, c.company_name, c.mrr)
	EventBus.rep_deal_closed.emit(rep.id, c.id)
	SalesLedger.announce_signing(c, lead.is_whale,
		{"key": "SALES_TICKER_SIGNED", "args": {"rep": rep.character_name, "company": c.company_name}})


## §5.3 — seats come from the star band, never from a negotiation. The placement inside the
## band comes from the ACCOUNT (run seed + lead id + archetype through the module's own mixer),
## so two accounts at one star do not sign identical seat counts. The rep's star does not reach
## the price or the seats (§7.5), and the value is replay-stable, so a reload cannot reroll a
## deal that already closed.
static func _seats_for(lead: Prospect) -> int:
	var band: Dictionary = SalesConstants.seat_band(lead.star)
	var t: float = SalesConstants.mix_unit(
		lead.id + "|" + lead.archetype_id, SalesConstants.SALT_REP_SEATS)
	return int(round(lerpf(float(band["low"]), float(band["high"]), t)))


# ============================================================================
#  §7.3 · The weekly summary
# ============================================================================

# DESIGN-PARKED: a week with no desk close and no lost desk deal posts NO report. §7.3 says the summary carries closes;
# a report of none is a report of nothing. Alternative seen: always post it with a "no closes this
# week" line — noise.
## "Haftalık satış özeti yalnız kapanışları taşır — temsilcinin sesiyle bilgi kartı. Churn
## girmez. Karar butonu yok." An inbox message, not an engine card: the week's rows (a desk close
## names its rep, the voice the report is sent in), the week's lost desk deals the founder was not mailed about and the book's
## account count as they stand when the report is written, so it never stops the clock, never waits in the event queue and
## never reads a later week. A week of losses alone opens it too.
static func _tick_weekly_summary() -> void:
	var anchor: int = int(GameState.get_flag("sales_weekly_anchor_day", 0))
	if anchor <= 0:
		GameState.set_flag("sales_weekly_anchor_day", GameState.day)
		return
	if GameState.day - anchor < TimeModel.ticks(SalesConstants.WEEKLY_SUMMARY_INTERVAL_WEEKS):
		return
	GameState.set_flag("sales_weekly_anchor_day", GameState.day)
	var rows: Array = SalesLedger.close_week()
	var lost: Array = SalesLedger.lost_week()
	# A row loaded from an older save names no rep and counts as the founder's.
	var closes: int = rows.filter(func(r: Dictionary) -> bool: return String(r.get("rep", "")) != "").size()
	if closes <= 0 and lost.is_empty():
		return
	EventBus.weekly_sales_report_issued.emit(closes)
	MessageSystem.post("sales_week", "SALES_WEEKLY_TITLE",
		{"rows": rows, "lost": lost, "accounts": CustomerRegistry.account_count()})
