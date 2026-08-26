class_name EvSignals
extends RefCounted

# THE ENGINE'S EARS. One place where an EventBus signal becomes a proposal, and an allowlist
# rather than a convention — the same discipline as the seam registry, for the same reason.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHY A TABLE AND NOT A LOOP OVER EventBus
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# A signal carries positional arguments; a card carries NAMED scope slots. Nothing in
# `signal customer_health_changed(customer_id: String, phase: String)` says that the first
# argument is a CUSTOMER id and not, say, a company name — and binding it into a `customer`
# slot on a guess is exactly how a card comes to be about the wrong subject. So each binding
# says which argument fills which slot, by hand, once.
#
# The second reason is subtractive. `docs/EVENT_SIGNAL_MANIFEST.md` counts 110 signals, 48 of
# them with no listener at all. Auto-connecting would make the engine a listener for all 110
# and turn every one of them into a potential admission path — including the three that have
# no production EMITTER, which would then be silently dead triggers rather than a lint error.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHAT ARRIVES, AND WHEN
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# Nothing here proposes. Handlers call `EvEngine.on_signal`, which BUFFERS: signals fire
# during TimeManager's slots 1-6, i.e. while Product, HR and Sales are still moving, and a
# slot-1 edge admitted inline would be judged against a world where Finance has not run.
# The buffer drains at step (f) of the engine's own tick, in emission order.

## signal name -> {slots: {slot_name: argument_index}}
##
## A signal not listed here cannot trigger a card. A card naming an unlisted signal is a build
## error, raised at install time rather than discovered as a beat that never fires.
const BINDINGS := {
	"customer_health_changed": {"slots": {"customer": 0}},
	"customer_churned": {"slots": {"customer": 0}},
	"customer_expanded": {"slots": {"customer": 0}},
	"employee_departed": {"slots": {"employee": 0}},
	"employee_hired": {"slots": {"employee": 0}},
	"promise_broken": {"slots": {}},
	"version_shipped": {"slots": {}},
	"build_phase_changed": {"slots": {}},
	"sheet_expired": {"slots": {"investor": 0}},
	"meeting_day": {"slots": {"investor": 0}},
	"phase_gate_reached": {"slots": {}},
}

static var _connected: Array = []


## Connect exactly the signals the loaded catalogue triggers on. Called once, after the
## catalogue loads — the set of signals worth listening to is a property of the CONTENT, and
## reading it off the content is what keeps the two from drifting.
static func install() -> void:
	uninstall()
	for name in _signals_in_catalogue():
		var signal_name: String = String(name)
		if not BINDINGS.has(signal_name):
			push_error("[EvSignals] a card triggers on '%s', which has no binding — " % signal_name
				+ "add one to EvSignals.BINDINGS naming which argument fills which slot")
			continue
		if not EventBus.has_signal(signal_name):
			push_error("[EvSignals] a card triggers on '%s', which EventBus does not declare"
				% signal_name)
			continue
		# One Callable per signal, carrying its own name and binding. `bind` appends, so the
		# signal's own arguments arrive first and the name last — which is why _relay takes
		# them as a varargs Array rather than by position.
		var handler: Callable = _make_handler(signal_name)
		EventBus.connect(signal_name, handler)
		_connected.append({"signal": signal_name, "handler": handler})


static func uninstall() -> void:
	for entry in _connected:
		var e: Dictionary = entry
		if EventBus.is_connected(String(e["signal"]), e["handler"]):
			EventBus.disconnect(String(e["signal"]), e["handler"])
	_connected.clear()


static func installed_signals() -> Array:
	var out: Array = []
	for e in _connected:
		out.append(String((e as Dictionary)["signal"]))
	return out


# --- Internals -------------------------------------------------------------

## Godot has no varargs Callable, so one arity per shape. Every signal in BINDINGS today takes
# 0, 1 or 2 arguments; a third would need a line here, and the push_error below says so rather
# than letting the connect fail at runtime with a signature mismatch nobody reads.
static func _make_handler(signal_name: String) -> Callable:
	var arity: int = _arity_of(signal_name)
	match arity:
		0: return func() -> void: _relay(signal_name, [])
		1: return func(a) -> void: _relay(signal_name, [a])
		2: return func(a, b) -> void: _relay(signal_name, [a, b])
		3: return func(a, b, c) -> void: _relay(signal_name, [a, b, c])
	push_error("[EvSignals] '%s' takes %d arguments; add an arity arm" % [signal_name, arity])
	return func() -> void: pass


static func _arity_of(signal_name: String) -> int:
	for s in EventBus.get_signal_list():
		if String((s as Dictionary)["name"]) == signal_name:
			return ((s as Dictionary)["args"] as Array).size()
	return 0


static func _relay(signal_name: String, args: Array) -> void:
	var slots: Dictionary = (BINDINGS[signal_name] as Dictionary).get("slots", {})
	var payload: Dictionary = {}
	for slot in slots:
		var idx: int = int(slots[slot])
		if idx < args.size():
			payload[String(slot)] = String(args[idx])
	EvEngine.on_signal(signal_name, payload)


static func _signals_in_catalogue() -> Array:
	var out: Array = []
	for id in EvCatalog.card_ids():
		var trigger: Dictionary = EvCatalog.card(String(id)).get("trigger", {})
		var name: String = String(trigger.get("signal", ""))
		if name != "" and not out.has(name):
			out.append(name)
	return out
