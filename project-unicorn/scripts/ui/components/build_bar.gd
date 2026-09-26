extends Control

# BuildBar — onaylı Build Bar kartı. TEK renderer, üç ev sahibi: yüzen takip kartı, ODA
# monitörü ve Ürün sayfası aynı sahneyi (BuildBar.tscn) kurar. Monitördeki kart yeniden
# biçimlenmez, AYNI karttır (R6).
#
# Üç satır, hepsi modelden:
#   ürün  : hangi yapım (faz adı burada tekrar edilmez) + tek not etiketi.
#   faz   : satırın kendi zemini ilerlemedir, ayrı çubuk yok. Ad + iş yükü + yüzde.
#   karar : karttaki TEK basılabilir şey.
# Üstünde 2px kapak çizgisi: grubun durumu.
#
# Dolgu sınırında dikey çizgi yok: dolgu rampa renginin %13 alfası olduğu için sınırın iki
# yanındaki yazı aynı kontrastta okunur; çizgi sayaç dizgisini keserdi.
#
# Tur rakamı hiçbir yerde yazmaz; turu renk taşır (UiTokens.build_ramp).
#
# TEMA-BAĞIMSIZ, BİLEREK: boy ve renk UiTokens'tan, yazı tipi proje temasından (BarKit).
# ODA alt ağacı kendi dondurulmuş temasını çözer; varyasyona uzanan kart monitörde farklı
# düşerdi.
#
# PROCESS_MODE_ALWAYS: ağaç duraklıyken de gui_input dağıtılsın. INHERIT'te kart çizilir ama
# her tıklamayı yutar.

const Model := preload("res://scripts/ui/components/build_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")

const PHASE_KEYS := {
	Model.PHASE_DESIGN: "BUILD_PHASE_DESIGN",
	Model.PHASE_DEVELOPMENT: "BUILD_PHASE_DEVELOPMENT",
	Model.PHASE_BETA: "BUILD_PHASE_BETA",
	Model.PHASE_SUPPORT: "BUILD_PHASE_SUPPORT",
}

# Onaylı sayfanın ölçüleri (360px tracker).
const CAP_H := 2
const ROW_PRODUCT_H := 44
const ROW_PHASE_H := 48
const ROW_DECISION_H := 44
const PAD_X := 12
const GAP := 10

## Ev sahibi kartı büyütebilir (Ürün sayfası, ODA monitörü). 1.0 = onaylı tracker boyu.
@export var size_scale: float = 1.0

var _model = null
var _font: Font = null

var _cap: Panel = null
var _name_label: Label = null
var _busy_label: Label = null
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS   # karar satırı tıklanabilir; kart kendisi değil
	add_to_group(&"build_bar")
	_font = BarKit.resolve_font(self)
	_build_tree()
	# Meşguliyet aynı karede okunsun: atama ya da eğitim değişimi bir sonraki oyun saatini
	# beklerse oyuncu bunu takılma diye okur.
	var r1: Callable = refresh.unbind(1)
	for s: Signal in [EventBus.build_phase_changed, EventBus.build_iteration_decision_pending,
			EventBus.day_advanced, EventBus.language_changed, EventBus.assignment_changed,
			EventBus.palette_changed]:
		s.connect(r1)
	EventBus.build_progress_changed.connect(refresh)
	EventBus.employee_training_changed.connect(refresh.unbind(2))
	refresh()


## Ev sahibi `size_scale`'i değiştirdikten sonra çağırır: satır yükseklikleri ve yazı boyları
## kuruluşta hesaplanır.
func rebuild() -> void:
	if _font == null:
		return   # _ready henüz koşmadı; kurulum zaten doğru ölçekle yapılacak
	_build_tree()
	_repaint()


## Modeli yeniden türet ve boya. Ev sahipleri bunu çağırmaz; widget kendi dinler.
func refresh() -> void:
	var m = Model.new()
	_model = m if m.derive() else null
	_repaint()


func fingerprint() -> String:
	return "" if _model == null else _model.fingerprint()


## Harness çıktısı (main.gd `call_group` ile çağırır).
func debug_print() -> void:
	print("[BuildBar] path=%s rect=%s model=%s" % [
		str(get_path()), str(get_global_rect()), fingerprint()])


# --- Ağaç ---------------------------------------------------------------------

func _px(v: int) -> int:
	return int(round(float(v) * size_scale))


func _fs(v: int) -> int:
	return maxi(UiTokens.SIZE_MICRO, _px(v))


func _build_tree() -> void:
	for c in get_children():
		c.queue_free()

	var shell := PanelContainer.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shell_sb := StyleBoxFlat.new()
	shell_sb.bg_color = UiTokens.BG_ART              # #10161C
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

	_cap = BarKit.cap(_px(CAP_H))
	col.add_child(_cap)

	# Ürün satırı. Monitör glifi her durumda amber: satır durumu değil kimliği taşır.
	var product: HBoxContainer = _padded_row(col)
	product.custom_minimum_size = Vector2(0, _px(ROW_PRODUCT_H))
	product.add_child(BarKit.glyph("monitor", _px(16), UiTokens.ACCENT))
	_name_label = BarKit.label(_font, _fs(13), UiTokens.INK)
	product.add_child(_name_label)
	product.add_child(_spacer())
	_busy_label = BarKit.label(_font, _fs(10), UiTokens.INK_MUTED)
	product.add_child(_busy_label)
	col.add_child(BarKit.hairline())

	# Faz satırı. Dolgu sola çapalı ve genişliği anchor_right'tır: kart genişleyince oranı
	# kendiliğinden korur.
	var phase_row := Control.new()
	phase_row.custom_minimum_size = Vector2(0, _px(ROW_PHASE_H))
	phase_row.clip_contents = true
	phase_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(phase_row)
	_fill = Panel.new()
	_fill.anchor_bottom = 1.0
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	phase_row.add_child(_fill)
	var phase: HBoxContainer = _padded_row(phase_row)
	(phase.get_parent() as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phase_icon = BarKit.glyph("phase_design", _px(15), UiTokens.ACCENT)
	phase.add_child(_phase_icon)
	_phase_label = BarKit.label(_font, _fs(12), UiTokens.ACCENT)
	phase.add_child(_phase_label)
	# Duraklat glifi yalnız bir TextureRect: kutu, kenar, hover yok — "basılabilir tek şey"
	# kuralı bozulmuyor.
	_pause_glyph = BarKit.glyph("pause", _px(18), UiTokens.negative())
	phase.add_child(_pause_glyph)
	_work_label = BarKit.label(_font, _fs(10), UiTokens.INK_MUTED)
	phase.add_child(_work_label)
	phase.add_child(_spacer())
	_percent_label = BarKit.label(_font, _fs(15), UiTokens.INK)
	phase.add_child(_percent_label)
	col.add_child(BarKit.hairline())

	# Karar satırı: karttaki tek basılabilir şey.
	_decision_row = PanelContainer.new()
	_decision_row.custom_minimum_size = Vector2(0, _px(ROW_DECISION_H))
	_decision_row.mouse_filter = Control.MOUSE_FILTER_STOP
	_decision_row.gui_input.connect(_on_decision_input)
	_decision_row.mouse_entered.connect(_on_decision_hover.bind(true))
	_decision_row.mouse_exited.connect(_on_decision_hover.bind(false))
	col.add_child(_decision_row)
	var decision: HBoxContainer = _padded_row(_decision_row)
	_decision_icon = BarKit.glyph("decision", _px(13), UiTokens.ACCENT)
	decision.add_child(_decision_icon)
	_decision_label = BarKit.label(_font, _fs(11), UiTokens.ACCENT)
	decision.add_child(_decision_label)


## Yatay dolgulu satır: dolgu `parent`'a eklenir, içerik kutusu döner.
func _padded_row(parent: Control) -> HBoxContainer:
	var pad := MarginContainer.new()
	pad.add_theme_constant_override(&"margin_left", _px(PAD_X))
	pad.add_theme_constant_override(&"margin_right", _px(PAD_X))
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(pad)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", _px(GAP))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(row)
	return row


func _spacer() -> Control:
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


# --- Boyama -------------------------------------------------------------------

func _repaint() -> void:
	visible = _model != null
	if _model == null:
		return
	var m = _model
	BarKit.paint_cap(_cap, m.cap_color())
	_name_label.text = m.product_name

	# Tek not etiketi, üç kanal: 360px kartta ikinci bir etiket ürün adını ezer. Öncelik
	# DURAKLAMA (bar duruyor) > BÖLÜNME (bar yarı hızda) > LİDER YOK (bar akıyor, çarpan 1,0).
	var note_key: String = m.pause_note_key
	if note_key == "":
		note_key = m.split_note_key
	if note_key == "":
		note_key = m.lead_note_key
	_busy_label.text = tr(note_key) if note_key != "" else ""
	_busy_label.visible = note_key != ""

	# Dolgu: duraklamışta düz donuk zemin, koşarken rampa renginin soluk hâli. Kenarı yok;
	# sınır renk değişiminin kendisi.
	var fill_sb := StyleBoxFlat.new()
	var alpha: float = UiTokens.BUILD_SUPPORT_FILL_ALPHA if m.phase == Model.PHASE_SUPPORT \
		else UiTokens.BUILD_FILL_ALPHA
	fill_sb.bg_color = UiTokens.BUILD_FILL_PAUSED if m.paused else Color(m.ramp_color(), alpha)
	fill_sb.anti_aliasing = false
	_fill.add_theme_stylebox_override(&"panel", fill_sb)
	_fill.anchor_right = clampf(m.fill, 0.0, 1.0)

	var ink: Color = UiTokens.INK_MUTED if m.paused else m.ramp_color()
	_phase_icon.texture = load(BarKit.ICON_DIR + "phase_%s.svg" % m.phase)
	_phase_icon.modulate = ink
	_phase_label.text = UiTokens.tr_upper(tr(PHASE_KEYS[m.phase]))
	_phase_label.add_theme_color_override(&"font_color", ink)
	# §2 — glif yalnız MANUEL duraklamada; oto-duraklama not cümlesiyle konuşur, ikisi bir
	# arada görünmez.
	_pause_glyph.visible = m.pause_kind == ProductSystem.PAUSE_MANUAL
	_pause_glyph.modulate = UiTokens.negative()
	# Yüzde yok: hat modelinin BETA'sında (§7, mühürlü) ve DESTEK'te koşu yokken — dolacak bir
	# şey yoksa sayı da yalan olurdu.
	_percent_label.text = tr("PROD_PERCENT").format({"n": m.percent})
	_percent_label.add_theme_color_override(&"font_color",
		UiTokens.INK_MUTED if m.paused else UiTokens.INK)
	_percent_label.visible = m.show_percent and (m.phase != Model.PHASE_SUPPORT or m.sprint_running)

	# İş yükü: "8 hata" ve BETA sayaçları kartta başka hiçbir yerde olmayan gerçekler.
	var work: String = ""
	var work_col: Color = UiTokens.CREAM_DIM
	match m.phase:
		Model.PHASE_DEVELOPMENT:
			if m.dev_bugs > 0:
				work = tr("BUILD_DEV_BUGS").format({"n": m.dev_bugs})
				work_col = UiTokens.negative()
		Model.PHASE_BETA:
			work = tr("BUILD_BETA_TRIPLET").format({
				"found": m.bugs_found, "fixed": m.bugs_fixed, "left": m.bugs_left})
		Model.PHASE_SUPPORT:
			# GELEN çizilmez: motorda karşılığı yok.
			work = tr("BUILD_SUPPORT_CONFIRMED").format({"n": m.live_bugs})
	_work_label.text = work
	_work_label.visible = work != ""
	_work_label.add_theme_color_override(&"font_color",
		UiTokens.INK_MUTED if m.paused else work_col)

	_paint_decision(m)


func _paint_decision(m) -> void:
	_decision_label.text = UiTokens.tr_upper(tr(m.decision_key))
	_decision_row.tooltip_text = m.decision_tooltip
	var on: bool = m.decision_enabled
	var hot: bool = on and _decision_hover
	# El imleci yalnız satır canlıyken: ölü satırın üstündeki el, ok imlecinin söylemediği
	# bir şeyi vaat eder.
	_decision_row.mouse_default_cursor_shape = (Control.CURSOR_POINTING_HAND if on
		else Control.CURSOR_ARROW)
	var tone: Color = UiTokens.ACCENT if on else UiTokens.INK_DIM
	_decision_icon.modulate = tone
	_decision_label.add_theme_color_override(&"font_color", UiTokens.INK if hot else tone)
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_WASH if hot else Color(0, 0, 0, 0)
	if hot:
		sb.border_width_left = 2
		sb.border_color = UiTokens.ACCENT
	sb.anti_aliasing = false
	_decision_row.add_theme_stylebox_override(&"panel", sb)


# --- Karar ---------------------------------------------------------------------

func _on_decision_hover(entered: bool) -> void:
	_decision_hover = entered
	if _model != null:
		_paint_decision(_model)


func _on_decision_input(ev: InputEvent) -> void:
	var mb := ev as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if _model == null or not _model.decision_enabled:
		return
	# WRITE-THROUGH: kart hiçbir alanı kendi yazmaz, sistemin seam'ini çağırır.
	match _model.phase:
		Model.PHASE_DESIGN: ProductSystem.enter_development()
		Model.PHASE_DEVELOPMENT: ProductSystem.enter_beta()
		# BETA'nın aksiyonu yayın AKIŞIDIR (§10 · S7): v1'de fiyat + altyapı + onay, v2+'da
		# tek onay. `launch()`u akışın onay adımı çağırır.
		Model.PHASE_BETA: PublishFlow.open()
		# §8.4 — DESTEK'in aksiyonu düzeltme koşusudur ve iki yönlüdür: yoksa başlatır,
		# sürüyorsa bitirir.
		Model.PHASE_SUPPORT:
			if ProductState.fix_run_active():
				SupportSystem.end_fix_run()
			else:
				SupportSystem.start_fix_run()
	refresh()
