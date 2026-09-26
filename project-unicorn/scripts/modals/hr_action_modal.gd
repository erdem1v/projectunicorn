extends Control

# İK EYLEM MODALI — ZAM YAP / TERFİ (slider'lı) · İŞTEN ÇIKAR (slider'sız), tek kabuk.
#
# ConfirmModal değil: tek autowrap etiketi, üç kayıt türünü (delta / olgu / kural) giysiyle
# ayıramaz, yalnız sıfırı geçen değeri kırmızıya çeviremez, slider taşıyamaz. Yaşam döngüsü ve
# host ConfirmModal ile ortak: `EventBus.confirm_requested` + `main.gd::_on_confirm_requested`,
# config'te `"modal": "hr_action"`. Tek onay, saati durdurma ve ESC = vazgeç orada.
#
# Yazı yüzleri ve boyutları doğrudan override: temada mono + SIZE_DATA + semibold varyasyon
# yok. Renkler ve boyutlar yine token'dan.

signal confirmed
signal dismissed

const FONT_MONO := preload("res://assets/fonts/variations/mono_reg.tres")
const FONT_MONO_SB := preload("res://assets/fonts/variations/mono_sb.tres")
const FONT_SANS_IT := preload("res://assets/fonts/variations/sans_it.tres")

const ARROW := "→"
const PAUSE_GLYPH := "⏸"

@onready var _dimmer: ColorRect = $Dimmer
@onready var _title: Label = %TitleLabel
@onready var _rule_top: Panel = %TitleRule
@onready var _slider_box: VBoxContainer = %SliderBox
@onready var _slider_pad: Control = %SliderPad
@onready var _pct_label: Label = %PctLabel
@onready var _rows: VBoxContainer = %RowsBox
@onready var _cancel_btn: Button = %CancelBtn
@onready var _commit_btn: Button = %CommitBtn

var _preview: Callable = Callable()     # (int) -> Dictionary
var _commit: Callable = Callable()      # (int) -> bool
var _commit_key: String = ""
var _slider: ValueSlider = null


func _ready() -> void:
	_dimmer.color = UiTokens.SCRIM_MODAL
	var rule := StyleBoxFlat.new()
	rule.bg_color = UiTokens.DIVIDER_LIGHT
	_rule_top.add_theme_stylebox_override("panel", rule)
	# Yüzde okunuşu: mono semibold, kehribar. Tasarımın 30px'i merdivende SIZE_ED_HEADLINE'a iner.
	_pct_label.add_theme_font_override("font", FONT_MONO_SB)
	_pct_label.add_theme_font_size_override("font_size", UiTokens.SIZE_ED_HEADLINE)
	_pct_label.add_theme_color_override("font_color", UiTokens.ACCENT)
	_cancel_btn.pressed.connect(_close)
	_commit_btn.pressed.connect(_on_commit)
	_cancel_btn.grab_focus()   # varsayılan odak güvenli tarafta


## Sözleşme:
##   {title, on_commit: Callable(int)->bool,
##    slider: {min, max, start}, preview: Callable(int)->Dictionary, commit_key   # slider'lı hâl
##    rows: Array, commit_text}                                                   # slider'sız hâl
func populate(cfg: Dictionary) -> void:
	_title.text = String(cfg.get("title", ""))
	_commit_key = String(cfg.get("commit_key", ""))
	_commit = cfg.get("on_commit", Callable())
	_preview = cfg.get("preview", Callable())
	# Alt bar versal: CSV cümleyi normal taşır, versalı dizim ekler (`tr_upper` i/İ'yi bilir).
	_cancel_btn.text = UiTokens.tr_upper(tr("UI_DISMISS"))

	var slider_cfg: Dictionary = cfg.get("slider", {})
	_slider_box.visible = not slider_cfg.is_empty()
	_slider_pad.visible = _slider_box.visible
	if _slider_box.visible:
		_slider = ValueSlider.new()
		_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_slider_box.add_child(_slider)
		_slider.setup(int(slider_cfg["min"]), int(slider_cfg["max"]), int(slider_cfg["start"]))
		# Değer rayın üstünde bir kez okunur; düğmedeki tekrar bir eylem adıdır.
		_paint(_slider.value)
		_slider.value_changed.connect(_paint)
	else:
		_render_rows(cfg.get("rows", []))
		_commit_btn.text = UiTokens.tr_upper(String(cfg.get("commit_text", "")))


func _paint(pct: int) -> void:
	# Önizlemenin tamamı motordan gelir; burada sayı hesaplanmaz.
	var pv: Dictionary = _preview.call(pct) as Dictionary
	var shown: int = int(pv.get("pct", pct))
	_pct_label.text = Fmt.percent(shown, 0)
	_render_rows(pv.get("rows", []))
	if _commit_key != "":
		_commit_btn.text = UiTokens.tr_upper(
			tr(_commit_key).format({"pct": Fmt.percent(shown, 0)}))


func _render_rows(rows: Array) -> void:
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	for r in rows:
		var row: Dictionary = r
		match String(row.get("kind", "")):
			"delta":
				# Sıfırı geçen değerde kırmızı olan YALNIZ sonuçtur; engel yok, bir bilgidir.
				var negative: bool = bool(row.get("negative_after", false))
				var after_color: Color = UiTokens.NEGATIVE if negative else UiTokens.INK
				_rows.add_child(_value_row(row, [
					_mono(String(row.get("before", "")), UiTokens.CREAM_DIM),
					_mono(ARROW, UiTokens.INK_DIM),
					_mono(String(row.get("after", "")), after_color, true)]))
			"fact":
				# Olgunun "önce"si yoktur; ok çizmek olmayan bir geçişi iddia ederdi.
				_rows.add_child(_value_row(row, [_mono(String(row.get("value", "")), UiTokens.INK)]))
			"rule":
				_rows.add_child(_rule_row(row))


# --- Üç kayıt türü ----------------------------------------------------------
# Aralarında başlık yok; ayrım giysiyle: deltanın oku var, olgunun yok, kuralın sayısı yok
# ve yüzü eğik.

func _mono(text: String, color: Color, semibold: bool = false) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", FONT_MONO_SB if semibold else FONT_MONO)
	lbl.add_theme_font_size_override("font_size", UiTokens.SIZE_DATA)
	lbl.add_theme_color_override("font_color", color)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl


## Etiket · esneyen boşluk · değer hücreleri · (varsa) not.
func _value_row(row: Dictionary, cells: Array) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_mono(String(row.get("label", "")), UiTokens.CREAM_DIM))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(spacer)
	for cell in cells:
		box.add_child(cell)
	var note: String = String(row.get("note", ""))
	if note != "":
		box.add_child(_mono(note, UiTokens.INK_DIM))
	return box


func _rule_row(row: Dictionary) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bool(row.get("pause", false)):
		var glyph := Label.new()
		glyph.text = PAUSE_GLYPH
		glyph.add_theme_font_size_override("font_size", UiTokens.SIZE_DATA)
		glyph.add_theme_color_override("font_color", UiTokens.NEGATIVE)
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(glyph)
	var lbl := Label.new()
	lbl.text = String(row.get("text", ""))
	# Sayısı olmayan tek kayıt türü, tek eğik yüz.
	lbl.add_theme_font_override("font", FONT_SANS_IT)
	lbl.add_theme_font_size_override("font_size", UiTokens.SIZE_DATA)
	lbl.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(lbl)
	return box


func _on_commit() -> void:
	var arg: int = _slider.value if _slider != null else 0
	if not _commit.call(arg):
		return   # motor reddettiyse modal açık kalır; sessiz kapanma yalan olurdu
	confirmed.emit()
	dismissed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
