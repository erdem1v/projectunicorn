# Ürün, sprint ve Ar-Ge

Dizin git sha: f3113fa4 (DIZIN.md başlığı, 2026-10-22). Ağaç o sırada kirliydi: sprint_*.gd, sprint.json, save_manager.gd yazılıyordu; satırlar `Dikkat` 1'e göre oku.

Ne yapar: ürün tek bir ürün satırıdır: alt-tür başına 9 hat × 3 kademe (JSON), 2 haftalık sprint motoru kartları haftalık atar, kapanışta sürüm çıkarır. Hata deposu, kalite, sunucu, acil durum ve Ar-Ge bunu besler.
Ar-Ge 19 düğümlü ağaçtır; tamamlanan düğüm hat kapılarını ve katsayıları açar. LineGates ve ModuleLocks "bu kademe/sayfa şimdi açık mı" sorusunun tek cevap yeridir.

## Dosyalar

- `scripts/systems/sprint_system.gd` (1734): sprint motoru: tür seçimi, plan eylemleri, haftalık atama/ilerleme, kapanış ve sürüm, karar kâğıdı, söz olayı, plan tutuşu; `GameState.product`'ın tek yazarı
- `scripts/systems/sprint_catalog.gd` (929): salt okur katalog: alanlar, aday kartlar, kilit gerekçesi, etki/öngörü satırları, lider ve PM planı, rakipler, `cfg("a.b")` ile sprint.json
- `scripts/systems/sprint_timeline.gd` (326): sprint ekranının zaman ekseni: motorun oynatma günlüğünden aşama yerleşimi, bekleme, kurucunun görüşme taraması, kişi parçaları, kapasite satırı kuralı; yalnız okur
- `scripts/systems/sprint_bridges.gd` (346): B2B talepleri, rakip çıkışları, basın satırı, MVP/ücretli plan ekonomisi, sürüm notu cümleleri, teşekkür notu ve B2C yorumları
- `scripts/systems/product_state.gd` (341): `mvp_*` bayraklarının evi: kimlik, hat kademeleri, açık hata deposu, sürüm yaşı/ilgi, sunucu sağlayıcı ve kapasite yazma yolu
- `scripts/systems/product_system.gd` (53): koşu sınırı (reset/to_dict/from_dict), haftalık açık hata görüntüsü, saat damgası okumaları
- `scripts/systems/product_read.gd` (172): olay motoruna açılan salt okuma yüzeyi; B2C taban merdiveni; `emit_edges` kenar sinyalleri
- `scripts/systems/product_lines.gd` (432): hat/kademe tablosunu `data/product/lines/*.json`'dan yükler, doğrular; Ar-Ge katsayıları (lisans, tasarım eforu, AI ağırlığı); gizli hat kaydı
- `scripts/systems/product_quality.gd` (394): ürünün tek kalitesi: alan seviyesi, beklenti, sözcük, uyum U (0-100), satışçı kapanış ihtimali, hesap uyumu
- `scripts/systems/product_catalog.gd` (241): alt-tür tablosu, demo tür ekranı (hangi tür oynanır/kilitli), eski düz özellik havuzları
- `scripts/systems/line_gates.gd` (130): kademe gereksinim doğrulayıcı (Ar-Ge düğümü, kişi ★, şirket toplamı ★); kart, tooltip ve satış aynı fonksiyonu okur
- `scripts/systems/module_locks.gd` (35): sekme/modül sayfası bu yapıda açık mı; `UiTokens.TABS` satırındaki `lock` adı kilitler
- `scripts/systems/incident_system.gd` (664): gecenin acil durumları: zar, tür, damga, kart isteği, saat tutuşu, cevabın bedeli (`plan`) ve uygulaması (`resolve`)
- `scripts/systems/infra_system.gd` (249): sunucu sağlayıcı kademesi, kapasite birimi, yük yüzdesi, otomatik ayar, fatura; durumu `ProductState`'te tutar
- `scripts/systems/rnd_system.gd` (814): Ar-Ge motoru: başlat/duraklat/vazgeç, atananlar, birikim, donma, tamamlama, gizli hat, aylık ürün notu, kayıt
- `scripts/systems/research_tree.gd` (427): `rnd_tree.json` yükleyici ve doğrulayıcı: efor/nakit/yıldız bantları, çapraz koşul, 8 katsayı, gizli hat profilleri
- `scripts/systems/research_seam.gd` (100): Ürün tarafının Ar-Ge'ye açılan kapısı: 19 düğüm kimliği tablosu, `completed()`, yerleşim ve aile
- `data/product/sprint.json` (140): tüm sprint/acil durum/kâğıt/rapor sayıları ve alan tanımları ([WORKING] değerler)
- `data/product/rivals.json` (86): alt-tür başına 3 rakip ve çıkış takvimi
- `data/product/lines/{erp,note_tool,video_clip,shared}.json` (169, 158, 160, 128): alt-tür hatları ve 4 paylaşılan platform hattı
- `data/techtree/rnd_tree.json` (57): düğüm başına efor, nakit, alan, yıldız, ebeveyn, çapraz koşul, etki; 4 gizli hat
- Yakın, kapsam dışı (yalnız yol): `scripts/tabs/product_tab.gd` (321), `scripts/tabs/product/*.gd` (8 dosya, en büyüğü `product_model.gd` 644), `scripts/tabs/rnd_tab.gd` (273), `scripts/tabs/rnd/*.gd` (5 dosya)
- Yakın: `scripts/ui/components/{research_bar,research_bar_model,build_bar,build_bar_model,build_hud_panel}.gd`, `scripts/events/seams/{seams_product,seams_incident}.gd`, `scripts/systems/support_system.gd` (424)
- Yakın: `scripts/debug/product_fixtures.gd` (699, `--product-shot` fikstürü), `scripts/debug/sprint_probe.gd` (425, `--sprint-probe`); çalışma günlüğü tohumları `scripts/main/main.gd` `_seed_product_live` (3839)

## Giriş noktaları

- `TimeManager._dispatch_daily_tick()` `scripts/autoload/time_manager.gd:383`: sıra Product(391) → Sprint(394) → Support(395) → Infra(396) → ProductRead.emit_edges(397) → RnD(399) → … → IncidentSystem(419)
- `TimeManager._dispatch_hourly_tick()` `time_manager.gd:437`: `InfraSystem.auto_adjust()`(445) sonra `IncidentSystem.hourly_tick()`(449); `SupportSystem.hourly_tick` hata düşürür
- `SprintSystem.daily_tick()` `scripts/systems/sprint_system.gd:27`: her günlük tik = bir oyun haftası; moda göre `_end_week` (active), `_auto_start` (plan/release) · TimeManager
- `SprintSystem.choose_type()` `sprint_system.gd:51`: tür/pazar/ad yazar, Sprint 1'i planlamada açar · `scripts/tabs/product_tab.gd:102`, `main.gd:504`
- `SprintSystem.new_state()` `sprint_system.gd:74`: `GameState.product` ilk durumu · `choose_type`, `scripts/autoload/save_manager.gd:888` (v14→v15 göçü)
- `SprintSystem.add()/send_next()/remove()` `sprint_system.gd:90`/`:98`/`:108`: "+", "→", kartı adaya döndür · `ProductTab._act` `product_tab.gd:277`
- `SprintSystem.start()` `sprint_system.gd:127` (`_begin` :139): sprinti başlatır, lisansı keser, plan tutuşunu kaldırır · `product_tab.gd:282`
- `SprintSystem.plan_next()` `sprint_system.gd:172`: sürüm notundan sonraki sprinte geçer, çeyrek döner · `product_tab.gd:285`, `_auto_start`
- `SprintSystem.publish()` `sprint_system.gd:290`: MVP kapısında ürünü CANLI v1.0 yapar · `product_tab.gd:286`
- `SprintSystem.skip()/set_delegate()/apply_lead()` `sprint_system.gd:284`/`:293`/`:337`: boş geçir, PM'e devret (devirde sprint liderin önerisiyle başlar), liderin önerisini uygula (bu sprint ve sonraki sütun) · `product_tab.gd`
- `SprintSystem._auto_start()` `sprint_system.gd:1547`: oyuncuyu beklemeyen sprinti başlatır; `apply_lead` bu sprinti ve sonraki sütunu doldurur, kart yoksa boş sprint · `daily_tick`, `plan_next` (devirde)
- `SprintSystem.approve()/approve_all()/edit()/pick_goal()` `sprint_system.gd:521`/`:528`/`:537`/`:544`: çeyrek PM planı ve hedef alan · `product_tab.gd:289-292`
- `SprintSystem.fix_first()/put_first()` `sprint_system.gd:204`/`:217`: hattın düzeltme kartı sprintin başına · olay fiili `sprint_fix_first` `scripts/events/core/effects.gd:497`
- `SprintSystem.decision_effort/progress/carry/trim/first()` `sprint_system.gd:331`-`:446`: karar kâğıdının kart fiilleri · `effects.gd:476-514` (`sprint_card_*`)
- `SprintSystem.cut_test()/set_hours_mult()` `sprint_system.gd:921`/`:501`: testi kısalt, fazla mesai · `effects.gd:485`, `:489` (`sprint_card_test`, `sprint_hours`)
- `SprintSystem._request_decision()` `sprint_system.gd:1191`: sprint başına tek zar, karar kâğıdı isteği · `_staff_week(true)` ← `_end_week` (:1064)
- `SprintSystem._ask_promise()` `sprint_system.gd:965`: son haftada yetişmeyen söz için `product.promise_due` · `_begin`, `_end_week`
- `SprintSystem._close()` `sprint_system.gd:1395`: kartları çıkarır, hata/kademe/sürüm kaydı yazar, `sprint_closed` yayar · `_end_week`
- `SprintSystem.sync_plan_hold()` `sprint_system.gd:1579`: plan beklerken `TimeManager.hold_clock("sprint_plan")` · `scripts/main/game_shell.gd:28`, `_changed`
- `SprintSystem.record_interrupt()` `sprint_system.gd:552`: sprintin kesinti kaydı (incident|promise|paper) · `IncidentSystem._ask` `incident_system.gd:272`
- `SprintSystem.timeline(extra)` `sprint_system.gd:836`: planlamada plan (artı `extra` aday) ya da koşan sprintin kalanı tek oynatmayla `SprintTimeline.build`e girer; planlamada `outcome` = `plan_outcome` biçimi · `ProductModel.live`
- `SprintSystem.prep_gains(weeks)` `sprint_system.gd:856`: sonraki sütunun kartlarının `weeks` hafta sonraki hazırlık kazancı (kopyalarda yalnız PM'lerin haftaları) · `ProductModel._next`
- `SprintSystem.away()` `sprint_system.gd:737`: ekip dışı kişiler [{id, reason}]: `training`, `leave`, `research`, kurucu `meetings` · `ProductModel._crew`
- `SprintSystem.set_founder_in_sprint()` `sprint_system.gd:299`: kurucu sprint kartı alır mı (planlamada ve sürüm notunda yazılır) · smoke `sprint_away_lists_who_cannot_work`
- `SprintTimeline.build()/done_at()/row_gaps()/capacity_rows()/row_power()` `scripts/systems/sprint_timeline.gd:39`/`:66`/`:76`/`:143`/`:162`: günlükten eksen; aşamanın `at` anına dek yaptığı iş; kart satırının bekleme ya da çubukla kapanmayan boşlukları (smoke Z3 ve `live:a4_*` `row_gaps`); ekibin kapasite satırı kuralı ve satır başına sprint puanı (sürüm notunda da) · `SprintSystem.timeline`, `ProductModel._progress`, `_next`
- `SprintSystem.capacity()/capacity_of()` `sprint_system.gd:640`/`:645`: ekibin ya da verilen `team` satırlarının sprint boyunca puanı; ekip ve satır toplamları yalnız buradan okunur (`SprintTimeline.capacity_rows`/`row_power`, smoke `sprint_timeline_matches_play_out`) · `SprintCatalog.lead_suggestion`, `ProductModel._center`
- `SprintCatalog.row_of()/due_sprint()` `sprint_catalog.gd:120`/`:317`: çalışanın kapasite satırı; kartın söz ya da talep son tarihi · `SprintTimeline`, `ProductModel._row`
- `SprintSystem.plan_outcome()/mvp_eta()/team()/payers()` `sprint_system.gd:761`/`:791`/`:692`/`:714`: plan önizlemesi, MVP tahmini, ekip, bedel ödeyenler · ProductModel, effects.gd
- `SprintCatalog.cfg()` `scripts/systems/sprint_catalog.gd:29`: sprint.json okuması (yoksa yükler) · yaklaşık her sistem; `load_data()` :23 → `main.gd:4683`
- `SprintCatalog.candidates()` `sprint_catalog.gd:194`: alanın aday kartları (feat:/req:/plan:/fix:/res:) · ProductModel, `SprintSystem`
- `SprintCatalog.lead_suggestion()/pm_plans()` `sprint_catalog.gd:526`/`:677`: lider `{this, next}` (bu sprint, sonraki sütun) ve PM planı (`_suggest` :1007); PM planı Ürün puanından bağımsız tam kart taşır · `apply_lead`, ÇEYREK
- `SprintCatalog._lead_picks()` `sprint_catalog.gd:549`: iki sütunun ortak alım döngüsü; sütunda tavan `room` = kapasite − sütunun kalanı − `SprintSystem.carried_points` `sprint_system.gd:806` · `lead_suggestion`
- `SprintCatalog.gate_reason()` `sprint_catalog.gd:290`: kilitli kademenin gerekçesi (`LineGates.unmet_parts`) · `_begin`, `product_model.gd:574`
- `SprintBridges.tick_requests()` `scripts/systems/sprint_bridges.gd:22`: B2B talep doğurur/düşürür · `SprintSystem.daily_tick` :33
- `SprintBridges.on_mvp()/on_release()` `sprint_bridges.gd:124`/`:71`: MVP'de sunucu açar; sürümde talebi karşılar · `SprintSystem._go_public` (sprint_system.gd:1505)
- `SprintBridges.thank()/pick_reviews()` `sprint_bridges.gd:189`/`:263`: sürüm teşekkür notu ve B2C yorumları · `SprintSystem._close`
- `ProductState.add_bugs()/clear_line_bugs()` `scripts/systems/product_state.gd:199`/`:207`: açık hata deposunun tek yazarları · `support_system.gd:128`, `_close`, `effects.gd:525`
- `ProductState.set_line_tier()` `product_state.gd:92`: kademe yazma (merdiveni sormaz) · `SprintSystem._close` :1430
- `ProductState.set_infra_provider()/set_infra_units()` `product_state.gd:301`/`:308`: sunucu durumu yazma, `infra_changed` yayar · `InfraSystem` tek çağıran
- `ProductSystem.daily_tick()/reset()` `scripts/systems/product_system.gd:29`/`:11`: açık hata görüntüsü; koşu sınırı · TimeManager, `save_manager.gd:347`
- `ProductRead.emit_edges()` `scripts/systems/product_read.gd:144`: bug/uyarı/taban kenar sinyalleri · `time_manager.gd:397`
- `ProductRead.step_unlockable()` `product_read.gd:78`: kademe şimdi alınabilir mi · seam `urun.*` (`seams_product.gd:8`)
- `ProductLines.ensure_loaded()/reload()` `scripts/systems/product_lines.gd:58`/`:66`: tembel yükleme/sıfırlama · her erişimci; `ProductSystem.reset`
- `ProductLines.register_runtime_line()` `product_lines.gd:366`: Ar-Ge'nin gizli hattını tabloya ekler · `RnDSystem._open_hidden_line_for` (rnd_system.gd:490)
- `ProductLines.sum_license_cost()/effort_of()/usage_weight_of()` `product_lines.gd:394`/`:341`/`:352`: Ar-Ge katsayılı lisans, efor, kullanım · `_begin`, `_close`
- `ProductQuality.fit()/close_chance()/account_fit()` `scripts/systems/product_quality.gd:261`/`:233`/`:246`: uyum U ve kapanış ihtimali · `b2b_sales_system.gd:157`, `sales_system.gd:222`
- `LineGates.evaluate()/is_unlocked()/unmet_parts()` `scripts/systems/line_gates.gd:65`/`:88`/`:95`: kademe kapısı · `product_read.gd:79`, `sprint_catalog.gd:296`, `b2b_sales_system.gd:597`
- `ModuleLocks.is_open()/ids()` `scripts/systems/module_locks.gd:21`/`:17`: sekme açık mı · `left_tabs.gd:258`, `events/core/delays.gd:108`, `seams_world.gd:148`
- `InfraSystem.daily_tick()` `scripts/systems/infra_system.gd:244`: faturayı "servers" burn kalemine yazar, hizmet edilen geçmişini tutar · `time_manager.gd:396`
- `InfraSystem.set_provider()/adjust_capacity()/auto_adjust()` `infra_system.gd:170`/`:196`/`:206`: oyuncu kararları ve otomatik ayar · `product_tab.gd:294-297`, `time_manager.gd:445`
- `IncidentSystem.daily_tick()` `scripts/systems/incident_system.gd:121`: 00:00 zarı (yalnız karar verir) · `time_manager.gd:419` (EventGate'ten sonra)
- `IncidentSystem.hourly_tick()` `incident_system.gd:219`: damgadan sonraki ilk tam saatte kartı ister (`_ask` :254) · `time_manager.gd:449`
- `IncidentSystem.plan()/resolve()` `incident_system.gd:473`/`:510`: cevabın bedeli ve uygulaması · çip, geçmiş, olay fiili `incident` `effects.gd:300`
- `IncidentSystem.force_on()` `incident_system.gd:228`: debug, o tikin zarını zorlar · `sprint_probe.gd` (`incident=<tür>@<tik>`)
- `RnDSystem.daily_tick()` `scripts/systems/rnd_system.gd:101`: birikim, donma, aylık not · `time_manager.gd:399`; ağaç v1.0'dan önce kapalı (`tree_open` rnd_system.gd:62)
- `RnDSystem.start()/set_assignees()/pause()/abandon()` `rnd_system.gd:246`/`:284`/`:314`/`:325`: Ar-Ge eylemleri · `rnd_assign_panel.gd:229-231`, `research_bar.gd:186`
- `RnDSystem.drop_assignee()` `rnd_system.gd:335`: kişi işten çekilince atamadan düşer · `character_registry.gd:253`, `:309`
- `RnDSystem.node_completed()` `rnd_system.gd:677`: düğüm bitti mi · `ResearchSeam.completed` (`research_seam.gd:64`) · Ürün, Destek, Satış, Altyapı
- `RnDSystem.to_dict()/from_dict()` `rnd_system.gd:759`/`:787`: kayıt; `from_dict` sonda `restore_hidden_lines` (:507) çağırır · `save_manager.gd:380`, `:398`
- `RnDSystem.pending_note()/mark_note_read()` `rnd_system.gd:647`/`:652`: aylık ürün notu · `ui/components/inbox.gd:199`, `main.gd:2523`
- `ResearchTree.ensure_loaded()` `scripts/systems/research_tree.gd:68`: `rnd_tree.json` yükler ve doğrular · her erişimci; hata `load_errors()` :85

## Sinyaller

- `sprint_planned`: yayan `sprint_system.gd:62`,`:194` · top_bar.gd:124
- `sprint_started`: yayan `sprint_system.gd:164` · top_bar.gd:125, office_people.gd:93
- `sprint_closed`: yayan `sprint_system.gd:1500` · `scripts/main/game_shell.gd:27`
- `card_phase_changed`, `card_done`: yayan `sprint_system.gd:1080`, `:1084` · dinleyen yok
- `card_carried_over`: yayan `sprint_system.gd:390`,`:1494` · dinleyen yok
- `card_decision_requested`: yayan `sprint_system.gd:1224` · yalnız smoke/probe
- `sprint_auto_started`: yayan `sprint_system.gd:1564` · dinleyen yok
- `product_state_changed`: yayan `sprint_system.gd:1572` (`_changed`) · product_tab.gd:111, build_bar.gd:46
- `version_shipped`: yayan `sprint_system.gd:305`,`:1497` · left_tabs.gd:132, top_bar.gd:126; olay motoru `scripts/events/core/signals.gd:30`
- `build_phase_changed("shipped")`: yayan `sprint_system.gd:304`,`:1496` · promise_registry.gd:15, left_tabs.gd:125; olay tetiği (`funding.frank_v1`)
- `line_upgraded`, `line_completed`, `delighter_shipped`: yayan `sprint_system.gd:1431`, `:1433`, `:1434` · dinleyen yok
- `build_progress_changed`: yayan `product_state.gd:203`,`:213` · product_tab.gd:112, build_bar.gd:44, build_hud_panel.gd:52
- `line_bugs_cleared`: yayan `product_state.gd:214` · yalnız smoke/run_probe
- `infra_changed`: yayan `product_state.gd:305`,`:313`,`:324` · product_tab.gd:115
- `bug_confirmed`, `unconfirmed_threshold_crossed`: yayan `product_read.gd:155`, `:158` · yalnız smoke
- `axis_floor_warning`, `axis_floor_crossed`: yayan `product_read.gd:165`, `:167` · olay motoru (`signals.gd:37-38`; `b2c_floor_signal`, `b2c_floor_churn`)
- `research_started`: yayan `rnd_system.gd:279` · left_tabs.gd:118, research_bar.gd:49
- `research_completed`: yayan `rnd_system.gd:462` · left_tabs.gd:119, research_bar.gd:50
- `research_frozen`, `research_resumed`: yayan `rnd_system.gd:145`, `:147` · left_tabs.gd:120-121, research_bar.gd:51-52
- `node_revealed`, `hidden_line_unlocked`: yayan `rnd_system.gd:481`, `:502` · dinleyen yok
- `product_note_read`: yayan `rnd_system.gd:659` · left_tabs.gd:123; `product_note_issued` MessageSystem'den (`message_system.gd:60`) · main.gd:4700
- `research_progress_changed`: yayan `time_manager.gd:400` · research_bar.gd:48, build_hud_panel.gd:53
- `headline_added`, `ticker_live_line`, `mentor_advisory_changed`: yayan `sprint_bridges.gd:117`, `:89`, `:134` · haber bandı ve Frank satırı
- `module_unlocked`: yayan `scripts/events/core/engine.gd:270` (`EvDelays.module_openings`, ModuleLocks'u okur) · olay motoru `signals.gd:41`
- Dinlenenler: `sprint_system.gd:1279-1308` (`event_resolved`, `hr_day_processed`, `character_removed`, `assignment_changed`, `employee_hired`, `training_started`, `TimeManager.speed_changed`)
- Dinlenenler: `incident_system.gd:313-314` (`event_resolved`, `clock_batch_ended`); `sprint_system.gd:1584` (`clock_batch_ended`, tek seferlik)

## Durum ve veri

- `GameState.product` `scripts/autoload/game_state.gd:302`: sprint, next, mode(plan|active|release), cards, release, releases, requests, rival_hits, quarter, decision, delegate… (`new_state` sprint_system.gd:74-84)
- `GameState.product` ek alanlar: `interrupt` {sprint, kind} (sprint_system.gd:553), `promise_due` {card, step, promises}, `type_draft`, `pending_faulty`, `empty_sprint`, `decision_sprint`
- Koşan kartta `progress_at_start`: sprintin başındaki `progress` (`_begin`, `put_first`; eski kayıtta `progress` okunur)
- Çeyrekte `quarter.start_day`: çeyreğin başladığı gün (`new_state`, `plan_next`; eski kayıtta sprintin başından geri sayılır)
- Kart `SprintCatalog.new_card` `sprint_catalog.gd:250`: id, kind(feature|request|fix|research), line, step, target_tier, area, need[3], progress[3], state, assignees, bugs, decision, cut
- Kart kimlik önekleri `sprint_catalog.gd:194-222`: `feat:<kademe>`, `req:<talep>`, `plan:cap_paid_plan`, `fix:<hat>`, `res:<alan>`; kart `need`/`progress` sırası [Tasarım, Geliştirme, Test]
- Sürüm kaydı `sprint_system.gd:1479-1484`: number, sprint, shipped, carried, velocity, expected, actual, press, gate, day, changed_areas, alerts_cleared, faulty (+ `thanks`, `reviews`)
- `GameState.incident` `game_state.gd:329`: last_day, pending, shifted, open, drains, forced (şema başlığı `incident_system.gd:32-34`)
- `GameState.flags` `mvp_*` (`FLAG_TYPES` `game_state.gd:48-91`; adlar `product_state.gd:11-39`): mvp_shipped, mvp_version, mvp_line_tiers, mvp_open_bugs, mvp_infra_*, mvp_interest…
- `GameState.trust_drains` `game_state.gd:325` (B2BSalesSystem yazar): `IncidentSystem.resolve` "per_sprint" bedelini oraya ekler (`B2BSalesSystem.add_trust_drain`)
- Ar-Ge durumu `rnd_system.gd:40-49` (kayıt `to_dict` :759, `systems.rnd`): states, progress, active, assignees, paid, freeze_job, note_*; `_was_frozen` kayıt dışı (:53)
- Kayıt: `SCHEMA_VERSION` 19 (`save_manager.gd:16`), `MIN_LOADABLE_VERSION` 10 (:23); göçler `_migrate_15` :823, `_migrate_16` :909, `_migrate_17` :975, `_migrate_18` :1006 (sprint puanı ×5)
- Kayıt sistem blokları `save_manager.gd:379-380`: `systems.product` ({support}) ve `systems.rnd`; ürün/sprint/incident `game_state` bloğunda
- `data/product/sprint.json` blokları: effort :5, need :7, roles :16, request :40, pm :41, decision :42, paper :43, incident :50, paid_plan :79, impact :80, thanks :82, reviews :83, areas :132
- `data/product/lines/*.json`: `subtype`, `lines[]` (id, profile design|dev|test, 3 kademe: effort, usage_weight, license_cost, requires{research,person,total}); `shared.json` 4 hat
- `data/techtree/rnd_tree.json`: `k_arge` :7, `report_period_weeks` :8, `nodes` :10 (19 düğüm), `hidden_lines` :38 (4 hat, yalnız `line_hidden_self_serve` yazılı)
- Sabitler: `SprintSystem` :14-24 (`HOLD_PLAN`, `CRUNCH_MULT`, `MVP_HORIZON`); `ProductQuality` :10-44 (`FIT_SCALE`, `RATIO_CAP`, `CLOSE_CURVE`, `AUDIENCE_STARS`)
- Sabitler: `InfraSystem` :15-68 (`LOAD_AMBER` 90, `LOAD_OVER` 100, `AUTO_EDGE` 80, `AUTO_TARGET` 65); `ProductLines` :17-41; `ResearchTree` :22-56 (`CASH_TABLE`, `STARS_BY_PLACE`)
- Statik, kayıt dışı: `ProductLines.memo` (:53), `ProductRead._prev_*` (:132), `IncidentSystem.rolls` (:51), `ProductState.bugs_free` (:220), `ModuleLocks._override` (:12)

## Metin anahtarları

- `PRODUCT_*` (80 aile, 278 anahtar): Ürün sayfası, sprint kartı, sürüm notu, sunucu bloğu; okuyanlar `scripts/tabs/product/*.gd`, `product_tab.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`, `sprint_system.gd`
- `PRODUCT_SERVER_*` (36 anahtar): sunucu/kapasite arayüzü: `overview_view.gd`, `product_model.gd`, `main.gd`
- `PRODUCT_REVIEW_*` (29): B2C yorum havuzu; `data/product/sprint.json` `reviews` bloğu ve `sprint_bridges.gd`
- `PROD_LINE_*` (20) ve `PROD_STEP_*` (150): hat ve kademe adı; anahtar `ProductLines.line_name_key` (:290) ve `product_lines.gd:177`; `PROD_TYPE_*` tür adı (`product_catalog.gd`)
- `PROD_LOCK_*` (kilit gerekçesi, `sprint_catalog.gd`), `PROD_SHIP_*`/`PROD_VERSION_*` (sürüm başlığı, `sprint_system.gd`), `PROD_RND_NODE_*` (düğüm adı, `ResearchSeam.node_name`)
- `RND_*`: Ar-Ge penceresi (`scripts/tabs/rnd/*.gd`, `rnd_tab.gd`, `research_bar.gd`); `RND_NOTE_*` (29) aylık not ve `RND_DISCOVERY_*` keşif notu: `rnd_system.gd`, `inbox.gd`, `mail_pane.gd`
- `BUILD_BUSY_*`/`BUILD_PHASE_*`: Ar-Ge duraklama cümlesi (`rnd_system.gd`) ve DESTEK kartı (`build_bar.gd`); `CLOCK_HOLD_SPRINT_PLAN`, `CLOCK_HOLD_RELEASE_NOTE`: `time_manager.gd:32`
- Acil durum ve kâğıt metni kart JSON'undadır: `data/events/cards/product/{incident_*,sprint_*,promise_due}.json`, `customer/{incident_month_close,release_thanks}.json`; gönderen `MAIL_SENDER_*`
- strings.csv elle yazılmaz: bayt-span splice (hafıza: strings-csv-surgery); `loc_product_derived_keys` ve `loc_product_line_keys_resolve` türetilen anahtarları denetler

## Testler

- Tek vaka: `bash tools/smoke_run.sh <vaka>` (`tools/smoke_run.sh:14`); vaka listesi `scripts/debug/endgame_smoke.gd` match tablosu (:78-587), gövde `_case_<ad>` (örn. `_case_sprint_two_days_close` :20455)
- Zaman ekseni: `sprint_timeline_matches_play_out` (eksen oynatmanın aynası: aşama sırası, beklemeler, kişi tek işte, hafta sınırında yapılan; kurucunun görüşme taraması; H/H0 ve hazırlık; sprint başı ilerleme)
  ve ekranın sayıları: bulunmuş ve öngörülen düzeltmenin efora ve oluğa girişi, eksenden önce biten aşama, anahtarların sözleşmesi, sonraki sütunun yükü (planlamada, koşarken, sürüm notunda)
- Ekip dışı ve takip kartı: `sprint_away_lists_who_cannot_work` (ekip özeti dahil), `sprint_follow_card_cannot_be_removed`
- Kart kilidi: `sprint_pin_holds_person` (kilitli kişi yalnız kendi kartında ve ilk sırada, çalışamıyorsa kart kimsesiz, süre ya da bitiş serbest bırakır, plan kilidin sprint ortası bitişini görür)
- Sprint: `sprint_two_days_close`, `sprint_capacity_from_team`, `sprint_ceiling_125_blocks_add`, `sprint_carry_keeps_progress`, `sprint_mvp_three_identity_k1`, `sprint_fix_card_clears_its_line`, `sprint_starts_only_with_consent`
- Sprint: `sprint_request_on_time_met`, `sprint_paid_plan_opens_paid_tier`, `sprint_departure_restaffs_card`, `sprint_never_stalls_in_plan`, `sprint_lead_offers_paid_plan_b2c`, `product_pm_plan_opens_as_next_sprint`
- Lider: `sprint_lead_fills_next_column` (öneri sonraki sütunu da doldurur: tavan, sıra, onaysız PM planı, devir), `sprint_lead_fills_to_ceiling`
- Kâğıt/karar/söz: `sprint_decision_blocks_progress`, `decision_one_per_sprint`, `paper_interrupt_order`, `paper_card_trim`, `paper_line_harden`, `promise_due_fires_when_late`, `promise_extend_once`, `promise_cut_test_escape`
- Acil durum/sunucu: `incident_gap_and_spread`, `incident_night_hold_resumes`, `incident_scale`, `incident_save_roundtrip`, `incident_gates`, `infra_capacity_moves_both_ways`, `auto_capacity_grows_only`, `capacity_step_immediate`
- Hat/kalite: `product_lines_catalog_loads`, `line_k3_locked_without_research`, `product_fit_table`, `product_quality_sector_table`, `product_line_profiles`, `product_area_row`
- Ar-Ge: `research_node_map_binds`, `rnd_tree_loads_and_validates`, `research_freezes_and_resumes`, `research_abandon_keeps_progress`, `rnd_note_author_and_lines`
- Kayıt: `sprint_save_roundtrip`, `save_v14_build_becomes_sprint_plan`, `save_v19_running_sprint_continues`, `save_v10_product_state`, `save_retired_product_flags`
- Harness: `--sprint-probe=hours=<h>:cards=<1|2>:ticks=<t>[:market=…][:incident=<tür>@<tik>][:promise=1][:team=<n>]` (`main.gd:258`, `sprint_probe.gd:3`) basar `SPRINTPROBE` satırları
- Harness: `--product-shot=<c1..c5|cards|flow|edge:<ad>|live:<tür>>` (`main.gd:257`), `--rnd-shot=<tür>` (:264), `--inbox-shot=rnd_note` (:252), `--event-shot=<sprint kâğıdı>`
- Harness: `bash tools/run_gate.sh` presetleri `full_run_fix_{none,worst,due,off}` ve `full_run_b2c_fix_*` (`PROBE FIX/BUGS/STOP` satırları); `--why-fire=<kart>`, `--event-lint`
- Fikstürler: `scripts/debug/product_fixtures.gd`, `data/events/cards/_fixtures/paper_{dev,design,pm,founder,plain,crunch}.json`; smoke acil durum zarını kapatır (`endgame_smoke.gd:71`)

## Dikkat

- Oynatma tek yoldur: `plan_outcome`, `timeline`, `intake` ve `first_bumps` `_replay`i okur
- `_assign` kartın `pinned` alanını ({person, until}) okur: gün < until ve kart bitmemişse kişi yalnız o karta gider, onda ilk gelir, çalışamıyorsa kart o hafta kimsesiz; yazarı Olaylar'ın `pin_card`'ı, `_play_out` haftanın gününü verir
  ↳ İleriki sprintleri sınayan `intake` (MVP tahmini, liderin sütunu) kilidi bugünün günüyle okur: sonraki bir sprintte biten kilidi o sprintin tahmini sürüyor sayar
- `_work`/`_play_out`/`_finish_sprint`in `log` parametresi yalnız `timeline` içindir; kapalıyken sonuçlar bayt eşit kalır (`--sprint-probe` `^SPRINTPROBE`)
- Zaman ekseni: testten sonra Geliştirmeye dönen düzeltme işi ayrı aşamadır (`fix: true`, sonda): testin bulduğu da, oynatmanın öngördüğü de oradadır (kartın gerçek bitişi); sayılar görünen efordur (kalan ihtiyaç ÷ hazırlık kazancı)
- Kartın eforu (`ProductModel._effort`: satırın `effort`ı, önerinin `effort`ı) oynanmamış karttan okunur: testin bulduğu düzeltmeyi sayar, oynatmanın öngördüğünü saymaz; aşama yükleri (`next.load`, `next.carried`, oluk) öngörüleni de Geliştirme'de sayar
- Gösterim kuralı: planlamada ve kartın testi bitmeden dördüncü parça çizilir ama ekranda da ipucunda da hata sayısı yazmaz (plan sayıyı bulur, göstermez); sayı test bitince kartın "Test: N hata buldu" satırıyla gelir. Hiçbir model alanı öngörülen hata sayısı taşımaz (`h`/`h0` göstergedir)
- Koşan sprintte eksen bu haftanın başındandır: önceki haftaların işi `done0`dır; eksenden önce biten aşama `before: true` ile gelir ve start = end = -1 olur, -1 tek başına "bu eksende aralığı yok" demektir
- Sonraki sütunun yükü her kipte aynı işlevlerden çıkar (`ProductModel._load`, `_carried`): planlamada ve koşarken devreden zaman ekseninin `out`u, sürüm notunda sonraki sütunun devreden kartlarının kalan ihtiyacı; planlı pay planlamada ve koşarken kartın sprint sonundaki kalan ihtiyacıdır (önden iş düşülmüş, `SprintSystem.prep_gains`in kazancıyla), sürüm notunda bugünkü; ekip satırları `SprintTimeline.row_power`dan (her satırın kişileri `SprintSystem.capacity_of`a)
- `remove()` kâğıdın takip kartını (`follow`) reddeder; `ProductModel._card` ona Kaldır düğmesi vermez
- Sol sütun `live()`ın `requests` ve `modules` alanlarını okur; `areas` yalnız çeyrek hedef menüsünün listesidir (`{id, name, goal_text}`), `customers` ve hat başına hata listesi yoktur (`bug_row_of` Destek raporunundur)
- Adayın `addable`ı `live()`da `null`dır: `ProductModel.resolve_addable` her karede en az bir `can_add` (8 ms) ister, `ghost` imleç "+"a gelince `timeline([aday])` kurar; ikisinin önbelleği her `live()`da atılır
- `area_sentence` ve türevleri (`_standing`, `_recent_hit`) ekranda okunmaz: tek okuyucusu `ProductQuality.area_row` (Genel Bakış'ın ürün durumu satırı için hazır, bağlı değil)
- Kirli ağaç: bu haritanın üretildiği sırada başka bir oturum sprint puan birimini ×5'e çekiyordu (sprint.json `effort` 15/25/40, `need` tablosu, `_migrate_18`, şema 19); HEAD'de yok. Satırlar kayabilir
- İki ayrı efor tablosu: hat JSON `effort` (bant 5-7/7-9/9-12, `ProductLines.effort_of`, yalnız yeni-kod terimi ve doğrulama) ile sprint.json `effort` k1 15·k2 25·k3 40 (`SprintCatalog.step_effort` :171, kart eforu). Karıştırma
- `SprintCatalog.cfg()` (:29) eksik anahtarda sert hata verir (`v[key]`); sprint.json bozuksa `JSON.parse_string` null döner. Yeni anahtar eklerken okuyan her çağrı yerini birlikte ekle
- Tik sırası bir sözleşmedir (`time_manager.gd:383-432`): Ar-Ge bir tik gecikmeli okur (`rnd_system.gd:94-100`); IncidentSystem EventGate'ten sonra koşar; sırayı değiştirme
- Tek yazıcı: `GameState.product` → SprintSystem (SprintBridges yalnız `requests`, `rival_hits`, `thanks`); açık hata → `add_bugs`/`clear_line_bugs`; `GameState.incident` → IncidentSystem; sunucu → `ProductState.set_infra_*`
- Sunucu kapasitesini yalnız oyuncu ve Otomatik ayar değiştirir; `SprintBridges.on_release` ona dokunmaz (`sprint_bridges.gd:71`); dolu sunucunun tek bedeli kesinti ihtimalidir (`IncidentSystem.load_mult` incident_system.gd:75)
- Saat tutuşları: `sprint_plan` (`sprint_system.gd:22`), `incident` (`incident_system.gd:48`), `product_release_note` (`product_tab.gd:16`); toplu adımda `clock_batch_ended`'e ertelenir; harness zarı kapatmazsa saat takılır
- Kesinti sırası: söz olayı veya acil durum gelen sprintte kâğıt gelmez; kâğıtlı sprintte yalnız `SERVICE_DOWN` (outage, checkout) gelir, öbürü `incident.shifted`'e kalır (`sprint_system.gd:1247`)
- Reddedilen acil durum başlamamış sayılır: `last_day` yazılmaz, tutuş yok (`incident_system.gd:254`); zar yalnız karar verir, kart bir sonraki tam saatte istenir
- Ar-Ge ile Ürün kapıları farklı soru sorar: `LineGates` ham `HRSystem.skill` (izindeki de sayılır), `RnDSystem.area_has_star` etkin çıktı (:387); tek fonksiyona birleştirme
- `ResearchSeam.completed()` adı sözleşmedir (yeniden adlandırma); bilinmeyen kimlik `push_error` + false. `RnDSystem._complete` (:437) önce DONE yazar: gizli hat kaydı yeniden girebilir
- Yükleme sırası: `ProductSystem.from_dict` sonra `RnDSystem.from_dict`; gizli hatlar `ProductState.subtype()`'a bakar (`save_manager.gd:395-398`); çalışma anı hatları kayıt dışıdır
- Gizli hat: yalnız `line_hidden_self_serve` yazılı; öbür üçü `mvp_hidden_lines`'a işlenir ama tabloya kaydolmaz (`rnd_system.gd:490`); `ProductLines` hata metni "twenty" der, düğüm 19'dur (:233)
- Kodda okuyucusu olmayan: `cicd` (`bug_rate_ceil`) ve `test_automation` (`beta_decay`) etkileri; `LineGates.speed_bonus_for` (:126), `ProductCatalog.type_sector_labels` (:237), `RnDSystem.family_root_done` (:707)
- Eski/yalnız smoke: `ProductLines.ladder_refusal` (:420), `ProductCatalog.FEATURE_POOLS` düz havuzu (kalan okuyucu `b2b_sales_system.gd:561`); `ProductRead` işlevlerinin `_product_id` parametresi kullanılmaz
- `fix:<hat>` kartının hata sayısı ve eforu saklı değildir; `_refresh_fix_cards` (sprint_system.gd:1617) her tikte depodan okur, hattında hata kalmayan kart silinir; koşan kartınki başlatmada kilitlenir
- Paylaşılan hat kimliği ürün içinde `id@alt-tür`dür; kart verisi alt-türden bağımsız yazılır, `SprintCatalog.in_product` (:421) çevirir
- Göç adları kayar: `_migrate_17` `version < 18`, `_migrate_18` `version < 19` koşar (`save_manager.gd:204-207`); sprint kartı şeması değişirse yeni göç ve `save_v*` vakası şart

## Bir değişiklik yaparken

- sprint.json sayısını/bloğunu değiştirirsen: okuyan `cfg("…")` çağrılarına, `sprint_probe.gd`, `product_fixtures.gd`, CLAUDE.md "[WORKING]" bölümü ve HARITA Ürün'e bak; puan birimi değişirse `SaveManager` göçü şart
- `GameState.product`'a alan eklersen: `new_state` (`sprint_system.gd:74`) + eski kayıt için varsayılan/göç (`save_manager.gd`) + `save_v19_running_sprint_continues`, `sprint_save_roundtrip` vakaları
- Yeni hat/kademe/alt-tür: `data/product/lines/*.json` + `PROD_LINE_*`/`PROD_STEP_*` (strings.csv) + `ProductCatalog.TYPE_SCREEN` + `rivals.json` + `ProductQuality.TABLE`; `loc_product_line_keys_resolve` koş
- Ar-Ge düğümü: `ResearchSeam.NODES` + `rnd_tree.json` (iki yönlü küme denetimi) + `PROD_RND_NODE_*` + `RND_*` metni; etkisini sahibi sistemde uygula (`ResearchSeam.completed`); `research_node_map_binds`
- Acil durum türü: `IncidentSystem.CARDS` (:37), `_allows` (:161), `_schedule` (:182), `plan`/`resolve` + sprint.json `incident` + kart JSON + `effects.gd:300` + `seams_incident.gd`; `incident_*` vakaları
- Kart/olay fiili (`sprint_*`, `line_harden`, `damage_product`): `effects.gd` liste (:43-48) ve uygulama (:476-525) + `--event-vocab` + `--event-lint` + çip (`events/present/chips.gd`)
- Yeni `mvp_*` bayrağı: sabit `product_state.gd` + `FLAG_TYPES` `game_state.gd:48` (yoksa kayıt tipini yitirir) + gerekiyorsa göç
- EventBus sinyali eklersen/silersen: `python tools/gen_signal_manifest.py`; olay tetikleyicisi olacaksa `scripts/events/core/signals.gd` BINDINGS (:23-41)
- Günlük tik sırası ya da yeni sistem: `time_manager.gd:383-432`, `rnd_system.gd:94-100` yorumu ve HARITA Çekirdek sırası; `incident_*` ve `sprint_*` vakalarını koş

## HARITA'da bayat

- Kesin bayat madde bulunmadı: HARITA Ürün (satır 139-164) ve Ar-Ge (166-181) bölümlerinin kod adları, yolları, vaka adları, sprint.json yolları ve CSV anahtarları kodda var.
- Bayat değil, eksik: Çekirdek dağıtım satırı (HARITA :16) saatlik dilimde `InfraSystem.auto_adjust` (`time_manager.gd:445`) adımını saymaz; Ürün maddesi sayar.
- Bayat değil, eksik: HARITA, okuyucusu olmayan `cicd`/`test_automation` etkilerini, ölü `speed_bonus_for`, `type_sector_labels`, `family_root_done`'u ve dinleyicisiz sinyalleri belirtmez.
