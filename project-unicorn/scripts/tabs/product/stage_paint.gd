class_name StagePaint
extends Control

# Sprint ekranının çizilen izleri: StyleBox'ın çizemediği şeritler, kesikli ve noktalı çizgiler, taramalar ve çubuklar. Renk ve ölçü
# UiTokens'tan gelir; yerleşim sahibi spec'i ve boyutu verir. Panoda her öğe kendi Control'üdür (`part`): üstüne gelinen yer ve
# ipucu o öğeye bağlanır, çizim ortak.
#   groove  Kapasite bölümünde bir aşamanın oluğu: `spec` {work, groove, done, outer, inner, ghost, scale, shared, empty},
#           hepsi efor; `scale` tam genişliğin eforudur. Oluğun çerçevesi kalın bir çizgiyle biter (aşamaları yalnız kurucu
#           paylaşıyorsa kesikli), dolgu aşamanın eforudur, `done` onun koyu önüdür, taşma şeritlidir (`outer` oluğun ötesinde,
#           `inner` içinde), `ghost` adayın eforu dolgunun ardından kesiklidir, boş aşama (`empty`) kesikli bir çizgidir.
#   busy    Kişinin yüzünün altındaki yük: `spec` {busy, cut} 0..1, `cut` görüşmelerin haftadan aldığı pay.
#   bracket Oluklardan solda üç satırın ayracı: `spec` {x, top, bottom}.
#   grid    Panonun zaman ekseni zemini: `spec` {px (hafta başına piksel), weeks (sprintin haftası)}; hafta ayracı, sprint sonu
#           çizgisi ve sonraki sprintin çizgili zemini.
#   now     Şimdiki an çizgisi ve tepesindeki üçgen; `spec` {}.
#   early   Erken kapanışın taralı alanı ve kesikli sol kenarı; `spec` {}.
#   bar     Bir aşamanın çubuğunun zemini ve kenarı: `spec` {state plan | run | done | wait | out | ghost, late, fill (0..1)}.
#           Tik kutuları, tarama ve `label` onun çocuğudur, üstüne bu sırayla çizilir.
#   label   Çubuğun içeriği: `spec` {state, late, icon (ikon yolu), main, sub, left (içeriğin başladığı yer), room (sağda yüzlere
#           ayrılan genişlik)}. Sığmayan yerde önce ikon sonra sayı düşer; biten aşamada sayının yerini tik tutar.
#   wait    Aşamanın hazır olduğu andan başladığı ana noktalı çizgi.
#   shadow  PM'in kısalttığı payın çubuğun altındaki gölgesi.
#   meet    Kurucunun görüşme günlerinin çubuk içindeki taraması.
#   tick    Önden bitmiş aşamanın tik kutusu (çubuğa takılamadığında tek başına).
#   risk    Kartın hata riski: `spec` {now, raw} 0..1; `raw` hazırlanmamış hâlinin taralı payı.
#   ask     Kartta bekleyen sorunun "?" işareti: halkalı yuvarlak zemin ve ortasında soru işareti; `spec` {}.
#   fade    Panonun altında "aşağıda {n} kart daha" hapının arkasında sütunun zeminine solan geçiş.

const CHECK := preload("res://assets/icons/util/check.svg")

static var _icons: Dictionary = {}

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


static func risk(now: float, raw: float) -> StagePaint:
	var paint := StagePaint.new()
	paint.kind = &"risk"
	paint.spec = {"now": now, "raw": raw}
	paint.custom_minimum_size = Vector2(UiTokens.D_RISK_BAR)
	paint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	paint.mouse_filter = Control.MOUSE_FILTER_PASS
	return paint


static func bracket(bracket_spec: Dictionary) -> StagePaint:
	var paint := StagePaint.new()
	paint.kind = &"bracket"
	paint.spec = bracket_spec
	paint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return paint


## Panonun bir öğesi `rect`te: zeminin ve şimdiki an çizgisinin üstüne gelinmez, öbürleri ipucu alır.
static func part(part_kind: StringName, stage_id: String, part_spec: Dictionary, rect: Rect2) -> StagePaint:
	var paint := StagePaint.new()
	paint.kind = part_kind
	paint.stage = stage_id
	paint.spec = part_spec
	paint.position = rect.position
	paint.size = rect.size
	paint.mouse_filter = Control.MOUSE_FILTER_IGNORE if part_kind in [&"grid", &"now", &"label", &"fade"] else Control.MOUSE_FILTER_PASS
	return paint


## `text` `variation`ın yazı yüzüyle (varsayılan çubuğun sayısı) ne kadar yer tutar: yerleşim ağaca girmeden hesaplanır.
static func text_width(text: String, variation := &"StageNum") -> float:
	var theme: Theme = load(UiTokens.MENAJER_THEME)
	return theme.get_font(&"font", variation).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, theme.get_font_size(&"font_size", variation)).x


## Çubuğun durumunu, yazısını ve dolgusunu değiştirir (saat ilerleyince); yeniden çizer.
func set_bar(bar_spec: Dictionary) -> void:
	spec.merge(bar_spec, true)
	queue_redraw()


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
		&"grid":
			_draw_grid()
		&"now":
			var mid: float = size.x / 2.0
			draw_rect(Rect2(mid - UiTokens.BORDER_FOCUS / 2.0, 0.0, UiTokens.BORDER_FOCUS, size.y), UiTokens.D_ACCENT)
			draw_colored_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0.0), Vector2(mid, UiTokens.D_NOW_HEAD.y)]),
				UiTokens.D_ACCENT)
		&"early":
			_hatch(Rect2(Vector2.ZERO, size), Color.TRANSPARENT, UiTokens.D_EARLY_STRIPE, UiTokens.D_EARLY_PERIOD)
			draw_dashed_line(Vector2(UiTokens.BORDER_FOCUS / 2.0, 0.0), Vector2(UiTokens.BORDER_FOCUS / 2.0, size.y),
				UiTokens.D_INK_3, UiTokens.BORDER_FOCUS, UiTokens.SPACE_XS)
		&"bar":
			_draw_bar()
		&"label":
			_draw_label()
		&"wait":
			_draw_wait()
		&"shadow":
			draw_rect(Rect2(Vector2.ZERO, size), Color(UiTokens.D_stage(stage), UiTokens.D_SHADOW_ALPHA))
			draw_rect(Rect2(0.0, size.y - UiTokens.BORDER_HAIRLINE, size.x, UiTokens.BORDER_HAIRLINE),
				Color(UiTokens.D_stage(stage), UiTokens.D_SHADOW_FOOT_ALPHA))
		&"meet":
			_hatch(Rect2(Vector2.ZERO, size), UiTokens.D_MEET_DARK, UiTokens.D_MEET_LIGHT, UiTokens.D_MEET_PERIOD)
			draw_rect(Rect2(Vector2.ZERO, size).grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.D_MEET_EDGE, false, UiTokens.BORDER_HAIRLINE)
		&"tick":
			_draw_tick(Rect2(Vector2.ZERO, size), stage)
		&"risk":
			_draw_risk()
		&"ask":
			_draw_ask()
		&"fade":
			draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)]),
				PackedColorArray([Color(UiTokens.D_SURFACE_2, 0.0), Color(UiTokens.D_SURFACE_2, 0.0), UiTokens.D_SURFACE_2, UiTokens.D_SURFACE_2]))


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
		_spill(Rect2(fill.end.x - spec.inner * per, inset, spec.inner * per, fill.size.y))
	if spec.outer > 0.0:
		var spill := Rect2(edge, 0, spec.outer * per, h)
		_spill(spill)
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


## Sprint dışına kalan payın taramalı alanı: turuncu zemin ve çapraz turuncu şeritler.
func _spill(area: Rect2) -> void:
	_hatch(area, UiTokens.D_hatch_base(), UiTokens.D_warn(), UiTokens.D_HATCH)


## `area` içinde, `base` zeminin üstüne `period` (x: aralık, y: kalınlık) çapraz şeritler.
func _hatch(area: Rect2, base: Color, stripe: Color, period: Vector2) -> void:
	if base.a > 0.0:
		draw_rect(area, base)
	var rise: float = area.size.y
	var x: float = area.position.x - rise
	while x < area.end.x:
		var from_t: float = clampf((area.position.x - x) / rise, 0.0, 1.0)
		var to_t: float = clampf((area.end.x - x) / rise, 0.0, 1.0)
		if to_t > from_t:
			draw_line(Vector2(x + from_t * rise, area.end.y - from_t * rise), Vector2(x + to_t * rise, area.end.y - to_t * rise),
				stripe, period.y)
		x += period.x


func _draw_busy() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UiTokens.D_LINE_1)
	draw_rect(Rect2(0, 0, size.x * spec.busy, size.y), UiTokens.D_stage(stage))
	var x: float = size.x * (1.0 - spec.cut)
	while x < size.x:
		draw_rect(Rect2(x, 0, UiTokens.BORDER_HAIRLINE, size.y), UiTokens.D_INK_4)
		x += UiTokens.SPACE_XXS


func _draw_grid() -> void:
	var per: float = spec.px
	var end: float = per * spec.weeks
	for week in range(1, int(spec.weeks)):
		draw_rect(Rect2(per * week, 0.0, UiTokens.BORDER_HAIRLINE, size.y), UiTokens.D_LINE_1)
	var x: float = end + UiTokens.D_SPILL_STEP - UiTokens.BORDER_HAIRLINE
	while x < size.x:
		draw_rect(Rect2(x, 0.0, UiTokens.BORDER_HAIRLINE, size.y), UiTokens.D_SPILL_LINE)
		x += UiTokens.D_SPILL_STEP
	draw_rect(Rect2(end, 0.0, UiTokens.BORDER_FOCUS, size.y), UiTokens.D_LINE_3)


## Bekleme: noktalı çizgi ve sonunda küçük bir dik çentik.
func _draw_wait() -> void:
	var mid: float = size.y / 2.0
	var x := 0.0
	while x < size.x:
		draw_rect(Rect2(x, mid - UiTokens.BORDER_FOCUS / 2.0, UiTokens.BORDER_FOCUS, UiTokens.BORDER_FOCUS), UiTokens.D_INK_4)
		x += UiTokens.SPACE_XS
	draw_rect(Rect2(size.x - UiTokens.BORDER_HAIRLINE, mid - UiTokens.SPACE_S + 1.0, UiTokens.BORDER_FOCUS, UiTokens.SPACE_M),
		UiTokens.D_INK_4)


func _draw_risk() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UiTokens.D_SURFACE_4)
	if spec.raw > spec.now:
		var raw_end: float = size.x * spec.raw
		var x := 0.0
		while x < raw_end:
			draw_rect(Rect2(x, 0.0, UiTokens.BORDER_HAIRLINE, size.y), UiTokens.D_RISK_RAW)
			x += UiTokens.SPACE_XXS + UiTokens.BORDER_HAIRLINE
	draw_rect(Rect2(0.0, 0.0, size.x * spec.now, size.y), UiTokens.D_INK_3)
	draw_rect(Rect2(Vector2.ZERO, size).grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.D_LINE_2, false, UiTokens.BORDER_HAIRLINE)


func _draw_ask() -> void:
	var r: float = size.x / 2.0
	draw_circle(Vector2(r, r), r, UiTokens.D_SURFACE_3)
	draw_circle(Vector2(r, r), r - UiTokens.BORDER_FOCUS, UiTokens.D_INK_1)
	var font: Font = get_theme_font(&"font", &"StageNum")
	var px: int = UiTokens.D_FS_12
	var wide: float = font.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	draw_string(font, Vector2((size.x - wide) / 2.0, (size.y + font.get_ascent(px) - font.get_descent(px)) / 2.0), "?",
		HORIZONTAL_ALIGNMENT_LEFT, -1, px, UiTokens.D_SURFACE_1)


func _draw_tick(box: Rect2, stage_id: String) -> void:
	draw_rect(box, UiTokens.D_stage(stage_id))
	var glyph: float = UiTokens.D_ICON_TAG
	draw_texture_rect(CHECK, Rect2(box.position + (box.size - Vector2.ONE * glyph) / 2.0, Vector2.ONE * glyph), false, UiTokens.D_SURFACE_1)


## Çubuk: zemini ve kenarı durumundan; planda ve koşarken önden yapılmış ya da yapılan iş çubuğun başında dolu.
func _draw_bar() -> void:
	var state: String = spec.state
	var box := Rect2(Vector2.ZERO, size)
	var late: bool = spec.late
	var edge := Color.TRANSPARENT
	match state:
		"plan", "run":
			draw_rect(box, UiTokens.D_SURFACE_3.lerp(UiTokens.D_neg(), UiTokens.D_STAGE_BAR_MIX.late) if late
				else UiTokens.D_stage_bar(stage, "plan" if state == "plan" else "run"))
			if spec.fill > 0.0:
				draw_rect(Rect2(0.0, 0.0, size.x * spec.fill, size.y), UiTokens.D_stage_bar(stage, "done_share"))
			edge = UiTokens.D_neg() if late else UiTokens.D_stage_bar_edge(stage, "plan")
		"done":
			draw_rect(box, UiTokens.D_neg() if late else UiTokens.D_stage_bar(stage, "done"))
		"wait":
			edge = UiTokens.D_neg() if late else UiTokens.D_stage_bar_edge(stage, "wait")
		"out":
			_spill(box)
			edge = UiTokens.D_neg() if late else UiTokens.D_warn()
		"ghost":
			var dash: float = UiTokens.D_HATCH.y
			for side in [[box.position, Vector2(box.end.x, 0.0)], [Vector2(0.0, box.end.y), box.end], [box.position, Vector2(0.0, box.end.y)],
					[Vector2(box.end.x, 0.0), box.end]]:
				draw_dashed_line(side[0], side[1], Color(UiTokens.D_stage(stage), UiTokens.D_STAGE_BAR_EDGE.ghost), UiTokens.BORDER_FOCUS, dash)
	if edge.a > 0.0:
		var width: float = UiTokens.BORDER_FOCUS if state == "out" or late else UiTokens.BORDER_HAIRLINE
		draw_rect(box.grow(-width / 2.0), edge, false, width)


## Çubuğun ikonu ve sayısı: ikon ve sayı sığarsa ikisi, yalnız sayı sığarsa sayı (yüz ya da tik yoksa ortada), yoksa hiçbiri.
func _draw_label() -> void:
	var state: String = spec.state
	var late: bool = spec.late
	var done: bool = state == "done"
	var ink: Color = UiTokens.D_SURFACE_1 if done else UiTokens.D_INK_1
	var glyph_ink: Color = ink if done else UiTokens.D_warn() if state == "out" else UiTokens.D_neg_ink() if late else UiTokens.D_stage(stage)
	var font: Font = get_theme_font(&"font", &"StageNum")
	var px: int = get_theme_font_size(&"font_size", &"StageNum")
	var main: String = spec.main
	var sub: String = spec.sub
	var glyph: float = UiTokens.D_ICON_TAG
	var body_w: float = glyph if done else font.get_string_size(main + sub, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	var left: float = spec.left
	var right: float = size.x - UiTokens.D_STAGE_BAR_PAD.y - spec.room
	var at: float = left
	if left + glyph + UiTokens.SPACE_S + body_w <= right:
		draw_texture_rect(_icon(spec.icon), Rect2(left, (size.y - glyph) / 2.0, glyph, glyph), false, glyph_ink)
		at = left + glyph + UiTokens.SPACE_S
	elif left == UiTokens.D_STAGE_BAR_PAD.x and spec.room <= 0.0 and body_w + 2.0 * UiTokens.SPACE_XS <= size.x:
		at = (size.x - body_w) / 2.0
	elif left + body_w > right:
		return
	if done:
		draw_texture_rect(CHECK, Rect2(at, (size.y - glyph) / 2.0, glyph, glyph), false, ink)
		return
	var baseline: float = (size.y + font.get_ascent(px) - font.get_descent(px)) / 2.0
	draw_string(font, Vector2(at, baseline), main, HORIZONTAL_ALIGNMENT_LEFT, -1, px, ink)
	if sub != "":
		draw_string(font, Vector2(at + font.get_string_size(main, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x, baseline), sub,
			HORIZONTAL_ALIGNMENT_LEFT, -1, px, UiTokens.D_INK_4)


static func _icon(path: String) -> Texture2D:
	if not _icons.has(path):
		_icons[path] = load(path)
	return _icons[path]
