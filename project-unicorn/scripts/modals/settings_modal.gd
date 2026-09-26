extends Control

# Ayarlar paneli — altı bölüm (GÖRÜNTÜ · SES · OYUN · DİL · ERİŞİLEBİLİRLİK · VERİ)
# kaydırılabilir bir gövdede.
#
# main.gd GameShell/ModalLayer'a mount eder, panel kendini `dismissed` ile serbest
# bırakır. Kök process_mode = ALWAYS: ağaç durdurulmuşken de etkileşimli kalır ve ESC alır.
#
# Kontroller CANLI (Uygula butonu yok): her domain sistemi kendi değerini uygular ve
# Settings'e yazar; Settings yazımı debounce eder, sürükleme diski dövmez.
#
# YERLEŞİM sahnede, İÇERİK burada: satırlar (etiket · boşluk · kontrol) tek bir
# yardımcıdan üretilir ve yalnız theme_type_variation taşır (UI/STYLE LAW kural 4).

signal dismissed

const DisplaySettingsLib := preload("res://scripts/systems/display_settings.gd")

const AUTOSAVE_IDS: Array[String] = ["off", "daily", "weekly", "monthly"]
const AUTOSAVE_KEYS: Array[String] = [
	"SET_AUTOSAVE_OFF", "SET_AUTOSAVE_DAILY", "SET_AUTOSAVE_WEEKLY", "SET_AUTOSAVE_MONTHLY"]
const LANG_KEYS: Array[String] = ["LANG_TR", "LANG_EN"]   # Localization.SUPPORTED sırasıyla

const KEY_AUTOSAVE := "autosave_frequency"
const KEY_COLORBLIND := "colorblind_palette"

# Bölüm başlıkları CSV'de doğal yazımda durur ve _retranslate'te büyütülür.
const HEADER_KEYS := {
	"%DisplayHeader": "SET_SEC_DISPLAY",
	"%AudioHeader": "SET_SEC_AUDIO",
	"%GameHeader": "SET_SEC_GAME",
	"%LanguageHeader": "SETTINGS_LANGUAGE",
	"%AccessibilityHeader": "SET_SEC_ACCESSIBILITY",
	"%DataHeader": "SET_SEC_DATA",
}

# Satır geometrisi (YERLEŞİM — bu dosyanın sahip olduğu tek sayı ailesi).
const ROW_SEP := 12
const CONTROL_W := 230
const SLIDER_W := 170
const PCT_W := 44

@onready var _title: Label = %TitleLabel
@onready var _close_btn: Button = %CloseBtn
@onready var _display_body: VBoxContainer = %DisplayBody
@onready var _audio_body: VBoxContainer = %AudioBody
@onready var _game_body: VBoxContainer = %GameBody
@onready var _lang_label: Label = %LangLabel
@onready var _lang_option: OptionButton = %LanguageOption
@onready var _a11y_body: VBoxContainer = %AccessibilityBody
@onready var _data_body: VBoxContainer = %DataBody

var _mode_option: OptionButton
var _res_option: OptionButton
var _res_list: Array[Vector2i] = []
var _res_note: Label
var _scale_option: OptionButton
var _vsync_toggle: CheckButton
var _master_slider: HSlider
var _music_toggle: CheckButton
var _music_slider: HSlider
var _sfx_slider: HSlider
var _mute_toggle: CheckButton
var _autosave_option: OptionButton
var _cb_toggle: CheckButton

var _pct_labels: Dictionary = {}   # HSlider → yüzde Label'ı
# Etiket/buton → çeviri anahtarı: dil seçimi CANLI kontroldür, metinler yerinde tazelenir.
var _label_keys: Dictionary = {}


func _ready() -> void:
	_build_display_section()
	_build_audio_section()
	_build_game_section()
	_build_language_section()
	_build_accessibility_section()
	_build_data_section()
	_sync_from_state()
	_retranslate()
	_close_btn.pressed.connect(_close)
	_close_btn.grab_focus()


# =============================================================================
# Kurulum
# =============================================================================

func _build_display_section() -> void:
	_mode_option = _dropdown(DisplaySettingsLib.MODE_ORDER.size())
	_mode_option.item_selected.connect(_on_window_mode_selected)
	_add_row(_display_body, "SET_WINDOW_MODE", _mode_option)

	_res_option = _dropdown(0)
	_res_option.item_selected.connect(func(idx: int) -> void:
		DisplaySettingsLib.set_resolution(_res_list[idx])
		_refresh_scale_options())
	_add_row(_display_body, "SET_RESOLUTION", _res_option)
	_res_note = _note_label("SET_RESOLUTION_LOCKED")
	_display_body.add_child(_res_note)

	_scale_option = _dropdown(DisplaySettingsLib.UI_SCALE_STEPS.size())
	_scale_option.item_selected.connect(func(idx: int) -> void:
		DisplaySettingsLib.set_ui_scale(DisplaySettingsLib.UI_SCALE_STEPS[idx])
		_refresh_scale_options())   # motor kırptıysa seçim de onu göstersin
	_add_row(_display_body, "SET_UI_SCALE", _scale_option)

	_vsync_toggle = _switch()
	_vsync_toggle.toggled.connect(func(on: bool) -> void: DisplaySettingsLib.set_vsync(on))
	_add_row(_display_body, "SET_VSYNC", _vsync_toggle)


func _build_audio_section() -> void:
	_master_slider = _add_volume_row("SET_VOL_MASTER", AudioManager.set_master_volume)

	_music_toggle = _switch()
	_music_toggle.toggled.connect(func(on: bool) -> void:
		AudioManager.set_music_enabled(on)
		_music_slider.editable = on)   # müzik kapalıyken seviye kontrolü sönükleşir
	_add_row(_audio_body, "SET_MUSIC_ENABLED", _music_toggle)

	_music_slider = _add_volume_row("SET_VOL_MUSIC", AudioManager.set_music_volume)
	_sfx_slider = _add_volume_row("SET_VOL_SFX", AudioManager.set_sfx_volume)

	_mute_toggle = _switch()
	_mute_toggle.toggled.connect(AudioManager.set_mute_unfocused)
	_add_row(_audio_body, "SET_MUTE_UNFOCUSED", _mute_toggle)


func _build_game_section() -> void:
	_autosave_option = _dropdown(AUTOSAVE_IDS.size())
	_autosave_option.item_selected.connect(func(idx: int) -> void:
		Settings.set_value(KEY_AUTOSAVE, AUTOSAVE_IDS[idx]))
	_add_row(_game_body, "SET_AUTOSAVE", _autosave_option)


func _build_language_section() -> void:
	_lang_option.get_popup().theme_type_variation = &"SettingsPopup"
	for i in LANG_KEYS.size():
		_lang_option.add_item("", i)
	_lang_option.item_selected.connect(func(idx: int) -> void:
		Localization.set_language(Localization.SUPPORTED[idx])
		_retranslate()
		_refresh_resolution_row())   # "(doğal)" işareti de çevrilir


func _build_accessibility_section() -> void:
	_cb_toggle = _switch()
	_cb_toggle.toggled.connect(_on_colorblind_toggled)
	_add_row(_a11y_body, "SET_COLORBLIND", _cb_toggle)
	_a11y_body.add_child(_note_label("SET_COLORBLIND_NOTE"))


func _build_data_section() -> void:
	for entry in [["SET_OPEN_SAVE_FOLDER", _on_open_save_folder], ["SET_RESET_DEFAULTS", _on_reset_pressed]]:
		var b := Button.new()
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		b.pressed.connect(entry[1])
		_data_body.add_child(b)
		_label_keys[b] = entry[0]


# =============================================================================
# Tepkiler
# =============================================================================

func _on_window_mode_selected(idx: int) -> void:
	DisplaySettingsLib.set_window_mode(DisplaySettingsLib.MODE_ORDER[idx])
	# Mod GEÇERLİ çözünürlüğü de değiştirir (tam ekranda native, pencerelide saklanan tercih).
	_refresh_resolution_row()
	_refresh_scale_options()


func _on_colorblind_toggled(on: bool) -> void:
	# Semantik renk master_theme.tres'e pişmediği için bu saf bir çalışma zamanı
	# takasıdır: token'ı çevir, canlı yüzeylere haber ver.
	UiTokens.set_colorblind(on)
	Settings.set_value(KEY_COLORBLIND, on)
	EventBus.palette_changed.emit(on)


func _on_open_save_folder() -> void:
	# Hiç kayıt alınmadıysa klasör yoktur ve dosya yöneticisi sessizce hiçbir şey yapmaz.
	var path: String = ProjectSettings.globalize_path(SaveManager.SAVE_DIR)
	DirAccess.make_dir_recursive_absolute(path)
	OS.shell_show_in_file_manager(path)


func _on_reset_pressed() -> void:
	EventBus.confirm_requested.emit({
		"title": tr("SET_RESET_CONFIRM_TITLE"),
		"body": tr("SET_RESET_CONFIRM_BODY"),
		"confirm_text": UiTokens.tr_upper(tr("SET_RESET_CONFIRM_OK")),
		"cancel_text": UiTokens.tr_upper(tr("SET_RESET_CONFIRM_CANCEL")),
		"on_confirm": _apply_reset,
	})


func _apply_reset() -> void:
	Settings.reset_to_defaults()   # DEFAULTS anahtarları; dil ve tur bayrağı DOKUNULMAZ
	EventBus.palette_changed.emit(UiTokens.is_colorblind())
	_sync_from_state()


# =============================================================================
# Durum → kontroller
# =============================================================================

## Her kontrolü canlı durumdan tohumla (açılışta ve sıfırlamadan sonra; panel açık kalır).
func _sync_from_state() -> void:
	_mode_option.select(DisplaySettingsLib.MODE_ORDER.find(DisplaySettingsLib.get_window_mode()))
	_refresh_resolution_row()   # sıfırlama çözünürlük anahtarlarını SİLER: liste yeniden tespit edilir
	_refresh_scale_options()
	_vsync_toggle.set_pressed_no_signal(DisplaySettingsLib.get_vsync())
	_master_slider.set_value_no_signal(AudioManager.get_master_volume() * 100.0)
	_music_slider.set_value_no_signal(AudioManager.get_music_volume() * 100.0)
	_sfx_slider.set_value_no_signal(AudioManager.get_sfx_volume() * 100.0)
	_music_toggle.set_pressed_no_signal(AudioManager.is_music_enabled())
	_music_slider.editable = AudioManager.is_music_enabled()
	_mute_toggle.set_pressed_no_signal(AudioManager.is_mute_unfocused())
	_autosave_option.select(maxi(0, AUTOSAVE_IDS.find(String(Settings.get_value(KEY_AUTOSAVE)))))
	_lang_option.select(Localization.SUPPORTED.find(Localization.get_language()))
	_cb_toggle.set_pressed_no_signal(UiTokens.is_colorblind())
	_update_pct_labels()


## Listeyi kurar, GEÇERLİ çözünürlüğü seçer ve kilidi uygular. effective_resolution:
## tam-ekran modlarında ekranda geçerli olan native boyuttur, saklanan pencereli tercih
## değil. Eşleşme yoksa motorun kullanacağı varsayılana düşülür.
## Çözünürlük YALNIZ pencereli modda anlamlı; kilitli satırın nedeni altındaki notta,
## Kenarlıksız modun kendi gerekçesiyle.
func _refresh_resolution_row() -> void:
	_res_list = DisplaySettingsLib.available_resolutions()
	var native: Vector2i = DisplaySettingsLib.native_resolution()
	_res_option.clear()
	for i in _res_list.size():
		# Çözünürlük bir ÖLÇÜ, çeviri değil; yalnız "doğal" işareti çeviriye tabi.
		var label: String = "%d × %d" % [_res_list[i].x, _res_list[i].y]
		if _res_list[i] == native:
			label += " (%s)" % tr("SET_RESOLUTION_NATIVE")
		_res_option.add_item(label, i)
	var idx: int = _res_list.find(DisplaySettingsLib.effective_resolution())
	_res_option.select(idx if idx >= 0 else _res_list.find(DisplaySettingsLib.default_resolution()))

	var editable: bool = DisplaySettingsLib.is_resolution_editable()
	_res_option.disabled = not editable
	_res_note.visible = not editable
	var borderless: bool = DisplaySettingsLib.get_window_mode() == DisplaySettingsLib.MODE_BORDERLESS
	_label_keys[_res_note] = "SET_RESOLUTION_BORDERLESS" if borderless else "SET_RESOLUTION_LOCKED"
	_res_note.text = tr(_label_keys[_res_note])


## Yasadışı adımlar DEVRE DIŞI kalır ve nedenlerini hover'da söyler. Seçim, motorun
## kırptığı değere senkronlanır — panel asla renderlanamayan bir adımı göstermez.
func _refresh_scale_options() -> void:
	var current: float = DisplaySettingsLib.get_ui_scale()
	var popup: PopupMenu = _scale_option.get_popup()
	var matched: int = -1
	for i in DisplaySettingsLib.UI_SCALE_STEPS.size():
		var step: float = DisplaySettingsLib.UI_SCALE_STEPS[i]
		var ok: bool = DisplaySettingsLib.is_step_allowed(step)
		popup.set_item_disabled(i, not ok)
		popup.set_item_tooltip(i, "" if ok else DisplaySettingsLib.step_blocked_note(step))
		if is_equal_approx(step, current):
			matched = i
	# Saklanan değer merdivende yoksa (elle düzenlenmiş settings.json) kırpılacağı adımı göster.
	if matched < 0:
		matched = DisplaySettingsLib.UI_SCALE_STEPS.find(DisplaySettingsLib.clamp_step(current))
	_scale_option.select(maxi(0, matched))


func _update_pct_labels() -> void:
	for slider: HSlider in _pct_labels:
		(_pct_labels[slider] as Label).text = Fmt.percent(int(round(slider.value)), 0)


## UiTokens.tr_upper Türkçe'nin i→İ kuralını bilir, ham to_upper() bilmez ("Dil" → "DIL" olurdu).
func _retranslate() -> void:
	_title.text = tr("SET_TITLE")
	_close_btn.text = UiTokens.tr_upper(tr("SET_CLOSE"))
	for path in HEADER_KEYS:
		(get_node(path) as Label).text = UiTokens.tr_upper(tr(HEADER_KEYS[path]))
	_lang_label.text = tr("SETTINGS_LANGUAGE")
	for i in LANG_KEYS.size():
		_lang_option.set_item_text(i, tr(LANG_KEYS[i]))
	for i in DisplaySettingsLib.MODE_KEYS.size():
		_mode_option.set_item_text(i, tr(DisplaySettingsLib.MODE_KEYS[i]))
	for i in AUTOSAVE_KEYS.size():
		_autosave_option.set_item_text(i, tr(AUTOSAVE_KEYS[i]))
	for i in DisplaySettingsLib.UI_SCALE_STEPS.size():   # yüzde kalıbı dile göre değişir
		_scale_option.set_item_text(i, Fmt.percent(int(round(DisplaySettingsLib.UI_SCALE_STEPS[i] * 100.0)), 0))
	for node in _label_keys:
		node.text = tr(_label_keys[node])
	_refresh_scale_options()   # devre dışı adımların ipucu metni de çevrilir
	_update_pct_labels()


# =============================================================================
# Satır kurucuları — YERLEŞİM + theme_type_variation, başka hiçbir stil yok.
# =============================================================================

func _add_row(parent: VBoxContainer, label_key: String, control: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", ROW_SEP)
	parent.add_child(row)
	var label := Label.new()
	label.theme_type_variation = &"BodySerif"
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	_label_keys[label] = label_key
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	row.add_child(control)


## Kaydırıcı 0..100, `setter` doğrusal 0..1 alır.
func _add_volume_row(label_key: String, setter: Callable) -> HSlider:
	var s := HSlider.new()
	s.theme_type_variation = &"VolumeSlider"
	s.custom_minimum_size = Vector2(SLIDER_W, 24)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.max_value = 100.0
	s.step = 1.0
	s.value_changed.connect(func(v: float) -> void:
		setter.call(v / 100.0)
		_update_pct_labels())
	var pct := Label.new()
	pct.theme_type_variation = &"RowMeta"
	pct.custom_minimum_size = Vector2(PCT_W, 0)
	pct.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_pct_labels[s] = pct
	var holder := HBoxContainer.new()
	holder.add_theme_constant_override("separation", ROW_SEP)
	holder.custom_minimum_size = Vector2(CONTROL_W, 0)
	holder.add_child(s)
	holder.add_child(pct)
	_add_row(_audio_body, label_key, holder)
	return s


## `count` boş öğe: metinleri _retranslate doldurur.
func _dropdown(count: int) -> OptionButton:
	var o := OptionButton.new()
	o.theme_type_variation = &"SettingsDropdown"
	o.get_popup().theme_type_variation = &"SettingsPopup"
	o.custom_minimum_size = Vector2(CONTROL_W, 0)
	o.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	o.clip_text = true   # uzun EN metni satırı genişletip paneli şişirmesin
	for i in count:
		o.add_item("", i)
	return o


func _switch() -> CheckButton:
	var c := CheckButton.new()
	c.theme_type_variation = &"SettingsSwitch"
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return c


func _note_label(key: String) -> Label:
	var l := Label.new()
	l.theme_type_variation = &"CaptionMuted"
	# autowrap + EXPAND_FILL birlikte: yalnız autowrap'li etiket min genişliği olarak
	# metnin tamamını ister ve kartı taşırır.
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label_keys[l] = key
	return l


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	Settings.flush()   # debounce penceresinde bekleyen yazımı panel kapanırken indir
	dismissed.emit()
	queue_free()
