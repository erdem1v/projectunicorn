extends PanelContainer

# BuildBar — yüzen DESTEK kartı: yayındaki ürün ve tek açık hata sayısı.
#
# Satırlar, hepsi modelden:
#   başlık : ürünün adı ve sürümü; masadaki biri iki işteyse sağda bölünmüş odağın notu.
#   destek : DESTEK ve "N açık hata ›". Hata varken satır Ürün penceresini en çok hatası olan hattın alanı açık açar
#            (sürüklemeye değil tıklamaya ayrılmıştır); ipucu o hattı ve itibar hata yüzünden düştüyse sebebini
#            söyler. Hata yokken satır sönüktür, tıklanmaz ve ipucu yalnız itibar sebebini taşır.
# Sprint planlamada bir gün bekleyip liderin önerisiyle kendiliğinden başladıysa, o sprint sürdükçe
# altta bir not satırı.

const Model := preload("res://scripts/ui/components/build_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")
const PRODUCT_ICON := preload("res://assets/icons/rail/product.svg")
const SUPPORT_ICON := preload("res://assets/icons/util/shield.svg")
const CHEVRON_ICON := preload("res://assets/icons/util/chevron_right.svg")
const PLAY_ICON := preload("res://assets/icons/util/play.svg")

var _model = null

var _name_label: Label = null
var _busy_label: Label = null
var _support_row: PanelContainer = null
var _key_label: Label = null
var _bugs_label: Label = null
var _chevron: TextureRect = null
var _hot := false   # fare DESTEK satırının üstünde
var _auto_row: Control = null
var _auto_label: Label = null


func _ready() -> void:
	# ALWAYS: ağaç duraklıyken (oyuncu karar verirken) de kart canlı kalsın.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_tree()
	# Meşguliyet aynı karede okunsun: atama ya da eğitim değişimi bir sonraki oyun saatini
	# beklerse oyuncu bunu takılma diye okur.
	var r1: Callable = refresh.unbind(1)
	for s: Signal in [EventBus.build_phase_changed, EventBus.day_advanced, EventBus.language_changed,
			EventBus.assignment_changed]:
		s.connect(r1)
	# Destek'in saati bu sinyalden sonra işler: boyama ertelenmezse sayılar bir saat geride kalır.
	EventBus.build_progress_changed.connect(refresh, CONNECT_DEFERRED)
	EventBus.employee_training_changed.connect(refresh.unbind(2))
	EventBus.product_state_changed.connect(refresh)
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
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 0)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)

	var head := BarKit.line()
	_box(col, &"FloatHead").add_child(head)
	head.add_child(BarKit.glyph(PRODUCT_ICON, UiTokens.D_ICON_TITLE, UiTokens.D_INK_3))
	_name_label = BarKit.filler(&"FloatTitle")
	head.add_child(_name_label)
	_busy_label = UiFactory.make_label("", &"Caption")
	head.add_child(_busy_label)

	var support := BarKit.line()
	_support_row = _box(col, &"FloatRow")
	# İpucu için fareyi alır; tıklanmayan basış kartın sürüklemesine geçer.
	_support_row.mouse_filter = Control.MOUSE_FILTER_PASS
	_support_row.gui_input.connect(_on_support_input)
	_support_row.mouse_entered.connect(_set_hot.bind(true))
	_support_row.mouse_exited.connect(_set_hot.bind(false))
	_support_row.add_child(support)
	support.add_child(BarKit.glyph(SUPPORT_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	_key_label = UiFactory.make_label("", &"FloatKey")
	support.add_child(_key_label)
	_bugs_label = BarKit.filler(&"KeyText")
	support.add_child(_bugs_label)
	_chevron = BarKit.glyph(CHEVRON_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_3)
	support.add_child(_chevron)

	_auto_row = _box(col, &"FloatFoot")
	var auto := BarKit.line()
	_auto_row.add_child(auto)
	auto.add_child(BarKit.glyph(PLAY_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
	_auto_label = UiFactory.make_label("", &"MetaMuted")
	auto.add_child(_auto_label)


## Fareyi geçiren kutu; kartın boş yeri sürüklemeye kalır.
func _box(parent: Control, variation: StringName) -> PanelContainer:
	var box := PanelContainer.new()
	box.theme_type_variation = variation
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(box)
	return box


# --- Boyama -------------------------------------------------------------------

func _repaint() -> void:
	visible = _model != null
	if _model == null:
		return
	var m = _model
	_name_label.text = m.product_name
	_busy_label.text = tr(m.split_note_key)
	_busy_label.visible = m.split_note_key != ""
	_key_label.text = Fmt.upper(tr("BUILD_PHASE_SUPPORT"))
	_bugs_label.text = SprintUiShared.count("PRODUCT_BUG_COUNT", m.open_bugs)
	_bugs_label.theme_type_variation = &"KeyText" if m.open_bugs > 0 else &"KeyTextMuted"
	_chevron.visible = m.open_bugs > 0
	_support_row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if m.open_bugs > 0 else Control.CURSOR_ARROW
	_support_row.tooltip_text = _tip()
	_paint_hot()
	_auto_row.visible = SprintSystem.mode() == "active" \
		and int(GameState.product.get("auto_started", -1)) == SprintSystem.sprint_number()
	_auto_label.text = tr("PRODUCT_AUTO_STARTED")


# --- Satır ---------------------------------------------------------------------

## İpucu: en çok açık hatası olan hat; itibar hata yüzünden düştüyse sebebi.
func _tip() -> String:
	var lines := PackedStringArray()
	if _model.worst_line != "":
		lines.append(tr("BUILD_SUPPORT_TIP").format({"capability": SprintCatalog.cap_name(_model.worst_line)}))
	var note: String = SupportSystem.neglect_note()
	if note != "":
		lines.append(note)
	return "\n".join(lines)


func _set_hot(on: bool) -> void:
	_hot = on
	_paint_hot()


## Tıklanan satır üstüne gelince parlar.
func _paint_hot() -> void:
	var lit: bool = _hot and _model != null and _model.open_bugs > 0
	_chevron.modulate = UiTokens.D_INK_1 if lit else UiTokens.D_INK_3
	if lit:
		_bugs_label.add_theme_color_override(&"font_color", UiTokens.D_INK_1)
	else:
		_bugs_label.remove_theme_color_override(&"font_color")


func _on_support_input(ev: InputEvent) -> void:
	if _model.open_bugs > 0 and UiFactory.is_left_click(ev):
		accept_event()
		_open_product()


## Ürün penceresi, en çok hatası olan hattın alanı açık: önce sayfa açılır, sayfa kendi durumunu kurulurken modelden
## tohumlar.
func _open_product() -> void:
	EventBus.tab_changed.emit("product")
	get_tree().get_first_node_in_group(&"window_layer").get_current_page_body().open_area(_model.worst_area)
