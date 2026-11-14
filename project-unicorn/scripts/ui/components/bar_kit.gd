extends RefCounted

# BarKit — yüzen kartların (DESTEK kartı, araştırma kartı) ortak parçaları. Yazı ve kutu ev
# sahibinin temasından çözülür (BuildHUDPanel'in menajer_theme'i): parça varyasyonu adlandırır,
# ikonun tonu D_* token'ıdır. Parçalar fareyi geçirir; kartın boş yeri sürüklemeye kalır.
#
# class_name yok, iki kart da `preload` eder: paylaşılan checkout'ta yeni bir
# class_name, öteki oturumların headless koşularını global class-cache yarım
# kalınca düşürüyor.


static func glyph(texture: Texture2D, px: int, tone: Color) -> TextureRect:
	var t := TextureRect.new()
	t.texture = texture
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.modulate = tone
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return t


static func line() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return h


## Satırın kalanını alan yazı; uzarsa sarar, satır büyür.
static func filler(variation: StringName) -> Label:
	var l := UiFactory.make_label("", variation)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
