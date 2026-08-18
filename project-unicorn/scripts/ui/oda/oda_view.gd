extends Control

# ============================================================================
# ODA — merkez görünüm kontrolcüsü (ODA rework 2026-08-06).
# ============================================================================
# Varsayılan ekran: kurucunun masasının POV oda sahnesi. İlke: stok kabukta ·
# akış odada · derinlik sekmede — buradaki her yüzey bir KISAYOLDUR, hiçbir
# bilgi yalnız burada yaşamaz. Motor DOKUNULMAZ: bu dosya yalnız okur ve
# EventBus'a abone olur; tek yazdığı şey navigasyon (tab_changed) ve
# Settings'teki tur bayrağı.
#
# Katmanlar (alttan üste): SceneLayer (gündüz/gece sanat çifti, crossfade) →
# ObjectLayer (AtlasTexture obje sprite'ları — gece tint'i buraya biner) →
# FXLayer (lamba halesi additive, telefon kırmızı noktası) → InfoLayer
# (motor-çizimi bilgi yüzeyleri: monitör ekranı, pano kartları, kâğıtlar,
# çerçeve içleri, mesai çipi, Frank satırı) → HotspotLayer (görünmez tıklama
# hedefleri + boyalı-çapa glow çerçeveleri) → (OdaTour / milestone paneli).
#
# Yerleşimin TEK kaynağı OdaLayout (scripts/ui/oda/oda_layout.gd) — burada
# koordinat sabiti YOKTUR. Mikro-hareket task §7 listesiyle SINIRLIDIR; döngülü
# animasyon ve _process yok, her şey sinyal + tek-seferlik tween.
#
# Resident yaşam döngüsü: GameShell.tscn'de CenterViewport çocuğu, hiç
# free edilmez, sekme açılınca yalnız gizlenir — mentor satırı latch'i,
# kâğıt geliş-animasyonu hafızası ve gece durumu gezintide yaşar.

const OdaLayoutRef := preload("res://scripts/ui/oda/oda_layout.gd")
const OdaTourRef := preload("res://scripts/ui/oda/oda_tour.gd")
const RIM_SHADER := preload("res://scenes/desk/oda_rim_glow.gdshader")
const TEX_DAY := preload("res://assets/art/center_view/room_day_3840x2160.png")
const TEX_NIGHT := preload("res://assets/art/center_view/room_night_3840x2160.png")
const TEX_MONITOR := preload("res://assets/art/center_view/monitor_3840x2160.png")
const TEX_KEYBOARD := preload("res://assets/art/center_view/keyboard_3840x2160.png")
const TEX_PHONE := preload("res://assets/art/center_view/phone_3840x2160.png")
const TEX_LAMP := preload("res://assets/art/center_view/lamp_3840x2160.png")
const TEX_MUG := preload("res://assets/art/center_view/mug_3840x2160.png")
# Gece varyantları: monitörün emissive ekranı + lambanın yanan ampulü. Yalnız bu
# ikisinin gece hali FARKLI render edilir; mug/telefon/klavye gece tint'iyle
# yeterince oturuyor, ayrı katman taşımanın bedeli kadar değeri yok.
# monitor_night EMEKLİ (2026-08-17): mühürlü sahnede ekran gece de karanlık cam,
# gece monitörü = gündüz katmanı + ObjectLayer modulate. Gerekçe _apply_night_textures'ta.
const TEX_LAMP_NIGHT := preload("res://assets/art/center_view/lamp_night_3840x2160.png")

# --- # WORKING değerleri (Erdem F5 mühürler) --------------------------------
const FRAMES_CLICKABLE := true      # Erdem onayı 2026-08-06 (task metni kanon; eski kanon "pasif" derdi)
# Dört-durum ışık makinesi (kalite turu v2 / D6 — saatlik adım ÖLDÜ, titreme yok):
# GÜNDÜZ 07-17 (nötr) · AKŞAM 18 (ılık tint) · GECE 19-05 (sahne çifti) · ŞAFAK 06
# (serin tint). Mesai bloğu GECE'yi zorlar. Geçiş yalnız DURUM değişince, tek tween.
const LIGHT_FADE_S := 1.5           # her durum geçişinin crossfade süresi (D6: 1.5 sn)
const HOVER_FADE_S := 0.15          # hover glow aç/kapa
const BUZZ_S := 0.30                # telefon titreşimi süresi
const BUZZ_PX := 3.0                # titreşim genliği
const PAPER_ARRIVE_S := 0.35        # kâğıt geliş animasyonu
const MONITOR_BAR_S := 0.8          # ilerleme barının "sakin" tween'i
const PAPER_CAP := 3                # masadaki azami kâğıt (fazlası +N çipi)
const SCREEN_GLOW_NIGHT_A := 0.35   # gece ekran parlaması (additive) alfası

signal anchor_clicked(anchor_id: String)

# Katman / düğüm referansları (kod-kurulu)
var _day_art: TextureRect
var _night_art: TextureRect
var _surround: ColorRect            # 16:9 tavanının iki yanında kalan boşluğun plakası
var _scene_layer: Control
var _object_layer: Control
var _sprites: Dictionary = {}          # id -> TextureRect
var _sprite_mats: Dictionary = {}      # id -> ShaderMaterial (monitor/phone)
var _phone_dot: Panel
var _info_layer: Control
# D4 sarmalayıcıları: host-türetimli her yüzeyin kırpan dış Control'ü.
var _monitor_wrap: Control
var _screen_glow: TextureRect          # gece ekran parlaması (additive — stylebox gölgesi DEĞİL)
var _board_wraps: Dictionary = {}      # "goal"/"market"/"dates"/"postit" -> Control
var _monitor_screen: PanelContainer
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
var _mon_track: Panel
var _mon_fill: Panel
var _phone_glass: Control              # DÖNMÜŞ kırpan sarmalayıcı (D2: camda yalnız bildirim)
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
var _postit: PanelContainer
var _postit_line: Label
var _overtime_chip: PanelContainer
var _overtime_label: Label
var _frame_slots: Array[Control] = []
var _papers_box: Control
var _hotspots: Dictionary = {}         # id -> Control
var _frame_outlines: Array[Panel] = [] # çerçeve başına border-only hover halkası (F2)

# Durum
var _is_night: bool = false
var _light_state: StringName = &""     # "" = henüz kurulmadı (ilk _eval_light hep uygular)
var _mentor_line: String = ""
var _paper_cards: Dictionary = {}      # paper_id -> PanelContainer
var _seen_paper_ids: Dictionary = {}   # geliş animasyonu tek-seferlik bekçisi
var _paper_overflow: int = 0
var _tour: Control = null
var _debug_papers: bool = false        # --oda-shot=night fixture'ı

# Tween sahipleri (kill-and-replace — asla üst üste binmez)
var _night_tween: Tween
var _bar_tween: Tween
var _buzz_tween: Tween
var _hover_tweens: Dictionary = {}


func _ready() -> void:
	add_to_group("oda_view")
	_build_scene_layer()
	_build_object_layer()
	_build_fx_layer()
	_build_info_layer()
	_build_hotspot_layer()
	_connect_signals()
	resized.connect(_relayout)
	visibility_changed.connect(_on_visibility_changed)
	# İlk kadraj: boyut _ready'de henüz oturmamış olabilir — bir frame ertele.
	call_deferred("_first_paint")


func _exit_tree() -> void:
	_disconnect_signals()


func _first_paint() -> void:
	_relayout()
	_refresh_all()
	_eval_light(true)


# =========================================================================
# KURULUM — katmanlar
# =========================================================================

func _mk_layer(layer_name: String) -> Control:
	var c := Control.new()
	c.name = layer_name
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	return c


func _build_scene_layer() -> void:
	_scene_layer = _mk_layer("SceneLayer")
	# Kuşatma plakası: oda 16:9 tavanına oturduğu için ultra-geniş ekranlarda iki
	# yanda boşluk kalır (OdaLayout.room_rect). Krem ViewportPanel şeritleri koyu
	# bir odanın yanında hata gibi okunurdu; BG_ART zaten "sanat plakası" için
	# adlandırılmış token. _scene_layer'ın İÇİNDE, çünkü gece tint'i (modulate
	# tween'i) kuşatmayı da odayla birlikte karartmalı.
	_surround = ColorRect.new()
	_surround.name = "Surround"
	_surround.color = UiTokens.BG_ART
	_surround.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_surround.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scene_layer.add_child(_surround)

	_day_art = _mk_scene_art("DayArt", TEX_DAY)
	_night_art = _mk_scene_art("NightArt", TEX_NIGHT)
	_night_art.modulate.a = 0.0
	_night_art.visible = false


func _mk_scene_art(art_name: String, tex: Texture2D) -> TextureRect:
	# MeetingScene reçetesi: IGNORE_SIZE + KEEP_ASPECT_COVERED = kaplama +
	# merkezli kırpma. Mipmap'li filtre: 4K→~1400px küçültmede shimmer olmasın.
	# FULL_RECT preset'i KALDIRILDI: sanat artık OdaLayout.room_rect'e oturuyor ve
	# rect'i _relayout sürüyor — çapalarla TEK rect'i paylaşmalı, yoksa boyama ile
	# tıklanabilir çapalar ultra-geniş ekranda birbirinden ayrışır.
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
	_object_layer = _mk_layer("ObjectLayer")
	# Çizim sırası: lamba (arka) → monitör → klavye → mug → telefon (en ön).
	# Klavye monitörden SONRA: monitör ayağının önünde duruyor.
	_sprites["lamp"] = _mk_object_sprite("Lamp", TEX_LAMP, "lamp", false)
	_sprites["monitor"] = _mk_object_sprite("Monitor", TEX_MONITOR, "monitor", true)
	_sprites["keyboard"] = _mk_object_sprite("Keyboard", TEX_KEYBOARD, "keyboard", false)
	_sprites["mug"] = _mk_object_sprite("Mug", TEX_MUG, "mug", false)
	_sprites["phone"] = _mk_object_sprite("Phone", TEX_PHONE, "phone", true)


func _mk_object_sprite(node_name: String, tex: Texture2D, layout_id: String, hoverable: bool) -> TextureRect:
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	# Region 3840-uzayında yazılı; size_limit=2048 importu kaynağı küçültmüş
	# olabilir — gerçek doku boyutuna ölçekle.
	var imported_scale: float = tex.get_width() / OdaLayoutRef.ART.x
	atlas.region = OdaLayoutRef.padded_region(layout_id, imported_scale)
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
	return tr_node


func _build_fx_layer() -> void:
	var fx := _mk_layer("FXLayer")
	# LAMBA HALESİ KALDIRILDI (2026-08-18, Erdem). Burada additive radyal bir
	# gradyan (LampGlow) vardı ve gece lamba sprite'ının ÜSTÜNE biniyordu. Sorun
	# şuydu: gövde düz siyah ama hale onun üzerine ekleniyor, dolayısıyla siyah
	# abajur sütlü/yarı saydam görünüyor — sanki lambanın KENDİSİ parlıyormuş gibi.
	# Sözleşme bunun tersi: gövde her iki modda düz siyah kalır, gece yalnız AMPUL
	# yanar. Işığı taşıyan iki şey zaten var ve ikisi de gövdeyi boyamıyor:
	# `lamp_night` katmanındaki emissive ampul + gece plakasına baked ışık havuzu.
	# Ölçümle doğrulandı: her iki lamba PNG'sinde soluk-alfa (1..39) pikseli SIFIR,
	# yani sanatta hiçbir parlama yok — görülen hale %100 bu node'du.
	# FXLayer KALIYOR: PhoneDot burada yaşıyor (silinirse onun audit yolu değişir).
	# Telefon kırmızı noktası: bekleyen olay latch'i (animasyon değil, durum).
	_phone_dot = UiFactory.make_dot(UiTokens.ODA_BADGE_BG, 10)
	_phone_dot.name = "PhoneDot"
	_phone_dot.visible = false
	fx.add_child(_phone_dot)


func _build_info_layer() -> void:
	_info_layer = _mk_layer("InfoLayer")
	_build_screen_glow()
	_build_monitor_screen()
	_build_phone_glass()
	_build_board_cards()
	_build_frames()
	_build_overtime_chip()
	_papers_box = Control.new()
	_papers_box.name = "PapersBox"
	_papers_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_papers_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_info_layer.add_child(_papers_box)


func _mk_surface_wrap(parent: Control, wrap_name: String) -> Control:
	# D4.2 sarmalayıcı kalıbı: düz Control min-size YAYMAZ → set_size'ın minimuma
	# yukarı clamp'i taşma üretemez; clip_contents içteki panelin stylebox'ı dahil
	# her şeyi kırpar. İçerik kısaltma (satır cap + clip_text) birincil mekanizma,
	# bu sarmalayıcı yapısal emniyettir.
	var wrap := Control.new()
	wrap.name = wrap_name
	wrap.clip_contents = true
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(wrap)
	return wrap


func _build_screen_glow() -> void:
	# Gece ekran parlaması (görev §7) — additive radyal gradyan,
	# monitör sarmalayıcısının DIŞINDA/arkasında (stylebox gölgesi olsaydı D4
	# sarmalayıcısı yarım-glow'a kırpardı). Gündüz alfa 0.
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
	# D4: cam dolu okunur — başlık DISPLAY, 2×2 stat grid'i (TITLE değerler),
	# mono alt-durum satırı. Ölü siyah alan kalmaz; sığmazsa DUR-RAPOR (taban 9px).
	_monitor_wrap = _mk_surface_wrap(_info_layer, "MonitorWrap")
	_monitor_screen = PanelContainer.new()
	_monitor_screen.name = "MonitorScreen"
	_monitor_screen.theme_type_variation = &"OdaMonitorScreen"
	_monitor_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_monitor_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_monitor_wrap.add_child(_monitor_screen)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_monitor_screen.add_child(col)
	var head := HBoxContainer.new()
	col.add_child(head)
	_mon_header = UiFactory.make_label("", &"OdaScreenCaption")
	head.add_child(_mon_header)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
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
	_mon_cells.clear()
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
	# Esnek dolgu: grid gizliyken (build/boş yüz) boşluğu bu yutar — içerik üstte
	# toplanır, ilerleme bloğu cam ALTINA oturur.
	_mon_slack = Control.new()
	_mon_slack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_mon_slack.visible = false
	col.add_child(_mon_slack)
	# İlerleme bloğu (yalnız build yüzü): etiket + Track/Fill (BuildHUD deseni —
	# runtime stylebox, renkler UiTokens'tan; ledger §A yasal).
	_mon_progress_block = VBoxContainer.new()
	_mon_progress_block.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	col.add_child(_mon_progress_block)
	var prog_label := UiFactory.make_label("", &"OdaScreenCaption")
	prog_label.name = "ProgLabel"
	_mon_progress_block.add_child(prog_label)
	_mon_track = Panel.new()
	_mon_track.custom_minimum_size = Vector2(0, 10)
	var sb_track := StyleBoxFlat.new()
	sb_track.bg_color = UiTokens.ODA_VEIL_SOFT
	sb_track.set_corner_radius_all(UiTokens.RADIUS_XS)
	_mon_track.add_theme_stylebox_override("panel", sb_track)
	_mon_progress_block.add_child(_mon_track)
	_mon_fill = Panel.new()
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = UiTokens.ODA_ACCENT
	sb_fill.set_corner_radius_all(UiTokens.RADIUS_XS)
	_mon_fill.add_theme_stylebox_override("panel", sb_fill)
	_mon_fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mon_fill.anchor_right = 0.0
	_mon_track.add_child(_mon_fill)
	# Alt durum satırı (canlı yüz): "sistem sakin · uyarı yok" / uyarı hali.
	_mon_footer = UiFactory.make_label("", &"OdaScreenCaption")
	col.add_child(_mon_footer)


func _build_phone_glass() -> void:
	# D2: camda YALNIZ bildirim — kırmızı nokta + "FRANK" mikro etiket. Replik
	# camda YOK; tam mesaj tıklamayla document model'e (Events sayfası) gider.
	# Sarmalayıcı KENDİSİ döner ve kırpar (AABB değil — kırpma yerel/dönmüş
	# uzayda cama oturur); pivot her boyut atamasından sonra yeniden kurulur.
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
	# D4: her pano kartı kırpan sarmalayıcıda, rect'i board_inner HOST'undan türer
	# (BOARD_REL) — mantar yüzeyden taşmak yapısal olarak imkânsız.
	# Hedef kartı — mockup: italik serif etiket + iri figür + ince bar.
	_board_goal = PanelContainer.new()
	_board_goal.name = "BoardGoal"
	_board_goal.theme_type_variation = &"OdaBoardCard"
	_board_goal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board_goal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board_wraps["goal"] = _mk_surface_wrap(_info_layer, "GoalWrap")
	_board_wraps["goal"].add_child(_board_goal)
	var gcol := VBoxContainer.new()
	gcol.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	_board_goal.add_child(gcol)
	# F5 turu (2026-08-17): hedef kartı panonun REGISTER'ına alındı. Eskiden tek
	# başına serif-deck etiketi + `MetricValueInk` (18px sans) taşıyordu, yani BİR
	# CÜMLE büyük-figür yuvasında oturuyordu — o yuva SAYI içindir (P3-kapandı
	# dalında aynı alan format_money taşıyor, doğru kullanımı o). Kart bu yüzden
	# bağırıyordu. Artık pazar payı / tarihler kalıbı birebir: başlık HBox'ı
	# (mono, BÜYÜK HARF, değer SAĞA yaslı) → satır → ince çizgi.
	# Kullanılan varyasyonların HEPSİ frozen temada zaten var — unfreeze YOK.
	var ghead := HBoxContainer.new()
	gcol.add_child(ghead)
	_goal_label = UiFactory.make_label("", &"NewsMeta")
	ghead.add_child(_goal_label)
	var gsp := Control.new()
	gsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ghead.add_child(gsp)
	_goal_sub = UiFactory.make_label("", &"NewsMeta")
	ghead.add_child(_goal_sub)
	_goal_value = UiFactory.make_label("", &"RowMeta")
	# clip_text + expand-fill = satır grameri (lig/tarih satırlarıyla aynı).
	# Bunun yan faydası gerçek bir kırığı kapatmak: hedef kartının HİÇBİR
	# etiketinde ne clip_text ne autowrap vardı, yani uzun bir P2/P3 değeri
	# zarifçe kısalmak yerine sarmalayıcı tarafından SESSİZCE kesiliyordu.
	_goal_value.clip_text = true
	_goal_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gcol.add_child(_goal_value)
	_goal_bar = ProgressBar.new()
	_goal_bar.theme_type_variation = &"BuildProgress"
	# 6 → 3 px: dolu amber şerit bütün panonun en ağır öğesiydi ve başka hiçbir
	# kartta karşılığı yok. `BuildProgress` stylebox'ları FROZEN temada, o yüzden
	# renk/radius dokunulmuyor — yükseklik tek serbest değişken, ve 3px'te
	# radius-3 dolgu şerit değil ÇİZGİ okuyor.
	_goal_bar.custom_minimum_size = Vector2(0, 3)
	_goal_bar.show_percentage = false
	_goal_bar.max_value = 100.0
	gcol.add_child(_goal_bar)
	# Pazar payı kartı.
	_board_league = PanelContainer.new()
	_board_league.name = "BoardLeague"
	_board_league.theme_type_variation = &"OdaBoardCard"
	_board_league.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board_league.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board_wraps["market"] = _mk_surface_wrap(_info_layer, "MarketWrap")
	_board_wraps["market"].add_child(_board_league)
	var lcol := VBoxContainer.new()
	lcol.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	_board_league.add_child(lcol)
	var lhead := HBoxContainer.new()
	lcol.add_child(lhead)
	_league_title = UiFactory.make_label("", &"NewsMeta")
	lhead.add_child(_league_title)
	var lsp := Control.new()
	lsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lhead.add_child(lsp)
	_league_rank = UiFactory.make_label("", &"NewsMeta")
	lhead.add_child(_league_rank)
	_league_rows = VBoxContainer.new()
	_league_rows.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	lcol.add_child(_league_rows)
	# İşaretli tarihler.
	_board_dates = PanelContainer.new()
	_board_dates.name = "BoardDates"
	_board_dates.theme_type_variation = &"OdaBoardCard"
	_board_dates.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board_dates.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board_wraps["dates"] = _mk_surface_wrap(_info_layer, "DatesWrap")
	_board_wraps["dates"].add_child(_board_dates)
	var dcol := VBoxContainer.new()
	dcol.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	_board_dates.add_child(dcol)
	_dates_title = UiFactory.make_label("", &"NewsMeta")
	dcol.add_child(_dates_title)
	_dates_rows = VBoxContainer.new()
	_dates_rows.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	dcol.add_child(_dates_rows)
	# İstisna post-it'i (dönüş SARMALAYICIDA — klip yerel/dönmüş uzayda oturur).
	_postit = PanelContainer.new()
	_postit.name = "PostIt"
	_postit.theme_type_variation = &"OdaPostIt"
	_postit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_postit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board_wraps["postit"] = _mk_surface_wrap(_info_layer, "PostItWrap")
	_board_wraps["postit"].visible = false
	_board_wraps["postit"].add_child(_postit)
	_postit_line = UiFactory.make_label("", &"QuoteSerif")
	_postit_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_postit.add_child(_postit_line)


func _build_frames() -> void:
	# D4+D5: slot = kırpan sarmalayıcı; rect'i boyalı çerçevenin DIŞ kutusundan
	# FRAME_DOC_INSET ile türetilir (ahşap hep görünür — "yapıştırılmış A4" ölür).
	for i in 3:
		var slot := _mk_surface_wrap(_info_layer, "FrameSlot%d" % i)
		_frame_slots.append(slot)


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
	var hs_layer := _mk_layer("HotspotLayer")
	hs_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	# Çerçeve hover halkaları: çerçeve BAŞINA border-only outline (bölge
	# dikdörtgeni ÖLDÜ — F2; OdaAnchorGlow artık gölgesiz/salt-kenar).
	for i in 3:
		var outline := Panel.new()
		outline.name = "FrameOutline%d" % i
		outline.theme_type_variation = &"OdaAnchorGlow"
		outline.modulate.a = 0.0
		outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hs_layer.add_child(outline)
		_frame_outlines.append(outline)
	_mk_hotspot(hs_layer, "monitor")
	var phone_hs := _mk_hotspot(hs_layer, "phone")
	phone_hs.add_to_group("oda_phone_anchor")  # event_modal telefon-orijin tween'i buradan bulur
	_mk_hotspot(hs_layer, "board")
	if FRAMES_CLICKABLE:
		_mk_hotspot(hs_layer, "frames")
	# Pencere BİLEREK hotspot'suz (kanon: tıklanmaz, yalnız zamanı söyler).


func _mk_hotspot(parent: Control, id: String) -> Control:
	var hs := Control.new()
	hs.name = "Hotspot" + id.capitalize()
	hs.mouse_filter = Control.MOUSE_FILTER_STOP
	hs.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hs.mouse_entered.connect(_on_hotspot_entered.bind(id))
	hs.mouse_exited.connect(_on_hotspot_exited.bind(id))
	hs.gui_input.connect(_on_hotspot_input.bind(id))
	parent.add_child(hs)
	_hotspots[id] = hs
	return hs


# =========================================================================
# SİNYALLER
# =========================================================================

func _connect_signals() -> void:
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.day_advanced.connect(_on_day_advanced)
	EventBus.mrr_changed.connect(_on_mrr_changed)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	EventBus.build_progress_changed.connect(_on_build_progress_changed)
	EventBus.event_triggered.connect(_on_event_triggered)
	EventBus.event_resolved.connect(_on_event_resolved)
	EventBus.mentor_advisory_changed.connect(_on_mentor_advisory)
	EventBus.hr_day_processed.connect(_on_hr_day_processed)
	EventBus.morale_changed.connect(_on_morale_changed)
	EventBus.rival_advanced.connect(_on_rivals_changed)
	EventBus.rival_status_changed.connect(_on_rival_status_changed)
	EventBus.sheet_granted.connect(_on_sheet_moved)
	EventBus.sheet_expired.connect(_on_sheet_moved)
	EventBus.sheet_walked.connect(_on_sheet_moved)
	EventBus.customer_added.connect(_on_customer_moved)
	EventBus.customer_removed.connect(_on_customer_moved)
	EventBus.customer_health_changed.connect(_on_customer_health)
	EventBus.language_changed.connect(_on_language_changed)
	EventBus.palette_changed.connect(_on_palette_changed)


func _disconnect_signals() -> void:
	EventBus.hour_changed.disconnect(_on_hour_changed)
	EventBus.day_advanced.disconnect(_on_day_advanced)
	EventBus.mrr_changed.disconnect(_on_mrr_changed)
	EventBus.phase_changed.disconnect(_on_phase_changed)
	EventBus.build_phase_changed.disconnect(_on_build_phase_changed)
	EventBus.build_progress_changed.disconnect(_on_build_progress_changed)
	EventBus.event_triggered.disconnect(_on_event_triggered)
	EventBus.event_resolved.disconnect(_on_event_resolved)
	EventBus.mentor_advisory_changed.disconnect(_on_mentor_advisory)
	EventBus.hr_day_processed.disconnect(_on_hr_day_processed)
	EventBus.morale_changed.disconnect(_on_morale_changed)
	EventBus.rival_advanced.disconnect(_on_rivals_changed)
	EventBus.rival_status_changed.disconnect(_on_rival_status_changed)
	EventBus.sheet_granted.disconnect(_on_sheet_moved)
	EventBus.sheet_expired.disconnect(_on_sheet_moved)
	EventBus.sheet_walked.disconnect(_on_sheet_moved)
	EventBus.customer_added.disconnect(_on_customer_moved)
	EventBus.customer_removed.disconnect(_on_customer_moved)
	EventBus.customer_health_changed.disconnect(_on_customer_health)
	EventBus.language_changed.disconnect(_on_language_changed)
	EventBus.palette_changed.disconnect(_on_palette_changed)


func _on_hour_changed(_hour: int) -> void:
	_eval_light(false)
	_refresh_overtime_chip()  # mesai sinyali yok — saatlik poll (motor boşluğu)

func _on_day_advanced(_d: int) -> void:
	_refresh_monitor()
	_refresh_dates()
	_refresh_papers()
	_refresh_frames()

func _on_mrr_changed(_v: int) -> void:
	_refresh_monitor()
	_refresh_goal()
	_refresh_league()  # pazar payı MRR'dan türer (Fix 3 bağlaması) — kıymık anında oynasın

func _on_phase_changed(_p: int) -> void:
	_refresh_goal()
	_refresh_papers()
	_refresh_frames()

func _on_build_phase_changed(_p: String) -> void:
	_refresh_monitor()
	_refresh_league()  # aktif sub-type build'le değişebilir

func _on_build_progress_changed() -> void:
	_refresh_monitor()

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

func _on_rivals_changed() -> void:
	_refresh_league()

func _on_rival_status_changed(_id: String, _s: String) -> void:
	_refresh_league()

func _on_sheet_moved(_vc: String) -> void:
	_refresh_papers()
	_refresh_dates()

func _on_customer_moved(_id: String) -> void:
	_refresh_papers()
	_refresh_dates()

func _on_customer_health(_id: String, _phase: String) -> void:
	_refresh_papers()
	_refresh_dates()

func _on_language_changed(_locale: String) -> void:
	_refresh_all()

func _on_palette_changed(_cb: bool) -> void:
	# Renk körü paleti takas edildi. ODA'nın iki semantik rengi de TÜRETİLMİŞ —
	# monitör çipinin sağlık noktası _refresh_monitor'da, masa kâğıtlarının
	# noktaları _refresh_papers'ta her seferinde token'dan okunur — yani tam
	# tazeleme yeterli; yerinde boyanacak ayrı bir override yok.
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
	# Boyama ve çapalar TEK rect'i paylaşır. 16:9 ve daha dar viewport'ta bu
	# rect tam viewport'tur (bugünkü davranış), daha geniştekinde ortalanmış
	# 16:9 bandıdır — cover_transform da aynı rect'ten türediği için sanat ile
	# çapalar yapısal olarak ayrışamaz.
	var room: Rect2 = OdaLayoutRef.room_rect(view)
	for art in [_day_art, _night_art]:
		art.position = room.position
		art.size = room.size
	for id in ["monitor", "keyboard", "phone", "lamp", "mug"]:
		var r: Rect2 = OdaLayoutRef.place(OdaLayoutRef.padded_target(id), view)
		var spr: TextureRect = _sprites[id]
		spr.position = r.position
		spr.size = r.size
	# Telefon noktası: telefon içerik-kutusunun sağ-üst köşesi.
	var phone_r: Rect2 = OdaLayoutRef.place(OdaLayoutRef.RECTS["phone"], view)
	_phone_dot.position = phone_r.position + Vector2(phone_r.size.x - 8.0, -4.0)
	# ── D4: host-türetimli yüzeyler — hepsi rect_in üzerinden, mutlak rect yok ──
	# Monitör camı: sprite İÇERİK rect'inden (padded_target DEĞİL — pad kaydırır).
	var mon_rect: Rect2 = OdaLayoutRef.place(OdaLayoutRef.RECTS["monitor"], view)
	var glass: Rect2 = OdaLayoutRef.rect_in(mon_rect, OdaLayoutRef.MONITOR_GLASS_REL)
	_set_rect(_monitor_wrap, glass)
	_set_rect(_screen_glow, glass.grow(12.0))
	# Telefon camı: dönmüş sarmalayıcı — pivot her boyut atamasından SONRA kurulur
	# (pivot_offset piksel cinsindendir, resize'da kendi kendine güncellenmez).
	var pglass_size: Vector2 = phone_r.size * OdaLayoutRef.PHONE_GLASS_SIZE_REL
	var pglass_center: Vector2 = phone_r.position + phone_r.size * OdaLayoutRef.PHONE_GLASS_CENTER_REL
	_phone_glass.size = pglass_size
	_phone_glass.pivot_offset = pglass_size * 0.5
	_phone_glass.position = pglass_center - pglass_size * 0.5
	_phone_glass.rotation = deg_to_rad(OdaLayoutRef.PHONE_GLASS_ANGLE_DEG)
	# Pano kartları: board_inner HOST'undan.
	var board: Rect2 = OdaLayoutRef.place(OdaLayoutRef.RECTS["board_inner"], view)
	for key in _board_wraps:
		_set_rect(_board_wraps[key], OdaLayoutRef.rect_in(board, OdaLayoutRef.BOARD_REL[key]))
	var postit_wrap: Control = _board_wraps["postit"]
	postit_wrap.pivot_offset = postit_wrap.size * 0.5
	postit_wrap.rotation_degrees = -2.0
	# Çerçeve belgeleri: dış kutu → FRAME_DOC_INSET içerlemesi.
	for i in 3:
		var outer: Rect2 = OdaLayoutRef.place(OdaLayoutRef.RECTS["frame_outer_%d" % i], view)
		_set_rect(_frame_slots[i], OdaLayoutRef.frame_doc_rect(outer))
	# Host'suz tek yüzey: mesai çipi (place_clamped'in kalan tek kullanıcısı).
	_place_clamped(_overtime_chip, "overtime_chip")
	# Hotspot'lar: obje/bölge rect'leri (padsız içerik kutuları).
	_hotspot_rect("monitor", OdaLayoutRef.RECTS["monitor"], view)
	_hotspot_rect("phone", OdaLayoutRef.RECTS["phone"], view)
	_hotspot_rect("board", OdaLayoutRef.RECTS["board_outer"], view)
	if _hotspots.has("frames"):
		_hotspot_rect("frames", OdaLayoutRef.RECTS["frames_band"], view)
	# Çerçeve hover halkaları: boyalı çerçevenin DIŞ kutusuna oturur (piksel
	# uzayında grow — normalize grow x/y'yi eşitsiz ölçeklerdi).
	for i in 3:
		_set_rect(_frame_outlines[i],
			OdaLayoutRef.place(OdaLayoutRef.RECTS["frame_outer_%d" % i], view).grow(4.0))
	_layout_papers()


func _set_rect(node: Control, r: Rect2) -> void:
	node.position = r.position
	node.size = r.size

func _place_clamped(node: Control, id: String) -> void:
	_set_rect(node, OdaLayoutRef.place_clamped(OdaLayoutRef.RECTS[id], size))

func _hotspot_rect(id: String, n: Rect2, view: Vector2) -> void:
	var r: Rect2 = OdaLayoutRef.place(n, view)
	var hs: Control = _hotspots[id]
	hs.position = r.position
	hs.size = r.size

func _layout_papers() -> void:
	var idx: int = 0
	for paper_id in _paper_cards:
		if idx >= OdaLayoutRef.PAPER_SLOTS.size():
			break
		var slot: Dictionary = OdaLayoutRef.PAPER_SLOTS[idx]
		var r: Rect2 = OdaLayoutRef.place(slot["rect"], size)
		var card: PanelContainer = _paper_cards[paper_id]
		card.position = r.position
		card.custom_minimum_size = Vector2(r.size.x, 0)
		card.size = Vector2(r.size.x, 0)
		card.rotation_degrees = float(slot["rot"])
		idx += 1


# =========================================================================
# IŞIK DURUM MAKİNESİ (kalite turu v2 / D6) — dört durum, geçiş yalnız durum
# sınırında (saatlik titreme yapısal olarak imkânsız: aynı durumda tween atılmaz).
# =========================================================================

func _any_overtime_active() -> bool:
	for dept in HRConstants.DEPARTMENTS:
		if HROvertimeSystem.is_active(dept):
			return true
	return false


func _light_state_for_hour(hour: int) -> StringName:
	# Mesai bloğu GECE'yi zorlar (task §3 kuralı — mesai gecesi lambası).
	if _any_overtime_active():
		return &"night"
	if hour >= 19 or hour <= 5:
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
	# Objeler sahne tint'ini de yer. Suluboyada objeler kendi ışığıyla boyanmıştı ve
	# akşam/şafakta tint'siz kalmaları yutulabiliyordu; prosedürel katmanlar plakayla
	# AYNI ışıktan render edildiği için tint'siz obje turuncu odanın üstünde gündüz
	# gibi durur. Çarpım: gece ODA_NIGHT_TINT, akşam/şafak sahne tint'i, gündüz beyaz.
	var obj_tint: Color = (UiTokens.ODA_NIGHT_TINT if night else Color.WHITE) * scene_tint
	_apply_night_textures(night)
	if _night_tween != null and _night_tween.is_valid():
		_night_tween.kill()
	if instant or not is_visible_in_tree():
		_night_art.visible = night
		_night_art.modulate.a = target_a
		_object_layer.modulate = obj_tint
		_scene_layer.modulate = scene_tint
		_apply_screen_glow(night, true)
		return
	_night_art.visible = true
	_night_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_night_tween.tween_property(_night_art, "modulate:a", target_a, LIGHT_FADE_S)
	_night_tween.tween_property(_object_layer, "modulate", obj_tint, LIGHT_FADE_S)
	_night_tween.tween_property(_scene_layer, "modulate", scene_tint, LIGHT_FADE_S)
	_apply_screen_glow(night, false)
	# Gündüz-quad'ı kapatma fade bitiminde (tek kare değişimi kuyruğunda erir).
	_night_tween.chain().tween_callback(func() -> void:
		if not _is_night:
			_night_art.visible = false
	)


func _apply_night_textures(night: bool) -> void:
	# YALNIZ LAMBA gece ayrı render edilir. Bunun sebebi ölçüldü, tercih değil:
	# lambanın gece/gündüz kanal oranı (1.72, 1.37, 0.89) — yani ampul KENDİ ışığıyla
	# aydınlandığı için bazı kanallarda 1'in ÜSTÜNDE. Bir multiply (modulate) 1'in
	# üstüne çıkamaz, o yüzden lamba ayrı katman olmak ZORUNDA.
	# MONİTÖR 2026-08-17'de bu listeden ÇIKTI: mühürlü sahnede ekran her iki modda da
	# KARANLIK CAM (emissive 0x000000) — içeriği oyun basıyor — dolayısıyla gece
	# monitörü gündüz katmanının ObjectLayer modulate'i altındaki hâlidir ve
	# monitor_night_3840x2160.png EMEKLİ EDİLDİ. Ölçülen oran (0.906, 0.783, 0.621),
	# hepsi < 1, yani multiply ile birebir temsil edilebiliyor → UiTokens.ODA_NIGHT_TINT.
	# Region aynı kalır, çünkü her iki varyant da aynı kameradan aynı kanvasa çizildi.
	# imported_scale yeniden hesaplanır: size_limit varyantları farklı ölçekleyebilir.
	var swap := {
		"lamp": TEX_LAMP_NIGHT if night else TEX_LAMP,
	}
	for id in swap:
		var spr: TextureRect = _sprites.get(id)
		if spr == null:
			continue
		var atlas := spr.texture as AtlasTexture
		if atlas == null:
			continue
		var tex: Texture2D = swap[id]
		if atlas.atlas == tex:
			continue
		atlas.atlas = tex
		atlas.region = OdaLayoutRef.padded_region(id, tex.get_width() / OdaLayoutRef.ART.x)


func _apply_screen_glow(night: bool, instant: bool) -> void:
	# Gece ekran parlaması — additive node. Stylebox gölgesi
	# DEĞİL: D4 sarmalayıcısı onu yarım-glow'a kırpardı.
	if _screen_glow == null:
		return
	var target: float = SCREEN_GLOW_NIGHT_A if night else 0.0
	if instant or not is_visible_in_tree():
		_screen_glow.modulate.a = target
		return
	var tw := create_tween()
	tw.tween_property(_screen_glow, "modulate:a", target, LIGHT_FADE_S)


# =========================================================================
# MONİTÖR (çapa 1) — build yüzü / canlı ürün yüzü / boş yüz. Ekran asla boş değil.
# =========================================================================

func _refresh_monitor() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	var prog_label: Label = _mon_progress_block.get_node("ProgLabel")
	if b != null and not b.is_bug_sprint:
		# BUILD YÜZÜ: başlık + sorumlu satırı, esnek dolgu, ilerleme CAM ALTINDA.
		# Faz etiketi sunum kopyasıdır (BuildHUD'un private const'una import yok).
		# Dil yasası: build→geliştirme ("build" kabul edilen loanword setinde değil).
		var phase_labels := {"iteration": "TASARIM", "development": "GELİŞTİRME", "bugfix": "BETA"}
		var bname: String = b.product_name if b.product_name != "" else tr("ODA_MONITOR_IDLE")
		_mon_header.text = UiTokens.tr_upper(bname)
		_mon_chip.visible = true
		_mon_chip_dot.visible = false
		_mon_chip_label.text = String(phase_labels.get(b.current_phase, ""))
		_mon_chip_label.add_theme_color_override("font_color", UiTokens.ODA_ACCENT)
		_mon_title.text = tr("ODA_MONITOR_BUILD_TITLE").format({"product": bname})
		var lead: String = tr("ODA_MONITOR_LEAD_FOUNDER")
		if b.lead_engineer_id != "" and b.lead_engineer_id != "founder":
			var emp: Character = CharacterRegistry.get_character(b.lead_engineer_id)
			if emp != null:
				lead = emp.character_name
		_mon_meta.visible = true
		_mon_meta.text = UiTokens.tr_upper(tr("ODA_MONITOR_BUILD_META").format({"days": maxi(0, ProductSystem.build_days_remaining()), "lead": lead}))
		_mon_grid.visible = false
		_mon_slack.visible = true
		_mon_footer.visible = false
		_mon_progress_block.visible = true
		prog_label.text = UiTokens.tr_upper(tr("ODA_MONITOR_PROGRESS"))
		# Yüzdenin tek evi (UiTokens.build_percent) — monitör çubuğu da oradan beslenir ki
		# oyuncu odadan sekmeye geçtiğinde dolgu bir anda yer değiştirmesin.
		_animate_bar(float(UiTokens.build_percent(ProductSystem.build_progress())) / 100.0)
		return
	if bool(GameState.get_flag("mvp_shipped", false)):
		# CANLI ÜRÜN YÜZÜ (D4: cam DOLU — 2×2 stat grid'i + alt durum satırı).
		var pname: String = String(GameState.get_flag("mvp_product_name", GameState.company_name))
		var ver: int = int(GameState.get_flag("mvp_version", 1))
		_mon_header.text = "%s · V%d" % [UiTokens.tr_upper(pname), ver]
		_mon_chip.visible = true
		var healthy: bool = ProductSystem.health_state() == "saglikli"
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
		# Alt satır üç durumu ayırır — "sağlıklı" TEK BAŞINA sessizliği hak etmez:
		# health_state() bir ORAN testidir (etkin/ham kararlılık), 70 kararlılıkta
		# onlarca canlı hataya kadar "saglikli" döner. Sayıyı ayrı terim yapmazsak
		# cam üstündeki HATA hücresi ile hemen altındaki satır birbirini yalanlar.
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


func _animate_bar(fraction: float) -> void:
	# "Sakin ilerleme hareketi" (mikro-hareket listesi): saatlik build_progress
	# sinyalinde bar yeni değere kısa SINE tween'iyle süzülür. Kill-and-replace.
	var target: float = clampf(fraction, 0.0, 1.0)
	if _bar_tween != null and _bar_tween.is_valid():
		_bar_tween.kill()
	if not is_visible_in_tree():
		_mon_fill.anchor_right = target
		return
	_bar_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_bar_tween.tween_property(_mon_fill, "anchor_right", target, MONITOR_BAR_S)


# =========================================================================
# TELEFON (çapa 2)
# =========================================================================

func _refresh_phone_dot() -> void:
	_phone_dot.visible = EventManager.get_queue_size() > 0


func _refresh_phone_notice() -> void:
	# D2: camda YALNIZ bildirim (nokta + mentor adı). Tam mesaj tıklamayla
	# Events sayfasına (center_viewport, get_mentor_line() üzerinden).
	if _mentor_line == "":
		_phone_glass.visible = false
		return
	_phone_glass.visible = true
	var tag: String = "FRANK"
	var mentor: Character = CharacterRegistry.get_mentor()
	if mentor != null and mentor.character_name != "":
		tag = UiTokens.tr_upper(mentor.character_name.get_slice(" ", 0))
	_phone_glass_label.text = tag


func get_mentor_line() -> String:
	# Latch'in tek evi burası (motor satırı saklamıyor — boşluk defterinde);
	# Events sayfası tam mesajı bu getter'dan okur.
	return _mentor_line


func _play_phone_buzz() -> void:
	# TEK titreşim + rim parıltısı; olay başına bir kez, sonra hareketsiz.
	if not is_visible_in_tree():
		return
	var phone: TextureRect = _sprites["phone"]
	var mat: ShaderMaterial = _sprite_mats["phone"]
	if _buzz_tween != null and _buzz_tween.is_valid():
		_buzz_tween.kill()
		phone.position.x = OdaLayoutRef.place(OdaLayoutRef.padded_target("phone"), size).position.x
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
# PANO (çapa 4) — hedef / lig / tarihler / post-it
# =========================================================================

## Pano başlık register'ı: mono + BÜYÜK HARF, pazar payı / tarihler başlıklarıyla
## aynı. Sondaki iki nokta serif-deck çağının kalıntısıydı ("Traction'a:" /
## "To Traction:") ve büyük harfte "TO TRACTION:" diye okunuyordu — diğer iki
## başlıkta iki nokta YOK. Kesme bilinçli olarak ÇAĞRI YERİNDE: bu sunum kararı,
## içerik değil, o yüzden strings.csv'ye dokunulmuyor (sahibi Lokalizasyon Faz 2).
static func _goal_head(s: String) -> String:
	return UiTokens.tr_upper(s.trim_suffix(":"))


func _refresh_goal() -> void:
	# Eşikler HER boyamada konstanttan CANLI okunur (Erdem onay düzeltmesi #1):
	# curve oturumu değerleri değiştirdiğinde pano kendiliğinden doğru kalır.
	_goal_bar.visible = true
	match GameState.phase:
		1:
			_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P1_LABEL"))
			_goal_value.text = tr("ODA_BOARD_GOAL_P1_META")
			var met: int = 0
			if bool(GameState.get_flag("mvp_shipped", false)): met += 1
			if CustomerRegistry.get_all().size() > 0: met += 1
			if GameState.mrr > 0: met += 1
			_goal_sub.text = "%d/3" % met
			_goal_bar.value = met / 3.0 * 100.0
		2:
			_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P2_LABEL"))
			_goal_value.text = "%s / %s MRR" % [
				UiTokens.format_money(GameState.mrr),
				UiTokens.format_money(SalesSystem.TRACTION_MRR_TARGET)]
			_goal_sub.text = UiTokens.tr_upper(tr("ODA_BOARD_GOAL_P2_BRAND").format({"value": GameState.brand, "target": _gate2_brand_floor()}))
			_goal_bar.value = SalesSystem.traction_progress() * 100.0
		_:
			if GameState.series_a_closed:
				_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P3_CLOSED"))
				_goal_value.text = UiTokens.format_money(GameState.run_investment_amount)
				_goal_sub.text = ""
				_goal_bar.visible = false
			else:
				_goal_label.text = _goal_head(tr("ODA_BOARD_GOAL_P3_LABEL"))
				_goal_value.text = tr("ODA_BOARD_GOAL_P3_HUNT").format({"n": GameState.active_sheets.size()})
				_goal_sub.text = ""
				_goal_bar.visible = false


func _gate2_brand_floor() -> int:
	# GATES tablosundan canlı okuma: from==2 kapısının brand_above eşiği + 1
	# ("eşik-1" sözleşmesi — phase_gate_system.gd yorumuna bak). Kopya yok.
	for gate in PhaseGateSystem.GATES:
		if int(gate.get("from", 0)) == 2:
			for cond in gate.get("conditions", []):
				if String(cond.get("type", "")) == "brand_above":
					return int(cond.get("value", 24)) + 1
	return 25


func _refresh_league() -> void:
	# PAZAR PAYI panosu (Dünya İnandırıcılığı Fix 3 bağlaması — lig görünümünün
	# yerine). Kaynak: RivalRegistry.get_market_snapshot (stateless; MRR + katalog
	# seed'lerinden türetilir). Merdiven grameri: en üstte pazar lideri, altında
	# oyuncunun HEMEN üstündeki basamaklar (tırmanılacak sıradaki rakipler), en
	# altta SEN satırı — kıymık küçükken bile bir sonraki hedef görünür. Satır
	# numarası GERÇEK pazar sırasıdır (liderle basamak arasındaki sayı atlaması
	# aradaki mesafeyi kendisi anlatır). Node/fonksiyon adları ve "board_league"
	# yerleşim anahtarı bilinçli olarak yerinde — yalnız veri kaynağı değişti;
	# kalite-ligi rank API'si artık yalnız detail_view'un "seni geçti" kapısında.
	var sub: String = _active_sub_type_id()
	if sub == "":
		_board_wraps["market"].visible = false
		return
	# D3 DURUM 1 — ürün piyasada değil: pano slotu TAMAMEN boş (kart render
	# edilmez; "<%0,1" gün-0 kıymığı öldü).
	if not bool(GameState.get_flag("mvp_shipped", false)):
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
	# D3 DURUM 2 — çıktı ama müşteri/MRR yok: tablo yerine TEK yönlendirme satırı
	# (kopya seçimi a — oyunun kuru register'ı; Erdem delege etti).
	if GameState.mrr <= 0:
		_league_rank.text = ""
		var line := UiFactory.make_label(tr("ODA_BOARD_MARKET_EMPTY"), &"QuoteSerif")
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_league_rows.add_child(line)
		return
	# D3 DURUM 3 — gerçek pay tablosu: top-3 + oyuncunun HEMEN üstündeki rakip
	# (dedup) + SEN + diğerleri. Satır numarası GERÇEK pazar sırasıdır (merdiven
	# mirasının iyi fikri): rakip sırası, oyuncunun onun üstünde olup olmamasına
	# göre +1 kayar; sayı atlaması aradaki mesafeyi kendisi anlatır.
	var player_pct: float = float(snap["player_pct"])
	_league_rank.text = RivalRegistry.format_share(player_pct)
	var player_name: String = String(GameState.get_flag("mvp_product_name", ""))
	if player_name == "":
		player_name = GameState.company_name
	var above_count: int = 0
	var nearest_above: Dictionary = {}
	for i in range(rivals.size() - 1, -1, -1):   # sondan yürü = oyuncunun hemen üstü
		if float(rivals[i]["share_pct"]) > player_pct:
			nearest_above = rivals[i]
			break
	for row in rivals:
		if float(row["share_pct"]) > player_pct:
			above_count += 1
	var picked: Dictionary = {}
	var picks: Array = []
	for i in mini(3, rivals.size()):
		picks.append(rivals[i])
		picked[String(rivals[i]["id"])] = true
	if not nearest_above.is_empty() and not picked.has(String(nearest_above["id"])):
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
		var glyph: String = ""
		if int(e["trend"]) > 0:
			glyph = "▲ "
		elif int(e["trend"]) < 0:
			glyph = "▼ "
		_league_rows.add_child(_league_row(int(e["rank"]), String(e["name"]), bool(e["is_player"]),
			glyph + RivalRegistry.format_share(float(e["share"]))))
	# "diğerleri" kuyruğu: <%0,1 iken gizli (uzun kuyruk için yanlış okunur).
	# Bu satır SIRASIZ kalır — merdivene sokulsaydı %12'lik artık oyuncunun kıymığının
	# ÜSTÜNE basamak olarak girer, sıra atlamasının anlattığı mesafeyi bozardı. Ama
	# sırasız kalmak "numarasını kaybetmiş rakip" gibi okunmamalı: baştaki "·" tam da
	# merdivenin "N ·" ayracıydı, o yüzden üç nokta ile değişti — liste burada
	# BİTMİYOR, listelenmeyenlerin toplamı diye okunur. İşaret dilden bağımsız
	# (TR/EN aynı satırda karışmasın: sözcük yalnız çeviri anahtarından gelir).
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
	# right_panel.gd:209-219 deseninin kopyası (provenance: RightPanel emekli —
	# ODA rework 2026-08-06; sunum-tarafı çözüm, motor dokunulmadı): aktif build →
	# yayınlanmış snapshot → kataloğun ilk tipi.
	var b = ProductSystem.get_active_build()
	if b != null and b.sub_product_type_id != "":
		return b.sub_product_type_id
	var shipped: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	if shipped != "":
		return shipped
	var types: Array = ProductCatalog.get_all_sub_product_types()
	return String(types[0].get("id", "")) if not types.is_empty() else ""


func _player_composite(sub: String) -> float:
	# right_panel.gd:222-229 deseninin kopyası (aynı provenance).
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var b = ProductSystem.get_active_build()
	if b != null:
		return QualityModel.composite_quality(QualityModel.economy_dims_from_build(b), axes)
	if GameState.get_flag("mvp_shipped", false):
		return QualityModel.shipped_composite()
	return 0.0


func _league_row(no: int, display: String, is_player: bool, value: String = "") -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var label := UiFactory.make_label("%d · %s" % [no, UiTokens.tr_upper(display)], &"MicroLabel",
		UiTokens.ODA_INK if is_player else UiTokens.ODA_INK_MUTED)
	label.clip_text = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	if is_player:
		row.add_child(UiFactory.make_label(tr("ODA_BOARD_LEAGUE_YOU"), &"MicroLabel", UiTokens.ODA_ACCENT_DEEP))
	if value != "":
		# Pay kolonu (pazar payı panosu): SEN satırında vurgulu, rakipte sönük.
		row.add_child(UiFactory.make_label(value, &"MicroLabel",
			UiTokens.ODA_ACCENT_DEEP if is_player else UiTokens.ODA_INK_DIM))
	return row


func _refresh_dates() -> void:
	# Sunum-tarafı toplama: motorun aggregator'ı yok (EventManager.get_upcoming
	# TODO — boşluk defterinde). Kaynaklar: VC görüşme günü, teklif vadeleri,
	# açık söz teslimleri, churn geri sayımları, ay kapanışı. En yakın 3.
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
	var d: int = today + 1
	while d <= today + 31:
		if int(GameState.get_date_dict(d)["day"]) == 1:
			items.append({"day": d, "label": tr("ODA_BOARD_DATE_MONTH")})
			break
		d += 1
	items = items.filter(func(it): return int(it["day"]) >= today)
	items.sort_custom(func(a, b): return int(a["day"]) < int(b["day"]))
	var shown: int = 0
	for it in items:
		if shown >= 3:
			break
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		var lbl := UiFactory.make_label(String(it["label"]), &"RowMeta")
		lbl.clip_text = true
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		row.add_child(UiFactory.make_label(_date_delta_text(int(it["day"]) - today), &"NewsMeta", UiTokens.ODA_INK))
		_dates_rows.add_child(row)
		shown += 1
	_board_wraps["dates"].visible = shown > 0


func _date_delta_text(delta: int) -> String:
	if delta <= 0:
		return tr("ODA_DATE_TODAY")
	if delta == 1:
		return tr("ODA_DATE_TOMORROW")
	return tr("ODA_DATE_IN_DAYS").format({"n": delta})


func _refresh_postit() -> void:
	# İstisna post-it'i: dikkat gerektiren İLK çalışan (worst-first sözleşmesi
	# HRSystem.badges_for'da). Kimse yoksa post-it yok.
	var target_name: String = ""
	for emp in CharacterRegistry.get_employees():
		if not HRSystem.badges_for(emp).is_empty():
			target_name = emp.character_name.get_slice(" ", 0)
			break
	if target_name == "":
		_board_wraps["postit"].visible = false
		return
	_board_wraps["postit"].visible = true
	_postit_line.text = tr("ODA_BOARD_POSTIT").format({"name": target_name})


func _refresh_overtime_chip() -> void:
	# day_index blok başladığı gün 0 dönebilir (ilk gece daily tick'te sayılır) —
	# aktif blokta çip HEP görünsün diye taban 1'e kelepçelenir.
	var max_day: int = 0
	for dept in HRConstants.DEPARTMENTS:
		if HROvertimeSystem.is_active(dept):
			max_day = maxi(max_day, maxi(1, HROvertimeSystem.day_index(dept)))
	_overtime_chip.visible = max_day > 0
	if max_day > 0:
		_overtime_label.text = tr("ODA_WINDOW_OVERTIME").format({"n": max_day})


# =========================================================================
# KÂĞITLAR (çapa 3) — ertelenebilir bekleyen kararlar. Temiz masa = işler yolunda.
# =========================================================================

func _gather_papers() -> Array:
	# Öncelik sırası (plan §5.3). Kâğıt akış TETİKLEMEZ — yalnız navigasyon.
	var papers: Array = []
	if GameState.phase_gate_ready and GameState.pending_next_phase > 0:
		papers.append({"id": "gate", "dot": UiTokens.ODA_ACCENT_DEEP,
			"tag": tr("ODA_PAPER_TAG_GATE"), "title": tr("ODA_PAPER_GATE_TITLE"),
			"target": "finance", "subpage": ""})
	var sheet_count: int = GameState.active_sheets.size()
	if sheet_count > 0:
		var min_left: int = 999
		for sheet in GameState.active_sheets:
			min_left = mini(min_left, sheet.days_left(GameState.day))
		var title: String = tr("ODA_PAPER_SHEET_TITLE").format({"days": maxi(0, min_left)}) if sheet_count == 1 \
			else tr("ODA_PAPER_SHEETS_TITLE").format({"n": sheet_count})
		papers.append({"id": "sheet", "dot": UiTokens.ODA_HEALTH_AMBER,
			"tag": tr("ODA_PAPER_TAG_FUNDING"), "title": title,
			"target": "finance", "subpage": "yatirim"})
	if HRSearchSystem.has_files_ready():
		papers.append({"id": "atlas", "dot": UiTokens.ODA_INK_MUTED,
			"tag": tr("ODA_PAPER_TAG_ATLAS"),
			"title": tr("ODA_PAPER_ATLAS_TITLE").format({"n": HRSearchSystem.get_files().size()}),
			"target": "hr", "subpage": ""})
	# İKAME: tasarımın istediği "sözleşme yenileme penceresi" motorda yok —
	# renewal sistemi gelince bu kaynak onunla değiştirilir. Fatura/ödeme vadesi
	# kaynağı da motorda karşılıksız (v1'de hiç yok). Done mesajında listeli.
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.lifecycle_phase == "expansion":
			papers.append({"id": "exp_%s" % c.id, "dot": UiTokens.oda_health_green(),
				"tag": UiTokens.tr_upper(c.company_name),
				"title": tr("ODA_PAPER_EXPANSION_TITLE"),
				"target": "sales", "subpage": ""})
	if _debug_papers:
		papers.append({"id": "dbg_gate", "dot": UiTokens.ODA_ACCENT_DEEP,
			"tag": tr("ODA_PAPER_TAG_GATE"), "title": tr("ODA_PAPER_GATE_TITLE"),
			"target": "finance", "subpage": ""})
		papers.append({"id": "dbg_atlas", "dot": UiTokens.ODA_INK_MUTED,
			"tag": tr("ODA_PAPER_TAG_ATLAS"), "title": tr("ODA_PAPER_ATLAS_TITLE").format({"n": 3}),
			"target": "hr", "subpage": ""})
	return papers


func _refresh_papers() -> void:
	var papers: Array = _gather_papers()
	_paper_overflow = maxi(0, papers.size() - PAPER_CAP)
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
		_update_paper_overflow_chip(card, i == PAPER_CAP - 1 and _paper_overflow > 0)
		rebuilt[p["id"]] = card
	_paper_cards = rebuilt
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
	var overflow := UiFactory.make_label("", &"MicroLabel", UiTokens.ODA_ACCENT_DEEP)
	overflow.name = "OverflowChip"
	overflow.visible = false
	row.add_child(overflow)
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"OdaPaperCardHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"OdaPaperCard")
	card.gui_input.connect(_on_paper_input.bind(String(p["target"]), String(p["subpage"])))
	_papers_box.add_child(card)
	return card


func _update_paper_overflow_chip(card: PanelContainer, show_chip: bool) -> void:
	var chip: Label = card.get_node("Row/OverflowChip")
	chip.visible = show_chip
	if show_chip:
		chip.text = "+%d" % _paper_overflow


func _animate_paper_arrival(card: PanelContainer) -> void:
	# Kâğıt başına TEK geliş animasyonu (mikro-hareket listesi) — _seen_paper_ids
	# bekçisi relayout/tab dönüşünde tekrarını engeller.
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		anchor_clicked.emit("paper:%s" % target)
		EventBus.tab_changed.emit(target)
		if subpage != "":
			# tab_changed mount'u SENKRON — handler bağlandı, deep-link güvenli.
			EventBus.finance_subpage_requested.emit(subpage)


func debug_seed_papers() -> void:
	# --oda-shot=night fixture'ı (yalnız debug): masaya 2 sentetik kâğıt.
	if not OS.is_debug_build():
		return
	_debug_papers = true
	_refresh_papers()


# =========================================================================
# ÇERÇEVE DUVARI (çapa 6) — kilometre taşları. Boş çerçeve = henüz kazanılmadı.
# =========================================================================

func get_milestones() -> Array:
	# PUBLIC (D5): document-model milestone sayfası (center_viewport) da buradan
	# okur — türetme mantığı tek evde kalır.
	# Motorun milestone defteri YOK (boşluk listesinde) — üçlü mevcut kalıcı
	# izlerden türetilir. Yatırımın GÜNÜ kayıtlı değil → yalnız miktar gösterilir.
	var founding_date: Dictionary = GameState.get_date_dict(1)
	var out: Array = [{
		"name": tr("ODA_FRAME_FOUNDING"), "earned": true,
		"meta": "%s %d" % [GameState.MONTH_NAMES_TR_TITLE[int(founding_date["month"]) - 1], int(founding_date["year"])],
	}]
	var launch_day: int = int(GameState.get_flag("mvp_launch_day", 0))
	if launch_day > 0:
		var ld: Dictionary = GameState.get_date_dict(launch_day)
		out.append({"name": tr("ODA_FRAME_FIRST_SHIP"), "earned": true,
			"meta": "%s %d" % [GameState.MONTH_NAMES_TR_TITLE[int(ld["month"]) - 1], int(ld["year"])]})
	else:
		out.append({"name": tr("ODA_FRAME_FIRST_SHIP"), "earned": false, "meta": ""})
	if GameState.run_investment_amount > 0:
		out.append({"name": tr("ODA_FRAME_FIRST_FUNDING"), "earned": true,
			"meta": UiTokens.format_money(GameState.run_investment_amount)})
	else:
		out.append({"name": tr("ODA_FRAME_FIRST_FUNDING"), "earned": false, "meta": ""})
	return out


func _refresh_frames() -> void:
	# D5 DİPLOMA MODELİ: çerçeve içi = mühür + ad — uzun metin YOK (tarih/tutar
	# document-model milestone sayfasında yaşar). Kazanılmamış çerçeve TAMAMEN
	# boş ("—" tiresi öldü). Gerçek diploma görseli Claude Design turunda gelecek;
	# şimdilik token-minimal (Erdem notu).
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
# D2/F2 hover kuralı (kalite turu v2): DOLGU ASLA PARLAMAZ. Sprite çapaları =
# şekle oturan rim shader; pano = kartların kenarı amber'e döner (varyasyon
# swap, ChoiceCardHover grameri); çerçeveler = çerçeve başına border-only
# outline (modulate fade). Bölge dikdörtgeni ÖLDÜ.
# =========================================================================

func _on_hotspot_entered(id: String) -> void:
	match id:
		"monitor", "phone":
			_tween_rim(id, 1.0)
		"board":
			_set_board_hover(true)
		"frames":
			_set_frame_outlines(0.6)


func _on_hotspot_exited(id: String) -> void:
	match id:
		"monitor", "phone":
			_tween_rim(id, 0.0)
		"board":
			_set_board_hover(false)
		"frames":
			_set_frame_outlines(0.0)


func _set_board_hover(hovered: bool) -> void:
	# Kart kenarı hover'ı — margin'ler bayt-aynı (metin zıplamaz); post-it hariç
	# (post-it kart değil, el yazısı nesne).
	var variation: StringName = &"OdaBoardCardHover" if hovered else &"OdaBoardCard"
	_board_goal.theme_type_variation = variation
	_board_league.theme_type_variation = variation
	_board_dates.theme_type_variation = variation


func _set_frame_outlines(target: float) -> void:
	for outline in _frame_outlines:
		var key: String = "outline_" + outline.name
		if _hover_tweens.has(key) and (_hover_tweens[key] as Tween).is_valid():
			(_hover_tweens[key] as Tween).kill()
		var tw := create_tween()
		tw.tween_property(outline, "modulate:a", target, HOVER_FADE_S)
		_hover_tweens[key] = tw


func debug_hover_anchors() -> void:
	# --oda-shot=hover fixture'ı (yalnız debug): dört hover muamelesi tek karede —
	# G2 kapısının kanıtı (dikdörtgen yok, dolgu parlamıyor).
	if not OS.is_debug_build():
		return
	_tween_rim("monitor", 1.0)
	_tween_rim("phone", 1.0)
	_set_board_hover(true)
	_set_frame_outlines(0.6)


func _tween_rim(id: String, target: float) -> void:
	var mat: ShaderMaterial = _sprite_mats[id]
	var key: String = "rim_" + id
	if _hover_tweens.has(key) and (_hover_tweens[key] as Tween).is_valid():
		(_hover_tweens[key] as Tween).kill()
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("glow_strength", v),
		float(mat.get_shader_parameter("glow_strength")), target, HOVER_FADE_S)
	_hover_tweens[key] = tw


func _on_hotspot_input(event: InputEvent, id: String) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	anchor_clicked.emit(id)
	match id:
		"monitor":
			EventBus.tab_changed.emit("product")
		"phone":
			# D2: bekleyen olay VEYA latch'li Frank satırı varsa Events sayfasına
			# (tam mesaj document model'de yaşar); ikisi de yoksa bilinçli no-op.
			if EventManager.get_queue_size() > 0 or _mentor_line != "":
				EventBus.tab_changed.emit("events")
		"board":
			# v1 tek hedef: Finance (hedef+tarihler finansal; pay derinliği v2 — # WORKING).
			EventBus.tab_changed.emit("finance")
		"frames":
			# D5: milestone detayı document model'de (popover öldü) — pseudo-doküman
			# id'si; center_viewport gövdesini kurar, TabPageChrome ✕/Esc bedava.
			EventBus.tab_changed.emit("milestones")


# =========================================================================
# İLK AÇILIŞ TURU
# =========================================================================

func start_intro_tour_if_unseen() -> void:
	# main.gd MentorIntro kapanışında call_group ile çağırır. Bayrak
	# user://settings.json'da (Settings autoload) — run'lar arası kalıcı.
	if bool(Settings.get_value("oda_intro_seen", false)):
		return
	if not visible or _tour != null:
		return
	# PanelLayer'a monte edilir, OdaView'un çocuğu olarak DEĞİL: çocukken dim rect'leri
	# yalnız CenterViewport'u kaplıyordu ve TopBar / sol ray turun altında tıklanabilir
	# kalıyordu. Çapa geometrisi hâlâ ODA'ya göre ölçülsün diye sahne olarak `self`
	# veriliyor (tur her adımda global rect'i yeniden okur).
	var tour_layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
	if tour_layer == null:
		push_error("[OdaView] GameShell/PanelLayer yok — tur monte edilemiyor")
		return
	_tour = OdaTourRef.new()
	_tour.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Sahne add_child'DAN ÖNCE verilir: _ready add_child sırasında koşar ve ilk adımı
	# hemen yerleştirir, o anda sahne boşsa spotlight tam ekrana göre ölçülür.
	_tour.set_stage(self)
	tour_layer.add_child(_tour)
	_tour.tree_exited.connect(func() -> void: _tour = null)
