class_name Customer
extends Resource

# Customer data model.
# Plain data container; stored in CustomerRegistry and aggregated into GameState.mrr by
# SalesSystem's MRR bridge. SaveCodec walks every @export, so the property list is the save
# schema and each default is the migration.
#
# Reserved (declared with defaults so future systems plug in without
# retrofitting and so the save schema is forward-compatible):
#   - renewal_day, warning_flags, account_contact, notes
#
# Naming caution (mirrors Character): use company_name (not `name`) for
# cross-data-model consistency.

# --- Identity ---
@export var id: String = ""                   # "co_<slug>" prefix
@export var company_name: String = ""
# COMPOSED names are NOT stored here — see display_name(). company_name holds a proper
# noun ("Nordica Logistics") and proper nouns do not localize.
@export var name_key: String = ""             # "" = company_name is the name; else a CSV key
@export var name_arg: String = ""             # {product} for name_key, when it takes one
@export var industry: String = ""             # SECTOR ID, ASCII ("logistics", "real_estate")
@export var company_size: String = "mid"      # "small" | "mid" | "enterprise" — B2B archetype; "individual" for B2C
@export var market_type: String = "b2c"       # "b2c" | "b2b" — the sales model this customer came from

# --- Commercial (feeds GameState.mrr via Sales aggregation) ---
@export var mrr: int = 0                      # Monthly recurring revenue, dollars
@export var seats: int = 0

# --- Status ---
@export var status: String = "active"         # "active" | "trial" | "churned"
@export var health: String = "healthy"        # "healthy" | "at_risk" | "churning" — derived from satisfaction
@export var satisfaction: int = 70            # 0-100; init from product quality, drifts daily; drives health band

# --- Acquisition (set when a customer is created) ---
@export var acquisition_source: String = ""   # "founder_pitch" | "sales_rep:<id>" | "organic" | "event" | "referral"
@export var acquired_on_day: int = 0          # GameState.day at signing (serves as signed_day)
@export var difficulty_stars: int = 0         # 1-5 carried from the prospect

# --- B2B lifecycle (two-layer satisfaction + watched churn) ---
# `industry` above serves as the sector channel (tolerance seed, complaint voice, contact seam).
@export var lifecycle_phase: String = "onboarding"  # onboarding|active|risk|churning|expansion
@export var scale: int = 1                    # 1..5 stars (customer size); demo binds 1-3
@export var tolerance: int = 50               # HIDDEN — satisfaction floor this account endures before Risk
@export var churn_countdown: int = -1         # -1 inactive; N..0 = the visible "Churn'e ~N gün" counter
@export var risk_streak: int = 0              # consecutive days satisfaction < tolerance
@export var assigned_to: String = ""          # "" = founder-managed; else a Customer Success employee id
@export var onboarding_until: int = 0         # day the onboarding window closes (signed_day + ONBOARDING_DAYS)
@export var pain_feature_id: String = ""      # the ProductCatalog feature this account wants (drives promises)
@export var retain_stalls: int = 0            # how many times "Oyala" has been used (works 1-2x, then caught on)
@export var retain_discounts: int = 0     # how many discounts this account has been given (cap B2BConstants.RETAIN_DISCOUNT_MAX_USES, both channels)
@export var last_risk_exit_day: int = -1  # HYSTERESIS latch: the day the account last left Risk; -1 = never. No re-entry for RISK_REENTRY_DAYS
# HIDDEN expansion latch. The maturity test in B2BSalesSystem.can_offer_expansion is MONOTONE
# (day - acquired_on_day >= EXPANSION_MATURE_DAYS) and BOTH resolutions put the account back to
# "active", so without a record that the moment already happened the account would be promoted
# back to "expansion" every morning. Stored as the DAY rather than a bool so a future re-arm
# rule can read it without a schema migration.
@export var last_expansion_day: int = -1      # -1 = expansion moment not yet offered
@export var cs_escalated: bool = false        # a CS-managed account has raised its one escalation (until it recovers)

# --- Trust ledger + the customer-rep request channel (all HIDDEN, no signals) ---
# trust_offset is what makes a broken promise LAST: it shifts this account's satisfaction
# TARGET, so the one-shot PROMISE_BROKEN_SAT is not erased by SAT_DRIFT_STEP within a
# week. It decays back to 0 daily, so the account forgives on its own.
@export var trust_offset: float = 0.0         # signed target shift from kept/broken promises
@export var support_request_since_day: int = -1    # -1 = no open request; else the day it opened
# The request phase is assigned ONCE at signing from a stride walk (B2BConstants.CS_PHASE_STRIDE),
# which spreads the book by construction. It is NOT derived from id.hash(): customer ids differ
# only in their trailing character and String.hash() is djb2, so consecutive signings would get
# consecutive phases and the whole book would file on consecutive mornings.
@export var cs_request_phase: int = 0         # day-offset within CS_REQUEST_INTERVAL_DAYS
@export var last_request_kind: String = ""    # blocks the same request kind twice in a row
# Player-set stewardship. reconcile_assignments() runs every morning and would otherwise undo
# a manual choice the same night; this flag is what lets player intent outlive the automation.
@export var cs_pinned: bool = false           # true = assigned_to was chosen by the player

# --- SATIŞ rev 6 §5.4 · the price trail -------------------------------------
# THE ACCOUNT CARRIES ITS OWN SEAT PRICE, stamped at the signature; expansion adds seats at
# this price, which is what makes the stance dial (§7.5) a decision with a tail rather than a
# one-day discount. 0 = no stamp (a fixture, or an old account the v10→v11 migration could not
# price from mrr/seats): `B2BSalesSystem.expand` then falls back to the caller's flat rate.
@export var seat_price: int = 0
# §5.4 — the signing discount is INSIDE seat_price and visible as its own trace. A fraction,
# not an amount, so it stays readable when the seat count moves.
@export var signing_discount: float = 0.0

# --- Reserved (declared, no reader or writer yet) ---
@export var renewal_day: int = 0              # When the next renewal event fires
@export var warning_flags: Array[String] = [] # "slow_payer" | "picky" | "kompromat_opportunity"
@export var account_contact: String = ""      # Customer-side contact name
@export var notes: String = ""                # Free text


# Map the satisfaction int onto the `health` band string. CustomerRegistry.set_satisfaction
# re-derives it on every change.
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
## A composed name baked into company_name would freeze one language into the save; storing
## the key and rendering here is the law's "store ids, render labels at display time" applied
## to a name. TranslationServer, not tr(): Resource has no Object to translate through.
func display_name() -> String:
	if name_key == "":
		return company_name
	return TranslationServer.translate(name_key).format({"product": name_arg})
