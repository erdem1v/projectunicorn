class_name SalesRepSystem
extends RefCounted

# THE SALES DESK (§7) — what an assigned Satış Temsilcisi actually does. Pure static logic,
# no scene dependency. Dispatched daily from B2BSalesSystem.daily_tick, LAST, after the
# faucet: a close creates a Customer and a same-day-signed account must not be lifecycle
# ticked on its own signing day.
#
# Supply is the faucet's (§3). A rep works ONE lead at a time and the pipeline says which one
# (§7.2). The ceiling is a STAR: a rep sells at or below their own Satış star and cannot reach
# above it (§7.1), a gate the player can see on the card.
#
# AN IN-LEAGUE DEAL ALWAYS CLOSES (§7.6); only WHEN is drawn. Each processing tick rolls the
# league's close chance (PROCESS_CLOSE_CHANCE) on the seeded `sales_rep` stream, because a
# week-long tick is too coarse to hold a duration of a few days. Premium is the one conditional:
# it divides the chance and, on a price-sensitive archetype, produces the price-break moment (§7.6).
#
# THE PRICE-BREAK CARD IS DEFINED AND INERT. Its behaviour and its trigger live here, and the
# moment publishes `rep_discount_requested`. What does NOT happen is `EventGate.request` — the
# wiring is the event package's (§18), and until it lands the deal closes at its own stance.
# That is a stated fallback, not an accident: an inert card must not be able to strand a deal.
#
# THE ADDITIVITY INVARIANT, desk half: with nobody on Satış nothing is worked — any open
# processing drops, and no lead is started or closed.


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
	# NO `lead_routed` HERE. That signal is the PLAYER's verb ("Temsilciye ver") and its one
	# publisher is SalesLedger.set_routing; a desk picking work up on its own is a different
	# event and borrowing the name would give one signal two meanings and two emitters (§14).


# ============================================================================
#  §7.2 · Processing
# ============================================================================

## The chance this deal closes on one processing tick: the league difference picks it and
## Premium divides it, so the expected processing time grows by the same +30 %.
static func close_chance(rep: Character, lead: Prospect) -> float:
	var chance: float = float(SalesConstants.PROCESS_CLOSE_CHANCE[clampi(lead.star - rep_star(rep), -2, 0)])
	if lead.work_stance == SalesConstants.STANCE_PREMIUM:
		chance /= 1.0 + SalesConstants.PROCESS_PREMIUM_PENALTY
	return chance


## A lead started this tick is picked up after this sweep, so its first roll is the next tick.
static func _tick_processing() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if not lead.is_being_worked():
			continue
		var rep: Character = _assigned_rep(lead.worked_by)
		if rep == null:
			# §12 — "Temsilci ayrılır / izne çıkar | işleme düşer; lead bekleme kurallarına döner."
			_drop_processing(lead)
			continue
		# §7.6 — the price-break moment of a Premium deal against a price-sensitive archetype,
		# read before the roll. It publishes and does NOT raise a card (see the header).
		_maybe_price_break(rep, lead)
		if RngStreams.get_stream(RngStreams.STREAM_SALES_REP).randf() < close_chance(rep, lead):
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


static func _close(rep: Character, lead: Prospect) -> void:
	# §7.5 — the rep closes at THE DIAL's price. Their star does not touch it: "Temsilci
	# kadrandan kapatır; yıldızı fiyata dokunmaz."
	var seat_price: int = SalesLedger.seat_price_anchor(lead.work_stance)
	var seats: int = _seats_for(lead)
	var c: Customer = SalesSystem.add_b2b_customer(lead, seats, seat_price,
		SalesSystem.signing_satisfaction_seed(), "sales_rep:%s" % rep.id)
	ProspectRegistry.remove(lead.id)
	SalesLedger.record_close(c, true)
	SalesSystem.record_sales_event("auto_close", rep.character_name, c.company_name, c.mrr)
	EventBus.rep_deal_closed.emit(rep.id, c.id)
	SalesLedger.announce_signing(c, lead.is_whale,
		TranslationServer.translate("SALES_TICKER_SIGNED").format(
			{"rep": rep.character_name, "company": c.company_name}))


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
	if GameState.day - anchor < TimeModel.ticks(SalesConstants.WEEKLY_SUMMARY_INTERVAL_WEEKS):
		return
	GameState.set_flag("sales_weekly_anchor_day", GameState.day)
	var closes: int = SalesLedger.close_week()
	if closes <= 0:
		return
	EventBus.weekly_sales_report_issued.emit(closes)
	EventGate.request(SalesConstants.WEEKLY_SUMMARY_CARD_ID)


# ============================================================================
#  Reads for the pipeline panel
# ============================================================================

## "Palmiye ile görüşüyor · 2. hafta" — the panel's line, as data. Week counting is INCLUSIVE
## (the first week reads as week 1), which is how a person would say it.
static func processing_view(rep: Character) -> Dictionary:
	var lead_id: String = SalesLedger.rep_busy(rep.id)
	if lead_id == "":
		return {}
	var lead: Prospect = ProspectRegistry.get_prospect(lead_id)
	return {
		"lead_id": lead.id,
		"company_name": lead.company_name,
		"week": GameState.day - lead.work_started_day + 1,
		"stance": lead.work_stance,
	}
