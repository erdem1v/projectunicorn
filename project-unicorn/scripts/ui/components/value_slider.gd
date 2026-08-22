class_name ValueSlider
extends Control

# ONAYLI SAYFANIN SLIDER'I (İK modal sayfası 1b + 1e). Godot'un `HSlider`'ı EMEKLİ
# EDİLDİ bu yüzey için; sebebi zevk değil, ölçüydü.
#
# NEDEN HSlider DEĞİL. HSlider görünümünü tema öğelerinden çözer: `slider` (ray
# stylebox'ı), `grabber_area` (dolu bölüm), `grabber` (bir DOKU). Onaylı tutamaç
# 14×18'lik bir dikdörtgen + İKİ adet 1×8 tutma çizgisi; bunu bir stylebox'la
# çizemezsiniz, bir doku isterdi — yani yeni bir varlık, yeni bir import, ve o
# dokunun tema öğesi olarak `build_theme.gd`'ye girmesi (THEME_STAMP 7 + regen).
# Dolu bölümün 3px, rayın 1px olması da tek bir `grabber_area` stylebox'ıyla
# anlatılamıyor — ikisi FARKLI kalınlıkta ve ortak eksende.
#
# `_draw` bunların hiçbirini istemiyor: dört ilkel şekil ve iki metin. Kart Build
# Bar turunda aynı gerekçeyle `_draw`'a inmişti; bu onun kardeşi.
#
# GODOT KAVRAMI — CanvasItem._draw(). Bir Control `queue_redraw()` çağrıldığında
# kendi yüzeyine doğrudan çizer (`draw_rect`, `draw_line`, `draw_string`). Çizim
# tema öğesi ÇÖZMEZ, o yüzden bu düğüm `--theme-audit` çıktısında yalnız YAPISAL
# bir satır olarak görünür (tamamı tire) — ODA'nın Keyboard TextureRect'i gibi.
#
# RENK VE BOYUT YİNE TOKEN'DAN (UI/STYLE LAW md.1): `_draw` boyama serbestliği
# vermiyor, yalnız çizim yolu değiştiriyor. Aşağıdaki hiçbir satırda ham `Color(...)`
# ya da skala dışı boyut yok.

signal value_changed(value: int)

const MONO_FONT := preload("res://assets/fonts/variations/mono_reg.tres")

# --- Onaylı geometri (sayfa 1b) --------------------------------------------
const RAIL_H := 1.0            # ray kalınlığı
const FILL_H := 3.0            # dolu bölüm — raydan KALIN, aynı eksende
const HANDLE_W := 14.0
const HANDLE_H := 18.0
const GRIP_W := 1.0
const GRIP_H := 8.0
const GRIP_GAP := 2.0
const END_GAP := 7.0           # ray ile uç etiketleri arası (margin-top 7)
const END_SIZE := UiTokens.SIZE_MICRO   # 9.5 → 9 (merdiven yukarı yuvarlar)
const OUTLINE_INSET := -2.0    # hover outline offset 2

var min_value: int = 0
var max_value: int = 100
var value: int = 0

var _hovered: bool = false
var _dragging: bool = false


func _ready() -> void:
	# Yükseklik: tutamaç (18) + uç boşluğu (7) + uç etiketi satırı (~12).
	# Ray tutamacın DİKEY ORTASINDA; uçlar rayın ALTINDA, yani tutamaçla hiçbir
	# konumda çarpışamazlar — sayfanın 1e notunun geometrik karşılığı budur.
	custom_minimum_size = Vector2(0, HANDLE_H + END_GAP + float(END_SIZE) + 3.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_ALL


func setup(lo: int, hi: int, start: int) -> void:
	min_value = lo
	max_value = maxi(hi, lo)
	value = clampi(start, min_value, max_value)
	queue_redraw()


func _rail_y() -> float:
	return HANDLE_H * 0.5


func _track_rect() -> Rect2:
	# Tutamaç raydan taşmasın diye iz yarı-tutamaç kadar içeriden başlar; böylece
	# %3'te sol kenar, %15'te sağ kenar TAM hizada durur, dışarı sarkmaz.
	var half: float = HANDLE_W * 0.5
	return Rect2(half, _rail_y(), maxf(size.x - HANDLE_W, 1.0), 0.0)


func _ratio() -> float:
	if max_value == min_value:
		return 0.0
	return float(value - min_value) / float(max_value - min_value)


func _draw() -> void:
	var track: Rect2 = _track_rect()
	var y: float = _rail_y()
	var handle_x: float = track.position.x + track.size.x * _ratio()

	# 1) RAY — uçtan uca, 1px, sönük kenar rengi.
	draw_rect(Rect2(track.position.x, y - RAIL_H * 0.5, track.size.x, RAIL_H),
		UiTokens.BORDER_HOVER)
	# 2) DOLU BÖLÜM — soldan tutamaca, 3px, kehribar.
	draw_rect(Rect2(track.position.x, y - FILL_H * 0.5,
		maxf(handle_x - track.position.x, 0.0), FILL_H), UiTokens.ACCENT)

	# 3) TUTAMAÇ — koyu zemin + 1px kehribar kontur. Zemin ÖNCE, çünkü rayı
	#    kapatması gerekiyor: tutamaç rayın ÜSTÜNDE duruyor, içinden geçmiyor.
	var h := Rect2(handle_x - HANDLE_W * 0.5, y - HANDLE_H * 0.5, HANDLE_W, HANDLE_H)
	var edge: Color = UiTokens.ACCENT_HOVER if (_hovered or _dragging) else UiTokens.ACCENT
	draw_rect(h, UiTokens.CARD_BG)
	draw_rect(h, edge, false, 1.0)
	if _hovered or _dragging:
		# Hover halkası: 2px dışarıda, kırpılmış kehribar. Kontur RENGİYLE değil
		# ALFASIYLA ayrışıyor — dolgu hover'ı yasak (UI/STYLE LAW: hover kenarda yaşar).
		draw_rect(h.grow(-OUTLINE_INSET), Color(UiTokens.ACCENT_HOVER, 0.45), false, 1.0)
	# 4) İKİ TUTMA ÇİZGİSİ — 1×8, aralarında 2px.
	var gx: float = handle_x - (GRIP_W * 2.0 + GRIP_GAP) * 0.5
	for i in 2:
		draw_rect(Rect2(gx + float(i) * (GRIP_W + GRIP_GAP), y - GRIP_H * 0.5,
			GRIP_W, GRIP_H), edge)

	# 5) UÇLAR — rayın ALTINDA, sönük, küçük. Sol sola, sağ sağa yaslı.
	var font: Font = MONO_FONT
	var ty: float = y + HANDLE_H * 0.5 + END_GAP + float(END_SIZE)
	var lo_text: String = Fmt.percent(min_value, 0)
	var hi_text: String = Fmt.percent(max_value, 0)
	draw_string(font, Vector2(track.position.x, ty), lo_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, END_SIZE, UiTokens.INK_DIM)
	var hi_w: float = font.get_string_size(hi_text, HORIZONTAL_ALIGNMENT_LEFT,
		-1.0, END_SIZE).x
	draw_string(font, Vector2(track.position.x + track.size.x - hi_w, ty), hi_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, END_SIZE, UiTokens.INK_DIM)


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_hovered = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_hovered = false
		queue_redraw()
	elif what == NOTIFICATION_RESIZED:
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			grab_focus()
			_set_from_x(event.position.x)
		else:
			_dragging = false
			queue_redraw()
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_set_from_x(event.position.x)
		accept_event()
	elif event.is_action_pressed("ui_left", true):
		_commit(value - 1)
		accept_event()
	elif event.is_action_pressed("ui_right", true):
		_commit(value + 1)
		accept_event()


func _set_from_x(x: float) -> void:
	var track: Rect2 = _track_rect()
	var t: float = clampf((x - track.position.x) / maxf(track.size.x, 1.0), 0.0, 1.0)
	_commit(min_value + int(roundf(t * float(max_value - min_value))))


func _commit(v: int) -> void:
	var nv: int = clampi(v, min_value, max_value)
	if nv == value:
		queue_redraw()
		return
	value = nv
	queue_redraw()
	value_changed.emit(value)
