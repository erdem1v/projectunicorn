class_name SalesRepSystem
extends RefCounted

# THE SALES DESK (§7) — what an assigned Satış Temsilcisi actually does. Pure static logic,
# no scene dependency. Dispatched daily from B2BSalesSystem.daily_tick, LAST, after the
# faucet: a close creates a Customer and a same-day-signed account must not be lifecycle
# ticked on its own signing day.
#
# WHAT REV 6 REPLACED (§19). The old desk generated its own leads, warmed every prospect in
# the pool at once through an invisible `warm_progress` accumulator, and closed anything under
# an MRR ceiling. All three are gone. Supply is the faucet's (§3). A rep works ONE lead at a
# time and the pipeline says which one and for how long (§7.2). And the ceiling is not money
# any more, it is a STAR: a rep sells at or below their own Satış star and cannot reach above
# it (§7.1), which is a gate the player can see on the card rather than a number they cannot.
#
# THE CLOSE IS DETERMINISTIC IN-LEAGUE (§7.6). There is no hidden close percentage. A rep
# assigned to a lead inside their band on Competitive or Standard WILL close it; what varies
# is how long it takes, and that comes from `hr.effective_skill` — morale, focus, hours and
# traits all play the same duration rather than a private formula. Premium is the one
# conditional: it lengthens processing and, on a price-sensitive archetype, produces the
# price-break moment (§7.6).
#
# THE PRICE-BREAK CARD IS DEFINED AND INERT. Its behaviour, its trigger window and its
# HAYIR DİYEMEZ multiplier all live here, and the moment publishes `rep_discount_requested`.
# What does NOT happen is `EventGate.request` — the wiring is the event package's (§18), and
# until it lands the deal closes at its own stance. That is a stated fallback, not an
# accident: an inert card must not be able to strand a deal.
#
# NO RNG. Not one draw. A rep working a lead is WORK, which this game models as elapsed days
# against a duration, not a coin flip — and it is what makes "Kerem dört gündür Ege Sigorta
# ile görüşüyor" a readable cause instead of a hidden roll.
#
# THE ADDITIVITY INVARIANT SURVIVES: with nobody assigned to Satış every entry point returns
# before it touches state, so a run without a rep behaves exactly as it did.


# ============================================================================
#  Daily entry
# ============================================================================

static func daily_tick() -> void:
	_tick_weekly_summary()
	if HRSystem.assigned_to(HRConstants.AREA_SALES).is_empty():
		_release_orphans()
		return
	_tick_processing()
	_tick_assignment()


## §12 — "Temsilci ayrılır / izne çıkar | işleme düşer; lead bekleme kurallarına döner."
## Also the whole-desk case: nobody assigned means every open processing drops.
static func _release_orphans() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if lead.worked_by == "" :
			continue
		if _rep_available(lead.worked_by):
			continue
		_drop_processing(lead)


static func _rep_available(rep_id: String) -> bool:
	for c in HRSystem.assigned_to(HRConstants.AREA_SALES):
		if (c as Character).id == rep_id:
			return true
	return false


static func _drop_processing(lead: Prospect) -> void:
	lead.worked_by = ""
	lead.work_started_day = -1
	lead.work_due_day = -1
	lead.work_stance = ""
	# The lead returns to the ordinary waiting rules with a full clock — the freeze it enjoyed
	# while it was being worked was never time it spent waiting.
	lead.expires_on_day = GameState.day + SalesConstants.LEAD_LIFE_DAYS


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
	var out: Array = []
	for star in range(SalesConstants.STAR_MIN, own + 1):
		out.append(star)
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
## bitmek üzere olan." Reserved leads are skipped outright — that desk is the founder's.
static func pick_lead_for(rep: Character) -> Prospect:
	var ceiling: int = band_ceiling(rep)
	var best: Prospect = null
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if lead.is_being_worked() or lead.star > ceiling:
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
	lead.work_due_day = GameState.day + processing_days(rep, lead, lead.work_stance)
	# NO `lead_routed` HERE. That signal is the PLAYER's verb ("Temsilciye ver") and its one
	# publisher is SalesLedger.set_routing; a desk picking work up on its own is a different
	# event and borrowing the name would give one signal two meanings and two emitters (§14).


# ============================================================================
#  §7.2 · Processing duration
# ============================================================================

## League difference picks the span (§7.2: own league 6-7 · one below 3-4 · two below 2-3),
## and the rep's EFFECTIVE OUTPUT places the deal inside it. Reading `hr.effective_skill`
## rather than a raw star is the whole point: morale, focus, hours and traits already live in
## that one formula (Ekip §4.5) and this desk does not get a second copy of it.
static func processing_days(rep: Character, lead: Prospect, stance: String) -> int:
	var span: Array = SalesConstants.process_span(lead.star - rep_star(rep))
	var output: float = HRSystem.effective_skill(rep, HRConstants.AREA_SALES)
	var t: float = clampf(output / SalesConstants.PROCESS_REFERENCE_OUTPUT, 0.0, 1.0)
	# A better rep lands nearer the FAST end of the span.
	var days: float = lerpf(float(span[1]), float(span[0]), t)
	if stance == SalesConstants.STANCE_PREMIUM:
		days *= (1.0 + SalesConstants.PROCESS_PREMIUM_PENALTY)
	return maxi(int(round(days)), SalesConstants.PROCESS_MIN_DAYS)


static func _tick_processing() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if not lead.is_being_worked():
			continue
		if not _rep_available(lead.worked_by):
			_drop_processing(lead)
			continue
		var rep: Character = CharacterRegistry.get_character(lead.worked_by)
		if rep == null:
			_drop_processing(lead)
			continue
		# §7.6 — the price-break moment, in the closing days of a Premium deal against a
		# price-sensitive archetype. It publishes and does NOT raise a card (see the header).
		_maybe_price_break(rep, lead)
		if GameState.day >= lead.work_due_day:
			_close(rep, lead)


# ============================================================================
#  §7.6 · The close, and the price-break moment
# ============================================================================

## Is this deal in the window where the price-break card would drop? The whole predicate, so
## the event package can bind to one name when it wires the card.
static func price_break_due(rep: Character, lead: Prospect) -> bool:
	if lead.work_stance != SalesConstants.STANCE_PREMIUM:
		return false
	if not SalesArchetypes.is_price_sensitive(lead.archetype_id):
		return false   # "Duyarsız arketip kartı üretmez."
	var window: int = SalesConstants.PRICE_BREAK_TRIGGER_LAST_DAYS
	# HAYIR DİYEMEZ widens the window rather than rolling a die — same effect, no RNG.
	if HRConstants.trait_mult(rep.traits, "promise_chance_mult") > 1.0:
		window = int(round(float(window) * SalesConstants.PRICE_BREAK_CANT_SAY_NO_MULT))
	return GameState.day >= lead.work_due_day - window


static func _maybe_price_break(rep: Character, lead: Prospect) -> void:
	if not price_break_due(rep, lead):
		return
	if GameState.get_flag("sales_price_break_%s" % lead.id, false):
		return
	GameState.set_flag("sales_price_break_%s" % lead.id, true)
	# The SURFACE, published. The CARD (SalesConstants.PRICE_BREAK_CARD_ID) exists as data and
	# is never requested — §18 puts its wiring in the event package. Until then the deal
	# closes at its own stance, which is the conservative fallback: an unwired card must not
	# be able to strand a deal that is otherwise finished.
	EventBus.rep_discount_requested.emit(rep.id, lead.id)


static func _close(rep: Character, lead: Prospect) -> void:
	# §7.5 — the rep closes at THE DIAL's price. Their star does not touch it: "Temsilci
	# kadrandan kapatır; yıldızı fiyata dokunmaz."
	var seat_price: int = SalesLedger.seat_price_anchor(lead.work_stance)
	var seats: int = _seats_for(lead)
	var c: Customer = SalesSystem.add_b2b_customer(lead, seats, seat_price,
		PitchSystem.signing_satisfaction_seed(), "sales_rep:%s" % rep.id)
	ProspectRegistry.remove(lead.id)
	GameState.flags.erase("sales_price_break_%s" % lead.id)
	GameState.set_flag("sales_weekly_closes",
		int(GameState.get_flag("sales_weekly_closes", 0)) + 1)
	SalesSystem.record_sales_event("auto_close", rep.character_name, c.company_name, c.mrr)
	EventBus.rep_deal_closed.emit(rep.id, c.id)
	_maybe_ticker(c, rep.character_name)


# DESIGN-PARKED: §5.3's seat band is settled AT A TABLE, and a rep's deal has no table.
# The midpoint is the neutral reading. Alternatives seen: scale with the rep's star (§7.5
# forbids it — "yıldızı fiyata dokunmaz"), or draw it (no RNG on this desk, by §7.6's own
# argument that a close is work rather than a coin flip).
# DESIGN-PARKED: §5.3's seat band is settled AT A TABLE, and a rep's deal has no table.
# The midpoint is the neutral reading. Alternatives seen: scale with the rep's star (§7.5
# forbids it — "yıldızı fiyata dokunmaz"), or draw it (no RNG on this desk, by §7.6's own
# argument that a close is work rather than a coin flip).
## §5.3 — seats come from the star band, never from a negotiation. A rep's deal takes the
## MIDDLE of the band: the player did not sit at that table, so there is nothing to have
## played well or badly.
static func _seats_for(lead: Prospect) -> int:
	var band: Dictionary = SalesConstants.seat_band(lead.star)
	return int(round((float(band["low"]) + float(band["high"])) * 0.5))


## §7.3 — "Ticker yalnız haber değeri görür. Rutin kapanışlar girmez." Newsworthy is a
## league-above signing, a whale, or the run's first 3★.
static func _maybe_ticker(c: Customer, rep_name: String) -> void:
	var newsworthy: bool = c.scale >= SalesConstants.TICKER_NEWSWORTHY_STAR \
		or c.scale > SalesFaucetSystem.reach_band()
	if not newsworthy:
		return
	EventBus.headline_added.emit(B2BConstants.notice_source_sales(),
		TranslationServer.translate("SALES_TICKER_SIGNED").format(
			{"rep": rep_name, "company": c.company_name}))


# ============================================================================
#  §7.3 · The weekly summary
# ============================================================================

# DESIGN-PARKED: a week with no closes drops NO card. §7.3 says the summary carries closes;
# a card that reports none is a card that reports nothing. Alternative seen: always drop it
# with a "no closes this week" line — noise, and the quiet-day floor is the engine's job
# (§13.6), not this desk's.
# DESIGN-PARKED: a week with no closes drops NO card. §7.3 says the summary carries closes;
# a card that reports none is a card that reports nothing. Alternative seen: always drop it
# with a "no closes this week" line — noise, and the quiet-day floor is the engine's job
# (§13.6), not this desk's.
## "Haftalık satış özeti yalnız kapanışları taşır — temsilcinin sesiyle bilgi kartı. Churn
## girmez. Karar butonu yok." Raised through the one door (EventGate.request), the way the
## Sales tab already raises retention — the gate still runs G1-G8 over it.
static func _tick_weekly_summary() -> void:
	var anchor: int = int(GameState.get_flag("sales_weekly_anchor_day", 0))
	if anchor <= 0:
		GameState.set_flag("sales_weekly_anchor_day", GameState.day)
		return
	if GameState.day - anchor < SalesConstants.WEEKLY_SUMMARY_INTERVAL_DAYS:
		return
	var closes: int = int(GameState.get_flag("sales_weekly_closes", 0))
	GameState.set_flag("sales_weekly_anchor_day", GameState.day)
	GameState.set_flag("sales_weekly_closes", 0)
	if closes <= 0:
		return   # a quiet week is not a report; §13.6's floor is the engine's job, not ours
	EventBus.weekly_sales_report_issued.emit(closes)
	EventGate.request(SalesConstants.WEEKLY_SUMMARY_CARD_ID, {"closes": closes})


# ============================================================================
#  Reads for the pipeline panel
# ============================================================================

## "Palmiye ile görüşüyor · 3. gün" — the panel's line, as data. Day counting is INCLUSIVE
## (the first day reads as day 1), which is how a person would say it.
static func processing_view(rep: Character) -> Dictionary:
	var lead_id: String = SalesLedger.rep_busy(rep.id)
	if lead_id == "":
		return {}
	var lead: Prospect = ProspectRegistry.get_prospect(lead_id)
	if lead == null:
		return {}
	return {
		"lead_id": lead.id,
		"company_name": lead.company_name,
		"day": GameState.day - lead.work_started_day + 1,
		"due_day": lead.work_due_day,
		"stance": lead.work_stance,
	}
