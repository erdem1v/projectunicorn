class_name EvTuning
extends RefCounted

# THE SINGLE TUNING SURFACE (GDD §13.8). Every number in §13.3, §13.4 and §13.6 is a WORKING
# VALUE that has not been measured and will move in playtest.
#
# So NOTHING DEPENDS ON A VALUE IN THIS FILE BEING WHAT IT IS TODAY: no branch keyed to
# "quota == 2", no comment elsewhere restating a number, no card text naming one (§8.4 makes
# that a seam read). A retune changes this file and nothing else.

# --- §13.3 Layer 1: the same card ------------------------------------------

## Weeks before a fired card may return to the deck. A card may override it.
const MIN_GAP_WEEKS_DEFAULT := 4

# --- §13.3 Layer 2: the same subject ---------------------------------------
#
# POOL CARDS ONLY. Critical cards and arc steps are exempt, and that exemption is the whole
# reason arcs work: an arc about one employee fires card after card about that employee, and
# throttling it would be throttling the story.

const SUBJECT_GAP_EMPLOYEE_WEEKS := 2
const SUBJECT_GAP_CUSTOMER_WEEKS := 4

# --- §13.3 Layers 1b and 2b: the same FAMILY -------------------------------
#
# Layer 1 asks how soon the SAME card may return. These two ask how soon its FAMILY may: three
# different cards about an employee asking for money inside a month is one card as far as the
# week feels. Rhythm families are short, money families long.

const FAMILY_GAP_WEEKS_DEFAULT := 6

const FAMILY_GAP_WEEKS := {
	"employee_asks_money": 12,
	"world_offer_b2c": 8,
	"world_offer_b2b": 8,
	"founder_solitude": 3,
	"founder_network": 4,
	"customer_risk": 2,
	"product_floor": 4,
}


static func family_gap(family: String) -> int:
	return int(FAMILY_GAP_WEEKS.get(family, FAMILY_GAP_WEEKS_DEFAULT))


# --- §3.1 Plausibility: the family's seniority floor -----------------------
#
# What a FAMILY of cards needs of its subject, whatever the single card asks for: the catalogue
# compiles the higher of the two into the slot's selector. A family absent here has no floor,
# and the card's own figure stands alone.

const FAMILY_SUBJECT_TENURE := {"employee_asks_money": 26}

# --- §13.3 Layer 3: category quota per week ----------------------------------
#
# The side benefit is the real one: a full quota forces the engine to look at another category,
# so the player's week is never one colour.

const CATEGORY_QUOTA_WEEK := {
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

# --- §13.3 Layer 4: the per-tick ceiling -----------------------------------

## Interrupts per game day (tick). The third one becomes paper — it is not dropped (I4).
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

## Consecutive weeks with no interrupt and no paper before the quiet pool is drawn from.
const FLOOR_QUIET_WEEKS := 1

## Three consecutive floor triggers that find nothing is a CONTENT HOLE, and the harness says
## so rather than letting randomness cover it (§13.6's last clause).
const FLOOR_EMPTY_REPORT_AFTER := 3

# --- §14.1 The pool's "nothing this week" ----------------------------------
#
# A virtual candidate in the pool's draw: without it the deck empties itself into every quiet
# week and a threshold reads as a firing date. Bootstrap's deck is thin and its weeks should
# breathe; a Series A week is full on its own. The floor is NOT governed by it (ruling E1) — a
# drawn blank still leaves a clear desk, and a clear desk is what the quiet pool is for.

const POOL_NOTHING_WEIGHT := {1: 1.5, 2: 1.0, 3: 0.6}

# --- §27.19 The delay window -----------------------------------------------

## Weeks a card's condition may go un-held before its armed window is thrown away and redrawn.
## One sprint cycle, so a condition that comes and goes with the sprint keeps its window.
const DISARM_WEEKS := 4

# --- §27.21 The first weeks ------------------------------------------------

## Game weeks in which the pool says nothing at all: the opening belongs to the tutorial and to
## the systems that name their own moment. The quiet floor, requests, arcs and system cards are
## exempt (ruling E4), so the opening is not silent — it is only not random.
const START_IMMUNITY_WEEKS := 3

# --- §12 Expiry ------------------------------------------------------------
#
# §12.2's table, in weeks. Fallbacks only: every interrupt and paper card carries its own
# expires_weeks (lint), chosen for the situation it describes.

const EXPIRY_DEFAULT_WEEKS := 1
const EXPIRY_MONEY_WEEKS := 4
const EXPIRY_LOW_STAKES_WEEKS := 2

## The last weeks of a paper that lived longer than this: the desk highlights them, the queue
## ranks the paper as expiring and the last warning fires. A paper whose whole life fits inside
## says "this week" from the start and gets no separate warning.
const EXPIRY_URGENT_WEEKS := 1

# --- §10.5 Arcs ------------------------------------------------------------

## An arc waiting for a new subject does not wait forever; after this many weeks it closes.
const ARC_AWAITING_SUBJECT_TIMEOUT_WEEKS := 2

## Nesting cap (§10.8). Arcs ship flat, so this is the cap the linter enforces, not a depth the
## runtime walks.
const ARC_MAX_NESTING := 2

## One active arc per subject unless the arc says otherwise (§10.7).
const ARC_PER_SUBJECT_DEFAULT := 1

# --- §8.5 Run-scarce narrative budgets -------------------------------------

const BUDGETS := {
	"frank_aphorism": 2,
}

# --- §13.7 The calibration anchor ------------------------------------------
#
# NOT a tuning value — a MEASUREMENT TARGET. The harness reports against it; nothing branches
# on it. §13.7 is explicit that the anchor is an instrument, not a proof.

const ANCHOR_MINUTES_PER_DECISION := 2.5
const ANCHOR_MAX_INTERRUPTS_PER_3_MIN := 3

# --- §9.2 Fixed odds ---------------------------------------------------------
#
# A dice odds that does not come from the state is named here once and read through the
# `olay.odds_*` seams: a card never carries the figure (I7), and a retune changes this table.

const ODDS := {"odds_10": 0.10, "odds_15": 0.15, "odds_20": 0.20, "odds_25": 0.25}

# The live demo of an award: the odds fall with the product's open bugs, and a lost demo costs
# the brand more when the product was buggy.

const AWARD_LIVE_BASE := 0.25
const AWARD_LIVE_PER_BUG := 0.05
const AWARD_LIVE_BUG_CAP := 3
const AWARD_LIVE_FLOOR := 0.10
const AWARD_SLIP_CLEAN := 1
const AWARD_SLIP_BUGGY := -2

# --- Build scope -----------------------------------------------------------

## Which version_scope values ship in this build; EndingsSystem.shipped_scopes() owns the answer.
## A `static var` because the engine probe and smoke widen it to admit `fixture`, and
## EndingsSystem.build_scope_override re-derives it.
static var SHIPPED_SCOPES: Array = EndingsSystem.shipped_scopes()
