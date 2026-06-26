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

# --- Pitch context (shown on the prospect card / drives the dialogue) ---
@export var need_summary: String = ""         # one-line surface need, always visible
@export var difficulty_stars: int = 1         # 1-5; raises pitch difficulty
@export var warning_flags: Array[String] = [] # "slow_payer" | "picky" | …

# --- Hidden until the founder's Markets skill is high enough to "read" them.
#     SkillCheck.can_read_prospect() gates UI reveal; PitchSystem uses these to
#     compute a fair price and de-risk the close. ---
@export var budget_band: String = ""          # "low" | "mid" | "high" — hidden if Markets too low
@export var real_need: String = ""            # the deeper need behind need_summary — hidden

# --- Provenance ---
@export var source: String = "find"           # "frank_intro" | "find" | "referral" | "event"
@export var spawned_on_day: int = 0
