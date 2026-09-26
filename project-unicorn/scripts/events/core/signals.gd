class_name EvSignals
extends RefCounted

# THE ENGINE'S EARS. The one place an EventBus signal becomes a proposal, and an allowlist
# rather than a loop over EventBus:
#
#   A signal carries positional arguments; a card carries NAMED scope slots. Nothing in a
#   signal's signature says its first argument is a CUSTOMER id, and binding it on a guess is
#   how a card comes to be about the wrong subject. So each binding names which argument fills
#   which slot, by hand, once.
#
#   Auto-connecting would make every EventBus signal a potential admission path, including ones
#   with no production emitter, which would then be silently dead triggers.
#
# Nothing here proposes. Handlers call `EvEngine.on_signal`, which BUFFERS until the engine's
# own tick (see EvEngine's step list).

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
	for entry in _connected:
		if EventBus.is_connected(entry["signal"], entry["handler"]):
			EventBus.disconnect(entry["signal"], entry["handler"])
	_connected.clear()

	var wanted: Array = []
	for id in EvCatalog.card_ids():
		var name: String = String(EvCatalog.card(id).get("trigger", {}).get("signal", ""))
		if name != "" and not wanted.has(name):
			wanted.append(name)

	for signal_name in wanted:
		if not BINDINGS.has(signal_name):
			push_error("[EvSignals] a card triggers on '%s', which has no binding — " % signal_name
				+ "add one to EvSignals.BINDINGS naming which argument fills which slot")
			continue
		if not EventBus.has_signal(signal_name):
			push_error("[EvSignals] a card triggers on '%s', which EventBus does not declare"
				% signal_name)
			continue
		var handler: Callable = _make_handler(signal_name)
		EventBus.connect(signal_name, handler)
		_connected.append({"signal": signal_name, "handler": handler})


# --- Internals -------------------------------------------------------------

## Godot has no varargs Callable, so one lambda per arity. A signal with more arguments needs
## an arm here; the push_error says so rather than letting connect fail on a signature mismatch.
static func _make_handler(signal_name: String) -> Callable:
	var arity: int = 0
	for s in EventBus.get_signal_list():
		if String(s["name"]) == signal_name:
			arity = (s["args"] as Array).size()
			break
	match arity:
		0: return func() -> void: _relay(signal_name, [])
		1: return func(a) -> void: _relay(signal_name, [a])
		2: return func(a, b) -> void: _relay(signal_name, [a, b])
		3: return func(a, b, c) -> void: _relay(signal_name, [a, b, c])
	push_error("[EvSignals] '%s' takes %d arguments; add an arity arm" % [signal_name, arity])
	return func() -> void: pass


static func _relay(signal_name: String, args: Array) -> void:
	var slots: Dictionary = BINDINGS[signal_name]["slots"]
	var payload: Dictionary = {}
	for slot in slots:
		var idx: int = slots[slot]
		if idx < args.size():
			payload[slot] = String(args[idx])
	EvEngine.on_signal(signal_name, payload)
