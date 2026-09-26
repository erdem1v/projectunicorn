class_name FounderConstants
extends RefCounted

# Founder identity constants: skills, allocation rules, traits, origins, portraits, logo
# styles. Every number here is a working placeholder for the calibration pass.
#
# The founder carries the same six areas as every employee (§3: "kurucunun her alanda puanı
# var"), plus Liderlik (§4.2, everyone) and Karizma (founder-only; ch. 02 §4).

# Six areas (HRConstants.AREAS, same ids, SAME RULER) + Liderlik + Karizma.
const SKILLS := ["product", "design", "engineering", "qa", "sales", "customer_success",
	"leadership", "charisma"]
const SKILL_CHARISMA := "charisma"
# Retired keys: GameState.get_founder_skill push_errors on these so a stale read screams
# instead of silently returning 0.
const OLD_SKILLS := ["markets", "politics", "tech", "negotiation", "influence"]

# --- Onboarding allocation ---
const POINT_POOL := 6        # onboarding skill points; ALL must be spent (İleri gated).
const ONBOARDING_CAP := 3    # per-skill max at creation (dağıtım biriminde, cetvelde değil)

## TEK CETVEL (§2.4 + §4.1 + §5.3): kurucu da çalışan da 0–10'da, iki puan bir yıldız.
## Dağıtım birimi ayrı kalır: oyuncu POINT_POOL puanı ONBOARDING_CAP tavanıyla dağıtır,
## cetvele çevirme yazma anında olur (GameState._build_founder), yani doğan kurucu en fazla
## 6/10 taşır.
const SKILL_CEILING := HRConstants.AREA_MAX

## Dağıtım biriminden cetvele geçişin tek evi; bir yerde daha çarpılırsa kurucu sessizce
## kareye çıkar.
const RULER_SCALE := 2


static func to_ruler(alloc_points: int) -> int:
	return clampi(alloc_points * RULER_SCALE, 0, SKILL_CEILING)

# --- Trait rules (Software-Inc formula) ---
# >=1 positive required; 1 positive -> negative optional; 2 positives -> exactly 1 negative.
const TRAIT_MAX_POSITIVE := 2
const TRAIT_MAX_NEGATIVE := 1

# Trait catalog. Display strings live in localization/strings.csv (name_key/effect_key).
# RESERVED: trait EFFECTS are consumed by no system yet — wiring real modifiers is a
# separate backend task. Character.traits stores the chosen ids until then.
const TRAITS := [
	{"id": "visionary", "polarity": "positive", "name_key": "TRAIT_VISIONARY_NAME", "effect_key": "TRAIT_VISIONARY_EFFECT"},
	{"id": "disciplined", "polarity": "positive", "name_key": "TRAIT_DISCIPLINED_NAME", "effect_key": "TRAIT_DISCIPLINED_EFFECT"},
	{"id": "networker", "polarity": "positive", "name_key": "TRAIT_NETWORKER_NAME", "effect_key": "TRAIT_NETWORKER_EFFECT"},
	{"id": "resilient", "polarity": "positive", "name_key": "TRAIT_RESILIENT_NAME", "effect_key": "TRAIT_RESILIENT_EFFECT"},
	{"id": "stubborn", "polarity": "negative", "name_key": "TRAIT_STUBBORN_NAME", "effect_key": "TRAIT_STUBBORN_EFFECT"},
	{"id": "micromanager", "polarity": "negative", "name_key": "TRAIT_MICROMANAGER_NAME", "effect_key": "TRAIT_MICROMANAGER_EFFECT"},
	{"id": "risk_blind", "polarity": "negative", "name_key": "TRAIT_RISK_BLIND_NAME", "effect_key": "TRAIT_RISK_BLIND_EFFECT"},
	{"id": "lone_wolf", "polarity": "negative", "name_key": "TRAIT_LONE_WOLF_NAME", "effect_key": "TRAIT_LONE_WOLF_EFFECT"},
]

# Self-Made opening cash; the origin catalog and GameState's defaults both read it.
const STARTING_CASH := 10000

# Origin catalog. starting_cash is a working placeholder. reserved_flags are SET by
# initialize_run but consumed nowhere yet — future press/network systems read them.
const ORIGINS := [
	{"id": "self_made", "locked": false,
		"name_key": "ONB_ORIGIN_SELF_MADE_NAME", "quote_key": "ONB_ORIGIN_SELF_MADE_QUOTE",
		"chips": [
			{"key": "ONB_ORIGIN_SM_CHIP_RESILIENT", "kind": "plus"},
			{"key": "ONB_ORIGIN_SM_CHIP_LOW_CAPITAL", "kind": "minus"},
			{"key": "ONB_ORIGIN_SM_CHIP_PRESS", "kind": "plus"},
		],
		"starting_cash": STARTING_CASH,
		"reserved_flags": ["origin_press_sympathy", "origin_low_capital"]},
	{"id": "heir", "locked": true,
		"name_key": "ONB_ORIGIN_HEIR_NAME", "quote_key": "ONB_ORIGIN_HEIR_QUOTE",
		"locked_note_key": "LOCK_FULL"},
	{"id": "corporate_refugee", "locked": true,
		"name_key": "ONB_ORIGIN_CORP_NAME", "quote_key": "ONB_ORIGIN_CORP_QUOTE",
		"locked_note_key": "LOCK_SOON"},
]

# --- Portraits (onboarding Page 1) — data-driven grid; one id per asset in PORTRAIT_DIR.
const PORTRAIT_DIR := "res://assets/art/founders/"
const PORTRAIT_IDS := [
	"founder_01", "founder_02", "founder_03", "founder_04", "founder_05", "founder_06",
	"founder_07", "founder_08", "founder_09", "founder_10", "founder_11",
]

# --- Logo styles (onboarding Page 3). emblem drives LogoEmblem._draw — no image assets.
const LOGO_STYLES := [
	{"id": "minimalist", "name_key": "LOGO_STYLE_MINIMALIST", "emblem": "circle_outline"},
	{"id": "tech", "name_key": "LOGO_STYLE_TECH", "emblem": "hexagon"},
	{"id": "playful", "name_key": "LOGO_STYLE_PLAYFUL", "emblem": "rounded_fill"},
	{"id": "serious", "name_key": "LOGO_STYLE_SERIOUS", "emblem": "square_fill"},
]

# --- Skill display keys (localization/strings.csv) ---
# Lowercase inline odds fragments ("temel %35 · +%15 satış"), a different register from the
# Title Case area label (HRConstants.area_label), hence a separate table.
const SKILL_LABEL_KEYS := {
	"product": "SKILL_LABEL_PRODUCT", "design": "SKILL_LABEL_DESIGN",
	"engineering": "SKILL_LABEL_ENGINEERING", "qa": "SKILL_LABEL_QA",
	"sales": "SKILL_LABEL_SALES", "customer_success": "SKILL_LABEL_CUSTOMER_SUCCESS",
	"leadership": "SKILL_LABEL_LEADERSHIP", "charisma": "SKILL_LABEL_CHARISMA",
}
# Onboarding column headers. CSV values carry FINAL display casing — never raw .to_upper()
# a Turkish string in code (dotted-İ bug: "liderlik".to_upper() == "LIDERLIK"; use UiTokens.tr_upper).
const SKILL_NAME_KEYS := {
	"product": "ONB_SKILL_PRODUCT", "design": "ONB_SKILL_DESIGN",
	"engineering": "ONB_SKILL_ENGINEERING", "qa": "ONB_SKILL_QA",
	"sales": "ONB_SKILL_SALES", "customer_success": "ONB_SKILL_CUSTOMER_SUCCESS",
	"leadership": "ONB_SKILL_LEADERSHIP", "charisma": "ONB_SKILL_CHARISMA",
}
# One-line skill descriptions under each onboarding column header.
const SKILL_DESC_KEYS := {
	"product": "ONB_SKILL_PRODUCT_DESC", "design": "ONB_SKILL_DESIGN_DESC",
	"engineering": "ONB_SKILL_ENGINEERING_DESC", "qa": "ONB_SKILL_QA_DESC",
	"sales": "ONB_SKILL_SALES_DESC", "customer_success": "ONB_SKILL_CUSTOMER_SUCCESS_DESC",
	"leadership": "ONB_SKILL_LEADERSHIP_DESC", "charisma": "ONB_SKILL_CHARISMA_DESC",
}


## Founder-skill display label (lowercase odds fragment). TranslationServer directly so
## static odds-text contexts work without a scene tree. Falls back to the raw key.
static func skill_label(skill_name: String) -> String:
	if not SKILL_LABEL_KEYS.has(skill_name):
		return skill_name
	return TranslationServer.translate(SKILL_LABEL_KEYS[skill_name])


## Points left to spend for the KALAN PUAN counter. Only canonical keys count.
static func alloc_remaining(alloc: Dictionary) -> int:
	var spent: int = 0
	for skill_key in SKILLS:
		spent += int(alloc.get(skill_key, 0))
	return POINT_POOL - spent


## Onboarding allocation guard: only canonical keys, each 0..ONBOARDING_CAP, and the
## whole pool spent. Missing keys count as 0.
static func validate_alloc(alloc: Dictionary) -> bool:
	for k in alloc.keys():
		if not SKILLS.has(k):
			return false
	for skill_key in SKILLS:
		var v: int = int(alloc.get(skill_key, 0))
		if v < 0 or v > ONBOARDING_CAP:
			return false
	return alloc_remaining(alloc) == 0


## Trait formula guard: known unique ids; 1..TRAIT_MAX_POSITIVE positives; at most
## TRAIT_MAX_NEGATIVE negatives; max positives force exactly one negative.
static func validate_traits(trait_ids: Array) -> bool:
	var pos: int = 0
	var neg: int = 0
	var seen: Array = []
	for raw_id in trait_ids:
		var trait_id: String = String(raw_id)
		if seen.has(trait_id):
			return false
		seen.append(trait_id)
		var t: Dictionary = trait_by_id(trait_id)
		if t.is_empty():
			return false
		if t["polarity"] == "positive":
			pos += 1
		else:
			neg += 1
	if pos < 1 or pos > TRAIT_MAX_POSITIVE or neg > TRAIT_MAX_NEGATIVE:
		return false
	return pos < TRAIT_MAX_POSITIVE or neg == 1


static func trait_by_id(trait_id: String) -> Dictionary:
	for t in TRAITS:
		if t["id"] == trait_id:
			return t
	return {}


static func origin_by_id(origin_id: String) -> Dictionary:
	for o in ORIGINS:
		if o["id"] == origin_id:
			return o
	return {}


static func portrait_path(portrait_id: String) -> String:
	return PORTRAIT_DIR + portrait_id + ".webp"
