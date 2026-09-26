class_name SegmentBar
extends Control

# Dark-register segmented skill bar (onboarding Page 2). One slot per step of the shared
# 0-10 ruler (SKILL_CEILING == HRConstants.AREA_MAX); set_filled takes RULER units, not
# onboarding points. Only the onboarding cap's ruler equivalent is fillable at creation;
# the beyond-cap slots render extra-dim, since the rest of the ruler is reached later
# through founder training.
#
# Custom-drawn rather than one themed Panel per slot: cheaper, crisper, and the slot
# count stays data-driven.

const SLOT_GAP := 4.0
const SLOT_HEIGHT := 6.0
const SEGMENTS := FounderConstants.SKILL_CEILING

var fillable: int = FounderConstants.to_ruler(FounderConstants.ONBOARDING_CAP)
var filled: int = 0


func _init() -> void:
	custom_minimum_size = Vector2(0, SLOT_HEIGHT)


func set_filled(value: int) -> void:
	filled = clampi(value, 0, SEGMENTS)
	queue_redraw()


func _draw() -> void:
	var w: float = (size.x - SLOT_GAP * (SEGMENTS - 1)) / SEGMENTS
	var y: float = (size.y - SLOT_HEIGHT) * 0.5
	for i in SEGMENTS:
		var color: Color = UiTokens.VEIL_FAINT   # ceiling slots — visible, unreachable now
		if i < filled:
			color = UiTokens.ACCENT
		elif i < fillable:
			color = UiTokens.CONVICTION_TRACK_BG
		draw_rect(Rect2(i * (w + SLOT_GAP), y, w, SLOT_HEIGHT), color)
