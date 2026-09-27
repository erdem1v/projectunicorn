class_name OfficeSystem
extends RefCounted

# Where the company works, and the week-long move to the next office. The state is GameState's
# (office_id, office_move_to, office_move_day) and this is its only writer; the catalog and its
# numbers are OfficeConstants'.


static func current() -> String:
	return GameState.office_id


static func is_moving() -> bool:
	return GameState.office_move_to != ""


static func arrival_day() -> int:
	return GameState.office_move_day


## One row per requirement of `id`: {kind, value, ok, now}, where `now` is today's reading
## (a bool for angel, a number for the others).
static func requirement_state(id: String) -> Array:
	var now := {
		"angel": GameState.run_angel_amount > 0,
		"team": HRSystem.headcount(),
		"cash": GameState.cash,
		"brand": GameState.brand,
	}
	var out: Array = []
	for req: Dictionary in OfficeConstants.CATALOG[id].reqs:
		var reading: Variant = now[req.kind]
		var ok: bool = reading if req.kind == "angel" else reading >= req.value
		out.append({"kind": req.kind, "value": req.value, "ok": ok, "now": reading})
	return out


## Not the office already, not mid-move, never back to the flat (the design has no way home),
## and every requirement met. Moving down a tier is allowed.
static func can_move_to(id: String) -> bool:
	if id == current() or id == "home" or is_moving():
		return false
	return requirement_state(id).all(func(r: Dictionary) -> bool: return r.ok)


## Starts the move; daily_tick lands it MOVE_DAYS later. No money moves: rent, deposit and
## movers wait on an open owner decision, so FinanceSystem's "office" burn line stays 0.
static func move_to(id: String) -> bool:
	if not can_move_to(id):
		return false
	GameState.office_move_to = id
	GameState.office_move_day = GameState.day + OfficeConstants.MOVE_DAYS
	EventBus.office_move_started.emit(id, GameState.office_move_day)
	return true


## Lands a move on its arrival day.
static func daily_tick() -> void:
	if not is_moving() or GameState.day < GameState.office_move_day:
		return
	GameState.office_id = GameState.office_move_to
	GameState.office_move_to = ""
	GameState.office_move_day = -1
	EventBus.office_changed.emit(GameState.office_id)
