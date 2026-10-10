extends Control

# Ayarlar paneli — altı bölüm (GÖRÜNTÜ · GRAFİK · SES · OYUN · ERİŞİLEBİLİRLİK · VERİ) kaydırılabilir bir
# gövdede. Dil satırı Oyun'dadır; her dil kendi adıyla okunur.
#
# main.gd GameShell/ModalLayer'a mount eder, panel kendini `dismissed` ile serbest
# bırakır. Kök process_mode = ALWAYS: ağaç durdurulmuşken de etkileşimli kalır ve ESC alır.
#
# Kontroller CANLI (Uygula butonu yok): her domain sistemi kendi değerini uygular ve
# Settings'e yazar; Settings yazımı debounce eder, sürükleme diski dövmez. Haber şeridinin
# aç/kapası şeridin kendisinindir (NewsTicker.set_open).
#
# YERLEŞİM sahnede, İÇERİK burada: satırlar (etiket · kontrol) tek bir yardımcıdan üretilir ve
# yalnız theme_type_variation taşır (UI/STYLE LAW kural 4).

signal dismissed

const DisplaySettingsLib := preload("res://scripts/systems/display_settings.gd")
const GraphicsSettingsLib := preload("res://scripts/systems/graphics_settings.gd")

const AUTOSAVE_KEYS: Array[String] = [   # SaveManager.AUTOSAVE_FREQUENCIES sırasıyla
	"SET_AUTOSAVE_OFF", "SET_AUTOSAVE_WEEKLY", "SET_AUTOSAVE_MONTHLY"]
const SUMMARY_FREQ_KEYS: Array[String] = [   # SummarySystem.FREQUENCIES sırasıyla
	"SET_SUMMARY_FREQ_WEEKLY", "SET_SUMMARY_FREQ_MONTHLY", "SET_SUMMARY_FREQ_QUARTERLY",
	"SET_SUMMARY_FREQ_YEARLY"]
const LANG_KEYS: Array[String] = ["LANG_TR", "LANG_EN"]   # Localization.SUPPORTED sırasıyla
# GraphicsSettings.ORDER sırasıyla, sonda Özel: seçilemez, yalnız seçenekler hiçbir ön ayara uymadığını söyler.
const GFX_PRESET_KEYS: Array[String] = ["SET_GFX_PRESET_LOW", "SET_GFX_PRESET_MEDIUM", "SET_GFX_PRESET_HIGH",
	"SET_GFX_PRESET_ULTRA", "SET_GFX_PRESET_CUSTOM"]
# Ön ayarın altındaki satırlar sırasıyla: seçenek → [etiket, değerler, öğe metinleri]. Yalnız etiketi olan satır
# aç/kapadır.
const GFX_ROWS := {
	"resolution": ["SET_GFX_RESOLUTION", ["fsr", "logical", "native", "super"],
		["SET_GFX_RES_FSR", "SET_GFX_RES_LOGICAL", "SET_GFX_RES_NATIVE", "SET_GFX_RES_SUPER"]],
	"aa": ["SET_GFX_AA", [0, 1, 2], ["SET_GFX_OFF", "SET_GFX_AA_FXAA", "SET_GFX_AA_SMAA"]],
	"msaa": ["SET_GFX_MSAA", [0, 1, 2, 3], ["SET_GFX_OFF", "SET_GFX_MSAA_2X", "SET_GFX_MSAA_4X", "SET_GFX_MSAA_8X"]],
	"shadow_size": ["SET_GFX_SHADOW_SIZE", [4096, 8192], ["SET_GFX_SHADOW_STANDARD", "SET_GFX_SHADOW_HIGH"]],
	"soft_shadows": ["SET_GFX_SOFT_SHADOWS"],
	"lamp_shadows": ["SET_GFX_LAMP_SHADOWS"],
	"small_shadows": ["SET_GFX_SMALL_SHADOWS"],
	"ssao": ["SET_GFX_SSAO"],
	"glow": ["SET_GFX_GLOW"],
	"tilt_shift": ["SET_GFX_TILT_SHIFT"],
	"vignette": ["SET_GFX_VIGNETTE"],
	"deband": ["SET_GFX_DEBAND"],
	"fps_cap": ["SET_GFX_FPS_CAP", [0, 30, 60, 120, 144], ["SET_GFX_FPS_UNLIMITED", "30", "60", "120", "144"]],
}

const KEY_COLORBLIND := "colorblind_palette"
const KEY_TICKER := "ticker_open"

# Bölüm başlıkları CSV'de doğal yazımda durur ve _retranslate'te büyütülür.
const HEADER_KEYS := {
	"%DisplayHeader": "SET_SEC_DISPLAY",
	"%GraphicsHeader": "SET_SEC_GRAPHICS",
	"%AudioHeader": "SET_SEC_AUDIO",
	"%GameHeader": "SET_SEC_GAME",
	"%AccessibilityHeader": "SET_SEC_ACCESSIBILITY",
	"%DataHeader": "SET_SEC_DATA",
}

# Satır geometrisi (YERLEŞİM — bu dosyanın sahip olduğu tek sayı ailesi): satırın boyu, kontrol
# sütunu, ses satırının yüzde sütunu.
const ROW_H := 48
const CONTROL_W := 260
const PCT_W := 48

@onready var _title: Label = %TitleLabel
@onready var _close_btn: Button = %CloseBtn
@onready var _display_body: VBoxContainer = %DisplayBody
@onready var _graphics_body: VBoxContainer = %GraphicsBody
@onready var _audio_body: VBoxContainer = %AudioBody
@onready var _game_body: VBoxContainer = %GameBody
@onready var _a11y_body: VBoxContainer = %AccessibilityBody
@onready var _data_body: HBoxContainer = %DataBody

var _mode_option: OptionButton
var _res_option: OptionButton
var _res_list: Array[Vector2i] = []
var _borderless_note: Control
var _fullscreen_note: Control
var _scale_option: OptionButton
var _vsync_toggle: CheckButton
var _ticker_toggle: CheckButton
var _gfx_preset: OptionButton
var _gfx_controls: Dictionary = {}   # GFX_ROWS seçeneği → OptionButton ya da CheckButton
var _master_slider: HSlider
var _music_toggle: CheckButton
var _music_slider: HSlider
var _sfx_slider: HSlider
var _mute_toggle: CheckButton
var _autosave_option: OptionButton
var _summary_option: OptionButton
var _pause_toggle: CheckButton
var _lang_option: OptionButton
var _cb_toggle: CheckButton

var _pct_labels: Dictionary = {}   # HSlider → yüzde Label'ı
# Etiket/buton → çeviri anahtarı: dil seçimi CANLI kontroldür, metinler yerinde tazelenir.
var _label_keys: Dictionary = {}


func _ready() -> void:
	($Dimmer as ColorRect).color = UiTokens.D_SCRIM
	_build_display_section()
	_build_graphics_section()
	_build_audio_section()
	_build_game_section()
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
	# Çözünürlük yalnız pencereli modda değişir; iki tam ekran modu gerekçesini satırın altında söyler.
	_borderless_note = _note(_display_body, "SET_RESOLUTION_BORDERLESS")
	_fullscreen_note = _note(_display_body, "SET_RESOLUTION_LOCKED")

	_scale_option = _dropdown(DisplaySettingsLib.UI_SCALE_STEPS.size())
	_scale_option.item_selected.connect(func(idx: int) -> void:
		DisplaySettingsLib.set_ui_scale(DisplaySettingsLib.UI_SCALE_STEPS[idx])
		_refresh_scale_options())   # motor kırptıysa seçim de onu göstersin
	_add_row(_display_body, "SET_UI_SCALE", _scale_option)

	_vsync_toggle = CheckButton.new()
	_vsync_toggle.toggled.connect(func(on: bool) -> void: DisplaySettingsLib.set_vsync(on))
	_add_row(_display_body, "SET_VSYNC", _vsync_toggle)

	_ticker_toggle = CheckButton.new()
	_ticker_toggle.toggled.connect(func(on: bool) -> void: get_tree().call_group(&"news_ticker", &"set_open", on))
	_add_row(_display_body, "SET_TICKER", _ticker_toggle)


func _build_graphics_section() -> void:
	_gfx_preset = _dropdown(GFX_PRESET_KEYS.size())
	_gfx_preset.set_item_disabled(GFX_PRESET_KEYS.size() - 1, true)
	_gfx_preset.item_selected.connect(func(idx: int) -> void:
		GraphicsSettingsLib.set_preset(GraphicsSettingsLib.ORDER[idx])
		_sync_graphics())
	_add_row(_graphics_body, "SET_GFX_PRESET", _gfx_preset)
	for key: String in GFX_ROWS:
		var row: Array = GFX_ROWS[key]
		if row.size() == 1:
			var toggle := CheckButton.new()
			toggle.toggled.connect(func(on: bool) -> void: _set_graphics(key, on))
			_gfx_controls[key] = toggle
		else:
			var option := _dropdown(row[1].size())
			option.item_selected.connect(func(idx: int) -> void: _set_graphics(key, row[1][idx]))
			_gfx_controls[key] = option
		_add_row(_graphics_body, row[0], _gfx_controls[key])


func _build_audio_section() -> void:
	_master_slider = _add_volume_row("SET_VOL_MASTER", AudioManager.set_master_volume)

	_music_toggle = CheckButton.new()
	_music_toggle.toggled.connect(func(on: bool) -> void:
		AudioManager.set_music_enabled(on)
		_music_slider.editable = on)   # müzik kapalıyken seviye kontrolü sönükleşir
	_add_row(_audio_body, "SET_MUSIC_ENABLED", _music_toggle)

	_music_slider = _add_volume_row("SET_VOL_MUSIC", AudioManager.set_music_volume)
	_sfx_slider = _add_volume_row("SET_VOL_SFX", AudioManager.set_sfx_volume)

	_mute_toggle = CheckButton.new()
	_mute_toggle.toggled.connect(AudioManager.set_mute_unfocused)
	_add_row(_audio_body, "SET_MUTE_UNFOCUSED", _mute_toggle)


func _build_game_section() -> void:
	_autosave_option = _dropdown(SaveManager.AUTOSAVE_FREQUENCIES.size())
	_autosave_option.item_selected.connect(func(idx: int) -> void:
		Settings.set_value(SaveManager.SETTING_AUTOSAVE_FREQUENCY, SaveManager.AUTOSAVE_FREQUENCIES[idx]))
	_add_row(_game_body, "SET_AUTOSAVE", _autosave_option)
	_summary_option = _dropdown(SummarySystem.FREQUENCIES.size())
	_summary_option.item_selected.connect(func(idx: int) -> void:
		Settings.set_value(SummarySystem.SETTING_FREQUENCY, SummarySystem.FREQUENCIES[idx]))
	_add_row(_game_body, "SET_SUMMARY_FREQ", _summary_option)
	_note(_game_body, "SET_SUMMARY_FREQ_NOTE")
	_pause_toggle = CheckButton.new()
	_pause_toggle.toggled.connect(func(on: bool) -> void: Settings.set_value(TimeManager.SETTING_PAUSE_UNFOCUSED, on))
	_add_row(_game_body, "SET_PAUSE_UNFOCUSED", _pause_toggle)
	_lang_option = _dropdown(LANG_KEYS.size())
	_lang_option.item_selected.connect(func(idx: int) -> void:
		Localization.set_language(Localization.SUPPORTED[idx])
		_retranslate())
	_add_row(_game_body, "SETTINGS_LANGUAGE", _lang_option)


func _build_accessibility_section() -> void:
	_cb_toggle = CheckButton.new()
	_cb_toggle.toggled.connect(_on_colorblind_toggled)
	_add_row(_a11y_body, "SET_COLORBLIND", _cb_toggle)
	_note(_a11y_body, "SET_COLORBLIND_NOTE")


func _build_data_section() -> void:
	for entry in [["SET_OPEN_SAVE_FOLDER", _on_open_save_folder], ["SET_RESET_DEFAULTS", _on_reset_pressed]]:
		var b := Button.new()
		b.theme_type_variation = &"SecondaryButtonSmall"
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
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


## Bir seçenek değişince ön ayar satırı ona uyan ön ayara ya da Özel'e döner.
func _set_graphics(key: String, value: Variant) -> void:
	GraphicsSettingsLib.set_option(key, value)
	_sync_graphics()


func _on_colorblind_toggled(on: bool) -> void:
	# Semantik renk temaya pişmediği için bu saf bir çalışma zamanı
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
		"confirm_text": tr("SET_RESET_CONFIRM_OK"),
		"cancel_text": tr("SET_RESET_CONFIRM_CANCEL"),
		"on_confirm": _apply_reset,
		"danger": true,
	})


func _apply_reset() -> void:
	Settings.reset_to_defaults()   # DEFAULTS anahtarları; dil ve tur bayrağı DOKUNULMAZ
	get_tree().call_group(&"news_ticker", &"set_open", bool(Settings.get_value(KEY_TICKER)))
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
	_ticker_toggle.set_pressed_no_signal(bool(Settings.get_value(KEY_TICKER)))
	_sync_graphics()
	_master_slider.set_value_no_signal(AudioManager.get_master_volume() * 100.0)
	_music_slider.set_value_no_signal(AudioManager.get_music_volume() * 100.0)
	_sfx_slider.set_value_no_signal(AudioManager.get_sfx_volume() * 100.0)
	_music_toggle.set_pressed_no_signal(AudioManager.is_music_enabled())
	_music_slider.editable = AudioManager.is_music_enabled()
	_mute_toggle.set_pressed_no_signal(AudioManager.is_mute_unfocused())
	# get_choice: an option this build no longer offers shows the default the game reads for it.
	_autosave_option.select(SaveManager.AUTOSAVE_FREQUENCIES.find(
		Settings.get_choice(SaveManager.SETTING_AUTOSAVE_FREQUENCY, SaveManager.AUTOSAVE_FREQUENCIES)))
	_summary_option.select(SummarySystem.FREQUENCIES.find(
		Settings.get_choice(SummarySystem.SETTING_FREQUENCY, SummarySystem.FREQUENCIES)))
	_pause_toggle.set_pressed_no_signal(bool(Settings.get_value(TimeManager.SETTING_PAUSE_UNFOCUSED)))
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
	_res_option.disabled = not DisplaySettingsLib.is_resolution_editable()
	var mode: String = DisplaySettingsLib.get_window_mode()
	_borderless_note.visible = mode == DisplaySettingsLib.MODE_BORDERLESS
	_fullscreen_note.visible = mode == DisplaySettingsLib.MODE_FULLSCREEN


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


func _sync_graphics() -> void:
	var shown: String = GraphicsSettingsLib.shown_preset()
	_gfx_preset.select(GFX_PRESET_KEYS.size() - 1 if shown == GraphicsSettingsLib.CUSTOM else GraphicsSettingsLib.ORDER.find(shown))
	var now: Dictionary = GraphicsSettingsLib.options()
	for key: String in _gfx_controls:
		if _gfx_controls[key] is CheckButton:
			_gfx_controls[key].set_pressed_no_signal(now[key])
		else:
			_gfx_controls[key].select((GFX_ROWS[key][1] as Array).find(now[key]))


func _update_pct_labels() -> void:
	for slider: HSlider in _pct_labels:
		(_pct_labels[slider] as Label).text = Fmt.percent(int(round(slider.value)), 0)


## Fmt.upper Türkçe'nin i→İ kuralını bilir, ham to_upper() bilmez ("Veri" → "VERI" olurdu).
func _retranslate() -> void:
	_title.text = Fmt.upper(tr("SET_TITLE"))
	for path in HEADER_KEYS:
		(get_node(path) as Label).text = Fmt.upper(tr(HEADER_KEYS[path]))
	for i in LANG_KEYS.size():
		_lang_option.set_item_text(i, tr(LANG_KEYS[i]))
	for i in DisplaySettingsLib.MODE_KEYS.size():
		_mode_option.set_item_text(i, tr(DisplaySettingsLib.MODE_KEYS[i]))
	for i in AUTOSAVE_KEYS.size():
		_autosave_option.set_item_text(i, tr(AUTOSAVE_KEYS[i]))
	for i in SUMMARY_FREQ_KEYS.size():
		_summary_option.set_item_text(i, tr(SUMMARY_FREQ_KEYS[i]))
	for i in GFX_PRESET_KEYS.size():
		_gfx_preset.set_item_text(i, tr(GFX_PRESET_KEYS[i]))
	for key: String in _gfx_controls:
		if _gfx_controls[key] is OptionButton:
			var items: Array = GFX_ROWS[key][2]
			for i in items.size():
				_gfx_controls[key].set_item_text(i, tr(items[i]))
	for i in DisplaySettingsLib.UI_SCALE_STEPS.size():   # yüzde kalıbı dile göre değişir
		_scale_option.set_item_text(i, Fmt.percent(int(round(DisplaySettingsLib.UI_SCALE_STEPS[i] * 100.0)), 0))
	for node in _label_keys:
		node.text = tr(_label_keys[node])
	_refresh_resolution_row()   # "(doğal)" işareti
	_refresh_scale_options()   # devre dışı adımların ipucu metni
	_update_pct_labels()


# =============================================================================
# Satır kurucuları — YERLEŞİM + theme_type_variation, başka hiçbir stil yok.
# =============================================================================

## A row: its label on the left, its control in the right column.
func _add_row(parent: VBoxContainer, label_key: String, control: Control) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = ROW_H
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	parent.add_child(row)
	var label := UiFactory.make_label("", &"BodyLabel")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	_label_keys[label] = label_key
	control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(control)


## Kaydırıcı 0..100, `setter` doğrusal 0..1 alır; yüzdesi sabit sütunda.
func _add_volume_row(label_key: String, setter: Callable) -> HSlider:
	var s := HSlider.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.max_value = 100.0
	s.step = 1.0
	s.value_changed.connect(func(v: float) -> void:
		setter.call(v / 100.0)
		_update_pct_labels())
	var pct := UiFactory.make_label("", &"NoteMuted")
	pct.custom_minimum_size.x = PCT_W
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_pct_labels[s] = pct
	var holder := HBoxContainer.new()
	holder.add_theme_constant_override("separation", UiTokens.SPACE_XXL)
	holder.custom_minimum_size.x = CONTROL_W
	holder.add_child(s)
	holder.add_child(pct)
	_add_row(_audio_body, label_key, holder)
	return s


## `count` boş öğe: metinleri _retranslate doldurur.
func _dropdown(count: int) -> OptionButton:
	var o := OptionButton.new()
	o.custom_minimum_size.x = CONTROL_W
	o.clip_text = true   # uzun EN metni satırı genişletip paneli şişirmesin
	for i in count:
		o.add_item("", i)
	return o


## The note under a row: the info glyph and its line. Returned to be shown or hidden.
func _note(parent: VBoxContainer, key: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	row.add_child(UiFactory.make_glyph("res://assets/icons/util/info.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_4))
	var line := UiFactory.make_label("", &"Caption")
	# autowrap + EXPAND_FILL birlikte: yalnız autowrap'li etiket min genişliği olarak
	# metnin tamamını ister ve kartı taşırır.
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(line)
	_label_keys[line] = key
	var note := SprintUiShared.pad(row, Vector4i(0, 0, 0, UiTokens.SPACE_M))
	parent.add_child(note)
	return note


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	Settings.flush()   # debounce penceresinde bekleyen yazımı panel kapanırken indir
	dismissed.emit()
	queue_free()
