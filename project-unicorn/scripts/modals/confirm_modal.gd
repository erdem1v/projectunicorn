extends Control

# Genel amaçlı hafif onay modalı: main.gd, EventBus.confirm_requested(config) üzerine
# ModalLayer'a mount eder; modal kendini `dismissed` ile serbest bırakır (main.gd hızı geri yükler).
# config: {title, body, confirm_text, cancel_text, on_confirm: Callable}
# İsteğe bağlı: {danger: true} yıkıcı onaydır, tehlike düğmesiyle; {locked: <gerekçe>} onayı kapatır, gerekçesi
# altında okunur. Üçüncü yol {alt_text, on_alt: Callable}: tek kullananı çıkışın "Çık"ıdır, son kayıttan beri
# oynananı siler, hep tehlike düğmesidir; güvenli Vazgeç o zaman sola geçer. Anahtar yoksa düğme gizli kalır.
# process_mode = ALWAYS (sahne pause'dayken de tıklanabilir); ESC = vazgeç.

signal confirmed
signal alt_selected
signal dismissed

## Üç düğme, sahnedeki iki düğmelik genişliğe sığmaz.
const WIDTH_THREE := 520.0

@onready var _panel: PanelContainer = %Panel
@onready var _title: Label = %TitleLabel
@onready var _body: Label = %BodyLabel
@onready var _cancel_btn: Button = %CancelBtn
@onready var _spring: Control = %Spring
@onready var _alt_btn: Button = %AltBtn
@onready var _confirm_btn: Button = %ConfirmBtn
@onready var _reason: Label = %ReasonLabel


func _ready() -> void:
	($Dimmer as ColorRect).color = UiTokens.D_SCRIM
	_alt_btn.theme_type_variation = UiTokens.D_variation(&"DangerButton")
	_confirm_btn.pressed.connect(_close.bind(confirmed))
	_alt_btn.pressed.connect(_close.bind(alt_selected))
	_cancel_btn.pressed.connect(_close)
	_cancel_btn.grab_focus()   # varsayılan odak GÜVENLİ taraf: yanlış Enter onaylamasın


func populate(cfg: Dictionary) -> void:
	_title.text = String(cfg.get("title", tr("UI_CONFIRM_TITLE")))
	_body.text = String(cfg.get("body", ""))
	_confirm_btn.text = String(cfg.get("confirm_text", tr("UI_CONFIRM")))
	_cancel_btn.text = String(cfg.get("cancel_text", tr("UI_DISMISS")))
	if cfg.get("danger", false):
		_confirm_btn.theme_type_variation = UiTokens.D_variation(&"DangerButton")
	_reason.text = String(cfg.get("locked", ""))
	_reason.visible = _reason.text != ""
	_confirm_btn.disabled = _reason.visible
	_alt_btn.text = String(cfg.get("alt_text", ""))
	if _alt_btn.text != "":
		_alt_btn.show()
		_spring.show()
		_cancel_btn.theme_type_variation = &"GhostButton"
		_panel.custom_minimum_size.x = WIDTH_THREE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close(choice: Signal = Signal()) -> void:
	if not choice.is_null():
		choice.emit()
	dismissed.emit()
	queue_free()
