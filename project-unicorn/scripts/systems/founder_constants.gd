class_name FounderConstants
extends RefCounted

# THE single constants block for founder identity: skills, allocation rules, traits,
# origins, portraits, logo styles. EVERY number here is a working placeholder — the
# calibration pass (last, one session) tunes this file and nothing else.
#
# SKILL-RENAME ledger (2026-07-16) — the 4-skill system became 5 skills:
#   tech     -> tech (unchanged)
#   markets  -> SPLIT by meaning: "sales" (prospect/pitch/deal-close reads)
#                                 "negotiation" (term-sheet/discount pushes)
#   charisma -> leadership (identity); every old READ reassigned by meaning:
#                B2B "Vizyon sat" -> influence; B2B close roll -> sales;
#                VC pitch persuasion beats -> influence (Erdem decision 2026-07-16)
#   politics -> influence
# Old keys must never be read again — GameState.get_founder_skill push_errors on
# OLD_SKILLS so a stale read screams in every log instead of silently returning 0.

const SKILLS := ["tech", "sales", "negotiation", "leadership", "influence"]
const OLD_SKILLS := ["markets", "charisma", "politics"]

# --- Onboarding allocation ---
const POINT_POOL := 6        # onboarding skill points; ALL must be spent (İleri gated).
                             # Erdem 2026-07-16: 8 over-equipped the early game — 6 forces
                             # a sharper identity (two strong suits, real gaps).
const ONBOARDING_CAP := 3    # per-skill max at creation
const SKILL_CEILING := 5     # underlying max — 4-5 reachable only via HR founder
                             # training (LATER task, not built). At 5 the SkillCheck
                             # formula clamps at MAX_CHANCE 0.95; safe headroom.

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

# Self-Made opening cash — single home; the origin catalog below and GameState's
# defaults + initialize_run fallback all read it.
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
		"locked_note_key": "ONB_LOCKED_FULL"},
	{"id": "corporate_refugee", "locked": true,
		"name_key": "ONB_ORIGIN_CORP_NAME", "quote_key": "ONB_ORIGIN_CORP_QUOTE",
		"locked_note_key": "ONB_LOCKED_SOON"},
]

# --- Portraits (onboarding Page 1) — data-driven grid. The mockup shows 12; 11 assets
# exist today. When founder_12.webp lands in assets/art/founders/, append its id here.
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

# --- Skill display keys (localization/strings.csv; TR canonical + EN literary) ---
# Lowercase odds fragments ("temel %X · +%Y satış") — the single label home,
# delegated to by PitchConstants.skill_label so existing callers stay diff-free.
const SKILL_LABEL_KEYS := {
	"tech": "SKILL_LABEL_TECH", "sales": "SKILL_LABEL_SALES",
	"negotiation": "SKILL_LABEL_NEGOTIATION", "leadership": "SKILL_LABEL_LEADERSHIP",
	"influence": "SKILL_LABEL_INFLUENCE",
}
# Onboarding column headers. CSV values carry FINAL display casing — never raw .to_upper()
# a Turkish string in code (dotted-İ bug: "liderlik".to_upper() == "LIDERLIK"; use UiTokens.tr_upper).
const SKILL_NAME_KEYS := {
	"tech": "ONB_SKILL_TECH", "sales": "ONB_SKILL_SALES",
	"negotiation": "ONB_SKILL_NEGOTIATION", "leadership": "ONB_SKILL_LEADERSHIP",
	"influence": "ONB_SKILL_INFLUENCE",
}
# One-line skill descriptions under each onboarding column header.
const SKILL_DESC_KEYS := {
	"tech": "ONB_SKILL_TECH_DESC", "sales": "ONB_SKILL_SALES_DESC",
	"negotiation": "ONB_SKILL_NEGOTIATION_DESC", "leadership": "ONB_SKILL_LEADERSHIP_DESC",
	"influence": "ONB_SKILL_INFLUENCE_DESC",
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
	if pos < 1 or pos > TRAIT_MAX_POSITIVE:
		return false
	if neg > TRAIT_MAX_NEGATIVE:
		return false
	if pos == TRAIT_MAX_POSITIVE and neg != 1:
		return false
	return true


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
