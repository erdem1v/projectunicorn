class_name EndingsSystem
extends RefCounted

# Endings Evaluator — daily tick slot 9 per docs/ENDGAME_DESIGN.md §3-4.
#
# Scans terminal conditions daily, reading GameState FIELDS only (§7.9:
# fields, not systems — the future VC pitch / scandal systems just write the
# fields and plug in with zero retrofit). Scan order = §7.1 priority chain:
# Bankruptcy > Brand Collapse > Cascade > Profitability condition > Soft cap.
#
# GOAL-TERMINATED RUN (Calibration Round A §2, 2026-08-19). The Day-180 wall and its
# time-out fork are gone: a run ends only on an ending — Series A, profitable and
# self-sustaining (§9, a CONDITION evaluated daily), bankruptcy — or at the SOFT CAP,
# a narrative non-win for a company that reached no goal inside the window investors
# give it (running_on_fumes, paper rewritten: "yatırımcılar ilgisini kaybetti").
#
# trigger_ending() is the single terminal seam for BOTH classes:
#   Class A (instant, played moment): acquisition accept, term sheet signed,
#   debug F-keys — call it directly, no daily-tick wait.
#   Class B (scanned): the daily scan calls it.
# It is idempotent (first terminal wins, §7.1), flushes the event queue (§7.2 —
# a queued Frank gate scene dies with the run) and freezes the clock (§7.3).

# Working values — §10 calibration items, numbers last.
const SHUTTER_DAYS := 30           # §4.3 Kepenk. 7 → 30 (director ruling, Frank v6 pass):
                                   # a month is real recovery room, a week is a formality.
                                   # The warning copy names no number, so it did not move.
const BRAND_COLLAPSE_FLOOR := 15   # §4.4
const BRAND_COLLAPSE_WINDOW := 30  # §4.4 "no recovery for 30 days"
const CASCADE_TABLES := 3          # §4.5 closed pitch tables
const PIVOT_MRR_MIN := 2000        # §4.5 "metrics are alive" floor
# SOFT CAP [WORKING] — Calibration Round A §2. Not a wall the economy is stretched across
# (that was RUN_END_DAY = 180, retired); the catch for a run that reached no goal ending in
# two years. 24 months is the smallest cap at which annual contracts (Layer B) are SEEN
# renewing. NOT deferred for a live term sheet: VC_PITCH_DESIGN ledger 16 rules no
# auto-sign, and an unsigned sheet is named on the paper. THE SOFT CAP HAS NO TELEGRAPH:
# the D-1 Frank warning was retired in the Frank v6 pass (that card became the last-day
# reminder for a live OFFER, which is a different moment). A "final stretch" surface is
# open work — docs/writing/FRANK_UNWIRED.md. Same day as a profitability close → the win
# wins (scan order).
const SOFT_CAP_DAY := 730
# PROFITABLE & SELF-SUSTAINING — a CONDITION evaluated daily (Calibration Round A §9), not a
# crossing read once at a wall. An "Artıda" month = net > 0 AND the treasury never sampled
# below zero inside it (GameState.month_history, closed by MonthSummarySystem). The run-lifetime
# cash_went_negative latch it replaces made the win permanently unreachable after one early
# Kepenk in a 24-month run. The MRR floor is DECOUPLED from SalesSystem.TRACTION_MRR_TARGET
# (it used to alias the Series A bar, which is now $40K+).
const PROFIT_STREAK_MONTHS := 6    # [WORKING] consecutive Artıda month-closes
const PROFIT_MIN_MARGIN_PCT := 15  # [WORKING] Σnet/Σincome over the window, percent
const BOOTSTRAP_WIN_MRR := 20_000  # [WORKING] scale floor at the moment the condition is met

# Ending metadata — 7 endings (§4). Only the TONE lives here now; the title and Frank's
# closing line are END_META_<ID>_TITLE / _FRANK in strings.csv, read through ending_title()
# and ending_frank_line(). A const cannot hold them: it is evaluated when the file loads,
# before a locale exists.
const ENDINGS := {
	"series_a_close": {
				"tone": "win",
	},
	"acquisition": {
				"tone": "soft_win",
	},
	"bankruptcy": {
				"tone": "loss",
	},
	"brand_collapse": {
				"tone": "loss",
	},
	"vc_rejection_cascade": {
				"tone": "loss",
	},
	"profitable_bootstrap": {
				"tone": "win",
	},
	"running_on_fumes": {
				"tone": "soft_loss",
	},
}


static func daily_tick() -> void:
	if not GameState.run_active:
		return
	_update_trackers()
	# Class A field backstop: the VC pitch flow (later) and debug F3 call
	# trigger_ending directly at the played moment; this catches a field set
	# through any other path (e.g. console/debug) no later than the next day.
	if GameState.series_a_closed:
		trigger_ending("series_a_close", TELEGRAPH_WIN)
		return
	if _tick_shutter():
		return
	if _check_brand_collapse():
		return
	if _check_vc_cascade():
		return
	if _check_profitable_bootstrap():
		return
	if _check_soft_cap():
		return
	_check_acquisition_offer()  # non-terminal; deliberately NOT shutter-gated (§7.5)


# --- Daily trackers (cheap, serializable) ---

static func _update_trackers() -> void:
	# (The 90-day daily-net ring that fed the retired Day-180 fork lived here; the §9
	# profitability condition reads GameState.month_history — the calendar-month ledger
	# MonthSummarySystem closes — instead.)
	# Brand-collapse window anchor: first day brand dipped under the floor;
	# any recovery to/above the floor resets the 30-day clock.
	if GameState.brand < BRAND_COLLAPSE_FLOOR:
		if GameState.brand_low_since_day < 0:
			GameState.brand_low_since_day = GameState.day
	else:
		GameState.brand_low_since_day = -1


# --- Bankruptcy + Kepenk (§4.3) ---

static func _tick_shutter() -> bool:
	if GameState.cash < 0:
		if GameState.shutter_days_left < 0:
			# Shutter starts: visible counter (TopBar via shutter_changed) +
			# Frank warning scene. A queued gate scene is held (§7.4).
			# Extension socket: a future loan / cash-injection mechanic resets
			# this by pushing cash ≥ 0 — no extra seam needed (DEFERRED BACKLOG).
			GameState.set_shutter_days_left(SHUTTER_DAYS)
			GameState.submit_month_highlight(TranslationServer.translate("END_HL_SHUTTER_STARTED"), 90)  # AYIN OLAYI (Spec 3 §4)
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
		# Cash recovered — full reset (§4.3), the held gate scene returns (§7.4).
		GameState.set_shutter_days_left(-1)
		PhaseGateSystem.on_shutter_cleared()
	return false


# --- Brand Collapse (§4.4) ---

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
	# No telegraph exists. The ending is debug-only anyway — its gate reads
	# GameState.active_scandal, which has no writer outside game_shell.gd:251 — and
	# GDD v2 ch.13 defers brand_collapse to Early Access. Filed, not invented.
	trigger_ending("brand_collapse", TELEGRAPH_NONE)
	return true


# --- VC Rejection Cascade + pivot escape hatch (§4.5) ---

static func _check_vc_cascade() -> bool:
	if GameState.vc_rejections < CASCADE_TABLES:
		return false
	# Ledger 17 (Spec 4): a player holding a live/pending sheet or an in-flight
	# meeting still holds a win path — cascade DEFERS until it resolves. Without
	# this, pivot could fire while victory is in hand.
	if not GameState.active_sheets.is_empty() or _any_pending_sheet() or not GameState.pending_meeting.is_empty():
		return false
	if GameState.pivot_used:
		# Erdem 2026-07-13: pivot closes the VC path permanently; the counter
		# stays at 3 but the cascade can never fire again. Only route left is
		# the Day-180 fork.
		return false
	if GameState.get_flag("pivot_offer_made", false):
		return false  # offer on the table — the player's choice resolves it
	if GameState.mrr >= PIVOT_MRR_MIN and GameState.cash > 0:
		# Metrics alive → Frank offers the hidden corridor. Played choice:
		# accept_pivot / decline_pivot modifiers resolve it (§4.5).
		# ENTRY POINT CLOSED (Frank v6): ev_pivot_offer and ev_acquisition_offer were merged
		# into ONE card, the buyout offer card, which is not built yet. The latch
		# still burns here so the cascade stays deferred exactly as it did while the offer sat
		# on the table - the run continues to another terminal instead of stalling.
		GameState.set_flag("pivot_offer_made", true)
		return false
	# HUNT_FRANK_LINE counts the closed tables on screen ("Kapanan masa: 2. Ucunculde
	# yol biter"), so the player is warned — but by a UI strip History cannot see.
	trigger_ending("vc_rejection_cascade", TELEGRAPH_UI_ONLY)
	return true


static func on_pivot_accepted() -> void:
	# Called via the "accept_pivot" event modifier.
	GameState.pivot_used = true
	# Ledger 18 (Spec 4): pivot closes the Hunt — cancel the pending meeting, kill
	# callbacks, remove a queued meeting prompt. Active sheets are impossible here
	# (ledger 17 defers cascade while any sheet lives), so none to clear.
	VCPitchSystem.on_pivot()
	if OS.is_debug_build():
		print("[EndingsSystem] Pivot accepted — VC path closed; the bootstrap road continues (goal: %d Artıda months)" % PROFIT_STREAK_MONTHS)


# Ledger 17 helper: any VC awaiting delayed sheet delivery counts as a live win path.
static func _any_pending_sheet() -> bool:
	for st in GameState.vc_states.values():
		if st is Dictionary and st.get("pending_sheet", false):
			return true
	return false


# --- Profitable & self-sustaining (Calibration Round A §9) ---

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
	}
	d["met"] = bool(d.streak_ok) and bool(d.margin_ok) and bool(d.mrr_ok) and bool(d.scandal_ok)
	return d


static func _check_profitable_bootstrap() -> bool:
	# A CONDITION evaluated daily, not a crossing. Sits after the cascade (a pivot offer does
	# not block the win — flush_queue drops the offer) and before the soft cap (same-day tie →
	# the win wins).
	if not bool(profitability_signal().get("met", false)):
		return false
	trigger_ending("profitable_bootstrap", TELEGRAPH_WIN)
	return true


# --- Soft cap (Calibration Round A §2; replaces the Day-180 time-out fork) ---

static func _check_soft_cap() -> bool:
	# The window investors give a company closed without a goal ending. Not deferred for a
	# live sheet or a pending meeting (ledger 16: no auto-sign; the D-1 warning told the
	# player). The ledger carries `unsigned_sheets` so the paper can name what was left on
	# the table.
	if GameState.day < SOFT_CAP_DAY:
		return false
	# THE DEFECT §6.8 NAMES. A run can reach day 730 with no prior warning at all. The
	# soft-cap ladder being built for this rebuild sets this flag; until it lands, this
	# line logs an untelegraphed loss on every soft-cap ending, which is the point.
	trigger_ending("running_on_fumes", "soft_cap_telegraphed")
	return true


# --- Acquisition offer (§4.2 — non-terminal; accept is the Class A win) ---

static func _check_acquisition_offer() -> void:
	if GameState.get_flag("acquisition_offer_made", false):
		return
	if GameState.phase != 3:
		return
	if GameState.brand < 30 or GameState.brand > 50:
		return  # "struggling but not failing" band
	if GameState.vc_rejections < 1:
		return
	# ENTRY POINT CLOSED (Frank v6): there is no buyout offer card. The "acquisition" ending
	# is UNTOUCHED and still fires from accept_acquisition; only this door is shut, so the
	# highlight is withheld too (there is no offer to announce).
	GameState.set_flag("acquisition_offer_made", true)


# --- Single terminal seam (§3, §7.1-7.3) ---

## Telegraph sentinels. Both are DELIBERATE declarations, not escape hatches: naming one is a
## statement about the ending, and the linter and the run log can both read it.
const TELEGRAPH_WIN := "win"              ## a victory needs no warning
const TELEGRAPH_NONE := "none"            ## no telegraph designed yet — filed, not hidden
const TELEGRAPH_UI_ONLY := "ui_strip"     ## a telegraph that exists on screen but not in History


## THE SINGLE TERMINAL SEAM — and, since 2026-08-25, the place I3 is enforced.
##
## `telegraph` HAS NO DEFAULT, on purpose. §0.3's I3 says "no untelegraphed loss", and the
## event engine can only guard the two call sites that are its own effects — this function has
## TEN callers and eight of them never touch the engine. Guarding the executor would have
## covered 2 of 10. Putting the argument here made every call site a compile error until
## somebody decided what warns the player, which is the decision I3 is actually about.
##
## It ASSERTS rather than REFUSES. §0.3 asks for "lint + runtime assert", and §8.4's refusal
## applies to the engine's own effects (EvEffects._permitted does refuse). Blocking here would
## strand a player mid-run over a content gap, which is a worse outcome than the gap.
static func trigger_ending(ending_id: String, telegraph: String,
		extra: Dictionary = {}) -> void:
	if not GameState.run_active:
		return  # idempotent — first terminal wins (§7.1)
	if not ENDINGS.has(ending_id):
		push_warning("[EndingsSystem] Unknown ending id: %s" % ending_id)
		return
	_assert_telegraph(ending_id, telegraph)
	GameState.set_run_active(false)
	GameState.ending_id = ending_id
	EventGate.flush()  # §7.2 — pending scenes (incl. Frank gate) die
	if OS.is_debug_build():
		print("[EndingsSystem] RUN ENDED: %s (Day %d)" % [ending_id, GameState.day])
	EventBus.run_ended.emit(ending_id, _build_ending_data(ending_id, extra))
	EventBus.speed_change_requested.emit(0)  # §7.3 — freeze clock, pause tree


## I3's runtime half. Loud, never blocking — see trigger_ending's note.
static func _assert_telegraph(ending_id: String, telegraph: String) -> void:
	var meta: Dictionary = ENDINGS.get(ending_id, {})
	var is_loss: bool = String(meta.get("tone", "")) in ["loss", "soft_loss"]
	if not is_loss:
		return                                  # a win needs no warning
	match telegraph:
		TELEGRAPH_WIN:
			push_error("[EndingsSystem] I3: '%s' is a loss and was declared a win" % ending_id)
		TELEGRAPH_NONE:
			push_error("[EndingsSystem] I3: '%s' ended the run with NO TELEGRAPH. "
				% ending_id + "Filed, not fixed — see docs/EVENT_ENGINE_QUESTIONS.md")
		TELEGRAPH_UI_ONLY:
			pass                                # on screen, invisible to History; accepted
		_:
			if not EvHistory.telegraph_fired(telegraph):
				push_error("[EndingsSystem] I3: '%s' fired but its telegraph '%s' never did"
					% [ending_id, telegraph])


static func _build_ending_data(ending_id: String, extra: Dictionary) -> Dictionary:
	# Live snapshot — safe because trigger_ending halts the world in the same
	# frame (§7.3: no MRR accrues behind the ending screen, so these numbers
	# cannot contradict the screen).
	var meta: Dictionary = ENDINGS[ending_id]
	var data := {
		"ending_id": ending_id,
		"title": ending_title(ending_id),
		"tone": meta.tone,
		"frank_line": ending_frank_line(ending_id),
		"day": GameState.day,
		"cash": GameState.cash,
		"mrr": GameState.mrr,
		"brand": GameState.brand,
		"reputation": GameState.reputation,
		"phase": GameState.phase,
		"customers": CustomerRegistry.get_active().size(),
		"employees": CharacterRegistry.get_employees().size(),
		"company_name": GameState.company_name,
		"founder_name": GameState.founder_name,
	}
	data.merge(extra, true)
	return data


# --- Synthetic scenes (ship-moment pattern; EventModal renders them) ---


## Ending title ("Series A Kapandı" / "Series A Closed"). The table holds tone only.
static func ending_title(ending_id: String) -> String:
	return TranslationServer.translate("END_META_%s_TITLE" % ending_id.to_upper())


## Frank's closing line for an ending.
static func ending_frank_line(ending_id: String) -> String:
	return TranslationServer.translate("END_META_%s_FRANK" % ending_id.to_upper())
