class_name EvGate
extends RefCounted

# THE SINGLE ADMISSION GATE (GDD §4, invariant I1).
#
# There is one way a card becomes showable and this is it. Not "one preferred way" — one way.
# The old engine had three (event_manager.gd:159, :200, :217), and two of them skipped the
# eligibility pass entirely, which meant one_shot, cooldown_days, allowed_hours, the build-safe
# gate and every trigger condition were DEAD FIELDS on all 19 injection sites. Nineteen systems
# each re-implemented the missing brake in their own vocabulary, seventeen of them successfully.
#
# I1 is enforced structurally, not by convention: the Queue is private to EventEngine and
# nothing outside this file can put a card in it. There is no public show(). GDScript has no
# `private`, so "the only caller is in this file" is the strongest available form — and the
# linter's §17.9 rule makes the second path unwritable rather than merely discouraged.
#
# THE LINE (§4.1)
#
#   signal / tick / arc step / schedule
#           ↓
#     propose(event_id, origin, context)      ← the only public entry
#           ↓
#     G1  is this real content
#     G2  does this build ship it, and is a tutorial suppressing it
#     G3  latch                     (one_shot / max_fires / cooldown)
#     G4  tick, phase window, allowed_hours, build-safe
#     G5  scope                     (can the slots fill, with the right types)
#     G6  guards                    (market, subtype, portfolio, phase)
#     G7  condition tree
#     G8  tempo                     ← NEVER REJECTS. Demotes the class. (P5)
#           ↓
#     admit → Queue, with the context FROZEN
#           ↓
#     at display: G5, G6, G7 again  ← §4.4
#
# WHY G5 SOMETIMES RUNS BEFORE G3, which §4.1's list does not say and which is a real
# deviation recorded in §27: an `entity`-keyed latch is keyed on the SUBJECT, and the subject
# comes from scope resolution. So for latch_key: entity the order is G5 then G3; for
# latch_key: run — the default and the majority — G3 stays first, where it is cheap and kills
# most of the corpus on most days. The intent of the ordering (cheap filters first) is kept;
# the dependency is honoured.
#
# G3 AND G8 DO NOT RE-RUN AT DISPLAY (§4.4). A card admitted yesterday already spent its
# cooldown, and its class was decided when it was admitted. Re-charging either would let a
# queued card die on a rule it has already passed.

enum Origin { TICK_DAILY, TICK_HOURLY, SIGNAL, SCHEDULE, ARC_STEP, POOL, FLOOR, FORCE, REQUEST }

const ORIGIN_NAMES := {
	Origin.TICK_DAILY: "tick_daily", Origin.TICK_HOURLY: "tick_hourly",
	Origin.SIGNAL: "signal", Origin.SCHEDULE: "schedule", Origin.ARC_STEP: "arc_step",
	Origin.POOL: "pool", Origin.FLOOR: "floor", Origin.FORCE: "force",
	Origin.REQUEST: "request",
}

## §20 B10: undeclared means daytime. A card that says nothing about its hour is not a card
## that fires at 03:00.
const DEFAULT_ALLOWED_HOURS := [8, 20]


## The verdict. `admitted` plus, when it is false, exactly which step said no and why — which
## is the whole substance of the "why didn't this fire" panel (§19.2). A gate that only
## returned a bool would force the panel to re-derive the answer and risk disagreeing with it.
class Verdict:
	var admitted: bool = false
	var step: String = ""              ## "G4" etc, "" when admitted
	var reason: String = ""            ## human-readable, dev-facing
	var context: Dictionary = {}       ## the resolved scope, frozen on admission
	var card_class: String = ""
	var report: Dictionary = {}        ## EvCondition.explain output when G7 refused

	func _init(ok: bool = false) -> void:
		admitted = ok

	static func refuse(gate_step: String, why: String, ctx: Dictionary = {},
			cond_report: Dictionary = {}) -> Verdict:
		var v := Verdict.new(false)
		v.step = gate_step
		v.reason = why
		v.context = ctx
		v.report = cond_report
		return v


# --- The only public entry -------------------------------------------------

## Offer a card. Returns a Verdict; the caller does not decide anything.
##
## `given` is what the proposer already knows — a signal's payload, an arc's remembered
## subject. It is a HINT: G5 still type-checks it, because a signal carrying the wrong kind of
## id is a bug in the emitter and binding it anyway would make the card lie about its subject.
static func propose(event_id: String, origin: Origin, given: Dictionary = {}) -> Verdict:
	var forced: bool = origin == Origin.FORCE

	# G1 — is this real content
	if not EvCatalog.has_card(event_id):
		return Verdict.refuse("G1", "no card with id '%s' in the catalogue" % event_id)
	var card: Dictionary = EvCatalog.card(event_id)

	# G2 — version scope and tutorial suppression
	if not forced:
		var g2: String = _g2_scope(card)
		if g2 != "":
			return Verdict.refuse("G2", g2)

	# Entity-keyed latches need the subject first; see the header.
	var entity_keyed: bool = String(card["latch_key"]) == EvLatches.KEY_ENTITY
	var scope_result: Dictionary = {}

	if entity_keyed:
		scope_result = EvScope.resolve(card["scope"], given)
		if not scope_result["ok"]:
			return Verdict.refuse("G5", "slot '%s' could not be filled" % scope_result["unresolved"])

	# G3 — latch
	if not forced:
		var key: String = EvLatches.key_for(event_id, card["latch_key"],
			_subject_of(scope_result.get("context", {})))
		var g3: String = EvLatches.blocked_reason(card["latch"], key)
		if g3 != "":
			return Verdict.refuse("G3", g3)

	# G4 — tick, window, build-safe
	if not forced:
		var g4: String = _g4_window(card, origin)
		if g4 != "":
			return Verdict.refuse("G4", g4)

	# G5 — scope (unless already resolved above)
	if not entity_keyed:
		scope_result = EvScope.resolve(card["scope"], given)
		if not scope_result["ok"]:
			# §4.3: a silent refusal, logged, never an error and never a guess.
			return Verdict.refuse("G5", "slot '%s' could not be filled" % scope_result["unresolved"])
	var context: Dictionary = scope_result["context"]

	# G6 — guards
	var g6: String = _g6_guards(card)
	if g6 != "":
		return Verdict.refuse("G6", g6, context)

	# G7 — the condition tree
	var condition: Dictionary = card.get("condition", {})
	if not condition.is_empty():
		var report: Dictionary = EvCondition.explain(condition, context)
		if not bool(report["passed"]):
			return Verdict.refuse("G7", "condition not met", context, report)

	# Admitted. G8 assigns the presentation class at pump time, over the whole day's
	# admissions at once — see EvTempo. Until then the card keeps the class it declared.
	var v := Verdict.new(true)
	v.context = context
	v.card_class = String(card["class"])
	return v


## Re-run the display-time subset (§4.4). Days can pass between admission and display: the
## employee resigned, the contract ended, the phase moved. G3 and G8 are deliberately absent.
static func revalidate(event_id: String, context: Dictionary) -> Verdict:
	if not EvCatalog.has_card(event_id):
		return Verdict.refuse("G1", "card vanished from the catalogue")
	var card: Dictionary = EvCatalog.card(event_id)

	# G5 — is the subject still alive
	if not EvScope.still_valid(context):
		return Verdict.refuse("G5", "entity gone from slot '%s'"
			% EvScope.first_dead_slot(context), context)

	var g6: String = _g6_guards(card)
	if g6 != "":
		return Verdict.refuse("G6", g6, context)

	var condition: Dictionary = card.get("condition", {})
	if not condition.is_empty():
		var report: Dictionary = EvCondition.explain(condition, context)
		if not bool(report["passed"]):
			return Verdict.refuse("G7", "condition no longer met", context, report)

	var v := Verdict.new(true)
	v.context = context
	v.card_class = String(card["class"])
	return v


# --- G2: version scope and tutorial ----------------------------------------

static func _g2_scope(card: Dictionary) -> String:
	# Release tier. No such concept exists in the codebase yet, so the default is "ships" and
	# the field is forward-compatible: content marked ea/full stays out of a demo pool without
	# anyone having to build a tier system first. Same shape as the tutorial hook below —
	# separating a mode now is free, retrofitting it is not.
	var scope: String = String(card.get("version_scope", "demo"))
	if not EvTuning.SHIPPED_SCOPES.has(scope):
		return "version_scope '%s' does not ship in this build" % scope

	# §11.6 tutorial suppression. While the flag is up the pool is silent and only tutorial
	# cards pass. The engine carries the hook; it does not design the flow.
	if EvFlags.has("tutorial_active") and not (card["tags"] as Array).has("tutorial"):
		return "tutorial_active suppresses everything but tutorial cards"
	return ""


# --- G4: tick, window, build-safe ------------------------------------------

static func _g4_window(card: Dictionary, origin: Origin) -> String:
	var tick: String = String(card["tick"])

	# A card declares which clock it lives on, and the proposer must match it. The old engine
	# derived this instead: has_random_trigger() silently routed a card to the daily path or
	# the hourly one, which decided whether it was capped AND whether allowed_hours was
	# honoured at all. Adding a dice roll to a beat moved it into a different engine, quietly.
	match origin:
		Origin.TICK_DAILY:
			if tick != "daily":
				return "card is tick:%s, proposed from the daily tick" % tick
		Origin.TICK_HOURLY:
			if tick != "hourly":
				return "card is tick:%s, proposed from the hourly tick" % tick
		Origin.SIGNAL:
			if tick != "signal":
				return "card is tick:%s, proposed from a signal" % tick
		Origin.SCHEDULE:
			if tick != "scheduled" and tick != "daily":
				return "card is tick:%s, proposed from the schedule" % tick
		Origin.REQUEST:
			# DELIBERATELY UNCHECKED. `tick` says which clock SWEEPS a card, not who may name
			# it. A caller that names a card has already seen the edge — the Sales tab's
			# player, CustomerRepSystem's aged request, ProductSystem's ship. Refusing them on
			# the clock would mean every named card also had to be swept, which is the second
			# admission path this rebuild exists to delete.
			#
			# `tick: "request"` is the other half: a card no clock sweeps at all. The sweep and
			# the pool skip it because its tick matches neither "daily" nor "hourly", so being
			# named is the only way it can reach the player.
			pass

	# allowed_hours. THE DEFECT THIS FIXES: in the old engine the daily tick always ran at hour
	# 0 (time_manager.gd:138-144), and the hour gate read GameState.current_hour — so any
	# daily card given a window that excluded midnight was PERMANENTLY ineligible and nothing
	# said so. Now the window only governs cards that live on the hourly clock, where an hour
	# is a real thing, and a daily card carrying one is a lint error rather than a silent death.
	if tick == "hourly":
		var window: Array = card.get("allowed_hours", DEFAULT_ALLOWED_HOURS)
		if not _hour_in(GameState.current_hour, window):
			return "hour %d outside allowed_hours %s" % [GameState.current_hour, str(window)]

	# Build-safe. While a version is being built, only cards scoped to that build phase or
	# explicitly marked build_safe may interrupt.
	var active_build = ProductSystem.get_active_build()
	if active_build != null:
		var tags: Array = card["tags"]
		if not tags.has("build_safe") and not tags.has("critical"):
			var want_phase: String = String((card["guards"] as Dictionary).get("build_phase", ""))
			if want_phase == "" or want_phase != active_build.current_phase:
				return "a build is running and this card is not build_safe"
	return ""


static func _hour_in(hour: int, window: Array) -> bool:
	if window.size() != 2:
		return true
	var start_h: int = int(window[0])
	var end_h: int = int(window[1])
	if start_h <= end_h:
		return hour >= start_h and hour <= end_h
	return hour >= start_h or hour <= end_h      # wraps midnight


# --- G6: guards ------------------------------------------------------------

static func _g6_guards(card: Dictionary) -> String:
	var guards: Dictionary = card["guards"]
	if guards.is_empty():
		return ""

	# market. The guard that stops a B2C card reaching a B2B contract. §20 A7.
	if guards.has("market"):
		var want: String = String(guards["market"])
		var actual: String = ProductState.market_type()
		if actual == "":
			return "market guard '%s' but nothing has shipped yet" % want
		if actual != want:
			return "market is %s, card wants %s" % [actual, want]

	if guards.has("subtype"):
		var want_sub: String = String(guards["subtype"])
		if ProductState.subtype() != want_sub:
			return "subtype is %s, card wants %s" % [ProductState.subtype(), want_sub]

	if guards.has("phase"):
		var want_phase: Variant = guards["phase"]
		var phases: Array = want_phase if typeof(want_phase) == TYPE_ARRAY else [want_phase]
		if not phases.has(GameState.phase):
			return "phase is %d, card wants %s" % [GameState.phase, str(phases)]

	if guards.has("product_live"):
		var want_live: bool = bool(guards["product_live"])
		if ProductState.is_live() != want_live:
			return "product_live is %s, card wants %s" % [ProductState.is_live(), want_live]

	return ""


# --- Helpers ---------------------------------------------------------------

## The card's primary subject, for an entity-keyed latch: the first REQUIRED slot in
## declaration order. Declaration order is stable because Godot Dictionaries preserve
## insertion order, and a smoke case pins that so the latch key cannot silently change shape.
static func _subject_of(context: Dictionary) -> String:
	for slot_name in context:
		return String((context[slot_name] as Dictionary).get("id", ""))
	return ""


static func origin_name(origin: Origin) -> String:
	return String(ORIGIN_NAMES.get(origin, "?"))
