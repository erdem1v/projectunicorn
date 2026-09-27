extends Control

# The office behind the windows: the design's 3D scene (tools/office3d) on the game clock. Loads
# the current office and swaps it on office_changed, drives its light every frame, and routes the
# pointer: drag and wheel move the camera, clicks and hover go to the people, or to the city map
# while that is the loaded layout. Windows are later siblings, so they take the pointer first.

@onready var _container: SubViewportContainer = $Viewport3D
@onready var camera: OfficeCamera = $Viewport3D/SubViewport/World/Camera3D
@onready var _scene_root: Node3D = $Viewport3D/SubViewport/World/SceneRoot
@onready var _people: OfficePeople = $Viewport3D/SubViewport/World/People
@onready var _city: OfficeCity = $Viewport3D/SubViewport/World/City
@onready var _tooltip: PanelContainer = $Overlay/Tooltip
@onready var _tooltip_label: Label = $Overlay/Tooltip/Label

var layout: OfficeLayout
var lighting: OfficeLighting
var _lowest := 0.0
var _fitted := false
var _pointer_inside := false


func _ready() -> void:
	lighting = OfficeLighting.new($Viewport3D/SubViewport/World)
	_container.gui_input.connect(camera.handle_input)
	_container.mouse_entered.connect(func() -> void: _pointer_inside = true)
	_container.mouse_exited.connect(_on_pointer_left)
	# Deferred: the container says it resized before it resizes the SubViewport the camera fits to.
	_container.resized.connect(_fit_once, CONNECT_DEFERRED)
	camera.clicked.connect(_on_clicked)
	EventBus.office_changed.connect(load_layout)
	load_layout(OfficeSystem.current())


## Loads an office (or "city", the map) in place of the one on screen.
func load_layout(office_id: String) -> void:
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
	_fit_once()
	_people.set_layout(layout, self)
	_city.set_layout(layout, self, materials.get("water", []))
	# The map brings its own corners: the controls over the office step aside while it is open.
	get_tree().call_group(&"office_overlays", &"set_map_open", office_id == "city")


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


## The first time the view has a size, frame the office; later resizes keep the camera.
func _fit_once() -> void:
	if _fitted or _container.size.x < 1.0 or _container.size.y < 1.0:
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
