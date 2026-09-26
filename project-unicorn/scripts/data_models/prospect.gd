class_name Prospect
extends Resource

# Prospect (sales lead) data model — GDD SATIŞ rev 6 §4, §13.
#
# A prospect is a B2B lead that has not signed. It lives in ProspectRegistry and is the input
# to the meeting. On a signature it becomes a Customer (SalesSystem.add_b2b_customer) and is
# removed here, so prospects never count toward MRR.
#
# THE SAVE SCHEMA IS THIS FILE. SaveCodec walks every `@export` and the DEFAULT is the
# migration: a field added here loads as its default out of an older save with no ladder
# entry. That is why the rev 6 fields below carry deliberate, playable defaults rather than
# sentinels — a v10 lead restored into v11 must be a legal lead, not a broken one.
#
# Naming caution (mirrors Customer/Character): use company_name, not `name`.

# --- Identity ---
@export var id: String = ""                   # "lead_<day>_<counter>"
@export var company_name: String = ""
@export var industry: String = ""             # SECTOR ID, ASCII ("logistics", "real_estate")

## §2 — the customer star, 1..3 in the demo. THE size encoding: seat band, money, difficulty
## and prestige all read it, and the row always draws five stars (Ekip §4.1 grammar).
@export var star: int = 1

## §11.1 — which customer archetype speaks at this table. Selects the probe families, the
## axis weights the persuasion reading multiplies, and the negotiation profile.
@export var archetype_id: String = "ops_cautious"

# --- Life and routing (§4) ---
@export var spawned_on_day: int = 0
## §4 — "çalışılmayan lead 1 hafta bekler; görünür sayaç". Absolute, not a countdown: a
## stored countdown drifts every time the day advances outside a tick.
@export var expires_on_day: int = 0
## §7.2.1 — "" | "reserved" (the desk is the founder's) | "rep" (first in the band queue).
@export var routing: String = ""

# --- Rep processing (§7.2, §13 "temsilci işleme") ---
@export var worked_by: String = ""            # character id, "" = nobody is on it
@export var work_started_day: int = -1
## §7.5 — "İşlenmekte olan deal başladığı kadrandan kapanır." The stance is stamped when
## processing STARTS, so moving the dial mid-deal cannot retroactively reprice it.
@export var work_stance: String = ""
@export var work_due_day: int = -1            # the day processing completes

# --- Whale hook (§8) ---
## The ORDERED-first-unmet condition, resolved when the lead is created and telegraphed on
## the card. "" = an ordinary lead, or a whale whose whole list was already satisfied.
@export var whale_condition: String = ""
@export var is_whale: bool = false

# --- Re-pitch memory (§9) ---
## The reason named the last time this company walked out of a meeting. Drives the blocker
## gate ("isimlenen neden değişmeden aynı yol aynı sonucu verir") and the memory line.
@export var last_loss_reason: String = ""
@export var loss_count: int = 0

## The ProductCatalog feature this company wants. A pitch promise names it (§6), and it
## carries into `Customer.pain_feature_id`, which drives the retention promise and the CS
## request channel (§19 "Korunanlar").
@export var pain_feature_id: String = ""

# --- Provenance ---
@export var source: String = "faucet"         # "faucet" | "event" | "referral" | "frank_intro"


## Days left before the lead gives up (§4 "görünür sayaç"). Clamped at zero so a lead the
## sweep has not reached yet never renders a negative count.
func days_left() -> int:
	return maxi(expires_on_day - GameState.day, 0)


## §7.2 — a lead being worked has its counter FROZEN (§12 "İşlenen lead | sayacı donar").
## The sweep skips it rather than pushing the expiry day forward, so nothing accumulates.
func is_being_worked() -> bool:
	return worked_by != ""


## §4 — "Ligin üstü lead girilebilirdir." The founder may sit at any table; the card carries
## the telegraph and only the REP automation is gated (§7.1).
func is_above_league(founder_star: int) -> bool:
	return star > founder_star
