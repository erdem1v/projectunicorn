extends Control

# ============================================================================
# AR-GE PENCERESİ (GDD "AR-GE MODÜLÜ" §2, §3, §5, §7, §8).
#
# Ortak koyu başlıkta Ar-Ge ve tamamlanan düğüm sayısı. Denetim şeridinde AĞAÇ | GEÇMİŞ ve koşan
# araştırmanın satırı (§5.6: çubuk sekmede de yaşar; pencere açıkken yüzen kart görünmez). Gövdede ağaç
# (RnDTreeView, seçili düğümün kartıyla) ve ayağında anahtarı, ya da Ar-Ge'nin kendi geçmişi (notlar ve
# keşifler; gelen kutusunun okuma bölmesi, okundu durumu tek). v1 yayınlanmadan pencere tek satırdır.
# Pencere görünen içerik kadar uzar (fit_height): ağaç kısa, kart açılınca aşağı doğru uzun; alan
# yetmezse gövde kayar, başlık, şerit ve ayak yerinde kalır.
#
# PROCESS_MODE_ALWAYS (.tscn) SÜS DEĞİL: Godot duraklatılmış düğümleri ÇİZER ama onlara
# `gui_input` DAĞITMAZ — hız 0'da her tıklama yutulurdu.
#
# GÜN SINIRI: `EventBus.day_advanced`e ASLA bağlanmaz. O sinyal günlük tikler dağıtılmadan ÖNCE
# atılıyor; oraya bağlanan bir görünüm DÜNKÜ durumu okur. Ar-Ge'nin gün-sınırı kancası
# `research_progress_changed`.
#
# DİL VE PALET: router sayfayı her değişimde serbest bırakıp yeniden kuruyor (WindowLayer._rebuild);
# buradan da bağlansaydı sayfa iki kez kurulurdu.
#
# TAZELEME MODELİ: ucuz bir anahtar (düğüm durumları + aktif düğüm + donma) yeniden-kurma ile
# yerinde-boyama arasında karar verir; `research_progress_changed` yirmi karoyu yıkmaz.
# ============================================================================

## The window follows the view's content (WindowLayer reads fit_height).
signal fit_changed

const HISTORY := preload("res://scripts/tabs/rnd/rnd_history.gd")
const VIEW_TREE := 0
const VIEW_HISTORY := 1
## The tree's key: each sample and its words.
const KEY := [["intra", "RND_LEGEND_INTRA"], ["cross", "RND_LEGEND_CROSS"], ["locked", "RND_LEGEND_LOCKED"],
	["available", "RND_LEGEND_AVAILABLE"], ["done", "RND_LEGEND_DONE"]]

## The window's head (WindowFrame reads it before the page is in the tree).
var frame_options: Dictionary
var _kpis: HBoxContainer
var _outer: VBoxContainer
var _tabs: HBoxContainer
var _line: HBoxContainer
var _scroll: ScrollContainer
var _tree_body: MarginContainer
var _tree: RnDTreeView
var _foot: PanelContainer
var _history: HISTORY
var _view := VIEW_TREE
var _signals: Array = []
var _structure_key := ""
var _selected := ""


func _init() -> void:
	_kpis = SprintUiShared.box(0)
	frame_options = {"title": "TAB_RND", "kpi": _kpis, "pad": Vector2i.ZERO}


func _ready() -> void:
	# TASLAK NÖBETİ: dil ya da palet değişince router sayfayı yıkıp yeniden kuruyor; bayrak
	# olmasaydı oyuncu okuduğu düğümden dışarı atılırdı. TÜKETİLİR VE SİLİNİR — bekleme
	# sayfasında da, bayat bir seçim bir sonraki turda geri gelmesin.
	var stashed: String = String(GameState.get_flag("rnd_selected", ""))
	GameState.flags.erase("rnd_selected")
	# İKİ SAYFA HÂLİ, TEK KAPI: `RnDSystem.tree_open()` (Ar-Ge §2, MÜHÜRLÜ). `version_shipped`
	# dinlendiği için oyuncu pencere açıkken v1'i yayınlarsa sayfa ağaca döner.
	if not RnDSystem.tree_open():
		# Before v1: the one line that says what the tree waits for (§2).
		var closed := UiFactory.D_empty(RnDUiShared.ICON, tr("RND_TREE_CLOSED"), &"BodyLabel")
		closed.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(closed)
		EventBus.version_shipped.connect(_on_version_shipped, CONNECT_ONE_SHOT)
		return
	_build()
	# §10'un okuma yüzeyinin sinyalleri; `assignment_changed` çünkü bir kişinin işi değişince
	# araştırma DONABİLİR, mesajlar geçmiş için, kapı sinyalleri kapalı eylemler için.
	_signals = [
		EventBus.research_started, EventBus.research_completed,
		EventBus.research_frozen, EventBus.research_resumed,
		EventBus.node_revealed, EventBus.hidden_line_unlocked,
		EventBus.research_progress_changed, EventBus.assignment_changed, EventBus.messages_changed,
		EventBus.event_triggered, EventBus.event_resolved, EventBus.event_set_aside,
	]
	for sig: Signal in _signals:
		sig.connect(_on_state_changed)
	EventBus.rnd_node_requested.connect(select_node)
	_refresh()
	select_node(stashed)


func _on_version_shipped(_v: int) -> void:
	# Bekleme sayfası ağaca döner. Router'ın kendi yıkıp-kurma yolu burada yok, o yüzden sayfayı
	# kendimiz yeniden kuruyoruz.
	UiFactory.clear(self)
	_ready()
	fit_changed.emit()


func _exit_tree() -> void:
	if EventBus.version_shipped.is_connected(_on_version_shipped):
		EventBus.version_shipped.disconnect(_on_version_shipped)
	for sig: Signal in _signals:
		sig.disconnect(_on_state_changed)
	if EventBus.rnd_node_requested.is_connected(select_node):
		EventBus.rnd_node_requested.disconnect(select_node)


## Router sayfayı bırakmadan önce çağırır (propagate_call). Seçili düğüm saklanır; `_ready` onu
## tüketip siler.
func on_page_closing() -> void:
	if _selected != "":
		GameState.set_flag("rnd_selected", _selected)


## The page's height: the strip, the view and, under the tree, its key; before v1 the one line.
func fit_height() -> float:
	if _outer == null:
		return UiTokens.D_H_EMPTY_STATE
	return _outer.get_combined_minimum_size().y + (_tree_body.get_combined_minimum_size().y if _view == VIEW_TREE
		else float(UiTokens.D_H_RND_HISTORY))


# --- Derin bağ ---------------------------------------------------------------

## Dışarıya açık seam, `rnd_node_requested`in işleyicisi. `tab_changed("rnd")` sayfayı SENKRON
## kurduğu için hemen ardından gelen istek bağlanmış bir işleyici bulur (§2). Barın "ata"sı true
## gönderir. AÇILMAMIŞ ama var olan bir düğümü de seçer — kart kendini "Önce {düğüm}." diye
## açıklayabilsin diye (§7).
func select_node(node_id: String, open_assign: bool = false) -> void:
	if ResearchSeam.is_node(node_id):
		_show_view(VIEW_TREE)
		_tree.select(node_id, open_assign)


# --- Kurulum -----------------------------------------------------------------

func _build() -> void:
	_outer = SprintUiShared.column(0)
	_outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_outer)
	var ctl := PanelContainer.new()
	ctl.theme_type_variation = &"WinCtl"
	ctl.custom_minimum_size.y = UiTokens.D_H_WIN_CTL
	var strip := SprintUiShared.box(UiTokens.SPACE_L)
	ctl.add_child(strip)
	_tabs = SprintUiShared.box(0)
	strip.add_child(_tabs)
	strip.add_child(RnDUiShared.spacer())
	_line = SprintUiShared.box(UiTokens.SPACE_L)
	strip.add_child(_line)
	_outer.add_child(ctl)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outer.add_child(_scroll)
	_tree = RnDTreeView.new()
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.selection_changed.connect(func(node_id: String) -> void: _selected = node_id)
	_tree_body = SprintUiShared.pad(_tree, Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XL, UiTokens.SPACE_3XL,
		UiTokens.SPACE_XL))
	_tree_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# The card opens under the tree: the window grows with it.
	_tree_body.minimum_size_changed.connect(fit_changed.emit)
	_scroll.add_child(_tree_body)

	_foot = PanelContainer.new()
	_foot.theme_type_variation = &"WinFoot"
	_foot.custom_minimum_size.y = UiTokens.D_H_WIN_FOOT
	var key := SprintUiShared.box(UiTokens.SPACE_XXL)
	for entry: Array in KEY:
		key.add_child(RnDUiShared.legend_item(entry[0], tr(entry[1])))
	key.add_child(RnDUiShared.spacer())
	key.add_child(SprintUiShared.label(tr("RND_TREE_HINT"), &"CaptionFaint"))
	_foot.add_child(key)
	_outer.add_child(_foot)

	_history = HISTORY.new()
	_history.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_history.visible = false
	_outer.add_child(_history)
	_kpis.add_child(UiFactory.D_kpi(tr("RND_TREE_DONE_KEY"), ""))


func _show_view(view: int) -> void:
	_view = view
	_scroll.visible = view == VIEW_TREE
	_foot.visible = view == VIEW_TREE
	_history.visible = view == VIEW_HISTORY
	if view == VIEW_HISTORY:
		_history.refresh()
	_paint_tabs()
	fit_changed.emit()


# --- Tazeleme ----------------------------------------------------------------

## ERTELENMİŞ: bu işleyicilerin çoğu bir düğmenin İÇİNDEN gelen motor emit'idir (atama panelinin
## Başlat'ı → `RnDSystem.start` → `research_started`). Sayfayı orada yeniden kurmak, düğümü kendi
## sinyalinin altından çekmek olurdu.
func _on_state_changed(_a = null, _b = null) -> void:
	_refresh.call_deferred()


func _refresh() -> void:
	UiFactory.D_kpi_value(_kpis.get_child(0)).text = "%d / %d" % [RnDSystem.completed_count(), ResearchSeam.NODES.size()]
	_paint_tabs()
	_paint_line()
	var key: String = _compute_structure_key()
	if key != _structure_key:
		_structure_key = key
		var keep: String = _selected
		_tree.rebuild()
		# Seçim yeniden kurulumu AŞAR: oyuncu bir düğümü okurken gün dönerse kart kapanmamalı.
		if keep != "":
			_tree.select(keep)
	else:
		_tree.repaint()
	if _view == VIEW_HISTORY:
		_history.refresh()


## Kart KÜMESİNİ ve karoların ŞEKLİNİ değiştiren her şey buraya girer; ilerleme yüzdesi GİRMEZ.
func _compute_structure_key() -> String:
	var parts := PackedStringArray()
	for id in ResearchSeam.NODES.keys():
		parts.append(RnDSystem.state_of(String(id)))
	parts.append(RnDSystem.active())
	parts.append(str(RnDSystem.is_frozen()))
	return "/".join(parts)


## AĞAÇ | GEÇMİŞ, the history with its count; picking one is reading, also while a decision waits.
func _paint_tabs() -> void:
	UiFactory.clear(_tabs)
	var seg := UiFactory.D_seg_tabs([tr("RND_VIEW_TREE"), tr("RND_VIEW_HISTORY")], _view, _show_view,
		[null, HISTORY.items().size()])
	for tab: Button in seg.find_children("*", "Button", true, false):
		tab.set_meta(&"gate_reads", true)
	_tabs.add_child(seg)


## The running research, as the float card reads it (§5.6): its name and who is on it, its progress, the weeks
## left or why it stands frozen, and its two links, off while a decision waits (the read-only strip says why).
func _paint_line() -> void:
	UiFactory.clear(_line)
	var active: String = RnDSystem.active()
	if active == "":
		return
	var frozen: bool = RnDSystem.is_frozen()
	_line.add_child(UiFactory.make_glyph(RnDUiShared.ICON, UiTokens.D_ICON_BUTTON, UiTokens.D_INK_3))
	_line.add_child(SprintUiShared.label(Fmt.upper(tr("RND_BAR_TITLE")), &"KeyLabel"))
	_line.add_child(SprintUiShared.label(ResearchSeam.node_name(active), &"SubjectStrong"))
	var faces := SprintUiShared.box(UiTokens.SPACE_XS)
	for cid in RnDSystem.assigned(active):
		# Someone who left stays on the research until its next tick prunes them.
		var c: Character = CharacterRegistry.get_character(String(cid))
		if c != null:
			faces.add_child(UiFactory.make_person_avatar(c.character_name, c.look, UiTokens.D_AVATAR_ROW_SM))
	_line.add_child(faces)
	var progress: float = RnDSystem.progress(active)
	_line.add_child(HRUiShared.D_bar(Vector2(UiTokens.D_W_RND_PROGRESS, UiTokens.D_H_PROGRESS), progress,
		UiTokens.D_LINE_3 if frozen else UiTokens.D_BAR_FILL))
	_line.add_child(SprintUiShared.label(RnDUiShared.percent_text(progress), &"KeyText"))
	if frozen:
		_line.add_child(UiFactory.make_glyph(RnDUiShared.PAUSE, UiTokens.D_ICON_ROW, UiTokens.D_INK_2))
		_line.add_child(SprintUiShared.label(tr(RnDSystem.freeze_note_key()), &"MetaText"))
	else:
		var weeks: float = RnDSystem.weeks_estimate(active, RnDSystem.assigned(active))
		_line.add_child(SprintUiShared.label(RnDUiShared.weeks_text(weeks) if weeks > 0.0 else tr("RND_WEEKS_NONE"),
			&"MetaMuted"))
	var rule := VSeparator.new()
	rule.custom_minimum_size.y = UiTokens.D_H_BTN_SM
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_line.add_child(rule)
	_line.add_child(RnDUiShared.links(frozen, EventGate.active_id() != "", func() -> void: RnDSystem.pause(),
		select_node.bind(active, true)))
