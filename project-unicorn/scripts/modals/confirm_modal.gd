extends Control

# Genel amaçlı hafif onay modalı: main.gd, EventBus.confirm_requested(config) üzerine
# ModalLayer'a mount eder; modal kendini `dismissed` ile serbest bırakır (main.gd hızı geri yükler).
# config: {title, body, confirm_text, cancel_text, on_confirm: Callable}
# İsteğe bağlı üçüncü yol: {alt_text, on_alt: Callable}; anahtar yoksa buton gizli kalır.
# process_mode = ALWAYS (sahne pause'dayken de tıklanabilir); ESC = vazgeç.

signal confirmed
signal alt_selected
signal dismissed

# Üç butonlu hâlde butonlar 440'lık gövdenin iç genişliğine sığmıyor; panel genişler.
const PANEL_HALF_W_2BTN := 220.0
const PANEL_HALF_W_3BTN := 260.0

@onready var _panel: Panel = $CenterPanel
@onready var _title: Label = %TitleLabel
@onready var _body: Label = %BodyLabel
@onready var _confirm_btn: Button = %ConfirmBtn
@onready var _cancel_btn: Button = %CancelBtn
@onready var _alt_btn: Button = %AltBtn


func _ready() -> void:
	_confirm_btn.pressed.connect(_close.bind(confirmed))
	_alt_btn.pressed.connect(_close.bind(alt_selected))
	_cancel_btn.pressed.connect(_close)
	_cancel_btn.grab_focus()   # varsayılan odak GÜVENLİ taraf: yanlış Enter onaylamasın


func populate(cfg: Dictionary) -> void:
	_title.text = String(cfg.get("title", tr("UI_CONFIRM_TITLE")))
	_body.text = String(cfg.get("body", ""))
	_confirm_btn.text = String(cfg.get("confirm_text", tr("UI_CONFIRM")))
	_cancel_btn.text = String(cfg.get("cancel_text", tr("UI_DISMISS")))
	_alt_btn.text = String(cfg.get("alt_text", ""))
	_alt_btn.visible = _alt_btn.text != ""
	var half: float = PANEL_HALF_W_3BTN if _alt_btn.visible else PANEL_HALF_W_2BTN
	_panel.offset_left = -half
	_panel.offset_right = half


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close(choice: Signal = Signal()) -> void:
	if not choice.is_null():
		choice.emit()
	dismissed.emit()
	queue_free()
