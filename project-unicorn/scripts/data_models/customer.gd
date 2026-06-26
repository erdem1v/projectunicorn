class_name Customer
extends Resource

# Customer data model per TECH_SPEC §7.
# Plain data container; stored in CustomerRegistry and aggregated by
# SalesSystem each daily tick into GameState.mrr.
#
# Used now (this turn):
#   - Identity: id, company_name, industry, company_size
#   - Commercial: mrr, seats (MRR feeds GameState via Sales aggregation)
#   - Status: status (only "active" customers contribute to MRR)
#
# Reserved (declared with defaults so future systems plug in without
# retrofitting and so the save schema is forward-compatible):
#   - health, acquisition_source, acquired_on_day, renewal_day,
#     difficulty_stars, warning_flags, account_contact, notes
#
# Naming caution (mirrors Character): use company_name (not `name`) for
# cross-data-model consistency.

# --- Identity (used now) ---
@export var id: String = ""                   # "co_<slug>" per TECH_SPEC §12 prefix
@export var company_name: String = ""         # Avoid `name` for consistency with Character
@export var industry: String = ""             # e.g. "Logistics", "Real Estate", "Textile"
@export var company_size: String = "mid"      # "small" | "mid" | "enterprise" — B2B archetype; "individual" for B2C
@export var market_type: String = "b2c"       # "b2c" | "b2b" — PostShip sales model this customer came from

# --- Commercial (used now — feeds GameState.mrr via Sales aggregation) ---
@export var mrr: int = 0                      # Monthly recurring revenue, dollars
@export var seats: int = 0                    # Per PROJECT_SPEC §5.4 RightPanel format

# --- Status (used now) ---
@export var status: String = "active"         # "active" | "trial" | "churned"
@export var health: String = "healthy"        # "healthy" | "at_risk" | "churning" — derived from satisfaction
@export var satisfaction: int = 70            # 0-100; init from product quality, drifts daily; drives health band

# --- Acquisition (used now — set when a customer is created via pitch/event/organic) ---
@export var acquisition_source: String = ""   # "founder_pitch" | "organic" | "event" | "referral"
@export var acquired_on_day: int = 0          # GameState.day at signing
@export var difficulty_stars: int = 0         # 1-5 carried from the prospect

# --- Reserved for future systems (declared, not used this turn) ---
@export var renewal_day: int = 0              # When the next renewal event fires (churn/renewal — next spec)
@export var warning_flags: Array[String] = [] # "slow_payer" | "picky" | "kompromat_opportunity"
@export var account_contact: String = ""      # Customer-side contact name
@export var notes: String = ""                # Free text


# Map the satisfaction int onto the legacy `health` band string. RightPanel
# health dots + customer-event conditions read `health`; SalesSystem calls this
# after each daily satisfaction tick. Bands per PostShip spec tunables.
func update_health_from_satisfaction() -> void:
	if satisfaction >= 60:
		health = "healthy"
	elif satisfaction >= 30:
		health = "at_risk"
	else:
		health = "churning"
