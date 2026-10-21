class_name OfficeSystem
extends RefCounted

# Where the company works, the rent it pays there and the week-long move to the next office. The state
# is GameState's (office_id, office_move_to, office_move_day) and this is its only writer; the catalog
# and its numbers are OfficeConstants'. The first arrival at each tier of a run lifts the brand once.

## The GameState flag holding the tiers the company has worked in this run.
const FLAG_REACHED := "offices_reached"


static func current() -> String:
	return GameState.office_id


static func is_moving() -> bool:
	return GameState.office_move_to != ""


static func arrival_day() -> int:
	return GameState.office_move_day


## What a move to `id` pays now: UPFRONT_MONTHS of its rent.
static func upfront(id: String) -> int:
	return OfficeConstants.UPFRONT_MONTHS * int(OfficeConstants.CATALOG[id].rent)


## The desks the company takes: the founder's and every employee's (one on leave keeps theirs).
static func desks_taken() -> int:
	return 1 + HRSystem.headcount()


## The free desks of the office the company works in; none when the team has outgrown it.
static func desks_free() -> int:
	return maxi(int(OfficeConstants.CATALOG[current()].desks) - desks_taken(), 0)


## An office hires as many as it has desks. At home there is no cap: whoever is hired there works remotely.
static func hiring_closed() -> bool:
	return current() != "home" and desks_free() == 0


## The tiers the company has worked in this run. A save from before the brand jump holds none: the
## office it stands in is its first. A read, never a write.
static func reached() -> Array:
	return GameState.get_flag(FLAG_REACHED, [] if current() == "home" else [current()])


## What the first arrival at `id` adds to the brand; 0 once the company has worked in that tier.
static func brand_jump(id: String) -> int:
	return 0 if id in reached() else int(OfficeConstants.CATALOG[id].brand)


## Not the office already, not mid-move, never back to the flat (the design has no way home), and the
## cash covers the up-front rent. Moving down a tier is allowed; the whole team comes along.
static func can_move_to(id: String) -> bool:
	return id != current() and id != "home" and not is_moving() and GameState.cash >= upfront(id)


## Starts the move: the up-front rent leaves the cash now and daily_tick lands the move MOVE_WEEKS
## later, the week the new rent starts.
static func move_to(id: String) -> bool:
	if not can_move_to(id):
		return false
	FinanceSystem.apply_one_time_cost(upfront(id), "office_upfront")
	GameState.office_move_to = id
	GameState.office_move_day = GameState.day + TimeModel.ticks(OfficeConstants.MOVE_WEEKS)
	EventBus.office_move_started.emit(id, GameState.office_move_day)
	return true


## Lands a move on its arrival day and, on a tier's first visit, lifts the brand; then writes the rent of
## the office the company works in: Finance runs after this and pulls it, so the week of arrival already
## pays it. The jump is claimed after office_changed, so the listeners read it as still to come.
static func daily_tick() -> void:
	if is_moving() and GameState.day >= GameState.office_move_day:
		var id: String = GameState.office_move_to
		var seen: Array = reached()
		GameState.set_flag(FLAG_REACHED, seen)   # pinned before office_id changes, or the fallback counts the new office
		var jump: int = brand_jump(id)
		GameState.office_id = id
		GameState.office_move_to = ""
		GameState.office_move_day = -1
		EventBus.office_changed.emit(id)
		if jump > 0:
			GameState.set_flag(FLAG_REACHED, seen + [id])
			GameState.set_brand(GameState.brand + jump)
	var rent: int = FinanceSystem.daily_rate(int(OfficeConstants.CATALOG[current()].rent))
	if int(FinanceSystem.burn_breakdown["office"]) != rent:
		FinanceSystem.set_burn_category("office", rent)
