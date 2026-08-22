extends Control

# İK EYLEM MODALI — onaylı "HR Modals" sayfası (1a · 1b · 1e).
# İki eylem, tek kabuk: ZAM YAP (slider'lı) · İŞTEN ÇIKAR (slider'sız).
#
# ────────────────────────────────────────────────────────────────────────────
# NEDEN ConfirmModal DEĞİL
# ────────────────────────────────────────────────────────────────────────────
# `ConfirmModal` sabit 440×220 bir panel ve gövdesi TEK autowrap `BodyLabel`;
# çağıran ona `"\n".join(lines)` veriyor. Onaylı sayfa ise ÜÇ farklı kayıt türünü
# birbirinden GİYSİYLE ayırıyor (delta / olgu / kural), sonucu farklı ağırlıkta
# diziyor, nakit sıfırı geçtiğinde YALNIZ o değeri kırmızıya çeviriyor ve zamda
# bir slider taşıyor. Tek etikete akıtılmış bir metinde bunların hiçbiri seçilemez.
# ConfirmModal genişletilmedi çünkü genişletilseydi yedi mevcut çağıranın hepsi
# yeni bir sözleşmeyi taşımak zorunda kalırdı.
#
# YAŞAM DÖNGÜSÜ ConfirmModal'DAN KOPYALANDI ve host'u da onunla PAYLAŞIYOR:
# `EventBus.confirm_requested` + `main.gd::_on_confirm_requested`. Config'e
# `"modal": "hr_action"` konulduğunda main bu sahneyi mount ediyor. Böylece
# "aynı anda tek onay", saati durdurma, kapanınca hızı geri verme ve ESC = vazgeç
# İKİNCİ KEZ YAZILMADI — o davranışların tek evi var.
#
# ────────────────────────────────────────────────────────────────────────────
# GODOT KAVRAMI — theme_type_variation vs. doğrudan override
# ────────────────────────────────────────────────────────────────────────────
# Normalde bir Control görünümünü `theme_type_variation` ile temadan çözer
# (UI/STYLE LAW md.4). Burada yazı YÜZLERİ ve BOYUTLARI doğrudan override ile
# takılıyor ve bu bilinçli bir istisna:
#
#   · Sayfa mono gövdeyi 12px'te (SIZE_DATA) ve sonucu 700 ağırlıkta istiyor;
#     temada mono+SIZE_DATA+semibold bir varyasyon YOK. Yenisini eklemek
#     `build_theme.gd`'ye dokunmak, yani THEME_STAMP 6→7 ve `master_theme.tres`
#     regen'i demek — bu turun kapılarından biri tam olarak o dosyanın
#     BAYT-AYNI kalması.
#   · Kural kaydının eğik sans yüzü zaten aynı gerekçeyle türetildi (H3,
#     `assets/fonts/variations/sans_it.tres`) ve o dosya tema tarafından okunmuyor.
#
# Yani burada override, kuralın delinmesi değil, kuralın İKİNCİ maddesinin
# (üretilmiş artefakta dokunma) korunması. RENKLER VE BOYUTLAR YİNE TOKEN'DAN:
# aşağıda tek bir ham `Color(...)` ya da merdiven dışı sayı yok.

signal confirmed
signal dismissed

const FONT_MONO := preload("res://assets/fonts/variations/mono_reg.tres")
const FONT_MONO_SB := preload("res://assets/fonts/variations/mono_sb.tres")
const FONT_SANS_IT := preload("res://assets/fonts/variations/sans_it.tres")

# --- Onaylı ölçüler (sayfa 1a) ---------------------------------------------
const SHELL_W := 420
# Boşluklar (14 / 16 / 11 / 22) sahnede Control dolgusu ve VBox separation'ı
# olarak duruyor — yerleşim sahnenin hakkı (UI/STYLE LAW md.4).
const ARROW := "→"
const PAUSE_GLYPH := "⏸"

@onready var _dimmer: ColorRect = $Dimmer
@onready var _panel: PanelContainer = %Shell
@onready var _title: Label = %TitleLabel
@onready var _rule_top: Panel = %TitleRule
@onready var _slider_box: VBoxContainer = %SliderBox
@onready var _slider_pad: Control = %SliderPad
@onready var _pct_label: Label = %PctLabel
@onready var _rows: VBoxContainer = %RowsBox
@onready var _cancel_btn: Button = %CancelBtn
@onready var _commit_btn: Button = %CommitBtn

var _preview: Callable = Callable()     # (int) -> Dictionary  · zam için
var _commit: Callable = Callable()      # (int) -> bool
var _commit_key: String = ""
var _slider: ValueSlider = null


func _ready() -> void:
	_dimmer.color = UiTokens.SCRIM_MODAL
	_panel.custom_minimum_size = Vector2(SHELL_W, 0)
	_title.theme_type_variation = &"ModalTitleSerif"
	var rule := StyleBoxFlat.new()
	rule.bg_color = UiTokens.DIVIDER_LIGHT
	_rule_top.add_theme_stylebox_override("panel", rule)
	# Yüzde okunuşu: mono semibold, kehribar, 32px. Merdiven 30 taşımıyor;
	# SIZE_ED_HEADLINE onun BELGELİ inişi (ui_tokens.gd:433 "display 30 rounds here").
	_pct_label.add_theme_font_override("font", FONT_MONO_SB)
	_pct_label.add_theme_font_size_override("font_size", UiTokens.SIZE_ED_HEADLINE)
	_pct_label.add_theme_color_override("font_color", UiTokens.ACCENT)
	_cancel_btn.pressed.connect(_close)
	_commit_btn.pressed.connect(_on_commit)
	_cancel_btn.grab_focus()   # varsayılan odak GÜVENLİ tarafta (ConfirmModal kuralı)


## Sözleşme:
##   {title, commit_text, on_commit: Callable(int)->bool,
##    preview: Callable(int)->Dictionary,   # slider'lı hâl
##    rows: Array,                          # slider'sız hâl (tek atış önizleme)
##    slider: {min, max, start}}            # yoksa slider çizilmez
func populate(cfg: Dictionary) -> void:
	_title.text = String(cfg.get("title", ""))
	_commit_key = String(cfg.get("commit_key", ""))
	_commit = cfg.get("on_commit", Callable())
	_preview = cfg.get("preview", Callable())
	# ALT BAR TAMAMEN VERSAL (sayfa 1a): VAZGEÇ ve işlem düğmesi aynı kaydı konuşuyor.
	# Çevirmen cümleyi normal yazıyor, versalı DİZİM ekliyor — CSV'ye BAĞIRAN bir
	# değer koymak çeviriyi bir yerleşim kararına bağlardı. `tr_upper` Türkçenin
	# i/İ tuzağını bilen tek büyükharf yolu.
	_cancel_btn.text = UiTokens.tr_upper(tr("UI_DISMISS"))

	var slider_cfg: Dictionary = cfg.get("slider", {})
	_slider_box.visible = not slider_cfg.is_empty()
	_slider_pad.visible = _slider_box.visible   # dolgu slider'la birlikte yaşar
	if _slider_box.visible:
		_slider = ValueSlider.new()
		_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_slider_box.add_child(_slider)
		_slider.setup(int(slider_cfg["min"]), int(slider_cfg["max"]), int(slider_cfg["start"]))
		# DEĞER TEK YERDE (sayfa 1b): rayın üstünde, ortalanmış, 32px kehribar.
		# Eski popover onu ÜÇ yerde tekrarlıyordu (etiket + düğme + satır metni);
		# düğmedeki tekrar KALIYOR çünkü o bir eylem adı, tutamacın altındaki
		# ikinci etiket ise hiç doğmadı.
		_paint(_slider.value)
		_slider.value_changed.connect(_paint)
	else:
		_render_rows(cfg.get("rows", []))
		_commit_btn.text = UiTokens.tr_upper(String(cfg.get("commit_text", "")))


func _paint(pct: int) -> void:
	# Önizlemenin TAMAMI motordan gelir; bu fonksiyon hiçbir sayı hesaplamaz.
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
			"delta": _rows.add_child(_delta_row(row))
			"fact": _rows.add_child(_fact_row(row))
			"rule": _rows.add_child(_rule_row(row))


# --- Üç kayıt türü ----------------------------------------------------------
# Aralarında BAŞLIK yok (sayfa: "no headers"). Ayrım yalnız giysiyle: deltanın oku
# var, olgunun yok, kuralın sayısı yok ve yüzü eğik. Bir okuyucu üç satırı yan yana
# gördüğünde hangisinin bir GEÇİŞ hangisinin bir DURUM olduğunu okumadan anlar.

func _mono(text: String, color: Color, semibold: bool = false) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", FONT_MONO_SB if semibold else FONT_MONO)
	lbl.add_theme_font_size_override("font_size", UiTokens.SIZE_DATA)
	lbl.add_theme_color_override("font_color", color)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl


func _value_row(label_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_mono(label_text, UiTokens.CREAM_DIM))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	return row


func _delta_row(row: Dictionary) -> Control:
	var box: HBoxContainer = _value_row(String(row.get("label", "")))
	box.add_child(_mono(String(row.get("before", "")), UiTokens.CREAM_DIM))
	box.add_child(_mono(ARROW, UiTokens.INK_DIM))
	# SIFIRI GEÇEN DEĞER (A2): kırmızı olan YALNIZ sonuç. Pankart yok, düğme
	# etiketi aynı, engel yok — motor `can_fire`'da karşılanabilirliğe zaten
	# bakmıyor, yani kart bir uyarı değil bir BİLGİ veriyor.
	var negative: bool = bool(row.get("negative_after", false))
	box.add_child(_mono(String(row.get("after", "")),
		UiTokens.NEGATIVE if negative else UiTokens.INK, true))
	var note: String = String(row.get("note", ""))
	if note != "":
		box.add_child(_mono(note, UiTokens.INK_DIM))
	return box


func _fact_row(row: Dictionary) -> Control:
	var box: HBoxContainer = _value_row(String(row.get("label", "")))
	# OK YOK. Bir olgunun "önce"si yoktur; ok çizmek olmayan bir geçişi iddia eder.
	box.add_child(_mono(String(row.get("value", "")), UiTokens.INK))
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
	# EĞİK SANS (H3): sayısı olmayan tek kayıt türü, tek eğik yüz. Mono gövdenin
	# yanında bu tek başına yeterli bir ayrım — sayfa buna ayrıca başlık koymuyor.
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
	if _commit.is_valid() and not _commit.call(arg):
		return   # motor reddettiyse modal AÇIK kalır; sessiz kapanma yalan olurdu
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
