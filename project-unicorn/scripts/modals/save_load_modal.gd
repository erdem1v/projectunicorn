extends Control

# Kaydet / Yükle modalı — tek sahne, iki mod. main.gd, EventBus.save_load_requested(mode)
# üzerine GameShell/ModalLayer'a mount eder ve add_child SONRASI populate(mode) çağırır
# (@onready referansları ancak o an dolar); modal kendini `dismissed` ile bırakır.
# process_mode = ALWAYS: tree paused iken de tıklanabilir.
#
# Okunamayan dosya satırı listeden düşmez: gerekçesiyle, yükleme aksiyonu kapalı görünür.

signal dismissed
signal load_requested(slot_id: String)

const MODE_SAVE := "save"

var _mode: String = ""

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
	_mode = mode
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
		_list.add_child(_build_row(slot))


func _build_row(slot: Dictionary) -> Control:
	var slot_id: String = String(slot.get("slot_id", ""))
	var label: String = String(slot.get("label", slot_id))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	col.add_child(UiFactory.make_label(label, &"BodySerif"))
	col.add_child(UiFactory.make_label(_meta_line(slot), &"RowMeta"))
	row.add_child(col)

	# Kaydet modunda bozuk bir dosyanın üstüne yazmak serbest: o slotu kurtarmanın en
	# doğrudan yolu.
	var action := Button.new()
	action.custom_minimum_size = Vector2(120, 34)
	if _mode == MODE_SAVE:
		action.text = tr("SAVE_OVERWRITE_OK")
		action.pressed.connect(_on_overwrite.bind(slot_id, label))
	else:
		action.text = tr("SAVE_LOAD_CONFIRM_OK")
		action.disabled = not bool(slot.get("loadable", false))
		action.pressed.connect(_on_load.bind(slot_id))
	row.add_child(action)

	var del := Button.new()
	del.custom_minimum_size = Vector2(80, 34)
	del.text = tr("SAVE_DELETE")
	del.pressed.connect(_confirm.bind("SAVE_DELETE_TITLE",
		tr("SAVE_DELETE_BODY").format({"label": label}), "SAVE_DELETE_OK", _do_delete.bind(slot_id)))
	row.add_child(del)

	return UiFactory.make_card(row, true, false)


func _meta_line(slot: Dictionary) -> String:
	if not bool(slot.get("loadable", false)):
		return tr(String(slot.get("error_key", "SAVE_ERR_CORRUPT")))
	var meta: Dictionary = slot.get("meta", {}) as Dictionary
	var parts: Array[String] = [
		tr("SAVE_META_DAY").format({"n": int(meta.get("day", 0))}),
		String(meta.get("phase_name", "")),
		tr("SAVE_META_CASH").format({"amount": UiTokens.format_money(int(meta.get("cash", 0)))}),
		tr("SAVE_META_MRR").format({"amount": UiTokens.format_money(int(meta.get("mrr", 0)))}),
		_stamp(int(slot.get("unix_time", 0))),
	]
	return " · ".join(PackedStringArray(parts.filter(func(p: String) -> bool: return p != "")))


func _stamp(unix_time: int) -> String:
	if unix_time <= 0:
		return ""
	# Gerçek dünya saati; alan sırası locale'e aittir (TR 19.08.2026, EN 08/19/2026).
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	return tr("SAVE_SLOT_TIMESTAMP").format({
		"day": "%02d" % d.day, "month": "%02d" % d.month, "year": d.year,
		"hour": "%02d" % d.hour, "minute": "%02d" % d.minute})


# --- Aksiyonlar ---

func _confirm(title_key: String, body: String, ok_key: String, on_confirm: Callable) -> void:
	EventBus.confirm_requested.emit({
		"title": tr(title_key),
		"body": body,
		"confirm_text": tr(ok_key),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": on_confirm,
	})


func _on_new_save() -> void:
	if SaveManager.can_save():
		_do_save(SaveManager.next_manual_slot_id())


func _on_overwrite(slot_id: String, label: String) -> void:
	if SaveManager.can_save():
		_confirm("SAVE_OVERWRITE_TITLE", tr("SAVE_OVERWRITE_BODY").format({"label": label}),
			"SAVE_OVERWRITE_OK", _do_save.bind(slot_id))


func _do_save(slot_id: String) -> void:
	SaveManager.save_to_slot(slot_id)
	_rebuild()


func _on_load(slot_id: String) -> void:
	# Yükleme sırasını main.gd yürütür ve bu modalı o sırada serbest bırakır.
	if SaveManager.has_unsaved_progress():
		_confirm("SAVE_LOAD_CONFIRM_TITLE", tr("SAVE_LOAD_CONFIRM_BODY"), "SAVE_LOAD_CONFIRM_OK",
			load_requested.emit.bind(slot_id))
	else:
		load_requested.emit(slot_id)


func _do_delete(slot_id: String) -> void:
	SaveManager.delete_slot(slot_id)
	_rebuild()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
