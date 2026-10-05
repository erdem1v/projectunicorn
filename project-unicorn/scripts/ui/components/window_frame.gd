extends PanelContainer

# Pencere kabuğu: WindowPanel kartı, içinde sayfa, sağ üstte kapatma glifi. Krem sayfa başlığını
# kendi satırında çizer; sağ iç boşluk glife ayrıldığı için ikisi çakışmaz. Koyu dile taşınan
# sayfa ortak başlığı açar ve kendi başlığını siler.
# Bir karar beklerken (EventGate.active_id() != "") gelen kutusu dışındaki her pencere yalnız okunur:
# başlığın altında karara dönen şerit belirir, sayfa gövdesine tıklama ulaşmaz; tekerlek ve kaydırma
# çubuğu geçer, kapatma ve şerit çalışır.
# Dışarıdan preload ile erişilir: global class cache'e bağımlılık yok (headless tuzağı).

const INBOX := preload("res://scripts/ui/components/inbox.gd")
## Glifin sayfa içeriğinden ayırdığı sağ şerit.
const CLOSE_GUTTER := UiTokens.SPACE_3XL + UiTokens.SPACE_L
const WHEEL := [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT,
	MOUSE_BUTTON_WHEEL_RIGHT]

var page: Control
var _strip: PanelContainer
var _strip_from: Label
var _close_slot: MarginContainer
var _close_top := 0


## `on_close` × basılınca ya da sayfa `close_requested` yayınca çağrılır (sayfanın konusu
## ortadan kalkınca pencere kendini kapatabilsin). `guarded` false olan pencere (gelen kutusu) karar
## beklerken de kullanılır.
## Sayfa `frame_options` ile seçer; hepsi kapalı doğar:
##   variation · görünüm; pad · iç boşluk; owns_close · glif sayfanın kendi başlık satırında (ürün
##     sprint ekranı genişliğini sağ şeride vermiyor);
##   theme · koyu dil: menajer_theme bu çerçevede başlar, WindowPanel'in gölgesi ofisin üstünde hale olur;
##   title · ortak başlık bandı, koyu dilin parçası olduğu için theme'i de açar: CSV anahtarı büyük
##     harfle, ardından sayfanın KPI yuvası (kpi, bir Control; değerlerini sayfa yazar) ve kapatma.
func _init(body: Control, on_close: Callable, guarded := true) -> void:
	var opts: Dictionary = body.get(&"frame_options") if &"frame_options" in body else {}
	theme_type_variation = opts.get("variation", &"WindowPanel")
	var title: String = opts.get("title", "")
	if opts.get("theme", false) or title != "":
		theme = load(UiTokens.MENAJER_THEME)
	var inset: Vector2i = opts.get("pad", UiTokens.PAD_PAGE)
	var owns_close: bool = opts.get("owns_close", false) or title != ""
	page = body
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", inset.x)
	pad.add_theme_constant_override("margin_top", inset.y)
	pad.add_theme_constant_override("margin_right", inset.x + (0 if owns_close else CLOSE_GUTTER))
	pad.add_theme_constant_override("margin_bottom", inset.y)
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	add_child(col)
	if title != "":
		col.add_child(_head(title, opts.get("kpi"), on_close))
	if guarded:
		_strip = _read_only_strip(0 if owns_close else CLOSE_GUTTER)
		col.add_child(_strip)
		EventBus.event_triggered.connect(_sync_gate.unbind(1))
		EventBus.event_resolved.connect(_sync_gate.unbind(2))
		EventBus.event_set_aside.connect(_sync_gate.unbind(1))
	col.add_child(pad)
	pad.add_child(body)
	if body.has_signal(&"close_requested"):
		body.connect(&"close_requested", on_close)
	if not owns_close:
		# Glif sayfanın başlık satırıyla aynı üst çizgide (şerit varsa onun altında), sağ şeridin içinde.
		_close_slot = MarginContainer.new()
		_close_slot.size_flags_horizontal = Control.SIZE_SHRINK_END
		_close_slot.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		_close_slot.add_theme_constant_override("margin_right", inset.x)
		add_child(_close_slot)
		_close_slot.add_child(UiFactory.make_close_button(on_close))
	_close_top = inset.y
	if guarded:
		_sync_gate()
	elif _close_slot != null:
		_close_slot.add_theme_constant_override("margin_top", _close_top)


## Başlık bandı: ad, KPI yuvası (yoksa boşluk) ve kapatma; ad ile KPI'lar arası 32 px.
func _head(title: String, kpi: Control, on_close: Callable) -> PanelContainer:
	var head := PanelContainer.new()
	head.theme_type_variation = &"WinHead"
	head.custom_minimum_size.y = UiTokens.D_H_WIN_HEAD
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_4XL)
	head.add_child(row)
	row.add_child(UiFactory.make_label(Fmt.upper(tr(title)), &"TitleH1"))
	var slot: Control = kpi if kpi != null else Control.new()
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slot)
	var close := UiFactory.make_close_button(on_close, true)
	close.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(close)
	return head


## The read-only strip, in the dark language on any window: the decision's sender and subject, and
## the way back to it. `right` keeps it clear of a cream window's close glyph.
func _read_only_strip(right: int) -> PanelContainer:
	var strip := PanelContainer.new()
	strip.theme = load(UiTokens.MENAJER_THEME)
	strip.theme_type_variation = &"WinReadOnly"
	strip.custom_minimum_size.y = UiTokens.D_H_BTN_SM + UiTokens.SPACE_M
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_right", right)
	strip.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	margin.add_child(row)
	var dot := Panel.new()
	dot.theme_type_variation = &"GateDot"
	dot.custom_minimum_size = Vector2.ONE * UiTokens.SPACE_M
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	var say := UiFactory.make_label(tr("WIN_READ_ONLY"), &"DataStrong")
	say.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(say)
	_strip_from = UiFactory.make_label("", &"MetaMuted")
	_strip_from.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_strip_from.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_strip_from.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(_strip_from)
	var back := Button.new()
	back.text = tr("WIN_BACK_TO_DECISION")
	back.icon = load("res://assets/icons/util/reply.svg")
	back.theme_type_variation = &"SecondaryButtonSmall"
	back.focus_mode = Control.FOCUS_NONE
	back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(INBOX.show.bind("active"))
	row.add_child(back)
	return strip


func _sync_gate() -> void:
	_strip.visible = EventGate.active_id() != ""
	if _close_slot != null:
		_close_slot.add_theme_constant_override("margin_top",
			_close_top + (int(_strip.custom_minimum_size.y) if _strip.visible else 0))
	if _strip.visible:
		var it: Dictionary = INBOX.active_item()
		_strip_from.text = "%s · %s" % [it.sender.name, it.subject]


## While the strip shows, a press on the page reaches only its scrollbars, the wheel and a control marked
## `gate_reads` (picking what to read: an Ar-Ge tile, a history row); the hovered control says which window is
## on top. A focused control is let go before Enter presses it.
func _input(event: InputEvent) -> void:
	if _strip == null or not _strip.visible or not is_visible_in_tree():
		return
	if event.is_action_pressed(&"ui_accept"):
		var focus: Control = get_viewport().gui_get_focus_owner()
		if focus != null and page.is_ancestor_of(focus):
			focus.release_focus()
	var press := event as InputEventMouseButton
	if press == null or not press.pressed or press.button_index in WHEEL:
		return
	var hit: Control = get_viewport().gui_get_hovered_control()
	if hit != null and (hit == page or page.is_ancestor_of(hit)) and not hit is ScrollBar \
			and not hit.has_meta(&"gate_reads"):
		get_viewport().set_input_as_handled()
