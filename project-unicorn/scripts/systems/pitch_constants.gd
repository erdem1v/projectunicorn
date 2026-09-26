class_name PitchConstants
extends RefCounted

# Single calibration surface for VC pitch GLOBAL knobs.
# Per-VC knobs (term bands, patience, conviction weights) live in InvestorRegistry — the
# other single location. EVERY number here is a working placeholder the calibration pass
# tunes; the design fixes STRUCTURE only.

# --- Conviction track zones — Soğuk 0-39 / Ilık 40-69 / Kazanıldı 70-100 ---
const ILIK_MIN := 40
const WON_MIN := 70
const ZONE_BOUNDS := [ILIK_MIN, WON_MIN]   # drawn by ConvictionTrack

# --- Conviction seeding (the macro moment) — base + run-state weights ---
# CONV_*, never SEED_*: SEED_ names the seed ROUND, and a conviction constant spelled that way
# is one careless autocomplete from handing the seed room the Series A room's numbers. This
# block is the Series A room's profile; the seed room's lives in SeedConstants under the same
# CONV_* names.
const CONV_BASE := 20
# The room's own revenue yardstick, deliberately NOT SalesSystem.TRACTION_MRR_TARGET: "does
# the door open" and "is this revenue impressive in the room" are different questions. It is
# also the line _sorgu_metrics' growth_flat branch compares MRR against.
const CONV_MRR_REFERENCE := 40_000
const CONV_MRR_MAX_BONUS := 20         # full bonus when MRR ≫ reference (scaled)
const CONV_BRAND_FLOOR := 50           # brand at floor = 0 contribution
const CONV_BRAND_MAX := 12             # ± cap from brand distance to floor
const CONV_SHUTTER_PENALTY := -15      # Kepenk active (thin runway priced in)
const CONV_THIN_RUNWAY_PENALTY := -8   # runway below comfort but not shuttered
const CONV_SCANDAL_PENALTY := -12      # unmanaged major scandal
const CONV_LEVERAGE_BONUS := 15        # a live sheet already in pocket
const CONV_WARM_INTRO_BONUS := 12      # Bosphorus via Frank
const CONV_DIMENSION_MATCH_BONUS := 8  # Meridian ↔ subgenre/product dimension
const CONV_CALLBACK_BONUS := 10        # re-entry after a met callback

# --- Difficulty band → SkillCheck.resolve diff int (visible Disco labels) ---
const DIFF_KOLAY := 1
const DIFF_ORTA := 2
const DIFF_ZORLU := 3
const DIFF_CETIN := 3                   # "Çetin" reads harder than Zorlu by copy; same diff for now

# --- Beat 2 Anlatı deltas ---
const BEAT2_SUCCESS_MIN := 15          # near_pass margin
const BEAT2_SUCCESS_MAX := 25          # crit_success margin
const BEAT2_FAIL := -5

# --- Beat 3 Sorgu postures ---
const DURUST_SUCCESS := 20
const DURUST_FAIL := -8
const DURUST_DIFF := DIFF_ORTA
const SPIN_SUCCESS := 28
const SPIN_FAIL := -15
const SPIN_DIFF := DIFF_ZORLU
const GECISTIR_SUCCESS := 5
const GECISTIR_FAIL := -5
const GECISTIR_DIFF := DIFF_KOLAY
const GECISTIR_CAP := 65               # deflection can never win the room

# --- Beat 1 perception + Beat 4 push ---
const BEAT1_DIFF := DIFF_ORTA
const MASAYI_ZORLA_DIFF := DIFF_ZORLU  # Ilık fork gamble; failure = RET (hard)

# --- Beat skill routing ---
# VC persuasion beats read Karizma (ch. 02 §4: "pitch/fundraising probability and terms");
# the metrik and traction angles read Satış (ANGLE_SKILL's fallback). One const per beat so a
# per-site remap is a one-token change.
const BEAT1_SKILL := "charisma"         # Odayı oku
const BEAT3_SKILL := "charisma"         # Sorgu postures (dürüst / spin / geçiştir)
const BEAT4_PUSH_SKILL := "charisma"    # Masayı zorla
const ANGLE_SKILL := {"vizyon": "charisma"}   # Beat 2 anlatı; fallback: "sales" (metrik, traction)

# --- Prep ---
const MEETING_LEAD_DAYS := 3           # request → meeting day
const PREP_DAYS := 2
const PREP_MIN_DAYS_BEFORE := 2        # prep startable only if ≥ this many full days remain
const PREP_BONUS := 2                  # SkillCheck bonus units on the focused check (+~20% odds)
# Moving a booked meeting costs a little of that fund's goodwill, paid at its NEXT meeting
# (stored per fund in vc_states.move_penalty, consumed when that meeting begins). Cancelling
# also shuts the booking desk for the rest of the day.
const MEETING_CANCEL_PENALTY := 3      # conviction points off the fund's next meeting
const MEETING_RESCHEDULE_PENALTY := 2  # ditto; reschedule = the same lead time again

# --- Sheet economy ---
# A Series A sheet is valid for a fixed number of BUSINESS days - weekdays on the
# real calendar (GameState.is_business_day). TermSheet.expires_day is the day the last one falls
# on; business_days_left() counts down to it. A queued sheet gets a fresh window on delivery.
const SHEET_VALIDITY_BUSINESS_DAYS := 10
const MAX_SHEETS := 2
const WARNING_DAYS := 3                 # BUSINESS days: expiry warning card + TopBar chip threshold

# The offer row before the table shows an ESTIMATED range, never the number. The range
# always contains the true opening term and never sits centred on it: the true value's position
# inside the range is a deterministic fraction (seeded by fund id + sheet grant day, so it never
# rerolls) drawn from [EST_POS_MIN, EST_POS_MAX] or its mirror.
const EST_VAL_WIDTH_PCT := 25           # valuation range width, % of the true valuation
const EST_VAL_MIN_WIDTH_M := 2          # ... but never narrower than this ($M)
const EST_DIL_WIDTH_PCT := 30           # dilution range width, % of the true dilution
const EST_DIL_MIN_WIDTH := 4            # ... but never narrower than this (percentage points)
const EST_POS_MIN := 0.15               # true value sits 15-40 % in from one edge (or the mirror)
const EST_POS_MAX := 0.40

# --- Callbacks ---
const CALLBACK_MRR_GROWTH_PCT := 20     # "MRR +20% over meeting-day value"
const CALLBACK_BUGS_UNDER := 3          # "active bugs under N"

# --- Term Sheet Table — the push-your-luck negotiation ---
# Every number is a working placeholder (calibration pass tunes it). Each lever's push reads
# ONE founder skill (the payoff of the onboarding skill choice) — kept as an editable data
# table so the mapping never hides inside table logic. `dilution` reads Karizma as the nearest
# fit (ch. 02 §4 gives Karizma the TERMS of a raise); the Ekip GDD does not bind it — one
# token on one line, left for ch. 09 to rule on.
const LEVER_SKILL := {"valuation": "sales", "dilution": "charisma", "board": "charisma"}
# Per-lever base difficulty (SkillCheck diff units). Kept 0-2 so "temel" reads legibly —
# diff 3 would zero the base (BASE_CHANCE − 3·DIFFICULTY_STEP = 0). Board is hardest (control),
# valuation easiest (a market argument).
const LEVER_DIFF := {"valuation": 0, "dilution": 1, "board": 2}
# Push step sizes — one successful push moves the lever this far the founder's way.
const VAL_STEP := 4                     # valuation +$4M per push (higher = founder-good)
const DIL_STEP := 4                     # dilution −4pp per push (lower = founder-good)
const DIL_FLOOR := 10                   # dilution can't be pushed below this (%)
# Board has no numeric step — a fixed sequence: drop veto first, then drop the seat.
# Odds self-damping: each push to a lever lowers its own subsequent odds.
const PUSH_DECAY := 0.12                # −12pp per prior push to that lever
const PUSH_ODDS_FLOOR := 0.05           # a lever never becomes literally impossible
# Leverage — a second live sheet: bonus to ALL push odds + a one-notch-better opening.
const LEVERAGE_BONUS_UNITS := 1         # SkillCheck bonus units (each = +BONUS_STEP = +10pp)
const LEVERAGE_OPEN_NOTCH := 4          # opening valuation starts +$4M better when leverage is live
# Dial spin duration (seconds) — the push roll presentation.
const DIAL_SPIN_SECS := 0.8

# --- THE TWO RUNGS ---------------------------------------------------------
# One meeting scene and one table serve both rounds. Which round a sitting IS travels on the
# data rather than through a parameter chain: the MEETING carries it in a sitting-local static
# (it has no sheet yet - the sheet is what it produces), and the TABLE reads it off
# TermSheet.stage (the seed offer never expires, so the table can open days later, by which
# time any static is long gone).
const STAGE_SEED := "seed"
const STAGE_SERIES_A := "series_a"

# The seed table's lever tables. Same three rows, same patience ladder, same dial - what
# changes is that lever one is the MONEY (a raise in dollars) instead of the valuation, so it
# needs its own skill routing and its own base difficulty. Karizma across the board: a seed
# round is negotiated by the founder in a room, not by a sales organisation.
const SEED_LEVER_SKILL := {"raise": "charisma", "dilution": "charisma", "board": "charisma"}
const SEED_LEVER_DIFF := {"raise": 1, "dilution": 1, "board": 2}

# --- Series A term sheets, DERIVED FROM THE RUN (ch. 09 §5.4) -------------
# valuation = ARR x a multiple, the multiple set by how fast the company is actually growing,
# then nudged by the fund's own archetype. The four funds keep their personalities; the price
# comes from the run.
#
# The growth band reads the SAME rolling average the seed expectation and the buyout multiple
# read (GameState.get_mom_growth_avg_pct) - one answer to "is this company growing", three
# consumers, rather than three spellings that drift apart.
const ARR_MULTIPLE := {"low": 8, "mid": 11, "high": 14}
const ARR_GROWTH_HIGH_PCT := 12   # rolling 3-month MoM average at or above this -> "high"
const ARR_GROWTH_MID_PCT := 5     # ... at or above this -> "mid"; below -> "low"
const ARR_WINDOW_MONTHS := 3
# Where inside the 15-25 % dilution band a fund opens, keyed on its own term_bands.dilution
# word, and how its term_bands.valuation word moves the valuation (percent).
const SERIES_A_DIL_MIN := 15
const SERIES_A_DIL_MAX := 25
const SERIES_A_DIL_BY_ARCH := {"low": 15, "generous": 16, "mid": 18, "high": 22}
const SERIES_A_VAL_ARCH_PCT := {"low": -20, "mid": 0, "high": 15, "generous": 25}

# --- What a rejection costs (ch. 09 §4) -----------------------------------
# "Repeated rejections cost brand and morale" — on top of the cascade point. Small on purpose:
# the cascade is the real consequence, this is the weather around it.
const REJECT_BRAND_COST := 3
const REJECT_MORALE_COST := 4

## Difficulty label shown in the odds text, for a diff int.
static func diff_label(diff: int) -> String:
	match diff:
		DIFF_KOLAY: return TranslationServer.translate("PITCH_DIFF_EASY")
		DIFF_ORTA: return TranslationServer.translate("PITCH_DIFF_MEDIUM")
		_: return TranslationServer.translate("PITCH_DIFF_HARD")


## Founder-skill display label for the odds split (home: FounderConstants.skill_label).
static func skill_label(skill_name: String) -> String:
	return FounderConstants.skill_label(skill_name)
