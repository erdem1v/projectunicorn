class_name RadialDial
extends Control

# The push dial on the term sheet table: the selected lever's chance as an arc over the dial's track, and a
# needle that rests on the arc's edge until a push, then sweeps from the left end and lands where the roll
# fell, inside the arc on a pass and past it on a fail. The needle is ink whatever the roll: the table's
# result line says how it went. Drawn, since Godot has no gauge; a click ends the sweep.

signal spin_finished()

const ARC_POINTS := 64

var _chance := 0.5
var _needle := 0.5    # along the arc, 0 at its left end
var _land := 0.0      # where the sweep under way ends
var _landed := false  # a roll has put the needle where it fell
var _tween: Tween


func _init() -> void:
	custom_minimum_size = UiTokens.D_DIAL
	mouse_filter = Control.MOUSE_FILTER_STOP


## At rest: the needle on the arc's edge.
func set_odds(chance: float) -> void:
	_kill()
	_chance = chance
	_needle = chance
	_landed = false
	queue_redraw()


## After a push: the arc takes the lever's chance now; the needle stays where the roll fell, or is put there
## when the table opened on a roll already made.
func show_result_rest(chance: float, passed: bool) -> void:
	_kill()
	_chance = chance
	if not _landed:
		_needle = _landing(chance, passed)
		_landed = true
	queue_redraw()


## A push rolled at `chance`: the needle sweeps from the arc's left end to where the roll fell.
func spin(chance: float, passed: bool) -> void:
	_kill()
	_chance = chance
	_land = _landing(chance, passed)
	_tween = create_tween()
	_tween.tween_method(_set_needle, 0.0, _land, PitchConstants.DIAL_SPIN_SECS) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.finished.connect(_finish)


func _landing(chance: float, passed: bool) -> float:
	return chance * 0.45 if passed else chance + (1.0 - chance) * 0.55


func _set_needle(v: float) -> void:
	_needle = v
	queue_redraw()


func _finish() -> void:
	_tween = null
	_needle = _land
	_landed = true
	queue_redraw()
	spin_finished.emit()


func _kill() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null


func _draw() -> void:
	var radius: float = UiTokens.D_DIAL_ARC.x
	var stroke: float = UiTokens.D_DIAL_ARC.y
	var hub: float = UiTokens.D_DIAL_NEEDLE.z
	var c := Vector2(size.x * 0.5, UiTokens.D_DIAL.y - hub - UiTokens.BORDER_FOCUS)
	draw_arc(c, radius, PI, TAU, ARC_POINTS, UiTokens.D_BAR_TRACK, stroke, true)
	if _chance > 0.0:
		draw_arc(c, radius, PI, PI + _chance * PI, ARC_POINTS, UiTokens.D_BAR_EMPH, stroke, true)
	var a := PI + clampf(_needle, 0.0, 1.0) * PI
	draw_line(c, c + Vector2(cos(a), sin(a)) * UiTokens.D_DIAL_NEEDLE.x, UiTokens.D_INK_1, UiTokens.D_DIAL_NEEDLE.y, true)
	draw_circle(c, hub, UiTokens.D_INK_1)


func _gui_input(event: InputEvent) -> void:
	if _tween != null and UiFactory.is_left_click(event):
		_kill()
		_finish()
