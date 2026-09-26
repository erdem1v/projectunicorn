class_name EndingsSystem
extends RefCounted

# Endings Evaluator — daily tick slot 9.
#
# Scans terminal conditions daily, reading GameState FIELDS only (fields, not systems: a
# system plugs in by writing its field with zero retrofit; the reserved active_scandal
# waits on a scandal system). Scan order = priority chain:
# Series A backstop > Bankruptcy > Brand Collapse > Cascade > Profitability condition >
# Soft cap.
#
# GOAL-TERMINATED RUN: a run ends only on an ending — Series A, profitable and
# self-sustaining (a CONDITION evaluated daily), bankruptcy — or at the SOFT CAP,
# a narrative non-win for a company that reached no goal inside the window investors
# give it (running_on_fumes: "yatırımcılar ilgisini kaybetti").
#
# trigger_ending() is the single terminal seam for BOTH classes:
#   Class A (instant, played moment): acquisition accept, term sheet signed,
#   debug F-keys — call it directly, no daily-tick wait.
#   Class B (scanned): the daily scan calls it.
# It is idempotent (first terminal wins), flushes the event queue (a queued
# Frank gate scene dies with the run) and freezes the clock.

# Working values — calibration items, numbers last.
const SHUTTER_DAYS := 30           # Kepenk (director ruling): a month is real recovery room,
                                   # a week is a formality. The warning copy names no number.
const BRAND_COLLAPSE_FLOOR := 15
const BRAND_COLLAPSE_WINDOW := 30  # "no recovery for 30 days"
const CASCADE_TABLES := 3          # closed pitch tables
const PIVOT_MRR_MIN := 2000        # "metrics are alive" floor
# SOFT CAP [WORKING]. Not a wall the economy is stretched across; the catch for a run that
# reached no goal ending in two years. 24 months is the smallest cap at which annual
# contracts are SEEN renewing. NOT deferred for a live term sheet: there is no auto-sign,
# and an unsigned sheet is named on the paper. Its telegraph is the final-stretch ladder
# (world.final_stretch_* cards, arc_final_stretch, ending on Frank's D-1 verdict), which
# stamps `soft_cap_telegraphed`. Same day as a profitability close → the win wins (scan order).
const SOFT_CAP_DAY := 730
# PROFITABLE & SELF-SUSTAINING — a CONDITION evaluated daily. An "Artıda" month = net > 0
# AND the treasury never sampled below zero inside it (GameState.month_history, closed by
# MonthSummarySystem), so one early Kepenk does not bar the win for the rest of the run.
# The MRR floor is its own number, not SalesSystem.TRACTION_MRR_TARGET (the Series A bar).
const PROFIT_STREAK_MONTHS := 6    # [WORKING] consecutive Artıda month-closes
const PROFIT_MIN_MARGIN_PCT := 15  # [WORKING] Σnet/Σincome over the window, percent
const BOOTSTRAP_WIN_MRR := 20_000  # [WORKING] scale floor at the moment the condition is met

# --- The buyout offer (Frank v6 surfaces 17 + 18) ---
# The only company valuation that exists outside a term-sheet sitting. Written as ARR x a
# multiple because that is how a small software acquisition is actually priced, and because
# every input is a figure the player has been watching all run.
const ACQ_BASE_MULTIPLE := 2.5
# Growth adjustment, keyed on the rolling 3-month MoM average — the SAME read the seed
# expectation and the Series A term sheet use. One answer to "is this company growing",
# three consumers; three separate readings would have drifted apart by the second retune.
const ACQ_GROWTH_CUTS := [0, 5, 12]              # percent, ascending
const ACQ_GROWTH_ADJ := [0.7, 1.0, 1.2, 1.5]     # under 0 / 0-5 / 5-12 / over 12
# Brand adjustment: a buyer pays for a name people already know.
const ACQ_BRAND_CUTS := [30, 50, 70]
const ACQ_BRAND_ADJ := [0.9, 1.0, 1.1, 1.2]
const ACQ_M_MIN := 1.5
const ACQ_M_MAX := 5.0
# How long the buyer can still turn up after the road closes. Without an upper bound the
# card condition stays true for the rest of the run and the phone rings on some unrelated
# day a year later. [ÇALIŞMA]
const ACQ_CARD_WINDOW_DAYS := 10

# The 7 endings, each id mapped to its tone. The title and Frank's closing line are
# END_META_<ID>_TITLE / _FRANK in strings.csv, read through ending_title() and
# ending_frank_line(). A const cannot hold them: it is evaluated when the file loads,
# before a locale exists.
const ENDINGS := {
	"series_a_close": "win",
	"acquisition": "soft_win",
	"bankruptcy": "loss",
	"brand_collapse": "loss",
	"vc_rejection_cascade": "loss",
	"profitable_bootstrap": "win",
	"running_on_fumes": "soft_loss",
}


static func daily_tick() -> void:
	if not GameState.run_active:
		return
	_update_trackers()
	# Class A field backstop: VCPitchSystem.sign_table and debug F3 call
	# trigger_ending directly at the played moment; this catches a field set
	# through any other path (e.g. console/debug) no later than the next day.
	if GameState.series_a_closed:
		trigger_ending("series_a_close", TELEGRAPH_WIN)
		return
	if _tick_shutter() or _check_brand_collapse() or _check_vc_cascade() \
			or _check_profitable_bootstrap() or _check_soft_cap():
		return
	_tick_acquisition_window()  # one day stamp; the card decides, not this scan


# --- Daily trackers (cheap, serializable) ---

static func _update_trackers() -> void:
	# Brand-collapse window anchor: first day brand dipped under the floor;
	# any recovery to/above the floor resets the 30-day clock.
	if GameState.brand < BRAND_COLLAPSE_FLOOR:
		if GameState.brand_low_since_day < 0:
			GameState.brand_low_since_day = GameState.day
	else:
		GameState.brand_low_since_day = -1


# --- Bankruptcy + Kepenk ---

static func _tick_shutter() -> bool:
	if GameState.cash < 0:
		if GameState.shutter_days_left < 0:
			# Shutter starts: visible counter (TopBar via shutter_changed) +
			# Frank warning scene. A queued gate scene is held.
			GameState.set_shutter_days_left(SHUTTER_DAYS)
			GameState.submit_month_highlight(TranslationServer.translate("END_HL_SHUTTER_STARTED"), 90)  # AYIN OLAYI
			PhaseGateSystem.on_shutter_started()
			# Nothing is pushed. `funding.shutter_warning` reads
			# `finance.cash < 0 AND finance.shutter_days_left >= 0` — the two facts the two
			# lines above have just written — and is tagged `critical`, so the daily sweep
			# admits it on the same day the counter appears.
		else:
			GameState.set_shutter_days_left(GameState.shutter_days_left - 1)
			if GameState.shutter_days_left <= 0:
				# The shutter card is the telegraph: 30 days of visible countdown.
				trigger_ending("bankruptcy", "funding.shutter_warning")
				return true
	elif GameState.shutter_days_left >= 0:
		# Cash recovered — full reset, the held gate scene returns.
		GameState.set_shutter_days_left(-1)
	return false


# --- Brand Collapse ---

static func _check_brand_collapse() -> bool:
	# active_scandal is a RESERVED field (no scandal system yet) — until it
	# ships, this ending is reachable only via debug. Deliberate per canon.
	if GameState.brand >= BRAND_COLLAPSE_FLOOR:
		return false
	if GameState.brand_low_since_day < 0:
		return false
	if GameState.day - GameState.brand_low_since_day < BRAND_COLLAPSE_WINDOW:
		return false
	if not GameState.active_scandal:
		return false
	# No telegraph exists: the ending is debug-only (see above) and GDD v2 ch.13 defers
	# brand_collapse to Early Access. Filed, not invented.
	trigger_ending("brand_collapse", TELEGRAPH_NONE)
	return true


# --- VC Rejection Cascade + pivot escape hatch ---

static func _check_vc_cascade() -> bool:
	if GameState.vc_rejections < CASCADE_TABLES:
		return false
	# A player holding a live/pending sheet or an in-flight
	# meeting still holds a win path — cascade DEFERS until it resolves. Without
	# this, pivot could fire while victory is in hand.
	if not GameState.active_sheets.is_empty() or _any_pending_sheet() or not GameState.pending_meeting.is_empty():
		return false
	if GameState.pivot_used:
		# Owner ruling: pivot closes the VC path permanently; the counter stays at 3 but
		# the cascade can never fire again.
		return false
	if GameState.get_flag("pivot_offer_made", false):
		return false  # metrics were alive once; the cascade stays deferred
	if GameState.mrr >= PIVOT_MRR_MIN and GameState.cash > 0:
		# Metrics alive → no cascade. The latch burns so the cascade stays deferred for
		# the rest of the run, which continues to another terminal instead of stalling.
		GameState.set_flag("pivot_offer_made", true)
		return false
	# HUNT_FRANK_LINE counts the closed tables on screen ("Kapanan masa: 2. Üçüncüde
	# yol biter."), so the player is warned — but by a UI strip History cannot see.
	trigger_ending("vc_rejection_cascade", TELEGRAPH_UI_ONLY)
	return true


static func on_pivot_accepted() -> void:
	# Called by on_buyout_declined (the buyout card's `decline_buyout` verb).
	GameState.pivot_used = true
	# Pivot closes the Hunt — cancel the pending meeting, kill
	# callbacks, remove a queued meeting prompt. Active sheets are impossible here
	# (the buyout card is gated on road_over(), which needs no live sheet), so none to clear.
	VCPitchSystem.on_pivot()
	if OS.is_debug_build():
		print("[EndingsSystem] Pivot accepted — VC path closed; the bootstrap road continues (goal: %d Artıda months)" % PROFIT_STREAK_MONTHS)


# Cascade-deferral helper: any VC awaiting delayed sheet delivery counts as a live win path.
static func _any_pending_sheet() -> bool:
	for st in GameState.vc_states.values():
		if st is Dictionary and st.get("pending_sheet", false):
			return true
	return false


# --- Profitable & self-sustaining ---

## Single home for the condition's reading: the Finance tab's "Artıda · n/6 ay" line and the
## daily scan both read this. `met` is the predicate.
static func profitability_signal() -> Dictionary:
	var streak: int = GameState.get_profitable_month_streak()
	var margin: int = GameState.get_window_margin_pct(PROFIT_STREAK_MONTHS)
	var d := {
		"streak": streak, "need": PROFIT_STREAK_MONTHS, "streak_ok": streak >= PROFIT_STREAK_MONTHS,
		"margin_pct": margin, "margin_ok": margin >= PROFIT_MIN_MARGIN_PCT,
		"mrr_ok": GameState.mrr >= BOOTSTRAP_WIN_MRR,
		"scandal_ok": not GameState.unmanaged_major_scandal,
		# THE FIFTH CLAUSE (ch. 13 §1). "Profitability alone is not an ending;
		# refusing the round and staying profitable is." Without it this predicate could win a
		# run in BOOTSTRAP, to a player who never opened the funding page — the ending read as
		# an accident rather than as a refusal. Not a phase check: a player who walks into
		# Series A Hunt and never opens the page would win the same accident one phase later.
		"faced_ok": GameState.faced_series_a,
	}
	d["met"] = d.streak_ok and d.margin_ok and d.mrr_ok and d.scandal_ok and d.faced_ok
	return d


static func _check_profitable_bootstrap() -> bool:
	# A CONDITION evaluated daily, not a crossing. Sits after the cascade and before the soft
	# cap (same-day tie → the win wins).
	# In EA / full builds the win is a MILESTONE: the paper opens once and the run goes on, so
	# once the latch is written the condition is not read again (it would stay true every day).
	if bootstrap_milestone_taken():
		return false
	if not profitability_signal().met:
		return false
	if ending_mode("profitable_bootstrap") == MODE_MILESTONE:
		trigger_milestone("profitable_bootstrap")
		return true
	trigger_ending("profitable_bootstrap", TELEGRAPH_WIN)
	return true


# --- Soft cap ---

static func _check_soft_cap() -> bool:
	# The window investors give a company closed without a goal ending. Not deferred for a
	# live sheet or a pending meeting (no auto-sign; the D-1 warning told the
	# player). The ledger carries `unsigned_sheets` so the paper can name what was left on
	# the table.
	if GameState.day < SOFT_CAP_DAY:
		return false
	# A run that has taken a positive milestone is past "reached no goal inside the window":
	# the cap does not apply to it (owner ruling — running_on_fumes says
	# "you didn't win", and this company did). It still ends on a loss, a signed Series A or a
	# sale; the player can also leave through ANA MENÜ with the run saved.
	if bootstrap_milestone_taken():
		return false
	# The final-stretch cards (arc_final_stretch) stamp this telegraph.
	trigger_ending("running_on_fumes", "soft_cap_telegraphed")
	return true


# --- The buyout offer (Frank v6 surfaces 17 + 18) ---

## The multiple a buyer would pay: a base, adjusted for growth and brand, clamped.
static func acquisition_multiple() -> float:
	var m: float = ACQ_BASE_MULTIPLE
	m *= float(ACQ_GROWTH_ADJ[_band_index(
		GameState.get_mom_growth_avg_pct(PitchConstants.ARR_WINDOW_MONTHS), ACQ_GROWTH_CUTS)])
	m *= float(ACQ_BRAND_ADJ[_band_index(GameState.brand, ACQ_BRAND_CUTS)])
	return clampf(m, ACQ_M_MIN, ACQ_M_MAX)


## What the buyer values the whole company at: ARR x the multiple.
static func acquisition_valuation() -> int:
	return int(round(float(GameState.mrr) * 12.0 * acquisition_multiple()))


## What lands in the founder's hands. THE SEALED CARD DECIDES THIS MAPPING, not preference:
## the shipped line reads "At a {valuation} valuation, your share comes to {offer}", so
## {valuation} is the company and {offer} is the founder's slice of it. Any other pairing
## makes a sentence that is already in both locales false.
static func acquisition_founder_share() -> int:
	var founder_pct: int = maxi(0, 100 - GameState.get_investor_equity_pct())
	return int(round(float(acquisition_valuation()) * float(founder_pct) / 100.0))


## Index of `value` in an ascending cut list: 0 below the first cut, len(cuts) above the last.
## GROWTH_AVG_UNKNOWN sorts below every cut, which lands an unreadable history on the
## pessimistic adjustment — the honest default, since a buyer with no growth to read does
## not pay for one.
static func _band_index(value: int, cuts: Array) -> int:
	var i: int = 0
	while i < cuts.size() and value >= int(cuts[i]):
		i += 1
	return i


## True when the player FACED the Series A decision by declining or walking, AND there is
## nothing left to walk to.
##
## THE SECOND HALF IS NOT DECORATION. The card's sealed first sentence is "Series A turu
## kapandı, ortada anlaşma yok". Fired on the first walk with three funds still open, that
## sentence is simply false — and its refusal option closes the VC road for good, so one
## walked table would have resolved a run that still had three doors in it.
##
## Deliberately NOT reachable from the cascade or the soft cap: those are their own endings,
## and the ruling names decline-or-walk specifically.
static func road_over() -> bool:
	if not GameState.faced_series_a:
		return false
	if not (GameState.faced_series_a_by in ["declined", "walked"]):
		return false
	if not GameState.active_sheets.is_empty() or not GameState.pending_meeting.is_empty():
		return false
	for inv in InvestorRegistry.get_active():
		var st: Dictionary = GameState.vc_states.get(String(inv.id), {})
		if bool(st.get("pending_sheet", false)):
			return false
		if String(st.get("status", "open")) in ["open", "callback"]:
			return false
	return true


## Days since the road closed, or -1 while it has not.
static func acq_days_open() -> int:
	if GameState.acq_road_over_day < 0:
		return -1
	return GameState.day - GameState.acq_road_over_day


## One day stamp, and nothing pushed — the card's own condition reads it, the same grammar
## the phase gates and the seed door use.
static func _tick_acquisition_window() -> void:
	if GameState.acq_road_over_day >= 0 or not road_over():
		return
	GameState.acq_road_over_day = GameState.day
	if OS.is_debug_build():
		print("[EndingsSystem] Series A road closed by '%s' (day %d) — buyout window open"
			% [GameState.faced_series_a_by, GameState.day])


## "Kendi paramla devam" — the refusal, and BOTH of its consequences.
##
## The second one is the beat FRANK_UNWIRED §3 says must survive the wiring: refusing to
## sell is remembered, and a later VC meeting asks about it. Dropping it silently deletes a
## question from the game.
static func on_buyout_declined() -> void:
	on_pivot_accepted()                                     # the VC road closes; bootstrap continues
	GameState.set_flag("acquisition_offer_rejected", true)  # the memory thrown back later


# --- Build scope and ending modes (owner rulings) ---
#
# One newspaper, two modes. In the DEMO every ending ends the run.
# In EA and FULL builds a loss still ends the run, but a win the company lives through is a
# MILESTONE: the paper opens, "Devam et" closes it and the run goes on. Today that is the
# profitable bootstrap. A signed Series A stays an ending in every build until Act 3
# ("Perde 3") is playable — turning it into a milestone also needs sign_table and the daily
# series_a_closed backstop routed through trigger_milestone, which is deliberately not built
# yet. A sale (acquisition) ends the run: the company is no longer the player's.

const BUILD_DEMO := "demo"
const BUILD_EA := "ea"
const BUILD_FULL := "full"
const MODE_ENDING := "ending"
const MODE_MILESTONE := "milestone"

## Tests and debug shots set this to pin a build; "" reads the real one.
static var build_scope_override: String = ""


## Which build this is. An EA or full export names itself with a custom feature tag
## ("ea" / "full") in its export preset; anything untagged — the demo export, the editor,
## every headless run — is the demo. A debug build also takes --build=<demo|ea|full>, from
## the command line or Project Settings → Application → Run → Main Run Args, so the EA flow
## can be played from the editor. The smoke suite and the run probe pin the demo through
## build_scope_override, so a --build= left in Main Run Args does not change what they measure.
static func build_scope() -> String:
	if build_scope_override != "":
		return build_scope_override
	if OS.has_feature(BUILD_FULL):
		return BUILD_FULL
	if OS.has_feature(BUILD_EA):
		return BUILD_EA
	if OS.is_debug_build():
		var args: Array = Array(OS.get_cmdline_args())
		args.append_array(Array(String(ProjectSettings.get_setting("application/run/main_args", "")).split(" ", false)))
		for a in args:
			var s: String = String(a)
			if s.begins_with("--build="):
				var v: String = s.trim_prefix("--build=")
				if v in [BUILD_DEMO, BUILD_EA, BUILD_FULL]:
					return v
	return BUILD_DEMO


## True once this run has taken the bootstrap milestone AND this build treats it as one. The
## build half matters: a milestone save opened in the demo (a debug relaunch drops --build=,
## or a save moves between installs) must end on the win and the cap like any demo run,
## rather than sit latched with no ending left to reach. The daily scan's two short-circuits
## and the phase.bootstrap_milestone seam all read this one answer.
static func bootstrap_milestone_taken() -> bool:
	return GameState.bootstrap_milestone_day >= 0 and ending_mode("profitable_bootstrap") == MODE_MILESTONE


## "ending" or "milestone" for this ending in this build (see the block comment above).
static func ending_mode(ending_id: String) -> String:
	if build_scope() != BUILD_DEMO and ending_id == "profitable_bootstrap":
		return MODE_MILESTONE
	return MODE_ENDING


## THE MILESTONE SEAM — the non-terminal sibling of trigger_ending. The paper opens and the
## run CONTINUES, so it leaves run_active, ending_id and the event queue alone (the queue is
## the rest of the run) and only asks for the clock to stop while the paper is up; main.gd
## holds it until "Devam et". Once per run per milestone: the latch is written here, and the
## daily scan never re-reads a condition whose latch is set.
static func trigger_milestone(milestone_id: String) -> void:
	if not GameState.run_active:
		return
	match milestone_id:
		"profitable_bootstrap":
			if GameState.bootstrap_milestone_day >= 0:
				return
			GameState.bootstrap_milestone_day = GameState.day
		_:
			push_warning("[EndingsSystem] Unknown milestone id: %s" % milestone_id)
			return
	var data: Dictionary = _build_ending_data(milestone_id, {})
	data["mode"] = MODE_MILESTONE
	if OS.is_debug_build():
		print("[EndingsSystem] MILESTONE: %s (Day %d) — the run continues" % [milestone_id, GameState.day])
	EventBus.milestone_reached.emit(milestone_id, data)
	EventBus.speed_change_requested.emit(0)


# --- Single terminal seam ---

## Telegraph sentinels. Both are DELIBERATE declarations, not escape hatches: naming one is a
## statement about the ending, and the linter and the run log can both read it.
const TELEGRAPH_WIN := "win"              ## a victory needs no warning
const TELEGRAPH_NONE := "none"            ## no telegraph designed yet — filed, not hidden
const TELEGRAPH_UI_ONLY := "ui_strip"     ## a telegraph that exists on screen but not in History


## THE SINGLE TERMINAL SEAM, and the place I3 is enforced.
##
## `telegraph` HAS NO DEFAULT, on purpose. §0.3's I3 says "no untelegraphed loss", and the
## event engine can only guard its own trigger_ending effect; most callers never touch the
## engine. With no default, every call site has to name what warns the player, which is the
## decision I3 is actually about.
##
## It ASSERTS rather than REFUSES. §0.3 asks for "lint + runtime assert", and §8.4's refusal
## applies to the engine's own effects (EvEffects._permitted does refuse). Blocking here would
## strand a player mid-run over a content gap, which is a worse outcome than the gap.
static func trigger_ending(ending_id: String, telegraph: String,
		extra: Dictionary = {}) -> void:
	if not GameState.run_active:
		return  # idempotent — first terminal wins
	if not ENDINGS.has(ending_id):
		push_warning("[EndingsSystem] Unknown ending id: %s" % ending_id)
		return
	_assert_telegraph(ending_id, telegraph)
	GameState.set_run_active(false)
	GameState.ending_id = ending_id
	EventGate.flush()  # pending scenes (incl. Frank gate) die
	if OS.is_debug_build():
		print("[EndingsSystem] RUN ENDED: %s (Day %d)" % [ending_id, GameState.day])
	EventBus.run_ended.emit(ending_id, _build_ending_data(ending_id, extra))
	EventBus.speed_change_requested.emit(0)  # freeze clock, pause tree


## I3's runtime half. Loud, never blocking — see trigger_ending's note.
static func _assert_telegraph(ending_id: String, telegraph: String) -> void:
	var is_loss: bool = String(ENDINGS.get(ending_id, "")) in ["loss", "soft_loss"]
	if not is_loss:
		return                                  # a win needs no warning
	match telegraph:
		TELEGRAPH_WIN:
			push_error("[EndingsSystem] I3: '%s' is a loss and was declared a win" % ending_id)
		TELEGRAPH_NONE:
			push_error("[EndingsSystem] I3: '%s' ended the run with NO TELEGRAPH. "
				% ending_id + "Filed, not fixed.")
		TELEGRAPH_UI_ONLY:
			pass                                # on screen, invisible to History; accepted
		_:
			if not EvHistory.telegraph_fired(telegraph):
				push_error("[EndingsSystem] I3: '%s' fired but its telegraph '%s' never did"
					% [ending_id, telegraph])


static func _build_ending_data(ending_id: String, extra: Dictionary) -> Dictionary:
	var data := {
		"ending_id": ending_id,
		"title": ending_title(ending_id),
		"tone": ENDINGS[ending_id],
		"frank_line": ending_frank_line(ending_id),
		"company_name": GameState.company_name,
	}
	data.merge(extra, true)
	return data


## Ending title ("Series A Kapandı" / "Series A Closed"). The table holds tone only.
static func ending_title(ending_id: String) -> String:
	return TranslationServer.translate("END_META_%s_TITLE" % ending_id.to_upper())


## Frank's closing line for an ending.
static func ending_frank_line(ending_id: String) -> String:
	return TranslationServer.translate("END_META_%s_FRANK" % ending_id.to_upper())
