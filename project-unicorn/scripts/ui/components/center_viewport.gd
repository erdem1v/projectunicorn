extends Panel

# Center viewport router. Varsayılan durum ODA'dır; sekmeler odanın ÜSTÜNE tam-sayfa açılır
# ve TabPageChrome sarmalayıcısında mount edilir. tab_changed("") = "sekme yok, oda görünür";
# kapatmanın üç yolu (✕, Esc, aktif sekmeye tekrar tıklama) hepsi bu sinyale çıkar.
#
# OdaView resident çocuktur (hep canlı, visible toggle): telefonun mentor latch'i, kâğıt seti
# ve gece durumu sekme gezintisinde yaşar. Sayfalar ModalLayer'a ASLA gitmez: game_shell
# orada Space/1-4'ü yutuyor, sayfa açıkken hız kontrolü çalışmalı.

const TAB_SCENES := {
	"product": preload("res://scenes/tabs/ProductTab.tscn"),
	"hr": preload("res://scenes/tabs/HRTab.tscn"),
	"sales": preload("res://scenes/tabs/SalesTab.tscn"),
	"finance": preload("res://scenes/tabs/FinanceTab.tscn"),  # Yatırım alt sayfası burada
	"personal": preload("res://scenes/tabs/PersonalTab.tscn"),
	"rnd": preload("res://scenes/tabs/RnDTab.tscn"),
}
# preload: global class cache'e bağımlılık yok (yeni class_name + headless tuzağı).
const PAGE_CHROME := preload("res://scripts/ui/components/tab_page_chrome.gd")

@onready var oda_view: Control = $OdaView

var _current_page: Control = null   # TabPageChrome sarmalayıcısı ya da null (= oda)
var _active_tab_id: String = ""


func _ready() -> void:
	EventBus.tab_changed.connect(_on_tab_changed)
	# Sayfa gövdeleri metnin çoğunu kodda besteler (tr().format, Fmt) ve semantik rengi
	# kendi _ready'lerinde override olarak basar; ikisi de kendiliğinden dönmez. Yerinde
	# repaint seam'i yok, router'ın tek kurulum yolu free-and-rebuild: açık sayfa yeniden
	# kurulur. Oda resident ve kendi yenilemesine sahip.
	EventBus.palette_changed.connect(_rebuild_open_page.unbind(1))
	EventBus.language_changed.connect(_rebuild_open_page.unbind(1))
	_on_tab_changed("")


func _rebuild_open_page() -> void:
	if _active_tab_id != "":
		_on_tab_changed(_active_tab_id)


func _on_tab_changed(tab_id: String) -> void:
	_active_tab_id = tab_id
	if _current_page != null:
		# Free-and-rebuild dil/palet yenilemesini kendi kendini iyileştiren şeydir; yarım
		# taslak o yüzden kapanışta saklanır (creation_flow.on_page_closing → GameState
		# `creation_draft`) ve product tab bir sonraki mount'ta geri yükler. propagate_call
		# sayfaya VE onu uygulayan her torununa ulaşır.
		_current_page.propagate_call("on_page_closing")
		_current_page.queue_free()
		_current_page = null

	oda_view.visible = tab_id == ""
	if tab_id == "":
		return

	var body: Control
	if TAB_SCENES.has(tab_id):
		body = (TAB_SCENES[tab_id] as PackedScene).instantiate()
	elif tab_id == "milestones":
		# Rayda sekmesi yok (highlight boş kalır); sarmalayıcı ✕/Esc'i bedava verir.
		body = _make_milestones_body()
	else:
		body = _make_placeholder_body(tab_id)
	_current_page = PAGE_CHROME.wrap(body)
	add_child(_current_page)
	# BuildHUD (son çocuk) sayfanın üstünde kalsın: sayfayı çizim sırasının en altına it.
	# OdaView o anda görünmez, 0-indeksin onun altına düşmesi önemsiz.
	move_child(_current_page, 0)


## Harness erişimi: mount edilmiş sekme instance'ı (PageHost'un tek çocuğu); oda görünürken null.
func get_current_page_body() -> Control:
	if _current_page == null:
		return null
	var host: Node = _current_page.get_node("PageHost")
	return host.get_child(0) as Control if host.get_child_count() > 0 else null


func _make_centered_column(body: Control, separation: int) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.grow_vertical = Control.GROW_DIRECTION_BOTH
	col.add_theme_constant_override("separation", separation)
	body.add_child(col)
	return col


func _make_placeholder_body(tab_id: String) -> Control:
	# Sahnesi olmayan sekmeler: ortalanmış başlık + tek satır. Başlık id'den türer (TAB_ + ID),
	# rayla aynı anahtar, ayrışamazlar.
	var body := Control.new()
	var col := _make_centered_column(body, UiTokens.SPACE_M)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	var title := UiFactory.make_label(Fmt.upper(tr("TAB_" + tab_id.to_upper())), &"TitleSerif")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := UiFactory.make_label(tr("ODA_PAGE_PLACEHOLDER"), &"CaptionMuted")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	# Events sayfası Frank'in TAM mesajını taşır: telefon camında yalnız bildirim var,
	# latch'in tek evi oda_view.
	var line: String = oda_view.get_mentor_line() if tab_id == "events" else ""
	if line != "":
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, UiTokens.SPACE_XL)
		col.add_child(gap)
		col.add_child(UiFactory.make_section_header(tr("ODA_EVENTS_FRANK_HEADER")))
		var quote := UiFactory.make_label("\"%s\"" % line, &"QuoteSerif")
		quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		quote.custom_minimum_size = Vector2(420, 0)
		quote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(quote)
	return body


func _make_milestones_body() -> Control:
	# Milestone detayı: mühür + ad + tarih/tutar + kazanılmışsa tek cümle not; veri
	# oda_view.get_milestones'tan, kazanılmamışlar sönük satır.
	var note_keys: Array = ["ODA_MS_FOUNDING_NOTE", "ODA_MS_SHIP_NOTE", "ODA_MS_FUNDING_NOTE"]
	var body := Control.new()
	var col := _make_centered_column(body, UiTokens.SPACE_XL)
	col.custom_minimum_size = Vector2(520, 0)
	var title := UiFactory.make_label(tr("ODA_MILESTONES_TITLE"), &"TitleSerif")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var data: Array = oda_view.get_milestones()
	for i in data.size():
		var m: Dictionary = data[i]
		var earned: bool = bool(m["earned"])
		var card := UiFactory.make_card(null, false, false)
		col.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", UiTokens.SPACE_L)
		card.add_child(row)
		var seal_holder := VBoxContainer.new()
		seal_holder.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(seal_holder)
		seal_holder.add_child(UiFactory.make_dot(
			UiTokens.ACCENT_DEEP if earned else UiTokens.DOT_IDLE, 16))
		var text_col := VBoxContainer.new()
		text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
		row.add_child(text_col)
		text_col.add_child(UiFactory.make_label(String(m["name"]), &"RowName",
			UiTokens.INK if earned else UiTokens.INK_DIM))
		if earned and i < note_keys.size():
			var note := UiFactory.make_label(tr(String(note_keys[i])), &"CaptionMuted")
			note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			text_col.add_child(note)
		var meta := UiFactory.make_label(String(m["meta"]) if earned else "—", &"RowMeta")
		meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(meta)
	return body
