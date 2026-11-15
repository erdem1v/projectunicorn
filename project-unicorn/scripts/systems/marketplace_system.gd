class_name MarketplaceSystem
extends RefCounted

# Pazaryeri ekonomisinin oyundaki sahibi: `GameState.marketplace`'in tek yazarı. Yazan seam'ler modelin işlevini
# durum ve `world()` ile çağırır; uygulananı `marketplace_changed` ile duyurur ve true döner, reddedileni duyurmaz ve false
# döner. `daily_tick` haftalık kapanıştır: pazaryeri türünde Satış yuvası onu haftada bir çağırır; durumu iki toplu müşteri
# kaydına ve Finans'ın `pazaryeri` giderine yansıtır. Durum yalnız yazan seam'lerde ve kapanışta doğar; okuyanlar boş durumu
# saklamadan modelin ilk durumuyla okur, böylece pazaryeri koşusu olmayan oyun sözlüğü hiç doldurmaz.

## Pazarlama's week, which the close reads (ORTAK_ARAYUZLER): its visits by category and source, E-posta's lift, the campaign.
const MarketingSystem := preload("res://scripts/systems/marketing_system.gd")
const TYPE_ID := "marketplace"
const STORES_ID := "co_mp_stores"
const USERS_ID := "co_mp_users"
## Modelin modül kimliğinden oyundaki hat kimliğine; paylaşılan hatlar türün son ekini taşır.
const MODULE_LINES := {
	"listing": "line_marketplace_listing", "storefront": "line_marketplace_storefront",
	"checkout": "line_marketplace_checkout", "orders": "line_marketplace_orders", "reviews": "line_marketplace_reviews",
	"mobile": "line_shared_mobile@marketplace", "integrations": "line_shared_integrations@marketplace",
	"accounts": "line_shared_security@marketplace", "backup": "line_shared_durability@marketplace",
}


## Yazanlar için: `GameState.marketplace`, boşsa modelin ilk durumuyla yerinde doldurulur.
static func _s() -> Dictionary:
	if GameState.marketplace.is_empty():
		GameState.marketplace.merge(MarketplaceModel.new_state())
	return GameState.marketplace


## Okuyanlar için (arayüz de buradan okur): durum boşsa modelin ilk durumu (saklanmaz), doluysa `GameState.marketplace`.
static func read_state() -> Dictionary:
	return GameState.marketplace if not GameState.marketplace.is_empty() else MarketplaceModel.new_state()


## Yüklenen durumda olmayan her anahtar (iç içe sözlüklerde de) modelin ilk durumundan gelir, var olan değere dokunulmaz; boş
## durum (pazaryeri koşusu olmayan oyun) boş kalır. Model eksik anahtarı varsayılanla okumaz. Yüklenen atamaların düşürmesi
## burada bağlanır (yeni koşuda ilk `assign`).
static func fill_missing_state() -> void:
	if not GameState.marketplace.is_empty():
		_fill(GameState.marketplace, MarketplaceModel.new_state())
		_watch_staffing()


static func _fill(have: Dictionary, initial: Dictionary) -> void:
	for key in initial:
		if not have.has(key):
			have[key] = initial[key]
		elif initial[key] is Dictionary and have[key] is Dictionary:
			_fill(have[key], initial[key])


## Modelin bu hafta için okuduğu dünya: sahiplerden kurulur, verilmeyen alan modelin varsayılanında kalır.
static func world() -> Dictionary:
	var open_bugs: Dictionary = ProductState.open_bugs_by_line()
	var tiers := {"membership": SprintCatalog.tier(SprintCatalog.PAID_PLAN)}
	var bugs := {}
	for module in MODULE_LINES:
		tiers[module] = ProductState.line_tier(MODULE_LINES[module])
		bugs[module] = int(open_bugs.get(MODULE_LINES[module], 0))
	var stars := {}
	# Ar-Ge'nin duraklattığı Satış işi atamayı tutar ama o hafta kazandırmaz.
	for person in read_state().assign:
		var c: Character = CharacterRegistry.get_character(person)
		if _can_work(c) and HRConstants.JOB_SALES in c.assigned_job_ids:
			stars[person] = int(sales_stars(c))
	return {"week": GameState.day, "published": ProductState.is_live(), "tiers": tiers, "bugs": bugs, "stars": stars,
		"unanswered": SupportSystem.unanswered_share(), "planned": _planned(),
		"channel": MarketingSystem.market_visits(), "return_lift": MarketingSystem.return_lift(),
		"campaign": MarketingSystem.active_campaign()}


# --- Yazan seam'ler -----------------------------------------------------------------------------

static func _written(applied: bool) -> bool:
	if applied:
		EventBus.marketplace_changed.emit()
	return applied


static func open_category(cat: String) -> bool:
	return _written(MarketplaceModel.open_category(_s(), world(), cat))


static func set_commission(cat: String, commission: int) -> bool:
	return _written(MarketplaceModel.set_commission(_s(), world(), cat, commission))


static func set_policy(rule: String, option: String) -> bool:
	return _written(MarketplaceModel.set_policy(_s(), world(), rule, option))


static func set_fee(fee: int) -> bool:
	return _written(MarketplaceModel.set_fee(_s(), world(), fee))


static func set_perk(perk: String, option: String) -> bool:
	return _written(MarketplaceModel.set_perk(_s(), world(), perk, option))


static func set_trial(on: bool) -> bool:
	return _written(MarketplaceModel.set_trial(_s(), on))


static func set_store_terms(cat: String, share: float, weeks: int) -> bool:
	return _written(MarketplaceModel.set_store_terms(_s(), cat, share, weeks))


static func add_users(n: float) -> bool:
	return _written(MarketplaceModel.add_users(_s(), n))


static func waive_commission(weeks: int) -> bool:
	return _written(MarketplaceModel.waive_commission(_s(), weeks))


## Olayın memnuniyet etkisi bir toplu kayıtta: tarafın defterine süreli bir satır (`note_decision`). Satır hemen görünür, sayı
## izleyen kapanışlarda hedefe yürür; kaydın memnuniyeti kapanışın yansımasıdır. Pazaryerinin kaydı değilse false.
static func add_satisfaction(record_id: String, amount: int) -> bool:
	var side: String = {USERS_ID: "users", STORES_ID: "stores"}.get(record_id, "")
	return side != "" and _written(MarketplaceModel.note_decision(_s(), side, amount))


## Bileti olmayan konuyu rapordan açar: `affected` haftalık etkilenen sipariş.
static func open_topic(id: String, affected: float) -> bool:
	return _written(MarketplaceModel.open_topic(_s(), world(), id, affected))


## Atanabilen: işbaşındaki kurucu ya da Satış Temsilcisi.
static func _can_work(c: Character) -> bool:
	return c != null and c.status == HRConstants.STATUS_ACTIVE and (c.category == "founder" or c.role == HRConstants.ROLE_SALES_REP)


## Atanabilenler: işbaşındaki kurucu ve Satış Temsilcileri.
static func assignable() -> Array:
	return CharacterRegistry.get_all().filter(_can_work)


## Satış işini alamayan: Satış'ı yok ve sürekli işleri (duraklamışlar dahil, iş tavanını Ekip'in kaydı böyle sayar) dolu.
static func at_job_cap(c: Character) -> bool:
	var held: Array = c.assigned_job_ids + c.paused_job_ids
	return HRConstants.JOB_SALES not in held and held.filter(HRConstants.is_continuous_job).size() >= HRConstants.MAX_JOBS_PER_PERSON


## Kişinin kazanımdaki Satış yıldızı: kurucu 1, Temsilci Satış becerisinin yıldızı (yarım yıldızıyla; model tam yıldızı okur).
static func sales_stars(c: Character) -> float:
	return 1.0 if c.category == "founder" else HRConstants.stars_for(HRSystem.skill(c, HRConstants.AREA_SALES))


## Atama kişiye Satış işini de verir (kurucunun sprint payı Satış işindeki kadar azalır); iş verilemezse (iş tavanı) atama olmaz.
## İş önce verilir: işin sinyalini dinleyen düşürme, Satış işi henüz verilmemiş atamayı görmesin. Model reddederse bu çağrının
## verdiği iş geri alınır.
static func assign(person: String, cat: String) -> bool:
	var c: Character = CharacterRegistry.get_character(person)
	if not _can_work(c):
		return false
	_watch_staffing()
	var had: bool = HRConstants.JOB_SALES in c.assigned_job_ids + c.paused_job_ids
	if CharacterRegistry.assign_job(person, HRConstants.JOB_SALES) != "":
		return false
	if not MarketplaceModel.assign(_s(), person, cat):
		if not had:
			CharacterRegistry.unassign_job(person, HRConstants.JOB_SALES)
		return false
	return _written(true)


## Ataması kalkan kişinin atamayla aldığı Satış işi de kalkar; Satış Temsilcisi işini işe alımda almıştır, işi kalır.
static func unassign(person: String) -> bool:
	var applied := MarketplaceModel.unassign(_s(), person)
	if applied and CharacterRegistry.get_character(person).role != HRConstants.ROLE_SALES_REP:
		CharacterRegistry.unassign_job(person, HRConstants.JOB_SALES)
	return _written(applied)


## Atama Satış işine ve kişinin kaydına bağlıdır: Ekip'te Satış işi kalkınca ya da kişi ayrılınca atama kapanışı beklemeden düşer.
static func _watch_staffing() -> void:
	if not EventBus.assignment_changed.is_connected(_on_staffing_changed):
		EventBus.assignment_changed.connect(_on_staffing_changed)
		EventBus.character_removed.connect(_on_staffing_changed)


## Duraklamış Satış işi (Ar-Ge'ye geçen kişi) atamayı tutar; izne ya da eğitime giden kişinin işi ve ataması kalır.
static func _on_staffing_changed(_id: String) -> void:
	var state := read_state()
	var dropped := false
	for person in state.assign.keys():
		var c: Character = CharacterRegistry.get_character(person)
		if c == null or not (HRConstants.JOB_SALES in c.assigned_job_ids or HRConstants.JOB_SALES in c.paused_job_ids):
			MarketplaceModel.unassign(state, person)
			dropped = true
	_written(dropped)


# --- Okuyucular: saklanan durumdan okur, kapanış koşturmaz --------------------------------------

static func policy_value(rule: String) -> String:
	return MarketplaceModel.policy_value(read_state(), world(), rule)


static func channel_read(cat: String) -> Dictionary:
	return MarketplaceModel.channel_read(read_state(), world(), cat)


static func source_revenue(source: String) -> float:
	return MarketplaceModel.source_revenue(read_state(), world(), source)


static func source_new_users(source: String) -> float:
	return MarketplaceModel.source_new_users(read_state(), source)


## Geçen kapanışın satış hacmi: açık kategorilerin toplamı.
static func week_gmv() -> float:
	var state := read_state()
	var total := 0.0
	for cat in MarketplaceModel.open_ids(state):
		total += MarketplaceModel.gmv(state, cat)
	return total


## Komisyonsuz bir haftanın bedeli: geçen kapanışta alınacak komisyon (yeni mağaza şartının payı düşülmüş).
static func week_commission() -> int:
	return roundi(MarketplaceModel.week_commission(read_state()))


## Açık kategorilerin mağaza toplamı.
static func stores() -> float:
	var state := read_state()
	var total := 0.0
	for cat in MarketplaceModel.open_ids(state):
		total += state.cats[cat].stores
	return total


## Aktif kullanıcı.
static func users() -> float:
	return read_state().users


## Geçen haftanın yeni kullanıcısı: bütün kaynakların ilk haftası.
static func new_users() -> float:
	return read_state().sources.values().reduce(func(total: float, weeks: Array) -> float: return total + weeks[0], 0.0)


## Ücret ödeyen üye.
static func paying_members() -> float:
	return MarketplaceModel.paying_members(read_state())


## Kapanışlarda kaybedilen kullanıcının birikmiş toplamı.
static func lost_users() -> float:
	return read_state().lost.users


## Aktif kullanıcının akışı, takvim saati başına: geçen haftanın yeni kullanıcısı eksi elde tutulamayan kullanıcı
## (kullanıcı × (1 − elde tutma)); kayıp bugünkü kullanıcıyla orantılıdır.
static func users_change_per_hour() -> float:
	var state := read_state()
	var lost: float = state.users * (1.0 - MarketplaceModel.retention(state, world()))
	return (new_users() - lost) / float(TimeModel.HOURS_PER_DAY * TimeModel.DAYS_PER_TICK)


## Talepler'in satırları: modelin satırları ve her satırın kartının kimliği; kademe konusunda modülün o kademesinin özellik kartı
## (`feat:<adım>`), ek özellikte `ext:<konu>`.
static func request_topics() -> Array:
	var tiers := MarketplaceModel.tier_topics()
	var rows: Array = MarketplaceModel.topic_rows(read_state(), world())
	for row in rows:
		row.card_id = _tier_card(tiers[row.id]) if tiers.has(row.id) else "ext:" + row.id
	return rows


## Kademe konusunun kartının kimliği: modülün o kademesinin adımının özellik kartı.
static func _tier_card(topic: Dictionary) -> String:
	return "feat:" + _tier_step(topic)


## Kademe konusunun adımının kimliği: modülün o kademesi.
static func _tier_step(topic: Dictionary) -> String:
	return String(ProductLines.step_at(MODULE_LINES[topic.module], topic.tier).id)


## Konunun oyuncuya görünen adı, tek yerden: kademe konusunda modülün o kademesinin adı, ek özellikte konunun kendi metni
## (`MP_TOPIC_<KİMLİK>`).
static func topic_name(id: String) -> String:
	var tiers := MarketplaceModel.tier_topics()
	if tiers.has(id):
		return SprintCatalog.step_name(_tier_step(tiers[id]))
	return TranslationServer.translate("MP_TOPIC_" + id.to_upper())


## Kartı koşan sprintte ya da sonraki sütunda duran kademe konularının kimliği.
static func _planned() -> Array:
	var cards: Array = GameState.product.get("sprint", {}).get("cards", []) + GameState.product.get("next", {}).get("cards", [])
	var tiers := MarketplaceModel.tier_topics()
	return tiers.keys().filter(func(id: String) -> bool: return _tier_card(tiers[id]) in cards)


# --- Haftalık kapanış ---------------------------------------------------------------------------

static func daily_tick() -> void:
	if not ProductState.is_live():
		return
	var state := _s()
	var w := world()
	MarketplaceModel.close_week(state, w)
	MarketplaceModel.tick_topics(state, w)
	_reflect(state)
	FinanceSystem.set_burn_category("pazaryeri", FinanceSystem.daily_rate(roundi(MarketplaceModel.monthly_cost(state))))
	EventBus.marketplace_changed.emit()


## Kapanışın durumunu iki kayda yazar: komisyon mağazalar kaydının, üyelik kullanıcılar kaydının MRR'ı; koltuk mağaza sayısı
## ve ücret ödeyen üye; memnuniyet modelin `sat`'ı. Kayıtlar yayından sonraki ilk kapanışta doğar.
static func _reflect(state: Dictionary) -> void:
	var income: Dictionary = MarketplaceModel.monthly_revenue(state)
	var records := {
		STORES_ID: {"name": "MP_STORES_RECORD", "mrr": income.commission, "seats": stores(), "sat": state.sat.stores},
		USERS_ID: {"name": "MP_USERS_RECORD", "mrr": income.membership, "seats": MarketplaceModel.paying_members(state),
			"sat": state.sat.users},
	}
	for id in records:
		var r: Dictionary = records[id]
		if CustomerRegistry.get_customer(id) == null:
			var record := Customer.new()
			record.id = id
			record.name_key = r.name
			record.name_arg = SalesSystem.product_display_name()
			record.industry = "consumer"
			record.company_size = "individual"
			record.market_type = "b2c"
			record.acquisition_source = "organic"
			record.acquired_on_day = GameState.day
			CustomerRegistry.add(record)
		CustomerRegistry.set_mrr(id, roundi(r.mrr))
		CustomerRegistry.set_seats(id, roundi(r.seats))
		CustomerRegistry.set_satisfaction(id, roundi(r.sat))
	SalesSystem.reflect_mrr()
