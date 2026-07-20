class_name TriangleRadar
extends Control

# ============================================================================
# Üç eksenli ürün profili radarı (Rev3, plan Step 8). Köşeler: İNOVASYON tepe
# (−90°), DENEYİM sol-alt (150°), KARARLILIK sağ-alt (30°) — legend sırasıyla
# eşleşir. Desen radial_dial.gd'den: kendi _draw()'u olan, queue_redraw ile
# tazelenen, UiTokens renkli, tscn'siz Control.
#
# Kullanım: set_axes({"innovation": 8, "stability": 5, "experience": 4}, max).
# Kurma-ekranı önizlemesi ile Ürün Detayı AYNI ölçeği (DEFAULT_MAX tabanı)
# kullanır ki iki yüzeydeki şekiller karşılaştırılabilir kalsın.
# ============================================================================

const DEFAULT_MAX := 25.0        # paylaşılan ölçek tabanı (önizleme == detay)
const LABEL_GAP := 14.0          # köşe → etiket mesafesi (px)
const NARROW_WIDTH := 260.0      # bu genişliğin altında yarıçap ekstra kısılır
const NARROW_R_FACTOR := 0.30    # dar genişlikte r üst sınırı = size.x × bu
const CENTER_NUDGE := 0.06       # merkez ~%6 aşağı — tepe etiketi sığsın
const FILL_ALPHA := 0.22         # değer poligonu dolgu saydamlığı
const VERTEX_DOT_R := 3.0        # değer köşesi nokta yarıçapı

# Çizim sırası köşe düzenini verir: tepe → sol-alt → sağ-alt.
const CORNER_ORDER := ["innovation", "experience", "stability"]
const CORNER_ANGLES_DEG := {     # Godot y-aşağı: 30/150 alt yarıya düşer
	"innovation": -90.0,
	"experience": 150.0,
	"stability": 30.0,
}
const DEFAULT_LABELS := {
	"innovation": "İNOVASYON",
	"experience": "DENEYİM",
	"stability": "KARARLILIK",
}

var _values := {"innovation": 0.0, "stability": 0.0, "experience": 0.0}
var _max: float = DEFAULT_MAX
var _labels: Dictionary = {}     # axis id -> Label (child)


func _ready() -> void:
	custom_minimum_size = Vector2(0, 170)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for axis in CORNER_ORDER:
		var lbl := Label.new()
		lbl.theme_type_variation = &"SectionLabel"
		lbl.add_theme_color_override("font_color", UiTokens.INK_DIM)  # küçük ve soluk (spec)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.text = String(DEFAULT_LABELS[axis])
		add_child(lbl)
		_labels[axis] = lbl
	resized.connect(_on_resized)
	_position_labels()


## Eksen değerlerini yaz (keys: innovation / stability / experience) ve yeniden çiz.
func set_axes(values: Dictionary, max_value: float = DEFAULT_MAX) -> void:
	for axis in _values.keys():
		_values[axis] = maxf(0.0, float(values.get(axis, 0.0)))
	_max = maxf(0.001, max_value)
	queue_redraw()


## Köşe etiketlerini isteğe bağlı ez (keys: innovation / stability / experience).
func set_labels(labels: Dictionary) -> void:
	for axis in labels.keys():
		if _labels.has(axis):
			(_labels[axis] as Label).text = String(labels[axis])
	_position_labels()


func _on_resized() -> void:
	_position_labels()
	queue_redraw()


func _center() -> Vector2:
	return Vector2(size.x * 0.5, size.y * 0.5 + size.y * CENTER_NUDGE)


func _radius() -> float:
	var r: float = minf(size.y * 0.40, size.x * 0.42)
	if size.x < NARROW_WIDTH:
		r = minf(r, size.x * NARROW_R_FACTOR)
	return maxf(r, 1.0)


func _dir(axis: String) -> Vector2:
	var a: float = deg_to_rad(float(CORNER_ANGLES_DEG[axis]))
	return Vector2(cos(a), sin(a))


func _position_labels() -> void:
	if _labels.is_empty():
		return
	var c: Vector2 = _center()
	var r: float = _radius()
	for axis in CORNER_ORDER:
		var lbl: Label = _labels[axis]
		var sz: Vector2 = lbl.get_minimum_size()
		lbl.size = sz
		var p: Vector2 = c + _dir(axis) * (r + LABEL_GAP)
		var pos: Vector2
		match axis:
			"innovation":      # tepe: yatay ortala, etiket noktanın ÜSTÜNDE
				pos = Vector2(p.x - sz.x * 0.5, p.y - sz.y)
			"experience":      # sol-alt: sağ kenarı noktaya, dikey ortala
				pos = Vector2(p.x - sz.x, p.y - sz.y * 0.5)
			_:                 # sağ-alt (stability): sol kenarı noktaya, dikey ortala
				pos = Vector2(p.x, p.y - sz.y * 0.5)
		pos.x = clampf(pos.x, 0.0, maxf(0.0, size.x - sz.x))
		pos.y = clampf(pos.y, 0.0, maxf(0.0, size.y - sz.y))
		lbl.position = pos


func _draw() -> void:
	var c: Vector2 = _center()
	var r: float = _radius()
	if r <= 2.0:
		return
	# Izgara: r×[1/3, 2/3, 1] iç içe üçgenler + merkez→köşe kolları.
	for f in [1.0 / 3.0, 2.0 / 3.0, 1.0]:
		var grid := PackedVector2Array()
		for axis in CORNER_ORDER:
			grid.append(c + _dir(axis) * r * f)
		grid.append(grid[0])
		draw_polyline(grid, UiTokens.CARD_BORDER, 1.0, true)
	for axis in CORNER_ORDER:
		draw_line(c, c + _dir(axis) * r, UiTokens.CARD_BORDER, 1.0, true)
	# Değer poligonu: amber dolgu + koyu amber kontur + köşe noktaları.
	var pts := PackedVector2Array()
	var biggest: float = 0.0
	for axis in CORNER_ORDER:
		var t: float = clampf(float(_values[axis]) / _max, 0.0, 1.0)
		biggest = maxf(biggest, t)
		pts.append(c + _dir(axis) * r * t)
	if biggest <= 0.01:
		return  # boş seçim — dejenere poligon çizme
	var fill: Color = UiTokens.ACCENT
	fill.a = FILL_ALPHA
	draw_colored_polygon(pts, fill)
	var outline := pts.duplicate()
	outline.append(pts[0])
	draw_polyline(outline, UiTokens.ACCENT_DEEP, 2.0, true)
	for p in pts:
		draw_circle(p, VERTEX_DOT_R, UiTokens.ACCENT_DEEP)
