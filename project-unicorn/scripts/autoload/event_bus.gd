extends Node

# Global signal hub. Systems emit here; scenes connect on tree-enter, disconnect on tree-exit.
# `# --- X ---` headers are the sections of docs/EVENT_SIGNAL_MANIFEST.md (gen_signal_manifest.py).

# --- State change signals (§13.2) ---
signal cash_changed(new_value: int)
signal mrr_changed(new_value: int)
signal burn_changed(new_value: int)
signal brand_changed(new_value: int)
signal reputation_changed(new_value: int)
signal day_advanced(new_day: int)
signal hour_changed(hour: int)            # 0-23, every in-game hour boundary
signal phase_changed(new_phase: int)
signal runway_recalculated(months: float)
# Payload = TOTAL investor percent (GameState.get_investor_equity_pct). Needed because an
# equity change that moves no cash would otherwise never repaint the Finance cap-table bar.
signal equity_changed(investor_pct: int)

# --- UI / time signals (§13.2) ---
signal speed_change_requested(speed: int)  # 0=pause, 1=1x, 2=2x, 3=3x
# "" = sekme yok, oda görünür. Sekme id'leri ray sırasıyla: "product", "sales", "hr",
# "finance", "personal", "marketing", "rnd", "events". "marketing" ve "rnd" KİLİTLİ:
# rayda görünür ama tıklanamaz, bu sinyal onları taşımaz.
signal tab_changed(tab_id: String)
# Mount edilmiş Finance sekmesine alt sayfa seçtirir ("ozet"|"yatirim"). tab_changed("finance")
# SENKRON mount eder, ardışık emit bu yüzden güvenli.
signal finance_subpage_requested(page_id: String)

# --- Settings / audio signals ---
# main.gd mounts SettingsModal (pause on open, restore on close).
signal settings_requested
# Genel amaçlı onay modalı (main.gd ModalLayer'a ConfirmModal mount eder).
# config: {title, body, confirm_text, cancel_text, on_confirm: Callable}
signal confirm_requested(config: Dictionary)
# AudioManager prefs; music_volume is linear 0..1.
signal music_enabled_changed(enabled: bool)
signal music_volume_changed(volume: float)
# Localization autoload: language changed, live surfaces re-translate. Payload = "tr"/"en".
signal language_changed(locale: String)
# The colourblind-safe semantic palette was toggled. Semantic colour is never baked into
# master_theme.tres, so the swap is a pure runtime repaint: resident shell children repaint
# in place, the open tab page rebuilds via a tab_changed re-emit (same as language_changed).
signal palette_changed(colorblind: bool)

# --- Character signals (§13.2) ---
signal character_added(character_id: String)
signal character_removed(character_id: String)
signal morale_changed(character_id: String, new_morale: int)
## DENEYİM biriktiğinde / sıfırlandığında; defter satırı mini-barı bununla tazelenir.
signal employee_experience_changed(character_id: String, new_experience: int)
## Eğitim başladığında, her gün ve bittiğinde (0 = bitti/eğitimde değil).
signal employee_training_changed(character_id: String, days_left: int)
## §9.3 OLAN terfi. employee_eligible_for_promotion ile karıştırılmaz: o UYGUN HÂLE GELMEYİ bildirir.
signal employee_promoted(character_id: String, new_level: int)

# §15.3 · OLAY MOTORUNA AÇILAN SİNYAL LİSTESİ
# Dinleyicisi olmasa da yayınlanır, adları KARARLIDIR: motor bunları okur, keşfetmez (§17.3).

## §5.1 barın DOLDUĞU AN (kenar, her gün değil).
signal experience_bar_full(character_id: String)

## §7 bandın DEĞİŞTİĞİ an (80 / 50 / 35 sınırları). Motorun sorusu "hangi banda düştü".
signal morale_band_changed(character_id: String, band_id: String)

## §9.3. Yayınlanmıyor: §9.3 terfiye seviye tavanı dışında KOŞUL vermiyor, kenarı seçmek
## tasarım hükmü olur. Ad kararlı, kenar bekliyor.
signal employee_eligible_for_promotion(character_id: String)

## §9.2. Yayınlanmıyor: zam talebi AYRI BİR OLAYDIR ve olay motorunun konusudur.
signal raise_requested(character_id: String)

## §11.4 izin talebi: yaz haftası geldiğinde HR yayınlar.
signal leave_requested(character_id: String)

signal employee_hired(character_id: String)
signal employee_departed(character_id: String)
signal training_started(character_id: String, area_key: String)
signal training_completed(character_id: String, area_key: String)
## Görev ataması değişti (§12.0): atandı, çıkarıldı ya da ayrılırken işleri boşaldı. Argüman
## kişidir, iş değil: dinleyen hem satırı hem etkilenen her işin doluluğunu tazeler.
## Tek yayıncı CharacterRegistry.
signal assignment_changed(character_id: String)
# END of HRSystem.daily_tick. day_advanced fires inside GameState.advance_day(), BEFORE the
# daily ticks dispatch, so a repaint there would read pre-tick HR state. No payload.
signal hr_day_processed()

# END of NewsFeedSystem.daily_tick; same reason as hr_day_processed. Read NewsFeedSystem.get_stream().
signal news_stream_changed()

# --- Customer signals (§13.2) ---
signal customer_added(customer_id: String)
signal customer_removed(customer_id: String)
signal customer_mrr_changed(customer_id: String, new_mrr: int)
signal customer_seats_changed(customer_id: String, new_seats: int)
signal customer_satisfaction_changed(customer_id: String, new_satisfaction: int)

# --- B2B lifecycle / relationship signals (B2B Sales System) ---
signal customer_health_changed(customer_id: String, phase: String)
signal customer_churned(customer_id: String)
signal customer_expanded(customer_id: String, new_seats: int)
signal customer_assigned(customer_id: String, employee_id: String)
# A product feature ship keeps a promise, a passed deadline breaks it.
signal promise_created(promise_id: String)
signal promise_kept(promise_id: String)
signal promise_broken(promise_id: String)

# --- Event signals (§13.2) ---
signal event_triggered(event_id: String)
signal event_resolved(event_id: String, choice_index: int)
signal modal_requested(event: GameEvent)

# --- Build / product signals ---
signal build_phase_changed(new_phase: String)
# true YALNIZ tavan parkında (ITER_MAX_ROUNDS'a gelindi); "Geliştirmeye geç" ya da yeni tur false.
signal build_iteration_decision_pending(pending: bool)
# END of ProductSystem.daily_tick: day_advanced fires BEFORE the tick moves the counters, so a
# bar repainting there would lag a day.
signal build_progress_changed()
# Ürün §10: sağlayıcı ya da kapasite değişti. Tek kaynak ProductState'in write-through
# seam'leri (set_infra_provider / set_infra_units); kapasite yüzeyleri poll etmez.
signal infra_changed()

# --- GDD ÜRÜN rev 6.1 §19 · OKUMA YÜZEYİNİN SİNYALLERİ ---
# Dinleyicisi olmasa da yayınlanır; eksik bir ad içeriğin o ana atıfta bulunamaması demektir.
# Adlar KARARLIDIR ve her birinin TEK emitter'ı vardır: iki emitter motora aynı anı iki kez gösterir.
signal version_shipped(version: int)
signal build_started(build_id: String)
signal build_paused(reason_key: String)
signal build_resumed()
signal fix_run_started(confirmed: int)
signal fix_run_finished(shipped: int, remaining: int)
signal bug_confirmed(total_confirmed: int)
signal unconfirmed_threshold_crossed(band: String)
signal axis_floor_warning(axis: String)
signal axis_floor_crossed(axis: String)
signal line_upgraded(line_id: String, tier: int)
signal line_completed(line_id: String)
signal delighter_shipped(step_id: String)
signal phase_bar_raised(phase: int)

# --- GDD AR-GE MODÜLÜ §10 · OKUMA YÜZEYİNİN SİNYALLERİ ---
# Ürün bloğuyla aynı yasa; tek emitter RnDSystem.
signal research_started(node_id: String)
signal research_completed(node_id: String)
signal research_frozen(node_id: String)
signal research_resumed(node_id: String)
signal node_revealed(node_id: String)
signal hidden_line_unlocked(line_id: String)
signal product_note_issued(day: int)

# §10 listesinde olmayan iki ek:
#   research_progress_changed: gün-sınırı tazeleme kancası (day_advanced tick'lerden ÖNCE atılır).
#   product_note_read: rozet bu sinyal olmadan temizlenemez.
signal research_progress_changed()
signal product_note_read()

# Ar-Ge deep-link (§2): tab_changed("rnd") SENKRON mount eder, ardışık emit güvenli.
# open_assign: barın "ata" bağı true, Konsept'in "→ Araştır" bağı false.
signal rnd_node_requested(node_id: String, open_assign: bool)

# §5.8 / §6.1 PanelLayer kartları. RnDSystem yayınlar, main.gd mount eder.
signal rnd_card_requested(kind: String, data: Dictionary)

# --- Rival signals (Product Lifecycle Part 1) ---
# rival_advanced fires once per day after advance_all so the ODA league repaints.
signal rival_status_changed(rival_id: String, status: String)
signal rival_advanced()

# --- PostShip / sales signals ---
signal prospect_added(prospect_id: String)
signal prospect_removed(prospect_id: String)
# Sales tab "Görüşmeye git" → main.gd opens the pitch in the shared MeetingScene.
signal pitch_requested(prospect_id: String)
# A sales sitting ended (any outcome); Sales/Hunt tabs repaint.
signal pitch_finished()

# --- SATIŞ rev 6 §14 · the module's signal vocabulary ------------------------
# One publisher each, published whether or not anything listens (§15.1). None can trigger a
# card: EvSignals.BINDINGS has no sales row; sales raises cards through EventGate.request.
signal prospect_arrived(prospect_id: String)          # §3 — the faucet produced a lead
signal lead_expired(prospect_id: String)              # §4 — "Beklemekten vazgeçti."
signal lead_reserved(prospect_id: String)             # §7.2.1 — "Ayır"
signal lead_routed(prospect_id: String)               # §7.2.1 — "Temsilciye ver"
signal meeting_entered(prospect_id: String)           # §5.0 — the founder sat down
signal meeting_won(prospect_id: String)               # §5.1.1 — the customer cut to Act 2
signal meeting_lost(account_key: String, reason: String)  # §5.2 — with the NAMED reason
signal deal_signed(customer_id: String, seats: int, seat_price: int)   # §5.3 — İmzala
signal deal_walked(account_key: String)               # §5.3 — neutral walk
signal rep_deal_closed(rep_id: String, customer_id: String)            # §7.6
signal rep_discount_requested(rep_id: String, prospect_id: String)     # §7.6 — the price-break moment
signal pitch_promise_made(account_key: String, feature_id: String)     # §6
signal pitch_promise_kept(account_key: String)        # §6
signal pitch_promise_broken(account_key: String)      # §6
signal whale_condition_met(prospect_id: String)       # §8 — the telegraphed item was satisfied
signal weekly_sales_report_issued(closes: int)        # §7.3
signal price_stance_changed(stance: String)           # §7.5
signal rep_band_cap_changed(rep_id: String)           # §7.2.2
# Frank's advisory line; the mentor surfaces read it.
signal mentor_advisory_changed(text: String)

# Live ticker line: the ONLY non-modal notification channel. `source` is the attribution shown
# in accent ("Atlas Seçme & Yerleştirme", "İK"). For beats that must NOT interrupt the player.
signal headline_added(source: String, text: String)

# --- Endgame signals (ENDGAME_DESIGN.md §2/§3) ---
# Gate condition satisfied. Phase has NOT changed yet; phase_changed fires after advance_phase().
signal phase_gate_reached(next_phase: int)
# Terminal reached. ending_data: EndingsSystem._build_ending_data snapshot + the caller's extra.
signal run_ended(ending_id: String, ending_data: Dictionary)
# A win the company lives through (EndingsSystem.trigger_milestone): same payload as run_ended
# plus "mode": "milestone"; the run CONTINUES after "Devam et".
signal milestone_reached(milestone_id: String, ending_data: Dictionary)
# Kepenk counter. -1 = inactive/cleared; N..0 = counting.
signal shutter_changed(days_left: int)
# A calendar month closed; shape on MonthSummarySystem._build_summary_data. main.gd mounts the modal.
signal month_ended(summary_data: Dictionary)

# --- Cinematic dialogue shell (Spec 5) — MeetingScene ---
# view_state is the dict MeetingScene.populate() consumes; main.gd mounts the scene into
# ModalLayer and relays choice_selected.
signal meeting_scene_requested(view_state: Dictionary)

# --- VC Pitch / Series A Hunt signals (Spec 4 / VC_PITCH_DESIGN.md §7) ---
signal sheet_granted(vc_id: String)             # term sheet delivered into active_sheets
signal sheet_expired(vc_id: String)             # validity clock hit 0 — NOT a rejection
signal callback_ready(vc_id: String)            # callback condition met; door reopened
signal meeting_day(vc_id: String)               # a booked meeting's day arrived
signal offer_countdown_changed(days_left: int)  # min sheet validity ≤ threshold; -1 = hide chip
signal term_table_requested(vc_id: String)      # Finance>Yatırım "Masaya otur" / deal-prompt → main mounts the table
signal sheet_walked(vc_id: String)              # a table walk destroyed a sheet — HuntTab repaints

# --- Seed round (GDD v2 ch. 09 §3) — the middle rung. One publisher each. ---
# seed_door_opened unlocks Finance > Yatırım in Traction.
signal seed_door_opened()                       # SeedRoundSystem.daily_tick latched the ratchet
signal seed_sheet_granted(vc_id: String)        # VCPitchSystem._grant_seed_sheet — an offer exists
signal seed_round_closed(vc_id: String)         # SeedRoundSystem.accept — money in, expectation armed

# --- Save / system-menu signals (SaveManager task) ---
# END of TimeManager._dispatch_daily_tick, once every daily slot has settled: the only correct
# autosave boundary (day_advanced fires before the slots run).
signal day_tick_completed(day: int)
# A save slot finished restoring AND the shell has been remounted, so every shell child has
# already painted; for surfaces that need a post-mount nudge. Payload = slot id.
signal game_loaded(slot_id: String)
# ESC on the shell with nothing open → main.gd mounts SystemMenuModal.
signal system_menu_requested
# System menu → main.gd mounts SaveLoadModal. mode = "save" | "load".
signal save_load_requested(mode: String)
# F5 / F9, release builds too. main.gd owns the orchestration because a quickload is the full
# teardown → reset → restore → remount sequence.
signal quicksave_requested
signal quickload_requested

# --- Debug signals (OS.is_debug_build only; emitter game_shell.gd) ---
# Shift+F4 re-triggers onboarding on a running game (screenshot capture).
signal debug_onboarding_retrigger_requested
