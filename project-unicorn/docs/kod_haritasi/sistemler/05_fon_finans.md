# Finans, yatırım turları, rakipler, haberler ve sonlar

Dizin git sha: f3113fa4 (DIZIN.md, 2026-10-22). Yol:satır başvuruları bu ağacın diskteki halinden; kirli ağaçta satırlar kayabilir.

Ne yapar: Kasa, burn, tek seferlik giderler ve ay akışı `FinanceSystem`dedir. Fon merdiveni (Frank'in çeki, faz kapısı, VC görüşmesi, term sheet) ve koşuyu bitiren sonlar bu dosyadaki statik sistemlerdir.
Rakip payı, Piyasa listesi, haber şeridi akışı ve gelen kutusu mesajlarının teslim saati de buradadır. Hepsi `TimeManager._dispatch_daily_tick` yuvalarından tik başına koşar; durum `GameState`'tedir.

## Dosyalar

Kapsam içi (`scripts/`):
- `systems/finance_system.gd` (325): kasa tiki, burn kalemleri, tek seferlik gider/gelir, işlem günlüğü, pazarlama kampanyası, runway eşikleri.
- `systems/angel_round_system.gd` (52): Frank'in çeki. `accept_offer` kasayı, hisse tablosunu ve sürümü tek adımda yazar.
- `systems/cheque_read.gd` (60): koşunun adlı hedef listesi (çek, sonra seed). `class_name` yok, okuyanlar preload eder.
- `systems/phase_gate_system.gd` (178): faz kapısı mandalı (Traction ve Series A), Series A sinyali ve yaklaşma adımı.
- `systems/vc_pitch_system.gd` (1327): VC görüşmesi (5 vuruş), inanç, teklif üretimi, term sheet sonuçları, geri arama, görüşme takvimi.
- `systems/pitch_constants.gd` (187): VC odasının ve masanın ayar sabitleri; `class_name PitchConstants`.
- `systems/skill_check.gd` (104): `SkillCheck`, kurucu beceri zarı: `chance_for` `:35`, `breakdown` `:40`, `roll_against` `:57`, `resolve` `:66` (pay bandı), `can_read_prospect` `:103`.
  ↳ okuyan `vc_pitch_system.gd`, `term_sheet_table_system.gd:276,649`, `vc_meeting_adapter.gd`, `origin_traits_step.gd:246` (`SALES_READ_THRESHOLD`); RNG akışı `skill` (`rng_streams.gd`).
- `systems/quality_model.gd` (37): `QualityModel`, rakibin üç boyutunun azalan getirili büyümesi `grow` `:22` ve bileşik kalite `composite_quality` `:29`.
  ↳ okuyan `RivalRegistry.advance_all` (`rival_registry.gd:78-80`) ve `Rival.composite()`; oyuncunun ürün kalitesi değil (o `ProductQuality`, 02_urun_sprint.md).
- `systems/endings_system.gd` (527): terminal taraması, kepenk, bitiş ve kilometre taşı kapıları, satın alma teklifinin sayıları, build kapsamı.
- `systems/endings_copy.gd` (539): bitiş gazetesinin satırlarını kuran saf okuyucu; `EndingScene` yalnız onu boyar.
- `systems/mail_clock.gd` (121): mail, kâğıt, not, hatırlatıcının geliş saati; mesai penceresi dışı üretileni pencereye taşır.
- `systems/message_system.gd` (77): gelen kutusunun motor kartı olmayan mesajları; `GameState.messages` ve `mail_outbox`un tek yazarı.
- `systems/news_feed_system.gd` (429): şeridin veri kaynağı; sektör, rakip, piyasa ve biz satırlarının haftalık kotalı akışı.
- `systems/rival_catalog.gd` (167): rakip tohum verisi (TEMPLATE, NAMES, SHARE_SEED, MARKET_ACTORS); `build_all` rakipleri kurar.
- `systems/market_catalog.gd` (217): Piyasa listesi; `data/market/*.json` üstünde saf değer fonksiyonu.
- `autoload/rival_registry.gd` (210): rakip alanının sahibi; günlük ilerleme ve durumsuz pazar payı anlık görüntüsü.
- `autoload/investor_registry.gd` (145): dört fonun statik tablosu (`INVESTORS`) ve kopya erişicileri.
- `data_models/rival.gd` (38): `Rival` kaynağı; `composite()` yalnız smoke okur.
- `tabs/piyasa_tab.gd` (689): Piyasa penceresi; sayı hesaplamaz, `MarketCatalog` ve `GameState.get_valuation_m` okur.

Komşu (bu sistemin kapısını açar ya da okur, başka haritada ele alınır):
- `systems/seed_round_system.gd` (225), `seed_constants.gd` (149), `term_sheet_table_system.gd` (987), `counterpart_system.gd` (101), `data_models/term_sheet.gd` (63).
- `systems/summary_system.gd` (244): ay kapanışı ve dönem özeti; runway eşiği satırını şeride yazar.
- Arayüz: `tabs/finance_tab.gd` (144), `tabs/finance/finance_ozet_view.gd` (590), `tabs/hunt_tab.gd` (544), `modals/ending_scene.gd` (563), `ui/components/news_ticker.gd` (237).
- Veri: `data/market/{companies,people}.json`, `data/product/rivals.json` (okuyan `systems/sprint_catalog.gd:12`), `data/events/cards/funding/*.json`.

## Giriş noktaları

Günlük dağıtım sırası `TimeManager._dispatch_daily_tick` (`autoload/time_manager.gd`):
- `RivalRegistry.advance_all()` `autoload/rival_registry.gd:71`: rakip boyutlarını büyütür · `time_manager.gd:406`.
- `FinanceSystem.daily_tick()` `systems/finance_system.gd:119`: maaş ve ek mesai çeker, bir haftanın gelir ve burn'ünü kasaya yazar · `time_manager.gd:410`.
- `PhaseGateSystem.daily_tick()` `systems/phase_gate_system.gd:68`: koşulu sağlanan kapıyı mandallar · `time_manager.gd:414`; hemen ardından `SeedRoundSystem.daily_tick()` (`:415`).
- `NewsFeedSystem.daily_tick()` `systems/news_feed_system.gd:148`: haftanın 3-5 şerit satırını besler · `time_manager.gd:421`, olay yuvasından sonra.
- `VCPitchSystem.daily_tick()` `systems/vc_pitch_system.gd:854`: bekleyen teklif, geri arama, görüşme günü, geri sayım çipi · `time_manager.gd:424`, Endings'ten önce.
- `EndingsSystem.daily_tick()` `systems/endings_system.gd:82`: terminal koşullarını öncelik sırasıyla tarar · `time_manager.gd:426`.
- `MailClock.sync_desk()` `systems/mail_clock.gd:112`: hatırlatıcıların geliş saatini yazar · `time_manager.gd:430`; saatlik koşu `MailClock.hourly_tick()` `mail_clock.gd:68` · `time_manager.gd:447`.

Finans:
- `FinanceSystem.apply_one_time_cost()` `finance_system.gd:179` ve `apply_one_time_income()` `:189`: önce işlem satırı, en son `set_cash` · `events/core/effects.gd:234`, `systems/hr_actions.gd:15`, `office_system.gd:66`,
  `rnd_system.gd:25`, `sprint_system.gd:159`, `incident_system.gd:521`.
- `FinanceSystem.set_burn_category()` `:216`: kalemi yazar, `daily_burn`ü hemen tazeler · `infra_system.gd:224`, `office_system.gd:89`.
- `FinanceSystem.start_marketing_push()` `:162`: kartın pazarlama kampanyasını başlatır · `events/core/effects.gd:295`; çarpan `marketing_growth_mult()` `finance_system.gd:171` · `sales_system.gd:204`.
- `FinanceSystem.get_burn_breakdown_pct()` `:281`, `get_monthly_flow()` `:271`, `runway_band()` `:313`: okuma kapıları · `finance_ozet_view.gd`, `top_bar.gd`, `summary_system.gd:161`.
- `FinanceSystem.to_dict()/from_dict()/reset()` `:87/:93/:79`: yalnız `burn_breakdown`; blok `autoload/save_manager.gd:381` ve `:399`, sıfırlama `:349`.

Fon merdiveni:
- `AngelRoundSystem.accept_offer()` `angel_round_system.gd:37`: çekin kabulü · `events/core/effects.gd:558` (`angel_accept` fiili, kart `funding.frank_cheque`).
- `ChequeRead.list()/steps()/summary()` `cheque_read.gd:15/:27/:53`: hedef listesi · `finance_ozet_view.gd:300`, `personal_tab.gd:198`, `top_bar.gd:269`, `inbox.gd`, `office_notice_stack.gd:128`.
- `PhaseGateSystem.on_gate_declined()` `phase_gate_system.gd:94`: "Henüz değil" · `events/core/effects.gd:555` (`phase_gate_decline` fiili).
- `PhaseGateSystem.on_shutter_started()` `:102`: sıradaki kapı kartlarını kuyruktan çeker · `EndingsSystem._tick_shutter` `endings_system.gd:119`.
- `PhaseGateSystem.series_a_signal()/series_a_approach()` `:135/:157`: kapalı, ısınıyor, açık okuması · `seams_world.gd:37`, `finance_ozet_view.gd:328`, `investor_appetite_ui.gd`.
- `VCPitchSystem.request_meeting()` `vc_pitch_system.gd:772`: görüşme rezervasyonu · `main/main.gd:4265` (Av sekmesinin düğmesi).
- `VCPitchSystem.begin_meeting()` `:59`: görüşmeyi açar, `meeting_scene_requested` yayar · `main.gd:4503`, `main.gd:4916`, seed için `seed_round_system.gd:109`.
- `VCPitchSystem.advance()` `:107` ve `withdraw()` `:118`: vuruş çözümü · `ui/meeting/vc_meeting_adapter.gd:67`, `:99`; kapanışta `end_sitting()` `vc_pitch_system.gd:131` (adapter `vc_meeting_adapter.gd:104`) saati ilerletir.
- `VCPitchSystem.call_waiting()/lapse_call()/postpone_call()` `:784/:801/:794`: fonun çağrısı · `main.gd:4836`, `:4603`, `:4691`.
- `VCPitchSystem.sign_table()/walk_table()` `:554/:608`: masa sonuçları · `term_sheet_table_system.gd:562`, `:350`, `:602`; sign Series A'da `EndingsSystem.trigger_ending("series_a_close")` çağırır.
- `VCPitchSystem.decline_expired_sheet()` `:637`: süresi dolan teklifi kapatır, ret sayılmaz · `events/core/effects.gd:574`.
- `VCPitchSystem.add_strain()` `:262`: fona kırgınlık · `events/core/effects.gd:581` (`investor_strain` fiili).
- `InvestorRegistry.get_investor()/get_active()/favored_angle()` `investor_registry.gd:92/:104/:113`: fon tablosu okuması · `vc_pitch_system.gd`, `term_sheet_table_system.gd`, `hunt_tab.gd`.

Sonlar:
- `EndingsSystem.trigger_ending(ending_id, telegraph, extra)` `endings_system.gd:471`: tek terminal kapı; `run_ended` yayar · `vc_pitch_system.gd` (`sign_table`), `events/core/effects.gd:658`, debug `game_shell.gd:203`.
- `EndingsSystem.trigger_milestone()` `:433`: EA/full'de kârlı bootstrap kilometre taşı; `milestone_reached` yayar · `_check_profitable_bootstrap` `:222`.
- `EndingsSystem.build_scope()` `:387`, `shipped_scopes()` `:408`, `ending_mode()` `:422`: build kapsamı · `events/core/tuning.gd`, `modals/ending_scene.gd:65`, `main.gd:86`.
- `EndingsSystem.road_over()` `:304`, `acquisition_valuation()` `:270`, `acquisition_founder_share()` `:278`, `profitability_signal()` `:203`: kart ve arayüz okumaları · `seams_ported.gd:170-181`, `finance_ozet_view.gd:231`.
- `EndingsSystem.on_buyout_declined()` `:343`: Series A yolunu kapatır, reddi hatırlar · `events/core/effects.gd:590` (`decline_buyout` fiili).
- `EndingsCopy.build()` `endings_copy.gd:52`: gazete görünümü · `modals/ending_scene.gd:67`.

Mesaj ve teslim saati:
- `MessageSystem.post(kind, key, args, urgent)` `message_system.gd:19`: mesajı ya dış kutuya ya hemen kutuya koyar · `summary_system.gd`, `rnd_system.gd`, `sales_rep_system.gd`, `support_system.gd`, `game_state.gd:954`.
- `MessageSystem.release()` `:28`: vakti gelen dış kutuyu teslim eder · `MailClock.hourly_tick` `mail_clock.gd:69`.
- `MailClock.arrival(key, urgent, spread)` `mail_clock.gd:55`: geliş saatini çeker · `message_system.gd:20`, `events/core/engine.gd`, `events/present/papers.gd`, `sprint_system.gd`.
- `MailClock.delivered(at)` `:43`: gösteren okuyucuların sorusu · `events/core/queue.gd`, `history.gd`, `inbox.gd`, `news_ticker.gd`.
- `MailClock.reach(id)` `:105`: oyuncu hatırlatıcıya vaktinden önce uzanır · `tabs/sales_tab.gd`.

Rakip, haber, Piyasa:
- `RivalRegistry.get_market_snapshot(sub_type_id)` `rival_registry.gd:127`: durumsuz pay tablosu · `finance_ozet_view.gd` (pazar payı kartı), ürün detayı, `news_feed_system.gd:154`.
- `RivalRegistry.get_player_share_pct()` `:161` ve `format_share()` `:165`: seam `rival.player_share_pct` (`seams_world.gd:76`), haber `fmt: share`.
- `NewsFeedSystem.on_headline_added(source, line)` `news_feed_system.gd:172`: "biz" tamponu · `EventBus.headline_added` bağı `time_manager.gd:85`.
- `NewsFeedSystem.get_stream()/get_lines_for_day()/read()/line_text()` `:197/:205/:240/:215`: şeridin okuma sözleşmesi · `ui/components/news_ticker.gd`, `events/present/ticker.gd`.
- `NewsFeedSystem.outlet_key()` `:424`: yayın adı anahtarı · `sprint_bridges.gd:89`, `news_ticker.gd`.
- `MarketCatalog.companies()/value()/listed()/sector_slots()` `market_catalog.gd:47/:84/:110/:78`: Piyasa okuması · `piyasa_tab.gd`, `rival_catalog.gd:build_all`, `news_feed_system.gd:395`.

## Sinyaller

Hepsi `EventBus`te (`autoload/event_bus.gd`); satır numarası tanım satırı.
- `phase_gate_reached` `event_bus.gd:243`: yayan `phase_gate_system.gd:85` · `finance_ozet_view.gd:69`; olay motoru sinyal tablosu `events/core/signals.gd:36`.
- `sheet_granted` `event_bus.gd:264`: yayan `vc_pitch_system.gd:417`, `:872` · `hunt_tab.gd:46`, `finance_ozet_view.gd:75`, `inbox.gd:159`, `events/core/signals.gd:33`.
- `sheet_expired` `event_bus.gd:265`: yayan `vc_pitch_system.gd:644` · `hunt_tab.gd:46`, `finance_ozet_view.gd`, `inbox.gd:159`.
- `sheet_walked` `event_bus.gd:270`: yayan `vc_pitch_system.gd:628` · `hunt_tab.gd:48`, `finance_ozet_view.gd:77`, `inbox.gd:160`.
- `seed_sheet_granted` `event_bus.gd:275`: yayan `vc_pitch_system.gd:405` · `hunt_tab.gd:49`, `events/core/signals.gd:34`.
- `callback_ready` `event_bus.gd:266`: yayan `vc_pitch_system.gd:889` · `hunt_tab.gd:46`.
- `meeting_day` `event_bus.gd:267`: yayan `vc_pitch_system.gd:903` · `hunt_tab.gd:47`, `events/core/signals.gd:35`.
- `offer_countdown_changed` `event_bus.gd:268`: yayan `vc_pitch_system.gd:914` · `ui/components/top_bar.gd:117`.
- `meeting_scene_requested` `event_bus.gd:261`: yayan `vc_pitch_system.gd:104` · `main/main.gd:2061`, `:4268`, `:4467` (VcMeetingAdapter ve MeetingPanel kurulumu).
- `pitch_finished` `event_bus.gd:203`: yayan `vc_pitch_system.gd:125`, `:387` (ve `sales_meeting_system.gd:120`) · `hunt_tab.gd:48`, `sales_tab.gd:76`.
- `term_table_requested` `event_bus.gd:269`: yayan `events/core/effects.gd:568`, `:587`, `hunt_tab.gd:521`, `game_shell.gd:163` · `main.gd:4702`.
- `mentor_advisory_changed` `event_bus.gd:231`: yayan `vc_pitch_system.gd:890` (geri arama açıldı) · `hunt_tab.gd:59`, `office_notice_stack.gd:43`, `game_state.gd:333`.
- `run_ended` `event_bus.gd:245`: yayan `endings_system.gd:484` · `main.gd:4697` (`_on_run_ended` `:4993`); `milestone_reached` `event_bus.gd:248`: yayan `endings_system.gd:448` · `main.gd:4698`.
- `shutter_changed` `event_bus.gd:250`: yayan `game_state.gd:412` (`set_shutter_weeks_left`) · `top_bar.gd:109`, `finance_ozet_view.gd:80`, `finance_tab.gd:51`.
- `equity_changed` `event_bus.gd:18`: yayan `game_state.gd:615`, `:626` (tur kayıtları) · `finance_ozet_view.gd:65`.
- `cash_changed` `event_bus.gd:7`, `burn_changed` `:9`, `runway_recalculated` `:15`: `GameState.set_cash/set_daily_burn` (`game_state.gd:340`, `:351`) yayar · TopBar, Finans.
- `month_ended` `event_bus.gd:253`: yayan `summary_system.gd:126` · `save_manager.gd:62`, `top_bar.gd:112`, `finance_ozet_view.gd:68`.
- `messages_changed` `event_bus.gd:129`: yayan `message_system.gd:55`, `:69`, `:76`, `events/core/history.gd:81` · gelen kutusu arayüzü (`inbox.gd`, `events_tab.gd`).
- `summary_ready` `event_bus.gd:256` ve `product_note_issued` `:179`: yayan `message_system.gd:58`, `:60` (teslimde) · `main.gd:4699`, `:4466`.
- `desk_changed` `event_bus.gd:125`: yayan `mail_clock.gd:72`, `:108`, `events/present/papers.gd` · `top_bar.gd:116`, `left_tabs.gd:114`, `product_tab.gd:114`.
- `news_stream_changed` `event_bus.gd:94`: yayan `news_feed_system.gd:169` · `news_ticker.gd:77`.
- `headline_added` `event_bus.gd:236`: yayan `hr_system.gd:100`, `sales_ledger.gd:280`, `sprint_bridges.gd:117`, `events/present/ticker.gd:25` · `news_ticker.gd:72`, `NewsFeedSystem.on_headline_added`.
- `ticker_live_line` `event_bus.gd:239`: yayan `news_feed_system.gd:405` (halka arz), `summary_system.gd:88`, `:92`, `sprint_bridges.gd:89` · `news_ticker.gd:73`.
- `rival_status_changed` `event_bus.gd:194` / `rival_advanced` `:195`: yayan `rival_registry.gd:84`, `:87` · yalnız `finance_ozet_view.gd:78-79` (liste biçimli bağ; KALITE.md "connect yok" der, yanlış alarm).

## Durum ve veri

GameState alanları (`autoload/game_state.gd`):
- Kasa: `cash` `:30`, `mrr` `:31`, `daily_burn` `:32`, `transactions` `:152` (üst sınır `TRANSACTIONS_CAP` 50 `:151`), `marketing_push` `:155`, `cash_history`, `month_ledger`, `month_history`.
- Faz ve son: `phase` `:37`, `phase_gate_ready` `:134`, `pending_next_phase` `:135`, `run_active` `:132`, `ending_id` `:133`, `series_a_closed` `:136`, `shutter_weeks_left` `:137`.
- Son sayaçları: `vc_rejections` `:138`, `pivot_used` `:139`, `active_scandal` `:140`, `unmanaged_major_scandal` `:141`, `brand_low_since_day` `:142`, `faced_series_a(_by)` `:272`, `acq_road_over_day` `:274`,
  `bootstrap_milestone_day` `:277`.
- Çek ve turlar: `run_angel_amount` `:239`, `run_angel_equity_pct` `:240`, `run_seed_amount` `:263`, `run_seed_equity_pct` `:264`, `seed_post_money_m` `:268`; `record_angel_round` `:612`, `record_seed_round` `:621`.
- Seed: `seed_door_open_day` `:257`, `seed_pitch_used` `:258`, `seed_sheet` `:259` (`active_sheets`te değil), `seed_lead` `:260`, `seed_closed_day` `:261`.
- Series A: `vc_states` `:245` (fon başına `status`, `callback`, `pending_sheet`, `meeting_count`, `move_penalty`, `reentry_bonus`, `sheet_conviction`), `active_sheets` `:246`, `pending_meeting` `:247`, `run_pitches` `:248`.
- Değerleme ve imza: `run_valuation_m` `:231`, `run_equity_pct` `:232`, `run_investment_amount` `:230`; `get_valuation_m()` `:635`, `mark_faced_series_a()` `:642`.
- Haber ve posta: `news_feed` `:293` (`stream`, `counts`, `biz_buffer`, `recent_rivals`, `recent_piyasa`), `messages` `:318`, `mail_outbox` `:320`, `desk_arrivals` `:322`, `mentor_line_at` `:314`.
- Piyasa: `market_catalog_version` `:296`, `market_shocks` `:297`, `market_ownership` `:298`. Katalogun kendisi kaydedilmez.
- `FinanceSystem.burn_breakdown` statik değişkendir (`finance_system.gd:23`), GameState'te değil; kayda `save_manager.gd:381` bloğuyla girer.
- Rakipler: `RivalRegistry._rivals` kayda `save_codec.gd:266` (`["rivals", Rival, RivalRegistry]`) ile girer, yüklemede `insert_raw` (`rival_registry.gd:37`) katalog tohumunun üstüne biner.

Sabitler:
- Finans: `BURN_IDS` `finance_system.gd:27`, `ONE_TIME_LABELS` `:31`, `MARKETING_*` `:63-68`, `RUNWAY_ALERT_MONTHS` `[3, 1]` `:73`, `RUNWAY_ALERT_REARM_MONTHS` `:74`.
- Çek: `AngelRoundSystem.MRR_THRESHOLD` 2500, `CASH_AMOUNT` 25_000, `EQUITY_PCT` 4 (`angel_round_system.gd:27-29`), bayrak `angel_seed_accepted_day` `:31`.
- Kapılar: `PhaseGateSystem.GATES` `phase_gate_system.gd:38` (1→2: ürün yayında, ilk müşteri, MRR>0; 2→3: `finance.mrr >= SalesSystem.TRACTION_MRR_TARGET`), `APPROACH_PCTS` `:31`, `GROWTH_MIN_PCT` `:25`.
- Görüşme: `PitchConstants` `pitch_constants.gd` (`ILIK_MIN` 40, `WON_MIN` 70 `:10-11`, `CONV_*` `:18-32`, `MEETING_LEAD_WEEKS` `:71`, `SHEET_VALIDITY_WEEKS` 3 `:93`, `MAX_SHEETS` 2 `:94`, `CALLBACK_*` `:110-115`,
  `ARR_MULTIPLE` `:165`, `SERIES_A_DIL_*` `:171-174`, `REJECT_*_COST` `:179-180`).
- Bitişler: `EndingsSystem` (`SHUTTER_WEEKS` 4 `:25`, `BRAND_COLLAPSE_*` `:28-29`, `CASCADE_TABLES` 3 `:30`, `PIVOT_MRR_MIN` `:31`, `SOFT_CAP_WEEK` 104 `:38`, `PROFIT_*` `:43-45`, `ACQ_*` `:51-65`, `ENDINGS` `:71`).
- Teslim saati: `MailClock.SPREAD_HOURS` 4, `SHORT_LIVED_SPREAD_HOURS` 1 (`mail_clock.gd:18-20`); `MessageSystem.CAPACITY` 50 (`message_system.gd:14`).
- Haber: `TARGET_*` ve `BIZ_HARD_CAP` `news_feed_system.gd:35-39`, `STREAM_CAP` 30 `:42`, `BIZ_BUFFER_CAP` 10 `:43`, `RIVAL_BIG_MOVE_PCT` `:64`, `PIYASA_MOVE_PCT` `:70`, `SEKTOR_POOL` `:81`.
- Rakip payı: `TIER_ASYMPTOTE` `rival_registry.gd:16`, `SHARE_*` `:114-124`, `RivalCatalog.MARKET_TOTAL_MRR` 1_500_000 `rival_catalog.gd:144`.
- Piyasa: `COMPANIES_PATH`, `PEOPLE_PATH` `market_catalog.gd:18-19`; veri 56 şirket, 46 kişi, meta `version` 1.
- Fonlar: `InvestorRegistry.INVESTORS` `investor_registry.gd:18` (anchor, nexus, bosphorus, meridian ve kilitli `locked_tier2`).

## Metin anahtarları

`localization/strings.csv`; aile önekleri ve okuyan dosyalar (DIZIN.md "Metin anahtarı aileleri"):
- `FIN_BURN_*`, `FIN_ONETIME_*`, `ANGEL_TX_*`, `SEED_TX_*`: `finance_system.gd` (kalem ve işlem adları, `ONE_TIME_LABELS` değerleri).
- `FIN_*` geri kalanı (`FIN_CAP_*`, `FIN_GOAL_*`, `FIN_PROFIT_*`, `FIN_MARKET_*`): `finance_ozet_view.gd`, `finance_tab.gd`, `top_bar.gd`.
- `CHEQUE_STEP_*`, `CHEQUE_TITLE`, `GOAL_STEP_*`, `SEED_SECTION_TITLE`: `cheque_read.gd`; `ANGEL_CHOICE_*`, `ANGEL_EVENT_*`, `ANGEL_NUDGE_*`: kartlar `frank_cheque.json`, `hire_nudge.json`;
  `ANGEL_MONTH_HIGHLIGHT`: `angel_round_system.gd:52`.
- `GATE_*` (`GATE_OPENED` `phase_gate_system.gd:87`), `FRANK_DOOR_*`, `FRANK_APPROACH_*`, `FRANK_OFFICE_*`: `data/events/cards/funding/*.json`.
- `VC_*` (`VC_B1..B4`, `VC_Q_*`, `VC_WHY_*`, `VC_FRANK_*`, `VC_REACT_*`, `VC_RES_*`, `VC_APPROACH_*`), `SEED_B*`, `SEED_Q_*`, `SEED_RES_*`: `vc_pitch_system.gd`; ön ek `_k()` ile seçilir (`vc_pitch_system.gd:1320`).
- `HUNT_*`: `hunt_tab.gd` ve `vc_pitch_system.gd` (`HUNT_CB_*`, `HUNT_EST_*`); `INV_ROLE_*`, `INV_ARCH_*`, `INV_CHIP_*`: `investor_registry.gd`; `INV_APPETITE_*`: `investor_appetite_ui.gd`.
- `TERM_*`, `SEED_*` masa metinleri: `term_sheet_table_system.gd`, `term_sheet_table_scene.gd`; `PITCH_DIFF_*`: `pitch_constants.gd:183`.
- `END_*` (`END_SA_`, `END_ACQ_`, `END_BK_`, `END_BC_`, `END_VC_`, `END_BS_`, `END_RF_`, `END_STAT_`, `END_SPAN_`, `END_GENERIC_`): `endings_copy.gd`; `END_META_<ID>_TITLE/_FRANK`: `endings_system.gd:520-527`.
- `END_HL_*`: `endings_system.gd` ay vurgusu; `END_EV_*`: kartlar `acquisition_offer.json`, `shutter_warning.json`; `ENDING_*`: `ending_scene.gd` (gazete çerçevesi).
- `NEWS_RIVAL_UP_n/DOWN_n`, `NEWS_<SEKTOR_ID>` (`NEWS_S_*`, 48 anahtar, kodda dinamik kurulur), `PIYASA_LINE`, `PIYASA_NEWS_*`, `PIYASA_WHY_*`, `WORLD_OUTLET_*`: `news_feed_system.gd`.
- `PIYASA_*` geri kalanı (`PIYASA_ABOUT_*` 56 anahtar, `PIYASA_SECTOR_*`, `PIYASA_KPI_*`, `PIYASA_FILTER_*`): `piyasa_tab.gd`; `SHARE_FLOOR`: `rival_registry.gd:167`, `piyasa_tab.gd`.
- `MENTOR_INTRO_*` (`intro` mesajı) ve diğer mesaj anahtarları gönderenlerde; gelen kutusu kabuğu `INBOX_*`, `MAIL_*` (`mail_pane.gd`, `events_tab.gd`).
- Kural: `static func` içinde `tr()` derlenir ama çalışırken ölür; bu dosyalar `TranslationServer.translate` kullanır (`vc_pitch_system.gd:1326`, `finance_system.gd:237`).

## Testler

Tek koşturucu `bash tools/smoke_run.sh <vaka>`; vaka listesi `scripts/debug/endgame_smoke.gd` `match case_name:` tablosudur (dosya ~25.950 satır). `export GODOT=...` gerekir; `--all` yalnız push öncesi.
- Finans: `month_summary`, `month_history_close_and_cap`, `burn_refresh_same_tick`, `burn_lines_visible`, `runway_net_status`, `runway_weeks_seam`, `runway_days_and_negative_cash`, `gross_runway_months`,
  `add_cash_writes_ledger`, `marketing_push_burns_and_ends`, `run_ledger`.
- Çek ve turlar: `cheque_read_steps`, `angel_fires_at_crossing`, `angel_never_pre_ship`, `angel_not_below_threshold`, `angel_accept_is_atomic`, `angel_locked_choice_inert`, `angel_one_shot_falsified`,
  `angel_survives_series_a`, `angel_hire_nudge`, `seed_*`, `valuation_*`.
- Kapılar ve görüşme: `gate1_b2b`, `gate1_b2c`, `gate2`, `gate_decline_reminder`, `gate_scope_and_halves`, `traction_gate_one_option`, `series_a_gate_mrr_only`, `series_a_signal_states`, `series_a_sheet_derives_from_arr`,
  `frank_approach_lines_once`.
- VC masası: `callback_contract`, `callback_churn_window`, `sheet_expiry_no_rejection`, `third_sheet_delayed`, `cascade_defer_with_sheet`, `walk_not_a_rejection`, `table_sign_closes_series_a`, `table_walk_not_a_rejection`,
  `investor_strain_fades_from_the_room`, `vc_weakest_area`, `vc_call_postpones_once`.
- Sonlar: `shutter_recovery`, `shutter_warning_every_episode`, `bankruptcy`, `cascade`, `brand_collapse`, `profit_condition_fires`, `profit_predicate_margin_scale_red`, `soft_cap_*` (adlardaki 730 eski gün sayımıdır),
  `buyout_*`, `pivot_accept`, `pivot_decline`.
- Sonlar (devam): `bootstrap_milestone_keeps_the_run`, `bootstrap_needs_the_faced_flag`, `ending_modes_by_build`, `ending_paper_modes_on_screen`, `milestone_clock_hold`, `milestone_paper_waits_for_card`, `event_i3_no_silent_loss`.
- Mesaj ve saat: `messages_save_round_trip`, `mail_pending_survives_save`, `inbox_no_night_stamp`; haber ve rakip: `news_feed_weights_and_no_repeat`, `news_piyasa_reason_lines`, `hotfix_ticker_routine_vs_news`,
  `market_share_tracks_mrr`, `rival_composite_table`.
- Piyasa: `market_catalog_lint`, `market_value_deterministic`, `market_listed_week_gating`, `market_price_band`, `market_value_texture`, `market_year_end_follows_anchors`, `market_save_roundtrip`.
- Koşu probu: `--run-log=full_run:100:sim` (satırlar `PROBE STATE/GATE/SIGNAL/MONTH/MARKET/END`); VC preset'leri `full_run_vc_*` `VC_BOOK/VC_MEET/VC_PUSH/VC_TABLE_*` basar; kapı `bash tools/run_gate.sh`.
- Kart tarafı: `--why-fire=funding.frank_cheque` (kapı kartı neden gelmiyor), `--event-lint`; ekran kapısı `--tab-shot=finance|piyasa[:...]`, `--finance-shot=<tür>`, `--vc-shot=<tür>[:shell]`, `--ending-shot=<anahtar>`.
- Debug tuşları `main/game_shell.gd:194`: F1 kapıyı aç, F2 faz atla, F3 Series A kapat, F5 kepenk (kasa -1000), F6 marka çöküşü ön şartı, F7 kaskad ön şartı, F8 kârlılık fikstürü.

## Dikkat

- Yazma sırası yük taşır: `record_transaction` önce, `set_cash` en son (`finance_system.gd:182-186`); çek için hisse tablosu, işlem satırı, kasa sırası (`angel_round_system.gd:49-51`). Senkron sinyaller yarım defter okur.
- Gider kimliği `FinanceSystem.ONE_TIME_LABELS`a kayıtlı olmalı; yoksa ekranda ham id çıkar ve kartın `add_cash` etiketini `EvLint` reddeder (`finance_system.gd:31`).
- İşlem günlüğü yalnız gerçekten kasayı oynatan hareketleri tutar; imza satırı yazılmaz (`finance_system.gd:252`). Kasa eksiye düşebilir (satın alma kapısı yok).
- `FinanceSystem.burn_breakdown` statiktir ve `reset()`le yeniden kurulur;
  `from_dict` kalemleri başlangıç şekline giydirir ve `daily_burn`ü yeniden hesaplar (`finance_system.gd:93-106`). Yeni gider kalemi hem `STARTING_BURN_BREAKDOWN` hem `BURN_IDS` hem `FIN_BURN_*` ister.
- `cheque_read.gd`ye `class_name` eklenmez; paylaşılan klasörde yeni `class_name` başka oturumların headless koşusunu bozuyor (dosya başlığı). Okuyanlar `preload` eder.
- Faz kapısı mandaldır: bir kez açılınca koşul bir daha okunmaz, MRR düşse de kapı kapanmaz (`phase_gate_system.gd:71`). Kapı kartları `critical` etiketlidir. `funding.frank_door_open` bilerek kuyruktan çekilmez (`:108`).
- Kapı eşiği tek evde: `SalesSystem.TRACTION_MRR_TARGET`. Çek eşiği `AngelRoundSystem.MRR_THRESHOLD` ayrı tutulur; paylaşılırsa çek ve Series A kapısı aynı gün açılır (`angel_round_system.gd:24`).
- Dağıtım sırası kırılgan: Finans, kapı, olay, haber, VC, Endings, Summary. `VCPitchSystem.daily_tick` Endings'ten önce olmalı, yoksa kaskad ertelemesi bayat `active_sheets` okur (`time_manager.gd:422-426`).
- `EndingsSystem.trigger_ending` telegraph parametresinin varsayılanı YOK (I3: telgrafsız kayıp yok). Kayıp bitişi telegraph'ı geçmişte atılmamışsa `push_error` basar, engellemez (`endings_system.gd:489`).
- `brand_collapse` yalnız debug ile ulaşılır: `active_scandal`ı F6 dışında yazan yok (`game_state.gd:140`, `game_shell.gd:215`). `unmanaged_major_scandal` da rezerve; `vc_pitch_system.gd:180` ve `:245` okur.
- Bitiş kümesi 7 kimlik (`ENDINGS` `endings_system.gd:71`); EA/full'de yalnız kârlı bootstrap kilometre taşıdır (`ending_mode` `:422`). Yeni bir bitiş `END_META_*`, `EndingsCopy.build` kolu, `ENDINGS` ve telegraph ister.
- `soft_cap` 104 hafta (`SOFT_CAP_WEEK`); smoke adı `soft_cap_ends_run_at_730` eski gün sayımını taşır. Kilometre taşı alınmış koşuda tavan uygulanmaz (`endings_system.gd:240`).
- `VCPitchSystem` görüşme durumu statik ve kayda girmez; `SaveManager.can_save` görüşme sürerken kaydı reddeder (`save_manager.gd:93`). `reset()` sıfırlar (`vc_pitch_system.gd:1301`).
- `_vc(vc_id)` satır YARATIR; salt okunan yollar (`series_a_road_closed`, `is_last_answer_moment`, `meeting_blocked_reason`) `vc_states.get` kullanır, kart koşulu hiçbir şey yazmamalı.
- Ret sayısı yalnız fonun çıkışında ve `_reject`te artar (`WALK_REASON_FUND`); oyuncunun kendi geri çekilişi (`"declined"`) ret değildir ve kaskada girmez (`vc_pitch_system.gd:608-632`).
- Seed teklifi `seed_sheet`te yaşar, `active_sheets`e girmez; `run_pitches` ve `run_sheets_won` yalnız Series A'yı sayar (`vc_pitch_system.gd:381-405`).
- `PitchConstants`/`SeedConstants` aynı `CONV_*` adlarını taşır; çağrıda hangi odanın olduğu açık yazılır (KALITE.md çift sabit listesi bu yüzden çıkar). `CALLBACK_*` sabitleri "onay bekliyor" (`pitch_constants.gd:113`);
  tasarım sabiti değişimi onay ister.
- Yatırımcı `display_name` CSV'den değil sabit tablodan gelir (özel ad). `InvestorRegistry` autoload ama veri const; `get_investor` adı `Object.get` yüzünden seçilmiş.
- `MailClock.instant` statik ve sıfırlanmaz; yalnız harness kurar. Saati gösteren okuyucu `delivered` sorar, varlığı soran sormaz (`mail_clock.gd:9-13`). `MessageSystem.post` dış kutudaysa `""` döner.
- Mesaj sinyalleri teslimde atılır, yazımda değil (`message_system.gd:56-60`); `summary_ready` önce yayılırsa özet erken görünür.
- Haber: RNG yok, tüm seçim `hash()` aritmetiği; biz tamponu dolunca EN YENİ satır düşer (`news_feed_system.gd:172`). Rakip eşiği ölçülmüş banda oturur (`RIVAL_BIG_MOVE_PCT` yorumu); dev (momentum 0) hiç haber olmaz.
- Rakip kimlikleri (`rv_<alt tür>_<i>`, `ma_*`) pay dokusunun hash'i ve kayıtlı cooldown için sabittir; `NAMES`, `TEMPLATE`, `SHARE_SEED` indeks-hizalıdır, sıra değişmez (`rival_catalog.gd:90-95`).
- `RivalRegistry.reset()` boşaltmaz, katalogdan yeniden tohumlar; `get_market_snapshot` durumsuzdur ve canlı kalite eksenlerini okumaz (`rival_registry.gd:100-112`). `_share_at` içindeki wobble pratikte doku üretmiyor (kendi ölçüm notu).
- `RivalRegistry.get_by_type()` `rival_registry.gd:61` hiçbir yerden çağrılmaz (ölü aday); `Rival.composite()` üretimde okunmaz, yalnız smoke.
- `MarketCatalog` değeri `(run_seed, katalog, market_shocks, hafta)` üzerinden saf hesaplanır; fiyat geçmişi saklanmaz. Oyuncu eylemi çapaları kıpırdatmaz. Katalog sürümü kayda yazılır (`market_catalog_version`).
- Yerel kural: oyuncuya görünen metinde tire yok; bitiş gazetesi kuralları `endings_copy.gd:16-24`.

## Bir değişiklik yaparken

- Yeni gider kalemi: `STARTING_BURN_BREAKDOWN`, `BURN_IDS`, `FIN_BURN_<ID>` (CSV, TR ve EN), yazan sistem, `finance_ozet_view.gd` gider listesi; `burn_*` ve `runway_*` vakalarını koş. Kaydı etkiler (`from_dict` anahtar anahtar giydirir).
- Yeni tek seferlik gider/gelir etiketi: `ONE_TIME_LABELS` + CSV anahtarı; olay kartından gelecekse `events/tools/lint.gd` (`EvLint`) izin listesi ve `EvChips` etiketi.
- Faz kapısı ya da çek eşiğini değiştirirsen: `PhaseGateSystem.GATES` / `AngelRoundSystem.MRR_THRESHOLD`, `ChequeRead.steps`, `funding.*` kart koşulları, `MailClock.reminders` (`GATES` okur), `gate1_*`, `gate2`, `angel_*`,
  `cheque_read_steps` ve rapora "onay bekliyor" yaz.
- VC odası ya da masa sayısı: `PitchConstants` / `SeedConstants` iki odayı birlikte düşün; `initial_conviction`, `_derive_series_a_terms`, `InvestorRegistry.INVESTORS`, `hunt_tab.gd`, `term_sheet_table_system.gd`,
  `VC_*` ve `HUNT_*` metinleri, `callback_*`, `table_*` ve `seed_*` vakaları.
- Yeni bitiş ya da kilometre taşı: `EndingsSystem.ENDINGS`, tarama kolu `daily_tick`, `END_META_*` ve `END_*` CSV, `EndingsCopy.build` kolu, telegraph kartı (kayıp ise), `ending_scene.gd`, `ending_modes_by_build`,
  `event_i3_no_silent_loss`, `--ending-shot`.
- Build kapsamı (`SHIPPED_SCOPES_BY_BUILD`): kart `version_scope` süzgeci `EvTuning.SHIPPED_SCOPES`, `export_presets.cfg` özellik etiketleri, smoke/probe sabitlemesi (`build_scope_override`).
- Mesaj türü ekleme: `MessageSystem.post` çağrısı, `MailClock` geliş davranışı (acil mi), gelen kutusu arayüzü (`mail_pane.gd`), `messages_*` ve `mail_pending_survives_save`; teslimde atılacak sinyal `_deliver` `match`ine.
- Şerit kaynağı ya da kota: `NewsFeedSystem` sabitleri (toplam 1,0), `GameState.news_feed` şekli (`_ensure_state` eski kaydı doldurur), `NEWS_*` / `PIYASA_*` CSV, `news_feed_weights_and_no_repeat`, `news_piyasa_reason_lines`.
- Yeni alt tür ya da rakip: `RivalCatalog.NAMES`, `data/product/rivals.json` (aynı sıra), `MarketCatalog.sector_slots` (`data/market/companies.json` meta), `rival_composite_table`, `market_catalog_lint`.

## HARITA'da bayat

- `docs/HARITA.md:299` (Sonlar): "Projede henüz export ön ayarı yok: `ea` etiketi olmayan bir EA export'u demo gibi davranır". `export_presets.cfg` üç preset taşır (`custom_features` "", "ea", "full");
  HARITA'nın kendi 405. satırı da öyle der.
