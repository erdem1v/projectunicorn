extends Control

# ODA — merkez görünüm: kurucunun masasının POV oda sahnesi. İlke: stok kabukta · akış
# odada · derinlik sekmede — buradaki her yüzey bir KISAYOLDUR, hiçbir bilgi yalnız burada
# yaşamaz. Bu dosya yalnız okur ve EventBus'a abone olur; tek yazdığı şey navigasyon
# (tab_changed) ve Settings'teki tur bayrağı.
#
# Katmanlar (alttan üste): SceneLayer (gündüz/gece sanat çifti, crossfade) → ObjectLayer
# (AtlasTexture obje sprite'ları — gece tint'i buraya biner) → FXLayer (telefon kırmızı
# noktası) → InfoLayer (motor-çizimi bilgi yüzeyleri: monitör ekranı, pano kartları,
# kâğıtlar, çerçeve içleri, mesai çipi) → HotspotLayer (görünmez tıklama hedefleri +
# çerçeve hover halkaları). Tur PanelLayer'a ayrı monte edilir.
#
# Yerleşimin TEK kaynağı OdaLayout — burada koordinat sabiti yok. Döngülü animasyon ve
# _process yok: her şey sinyal + tek-seferlik tween.
#
# Resident: GameShell.tscn'de CenterViewport çocuğu, hiç free edilmez, sekme açılınca
# yalnız gizlenir — mentor satırı latch'i, kâğıt geliş hafızası ve gece durumu gezintide yaşar.

const OdaTourRef := preload("res://scripts/ui/oda/oda_tour.gd")
const RIM_SHADER := preload("res://scenes/desk/oda_rim_glow.gdshader")
const TEX_DAY := preload("res://assets/art/center_view/room_day_3840x2160.png")
const TEX_NIGHT := preload("res://assets/art/center_view/room_night_3840x2160.png")
const TEX_MONITOR := preload("res://assets/art/center_view/monitor_3840x2160.png")
# Monitörün build yüzü BuildHUD/tracker ile AYNI sahneyi kurar — paralel bir çubuk yok.
const BUILD_BAR_SCENE := preload("res://scenes/ui/components/BuildBar.tscn")
const TEX_KEYBOARD := preload("res://assets/art/center_view/keyboard_3840x2160.png")
const TEX_PHONE := preload("res://assets/art/center_view/phone_3840x2160.png")
const TEX_LAMP := preload("res://assets/art/center_view/lamp_3840x2160.png")
const TEX_MUG := preload("res://assets/art/center_view/mug_3840x2160.png")
# Gece ayrı render edilen tek obje lambadır: yanan ampul bazı kanallarda gündüzün ÜSTÜNE
# çıkar (gece/gündüz oranı 1.72, 1.37, 0.89) ve bir multiply (modulate) 1'i aşamaz.
# Diğer objelerin gece hâli ODA_NIGHT_TINT çarpımıyla birebir temsil edilir.
const TEX_LAMP_NIGHT := preload("res://assets/art/center_view/lamp_night_3840x2160.png")

# --- # WORKING değerleri (Erdem F5 mühürler) --------------------------------
# Dört-durum ışık makinesi: GÜNDÜZ 07-17 (nötr) · AKŞAM 18 (ılık tint) · GECE 19-05 ve
# şirket penceresi kapandıktan sonra (sahne çifti) · ŞAFAK 06 (serin tint). Geçiş yalnız
# durum değişince, tek tween — saatlik titreme yapısal olarak imkânsız.
const LIGHT_FADE_S := 1.5           # her durum geçişinin crossfade süresi
const HOVER_FADE_S := 0.15          # hover glow aç/kapa
const BUZZ_S := 0.30                # telefon titreşimi süresi
const BUZZ_PX := 3.0                # titreşim genliği
const PAPER_ARRIVE_S := 0.35        # kâğıt geliş animasyonu
const PAPER_CAP := 3                # masadaki azami kâğıt (fazlası +N çipi)
const SCREEN_GLOW_NIGHT_A := 0.35   # gece ekran parlaması (additive) alfası

# Katman / düğüm referansları (kod-kurulu)
var _day_art: TextureRect
var _night_art: TextureRect
var _scene_layer: Control
var _object_layer: Control
var _sprites: Dictionary = {}          # id -> TextureRect
var _sprite_mats: Dictionary = {}      # id -> ShaderMaterial (monitor/phone)
var _phone_dot: Panel
var _info_layer: Control
# Host-türetimli her yüzeyin kırpan dış sarmalayıcısı (OdaLayout standardı 2).
var _monitor_wrap: Control
var _screen_glow: TextureRect          # gece ekran parlaması (additive — stylebox gölgesi DEĞİL)
var _board_wraps: Dictionary = {}      # "goal"/"market"/"dates"/"postit" -> Control
var _mon_header: Label
var _mon_chip: PanelContainer
var _mon_chip_label: Label
var _mon_chip_dot: Panel
var _mon_title: Label
var _mon_meta: Label
var _mon_grid: GridContainer
var _mon_cells: Array = []             # 4 × {cap: Label, val: Label}
var _mon_footer: Label
var _mon_slack: Control                # grid gizliyken boşluğu yutan esnek dolgu
var _mon_progress_block: VBoxContainer
var _mon_bar: Control                  # BuildBar örneği (kendi modelini kendi çeker)
var _phone_glass: Control              # DÖNMÜŞ kırpan sarmalayıcı (camda yalnız bildirim)
var _phone_glass_label: Label
var _board_goal: PanelContainer
var _goal_label: Label
var _goal_value: Label
var _goal_sub: Label
var _goal_bar: ProgressBar
var _board_league: PanelContainer
var _league_title: Label
var _league_rank: Label
var _league_rows: VBoxContainer
var _board_dates: PanelContainer
var _dates_title: Label
var _dates_rows: VBoxContainer
var _postit_line: Label
var _overtime_chip: PanelContainer
var _overtime_label: Label
var _frame_slots: Array[Control] = []
var _papers_box: Control
var _hotspots: Dictionary = {}         # id -> Control
var _frame_outlines: Array[Panel] = [] # çerçeve başına border-only hover halkası

# Durum
var _is_night: bool = false
var _light_state: StringName = &""     # "" = henüz kurulmadı (ilk _eval_light hep uygular)
var _mentor_line: String = ""
var _paper_cards: Dictionary = {}      # paper_id -> PanelContainer
var _seen_paper_ids: Dictionary = {}   # geliş animasyonu tek-seferlik bekçisi
var _tour: Control = null
var _debug_papers: bool = false        # --oda-shot=night fixture'ı

# Tween sahipleri (kill-and-replace — asla üst üste binmez)
var _night_tween: Tween
var _buzz_tween: Tween
var _hover_tweens: Dictionary = {}


func _ready() -> void:
	add_to_group("oda_view")
	_build_scene_layer()
	_build_object_layer()
	_build_fx_layer()
	_build_info_layer()
	_build_hotspot_layer()
	for link in _bus_links():
		(link[0] as Signal).connect(link[1])
	resized.connect(_relayout)
	visibility_changed.connect(_on_visibility_changed)
	# İlk kadraj: boyut _ready'de henüz oturmamış olabilir — bir frame ertele.
	call_deferred("_first_paint")


func _exit_tree() -> void:
	for link in _bus_links():
		(link[0] as Signal).disconnect(link[1])


func _first_paint() -> void:
	_relayout()
	_refresh_all()
	_eval_light(true)


# =========================================================================
# KURULUM — katmanlar
# =========================================================================

func _mk_layer(layer_name: String, parent: Control) -> Control:
	var c := Control.new()
	c.name = layer_name
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


func _hspacer(parent: Control) -> void:
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(sp)


func _mk_col(parent: Control, separation: int) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", separation)
	parent.add_child(col)
	return col


func _build_scene_layer() -> void:
	_scene_layer = _mk_layer("SceneLayer", self)
	# Kuşatma plakası: ultra-geniş ekranda odanın iki yanında kalan boşluk
	# (OdaLayout.room_rect). _scene_layer'ın İÇİNDE, çünkü gece tint'i kuşatmayı da
	# odayla birlikte karartmalı.
	var surround := ColorRect.new()
	surround.name = "Surround"
	surround.color = UiTokens.BG_ART
	surround.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surround.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scene_layer.add_child(surround)
	_day_art = _mk_scene_art("DayArt", TEX_DAY)
	_night_art = _mk_scene_art("NightArt", TEX_NIGHT)
	_night_art.modulate.a = 0.0
	_night_art.visible = false


func _mk_scene_art(art_name: String, tex: Texture2D) -> TextureRect:
	# IGNORE_SIZE + KEEP_ASPECT_COVERED = kaplama + merkezli kırpma; mipmap'li filtre
	# 4K→~1400px küçültmede shimmer'ı önler. Rect'i _relayout room_rect'ten sürer —
	# çapalarla TEK rect'i paylaşmalı, yoksa ultra-geniş ekranda ayrışırlar.
	var tr_node := TextureRect.new()
	tr_node.name = art_name
	tr_node.texture = tex
	tr_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr_node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	tr_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scene_layer.add_child(tr_node)
	return tr_node


func _build_object_layer() -> void:
	_object_layer = _mk_layer("ObjectLayer", self)
	# Çizim sırası: lamba (arka) → monitör → klavye (monitör ayağının önünde) → mug → telefon.
	_mk_object_sprite("Lamp", TEX_LAMP, "lamp", false)
	_mk_object_sprite("Monitor", TEX_MONITOR, "monitor", true)
	_mk_object_sprite("Keyboard", TEX_KEYBOARD, "keyboard", false)
	_mk_object_sprite("Mug", TEX_MUG, "mug", false)
	_mk_object_sprite("Phone", TEX_PHONE, "phone", true)


func _mk_object_sprite(node_name: String, tex: Texture2D, layout_id: String, hoverable: bool) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = OdaLayout.padded_region(layout_id, tex)
	var tr_node := TextureRect.new()
	tr_node.name = node_name
	tr_node.texture = atlas
	tr_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr_node.stretch_mode = TextureRect.STRETCH_SCALE  # hedef aspect == region aspect (OdaLayout garantisi)
	tr_node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	tr_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if hoverable:
		var mat := ShaderMaterial.new()
		mat.shader = RIM_SHADER
		mat.set_shader_parameter("glow_color", UiTokens.ODA_RIM_GLOW)
		mat.set_shader_parameter("glow_strength", 0.0)
		tr_node.material = mat
		_sprite_mats[layout_id] = mat
	_object_layer.add_child(tr_node)
	_sprites[layout_id] = tr_node


func _build_fx_layer() -> void:
	# Lambanın gece ışığını emissive ampul + plakaya baked havuz taşır; buraya hale
	# eklenmez — additive hale düz siyah gövdeyi sütlü gösterir.
	var fx := _mk_layer("FXLayer", self)
	# Telefon kırmızı noktası: bekleyen olay latch'i (animasyon değil, durum).
	_phone_dot = UiFactory.make_dot(UiTokens.ODA_BADGE_BG, 10)
	_phone_dot.name = "PhoneDot"
	_phone_dot.visible = false
	fx.add_child(_phone_dot)


func _build_info_layer() -> void:
	_info_layer = _mk_layer("InfoLayer", self)
	_build_screen_glow()
	_build_monitor_screen()
	_build_phone_glass()
	_build_board_cards()
	for i in 3:
		# Çerçeve belgesi slotu; içeriği _refresh_frames kurar.
		_frame_slots.append(_mk_surface_wrap("FrameSlot%d" % i))
	_build_overtime_chip()
	_papers_box = _mk_layer("PapersBox", _info_layer)


func _mk_surface_wrap(wrap_name: String) -> Control:
	# Düz Control min-size YAYMAZ → set_size'ın minimuma yukarı clamp'i taşma üretemez;
	# clip_contents içteki panelin stylebox'ı dahil her şeyi kırpar. İçerik kısaltma
	# (satır cap + clip_text) birincil mekanizma, bu sarmalayıcı yapısal emniyettir.
	var wrap := Control.new()
	wrap.name = wrap_name
	wrap.clip_contents = true
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_info_layer.add_child(wrap)
	return wrap


## Sarmalayıcı + içinde full-rect temalı panel.
func _mk_wrapped_panel(wrap_name: String, panel_name: String, variation: StringName) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = panel_name
	panel.theme_type_variation = variation
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mk_surface_wrap(wrap_name).add_child(panel)
	return panel


func _build_screen_glow() -> void:
	# Additive radyal gradyan, monitör sarmalayıcısının DIŞINDA/arkasında — stylebox
	# gölgesi olsaydı sarmalayıcı onu yarım-glow'a kırpardı. Gündüz alfa 0.
	var grad := Gradient.new()
	grad.set_color(0, UiTokens.ODA_SCREEN_GLOW)
	grad.set_color(1, Color(UiTokens.ODA_SCREEN_GLOW, 0.0))
	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.fill = GradientTexture2D.FILL_RADIAL
	gtex.fill_from = Vector2(0.5, 0.5)
	gtex.fill_to = Vector2(0.5, 0.0)
	gtex.width = 256
	gtex.height = 256
	_screen_glow = TextureRect.new()
	_screen_glow.name = "ScreenGlow"
	_screen_glow.texture = gtex
	_screen_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_screen_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_screen_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var add_mat := CanvasItemMaterial.new()
	add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_screen_glow.material = add_mat
	_screen_glow.modulate.a = 0.0
	_info_layer.add_child(_screen_glow)


func _build_monitor_screen() -> void:
	# Cam dolu okunur — başlık, 2×2 stat grid'i, mono alt-durum satırı. Ölü siyah alan kalmaz.
	var screen := _mk_wrapped_panel("MonitorWrap", "MonitorScreen", &"OdaMonitorScreen")
	_monitor_wrap = screen.get_parent()
	var col := _mk_col(screen, UiTokens.SPACE_M)
	var head := HBoxContainer.new()
	col.add_child(head)
	_mon_header = UiFactory.make_label("", &"OdaScreenCaption")
	head.add_child(_mon_header)
	_hspacer(head)
	_mon_chip = PanelContainer.new()
	_mon_chip.theme_type_variation = &"ChromeChip"
	head.add_child(_mon_chip)
	var chip_row := HBoxContainer.new()
	chip_row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	_mon_chip.add_child(chip_row)
	_mon_chip_dot = UiFactory.make_dot(UiTokens.oda_health_green(), 6)
	chip_row.add_child(_mon_chip_dot)
	_mon_chip_label = UiFactory.make_label("", &"ChromeBadgeLabel")
	chip_row.add_child(_mon_chip_label)
	_mon_title = UiFactory.make_label("", &"OdaScreenTitle")
	_mon_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_mon_title)
	_mon_meta = UiFactory.make_label("", &"OdaScreenCaption")
	col.add_child(_mon_meta)
	# 2×2 stat grid'i (canlı yüz): hücreler dikeyde EXPAND — cam boşluğunu grid yutar.
	_mon_grid = GridContainer.new()
	_mon_grid.columns = 2
	_mon_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_mon_grid.add_theme_constant_override("h_separation", UiTokens.SPACE_XL)
	_mon_grid.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	col.add_child(_mon_grid)
	for i in 4:
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cell.alignment = BoxContainer.ALIGNMENT_CENTER
		cell.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
		_mon_grid.add_child(cell)
		var cap := UiFactory.make_label("", &"OdaScreenCaption")
		cell.add_child(cap)
		var val := UiFactory.make_label("", &"OdaScreenValue")
		cell.add_child(val)
		_mon_cells.append({"cap": cap, "val": val})
	# Esnek dolgu: grid gizliyken (build/boş yüz) boşluğu bu yutar — içerik üstte toplanır.
	_mon_slack = Control.new()
	_mon_slack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_mon_slack.visible = false
	col.add_child(_mon_slack)
	# İlerleme bloğu (yalnız build yüzü): BuildHUD ve tracker kartıyla AYNI sahne; renkler
	# bar'ın kendi token okumasından (üç ev sahibinde piksel piksel aynı). KOŞULSUZ kurulur
	# ki theme-audit düğüm deltası deterministik olsun; yüksekliği _relayout camdan türetir.
	_mon_progress_block = _mk_col(col, UiTokens.SPACE_XS)
	var prog_label := UiFactory.make_label("", &"OdaScreenCaption")
	prog_label.name = "ProgLabel"
	_mon_progress_block.add_child(prog_label)
	_mon_bar = BUILD_BAR_SCENE.instantiate()
	_mon_bar.name = "BuildBar"
	_mon_bar.custom_minimum_size = Vector2(0, 44)
	_mon_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_mon_progress_block.add_child(_mon_bar)
	# Alt durum satırı (canlı yüz).
	_mon_footer = UiFactory.make_label("", &"OdaScreenCaption")
	col.add_child(_mon_footer)


func _build_phone_glass() -> void:
	# Camda YALNIZ bildirim — kırmızı nokta + mentor adı; tam mesaj tıklamayla Events
	# sayfasına gider. Sarmalayıcı KENDİSİ döner ve kırpar (kırpma dönmüş uzayda cama oturur).
	_phone_glass = Control.new()
	_phone_glass.name = "PhoneGlass"
	_phone_glass.clip_contents = true
	_phone_glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phone_glass.visible = false
	_info_layer.add_child(_phone_glass)
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	_phone_glass.add_child(row)
	var dot_holder := VBoxContainer.new()
	dot_holder.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(dot_holder)
	dot_holder.add_child(UiFactory.make_dot(UiTokens.ODA_BADGE_BG, 8))
	_phone_glass_label = UiFactory.make_label("", &"ChromeBadgeLabel")
	row.add_child(_phone_glass_label)


func _build_board_cards() -> void:
	# Her pano kartı kırpan sarmalayıcıda; rect'i board_inner HOST'undan türer (BOARD_REL).
	# Hedef kartı: pazar payı / tarihler kalıbı — başlık HBox'ı (mono, BÜYÜK HARF, değer
	# sağa yaslı) → satır → ince çizgi.
	_board_goal = _mk_wrapped_panel("GoalWrap", "BoardGoal", &"OdaBoardCard")
	_board_wraps["goal"] = _board_goal.get_parent()
	var gcol := _mk_col(_board_goal, UiTokens.SPACE_XS)
	var ghead := HBoxContainer.new()
	gcol.add_child(ghead)
	_goal_label = UiFactory.make_label("", &"NewsMeta")
	ghead.add_child(_goal_label)
	_hspacer(ghead)
	_goal_sub = UiFactory.make_label("", &"NewsMeta")
	ghead.add_child(_goal_sub)
	# clip_text + expand-fill: uzun değer sarmalayıcıda kesilmek yerine zarifçe kısalır.
	_goal_value = UiFactory.make_label("", &"RowMeta")
	_goal_value.clip_text = true
	_goal_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gcol.add_child(_goal_value)
	_goal_bar = ProgressBar.new()
	_goal_bar.theme_type_variation = &"BuildProgress"
	# 3px: BuildProgress stylebox'ları donmuş temada; yükseklik tek serbest değişken ve bu
	# boyda radius-3 dolgu şerit değil ÇİZGİ okur.
	_goal_bar.custom_minimum_size = Vector2(0, 3)
	_goal_bar.show_percentage = false
	_goal_bar.max_value = 100.0
	gcol.add_child(_goal_bar)
	# Pazar payı kartı.
	_board_league = _mk_wrapped_panel("MarketWrap", "BoardLeague", &"OdaBoardCard")
	_board_wraps["market"] = _board_league.get_parent()
	var lcol := _mk_col(_board_league, UiTokens.SPACE_XS)
	var lhead := HBoxContainer.new()
	lcol.add_child(lhead)
	_league_title = UiFactory.make_label("", &"NewsMeta")
	lhead.add_child(_league_title)
	_hspacer(lhead)
	_league_rank = UiFactory.make_label("", &"NewsMeta")
	lhead.add_child(_league_rank)
	_league_rows = _mk_col(lcol, UiTokens.SPACE_XXS)
	# İşaretli tarihler.
	_board_dates = _mk_wrapped_panel("DatesWrap", "BoardDates", &"OdaBoardCard")
	_board_wraps["dates"] = _board_dates.get_parent()
	var dcol := _mk_col(_board_dates, UiTokens.SPACE_XS)
	_dates_title = UiFactory.make_label("", &"NewsMeta")
	dcol.add_child(_dates_title)
	_dates_rows = _mk_col(dcol, UiTokens.SPACE_XXS)
	# İstisna post-it'i (dönüş SARMALAYICIDA — klip yerel/dönmüş uzayda oturur).
	var postit := _mk_wrapped_panel("PostItWrap", "PostIt", &"OdaPostIt")
	_board_wraps["postit"] = postit.get_parent()
	_board_wraps["postit"].visible = false
	_postit_line = UiFactory.make_label("", &"QuoteSerif")
	_postit_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	postit.add_child(_postit_line)


func _build_overtime_chip() -> void:
	_overtime_chip = PanelContainer.new()
	_overtime_chip.name = "OvertimeChip"
	_overtime_chip.theme_type_variation = &"ChromeChip"
	_overtime_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overtime_chip.visible = false
	_info_layer.add_child(_overtime_chip)
	_overtime_label = UiFactory.make_label("", &"ChromeBadgeLabel")
	_overtime_label.add_theme_color_override("font_color", UiTokens.ODA_ACCENT)
	_overtime_chip.add_child(_overtime_label)


func _build_hotspot_layer() -> void:
	var hs_layer := _mk_layer("HotspotLayer", self)
	hs_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	# Çerçeve hover halkaları: çerçeve BAŞINA border-only outline.
	for i in 3:
		var outline := Panel.new()
		outline.name = "FrameOutline%d" % i
		outline.theme_type_variation = &"OdaAnchorGlow"
		outline.modulate.a = 0.0
		outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hs_layer.add_child(outline)
		_frame_outlines.append(outline)
	# Pencere BİLEREK hotspot'suz (tıklanmaz, yalnız zamanı söyler).
	for id in ["monitor", "phone", "board", "frames"]:
		var hs := Control.new()
		hs.name = "Hotspot" + id.capitalize()
		hs.mouse_filter = Control.MOUSE_FILTER_STOP
		hs.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hs.mouse_entered.connect(_set_hover.bind(id, true))
		hs.mouse_exited.connect(_set_hover.bind(id, false))
		hs.gui_input.connect(_on_hotspot_input.bind(id))
		hs_layer.add_child(hs)
		_hotspots[id] = hs
	_hotspots["phone"].add_to_group("oda_phone_anchor")  # event_modal telefon-orijin tween'i buradan bulur


# =========================================================================
# SİNYALLER
# =========================================================================

func _bus_links() -> Array:
	return [
		[EventBus.hour_changed, _on_hour_changed],
		[EventBus.day_advanced, _on_day_advanced],
		[EventBus.mrr_changed, _on_mrr_changed],
		[EventBus.phase_changed, _on_phase_changed],
		[EventBus.build_phase_changed, _on_build_phase_changed],
		[EventBus.build_progress_changed, _refresh_monitor],
		[EventBus.event_triggered, _on_event_triggered],
		[EventBus.event_resolved, _on_event_resolved],
		[EventBus.mentor_advisory_changed, _on_mentor_advisory],
		[EventBus.hr_day_processed, _on_hr_day_processed],
		[EventBus.morale_changed, _on_morale_changed],
		[EventBus.rival_advanced, _refresh_league],
		[EventBus.rival_status_changed, _on_rival_status_changed],
		[EventBus.sheet_granted, _on_ledger_moved],
		[EventBus.sheet_expired, _on_ledger_moved],
		[EventBus.sheet_walked, _on_ledger_moved],
		[EventBus.customer_added, _on_ledger_moved],
		[EventBus.customer_removed, _on_ledger_moved],
		[EventBus.customer_health_changed, _on_ledger_moved],
		[EventBus.language_changed, _on_look_changed],
		# Renk körü paleti: ODA'nın semantik renkleri her boyamada token'dan okunur,
		# o yüzden tam tazeleme yeterli.
		[EventBus.palette_changed, _on_look_changed],
	]


func _on_hour_changed(_hour: int) -> void:
	_eval_light(false)
	_refresh_overtime_chip()  # mesai sinyali yok — saatlik poll

func _on_day_advanced(_d: int) -> void:
	_refresh_monitor()
	_refresh_dates()
	_refresh_papers()
	_refresh_frames()
	_refresh_goal()

func _on_mrr_changed(_v: int) -> void:
	_refresh_monitor()
	_refresh_goal()
	_refresh_league()  # pazar payı MRR'dan türer

func _on_phase_changed(_p: int) -> void:
	_refresh_goal()
	_refresh_papers()
	_refresh_frames()

func _on_build_phase_changed(_p: String) -> void:
	_refresh_monitor()
	_refresh_league()  # aktif sub-type build'le değişebilir

func _on_event_triggered(_id: String) -> void:
	_refresh_phone_dot()
	_play_phone_buzz()

func _on_event_resolved(_id: String, _choice: int) -> void:
	_refresh_phone_dot()

func _on_mentor_advisory(text: String) -> void:
	_mentor_line = text
	_refresh_phone_notice()

func _on_hr_day_processed() -> void:
	_refresh_papers()
	_refresh_postit()
	_refresh_overtime_chip()
	_eval_light(false)  # mesai başladı/bittiyse gece zorlaması anında otursun

func _on_morale_changed(_id: String, _m: int) -> void:
	_refresh_postit()

func _on_rival_status_changed(_id: String, _s: String) -> void:
	_refresh_league()

## Term sheet ve müşteri sinyalleri (1 ya da 2 argüman).
func _on_ledger_moved(_id: String, _phase: String = "") -> void:
	_refresh_papers()
	_refresh_dates()

func _on_look_changed(_v: Variant) -> void:
	_refresh_all()

func _on_visibility_changed() -> void:
	if visible:
		_relayout()
		_refresh_all()
		_eval_light(true)  # sekmeden dönüşte anlık otur (fade tekrarı olmasın)


func _refresh_all() -> void:
	_refresh_monitor()
	_refresh_phone_dot()
	_refresh_phone_notice()
	_refresh_goal()
	_refresh_league()
	_refresh_dates()
	_refresh_postit()
	_refresh_papers()
	_refresh_frames()
	_refresh_overtime_chip()


# =========================================================================
# YERLEŞİM
# =========================================================================

func _relayout() -> void:
	var view: Vector2 = size
	if view.x < 2.0 or view.y < 2.0:
		return
	# Boyama ve çapalar TEK rect'i paylaşır (room_rect → cover_transform).
	var room: Rect2 = OdaLayout.room_rect(view)
	_set_rect(_day_art, room)
	_set_rect(_night_art, room)
	for id in _sprites:
		_set_rect(_sprites[id], OdaLayout.place(OdaLayout.padded_target(id), view))
	# Telefon noktası: telefon içerik-kutusunun sağ-üst köşesi.
	var phone_r: Rect2 = OdaLayout.place(OdaLayout.RECTS["phone"], view)
	_phone_dot.position = phone_r.position + Vector2(phone_r.size.x - 8.0, -4.0)
	# Monitör camı: sprite İÇERİK rect'inden (padded_target DEĞİL — pad kaydırır).
	var mon_rect: Rect2 = OdaLayout.place(OdaLayout.RECTS["monitor"], view)
	var glass: Rect2 = OdaLayout.rect_in(mon_rect, OdaLayout.MONITOR_GLASS_REL)
	_set_rect(_monitor_wrap, glass)
	_set_rect(_screen_glow, glass.grow(12.0))
	# BuildBar yüksekliği CAMDAN türer. Kartın doğal boyu 2+44+48+44 = 138; 1080p camına
	# (~269px) sığar, 720p camında (~164px) size_scale ile satır yükseklikleri ve yazı boyu
	# birlikte iner — bar kendi eşiklerinden yazıyı MICRO'ya çeker, 9px altına inmez.
	var card_h: float = 138.0
	var fit: float = clampf(glass.size.y * 0.62 / card_h, 0.62, 1.0)
	if not is_equal_approx(float(_mon_bar.size_scale), fit):
		_mon_bar.size_scale = fit
		_mon_bar.rebuild()
	_mon_bar.custom_minimum_size = Vector2(0.0, card_h * fit)
	# Telefon camı: dönmüş sarmalayıcı — pivot_offset piksel cinsindendir, resize'da kendi
	# kendine güncellenmez; her boyut atamasından SONRA kurulur.
	var pglass_size: Vector2 = phone_r.size * OdaLayout.PHONE_GLASS_SIZE_REL
	var pglass_center: Vector2 = phone_r.position + phone_r.size * OdaLayout.PHONE_GLASS_CENTER_REL
	_phone_glass.size = pglass_size
	_phone_glass.pivot_offset = pglass_size * 0.5
	_phone_glass.position = pglass_center - pglass_size * 0.5
	_phone_glass.rotation = deg_to_rad(OdaLayout.PHONE_GLASS_ANGLE_DEG)
	# Pano kartları: board_inner HOST'undan.
	var board: Rect2 = OdaLayout.place(OdaLayout.RECTS["board_inner"], view)
	for key in _board_wraps:
		_set_rect(_board_wraps[key], OdaLayout.rect_in(board, OdaLayout.BOARD_REL[key]))
	var postit_wrap: Control = _board_wraps["postit"]
	postit_wrap.pivot_offset = postit_wrap.size * 0.5
	postit_wrap.rotation_degrees = -2.0
	# Çerçeve belgeleri (dış kutu → içerleme) ve hover halkaları (dış kutu; piksel
	# uzayında grow — normalize grow x/y'yi eşitsiz ölçeklerdi).
	for i in 3:
		var outer: Rect2 = OdaLayout.place(OdaLayout.RECTS["frame_outer_%d" % i], view)
		_set_rect(_frame_slots[i], OdaLayout.frame_doc_rect(outer))
		_set_rect(_frame_outlines[i], outer.grow(4.0))
	_set_rect(_overtime_chip, OdaLayout.place_clamped(OdaLayout.RECTS["overtime_chip"], view))
	# Hotspot'lar: obje/bölge rect'leri (padsız içerik kutuları).
	for id in _hotspots:
		var anchor: String = {"board": "board_outer", "frames": "frames_band"}.get(id, id)
		_set_rect(_hotspots[id], OdaLayout.place(OdaLayout.RECTS[anchor], view))
	_layout_papers()


func _set_rect(node: Control, r: Rect2) -> void:
	node.position = r.position
	node.size = r.size


func _layout_papers() -> void:
	var idx: int = 0
	for paper_id in _paper_cards:
		if idx >= OdaLayout.PAPER_SLOTS.size():
			break
		var slot: Dictionary = OdaLayout.PAPER_SLOTS[idx]
		var r: Rect2 = OdaLayout.place(slot["rect"], size)
		var card: PanelContainer = _paper_cards[paper_id]
		card.position = r.position
		card.custom_minimum_size = Vector2(r.size.x, 0)
		card.size = Vector2(r.size.x, 0)
		card.rotation_degrees = float(slot["rot"])
		idx += 1


# =========================================================================
# IŞIK DURUM MAKİNESİ — dört durum, geçiş yalnız durum sınırında.
# =========================================================================

## §8.1: mesai bitiminde hava kararır; karanlık ŞİRKET PENCERESİNE göre çizilir
## (başlangıç saati + şirket süresi). Kişilerin bireysel istisnaları odayı karartmaz.
func _past_company_close(hour: int) -> bool:
	var close_h: int = WorkHoursSystem.start_hour() + GameState.company_work_hours
	if close_h >= 24:
		return false      # pencere gece yarısını aşıyorsa gün içinde kapanış yok
	return hour >= close_h


func _light_state_for_hour(hour: int) -> StringName:
	if _past_company_close(hour) or hour >= 19 or hour <= 5:
		return &"night"
	if hour == 18:
		return &"evening"
	if hour == 6:
		return &"dawn"
	return &"day"


func _eval_light(instant: bool) -> void:
	var state: StringName = _light_state_for_hour(GameState.current_hour)
	if state == _light_state:
		return
	_light_state = state
	var night: bool = state == &"night"
	_is_night = night
	var scene_tint: Color = Color.WHITE
	match state:
		&"evening":
			scene_tint = UiTokens.ODA_TINT_EVENING
		&"dawn":
			scene_tint = UiTokens.ODA_TINT_DAWN
	var target_a: float = 1.0 if night else 0.0
	var glow_a: float = SCREEN_GLOW_NIGHT_A if night else 0.0
	# Objeler plakayla AYNI ışıktan render edildi; tint'siz obje turuncu odanın üstünde
	# gündüz gibi durur. Çarpım: gece ODA_NIGHT_TINT, akşam/şafak sahne tint'i, gündüz beyaz.
	var obj_tint: Color = (UiTokens.ODA_NIGHT_TINT if night else Color.WHITE) * scene_tint
	_apply_lamp_texture(night)
	if _night_tween != null and _night_tween.is_valid():
		_night_tween.kill()
	if instant or not is_visible_in_tree():
		_night_art.visible = night
		_night_art.modulate.a = target_a
		_object_layer.modulate = obj_tint
		_scene_layer.modulate = scene_tint
		_screen_glow.modulate.a = glow_a
		return
	_night_art.visible = true
	_night_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_night_tween.tween_property(_night_art, "modulate:a", target_a, LIGHT_FADE_S)
	_night_tween.tween_property(_object_layer, "modulate", obj_tint, LIGHT_FADE_S)
	_night_tween.tween_property(_scene_layer, "modulate", scene_tint, LIGHT_FADE_S)
	_night_tween.tween_property(_screen_glow, "modulate:a", glow_a, LIGHT_FADE_S)
	# Gece quad'ını kapatma fade bitiminde (tek kare değişimi kuyruğunda erir).
	_night_tween.chain().tween_callback(func() -> void:
		if not _is_night:
			_night_art.visible = false
	)


func _apply_lamp_texture(night: bool) -> void:
	# Region aynı kalır (iki varyant aynı kameradan aynı kanvasa çizildi); ölçek her
	# dokudan yeniden okunur çünkü import size_limit varyantları farklı ölçekleyebilir.
	var tex: Texture2D = TEX_LAMP_NIGHT if night else TEX_LAMP
	var atlas: AtlasTexture = _sprites["lamp"].texture
	if atlas.atlas != tex:
		atlas.atlas = tex
		atlas.region = OdaLayout.padded_region("lamp", tex)


# =========================================================================
# MONİTÖR — build yüzü / canlı ürün yüzü / boş yüz. Ekran asla boş değil.
# =========================================================================

func _refresh_monitor() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	var prog_label: Label = _mon_progress_block.get_node("ProgLabel")
	# Ortak taban: build yüzü kromu gizler, diğer iki yüz geri ister — bir yüzün
	# gizlemesi öbürüne sızmasın.
	_mon_header.visible = true
	_mon_title.visible = true
	prog_label.visible = true
	if b != null and not b.is_bug_sprint:
		# YAPIM YÜZÜ = yalnız BuildBar kartı. Kart modelini kendisi çeker (aynı sinyaller);
		# ek başlık/çip kartın söylediğini ikinci kez söylerdi.
		_mon_header.visible = false
		_mon_chip.visible = false
		_mon_title.visible = false
		_mon_meta.visible = false
		_mon_grid.visible = false
		_mon_footer.visible = false
		_mon_slack.visible = true
		_mon_progress_block.visible = true
		prog_label.visible = false
		return
	if bool(GameState.get_flag("mvp_shipped", false)):
		# CANLI ÜRÜN YÜZÜ: 2×2 stat grid'i + alt durum satırı.
		var pname: String = String(GameState.get_flag("mvp_product_name", GameState.company_name))
		var ver: int = int(GameState.get_flag("mvp_version", 1))
		_mon_header.text = "%s · V%d" % [UiTokens.tr_upper(pname), ver]
		_mon_chip.visible = true
		var healthy: bool = ProductSystem.health_state() == "saglikli"   # LOC-DATA state / route id
		_set_chip_dot(UiTokens.oda_health_green() if healthy else UiTokens.ODA_HEALTH_AMBER)
		_mon_chip_dot.visible = true
		_mon_chip_label.text = tr("ODA_MONITOR_LIVE_CHIP")
		_mon_chip_label.add_theme_color_override("font_color", UiTokens.ODA_CREAM)
		_mon_title.text = tr("ODA_MONITOR_OK_TITLE") if healthy else tr("ODA_MONITOR_RISK_TITLE")
		var bugs: int = int(GameState.get_flag("mvp_live_bug_count", 0))
		var raw_stab: float = float(GameState.get_flag("mvp_stability", 0.0))
		var eff_stab: int = int(round(QualityModel.effective_stability(raw_stab, bugs)))
		var is_b2b: bool = String(GameState.get_flag("mvp_market_type", "b2c")) == "b2b"
		var users_cap: String = tr("ODA_MON_CAP_ACCOUNTS") if is_b2b else tr("ODA_MON_CAP_USERS")
		var users_val: String = str(CustomerRegistry.get_by_market("b2b").size()) if is_b2b \
			else str(int(GameState.get_flag("b2c_audience", 0)))
		var cells: Array = [
			[tr("ODA_MON_CAP_BUGS"), str(bugs)],
			[tr("ODA_MON_CAP_STAB"), str(eff_stab)],
			[tr("ODA_MON_CAP_MRR"), UiTokens.format_money(GameState.mrr)],
			[users_cap, users_val],
		]
		for i in 4:
			(_mon_cells[i]["cap"] as Label).text = UiTokens.tr_upper(String(cells[i][0]))
			(_mon_cells[i]["val"] as Label).text = String(cells[i][1])
		_mon_meta.visible = false
		_mon_grid.visible = true
		_mon_slack.visible = false
		_mon_footer.visible = true
		# health_state() bir ORAN testidir: 70 kararlılıkta onlarca canlı hataya kadar
		# "saglikli" döner. Hata sayısı ayrı terim olmazsa HATA hücresi ile alt satır
		# birbirini yalanlar.
		var footer: String = tr("ODA_MONITOR_WARN")
		if healthy:
			footer = tr("ODA_MONITOR_CALM") if bugs == 0 else tr("ODA_MONITOR_BUGS").format({"n": bugs})
		_mon_footer.text = UiTokens.tr_upper(footer)
		_mon_progress_block.visible = false
		return
	# BOŞ YÜZ (run başı — henüz ne build ne yayın).
	_mon_header.text = UiTokens.tr_upper(GameState.company_name)
	_mon_chip.visible = false
	_mon_title.text = tr("ODA_MONITOR_IDLE")
	_mon_meta.visible = true
	_mon_meta.text = UiTokens.tr_upper(tr("ODA_MONITOR_IDLE_META"))
	_mon_grid.visible = false
	_mon_slack.visible = true
	_mon_footer.visible = false
	_mon_progress_block.visible = false


func _set_chip_dot(color: Color) -> void:
	# make_dot stylebox'ı sabit renkli — rengi değişince yeniden kur (ucuz, 6px).
	var row: HBoxContainer = _mon_chip.get_child(0)
	var old: Panel = _mon_chip_dot
	_mon_chip_dot = UiFactory.make_dot(color, 6)
	row.add_child(_mon_chip_dot)
	row.move_child(_mon_chip_dot, 0)
	old.queue_free()


# =========================================================================
# TELEFON
# =========================================================================

func _refresh_phone_dot() -> void:
	_phone_dot.visible = EventGate.queue_size() > 0


func _refresh_phone_notice() -> void:
	if _mentor_line == "":
		_phone_glass.visible = false
		return
	_phone_glass.visible = true
	var tag: String = tr("ODA_MENTOR_TAG_FALLBACK")
	var mentor: Character = CharacterRegistry.get_mentor()
	if mentor != null and mentor.character_name != "":
		tag = UiTokens.tr_upper(mentor.character_name.get_slice(" ", 0))
	_phone_glass_label.text = tag


## Mentor satırı latch'inin tek evi (motor satırı saklamıyor); Events sayfası tam
## mesajı buradan okur.
func get_mentor_line() -> String:
	return _mentor_line


func _play_phone_buzz() -> void:
	# TEK titreşim + rim parıltısı; olay başına bir kez, sonra hareketsiz.
	if not is_visible_in_tree():
		return
	var phone: TextureRect = _sprites["phone"]
	var mat: ShaderMaterial = _sprite_mats["phone"]
	if _buzz_tween != null and _buzz_tween.is_valid():
		_buzz_tween.kill()
		phone.position.x = OdaLayout.place(OdaLayout.padded_target("phone"), size).position.x
	var base_x: float = phone.position.x
	var seg: float = BUZZ_S / 6.0
	_buzz_tween = create_tween()
	for i in 3:
		_buzz_tween.tween_property(phone, "position:x", base_x + BUZZ_PX, seg)
		_buzz_tween.tween_property(phone, "position:x", base_x - BUZZ_PX, seg)
	_buzz_tween.tween_property(phone, "position:x", base_x, seg * 0.5)
	var glow := create_tween()
	glow.tween_method(func(v: float) -> void: mat.set_shader_parameter("glow_strength", v), 0.0, 0.9, BUZZ_S * 0.5)
	glow.tween_method(func(v: float) -> void: mat.set_shader_parameter("glow_strength", v), 0.9, 0.0, BUZZ_S)


# =========================================================================
# PANO — hedef / pazar payı / tarihler / post-it
# =========================================================================

## Pano başlık register'ı: mono + BÜYÜK HARF, sondaki iki nokta kesilir (diğer
## başlıklarla aynı). Sunum kararı, o yüzden çağrı yerinde.
static func _goal_head(s: String) -> String:
	return UiTokens.tr_upper(s.trim_suffix(":"))


func _refresh_goal() -> void:
	# Eşikler her boyamada canlı okunur — ayar değişirse pano kendiliğinden doğru kalır.
	_goal_sub.text = ""
	_goal_bar.visible = false
	match GameState.phase:
		1:
			_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P1_LABEL"))
			_goal_value.text = tr("ODA_BOARD_GOAL_P1_META")
			var met: int = 0
			if bool(GameState.get_flag("mvp_shipped", false)): met += 1
			if CustomerRegistry.get_all().size() > 0: met += 1
			if GameState.mrr > 0: met += 1
			_goal_sub.text = tr("ODA_GOAL_PROGRESS").format({"met": met, "total": 3})
			_goal_bar.visible = true
			_goal_bar.value = met / 3.0 * 100.0
		2:
			# Gelir çıtasının rakamı basılmaz — kapının SİNYALİ basılır.
			var sig: Dictionary = PhaseGateSystem.series_a_signal()
			_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P2_LABEL"))
			_goal_value.text = InvestorAppetiteUi.state_text(String(sig.get("state", "closed")))
		_:
			if GameState.series_a_closed:
				_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P3_CLOSED"))
				_goal_value.text = UiTokens.format_money(GameState.run_investment_amount)
			else:
				_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P3_LABEL"))
				_goal_value.text = tr("ODA_BOARD_GOAL_P3_HUNT").format({"n": GameState.active_sheets.size()})


func _refresh_league() -> void:
	# PAZAR PAYI panosu (RivalRegistry.get_market_snapshot — stateless, MRR + katalog
	# seed'lerinden türer). Ürün piyasada değilse kart hiç render edilmez.
	var sub: String = _active_sub_type_id()
	if sub == "" or not bool(GameState.get_flag("mvp_shipped", false)):
		_board_wraps["market"].visible = false
		return
	var snap: Dictionary = RivalRegistry.get_market_snapshot(sub)
	var rivals: Array = snap["rivals"]
	if rivals.is_empty():
		_board_wraps["market"].visible = false
		return
	_board_wraps["market"].visible = true
	_league_title.text = UiTokens.tr_upper(tr("ODA_BOARD_MARKET_TITLE"))
	for child in _league_rows.get_children():
		child.queue_free()
	# Çıktı ama MRR yok: tablo yerine tek yönlendirme satırı.
	if GameState.mrr <= 0:
		_league_rank.text = ""
		var line := UiFactory.make_label(tr("ODA_BOARD_MARKET_EMPTY"), &"QuoteSerif")
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_league_rows.add_child(line)
		return
	# Gerçek pay tablosu: top-3 + oyuncunun HEMEN üstündeki rakip (dedup) + SEN. Satır
	# numarası GERÇEK pazar sırasıdır — sayı atlaması aradaki mesafeyi kendisi anlatır.
	var player_pct: float = float(snap["player_pct"])
	_league_rank.text = RivalRegistry.format_share(player_pct)
	var player_name: String = String(GameState.get_flag("mvp_product_name", ""))
	if player_name == "":
		player_name = GameState.company_name
	var above_count: int = 0
	var nearest_above: Dictionary = {}
	for row in rivals:
		if float(row["share_pct"]) > player_pct:
			above_count += 1
			nearest_above = row
	var picks: Array = rivals.slice(0, 3)
	if not nearest_above.is_empty() and not picks.has(nearest_above):
		picks.append(nearest_above)
	var entries: Array = []
	for pick in picks:
		var rival_rank: int = rivals.find(pick) + 1 + (1 if player_pct > float(pick["share_pct"]) else 0)
		entries.append({"rank": rival_rank, "name": String(pick["name"]),
			"share": float(pick["share_pct"]), "trend": int(pick["trend"]), "is_player": false})
	entries.append({"rank": above_count + 1, "name": player_name,
		"share": player_pct, "trend": 0, "is_player": true})
	entries.sort_custom(func(a, b): return float(a["share"]) > float(b["share"]))
	for e in entries:
		var glyph: String = ["▼ ", "", "▲ "][signi(int(e["trend"])) + 1]
		_league_rows.add_child(_league_row(int(e["rank"]), String(e["name"]), bool(e["is_player"]),
			glyph + RivalRegistry.format_share(float(e["share"]))))
	# "Diğerleri" kuyruğu SIRASIZ kalır: merdivene girseydi oyuncunun kıymığının üstüne
	# basamak olur, sıra atlamasının anlattığı mesafeyi bozardı. Baştaki "…" listenin
	# bitmediğini söyler. <%0,1 iken gizli.
	var others: float = float(snap["others_pct"])
	if others >= 0.1:
		var orow := HBoxContainer.new()
		orow.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		var olbl := UiFactory.make_label("… %s" % tr("ODA_BOARD_MARKET_OTHERS"), &"MicroLabel", UiTokens.ODA_INK_DIM)
		olbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		orow.add_child(olbl)
		orow.add_child(UiFactory.make_label(RivalRegistry.format_share(others), &"MicroLabel", UiTokens.ODA_INK_DIM))
		_league_rows.add_child(orow)


func _active_sub_type_id() -> String:
	# Aktif build → yayınlanmış snapshot → kataloğun ilk tipi.
	var b = ProductSystem.get_active_build()
	if b != null and b.sub_product_type_id != "":
		return b.sub_product_type_id
	var shipped: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	if shipped != "":
		return shipped
	var types: Array = ProductCatalog.get_all_sub_product_types()
	return String(types[0].get("id", "")) if not types.is_empty() else ""


func _league_row(no: int, display: String, is_player: bool, value: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var label := UiFactory.make_label("%d · %s" % [no, UiTokens.tr_upper(display)], &"MicroLabel",
		UiTokens.ODA_INK if is_player else UiTokens.ODA_INK_MUTED)
	label.clip_text = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	if is_player:
		row.add_child(UiFactory.make_label(tr("ODA_BOARD_LEAGUE_YOU"), &"MicroLabel", UiTokens.ODA_ACCENT_DEEP))
	# Pay kolonu: SEN satırında vurgulu, rakipte sönük.
	row.add_child(UiFactory.make_label(value, &"MicroLabel",
		UiTokens.ODA_ACCENT_DEEP if is_player else UiTokens.ODA_INK_DIM))
	return row


func _refresh_dates() -> void:
	# Sunum-tarafı toplama (motorun "yaklaşanlar" toplayıcısı yok): VC görüşme günü, teklif
	# vadeleri, açık söz teslimleri, churn geri sayımları, ay kapanışı. En yakın 3.
	_dates_title.text = UiTokens.tr_upper(tr("ODA_BOARD_DATES_TITLE"))
	for child in _dates_rows.get_children():
		child.queue_free()
	var today: int = GameState.day
	var items: Array = []
	if GameState.pending_meeting.has("day"):
		items.append({"day": int(GameState.pending_meeting["day"]), "label": tr("ODA_BOARD_DATE_MEETING")})
	for sheet in GameState.active_sheets:
		items.append({"day": int(sheet.expires_day), "label": tr("ODA_BOARD_DATE_SHEET")})
	for p in PromiseRegistry.get_all():
		if p.status == "open":
			items.append({"day": int(p.deadline_day), "label": tr("ODA_BOARD_DATE_PROMISE")})
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.churn_countdown >= 0:
			items.append({"day": today + int(c.churn_countdown),
				"label": tr("ODA_BOARD_DATE_CHURN").format({"company": c.company_name})})
	for d in range(today + 1, today + 32):
		if int(GameState.get_date_dict(d)["day"]) == 1:
			items.append({"day": d, "label": tr("ODA_BOARD_DATE_MONTH")})
			break
	items = items.filter(func(it): return int(it["day"]) >= today)
	items.sort_custom(func(a, b): return int(a["day"]) < int(b["day"]))
	items = items.slice(0, 3)
	for it in items:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		var lbl := UiFactory.make_label(String(it["label"]), &"RowMeta")
		lbl.clip_text = true
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		row.add_child(UiFactory.make_label(_date_delta_text(int(it["day"]) - today), &"NewsMeta", UiTokens.ODA_INK))
		_dates_rows.add_child(row)
	_board_wraps["dates"].visible = not items.is_empty()


func _date_delta_text(delta: int) -> String:
	if delta <= 0:
		return tr("ODA_DATE_TODAY")
	if delta == 1:
		return tr("ODA_DATE_TOMORROW")
	return tr("ODA_DATE_IN_DAYS").format({"n": delta})


func _refresh_postit() -> void:
	# Dikkat gerektiren İLK çalışan (worst-first sözleşmesi HRSystem.badges_for'da).
	var target_name: String = ""
	for emp in CharacterRegistry.get_employees():
		if not HRSystem.badges_for(emp).is_empty():
			target_name = emp.character_name.get_slice(" ", 0)
			break
	_board_wraps["postit"].visible = target_name != ""
	if target_name != "":
		_postit_line.text = tr("ODA_BOARD_POSTIT").format({"name": target_name})


## Camın içindeki tek gece sinyali: şirket penceresi KAPANDIKTAN sonra (§8.1) ve mesaide
## en az bir çalışan varsa kaç kişinin hâlâ çalıştığını yazar. Gündüz sessizdir — mesai
## bilgisi gündüz Ekip başlığındaki çipte. Sayım WorkHoursSystem.counts()'tan: çalışma
## saatleri modalinin bedel bloğuyla AYNI sayı (ikisi aynı ekranda yan yana görünebilir).
func _refresh_overtime_chip() -> void:
	var hour: int = int(GameState.get_date_dict().get("hour", 0))
	var on_overtime: int = int(WorkHoursSystem.counts()["overtime"])
	var show: bool = _past_company_close(hour) and on_overtime > 0
	_overtime_chip.visible = show
	if show:
		_overtime_label.text = tr("ODA_OVERTIME_TONIGHT").format({"n": on_overtime})


# =========================================================================
# KÂĞITLAR — ertelenebilir bekleyen kararlar. Temiz masa = işler yolunda.
# =========================================================================

## Hatırlatıcı kâğıt: canlı sistem durumundan türer, tıklanınca sekmeye gider, saati yoktur.
func _reminder(id: String, dot: Color, tag: String, title: String, target: String, subpage: String = "") -> Dictionary:
	return {"id": id, "dot": dot, "tag": tag, "title": title, "target": target, "subpage": subpage, "days_left": -1}


func _gather_papers() -> Array:
	# İKİ CİNS KÂĞIT, TEK MASA. Motor kâğıtları saati işleyen KARARLARDIR, tıklanınca kartı
	# açar; sıralamanın sahibi motordur ve listenin BAŞINA gelir (EvPapers.ordered() en
	# acili öne alır) — son 3 gününe girmiş bir karar görünür üç yuvanın dışında kalamaz.
	# Yuvasını kaybeden hatırlatıcı sekmesinde durmaya devam eder; karar ise saatini
	# kimsenin göremediği yerde bitirirdi.
	var papers: Array = []
	for entry in EventGate.desk_papers(PAPER_CAP):
		var e: Dictionary = entry
		papers.append({
			"id": String(e["id"]),
			"dot": UiTokens.ODA_ACCENT_DEEP if bool(e["urgent"]) else UiTokens.ODA_HEALTH_AMBER,
			"tag": String(e["tag"]),
			"title": String(e["title"]),
			"target": "event:%s" % String(e["id"]),   # kartı açar, sekmeye gitmez
			"subpage": "",
			"days_left": int(e["days_left"]),
			"urgent": bool(e["urgent"]),
		})
	if GameState.phase_gate_ready and GameState.pending_next_phase > 0:
		papers.append(_reminder("gate", UiTokens.ODA_ACCENT_DEEP,
			tr("ODA_PAPER_TAG_GATE"), tr("ODA_PAPER_GATE_TITLE"), "finance"))
	var sheet_count: int = GameState.active_sheets.size()
	if sheet_count > 0:
		var min_left: int = 999
		for sheet in GameState.active_sheets:
			min_left = mini(min_left, sheet.days_left(GameState.day))
		var title: String = tr("ODA_PAPER_SHEET_TITLE").format({"days": maxi(0, min_left)}) if sheet_count == 1 \
			else tr("ODA_PAPER_SHEETS_TITLE").format({"n": sheet_count})
		papers.append(_reminder("sheet", UiTokens.ODA_HEALTH_AMBER,
			tr("ODA_PAPER_TAG_FUNDING"), title, "finance", "yatirim"))   # LOC-DATA state / route id
	if HRSearchSystem.has_files_ready():
		papers.append(_reminder("atlas", UiTokens.ODA_INK_MUTED, tr("ODA_PAPER_TAG_ATLAS"),
			tr("ODA_PAPER_ATLAS_TITLE").format({"n": HRSearchSystem.get_files().size()}), "hr"))
	# İKAME: tasarımın istediği sözleşme yenileme penceresi ve fatura vadesi motorda yok;
	# genişleme aşamasındaki B2B hesabı onların yerini tutar.
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.lifecycle_phase == "expansion":
			papers.append(_reminder("exp_%s" % c.id, UiTokens.oda_health_green(),
				UiTokens.tr_upper(c.company_name), tr("ODA_PAPER_EXPANSION_TITLE"), "sales"))
	if _debug_papers:
		papers.append(_reminder("dbg_gate", UiTokens.ODA_ACCENT_DEEP,
			tr("ODA_PAPER_TAG_GATE"), tr("ODA_PAPER_GATE_TITLE"), "finance"))
		papers.append(_reminder("dbg_atlas", UiTokens.ODA_INK_MUTED,
			tr("ODA_PAPER_TAG_ATLAS"), tr("ODA_PAPER_ATLAS_TITLE").format({"n": 3}), "hr"))
	return papers


func _refresh_papers() -> void:
	var papers: Array = _gather_papers()
	var overflow: int = maxi(0, papers.size() - PAPER_CAP)
	var visible_papers: Array = papers.slice(0, PAPER_CAP)
	var wanted: Dictionary = {}
	for p in visible_papers:
		wanted[p["id"]] = p
	# Kalkan kâğıtlar: karar çözüldü → masadan iz bırakmadan gider.
	for existing_id in _paper_cards.keys():
		if not wanted.has(existing_id):
			_paper_cards[existing_id].queue_free()
			_paper_cards.erase(existing_id)
	# Gelen kâğıtlar (sıra korunarak yeniden dizilir). Geliş animasyonu LAYOUT'TAN
	# SONRA oynar — yoksa _layout_papers tween ortasında pozisyonu ezer.
	var rebuilt: Dictionary = {}
	var arrivals: Array = []
	for i in visible_papers.size():
		var p: Dictionary = visible_papers[i]
		var card: PanelContainer
		if _paper_cards.has(p["id"]):
			card = _paper_cards[p["id"]]
		else:
			card = _mk_paper_card(p)
			if not _seen_paper_ids.has(p["id"]):
				_seen_paper_ids[p["id"]] = true
				arrivals.append(card)
		rebuilt[p["id"]] = card
	_paper_cards = rebuilt
	for i in visible_papers.size():
		_update_paper_overflow_chip(_paper_cards[visible_papers[i]["id"]],
			overflow if i == PAPER_CAP - 1 else 0)
	_layout_papers()
	for card in arrivals:
		_animate_paper_arrival(card)


func _mk_paper_card(p: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"OdaPaperCard"
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	card.add_child(row)
	row.add_child(UiFactory.make_dot(p["dot"], 6))
	row.add_child(UiFactory.make_label(String(p["tag"]), &"MicroLabel"))
	var title := UiFactory.make_label(String(p["title"]), &"BodySerif")
	title.clip_text = true
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	# KALAN SÜRE (§11.4) yalnız saati olan kâğıtta; son üç günde vurgu — ertelenmiş bir
	# kararın aldığı TEK uyarı budur.
	var days_left: int = int(p["days_left"])
	if days_left >= 0:
		var clock := UiFactory.make_label(
			tr("ODA_PAPER_DAYS").format({"n": days_left}), &"MicroLabel",
			UiTokens.ODA_ACCENT_DEEP if bool(p.get("urgent", false)) else UiTokens.ODA_INK_MUTED)
		clock.name = "DaysLeft"
		row.add_child(clock)
	var overflow := UiFactory.make_label("", &"MicroLabel", UiTokens.ODA_ACCENT_DEEP)
	overflow.name = "OverflowChip"
	overflow.visible = false
	row.add_child(overflow)
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"OdaPaperCardHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"OdaPaperCard")
	card.gui_input.connect(_on_paper_input.bind(String(p["target"]), String(p["subpage"])))
	_papers_box.add_child(card)
	return card


func _update_paper_overflow_chip(card: PanelContainer, overflow: int) -> void:
	var chip: Label = card.get_node("Row/OverflowChip")
	chip.visible = overflow > 0
	if overflow <= 0:
		return
	chip.text = "+%d" % overflow
	# Sıralamanın kapatamadığı tek durum: dördü birden son 3 günde. O zaman dördüncüsü
	# saatini çipin arkasında bitirir — çip bu aciliyeti taşır.
	var hidden_urgent: bool = false
	for entry in EventGate.desk_papers(64):
		var e: Dictionary = entry
		if bool(e.get("urgent", false)) and not _paper_cards.has(String(e["id"])):
			hidden_urgent = true
			break
	chip.add_theme_color_override("font_color",
		UiTokens.ODA_ACCENT_DEEP if hidden_urgent else UiTokens.ODA_INK_MUTED)


func _animate_paper_arrival(card: PanelContainer) -> void:
	# Kâğıt başına TEK geliş animasyonu — _seen_paper_ids relayout/tab dönüşünde tekrarı önler.
	if not is_visible_in_tree():
		return
	var target_rot: float = card.rotation_degrees
	card.modulate.a = 0.0
	card.rotation_degrees = target_rot + 9.0
	var from_offset := Vector2(120.0, -20.0)
	card.position += from_offset
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "modulate:a", 1.0, PAPER_ARRIVE_S)
	tw.tween_property(card, "rotation_degrees", target_rot, PAPER_ARRIVE_S)
	tw.tween_property(card, "position", card.position - from_offset, PAPER_ARRIVE_S)


func _on_paper_input(event: InputEvent, target: String, subpage: String) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		return
	# Motor kâğıdı kendi kartını açar, hatırlatıcı sekmeye gider — iki cins TEK tıklama
	# yolunu paylaşır, ayrım `event:` önekiyle.
	if target.begins_with("event:"):
		EventGate.open_paper(target.trim_prefix("event:"))
		return
	EventBus.tab_changed.emit(target)
	if subpage != "":
		# tab_changed mount'u SENKRON — handler bağlandı, deep-link güvenli.
		EventBus.finance_subpage_requested.emit(subpage)


## --oda-shot=night fixture'ı: masaya 2 sentetik kâğıt.
func debug_seed_papers() -> void:
	_debug_papers = true
	_refresh_papers()


# =========================================================================
# ÇERÇEVE DUVARI — kilometre taşları. Boş çerçeve = henüz kazanılmadı.
# =========================================================================

## Milestone sayfası (center_viewport) da buradan okur — türetme tek evde. Motorun
## milestone defteri yok; üçlü kalıcı izlerden türer. Yatırımın günü kayıtlı değil,
## yalnız miktar gösterilir.
func get_milestones() -> Array:
	var launch_day: int = int(GameState.get_flag("mvp_launch_day", 0))
	var funding: int = GameState.run_investment_amount
	return [
		{"name": tr("ODA_FRAME_FOUNDING"), "earned": true, "meta": _month_year(1)},
		{"name": tr("ODA_FRAME_FIRST_SHIP"), "earned": launch_day > 0,
			"meta": _month_year(launch_day) if launch_day > 0 else ""},
		{"name": tr("ODA_FRAME_FIRST_FUNDING"), "earned": funding > 0,
			"meta": UiTokens.format_money(funding) if funding > 0 else ""},
	]


func _month_year(day: int) -> String:
	var d: Dictionary = GameState.get_date_dict(day)
	return Fmt.month_name(int(d["month"])) + " " + str(int(d["year"]))


func _refresh_frames() -> void:
	# Diploma modeli: çerçeve içi = mühür + ad (tarih/tutar milestone sayfasında).
	# Kazanılmamış çerçeve tamamen boş.
	var data: Array = get_milestones()
	for i in 3:
		var slot: Control = _frame_slots[i]
		for child in slot.get_children():
			child.queue_free()
		var m: Dictionary = data[i]
		if not bool(m["earned"]):
			continue
		var plate := PanelContainer.new()
		plate.theme_type_variation = &"EngravingFrame"
		plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(plate)
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		plate.add_child(col)
		var seal_row := HBoxContainer.new()
		seal_row.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_child(seal_row)
		seal_row.add_child(UiFactory.make_dot(UiTokens.ODA_ACCENT_DEEP, 14))
		var nm := UiFactory.make_label(String(m["name"]), &"MicroLabel", UiTokens.ODA_INK_MUTED)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(nm)


# =========================================================================
# HOTSPOT etkileşimi — hover + tıklama hedefleri.
# Hover kuralı: DOLGU ASLA PARLAMAZ. Sprite çapaları = şekle oturan rim shader; pano =
# kart kenarı amber'e döner (varyasyon swap); çerçeveler = çerçeve başına border-only
# outline (modulate fade).
# =========================================================================

func _set_hover(id: String, on: bool) -> void:
	match id:
		"monitor", "phone":
			_tween_rim(id, 1.0 if on else 0.0)
		"board":
			# Margin'ler bayt-aynı (metin zıplamaz); post-it kart değil, hariç.
			var variation: StringName = &"OdaBoardCardHover" if on else &"OdaBoardCard"
			_board_goal.theme_type_variation = variation
			_board_league.theme_type_variation = variation
			_board_dates.theme_type_variation = variation
		"frames":
			for outline in _frame_outlines:
				_hover_tween("outline_" + outline.name).tween_property(
					outline, "modulate:a", 0.6 if on else 0.0, HOVER_FADE_S)


func _hover_tween(key: String) -> Tween:
	var old: Tween = _hover_tweens.get(key)
	if old != null and old.is_valid():
		old.kill()
	var tw := create_tween()
	_hover_tweens[key] = tw
	return tw


## --oda-shot=hover fixture'ı: dört hover muamelesi tek karede.
func debug_hover_anchors() -> void:
	for id in _hotspots:
		_set_hover(id, true)


func _tween_rim(id: String, target: float) -> void:
	var mat: ShaderMaterial = _sprite_mats[id]
	_hover_tween("rim_" + id).tween_method(
		func(v: float) -> void: mat.set_shader_parameter("glow_strength", v),
		float(mat.get_shader_parameter("glow_strength")), target, HOVER_FADE_S)


func _on_hotspot_input(event: InputEvent, id: String) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	match id:
		"monitor":
			EventBus.tab_changed.emit("product")
		"phone":
			# Bekleyen olay VEYA latch'li mentor satırı varsa Events sayfasına; yoksa no-op.
			if EventGate.queue_size() > 0 or _mentor_line != "":
				EventBus.tab_changed.emit("events")
		"board":
			EventBus.tab_changed.emit("finance")   # WORKING: tek hedef
		"frames":
			# Milestone pseudo-dokümanı; center_viewport gövdesini kurar.
			EventBus.tab_changed.emit("milestones")


# =========================================================================
# İLK AÇILIŞ TURU
# =========================================================================

## main.gd MentorIntro kapanışında call_group ile çağırır. Bayrak user://settings.json'da.
func start_intro_tour_if_unseen() -> void:
	if bool(Settings.get_value("oda_intro_seen", false)):
		return
	if not visible or _tour != null:
		return
	# PanelLayer'a tam ekran monte edilir (bkz. oda_tour.gd); çapa geometrisi yine ODA'ya
	# göre ölçülsün diye sahne olarak `self` verilir.
	var tour_layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
	if tour_layer == null:
		push_error("[OdaView] GameShell/PanelLayer yok — tur monte edilemiyor")
		return
	_tour = OdaTourRef.new()
	_tour.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Sahne add_child'DAN ÖNCE verilir: _ready ilk adımı hemen yerleştirir.
	_tour.set_stage(self)
	tour_layer.add_child(_tour)
	_tour.tree_exited.connect(func() -> void: _tour = null)
