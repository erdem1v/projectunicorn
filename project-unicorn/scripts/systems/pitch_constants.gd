class_name PitchConstants
extends RefCounted

# Single calibration surface for VC pitch GLOBAL knobs (Spec 4 / VC_PITCH_DESIGN.md §9).
# Per-VC knobs (term bands, patience, conviction weights) live in InvestorRegistry — the
# other single location. EVERY number here is a working placeholder; the calibration pass
# (last, one session) touches this file + the InvestorRegistry table and nothing else. The
# doc fixes STRUCTURE only.

# --- Conviction track zones (§3) — Soğuk 0-39 / Ilık 40-69 / Kazanıldı 70-100 ---
const ZONE_BOUNDS := [40, 70]          # [ilik_min, kazanildi_min]; passed to MeetingScene conviction
const ILIK_MIN := 40
const WON_MIN := 70

# --- Conviction seeding (§3 macro moment) — base + run-state weights ---
#
# RENAMED SEED_* → CONV_* (2026-08-27, the seed-rung wave). These twelve numbers have always
# meant "how the room is SEEDED with conviction", and the run now has an actual SEED ROUND with
# its own constants file. Two families spelled the same way is a bug waiting for its first
# careless autocomplete: the very first line of SeedRoundSystem that reached for "the seed MRR
# reference" would have been handed the SERIES A BAR. It would have compiled and run.
# The seed room's profile lives in seed_constants.gd; this block is the Series A room's.
const CONV_BASE := 20
# DECOUPLED FROM THE SERIES A BAR (2026-08-27), and the decoupling is the decision, not an
# oversight. This used to be `SalesSystem.TRACTION_MRR_TARGET`, so one calibration number
# silently answered two different questions: "does the door open" and "is this company's
# revenue impressive in the room". When the bar moved 40,000 → 120,000 the second answer moved
# with it — every Series A meeting lost ~10 conviction at once, and _sorgu_metrics' growth_flat
# branch (which compares MRR to this reference) became the permanent interrogation for every
# run the economy can actually produce. The room's yardstick is now its own number.
const CONV_MRR_REFERENCE := 40_000
const CONV_MRR_MAX_BONUS := 20         # full bonus when MRR ≫ reference (scaled)
const CONV_BRAND_FLOOR := 50           # brand at floor = 0 contribution
const CONV_BRAND_MAX := 12             # ± cap from brand distance to floor
const CONV_SHUTTER_PENALTY := -15      # Kepenk active (ledger 12 — thin runway priced in)
const CONV_THIN_RUNWAY_PENALTY := -8   # runway below comfort but not shuttered
const CONV_SCANDAL_PENALTY := -12      # unmanaged major scandal
const CONV_LEVERAGE_BONUS := 15        # a live sheet already in pocket (§6)
const CONV_WARM_INTRO_BONUS := 12      # Bosphorus via Frank
const CONV_DIMENSION_MATCH_BONUS := 8  # Meridian ↔ subgenre/product dimension
const CONV_CALLBACK_BONUS := 10        # re-entry after a met callback (§5)

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
const GECISTIR_CAP := 65               # deflection can never win the room (§4 Beat 3)

# --- Beat 1 perception + Beat 4 push ---
const BEAT1_DIFF := DIFF_ORTA
const MASAYI_ZORLA_DIFF := DIFF_ZORLU  # Ilık fork gamble; failure = RET (hard, Erdem call C)

# --- Beat skill routing (SKILL-RENAME 2026-07-16, re-pointed 2026-08-21) ---
# Erdem: VC persuasion beats read the founder's persuasion number; the traction angle reads
# Satış. One const per beat so a per-site remap is a one-token change.
# 2026-08-21: `influence` became `charisma` when the areas model (§4) brought Karizma back
# under its own name. Same number, same reads — ch. 02 §4 already defined Karizma as
# "pitch/fundraising probability and terms", which is exactly this routing.
const BEAT1_SKILL := "charisma"         # Odayı oku
const BEAT3_SKILL := "charisma"         # Sorgu postures (dürüst / spin / geçiştir)
const BEAT4_PUSH_SKILL := "charisma"    # Masayı zorla
const ANGLE_SKILL := {"vizyon": "charisma"}   # Beat 2 anlatı; fallback: "sales" (traction)

# --- Prep (§1) ---
const MEETING_LEAD_DAYS := 3           # request → meeting day
const PREP_DAYS := 2
const PREP_MIN_DAYS_BEFORE := 2        # prep startable only if ≥ this many full days remain
const PREP_BONUS := 2                  # SkillCheck bonus units on the focused check (+~20% odds)
# K4 — moving a booked meeting costs a little of that fund's goodwill, paid at its NEXT meeting
# (stored per fund in vc_states.move_penalty, consumed when that meeting begins). Cancelling
# also shuts the booking desk for the rest of the day.
const MEETING_CANCEL_PENALTY := 3      # conviction points off the fund's next meeting
const MEETING_RESCHEDULE_PENALTY := 2  # ditto; reschedule = the same lead time again

# --- Sheet economy (§5) ---
# K5 (2026-09): a Series A sheet is valid for a fixed number of BUSINESS days - weekdays on the
# real calendar (GameState.is_business_day). TermSheet.expires_day is the day the last one falls
# on; business_days_left() counts down to it. A queued sheet gets a fresh window on delivery.
const SHEET_VALIDITY_BUSINESS_DAYS := 10
const MAX_SHEETS := 2
const WARNING_DAYS := 3                 # BUSINESS days: expiry warning card + TopBar chip threshold (ledger 14)

# K6 — the offer row before the table shows an ESTIMATED range, never the number. The range
# always contains the true opening term and never sits centred on it: the true value's position
# inside the range is a deterministic fraction (seeded by fund id + sheet grant day, so it never
# rerolls) drawn from [EST_POS_MIN, EST_POS_MAX] or its mirror.
const EST_VAL_WIDTH_PCT := 25           # valuation range width, % of the true valuation
const EST_VAL_MIN_WIDTH_M := 2          # ... but never narrower than this ($M)
const EST_DIL_WIDTH_PCT := 30           # dilution range width, % of the true dilution
const EST_DIL_MIN_WIDTH := 4            # ... but never narrower than this (percentage points)
const EST_POS_MIN := 0.15               # true value sits 15-40 % in from one edge (or the mirror)
const EST_POS_MAX := 0.40

# --- Cascade / callbacks ---
# (Cascade table count lives at its single home, EndingsSystem.CASCADE_TABLES — UI reads it there.)
const CALLBACK_MRR_GROWTH_PCT := 20     # "MRR +20% over meeting-day value"
const CALLBACK_BUGS_UNDER := 3          # "active bugs under N"

# --- Soft cap eve: RETIRED (Frank v6, surface 15) ---
# There was a Frank line on the eve of the soft cap ("yarın son gün, cebinde teklif var",
# ledger 16), inherited from the Day-180 wall before it. The document moved that card onto a
# different moment - the last day to answer the last live OFFER - so the calendar constant it
# rode has no reader left and is gone rather than left lying around.
#
# THE SOFT CAP NOW HAS NO TELEGRAPH: a run can reach EndingsSystem.SOFT_CAP_DAY with no prior
# warning. That is open work with an owner-shaped hole in it (a "final stretch" surface, author
# and voice undecided) and it is written up in docs/writing/FRANK_UNWIRED.md.

# --- Term Sheet Table (Spec 6 / ENDGAME_DESIGN.md §5) — the push-your-luck negotiation ---
# Every number is a working placeholder (calibration pass tunes it). Each lever's push reads
# ONE founder skill (the payoff of the onboarding skill choice) — kept as an editable data
# table so the mapping never hides inside table logic:
# 2026-08-21: `dilution` used to read `negotiation`, which rev 2's six areas RETIRE — there
# is no negotiation area. Bound to Karizma as the nearest fit (ch. 02 §4 gives Karizma the
# TERMS of a raise, not just the odds). THIS IS THE ONE BINDING rev 2 DOES NOT AUTHORIZE;
# it is deliberately one token on one line, and it belongs to ch. 09's turn to rule on.
const LEVER_SKILL := {"valuation": "sales", "dilution": "charisma", "board": "charisma"}
# Per-lever base difficulty (SkillCheck diff units). Kept 0-2 so "temel" reads legibly —
# diff 3 would zero the base (BASE_CHANCE − 3·DIFFICULTY_STEP = 0). Board is hardest (control),
# valuation easiest (a market argument).
const LEVER_DIFF := {"valuation": 0, "dilution": 1, "board": 2}
# Push step sizes — one successful push moves the lever this far the founder's way.
const VAL_STEP := 4                     # valuation +$4M per push (higher = founder-good)
const DIL_STEP := 4                     # dilution −4pp per push (lower = founder-good)
const DIL_FLOOR := 10                   # dilution can't be pushed below this (%)
# Board has no numeric step — a fixed sequence: drop veto first, then drop the seat (§8).
# Odds self-damping: each push to a lever lowers its own subsequent odds (decision 9).
const PUSH_DECAY := 0.12                # −12pp per prior push to that lever
const PUSH_ODDS_FLOOR := 0.05           # a lever never becomes literally impossible (ledger 6)
# Leverage — a second live sheet (§8): bonus to ALL push odds + a one-notch-better opening.
const LEVERAGE_BONUS_UNITS := 1         # SkillCheck bonus units (each = +BONUS_STEP = +10pp)
const LEVERAGE_OPEN_NOTCH := 4          # opening valuation starts +$4M better when leverage is live
# Dial spin duration (seconds) — the push roll presentation.
const DIAL_SPIN_SECS := 0.8

# --- THE TWO RUNGS (seed rung, 2026-08-27) --------------------------------
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
# The opening offer used to be four numbers copied verbatim off the investor row, so the same
# company got the same sheet whether it arrived at the table with $40K or $400K of revenue.
# It is priced now: valuation = ARR x a multiple, the multiple set by how fast the company is
# actually growing, then nudged by the fund's own archetype. The four funds keep their
# personalities; what they lose is the frozen number.
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
# "Repeated rejections cost brand and morale." They used to cost a cascade point and nothing
# else, which made three closed doors a counter rather than a season. Small on purpose: the
# cascade is the real consequence, this is the weather around it.
const REJECT_BRAND_COST := 3
const REJECT_MORALE_COST := 4

## Difficulty label shown in the odds text, for a diff int.
static func diff_label(diff: int) -> String:
	match diff:
		DIFF_KOLAY: return TranslationServer.translate("PITCH_DIFF_EASY")
		DIFF_ORTA: return TranslationServer.translate("PITCH_DIFF_MEDIUM")
		_: return TranslationServer.translate("PITCH_DIFF_HARD")


## Founder-skill display label for the odds split (§5). Single label home is
## FounderConstants (CSV-backed since SKILL-RENAME); kept here as a delegate so
## existing callers (term sheet table, meeting) stay unchanged.
static func skill_label(skill_name: String) -> String:
	return FounderConstants.skill_label(skill_name)
