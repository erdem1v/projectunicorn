class_name OfficePeople
extends Node3D

# The staff in the office (office-sim-v12.js rebuildPeople and update, people-x.js): the founder
# and every employee as an OfficeActor, seated in hire order. Who is in follows the game clock,
# each person's working hours; how they move is real time, in a time-lapse office where a whole
# day passes in 12 real seconds at 1×. A walk in or out is sped up to take at most ARRIVE_MAX_S,
# and the clock may have moved on by the time they sit down or reach the door; short breaks from
# the desk run at walking pace. Walkers open the layout's lift or door, and the office lighting
# hears who sits at which desk.

const TRIP_EVERY := Vector2(25.0, 60.0)   # [WORKING] real seconds at the desk between breaks
const TRIP_STAY := Vector2(6.0, 10.0)     # [WORKING] real seconds at the break spot
const AWAY_SHARE := 1.0 / 3.0             # [WORKING] share of those in who may be off their seats
const ARRIVE_MAX_S := 3.0                 # [WORKING] real seconds a walk in or out may take
const LIFT_EASE := 6.0                    # the design's lift easing, per second
## The design's founder at home sleeps from 23:25 to 07:35 (office-home.js), in game minutes.
const BED := Vector2(1405.0, 455.0)
## Break spot kinds and what each reads as (people-x.js brk). Booths are the sales reps'; at
## home the founder takes the kettle and the balcony in place of the kitchen table.
const BREAKS := {"coffee": "coffee", "wc": "wc", "visit": "visit", "booth": "phone", "eat": "food"}
## What each job looks like at the desk; build is design work for a product or design person.
const JOB_ACTS := {
	HRConstants.JOB_BUILD: "code",
	HRConstants.JOB_TEST: "test",
	HRConstants.JOB_RESEARCH: "research",
	HRConstants.JOB_SALES: "phone",
	HRConstants.JOB_SUPPORT: "phone",
	HRConstants.JOB_ACCOUNTS: "phone",
}
const ICON_PX := 26.0     # the design's iconS: a head icon this many pixels tall,
const ICON_MIN := 0.6     # but never under this many world units

var _layout: OfficeLayout
var _view: Node
var _actors := {}         # character id -> OfficeActor
var _entry := {}          # where people come in and go out
var _bed := {}            # the founder's bed, at home
var _lift: Array = []     # [node, panel] per lift door or door wing
var _lift_open := 0.0


func _ready() -> void:
	EventBus.character_added.connect(_on_character_added)
	EventBus.character_removed.connect(_on_character_removed)
	EventBus.assignment_changed.connect(_on_assignment_changed)


func set_layout(layout: OfficeLayout, view: Node) -> void:
	_layout = layout
	_view = view
	_lift.clear()
	_lift_open = 0.0
	if layout.id == "city":
		for a: OfficeActor in _actors.values():
			a.visible = false
		return
	for panel: Dictionary in layout.elev_panels:
		_lift.append([view.find_child(panel.node, true, false), panel])
	_bed = layout.spots.bed[0] if layout.spots.has("bed") else {}
	# The door on the desks' side: the flat's stairs, not its street.
	var zone: String = layout.spots.desk[0].zone
	for kind: String in layout.spots:
		for s: Dictionary in layout.spots[kind]:
			if s.pose == "out" and s.zone == zone:
				_entry = s
	_seat_everyone()


## The person under `screen_pos` (view pixels) as {character_id}, or {}.
func pick(screen_pos: Vector2) -> Dictionary:
	var a := _hit(screen_pos)
	return {} if a == null else {"character_id": a.character.id}


func hover(screen_pos: Vector2) -> String:
	var a := _hit(screen_pos)
	if a == null:
		return ""
	return tr("OFFICE_TOOLTIP").format({"name": a.character.character_name, "status": tr(a.status_key())})


## Rings the person with `character_id` ("" rings nobody).
func select(character_id: String) -> void:
	for a: OfficeActor in _actors.values():
		a.selected = a.character.id == character_id


func _process(delta: float) -> void:
	if _layout.id == "city":
		return
	var running := not get_tree().paused
	var minute := TimeManager.day_minute()
	var icon_size := maxf(ICON_MIN, ICON_PX * (_view.camera as OfficeCamera).size / get_viewport().get_visible_rect().size.y)
	var lighting: OfficeLighting = _view.lighting
	var anyone := false
	var near_lift := false
	for a: OfficeActor in _actors.values():
		if running:
			_steer(a, delta, minute)
		a.animate(delta, running, icon_size)
		var at_desk := a.visible and not a.is_walking() and is_same(a.spot, a.seat)
		if a.desk_id >= 0:
			lighting.set_station_state(a.desk_id, at_desk)
		if a.founder:
			lighting.founder_at_desk = at_desk
		elif a.visible:
			anyone = true
		near_lift = near_lift or (a.is_walking() and _layout.elev_near.has_point(a.position))
	lighting.anyone_in = anyone
	if running and not _lift.is_empty():
		_lift_open += (float(near_lift) - _lift_open) * minf(1.0, delta * LIFT_EASE)
		for door: Array in _lift:
			var node: Node3D = door[0]
			var panel: Dictionary = door[1]
			node.set_indexed("rotation:y" if panel.rot else "position:" + panel.ax, panel.p0 + panel.d * _lift_open)


## Where `a` belongs now: their seat in working hours, the founder always (in bed at night at
## home); {} = not in the office.
func _wanted(a: OfficeActor, minute: float) -> Dictionary:
	if a.seat.is_empty() or a.character.status != HRConstants.STATUS_ACTIVE:
		return {}
	if a.founder:
		return _bed if not _bed.is_empty() and (minute >= BED.x or minute < BED.y) else a.seat
	var start := WorkHoursSystem.start_hour() * 60.0
	return a.seat if minute >= start and minute < start + WorkHoursSystem.hours_for(a.character) * 60.0 else {}


func _act_at(a: OfficeActor, place: Dictionary) -> String:
	return "sleep" if is_same(place, _bed) else a.work_act


func _steer(a: OfficeActor, delta: float, minute: float) -> void:
	if a.is_walking():
		a.advance(delta)
		return
	var want := _wanted(a, minute)
	if want.is_empty():
		if a.visible:
			a.stay = 0.0
			a.walk(_entry, "", ARRIVE_MAX_S)
	elif not a.visible:
		a.stand(_entry, "")
		a.walk(want, _act_at(a, want), ARRIVE_MAX_S)
	elif is_same(a.spot, want):
		a.trip_in -= delta
		if a.trip_in <= 0.0 and is_same(want, a.seat):
			a.trip_in = a.rng.randf_range(TRIP_EVERY.x, TRIP_EVERY.y)
			_take_break(a)
	elif a.stay > 0.0:
		a.stay -= delta
		if a.stay <= 0.0:
			a.walk(want, _act_at(a, want))
	else:
		a.walk(want, _act_at(a, want), ARRIVE_MAX_S)


## A short break to a free spot of a kind this office has; none while too many are up already.
func _take_break(a: OfficeActor) -> void:
	var inside := 0
	var up := 0
	var taken := {}   # spot position -> true: the seats of those in, and where each is or is heading
	for b: OfficeActor in _actors.values():
		if b.visible:
			inside += 1
			up += int(b.is_walking() or not is_same(b.spot, b.seat))
			taken[b.seat.pos] = true
			taken[b.destination().pos] = true
	if up >= maxi(1, int(inside * AWAY_SHARE)):
		return
	var home := _layout.id == "home"
	var options := []
	for kind: String in BREAKS:
		var spots: Array = _layout.spots.get(kind, [])
		match kind:
			"visit":
				spots = []
				for b: OfficeActor in _actors.values():
					if b != a and b.desk_id > 0 and b.visible and is_same(b.spot, b.seat):
						spots.append(_layout.spots.visit[b.desk_id - 1])
			"booth":
				if a.character.role != HRConstants.ROLE_SALES_REP:
					spots = []
			"eat":
				if home and a.founder:
					spots = _layout.spots.get("ket", []) + _layout.spots.get("bal", [])
		spots = spots.filter(func(s: Dictionary) -> bool: return not taken.has(s.pos))
		if not spots.is_empty():
			options.append([spots, "coffee" if kind == "eat" and home and a.founder else BREAKS[kind]])
	if options.is_empty():
		return
	var choice: Array = options[a.rng.randi_range(0, options.size() - 1)]
	a.stay = a.rng.randf_range(TRIP_STAY.x, TRIP_STAY.y)
	a.walk(choice[0][a.rng.randi_range(0, choice[0].size() - 1)], choice[1])


## Matches the actors to the roster and places everyone where they belong this minute, without
## walking: the founder at desk 0, employees by hire day at desks 1.., then at the layout's spare
## spots (the flat's kitchen table, balcony and kettle, an office's visit and coffee spots); anyone
## past those is not drawn.
func _seat_everyone() -> void:
	var people: Array[Character] = CharacterRegistry.get_employees()
	people.sort_custom(func(x: Character, y: Character) -> bool:
		return x.hire_day < y.hire_day or (x.hire_day == y.hire_day and x.id < y.id))
	var founder := CharacterRegistry.get_founder()
	if founder:
		people.push_front(founder)
	var ids := {}
	for c in people:
		ids[c.id] = true
		if not _actors.has(c.id):
			var a := OfficeActor.new()
			add_child(a)
			a.setup(c)
			a.trip_in = a.rng.randf_range(TRIP_EVERY.x, TRIP_EVERY.y)
			_actors[c.id] = a
	for id: String in _actors.keys():
		if not ids.has(id):
			_actors[id].queue_free()
			_actors.erase(id)

	var desks: Array = _layout.spots.desk
	var seats := desks.slice(1, mini(desks.size(), _layout.max_n + 1))
	var desk_count := seats.size()
	for kind: String in (["eat", "bal", "ket"] if _layout.id == "home" else ["visit", "coffee"]):
		seats.append_array(_layout.spots.get(kind, []))
	var lighting: OfficeLighting = _view.lighting
	for d in desks.size():
		lighting.set_station_state(d, false)
	var minute := TimeManager.day_minute()
	for i in people.size():
		var a: OfficeActor = _actors[people[i].id]
		var n := i - int(founder != null)
		a.seat = desks[0] if a.founder else (seats[n] if n < seats.size() else {})
		a.desk_id = 0 if a.founder else (n + 1 if n < desk_count else -1)
		a.work_act = _work_act(a.character)
		a.stay = 0.0
		var want := _wanted(a, minute)
		a.stand(_entry if want.is_empty() else want, "" if want.is_empty() else _act_at(a, want))


static func _work_act(c: Character) -> String:
	if c.category == "founder":
		return "plan"
	if c.assigned_job_ids.is_empty():
		return "research"
	var act: String = JOB_ACTS[c.assigned_job_ids[0]]
	return "design" if act == "code" and not c.assigned_jobs.has(HRConstants.AREA_ENGINEERING) else act


func _hit(screen_pos: Vector2) -> OfficeActor:
	var camera: Camera3D = _view.camera
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var best: OfficeActor = null
	var nearest := INF
	for a: OfficeActor in _actors.values():
		if not a.visible:
			continue
		var d := a.hit(from, dir)
		if d < nearest:
			nearest = d
			best = a
	return best


func _on_character_added(character_id: String) -> void:
	if _layout.id != "city" and CharacterRegistry.get_character(character_id).category in ["employee", "founder"]:
		_seat_everyone()


func _on_character_removed(character_id: String) -> void:
	if _actors.has(character_id) and _layout.id != "city":
		_seat_everyone()


func _on_assignment_changed(character_id: String) -> void:
	var a: OfficeActor = _actors.get(character_id)
	if a == null:
		return
	a.work_act = _work_act(a.character)
	if is_same(a.destination(), a.seat):
		a.act = a.work_act
