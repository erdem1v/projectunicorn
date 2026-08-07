extends Control

# Ayarlar paneli — altı bölüm (GÖRÜNTÜ · SES · OYUN · DİL · ERİŞİLEBİLİRLİK ·
# VERİ) kaydırılabilir bir gövdede.
#
# MentorIntroModal konvansiyonu: main.gd GameShell/ModalLayer'a mount eder, panel
# kendini `dismissed` ile serbest bırakır (main.gd hızı geri yükler). Kök
# process_mode = ALWAYS — ağaç durdurulmuşken de etkileşimli kalır, ki
# _unhandled_input pause sırasında da ESC alabilsin.
#
# Kontroller CANLI: kaydırıcıyı oynatmak / anahtarı çevirmek anında uygulanır
# (Uygula butonu YOK). Kalıcılık AYRI bir mülkiyet: her domain sistemi kendi
# değerini Settings'e yazar (Settings persists, sistem applies), Settings de
# yazımı ~0.5 sn debounce eder — sürükleme diski dövmez.
#
# YERLEŞİM sahnede, İÇERİK burada: satırlar (etiket · boşluk · kontrol) tek bir
# yardımcıdan üretilir ve yalnız theme_type_variation taşırlar. Bu dosyada font
# boyutu / renk / stylebox yoktur (UI/STYLE LAW kural 4).
#
# GÖRSEL KALİTE NOTU: bu tur ÇALIŞAN yer tutucu kalitesindedir — her ekran için
# ayrı bir "Terminal reçetesi" yeniden kaplaması bekliyor; buraya süsleme
# eklenmedi.

signal dismissed

const DisplaySettingsLib := preload("res://scripts/systems/display_settings.gd")

# Otomatik kayıt sıklığı: bu görev YALNIZ ayarı kalıcı kılar. Tüketici (SaveManager)
# paralel bir görevde kuruluyor ve anahtarı tembel okuyacak.
const AUTOSAVE_IDS: Array[String] = ["off", "daily", "weekly", "monthly"]
const AUTOSAVE_KEYS: Array[String] = [
	"SET_AUTOSAVE_OFF", "SET_AUTOSAVE_DAILY", "SET_AUTOSAVE_WEEKLY", "SET_AUTOSAVE_MONTHLY"]

const KEY_AUTOSAVE := "autosave_frequency"
const KEY_COLORBLIND := "colorblind_palette"

const SAVE_DIR := "user://saves/"

# Satır geometrisi (YERLEŞİM — bu dosyanın sahip olduğu tek sayı ailesi).
const ROW_SEP := 12
const CONTROL_W := 230
const SLIDER_W := 170
const PCT_W := 44

@onready var _title: Label = %TitleLabel
@onready var _close_btn: Button = %CloseBtn
@onready var _display_header: Label = %DisplayHeader
@onready var _display_body: VBoxContainer = %DisplayBody
@onready var _audio_header: Label = %AudioHeader
@onready var _audio_body: VBoxContainer = %AudioBody
@onready var _game_header: Label = %GameHeader
@onready var _game_body: VBoxContainer = %GameBody
@onready var _lang_header: Label = %LanguageHeader
@onready var _lang_label: Label = %LangLabel
@onready var _lang_option: OptionButton = %LanguageOption
@onready var _a11y_header: Label = %AccessibilityHeader
@onready var _a11y_body: VBoxContainer = %AccessibilityBody
@onready var _data_header: Label = %DataHeader
@onready var _data_body: VBoxContainer = %DataBody

# --- Canlı kontrol referansları (yeniden çeviri + karşılıklı etkiler için) ---
var _mode_option: OptionButton
var _res_option: OptionButton
var _res_note: Label
var _scale_option: OptionButton
var _vsync_toggle: CheckButton
var _master_slider: HSlider
var _master_pct: Label
var _music_toggle: CheckButton
var _music_slider: HSlider
var _music_pct: Label
var _sfx_slider: HSlider
var _sfx_pct: Label
var _mute_toggle: CheckButton
var _autosave_option: OptionButton
var _cb_toggle: CheckButton
var _cb_note: Label
var _folder_btn: Button
var _reset_btn: Button

# Etiket → çeviri anahtarı defteri: dil değişince metinleri yerinde tazelemek için
# (panel kapanıp açılmaz — dil seçimi CANLI kontroldür).
var _label_keys: Dictionary = {}


func _ready() -> void:
	_build_display_section()
	_build_audio_section()
	_build_game_section()
	_build_language_section()
	_build_accessibility_section()
	_build_data_section()
	_retranslate()
	_close_btn.pressed.connect(_close)
	_close_btn.grab_focus()


# =============================================================================
# GÖRÜNTÜ
# =============================================================================

func _build_display_section() -> void:
	_mode_option = _dropdown()
	for i in DisplaySettingsLib.MODE_ORDER.size():
		_mode_option.add_item("", i)
	_mode_option.select(DisplaySettingsLib.MODE_ORDER.find(DisplaySettingsLib.get_window_mode()))
	_mode_option.item_selected.connect(_on_window_mode_selected)
	_add_row(_display_body, "SET_WINDOW_MODE", _mode_option)

	_res_option = _dropdown()
	_fill_resolution_options()
	_res_option.item_selected.connect(_on_resolution_selected)
	_add_row(_display_body, "SET_RESOLUTION", _res_option)
	_res_note = _note_label("SET_RESOLUTION_LOCKED")
	_display_body.add_child(_res_note)

	_scale_option = _dropdown()
	for i in DisplaySettingsLib.UI_SCALE_STEPS.size():
		var step: float = DisplaySettingsLib.UI_SCALE_STEPS[i]
		_scale_option.add_item("%%%d" % int(round(step * 100.0)), i)
	_scale_option.item_selected.connect(_on_ui_scale_selected)
	_add_row(_display_body, "SET_UI_SCALE", _scale_option)
	_refresh_scale_options()

	_vsync_toggle = _switch(DisplaySettingsLib.get_vsync())
	_vsync_toggle.toggled.connect(_on_vsync_toggled)
	_add_row(_display_body, "SET_VSYNC", _vsync_toggle)

	_refresh_resolution_row()


func _on_window_mode_selected(idx: int) -> void:
	DisplaySettingsLib.set_window_mode(DisplaySettingsLib.MODE_ORDER[idx])
	# Mod değişimi GEÇERLİ çözünürlüğü de değiştirir (tam ekranda native, pencerelide
	# saklanan tercih), o yüzden seçili satır yeniden hesaplanmalı.
	_fill_resolution_options()
	_refresh_resolution_row()
	_refresh_scale_options()


## Listeyi kurar VE doğru satırı seçer. Tek yerde toplandı çünkü eskiden iki ayrı
## kopyası vardı (kurulum + _sync_from_state) ve ikisi de aynı hatayı taşıyordu:
## saklanan değer listede yoksa sessizce 0. indekse (1280×720) düşüyordu, üstelik
## seçimi Settings'e GERİ YAZMADAN. Panel yalan söylüyordu ve oyuncunun açılır
## listeye ilk dokunuşu onu 720p'ye indiriyordu. Eşleşme yoksa artık motorun
## gerçekten kullanacağı değere düşüyoruz — UI ölçeği satırının zaten doğru
## yaptığı şeyin aynısı.
func _fill_resolution_options() -> void:
	# effective_resolution, get_resolution DEĞİL: tam-ekran modlarında satır kilitli
	# ve ekranda geçerli olan native boyuttur — saklanan pencereli tercihi göstermek
	# panelin yeniden yalan söylemesi olurdu.
	var current: Vector2i = DisplaySettingsLib.effective_resolution()
	var native: Vector2i = DisplaySettingsLib.native_resolution()
	var list: Array[Vector2i] = DisplaySettingsLib.available_resolutions()
	_res_option.clear()
	for i in list.size():
		# Çözünürlük bir ÖLÇÜ, çeviri değil: "1920 × 1080" her iki dilde de aynı.
		# Yalnız "doğal" işareti çeviriye tabi.
		var label: String = "%d × %d" % [list[i].x, list[i].y]
		if list[i] == native:
			label += " (%s)" % tr("SET_RESOLUTION_NATIVE")
		_res_option.add_item(label, i)
		if list[i] == current:
			_res_option.select(i)
	if _res_option.selected < 0:
		var fallback: Vector2i = DisplaySettingsLib.default_resolution()
		for i in list.size():
			if list[i] == fallback:
				_res_option.select(i)


func _on_resolution_selected(idx: int) -> void:
	var list: Array[Vector2i] = DisplaySettingsLib.available_resolutions()
	if idx < 0 or idx >= list.size():
		return
	DisplaySettingsLib.set_resolution(list[idx])
	_refresh_scale_options()


func _on_ui_scale_selected(idx: int) -> void:
	DisplaySettingsLib.set_ui_scale(DisplaySettingsLib.UI_SCALE_STEPS[idx])
	_refresh_scale_options()   # motor yukarı kırptıysa seçim de onu göstersin


func _on_vsync_toggled(on: bool) -> void:
	DisplaySettingsLib.set_vsync(on)


## Çözünürlük YALNIZ pencereli modda anlamlı — iki tam-ekran modunda pencere zaten
## ekranı doldurur. Satır kilitlenir ve nedeni altındaki notta yazar.
func _refresh_resolution_row() -> void:
	var editable: bool = DisplaySettingsLib.is_resolution_editable()
	_res_option.disabled = not editable
	_res_note.visible = not editable


## Okunabilirlik tabanı (fiziksel piksel) her pencere boyutunda yeniden ölçülür:
## yasadışı adımlar DEVRE DIŞI kalır ve nedenlerini hover'da söyler. Seçim, motorun
## yukarı kırptığı değere senkronlanır — panel asla renderlanamayan bir adımı göstermez.
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
	# Kaydedilmiş değer listede yoksa (elle düzenlenmiş settings.json) boş bir
	# açılır kutu göstermek yerine motorun kırpacağı yasal adımı göster.
	if matched < 0:
		matched = DisplaySettingsLib.UI_SCALE_STEPS.find(DisplaySettingsLib.clamp_step(current))
	_scale_option.select(maxi(0, matched))


# =============================================================================
# SES
# =============================================================================

func _build_audio_section() -> void:
	_master_slider = _volume_slider(AudioManager.get_master_volume())
	_master_pct = _pct_label()
	_master_slider.value_changed.connect(_on_master_changed)
	_add_slider_row(_audio_body, "SET_VOL_MASTER", _master_slider, _master_pct)

	_music_toggle = _switch(AudioManager.is_music_enabled())
	_music_toggle.toggled.connect(_on_music_toggled)
	_add_row(_audio_body, "SET_MUSIC_ENABLED", _music_toggle)

	_music_slider = _volume_slider(AudioManager.get_music_volume())
	_music_slider.editable = AudioManager.is_music_enabled()
	_music_pct = _pct_label()
	_music_slider.value_changed.connect(_on_music_volume_changed)
	_add_slider_row(_audio_body, "SET_VOL_MUSIC", _music_slider, _music_pct)

	_sfx_slider = _volume_slider(AudioManager.get_sfx_volume())
	_sfx_pct = _pct_label()
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_add_slider_row(_audio_body, "SET_VOL_SFX", _sfx_slider, _sfx_pct)

	_mute_toggle = _switch(AudioManager.is_mute_unfocused())
	_mute_toggle.toggled.connect(_on_mute_unfocused_toggled)
	_add_row(_audio_body, "SET_MUTE_UNFOCUSED", _mute_toggle)

	_update_pct_labels()


func _on_master_changed(v: float) -> void:
	AudioManager.set_master_volume(v / 100.0)
	_update_pct_labels()


func _on_music_toggled(on: bool) -> void:
	AudioManager.set_music_enabled(on)
	_music_slider.editable = on   # müzik kapalıyken seviye kontrolü sönükleşir


func _on_music_volume_changed(v: float) -> void:
	AudioManager.set_music_volume(v / 100.0)
	_update_pct_labels()


func _on_sfx_changed(v: float) -> void:
	AudioManager.set_sfx_volume(v / 100.0)
	_update_pct_labels()


func _on_mute_unfocused_toggled(on: bool) -> void:
	AudioManager.set_mute_unfocused(on)


func _update_pct_labels() -> void:
	_master_pct.text = "%d%%" % int(round(_master_slider.value))
	_music_pct.text = "%d%%" % int(round(_music_slider.value))
	_sfx_pct.text = "%d%%" % int(round(_sfx_slider.value))


# =============================================================================
# OYUN
# =============================================================================

func _build_game_section() -> void:
	_autosave_option = _dropdown()
	for i in AUTOSAVE_IDS.size():
		_autosave_option.add_item("", i)
	var saved: String = String(Settings.get_value(KEY_AUTOSAVE, Settings.get_default(KEY_AUTOSAVE)))
	_autosave_option.select(maxi(0, AUTOSAVE_IDS.find(saved)))
	_autosave_option.item_selected.connect(_on_autosave_selected)
	_add_row(_game_body, "SET_AUTOSAVE", _autosave_option)


func _on_autosave_selected(idx: int) -> void:
	# Bu tur SADECE kalıcılık: tüketici (SaveManager) paralel görevde kuruluyor.
	Settings.set_value(KEY_AUTOSAVE, AUTOSAVE_IDS[idx])


# =============================================================================
# DİL
# =============================================================================

func _build_language_section() -> void:
	# Davranış değişmedi (Package 5): Localization autoload hem uygular hem
	# Settings'e yazar. NOT: yerelleştirme görevinin "ilk açılışta dil sor" kapısı
	# AYNI kalıcılığa (Settings > "language") bağlanacak — kapı BURADA kurulmaz,
	# burası yalnız oyun içi değiştirici.
	_lang_option.theme_type_variation = &"SettingsDropdown"
	_lang_option.get_popup().theme_type_variation = &"SettingsPopup"
	_lang_option.clear()
	_lang_option.add_item(tr("LANG_TR"), 0)   # id 0 = tr
	_lang_option.add_item(tr("LANG_EN"), 1)   # id 1 = en
	_lang_option.select(0 if Localization.get_language() == "tr" else 1)
	_lang_option.item_selected.connect(_on_language_selected)


func _on_language_selected(idx: int) -> void:
	Localization.set_language("tr" if idx == 0 else "en")
	_retranslate()


# =============================================================================
# ERİŞİLEBİLİRLİK
# =============================================================================

func _build_accessibility_section() -> void:
	_cb_toggle = _switch(UiTokens.is_colorblind())
	_cb_toggle.toggled.connect(_on_colorblind_toggled)
	_add_row(_a11y_body, "SET_COLORBLIND", _cb_toggle)
	_cb_note = _note_label("SET_COLORBLIND_NOTE")
	_a11y_body.add_child(_cb_note)


func _on_colorblind_toggled(on: bool) -> void:
	# Semantik renk master_theme.tres'e HİÇ pişmediği için bu saf bir çalışma
	# zamanı takasıdır: token'ı çevir, canlı yüzeylere haber ver.
	UiTokens.set_colorblind(on)
	Settings.set_value(KEY_COLORBLIND, on)
	EventBus.palette_changed.emit(on)


# =============================================================================
# VERİ
# =============================================================================

func _build_data_section() -> void:
	_folder_btn = Button.new()
	_folder_btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_folder_btn.pressed.connect(_on_open_save_folder)
	_data_body.add_child(_folder_btn)
	_label_keys[_folder_btn] = "SET_OPEN_SAVE_FOLDER"

	_reset_btn = Button.new()
	_reset_btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_reset_btn.pressed.connect(_on_reset_pressed)
	_data_body.add_child(_reset_btn)
	_label_keys[_reset_btn] = "SET_RESET_DEFAULTS"


func _on_open_save_folder() -> void:
	# Klasör ilk açılışta henüz YOKTUR (hiç kayıt alınmadıysa) — dosya yöneticisine
	# var olmayan bir yol vermek sessizce hiçbir şey yapar, o yüzden önce yaratılır.
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(SAVE_DIR))


func _on_reset_pressed() -> void:
	# ConfirmModal sözleşmesi (confirm_modal.gd): on_confirm, modal'ın `confirmed`
	# sinyaline bağlanan ARGÜMANSIZ bir Callable'dır — argüman gerekseydi bind
	# edilirdi; _apply_reset argüman almadığı için düz metot referansı yeterli
	# (hr_tab / creation_flow'un aynı şekli).
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


## Sıfırlama sonrası her kontrolü canlı durumdan yeniden tohumla (panel açık kalır).
func _sync_from_state() -> void:
	_mode_option.select(DisplaySettingsLib.MODE_ORDER.find(DisplaySettingsLib.get_window_mode()))
	# Sıfırlama çözünürlük anahtarlarını SİLER, yani get_resolution yeniden tespit
	# eder — liste de yeniden kurulmalı, yoksa eski seçim ekranda kalır.
	_fill_resolution_options()
	_vsync_toggle.set_pressed_no_signal(DisplaySettingsLib.get_vsync())
	_master_slider.set_value_no_signal(AudioManager.get_master_volume() * 100.0)
	_music_slider.set_value_no_signal(AudioManager.get_music_volume() * 100.0)
	_sfx_slider.set_value_no_signal(AudioManager.get_sfx_volume() * 100.0)
	_music_toggle.set_pressed_no_signal(AudioManager.is_music_enabled())
	_music_slider.editable = AudioManager.is_music_enabled()
	_mute_toggle.set_pressed_no_signal(AudioManager.is_mute_unfocused())
	_cb_toggle.set_pressed_no_signal(UiTokens.is_colorblind())
	var saved: String = String(Settings.get_value(KEY_AUTOSAVE, Settings.get_default(KEY_AUTOSAVE)))
	_autosave_option.select(maxi(0, AUTOSAVE_IDS.find(saved)))
	_refresh_resolution_row()
	_refresh_scale_options()
	_update_pct_labels()


# =============================================================================
# Çeviri
# =============================================================================

## Bölüm başlıkları CSV'de doğal yazımda durur ve BURADA büyütülür —
## UiTokens.tr_upper Türkçe'nin i→İ kuralını bilir, ham to_upper() bilmez
## ("Görüntü" → "GÖRÜNTÜ" doğru, "Dil" → "DIL" yanlış olurdu).
func _retranslate() -> void:
	_title.text = tr("SET_TITLE")
	_close_btn.text = UiTokens.tr_upper(tr("SET_CLOSE"))
	_display_header.text = UiTokens.tr_upper(tr("SET_SEC_DISPLAY"))
	_audio_header.text = UiTokens.tr_upper(tr("SET_SEC_AUDIO"))
	_game_header.text = UiTokens.tr_upper(tr("SET_SEC_GAME"))
	_lang_header.text = UiTokens.tr_upper(tr("SETTINGS_LANGUAGE"))
	_a11y_header.text = UiTokens.tr_upper(tr("SET_SEC_ACCESSIBILITY"))
	_data_header.text = UiTokens.tr_upper(tr("SET_SEC_DATA"))
	_lang_label.text = tr("SETTINGS_LANGUAGE")
	_lang_option.set_item_text(0, tr("LANG_TR"))
	_lang_option.set_item_text(1, tr("LANG_EN"))
	for i in DisplaySettingsLib.MODE_KEYS.size():
		_mode_option.set_item_text(i, tr(DisplaySettingsLib.MODE_KEYS[i]))
	for i in AUTOSAVE_KEYS.size():
		_autosave_option.set_item_text(i, tr(AUTOSAVE_KEYS[i]))
	for node in _label_keys.keys():
		var key: String = String(_label_keys[node])
		if node is Button:
			(node as Button).text = tr(key)
		elif node is Label:
			(node as Label).text = tr(key)
	_refresh_scale_options()   # devre dışı adımların ipucu metni de çevrilir


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


func _add_slider_row(parent: VBoxContainer, label_key: String, slider: HSlider, pct: Label) -> void:
	var holder := HBoxContainer.new()
	holder.add_theme_constant_override("separation", ROW_SEP)
	holder.custom_minimum_size = Vector2(CONTROL_W, 0)
	holder.add_child(slider)
	holder.add_child(pct)
	_add_row(parent, label_key, holder)


func _dropdown() -> OptionButton:
	var o := OptionButton.new()
	o.theme_type_variation = &"SettingsDropdown"
	o.get_popup().theme_type_variation = &"SettingsPopup"
	o.custom_minimum_size = Vector2(CONTROL_W, 0)
	o.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	o.clip_text = true   # uzun EN metni satırı genişletip paneli şişirmesin
	return o


func _switch(on: bool) -> CheckButton:
	var c := CheckButton.new()
	c.theme_type_variation = &"SettingsSwitch"
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.set_pressed_no_signal(on)
	return c


func _volume_slider(linear: float) -> HSlider:
	var s := HSlider.new()
	s.theme_type_variation = &"VolumeSlider"
	s.custom_minimum_size = Vector2(SLIDER_W, 24)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.min_value = 0.0
	s.max_value = 100.0
	s.step = 1.0
	s.set_value_no_signal(linear * 100.0)
	return s


func _pct_label() -> Label:
	var l := Label.new()
	l.theme_type_variation = &"RowMeta"
	l.custom_minimum_size = Vector2(PCT_W, 0)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return l


func _note_label(key: String) -> Label:
	var l := Label.new()
	l.theme_type_variation = &"CaptionMuted"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# autowrap + EXPAND_FILL birlikte gerekir: yalnız autowrap veren etiket kendi
	# min genişliğini metnin tamamı kadar ister ve kartı taşırır (tema süpürmesinin
	# clip_text/autowrap gotcha'sı).
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size = Vector2(0, 0)
	_label_keys[l] = key
	return l


# =============================================================================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC — projenin ilk-vazgeç konvansiyonu
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	Settings.flush()   # debounce penceresinde bekleyen yazımı panel kapanırken indir
	dismissed.emit()
	queue_free()
