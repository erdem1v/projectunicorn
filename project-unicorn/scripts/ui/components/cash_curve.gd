class_name CashCurve
extends Control

# ============================================================================
# Nakit eğrisi. Gerçekleşen kasa çizgisi, altında açık alan, sıfırın altında tehlike alanı; bugünden iki kesikli
# projeksiyon: "mevcut gidiş" (bugünkü net, yalnız kasa eriyorken) ve "satış hedefi tutarsa" (pipeline-ağırlıklı
# iyimser net, ufukta ötekinden ayrı okunduğunda). Alan seçilen aralığı izler: bugünden pencere kadar geri, ufka
# kadar ileri; koşudan önceki haftalar boş geçmiştir. Bugünün ve kasanın sıfıra indiği ilk haftanın çizgileri
# adıyla, üstüne gelinen haftanın kasası kendi notunda. Ekonomi burada HESAPLANMAZ: set_data'ya gelen her sayı
# bir motor seam'inden çıkar, bu dosya yalnız piksel geometrisi çözer. Yatay eksen tiktir (hafta).
#
# Kullanım (FinanceOzetView):
#   curve.set_data({
#     "samples": [...],        # [{day:int, cash:int}], alanın içinde kalanlar
#     "day_min": int,          # alanın ilk tiki
#     "today_day": int, "cash_now": int,
#     "current_net": int,      # tik başına net: TimeModel.per_tick(GameState.get_net_daily_flow())
#     "optimistic_net": int,   # tik başına: TimeModel.per_tick(FinanceSystem.get_optimistic_daily_net())
#     "horizon": int,          # projeksiyonun tik sayısı
#     "ticks": [...],          # [{day:int, label:String}] ay başlangıçları
#   })
# ============================================================================

const PAD := UiTokens.D_CHART_PAD
const HEADROOM := 1.08   # the plot's room over its highest figure
const MAX_STEPS := 6.0   # the most grid steps across the cash span

## The legend's lines as the curve draws them: the current course only while cash melts, the target only where
## it reads apart from it at the horizon, the danger area only below zero.
var shows := {"current": false, "target": false, "below": false}
var _d: Dictionary = {}
var _axis: Vector3 = Vector3.ZERO   # the cash axis: low, high, step
var _hover := -1                    # the hovered sample


func _init() -> void:
	custom_minimum_size.y = UiTokens.D_H_CHART
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_exited.connect(_hover_at.bind(-1))


func set_data(d: Dictionary) -> void:
	_d = d
	var end_cur: float = d.cash_now + d.current_net * d.horizon
	var end_opt: float = d.cash_now + d.optimistic_net * d.horizon
	var values: Array = d.samples.map(func(s: Dictionary) -> float: return float(s.cash))
	values.append_array([float(d.cash_now), end_opt])
	if d.current_net < 0:
		values.append(end_cur)
	var lo: float = minf(0.0, values.min())
	var hi: float = maxf(1.0, values.max())
	var step: float = _step(hi - lo)
	_axis = Vector3(floorf(lo / step) * step, ceilf(hi * HEADROOM / step) * step, step)
	var plot_h: float = UiTokens.D_H_CHART - PAD.y - PAD.w
	shows = {"current": d.current_net < 0, "below": lo < 0.0,
		"target": d.current_net >= 0 or absf(end_cur - end_opt) / (_axis.y - _axis.x) * plot_h >= UiTokens.D_CHART_STROKE}
	# The note under a pointer that has not moved stays through a repaint.
	_hover = mini(_hover, d.samples.size() - 1)
	queue_redraw()


## The grid's step: one of 1, 2, 2.5, 5 times a power of ten, at most MAX_STEPS of them across the span.
static func _step(span: float) -> float:
	var unit: float = pow(10.0, floorf(log(span / MAX_STEPS) / log(10.0)))
	for m in [1.0, 2.0, 2.5, 5.0]:
		if span / (m * unit) <= MAX_STEPS:
			return m * unit
	return 10.0 * unit


func _gui_input(event: InputEvent) -> void:
	var motion := event as InputEventMouseMotion
	if motion == null or _d.is_empty():
		return
	var best := -1
	var gap := INF
	for i in _d.samples.size():
		var dx: float = absf(_x(float(_d.samples[i].day)) - motion.position.x)
		if dx < gap:
			gap = dx
			best = i
	_hover_at(best)


func _hover_at(index: int) -> void:
	if index != _hover:
		_hover = index
		queue_redraw()


func _x(day: float) -> float:
	var d0: float = _d.day_min
	return PAD.x + (day - d0) / (_d.today_day + _d.horizon - d0) * (size.x - PAD.x - PAD.z)


func _y(cash: float) -> float:
	return PAD.y + (_axis.y - cash) / (_axis.y - _axis.x) * (size.y - PAD.y - PAD.w)


func _draw() -> void:
	if _d.is_empty():
		return
	var font: Font = get_theme_font("font", &"SmallMuted")
	var fs: int = get_theme_font_size("font_size", &"SmallMuted")
	var ink3: Color = get_theme_color("font_color", &"SmallMuted")
	var x0: float = PAD.x
	var x1: float = size.x - PAD.z
	var y1: float = size.y - PAD.w
	var mid: float = (font.get_ascent(fs) - font.get_descent(fs)) * 0.5
	# The cash axis: a grid line a step, the $0 line the axis; figures right-aligned before the plot.
	var v: float = _axis.x
	while v <= _axis.y + 0.5:
		var gy: float = _y(v)
		draw_line(Vector2(x0, gy), Vector2(x1, gy), UiTokens.D_CHART_AXIS if is_zero_approx(v) else UiTokens.D_CHART_GRID)
		var figure: String = Fmt.money_chip(int(v))
		draw_string(font, Vector2(x0 - UiTokens.SPACE_M - font.get_string_size(figure, HORIZONTAL_ALIGNMENT_LEFT, -1,
			fs).x, gy + mid), figure, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink3)
		v += _axis.z
	# The months under the plot.
	for tick in _d.ticks:
		var tx: float = _x(float(tick.day))
		draw_line(Vector2(tx, y1), Vector2(tx, y1 + UiTokens.SPACE_XS), UiTokens.D_CHART_AXIS)
		var width: float = font.get_string_size(tick.label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(font, Vector2(tx - width * 0.5, size.y - UiTokens.SPACE_S), tick.label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink3)

	var realized: Array = _d.samples.map(func(s: Dictionary) -> Vector2: return Vector2(s.day, s.cash))
	var today := Vector2(_d.today_day, _d.cash_now)
	var horizon: float = _d.today_day + _d.horizon
	var course: Array = realized.duplicate()
	if shows.current:
		course.append(Vector2(horizon, _d.cash_now + _d.current_net * _d.horizon))
	_area(realized, false, UiTokens.D_CHART_POS_AREA)
	_area(course, true, UiTokens.D_chart_neg_area())
	if realized.size() > 1:
		draw_polyline(PackedVector2Array(realized.map(_px)), UiTokens.D_CHART_LINE, UiTokens.D_CHART_STROKE, true)
	if shows.current:
		dash(self, _px(today), _px(course[-1]), UiTokens.D_CHART_PROJ, UiTokens.D_DASH_CURRENT)
	if shows.target:
		dash(self, _px(today), _px(Vector2(horizon, _d.cash_now + _d.optimistic_net * _d.horizon)), UiTokens.D_INK_3,
			UiTokens.D_DASH_TARGET)

	# Today's line and, where the course first reaches zero, the zero mark; each says which week it is,
	# today's word on the side away from the zero mark and both inside the plot.
	var tx: float = _x(today.x)
	var top: float = PAD.y - UiTokens.SPACE_XS
	var words: float = PAD.y - UiTokens.SPACE_M
	var gap: float = UiTokens.SPACE_S
	dash(self, Vector2(tx, top), Vector2(tx, y1), UiTokens.D_INK_3, UiTokens.D_DASH_MARK, UiTokens.BORDER_HAIRLINE)
	var today_word: String = tr("FIN_CURVE_TODAY").format({"n": int(GameState.get_date_dict(int(today.x)).week)})
	var today_w: float = font.get_string_size(today_word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var today_left: bool = tx > size.x * 0.5
	var zero: float = _zero_day(course)
	if not is_nan(zero):
		var zx: float = _x(zero)
		dash(self, Vector2(zx, top), Vector2(zx, y1), UiTokens.D_neg(), UiTokens.D_DASH_MARK, UiTokens.BORDER_HAIRLINE)
		var word: String = tr("FIN_CURVE_ZERO").format({"n": int(GameState.get_date_dict(ceili(zero)).week)})
		var w: float = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		# The zero mark's word points away from today, back toward it when the plot ends first; today's then
		# turns away from it, or toward it when both fit between the two lines.
		var right: bool = zx > tx and zx + gap + w <= x1
		draw_string(font, Vector2(zx + gap if right else zx - gap - w, words), word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs,
			UiTokens.D_neg_ink())
		if zx < tx:
			today_left = false
		elif right:
			today_left = true
		else:
			today_left = zx - gap - w <= tx + gap + today_w
	draw_string(font, Vector2(tx - gap - today_w if today_left else tx + gap, words), today_word,
		HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTokens.D_INK_2)
	if _hover >= 0:
		_draw_hover(realized[_hover], font, fs)
	var dot: Vector2 = _px(today)
	draw_circle(dot, UiTokens.D_CHART_DOT + UiTokens.D_CHART_HALO, UiTokens.D_SURFACE_2, true, -1.0, true)
	draw_circle(dot, UiTokens.D_CHART_DOT, UiTokens.D_INK_1, true, -1.0, true)


func _px(p: Vector2) -> Vector2:
	return Vector2(_x(p.x), _y(p.y))


## The area between the line through `points` and zero, on one side of it: under the line above zero, over it below.
func _area(points: Array, below: bool, color: Color) -> void:
	for i in points.size() - 1:
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		if (a.y < 0.0) != (b.y < 0.0):
			var cut := Vector2(lerpf(a.x, b.x, a.y / (a.y - b.y)), 0.0)
			if (a.y < 0.0) == below:
				b = cut
			else:
				a = cut
		elif (a.y < 0.0) != below:
			continue
		draw_colored_polygon(PackedVector2Array([_px(Vector2(a.x, 0.0)), _px(a), _px(b), _px(Vector2(b.x, 0.0))]), color)


## The tick where the course first falls below zero, NAN when it does not.
func _zero_day(course: Array) -> float:
	for i in course.size() - 1:
		var a: Vector2 = course[i]
		var b: Vector2 = course[i + 1]
		if a.y >= 0.0 and b.y < 0.0:
			return lerpf(a.x, b.x, a.y / (a.y - b.y))
	return NAN


## The hovered week: its line, its ringed point and its note, turned back when it would leave the curve.
func _draw_hover(p: Vector2, font: Font, fs: int) -> void:
	var at: Vector2 = _px(p)
	draw_line(Vector2(at.x, PAD.y), Vector2(at.x, size.y - PAD.w), UiTokens.D_LINE_HOVER)
	draw_circle(at, UiTokens.D_CHART_DOT + UiTokens.D_CHART_RING, UiTokens.D_INK_1, true, -1.0, true)
	draw_circle(at, UiTokens.D_CHART_DOT - UiTokens.D_CHART_RING, UiTokens.D_SURFACE_3, true, -1.0, true)
	var title_font: Font = get_theme_font("font", &"TipTitle")
	var title_fs: int = get_theme_font_size("font_size", &"TipTitle")
	var lines: Array = [[Fmt.date_line(GameState.get_date_dict(int(p.x))), title_font, title_fs, UiTokens.D_INK_1],
		[tr("FIN_CURVE_TIP_CASH").format({"amount": Fmt.money_exact(int(p.y))}), font, fs, UiTokens.D_INK_2]]
	var pad: float = UiTokens.SPACE_L
	var h: float = pad * 2.0 + UiTokens.SPACE_XS
	for line in lines:
		h += line[1].get_height(line[2])
	var box := Rect2(at.x + pad, at.y + pad, UiTokens.D_W_CHART_TIP, h)
	if box.end.x > size.x:
		box.position.x = at.x - pad - box.size.x
	if box.end.y > size.y:
		box.position.y = at.y - pad - box.size.y
	draw_style_box(get_theme_stylebox("panel", &"TooltipPanel"), box)
	var y: float = box.position.y + pad
	for line in lines:
		draw_string(line[1], Vector2(box.position.x + pad, y + line[1].get_ascent(line[2])), line[0],
			HORIZONTAL_ALIGNMENT_LEFT, -1, line[2], line[3])
		y += line[1].get_height(line[2]) + UiTokens.SPACE_XS


## A dashed segment: `dash` is the dash and the gap.
static func dash(on: CanvasItem, a: Vector2, b: Vector2, color: Color, rhythm: Vector2,
		width := UiTokens.D_CHART_STROKE) -> void:
	var length: float = a.distance_to(b)
	var dir: Vector2 = (b - a) / maxf(length, 1.0)
	var at := 0.0
	while at < length:
		on.draw_line(a + dir * at, a + dir * minf(at + rhythm.x, length), color, width, true)
		at += rhythm.x + rhythm.y


## A legend's sample of the curve's `kind` of line: "actual", "current", "target" or "below".
static func legend_sample(kind: String) -> Control:
	var sample := Control.new()
	sample.custom_minimum_size = Vector2(UiTokens.D_W_LEGEND, UiTokens.D_ICON_TAG)
	sample.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sample.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sample.draw.connect(_draw_sample.bind(sample, kind))
	return sample


static func _draw_sample(sample: Control, kind: String) -> void:
	var y: float = sample.size.y * 0.5
	var a := Vector2(0, y)
	var b := Vector2(sample.size.x, y)
	match kind:
		"actual":
			sample.draw_line(a, b, UiTokens.D_CHART_LINE, UiTokens.D_CHART_STROKE)
		"current":
			dash(sample, a, b, UiTokens.D_CHART_PROJ, UiTokens.D_DASH_CURRENT)
		"target":
			dash(sample, a, b, UiTokens.D_INK_3, UiTokens.D_DASH_TARGET)
		"below":
			var box := Rect2(0, y - UiTokens.SPACE_S, sample.size.x, UiTokens.SPACE_L)
			sample.draw_rect(box, UiTokens.D_chart_neg_area())
			sample.draw_line(box.position, Vector2(box.end.x, box.position.y), UiTokens.D_neg())
