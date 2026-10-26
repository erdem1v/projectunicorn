class_name EvCatalog
extends RefCounted

# THE CARD AND ARC CATALOGUE (GDD §2, §3). Read-only, loaded once at boot, never serialised.
#
# Cards are plain Dictionaries, not Resources: every card is on disk, so §16.1 persists IDS and a
# card never round-trips through the save codec.
#
# The loader recurses, so EXCLUDED_DIRS is a rule, not a convenience: cards for mechanics that
# do not exist yet carry empty conditions, an empty condition is TRUE (§5.3), and pooling such a
# directory would fire them in week 1.

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
	card["min_gap_weeks"] = int(card.get("min_gap_weeks", EvTuning.MIN_GAP_WEEKS_DEFAULT))
	card["latch_key"] = String(card.get("latch_key", EvLatches.KEY_RUN))
	if not card.has("latch"):
		card["latch"] = {EvLatches.COOLDOWN: EvLatches.DEFAULT_COOLDOWN_WEEKS}
	if int(card.get("schema", 0)) == SCHEMA_PLAUSIBILITY:
		_compile_plausibility(card)
	# After the compiler, so the leaves it writes are typed like the authored ones.
	_coerce_conditions(card)


# --- Schema v3: the plausibility block --------------------------------------
#
# A card says where it is PLAUSIBLE — phase band, headcount, subject seniority, product state,
# open modules, earliest week — in one mandatory block, and the engine turns that block into
# ordinary condition leaves. One rule, one place: the gate, the linter and --why-fire all read
# leaves, so none of them needs to know the block exists.
#
# Compiled leaves carry `_from: plausibility` so a tool can tell them from authored ones.

const SCHEMA_PLAUSIBILITY := 3

## Where seniority is readable, by EvScope slot type. A slot of any other type has none.
const TENURE_SEAMS := {"employee": "hr.tenure_weeks", "customer": "musteri.tenure_weeks"}

## §2's product states, as the `urun.is_live` each one compiles to. "any" is absent because it
## writes no leaf at all.
const PRODUCT_LIVE := {"pre_launch": false, "live": true}

## §3.1's phase bands; `band_leaves` spells what each one stands for.
const PHASE_BANDS := ["bootstrap_solo", "bootstrap_team", "traction", "series_a"]


static func _compile_plausibility(card: Dictionary) -> void:
	var p: Dictionary = card.get("plausibility", {})
	var compiled: Array = []

	var bands: Array = []
	for band in (p.get("phase_band", []) as Array):
		var leaves: Array = band_leaves(String(band))
		# An unknown band is the linter's error (P1). Compiling it as an empty `all` would read
		# TRUE (§5.3) and admit the card in every phase, which is the opposite of the finding.
		if not leaves.is_empty():
			bands.append({"all": leaves})
	if not bands.is_empty():
		compiled.append({"any": bands})

	# A headcount floor of nobody and a min_week of zero say nothing, and compiling them would
	# hang an always-true leaf on nearly every card, burying --why-fire's plausibility block. A
	# shape other than [min, max] is the linter's error (P1), so the loader writes no leaf for it.
	var headcount: Array = p.get("headcount", [])
	if headcount.size() == 2:
		if int(headcount[0]) > 0:
			compiled.append(_plaus_leaf("hr.headcount", ">=", int(headcount[0])))
		if headcount[1] != null:
			compiled.append(_plaus_leaf("hr.headcount", "<=", int(headcount[1])))

	# An unknown product state is the linter's error (P1), like an unknown band: compiling a guess
	# would pin the card to one side of the launch while the block names neither.
	var product: String = String(p.get("product", "any"))
	if PRODUCT_LIVE.has(product):
		compiled.append(_plaus_leaf("urun.is_live", "==", bool(PRODUCT_LIVE[product])))

	for module in (p.get("modules", []) as Array):
		compiled.append(_plaus_leaf("build.module_unlocked." + String(module), "==", true))

	var min_week: int = int(p.get("min_week", 0))
	if min_week > 0:
		compiled.append(_plaus_leaf("time.week", ">=", min_week))

	var authored: Dictionary = card.get("condition", {})
	card["condition"] = {"all": ([authored] if not authored.is_empty() else []) + compiled}

	# Seniority filters the SELECTOR, not the card: a card about someone who has been here a
	# while must BIND such a person, not bind anyone and then refuse at the gate. A system card
	# is given its subject, so filtering would only lose the request (§3.1).
	if bool(card.get("system", false)):
		return
	for slot in (card["scope"] as Dictionary):
		var spec: Dictionary = card["scope"][slot]
		var seam: String = String(TENURE_SEAMS.get(String(spec.get("type", "")), ""))
		if seam == "" or not spec.has("select"):
			continue
		var leaf: Dictionary = {"entity_seam": seam, "scope": slot, "op": ">=",
			"value": tenure_floor(card, slot), "_from": "plausibility"}
		var where: Dictionary = spec.get("where", {})
		spec["where"] = {"all": ([where] if not where.is_empty() else []) + [leaf]}


## The leaves a phase band stands for, empty for a band §3.1 does not name, so the linter reads
## an unknown band off an empty answer.
static func band_leaves(band: String) -> Array:
	match band:
		"bootstrap_solo":
			return [_plaus_leaf("phase.current", "==", 1), _plaus_leaf("hr.headcount", "==", 0)]
		"bootstrap_team":
			return [_plaus_leaf("phase.current", "==", 1), _plaus_leaf("hr.headcount", ">=", 1)]
		"traction":
			return [_plaus_leaf("phase.current", "==", 2)]
		"series_a":
			return [_plaus_leaf("phase.current", "==", 3)]
	return []


static func _plaus_leaf(seam: String, op: String, value: Variant) -> Dictionary:
	return {"seam": seam, "op": op, "value": value, "_from": "plausibility"}


## Weeks the subject of `slot` must have been aboard: the card's own figure (per slot where it
## names one) or its family's floor, whichever is higher. The linter asks for the same number.
static func tenure_floor(card: Dictionary, slot: String) -> int:
	var p: Dictionary = card.get("plausibility", {})
	var own: Variant = (p.get("subject_tenure_by_slot", {}) as Dictionary) \
		.get(slot, p.get("subject_tenure_weeks", 0))
	return maxi(int(own),
		int(EvTuning.FAMILY_SUBJECT_TENURE.get(String(card.get("family", "")), 0)))


## Coerce every condition literal to its seam's declared type, once, here. Godot's JSON parser
## returns every number as a float, so `"value": [1,2,3]` would never match an int seam under
## `in`; coercing at load lets the hot path compare like with like. The same walk gives a `year_roll`
## leaf the card's id as its key: a condition does not know the card it sits in.
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
	for spec in (card.get("scope", {}) as Dictionary).values():
		if typeof((spec as Dictionary).get("where", null)) == TYPE_DICTIONARY:
			trees.append(spec["where"])

	for tree in trees:
		for leaf in EvCondition.leaves(tree):
			var d: Dictionary = leaf
			# A year's roll is the card's own unless the leaf names a key to share one with another card.
			if d.has("year_roll") and not d.has("key"):
				d["key"] = card["id"]
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


## The pool's raw material: cards on this tick that are not arc steps, critical or quiet. §10.10
## keeps arc steps out — a step drawn from the pool would burn its own one_shot latch and lock
## its arc at that step forever. A quiet card only fills a week nothing else filled (§13.6).
static func pool_candidates(tick: String) -> Array:
	var out: Array = []
	for id in card_ids():
		var c: Dictionary = _cards[id]
		var tags: Array = c["tags"]
		if String(c["tick"]) == tick and not c.has("arc") and not tags.has("critical") and not tags.has("quiet"):
			out.append(c)
	return out


static func load_errors() -> Array:
	return _load_errors.duplicate(true)
