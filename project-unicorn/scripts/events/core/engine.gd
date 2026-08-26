class_name EvEngine
extends RefCounted

# THE TICK ORCHESTRATOR. Everything the engine does in a day happens here, in this order, and
# the order is the design.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHERE THIS SITS IN THE OUTER TICK
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# TimeManager dispatches 13 daily slots; the engine is slot 7, after Finance and before the
# endings scan. Both placements are load-bearing and both are already documented in the file
# that does the dispatching (time_manager.gd:344-348): a `finance.cash` condition must see the
# day's net flow, and a terminal must be able to suppress the day's mounts.
#
# THE ENGINE READS NOTHING ON `day_advanced`. That signal fires INSIDE GameState.advance_day(),
# before the slots dispatch, so anything hooked there reads yesterday. Four separate modules
# have been bitten by this and each left a comment about it (event_bus.gd:113, :121, :164,
# :286). The engine is driven by TimeManager's call, never by the signal.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# THE INNER ORDER, AND WHY EACH STEP IS WHERE IT IS
# ─────────────────────────────────────────────────────────────────────────────────────────
#
#   a. paper expiry          on_expire writes history and flags that TODAY's conditions must
#                            see; an expiry is yesterday's decision resolving, so it belongs
#                            with the resolutions. It also frees desk slots before new papers
#                            land.
#   b. timed-flag expiry     must precede any condition read, or `flag_expires_within` lies.
#   c. arc invalidation      reads state that settled yesterday — §8.2's no-cascade-in-one-tick
#                            rule guarantees that. Before the schedule, so an invalidated arc's
#                            step is gone before it can fire.
#   d. awaiting timeout      same phase as (c), so an arc cannot both time out and be
#                            re-subjected in one tick.
#   e. schedule              §20 B1: an overdue entry fires, never skips.
#   f. signal drain          THE GDD DOES NOT SPECIFY THIS AND IT IS A REAL BUG SOURCE.
#                            Signals fire during slots 1-6, i.e. while Product, HR and Sales
#                            are still moving. Proposing inline would admit a slot-1 signal
#                            before Finance had run. So signals BUFFER and drain here, in
#                            emission order. time_manager.gd:357-368 already documents this
#                            exact hazard for the old engine's enqueue_front ("on a day when
#                            two systems both inject, the FIRST caller owns the modal"), and
#                            buffering turns that ordering accident into data.
#   g. tick proposals        the per-tick sweep.
#   h. pool draw             after the authored beats — the pool fills what they left.
#   i. floor                 only if (a)-(h) produced nothing at all.
#   j. class assignment      §13's budget, applied to the whole day's admissions AT ONCE.
#   k. pump                  show the top card.
#
# STEP (j) IS NOT WHERE §4.1 PUTS IT, and that is deliberate. §4.1 lists G8 inside propose(),
# which would demote the THIRD-ARRIVING card. The third to arrive is not the least important —
# it might be the arc payoff. Collecting the day's admissions and assigning classes top-down by
# §11.2 priority means the least important thing is demoted, which is what I4 is for.

## Signals proposed during the systems' own slots, drained at step (f).
static var _signal_buffer: Array = []
## TOTAL days the floor was reached and found nothing — a figure the harness reports, where
## the streak below only warns.
static var _floor_empty_total: int = 0


static func empty_floor_days() -> int:
	return _floor_empty_total


## Consecutive days the floor found nothing. §13.6: three in a row is a content hole and the
## harness says so rather than letting randomness cover it.
static var _floor_empty_streak: int = 0
## Consecutive days with no interrupt and no paper.
static var _quiet_days: int = 0
## Admissions made today, awaiting class assignment at step (j).
static var _today_admissions: Array = []


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
	_step_pool(EvGate.Origin.POOL, "daily")
	_step_floor()
	_step_assign_classes()
	pump()


static func hourly_tick(hour: int) -> void:
	if not GameState.run_active:
		return
	_today_admissions.clear()
	_step_signal_drain()
	_step_tick_proposals(EvGate.Origin.TICK_HOURLY, "hourly")
	_step_pool(EvGate.Origin.POOL, "hourly")
	_step_assign_classes()
	pump()
	# No expiry and no arc invalidation on the hourly path: both are day-granular (§12.5), and
	# running an invalidation check 24 times a day lets an arc die on the 23rd identical read
	# with no new information behind it.


# --- (a) Paper expiry ------------------------------------------------------

static func _step_paper_expiry() -> void:
	# §20 B11: the last-day warning comes first and the expiry the day after. If the warning
	# cannot fire — the budget is spent, the day is full — the expiry still happens. A warning
	# is a courtesy; the consequence is not conditional on it.
	_step_last_warnings()

	for expired in EvPapers.take_expired():
		var entry: Dictionary = expired
		var event_id: String = String(entry["event_id"])
		var card: Dictionary = EvCatalog.card(event_id)
		var context: Dictionary = (entry["entry"] as Dictionary).get("context", {})

		# §12.4: on_expire runs, history says `expired`, expire_note reaches the ticker. There
		# is no silent expiry — §17.7 makes all three fields mandatory on a paper, so a card
		# that got this far has them.
		var deltas: Array = EvEffects.run_expire(card.get("on_expire", {}).get("penalties", []),
			context)
		EvHistory.record(event_id, EvHistory.RESOLUTION_EXPIRED, "", "expired",
			context, deltas, String((entry["entry"] as Dictionary).get("arc_id", "")))
		var note: String = String(card.get("expire_note", ""))
		if note != "":
			EvTicker.push(note, EvTicker.PRIORITY_PLAYER, context)

		# A1 (approved amendment). An arc step that expires MUST move its arc — the on_expire
		# list carries an arc verb, and lint enforces it. Without this an arc payoff demoted to
		# paper and left unanswered would stall its arc for the rest of the run, which is
		# §10.10's silent death arriving through a door §10 never closed.
		var arc_id: String = String((entry["entry"] as Dictionary).get("arc_id", ""))
		if arc_id != "" and not _touches_arc(card.get("on_expire", {}).get("penalties", [])):
			push_error("[EvEngine] arc step '%s' expired without an arc verb in on_expire — "
				% event_id + "arc '%s' may now be stalled (A1, lint should have caught this)"
				% arc_id)


static func _step_last_warnings() -> void:
	for event_id in EvPapers.needing_last_warning():
		var id: String = String(event_id)
		if EvQueue.has(id) or EvQueue.active_id() == id:
			continue                      # already in front of the player
		var context: Dictionary = EvPapers.context_of(id)
		# Re-validate: a paper whose subject died overnight should expire quietly, not be
		# shouted about.
		var verdict: EvGate.Verdict = EvGate.revalidate(id, context)
		if not verdict.admitted:
			continue
		EvQueue.admit(id, context, "interrupt", EvPapers.arc_of(id))
		_today_admissions.append(id)



static func _pool_candidates_after_brakes(tick: String, origin: EvGate.Origin) -> Array:
	var out: Array = []
	for card in EvCatalog.pool_candidates(tick):
		var c: Dictionary = card
		var verdict: EvGate.Verdict = EvGate.propose(String(c["id"]), origin)
		if not verdict.admitted:
			continue
		var subject: String = EvGate._subject_of(verdict.context)
		var braked: String = EvTempo.pool_blocked_reason(c, subject)
		if braked != "":
			continue                      # §13.3 layers 1-3: a refusal, not a demotion
		out.append({"card": c, "verdict": verdict})
	return out



static func _touches_arc(effects: Array) -> bool:
	for e in effects:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var verb: String = String((e as Dictionary).get("verb", ""))
		if verb in ["advance_arc", "end_arc", "abort_arc"]:
			return true
	return false


# --- (c) Arc invalidation --------------------------------------------------

static func _step_arc_invalidation() -> void:
	for arc_id in EvArcs.live_ids():
		if EvArcs.state_of(arc_id) != EvArcs.STATE_ACTIVE:
			continue
		var definition: Dictionary = EvCatalog.arc(arc_id)
		var conditions: Array = definition.get("invalidate_when", [])
		if conditions.is_empty():
			continue
		var context: Dictionary = _arc_context(arc_id)
		var tripped: bool = false
		for c in conditions:
			if typeof(c) == TYPE_DICTIONARY and EvCondition.eval(c as Dictionary, context):
				tripped = true
				break
		if tripped:
			_invalidate(arc_id, definition, context)


static func _invalidate(arc_id: String, definition: Dictionary, context: Dictionary) -> void:
	var policy_block: Dictionary = definition.get("on_invalidate", {})
	var policy: String = String(policy_block.get("policy", EvArcs.POLICY_FADE))

	match policy:
		EvArcs.POLICY_REASSIGN:
			# §10.5: the arc does not die, it STOPS. Its schedule is frozen as relative days
			# and a card goes out asking who takes over. Ar-Ge §5.0's rule for research
			# assignments is the same shape — "atamalar silinmez, duraklar".
			EvArcs.pause_for_subject(arc_id)
			var prompt: String = String(policy_block.get("reassign_event", ""))
			if prompt != "":
				_propose(prompt, EvGate.Origin.ARC_STEP, context)

		EvArcs.POLICY_CLOSE:
			# A visible card ties the thread off. §10.6 forbids a promise arc from doing
			# anything quieter than this.
			EvEffects.run_ambient(policy_block.get("penalties", []), context)
			var closer: String = String(policy_block.get("close_event", ""))
			if closer != "":
				_propose(closer, EvGate.Origin.ARC_STEP, context)
			EvArcs.end(arc_id, "invalidated")

		_:
			# fade: a ticker line and nothing else. Legitimate for a subjectless world arc,
			# and forbidden for a promise (§10.6) — the linter refuses that combination, so
			# reaching here with a promise arc means content got past the gate.
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
		# the thread is tied off visibly rather than hanging for the rest of the run.
		var definition: Dictionary = EvCatalog.arc(arc_id)
		var block: Dictionary = definition.get("on_invalidate", {}).duplicate(true)
		block["policy"] = EvArcs.POLICY_CLOSE
		definition = definition.duplicate(true)
		definition["on_invalidate"] = block
		_invalidate(arc_id, definition, _arc_context(arc_id))


static func _arc_context(arc_id: String) -> Dictionary:
	var subject: Dictionary = EvArcs.subject_of(arc_id)
	if subject.is_empty():
		return {}
	return {String(subject.get("slot", "subject")): subject}


# --- (e) Schedule ----------------------------------------------------------

static func _step_schedule() -> void:
	for due in EvSchedule.take_due():
		var entry: Dictionary = due
		_propose(String(entry["event_id"]), EvGate.Origin.SCHEDULE,
			entry.get("context", {}), String(entry.get("arc_id", "")))


# --- (e2) The arc's own step ------------------------------------------------

## Propose the card at each live arc's CURRENT step.
##
## THIS WAS THE HOLE. `_step_tick_proposals` skips a card with an `arc` and the pool excludes
## one (§10.10) — both correct, both saying "the arc raises this, not us" — and then nothing
## raised it. An arc's steps could reach the player by exactly one route, a previous step
## calling `schedule_event`, and a ladder whose author did not know that stops after its first
## rung with every gate green.
##
## The step is PROPOSED, not forced: G3 still latches it, G6 still guards it, and G7 still asks
## its condition, which is how `world.final_stretch_comment` waits for day 700 while its arc has
## been live since 640. `Origin.ARC_STEP` has no arm in G4 on purpose — an arc step's clock is
## the arc, not the day's sweep.
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


# --- (f) Signals -----------------------------------------------------------

## Called from a signal handler DURING the systems' slots. Buffers rather than proposing, so a
## slot-1 edge is not admitted before Finance has run.
static func on_signal(signal_name: String, payload: Dictionary) -> void:
	_signal_buffer.append({"signal": signal_name, "payload": payload, "day": GameState.day})


static func _step_signal_drain() -> void:
	if _signal_buffer.is_empty():
		return
	var buffered: Array = _signal_buffer.duplicate()
	_signal_buffer.clear()
	for item in buffered:
		var entry: Dictionary = item
		var signal_name: String = String(entry["signal"])
		for card in _cards_triggered_by(signal_name):
			_propose(String((card as Dictionary)["id"]), EvGate.Origin.SIGNAL,
				entry.get("payload", {}))


static func _cards_triggered_by(signal_name: String) -> Array:
	var out: Array = []
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		var trigger: Dictionary = card.get("trigger", {})
		if String(trigger.get("signal", "")) == signal_name:
			out.append(card)
	return out


# --- (g) The sweep ---------------------------------------------------------

## Per-tick, never per-frame (§15.3, acceptance gate 14).
##
## A DELIBERATE DEVIATION, RECORDED: the GDD asks for change-driven re-evaluation via seam
## dirty-flags. Signal-triggered cards ARE change-driven — they are proposed from the handler.
## Condition-triggered cards are swept, because dirty-flagging cannot cover three of the five
## leaf types: `days_since_flag` depends on the day counter so its cards are unconditionally
## dirty every tick (and the Frank corpus is built on that primitive), and a selector like
## "the lowest-morale employee" is dirty on every morale signal. A missed dirty-mark is also
## INVISIBLE — the card silently never fires and the panel truthfully reports "condition
## false" while the real cause is a stale cache, which is the same failure class as
## `get_history()` having no callers. The cheap pre-filters are the gate's own order: latch
## first, then guards, then the tree.
static func _step_tick_proposals(origin: EvGate.Origin, tick: String) -> void:
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		if String(card["tick"]) != tick:
			continue
		if card.has("arc"):
			continue                        # arc steps come from the arc, never from a sweep
		if not (card["tags"] as Array).has("critical"):
			continue                        # everything else is the pool's business
		_propose(id, origin, {})


# --- (h) The pool ----------------------------------------------------------

static func _step_pool(origin: EvGate.Origin, tick: String) -> void:
	var candidates: Array = _pool_candidates_after_brakes(tick, origin)

	if candidates.is_empty():
		return

	# §14.3: a deterministic weighted draw. NOT RngStreams — that generator is
	# position-resuming (it serialises `state` precisely because position matters), so a reload
	# that spends a different number of draws would pick a different card. A pure hash of
	# (seed, day, "pool", n) cannot drift.
	var picked: Dictionary = _weighted_pick(candidates)
	var card: Dictionary = picked["card"]
	var verdict: EvGate.Verdict = picked["verdict"]
	_admit(String(card["id"]), verdict, "")


static func _weighted_pick(candidates: Array) -> Dictionary:
	var total: float = 0.0
	for c in candidates:
		total += maxf(0.0, float(((c as Dictionary)["card"] as Dictionary)["weight"]))
	if total <= 0.0:
		return candidates[0]
	var roll: float = EvDice.unit("pool", GameState.day, "", "") * total
	var running: float = 0.0
	for c in candidates:
		running += maxf(0.0, float(((c as Dictionary)["card"] as Dictionary)["weight"]))
		if roll <= running:
			return c
	return candidates[candidates.size() - 1]


# --- (i) The floor ---------------------------------------------------------

static func _step_floor() -> void:
	# §13.6's three conditions, all of them: a quiet stretch, a CLEAR desk, and no open modal.
	# The desk clause is the subtle one — an unanswered paper means the player is deferring,
	# not that the game has gone quiet, and filling a silence the player made themselves is how
	# an engine starts nagging.
	if not _today_admissions.is_empty():
		_quiet_days = 0
		return
	if not EvPapers.is_empty() or EvQueue.active_id() != "":
		_quiet_days = 0
		return
	if EvFlags.has("tutorial_active"):
		return                                  # §11.6: the floor is off during a tutorial

	_quiet_days += 1
	if _quiet_days < EvTuning.FLOOR_QUIET_DAYS:
		return
	_quiet_days = 0

	var quiet_pool: Array = []
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		if not (card["tags"] as Array).has("quiet"):
			continue
		# §13.6: quiet cards still pass their own conditions. The floor does not skip the gate;
		# it only ignores the category quota.
		var verdict: EvGate.Verdict = EvGate.propose(id, EvGate.Origin.FLOOR)
		if verdict.admitted:
			quiet_pool.append({"card": card, "verdict": verdict})

	if quiet_pool.is_empty():
		# §13.6's last clause: silence beats nonsense, but an empty floor is REPORTED. Three in
		# a row is a content hole, and the harness says so rather than letting randomness
		# cover it.
		_floor_empty_streak += 1
		_floor_empty_total += 1
		if _floor_empty_streak >= EvTuning.FLOOR_EMPTY_REPORT_AFTER:
			push_warning("[EvEngine] the floor has found nothing %d times running — "
				% _floor_empty_streak + "the quiet pool is too thin (§13.6)")
		return

	_floor_empty_streak = 0
	var picked: Dictionary = _weighted_pick(quiet_pool)
	_admit(String((picked["card"] as Dictionary)["id"]), picked["verdict"], "")


# --- (j) Class assignment --------------------------------------------------

static func _step_assign_classes() -> void:
	if _today_admissions.is_empty():
		return
	var pending: Array = []
	for event_id in _today_admissions:
		pending.append({"event_id": event_id})
	for assigned in EvTempo.assign(pending):
		var entry: Dictionary = assigned
		var event_id: String = String(entry["event_id"])
		var final_class: String = String(entry["class"])
		EvQueue.set_class(event_id, final_class)
		# I4: a demoted card is not dropped, it lands on the desk — and it keeps a clock, which
		# is the only reason paper is a safe floor. R8a's lint rule guarantees a demotable
		# interrupt carries the expiry trio, so this cannot manufacture a paper without one.
		if final_class == "paper" and bool(entry.get("demoted", false)):
			var card: Dictionary = EvCatalog.card(event_id)
			var ctx: Dictionary = EvQueue.context_of(event_id)
			# OFF THE QUEUE AND ONTO THE DESK. A demoted card that stayed queued would still be
			# mounted by the next pump, which would make the demotion invisible — the tempo
			# brake would report a quiet day and the player would get the modal anyway.
			EvQueue.remove(event_id)
			EvPapers.place(event_id, ctx, _expiry_days(card), String(card.get("arc", "")))
	_today_admissions.clear()




# --- Admission and display -------------------------------------------------

static func _propose(event_id: String, origin: EvGate.Origin, given: Dictionary,
		arc_id: String = "") -> bool:
	var verdict: EvGate.Verdict = EvGate.propose(event_id, origin, given)
	if not verdict.admitted:
		return false
	return _admit(event_id, verdict, arc_id)


static func _admit(event_id: String, verdict: EvGate.Verdict, arc_id: String) -> bool:
	var card: Dictionary = EvCatalog.card(event_id)

	# The latch is spent AT ADMISSION, not at resolution. A card that reached the queue has
	# consumed its slot even if the player never answers it — otherwise it would be re-proposed
	# every tick while it sat there waiting.
	var key: String = EvLatches.key_for(event_id, String(card["latch_key"]),
		EvGate._subject_of(verdict.context))
	EvLatches.spend(key)

	# A PAPER IS NOT QUEUED. It goes to the desk and nowhere else, and the distinction is
	# load-bearing in two directions: `has_pending()` gates the clock and the save, so a paper
	# left on the desk for its full week would otherwise hold the game paused and unsaveable
	# for seven days; and `pump()` mounts whatever the queue ranks first, so a queued paper
	# would arrive as a modal — the exact opposite of §11.4, where a paper WAITS and becomes a
	# modal only when the player picks it up.
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


static func _expiry_days(card: Dictionary) -> int:
	if card.has("expires_days"):
		return int(card["expires_days"])
	# §12.2's table, by stakes rather than by guesswork.
	if (card["tags"] as Array).has("money_table"):
		return EvTuning.EXPIRY_MONEY_DAYS
	if (card["tags"] as Array).has("low_stakes"):
		return EvTuning.EXPIRY_LOW_STAKES_DAYS
	return EvTuning.EXPIRY_DEFAULT_DAYS


## Show the top card, if nothing is showing. §4.4's re-validation happens HERE — days may have
## passed since admission, and the employee the card is about may have resigned.
static func pump() -> bool:
	if not GameState.run_active:
		return false
	if EvQueue.active_id() != "":
		return false

	while true:
		var next: Dictionary = EvQueue.next()
		if next.is_empty():
			return false
		var event_id: String = String(next["event_id"])
		var context: Dictionary = next["context"]

		var verdict: EvGate.Verdict = EvGate.revalidate(event_id, context)
		if not verdict.admitted:
			# §4.4: the card is cancelled silently and history says `dropped`. Silent to the
			# player, loud in the log — a card that stopped making sense between admission and
			# display is not an error, it is the world moving.
			EvQueue.take(event_id)
			EvPapers.remove(event_id)
			EvHistory.record(event_id, EvHistory.RESOLUTION_DROPPED, "", verdict.step,
				context, [], String(next.get("arc_id", "")))
			continue

		EvQueue.take(event_id)
		EvQueue.set_active(event_id, context)
		_announce(event_id, context)
		return true
	return false


## THE ENGINE'S ONLY WORDS TO THE UI, and they are the same two the old engine said, so every
## consumer keeps working without knowing the engine changed underneath it:
##
##   `event_triggered`  — the left rail's badge counts these (left_tabs.gd:73).
##   `modal_requested`  — main.gd mounts the EventModal on this, captures the pre-event speed
##                        and pauses. Without it NOTHING reaches the screen: the queue would
##                        fill, the active slot would be set, and the game would go quiet.
##
## The view is built HERE and handed over, rather than the receiver being asked to fetch it,
## because the receiver would have to know which id is active — and that is the private-field
## reach-in the facade exists to delete.
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
	var option: Dictionary = _option(card, option_id)
	if option.is_empty():
		push_error("[EvEngine] card '%s' has no option '%s'" % [event_id, option_id])
		return

	# §20 A2 and E4: the last check. Between the card appearing and the click, the entity may
	# have gone and the cost may have become unaffordable.
	if not EvScope.still_valid(context):
		EvQueue.clear_active()
		EvHistory.record(event_id, EvHistory.RESOLUTION_DROPPED, "", "entity_gone", context, [])
		EventBus.event_resolved.emit(event_id, -1)
		pump()
		return

	var deltas: Array = []
	var outcome: String = String(option.get("outcome_id", option_id))

	if option.has("check"):
		# §9: the dice. One type, `check`, and both branches run through the check-branch
		# vocabulary — which is where I6 lives.
		var check: Dictionary = option["check"]
		var odds: float = float(EvSeams.read(String(check.get("odds_seam", ""))))
		var passed: bool = EvDice.check(odds, event_id, option_id)
		deltas = EvEffects.run_check_branch(check.get("on_pass" if passed else "on_fail", []),
			context)
		outcome = "%s_%s" % [outcome, "pass" if passed else "fail"]
	else:
		deltas = EvEffects.run_played(option.get("effects", []), context)

	EvHistory.record(event_id, EvHistory.RESOLUTION_CHOSEN, option_id, outcome,
		context, deltas, String(card.get("arc", "")))

	EvPapers.remove(event_id)
	EvQueue.clear_active()

	# An arc step resolving advances its arc — unless the option said otherwise explicitly.
	var arc_id: String = String(card.get("arc", ""))
	if arc_id != "" and not _touches_arc(option.get("effects", [])):
		EvArcs.advance(arc_id)

	# BEFORE THE PUMP, and that ordering is a contract main.gd depends on: its handler asks
	# `has_pending()` to decide whether to give the clock back, and the answer has to be about
	# the queue as it stands BEFORE the next card is mounted. Emitting after the pump would
	# make every chained card unpause and re-pause the tree between modals.
	#
	# The index, not the option id: `event_resolved(event_id, choice_index)` is EventBus's
	# declared signature and three consumers read it positionally. The engine knows the option
	# order because it built the view from the same array.
	EventBus.event_resolved.emit(event_id, _option_index(card, option_id))

	pump()


## The option's position in the card's own order — which is also the row order the modal
## rendered, because EvPresenter walks the same array.
static func _option_index(card: Dictionary, option_id: String) -> int:
	var options: Array = card.get("options", [])
	for i in options.size():
		if String((options[i] as Dictionary).get("id", "")) == option_id:
			return i
	return -1


static func _option(card: Dictionary, option_id: String) -> Dictionary:
	for o in (card.get("options", []) as Array):
		if typeof(o) == TYPE_DICTIONARY and String((o as Dictionary).get("id", "")) == option_id:
			return o
	return {}


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_signal_buffer.clear()
	_floor_empty_streak = 0
	_floor_empty_total = 0
	_quiet_days = 0
	_today_admissions.clear()
	EvSave.reset()

# --- Public entries --------------------------------------------------------

## Ask for a card by id, from outside the tick. The Sales tab's two buttons are the production
## callers: a player pressing "İlgilen →" is a legitimate second ENTRY POINT, and must not be a
## second ADMISSION path (I1).
##
## So it proposes like anything else. The gate applies every step, the latch is spent, and a
## duplicate is refused by the queue rather than by the caller checking a private field first —
## which is what sales_tab.gd used to do, reaching into EventManager._active_event_id from a
## tab to make its own push safe.
##
## Returns true when the card was admitted AND reached the screen.
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
## card still has to be real content, still has to fill its slots, and still has to make sense
## in the current world. A "force" that skipped scope resolution would hand the executor an
## unbound slot and the effects would silently no-op, which is a worse test than no test.
##
## Writes history with `forced: true`, so a run log can tell a forced fire from a played one.
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


## Ids admitted through force_fire this run, so resolution can stamp history correctly.
static var _forced: Array = []


static func was_forced(event_id: String) -> bool:
	return _forced.has(event_id)


## The player picked a paper off the desk. §11.4: "Kağıt açıldığında modal gibi davranır (zaman
## durur), kapatıldığında masaya döner."
##
## It does NOT go through the gate again in full: the card was already admitted, its latch is
## already spent, and re-charging either would let a paper die on a rule it has already passed
## (§4.4 excludes G3 and G8 from display-time re-validation for exactly this reason). What it
## DOES re-check is G5/G6/G7 — days may have passed on the desk, and the employee the card is
## about may have resigned in the meantime.
static func open_paper(event_id: String) -> bool:
	if not EvPapers.has(event_id):
		return false
	if EvQueue.active_id() != "":
		return false                       # one modal at a time (§11.3)
	var context: Dictionary = EvPapers.context_of(event_id)
	var verdict: EvGate.Verdict = EvGate.revalidate(event_id, context)
	if not verdict.admitted:
		# The world moved while it sat there. Silent to the player, loud in the log, and
		# history says `dropped` with the gate step that refused it — so the debug panel can
		# explain a paper that vanished off the desk.
		EvPapers.remove(event_id)
		EvQueue.remove(event_id)
		EvHistory.record(event_id, EvHistory.RESOLUTION_DROPPED, "", verdict.step, context, [])
		return false
	EvPapers.mark_opened(event_id)
	EvQueue.set_active(event_id, context)
	_announce(event_id, context)
	return true
