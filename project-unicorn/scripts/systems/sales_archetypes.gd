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
#                      `video_clip`. The `ai_*` / `saas_*` ids are the retired feature-pool
#                      generation and match nothing; Ürün rev 6.1 §20 retired them.)
#   star_range      → which faucet band this archetype can fill
#   buyer           → which probe families the picker may draw (a technical buyer asks
#                     different questions from an operational one)
#   temperament     → Act 2 patience and counter-offer step
#   priorities      → the axis weights the persuasion reading multiplies, plus how many
#                     BASE and how many DELIGHT steps this buyer counts (the Kano reading
#                     — the LABEL never reaches the screen, §11.1)
#   negotiation     → reserve sensitivity, patience, insult margin, price-sensitivity flag
#                     (the flag is what §7.6 reads to decide a price-break card is possible)
#   conditions      → the ordered whale condition list (§8); empty = never a whale
#
# NO LOCALISED TEXT LIVES HERE. Ids in, sentences at render time — the same law that moved
# the B2C user-base name out of `Customer.company_name`. Player-facing archetype voice is a
# CSV key derived from the id (`SALES_ARCH_<ID>_LINE`), and it is a tagged placeholder until
# the writing round lands.

const DEFAULT_ID := "ops_cautious"

# Temperament ids. They are read by the negotiation profile and by the probe picker; they
# are never printed.
const TEMPER_CAUTIOUS := "cautious"
const TEMPER_BRISK := "brisk"
const TEMPER_EXACTING := "exacting"

# Buyer types. Same rule: read, never printed.
const BUYER_OPERATIONS := "operations"
const BUYER_TECHNICAL := "technical"
const BUYER_FINANCE := "finance"

const TABLE := {
	# --- Stub 1 · the cautious operations buyer -----------------------------
	# Reads stability above everything, counts base steps and ignores delighters, and
	# haggles slowly. The §10 language sample is written against this shape.
	"ops_cautious": {
		"sectors": ["logistics", "construction", "manufacturing"],
		"subtype_affinity": ["erp"],       # the only B2B sub-type that ships today
		"star_range": [1, 3],
		"buyer": BUYER_OPERATIONS,
		"temperament": TEMPER_CAUTIOUS,
		"priorities": {
			"axis_weights": {"stability": 0.55, "experience": 0.30, "innovation": 0.15},
			"base_steps_counted": 3,
			"delight_steps_counted": 0,
		},
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
	# Wants the ladder climbed: innovation first, and it counts delighters. Moves fast and
	# is NOT price sensitive, so it never produces a price-break card (§7.6).
	"tech_exacting": {
		"sectors": ["technology", "ecommerce", "finance"],
		"subtype_affinity": [],            # no second B2B sub-type to prefer yet
		"star_range": [1, 3],
		"buyer": BUYER_TECHNICAL,
		"temperament": TEMPER_EXACTING,
		"priorities": {
			"axis_weights": {"innovation": 0.50, "stability": 0.30, "experience": 0.20},
			"base_steps_counted": 2,
			"delight_steps_counted": 2,
		},
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
	# Buys the experience of not being surprised, and buys it cheaply. Impatient, very price
	# sensitive, and the archetype the price-break card was designed against.
	"finance_brisk": {
		"sectors": ["insurance", "legal", "retail", "real_estate"],
		"subtype_affinity": [],
		"star_range": [1, 2],
		"buyer": BUYER_FINANCE,
		"temperament": TEMPER_BRISK,
		"priorities": {
			"axis_weights": {"experience": 0.45, "stability": 0.40, "innovation": 0.15},
			"base_steps_counted": 2,
			"delight_steps_counted": 1,
		},
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


## Player-facing single line (§4 "arketip sesi tek satır"). A tagged PLACEHOLDER until the
## writing round replaces it wholesale; the tag is what makes them mechanically findable.
static func voice_line(archetype_id: String) -> String:
	return TranslationServer.translate("SALES_ARCH_%s_LINE" % archetype_id.to_upper())


static func sectors(archetype_id: String) -> Array:
	return (_row(archetype_id).get("sectors", []) as Array).duplicate()


static func star_range(archetype_id: String) -> Array:
	return (_row(archetype_id).get("star_range", [1, 3]) as Array).duplicate()


static func accepts_star(archetype_id: String, star: int) -> bool:
	var r: Array = star_range(archetype_id)
	return star >= int(r[0]) and star <= int(r[1])


static func buyer(archetype_id: String) -> String:
	return String(_row(archetype_id).get("buyer", BUYER_OPERATIONS))


static func temperament(archetype_id: String) -> String:
	return String(_row(archetype_id).get("temperament", TEMPER_CAUTIOUS))


## Axis weights, normalised. Read by the persuasion reading's product-fit term — this is the
## whole reason "the same product reads differently to two customers".
static func axis_weights(archetype_id: String) -> Dictionary:
	var p: Dictionary = _row(archetype_id).get("priorities", {}) as Dictionary
	var w: Dictionary = (p.get("axis_weights", {}) as Dictionary).duplicate()
	var total: float = 0.0
	for k in w.keys():
		total += float(w[k])
	if total <= 0.0:
		return {"innovation": 0.34, "stability": 0.33, "experience": 0.33}
	for k in w.keys():
		w[k] = float(w[k]) / total
	return w


## How many BASE and how many DELIGHT ladder steps this buyer counts (§11.1). The Kano
## reading of the product; the label never reaches the screen.
static func step_appetite(archetype_id: String) -> Dictionary:
	var p: Dictionary = _row(archetype_id).get("priorities", {}) as Dictionary
	return {
		"base": int(p.get("base_steps_counted", 2)),
		"delight": int(p.get("delight_steps_counted", 0)),
	}


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


## Which archetypes can fill a given star band for the active sub-product. Deterministic
## order, so the faucet's pick is reproducible from the seed alone.
## AFFINITY BIASES THE DRAW, IT DOES NOT WIN IT (F13, ölçüldü 2026-08-27).
##
## This used to return `preferred` outright whenever it was non-empty, which reads fine until
## you count the rows: `erp` is the only B2B sub-type that ships, exactly one archetype names
## it, so `preferred` was always a list of ONE and the other two archetypes could never be
## drawn at any star. Every company in the pipeline spoke the same voice line, and it looked
## like stub scarcity because there are only three stubs — it was not. Three archetypes existed
## and the draw could reach one.
##
## An affinity is a leaning: this kind of buyer is MORE likely to want this kind of product,
## not the only kind who ever appears. Expressed as slot multiplicity so the mixer stays a
## plain index pick and nothing here needs a weights table or a second random draw.
const AFFINITY_WEIGHT := 2      # [ÇALIŞMA] a subtype-matched archetype gets this many slots


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
