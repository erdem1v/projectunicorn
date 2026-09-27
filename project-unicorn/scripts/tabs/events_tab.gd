extends Control

# Olaylar sayfası: Frank'in son notu ve masada bekleyen kâğıtlar. Kâğıtların türetmesi, satırı ve
# tıklama yolu DeskPapers'ta (ofisin not yığını da oradan okur); sayfa yalnız dizer.

const PAPERS := preload("res://scripts/ui/components/desk_papers.gd")

var _frank: VBoxContainer
var _quote: Label
var _list: VBoxContainer


func _ready() -> void:
	# Kenar boşluğu pencerenin (WindowFrame): başlık satırı kapatma glifiyle aynı çizgide.
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	add_child(col)
	col.add_child(UiFactory.make_label(tr("TAB_EVENTS"), &"PageTitleSerif"))

	_frank = VBoxContainer.new()
	_frank.add_theme_constant_override("separation", UiTokens.SPACE_S)
	_frank.add_child(HRUiShared.section_header(tr("EVENTS_FRANK_HEADER")))
	_quote = UiFactory.make_label("", &"QuoteSerif")
	_quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_frank.add_child(_quote)
	col.add_child(_frank)

	col.add_child(HRUiShared.section_header(tr("EVENTS_DESK_HEADER")))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", UiTokens.SPACE_S)
	scroll.add_child(_list)

	PAPERS.connect_changes(_refresh)
	_refresh()


## Sinyaller 0-2 argümanlı; ikisi de opsiyonel ki hepsi buraya bağlanabilsin.
func _refresh(_a = null, _b = null) -> void:
	# Frank'in satırını motor saklamıyor; GameState mentor_advisory_changed'den kilitliyor.
	var key: String = GameState.mentor_line_key
	_frank.visible = key != ""
	_quote.text = tr("FIN_MENTOR_QUOTE_WRAPPED").format(
		{"quote": tr(key).format(GameState.mentor_line_args)})
	UiFactory.clear(_list)
	var papers: Array = PAPERS.gather()
	if papers.is_empty():
		_list.add_child(UiFactory.make_label(tr("EVENTS_DESK_EMPTY"), &"CaptionMuted"))
	for p in papers:
		_list.add_child(_paper_row(p))


func _paper_row(p: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRow"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# Hover = kenar; iki varyasyonun dolgusu ve margin'i aynı, satır zıplamaz.
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"LedgerRowHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"LedgerRow")
	card.gui_input.connect(_on_paper_input.bind(p))
	var row: HBoxContainer = PAPERS.make_row(p)
	HRUiShared.set_mouse_ignore(row)
	card.add_child(row)
	return card


func _on_paper_input(event: InputEvent, paper: Dictionary) -> void:
	if not UiFactory.is_left_click(event):
		return
	PAPERS.open(paper)
	# Bu arada dünya değiştiyse motor kâğıdı sinyalsiz düşürür; liste yeniden okunur.
	_refresh()
