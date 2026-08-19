extends Control

# Genel amaçlı hafif onay modalı (SettingsModal konvansiyonu): main.gd,
# EventBus.confirm_requested(config) üzerine GameShell/ModalLayer'a mount eder;
# modal kendini `dismissed` ile serbest bırakır (main.gd hızı geri yükler).
# İlk kullanıcı: Tracker Card'ın build-iptal çarpısı. config sözleşmesi:
#   {title, body, confirm_text, cancel_text, on_confirm: Callable}
# İSTEĞE BAĞLI ÜÇÜNCÜ YOL (SaveManager task'ı): {alt_text, on_alt: Callable}.
#   Anahtar yoksa buton gizli kalır — mevcut yedi çağıran hiç değişmedi; ek
#   anahtar eklemek kayıt şemasındaki ileri-uyumluluk disiplininin aynısı.
#   İlk kullanıcı: "Kaydedilmemiş ilerleme var" → Kaydet ve çık / Çık / Vazgeç.
# process_mode = ALWAYS (sahne pause'dayken de tıklanabilir); ESC = vazgeç.

signal confirmed
signal alt_selected
signal dismissed

# Üç butonlu hâlde 120 + 130 + 140 + ayraçlar, 440'lık gövdenin 384 px'lik iç
# genişliğine sığmıyor — o durumda panel genişler. Yerleşim script'in hakkı
# (UI/STYLE LAW md.4); renk/boyut taşımıyoruz.
const PANEL_HALF_W_2BTN := 220.0
const PANEL_HALF_W_3BTN := 260.0

@onready var _panel: Panel = $CenterPanel
@onready var _title: Label = %TitleLabel
@onready var _body: Label = %BodyLabel
@onready var _confirm_btn: Button = %ConfirmBtn
@onready var _cancel_btn: Button = %CancelBtn
@onready var _alt_btn: Button = %AltBtn


func _ready() -> void:
	_confirm_btn.pressed.connect(_on_confirm)
	_alt_btn.pressed.connect(_on_alt)
	_cancel_btn.pressed.connect(_close)
	_cancel_btn.grab_focus()   # varsayılan odak GÜVENLİ taraf (yanlış Enter iptali onaylamasın)


func populate(cfg: Dictionary) -> void:
	_title.text = String(cfg.get("title", tr("UI_CONFIRM_TITLE")))
	_body.text = String(cfg.get("body", ""))
	_confirm_btn.text = String(cfg.get("confirm_text", tr("UI_CONFIRM")))
	_cancel_btn.text = String(cfg.get("cancel_text", tr("UI_DISMISS")))

	var alt_text: String = String(cfg.get("alt_text", ""))
	_alt_btn.visible = alt_text != ""
	_alt_btn.text = alt_text
	var half: float = PANEL_HALF_W_3BTN if _alt_btn.visible else PANEL_HALF_W_2BTN
	_panel.offset_left = -half
	_panel.offset_right = half


func _on_confirm() -> void:
	confirmed.emit()
	dismissed.emit()
	queue_free()


func _on_alt() -> void:
	alt_selected.emit()
	dismissed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC = vazgeç (proje konvansiyonu)
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
