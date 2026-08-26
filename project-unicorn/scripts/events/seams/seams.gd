class_name EvSeams
extends RefCounted

# THE SEAM REGISTRY (GDD §6). Named, read-only queries. Content never reaches into a system;
# it asks here, by name, and the name is a contract that survives the system's internals
# changing underneath it.
#
# WHY A REGISTRY AND NOT DIRECT CALLS. Three reasons, in order of how much they cost when
# skipped:
#
#   Content rot. A card written in month one that says `hr.morale_avg` still means the same
#   thing in month six, because §6.1 forbids a name's meaning changing — a changed meaning
#   gets a NEW name. Direct calls give you no such promise: the function keeps its name and
#   quietly starts returning something else, and forty cards start lying at once.
#
#   Lint. Because every name a card may use is enumerable, an unknown name is a BUILD error
#   (§17.1) instead of a runtime warning nobody reads. The old engine's unknown-condition
#   path was `push_warning` on every tick, forever (event_manager.gd:456).
#
#   Types. Every entry declares its type, so a condition's literal can be coerced ONCE at
#   catalogue load. That closes a defect the codebase already measured: Godot's JSON parser
#   returns TYPE_FLOAT for every number (save_codec.gd:27-38), so `{"op": "in",
#   "value": [1,2,3]}` loads as floats and silently never matches an int seam.
#
# AN ALLOWLIST, NOT A CONVENTION. It is tempting to say "any static function on a read-surface
# class is a seam". That is false in this codebase and provably so: ProductRead.emit_edges()
# (product_read.gd:196-243) is a static function on the class the GDD calls Ürün's read
# catalogue, and it mutates five statics and emits five signals. §5.3 bans side effects during
# condition evaluation; only an explicit list can enforce that, so every seam is registered by
# hand and a smoke case proves the whole catalogue is side-effect free.

enum Kind {
	GLOBAL,   ## takes nothing: finance.cash()
	ENTITY,   ## takes one entity id: hr.morale(person)
}

## name -> {kind, type, fn, owner, note}
static var _seams: Dictionary = {}
## Test-only overrides, consulted before the real binding.
static var _mocks: Dictionary = {}
static var _installed: bool = false


# --- Registration ----------------------------------------------------------

static func register(name: String, kind: Kind, type: int, fn: Callable,
		owner: String, note: String = "") -> void:
	if _seams.has(name):
		push_error("[EvSeams] duplicate seam '%s' — a name has exactly one home" % name)
		return
	_seams[name] = {"kind": kind, "type": type, "fn": fn, "owner": owner, "note": note}


static func ensure_installed() -> void:
	if _installed:
		return
	_installed = true
	EvSeamsHR.install()
	EvSeamsProduct.install()
	EvSeamsFinance.install()
	EvSeamsSales.install()
	EvSeamsWorld.install()
	EvSeamsPorted.install()


# --- Reading ---------------------------------------------------------------

## A global seam's current value. Unknown name returns null and errors — lint should have
## caught it, so reaching here at runtime is itself the finding.
static func read(name: String) -> Variant:
	ensure_installed()
	if _mocks.has(name):
		return _mocks[name]
	var entry: Variant = _seams.get(name, null)
	if entry == null:
		push_error("[EvSeams] unknown seam '%s'" % name)
		return null
	var d: Dictionary = entry
	if d["kind"] != Kind.GLOBAL:
		push_error("[EvSeams] '%s' is entity-scoped; call read_for()" % name)
		return null
	return (d["fn"] as Callable).call()


## An entity-scoped seam for one entity id.
static func read_for(name: String, entity_id: String) -> Variant:
	ensure_installed()
	var mock_key: String = "%s@%s" % [name, entity_id]
	if _mocks.has(mock_key):
		return _mocks[mock_key]
	if _mocks.has(name):
		return _mocks[name]
	var entry: Variant = _seams.get(name, null)
	if entry == null:
		push_error("[EvSeams] unknown seam '%s'" % name)
		return null
	var d: Dictionary = entry
	if d["kind"] != Kind.ENTITY:
		push_error("[EvSeams] '%s' is global; call read()" % name)
		return null
	return (d["fn"] as Callable).call(entity_id)


# --- Introspection (lint, the debug panel, the vocabulary generator) --------

static func has(name: String) -> bool:
	ensure_installed()
	return _seams.has(name)


static func kind_of(name: String) -> Kind:
	ensure_installed()
	return _seams.get(name, {}).get("kind", Kind.GLOBAL)


## TYPE_INT / TYPE_FLOAT / TYPE_STRING / TYPE_BOOL. Drives load-time literal coercion.
static func type_of(name: String) -> int:
	ensure_installed()
	return int(_seams.get(name, {}).get("type", TYPE_NIL))


static func owner_of(name: String) -> String:
	ensure_installed()
	return String(_seams.get(name, {}).get("owner", ""))


static func all_names() -> Array:
	ensure_installed()
	var names: Array = _seams.keys()
	names.sort()
	return names


## Coerce a condition literal to the seam's declared type. Called ONCE, at catalogue load.
## Returns the value untouched when the seam is unknown — the caller refuses the card.
static func coerce(name: String, value: Variant) -> Variant:
	if not has(name):
		return value
	var want: int = type_of(name)
	if typeof(value) == TYPE_ARRAY:
		var out: Array = []
		for v in (value as Array):
			out.append(_coerce_one(want, v))
		return out
	return _coerce_one(want, value)


static func _coerce_one(want: int, value: Variant) -> Variant:
	match want:
		TYPE_INT:
			return int(round(float(value))) if typeof(value) in [TYPE_FLOAT, TYPE_INT] else value
		TYPE_FLOAT:
			return float(value) if typeof(value) in [TYPE_FLOAT, TYPE_INT] else value
		TYPE_STRING:
			return String(value)
		TYPE_BOOL:
			return bool(value)
	return value


# --- Test support ----------------------------------------------------------

## §6.1's fifth clause: mockable, because it is the only way to test content without the
## systems behind it. Key is either "seam.name" or "seam.name@entity_id".
static func mock(name: String, value: Variant) -> void:
	_mocks[name] = value


static func clear_mocks() -> void:
	_mocks.clear()


static func reset() -> void:
	_mocks.clear()
