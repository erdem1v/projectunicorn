extends Control

# The office behind the windows: the design's 3D scene (tools/office3d) on the game clock. Loads
# the current office and swaps it on office_changed, drives its light every frame, and routes the
# pointer: drag and wheel move the camera, clicks and hover go to the people, or to the city map
# while that is the loaded layout. Windows are later siblings, so they take the pointer first.
# The skipped night blinks: the 3D image drops to dark (the people may have faded it out first) and
# the 08:00 light fades in. Under an open window the image dims, on its own modulate, so the blink
# multiplies with it and the controls over the office keep their colour. The controls over the
# office (the office_overlays group) step aside for the map and for the founder's trip.

const TRAVEL := preload("res://scripts/ui/office/office_travel.gd")
## The blink's dark end: the 3D view's own fade, scene data like the office's other colours.
const FADE_DARK := Color.BLACK
const NIGHT_FADE_S := 0.6     # [WORKING]
## The office under an open window: the 3D image times DIM, eased in and out over DIM_S.
const DIM := 0.84             # [WORKING]
const DIM_S := 0.12

@onready var _container: SubViewportContainer = $Viewport3D
@onready var camera: OfficeCamera = $Viewport3D/SubViewport/World/Camera3D
@onready var _scene_root: Node3D = $Viewport3D/SubViewport/World/SceneRoot
@onready var _people: OfficePeople = $Viewport3D/SubViewport/World/People
@onready var _city: OfficeCity = $Viewport3D/SubViewport/World/City
@onready var _tooltip: PanelContainer = $Overlay/Tooltip
@onready var _tooltip_label: Label = $Overlay/Tooltip/Label

var layout: OfficeLayout
var lighting: OfficeLighting
## The people of a meeting, in the `meet` layout.
var cast: MeetingCast
## The floor the people walk (tools/office3d/bake_nav.gd); null on the city map.
var nav_region: NavigationRegion3D
## The founder's trip to an outside meeting (main.gd plays it), and the call that opens it.
var travel: TRAVEL
var invite: MeetingInvite
var _lowest := 0.0
var _fitted := false
var _pointer_inside := false
var _fade: Tween
var _veiled := false   # the founder's trip is on: the layer shows the office alone
var _dimmed := false   # a window is open over the view
var _dim: Tween


func _ready() -> void:
	lighting = OfficeLighting.new($Viewport3D/SubViewport/World)
	cast = MeetingCast.new()
	$Viewport3D/SubViewport/World.add_child(cast)
	_container.gui_input.connect(camera.handle_input)
	_container.mouse_entered.connect(func() -> void: _pointer_inside = true)
	_container.mouse_exited.connect(_on_pointer_left)
	# Deferred: the container says it resized before it resizes the SubViewport the camera fits to.
	_container.resized.connect(_fit, CONNECT_DEFERRED)
	camera.clicked.connect(_on_clicked)
	EventBus.office_changed.connect(load_layout)
	EventBus.night_skipped.connect(_on_night_skipped)
	load_layout(OfficeSystem.current())
	travel = TRAVEL.new(self, _people, _city)
	$Overlay.add_child(travel)
	invite = MeetingInvite.new(self, _people)
	$Overlay.add_child(invite)


## A decision opens over the office: no move is chosen on a map left open under it.
func close_map() -> void:
	if layout.id == "city":
		_city.close()


## Loads an office (or "city", the map, or "meet", the meeting room) in place of the one on
## screen. `road` is the map of the founder's trip: no controls, and the view takes no pointer.
func load_layout(office_id: String, road := false) -> void:
	for old in _scene_root.get_children():
		old.free()
	layout = OfficeLayout.load(office_id)
	var scene: Node3D = (load("res://art/office3d/%s.glb" % office_id) as PackedScene).instantiate()
	_scene_root.add_child(scene)
	_lowest = INF
	for mi: MeshInstance3D in scene.find_children("*", "MeshInstance3D", true, false):
		_lowest = minf(_lowest, (mi.global_transform * mi.get_aabb()).position.y)
	var materials := OfficeMaterials.convert_scene(scene, layout)
	lighting.set_layout(layout, scene, materials, OfficeMaterials.stations(scene))
	_fitted = false
	_fit()
	nav_region = null
	var links := []
	if office_id != "city":
		var nm: NavigationMesh = load("res://art/office3d/%s_nav.tres" % office_id)
		var map := _scene_root.get_world_3d().navigation_map
		NavigationServer3D.map_set_cell_size(map, nm.cell_size)
		NavigationServer3D.map_set_cell_height(map, nm.cell_height)
		nav_region = NavigationRegion3D.new()
		nav_region.navigation_mesh = nm
		_scene_root.add_child(nav_region)
		# The stairs and doorways the bake could not join, as one-lane links.
		for l: Dictionary in nm.get_meta("links", []):
			var link := NavigationLink3D.new()
			link.bidirectional = true
			_scene_root.add_child(link)
			link.start_position = l.a
			link.end_position = l.b
			links.append({"rid": link.get_rid(), "path": l.path})
	OfficePerson.set_links(links)
	_people.set_layout(layout, self)
	cast.set_layout(layout, self)
	_city.set_layout(layout, self, materials.get("water", []), road)
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE if road else Control.MOUSE_FILTER_STOP
	if road:
		_on_pointer_left()
	_step_overlays()
	_ease_dim()


## WindowLayer keeps the view right of the rail (`left`, in the parent's space): the camera
## frames that part and the overlay's controls anchor to it.
func set_safe_left(left: float) -> void:
	offset_left = left


## WindowLayer's veil for the founder's trip: the controls over the office step aside until it
## lifts, through the loads of the trip too.
func set_veiled(veiled: bool) -> void:
	_veiled = veiled
	_step_overlays()


## WindowLayer dims the office while a window is open over it; the map stays lit.
func set_dimmed(dimmed: bool) -> void:
	_dimmed = dimmed
	_ease_dim()


## Eases the 3D image to FADE_DARK or back over `time` seconds. The tween is this node's, which
## runs while the tree is paused.
func fade(dark: bool, time: float) -> Tween:
	if _fade != null:
		_fade.kill()
	_fade = create_tween()
	_fade.tween_property(_container, "modulate", FADE_DARK if dark else Color.WHITE, time)
	return _fade


## `screen_pos` is in this view's own coordinates, as pick and hover receive it.
func show_tooltip(text: String, screen_pos: Vector2) -> void:
	_tooltip_label.text = text
	_tooltip.reset_size()
	_tooltip.position = (screen_pos + Vector2(UiTokens.SPACE_L, UiTokens.SPACE_L)).clamp(Vector2.ZERO, size - _tooltip.size)
	_tooltip.show()


func hide_tooltip() -> void:
	_tooltip.hide()


## The ring marks whose dossier is open: WindowLayer rings the person when it opens the dossier
## and clears the ring when that window closes.
func select_person(id: String) -> void:
	_people.select(id)


func clear_selection() -> void:
	_people.select("")


func _process(_delta: float) -> void:
	lighting.apply(TimeManager.day_minute())
	if not _pointer_inside or camera.is_dragging():
		return
	var at := _container.get_local_mouse_position()
	var label := _city.hover(at) if layout.id == "city" else _people.hover(at)
	# The map draws its own hover card and gives no text, so it answers for the cursor itself.
	var over := _city.is_hovering() or not label.is_empty()
	_container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if over else Control.CURSOR_ARROW
	if label.is_empty():
		hide_tooltip()
	else:
		show_tooltip(label, at)


## The first time the view has a size, frame the office; a later resize (the rail's mode, the UI
## scale, the window) refits and keeps the frame.
func _fit() -> void:
	if _container.size.x < 1.0 or _container.size.y < 1.0:
		return
	if _fitted:
		camera.refit()
		return
	_fitted = true
	camera.fit(layout.bounds, _lowest)
	camera.frame(layout.thumb_targets)


func _on_clicked(screen_pos: Vector2) -> void:
	if layout.id == "city":
		_city.pick(screen_pos)
		return
	var hit := _people.pick(screen_pos)
	if not hit.is_empty():
		get_tree().call_group(&"window_layer", &"open_detail", "hr_dossier", hit)


func _on_pointer_left() -> void:
	_pointer_inside = false
	hide_tooltip()


## The map brings its own corners, and the trip and the meeting room want none: the controls over
## the office step aside while any is on.
func _step_overlays() -> void:
	get_tree().call_group(&"office_overlays", &"set_map_open", _veiled or not layout.staffed())


func _ease_dim() -> void:
	var to := Color(DIM, DIM, DIM) if _dimmed and layout.id != "city" else Color.WHITE
	if _dim != null:
		_dim.kill()
	_dim = create_tween()
	_dim.tween_property(_container, "self_modulate", to, DIM_S)


func _on_night_skipped() -> void:
	_container.modulate = FADE_DARK
	fade(false, NIGHT_FADE_S)
