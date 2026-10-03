class_name OfficeCity
extends Node3D

# The city map for choosing the next office (the design's office-city.js diorama and the page
# around it: openCity, mapAnchors, focusMap, the office card). OfficeView loads it like any
# office; while it is the loaded layout this binds its buildings, draws the chips, the hover
# card and the office card over the view, marks the pick and the current office, and runs the
# traffic. The move button that opens it lives in OfficeHud, mounted here with the first layout.
# In road mode (the founder's trip to a meeting) the map has no controls and takes no input:
# road() plays one way of the trip, the founder's disc riding a dashed road between the company's
# building and the investors' tower, both named by a chip, while the camera pans from one to the
# other; the tower's crown lights as the founder arrives and dims as they leave.

signal road_done   # one way of the trip is over

const HUD := preload("res://scripts/ui/office/office_hud.gd")
const CARD := preload("res://scripts/ui/office/office_map_card.gd")

## openCity: a little wider than the fit and lifted, so the chips over the towers stay in frame.
const OPEN_ZOOM := 0.9
const OPEN_LIFT_PX := 44.0
## focusMap: the picked building, framed at this share of its height and this much closer than
## the map, sits left of centre so the card at the right leaves it in view.
const FOCUS_HEIGHT := 0.35
const FOCUS_ZOOM := 2.1
const FOCUS_SHIFT_PX := 170.0
const FOCUS_TIME := 0.75
## mapAnchors: a chip goes once its anchor is this share of the frame outside it.
const CHIP_SLACK := 0.025
## A chip's gap above its anchor; the current office's clears the pin.
const CHIP_GAP_PX := 10.0
const CHIP_GAP_CURRENT_PX := 48.0
## The pin over the current office: height above the anchor, bob size and rate, spin rate.
const PIN_RISE := 3.4
const PIN_BOB := 0.7
const PIN_BOB_RATE := 2.2
const PIN_SPIN := 1.1
## The ferry's run past the quay: start x, loop length, speed.
const FERRY_START := -94.0
const FERRY_LOOP := 140.0
const FERRY_SPEED := 3.4
const CAR_Y := 0.04
## The water's drift: loop speed along u, sway size and rate along v.
const WATER_DRIFT := 0.004
const WATER_SWAY := 0.01
const WATER_SWAY_RATE := 0.25
## The founder's road (the design's mapPath): a quadratic arc of this many points between the two
## anchors, its middle this far above the higher one; its casing and dashes (width, and dash and
## gap length), px; the founder's disc riding it and the disc's ring, px.
const ROAD_POINTS := 48
const ROAD_RISE := 16.0
const ROAD_CASING_PX := 5.0
const ROAD_DASH_PX := 2.2
const ROAD_DASH_GAP_PX := 7.0
const ROAD_DISC_PX := 46
const ROAD_DISC_RING_PX := 3.0
## One way of the trip, seconds and zooms (x the map's fit): the camera starts on the building
## left at `from_zoom` and pans out over `fit_s`; the road starts `road_at` into the pan and takes
## `road_s`; `to_at` into the road the camera heads for the building reached, at `to_zoom` over
## `to_s`, and the way is done `hold` after that. [WORKING]
const ROAD_OUT := {"from_zoom": 2.6, "fit_s": 1.3, "road_at": 1.1, "road_s": 2.7, "to_at": 1.3,
	"to_zoom": 2.2, "to_s": 1.6, "hold": 1.8}
const ROAD_HOME := {"from_zoom": 2.2, "fit_s": 1.1, "road_at": 0.5, "road_s": 2.5, "to_at": 1.3,
	"to_zoom": 2.3, "to_s": 1.4, "hold": 1.7}

@onready var _scene_root: Node3D = $"../SceneRoot"

var _view: Control
var _overlay: Control
var _hud: HUD
var _layout: OfficeLayout
## The map's overlay controls; null while an office is loaded.
var _map: Control
var _chips: Array[Array] = []     # [hit, chip, gap]
var _hover_card: PanelContainer
var _hover_name: Label
var _hover_line: Label
var _hovered_id := ""
var _hover_frame := -2
var _card: CARD
var _selected := {}
var _frames := {}                 # hit id -> selection frame
var _pin: Node3D
var _pin_hit := {}
var _pin_at := Vector3.ZERO       # the point the pin floats over
var _road_layer: Control          # the road's lines, disc and chips; null when no trip is on
var _road_lines: Array[Line2D] = []   # casing, dashes
var _road_disc: Control
var _road := {}                   # the way under way: {a, b: anchors, t, s: seconds, out}
var _road_token := 0              # a new layout or a new way cancels the waits of the one before
var _cars: Array[Array] = []      # [car, lane]
var _ferry: Node3D
var _water: Array = []            # the map's water materials, drifting on _now
## Wall-clock seconds of traffic; they stand still while the tree is paused. The trip runs it.
var _now := 0.0


func _ready() -> void:
	EventBus.language_changed.connect(_rebuild_controls.unbind(1))
	EventBus.palette_changed.connect(_rebuild_controls.unbind(1))


func set_layout(layout: OfficeLayout, view: Node, water: Array, road := false) -> void:
	_view = view
	_layout = layout
	_water = water
	if _hud == null:
		_overlay = view.get_node("Overlay")
		_hud = HUD.new()
		_hud.move_pressed.connect(open)
		_overlay.add_child(_hud)
	if _map != null:
		_drop_controls()
	_drop_road()
	var is_map := layout.id == "city"
	set_process(is_map)
	if is_map:
		_selected = {}
		_bind_scene()
		_frame_camera()
		if not road:
			_build_controls()


## One way of the founder's trip on the road map: out from the company's building to the
## investors' tower, or home. The chips name the company's office and the tower (`tower_label`);
## road_done says the way is over.
func road(out: bool, tower_label: String) -> void:
	var plan: Dictionary = ROAD_OUT if out else ROAD_HOME
	var ends := [_pin_hit, _layout.meet_hit]
	if not out:
		ends.reverse()
	_build_road(tower_label)
	var token := _road_token
	var cam: OfficeCamera = _view.camera
	# Home, the crown is lit from the start and dims as the founder leaves.
	(_view.lighting as OfficeLighting).crown_glow = 0.0 if out else 1.0
	_focus_on(ends[0].box, 0.0, 0.0, plan.from_zoom)
	cam.focus(cam.fit_target, cam.fit_zoom, plan.fit_s)
	await get_tree().create_timer(plan.road_at).timeout
	if token != _road_token:
		return
	_road = {"a": ends[0].anchor, "b": ends[1].anchor, "t": 0.0, "s": plan.road_s, "out": out}
	await get_tree().create_timer(plan.to_at).timeout
	if token != _road_token:
		return
	_focus_on(ends[1].box, plan.to_s, 0.0, plan.to_zoom)
	await get_tree().create_timer(plan.hold).timeout
	if token == _road_token:
		road_done.emit()


## Picks the building under the pointer, or clears the pick on empty ground.
func pick(screen_pos: Vector2) -> void:
	_select(_hit_at(screen_pos))


## Draws its own hover card (a serif name over a line), so it gives the view no tooltip text.
func hover(screen_pos: Vector2) -> String:
	_hover_frame = Engine.get_process_frames()
	var hit := _hit_at(screen_pos)
	if hit.get("id", "") != _hovered_id:
		_hovered_id = hit.get("id", "")
		if not hit.is_empty():
			var office: Dictionary = OfficeConstants.CATALOG[hit.office]
			_hover_name.text = tr(office.name_key)
			_hover_line.text = tr("OFFICE_HOVER_HOME") if hit.office == "home" \
				else tr("OFFICE_HOVER_LINE").format({"desks": office.desks, "money": UiTokens.format_money(office.rent)})
			_hover_card.reset_size()
	_hover_card.visible = not hit.is_empty()
	if _hover_card.visible:
		_hover_card.position = (screen_pos + Vector2.ONE * UiTokens.SPACE_XL).clamp(Vector2.ZERO, _map.size - _hover_card.size)
	return ""


func is_hovering() -> bool:
	return _map != null and _hover_card.visible


## The map's scene loads on this thread, long enough to see; a frame with the veil is drawn
## first (the frame in flight, then one more) so the wait reads as one.
func open() -> void:
	_hud.set_map_open(true)
	var veil := PanelContainer.new()
	veil.theme_type_variation = &"CardFloating"
	veil.add_child(UiFactory.make_label(tr("OFFICE_MAP_LOADING"), &"RowName"))
	_overlay.add_child(veil)
	veil.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	await get_tree().process_frame
	await get_tree().process_frame
	veil.queue_free()
	_view.load_layout("city")


## Back to the office the company works in; set_layout drops the map's controls.
func close() -> void:
	_view.load_layout(OfficeSystem.current())


## Harness entry: selects an office as a click on its building would.
func debug_pick(office_id: String) -> void:
	for hit: Dictionary in _layout.map_hits:
		if hit.office == office_id:
			_select(hit)


func _process(delta: float) -> void:
	if not get_tree().paused:
		_now += delta
	var cam: OfficeCamera = _view.camera
	var frame := get_viewport().get_visible_rect().size
	var room := Rect2(-frame * CHIP_SLACK, frame * (1.0 + 2.0 * CHIP_SLACK))
	for c: Array in _chips:
		var at := cam.unproject_position(c[0].anchor)
		var chip: Control = c[1]
		chip.visible = room.has_point(at)
		chip.position = at - Vector2(chip.size.x * 0.5, chip.size.y + c[2])
	if not _road.is_empty():
		_step_road(delta)
	if _map != null:
		# The view asks for hover only while the pointer is on the 3D view and no drag runs.
		if Engine.get_process_frames() - _hover_frame > 1:
			_hover_card.hide()
			_hovered_id = ""
	if _pin.visible:
		_pin.position = _pin_at + Vector3.UP * (PIN_RISE + sin(_now * PIN_BOB_RATE) * PIN_BOB)
		_pin.rotation.y = _now * PIN_SPIN
	for c: Array in _cars:
		var lane: Dictionary = c[1]
		var run: Vector2 = lane.b - lane.a
		var at: Vector2 = lane.a + run * (fmod(_now * lane.v + lane.ph, run.length()) / run.length())
		c[0].position = Vector3(at.x, CAR_Y, at.y)
	_ferry.position.x = FERRY_START + fmod(_now * FERRY_SPEED, FERRY_LOOP)
	for m: ShaderMaterial in _water:
		m.set_shader_parameter("uv1_offset", Vector2(fmod(_now * WATER_DRIFT, 1.0), sin(_now * WATER_SWAY_RATE) * WATER_SWAY))


func _bind_scene() -> void:
	var scene := _scene_root.get_child(0)
	_frames.clear()
	_pin_hit = {}
	for hit: Dictionary in _layout.map_hits:
		_frames[hit.id] = scene.find_child("frame_" + hit.id, true, false)
		if hit.office == OfficeSystem.current():
			_pin_hit = hit
	_pin = scene.find_child("pin", true, false)
	_pin.visible = not _pin_hit.is_empty()
	_pin_at = _pin_hit.get("anchor", Vector3.ZERO)
	_cars.clear()
	for lane: Dictionary in _layout.lanes:
		var car: Node3D = scene.find_child(lane.car_node, true, false)
		car.rotation.y = lane.ry
		_cars.append([car, lane])
	_ferry = scene.find_child("ferry", true, false)
	_now = 0.0


## The view has just fitted the map's box; the design then widens and lifts that framing and
## keeps it as the map's own fit.
func _frame_camera() -> void:
	var cam: OfficeCamera = _view.camera
	cam.fit_zoom *= OPEN_ZOOM
	cam.fit_target += cam.global_basis.y * OPEN_LIFT_PX * cam.units_per_px(cam.fit_zoom)
	cam.focus(cam.fit_target, cam.fit_zoom, 0.0)


func _build_controls() -> void:
	_map = Control.new()
	_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_map)
	_map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_chips.clear()
	for hit: Dictionary in _layout.map_hits:
		var name_text: String = tr(OfficeConstants.CATALOG[hit.office].name_key)
		_add_chip(_map, hit, name_text, hit.office == OfficeSystem.current())
	var panel := _make_panel()
	_map.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, UiTokens.SPACE_3XL)
	_hover_card = PanelContainer.new()
	_hover_card.theme_type_variation = &"CardFloating"
	_hover_card.hide()
	_hovered_id = ""
	var col := VBoxContainer.new()
	_hover_card.add_child(col)
	_hover_name = UiFactory.make_label("", &"NameSerif")
	col.add_child(_hover_name)
	_hover_line = UiFactory.make_label("", &"RowMeta")
	col.add_child(_hover_line)
	HRUiShared.set_mouse_ignore(_hover_card)
	_map.add_child(_hover_card)
	_show_card()


## The map's own panel, at the bottom left where an office shows its move button.
func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"CardFloating"
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var col := VBoxContainer.new()
	panel.add_child(col)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(top)
	var title := UiFactory.make_label(tr("OFFICE_MAP_TITLE"), &"NameSerif")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	top.add_child(UiFactory.make_close_button(close))
	col.add_child(UiFactory.make_label(tr("OFFICE_MAP_SUB"), &"RowMeta"))
	return panel


## Language and palette changes redraw the map's text and chips; the pick and the camera stay.
func _rebuild_controls() -> void:
	if _map == null:
		return
	_drop_controls()
	_build_controls()


func _drop_controls() -> void:
	_map.queue_free()
	_map = null
	_card = null
	_chips.clear()


## A chip over `hit`, under `parent`: the current office's amber (its name after the CURRENT
## label), any other a dark pill. The design's dark chip floats over the 3D diorama: a chrome
## surface, not the cream body.
func _add_chip(parent: Control, hit: Dictionary, text: String, current: bool) -> void:
	var chip: PanelContainer
	if current:
		chip = UiFactory.make_pill(tr("OFFICE_CHIP_CURRENT").format({"name": text}), UiTokens.BADGE_BG,
			UiTokens.BADGE_FG, false)
	else:
		chip = UiFactory.make_pill(text, UiTokens.BG_TOPBAR, UiTokens.CREAM, false)
	parent.add_child(chip)
	chip.reset_size()
	_chips.append([hit, chip, CHIP_GAP_CURRENT_PX if current else CHIP_GAP_PX])


func _select(hit: Dictionary) -> void:
	# The flat is never a move target: a click on it, unless the company still lives there, is
	# a click on empty ground.
	if hit.get("office", "") == "home" and OfficeSystem.current() != "home":
		hit = {}
	_selected = hit
	for id: String in _frames:
		_frames[id].visible = id == hit.get("id", "")
	_show_card()
	if hit.is_empty():
		var cam: OfficeCamera = _view.camera
		cam.focus(cam.fit_target, cam.fit_zoom, FOCUS_TIME)
		return
	_focus_on(hit.box, FOCUS_TIME, FOCUS_SHIFT_PX)


## focusMap's framing of a building: a point FOCUS_HEIGHT up its box, `zoom_k` times closer than
## the map, moved `shift_px` left of centre.
func _focus_on(box: AABB, duration: float, shift_px := 0.0, zoom_k := FOCUS_ZOOM) -> void:
	var cam: OfficeCamera = _view.camera
	var to := box.get_center()
	to.y = box.position.y + box.size.y * FOCUS_HEIGHT
	var zoom := cam.fit_zoom * zoom_k
	cam.focus(to + cam.global_basis.x * shift_px * cam.units_per_px(zoom), zoom, duration)


func _show_card() -> void:
	if _card != null:
		_card.queue_free()
		_card = null
	if _selected.is_empty():
		return
	_card = CARD.new(_selected.office)
	_card.cancel_pressed.connect(_select.bind({}))
	_card.move_pressed.connect(_move)
	_map.add_child(_card)
	_hover_card.move_to_front()


func _move() -> void:
	if OfficeSystem.move_to(_selected.office):
		close()
	else:
		# The clock ran on while the card was open: draw it again with today's readings.
		_show_card()


func _hit_at(screen_pos: Vector2) -> Dictionary:
	var cam: OfficeCamera = _view.camera
	var from := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	var best := {}
	var best_d := INF
	for hit: Dictionary in _layout.map_hits:
		var at: Variant = (hit.box as AABB).intersects_ray(from, dir)
		if at != null and from.distance_to(at) < best_d:
			best_d = from.distance_to(at)
			best = hit
	return best


## The road's lines, the founder's disc and the two chips, over the map.
func _build_road(tower_label: String) -> void:
	_drop_road()
	_road_layer = Control.new()
	_road_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_road_layer)
	_road_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var casing := Line2D.new()
	casing.width = ROAD_CASING_PX
	casing.default_color = UiTokens.ROAD_CASING
	var dashes := Line2D.new()
	dashes.width = ROAD_DASH_PX
	# A tiled texel row, dash then gap, scaled to the line's width.
	var texels := maxi(1, roundi(ROAD_DASH_GAP_PX / ROAD_DASH_PX))
	var dash := Image.create_empty(texels * 2, 1, false, Image.FORMAT_RGBA8)
	dash.fill_rect(Rect2i(0, 0, texels, 1), UiTokens.ROAD_DASH)
	dashes.texture = ImageTexture.create_from_image(dash)
	dashes.texture_mode = Line2D.LINE_TEXTURE_TILE
	dashes.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_road_lines.assign([casing, dashes])
	for line: Line2D in _road_lines:
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.antialiased = true
		line.visible = false
		_road_layer.add_child(line)
	var founder: Character = CharacterRegistry.get_founder()
	_road_disc = UiFactory.make_person_avatar(founder.character_name, founder.look, ROAD_DISC_PX)
	# The ring is the disc's last child, drawn over the face.
	var ring := Control.new()
	ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.draw.connect(func() -> void:
		ring.draw_arc(ring.size * 0.5, (ROAD_DISC_PX - ROAD_DISC_RING_PX) * 0.5, 0.0, TAU, 48,
			UiTokens.ACCENT, ROAD_DISC_RING_PX, true))
	_road_disc.add_child(ring)
	_road_disc.visible = false
	_road_layer.add_child(_road_disc)
	_add_chip(_road_layer, _pin_hit, tr(OfficeConstants.CATALOG[_pin_hit.office].name_key), true)
	_add_chip(_road_layer, _layout.meet_hit, tower_label, false)


## The way under way, a frame on: the road drawn through the camera as it is now, the disc eased
## along it, and the tower's crown lit as the founder nears it or dimmed as they leave.
func _step_road(delta: float) -> void:
	_road.t = minf(_road.t + delta, _road.s)
	var u: float = _road.t / _road.s
	var e := ease(u, -2.0)
	var cam: OfficeCamera = _view.camera
	var a: Vector3 = _road.a
	var b: Vector3 = _road.b
	var mid := (a + b) * 0.5
	mid.y = maxf(a.y, b.y) + ROAD_RISE
	var pts := PackedVector2Array()
	for i in ROAD_POINTS:
		var t := float(i) / (ROAD_POINTS - 1)
		pts.append(cam.unproject_position(a.lerp(mid, t).lerp(mid.lerp(b, t), t)))
	for line: Line2D in _road_lines:
		line.points = pts
		line.visible = true
	var f := e * (ROAD_POINTS - 1)
	var i := mini(ROAD_POINTS - 2, floori(f))
	_road_disc.position = pts[i].lerp(pts[i + 1], f - i) - _road_disc.size * 0.5
	_road_disc.visible = true
	(_view.lighting as OfficeLighting).crown_glow = smoothstep(0.5, 1.0, e) if _road.out else 1.0 - smoothstep(0.0, 0.4, e)


func _drop_road() -> void:
	_road_token += 1
	_road = {}
	if _road_layer != null:
		_road_layer.queue_free()
		_road_layer = null
		_road_lines.clear()
		_chips.clear()

