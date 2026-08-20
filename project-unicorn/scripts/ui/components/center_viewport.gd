extends Panel

# Center viewport per TECH_SPEC §5.2 — ODA rework'ten (2026-08-06) sonra:
# varsayılan durum ODA'dır (masa POV oda sahnesi), sekmeler odanın ÜSTÜNE
# tam-sayfa açılır ve TabPageChrome sarmalayıcısında mount edilir (üst koyu
# şerit + "ODAYA DÖN ✕"). tab_changed("") = "sekme yok, oda görünür"
# (event_bus.gd sözleşmesi; kapatmanın üç yolu — ✕, Esc, aktif sekmeye tekrar
# tıklama — hepsi bu sinyale çıkar, router tek yerden dinler).
#
# OdaView GameShell.tscn'de resident çocuktur (hep canlı, visible toggle):
# telefonun mentor latch'i, kâğıt seti ve gece durumu sekme gezintisinde yaşar.
# Sayfalar ModalLayer'a ASLA gitmez — game_shell Guard 2 orada Space/1-4'ü
# yutuyor; sayfa açıkken hız kontrolü çalışmalı.

const TAB_SCENES := {
	"product": preload("res://scenes/tabs/ProductTab.tscn"),
	"hr": preload("res://scenes/tabs/HRTab.tscn"),   # Ekip sayfası (task 3)
	"sales": preload("res://scenes/tabs/SalesTab.tscn"),
	"finance": preload("res://scenes/tabs/FinanceTab.tscn"),  # Spec 6 — hosts the Yatırım sub-page
}
# preload (global class cache'e bağımlılık yok — yeni class_name + headless tuzağı).
const PAGE_CHROME := preload("res://scripts/ui/components/tab_page_chrome.gd")

# OdaView sahnesi GameShell.tscn'e P5 adımında girer; o gelene dek null-tolerant
# (oda durumu = boş krem viewport, ara-durum F5'i için yeterli).
@onready var oda_view: Control = get_node_or_null("OdaView")

var _current_page: Control = null   # TabPageChrome sarmalayıcısı ya da null (= oda)
var _active_tab_id: String = ""     # açık sayfanın id'si ("" = oda) — palet yenilemesi buradan okur


func _ready() -> void:
	EventBus.tab_changed.connect(_on_tab_changed)
	EventBus.palette_changed.connect(_on_palette_changed)
	EventBus.language_changed.connect(_on_language_changed)
	# Açılış durumu ODA'dır ("home sekmesi" kavramı emekli; left_tabs'ın eski
	# default-product emit'i de silindi — zaten sibling-ready sırası gereği
	# buradaki connect'ten ÖNCE ateşleniyordu, hiç duyulmuyordu).
	_on_tab_changed("")


func _exit_tree() -> void:
	EventBus.tab_changed.disconnect(_on_tab_changed)
	EventBus.palette_changed.disconnect(_on_palette_changed)
	EventBus.language_changed.disconnect(_on_language_changed)


## Renk körü paleti değişti: açık sayfayı YENİDEN KUR. Sayfa gövdeleri semantik
## rengi kendi _ready'lerinde okuyup override olarak basıyor, yani yerinde bir
## repaint seam'i yok — free-and-rebuild zaten bu router'ın tek kurulum yolu
## (audit Group 7 bunu "dil yenilemesini kendi kendini iyileştiren şey" diye
## adlandırıyor; palet için de aynı kanal doğru olanı).
## Oda açıkken hiçbir şey yapmıyoruz: OdaView resident ve palette_changed'e kendisi
## bağlı, bir daha kurmak gereksiz iş olurdu.
func _on_palette_changed(_colorblind: bool) -> void:
	if _active_tab_id != "":
		_on_tab_changed(_active_tab_id)


## Dil değişti: açık sayfayı YENİDEN KUR — palet yenilemesiyle aynı kanal, aynı gerekçe.
## Sahne-anahtarlı statik metin auto-translate ile kendi kendine dönüyor (probe'la
## kanıtlandı), ama sayfa gövdeleri metnin ÇOĞUNU kod tarafında BESTELİYOR
## (tr(KEY).format({...}), Fmt ile biçimlenmiş sayı ve tarihler) ve besteleme çıktısı
## ham anahtar DEĞİL, çözülmüş metindir — yani kendiliğinden çevrilmez. Router'ın tek
## kurulum yolu zaten free-and-rebuild olduğu için burada yeni bir repaint seam'i icat
## etmiyoruz; var olanı çağırıyoruz.
## Oda açıkken hiçbir şey yapmıyoruz: OdaView resident ve kendi yenilemesine sahip.
func _on_language_changed(_locale: String) -> void:
	if _active_tab_id != "":
		_on_tab_changed(_active_tab_id)


func _on_tab_changed(tab_id: String) -> void:
	_active_tab_id = tab_id
	if _current_page != null:
		# S2-33 (Calibration Round A §16): the free-and-rebuild is what makes the language and
		# palette refresh self-healing, so the guard is NOT "stop freeing pages" — the page is
		# told it is closing and stashes any in-progress draft (creation_flow.on_page_closing
		# → GameState flag `creation_draft`), which the product tab re-hydrates on its next
		# mount. propagate_call reaches the page AND every descendant that implements it.
		_current_page.propagate_call("on_page_closing")
		_current_page.queue_free()
		_current_page = null

	if tab_id == "":
		if oda_view != null:
			oda_view.visible = true   # çift-kapatmada idempotent
		return

	if oda_view != null:
		oda_view.visible = false
	var body: Control
	if TAB_SCENES.has(tab_id):
		body = (TAB_SCENES[tab_id] as PackedScene).instantiate()
	elif tab_id == "milestones":
		# D5 pseudo-dokümanı: rayda sekmesi yok (highlight boş kalır — doğru),
		# TabPageChrome sarmalayıcısı ✕/Esc'i bedava verir.
		body = _make_milestones_body()
	else:
		body = _make_placeholder_body(tab_id)   # ops / rnd / personal / events
	_current_page = PAGE_CHROME.wrap(body)
	add_child(_current_page)
	# BuildHUD (GameShell.tscn'de SON çocuk) sayfanın üstünde kalsın: add_child
	# sona ekler, sayfayı çizim sırasının en altına it. OdaView o anda görünmez
	# olduğundan 0-indeksin onun altına düşmesi önemsiz.
	move_child(_current_page, 0)


func get_current_page_body() -> Control:
	# Harness/debug erişimi (hr-shot / product-shot): mount edilmiş sekme
	# instance'ı — TabPageChrome sarmalayıcısındaki PageHost'un tek çocuğu.
	# Sayfa yokken (oda görünür) null. Sarmalayıcı yeniden adlandırması eski
	# `_current_tab_node` erişimini kırmıştı; dış dünya artık YALNIZ bu seam'i kullanır.
	if _current_page == null:
		return null
	var host: Node = _current_page.get_node_or_null("PageHost")
	if host == null or host.get_child_count() == 0:
		return null
	return host.get_child(0) as Control


func _make_placeholder_body(tab_id: String) -> Control:
	# Sahnesi olmayan sekmeler: sarmalayıcı içinde ortalanmış başlık + tek satır.
	# (GameShell.tscn'deki eski paylaşımlı Content VBox'ı — baked İngilizce
	# "PRODUCT" / "Content coming" — bununla emekli oldu.)
	var body := Control.new()
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.grow_vertical = Control.GROW_DIRECTION_BOTH
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	body.add_child(col)
	# The caption is DERIVED from the id (TAB_ + ID), not looked up in a second table:
	# UiTokens.TABS no longer carries an English `label`, so the rail and this page title
	# now read the same localization key and cannot drift apart (S2-34).
	var title := UiFactory.make_label(Fmt.upper(tr("TAB_" + tab_id.to_upper())), &"TitleSerif")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := UiFactory.make_label(tr("ODA_PAGE_PLACEHOLDER"), &"CaptionMuted")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	# D2: Events sayfası Frank'in TAM mesajını taşır (telefon camında yalnız
	# bildirim var; latch'in tek evi oda_view — get_mentor_line seam'i).
	if tab_id == "events" and oda_view != null:
		var line: String = String(oda_view.get_mentor_line())
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
	# D5: milestone DETAYI — mühür + ad + tarih/tutar + tek cümle not. Veri tek
	# evden (oda_view.get_milestones); kazanılmamışlar sönük satır.
	var note_keys: Array = ["ODA_MS_FOUNDING_NOTE", "ODA_MS_SHIP_NOTE", "ODA_MS_FUNDING_NOTE"]
	var body := Control.new()
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.grow_vertical = Control.GROW_DIRECTION_BOTH
	col.custom_minimum_size = Vector2(520, 0)
	col.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	body.add_child(col)
	var title := UiFactory.make_label(tr("ODA_MILESTONES_TITLE"), &"TitleSerif")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var data: Array = oda_view.get_milestones() if oda_view != null else []
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
