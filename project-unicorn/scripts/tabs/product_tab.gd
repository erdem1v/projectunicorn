extends Control

# Product tab — Tracker Card dönemi (Blok C kapanışı).
# View routing keyed off (active_build, GameState.flags["mvp_shipped"]):
#   DesignDocumentView | build yok + ship yok (veya _v2_mode planlama)
#   CalmBuildView      | v1 build aktif — build köşedeki Tracker Card'tan akar,
#                        orta alan sakin (ürün adı + "inşa ediliyor", ipucu yok)
#   PostShipView       | ship sonrası + v2/v3 build SÜRERKEN de (canlı ürün
#                        yönetilmeye devam eder; build yine kartta akar)
#
# Eski BuildProgressView + PolishProgressView (ortadaki büyük dev-bar/feed bloğu)
# KALDIRILDI — faz akışı + karar butonları BuildHUDPanel'deki dört-faz Tracker
# Card'ında (TASARIM/GELİŞTİRME/BETA/YAYINLANDI). GÜNLÜK GELİŞİM feed'i silindi
# (Erdem kararı).

# --- Transient planning state (held until start_build is called) ---

var _selected_sub_product_type: String = ""
var _selected_features: Array[String] = []
# Product Lifecycle Part 2B: when true the DesignDocumentView is in "v2 mode" — the shipped
# product's type + name are locked, its existing features are pre-checked and can't be
# dropped, and committing calls start_version_build (add features to the live product).
var _v2_mode: bool = false
# Pool-deepening sub-mode (feature-exhaustion unlock): true when _v2_mode AND every pool
# feature is already in the product. Then _selected_features holds the EXISTING features the
# player picks TO STRENGTHEN (⊆ mvp_components), not the product set.
var _v2_strengthen_mode: bool = false
# Product Lifecycle Part 1 — product name (required to commit) + suggest cursor.
var _selected_product_name: String = ""
var _name_suggest_index: int = 0
# Code-built "what this product strengthens" profile panel (right column).
var _projection_profile: VBoxContainer = null
# Commit ceremony (Blok C): Frank's last word inside the commit card.
var _commit_frank_label: Label = null
# Part 2B: "Vazgeç" escape hatch shown only in v2 mode (back to PostShip without committing).
var _v2_cancel_button: Button = null

# --- View nodes ---
# The static tab title (hidden in post-ship — PostShipTitle carries the identity there).
@onready var title_bar: HBoxContainer = $Margin/Layout/TitleBar
@onready var design_document_view: VBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView
# v1 build sürerken kurma ekranı GÖRÜNÜR ama KİLİTLİ (locked=visible pillar'ı) —
# boş "inşa ediliyor" görünümünün yerini aldı (Erdem playtest kararı).
var _design_locked: bool = false
# Part 2B: PostShipView is now inside a ScrollContainer (content overflowed). post_ship_view
# points at the INNER VBox so all add_child/move_child/get_parent logic is unchanged; the
# scroll wrapper is the node we toggle visible.
@onready var post_ship_scroll: ScrollContainer = $Margin/Layout/BuildStateRoot/PostShipScroll
@onready var post_ship_view: VBoxContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView

# --- DesignDocumentView wiring ---
# Sub-type rows (5)
@onready var sub_type_list: VBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/LeftColumn/LeftVBox/ProductSection/SubTypeList
@onready var type_caption_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/LeftColumn/LeftVBox/ProductSection/CaptionLabel
@onready var center_header_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/HeaderRow/HeaderLabel
@onready var right_header_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/RightColumn/RightVBox/HeaderLabel

# Feature grid (7 cards)
@onready var selection_counter_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/HeaderRow/SelectionCounterLabel
@onready var context_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/ContextLabel
@onready var empty_instruction_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/EmptyInstructionLabel
@onready var feature_grid: GridContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/FeatureGrid

# Projection rows (8)
@onready var projection_list: VBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/RightColumn/RightVBox/ProjectionList
@onready var mentor_advisory_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/RightColumn/RightVBox/MentorAdvisoryLabel

# Commit bar
@onready var commit_bar: Button = $Margin/Layout/BuildStateRoot/DesignDocumentView/CommitBar
@onready var reason_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ReasonLabel

# Product name row (Product Lifecycle Part 1)
@onready var name_row: HBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/NameRow
@onready var name_input: LineEdit = $Margin/Layout/BuildStateRoot/DesignDocumentView/NameRow/NameInput
@onready var suggest_button: Button = $Margin/Layout/BuildStateRoot/DesignDocumentView/NameRow/SuggestButton

# --- PostShipView (PostShip sales phase, B2C/B2B aware) ---
@onready var post_ship_title: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/PostShipTitle
@onready var post_ship_status_body: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/StatusPanel/StatusVBox/StatusBody
@onready var post_ship_frank_line: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/FrankPanel/FrankBody/FrankVBox/FrankLine
@onready var post_ship_traction_bar: ProgressBar = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/TractionPanel/TractionVBox/TractionBar
@onready var post_ship_traction_label: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/TractionPanel/TractionVBox/TractionLabel
@onready var post_ship_sales_button: Button = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/SalesHintButton
# Structural PostShipView panels (for code-built-card order enforcement — Part 2A).
@onready var post_ship_status_panel: PanelContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/StatusPanel
@onready var post_ship_frank_panel: PanelContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/FrankPanel
@onready var post_ship_traction_panel: PanelContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/TractionPanel

# --- Post-ship action center (Yön A redesign) — the sprint banner lives in _action_list ---
var _sprint_banner: VBoxContainer = null

# --- Post-ship funnel (B2C) + traction chip — built in code ---
var _status_funnel: HBoxContainer = null
var _traction_chip: Control = null

# --- Dynamic pricing lever (B2C) — built in code, mounted into PostShipView ---
var _pricing_panel: PanelContainer = null
var _pricing_header_row: HBoxContainer = null
var _pricing_status_chip: Control = null
var _pricing_value_label: Label = null
var _pricing_rationale: HFlowContainer = null
var _pricing_spectrum: Control = null
var _pricing_band: HBoxContainer = null
var _price_slider: HSlider = null
var _pricing_marks: Label = null
var _pricing_projection: VBoxContainer = null
var _pricing_apply: Button = null
var _pricing_initialized: bool = false

# --- Yön A control-panel scaffold (redesign) — built once; authored PostShip nodes are
# reparented into it at runtime (their @onready refs stay valid). ---
var _scaffold_built: bool = false
var _top_strip: HBoxContainer = null
var _version_row: HBoxContainer = null
var _health_slot: HBoxContainer = null
var _left_col: VBoxContainer = null
var _right_col: VBoxContainer = null
var _dim_list: VBoxContainer = null
var _chips_row: HFlowContainer = null
var _left_funnel_body: VBoxContainer = null
var _action_list: VBoxContainer = null
var _price_detail_slot: VBoxContainer = null
var _b2b_info: VBoxContainer = null
var _bottom_strip: VBoxContainer = null
var _rival_line: Label = null
var _action_built: bool = false
# Fiyatlandır seçici satırı kaldırıldı — fiyat paneli B2C'de hep açık;
# _action_rows yalnız sprint + v2 tetikleyicilerini tutar.
var _action_rows: Dictionary = {}       # id -> {root, title, desc, status}
# --- Design-doc redesign (onaylı mockup, Part 1) — yerleşim scaffold'u + chrome ---
var _design_layout_built: bool = false
var _decision_slot: VBoxContainer = null           # alt-sağ KARAR slot'u (CommitCard buraya)
var _counter_chip: PanelContainer = null           # "N/4 seçili" amber rozeti
var _stat_values: Dictionary = {}                  # Row_* -> alt-sol stat kutusunun value Label'ı
var _summary_line: Label = null                    # KARAR kartındaki tek satır özet
# Tip satırı / feature kartı dolguları — bir kez kurulur, paint'te swap edilir
var _card_style_normal: StyleBoxFlat = null
var _card_style_selected: StyleBoxFlat = null


func _ready() -> void:
	_wire_design_document_view()
	post_ship_sales_button.pressed.connect(_on_post_ship_sales_pressed)
	EventBus.day_advanced.connect(_on_day_advanced)
	EventBus.build_progress_changed.connect(_on_build_progress_changed)
	# Ship/cancel/faz geçişinde anında re-route (saatlik sinyali beklemeden) —
	# Tracker Card "PostShip'e geç" tab'ı yeniden kurduğunda da doğru ekran açılır.
	EventBus.build_phase_changed.connect(_on_build_phase_changed_route)
	# PostShip repaint on sales-state changes (immediate feedback for revenue/leads).
	EventBus.mrr_changed.connect(_on_sales_state_changed)
	EventBus.customer_added.connect(_on_sales_state_changed)
	EventBus.customer_removed.connect(_on_sales_state_changed)
	EventBus.prospect_added.connect(_on_sales_state_changed)
	EventBus.prospect_removed.connect(_on_sales_state_changed)
	# Economy Model v2: audience flows hourly but b2c_audience is a silent flag, so
	# repaint the PostShip audience line each in-game hour (MRR repaints via mrr_changed).
	EventBus.hour_changed.connect(_on_sales_state_changed)
	_refresh_view()


func _exit_tree() -> void:
	if EventBus.day_advanced.is_connected(_on_day_advanced):
		EventBus.day_advanced.disconnect(_on_day_advanced)
	if EventBus.build_progress_changed.is_connected(_on_build_progress_changed):
		EventBus.build_progress_changed.disconnect(_on_build_progress_changed)
	if EventBus.build_phase_changed.is_connected(_on_build_phase_changed_route):
		EventBus.build_phase_changed.disconnect(_on_build_phase_changed_route)
	for sig in [EventBus.mrr_changed, EventBus.customer_added, EventBus.customer_removed,
			EventBus.prospect_added, EventBus.prospect_removed, EventBus.hour_changed]:
		if sig.is_connected(_on_sales_state_changed):
			sig.disconnect(_on_sales_state_changed)


# --- View routing ---

func _refresh_view() -> void:
	var active = ProductSystem.get_active_build()
	var shipped: bool = GameState.get_flag("mvp_shipped", false)
	if _v2_mode and active == null and shipped:
		# Part 2B: player opened "v2 Geliştir" — plan the next version in the design view
		# (pre-filled from the live product) before the build exists. Overrides the
		# active==null && shipped → PostShip route below.
		_show_state(design_document_view)
		_refresh_design_document()
		return
	# (Sprint artık build slotu kullanmıyor — carrier dalı kalktı; sprint durumu
	# PostShip route'larında flag'den okunur, routing null+shipped / build+shipped
	# dallarına doğal düşer.)
	if active == null and shipped:
		_show_state(post_ship_scroll)
		_paint_post_ship()
	elif active != null and active.current_phase in ["iteration", "development", "bugfix", "polish"]:
		# Tracker Card (Blok C): build köşe kartından akar. v2/v3 build'de oyuncu
		# canlı ürünü yönetmeye devam eder (PostShip); ilk build'de kurma ekranı
		# GÖRÜNÜR ama KİLİTLİ kalır (ne inşa ettiğini görür, değiştiremez).
		if active.is_version_build or shipped:
			_show_state(post_ship_scroll)
			_paint_post_ship()
		else:
			_show_state(design_document_view)
			_paint_design_locked(active)
	else:
		_show_state(design_document_view)
		_paint_design_normal()


func _show_state(view: Control) -> void:
	design_document_view.visible = (view == design_document_view)
	# Post-ship toggles the scroll WRAPPER (post_ship_view is now the inner VBox).
	post_ship_scroll.visible = (view == post_ship_scroll)
	# The generic "Product / Design document" tab title is redundant in post-ship
	# (PostShipTitle shows "<name> · vN · canlı") — hide it there to kill the double title.
	title_bar.visible = (view != post_ship_scroll)


func _paint_design_locked(b: FeatureBuild) -> void:
	# Locked=visible pillar: oyuncu NE kurduğunu görür (tip + feature'lar +
	# projeksiyon), build bitene dek DEĞİŞTİREMEZ. Seçim build'den re-seed edilir
	# (commit transient state'i sıfırlamıştı).
	_design_locked = true
	_selected_sub_product_type = b.sub_product_type_id
	_selected_features.clear()
	for fid in b.feature_ids:
		_selected_features.append(String(fid))
	_selected_product_name = b.product_name
	name_input.text = b.product_name
	_refresh_design_document()
	# Kilit görünümü paint'ten SONRA uygulanır (commit bar metnini/durumunu ezer).
	name_input.editable = false
	suggest_button.visible = false
	commit_bar.disabled = true
	commit_bar.text = "İNŞA EDİLİYOR — TASARIM KİLİTLİ"   # working-metin
	reason_label.visible = false
	_set_design_dim(0.6)   # working değer — Erdem F5


func _paint_design_normal() -> void:
	# Kilitten normale dönüş: dim geri alınır; editable/suggest'i
	# _refresh_design_document zaten normal akışa göre yazar.
	if _design_locked:
		_design_locked = false
		_set_design_dim(1.0)
	# İptal edilen build'in seçimi kurma ekranına geri gelir (yanlış-tık affı) —
	# oyuncu düzenleyip yeniden başlatır. Tek-seferlik flag, burada tüketilir.
	if GameState.has_flag("cancelled_build_prefill"):
		var pf: Dictionary = GameState.get_flag("cancelled_build_prefill", {})
		GameState.flags.erase("cancelled_build_prefill")
		_selected_sub_product_type = String(pf.get("type", ""))
		_selected_features.clear()
		for fid in pf.get("features", []):
			_selected_features.append(String(fid))
		_selected_product_name = String(pf.get("name", ""))
		name_input.text = _selected_product_name
	_refresh_design_document()


func _set_design_dim(alpha: float) -> void:
	var cols: Control = design_document_view.get_node_or_null("ColumnsRow")
	if cols != null:
		cols.modulate = Color(1, 1, 1, alpha)
	var bottom: Control = design_document_view.get_node_or_null("BottomRow")
	if bottom != null:
		bottom.modulate = Color(1, 1, 1, alpha)


func _on_build_phase_changed_route(_new_phase: String) -> void:
	_refresh_view()


# =========================================================================
#  DesignDocumentView wiring + painting
# =========================================================================

func _wire_design_document_view() -> void:
	# Sub-type rows
	for i in range(sub_type_list.get_child_count()):
		var row: Panel = sub_type_list.get_child(i) as Panel
		if row != null:
			row.gui_input.connect(_on_sub_type_row_input.bind(row))
	# Feature cards
	for i in range(feature_grid.get_child_count()):
		var card: Panel = feature_grid.get_child(i) as Panel
		if card != null:
			card.gui_input.connect(_on_feature_card_input.bind(card))
	# Commit
	commit_bar.pressed.connect(_on_commit_pressed)
	# Product name row
	name_input.text_changed.connect(_on_name_input_changed)
	suggest_button.pressed.connect(_on_suggest_pressed)
	_name_suggest_index = GameState.day   # vary the first suggestion per run
	# Commit ceremony (Blok C): amber CTA + a framed decision card (no more gray slab).
	commit_bar.theme_type_variation = &"CommitButton"
	_ensure_design_layout()   # onaylı mockup yerleşimi (üst: tip+feature, alt: projeksiyon+karar)
	_build_commit_card()      # KARAR kartını _decision_slot'a kurar — layout'tan SONRA çağrılmalı
	_ensure_sub_type_scroll() # HOTFIX: 10 tipli birleşik havuz taşmasın — _ensure_design_layout'tan
	                          # SONRA (left_col zinciri SubTypeList parent'ından yürür)


func _ensure_design_layout() -> void:
	# Onaylı mockup (Yön A) yerleşimi: üst sıra = ÜRÜN TİPİ kolonu + ÖZELLİKLER kolonu,
	# alt sıra = "BU ÜRÜN NEYİ GÜÇLENDİRİYOR" projeksiyon kartı + KARAR slot'u.
	# Reparent-only + guard'lı (bir kez); @onready ref'leri geçerli kalır, boyama
	# mantığı ve hesaplar değişmez. Eski _ensure_design_two_col'un yerini alır.
	if _design_layout_built:
		return
	_design_layout_built = true
	# Üst sıra oranları: sol tip kolonu dar, feature kolonu geniş.
	var left_col: Control = sub_type_list.get_parent().get_parent().get_parent() as Control  # SubTypeList→ProductSection→LeftVBox→LeftColumn
	if left_col != null:
		left_col.size_flags_stretch_ratio = 2.6
	var center_col: Control = feature_grid.get_parent().get_parent() as Control
	center_col.size_flags_stretch_ratio = 5.4
	# Alt sıra: ProjectionCard (authored RightVBox buraya reparent) + DecisionSlot.
	var right_vbox: Node = projection_list.get_parent()        # RightColumn/RightVBox
	var right_col: Control = right_vbox.get_parent() as Control
	var bottom := HBoxContainer.new()
	bottom.name = "BottomRow"
	bottom.add_theme_constant_override("separation", 12)
	design_document_view.add_child(bottom)
	design_document_view.move_child(bottom, 1)                 # ColumnsRow'un hemen altı
	var proj_card := PanelContainer.new()
	proj_card.name = "ProjectionCard"
	proj_card.theme_type_variation = &"CardPanel"
	proj_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	proj_card.size_flags_stretch_ratio = 5.0
	bottom.add_child(proj_card)
	right_vbox.get_parent().remove_child(right_vbox)
	proj_card.add_child(right_vbox)
	right_col.visible = false
	_decision_slot = VBoxContainer.new()
	_decision_slot.name = "DecisionSlot"
	_decision_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decision_slot.size_flags_stretch_ratio = 4.0
	bottom.add_child(_decision_slot)
	# Projeksiyon kartı içeriği: başlık + üç stat kutusu; eski Row_* listesi gizli kalır
	# (_set_projection_row hâlâ ValueRight'a yazar — tek kaynak + harness dump'ı korunur).
	right_header_label.text = "BU ÜRÜN NEYİ GÜÇLENDİRİYOR"
	var stat_row := HBoxContainer.new()
	stat_row.name = "StatRow"
	stat_row.add_theme_constant_override("separation", 10)
	right_vbox.add_child(stat_row)
	right_vbox.move_child(stat_row, right_header_label.get_index() + 1)
	for entry in [["Row_SubType", "ÜRÜN TİPİ"], ["Row_FeatureCount", "ÖZELLİK SAYISI"], ["Row_Duration", "TAHMİNİ SÜRE"]]:
		var stat := UiFactory.make_stat(String(entry[1]), "—")
		var cell := UiFactory.make_card(stat, true)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_row.add_child(cell)
		_stat_values[String(entry[0])] = stat.get_child(1).get_child(0)  # make_stat: [Caption, Row[Value,..]]
	projection_list.visible = false
	var right_sep: Node = right_vbox.get_node_or_null("RightSeparator")
	if right_sep is Control:
		(right_sep as Control).visible = false
	# Sayaç rozeti: authored SelectionCounterLabel amber chip'e alınır (ref geçerli kalır;
	# HeaderRow HBox olduğundan başlıkla çakışma yapısal olarak imkânsız).
	var header_row: Node = selection_counter_label.get_parent()
	var counter_idx: int = selection_counter_label.get_index()
	_counter_chip = PanelContainer.new()
	_counter_chip.name = "CounterChip"
	var chip_sb := StyleBoxFlat.new()
	chip_sb.bg_color = UiTokens.AMBER_BG
	chip_sb.set_corner_radius_all(3)
	chip_sb.content_margin_left = 8
	chip_sb.content_margin_right = 8
	chip_sb.content_margin_top = 2
	chip_sb.content_margin_bottom = 2
	_counter_chip.add_theme_stylebox_override("panel", chip_sb)
	_counter_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header_row.remove_child(selection_counter_label)
	header_row.add_child(_counter_chip)
	header_row.move_child(_counter_chip, counter_idx)
	_counter_chip.add_child(selection_counter_label)
	selection_counter_label.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
	# ContextLabel emekli — tip adı artık "ÖZELLİKLER · [tip]" başlığında.
	context_label.visible = false


func _build_commit_card() -> void:
	# KARAR kartı — alt-sağ DecisionSlot'a kurulur (mockup). Authored NameRow/CommitBar/
	# ReasonLabel @onready çözüldükten SONRA içine reparent edilir; ref'ler geçerli kalır.
	var card := PanelContainer.new()
	card.name = "CommitCard"
	card.theme_type_variation = &"CardPanel"
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	card.add_child(vb)
	vb.add_child(UiFactory.make_section_header("Karar"))
	_decision_slot.add_child(card)
	for n in [name_row, commit_bar, reason_label]:
		n.get_parent().remove_child(n)
		vb.add_child(n)
	# Tek satır özet (mockup: "Nova — AI Assistant, 2 özellik. ...") — buton üstünde.
	_summary_line = Label.new()
	_summary_line.theme_type_variation = &"CaptionMuted"
	_summary_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_line.visible = false
	vb.add_child(_summary_line)
	vb.move_child(_summary_line, commit_bar.get_index())
	# Esnek boşluk: buton kartın altına otursun (mockup'taki ferah karar bölgesi).
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(spacer)
	vb.move_child(spacer, commit_bar.get_index())
	# Frank's last word, between the button and the reason hint.
	_commit_frank_label = Label.new()
	_commit_frank_label.theme_type_variation = &"QuoteSerif"
	_commit_frank_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_commit_frank_label.visible = false
	vb.add_child(_commit_frank_label)
	vb.move_child(_commit_frank_label, reason_label.get_index())  # above the reason hint
	# Part 2B: v2 escape hatch — back to the live product without committing a version.
	_v2_cancel_button = Button.new()
	_v2_cancel_button.text = "Vazgeç"
	_v2_cancel_button.visible = false
	_v2_cancel_button.pressed.connect(_on_v2_cancel_pressed)
	vb.add_child(_v2_cancel_button)


func _refresh_design_document() -> void:
	_paint_sub_type_list()
	_paint_feature_grid()
	_refresh_projection()
	_refresh_commit_bar()
	# Name row appears once a product type is chosen.
	name_row.visible = _selected_sub_product_type != ""
	# Part 2B: in v2 mode the name is locked (product keeps its identity) and the escape
	# hatch is shown; normal build restores editable name + reroll.
	name_input.editable = not _v2_mode
	suggest_button.visible = not _v2_mode
	if _v2_cancel_button != null:
		_v2_cancel_button.visible = _v2_mode


# ---- Sub-type list ----

func _paint_sub_type_list() -> void:
	# Onboarding rework 2026-07-16: subgenre adımı kalktı — havuz artık TÜM
	# ürün tipleri (ai + saas birleşik); commit edilen ürün subgenre'ı yazar.
	var sub_types: Array = ProductCatalog.get_all_sub_product_types()
	type_caption_label.text = "%d SEÇENEK — BİRİNİ SEÇ" % sub_types.size()
	_ensure_card_styles()
	_ensure_row_capacity(sub_types.size())
	for i in range(sub_type_list.get_child_count()):
		var row: Panel = sub_type_list.get_child(i) as Panel
		if row == null:
			continue
		if i < sub_types.size():
			var data: Dictionary = sub_types[i]
			var sub_id: String = String(data.get("id", ""))
			var refs: Dictionary = _ensure_type_row_chrome(row)
			(refs["title"] as Label).text = String(data.get("name_human", data.get("name", "")))
			(refs["category"] as Label).text = String(data.get("category_tr", ""))
			(refs["desc"] as Label).text = String(data.get("desc_tr", data.get("pitch", "")))
			var icon_node := refs["icon"] as TextureRect
			var icon_path: String = "res://assets/icons/products/%s.svg" % sub_id
			if ResourceLoader.exists(icon_path):
				icon_node.texture = load(icon_path)
				icon_node.visible = true
			else:
				icon_node.texture = null
				icon_node.visible = false
			row.set_meta("sub_type_id", sub_id)
			row.visible = true
			var selected: bool = (_selected_sub_product_type == sub_id)
			var sel_border: Panel = row.get_node("SelectedBorder")
			sel_border.visible = selected
			# Pale-amber dolgu taban Panel'in stylebox'ında (SelectedBorder üstte çizilir —
			# dolgu ona konursa metni yıkar); amber çerçeve SelectedBorder'ın işi.
			row.add_theme_stylebox_override("panel", _card_style_selected if selected else _card_style_normal)
		else:
			row.visible = false


func _ensure_sub_type_scroll() -> void:
	# HOTFIX (Erdem 2026-07-16): the merged 10-type pool overflowed the authored
	# 5-row column and pushed the decision area (commit button) off-screen.
	# Stopgap: wrap SubTypeList in a ScrollContainer capped near the old 5-row
	# height so the rest of the screen keeps its layout. The real picker
	# redesign is a separate queued task — do not grow this into one.
	if sub_type_list.get_parent() is ScrollContainer:
		return
	var section: Node = sub_type_list.get_parent()
	var list_index: int = sub_type_list.get_index()
	var scroll := ScrollContainer.new()
	scroll.name = "SubTypeScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(0, 340)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_child(scroll)
	section.move_child(scroll, list_index)
	sub_type_list.reparent(scroll)
	sub_type_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _ensure_row_capacity(needed: int) -> void:
	# Merged pool (10 tip) > authored 5 satır — eksikleri ilk satırı klonlayarak
	# büyüt (sessiz kırpma yok). Klonun kopyalanan chrome'u ve meta ref'leri
	# ORİJİNAL node'ları gösterir — temizle ki _ensure_type_row_chrome kendi
	# chrome'unu sıfırdan kursun; gui_input'u da burada bağla (wire yalnızca
	# authored satırları bağladı).
	if sub_type_list.get_child_count() >= needed:
		return
	var template: Panel = sub_type_list.get_child(0) as Panel
	if template == null:
		return
	while sub_type_list.get_child_count() < needed:
		var clone: Panel = template.duplicate() as Panel
		clone.name = "SubTypeRow_%d" % sub_type_list.get_child_count()
		if clone.has_meta("chrome"):
			clone.remove_meta("chrome")
		if clone.has_meta("sub_type_id"):
			clone.remove_meta("sub_type_id")
		var stale_chrome: Node = clone.get_node_or_null("TypeChrome")
		if stale_chrome != null:
			stale_chrome.free()
		sub_type_list.add_child(clone)
		clone.gui_input.connect(_on_sub_type_row_input.bind(clone))


func _ensure_card_styles() -> void:
	# Seçili/normal kart dolguları — authored StyleBoxFlat_row_inner ile aynı anatomi
	# (1px sıcak-tan çerçeve, radius 4), seçilide zemin pale-amber'a kayar. Bir kez
	# kurulur, paint'te swap edilir (per-paint StyleBox üretimi yok).
	if _card_style_normal != null:
		return
	_card_style_normal = StyleBoxFlat.new()
	_card_style_normal.bg_color = UiTokens.CARD_BG
	_card_style_normal.border_color = UiTokens.CARD_BORDER
	_card_style_normal.set_border_width_all(1)
	_card_style_normal.set_corner_radius_all(4)
	_card_style_selected = StyleBoxFlat.new()
	_card_style_selected.bg_color = UiTokens.CARD_BG.lerp(UiTokens.AMBER_BG, 0.55)
	_card_style_selected.border_color = UiTokens.CARD_BORDER
	_card_style_selected.set_border_width_all(1)
	_card_style_selected.set_corner_radius_all(4)


func _ensure_type_row_chrome(row: Panel) -> Dictionary:
	# Tip kartı chrome'u (mockup): ikon + TR başlık (name_human) + kategori alt-etiketi
	# (category_tr, mono) + tek satır açıklama (desc_tr). Authored RowLayout gizlenir
	# (taşınmaz — adları/yolları korunur); bir kez kurulur, ref'ler meta'da cache'li.
	# Chrome'un tamamı mouse IGNORE — satırın gui_input tıklaması yaşamaya devam eder.
	if row.has_meta("chrome"):
		return row.get_meta("chrome")
	var row_layout: Control = row.get_node_or_null("RowLayout")
	if row_layout != null:
		row_layout.visible = false
	var chrome := HBoxContainer.new()
	chrome.name = "TypeChrome"
	chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(chrome)
	chrome.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chrome.offset_left = 12.0
	chrome.offset_top = 8.0
	chrome.offset_right = -12.0
	chrome.offset_bottom = -8.0
	chrome.add_theme_constant_override("separation", 10)
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(24, 24)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.modulate = UiTokens.ACCENT_DEEP
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.add_child(icon)
	var text_box := VBoxContainer.new()
	text_box.name = "TextBox"
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 1)
	text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.add_child(text_box)
	var title := UiFactory.make_label("", &"NameSerif")
	title.name = "Title"
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.add_child(title)
	var cat := Label.new()
	cat.name = "Category"
	cat.theme_type_variation = &"SectionLabel"
	cat.add_theme_font_size_override("font_size", 9)
	cat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.add_child(cat)
	var desc := Label.new()
	desc.name = "Desc"
	desc.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	desc.add_theme_font_size_override("font_size", 11)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.max_lines_visible = 2
	desc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.add_child(desc)
	var refs := {"icon": icon, "title": title, "category": cat, "desc": desc}
	row.set_meta("chrome", refs)
	return refs


func _on_sub_type_row_input(event: InputEvent, row: Panel) -> void:
	# Build sürerken kurma ekranı kilitli — görüntü var, değişiklik yok.
	if _design_locked:
		return
	# Part 2B: in v2 mode the product type is fixed to the live product — no re-picking.
	if _v2_mode:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var sub_type_id: String = row.get_meta("sub_type_id", "")
		if sub_type_id == "":
			return
		# Switching sub-type invalidates the feature pool — clear features +
		# duration so the user re-decides downstream.
		_selected_sub_product_type = sub_type_id
		_selected_features = []
		# Prefill a suggested product name the first time a type is picked (the
		# player can edit or reroll it). Name persists across sub-type switches.
		if _selected_product_name == "":
			var s: String = ProductCatalog.suggest_product_name(_name_suggest_index)
			name_input.text = s
			_selected_product_name = s
		_refresh_design_document()


func _on_name_input_changed(new_text: String) -> void:
	_selected_product_name = new_text.strip_edges()
	_refresh_commit_bar()   # cheap toggle; avoids a full repaint that would reset the caret


func _on_suggest_pressed() -> void:
	_name_suggest_index += 1
	var s: String = ProductCatalog.suggest_product_name(_name_suggest_index)
	name_input.text = s
	_selected_product_name = s
	_refresh_commit_bar()


# ---- Feature grid ----

func _paint_feature_grid() -> void:
	if _selected_sub_product_type == "":
		feature_grid.visible = false
		center_header_label.text = "ÖZELLİKLER"
		empty_instruction_label.visible = true
		selection_counter_label.text = "0 / 4 seçili — min 2"
		return
	empty_instruction_label.visible = false
	# Tip adı başlıkta taşınır (mockup: "ÖZELLİKLER · AI ASSISTANT"); ContextLabel emekli.
	center_header_label.text = "ÖZELLİKLER · %s" % _tr_upper(_sub_product_type_name_tr(_selected_sub_product_type))
	feature_grid.visible = true
	_ensure_card_styles()

	var pool: Array = ProductCatalog.get_feature_pool(_selected_sub_product_type)
	var feature_cap: int
	if _v2_strengthen_mode:
		feature_cap = ProductSystem.STRENGTHEN_MAX_PER_VERSION
	elif _v2_mode:
		feature_cap = ProductSystem.MAX_VERSION_FEATURES
	else:
		feature_cap = 4
	var at_max: bool = _selected_features.size() >= feature_cap
	for i in range(feature_grid.get_child_count()):
		var card: Panel = feature_grid.get_child(i) as Panel
		if card == null:
			continue
		if i < pool.size():
			var data: Dictionary = pool[i]
			var fid: String = String(data.get("id", ""))
			var refs: Dictionary = _ensure_feature_card_chrome(card)
			(refs["name"] as Label).text = String(data.get("name", ""))
			(refs["desc"] as Label).text = String(data.get("desc_short", data.get("voice", "")))
			(refs["badge"] as Label).text = "+%dg" % int(data.get("complexity", 0))
			(refs["contrib"] as Label).text = _feature_contrib_text(data)
			card.set_meta("feature_id", fid)
			_paint_axes(card, data)
			card.visible = true
			var sel_border: Panel = card.get_node("SelectedBorder")
			var selected: bool = _selected_features.has(fid)
			sel_border.visible = selected
			(refs["check"] as Label).visible = selected
			card.add_theme_stylebox_override("panel", _card_style_selected if selected else _card_style_normal)
			# Dim unselected cards when at the 4-feature cap (matches Spec #2 recipe).
			if at_max and not selected:
				card.modulate = Color(1, 1, 1, 0.55)
			else:
				card.modulate = Color(1, 1, 1, 1)
		else:
			card.visible = false
	if _v2_strengthen_mode:
		selection_counter_label.text = "%d / %d güçlendirme seçili" % [
			_selected_features.size(), ProductSystem.STRENGTHEN_MAX_PER_VERSION]
	elif _v2_mode:
		var base_n: int = GameState.get_flag("mvp_components", []).size()
		selection_counter_label.text = "%d / %d özellik · v1: %d, +%d yeni" % [
			_selected_features.size(), ProductSystem.MAX_VERSION_FEATURES, base_n,
			max(0, _selected_features.size() - base_n)]
	else:
		selection_counter_label.text = "%d / 4 seçili — min 2" % _selected_features.size()


# Feature-card three-axis display (Product Lifecycle Part 1 → redesign Part 1).
# Built in code so the .tscn cards need no per-card surgery: the static ComplexityRow
# is hidden and a 3-row AxesBox is added once — artık 15 nokta değil, 5-segment yatay
# bar (mockup). Caption'lar hazır-uppercase (Godot to_upper() TR i/ı bilmez).
const _AXIS_ROWS := [["pull", "ÇEKİM"], ["complexity", "KARMAŞIKLIK"], ["stakes", "RİSK"]]
const _AXIS_SEG_EMPTY := Color(0.85, 0.82, 0.75, 1)   # boş segment (eski boş nokta tonu)


func _ensure_axes_box(card: Panel) -> VBoxContainer:
	var layout: VBoxContainer = card.get_node("CardLayout")
	var existing := layout.get_node_or_null("AxesBox")
	if existing != null:
		return existing
	var static_row := layout.get_node_or_null("ComplexityRow")
	if static_row != null:
		static_row.visible = false
	var box := VBoxContainer.new()
	box.name = "AxesBox"
	box.add_theme_constant_override("separation", 4)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for pair in _AXIS_ROWS:
		var row := HBoxContainer.new()
		row.name = String(pair[0])
		row.add_theme_constant_override("separation", 8)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cap := Label.new()
		cap.text = String(pair[1])
		cap.custom_minimum_size = Vector2(82, 0)
		cap.theme_type_variation = &"SectionLabel"
		cap.add_theme_font_size_override("font_size", 9)
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(cap)
		var segs := HBoxContainer.new()
		segs.name = "Seg"
		segs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		segs.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		segs.add_theme_constant_override("separation", 3)
		segs.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in 5:
			var seg := ColorRect.new()
			seg.custom_minimum_size = Vector2(0, 5)
			seg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			segs.add_child(seg)
		row.add_child(segs)
		box.add_child(row)
	layout.add_child(box)
	return box


func _paint_axes(card: Panel, data: Dictionary) -> void:
	var box := _ensure_axes_box(card)
	for pair in _AXIS_ROWS:
		var key := String(pair[0])
		var v: int = int(data.get(key, 1))
		var segs: HBoxContainer = box.get_node(key + "/Seg")
		var fill: Color = UiTokens.ACCENT
		if key == "pull":
			fill = UiTokens.POSITIVE
		elif key == "stakes":
			fill = UiTokens.NEGATIVE
		for i in range(segs.get_child_count()):
			var seg: ColorRect = segs.get_child(i) as ColorRect
			if seg == null:
				continue
			seg.color = fill if i < v else _AXIS_SEG_EMPTY


func _ensure_feature_card_chrome(card: Panel) -> Dictionary:
	# Feature kartı chrome'u (mockup): başlık satırı (isim + ✓ + "+Ng" süre rozeti),
	# açıklama (authored VoiceLabel yerinde), segmentli AxesBox ve boyut-katkı satırı.
	# Bir kez kurulur; NameLabel HeaderRow'a reparent edilir — eski CardLayout/NameLabel
	# yolu yerine meta ref'leri kullanılır. Chrome mouse IGNORE (kart tıklaması yaşar).
	if card.has_meta("chrome"):
		return card.get_meta("chrome")
	var layout: VBoxContainer = card.get_node("CardLayout")
	var name_label: Label = layout.get_node("NameLabel")
	var header := HBoxContainer.new()
	header.name = "HeaderRow"
	header.add_theme_constant_override("separation", 8)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(header)
	layout.move_child(header, 0)
	name_label.get_parent().remove_child(name_label)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)
	var check := Label.new()
	check.name = "Check"
	check.text = "✓"
	check.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
	check.visible = false
	check.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(check)
	var badge := UiFactory.make_pill("", UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP, false)
	badge.name = "DurBadge"
	header.add_child(badge)
	# AxesBox'ı ContribLine'dan ÖNCE kur ki sıra mockup'taki gibi kalsın:
	# HeaderRow → açıklama → barlar → katkı satırı.
	_ensure_axes_box(card)
	var contrib := Label.new()
	contrib.name = "ContribLine"
	contrib.theme_type_variation = &"SectionLabel"
	contrib.add_theme_font_size_override("font_size", 9)
	contrib.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
	contrib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(contrib)
	var refs := {
		"name": name_label, "check": check,
		"badge": badge.get_child(0), "desc": layout.get_node("VoiceLabel"),
		"contrib": contrib,
	}
	card.set_meta("chrome", refs)
	return refs


func _feature_contrib_text(data: Dictionary) -> String:
	# Boyut-katkı satırı ("İNOVASYON +6 · EDİTÖR AKIŞI +2"): dimension_contribution ham
	# ağırlıklarından (0.5-4.0) display-only ×2 ölçek — WORKING CALL (mockup'ın +8/+5 dili;
	# Erdem çarpanı/top-2'yi değiştirebilir). Ağırlıklardan yalnız OKUR, hesaba girmez.
	var dc: Dictionary = data.get("dimension_contribution", {})
	var labels := _axis_display_labels()
	var entries: Array = []
	for axis in ["innovation", "stability", "usability"]:
		var v: int = int(round(float(dc.get(axis, 0.0)) * 2.0))
		if v > 0:
			entries.append([v, String(labels.get(axis, axis))])
	entries.sort_custom(func(a, b): return a[0] > b[0])
	var parts: PackedStringArray = []
	for e in entries.slice(0, 2):
		parts.append("%s +%d" % [_tr_upper(String(e[1])), int(e[0])])
	return " · ".join(parts)


func _tr_upper(s: String) -> String:
	# Godot to_upper() Türkçe i/ı ayrımını bilmez ("i"→"I"); başlık/etiketler için düzelt.
	return s.replace("i", "İ").replace("ı", "I").to_upper()


func _on_feature_card_input(event: InputEvent, card: Panel) -> void:
	# Build sürerken kurma ekranı kilitli — görüntü var, değişiklik yok.
	if _design_locked:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var feature_id: String = card.get_meta("feature_id", "")
		if feature_id == "":
			return
		# Pool-deepening: in strengthen sub-mode, selecting an EXISTING feature marks it to
		# strengthen (freely toggleable, capped at STRENGTHEN_MAX_PER_VERSION).
		if _v2_mode and _v2_strengthen_mode:
			if _selected_features.has(feature_id):
				_selected_features.erase(feature_id)
			elif GameState.get_flag("mvp_components", []).has(feature_id) \
					and _selected_features.size() < ProductSystem.STRENGTHEN_MAX_PER_VERSION:
				_selected_features.append(feature_id)
			_refresh_design_document()
			return
		if _selected_features.has(feature_id):
			# Part 2B: shipped features are locked in v2 mode — you add to the product, not strip it.
			if _v2_mode and GameState.get_flag("mvp_components", []).has(feature_id):
				return
			_selected_features.erase(feature_id)
		else:
			# v2 carries the union (v1 + new) so it uses the larger version cap, not the v1 max of 4.
			var cap: int = ProductSystem.MAX_VERSION_FEATURES if _v2_mode else 4
			if _selected_features.size() >= cap:
				return
			_selected_features.append(feature_id)
		_refresh_design_document()


# ---- Projection panel ----

func _refresh_projection() -> void:
	# Spec #4: planning no longer commits a duration, so the duration/quality-
	# ceiling/bug-risk/runway-cost/runway-after rows have nothing honest to
	# forecast. Keep them hidden; show sub-type + feature count + a one-line
	# hint about iteration cadence so the player knows what they're committing
	# to before pressing build.
	# Dil tutarlılığı (redesign): stat kutusu TR başlık gösterir (display-only —
	# _sub_product_type_name EN etiketi BuildProgress tarafında yaşamaya devam eder).
	_set_projection_row("Row_SubType", _sub_product_type_name_tr(_selected_sub_product_type) if _selected_sub_product_type != "" else "—")
	var _feat_cap: int
	if _v2_strengthen_mode:
		_feat_cap = ProductSystem.STRENGTHEN_MAX_PER_VERSION
	elif _v2_mode:
		_feat_cap = ProductSystem.MAX_VERSION_FEATURES
	else:
		_feat_cap = 4
	_set_projection_row("Row_FeatureCount", "%d / %d" % [_selected_features.size(), _feat_cap] if not _selected_features.is_empty() else "—")
	# Duration row. v2/strengthen süresi YENİ işe dayanır (ProductSystem.version_dev_days
	# — start_version_build ile TEK kaynak): eski tam-union süresi "rozet +4g ama süre
	# ~14 gün" görsel bug'ıydı. v1 eski formülünde kalır.
	if _v2_strengthen_mode:
		if _selected_features.is_empty():
			_hide_projection_row("Row_Duration")
		else:
			_set_projection_row("Row_Duration", "~%d gün" % ProductSystem.version_dev_days(_selected_features))
	elif _v2_mode:
		var added_ids: Array = _v2_added_ids()
		if added_ids.is_empty():
			_hide_projection_row("Row_Duration")
		else:
			_set_projection_row("Row_Duration", "~%d gün" % ProductSystem.version_dev_days(added_ids))
	elif not _selected_features.is_empty():
		_set_projection_row("Row_Duration", "~%d gün" % (ProductSystem.DEVELOPMENT_DAYS_BASE + _selected_total_complexity()))
	else:
		_hide_projection_row("Row_Duration")
	_hide_projection_row("Row_ShipDate")
	_hide_projection_row("Row_QualityCeiling")
	_hide_projection_row("Row_BugRisk")
	_hide_projection_row("Row_RunwayCost")
	_hide_projection_row("Row_RunwayAfter")
	_paint_projection_profile()
	mentor_advisory_label.text = _mentor_advisory_text()


# ---- Selection aggregates + dimension profile (Product Lifecycle Part 1) ----

func _selected_total_complexity() -> int:
	var t: int = 0
	for fid in _selected_features:
		t += int(ProductCatalog.get_feature_by_id(fid).get("complexity", 0))
	return t


func _selected_total_stakes() -> int:
	var t: int = 0
	for fid in _selected_features:
		t += int(ProductCatalog.get_feature_by_id(fid).get("stakes", 0))
	return t


func _selected_dimension_shares() -> Dictionary:
	var acc := {"innovation": 0.0, "stability": 0.0, "usability": 0.0}
	for fid in _selected_features:
		var dc: Dictionary = ProductCatalog.get_feature_by_id(fid).get("dimension_contribution", {})
		for k in acc.keys():
			acc[k] += float(dc.get(k, 0.0))
	var total: float = acc["innovation"] + acc["stability"] + acc["usability"]
	if total <= 0.0:
		return {"innovation": 1.0 / 3.0, "stability": 1.0 / 3.0, "usability": 1.0 / 3.0}
	return {"innovation": acc["innovation"] / total, "stability": acc["stability"] / total, "usability": acc["usability"] / total}


func _axis_display_labels() -> Dictionary:
	var out := {"innovation": "İnovasyon", "stability": "Kararlılık", "usability": "Kullanılabilirlik"}
	for a in ProductCatalog.get_quality_axes(_selected_sub_product_type):
		out[String(a.get("axis", ""))] = String(a.get("display_label", a.get("axis", "")))
	return out


func _ensure_projection_profile() -> VBoxContainer:
	# Boyut profili — mockup'taki yüzde barları (track + amber fill + % etiketi).
	# Bir kez kurulur (eskisi per-paint queue_free/rebuild yapıyordu — repaint hijyeni);
	# kendi başlığı yok: kartın authored HeaderLabel'ı "BU ÜRÜN NEYİ GÜÇLENDİRİYOR" taşır.
	if _projection_profile != null and is_instance_valid(_projection_profile):
		return _projection_profile
	var vb := VBoxContainer.new()
	vb.name = "ProfileBox"
	vb.add_theme_constant_override("separation", 6)
	var right_vbox: Node = mentor_advisory_label.get_parent()
	right_vbox.add_child(vb)
	right_vbox.move_child(vb, mentor_advisory_label.get_index())  # sit just above the mentor line
	for axis in ["innovation", "stability", "usability"]:
		var row := HBoxContainer.new()
		row.name = axis
		row.add_theme_constant_override("separation", 10)
		var cap := Label.new()
		cap.name = "Cap"
		cap.custom_minimum_size = Vector2(150, 0)
		cap.add_theme_color_override("font_color", UiTokens.INK)
		cap.add_theme_font_size_override("font_size", 12)
		row.add_child(cap)
		var track := Panel.new()
		track.name = "Track"
		track.custom_minimum_size = Vector2(0, 8)
		track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		track.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var track_sb := StyleBoxFlat.new()
		track_sb.bg_color = UiTokens.CARD_BORDER
		track_sb.set_corner_radius_all(3)
		track.add_theme_stylebox_override("panel", track_sb)
		row.add_child(track)
		# Fill: track'e tam-anchor'lu; paint yalnız anchor_right = pay yazar (boyut
		# matematiği anchor sistemine kalır — her pay farkı görünür).
		var fill := Panel.new()
		fill.name = "Fill"
		var fill_sb := StyleBoxFlat.new()
		fill_sb.bg_color = UiTokens.ACCENT
		fill_sb.set_corner_radius_all(3)
		fill.add_theme_stylebox_override("panel", fill_sb)
		track.add_child(fill)
		fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var pct := Label.new()
		pct.name = "Pct"
		pct.theme_type_variation = &"SectionLabel"
		pct.add_theme_font_size_override("font_size", 11)
		pct.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
		pct.custom_minimum_size = Vector2(42, 0)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(pct)
		vb.add_child(row)
	_projection_profile = vb
	return vb


func _paint_projection_profile() -> void:
	var box := _ensure_projection_profile()
	if _selected_features.is_empty():
		box.visible = false
		return
	box.visible = true
	var shares := _selected_dimension_shares()
	var labels := _axis_display_labels()
	for axis in ["innovation", "stability", "usability"]:
		var row: HBoxContainer = box.get_node(axis)
		(row.get_node("Cap") as Label).text = String(labels.get(axis, axis))
		(row.get_node("Pct") as Label).text = "%d%%" % int(round(float(shares[axis]) * 100.0))
		var fill: Panel = row.get_node("Track/Fill")
		fill.anchor_right = clampf(float(shares[axis]), 0.0, 1.0)


func _set_projection_row(row_name: String, value: String) -> void:
	var row := projection_list.get_node_or_null(row_name)
	if row == null:
		return
	row.visible = true
	var value_label := row.get_node_or_null("ValueRight")
	if value_label is Label:
		value_label.text = value
	# Alt-sol kartın stat kutusu aynı değeri aynalar (liste gizli ama ValueRight
	# tek kaynak kalır; eşleşmeyen Row_* adları burada no-op).
	if _stat_values.has(row_name):
		(_stat_values[row_name] as Label).text = value


func _hide_projection_row(row_name: String) -> void:
	var row := projection_list.get_node_or_null(row_name)
	if row != null:
		row.visible = false
	if _stat_values.has(row_name):
		(_stat_values[row_name] as Label).text = "—"


func _mentor_advisory_text() -> String:
	if _v2_mode and _v2_strengthen_mode:
		# Pool exhausted: deepen an existing feature instead of adding a new one.
		if _selected_features.is_empty():
			return "Havuz tükendi — mevcut gücünü derinleştir. Hangi yanını?"
		return "%s derinleşecek. Diğer yanlar bir tık yavaşlar — seçim bu." % _strengthen_target_axis_label()
	if _v2_mode:
		# v2: type/name locked, up to MAX_VERSION_FEATURES; advise on the weak axis to target.
		var base_n: int = GameState.get_flag("mvp_components", []).size()
		if _selected_features.size() <= base_n:
			return "Zayıf yanını güçlendiren yeni bir feature ekle — v2 büyüme demek."
		return "Zayıf yanın %s. Onu besleyen feature ekle, rakibi orada geç." % _weakest_axis_label()
	if _selected_sub_product_type == "":
		return "Soldan başla. Ne yaptığımıza karar verelim."
	if _selected_features.size() < 2:
		return "Ne yapacağına karar verelim. En az iki özellik."
	if _selected_features.size() > 4:
		return "Dört'ten fazlasını taşıyamayız."
	# Frank comments on the chosen profile (scope discipline + risk).
	var comp: int = _selected_total_complexity()
	var stakes: int = _selected_total_stakes()
	var tech: int = GameState.get_founder_skill("tech")
	if comp >= 12 and tech <= 1:
		return "Ağır bir liste, tech'in düşük. Bu bug yağmuru olabilir."
	if stakes >= 14:
		return "Riskli parçalar seçtin. Biri bozulursa itibarın yanar."
	if _selected_product_name == "":
		return "Fena değil. Şimdi ürününe bir isim ver."
	return "Hazır. Build'i başlat — fazları üst köşeden yöneteceksin."


# ---- Commit bar ----

func _refresh_commit_bar() -> void:
	if _v2_mode and _v2_strengthen_mode:
		_refresh_commit_bar_v2_strengthen()
		return
	if _v2_mode:
		_refresh_commit_bar_v2()
		return
	var valid: bool = _selected_sub_product_type != "" \
		and _selected_features.size() >= 2 \
		and _selected_features.size() <= 4 \
		and _selected_product_name != ""
	commit_bar.disabled = not valid
	# Speak the product name on the button when ready (commit-ceremony teaser; the
	# full decision card is Blok C).
	if valid:
		commit_bar.text = "%s'i inşa etmeye başla · %d özellik · ~%d gün" % [
			_selected_product_name, _selected_features.size(), ProductSystem.DEVELOPMENT_DAYS_BASE + _selected_total_complexity()]
	else:
		commit_bar.text = "BUILD'İ BAŞLAT"
	# Helpful "what's missing" hint.
	if not valid:
		if _selected_sub_product_type == "":
			reason_label.text = "Soldan bir ürün tipi seç."
		elif _selected_features.size() < 2:
			reason_label.text = "En az 2 özellik seç."
		elif _selected_features.size() > 4:
			reason_label.text = "En fazla 4 özellik taşıyabiliriz."
		else:
			reason_label.text = "Ürününe bir isim ver."
	reason_label.visible = not valid
	# Tek satır özet (mockup; working-metin) — geçerliyken ürün kimliğini konuşur,
	# değilken ReasonLabel zaten ne eksik söylüyor.
	if _summary_line != null:
		_summary_line.visible = valid
		if valid:
			_summary_line.text = "%s — %s, %d özellik. Ne yaptığımıza karar verdik." % [
				_selected_product_name, _sub_product_type_name_tr(_selected_sub_product_type), _selected_features.size()]


func _refresh_commit_bar_v2() -> void:
	# Part 2B: v2 validity = at least one feature ADDED beyond the shipped set, union within cap.
	# Name/type are locked (inherited), so they're never the blocker.
	var base_n: int = GameState.get_flag("mvp_components", []).size()
	var added: int = max(0, _selected_features.size() - base_n)
	var valid: bool = added >= 1 and _selected_features.size() <= ProductSystem.MAX_VERSION_FEATURES
	commit_bar.disabled = not valid
	if valid:
		# Süre = YENİ işin süresi (version_dev_days — start_version_build ile tek kaynak).
		# Kapasite bölünecekse (sprint aktif + tek kişi) uzayan duvar-süresi ÖNCEDEN
		# gösterilir — görünür maliyet, açık seçim.
		var days: int = ProductSystem.version_dev_days(_v2_added_ids())
		var pf: float = ProductSystem.projected_speed_factor_with_extra_job()
		var nv: int = int(GameState.get_flag("mvp_version", 1)) + 1
		if pf < 1.0:
			commit_bar.text = "v%d'i inşa et · +%d özellik · ~%d gün → ~%d gün" % [
				nv, added, days, ProductSystem.days_at_factor(days, pf)]
		else:
			commit_bar.text = "v%d'i inşa et · +%d özellik · ~%d gün" % [nv, added, days]
	else:
		commit_bar.text = "v%d GELİŞTİR" % (int(GameState.get_flag("mvp_version", 1)) + 1)
	if not valid:
		if added < 1:
			reason_label.text = "En az bir yeni özellik ekle — v2 büyüme demek."
		else:
			reason_label.text = "En fazla %d özellik taşıyabiliriz." % ProductSystem.MAX_VERSION_FEATURES
	reason_label.visible = not valid
	if _summary_line != null:
		_summary_line.visible = valid
		if valid:
			_summary_line.text = "%s v%d — +%d yeni özellik. Büyüme hamlesi." % [
				String(GameState.get_flag("mvp_product_name", "")),
				int(GameState.get_flag("mvp_version", 1)) + 1, added]
	# Frank's last word in the commit card (v2 risk framing).
	if _commit_frank_label != null:
		_commit_frank_label.visible = valid
		if valid:
			_commit_frank_label.text = "Frank: \"Yeni feature, yeni bug. Ama büyümezsen geri kalırsın.\""


func _refresh_commit_bar_v2_strengthen() -> void:
	# Pool-deepening: the pool is exhausted, so the player picks 1..N existing features to
	# STRENGTHEN. Süre = güçlendirme pick'lerinin işi (version_dev_days — tek kaynak).
	var n: int = _selected_features.size()
	var valid: bool = n >= 1 and n <= ProductSystem.STRENGTHEN_MAX_PER_VERSION
	var next_v: int = int(GameState.get_flag("mvp_version", 1)) + 1
	commit_bar.disabled = not valid
	if valid:
		var days: int = ProductSystem.version_dev_days(_selected_features)
		var pf: float = ProductSystem.projected_speed_factor_with_extra_job()
		if pf < 1.0:
			commit_bar.text = "v%d'i inşa et · %d güçlendirme · ~%d gün → ~%d gün" % [
				next_v, n, days, ProductSystem.days_at_factor(days, pf)]
		else:
			commit_bar.text = "v%d'i inşa et · %d güçlendirme · ~%d gün" % [next_v, n, days]
	else:
		commit_bar.text = "v%d GÜÇLENDİR" % next_v
	reason_label.text = "Güçlendirmek için en az bir mevcut özelliği seç." if not valid else ""
	reason_label.visible = not valid
	if _summary_line != null:
		_summary_line.visible = valid
		if valid:
			_summary_line.text = "%s v%d — %d güçlendirme. Derinleşme hamlesi." % [
				String(GameState.get_flag("mvp_product_name", "")), next_v, n]
	if _commit_frank_label != null:
		_commit_frank_label.visible = valid
		if valid:
			_commit_frank_label.text = "Frank: \"Yeni yüzey yok, yeni bug az. Ama derinleşmek de büyümektir.\""


func _v2_added_ids() -> Array:
	# v2 add-modunda seçimin YENİ kısmı (union - shipped set) — süre gösterimleri
	# version_dev_days'e bunu verir (commit'teki start_version_build'e giden added
	# listesiyle aynı küme).
	var base: Array = GameState.get_flag("mvp_components", [])
	var out: Array = []
	for fid in _selected_features:
		if not base.has(fid):
			out.append(fid)
	return out


func _strengthen_target_axis_label() -> String:
	# Aggregate dominant axis of the currently-picked strengthen features, in tip-özel labels.
	var acc := {"innovation": 0.0, "stability": 0.0, "usability": 0.0}
	for fid in _selected_features:
		var dc: Dictionary = ProductCatalog.get_feature_by_id(String(fid)).get("dimension_contribution", {})
		for ax in acc.keys():
			acc[ax] += float(dc.get(ax, 0.0))
	var labels: Dictionary = _axis_labels_for_shipped()
	var best: String = "innovation"
	var best_v: float = -INF
	for ax in ["innovation", "stability", "usability"]:
		if acc[ax] > best_v:
			best_v = acc[ax]
			best = ax
	return String(labels.get(best, best))


func _commit_frank_line() -> String:
	var comp: int = _selected_total_complexity()
	var stakes: int = _selected_total_stakes()
	var tech: int = GameState.get_founder_skill("tech")
	if comp >= 12 and tech <= 1:
		return "Ağır bir liste, tech'in düşük. Bug'a hazır ol."
	if stakes >= 14:
		return "Riskli parçalar var. Kırılırsa acıtır. Yine de — karar senin."
	return "Fena değil. Bas, fazları üstten yönet."


func _on_commit_pressed() -> void:
	if commit_bar.disabled:
		return
	var founder = CharacterRegistry.get_founder()
	var founder_id: String = founder.id if founder != null else "char_founder"
	var ok: bool
	if _v2_mode and _v2_strengthen_mode:
		# Pool-deepening: feature set is unchanged (whole product); pass the strengthen picks.
		ok = ProductSystem.start_version_build([], founder_id, _selected_features.duplicate())
	elif _v2_mode:
		# Part 2B: pass only the ADDED features; start_version_build unions them onto the
		# shipped set and seeds axes from the live product.
		var base: Array = GameState.get_flag("mvp_components", [])
		var added: Array[String] = []
		for fid in _selected_features:
			if not base.has(fid):
				added.append(String(fid))
		ok = ProductSystem.start_version_build(added, founder_id)
	else:
		ok = ProductSystem.start_build(_selected_sub_product_type, _selected_features, founder_id, _selected_product_name)
	if ok:
		# Reset transient state — router sakin build görünümüne geçer; build akışı
		# sağ üstteki Tracker Card'ta
		_v2_mode = false
		_v2_strengthen_mode = false
		_selected_sub_product_type = ""
		_selected_features = []
		_selected_product_name = ""
		name_input.text = ""
		# Pause'daysa unpause (build tick'lesin); koşan hızı ASLA ezme.
		TimeManager.resume_if_paused()
		_refresh_view()


func _on_v2_pressed() -> void:
	# Part 2B: open the design view in v2 mode, pre-filled from the live product. The build
	# doesn't exist yet, so _refresh_view's v2-mode branch keeps us on DesignDocumentView.
	_v2_mode = true
	_selected_sub_product_type = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	# Pool exhausted → strengthen sub-mode (pick existing features to deepen); else add-mode.
	_v2_strengthen_mode = _pool_exhausted(_selected_sub_product_type)
	_selected_features = []
	if not _v2_strengthen_mode:
		for fid in GameState.get_flag("mvp_components", []):
			_selected_features.append(String(fid))   # add-mode: existing pre-checked (locked)
	# strengthen-mode: _selected_features stays EMPTY → it holds the strengthen picks.
	_selected_product_name = String(GameState.get_flag("mvp_product_name", ""))
	name_input.text = _selected_product_name
	_refresh_view()


func _pool_exhausted(sub_id: String) -> bool:
	# Every pool feature already in the product → nothing new to add (strengthen instead).
	var mvp: Array = GameState.get_flag("mvp_components", [])
	for f in ProductCatalog.get_feature_pool(sub_id):
		if not mvp.has(String(f.get("id", ""))):
			return false
	return true


func _on_v2_cancel_pressed() -> void:
	# Escape hatch: drop v2 planning, return to the live product management center.
	_v2_mode = false
	_v2_strengthen_mode = false
	_selected_sub_product_type = ""
	_selected_features = []
	_selected_product_name = ""
	_refresh_view()


# =========================================================================
#  PostShipView (preserved from Spec #1)
# =========================================================================

func _paint_post_ship() -> void:
	# Yön A control panel (redesign): top strip (title + health) → two columns (status left,
	# actions right) → bottom strip (rival + Frank). Same data, new layout.
	_ensure_post_ship_scaffold()
	var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
	var quality: int = int(round(QualityModel.shipped_normalized()))
	var funnel_card: Node = _left_funnel_body.get_parent()   # the make_card wrapper
	# Market branch — B2C: funnel (left) + pricing action (right). B2B: status text + sales action.
	if market == "b2c":
		post_ship_status_body.visible = false
		_b2b_info.visible = false
		funnel_card.visible = true
		var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
		_paint_status_funnel(int(GameState.get_flag("b2c_audience", 0)), CustomerRegistry.get_total_users(), GameState.mrr, is_open)
		post_ship_sales_button.visible = false
	else:
		if _status_funnel != null:
			_status_funnel.visible = false
		funnel_card.visible = false
		_b2b_info.visible = true
		post_ship_status_body.visible = true
		if _pricing_panel != null:
			_pricing_panel.visible = false
		var custn: int = CustomerRegistry.get_active().size()
		if custn == 0:
			post_ship_status_body.text = "İlk pitch'in Sales sekmesinde seni bekliyor." if ProspectRegistry.has_any() \
				else "Henüz müşteri yok — Frank seni biriyle tanıştıracak."
		else:
			post_ship_status_body.text = "%d müşteri · MRR $%d." % [custn, GameState.mrr]
		post_ship_sales_button.visible = true

	# LEFT column — dimensions (bars + version delta) + status chips.
	_paint_dimensions()
	_paint_status_chips()
	# RIGHT column — action rows (pricing renders inside the price detail slot).
	_paint_action_card()
	# TOP strip — title + version + big health badge. BOTTOM strip — rival + Frank.
	_paint_top_strip()
	_paint_bottom_strip(quality)

	# TRACTION north-star — reparented into LeftCol (uncut); refs unchanged.
	post_ship_traction_bar.value = SalesSystem.traction_progress()
	post_ship_traction_label.text = "MRR $%d / $%d" % [GameState.mrr, SalesSystem.TRACTION_MRR_TARGET]
	# Chip = gate-1 readiness. Gate state comes from PhaseGateSystem's latch
	# (subgenre-agnostic), not the old ready_for_traction flag (B2C-only bug).
	# Already in phase ≥ 2 → gate passed → chip stays "ready" (ratchet, §2.3).
	var traction_ready: bool = GameState.phase >= 2 \
		or (GameState.phase_gate_ready and GameState.pending_next_phase == 2)
	_paint_traction_chip(traction_ready)


func _ensure_post_ship_scaffold() -> void:
	# Build the two-column scaffold ONCE and reparent the authored PostShip nodes into it.
	# @onready refs are node instances (NodePaths resolved at tree-entry) → reparenting keeps
	# them valid. Same trick _build_commit_card already relies on. Never call this per-paint.
	if _scaffold_built:
		return
	_scaffold_built = true
	# TOP STRIP — title group (title + version row) | health slot ------------------------
	_top_strip = HBoxContainer.new()
	_top_strip.add_theme_constant_override("separation", 12)
	var title_group := VBoxContainer.new()
	title_group.add_theme_constant_override("separation", 2)
	title_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	post_ship_title.get_parent().remove_child(post_ship_title)
	post_ship_title.theme_type_variation = &"TitleSerif"       # big serif (token reuse)
	title_group.add_child(post_ship_title)
	_version_row = HBoxContainer.new()
	_version_row.add_theme_constant_override("separation", 5)
	title_group.add_child(_version_row)
	_top_strip.add_child(title_group)
	_health_slot = HBoxContainer.new()
	_health_slot.add_theme_constant_override("separation", 6)
	_health_slot.size_flags_horizontal = Control.SIZE_SHRINK_END
	_health_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_strip.add_child(_health_slot)
	post_ship_view.add_child(_top_strip)
	post_ship_view.add_child(HSeparator.new())
	# MAIN ROW — two columns -------------------------------------------------------------
	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 16)
	_left_col = VBoxContainer.new()
	_left_col.add_theme_constant_override("separation", 10)
	_left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_right_col = VBoxContainer.new()
	_right_col.add_theme_constant_override("separation", 10)
	_right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_row.add_child(_left_col)
	main_row.add_child(_right_col)
	post_ship_view.add_child(main_row)
	# LEFT scaffolding: header, dims, chips, funnel card, reparented traction ------------
	_left_col.add_child(_two_ended_header("Ürün Durumu", "Nasıl Gidiyor"))
	_dim_list = VBoxContainer.new()
	_dim_list.add_theme_constant_override("separation", 6)
	_left_col.add_child(_dim_list)
	_chips_row = HFlowContainer.new()
	_chips_row.add_theme_constant_override("h_separation", 6)
	_chips_row.add_theme_constant_override("v_separation", 4)
	_left_col.add_child(_chips_row)
	_left_funnel_body = VBoxContainer.new()
	_left_funnel_body.add_theme_constant_override("separation", 8)
	_left_col.add_child(UiFactory.make_card(_left_funnel_body))
	post_ship_traction_panel.get_parent().remove_child(post_ship_traction_panel)
	_left_col.add_child(post_ship_traction_panel)   # uncut now — grows with the column
	# RIGHT scaffolding: B2B info (reparented) + action list. "NE YAPACAKSIN? ·
	# BİR KOL SEÇ" başlığı kaldırıldı (Erdem: alan tamamen gitsin, altındakiler
	# yukarı) — fiyat paneli artık seçicisiz, doğrudan burada başlar.
	_b2b_info = VBoxContainer.new()
	_b2b_info.add_theme_constant_override("separation", 8)
	_b2b_info.visible = false
	post_ship_status_body.get_parent().remove_child(post_ship_status_body)
	_b2b_info.add_child(post_ship_status_body)
	post_ship_sales_button.get_parent().remove_child(post_ship_sales_button)
	_b2b_info.add_child(post_ship_sales_button)
	_right_col.add_child(_b2b_info)
	_action_list = VBoxContainer.new()
	_action_list.add_theme_constant_override("separation", 8)
	_right_col.add_child(_action_list)
	# BOTTOM STRIP — rival line + reparented Frank card ----------------------------------
	post_ship_view.add_child(HSeparator.new())
	_bottom_strip = VBoxContainer.new()
	_bottom_strip.add_theme_constant_override("separation", 8)
	_rival_line = Label.new()
	_rival_line.add_theme_font_size_override("font_size", 12)
	_rival_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bottom_strip.add_child(_rival_line)
	post_ship_frank_panel.get_parent().remove_child(post_ship_frank_panel)
	_bottom_strip.add_child(post_ship_frank_panel)
	post_ship_view.add_child(_bottom_strip)
	# retire the legacy authored "DURUM" card (its body/funnel now live in the columns)
	post_ship_status_panel.visible = false


func _two_ended_header(left_text: String, right_text: String) -> HBoxContainer:
	var hb := HBoxContainer.new()
	var l := UiFactory.make_section_header(left_text)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(l)
	var r := UiFactory.make_label(right_text.to_upper(), &"SectionLabel", UiTokens.INK_DIM)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hb.add_child(r)
	return hb


func _ensure_status_funnel() -> void:
	if _status_funnel != null:
		return
	_status_funnel = HBoxContainer.new()
	_status_funnel.add_theme_constant_override("separation", 14)
	_left_funnel_body.add_child(_status_funnel)   # Yön A: funnel lives in the LeftCol card


func _paint_status_funnel(audience: int, paying: int, mrr: int, is_open: bool) -> void:
	_ensure_status_funnel()
	_clear(_status_funnel)
	_status_funnel.visible = true
	_status_funnel.add_child(UiFactory.make_stat("Deneyen", str(audience)))
	if is_open:
		_status_funnel.add_child(_funnel_arrow())
		_status_funnel.add_child(UiFactory.make_stat("Ödeyen", str(paying)))
		_status_funnel.add_child(_funnel_arrow())
		_status_funnel.add_child(UiFactory.make_stat("MRR", _fmt_money(mrr)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_funnel.add_child(spacer)
	var band: String = SalesSystem.growth_band()
	var kind: StringName = &"neutral"
	if band == "hızlı büyüyor" or band == "büyüyor":
		kind = &"positive"
	elif band == "eriyor":
		kind = &"negative"
	var chip: Control = UiFactory.make_badge(band, kind)
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_status_funnel.add_child(chip)


func _funnel_arrow() -> Label:
	var a: Label = UiFactory.make_label("→", &"MetricValueInk", UiTokens.INK_DIM)
	a.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return a


func _paint_traction_chip(ready: bool) -> void:
	if _traction_chip != null and is_instance_valid(_traction_chip):
		_traction_chip.get_parent().remove_child(_traction_chip)
		_traction_chip.queue_free()
		_traction_chip = null
	if ready:
		_traction_chip = UiFactory.make_badge("Hazır — Frank'le konuş", &"positive")
		post_ship_traction_label.get_parent().add_child(_traction_chip)


func _on_post_ship_sales_pressed() -> void:
	EventBus.tab_changed.emit("sales")


# =========================================================================
#  B1 status card + B2 action card + B4 wear-aware Frank (Product Lifecycle 2A)
# =========================================================================

const HEALTH_STAB_MARGIN := 10.0   # effective stability this far below raw → yıpranıyor
const HEALTH_BUG_WARN := 8         # or this many live bugs → yıpranıyor


func _sprinting() -> bool:
	# Sprint artık flag-bazlı (build slotu kullanmıyor) — v3 gelişirken de sürebilir.
	return GameState.get_flag("mvp_bug_sprint_active", false)


func _live_bugs() -> int:
	return int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0)))


func _post_ship_composite() -> float:
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	return QualityModel.composite_quality(QualityModel.economy_dims_from_flags(), ProductCatalog.get_quality_axes(sub))


func _product_health() -> String:
	if _sprinting():
		return "toparlanıyor"
	var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
	if market == "b2c" and SalesSystem._audience_delta_per_hour() < 0.0:
		return "eriyor"
	var raw_stab: float = float(GameState.get_flag("mvp_stability", 0.0))
	var eff: float = QualityModel.effective_stability(raw_stab, _live_bugs())
	if (raw_stab - eff) >= HEALTH_STAB_MARGIN or _live_bugs() >= HEALTH_BUG_WARN:
		return "yıpranıyor"
	return "sağlıklı"


func _health_kind(h: String) -> StringName:
	match h:
		"eriyor": return &"negative"
		"yıpranıyor": return &"attention"
		"toparlanıyor": return &"accent"
		_: return &"positive"


func _rival_passed_name() -> String:
	# Closest same-type STARTUP rival above the player — but only a meaningful "you
	# fell behind" signal when the player is in the LOWER HALF of the startup league
	# (not merely because one stronger startup exists; a 2/6 product isn't "passed").
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var player: float = _post_ship_composite()
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, player)
	if int(rank["rank"]) <= int(ceil(float(int(rank["total"])) / 2.0)):
		return ""
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var passer: String = ""
	var best: float = INF
	for r in RivalRegistry.get_by_type(sub):
		if r.tier == "startup":
			var c: float = r.composite(axes)
			if c > player and c < best:
				best = c
				passer = r.product_name
	return passer


func _axis_labels_for_shipped() -> Dictionary:
	var out := {"innovation": "İnovasyon", "stability": "Kararlılık", "usability": "Kullanılabilirlik"}
	for a in ProductCatalog.get_quality_axes(String(GameState.get_flag("mvp_sub_product_type_id", ""))):
		out[String(a.get("axis", ""))] = String(a.get("display_label", a.get("axis", "")))
	return out


func _paint_dimensions() -> void:
	# Three dimension rows: label | bar (fill=score, state color) | big number | version delta.
	# Innovation/Usability: single version-over-version delta. Stability: DUAL info — big number
	# = effective (bug-eroded), green version delta (raw gain = "the build worked"), red bug badge.
	_clear(_dim_list)
	var L: Dictionary = _axis_labels_for_shipped()
	var inn: int = int(round(float(GameState.get_flag("mvp_innovation", 0.0))))
	var usa: int = int(round(float(GameState.get_flag("mvp_usability", 0.0))))
	var raw: int = int(round(float(GameState.get_flag("mvp_stability", 0.0))))
	var eff: int = int(round(QualityModel.effective_stability(float(GameState.get_flag("mvp_stability", 0.0)), _live_bugs())))
	_dim_list.add_child(_dim_row(L["innovation"], inn, inn, _ver_delta("mvp_innovation"), null))
	var bug_drop: int = raw - eff
	var bug_badge: Control = null
	var stab_color = null
	if bug_drop > 0:
		bug_badge = UiFactory.make_badge("🐛 −%d" % bug_drop, &"negative")
		stab_color = UiTokens.NEGATIVE
	_dim_list.add_child(_dim_row(L["stability"], eff, eff, _ver_delta("mvp_stability"), bug_badge, stab_color))
	_dim_list.add_child(_dim_row(L["usability"], usa, usa, _ver_delta("mvp_usability"), null))


func _dim_row(label: String, bar_score: int, big: int, ver_delta: int, extra_badge: Control, num_color = null) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var cap: Label = UiFactory.make_label(label, &"NameSerif")
	cap.custom_minimum_size = Vector2(120, 0)
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(cap)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"          # set FIRST, then override fill color
	bar.custom_minimum_size = Vector2(0, 8)
	bar.show_percentage = false
	bar.max_value = 100.0
	bar.value = float(clampi(bar_score, 0, 100))
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_override_bar_fill(bar, _score_color(bar_score))
	row.add_child(bar)
	var val: Label = UiFactory.make_label("%d" % big, &"MetricValueInk", num_color)
	val.add_theme_font_size_override("font_size", 24)    # the visual centerpiece (mockup big number)
	val.custom_minimum_size = Vector2(40, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	var dtxt: String = ("+%d" % ver_delta) if ver_delta >= 0 else ("%d" % ver_delta)
	var db: Control = UiFactory.make_delta_badge(dtxt, ver_delta)
	db.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(db)
	if extra_badge != null:
		extra_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(extra_badge)
	return row


func _ver_delta(flag: String) -> int:
	# Version-over-version gain (display-only mvp_*_prev snapshot written at launch()).
	return int(round(float(GameState.get_flag(flag, 0.0)))) - int(round(float(GameState.get_flag(flag + "_prev", 0.0))))


func _score_color(s: int) -> Color:
	if s >= 67:
		return UiTokens.HEALTH_GREEN
	if s >= 34:
		return UiTokens.HEALTH_AMBER
	return UiTokens.NEGATIVE


func _override_bar_fill(bar: ProgressBar, c: Color) -> void:
	# BuildProgress's amber fill → per-bar state color. Must run AFTER theme_type_variation is set.
	var fill: StyleBox = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var f: StyleBoxFlat = fill.duplicate()
		f.bg_color = c
		bar.add_theme_stylebox_override("fill", f)


func _paint_status_chips() -> void:
	_clear(_chips_row)
	var bugs: int = _live_bugs()
	var dir: String = "azalıyor" if _sprinting() else "artıyor"
	var bug_kind: StringName = &"positive"
	if bugs > 2:
		bug_kind = &"negative"
	elif bugs > 0:
		bug_kind = &"attention"
	_chips_row.add_child(UiFactory.make_badge("◆ %d bug · %s" % [bugs, dir], bug_kind))
	var ver: int = int(GameState.get_flag("mvp_version", 1))
	var age_txt: String = "🕐 v%d · canlı" % ver
	if GameState.has_flag("mvp_launch_day"):
		var days: int = max(0, GameState.day - int(GameState.get_flag("mvp_launch_day", GameState.day)))
		age_txt = "🕐 v%d · %d gün canlı" % [ver, days]
	_chips_row.add_child(UiFactory.make_badge(age_txt, &"neutral"))


func _paint_top_strip() -> void:
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname == "":
		pname = _sub_product_type_name(String(GameState.get_flag("mvp_sub_product_type_id", "")))
	post_ship_title.text = pname
	var ver: int = int(GameState.get_flag("mvp_version", 1))
	var h: String = _product_health()
	var hc: Color = UiTokens.health_color(_health_state(h))
	_clear(_version_row)
	_version_row.add_child(UiFactory.make_label("V%d ·" % ver, &"RowMeta"))
	var dot: Control = UiFactory.make_dot(hc, 7)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_version_row.add_child(dot)
	_version_row.add_child(UiFactory.make_label("CANLI", &"RowMeta"))
	_clear(_health_slot)
	var bigdot: Control = UiFactory.make_dot(hc, 9)
	bigdot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_health_slot.add_child(bigdot)
	_health_slot.add_child(UiFactory.make_badge(h, _health_kind(h)))


func _health_state(h: String) -> StringName:
	# Map the Turkish health word → health_color() state (healthy/warn/bad).
	match h:
		"eriyor": return &"bad"
		"yıpranıyor": return &"warn"
		_: return &"healthy"   # sağlıklı / toparlanıyor


func _paint_bottom_strip(quality: int) -> void:
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, _post_ship_composite())
	var passer: String = _rival_passed_name()
	_rival_line.text = String(rank["text"]) + ("  —  %s seni geçti." % passer if passer != "" else "")
	_rival_line.add_theme_color_override("font_color", UiTokens.NEGATIVE if passer != "" else UiTokens.INK_MUTED)
	post_ship_frank_line.text = _post_ship_frank_text(quality)


func _ensure_action_card() -> void:
	# "Fiyatlandır" seçici satırı KALDIRILDI (Erdem: gereksiz — fiyat paneli
	# zaten burada). Fiyat paneli B2C'de HEP açık, doğrudan kolonun başında;
	# altında sprint + v2 aksiyon satırları.
	if _action_built:
		return
	_action_built = true
	_sprint_banner = VBoxContainer.new()
	_sprint_banner.add_theme_constant_override("separation", 4)
	_sprint_banner.visible = false
	_action_list.add_child(_sprint_banner)
	_price_detail_slot = VBoxContainer.new()
	_action_list.add_child(_price_detail_slot)   # the pricing panel mounts here
	_action_rows["sprint"] = _make_action_row("sprint", "🐛", "Bug Sprinti")
	_action_rows["v2"] = _make_action_row("v2", "▲", "Geliştir")


func _make_action_row(id: String, icon: String, title: String) -> Dictionary:
	var root: PanelContainer = UiFactory.make_card(null, true)   # CardPanelTight
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	var ic: Label = UiFactory.make_label(icon, &"NameSerif")
	ic.custom_minimum_size = Vector2(22, 0)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(ic)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var t: Label = UiFactory.make_label(title, &"NameSerif")
	var d: Label = UiFactory.make_label("", &"RowMeta")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(t)
	vb.add_child(d)
	hb.add_child(vb)
	var s: Label = UiFactory.make_label("", &"RowMeta")
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(s)
	root.add_child(hb)
	_set_mouse_ignore(hb)                       # clicks bubble to the card's gui_input
	root.gui_input.connect(_on_action_row_input.bind(id))
	_action_list.add_child(root)
	return {"root": root, "title": t, "desc": d, "status": s}


func _set_mouse_ignore(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_set_mouse_ignore(c)


func _apply_action_selection(sel_id: String) -> void:
	# Selected row → pale-amber card with a 2px amber border (mockup). Others → base card.
	for id in _action_rows.keys():
		(_action_rows[id]["root"] as PanelContainer).remove_theme_stylebox_override("panel")
	if _action_rows.has(sel_id):
		var root: PanelContainer = _action_rows[sel_id]["root"]
		var sel: StyleBoxFlat = (root.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
		sel.bg_color = UiTokens.AMBER_BG
		sel.border_color = UiTokens.ACCENT
		sel.set_border_width_all(2)
		root.add_theme_stylebox_override("panel", sel)


func _building_active() -> bool:
	# Gerçek bir build sürüyor mu (sprint artık slot kullanmıyor — yalnız v2 satırını
	# kilitler; sprint kanon gereği build sürerken de BAŞLATILABİLİR).
	return ProductSystem.get_active_build() != null


func _paint_action_card() -> void:
	_ensure_action_card()
	var is_b2c: bool = (String(GameState.get_flag("mvp_market_type", "b2c")) == "b2c")
	# Fiyat paneli B2C'de HEP açık (seçici satır kaldırıldı); B2B _b2b_info kullanır.
	_price_detail_slot.visible = is_b2c
	if is_b2c:
		_paint_pricing()
		if _pricing_panel != null:
			_pricing_panel.visible = true
	# Sprint mode banner (pricing stays live below it) — sprint durumu artık
	# mvp_sprint_* flag'lerinde (carrier yok; v3 gelişirken de akabilir).
	if _sprinting():
		var total: float = maxf(1.0, float(GameState.get_flag("mvp_sprint_days_total", 1)))
		var elapsed: float = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0))
		# Kalan süre duvar-günü cinsinden: kapasite bölünmüşse (build'le paralel,
		# tek kişi) sprint yarı hızda akar → kalan iş-günü 2× takvim günü sürer.
		var cf: float = ProductSystem.capacity_speed_factor()
		var remaining: int = ProductSystem.days_at_factor(int(ceil(maxf(0.0, total - elapsed))), cf)
		_sprint_banner.visible = true
		_clear(_sprint_banner)
		var bl := Label.new()
		bl.text = "Bug Sprinti · %d gün kaldı · 🐛 %d" % [remaining, _live_bugs()]
		if cf < 1.0:
			bl.text += " · yarı hız"
		bl.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
		bl.add_theme_font_size_override("font_size", 12)
		_sprint_banner.add_child(bl)
		var bar := ProgressBar.new()
		bar.theme_type_variation = &"BuildProgress"
		bar.custom_minimum_size = Vector2(0, 6)
		bar.show_percentage = false
		bar.max_value = total
		bar.value = elapsed
		_sprint_banner.add_child(bar)
	else:
		_sprint_banner.visible = false
	# Sprint row copy + lock state.
	var bugs: int = _live_bugs()
	var sr: Dictionary = _action_rows["sprint"]
	# Kapasite ön-gösterimi: diğer iş aktif VE kapasite < talep+1 olacaksa pf < 1.0 —
	# uzayan duvar-süresi tıklamadan ÖNCE görünür (görünür maliyet, açık seçim).
	var pf: float = ProductSystem.projected_speed_factor_with_extra_job()
	if _sprinting():
		sr["title"].text = "Sprint sürüyor…"
		sr["desc"].text = "Bug'lar temizleniyor. Büyüme akmaya devam eder."
		sr["status"].text = "🐛 %d" % bugs
	elif bugs <= 0:
		sr["title"].text = "Temiz — sprint gerekmez"
		sr["desc"].text = "0 aktif bug. Şu an müdahale gerekmiyor."
		sr["status"].text = "0 BUG"
	else:
		sr["title"].text = "Bug Sprinti başlat"
		sr["desc"].text = "Bug'ları temizle — kararlılık geri gelir (build'le paralelse ikisi yavaşlar)."
		var sdays: int = ProductSystem.sprint_duration_for(bugs)
		if pf < 1.0:
			sr["status"].text = "%d BUG · ~%d GÜN → ~%d GÜN" % [bugs, sdays, ProductSystem.days_at_factor(sdays, pf)]
		else:
			sr["status"].text = "%d BUG · ~%d GÜN" % [bugs, sdays]
	# v2/v4 growth row.
	var vr: Dictionary = _action_rows["v2"]
	var nextv: int = int(GameState.get_flag("mvp_version", 1)) + 1
	vr["title"].text = "v%d Geliştir" % nextv
	vr["desc"].text = "Yeni feature / güçlendirme — daha yüksek rekabet. (Yeni feature = yeni bug.)"
	# Henüz seçim yok — v2 süre modelinin tabanı gösterilir; gerçek süre kurma
	# ekranında seçime göre netleşir (version_dev_days, tek kaynak).
	var vdays: int = ProductSystem.version_dev_days([])
	if pf < 1.0:
		vr["status"].text = "~%d+ GÜN → ~%d+ GÜN" % [vdays, ProductSystem.days_at_factor(vdays, pf)]
	else:
		vr["status"].text = "~%d+ GÜN" % vdays
	# Kilitler (kanon: canlı yaşam döngüsü build'den bağımsız; kilit yok — kapasite var):
	# - sprint satırı: sprinting/temiz'ken kilitli — build SÜRERKEN AÇIK.
	# - v2 satırı: yalnız build sürerken kilitli (ikinci build yok). Sprint sürerken
	#   AÇIK — bedel kilit değil, kapasite bölünmesi (capacity_speed_factor).
	var building: bool = _building_active()
	if building:
		vr["status"].text = "BUILD SÜRÜYOR"
	sr["root"].modulate = Color(1, 1, 1, 0.55 if (_sprinting() or bugs <= 0) else 1.0)
	vr["root"].modulate = Color(1, 1, 1, 0.55 if building else 1.0)
	# Sprint/v2 tetikleyici satırlar — kalıcı seçim yok, vurgu nötr kalır.
	_apply_action_selection("")


func _on_action_row_input(ev: InputEvent, id: String) -> void:
	if not (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT):
		return
	match id:
		"sprint":
			if _sprinting() or _live_bugs() <= 0:
				return   # locked (build sürerken AÇIK — kanon)
			_on_bug_sprint_pressed()
		"v2":
			if _building_active():
				return   # ikinci build yok; sprint sürerken AÇIK (bedel = kapasite bölünmesi)
			_on_v2_pressed()


func _on_bug_sprint_pressed() -> void:
	if ProductSystem.start_bug_sprint():
		TimeManager.resume_if_paused()   # pause'daysa unpause; koşan hızı ezme
		_refresh_view()


func _post_ship_frank_text(_quality: int) -> String:
	if GameState.get_flag("bug_sprint_just_done", false):
		GameState.set_flag("bug_sprint_just_done", false)   # one-shot
		return "\"Temizlendi. Şimdi geri büyümeye bak.\""
	if _sprinting():
		return "\"Doğru iş. Bitir şunu, sonra geri büyürüz.\""
	if GameState.get_flag("needs_engineer", false):
		return "\"Sürekli bug'la boğuşuyorsun — birini alma vaktin geldi.\""
	var passer: String = _rival_passed_name()
	var health: String = _product_health()
	if health == "eriyor":
		# Bleeding: if BUGS are the lever (a sprint fixes it), point there; otherwise
		# it's competition — name the rival.
		if _live_bugs() >= HEALTH_BUG_WARN:
			return "\"Kan kaybediyorsun. Bug sprinti vakti — yoksa bu ürün ölür.\""
		if passer != "":
			return "\"%s seni geçti. Ya bir şey yap ya kaybol.\"" % passer
		return "\"Kan kaybediyorsun. Bug sprinti vakti — yoksa bu ürün ölür.\""
	var weak: String = _weakest_axis_label()
	if passer != "":
		# Not bleeding, but a rival passed → point at the growth arm + the weak axis to fix.
		return "\"Zayıf yanın %s — v2'de onu güçlendir, %s'i yakala.\"" % [weak, passer]
	if health == "yıpranıyor":
		return "\"Bug'lar birikiyor. Kullanıcılar henüz gitmedi ama fark ediyorlar.\""
	# Healthy: nudge toward v2 growth (Part 2B), naming the weak axis + the §10 risk.
	return "\"İyi gidiyor. Ama büyümezsen geri kalırsın. v2 riskli — yeni feature, yeni bug. Yine de zayıf yanın %s, orası büyümeyi hak ediyor.\"" % weak


func _weakest_axis_label() -> String:
	# Lowest-scoring axis (economy dims → stability already bug-eroded), in tip-özel labels.
	var dims: Dictionary = QualityModel.economy_dims_from_flags()
	var labels: Dictionary = _axis_labels_for_shipped()
	var worst: String = "innovation"
	var worst_v: float = INF
	for ax in ["innovation", "stability", "usability"]:
		var s: float = QualityModel.axis_score(dims, ax)
		if s < worst_v:
			worst_v = s
			worst = ax
	return String(labels.get(worst, worst))


func _on_sales_state_changed(_arg = null) -> void:
	# Repaint PostShip on revenue / customer / prospect changes (routes safely
	# even outside the post-ship state).
	_refresh_view()


# =========================================================================
#  Dynamic pricing lever (B2C) — value algorithm + free-price ruler + churn
# =========================================================================

func _paint_pricing() -> void:
	_ensure_pricing_panel()
	_pricing_panel.visible = true
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var floor_p: int = int(v["floor"])
	var can_read: bool = GameState.get_founder_skill("sales") >= SkillCheck.SALES_READ_THRESHOLD
	var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)

	# Ruler range: lower bound near floor, top open (optimal × 3).
	var smax: int = maxi(optimal * 3, floor_p + 4)
	_price_slider.min_value = 1
	_price_slider.max_value = smax
	if not _pricing_initialized:
		_price_slider.value = float(int(GameState.get_flag("b2c_price", optimal))) if is_open else float(optimal)
		_pricing_initialized = true

	_rebuild_header_chip(is_open)

	# Value anchor + rationale chips (Markets-gated A.2/A.3).
	_pricing_value_label.text = "~$%d" % optimal if can_read else "belirsiz"
	_rebuild_rationale(v["lines"], can_read)

	# Colored value spectrum (band = slider track) + floor/optimal notches + marks.
	_rebuild_bands(optimal, floor_p, smax, can_read)
	if can_read:
		_pricing_marks.text = "Alt sınır $%d   ·   Optimal $%d   ·   üst açık" % [floor_p, optimal]
	else:
		_pricing_marks.text = "Alt sınır $%d   ·   Optimal belirsiz (Markets düşük)" % floor_p

	_update_projection(int(_price_slider.value))


func _ensure_pricing_panel() -> void:
	if _pricing_panel != null:
		return
	var panel := PanelContainer.new()
	panel.name = "PricingPanel"
	panel.theme_type_variation = &"CardPanel"

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)

	# 1. Header: "FİYATLANDIRMA" + right status chip (rebuilt in paint).
	_pricing_header_row = HBoxContainer.new()
	var hdr := UiFactory.make_section_header("Fiyatlandırma")
	hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pricing_header_row.add_child(hdr)
	vb.add_child(_pricing_header_row)

	# 2. Value anchor.
	vb.add_child(UiFactory.make_label("ÜRÜN DEĞERİ", &"MetricCaptionInk"))
	var anchor_row := HBoxContainer.new()
	anchor_row.add_theme_constant_override("separation", 6)
	_pricing_value_label = UiFactory.make_label("", &"MetricValueInk")
	anchor_row.add_child(_pricing_value_label)
	var per := UiFactory.make_label("/ kullanıcı", &"RowMeta")
	per.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	anchor_row.add_child(per)
	vb.add_child(anchor_row)

	# 3. Rationale chips (value drivers).
	_pricing_rationale = HFlowContainer.new()
	_pricing_rationale.add_theme_constant_override("h_separation", 5)
	_pricing_rationale.add_theme_constant_override("v_separation", 4)
	vb.add_child(_pricing_rationale)

	# 4. Spectrum control: colored band + notches with the slider overlaid so the
	# amber grabber rides directly on the value band (PriceSlider = transparent track).
	_pricing_spectrum = Control.new()
	_pricing_spectrum.custom_minimum_size = Vector2(0, 30)
	_pricing_spectrum.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(_pricing_spectrum)

	_pricing_band = HBoxContainer.new()
	_pricing_band.add_theme_constant_override("separation", 0)
	_pricing_band.anchor_right = 1.0
	_pricing_band.anchor_top = 0.5
	_pricing_band.anchor_bottom = 0.5
	_pricing_band.offset_top = -4.0
	_pricing_band.offset_bottom = 4.0
	_pricing_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pricing_spectrum.add_child(_pricing_band)

	_price_slider = HSlider.new()
	_price_slider.theme_type_variation = &"PriceSlider"
	_price_slider.min_value = 1
	_price_slider.max_value = 100
	_price_slider.step = 1
	_price_slider.anchor_right = 1.0
	_price_slider.anchor_bottom = 1.0
	_price_slider.value_changed.connect(_on_price_slider_changed)
	_pricing_spectrum.add_child(_price_slider)

	# 5. Marks.
	_pricing_marks = UiFactory.make_label("", &"MetricCaptionInk")
	vb.add_child(_pricing_marks)

	# 6. Projection block (live before→after), rebuilt on every slider move.
	var proj_card := PanelContainer.new()
	proj_card.theme_type_variation = &"CardPanelTight"
	_pricing_projection = VBoxContainer.new()
	_pricing_projection.add_theme_constant_override("separation", 8)
	proj_card.add_child(_pricing_projection)
	vb.add_child(proj_card)

	# 7. Apply CTA (amber primary).
	_pricing_apply = Button.new()
	_pricing_apply.theme_type_variation = &"CommitButton"
	_pricing_apply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pricing_apply.pressed.connect(_on_pricing_apply_pressed)
	vb.add_child(_pricing_apply)

	# Yön A: the pricing panel is the expanded detail of the "Fiyatlandır" action row.
	_price_detail_slot.add_child(panel)
	_pricing_panel = panel


func _rebuild_header_chip(is_open: bool) -> void:
	if _pricing_status_chip != null and is_instance_valid(_pricing_status_chip):
		_pricing_header_row.remove_child(_pricing_status_chip)
		_pricing_status_chip.queue_free()
	if is_open:
		_pricing_status_chip = UiFactory.make_badge("Canlı · $%d" % int(GameState.get_flag("b2c_price", 0)), &"positive")
	else:
		_pricing_status_chip = UiFactory.make_badge("Taslak", &"neutral")
	_pricing_status_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pricing_header_row.add_child(_pricing_status_chip)


func _rebuild_rationale(lines: Array, can_read: bool) -> void:
	_clear(_pricing_rationale)
	if not can_read:
		_pricing_rationale.add_child(UiFactory.make_badge("içgüdüsel fiyat", &"neutral"))
		return
	for line in lines:
		var s: int = int(line.get("sign", 0))
		var kind: StringName = &"neutral"
		if s > 0:
			kind = &"positive"
		elif s < 0:
			kind = &"negative"
		# Short chip: the driver, not the full explanation ("Kalite 100 → …" → "Kalite 100").
		var short: String = String(line.get("text", "")).split("→")[0].strip_edges()
		_pricing_rationale.add_child(UiFactory.make_badge(short, kind))


func _rebuild_bands(optimal: int, floor_p: int, smax: int, can_read: bool) -> void:
	_clear(_pricing_band)
	for ch in _pricing_spectrum.get_children():
		if String(ch.name).begins_with("Notch"):
			_pricing_spectrum.remove_child(ch)
			ch.queue_free()
	# Zones by ratio across the full 1..smax range: green (volume) → amber (optimal) → red (premium).
	var a: float = maxf(1.0, optimal * 0.85)
	var b: float = maxf(a + 1.0, optimal * 1.15)
	_add_band(UiTokens.POSITIVE, a - 1.0)
	_add_band(UiTokens.HEALTH_AMBER, b - a)
	_add_band(UiTokens.NEGATIVE, maxf(1.0, float(smax) - b))
	if can_read:
		var span: float = maxf(1.0, float(smax - 1))
		_add_notch(clampf(float(floor_p - 1) / span, 0.0, 1.0))
		_add_notch(clampf(float(optimal - 1) / span, 0.0, 1.0))


func _add_band(color: Color, ratio: float) -> void:
	var r := ColorRect.new()
	r.color = color
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.size_flags_stretch_ratio = maxf(0.01, ratio)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pricing_band.add_child(r)


func _add_notch(ratio: float) -> void:
	var n := ColorRect.new()
	n.name = "Notch"
	n.color = UiTokens.INK
	n.anchor_left = ratio
	n.anchor_right = ratio
	n.offset_left = -1.0
	n.offset_right = 1.0
	n.anchor_top = 0.5
	n.anchor_bottom = 0.5
	n.offset_top = -8.0
	n.offset_bottom = 8.0
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pricing_spectrum.add_child(n)
	_pricing_spectrum.move_child(n, 1)  # above band, below slider grabber


func _on_price_slider_changed(value: float) -> void:
	_update_projection(int(value))


func _update_projection(price: int) -> void:
	# Live, pre-commit estimate (B.3 / D.3). No mutation.
	_clear(_pricing_projection)
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var floor_p: int = int(v["floor"])
	var can_read: bool = GameState.get_founder_skill("sales") >= SkillCheck.SALES_READ_THRESHOLD
	var est: Dictionary = SalesSystem.estimate_price_change(price)
	var cur_paying: int = CustomerRegistry.get_total_users()
	var new_paying: int = int(est["new_paying"])
	var new_mrr: int = int(est["new_mrr"])
	var old_mrr: int = int(est["old_mrr"])
	var conv: int = int(round(SalesSystem.conversion_rate(price) * 100.0))
	var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)

	# Metric cells (before→after).
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.add_child(UiFactory.make_stat("Seçilen", "$%d" % price, 0, "", UiTokens.ACCENT_DEEP))
	var dpay: int = new_paying - cur_paying
	row.add_child(UiFactory.make_stat("Ödeyen", str(new_paying), dpay, _signed(dpay) if (is_open and dpay != 0) else ""))
	var dmrr: int = new_mrr - old_mrr
	row.add_child(UiFactory.make_stat("MRR", _fmt_money(new_mrr), dmrr, _signed_money(dmrr) if (is_open and dmrr != 0) else ""))
	row.add_child(UiFactory.make_stat("Dönüşüm", "%d%%" % conv))
	_pricing_projection.add_child(row)

	# Zone + raise chips.
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 5)
	chips.add_theme_constant_override("v_separation", 4)
	if not can_read:
		chips.add_child(UiFactory.make_badge("içgüdüsel fiyat", &"neutral"))
	elif price < floor_p:
		chips.add_child(UiFactory.make_badge("ucuza kaçış", &"positive"))
	elif price < optimal:
		chips.add_child(UiFactory.make_badge("volume oyunu · dönüşüm yüksek", &"positive"))
	elif price > optimal:
		chips.add_child(UiFactory.make_badge("premium · audience zorlanır", &"negative"))
	else:
		chips.add_child(UiFactory.make_badge("optimal · dengeli", &"accent"))
	if est["is_raise"]:
		chips.add_child(UiFactory.make_badge("zam · audience −%d%%" % int(round(float(est["audience_drop_pct"]) * 100.0)), &"negative"))
	_pricing_projection.add_child(chips)

	# CTA label carries the impact.
	if not is_open:
		_pricing_apply.text = "Fiyatı koy · $%d" % price
	else:
		_pricing_apply.text = "Fiyatı uygula · MRR %s → %s" % [_fmt_money(old_mrr), _fmt_money(new_mrr)]


func _on_pricing_apply_pressed() -> void:
	var price: int = int(_price_slider.value)
	SalesSystem.apply_b2c_price(price)  # the only B2C revenue mover — a played decision
	# apply emits mrr_changed → _on_sales_state_changed → _refresh_view repaints,
	# but call directly too so the panel updates even if MRR happened to be equal.
	_refresh_view()


# --- small formatting/util helpers for the pricing UI ---
func _clear(node: Node) -> void:
	for ch in node.get_children():
		node.remove_child(ch)
		ch.queue_free()


func _signed(v: int) -> String:
	if v > 0:
		return "+%d" % v
	if v < 0:
		return "−%d" % absi(v)
	return "±0"


func _signed_money(v: int) -> String:
	if v == 0:
		return ""
	return ("+%s" % _fmt_money(v)) if v > 0 else ("−%s" % _fmt_money(absi(v)))


func _fmt_money(value: int) -> String:
	if absi(value) >= 1000000:
		return "$%.1fM" % (value / 1000000.0)
	if absi(value) >= 1000:
		return "$%.0fK" % (value / 1000.0)
	return "$%d" % value


func _frank_ship_reaction(quality: int, bugs: int) -> String:
	if bugs > 8:
		return "\"Çıktı işte. Ama o bug'lar… ilk izlenim önemli, çabuk topla.\""
	if quality >= 80:
		return "\"İyi iş. Temiz çıktı. Şimdi sabır — müşteri kendiliğinden gelmez.\""
	return "\"Tamam, yayında. Zor kısım şimdi: birinin buna para vermesini sağlamak.\""


# =========================================================================
#  Helpers
# =========================================================================

func _sub_product_type_name(sub_type_id: String) -> String:
	if sub_type_id == "":
		return "—"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return String(data.get("name", sub_type_id))


func _sub_product_type_name_tr(sub_type_id: String) -> String:
	# Display-only TR başlık (name_human). _sub_product_type_name (EN kısa etiket)
	# BuildProgress başlığını + projeksiyon dump'ını da beslediği için dokunulmaz.
	if sub_type_id == "":
		return "—"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return String(data.get("name_human", data.get("name", sub_type_id)))


func _display_date_for(day_number: int) -> String:
	# Mirrors GameState.get_display_date() but for an arbitrary day number.
	# Day 1 = Wed Jan 1 2025 anchor.
	if day_number <= 0:
		return "—"
	var anchor_unix: int = int(Time.get_unix_time_from_datetime_dict(GameState.START_DATE))
	var current_unix: int = anchor_unix + (day_number - 1) * 86400
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(current_unix)
	return "%s, %s %d" % [GameState.DOW_ABBR[d.weekday], GameState.MONTH_ABBR[d.month - 1], d.day]


# =========================================================================
#  Signal handlers
# =========================================================================

func _on_day_advanced(_new_day: int) -> void:
	# Re-route + paint (build might have transitioned phase this tick).
	# (Feed defteri silindi — GÜNLÜK GELİŞİM feed'i Tracker Card geçişiyle kalktı.)
	_refresh_view()


func _on_build_progress_changed() -> void:
	# Fired hourly at the end of ProductSystem.hourly_tick — keeps the calm/post-ship
	# views tracking the build state without waiting for day boundaries.
	_refresh_view()
