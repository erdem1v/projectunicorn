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
# THE AREA (§4, 2026-08-21). This desk reads exactly one number now —
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

## The CS desk, best first. Public because the event engine's `support_lead` scope selector
## needs the same ranking the system itself uses — two rankings of one desk would eventually
## disagree, and the card would name someone the system does not consider the lead.
static func ranked_reps() -> Array:
	return _ranked(HRConstants.AREA_CUSTOMER_SUCCESS)


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


static func throughput_of(rep: Character) -> float:
	# Requests one rep clears per day. Public so the UI and the smoke suite read the same
	# number the tick uses.
	if rep == null:
		return 0.0
	return B2BConstants.CS_THROUGHPUT_BASE \
		# §4.5: kişinin ne ürettiği TEK EVDE (HRSystem.effective_skill) — alan katsayısı,
		# odak, moral bandı ve huy çarpanları orada. Masanın kendi şekli (taban + kişi başı
		# kapasite, ve _ranked'ın istif sırası) burada kalıyor.
		+ HRSystem.daily_contribution(rep, HRConstants.AREA_CUSTOMER_SUCCESS) \
			* B2BConstants.CS_THROUGHPUT_PER_PACE


static func desk_throughput() -> float:
	# Same rank-ordered diminishing stack as the sales desk: a second rep on one queue does not
	# double it. REP_STACK_DECAY is shared by both desks because the reason is the same — the
	# queue gets crowded, not the people worse.
	var total: float = 0.0
	var weight: float = 1.0
	for rep in _ranked(HRConstants.AREA_CUSTOMER_SUCCESS):
		total += weight * throughput_of(rep)
		weight *= B2BConstants.REP_STACK_DECAY
	# §8.4: ayrı bir mesai çarpanı yok — saat, her temsilcinin katkısının içinde.
	return total


# --- STEWARDSHIP: who holds which account ---

static func reconcile_assignments() -> void:
	# Release first, then fill: a rep who went on leave this morning frees their accounts
	# before anyone else's capacity is measured.
	# §11.3: AYRILAN BİR TEMSİLCİNİN HESAPLARI OTOMATİK DEVREDİLMEZ. Eski `_release_unheld`
	# ayrılanın bütün defterini kurucuya yazıyor ve oyuncunun elle taktığı pini de onunla
	# birlikte siliyordu — yani ayrılmanın bedeli olan KAPASİTE BOŞLUĞU (§5.7: "ayrılmanın
	# bedeli kapasitedir: iş boşalır, o işi yapacak kimse kalmaz") sessizce kapanıyordu.
	# Hesap sahipsiz kalır ve oyuncu onu görür.
	if CharacterRegistry.count_active_by_role(HRConstants.ROLE_CUSTOMER_REP) == 0:
		return
	_delegate_excess()





# ============================================================================
#  F5 · A NEW ACCOUNT LANDS ON A DESK (working rule, direktör onayı 2026-08-27)
# ============================================================================
#
# DESIGN-PARKED, and the parking is the point: this is a stopgap default, not the account
# model. The full rule — who owns an account, when it moves, what the founder keeps — belongs
# to the account-management session, and this table is the one place to change while waiting.
#
# What it fixes: nothing assigned a freshly signed account to anybody. `_delegate_excess` only
# hands over what exceeds the founder's direct cap AND skips onboarding accounts on purpose
# ("the founder onboards every new account personally"), so an early run reached six accounts
# with a Customer Rep sitting at 0/4 — the picker was reading live state and the state really
# was zero. The player saw an idle rep and a full founder and no way to read why.
#
# THIS OVERRIDES THE ONBOARDING SKIP for the signing moment only. `_delegate_excess` still
# refuses to reach into onboarding on its daily sweep; what changed is that a new account now
# arrives already owned, so the sweep has nothing to reach for.
#
# NOT PINNED. Pinning marks a PLAYER decision (`assign_customer`'s own contract), and this is
# not one — the morning reconcile must stay free to move it, and the player's "kendim tutayım"
# must stay the only thing that pins.
const AUTO_ASSIGN_ON_SIGN := true


## Seats a newly signed account with the least-loaded rep who has room. No room anywhere (or
## no reps at all) leaves it on the founder's desk, which is what the Sales tab's assign verb
## is for. Ties break on id so a reload cannot shuffle the book.
##
## KURUCUYA OTOMATİK HESAP VERİLMEZ — MÜHÜRLÜ HÜKÜM (A2, 2026-08-27). `_ranked` yalnız
## `category == "employee"` olanları döndürüyor, yani kurucu bu döngüye zaten hiç girmiyor; bu
## yorum o dışlamanın KASITLI olduğunu söylüyor, tesadüf olmadığını.
##
## Gerekçe: kurucunun PASİF BAKIMI (B1) tek kişilik koşuyu zaten taşıyor — boştaki kurucu
## bildirimleri doğruluyor VE sahip olduğu hesapların aşınmasını yavaşlatıyor. Üstüne bir de
## otomatik sahiplik verilseydi erken oyun İKİ KAT yastıklanırdı: hem masa çalışır hem defter
## korunur, ikisi de oyuncunun hiçbir şey yapmasına gerek kalmadan. Kurucunun taşıdığı her
## hesap BİLEREK verilmiş olmalı, ve onu veren tek yer Satış sekmesinin seçicisidir.
static func auto_assign_new(c: Customer) -> void:
	if not AUTO_ASSIGN_ON_SIGN or c == null or c.assigned_to != "" or c.cs_pinned:
		return
	var best: Character = null
	var best_load: int = 0
	for rep in _ranked(HRConstants.AREA_CUSTOMER_SUCCESS):
		var cap: int = B2BConstants.account_capacity(
			int(rep.role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0)))
		var load: int = roster_size(rep.id)
		if load >= cap:
			continue
		if best == null or load < best_load or (load == best_load and rep.id < best.id):
			best = rep
			best_load = load
	if best == null:
		return
	CustomerRegistry.assign_customer(c.id, best.id, false)


## B4 — KURUCUNUN HESAP KAPASİTESİ, ve aynı formül. Kendi MÜŞTERİ İLİŞKİLERİ puanından
## okunuyor; kurucusu olmayan bir koşuda sıfır döner, yani devredilecek bir fazlalık da olmaz.
static func founder_account_capacity() -> int:
	var f: Character = CharacterRegistry.get_founder()
	if f == null:
		return 0
	return B2BConstants.account_capacity(int(f.role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0)))


static func _delegate_excess() -> void:
	# The founder hands over only what exceeds HIS OWN CAPACITY — delegation as a response to
	# load. Deliberately NOT "fill every rep to capacity on hire": that would take accounts the
	# founder is comfortably holding, and it would silently capture the founder-managed control
	# account that three existing smoke cases hold on purpose.
	#
	# B4 (2026-08-27) — o kapasite artık bir sabit değil, KURUCUNUN KENDİ MÜŞTERİ İLİŞKİLERİ
	# YILDIZINDAN türüyor, herkesinki gibi. "Kurucu şu kadar taşır" diye ayrı bir kural yok.
	var excess: int = B2BSalesSystem.founder_managed_count() - founder_account_capacity()
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
		var cap: int = B2BConstants.account_capacity(int(rep.role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0)))
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
	# event (the old enqueue path bypassed one_shot and cooldown entirely; the card
	# declares its own latch now and the gate enforces it).
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
	if c.pain_feature_id != "" and not ProductState.is_feature_live(c.pain_feature_id):
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
	# NAMES a card; it does not build one. The three request branches used to be one builder
	# picking between them at construction time, which made the branch invisible to content —
	# `last_request_kind` had one writer and no reader. They are three `tick: request` cards
	# now, selected by the same picker read through a seam, and the gate decides.
	#
	# The desk's own policy stays here: the aging window above and the weekly ceiling. Those
	# are facts about the support desk, not tempo rules, and §13.3's category quota is a
	# different question asked by a different layer.
	var kind: String = B2BEventFactory.pick_request_kind(c)
	if kind == "":
		return
	# The picker skips `last_request_kind`, and until 2026-09 nothing ever WROTE it, so the
	# same kind could arrive from one account twice running. Stamped only when the gate
	# actually admits the card: a refused request did not happen.
	if EventGate.request("customer.request_" + kind, {"customer": c.id}):
		CustomerRegistry.set_last_request_kind(c.id, kind)
