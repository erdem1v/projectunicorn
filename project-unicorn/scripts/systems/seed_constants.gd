class_name SeedConstants
extends RefCounted

# THE SEED RUNG'S SINGLE CALIBRATION SURFACE (GDD v2 ch. 09 §3). Every number here is a
# working value; the playtest gate retunes this file and the seed lever tables in
# PitchConstants (SEED_LEVER_SKILL / SEED_LEVER_DIFF), and nothing else.
#
# WHY A SECOND CONSTANTS FILE INSTEAD OF MORE ROWS IN PitchConstants. PitchConstants is the
# GLOBAL pitch surface — zones, beat deltas, prep, sheet economy, the term-sheet table's lever
# tables — and both stages read it. This file is read by ONE rung. Keeping them apart is what
# lets a calibration pass answer "what does the seed cost" by opening one file.
#
# NAMING. Inside this file `CONV_*` means "the seed room's conviction profile"; the call site
# always says which room: `SeedConstants.CONV_MRR_REFERENCE` is the seed room,
# `PitchConstants.CONV_MRR_REFERENCE` is the Series A room.


# --- The door --------------------------------------------------------------
# Traction phase only, and the bar is NEVER RENDERED — the appetite grammar (the signal is
# shown, the number is not) governs this door exactly as it governs the Series A one.
const DOOR_MRR := 20_000                  # the live bar (band anchor)
const DOOR_MRR_BAND := [15_000, 25_000]   # [ÇALIŞMA] the envelope the anchor sits in
const DOOR_PHASE := 2                     # Traction. The door CLOSES on entering phase 3:
                                          # one seed pitch per run, taken here or not at all.

# --- Conviction → term band ------------------------------------------------
# SEED CANNOT HARD-REJECT. The room still has a temperature; what changes is what the
# temperature buys. The cut points are deliberately ALIASED to the meeting's own zone bounds so
# the conviction track the player watched all meeting maps 1:1 onto the band they get —
# Soğuk → harsh, Ilık → standard, Kazanıldı → strong. A separate pair of cut points would have
# let the dial say one thing and the sheet say another.
const BAND_STRONG_MIN := PitchConstants.WON_MIN
const BAND_STANDARD_MIN := PitchConstants.ILIK_MIN
const BAND_STRONG := "strong"
const BAND_STANDARD := "standard"
const BAND_HARSH := "harsh"
const BAND_IDS := [BAND_HARSH, BAND_STANDARD, BAND_STRONG]   # index order == severity order

# --- Raise + dilution bands ------------------------------------------------
# Real-world-anchored: $100-150K at 12-18% implies a $555K-$1.25M post, the compressed end of a
# real pre-seed. The implied post is a DERIVED CAPTION at the table, never a lever — see
# TermSheetTableSystem.implied_post_money(). It cannot be pushed because it has no row.
const RAISE_MIN := 100_000
const RAISE_MAX := 150_000
const RAISE_STEP := 10_000    # one successful push moves the raise this far the founder's way
const DIL_MIN := 12           # also the push FLOOR: a push cannot leave the band
const DIL_MAX := 18
const DIL_STEP := 2           # one successful push, in percentage points

# --- Opening position by band ----------------------------------------------
# The band picks the corner of the box; the fund's archetype nudges inside it (below).
const OPENING := {
	BAND_STRONG:   {"raise": 150_000, "dilution_pct": 12},
	BAND_STANDARD: {"raise": 125_000, "dilution_pct": 15},
	BAND_HARSH:    {"raise": 100_000, "dilution_pct": 18},
}

# Board position by band. A seed investor taking a full board seat is the HARSH read; a clean
# seed is what a strong room buys. In the strong band the board lever therefore opens ALREADY AT
# ITS BEST — the table already handles that (`_lever_at_best` disables the push), and it reads
# as a reward rather than a missing row.
const BOARD := {
	BAND_STRONG:   {"seats": 0, "veto": false},
	BAND_STANDARD: {"seats": 0, "veto": true},
	BAND_HARSH:    {"seats": 1, "veto": true},
}

# Patience pool by band, mirroring InvestorRegistry's per-fund pools: a warm room has more rope.
# The Series A pools stay on the funds; this is the seed rung's own ladder.
const PATIENCE_BY_BAND := {BAND_STRONG: 4, BAND_STANDARD: 3, BAND_HARSH: 2}

# --- Archetype nudge inside the band ---------------------------------------
# The four funds keep their personalities at seed. Keyed by the fund's OWN term_bands words
# (InvestorRegistry.term_bands.valuation / .dilution), so a fund re-cast in the registry moves
# here for free. Results are clamped back into [RAISE_MIN, RAISE_MAX] / [DIL_MIN, DIL_MAX]:
# the band is the promise, the archetype is only where inside it you land.
const ARCH_RAISE_NUDGE := {"generous": 10_000, "high": 5_000, "mid": 0, "low": -5_000}
const ARCH_DIL_NUDGE := {"generous": -1, "low": -1, "mid": 0, "high": 1}

# --- The seed room's conviction profile ------------------------------------
# REWEIGHTED TOWARD THE FOUNDER AND THE INSIGHT, AWAY FROM HARD METRICS. That is the whole
# difference between the two rooms, and it is why one scene can run both: a seed investor is
# buying a person and a thesis, a Series A investor is auditing a business.
const CONV_BASE := 30                     # a softer floor than Series A's 20 — the room starts open
const CONV_MRR_REFERENCE := DOOR_MRR      # NOT the Series A bar. The seed room asks "has anyone
                                          # paid you yet", not "are you a Series A company".
const CONV_MRR_MAX_BONUS := 8             # vs 20 at Series A
const CONV_BRAND_FLOOR := 50
const CONV_BRAND_MAX := 6                 # vs 12
const CONV_FOUNDER_SKILL := "charisma"    # Karizma — ch. 02 §4's "pitch/fundraising odds and terms"
const CONV_FOUNDER_MAX := 18              # scaled off the 0-10 founder ruler; the founder IS the asset
const CONV_VISION_BONUS := 10             # a shipped product to point at while telling the story
const CONV_NARRATIVE_DOMAIN_BONUS := 8    # the fund whose domain is "narrative" is at home here
const CONV_WARM_INTRO_BONUS := 12         # Frank's introduction (a registry property today)
const CONV_SHUTTER_PENALTY := -10         # thinner than Series A's -15: seed money is what fixes it
const CONV_THIN_RUNWAY_PENALTY := -4
const CONV_SCANDAL_PENALTY := -12         # UNCHANGED from Series A on purpose: character is the one
                                          # thing a seed investor cannot diligence away

# Beat-2 angle difficulty shift, applied on top of the fund's own weights and clamped back into
# the real difficulty range. Vision gets easier, hard metrics get harder — the same three
# choices, priced for a different room.
const CONV_ANGLE_SHIFT := {"vizyon": -1, "traction": 0, "metrik": 1}

# --- Seeded-you warmth at Series A -----------------------------------------
# The fund that led the seed walks into the Series A room already believing. Read by
# VCPitchSystem.initial_conviction, and it is the ONLY piece of ch. 09 §6's relationship model
# that is built; the other states (passed / you-walked / you-pushed-hard) are not.
const SEED_LEAD_WARMTH_BONUS := 10

# --- Growth expectation after taking the money -----------------------------
# Taking seed means owing growth (ch. 09 §2), judged as a ROLLING AVERAGE, not a streak —
# SeedRoundSystem.expectation() says why.
const EXPECT_MOM_PCT := 10            # rolling month-over-month average the run is judged against
const EXPECT_WINDOW_MONTHS := 3       # the window that average is taken over
const EXPECT_GRACE_DAYS := 60         # from signing: nothing grows in the first two months
const EXPECT_NONE := 0                # no seed taken — the expectation does not exist
const EXPECT_GRACE := 1               # inside the grace window
const EXPECT_ON_TRACK := 2
const EXPECT_STALLED := 3             # "durgun" — the state that colours the fumes copy

# --- Bookkeeping -----------------------------------------------------------
const TX_LABEL := "seed_round"        # raw id; display via FinanceSystem.ONE_TIME_LABELS
# THE SEED OFFER NEVER LAPSES: the rung is guaranteed once entered, so an expiry would be a
# way to lose it by doing nothing. The sheet still carries an expires_day, and a sentinel far
# in the future keeps every generic countdown renderer honest instead of letting it read a
# negative number and call the offer dead.
const NO_EXPIRY_DAY := 2_000_000_000


# ============================================================================
# Band helpers — the two questions every caller asks about a conviction value
# ============================================================================

## Conviction (already capped by the meeting) → the band id it buys.
static func band_for(conviction: int) -> String:
	if conviction >= BAND_STRONG_MIN:
		return BAND_STRONG
	if conviction >= BAND_STANDARD_MIN:
		return BAND_STANDARD
	return BAND_HARSH


## The band's index into BAND_IDS, for the `by_seam` card bodies: EvPresenter._resolve_variant
## runs the seam value through int(), so the seam carries an INDEX, never the id string (a
## String would collapse to 0 and every variant body would render the harsh arm forever).
## Unknown ids read as harsh rather than erroring: a body that renders the wrong arm is
## recoverable, a crash mid-meeting is not.
static func band_index(band_id: String) -> int:
	return maxi(0, BAND_IDS.find(band_id))
