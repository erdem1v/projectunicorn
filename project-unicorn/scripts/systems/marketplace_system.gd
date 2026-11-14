class_name MarketplaceSystem
extends RefCounted

# Pazaryeri ekonomisinin oyundaki sahibi: `GameState.marketplace`'in tek yazarı. Yazan seam'ler modelin aynı adlı işlevini
# durum ve `world()` ile çağırır; uygulananı `marketplace_changed` ile duyurur ve true döner, reddedileni duyurmaz ve false
# döner. `daily_tick` haftalık kapanıştır ve durumu iki toplu müşteri kaydına yansıtır. Durum yalnız yazan seam'lerde ve
# kapanışta doğar; okuyanlar boş durumu saklamadan modelin ilk durumuyla okur, böylece pazaryeri koşusu olmayan oyun sözlüğü
# hiç doldurmaz.

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


## Okuyanlar için: durum boşsa modelin ilk durumu (saklanmaz), doluysa `GameState.marketplace`.
static func _read() -> Dictionary:
	return GameState.marketplace if not GameState.marketplace.is_empty() else MarketplaceModel.new_state()


## Modelin bu hafta için okuduğu dünya: sahiplerden kurulur, verilmeyen alan modelin varsayılanında kalır.
static func world() -> Dictionary:
	var open_bugs: Dictionary = ProductState.open_bugs_by_line()
	var tiers := {"membership": SprintCatalog.tier(SprintCatalog.PAID_PLAN)}
	var bugs := {}
	for module in MODULE_LINES:
		tiers[module] = ProductState.line_tier(MODULE_LINES[module])
		bugs[module] = int(open_bugs.get(MODULE_LINES[module], 0))
	var stars := {}
	for person in _read().assign:
		var c: Character = CharacterRegistry.get_character(person)
		stars[person] = 1 if c.category == "founder" else int(HRConstants.stars_for(HRSystem.skill(c, HRConstants.AREA_SALES)))
	return {"week": GameState.day, "published": ProductState.is_live(), "tiers": tiers, "bugs": bugs, "stars": stars}


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


# --- Okuyucular: saklanan durumdan okur, kapanış koşturmaz --------------------------------------

static func policy_value(rule: String) -> String:
	return MarketplaceModel.policy_value(_read(), world(), rule)


static func channel_read(cat: String) -> Dictionary:
	return MarketplaceModel.channel_read(_read(), world(), cat)


static func source_revenue(source: String) -> float:
	return MarketplaceModel.source_revenue(_read(), world(), source)


## Açık kategorilerin mağaza toplamı.
static func stores() -> float:
	var state := _read()
	var total := 0.0
	for cat in MarketplaceModel.open_ids(state):
		total += state.cats[cat].stores
	return total


# --- Haftalık kapanış ---------------------------------------------------------------------------

static func daily_tick() -> void:
	if not ProductState.is_live():
		return
	var state := _s()
	var w := world()
	MarketplaceModel.close_week(state, w)
	MarketplaceModel.tick_topics(state, w)
	_reflect(state)
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
