class_name EvCondition
extends RefCounted

# The condition vocabulary (GDD §5). A condition is a nested Dictionary. There is no parser,
# no lexer and no Expression — recursive evaluation over plain data, which is what makes a
# condition serialisable, lintable and printable in the "why didn't this fire" panel.
#
# THREE THINGS THIS FILE DOES THAT THE OLD ENGINE COULD NOT
#
# 1. It NESTS. The old vocabulary was 29 flat types joined by a hard AND
#    (event_manager.gd:506-517), so "either the money or the relationship" was inexpressible
#    and the trigger went into GDScript instead — the I5 violation the GDD names.
#
# 2. It EXPLAINS. §5.4 wants a structured refusal, not a bool. But §5.3 also wants
#    short-circuiting, and those two fight: a report needs every failing leaf, short-circuit
#    stops at the first. So there are two entry points over ONE recursion —
#
#        eval(node)     short-circuits. The gate's hot path, once per card per tick.
#        explain(node)  does not. The debug panel and the locked-option reason.
#
#    One recursion, not two implementations, because the failure mode of two is that the
#    panel and the gate disagree — and a panel that disagrees with the gate is worse than no
#    panel, since it sends you looking in the wrong place.
#
# 3. It reports BLAME AS A TREE, not a single leaf. A failing `none: [flag: shutter_active]`
#    means a child PASSED and that is the problem; "the failed leaf" cannot say that. The
#    report mirrors the node structure and collapses to the blame path.
#
# WHAT `any` REPORTS WHEN IT FAILS. All of its children failed, so naming one is arbitrary and
# usually misleading. The node itself is the failing unit: an `any` is one requirement the
# author wrote as a disjunction ("the money or the relationship"), so its player-facing reason
# is one authored sentence on the node. Lint requires that sentence (§17 addition). The dev
# panel gets every child's report underneath, ranked by nearest-miss; the player never does,
# because "you were 2 short on headcount" is a lie when the phase gate was the real wall.
#
# TYPE COERCION IS NOT OPTIONAL. Godot's JSON parser returns TYPE_FLOAT for every number —
# save_codec.gd:27-38 measured it and the whole codec is shaped around it. So a leaf authored
# as {"seam": "hr.headcount", "op": "in", "value": [1,2,3]} loads as [1.0, 2.0, 3.0] and an
# `in` test against an int seam silently never matches. Leaves are therefore coerced ONCE at
# catalogue load against the seam's declared type, and a leaf whose seam is unknown refuses
# the card there rather than warning forever at runtime.

# --- Node kinds ------------------------------------------------------------

const ALL := "all"
const ANY := "any"
const NONE := "none"
const NOT := "not"

const COMBINATORS := [ALL, ANY, NONE, NOT]

# Leaf keys, in the order the evaluator probes them.
const LEAF_KEYS := [
	"seam", "flag", "flag_unset", "days_since_flag", "flag_expires_within",
	"history", "arc", "entity_exists", "entity_count", "entity_seam",
]


# --- Public: the hot path --------------------------------------------------

## True when the tree holds. Short-circuits. Never allocates a report.
static func eval(node: Dictionary, ctx: Dictionary = {}) -> bool:
	return _walk(node, ctx, null)


# --- Public: the explaining path -------------------------------------------

## Full report, no short-circuit. Shape:
##   {node: <the dict>, kind: <String>, passed: <bool>, reason: <String|"">,
##    blame: [<child reports>], detail: {<leaf-specific live values>}}
## `blame` holds only the children responsible for the verdict: for a failing `all` that is
## every failing child; for a failing `none` it is the children that PASSED.
static func explain(node: Dictionary, ctx: Dictionary = {}) -> Dictionary:
	var report: Dictionary = {}
	_walk(node, ctx, report)
	return report


## The player-facing sentence for a refusal, or "" when the content did not author one.
## Deliberately never derived from a leaf — see the header.
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


# --- Public: leaf enumeration ----------------------------------------------

## Every leaf in the tree, depth-first, in authoring order.
##
## THIS IS NOT A CONVENIENCE. phase_gate_system.gd:200-215 does not merely evaluate the gate
## condition — it walks the array and switches on each leaf's type to build the Series A
## readout the player actually sees (mrr_ok, streak, brand_ok, progress). That code consumes
## the vocabulary's SHAPE, not its result. Nesting breaks it unless enumeration exists, so
## enumeration ships in the same phase nesting does.
static func leaves(node: Dictionary) -> Array:
	var out: Array = []
	_collect_leaves(node, out)
	return out


## Leaves whose named key matches, e.g. leaves_named(tree, "seam", "finance.mrr").
## `value` of "" matches any.
static func leaves_named(node: Dictionary, leaf_key: String, value: String = "") -> Array:
	var out: Array = []
	for leaf in leaves(node):
		if not (leaf as Dictionary).has(leaf_key):
			continue
		if value != "" and String((leaf as Dictionary)[leaf_key]) != value:
			continue
		out.append(leaf)
	return out


## Every seam name the tree reads. Generated, never authored — it is what a dirty-flag
## optimisation would need, and what the linter uses to prove every named seam is registered.
static func seams_read(node: Dictionary) -> Array:
	var out: Array = []
	for leaf in leaves(node):
		var d: Dictionary = leaf
		if d.has("seam") and not out.has(String(d["seam"])):
			out.append(String(d["seam"]))
		if d.has("entity_seam") and not out.has(String(d["entity_seam"])):
			out.append(String(d["entity_seam"]))
	return out


static func _collect_leaves(node: Dictionary, out: Array) -> void:
	if node.is_empty():
		return
	var kind: String = _kind_of(node)
	if kind == NOT:
		_collect_leaves(node[NOT] as Dictionary, out)
		return
	if kind in [ALL, ANY, NONE]:
		for child in (node[kind] as Array):
			if typeof(child) == TYPE_DICTIONARY:
				_collect_leaves(child as Dictionary, out)
		return
	out.append(node)


# --- The one recursion -----------------------------------------------------

static func _kind_of(node: Dictionary) -> String:
	for c in COMBINATORS:
		if node.has(c):
			return c
	return "leaf"


## `report` is null on the hot path and a Dictionary to fill on the explaining path. Every
## early return writes the report first, so the two paths can never disagree about a verdict.
static func _walk(node: Dictionary, ctx: Dictionary, report) -> bool:
	# §5.3: an empty condition is TRUE — "no gate". Used by every unlocked option.
	if node.is_empty():
		_stamp(report, node, "empty", true, [], {})
		return true

	var kind: String = _kind_of(node)
	var authored_reason: String = String(node.get("reason", ""))

	match kind:
		ALL:
			var kids: Array = node[ALL] as Array
			var blame: Array = []
			var ok: bool = true
			for child in kids:
				var cd: Dictionary = child as Dictionary
				if report == null:
					if not _walk(cd, ctx, null):
						return false          # §5.3 short-circuit, hot path only
				else:
					var sub: Dictionary = {}
					if not _walk(cd, ctx, sub):
						ok = false
						blame.append(sub)
			_stamp(report, node, ALL, ok, blame, {})
			return ok

		ANY:
			var kids_any: Array = node[ANY] as Array
			# §5.3: an empty `any` is FALSE. Nothing to satisfy it.
			var blame_any: Array = []
			var ok_any: bool = false
			for child in kids_any:
				var cd2: Dictionary = child as Dictionary
				if report == null:
					if _walk(cd2, ctx, null):
						return true
				else:
					var sub2: Dictionary = {}
					if _walk(cd2, ctx, sub2):
						ok_any = true
					else:
						blame_any.append(sub2)
			if report == null:
				return false
			# Only blame children when the node itself failed; a passing `any` blames nobody.
			_stamp(report, node, ANY, ok_any, [] if ok_any else blame_any, {})
			return ok_any

		NONE:
			var kids_none: Array = node[NONE] as Array
			# §5.3: an empty `none` is TRUE.
			var blame_none: Array = []
			var ok_none: bool = true
			for child in kids_none:
				var cd3: Dictionary = child as Dictionary
				if report == null:
					if _walk(cd3, ctx, null):
						return false
				else:
					var sub3: Dictionary = {}
					if _walk(cd3, ctx, sub3):
						ok_none = false
						# The child that PASSED is the one to blame — this is the case a
						# single "failed_leaf" field cannot express.
						blame_none.append(sub3)
			_stamp(report, node, NONE, ok_none, blame_none, {})
			return ok_none

		NOT:
			var inner: Dictionary = node[NOT] as Dictionary
			if report == null:
				return not _walk(inner, ctx, null)
			var sub4: Dictionary = {}
			var inner_ok: bool = _walk(inner, ctx, sub4)
			_stamp(report, node, NOT, not inner_ok, [sub4] if inner_ok else [], {})
			return not inner_ok

		_:
			return _leaf(node, ctx, report, authored_reason)


static func _stamp(report, node: Dictionary, kind: String, passed: bool,
		blame: Array, detail: Dictionary) -> void:
	if report == null:
		return
	report["node"] = node
	report["kind"] = kind
	report["passed"] = passed
	report["reason"] = String(node.get("reason", ""))
	report["blame"] = blame
	report["detail"] = detail


# --- Leaves ----------------------------------------------------------------

static func _leaf(node: Dictionary, ctx: Dictionary, report, _authored: String) -> bool:
	# Dispatch on which key the leaf carries, not on a "type" field: the GDD writes leaves as
	# {"seam": …} / {"flag": …} / {"history": …}, so the key IS the discriminator and an
	# author cannot forget to name it.
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

	# §5.3: an unknown leaf is FALSE plus an error, never a silent true. The linter refuses it
	# at build time; this branch only fires for content that reached runtime some other way.
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
	# whose product has not shipped must not satisfy "one day after it shipped". The old
	# engine documented this at event_manager.gd:396-401 and it is carried forward verbatim.
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
			ok = EvHistory.fire_count(ev) > 0
			detail["fires"] = EvHistory.fire_count(ev)
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
