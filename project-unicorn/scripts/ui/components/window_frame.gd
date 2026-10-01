extends PanelContainer

# Pencere kabuğu: WindowPanel kartı, içinde sayfa, sağ üstte kapatma glifi. Başlık çerçevede
# yok, sayfanın kendi başlık satırında; sağ iç boşluk glife ayrıldığı için ikisi çakışmaz.
# Dışarıdan preload ile erişilir: global class cache'e bağımlılık yok (headless tuzağı).

## Glifin sayfa içeriğinden ayırdığı sağ şerit.
const CLOSE_GUTTER := UiTokens.SPACE_3XL + UiTokens.SPACE_L

var page: Control


## `on_close` × basılınca ya da sayfa `close_requested` yayınca çağrılır (sayfanın konusu
## ortadan kalkınca pencere kendini kapatabilsin).
## Sayfa `frame_options` ile görünümü (`variation`), iç boşluğu (`pad`) ve glifi kendi başlık
## satırına almayı (`owns_close`) seçebilir: ürün sprint ekranı genişliğini sağ şeride vermiyor.
func _init(body: Control, on_close: Callable) -> void:
	var opts: Dictionary = body.get(&"frame_options") if &"frame_options" in body else {}
	theme_type_variation = opts.get("variation", &"WindowPanel")
	var inset: Vector2i = opts.get("pad", UiTokens.PAD_PAGE)
	var owns_close: bool = opts.get("owns_close", false)
	page = body
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", inset.x)
	pad.add_theme_constant_override("margin_top", inset.y)
	pad.add_theme_constant_override("margin_right", inset.x + (0 if owns_close else CLOSE_GUTTER))
	pad.add_theme_constant_override("margin_bottom", inset.y)
	add_child(pad)
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
