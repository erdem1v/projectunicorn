extends Control

# GameShell root. process_mode = ALWAYS (GameShell.tscn) so this handler runs while
# the tree is paused — that's what lets Space UN-pause the game. _input (not
# _unhandled_input) so a focused Button can't swallow Space via ui_accept first.

const INBOX := preload("res://scripts/ui/components/inbox.gd")
const HELD_GLYPH := preload("res://assets/icons/util/pause.svg")
## A refused speed key says why at most this often.
const HELD_TOAST_MS := 3000

var _vc_debug_idx: int = 0   # Shift+F5: cycles the VC roster
var _held_toast_ms := -HELD_TOAST_MS
# Ürün sekmesinin fikstür röleleri. Fikstür betiği yalnız debug_product_apply'da yüklenir; oyun ona
# dokunmaz.
const PRODUCT_FIXTURES := "res://scripts/debug/product_fixtures.gd"
var _product_source: Object = null

@onready var _windows: Node = $CenterViewport   # WindowLayer: Esc en üstteki pencereyi kapatır
@onready var _ticker: Control = $NewsTicker


func _ready() -> void:
	EventBus.sprint_closed.connect(_on_sprint_closed)
	_ticker.open_changed.connect(_lay_ticker)
	_lay_ticker(_ticker.open)


## Kapalı haber şeridi sol altta yalnız aç/kapa hücresidir: ofis ve ray ekranın altına iner, rayın
## son satırı hücrenin üstünde kalır.
func _lay_ticker(open: bool) -> void:
	var band: float = _ticker.custom_minimum_size.y
	$CenterViewport.offset_bottom = -band if open else 0.0
	$LeftTabs.offset_bottom = -band if open else 0.0
	$LeftTabs.set_bottom_clearance(0.0 if open else band)


## Sprint kapanınca sürüm notu Ürün sekmesinde açılır; sekme zaten açıksa kendini yeniden çizer.
func _on_sprint_closed(_number: int) -> void:
	var page: Control = _windows.get_current_page_body()
	if page == null or not page.has_method(&"set_source"):
		EventBus.tab_changed.emit("product")


func _layer_busy(layer_name: String) -> bool:
	var layer: Node = get_node_or_null(layer_name)
	return layer != null and layer.get_child_count() > 0


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	# Çıplak F5/F9 = hızlı kayıt/yükleme, debug VE release'de aynı. Debug bandının ÜSTÜNDE,
	# çünkü aşağıdaki blok F1-F11'i HANDLED işaretliyor.
	if (key.keycode == KEY_F5 or key.keycode == KEY_F9) \
			and not key.ctrl_pressed and not key.shift_pressed and not key.alt_pressed:
		get_viewport().set_input_as_handled()
		if key.keycode == KEY_F5:
			EventBus.quicksave_requested.emit()
		else:
			EventBus.quickload_requested.emit()
		return
	if OS.is_debug_build() and key.keycode >= KEY_F1 and key.keycode <= KEY_F11:
		get_viewport().set_input_as_handled()
		_debug_fkey(key)
		return
	# Hız: Space pause/devam, 1-4 hız basamağı. 1-4 toplantı panelinde (MeetingPanel) ve
	# TermSheetTable'da seçenek seçimi de; ikisi de ModalLayer'da, Guard 2 ayrımı sağlar.
	# Kurucunun toplantı yolculuğunda bu tuşları OfficeTravel yutar.
	var speed_idx: int = -1
	match key.keycode:
		KEY_1, KEY_KP_1: speed_idx = 1
		KEY_2, KEY_KP_2: speed_idx = 2
		KEY_3, KEY_KP_3: speed_idx = 3
		KEY_4, KEY_KP_4: speed_idx = 4
	if speed_idx < 0 and key.keycode != KEY_SPACE and key.keycode != KEY_ESCAPE:
		return
	# Guard 1: metin alanı odaklı → tuş karakterini yazsın. Esc'te LineEdit odağı
	# ui_cancel ile bırakır; BİR SONRAKİ Esc sayfayı kapatır.
	var focus: Control = get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		return
	# Guard 2: bloklayan modal pause'u main.gd üzerinden yönetir (_pre_*_speed durum
	# makinesi bozulmasın). HANDLED işaretlemeden dön — Esc modalın ui_cancel'ına aksın.
	if _layer_busy("ModalLayer"):
		return
	if key.keycode == KEY_ESCAPE:
		# Guard 3: PanelLayer sakinleri (Atlas, Eğitim, Mesai, satır menüsü) Esc'in sahibi;
		# yoksa Esc sekmeyi kapatır ve PanelLayer çocuğu ekranda öksüz kalır.
		if _layer_busy("PanelLayer"):
			return
		get_viewport().set_input_as_handled()
		# Önce ayrıntı, sonra birincil pencere (× ile aynı kanal). Ofiste her şey kapalıyken karar
		# bekliyorsa gelen kutusu kararla yeniden açılır, yoksa sistem menüsü.
		if _windows.close_top():
			return
		if EventGate.active_id() != "":
			INBOX.show("active")
		else:
			EventBus.system_menu_requested.emit()
		return
	get_viewport().set_input_as_handled()
	# Karar saati tutarken hız değişmez: kapı çerçevesi yanıp söner, toast nedenini söyler.
	if EventGate.active_id() != "":
		get_tree().call_group(&"top_bar", &"blink_gate")
		if Time.get_ticks_msec() - _held_toast_ms >= HELD_TOAST_MS:
			_held_toast_ms = Time.get_ticks_msec()
			get_tree().call_group(&"toast", &"show_toast", tr("CLOCK_HELD"), tr("GATE_ANSWER_FIRST"),
				HELD_GLYPH, UiTokens.D_ACCENT)
		return
	# TopBar butonlarıyla aynı sinyal, TopBar senkron kalsın.
	if speed_idx < 0:
		speed_idx = 0 if TimeManager.current_speed > 0 else TimeManager.last_running_speed
	EventBus.speed_change_requested.emit(speed_idx)


# --- Debug F-tuşları (yalnız debug build) ---
# Shift varyantları burada; _debug_endgame_key shift'i yok sayar. Modal açıkken
# Shift varyantları yığılmaz: modal çözülmeden shell'i serbest bırakmak (Shift+F4)
# EventManager'ın olay hattını kalıcı olarak kilitler.
func _debug_fkey(key: InputEventKey) -> void:
	if key.shift_pressed and key.keycode in [KEY_F4, KEY_F5, KEY_F6]:
		if _layer_busy("ModalLayer"):
			return
		match key.keycode:
			KEY_F4:
				EventBus.debug_onboarding_retrigger_requested.emit()
			KEY_F5:
				var roster: Array = InvestorRegistry.get_active()
				var inv: Dictionary = roster[_vc_debug_idx % roster.size()]
				_vc_debug_idx += 1
				VCPitchSystem.begin_meeting(String(inv.get("id", "")))
			KEY_F6:
				_debug_open_term_table()
		return
	_debug_endgame_key(key.keycode)


# Anchor + Nexus sheet'lerini (mockup'ın kaldıraç durumu) yoksa verir, masayı Anchor'da açar.
func _debug_open_term_table() -> void:
	if GameState.phase < 3:
		GameState.set_phase(3)
	for tt_vc in ["anchor", "nexus"]:
		if VCPitchSystem.sheet_for(tt_vc) == null and GameState.active_sheets.size() < PitchConstants.MAX_SHEETS:
			GameState.active_sheets.append(VCPitchSystem._make_sheet(tt_vc, GameState.day))
	EventBus.term_table_requested.emit("anchor", PitchConstants.STAGE_SERIES_A)


# Argless relays for the MCP runtime bridge (it can't pass typed args). Debug builds only.
func debug_force_vc_meeting(vc_id: String = "anchor") -> void:
	if OS.is_debug_build():
		VCPitchSystem.begin_meeting(vc_id)


func debug_product_apply(fixture_id: String) -> void:
	if OS.is_debug_build():
		EventBus.tab_changed.emit("product")
		_product_source = (load(PRODUCT_FIXTURES) as GDScript).new(fixture_id)
		_windows.get_current_page_body().set_source(_product_source)


## Fikstürün geçiş tablosunu bir adım sürer; set_source sekmeyi yeni modelden yeniden kurar.
## Pencere kapandıysa ya da başka sekme açıksa sayfa yoktur ya da sprint ekranı değildir.
func debug_product_act(kind: String) -> void:
	var page: Control = _windows.get_current_page_body()
	if not OS.is_debug_build() or _product_source == null or page == null or not page.has_method(&"set_source"):
		return
	_product_source.act(kind, {})
	page.set_source(_product_source)


# Class B durumları ön şartı kurar, bitişi BİR SONRAKİ günlük tik (slot 8/9) ateşler —
# gerçek tarama yolu sınanır. F3 bilerek Class A anlık yoldur. F5/F9 Ctrl ile gelir
# (çıplak hali hızlı kayıt/yükleme).
func _debug_endgame_key(keycode: Key) -> void:
	match keycode:
		KEY_F1:
			PhaseGateSystem.debug_force_gate()
		KEY_F2:
			# Anlık faz atlama (Frank sahnesini atlar).
			GameState.phase_gate_ready = true
			GameState.pending_next_phase = GameState.phase + 1
			GameState.advance_phase()
		KEY_F3:
			GameState.series_a_closed = true
			EndingsSystem.trigger_ending("series_a_close", EndingsSystem.TELEGRAPH_WIN)
		KEY_F4:
			# Satın alma teklifi ön şartları.
			GameState.set_phase(3)
			GameState.set_brand(40)
			GameState.vc_rejections = maxi(GameState.vc_rejections, 1)
		KEY_F5:
			# Kepenk bir sonraki günlük tikte başlar.
			GameState.set_cash(-1000)
		KEY_F6:
			# Marka çöküşü ön şartları.
			GameState.set_brand(10)
			GameState.active_scandal = true
			GameState.brand_low_since_day = maxi(1, GameState.day - TimeModel.ticks(EndingsSystem.BRAND_COLLAPSE_WINDOW))
		KEY_F7:
			# Kaskad ön şartları: 3 ret, ölü metrikler.
			GameState.vc_rejections = 3
			GameState.set_mrr(0)
		KEY_F8:
			# Kârlılık koşulu: PROFIT_STREAK_MONTHS artıda ay kapanışı (marj %20) + MRR tabanı.
			# Damgalar haftalık tiktir; fikstürün ayı dört haftadır.
			GameState.month_history.clear()
			for i in EndingsSystem.PROFIT_STREAK_MONTHS:
				GameState.push_month_close({"start_day": 1 + i * 4, "end_day": 4 + i * 4,
					"mrr_close": EndingsSystem.BOOTSTRAP_WIN_MRR, "income": 30_000, "expense": 24_000,
					"net": 6_000, "red_weeks": 0})
			GameState.set_mrr(EndingsSystem.BOOTSTRAP_WIN_MRR)
			if GameState.cash < 0:
				GameState.set_cash(1000)
		KEY_F9:
			# Yumuşak tavan arifesi.
			GameState.day = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK) - 1
		KEY_F10:
			# Pivot teklifi ön şartları: 3 ret, canlı metrikler.
			GameState.vc_rejections = 3
			GameState.set_mrr(3000)
			if GameState.cash <= 0:
				GameState.set_cash(1000)
