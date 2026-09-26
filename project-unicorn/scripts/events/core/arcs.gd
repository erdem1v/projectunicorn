class_name EvArcs
extends RefCounted

# ARCS (GDD §10). An arc OWNS a chain of cards, so a promise made on day 10 cannot be orphaned
# by one link's condition never coming true: a card dies, the arc lives, and when its subject
# leaves it applies a policy (§10.5) instead of evaporating (§0.2).
#
# The rules that keep an arc from dying quietly:
#   1. An arc step never enters the pool (§10.10) — EvCatalog.pool_candidates() excludes steps
#      structurally, and lint checks it too.
#   2. A promise arc may not fade and may not carry empty on_invalidate effects (§10.6).
#   3. An arc with a subject must declare invalidate_when (§10.4).
#   4. An arc-step card that can expire must carry an arc verb in on_expire: an arc never
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

## Start an arc. Returns true when it actually started. §10.9's two refusals (already running;
## ended and not restartable) are warnings, not errors — content may legitimately attempt both.
static func start(arc_id: String, subject: Dictionary = {}) -> bool:
	if not EvCatalog.has_arc(arc_id):
		push_error("[EvArcs] no arc definition '%s'" % arc_id)
		return false

	var definition: Dictionary = EvCatalog.arc(arc_id)
	var existing: Dictionary = _live.get(arc_id, {})
	if not existing.is_empty():
		if String(existing["state"]) != STATE_ENDED:
			push_warning("[EvArcs] '%s' is already running — start ignored" % arc_id)
			return false
		if not bool(definition.get("restartable", false)):
			push_warning("[EvArcs] '%s' has ended and is not restartable" % arc_id)
			return false

	# §10.7: one live arc per subject unless the definition opts out. The refused start is not
	# deferred — the card that wanted it proposes again tomorrow.
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
	if int(st["step"]) >= (EvCatalog.arc(arc_id).get("steps", []) as Array).size():
		end(arc_id, "completed")
	return int(st["step"])


## Close an arc with an outcome ID, never a label — a later card's {"arc": "ended", "outcome": …}
## must work in either language.
static func end(arc_id: String, outcome: String) -> void:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty():
		return
	st["state"] = STATE_ENDED
	st["outcome"] = outcome
	# Sweep every surface that could still show one of its cards, not only the schedule §20 G3
	# names — otherwise a queued step plays after the player watched the arc close.
	EvSchedule.drop_arc(arc_id)
	EvQueue.drop_arc(arc_id)
	EvPapers.drop_arc(arc_id)


static func abort(arc_id: String, reason: String) -> void:
	end(arc_id, "aborted:%s" % reason)


# --- Variables -------------------------------------------------------------

## Arc-local memory (§20 G4): flags are global and two arcs writing one would collide.
static func set_var(arc_id: String, key: String, value: Variant) -> void:
	var st: Dictionary = _live.get(arc_id, {})
	if st.is_empty():
		return
	(st["vars"] as Dictionary)[key] = value


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
## §10.9: a rehired old subject is a new entity with a new id, and the arc does not reattach —
## the person on screen never had the conversation the arc remembers.
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

## Pause without dying. The arc keeps its step and vars; its scheduled steps leave the global
## schedule and wait as RELATIVE days. A past-due schedule entry fires immediately (§20 B1), so
## keeping absolute days would dump every frozen step at once on resume.
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


## §10.5: after the timeout the policy falls to close, so the thread is tied off visibly.
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
		# An arc whose definition vanished has no steps and no policy; kept, it would sit live
		# forever holding its subject's slot. Dropped with a log, never a crash.
		if not EvCatalog.has_arc(arc_id):
			push_error("[EvArcs] save names arc '%s' with no definition — aborted (fade)" % arc_id)
			continue
		_live[arc_id] = (d["arcs"] as Dictionary)[arc_id]
