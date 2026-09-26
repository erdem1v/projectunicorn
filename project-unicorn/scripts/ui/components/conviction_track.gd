class_name ConvictionTrack
extends VBoxContainer

# İKNA gauge — the single conviction track. Three labeled zones (SOĞUK / ILIK / KAZANILDI),
# an amber fill, subtle dividers at the zone bounds, and a mono readout.
#
# Godot concept: the bar is custom-drawn via the Track control's `draw` signal rather than
# nested ColorRects — one repaint from token colors keeps fill/dividers pixel-exact at any
# column width and re-solves automatically on resize (no manual anchor math).

@onready var _value_label: Label = $TopRow/ValueLabel
@onready var _track: Control = $Track

var _value: int = 0


func _ready() -> void:
	_track.draw.connect(_on_track_draw)


func set_value(value: int) -> void:
	_value = clampi(value, 0, 100)
	_value_label.text = str(_value)
	_track.queue_redraw()


func _on_track_draw() -> void:
	var w: float = _track.size.x
	var h: float = _track.size.y
	_track.draw_rect(Rect2(0.0, 0.0, w, h), UiTokens.CONVICTION_TRACK_BG)
	_track.draw_rect(Rect2(0.0, 0.0, w * _value / 100.0, h), UiTokens.ACCENT)
	for bound in PitchConstants.ZONE_BOUNDS:
		_track.draw_rect(Rect2(w * float(bound) / 100.0, 0.0, 1.0, h), UiTokens.SEPARATOR)
