class_name ProductCatalog
extends RefCounted

# Read-only catalog: sub-product types and the flat feature pools.
# Player-facing words live in strings.csv, derived from ids (copy accessors at the bottom).

# Dış anahtar PAZAR DEĞİL, HABER/OLAY HAVUZUDUR (GameState.subgenre; news_feed_system
# "ai" | "saas" | "social" bekler). Pazarı `market_type` söyler: "b2c" kitle + büyüme
# kararları, "b2b" aday + satış toplantısı. Bu yüzden B2C bir not aracı "saas"
# havuzunda durur. `sectors` kart chip'leri ve SECTOR_* satırlarıdır.
const SUB_PRODUCT_TYPES := {
	"ai": [
		# K3 yönü AI (otomatik klip seçimi, altyazı zekâsı); haberleri bu yüzden "ai" havuzundan.
		{"id": "video_clip",
			"sectors": ["consumer", "social_media", "media"], "market_type": "b2c"},
		{"id": "ai_assistant",
			"sectors": ["consumer", "education", "productivity"], "market_type": "b2c"},
		{"id": "ai_photo_editor",
			"sectors": ["consumer", "social_media", "ecommerce"], "market_type": "b2c", "price_tendency": "volume"},
		{"id": "ai_code_copilot",
			"sectors": ["software", "technology"], "market_type": "b2c"},
		{"id": "ai_vector_search",
			"sectors": ["enterprise", "finance", "legal"], "market_type": "b2b", "price_tendency": "premium"},
	],
	"saas": [
		{"id": "note_tool",
			"sectors": ["consumer", "productivity", "education"], "market_type": "b2c"},
		{"id": "erp",
			"sectors": ["manufacturing", "retail", "logistics"], "market_type": "b2b",
			"price_tendency": "neutral"},
		{"id": "saas_project_mgmt",
			"sectors": ["agency", "software", "construction"], "market_type": "b2b"},
		{"id": "saas_crm",
			"sectors": ["sales", "insurance", "real_estate"], "market_type": "b2b"},
		{"id": "saas_analytics",
			"sectors": ["retail", "finance", "media"], "market_type": "b2b"},
		{"id": "saas_billing",
			"sectors": ["saas", "subscription", "fintech"], "market_type": "b2b"},
		{"id": "saas_dev_tools",
			"sectors": ["software", "technology", "fintech"], "market_type": "b2b", "price_tendency": "premium"},
		{"id": "saas_ops",
			"sectors": ["construction", "logistics", "health"], "market_type": "b2b", "price_tendency": "neutral"},
	],
}

## §12.11 — demo tip ekranı. `playable` hat içeriği olan alt-tiplerdir ve
## ProductLines.subtypes() ile birebir eşleşir (smoke: line_subtypes_match_type_screen).
## Kilitli kartlar düz katalogdan seçilir, §12.11 pazar başına üç der. B2B'nin üçüncüsü
## bir ürün değil §12.11'in AÇIK SLOT'udur: dördüncü B2B alt-tipi gelene kadar kilitli
## kart olarak durur.
const TYPE_SCREEN_SLOT := "b2b_open_slot"

const TYPE_SCREEN := {
	"b2c": {
		"playable": ["note_tool", "video_clip"],
		"locked": ["ai_code_copilot", "ai_photo_editor", "ai_assistant"],
	},
	"b2b": {
		"playable": ["erp"],
		"locked": ["ai_vector_search", "saas_crm", TYPE_SCREEN_SLOT],
	},
}


## Tip ekranının oynanabilir kartları.
static func playable_types(market: String) -> Array:
	var out: Array = []
	for tid in (TYPE_SCREEN.get(market, {}) as Dictionary).get("playable", []):
		var st: Dictionary = get_sub_product_type_by_id(String(tid))
		if not st.is_empty():
			out.append(st)
	return out


## Tip ekranının kilitli kartları. Açık slot katalog kaydı olmadığı için kimlik döner;
## kartı çizen taraf onu kendi metniyle ayırır.
static func locked_type_ids(market: String) -> Array:
	return ((TYPE_SCREEN.get(market, {}) as Dictionary).get("locked", []) as Array).duplicate()


# Düz özellik havuzu (hat modeli olmayan alt-tipler): satışın acı noktaları ve sözleri bu
# kimlikleri okur.
const FEATURE_POOLS := {
	"ai_assistant": [
		{"id": "ai_assistant_chat"},
		{"id": "ai_assistant_memory"},
		{"id": "ai_assistant_tools"},
		{"id": "ai_assistant_voice"},
		{"id": "ai_assistant_image"},
		{"id": "ai_assistant_streaming"},
	],
	"ai_photo_editor": [
		{"id": "ai_photo_bg_removal"},
		{"id": "ai_photo_inpaint"},
		{"id": "ai_photo_upscale"},
		{"id": "ai_photo_style_transfer"},
		{"id": "ai_photo_batch"},
		{"id": "ai_photo_filters"},
	],
	"ai_code_copilot": [
		{"id": "ai_code_autocomplete"},
		{"id": "ai_code_chat"},
		{"id": "ai_code_refactor"},
		{"id": "ai_code_explain"},
		{"id": "ai_code_test_gen"},
		{"id": "ai_code_multi_file"},
		{"id": "ai_code_diff_review"},
	],
	"ai_vector_search": [
		{"id": "ai_vec_embed_api"},
		{"id": "ai_vec_search_api"},
		{"id": "ai_vec_filter"},
		{"id": "ai_vec_dashboard"},
		{"id": "ai_vec_scaling"},
		{"id": "ai_vec_sdk"},
	],
	"saas_project_mgmt": [
		{"id": "saas_pm_tasks"},
		{"id": "saas_pm_gantt"},
		{"id": "saas_pm_comments"},
		{"id": "saas_pm_integrations"},
		{"id": "saas_pm_automation"},
		{"id": "saas_pm_reporting"},
	],
	"saas_crm": [
		{"id": "saas_crm_contacts"},
		{"id": "saas_crm_pipeline"},
		{"id": "saas_crm_email"},
		{"id": "saas_crm_forecast"},
		{"id": "saas_crm_mobile"},
		{"id": "saas_crm_call_log"},
	],
	"saas_analytics": [
		{"id": "saas_an_dashboards"},
		{"id": "saas_an_query"},
		{"id": "saas_an_alerts"},
		{"id": "saas_an_share"},
		{"id": "saas_an_etl"},
		{"id": "saas_an_embed"},
	],
	"saas_billing": [
		{"id": "saas_bill_subscriptions"},
		{"id": "saas_bill_invoice"},
		{"id": "saas_bill_tax"},
		{"id": "saas_bill_dunning"},
		{"id": "saas_bill_webhooks"},
		{"id": "saas_bill_proration"},
	],
	"saas_dev_tools": [
		{"id": "saas_dev_cli"},
		{"id": "saas_dev_api"},
		{"id": "saas_dev_docs"},
		{"id": "saas_dev_ci_plugin"},
		{"id": "saas_dev_logs"},
		{"id": "saas_dev_sandbox"},
	],
	"saas_ops": [
		{"id": "saas_ops_workflow"},
		{"id": "saas_ops_reporting"},
		{"id": "saas_ops_integration"},
		{"id": "saas_ops_scheduling"},
		{"id": "saas_ops_field"},
		{"id": "saas_ops_mobile"},
	],
}


## Tüm havuzların birleşimi: tip oyun içinde seçilir ve seçim GameState.subgenre'yi
## tipin havuzundan yazar.
static func get_all_sub_product_types() -> Array:
	var all: Array = []
	for subgenre_key in SUB_PRODUCT_TYPES:
		all.append_array(SUB_PRODUCT_TYPES[subgenre_key])
	return all


## Pool (subgenre key) a sub-product type belongs to; "" if unknown.
static func get_pool_of(sub_product_type_id: String) -> String:
	for subgenre_key in SUB_PRODUCT_TYPES:
		for sub_type in SUB_PRODUCT_TYPES[subgenre_key]:
			if sub_type["id"] == sub_product_type_id:
				return subgenre_key
	return ""


static func get_sub_product_type_by_id(id: String) -> Dictionary:
	for sub_type in get_all_sub_product_types():
		if sub_type["id"] == id:
			return sub_type
	return {}


static func get_feature_pool(sub_product_type_id: String) -> Array:
	return FEATURE_POOLS.get(sub_product_type_id, [])


## PostShip satış modeli. Bilinmeyen id "b2c" okur: B2C aday hattı istemez.
static func get_market_type(sub_product_type_id: String) -> String:
	return String(get_sub_product_type_by_id(sub_product_type_id).get("market_type", "b2c"))


## "premium" | "neutral" | "volume" — SalesSystem.product_value()'nun optimumunu kaydırır.
static func get_price_tendency(sub_product_type_id: String) -> String:
	return String(get_sub_product_type_by_id(sub_product_type_id).get("price_tendency", "neutral"))


# ---------------------------------------------------------------- copy accessors
# Anahtarlar id'den türetilir (PROD_TYPE_<ID>_NAME …); tr("LITERAL") grep'i onları
# göremediği için `loc_product_derived_keys` smoke'u gerçek id listelerini gezer.
# Eksik satır ham id'ye düşer. Statik dosya: tr() değil TranslationServer.

static func _derived(prefix: String, id: String, suffix: String = "") -> String:
	if id == "":
		return ""
	var key: String = prefix + id.to_upper() + suffix
	var out: String = TranslationServer.translate(key)
	return out if out != key else id


static func type_name(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_NAME")


static func type_category(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_CATEGORY")


static func type_desc(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_DESC")


## Tipin altındaki tek satırlık "ne kazanırsın, neye mal olur" cümlesi.
static func type_tradeoff(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_TRADEOFF")


static func type_sector_labels(sub_product_type_id: String) -> Array:
	var out: Array = []
	for sid in get_sub_product_type_by_id(sub_product_type_id).get("sectors", []):
		out.append(_derived("SECTOR_", String(sid)))
	return out
