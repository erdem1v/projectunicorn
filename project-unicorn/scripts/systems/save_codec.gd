class_name SaveCodec
extends RefCounted

# The save/load serialization layer. Pure translation: state ⇄ JSON-safe Variants. It writes
# nothing to disk and owns no policy; SaveManager does both.
#
# ONE GENERIC WALKER. Every model is a Resource whose @export vars carry
# PROPERTY_USAGE_STORAGE, so the property list IS the save schema; there is no hand-written
# field list to forget a new field in. res_from_dict sets only properties the class has
# TODAY: a key the class no longer has is dropped, and a property the save does not mention
# keeps its declared default. The defaults are the migration in both directions.
#
# TWO ENGINE FACTS THIS FILE IS BUILT AROUND:
#   1. Godot's JSON parser returns TYPE_FLOAT for every number, so every integer has to be
#      re-derived from a type oracle on load: the declared default for Resource properties,
#      the live field for GameState, GameState.FLAG_TYPES for flags, and _normalize_number
#      for untyped nested bags (every reader of those goes through int()/float()).
#   2. A typed array cannot be assigned from an untyped Array, and JSON arrays are untyped.
#      Array.assign() into a copy of the declared default converts the elements.

const TYPE_TAG := "__res"


# Every Resource class that can reach a save file. A `match` because a global class name is
# not a constant expression and cannot sit in a const Dictionary.
static func script_for_class(cls: String) -> Script:
	match cls:
		"Character":    return Character
		"Customer":     return Customer
		"Prospect":     return Prospect
		"Rival":        return Rival
		"Promise":      return Promise
		"FeatureBuild": return FeatureBuild
		"TermSheet":    return TermSheet
		_:              return null


# ============================================================================
#  Generic Resource walker
# ============================================================================

# Storage properties declared by the script. @export vars report STORAGE|SCRIPT_VARIABLE;
# engine bookkeeping (resource_name, script, …) lacks the SCRIPT_VARIABLE bit.
static func _saved_props(r: Resource) -> Array[String]:
	var out: Array[String] = []
	for p in r.get_property_list():
		var usage: int = int(p.usage)
		if (usage & PROPERTY_USAGE_STORAGE) and (usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			out.append(String(p.name))
	return out


static func res_to_dict(r: Resource) -> Dictionary:
	# Every storage property, plus a type tag so the way back needs no context.
	if r == null:
		return {}
	var out: Dictionary = {TYPE_TAG: _class_of(r)}
	for pname in _saved_props(r):
		out[pname] = to_json(r.get(pname))
	return out


static func res_from_dict(d: Dictionary, fallback: Script = null) -> Resource:
	# `fallback` covers a payload without a known tag; the caller knows what it asked for.
	if d.is_empty():
		return null
	var cls: String = String(d.get(TYPE_TAG, ""))
	var script: Script = script_for_class(cls)
	if script == null:
		script = fallback
	if script == null:
		push_warning("[SaveCodec] res_from_dict: unknown class '%s' and no fallback — skipped" % cls)
		return null
	var r: Resource = script.new()
	for pname in _saved_props(r):
		if d.has(pname):
			# The declared default is the type oracle and the typed-array template.
			r.set(pname, coerce_like(r.get(pname), d[pname]))
	return r


static func _class_of(r: Resource) -> String:
	var s: Script = r.get_script()
	if s != null and String(s.get_global_name()) != "":
		return String(s.get_global_name())
	return r.get_class()


# ============================================================================
#  Variant ⇄ JSON
# ============================================================================

static func to_json(v: Variant) -> Variant:
	match typeof(v):
		TYPE_OBJECT:
			if v is Resource:
				return res_to_dict(v as Resource)
			push_warning("[SaveCodec] non-Resource Object dropped from save: %s" % str(v))
			return null
		TYPE_ARRAY:
			var arr: Array = []
			for e in (v as Array):
				arr.append(to_json(e))
			return arr
		TYPE_DICTIONARY:
			var d: Dictionary = {}
			for k in (v as Dictionary).keys():
				# JSON keys are strings; String() keeps a stray non-string key legible.
				d[String(k)] = to_json((v as Dictionary)[k])
			return d
		_:
			return v


static func from_json(v: Variant) -> Variant:
	# Decode without a type oracle, for untyped containers. Tagged dictionaries come back as
	# Resources, numbers through _normalize_number.
	match typeof(v):
		TYPE_DICTIONARY:
			var src: Dictionary = v as Dictionary
			if src.has(TYPE_TAG):
				return res_from_dict(src)
			var d: Dictionary = {}
			for k in src.keys():
				d[String(k)] = from_json(src[k])
			return d
		TYPE_ARRAY:
			var arr: Array = []
			for e in (v as Array):
				arr.append(from_json(e))
			return arr
		TYPE_FLOAT:
			return _normalize_number(v as float)
		_:
			return v


static func coerce_like(template: Variant, raw: Variant) -> Variant:
	# Decode `raw` into the shape the live default `template` declares, including the
	# element type of a typed array.
	match typeof(template):
		TYPE_BOOL:
			return bool(raw)
		TYPE_INT:
			return int(raw) if typeof(raw) != TYPE_STRING else String(raw).to_int()
		TYPE_FLOAT:
			return float(raw)
		TYPE_STRING:
			return String(raw)
		TYPE_STRING_NAME:
			return StringName(String(raw))
		TYPE_ARRAY:
			if typeof(raw) != TYPE_ARRAY:
				return template
			var target: Array = (template as Array).duplicate()
			target.clear()
			target.assign(from_json(raw) as Array)
			return target
		TYPE_DICTIONARY:
			return from_json(raw) if typeof(raw) == TYPE_DICTIONARY else template
		TYPE_OBJECT:
			if typeof(raw) != TYPE_DICTIONARY:
				return null
			var fallback: Script = (template as Resource).get_script() if template is Resource else null
			return res_from_dict(raw as Dictionary, fallback)
		_:
			return from_json(raw)


static func _normalize_number(f: float) -> Variant:
	# Integral → int, so an untyped bag does not turn {"day": 3} into {"day": 3.0}. Past 2^53
	# a float is not an exact integer anyway.
	if not is_finite(f) or f != floor(f) or absf(f) > 9007199254740992.0:
		return f
	return int(f)


# ============================================================================
#  GameState
# ============================================================================

static func game_state_fields() -> Array[String]:
	# Every script variable on GameState, discovered rather than listed. SCRIPT_VARIABLE alone:
	# GameState's vars are plain `var`, not @export, so they carry no STORAGE bit.
	var out: Array[String] = []
	for p in GameState.get_property_list():
		if int(p.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE:
			out.append(String(p.name))
	return out


static func capture_game_state() -> Dictionary:
	var out: Dictionary = {}
	for fname in game_state_fields():
		out[fname] = to_json(GameState.get(fname))
	return out


static func apply_game_state(block: Dictionary) -> void:
	# Applied over initialize_run's defaults. Direct set() by design: no shell is in the tree,
	# and routing every field through emitting setters would broadcast into the void.
	for fname in game_state_fields():
		if not block.has(fname):
			continue
		var current: Variant = GameState.get(fname)
		var decoded: Variant = _decode_flags(block[fname]) if fname == "flags" \
			else coerce_like(current, block[fname])
		# Containers are refilled in place, never replaced, so a reference a system holds
		# keeps pointing at the live run.
		if typeof(current) == TYPE_DICTIONARY and typeof(decoded) == TYPE_DICTIONARY:
			(current as Dictionary).clear()
			(current as Dictionary).merge(decoded as Dictionary)
		elif typeof(current) == TYPE_ARRAY and typeof(decoded) == TYPE_ARRAY:
			(current as Array).clear()
			(current as Array).assign(decoded as Array)   # keeps the declared element type
		else:
			GameState.set(fname, decoded)


static func _decode_flags(raw: Variant) -> Dictionary:
	# Readers of flags disagree about typing (bool() vs plain truthiness), so every flag is
	# pinned to its declared type in GameState.FLAG_TYPES.
	var out: Dictionary = {}
	if typeof(raw) != TYPE_DICTIONARY:
		return out
	for k in (raw as Dictionary).keys():
		var key: String = String(k)
		var v: Variant = (raw as Dictionary)[k]
		match GameState.flag_type_for(key):
			TYPE_BOOL:       out[key] = bool(v)
			TYPE_INT:        out[key] = int(v)
			TYPE_FLOAT:      out[key] = float(v)
			TYPE_STRING:     out[key] = String(v)
			TYPE_ARRAY:      out[key] = from_json(v) if typeof(v) == TYPE_ARRAY else []
			TYPE_DICTIONARY: out[key] = from_json(v) if typeof(v) == TYPE_DICTIONARY else {}
			_:               out[key] = from_json(v)
	return out


# ============================================================================
#  Registries
# ============================================================================

# [save key, model script, registry] in restore order. PROMISES LAST: PromiseRegistry drops
# open promises on customer_removed, so every customer must be seated before one is inserted.
static func _registries() -> Array:
	return [
		["characters", Character, CharacterRegistry],
		["customers", Customer, CustomerRegistry],
		["prospects", Prospect, ProspectRegistry],
		["rivals", Rival, RivalRegistry],
		["promises", Promise, PromiseRegistry],
	]


static func capture_registries() -> Dictionary:
	var out: Dictionary = {}
	for entry in _registries():
		var rows: Array = []
		for r in entry[2].get_all():
			rows.append(res_to_dict(r))
		out[entry[0]] = rows
	return out


static func restore_registries(state: Dictionary) -> void:
	# Raw inserts, no signals: the shell is not in the tree during a load. Rivals overlay the
	# catalog re-seed RivalRegistry.reset() already did, so a rival added after the save was
	# written still exists at its catalog starting values.
	var reg: Dictionary = state.get("registries", {}) as Dictionary
	for entry in _registries():
		for d in (reg.get(entry[0], []) as Array):
			var r: Resource = res_from_dict(d as Dictionary, entry[1])
			if r != null:
				entry[2].insert_raw(r)


# System routing lives in SaveManager, not here: the systems call into this class, so a
# capture_systems() here would make a class_name ↔ class_name cycle.
