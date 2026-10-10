class_name OfficeCamera
extends Camera3D

# The design's isometric camera (office-sim-v12.js camOff, fitView, onDown/onMove/onUp, onWheel,
# camAnim): orthographic, 35° up and 45° round, FH world units of frame height at zoom 1.
# OfficeView hands it the pointer events of the 3D view.

signal clicked(screen_pos: Vector2)

const FH := 20.0
const DISTANCE := 120.0
const ELEVATION := PI * 35.0 / 180.0
## How far scenery (neighbour roofs, street trees) may rise above the layout box.
const HEIGHT_PAD := 10.0
const DEPTH_MARGIN := 5.0
const CLICK_SLOP := 5.0     # px between press and release that still count as a click
const ZOOM_RANGE := Vector2(0.6, 8.0)   # × fit zoom
## The zoom-out lock of a place, so the frame stays on the scenery built round the office [WORKING]: x is
## the half width in metres of the ground the frame may span at its widest (0: never past the fit), y how far
## in metres the frame's centre on the ground may stand from the fit's once zoomed right in. A place without
## one (the meeting room, which floats over the city) keeps ZOOM_RANGE and free panning.
const LOCKS := {"home": Vector2(41.4, 31.5), "ishani": Vector2(53.6, 31.9), "plaza": Vector2(92.0, 26.0),
	"loft": Vector2(72.9, 43.5), "city": Vector2(0.0, 66.0)}
const WHEEL_STEP := 0.15    # the design's exp(-deltaY * .0015) at a wheel notch of 100

var target := Vector3.ZERO
var zoom := 1.0
var fit_zoom := 1.0
var fit_target := Vector3.ZERO
## The fitted box across the view, in world units, and the zoom that fits it to the view's size
## of the moment: refit scales every zoom by how much that changes.
var _span := Vector2.ONE
var _span_zoom := 1.0

var _offset := Vector3(sin(PI / 4.0) * cos(ELEVATION), sin(ELEVATION), cos(PI / 4.0) * cos(ELEVATION)) * DISTANCE
var _lowest := 0.0
var _highest := 0.0
var _press := Vector2.ZERO
var _last := Vector2.ZERO
var _held := false
var _anim := {}
var _lock := Vector2.ZERO


## Centres the box and zooms until it fills 90% of the frame, as the design's fitView.
## `lowest` is the world y of the scene's lowest geometry, `place` the layout's id in LOCKS.
func fit(bounds: AABB, lowest: float, place := "") -> void:
	_anim = {}
	_lock = LOCKS.get(place, Vector2.ZERO)
	_lowest = lowest
	_highest = bounds.end.y + HEIGHT_PAD
	target = bounds.get_center()
	zoom = 1.0
	_place()
	var to_view := global_transform.affine_inverse()
	var lo := Vector2(INF, INF)
	var hi := -lo
	for i in 8:
		var p := to_view * bounds.get_endpoint(i)
		lo = lo.min(Vector2(p.x, p.y))
		hi = hi.max(Vector2(p.x, p.y))
	target += global_basis.x * (lo.x + hi.x) * 0.5 + global_basis.y * (lo.y + hi.y) * 0.5
	_span = hi - lo
	_span_zoom = _zoom_to_fit()
	fit_zoom = _span_zoom
	zoom = fit_zoom
	fit_target = target
	_place()


## The view changed size: fit, frame and a running ease keep their ratio to the box's fit, so the
## frame keeps its centre and its share of the box.
func refit() -> void:
	var now := _zoom_to_fit()
	var k := now / _span_zoom
	_span_zoom = now
	fit_zoom *= k
	zoom *= k
	if not _anim.is_empty():
		_anim.za *= k
		_anim.zb *= k
	# A wider view spans more ground at the same zoom.
	zoom = maxf(zoom, _floor())
	_place()


func _zoom_to_fit() -> float:
	var view := get_viewport().get_visible_rect().size
	return minf(FH * view.x / view.y / _span.x, FH / _span.y) * 0.9


## The opening frame: the design's snapshot framing (a point on the office floor and a zoom
## over fit_zoom), so the office fills the view instead of the whole block. Empty = keep fit.
func frame(framing: Dictionary) -> void:
	if framing.is_empty():
		return
	var to := fit_target
	if framing.target != null:
		var dq: Vector3 = framing.target - fit_target
		to += global_basis.x * dq.dot(global_basis.x) + global_basis.y * dq.dot(global_basis.y)
	focus(to, fit_zoom * float(framing.zoom), 0.0)


## World units across one pixel of the view at `at_zoom`.
func units_per_px(at_zoom: float) -> float:
	return FH / (at_zoom * get_viewport().get_visible_rect().size.y)


## Eases target and zoom over `duration` seconds (0 jumps), as the design's camAnim.
func focus(to: Vector3, to_zoom: float, duration := 0.75) -> void:
	if duration > 0.0:
		_anim = {"t": 0.0, "dur": duration, "a": target, "b": to, "za": zoom, "zb": to_zoom}
		return
	_anim = {}
	target = to
	zoom = to_zoom
	_place()


func is_dragging() -> bool:
	return _held


func handle_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button:
		match button.button_index:
			MOUSE_BUTTON_LEFT:
				if button.pressed:
					_anim = {}
					_press = button.position
					_last = button.position
					_held = true
				else:
					if _held and button.position.distance_to(_press) < CLICK_SLOP:
						clicked.emit(button.position)
					_held = false
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				if button.pressed:
					var dir := 1.0 if button.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
					_zoom_at(button.position, zoom * exp(dir * WHEEL_STEP * button.factor))
		return
	var motion := event as InputEventMouseMotion
	if motion and _held:
		var step := motion.position - _last
		_last = motion.position
		var units := FH / (zoom * get_viewport().get_visible_rect().size.y)
		var from := target
		target += global_basis.x * (-step.x * units) + global_basis.y * (step.y * units)
		_confine(from, zoom)
		_place()


func _process(delta: float) -> void:
	if _anim.is_empty():
		return
	_anim.t += delta
	var k := minf(1.0, _anim.t / _anim.dur)
	var e := 2.0 * k * k if k < 0.5 else 1.0 - pow(2.0 - 2.0 * k, 2.0) / 2.0
	target = (_anim.a as Vector3).lerp(_anim.b, e)
	zoom = lerpf(_anim.za, _anim.zb, e)
	_place()
	if k >= 1.0:
		_anim = {}


## The point under the cursor stays put while the zoom changes.
func _zoom_at(screen_pos: Vector2, to_zoom: float) -> void:
	_anim = {}
	var view := get_viewport().get_visible_rect().size
	var zn := clampf(to_zoom, _floor(), fit_zoom * ZOOM_RANGE.y)
	var n := screen_pos / view * 2.0 - Vector2.ONE
	var shift := 1.0 / zoom - 1.0 / zn
	var from := target
	var from_zoom := zoom
	target += global_basis.x * (n.x * FH * view.x / view.y * 0.5 * shift) - global_basis.y * (n.y * FH * 0.5 * shift)
	zoom = zn
	_confine(from, from_zoom)
	_place()


## The widest zoom: the lock's ground half width at this view's aspect, between ZOOM_RANGE's and the fit. The
## frame's ground footprint is a rectangle turned 45°, whose square bounds reach
## FH / 2 × (aspect + 1 / sin(ELEVATION)) × √½ metres each way per unit of 1 / zoom.
func _floor() -> float:
	if _lock == Vector2.ZERO:
		return fit_zoom * ZOOM_RANGE.x
	if _lock.x == 0.0:
		return fit_zoom
	var view := get_viewport().get_visible_rect().size
	var reach := FH * 0.5 * (view.x / view.y + 1.0 / sin(ELEVATION)) * sqrt(0.5)
	return clampf(reach / _lock.x, fit_zoom * ZOOM_RANGE.x, fit_zoom)


## How far the frame's ground centre may stand from the fit's at `at_zoom`: nothing at the widest zoom.
func _room(at_zoom: float) -> float:
	return _lock.y * maxf(0.0, 1.0 - _floor() / at_zoom)


## Pulls a drag or a wheel step back so the frame's ground centre stays within the room of the new zoom. A
## frame the game put further out (a focus) may stay where it is, and comes in with the room as it narrows.
func _confine(from: Vector3, from_zoom: float) -> void:
	if _lock == Vector2.ZERO:
		return
	var room := _room(zoom)
	var before := _room(from_zoom)
	var was := _ground_offset(from).length()
	if was > before:
		room = was * room / before if before > 0.0 else maxf(room, was)
	var off := _ground_offset(target)
	var to := off.limit_length(room)
	target += global_basis.x * (to.x - off.x) + global_basis.y * ((to.y - off.y) * sin(ELEVATION))


## Where the frame's centre lands on the ground relative to the fit's: across, and in depth, where one unit
## up the screen covers 1 / sin(ELEVATION) of ground.
func _ground_offset(at: Vector3) -> Vector2:
	var d := at - fit_target
	return Vector2(d.dot(global_basis.x), d.dot(global_basis.y) / sin(ELEVATION))


func _place() -> void:
	look_at_from_position(target + _offset, target, Vector3.UP)
	size = FH / zoom
	# Godot fits an orthographic camera's sun shadow to its whole near..far slab (the light's max
	# distance does not apply), so the slab hugs what the frame can hold: a point at height y seen
	# at frame height v lies y / sin(el) - v / tan(el) nearer than the target.
	var reach := size * 0.5 / tan(ELEVATION)
	near = maxf(0.1, DISTANCE - (_highest - target.y) / sin(ELEVATION) - reach - DEPTH_MARGIN)
	far = DISTANCE + (target.y - _lowest) / sin(ELEVATION) + reach + DEPTH_MARGIN
