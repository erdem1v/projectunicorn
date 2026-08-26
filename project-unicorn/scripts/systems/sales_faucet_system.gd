class_name SalesFaucetSystem
extends RefCounted

# THE MARKET FAUCET (§3) and the pipeline's clock (§4). Pure static logic, no scene
# dependency. Dispatched daily from B2BSalesSystem.daily_tick, BEFORE the rep desk, so a rep
# starting work today can pick up a lead that arrived today.
#
# THE BUTTON IS DEAD (§3, §19). "Aday bul" spawned 2 leads every 5 days whether or not anyone
# was selling, which made sales capacity decorative: hiring raised supply and never capped
# what the player could work. The faucet reads three things instead — assigned sales capacity,
# interest, and phase — and it never dries: with zero sales staff a base inbound continues,
# and the 1★ band carries a hard floor under every multiplier (§3).
#
# THE POOL NEVER EXHAUSTS (§3). Names come from SalesNamePool, which is the curated 65 plus a
# generated majority; the 65-name catalogue's SOLE-SUPPLY role is what §19 retired, not the
# catalogue. Signing removes a name for the run; an expired company comes back after its
# return lock (§4) as ITSELF, which is why the lock is keyed by name rather than consuming one.
#
# THE MARKET GUARD (§3.1) IS CHECKED HERE TOO. SalesSystem.daily_tick already gates the whole
# B2B desk on a live B2B product, and this file re-asks. The duplication is deliberate: the
# guard is the answer to the audit's root-cause (b) — a consumer run must produce ZERO B2B
# leads — and a second reader costs one comparison a day.
#
# NO RNG. Every draw is integer arithmetic over the run seed and the day, the house pattern
# from HRCandidateGenerator._mix. Two runs with the same seed meet the same companies in the
# same order, which is what makes the pipeline reproducible across a save/load.

const MIX_MODULUS := 1000003
const MIX_MULTIPLIER := 48271
const MIX_INCREMENT := 12345
const MIX_SALT_STRIDE := 7919
const SALT_STAR := 307
const SALT_ARCHETYPE := 311
const SALT_SECTOR := 313
const SALT_NAME := 317

# Legacy size ids the event catalogue still speaks (`add_prospect` cards were authored
# against the retired three-tier ordinal). Mapped, not honoured: the star is the truth now.
const LEGACY_SIZE_TO_STAR := {"small": 1, "mid": 2, "enterprise": 3}


# ============================================================================
#  Daily entry
# ============================================================================

static func daily_tick() -> void:
	if not _market_open():
		return
	_tick_expiry()
	_tick_return_locks()
	_tick_whale_conditions()
	_tick_inflow()


## §3.1 — the faucet and the whole B2B pipeline run only behind a LIVE B2B product.
static func market_open() -> bool:
	return _market_open()


static func _market_open() -> bool:
	return GameState.get_flag("mvp_shipped", false) and SalesSystem.is_b2b_market()


# ============================================================================
#  §4 — lead life and the return lock
# ============================================================================

static func _tick_expiry() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		# §12 — "İşlenen lead | sayacı donar." A lead on a rep's desk does not age; the
		# expiry day is pushed with the work so nothing accumulates behind the freeze.
		if lead.is_being_worked():
			lead.expires_on_day = GameState.day + SalesConstants.LEAD_LIFE_DAYS
			continue
		if GameState.day < lead.expires_on_day:
			continue
		# §4 — "süre dolunca dürüst düşer". The line is honest and the return is TRACELESS:
		# no memory, no penalty, only a lock on how soon this company can come back.
		_lock_return(lead.company_name, SalesConstants.RETURN_LOCK_DAYS)
		# The card disappears with the lead, so the sentence has to survive it somewhere the
		# player can still read. The activity log is that place — an expiry the player never
		# sees is an untelegraphed loss, and the line is the telegraph.
		SalesSystem.record_sales_event("lead_expired", "", lead.company_name, 0)
		EventBus.lead_expired.emit(lead.id)
		ProspectRegistry.remove(lead.id)


static func _tick_return_locks() -> void:
	var locks: Dictionary = GameState.sales_return_locks
	var expired: Array = []
	for name in locks.keys():
		if GameState.day >= int(locks[name]):
			expired.append(name)
	for name in expired:
		locks.erase(name)


# DESIGN-PARKED: a satisfied whale condition is CLEARED from the live card and announced
# once. §8 rules that a met item is never demanded, and that reads as a rule about the demand
# rather than only about the draw. Alternative seen: announce only at the signature, which
# never tells the player the door opened.
## §8 — the whale's condition is a DOOR, and the moment it opens is worth saying out loud.
## A satisfied item is cleared from the card (the GDD's "karşılanmış şart istenmez" applies to
## a live lead too, not only to a fresh one) and the signal fires exactly once, because the
## condition is cleared in the same pass that emits it.
static func _tick_whale_conditions() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if not lead.is_whale or lead.whale_condition == "":
			continue
		if not _condition_met(lead.whale_condition, lead):
			continue
		lead.whale_condition = ""
		EventBus.whale_condition_met.emit(lead.id)


## Hold a company out of the pool until `days` have passed. Used by expiry (§4), by a walked
## negotiation (§5.3) and by the price-break refusal (§7.6) — three sources, one ledger.
static func lock_return(company_name: String, days: int) -> void:
	_lock_return(company_name, days)


static func _lock_return(company_name: String, days: int) -> void:
	if company_name == "":
		return
	var until: int = GameState.day + maxi(days, 1)
	var locks: Dictionary = GameState.sales_return_locks
	locks[company_name] = maxi(int(locks.get(company_name, 0)), until)


static func is_return_locked(company_name: String) -> bool:
	return GameState.day < int(GameState.sales_return_locks.get(company_name, 0))


# ============================================================================
#  §3 — the flow
# ============================================================================

## Assigned sales capacity: everyone on the Satış job who can work today. The founder counts
## when assigned, exactly like anyone else — §3's "atanmış satış kapasitesi" is an ASSIGNMENT
## question, never a job title one (Ekip §12.0).
static func assigned_rep_count() -> int:
	return HRSystem.assigned_to(HRConstants.AREA_SALES).size()


## Leads per day before the daily cap. PUBLIC so the pipeline panel and the smoke suite read
## the same number the tick uses — the old desk's `lead_rate_per_day` had no UI caller and
## drifted out of anyone's sight.
static func lead_rate_per_day() -> float:
	var per_week: float = SalesConstants.FAUCET_BASE_PER_WEEK \
		+ SalesConstants.FAUCET_PER_REP_PER_WEEK * float(assigned_rep_count())
	var rate: float = per_week / SalesConstants.DAYS_PER_WEEK
	rate *= SalesConstants.interest_mult(ProductRead.interest())
	rate *= SalesConstants.phase_mult(GameState.phase)
	# §3 — "1★ akışı hiçbir durumda kurumaz." The floor sits UNDER the product of every
	# multiplier, so a stale version with no interest still meets someone.
	return maxf(rate, SalesConstants.ONE_STAR_FLOOR_PER_WEEK / SalesConstants.DAYS_PER_WEEK)


static func _tick_inflow() -> void:
	var progress: float = float(GameState.get_flag("sales_faucet_progress", 0.0)) \
		+ lead_rate_per_day()
	var emitted: int = 0
	while progress >= 1.0 and emitted < SalesConstants.FAUCET_DAILY_MAX:
		if spawn(_roll_star(emitted), "faucet") == null:
			break
		progress -= 1.0
		emitted += 1
	# Never bank more than one lead's worth: a slow week must not release a burst the moment
	# the player clears the column.
	GameState.set_flag("sales_faucet_progress", minf(progress, 1.0))


## §3 — the star mix, after the quality shifter has moved the top band's share.
static func star_mix_now() -> Array:
	var mix: Array = SalesConstants.star_mix(GameState.phase)
	var strength: float = product_strength()
	# "zayıf ürünle büyük balık kapıyı çalmaz": the top band keeps only a fraction of its
	# share, and what it loses falls to 1★ so the mix still sums to 1 without a second table.
	var t: float = clampf((strength - SalesConstants.QUALITY_STRENGTH_LOW)
		/ maxf(SalesConstants.QUALITY_STRENGTH_HIGH - SalesConstants.QUALITY_STRENGTH_LOW, 0.001),
		0.0, 1.0)
	var keep: float = lerpf(SalesConstants.QUALITY_SHIFT_FLOOR, 1.0, t)
	var top: float = float(mix[2])
	mix[2] = top * keep
	mix[0] = float(mix[0]) + top * (1.0 - keep)
	return mix


## How strong the shipped product reads against its market floors (Ürün §14). 1.0 means "on
## the bar"; the faucet's quality shifter is the only consumer, and it is a RATIO rather than
## a raw axis so a floor change moves both sides together.
static func product_strength() -> float:
	var floors: Dictionary = ProductRead.market_floors("b2b")
	var total: float = 0.0
	var n: int = 0
	for axis in floors.keys():
		var floor_v: float = maxf(float(floors[axis]), 1.0)
		total += float(ProductRead.axis_reading("", String(axis))) / floor_v
		n += 1
	return total / float(maxi(n, 1))


static func _roll_star(nth_today: int) -> int:
	var mix: Array = star_mix_now()
	var total: float = float(mix[0]) + float(mix[1]) + float(mix[2])
	if total <= 0.0:
		return SalesConstants.STAR_MIN
	var draw: float = float(_mix(_day_seed(nth_today), SALT_STAR) % 10000) / 10000.0 * total
	var acc: float = 0.0
	for i in 3:
		acc += float(mix[i])
		if draw < acc:
			return SalesConstants.STAR_MIN + i
	return SalesConstants.STAR_MAX


# ============================================================================
#  Spawning
# ============================================================================

## Create one lead. THE single creation path — the faucet, the event channel and every
## harness come through here, so a lead can never exist without a star, an archetype, a name
## and an expiry.
##
## Returns null when the market is shut or when the archetype's sectors somehow hold no free
## name; a caller that gets null has produced nothing and burned nothing.
static func spawn(star: int, source: String, archetype_hint: String = "") -> Prospect:
	if not _market_open():
		return null
	var s: int = clampi(star, SalesConstants.STAR_MIN, SalesConstants.STAR_MAX)
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var seed_base: int = _day_seed(GameState.run_prospects_spawned)

	var archetype: String = archetype_hint
	if archetype == "" or not SalesArchetypes.has(archetype):
		var pool: Array = SalesArchetypes.candidates_for(s, sub_id)
		if pool.is_empty():
			return null
		archetype = String(pool[_mix(seed_base, SALT_ARCHETYPE) % pool.size()])

	var excluded: Dictionary = _excluded_names()
	var sectors: Array = SalesArchetypes.sectors(archetype)
	var chosen_sector: String = ""
	var company: String = ""
	for offset in sectors.size():
		var sector: String = String(sectors[(_mix(seed_base, SALT_SECTOR) + offset) % sectors.size()])
		var name: String = SalesNamePool.take(sector, seed_base + offset, excluded)
		if name != "":
			chosen_sector = sector
			company = name
			break
	if company == "":
		return null

	var p := Prospect.new()
	GameState.run_prospects_spawned += 1
	p.id = "lead_%d_%d" % [GameState.day, GameState.run_prospects_spawned]   # LOC-DATA lead id
	p.company_name = company
	p.industry = chosen_sector
	p.star = s
	p.archetype_id = archetype
	p.spawned_on_day = GameState.day
	p.expires_on_day = GameState.day + SalesConstants.LEAD_LIFE_DAYS
	p.source = source
	# The feature this company wants, from the SAME picker the account side uses, so a
	# promise given at the table points at the same kind of thing a retention promise does
	# and the CS request channel finds something real to ask for after the signature.
	p.pain_feature_id = B2BSalesSystem.pick_pain_feature(sub_id, GameState.run_prospects_spawned)
	# §9 — a company that walked out of a meeting remembers why, and the memory rides the new
	# lead so the blocker gate and the memory line have something to read.
	var memory: Dictionary = GameState.sales_account_memory.get(company, {}) as Dictionary
	p.last_loss_reason = String(memory.get("loss_reason", ""))
	p.loss_count = int(memory.get("loss_count", 0))
	# §8 — the whale hook. Relative by construction: one band above what the desk can reach.
	_seat_whale_condition(p)
	ProspectRegistry.add(p)
	EventBus.prospect_arrived.emit(p.id)
	return p


## §8 — "karşılanmış şart istenmez": walk the ordered list and take the FIRST UNMET item. If
## the whole list is satisfied the whale still comes, without a condition, and plays the
## negotiation hard (the negotiation profile reads `is_whale`, not the condition).
static func _seat_whale_condition(p: Prospect) -> void:
	var order: Array = SalesArchetypes.conditions(p.archetype_id)
	if order.is_empty() or p.star <= reach_band():
		return
	p.is_whale = true
	for cond in order:
		if not _condition_met(String(cond), p):
			p.whale_condition = String(cond)
			return


static func _condition_met(condition: String, p: Prospect) -> bool:
	match condition:
		SalesConstants.WHALE_COND_PROVIDER:
			# Ürün §10 already owns this exact question, including the security_cert path.
			return not InfraSystem.blocks_enterprise_signature()
		SalesConstants.WHALE_COND_LOCKED_TIER:
			return _next_locked_step(p) == ""
		SalesConstants.WHALE_COND_SLA:
			# An SLA promise is met while one is open against this account's own company.
			return PromiseRegistry.has_open_for("co_" + p.id)
	return true


## The first line whose next step exists and is NOT unlockable — the "kilitli üst kademe" a
## whale asks for (§8, Ürün §15). "" when every open line's next step is reachable.
static func _next_locked_step(p: Prospect) -> String:
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	for line_id in ProductLines.line_ids(sub_id):
		var step_id: String = ProductRead.line_next_step("", String(line_id))
		if step_id != "" and not ProductRead.step_unlockable(step_id):
			return step_id
	return ""


## §8 — the band the desk can reach today: the best Satış star between the founder and the
## sales roster. Derived, never stored (§13 "Erişim bandı türetilir, saklanmaz").
static func reach_band() -> int:
	var best: int = int(HRConstants.stars_for(GameState.get_founder_skill(HRConstants.AREA_SALES)))
	for c in HRSystem.assigned_to(HRConstants.AREA_SALES):
		best = maxi(best, int(HRConstants.stars_for(HRSystem.skill(c as Character, HRConstants.AREA_SALES))))
	return maxi(best, 1)


# ============================================================================
#  Helpers
# ============================================================================

## Names the faucet may not offer: signed this run, already live in the pipeline, or inside a
## return lock. One set, three sources, so the picker and any predicate cannot disagree.
static func _excluded_names() -> Dictionary:
	var ex: Dictionary = {}
	for nm in GameState.b2b_signed_company_names:
		ex[nm] = true
	for nm in ProspectRegistry.get_company_names():
		ex[nm] = true
	for nm in GameState.sales_return_locks.keys():
		if GameState.day < int(GameState.sales_return_locks[nm]):
			ex[nm] = true
	return ex


static func _day_seed(salt: int) -> int:
	return GameState.run_seed + GameState.day * 7 + salt * 13


static func _mix(seed_value: int, salt: int) -> int:
	var n: int = (absi(seed_value) % MIX_MODULUS) + MIX_SALT_STRIDE * (absi(salt) % MIX_MODULUS)
	return absi((n * MIX_MULTIPLIER + MIX_INCREMENT) % MIX_MODULUS)
