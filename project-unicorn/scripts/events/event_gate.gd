class_name EventGate
extends RefCounted

# THE single address for the event layer. Every system, tab, modal, autoload and harness in
# the game talks to the event engine through this file and through nothing else.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# THE SWAP HAPPENED HERE (2026-08-25)
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# This file landed first as a pure forward to the old `EventManager`, so that ~30 call sites
# could be repointed while behaviour was byte-identical. That was the whole plan: make the
# migration reversible before making it.
#
# It now forwards to the new engine instead, and the diff that performed the swap is this
# file's body. Nothing else in the game changed shape on that day.
#
# WHY NOT TWO ENGINES SIDE BY SIDE, which was the original plan and was overturned on evidence:
# `main.gd:2275-2290` mounts the event modal with NO null guard — alone among that file's eight
# modal openers — and is safe only because exactly one `_active` exists. Two engines orphan a
# `Control` in `ModalLayer`; `game_shell.gd:151-153` then guards on a child COUNT, so Space,
# 1/2/3 and Esc die permanently; and `event_modal.gd` has no `ui_cancel`, so there is no
# keyboard way out. No pause, no menu, no save, no quit.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# THE ADMISSION API CHANGED SHAPE, AND THAT IS THE POINT
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# Before: `propose(ev: GameEvent)` — a caller BUILT a card and handed it over.
# After:  `request(event_id: String, context)` — a caller NAMES a card and the gate decides.
#
# The old shape is what made the bypass possible: if a caller can construct a card, the card's
# own declared rules are whatever the caller remembered to honour, which is how `one_shot` and
# `cooldown_days` came to be dead fields on nineteen injection sites. A caller that can only
# name an id cannot smuggle anything past the gate.

# --- Admission -------------------------------------------------------------

## Ask for a card by id. The gate decides; the caller does not.
##
## Returns true when it was admitted. Almost nothing needs the return value — the two Sales
## tab buttons use it to decide whether to flash a "nothing to do" affordance.
##
## `context` is a HINT, not an instruction: the gate still type-checks it (§4.3), because a
## caller passing the wrong kind of id is a bug in the caller and binding it anyway would make
## the card lie about its own subject.
static func request(event_id: String, context: Dictionary = {}) -> bool:
	return EvEngine.request(event_id, context)


## Resolve the ACTIVE card. Any other id is rejected — the double-click guard.
##
## `option` is either the option's ID or its INDEX in the rendered card, and the second shape
## is not a convenience: `event_modal.gd` renders a list of rows and knows which ROW was
## clicked, not what that row is called. Turning the index back into an id is the adapter's
## job, in the one place that also built the list — asking every caller to carry both would
## make the modal look up an id it has no other use for.
static func resolve(event_id: String, option: Variant) -> void:
	EvEngine.resolve(event_id, option_id_of(event_id, option))


## The option id `option` names — pass-through for a String, positional lookup for an int.
## Out of range returns "", which EvEngine.resolve refuses rather than guessing.
static func option_id_of(event_id: String, option: Variant) -> String:
	if typeof(option) == TYPE_STRING or typeof(option) == TYPE_STRING_NAME:
		return String(option)
	var options: Array = EvCatalog.card(event_id).get("options", [])
	var idx: int = int(option)
	if idx < 0 or idx >= options.size():
		return ""
	return String((options[idx] as Dictionary).get("id", ""))


## Debug and smoke only (§4.5). Skips G3, G4 and G8; does NOT skip G1, G2, G5, G6 or G7, and
## still writes history with `forced: true`. Unreachable in a release build.
static func force_fire(event_id: String, context: Dictionary = {}) -> bool:
	if not OS.is_debug_build():
		push_error("[EventGate] force_fire is not available in a release build")
		return false
	return EvEngine.force_fire(event_id, context)


# --- State the rest of the game arbitrates on ------------------------------

static func active_id() -> String:
	return EvQueue.active_id()


## The active card's frozen scope binding. The modal needs it to re-check option locks.
static func active_context() -> Dictionary:
	return EvQueue.active_context()


static func active_card() -> GameEvent:
	# The renderable view, built fresh from the card and the live locale. Never stored — the
	# queue holds ids, which is what makes a mid-run language switch safe (§3.2).
	var id: String = EvQueue.active_id()
	if id == "":
		return null
	return EvPresenter.build_view(id, EvQueue.active_context())


static func has_pending() -> bool:
	return EvQueue.active_id() != "" or EvQueue.size() > 0


static func queue_size() -> int:
	return EvQueue.size()


## Every resolution this run. The thing the old engine wrote and nobody could read.
static func history() -> Array:
	return EvHistory.rows()


static func is_catalogued(event_id: String) -> bool:
	return EvCatalog.has_card(event_id)


# --- Condition vocabulary --------------------------------------------------

## Evaluate one condition tree. NOT event-only: PhaseGateSystem gates both phase transitions
## with it and EventModal re-runs it at render time to decide whether an option is locked.
## `context` binds the card's scope slots, and an `entity_seam` leaf is meaningless without
## it. It defaults to empty because most callers ask GLOBAL questions (the phase gate's own
## conditions read nothing entity-scoped); a caller re-checking an option lock passes the
## card's frozen context, which is what makes "this account has spent both discounts" a
## question about THAT account rather than about no account at all.
static func condition_met(condition: Dictionary, context: Dictionary = {}) -> bool:
	return EvCondition.eval(condition, context)


## Every leaf in a tree, in authoring order.
##
## Exists because `phase_gate_system.gd:200-215` does not merely EVALUATE the gate condition —
## it walks the array switching on each leaf's type to build the player-facing Series A readout
## (mrr_ok, streak, brand_ok, progress). That code consumes the vocabulary's SHAPE, and nesting
## would have broken it silently. It shipped in the same phase nesting did, for that reason.
static func condition_leaves(condition: Dictionary) -> Array:
	return EvCondition.leaves(condition)


## The blame tree behind a refusal: which leaves failed, and what the seams behind them read at
## the moment they did. §5.4, and the substance of the "why didn't this fire" panel.
static func condition_report(condition: Dictionary) -> Dictionary:
	return EvCondition.explain(condition)


# --- Queue surgery ---------------------------------------------------------

static func remove_queued(event_id: String) -> void:
	EvQueue.remove(event_id)
	EvPapers.remove(event_id)


## Terminal reached: queued cards die with the run. The ACTIVE card is deliberately left alone —
## an open modal resolves normally.
static func flush() -> void:
	EvQueue.flush()


# --- Lifecycle -------------------------------------------------------------

## The player picked a paper off the desk. §11.4: it behaves like a modal while it is open and
## goes back to the desk when closed. Returns false when the world moved while it sat there —
## the paper is removed and history says `dropped` with the gate step that refused it.
static func open_paper(event_id: String) -> bool:
	return EvEngine.open_paper(event_id)


## The desk, most urgent first, capped at the sealed layout's slot count. `overflow` is what
## did not fit — and by construction nothing inside its last three days is ever in it, because
## EvPapers.ordered() sorts by days remaining.
static func desk_papers(slots: int = 3) -> Array:
	return EvPresenter.desk_papers(slots)


static func desk_overflow(slots: int = 3) -> int:
	return EvPresenter.desk_overflow(slots)


static func reset() -> void:
	EvEngine.reset()


static func to_dict() -> Dictionary:
	return EvSave.to_dict()


static func from_dict(d: Dictionary) -> void:
	EvSave.from_dict(d)


static func daily_tick() -> void:
	EvEngine.daily_tick()


static func hourly_tick(hour: int) -> void:
	EvEngine.hourly_tick(hour)


# --- Test seams ------------------------------------------------------------
#
# The smoke suite reached into the old engine's private fields, which is why sixteen of its
# lines could not be repointed mechanically. Naming what a test wants is what lets the test
# survive the engine underneath it being replaced — as these did.

static func queued_ids() -> Array:
	return EvQueue.ids()


static func queued_cards() -> Array:
	var out: Array = []
	for entry in EvQueue.entries():
		out.append(EvPresenter.build_view(String((entry as Dictionary)["event_id"]),
			(entry as Dictionary)["context"]))
	return out


static func instances_of(event_id: String) -> int:
	var n: int = 1 if EvQueue.active_id() == event_id else 0
	for id in EvQueue.ids():
		if String(id) == event_id:
			n += 1
	return n


static func queue_position_of(event_id: String) -> int:
	var ids: Array = EvQueue.ids()
	return ids.find(event_id)


## The renderable view of any card, with a context the caller supplies. Production only ever
## renders the ACTIVE card (active_card above); this is for the harnesses and the screenshot
## flags, which need to look at a card without admitting it.
static func render(event_id: String, context: Dictionary = {}) -> GameEvent:
	return EvPresenter.build_view(event_id, context)


## Bind a card's scope slots against the world as it is, without proposing anything. Returns
## an empty context when a required slot cannot fill — which for a harness is the answer, not
## an error.
static func bind_scope(event_id: String) -> Dictionary:
	var result: Dictionary = EvScope.resolve(EvCatalog.card(event_id).get("scope", {}))
	return result.get("context", {}) if bool(result.get("ok", false)) else {}


static func catalogue_card(event_id: String) -> Dictionary:
	return EvCatalog.card(event_id)


static func debug_apply_effects(effects: Array, context: Dictionary = {}) -> void:
	EvEffects.run_played(effects, context)


## Per-hour probability reproducing a per-DAY probability over `window_hours` independent rolls.
## Pure function. It survived the swap because a smoke case pins its exact arithmetic, and the
## arithmetic did not stop being true when the engine around it changed.
static func hourly_chance(p_day: float, window_hours: int) -> float:
	var p: float = clampf(p_day, 0.0, 1.0)
	if window_hours <= 1 or p >= 1.0:
		return p
	return 1.0 - pow(1.0 - p, 1.0 / float(window_hours))
