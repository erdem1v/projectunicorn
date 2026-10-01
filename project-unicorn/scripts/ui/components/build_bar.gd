extends Control

# BuildBar — yüzen DESTEK kartı: yayındaki ürün, doğrulanmış hatalar ve düzeltme koşusu.
#
# Üç satır, hepsi modelden:
#   ürün  : hangi ürün ve sürüm + tek not etiketi.
#   faz   : satırın kendi zemini koşunun ilerlemesidir, ayrı çubuk yok. Ad + iş yükü + yüzde.
#   karar : karttaki TEK basılabilir şey.
# Üstünde 2px kapak çizgisi: grubun durumu.
#
# Dolgu sınırında dikey çizgi yok: dolgu rengin %13 alfası olduğu için sınırın iki yanındaki
# yazı aynı kontrastta okunur; çizgi sayaç dizgisini keserdi.
#
# TEMA-BAĞIMSIZ, BİLEREK: boy ve renk UiTokens'tan, yazı tipi proje temasından (BarKit).
#
# PROCESS_MODE_ALWAYS: ağaç duraklıyken de gui_input dağıtılsın. INHERIT'te kart çizilir ama
# her tıklamayı yutar.

const Model := preload("res://scripts/ui/components/build_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")

const CAP_H := 2
const ROW_PRODUCT_H := 44
const ROW_PHASE_H := 48
const ROW_DECISION_H := 44
const PAD_X := 12
const GAP := 10
const MONITOR_PX := 16
const PHASE_PX := 15
const DECISION_PX := 13

var _model = null
var _font: Font = null

var _cap: Panel = null
var _name_label: Label = null
var _busy_label: Label = null
var _fill: Panel = null
var _phase_icon: TextureRect = null
var _phase_label: Label = null
var _work_label: Label = null
var _percent_label: Label = null
var _decision_row: PanelContainer = null
var _decision_icon: TextureRect = null
var _decision_label: Label = null
var _decision_hover := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS   # karar satırı tıklanabilir; kart kendisi değil
	_font = BarKit.resolve_font(self)
	_build_tree()
	# Meşguliyet aynı karede okunsun: atama ya da eğitim değişimi bir sonraki oyun saatini
	# beklerse oyuncu bunu takılma diye okur.
	var r1: Callable = refresh.unbind(1)
	for s: Signal in [EventBus.build_phase_changed, EventBus.day_advanced, EventBus.language_changed,
			EventBus.assignment_changed, EventBus.palette_changed]:
		s.connect(r1)
	EventBus.build_progress_changed.connect(refresh)
	EventBus.employee_training_changed.connect(refresh.unbind(2))
	refresh()


## Modeli yeniden türet ve boya. Ev sahibi bunu çağırmaz; widget kendi dinler.
func refresh() -> void:
	var m = Model.new()
	_model = m if m.derive() else null
	_repaint()


func fingerprint() -> String:
	return "" if _model == null else _model.fingerprint()


# --- Ağaç ---------------------------------------------------------------------

func _build_tree() -> void:
	var shell := PanelContainer.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shell_sb := StyleBoxFlat.new()
	shell_sb.bg_color = UiTokens.CARD_BG
	shell_sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	shell_sb.border_color = UiTokens.CARD_BORDER
	shell_sb.set_corner_radius_all(UiTokens.RADIUS_S)
	shell_sb.corner_radius_top_left = 0
	shell_sb.corner_radius_top_right = 0
	shell_sb.anti_aliasing = false
	shell.add_theme_stylebox_override(&"panel", shell_sb)
	add_child(shell)

	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 0)
	shell.add_child(col)

	_cap = BarKit.cap(CAP_H)
	col.add_child(_cap)

	# Ürün satırı. Monitör glifi her durumda amber: satır durumu değil kimliği taşır.
	var product: HBoxContainer = _padded_row(col)
	product.custom_minimum_size = Vector2(0, ROW_PRODUCT_H)
	product.add_child(BarKit.glyph("monitor", MONITOR_PX, UiTokens.ACCENT_DEEP))
	_name_label = BarKit.label(_font, UiTokens.SIZE_BODY, UiTokens.INK)
	product.add_child(_name_label)
	product.add_child(_spacer())
	_busy_label = BarKit.label(_font, UiTokens.SIZE_META, UiTokens.INK_MUTED)
	product.add_child(_busy_label)
	col.add_child(BarKit.hairline())

	# Faz satırı. Dolgu sola çapalı ve genişliği anchor_right'tır: kart genişleyince oranı
	# kendiliğinden korur.
	var phase_row := Control.new()
	phase_row.custom_minimum_size = Vector2(0, ROW_PHASE_H)
	phase_row.clip_contents = true
	phase_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(phase_row)
	_fill = Panel.new()
	_fill.anchor_bottom = 1.0
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	phase_row.add_child(_fill)
	var phase: HBoxContainer = _padded_row(phase_row)
	(phase.get_parent() as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phase_icon = BarKit.glyph("phase_support", PHASE_PX, UiTokens.positive())
	phase.add_child(_phase_icon)
	_phase_label = BarKit.label(_font, UiTokens.SIZE_DATA, UiTokens.positive())
	phase.add_child(_phase_label)
	_work_label = BarKit.label(_font, UiTokens.SIZE_META, UiTokens.INK_DIM)
	phase.add_child(_work_label)
	phase.add_child(_spacer())
	_percent_label = BarKit.label(_font, UiTokens.SIZE_LEAD, UiTokens.INK)
	phase.add_child(_percent_label)
	col.add_child(BarKit.hairline())

	# Karar satırı: karttaki tek basılabilir şey.
	_decision_row = PanelContainer.new()
	_decision_row.custom_minimum_size = Vector2(0, ROW_DECISION_H)
	_decision_row.mouse_filter = Control.MOUSE_FILTER_STOP
	_decision_row.gui_input.connect(_on_decision_input)
	_decision_row.mouse_entered.connect(_on_decision_hover.bind(true))
	_decision_row.mouse_exited.connect(_on_decision_hover.bind(false))
	col.add_child(_decision_row)
	var decision: HBoxContainer = _padded_row(_decision_row)
	_decision_icon = BarKit.glyph("decision", DECISION_PX, UiTokens.ACCENT_DEEP)
	decision.add_child(_decision_icon)
	_decision_label = BarKit.label(_font, UiTokens.SIZE_SMALL, UiTokens.ACCENT_DEEP)
	decision.add_child(_decision_label)


## Yatay dolgulu satır: dolgu `parent`'a eklenir, içerik kutusu döner.
func _padded_row(parent: Control) -> HBoxContainer:
	var pad := MarginContainer.new()
	pad.add_theme_constant_override(&"margin_left", PAD_X)
	pad.add_theme_constant_override(&"margin_right", PAD_X)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(pad)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
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
	# Yeşil palete bağlı (CB modu): her boyamada yeniden okunur.
	var tone: Color = UiTokens.positive()
	BarKit.paint_cap(_cap, tone)
	_name_label.text = m.product_name
	_busy_label.text = tr(m.split_note_key) if m.split_note_key != "" else ""
	_busy_label.visible = m.split_note_key != ""
	var fill_sb := StyleBoxFlat.new()
	fill_sb.bg_color = Color(tone, UiTokens.BUILD_SUPPORT_FILL_ALPHA)
	fill_sb.anti_aliasing = false
	_fill.add_theme_stylebox_override(&"panel", fill_sb)
	_fill.anchor_right = clampf(m.fill, 0.0, 1.0)
	_phase_icon.modulate = tone
	_phase_label.text = UiTokens.tr_upper(tr("BUILD_PHASE_SUPPORT"))
	_phase_label.add_theme_color_override(&"font_color", tone)
	# Yüzde yalnız koşu sürerken: dolacak bir şey yoksa sayı da yalan olurdu.
	_percent_label.text = tr("PROD_PERCENT").format({"n": m.percent})
	_percent_label.visible = m.fix_run_active
	# GELEN çizilmez: motorda karşılığı yok.
	_work_label.text = tr("BUILD_SUPPORT_CONFIRMED").format({"n": m.live_bugs})
	_paint_decision(m)


func _paint_decision(m) -> void:
	_decision_label.text = UiTokens.tr_upper(tr(m.decision_key))
	var on: bool = m.decision_enabled
	var hot: bool = on and _decision_hover
	# El imleci yalnız satır canlıyken: ölü satırın üstündeki el, ok imlecinin söylemediği
	# bir şeyi vaat eder.
	_decision_row.mouse_default_cursor_shape = (Control.CURSOR_POINTING_HAND if on
		else Control.CURSOR_ARROW)
	var tone: Color = UiTokens.ACCENT_DEEP if on else UiTokens.INK_DIM
	_decision_icon.modulate = tone
	_decision_label.add_theme_color_override(&"font_color", UiTokens.INK if hot else tone)
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_WASH if hot else Color.TRANSPARENT
	if hot:
		sb.border_width_left = 2
		sb.border_color = UiTokens.ACCENT_DEEP
	sb.anti_aliasing = false
	_decision_row.add_theme_stylebox_override(&"panel", sb)


# --- Karar ---------------------------------------------------------------------

func _on_decision_hover(entered: bool) -> void:
	_decision_hover = entered
	if _model != null:
		_paint_decision(_model)


## §8.4 — düzeltme koşusu iki yönlüdür: yoksa başlatır, sürüyorsa bitirir. WRITE-THROUGH: kart
## hiçbir alanı kendi yazmaz, sistemin seam'ini çağırır.
func _on_decision_input(ev: InputEvent) -> void:
	if not UiFactory.is_left_click(ev) or _model == null or not _model.decision_enabled:
		return
	if ProductState.fix_run_active():
		SupportSystem.end_fix_run()
	else:
		SupportSystem.start_fix_run()
	refresh()
