class_name OfficeCamera
extends Camera3D

# The design's isometric camera (office-sim-v12.js camOff, fitView, onDown/onMove/onUp, onWheel,
# camAnim): orthographic, 35° up and 45° round, FH world units of frame height at zoom 1.
# OfficeView hands it the pointer events of the 3D view.

signal clicked(screen_pos: Vector2)
## An eased focus() reached its frame.
signal focus_done

const FH := 20.0
const DISTANCE := 120.0
const ELEVATION := PI * 35.0 / 180.0
## How far scenery (neighbour roofs, street trees) may rise above the layout box.
const HEIGHT_PAD := 10.0
const DEPTH_MARGIN := 5.0
const CLICK_SLOP := 5.0     # px between press and release that still count as a click
const ZOOM_RANGE := Vector2(0.6, 8.0)   # × fit zoom
const WHEEL_STEP := 0.15    # the design's exp(-deltaY * .0015) at a wheel notch of 100

var target := Vector3.ZERO
var zoom := 1.0
var fit_zoom := 1.0
var fit_target := Vector3.ZERO

var _offset := Vector3(sin(PI / 4.0) * cos(ELEVATION), sin(ELEVATION), cos(PI / 4.0) * cos(ELEVATION)) * DISTANCE
var _lowest := 0.0
var _highest := 0.0
var _press := Vector2.ZERO
var _last := Vector2.ZERO
var _held := false
var _anim := {}


## Centres the box and zooms until it fills 90% of the frame, as the design's fitView.
## `lowest` is the world y of the scene's lowest geometry.
func fit(bounds: AABB, lowest: float) -> void:
	_anim = {}
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
	var view := get_viewport().get_visible_rect().size
	fit_zoom = minf(FH * view.x / view.y / (hi.x - lo.x), FH / (hi.y - lo.y)) * 0.9
	zoom = fit_zoom
	fit_target = target
	_place()


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
		target += global_basis.x * (-step.x * units) + global_basis.y * (step.y * units)
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
		focus_done.emit()


## The point under the cursor stays put while the zoom changes.
func _zoom_at(screen_pos: Vector2, to_zoom: float) -> void:
	_anim = {}
	var view := get_viewport().get_visible_rect().size
	var zn := clampf(to_zoom, fit_zoom * ZOOM_RANGE.x, fit_zoom * ZOOM_RANGE.y)
	var n := screen_pos / view * 2.0 - Vector2.ONE
	var shift := 1.0 / zoom - 1.0 / zn
	target += global_basis.x * (n.x * FH * view.x / view.y * 0.5 * shift) - global_basis.y * (n.y * FH * 0.5 * shift)
	zoom = zn
	_place()


func _place() -> void:
	look_at_from_position(target + _offset, target, Vector3.UP)
	size = FH / zoom
	# Godot fits an orthographic camera's sun shadow to its whole near..far slab (the light's max
	# distance does not apply), so the slab hugs what the frame can hold: a point at height y seen
	# at frame height v lies y / sin(el) - v / tan(el) nearer than the target.
	var reach := size * 0.5 / tan(ELEVATION)
	near = maxf(0.1, DISTANCE - (_highest - target.y) / sin(ELEVATION) - reach - DEPTH_MARGIN)
	far = DISTANCE + (target.y - _lowest) / sin(ELEVATION) + reach + DEPTH_MARGIN
