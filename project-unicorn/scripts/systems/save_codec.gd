class_name SaveCodec
extends RefCounted

# The save/load serialization layer (TECH_SPEC §10). Pure translation: state ⇄ JSON-safe
# Variants. It writes nothing to disk and owns no policy — SaveManager does both.
#
# ONE GENERIC WALKER, NOT NINE HAND-WRITTEN PAIRS. All nine models in scripts/data_models
# are Resource + @export, and @export is exactly PROPERTY_USAGE_STORAGE, so the property
# list already IS the save schema. Hand-written to_dict/from_dict pairs would be nine places
# to forget a field — and the field most likely to be forgotten is the one added last, which
# is also the one nobody has a test for yet.
#
# THE RESERVED-FIELD DISCIPLINE THIS INHERITS. The models already document it themselves:
#   character.gd:20-23     "Reserved (declared with defaults so future systems plug in
#                           without retrofitting the model and so the save schema is
#                           forward-compatible): loyalty, relationship, trust_score,
#                           attention_flag"
#   customer.gd:13-16      "Reserved (declared with defaults so future systems plug in
#                           without retrofitting and so the save schema is forward-compatible)"
#   feature_build.gd:13-21 "Forward-compat fields (equity_impact, revenue_share, tags,
#                           quality_modifiers) follow the Character forward-compat pattern"
# res_from_dict honours that literally: it sets ONLY properties that exist on the class
# TODAY, and a key the class no longer has is dropped, while a property the save does not
# mention keeps its DECLARED DEFAULT. So an old save loads into a newer model (new fields =
# defaults) and a save from a build with an extra field loads into an older model (extra key
# ignored). No migration code for either direction; the defaults are the migration.
#
# TWO MEASURED ENGINE FACTS THIS FILE IS BUILT AROUND — verify before "simplifying" either:
#
#   1. Godot's JSON parser returns TYPE_FLOAT for EVERY number. `JSON.parse_string("5")`
#      yields 5.0, not 5 (measured on 4.6.2). So nothing survives a round trip as an int on
#      its own; every integer has to be re-derived from a type oracle on load. For typed
#      surfaces the oracle is exact (see below). For untyped bags it is _normalize_number.
#
#   2. A typed array (Array[String], Array[int], Array[EventChoice]) cannot be assigned from
#      an untyped Array — Godot rejects it outright. JSON has no concept of the element
#      type, so every array comes back untyped. The fix is `Array.assign()`, which converts
#      elements into the target's type, applied to a DUPLICATE OF THE DECLARED DEFAULT so
#      the element type comes from the live class rather than from a table that can drift.
#
# THE TYPE ORACLE, in order of exactness:
#   Resource properties  → get_property_list() + the declared default value. Exact.
#   GameState fields     → the live field's current value (typeof + typed-array template).
#                          Exact, and drift-proof: a new GameState var is saved automatically.
#   GameState.flags      → GameState.FLAG_TYPES (audit constraint — see game_state.gd).
#   Nested untyped bags  → _normalize_number: an integral float becomes an int unless its key
#                          is registered in FLOAT_KEYS. Audited: no persisted nested container
#                          in this codebase holds a genuine integral float today, and every
#                          consumer of those bags reads through int()/float() anyway. FLOAT_KEYS
#                          is the escape hatch — register a key there the moment one does.

const TYPE_TAG := "__res"

# name (as written by _class_of) -> the script that rebuilds it. Every Resource that can
# reach a save file must appear here or res_from_dict cannot name its class on the way back.
#
# A `match` rather than a const Dictionary because a global class name is NOT a constant
# expression in GDScript ("Assigned value for constant isn't a constant expression"), and a
# lazily-filled static var would be the same table with an initialisation guard bolted on.
static func script_for_class(cls: String) -> Script:
	match cls:
		"Character":    return Character
		"Customer":     return Customer
		"Prospect":     return Prospect
		"Rival":        return Rival
		"Promise":      return Promise
		"FeatureBuild": return FeatureBuild
		"GameEvent":    return GameEvent
		"EventChoice":  return EventChoice
		"TermSheet":    return TermSheet
		_:              return null

# Dictionary keys inside UNTYPED containers whose values must stay float through a load.
# Empty today because the audit found none (see the header). Adding a nested float means
# adding its key here in the same commit — that is the whole contract.
const FLOAT_KEYS: Array[String] = []

# Resource base properties that carry STORAGE but are engine bookkeeping, not model data.
# The primary filter is PROPERTY_USAGE_SCRIPT_VARIABLE (measured: @export vars report
# usage 4102 = STORAGE|EDITOR|SCRIPT_VARIABLE, while resource_name/script do not carry the
# SCRIPT_VARIABLE bit); this set is the belt-and-braces second line.
const SKIP_PROPS: Array[String] = [
	"resource_local_to_scene", "resource_name", "resource_path", "resource_scene_unique_id", "script",
]


# ============================================================================
#  Generic Resource walker
# ============================================================================

static func res_to_dict(r: Resource) -> Dictionary:
	# Every storage property, plus a "__res" type tag so the way back needs no context.
	# Nested Resources (GameEvent.choices is Array[EventChoice]) recurse through to_json.
	if r == null:
		return {}
	var out: Dictionary = {TYPE_TAG: _class_of(r)}
	for p in r.get_property_list():
		var usage: int = int(p.usage)
		if not (usage & PROPERTY_USAGE_STORAGE):
			continue
		if not (usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		var pname: String = String(p.name)
		if pname in SKIP_PROPS:
			continue
		out[pname] = to_json(r.get(pname))
	return out


static func res_from_dict(d: Dictionary, fallback: Script = null) -> Resource:
	# Rebuild from the type tag. `fallback` covers a payload written before the tag existed
	# (or one whose class was renamed) — the caller knows what it asked for.
	if typeof(d) != TYPE_DICTIONARY or d.is_empty():
		return null
	var cls: String = String(d.get(TYPE_TAG, ""))
	var script: Script = script_for_class(cls)
	if script == null:
		script = fallback
	if script == null:
		push_warning("[SaveCodec] res_from_dict: unknown class '%s' and no fallback — skipped" % cls)
		return null
	var r: Resource = script.new()
	# Property names that EXIST ON THIS CLASS TODAY. Anything else in the payload is a field
	# a newer/older build wrote and this one does not know: dropped, never assigned blindly.
	var known: Dictionary = {}
	for p in r.get_property_list():
		var usage: int = int(p.usage)
		if (usage & PROPERTY_USAGE_STORAGE) and (usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			known[String(p.name)] = true
	for key in d.keys():
		var kname: String = String(key)
		if kname == TYPE_TAG or kname in SKIP_PROPS:
			continue
		if not known.has(kname):
			continue  # forward-compat: unknown field, leave the class alone
		# The declared default is the type oracle AND (for arrays) the element-type template.
		r.set(kname, coerce_like(r.get(kname), d[key]))
	return r


static func res_list_to_json(items: Array) -> Array:
	var out: Array = []
	for r in items:
		if r is Resource:
			out.append(res_to_dict(r as Resource))
	return out


static func _class_of(r: Resource) -> String:
	var s: Script = r.get_script()
	if s != null:
		var gname: String = String(s.get_global_name())
		if gname != "":
			return gname
	return r.get_class()


# ============================================================================
#  Variant ⇄ JSON
# ============================================================================

static func to_json(v: Variant) -> Variant:
	match typeof(v):
		TYPE_OBJECT:
			if v is Resource:
				return res_to_dict(v as Resource)
			# A non-Resource Object cannot be described by this schema. Dropping it silently
			# would produce a save that LIES about the field; null is at least legible.
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
				# JSON object keys are always strings. Every persisted dictionary in this
				# codebase is already String-keyed (audited); String() keeps a stray
				# non-string key legible instead of failing the whole write.
				d[String(k)] = to_json((v as Dictionary)[k])
			return d
		_:
			return v


static func from_json(v: Variant, key_hint: String = "") -> Variant:
	# Decode WITHOUT a type oracle — used inside untyped containers. Scalars come back
	# normalized (see _normalize_number); tagged dictionaries come back as Resources.
	match typeof(v):
		TYPE_DICTIONARY:
			var src: Dictionary = v as Dictionary
			if src.has(TYPE_TAG):
				return res_from_dict(src)
			var d: Dictionary = {}
			for k in src.keys():
				d[String(k)] = from_json(src[k], String(k))
			return d
		TYPE_ARRAY:
			var arr: Array = []
			for e in (v as Array):
				# Array elements inherit the ARRAY's key for the FLOAT_KEYS lookup: a list
				# under a float-typed key is a list of floats.
				arr.append(from_json(e, key_hint))
			return arr
		TYPE_FLOAT:
			return _normalize_number(v as float, key_hint)
		_:
			return v


static func coerce_like(template: Variant, raw: Variant) -> Variant:
	# Decode `raw` into the shape `template` declares. `template` is a live default value,
	# so it carries both the Variant type AND (for arrays) the element type.
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
			var decoded: Array = []
			for e in (raw as Array):
				decoded.append(from_json(e))
			# assign() converts elements into the template's element type — the ONLY way an
			# Array[String] / Array[int] / Array[EventChoice] survives a JSON round trip.
			var target: Array = (template as Array).duplicate()
			target.clear()
			target.assign(decoded)
			return target
		TYPE_DICTIONARY:
			if typeof(raw) != TYPE_DICTIONARY:
				return template
			return from_json(raw)
		TYPE_OBJECT:
			if typeof(raw) != TYPE_DICTIONARY:
				return null
			var fallback: Script = null
			if template is Resource:
				fallback = (template as Resource).get_script()
			return res_from_dict(raw as Dictionary, fallback)
		_:
			# TYPE_NIL and anything exotic: no oracle, decode generically.
			return from_json(raw)


static func _normalize_number(f: float, key_hint: String) -> Variant:
	# See engine fact 1 in the header: JSON hands back every number as a float, so an
	# untyped bag would otherwise turn {"day": 3} into {"day": 3.0} and quietly change the
	# type of half the run state. Integral → int, unless the key says otherwise.
	if key_hint != "" and key_hint in FLOAT_KEYS:
		return f
	if not is_finite(f):
		return f
	if f != floor(f):
		return f
	if absf(f) > 9007199254740992.0:   # past 2^53 the float is not an exact integer anyway
		return f
	return int(f)


# ============================================================================
#  GameState
# ============================================================================

static func game_state_fields() -> Array[String]:
	# Every script-declared variable on GameState, discovered rather than listed. A hand
	# written whitelist is exactly the thing that silently stops covering a field added six
	# months later; the property list cannot drift from the class it describes.
	# NOTE the filter is SCRIPT_VARIABLE alone: GameState's vars are plain `var` (not
	# @export), so they do NOT carry PROPERTY_USAGE_STORAGE the way the Resource models do.
	var out: Array[String] = []
	for p in GameState.get_property_list():
		if not (int(p.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		var pname: String = String(p.name)
		if pname in GameState.SAVE_EXCLUDE_FIELDS:
			continue
		out.append(pname)
	return out


static func capture_game_state() -> Dictionary:
	var out: Dictionary = {}
	for fname in game_state_fields():
		out[fname] = to_json(GameState.get(fname))
	return out


static func apply_game_state(block: Dictionary) -> void:
	# Applied OVER initialize_run's defaults, so a field the save does not carry keeps the
	# fresh-run value rather than becoming null. Direct set() by design: this runs with no
	# shell in the tree (see initialize_run's own note at the "no listeners exist" comment),
	# and routing 70 fields through emitting setters would be a broadcast storm into the void.
	if block.is_empty():
		return
	for fname in game_state_fields():
		if not block.has(fname):
			continue
		var current: Variant = GameState.get(fname)
		var decoded: Variant = _decode_flags(block[fname]) if fname == "flags" \
			else coerce_like(current, block[fname])
		# CONTAINERS ARE REFILLED IN PLACE, NOT REPLACED. initialize_run already refuses to
		# reassign these ("Dicts via .clear() in case a system cached the reference"), and a
		# load has exactly the same exposure with a longer fuse: a system holding the old
		# Dictionary would keep reading a run that no longer exists, and every write it made
		# would land nowhere. Nothing caches one today (audited), which is precisely when a
		# guarantee is cheap to keep.
		if typeof(current) == TYPE_DICTIONARY and typeof(decoded) == TYPE_DICTIONARY:
			(current as Dictionary).clear()
			(current as Dictionary).merge(decoded as Dictionary)
		elif typeof(current) == TYPE_ARRAY and typeof(decoded) == TYPE_ARRAY:
			(current as Array).clear()
			(current as Array).assign(decoded as Array)   # keeps the declared element type
		else:
			GameState.set(fname, decoded)


static func _decode_flags(raw: Variant) -> Dictionary:
	# GameState.flags carries the whole product state in ~51 untyped keys, and the readers
	# disagree about typing on purpose-by-accident: event conditions coerce through bool()
	# while systems use plain truthiness, so a String-typed flag satisfies one and fails the
	# other. FLAG_TYPES is the pin — see game_state.gd.
	var out: Dictionary = {}
	if typeof(raw) != TYPE_DICTIONARY:
		return out
	for k in (raw as Dictionary).keys():
		var key: String = String(k)
		var declared: int = GameState.flag_type_for(key)
		var value: Variant = (raw as Dictionary)[k]
		if declared == TYPE_NIL:
			out[key] = from_json(value, key)   # unregistered flag: best-effort decode
			continue
		out[key] = _coerce_to_type(value, declared)
	return out


static func _coerce_to_type(v: Variant, t: int) -> Variant:
	match t:
		TYPE_BOOL:       return bool(v)
		TYPE_INT:        return int(v)
		TYPE_FLOAT:      return float(v)
		TYPE_STRING:     return String(v)
		TYPE_ARRAY:      return from_json(v) if typeof(v) == TYPE_ARRAY else []
		TYPE_DICTIONARY: return from_json(v) if typeof(v) == TYPE_DICTIONARY else {}
		_:               return from_json(v)


# ============================================================================
#  Registries
# ============================================================================

static func capture_registries() -> Dictionary:
	return {
		"characters": res_list_to_json(CharacterRegistry.get_all()),
		"customers": res_list_to_json(CustomerRegistry.get_all()),
		"prospects": res_list_to_json(ProspectRegistry.get_all()),
		"rivals": res_list_to_json(RivalRegistry.get_all()),
		"promises": res_list_to_json(PromiseRegistry.get_all()),
	}


static func restore_registries(state: Dictionary) -> void:
	# RAW INSERTS, NO SIGNALS. The shell is not in the tree during a load (main.gd tears it
	# down first), so an emit would land in the void; and emitting customer_added N times
	# would make the UI paint a company being founded rather than resumed.
	#
	# ORDER IS LOAD-BEARING — promises LAST. PromiseRegistry._ready binds
	# customer_removed → drop_open_for, so anything that can remove a customer after the
	# promises are in would silently delete them. Restoring promises after every customer
	# is already seated removes the window entirely rather than relying on nothing firing.
	var reg: Dictionary = state.get("registries", {}) as Dictionary
	if reg.is_empty():
		return
	for d in (reg.get("characters", []) as Array):
		var c: Character = res_from_dict(d as Dictionary, Character) as Character
		if c != null:
			CharacterRegistry.insert_raw(c)
	for d in (reg.get("customers", []) as Array):
		var cu: Customer = res_from_dict(d as Dictionary, Customer) as Customer
		if cu != null:
			CustomerRegistry.insert_raw(cu)
	for d in (reg.get("prospects", []) as Array):
		var p: Prospect = res_from_dict(d as Dictionary, Prospect) as Prospect
		if p != null:
			ProspectRegistry.insert_raw(p)
	# Rivals OVERLAY the catalog re-seed rather than replacing it (RivalRegistry.reset() has
	# already re-seeded from RivalCatalog.build_all()). A save written before a catalog entry
	# existed therefore gains that rival at its catalog starting values instead of leaving a
	# hole every share/league query would have to guard against.
	for d in (reg.get("rivals", []) as Array):
		var rv: Rival = res_from_dict(d as Dictionary, Rival) as Rival
		if rv != null:
			RivalRegistry.insert_raw(rv)
	for d in (reg.get("promises", []) as Array):
		var pr: Promise = res_from_dict(d as Dictionary, Promise) as Promise
		if pr != null:
			PromiseRegistry.insert_raw(pr)


# SYSTEM ROUTING LIVES IN SaveManager, NOT HERE — deliberately. ProductSystem, FinanceSystem
# and the rest call INTO this file (res_to_dict / res_from_dict), so a capture_systems() here
# would close a class_name ↔ class_name loop and give GDScript a cyclic reference to resolve
# at parse time. SaveManager is an autoload, and an autoload → class_name reference can never
# cycle. It is also the honest split: this file translates, SaveManager orchestrates.
