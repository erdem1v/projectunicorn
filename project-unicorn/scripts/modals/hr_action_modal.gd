extends Control

# İK EYLEM MODALI — ZAM YAP / TERFİ (kaydırıcılı) · İŞTEN ÇIKAR (kaydırıcısız), tek kabuk.
#
# ConfirmModal değil: tek autowrap etiketi, üç kayıt türünü (delta / olgu / kural) ayıramaz, yalnız
# sıfırı geçen değeri kırmızıya çeviremez, kaydırıcı taşıyamaz. Yaşam döngüsü ve host ConfirmModal
# ile ortak: `EventBus.confirm_requested` + `main.gd::_on_confirm_requested`, config'te
# `"modal": "hr_action"`. Tek onay, saati durdurma ve ESC = vazgeç orada.
#
# Başlıkta eylem ve kişi; gövdede (varsa) yüzde ve kaydırıcı, sonra kayıtlar: deltanın oku var,
# olgunun yok, kuralın sayısı yok ve bilgi glifiyle durur. Bedeller (kıdem tazminatı, aylık fark,
# moral düşümü) bedel diskiyle mürekkeptir; kırmızı yalnız sıfırın altına inen kasadır ve o zaman
# kepenk notu gelir.

signal confirmed
signal dismissed

const WIDTH := 480
const ARROW := "→"

var _preview: Callable = Callable()     # (int) -> Dictionary
var _commit: Callable = Callable()      # (int) -> bool
var _commit_key: String = ""
var _slider: HSlider = null
var _pct: Label
var _rows: VBoxContainer
var _note: MarginContainer   # the shutter note, shown only while the cash would go below zero
var _commit_btn: Button
var _person_id: String = ""


## Sözleşme:
##   {title, person: Character, on_commit: Callable(int)->bool,
##    slider: {min, max, start}, preview: Callable(int)->Dictionary, commit_key   # kaydırıcılı hâl
##    rows: Array, commit_text, danger}                                            # kaydırıcısız hâl
func populate(cfg: Dictionary) -> void:
	_commit_key = String(cfg.get("commit_key", ""))
	_commit = cfg.get("on_commit", Callable())
	_preview = cfg.get("preview", Callable())
	var scrim := ColorRect.new()
	scrim.color = UiTokens.D_SCRIM
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	var shell := PanelContainer.new()
	shell.theme_type_variation = &"DialogPanel"
	shell.custom_minimum_size.x = WIDTH
	centre.add_child(shell)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	shell.add_child(col)

	var head := VBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_L)
	head.add_child(UiFactory.make_label(String(cfg.get("title", "")), &"DialogTitle"))
	var person: Character = cfg["person"]
	head.add_child(HRUiShared.D_who(person, UiTokens.D_AVATAR_ROW))
	# The person's Kadro row stays raised while the dialog is open.
	_person_id = person.id
	get_tree().call_group(HRLedger.VIEWS_GROUP, &"hold_person", _person_id, true)
	col.add_child(_inset(head, UiTokens.SPACE_XXL, UiTokens.SPACE_3XL, 0))

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 0)
	var slider_cfg: Dictionary = cfg.get("slider", {})
	if not slider_cfg.is_empty():
		_pct = UiFactory.make_label("", &"KpiValue", UiTokens.D_INK_1)
		body.add_child(_pct)
		_slider = HSlider.new()
		_slider.min_value = int(slider_cfg["min"])
		_slider.max_value = int(slider_cfg["max"])
		_slider.value = int(slider_cfg["start"])
		_slider.step = 1
		body.add_child(_inset(_slider, UiTokens.SPACE_M, 0, 0))
		var ends := HBoxContainer.new()
		ends.add_child(UiFactory.make_label(Fmt.percent(int(slider_cfg["min"]), 0), &"SmallMuted"))
		var gap := Control.new()
		gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ends.add_child(gap)
		ends.add_child(UiFactory.make_label(Fmt.percent(int(slider_cfg["max"]), 0), &"SmallMuted"))
		body.add_child(_inset(ends, UiTokens.SPACE_XS, 0, 0))
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 0)
	body.add_child(_inset(_rows, UiTokens.SPACE_L if _slider != null else 0, 0, 0))
	# Kasa sıfırın altına inerse kepenk sayacı başlar: bedel değil tehlike, onu söyleyen tek kırmızı.
	var note := PanelContainer.new()
	note.theme_type_variation = UiTokens.D_variation(&"RiskStrip")
	var note_row := HBoxContainer.new()
	note_row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	note_row.add_child(UiFactory.make_glyph("res://assets/icons/util/warn.svg", UiTokens.D_ICON_BUTTON, UiTokens.D_neg()))
	var note_text := UiFactory.make_label(tr("HR_FIRE_CASH_NEGATIVE").format({"n": EndingsSystem.SHUTTER_WEEKS}),
		&"MetaMuted", UiTokens.D_neg_ink())
	note_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note_row.add_child(note_text)
	for part: Control in note_row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	note.add_child(_inset(note_row, UiTokens.SPACE_M, 0, UiTokens.SPACE_M))
	_note = _inset(note, UiTokens.SPACE_XL, 0, 0)
	body.add_child(_note)
	col.add_child(_inset(body, UiTokens.SPACE_XL, UiTokens.SPACE_3XL))

	var base := PanelContainer.new()
	base.theme_type_variation = &"PanelFoot"
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", UiTokens.SPACE_L)
	foot.alignment = BoxContainer.ALIGNMENT_END
	base.add_child(foot)
	col.add_child(base)
	var cancel := Button.new()
	cancel.text = tr("UI_DISMISS")
	cancel.focus_mode = Control.FOCUS_NONE
	cancel.pressed.connect(_close)
	foot.add_child(cancel)
	_commit_btn = Button.new()
	_commit_btn.focus_mode = Control.FOCUS_NONE
	_commit_btn.pressed.connect(_on_commit)
	if cfg.get("danger", false):
		_commit_btn.theme_type_variation = UiTokens.D_variation(&"DangerButton")
		_commit_btn.icon = load("res://assets/icons/world/person_left.svg")
	else:
		_commit_btn.theme_type_variation = &"PrimaryButtonDark"
	foot.add_child(_commit_btn)

	if _slider != null:
		_paint(int(_slider.value))
		_slider.value_changed.connect(func(v: float) -> void: _paint(int(v)))
	else:
		_render_rows(cfg.get("rows", []))
		_commit_btn.text = String(cfg.get("commit_text", ""))


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _exit_tree() -> void:
	get_tree().call_group(HRLedger.VIEWS_GROUP, &"hold_person", _person_id, false)


## A box inset `top` from above (and `bottom` below) and `side` on both sides.
func _inset(child: Control, top: int, side: int, bottom: int = -1) -> MarginContainer:
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_top", top)
	pad.add_theme_constant_override("margin_left", side)
	pad.add_theme_constant_override("margin_right", side)
	pad.add_theme_constant_override("margin_bottom", side if bottom < 0 else bottom)
	pad.add_child(child)
	return pad


func _paint(pct: int) -> void:
	# Önizlemenin tamamı motordan gelir; burada sayı hesaplanmaz.
	var pv: Dictionary = _preview.call(pct) as Dictionary
	var shown: int = int(pv.get("pct", pct))
	_pct.text = Fmt.percent(shown, 0)
	_render_rows(pv.get("rows", []))
	_commit_btn.text = tr(_commit_key).format({"pct": Fmt.percent(shown, 0)})


func _render_rows(rows: Array) -> void:
	UiFactory.clear(_rows)
	var below_zero := false
	for r: Dictionary in rows:
		match String(r.get("kind", "")):
			"delta":
				# Sıfırı geçen değerde kırmızı olan YALNIZ sonuçtur; engel yok, bir bilgidir.
				var negative: bool = bool(r.get("negative_after", false))
				below_zero = below_zero or negative
				_rows.add_child(_value_row(r, [
					UiFactory.make_label(String(r.get("before", "")), &"DataText", UiTokens.D_INK_3),
					UiFactory.make_label(ARROW, &"CaptionFaint"),
					UiFactory.make_label(String(r.get("after", "")), &"DataStrong", UiTokens.D_neg() if negative else null)],
					true))
			"fact":
				# Olgunun "önce"si yoktur; ok çizmek olmayan bir geçişi iddia ederdi. Olgu bir bedeldir.
				_rows.add_child(_value_row(r, [UiFactory.D_cost(String(r.get("value", "")), &"DataStrong")], false))
			"rule":
				var rule := HBoxContainer.new()
				rule.add_theme_constant_override("separation", UiTokens.SPACE_M)
				rule.add_child(UiFactory.make_glyph("res://assets/icons/util/info.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_4))
				var text := UiFactory.make_label(String(r.get("text", "")), &"MetaMuted")
				text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				rule.add_child(text)
				_rows.add_child(_inset(rule, UiTokens.SPACE_XL, 0, 0))
	_note.visible = below_zero


## Etiket · esneyen boşluk · değer hücreleri · (varsa) not; bir delta'nın notu (aylık fark) bedeldir.
func _value_row(row: Dictionary, cells: Array, cost_note: bool) -> PanelContainer:
	var line := PanelContainer.new()
	line.theme_type_variation = &"TableRow"
	line.custom_minimum_size.y = UiTokens.D_H_BTN_SM
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_M)
	line.add_child(box)
	var key := UiFactory.make_label(String(row.get("label", "")), &"DataText", UiTokens.D_INK_3)
	key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(key)
	for cell: Control in cells:
		box.add_child(cell)
	var note: String = String(row.get("note", ""))
	if note != "":
		box.add_child(UiFactory.D_cost(note, &"MetaMuted") if cost_note else UiFactory.make_label(note, &"MetaMuted"))
	for part: Control in box.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return line


func _on_commit() -> void:
	var arg: int = int(_slider.value) if _slider != null else 0
	if not _commit.call(arg):
		return   # motor reddettiyse modal açık kalır; sessiz kapanma yalan olurdu
	confirmed.emit()
	dismissed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
