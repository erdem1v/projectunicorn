class_name OfficeCrowdProbe
extends Node

# --office-crowd-probe's watch (main.gd sets the office up): every person on every physics tick
# through one day on the real clock, a second's pause at noon, the night and the skip into the
# next morning. Counts what must not happen (a step longer than walking allows, motion while
# paused, a stalled walker, a pose that does not match what the body does, two people on their
# feet inside each other, someone appearing or vanishing away from the door on a lit frame, an
# engine error) and what should (walks in and out, cuts under black, lines, meetings), then
# prints CROWD lines. Also builds the office shot's people sheets (main.gd --office-shot extras).

const CROWD := 0.3          # metres between two people on their feet
const STALL_S := 6.0        # ambient seconds a walker may go without getting anywhere
## Frames a pose may trail its phase: a body poses every few frames (its LOD), and the tree may take
## a few of those to travel to the phase's state.
const POSE_LAG := 3 * OfficePerson.OFF_SCREEN
const DOOR := 0.5           # metres from the door where people may appear and vanish
const PAUSE_S := 1.0        # real seconds of pause at noon
const MORNING_MIN := 72.0   # game minutes kept after the night skip, the same morning at every speed
const SHOTS := [0.02, 0.3, 0.6]   # shares of the working day a frame is saved at
const WARM_UP := "crowd_probe"    # the clock's freeze while the people take their first frames
const WARM_FRAMES := 3
const NAV_FLOOR := Color(0.1, 0.9, 0.2, 0.45)
const NAV_WAY := Color(0.9, 0.1, 0.1)
const NAV_DOOR := Color(0.1, 0.2, 0.95)

var _view: Control
var _people: OfficePeople
var _counts := {}
var _notes: PackedStringArray = []
var _prev := {}
var _prev_k := {}
var _since := {}
var _shown := {}
var _queued := {}
var _meeting := {}
var _lines := {}            # kind -> the longest the line got
var _crowded := {}          # "phase+phase near x,z" -> pair-ticks, where people ran into each other
var _night_s := -1.0        # real seconds since the night began, -1 before it
var _frame_ms: PackedFloat32Array = []
var _probe_us := 0          # this watch's own cost, to take off the frame times
var _ticks := 0


class Catch extends Logger:
	var probe: OfficeCrowdProbe

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool,
			error_type: int, _backtraces: Array[ScriptBacktrace]) -> void:
		if error_type != ERROR_TYPE_WARNING:
			probe.call_deferred("_on_error", "%s:%d %s %s %s" % [file.get_file(), line, function, code, rationale])


## `n` employees in turn through the roles, each at their role's first job.
static func seed_staff(n: int) -> void:
	for i in n:
		var c := Character.new()
		c.id = "char_crowd_%d" % i
		c.character_name = "%s %s" % [HRConstants.FIRST_NAMES[i * 7 % HRConstants.FIRST_NAMES.size()],
			HRConstants.LAST_NAMES[i * 3 % HRConstants.LAST_NAMES.size()]]
		c.role = HRConstants.EMPLOYEE_ROLES[i % HRConstants.EMPLOYEE_ROLES.size()]
		c.category = "employee"
		c.role_stats = HRConstants.seed_skills(c.role, 5, 3, 1)
		c.traits = ["picks_it_up_fast"]
		CharacterRegistry.add(c)
		CharacterRegistry.assign_job(c.id, HRConstants.default_job_for_role(c.role))


## Watches `view`'s people at game speed `speed`; `save` takes a shot's file name.
func run(view: Control, speed: int, label: String, save: Callable) -> void:
	_view = view
	_people = view.get_node("Viewport3D/SubViewport/World/People")
	var catch := Catch.new()
	catch.probe = self
	OS.add_logger(catch)
	for key in ["jump", "paused_move", "nan", "stall", "pose", "crowd", "pop", "vanish", "walk_in", "cut_in",
			"walk_out", "cut_out", "queued", "meetings", "error"]:
		_counts[key] = 0
	while not _people._placed:
		await get_tree().process_frame
	process_physics_priority = 100
	_report_draws()
	var skipped := [false]
	var on_skip := func() -> void:
		skipped[0] = true
		if _night_s >= OfficeConstants.NIGHT_WAIT_S - 0.05:
			var walking := _people._actors.values().filter(func(a: OfficeActor) -> bool: return a.visible and a.is_walking())
			_notes.append("still walking at the cap: %s" % ", ".join(walking.map(func(a: OfficeActor) -> String:
				return "%s %s" % [a.character.id, OfficePerson.Phase.keys()[a.phase]])))
	EventBus.night_skipped.connect(on_skip, CONNECT_ONE_SHOT)
	# The probe's own work (the draws above, a shot's save) and the people's first frames off the
	# pause are kept off the clock: a slow frame at 4× is four times the game minutes, and the door
	# lets in one a frame. The first frames run at 1×, the same at every speed.
	TimeManager.freeze_clock(WARM_UP)
	EventBus.speed_change_requested.emit(1)
	for _i in WARM_FRAMES:
		await get_tree().process_frame
	EventBus.speed_change_requested.emit(speed)
	TimeManager.thaw_clock(WARM_UP)
	var start := TimeModel.WEEK_START_HOUR * 60.0
	var end := WorkHoursSystem.workday_end() * 60.0
	var shot := 0
	var paused := false
	# The frame times are the people's: the frame after the start, a shot's save or the pause's end,
	# and a frame with a step of the clock's hour (its systems' tick, the night's start and skip),
	# carry the probe's or the clock's work, the same at every speed, and are left out.
	var hitch := true
	while not skipped[0] or TimeManager.day_minute() < start + MORNING_MIN:
		var hour: int = GameState.current_hour
		await get_tree().process_frame
		var dt := get_process_delta_time()
		if not hitch and GameState.current_hour == hour:
			_frame_ms.append(dt * 1000.0)
		hitch = false
		var share := (TimeManager.day_minute() - start) / (end - start)
		if shot < SHOTS.size() and share >= SHOTS[shot] and not skipped[0]:
			EventBus.speed_change_requested.emit(0)
			save.call("crowd_%s_%02d" % [label, shot])
			await get_tree().process_frame
			EventBus.speed_change_requested.emit(speed)
			shot += 1
			hitch = true
		if not paused and share >= 0.5:
			paused = true
			EventBus.speed_change_requested.emit(0)
			await get_tree().create_timer(PAUSE_S).timeout
			EventBus.speed_change_requested.emit(speed)
			hitch = true
		if TimeManager.is_night() and not skipped[0]:
			if _night_s < 0.0:
				_night_s = 0.0
				save.call("crowd_%s_%02d" % [label, SHOTS.size()])
				hitch = true
			_night_s += dt
	save.call("crowd_%s_%02d" % [label, SHOTS.size() + 1])
	var ms := Array(_frame_ms)
	ms.sort()
	var places := _crowded.keys()
	places.sort_custom(func(x: String, y: String) -> bool: return _crowded[x] > _crowded[y])
	print("CROWD motion %s" % _pick(["jump", "paused_move", "nan", "stall", "pose", "crowd", "error"]))
	print("CROWD doors %s" % _pick(["walk_in", "cut_in", "walk_out", "cut_out", "pop", "vanish"]))
	print("CROWD rhythm queued=%d longest=%s meetings=%d" % [_counts.queued, _lines, _counts.meetings])
	print("CROWD night wait_s=%.2f capped=%s" % [_night_s, str(_night_s >= OfficeConstants.NIGHT_WAIT_S - 0.05)])
	# Without the frames that step the clock's hour, so not every frame the player sees; at 4× a day
	# has a quarter of the frames, so its p99 is a handful of them: slow is the share over a tick.
	print("CROWD frames n=%d mean_ms=%.2f p99_ms=%.2f max_ms=%.2f slow=%.1f%% probe_ms=%.2f (no hour steps)" % [
		ms.size(), ms.reduce(func(a: float, b: float) -> float: return a + b, 0.0) / ms.size(), ms[int(ms.size() * 0.99)],
		ms[-1], 100.0 * ms.filter(func(m: float) -> bool: return m > 1000.0 / 60.0).size() / ms.size(),
		_probe_us / 1000.0 / maxi(1, _ticks)])
	print("CROWD crowded %s" % ", ".join(places.slice(0, 3).map(func(k: String) -> String: return "%s %d" % [k, _crowded[k]])))
	for n in _notes:
		print("CROWD note %s" % n)
	print("CROWD END")


func _physics_process(delta: float) -> void:
	if _people == null or not _people._placed:
		return
	var started := Time.get_ticks_usec()
	var dark: bool = (_view.get_node("Viewport3D") as CanvasItem).modulate.v < 0.1
	var actors: Array = _people._actors.values()
	for a: OfficeActor in actors:
		var at := a._prev_pos
		if not at.is_finite():
			_counts.nan += 1
			continue
		if _shown.get(a, a.visible) != a.visible:
			_door(a, at, dark)
		_shown[a] = a.visible
		if _prev.has(a) and a.visible:
			var step := at.distance_to(_prev[a])
			if a.k == 0.0 and _prev_k.get(a, 1.0) == 0.0 and step > 1e-5:
				_counts.paused_move += 1
			elif step > OfficePerson.WALK_SPEED * maxf(a.k, _prev_k.get(a, 1.0)) * delta * 1.6 + 0.002 and not dark:
				_count("jump", "jump %.2f m %s in %s" % [step, a.character.id, OfficePerson.Phase.keys()[a.phase]])
		_prev[a] = at
		_prev_k[a] = a.k
		var key := "%d" % a.phase
		if _since.get(a, [""])[0] != key:
			_since[a] = [key, 0.0, at, Engine.get_process_frames()]
		else:
			_since[a][1] += delta * a.k
		if a.phase == OfficePerson.Phase.WALK and _since[a][1] > STALL_S:
			if at.distance_to(_since[a][2]) < 0.2:
				_count("stall", "stall %s at %s" % [a.character.id, at])
			_since[a][1] = 0.0
			_since[a][2] = at
		if _since[a][1] > 1.0 and Engine.get_process_frames() - _since[a][3] > POSE_LAG and a.visible \
				and not _pose_matches(a):
			_count("pose", "pose %s in %s" % [a._playback.get_current_node(), OfficePerson.Phase.keys()[a.phase]])
			_since[a][1] = -INF
		if a.queued and not _queued.get(a, false):
			_counts.queued += 1
		_queued[a] = a.queued
		if a.errand == "meeting" and not _meeting.get(a, false):
			_counts.meetings += 1
		_meeting[a] = a.errand == "meeting"
	for kind: String in _people._venue._lines:
		_lines[kind] = maxi(_lines.get(kind, 0), (_people._venue._lines[kind] as Array).size())
	for i in actors.size():
		for j in range(i + 1, actors.size()):
			var a: OfficeActor = actors[i]
			var b: OfficeActor = actors[j]
			if a.visible and b.visible and not _down(a) and not _down(b) \
					and Vector2(a.position.x - b.position.x, a.position.z - b.position.z).length() < CROWD:
				_counts.crowd += 1
				var where := "%s+%s near %d,%d" % [OfficePerson.Phase.keys()[mini(a.phase, b.phase)],
					OfficePerson.Phase.keys()[maxi(a.phase, b.phase)], roundi(a.position.x), roundi(a.position.z)]
				_crowded[where] = _crowded.get(where, 0) + 1
	_probe_us += Time.get_ticks_usec() - started
	_ticks += 1


## Someone appeared or vanished: under black anywhere, else only at the door on foot.
func _door(a: OfficeActor, at: Vector3, dark: bool) -> void:
	var at_door: bool = at.distance_to(_people._entry.pos) < DOOR
	if a.visible:
		_count("cut_in" if dark else ("walk_in" if at_door else "pop"), "" if at_door or dark else "pop %s at %s" % [a.character.id, at])
	else:
		_count("cut_out" if dark else ("walk_out" if at_door else "vanish"), "" if at_door or dark else "vanish %s at %s" % [a.character.id, at])


func _count(key: String, note: String) -> void:
	_counts[key] += 1
	if note != "" and _counts[key] <= 3:
		_notes.append(note)


func _pick(keys: Array) -> String:
	return " ".join(keys.map(func(k: String) -> String: return "%s=%d" % [k, _counts[k]]))


## The looks and today's timetables: how close the nearest two come.
func _report_draws() -> void:
	var actors: Array = _people._actors.values()
	var plans := {}
	for a: OfficeActor in actors:
		plans["%.1f/%.1f" % [a.plan.late, a.plan.early]] = true
	print("CROWD START %s plans=%d distinct=%d" % [looks_line(actors), actors.size(), plans.size()])


## How many people, how many distinct looks, and the fewest glance slots two of them are apart.
static func looks_line(actors: Array) -> String:
	var sigs := {}
	var apart := 99
	for i in actors.size():
		var look: Dictionary = (actors[i] as OfficeActor).character.look
		sigs[LookSystem.signature(look)] = true
		for j in range(i + 1, actors.size()):
			apart = mini(apart, LookSystem.apart(look, (actors[j] as OfficeActor).character.look))
	return "people=%d looks=%d min_apart=%d" % [actors.size(), sigs.size(), apart]


## The eleven founder portraits (tools/people/bake_portraits.gd), each beside the live bust of the
## look they are rendered from.
static func founder_sheet() -> Control:
	var sheet := PanelContainer.new()
	sheet.set_anchors_preset(Control.PRESET_FULL_RECT)
	var grid := GridContainer.new()
	grid.columns = 8
	sheet.add_child(grid)
	for id: String in FounderConstants.PORTRAIT_IDS:
		var portrait := TextureRect.new()
		portrait.texture = load(FounderConstants.portrait_path(id, FounderConstants.PORTRAIT_CELL))
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.custom_minimum_size = Vector2(FounderConstants.PORTRAIT_CELL)
		grid.add_child(portrait)
		grid.add_child(UiFactory.make_person_avatar(id, LookSystem.founder(id), FounderConstants.PORTRAIT_CELL.x))
	return sheet


## The office's baked floor (green), the spots' ways in (red) and the doors (blue) over the scene.
static func nav_overlay(layout: OfficeLayout) -> Node3D:
	var nm: NavigationMesh = load("res://art/office3d/%s_nav.tres" % layout.id)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for p in nm.get_polygon_count():
		var poly := nm.get_polygon(p)
		for i in range(1, poly.size() - 1):
			for v: int in [poly[0], poly[i], poly[i + 1]]:
				st.add_vertex(nm.vertices[v] + Vector3.UP * 0.03)
	var root := MeshInstance3D.new()
	root.mesh = st.commit()
	root.material_override = _flat(NAV_FLOOR)
	for kind: String in layout.spots:
		for s: Dictionary in layout.spots[kind]:
			var dot := MeshInstance3D.new()
			dot.mesh = BoxMesh.new()
			(dot.mesh as BoxMesh).size = Vector3.ONE * 0.18
			dot.material_override = _flat(NAV_DOOR if s.pose == "out" else NAV_WAY)
			dot.position = OfficePerson.way_in(s) + Vector3.UP * 0.1
			root.add_child(dot)
	return root


static func _flat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if c.a < 1.0 else BaseMaterial3D.TRANSPARENCY_DISABLED
	return m


func _on_error(text: String) -> void:
	_count("error", "ERR " + text)


static func _down(p: OfficePerson) -> bool:
	return p.phase in OfficePerson.DOWN or p.phase in [OfficePerson.Phase.STAND_UP, OfficePerson.Phase.GET_UP]


## The tree is in the phase's state, or still in the one-shot that hands on to it at its end: after
## a slow frame the physics catch-up can run a whole sit-down or stand-up before the tree starts it.
static func _pose_matches(p: OfficePerson) -> bool:
	var node := p._playback.get_current_node()
	var leading := p._playback.get_current_play_position() < p._playback.get_current_length()
	match p.phase:
		OfficePerson.Phase.WALK, OfficePerson.Phase.FOLLOW, OfficePerson.Phase.WAIT_LINK, OfficePerson.Phase.TURN:
			return node == &"move" or (node == &"stand_up" and leading)
		OfficePerson.Phase.SEATED:
			return node == &"seated" or (node == &"sit_down" and leading)
		OfficePerson.Phase.LYING:
			return node == &"sleep"
		OfficePerson.Phase.STILL:
			return node == (&"stand" if p._here.get("pose", "") == "stand" else &"move")
	return true
