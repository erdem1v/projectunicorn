class_name ValueSlider
extends Control

# İK modal sayfasının slider'ı, `_draw` ile çizilir. HSlider burada yetmiyor: onaylı
# tutamaç 14×18'lik bir dikdörtgen + iki 1×8 tutma çizgisi (stylebox çizemez, yeni bir
# doku ve tema öğesi isterdi), dolu bölüm 3px ve ray 1px ortak eksende (tek bir
# `grabber_area` stylebox'ı bunu anlatamaz). Çizim tema öğesi çözmediği için bu düğüm
# `--theme-audit` çıktısında yalnız yapısal bir satır olarak görünür. Renk ve boyut
# yine token'dan gelir.

signal value_changed(value: int)

const MONO_FONT := preload("res://assets/fonts/variations/mono_reg.tres")

const RAIL_H := 1.0            # ray kalınlığı
const FILL_H := 3.0            # dolu bölüm — raydan KALIN, aynı eksende
const HANDLE_W := 14.0
const HANDLE_H := 18.0
const RAIL_Y := HANDLE_H * 0.5 # ray tutamacın dikey ortasında
const GRIP_W := 1.0
const GRIP_H := 8.0
const GRIP_GAP := 2.0
const END_GAP := 7.0           # ray ile uç etiketleri arası
const END_SIZE := UiTokens.SIZE_MICRO
const OUTLINE_INSET := 2.0     # hover halkasının tutamaçtan uzaklığı

var min_value: int = 0
var max_value: int = 100
var value: int = 0

var _hovered: bool = false
var _dragging: bool = false


func _ready() -> void:
	# Tutamaç + uç boşluğu + uç etiketi satırı. Uçlar rayın ALTINDA, yani tutamaçla
	# hiçbir konumda çarpışmazlar.
	custom_minimum_size = Vector2(0, HANDLE_H + END_GAP + float(END_SIZE) + 3.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_ALL


func setup(lo: int, hi: int, start: int) -> void:
	min_value = lo
	max_value = maxi(hi, lo)
	value = clampi(start, min_value, max_value)
	queue_redraw()


func _track_rect() -> Rect2:
	# İz yarı-tutamaç kadar içeriden başlar: uçlarda tutamaç kenarla hizalı durur, sarkmaz.
	return Rect2(HANDLE_W * 0.5, RAIL_Y, maxf(size.x - HANDLE_W, 1.0), 0.0)


func _ratio() -> float:
	if max_value == min_value:
		return 0.0
	return float(value - min_value) / float(max_value - min_value)


func _draw() -> void:
	var track: Rect2 = _track_rect()
	var handle_x: float = track.position.x + track.size.x * _ratio()
	var active: bool = _hovered or _dragging

	draw_rect(Rect2(track.position.x, RAIL_Y - RAIL_H * 0.5, track.size.x, RAIL_H),
		UiTokens.BORDER_HOVER)
	draw_rect(Rect2(track.position.x, RAIL_Y - FILL_H * 0.5,
		maxf(handle_x - track.position.x, 0.0), FILL_H), UiTokens.ACCENT)

	# Tutamaç zemini rayı örter: tutamaç rayın üstünde durur, içinden geçmez.
	var h := Rect2(handle_x - HANDLE_W * 0.5, RAIL_Y - HANDLE_H * 0.5, HANDLE_W, HANDLE_H)
	var edge: Color = UiTokens.ACCENT_HOVER if active else UiTokens.ACCENT
	draw_rect(h, UiTokens.CARD_BG)
	draw_rect(h, edge, false, 1.0)
	if active:
		# Hover kenarda yaşar: dolgu değil, alfası düşük bir dış halka.
		draw_rect(h.grow(OUTLINE_INSET), Color(UiTokens.ACCENT_HOVER, 0.45), false, 1.0)
	var gx: float = handle_x - (GRIP_W * 2.0 + GRIP_GAP) * 0.5
	for i in 2:
		draw_rect(Rect2(gx + float(i) * (GRIP_W + GRIP_GAP), RAIL_Y - GRIP_H * 0.5,
			GRIP_W, GRIP_H), edge)

	var ty: float = RAIL_Y + HANDLE_H * 0.5 + END_GAP + float(END_SIZE)
	var hi_text: String = Fmt.percent(max_value, 0)
	draw_string(MONO_FONT, Vector2(track.position.x, ty), Fmt.percent(min_value, 0),
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, END_SIZE, UiTokens.INK_DIM)
	var hi_w: float = MONO_FONT.get_string_size(hi_text, HORIZONTAL_ALIGNMENT_LEFT,
		-1.0, END_SIZE).x
	draw_string(MONO_FONT, Vector2(track.end.x - hi_w, ty), hi_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, END_SIZE, UiTokens.INK_DIM)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_hovered = true
			queue_redraw()
		NOTIFICATION_MOUSE_EXIT:
			_hovered = false
			queue_redraw()
		NOTIFICATION_RESIZED:
			queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if event.pressed:
			grab_focus()
			_set_from_x(event.position.x)
		else:
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
	var t: float = clampf((x - track.position.x) / track.size.x, 0.0, 1.0)
	_commit(min_value + int(roundf(t * float(max_value - min_value))))


func _commit(v: int) -> void:
	var nv: int = clampi(v, min_value, max_value)
	queue_redraw()
	if nv != value:
		value = nv
		value_changed.emit(value)
