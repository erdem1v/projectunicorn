extends Control

# The founder's trip to an outside meeting, played on the office view. main.gd runs it with the
# sitting already open, the clock frozen and the tree running: the founder walks out, the view
# blinks to the city map in road mode, and the camera and the pin slide to the meeting's
# building. travel_back() puts the office back under the meeting scene, and arrive() brings the
# founder in once the meeting's hours have run. A click or Esc skips the trip; Space and the
# speed keys do nothing during it. The node is the view's, so its waits and fades also run once
# the scene has paused the tree.

const EXIT_S := 1.5    # [WORKING] the founder's walk out is watched this long at most
const FADE_S := 0.25   # [WORKING] each half of the blink into the map

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


func travel_out() -> void:
	_skipped = false
	move_to_front()
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)
	_people.send_founder_out()
	await _until(_people.founder_arrived, EXIT_S)
	if not _skipped:
		await _until(_view.fade(true, FADE_S).finished)
	if not _skipped:
		_view.load_layout("city", true)
		_view.fade(false, FADE_S)
		_city.drive(OfficeConstants.MEETING_TARGET[OfficeSystem.current()])
		await _until(_view.camera.focus_done)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(false)


## The office comes back, without the founder, two frames after the scene mounts: the scene is
## on screen before the load's hitch.
func travel_back() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_view.load_layout(OfficeSystem.current())
	_view.fade(false, FADE_S)


func arrive() -> void:
	_people.founder_back()


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
