class_name EvWhy
extends RefCounted

# "WHY DIDN'T THIS FIRE" (GDD §19.2).
#
#     godot --headless --path . --why-fire=<event_id>
#
# §19.2 calls this the calibration round's precondition, and that is the right framing: you
# cannot tune a pool you cannot interrogate. Before this existed the answer to "why have I
# never seen that card" was to read four files and guess.
#
# THE ONE DESIGN RULE HERE: this panel must never be able to disagree with the gate. It does
# not re-derive anything — it calls `EvGate.propose()` and prints the `Verdict` the real
# admission path would have produced, including the condition report the real evaluator built.
# A panel that computes its own answer is worse than no panel, because it sends you looking in
# the wrong place with confidence.
#
# What it answers, in §19.2's own order:
#   · which gate step refused it (G1-G8)
#   · the failing condition leaves, WITH the live seam values behind them
#   · latch state: last fire, cooldown remaining
#   · what it is waiting on: a signal, an arc, a day
#   · and — the one nobody thinks to ask — whether the signal it waits on has EVER been emitted

static func report(event_id: String) -> String:
	var out: PackedStringArray = []
	out.append("=== WHY DIDN'T '%s' FIRE? ===" % event_id)
	out.append("day %d, hour %02d, phase %d" % [GameState.day, GameState.current_hour, GameState.phase])
	out.append("")

	if not EvCatalog.has_card(event_id):
		out.append("G1  NO SUCH CARD.")
		out.append("    Nothing in data/events/cards/ carries that id.")
		var near: Array = _nearest_ids(event_id)
		if not near.is_empty():
			out.append("    Did you mean: %s" % ", ".join(near))
		return "\n".join(out)

	var card: Dictionary = EvCatalog.card(event_id)
	out.append("file      %s" % card.get("_path", "?"))
	out.append("class     %s   tick: %s   category: %s"
		% [card["class"], card["tick"], card["category"]])
	out.append("tags      %s" % str(card["tags"]))
	if card.has("arc"):
		out.append("arc       %s" % card["arc"])
	out.append("")

	# --- where it already is -----------------------------------------------
	if EvQueue.active_id() == event_id:
		out.append("IT IS ON SCREEN RIGHT NOW.")
		return "\n".join(out)
	if EvQueue.has(event_id):
		out.append("IT IS QUEUED and waiting for the modal to free up.")
		out.append("  ahead of it: %s" % str(EvQueue.ids()))
		return "\n".join(out)
	if EvPapers.has(event_id):
		out.append("IT IS ON THE DESK as a paper, %d day(s) left."
			% EvPapers.days_left(event_id))
		return "\n".join(out)
	if EvSchedule.has(event_id):
		for e in EvSchedule.pending():
			if String((e as Dictionary)["event_id"]) == event_id:
				out.append("IT IS SCHEDULED for day %d — %d day(s) away."
					% [int((e as Dictionary)["fire_on_day"]),
						int((e as Dictionary)["fire_on_day"]) - GameState.day])
				return "\n".join(out)

	# --- history and latch --------------------------------------------------
	var fires: int = EvHistory.fire_count(event_id)
	out.append("HISTORY   fired %d time(s)%s"
		% [fires, "" if fires == 0 else ", last on day %d as '%s'"
			% [EvHistory.last_day(event_id), EvHistory.last_resolution(event_id)]])
	if fires > 0 and EvHistory.last_option(event_id) != "":
		out.append("          the player chose '%s'" % EvHistory.last_option(event_id))

	var latch_key: String = EvLatches.key_for(event_id, String(card["latch_key"]), "")
	var latch_block: String = EvLatches.blocked_reason(card["latch"], latch_key)
	out.append("LATCH     %s   key: %s" % [str(card["latch"]), latch_key])
	if latch_block != "":
		out.append("          BLOCKED: %s" % latch_block)
		var left: int = EvLatches.cooldown_left(card["latch"], latch_key)
		if left > 0:
			out.append("          available again on day %d" % (GameState.day + left))
	out.append("")

	# --- what is it waiting on ---------------------------------------------
	var trigger: Dictionary = card.get("trigger", {})
	if trigger.has("signal"):
		var signal_name: String = String(trigger["signal"])
		out.append("WAITING   on signal '%s'" % signal_name)
		if not EventBus.has_signal(signal_name):
			out.append("          !! EventBus DOES NOT DECLARE THAT SIGNAL.")
		elif _never_emitted(signal_name):
			# The finding that is invisible from any other angle. Three signals are declared
			# and never emitted anywhere in the tree; a card waiting on one of them looks
			# perfectly healthy and can never fire.
			out.append("          !! THAT SIGNAL HAS NO EMITTER ANYWHERE IN scripts/.")
			out.append("             The card is structurally unreachable, not merely unlucky.")
		out.append("")
	if card.has("arc"):
		var arc_id: String = String(card["arc"])
		out.append("ARC       '%s' is %s, at step %d"
			% [arc_id, EvArcs.state_of(arc_id) if EvArcs.state_of(arc_id) != "" else "not started",
				EvArcs.step_of(arc_id)])
		if EvArcs.subject_id(arc_id) != "":
			out.append("          subject: %s" % EvArcs.subject_id(arc_id))
		out.append("")

	# --- the real gate ------------------------------------------------------
	var origin: EvGate.Origin = _origin_for(String(card["tick"]))
	var verdict: EvGate.Verdict = EvGate.propose(event_id, origin)
	if verdict.admitted:
		out.append("GATE      IT WOULD BE ADMITTED RIGHT NOW, as class '%s'." % verdict.card_class)
		out.append("          So the reason you have not seen it is timing, not eligibility:")
		out.append("          nothing has proposed it from a %s origin today."
			% EvGate.origin_name(origin))
	else:
		out.append("GATE      REFUSED AT %s" % verdict.step)
		out.append("          %s" % verdict.reason)
		if not verdict.report.is_empty():
			out.append("")
			out.append("CONDITION")
			_print_report(verdict.report, out, "          ")

	out.append("")
	out.append("SEAMS THIS CARD READS")
	var seams: Array = []
	for tree in [card.get("condition", {}), trigger.get("condition", {})]:
		if typeof(tree) == TYPE_DICTIONARY and not (tree as Dictionary).is_empty():
			for s in EvCondition.seams_read(tree as Dictionary):
				if not seams.has(s):
					seams.append(s)
	if seams.is_empty():
		out.append("          (none — this card has no condition)")
	for s in seams:
		out.append("          %-34s = %s" % [s, str(EvSeams.read(s)) if EvSeams.kind_of(s) == EvSeams.Kind.GLOBAL else "(entity-scoped)"])

	return "\n".join(out)


## The blame tree, indented. A failing `none` shows the child that PASSED, which is the case a
## flat "failed leaf" field could not express at all.
static func _print_report(report: Dictionary, out: PackedStringArray, indent: String) -> void:
	var mark: String = "ok  " if bool(report.get("passed", false)) else "FAIL"
	var kind: String = String(report.get("kind", "?"))
	var detail: Dictionary = report.get("detail", {})
	var line: String = "%s%s %s" % [indent, mark, kind]
	if not detail.is_empty():
		line += "  " + _detail_line(detail)
	if String(report.get("reason", "")) != "":
		line += "   (\"%s\")" % report["reason"]
	out.append(line)
	for child in (report.get("blame", []) as Array):
		_print_report(child as Dictionary, out, indent + "  ")


static func _detail_line(detail: Dictionary) -> String:
	if detail.has("seam"):
		return "%s = %s, wanted %s %s" % [detail["seam"], str(detail.get("actual", "?")),
			str(detail.get("op", "")), str(detail.get("want", ""))]
	if detail.has("flag"):
		return "flag %s is %s" % [detail["flag"], "set" if bool(detail.get("set", false)) else "unset"]
	if detail.has("stamp"):
		return "stamp %s: %s" % [detail["stamp"],
			("%d day(s) ago" % int(detail.get("days", 0))) if bool(detail.get("stamped", false))
				else "NEVER STAMPED"]
	if detail.has("form"):
		var bits: PackedStringArray = []
		for k in detail:
			bits.append("%s=%s" % [k, str(detail[k])])
		return ", ".join(bits)
	return str(detail)


static func _origin_for(tick: String) -> EvGate.Origin:
	match tick:
		"hourly": return EvGate.Origin.TICK_HOURLY
		"signal": return EvGate.Origin.SIGNAL
		"scheduled": return EvGate.Origin.SCHEDULE
	return EvGate.Origin.TICK_DAILY


static func _never_emitted(signal_name: String) -> bool:
	# Textual, deliberately: `EventBus.<name>.emit` is the only shape this codebase uses, and
	# a parser would buy nothing over a grep. Same scan the manifest generator runs.
	var needle: String = "EventBus.%s.emit" % signal_name
	return not _grep("res://scripts", needle)


static func _grep(dir_path: String, needle: String) -> bool:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return false
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		var full: String = dir_path.path_join(name)
		if dir.current_is_dir():
			if not name.begins_with(".") and _grep(full, needle):
				dir.list_dir_end()
				return true
		elif name.ends_with(".gd"):
			var f := FileAccess.open(full, FileAccess.READ)
			if f != null and f.get_as_text().contains(needle):
				dir.list_dir_end()
				return true
		name = dir.get_next()
	dir.list_dir_end()
	return false


static func _nearest_ids(wanted: String) -> Array:
	var out: Array = []
	var stem: String = wanted.split(".")[-1]
	for id in EvCatalog.card_ids():
		if String(id).contains(stem) or stem.contains(String(id).split(".")[-1]):
			out.append(id)
		if out.size() >= 4:
			break
	return out
