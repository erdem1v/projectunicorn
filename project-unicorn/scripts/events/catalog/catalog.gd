class_name EvCatalog
extends RefCounted

# THE CARD AND ARC CATALOGUE (GDD §2, §3). Read-only, loaded once at boot, never serialised.
#
# Cards are plain Dictionaries, not Resources: every card is on disk, so §16.1 persists IDS and a
# card never round-trips through the save codec.
#
# The loader recurses, so EXCLUDED_DIRS is a rule, not a convenience: cards for mechanics that
# do not exist yet carry empty conditions, an empty condition is TRUE (§5.3), and pooling such a
# directory would fire them on day 1.

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
	if not _loaded:
		reload()


static func reload() -> void:
	_cards.clear()
	_arcs.clear()
	_load_errors.clear()
	_loaded = true
	EvSeams.ensure_installed()
	_walk(CARDS_DIR, _cards, "card")
	_walk(ARCS_DIR, _arcs, "arc")
	# The EventBus signals worth listening to are a property of the content, so they are re-read
	# on every reload — or a card added at runtime would trigger on a signal nothing hears.
	EvSignals.install()
	if not _load_errors.is_empty() and OS.is_debug_build():
		push_warning("[EvCatalog] %d content problem(s) at load; run the linter"
			% _load_errors.size())


static func _walk(dir_path: String, into: Dictionary, what: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return          # an absent directory is not an error; content arrives in batches
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if dir.current_is_dir():
			if not EXCLUDED_DIRS.has(name) and not name.begins_with("."):
				_walk(dir_path.path_join(name) + "/", into, what)
		elif name.ends_with(".json") and not EXCLUDED_PREFIXES.any(func(p): return name.begins_with(p)):
			_ingest(dir_path.path_join(name), into, what)
		name = dir.get_next()
	dir.list_dir_end()


static func _ingest(path: String, into: Dictionary, what: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_error(path, "unreadable")
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_error(path, "not a JSON object")
		return
	var d: Dictionary = parsed
	if d.is_empty():
		return
	var id: String = String(d.get("id", ""))
	if id == "":
		_error(path, "%s has no id" % what)
		return
	if into.has(id):
		_error(path, "duplicate %s id '%s' (already from %s)" % [what, id, into[id]["_path"]])
		return
	d["_path"] = path
	if what == "card":
		_normalise_card(d)
	into[id] = d


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


## Coerce every condition literal to its seam's declared type, once, here. Godot's JSON parser
## returns every number as a float, so `"value": [1,2,3]` would never match an int seam under
## `in`; coercing at load lets the hot path compare like with like.
##
## A leaf naming an unknown seam is recorded and left alone — the linter makes it a build error,
## and refusing the whole card at runtime would lose every leaf that was fine.
static func _coerce_conditions(card: Dictionary) -> void:
	var trees: Array = []
	if typeof(card.get("condition", null)) == TYPE_DICTIONARY:
		trees.append(card["condition"])
	var trig: Variant = card.get("trigger", null)
	if typeof(trig) == TYPE_DICTIONARY and typeof((trig as Dictionary).get("condition", null)) == TYPE_DICTIONARY:
		trees.append(trig["condition"])
	for opt in (card["options"] as Array):
		if typeof(opt) == TYPE_DICTIONARY and typeof((opt as Dictionary).get("requires", null)) == TYPE_DICTIONARY:
			trees.append(opt["requires"])

	for tree in trees:
		for leaf in EvCondition.leaves(tree):
			var d: Dictionary = leaf
			var seam_name: String = String(d.get("seam", d.get("entity_seam", "")))
			if seam_name == "":
				continue
			if not EvSeams.has(seam_name):
				_error(String(card["_path"]), "unknown seam '%s'" % seam_name)
			elif d.has("value"):
				d["value"] = EvSeams.coerce(seam_name, d["value"])


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


## The pool's raw material: cards on this tick that are neither arc steps nor critical. §10.10
## keeps arc steps out — a step drawn from the pool would burn its own one_shot latch and lock
## its arc at that step forever.
static func pool_candidates(tick: String) -> Array:
	var out: Array = []
	for id in card_ids():
		var c: Dictionary = _cards[id]
		if String(c["tick"]) == tick and not c.has("arc") and not (c["tags"] as Array).has("critical"):
			out.append(c)
	return out


static func load_errors() -> Array:
	return _load_errors.duplicate(true)
