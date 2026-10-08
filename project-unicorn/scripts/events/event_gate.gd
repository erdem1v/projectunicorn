class_name EventGate
extends RefCounted

# The single address for the event layer: every system, tab, modal, autoload and harness talks
# to the event engine through this file and nothing else.
#
# A caller NAMES a card (`request(event_id, context)`) and the gate decides. A caller that could
# BUILD a card would bypass the card's own rules (one_shot, cooldown); one that can only name an
# id cannot smuggle anything past the gate.

# --- Admission -------------------------------------------------------------

## Ask for a card by id. Returns true when it was admitted, or when this instance's waiting paper was
## opened instead (the Sales tab buttons use it).
## `context` names the card's subjects: the gate binds them or refuses the card (§4.3).
static func request(event_id: String, context: Dictionary = {}) -> bool:
	return EvEngine.request(event_id, context)


## Resolve the ACTIVE card; any other id is rejected (double-click guard). `option` is the
## option's id or its INDEX in the rendered card — the modal knows which row was clicked, not
## what it is called. Out of range becomes "", which EvEngine.resolve refuses.
static func resolve(event_id: String, option: Variant) -> void:
	var option_id: String = ""
	if typeof(option) == TYPE_STRING or typeof(option) == TYPE_STRING_NAME:
		option_id = String(option)
	else:
		var options: Array = EvCatalog.card(event_id).get("options", [])
		var idx: int = int(option)
		if idx >= 0 and idx < options.size():
			option_id = String((options[idx] as Dictionary).get("id", ""))
	EvEngine.resolve(event_id, option_id)


## Debug and smoke only (§4.5). Skips G3, G4 and G8; still runs G1, G2, G5, G6, G7 and writes
## history with `forced: true`.
static func force_fire(event_id: String, context: Dictionary = {}) -> bool:
	if not OS.is_debug_build():
		push_error("[EventGate] force_fire is not available in a release build")
		return false
	return EvEngine.force_fire(event_id, context)


# --- State the rest of the game arbitrates on ------------------------------

static func active_id() -> String:
	return EvQueue.active_id()


## The active card is a paper the player picked up off the desk; it may go back unanswered.
static func active_from_desk() -> bool:
	return EvQueue.active_from_desk()


## True while the chosen option's effects run: a sitting the option opens is the card's own, so
## the decision gate lets it through.
static func resolving() -> bool:
	return EvEngine.resolving()


## The active card's frozen scope binding. The modal needs it to re-check option locks.
static func active_context() -> Dictionary:
	return EvQueue.active_context()


## Built fresh from the card in the live locale, never stored (§3.2).
static func active_card() -> GameEvent:
	var id: String = EvQueue.active_id()
	if id == "":
		return null
	return EvPresenter.build_view(id, EvQueue.active_context())


static func has_pending() -> bool:
	return EvQueue.active_id() != "" or EvQueue.size() > 0


static func queue_size() -> int:
	return EvQueue.size()


## Every resolution, oldest first (§7.1's rows); the inbox lists the played and expired ones.
static func history() -> Array:
	return EvHistory.rows()


static func is_catalogued(event_id: String) -> bool:
	return EvCatalog.has_card(event_id)


# --- Condition vocabulary --------------------------------------------------

## Evaluate one condition tree. Not event-only: PhaseGateSystem gates phase transitions with it
## and the inbox's reading pane re-checks option locks. `context` binds the card's scope slots; an
## `entity_seam` leaf has no subject without it.
static func condition_met(condition: Dictionary, context: Dictionary = {}) -> bool:
	return EvCondition.eval(condition, context)


## Every leaf in a tree, in authoring order. PhaseGateSystem walks the leaves to build the
## Series A readout, so it consumes the vocabulary's shape, not just its verdict.
static func condition_leaves(condition: Dictionary) -> Array:
	return EvCondition.leaves(condition)


## The player-facing sentence for a refusal, or "" when the content authored none for the clause
## that actually failed. Pass the card's context, or an `entity_seam` leaf reads false for
## everyone and the wrong clause gets blamed.
static func condition_reason(condition: Dictionary, context: Dictionary = {}) -> String:
	return EvCondition.reason_of(EvCondition.explain(condition, context))


# --- Queue surgery ---------------------------------------------------------

## Drops every queued instance of the card; on the desk only a run-keyed card's paper has this id.
static func remove_queued(event_id: String) -> void:
	EvQueue.remove(event_id)
	EvPapers.remove(event_id)


## Terminal reached: queued cards die with the run. The ACTIVE card is left alone — an open modal
## resolves normally.
static func flush() -> void:
	EvQueue.flush()


# --- Lifecycle -------------------------------------------------------------

## The player picked a paper off the desk (§11.4); `key` is the desk entry's id (desk_papers "id").
## Returns false when the world moved while it sat there — the paper is removed and history says
## `dropped`.
static func open_paper(key: String) -> bool:
	return EvEngine.open_paper(key)


## Puts the opened paper back on the desk unanswered (§11.4): no history row, its clock still
## running. False when the active card did not come off the desk; an interrupt is answered.
static func set_aside() -> bool:
	return EvEngine.set_aside()


## Shows the top queued card when none is showing. A load restores the queue and nothing pumps
## it before the next tick, so main pumps once the loaded run stands.
static func pump() -> void:
	EvEngine.pump()


## The desk, most urgent first, capped at the layout's slot count (the whole desk without one).
static func desk_papers(slots := -1) -> Array:
	return EvPresenter.desk_papers(slots)


static func reset() -> void:
	EvEngine.reset()


static func daily_tick() -> void:
	EvEngine.daily_tick()


static func hourly_tick(hour: int) -> void:
	EvEngine.hourly_tick(hour)


# --- Test seams ------------------------------------------------------------
#
# Named so a test says what it wants instead of reaching into engine internals.

static func queued_ids() -> Array:
	return EvQueue.ids()


static func instances_of(event_id: String) -> int:
	var n: int = 1 if EvQueue.active_id() == event_id else 0
	return n + EvQueue.ids().count(event_id)


static func queue_position_of(event_id: String) -> int:
	return EvQueue.ids().find(event_id)


## Any card's view with a caller-supplied context, without admitting it: the inbox's papers and
## past decisions (with the names they kept) and the shot flags.
static func render(event_id: String, context: Dictionary = {}, names: Dictionary = {}) -> GameEvent:
	return EvPresenter.build_view(event_id, context, names)


## Bind a card's scope slots against the world as it is; a `given` slot binds that id instead of
## running its selector. Empty when a required slot cannot fill or a given id does not bind.
static func bind_scope(event_id: String, given: Dictionary = {}) -> Dictionary:
	var result: Dictionary = EvScope.resolve(EvCatalog.card(event_id).get("scope", {}), given)
	return result.get("context", {}) if bool(result.get("ok", false)) else {}


static func catalogue_card(event_id: String) -> Dictionary:
	return EvCatalog.card(event_id)


static func debug_apply_effects(effects: Array, context: Dictionary = {}) -> void:
	EvEffects.run_played(effects, context)


## Per-hour probability reproducing a per-DAY probability over `window_hours` independent rolls.
static func hourly_chance(p_day: float, window_hours: int) -> float:
	var p: float = clampf(p_day, 0.0, 1.0)
	if window_hours <= 1 or p >= 1.0:
		return p
	return 1.0 - pow(1.0 - p, 1.0 / float(window_hours))
