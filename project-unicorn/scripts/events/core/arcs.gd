class_name EvArcs
extends RefCounted

# ARCS (GDD §10). The object that carries the game's thesis.
#
# WHY AN ARC IS A SEPARATE THING AND NOT A CHAIN OF CARDS CALLING EACH OTHER BY ID (§2.1).
# A chain breaks in the middle and nobody finds out: one link's condition never comes true, the
# rest are orphaned, and the promise made on day 10 simply never pays. The arc OWNS the chain.
# A card dies; the arc lives. Its subject leaves the company and the arc knows, and applies a
# policy about it (§10.5) instead of evaporating.
#
# That is the difference between "we wrote a callback" and "the player can trust the game to
# remember", and it is the whole of §0.2.
#
# THE FOUR RULES THAT KEEP AN ARC FROM DYING QUIETLY
#
#   1. An arc step may never enter the pool (§10.10). If the pool drew a step, the step would
#      burn its own one_shot latch out of order and the arc could never run it — locked, with
#      no error. E-lint, and EvCatalog.pool_candidates() excludes arc steps structurally too,
#      because a rule enforced in one place is a rule with one place to forget.
#
#   2. A promise arc may not fade and may not carry empty on_invalidate effects (§10.6). If
#      something promised evaporates silently the player reads it as a bug, and the thesis
#      dies with the trust.
#
#   3. An arc with a subject must declare invalidate_when (§10.4). Not declaring it is not
#      "never invalidates", it is "nobody thought about the subject leaving".
#
#   4. NEW, and the GDD does not cover it — approved as amendment A1. An arc step can be
#      class: paper; papers expire; §10 says nothing about what that does to the arc. A payoff
#      card demoted to paper by the interrupt ceiling and then left unanswered would stall its
#      arc forever, which is rule 1's silent death coming back through the door. So: an
#      arc-step card that can expire MUST carry an arc verb in on_expire. An arc never
#      advances implicitly on expiry, and never stalls silently either.

const STATE_ACTIVE := "active"
const STATE_AWAITING := "awaiting_subject"
const STATE_ENDED := "ended"

const TYPE_PROMISE := "promise"
const TYPE_CHARACTER := "character"
const TYPE_WORLD := "world"
const TYPE_ASSIGNMENT := "assignment"

const POLICY_REASSIGN := "reassign"
const POLICY_CLOSE := "close"
const POLICY_FADE := "fade"

## arc_id -> runtime state. §16.1 serialises this whole dictionary.
static var _live: Dictionary = {}


# --- Lifecycle -------------------------------------------------------------

## Start an arc. Returns true when it actually started.
##
## §10.9's two refusals are both no-ops with a warning rather than errors, because both are
## things content can legitimately attempt: an arc already running, and an arc that has ended
## and is not restartable. Neither is a crash; both are worth seeing in a log.
static func start(arc_id: String, subject: Dictionary = {}) -> bool:
	if not EvCatalog.has_arc(arc_id):
		push_error("[EvArcs] no arc definition '%s'" % arc_id)
		return false

	var existing: Dictionary = _live.get(arc_id, {})
	if not existing.is_empty():
		if String(existing["state"]) != STATE_ENDED:
			push_warning("[EvArcs] '%s' is already running — start ignored" % arc_id)
			return false
		if not bool(EvCatalog.arc(arc_id).get("restartable", false)):
			push_warning("[EvArcs] '%s' has ended and is not restartable" % arc_id)
			return false

	var definition: Dictionary = EvCatalog.arc(arc_id)

	# §10.7: one live arc per subject unless the definition opts out. The second arc is not
	# queued for later — with a per-tick sweep the card that wanted to start it simply fails
	# its own condition and proposes again tomorrow, for free. A deferral queue would be a
	# second scheduler to keep in step with the first.
	if not subject.is_empty() and not bool(definition.get("allow_concurrent", false)):
		var holder: String = arc_on_subject(String(subject.get("id", "")))
		if holder != "" and holder != arc_id:
			push_warning("[EvArcs] subject %s already carries arc '%s'"
				% [subject.get("id", ""), holder])
			return false

	_live[arc_id] = {
		"id": arc_id,
		"type": String(definition.get("type", TYPE_WORLD)),
		"subject": subject.duplicate(true),
		"step": 0,
		"vars": {},
		"started_day": GameState.day,
		"state": STATE_ACTIVE,
		"outcome": "",
		"awaiting_since": -1,
		"frozen_schedule": [],
	}
	return true


## Move to the next step, or to an explicit one. Returns the new step index, or -1 when the arc
## is not running.
static func advance(arc_id: String, step: int = -1) -> int:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty() or String(st["state"]) != STATE_ACTIVE:
		return -1
	st["step"] = int(st["step"]) + 1 if step < 0 else step
	var steps: Array = EvCatalog.arc(arc_id).get("steps", [])
	if int(st["step"]) >= steps.size():
		end(arc_id, "completed")
		return int(st["step"])
	return int(st["step"])


## Close an arc with an outcome. The outcome is an ID, never a label — a later card asks
## {"arc": "ended", "id": …, "outcome": …} and that has to work in either language.
static func end(arc_id: String, outcome: String) -> void:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty():
		return
	st["state"] = STATE_ENDED
	st["outcome"] = outcome
	_sweep(arc_id)


## Abort without an outcome. §20 G3 says abort clears its scheduled steps; it must clear MORE
## than that — see _sweep.
static func abort(arc_id: String, reason: String) -> void:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty():
		return
	st["state"] = STATE_ENDED
	st["outcome"] = "aborted:%s" % reason
	_sweep(arc_id)


## Remove every trace of a dead arc from every surface that could still show one of its cards.
##
## §16.1 lists queue[], papers[], schedule[] and ticker_queue as SEPARATE arrays, and §20 G3
## only mentions the schedule. Sweeping one of four is how a close-policy arc fires its visible
## closing card while a queued step of the same arc is still sitting behind it — the player
## watches the arc close, and then watches it continue.
static func _sweep(arc_id: String) -> void:
	EvSchedule.drop_arc(arc_id)
	EvQueue.drop_arc(arc_id)
	EvPapers.drop_arc(arc_id)


# --- Variables -------------------------------------------------------------

## Arc-local memory. §20 G4: flags are global, so two arcs writing the same flag collide;
## anything that belongs to ONE arc lives here instead.
static func set_var(arc_id: String, key: String, value: Variant) -> void:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty():
		return
	(st["vars"] as Dictionary)[key] = value


static func get_var(arc_id: String, key: String, fallback: Variant = null) -> Variant:
	return ((_live.get(arc_id, {}) as Dictionary).get("vars", {}) as Dictionary).get(key, fallback)


# --- Subject handling ------------------------------------------------------

static func subject_of(arc_id: String) -> Dictionary:
	return (_live.get(arc_id, {}) as Dictionary).get("subject", {})


static func subject_id(arc_id: String) -> String:
	return String(subject_of(arc_id).get("id", ""))


## Which live arc holds this subject, or "". §10.7's per-subject limit reads it.
static func arc_on_subject(entity_id: String) -> String:
	if entity_id == "":
		return ""
	for arc_id in _live:
		var st: Dictionary = _live[arc_id]
		if String(st["state"]) == STATE_ENDED:
			continue
		if String((st["subject"] as Dictionary).get("id", "")) == entity_id:
			return arc_id
	return ""


## Bind a new subject to an arc that was waiting for one, and resume it.
##
## §10.9 is emphatic about what this is NOT: if the OLD subject comes back — the employee is
## rehired — that is a new entity with a new id and the arc does not reattach. A rehire is a
## different person to the fiction, and pretending otherwise would have the game remember a
## conversation that the person on screen never had.
static func reassign_subject(arc_id: String, subject: Dictionary) -> bool:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty() or String(st["state"]) != STATE_AWAITING:
		return false
	st["subject"] = subject.duplicate(true)
	st["state"] = STATE_ACTIVE
	st["awaiting_since"] = -1
	_thaw_schedule(arc_id)
	return true


# --- The three invalidation policies (§10.5) -------------------------------

## Pause without dying. The arc keeps its step and its vars; its scheduled steps come out of
## the global schedule and wait as RELATIVE days.
##
## Why relative: §16.3 says every day field is an absolute game day, and §20 B1 says a schedule
## entry whose day has passed fires immediately rather than being skipped. Both are right, and
## together they mean a frozen arc resumed after nine days would dump every frozen step at
## once. Storing remaining_days on the arc and re-materialising absolute days on resume keeps
## the global schedule purely absolute and makes the frozen state explicit instead of implied.
static func pause_for_subject(arc_id: String) -> void:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty() or String(st["state"]) != STATE_ACTIVE:
		return
	st["state"] = STATE_AWAITING
	st["awaiting_since"] = GameState.day
	st["frozen_schedule"] = EvSchedule.freeze_arc(arc_id)


static func _thaw_schedule(arc_id: String) -> void:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty():
		return
	EvSchedule.thaw_arc(arc_id, st.get("frozen_schedule", []))
	st["frozen_schedule"] = []


## §10.5: an arc does not wait for a new subject forever. After the timeout the policy falls to
## close, so the thread is tied off visibly rather than hanging for the rest of the run.
static func awaiting_timed_out(arc_id: String) -> bool:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty() or String(st["state"]) != STATE_AWAITING:
		return false
	var since: int = int(st["awaiting_since"])
	return since >= 0 and (GameState.day - since) >= EvTuning.ARC_AWAITING_SUBJECT_TIMEOUT_DAYS


# --- State reads (EvCondition's arc leaves) --------------------------------

static func state_of(arc_id: String) -> String:
	return String((_live.get(arc_id, {}) as Dictionary).get("state", ""))


static func step_of(arc_id: String) -> int:
	return int((_live.get(arc_id, {}) as Dictionary).get("step", -1))


static func outcome_of(arc_id: String) -> String:
	return String((_live.get(arc_id, {}) as Dictionary).get("outcome", ""))


static func is_active(arc_id: String) -> bool:
	return state_of(arc_id) == STATE_ACTIVE


static func started_day(arc_id: String) -> int:
	return int((_live.get(arc_id, {}) as Dictionary).get("started_day", -1))


static func live_ids() -> Array:
	var ids: Array = []
	for arc_id in _live:
		if String((_live[arc_id] as Dictionary)["state"]) != STATE_ENDED:
			ids.append(arc_id)
	ids.sort()
	return ids


static func all_ids() -> Array:
	var ids: Array = _live.keys()
	ids.sort()
	return ids


static func snapshot(arc_id: String) -> Dictionary:
	return (_live.get(arc_id, {}) as Dictionary).duplicate(true)


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_live.clear()


static func to_dict() -> Dictionary:
	return {"arcs": _live.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	for arc_id in (d.get("arcs", {}) as Dictionary):
		# §16.4 covers a save naming an event_id the catalogue no longer has. It does not cover
		# a vanished ARC definition, and that is the more dangerous one: an arc with no
		# definition has no steps to run and no policy to apply, so it would sit live forever
		# holding its subject's per-subject slot. Approved directive: abort with fade, log,
		# never crash.
		if not EvCatalog.has_arc(arc_id):
			push_error("[EvArcs] save names arc '%s' with no definition — aborted (fade)" % arc_id)
			continue
		_live[arc_id] = (d["arcs"] as Dictionary)[arc_id]
