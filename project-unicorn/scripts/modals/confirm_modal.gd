extends Control

# Genel amaçlı hafif onay modalı (SettingsModal konvansiyonu): main.gd,
# EventBus.confirm_requested(config) üzerine GameShell/ModalLayer'a mount eder;
# modal kendini `dismissed` ile serbest bırakır (main.gd hızı geri yükler).
# İlk kullanıcı: Tracker Card'ın build-iptal çarpısı. config sözleşmesi:
#   {title, body, confirm_text, cancel_text, on_confirm: Callable}
# process_mode = ALWAYS (sahne pause'dayken de tıklanabilir); ESC = vazgeç.

signal confirmed
signal dismissed

@onready var _title: Label = %TitleLabel
@onready var _body: Label = %BodyLabel
@onready var _confirm_btn: Button = %ConfirmBtn
@onready var _cancel_btn: Button = %CancelBtn


func _ready() -> void:
	_confirm_btn.pressed.connect(_on_confirm)
	_cancel_btn.pressed.connect(_close)
	_cancel_btn.grab_focus()   # varsayılan odak GÜVENLİ taraf (yanlış Enter iptali onaylamasın)


func populate(cfg: Dictionary) -> void:
	_title.text = String(cfg.get("title", "Emin misin?"))
	_body.text = String(cfg.get("body", ""))
	_confirm_btn.text = String(cfg.get("confirm_text", "Onayla"))
	_cancel_btn.text = String(cfg.get("cancel_text", "Vazgeç"))


func _on_confirm() -> void:
	confirmed.emit()
	dismissed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC = vazgeç (proje konvansiyonu)
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
