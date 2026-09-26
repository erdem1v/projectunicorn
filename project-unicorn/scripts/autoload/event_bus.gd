extends Node

# Global signal hub.
# Singletons and systems emit signals here; scenes connect to update themselves.
# Scenes connect on tree-enter, disconnect on tree-exit.

# --- State change signals (§13.2) ---
signal cash_changed(new_value: int)
signal mrr_changed(new_value: int)
signal burn_changed(new_value: int)
signal brand_changed(new_value: int)
signal reputation_changed(new_value: int)
signal day_advanced(new_day: int)
signal hour_changed(hour: int)            # 0-23, emitted every in-game hour boundary
signal phase_changed(new_phase: int)
signal runway_recalculated(months: float)
# Cap table moved (Frank's angel round today; Series B later). Payload = TOTAL investor
# percent, GameState.get_investor_equity_pct(). Exists because the Finance cap-table bar
# otherwise repaints only as a side effect of the cash write that happens to accompany a
# round — true for the angel seam by construction, false for the first equity change that
# moves no cash (an option pool, a secondary, a re-cap).
signal equity_changed(investor_pct: int)

# --- UI / time signals (§13.2) ---
signal speed_change_requested(speed: int)  # 0=pause, 1=1x, 2=2x, 3=3x (4x removed 2026-08-19)
# ODA rework: "" = sekme yok, oda görünür (varsayılan durum). Sekme id'leri, ray
# sırasıyla: "product", "sales", "hr", "finance", "personal", "marketing", "rnd",
# "events". "marketing" ve "rnd" KİLİTLİ — rayda görünür ama tıklanamaz, yani bu
# sinyal onları hiç taşımaz. ("ops" 2026-08-20'de kaldırıldı; kimse emit etmiyordu.)
signal tab_changed(tab_id: String)
# Kâğıt deep-link'i (ODA rework §5.3): mount edilmiş Finance sekmesine alt sayfa
# seçtirir ("ozet"|"yatirim"). tab_changed("finance") emit'i SENKRON mount eder,
# ardışık emit bu yüzden güvenli — handler bağlanmış olur.
signal finance_subpage_requested(page_id: String)

# --- Settings / audio signals ---
# Gear button (below the left tab column) → main.gd mounts SettingsModal
# (same lifecycle as modal_requested: pause on open, restore on close).
signal settings_requested
# Genel amaçlı onay modalı isteği (main.gd ModalLayer'a ConfirmModal mount eder).
# config: {title, body, confirm_text, cancel_text, on_confirm: Callable}
# İlk kullanıcı: Tracker Card build-iptal çarpısı.
signal confirm_requested(config: Dictionary)
# AudioManager emits these when the prefs change so any UI can reflect state
# without polling. music_volume is linear 0..1.
signal music_enabled_changed(enabled: bool)
signal music_volume_changed(volume: float)
# Localization: emitted by the Localization autoload when the language
# changes so live surfaces re-translate (e.g. TopBar runway). Payload = locale "tr"/"en".
signal language_changed(locale: String)
# Accessibility: the colourblind-safe semantic palette was toggled. Semantic colour is
# never baked into master_theme.tres (build_theme.gd holds zero POSITIVE/NEGATIVE refs),
# so the swap is a pure runtime repaint — UiTokens resolves the pair, this signal tells
# live surfaces to re-read it. Payload = true when the CB palette is active.
# Same self-healing grammar as language_changed: resident shell children repaint in
# place, the open tab page rebuilds via a tab_changed re-emit.
signal palette_changed(colorblind: bool)

# --- Character signals (§13.2) ---
signal character_added(character_id: String)
signal character_removed(character_id: String)
signal morale_changed(character_id: String, new_morale: int)
## DENEYİM biriktiğinde / sıfırlandığında (Terminal UI görevi). Defter satırı
## mini-barı bu sinyalle tazeler.
signal employee_experience_changed(character_id: String, new_experience: int)
## Eğitim başladığında, her gün ve bittiğinde (0 = bitti/eğitimde değil).
signal employee_training_changed(character_id: String, days_left: int)
## §9.3 terfi. §15.3'ün sinyal listesindeki `employee_eligible_for_promotion` ile
## KARIŞTIRILMAZ: bu OLAN terfiyi bildirir, o UYGUN HÂLE GELMEYİ. İkincisi olay motorunun
## kenar yakalaması için (§17.3) ve Faz 4'te açılıyor.
signal employee_promoted(character_id: String, new_level: int)

# ---------------------------------------------------------------------------
# §15.3 · OLAY MOTORUNA AÇILAN SİNYAL LİSTESİ
# ---------------------------------------------------------------------------
# "Dinleyicisi olmasa da BUGÜN yayınlanır, adları KARARLIDIR." Motor geldiğinde işi
# bunları okumak olacak, keşfetmek değil (§17.3). Eskiler (character_added/_removed,
# morale_changed, employee_experience_changed) canlı tüketicileriyle birlikte duruyor ve
# Faz 7'de emekli oluyor; §15.3'ün adlandırdıkları yanlarına geliyor.

## §5.1 barın DOLDUĞU AN — her gün değil, KENAR. §17.3 motorun bugün kenar yakalayamadığını
## ("Morali 35'i geçtiği an" yoklama modelinde yakalanamıyor) bir mimari borç olarak
## yazıyor; bu sinyal o borcun Ekip tarafındaki karşılığı.
signal experience_bar_full(character_id: String)

## §7 bandın DEĞİŞTİĞİ an (80 / 50 / 35 sınırları). Puan puan değil, BANT — çünkü motorun
## soracağı soru "morali kaç" değil "hangi banda düştü".
signal morale_band_changed(character_id: String, band_id: String)

## §9.3. HR BUNU YAYINLAMIYOR ve sebebi belgede: §9.3 terfiye seviye tavanı dışında bir
## KOŞUL vermiyor, yani ateşlenecek GDD tanımlı bir kenar yok. Kenarı seçmek (bir yıllık
## kıdem? dolmuş bar? yıldız eşiği?) bir tasarım hükmü olurdu; ad kararlı olarak yayınlanıyor,
## kenar bekliyor.
signal employee_eligible_for_promotion(character_id: String)

## §9.2. HR BUNU DA YAYINLAMIYOR: "Çalışandan gelen zam talebi AYRI BİR OLAYDIR ve olay
## motorunun konusudur." HR'ın yayınlaması, HR'ın olayı yazması olurdu.
signal raise_requested(character_id: String)

## §11.4 izin talebi. Kart olay motorunun (§17.3) ama TALEP bu modülden doğuyor — yaz
## haftası geldiğinde HR bunu yayınlar ve motor geldiğinde kartı buna bağlar.
signal leave_requested(character_id: String)

signal employee_hired(character_id: String)
signal employee_departed(character_id: String)
signal training_started(character_id: String, area_key: String)
signal training_completed(character_id: String, area_key: String)
## Görev ataması değiştiğinde (§12.0): atandı, çıkarıldı ya da ayrılma
## anında işleri boşaldı. TEK argüman kişidir, iş değil — bir atama değişikliği o kişinin
## SATIRINI ve etkilediği HER işin doluluk okumasını birden tazeler, o yüzden dinleyen
## taraf zaten iki tarafa da bakmak zorunda. CharacterRegistry tek yayıncıdır.
signal assignment_changed(character_id: String)
# Emitted at the END of HRSystem.daily_tick, once all seven HR steps have settled — the HR
# tab's day-boundary repaint hook. Exactly the same reason build_progress_changed exists:
# day_advanced fires inside GameState.advance_day(), which TimeManager calls BEFORE the daily
# ticks dispatch, so a repaint on day_advanced would read PRE-tick HR state (Atlas strip one
# day behind, arriving candidate files invisible until the next day). No payload — a repaint
# hook, not a data channel; every number is still read from the owning system.
signal hr_day_processed()

# Emitted at the END of NewsFeedSystem.daily_tick (slot 7), once the day's news lines are
# composed — the ticker's day-boundary repaint hook. Same rationale as hr_day_processed:
# day_advanced fires BEFORE the daily ticks dispatch, so a feed repaint on day_advanced
# would read yesterday's stream. No payload — read NewsFeedSystem.get_stream().
signal news_stream_changed()

# --- Customer signals (§13.2) ---
signal customer_added(customer_id: String)
signal customer_removed(customer_id: String)
signal customer_mrr_changed(customer_id: String, new_mrr: int)
signal customer_seats_changed(customer_id: String, new_seats: int)
signal customer_satisfaction_changed(customer_id: String, new_satisfaction: int)

# --- B2B lifecycle / relationship signals (B2B Sales System) ---
# health/phase changes drive the portfolio health display + the churn countdown
# ("Churn'e ~N gün"); churned/expanded are discrete account moments; assigned
# tracks Customer-Success delegation.
signal customer_health_changed(customer_id: String, phase: String)
signal customer_churned(customer_id: String)
signal customer_expanded(customer_id: String, new_seats: int)
signal customer_assigned(customer_id: String, employee_id: String)
# Promise tracking (B2B Sales System §C). "Söz ver" / a CS escalation create a
# promise; a Product feature ship keeps it, a passed deadline breaks it.
signal promise_created(promise_id: String)
signal promise_kept(promise_id: String)
signal promise_broken(promise_id: String)

# --- Event signals (§13.2) ---
signal event_triggered(event_id: String)
signal event_resolved(event_id: String, choice_index: int)
signal modal_requested(event: GameEvent)

# --- Build / product signals ---
# Emitted by ProductSystem whenever current_phase transitions. BuildHUDPanel
# subscribes to drive its faz-aware paint instead of polling active_build.
signal build_phase_changed(new_phase: String)
# Build Bar 2026-08-19 (Software Inc. segment grameri): turlar kendi kendine döner;
# true YALNIZ tavan parkında (ITER_MAX_ROUNDS'a gelindi), oyuncu "Geliştirmeye geç"
# deyince ya da yeni tur başlayınca false. Emitter'lar ProductSystem'de
# (_pend_iteration_decision / _start_next_round / enter_development); BuildHUDPanel ve
# BuildBar bağlanır, creation_flow zaten build_progress_changed üzerinden repaint oluyor.
signal build_iteration_decision_pending(pending: bool)
# Emitted at the END of ProductSystem.daily_tick (after the phase tick advances
# its counters), so build progress bars repaint with the post-tick value.
# day_advanced fires BEFORE the tick decrements the counter, which made the bar
# lag a day and read empty on day 1 then jump (Faz 1 bug 1.1).
signal build_progress_changed()
# Ürün rev 6.1 §10 — sağlayıcı ya da kapasite değişti. ProductState'in write-through
# seam'lerinden çıkar (set_infra_provider / set_infra_units), yani kim değiştirirse
# değiştirsin tek bir yerden haber verilir. Kapasite bloğu, doluluk çubuğu, brüt
# marj satırı ve fatura kalemi bunu dinler; hiçbiri poll etmez.
signal infra_changed()

# --- GDD ÜRÜN rev 6.1 §19 · OKUMA YÜZEYİNİN SİNYALLERİ ---
# "Sinyaller (dinleyicisi olmasa da yayınlanır)". Bugün hiçbirinin abonesi yok ve
# bu KASITLI: eksik bir ad, içeriğin o ana asla atıfta bulunamaması demektir
# (§19'un attribution yasası). Adlar KARARLIDIR; iç yapı değişse de korunurlar.
# Her birinin TEK emitter'ı vardır — iki emitter, olay motoruna aynı anı iki kez
# gösterir ve sebebini bulmayı imkânsızlaştırır.
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
# Aynı yasa yukarıdaki Ürün bloğuyla: dinleyicisi olmasa da yayınlanır, adlar KARARLIDIR,
# ve her birinin TEK emitter'ı vardır. Emitter RnDSystem'dir.
signal research_started(node_id: String)
signal research_completed(node_id: String)
signal research_frozen(node_id: String)
signal research_resumed(node_id: String)
signal node_revealed(node_id: String)
signal hidden_line_unlocked(line_id: String)
signal product_note_issued(day: int)

# §10'un listesinde OLMAYAN iki ek, ikisi de yan kapıdaki precedent'le:
#   research_progress_changed — bar ve tracker'ın gün-sınırı tazeleme kancası. day_advanced'e
#   bağlanamaz: o GameState.advance_day() İÇİNDE, TimeManager günlük tick'leri dağıtmadan
#   ÖNCE atılıyor (hr_tab.gd:15-19 aynı tuzağı yazıyor). `build_progress_changed` §19'un
#   bloğunun DIŞINDA tam olarak bu sebeple duruyor.
#   product_note_read — rozet bu sinyal olmadan asla temizlenemez.
signal research_progress_changed()
signal product_note_read()

# Ar-Ge deep-link (§2): tab_changed("rnd") emit'i SENKRON mount eder, ardışık emit bu yüzden
# güvenlidir — handler bağlanmış olur (finance_subpage_requested precedent'i, :31-34).
# open_assign: barın "ata" bağı true, Konsept'in "→ Araştır" bağı false gönderir.
signal rnd_node_requested(node_id: String, open_assign: bool)

# §5.8 / §6.1 — PanelLayer kartları. RnDSystem yayınlar, main.gd mount eder.
signal rnd_card_requested(kind: String, data: Dictionary)

# --- Rival signals (Product Lifecycle Part 1) ---
# Emitted by RivalRegistry. rival_status_changed when a
# rival's display band flips; rival_advanced once per day after advance_all so
# the ODA board league repaints (RightPanel retired — ODA rework 2026-08-06).
signal rival_status_changed(rival_id: String, status: String)
signal rival_advanced()

# --- PostShip / sales signals ---
# Prospect pool changes (Sales tab repaints). Mirrors customer_added/removed.
signal prospect_added(prospect_id: String)
signal prospect_removed(prospect_id: String)
# Sales tab "Görüşmeye git" → main.gd routes to B2BPitchMeeting, which renders the
# pitch in the shared MeetingScene (pause on open, restore on close).
signal pitch_requested(prospect_id: String)
# Emitted when a sales sitting ends (any outcome) so the Sales/Hunt tabs repaint. Speed
# restore + scene teardown happen in main.gd's dialogue close path. Publisher: the meeting
# system, which replaced B2BPitchMeeting in SATIŞ rev 6.
signal pitch_finished()

# --- SATIŞ rev 6 §14 · the module's signal vocabulary ------------------------
# Eighteen names, ONE publisher each, published whether or not anything listens — the
# engine's convention (§15.1), and the reason it holds here is that the event package
# arrives later and must find the vocabulary already spoken rather than invent it.
#
# NONE OF THESE CAN TRIGGER A CARD TODAY. `EvSignals.BINDINGS` is an engine allowlist with
# no sales row, and this module edits no engine file. Sales raises cards the way the tab
# already did — `EventGate.request(...)` with a `tick: "request"` card — so the binding
# table is a thing the event package opens when it wires the demand store, not a thing this
# task needed.
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
# Frank's advisory line — updated by intro/customer events/traction. Its RightPanel
# home retired with the ODA rework; the mentor surfaces read it now.
signal mentor_advisory_changed(text: String)

# Live ticker line. The ONLY non-modal notification channel: a system pushes one line and
# NewsTicker scrolls it ahead of the ambient pool. `source` is the attribution shown in
# accent ("Atlas Seçme & Yerleştirme", "İK"). Use this for beats that must NOT interrupt
# the player — candidate files arriving, an employee going on leave.
signal headline_added(source: String, text: String)

# --- Endgame signals (ENDGAME_DESIGN.md §2/§3) ---
# Gate condition satisfied (slot 8). Phase has NOT changed yet — the transition
# is played inside the Frank scene; phase_changed fires only after advance_phase().
signal phase_gate_reached(next_phase: int)
# Terminal reached (slot 9 scan or Class A instant). ending_data: snapshot dict
# built by EndingsSystem._build_ending_data (title/tone/frank_line + run stats).
signal run_ended(ending_id: String, ending_data: Dictionary)
# A win the company lives through (EA / full builds, EndingsSystem.trigger_milestone): the
# paper opens in milestone mode and the run CONTINUES. Same payload shape as run_ended,
# plus "mode": "milestone". main.gd mounts the paper and resumes the clock on "Devam et".
signal milestone_reached(milestone_id: String, ending_data: Dictionary)
# Kepenk counter. -1 = inactive/cleared; 7..0 = counting. TopBar listens.
signal shutter_changed(days_left: int)
# Month-End Summary: emitted by MonthSummarySystem (daily slot
# 10) when a calendar month closes. summary_data shape is documented on
# MonthSummarySystem._build_summary_data. main.gd mounts MonthSummaryModal.
signal month_ended(summary_data: Dictionary)

# --- Cinematic dialogue shell (Spec 5) — MeetingScene ---
# view_state is the dict populate() consumes (contract on MeetingScene). It fires from a
# debug fixture (game_shell Shift+F2) and from VCPitchSystem/B2BPitchMeeting with a real
# view state; main.gd mounts the scene into ModalLayer and relays choice_selected.
# (A sibling `frank_popup_requested` lived here until 2026-08-20. Its one production
# caller — the deal-closed prompt — is an ordinary Frank event card now, so Frank speaks
# on the same surface as everyone else and the second cinematic shell was retired.)
signal meeting_scene_requested(view_state: Dictionary)

# --- VC Pitch / Series A Hunt signals (Spec 4 / VC_PITCH_DESIGN.md §7) ---
# Roster + Teklifler panel repaint from these; TopBar chip from offer_countdown_changed.
signal sheet_granted(vc_id: String)             # term sheet delivered into active_sheets
signal sheet_expired(vc_id: String)             # validity clock hit 0 — NOT a rejection
signal callback_ready(vc_id: String)            # callback condition met; door reopened
signal meeting_day(vc_id: String)               # a booked meeting's day arrived
signal meeting_requested(vc_id: String)         # Hunt "TOPLANTI İSTE" → VCPitchSystem schedules
signal offer_countdown_changed(days_left: int)  # min sheet validity ≤ threshold; -1 = hide chip
signal term_table_requested(vc_id: String)      # Finance>Yatırım "Masaya otur" / deal-prompt → main mounts the table
signal sheet_walked(vc_id: String)              # a table walk destroyed a sheet — HuntTab repaints

# --- Seed round (GDD v2 ch. 09 §3) — the middle rung. One publisher each. ---
# seed_door_opened is what unlocks Finance > Yatırım in Traction: the sub-page lock used to be
# a bare `phase < 3` and the seed rung opens the page two phases early.
signal seed_door_opened()                       # SeedRoundSystem.daily_tick latched the ratchet
signal seed_sheet_granted(vc_id: String)        # VCPitchSystem._grant_seed_sheet — an offer exists
signal seed_round_closed(vc_id: String)         # SeedRoundSystem.accept — money in, expectation armed

# --- Save / system-menu signals (SaveManager task) ---
# Emitted at the very END of TimeManager._dispatch_daily_tick, once all twelve daily
# slots have settled. NOT a duplicate of day_advanced: that one fires inside
# GameState.advance_day(), which TimeManager calls BEFORE the ticks dispatch, so an
# autosave hooked there would snapshot PRE-tick state (yesterday's finance, yesterday's
# HR). Same rationale that already justifies hr_day_processed / news_stream_changed /
# build_progress_changed — this is the run-state-settled hook, and it is the only
# correct autosave boundary.
signal day_tick_completed(day: int)
# A save slot finished restoring AND the shell has been remounted. Payload = slot id.
# Load order is teardown → reset_all_owners → initialize_run(restore) → registries →
# remount, so every shell child has already painted from GameState by the time this
# fires; it exists for surfaces that need a post-mount nudge, not for the initial paint.
signal game_loaded(slot_id: String)
# ESC on the shell with no tab page, no ModalLayer child and no PanelLayer child.
# main.gd mounts SystemMenuModal (pause on open, restore prior speed on close) — the
# same lifecycle as settings_requested.
signal system_menu_requested
# System menu → main.gd mounts SaveLoadModal. mode = "save" | "load".
signal save_load_requested(mode: String)
# F5 / F9. game_shell stays a pure input router (same shape as
# speed_change_requested / debug_onboarding_retrigger_requested) — main.gd owns
# the orchestration, because a quickload is the full teardown → reset → restore →
# remount sequence and only main.gd holds the shell and the modal refs.
# These fire in release builds too: the two debug endgame fixtures that used to
# own F5/F9 moved to Ctrl+F5 / Ctrl+F9 precisely so the binding cannot behave
# differently in dev than it does for the player.
signal quicksave_requested
signal quickload_requested

# --- Debug signals (OS.is_debug_build only; emitter game_shell.gd) ---
# Shift+F4 re-triggers onboarding on a running game (screenshot/mockup capture).
# main.gd tears down the shell and remounts OnboardingFlow. No-op in release.
signal debug_onboarding_retrigger_requested
