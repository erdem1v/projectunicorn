class_name AngelRoundSystem
extends RefCounted

# Frank's angel round — the early-game economy bridge (canon, July 2026).
#
# Frank is an angel, not a fund. His cheque arrives once, after a played MVP and real
# revenue, with no term-sheet ceremony: one warm-dry Frank scene, one decision. Taking it
# costs 4% of the company. Refusing it is the hard path, and the hard path is not built
# yet — so that choice ships VISIBLE AND LOCKED rather than hidden, which is the game's
# standing grammar for a door the player can see but not open.
#
# WHY A SYSTEM AND NOT A JSON EVENT. Three things the event pool cannot express:
#   1. A one-shot latch that survives the enqueue path. Synthetic events skip
#      _is_eligible entirely (event_manager.gd:198-212), so GameEvent.one_shot is dead
#      code for anything injected — the latch has to be a GameState flag.
#   2. An ATOMIC cash + cap-table write. Two JSON modifiers are two writes the dispatcher
#      applies in a loop; a half-applied round becomes representable the day someone
#      reorders the array.
#   3. An honestly-unreachable lock condition (the JSON vocabulary has no flag_unset, and
#      inventing a fake threshold that could accidentally come true is worse than none).
#
# WHY IT IS STATELESS. PhaseGateSystem caches its event instance because gate reminders
# must re-surface the SAME object. This scene fires once and is never re-prompted, so it
# is built inline and released: nothing to register in SaveManager.reset_all_owners(),
# nothing to restore. The only persistent state is the two GameState flags.

const EVENT_ID := "ev_angel_frank_seed"

# WORKING (director, 2026-08-17). The bar was ruled down from 5,000 after the collision
# was measured: at 5,000 this scene and the Traction→Series A gate share one MRR bar
# (phase_gate_system.gd reads SalesSystem.TRACTION_MRR_TARGET - 1), so the angel round and
# the Series A door opened on the same day — and $25,000 against a 5,000-MRR company is no
# bridge at all. Deliberately NOT wired to TRACTION_MRR_TARGET: this is a different bar
# with a different job, and sharing the constant would silently re-create the collision.
const MRR_THRESHOLD := 2500
const CASH_AMOUNT := 25_000
const EQUITY_PCT := 4
const TX_LABEL := "angel_seed"                 # raw id; display via FinanceSystem.ONE_TIME_LABELS
const FLAG_OFFERED := "angel_seed_offered"
const FLAG_ACCEPTED_DAY := "angel_seed_accepted_day"
const HARD_MODE_FLAG := "hard_mode_unlocked"

# The hire nudge: Frank, a day or two after the money lands, on the subject of being one
# person. Flavour and a signpost — it forces nothing, and the HR rail badge that rides with
# it (HRSystem.attention_count) clears itself the moment anyone is hired.
const NUDGE_EVENT_ID := "ev_angel_hire_nudge"
const NUDGE_DELAY_DAYS := 2
const FLAG_NUDGE_SHOWN := "angel_nudge_shown"

# Same shape as PhaseGateSystem.GATES.conditions, evaluated through the ONE condition
# vocabulary (EventManager.is_condition_met) rather than re-typed as bespoke ifs here.
# mrr_above is a strict ">", so MRR_THRESHOLD - 1 means "MRR ≥ 2500" and 2499 never fires.
const TRIGGER_CONDITIONS := [
	{"type": "mvp_shipped", "value": true},
	{"type": "mrr_above", "value": MRR_THRESHOLD - 1},
]


# --- TimeManager slot 8a (before the phase gate — see _tick_angel_round there) ---

static func daily_tick() -> void:
	if not GameState.run_active:
		return   # nothing new mounts after a terminal (ENDGAME_DESIGN §7.3)
	if bool(GameState.get_flag(FLAG_OFFERED, false)):
		_tick_hire_nudge()
		return   # THE LATCH
	for c in TRIGGER_CONDITIONS:
		if not EventManager.is_condition_met(c):
			return
	_open_offer()


static func _tick_hire_nudge() -> void:
	# Fires once, NUDGE_DELAY_DAYS after the money landed, and only if the founder is still
	# working alone — a line about hiring is noise to someone who already has a team.
	# Its own flag latch, for the same reason the offer has one: injected events never see
	# _is_eligible, so one_shot cannot carry this.
	if bool(GameState.get_flag(FLAG_NUDGE_SHOWN, false)):
		return
	var accepted_day: int = int(GameState.get_flag(FLAG_ACCEPTED_DAY, 0))
	if accepted_day <= 0:
		return   # the offer was raised but not taken (or is still on screen)
	if GameState.day < accepted_day + NUDGE_DELAY_DAYS:
		return
	if not CharacterRegistry.get_employees().is_empty():
		GameState.set_flag(FLAG_NUDGE_SHOWN, true)   # already hired — spend the shot silently
		return
	GameState.set_flag(FLAG_NUDGE_SHOWN, true)
	EventManager.enqueue(build_nudge_event())


static func build_nudge_event() -> GameEvent:
	var ev := GameEvent.new()
	ev.id = NUDGE_EVENT_ID
	ev.category = "reactive"
	ev.character_id = "char_mentor_frank"
	ev.title = TranslationServer.translate("ANGEL_NUDGE_TITLE")
	ev.body_text = TranslationServer.translate("ANGEL_NUDGE_BODY")
	ev.subtitle = ""
	ev.mentor_choice = -1
	ev.priority = 3          # below the gate/seed beats: it is advice, not a decision
	ev.tags = ["build_safe", "angel_round"]
	var ack := EventChoice.new()
	ack.label = TranslationServer.translate("ANGEL_NUDGE_ACK")
	ack.modifiers = []       # advisory: no economic delta, and the modal shows no chip
	var choices: Array[EventChoice] = []
	choices.append(ack)
	ev.choices = choices
	return ev


static func _open_offer() -> void:
	# Latch BEFORE the enqueue (PhaseGateSystem._open_gate precedent): an enqueue that
	# no-ops against the queue dedupe must still burn the one shot, or the offer re-opens
	# tomorrow and every tomorrow after it.
	GameState.set_flag(FLAG_OFFERED, true)
	if OS.is_debug_build():
		print("[AngelRoundSystem] Frank seed offered at MRR $%d (day %d)" % [GameState.mrr, GameState.day])
	EventManager.enqueue_front(build_offer_event())


static func build_offer_event() -> GameEvent:
	# Public so the screenshot/smoke harnesses can render the card without tripping the latch.
	# Static context ⇒ tr() is unavailable (it is a Node method); TranslationServer.translate
	# is the documented statics path (ui_tokens.gd, hr_system.gd do the same).
	var ev := GameEvent.new()
	ev.id = EVENT_ID
	ev.category = "reactive"
	ev.character_id = "char_mentor_frank"
	ev.title = TranslationServer.translate("ANGEL_EVENT_TITLE")
	ev.body_text = TranslationServer.translate("ANGEL_EVENT_BODY")
	ev.subtitle = ""          # day-boundary beat ⇒ no "· HH:MM" (EVENT AUTHORING LAW)
	ev.mentor_choice = -1     # Frank is the speaker; he does not endorse his own offer
	ev.one_shot = false       # inert on an injected event — the real latch is FLAG_OFFERED
	ev.priority = 10
	ev.cooldown_days = 0
	ev.tags = ["build_safe", "angel_round"]
	ev.trigger_conditions = []   # the SYSTEM owns eligibility, not the pool

	var accept := EventChoice.new()
	accept.label = TranslationServer.translate("ANGEL_CHOICE_ACCEPT")
	accept.modifiers = [{"type": "angel_accept"}]   # ONE modifier: see accept_offer

	var refuse := EventChoice.new()
	refuse.label = TranslationServer.translate("ANGEL_CHOICE_REFUSE")
	refuse.modifiers = []   # a locked choice carries none, so the lock is safe even if the
	                        # UI gate were ever bypassed
	# GUARANTEED FALSE, STRUCTURALLY. is_condition_met resolves this to
	# `GameState.get_flag("hard_mode_unlocked", null) == true` → null == true → false, and
	# no writer for that key exists anywhere in the engine (grep-verified). It cannot come
	# true by accident — only by someone deliberately shipping hard mode, which is exactly
	# the socket this is meant to be. flag_equals rather than flag_set on purpose:
	# flag_set would open the moment anyone wrote the key to ANY value, false included.
	refuse.unlock_condition = {"type": "flag_equals", "key": HARD_MODE_FLAG, "value": true}
	refuse.unlock_reason_text = TranslationServer.translate("ANGEL_CHOICE_REFUSE_LOCK")

	var choices: Array[EventChoice] = []
	choices.append(accept)
	choices.append(refuse)
	ev.choices = choices
	return ev


# --- THE ATOMIC ACCEPT SEAM (called by the "angel_accept" modifier) ---

static func accept_offer() -> void:
	# Cash + ledger row + cap table + latch: together or not at all.
	#
	# "Atomic" here means one function, one call site, and no observable intermediate. The
	# re-entry guard sits ABOVE every write, so a partially applied round is
	# unrepresentable; the first signal any listener can see (equity_changed) fires after
	# the ledger row is appended and both cap-table scalars are written.
	#
	# THE ORDER IS LOAD-BEARING, and it copies apply_one_time_cost's reasoning: cash goes
	# LAST because cash_changed is synchronous and the Finance tab repaints inside it — it
	# must read a settled ledger and a settled cap table, never a half-applied round.
	# Moving the cash write up by one line ships a one-frame bar reading 0% beside $25,000
	# of new money.
	if GameState.run_angel_amount > 0:
		push_warning("[AngelRoundSystem] accept_offer called twice — ignored")
		return
	GameState.record_angel_round(EQUITY_PCT, CASH_AMOUNT)      # cap table → equity_changed
	FinanceSystem.apply_one_time_income(CASH_AMOUNT, TX_LABEL) # ledger row, then set_cash
	GameState.set_flag(FLAG_ACCEPTED_DAY, GameState.day)       # Step 3's hire nudge reads this
	GameState.submit_month_highlight(
		TranslationServer.translate("ANGEL_MONTH_HIGHLIGHT"), 75)  # below advance_phase's 80
	if OS.is_debug_build():
		print("[AngelRoundSystem] seed taken: +$%d for %d%% (day %d)" % [
			CASH_AMOUNT, EQUITY_PCT, GameState.day])
