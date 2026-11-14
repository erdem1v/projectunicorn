extends Control

## A 3D place behind a screen with no run: the office view's world without its people and map, lit at a fixed minute,
## with no clock, input or game state. The plate baked from the same scene stands from the first frame; the scene
## fades in over it once its model has loaded off the main thread. The low graphics preset keeps the plate alone.
## The menu and the onboarding stand on the city, in the menu's warm greys (menu_grade.gdshader), cropped close
## enough that only blocks and streets fill the frame. An office (the plate bake and the backdrop probe) stands at the
## camera's fit with every light on.

signal live_ready

const OFFICE_VIEW := preload("res://scenes/office/OfficeView.tscn")
const GraphicsSettingsLib := preload("res://scripts/systems/graphics_settings.gd")
const GRADE := preload("res://scenes/menu/menu_grade.gdshader")
const MENU_FADE_S := 0.6       # [WORKING] plate to live scene
const MENU_CITY_ZOOM := 2.8    # [WORKING] the city closer than the camera's fit: only blocks and streets fill the frame
const MENU_CITY_FOCUS := Vector2(-0.05, 0.3)   # [WORKING] the frame's centre from the fit's, in frame heights (right, up)
## Scene nodes the menu's city goes without.
const MENU_CITY_HIDDEN := [&"ferry", &"boat_0", &"boat_1", &"boat_2", &"boat_3"]

var _office := ""
var _minute := 0.0
var _model := ""
var _sub: SubViewport
var _camera: OfficeCamera   # set once the live scene stands


func _ready() -> void:
	set_process(false)


## `minute` is the time of day the light stands at; the plate is assets/art/menu/backdrop_<office>_<HHMM>.png.
func start(office_id: String, minute: float) -> void:
	var plate := "res://assets/art/menu/backdrop_%s_%02d%02d.png" % [office_id, floori(minute / 60.0), int(minute) % 60]
	# A place and minute with no plate yet: --menu-shot=bake_plate draws its scene alone.
	if ResourceLoader.exists(plate):
		%Plate.texture = load(plate)
	if GraphicsSettingsLib.shown_preset() == "low":
		return
	_office = office_id
	_minute = minute
	var view: Control = OFFICE_VIEW.instantiate()
	_sub = view.get_node("Viewport3D/SubViewport")
	_sub.get_parent().remove_child(_sub)
	_sub.get_node("World/People").free()
	_sub.get_node("World/City").free()
	view.free()
	%Live.modulate.a = 0.0
	%Live.add_child(_sub)
	_model = "res://art/office3d/%s.glb" % office_id
	ResourceLoader.load_threaded_request(_model)
	set_process(true)


## Frees the live scene now rather than with this node at the frame's end, so the screen mounted next draws its first
## frame without it; the plate stays.
func stop() -> void:
	set_process(false)
	if _sub != null:
		_sub.free()
		_sub = null
		_camera = null


func _process(_delta: float) -> void:
	if ResourceLoader.load_threaded_get_status(_model) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return
	set_process(false)
	var world: Node3D = _sub.get_node("World")
	var scene: Node3D = (ResourceLoader.load_threaded_get(_model) as PackedScene).instantiate()
	world.get_node("SceneRoot").add_child(scene)
	var lowest := INF
	for mi: MeshInstance3D in scene.find_children("*", "MeshInstance3D", true, false):
		lowest = minf(lowest, (mi.global_transform * mi.get_aabb()).position.y)
	var layout := OfficeLayout.load(_office)
	var lighting := OfficeLighting.new(world)
	lighting.set_layout(layout, scene, OfficeMaterials.convert_scene(scene, layout), OfficeMaterials.stations(scene))
	if layout.staffed():
		lighting.anyone_in = true
		for desk in layout.spots.desk.size():
			lighting.set_station_state(desk, true)
	lighting.apply(_minute)
	# Drawn at the screen's logical size, as its plate was baked.
	GraphicsSettingsLib.apply_view(_sub, world, world.get_node("SceneRoot"), GraphicsSettingsLib.options(), 1.0)
	_camera = world.get_node("Camera3D")
	_camera.fit(layout.bounds, lowest, _office)
	if not layout.staffed():
		# The city in the menu's warm greys, without its boats.
		var grade := ShaderMaterial.new()
		grade.shader = GRADE
		grade.set_shader_parameter("tone", UiTokens.D_SURFACE_0)
		%Live.material = grade
		for hidden: StringName in MENU_CITY_HIDDEN:
			scene.find_child(hidden, true, false).visible = false
		_camera.fit_zoom *= MENU_CITY_ZOOM
		var frame_h := OfficeCamera.FH / _camera.fit_zoom
		_camera.focus(_camera.fit_target + (_camera.global_basis.x * MENU_CITY_FOCUS.x
			+ _camera.global_basis.y * MENU_CITY_FOCUS.y) * frame_h, _camera.fit_zoom, 0.0)
	# The view takes the container's size a frame after it joins, and again on every resize.
	_sub.size_changed.connect(_camera.refit)
	create_tween().tween_property(%Live, "modulate:a", 1.0, MENU_FADE_S)
	live_ready.emit()
