class_name SegmentBar
extends Control

# Dark-register segmented skill bar (onboarding Page 2). Five slots — the true
# SKILL_CEILING — of which only ONBOARDING_CAP are fillable at creation: the
# beyond-cap slots render extra-dim, silently documenting the growth arc (4-5
# reachable later via HR founder training) without building that system.
#
# Godot concept: a custom-drawn Control. _draw() paints with the CanvasItem draw
# API; queue_redraw() invalidates after a state change. Cheaper and crisper than
# stacking themed Panels per slot, and the slot count stays data-driven.

const SLOT_GAP := 4.0
const SLOT_HEIGHT := 6.0

var segments: int = FounderConstants.SKILL_CEILING
var fillable: int = FounderConstants.ONBOARDING_CAP
var filled: int = 0


func _init() -> void:
	custom_minimum_size = Vector2(0, SLOT_HEIGHT)


func set_filled(value: int) -> void:
	filled = clampi(value, 0, segments)
	queue_redraw()


func _draw() -> void:
	if segments <= 0:
		return
	var w: float = (size.x - SLOT_GAP * (segments - 1)) / segments
	var y: float = (size.y - SLOT_HEIGHT) * 0.5
	for i in segments:
		var color: Color
		if i < filled:
			color = UiTokens.ACCENT
		elif i < fillable:
			color = UiTokens.CONVICTION_TRACK_BG
		else:
			color = Color(1, 1, 1, 0.03)   # ceiling slots — visible, unreachable now
		draw_rect(Rect2(i * (w + SLOT_GAP), y, w, SLOT_HEIGHT), color)
