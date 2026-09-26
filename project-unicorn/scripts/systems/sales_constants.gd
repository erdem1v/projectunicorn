class_name SalesConstants
extends RefCounted

# THE single tunables block for the rebuilt Sales module (GDD SATIŞ rev 6).
#
# WHY A SECOND CONSTANTS FILE. `B2BConstants` keeps the PRESERVED account-lifecycle set
# (§19 "Korunanlar": tolerance, risk series, churn countdown, retention, CS escalation,
# brand costs). Everything the rebuild introduces lives here. The split is the retirement
# list's own line: one file for the machine that was kept, one for the machine that
# replaced it, so a reader can tell at a glance which side of §19 a number sits on.
#
# Every value below is a WORKING placeholder carrying its GDD section. §17 lists the whole
# calibration surface; the SHAPE is sealed, the NUMBERS are a playtest pass.


# ============================ §3 · The faucet ================================
# "Musluk üç şeyi okur: atanmış satış kapasitesi + ilgi + faz."
# Flow accumulates per DAY from a per-WEEK rate, so a rep hired on a Tuesday contributes
# from Tuesday rather than at a week boundary the player cannot see.
const FAUCET_BASE_PER_WEEK := 3.0        # [K] base inbound with ZERO sales staff
const FAUCET_PER_REP_PER_WEEK := 2.0     # [K] added per assigned sales rep
const DAYS_PER_WEEK := 7.0

# Interest (§3; owner Ürün §9) maps onto a multiplier band. Zero interest still flows: the
# faucet never dries, it slows.
const INTEREST_MULT_MIN := 0.8           # [K]
const INTEREST_MULT_MAX := 1.3           # [K]
const INTEREST_SCALE := 100.0            # ProductState.INTEREST_MAX, mirrored for the map

# Phase multiplier (§3). Series A shares Traction's figure: the GDD names two phases and
# the third is the same market.
const PHASE_MULT_BOOTSTRAP := 1.0        # [K]
const PHASE_MULT_TRACTION := 1.25        # [K]

# "1★ akışı hiçbir durumda kurumaz" (§3). A hard floor under the product of every
# multiplier, expressed per week and applied to the 1★ band alone.
const ONE_STAR_FLOOR_PER_WEEK := 1.0     # [K]

# A day cannot deliver more than this however the multipliers stack. Kept from the old desk
# because it is legible: a full column reads as "you are not meeting anyone", never as
# "the faucet broke".
const FAUCET_DAILY_MAX := 2              # [K]

# Star mix per phase, 1★/2★/3★ (§3). The demo ceiling is 3★ and MÜHÜRLÜ (§2): 4-5★ is not
# generated and not written, and there is no locked 4★ card either.
const STAR_MIX_BOOTSTRAP := [0.75, 0.22, 0.03]   # [K]
const STAR_MIX_TRACTION := [0.35, 0.50, 0.15]    # [K]
const STAR_MIN := 1
const STAR_MAX := 3                      # demo ceiling (§2, MÜHÜRLÜ)

# Quality shifter (§3): "üst bandın payı ürün okumasıyla açılır; zayıf ürünle büyük balık
# kapıyı çalmaz." Product strength 0..1 scales the top band's share and the mass it loses
# falls to the 1★ band, so the mix always sums to 1 without a second table.
const QUALITY_SHIFT_FLOOR := 0.25        # [K] the weakest product still keeps this much of the top band
const QUALITY_STRENGTH_LOW := 0.6        # [K] axis-over-floor ratio that reads as weak
const QUALITY_STRENGTH_HIGH := 1.6       # [K] ratio at which the top band opens fully


# ============================ §4 · Pipeline ==================================
const LEAD_LIFE_DAYS := 7                # [K] an unworked lead waits this long
const RETURN_LOCK_DAYS := 30             # [K] an expired company will not return before this

# Routing verbs (§7.2.1). Stored on the Prospect as ids, never as localised text.
const ROUTE_NONE := ""
const ROUTE_RESERVED := "reserved"       # "Ayır" — the desk is the founder's; reps skip it
const ROUTE_REP := "rep"                 # "Temsilciye ver" — first in the band queue


# ============================ §5.0 · Time model ==============================
const MEETING_SKIP_HOURS := 2            # [K] the clock the sitting costs
const MEETING_ENTRY_CUTOFF_HOURS := 2    # [ÇALIŞMA] no entry this close to the end of the workday
const WORKDAY_START_HOUR := 9            # the company window, shared with the ODA light state
const WORKDAY_END_HOUR := 17


# ============================ §5.1 · Act 1 · persuasion ======================
# One visible percentage (§5.1) built with the engine's §9.6 grammar. The weights are the
# calibration surface; the SHAPE — which terms exist and which do not — is sealed.
const ODDS_CEIL := 0.97                  # [K] "tavan %97"
const ODDS_FLOOR := 0.05                 # [K] "taban sıfır değil"
const ODDS_BASE := 0.35                  # [K] the table before anything is read

const W_PRODUCT_FIT := 0.42              # [K] the dominant term
const W_FOUNDER_SALES := 0.22            # [K] the founder's Satış, the base
const W_PRICE_SIGNAL := 0.10             # [K] the stance dial read at the table (§7.5)
const W_PROVIDER_TIER := 0.10            # [K] the Ürün §10 provider ladder
const W_ANSWER := 0.08                   # [K] per played ▲/▼ verb

# Star mismatch is a HARD curve (§5.1): a founder two leagues under the table pays for it.
# Indexed by (customer star - founder star), clamped. A founder ABOVE the table pays zero
# and gains nothing (§12: "Kurucu ★'ı müşteriden yüksek | ceza sıfır; bonus satırı yok").
const MISMATCH_PENALTY := [0.0, 0.14, 0.34]   # [K] 0 / 1 / 2+ leagues over the founder

# Charisma has exactly two moments and enters no other formula (§5.1, MÜHÜRLÜ).
const CHARISMA_MISMATCH_RELIEF := 0.5    # [K] the fraction of the mismatch penalty it erases
const HONESTY_BONUS := 0.06              # [K] some archetypes pay for "Kabul et"


# ============================ §5.1.1 · Scene shape ===========================
# The CUSTOMER ends the meeting, not a quota. Two thresholds on one needle.
const CUT_HIGH := 0.72                   # [K] above this the customer cuts to Act 2
const CUT_LOW := 0.12                    # [K] below this the customer cuts and it is a loss
const SAFETY_CAP_PROBES := 6             # [K] the sitting can never run longer than this
const SKIP_TO_OFFER_FROM_PROBE := 2      # "Teklife geç" opens from the second probe

# Meeting forms by star (§5.1.1): one breath / standard / deep enquiry.
const PROBES_ONE_BREATH := 1             # 1★
const PROBES_STANDARD := 3               # [K] 2★
const PROBES_DEEP := 5                   # [K] 3★ and whales

# The inner voice is BUDGETED; there is no compulsory opening slot (§5.1.1).
const INNER_VOICE_BUDGET_PER_RUN := 6    # [K]

const MODIFIER_LINES_MAX := 4            # engine §9.6 — "maksimum 4 satır"


# ============================ §5.3 · Act 2 · negotiation =====================
# Seats come from the star band; there is no seat haggling (§5.3). One axis: price per seat.
const SEAT_BAND := {                     # [K]
	1: {"low": 5, "high": 10},
	2: {"low": 15, "high": 30},
	3: {"low": 40, "high": 70},
}
const SEAT_PRICE_MIN := 30               # [K] §17 "koltuk fiyat bandı $30-70"
const SEAT_PRICE_MAX := 70               # [K]

# The stance dial is the SINGLE B2B price source (§7.5, §15). It places the band.
const STANCE_COMPETITIVE := "competitive"
const STANCE_STANDARD := "standard"
const STANCE_PREMIUM := "premium"
const STANCES := [STANCE_COMPETITIVE, STANCE_STANDARD, STANCE_PREMIUM]
const STANCE_MULT := {                   # [K] %85 / 100 / 115
	"competitive": 0.85,
	"standard": 1.0,
	"premium": 1.15,
}
const STANCE_DEFAULT := STANCE_STANDARD

# Reserve, patience and the insult threshold (§5.3 "şekil formülleri").
const PATIENCE_MIN := 2                  # [K]
const PATIENCE_MAX := 4                  # [K]
const RESERVE_SENSITIVITY_MIN := 0.82    # [K] the archetype sensitivity band around the anchor
const RESERVE_SENSITIVITY_MAX := 1.18    # [K]
const INSULT_MARGIN := 0.28              # [K] "hakaret eşiği rezervin belirgin üstü"
const COUNTER_STEP_MIN := 0.06           # [K] the counter-offer step, from temperament
const COUNTER_STEP_MAX := 0.16           # [K]
# A promise narrows the band's TOP end (§5.3, §6): the promised feature is not free.
const PROMISE_BAND_NARROW := 0.15        # [K] the fraction of the band the locked zone takes
const WALK_LOCK_DAYS := 30               # [ÇALIŞMA] neutral walk, traceless


# ============================ §7 · Rep automation ============================
# Processing duration by league difference (§7.2), a [min, max] day span. The rep's
# effective output places the deal inside it.
const PROCESS_DAYS_OWN_LEAGUE := [6, 7]  # [K]
const PROCESS_DAYS_ONE_BELOW := [3, 4]   # [K]
const PROCESS_DAYS_TWO_BELOW := [2, 3]   # [K]
# The effective output that reads as a competent rep — the anchor the span measures against.
const PROCESS_REFERENCE_OUTPUT := 5.0    # [K]
const PROCESS_PREMIUM_PENALTY := 0.30    # [K] "Premium işleme süresini uzatır +%30"
const PROCESS_MIN_DAYS := 1

# §7.2.2 band cap. -1 = "Kendi ligi", the default; otherwise a full star step.
const BAND_CAP_OWN_LEAGUE := -1

# §7.6 price-break card. DEFINED HERE, FIRED BY THE EVENT PACKAGE — inert until then.
const PRICE_BREAK_CARD_ID := "sales.price_break"
const PRICE_BREAK_TRIGGER_LAST_DAYS := 2   # [ÇALIŞMA] the closing days of processing
const PRICE_BREAK_CANT_SAY_NO_MULT := 1.6  # [K] HAYIR DİYEMEZ drops the card more often
const PRICE_BREAK_SIGNING_DISCOUNT := 0.15 # [K] the permanent trace a broken band leaves

# §7.3 presentation.
const WEEKLY_SUMMARY_INTERVAL_DAYS := 7    # [ÇALIŞMA]
const WEEKLY_SUMMARY_CARD_ID := "sales.weekly_summary"
const TICKER_NEWSWORTHY_STAR := 3          # [ÇALIŞMA] a 3★ signing is news
# §7.3 "Prestij: haber değeri VE MARKA ETKİSİ". A newsworthy signing (whale, above the
# company's league, or the run's first 3★) reached the ticker but never the brand, which left
# brand with no faucet at all outside a handful of cards while churn, broken words and VC
# rejections all drain it — and brand still moves conviction in the Series A meeting.
const PRESTIGE_SIGNING_BRAND := 3           # [ÇALIŞMA]


# ============================ §8 · Whale ====================================
# Adaptive condition: the FIRST UNMET item of an ordered list. A satisfied item is never
# demanded (§8), so a whale never asks for something the player already has.
const WHALE_COND_PROVIDER := "provider_or_cert"
const WHALE_COND_LOCKED_TIER := "locked_tier"
const WHALE_COND_SLA := "sla_promise"
const WHALE_CONDITION_ORDER := [WHALE_COND_PROVIDER, WHALE_COND_LOCKED_TIER, WHALE_COND_SLA]


# ============================ §9 · Re-pitch =================================
# A lost customer may be returned to, but the blocker gates it: an unchanged named reason
# gives an unchanged answer, and the door says so.
const REPITCH_PENALTY := 0.10            # [ÇALIŞMA] the "−10 sınıfı ▼" trace, permanent


# ============================ §11.7 · Sales candidate curve =================
# Sales stars are money and the role carries no secondary area, so the curve sits half a
# step under every other role. The demo candidate ceiling is ★3,5 = raw 7 (§11.7).
const CANDIDATE_STAR_CAP_RAW := 7        # [ÇALIŞMA] ★3,5 on the 0-10 ruler
const CANDIDATE_TOP_CHANCE := 0.25       # [K] ~%25 of junior searches carry the ★2 file


# ============================ Loss reasons (§5.2) ============================
# The WORKING taxonomy. Content refines the wording later; these ids are what the loss log
# and the demand generator will speak.
const LOSS_STABILITY := "stability"
const LOSS_MISSING_TIER := "missing_tier"
const LOSS_PROVIDER_TRUST := "provider_trust"
const LOSS_PRICE := "price"
const LOSS_SWITCHING_RISK := "switching_risk"
const LOSS_REASONS := [LOSS_STABILITY, LOSS_MISSING_TIER, LOSS_PROVIDER_TRUST,
	LOSS_PRICE, LOSS_SWITCHING_RISK]


# ============================ Derived helpers ================================

## Interest 0-100 → the §3 multiplier band. Linear, clamped at both ends.
static func interest_mult(interest: float) -> float:
	var t: float = clampf(interest / INTEREST_SCALE, 0.0, 1.0)
	return lerpf(INTEREST_MULT_MIN, INTEREST_MULT_MAX, t)


## Phase (GameState.phase, 1/2/3) → the §3 multiplier.
static func phase_mult(phase: int) -> float:
	return PHASE_MULT_BOOTSTRAP if phase <= 1 else PHASE_MULT_TRACTION


## The star mix for a phase, as a fresh three-element array the caller may mutate.
static func star_mix(phase: int) -> Array:
	var src: Array = STAR_MIX_BOOTSTRAP if phase <= 1 else STAR_MIX_TRACTION
	return src.duplicate()


## Seat count band for a star tier (§5.3). Falls back to 1★ for anything unexpected.
static func seat_band(star: int) -> Dictionary:
	return SEAT_BAND.get(clampi(star, STAR_MIN, STAR_MAX), SEAT_BAND[STAR_MIN])


## Stance id → the §7.5 band placement multiplier.
static func stance_mult(stance: String) -> float:
	return float(STANCE_MULT.get(stance, STANCE_MULT[STANCE_DEFAULT]))


## League difference (customer star − rep star) → the §7.2 [min, max] day span.
static func process_span(league_delta: int) -> Array:
	if league_delta >= 0:
		return PROCESS_DAYS_OWN_LEAGUE.duplicate()
	if league_delta == -1:
		return PROCESS_DAYS_ONE_BELOW.duplicate()
	return PROCESS_DAYS_TWO_BELOW.duplicate()


# ============================================================================
#  The module's ONE deterministic mixer (§7.6 / §11.4)
# ============================================================================
#
# Sales had this arithmetic in one place (NegotiationSystem) and needed it in a second when
# the rep desk stopped handing every account the same terms. A second private copy is how a
# codebase ends up with four near-identical mixers that drift; this is the module's single
# home and `NegotiationSystem` now calls it, so the two cannot disagree.
#
# NOT AN RNG STREAM. It hashes run seed + a stable identity + a salt, so replaying the same
# run produces the same answer no matter what else was drawn in between — the same property
# `EvDice.check` has and the reason a reload cannot reroll a deal.
const MIX_MODULUS := 1000003
const MIX_MULTIPLIER := 48271
const MIX_INCREMENT := 12345
const MIX_SALT_STRIDE := 7919

const SALT_UNITS := 401          # negotiation seats / equity points
const SALT_RESERVE := 409        # negotiation hidden reserve
const SALT_REP_SEATS := 419      # the rep desk's seat count (§7.6)


## Deterministic value in [0, MIX_MODULUS) from the run seed, a stable identity and a salt.
static func mix(identity: String, salt: int) -> int:
	var base: int = GameState.run_seed + identity.hash()
	var n: int = (absi(base) % MIX_MODULUS) + MIX_SALT_STRIDE * (absi(salt) % MIX_MODULUS)
	return absi((n * MIX_MULTIPLIER + MIX_INCREMENT) % MIX_MODULUS)


## The same value as a 0..1 fraction — what every band placement actually wants.
static func mix_unit(identity: String, salt: int) -> float:
	return float(mix(identity, salt) % 1000) / 1000.0
