class_name EvHarness
extends RefCounted

# THE AUTO-PLAY HARNESS (GDD §19.3). Two modes, one runner.
#
#     godot --headless --path . --event-harness=guided
#     godot --headless --path . --event-harness=random:seeds=200:days=365
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHY TWO MODES AND NOT ONE
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# §19.3 gives the reason in one sentence and it is worth restating because it is not obvious:
# **random choice can never complete a long conditional arc.** An arc whose payoff needs the
# player to have promised on day 10 and kept the promise by day 90 has a vanishing chance of
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
# SAVE/LOAD EVERY 50 DAYS, IN BOTH MODES
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# §19.3's shared clause. It is the cheapest possible test of the thing most likely to break
# quietly: an arc that survives a hundred days but not a reload is an arc that works in every
# test and fails for every player.

const SAVE_EVERY_DAYS := 50

## §13.7's window. Three real minutes, which is 15 in-game days at 1x and 60 at 3x.
const ANCHOR_WINDOW_SECONDS := 180.0


class Result:
	var runs: int = 0
	var days: int = 0
	var crashes: int = 0
	var dangling: int = 0
	var untelegraphed: int = 0
	var arcs_started: Dictionary = {}
	var arcs_completed: Dictionary = {}
	var steps_seen: Dictionary = {}
	var cards_fired: Dictionary = {}
	# PER-RUN, cleared at the top of every seed. They are keyed on the in-game day, and every
	# run walks the same day numbers — accumulating across seeds turns a ceiling of two into a
	# reported sixteen and a busy run into a five-thousand-day silence.
	var decisions_by_day: Dictionary = {}
	var interrupts_by_day: Dictionary = {}
	## The worst day and the longest quiet stretch seen in ANY single run.
	var busiest_day: int = 0
	var longest_quiet: int = 0
	## §13.7's actual anchor, per speed rung: the densest THREE REAL MINUTES of play, and the
	## longest silence in real seconds. Keyed by speed index (1x, 2x, 3x).
	var densest_3min: Dictionary = {}
	var longest_silence_s: Dictionary = {}
	## §13.6: days on which the floor was reached and found nothing. A content hole, counted.
	var empty_floor_days: int = 0
	var run_lengths: Array = []
	var endings: Dictionary = {}


static var _result: Result


# --- Entry point -----------------------------------------------------------

static func run(spec: String) -> bool:
	var parts: PackedStringArray = spec.split(":")
	var mode: String = parts[0] if parts.size() > 0 else "guided"
	var seeds: int = 20
	var days: int = 365
	for i in range(1, parts.size()):
		var kv: PackedStringArray = parts[i].split("=")
		if kv.size() != 2:
			continue
		if kv[0] == "seeds":
			seeds = int(kv[1])
		elif kv[0] == "days":
			days = int(kv[1])

	_result = Result.new()
	print("=== EVENT HARNESS · %s · %d seed(s) · %d day(s) ===" % [mode, seeds, days])

	for i in seeds:
		_one_run(mode, 424242 + i * 7919, days)

	return _report(mode)


# --- One run ---------------------------------------------------------------

static func _one_run(mode: String, seed_value: int, max_days: int) -> void:
	GameState.initialize_run({"seed": seed_value})
	EvEngine.reset()
	EvCatalog.reload()
	_result.runs += 1
	_result.decisions_by_day.clear()
	_result.interrupts_by_day.clear()
	_seen_live.clear()
	EvEffects.reset_counters()

	var day: int = GameState.day
	while day < max_days and GameState.run_active:
		GameState.day = day
		EvEngine.daily_tick()
		_drain(mode)
		_note_arcs()
		for hour in [9, 13, 17]:
			GameState.current_hour = hour
			EvEngine.hourly_tick(hour)
			_drain(mode)
		_check_dangling()
		if day % SAVE_EVERY_DAYS == 0:
			_save_load_cycle()
		_result.days += 1
		day += 1

	_result.empty_floor_days += EvEngine.empty_floor_days()
	_result.untelegraphed += EvEffects.untelegraphed_refusals()
	_result.run_lengths.append(day)
	if GameState.ending_id != "":
		_result.endings[GameState.ending_id] = int(_result.endings.get(GameState.ending_id, 0)) + 1

	# THIS RUN's maxima, folded in before the day tables are cleared for the next seed. The
	# tempo anchor is a claim about a single run — "no stretch over 60-90 seconds without a
	# decision" — and a figure summed across seeds answers a question nobody asked.
	for d in _result.interrupts_by_day:
		_result.busiest_day = maxi(_result.busiest_day, int(_result.interrupts_by_day[d]))
	var quiet: int = 0
	for d in range(1, day):
		if int(_result.decisions_by_day.get(d, 0)) == 0:
			quiet += 1
			_result.longest_quiet = maxi(_result.longest_quiet, quiet)
		else:
			quiet = 0

	# §13.7 PROPER. Three real minutes is a different number of DAYS on every speed rung, so
	# the window is computed once per rung and the anchor is reported per rung. Anything else
	# is a figure that does not say what speed it was measured at.
	for speed in range(1, TimeManager.SECONDS_PER_DAY.size()):
		var secs_per_day: float = float(TimeManager.SECONDS_PER_DAY[speed])
		if secs_per_day <= 0.0:
			continue
		var window: int = maxi(1, int(round(ANCHOR_WINDOW_SECONDS / secs_per_day)))
		var densest: int = 0
		var running: int = 0
		for d in range(1, day):
			running += int(_result.decisions_by_day.get(d, 0))
			if d - window >= 1:
				running -= int(_result.decisions_by_day.get(d - window, 0))
			densest = maxi(densest, running)
		_result.densest_3min[speed] = maxi(int(_result.densest_3min.get(speed, 0)), densest)
		var silence_s: int = int(round(float(_result.longest_quiet) * secs_per_day))
		_result.longest_silence_s[speed] = maxi(
			int(_result.longest_silence_s.get(speed, 0)), silence_s)


## Arcs that started, and arcs that reached an end, counted once each per run.
##
## THIS DID NOT EXIST. `arcs_started` and `arcs_completed` were fields nothing wrote, so the
## guided report's completion table printed 0/0 whatever the engine did — a gate incapable of
## passing. Sampled once per day rather than hooked to a signal, because an arc that starts and
## ends inside one tick still has to be counted, and a sample after the tick sees both.
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
	# Guided mode clears the desk every day (a player trying to finish an arc does); random
	# mode opens one paper a day, which is closer to how a desk actually drains.
	var desk: Array = EvPapers.ids()
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
			_result.interrupts_by_day[GameState.day] = \
				int(_result.interrupts_by_day.get(GameState.day, 0)) + 1
		_result.decisions_by_day[GameState.day] = \
			int(_result.decisions_by_day.get(GameState.day, 0)) + 1
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


## Guided: take the option that MOVES THE ARC. Random: hash-pick, so a seed reproduces exactly.
## An arc whose steps are fixture content. Not production, not in the gate.
static func _is_fixture_arc(arc_id: String) -> bool:
	for step in (EvCatalog.arc(arc_id).get("steps", []) as Array):
		var card: Dictionary = EvCatalog.card(String((step as Dictionary).get("event_id", "")))
		if String(card.get("version_scope", "demo")) == "fixture":
			return true
	return false


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


# --- Assertions per day ----------------------------------------------------

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
	print("RUNS      %d, %d simulated day(s)" % [r.runs, r.days])

	# Run length. The directive behind this: SOFT_CAP_DAY is 730, and if no run ever gets
	# near it then the soft-cap telegraph is content nobody will see and I3 is satisfied
	# vacuously. Worth knowing either way.
	if not r.run_lengths.is_empty():
		var total: int = 0
		var longest: int = 0
		for d in r.run_lengths:
			total += int(d)
			longest = maxi(longest, int(d))
		print("RUN LEN   mean %d day(s), longest %d" % [total / r.run_lengths.size(), longest])
		print("          soft cap is day %d — %s"
			% [EndingsSystem.SOFT_CAP_DAY,
				"REACHABLE in this sweep" if longest >= EndingsSystem.SOFT_CAP_DAY
					else "NOT reached; its telegraph is unseen content"])

	print("ENDINGS   %s" % (str(r.endings) if not r.endings.is_empty() else "none reached"))
	print("CARDS     %d distinct fired" % r.cards_fired.size())

	# §13.7's anchor. A measurement, not a gate — §13.7 says so itself. Both figures are the
	# worst SINGLE RUN, folded in at the end of each seed; the day tables they come from are
	# per-run, because every run walks the same day numbers.
	print("TEMPO     busiest day: %d interrupt(s) against the DAILY ceiling of %d"
		% [r.busiest_day, EvTuning.MAX_INTERRUPTS_PER_DAY])
	print("          longest silence: %d in-game day(s)" % r.longest_quiet)
	print("§13.7 ANCHOR — densest 3 real minutes, and the longest silence in real seconds.")
	print("          (3 min = %d days at 1x, %d at 2x, %d at 3x)" % [
		int(round(ANCHOR_WINDOW_SECONDS / float(TimeManager.SECONDS_PER_DAY[1]))),
		int(round(ANCHOR_WINDOW_SECONDS / float(TimeManager.SECONDS_PER_DAY[2]))),
		int(round(ANCHOR_WINDOW_SECONDS / float(TimeManager.SECONDS_PER_DAY[3])))])
	for speed in [1, 2, 3]:
		print("          %dx : %d decision(s) per 3 min (ceiling %d) · silence %d s" % [
			speed, int(r.densest_3min.get(speed, 0)),
			EvTuning.ANCHOR_MAX_INTERRUPTS_PER_3_MIN,
			int(r.longest_silence_s.get(speed, 0))])
	print("FLOOR     %d day(s) the floor was reached and found nothing (\u00a713.6)"
		% r.empty_floor_days)
	var lens: Array = r.run_lengths.duplicate()
	lens.sort()
	if not lens.is_empty():
		print("RUN LEN   median %d, shortest %d, longest %d (in-game days)" % [
			int(lens[lens.size() / 2]), int(lens[0]), int(lens[lens.size() - 1])])

	var ok: bool = true
	print("")
	print("CRASHES   %d" % r.crashes)
	print("DANGLING  %d" % r.dangling)
	# §19.3's third clean-run condition. A refusal here is the executor stopping a card from
	# ending the run on a telegraph that never fired — so nonzero is CONTENT that would have
	# shipped a silent loss, not an engine failure, and it is named rather than counted silently.
	print("UNTELEGRAPHED  %d refusal(s) — a card tried to end a run on a telegraph that "
		% r.untelegraphed + "never fired")
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
