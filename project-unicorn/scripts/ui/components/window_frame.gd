extends PanelContainer

# Pencere kabuğu: WindowPanel kartı, içinde sayfa, sağ üstte kapatma glifi. Başlık çerçevede
# yok, sayfanın kendi başlık satırında; sağ iç boşluk glife ayrıldığı için ikisi çakışmaz.
# Dışarıdan preload ile erişilir: global class cache'e bağımlılık yok (headless tuzağı).

## Glifin sayfa içeriğinden ayırdığı sağ şerit.
const CLOSE_GUTTER := UiTokens.SPACE_3XL + UiTokens.SPACE_L

var page: Control


## `on_close` × basılınca ya da sayfa `close_requested` yayınca çağrılır (sayfanın konusu
## ortadan kalkınca pencere kendini kapatabilsin).
func _init(body: Control, on_close: Callable) -> void:
	theme_type_variation = &"WindowPanel"
	page = body
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", UiTokens.PAD_PAGE.x)
	pad.add_theme_constant_override("margin_top", UiTokens.PAD_PAGE.y)
	pad.add_theme_constant_override("margin_right", UiTokens.PAD_PAGE.x + CLOSE_GUTTER)
	pad.add_theme_constant_override("margin_bottom", UiTokens.PAD_PAGE.y)
	add_child(pad)
	pad.add_child(body)

	# Glif sayfanın başlık satırıyla aynı üst çizgide, sağ şeridin içinde.
	var slot := MarginContainer.new()
	slot.size_flags_horizontal = Control.SIZE_SHRINK_END
	slot.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	slot.add_theme_constant_override("margin_top", UiTokens.PAD_PAGE.y)
	slot.add_theme_constant_override("margin_right", UiTokens.PAD_PAGE.x)
	add_child(slot)
	slot.add_child(UiFactory.make_close_button(on_close))
	if body.has_signal(&"close_requested"):
		body.connect(&"close_requested", on_close)
