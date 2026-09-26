class_name TabPageChrome
extends VBoxContainer

# Sekme sayfası kabuğu: sayfanın üstüne ince koyu şerit (ChromePageStrip) + sağda tek
# "ODAYA DÖN  ✕" butonu. Sekme instance'ı PageHost'ta DEĞİŞMEDEN yaşar; şerit ayrı bant
# olduğu için sayfanın sağ-üst öğeleriyle çakışamaz. Kapatma EventBus.tab_changed("")'dir.
# Dışarıdan preload ile erişilir: global class cache'e bağımlılık yok (headless tuzağı).


static func wrap(page: Control) -> TabPageChrome:
	var w := TabPageChrome.new()
	w.name = "TabPage"
	w.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	w.add_theme_constant_override("separation", 0)
	w._build(page)
	return w


func _build(page: Control) -> void:
	var strip := PanelContainer.new()
	strip.name = "Strip"
	strip.theme_type_variation = &"ChromePageStrip"
	add_child(strip)

	var row := HBoxContainer.new()
	strip.add_child(row)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var close_btn := Button.new()
	close_btn.name = "CloseBtn"
	close_btn.theme_type_variation = &"ChromeGhost"
	# Space asla bu butona düşmesin: ui_accept kör-kapatma yasağı, ve game_shell'in
	# Space hız toggle'ı odaklı butonda takılmasın.
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.text = "%s  ✕" % tr("ODA_RETURN")
	close_btn.pressed.connect(_on_close_pressed)
	row.add_child(close_btn)

	var host := Control.new()
	host.name = "PageHost"
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(host)
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(page)


func _on_close_pressed() -> void:
	EventBus.tab_changed.emit("")
