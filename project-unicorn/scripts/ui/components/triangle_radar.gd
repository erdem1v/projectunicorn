class_name TriangleRadar
extends Control

# Üç eksenli ürün profili radarı: kendi _draw()'u olan, tscn'siz Control.
# Kullanım: set_axes({"innovation": 8, "stability": 5, "experience": 4}, max).

const DEFAULT_MAX := 25.0        # kurma ekranı önizlemesinin ölçek tabanı
const LABEL_GAP := 14.0          # köşe → etiket mesafesi (px)
const NARROW_WIDTH := 260.0      # bu genişliğin altında yarıçap ekstra kısılır
const NARROW_R_FACTOR := 0.30    # dar genişlikte r üst sınırı = size.x × bu
const CENTER_NUDGE := 0.06       # merkez ~%6 aşağı — tepe etiketi sığsın
const FILL_ALPHA := 0.22         # değer poligonu dolgu saydamlığı
const VERTEX_DOT_R := 3.0        # değer köşesi nokta yarıçapı

# Tepeden saat yönünde okunuş legend sırasıdır. Godot y-aşağı: 30/150 alt yarıya düşer.
const CORNER_ANGLES_DEG := {
	"innovation": -90.0,
	"experience": 150.0,
	"stability": 30.0,
}
# Etiketin köşe noktasına tutunduğu yer, kendi boyutunun kesri olarak: tepe etiketi
# noktanın üstünde ortalı; alt etiketler dikey ortalı, sol-alt sağ kenarıyla, sağ-alt
# sol kenarıyla.
const LABEL_ANCHOR := {
	"innovation": Vector2(0.5, 1.0),
	"experience": Vector2(1.0, 0.5),
	"stability": Vector2(0.0, 0.5),
}

var _t := {"innovation": 0.0, "stability": 0.0, "experience": 0.0}  # eksen / ölçek, 0..1
var _labels: Dictionary = {}     # axis id -> Label (child)


# Varsayılanlar _init'te: çağıran new() ile add_child arasında min boyutu ezebilsin.
func _init() -> void:
	custom_minimum_size = Vector2(0, 170)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for axis in CORNER_ANGLES_DEG:
		var lbl := Label.new()
		lbl.theme_type_variation = &"SectionLabel"
		lbl.add_theme_color_override("font_color", UiTokens.INK_DIM)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Fmt.upper: Türkçe noktalı İ korunur, İngilizce kazanmaz.
		lbl.text = Fmt.upper(ProductCatalog.axis_label(axis))
		add_child(lbl)
		_labels[axis] = lbl
	resized.connect(_position_labels)


## Eksen değerlerini yaz (keys: innovation / stability / experience) ve yeniden çiz.
func set_axes(values: Dictionary, max_value: float) -> void:
	var m: float = maxf(0.001, max_value)
	for axis in _t:
		_t[axis] = clampf(float(values.get(axis, 0.0)) / m, 0.0, 1.0)
	queue_redraw()


func _center() -> Vector2:
	return Vector2(size.x * 0.5, size.y * (0.5 + CENTER_NUDGE))


func _radius() -> float:
	var r: float = minf(size.y * 0.40, size.x * 0.42)
	if size.x < NARROW_WIDTH:
		r = minf(r, size.x * NARROW_R_FACTOR)
	return r


func _dir(axis: String) -> Vector2:
	return Vector2.from_angle(deg_to_rad(CORNER_ANGLES_DEG[axis]))


func _position_labels() -> void:
	var c: Vector2 = _center()
	var r: float = _radius()
	for axis in CORNER_ANGLES_DEG:
		var lbl: Label = _labels[axis]
		var sz: Vector2 = lbl.get_minimum_size()
		lbl.size = sz
		var pos: Vector2 = c + _dir(axis) * (r + LABEL_GAP) - sz * LABEL_ANCHOR[axis]
		lbl.position = pos.clamp(Vector2.ZERO, (size - sz).max(Vector2.ZERO))


func _draw() -> void:
	var c: Vector2 = _center()
	var r: float = _radius()
	if r <= 2.0:
		return
	# Izgara: r×[1/3, 2/3, 1] iç içe üçgenler + merkez→köşe kolları.
	for f in [1.0 / 3.0, 2.0 / 3.0, 1.0]:
		var grid := PackedVector2Array()
		for axis in CORNER_ANGLES_DEG:
			grid.append(c + _dir(axis) * r * f)
		grid.append(grid[0])
		draw_polyline(grid, UiTokens.CARD_BORDER, 1.0, true)
	for axis in CORNER_ANGLES_DEG:
		draw_line(c, c + _dir(axis) * r, UiTokens.CARD_BORDER, 1.0, true)
	if _t.values().max() <= 0.01:
		return  # boş seçim — dejenere poligon çizme
	var pts := PackedVector2Array()
	for axis in CORNER_ANGLES_DEG:
		pts.append(c + _dir(axis) * r * float(_t[axis]))
	draw_colored_polygon(pts, Color(UiTokens.ACCENT, FILL_ALPHA))
	var outline := pts.duplicate()
	outline.append(pts[0])
	draw_polyline(outline, UiTokens.ACCENT_DEEP, 2.0, true)
	for p in pts:
		draw_circle(p, VERTEX_DOT_R, UiTokens.ACCENT_DEEP)
