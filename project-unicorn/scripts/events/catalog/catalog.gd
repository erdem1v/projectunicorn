class_name EvCatalog
extends RefCounted

# THE CARD AND ARC CATALOGUE (GDD §2, §3). Read-only, loaded once at boot, never serialised.
#
# CARDS ARE PLAIN DICTIONARIES, NOT RESOURCES. The old engine made GameEvent a Resource and
# then had to serialise whole cards into the save, because factories minted synthetic ones the
# catalogue had never heard of (event_manager.gd:263-268 explains why it had no choice). The
# new engine has no synthetics — every card is on disk — so §16.1 persists IDS, and a card
# never needs to round-trip at all.
#
# That is worth more than the simplicity. SaveCodec.script_for_class (save_codec.gd:59-70) is a
# nine-branch match, and a Resource that is not in it fails to rebuild with a push_warning —
# which is NOT in smoke_run.sh's error-token list, so an unregistered card class would be
# silent data loss with a green suite. Dictionaries cannot enter that failure mode. The engine
# block asserts at load that no "__res" tag appears anywhere inside it.
#
# THE LOADER RECURSES, AND ONE DIRECTORY MUST STAY EXCLUDED. data/events/unwired/ holds
# finished text for mechanics that do not exist yet. Its cards have empty conditions, and an
# empty condition is TRUE (§5.3) — so the moment a recursive loader sees that directory,
# ev_seed_closed fires on day 1. Today it is inert only because the old loader is a single
# non-recursive constant; that accident becomes an explicit rule here, and lint asserts it.

const CARDS_DIR := "res://data/events/cards/"
const ARCS_DIR := "res://data/events/arcs/"

## Directory names that are never pooled, whatever they contain.
const EXCLUDED_DIRS := ["unwired", "drafts"]
## Filename prefixes the pool skips. Fixtures reachable by --event-shot, never by play.
const EXCLUDED_PREFIXES := ["ev_debug_", "_"]

## id -> card Dictionary
static var _cards: Dictionary = {}
## id -> arc definition Dictionary
static var _arcs: Dictionary = {}
## Problems found at load, for the linter and the boot report.
static var _load_errors: Array = []
static var _loaded: bool = false


# --- Loading ---------------------------------------------------------------

static func ensure_loaded() -> void:
	if _loaded:
		return
	reload()


static func reload() -> void:
	_cards.clear()
	_arcs.clear()
	_load_errors.clear()
	_loaded = true
	EvSeams.ensure_installed()
	_walk(CARDS_DIR, _ingest_card)
	_walk(ARCS_DIR, _ingest_arc)
	# The set of EventBus signals worth listening to is a property of the CONTENT, so it is
	# read off the content the moment the content is known — and re-read on every reload, or a
	# card added at runtime would trigger on a signal nothing is connected to.
	EvSignals.install()
	if not _load_errors.is_empty() and OS.is_debug_build():
		push_warning("[EvCatalog] %d content problem(s) at load; run the linter"
			% _load_errors.size())


static func _walk(dir_path: String, ingest: Callable) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return          # an absent directory is not an error; content arrives in batches
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if dir.current_is_dir():
			if not EXCLUDED_DIRS.has(name) and not name.begins_with("."):
				_walk(dir_path.path_join(name) + "/", ingest)
		elif name.ends_with(".json") and not _excluded_file(name):
			ingest.call(dir_path.path_join(name))
		name = dir.get_next()
	dir.list_dir_end()


static func _excluded_file(file_name: String) -> bool:
	for prefix in EXCLUDED_PREFIXES:
		if file_name.begins_with(prefix):
			return true
	return false


static func _read_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_error(path, "unreadable")
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_error(path, "not a JSON object")
		return {}
	return parsed


static func _ingest_card(path: String) -> void:
	var d: Dictionary = _read_json(path)
	if d.is_empty():
		return
	var id: String = String(d.get("id", ""))
	if id == "":
		_error(path, "card has no id")
		return
	if _cards.has(id):
		_error(path, "duplicate card id '%s' (already from %s)" % [id, _cards[id]["_path"]])
		return
	d["_path"] = path
	_normalise_card(d)
	_cards[id] = d


static func _ingest_arc(path: String) -> void:
	var d: Dictionary = _read_json(path)
	if d.is_empty():
		return
	var id: String = String(d.get("id", ""))
	if id == "":
		_error(path, "arc has no id")
		return
	if _arcs.has(id):
		_error(path, "duplicate arc id '%s'" % id)
		return
	d["_path"] = path
	_arcs[id] = d


static func _error(path: String, message: String) -> void:
	_load_errors.append({"path": path, "message": message})
	push_error("[EvCatalog] %s: %s" % [path, message])


# --- Normalisation: the defaults §3.1 declares -----------------------------

static func _normalise_card(card: Dictionary) -> void:
	card["tick"] = String(card.get("tick", "daily"))
	card["class"] = String(card.get("class", "paper"))
	card["category"] = String(card.get("category", "other"))
	card["tags"] = card.get("tags", [])
	card["scope"] = card.get("scope", {})
	card["guards"] = card.get("guards", {})
	card["options"] = card.get("options", [])
	card["weight"] = float(card.get("weight", 1.0))
	card["min_gap_days"] = int(card.get("min_gap_days", 30))
	card["latch_key"] = String(card.get("latch_key", EvLatches.KEY_RUN))
	if not card.has("latch"):
		card["latch"] = {EvLatches.COOLDOWN: EvLatches.DEFAULT_COOLDOWN_DAYS}
	_coerce_conditions(card)


## Coerce every condition literal to its seam's declared type, ONCE, here.
##
## Godot's JSON parser returns TYPE_FLOAT for every number — save_codec.gd:27-38 measured it.
## So {"seam": "hr.headcount", "op": "in", "value": [1,2,3]} arrives as [1.0, 2.0, 3.0] and an
## `in` test against an int seam silently never matches. Coercing at load means the hot path
## compares like with like and nobody has to remember.
##
## A leaf naming an unknown seam is recorded and left alone; the linter turns that into a build
## error, which is the right place for it — at runtime, refusing to load the whole card would
## lose the other nineteen leaves that were fine.
static func _coerce_conditions(card: Dictionary) -> void:
	for tree in _condition_trees(card):
		for leaf in EvCondition.leaves(tree):
			var d: Dictionary = leaf
			var seam_name: String = String(d.get("seam", d.get("entity_seam", "")))
			if seam_name == "":
				continue
			if not EvSeams.has(seam_name):
				_error(String(card.get("_path", "?")), "unknown seam '%s'" % seam_name)
				continue
			if d.has("value"):
				d["value"] = EvSeams.coerce(seam_name, d["value"])


## Every condition tree a card carries: its own, plus one per option's `requires`.
static func _condition_trees(card: Dictionary) -> Array:
	var out: Array = []
	if typeof(card.get("condition", null)) == TYPE_DICTIONARY:
		out.append(card["condition"])
	if typeof(card.get("trigger", null)) == TYPE_DICTIONARY:
		var trig: Dictionary = card["trigger"]
		if typeof(trig.get("condition", null)) == TYPE_DICTIONARY:
			out.append(trig["condition"])
	for opt in (card.get("options", []) as Array):
		if typeof(opt) == TYPE_DICTIONARY and typeof((opt as Dictionary).get("requires", null)) == TYPE_DICTIONARY:
			out.append((opt as Dictionary)["requires"])
	return out


# --- Reading ---------------------------------------------------------------

static func card(event_id: String) -> Dictionary:
	ensure_loaded()
	return _cards.get(event_id, {})


static func has_card(event_id: String) -> bool:
	ensure_loaded()
	return _cards.has(event_id)


static func arc(arc_id: String) -> Dictionary:
	ensure_loaded()
	return _arcs.get(arc_id, {})


static func has_arc(arc_id: String) -> bool:
	ensure_loaded()
	return _arcs.has(arc_id)


static func card_ids() -> Array:
	ensure_loaded()
	var ids: Array = _cards.keys()
	ids.sort()
	return ids


static func arc_ids() -> Array:
	ensure_loaded()
	var ids: Array = _arcs.keys()
	ids.sort()
	return ids


## Cards whose tick matches and which are not arc steps. The pool's raw material — §10.10 keeps
## arc steps out of it, because a step fired from the pool would burn its own one_shot latch
## and lock the arc at that step forever. That is a silent death, and silent deaths are the
## thing the arc object exists to prevent.
static func pool_candidates(tick: String) -> Array:
	ensure_loaded()
	var out: Array = []
	for id in card_ids():
		var c: Dictionary = _cards[id]
		if String(c["tick"]) != tick:
			continue
		if c.has("arc"):
			continue
		if (c["tags"] as Array).has("critical"):
			continue
		out.append(c)
	return out


static func load_errors() -> Array:
	return _load_errors.duplicate(true)
