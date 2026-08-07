extends Control

# ESC sistem menüsü (SaveManager task'ı). ConfirmModal/SettingsModal konvansiyonu:
# main.gd, EventBus.system_menu_requested üzerine GameShell/ModalLayer'a mount eder;
# modal kendini `dismissed` ile serbest bırakır, hızı main.gd geri yükler.
#
# process_mode = ALWAYS (.tscn kökünde 3). Çocuklar INHERIT — bir ALWAYS ebeveynin
# altında INHERIT de ALWAYS'e çözülür, bu yüzden tüm butonlar tree paused iken de
# tıklanabilir. Bu projenin EN SIK tekrarlanan yaşam-döngüsü hatası pause'a kapalı
# UI'dır (ENDGAME_DESIGN.md §"Pause-gated UI" bunu ayrıca yasalaştırıyor); doğrulaması
# 4x hızda menüyü açıp her butona tıklamaktır, göz kararı değil.
#
# Menü YALNIZ ModalLayer ve PanelLayer boşken açılır (game_shell._input). Zorunlu
# karar zorunlu kalır: olay modalı üstündeyken ESC bu menüyü açmaz.

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

	# Ana menü DEMO hazırlığında kendi tasarımıyla geliyor; slot şimdiden var ve
	# kilidi telgraflanıyor (oyunun "yakında" grameri) — sessiz bir ölü buton değil.
	_main_menu_btn.disabled = true
	_main_menu_btn.tooltip_text = tr("SYS_SOON")

	# Kaydetme, çözülmemiş bir karar ya da süren bir oturum varken kapalı —
	# gerekçesi SaveManager'ın tek kapısından okunur, burada yeniden icat edilmez.
	var can_save: bool = SaveManager.can_save()
	_save_btn.disabled = not can_save
	_reason.text = "" if can_save else tr(SaveManager.cannot_save_reason_key())
	_reason.visible = not can_save

	_resume_btn.pressed.connect(_close)
	_save_btn.pressed.connect(_on_save)
	_load_btn.pressed.connect(_on_load)
	_settings_btn.pressed.connect(_on_settings)
	_quit_btn.pressed.connect(_on_quit)

	_resume_btn.grab_focus()   # varsayılan odak GÜVENLİ taraf: yanlış Enter oyuna döner


func _on_save() -> void:
	EventBus.save_load_requested.emit("save")


func _on_load() -> void:
	EventBus.save_load_requested.emit("load")


func _on_settings() -> void:
	EventBus.settings_requested.emit()


func _on_quit() -> void:
	# Kaydedilmemiş ilerleme yoksa doğrudan çık — kullanıcıyı boş bir onayla durdurmayız.
	if not SaveManager.has_unsaved_progress():
		get_tree().quit()
		return
	# Üç yol: kaydet ve çık / kaydetmeden çık / vazgeç. ConfirmModal'ın isteğe
	# bağlı üçüncü butonu (alt_text + on_alt) tam olarak bunun için eklendi.
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
	# Kaydedilemiyorsa (karar ekranı) çıkışı SESSİZCE yutmayız: gerekçe zaten
	# menüde yazılı, quit butonu da o durumda buraya gelmiş olur.
	if SaveManager.can_save():
		SaveManager.quicksave()
	get_tree().quit()


func _quit_now() -> void:
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC = en üstteki katmanı kapat (proje konvansiyonu)
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
