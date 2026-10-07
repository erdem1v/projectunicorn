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
# (SaveManager'ın tek kapısı), ana menü henüz yokken. Yükle penceresinin "Karara dön"ü menüyü de
# kapatır (grup system_menu). Dil menü açıkken değişebilir (Ayarlar üstünde): düğmeler ve gerekçeler
# anahtardır ve kendilerini çevirir, başlık ve tarih yeniden yazılır.

signal dismissed

const INBOX := preload("res://scripts/ui/components/inbox.gd")


func _ready() -> void:
	add_to_group(&"system_menu")
	($Dimmer as ColorRect).color = UiTokens.D_SCRIM
	_retranslate()
	EventBus.language_changed.connect(_retranslate.unbind(1))
	if not SaveManager.can_save():
		_lock(%SaveBtn, SaveManager.cannot_save_reason_key())
	_lock(%MainMenuBtn, "SYS_SOON")
	%ResumeBtn.pressed.connect(close)
	%SaveBtn.pressed.connect(EventBus.save_load_requested.emit.bind("save"))
	%LoadBtn.pressed.connect(EventBus.save_load_requested.emit.bind("load"))
	%SettingsBtn.pressed.connect(EventBus.settings_requested.emit)
	%QuitBtn.pressed.connect(_on_quit)
	%ResumeBtn.grab_focus()   # varsayılan odak GÜVENLİ taraf: yanlış Enter oyuna döner


## The head's title and the run's date and hour.
func _retranslate() -> void:
	%TitleLabel.text = Fmt.upper(tr("SYS_TITLE"))
	%DateLabel.text = INBOX.date_text(GameState.day, GameState.current_hour)


## A row that does not work now: the button off, its reason (a key) inside it on the right.
func _lock(button: Button, why_key: String) -> void:
	button.disabled = true
	var reason := UiFactory.make_label(why_key, &"Caption")
	reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	reason.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_child(reason)
	reason.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	reason.offset_right = -UiTokens.SPACE_XL


func _on_quit() -> void:
	# Kaydedilmemiş ilerleme yoksa doğrudan çık — boş bir onayla durdurmayız.
	if not SaveManager.has_unsaved_progress():
		get_tree().quit()
		return
	# Üç yol: kaydet ve çık / kaydetmeden çık / vazgeç. Kaydedilemezken (bir karar beklerken) Kaydet ve çık kapalıdır,
	# gerekçesi altında.
	EventBus.confirm_requested.emit({
		"title": tr("SYS_QUIT_TITLE"),
		"body": tr("SYS_QUIT_BODY"),
		"confirm_text": tr("SYS_QUIT_SAVE"),
		"locked": tr(SaveManager.cannot_save_reason_key()),
		"alt_text": tr("SYS_QUIT_DISCARD"),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": _save_and_quit,
		"on_alt": get_tree().quit,
	})


func _save_and_quit() -> void:
	# main.gd saves and toasts the result. Only a landed save clears the unsaved flag, so a
	# refusal or a failed write keeps the game open.
	EventBus.quicksave_requested.emit()
	if not SaveManager.has_unsaved_progress():
		get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC = en üstteki katmanı kapat
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	dismissed.emit()
	queue_free()
