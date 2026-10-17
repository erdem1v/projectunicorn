extends Control

# ESC sistem menüsü. main.gd, EventBus.system_menu_requested üzerine
# GameShell/ModalLayer'a mount eder; modal kendini `dismissed` ile serbest bırakır,
# hızı main.gd geri yükler. Başlığında koşunun tarihi ve saati.
#
# Kök process_mode = ALWAYS (.tscn'de 3); INHERIT çocuklar da ALWAYS'e çözülür, bu
# yüzden tüm butonlar tree paused iken de tıklanabilir. Pause'a kapalı UI bu projenin
# en sık tekrarlanan yaşam-döngüsü hatasıdır; doğrulaması 4x hızda menüyü açıp her
# butona tıklamaktır.
#
# Şu an çalışmayan satır kapalıdır ve gerekçesi satırının sağında okunur: Kaydet kaydedilemezken
# (SaveManager'ın tek kapısı); açık Kaydet ve Yükle orada kısayollarını gösterir. Yükle penceresinin "Karara
# dön"ü menüyü de kapatır (grup system_menu).
# Dil menü açıkken değişebilir (Ayarlar üstünde): düğmeler ve gerekçeler anahtardır ve kendilerini
# çevirir, başlık ve tarih yeniden yazılır.

signal dismissed
signal main_menu_requested
signal exit_save_requested

const INBOX := preload("res://scripts/ui/components/inbox.gd")


func _ready() -> void:
	add_to_group(&"system_menu")
	($Dimmer as ColorRect).color = UiTokens.D_SCRIM
	_retranslate()
	EventBus.language_changed.connect(_retranslate.unbind(1))
	if SaveManager.can_save():
		_aside(%SaveBtn, "SYS_HINT_F5")
	else:
		%SaveBtn.disabled = true
		_aside(%SaveBtn, SaveManager.cannot_save_reason_key())
	_aside(%LoadBtn, "SYS_HINT_F9")
	%ResumeBtn.pressed.connect(close)
	%SaveBtn.pressed.connect(EventBus.save_load_requested.emit.bind("save"))
	%LoadBtn.pressed.connect(EventBus.save_load_requested.emit.bind("load"))
	%SettingsBtn.pressed.connect(EventBus.settings_requested.emit)
	%MainMenuBtn.pressed.connect(_on_main_menu)
	%QuitBtn.pressed.connect(_on_quit)
	%ResumeBtn.grab_focus()   # varsayılan odak GÜVENLİ taraf: yanlış Enter oyuna döner


## The head's title and the run's date and hour.
func _retranslate() -> void:
	%TitleLabel.text = Fmt.upper(tr("SYS_TITLE"))
	%DateLabel.text = INBOX.date_text(GameState.day, MailClock.now())


## A key inside a row, on its right: the row's shortcut, or why it does not work now.
func _aside(button: Button, key: String) -> void:
	var aside := UiFactory.make_label(key, &"Caption")
	aside.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	aside.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_child(aside)
	aside.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	aside.offset_right = -UiTokens.SPACE_XL


func _on_main_menu() -> void:
	var weeks: int = GameState.day - SaveManager.last_saved_at.x
	_leave(main_menu_requested.emit, "SYS_MENU_TITLE",
		tr("SYS_MENU_BODY_WEEKS").format({"n": weeks}) if weeks > 0 else tr("SYS_QUIT_BODY"), "SYS_MENU_SAVE",
		"SYS_MENU_DISCARD")


func _on_quit() -> void:
	_leave(get_tree().quit, "SYS_QUIT_TITLE", tr("SYS_QUIT_BODY"), "SYS_QUIT_SAVE", "SYS_QUIT_DISCARD")


## Kaydedilmemiş ilerleme yoksa doğrudan `leave`: boş bir onayla durdurmayız. Varsa üç yol: kaydet ve git /
## kaydetmeden git / vazgeç. Kaydedilemezken (bir karar beklerken) kaydet ve git kapalıdır, gerekçesi altında.
func _leave(leave: Callable, title_key: String, body: String, save_key: String, discard_key: String) -> void:
	if not SaveManager.has_unsaved_progress():
		leave.call()
		return
	EventBus.confirm_requested.emit({
		"title": tr(title_key),
		"body": body,
		"confirm_text": tr(save_key),
		"locked": tr(SaveManager.cannot_save_reason_key()),
		"alt_text": tr(discard_key),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": _save_and.bind(leave),
		"on_alt": leave,
	})


func _save_and(leave: Callable) -> void:
	# main.gd saves into the run's autosaves and toasts the result. Only a landed save clears the unsaved progress, so
	# a refusal or a failed write keeps the game open.
	exit_save_requested.emit()
	if not SaveManager.has_unsaved_progress():
		leave.call()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC = en üstteki katmanı kapat
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	dismissed.emit()
	queue_free()
