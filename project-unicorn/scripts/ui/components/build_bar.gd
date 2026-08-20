extends Control

# BuildBar — Software Inc. segment grameri (2026-08-19). TEK renderer, ÜÇ ev sahibi:
# BuildHUD kartı, Product sekmesindeki tracker kartı ve ODA monitörünün build yüzü aynı
# sahneyi (BuildBar.tscn) kurar; piksel piksel aynı widget, ev sahibinin boyuna ölçeklenir.
#
#   TASARIM   : TEK çubuk — koşan turun dolumuyla dolar, tur bitince BOŞALIR, sonraki
#               turla yeniden dolar (Software Inc. tasarım çubuğu; yönetmen kararı
#               2026-08-19: tur sınırları hücre olarak ÇİZİLMEZ, tur sayısı yazıdır).
#               Altında mono: "Tur 2" (tavanda "Tur 4 · son") + "bu tur +1 · kalan 4".
#   GELİŞTİRME: tek çubuk (bant içi dolum) + "Geliştirme · ~N gün" (parkta "hazır").
#   BETA      : tek çubuk ki hatalar çözüldükçe BOŞALIR (kalan/başlangıç) + "HATA 12" çipi.
#
# Model TÜRETİLMİŞTİR (build_bar_model.gd) ve widget onu KENDİ çeker: EventBus'ın build
# sinyallerine burada bir kez bağlanır; ev sahipleri hiçbir şey itmez, dolayısıyla
# birbirinden kopamaz (smoke build_bar_hosts_agree bunu ölçer). Ev sahibi yalnız
# genişlik/yükseklik verir; segment yüksekliği ve yazı boyu buradan türer.
#
# Tema-bağımsız: hiç çocuk düğüm yok, her şey _draw'da; renkler UiTokens'tan (palet
# tablosu), yazı tipi PROJE temasından (ThemeDB) — get_theme_font DEĞİL, çünkü ODA alt
# ağacı kendi dondurulmuş temasını çözer ve monitördeki bar HUD'dakinden farklı düşerdi.
# UI/STYLE LAW: state'e bağlı stil UiTokens helper'larından okunur; runtime StyleBoxFlat
# siteleri docs/design/theme_sweep_ledger.md §A'da envanterlidir (bu dosya eklendi).
#
# Godot kavramı: custom-drawn Control — _draw() CanvasItem çizim API'siyle boyar,
# queue_redraw() durum değişince geçersiz kılar (segment_bar.gd / cash_curve.gd deseni).
# class_name YOK (bkz. build_bar_model.gd başlığı) — ev sahipleri sahneyi preload eder.

const Model := preload("res://scripts/ui/components/build_bar_model.gd")

const LINE_GAP := 4         # çubuk ile ilk yazı satırı arası (UiTokens.SPACE_XS ile aynı)
const CHIP_PAD_X := 6       # UiTokens.PAD_CHIP.x
const CHIP_PAD_Y := 2       # UiTokens.PAD_CHIP.y

var _model = null           # build_bar_model instance ya da null (bar'a değmeyen durum)
var _font: Font = null
var _sb_fill: StyleBoxFlat = null
var _sb_empty: StyleBoxFlat = null
var _sb_chip_neg: StyleBoxFlat = null
var _sb_chip_pos: StyleBoxFlat = null
# Bağlantılar bir kez kurulur ve AYNI callable'larla sökülür (arity: refresh() argsız,
# sinyallerin çoğu 1 argümanlı → unbind(1); product_tab._signal_map deseni).
var _wires: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group(&"build_bar")
	_font = _resolve_font()
	_build_styles()
	var r1: Callable = refresh.unbind(1)
	_wires = [
		[EventBus.build_progress_changed, Callable(self, "refresh")],
		[EventBus.build_phase_changed, r1],
		[EventBus.build_iteration_decision_pending, r1],
		[EventBus.day_advanced, r1],
		[EventBus.language_changed, r1],
		[EventBus.palette_changed, Callable(self, "_on_palette_changed")],
	]
	for w in _wires:
		(w[0] as Signal).connect(w[1])
	resized.connect(queue_redraw)
	refresh()


func _exit_tree() -> void:
	for w in _wires:
		var s: Signal = w[0]
		if s.is_connected(w[1]):
			s.disconnect(w[1])
	_wires.clear()


func _on_palette_changed(_cb: bool) -> void:
	_build_styles()
	refresh()


## Modeli yeniden türet ve boya. Ev sahipleri bunu ÇAĞIRMAZ (widget kendi dinler);
## public kalması harness/smoke içindir.
func refresh() -> void:
	var m = Model.new()
	_model = m if m.derive() else null
	queue_redraw()


func get_model():
	return _model


## Son TÜRETİLMİŞ modelin parmak izi (yeniden türetmez — smoke bununla ev sahiplerinin
## aynı tick'te aynı durumu gösterdiğini ölçer; bayat bir bar burada yakalanır).
func fingerprint() -> String:
	return "" if _model == null else _model.fingerprint()


## Harness çıktısı (call_group ile çağrılır; kendi kendine basmaz — normal F5'te sessiz).
func debug_print() -> void:
	print("[BuildBar] path=%s rect=%s model=%s" % [str(get_path()), str(get_global_rect()), fingerprint()])


# --- Stil / yazı tipi ---------------------------------------------------------

func _resolve_font() -> Font:
	# Proje teması → MicroLabel varyasyonunun mono yüzü (mono_label, JetBrains Mono).
	# Theme.get_font varyasyon zincirini YÜRÜMEZ, o yüzden önce has_font.
	var th: Theme = ThemeDB.get_project_theme()
	if th != null:
		if th.has_font(&"font", &"MicroLabel"):
			return th.get_font(&"font", &"MicroLabel")
		if th.has_font(&"font", &"Label"):
			return th.get_font(&"font", &"Label")
	return get_theme_default_font()


func _build_styles() -> void:
	# Terminal reçetesi: yalnız amber vurgu, kıl çizgiler, radius 2, gradyan yok.
	# Kenar yumuşatma KAPALI: 8-10px'lik çubuklarda AA kıl çizgiyi bulanıklaştırır.
	_sb_fill = StyleBoxFlat.new()
	_sb_fill.bg_color = UiTokens.ACCENT
	_sb_fill.set_corner_radius_all(UiTokens.RADIUS_S)
	_sb_fill.anti_aliasing = false
	_sb_empty = StyleBoxFlat.new()
	_sb_empty.bg_color = Color.TRANSPARENT
	_sb_empty.border_color = UiTokens.BORDER_HOVER
	_sb_empty.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	_sb_empty.set_corner_radius_all(UiTokens.RADIUS_S)
	_sb_empty.anti_aliasing = false
	_sb_chip_neg = _chip_box(UiTokens.negative_bg(), UiTokens.negative_rule())
	_sb_chip_pos = _chip_box(UiTokens.positive_bg(), UiTokens.positive_rule())


func _chip_box(bg: Color, rule: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = rule
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.anti_aliasing = false
	return sb


# --- Ölçek: her şey kendi size'ından türer ----------------------------------

func _font_px() -> int:
	# TERMINAL merdiveninden, tabanı SIZE_MICRO (9 = OdaLayout.MIN_READABLE_FONT_PX):
	# ev sahibi ne kadar dar olursa olsun yazı 9'un altına inmez, satır düşer.
	if size.y >= 48.0:
		return UiTokens.SIZE_SMALL
	if size.y >= 36.0:
		return UiTokens.SIZE_META
	return UiTokens.SIZE_MICRO


func _bar_h() -> int:
	return 10 if size.y >= 40.0 else 8


# --- Çizim --------------------------------------------------------------------

func _draw() -> void:
	if _model == null or _font == null:
		return
	var w: int = int(floor(size.x))
	if w < 8:
		return
	var bar_h: int = _bar_h()
	var fs: int = _font_px()
	# Satır adımı glif tabanlı (fs + 4), Font.get_height DEĞİL: tema yüzü sembol fallback'iyle
	# sarılı ve metrik yüksekliği 10px'te 18 bildiriyor — gerçek mürekkep ~11px. Adım 14,
	# 44px'lik ev sahibinde iki satırı (tur + kazanç) taşır; 28px'te tek satıra düşer.
	var line_h: int = fs + 4
	var m = _model
	match m.phase:
		Model.PHASE_DESIGN:
			# Tek çubuk, her turda yeniden dolar; tavan parkında round_progress zaten 1.0.
			_draw_track(Rect2(0, 0, w, bar_h), m.round_progress)
			var l1: String
			if m.at_cap:
				l1 = tr("BUILD_ROUND_LAST").format({"n": m.round_index})
			else:
				l1 = tr("BUILD_ROUND_OF").format({"n": m.round_index})
			var l2: String = ""
			if m.show_gain:
				l2 = tr("BUILD_GAIN_LINE").format({"gain": m.gain, "left": m.gain_left})
			_draw_caption_lines(w, bar_h, fs, line_h, l1, l2)
		Model.PHASE_DEVELOPMENT:
			_draw_track(Rect2(0, 0, w, bar_h), m.phase_progress)
			var l1: String
			if m.dev_parked:
				l1 = tr("BUILD_DEV_READY")
			else:
				l1 = tr("BUILD_DEV_LINE").format({"days": m.dev_days_left})
				if m.half_speed:
					l1 += tr("PROD_HALF_SPEED")
			_draw_caption_lines(w, bar_h, fs, line_h, l1, "")
		Model.PHASE_BETA:
			_draw_track(Rect2(0, 0, w, bar_h), m.beta_fill())
			_draw_bug_chip(bar_h, fs, line_h, m.bugs_remaining)


func _draw_track(r: Rect2i, fill: float) -> void:
	draw_style_box(_sb_empty, r)
	var fw: int = int(floor(float(r.size.x) * clampf(fill, 0.0, 1.0)))
	if fw >= 1:
		draw_style_box(_sb_fill, Rect2(r.position.x, r.position.y, fw, r.size.y))


func _draw_caption_lines(w: int, bar_h: int, fs: int, line_h: int, l1: String, l2: String) -> void:
	# İki satır sığıyorsa alt alta; sığmıyorsa tek satıra " · " ile birleşir; o da
	# sığmıyorsa ikinci satır DÜŞER (monitör camı kuralı — yazı asla küçülmez).
	var y1: int = bar_h + LINE_GAP
	var two_lines: bool = l2 != "" and float(y1 + line_h + fs + 2) <= size.y
	if l2 != "" and not two_lines:
		var joined: String = l1 + " · " + l2
		if _font.get_string_size(joined, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= float(w):
			l1 = joined
		l2 = ""
	var asc: float = _font.get_ascent(fs)
	draw_string(_font, Vector2(0.0, round(float(y1) + asc)), l1,
		HORIZONTAL_ALIGNMENT_LEFT, float(w), fs, UiTokens.INK)
	if two_lines:
		draw_string(_font, Vector2(0.0, round(float(y1 + line_h) + asc)), l2,
			HORIZONTAL_ALIGNMENT_LEFT, float(w), fs, UiTokens.INK_MUTED)


func _draw_bug_chip(bar_h: int, fs: int, line_h: int, bugs: int) -> void:
	# Negatif tonlu durum çipi ("HATA 12"); sıfırda pozitif ton (WORKING — çip aynı,
	# semantik çift UiTokens accessor'larından, renk körü paleti dahil).
	var text: String = tr("BUILD_BETA_BUGS_CHIP").format({"n": bugs})
	var tw: float = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var cw: int = int(ceil(tw)) + CHIP_PAD_X * 2
	var ch: int = line_h + CHIP_PAD_Y * 2
	var y: int = bar_h + LINE_GAP
	var neg: bool = bugs > 0
	draw_style_box(_sb_chip_neg if neg else _sb_chip_pos, Rect2(0, y, cw, ch))
	var col: Color = UiTokens.negative() if neg else UiTokens.positive()
	draw_string(_font, Vector2(float(CHIP_PAD_X), round(float(y + CHIP_PAD_Y) + _font.get_ascent(fs))),
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
