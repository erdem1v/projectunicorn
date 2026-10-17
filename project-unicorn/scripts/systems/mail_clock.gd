class_name MailClock
extends RefCounted

# WHEN THINGS ARRIVE. Mail, papers, notes, reminders, Frank's line and the ticker's lines come in while the
# company works (WorkHoursSystem.company_window), never at the 00:00 rollover that made them. What the clock
# makes outside the window takes an ARRIVAL TIME inside it (`arrival`) and is not shown before then; an urgent
# item (an ending's warning, an emergency) arrives when it is made. `at` is an absolute minute, tick * 1440 +
# minute of the day; -1 is "no time" (an old save, a fixture) and such an item is always shown.
#
# Two ways to wait. A message waits OUTSIDE the inbox, in GameState.mail_outbox, and hourly_tick delivers it:
# nothing reads it before. A card waits INSIDE its store (queue, desk, history) with its `at`: what SHOWS it
# asks `delivered`, what asks whether it EXISTS does not (EvQueue.has/holds/ids, EvPapers.has/keys_of,
# EventGate.instances_of, on_desk): a hidden paper is still the paper its card waits on. Reminders are derived
# from live state, so their arrival times are kept in GameState.desk_arrivals and written by sync_desk.

const DAY_MINUTES := 1440
## [WORKING] Hours from the window's start an arrival is drawn across.
const SPREAD_HOURS := 4
## [WORKING] The same for a paper that lives one week: it lands at the window's start, so its week is not cut short.
const SHORT_LIVED_SPREAD_HOURS := 1

## A harness that drives the daily tick directly (EndgameSmoke) sets it: everything is delivered when it is made.
static var instant := false


## The absolute minute now. A workday ending at 24:00 has its last minute at 23:59, and the 00:00 hourly slice, which
## runs before the tick's number advances, already counts the new tick.
static func now() -> int:
	var tick: int = GameState.day + (1 if TimeManager.is_rolling_over() else 0)
	return tick * DAY_MINUTES + mini(int(TimeManager.day_minute()), DAY_MINUTES - 1)


## True while the company's workday is on.
static func in_window() -> bool:
	if instant:
		return true
	var window: Dictionary = WorkHoursSystem.company_window()
	var minute: int = now() % DAY_MINUTES
	return minute >= int(window.start) * 60 and minute < int(window["end"]) * 60


## May the player see what arrived at `at` yet?
static func delivered(at: int) -> bool:
	return instant or at < 0 or at <= now()


## When something made now reaches the player: now while the workday is on or when `urgent`; else a whole hour in
## the next window's first `spread` hours, drawn from `key` so the same save draws the same hour.
static func arrival(key: String, urgent := false, spread := SPREAD_HOURS) -> int:
	if urgent or in_window():
		return now()
	var window: Dictionary = WorkHoursSystem.company_window()
	var start: int = int(window.start)
	var t: int = now()
	var day: int = t / DAY_MINUTES + (1 if t % DAY_MINUTES >= start * 60 else 0)
	var slot: int = floori(EvDice.unit("arrival", day, key, "") * mini(spread, int(window["end"]) - start))
	return day * DAY_MINUTES + (start + slot) * 60


## Every hour: the outbox's due messages are delivered, new reminders get their time, and the surfaces are told what
## the hour brought.
static func hourly_tick() -> void:
	MessageSystem.release()
	sync_desk()
	if in_window():
		EventBus.desk_changed.emit()


# --- Reminders -------------------------------------------------------------

## What stands on the desk as a reminder, from the live state, in the order the desk lists it: the open gate, a
## term sheet, candidate files, an account in Risk or Expansion, an employee about to leave. `id` is what its
## arrival time is kept under; `card` is the gate's card, `ref` the account or the employee.
static func reminders() -> Array:
	var out: Array = []
	if GameState.phase_gate_ready:
		for gate in PhaseGateSystem.GATES:
			if int(gate.to) == GameState.pending_next_phase:
				out.append({"id": "gate", "kind": "gate", "card": String(gate.card_id)})
	if not GameState.active_sheets.is_empty():
		out.append({"id": "sheet", "kind": "sheet"})
	if HRSearchSystem.has_files_ready():
		out.append({"id": "atlas", "kind": "atlas"})
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.lifecycle_phase in ["risk", "expansion"]:
			out.append({"id": "customer:" + c.id, "kind": "customer", "ref": c})
	for e in CharacterRegistry.get_employees():
		if HRConstants.is_flight_risk(e.morale):
			out.append({"id": "employee:" + e.id, "kind": "employee", "ref": e})
	return out


## When a reminder reached the player, -1 while it has no time (it is shown).
static func reminder_at(id: String) -> int:
	return int(GameState.desk_arrivals.get(id, -1))


## The player reaches for a reminder before its time (the Sales tab's button): it is at hand now.
static func reach(id: String) -> void:
	if not delivered(reminder_at(id)):
		GameState.desk_arrivals[id] = now()
		EventBus.desk_changed.emit()


## The reminders that stand without a time take theirs; the times of reminders that are gone are dropped.
static func sync_desk() -> void:
	var ledger: Dictionary = GameState.desk_arrivals
	var standing: Array = []
	for r in reminders():
		standing.append(r.id)
		if not ledger.has(r.id):
			ledger[r.id] = arrival("reminder|" + String(r.id))
	for id in ledger.keys():
		if not standing.has(id):
			ledger.erase(id)
