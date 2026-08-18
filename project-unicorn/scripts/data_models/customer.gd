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
# COMPOSED names are NOT stored here — see display_name(). company_name holds a proper
# noun ("Nordica Logistics") and proper nouns do not localize.
@export var name_key: String = ""             # "" = company_name is the name; else a CSV key
@export var name_arg: String = ""             # {product} for name_key, when it takes one
@export var industry: String = ""             # SECTOR ID, ASCII ("logistics", "real_estate")
@export var company_size: String = "mid"      # "small" | "mid" | "enterprise" — B2B archetype; "individual" for B2C
@export var market_type: String = "b2c"       # "b2c" | "b2b" — PostShip sales model this customer came from

# --- Commercial (used now — feeds GameState.mrr via Sales aggregation) ---
@export var mrr: int = 0                      # Monthly recurring revenue, dollars
@export var seats: int = 0                    # Per PROJECT_SPEC §5.4 customer-row format

# --- Status (used now) ---
@export var status: String = "active"         # "active" | "trial" | "churned"
@export var health: String = "healthy"        # "healthy" | "at_risk" | "churning" — derived from satisfaction
@export var satisfaction: int = 70            # 0-100; init from product quality, drifts daily; drives health band

# --- Acquisition (used now — set when a customer is created via pitch/event/organic) ---
@export var acquisition_source: String = ""   # "founder_pitch" | "sales_rep:<id>" | "organic" | "event" | "referral"
@export var acquired_on_day: int = 0          # GameState.day at signing (serves as signed_day)
@export var difficulty_stars: int = 0         # 1-5 carried from the prospect

# --- B2B lifecycle (B2B Sales System — two-layer satisfaction + watched churn) ---
# `industry` above serves as the sector channel (portfolio sector tag reads from it).
@export var lifecycle_phase: String = "onboarding"  # onboarding|active|risk|churning|expansion
@export var scale: int = 1                    # 1..5 stars (customer size); demo binds 1-3
@export var tolerance: int = 50               # HIDDEN — satisfaction floor this account endures before Risk
@export var churn_countdown: int = -1         # -1 inactive; N..0 = the visible "Churn'e ~N gün" counter
@export var risk_streak: int = 0              # consecutive days satisfaction < tolerance
@export var assigned_to: String = ""          # "" = founder-managed; else a Customer Success employee id
# `support_load` DELETED (Task 2b): written twice, read never, and with no registry seam it
# was a standing WRITE-THROUGH LAW exception. It only ever mirrored `scale`, which is still here.
@export var onboarding_until: int = 0         # day the onboarding window closes (signed_day + ONBOARDING_DAYS)
@export var pain_feature_id: String = ""      # the ProductCatalog feature this account wants (drives promises)
@export var retain_stalls: int = 0            # how many times "Oyala" has been used (works 1-2x, then caught on)
# HIDDEN expansion latch (K2). -1 = this account has never had its expansion moment.
# The promotion test in _tick_healthy is MONOTONE (day - acquired_on_day >= MATURE_DAYS)
# and BOTH resolutions put the account back to "active", so without a record that the
# moment already happened the same modal re-fired every single morning, forever, and
# "Büyüt" became an unbounded free MRR faucet. Stored as the DAY rather than a bool so a
# future re-arm rule can read it without a schema migration.
@export var last_expansion_day: int = -1      # -1 = expansion moment not yet offered
@export var cs_escalated: bool = false        # a CS-managed account has raised its one escalation (until it recovers)
# --- Task 2b: trust ledger + the customer-rep request channel (all HIDDEN, no signals) ---
# trust_offset is what makes a broken promise LAST: it shifts this account's satisfaction
# TARGET, so the one-shot PROMISE_BROKEN_SAT is no longer erased by SAT_DRIFT_STEP within a
# week. It decays back to 0 daily, so the account forgives on its own.
@export var trust_offset: float = 0.0         # signed target shift from kept/broken promises
@export var support_request_since_day: int = -1    # -1 = no open request; else the day it opened
# `support_request_progress` DELETED (2b fixes): written 1.0/0.0, read by nothing. The real
# latch is support_request_since_day, which doubles as the escalation clock.
#
# The request cadence used to derive its phase from `absi(id.hash()) % INTERVAL`. That is
# structurally broken here: customer ids are "co_lead_<day>_<counter>", identical but for the
# trailing character, and Godot's String.hash() is djb2 — a last-character delta shifts the
# hash by exactly that delta, so consecutive ids get CONSECUTIVE phases. Measured:
# co_lead_3_0/1/2/3 -> phases 9, 10, 11, 0, i.e. the whole book files on four consecutive
# mornings and then goes silent for eight days. Widening the interval alone would not have
# fixed it. The phase is now assigned explicitly at signing from a stride walk (see
# B2BConstants.CS_PHASE_STRIDE), which spreads by construction rather than by luck.
@export var cs_request_phase: int = 0         # day-offset within CS_REQUEST_INTERVAL_DAYS
@export var last_request_kind: String = ""    # blocks the same request kind twice in a row
# Player-set stewardship. reconcile_assignments() runs every morning and would otherwise undo
# a manual choice the same night; this flag is what lets player intent outlive the automation.
# Cleared automatically if the pinned rep leaves or goes inactive, so no dead pins accumulate.
@export var cs_pinned: bool = false           # true = assigned_to was chosen by the player

# --- Reserved for future systems (declared, not used this turn) ---
@export var renewal_day: int = 0              # When the next renewal event fires (churn/renewal — next spec)
@export var warning_flags: Array[String] = [] # "slow_payer" | "picky" | "kompromat_opportunity"
@export var account_contact: String = ""      # Customer-side contact name
@export var notes: String = ""                # Free text


# Map the satisfaction int onto the legacy `health` band string. Customer-event
# conditions read `health` (the health-dot UI it was also built for retired with
# RightPanel, so the event layer is its one live reader); SalesSystem calls this
# after each daily satisfaction tick. Bands per PostShip spec tunables.
func update_health_from_satisfaction() -> void:
	if satisfaction >= 60:
		health = "healthy"
	elif satisfaction >= 30:
		health = "at_risk"
	else:
		health = "churning"


## The name to SHOW. Two kinds of customer, two rules:
##  · a real company carries a PROPER NOUN in company_name, and proper nouns do not localize
##  · the B2C user base is not a company — its name is composed copy ("<product> kullanıcıları")
##
## The composed one used to be BAKED INTO company_name at creation, which froze one language
## into a persisted field: a save taken in Turkish showed Turkish user-base copy forever, in
## either locale, and no language switch could heal it. Storing the key and rendering here is
## the law's "store ids, render labels at display time" applied to a name.
## TranslationServer, not tr(): Resource has no Object to translate through.
func display_name() -> String:
	if name_key == "":
		return company_name
	return TranslationServer.translate(name_key).format({"product": name_arg})
