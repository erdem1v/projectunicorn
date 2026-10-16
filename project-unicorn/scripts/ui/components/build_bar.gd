extends PanelContainer

# BuildBar — yüzen DESTEK kartı: yayındaki ürün, doğrulanmış hatalar ve gelen bildirimler.
#
# Satırlar, hepsi modelden:
#   başlık : ürünün adı ve sürümü; masadaki biri iki işteyse sağda bölünmüş odağın notu.
#   destek : DESTEK, doğrulanmış hatalar ve gelen bildirimler.
# Sprint planlamada bir gün bekleyip liderin önerisiyle kendiliğinden başladıysa, o sprint sürdükçe
# altta bir not satırı.

const Model := preload("res://scripts/ui/components/build_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")
const PRODUCT_ICON := preload("res://assets/icons/rail/product.svg")
const SUPPORT_ICON := preload("res://assets/icons/util/shield.svg")
const PLAY_ICON := preload("res://assets/icons/util/play.svg")

var _model = null

var _name_label: Label = null
var _busy_label: Label = null
var _key_label: Label = null
var _confirmed_label: Label = null
var _incoming_label: Label = null
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
	_box(col, &"FloatRow").add_child(support)
	support.add_child(BarKit.glyph(SUPPORT_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	_key_label = UiFactory.make_label("", &"FloatKey")
	support.add_child(_key_label)
	_confirmed_label = UiFactory.make_label("", &"MetaMuted")
	support.add_child(_confirmed_label)
	_incoming_label = UiFactory.make_label("", &"MetaMuted")
	support.add_child(_incoming_label)

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
	_confirmed_label.text = tr("BUILD_SUPPORT_CONFIRMED").format({"n": m.live_bugs})
	_incoming_label.text = tr("BUILD_SUPPORT_INCOMING").format({"n": m.incoming})
	_auto_row.visible = SprintSystem.mode() == "active" \
		and int(GameState.product.get("auto_started", -1)) == SprintSystem.sprint_number()
	_auto_label.text = tr("PRODUCT_AUTO_STARTED")

