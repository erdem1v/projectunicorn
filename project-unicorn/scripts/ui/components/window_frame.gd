extends PanelContainer

# Pencere kabuğu: WindowPanel kartı, içinde sayfa, sağ üstte kapatma glifi. Krem sayfa başlığını
# kendi satırında çizer; sağ iç boşluk glife ayrıldığı için ikisi çakışmaz. Koyu dile taşınan
# sayfa ortak başlığı açar ve kendi başlığını siler.
# Dışarıdan preload ile erişilir: global class cache'e bağımlılık yok (headless tuzağı).

## Glifin sayfa içeriğinden ayırdığı sağ şerit.
const CLOSE_GUTTER := UiTokens.SPACE_3XL + UiTokens.SPACE_L

var page: Control


## `on_close` × basılınca ya da sayfa `close_requested` yayınca çağrılır (sayfanın konusu
## ortadan kalkınca pencere kendini kapatabilsin).
## Sayfa `frame_options` ile seçer; hepsi kapalı doğar:
##   variation · görünüm; pad · iç boşluk; owns_close · glif sayfanın kendi başlık satırında (ürün
##     sprint ekranı genişliğini sağ şeride vermiyor);
##   theme · koyu dil: menajer_theme bu çerçevede başlar, WindowPanel'in gölgesi ofisin üstünde hale olur;
##   title · ortak başlık bandı, koyu dilin parçası olduğu için theme'i de açar: CSV anahtarı büyük
##     harfle, ardından sayfanın KPI yuvası (kpi, bir Control; değerlerini sayfa yazar) ve kapatma.
func _init(body: Control, on_close: Callable) -> void:
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
	if title == "":
		add_child(pad)
	else:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 0)
		col.add_child(_head(title, opts.get("kpi"), on_close))
		pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
		col.add_child(pad)
		add_child(col)
	pad.add_child(body)
	if body.has_signal(&"close_requested"):
		body.connect(&"close_requested", on_close)
	if owns_close:
		return

	# Glif sayfanın başlık satırıyla aynı üst çizgide, sağ şeridin içinde.
	var slot := MarginContainer.new()
	slot.size_flags_horizontal = Control.SIZE_SHRINK_END
	slot.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	slot.add_theme_constant_override("margin_top", inset.y)
	slot.add_theme_constant_override("margin_right", inset.x)
	add_child(slot)
	slot.add_child(UiFactory.make_close_button(on_close))


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
