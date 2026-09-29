extends Control

# The founder's trip to an outside meeting and back, played on the office view. main.gd runs it
# with the sitting open, the clock frozen and the tree running. Out: the founder walks out of the
# office while the two seated nearest look up, the view blinks to the city map, where the
# founder's disc rides the road to the investors' tower (OfficeCity.road), and blinks into the
# meeting room on its top floor (MeetingCast): the other side sits at the table and the founder
# walks in from the lift and sits down. Home: the founder gets up for the lift, the road back, and
# the office, where the founder walks back in and the one seated nearest looks up and asks how it
# went. A click or Esc skips the trip; Space and the speed keys do nothing during it. The node is
# the view's, so its waits and fades also run once the scene has paused the tree.

const EXIT_S := 1.5    # [WORKING] the founder's walk out is watched this long at most
const FADE_S := 0.25   # [WORKING] each half of a blink
const SEAT_S := 8.0    # [WORKING] the walk to the table is watched this long at most
## Seconds into the walk out that the two seated nearest look up, and how long they look on once
## the founder is out.
const LOOK_AT := [0.5, 1.2]
const LOOK_HOLD := 0.9
const LEAVE_S := 1.6   # [WORKING] the founder gets up from the table this long before the blink
## Seconds into the walk back in that the one seated nearest looks up and asks, and for how long.
const ASK_AT := 1.3
const ASK_S := 2.6

var _view: Control
var _people: OfficePeople
var _city: OfficeCity
var _skipped := false


func _init(view: Control, people: OfficePeople, city: OfficeCity) -> void:
	_view = view
	_people = people
	_city = city
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# READY turns input on for a script with _input; the keys are the trip's only.
	set_process_input(false)


## To the meeting room: `looks` sit at the table (lead first), `tower_label` names the tower on the
## map. Ends with the founder seated at the table.
func travel_out(looks: Array, tower_label: String) -> void:
	_begin()
	var lookers := _people.nearest_to_founder(LOOK_AT.size())
	var founder: OfficeActor = _people.founder()
	_people.send_founder_out()
	for i in lookers.size():
		# Not once the founder is through the door or the trip has left the office.
		get_tree().create_timer(LOOK_AT[i]).timeout.connect(func() -> void:
			if founder.visible:
				lookers[i].look_at = founder)
	await _until(_people.founder_arrived, EXIT_S)
	await _until(get_tree().create_timer(LOOK_HOLD).timeout)
	for a: OfficeActor in lookers:
		a.look_at = null
	await _blink("city")
	if not _skipped:
		_city.road(true, tower_label)
		await _until(_city.road_done)
	await _blink("meet")
	var cast: MeetingCast = _view.cast
	cast.stage(looks, CharacterRegistry.get_founder().look, _skipped)
	if not _skipped:
		cast.walk_in()
		await _until(cast.founder_seated, SEAT_S)
	_end()


## Back to the office from the meeting room, `tower_label` naming the tower on the map again.
## Ends as the founder walks back in; the ask comes after.
func travel_home(tower_label: String) -> void:
	_begin()
	_view.cast.walk_out()
	await _until(_view.cast.founder_out, LEAVE_S)
	await _blink("city")
	if not _skipped:
		_city.road(false, tower_label)
		await _until(_city.road_done)
	await _blink(OfficeSystem.current())
	_people.founder_back()
	_end()
	get_tree().create_timer(ASK_AT).timeout.connect(_ask)


## The one seated nearest looks up at the founder walking back in and asks how it went.
func _ask() -> void:
	var asker := _people.nearest_to_founder(1)
	if asker.is_empty():
		return
	var a: OfficeActor = asker[0]
	a.look_at = _people.founder()
	a.gesture("lookup", ASK_S)
	EventBus.ticker_live_line.emit(a.character.character_name, tr("MEETING_BACK_ASK"))
	a.create_tween().tween_callback(func() -> void: a.look_at = null).set_delay(ASK_S)


func _begin() -> void:
	_skipped = false
	move_to_front()
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)


func _end() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(false)


## Loads `layout_id` under a blink to black, the map in road mode; a skipped trip loads it with
## no blink.
func _blink(layout_id: String) -> void:
	if not _skipped:
		await _until(_view.fade(true, FADE_S).finished)
	_view.load_layout(layout_id, layout_id == "city")
	_view.fade(false, FADE_S)


## Waits for `sig`, at most `max_s` seconds, and no longer once the trip is skipped.
func _until(sig: Signal, max_s := INF) -> void:
	var fired := [false]
	var mark := func() -> void: fired[0] = true
	sig.connect(mark, CONNECT_ONE_SHOT)
	while not fired[0] and not _skipped and max_s > 0.0:
		await get_tree().process_frame
		max_s -= get_process_delta_time()
	if sig.is_connected(mark):
		sig.disconnect(mark)


func _gui_input(event: InputEvent) -> void:
	if UiFactory.is_left_click(event):
		_skipped = true


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed:
		return
	match key.keycode:
		KEY_ESCAPE:
			_skipped = true
		KEY_SPACE, KEY_1, KEY_2, KEY_3, KEY_4, KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4:
			pass
		_:
			return
	get_viewport().set_input_as_handled()
