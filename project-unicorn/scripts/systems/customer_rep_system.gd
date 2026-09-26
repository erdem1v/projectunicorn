class_name CustomerRepSystem
extends RefCounted

# The MÜŞTERİ MASASI — what a hired Müşteri Temsilcisi actually does. Pure static logic, no
# scene dependency. Two entry points, both dispatched from B2BSalesSystem.daily_tick:
# reconcile_assignments() before the lifecycle sweep, daily_tick() after it.
#
# THE ROLE HAS TWO JOBS, AND THEY ARRIVE AT DIFFERENT TIMES:
#
#   STEWARDSHIP  — assigned_to, which feeds B2BConstants.cs_dampen (slower erosion) and the
#                  rep's own escalation. CAPPED: the founder hands over only what exceeds his
#                  own account capacity, and each rep holds at most capacity_of(rep).
#                  Delegation is a response to load.
#   TALEP KANALI — this file's daily_tick. UNCAPPED and covering the WHOLE customer book,
#                  founder-managed accounts included, from the rep's very first day. Without
#                  this a rep hired early would sit idle, and an employee drawing salary for
#                  nothing is a dead hire.
#
# THE AREA. This desk reads exactly one number — MÜŞTERİ İLİŞKİLERİ — and it drives all four:
#   capacity     accounts one rep can steward           (capacity_of)
#   throughput   requests cleared per day               (throughput_of)
#   quality      churn dampening                        (B2BConstants.cs_dampen)
#   judgement    the absorb-vs-escalate valve           (absorb_ceiling)
# The trade-off lives in the assignment layer, not in the person: who is on Hesap sahipliği
# at all, and what else you had to leave unstaffed to put them there (Ekip §4.4, §12.0).
#
# NO RNG — see SalesRepSystem's header for the reasoning; the same rule binds this file.
#
# THE ADDITIVITY INVARIANT: with no active Müşteri Temsilcisi, both entry points return before
# touching state and no request is ever generated. Customers still reach the player through
# the retention and expansion cards; the request desk is a SECOND resolution surface for the
# same dissatisfaction, and it only opens when somebody staffs it.


# --- The ranked desk ---

## The CS desk, best first. Public because the event engine's `support_lead` scope selector
## needs the same ranking the system itself uses — two rankings of one desk would eventually
## disagree, and the card would name someone the system does not consider the lead.
static func ranked_reps() -> Array:
	# rev 2 §4: HESAP SAHİPLİĞİ işine atanmış herkes — rol değil atama. Bir Müşteri Temsilcisi
	# işe alındığında bu işe otomatik konuyor, yani yukarıdaki additivity invariant'ı birebir
	# korunuyor. Kurucu bu masaya sayılmaz: onun doğrudan taşıdığı hesaplar
	# (B2BSalesSystem.founder_managed_count) founder_account_capacity() ile ayrı ölçülüyor.
	var area: String = HRConstants.AREA_CUSTOMER_SUCCESS
	var reps: Array = HRSystem.assigned_to(area).filter(
		func(c: Character) -> bool: return c.category == "employee")
	reps.sort_custom(func(a: Character, b: Character) -> bool:
		var av: int = int(a.role_stats.get(area, 0))
		var bv: int = int(b.role_stats.get(area, 0))
		if av == bv:
			return a.id < b.id
		return av > bv)
	return reps


## Accounts this person can steward, from their own MÜŞTERİ İLİŞKİLERİ points — the same
## formula for a rep and for the founder.
static func capacity_of(c: Character) -> int:
	return B2BConstants.account_capacity(int(c.role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0)))


static func throughput_of(rep: Character) -> float:
	# Requests one rep clears per day. Public so desk_throughput and the smoke suite read the
	# same number.
	# §4.5: kişinin ne ürettiği TEK EVDE (HRSystem.effective_skill) — alan katsayısı, odak,
	# moral bandı ve huy çarpanları orada. Masanın kendi şekli (taban + kişi başı kapasite, ve
	# ranked_reps'in istif sırası) burada kalıyor.
	return B2BConstants.CS_THROUGHPUT_BASE \
		+ HRSystem.daily_contribution(rep, HRConstants.AREA_CUSTOMER_SUCCESS) \
			* B2BConstants.CS_THROUGHPUT_PER_PACE


static func desk_throughput() -> float:
	# Rank-ordered diminishing stack: a second rep on one queue does not double it — the queue
	# gets crowded, not the people worse.
	# §8.4: ayrı bir mesai çarpanı yok — saat, her temsilcinin katkısının içinde.
	var total: float = 0.0
	var weight: float = 1.0
	for rep in ranked_reps():
		total += weight * throughput_of(rep)
		weight *= B2BConstants.REP_STACK_DECAY
	return total


# --- STEWARDSHIP: who holds which account ---

static func reconcile_assignments() -> void:
	# §11.3: AYRILAN BİR TEMSİLCİNİN HESAPLARI OTOMATİK DEVREDİLMEZ — ayrılmanın bedeli
	# kapasitedir (§5.7: "iş boşalır, o işi yapacak kimse kalmaz"). Hesap sahipsiz kalır ve
	# oyuncu onu görür; burada yalnız kurucunun fazlası devredilir.
	if CharacterRegistry.count_active_by_role(HRConstants.ROLE_CUSTOMER_REP) == 0:
		return
	_delegate_excess()


# ============================================================================
#  A NEW ACCOUNT LANDS ON A DESK (working rule)
# ============================================================================
#
# DESIGN-PARKED: a stopgap default, not the account model. The full rule — who owns an
# account, when it moves, what the founder keeps — belongs to the account-management session
# (Satış §16, "hesap yönetimi oturumu"), and this is the one place to change while waiting.
#
# WHY IT EXISTS: nothing else assigns a freshly signed account. `_delegate_excess` hands over
# only the founder's excess and skips onboarding accounts, so without this a rep can sit idle
# beside a full founder desk with no reason the player can read.
#
# THIS OVERRIDES THE ONBOARDING SKIP for the signing moment only. `_delegate_excess` still
# refuses to reach into onboarding on its daily sweep; a new account arrives already owned,
# so the sweep has nothing to reach for.
#
# NOT PINNED. Pinning marks a PLAYER decision (`assign_customer`'s own contract), and this is
# not one — the morning reconcile must stay free to move it, and the player's "kendim tutayım"
# must stay the only thing that pins.

## Seats a newly signed account with the least-loaded rep who has room. No room anywhere (or
## no reps at all) leaves it on the founder's desk, which is what the Sales tab's assign verb
## is for. Ties break on id so a reload cannot shuffle the book.
##
## KURUCUYA OTOMATİK HESAP VERİLMEZ — MÜHÜRLÜ HÜKÜM. `ranked_reps` yalnız
## `category == "employee"` olanları döndürüyor, yani kurucu bu döngüye hiç girmiyor; bu
## dışlama KASITLIDIR.
##
## Gerekçe: kurucunun PASİF BAKIMI tek kişilik koşuyu zaten taşıyor — boştaki kurucu
## bildirimleri doğruluyor VE sahip olduğu hesapların aşınmasını yavaşlatıyor. Üstüne bir de
## otomatik sahiplik verilseydi erken oyun İKİ KAT yastıklanırdı: hem masa çalışır hem defter
## korunur, ikisi de oyuncunun hiçbir şey yapmasına gerek kalmadan. Kurucunun taşıdığı her
## hesap BİLEREK verilmiş olmalı, ve onu veren tek yer Satış sekmesinin seçicisidir.
static func auto_assign_new(c: Customer) -> void:
	var best: Character = null
	var best_load: int = 0
	for rep in ranked_reps():
		var load: int = roster_size(rep.id)
		if load >= capacity_of(rep):
			continue
		if best == null or load < best_load or (load == best_load and rep.id < best.id):
			best = rep
			best_load = load
	if best != null:
		CustomerRegistry.assign_customer(c.id, best.id, false)


## KURUCUNUN HESAP KAPASİTESİ, herkesinkiyle aynı formül (capacity_of). Kurucusu olmayan bir
## koşuda sıfır döner, yani devredilecek bir fazlalık da olmaz.
static func founder_account_capacity() -> int:
	var f: Character = CharacterRegistry.get_founder()
	return capacity_of(f) if f != null else 0


static func _delegate_excess() -> void:
	# The founder hands over only what exceeds HIS OWN CAPACITY — delegation as a response to
	# load. Deliberately NOT "fill every rep to capacity on hire": that would take accounts the
	# founder is comfortably holding, and capture the founder-managed control account the smoke
	# suite holds on purpose.
	var excess: int = B2BSalesSystem.founder_managed_count() - founder_account_capacity()
	if excess <= 0:
		return
	var pool: Array[Customer] = []
	for c in CustomerRegistry.get_by_market("b2b"):
		# Skipped: accounts already held, accounts the player deliberately parked on the
		# founder's desk (pinned), and onboarding — the founder onboards every new account
		# personally.
		if c.assigned_to == "" and not c.cs_pinned \
				and B2BConstants.CS_ASSIGNABLE_PHASES.has(c.lifecycle_phase):
			pool.append(c)
	# Oldest first: the newest signing is the one the founder still has a relationship with.
	pool.sort_custom(func(a: Customer, b: Customer) -> bool:
		if a.acquired_on_day == b.acquired_on_day:
			return a.id < b.id
		return a.acquired_on_day < b.acquired_on_day)
	var todo: int = mini(excess, pool.size())
	var handed: int = 0
	for rep in ranked_reps():
		var remaining: int = capacity_of(rep) - roster_size(rep.id)
		while remaining > 0 and handed < todo:
			CustomerRegistry.assign_customer(pool[handed].id, rep.id)
			handed += 1
			remaining -= 1


## How many b2b accounts this rep currently stewards. Public because the Sales tab's steward
## picker shows it and the HR tab keys its card rebuild on it — the UI computes nothing itself.
static func roster_size(rep_id: String) -> int:
	return CustomerRegistry.get_by_market("b2b").filter(
		func(c: Customer) -> bool: return c.assigned_to == rep_id).size()


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
	# support_request_since_day itself, state this system owns, never a property of the event.
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
	# The judgement valve: a request is absorbed when its difficulty is at most CS_ABSORB_BASE
	# plus the top rep's MÜŞTERİ İLİŞKİLERİ points; anything harder reaches the player.
	var reps: Array = ranked_reps()
	var top: int = 0 if reps.is_empty() \
		else int(reps[0].role_stats.get(HRConstants.AREA_CUSTOMER_SUCCESS, 0))
	return B2BConstants.CS_ABSORB_BASE + top


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
	# Silently handled: the record lands in the sales log, so "Son hareketler" can show the
	# desk earning its salary — a pull surface, not a push.
	# Deliberately NO satisfaction credit: a delta with no played decision upstream is exactly
	# what §10 forbids. The value of absorption is the interruption the player never gets.
	CustomerRegistry.set_support_request(c.id, -1)
	var reps: Array = ranked_reps()
	if reps.is_empty():
		return
	SalesSystem.record_sales_event("cs_absorb", reps[0].character_name, c.company_name, 0)


static func _escalate_stale() -> void:
	# A request the desk never got to still reaches the player eventually — that is the cost of
	# understaffing. It stays subject to the weekly ceiling (see _escalate): over the cap the
	# request stays open and re-tries tomorrow — deferred, never dropped.
	for c in _open_requests():
		if GameState.day - c.support_request_since_day >= B2BConstants.CS_ESCALATE_AFTER_DAYS:
			_escalate(c)


static func _escalate(c: Customer) -> void:
	# THE COMPANY-WIDE CEILING. Per-account pacing alone cannot bound a bad week: with a full
	# book, several accounts come due close together and _escalate_stale ignores throughput
	# entirely. This is the one place that guarantees the player is interrupted at most
	# CS_ESCALATION_WEEKLY_CAP times per window, whatever the book does. The stamp array is a
	# rolling window, pruned as it is read.
	# Over budget → return WITHOUT clearing the latch, so the request stays open and is
	# re-offered tomorrow. Deferred, never dropped: nothing the player owed a decision on
	# silently disappears.
	var cutoff: int = GameState.day - B2BConstants.CS_ESCALATION_WINDOW_DAYS
	while not GameState.cs_escalation_days.is_empty() and GameState.cs_escalation_days[0] <= cutoff:
		GameState.cs_escalation_days.remove_at(0)
	if GameState.cs_escalation_days.size() >= B2BConstants.CS_ESCALATION_WEEKLY_CAP:
		return
	if ranked_reps().is_empty():
		return
	# Clear the latch AT escalation: the request has left the desk and become the player's, so
	# the choice's own modifiers resolve it and no new modifier type is needed to close it out.
	CustomerRegistry.set_support_request(c.id, -1)
	GameState.cs_escalation_days.append(GameState.day)
	# NAMES a card; it does not build one. The three request branches are three
	# `tick: request` cards, picked by the same rule the `musteri.request_kind` seam reads,
	# and the gate decides.
	#
	# The desk's own policy stays here: the aging window above and the weekly ceiling. Those
	# are facts about the support desk, not tempo rules, and §13.3's category quota is a
	# different question asked by a different layer.
	var kind: String = B2BEventFactory.pick_request_kind(c)
	# The picker skips `last_request_kind`; stamp it only when the gate actually admits the
	# card — a refused request did not happen.
	if EventGate.request("customer.request_" + kind, {"customer": c.id}):
		CustomerRegistry.set_last_request_kind(c.id, kind)
