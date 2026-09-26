class_name EvCondition
extends RefCounted

# The condition vocabulary (GDD §5). A condition is a nested Dictionary evaluated recursively —
# no parser, no Expression — which keeps it serialisable, lintable and printable in the "why
# didn't this fire" panel.
#
# Two entry points over ONE recursion: `eval` short-circuits (the gate's hot path), `explain`
# does not (the debug panel and the locked-option reason, §5.4). Two implementations could
# disagree, and a panel that disagrees with the gate sends you looking in the wrong place.
#
# Blame is a TREE, not a single leaf: a failing `none` means a child PASSED, which "the failed
# leaf" cannot say.
#
# A failing `any` is one requirement written as a disjunction, so its player-facing reason is one
# authored sentence on the node (lint requires it). The dev panel sees every child's report; the
# player never does — "you were 2 short on headcount" is a lie when the phase gate was the wall.
#
# Leaf literals are coerced to their seam's declared type once, at catalogue load (JSON numbers
# all arrive as floats).

const ALL := "all"
const ANY := "any"
const NONE := "none"
const NOT := "not"

const COMBINATORS := [ALL, ANY, NONE, NOT]


## True when the tree holds. Short-circuits. Never allocates a report.
static func eval(node: Dictionary, ctx: Dictionary = {}) -> bool:
	return _walk(node, ctx, null)


## Full report, no short-circuit. Shape:
##   {node, kind, passed, reason, blame: [<child reports>], detail: {<leaf live values>}}
## `blame` holds only the children responsible for the verdict: for a failing `all` every
## failing child; for a failing `none` the children that PASSED.
static func explain(node: Dictionary, ctx: Dictionary = {}) -> Dictionary:
	var report: Dictionary = {}
	_walk(node, ctx, report)
	return report


## The player-facing sentence for a refusal, or "" when the content did not author one. Never
## derived from a leaf — see the header.
static func reason_of(report: Dictionary) -> String:
	if report.is_empty():
		return ""
	var mine: String = String(report.get("reason", ""))
	if mine != "":
		return mine
	# One failing child with a reason of its own speaks for the node; two do not.
	var spoken: Array = []
	for child in (report.get("blame", []) as Array):
		var r: String = reason_of(child as Dictionary)
		if r != "":
			spoken.append(r)
	return String(spoken[0]) if spoken.size() == 1 else ""


## Every leaf in the tree, depth-first, in authoring order.
static func leaves(node: Dictionary) -> Array:
	var out: Array = []
	_collect_leaves(node, out)
	return out


## Leaves carrying `leaf_key`, e.g. leaves_named(tree, "seam", "finance.mrr"). `value` "" = any.
static func leaves_named(node: Dictionary, leaf_key: String, value: String = "") -> Array:
	var out: Array = []
	for leaf in leaves(node):
		if (leaf as Dictionary).has(leaf_key) and (value == "" or String(leaf[leaf_key]) == value):
			out.append(leaf)
	return out


## Every seam name the tree reads; the linter uses it to prove each one is registered.
static func seams_read(node: Dictionary) -> Array:
	var out: Array = []
	for leaf in leaves(node):
		for key in ["seam", "entity_seam"]:
			if (leaf as Dictionary).has(key) and not out.has(String(leaf[key])):
				out.append(String(leaf[key]))
	return out


static func _collect_leaves(node: Dictionary, out: Array) -> void:
	if node.is_empty():
		return
	var kind: String = _kind_of(node)
	if kind == NOT:
		_collect_leaves(node[NOT] as Dictionary, out)
	elif kind == "leaf":
		out.append(node)
	else:
		for child in (node[kind] as Array):
			if typeof(child) == TYPE_DICTIONARY:
				_collect_leaves(child as Dictionary, out)


# --- The one recursion -----------------------------------------------------

static func _kind_of(node: Dictionary) -> String:
	for c in COMBINATORS:
		if node.has(c):
			return c
	return "leaf"


## `report` is null on the hot path and a Dictionary to fill on the explaining path. Every
## return writes the report first, so the two paths can never disagree about a verdict.
static func _walk(node: Dictionary, ctx: Dictionary, report) -> bool:
	# §5.3: an empty condition is TRUE — "no gate". Used by every unlocked option.
	if node.is_empty():
		_stamp(report, node, "empty", true)
		return true

	var kind: String = _kind_of(node)
	match kind:
		NOT:
			var inner: Dictionary = node[NOT] as Dictionary
			if report == null:
				return not _walk(inner, ctx, null)
			var sub: Dictionary = {}
			var inner_ok: bool = _walk(inner, ctx, sub)
			_stamp(report, node, NOT, not inner_ok, [sub] if inner_ok else [])
			return not inner_ok
		ALL, ANY, NONE:
			# A "hit" is a child verdict that decides the node: a failing child for `all`, a
			# passing one for `any` and `none`. Any hit makes `any` true and the others false;
			# no hit gives the opposite — so (§5.3) empty `all`/`none` are TRUE, empty `any` FALSE.
			var hit: bool = kind != ALL
			var on_hit: bool = kind == ANY
			var hits: Array = []
			var misses: Array = []
			for child in (node[kind] as Array):
				if report == null:
					if _walk(child as Dictionary, ctx, null) == hit:
						return on_hit          # §5.3 short-circuit, hot path only
					continue
				var sub: Dictionary = {}
				if _walk(child as Dictionary, ctx, sub) == hit:
					hits.append(sub)
				else:
					misses.append(sub)
			if report == null:
				return not on_hit
			var ok: bool = on_hit if not hits.is_empty() else not on_hit
			# `all` blames its failing children, `none` its passing ones; a failing `any` blames
			# every child and a passing one blames nobody.
			var blame: Array = hits if kind != ANY else ([] if ok else misses)
			_stamp(report, node, kind, ok, blame)
			return ok
		_:
			return _leaf(node, ctx, report)


static func _stamp(report, node: Dictionary, kind: String, passed: bool,
		blame: Array = [], detail: Dictionary = {}) -> void:
	if report == null:
		return
	report["node"] = node
	report["kind"] = kind
	report["passed"] = passed
	report["reason"] = String(node.get("reason", ""))
	report["blame"] = blame
	report["detail"] = detail


# --- Leaves ----------------------------------------------------------------

static func _leaf(node: Dictionary, ctx: Dictionary, report) -> bool:
	# The key a leaf carries IS its discriminator ({"seam": …} / {"flag": …}), so an author
	# cannot forget to name a type.
	if node.has("seam"):
		return _leaf_seam(node, report)
	if node.has("flag"):
		return _leaf_flag(node, report, true)
	if node.has("flag_unset"):
		return _leaf_flag(node, report, false)
	if node.has("days_since_flag"):
		return _leaf_days_since(node, report)
	if node.has("flag_expires_within"):
		return _leaf_expires_within(node, report)
	if node.has("history"):
		return _leaf_history(node, report)
	if node.has("arc"):
		return _leaf_arc(node, report)
	if node.has("entity_exists"):
		return _leaf_entity_exists(node, ctx, report)
	if node.has("entity_count"):
		return _leaf_entity_count(node, report)
	if node.has("entity_seam"):
		return _leaf_entity_seam(node, ctx, report)

	# §5.3: an unknown leaf is FALSE plus an error, never a silent true. Lint refuses it at build
	# time; this only fires for content that reached runtime some other way.
	push_error("[EvCondition] unrecognised leaf: %s" % str(node))
	_stamp(report, node, "unknown", false, [], {"error": "unrecognised leaf"})
	return false

static func _leaf_seam(node: Dictionary, report) -> bool:
	var name: String = String(node["seam"])
	var actual: Variant = EvSeams.read(name)
	var op: String = String(node.get("op", "=="))
	var want: Variant = node.get("value")
	var ok: bool = _compare(actual, op, want)
	_stamp(report, node, "seam", ok, [], {"seam": name, "actual": actual, "op": op, "want": want})
	return ok


static func _leaf_flag(node: Dictionary, report, want_set: bool) -> bool:
	var key: String = String(node["flag" if want_set else "flag_unset"])
	var is_set: bool = EvFlags.has(key)
	var ok: bool = is_set == want_set
	_stamp(report, node, "flag", ok, [], {"flag": key, "set": is_set})
	return ok


static func _leaf_days_since(node: Dictionary, report) -> bool:
	# "N days after the day stamped in <key>". An ABSENT stamp is FALSE, never day 0 — a run
	# whose product has not shipped must not satisfy "one day after it shipped".
	var key: String = String(node["days_since_flag"])
	if not EvFlags.has_stamp(key):
		_stamp(report, node, "days_since_flag", false, [], {"stamp": key, "stamped": false})
		return false
	var elapsed: int = EvFlags.days_since(key)
	var ok: bool = _compare(elapsed, String(node.get("op", ">=")), node.get("value", 0))
	_stamp(report, node, "days_since_flag", ok, [],
		{"stamp": key, "stamped": true, "days": elapsed, "want": node.get("value", 0)})
	return ok


static func _leaf_expires_within(node: Dictionary, report) -> bool:
	var key: String = String(node["flag_expires_within"])
	var days: int = int(node.get("days", 0))
	var left: int = EvFlags.days_until_expiry(key)
	var ok: bool = left >= 0 and left <= days
	_stamp(report, node, "flag_expires_within", ok, [], {"flag": key, "days_left": left, "within": days})
	return ok


static func _leaf_history(node: Dictionary, report) -> bool:
	var form: String = String(node["history"])
	var ev: String = String(node.get("event", ""))
	var ok: bool = false
	var detail: Dictionary = {"form": form, "event": ev}
	match form:
		"fired":
			detail["fires"] = EvHistory.fire_count(ev)
			ok = int(detail["fires"]) > 0
		"fire_count":
			var n: int = EvHistory.fire_count(ev)
			ok = _compare(n, String(node.get("op", ">=")), node.get("value", 1))
			detail["fires"] = n
		"chose":
			var opt: String = String(node.get("option", ""))
			ok = EvHistory.chose(ev, opt)
			detail["option"] = opt
			detail["chosen"] = EvHistory.last_option(ev)
		"days_since":
			var d: int = EvHistory.days_since(ev)
			ok = d >= 0 and _compare(d, String(node.get("op", ">=")), node.get("value", 0))
			detail["days"] = d
		"resolution":
			var want_res: String = String(node.get("value", ""))
			ok = EvHistory.last_resolution(ev) == want_res
			detail["resolution"] = EvHistory.last_resolution(ev)
		_:
			push_error("[EvCondition] unknown history form: %s" % form)
	_stamp(report, node, "history", ok, [], detail)
	return ok


static func _leaf_arc(node: Dictionary, report) -> bool:
	var form: String = String(node["arc"])
	var arc_id: String = String(node.get("id", ""))
	var state: String = EvArcs.state_of(arc_id)
	var ok: bool = false
	var detail: Dictionary = {"form": form, "arc": arc_id, "state": state}
	match form:
		"active":
			ok = state == EvArcs.STATE_ACTIVE
		"awaiting_subject":
			ok = state == EvArcs.STATE_AWAITING
		"at_step":
			ok = state == EvArcs.STATE_ACTIVE and EvArcs.step_of(arc_id) == int(node.get("step", -1))
			detail["step"] = EvArcs.step_of(arc_id)
		"ended":
			ok = state == EvArcs.STATE_ENDED
			var want_out: String = String(node.get("outcome", ""))
			if ok and want_out != "":
				ok = EvArcs.outcome_of(arc_id) == want_out
			detail["outcome"] = EvArcs.outcome_of(arc_id)
		_:
			push_error("[EvCondition] unknown arc form: %s" % form)
	_stamp(report, node, "arc", ok, [], detail)
	return ok


static func _leaf_entity_exists(node: Dictionary, ctx: Dictionary, report) -> bool:
	var slot: String = String(node["entity_exists"])
	var ok: bool = EvScope.resolved(ctx, slot)
	_stamp(report, node, "entity_exists", ok, [], {"slot": slot, "bound": ctx.get(slot, null)})
	return ok


static func _leaf_entity_count(node: Dictionary, report) -> bool:
	var type_id: String = String(node["entity_count"])
	var n: int = EvScope.count_of(type_id)
	var ok: bool = _compare(n, String(node.get("op", ">=")), node.get("value", 1))
	_stamp(report, node, "entity_count", ok, [], {"type": type_id, "count": n})
	return ok


static func _leaf_entity_seam(node: Dictionary, ctx: Dictionary, report) -> bool:
	# §5.2: `scope` is optional when the card has exactly one slot of that type and REQUIRED
	# when it has more (§17.12 makes the omission a build error, so runtime only has to cope
	# with content that already passed lint).
	var seam: String = String(node["entity_seam"])
	var slot: String = String(node.get("scope", ""))
	var entity_id: String = EvScope.id_in(ctx, slot, seam)
	if entity_id == "":
		_stamp(report, node, "entity_seam", false, [], {"seam": seam, "slot": slot, "bound": false})
		return false
	var actual: Variant = EvSeams.read_for(seam, entity_id)
	var ok: bool = _compare(actual, String(node.get("op", ">=")), node.get("value"))
	_stamp(report, node, "entity_seam", ok, [],
		{"seam": seam, "slot": slot, "entity": entity_id, "actual": actual, "want": node.get("value")})
	return ok


# --- Comparison ------------------------------------------------------------

## The one comparison. `in` takes an Array; everything else is scalar. Numbers are compared
## numerically even when one side arrived from JSON as a float — the coercion pass makes that
## rare, and this makes it harmless when it is not.
static func _compare(actual: Variant, op: String, want: Variant) -> bool:
	if op == "in":
		if typeof(want) != TYPE_ARRAY:
			push_error("[EvCondition] op 'in' needs an Array, got %s" % type_string(typeof(want)))
			return false
		for candidate in (want as Array):
			if _equal(actual, candidate):
				return true
		return false

	match op:
		"==": return _equal(actual, want)
		"!=": return not _equal(actual, want)

	# Ordered comparisons are numeric only. Comparing strings with >= is almost always an
	# authoring mistake, so it says so rather than returning a lexicographic surprise.
	if not _numeric(actual) or not _numeric(want):
		push_error("[EvCondition] op '%s' needs numbers, got %s vs %s"
			% [op, type_string(typeof(actual)), type_string(typeof(want))])
		return false
	var a: float = float(actual)
	var b: float = float(want)
	match op:
		">":  return a > b
		">=": return a >= b
		"<":  return a < b
		"<=": return a <= b
	push_error("[EvCondition] unknown op: %s" % op)
	return false


static func _numeric(v: Variant) -> bool:
	return typeof(v) in [TYPE_INT, TYPE_FLOAT, TYPE_BOOL]


static func _equal(a: Variant, b: Variant) -> bool:
	if _numeric(a) and _numeric(b):
		return is_equal_approx(float(a), float(b))
	return a == b
