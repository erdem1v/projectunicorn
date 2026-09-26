class_name ProductCatalog
extends RefCounted

# Read-only catalog: sub-product types, the flat feature pools and per-type axis weights.
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


# Düz özellik havuzu (hat modeli olmayan alt-tipler). Satır alanları:
#   complexity (1-5) — commit'te bug tohumu ve risk bandı.
#   efor (5-9)       — iş miktarı; süre = Σefor / ekip hızı. Çalışma kuralı 4 + complexity,
#                      ama sapabilsin diye her satırda açık yazılır.
#   cost / cost_source ("api" | "license") — yalnız üçüncü-parti özellikte; commit'te bir
#                      kez tahsil edilir.
#   dimension_contribution — eksenlere tam sayı katkı; ship edilen eksen = seçili katkıların
#                      toplamı (ProductSystem.projected_axes), yani önizleme == ship.
const FEATURE_POOLS := {
	"ai_assistant": [
		{"id": "ai_assistant_chat", "complexity": 2, "efor": 6, "dimension_contribution": {"experience": 4}},
		{"id": "ai_assistant_memory", "complexity": 3, "efor": 7, "dimension_contribution": {"innovation": 5, "stability": 3}},
		{"id": "ai_assistant_tools", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 6}},
		{"id": "ai_assistant_voice", "complexity": 3, "efor": 7, "cost": 800, "cost_source": "api", "dimension_contribution": {"innovation": 5, "experience": 3}},
		{"id": "ai_assistant_image", "complexity": 4, "efor": 8, "cost": 1200, "cost_source": "api", "dimension_contribution": {"innovation": 6}},
		{"id": "ai_assistant_streaming", "complexity": 2, "efor": 6, "dimension_contribution": {"experience": 4}},
	],
	"ai_photo_editor": [
		{"id": "ai_photo_bg_removal", "complexity": 2, "efor": 6, "dimension_contribution": {"experience": 4}},
		{"id": "ai_photo_inpaint", "complexity": 4, "efor": 8, "cost": 1500, "cost_source": "api", "dimension_contribution": {"innovation": 6, "experience": 3}},
		{"id": "ai_photo_upscale", "complexity": 3, "efor": 7, "cost": 900, "cost_source": "license", "dimension_contribution": {"innovation": 5, "experience": 3}},
		{"id": "ai_photo_style_transfer", "complexity": 3, "efor": 7, "cost": 500, "cost_source": "license", "dimension_contribution": {"innovation": 5, "experience": 3}},
		{"id": "ai_photo_batch", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 5, "experience": 3}},
		{"id": "ai_photo_filters", "complexity": 1, "efor": 5, "dimension_contribution": {"experience": 3}},
	],
	"ai_code_copilot": [
		{"id": "ai_code_autocomplete", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 3, "experience": 5}},
		{"id": "ai_code_chat", "complexity": 2, "efor": 6, "dimension_contribution": {"experience": 4}},
		{"id": "ai_code_refactor", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 6, "stability": 3}},
		{"id": "ai_code_explain", "complexity": 2, "efor": 6, "dimension_contribution": {"experience": 4}},
		{"id": "ai_code_test_gen", "complexity": 3, "efor": 7, "dimension_contribution": {"innovation": 3, "stability": 5}},
		{"id": "ai_code_multi_file", "complexity": 5, "efor": 9, "dimension_contribution": {"innovation": 7}},
		{"id": "ai_code_diff_review", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 6, "stability": 3}},
	],
	"ai_vector_search": [
		{"id": "ai_vec_embed_api", "complexity": 3, "efor": 7, "dimension_contribution": {"innovation": 3, "stability": 5}},
		{"id": "ai_vec_search_api", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 5}},
		{"id": "ai_vec_filter", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 5, "experience": 3}},
		{"id": "ai_vec_dashboard", "complexity": 2, "efor": 6, "dimension_contribution": {"experience": 4}},
		{"id": "ai_vec_scaling", "complexity": 5, "efor": 9, "dimension_contribution": {"stability": 7}},
		{"id": "ai_vec_sdk", "complexity": 2, "efor": 6, "dimension_contribution": {"stability": 2, "experience": 4}},
	],
	"saas_project_mgmt": [
		{"id": "saas_pm_tasks", "complexity": 2, "efor": 6, "dimension_contribution": {"stability": 2, "experience": 4}},
		{"id": "saas_pm_gantt", "complexity": 3, "efor": 7, "dimension_contribution": {"experience": 5}},
		{"id": "saas_pm_comments", "complexity": 2, "efor": 6, "dimension_contribution": {"experience": 4}},
		{"id": "saas_pm_integrations", "complexity": 4, "efor": 8, "cost": 700, "cost_source": "api", "dimension_contribution": {"stability": 6, "experience": 3}},
		{"id": "saas_pm_automation", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 6, "experience": 3}},
		{"id": "saas_pm_reporting", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 3, "experience": 5}},
	],
	"saas_crm": [
		{"id": "saas_crm_contacts", "complexity": 2, "efor": 6, "dimension_contribution": {"stability": 2, "experience": 4}},
		{"id": "saas_crm_pipeline", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 3, "experience": 5}},
		{"id": "saas_crm_email", "complexity": 4, "efor": 8, "cost": 600, "cost_source": "api", "dimension_contribution": {"stability": 6, "experience": 3}},
		{"id": "saas_crm_forecast", "complexity": 3, "efor": 7, "dimension_contribution": {"innovation": 5, "experience": 3}},
		{"id": "saas_crm_mobile", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 3, "experience": 6}},
		{"id": "saas_crm_call_log", "complexity": 3, "efor": 7, "cost": 800, "cost_source": "api", "dimension_contribution": {"innovation": 5, "stability": 3}},
	],
	"saas_analytics": [
		{"id": "saas_an_dashboards", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 3, "experience": 5}},
		{"id": "saas_an_query", "complexity": 4, "efor": 8, "dimension_contribution": {"stability": 3, "experience": 6}},
		{"id": "saas_an_alerts", "complexity": 3, "efor": 7, "dimension_contribution": {"innovation": 5, "stability": 3}},
		{"id": "saas_an_share", "complexity": 2, "efor": 6, "dimension_contribution": {"stability": 2, "experience": 4}},
		{"id": "saas_an_etl", "complexity": 5, "efor": 9, "cost": 1000, "cost_source": "api", "dimension_contribution": {"stability": 7}},
		{"id": "saas_an_embed", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 6, "stability": 3}},
	],
	"saas_billing": [
		{"id": "saas_bill_subscriptions", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 5, "experience": 3}},
		{"id": "saas_bill_invoice", "complexity": 2, "efor": 6, "dimension_contribution": {"stability": 4, "experience": 2}},
		{"id": "saas_bill_tax", "complexity": 5, "efor": 9, "cost": 2000, "cost_source": "license", "dimension_contribution": {"stability": 7}},
		{"id": "saas_bill_dunning", "complexity": 3, "efor": 7, "dimension_contribution": {"innovation": 3, "stability": 5}},
		{"id": "saas_bill_webhooks", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 5}},
		{"id": "saas_bill_proration", "complexity": 4, "efor": 8, "dimension_contribution": {"stability": 6}},
	],
	"saas_dev_tools": [
		{"id": "saas_dev_cli", "complexity": 2, "efor": 6, "dimension_contribution": {"stability": 2, "experience": 4}},
		{"id": "saas_dev_api", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 5, "experience": 3}},
		{"id": "saas_dev_docs", "complexity": 3, "efor": 7, "dimension_contribution": {"experience": 5}},
		{"id": "saas_dev_ci_plugin", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 3, "stability": 6}},
		{"id": "saas_dev_logs", "complexity": 3, "efor": 7, "dimension_contribution": {"innovation": 3, "stability": 5}},
		{"id": "saas_dev_sandbox", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 5, "experience": 3}},
	],
	"saas_ops": [
		{"id": "saas_ops_workflow", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 6, "experience": 3}},
		{"id": "saas_ops_reporting", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 3, "experience": 5}},
		{"id": "saas_ops_integration", "complexity": 5, "efor": 9, "cost": 1800, "cost_source": "license", "dimension_contribution": {"stability": 7}},
		{"id": "saas_ops_scheduling", "complexity": 3, "efor": 7, "dimension_contribution": {"stability": 3, "experience": 5}},
		{"id": "saas_ops_field", "complexity": 5, "efor": 9, "dimension_contribution": {"innovation": 4, "stability": 7}},
		{"id": "saas_ops_mobile", "complexity": 4, "efor": 8, "dimension_contribution": {"innovation": 3, "experience": 6}},
	],
}


# Pazarın eksenlere verdiği ağırlık (composite_quality'ye girer); etiketler evrensel
# üçlüdür (axis_label). Kayıtlardan ayrı sözlük, tip kayıtları okunur kalsın diye.
const QUALITY_AXES := {
	# --- AI (mostly B2C) ---
	"ai_assistant": [
		{"axis": "innovation", "weight": 1.4},
		{"axis": "stability", "weight": 0.7},
		{"axis": "experience", "weight": 1.3},
	],
	"ai_photo_editor": [
		{"axis": "innovation", "weight": 1.3},
		{"axis": "stability", "weight": 0.6},
		{"axis": "experience", "weight": 1.4},
	],
	"ai_code_copilot": [
		{"axis": "innovation", "weight": 1.0},
		{"axis": "stability", "weight": 1.4},
		{"axis": "experience", "weight": 0.9},
	],
	"ai_vector_search": [
		{"axis": "innovation", "weight": 0.8},
		{"axis": "stability", "weight": 1.6},
		{"axis": "experience", "weight": 0.9},
	],
	# --- SaaS (all B2B) ---
	"saas_project_mgmt": [
		{"axis": "innovation", "weight": 0.8},
		{"axis": "stability", "weight": 1.1},
		{"axis": "experience", "weight": 1.3},
	],
	"saas_crm": [
		{"axis": "innovation", "weight": 0.8},
		{"axis": "stability", "weight": 1.2},
		{"axis": "experience", "weight": 1.2},
	],
	"saas_analytics": [
		{"axis": "innovation", "weight": 1.1},
		{"axis": "stability", "weight": 1.2},
		{"axis": "experience", "weight": 0.9},
	],
	"saas_billing": [
		{"axis": "innovation", "weight": 0.7},
		{"axis": "stability", "weight": 1.6},
		{"axis": "experience", "weight": 0.9},
	],
	"saas_dev_tools": [
		{"axis": "innovation", "weight": 1.1},
		{"axis": "stability", "weight": 1.4},
		{"axis": "experience", "weight": 0.9},
	],
	"saas_ops": [
		{"axis": "innovation", "weight": 0.9},
		{"axis": "stability", "weight": 1.5},
		{"axis": "experience", "weight": 1.1},
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


static func get_feature_by_id(feature_id: String) -> Dictionary:
	for pool_key in FEATURE_POOLS:
		for feature in FEATURE_POOLS[pool_key]:
			if feature["id"] == feature_id:
				return feature
	return {}


## PostShip satış modeli. Bilinmeyen id "b2c" okur: B2C aday hattı istemez.
static func get_market_type(sub_product_type_id: String) -> String:
	return String(get_sub_product_type_by_id(sub_product_type_id).get("market_type", "b2c"))


## "premium" | "neutral" | "volume" — SalesSystem.product_value()'nun optimumunu kaydırır.
static func get_price_tendency(sub_product_type_id: String) -> String:
	return String(get_sub_product_type_by_id(sub_product_type_id).get("price_tendency", "neutral"))


## [] for unknown ids → QualityModel falls back to equal DEFAULT_AXES.
static func get_quality_axes(sub_product_type_id: String) -> Array:
	return QUALITY_AXES.get(sub_product_type_id, [])


# ---------------------------------------------------------------- efor / maliyet / risk

const FEATURE_RISK_LOW_MAX := 2    # complexity <= 2 → "dusuk"
const FEATURE_RISK_HIGH_MIN := 4   # complexity >= 4 → "yuksek"; arası "orta"


static func get_feature_efor(feature_id: String) -> int:
	return int(get_feature_by_id(feature_id).get("efor", 0))


static func sum_efor(feature_ids: Array) -> int:
	var total: int = 0
	for fid in feature_ids:
		total += get_feature_efor(String(fid))
	return total


## {"amount": int, "source": "api" | "license" | ""}
static func get_feature_cost(feature_id: String) -> Dictionary:
	var f: Dictionary = get_feature_by_id(feature_id)
	return {"amount": int(f.get("cost", 0)), "source": String(f.get("cost_source", ""))}


static func sum_cost(feature_ids: Array) -> int:
	var total: int = 0
	for fid in feature_ids:
		total += int(get_feature_by_id(String(fid)).get("cost", 0))
	return total


## "dusuk" | "orta" | "yuksek" — ProductUiShared.risk_label çevirir.
static func feature_risk_band(complexity: int) -> String:
	if complexity <= FEATURE_RISK_LOW_MAX:
		return "dusuk"   # LOC-DATA risk band id
	if complexity >= FEATURE_RISK_HIGH_MIN:
		return "yuksek"   # LOC-DATA risk band id
	return "orta"   # LOC-DATA risk band id


# "Öner" düğmesinin ad havuzu. Özel adlar çevrilmez; seçim sırayla, koşu tekrarlanabilir.
const PRODUCT_NAME_POOL := [
	"Pulse", "Nova", "Kairo", "Vela", "Loop", "Mira", "Flux", "Orbit", "Ember", "Sable",
	"Nimbus", "Cadence", "Quill", "Atlas", "Beacon", "Ripple", "Vertex", "Halo", "Drift", "Onyx",
]


static func suggest_product_name(index: int) -> String:
	return String(PRODUCT_NAME_POOL[abs(index) % PRODUCT_NAME_POOL.size()])


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


static func axis_label(axis_id: String) -> String:
	return _derived("PROD_AXIS_", axis_id)
