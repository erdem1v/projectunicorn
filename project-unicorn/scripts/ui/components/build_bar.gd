extends PanelContainer

# BuildBar — yüzen DESTEK kartı: yayındaki ürün, doğrulanmış hatalar ve düzeltme koşusu.
#
# Satırlar, hepsi modelden:
#   başlık : ürünün adı ve sürümü; masadaki biri iki işteyse sağda bölünmüş odağın notu.
#   destek : DESTEK ve doğrulanmış hatalar; koşu sürerken sağda yüzde, altında ilerleme.
#   eylem  : karttaki TEK basılabilir şey, koşuyu başlatır ya da bitirir; kapalıyken gerekçesi
#            yanında.
# Sprint planlamada bir gün bekleyip liderin önerisiyle kendiliğinden başladıysa, o sprint sürdükçe
# altta bir not satırı.
#
# PROCESS_MODE_ALWAYS: ağaç duraklıyken de eylem çalışsın. INHERIT'te kart çizilir ama her
# tıklamayı yutar.

const Model := preload("res://scripts/ui/components/build_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")
const PRODUCT_ICON := preload("res://assets/icons/rail/product.svg")
const SUPPORT_ICON := preload("res://assets/icons/util/shield.svg")
const PLAY_ICON := preload("res://assets/icons/util/play.svg")
const END_ICON := preload("res://assets/icons/util/pause.svg")

var _model = null

var _name_label: Label = null
var _busy_label: Label = null
var _key_label: Label = null
var _confirmed_label: Label = null
var _percent_label: Label = null
var _progress: ProgressBar = null
var _action: Button = null
var _refusal_label: Label = null
var _auto_row: Control = null
var _auto_label: Label = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_tree()
	# Meşguliyet aynı karede okunsun: atama ya da eğitim değişimi bir sonraki oyun saatini
	# beklerse oyuncu bunu takılma diye okur.
	var r1: Callable = refresh.unbind(1)
	for s: Signal in [EventBus.build_phase_changed, EventBus.day_advanced, EventBus.language_changed,
			EventBus.assignment_changed]:
		s.connect(r1)
	EventBus.build_progress_changed.connect(refresh)
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

	# Destek satırı; ilerleme yalnız koşu sürerken, satırın altında.
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box(col, &"FloatRow").add_child(stack)
	var support := BarKit.line()
	stack.add_child(support)
	support.add_child(BarKit.glyph(SUPPORT_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	_key_label = UiFactory.make_label("", &"FloatKey")
	support.add_child(_key_label)
	_confirmed_label = UiFactory.make_label("", &"MetaMuted")
	_confirmed_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	support.add_child(_confirmed_label)
	_percent_label = UiFactory.make_label("", &"KeyText")
	support.add_child(_percent_label)
	_progress = ProgressBar.new()
	_progress.show_percentage = false
	_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(_progress)

	var action_box := MarginContainer.new()
	action_box.add_theme_constant_override(&"margin_left", UiTokens.SPACE_M)
	action_box.add_theme_constant_override(&"margin_top", UiTokens.SPACE_M)
	action_box.add_theme_constant_override(&"margin_right", UiTokens.SPACE_L)
	action_box.add_theme_constant_override(&"margin_bottom", UiTokens.SPACE_M)
	action_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(action_box)
	var action := BarKit.line()
	action_box.add_child(action)
	# Odak yok: game_shell Space'i hız tuşu olarak okur.
	_action = Button.new()
	_action.theme_type_variation = &"FloatAction"
	_action.focus_mode = Control.FOCUS_NONE
	_action.pressed.connect(_on_action)
	action.add_child(_action)
	_refusal_label = UiFactory.make_label("", &"Caption")
	action.add_child(_refusal_label)

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
	# GELEN çizilmez: motorda karşılığı yok.
	_confirmed_label.text = tr("BUILD_SUPPORT_CONFIRMED").format({"n": m.live_bugs})
	# Yüzde ve ilerleme yalnız koşu sürerken: dolacak bir şey yoksa sayı da yalan olurdu.
	_percent_label.text = tr("PROD_PERCENT").format({"n": m.percent})
	_percent_label.visible = m.fix_run_active
	_progress.value = m.percent
	_progress.visible = m.fix_run_active
	_action.text = tr(m.decision_key)
	_action.icon = END_ICON if m.fix_run_active else PLAY_ICON
	_action.disabled = not m.decision_enabled
	_refusal_label.text = tr(m.refusal_key)
	_refusal_label.visible = m.refusal_key != ""
	_auto_row.visible = SprintSystem.mode() == "active" \
		and int(GameState.product.get("auto_started", -1)) == SprintSystem.sprint_number()
	_auto_label.text = tr("PRODUCT_AUTO_STARTED")


# --- Eylem ---------------------------------------------------------------------

## §8.4 — düzeltme koşusu iki yönlüdür: yoksa başlatır, sürüyorsa bitirir. WRITE-THROUGH: kart
## hiçbir alanı kendi yazmaz, sistemin seam'ini çağırır.
func _on_action() -> void:
	if ProductState.fix_run_active():
		SupportSystem.end_fix_run()
	else:
		SupportSystem.start_fix_run()
	refresh()
