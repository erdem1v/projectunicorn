class_name EvEngine
extends RefCounted

# THE TICK ORCHESTRATOR. Everything the engine does in a day happens here, in this order, and
# the order is the design.
#
# TimeManager calls the engine after Finance and before the endings scan: a `finance.cash`
# condition must see the day's net flow, and a terminal must be able to suppress the day's
# mounts. The engine reads nothing on `day_advanced` — that signal fires inside
# GameState.advance_day(), before the slots dispatch, so anything hooked there reads yesterday.
#
# THE INNER ORDER, AND WHY EACH STEP IS WHERE IT IS
#
#   a. paper expiry          on_expire writes history and flags that TODAY's conditions must
#                            see, and frees desk slots before new papers land.
#   b. timed-flag expiry     must precede any condition read, or `flag_expires_within` lies.
#   c. arc invalidation      reads state that settled yesterday (§8.2: no cascade in one tick).
#                            Before the schedule, so an invalidated arc's step never fires.
#   d. awaiting timeout      same phase as (c), so an arc cannot both time out and be
#                            re-subjected in one tick.
#   e. schedule              §20 B1: an overdue entry fires, never skips.
#   f. arc steps             each live arc proposes the card at its current step.
#   g. signal drain          signals fire during the systems' own slots, while Product, HR and
#                            Sales are still moving; proposing inline would judge a slot-1 edge
#                            before Finance ran. So they BUFFER and drain here, in emission order.
#   h. tick proposals        the per-tick sweep.
#   i. pool draw             after the authored beats — the pool fills what they left.
#   j. floor                 only if (a)-(i) produced nothing at all.
#   k. class assignment      §13's budget, applied to the whole day's admissions AT ONCE.
#   l. pump                  show the top card.
#
# STEP (k) IS NOT WHERE §4.1 PUTS IT, deliberately. §4.1 lists G8 inside propose(), which would
# demote the THIRD-ARRIVING card — possibly the arc payoff. Assigning classes top-down by §11.2
# priority over the day's admissions demotes the least important card, which is what I4 is for.

## Signals proposed during the systems' own slots, drained at step (g).
static var _signal_buffer: Array = []
## Total days the floor was reached and found nothing; the harness reports it.
static var _floor_empty_total: int = 0
## Consecutive days the floor found nothing. §13.6: a run of these is a content hole.
static var _floor_empty_streak: int = 0
## Consecutive days with no interrupt and no paper.
static var _quiet_days: int = 0
## Admissions made today, awaiting class assignment at step (k).
static var _today_admissions: Array = []
## Ids admitted through force_fire and not yet resolved, so their history row says `forced`.
static var _forced: Array = []


static func empty_floor_days() -> int:
	return _floor_empty_total


# --- The daily tick --------------------------------------------------------

static func daily_tick() -> void:
	if not GameState.run_active:
		return
	_today_admissions.clear()

	_step_paper_expiry()
	EvFlags.tick_expiry()
	_step_arc_invalidation()
	_step_awaiting_timeout()
	_step_schedule()
	_step_arc_steps()
	_step_signal_drain()
	_step_tick_proposals(EvGate.Origin.TICK_DAILY, "daily")
	_step_pool("daily")
	_step_floor()
	_step_assign_classes()
	pump()


## No expiry and no arc invalidation here: both are day-granular (§12.5), and checking
## invalidation 24 times a day lets an arc die on the 23rd identical read.
static func hourly_tick(_hour: int) -> void:
	if not GameState.run_active:
		return
	_today_admissions.clear()
	_step_signal_drain()
	_step_tick_proposals(EvGate.Origin.TICK_HOURLY, "hourly")
	_step_pool("hourly")
	_step_assign_classes()
	pump()


# --- (a) Paper expiry ------------------------------------------------------

static func _step_paper_expiry() -> void:
	# §20 B11: the last-day warning comes first and the expiry the day after. If the warning
	# cannot fire the expiry still happens — the consequence is not conditional on the courtesy.
	_step_last_warnings()

	for expired in EvPapers.take_expired():
		var event_id: String = String(expired["event_id"])
		var paper: Dictionary = expired["entry"]
		var context: Dictionary = paper.get("context", {})
		var arc_id: String = String(paper.get("arc_id", ""))
		var card: Dictionary = EvCatalog.card(event_id)
		var penalties: Array = card.get("on_expire", {}).get("penalties", [])

		# §12.4: on_expire runs, history says `expired`, expire_note reaches the ticker.
		var deltas: Array = EvEffects.run_expire(penalties, context)
		EvHistory.record(event_id, EvHistory.RESOLUTION_EXPIRED, "", "expired",
			context, deltas, arc_id)
		var note: String = String(card.get("expire_note", ""))
		if note != "":
			EvTicker.push(note, EvTicker.PRIORITY_PLAYER, context)

		# An expiring arc step must move its arc through an arc verb in on_expire (lint enforces
		# it); without one, an unanswered payoff stalls its arc for the rest of the run (§10.10).
		if arc_id != "" and not _touches_arc(penalties):
			push_error("[EvEngine] arc step '%s' expired without an arc verb in on_expire — arc '%s' may now be stalled"
				% [event_id, arc_id])


static func _step_last_warnings() -> void:
	for event_id in EvPapers.needing_last_warning():
		var id: String = String(event_id)
		if EvQueue.has(id) or EvQueue.active_id() == id:
			continue                      # already in front of the player
		var context: Dictionary = EvPapers.context_of(id)
		# A paper whose subject died overnight expires quietly rather than being shouted about.
		if not EvGate.revalidate(id, context).admitted:
			continue
		EvQueue.admit(id, context, "interrupt", EvPapers.arc_of(id))
		_today_admissions.append(id)


static func _touches_arc(effects: Array) -> bool:
	for e in effects:
		if typeof(e) == TYPE_DICTIONARY \
				and String(e.get("verb", "")) in ["advance_arc", "end_arc", "abort_arc"]:
			return true
	return false


# --- (c) Arc invalidation --------------------------------------------------

static func _step_arc_invalidation() -> void:
	for arc_id in EvArcs.live_ids():
		if EvArcs.state_of(arc_id) != EvArcs.STATE_ACTIVE:
			continue
		var definition: Dictionary = EvCatalog.arc(arc_id)
		var context: Dictionary = _arc_context(arc_id)
		for c in definition.get("invalidate_when", []):
			if typeof(c) == TYPE_DICTIONARY and EvCondition.eval(c, context):
				_invalidate(arc_id, definition, context)
				break


static func _invalidate(arc_id: String, definition: Dictionary, context: Dictionary) -> void:
	var policy_block: Dictionary = definition.get("on_invalidate", {})

	match String(policy_block.get("policy", EvArcs.POLICY_FADE)):
		EvArcs.POLICY_REASSIGN:
			# §10.5: the arc does not die, it STOPS. Its schedule is frozen as relative days and
			# a card goes out asking who takes over.
			EvArcs.pause_for_subject(arc_id)
			var prompt: String = String(policy_block.get("reassign_event", ""))
			if prompt != "":
				_propose(prompt, EvGate.Origin.ARC_STEP, context)

		EvArcs.POLICY_CLOSE:
			# A visible card ties the thread off; §10.6 forbids a promise arc anything quieter.
			EvEffects.run_ambient(policy_block.get("penalties", []), context)
			var closer: String = String(policy_block.get("close_event", ""))
			if closer != "":
				_propose(closer, EvGate.Origin.ARC_STEP, context)
			EvArcs.end(arc_id, "invalidated")

		_:
			# fade: a ticker line and nothing else. Legitimate for a subjectless world arc,
			# forbidden for a promise (§10.6) — lint refuses that combination.
			if String(definition.get("type", "")) == EvArcs.TYPE_PROMISE:
				push_error("[EvEngine] promise arc '%s' tried to fade — §10.6 forbids it" % arc_id)
			var note: String = String(policy_block.get("note_key", ""))
			if note != "":
				EvTicker.push(note, EvTicker.PRIORITY_PLAYER, context)
			EvArcs.end(arc_id, "faded")


static func _step_awaiting_timeout() -> void:
	for arc_id in EvArcs.live_ids():
		if not EvArcs.awaiting_timed_out(arc_id):
			continue
		# §10.5: an arc does not wait forever. After the timeout the policy falls to close, so
		# the thread is tied off visibly.
		var definition: Dictionary = EvCatalog.arc(arc_id).duplicate(true)
		var block: Dictionary = definition.get("on_invalidate", {})
		block["policy"] = EvArcs.POLICY_CLOSE
		definition["on_invalidate"] = block
		_invalidate(arc_id, definition, _arc_context(arc_id))


static func _arc_context(arc_id: String) -> Dictionary:
	var subject: Dictionary = EvArcs.subject_of(arc_id)
	if subject.is_empty():
		return {}
	return {String(subject.get("slot", "subject")): subject}


# --- (e) Schedule ----------------------------------------------------------

static func _step_schedule() -> void:
	for entry in EvSchedule.take_due():
		_propose(String(entry["event_id"]), EvGate.Origin.SCHEDULE,
			entry.get("context", {}), String(entry.get("arc_id", "")))


# --- (f) The arc's own step ------------------------------------------------

## Propose the card at each live arc's CURRENT step. The sweep skips arc cards and the pool
## excludes them (§10.10), so without this an arc's later steps could only arrive if an earlier
## step happened to `schedule_event` them.
##
## The step is PROPOSED, not forced: G3 still latches it and G6/G7 still guard it, which is how
## a step waits for its own condition while its arc is already live. `Origin.ARC_STEP` has no
## arm in G4 on purpose — an arc step's clock is the arc, not the day's sweep.
static func _step_arc_steps() -> void:
	for arc_id in EvArcs.live_ids():
		if EvArcs.state_of(arc_id) != EvArcs.STATE_ACTIVE:
			continue
		var steps: Array = EvCatalog.arc(arc_id).get("steps", [])
		var idx: int = EvArcs.step_of(arc_id)
		if idx < 0 or idx >= steps.size():
			continue
		var event_id: String = String((steps[idx] as Dictionary).get("event_id", ""))
		if event_id == "" or EvQueue.has(event_id) or EvQueue.active_id() == event_id \
				or EvPapers.has(event_id) or EvSchedule.has(event_id):
			continue                       # already on its way to the player
		_propose(event_id, EvGate.Origin.ARC_STEP, EvArcs.subject_of(arc_id), arc_id)


# --- (g) Signals -----------------------------------------------------------

## Called from a signal handler during the systems' slots. Buffers rather than proposing.
static func on_signal(signal_name: String, payload: Dictionary) -> void:
	_signal_buffer.append({"signal": signal_name, "payload": payload})


static func _step_signal_drain() -> void:
	var buffered: Array = _signal_buffer.duplicate()
	_signal_buffer.clear()
	for entry in buffered:
		for id in EvCatalog.card_ids():
			if String(EvCatalog.card(id).get("trigger", {}).get("signal", "")) == entry["signal"]:
				_propose(id, EvGate.Origin.SIGNAL, entry["payload"])


# --- (h) The sweep ---------------------------------------------------------

## Per-tick, never per-frame (§15.3). The GDD asks for change-driven re-evaluation via seam
## dirty-flags; condition-triggered cards are swept instead, because `days_since_flag` depends
## on the day counter (always dirty) and selectors like "the lowest-morale employee" are dirty
## on every morale signal — and a missed dirty-mark would be invisible: the card silently never
## fires. The gate's own order (latch, guards, tree) is the cheap pre-filter.
static func _step_tick_proposals(origin: EvGate.Origin, tick: String) -> void:
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		if String(card["tick"]) != tick or card.has("arc"):
			continue                        # arc steps come from the arc, never from a sweep
		if (card["tags"] as Array).has("critical"):
			_propose(id, origin, {})        # everything else is the pool's business


# --- (i) The pool ----------------------------------------------------------

static func _step_pool(tick: String) -> void:
	var candidates: Array = []
	for card in EvCatalog.pool_candidates(tick):
		var verdict: EvGate.Verdict = EvGate.propose(String(card["id"]), EvGate.Origin.POOL)
		# §13.3 layers 1-3 are a refusal here, not a demotion.
		if verdict.admitted \
				and EvTempo.pool_blocked_reason(card, EvGate._subject_of(verdict.context)) == "":
			candidates.append({"card": card, "verdict": verdict})
	if candidates.is_empty():
		return

	# §14.3: a deterministic weighted draw. NOT RngStreams — that generator is position-resuming,
	# so a reload that spent a different number of draws would pick a different card. A pure hash
	# of (seed, day, "pool") cannot drift.
	var picked: Dictionary = _weighted_pick(candidates)
	_admit(String(picked["card"]["id"]), picked["verdict"], "")


static func _weighted_pick(candidates: Array) -> Dictionary:
	var total: float = 0.0
	for c in candidates:
		total += maxf(0.0, float(c["card"]["weight"]))
	if total <= 0.0:
		return candidates[0]
	var roll: float = EvDice.unit("pool", GameState.day, "", "") * total
	var running: float = 0.0
	for c in candidates:
		running += maxf(0.0, float(c["card"]["weight"]))
		if roll <= running:
			return c
	return candidates[-1]


# --- (j) The floor ---------------------------------------------------------

static func _step_floor() -> void:
	# §13.6's three conditions: a quiet stretch, a CLEAR desk, and no open modal. An unanswered
	# paper means the player is deferring, and filling a silence the player made is nagging.
	if not _today_admissions.is_empty() or not EvPapers.is_empty() or EvQueue.active_id() != "":
		_quiet_days = 0
		return
	if EvFlags.has("tutorial_active"):
		return                                  # §11.6: the floor is off during a tutorial

	_quiet_days += 1
	if _quiet_days < EvTuning.FLOOR_QUIET_DAYS:
		return
	_quiet_days = 0

	# §13.6: quiet cards still pass their own conditions; the floor only ignores the quota.
	var quiet_pool: Array = []
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		if not (card["tags"] as Array).has("quiet"):
			continue
		var verdict: EvGate.Verdict = EvGate.propose(id, EvGate.Origin.FLOOR)
		if verdict.admitted:
			quiet_pool.append({"card": card, "verdict": verdict})

	if quiet_pool.is_empty():
		# §13.6: silence beats nonsense, but an empty floor is REPORTED.
		_floor_empty_streak += 1
		_floor_empty_total += 1
		if _floor_empty_streak >= EvTuning.FLOOR_EMPTY_REPORT_AFTER:
			push_warning("[EvEngine] the floor has found nothing %d times running — the quiet pool is too thin (§13.6)"
				% _floor_empty_streak)
		return

	_floor_empty_streak = 0
	var picked: Dictionary = _weighted_pick(quiet_pool)
	_admit(String(picked["card"]["id"]), picked["verdict"], "")


# --- (k) Class assignment --------------------------------------------------

static func _step_assign_classes() -> void:
	if _today_admissions.is_empty():
		return
	var pending: Array = _today_admissions.map(func(id): return {"event_id": id})
	for entry in EvTempo.assign(pending):
		var event_id: String = String(entry["event_id"])
		var final_class: String = String(entry["class"])
		EvQueue.set_class(event_id, final_class)
		# I4: a demoted card is not dropped, it lands on the desk with a clock (R8a's lint rule
		# guarantees a demotable interrupt carries the expiry trio). It must leave the queue, or
		# the next pump would mount it anyway and the demotion would be invisible.
		if final_class == "paper" and bool(entry.get("demoted", false)):
			var queued: Dictionary = EvQueue.take(event_id)
			# A demoted last warning is already on the desk; re-placing it would restart its clock.
			if not EvPapers.has(event_id):
				var card: Dictionary = EvCatalog.card(event_id)
				EvPapers.place(event_id, queued.get("context", {}), _expiry_days(card),
					String(card.get("arc", "")))
	_today_admissions.clear()


# --- Admission and display -------------------------------------------------

static func _propose(event_id: String, origin: EvGate.Origin, given: Dictionary,
		arc_id: String = "") -> bool:
	var verdict: EvGate.Verdict = EvGate.propose(event_id, origin, given)
	return verdict.admitted and _admit(event_id, verdict, arc_id)


static func _admit(event_id: String, verdict: EvGate.Verdict, arc_id: String) -> bool:
	var card: Dictionary = EvCatalog.card(event_id)

	# The latch is spent AT ADMISSION: a card waiting in the queue must not be re-proposed
	# every tick.
	EvLatches.spend(EvLatches.key_for(event_id, String(card["latch_key"]),
		EvGate._subject_of(verdict.context)))

	# A PAPER IS NOT QUEUED. `has_pending()` gates the clock and the save, so a queued paper
	# would hold the game paused for its whole week; and `pump()` would mount it as a modal,
	# the opposite of §11.4, where a paper waits until the player picks it up.
	if verdict.card_class == "paper":
		if EvPapers.has(event_id):
			return false
		EvPapers.place(event_id, verdict.context, _expiry_days(card), arc_id)
		_today_admissions.append(event_id)
		return true
	var ok: bool = EvQueue.admit(event_id, verdict.context, verdict.card_class, arc_id)
	if ok:
		_today_admissions.append(event_id)
	return ok


## §12.2's table, by stakes.
static func _expiry_days(card: Dictionary) -> int:
	if card.has("expires_days"):
		return int(card["expires_days"])
	var tags: Array = card["tags"]
	if tags.has("money_table"):
		return EvTuning.EXPIRY_MONEY_DAYS
	if tags.has("low_stakes"):
		return EvTuning.EXPIRY_LOW_STAKES_DAYS
	return EvTuning.EXPIRY_DEFAULT_DAYS


## Show the top card, if nothing is showing. §4.4's re-validation happens HERE — days may have
## passed since admission, and the card's subject may have resigned.
static func pump() -> bool:
	if not GameState.run_active or EvQueue.active_id() != "":
		return false

	while true:
		var next: Dictionary = EvQueue.next()
		if next.is_empty():
			return false
		var event_id: String = String(next["event_id"])
		var context: Dictionary = next["context"]
		EvQueue.take(event_id)

		var verdict: EvGate.Verdict = EvGate.revalidate(event_id, context)
		if not verdict.admitted:
			# §4.4: cancelled silently, history says `dropped` — the world moved.
			EvPapers.remove(event_id)
			EvHistory.record(event_id, EvHistory.RESOLUTION_DROPPED, "", verdict.step,
				context, [], String(next.get("arc_id", "")))
			continue

		EvQueue.set_active(event_id, context)
		_announce(event_id, context)
		return true
	return false


## The engine's only words to the UI. `event_triggered` feeds the left rail's badge;
## `modal_requested` is what main.gd mounts the EventModal on — without it nothing reaches the
## screen. The view is built here so the receiver never has to know which id is active.
static func _announce(event_id: String, context: Dictionary) -> void:
	EventBus.event_triggered.emit(event_id)
	EventBus.modal_requested.emit(EvPresenter.build_view(event_id, context))


# --- Resolution ------------------------------------------------------------

## The player picked an option. The one path by which a decision becomes state.
static func resolve(event_id: String, option_id: String) -> void:
	if EvQueue.active_id() != event_id:
		push_warning("[EvEngine] resolve for '%s' but '%s' is active — ignored"
			% [event_id, EvQueue.active_id()])
		return
	var card: Dictionary = EvCatalog.card(event_id)
	var context: Dictionary = EvQueue.active_context()
	var option_index: int = _option_index(card, option_id)
	if option_index < 0:
		push_error("[EvEngine] card '%s' has no option '%s'" % [event_id, option_id])
		return
	var option: Dictionary = card["options"][option_index]

	# §20 A2 and E4: the last check. Between the card appearing and the click, the entity may
	# have gone.
	if not EvScope.still_valid(context):
		EvQueue.clear_active()
		EvHistory.record(event_id, EvHistory.RESOLUTION_DROPPED, "", "entity_gone", context, [])
		EventBus.event_resolved.emit(event_id, -1)
		pump()
		return

	var deltas: Array
	var outcome: String = String(option.get("outcome_id", option_id))
	if option.has("check"):
		# §9: the dice. Both branches run through the check-branch vocabulary, where I6 lives.
		var check: Dictionary = option["check"]
		var odds: float = float(EvSeams.read(String(check.get("odds_seam", ""))))
		var passed: bool = EvDice.check(odds, event_id, option_id)
		deltas = EvEffects.run_check_branch(check.get("on_pass" if passed else "on_fail", []),
			context)
		outcome = "%s_%s" % [outcome, "pass" if passed else "fail"]
	else:
		deltas = EvEffects.run_played(option.get("effects", []), context)

	var arc_id: String = String(card.get("arc", ""))
	var forced: bool = _forced.has(event_id)
	_forced.erase(event_id)
	EvHistory.record(event_id, EvHistory.RESOLUTION_CHOSEN, option_id, outcome,
		context, deltas, arc_id, forced)

	EvPapers.remove(event_id)
	EvQueue.clear_active()

	# An arc step resolving advances its arc — unless the option moved the arc itself.
	if arc_id != "" and not _touches_arc(option.get("effects", [])):
		EvArcs.advance(arc_id)

	# BEFORE THE PUMP: main.gd's handler asks `has_pending()` to decide whether to give the
	# clock back, and the answer must describe the queue before the next card is mounted.
	# The index, not the option id, is EventBus's declared signature; it matches the modal's row
	# order because EvPresenter walks the same array.
	EventBus.event_resolved.emit(event_id, option_index)

	pump()


static func _option_index(card: Dictionary, option_id: String) -> int:
	var options: Array = card.get("options", [])
	for i in options.size():
		if String((options[i] as Dictionary).get("id", "")) == option_id:
			return i
	return -1


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_signal_buffer.clear()
	_floor_empty_streak = 0
	_floor_empty_total = 0
	_quiet_days = 0
	_today_admissions.clear()
	_forced.clear()
	EvSave.reset()


# --- Public entries --------------------------------------------------------

## Ask for a card by id, from outside the tick — e.g. the Sales tab's "İlgilen →". A second
## ENTRY POINT, never a second ADMISSION path (I1): the gate applies every step, the latch is
## spent, and a duplicate is refused by the queue.
##
## Returns true when the card was admitted.
static func request(event_id: String, context: Dictionary = {}) -> bool:
	if not GameState.run_active:
		return false
	if not _propose(event_id, EvGate.Origin.REQUEST, context):
		return false
	_step_assign_classes()
	pump()
	return true


## §4.5 — the one sanctioned exception, for debug and the smoke suite.
##
## Skips G3 (latch), G4 (window) and G8 (tempo). Does NOT skip G1, G2, G5, G6 or G7: a forced
## card with an unbound slot would make its effects silently no-op, a worse test than none.
## Its history row carries `forced: true`.
static func force_fire(event_id: String, context: Dictionary = {}) -> bool:
	if not OS.is_debug_build():
		push_error("[EvEngine] force_fire is not available in a release build")
		return false
	var verdict: EvGate.Verdict = EvGate.propose(event_id, EvGate.Origin.FORCE, context)
	if not verdict.admitted:
		push_warning("[EvEngine] force_fire refused at %s: %s" % [verdict.step, verdict.reason])
		return false
	EvQueue.admit(event_id, verdict.context, verdict.card_class,
		String(EvCatalog.card(event_id).get("arc", "")))
	_forced.append(event_id)
	pump()
	return true


## The player picked a paper off the desk. §11.4: "Kağıt açıldığında modal gibi davranır (zaman
## durur), kapatıldığında masaya döner."
##
## Not a full gate pass: the latch is spent and the class decided, and re-charging either would
## let a paper die on a rule it already passed (§4.4). G5/G6/G7 are re-checked — the subject may
## have resigned while it sat on the desk.
static func open_paper(event_id: String) -> bool:
	if not EvPapers.has(event_id) or EvQueue.active_id() != "":
		return false                       # one modal at a time (§11.3)
	var context: Dictionary = EvPapers.context_of(event_id)
	var verdict: EvGate.Verdict = EvGate.revalidate(event_id, context)
	if not verdict.admitted:
		# History says `dropped` with the refusing step, so the debug panel can explain a paper
		# that vanished off the desk.
		EvPapers.remove(event_id)
		EvQueue.remove(event_id)
		EvHistory.record(event_id, EvHistory.RESOLUTION_DROPPED, "", verdict.step, context, [])
		return false
	EvPapers.mark_opened(event_id)
	EvQueue.set_active(event_id, context)
	_announce(event_id, context)
	return true
