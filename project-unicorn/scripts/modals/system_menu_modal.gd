extends Control

# ESC sistem menüsü. main.gd, EventBus.system_menu_requested üzerine
# GameShell/ModalLayer'a mount eder; modal kendini `dismissed` ile serbest bırakır,
# hızı main.gd geri yükler.
#
# Kök process_mode = ALWAYS (.tscn'de 3); INHERIT çocuklar da ALWAYS'e çözülür, bu
# yüzden tüm butonlar tree paused iken de tıklanabilir. Pause'a kapalı UI bu projenin
# en sık tekrarlanan yaşam-döngüsü hatasıdır; doğrulaması 4x hızda menüyü açıp her
# butona tıklamaktır.
#
# Menü YALNIZ ModalLayer ve PanelLayer boşken açılır (game_shell._input): olay modalı
# üstündeyken ESC bu menüyü açmaz, zorunlu karar zorunlu kalır.

signal dismissed

@onready var _title: Label = %TitleLabel
@onready var _resume_btn: Button = %ResumeBtn
@onready var _save_btn: Button = %SaveBtn
@onready var _load_btn: Button = %LoadBtn
@onready var _settings_btn: Button = %SettingsBtn
@onready var _main_menu_btn: Button = %MainMenuBtn
@onready var _soon_badge: Label = %SoonBadge
@onready var _quit_btn: Button = %QuitBtn
@onready var _reason: Label = %ReasonLabel


func _ready() -> void:
	_title.text = tr("SYS_TITLE")
	_resume_btn.text = tr("SYS_RESUME")
	_save_btn.text = tr("SYS_SAVE")
	_load_btn.text = tr("SYS_LOAD")
	_settings_btn.text = tr("SYS_SETTINGS")
	_main_menu_btn.text = tr("SYS_MAIN_MENU")
	_soon_badge.text = tr("SYS_SOON")
	_quit_btn.text = tr("SYS_QUIT")

	# Ana menü henüz yok; slot (sahnede disabled) kilidini "yakında" rozetiyle telgraflar.
	_main_menu_btn.tooltip_text = tr("SYS_SOON")

	# Kaydetme, çözülmemiş bir karar ya da süren bir oturum varken kapalı; gerekçe
	# SaveManager'ın tek kapısından okunur.
	var can_save: bool = SaveManager.can_save()
	_save_btn.disabled = not can_save
	_reason.visible = not can_save
	if not can_save:
		_reason.text = tr(SaveManager.cannot_save_reason_key())

	_resume_btn.pressed.connect(_close)
	_save_btn.pressed.connect(func() -> void: EventBus.save_load_requested.emit("save"))
	_load_btn.pressed.connect(func() -> void: EventBus.save_load_requested.emit("load"))
	_settings_btn.pressed.connect(func() -> void: EventBus.settings_requested.emit())
	_quit_btn.pressed.connect(_on_quit)

	_resume_btn.grab_focus()   # varsayılan odak GÜVENLİ taraf: yanlış Enter oyuna döner


func _on_quit() -> void:
	# Kaydedilmemiş ilerleme yoksa doğrudan çık — boş bir onayla durdurmayız.
	if not SaveManager.has_unsaved_progress():
		_quit_now()
		return
	# Üç yol: kaydet ve çık / kaydetmeden çık / vazgeç.
	EventBus.confirm_requested.emit({
		"title": tr("SYS_QUIT_TITLE"),
		"body": tr("SYS_QUIT_BODY"),
		"confirm_text": tr("SYS_QUIT_SAVE"),
		"alt_text": tr("SYS_QUIT_DISCARD"),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": _save_and_quit,
		"on_alt": _quit_now,
	})


func _save_and_quit() -> void:
	# Kaydedilemiyorsa (karar ekranı) yine çıkılır; gerekçe menüde zaten yazılı.
	if SaveManager.can_save():
		SaveManager.quicksave()
	_quit_now()


func _quit_now() -> void:
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC = en üstteki katmanı kapat
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
