class_name TabPageChrome
extends VBoxContainer

# Sekme sayfası kabuğu (ODA rework §2): her tam-sayfa sekmenin üstüne ince koyu
# şerit (ChromePageStrip) + sağda tek "ODAYA DÖN  ✕" ghost butonu koyar; sekme
# instance'ı PageHost'ta DEĞİŞMEDEN yaşar (sekme içi sıfır düzenleme — şerit
# ayrı bant olduğu için HR'ın sağ-üst butonu / Sales'in sağa yaslı metrikleriyle
# çakışamaz). Kapatma tek kanala düşer: EventBus.tab_changed("") — Esc ve
# aktif-sekmeye-tekrar-tıklama da aynı sinyale çıkar, router tek yerden dinler.
#
# Dışarıdan preload ile erişilir (center_viewport.gd) — global class cache'e
# bağımlılık bırakmamak için (yeni class_name + headless koşu tuzağı).


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
	# Space asla bu butona düşmesin: ui_accept blind-close yasağı (Kepenk vakası,
	# ENDGAME_DESIGN §7 kuralı) + game_shell Space toggle'ı odak butonda takılmasın.
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
