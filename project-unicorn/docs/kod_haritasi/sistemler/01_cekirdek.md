# Çekirdek: autoload, kayıt ve göç, zaman, ayarlar, ses

Dizin sha: f3113fa4 (DIZIN.md başlığı, 2026-10-22). Yollar `project-unicorn/` köküne göredir; satır numaraları diskteki (kirli ağaç) hâldir.

Ne yapar: 14 autoload koşunun durumunu (GameState), saat ve haftalık tik dağıtımını (TimeManager), kayıt/yükleme/göçü (SaveManager), kalıcı ayarları, dili ve müziği taşır.
EventBus sinyal merkezidir; beş kayıt defteri (karakter, müşteri, aday, söz, rakip) ve yatırımcı tablosu veriyi tutar. Veri modelleri düz `Resource`tur; `SaveCodec` onları `@export` alanlarından yazar.
Yardımcı: `Fmt` konuma duyarlı biçimlendirme. Dışarıdan: `TimeModel`, `SaveCodec`, `RngStreams`, `EvSave` `scripts/systems/` ve `scripts/events/core/` altındadır; burada yalnız bağlantı noktaları anılır.
Kaynak: Çekirdek ve zaman için GDD ch01 ve GDD Zaman Modeli (§10 kayıt göçü kuralları); Kayıt ile Platform bölümlerinin GDD atfı yok.
Sahipler (Çekirdek): autoload `GameState`, `TimeManager`, `EventBus`; sınıf `TimeModel`, `RngStreams`, `SkillCheck`, `Fmt`. Sahipler (Kayıt): autoload `SaveManager`; sınıf `SaveCodec`.
Sahipler (Platform): autoload `Settings`, `Localization`, `AudioManager`; sınıf `DisplaySettings`; yol ile yüklenen `graphics_settings.gd` (`Settings` preload eder).

## Dosyalar
- `project.godot:24-39` (autoload): sıra EventBus, GameState, 5 kayıt defteri (Character..Rival), InvestorRegistry, TimeManager, SaveManager, Settings, Localization, AudioManager, MCPRuntime
- `scripts/autoload/event_bus.gd` (301): 145 sinyal, durumsuz; `# --- X ---` başlıkları `tools/gen_signal_manifest.py` bölümleridir
- `scripts/autoload/game_state.gd` (1004): koşunun tüm skaler ve liste durumu; her `var` kayıt şemasıdır; setter'lar sinyal yayar; `initialize_run` yeni koşu ve yükleme tabanı
- `scripts/autoload/time_manager.gd` (451): saat birikimi, hız, tutuş/donma, gece atlama, günlük ve saatlik tik dağıtımı, saat bloğunun kaydı
- `scripts/autoload/save_manager.gd` (1289): yuva politikası, atomik yazım, autosave, yükleme, `reset_all_owners`, v10 → v19 göç zinciri ve smoke'a kalan eski göçler
- `scripts/autoload/settings.gd` (174): `user://settings.json` kalıcılığı, `DEFAULTS` şeması, `apply_all` ile sahibine dağıtım
- `scripts/autoload/localization.gd` (114): `strings.csv`'yi Translation'a yükler, `--lang=`, ilk açılışta dil seçimi, `pick`
- `scripts/autoload/audio_manager.gd` (172): Music/SFX bus'ları, tek döngü parçası, ses ayarlarını uygular ve geri yazar, odak kaybında susturur
- `scripts/autoload/character_registry.gd` (627): çalışan, kurucu, mentor ve NPC tek doğruluk kaynağı; yazma yalnız buradan (write-through)
- `scripts/autoload/customer_registry.gd` (321): müşteri hesapları; MRR, koltuk, memnuniyet yazımı sinyal yayar
- `scripts/autoload/prospect_registry.gd` (73): imzasız B2B adaylar; imzada Customer olur ve buradan çıkar
- `scripts/autoload/promise_registry.gd` (187): müşteriye verilen sözler; `build_phase_changed` ve `customer_removed` dinler
- `scripts/autoload/rival_registry.gd` (210): rakip alanı; `RivalCatalog`tan tohumlanır, `advance_all` günlük tikte
- `scripts/autoload/investor_registry.gd` (145): Seri A fon tablosu (const); koşu durumu `GameState.vc_states`te
- `scripts/data_models/character.gd` (106): `Character` Resource (kimlik, maaş, moral, `role_stats`, atama, izin, eğitim, verim satırları)
- `scripts/data_models/customer.gd` (124): `Customer` Resource (B2B/B2C hesap, iki katmanlı memnuniyet, churn sayacı, `market_ref`)
- `scripts/data_models/prospect.gd` (111): `Prospect` Resource (aday, yıldız, arketip, anlaşma alanları)
- `scripts/data_models/promise.gd` (22): `Promise` Resource (söz: müşteri, özellik, vade, durum)
- `scripts/data_models/rival.gd` (38): `Rival` Resource (tier, üç boyut, momentum, `composite()`)
- `scripts/data_models/term_sheet.gd` (63): `TermSheet` Resource (Seri A ve seed teklifi, vade, `opening_terms`)
- `scripts/data_models/event.gd` (21) ve `event_choice.gd` (11): `GameEvent`/`EventChoice` kartın çizim görünümü; asla kaydedilmez
- `scripts/util/fmt.gd` (223): `Fmt` para, yüzde, tarih, ay adı, büyük harf, `cap_first`; yerel veri strings.csv'dedir
- `scripts/systems/display_settings.gd` (350): `DisplaySettings`, pencere kipi, çözünürlük, vsync, UI ölçeği; durumsuz, `Settings` saklar bu uygular; `is_inert()` harness pencereyi sahiplenince her çağrıyı keser
- `scripts/systems/graphics_settings.gd` (211): class_name yok (`Settings` preload eder); 3B görüntü kalitesi, 4 ön ayar `data/graphics/presets.json`, `OfficeView.apply_graphics`; `--gfx=<ön ayar>`
- `scripts/main/main.gd` (5430): ana sahne kökü; açılış (Godot kartı → menü → onboarding → kabuk), modal montajı, karar kapısı (`hold_clock("event")`), kayıt/yükleme ve yolculuk akışı
  ↳ modal ve menü giriş noktaları 09_arayuz_bilesen.md'de, debug bayrak dağıtıcısı ve `--*-shot` koşucuları 10_test_harness.md'de
- `scripts/main/game_shell.gd` (240): `GameShell.tscn` kökü (grup `game_shell`, ALWAYS); Esc zinciri `_input` `game_shell.gd:55`, `request_speed` `:114`, `say_held` `:126`, şerit yerleşimi, sprint kapanınca Ürün'ü açar
  ↳ debug F tuşları `_debug_fkey` `:138`, `_debug_endgame_key` `:192` (10_test_harness.md, 05_fon_finans.md)
- Komşular (kapsam dışı ama bağlı): `scripts/systems/save_codec.gd` (298), `time_model.gd` (50), `rng_streams.gd` (79), `scripts/events/core/save.gd` (103)

## Giriş noktaları
- `GameState.initialize_run(payload)` `scripts/autoload/game_state.gd:769`: yeni koşu ve her yükleme · `scripts/onboarding/onboarding_flow.gd:202`, `scripts/main/main.gd:627,5346`, `save_manager.gd:303`, harness'ler
- `GameState.set_cash/set_mrr/set_daily_burn/set_brand/set_reputation` `game_state.gd:340-362`: dışarıdan tek yazma yolu; sinyal yayar ve runway'i yeniden hesaplar
- `GameState.advance_day()` `game_state.gd:365` ve `set_current_hour()` `:369`: yalnız TimeManager çağırır; `GameState.advance_phase()` `:383` kapı açıkken Frank kartı
- `GameState.set_flag/get_flag/flag_type_for` `game_state.gd:441,470,448`: tipli bayrak; kayıt tipi `FLAG_TYPES` `:48` ve `FLAG_TYPE_PREFIXES` `:126` verir
- `GameState.get_date_dict(tick)` `game_state.gd:665`: tik → takvim (1 Oca 2012 Pazar + 7 gün × tik); `get_run_ledger()` `:675` bitiş ekranının tek okuma yüzü
- `TimeManager._process` `time_manager.gd:96` → `_advance_real` `:100`: gerçek zamanı oyun saatine çevirir · motor her kare
- `TimeManager._step_hour` `time_manager.gd:144`: bir oyun saati; 00:00'da `advance_day` ve günlük tik · `_drain_boundaries` `:127`, `_run_batch` `:193`
- `TimeManager.advance_hours(n, meeting)` `time_manager.gd:173` · `scripts/main/main.gd:1311,1315,1319,2166`, `scripts/systems/sales_meeting_system.gd:119`, `term_sheet_table_system.gd:574`
- `TimeManager.skip_night()` `time_manager.gd:183`: gecenin saatlerini tek toplu adımda koşar · `_advance_real` içinden; `scripts/main/main.gd:1300` (gece probe'u)
- `TimeManager.hold_clock/release_clock` `time_manager.gd:350,359` · `main.gd:2160,4744,5268` (milestone_paper, event),
  ↳ `incident_system.gd:311`, `sprint_system.gd:1867` (plan bekliyor ve saat mesai başlangıcında), `scripts/tabs/product_tab.gd:340,342`
- `TimeManager.freeze_clock/thaw_clock` `time_manager.gd:250,256` · yolculuk için `main.gd:4957,4981` (`tree_runs` true), çekimlerde `main.gd:2053,2132`
- `TimeManager.register_night_gate/unregister_night_gate` `time_manager.gd:264,269` · `scripts/ui/office/office_people.gd:100,104` (ofis boşalma yüklemi)
- `TimeManager._dispatch_daily_tick` `time_manager.gd:385` ve `_dispatch_hourly_tick` `:439`: sistem sırası burada; yeni sistem tiki buraya takılır. Günlük sıra: `SummarySystem.begin_day` (yuva 0),
  ↳ ürün (`ProductSystem`, `SprintSystem`, `SupportSystem`, `InfraSystem`, `ProductRead.emit_edges`), Ar-Ge, ekip, satış, `CharacterRegistry.prune_productivity_mods`, rakipler, ofis, finans, faz kapısı ve seed, olaylar,
  ↳ `IncidentSystem.daily_tick`, haber, VC, sonlar, `SummarySystem.daily_tick` (yuva 10), `MailClock.sync_desk`; gün `EventBus.day_tick_completed` ile kapanır (autosave sınırı). Saatlik sıra: `SupportSystem`, `SalesSystem`,
  ↳ `InfraSystem.auto_adjust`, `MailClock.hourly_tick`, `IncidentSystem.hourly_tick`, `EventGate.hourly_tick`; 00:00'ın saatlik dilimi `advance_day()`'den önce koşar (`TimeManager.is_rolling_over()` o dilimde doğrudur)
- `SaveManager.save_to_slot/read_slot/apply_loaded_state` `save_manager.gd:219,153,286` · `scripts/main/main.gd:5152,5200,5211`
  ↳ Göç zincirini `read_slot` değil `_read_file` `:170` koşar; `read_slot` yalnız onu çağırır ve bozuk ya da eksik hedefte slotun `.bak`'ına düşer (sonuca `from_backup`); `SAVE_ERR_NEWER` ve `SAVE_ERR_TOO_OLD` geriye düşmez
- `SaveManager.list_slots/list_runs` `save_manager.gd:120,138` · `scripts/menu/main_menu.gd:42`, `scripts/modals/save_load_modal.gd:55`
- `SaveManager.end_run()` `save_manager.gd:364`: koşuyu süreç içinde bitirir · `scripts/main/main.gd:128,5385` (menüye dönüş)
- `SaveManager.reset_all_owners()` `save_manager.gd:326`: statik/kayıtlı koşu durumunun tek sıfırlama listesi
- `SaveManager.can_save/cannot_save_reason_key/has_unsaved_progress` `save_manager.gd:81,85,99`: kayıt kapısı (karar bekliyor, oturum açık, koşu yok)
- `SaveManager.quick_slot_id/exit_slot_id/delete_slot/build_meta` `save_manager.gd:244,249,254,263`: yuva adları ve liste için meta
- `Settings.get_value/get_choice/set_value/has_stored/reset_to_defaults/apply_all/flush` `settings.gd:78,84,95,91,104,113,137` · modal ve `Display/Audio/Localization/SaveManager/TimeManager` okur
- `Localization.set_language/get_language/pick/detect_language` `localization.gd:82,35,76,67` · `scripts/modals/settings_modal.gd`; `pick` olay JSON'unu çizimde çözer
- `AudioManager.apply_from_settings/set_*_volume/set_music_enabled/set_mute_unfocused` `audio_manager.gd:77,100-130` · `scripts/modals/settings_modal.gd:172-187`, `settings.gd:125`
- `Fmt.money/percent/number/month_name/date_line/upper/cap_first` `scripts/util/fmt.gd:154,139,134,74,85,36,50`: 84 dosya kullanır; her sayı ve tarih buradan geçer
- `CharacterRegistry.add/get_character/get_founder/assign_job/prune_productivity_mods` `character_registry.gd` · HR, Finans, Ekip; `insert_raw` `:502` kayıt yüklemesi, `reset` `:565`
- `CustomerRegistry.set_mrr/set_seats/set_satisfaction/add/remove` `customer_registry.gd`; `insert_raw` `:105`, `reset` `:113`
- `RivalRegistry.advance_all()` `rival_registry.gd` · `time_manager.gd` günlük tik; `reset` `rival_registry.gd:25` katalogdan yeniden tohumlar
- `PromiseRegistry.create/extend/drop_targetless` `promise_registry.gd:50,83,105` · kart efekti `promise_create`, `SalesFinalizer`, `save_manager.gd` yüklemede

## Sinyaller
- `speed_changed(new_speed)`: yayan `time_manager.gd:321,337` (TimeManager'in kendi sinyali) · dinleyen `scripts/ui/components/top_bar.gd:120`, `sprint_system.gd:1340`, `office_notice_stack.gd:47`
- `hold_changed()`: yayan `time_manager.gd:355,361` · dinleyen `top_bar.gd:122`, `scripts/ui/office/office_notice_stack.gd:48`
- `EventBus.speed_change_requested(speed)` `event_bus.gd:21`: isteği `main.gd`, `game_shell.gd:121`, `save_manager.gd:370` yayar · dinleyen `time_manager.gd:81`
- `EventBus.day_advanced(new_day)` `event_bus.gd:12`: yayan `game_state.gd:367` · `top_bar.gd:106`, `product_tab.gd:116`, `research_bar.gd:53`
- `EventBus.hour_changed(hour)` `event_bus.gd:13`: yayan `game_state.gd:371` · `top_bar.gd:107`, `news_ticker.gd:74`, `sales_tab.gd:82`
- `EventBus.day_tick_completed(day)` `event_bus.gd:286`: yayan `time_manager.gd:432` (günlük dağıtımın sonu) · `save_manager.gd:61` autosave sınırı, `office_city.gd:102`, `plausibility.gd:159`
- `EventBus.night_skipped()` `event_bus.gd:23`: yayan `time_manager.gd:190` · `main.gd:478,2285`, `office_view.gd:64`, `office_people.gd:86`
- `EventBus.clock_batch_ended()` `event_bus.gd:25`: yayan `time_manager.gd:203` · `scripts/events/core/signals.gd:54`, `incident_system.gd:314`, `sprint_system.gd:1864`
- `EventBus.cash_changed/mrr_changed/burn_changed/brand_changed/reputation_changed/phase_changed/runway_recalculated` `event_bus.gd:7-15`: yayan `game_state.gd:342-392,764` · `top_bar.gd:100-108`
- `EventBus.language_changed(locale)` `event_bus.gd:43`: yayan `localization.gd:88`, `main.gd:3743` · `character_registry.gd:16` ve 10'dan fazla arayüz
- `EventBus.palette_changed(colorblind)` `event_bus.gd:47`: yayan `settings_modal.gd:251,282` · `left_tabs.gd:130`, `top_bar.gd:111`, `news_ticker.gd:81`
- `EventBus.month_ended(close)` `event_bus.gd:253`: yayan `scripts/systems/summary_system.gd:126` · `save_manager.gd:62` (aylık autosave)
- `EventBus.event_resolved/event_set_aside` `event_bus.gd:119,122`: `save_manager.gd:63-66` kirli bayrağı kurar ve bekleyen autosave'i yeniden dener
- `EventBus.game_loaded(slot_id)` `event_bus.gd:289`: yayan `main.gd:5219` · `left_tabs.gd:126`
- `EventBus.quicksave_requested/quickload_requested/save_load_requested/system_menu_requested/settings_requested` `event_bus.gd:296,297,293,291,38`: yayan `main.gd`, `game_shell.gd` · dinleyen `main.gd:4714-4705,89`
- `EventBus.headline_added(source, line)` `event_bus.gd:236`: `time_manager.gd:85` `NewsFeedSystem.on_headline_added`'e bağlar (statik sistem için önyükleme)
- Geri kalan 125 sinyal başka sistemlerin: `grep "^- ad(" docs/kod_haritasi/DIZIN.md`; `KALITE.md` "Yarım sinyaller" bölümü emit/connect'siz olanları listeler

## Durum ve veri
- `GameState` kimlik: `run_id` `:13`, `company_name` `:14`, `origin` `:15`, `subgenre` `:16`, `logo` `:17`, `founder_*` `:18-21`, `difficulty` `:22`, `run_seed` `:24`, `name_lang` `:27`
- `GameState` çekirdek: `cash` `:30`, `mrr` `:31`, `daily_burn` `:32`, `brand` `:33`, `reputation` `:34`, `day` `:35`, `current_hour` `:36`, `phase` `:37`, `flags` `:40`
- `GameState` bitiş: `run_active` `:132`, `ending_id` `:133`, `phase_gate_ready` `:134`, `pending_next_phase` `:135`, `shutter_weeks_left` `:137`, `vc_rejections` `:138`
- `GameState` defterler: `cash_history` `:148` (üst sınır `CASH_HISTORY_CAP` `:147`), `transactions` `:152`, `sales_log` `:159`, `month_ledger` `:164`, `month_history` `:170`, `summary_ledger` `:177`
- `GameState` VC ve seed: `vc_states` `:245`, `active_sheets` `:246`, `pending_meeting` `:247`, `seed_sheet` `:259`, `seed_post_money_m` `:268`, `run_seed_amount` `:263`
- `GameState` diğer: `product` `:302` (yazarı SprintSystem), `office_id` `:305`, `messages` `:318`, `mail_outbox` `:320`, `desk_arrivals` `:322`, `incident` `:329`, `news_feed` `:293`, `hr_search` `:280`
- `GameState.START_DATE` `game_state.gd:8` = 1 Oca 2012; `PHASE_KEYS` `:396` (FIN_PHASE_* anahtarları); `get_runway_months` `:486`, `runway_months_for` `:492`
- `TimeModel` (`scripts/systems/time_model.gd:10-20`): `SECONDS_PER_HOUR` [0, 2.5, 1.25, 0.833], `WEEK_START_HOUR` 8, `WORKDAY_LATEST_END` 24, `WEEK_WORK_HOURS` 40, `DAYS_PER_TICK` 7, `DAYS_PER_MONTH` 30
- `TimeManager` durum: `current_speed` `:40`, `last_running_speed` `:41`, `_in_game_hours` `:47` (kayda girer), `_holds` `:60`, `_freezes` `:64`, `_night_gate` `:68`, `_suspended` `:52`; `HOLD_LABELS` `:32`
- Kayıt dosyası: `user://saves/<slot>.json` (+ `.bak`, `.tmp`) `save_manager.gd:24,510`; yuva kimlikleri `quick_<run>`, `auto_<run>_<1..3>`, `manual_<n>` (`:28-29`)
- Kayıt gövdesi `_payload` `save_manager.gd:231`: `schema_version`, `game_version`, `meta`, `state{game_state, registries, systems{product, rnd, finance, event_engine, hr, time, rng}}`
- Kayıt sürümü: `SCHEMA_VERSION` 19 `save_manager.gd:16`, `MIN_LOADABLE_VERSION` 10 `:23`; autosave `AUTO_SLOTS_PER_RUN` 3 `:28`, `AUTOSAVE_MIN_REAL_SECONDS` 10 `:36`, `AUTOSAVE_FREQUENCIES` `:32`
- Kayıt kayıtları: `SaveCodec._registries()` `save_codec.gd:261` sırası characters, customers, prospects, rivals, promises (sözler son: müşteri düşünce söz de düşer)
- Göç zinciri `_read_file` `save_manager.gd:194-207`: `<11` `_migrate_11` `:630`, `<13` `_migrate_13` `:656`, `<14` `_migrate_14` `:664`, `<15` `_migrate_15` `:825`, `<16` `_migrate_16` `:911`
- Göç zinciri devamı: `<18` `_migrate_18` `:977` (v17 → v18 `market_ref`), `<19` `_migrate_19` `:1010` (v18 → v19 sprint puanı ×5, kartta `need`); yardımcılar `_scale_sprint_card` `:1031`, `_retire_stability` `:1056`;
  ↳ `_migrate_N` N'den önce yazılmış kaydı N'e getirir; emekli bayraklar göçlerden sonra `SaveCodec.RETIRED_FLAGS` ile her yüklemede düşer (`SaveCodec._decode_flags` `save_codec.gd:234`), şema artmaz
- Ayar dosyası: `user://settings.json` `settings.gd:10`, `{schema_version:1, values}`; `DEFAULTS` `:24-53`; `SAVE_DEBOUNCE_SEC` 0,5 `:56`
- Ayar anahtarları dışarıda: `language` (Localization'ın), `runs_finished` (`main.gd:5241`, `scripts/onboarding/first_week_doc.gd:15`); `reset_to_defaults` yalnız `DEFAULTS` anahtarlarını siler
- Ses: `MUSIC_TRACK_PATH` `audio_manager.gd:10` = `res://assets/audio/Döngü Modu.mp3`; bus'lar Master(0), "Music", "SFX" çalışma anında kurulur `:63`
- Dil: `STRINGS_CSV` `localization.gd:12` (`keys,tr,en`), `SUPPORTED` ["tr","en"] `:15`; `BOOT|lang=|source=` satırı `:32`
- JSON veri dosyası (`data/`) bu sistemin değil; çekirdek yalnız `strings.csv` ve `project.godot` okur

## Metin anahtarları
- `CLOCK_HOLD_*`, `CLOCK_HELD`, `GATE_ANSWER_FIRST`: `time_manager.gd:32-38,374` `hold_label()`; okuyan `top_bar.gd:375`, `game_shell.gd:130`, `scripts/tabs/hunt_tab.gd:205`
- `SAVE_ERR_*` (CORRUPT, NEWER, TOO_OLD, MODAL_OPEN, DECISION_WAITING, WRITE, NO_RUN, NO_QUICK): `save_manager.gd`, `main.gd`, `save_load_modal.gd`
- `SAVE_QUICK_SLOT`, `SAVE_AUTO_SLOT`, `SAVE_MANUAL_SLOT`: `save_manager.gd:600` `label_for`; `SAVE_META_*`, `SAVE_GROUP_*`, `SAVE_TOAST_*`, `SAVE_DELETE_*`, `SAVE_OVERWRITE_*`: `save_load_modal.gd`, `main.gd`
- `SET_*` (ayarlar), `LANG_TR_*`, `LANG_EN_*`, `SETTINGS_LANGUAGE_*`: `scripts/modals/settings_modal.gd`; `SET_UI_*`, `SET_WINDOW_*`, `SET_RESOLUTION_*` ayrıca `display_settings.gd`
- `SYS_*` (sistem menüsü): `scripts/modals/system_menu_modal.gd`, `main.gd`
- `FIN_PHASE_*`, `MONTH_HL_*`: `game_state.gd:396,391` faz adı ve ay vurgusu
- `NUM_GROUP_*`, `NUM_DECIMAL_*`, `PCT_PATTERN_*`, `MONTH_1..12`, `DATE_LINE_*`, `FMT_AGO_*`: `scripts/util/fmt.gd` (yerel biçimi CSV'den okur)
- Anahtar ailesi dökümü: `DIZIN.md` "Metin anahtarı aileleri"; CSV'ye elle dokunma kuralı için `strings-csv-surgery` hafıza notu (bayt-aralığı ekleme)

## Testler
- Koşturucu: `bash tools/smoke_run.sh <vaka>` (tüm süit `--all`, yalnız push öncesi); bayrak `--endgame-smoke=<vaka>` `--` ayracından ÖNCE; vaka tablosu `scripts/debug/endgame_smoke.gd:78-590` (`match case_name`)
- Zaman: `speed_preserve` `:94`, `speed_ladder` `:220`, `speed_day_invariant` `:221`, `speed_save_clamps_to_ladder` `:402`, `clock_resumes_only_by_player` `:400`, `milestone_clock_hold` `:397`, `event_gate_holds_clock` `:399`
- Zaman devamı: `incident_night_hold_resumes` `:340`, `smoke_seed_pinned` `:404`, `sales_meeting_time_skip_founder_share` `:158`, `month_history_*` `:376,381`, `run_ledger`, `growth_streak_semantics`
- Kayıt: `save_roundtrip_fingerprint` `:298`, `save_continuity_seeded` `:299`, `save_double_load_no_residue` `:300`, `save_backup_fallback` `:301`, `autosave_writes_off_thread` `:302`, `menu_state_machine`
- Göç: `save_v13_day_stamps_migrate` `:304`, `save_v14_build_becomes_sprint_plan` `:550`, `save_v14_history_becomes_releases` `:551`, `save_v19_cards_scale_and_shape` `:552`, `save_v19_running_sprint_continues` `:553`
- Göç devamı: `save_v15_tickets_become_open_bugs` `:555`, `save_v15_callback_bugs_under` `:556`, `save_v17_market_ref` `:447`, `save_v10_product_state` `:465`, `legacy_v12_save_opens_live_table`, `office_move_gates_and_save` (12 → 13)
- Eski göç yardımcıları yalnız smoke'ta: `save_migration_v3_to_v4` `:416`, `save_migration_v4_to_v5` `:422`, `save_migration_v6_to_v7` `:424`, `save_migration_v6_to_v7_drops` `:425`, `loc_save_sector_migration` `:321`
- Kayıt temizliği: `save_retired_product_flags` `:449`, `save_drops_retired_transaction_label` `:119`, `save_old_calendar_leave_year` `:120`, `seed_sheet_round_trips` `:491`, `month_history_save_typing` `:381`
- Yerelleştirme ve ayar: `loc_csv_integrity` `:316`, `loc_format_locale_flip` `:317`, `loc_pick_fallback` `:319`, `loc_language_switch` `:366`, `locale_switch`, `ui_scale_ladder_fits_settings` `:314`
- Kapı sırası (CLAUDE.md §12): event-lint → `scripts/debug/loc_residue.gd` → `smoke_run.sh loc_csv_integrity` → hedefli vaka; yeni vaka yalnız çekirdek mantık için (§10)
- Ölçüm: `--tempo-probe=<hız>[:shell]` saati gerçek zamanda ölçer; `--tick-probe=<hız>` `auto_*` yuvaları yazar (ayrı `APPDATA` ile koş); `--lang=tr|en` dili zorlar, Settings'e yazmaz
  ↳ `--tempo-probe` her haftayı 08:00'den 08:00'e (gece atlamasının indiği an) ölçer, `TimeModel.seconds_per_tick` hedefinden sapmayı basar ve üçüncü haftada durur; çıplak hâli kabuk kurmaz,
  ↳ `:shell` kabuğu ve ofisi kurar (gece çıkış kapısının maliyeti de ölçülür);
  ↳ `--tick-probe=<hız>[:<pencere>][:accounts=<n>][:team=<n>]` (`scripts/debug/tick_probe.gd`) aynı tempo dünyasını (`main._seed_tempo_state`; `accounts=<n>` ile n B2B hesaplı canlı ERP dünyası `main._seed_accounts_state`:
  ↳ 13 sektör × 3 yıldız, hesap başına tek koltuk, tolerans 0,
  ↳ `TICK WORLD` satırı) başsız kabukla ve isteğe bağlı açık pencereyle beş hafta gerçek saatle koşar; her kareyi iki `process_frame` arası ölçer ve içinde yayılan sinyalle sınıflar; (gece `night_skipped`, saat `hour_changed`,
  ↳ onlardan sonraki kare, koşunun ilk saati), TopBar'ın kare başına yenilemesini (`refresh_count`) ve autosave karesini sayar; `TICK` satırları basar. Karar kapısı bağlı değildir (shot kabuğu): kart saati tutmaz, geldiği kare sayılır;
  ↳ bot kartı sonraki kare ölçülünce `RunProbe._drain_modals` ile cevaplar, sürüm notu tutuşunu oyuncu gibi kaldırır; duruşla biten adım `TICK|stopped` basar; `auto_*` yazar: kayıt taşıyan kullanıcı dizininde çalışmaz;
  ↳ oturtulamayan `team=` `TICK ERROR` basıp 1 ile çıkar
- Üst barın saat hâlleri: `--clock-shot=<running|paused|held|released|gate|incident|focus_out|focus_out_off>` (`main._run_clock_shot`) kabuğu kurar, karar kapısını bağlar,
  ↳ her kare için `CLOCKSHOT` satırı basar (birincil pencere, sprint kipi, tutuşlar, hız). Odak kolları kareden önce `CLOCKSHOT|<kol>|before=|after=` basar (odak kaybından önceki ve sonraki hız); `held`, `released`,
  ↳ `gate` B2C ürünün sürüm notu üstünde koşar; `incident` tema tohumunun şirketini 23:00'ten gece atlamasıyla acil durumun saatine koşturur; (`main._night_emergency`) ve saati hem acil durumun hem kartının tuttuğunu gösterir;
  ↳ dar bar `paused` ve `--shot-scale=1.25` ile çekilir
- Probe kayıt türleri (Çekirdek): `BEGIN`, `STATE`, `WEEK`, `END`, `ERROR`; gerçek saat modları (`--run-log=…:1|2|3`) `TimeManager._drain_boundaries`'ı gerçek saatle süren tek moddur
- Probe kayıt türleri (Kayıt): `VC_REPLAY`, `VC_REPLAY_SUM`: masa tekrarlarının öncesini ve sonrasını `SaveCodec.capture_*` ve `SaveManager._capture_systems` ile yakalar, tekrar iz bırakırsa `ERROR` basar;
  ↳ yalnız `full_run_vc_*` preset'lerinde
- Probe kayıt türleri (Platform): adanmış kayıt yok; `PICK` etiketi seçili dilde basıldığı için probe `--lang=tr` ile koşar
- Görsel (Kayıt): `--modal-shot=save_empty|save|save_overwrite|load_empty|load|load_gate|load_delete` (Kayıt ve Yükle penceresi, üzerine yazma onayı, karar beklerken Yükle); dört kaydı yazar ya da siler, ayrı `APPDATA` ile koşar.
  ↳ Menüdeki Yükle ve Devam için `--menu-shot=load|continue` (09_arayuz_bilesen.md)
- Görsel (Platform): `--modal-shot=settings|settings_end|settings_<mode|res|scale|autosave|summary|lang|graphics|gfx>|settings_reset|system|system_gate` (açık liste maketin üstündeki öğesiyle; `settings_scale` 1280×720 pencerede).
  ↳ Ayrıca `--lang=en`, `--shot-scale=`, `--palette=cb`; metin kapısı `scripts/debug/loc_residue.gd` (10_test_harness.md)
- Ölçüm (Platform): `--display-check` gerçek pencereyi tam ekran, çerçevesiz ve pencereli kiplerden, çözünürlüklerden ve vsync'ten geçirip DisplayServer'ın bildirdiğini basar;
  ↳ kalıcı ayarlayıcıları kullandığı için `settings.json`'a yazar ve sonda eski değerleri geri yükler. Zaman aşımı ya da çökmede ayarlar değişmiş kalır; `--display-check` bilerek harness bayrağı sayılmaz (`SaveManager._is_harness_arg`)
- Harness bayrağı sayılanlar `save_manager.gd:497`: `--` ile başlayıp "smoke", "-shot", "audit", "probe", "run-log", "plausibility" içerenler; autosave kapanır, `DisplaySettings.is_inert` de bunu okur

## Dikkat
- Göç adı ve koşulu aynı N'dir (`_migrate_N` `version < N`, `save_manager.gd:194-207`); yeni göçte `SCHEMA_VERSION`, koşul, adı ve belgeyi birlikte yaz
- `_migrate_sector_ids` `:1095`, `_migrate_character_areas` `:1108`, `_migrate_assignments_to_areas` `:1168`, `_migrate_to_rev11` `:1208` zincirde YOK (`MIN_LOADABLE_VERSION` 10); yalnız `endgame_smoke.gd:11987-12221` çağırır
- Göç her yuva listelemesinde koşar (`list_slots` her dosyayı `_read_file`dan geçirir): saf, ucuz, canlı durumdan bağımsız olmalı; `_migrate_18` bu yüzden kaydın kendi ürün alt türünü okur
- `_migrate_15` kartı v18 biçiminde yazar (`_V14_EFFORT`, `_V14_SHARES` `save_manager.gd:821-822`); ×5 ve `need` dönüşümünü yalnız `_migrate_19` yapar. `list_slots` ve `read_slot` her yuvada tam zinciri tekrar koşar
- `SaveCodec.game_state_fields()` `save_codec.gd:192` `GameState`in HER script `var`ını kaydeder; kaydedilmemesi gereken geçici alan eklenemez. Yeni alan makul varsayılan taşımalı (varsayılan = göç)
- JSON her sayıyı float yapar: yeni `GameState.flags` anahtarı `FLAG_TYPES` ya da `FLAG_TYPE_PREFIXES` ister, yoksa tipi geri gelmez; debug yapıda `set_flag` sapmayı uyarır (`game_state.gd:441-467`)
- Yükleme bir OS yeniden başlatması gibi davranmalı: statik/kayıtlı koşu durumu ekleyen sahip `reset_all_owners` `save_manager.gd:326`e girmeli, yoksa eski koşu sızar. Sıra bağımlıdır (saat önce, RNG son)
- Yükleme sırası: `TimeManager.set_suspended(true)` → `reset_all_owners` → `initialize_run(restore)` → registries → `_restore_systems` → sabitleme; saat bloğu `from_dict` her zaman duraklı döndürür (`time_manager.gd:304`)
- `can_save()` karar bekleyen kart (`EventGate.active_id`) ya da dört oturum sistemi (`VCPitchSystem`, `TermSheetTableSystem`, `SalesMeetingSystem`, `NegotiationSystem`) açıkken reddeder; oturum durumu kaydedilmez
- Saat iki bağımsız sayaçtır: `_in_game_hours` ve `GameState.current_hour`. `current_hour`ı başka yoldan yazan `sync_to_current_hour()` çağırmalı, yoksa saatlik tik atlanır (`time_manager.gd:20-24,236`)
- Gece her karede türetilir, mandalsız (`is_night` `time_manager.gd:217`); `skip_night` günlük tikin autosave'ini içerde koşar. Toplantı atlaması gece yarısını geçmez (`advance_hours`, `:173`)
- `hold_clock` hızı 0'a çeker ve oyuncu başlatana kadar tutar; aynı neden ikinci kez sessizdir. Yeni neden `HOLD_LABELS` `time_manager.gd:32`e girmezse adı `CLOCK_HELD` olur
- Yükleme sonrası hız 0'dır; `speed_change_requested(>0)` koşu bitmişse ya da tutuş varsa yutulur (`time_manager.gd:326-340`); `EventBus.speed_change_requested` yorumundaki "4=4x" bayat, merdiven 3 basamak
- Günlük tik sırası bağımlıdır (her yuva öncekinin yerleştirdiğini okur): `SummarySystem.begin_day` önce, `FinanceSystem` faz kapısından ve olaylardan önce, `EndingsSystem` VC'den sonra (`time_manager.gd:383-435`)
- `Settings` `SaveManager`dan SONRA yüklenir: SaveManager ayarı kullanım anında okur (`save_manager.gd:430`), `_ready`de okumaz. Autoload sırasını değiştirmek bu bağlılıkları kırar
- `Settings` DisplaySettings/GraphicsSettings'e `preload` ile bağlıdır, sınıf adıyla değil: sınıf önbelleği bayatken autoload çözülemezse tüm oyun düşer (`settings.gd:13-17`); `class_name` değişince `--headless --import` şart
- `AudioManager` `Settings`ten sonra yüklenir; `Settings.apply_all` onu `is_node_ready` ile korur (`settings.gd:124-125`). SFX bus'ında oynatıcı yok; kaydırıcı boş bus'ı oynatır
- `Localization.pick(tr, en)` çizimde çözer; olay önbelleği açılışta bir kez kurulduğu için yükleme anında dil dondurmak yanlıştır. Boş `en` "metin zaten yerelleşmiş" sözleşmesidir (`localization.gd:73-80`)
- `Character`/`Customer`/`Prospect` `name` alanı taşımaz (Node/Object ayrılmış): `character_name`, `company_name`; kayıt defterlerinde `get_character` gibi adlar `Object.get`i gölgelememek içindir
- Ölü aday (KALITE.md): EventBus'ta `employee_eligible_for_promotion` ve `raise_requested` yayansız
- CLAUDE.md §9: yerini alan kod eskisini aynı commit'te siler; ölü göç yardımcıları, ölü sinyaller ve tarihçe yorumları bu kuralın dışında kalmış (özellikle `save_manager.gd` göç yorumları)

## Bir değişiklik yaparken
- `GameState`e alan eklersen: varsayılanı makul seç (göç yerine geçer), `initialize_run` `:769` içinde sıfırla (container ise `clear()` ile yerinde), bayraksa `FLAG_TYPES`e yaz; alan şemayı değiştiriyorsa `SCHEMA_VERSION` ve göç düşün
- Kayıt şemasını bozan değişiklik (anahtar adı, birim) için: `SCHEMA_VERSION` artır `save_manager.gd:16`, `_read_file` zincirine koşul ve `_migrate_*` ekle `:194-207`, `CLAUDE.md` Kayıt maddesi, Durum ve veri bölümü, bir `save_v*` vaka
- Yeni `Resource` modelini kayda sokarsan: `SaveCodec.script_for_class` `save_codec.gd:38` ve `_registries()` `:261` listesine, `SaveManager.reset_all_owners`a sıfırlayıcıyı, `insert_raw`/`reset` çiftini kayıt defterine ekle
- Saatlik/günlük tike sistem eklersen: `TimeManager._dispatch_daily_tick` `:385` veya `_dispatch_hourly_tick` `:439` doğru yuvaya; bu sayfanın dağıtım sırası maddesini ve `CLAUDE.md` Zaman maddesini güncelle
- Saati durduran yeni yüzey: `hold_clock(neden)`, `HOLD_LABELS`e anahtar + `CLOCK_HOLD_*` CSV satırı; kapanışta `release_clock`; hız merdiveni: `TimeModel.SECONDS_PER_HOUR`, `top_bar.gd`, `speed_*` vakaları, CLAUDE.md
- Yeni ayar: `Settings.DEFAULTS` `:24`e anahtar (şemanın tamamı budur), `settings_modal.gd` satırı + `SET_*` CSV anahtarları, sahibine uygulama `apply_all` `settings.gd:113`; `reset_to_defaults` onu otomatik temizler
- Yeni sinyal: `event_bus.gd`de ilgili `# --- X ---` bölümüne ekle ve `python tools/gen_signal_manifest.py` çalıştır; bağlanan dosyalar `_exit_tree`de ayırmalı; kayıt yükü taşıyan sinyali `game_loaded` sonrası boyamayla karıştırma
- Yeni dil ya da biçim: `Fmt` kodu değil `strings.csv` sütunu/anahtarı (`NUM_*`, `PCT_PATTERN_*`, `MONTH_*`); `Localization.SUPPORTED` `:15` ve `loc_*` vakaları, `docs/design/localization_glossary.md`
- Autoload ekler ya da sıralarsan: `project.godot:24-39`, CLAUDE.md autoload listesi, `DIZIN.md`yi yeniden üret (`python -I tools/kod_haritasi/uret.py`); `_ready`de sonraki autoload'a bağlanma
