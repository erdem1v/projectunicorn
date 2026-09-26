extends Control

# ============================================================================
# AR-GE SAYFASI (GDD "AR-GE MODÜLÜ" §2, §3, §5, §7, §8).
#
# Kod-kurulu düzen, boş .tscn kökü (Ürün / Ekip idiomu): ağacın yerleşimi
# `size.x`ten türetiliyor ve karolar mutlak konumlu, yani .tscn'de tutulacak bir
# iskelet YOK. Kökte yalnız üç şey var: `process_mode`, tam-ekran çapa, script.
#
# PROCESS_MODE_ALWAYS ZORUNLU VE SÜS DEĞİL. Godot duraklatılmış düğümleri
# ÇİZMEYE devam eder ama onlara `gui_input` DAĞITMAZ — hız 0'da her karo
# görünür, her tıklama yutulurdu. Editörde görünmez, yalnız çalışırken çıkar.
#
# GÜN SINIRI: `EventBus.day_advanced`e ASLA bağlanmaz. O sinyal
# `GameState.advance_day()` İÇİNDE, TimeManager günlük tick'leri dağıtmadan ÖNCE
# atılıyor; oraya bağlanan bir görünüm DÜNKÜ durumu okur (hr_tab aynı tuzağı
# yazıyor). Ar-Ge'nin gün-sınırı kancası `research_progress_changed`.
#
# DİL VE PALET: bu sayfa `language_changed`/`palette_changed`e BAĞLANMAZ.
# Router sayfayı her mount'ta serbest bırakıp yeniden kuruyor (center_viewport
# ._on_language_changed) ve dil/palet yenilemesini KENDİ KENDİNİ İYİLEŞTİREN şey
# tam olarak bu; buradan da bağlansaydık sayfa iki kez kurulurdu.
#
# TAZELEME MODELİ (hr_tab'ın yapı-anahtarı deseni): ucuz bir anahtar (açılmış
# küme + tamamlanmış küme + aktif düğüm + donma + bekleyen rapor) yeniden-kurma
# ile yerinde-boyama arasında karar verir. Böylece `research_progress_changed`
# yalnız şeridi ve koşan karonun dolgusunu tazeler, yirmi karoyu yıkmaz.
#
# WORKING TR — oyuncuya görünen her metin bir anahtardan geliyor; ses geçişi
# (voice pass) yazı ekibinin işi.
# ============================================================================

## Sayfanın kendi kenar boşluğu (Ekip sayfasının ölçüsü).
const PAGE_MARGIN := 16
## Koşan araştırmanın tek satırlık şeridi (§8 — sayfanın en üstü).
const BAR_H := 26

var _signals: Array = []
var _tree: RnDTreeView = null
var _progress_label: Label = null
var _bar: Control = null
var _bar_fill: Panel = null
var _bar_name: Label = null
var _bar_days: Label = null
var _bar_percent: Label = null
var _structure_key: String = ""
var _selected: String = ""


func _ready() -> void:
	# İKİ SAYFA HÂLİ, TEK KAPI: `RnDSystem.tree_open()` (Ar-Ge §2, MÜHÜRLÜ). `version_shipped`
	# dinlendiği için oyuncu sekme açıkken v1'i yayınlarsa sayfa ağaca döner.
	if not RnDSystem.tree_open():
		_build_waiting_page()
		EventBus.version_shipped.connect(_on_version_shipped, CONNECT_ONE_SHOT)
		return
	_build_chrome()
	# §10'un okuma yüzeyinin sinyalleri + üç ek. `assignment_changed` burada,
	# çünkü bir kişinin işi değişince araştırma DONABİLİR ve koltuk listesi
	# kartın canlı satırıdır.
	_signals = [
		EventBus.research_started, EventBus.research_completed,
		EventBus.research_frozen, EventBus.research_resumed,
		EventBus.node_revealed, EventBus.hidden_line_unlocked,
		EventBus.research_progress_changed,
		EventBus.product_note_issued, EventBus.product_note_read,
		EventBus.assignment_changed,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	EventBus.rnd_node_requested.connect(select_node)

	# TASLAK NÖBETİ (creation_flow'un `creation_draft` emsali): dil ya da
	# palet değişince router sayfayı yıkıp yeniden kuruyor; bayrak olmasaydı
	# oyuncu okuduğu düğümden dışarı atılırdı. TÜKETİLİR VE SİLİNİR — bayat bir
	# seçim bir sonraki turda geri gelmesin.
	var stashed: String = String(GameState.get_flag("rnd_selected", ""))
	GameState.flags.erase("rnd_selected")
	_refresh()
	select_node(stashed)


func _on_version_shipped(_v: int) -> void:
	# Bekleme sayfası ağaca döner. Router'ın kendi free-and-rebuild yolu burada yok, o
	# yüzden sayfayı kendimiz yeniden kuruyoruz.
	for child in get_children():
		child.queue_free()
	_ready()


func _exit_tree() -> void:
	if EventBus.version_shipped.is_connected(_on_version_shipped):
		EventBus.version_shipped.disconnect(_on_version_shipped)
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)
	if EventBus.rnd_node_requested.is_connected(select_node):
		EventBus.rnd_node_requested.disconnect(select_node)


## Router sayfayı bırakmadan önce çağırır (propagate_call). Seçili düğüm
## saklanır; `_ready` onu tüketip siler.
func on_page_closing() -> void:
	if _selected != "":
		GameState.set_flag("rnd_selected", _selected)


# --- Derin bağ ---------------------------------------------------------------

## Dışarıya açık seam, `rnd_node_requested`in işleyicisi. `tab_changed("rnd")` emit'i
## sayfayı SENKRON mount ediyor (`_ready` `add_child` içinde koşar), yani hemen ardından
## gelen `rnd_node_requested` bağlanmış bir işleyici bulur (§2). Ürün'ün "→ Araştır"ı
## false, barın "ata"sı true gönderir. AÇILMAMIŞ ama var olan bir düğümü de seçer —
## panel kendini "Önce {düğüm}." diye açıklayabilsin diye (§7).
func select_node(node_id: String, open_assign: bool = false) -> void:
	if ResearchSeam.is_node(node_id):
		_tree.select(node_id, open_assign)


# --- Sayfa kromu -------------------------------------------------------------

## V1 ÖNCESİ SAYFA: TEK SATIR, BAŞKA HİÇBİR ŞEY. Kilitli yuva yok, hayalet ağaç yok,
## fragman ızgarası yok. Kapı rayda değil sayfada (§2; bkz. ui_tokens'ın `lock` notu) — kapı
## burada, ve kapının söylediği tek şey neyi beklediği. Kabuk zaten bu grameri kullanıyor:
## ortalanmış başlık + tek `CaptionMuted` satır (center_viewport._make_placeholder_body).
func _build_waiting_page() -> void:
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.grow_vertical = Control.GROW_DIRECTION_BOTH
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	add_child(col)
	var title := UiFactory.make_label(Fmt.upper(tr("TAB_RND")), &"TitleSerif")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var line := UiFactory.make_label(tr("RND_TREE_CLOSED"), &"CaptionMuted")
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(line)


func _build_chrome() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, PAGE_MARGIN)
	add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", UiTokens.SPACE_M)
	margin.add_child(outer)

	# --- Başlık: Ar-Ge + ipucu · sağda ilerleme ---
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_L)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(UiFactory.make_label(tr("TAB_RND"), &"PageTitleSerif"))
	# İTALİK YOK: gövde-mürekkep kaydında italik bir serif YÜZ tanımlı değil ve
	# bu sayfa yeni bir varyasyon EKLEMEZ.
	head.add_child(UiFactory.make_label(tr("RND_TREE_HINT"), &"CaptionMuted"))
	head.add_child(RnDUiShared.spacer())
	_progress_label = UiFactory.make_label("", &"TitleRowSummary")
	_progress_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_progress_label)
	outer.add_child(head)

	# --- Koşan araştırmanın şeridi (yalnız aktifken görünür) ---
	_bar = _build_bar()
	outer.add_child(_bar)

	# --- AĞAÇ + ayrılmış detay şeridi (RnDTreeView ikisini birden taşır) ---
	_tree = RnDTreeView.new()
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.selection_changed.connect(_on_selection_changed)
	outer.add_child(_tree)

	outer.add_child(_build_legend())


## Üst şerit (§8): ARAŞTIRMA · ad · kalan gün · yüzde, ve YAZININ ARKASINDA
## yüzde çapalı bir dolgu. Dolgu ayrı bir düğüm çünkü bir `StyleBoxFlat` yüzde
## İFADE EDEMEZ (build_bar.gd'nin reçetesi).
func _build_bar() -> Control:
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(0, BAR_H)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.visible = false

	var plate := Panel.new()
	plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var psb := StyleBoxFlat.new()
	psb.bg_color = UiTokens.CARD_BG
	psb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	psb.border_color = UiTokens.CARD_BORDER
	psb.set_corner_radius_all(UiTokens.RADIUS_S)
	psb.anti_aliasing = false
	plate.add_theme_stylebox_override("panel", psb)
	bar.add_child(plate)

	var refs := {}
	bar.add_child(RnDUiShared.fill_host(refs, "bar"))
	_bar_fill = refs["bar"]

	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override("margin_left", UiTokens.SPACE_L)
	pad.add_theme_constant_override("margin_right", UiTokens.SPACE_L)
	bar.add_child(pad)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(row)
	row.add_child(UiFactory.make_label(tr("RND_BAR_TITLE"), &"SectionAmber"))
	_bar_name = UiFactory.make_label("", &"RowName")
	_bar_name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_bar_name)
	row.add_child(RnDUiShared.spacer())
	_bar_days = UiFactory.make_label("", &"RowMeta")
	_bar_days.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_bar_days)
	_bar_percent = UiFactory.make_label("", &"RowMeta", UiTokens.INK)
	_bar_percent.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_bar_percent)
	return bar


func _build_legend() -> HBoxContainer:
	var legend := HBoxContainer.new()
	legend.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	legend.add_child(RnDUiShared.legend_item("intra", tr("RND_LEGEND_INTRA")))
	legend.add_child(RnDUiShared.legend_item("cross", tr("RND_LEGEND_CROSS")))
	legend.add_child(RnDUiShared.legend_item("locked", tr("RND_LEGEND_LOCKED")))
	legend.add_child(RnDUiShared.legend_item("available", tr("RND_LEGEND_AVAILABLE")))
	legend.add_child(RnDUiShared.legend_item("done", tr("RND_LEGEND_DONE")))
	legend.add_child(RnDUiShared.spacer())
	# RND_LEGEND_COUNT ağacın ŞEKLİNİ söyler, durumunu değil: dört aile × beş = yirmi.
	# Üç sayı da ResearchSeam'den TÜRETİLİR, çünkü sabit yazılmış bir "4 aile × 5 = 20"
	# ağaç şekli değiştiği gün sessizce yalan söylerdi. Ve tam olarak geçilen anahtarlar
	# yazılır: `loc_format_args` fazladan anahtarı da eksik anahtarı da düşürür, ve haklıdır
	# — "format eşleşmeyeni yok sayar" diye üç ad birden geçmek sürüklenmeyi gizler.
	var fam_ids := {}
	for nid in ResearchSeam.NODES.keys():
		fam_ids[ResearchSeam.family(String(nid))] = true
	var node_total: int = ResearchSeam.NODES.size()
	var fam_count: int = fam_ids.size()
	legend.add_child(RnDUiShared.legend_item("", tr("RND_LEGEND_COUNT").format({
		"families": fam_count,
		"per": node_total / fam_count,
		"total": node_total,
	})))
	return legend


# --- Tazeleme ----------------------------------------------------------------

## ERTELENMİŞ: bu işleyicilerin çoğu bir düğmenin/`gui_input`ın İÇİNDEN gelen
## motor emit'idir (atama panelinin Başlat'ı → `RnDSystem.start` →
## `research_started`). Sayfayı orada yeniden kurmak, düğümü kendi sinyalinin
## altından çekmek olurdu (team_panel'in yazdığı tuzak).
func _on_state_changed(_arg = null) -> void:
	_refresh.call_deferred()


func _on_selection_changed(node_id: String) -> void:
	_selected = node_id


func _refresh() -> void:
	_paint_bar()
	_paint_progress()
	var key: String = _compute_structure_key()
	if key != _structure_key:
		_structure_key = key
		var keep: String = _selected
		_tree.rebuild()
		# Seçim yeniden kurulumu AŞAR: oyuncu bir düğümü okurken gün dönerse
		# kart kapanmamalı. Kilitli kalmış bir düğüm de geri seçilir — panelin
		# kendi açıklaması var.
		if keep != "":
			_tree.select(keep)
	else:
		_tree.repaint()


## Kart KÜMESİNİ ve karoların ŞEKLİNİ değiştiren her şey buraya girer; ilerleme
## yüzdesi GİRMEZ (yerinde boyanır — günde bir kez yirmi karo yıkmanın sebebi yok).
func _compute_structure_key() -> String:
	var parts := PackedStringArray()
	for id in ResearchSeam.NODES.keys():
		parts.append("%s%s" % [String(id).substr(0, 3), RnDSystem.state_of(String(id))])
	parts.append("a%s" % RnDSystem.active())
	parts.append("f%s" % ("1" if RnDSystem.is_frozen() else "0"))
	parts.append("n%s" % ("1" if RnDSystem.note_pending() else "0"))
	return "/".join(parts)


func _paint_progress() -> void:
	_progress_label.text = tr("RND_TREE_PROGRESS").format({
		"done": RnDSystem.completed_count(), "total": ResearchSeam.NODES.size()})


func _paint_bar() -> void:
	var active: String = RnDSystem.active()
	_bar.visible = active != ""
	if active == "":
		return
	var p: float = RnDSystem.progress(active)
	_bar_name.text = ResearchSeam.node_name(active)
	RnDUiShared.set_fill(_bar_fill, p)
	_bar_percent.text = RnDUiShared.percent_text(p)
	# DONMUŞTA GÜN YAZILMAZ. `days_estimate` -1.0 döner ("katkı yok") ve o sayı
	# asla bölünmez; yerine durumun kendi cümlesi geçer (§5.5 · §5.7). Donmuşsa cümle
	# SEBEBİ söyler ve motordan okunur — tracker'la aynı cümle (§5.6.1).
	var days: float = RnDSystem.days_estimate(active, RnDSystem.assigned(active))
	if days > 0.0:
		_bar_days.text = RnDUiShared.days_text(days)
		_bar_days.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	else:
		var note: String = RnDSystem.freeze_note_key()
		_bar_days.text = tr(note if note != "" else "BUILD_BUSY_NOBODY")
		_bar_days.add_theme_color_override("font_color", UiTokens.ACCENT)
