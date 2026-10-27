class_name StagePaint
extends Control

# Sprint ekranının çizilen izleri: StyleBox'ın çizemediği şeritler, kesikli çizgiler ve üç satırı saran ayraç. Renk ve ölçü
# UiTokens'tan gelir; yerleşim sahibi spec'i ve boyutu verir.
#   groove  Kapasite bölümünde bir aşamanın oluğu: `spec` {work, groove, done, outer, inner, ghost, scale, shared, empty},
#           hepsi efor; `scale` tam genişliğin eforudur. Oluğun çerçevesi kalın bir çizgiyle biter (aşamaları yalnız kurucu
#           paylaşıyorsa kesikli), dolgu aşamanın eforudur, `done` onun koyu önüdür, taşma şeritlidir (`outer` oluğun ötesinde,
#           `inner` içinde), `ghost` adayın eforu dolgunun ardından kesiklidir, boş aşama (`empty`) kesikli bir çizgidir.
#   busy    Kişinin yüzünün altındaki yük: `spec` {busy, cut} 0..1, `cut` görüşmelerin haftadan aldığı pay.
#   bracket Oluklardan solda üç satırın ayracı: `spec` {x, top, bottom}.

var kind: StringName
var stage := ""
var spec: Dictionary = {}


static func groove(stage_id: String, groove_spec: Dictionary) -> StagePaint:
	var paint := StagePaint.new()
	paint.kind = &"groove"
	paint.stage = stage_id
	paint.spec = groove_spec
	paint.custom_minimum_size.y = UiTokens.D_H_CAP_TRACK
	paint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return paint


static func busy(stage_id: String, share: float, cut: float) -> StagePaint:
	var paint := StagePaint.new()
	paint.kind = &"busy"
	paint.stage = stage_id
	paint.spec = {"busy": share, "cut": cut}
	paint.custom_minimum_size = Vector2(UiTokens.D_BUSY_BAR)
	paint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return paint


static func bracket(bracket_spec: Dictionary) -> StagePaint:
	var paint := StagePaint.new()
	paint.kind = &"bracket"
	paint.spec = bracket_spec
	paint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return paint


func _draw() -> void:
	match kind:
		&"groove":
			_draw_groove()
		&"busy":
			_draw_busy()
		&"bracket":
			draw_polyline(PackedVector2Array([Vector2(spec.x + UiTokens.SPACE_M, spec.top), Vector2(spec.x, spec.top),
				Vector2(spec.x, spec.bottom), Vector2(spec.x + UiTokens.SPACE_M, spec.bottom)]), UiTokens.D_INK_3,
				UiTokens.BORDER_FOCUS)


func _draw_groove() -> void:
	var h: float = size.y
	var inset: float = UiTokens.D_CAP_FILL_INSET
	if spec.empty:
		draw_dashed_line(Vector2(0, h / 2.0), Vector2(size.x, h / 2.0), UiTokens.D_LINE_2, UiTokens.BORDER_FOCUS,
			UiTokens.SPACE_S)
		return
	var per: float = size.x / spec.scale
	var work: float = spec.work * per
	var edge: float = spec.groove * per
	var fill := Rect2(0, inset, minf(work, edge), h - 2.0 * inset)
	draw_rect(fill, UiTokens.D_stage_fill(stage))
	draw_rect(Rect2(0, inset, minf(spec.done * per, edge), fill.size.y), UiTokens.D_stage(stage))
	if spec.inner > 0.0:
		_hatch(Rect2(fill.end.x - spec.inner * per, inset, spec.inner * per, fill.size.y))
	if spec.outer > 0.0:
		var spill := Rect2(edge, 0, spec.outer * per, h)
		_hatch(spill)
		draw_rect(spill.grow(-UiTokens.BORDER_FOCUS / 2.0), UiTokens.D_warn(), false, UiTokens.BORDER_FOCUS)
	if spec.ghost > 0.0:
		var ghost := Rect2(work, inset, spec.ghost * per, fill.size.y)
		draw_rect(ghost, UiTokens.D_stage_ghost(stage))
		var dash := UiTokens.D_HATCH.y
		for side in [[ghost.position, Vector2(ghost.end.x, ghost.position.y)], [Vector2(ghost.position.x, ghost.end.y), ghost.end]]:
			draw_dashed_line(side[0], side[1], UiTokens.D_INK_2, UiTokens.BORDER_FOCUS, dash)
	draw_rect(Rect2(0, 0, edge, h).grow(-UiTokens.BORDER_FOCUS / 2.0), UiTokens.D_stage_edge(stage), false, UiTokens.BORDER_FOCUS)
	var cap: float = UiTokens.BORDER_ACCENT
	if spec.shared:
		draw_dashed_line(Vector2(edge - cap / 2.0, 0), Vector2(edge - cap / 2.0, h), UiTokens.D_INK_3, cap, UiTokens.SPACE_XS)
	else:
		draw_rect(Rect2(edge - cap, 0, cap, h), UiTokens.D_INK_2)


## `area` içinde, zeminin üstüne çapraz şeritler.
func _hatch(area: Rect2) -> void:
	draw_rect(area, UiTokens.D_hatch_base())
	var rise: float = area.size.y
	var x: float = area.position.x - rise
	while x < area.end.x:
		var from_t: float = clampf((area.position.x - x) / rise, 0.0, 1.0)
		var to_t: float = clampf((area.end.x - x) / rise, 0.0, 1.0)
		if to_t > from_t:
			draw_line(Vector2(x + from_t * rise, area.end.y - from_t * rise), Vector2(x + to_t * rise, area.end.y - to_t * rise),
				UiTokens.D_warn(), UiTokens.D_HATCH.y)
		x += UiTokens.D_HATCH.x


func _draw_busy() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UiTokens.D_LINE_1)
	draw_rect(Rect2(0, 0, size.x * spec.busy, size.y), UiTokens.D_stage(stage))
	var x: float = size.x * (1.0 - spec.cut)
	while x < size.x:
		draw_rect(Rect2(x, 0, UiTokens.BORDER_HAIRLINE, size.y), UiTokens.D_INK_4)
		x += UiTokens.SPACE_XXS
