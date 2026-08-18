class_name ProductCatalog
extends RefCounted

# Read-only catalog data for sub-product types and feature pools.
# Hardcoded for demo; JSON externalization to data/products/ is content-phase
# work. Voice strings are working drafts — Erdem revises in content pass.

# market_type ("b2c" | "b2b") drives the PostShip sales model (Spec PostShip §A):
# B2C → audience/organic + growth decisions; B2B → prospect + pitch dialogue.
# First pass is binary; hybrids are future work. Erdem may revise the marking.
# Product Lifecycle Part 1: `name_human` = jargon-free display name, `bet` =
# founder-voice market bet (shown as the type card's two lines). `name` kept as a
# short internal label + fallback. Multi-Modal App removed (Erdem: "kimse tıklamaz").
# Design-doc redesign (Part 1): `category_tr` (mono kategori alt-etiketi) + `desc_tr`
# (tek satır kart açıklaması) DISPLAY-ONLY — yalnız product_tab kart görseli okur,
# hiçbir hesaba girmez.
# Rev3 creation step 02: `sectors_tr` (kart chip'leri) + `plus_minus_tr` (tek satır
# artı/eksi cümlesi) DISPLAY-ONLY working copy — hesaba girmez.
# İçerik working-metin — Erdem voice-pass bekliyor (final copy kilitlemeyin).
const SUB_PRODUCT_TYPES := {
	"ai": [
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
	"social": [],
}

# Rev3 feature record shape — each feature carries:
#   complexity (1-5) — bug seeding (_seed_feature_bugs, _accrue_bugs_hourly) + risk band.
#   efor (5-9)       — iş miktarı; build süresi = Σefor / ekip hızı. Working kural
#                      efor = 4 + complexity, SATIR BAŞINA AÇIK yazılır (Erdem sapabilir).
#   pull    (1-5) — audience draw.
#   stakes  (1-5) — reputation damage multiplier if this area breaks.
#   cost / cost_source ("api"|"license") — YALNIZ 11 üçüncü-parti feature'da; yoksa 0.
#     Commit'te BİR KEZ tahsil edilir (FinanceSystem.apply_one_time_cost).
#   dimension_contribution — 1-2 eksene TAM SAYI katkı ({innovation, stability, experience}).
#     Rev3 deterministik model: ship edilen eksen değeri = seçili katkıların toplamı
#     (ProductSystem.projected_axes). Önizleme == ship, yapısal garanti.
#   requires_research (bool) — Ar-Ge kilidi; 5 cx-5 feature'da true (UI kilitli çizer).
#
# BALANCE CONSEQUENCE (flag, do NOT retune here): deterministic sums read LOWER into
# normalized quality than the old grown axes (v1 composite ~7-12 → normalized ~12-20
# vs eski ~25-35). Startup rivals (31-82, asimptot 100) fresh v1'in üstünde başlar —
# oyuncu lige sondan girer, v2/v3 + strengthen ile tırmanır (intended pressure).
# Knobs for Erdem's balance pass: QualityModel.NORMALIZE_HALF_SAT (50 → ~25) veya
# global katkı ölçeği (bu tablo ×1.5). İkisine de BURADA dokunmayın.
# İçerik working-metin — Erdem voice-pass bekliyor (final copy kilitlemeyin).
const FEATURE_POOLS := {
	"ai_assistant": [
		{"id": "ai_assistant_chat", "complexity": 2, "efor": 6, "pull": 4, "stakes": 2, "dimension_contribution": {"experience": 4}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_memory", "complexity": 3, "efor": 7, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 5, "stability": 3}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_tools", "complexity": 4, "efor": 8, "pull": 5, "stakes": 5, "dimension_contribution": {"innovation": 6}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_voice", "complexity": 3, "efor": 7, "pull": 4, "stakes": 3, "cost": 800, "cost_source": "api", "dimension_contribution": {"innovation": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_image", "complexity": 4, "efor": 8, "pull": 4, "stakes": 4, "cost": 1200, "cost_source": "api", "dimension_contribution": {"innovation": 6}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_streaming", "complexity": 2, "efor": 6, "pull": 3, "stakes": 1, "dimension_contribution": {"experience": 4}, "requires_research": false, "tags": []},
	],
	"ai_photo_editor": [
		{"id": "ai_photo_bg_removal", "complexity": 2, "efor": 6, "pull": 5, "stakes": 2, "dimension_contribution": {"experience": 4}, "requires_research": false, "tags": []},
		{"id": "ai_photo_inpaint", "complexity": 4, "efor": 8, "pull": 5, "stakes": 4, "cost": 1500, "cost_source": "api", "dimension_contribution": {"innovation": 6, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "ai_photo_upscale", "complexity": 3, "efor": 7, "pull": 4, "stakes": 3, "cost": 900, "cost_source": "license", "dimension_contribution": {"innovation": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "ai_photo_style_transfer", "complexity": 3, "efor": 7, "pull": 4, "stakes": 2, "cost": 500, "cost_source": "license", "dimension_contribution": {"innovation": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "ai_photo_batch", "complexity": 3, "efor": 7, "pull": 3, "stakes": 3, "dimension_contribution": {"stability": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "ai_photo_filters", "complexity": 1, "efor": 5, "pull": 3, "stakes": 1, "dimension_contribution": {"experience": 3}, "requires_research": false, "tags": []},
	],
	"ai_code_copilot": [
		{"id": "ai_code_autocomplete", "complexity": 3, "efor": 7, "pull": 5, "stakes": 4, "dimension_contribution": {"stability": 3, "experience": 5}, "requires_research": false, "tags": []},
		{"id": "ai_code_chat", "complexity": 2, "efor": 6, "pull": 4, "stakes": 2, "dimension_contribution": {"experience": 4}, "requires_research": false, "tags": []},
		{"id": "ai_code_refactor", "complexity": 4, "efor": 8, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 6, "stability": 3}, "requires_research": false, "tags": []},
		{"id": "ai_code_explain", "complexity": 2, "efor": 6, "pull": 3, "stakes": 1, "dimension_contribution": {"experience": 4}, "requires_research": false, "tags": []},
		{"id": "ai_code_test_gen", "complexity": 3, "efor": 7, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 3, "stability": 5}, "requires_research": false, "tags": []},
		{"id": "ai_code_multi_file", "complexity": 5, "efor": 9, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 7}, "requires_research": true, "tags": []},
		{"id": "ai_code_diff_review", "complexity": 4, "efor": 8, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 6, "stability": 3}, "requires_research": false, "tags": []},
	],
	"ai_vector_search": [
		{"id": "ai_vec_embed_api", "complexity": 3, "efor": 7, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 3, "stability": 5}, "requires_research": false, "tags": []},
		{"id": "ai_vec_search_api", "complexity": 3, "efor": 7, "pull": 3, "stakes": 4, "dimension_contribution": {"stability": 5}, "requires_research": false, "tags": []},
		{"id": "ai_vec_filter", "complexity": 3, "efor": 7, "pull": 3, "stakes": 3, "dimension_contribution": {"stability": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "ai_vec_dashboard", "complexity": 2, "efor": 6, "pull": 2, "stakes": 2, "dimension_contribution": {"experience": 4}, "requires_research": false, "tags": []},
		{"id": "ai_vec_scaling", "complexity": 5, "efor": 9, "pull": 3, "stakes": 5, "dimension_contribution": {"stability": 7}, "requires_research": true, "tags": []},
		{"id": "ai_vec_sdk", "complexity": 2, "efor": 6, "pull": 3, "stakes": 3, "dimension_contribution": {"stability": 2, "experience": 4}, "requires_research": false, "tags": []},
	],
	"saas_project_mgmt": [
		{"id": "saas_pm_tasks", "complexity": 2, "efor": 6, "pull": 4, "stakes": 2, "dimension_contribution": {"stability": 2, "experience": 4}, "requires_research": false, "tags": []},
		{"id": "saas_pm_gantt", "complexity": 3, "efor": 7, "pull": 3, "stakes": 2, "dimension_contribution": {"experience": 5}, "requires_research": false, "tags": []},
		{"id": "saas_pm_comments", "complexity": 2, "efor": 6, "pull": 3, "stakes": 2, "dimension_contribution": {"experience": 4}, "requires_research": false, "tags": []},
		{"id": "saas_pm_integrations", "complexity": 4, "efor": 8, "pull": 4, "stakes": 4, "cost": 700, "cost_source": "api", "dimension_contribution": {"stability": 6, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "saas_pm_automation", "complexity": 4, "efor": 8, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 6, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "saas_pm_reporting", "complexity": 3, "efor": 7, "pull": 3, "stakes": 2, "dimension_contribution": {"stability": 3, "experience": 5}, "requires_research": false, "tags": []},
	],
	"saas_crm": [
		{"id": "saas_crm_contacts", "complexity": 2, "efor": 6, "pull": 3, "stakes": 3, "dimension_contribution": {"stability": 2, "experience": 4}, "requires_research": false, "tags": []},
		{"id": "saas_crm_pipeline", "complexity": 3, "efor": 7, "pull": 4, "stakes": 3, "dimension_contribution": {"stability": 3, "experience": 5}, "requires_research": false, "tags": []},
		{"id": "saas_crm_email", "complexity": 4, "efor": 8, "pull": 4, "stakes": 5, "cost": 600, "cost_source": "api", "dimension_contribution": {"stability": 6, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "saas_crm_forecast", "complexity": 3, "efor": 7, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "saas_crm_mobile", "complexity": 4, "efor": 8, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 3, "experience": 6}, "requires_research": false, "tags": []},
		{"id": "saas_crm_call_log", "complexity": 3, "efor": 7, "pull": 3, "stakes": 3, "cost": 800, "cost_source": "api", "dimension_contribution": {"innovation": 5, "stability": 3}, "requires_research": false, "tags": []},
	],
	"saas_analytics": [
		{"id": "saas_an_dashboards", "complexity": 3, "efor": 7, "pull": 4, "stakes": 3, "dimension_contribution": {"stability": 3, "experience": 5}, "requires_research": false, "tags": []},
		{"id": "saas_an_query", "complexity": 4, "efor": 8, "pull": 4, "stakes": 3, "dimension_contribution": {"stability": 3, "experience": 6}, "requires_research": false, "tags": []},
		{"id": "saas_an_alerts", "complexity": 3, "efor": 7, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 5, "stability": 3}, "requires_research": false, "tags": []},
		{"id": "saas_an_share", "complexity": 2, "efor": 6, "pull": 3, "stakes": 3, "dimension_contribution": {"stability": 2, "experience": 4}, "requires_research": false, "tags": []},
		{"id": "saas_an_etl", "complexity": 5, "efor": 9, "pull": 4, "stakes": 5, "cost": 1000, "cost_source": "api", "dimension_contribution": {"stability": 7}, "requires_research": true, "tags": []},
		{"id": "saas_an_embed", "complexity": 4, "efor": 8, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 6, "stability": 3}, "requires_research": false, "tags": []},
	],
	"saas_billing": [
		{"id": "saas_bill_subscriptions", "complexity": 3, "efor": 7, "pull": 3, "stakes": 4, "dimension_contribution": {"stability": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "saas_bill_invoice", "complexity": 2, "efor": 6, "pull": 3, "stakes": 3, "dimension_contribution": {"stability": 4, "experience": 2}, "requires_research": false, "tags": []},
		{"id": "saas_bill_tax", "complexity": 5, "efor": 9, "pull": 2, "stakes": 5, "cost": 2000, "cost_source": "license", "dimension_contribution": {"stability": 7}, "requires_research": true, "tags": []},
		{"id": "saas_bill_dunning", "complexity": 3, "efor": 7, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 3, "stability": 5}, "requires_research": false, "tags": []},
		{"id": "saas_bill_webhooks", "complexity": 3, "efor": 7, "pull": 3, "stakes": 4, "dimension_contribution": {"stability": 5}, "requires_research": false, "tags": []},
		{"id": "saas_bill_proration", "complexity": 4, "efor": 8, "pull": 2, "stakes": 5, "dimension_contribution": {"stability": 6}, "requires_research": false, "tags": []},
	],
	"saas_dev_tools": [
		{"id": "saas_dev_cli", "complexity": 2, "efor": 6, "pull": 3, "stakes": 2, "dimension_contribution": {"stability": 2, "experience": 4}, "requires_research": false, "tags": []},
		{"id": "saas_dev_api", "complexity": 3, "efor": 7, "pull": 4, "stakes": 5, "dimension_contribution": {"stability": 5, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "saas_dev_docs", "complexity": 3, "efor": 7, "pull": 4, "stakes": 3, "dimension_contribution": {"experience": 5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_ci_plugin", "complexity": 4, "efor": 8, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 3, "stability": 6}, "requires_research": false, "tags": []},
		{"id": "saas_dev_logs", "complexity": 3, "efor": 7, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 3, "stability": 5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_sandbox", "complexity": 3, "efor": 7, "pull": 3, "stakes": 3, "dimension_contribution": {"stability": 5, "experience": 3}, "requires_research": false, "tags": []},
	],
	"saas_ops": [
		{"id": "saas_ops_workflow", "complexity": 4, "efor": 8, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 6, "experience": 3}, "requires_research": false, "tags": []},
		{"id": "saas_ops_reporting", "complexity": 3, "efor": 7, "pull": 3, "stakes": 2, "dimension_contribution": {"stability": 3, "experience": 5}, "requires_research": false, "tags": []},
		{"id": "saas_ops_integration", "complexity": 5, "efor": 9, "pull": 4, "stakes": 5, "cost": 1800, "cost_source": "license", "dimension_contribution": {"stability": 7}, "requires_research": false, "tags": []},
		{"id": "saas_ops_scheduling", "complexity": 3, "efor": 7, "pull": 4, "stakes": 3, "dimension_contribution": {"stability": 3, "experience": 5}, "requires_research": false, "tags": []},
		{"id": "saas_ops_field", "complexity": 5, "efor": 9, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 4, "stability": 7}, "requires_research": true, "tags": []},
		{"id": "saas_ops_mobile", "complexity": 4, "efor": 8, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 3, "experience": 6}, "requires_research": false, "tags": []},
	],
}


# Per-sub-type quality-axis weighting (Product Lifecycle Part 1). Kept as a
# parallel dict keyed by sub-type id (not embedded in SUB_PRODUCT_TYPES) so the
# type records stay readable. Each entry: [{axis, weight, display_label}] over the
# three canonical QualityModel axes. `weight` = how much that pazar cares about the
# axis (feeds composite_quality). Rev3: display_label'lar EVRENSEL üçlüye düzlendi
# (İnovasyon / Kararlılık / Deneyim) — tip-özel eksen takma adları öldü;
# ağırlıklar DEĞİŞMEDİ. Working values — Erdem tunes at the balance pass.
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


static func get_sub_product_types(subgenre: String) -> Array:
	return SUB_PRODUCT_TYPES.get(subgenre, [])


## Merged product pool (onboarding rework 2026-07-16: the Subgenre onboarding
## step is gone — product type is decided in-game, so the picker offers EVERY
## pool). Picking a type write-through-sets GameState.subgenre from its pool
## (see ProductSystem.start_build) so subgenre events/VC seeding keep working.
static func get_all_sub_product_types() -> Array:
	var all: Array = []
	for subgenre_key in SUB_PRODUCT_TYPES:
		all.append_array(SUB_PRODUCT_TYPES[subgenre_key])
	return all


## Pool (subgenre key) a sub-product type belongs to; "" if unknown.
static func get_pool_of(sub_product_type_id: String) -> String:
	for subgenre_key in SUB_PRODUCT_TYPES:
		for sub_type in SUB_PRODUCT_TYPES[subgenre_key]:
			if String(sub_type.get("id", "")) == sub_product_type_id:
				return subgenre_key
	return ""


static func get_feature_pool(sub_product_type_id: String) -> Array:
	return FEATURE_POOLS.get(sub_product_type_id, [])


static func get_feature_by_id(feature_id: String) -> Dictionary:
	for pool_key in FEATURE_POOLS:
		var pool: Array = FEATURE_POOLS[pool_key]
		for feature in pool:
			if feature.get("id", "") == feature_id:
				return feature
	return {}


static func get_sub_product_type_by_id(id: String) -> Dictionary:
	for subgenre_key in SUB_PRODUCT_TYPES:
		var list: Array = SUB_PRODUCT_TYPES[subgenre_key]
		for sub_type in list:
			if sub_type.get("id", "") == id:
				return sub_type
	return {}


# Sales model selector for the PostShip phase. Defaults to "b2c" for unknown ids
# (safe: B2C needs no prospect pipeline). Forward-compat: other sales params
# (price tier, target-market desc) can be read off the same sub-type record.
static func get_market_type(sub_product_type_id: String) -> String:
	var st: Dictionary = get_sub_product_type_by_id(sub_product_type_id)
	return String(st.get("market_type", "b2c"))


# Optional pricing lean per sub-type: "premium" | "neutral" | "volume". Defaults
# to "neutral" when the record omits it. Shifts SalesSystem.product_value()'s optimal.
static func get_price_tendency(sub_product_type_id: String) -> String:
	var st: Dictionary = get_sub_product_type_by_id(sub_product_type_id)
	return String(st.get("price_tendency", "neutral"))


# Per-sub-type quality-axis weights + display labels (Product Lifecycle Part 1).
# Returns [] for unknown ids → QualityModel falls back to equal DEFAULT_AXES.
static func get_quality_axes(sub_product_type_id: String) -> Array:
	return QUALITY_AXES.get(sub_product_type_id, [])


# =========================================================================
#  Rev3 efor / maliyet / risk accessors (engine + UI tek kaynağı)
# =========================================================================

const FEATURE_RISK_LOW_MAX := 2    # complexity <= 2 → "dusuk" (Hata riski: Düşük)
const FEATURE_RISK_HIGH_MIN := 4   # complexity >= 4 → "yuksek"; arası "orta"


static func get_feature_efor(feature_id: String) -> int:
	# Satırda açık `efor` yoksa working kurala düşer (4 + complexity).
	var f: Dictionary = get_feature_by_id(feature_id)
	if f.is_empty():
		return 0
	return int(f.get("efor", 4 + int(f.get("complexity", 0))))


static func sum_efor(feature_ids: Array) -> int:
	var total: int = 0
	for fid in feature_ids:
		total += get_feature_efor(String(fid))
	return total


static func get_feature_cost(feature_id: String) -> Dictionary:
	# {"amount": int, "source": "api"|"license"|""} — cost alanı olmayan satır 0/"".
	var f: Dictionary = get_feature_by_id(feature_id)
	return {"amount": int(f.get("cost", 0)), "source": String(f.get("cost_source", ""))}


static func sum_cost(feature_ids: Array) -> int:
	var total: int = 0
	for fid in feature_ids:
		total += int(get_feature_cost(String(fid)).get("amount", 0))
	return total


static func feature_risk_band(complexity: int) -> String:
	# "dusuk" | "orta" | "yuksek" — UI TR etikete çevirir (Düşük/Orta/Yüksek).
	if complexity <= FEATURE_RISK_LOW_MAX:
		return "dusuk"   # LOC-DATA risk band id
	if complexity >= FEATURE_RISK_HIGH_MIN:
		return "yuksek"   # LOC-DATA risk band id
	return "orta"   # LOC-DATA risk band id


static func selection_risk_band(feature_ids: Array) -> String:
	# Seçimin bandı = round(ortalama complexity) bandı (working kural).
	if feature_ids.is_empty():
		return "dusuk"   # LOC-DATA risk band id
	var total: int = 0
	for fid in feature_ids:
		total += int(get_feature_by_id(String(fid)).get("complexity", 0))
	return feature_risk_band(int(round(float(total) / float(feature_ids.size()))))


# Product-name suggestion pool (Product Lifecycle Part 1 — the "Öner" button).
# Working set; Erdem revises. Deterministic pick keeps runs reproducible.
const PRODUCT_NAME_POOL := [
	"Pulse", "Nova", "Kairo", "Vela", "Loop", "Mira", "Flux", "Orbit", "Ember", "Sable",
	"Nimbus", "Cadence", "Quill", "Atlas", "Beacon", "Ripple", "Vertex", "Halo", "Drift", "Onyx",
]


static func suggest_product_name(index: int) -> String:
	if PRODUCT_NAME_POOL.is_empty():
		return TranslationServer.translate("PRODUCT_FALLBACK_NAME")
	return String(PRODUCT_NAME_POOL[abs(index) % PRODUCT_NAME_POOL.size()])


# ============================================================================
# COPY ACCESSORS — the words left this file for strings.csv (Lokalizasyon Faz 2 · B3a).
# ============================================================================
# The catalog used to hold the display name, category, description, trade-off line, bet,
# pitch, feature name and feature voice as literals. Two problems, one of them a LAW
# violation: the feature NAME was stored in ENGLISH while its description was Turkish, and
# the creation flow renders them side by side — the Turkish feature picker literally read
# "**Workflow Automation** Şu olunca şunu yap…". LANGUAGE INTEGRITY LAW: English never
# appears on screen. So the Turkish names here were AUTHORED, not translated.
#
# Everything is derived from the id the code already carries, so one id yields one row in
# both languages. Derived keys are invisible to a tr("LITERAL") grep, which is why
# `loc_product_derived_keys` walks the real id lists and asserts each key resolves.
# TranslationServer, not tr(): this file is all statics.

static func _derived(prefix: String, id: String, suffix: String = "") -> String:
	if id == "":
		return ""
	var key: String = prefix + id.to_upper() + suffix
	var out: String = TranslationServer.translate(key)
	return out if out != key else id


## Player-facing product name ("Görsel Düzenleyici" / "Photo Editor").
static func type_name(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_NAME")


static func type_category(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_CATEGORY")


static func type_desc(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_DESC")


## The one-line "what you gain, what it costs you" under a product type.
static func type_tradeoff(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_TRADEOFF")


## The founder's wager, in their own voice.
static func type_bet(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_BET")


static func type_pitch(sub_product_type_id: String) -> String:
	return _derived("PROD_TYPE_", sub_product_type_id, "_PITCH")


## The market tags under a product type, localized. Stored as ids (B1a's SECTOR_* rows).
static func type_sector_labels(sub_product_type_id: String) -> Array:
	var out: Array = []
	for sid in get_sub_product_type_by_id(sub_product_type_id).get("sectors", []):
		out.append(_derived("SECTOR_", String(sid)))
	return out


static func feature_name(feature_id: String) -> String:
	return _derived("PROD_FEAT_", feature_id, "_NAME")


## The wry one-liner under a feature name in the picker.
static func feature_voice(feature_id: String) -> String:
	return _derived("PROD_FEAT_", feature_id, "_VOICE")


## Quality-axis display label ("İnovasyon" / "Innovation").
static func axis_label(axis_id: String) -> String:
	return _derived("PROD_AXIS_", axis_id)
