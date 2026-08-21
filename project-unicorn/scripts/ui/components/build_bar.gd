extends Control

# BuildBar — onaylı Build Bar kartı (tasarım sayfası rev 3, 2026-08-21). TEK renderer,
# ÜÇ ev sahibi: tracker kartı, ODA monitörü ve Ürün sayfası aynı sahneyi (BuildBar.tscn)
# kurar. R6: monitördeki kart yeniden çizilmez, yeniden biçimlenmez — AYNI karttır.
#
# ÜÇ SATIR, hepsi 2i'nin tek-gerçek defterinden:
#   ürün    : hangi yapım. Faz adı burada TEKRAR EDİLMEZ. Duraklamışsa meşguliyet notu.
#   faz     : SATIRIN KENDİ ZEMİNİ İLERLEMEDİR — ayrı çubuk yok. Ad + iş yükü + yüzde.
#   karar   : karttaki TEK basılabilir şey; düzeltme koşarken düşer.
# Üstünde 2px KAPAK ÇİZGİSİ: grubun durumu (amber yapım · kırmızı durmuş · yeşil DESTEK).
#
# DOLGU SINIRINDA DİKEY ÇİZGİ YOKTUR ve bu bir stil tercihi değil bir ÖLÇÜM: dolgu
# rampa renginin %13 alfası olduğu için sınırın iki yanındaki yazı aynı kontrastta
# okunuyor, yani ayıraç çizgisine gerek kalmıyor. Çizgi eklemek sayaç dizgisini keserdi
# (sayfanın 2b stres karesi tam olarak bunu kanıtlıyor).
#
# TUR RAKAMI HİÇBİR YERDE YAZMAZ. Turu RENK taşır (UiTokens.build_ramp).
#
# TEMA-BAĞIMSIZ, BİLEREK: her yazı boyu/rengi UiTokens'tan, yazı tipi PROJE temasından
# (ThemeDB) okunur — get_theme_font ya da theme_type_variation DEĞİL. Sebep ölçüldü:
# ODA alt ağacı kendi DONDURULMUŞ temasını çözer, yani varyasyona uzanan bir kart
# monitörde tracker'dakinden FARKLI düşerdi ve R6 "aynı kart" der.
#
# Godot kavramı: PROCESS_MODE_ALWAYS — ağaç duraklıyken (oyuncu karar verirken) bile
# gui_input dağıtılsın. Varsayılan INHERIT'te kart ÇİZİLİR ama her tıklamayı YUTAR;
# editörde görünmez, yalnız çalışma anında ortaya çıkar.

const Model := preload("res://scripts/ui/components/build_bar_model.gd")

const ICON_DIR := "res://assets/icons/build/"

# Onaylı sayfanın ölçüleri (360px tracker). `size_scale` ev sahibinin büyütmesi için.
const CAP_H := 2
const ROW_PRODUCT_H := 44
const ROW_PHASE_H := 48
const ROW_DECISION_H := 44
const PAD_X := 12
const GAP := 10

## Ev sahibi kartı büyütebilir (Ürün sayfası). 1.0 = onaylı tracker boyu.
@export var size_scale: float = 1.0

var _model = null
var _font: Font = null

var _cap: Panel = null
var _product_row: HBoxContainer = null
var _name_label: Label = null
var _busy_label: Label = null
var _phase_row: Control = null
var _fill: Panel = null
var _phase_icon: TextureRect = null
var _phase_label: Label = null
var _pause_glyph: TextureRect = null
var _work_label: Label = null
var _percent_label: Label = null
var _decision_row: PanelContainer = null
var _decision_icon: TextureRect = null
var _decision_label: Label = null
var _decision_hover := false

# Bağlantılar bir kez kurulur ve AYNI callable'larla sökülür.
var _wires: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS   # karar satırı tıklanabilir; kart kendisi değil
	add_to_group(&"build_bar")
	_font = _resolve_font()
	_build_tree()
	var r1: Callable = refresh.unbind(1)
	_wires = [
		[EventBus.build_progress_changed, Callable(self, "refresh")],
		[EventBus.build_phase_changed, r1],
		[EventBus.build_iteration_decision_pending, r1],
		[EventBus.day_advanced, r1],
		[EventBus.language_changed, r1],
		# MEŞGULİYET AYNI KAREDE OKUNSUN (B3). Bu ikisi bugüne kadar hiçbir yapım
		# yüzeyi tarafından dinlenmiyordu, yani bir atama değişikliği karta ancak
		# BİR SONRAKİ oyun saatinde ulaşırdı ve oyuncu bunu takılma diye okurdu.
		[EventBus.assignment_changed, r1],
		[EventBus.employee_training_changed, refresh.unbind(2)],
		[EventBus.palette_changed, r1],
	]
	for w in _wires:
		(w[0] as Signal).connect(w[1])
	refresh()


func _exit_tree() -> void:
	for w in _wires:
		var s: Signal = w[0]
		if s.is_connected(w[1]):
			s.disconnect(w[1])
	_wires.clear()


## Ev sahibi `size_scale`'i değiştirdikten sonra çağırır: satır yükseklikleri ve yazı
## boyları kuruluş anında hesaplanıyor, yani ölçek değişince ağaç yeniden kurulmalı.
func rebuild() -> void:
	if _font == null:
		return   # henüz _ready koşmadı; kurulum zaten doğru ölçekle yapılacak
	_build_tree()
	_repaint()


## Modeli yeniden türet ve boya. Ev sahipleri bunu ÇAĞIRMAZ (widget kendi dinler).
func refresh() -> void:
	var m = Model.new()
	_model = m if m.derive() else null
	_repaint()


func fingerprint() -> String:
	return "" if _model == null else _model.fingerprint()


## Harness çıktısı (call_group ile çağrılır; normal F5'te sessiz).
func debug_print() -> void:
	print("[BuildBar] path=%s rect=%s model=%s" % [
		str(get_path()), str(get_global_rect()), fingerprint()])


# --- Ağaç ---------------------------------------------------------------------

func _px(v: int) -> int:
	return int(round(float(v) * size_scale))


func _fs(v: int) -> int:
	return maxi(UiTokens.SIZE_MICRO, int(round(float(v) * size_scale)))


func _label(size_px: int, color: Color, bold: bool = false) -> Label:
	var l := Label.new()
	l.add_theme_font_override(&"font", _font)
	l.add_theme_font_size_override(&"font_size", size_px)
	l.add_theme_color_override(&"font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# clip_text KAPALI ve bu ÖLÇÜLDÜ: açıkken Label'ın asgari GENİŞLİĞİ sıfıra iner,
	# yani yanındaki esneyen boşluk bütün satırı yutuyor ve her yazı görünmez oluyordu.
	# Sözleşme de bunu yasaklıyor zaten: "dolgunun kenarı hiçbir yazıyı kesmez" —
	# kesilebilen bir yazı o sözü zaten veremez.
	l.clip_text = false
	l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	if bold:
		l.add_theme_constant_override(&"outline_size", 0)
	return l


func _glyph(name: String, px: int, color: Color) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(ICON_DIR + name + ".svg")
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.modulate = color
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return t


func _hairline() -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(0, 1)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.BG_AVATAR   # #1B232B — sayfanın satır kılı
	sb.anti_aliasing = false
	p.add_theme_stylebox_override(&"panel", sb)
	return p


func _build_tree() -> void:
	for c in get_children():
		c.queue_free()

	var shell := PanelContainer.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shell_sb := StyleBoxFlat.new()
	shell_sb.bg_color = UiTokens.BG_ART            # #10161C
	shell_sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	shell_sb.border_color = UiTokens.SURFACE_SUNKEN  # #232C34
	shell_sb.set_corner_radius_all(UiTokens.RADIUS_S)
	shell_sb.corner_radius_top_left = 0
	shell_sb.corner_radius_top_right = 0
	shell_sb.anti_aliasing = false
	shell.add_theme_stylebox_override(&"panel", shell_sb)
	add_child(shell)

	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 0)
	shell.add_child(col)

	# --- KAPAK ÇİZGİSİ. Ayrı bir Panel, çünkü StyleBoxFlat tek kenara ayrı RENK
	# veremez ve kapak çizgisi gövde kenarından FARKLI renktedir (2i: grubun durumu).
	_cap = Panel.new()
	_cap.custom_minimum_size = Vector2(0, _px(CAP_H))
	_cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_cap)

	col.add_child(_build_product_row())
	col.add_child(_hairline())
	col.add_child(_build_phase_row())
	col.add_child(_hairline())
	col.add_child(_build_decision_row())


func _build_product_row() -> Control:
	_product_row = HBoxContainer.new()
	_product_row.custom_minimum_size = Vector2(0, _px(ROW_PRODUCT_H))
	_product_row.add_theme_constant_override(&"separation", _px(GAP))
	_product_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pad := MarginContainer.new()
	pad.add_theme_constant_override(&"margin_left", _px(PAD_X))
	pad.add_theme_constant_override(&"margin_right", _px(PAD_X))
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(_product_row)
	# Monitör glifi HER DURUMDA amber (sayfanın üç karesinde de öyle) — ürün satırı
	# durumun taşıyıcısı değil, kimliğin taşıyıcısı.
	_product_row.add_child(_glyph("monitor", _px(16), UiTokens.ACCENT))
	_name_label = _label(_fs(13), UiTokens.INK)
	_product_row.add_child(_name_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_product_row.add_child(spacer)
	_busy_label = _label(_fs(10), UiTokens.INK_MUTED)
	_product_row.add_child(_busy_label)
	return pad


func _build_phase_row() -> Control:
	_phase_row = Control.new()
	_phase_row.custom_minimum_size = Vector2(0, _px(ROW_PHASE_H))
	_phase_row.clip_contents = true          # dolgu köşeden taşmasın
	_phase_row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# DOLGU: sola çapalı, genişliği YÜZDE. anchor_right kullanmak manuel yeniden
	# boyutlandırmayı tamamen kaldırıyor — kart genişleyince dolgu oranını korur.
	_fill = Panel.new()
	_fill.anchor_left = 0.0
	_fill.anchor_top = 0.0
	_fill.anchor_bottom = 1.0
	_fill.anchor_right = 0.0
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phase_row.add_child(_fill)

	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.add_theme_constant_override(&"margin_left", _px(PAD_X))
	pad.add_theme_constant_override(&"margin_right", _px(PAD_X))
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", _px(GAP))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(row)
	_phase_row.add_child(pad)

	_phase_icon = _glyph("phase_design", _px(15), UiTokens.ACCENT)
	row.add_child(_phase_icon)
	_phase_label = _label(_fs(12), UiTokens.ACCENT)
	row.add_child(_phase_label)
	# DURAKLAT GLİFİ: kutu yok, kenar yok, hover yok, düğme geometrisi yok (2i).
	# Sadece bir TextureRect — bu yüzden "basılabilir tek şey" kuralı bozulmuyor.
	_pause_glyph = _glyph("pause", _px(18), UiTokens.NEGATIVE)
	row.add_child(_pause_glyph)
	_work_label = _label(_fs(10), UiTokens.INK_MUTED)
	row.add_child(_work_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	_percent_label = _label(_fs(15), UiTokens.INK)
	row.add_child(_percent_label)
	return _phase_row


func _build_decision_row() -> Control:
	_decision_row = PanelContainer.new()
	_decision_row.custom_minimum_size = Vector2(0, _px(ROW_DECISION_H))
	_decision_row.mouse_filter = Control.MOUSE_FILTER_STOP   # KARTTAKİ TEK BASILABİLİR ŞEY
	_decision_row.gui_input.connect(_on_decision_input)
	_decision_row.mouse_entered.connect(_on_decision_hover.bind(true))
	_decision_row.mouse_exited.connect(_on_decision_hover.bind(false))
	var pad := MarginContainer.new()
	pad.add_theme_constant_override(&"margin_left", _px(PAD_X))
	pad.add_theme_constant_override(&"margin_right", _px(PAD_X))
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", _px(GAP))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(row)
	_decision_row.add_child(pad)
	_decision_icon = _glyph("decision", _px(13), UiTokens.ACCENT)
	row.add_child(_decision_icon)
	_decision_label = _label(_fs(11), UiTokens.ACCENT)
	row.add_child(_decision_label)
	return _decision_row


# --- Boyama -------------------------------------------------------------------

func _repaint() -> void:
	var live: bool = _model != null
	visible = live
	if not live:
		return
	var m = _model
	var cap_sb := StyleBoxFlat.new()
	cap_sb.bg_color = m.cap_color()
	cap_sb.anti_aliasing = false
	_cap.add_theme_stylebox_override(&"panel", cap_sb)

	_name_label.text = m.product_name
	_busy_label.text = tr(m.pause_note_key) if m.pause_note_key != "" else ""
	_busy_label.visible = m.pause_note_key != ""

	# DOLGU. Duraklamışta DÜZ donuk zemin; koşarken rampa renginin %13'ü. İki hâlin
	# de KENARI YOK: sınır renk değişiminin kendisi.
	var fill_sb := StyleBoxFlat.new()
	if m.paused:
		fill_sb.bg_color = UiTokens.BUILD_FILL_PAUSED
	elif m.phase == Model.PHASE_SUPPORT:
		fill_sb.bg_color = Color(UiTokens.POSITIVE, UiTokens.BUILD_SUPPORT_FILL_ALPHA)
	else:
		fill_sb.bg_color = Color(m.ramp_color(), UiTokens.BUILD_FILL_ALPHA)
	fill_sb.anti_aliasing = false
	_fill.add_theme_stylebox_override(&"panel", fill_sb)
	_fill.anchor_right = clampf(m.fill, 0.0, 1.0)

	var ink: Color = UiTokens.INK_MUTED if m.paused else m.ramp_color()
	_phase_icon.texture = load(ICON_DIR + _phase_glyph(m.phase) + ".svg")
	_phase_icon.modulate = ink
	_phase_label.text = UiTokens.tr_upper(tr(_phase_key(m.phase)))
	_phase_label.add_theme_color_override(&"font_color", ink)
	_pause_glyph.visible = m.paused
	_percent_label.text = tr("PROD_PERCENT").format({"n": m.percent})
	_percent_label.add_theme_color_override(&"font_color",
		UiTokens.INK_MUTED if m.paused else UiTokens.INK)
	# DESTEK'te ve beta parkında yüzde yok: dolacak bir şey yoksa sayı da yalan olurdu.
	_percent_label.visible = m.phase != Model.PHASE_SUPPORT or m.sprint_running

	_paint_workload(m)
	_paint_decision(m)


func _paint_workload(m) -> void:
	# 2i: "8 hata" ve "KALAN 6" kartta BAŞKA HİÇBİR YERDE olmayan iş yükü gerçekleri.
	var txt: String = ""
	var col: Color = UiTokens.CREAM_DIM
	match m.phase:
		Model.PHASE_DEVELOPMENT:
			if m.dev_bugs > 0:
				txt = tr("BUILD_DEV_BUGS").format({"n": m.dev_bugs})
				col = UiTokens.negative()
		Model.PHASE_BETA:
			txt = tr("BUILD_BETA_TRIPLET").format({
				"found": m.bugs_found, "fixed": m.bugs_fixed, "left": m.bugs_left})
		Model.PHASE_SUPPORT:
			# GELEN ÇİZİLMİYOR: motorda karşılığı yok ve uydurulmayacak (B4). Yeri
			# ayrıldı — sistem gelince bu dizgenin başına reflow olmadan iner.
			txt = tr("BUILD_SUPPORT_CONFIRMED").format({"n": m.live_bugs})
	_work_label.text = txt
	_work_label.visible = txt != ""
	_work_label.add_theme_color_override(&"font_color",
		UiTokens.INK_MUTED if m.paused else col)


func _paint_decision(m) -> void:
	# KOŞU SÜRERKEN DÜŞER (2i). Görünmezlik + STOP kalkışı birlikte: görünmeyen ama
	# tıklanabilir bir satır tam olarak process_mode tuzağının ikizidir.
	var shown: bool = m.decision_key != ""
	_decision_row.visible = shown
	_decision_row.mouse_filter = (Control.MOUSE_FILTER_STOP if shown
		else Control.MOUSE_FILTER_IGNORE)
	if not shown:
		return
	_decision_label.text = UiTokens.tr_upper(tr(m.decision_key))
	var on: bool = m.decision_enabled
	var tone: Color = UiTokens.ACCENT if on else UiTokens.INK_DIM
	_decision_icon.modulate = tone
	_decision_label.add_theme_color_override(&"font_color",
		UiTokens.INK if (_decision_hover and on) else tone)
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_WASH if (_decision_hover and on) else Color(0, 0, 0, 0)
	if _decision_hover and on:
		sb.border_width_left = 2
		sb.border_color = UiTokens.ACCENT
	sb.anti_aliasing = false
	_decision_row.add_theme_stylebox_override(&"panel", sb)


func _phase_key(phase: StringName) -> String:
	match phase:
		Model.PHASE_DESIGN: return "BUILD_PHASE_DESIGN"
		Model.PHASE_DEVELOPMENT: return "BUILD_PHASE_DEVELOPMENT"
		Model.PHASE_BETA: return "BUILD_PHASE_BETA"
		_: return "BUILD_PHASE_SUPPORT"


func _phase_glyph(phase: StringName) -> String:
	match phase:
		Model.PHASE_DESIGN: return "phase_design"
		Model.PHASE_DEVELOPMENT: return "phase_development"
		Model.PHASE_BETA: return "phase_beta"
		_: return "phase_support"


# --- Karar ---------------------------------------------------------------------

func _on_decision_hover(entered: bool) -> void:
	_decision_hover = entered
	if _model != null:
		_paint_decision(_model)


func _on_decision_input(ev: InputEvent) -> void:
	if _model == null or not _model.decision_enabled:
		return
	if not (ev is InputEventMouseButton):
		return
	var mb := ev as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	# WRITE-THROUGH: kart hiçbir alanı kendi yazmaz, sistemin seam'ini çağırır.
	match _model.phase:
		Model.PHASE_DESIGN: ProductSystem.enter_development()
		Model.PHASE_DEVELOPMENT: ProductSystem.enter_beta()
		Model.PHASE_BETA: ProductSystem.launch()
		Model.PHASE_SUPPORT: ProductSystem.start_bug_sprint()
	refresh()


# --- Yazı tipi -----------------------------------------------------------------

func _resolve_font() -> Font:
	# Proje teması → MicroLabel varyasyonunun mono yüzü (JetBrains Mono).
	# Theme.get_font varyasyon zincirini YÜRÜMEZ, o yüzden önce has_font.
	var th: Theme = ThemeDB.get_project_theme()
	if th != null:
		if th.has_font(&"font", &"MicroLabel"):
			return th.get_font(&"font", &"MicroLabel")
		if th.has_font(&"font", &"Label"):
			return th.get_font(&"font", &"Label")
	return get_theme_default_font()
