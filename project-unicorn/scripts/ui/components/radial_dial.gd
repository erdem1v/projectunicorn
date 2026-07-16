class_name RadialDial
extends Control

# Push-roll dial (Spec 6 §1). A top-semicircle gauge: the green arc = success odds, the red arc
# = the rest, and a needle that rests at the odds boundary, then SWEEPS to a landing on a push
# (green zone = won, red zone = lost). Custom-drawn with draw_arc / draw_line — Godot has no
# radial gauge widget; the ConvictionTrack custom-draw pattern (draw + queue_redraw from token
# colors) is the reference. Self-contained (no .tscn): the % readout Label is built in _ready.
#
# Godot concept: overriding _draw() lets us paint at any size and re-solve on resize (no anchor
# math); a Tween animates the needle via tween_method, and a left click finalizes it (skippable).

signal spin_finished()

var _chance: float = 0.5       # green fraction [0..1]
var _needle_v: float = 0.5     # needle position along the arc [0..1] (0 = left / green end)
var _result: String = ""       # "" | "success" | "failure" — colours the needle + readout
var _readout: Label
var _tween: Tween = null


func _ready() -> void:
	custom_minimum_size = Vector2(0, 172)
	mouse_filter = Control.MOUSE_FILTER_STOP   # catch clicks to skip the spin
	_readout = Label.new()
	_readout.name = "Readout"
	_readout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_readout.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_readout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_readout.theme_type_variation = &"ConvictionValue"
	add_child(_readout)
	resized.connect(queue_redraw)
	_sync_readout()


## Rest state — needle at the odds boundary, no landed result (S1/S2).
func set_odds(chance: float) -> void:
	_kill_tween()
	_chance = clampf(chance, 0.0, 1.0)
	_result = ""
	_needle_v = _chance
	_sync_readout()
	queue_redraw()


## Post-push rest — keep the needle where the spin landed, recolour the arc to the new odds,
## keep the green/red result tint. Used by the scene's _render after a spin settles (S4/S5/S6).
func show_result_rest(chance: float, passed: bool) -> void:
	_kill_tween()
	_chance = clampf(chance, 0.0, 1.0)
	_result = "success" if passed else "failure"
	_sync_readout()
	queue_redraw()


## Animate a push: sweep the needle from the green end and land it in green (won) or red (lost).
func spin(chance: float, passed: bool) -> void:
	_kill_tween()
	_chance = clampf(chance, 0.0, 1.0)
	_result = "success" if passed else "failure"
	_needle_v = 0.0
	_sync_readout()
	queue_redraw()
	_tween = create_tween()
	_tween.tween_method(_set_needle, 0.0, _land_v(), PitchConstants.DIAL_SPIN_SECS) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.finished.connect(func() -> void: spin_finished.emit())


## Click-to-finalize the current spin (skippable, §3).
func skip() -> void:
	if _tween != null and _tween.is_valid() and _tween.is_running():
		_tween.kill()
		_tween = null
		_needle_v = _land_v()
		queue_redraw()
		spin_finished.emit()


func _land_v() -> float:
	# Needle lands well inside the green zone on a win, the red zone on a loss.
	return _chance * 0.45 if _result == "success" else _chance + (1.0 - _chance) * 0.55


func _set_needle(v: float) -> void:
	_needle_v = v
	queue_redraw()


func _kill_tween() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null


func _sync_readout() -> void:
	if _readout == null:
		return
	_readout.text = "%%%d" % int(round(_chance * 100.0))
	_readout.add_theme_color_override("font_color", _needle_color())


func _needle_color() -> Color:
	match _result:
		"success": return UiTokens.POSITIVE_BRIGHT
		"failure": return UiTokens.NEGATIVE_BRIGHT
		_: return UiTokens.ACCENT


func _draw() -> void:
	var c: Vector2 = Vector2(size.x * 0.5, size.y * 0.84)
	var r: float = minf(size.x * 0.44, size.y * 0.78)
	if r <= 1.0:
		return
	var w: float = maxf(r * 0.15, 7.0)
	var boundary: float = PI + _chance * PI          # top semicircle: PI (left) → TAU (right)
	draw_arc(c, r, PI, boundary, 40, UiTokens.POSITIVE_BRIGHT, w, true)
	draw_arc(c, r, boundary, TAU, 40, UiTokens.NEGATIVE_BRIGHT, w, true)
	var na: float = PI + clampf(_needle_v, 0.0, 1.0) * PI
	var tip: Vector2 = c + Vector2(cos(na), sin(na)) * (r - w * 0.15)
	draw_line(c, tip, _needle_color(), maxf(r * 0.045, 3.0), true)
	draw_circle(c, maxf(r * 0.08, 5.0), _needle_color())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		skip()
