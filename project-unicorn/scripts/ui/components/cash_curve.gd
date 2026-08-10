class_name CashCurve
extends Control

# ============================================================================
# Nakit eğrisi (Finance Tab v1). Gerçekleşen kasa çizgisi + iki kesikli
# projeksiyon: "mevcut gidiş" (bugünkü günlük net, doğrusal) ve "satış hedefi
# tutarsa" (pipeline-ağırlıklı iyimser net). Desen triangle_radar.gd'den:
# kendi _draw()'u olan, queue_redraw ile tazelenen, UiTokens renkli, tscn'siz
# Control. Ekonomi burada HESAPLANMAZ — set_data'ya gelen her sayı bir motor
# seam'inden çıkar; bu dosya yalnız piksel geometrisi çözer.
#
# Kullanım (FinanceOzetView):
#   curve.set_data({
#     "samples": [...],        # [{day:int, cash:int}] — pencere görünümde KIRPILMIŞ
#     "today_day": int, "cash_now": int,
#     "current_net": int,      # GameState.get_net_daily_flow()
#     "optimistic_net": int,   # FinanceSystem.get_optimistic_daily_net()
#     "horizon_days": int,     # projeksiyon uzunluğu (görünüm karar verir)
#     "ticks": [...],          # [{day:int, label:String}] ay başlangıçları
#   })
# ============================================================================

const PAD_LEFT := 8.0
const PAD_RIGHT := 8.0
const PAD_TOP := 10.0
const PAD_BOTTOM := 20.0         # ay etiketleri için alt bant
const REALIZED_WIDTH := 2.0
const PROJECTION_WIDTH := 1.5
const DASH_LEN := 5.0
# İKİ PROJEKSİYONUN AYRI RİTMİ. Eskiden ikisi de aynı kalınlık ve aynı kesik
# boyundaydı, yani onları ayıran TEK şey renkti — tasarımdaki sıfır-yedeklilikli
# iki yerden biri (öteki 4a'daki çıplak "CANLI" metni). Renk körü modu açıkken
# mavi/turuncu ayrımı hâlâ okunur, ama ritim farkı renkten BAĞIMSIZ bir ikinci
# işarettir ve grafiğin tek dayanağı hue olmaktan çıkar.
const DASH_CURRENT := 4.0        # "mevcut gidiş" — sık kesik
const DASH_TARGET := 11.0        # "satış hedefi tutarsa" — uzun kesik
const TODAY_DOT_R := 3.5
const TICK_FONT_SIZE := 9
const GRID_LINES := 3            # yatay kılavuz çizgisi sayısı

var _d: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = Vector2(0, 220)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_data(d: Dictionary) -> void:
	_d = d
	queue_redraw()


func _draw() -> void:
	var samples: Array = _d.get("samples", [])
	if samples.is_empty():
		return
	var today_day: int = int(_d.get("today_day", 1))
	var cash_now: int = int(_d.get("cash_now", 0))
	var current_net: int = int(_d.get("current_net", 0))
	var optimistic_net: int = int(_d.get("optimistic_net", 0))
	var horizon_days: int = maxi(int(_d.get("horizon_days", 30)), 1)

	# --- Alan (plot rect) ---
	var x0: float = PAD_LEFT
	var x1: float = maxf(size.x - PAD_RIGHT, x0 + 1.0)
	var y0: float = PAD_TOP
	var y1: float = maxf(size.y - PAD_BOTTOM, y0 + 1.0)
	if x1 - x0 < 8.0 or y1 - y0 < 8.0:
		return

	# --- Gün alanı: pencere başı → bugün + ufuk ---
	var day_min: float = float(samples[0].day)
	var day_max: float = float(today_day + horizon_days)
	if day_max <= day_min:
		day_max = day_min + 1.0  # 1. gün tek nokta — sıfıra bölme koruması

	# --- Nakit alanı: örnekler + projeksiyon uçları; $0 tabanı hep dahil ---
	var cash_min: float = 0.0
	var cash_max: float = 1.0
	for s in samples:
		cash_min = minf(cash_min, float(s.cash))
		cash_max = maxf(cash_max, float(s.cash))
	var end_current: float = float(cash_now + current_net * horizon_days)
	var end_optimistic: float = float(cash_now + optimistic_net * horizon_days)
	if current_net < 0:
		cash_min = minf(cash_min, end_current)
		cash_max = maxf(cash_max, end_current)
	cash_min = minf(cash_min, end_optimistic)
	cash_max = maxf(cash_max, end_optimistic)
	cash_max *= 1.08
	if cash_max - cash_min < 1.0:
		cash_min -= 1.0  # düz seri (tüm değerler eşit) — aralığı yapay aç
		cash_max += 1.0

	var to_px := func(day: float, cash: float) -> Vector2:
		var tx: float = (day - day_min) / (day_max - day_min)
		var ty: float = (cash - cash_min) / (cash_max - cash_min)
		return Vector2(lerpf(x0, x1, tx), lerpf(y1, y0, ty))

	# --- 1. Kılavuz: yatay hairline'lar + $0 tabanı ---
	for i in range(1, GRID_LINES + 1):
		var gy: float = lerpf(y0, y1, float(i) / float(GRID_LINES + 1))
		draw_line(Vector2(x0, gy), Vector2(x1, gy), UiTokens.DIVIDER_LIGHT, 1.0)
	if cash_min < 0.0:
		var zero_color: Color = UiTokens.negative()
		zero_color.a = 0.4
		var zy: float = to_px.call(day_min, 0.0).y
		draw_line(Vector2(x0, zy), Vector2(x1, zy), zero_color, 1.0)

	# --- 2. Ay işaretleri + etiketler ---
	var font: Font = get_theme_default_font()
	for tick in _d.get("ticks", []):
		var td: float = float(tick.day)
		if td < day_min or td > day_max:
			continue
		var tx: float = to_px.call(td, cash_min).x
		draw_line(Vector2(tx, y1), Vector2(tx, y1 + 4.0), UiTokens.INK_DIM, 1.0)
		var label: String = String(tick.label)
		var lw: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, TICK_FONT_SIZE).x
		var lx: float = clampf(tx - lw * 0.5, x0, maxf(x0, x1 - lw))
		draw_string(font, Vector2(lx, y1 + 16.0), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, TICK_FONT_SIZE, UiTokens.INK_DIM)

	# --- 3. Gerçekleşen çizgi (+ altı dolgu). Tek örnek → yalnız nokta
	#     (tek noktalı polyline hata basar). ---
	var pts := PackedVector2Array()
	for s in samples:
		pts.append(to_px.call(float(s.day), float(s.cash)))
	if pts.size() == 1:
		draw_circle(pts[0], TODAY_DOT_R, UiTokens.INK)
	else:
		# DOLGU YOK (Terminal, mockup 5i): grafikteki her path `fill="none"`.
		# Sayfanın kendi notu "tek dolgu" diyor ama SVG'de dolgu yok — SVG yönetir.
		draw_polyline(pts, UiTokens.INK, REALIZED_WIDTH, true)

	# --- 4. Bugün: kesikli dikey hairline + nokta; projeksiyonlar buradan çatallanır ---
	var today_px: Vector2 = to_px.call(float(today_day), float(cash_now))
	draw_dashed_line(Vector2(today_px.x, y0), Vector2(today_px.x, y1),
			UiTokens.INK_DIM, 1.0, DASH_LEN)

	# --- 5. Projeksiyon "mevcut gidiş" — YALNIZ net negatifken (ARTIDA kuralı:
	#     kasa erimiyorken kırmızı erime çizgisi çizilmez). ---
	if current_net < 0:
		var end_c: Vector2 = to_px.call(day_max, end_current)
		draw_dashed_line(today_px, end_c, UiTokens.negative(), PROJECTION_WIDTH, DASH_CURRENT)

	# --- 6. Projeksiyon "satış hedefi tutarsa" ---
	var end_o: Vector2 = to_px.call(day_max, end_optimistic)
	draw_dashed_line(today_px, end_o, UiTokens.positive(), PROJECTION_WIDTH, DASH_TARGET)

	# --- 7. Bugün noktası en üstte ---
	draw_circle(today_px, TODAY_DOT_R, UiTokens.ACCENT_DEEP)
