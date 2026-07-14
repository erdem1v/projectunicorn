extends Control

# Build Takip Kutusu — Software Inc. proje-kartı modeli, dört faz (Tracker Card spec).
# Orta çalışma alanının (CenterViewport) sağ üstünde yüzer; tab değişince ÖLMEZ
# (center_viewport yalnız tab içeriğini queue_free eder, bu kart onun kardeşi).
# Sağdaki bilgi paneliyle (RightPanel) ilgisi yok.
#
# Dört faz (iç string / görünen ad):
#   iteration   → FAZ 1 TASARIM   — iterasyonlar otomatik döner; buton "Geliştir →"
#   development → FAZ 2 GELİŞTİRME — kod %0→100; buton "Yayınla · erken" (flat)
#   bugfix      → FAZ 3 BETA       — bulunan/çözülen/kalan; buton "Yayınla →"
#   (snapshot)  → FAZ 4 YAYINLANDI — ship sonrası kart-yerel geçiş hali;
#                                    buton "PostShip'e geç →"
#
# Progress AYRI BAR DEĞİL: faz satırının (PhaseCell) arka planı soldan sağa dolar —
# Track Panel + Fill Panel deseni, paint yalnız fill.anchor_right yazar.
# Kart boyutu her fazda SABİT (Root offset'leri sabit; içerik yalnız text/visible).
#
# Çoklu-build'e hazır: _paint_builds(builds: Array) liste-şekilli; bugün liste tek
# eleman ([active_build], bug-sprint taşıyıcıları filtreli), pager tek build'de pasif.
#
# Signal-driven refresh (no _process poll): build_phase_changed + build_progress_changed
# + day_advanced. process_mode = ALWAYS (pause'dayken de tıklanabilir).

@onready var icon_rect: TextureRect = $Root/Panel/VBox/HeaderRow/Icon
@onready var name_label: Label = $Root/Panel/VBox/HeaderRow/TitleBox/NameLabel
@onready var meta_label: Label = $Root/Panel/VBox/HeaderRow/TitleBox/MetaLabel
@onready var prev_btn: Button = $Root/Panel/VBox/HeaderRow/Pager/PrevBtn
@onready var page_label: Label = $Root/Panel/VBox/HeaderRow/Pager/PageLabel
@onready var next_btn: Button = $Root/Panel/VBox/HeaderRow/Pager/NextBtn
@onready var cancel_btn: Button = $Root/Panel/VBox/HeaderRow/CancelBtn
@onready var phase_cell: Control = $Root/Panel/VBox/BodyRow/PhaseCell
@onready var track: Panel = $Root/Panel/VBox/BodyRow/PhaseCell/Track
@onready var fill: Panel = $Root/Panel/VBox/BodyRow/PhaseCell/Track/Fill
@onready var phase_name_label: Label = $Root/Panel/VBox/BodyRow/PhaseCell/PhaseMargin/PhaseVBox/PhaseName
@onready var phase_status_label: Label = $Root/Panel/VBox/BodyRow/PhaseCell/PhaseMargin/PhaseVBox/PhaseStatus
@onready var axis_col: VBoxContainer = $Root/Panel/VBox/BodyRow/AxisCol
@onready var axis_inno: Label = $Root/Panel/VBox/BodyRow/AxisCol/AxisInno
@onready var axis_stab: Label = $Root/Panel/VBox/BodyRow/AxisCol/AxisStab
@onready var axis_usab: Label = $Root/Panel/VBox/BodyRow/AxisCol/AxisUsab
@onready var phase_line: Label = $Root/Panel/VBox/PhaseLine
@onready var beta_row: HBoxContainer = $Root/Panel/VBox/BetaRow
@onready var beta_found_val: Label = $Root/Panel/VBox/BetaRow/FoundBox/Val
@onready var beta_fixed_val: Label = $Root/Panel/VBox/BetaRow/FixedBox/Val
@onready var beta_remain_val: Label = $Root/Panel/VBox/BetaRow/RemainBox/Val
@onready var action_button: Button = $Root/Panel/VBox/ActionButton

# Kısa eksen etiketleri — sabit kanonik harita (working call; tip-özel istenirse
# product_catalog quality_axes'e short_label alanı eklenir, Erdem karar verir).
const _AXIS_SHORT := {"innovation": "İNOV", "stability": "KARAR", "usability": "AKIŞ"}

var _page: int = 0
var _snapshot: Dictionary = {}     # FAZ 4 geçiş hali — ship sonrası build null'ken yaşar
var _lock_chip: Control = null     # BETA "kilitli" rozeti (bir kez kurulur)
# Dolgu tonları — bir kez kurulur, paint yalnız stylebox swap eder.
# İterasyon turdan tura ton değiştirir (working call — Erdem F5'te yargılar).
var _sb_track: StyleBoxFlat = null
var _sb_fill_a: StyleBoxFlat = null
var _sb_fill_b: StyleBoxFlat = null
var _sb_fill_done: StyleBoxFlat = null
var _fill_current: StyleBoxFlat = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_styles()
	_lock_chip = UiFactory.make_badge("KİLİTLİ")
	_lock_chip.visible = false
	axis_col.add_child(_lock_chip)
	action_button.pressed.connect(_on_action_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	prev_btn.pressed.connect(func() -> void: _page -= 1; _refresh())
	next_btn.pressed.connect(func() -> void: _page += 1; _refresh())
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	EventBus.day_advanced.connect(func(_d: int) -> void: _refresh())
	EventBus.build_progress_changed.connect(_refresh)
	_refresh()


func _exit_tree() -> void:
	if EventBus.build_phase_changed.is_connected(_on_build_phase_changed):
		EventBus.build_phase_changed.disconnect(_on_build_phase_changed)
	if EventBus.build_progress_changed.is_connected(_refresh):
		EventBus.build_progress_changed.disconnect(_refresh)


func _build_styles() -> void:
	# Dolgu tonları BELİRGİN (eski AMBER_BG track'ten ayırt edilemiyordu —
	# playtest bulgusu). İki ton turdan tura alternasyon; working renkler,
	# Erdem F5'te yargılar ama görünürlük şart.
	_sb_track = StyleBoxFlat.new()
	_sb_track.bg_color = UiTokens.NEUTRAL_BADGE_BG.lerp(UiTokens.CARD_BORDER, 0.5)
	_sb_track.set_corner_radius_all(4)
	track.add_theme_stylebox_override("panel", _sb_track)
	_sb_fill_a = StyleBoxFlat.new()
	_sb_fill_a.bg_color = UiTokens.ACCENT.lerp(UiTokens.CARD_BG, 0.35)   # net amber
	_sb_fill_a.set_corner_radius_all(4)
	_sb_fill_b = StyleBoxFlat.new()
	_sb_fill_b.bg_color = UiTokens.ACCENT_DEEP.lerp(UiTokens.CARD_BG, 0.45)  # koyu kahve-amber
	_sb_fill_b.set_corner_radius_all(4)
	_sb_fill_done = StyleBoxFlat.new()
	_sb_fill_done.bg_color = UiTokens.POSITIVE_BG
	_sb_fill_done.set_corner_radius_all(4)
	_set_fill_style(_sb_fill_a)


func _set_fill_style(sb: StyleBoxFlat) -> void:
	if _fill_current == sb:
		return
	_fill_current = sb
	fill.add_theme_stylebox_override("panel", sb)


func _set_fill_fraction(f: float) -> void:
	fill.anchor_right = clampf(f, 0.0, 1.0)


func _on_build_phase_changed(new_phase: String) -> void:
	match new_phase:
		"shipped":
			# Emit-sırası ayrımı (doğrulandı): gerçek ship "shipped"i active_build
			# hâlâ doluyken emit eder; bug-sprint bitişi null'ladıktan SONRA emit
			# eder. → yalnız gerçek ship FAZ 4 snapshot'ı yaratır.
			var b: FeatureBuild = ProductSystem.get_active_build()
			if b != null and not b.is_bug_sprint:
				_snapshot = {
					"name": b.product_name,
					"sub_type": b.sub_product_type_id,
					"version": int(GameState.get_flag("mvp_version", 1)),
					"open_bugs": int(GameState.get_flag("mvp_live_bug_count", 0)),
				}
		"iteration":
			_snapshot = {}   # yeni build geçiş halini süpürür
		"cancelled":
			_snapshot = {}
	_refresh()


func _refresh() -> void:
	if not _snapshot.is_empty():
		_paint_shipped_snapshot()
		return
	_paint_builds(_collect_builds())


func _collect_builds() -> Array:
	# Çoklu-build'e hazır liste şekli; bugün en fazla tek eleman (static active_build).
	var out: Array = []
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b != null and not b.is_bug_sprint and b.current_phase in ["iteration", "development", "bugfix"]:
		out.append(b)
	return out


func _paint_builds(builds: Array) -> void:
	if builds.is_empty():
		visible = false
		return
	visible = true
	_page = clampi(_page, 0, builds.size() - 1)
	page_label.text = "%d/%d" % [_page + 1, builds.size()]
	prev_btn.disabled = builds.size() <= 1
	next_btn.disabled = builds.size() <= 1
	_paint_one(builds[_page])


func _paint_one(b: FeatureBuild) -> void:
	# --- Ortak başlık: ikon + ad + "V2 · AI ASSISTANT" ---
	cancel_btn.visible = true   # canlı fazlarda iptal edilebilir
	name_label.text = b.product_name if b.product_name != "" else _sub_type_display(b.sub_product_type_id)
	var version: int = (int(GameState.get_flag("mvp_version", 1)) + 1) if b.is_version_build else 1
	meta_label.text = "V%d · %s" % [version, _sub_type_display(b.sub_product_type_id).to_upper()]
	_paint_icon(b.sub_product_type_id)
	# --- Eksen %'leri — bugünkü HUD kaynakları aynen (İnov=ham, Karar=effective,
	# Akış=ham); yeni matematik yok. Dims açık-uçlu → %100 aşabilir (working, mockup dili).
	var draw: Dictionary = QualityModel.dims_from_build(b)
	var deco: Dictionary = QualityModel.economy_dims_from_build(b)
	axis_inno.text = "%s: %d%%" % [_AXIS_SHORT["innovation"], int(round(float(draw.get("innovation", 0.0))))]
	axis_stab.text = "%s: %d%%" % [_AXIS_SHORT["stability"], int(round(float(deco.get("stability", 0.0))))]
	axis_usab.text = "%s: %d%%" % [_AXIS_SHORT["usability"], int(round(float(draw.get("usability", 0.0))))]
	axis_col.visible = true
	# --- Faz dalları ---
	match b.current_phase:
		"iteration":
			phase_name_label.text = "TASARIM"
			phase_status_label.text = "İterasyon %d" % b.iteration_count
			# Payda = turun kendi uzunluğu (delay_days event'leri bunu uzatır);
			# 0 = eski save → const fallback.
			var iter_len: float = b.iteration_round_days if b.iteration_round_days > 0.0 else float(ProductSystem.ITERATION_LENGTH_DAYS)
			iter_len = maxf(1.0, iter_len)
			_set_fill_fraction(1.0 - clampf(b.iteration_days_in_current / iter_len, 0.0, 1.0))
			_set_fill_style(_sb_fill_a if b.iteration_count % 2 == 1 else _sb_fill_b)
			_lock_chip.visible = false
			# Faza özel satır: tur-içi gün (working — spec boş bırakmış; veri, ipucu değil)
			phase_line.text = "Gün %d/%d" % [
				clampi(int(ceil(iter_len - b.iteration_days_in_current + 0.0001)), 1, int(iter_len)), int(iter_len)]
			phase_line.visible = true
			beta_row.visible = false
			_style_action("Geliştir →", false)
		"development":
			phase_name_label.text = "GELİŞTİRME"
			phase_status_label.text = "kod aşaması"
			var total: float = maxf(1.0, float(b.development_days_total))
			var code_pct: int = int(floor(clampf(b.development_days_elapsed / total, 0.0, 1.0) * 100.0))
			_set_fill_fraction(b.development_days_elapsed / total)
			_set_fill_style(_sb_fill_a)
			_lock_chip.visible = false
			phase_line.text = "Kod: %%%d · Bug: %d" % [code_pct, b.bug_count]
			phase_line.visible = true
			beta_row.visible = false
			_style_action("Yayınla · erken", true)
		"bugfix":
			phase_name_label.text = "BETA"
			phase_status_label.text = "test aşaması"
			# Dolgu = temizlik ilerlemesi (çözülen/bulunan); yeni bug bulununca geri
			# oynar — bilinçli, Software Inc hissi (working call).
			_set_fill_fraction(float(b.bugs_fixed) / float(max(1, b.bugs_found)))
			_set_fill_style(_sb_fill_a)
			_lock_chip.visible = true
			phase_line.visible = false
			beta_row.visible = true
			beta_found_val.text = str(b.bugs_found)
			beta_fixed_val.text = str(b.bugs_fixed)
			beta_remain_val.text = str(b.bugs_found - b.bugs_fixed)
			_style_action("Yayınla →", false)
		_:
			visible = false
	# Kapasite bölünmüşse (sprint'le paralel, tek kişi) build yarı hızda akar —
	# faktör < 1 yalnız iki iş paralelken mümkün (capacity_speed_factor, tek kaynak).
	if ProductSystem.capacity_speed_factor() < 1.0:
		phase_status_label.text += " · yarı hız"


func _paint_shipped_snapshot() -> void:
	# FAZ 4 — YAYINLANDI (kart-yerel geçiş hali; active_build artık null).
	visible = true
	cancel_btn.visible = false   # iptal edilecek build yok
	name_label.text = String(_snapshot.get("name", ""))
	meta_label.text = "V%d · %s" % [int(_snapshot.get("version", 1)),
		_sub_type_display(String(_snapshot.get("sub_type", ""))).to_upper()]
	_paint_icon(String(_snapshot.get("sub_type", "")))
	page_label.text = "1/1"
	prev_btn.disabled = true
	next_btn.disabled = true
	phase_name_label.text = "✓ YAYINLANDI"
	phase_name_label.add_theme_color_override("font_color", UiTokens.POSITIVE)
	phase_status_label.text = ""
	_set_fill_fraction(1.0)
	_set_fill_style(_sb_fill_done)
	axis_col.visible = false
	_lock_chip.visible = false
	var open_bugs: int = int(_snapshot.get("open_bugs", 0))
	phase_line.text = "V%d CANLI · %d AÇIK BUG" % [int(_snapshot.get("version", 1)), open_bugs] \
		if open_bugs > 0 else "V%d CANLI" % int(_snapshot.get("version", 1))
	phase_line.visible = true
	beta_row.visible = false
	_style_action("PostShip'e geç →", false)


func _style_action(text: String, flat_style: bool) -> void:
	# "Yayınla · erken" amber CTA değil, sönük metin-stil kaçış kapısı (working call).
	action_button.text = text
	if flat_style:
		action_button.theme_type_variation = &""
		action_button.flat = true
		action_button.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
	else:
		action_button.theme_type_variation = &"CommitButton"
		action_button.flat = false
		action_button.remove_theme_color_override("font_color")
	# FAZ 4 dışında faz-adı rengi normale döner (snapshot POSITIVE'e boyuyor).
	if not text.begins_with("PostShip"):
		phase_name_label.remove_theme_color_override("font_color")


func _on_cancel_pressed() -> void:
	# Yanlış-tık affı (§recoverable-pressure): iptal = kurma ekranına dönüş,
	# oyuncu orada düzenler. Yanan gün/para geri gelmez — sadece bundan sonrası
	# durur; erken iptalde (ilk gün) zaten bir şey yanmadı, onay metni basit.
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.is_bug_sprint:
		return
	var burned_days: int = max(0, GameState.day - b.start_day)
	var burned_cash: int = burned_days * GameState.daily_burn   # working yaklaşım — Erdem balance-pass
	var early: bool = burned_days < ProductSystem.CANCEL_FREE_DAYS
	# Seçim iptalden ÖNCE yakalanır (cancel_build build'i null'lar) → kurma
	# ekranı aynı seçimle açılır, oyuncu düzenler.
	var prefill := {
		"type": b.sub_product_type_id,
		"features": b.feature_ids.duplicate(),
		"name": b.product_name,
	}
	EventBus.confirm_requested.emit({
		"title": "Build'i iptal et?",
		"body": "Kurma ekranına dönersin — seçimlerini düzenleyip yeniden başlarsın." if early
			else "%d gün + $%d yandı — geri gelmez. Sadece bundan sonrası durur." % [burned_days, burned_cash],
		"confirm_text": "İptal et",
		"cancel_text": "Vazgeç",
		"on_confirm": _do_cancel.bind(prefill),
	})


func _do_cancel(prefill: Dictionary) -> void:
	# SIRA ÖNEMLİ: önce cancel (build_phase_changed("cancelled") emit'i ekrandaki
	# ESKİ ProductTab'ı repaint eder — flag o anda yazılı olsaydı erken tüketirdi),
	# SONRA prefill flag'i, SONRA tab_changed (CenterViewport ProductTab'ı yeniden
	# kurar → yeni instance prefill'i tüketir → kurma ekranı aynı seçimle açılır).
	ProductSystem.cancel_build()
	GameState.set_flag("cancelled_build_prefill", prefill)
	EventBus.tab_changed.emit("product")
	_refresh()


func _on_action_pressed() -> void:
	if not _snapshot.is_empty():
		# FAZ 4 → PostShip: geçiş halini kapat, oyuncuyu product tab'a götür
		# (CenterViewport ProductTab'ı yeniden kurar → PostShipView route'u).
		_snapshot = {}
		EventBus.tab_changed.emit("product")
		_refresh()
		return
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		_refresh()
		return
	match b.current_phase:
		"iteration":
			ProductSystem.enter_development()
		"development", "bugfix":
			ProductSystem.launch()
	_refresh()


func _paint_icon(sub_type_id: String) -> void:
	var path: String = "res://assets/icons/products/%s.svg" % sub_type_id
	if sub_type_id != "" and ResourceLoader.exists(path):
		icon_rect.texture = load(path)
		icon_rect.modulate = UiTokens.ACCENT_DEEP
		icon_rect.visible = true
	else:
		icon_rect.texture = null
		icon_rect.visible = false


func _sub_type_display(sub_type_id: String) -> String:
	# Meta satırı mockup'taki gibi KISA EN etiketi kullanır ("AI ASSISTANT") —
	# working call: TR name_human uzun geliyor (kart 320px); Erdem F5'te yargılar.
	if sub_type_id == "":
		return "Build"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return String(data.get("name", sub_type_id))
