# HARİTA — kod haritası

Her sistem için kodun yeri, sahibi, dışarıdan çağrılan giriş noktaları, onu gözleyen smoke vakaları ve probe kayıtları, varsa görsel kontrol ve ölçüm bayrakları. Yollar `project-unicorn/` köküne görelidir, `(git kökü)` bir üst dizindir.
Smoke önekleri kaba eşleşmedir: bir vaka iki sistemi birden sınayabilir, liste başlangıç noktasıdır, tam seçim değildir.
Açık işler ve sahip kararı bekleyen maddeler: `docs/ACIK_ISLER/`.

## Çekirdek · GDD ch01, Zaman Modeli

- **Yer:** `scripts/autoload/{game_state,time_manager,event_bus}.gd`, `scripts/systems/{time_model,rng_streams,skill_check}.gd`, `scripts/util/fmt.gd`
- **Sahip:** autoload `GameState`, `TimeManager`, `EventBus`; sınıf `TimeModel`, `RngStreams`, `SkillCheck`, `Fmt`
- **Giriş:**
  - `GameState.initialize_run(payload)` yeni koşuyu kurar; onboarding, smoke ve probe buradan geçer.
  - Yazma yüzeyi: `GameState.set_cash`, `set_mrr`, `set_brand`, `advance_phase`, `advance_day`, `set_current_hour`; tipli bayrak tablosu `set_flag` / `get_flag` (`FLAG_TYPES`). `set_phase` yalnız debug yollarında (shot koşucuları, debug tuşları, smoke) kullanılır.
  - Ay defteri: `accrue_month_flow`, `push_month_close`, `get_runway_months`, `get_run_ledger`.
  - Zaman: bir tik (oyun günü, `GameState.day`) bir haftadır. `TimeModel` ayar bloğu ve birim dönüştürücüleridir: `SECONDS_PER_HOUR`, `WEEK_START_HOUR` (8), `WORKDAY_LATEST_END` (24), `OVERTIME_HOUR_YIELD`, `WEEK_WORK_HOURS`; birimler `DAYS_PER_TICK` (7), `DAYS_PER_MONTH` (30), `HOURS_PER_DAY` (24), `WEEKS_PER_YEAR` (52); `ticks(weeks)` (süre okuması), `per_tick(rate_per_day)` (×7), `days`, `months`, `seconds_per_tick(speed)`. Takvim `GameState.get_date_dict(tick)`: her tik bir Perşembe'dir, `week` o günün yıl içindeki haftasıdır. Tarih satırı `Fmt.date_line`.
  - `TimeManager` günlük dağıtım sırası: dönem özeti ve ay kapanışı (yuva 0, `SummarySystem.begin_day`) → ürün → Ar-Ge → ekip → satış → rakipler → finans → ofis → faz kapısı ve seed → olaylar → haber → VC → sonlar → özet ve şerit satırları (yuva 10, `SummarySystem.daily_tick`). Gün `EventBus.day_tick_completed` ile kapanır (autosave sınırı). Saatlik dağıtım: ürün ve destek, satış, olaylar.
  - Haftanın akışı: hafta 08:00'de başlar (`GameState.start_work_week` kurucunun haftalık toplantı payını sıfırlar). Mesai bitince (`WorkHoursSystem.workday_end()`) gece başlar; `TimeManager.is_night()` her karede durumdan türetilir. Ofis boşalınca `skip_night()` gecenin saatlerini tek toplu adımda koşar: 00:00 devri, günlük tik ve autosave içindedir, 08:00'e varınca `EventBus.night_skipped` yayılır. "Ofis boş" yüklemi `register_night_gate(callable, max_wait_s)` / `unregister_night_gate()` ile kaydolur; kapı yoksa (headless, smoke, probe) gece hemen atlanır.
  - Saati dışarıdan ileri taşıyan öbür kapı `TimeManager.advance_hours(n, meeting)`'dir (toplantı kapanışı, smoke, probe). Saatin kesrini korur; toplantı atlaması gece yarısını geçmez ve kurucunun haftalık çıktısından saat / `WEEK_WORK_HOURS` payı düşer (`founder_output_factor()`, `GameState.founder_meeting_share()`). Toplu adım sürerken olay gösterimi ertelenir (`is_batching()`); adım bitince `EventBus.clock_batch_ended` motoru pompalar.
  - Hız: istek `EventBus.speed_change_requested`, sonuç `TimeManager.speed_changed`; merdiven `TimeModel.SECONDS_PER_HOUR` (duraklat, 1×, 2×, 3×, 4×). `hold_clock` / `release_clock` ağacı da duraklatır; `freeze_clock` / `thaw_clock` yalnız birikimi durdurur (gece çıkışı, kurucunun yolculuğu), ofis yürümeye devam eder.
  - `EventBus` sistemler arası sinyalleri taşır. İstisna: `TimeManager.speed_changed` (TopBar hız düğmelerini buradan boyar). `# --- X ---` bölüm başlıklarını `tools/gen_signal_manifest.py` okur.
  - `RngStreams.get_stream(id)`, `reseed(run_seed)`; `SkillCheck.resolve`, `chance_for`; `Fmt.money`, `percent`, `number`, `month_name`, `month_abbr`, `upper`, `date_line`, `count_key` (EN tekil ikiz seçici).
  - Olay seam'leri `time.*` (`seams_world.gd`: `time.week`, `time.hour`, `time.speed`).
- **Smoke:** her vaka `GameState.initialize_run`'dan geçer. Adanmış: `speed_*` (`speed_tracks_team_change` hariç), `smoke_seed_pinned`, `run_ledger`, `growth_streak_semantics`, `month_history_*`.
- **Probe:** `BEGIN`, `STATE`, `WEEK`, `END`, `ERROR`. Gerçek saat modları (`:1|2|3|4`) probe'da `TimeManager._drain_boundaries`'ı gerçek saatle süren tek moddur.
- **Ölçüm:** `--tempo-probe=<hız>[:shell]` gerçek saatle koşar; her haftayı 08:00'den 08:00'e (gece atlamasının indiği an) ölçer, `TimeModel.seconds_per_tick` hedefinden sapmayı basar ve üçüncü haftada durur. Çıplak hâli kabuk kurmaz; `:shell` kabuğu ve ofisi kurar, gece çıkış kapısının maliyeti de ölçülür.

## Kayıt

- **Yer:** `scripts/autoload/save_manager.gd`, `scripts/systems/save_codec.gd`, `scripts/modals/save_load_modal.gd`, `scenes/modals/SaveLoadModal.tscn`
- **Sahip:** autoload `SaveManager`; sınıf `SaveCodec`
- **Giriş:**
  - `SaveManager.save_to_slot`, `quicksave`, `read_slot`, `apply_loaded_state`, `list_slots`, `delete_slot`, `can_save`, `cannot_save_reason_key`, `has_unsaved_progress`.
  - Autosave sıklığı `autosave_frequency` ayarıdır (`AUTOSAVE_FREQUENCIES`: kapalı, haftalık, aylık). Haftalık kip her `EventBus.day_tick_completed`'e, aylık kip `EventBus.month_ended`'e bağlıdır; iki autosave arasında en az `AUTOSAVE_MIN_REAL_SECONDS` gerçek saniye geçer. Bir kartın engellediği autosave kuyruk boşalınca (`event_resolved`) yeniden dener. `auto_*` yuvaları arasında döner; yuvalar `user://saves/` altındadır.
  - `SaveManager.reset_all_owners` koşu durumunu statik tutan sahipleri sıfırlar; `InfraSystem`'in bağlı olmayan uyarı kartı mandalı bu listede yoktur. Statik koşu durumu ekleyen sistem buraya yazılır.
  - Durum tutan sistemler `to_dict` / `from_dict` verir; olay motoru `EvSave` üzerinden girer.
  - `SaveCodec.capture_game_state`, `apply_game_state`, `capture_registries`, `restore_registries`. GameState değişkenlerini ve kayıtlı modellerin `@export` alanlarını kendisi bulur; yeni alan varsayılan değer ister.
  - Sürüm sabitleri `SCHEMA_VERSION` (14) ve `MIN_LOADABLE_VERSION` (10); göçler `save_manager.gd` içinde `_migrate_*`, `read_slot` sırayla uygular. `_migrate_14` v13 → v14 göçüdür: gün damgalarını ve gün sayaçlarını haftaya çevirir, adı değişen alanı yeni adla yazar, dönem defterini ve runway eşiğini türetir (kurallar ve alan listesi GDD Zaman Modeli §10).
  - UI yolu: `EventBus.save_load_requested`, `quicksave_requested`, `quickload_requested` → `main.gd`.
- **Smoke:** `save_*`, `legacy_v12_save_opens_live_table`, `sales_save_roundtrip_rev6`, `sales_check_replays_after_load`, `account_ownership_round_trip`, `month_history_save_typing`, `seed_sheet_round_trips`, `loc_save_sector_migration`, `office_move_gates_and_save` (12→13 göçü), `save_v13_day_stamps_migrate` (13→14 göçü).
- **Probe:** `VC_REPLAY`, `VC_REPLAY_SUM`. Masa tekrarlarının öncesini ve sonrasını `SaveCodec.capture_*` ve `SaveManager._capture_systems` ile yakalar; tekrar iz bırakırsa `ERROR` basar. Yalnız `full_run_vc_*` preset'lerinde.
- **Görsel:** `--modal-shot=saveload`. Gerçek bir quicksave yazar.

## Platform (Settings, Localization, Audio, Display)

- **Yer:** `scripts/autoload/{settings,localization,audio_manager}.gd`, `scripts/systems/display_settings.gd`, `scripts/modals/{settings_modal,system_menu_modal}.gd`, `scenes/modals/{SettingsModal,SystemMenuModal}.tscn`, `localization/strings.csv`, `assets/audio/`
- **Sahip:** autoload `Settings`, `Localization`, `AudioManager`; sınıf `DisplaySettings`
- **Giriş:**
  - `Settings.get_value`, `set_value`, `has_stored`, `reset_to_defaults`, `flush`. Dosya `user://settings.json`, kayıtlardan bağımsızdır.
  - `Localization` `strings.csv`'yi (`keys,tr,en`) kendisi ayrıştırıp TranslationServer'a yükler. `set_language`, `get_language`, `pick`. `--lang=` bayrağını okur.
  - `AudioManager` ses düzeylerini tutar; yalnız ayarlar modalı kullanır.
  - `DisplaySettings` çözünürlük, pencere kipi ve vsync'i yönetir. `BASE_VIEWPORT` `project.godot`'taki viewport'u elle yansıtır. Debug bayrakları (`SaveManager._is_harness_arg`, autosave'i kapatan listeyle aynı tek liste) onu etkisiz kılar; `--display-check` bilerek bu listenin dışındadır.
  - UI yolu: `EventBus.settings_requested`, `system_menu_requested` → `main.gd`.
- **Smoke:** `loc_*`, `locale_switch`, `settings_language_toggle`, `ui_scale_ladder_fits_settings`, `borderless_note_key_exists`.
- **Probe:** adanmış kayıt yok. `PICK` etiketi seçili dilde basıldığı için probe `--lang=tr` ile koşturulur.
- **Görsel:** `--modal-shot=settings|system`, `--lang=en`, `--shot-scale=`. Metin kapısı `scripts/debug/loc_residue.gd` (Araçlar).
- **Ölçüm:** `--display-check` gerçek pencereyi tam ekran, çerçevesiz ve pencereli kiplerden, çözünürlüklerden ve vsync'ten geçirip DisplayServer'ın bildirdiğini basar. Kalıcı ayarlayıcıları kullandığı için `settings.json`'a yazar ve sonda eski değerleri geri yükler; zaman aşımı ya da çökmede ayarlar değişmiş kalır.

## Tema ve UI kiti · GDD ch12

- **Yer:** `scripts/theme/{ui_tokens,ui_factory,build_theme}.gd`, `themes/master_theme.tres` (üretilmiş), `scripts/ui/components/{bar_kit,star_rating,value_slider,dialogue_portrait_card}.gd`, `scenes/ui/components/DialoguePortraitCard.tscn`, `scenes/debug/ThemeProbe.tscn`, `assets/fonts/`, `assets/icons/` kökündeki genel ikonlar
- **Sahip:** sınıf `UiTokens`, `UiFactory`, `StarRating`, `ValueSlider`, `DialoguePortraitCard`
- **Giriş:**
  - `UiTokens`: palet, yazı merdiveni, `THEME_STAMP`; yardımcılar `format_money`, `positive`, `negative`, `badge_palette`, `build_percent`.
  - `UiFactory.make_label`, `make_badge`, `make_card`, `make_pill`, `make_state_chip`, `make_section_header`, `make_centered_column`, `make_placeholder_column`, `initials_of`, `clear`, `is_left_click`.
  - `build_theme.gd` token → tema dönüştürücüsüdür: `godot --headless --path . -s res://scripts/theme/build_theme.gd`. `main.gd` açılışta `master_theme.tres` damgasını `THEME_STAMP` ile karşılaştırır.
  - Kabuk varyasyonları: pencere `WindowPanel` (krem kart, `RADIUS_WINDOW`, gölge) ve köşesindeki × `WindowClose`; sol ray `SideRailPanel`, `TabButton` / `TabButtonActive`. Koyu sahnelerin butonları `DialogueChoiceButton` ve `ChromeAlertButton`. Koyu çerçeve gövdeyle değişen her rengi `*_CHROME` ikizinden okur (`ACCENT_CHROME`, `INK_*_CHROME`, `VEIL_*_CHROME`); `Chrome*` ailesinin yasal yüzeyleri CLAUDE.md §7'de.
  - `bar_kit.gd` Build Bar ile Research Bar'ın ortak çizimidir. `DialoguePortraitCard` fonlama, satış ve onboarding tarafından paylaşılır.
- **Smoke:** `build_percent_single_source`, `star_ruler_contract`, `rail_tabs_match_scene_order`.
- **Probe:** yok.
- **Görsel:** `--theme-audit=<sekme id>`, `--probe-shot` (ThemeProbe), `--tab-shot=`, `--shot-size=`.

## Kabuk (main.gd, GameShell, TopBar, LeftTabs, WindowLayer) · GDD ch12

- **Yer:** `scripts/main/{main,game_shell}.gd`, `scenes/main/{Main,GameShell}.tscn`, `scripts/ui/components/{top_bar,left_tabs,window_layer,window_frame,desk_papers}.gd`, `scenes/ui/components/{TopBar,LeftTabs}.tscn`, `scripts/tabs/events_tab.gd`, `scenes/tabs/EventsTab.tscn`, `scripts/modals/confirm_modal.gd`, `scenes/modals/ConfirmModal.tscn`, `assets/icons/tabs/`
- **Sahip:** `main.gd` (ana sahne kökü), `game_shell.gd` (`GameShell.tscn`), `window_layer.gd` (`MidRow/CenterViewport`, grup `window_layer`); `window_frame.gd` ve `desk_papers.gd` (yolla preload edilir, sınıf adı yok)
- **Giriş:**
  - `main.gd` açılışta debug bayraklarını yönlendirir, sonra onboarding'i ya da kabuğu kurar. Oyunda modal ve sahneleri EventBus sinyalleriyle açar: `modal_requested`, `pitch_requested`, `meeting_scene_requested`, `term_table_requested`, `rnd_card_requested`, `confirm_requested` (`hr_action` dahil), `settings_requested`, `system_menu_requested`, `save_load_requested`, `summary_ready` (dönem özeti modalı), `run_ended`, `milestone_reached`, `product_note_issued` (ilk Ar-Ge notu). Ayrıca `quicksave_requested` / `quickload_requested`'i ve olay modalını kapatan `event_resolved`'u dinler.
  - `WindowLayer` (`CenterViewport`'un script'i) `EventBus.tab_changed`'i dinler ve sekmeyi ofisin üstünde sabit yuvalı bir pencerede açar: `TAB_SCENES` sekme sahneleri, `SPECS` 1920×1080 tabanında pencere boyları, `WindowFrame` kabuk (sağ üstte ×). Aynı anda en çok bir birincil ve ona bağlı bir ayrıntı penceresi (`DETAILS`: `hr_dossier`); sürükleme yok. `open_primary(id)`, `open_detail(kind, payload)`, `close_top()` (Esc: önce ayrıntı, sonra birincil; hiçbir pencere yoksa false döner ve `game_shell` sistem menüsünü açar), `get_current_page_body()` (harness). `hr_dossier` açılınca ofiste kişinin halkası yanar (`office_view.select_person`), ayrıntı kapanınca söner (`clear_selection`). `tab_changed("")` pencere yok demektir; ×, Esc ve aktif sekmeye tekrar tık bu sinyale çıkar. Dil ya da palet değişince açık pencereler yeniden kurulur. Çocuk sırası: `OfficeView` ilk, pencereler, `BuildHUD` son (bir çubuğu doluyken ofiste de pencere üstünde de görünür).
  - `DeskPapers` masadaki kâğıtların tek türetme ve çizim evidir: `gather()` motor kâğıtlarını (`EventGate.desk_papers`) ve durumdan türeyen hatırlatıcıları (faz kapısı, term sheet, Atlas dosyaları, B2B genişlemesi) verir, `make_row()` satırı çizer, `open()` motor kâğıdını `EventGate.open_paper` ile açar, hatırlatıcıyı sekmesine götürür. Kâğıdı değiştiren sinyallere `connect_changes(c)` ile abone olunur. Okuyanlar: Olaylar sayfası (`events_tab.gd`: Frank'in son satırı `GameState.mentor_line_key` + `mentor_line_args`, çizimde `tr(key).format(args)`, ve bütün kâğıtlar) ve ofisin not yığını.
  - `LeftTabs` ray, kilit ve rozetleri; `TopBar` kasa, MRR, runway, tarih ve hız düğmelerini taşır; burn ve net canlı aylık hızdır (`FinanceSystem.get_monthly_flow`, `/ay`). Hız isteğini `EventBus.speed_change_requested` ile gönderir, düğmeleri `TimeManager.speed_changed` ile boyar.
  - Kurucunun dış toplantıya yolculuğu `main.gd`'dedir (`_leave_office`, `_return_to_office`): oturum açılınca saat `TimeManager.freeze_clock("travel")` ile donar, ağaç koşar, `WindowLayer.set_veiled` pencereleri ve ofis üstü denetimleri gizler, `OfficeView.travel` yolculuğu oynar (Ofis bölümü). Yolculukta gelen kart toplantıdan sonra gösterilir.
  - Metni smoke'a sabit yerler (başlıcaları; bkz. Araçlar > Smoke): `window_layer.gd` içindeki `propagate_call("on_page_closing")`; `TopBar.tscn` ve `top_bar.gd`'deki hız düğmeleri (sahnedeki `PauseBtn` ve `Speed1Btn` ile `Speed4Btn` arası adlar sabit); `main.gd` özel adları `_on_milestone_reached`, `_on_milestone_continue`, `_keep_run_for_main_menu`, `_shell`, `_event_modal`, `_milestone_modal`; `left_tabs._refresh_rnd_badge`; `product_tab.gd` `_view_node`, `_view_id`, `_navigate`.
- **Smoke:** `rail_tabs_match_scene_order`, `topbar_speed_cluster_four_rungs`, `creation_draft_survives_navigation`, `milestone_paper_under_card`, `build_bar_hosts_agree`, `rnd_rail_open_with_waiting_page`, `all_scripts_load`.
- **Probe:** yok (probe kabuk kurmaz).
- **Görsel:** `--tab-shot=<product|sales|hr|finance|personal|rnd|marketing|events>` (pencere ofisin önünde), `--modal-shot=confirm|confirm3`, `--shot-size=`, `--skip-onboarding`.
- **Ölçüm:** `--render-probe[=<sekme>]` (`--shot-size=` ile) kabuğu tek pencere boyutunda kurar, kare maliyetini ve doku ve video belleğini basar.

## Ofis (3B) · GDD ch12

- **Yer:** `scenes/office/OfficeView.tscn`, `scenes/office/shaders/{office_toon,office_ink,office_sky}.gdshader`, `scripts/ui/office/*.gd`, `scripts/systems/{office_system,office_constants}.gd`, `art/office3d/` (ofis başına GLB, yan JSON ve içe aktarıcının çıkardığı dokular), `assets/art/office/` (Xbot rigi, harita kartı küçük resimleri, kafa üstü ikonları)
- **Sahip:** sınıf `OfficeSystem` (durumun tek yazarı), `OfficeConstants` (katalog, hepsi [WORKING]), `OfficeLayout`, `OfficeMaterials`, `OfficeLighting`, `OfficeCamera`, `OfficePeople`, `OfficeActor`, `OfficeLook`, `OfficeCity`; `OfficeView` `GameShell.tscn` içinde kalıcı çocuktur (`MidRow/CenterViewport/OfficeView`, grup `office_view`)
- **Giriş:**
  - Durum `GameState.office_id`, `office_move_to`, `office_move_day`. `OfficeSystem.current`, `is_moving`, `arrival_day`, `requirement_state`, `can_move_to`, `move_to` (kasa hareketi yok, `FinanceSystem`'in "office" kalemi 0; taşınma `OfficeConstants.MOVE_WEEKS` sürer), `daily_tick` (taşınmayı varış tikinde indirir). Sinyaller `EventBus.office_move_started`, `office_changed`. Olay seam'i `office.current` (`seams_world.gd`); kart `funding.frank_office_move`.
  - `OfficeView.load_layout(id)` GLB'yi ve yan JSON'u (`OfficeLayout.load`) yükler, `office_changed`'de ofisi değiştirir; `current_layout`, `camera`, `lighting`, `show_tooltip` / `hide_tooltip`. Kişiye tık `window_layer` grubunda `open_detail("hr_dossier", {character_id})` çağırır.
  - Işık `TimeManager.day_minute()`'ı okur (`OfficeLighting.apply`, tasarımın gün boyu renk senaryosu). Kişiler `CharacterRegistry` ve `WorkHoursSystem`'i okur (`in_office`, `start_hour`, `hours_for`): herkes kendi mesaisinde masadadır; kurucu şirket penceresini izler, pencere dışında evde yatağındadır, öbür ofislerde çıkar. Mesai bitiminden `ARRIVE_MAX_S` gerçek saniye önce çıkışa yürünür; yürüyüş ve molalar gerçek saniyeyle akar.
  - Gece kapısı: `OfficePeople` `TimeManager.register_night_gate(office_empty, NIGHT_WALKOUT_MAX_S)` ile kaydolur. Gece ofisin boşalmasını en çok `NIGHT_WALKOUT_MAX_S` bekler; gece başlarken hâlâ ayakta olan herkes çıkışa (evde kurucu yatağa) gönderilir. `OfficeView` `EventBus.night_skipped`'te kısa bir kararma oynar (`NIGHT_FADE_S`).
  - Kurucunun toplantı yolculuğu `OfficeView.travel`'dir (`office_travel.gd`, sınıf adı yok; `main.gd` sürer, Kabuk bölümü). `travel_out()` kurucuyu çıkışa yürütür (`OfficePeople.send_founder_out`, `founder_arrived`, en çok `EXIT_S`), haritaya kararır, şehri yol kipinde yükler (`load_layout("city", true)`) ve kamerayla iğneyi hedef binaya kaydırır (`OfficeCity.drive`, `OfficeConstants.MEETING_TARGET`, `OfficeCamera.focus_done`). `travel_back()` ofisi toplantı sahnesinin altına geri yükler, `arrive()` kurucuyu içeri alır (`founder_back`). Tık ya da Esc yolculuğu atlar; shot'larda yolculuk yoktur (`--travel-shot` hariç).
  - Şehir haritası `city` yerleşimidir (`OfficeCity`): ofis kartı `office_map_card.gd`, "Ofisi taşı" düğmesi ve taşınma sayacı `office_hud.gd` (sol alt).
  - Not yığını `Overlay/NoticeStack` (`office_notice_stack.gd`, sağ alt): Frank'in son satırı (`GameState.mentor_line_key` + args) ve `DeskPapers` kâğıtları; açık pencere yığını örter.
- **Smoke:** `office_move_gates_and_save`; `build_bar_hosts_agree` (iki ev sahibi: BuildHUD ve ürün izleyicisi).
- **Probe:** yok.
- **Görsel:** `--office-shot=<home|ishani|plaza|loft|city>:<saat>[:full|card|<sekme>|hr_dossier]` (ofis her zaman kabuğun içinde; `full` bütün masalar dolu, `card` yalnız `city`'de Plaza'nın kartı açık, `<sekme>` o sekmenin penceresi açık, `hr_dossier` Ekip penceresi ve ilk çalışanın dosyası); kare süresini ve çizim sayılarını da basar. `--travel-shot=<home|ishani|plaza|loft>` 10:00'da satış toplantısına yolculuğu kare dizisi olarak çeker (`travel_shot_<ofis>_NN.png`). `--day-shot=<ofis>:<hız>` bir haftayı gerçek saatle 08:00'den gece atlamasıyla ertesi 08:00'e çeker; hafta Ocak'ın sonudur, sessiz ay kapanışının şerit satırı karelerde görünür (`day_shot_<ofis>_<hız>_NN.png`, kare başına `DAYSHOT` satırı). `--tab-shot=` pencereyi ofisin önünde çeker. Dışa aktarım hattı Üçüncü taraf ve altyapı altında.

## Ürün · GDD ch03, ch06

- **Yer:** `scripts/systems/{product_system,product_state,product_read,product_lines,product_catalog,line_gates,quality_model,infra_system,support_system}.gd`, `scripts/data_models/feature_build.gd`, `scripts/tabs/product_tab.gd`, `scripts/tabs/product/`, `scripts/ui/components/{build_bar,build_bar_model,build_hud_panel,triangle_radar}.gd`, `scenes/tabs/ProductTab.tscn`, `scenes/ui/components/{BuildBar,BuildHUDPanel}.tscn`, `data/product/lines/`, `assets/icons/build/`
- **Sahip:** sınıf `ProductSystem`, `ProductState`, `ProductRead`, `ProductLines`, `ProductCatalog`, `LineGates`, `QualityModel`, `InfraSystem`, `SupportSystem`, `FeatureBuild`; UI `ProductUiShared`, `PublishFlow`, `FeatureLinesView`, `CapacityBlock`, `ProductTeamPanel`, `TriangleRadar`
- **Giriş:**
  - `ProductSystem.daily_tick` / `hourly_tick`, `start_line_build`, `get_active_build`, `enter_development`, `enter_beta`, `launch`, `cancel_build`, `live_bug_count`.
  - `ProductState` canlı ürün okumalarının evidir (`is_live`, `market_type`, `subtype`, `bugs_confirmed`, `line_tier`) ve kendi tanımladığı `mvp_*` adlarının tek evidir. Eski `mvp_*` bayrakları (`mvp_shipped`, `mvp_live_bug_count`, `mvp_components`, `mvp_market_type`…) birçok sistemde hâlâ doğrudan okunur.
  - `ProductRead` olay motoruna açılan `urun.*` okuma yüzeyidir.
  - `ProductLines` (`data/product/lines/*.json`), `LineGates.is_unlocked`, `ProductCatalog.get_quality_axes` / `axis_label`, `QualityModel.composite_quality` / `axis_score`.
  - `InfraSystem.daily_tick`, `provider`, `capacity_state`, `monthly_bill`; `SupportSystem.daily_tick` / `hourly_tick`, `start_fix_run`, `end_fix_run`, `desk_staffed`.
  - Olay seam'leri `urun.*` (`seams_product.gd`, `seams_ported.gd`).
- **Smoke:** `iter_*`, `beta_*`, `build_*`, `line_*`, `infra_*`, `destek_*`, `product_*`, `coupling_*` (Ekip ile ortak), `live_during_vbuild`, `sprint_no_freeze`, `capacity_split`, `speed_tracks_team_change`, `feature_bug_seed_by_complexity`, `hardening_seeds_no_bugs`, `single_feature_build_legal`, `commit_cost_charged_once`, `phase_bands_20_60_20`, `deterministic_axes_at_ship`, `fix_run_ships_subset`, `support_desk_rates_stack`, `cancel_reverts_planned_steps`, `pause_kinds_and_lead_note`, `run_profile_never_exhausts`, `quality_half_sat_25`, `b2b_v1_lands_mid_band`, `field_unlocked_for_saas_ops`, `b2c_satisfaction_gate_experience`, `ship_tooltip_counts_critical_penalty`, `axis_reading_replaces_not_adds`, `gate_scope_and_halves`, `above_gate_bonus_ladder`, `design_turn_ladder`, `type_screen_matches_line_content`.
- **Probe:** `SHIP`, `FIXTURE`, `STATE` içinde `bugs=` ve `q=`, `PLAY` (`_open_the_company`, `_keep_the_word`, `_run_the_company` altyapı ve fix run adımları).
- **Görsel:** `--product-shot=<tür>` (ör. `portfoy`, `ozellikler`, `tracker`, `beta`, `detail_b2b`, `publish`), `--build-state=<durum>`, `--tab-shot=product`.

## Ar-Ge · GDD Ar-Ge modülü

- **Yer:** `scripts/systems/{rnd_system,research_tree,research_seam}.gd`, `scripts/tabs/rnd_tab.gd`, `scripts/tabs/rnd/`, `scripts/modals/rnd_card_modal.gd`, `scripts/ui/components/{research_bar,research_bar_model}.gd`, `scenes/tabs/RnDTab.tscn`, `scenes/modals/RnDCardModal.tscn`, `scenes/ui/components/ResearchBar.tscn`, `data/techtree/rnd_tree.json`
- **Sahip:** sınıf `RnDSystem`, `ResearchTree`, `ResearchSeam`; UI `RnDUiShared`, `RnDTreeView`, `RnDDetailPanel`, `RnDAssignPanel`
- **Giriş:**
  - `RnDSystem.daily_tick`, `start`, `pause`, `set_assignees`, `tree_open`, `active`, `progress`, `weeks_estimate`, `area_has_star`, `missing_star_area`, `node_completed`, `state_of`.
  - `ResearchTree` `rnd_tree.json`'u okur (`children_of`, `cash_of`, `stars_of`).
  - `ResearchSeam.completed`, `placement`, `family`, `node_name` ürün hat kapılarının ve satışın okuduğu Ar-Ge kapısıdır.
  - Kartlar `EventBus.rnd_card_requested` ve ilk not için `product_note_issued` → `main.gd` → `RnDCardModal`.
  - Olay seam'leri `arge.*` (`seams_product.gd`).
- **Smoke:** `research_*`, `rnd_*`, `card_math_matches_gdd_example`, `paused_job_resumes_on_direct_return`, `founder_split_halves_flat_speed`, `split_bars_name_their_cause`, `line_k3_locked_without_research`.
- **Probe:** `PLAY ... research` (`_run_research`).
- **Görsel:** `--tab-shot=rnd`, `--modal-shot=rnd-note|rnd-discovery|rnd-discovery-line`.

## Ekip · GDD Ekip modülü, ch02

- **Yer:** `scripts/autoload/character_registry.gd`, `scripts/data_models/character.gd`, `scripts/systems/{hr_system,hr_constants,hr_actions,hr_candidate_generator,hr_search_system,hr_morale_system,work_hours_system,founder_constants}.gd`, `scripts/tabs/{hr_tab,personal_tab}.gd`, `scripts/tabs/hr/`, `scripts/modals/{hr_action_modal,training_modal,work_hours_modal}.gd`, `scenes/tabs/{HRTab,PersonalTab}.tscn`, `scenes/modals/{HRActionModal,HRAtlasModal,TrainingModal,WorkHoursModal}.tscn`, `assets/art/founders/`, `assets/icons/traits/`
- **Sahip:** autoload `CharacterRegistry`; sınıf `Character`, `HRSystem`, `HRConstants`, `HRActions`, `HRCandidateGenerator`, `HRSearchSystem`, `HRMoraleSystem`, `WorkHoursSystem`, `FounderConstants`; UI `HRUiShared`, `HRAssignments`, `HRLedger`, `HRPopover`
- **Giriş:**
  - `CharacterRegistry.get_character`, `get_founder`, `get_employees`, `get_active_employees`, `add`, `assign_job`, `unassign_job`, `get_total_monthly_salaries`.
  - `HRSystem.daily_tick` alt sistemlerin sırasını yönetir. Okumalar: `is_busy`, `assigned_to`, `skill`, `effective_skill`, `daily_contribution`, `is_overloaded`.
  - `HRSearchSystem.start_search`, `hire`; `HRMoraleSystem.apply_delta`, `send_on_leave`; `HRActions.apply_raise`, `apply_promotion`, `fire`; `WorkHoursSystem.hours_for`, `set_company_hours`, `end_hour_for`, `max_hours` (başlangıcın izin verdiği en uzun gün), `group_hours_in` (modal taslağının grup satırı), `in_office`, `workday_end` (gecenin tek girdisi, en geç 24), `sitting_open(hours)` (kurucunun dört oturumunun tek giriş kapısı: gece değil ve mesai bitimine en az `hours` var).
  - `HRConstants` rol, alan ve yıldız sözlüğüdür (`role_label`, `area_label`, `stars_for`). `FounderConstants` köken, trait ve beceri dağılımını verir. `HRUiShared` sekmeler arası UI yardımcılarının evidir.
  - Ekip dosyası (`scripts/tabs/hr/hr_dossier.gd`) kişinin ayrıntı penceresidir: `WindowLayer.open_detail("hr_dossier", {character_id})`. Kadro satırında ad ve avatar tıkı (`HRLedger.ACTION_DOSSIER`) ve ofiste kişiye tık açar, satırın gerisi menüyü (`ACTION_MENU`); aksiyonlar satır menüsüyle aynı kapıdan geçer (`HRLedger.action_list`). Kişi ayrılınca pencere kendini kapatır.
  - Kişisel sayfasının Kilometre Taşları kartı `GameState.milestones()`'u okur.
  - Olay seam'leri `hr.*` (`seams_hr.gd`, `seams_ported.gd`), `founder.*` (`seams_hr.gd`, `seams_world.gd`).
  - Smoke'a sabit adlar (başlıcaları; bkz. Araçlar > Smoke): `hr_popover._place`, `hr_morale_system.send_on_leave` ve `tick_leave_departures`, `hr_ledger.ACTION_MENU`. Emekli adlar `hr_popover`, `hr_actions`, `hr_tab` ve `hr_ledger` içinde geri gelmemeli.
- **Smoke:** `hr_*`, `founder_*`, `work_hours_*`, `coupling_*` (Ürün ile ortak), `alloc_guard`, `trait_formula`, `single_trait_contract`, `job_assignment_and_idle`, `overload_costs_output`, `leadership_is_trainable`, `promotion_and_raise_gate`, `effective_skill_formula`, `menu_has_one_path`, `vacation_action_retired`, `gorevler_has_no_founder`, `leave_does_not_pause_build`, `money_never_double_minus`, `role_locks_and_runway_pair`, `hires_land_in_own_column`, `cs_candidate_trait_filter`, `sales_candidate_curve_and_traits`.
- **Probe:** `HR`, `GATE` (roller ve maaş), `STATE` içinde `emp=`, `PLAY` (`_hire_after_the_seed`, `_keep_the_team`).
- **Görsel:** `--hr-shot=<tür>` (ör. `ekip`, `atlas`, `dosyalar`, `saatler`, `gorevler`, `zam`), `--tab-shot=hr|personal`.

## Satış · GDD Satış modülü

- **Yer:** `scripts/autoload/{customer_registry,prospect_registry,promise_registry}.gd`, `scripts/data_models/{customer,prospect,promise}.gd`, `scripts/systems/` altında `sales_*`, `b2b_*`, `customer_rep_system`, `company_catalog`, `negotiation_system`; `scripts/tabs/sales_tab.gd`, `scripts/modals/{sales_meeting_scene,sales_stage,negotiation_scene}.gd`, `scenes/tabs/SalesTab.tscn`, `scenes/modals/{SalesMeetingScene,NegotiationScene}.tscn`
- **Sahip:** autoload `CustomerRegistry`, `ProspectRegistry`, `PromiseRegistry`; model `Customer`, `Prospect`, `Promise`; sınıf `SalesSystem`, `B2BSalesSystem`, `SalesFaucetSystem`, `SalesMeetingSystem`, `NegotiationSystem`, `SalesRepSystem`, `CustomerRepSystem`, `SalesLedger`, `SalesProbes`, `SalesFinalizer`, `SalesConstants`, `SalesArchetypes`, `SalesNamePool`, `B2BConstants`, `CompanyCatalog`; UI `SalesMeetingScene`, `SalesStage`, `NegotiationScene`
- **Giriş:**
  - Yazma yüzeyi (WRITE-THROUGH): `CustomerRegistry.set_mrr`, `set_seats`, `set_satisfaction`, `add`, `remove`. Müşteri MRR'ını değiştiren alan dışı çağıran toplamı `SalesSystem.reflect_mrr()` ile GameState'e yansıtır.
  - `SalesSystem.daily_tick` (B2B yaşam döngüsünü de dağıtır) ve `hourly_tick` (B2C kitle ve MRR). Diğer: `add_b2b_customer`, `apply_b2c_price`, `b2c_audience`, `record_sales_event`.
  - `B2BSalesSystem.accept_promise`, `apply_discount`, `expand`, `pick_pain_feature`, `refresh_pains_after_ship`.
  - `SalesFaucetSystem.spawn` aday üretir; `expire_leads` süresi dolan lead'i temsilci masasından sonra düşürür (`B2BSalesSystem.daily_tick`). `SalesMeetingSystem.open` / `choose` / `view_state` ve `NegotiationSystem.open` / `offer` / `accept_counter` / `walk` toplantı akışıdır. Giriş kapısı `SalesLedger.meeting_block_reason` (`WorkHoursSystem.sitting_open(MEETING_ENTRY_CUTOFF_HOURS)`: gece ya da mesai bitimine 2 saatten az; sonra haftada `MEETINGS_PER_WEEK` toplantı); `SalesMeetingSystem.close` kurucuyu serbest bırakır ve saati `MEETING_SKIP_HOURS` kadar ilerletir (`TimeManager.advance_hours`).
  - `SalesRepSystem` temsilcinin işlediği lead'i her tik lig farkının kapanma ihtimaliyle zarlar (`close_chance`, `SalesConstants.PROCESS_CLOSE_CHANCE`, `RngStreams` `sales_rep` akışı).
  - `PromiseRegistry.create`, `tick_deadlines`; `ProspectRegistry.get_prospect`, `remove`.
  - UI yolu: `EventBus.pitch_requested` → `main.gd` → `SalesMeetingScene`.
  - Olay seam'leri `musteri.*`, `sales.*`, `destek.*` (`seams_sales.gd`, `seams_ported.gd`).
- **Smoke:** `sales_*`, `b2b_*`, `b2c_*`, `cs_*`, `promise_*`, `hotfix_*`, `discount_*`, `risk_*`, `seat_upsell_moves_seats`, `satisfaction_seam_emits`, `prospect_id_unique_after_removal`, `company_catalog_pool_integrity`, `recover_preserves_onboarding`, `owned_account_erodes_slower`, `account_ownership_round_trip`, `founder_owns_accounts_manually`, `conversion_bug_penalty`, `audience_pct_modifier`, `complaint_never_charges_cash`, `retention_gate_shared`, `manual_retention_respects_cap`.
- **Probe:** preset'ler `b2b_*`, `b2c*`. Kayıtlar `STATE` (`mrr=`, `cust=`, `promises=`, `aud=`, `sat=`), `CUST`, `SAT`, `CHURN`, `PROMISE`, `DISCOUNT`, `RETAIN`, `PLAY` (`_meet`).
- **Görsel:** `--sales-shot[=pipeline|desk|b2c]`, `--b2b-shot=<tür>`, `--meeting-shot=<probe|locked|won|lost|handoff>`, `--negotiation-shot=<tür>`, `--tab-shot=sales`.

## Finans · GDD ch08

- **Yer:** `scripts/systems/{finance_system,summary_system}.gd`, `scripts/tabs/finance_tab.gd`, `scripts/tabs/finance/finance_ozet_view.gd`, `scripts/modals/month_summary_modal.gd`, `scripts/ui/components/cash_curve.gd`, `scenes/tabs/FinanceTab.tscn`, `scenes/modals/MonthSummaryModal.tscn`
- **Sahip:** sınıf `FinanceSystem`, `SummarySystem`, `FinanceOzetView`, `CashCurve`; kasa, ay defteri (`month_ledger`, `month_history`) ve dönem defteri (`summary_ledger`) `GameState`'te
- **Giriş:**
  - `FinanceSystem.daily_tick` haftanın akışını uygular ve runway'i yeniden hesaplar: kasa tik başına 7 × (round(MRR / 30) − günlük burn) değişir. Oranlar (maaş ÷ 30, altyapı faturası, ek mesai) günlük kalır; ×7 yalnız burada yapılır. `apply_one_time_cost`, `apply_one_time_income`, `get_burn_breakdown`, `set_burn_category`, `get_monthly_flow` (TopBar'ın ve Finans'ın canlı aylık burn ve neti). Runway eşikleri `RUNWAY_ALERT_MONTHS` (Finans rozeti ilkini, şerit satırı ikisini okur), `runway_band`.
  - `SummarySystem` ay kapanışının ve dönem özetinin sahibidir. `begin_day` (yuva 0): tikin Perşembe'si yeni bir aya düştüyse biten ay `month_history`'ye itilir, `EventBus.month_ended` yayılır ve yeni ay defteri açılır; bu haftanın akışı yeni aya yazılır. Oyuncunun sıklığı (`summary_frequency`, `SummarySystem.FREQUENCIES`: haftalık, aylık, çeyreklik, yıllık) dönemi bu tikte kapatıyorsa özet yükü kurulur ve yeni dönem açılır. `daily_tick` (yuva 10, sonlardan sonra, yalnız koşu sürüyorsa): ay kapanışı satırı (`MONTH_CLOSED_TICKER`) ve runway eşiği satırı `EventBus.ticker_live_line` ile şeride, özet `EventBus.summary_ready` ile `main.gd` → `MonthSummaryModal`'a gider. `frequency_override` oyuncunun ayarını ezer (smoke); F11 dönemin şimdiye kadarki özetini yayar (`debug_force_summary`).
  - `finance_tab.gd` Yatırım alt sayfasında `HuntTab`'i barındırır (Fonlama). `FinanceOzetView` Özet'te faz hedefi kartını (`_refresh_goal`) ve pazar payı merdivenini (`_refresh_league`, `RivalRegistry.get_market_snapshot`) taşır.
  - Olay seam'leri `finance.*` (`seams_finance.gd`).
- **Smoke:** `month_summary`, `summary_frequency_ticks`, `month_history_*`, `burn_*`, `runway_*`, `gross_runway_months`, `run_ledger`, `targeted_modifier_hits_named_customer`.
- **Probe:** `STATE` (`cash=`, `burn=`, `runway=`), `MONTH`, `MONTH_BURN`, `GATE` içindeki gider kalemleri.
- **Görsel:** `--finance-shot=<tür>` (ör. `ozet`, `artida`, `uyari`, `kepenk`), `--modal-shot=month`, `--tab-shot=finance`.

## Fonlama merdiveni · GDD ch09

- **Yer:** `scripts/autoload/investor_registry.gd`, `scripts/data_models/term_sheet.gd`, `scripts/systems/{angel_round_system,seed_round_system,seed_constants,phase_gate_system,vc_pitch_system,pitch_constants,term_sheet_table_system}.gd`, `scripts/tabs/hunt_tab.gd`, `scripts/modals/{meeting_scene,term_sheet_table_scene}.gd`, `scripts/ui/components/{conviction_track,radial_dial,dialogue_choice_card,investor_appetite_ui}.gd`, `scenes/tabs/HuntTab.tscn`, `scenes/modals/{MeetingScene,TermSheetTableScene}.tscn`, `scenes/ui/components/{ConvictionTrack,DialogueChoiceCard}.tscn`, `assets/art/investors/`, `assets/art/rooms/`
- **Sahip:** autoload `InvestorRegistry`; sınıf `TermSheet`, `AngelRoundSystem`, `SeedRoundSystem`, `SeedConstants`, `PhaseGateSystem`, `VCPitchSystem`, `PitchConstants`, `TermSheetTableSystem`, `MeetingScene`, `TermSheetTableScene`, `ConvictionTrack`, `RadialDial`, `DialogueChoiceCard`, `InvestorAppetiteUi`
- **Giriş:**
  - `PhaseGateSystem.daily_tick` faz kapısını mandallar ve `EventBus.phase_gate_reached` yayar. `series_a_signal`, `on_gate_declined`. Oyun içinde faz yalnız `GameState.advance_phase` ile ilerler; `set_phase` debug arka kapısıdır.
  - `AngelRoundSystem.accept_offer` (Frank); `SeedRoundSystem.daily_tick`, `door_open`, `begin_pitch`, `make_seed_sheet`, `accept`.
  - `VCPitchSystem.daily_tick`, `begin_meeting`, `sheet_for`; `TermSheetTableSystem.open`, `push`, `sign`, `walk`, `leave`, `view_state`.
  - Oturumun saati: giriş kapısı `WorkHoursSystem.sitting_open(hours)` (Ekip bölümü; seam'leri `funding.meeting_sitting_open`, `funding.table_sitting_open`). Oturum kapanınca `VCPitchSystem.end_sitting` ve `TermSheetTableSystem.end_sitting` saati `PitchConstants.MEETING_HOURS` / `TERM_TABLE_HOURS` kadar ilerletir (`TimeManager.advance_hours`); koşuyu bitiren imzada atlama yoktur.
  - `InvestorRegistry.get_investor`, `get_active`. Tur kayıtları `GameState.record_angel_round`, `record_seed_round`, `mark_faced_series_a`.
  - UI yolu: `EventBus.meeting_scene_requested`, `term_table_requested` → `main.gd`.
  - Olay seam'leri `funding.*`, `investor.*`, `phase.*` (`seams_ported.gd`, `seams_world.gd`).
- **Smoke:** `angel_*`, `seed_*`, `series_a_*`, `pitch_*`, `table_*`, `meeting_*`, `gate1_*`, `gate2`, `gate_decline_reminder`, `traction_gate_one_option`, `full_loop`, `gecistir_cap`, `callback_contract`, `sheet_expiry_no_rejection`, `third_sheet_delayed`, `cascade_defer_with_sheet`, `walk_not_a_rejection`, `patience_zero_locks_pushes`, `push_decay_lowers_odds`, `leverage_bonus_applies_and_shows`, `no_leverage_no_box`, `investment_figure_tracks_terms`, `deal_prompt_defer_keeps_clock`, `hunt_offer_lifecycle`, `legacy_v12_save_opens_live_table`, `prep_bonus_and_capacity`, `pivot_closes_hunt`, `lever_skill_new_keys`, `frank_approach_lines_once`, `growth_streak_semantics`.
- **Probe:** `SIGNAL`, `GATE`, `STATE` (`appetite=`, `approach=`, `gate_ready=`); `VC_CONFIG`, `VC_BOOK`, `VC_MEET`, `VC_PUSH`, `VC_TABLE_OPEN`, `VC_TABLE_END`, `VC_REPLAY`, `VC_REPLAY_SUM` yalnız `full_run_vc_*` preset'lerinde.
- **Görsel:** `--vc-shot=<hunt|hunt_closed|table|table_final|table_walk|table_other|seed_table|k10>`.

## Dünya (rakip, haber) · GDD ch10

- **Yer:** `scripts/autoload/rival_registry.gd`, `scripts/data_models/rival.gd`, `scripts/systems/{rival_catalog,news_feed_system}.gd`, `scripts/ui/components/news_ticker.gd`, `scenes/ui/components/NewsTicker.tscn`
- **Sahip:** autoload `RivalRegistry`; sınıf `Rival`, `RivalCatalog`, `NewsFeedSystem`
- **Giriş:**
  - `RivalRegistry.advance_all` (günlük), `get_all`, `get_rival`, `get_market_snapshot`, `get_player_share_pct`, `format_share`; `RivalCatalog.build_all`.
  - `NewsFeedSystem.daily_tick`, `on_headline_added` (`EventBus.headline_added`), `get_stream`, `outlet_name`. Şerit `news_ticker.gd`; olay motoru satırlarını `EvTicker.push` aynı sinyalle gönderir.
  - Olay seam'leri `rival.*` (`seams_world.gd`).
- **Smoke:** `market_share_tracks_mrr`, `news_feed_weights_and_no_repeat`, `hotfix_ticker_routine_vs_news`, `rival_relative_uses_template_half_sat`.
- **Probe:** adanmış kayıt yok; `STATE` içindeki `q=` rakibe göre kalitedir.
- **Görsel:** adanmış bayrak yok; şerit her kabuk karesinde görünür (`--tab-shot=`).

## Sonlar ve gazete · GDD ch13, ch14

- **Yer:** `scripts/systems/{endings_system,endings_copy}.gd`, `scripts/modals/ending_scene.gd`, `scenes/modals/EndingScene.tscn`, `assets/endings/` (gravür yeri ve README). İçerik: `data/events/cards/world/final_stretch_*`, `data/events/arcs/soft_cap_stretch.json`
- **Sahip:** sınıf `EndingsSystem`, `EndingsCopy`, `EndingScene`; autoload yok
- **Giriş:**
  - `EndingsSystem.daily_tick` terminal koşulları öncelik sırasıyla tarar. Bitiş `trigger_ending`, kilometre taşı `trigger_milestone` ile tetiklenir.
  - `build_scope()` build kapsamını (`BUILD_DEMO`, `BUILD_EA`, `BUILD_FULL`) export'ta özellik etiketinden (`ea`/`full`), debug build'de `--build=`'den (komut satırı ya da `main_args`) okur; etiketsiz ise demo. Smoke ve probe `build_scope_override` ile demoya sabitler; kart havuzu da aynı sabitlemeyi izler. Projede henüz export ön ayarı yok: `ea` etiketi olmayan bir EA export'u demo gibi davranır. `ending_mode`, `bootstrap_milestone_taken`, `profitability_signal`, `acquisition_valuation`, `road_over`.
  - `EndingsCopy.build` gazete görünümünü üretir; `EndingScene` yalnız onu boyar.
  - UI yolu: `EventBus.run_ended`, `milestone_reached` → `main.gd`.
  - Smoke'a sabit (başlıcası; bkz. Araçlar > Smoke): `trigger_ending` imzası (`event_i3_no_silent_loss`).
- **Smoke:** `bankruptcy*`, `soft_cap_*`, `profit_*`, `ending_*`, `bootstrap_*`, `milestone_*`, `buyout_*`, `faced_flag_*`, `shutter_recovery`, `brand_collapse`, `cascade`, `pivot_accept`, `pivot_decline`, `terminal_kills_gate`, `fumes_zero_revenue_ledger`, `no_calendar_stop_before_cap`, `b2c_ending_reports_audience`, `frank_line_renders_outside_the_paper`.
- **Probe:** `END ... ending=` (`full_run*` preset'lerinde), `STATE` içinde `profit_streak=`.
- **Görsel:** `--ending-shot=<ending_id>` (takma adlar dahil); EA/full akışı `--build=ea|full` ile.

## Olay motoru · GDD Olay Motoru rev 2 (.md)

- **Yer:** `scripts/events/event_gate.gd`, `scripts/events/{catalog,core,gate,present,seams}/`, `scripts/data_models/{event,event_choice}.gd`, `scripts/modals/event_modal.gd`, `scenes/modals/EventModal.tscn`
- **Sahip:** sınıf `EventGate` (statik cephe, autoload değil); `EvCatalog`; `core/` → `EvEngine`, `EvQueue`, `EvHistory`, `EvFlags`, `EvLatches`, `EvSchedule`, `EvArcs`, `EvEffects`, `EvCondition`, `EvDice`, `EvBudgets`, `EvSignals`, `EvSave`, `EvTuning`; `gate/` → `EvGate`, `EvScope`; `present/` → `EvPresenter`, `EvPapers`, `EvTempo`, `EvTicker`; `seams/` → `EvSeams` ve `EvSeams*`; model `GameEvent`, `EventChoice`
- **Giriş:**
  - Tek giriş `EventGate.request(id, ctx)`. Ayrıca `resolve`, `daily_tick` / `hourly_tick` (TimeManager), `condition_met` / `condition_reason` (kilitli satırlar), `desk_papers` / `open_paper` (`DeskPapers`), `active_id` / `active_context`, `remove_queued`, `to_dict` / `from_dict`.
  - Sunum: `EvPresenter.build_view` → `EventBus.modal_requested` → `main.gd` → `event_modal.gd` → seçim `EventGate.resolve`.
  - EventBus sinyalleri motora `EvSignals.BINDINGS` ile bağlanır. Okumalar yalnız adlı seam'lerden geçer (`EvSeams.read`); seam adları alan dosyalarında (`seams_*.gd`) kayıtlıdır.
  - Kapsam: `EvTuning.SHIPPED_SCOPES` hangi `version_scope` değerlerinin havuza girdiğini belirler; değeri `EndingsSystem.shipped_scopes()`'tan (`SHIPPED_SCOPES_BY_BUILD`: demo ⊂ ea ⊂ full) gelir ve `build_scope_override`'ı izler.
  - Efekt rozetlerinin tek kurucusu `event_modal._describe_modifier`. Smoke `SILENT_VERBS` sabitini okur.
- **Smoke:** `event_*`, `ambient_*`, `harness_sniffer_matches_run_log`, `source_tag_speaker_wins`.
- **Probe:** `FIRE`, `PICK`, `TALLY_BEGIN` / `TALLY` / `TALLY_END`, `WEEK`, `ERROR` (drain koruması, kilitsiz seçeneği olmayan kart).
- **Görsel:** `--event-shot=<kart id>`, `--b2b-shot=<tür>`. Motorun kendi araçları Araçlar altında.

## Olay içeriği (data/events) · GDD ch11

- **Yer:** `data/events/cards/<kategori>/*.json`, `data/events/arcs/*.json`
- **Sahip:** yükleyici `EvCatalog`; `cards/` altında özyinelemeli yürür; `unwired` ve `drafts` adlı dizinlere ve `.` ile başlayan dizinlere hiç girmez, `_` ya da `ev_debug_` ile başlayan dosyaları havuza almaz. Kategori sahipleri: `customer` → Satış, `funding` → Fonlama, `product` → Ürün, `team` → Ekip, `world` ve `arcs/soft_cap_stretch.json` → Sonlar.
- **Giriş:**
  - Kart metni `text.tr` ve `text.en` bloklarındadır; seçenek id'leri iki dilde aynıdır. Koşul ve efektler yalnız kayıtlı seam ve fiilleri kullanır.
  - `cards/_fixtures/` ve `arcs/fixture_*` motor test içeriğidir: `version_scope: "fixture"` taşır, normal koşuda havuza girmez (klasör README'si).
  - İlgili belgeler: `docs/content/events_draft/_vocabulary.md` (`--event-vocab` üretir, KEEP bloğu elle), `docs/content/`, `docs/writing/`.
- **Smoke:** `card_body_tokens_resolve`, `loc_event_en_coverage`, `event_chip_coverage`, `event_thesis_*`.
- **Probe:** `FIRE`, `PICK`, `TALLY`.
- **Görsel:** `--event-shot=<kart id>`. Kapı `--event-lint` (taban `tools/lint_baseline.json`).

## Onboarding · GDD ch02, ch12

- **Yer:** `scripts/onboarding/{language_gate,onboarding_flow}.gd`, `scripts/onboarding/steps/`, `scenes/onboarding/`, `scripts/modals/mentor_intro_modal.gd`, `scenes/modals/MentorIntroModal.tscn`, `scripts/ui/components/{logo_emblem,segment_bar}.gd`
- **Sahip:** sınıf `OnboardingStep`, `LogoEmblem`, `SegmentBar`; kurallar `FounderConstants`'ta (Ekip)
- **Giriş:**
  - `main.gd` akışı kurar; `OnboardingFlow` son adımda `GameState.initialize_run(draft)` çağırır ve `completed` yayar; `main.gd` kabuğu ve `MentorIntroModal`'ı açar.
  - `LanguageGate` seçilen dili `Localization.set_language` ile yazar ve `chosen` yayar.
- **Smoke:** `onboarding_pages_contract`; adımın kullandığı kurallar için `founder_5skill_init`, `alloc_guard`, `trait_formula`.
- **Probe:** yok; probe onboarding'i atlar.
- **Görsel:** `--onboard-shot=<1|2|3>`, `--force-language-gate`, `--modal-shot=mentor`. `project.godot` `main_args`'taki `--skip-onboarding` doğrudan kabuğa geçer.

## Araçlar (smoke, probe, loc_residue, events/tools, tools/)

- **Smoke:** `scripts/debug/endgame_smoke.gd` (`EndgameSmoke`). Vaka listesi dosyadaki `match case_name:` tablosudur. Koşturucu `tools/smoke_run.sh <vaka>|--all`; stderr'de betik hatası gören vakayı düşürür. `run_case` her vakada tohumu ve build kapsamını (demo) sabitler.
  - Smoke özel fonksiyonları ve sahne düğüm adlarını da doğrudan çağırır; sembol adını değiştirmeden önce `endgame_smoke.gd`'de ara.
  - Paylaşılan kayıt yuvasına yazan vakalar paralel koşturulmaz (koşturucu zorlamaz: `--all` sırayla koşar, elle paralel koşuda koruma yoktur; ortak yuvalar `manual_9001` / `manual_9002`): `legacy_v12_save_opens_live_table`, `sales_save_roundtrip_rev6`, `cs_request_kind_state_driven`, `account_ownership_round_trip`, `save_roundtrip_fingerprint`, `save_continuity_seeded`, `save_double_load_no_residue`, `month_history_save_typing`, `milestone_paper_under_card`, `save_v10_product_state`.
  - `all_scripts_load` `scripts/` ve `scenes/` altındaki her `.gd`'yi derler; `addons/`'u kapsamaz.
- **Probe:** `scripts/debug/run_probe.gd` (`RunProbe`), `--run-log=<preset>:<hafta>:<mod>[:<tohum>]`; mod `sim` ya da gerçek saat hızı `1|2|3|4`. `sim` modu belirlenimcidir; yalnız `^PROBE` satırları karşılaştırılır. Preset aileleri: `full_run*` (oynanan koşu), `full_run_vc_*` (Series A masası, yalnız `sim`), `b2b_*` ve `b2c*` (fikstür dünyası). Kayıt türleri: `BEGIN`, `STATE`, `SIGNAL`, `GATE`, `CUST`, `SAT`, `FIRE`, `PICK`, `DISCOUNT`, `CHURN`, `PROMISE`, `SHIP`, `MONTH`, `MONTH_BURN`, `PLAY`, `FIXTURE`, `RETAIN`, `WEEK`, `TALLY*`, `END`, `HR`, `VC_*`, `ERROR`.
- **Metin kapısı:** `scripts/debug/loc_residue.gd` (`-s` ile). Betiklerde Türkçe literal, CSV'de olmayan sahne metni ve statik fonksiyonda `tr()` arar. Veri olan literal satırı `# LOC-DATA <gerekçe>` ile işaretlenir.
- **Olay motoru araçları** (`scripts/events/tools/`): `EvProbe` (`--event-probe`), `EvLint` (`--event-lint`; `=baseline` taban dosyasını yeniden yazar), `EvWhy` (`--why-fire=<id>`), `EvHarness` (`--event-harness=random:seeds=N:weeks=M|guided[:seeds=N:weeks=M]`), `EvVocabGen` (`--event-vocab` → `_vocabulary.md`).
- **`tools/`:** `smoke_run.sh`, `gen_signal_manifest.py` (`event_bus.gd` sinyalleri ve `# --- X ---` başlıkları, `scripts/` altındaki emit/connect satırları, `EvSignals.BINDINGS` ve `data/events/cards` kart tetiklerinden `docs/EVENT_SIGNAL_MANIFEST.md` üretir), `lint_baseline.json`.
- **Görsel ve ölçüm bayrakları** yalnız debug build'de çalışır. Bayraklar `--` ayıracının arkasına konmaz.
  - `*-shot` bayrakları (`--probe-shot` dahil) pencereli açılır ve kareyi kullanıcı dizinine (`%APPDATA%/Godot/app_userdata/Project Unicorn/`) yazar. `--theme-audit` pencereli açılır, kare yazmaz, denetim satırlarını basar.
  - Ölçüm bayrakları (`--tempo-probe`, `--render-probe`, `--display-check`) kare yazmaz, ölçüm satırlarını basar.
  - Dosya yazanlar: `--event-lint=baseline`, `--modal-shot=saveload`, `--event-vocab`, `--display-check` (`settings.json`'a yazar ve geri yükler).

## Üçüncü taraf ve altyapı

- **`addons/`:** `auto_reload`, `godot_mcp_editor`, `godot_mcp_runtime`. Üçüncü taraf, dokunulmaz. `godot_mcp_runtime` `MCPRuntime` autoload'unu kaydeder (yalnız debug build, yerel TCP).
- **`.mcp.json` (git kökü):** Claude Code için Godot MCP sunucusu (gopeak). Kalır.
- **`.githooks/pre-commit` (git kökü):** isteğe bağlı; `git config core.hooksPath .githooks` ile açılır. İlgili yollar sahnelenince `--event-lint` ve `loc_residue` koşturur. CI yok.
- **Ofis 3B dışa aktarım hattı (çevrim dışı; oyun yalnız çıktılarını yükler):**
  - `tools/office3d/`: tasarımın Three.js kaynağının birebir kopyası (`src/`; kaynak ve deltalar `DESIGN_SOURCE.md`), dışa aktarım sayfası (`export_office.html`, `export_office.js`), `serve.py`, `run_export.sh` ve denetim `check_export.py`. Tarif ve tuzaklar `README.md`'de. `.gdignore` taşır.
  - Çıktılar: `art/office3d/<id>.glb` ve `<id>.json` (`home`, `ishani`, `plaza`, `loft`, `city`), `assets/art/office/thumb_<id>.jpg`. Koşu Chrome'u ön planda açar ve ağ ister (esm.sh, Xbot). Sonra `--headless --import` ve bir ısınma koşusu (sınıf önbelleği tuzağı); içe aktarıcı GLB'nin gömülü dokularını `art/office3d/<id>_<n>.png` olarak çıkarır.
- **Üçüncü taraf varlıklar:** ray ikonları (`assets/icons/tabs/`) ve ofisin kafa üstü ikonlarındaki glifler Lucide'dir (ISC, `assets/icons/tabs/LICENSE-lucide.txt`); `assets/art/office/xbot.glb` Mixamo X Bot'tur (kaynak ve not `assets/art/office/README.md`).
- **Kök dosyalar:** `project.godot` (ana sahne, `main_args`, autoload sırası, viewport), `icon.svg`, `.editorconfig`, `.gitattributes`, `.gitignore`. Git kökündeki `.agents/`, `.claude/skills/` ve `skills-lock.json` projenin parçası değildir.
