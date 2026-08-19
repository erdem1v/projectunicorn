class_name Prospect
extends Resource

# Prospect (sales lead) data model — PostShip spec §B.
# A prospect is a B2B lead that has NOT signed yet. It lives in ProspectRegistry
# and is the input to the pitch dialogue. On a successful pitch it is converted
# into a Customer (CustomerRegistry.add) and removed from the prospect pool, so
# prospects never count toward MRR.
#
# Naming caution (mirrors Customer/Character): use company_name, not `name`.

# --- Identity ---
@export var id: String = ""                   # "lead_<slug>"
@export var company_name: String = ""
@export var industry: String = ""             # e.g. "Logistics", "Real Estate"
@export var archetype: String = "small"       # "small" | "mid" | "enterprise" — sets MRR band + difficulty
@export var scale: int = 1                     # 1..5 stars (customer size); demo binds 1-3, 4-5 gated (Tier 2)

# --- Pitch context (shown on the prospect card / drives the dialogue) ---
@export var need_index: int = -1              # row in the PITCH_NEED_* pool; -1 = none
@export var difficulty_stars: int = 1         # 1-5; raises pitch difficulty
@export var warning_flags: Array[String] = [] # "slow_payer" | "picky" | …
@export var pain_feature_id: String = ""      # the ProductCatalog feature the surface need maps to (B.4)
@export var value_band_min: int = 0           # E.3: prospect value RANGE floor (shown as $min-$max/ay)
@export var value_band_max: int = 0           # E.3: prospect value RANGE ceiling
# Task 2b: how far a Satış Uzmanı has worked this lead. ONE accumulator, TWO outcomes — at
# AUTO_CLOSE_PROGRESS a routine lead signs itself; on anything bigger the same number is the
# bonus the founder inherits at the close stage. Zero sales reps = never advances.
@export var warm_progress: float = 0.0        # 0..n; SalesRepSystem owns it
@export var rep_portrait_id: String = ""      # customer-rep face for the pitch MeetingScene; assigned once, kept across a re-meeting (CALLBACK)

# --- Hidden until the founder's Satış (sales) skill is high enough to "read" them.
#     SkillCheck.can_read_prospect() gates UI reveal; PitchSystem uses these to
#     compute a fair price and de-risk the close. ---
@export var budget_band: String = ""          # "low" | "mid" | "high" — hidden if Satış too low
@export var real_need_index: int = -1         # row in the PITCH_REAL_NEED_* pool; -1 = none

# --- Provenance ---
@export var source: String = "find"           # "frank_intro" | "find" | "referral" | "event"
@export var spawned_on_day: int = 0


# ============================================================================
# DISPLAY — the need lines are rebuilt here, not stored.
# ============================================================================
# These were `need_summary` and `real_need`: plain String @exports holding a finished Turkish
# sentence. Being @exports they went into the save file, so a run started in Turkish carried
# Turkish prose into an English session and no language switch could reach it. The law is
# explicit — localized text is never written into state. Indices in, sentence at render time.

## The visible one-line need. Prefers the pain feature when the prospect has one (that path
## already carried an id), and falls back to the generic pool.
func display_need() -> String:
	if pain_feature_id != "":
		return B2BConstants.pain_phrase(pain_feature_id)
	if need_index < 0:
		return ""
	return TranslationServer.translate("PITCH_NEED_%d" % need_index)


## The hidden deeper need, revealed once the founder's Satış is high enough to read it.
func display_real_need() -> String:
	if real_need_index < 0:
		return ""
	return TranslationServer.translate("PITCH_REAL_NEED_%d" % real_need_index)
