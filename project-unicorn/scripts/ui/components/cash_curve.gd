class_name CashCurve
extends Control

# ============================================================================
# Nakit eğrisi. Gerçekleşen kasa çizgisi, altında eksene doğru sönen alan, sıfırın altında tehlike alanı; bugünden
# kesikli projeksiyon: "mevcut gidiş" (bugünkü net, yalnız kasa eriyorken) ve "satış hedefi" (pipeline-ağırlıklı
# iyimser net, ufukta ötekinden ayrı okunduğunda), ikisi de ucunda kendi adıyla. Alan seçilen aralığı izler: bugünden
# pencere kadar geri ama koşunun ilk örneğinden öncesine değil, ufka kadar ileri. Bugün tek nokta ve adı; kasanın
# sıfıra indiği ilk hafta kırmızı nokta ve adı; üstüne gelinen haftanın kasası kendi notunda. Ekonomi burada
# HESAPLANMAZ: set_data'ya gelen her sayı bir motor seam'inden çıkar, bu dosya yalnız piksel geometrisi çözer.
# Yatay eksen tiktir (hafta).
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

const PAD := UiTokens.D_CHART_PAD   # the plot's room over its top and under its floor (the months)
const HEADROOM := 0.08   # the plot's room over its highest figure and under its lowest, a share of the span
const MAX_LINES := 3     # the grid's lines across the cash span, $0 among them
const MAX_MONTHS := 4    # the months named under the plot
## A projection's name at its end: the key of its words.
const END_NAME := {"current": "FIN_CURVE_COURSE", "target": "FIN_CURVE_TARGET"}

var _d: Dictionary = {}
var _axis: Vector3 = Vector3.ZERO   # the cash axis: low, high, step
## The current course shows only while the cash melts, the target only where it reads apart from it at the horizon.
var _shows := {"current": false, "target": false}
var _right := 0.0                   # the box's room right of the plot: the projections' names
var _hover := -1                    # the hovered sample


func _init() -> void:
	custom_minimum_size.y = UiTokens.D_H_CHART
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_exited.connect(_hover_at.bind(-1))


func set_data(d: Dictionary) -> void:
	_d = d
	var values: Array = d.samples.map(func(s: Dictionary) -> float: return float(s.cash))
	values.append_array([float(d.cash_now), _end("target")])
	if d.current_net < 0:
		values.append(_end("current"))
	var lo: float = minf(0.0, values.min())
	var hi: float = maxf(1.0, values.max())
	var room: float = (hi - lo) * HEADROOM
	_axis = Vector3(lo - room if lo < 0.0 else 0.0, hi + room, 0.0)
	_axis.z = _step(_axis.x, _axis.y)
	var plot_h: float = UiTokens.D_H_CHART - PAD.y - PAD.w
	var apart: float = absf(_end("current") - _end("target")) / (_axis.y - _axis.x) * plot_h
	_shows = {"current": d.current_net < 0, "target": d.current_net >= 0 or apart >= UiTokens.D_CHART_STROKE}
	var font: Font = get_theme_font("font", &"SmallMuted")
	var fs: int = get_theme_font_size("font_size", &"SmallMuted")
	_right = UiTokens.SPACE_XS
	for kind in END_NAME:
		if _shows[kind]:
			_right = maxf(_right, UiTokens.SPACE_XS + UiTokens.SPACE_S + font.get_string_size(tr(END_NAME[kind]),
				HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
	# The note under a pointer that has not moved stays through a repaint.
	_hover = mini(_hover, d.samples.size() - 1)
	queue_redraw()


## The cash at the horizon on the projection of `kind`, "current" or "target".
func _end(kind: String) -> float:
	return _d.cash_now + (_d.current_net if kind == "current" else _d.optimistic_net) * _d.horizon


## The grid's step: the smallest of 1, 1.5, 2, 5 times a power of ten that leaves at most MAX_LINES lines in [lo, hi].
static func _step(lo: float, hi: float) -> float:
	var unit: float = pow(10.0, floorf(log((hi - lo) / MAX_LINES) / log(10.0)))
	for m in [1.0, 1.5, 2.0, 5.0]:
		if floorf(hi / (m * unit)) - ceilf(lo / (m * unit)) < MAX_LINES:
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
	return UiTokens.SPACE_XS + (day - d0) / (_d.today_day + _d.horizon - d0) * (size.x - _right - UiTokens.SPACE_XS)


func _y(cash: float) -> float:
	return PAD.y + (_axis.y - cash) / (_axis.y - _axis.x) * (size.y - PAD.y - PAD.w)


func _draw() -> void:
	if _d.is_empty():
		return
	var font: Font = get_theme_font("font", &"SmallMuted")
	var fs: int = get_theme_font_size("font_size", &"SmallMuted")
	var x1: float = size.x - _right
	var y1: float = size.y - PAD.w
	var mid: float = (font.get_ascent(fs) - font.get_descent(fs)) * 0.5
	# The cash axis: a line a step, $0 the strongest; each says its figure over its left end.
	for k in range(ceili(_axis.x / _axis.z), floori(_axis.y / _axis.z) + 1):
		var gy: float = _y(k * _axis.z)
		draw_line(Vector2(0.0, gy), Vector2(x1, gy), UiTokens.D_CHART_AXIS if k == 0 else UiTokens.D_CHART_GRID)
		_word(font, fs, Vector2(UiTokens.SPACE_XS, gy - UiTokens.SPACE_XS), Fmt.money_chip(int(k * _axis.z)), UiTokens.D_INK_4)
	# The months under the plot.
	for tick in _months():
		var width: float = font.get_string_size(tick.label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(font, Vector2(clampf(_x(float(tick.day)) - width * 0.5, 0.0, size.x - width), size.y - UiTokens.SPACE_S),
			tick.label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTokens.D_INK_3)

	var realized: Array = _d.samples.map(func(s: Dictionary) -> Vector2: return Vector2(s.day, s.cash))
	var today := Vector2(_d.today_day, _d.cash_now)
	var horizon: float = _d.today_day + _d.horizon
	var course: Array = realized.duplicate()
	if _shows.current:
		course.append(Vector2(horizon, _end("current")))
	var danger: Color = UiTokens.D_chart_neg_area()
	_area(realized, false, UiTokens.D_CHART_FILL, UiTokens.D_CHART_FILL_FADE)
	_area(course, true, danger, danger)
	if realized.size() > 1:
		draw_polyline(PackedVector2Array(realized.map(_px)), UiTokens.D_CHART_LINE, UiTokens.D_CHART_STROKE, true)
	if _shows.current:
		_dash(_px(today), _px(course[-1]), UiTokens.D_CHART_PROJ, UiTokens.D_DASH_CURRENT, UiTokens.D_CHART_STROKE)
	if _shows.target:
		_dash(_px(today), _px(Vector2(horizon, _end("target"))), UiTokens.D_CHART_PROJ, UiTokens.D_DASH_TARGET,
			UiTokens.BORDER_HAIRLINE)
	# Each projection's name beside its end, apart where the two ends lie closer than a line of text.
	var line_h: float = font.get_height(fs)
	var ends: Array = []
	for kind in END_NAME:
		if _shows[kind]:
			ends.append([_y(_end(kind)), tr(END_NAME[kind])])
	ends.sort()
	if ends.size() == 2 and ends[1][0] - ends[0][0] < line_h:
		var apart: float = (line_h - (ends[1][0] - ends[0][0])) * 0.5
		ends[0][0] -= apart
		ends[1][0] += apart
	for end in ends:
		_word(font, fs, Vector2(x1 + UiTokens.SPACE_S, end[0] + mid), end[1], UiTokens.D_INK_3)

	# Where the course first reaches zero: a red point on the $0 line, its week under the line on the side the
	# course has not been.
	var zero: float = _zero_day(course)
	if not is_nan(zero):
		var at: Vector2 = _px(Vector2(zero, 0.0))
		draw_circle(at, UiTokens.D_CHART_MARK, UiTokens.D_neg(), true, -1.0, true)
		var zero_word: String = tr("FIN_CURVE_ZERO").format({"n": int(GameState.get_date_dict(ceili(zero)).week)})
		var zero_w: float = font.get_string_size(zero_word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		_word(font, fs, Vector2(maxf(0.0, at.x - zero_w), at.y + UiTokens.SPACE_S + font.get_ascent(fs)), zero_word,
			UiTokens.D_neg_ink())

	# Today: its point, a rule from it to the floor and its week over it, on the side the projection does not head
	# to (right while the cash melts, left while it climbs).
	var dot: Vector2 = _px(today)
	draw_line(Vector2(dot.x, dot.y + UiTokens.D_CHART_DOT), Vector2(dot.x, y1), UiTokens.D_LINE_2)
	var today_word: String = tr("FIN_CURVE_TODAY").format({"n": int(GameState.get_date_dict(int(today.x)).week)})
	var today_w: float = font.get_string_size(today_word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var left: float = dot.x - UiTokens.D_CHART_DOT if _shows.current else dot.x + UiTokens.D_CHART_DOT - today_w
	_word(font, fs, Vector2(clampf(left, 0.0, size.x - today_w),
		maxf(font.get_ascent(fs), dot.y - UiTokens.D_CHART_DOT - UiTokens.SPACE_M)), today_word, UiTokens.D_INK_2)
	draw_circle(dot, UiTokens.D_CHART_DOT + UiTokens.D_CHART_HALO, UiTokens.D_SURFACE_2, true, -1.0, true)
	draw_circle(dot, UiTokens.D_CHART_DOT, UiTokens.D_INK_1, true, -1.0, true)
	if _hover >= 0:
		_draw_hover(realized[_hover], font, fs)


func _px(p: Vector2) -> Vector2:
	return Vector2(_x(p.x), _y(p.y))


## A word on the plot, ringed in the card's ground so a line behind it does not run through its letters.
func _word(font: Font, fs: int, at: Vector2, text: String, color: Color) -> void:
	draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTokens.SPACE_XS, UiTokens.D_SURFACE_2)
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)


## At most MAX_MONTHS month starts, evenly spread from the first to the last.
func _months() -> Array:
	var all: Array = _d.ticks
	if all.size() <= MAX_MONTHS:
		return all
	return range(MAX_MONTHS).map(func(i: int) -> Dictionary: return all[roundi(i * (all.size() - 1.0) / (MAX_MONTHS - 1))])


## The area between the line through `points` and zero, on one side of it: under the line above zero, over it below;
## `at_line` is its colour at the line, `at_zero` at the $0 line.
func _area(points: Array, below: bool, at_line: Color, at_zero: Color) -> void:
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
		draw_polygon(PackedVector2Array([_px(Vector2(a.x, 0.0)), _px(a), _px(b), _px(Vector2(b.x, 0.0))]),
			PackedColorArray([at_zero, at_line, at_line, at_zero]))


## The tick where the course first falls below zero, NAN when it does not.
func _zero_day(course: Array) -> float:
	for i in course.size() - 1:
		var a: Vector2 = course[i]
		var b: Vector2 = course[i + 1]
		if a.y >= 0.0 and b.y < 0.0:
			return lerpf(a.x, b.x, a.y / (a.y - b.y))
	return NAN


## The hovered week: its line, its ringed point and its note, turned back before it would reach the projections' names.
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
	var w := 0.0
	var h: float = pad * 2.0 + UiTokens.SPACE_XS
	for line in lines:
		w = maxf(w, line[1].get_string_size(line[0], HORIZONTAL_ALIGNMENT_LEFT, -1, line[2]).x)
		h += line[1].get_height(line[2])
	# The note keeps to the half of the plot the point is not in, so it covers neither the point nor the line near it.
	var floor_y: float = size.y - PAD.w
	var box := Rect2(at.x + pad, PAD.y if at.y > (PAD.y + floor_y) * 0.5 else floor_y - h - UiTokens.SPACE_M, w + pad * 2.0, h)
	if box.end.x > size.x - _right:
		box.position.x = at.x - pad - box.size.x
	draw_style_box(get_theme_stylebox("panel", &"ChartTip"), box)
	var y: float = box.position.y + pad
	for line in lines:
		draw_string(line[1], Vector2(box.position.x + pad, y + line[1].get_ascent(line[2])), line[0],
			HORIZONTAL_ALIGNMENT_LEFT, -1, line[2], line[3])
		y += line[1].get_height(line[2]) + UiTokens.SPACE_XS


## A dashed segment: `rhythm` is the dash and the gap.
func _dash(a: Vector2, b: Vector2, color: Color, rhythm: Vector2, width: float) -> void:
	var length: float = a.distance_to(b)
	var dir: Vector2 = (b - a) / maxf(length, 1.0)
	var at := 0.0
	while at < length:
		draw_line(a + dir * at, a + dir * minf(at + rhythm.x, length), color, width, true)
		at += rhythm.x + rhythm.y
