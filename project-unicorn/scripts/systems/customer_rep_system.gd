class_name CustomerRepSystem
extends RefCounted

# The MÜŞTERİ MASASI — what a hired Müşteri Temsilcisi actually does (Task 2b). Pure static
# logic, no scene dependency. Two entry points, both dispatched from B2BSalesSystem.daily_tick:
# reconcile_assignments() before the lifecycle sweep, daily_tick() after it.
#
# THE ROLE HAS TWO JOBS, AND THEY ARRIVE AT DIFFERENT TIMES. This split is the whole design:
#
#   STEWARDSHIP  — assigned_to, which feeds B2BConstants.cs_dampen (slower erosion) and the
#                  rep's own escalation. CAPPED: the founder hands over only what exceeds
#                  FOUNDER_DIRECT_CAP, and only up to cs_capacity(HIZ) per rep. Delegation is
#                  a response to load, which is what that constant always claimed to mean.
#   TALEP KANALI — this file's daily_tick. UNCAPPED and covering the WHOLE customer book,
#                  founder-managed accounts included, from the rep's very first day. Without
#                  this a rep hired early would sit idle until the founder's fifth account,
#                  and an employee drawing salary for nothing is a dead hire.
#
# THE AREA (GDD v2 ch. 07 rev 2 §2, 2026-08-21). This desk reads exactly one number now —
# MÜŞTERİ BAŞARISI — because §2 gives that one area everything this file does: "bilet çözümü,
# memnuniyet, churn". It drives all four:
#   capacity     accounts one rep can steward           (B2BConstants.cs_capacity)
#   throughput   requests cleared per day               (throughput_of)
#   quality      churn dampening                        (B2BConstants.cs_dampen)
#   judgement    the absorb-vs-escalate valve           (absorb_ceiling)
# This USED to be a two-axis trade-off (HIZ bought volume, UZMANLIK bought quality) and it
# deliberately is not any more: rev 2 deleted Hız, and the trade-off moved OUT of the person
# and INTO the assignment layer — the real question is now who is on Hesap sahipliği at all,
# and what else you had to leave unstaffed to put them there (§4/§5).
#
# NO RNG — see SalesRepSystem's header for the reasoning; the same rule binds this file.
#
# THE ADDITIVITY INVARIANT: with no active Müşteri Temsilcisi, both entry points return before
# touching state, no request is ever generated, and the game behaves exactly as it did before
# Task 2b. Customers still reach the player through the existing complaint / retention /
# expansion families; the request desk is a SECOND resolution surface for the same
# dissatisfaction, and it only opens when somebody staffs it.


# --- The ranked desk ---

static func _ranked(axis: String) -> Array:
	# rev 2 §4: HESAP SAHİPLİĞİ işine atanmış herkes — rol değil atama. Bugün bir Müşteri
	# Temsilcisi işe alındığında bu işe otomatik konuyor, yani yukarıdaki additivity
	# invariant'ı birebir korunuyor. Kurucu bu masaya sayılmaz: onun doğrudan taşıdığı
	# hesaplar FOUNDER_DIRECT_CAP ile ayrı ölçülüyor (b2b_sales_system.founder_managed_count).
	var reps: Array = []
	for c in HRSystem.assigned_to(HRConstants.AREA_CUSTOMER_SUCCESS):
		if c.category == "employee":
			reps.append(c)
	reps.sort_custom(func(a: Character, b: Character) -> bool:
		var av: int = int(a.role_stats.get(axis, 0))
		var bv: int = int(b.role_stats.get(axis, 0))
		if av == bv:
			return a.id < b.id
		return av > bv)
	return reps


static func _top_expertise() -> int:
	var reps: Array = _ranked(HRConstants.AREA_CUSTOMER_SUCCESS)
	if reps.is_empty():
		return 0
	return int(reps[0].role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0))


static func _overtime_mult() -> float:
	# Exactly 1.0 with no Müşteri block running. Before Task 2b a player could start one and
	# pay for it in cash and morale for nothing — HROvertimeSystem.speed_multiplier was only
	# ever read with DEPT_PRODUCT_DEV. This is the customer desk's half of closing that.
	return HROvertimeSystem.speed_multiplier(HRConstants.DEPT_CUSTOMER)


static func throughput_of(rep: Character) -> float:
	# Requests one rep clears per day. Public so the UI and the smoke suite read the same
	# number the tick uses.
	if rep == null:
		return 0.0
	return B2BConstants.CS_THROUGHPUT_BASE \
		+ float(int(rep.role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0))) * B2BConstants.CS_THROUGHPUT_PER_PACE


static func desk_throughput() -> float:
	# Same rank-ordered diminishing stack as the sales desk: a second rep on one queue does not
	# double it. REP_STACK_DECAY is shared by both desks because the reason is the same — the
	# queue gets crowded, not the people worse.
	var total: float = 0.0
	var weight: float = 1.0
	for rep in _ranked(HRConstants.AREA_CUSTOMER_SUCCESS):
		total += weight * throughput_of(rep)
		weight *= B2BConstants.REP_STACK_DECAY
	return total * _overtime_mult()


# --- STEWARDSHIP: who holds which account ---

static func reconcile_assignments() -> void:
	# Release first, then fill: a rep who went on leave this morning frees their accounts
	# before anyone else's capacity is measured.
	_release_unheld()
	if CharacterRegistry.count_active_by_role(HRConstants.ROLE_CUSTOMER_REP) == 0:
		return
	_delegate_excess()


static func _release_unheld() -> void:
	# An account whose rep is gone, on leave, or beyond that rep's current capacity goes back
	# to the founder. Capacity can shrink under the account (a rep's HIZ never drops today, but
	# firing one does), so this is a reconcile rather than a one-way hand-off.
	# PINNED accounts (player-chosen) are kept first, so a manual assignment can never be the
	# one evicted by the capacity sweep — otherwise the player's choice would silently lose a
	# race against registry iteration order. A pin does NOT survive its rep leaving: that
	# releases the account AND clears the pin, so no dead pins accumulate.
	var held: Dictionary = {}   # rep id -> count already kept
	var book: Array[Customer] = CustomerRegistry.get_by_market("b2b")
	var ordered: Array[Customer] = []
	for c in book:
		if c.cs_pinned:
			ordered.append(c)
	for c in book:
		if not c.cs_pinned:
			ordered.append(c)
	for c in ordered:
		if c.assigned_to == "":
			continue
		var rep: Character = CharacterRegistry.get_character(c.assigned_to)
		if rep == null or rep.status != HRConstants.STATUS_ACTIVE:
			CustomerRegistry.assign_customer(c.id, "")   # pinned = false: the pin dies with it
			continue
		var cap: int = B2BConstants.cs_capacity(int(rep.role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0)))
		var kept: int = int(held.get(rep.id, 0))
		if kept >= cap:
			CustomerRegistry.assign_customer(c.id, "")
			continue
		held[rep.id] = kept + 1


static func _delegate_excess() -> void:
	# The founder hands over only what exceeds FOUNDER_DIRECT_CAP — delegation as a response to
	# load. Deliberately NOT "fill every rep to capacity on hire": that would take accounts the
	# founder is comfortably holding, and it would silently capture the founder-managed control
	# account that three existing smoke cases hold on purpose.
	var excess: int = B2BSalesSystem.founder_managed_count() - B2BConstants.FOUNDER_DIRECT_CAP
	if excess <= 0:
		return
	# Oldest first: the newest signing is the one the founder still has a relationship with.
	var pool: Array[Customer] = []
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to != "":
			continue
		if c.cs_pinned:
			continue   # the player deliberately parked this one on the founder's desk
		if not B2BConstants.CS_ASSIGNABLE_PHASES.has(c.lifecycle_phase):
			continue   # the founder onboards every new account personally
		pool.append(c)
	pool.sort_custom(func(a: Customer, b: Customer) -> bool:
		if a.acquired_on_day == b.acquired_on_day:
			return a.id < b.id
		return a.acquired_on_day < b.acquired_on_day)

	var free_slots: Array = []   # [rep, remaining]
	for rep in _ranked(HRConstants.AREA_CUSTOMER_SUCCESS):
		var cap: int = B2BConstants.cs_capacity(int(rep.role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0)))
		var remaining: int = cap - roster_size(rep.id)
		if remaining > 0:
			free_slots.append([rep, remaining])

	var handed: int = 0
	for slot in free_slots:
		var rep: Character = slot[0]
		var remaining: int = int(slot[1])
		while remaining > 0 and handed < excess and handed < pool.size():
			CustomerRegistry.assign_customer(pool[handed].id, rep.id)
			handed += 1
			remaining -= 1


## How many b2b accounts this rep currently stewards. Public because the HR card shows it
## next to cs_capacity() — the card computes nothing itself, every figure is an engine call.
static func roster_size(rep_id: String) -> int:
	var n: int = 0
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to == rep_id:
			n += 1
	return n


# --- TALEP KANALI: the request channel ---

static func daily_tick() -> void:
	if CharacterRegistry.count_active_by_role(HRConstants.ROLE_CUSTOMER_REP) == 0:
		return
	_open_due_requests()
	_work_the_queue()
	_escalate_stale()


static func _open_due_requests() -> void:
	# Deterministic cadence, phase-offset per account so the whole book does not file on the
	# same morning. One open request per customer at a time — the latch is
	# support_request_since_day itself, i.e. state this system owns, never a property of the
	# event (EventManager.enqueue bypasses one_shot and cooldown entirely).
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.support_request_since_day >= 0:
			continue
		if (GameState.day + c.cs_request_phase) % B2BConstants.CS_REQUEST_INTERVAL_DAYS != 0:
			continue
		CustomerRegistry.set_support_request(c.id, GameState.day)


static func _open_requests() -> Array[Customer]:
	# Oldest request first; account id breaks ties so the order never depends on dictionary
	# iteration order.
	var out: Array[Customer] = []
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.support_request_since_day >= 0:
			out.append(c)
	out.sort_custom(func(a: Customer, b: Customer) -> bool:
		if a.support_request_since_day == b.support_request_since_day:
			return a.id < b.id
		return a.support_request_since_day < b.support_request_since_day)
	return out


static func request_difficulty(c: Customer) -> int:
	# How hard this account's request is to satisfy without the founder. Every term is state
	# the player can already see or reason about: an unbuilt feature is a promise the desk
	# cannot make, an unhappy account argues, a bigger account expects more.
	var d: int = 1
	if c.pain_feature_id != "":
		var live: Array = GameState.get_flag("mvp_components", [])
		if not live.has(c.pain_feature_id):
			d += 2
	if c.satisfaction < c.tolerance:
		d += 2
	d += maxi(c.scale - 1, 0)
	return d


static func absorb_ceiling() -> int:
	# The UZMANLIK valve. At UZMANLIK 5 the ceiling is 7, which absorbs an unhappy scale-3
	# account asking for an unshipped feature (1+2+2+2); at UZMANLIK 4 that same request
	# reaches the player. Two-directional by construction.
	return B2BConstants.CS_ABSORB_BASE + _top_expertise()


static func _work_the_queue() -> void:
	var budget: float = float(GameState.get_flag("cs_throughput_progress", 0.0)) + desk_throughput()
	var ceiling: int = absorb_ceiling()
	for c in _open_requests():
		if budget < 1.0:
			break
		budget -= 1.0
		if request_difficulty(c) <= ceiling:
			_absorb(c)
		else:
			_escalate(c)
	# Do not bank more than one request's worth of idle capacity.
	GameState.set_flag("cs_throughput_progress", minf(budget, 1.0))


static func _absorb(c: Customer) -> void:
	# Silently handled — and as of the 2b fixes, ACTUALLY silent. This used to push a ticker
	# headline per absorption, which meant "absorbed" still interrupted the player's reading
	# every time and was a large part of why the cadence felt daily. The record still lands in
	# the sales log, so "Son hareketler" can show the desk earning its salary; it just stopped
	# shouting. Pull surface, not push.
	# Deliberately NO satisfaction credit: a delta with no played decision upstream is exactly
	# what §10 forbids. The value of absorption is the interruption the player never gets.
	CustomerRegistry.set_support_request(c.id, -1)
	var reps: Array = _ranked(HRConstants.AREA_CUSTOMER_SUCCESS)
	if reps.is_empty():
		return
	var rep: Character = reps[0]
	SalesSystem.record_sales_event("cs_absorb", rep.character_name, c.company_name, 0)


static func _escalations_this_window() -> int:
	# Rolling count, pruning as it reads — the array only ever holds a week of stamps.
	var cutoff: int = GameState.day - B2BConstants.CS_ESCALATION_WINDOW_DAYS
	while not GameState.cs_escalation_days.is_empty() and GameState.cs_escalation_days[0] <= cutoff:
		GameState.cs_escalation_days.remove_at(0)
	return GameState.cs_escalation_days.size()


static func _escalation_budget_left() -> bool:
	return _escalations_this_window() < B2BConstants.CS_ESCALATION_WEEKLY_CAP


static func _escalate_stale() -> void:
	# A request the desk never got to still reaches the player eventually — that is the cost of
	# understaffing, and it is what makes HIZ matter independently of UZMANLIK. It stays subject
	# to the weekly ceiling though: this path used to bypass BOTH the throughput budget and the
	# absorb ceiling, so understaffing actively INCREASED player-facing traffic. Over the cap the
	# request simply stays open and re-tries tomorrow — deferred, never dropped.
	for c in _open_requests():
		if GameState.day - c.support_request_since_day >= B2BConstants.CS_ESCALATE_AFTER_DAYS:
			_escalate(c)


static func _escalate(c: Customer) -> void:
	# THE COMPANY-WIDE CEILING. Per-account pacing alone cannot bound a bad week: with a full
	# book, several accounts come due close together and _escalate_stale ignores throughput
	# entirely. This is the one place that guarantees the player is interrupted at most
	# CS_ESCALATION_WEEKLY_CAP times per window, whatever the book does.
	# Over budget → return WITHOUT clearing the latch, so the request stays open and is
	# re-offered tomorrow. Deferred, never dropped: nothing the player owed a decision on
	# silently disappears.
	if not _escalation_budget_left():
		return
	var reps: Array = _ranked(HRConstants.AREA_CUSTOMER_SUCCESS)
	if reps.is_empty():
		return
	# Clear the latch AT escalation: the request has left the desk and become the player's, so
	# the choice's own modifiers resolve it and no new modifier type is needed to close it out.
	CustomerRegistry.set_support_request(c.id, -1)
	GameState.cs_escalation_days.append(GameState.day)
	EventManager.enqueue(B2BEventFactory.build_cs_request(c, reps[0]))
