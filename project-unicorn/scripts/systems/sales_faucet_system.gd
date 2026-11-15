class_name SalesFaucetSystem
extends RefCounted

# THE MARKET FAUCET (§3) and the pipeline's clock (§4). Pure static logic, no scene
# dependency. Dispatched daily from B2BSalesSystem.daily_tick: the inflow runs BEFORE the rep
# desk, so a rep starting work today can pick up a lead that arrived today, and expire_leads
# runs AFTER it, so the tick a lead expires on is still a tick a rep can take it.
#
# AKIŞ ÜÇ ŞEYİ OKUR (PRD_ERP §4.3): yayındaki ürün, İtibar ve Satış'a atanmış kişiler (`lead_rate_per_week`). Hiç kurumaz: satışçısız ve
# İtibar sıfırın altındayken de yayındaki ürün haftada bir adayla tanışır.
#
# THE POOL NEVER EXHAUSTS (§3). Names come from SalesNamePool, the curated CompanyCatalog names plus a
# generated majority. Signing removes a name for the run; an expired company comes back after its
# return lock (§4) as ITSELF, which is why the lock is keyed by name rather than consuming one.
#
# THE MARKET GUARD (§3.1) IS CHECKED HERE TOO. SalesSystem.daily_tick already gates the whole
# B2B desk on a live B2B product, and this file re-asks. The duplication is deliberate: §3.1
# says a consumer run must produce ZERO B2B leads, and a second reader costs one comparison a
# tick.
#
# NO RNG. Every draw is integer arithmetic over the run seed and the day, on SalesConstants'
# mixer constants. Two runs with the same seed meet the same companies in the same order,
# which is what makes the pipeline reproducible across a save/load.

const SALT_STAR := 307
const SALT_ARCHETYPE := 311
const SALT_SECTOR := 313

const SIZE_TO_STAR := {"small": 1, "mid": 2, "enterprise": 3}


# ============================================================================
#  Daily entry
# ============================================================================

static func daily_tick() -> void:
	if not market_open():
		return
	_tick_return_locks()
	_tick_whale_conditions()
	_tick_inflow()


## §3.1 — the faucet and the whole B2B pipeline run only behind a LIVE B2B product.
static func market_open() -> bool:
	return GameState.get_flag("mvp_shipped", false) and SalesSystem.is_b2b_market()


# ============================================================================
#  §4 — lead life and the return lock
# ============================================================================

static func expire_leads() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		# §12 — "İşlenen lead | sayacı donar." A lead on a rep's desk does not age; the
		# expiry day is pushed with the work so nothing accumulates behind the freeze.
		if lead.is_being_worked():
			lead.expires_on_day = GameState.day + TimeModel.ticks(SalesConstants.LEAD_LIFE_WEEKS)
			continue
		if GameState.day < lead.expires_on_day:
			continue
		# §4 — "süre dolunca dürüst düşer". The line is honest and the return is TRACELESS:
		# no memory, no penalty, only a lock on how soon this company can come back.
		lock_return(lead.company_name, SalesConstants.RETURN_LOCK_WEEKS)
		# The card disappears with the lead, so the sentence has to survive it somewhere the
		# player can still read. The activity log is that place — an expiry the player never
		# sees is an untelegraphed loss, and the line is the telegraph.
		SalesSystem.record_sales_event("lead_expired", "", lead.company_name, 0)
		EventBus.lead_expired.emit(lead.id)
		ProspectRegistry.remove(lead.id)


static func _tick_return_locks() -> void:
	var locks: Dictionary = GameState.sales_return_locks
	for name in locks.keys():
		if GameState.day >= int(locks[name]):
			locks.erase(name)


# DESIGN-PARKED: a satisfied whale condition is CLEARED from the live card and announced
# once. §8 rules that a met item is never demanded, and that reads as a rule about the demand
# rather than only about the draw. Alternative seen: announce only at the signature, which
# never tells the player the door opened.
## §8 — the signal fires exactly once, because the condition is cleared in the same pass
## that emits it.
static func _tick_whale_conditions() -> void:
	for p in ProspectRegistry.get_all():
		var lead: Prospect = p as Prospect
		if not lead.is_whale or lead.whale_condition == "":
			continue
		if not _condition_met(lead.whale_condition, lead):
			continue
		lead.whale_condition = ""
		EventBus.whale_condition_met.emit(lead.id)


## Hold a company out of the pool until `weeks` have passed. Expiry (§4), a lost meeting (§5.2)
## and a walked or insulted negotiation (§5.3) all write this one ledger; §7.6's price-break
## refusal ("fiyatta kal … 4 hafta kilit") will too once its card is wired.
static func lock_return(company_name: String, weeks: int) -> void:
	if company_name == "":
		return
	var until: int = GameState.day + maxi(TimeModel.ticks(weeks), 1)
	var locks: Dictionary = GameState.sales_return_locks
	locks[company_name] = maxi(int(locks.get(company_name, 0)), until)


static func is_return_locked(company_name: String) -> bool:
	return GameState.day < int(GameState.sales_return_locks.get(company_name, 0))


# ============================================================================
#  §3 — the flow
# ============================================================================

## Haftada gelen aday (tik sınırından önce): yayındaki ürün, İtibar'ın payı (sıfırın altında 0, `REP_FULL`'da `FLOW_REP_MAX`) ve
## Satış'a atanmış kişiler; kurucu da atanınca sayılır (Ekip §12.0). Satış başlığı, tik ve smoke aynı sayıyı okur.
static func lead_rate_per_week() -> float:
	return (SalesConstants.FLOW_LIVE_PER_WEEK
		+ SalesConstants.FLOW_REP_MAX * clampf(float(GameState.reputation) / SalesConstants.REP_FULL, 0.0, 1.0)
		+ SalesConstants.FAUCET_PER_REP_PER_WEEK * float(HRSystem.assigned_to(HRConstants.AREA_SALES).size()))


static func _tick_inflow() -> void:
	var progress: float = float(GameState.get_flag("sales_faucet_progress", 0.0)) \
		+ lead_rate_per_week()
	var mix: Array = star_mix_now()   # the product does not move while the tick draws
	var emitted: int = 0
	while progress >= 1.0 and emitted < SalesConstants.FAUCET_TICK_MAX:
		if spawn(_roll_star(emitted, mix), "faucet") == null:
			break
		progress -= 1.0
		emitted += 1
	# Never bank more than one lead's worth: a slow week must not release a burst the moment
	# the player clears the column.
	GameState.set_flag("sales_faucet_progress", minf(progress, 1.0))


## Yıldız karışımı: evrenin tablosu, açık en yüksek bandın (`top_band`) üstündeki bantların payı ona düşer; kapalı bandın payı
## 0'dır, Pazarlamanın kanal karışımı buna dayanır (`MarketingSystem`).
static func star_mix_now() -> Array:
	var mix: Array = SalesConstants.star_mix(GameState.phase)
	var top: int = top_band() - SalesConstants.STAR_MIN
	for i in range(top + 1, mix.size()):
		mix[top] = float(mix[top]) + float(mix[i])
		mix[i] = 0.0
	return mix


## Akışın açık en yüksek yıldızı: 1★ hep açık; s★, altındaki bant açıkken ürünün o boya uyumu (`market_fit(s)`) beklentinin
## (`FIT_SCALE`) `BAND_MATCH` katına varınca açılır (PRD_ERP §4.3). Bir modülün K2'si bandı tek başına açmaz: uyum o boydaki
## şirketin bütün beklentisini okur.
static func top_band() -> int:
	var top: int = SalesConstants.STAR_MIN
	while top < SalesConstants.STAR_MAX and ProductQuality.market_fit(top + 1) >= ProductQuality.FIT_SCALE * SalesConstants.BAND_MATCH:
		top += 1
	return top


## Ürünün 3★ şirkete uyumu (ProductQuality.market_fit), böyle bir şirketin beklediğini karşılayan ürünün uyumuna oranı; 1 "karşılar".
## Pazarlamanın kanal formülü okur (PRD_PAZARLAMA B0).
static func product_strength() -> float:
	return float(ProductQuality.market_fit(SalesConstants.STAR_MAX)) / ProductQuality.FIT_SCALE


static func _roll_star(nth_today: int, mix: Array) -> int:
	var total: float = float(mix[0]) + float(mix[1]) + float(mix[2])
	var draw: float = float(SalesConstants.mix_seed(_day_seed(nth_today), SALT_STAR) % 10000) / 10000.0 * total
	var acc: float = 0.0
	for i in 3:
		acc += float(mix[i])
		if draw < acc:
			return SalesConstants.STAR_MIN + i
	return SalesConstants.STAR_MAX


# ============================================================================
#  Spawning
# ============================================================================

## Create one lead. THE single in-game creation path — the faucet and the event channel come
## through here, so a played lead can never exist without a star, an archetype, a name and an
## expiry.
##
## Returns null when the market is shut, when no archetype fits the star, or when the
## product's buyer sectors (or the asked one) hold no free name; a caller that gets null has produced nothing and
## burned nothing.
static func spawn(star: int, source: String, sector := "") -> Prospect:
	if not market_open():
		return null
	var s: int = clampi(star, SalesConstants.STAR_MIN, SalesConstants.STAR_MAX)
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var seed_base: int = _day_seed(GameState.run_prospects_spawned)

	var pool: Array = SalesArchetypes.candidates_for(s, sub_id)
	if pool.is_empty():
		return null
	var archetype: String = String(pool[SalesConstants.mix_seed(seed_base, SALT_ARCHETYPE) % pool.size()])

	var excluded: Dictionary = _excluded_names()
	# The product's buyer sectors in pull order; Pazarlama's Hedef sektör asks for one of them (MarketingSystem._spawn_leads).
	var sectors: Array = ProductLines.buyer_sectors(sub_id)
	if sector != "":
		sectors = [sector] if sectors.has(sector) else []
	else:
		sectors = sector_order(sectors, s, seed_base)
	var chosen_sector: String = ""
	var company: String = ""
	for offset in sectors.size():
		var s_id: String = String(sectors[offset])
		var name: String = SalesNamePool.take(s_id, seed_base + offset, excluded)
		if name != "":
			chosen_sector = s_id
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
	p.expires_on_day = GameState.day + TimeModel.ticks(SalesConstants.LEAD_LIFE_WEEKS)
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
	# §8 — the whale hook ("erişim bandının bir üstünde"), relative by construction: any star
	# above what the desk can reach.
	_seat_whale_condition(p)
	ProspectRegistry.add(p)
	EventBus.prospect_arrived.emit(p.id)
	return p


## Alıcı sektörleri çekim sırasıyla (PRD_ERP §4.3): ilki ürünün o boydaki uyumuyla (`ProductQuality.sector_fit`, en az 1)
## ağırlıklı çekilir, güçlü olduğu alanları vurgulayan sektör öndedir; kalanı listedeki sırasıyla onun ardından gelir, adı
## tükenmiş sektörün yerine sıradaki geçer. Çekiliş `seed_base`'den karıştırıcının ikinci turudur, alıcı tipinin çekilişinden
## bağımsızdır.
static func sector_order(sectors: Array, star: int, seed_base: int) -> Array:
	if sectors.is_empty():
		return []
	var weights: Array = sectors.map(func(s: String) -> int: return maxi(1, ProductQuality.sector_fit(s, star)))
	var at: int = SalesConstants.mix_seed(SalesConstants.mix_seed(seed_base, SALT_SECTOR), SALT_SECTOR) % int(
		weights.reduce(func(sum: int, w: int) -> int: return sum + w, 0))
	var first: int = 0
	while at >= weights[first]:
		at -= weights[first]
		first += 1
	return sectors.slice(first) + sectors.slice(0, first)


## The event channel's door into the pipeline. Satış §3 routes the whale role through "kahraman
## hesap / olay kanalı", and the engine's `add_prospect` effect is that channel. Its card
## (`customer/frank_intro.json`) speaks the three-tier size ids, so the translation to a star
## happens here, once, rather than in every card.
static func spawn_prospect(size: String, source: String) -> Prospect:
	return spawn(int(SIZE_TO_STAR.get(size, 1)), source)


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
		SalesConstants.WHALE_COND_LOCKED_TIER:
			return SalesProbes.locked_line() == ""
		SalesConstants.WHALE_COND_SLA:
			# An SLA promise is met while one is open against this account's own company.
			return PromiseRegistry.has_open_for("co_" + p.id)
	return true


## §8 — the band the desk can reach today: the best Satış star between the founder and the
## sales roster. Derived, never stored (§13 "Erişim bandı türetilir, saklanmaz").
static func reach_band() -> int:
	var best: int = SalesLedger.founder_star()
	for c in HRSystem.assigned_to(HRConstants.AREA_SALES):
		best = maxi(best, SalesRepSystem.rep_star(c as Character))
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
		if is_return_locked(nm):
			ex[nm] = true
	return ex


static func _day_seed(salt: int) -> int:
	return GameState.run_seed + GameState.day * 7 + salt * 13
