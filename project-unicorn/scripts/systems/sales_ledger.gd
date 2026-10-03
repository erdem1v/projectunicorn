class_name SalesLedger
extends RefCounted

# THE SALES READ SURFACE (§14) AND THE MODULE'S OWN WRITE SEAMS.
#
# The engine's §6.4 makes a named read surface a standard clause of every module, and this is
# Sales': every name in §14 resolves here, the names are STABLE, and a changed meaning gets a
# new name rather than a quiet redefinition.
#
# IT IS ALSO THE WRITE SIDE, and that is deliberate. §14's queries read run state that has no
# other owner — the price stance, the per-rep band cap, the week's meeting count, the loss log,
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


static func lead_weeks_left(lead_id: String) -> int:
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	return p.weeks_left() if p != null else 0


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


static func set_open_pitch_promise(account_id: String) -> void:
	GameState.set_flag("sales_open_pitch_promise", account_id)


static func clear_open_pitch_promise() -> void:
	GameState.set_flag("sales_open_pitch_promise", "")


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
## "First" is a run fact, not a book fact: a churned account leaves the registry but not the
## run, so the seating stamps the run's first 3★ id (SalesSystem.add_b2b_customer) and only that
## account reads as first.
static func is_newsworthy_signing(c: Customer, is_whale: bool) -> bool:
	if is_whale:
		return true
	if c.scale > SalesFaucetSystem.reach_band():
		return true
	if c.scale >= SalesConstants.TICKER_NEWSWORTHY_STAR:
		return String(GameState.get_flag("sales_first_top_star_id", "")) == c.id
	return false


## §7.3 — a newsworthy signing reaches the ticker and credits the brand. ONE home for both
## signing paths (the founder's table and the rep desk); each brings its own headline.
static func announce_signing(c: Customer, is_whale: bool, headline: String) -> void:
	if not is_newsworthy_signing(c, is_whale):
		return
	EventBus.headline_added.emit(B2BConstants.notice_source_sales(), headline)
	GameState.set_brand(GameState.brand + SalesConstants.PRESTIGE_SIGNING_BRAND)


## §8 — the live lead's unmet whale condition, "" when the company has no lead in the pipeline
## or its condition is met. The faucet seats and clears it on the Prospect itself.
static func whale_condition(account_key: String) -> String:
	for p in ProspectRegistry.get_all():
		if (p as Prospect).company_name == account_key:
			return (p as Prospect).whale_condition
	return ""


## §5.4 — the signing discount lives INSIDE the seat price and is visible as its own trace.
static func signing_discount(account_id: String) -> float:
	var c: Customer = CustomerRegistry.get_customer(account_id)
	return c.signing_discount if c != null else 0.0


static func seat_price(account_id: String) -> int:
	var c: Customer = CustomerRegistry.get_customer(account_id)
	return c.seat_price if c != null else 0


# ============================================================================
#  §5.0 · The week's meetings
# ============================================================================

## §5.0 — sales meetings held this week. The counter carries its tick, so a new week reads zero
## with no reset to run. Meetings sit in the working hours, where the tick is the week.
static func meetings_this_week() -> int:
	var week: Dictionary = GameState.sales_meetings_week
	return int(week.get("count", 0)) if int(week.get("tick", -1)) == GameState.day else 0


static func count_meeting() -> void:
	GameState.sales_meetings_week = {"tick": GameState.day, "count": meetings_this_week() + 1}


## §5.0 — the entry gate, in order: the night, too close to the end of the workday ("mesai
## bitimine 2 saatten az kala giriş kapalı, nedenli"), then the week's meeting cap. The workday
## is the founder's, whose end also stops the meeting's skip, and it may end at 24:00. Returns
## "" when entry is open, otherwise the CSV key naming the reason, so the caller never composes
## a sentence.
static func meeting_block_reason(lead_id: String) -> String:
	if not SalesFaucetSystem.market_open():
		return "SALES_BLOCK_NO_B2B"
	if not WorkHoursSystem.sitting_open(SalesConstants.MEETING_ENTRY_CUTOFF_HOURS):
		return "SALES_BLOCK_TOO_LATE"
	if meetings_this_week() >= SalesConstants.MEETINGS_PER_WEEK:
		return "SALES_BLOCK_WEEK_FULL"
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
# EACH CLOSE IS STAMPED AS IT SIGNS (company, star, seats, seat price, MRR, the closing rep)
# into the open window's rows. The capped activity log can lose a week's closes behind the next
# tick's expiries, and an account can churn before the report is read. When the window ends with
# a desk close, its rows become the week's report: SalesRepSystem posts them to the inbox as they
# stand, and the inbox draws its table from those rows whenever it is opened.

## One close into the open window, with the name of the rep who closed it, "" for the founder.
## The desk's closes raise the report and sign it; the name is stored, not looked up, because
## the rep can leave before the report is read. The founder's closes are listed beside them.
static func record_close(c: Customer, rep: String) -> void:
	var rows: Array = GameState.get_flag("sales_weekly_close_rows", [])
	rows.append({"company": c.company_name, "star": c.scale, "seats": c.seats,
		"price": c.seat_price, "mrr": c.mrr, "rep": rep})
	GameState.set_flag("sales_weekly_close_rows", rows)


## Ends the open window and returns its closes.
static func close_week() -> Array:
	var rows: Array = GameState.get_flag("sales_weekly_close_rows", [])
	GameState.set_flag("sales_weekly_close_rows", [])
	return rows

