class_name OfficePeople
extends Node3D

# The staff in the office: the founder and every employee as an OfficeActor, each at a desk kept
# for as long as they stay. Arrivals and departures run on the game clock: everyone is due in a
# little after the start and gone a little before their end (the founder keeps the company
# window), and a walk starts early enough to land on time; the way out takes one at a time. A walk
# that cannot fit is cut instead, under the morning's or the night's black. The rest runs on
# ambient seconds (real seconds times k, the clock's pace capped at VISUAL_CAP, 0 when paused):
# breaks with a line at the coffee and the restrooms, small idles at the desk, lunch, team
# meetings, the loft's all-hands. At home only the founder is drawn, sleeping out of hours; the
# staff work remotely. The night waits on office_empty() (TimeManager's night gate). The founder's
# trip to a meeting walks them out.

signal founder_arrived   # the founder sent out reached the door

const LIFT_EASE := 6.0    # the design's lift easing, per second
const ICON_PX := 26.0     # the design's iconS: a head icon this many pixels tall,
const ICON_MIN := 0.6     # but never under this many world units
const CUT_FADE_S := 0.25  # [WORKING] the view fades to black before the night cuts those still in
## A spot's way in starts at the first point of its chain this close to the baked floor.
const ON_FLOOR := 0.3
## Seconds of getting up and sitting down a walk to a seat adds, and one to bed.
const SEAT_LEG_S := 2.5
const BED_LEG_S := 4.0
## What each job is at the desk (the icon and tooltip), and what the body does for each.
const JOB_WORK := {
	HRConstants.JOB_BUILD: "code",
	HRConstants.JOB_TEST: "test",
	HRConstants.JOB_RESEARCH: "research",
	HRConstants.JOB_SALES: "phone",
	HRConstants.JOB_SUPPORT: "phone",
	HRConstants.JOB_ACCOUNTS: "phone",
}
const WORK_BODY := {"code": "type", "test": "type", "design": "notes", "research": "read", "plan": "notes",
	"phone": "phone"}
## What each errand from the desk shows and does: [status, body act].
const ERRANDS := {"coffee": ["coffee", "drink"], "wc": ["wc", "idle"], "visit": ["visit", "talk"],
	"booth": ["phone", "phone"], "eat": ["food", "talk"], "meeting": ["meeting", "talk"]}
## Short things done at the desk between stretches of work, and round a meeting table in turn.
const DESK_IDLES := ["look", "lean_back", "stretch", "yawn", "drink"]
const MEETING_ACTS := ["talk", "listen", "nod", "notes"]

## The founder is on the trip to a meeting: out of the office until founder_back().
var founder_away := false
## A call waits for the founder (MeetingInvite): the phone rings over their head.
var founder_calling := false

var _layout: OfficeLayout
var _view: Node
var _office := ""        # the office whose desks _desk_of keeps
var _actors := {}        # character id -> OfficeActor
var _founder: OfficeActor
var _desk_of := {}       # character id -> desk index
var _spare := {}         # spot position -> true: someone works there, so no break goes there
var _entry := {}         # where people come in and go out
var _bed := {}           # the founder's bed, at home
var _coffee: Array = []  # the coffee counter's spots; the kettle's at home
var _lift: Array = []    # [node, panel] per lift door or door wing
var _lift_open := 0.0
var _venue: OfficeVenue
var _map := RID()
var _placed := false     # the office's floor is on the navigation map and everyone is placed
var _k := 0.0
var _clock := 0.0        # ambient seconds in this office
var _door_turn := 0.0    # the ambient second of the next turn out through the door
var _fade: Tween         # the view going dark for the night's cut
var _founder_told := true
var _rooms: Array[float] = []   # per meeting room: ambient seconds to its next team meeting
var _kickoff: Array = []   # character ids the next kick-off gathers; empty = none due
var _all_hands_day := -1
var _selected := ""
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	EventBus.character_added.connect(_on_roster_changed.unbind(1))
	EventBus.character_removed.connect(_on_roster_changed.unbind(1))
	EventBus.assignment_changed.connect(_on_assignment_changed)
	EventBus.night_skipped.connect(_on_night_skipped)
	# A sprint's kick-off waits for a free room; an office without rooms has none.
	EventBus.sprint_started.connect(func(_n: int) -> void:
		_kickoff = SprintSystem.team().map(func(p: Dictionary) -> String: return p.id) \
			if _placed and not _rooms.is_empty() else [])
	NavigationServer3D.map_changed.connect(_on_map_changed)
	TimeManager.register_night_gate(office_empty, OfficeConstants.NIGHT_WAIT_S)


func _exit_tree() -> void:
	TimeManager.unregister_night_gate()


## The night gate: nobody is on the way out of the door or to bed. Anyone else still in the office
## (left seated for the cut, waiting for their turn at the door) is cut under black, so the view
## goes dark over them first; out of sight or asleep counts as out.
func office_empty() -> bool:
	if not _layout.staffed() or _headless():
		return true
	if not _placed:
		return false
	var cutting := false
	for a: OfficeActor in _actors.values():
		if not a.visible or a.phase == OfficePerson.Phase.LYING:
			continue
		if a.is_walking() and (is_same(a.spot, _entry) or is_same(a.spot, _bed)):
			return false
		cutting = true
	if not cutting:
		return true
	if _fade == null and _k > 0.0:
		_fade = _view.fade(true, CUT_FADE_S)
	return _fade != null and not _fade.is_running()


## The founder's trip to a meeting: up from wherever they are and out of the door. founder_arrived
## says they reached it, next frame when they were out already.
func send_founder_out() -> void:
	founder_away = true
	_founder_told = false
	if _founder != null and _founder.visible:
		_drop_errand(_founder)
		_founder.status = "leave"
		_founder.go_to(_entry, "idle")


## Back from the meeting: the day walks the founder in, or at home past the window to bed.
func founder_back() -> void:
	founder_away = false


## The founder in this office, or null before the office is placed or on the map.
func founder() -> OfficeActor:
	return _founder if _placed else null


## The `n` people seated nearest the founder, nearest first: they look up as the founder leaves
## for a meeting and comes back. None before the office is placed.
func nearest_to_founder(n: int) -> Array:
	if not _placed:
		return []
	var seated := _actors.values().filter(func(a: OfficeActor) -> bool:
		return a != _founder and a.visible and a.phase == OfficePerson.Phase.SEATED)
	seated.sort_custom(func(x: OfficeActor, y: OfficeActor) -> bool:
		return x.position.distance_to(_founder.position) < y.position.distance_to(_founder.position))
	return seated.slice(0, n)


## Takes the office's layout. The people wait, frozen and out of sight, until its floor is on the
## navigation map; on the city map and in the meeting room they wait for the next office.
func set_layout(layout: OfficeLayout, view: Node) -> void:
	_layout = layout
	_view = view
	_placed = false
	_kickoff = []
	_map = RID()
	_lift.clear()
	_lift_open = 0.0
	process_mode = PROCESS_MODE_DISABLED
	for a: OfficeActor in _actors.values():
		a.visible = false
	if not layout.staffed() or _headless():
		return
	if layout.id != _office:
		_office = layout.id
		_desk_of.clear()
	for panel: Dictionary in layout.elev_panels:
		_lift.append([view.find_child(panel.node, true, false), panel])
	_bed = layout.spots.bed[0] if layout.spots.has("bed") else {}
	_coffee = layout.spots.get("coffee", layout.spots.get("ket", []))
	# The door on the desks' side: the flat's stairs, not its street.
	var zone: String = layout.spots.desk[0].zone
	for kind: String in layout.spots:
		for s: Dictionary in layout.spots[kind]:
			if s.pose == "out" and s.zone == zone:
				_entry = s
	_map = (view.nav_region as NavigationRegion3D).get_navigation_map()


## The person under `screen_pos` (view pixels) as {character_id}, or {}.
func pick(screen_pos: Vector2) -> Dictionary:
	var a := _hit(screen_pos)
	return {} if a == null else {"character_id": a.character.id}


func hover(screen_pos: Vector2) -> String:
	var a := _hit(screen_pos)
	if a == null:
		return ""
	return tr("OFFICE_TOOLTIP").format({"name": a.character.character_name, "status": tr(a.status_key())})


## Rings the person with `character_id` ("" rings nobody), here and in the next office.
func select(character_id: String) -> void:
	_selected = character_id
	for a: OfficeActor in _actors.values():
		a.selected = a.character.id == character_id


func _physics_process(_delta: float) -> void:
	# Ahead of the people's own ticks (children tick after their parent): a pause stops them in this one.
	_k = 0.0 if get_tree().paused else _pace(TimeManager.current_speed)
	for a: OfficeActor in _actors.values():
		a.k = _k


func _process(delta: float) -> void:
	if founder_away and not _founder_told and not _founder.visible:
		_founder_told = true
		founder_arrived.emit()
	var dt := delta * _k
	_clock += dt
	# At night nobody sets off: those on the way arrive, and the cut takes everyone still in.
	if dt > 0.0 and not TimeManager.is_night():
		var minute := TimeManager.day_minute()
		_meetings(dt, minute)
		for a: OfficeActor in _actors.values():
			_steer(a, dt, minute)
	var icon_size := maxf(ICON_MIN, ICON_PX * (_view.camera as OfficeCamera).size / get_viewport().get_visible_rect().size.y)
	var lighting: OfficeLighting = _view.lighting
	var anyone := false
	var near_lift := false
	for a: OfficeActor in _actors.values():
		a.calling = a.founder and founder_calling
		a.decorate(icon_size)
		var at_desk := a.visible and a.phase == OfficePerson.Phase.SEATED and is_same(a.spot, a.seat)
		if a.desk_id >= 0:
			lighting.set_station_state(a.desk_id, at_desk)
		if a.founder:
			lighting.founder_at_desk = at_desk
		elif a.visible:
			anyone = true
		near_lift = near_lift or (a.visible and a.is_walking() and _layout.elev_near.has_point(a.position))
	lighting.anyone_in = anyone
	if dt > 0.0 and not _lift.is_empty():
		_lift_open += (float(near_lift) - _lift_open) * minf(1.0, dt * LIFT_EASE)
		for door: Array in _lift:
			var node: Node3D = door[0]
			var panel: Dictionary = door[1]
			node.set_indexed("rotation:y" if panel.rot else "position:" + panel.ax, panel.p0 + panel.d * _lift_open)


## Where `a` belongs this minute: their seat through their day, the bed out of hours for the
## founder at home, {} (out of the office) otherwise. The walk in starts early enough to land when
## they are due, the walk out EXIT_SLACK times its length before their end; a day too short for
## the walk out keeps them seated for the night's cut.
func _wanted(a: OfficeActor, minute: float) -> Dictionary:
	if a.ghost or a.seat.is_empty() or not WorkHoursSystem.in_office(a.character) or (a.founder and founder_away):
		return {}
	var day := _hours(a)
	if a.founder and not _bed.is_empty():
		return a.seat if minute >= day.x and minute < day.y - _walk_minutes(a.bed_len, BED_LEG_S) else _bed
	var walk := _walk_minutes(a.in_len, SEAT_LEG_S)
	if not a.cut_in and minute < day.x - walk:
		return {}
	var out := day.y - walk * OfficeConstants.EXIT_SLACK
	if not a.cut and minute >= out:
		a.cut = out - day.x < OfficeConstants.MIN_PRESENCE * (day.y - day.x)
		if not a.cut:
			return {}
	return a.seat


func _steer(a: OfficeActor, dt: float, minute: float) -> void:
	if a.plan.get("day", -1) != GameState.day:
		_plan_day(a, minute)
	var want := _wanted(a, minute)
	if want.is_empty():
		_head_out(a, minute)
	elif not a.visible:
		if _door_free(a):
			_send(a, want)
	elif not is_same(want, a.seat):
		if not is_same(a.spot, want):
			_drop_errand(a)
			_send(a, want)
	elif a.errand != "":
		_on_errand(a, dt)
	elif not is_same(a.spot, a.seat):
		_send(a, a.seat)
	elif not a.is_walking():
		_at_desk(a, dt, minute)


## Small idles between stretches of work, and the next break (none once left for the night's cut).
func _at_desk(a: OfficeActor, dt: float, minute: float) -> void:
	if a.idle_left > 0.0:
		a.idle_left -= dt
		if a.idle_left <= 0.0:
			_send(a, a.seat)
		return
	a.idle_in -= dt
	a.trip_in -= dt
	if a.trip_in <= 0.0 and not a.cut:
		a.trip_in = a.rng.randf_range(OfficeConstants.TRIP_EVERY.x, OfficeConstants.TRIP_EVERY.y)
		_take_break(a, minute)
	elif a.idle_in <= 0.0:
		a.idle_in = a.rng.randf_range(OfficeConstants.DESK_IDLE_EVERY.x, OfficeConstants.DESK_IDLE_EVERY.y)
		a.idle_left = a.rng.randf_range(OfficeConstants.DESK_IDLE_S.x, OfficeConstants.DESK_IDLE_S.y)
		a.go_to(a.seat, DESK_IDLES[a.rng.randi_range(0, DESK_IDLES.size() - 1)])


## Lunch once in its window, else a break drawn by weight from those this office has. A taken
## coffee counter or restroom has a line; a full line puts the break off.
func _take_break(a: OfficeActor, minute: float) -> void:
	if minute >= OfficeConstants.LUNCH_WINDOW.x and minute < OfficeConstants.LUNCH_WINDOW.y and a.lunch_day != GameState.day:
		var table := _venue.take(a, _break_spots(a, "eat"))
		if not table.is_empty():
			a.lunch_day = GameState.day
			_errand(a, table, "eat")
			return
	var kinds := []
	var weights := PackedFloat32Array()
	for kind: String in OfficeConstants.BREAK_WEIGHTS:
		var w: int = OfficeConstants.BREAK_WEIGHTS[kind][int(a.founder)]
		if w > 0 and not _break_spots(a, kind).is_empty():
			kinds.append(kind)
			weights.append(w)
	if kinds.is_empty():
		return
	var kind: String = kinds[a.rng.rand_weighted(weights)]
	var s := _venue.take(a, _break_spots(a, kind))
	if not s.is_empty():
		_errand(a, s, kind)
	elif _venue.has_line(kind):
		var place := _venue.join(a, kind)
		if place.is_empty():
			a.trip_in = a.rng.randf_range(OfficeConstants.POSTPONE.x, OfficeConstants.POSTPONE.y)
			return
		a.errand = kind
		a.queued = true
		a.status = ERRANDS[kind][0]
		a.go_to(place, "wait")


## The spots a break of `kind` can go to: a seated colleague's visitor place, the booths for a
## sales rep, else the office's spots of that kind; never a spare seat someone works at.
func _break_spots(a: OfficeActor, kind: String) -> Array:
	match kind:
		"coffee":
			return _coffee
		"visit":
			var visits: Array = _layout.spots.get("visit", [])
			var out := []
			for b: OfficeActor in _actors.values():
				if b != a and b.desk_id > 0 and b.desk_id <= visits.size() and b.visible and b.errand.is_empty() \
						and is_same(b.spot, b.seat) and _venue.is_free(visits[b.desk_id - 1]) \
						and not _spare.has(visits[b.desk_id - 1].pos):
					out.append(visits[b.desk_id - 1])
			return out
		"booth":
			return _layout.spots.get("booth", []) if a.character.role == HRConstants.ROLE_SALES_REP else []
	return _layout.spots.get(kind, []).filter(func(s: Dictionary) -> bool: return not _spare.has(s.pos))


## Away from the desk: in a line until its head takes a spot that frees, then at the break or round
## a table until the stay runs out, and back.
func _on_errand(a: OfficeActor, dt: float) -> void:
	if a.queued:
		if _venue.head(a.errand) == a:
			var s := _venue.take(a, _break_spots(a, a.errand))
			if not s.is_empty():
				var kind := a.errand
				_errand(a, s, kind)
				# The rest of the line steps up a place.
				var line := _venue.line(kind)
				var places := _venue.places(kind)
				for i in line.size():
					(line[i] as OfficeActor).go_to(places[i], "wait")
		return
	if a.is_walking():
		return
	a.stay -= dt
	if a.errand == "meeting":
		a.idle_in -= dt
		if a.idle_in <= 0.0:
			a.idle_in = OfficeConstants.MEETING_ACT_S
			a.go_to(a.spot, MEETING_ACTS[a.rng.randi_range(0, MEETING_ACTS.size() - 1)])
	if a.stay <= 0.0:
		_drop_errand(a)
		_send(a, a.seat)


## Off to `to` on an errand of `kind`, for `stay` ambient seconds (its kind's stay when < 0).
func _errand(a: OfficeActor, to: Dictionary, kind: String, stay := -1.0) -> void:
	a.errand = kind
	a.queued = false
	var range_s: Vector2 = OfficeConstants.STAYS.get(kind, Vector2.ZERO)
	a.stay = stay if stay >= 0.0 else a.rng.randf_range(range_s.x, range_s.y)
	a.status = ERRANDS[kind][0]
	a.go_to(to, ERRANDS[kind][1])


func _drop_errand(a: OfficeActor) -> void:
	_venue.release(a)
	a.errand = ""
	a.queued = false


## Team meetings in each free room (a role group with two or more at their desks, sometimes with
## the founder), the kick-off when a sprint starts, and the loft's all-hands at its hour.
func _meetings(dt: float, minute: float) -> void:
	if _layout.spots.has("trib") and minute >= OfficeConstants.ALL_HANDS_MINUTE and _all_hands_day != GameState.day:
		_all_hands_day = GameState.day
		for a: OfficeActor in _free_hands():
			var s := _venue.take(a, _layout.spots.present if a.founder else _layout.spots.trib)
			if not s.is_empty():
				_errand(a, s, "meeting", OfficeConstants.ALL_HANDS_S)
				# The audience listens throughout; the founder talks.
				a.idle_in = OfficeConstants.ALL_HANDS_S
				if not a.founder:
					a.go_to(s, "listen")
	for i in _rooms.size():
		var room: Array = _layout.meet_rooms[i]
		if not room.all(_venue.is_free):
			continue
		if not _kickoff.is_empty():
			var team := _kickoff
			_kickoff = []
			_meet(room, _free_hands().filter(func(a: OfficeActor) -> bool: return a.founder or team.has(a.character.id)))
			continue
		_rooms[i] -= dt
		if _rooms[i] > 0.0:
			continue
		_rooms[i] = _rng.randf_range(OfficeConstants.MEETING_EVERY.x, OfficeConstants.MEETING_EVERY.y)
		var groups := {}
		for a: OfficeActor in _free_hands():
			if not a.founder:
				groups.get_or_add(HRConstants.ROLE_GROUP[a.character.role], []).append(a)
		var teams: Array = groups.values().filter(func(g: Array) -> bool: return g.size() >= 2)
		if teams.is_empty():
			continue
		var team: Array = teams[_rng.randi_range(0, teams.size() - 1)]
		if _free_hands().has(_founder) and _rng.randf() < OfficeConstants.MEETING_FOUNDER:
			team.push_front(_founder)
		_meet(room, team)


## `team` round `room`'s table, as many as it seats.
func _meet(room: Array, team: Array) -> void:
	if team.size() < 2:
		return
	var length := _rng.randf_range(OfficeConstants.MEETING_LEN.x, OfficeConstants.MEETING_LEN.y)
	for a: OfficeActor in team.slice(0, room.size()):
		_errand(a, _venue.take(a, room), "meeting", length)
		a.idle_in = OfficeConstants.MEETING_ACT_S


## Those at their desks with nothing else on.
func _free_hands() -> Array:
	return _actors.values().filter(func(a: OfficeActor) -> bool:
		return a.visible and not a.ghost and not a.cut and a.errand.is_empty() and is_same(a.spot, a.seat) \
			and not a.is_walking())


## To their seat to work, or to bed.
func _send(a: OfficeActor, to: Dictionary) -> void:
	var doing := _doing(a, to)
	a.status = doing[0]
	a.go_to(to, doing[1])


## [status, body act] at the seat or in bed.
func _doing(a: OfficeActor, to: Dictionary) -> Array:
	return ["sleep", "idle"] if is_same(to, _bed) else [a.work, WORK_BODY[a.work]]


## Out through the door one at a time: each takes the next turn at it, DOOR_S after the one before,
## and sets off when a walk from their seat lands on it; one whose turn falls after the day's end
## stays seated for the night's cut. Someone gone from the company is removed once through.
func _head_out(a: OfficeActor, minute: float) -> void:
	if not a.visible:
		if a.ghost:
			_remove(a)
	elif is_same(a.spot, _entry):
		pass
	elif a.leave_at < 0.0:
		var walk := _walk_s(a.in_len, SEAT_LEG_S) * OfficeConstants.EXIT_SLACK
		var turn := maxf(_clock + walk, _door_turn)
		if minute + _game_minutes(turn - _clock) > WorkHoursSystem.workday_end() * 60.0 and not a.ghost:
			a.cut = true
			return
		_door_turn = turn + OfficeConstants.DOOR_S
		a.leave_at = turn - walk
	elif _clock >= a.leave_at:
		_drop_errand(a)
		a.status = "leave"
		a.go_to(_entry, "idle")


func _remove(a: OfficeActor) -> void:
	_venue.release(a)
	_actors.erase(a.character.id)
	a.queue_free()


## The door is free for `a` to come in: the last one in has walked DOOR_CLEAR from it, and nobody
## is on the last metres out through it (whoever stands near it is walked round).
func _door_free(a: OfficeActor) -> bool:
	var reach: float = _entry.pos.distance_to(_entry.tail[0]) + OfficeConstants.DOOR_CLEAR
	return _actors.values().all(func(b: OfficeActor) -> bool:
		if b == a or not b.visible or not b.is_walking():
			return true
		var d: float = b.position.distance_to(_entry.pos)
		return d > OfficeConstants.DOOR_CLEAR and not (is_same(b.spot, _entry) and d <= reach))


## Today's draws for `a`: due in after the start (some days late), gone before their end; the
## founder keeps the window. From the person and the week, so no two people and no two weeks keep
## one timetable. Placed at the desk at the morning cut when the walk in cannot land in time.
func _plan_day(a: OfficeActor, minute: float) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = SalesConstants.mix_seed(SalesConstants.mix(a.character.id, SalesConstants.SALT_DAY), GameState.day)
	a.plan = {"day": GameState.day, "late": 0.0, "early": 0.0}
	if not a.founder:
		a.plan.late = r.randf_range(OfficeConstants.ARRIVE_JITTER.x, OfficeConstants.ARRIVE_JITTER.y)
		if r.randf() < OfficeConstants.LATE_SHARE:
			a.plan.late += r.randf_range(OfficeConstants.LATE_EXTRA.x, OfficeConstants.LATE_EXTRA.y)
		a.plan.early = r.randf_range(OfficeConstants.LEAVE_JITTER.x, OfficeConstants.LEAVE_JITTER.y)
	a.cut = false
	a.leave_at = -1.0
	a.cut_in = minute + _walk_minutes(a.in_len, SEAT_LEG_S) > _hours(a).x + OfficeConstants.ARRIVE_LATE_OK


## (due in, gone by) in game minutes today, on the hours as they stand now.
func _hours(a: OfficeActor) -> Vector2:
	return Vector2(WorkHoursSystem.start_hour() * 60.0 + a.plan.late,
		WorkHoursSystem.end_hour_for(a.character) * 60.0 - a.plan.early)


## Ambient seconds a walk of `metres` takes, with `extra_s` of getting up and sitting down.
static func _walk_s(metres: float, extra_s: float) -> float:
	return metres / OfficePerson.WALK_SPEED + extra_s


## Game minutes the same walk takes at the game's speed.
func _walk_minutes(metres: float, extra_s: float) -> float:
	return _game_minutes(_walk_s(metres, extra_s))


## Game minutes `ambient_s` ambient seconds take at the game's speed (paused, the speed it resumes at).
func _game_minutes(ambient_s: float) -> float:
	var speed: int = TimeManager.current_speed if TimeManager.current_speed > 0 else TimeManager.last_running_speed
	return 60.0 * TimeManager.hours_per_real_second(speed) * ambient_s / _pace(speed)


## k at game speed `speed`: the clock's game minutes per real second over the people's own pace,
## capped at VISUAL_CAP.
static func _pace(speed: int) -> float:
	return minf(60.0 * TimeManager.hours_per_real_second(speed) / OfficeConstants.PACE_MINUTES, OfficeConstants.VISUAL_CAP)


## Matches the actors to the roster. A newcomer starts out of sight at the door; someone gone from
## it is a ghost who walks out. The founder has desk 0; the staff keep their desks, a newcomer
## takes the lowest free one, then a spare place (an eating table's seat, then a visitor's place);
## anyone past those is not drawn. At home only the founder is. `cut` places everyone where they
## belong now, with no walk.
func _sync(cut: bool) -> void:
	var people: Array[Character] = []
	if _layout.id != "home":
		people = CharacterRegistry.employees_by_hire()
	people.push_front(CharacterRegistry.get_founder())
	var ids := people.map(func(c: Character) -> String: return c.id)
	for a: OfficeActor in _actors.values():
		if not ids.has(a.character.id) and not a.ghost:
			a.ghost = true
			if a.desk_id >= 0:
				(_view.lighting as OfficeLighting).set_station_state(a.desk_id, false)
			a.desk_id = -1
			_desk_of.erase(a.character.id)
	var desks: Array = _layout.spots.desk
	var taken := _desk_of.values()
	var free := range(1, mini(desks.size(), _layout.max_n + 1)).filter(func(d: int) -> bool: return not taken.has(d))
	var spares: Array = _layout.spots.get("eat", []) + _layout.spots.get("visit", [])
	_spare.clear()
	for c in people:
		var a: OfficeActor = _actors.get(c.id)
		if a == null:
			a = OfficeActor.new()
			add_child(a)
			a.setup_actor(c)
			a.k = _k
			a.selected = c.id == _selected
			a.trip_in = a.rng.randf_range(OfficeConstants.FIRST_BREAK.x, OfficeConstants.FIRST_BREAK.y)
			a.idle_in = a.rng.randf_range(OfficeConstants.DESK_IDLE_EVERY.x, OfficeConstants.DESK_IDLE_EVERY.y)
			a.place(_entry, "idle")
			_actors[c.id] = a
		if a.founder:
			_founder = a
		elif not _desk_of.has(c.id) and not free.is_empty():
			_desk_of[c.id] = free.pop_front()
		a.desk_id = 0 if a.founder else _desk_of.get(c.id, -1)
		a.seat = desks[a.desk_id] if a.desk_id >= 0 else (spares.pop_front() if not spares.is_empty() else {})
		if a.desk_id < 0 and not a.seat.is_empty():
			_spare[a.seat.pos] = true
		a.work = _work_of(c)
		a.in_len = _path_len(_entry, a.seat) if not a.seat.is_empty() else 0.0
		a.bed_len = _path_len(a.seat, _bed) if a.founder and not _bed.is_empty() else 0.0
	if cut:
		var minute := TimeManager.day_minute()
		for a: OfficeActor in _actors.values():
			_place(a, minute)


## Puts `a` where they belong at `minute` with no walk: under a black frame or a load.
func _place(a: OfficeActor, minute: float) -> void:
	_drop_errand(a)
	_plan_day(a, minute)
	var want := _wanted(a, minute)
	# Not due yet and in time on foot: they walk in from the door.
	if want.is_empty() or (is_same(want, a.seat) and _bed.is_empty() and not a.cut_in and minute < _hours(a).x):
		a.status = ""
		a.place(_entry, "idle")
	else:
		var doing := _doing(a, want)
		a.status = doing[0]
		a.place(want, doing[1])


static func _work_of(c: Character) -> String:
	if c.category == "founder":
		return "plan"
	if c.assigned_job_ids.is_empty():
		return "research"
	var work: String = JOB_WORK[c.assigned_job_ids[0]]
	return "design" if work == "code" and not c.assigned_jobs.has(HRConstants.AREA_ENGINEERING) else work


## Metres along the floor from one spot to another, their own last metres included.
func _path_len(from: Dictionary, to: Dictionary) -> float:
	var a: Vector3 = from.tail[0]
	var b: Vector3 = to.tail[0]
	var lift := Vector3.UP * OfficePerson.NAV_LIFT
	var path := NavigationServer3D.map_get_path(_map, a + lift, b + lift, true)
	var n: float = from.pos.distance_to(a) + to.pos.distance_to(b)
	for i in range(1, path.size()):
		n += path[i].distance_to(path[i - 1])
	return n


## Each spot's way in from the floor, written into the layout's own spot for OfficePerson: the
## design's chain from its first point on the baked floor, at the drawn floor's height (the stairs,
## the tribune and the mezzanine start off it).
func _mark_tails() -> void:
	for kind: String in _layout.spots:
		for s: Dictionary in _layout.spots[kind]:
			var pts := [s.pos] + Array(s.chain)
			s.tail = [OfficePerson.way_in(s)]
			for j in range(1, pts.size()):
				var near := OfficePerson.floor_near(_map, pts[j], ON_FLOOR)
				if near != Vector3.INF:
					var back := pts.slice(1, j)
					back.reverse()
					s.tail = [near] + back
					break


func _hit(screen_pos: Vector2) -> OfficeActor:
	var camera: Camera3D = _view.camera
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var best: OfficeActor = null
	var nearest := INF
	for a: OfficeActor in _actors.values():
		if not a.visible or a.ghost:
			continue
		var d := a.hit(from, dir)
		if d < nearest:
			nearest = d
			best = a
	return best


## The office's floor is on the navigation map: the spots' ways in, the shared places, and
## everyone where they belong.
func _on_map_changed(map: RID) -> void:
	if _placed or map != _map or not OfficePerson.floor_ready(_view.nav_region, _entry.pos, _layout.spots.desk[0].pos):
		return
	_placed = true
	process_mode = PROCESS_MODE_INHERIT
	_mark_tails()
	_venue = OfficeVenue.new({"coffee": _coffee, "wc": _layout.spots.get("wc", [])}, _map)
	_rng.seed = hash(_layout.id)
	_rooms.clear()
	for room: Array in _layout.meet_rooms:
		_rooms.append(_rng.randf_range(OfficeConstants.MEETING_EVERY.x, OfficeConstants.MEETING_EVERY.y))
	_sync(true)


## 08:00 under the night's black: the ghosts are gone and everyone is placed for the new day.
func _on_night_skipped() -> void:
	_fade = null
	if not _placed:
		return
	for a: OfficeActor in _actors.values():
		if a.ghost:
			_remove(a)
		else:
			_place(a, TimeManager.day_minute())


func _on_roster_changed() -> void:
	if _placed:
		_sync(false)


func _on_assignment_changed(character_id: String) -> void:
	var a: OfficeActor = _actors.get(character_id)
	if a == null or a.ghost:
		return
	a.work = _work_of(a.character)
	if a.errand.is_empty() and is_same(a.spot, a.seat):
		_send(a, a.seat)


static func _headless() -> bool:
	return DisplayServer.get_name() == "headless"
