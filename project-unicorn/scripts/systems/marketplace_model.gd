class_name MarketplaceModel
extends RefCounted

# Pazaryeri ekonomisinin saf çekirdeği. Girdi iki sözlüktür: `state` (GameState.marketplace'in biçimi, `new_state`) ve `world`
# (o haftanın başka sahiplerden gelen girdileri, `WORLD`; verilmeyen alan varsayılanını alır). GameState'i okumaz ve yazmaz;
# yazan işlevler (`open_category`, `set_*`, `close_week`) yalnız verilen `state`'i değiştirir, önizleme kopyada koşar.
# Sabitler `data/product/marketplace.json` ve `categories.json`'da, hepsi [WORKING]. Sayılar ondalıklıdır, yuvarlama
# gösterimin işidir. Oyuncuya görünen metin yoktur: defter satırı, adım ve bölge kimlik döndürür.
#
# Kimlikler: kategori `fashion`, `electronics`, `home`, `beauty`, `baby`, `sports`; adım `cart`, `checkout`, `order`, `delivered`;
# bölge `comfortable`, `strained`, `leaving`; kural `shipping`, `return_window`, `return_shipping`, `admission`; ayrıcalık
# `free_shipping`, `fast_delivery`, `doorstep_returns`, `member_discount`; modül `listing`, `storefront`, `checkout`, `orders`,
# `reviews`, `mobile`, `integrations`, `accounts`, `backup`, `membership`; defter tarafı `users`, `stores`; Talepler konusu
# `data/product/marketplace.json` `topics.catalog`'ta, durumu `waiting`, `planned`, `shipped`.
#
# `state` (gün alanları hafta sayısıdır, hiç değişmemişin günü NEVER): `users`, `members`; `sources[kaynak]` son on iki
# haftanın yeni kullanıcısı (yeni önde); `cats[kategori]` = `open`, `open_day`, `commission` (yüzde), `commission_day`, `stores`,
# `joined` (son sekiz hafta), `terms` ({} ya da `share`, `weeks`, `mult`), `week` (kapanışın sayıları: `returning`, `organic`,
# `channel`, `visits`, `cart`, `checkout`, `order`, `delivered`, `returns`, `net`); `assign[kişi]` = kategori; `policy[kural]` =
# `pick`, `day`; `premium` = `open`, `fee`, `fee_day`, `trial`, `joined` (denemede katılan üye, son dört hafta), `orders` (üye
# siparişi, son dört hafta), `perks[ayrıcalık]` = `pick`, `day`, `uses`, `cost` (son dört hafta); `ledger[taraf]` = satırlar
# (`key`, `arg`, `points`, `weeks`; WHILE koşul sürdükçe); `revenue_weeks`; `sat[taraf]` (iki memnuniyet); `burn[kalem]` (son
# kapanışın haftalık `pazaryeri` gideri); `lost` (kapanışlarda kaybedilen `users` ve `stores`, birikir); `topics[konu]` =
# `tickets` (son dört haftanın bileti, yeni önde), `since_day` (ilk biletin ya da isteğin haftası), `status`, `source` (`tickets`
# ya da `report`).
#
# `world`: `week`, `published`, `tiers[modül]` (0 = yok), `bugs[modül]` (açık hata), `stars[kişi]` (Satış yıldızı, yoksa 1),
# `channel[kategori][kaynak]` (Pazarlama'nın kanal ziyareti), `return_lift`, `overrides[kural]` (kampanyanın ezmesi),
# `campaign_discount[kategori]` (şirketin karşıladığı haftalık indirim), `campaign_loss` (kampanya bitti, katılan mağaza zarar etti),
# `unanswered` (Destek'in cevapsız bildirim payı), `features` (yayındaki ek özellik konularının kimliği: yayında olmayan
# kullanıcı özelliği bağlı adımı `missing_mult` kadar kısar), `planned` (sprint planındaki konuların kimliği), `outage` (acil
# durumun kullanıcı memnuniyetine yazdığı düşüş).
#
# "Sipariş" teslim edilen siparişin adıdır (gain, haftalık sipariş, mağaza başına sipariş, üye siparişi, kargo ve iade
# sayıları); "Sipariş verdi" adımı `order` ayrı sayılır.

const DATA_PATH := "res://data/product/marketplace.json"
const CATEGORIES_PATH := "res://data/product/categories.json"
## Hiç değişmemiş bir ayarın günü: kilit ilk haftada da açıktır.
const NEVER := -1000
## Defter satırının süresi yok: koşul sürdükçe her kapanışta yeniden yazılır.
const WHILE := -1
const SIDES := ["users", "stores"]
const STEPS := ["cart", "checkout", "order", "delivered"]
## Adım çarpanı tablosu 1. kademeden başlayan modüller (0,83, 0,96, 1): Vitrin, Sepet ve Ödeme, Siparişler. Öbürleri (Mobil,
## Entegrasyonlar) yokken de çalışır; tabloları 0. kademeden başlar (0,90, 0,95, 0,98, 1).
const TABLE_FROM_TIER_1 := ["storefront", "checkout", "orders"]
## Önizlemede fark yerine oran olarak okunan büyüklükler.
const RELATIVE := ["store_earnings"]
const WORLD := {
	"week": 0, "published": false, "tiers": {}, "bugs": {}, "stars": {}, "channel": {}, "return_lift": 0.0, "overrides": {},
	"campaign_discount": {}, "campaign_loss": false, "unanswered": 0.0, "features": [],
	"planned": [], "outage": 0.0,
}

static var _c: Dictionary = _read(DATA_PATH)
static var _cats: Dictionary = _read_categories()


static func _read(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


static func _read_categories() -> Dictionary:
	var out := {}
	for d in _read(CATEGORIES_PATH).categories:
		out[d.id] = d
	return out


static func new_world() -> Dictionary:
	return WORLD.duplicate(true)


static func _w(world: Dictionary, key: String) -> Variant:
	return world.get(key, WORLD[key])


static func new_state() -> Dictionary:
	var cats := {}
	for id in _cats:
		cats[id] = {"open": false, "open_day": NEVER, "commission": int(_cats[id].start_commission_pct), "commission_day": NEVER,
			"stores": 0.0, "joined": [], "terms": {}, "week": {}}
	var policy := {}
	for rule in _c.rules.options:
		policy[rule] = {"pick": _c.rules.options[rule][0], "day": NEVER}
	var perks := {}
	for perk in _c.premium.perks:
		perks[perk] = {"pick": "off", "day": NEVER, "uses": [], "cost": []}
	var topics := {}
	for topic in _c.topics.catalog:
		topics[topic.id] = {"tickets": [], "since_day": NEVER, "status": "waiting", "source": "tickets"}
	var base: float = _c.ledger.base
	return {"users": 0.0, "members": 0.0, "sources": {}, "cats": cats, "assign": {}, "policy": policy,
		"premium": {"open": false, "fee": int(_c.premium.fee_start), "fee_day": NEVER, "trial": false, "joined": [],
			"orders": [], "perks": perks},
		"ledger": {"users": [], "stores": []}, "sat": {"users": base, "stores": base}, "revenue_weeks": [], "burn": {},
		"lost": {"users": 0.0, "stores": 0.0}, "topics": topics}


# --- Kategori ve kural erişimi ---------------------------------------------------------------

static func cat_ids() -> Array:
	return _cats.keys()


static func cat_def(cat: String) -> Dictionary:
	return _cats[cat]


static func open_ids(state: Dictionary) -> Array:
	return _cats.keys().filter(func(id: String) -> bool: return state.cats[id].open)


static func _tier(world: Dictionary, module: String) -> int:
	return int(_w(world, "tiers").get(module, 0))


static func _met(world: Dictionary, needs: Dictionary) -> bool:
	return needs.is_empty() or _tier(world, needs.module) >= int(needs.tier)


## Modülün bugünkü kademesinin adım çarpanı.
static func _tier_mult(world: Dictionary, module: String) -> float:
	var tier := _tier(world, module)
	if module in TABLE_FROM_TIER_1:
		return _c.steps.tier_from_1[clampi(tier - 1, 0, 2)]
	return _c.steps.tier_from_0[clampi(tier, 0, 3)]


static func _bug_mult(world: Dictionary, modules: Array) -> float:
	var open := 0
	for module in modules:
		open += int(_w(world, "bugs").get(module, 0))
	return 1.0 - _c.steps.bug_each * mini(open, int(_c.steps.bug_cap))


## Kampanyanın ezdiği ya da saklı seçim; kampanya kargoyu bedava yapınca `free`.
static func policy_value(state: Dictionary, world: Dictionary, rule: String) -> String:
	return _w(world, "overrides").get(rule, state.policy[rule].pick)


static func policy_open(world: Dictionary, rule: String) -> bool:
	return _met(world, _c.rules.needs.get(rule, {}))


## Son değişikliğin gününden bu yana kilitten kalan hafta.
static func lock_left(day: float, world: Dictionary) -> int:
	return maxi(0, int(day) + int(_c.rules.lock_weeks) - int(_w(world, "week")))


# --- Mağaza: payı, bölgesi, kazanımı ---------------------------------------------------------

static func return_rate(state: Dictionary, world: Dictionary, cat: String) -> float:
	var r: Dictionary = _c.rules.returns
	var rate: float = _cats[cat].sector_return * r.window_mult[policy_value(state, world, "return_window")] \
		* r.reviews_mult[clampi(_tier(world, "reviews"), 0, 3)]
	if policy_value(state, world, "return_shipping") == "we_pay":
		rate *= r.we_pay_mult
	if policy_value(state, world, "admission") == "registered":
		rate *= r.registered_mult
	return rate


## Mağazanın komisyon artışının fiyatına yansıttığı pay, sepetin oranı olarak.
static func price_pass(cat: String, commission: float) -> float:
	return _c.stores.pass_through * maxf(0.0, commission - _cats[cat].start_commission_pct) / 100.0


static func ship_mult(state: Dictionary, world: Dictionary, cat: String) -> float:
	var user: float = _c.rules.shipping.user_pays_mult
	match policy_value(state, world, "shipping"):
		"user_pays":
			return user
		"big_basket":
			return user + (1.0 - user) * _cats[cat].big_basket_share
	return 1.0


## Kargoyu mağazanın ödediği siparişlerin payı: büyük sepette yalnız büyük sepetler, hep mağaza öderde hepsi.
static func _store_ships(rule: String, big_basket_share: float) -> float:
	match rule:
		"big_basket":
			return big_basket_share
		"store_pays":
			return 1.0
	return 0.0


## Kargo bedelinin mağazaya düşen payı, sepetin oranı olarak.
static func _ship_share(state: Dictionary, world: Dictionary, cat: String) -> float:
	var d: Dictionary = _cats[cat]
	return _store_ships(policy_value(state, world, "shipping"), d.big_basket_share) * _c.rules.shipping.fee / d.basket


## Mağazaya kalan, sepetin oranı olarak, `commission` yüzdesiyle.
static func store_keep(state: Dictionary, world: Dictionary, cat: String, commission: float) -> float:
	var d: Dictionary = _cats[cat]
	var return_ship := 0.0
	if policy_value(state, world, "return_shipping") == "store_pays":
		return_ship = return_rate(state, world, cat) * _c.rules.shipping.fee / d.basket
	return d.margin - commission / 100.0 - _ship_share(state, world, cat) - return_ship + price_pass(cat, commission)


static func zone_at(state: Dictionary, world: Dictionary, cat: String, commission: float) -> String:
	var ratio: float = store_keep(state, world, cat, commission) / _cats[cat].margin
	if ratio >= _c.stores.zone_ease:
		return "comfortable"
	return "strained" if ratio >= _c.stores.zone_strain else "leaving"


static func zone(state: Dictionary, world: Dictionary, cat: String) -> String:
	return zone_at(state, world, cat, state.cats[cat].commission)


## Öbür kurallar bugünkü hâliyle dururken bölgenin değiştiği en yüksek tam sayı komisyonlar: `comfortable` rahat kaldığı,
## `strained` ayrılıra düşmediği son oran.
static func zone_limits(state: Dictionary, world: Dictionary, cat: String) -> Dictionary:
	var limits := {"comfortable": 0, "strained": 0}
	for commission in range(int(_c.commission.min), int(_c.commission.max) + 1):
		match zone_at(state, world, cat, commission):
			"comfortable":
				limits.comfortable = commission
				limits.strained = commission
			"strained":
				limits.strained = commission
	return limits


## Seçenek: mağaza sayısının kategorinin gerektirdiğine oranı, en çok 1.
static func variety(state: Dictionary, cat: String) -> float:
	return minf(1.0, state.cats[cat].stores / _cats[cat].stores_needed)


## Bir kişinin bu kategoride haftalık mağaza kazanımı; yayından önce 0.
static func acquisition_of(state: Dictionary, world: Dictionary, cat: String, stars: int) -> float:
	if not _w(world, "published"):
		return 0.0
	var st: Dictionary = _c.stores
	var rate: float = st.acquire_base[clampi(stars, 1, 5) - 1] * st.zone_mult[zone(state, world, cat)] \
		* st.listing_acquire[clampi(_tier(world, "listing") - 1, 0, 2)] * state.cats[cat].terms.get("mult", 1.0)
	if policy_value(state, world, "admission") == "registered":
		rate *= st.admission_mult
	return rate


static func acquisition(state: Dictionary, world: Dictionary, cat: String) -> float:
	var total := 0.0
	for person in state.assign:
		if state.assign[person] == cat:
			total += acquisition_of(state, world, cat, int(_w(world, "stars").get(person, 1)))
	return total


## Kategorinin geçen haftaki ziyaretinin payı; ziyaret yoksa açık kategoriler eşit.
static func _visit_share(state: Dictionary, cat: String) -> float:
	var open := open_ids(state)
	var total := 0.0
	for id in open:
		total += state.cats[id].week.get("visits", 0.0)
	if total == 0.0:
		return 1.0 / open.size()
	return state.cats[cat].week.get("visits", 0.0) / total


## Bir mağazanın haftada ayrılma olasılığı; mağazası olmayan kategoride 0.
static func _leave_rate(state: Dictionary, world: Dictionary, cat: String) -> float:
	var cs: Dictionary = state.cats[cat]
	var st: Dictionary = _c.stores
	if cs.stores <= 0.0:
		return 0.0
	var idle: float = clampf(1.0 - float(cs.week.get("delivered", 0.0)) / cs.stores / st.idle_orders, 0.0, 1.0)
	var in_zone: float = st.leave_zone if zone(state, world, cat) == "leaving" else 0.0
	return st.leave_base * st.listing_stay[clampi(_tier(world, "listing") - 1, 0, 2)] + in_zone \
		+ st.leave_idle * idle + st.leave_sat * maxf(0.0, st.sat_ok - state.sat.stores)


## Kapanışın 1. adımı: katılan mağaza (kazanım ve kendiliğinden gelen) ve ayrılan; ayrılanı döndürür.
static func _store_flow(state: Dictionary, world: Dictionary, cat: String) -> float:
	var cs: Dictionary = state.cats[cat]
	var st: Dictionary = _c.stores
	var joins: float = acquisition(state, world, cat) + state.users * st.organic_rate * _visit_share(state, cat)
	var leaving: float = cs.stores * _leave_rate(state, world, cat)
	cs.stores += joins - leaving
	_push(cs.joined, joins, int(st.joined_weeks))
	return leaving


# --- Ziyaretten teslimata --------------------------------------------------------------------

## Bağlı adımı kısan, yayında olmayan ek özelliklerin çarpanı.
static func _feature_mult(world: Dictionary, step: String) -> float:
	var mult := 1.0
	for topic in _c.topics.catalog:
		if topic.has("missing_mult") and topic.link == step and not _topic_live(world, topic):
			mult *= topic.missing_mult
	return mult


## Adım başına çarpan; hepsi 1 iken adım ulaşılabilir oranındadır. En küçüğü en zayıf adımdır.
static func step_factors(state: Dictionary, world: Dictionary, cat: String) -> Dictionary:
	var price: float = pow(1.0 + price_pass(cat, state.cats[cat].commission), -_c.commission.elasticity)
	var factors := {
		"cart": _tier_mult(world, "storefront") * variety(state, cat) * price,
		"checkout": ship_mult(state, world, cat) * _tier_mult(world, "mobile"),
		"order": _tier_mult(world, "checkout") * _bug_mult(world, ["checkout"]),
		"delivered": _tier_mult(world, "orders") * _tier_mult(world, "integrations") * _bug_mult(world, ["orders", "integrations"]),
	}
	for step in STEPS:
		factors[step] *= _feature_mult(world, step)
	return factors


static func weakest_step(state: Dictionary, world: Dictionary, cat: String) -> String:
	var factors := step_factors(state, world, cat)
	var worst: String = STEPS[0]
	for step in STEPS:
		if factors[step] < factors[worst]:
			worst = step
	return worst


## Ziyaretten her adımın sayısı: öncekinin ulaşılabilir oranı çarpı çarpanı kadarı.
static func _funnel(visits: float, factors: Dictionary) -> Dictionary:
	var counts := {}
	var count := visits
	for step in STEPS:
		count *= _c.steps.reach[step] * factors[step]
		counts[step] = count
	return counts


## Değişiklik bugün yürürlükte olsaydı geçen haftanın ziyaretinden haftalık siparişin kaç artacağı. `change`:
## `tier` ({modül: kademe}), `bugs` ({modül: açık hata}), `policy` ({kural: seçenek}), `features` (yayına çıkan ek özellik konularının
## kimlikleri); biri ya da birkaçı.
static func gain(state: Dictionary, world: Dictionary, cat: String, change: Dictionary) -> float:
	var changed_state := state
	if change.has("policy"):
		changed_state = state.duplicate(true)
		for rule in change.policy:
			changed_state.policy[rule].pick = change.policy[rule]
	var changed_world := world.merged({"tiers": _w(world, "tiers").merged(change.get("tier", {}), true),
		"bugs": _w(world, "bugs").merged(change.get("bugs", {}), true),
		"features": _w(world, "features") + change.get("features", [])}, true)
	var visits: float = state.cats[cat].week.get("visits", 0.0)
	return _funnel(visits, step_factors(changed_state, changed_world, cat)).delivered \
		- _funnel(visits, step_factors(state, world, cat)).delivered


static func _visits(state: Dictionary, world: Dictionary, cat: String) -> Dictionary:
	var d: Dictionary = _cats[cat]
	var v: Dictionary = _c.visits
	var base_total := 0.0
	for id in open_ids(state):
		base_total += _cats[id].base_interest
	var sat_coef: float = clampf((state.sat.users - v.sat_floor) / v.sat_span, 0.0, 1.0)
	var channel := 0.0
	for source_visits in _w(world, "channel").get(cat, {}).values():
		channel += source_visits
	return {
		"returning": (state.users - state.members + state.members * v.member_freq) * d.visit_freq * (1.0 + _w(world, "return_lift")),
		"organic": (state.users * v.organic_rate * sat_coef * d.base_interest / base_total + d.base_interest) * variety(state, cat),
		"channel": channel,
	}


# --- Kullanıcı ve Premium --------------------------------------------------------------------

static func retention(state: Dictionary, world: Dictionary) -> float:
	var r: Dictionary = _c.visits.retention
	var member_share: float = float(state.members) / state.users if state.users > 0.0 else 0.0
	return clampf(r.base + r.per_sat * (state.sat.users - r.sat_ref) \
		+ _c.rules.returns.window_retention[policy_value(state, world, "return_window")] + r.member_share * member_share, r.min, r.max)


static func open_premium(state: Dictionary, world: Dictionary) -> bool:
	if state.premium.open or not _met(world, _c.premium.needs):
		return false
	state.premium.open = true
	return true


## Premium'a alınan ayrıcalıkların çekim puanları toplamı; "Hep mağaza öder" kuralında kargo bedava bir şey vermez.
static func premium_pull(state: Dictionary) -> float:
	var pull := 0.0
	for perk in state.premium.perks:
		var free_already: bool = perk == "free_shipping" and state.policy.shipping.pick == "store_pays"
		if state.premium.perks[perk].pick == "premium" and not free_already:
			pull += _c.premium.perks[perk].pull
	return pull


## Geri gelen ziyaretten doğan siparişin toplam siparişe oranı.
static func returning_share(state: Dictionary, cats: Array) -> float:
	var returning := 0.0
	var orders := 0.0
	for id in cats:
		var wk: Dictionary = state.cats[id].week
		orders += wk.get("delivered", 0.0)
		if wk.get("visits", 0.0) > 0.0:
			returning += wk.delivered * wk.returning / float(wk.visits)
	return returning / orders if orders > 0.0 else 0.0


# --- Gelir ve gider --------------------------------------------------------------------------

## Ücret ödeyen üye: denemede katılan ödemez.
static func paying_members(state: Dictionary) -> float:
	return maxf(0.0, state.members - _sum(state.premium.joined))


## Komisyon geliri mağazalar kaydının, üyelik geliri kullanıcılar kaydının MRR'ına yazılır.
static func monthly_revenue(state: Dictionary) -> Dictionary:
	var inc: Dictionary = _c.income
	return {"commission": _sum(state.revenue_weeks) * inc.month_weeks / inc.window_weeks,
		"membership": paying_members(state) * state.premium.fee}


## Son kapanışın `pazaryeri` gideri, aylık.
static func monthly_cost(state: Dictionary) -> float:
	return _sum(state.burn.values()) * _c.income.month_weeks


# --- Pazarlama'nın okuması -------------------------------------------------------------------

## Kategorideki kanal ziyaretinin değeri. `conversion`: ziyaretten teslim edilen siparişe oran; `monthly_commission`: bir kullanıcının
## kategoride bıraktığı aylık net komisyon (haftalık ziyaret sıklığı × dönüşüm × iade sonrası siparişin komisyonu × ay haftası);
## `organic`: kendiliğinden gelecek haftalık ziyaret; öbürleri kategorinin sabitleri. Kapalı kategoride dönüşüm ve ziyaret 0.
static func channel_read(state: Dictionary, world: Dictionary, cat: String) -> Dictionary:
	var d: Dictionary = _cats[cat]
	var cs: Dictionary = state.cats[cat]
	var conversion: float = _funnel(1.0, step_factors(state, world, cat)).delivered
	var per_order: float = (1.0 - return_rate(state, world, cat)) * d.basket * cs.commission / 100.0
	return {"conversion": conversion, "monthly_commission": d.visit_freq * _c.income.month_weeks * conversion * per_order,
		"organic": _visits(state, world, cat).organic if cs.open else 0.0, "margin": d.margin, "base_interest": d.base_interest,
		"ad_pool": d.ad_pool}


## Kaynaktan son on iki haftada gelen kullanıcıların (elde tutmayla küçülmüş) son dört haftada bıraktığı net komisyon: kalan
## kullanıcı × aktif kullanıcı başına son dört haftanın net komisyonu × o dört haftanın kaçında burada olduğu (bu hafta gelen
## dörtte bir, dördüncü haftasından itibaren tam).
static func source_revenue(state: Dictionary, world: Dictionary, source: String) -> float:
	if state.users <= 0.0:
		return 0.0
	var keep := retention(state, world)
	var window: float = _c.income.window_weeks
	var present := 0.0
	var arrivals: Array = state.sources.get(source, [])
	for i in arrivals.size():
		present += arrivals[i] * pow(keep, i) * minf(i + 1.0, window) / window
	return present * _sum(state.revenue_weeks) / state.users


# --- Yazan işlevler --------------------------------------------------------------------------

static func open_category(state: Dictionary, world: Dictionary, cat: String) -> bool:
	if state.cats[cat].open:
		return false
	state.cats[cat].open = true
	state.cats[cat].open_day = _w(world, "week")
	return true


static func set_commission(state: Dictionary, world: Dictionary, cat: String, commission: int) -> bool:
	var cs: Dictionary = state.cats[cat]
	if not cs.open or commission == cs.commission or commission < _c.commission.min or commission > _c.commission.max \
			or lock_left(cs.commission_day, world) > 0:
		return false
	if commission > cs.commission:
		var raised: Dictionary = _c.ledger.rows.commission_raised
		_add(state, "stores", "commission_raised", cat, raised.points * (commission - cs.commission), int(raised.weeks))
	cs.commission = commission
	cs.commission_day = _w(world, "week")
	return true


static func set_policy(state: Dictionary, world: Dictionary, rule: String, option: String) -> bool:
	var p: Dictionary = state.policy[rule]
	if option == p.pick or not option in _c.rules.options[rule] or lock_left(p.day, world) > 0 or not policy_open(world, rule):
		return false
	p.pick = option
	p.day = _w(world, "week")
	return true


static func set_fee(state: Dictionary, world: Dictionary, fee: int) -> bool:
	var pr: Dictionary = state.premium
	if not pr.open or fee == pr.fee or fee < _c.premium.fee_min or fee > _c.premium.fee_max or lock_left(pr.fee_day, world) > 0:
		return false
	pr.fee = fee
	pr.fee_day = _w(world, "week")
	return true


static func set_perk(state: Dictionary, world: Dictionary, perk: String, option: String) -> bool:
	var p: Dictionary = state.premium.perks[perk]
	var cfg: Dictionary = _c.premium.perks[perk]
	if not state.premium.open or option == p.pick or not option in cfg.options or lock_left(p.day, world) > 0 \
			or not _met(world, cfg.get("needs", {})):
		return false
	if perk == "fast_delivery" and p.pick == "everyone" and option == "premium":
		var members_only: Dictionary = _c.ledger.rows.fast_members_only
		_add(state, "users", "fast_members_only", "", members_only.points, int(members_only.weeks))
	p.pick = option
	p.day = _w(world, "week")
	return true


static func set_trial(state: Dictionary, on: bool) -> bool:
	if not state.premium.open or on == state.premium.trial:
		return false
	state.premium.trial = on
	return true


## Yeni mağaza şartı: yeni gelen mağazadan `weeks` hafta alınan komisyon payı; kazanım çarpanı payın seçeneğinden gelir.
static func set_store_terms(state: Dictionary, cat: String, share: float, weeks: int) -> bool:
	for option in _c.store_terms.options:
		if is_equal_approx(option.share, share):
			state.cats[cat].terms = {"share": share, "weeks": weeks, "mult": option.mult}
			return true
	return false


## Olayın kullanıcı ekleyişi ya da çıkarışı (`n` eksi olabilir); üye sayısı kullanıcıyı aşmaz. Kullanıcı sayısı değişmediyse false.
static func add_users(state: Dictionary, n: float) -> bool:
	var before: float = state.users
	state.users = maxf(0.0, before + n)
	state.members = minf(state.members, state.users)
	return state.users != before


# --- Memnuniyet defteri ----------------------------------------------------------------------

static func _add(state: Dictionary, side: String, key: String, arg: String, points: float, weeks: int) -> void:
	state.ledger[side].append({"key": key, "arg": arg, "points": points, "weeks": weeks})


## Hedef: taban artı satırların toplamı, 0 ile 100 arası.
static func target_sat(state: Dictionary, side: String) -> float:
	var points := 0.0
	for row in state.ledger[side]:
		points += row.points
	return clampf(_c.ledger.base + points, 0.0, 100.0)


## Kapanışın 7. adımı: koşul satırlarını yeniden yazar, konu durumundan "Karşılandı" ve "Geciken talep" satırlarını çıkarır,
## olayların satırlarını ekler, memnuniyeti hedefe yaklaştırır, süreli satırların süresini bir hafta azaltır.
static func _settle(state: Dictionary, world: Dictionary, totals: Dictionary) -> void:
	var rows: Dictionary = _c.ledger.rows
	for side in SIDES:
		state.ledger[side] = state.ledger[side].filter(func(r: Dictionary) -> bool: return r.weeks != WHILE)
	for cat in open_ids(state):
		if state.cats[cat].stores > 0.0:
			match zone(state, world, cat):
				"strained":
					_add(state, "stores", "strained", cat, rows.strained.points, WHILE)
				"leaving":
					_add(state, "stores", "earnings_thin", cat, rows.earnings_thin.points, WHILE)
		if _w(world, "published") and variety(state, cat) < rows.thin_selection.below:
			_add(state, "users", "thin_selection", cat, rows.thin_selection.points, WHILE)
	var window: String = policy_value(state, world, "return_window")
	for side in SIDES:
		var points: float = rows.return_window[side].get(window, 0.0)
		if points != 0.0:
			_add(state, side, "return_window", "", points, WHILE)
	if policy_value(state, world, "return_shipping") == "we_pay":
		_add(state, "stores", "return_shipping_paid", "", rows.return_shipping_paid.points, WHILE)
	if policy_value(state, world, "admission") == "registered":
		_add(state, "users", "registered_stores", "", rows.registered_stores.points, WHILE)
	if totals.placed > 0.0 and totals.delivered / totals.placed < rows.late_delivery.below:
		_add(state, "users", "late_delivery", "", rows.late_delivery.points, WHILE)
	var unanswered: float = _w(world, "unanswered")
	if unanswered > 0.0:
		_add(state, "users", "support_backlog", "", maxf(rows.support_backlog.floor, unanswered * rows.support_backlog.per_share), WHILE)
	if state.users > rows.weak_security.users_over and _tier(world, "accounts") == 0:
		_add(state, "users", "weak_security", "", rows.weak_security.points, WHILE)
	for perk in ["fast_delivery", "doorstep_returns"]:
		if state.premium.perks[perk].pick == "everyone":
			_add(state, "users", perk, "", rows[perk].points, WHILE)
	_refresh_topics(state, world)
	for side in SIDES:
		var late := _late_topic(state, world, side)
		if late != "":
			_add(state, side, "late_topic", late, rows.late_topic.points, WHILE)
	if _w(world, "campaign_loss"):
		_add(state, "stores", "sale_loss", "", rows.sale_loss.points, int(rows.sale_loss.weeks))
	var outage: float = _w(world, "outage")
	if outage > 0.0:
		_add(state, "users", "outage", "", -outage, int(rows.outage.weeks))
	for side in SIDES:
		state.sat[side] = move_toward(state.sat[side], target_sat(state, side), _c.ledger.max_step)
		for row in state.ledger[side]:
			if row.weeks != WHILE:
				row.weeks -= 1
		state.ledger[side] = state.ledger[side].filter(func(r: Dictionary) -> bool: return r.weeks != 0)


# --- Talepler: konular ve biletler -----------------------------------------------------------

## Konunun özelliği yayında mı: kademe konusunda modülün kademesi yetiyor, ek özellikte dünyanın yayındaki listesinde.
static func _topic_live(world: Dictionary, topic: Dictionary) -> bool:
	if topic.has("tier"):
		return _tier(world, topic.module) >= int(topic.tier)
	return topic.id in _w(world, "features")


## Konu durumunu dünyadan okur; isteği gelmiş bir konu ilk kez yayına çıkınca tarafına "Karşılandı" satırı yazar.
static func _refresh_topics(state: Dictionary, world: Dictionary) -> void:
	var met: Dictionary = _c.ledger.rows.met
	for topic in _c.topics.catalog:
		var ts: Dictionary = state.topics[topic.id]
		var live := _topic_live(world, topic)
		if live and ts.status != "shipped" and ts.since_day != NEVER:
			_add(state, topic.side, "met", topic.id, met.points, int(met.weeks))
		ts.status = "shipped" if live else ("planned" if topic.id in _w(world, "planned") else "waiting")


## Tarafın en eski gecikmiş konusu: yayında olmayan (planda olan dahil) ve ilk isteğinden bu yana eşikten çok hafta geçmiş; yoksa "".
static func _late_topic(state: Dictionary, world: Dictionary, side: String) -> String:
	var oldest := ""
	var since := 0
	for topic in _c.topics.catalog:
		var ts: Dictionary = state.topics[topic.id]
		if topic.side != side or ts.status == "shipped" or ts.since_day == NEVER \
				or int(_w(world, "week")) - int(ts.since_day) <= int(_c.topics.late_weeks):
			continue
		if oldest == "" or ts.since_day < since:
			oldest = topic.id
			since = int(ts.since_day)
	return oldest


## Biletin sayıldığı büyüklük: `lost` bağlı adımın bir önceki adıma (ziyaret, sepet, ödeme, sipariş) göre kaybı, `returns` iade
## edilen sipariş, öbürü teslim edilen sipariş.
static func _ticket_base(week: Dictionary, topic: Dictionary) -> float:
	match topic.base:
		"lost":
			var at: int = STEPS.find(topic.link)
			return week.get("visits" if at == 0 else STEPS[at - 1], 0.0) - week.get(topic.link, 0.0)
		"returns":
			return week.get("returns", 0.0)
	return week.get("delivered", 0.0)


## Konunun bu haftaki bileti: kullanıcı konusunda bağlı adımda sayılan büyüklük × oran, mağaza konusunda derdi olan mağazaların payı ×
## oran. Yayında olmayan her kullanıcı konusu bağlı adımı kısar, yani adım ulaşılabilir oranda iken konu zaten yayındadır.
static func _tickets(state: Dictionary, topic: Dictionary) -> float:
	var total := 0.0
	for cat in open_ids(state):
		if topic.side == "stores":
			total += state.cats[cat].stores * _c.topics.pains[topic.link] * topic.rate
		else:
			total += _ticket_base(state.cats[cat].week, topic) * topic.rate
	return total


## Kapanıştan sonra haftada bir: her konunun o haftaki biletini son dört haftaya yazar (yayındaki konuya bilet gelmez); ilk bileti
## gelen konunun yaşı o haftadan başlar.
static func tick_topics(state: Dictionary, world: Dictionary) -> void:
	for topic in _c.topics.catalog:
		var ts: Dictionary = state.topics[topic.id]
		var tickets := 0.0 if _topic_live(world, topic) else _tickets(state, topic)
		_push(ts.tickets, tickets, int(_c.topics.window_weeks))
		if tickets > 0.0 and ts.since_day == NEVER:
			ts.since_day = int(_w(world, "week"))


## Haftada etkilenen sipariş: yayındaki konuda 0. Kullanıcı konusunda konu çıkınca kazanılan teslim edilmiş sipariş (`gain`: kademe ya
## da ek özellik); adımsız `returning` konusunda kademeyle haftada iade edilmeyecek sipariş. Mağaza konusunda derdi olan mağazaların
## siparişi × o hafta ayrılma olasılığı.
static func _affected(state: Dictionary, world: Dictionary, topic: Dictionary) -> float:
	if _topic_live(world, topic):
		return 0.0
	var total := 0.0
	for cat in open_ids(state):
		var delivered: float = state.cats[cat].week.get("delivered", 0.0)
		if topic.side == "stores":
			total += delivered * _c.topics.pains[topic.link] * _leave_rate(state, world, cat)
		elif topic.link == "returning":
			var tiered := world.merged({"tiers": _w(world, "tiers").merged({topic.module: int(topic.tier)}, true)}, true)
			total += delivered * (return_rate(state, world, cat) - return_rate(state, tiered, cat))
		elif topic.has("tier"):
			total += gain(state, world, cat, {"tier": {topic.module: int(topic.tier)}})
		else:
			total += gain(state, world, cat, {"features": [topic.id]})
	return total


## Talepler'in satırları, ilk isteği gelmiş her konu için: `tickets` son dört haftanın toplamı, `affected` haftada etkilenen sipariş,
## `reason` konunun bağlı adımı ya da mağaza derdi, `age` ilk istekten bu yana hafta.
static func topic_rows(state: Dictionary, world: Dictionary) -> Array:
	var rows := []
	for topic in _c.topics.catalog:
		var ts: Dictionary = state.topics[topic.id]
		if ts.since_day != NEVER:
			rows.append({"id": topic.id, "side": topic.side, "module": topic.module, "tickets": _sum(ts.tickets),
				"affected": _affected(state, world, topic), "reason": topic.link, "status": ts.status,
				"age": int(_w(world, "week")) - int(ts.since_day), "source": ts.source})
	return rows


# --- Haftalık kapanış ------------------------------------------------------------------------

## Sıra bağlayıcıdır: mağaza akışı, ziyaret ve adımlar, iade, kullanıcı, gelir ve gider, Premium, defter. Haftanın biletleri
## (`tick_topics`, kapanıştan sonra), olay isteği ve sinyal bu çekirdeğin dışındadır.
static func close_week(state: Dictionary, world: Dictionary) -> void:
	var ids := open_ids(state)
	for cat in ids:
		state.lost.stores += _store_flow(state, world, cat)
	var member_share := 0.0
	if state.users > 0.0:
		var freq: float = _c.visits.member_freq
		member_share = state.members * freq / (state.users - state.members + state.members * freq)
	var totals := {"new": {}, "placed": 0.0, "delivered": 0.0, "net": 0.0, "member_orders": 0.0, "perks": {},
		"burn": {"return_shipping": 0.0, "campaign_shipping": 0.0, "perk_shipping": 0.0, "perk_returns": 0.0}}
	for perk in state.premium.perks:
		totals.perks[perk] = {"uses": 0.0, "cost": 0.0}
	for cat in ids:
		_close_category(state, world, cat, member_share, totals)
	var window := int(_c.income.window_weeks)
	var fresh: float = _sum(totals.new.values())
	var keep := retention(state, world)
	state.lost.users += state.users * (1.0 - keep)
	state.users = state.users * keep + fresh
	for source in totals.new:
		if not state.sources.has(source):
			state.sources[source] = []
	for source in state.sources:
		_push(state.sources[source], totals.new.get(source, 0.0), int(_c.visits.source_weeks))
	_push(state.revenue_weeks, totals.net, window)
	state.burn = totals.burn
	open_premium(state, world)
	var pr: Dictionary = state.premium
	if pr.open:
		var p: Dictionary = _c.premium
		var target: float = state.users * p.target * premium_pull(state) / (1.0 + p.fee_sensitivity * (pr.fee - p.fee_start))
		var grown: float = (target - state.members) * (p.approach_trial if pr.trial else p.approach)
		state.members += grown
		_push(pr.joined, maxf(0.0, grown) if pr.trial else 0.0, int(p.trial_weeks))
	_push(pr.orders, totals.member_orders, window)
	for perk in pr.perks:
		_push(pr.perks[perk].uses, totals.perks[perk].uses, window)
		_push(pr.perks[perk].cost, totals.perks[perk].cost, window)
	_settle(state, world, totals)


## Bir kategorinin ziyareti, dört adımı, iadesi, net komisyonu ve ayrıcalık kullanımı (kapanışın 2, 3 ve 5. adımları).
static func _close_category(state: Dictionary, world: Dictionary, cat: String, member_share: float, totals: Dictionary) -> void:
	var cs: Dictionary = state.cats[cat]
	var d: Dictionary = _cats[cat]
	var perks: Dictionary = state.premium.perks
	var fee: float = _c.rules.shipping.fee
	var vis := _visits(state, world, cat)
	var visits: float = vis.returning + vis.organic + vis.channel
	var n := _funnel(visits, step_factors(state, world, cat))
	var returns: float = n.delivered * return_rate(state, world, cat)
	var member_orders: float = n.delivered * member_share
	var use := func(perk: String, uses: float, cost: float) -> void:
		totals.perks[perk].uses += uses
		totals.perks[perk].cost += cost
	var ship_uses := 0.0
	if perks.free_shipping.pick == "premium":
		# Saklı seçimden okunur: kampanya haftasında da kargoyu kullanıcının ödeyeceği üye siparişleri sayılır.
		ship_uses = member_orders * (1.0 - _store_ships(state.policy.shipping.pick, d.big_basket_share))
		use.call("free_shipping", ship_uses, ship_uses * fee)
		totals.burn.perk_shipping += ship_uses * fee
	if policy_value(state, world, "shipping") == "free":
		totals.burn.campaign_shipping += (n.delivered - ship_uses) * fee
	if policy_value(state, world, "return_shipping") == "we_pay":
		totals.burn.return_shipping += returns * fee
	match perks.fast_delivery.pick:
		"everyone":
			use.call("fast_delivery", n.delivered, 0.0)
		"premium":
			use.call("fast_delivery", member_orders, 0.0)
	var door_uses := 0.0
	match perks.doorstep_returns.pick:
		"everyone":
			door_uses = returns
		"premium":
			door_uses = returns * member_share
	var door_cost: float = door_uses * _c.premium.perks.doorstep_returns.unit_cost
	use.call("doorstep_returns", door_uses, door_cost)
	totals.burn.perk_returns += door_cost
	var discount := 0.0
	if perks.member_discount.pick == "premium":
		discount = member_orders * _c.premium.perks.member_discount.discount * d.basket
		use.call("member_discount", member_orders, discount)
	var gross: float = (n.delivered - returns) * d.basket * cs.commission / 100.0
	var terms_cut := 0.0
	if not cs.terms.is_empty() and cs.stores > 0.0:
		terms_cut = gross * minf(1.0, _sum(cs.joined.slice(0, int(cs.terms.weeks))) / cs.stores) * (1.0 - cs.terms.share)
	var net: float = gross - terms_cut - _w(world, "campaign_discount").get(cat, 0.0) - discount
	cs.week = {"returning": vis.returning, "organic": vis.organic, "channel": vis.channel, "visits": visits, "cart": n.cart,
		"checkout": n.checkout, "order": n.order, "delivered": n.delivered, "returns": returns, "net": net}
	totals.placed += n.order
	totals.delivered += n.delivered
	totals.net += net
	totals.member_orders += member_orders
	if visits > 0.0:
		totals.new.organic = totals.new.get("organic", 0.0) + n.delivered * vis.organic / visits
		var by_source: Dictionary = _w(world, "channel").get(cat, {})
		for source in by_source:
			totals.new[source] = totals.new.get(source, 0.0) + n.delivered * by_source[source] / visits


## Yeni değer başa girer; dizi en çok `size` hafta tutar.
static func _push(weeks: Array, value: float, size: int) -> void:
	weeks.push_front(value)
	weeks.resize(mini(weeks.size(), size))


static func _sum(values: Array) -> float:
	var total := 0.0
	for value in values:
		total += value
	return total


# --- Önizleme --------------------------------------------------------------------------------

## Durumun kopyasında kapanışı önizleme süresince ileri koşar: Pazarlama'nın değerleri aynı kalır, olay ve acil durum yoktur.
static func project(state: Dictionary, world: Dictionary) -> Dictionary:
	var ahead := state.duplicate(true)
	var quiet := world.merged({"outage": 0.0, "campaign_loss": false}, true)
	for i in int(_c.preview.weeks):
		close_week(ahead, quiet.merged({"week": int(_w(world, "week")) + i}, true))
	return ahead


## Önizlemenin ve probe'un okuduğu büyüklükler; `cat` verilirse yalnız o kategori, yoksa açık kategoriler (ağırlık: geçen
## haftanın siparişi, sipariş yoksa eşit).
static func metrics(state: Dictionary, world: Dictionary, cat: String = "") -> Dictionary:
	var ids: Array = [cat] if cat != "" else open_ids(state)
	var orders := 0.0
	var acquired := 0.0
	for id in ids:
		orders += state.cats[id].week.get("delivered", 0.0)
		acquired += acquisition(state, world, id)
	var revenue := monthly_revenue(state)
	var perk_cost := 0.0
	for perk in state.premium.perks.values():
		perk_cost += _sum(perk.cost)
	return {
		"orders": orders,
		"return_rate": _weighted(state, ids, func(id: String) -> float: return return_rate(state, world, id)),
		"returning_share": returning_share(state, ids),
		"store_earnings": _weighted(state, ids, func(id: String) -> float: return store_keep(state, world, id, state.cats[id].commission)),
		"store_prices": _weighted(state, ids, func(id: String) -> float: return price_pass(id, state.cats[id].commission)),
		"store_sat": state.sat.stores,
		"user_sat": state.sat.users,
		"store_acquisition": acquired,
		"monthly_revenue": revenue.commission + revenue.membership,
		"monthly_cost": monthly_cost(state),
		"members": state.members,
		"perk_cost": perk_cost,
	}


static func _weighted(state: Dictionary, ids: Array, value: Callable) -> float:
	var weights: Array = ids.map(func(id: String) -> float: return state.cats[id].week.get("delivered", 0.0))
	var total := _sum(weights)
	var out := 0.0
	for i in ids.size():
		out += (weights[i] / total if total > 0.0 else 1.0 / ids.size()) * value.call(ids[i])
	return out


## Değişiklikle ve değişiklik olmadan dört hafta sonraki büyüklüklerin farkı; `apply` kopyaya değişikliği yazar ve reddedilirse
## false döner (önizleme boş sözlüktür).
static func _preview(state: Dictionary, world: Dictionary, cat: String, apply: Callable) -> Dictionary:
	var changed := state.duplicate(true)
	if not apply.call(changed):
		return {}
	var before := metrics(project(state, world), world, cat)
	var after := metrics(project(changed, world), world, cat)
	var diff := {}
	for key in before:
		if key in RELATIVE:
			diff[key] = after[key] / before[key] - 1.0 if before[key] != 0.0 else 0.0
		else:
			diff[key] = after[key] - before[key]
	return diff


static func preview_commission(state: Dictionary, world: Dictionary, cat: String, commission: int) -> Dictionary:
	return _preview(state, world, cat, func(s: Dictionary) -> bool: return set_commission(s, world, cat, commission))


static func preview_policy(state: Dictionary, world: Dictionary, rule: String, option: String) -> Dictionary:
	return _preview(state, world, "", func(s: Dictionary) -> bool: return set_policy(s, world, rule, option))


## `change`: `fee` (yeni ücret), `perk` ([ayrıcalık, seçenek]) ya da `trial` (ücretsiz deneme açık mı).
static func preview_premium(state: Dictionary, world: Dictionary, change: Dictionary) -> Dictionary:
	var apply: Callable
	if change.has("fee"):
		apply = func(s: Dictionary) -> bool: return set_fee(s, world, change.fee)
	elif change.has("perk"):
		apply = func(s: Dictionary) -> bool: return set_perk(s, world, change.perk[0], change.perk[1])
	else:
		apply = func(s: Dictionary) -> bool: return set_trial(s, change.trial)
	return _preview(state, world, "", apply)
