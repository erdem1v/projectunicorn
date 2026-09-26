class_name SalesLedger
extends RefCounted

# THE SALES READ SURFACE (§14) AND THE MODULE'S OWN WRITE SEAMS.
#
# The engine's §6.4 makes a named read surface a standard clause of every module, and this is
# Sales': every name in §14 resolves here, the names are STABLE, and a changed meaning gets a
# new name rather than a quiet redefinition.
#
# IT IS ALSO THE WRITE SIDE, and that is deliberate. §14's queries read run state that has no
# other owner — the price stance, the per-rep band cap, the daily meeting right, the loss log,
# the account memory. Putting the getters somewhere and the setters somewhere else is how a
# field ends up written raw "just this once" (CLAUDE.md's WRITE-THROUGH LAW). One file, one
# vocabulary, and every setter that a surface reacts to emits.
#
# WHERE THE STATE ACTUALLY LIVES. On `GameState`, as typed vars and typed flags, which means
# SaveCodec's property walker carries all of it with no `_capture_systems` block and no hand
# written field list (§13). The defaults ARE the v10 → v11 migration.
#
# WHAT IS **NOT** HERE. Anything another module owns: seats and MRR are CustomerRegistry's,
# aggregate MRR is SalesSystem.reflect_mrr()'s, promises are PromiseRegistry's, effective
# output is hr.effective_skill's. §15's single-source table is binding and this file consumes
# it rather than mirroring it.


# ============================================================================
#  §14 · Pipeline
# ============================================================================

static func pipeline_count() -> int:
	return ProspectRegistry.count()


static func lead_star(lead_id: String) -> int:
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	return p.star if p != null else 0


static func lead_days_left(lead_id: String) -> int:
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	return p.days_left() if p != null else 0


static func lead_routing(lead_id: String) -> String:
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	return p.routing if p != null else SalesConstants.ROUTE_NONE


## §7.2.1 — "Ayır" (the desk is the founder's) and "Temsilciye ver" (first in the band queue).
## Reserving does NOT stop the clock (§7.2.1: "Rezerv süreyi durdurmaz").
static func set_routing(lead_id: String, routing: String) -> void:
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	if p == null or p.routing == routing:
		return
	p.routing = routing
	if routing == SalesConstants.ROUTE_RESERVED:
		EventBus.lead_reserved.emit(lead_id)
	elif routing == SalesConstants.ROUTE_REP:
		EventBus.lead_routed.emit(lead_id)


static func reach_band() -> int:
	return SalesFaucetSystem.reach_band()


# ============================================================================
#  §14 · The rep desk
# ============================================================================

## §7.2.2 — the per-rep working band cap. -1 is "Kendi ligi" and is the DEFAULT, which is why
## the absence of a stored value is not a gap to fill but the answer itself.
static func rep_band_cap(person_id: String) -> int:
	return int(GameState.sales_band_caps.get(person_id, SalesConstants.BAND_CAP_OWN_LEAGUE))


static func set_rep_band_cap(person_id: String, cap: int) -> void:
	if rep_band_cap(person_id) == cap:
		return
	if cap == SalesConstants.BAND_CAP_OWN_LEAGUE:
		GameState.sales_band_caps.erase(person_id)
	else:
		GameState.sales_band_caps[person_id] = clampi(cap, SalesConstants.STAR_MIN, SalesConstants.STAR_MAX)
	EventBus.rep_band_cap_changed.emit(person_id)


## §7.2 — is this rep on a lead right now, and which one. "" = free.
static func rep_busy(person_id: String) -> String:
	for p in ProspectRegistry.get_all():
		if (p as Prospect).worked_by == person_id:
			return (p as Prospect).id
	return ""


# ============================================================================
#  §14 · Price (§7.5 — the dial is the SINGLE B2B price source)
# ============================================================================

static func price_stance() -> String:
	var s: String = String(GameState.get_flag("sales_price_stance", SalesConstants.STANCE_DEFAULT))
	return s if SalesConstants.STANCES.has(s) else SalesConstants.STANCE_DEFAULT


static func set_price_stance(stance: String) -> void:
	if not SalesConstants.STANCES.has(stance) or stance == price_stance():
		return
	GameState.set_flag("sales_price_stance", stance)
	EventBus.price_stance_changed.emit(stance)


## The seat-price anchor the dial produces: the middle of the band, moved by the stance.
## Act 2 opens here, the rep desk closes here and the pipeline projection prices here — one
## number (§15).
static func seat_price_anchor(stance: String = "") -> int:
	var st: String = stance if stance != "" else price_stance()
	var mid: float = float(SalesConstants.SEAT_PRICE_MIN + SalesConstants.SEAT_PRICE_MAX) * 0.5
	return int(round(mid * SalesConstants.stance_mult(st)))


# ============================================================================
#  §14 · Promises (§6)
# ============================================================================

## §6 — "Tek açık pitch sözü". The id of the account holding the open PITCH promise, or "".
## Retention promises live in the same Registry on a separate counter and never appear here.
static func open_pitch_promise() -> String:
	return String(GameState.get_flag("sales_open_pitch_promise", ""))


static func open_pitch_promise_feature() -> String:
	return String(GameState.get_flag("sales_open_pitch_feature", ""))


static func set_open_pitch_promise(account_id: String, feature_id: String) -> void:
	GameState.set_flag("sales_open_pitch_promise", account_id)
	GameState.set_flag("sales_open_pitch_feature", feature_id)


static func clear_open_pitch_promise() -> void:
	GameState.set_flag("sales_open_pitch_promise", "")
	GameState.set_flag("sales_open_pitch_feature", "")


## §6 — a BROKEN promise locks the row on that account for the rest of the run.
static func promise_locked_for(account_key: String) -> bool:
	return bool(_memory(account_key).get("promise_broken", false))


# ============================================================================
#  §5.2 · Loss — the named reason, the account memory, the log
# ============================================================================

## The one loss seam (§5.2 "sales.report_loss(hesap, neden-türü, hedef)"). It writes the
## account's memory AND the run's log, and it emits — the demand generator arrives with the
## event package and will read the log it finds already full (§5.2 "depo-öncesi").
##
## A loss produces NO economic delta (§5.2). Nothing here touches cash, MRR or brand.
static func report_loss(account_key: String, reason_type: String, target: String) -> void:
	var mem: Dictionary = _memory(account_key)
	mem["loss_reason"] = reason_type
	mem["loss_target"] = target
	mem["loss_count"] = int(mem.get("loss_count", 0)) + 1
	mem["loss_day"] = GameState.day
	GameState.sales_account_memory[account_key] = mem
	GameState.sales_loss_log.append({
		"day": GameState.day, "account": account_key,
		"reason": reason_type, "target": target,
	})
	EventBus.meeting_lost.emit(account_key, reason_type)


static func loss_reason(account_key: String) -> String:
	return String(_memory(account_key).get("loss_reason", ""))


static func loss_count(account_key: String) -> int:
	return int(_memory(account_key).get("loss_count", 0))


## The whole log, newest last. Deliberately UNPRUNED: it is a buffer for a reader that has not
## shipped yet, and a trimmed buffer would silently answer a question it was never asked.
static func loss_log() -> Array:
	return GameState.sales_loss_log.duplicate(true)


## §5.3 — a table tipped over on purpose is remembered.
static func record_insult(account_key: String) -> void:
	var mem: Dictionary = _memory(account_key)
	mem["insulted"] = true
	mem["insult_day"] = GameState.day
	GameState.sales_account_memory[account_key] = mem


static func was_insulted(account_key: String) -> bool:
	return bool(_memory(account_key).get("insulted", false))


static func record_broken_promise(account_key: String) -> void:
	var mem: Dictionary = _memory(account_key)
	mem["promise_broken"] = true
	GameState.sales_account_memory[account_key] = mem


static func _memory(account_key: String) -> Dictionary:
	return (GameState.sales_account_memory.get(account_key, {}) as Dictionary).duplicate()


# ============================================================================
#  §14 · Deals
# ============================================================================

static func deal_count(star: int) -> int:
	var n: int = 0
	for c in CustomerRegistry.get_by_market("b2b"):
		if (c as Customer).scale == star:
			n += 1
	return n


static func last_signed_star() -> int:
	return int(GameState.get_flag("sales_last_signed_star", 0))


## §7.3 — "Ticker yalnız haber değeri görür. Rutin kapanışlar girmez." ONE HOME for the rule,
## read by both signing paths. §7.3 names three things and this names the same three:
##   above-league   the signing reached past the desk's reach band
##   whale          the account the run was telegraphing
##   first 3★       the FIRST one, once, because the second is no longer news
##
## "First" is read from the book: the customer is already seated when this is asked, so it is
## the first while it is the only ACTIVE 3★ account (a churned account leaves the registry).
static func is_newsworthy_signing(c: Customer, is_whale: bool) -> bool:
	if is_whale:
		return true
	if c.scale > SalesFaucetSystem.reach_band():
		return true
	if c.scale >= SalesConstants.TICKER_NEWSWORTHY_STAR:
		return deal_count(c.scale) <= 1
	return false


## §7.3 — a newsworthy signing reaches the ticker and credits the brand. ONE home for both
## signing paths (the founder's table and the rep desk); each brings its own headline.
static func announce_signing(c: Customer, is_whale: bool, headline: String) -> void:
	if not is_newsworthy_signing(c, is_whale):
		return
	EventBus.headline_added.emit(B2BConstants.notice_source_sales(), headline)
	GameState.set_brand(GameState.brand + SalesConstants.PRESTIGE_SIGNING_BRAND)


static func whale_condition(account_key: String) -> String:
	return String(_memory(account_key).get("whale_condition", ""))


## §5.4 — the signing discount lives INSIDE the seat price and is visible as its own trace.
static func signing_discount(account_id: String) -> float:
	var c: Customer = CustomerRegistry.get_customer(account_id)
	return c.signing_discount if c != null else 0.0


static func seat_price(account_id: String) -> int:
	var c: Customer = CustomerRegistry.get_customer(account_id)
	return c.seat_price if c != null else 0


# ============================================================================
#  §5.0 · The daily meeting right
# ============================================================================

## §5.0 — "kurucu günde bir toplantıya girer; hak her mesai başında yenilenir." Stored as the
## DAY the right was spent rather than a boolean, so the refresh needs no tick to run: a new
## day simply stops matching.
static func meeting_available_today() -> bool:
	return int(GameState.get_flag("sales_meeting_used_day", -1)) != GameState.day


static func consume_meeting_right() -> void:
	GameState.set_flag("sales_meeting_used_day", GameState.day)


## §5.0 — "mesai bitimine 2 saatten az kala giriş kapalı, nedenli." Returns "" when entry is
## open, otherwise the CSV key naming the reason, so the caller never composes a sentence.
static func meeting_block_reason(lead_id: String) -> String:
	if not SalesFaucetSystem.market_open():
		return "SALES_BLOCK_NO_B2B"
	if not meeting_available_today():
		return "SALES_BLOCK_MEETING_SPENT"
	if GameState.current_hour > SalesConstants.WORKDAY_END_HOUR - SalesConstants.MEETING_ENTRY_CUTOFF_HOURS:
		return "SALES_BLOCK_TOO_LATE"
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	if p == null:
		return "SALES_BLOCK_NO_LEAD"
	if p.is_being_worked():
		return ""   # §12 — the founder outranks a rep; the processing simply drops
	# §9 — the re-pitch blocker gate. An unchanged reason gives an unchanged answer, and the
	# door says which one.
	if p.loss_count > 0 and p.last_loss_reason != "" and not _blocker_cleared(p):
		return "SALES_BLOCK_REASON_UNCHANGED"
	return ""


## §9 — has the named reason actually moved since the loss? Each reason type names the query
## that would have to change; anything not listed clears on its own (the writing round refines
## the taxonomy, and an unrecognised id must never lock a door forever).
static func _blocker_cleared(p: Prospect) -> bool:
	match p.last_loss_reason:
		SalesConstants.LOSS_STABILITY:
			return ProductRead.axis_reading("", "stability") >= 55 and ProductRead.confirmed_open() <= 2
		SalesConstants.LOSS_MISSING_TIER:
			return SalesProbes.locked_line() == ""
		SalesConstants.LOSS_PROVIDER_TRUST:
			return not InfraSystem.blocks_enterprise_signature()
		SalesConstants.LOSS_PRICE:
			return price_stance() == SalesConstants.STANCE_COMPETITIVE
		SalesConstants.LOSS_SWITCHING_RISK:
			return not HRSystem.assigned_to(HRConstants.AREA_CUSTOMER_SUCCESS).is_empty()
	return true


# ============================================================================
#  §5.1.1 · The inner-voice budget
# ============================================================================

static func inner_voice_left() -> int:
	return maxi(SalesConstants.INNER_VOICE_BUDGET_PER_RUN
		- int(GameState.get_flag("sales_inner_voice_used", 0)), 0)


static func spend_inner_voice() -> void:
	GameState.set_flag("sales_inner_voice_used",
		int(GameState.get_flag("sales_inner_voice_used", 0)) + 1)


# ============================================================================
#  §7.3 · The weekly summary's ROWS
# ============================================================================
#
# §7.3 asks for the week's CLOSES, and a summary with no rows summarises nothing.
#
# COMPOSED HERE, NOT IN THE CARD, because the card is data: it names one seam and the
# arithmetic stays in the module that owns it. `GameState.sales_log` carries the close events
# (day, kind, company, mrr); the star, the seat count and the seat price come off the account
# those closes produced, which is the only place they are stamped (§5.4).
#
# STATIC → `TranslationServer.translate`, never `tr()`: a static has no node to resolve
# against, and `loc_residue` fails the build on it ([static-tr]).

const WEEKLY_WINDOW_DAYS := 7
const CLOSE_KINDS := ["auto_close", "founder_close"]


## The week's closes, one line each, plus a total. "" when the week closed nothing — the card
## itself is not raised on an empty week (§7.3), so this is the belt to that braces.
static func weekly_close_lines() -> String:
	var since: int = GameState.day - WEEKLY_WINDOW_DAYS
	var rows: PackedStringArray = []
	var total: int = 0
	for entry in SalesSystem.get_sales_log():
		var e: Dictionary = entry as Dictionary
		if int(e.get("day", 0)) <= since or not CLOSE_KINDS.has(String(e.get("kind", ""))):
			continue
		var company: String = String(e.get("company", ""))
		var mrr: int = int(e.get("mrr", 0))
		var acct: Customer = _account_of(company)
		total += mrr
		rows.append(TranslationServer.translate("SALES_WEEKLY_ROW").format({
			"company": company,
			"stars": _star_text(acct.scale if acct != null else 0),
			"seats": acct.seats if acct != null else 0,
			"price": Fmt.money_exact(acct.seat_price if acct != null else 0),
			"mrr": Fmt.money_exact(mrr),
		}))
	if rows.is_empty():
		return ""
	rows.append(TranslationServer.translate("SALES_WEEKLY_TOTAL").format({
		"n": rows.size(), "mrr": Fmt.money_exact(total)}))
	return "\n".join(rows)


## Always STAR_MAX glyphs, filled then "·" — a row that shrinks with the star turns a table
## into a ragged edge.
static func _star_text(star: int) -> String:
	var filled: int = clampi(star, 0, SalesConstants.STAR_MAX)
	return StarRating.FILLED.repeat(filled) + "·".repeat(SalesConstants.STAR_MAX - filled)


static func _account_of(company: String) -> Customer:
	for c in CustomerRegistry.get_by_market("b2b"):
		if (c as Customer).company_name == company:
			return c as Customer
	return null
