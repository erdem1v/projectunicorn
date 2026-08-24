class_name SegmentBar
extends Control

# Dark-register segmented skill bar (onboarding Page 2). ON slot — the shared 0-10
# ruler (SKILL_CEILING == HRConstants.AREA_MAX) — of which only the onboarding cap's
# RULER equivalent is fillable at creation: the beyond-cap slots render extra-dim,
# silently documenting the growth arc (the rest reachable later via HR founder
# training) without building that system.
#
# CETVEL BIRIMI, DAGITIM BIRIMI DEGIL (2026-08-24). Cubuk 5 yuvadan 10'a cikti cunku
# kurucu artik calisanla ayni cetvelde (GDD rev 11 §2.4 + §4.1). Dagitim birimi
# degismedi: oyuncu hala POINT_POOL kadar puani ONBOARDING_CAP tavaniyla dagitiyor ve
# yanindaki +/- sayaci o puani sayiyor. Cubuk o dagitimin CETVEL karsiligini cizer
# (FounderConstants.to_ruler) — yoksa 3 puan harcamis bir oyuncu 10 yuvanin 3'unu dolu
# gorur ve dogacak kurucunun 6/10 tasidigini hicbir yerde okuyamazdi.
#
# Godot concept: a custom-drawn Control. _draw() paints with the CanvasItem draw
# API; queue_redraw() invalidates after a state change. Cheaper and crisper than
# stacking themed Panels per slot, and the slot count stays data-driven.

const SLOT_GAP := 4.0
const SLOT_HEIGHT := 6.0

var segments: int = FounderConstants.SKILL_CEILING
var fillable: int = FounderConstants.to_ruler(FounderConstants.ONBOARDING_CAP)
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
			color = UiTokens.VEIL_FAINT   # ceiling slots — visible, unreachable now
		draw_rect(Rect2(i * (w + SLOT_GAP), y, w, SLOT_HEIGHT), color)
