class_name EvSeams
extends RefCounted

# THE SEAM REGISTRY (GDD §6). Named, read-only queries. Content never reaches into a system;
# it asks here, by name, and the name is a contract that survives the system's internals
# changing (§6.1: a changed meaning gets a NEW name).
#
# Because every name is enumerable, an unknown name is a BUILD error (§17.1). Because every
# entry declares its type, a condition literal is coerced ONCE at catalogue load — Godot's JSON
# parser returns floats for every number, so `"in": [1,2,3]` would otherwise never match an int.
#
# AN ALLOWLIST, NOT A CONVENTION. Not every static function on a read surface is side-effect
# free (ProductRead.emit_edges() mutates state and emits signals), and §5.3 bans side effects
# during condition evaluation — so every seam is registered by hand, and a smoke case proves the
# whole catalogue is side-effect free.

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

## A global seam's current value. An unknown name returns null and errors — lint should have
## caught it.
static func read(name: String) -> Variant:
	ensure_installed()
	if _mocks.has(name):
		return _mocks[name]
	var fn: Callable = _binding(name, Kind.GLOBAL)
	return fn.call() if fn.is_valid() else null


## An entity-scoped seam for one entity id. A per-entity mock wins over a seam-wide one.
static func read_for(name: String, entity_id: String) -> Variant:
	ensure_installed()
	for key in ["%s@%s" % [name, entity_id], name]:
		if _mocks.has(key):
			return _mocks[key]
	var fn: Callable = _binding(name, Kind.ENTITY)
	return fn.call(entity_id) if fn.is_valid() else null


static func _binding(name: String, want: Kind) -> Callable:
	if not _seams.has(name):
		push_error("[EvSeams] unknown seam '%s'" % name)
		return Callable()
	var d: Dictionary = _seams[name]
	if d["kind"] != want:
		push_error("[EvSeams] '%s' has the wrong kind; use %s()"
			% [name, "read_for" if want == Kind.GLOBAL else "read"])
		return Callable()
	return d["fn"]


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
	clear_mocks()
