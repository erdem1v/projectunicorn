class_name EvHarness
extends RefCounted

# THE AUTO-PLAY HARNESS (GDD §19.3). Two modes, one runner.
#
#     godot --headless --path . --event-harness=guided
#     godot --headless --path . --event-harness=random:seeds=200:weeks=52
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHY TWO MODES AND NOT ONE
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# §19.3 gives the reason in one sentence and it is worth restating because it is not obvious:
# **random choice can never complete a long conditional arc.** An arc whose payoff needs the
# player to have promised in week 2 and kept the promise by week 13 has a vanishing chance of
# happening by coin flip, so a single random harness measures arc completion at roughly zero
# and tells you nothing about whether arcs work.
#
#   RANDOM   thousands of seeded runs, choices picked by hash. Asserts: no crash, no dangling
#            entity reference, no untelegraphed loss, the tempo anchor holds. **Coverage here
#            is a WARNING, not a failure** — random play is not player play, and treating a
#            card the dice never reached as a defect would produce a wall of false positives.
#
#   GUIDED   one intent script per critical arc: at each step, take the option that ADVANCES
#            the arc. Asserts: ≥99% arc completion (E), zero never-visited arc steps (E).
#
# The intent script derives almost mechanically from the arc definition — §19.3 says so and it
# is true: the steps are listed, and the advancing option is the one whose effects carry an arc
# verb. So guided mode needs no hand-written scripts, which is what stops it rotting.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# SAVE/LOAD EVERY 7 WEEKS, IN BOTH MODES
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# §19.3's shared clause. It is the cheapest possible test of the thing most likely to break
# quietly: an arc that survives a dozen weeks but not a reload is an arc that works in every
# test and fails for every player.

const SAVE_EVERY_WEEKS := 7

## The daytime hours each simulated week sweeps hourly cards at, inside the default workday:
## the night refuses non-critical hourly cards.
const SWEEP_HOURS := [9, 13, 16]

## §13.7's window. Three real minutes, a different number of weeks on every speed rung.
const ANCHOR_WINDOW_SECONDS := 180.0


class Result:
	var runs: int = 0
	var weeks: int = 0
	var crashes: int = 0
	var dangling: int = 0
	var untelegraphed: int = 0
	var arcs_started: Dictionary = {}
	var arcs_completed: Dictionary = {}
	var steps_seen: Dictionary = {}
	var cards_fired: Dictionary = {}
	# PER-RUN, cleared at the top of every seed. They are keyed on the in-game week, and every
	# run walks the same week numbers — accumulating across seeds turns a ceiling of two into a
	# reported sixteen and a busy run into a thousand-week silence.
	var decisions_by_week: Dictionary = {}
	var interrupts_by_week: Dictionary = {}
	## The worst week and the longest quiet stretch (weeks) seen in ANY single run.
	var busiest_week: int = 0
	var longest_quiet: int = 0
	## §13.7's anchor, per speed rung: the most interrupts in any THREE REAL MINUTES of play, and
	## the longest silence in real seconds. Keyed by speed index (1x to 4x).
	var densest_3min: Dictionary = {}
	var longest_silence_s: Dictionary = {}
	## §13.6: weeks in which the floor was reached and found nothing. A content hole, counted.
	var empty_floor_weeks: int = 0
	var run_lengths: Array = []
	var endings: Dictionary = {}


static var _result: Result


# --- Entry point -----------------------------------------------------------

static func run(spec: String) -> bool:
	var parts: PackedStringArray = spec.split(":")
	var mode: String = parts[0] if parts.size() > 0 else "guided"
	var seeds: int = 20
	var weeks: int = 52
	for i in range(1, parts.size()):
		var kv: PackedStringArray = parts[i].split("=")
		if kv.size() != 2:
			continue
		if kv[0] == "seeds":
			seeds = int(kv[1])
		elif kv[0] == "weeks":
			weeks = int(kv[1])

	_result = Result.new()
	print("=== EVENT HARNESS · %s · %d seed(s) · %d week(s) ===" % [mode, seeds, weeks])

	for i in seeds:
		_one_run(mode, 424242 + i * 7919, weeks)

	return _report(mode)


# --- One run ---------------------------------------------------------------

static func _one_run(mode: String, seed_value: int, max_weeks: int) -> void:
	GameState.initialize_run({"seed": seed_value})
	EvEngine.reset()
	EvCatalog.reload()
	_result.runs += 1
	_result.decisions_by_week.clear()
	_result.interrupts_by_week.clear()
	_seen_live.clear()
	EvEffects.reset_counters()

	var week: int = GameState.day
	while week < max_weeks and GameState.run_active:
		GameState.day = week
		EvEngine.daily_tick()
		_drain(mode)
		_note_arcs()
		for hour in SWEEP_HOURS:
			GameState.current_hour = hour
			EvEngine.hourly_tick(hour)
			_drain(mode)
		_check_dangling()
		if week % SAVE_EVERY_WEEKS == 0:
			_save_load_cycle()
		_result.weeks += 1
		week += 1

	_result.empty_floor_weeks += EvEngine.empty_floor_ticks()
	_result.untelegraphed += EvEffects.untelegraphed_refusals()
	_result.run_lengths.append(week)
	if GameState.ending_id != "":
		_result.endings[GameState.ending_id] = int(_result.endings.get(GameState.ending_id, 0)) + 1

	# THIS RUN's maxima, folded in before the week tables are cleared for the next seed. The
	# tempo anchor is a claim about a single run — "no stretch over 60-90 seconds without a
	# decision" — and a figure summed across seeds answers a question nobody asked.
	for w in _result.interrupts_by_week:
		_result.busiest_week = maxi(_result.busiest_week, int(_result.interrupts_by_week[w]))
	var quiet: int = 0
	for w in range(1, week):
		if int(_result.decisions_by_week.get(w, 0)) == 0:
			quiet += 1
			_result.longest_quiet = maxi(_result.longest_quiet, quiet)
		else:
			quiet = 0

	# §13.7: three real minutes is a different number of WEEKS on every speed rung, so the
	# window is computed and the anchor reported per rung.
	for speed in range(1, TimeModel.SECONDS_PER_HOUR.size()):
		var secs_per_week: float = TimeModel.seconds_per_tick(speed)
		var window: int = maxi(1, int(round(ANCHOR_WINDOW_SECONDS / secs_per_week)))
		var densest: int = 0
		var running: int = 0
		for w in range(1, week):
			running += int(_result.interrupts_by_week.get(w, 0))
			if w - window >= 1:
				running -= int(_result.interrupts_by_week.get(w - window, 0))
			densest = maxi(densest, running)
		_result.densest_3min[speed] = maxi(int(_result.densest_3min.get(speed, 0)), densest)
		var silence_s: int = int(round(float(_result.longest_quiet) * secs_per_week))
		_result.longest_silence_s[speed] = maxi(
			int(_result.longest_silence_s.get(speed, 0)), silence_s)


## Arcs that started, and arcs that reached an end, counted once each per run. Sampled once per
## week rather than hooked to a signal, because an arc that starts and ends inside one tick still
## has to be counted, and a sample after the tick sees both.
static var _seen_live: Dictionary = {}

static func _note_arcs() -> void:
	for arc_id in EvArcs.all_ids():
		var state: String = EvArcs.state_of(arc_id)
		if state == "":
			continue
		if not _seen_live.has(arc_id):
			_seen_live[arc_id] = true
			_result.arcs_started[arc_id] = int(_result.arcs_started.get(arc_id, 0)) + 1
		if state == EvArcs.STATE_ENDED and not _seen_live.get(arc_id + "#done", false):
			_seen_live[arc_id + "#done"] = true
			_result.arcs_completed[arc_id] = int(_result.arcs_completed.get(arc_id, 0)) + 1


## Answer every card the engine puts up, the same way the real modal does — through the one
## resolution seam, so the engine cannot tell the harness from a person.
static func _drain(mode: String) -> void:
	# THE DESK IS PART OF PLAYING. A paper waits until the player picks it up, and a harness
	# that only answers modals is a player who never touches the desk — so any arc whose
	# opener is a paper never starts, and `arc_final_stretch`'s opener is exactly that.
	# Guided mode clears the desk every sweep (a player trying to finish an arc does); random
	# mode opens one paper a sweep, which is closer to how a desk actually drains.
	var desk: Array = EvPapers.ordered()
	for paper_id in desk:
		if EvQueue.active_id() != "":
			break
		if EvEngine.open_paper(String(paper_id)):
			_from_desk = true
			_drain_active(mode)
			_from_desk = false
		if not mode.begins_with("guided"):
			break
	_drain_active(mode)


## True while the card being answered came off the DESK rather than the queue — the difference
## between a decision that interrupted the player and one they reached for.
static var _from_desk: bool = false


static func _drain_active(mode: String) -> void:
	var guard: int = 0
	while EvQueue.active_id() != "":
		guard += 1
		if guard > 64:
			# Not a cap — a finding. A card re-queueing inside its own resolution is a real
			# defect and this says so rather than hanging.
			push_error("[EvHarness] drain guard tripped on '%s' — a card is re-queueing "
				% EvQueue.active_id() + "inside its own resolution")
			_result.crashes += 1
			EvQueue.clear_active()
			return
		var event_id: String = EvQueue.active_id()
		var card: Dictionary = EvCatalog.card(event_id)
		_result.cards_fired[event_id] = int(_result.cards_fired.get(event_id, 0)) + 1
		# COUNTED AS SHOWN, not as declared. A demoted card is a PAPER — the player picked
		# it up off the desk — and counting it as an interrupt because its file says
		# `interrupt` reports the tempo brake breaching a ceiling it just enforced.
		if String(card.get("class", "")) == "interrupt" and not _from_desk:
			_result.interrupts_by_week[GameState.day] = \
				int(_result.interrupts_by_week.get(GameState.day, 0)) + 1
		_result.decisions_by_week[GameState.day] = \
			int(_result.decisions_by_week.get(GameState.day, 0)) + 1
		if card.has("arc"):
			var step_key: String = "%s/%s" % [card["arc"], event_id]
			_result.steps_seen[step_key] = int(_result.steps_seen.get(step_key, 0)) + 1

		var option_id: String = _pick(mode, card, event_id)
		if option_id == "":
			push_error("[EvHarness] '%s' has no takeable option — the player would be stuck"
				% event_id)
			_result.crashes += 1
			EvQueue.clear_active()
			return
		EvEngine.resolve(event_id, option_id)


## An arc whose steps are fixture content. Not production, not in the gate.
static func _is_fixture_arc(arc_id: String) -> bool:
	for step in (EvCatalog.arc(arc_id).get("steps", []) as Array):
		var card: Dictionary = EvCatalog.card(String((step as Dictionary).get("event_id", "")))
		if String(card.get("version_scope", "demo")) == "fixture":
			return true
	return false


## Guided: take the option that MOVES THE ARC. Random: hash-pick, so a seed reproduces exactly.
static func _pick(mode: String, card: Dictionary, event_id: String) -> String:
	var options: Array = card.get("options", [])
	var takeable: Array = []
	for o in options:
		var opt: Dictionary = o
		if opt.has("requires") and not EvCondition.eval(opt["requires"], EvQueue.active_context()):
			continue                    # locked-visible: shown, never takeable
		takeable.append(opt)
	if takeable.is_empty():
		return ""

	if mode.begins_with("guided") and card.has("arc"):
		for o in takeable:
			for e in ((o as Dictionary).get("effects", []) as Array):
				if typeof(e) != TYPE_DICTIONARY:
					continue
				var verb: String = String((e as Dictionary).get("verb", ""))
				if verb in ["advance_arc", "end_arc", "start_arc"]:
					return String((o as Dictionary)["id"])

	var idx: int = int(EvDice.unit("harness", GameState.day, event_id, "") * takeable.size())
	return String((takeable[mini(idx, takeable.size() - 1)] as Dictionary)["id"])


# --- Assertions per week ---------------------------------------------------

static func _check_dangling() -> void:
	# A queued card whose subject has died and was not dropped. Display re-validation should
	# have caught it; this catches the case where it did not.
	for entry in EvQueue.entries():
		if not EvScope.still_valid((entry as Dictionary)["context"]):
			push_error("[EvHarness] dangling entity in queued '%s'" % (entry as Dictionary)["event_id"])
			_result.dangling += 1


static func _save_load_cycle() -> void:
	var block: Dictionary = EvSave.to_dict()
	var offender: String = EvSave.verify_no_resources(block)
	if offender != "":
		push_error("[EvHarness] a Resource reached the save block at %s" % offender)
		_result.crashes += 1
	var json: String = JSON.stringify(block)
	EvSave.reset()
	EvSave.from_dict(JSON.parse_string(json) as Dictionary)


# --- The report ------------------------------------------------------------

static func _report(mode: String) -> bool:
	var r: Result = _result
	print("")
	print("RUNS      %d, %d simulated week(s)" % [r.runs, r.weeks])

	# Run length: if no run gets near the soft cap, its telegraph is content nobody will see and
	# I3 is satisfied vacuously.
	if not r.run_lengths.is_empty():
		var lens: Array = r.run_lengths.duplicate()
		lens.sort()
		var longest: int = int(lens[-1])
		print("RUN LEN   mean %d, median %d, shortest %d, longest %d (in-game weeks)" % [
			int(lens.reduce(func(a, b): return a + b, 0)) / lens.size(), int(lens[lens.size() / 2]),
			int(lens[0]), longest])
		print("          soft cap is week %d — %s"
			% [EndingsSystem.SOFT_CAP_WEEK,
				"REACHABLE in this sweep" if longest >= TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK)
					else "NOT reached; its telegraph is unseen content"])

	print("ENDINGS   %s" % (str(r.endings) if not r.endings.is_empty() else "none reached"))
	print("CARDS     %d distinct fired" % r.cards_fired.size())

	# §13.7's anchor. A measurement, not a gate — §13.7 says so itself. The window figures are
	# the worst SINGLE RUN, folded in at the end of each seed; the week tables they come from are
	# per-run, because every run walks the same week numbers.
	print("TEMPO     busiest week: %d interrupt(s) against the per-tick ceiling of %d"
		% [r.busiest_week, EvTuning.MAX_INTERRUPTS_PER_DAY])
	print("          longest silence: %d in-game week(s)" % r.longest_quiet)
	var real_min: float = float(r.weeks) * TimeModel.seconds_per_tick(1) / 60.0
	var decisions: int = r.cards_fired.values().reduce(func(a, b): return a + b, 0)
	print("§13.7 ANCHOR — one decision every %s real min at 1x (anchor %.1f); the busiest"
		% ["%.1f" % (real_min / decisions) if decisions > 0 else "n/a",
			EvTuning.ANCHOR_MINUTES_PER_DECISION]
		+ " 3 real minutes, and the longest silence in real seconds.")
	for speed in range(1, TimeModel.SECONDS_PER_HOUR.size()):
		print("          %dx : 3 min = %d week(s) · %d interrupt(s) (ceiling %d) · silence %d s" % [
			speed, int(round(ANCHOR_WINDOW_SECONDS / TimeModel.seconds_per_tick(speed))),
			int(r.densest_3min.get(speed, 0)),
			EvTuning.ANCHOR_MAX_INTERRUPTS_PER_3_MIN,
			int(r.longest_silence_s.get(speed, 0))])
	print("FLOOR     %d week(s) the floor was reached and found nothing (\u00a713.6)"
		% r.empty_floor_weeks)

	var ok: bool = true
	print("")
	print("CRASHES   %d" % r.crashes)
	print("DANGLING  %d" % r.dangling)
	# §19.3's third clean-run condition. A refusal here is the executor stopping a card from
	# ending the run with no telegraph declared or on one that never fired — so nonzero is
	# CONTENT that would have shipped a silent loss, not an engine failure.
	print("UNTELEGRAPHED  %d refusal(s) — a card tried to end a run with no telegraph declared "
		% r.untelegraphed + "or on one that never fired")
	if r.untelegraphed > 0:
		ok = false
	if r.crashes > 0 or r.dangling > 0:
		ok = false

	if mode.begins_with("guided"):
		# The one place coverage IS an error. §19.3: ≥99% completion for critical arcs, and
		# zero never-visited steps.
		print("")
		print("ARCS (guided mode — completion is an ERROR condition here)")
		# FIXTURE ARCS ARE NOT IN THE GATE. They are `version_scope: fixture`, refused at G2 in
		# any build that does not ship fixtures, so including them makes the gate permanently
		# red for a reason that has nothing to do with content. They are listed, and marked.
		var unvisited: Array = []
		for arc_id in EvCatalog.arc_ids():
			var fixture: bool = _is_fixture_arc(arc_id)
			var started: int = int(r.arcs_started.get(arc_id, 0))
			var completed: int = int(r.arcs_completed.get(arc_id, 0))
			var pct: float = 100.0 * float(completed) / float(maxi(1, started))
			print("  %-28s started %3d  completed %3d  (%.0f%%)%s" % [
				arc_id, started, completed, pct, "   [fixture — not in the gate]" if fixture else ""])
			if fixture:
				continue
			if started == 0:
				print("      NEVER STARTED in %d run(s)" % r.runs)
				ok = false
			elif pct < 99.0:
				print("      below \u00a719.3's 99%% completion bar")
				ok = false
			for step in (EvCatalog.arc(arc_id).get("steps", []) as Array):
				var key: String = "%s/%s" % [arc_id, (step as Dictionary).get("event_id", "")]
				if not r.steps_seen.has(key):
					unvisited.append(key)
		if not unvisited.is_empty():
			print("  NEVER VISITED: %s" % ", ".join(unvisited))
			ok = false
	else:
		# §19.3: in random mode coverage is a W-report. A card the dice never reached is not
		# evidence of anything, and saying otherwise trains people to ignore the harness.
		var never: Array = []
		for id in EvCatalog.card_ids():
			if not r.cards_fired.has(id):
				never.append(id)
		print("")
		print("COVERAGE  %d card(s) never fired (a WARNING, not a failure — random play is "
			% never.size() + "not player play)")
		if never.size() <= 20:
			for id in never:
				print("            %s" % id)

	print("")
	print("HARNESS %s" % ("PASS" if ok else "FAIL"))
	return ok
