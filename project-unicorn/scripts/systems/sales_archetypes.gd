class_name SalesArchetypes
extends RefCounted

# CUSTOMER ARCHETYPES — the §11.1 schema, plus the demo stubs that make the machine run.
#
# SCOPE, STATED. The GDD wants 6-8 curated identities for the demo and 12-16 in Early
# Access; curation is the content round's work (§18). This file ships the SCHEMA in full
# and three stubs, so every consumer — the faucet, the probe picker, the negotiation
# profile, the whale hook — is exercised end to end before a single line of real prose
# exists. Adding a curated archetype is a row here and nothing else.
#
# WHY EVERY DIMENSION MUST CHANGE PLAY (§11.1). A dimension that only changes a label is
# content cost with no gameplay return, so each field below names the machine that reads it:
#
#   sector          → which name family the pool draws from, and which sub-types it likes
#                     (SUB-TYPE IDS ARE THE LINE-LADDER ONES — `erp`, `note_tool`,
#                      `video_clip`; Ürün rev 6.1 §20)
#   star_range      → which faucet band this archetype can fill
#   buyer           → which probe families the picker may draw (a technical buyer asks
#                     different questions from an operational one)
#   temperament     → a storylet fact the probe catalogue can key on (SalesProbes.facts_for)
#   negotiation     → reserve sensitivity, patience, insult margin, price-sensitivity flag
#                     (the flag is what §7.6 reads to decide a price-break card is possible)
#   conditions      → the ordered whale condition list (§8); empty = never a whale
#
# NO LOCALISED TEXT LIVES HERE. Ids in, sentences at render time. Player-facing archetype
# voice is a CSV key derived from the id (`SALES_ARCH_<ID>_LINE`).

const DEFAULT_ID := "ops_cautious"

# Temperament ids: a storylet fact (SalesProbes.facts_for); never printed.
const TEMPER_CAUTIOUS := "cautious"
const TEMPER_BRISK := "brisk"
const TEMPER_EXACTING := "exacting"

# Buyer types. Same rule: read, never printed.
const BUYER_OPERATIONS := "operations"
const BUYER_TECHNICAL := "technical"
const BUYER_FINANCE := "finance"

const TABLE := {
	# --- Stub 1 · the cautious operations buyer -----------------------------
	# Haggles slowly. The §10 language sample is written against this shape. Sector order is load-bearing (the faucet draws
	# `% size`, the fixtures read [0]): a new sector goes last.
	"ops_cautious": {
		"sectors": ["logistics", "construction", "manufacturing", "health", "textile"],
		"subtype_affinity": ["erp"],       # the only B2B sub-type that ships today
		"star_range": [1, 3],
		"buyer": BUYER_OPERATIONS,
		"temperament": TEMPER_CAUTIOUS,
		"negotiation": {
			"reserve_sensitivity": 0.92,
			"patience": 3,
			"insult_margin": 0.28,
			"price_sensitive": true,
		},
		"honesty_premium": true,          # "Kabul et" earns this archetype's respect (§5.1)
		"conditions": [SalesConstants.WHALE_COND_PROVIDER, SalesConstants.WHALE_COND_SLA],
	},

	# --- Stub 2 · the technical buyer ---------------------------------------
	# Wants the ladder climbed. Moves fast and is NOT price sensitive, so it never produces a price-break card (§7.6).
	"tech_exacting": {
		"sectors": ["technology", "ecommerce", "finance", "media"],
		"subtype_affinity": [],            # no second B2B sub-type to prefer yet
		"star_range": [1, 3],
		"buyer": BUYER_TECHNICAL,
		"temperament": TEMPER_EXACTING,
		"negotiation": {
			"reserve_sensitivity": 1.12,
			"patience": 2,
			"insult_margin": 0.34,
			"price_sensitive": false,
		},
		"honesty_premium": false,
		"conditions": [SalesConstants.WHALE_COND_LOCKED_TIER, SalesConstants.WHALE_COND_PROVIDER],
	},

	# --- Stub 3 · the finance buyer -----------------------------------------
	# Buys cheaply. Impatient, very price sensitive, and the archetype the price-break card was designed against.
	"finance_brisk": {
		"sectors": ["insurance", "legal", "retail", "real_estate"],
		"subtype_affinity": [],
		"star_range": [1, 2],
		"buyer": BUYER_FINANCE,
		"temperament": TEMPER_BRISK,
		"negotiation": {
			"reserve_sensitivity": 0.84,
			"patience": 2,
			"insult_margin": 0.24,
			"price_sensitive": true,
		},
		"honesty_premium": true,
		"conditions": [],                 # never a whale in the demo set
	},
}


static func ids() -> Array:
	var out: Array = TABLE.keys()
	out.sort()   # deterministic: the faucet indexes into this
	return out


static func has(archetype_id: String) -> bool:
	return TABLE.has(archetype_id)


static func _row(archetype_id: String) -> Dictionary:
	return TABLE.get(archetype_id, TABLE[DEFAULT_ID]) as Dictionary


## Player-facing single line (§4 "arketip sesi tek satır").
static func voice_line(archetype_id: String) -> String:
	return TranslationServer.translate("SALES_ARCH_%s_LINE" % archetype_id.to_upper())


static func sectors(archetype_id: String) -> Array:
	return (_row(archetype_id).get("sectors", []) as Array).duplicate()


static func accepts_star(archetype_id: String, star: int) -> bool:
	var r: Array = _row(archetype_id)["star_range"]
	return star >= int(r[0]) and star <= int(r[1])


static func buyer(archetype_id: String) -> String:
	return String(_row(archetype_id).get("buyer", BUYER_OPERATIONS))


static func temperament(archetype_id: String) -> String:
	return String(_row(archetype_id).get("temperament", TEMPER_CAUTIOUS))


static func negotiation(archetype_id: String) -> Dictionary:
	return (_row(archetype_id).get("negotiation", {}) as Dictionary).duplicate()


static func is_price_sensitive(archetype_id: String) -> bool:
	return bool(negotiation(archetype_id).get("price_sensitive", false))


# DESIGN-PARKED: the honesty premium is a per-archetype BOOL, not a scale. Across three
# stubs a scale is indistinguishable and it would add a calibration surface with nothing to
# calibrate against. Alternative seen: a per-archetype coefficient.
## Some archetypes pay a premium for a straight answer (§5.1 "bazı arketiplerde dürüstlük
## primi"). One bool, read by the "Kabul et" verb.
static func pays_honesty_premium(archetype_id: String) -> bool:
	return bool(_row(archetype_id).get("honesty_premium", false))


## The ORDERED whale condition list (§8). Empty means this archetype is never a whale.
static func conditions(archetype_id: String) -> Array:
	return (_row(archetype_id).get("conditions", []) as Array).duplicate()


const AFFINITY_WEIGHT := 2      # [ÇALIŞMA] a subtype-matched archetype gets this many slots


## Which archetypes can fill a given star band for the active sub-product. Deterministic
## order, so the faucet's pick is reproducible from the seed alone.
##
## AFFINITY BIASES THE DRAW, IT DOES NOT WIN IT: this kind of buyer is MORE likely to want
## this kind of product, not the only kind who ever appears. Expressed as slot multiplicity
## (AFFINITY_WEIGHT) so the mixer stays a plain index pick with no weights table and no
## second draw.
static func candidates_for(star: int, sub_product_id: String) -> Array:
	var preferred: Array = []
	var fallback: Array = []
	for id in ids():
		if not accepts_star(String(id), star):
			continue
		var aff: Array = _row(String(id)).get("subtype_affinity", []) as Array
		if sub_product_id != "" and aff.has(sub_product_id):
			preferred.append(id)
		else:
			fallback.append(id)
	if preferred.is_empty():
		return fallback
	if fallback.is_empty():
		return preferred
	var pool: Array = fallback.duplicate()
	for _i in AFFINITY_WEIGHT:
		pool.append_array(preferred)
	return pool
