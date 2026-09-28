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

# --- Build scope -----------------------------------------------------------

## Which version_scope values ship in this build; EndingsSystem.shipped_scopes() owns the answer.
## A `static var` because the engine probe and smoke widen it to admit `fixture`, and
## EndingsSystem.build_scope_override re-derives it.
static var SHIPPED_SCOPES: Array = EndingsSystem.shipped_scopes()
