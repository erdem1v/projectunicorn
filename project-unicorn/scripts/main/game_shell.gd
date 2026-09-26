extends Control

# GameShell root. process_mode = ALWAYS (GameShell.tscn) so this handler runs while
# the tree is paused — that's what lets Space UN-pause the game. _input (not
# _unhandled_input) so a focused Button can't swallow Space via ui_accept first.

var _meeting_fixture_toggle: bool = false  # Shift+F2: full ↔ extreme-length fixture
var _vc_debug_idx: int = 0                 # Shift+F5: cycles the VC roster
# tab_changed aynası — "" = oda görünür. Esc yönlendirmesi buradan okur.
var _active_tab_id: String = ""


func _ready() -> void:
	EventBus.tab_changed.connect(func(tab_id: String) -> void: _active_tab_id = tab_id)


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
	# Hız: Space pause/devam, 1-3 hız basamağı. 1-4 MeetingScene / TermSheetTable içinde
	# diyalog seçimi de; onlar yalnız modal açıkken var, Guard 2 ayrımı sağlar.
	var speed_idx: int = -1
	match key.keycode:
		KEY_1, KEY_KP_1: speed_idx = 1
		KEY_2, KEY_KP_2: speed_idx = 2
		KEY_3, KEY_KP_3: speed_idx = 3
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
		# Guard 3: PanelLayer sakinleri (HRAtlasModal / HRPopover / OdaTour) Esc'in sahibi;
		# yoksa Esc sekmeyi kapatır ve PanelLayer çocuğu ekranda öksüz kalır.
		if _layer_busy("PanelLayer"):
			return
		get_viewport().set_input_as_handled()
		if _active_tab_id != "":
			EventBus.tab_changed.emit("")  # açık sayfayı kapat → odaya dön (✕ ile aynı kanal)
		else:
			# Odada, her şey kapalıyken: sistem menüsü. Guard 2 geçildiyse zorunlu karar yok.
			EventBus.system_menu_requested.emit()
		return
	get_viewport().set_input_as_handled()
	# TopBar butonlarıyla aynı sinyal, TopBar senkron kalsın.
	if speed_idx < 0:
		speed_idx = 0 if TimeManager.current_speed > 0 else TimeManager.last_running_speed
	EventBus.speed_change_requested.emit(speed_idx)


# --- Debug F-tuşları (yalnız debug build) ---
# Shift varyantları burada; _debug_endgame_key shift'i yok sayar. Modal açıkken
# Shift varyantları yığılmaz: modal çözülmeden shell'i serbest bırakmak (Shift+F4)
# EventManager'ın olay hattını kalıcı olarak kilitler.
func _debug_fkey(key: InputEventKey) -> void:
	if key.keycode == KEY_F11:
		# Canlı veriyle ay özeti; Shift = uç-değer yerleşim fikstürü.
		MonthSummarySystem.debug_force_summary(key.shift_pressed)
		return
	if key.shift_pressed and key.keycode in [KEY_F2, KEY_F4, KEY_F5, KEY_F6]:
		if _layer_busy("ModalLayer"):
			return
		match key.keycode:
			KEY_F2:
				_meeting_fixture_toggle = not _meeting_fixture_toggle
				EventBus.meeting_scene_requested.emit(MeetingScene.debug_fixture_full()
						if _meeting_fixture_toggle else MeetingScene.debug_fixture_long())
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
	EventBus.term_table_requested.emit("anchor")


# Argless relays for the MCP runtime bridge (it can't pass typed args). Debug builds only.
func debug_force_month_extreme() -> void:
	if OS.is_debug_build():
		MonthSummarySystem.debug_force_summary(true)


func debug_force_meeting() -> void:
	if OS.is_debug_build():
		EventBus.meeting_scene_requested.emit(MeetingScene.debug_fixture_full())


func debug_force_meeting_long() -> void:
	if OS.is_debug_build():
		EventBus.meeting_scene_requested.emit(MeetingScene.debug_fixture_long())


func debug_force_vc_meeting(vc_id: String = "anchor") -> void:
	if OS.is_debug_build():
		VCPitchSystem.begin_meeting(vc_id)


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
			GameState.brand_low_since_day = maxi(1, GameState.day - 30)
		KEY_F7:
			# Kaskad ön şartları: 3 ret, ölü metrikler.
			GameState.vc_rejections = 3
			GameState.set_mrr(0)
		KEY_F8:
			# Kârlılık koşulu: PROFIT_STREAK_MONTHS artıda ay kapanışı (marj %20) + MRR tabanı.
			GameState.month_history.clear()
			for i in EndingsSystem.PROFIT_STREAK_MONTHS:
				GameState.push_month_close({"start_day": 1 + i * 30, "end_day": 30 + i * 30,
					"mrr_close": EndingsSystem.BOOTSTRAP_WIN_MRR, "income": 30_000, "expense": 24_000,
					"net": 6_000, "red_days": 0})
			GameState.set_mrr(EndingsSystem.BOOTSTRAP_WIN_MRR)
			if GameState.cash < 0:
				GameState.set_cash(1000)
		KEY_F9:
			# Yumuşak tavan arifesi.
			GameState.day = EndingsSystem.SOFT_CAP_DAY - 1
		KEY_F10:
			# Pivot teklifi ön şartları: 3 ret, canlı metrikler.
			GameState.vc_rejections = 3
			GameState.set_mrr(3000)
			if GameState.cash <= 0:
				GameState.set_cash(1000)
