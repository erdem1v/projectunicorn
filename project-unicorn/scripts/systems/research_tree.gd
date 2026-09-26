class_name ResearchTree
extends RefCounted

# Ar-Ge GDD §4 · §13 — the research tree's TUNABLE half, loaded from
# res://data/techtree/rnd_tree.json and validated against ResearchSeam at load.
#
# WHY THE DATA IS SPLIT IN TWO, and this is load-bearing rather than taste:
#   ResearchSeam.NODES keeps the ID / FAMILY / PLACE spine as a compile-time const,
#   because ProductLines._validate_step reads it during ITS OWN load. Moving that spine
#   into a file would make the line validator depend on file-I/O ordering between two
#   lazily-loaded statics that nothing sequences. The const costs nothing and removes the
#   whole class of bug.
#   Everything a calibration pass touches — effort, cash, areas, stars — plus the four
#   hidden lines' raw line dicts live HERE, so §13's numbers move without a recompile and
#   the hidden lines sit in the same shape data/product/lines/*.json already uses.
#
# LOUD FAILURE, the ProductLines idiom: every rule below appends to _load_errors AND
# push_error()s. A tree that violates its own shape must not boot quietly — the whole
# point of §3.1 is that nothing telegraphed is unreachable, and a silent data typo is
# exactly how that promise breaks.

const TREE_PATH := "res://data/techtree/rnd_tree.json"

## §5.2 — hangi ailenin araştırması hangi alandan okunur. Ar-Ge kendi kopyasını
## tutmuyor; bu tablo AİLE→ALAN eşlemesidir ve §4'ün başlıklarından gelir.
const FAMILY_AREA := {
	"capability": "product",
	"platform": "engineering",
	"practice": "qa",
	"design": "design",
}

## §5.2 — kök ★1 · dal ★2 · devam ★2 + ★2.
const STARS_BY_PLACE := {"root": 1, "branch": 2, "continuation": 2}

## §13 — efor bantları yere göre.
const EFFORT_BANDS := {"root": [40, 50], "branch": [70, 90], "continuation": [70, 90]}

## §13 — nakit tablosu TAM olarak budur. Bir aralık değil, bir TABLO: aralık olsaydı
## sonraki bir düzenleme dördüncü bir maliyeti sessizce icat edebilirdi.
const CASH_TABLE := {"ai_engine": 600, "security_cert": 900, "analytics_engine": 400}

## §3.1 sapma tavanı, makinece kontrol edilebilir tek okuması: çapraz koşul DAİMA
## başka bir ailenin UCUZ ve ERKEN düğümünü işaret eder.
const CROSS_EFFORT_CEIL := 50

## §13'ün on katsayısı. `enterprise_trust` ve `product_note` katsayı DEĞİL kancadır
## (§4.2'nin balina imza koşulu, §6'nın aylık notu) — ayrı sayılırlar.
const COEFFICIENT_EFFECTS := [
	"load_divisor", "validation_throughput", "bug_rate_ceil", "beta_decay",
	"overage_satisfaction", "inflow_base", "license_cost", "b2c_conversion",
	"experience_effort", "ai_usage_weight",
]
const HOOK_EFFECTS := ["enterprise_trust", "product_note"]

static var _nodes: Dictionary = {}
static var _hidden: Dictionary = {}
static var _children: Dictionary = {}
static var _k_arge: float = 1.0
static var _report_period: int = 30
static var _loaded := false
static var _load_errors: Array[String] = []


## Lazy load. Every accessor goes through it, so a caller can never read a half-built table.
static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_load()


## Test/debug seam: forget everything and re-read from disk.
static func reload() -> void:
	_nodes.clear()
	_hidden.clear()
	_children.clear()
	_load_errors.clear()
	_loaded = false
	ensure_loaded()


static func load_errors() -> Array[String]:
	ensure_loaded()
	return _load_errors.duplicate()


# ---------------------------------------------------------------- loading

static func _load() -> void:
	var doc: Dictionary = _read_json(TREE_PATH)
	if doc.is_empty():
		_fail("%s missing or unreadable" % TREE_PATH)
		return

	_k_arge = float(doc.get("k_arge", 1.0))
	_report_period = int(doc.get("report_period_days", 30))
	if _k_arge <= 0.0:
		_fail("k_arge must be positive, got %s" % _k_arge)
	if _report_period <= 0:
		_fail("report_period_days must be positive, got %d" % _report_period)

	_nodes = (doc.get("nodes", {}) as Dictionary).duplicate(true)
	_hidden = (doc.get("hidden_lines", {}) as Dictionary).duplicate(true)

	_validate_node_set()
	_validate_rows()
	_validate_cross_links()
	_validate_hidden_lines()
	_validate_effects()
	_build_children()


## Set equality with the seam, BOTH ways. Not "contains": a typo in either file has to be
## loud, and a missing row is as wrong as an extra one.
static func _validate_node_set() -> void:
	for id in ResearchSeam.NODES.keys():
		if not _nodes.has(id):
			_fail("tree is missing node '%s', which ResearchSeam.NODES declares" % id)
	for id in _nodes.keys():
		if not ResearchSeam.NODES.has(id):
			_fail("tree declares node '%s', which is not one of Ar-Ge §4's twenty" % id)


## Per row: parent chain, arity, area, stars, effort band, cash table.
static func _validate_rows() -> void:
	var roots := 0
	var branches := 0
	var conts := 0
	for id in _nodes.keys():
		if not ResearchSeam.NODES.has(id):
			continue
		var row: Dictionary = _nodes[id] as Dictionary
		var place: String = ResearchSeam.placement(String(id))
		var family: String = ResearchSeam.family(String(id))
		var parent: String = String(row.get("parent", ""))

		match place:
			ResearchSeam.PLACE_ROOT:
				roots += 1
				if parent != "":
					_fail("%s is a root but names parent '%s'" % [id, parent])
			ResearchSeam.PLACE_BRANCH:
				branches += 1
				if parent == "" or ResearchSeam.placement(parent) != ResearchSeam.PLACE_ROOT:
					_fail("%s is a branch; its parent must be its family's root, got '%s'" % [id, parent])
			ResearchSeam.PLACE_CONT:
				conts += 1
				if parent == "" or ResearchSeam.placement(parent) != ResearchSeam.PLACE_BRANCH:
					_fail("%s is a continuation; its parent must be a branch, got '%s'" % [id, parent])
		if parent != "" and ResearchSeam.family(parent) != family:
			_fail("%s parent '%s' is in family '%s', not '%s'"
				% [id, parent, ResearchSeam.family(parent), family])

		# Arity and the family's own area first (§5.2).
		var areas: Array = row.get("areas", []) as Array
		var want_n: int = 2 if place == ResearchSeam.PLACE_CONT else 1
		if areas.size() != want_n:
			_fail("%s is a %s and wants %d area(s), got %d" % [id, place, want_n, areas.size()])
		elif String(areas[0]) != String(FAMILY_AREA.get(family, "")):
			_fail("%s first area is '%s'; family '%s' reads '%s'"
				% [id, areas[0], family, FAMILY_AREA.get(family, "")])
		for a in areas:
			if not HRConstants.AREAS.has(String(a)):
				_fail("%s names unknown area '%s'" % [id, a])

		# The star ladder (§5.2).
		var stars: int = int(row.get("stars", 0))
		var want_stars: int = STARS_BY_PLACE[place]
		if stars != want_stars:
			_fail("%s is a %s and wants ★%d, got ★%d" % [id, place, want_stars, stars])
		if stars < 1 or stars > HRConstants.STAR_MAX:
			_fail("%s stars ★%d is outside 1..%d" % [id, stars, HRConstants.STAR_MAX])

		# Effort band and the cash table (§13).
		var effort: int = int(row.get("effort", 0))
		var band: Array = EFFORT_BANDS[place]
		if effort < int(band[0]) or effort > int(band[1]):
			_fail("%s effort %d is outside the %s band %s" % [id, effort, place, band])
		var cash: int = int(row.get("cash", 0))
		var want_cash: int = int(CASH_TABLE.get(id, 0))
		if cash != want_cash:
			_fail("%s cash is $%d; §13's table says $%d" % [id, cash, want_cash])

	if roots != 4 or branches != 8 or conts != 8:
		_fail("tree shape is %d/%d/%d; §3 wants 4 roots / 8 branches / 8 continuations"
			% [roots, branches, conts])


## §3's cross-family rule and §3.1's sapma tavanı.
static func _validate_cross_links() -> void:
	var found: Array[String] = []
	for id in _nodes.keys():
		var cross: String = String((_nodes[id] as Dictionary).get("cross", ""))
		if cross == "":
			continue
		found.append(String(id))
		var place: String = ResearchSeam.placement(String(id))
		if place != ResearchSeam.PLACE_CONT:
			_fail("%s carries a cross condition but is a %s; §3 puts them on continuations only"
				% [id, place])
		if not ResearchSeam.NODES.has(cross):
			_fail("%s cross target '%s' is not one of the twenty" % [id, cross])
			continue
		if ResearchSeam.family(cross) == ResearchSeam.family(String(id)):
			_fail("%s cross target '%s' is in its OWN family; that is not a cross link" % [id, cross])
		if ResearchSeam.placement(cross) != ResearchSeam.PLACE_ROOT:
			_fail("%s cross target '%s' is a %s; §3.1's ceiling wants a root"
				% [id, cross, ResearchSeam.placement(cross)])
		var t: Dictionary = _nodes.get(cross, {}) as Dictionary
		if int(t.get("effort", 0)) > CROSS_EFFORT_CEIL or int(t.get("cash", 0)) > 0:
			_fail("%s cross target '%s' costs %d effort / $%d; §3.1 wants a cheap early node"
				% [id, cross, int(t.get("effort", 0)), int(t.get("cash", 0))])
	if found.size() != 4:
		_fail("tree has %d cross links; §13 says exactly 4" % found.size())


## §4.5 — the four hidden lines, their axes and the single branch-level one.
static func _validate_hidden_lines() -> void:
	var openers: Dictionary = {}
	for id in _nodes.keys():
		var line_id: String = String((_nodes[id] as Dictionary).get("opens_line", ""))
		if line_id == "":
			continue
		if openers.has(line_id):
			_fail("hidden line '%s' is opened by both '%s' and '%s'"
				% [line_id, openers[line_id], id])
		openers[line_id] = String(id)
		if not _hidden.has(line_id):
			_fail("%s opens '%s', which no hidden_lines entry declares" % [id, line_id])

	if openers.size() != 4:
		_fail("%d nodes open a hidden line; §4.5 says exactly 4" % openers.size())

	var axis_tally: Dictionary = {}
	var branch_openers: Array[String] = []
	for line_id in _hidden.keys():
		var hl: Dictionary = _hidden[line_id] as Dictionary
		var axis: String = String(hl.get("axis", ""))
		if not QualityModel.AXES.has(axis):
			_fail("hidden line '%s' has unknown axis '%s'" % [line_id, axis])
		axis_tally[axis] = int(axis_tally.get(axis, 0)) + 1
		var by: String = String(hl.get("opened_by", ""))
		if String(openers.get(line_id, "")) != by:
			_fail("hidden line '%s' says opened_by '%s'; the node table disagrees" % [line_id, by])
		if by != "" and ResearchSeam.placement(by) == ResearchSeam.PLACE_BRANCH:
			branch_openers.append(by)
		# §12.1 / §13.5 — only the demo line carries content. The other three are declared
		# and never registered (§4.5.2), so an empty raw is CORRECT, not missing.
		var authored: bool = bool(hl.get("authored", false))
		var raw: Dictionary = hl.get("raw", {}) as Dictionary
		if authored and raw.is_empty():
			_fail("hidden line '%s' is marked authored but carries no raw line" % line_id)
		if not authored and not raw.is_empty():
			_fail("hidden line '%s' is deferred to EA but carries a raw line" % line_id)
		if authored:
			_validate_hidden_k3(line_id, raw)

	# §4.5's applied redistribution: İnovasyon 1 · Kararlılık 2 · Deneyim 1.
	if int(axis_tally.get("innovation", 0)) != 1 or int(axis_tally.get("stability", 0)) != 2 \
			or int(axis_tally.get("experience", 0)) != 1:
		_fail("hidden line axis tally is %s; §4.5 wants innovation 1 / stability 2 / experience 1"
			% axis_tally)

	# §13.5's sealed single exception — one hidden line at branch level, and it is
	# test_automation's. Asserting the NAME stops the exception being silently doubled.
	if branch_openers.size() != 1:
		_fail("%d hidden lines sit at branch level; §13.5 allows exactly one" % branch_openers.size())
	elif branch_openers[0] != "test_automation":
		_fail("the branch-level hidden line is opened by '%s'; §13.5's exception is test_automation"
			% branch_openers[0])


## `register_runtime_line` routes through the SAME validator as every catalog line, so a
## hidden line's own K3 must carry a research node and that node must be root-or-branch
## (§4.5). Without this, the failure surfaces as a hard push_error at the moment a player
## completes the node, hours into a run.
static func _validate_hidden_k3(line_id: String, raw: Dictionary) -> void:
	var steps: Array = raw.get("steps", []) as Array
	if steps.size() != 3:
		_fail("hidden line '%s' has %d steps, expected 3" % [line_id, steps.size()])
		return
	var k3: Dictionary = steps[2] as Dictionary
	var node: String = String((k3.get("requires", {}) as Dictionary).get("research", ""))
	if node == "":
		_fail("hidden line '%s' K3 carries no research node; the catalog will refuse it" % line_id)
		return
	if not ResearchSeam.is_node(node):
		_fail("hidden line '%s' K3 binds '%s', not one of the twenty" % [line_id, node])
	elif not ResearchSeam.may_gate_visible_step(node):
		_fail("hidden line '%s' K3 binds '%s', a %s node — §3.1 forbids it and the catalog would refuse the line"
			% [line_id, node, ResearchSeam.placement(node)])


## §13's ten coefficients, each present exactly once and owned by a real system.
static func _validate_effects() -> void:
	var seen: Dictionary = {}
	for id in _nodes.keys():
		var eff: String = String((_nodes[id] as Dictionary).get("effect", ""))
		if eff == "":
			continue
		if seen.has(eff):
			_fail("effect '%s' is claimed by both '%s' and '%s'" % [eff, seen[eff], id])
		seen[eff] = String(id)
		if not COEFFICIENT_EFFECTS.has(eff) and not HOOK_EFFECTS.has(eff):
			_fail("%s carries unknown effect id '%s'" % [id, eff])
	for eff in COEFFICIENT_EFFECTS:
		if not seen.has(eff):
			_fail("§13's coefficient '%s' is on no node" % eff)


static func _build_children() -> void:
	for id in _nodes.keys():
		var parent: String = String((_nodes[id] as Dictionary).get("parent", ""))
		if parent != "":
			_children.get_or_add(parent, []).append(String(id))
	for k in _children.keys():
		(_children[k] as Array).sort()


static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[ResearchTree] cannot open %s (err %d)" % [path, FileAccess.get_open_error()])
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[ResearchTree] JSON parse failed: %s" % path)
		return {}
	return parsed as Dictionary


static func _fail(reason: String) -> void:
	_load_errors.append(reason)
	push_error("[ResearchTree] %s" % reason)


# ---------------------------------------------------------------- accessors

static func node_ids() -> Array:
	ensure_loaded()
	return _nodes.keys()


static func has(node_id: String) -> bool:
	ensure_loaded()
	return _nodes.has(node_id)


static func _row(node_id: String) -> Dictionary:
	ensure_loaded()
	return _nodes.get(node_id, {}) as Dictionary


static func effort_of(node_id: String) -> int:
	return int(_row(node_id).get("effort", 0))


static func cash_of(node_id: String) -> int:
	return int(_row(node_id).get("cash", 0))


## §5.2 — the areas this node reads its speed from. Stars OUTSIDE these do not count (§5.4).
static func areas_of(node_id: String) -> Array:
	return (_row(node_id).get("areas", []) as Array).duplicate()


static func stars_of(node_id: String) -> int:
	return int(_row(node_id).get("stars", 0))


static func parent_of(node_id: String) -> String:
	return String(_row(node_id).get("parent", ""))


static func cross_of(node_id: String) -> String:
	return String(_row(node_id).get("cross", ""))


static func opens_line_of(node_id: String) -> String:
	return String(_row(node_id).get("opens_line", ""))


## §8 — does the node card carry a named cash line ("GPU kirası $600")?
static func has_cost_label(node_id: String) -> bool:
	return bool(_row(node_id).get("cost_label", false))


static func children_of(node_id: String) -> Array:
	ensure_loaded()
	return (_children.get(node_id, []) as Array).duplicate()


static func k_arge() -> float:
	ensure_loaded()
	return _k_arge


static func report_period_days() -> int:
	ensure_loaded()
	return _report_period


# ---------------------------------------------------------------- hidden lines

static func hidden_line_ids() -> Array:
	ensure_loaded()
	return _hidden.keys()


static func hidden_line_axis(line_id: String) -> String:
	ensure_loaded()
	return String((_hidden.get(line_id, {}) as Dictionary).get("axis", ""))


## §12.1 — only KENDİ KENDİNE SERVİS is written for the demo. The other three are
## declared so their ids exist and are NEVER registered (§4.5.2).
static func hidden_line_authored(line_id: String) -> bool:
	ensure_loaded()
	return bool((_hidden.get(line_id, {}) as Dictionary).get("authored", false))


static func hidden_line_raw(line_id: String) -> Dictionary:
	ensure_loaded()
	return ((_hidden.get(line_id, {}) as Dictionary).get("raw", {}) as Dictionary).duplicate(true)
