extends Control

# Kaydet / Yükle modalı — tek sahne, iki mod. main.gd, EventBus.save_load_requested(mode)
# üzerine GameShell/ModalLayer'a mount eder ve add_child SONRASI populate(mode) çağırır
# (@onready referansları ancak o an dolar); modal kendini `dismissed` ile bırakır.
# process_mode = ALWAYS: tree paused iken de tıklanabilir.
#
# Kaydet modunda başta yeni kayıt yuvası (koşunun künyesiyle), altında kayıtlar. Liste boşken pencere
# kısadır; kayıt varken tam boyunu tutar ve liste kayar. Okunamayan dosya listeden düşmez: gerekçesiyle,
# yükleme aksiyonu kapalı görünür. Bir karar beklerken menüde Kaydet kapalıdır; Yükle penceresinde yükleme
# kapalıdır (main._load_slot), başta karar şeridi gerekçesiyle ve karara dönüşüyle durur, silme açık kalır.

signal dismissed
signal load_requested(slot_id: String)

const GATE_STRIP := preload("res://scripts/ui/components/gate_strip.gd")
const INBOX := preload("res://scripts/ui/components/inbox.gd")
const MODE_SAVE := "save"
## The window's height while it lists saves and, by mode, while it has none; a save's slot; the well of its glyph.
const FULL_H := 660.0
const EMPTY_H := {"save": 420.0, "load": 340.0}
const SLOT_H := 72.0
const WELL := 40

var _mode: String = ""

@onready var _panel: PanelContainer = %Panel
@onready var _title: Label = %TitleLabel
@onready var _scroll: ScrollContainer = %Scroll
@onready var _list: VBoxContainer = %SlotList
@onready var _close_btn: Button = %CloseBtn


func _ready() -> void:
	($Dimmer as ColorRect).color = UiTokens.D_SCRIM
	_close_btn.pressed.connect(_close)
	_close_btn.grab_focus()


func populate(mode: String) -> void:
	_mode = mode
	_title.text = Fmt.upper(tr("SAVE_TITLE_SAVE" if _mode == MODE_SAVE else "SAVE_TITLE_LOAD"))
	if EventGate.active_id() != "":
		%Head.add_sibling(GATE_STRIP.new(tr("GATE_ANSWER_FIRST"), _back_to_decision))
	_rebuild()


# --- Liste ---

func _rebuild() -> void:
	UiFactory.clear(_list)
	var slots: Array = SaveManager.list_slots()
	if _mode == MODE_SAVE:
		_list.add_child(_new_slot())
		if not slots.is_empty():
			var head := SprintUiShared.section("SAVE_LIST_HEADER")
			_list.add_child(SprintUiShared.pad(head, Vector4i(0, UiTokens.SPACE_M, 0, 0)))
	for slot in slots:
		_list.add_child(_slot_row(slot))
	if slots.is_empty():
		var glyph: String = "res://assets/icons/util/%s.svg" % ("save" if _mode == MODE_SAVE else "load")
		_list.add_child(SprintUiShared.pad(UiFactory.D_empty(glyph, tr("SAVE_EMPTY"), &"NoteMuted"),
			Vector4i(0, UiTokens.SPACE_4XL, 0, UiTokens.SPACE_4XL)))
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if slots.is_empty() \
		else ScrollContainer.SCROLL_MODE_AUTO
	_panel.custom_minimum_size.y = EMPTY_H[_mode] if slots.is_empty() else FULL_H


## The new save's slot, dashed: this run's line and the one amber key.
func _new_slot() -> PanelContainer:
	var doc := _slot(tr("SAVE_NEW_SLOT"), "", _meta_line({"loadable": true, "meta": SaveManager.build_meta()}),
		_well("res://assets/icons/util/plus.svg", UiTokens.D_INK_3, true), &"SprintCardPlanned",
		[[tr("SYS_SAVE"), &"PrimaryButtonDarkSmall", func() -> void: _do_save(SaveManager.next_manual_slot_id()),
			false]])
	HRUiShared.D_dashed(doc, UiTokens.D_LINE_2, UiTokens.D_CUT_SM)
	return doc


func _slot_row(slot: Dictionary) -> PanelContainer:
	var slot_id: String = String(slot.slot_id)
	var label: String = String(slot.label)
	var loadable: bool = bool(slot.loadable)
	var delete := [tr("SAVE_DELETE"), &"GhostButtonSmall", _confirm.bind("SAVE_DELETE_TITLE",
		tr("SAVE_DELETE_BODY").format({"label": label}), "SAVE_DELETE_OK", _do_delete.bind(slot_id)), false]
	var action: Array
	if _mode == MODE_SAVE:
		# Kaydet modunda bozuk bir dosyanın üstüne yazmak serbest: o slotu kurtarmanın en doğrudan yolu.
		action = [tr("SAVE_OVERWRITE_OK"), &"SecondaryButtonSmall", _on_overwrite.bind(slot_id, label), false]
	else:
		action = [tr("SAVE_LOAD_CONFIRM_OK"), &"SecondaryButtonSmall", _on_load.bind(slot_id),
			EventGate.active_id() != "" or not loadable]
	var well: Control = _well("res://assets/icons/util/save.svg", UiTokens.D_INK_3) if loadable \
		else _well("res://assets/icons/util/warn.svg", UiTokens.D_warn())
	return _slot(label, _stamp(int(slot.unix_time)), _meta_line(slot), well, &"DealDoc", [delete, action])


## A save's document: its well, its name with its time on the right over its line, then its keys, each
## [text, look, on_press, off].
func _slot(title: String, stamp: String, line: String, well: Control, look: StringName, keys: Array) -> PanelContainer:
	var doc := PanelContainer.new()
	doc.theme_type_variation = look
	doc.custom_minimum_size.y = SLOT_H
	var row := SprintUiShared.box(UiTokens.SPACE_XL)
	doc.add_child(row)
	row.add_child(well)
	var text := SprintUiShared.column(UiTokens.SPACE_XXS)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	head.add_child(UiFactory.make_label(title, &"DataStrong"))
	var time := UiFactory.make_label(stamp, &"CaptionFaint")
	time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	time.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head.add_child(time)
	text.add_child(head)
	text.add_child(SprintUiShared.prose(line, &"Caption"))
	row.add_child(text)
	for key: Array in keys:
		var b := Button.new()
		b.text = key[0]
		b.theme_type_variation = key[1]
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b.pressed.connect(key[2])
		b.disabled = key[3]
		row.add_child(b)
	return doc


## A slot's well and its glyph; the new save's well is dashed.
func _well(glyph: String, ink: Color, dashed := false) -> Control:
	var well: Control = Control.new() if dashed else Panel.new()
	well.custom_minimum_size = Vector2.ONE * WELL
	well.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if dashed:
		HRUiShared.D_dashed(well, UiTokens.D_LINE_3)
	else:
		well.theme_type_variation = &"IconWell"
	var icon := UiFactory.make_glyph(glyph, UiTokens.D_ICON_CONTROL, ink)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE,
		(WELL - UiTokens.D_ICON_CONTROL) / 2)
	well.add_child(icon)
	return well


func _meta_line(slot: Dictionary) -> String:
	if not bool(slot.loadable):
		return tr(String(slot.get("error_key", "SAVE_ERR_CORRUPT")))
	var meta: Dictionary = slot.meta
	return " · ".join([
		tr("SAVE_META_DAY").format({"date": Fmt.date_line(GameState.get_date_dict(int(meta.day)))}),
		tr(GameState.PHASE_KEYS[int(meta.phase) - 1]),
		tr("SAVE_META_CASH").format({"amount": Fmt.money_exact(int(meta.cash))}),
		tr("SAVE_META_MRR").format({"amount": Fmt.money(int(meta.mrr))}),
	])


func _stamp(unix_time: int) -> String:
	if unix_time <= 0:
		return ""
	# Gerçek dünya saati; alan sırası locale'e aittir (TR 19.08.2026, EN 08/19/2026).
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	return tr("SAVE_SLOT_TIMESTAMP").format({
		"day": "%02d" % d.day, "month": "%02d" % d.month, "year": d.year,
		"hour": "%02d" % d.hour, "minute": "%02d" % d.minute})


# --- Aksiyonlar ---

## A question over the dialog. Each one here destroys what it names (a save, or the weeks since the last one): the
## danger key.
func _confirm(title_key: String, body: String, ok_key: String, on_confirm: Callable) -> void:
	EventBus.confirm_requested.emit({
		"title": tr(title_key),
		"body": body,
		"confirm_text": tr(ok_key),
		"cancel_text": tr("SYS_CANCEL"),
		"on_confirm": on_confirm,
		"danger": true,
	})


func _on_overwrite(slot_id: String, label: String) -> void:
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


## Karara dön: the menu that opened this window closes with it, and the inbox opens on the decision.
func _back_to_decision() -> void:
	get_tree().call_group(&"system_menu", &"close")
	_close()
	INBOX.show("active")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
