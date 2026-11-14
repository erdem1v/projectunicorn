class_name ProductCatalog
extends RefCounted

# Read-only catalog: sub-product types and the flat feature pools.
# Player-facing words live in strings.csv, derived from ids (copy accessors at the bottom).

# Dış anahtar PAZAR DEĞİL, HABER/OLAY HAVUZUDUR (GameState.subgenre; news_feed_system
# "ai" | "saas" | "social" bekler). Pazarı `market_type` söyler: "b2c" kitle + büyüme
# kararları, "b2b" aday + satış toplantısı. Bu yüzden B2C bir not aracı "saas"
# havuzunda durur. Tür seçim ekranı oynanabilir türün
# `desks`'ini (yolun açacağı masalar, PROD_DESK_*) ve `plus`/`minus`'unu (adı olan iki kavram, PROD_CONCEPT_*) okur.
const SUB_PRODUCT_TYPES := {
	"ai": [
		# K3 yönü AI (otomatik klip seçimi, altyazı zekâsı); haberleri bu yüzden "ai" havuzundan.
		{"id": "video_clip",
			"market_type": "b2c"},
		{"id": "ai_assistant",
			"market_type": "b2c"},
		{"id": "ai_photo_editor",
			"market_type": "b2c", "price_tendency": "volume"},
		{"id": "ai_code_copilot",
			"market_type": "b2c"},
		{"id": "ai_vector_search",
			"market_type": "b2b", "price_tendency": "premium"},
	],
	"saas": [
		{"id": "note_tool",
			"market_type": "b2c"},
		{"id": "erp",
			"market_type": "b2b",
			"price_tendency": "neutral",
			"desks": ["modules", "sales", "requests", "renewal"], "plus": "switching_cost", "minus": "long_sales_cycle"},
		{"id": "saas_project_mgmt",
			"market_type": "b2b"},
		{"id": "saas_crm",
			"market_type": "b2b"},
		{"id": "saas_analytics",
			"market_type": "b2b"},
		{"id": "saas_billing",
			"market_type": "b2b"},
		{"id": "saas_dev_tools",
			"market_type": "b2b", "price_tendency": "premium"},
		{"id": "saas_ops",
			"market_type": "b2b", "price_tendency": "neutral"},
		{"id": "marketplace",
			"market_type": "b2c",
			"desks": ["product_dev", "categories", "policies", "premium", "campaigns"],
			"plus": "network_effect", "minus": "chicken_egg"},
	],
}

## §12.11 — demo tip ekranı. `playable` hat içeriği olan alt-tiplerdir. B2C'nin oynanabilir türü yok: pazaryerinin tür
## ekranı arayüzü henüz yok; hattı olup burada olmayan tür `type_screen_matches_line_content`'in `waiting` listesinde
## adıyla durur.
## Kilitli kartlar düz katalogdan seçilir, §12.11 pazar başına üç der. B2B'nin üçüncüsü
## bir ürün değil §12.11'in AÇIK SLOT'udur: dördüncü B2B alt-tipi gelene kadar kilitli
## kart olarak durur.
const TYPE_SCREEN_SLOT := "b2b_open_slot"

const TYPE_SCREEN := {
	"b2c": {
		"playable": [],
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


## PostShip satış modeli. Katalogda olmayan id hatadır ve "" döner.
static func get_market_type(sub_product_type_id: String) -> String:
	var record: Dictionary = get_sub_product_type_by_id(sub_product_type_id)
	if record.is_empty():
		push_error("[ProductCatalog] unknown sub-product type '%s'" % sub_product_type_id)
		return ""
	return String(record.market_type)


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
