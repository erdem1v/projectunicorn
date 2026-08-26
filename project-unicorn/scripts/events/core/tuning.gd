class_name EvTuning
extends RefCounted

# THE SINGLE TUNING SURFACE (GDD §13.8).
#
# Read that section before changing anything here. Its words, not a paraphrase: every number in
# §13.3, §13.4 and §13.6 is a WORKING VALUE and NONE OF THEM HAS BEEN MEASURED. The category
# quotas, the phase multipliers, the five-day floor threshold, the 30/14-day brake windows —
# all of them will move in playtest.
#
# So the rule is architectural, not numerical: NOTHING DEPENDS ON A VALUE IN THIS FILE BEING
# WHAT IT IS TODAY. No branch keyed to "quota == 2". No comment elsewhere restating a number.
# No card text naming one — §8.4 makes that a seam read for exactly this reason, and the live
# bug it exists to prevent is END_META_BANKRUPTCY_FRANK still saying "yedi gün" while
# SHUTTER_DAYS has been 30 since the Frank v6 pass.
#
# The calibration round changes this file and nothing else. If a retune ever requires touching
# a second file, that is a defect in this one.

# --- §13.3 Layer 1: the same card ------------------------------------------

## Days before a fired card may return to the deck. A card may override; the linter warns
## under 7 (§17.9) because a card that can return within a week is usually an accident.
const MIN_GAP_DAYS_DEFAULT := 30

# --- §13.3 Layer 2: the same subject ---------------------------------------
#
# POOL CARDS ONLY. Critical cards and arc steps are exempt, and that exemption is the whole
# reason arcs work: an arc about one employee fires card after card about that employee, and
# throttling it would be throttling the story.

const SUBJECT_GAP_EMPLOYEE_DAYS := 14
const SUBJECT_GAP_CUSTOMER_DAYS := 30

# --- §13.3 Layer 3: category quota over a rolling 7 days --------------------
#
# The side benefit is the real one: a full quota forces the engine to look at another category,
# so the player's week is never one colour.

const CATEGORY_QUOTA_7D := {
	"team": 2,
	"customer": 2,
	"product": 2,
	"rival": 1,
	"funding": 1,
	"founder": 1,
	# The world speaking for itself — the press, the sector, the calendar. One a week: it is
	# atmosphere, and atmosphere that arrives twice in a week stops being atmosphere.
	"world": 1,
}

## A category not in the table gets this. Present so an author adding a category does not
## silently get "unlimited".
const CATEGORY_QUOTA_DEFAULT := 1

# --- §13.3 Layer 4: the daily ceiling --------------------------------------

## Interrupts per day. The third one becomes paper — it is not dropped (I4).
const MAX_INTERRUPTS_PER_DAY := 2

# --- §13.4 Phase multipliers -----------------------------------------------
#
# Applied to layers 3 and 4 only. Layers 1 and 2 are fixed, because repetition is bad in every
# phase and no amount of late-game pressure makes the same card twice in a week good.

const PHASE_MULTIPLIER := {
	1: 1.0,    ## Bootstrap
	2: 1.3,    ## Traction
	3: 1.6,    ## Series A Hunt
}

# --- §13.6 The floor: dead time --------------------------------------------

## Consecutive days with no interrupt and no paper before the quiet pool is drawn from.
const FLOOR_QUIET_DAYS := 5

## Three consecutive floor triggers that find nothing is a CONTENT HOLE, and the harness says
## so rather than letting randomness cover it (§13.6's last clause).
const FLOOR_EMPTY_REPORT_AFTER := 3

# --- §12 Expiry ------------------------------------------------------------
#
# §12.2's table. The default is a week; money gets a month because a term sheet the player
# cannot think about for a month is not a decision; low-stakes gets a fortnight.

const EXPIRY_DEFAULT_DAYS := 7
const EXPIRY_MONEY_DAYS := 30
const EXPIRY_LOW_STAKES_DAYS := 14

## Days before expiry at which a paper starts showing urgency, and at which it is promoted
## into a visible desk slot if it has been sitting behind the overflow chip. A consequence
## that lands off-screen is not a consequence.
const EXPIRY_URGENT_DAYS := 3

# --- §10.5 Arcs ------------------------------------------------------------

## An arc waiting for a new subject does not wait forever; after this it closes.
const ARC_AWAITING_SUBJECT_TIMEOUT_DAYS := 14

## Nesting is capped at 2 by §10.8. Arcs ship FLAT in v1 — parent_arc is reserved and defaults
## to null — so this is the cap the linter enforces, not a depth the runtime walks.
const ARC_MAX_NESTING := 2

## One active arc per subject unless the arc says otherwise (§10.7).
const ARC_PER_SUBJECT_DEFAULT := 1

# --- §8.5 Run-scarce narrative budgets -------------------------------------

const BUDGETS := {
	"frank_aphorism": 2,
}

# --- §18 Ticker ------------------------------------------------------------

const TICKER_CAPACITY := 20

# --- §13.7 The calibration anchor ------------------------------------------
#
# NOT a tuning value — a MEASUREMENT TARGET. The harness reports against it; nothing branches
# on it. §13.7 is explicit that the anchor is an instrument, not a proof.

const ANCHOR_MINUTES_PER_DECISION := 2.5
const ANCHOR_MAX_INTERRUPTS_PER_3_MIN := 3

# --- Build scope -----------------------------------------------------------

## Which version_scope values ship in this build. No release-tier system exists in the
## codebase, so this is the whole of it: one array, and content marked ea/full stays out of
## the pool without anyone having to build a tier system first.
##
## A `static var` rather than a `const` for one reason: the engine probe widens it to admit
## `fixture` scope for its own run and narrows it again afterwards, and a const Array is
## read-only. That is the ONLY sanctioned mutation — production code reads it and never writes.
static var SHIPPED_SCOPES: Array = ["demo"]
