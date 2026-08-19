extends Control

# Kaydet / Yükle modalı — TEK sahne, İKİ mod (SaveManager task'ı §5.5).
# ConfirmModal konvansiyonu: main.gd, EventBus.save_load_requested(mode) üzerine
# GameShell/ModalLayer'a mount eder ve add_child SONRASI populate(mode) çağırır
# (@onready referansları ancak o an dolar); modal kendini `dismissed` ile bırakır.
#
# process_mode = ALWAYS (.tscn kökünde 3) — tree paused iken de tıklanabilir.
#
# UI POLİTİKASI: çalışan yer tutucu, mevcut tema. Küçük resim yok, metin var.
# Terminal-reçetesi giydirme global UI turunda gelecek — burada süslemiyoruz.
#
# Slot satırları SaveManager.list_slots() sözleşmesinden kurulur:
#   {slot_id, kind: "manual"|"auto"|"quick", label, meta, loadable: bool,
#    error_key: String, unix_time: int}
# OKUNAMAYAN dosya satırı LİSTEDEN DÜŞMEZ: gerekçesiyle birlikte, aksiyonu kapalı
# olarak görünür. Sessizce kaybolan bir kayıt, bozuk bir kayıttan daha kötüdür.

signal dismissed
signal load_requested(slot_id: String)

const MODE_SAVE := "save"
const MODE_LOAD := "load"

var _mode: String = MODE_LOAD

@onready var _title: Label = %TitleLabel
@onready var _empty: Label = %EmptyLabel
@onready var _list: VBoxContainer = %SlotList
@onready var _new_btn: Button = %NewSaveBtn
@onready var _close_btn: Button = %CloseBtn


func _ready() -> void:
	_close_btn.text = tr("SET_CLOSE")
	_new_btn.text = tr("SAVE_NEW_SLOT")
	_empty.text = tr("SAVE_EMPTY")
	_close_btn.pressed.connect(_close)
	_new_btn.pressed.connect(_on_new_save)
	_close_btn.grab_focus()


func populate(mode: String) -> void:
	_mode = mode if mode == MODE_SAVE else MODE_LOAD
	_title.text = tr("SAVE_TITLE_SAVE") if _mode == MODE_SAVE else tr("SAVE_TITLE_LOAD")
	_new_btn.visible = _mode == MODE_SAVE
	_rebuild()


# --- Liste ---

func _rebuild() -> void:
	for child in _list.get_children():
		child.queue_free()

	var slots: Array = SaveManager.list_slots()
	_empty.visible = slots.is_empty()
	for slot in slots:
		_list.add_child(_build_row(slot as Dictionary))


func _build_row(slot: Dictionary) -> Control:
	var loadable: bool = bool(slot.get("loadable", false))
	var slot_id: String = String(slot.get("slot_id", ""))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	col.add_child(UiFactory.make_label(String(slot.get("label", slot_id)), &"BodySerif"))
	col.add_child(UiFactory.make_label(_meta_line(slot), &"RowMeta"))
	row.add_child(col)

	# YÜKLE modunda okunamayan satırın aksiyonu kapalı; KAYDET modunda üzerine
	# yazmak hâlâ serbest — bozuk bir dosyanın üstüne sağlam kayıt yazmak, o slotu
	# kurtarmanın en doğrudan yolu.
	var action := Button.new()
	action.custom_minimum_size = Vector2(120, 34)
	if _mode == MODE_SAVE:
		action.text = tr("SAVE_OVERWRITE_OK")
		action.pressed.connect(_on_overwrite.bind(slot))
	else:
		action.text = tr("SAVE_LOAD_CONFIRM_OK")
		action.disabled = not loadable
		action.pressed.connect(_on_load.bind(slot))
	row.add_child(action)

	var del := Button.new()
	del.custom_minimum_size = Vector2(80, 34)
	del.text = tr("SAVE_DELETE")
	del.pressed.connect(_on_delete.bind(slot))
	row.add_child(del)

	return UiFactory.make_card(row, true, false)


func _meta_line(slot: Dictionary) -> String:
	if not bool(slot.get("loadable", false)):
		return tr(String(slot.get("error_key", "SAVE_ERR_CORRUPT")))
	var meta: Dictionary = slot.get("meta", {}) as Dictionary
	var parts: Array[String] = []
	parts.append(tr("SAVE_META_DAY").format({"n": int(meta.get("day", 0))}))
	parts.append(String(meta.get("phase_name", "")))
	parts.append(tr("SAVE_META_CASH").format({"amount": UiTokens.format_money(int(meta.get("cash", 0)))}))
	parts.append(tr("SAVE_META_MRR").format({"amount": UiTokens.format_money(int(meta.get("mrr", 0)))}))
	parts.append(_stamp(int(slot.get("unix_time", 0))))
	var out: Array[String] = []
	for p in parts:
		if p != "":
			out.append(p)
	return " · ".join(out)


func _stamp(unix_time: int) -> String:
	if unix_time <= 0:
		return ""
	# Sayısal tarih — locale'den bağımsız, anahtar gerektirmez.
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	# Real-world wall clock on the save slot, not in-fiction time. The FIELD ORDER is a
	# locale property: TR writes 19.08.2026, EN writes 08/19/2026.
	return tr("SAVE_SLOT_TIMESTAMP").format({
		"day": "%02d" % d.day, "month": "%02d" % d.month, "year": d.year,
		"hour": "%02d" % d.hour, "minute": "%02d" % d.minute})


# --- Aksiyonlar ---

func _on_new_save() -> void:
	if not SaveManager.can_save():
		return
	SaveManager.save_to_slot(SaveManager.next_manual_slot_id())
	_rebuild()


func _on_overwrite(slot: Dictionary) -> void:
	if not SaveManager.can_save():
		return
	EventBus.confirm_requested.emit({
		"title": tr("SAVE_OVERWRITE_TITLE"),
		"body": tr("SAVE_OVERWRITE_BODY").format({"label": String(slot.get("label", ""))}),
		"confirm_text": tr("SAVE_OVERWRITE_OK"),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": _do_overwrite.bind(String(slot.get("slot_id", ""))),
	})


func _do_overwrite(slot_id: String) -> void:
	SaveManager.save_to_slot(slot_id)
	_rebuild()


func _on_load(slot: Dictionary) -> void:
	var slot_id: String = String(slot.get("slot_id", ""))
	if not SaveManager.has_unsaved_progress():
		_emit_load(slot_id)
		return
	EventBus.confirm_requested.emit({
		"title": tr("SAVE_LOAD_CONFIRM_TITLE"),
		"body": tr("SAVE_LOAD_CONFIRM_BODY"),
		"confirm_text": tr("SAVE_LOAD_CONFIRM_OK"),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": _emit_load.bind(slot_id),
	})


func _emit_load(slot_id: String) -> void:
	# Yükleme sırasını main.gd yürütür (shell teardown → reset → restore → remount);
	# bu modal onun bir parçası olarak serbest bırakılır, kendini kapatmaz.
	load_requested.emit(slot_id)


func _on_delete(slot: Dictionary) -> void:
	EventBus.confirm_requested.emit({
		"title": tr("SAVE_DELETE_TITLE"),
		"body": tr("SAVE_DELETE_BODY").format({"label": String(slot.get("label", ""))}),
		"confirm_text": tr("SAVE_DELETE_OK"),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": _do_delete.bind(String(slot.get("slot_id", ""))),
	})


func _do_delete(slot_id: String) -> void:
	SaveManager.delete_slot(slot_id)
	_rebuild()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC = en üstteki katmanı kapat
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
