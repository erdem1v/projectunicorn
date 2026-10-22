# Satış, B2B hesaplar, müşteri ve destek

Dizin sha: f3113fa4 (DIZIN.md başlığı; yollar:satırlar bu dizinin kirli ağaç halinden okundu, kapsamdaki dosyalar commit'ten beri değişmedi). Yeniden üret: `python -I tools/kod_haritasi/uret.py`.

Ne yapar: B2B ürün canlıyken lead akışını (şelale), kurucunun iki perdelik görüşmesini, satış temsilcisinin masasını, imzayı ve imzalı hesabın yaşam döngüsünü (memnuniyet, risk, churn, genişleme, söz, sunucu maddesi) işler.
Müşteri temsilcisi masası talepleri yutar ya da oyuncuya çıkarır; Destek, canlı üründe bildirim akışını hataya çevirir ve memnuniyete zarar yazar.
B2C kitle ve MRR türetimi de `SalesSystem`'dedir. Piyasa kataloğu (`MarketCatalog`) ve karşı taraf kişileri (`CounterpartSystem`) bu sistemin sınırında durur.

## Dosyalar
- `scripts/systems/sales_system.gd` (556): giriş kapısı; B2C kitle/MRR/fiyat formülleri, `add_b2b_customer` (tek B2B imza yolu), `reflect_mrr` (tek MRR köprüsü), satış günlüğü
- `scripts/systems/b2b_sales_system.gd` (644): hesap yaşam döngüsü motoru; iki katmanlı memnuniyet, risk/churn sayacı, genişleme, söz sonuçları, güven defteri, sunucu maddesi
- `scripts/systems/b2b_constants.gd` (286): hesap makinesinin ayar bloğu (yaşam döngüsü, tolerans, söz, müşteri masası, genişleme, sektör kimlikleri)
- `scripts/systems/sales_constants.gd` (299): satış modülünün ayar bloğu (şelale, yıldız, görüşme eşikleri, pazarlık, anlaşma planı, kayıp nedenleri, karıştırıcı sabitleri)
- `scripts/systems/sales_faucet_system.gd` (307): lead şelalesi, lead ömrü, dönüş kilidi, balina koşulu, `spawn` (lead'in tek yaratım yolu)
- `scripts/systems/sales_rep_system.gd` (317): satış masası; temsilci lead seçimi, işleme, `sign_due` süpürmesi, fiyat kırma anı, kayıp postası, haftalık özet
- `scripts/systems/sales_meeting_system.gd` (489): Perde 1 (ikna); iğne, soru seçimi, cevap, kesim eşikleri, tek zar, kayıp nedeni; oturum durumu kaydedilmez
- `scripts/systems/negotiation_system.gd` (276): Perde 2 (pazarlık); cetvel, gizli rezerv, sabır, hakaret; tür-bağımsız (`b2b_deal` ve `series_a`)
- `scripts/systems/sales_finalizer.gd` (108): biten pazarlığın uygulayıcısı; masa anlaşması açma, imza, yürüyüş/hakaret/kayıp yolları
- `scripts/systems/sales_ledger.gd` (425): Satış okuma yüzeyi (GDD §14) ve yazma seam'leri; yönlendirme, fiyat duruşu, kayıp hafızası, toplantı kapısı, haftalık satırlar
- `scripts/systems/sales_probes.gd` (337): soru kataloğu (storylet seçici), gerçek sözlüğü `facts_for`, cevap kapıları; metinler türetilmiş CSV anahtarı
- `scripts/systems/sales_archetypes.gd` (185): müşteri arketipleri (3 taslak); sektör, alıcı tipi, mizaç, pazarlık profili, balina koşulları
- `scripts/systems/sales_name_pool.gd` (103): şirket adı havuzu (65 seçme ad + üretilmiş); `take` ile kullanılmamış ad çeker
- `scripts/systems/company_catalog.gd` (116): sektör başına 5 seçme şirket adı (13 sektör, 65 ad); özel isim, LOC-DATA işaretli
- `scripts/systems/customer_rep_system.gd` (380): müşteri masası; hesap sahipliği (kapasite, otomatik atama, fazlayı devretme) ve talep kanalı (yut, yükselt)
- `scripts/systems/counterpart_system.gd` (101): masanın karşısındaki kişiler; fonun üç kişisi (kaydedilir) ve adayın yıldızı kadar kişi (kimlikten türetilir)
- `scripts/systems/support_system.gd` (424): Destek; bildirim akışı, doğrulama, iki kademeli memnuniyet zararı, hata ihmali, haftalık destek raporu, ilgi
- `scripts/systems/market_catalog.gd` (217): Piyasa kataloğu ve saf değer fonksiyonu; veri `data/market/`, kaydedilmez (Piyasa'nın ana anlatımı 05_fon_finans.md)
- `scripts/autoload/customer_registry.gd` (321): müşteri deposu + tüm yazma seam'leri (`set_*`); sinyalleri o yayar
- `scripts/autoload/prospect_registry.gd` (73): lead deposu (`add`, `remove`, `get_company_names`)
- `scripts/autoload/promise_registry.gd` (187): söz deposu; vade süpürmesi, uzatma, kırma, hesap gidince düşürme
- `scripts/data_models/customer.gd` (124): `Customer` Resource; `@export` listesi kayıt şemasıdır, varsayılan göçtür
- `scripts/data_models/prospect.gd` (111): `Prospect` Resource (lead + anlaşma planı + balina + hafıza alanları)
- `scripts/data_models/promise.gd` (22): `Promise` Resource (`due_sprint`, `extended`, `status`)
- `data/market/companies.json` (1571 satır, 56 şirket) ve `data/market/people.json` (327 satır, 46 kişi): Piyasa listesi verisi; `meta.sector_slots` sektörün 3 şirketini bağlar
- Dışarıda ama ayrılmaz: `scripts/tabs/sales_tab.gd` (834), `scripts/ui/meeting/sales_meeting_adapter.gd` (320), `scripts/events/seams/seams_sales.gd` (132), `seams_ported.gd` (194), `scripts/tabs/piyasa_tab.gd` (689)
- Satış olay içeriği: `data/events/cards/customer/*.json` (17 dosya; retention, expansion, cs_escalation, request_*, frank_intro); sprint tarafı `data/events/cards/product/support_overflow.json`

## Giriş noktaları
- `SalesSystem.daily_tick()` `scripts/systems/sales_system.gd:125`: günlük yuva 4 · `TimeManager._dispatch_daily_tick` `scripts/autoload/time_manager.gd:403`
- `SalesSystem.hourly_tick()` `scripts/systems/sales_system.gd:151`: B2C'de saatlik kitle/MRR, B2B'de 12:00 süpürmesi `sign_due` · `time_manager.gd:443`
- `B2BSalesSystem.daily_tick()` `scripts/systems/b2b_sales_system.gd:20`: sıra yüklü; söz vadesi, devir, hesap süpürmesi, müşteri masası, şelale, satış masası, lead ömrü · `SalesSystem.daily_tick` (yalnız B2B ürün)
- `B2BSalesSystem._tick_customer()` `scripts/systems/b2b_sales_system.gd:48`: bir hesabın günü (madde, güven affı, memnuniyet, risk ya da sağlıklı)
- `B2BSalesSystem.satisfaction_target()` `scripts/systems/b2b_sales_system.gd:146`: ürün uyumu eksi hata bedeli artı güven izi · `_tick_satisfaction`, Satış sekmesi, olay çipleri
- `B2BSalesSystem.accept_promise()` `scripts/systems/b2b_sales_system.gd:376`: olay efekti `promise_create` · `scripts/events/core/effects.gd:449`
- `B2BSalesSystem.apply_discount()` `scripts/systems/b2b_sales_system.gd:410`: olay efekti `b2b_retain_discount` · `scripts/events/core/effects.gd:628`
- `B2BSalesSystem.expand()` `scripts/systems/b2b_sales_system.gd:437`: olay efekti `b2b_expand` · `scripts/events/core/effects.gd:649`
- `B2BSalesSystem.on_promise_resolved()` `scripts/systems/b2b_sales_system.gd:501`: söz çözülünce memnuniyet, tolerans, güven, marka yazar · `scripts/autoload/promise_registry.gd:187`
- `B2BSalesSystem.charge_trust_drains()` `scripts/systems/b2b_sales_system.gd:206`: her sprint kapanışı · `scripts/systems/sprint_system.gd:1499` (`add_trust_drain` `b2b_sales_system.gd:200`, `effects.gd:439`)
- `B2BSalesSystem.refresh_pains_after_ship()` `scripts/systems/b2b_sales_system.gd:639`: yayın sonrası hesap yeni dilek seçer · `scripts/autoload/promise_registry.gd:161`
- `B2BSalesSystem.meet_clauses()` `scripts/systems/b2b_sales_system.gd:339`: Kurumsal sunucuya geçiş maddeleri karşılar · `InfraSystem.set_provider`
- `SalesSystem.add_b2b_customer()` `scripts/systems/sales_system.gd:343`: tek B2B imza yolu · `SalesFinalizer.sign_deal` `sales_finalizer.gd:84` ve `SalesRepSystem._close` `sales_rep_system.gd:258`
- `SalesSystem.reflect_mrr()` `scripts/systems/sales_system.gd:166`: toplam MRR'ı `GameState.set_mrr`'a yansıtan tek yer · MRR değiştiren her çağıran
- `SalesFaucetSystem.daily_tick()` `scripts/systems/sales_faucet_system.gd:37`: kilit süpürmesi, balina koşulu, lead girişi · `B2BSalesSystem.daily_tick` `b2b_sales_system.gd:43`
- `SalesFaucetSystem.spawn()` `scripts/systems/sales_faucet_system.gd:191`: lead'in tek yaratım yolu · `_tick_inflow` ve `spawn_prospect` `sales_faucet_system.gd:251` (olay efekti `add_prospect`, `effects.gd:291`)
- `SalesFaucetSystem.lock_return()` `scripts/systems/sales_faucet_system.gd:102`: şirketi havuzdan bir süre dışlar · `expire_leads`, `SalesFinalizer._leave` `sales_finalizer.gd:52`
- `SalesRepSystem.daily_tick()` `scripts/systems/sales_rep_system.gd:36`: haftalık özet, işleme, atama · `B2BSalesSystem.daily_tick` `b2b_sales_system.gd:44`
- `SalesRepSystem.sign_due()` `scripts/systems/sales_rep_system.gd:198`: planı dolan masa ve masa anlaşmalarını imzalar · günlük yuva ve öğlen `SalesSystem.hourly_tick`
- `SalesMeetingSystem.open()` `scripts/systems/sales_meeting_system.gd:83`: Perde 1'i açar · `main.gd:4776`
- `SalesMeetingSystem.choose()` `scripts/systems/sales_meeting_system.gd:241`: bir cevap oynar, iğneyi oynatır, eşik ve zarı değerlendirir · `SalesMeetingAdapter`
- `SalesMeetingSystem.close()` `scripts/systems/sales_meeting_system.gd:114`: iki saati `TimeManager.advance_hours` ile oynatır, oturumu siler · `sales_meeting_adapter.gd:118`
- `NegotiationSystem.open()` `scripts/systems/negotiation_system.gd:91`: Perde 2'yi açar · `scripts/ui/meeting/sales_meeting_adapter.gd:198`
- `NegotiationSystem.offer()` `scripts/systems/negotiation_system.gd:168`: teklif; imza, hakaret ya da karşı teklif · `sales_meeting_adapter.gd:224` (`accept_counter` negotiation_system.gd:195, `walk` :202)
- `SalesFinalizer.apply()` `scripts/systems/sales_finalizer.gd:22`: biten pazarlığın sonucunu uygular · `scripts/ui/meeting/sales_meeting_adapter.gd:111`
- `SalesLedger.meeting_block_reason()` `scripts/systems/sales_ledger.gd:324`: görüşmeye giriş kapısı, CSV anahtarı döner · Satış sekmesi ve `main.gd` davet yolu
- `SalesLedger.set_routing()` `scripts/systems/sales_ledger.gd:52`: Ayır / Temsilciye ver · `scripts/tabs/sales_tab.gd:409`
- `SalesLedger.set_price_stance()` `scripts/systems/sales_ledger.gd:131`: fiyat kadranı · Satış sekmesi
- `CustomerRepSystem.daily_tick()` `scripts/systems/customer_rep_system.gd:192`: talep kanalı (aç, işle, bayatı yükselt) · `b2b_sales_system.gd:39`
- `CustomerRepSystem.reconcile_assignments()` `scripts/systems/customer_rep_system.gd:89`: kurucunun fazlasını devreder · `b2b_sales_system.gd:34`
- `CustomerRepSystem.auto_assign_new()` `scripts/systems/customer_rep_system.gd:131`: yeni imzayı en az yüklü temsilciye verir · `SalesSystem.add_b2b_customer`
- `CustomerRepSystem.pick_request_kind()` `scripts/systems/customer_rep_system.gd:318`: talebin türü (şikâyet, özellik, yenileme) · `seams_ported.gd:59` (`musteri.request_kind`)
- `SupportSystem.hourly_tick()` `scripts/systems/support_system.gd:106`: bildirim gelir, doğrulanır, hata olur · `time_manager.gd:441`
- `SupportSystem.daily_tick()` `scripts/systems/support_system.gd:132`: memnuniyet zararı, hata ihmali, ilgi, haftalık rapor · `time_manager.gd:395`
- `SupportSystem.weekly_report()` `scripts/systems/support_system.gd:320`: haftada en çok bir rapor postası · `daily_tick`, `main.gd:1718` (sahne fikstürü)
- `SupportSystem.to_dict()` `scripts/systems/support_system.gd:146` (`from_dict` :150): yalnız `_damage_residue` kaydı · `ProductSystem.to_dict` `product_system.gd:22`
- `MarketCatalog.value()` `scripts/systems/market_catalog.gd:84`: şirketin haftadaki değeri (saf); `price` :98, `listed` :110, `series` :102 · `piyasa_tab.gd:101`, `news_feed_system.gd:368`
- `CounterpartSystem.prospect_people()` `scripts/systems/counterpart_system.gd:56`: adayın karşısındaki kişiler · `main.gd:4777`, `sales_tab.gd:328`, `inbox.gd:448`
- `CounterpartSystem.fill_investor_people()` `scripts/systems/counterpart_system.gd:33`: fonların üç kişisini çeker · `game_state.gd:950`, `save_manager.gd:317`
- `CustomerRegistry.add()` `scripts/autoload/customer_registry.gd:94`: yeni hesap · `SalesSystem.add_b2b_customer`, `_ensure_b2c_record` `sales_system.gd:238`
- `PromiseRegistry.create()` `scripts/autoload/promise_registry.gd:50`: söz açar (sprint vadesi) · `SalesFinalizer.sign_deal`, `B2BSalesSystem.accept_promise`
- `PromiseRegistry.tick_deadlines()` `scripts/autoload/promise_registry.gd:164`: vadesi geçen sözü kırar · `B2BSalesSystem.daily_tick` `b2b_sales_system.gd:33`

## Sinyaller
Emit satırları DIZIN'den ve kaynaktan; "dinleyen" DIZIN'in `connect` sütunudur: dizi içi bağlamalar (`scripts/tabs/sales_tab.gd:62`) ve olay motoru izin listesi (`scripts/events/core/signals.gd:22`) dahil.
- `customer_added`: yayan `scripts/autoload/customer_registry.gd:102` · `top_bar.gd:127`, `inbox.gd:160`, `sales_tab.gd:71`, `finance_ozet_view.gd:73`, olay motoru (`signals.gd:23`)
- `customer_removed`: yayan `scripts/autoload/customer_registry.gd:128` · `promise_registry.gd:21` (söz düşer), `left_tabs.gd:117`, `inbox.gd:160`, `sales_tab.gd:71`, `finance_ozet_view.gd:74`
- `customer_mrr_changed`: yayan `scripts/autoload/customer_registry.gd:140` · dinleyen yok
- `customer_seats_changed`: yayan `scripts/autoload/customer_registry.gd:155` · `sales_tab.gd:75`
- `customer_satisfaction_changed`: yayan `scripts/autoload/customer_registry.gd:171` · `sales_tab.gd:75`
- `customer_health_changed`: yayan `scripts/autoload/customer_registry.gd:186` (faz değişince; `set_lifecycle_phase`) · `left_tabs.gd:115`, `inbox.gd:161`, `sales_tab.gd:72`, olay motoru (`signals.gd:24`; `customer.retention` buna bağlı)
- `customer_churn_countdown_changed`: yayan `scripts/autoload/customer_registry.gd:199` · `sales_tab.gd:72`
- `customer_churned`: yayan `scripts/systems/b2b_sales_system.gd:308` (`_remove_lost`; olay yolundaki `churn_customer` bunu yaymaz, `effects.gd:270`) · `left_tabs.gd:116`, `sales_tab.gd:73`, olay motoru
- `customer_expanded`: yayan `scripts/systems/b2b_sales_system.gd:449` · `sales_tab.gd:74`, olay motoru
- `customer_assigned`: yayan `scripts/autoload/customer_registry.gd:321` · `hr_tab.gd:78`, `sales_tab.gd:74`
- `promise_created`: yayan `scripts/autoload/promise_registry.gd:77` · yalnız probe (`run_probe.gd:482`)
- `promise_kept`: yayan `scripts/autoload/promise_registry.gd:185` (kısmi de buradan) · yalnız smoke ve probe
- `promise_broken`: yayan `scripts/autoload/promise_registry.gd:183` · olay motoru (`signals.gd:29`), smoke
- `prospect_added`: yayan `scripts/autoload/prospect_registry.gd:49` · `sales_tab.gd:66`
- `prospect_removed`: yayan `scripts/autoload/prospect_registry.gd:73` · `sales_tab.gd:66`
- `prospect_arrived`: yayan `scripts/systems/sales_faucet_system.gd:243` · `sales_tab.gd:67`, `run_probe.gd:498`
- `lead_expired`: yayan `scripts/systems/sales_faucet_system.gd:71` · `sales_tab.gd:67`
- `lead_reserved` / `lead_routed` / `lead_unrouted`: yayan `scripts/systems/sales_ledger.gd:61` / `:63` / `:65` · `sales_tab.gd:68`
- `whale_condition_met`: yayan `scripts/systems/sales_faucet_system.gd:96` (tek yayıcı; `sign_deal` yaymaz) · dinleyen yok
- `pitch_requested`: yayan `scripts/tabs/sales_tab.gd:412` · `scripts/main/main.gd:4462` (görüşme daveti)
- `meeting_entered`: yayan `scripts/systems/sales_meeting_system.gd:100` · yalnız probe
- `meeting_won`: yayan `scripts/systems/sales_meeting_system.gd:322` (`_win`) · dinleyen yok
- `meeting_lost`: yayan `scripts/systems/sales_ledger.gd:190` (`report_loss`; masa kaybı, yürüyüş-kayıp ve masa kaybı hep buradan) · yalnız probe
- `pitch_finished`: yayan `scripts/systems/sales_meeting_system.gd:120` (VC de yayar: `vc_pitch_system.gd:125,387`) · `sales_tab.gd:76`, `hunt_tab.gd:48`
- `deal_signed`: yayan `scripts/systems/sales_system.gd:407` · `sales_tab.gd:70`, probe
- `deal_walked`: yayan `scripts/systems/sales_finalizer.gd:55` (`_leave`) · `sales_tab.gd:70`
- `rep_deal_closed`: yayan `scripts/systems/sales_rep_system.gd:272` · `sales_tab.gd:70`
- `rep_deal_lost`: yayan `scripts/systems/sales_rep_system.gd:255` · yalnız smoke ve probe
- `rep_discount_requested`: yayan `scripts/systems/sales_rep_system.gd:233` · yalnız smoke; fiyat kırma kartı bağlı değil (aşağıda Dikkat)
- `pitch_promise_made` / `pitch_promise_kept` / `pitch_promise_broken`: yayan `sales_finalizer.gd:100` / `b2b_sales_system.gd:514` / `:512` · dinleyen yok
- `weekly_sales_report_issued`: yayan `scripts/systems/sales_rep_system.gd:315` · yalnız smoke
- `price_stance_changed` / `rep_band_cap_changed`: yayan `scripts/systems/sales_ledger.gd:135` / `:109` · `sales_tab.gd:69`
- Destek ve Piyasa sinyal yaymaz; destek raporu `MessageSystem.post("support_week")` `support_system.gd:336` ile gelen kutusuna düşer.

## Durum ve veri
- `GameState.sales_log` (`SALES_LOG_CAP` 12) `scripts/autoload/game_state.gd:158`: etkinlik günlüğü; yazan `SalesSystem.record_sales_event` `sales_system.gd:327`
- Koşu sayaçları `game_state.gd:189-193`: `run_customers_signed`, `run_customers_lost`, `run_customers_expanded`, `run_prospects_spawned` (lead kimliğini tekil tutar, tek yön artar)
- `GameState.b2b_signed_company_names` `game_state.gd:196`: imzalı şirket adları; churn'den sağ çıkar, şelale bu adı bir daha sunmaz
- `GameState.cs_escalation_days` `game_state.gd:199`: müşteri masasının haftalık yükseltme tavanı için kayan pencere
- `GameState.sales_loss_log`, `sales_account_memory`, `sales_return_locks`, `sales_band_caps`, `sales_line_memory` `game_state.gd:212-221`: Satış defteri (yazan `SalesLedger`; `sales_line_memory`'yi `SalesProbes.remember` yazar)
- `GameState.sales_meetings_week` `game_state.gd:186`: {tick, count}; haftanın görüşme sayısı, sıfırlama yok (tik damgası taşır)
- `GameState.trust_drains` `game_state.gd:325`: süren güven bedelleri; tek yazıcı `B2BSalesSystem.add_trust_drain`
- `GameState.investor_people` `game_state.gd:206`: fonların üç kişisi (kaydedilir); adayın kişileri kaydedilmez, kimlikten yeniden türer
- `GameState.market_shocks`, `market_catalog_version` `game_state.gd:296-297`: Piyasa şok defteri; üretimde yazıcısı yok (Dikkat)
- Tipli bayraklar `GameState.FLAG_TYPES` `game_state.gd:48` (b2c ve sales girdileri :86-103): `sales_faucet_progress`, `sales_price_stance`, `sales_inner_voice_used`, `sales_open_pitch_promise`, `sales_weekly_*`, `cs_throughput_progress`
- Bayraklar (sabit tipli değil, anahtar öneki): `b2b_broke_<müşteri>` `game_state.gd:127` (kırılmış söz mandalı); `mvp_market_type` `game_state.gd:56` pazarın B2B mi B2C mi olduğunu söyler
- Kayıt: `SaveManager.SCHEMA_VERSION` 19 (çalışma ağacında; HEAD'de 18) `scripts/autoload/save_manager.gd:16`. `Customer`/`Prospect`/`Promise` `@export` listesi şemadır, varsayılan göçtür
- Oturum durumu kaydedilmez: `SalesMeetingSystem` ve `NegotiationSystem` statik değişkenleri; `can_save()` oturum açıkken reddeder `save_manager.gd:93-94`, `reset_all_owners` sıfırlar `:353-354`
- `SupportSystem._damage_residue` `scripts/systems/support_system.gd:99`: kesirli memnuniyet zararı artığı; kaydı `ProductSystem.to_dict` taşır
- `Customer` gizli alanları `scripts/data_models/customer.gd`: `tolerance` :40, `trust_offset` :61, `cs_pinned` :72, `market_ref` :79, `seat_price` :86, `clause_due_day` :94
- Önemli sabitler, yaşam döngüsü: `ONBOARDING_WEEKS` `b2b_constants.gd:10`, `SAT_DRIFT_STEP` `:30`, `CHURN_COUNTDOWN_WEEKS` `:28`, `RISK_REENTRY_WEEKS` `:27`, `EXPANSION_MATURE_WEEKS` `:29`, `TOLERANCE_BASE` `:39`
- Önemli sabitler, söz ve masa: `PROMISE_DEADLINE_WEEKS` `b2b_constants.gd:152`, `PROMISE_RELOCK_WEEKS` `:167`, `CS_ESCALATION_SAT` `:176`, `CS_REQUEST_INTERVAL_WEEKS` `:241`, `CS_ESCALATION_WEEKLY_CAP` `:248`
- Önemli sabitler, sunucu maddesi: `CLAUSE_STAR` `b2b_constants.gd:49`, `CLAUSE_WEEKS` :50, `CLAUSE_NOTICE_WEEKS` :51, `CLAUSE_MARGIN` :52; sektör kimlikleri `SECTORS` :97, fikstür sektörü `SECTOR_FIXTURE` :103
- Önemli sabitler, satış: `FAUCET_BASE_PER_WEEK` `sales_constants.gd:19`, `LEAD_LIFE_WEEKS` :56, `RETURN_LOCK_WEEKS` :57, `MEETINGS_PER_WEEK` :68, `CUT_HIGH` :97, `CUT_LOW` :98, `SEAT_PRICE_MIN` :120, `DEAL_BASE_WEEKS` :152
- Destek sabitleri `support_system.gd`: `INFLOW_BASE` :33, `VALIDATION_COEF` :48, `DAMAGE_DAILY_CAP` :69, `NEGLECT_BUGS` :86, `NEGLECT_WEEKS` :88, `REPORT_KIND` :314
- B2C: `B2C_USERBASE_ID` `sales_system.gd:25` (tek toplu kayıt `co_b2c_userbase`), `SATISFACTION_DRIFT_PER_DAY` :40, `TRACTION_MRR_TARGET` :46 (Series A çıtası, ekranda sayı olarak gösterilmez)
- Veri dosyaları: `data/market/companies.json` (`meta`: version, knot_weeks, noise, sector_slots; her şirkette `anchors` yıl sonu değerleri, `beta`, `noise`, `shares_outstanding`) ve `people.json`; yükleyen `market_catalog.gd:34`
- Arketipler kodda: `SalesArchetypes.TABLE` `scripts/systems/sales_archetypes.gd:41` (`ops_cautious` :45, `tech_exacting` :63, `finance_brisk` :81)
- Soru kataloğu kodda: `SalesProbes.CATALOGUE` `scripts/systems/sales_probes.gd:141` (8 soru, vurgu cevapları `EMPHASIS_ANSWERS` :115)

## Metin anahtarları
Tüm anahtarlar `localization/strings.csv`'de. Türetilmiş anahtarlarda sabit metin aranamaz; `loc_sales_derived_keys` ve `loc_b2b_derived_keys` vakaları bu katalogları gezer.
- `SALES_PROBE_<ID>`, `SALES_ANS_<ID>_<CEVAP>`, `SALES_LOCK_<GERÇEK>`: soru, cevap ve kilit satırları · `sales_probes.gd`, `sales_meeting_system.gd:457` (`_lock_key`)
- `SALES_MOD_*`: zar ipucu satırları (`_modifier_labels` `sales_meeting_system.gd:194`); `SALES_LOSS_*`, `SALES_WIN_CUT`, `SALES_MEMORY_*`, `SALES_INNER_VOICE_*`, `SALES_MEETING_OBJECTION` · `sales_meeting_system.gd`, `sales_ledger.gd`
- `SALES_ARCH_<ID>_LINE`: arketip sesi · `sales_archetypes.gd:115`
- `SALES_BLOCK_*`, `SALES_ROUTE_*`, `SALES_BAND_*`: görüşme kapısı, yönlendirme ve bant gerekçeleri · `sales_ledger.gd`, `sales_rep_system.gd`, `sales_tab.gd`
- `SALES_TICKER_*`, `NOTICE_SRC_*`: imza haberi · `sales_finalizer.gd:108`, `sales_rep_system.gd:274` (başlık satırları), `sales_ledger.gd:277` (`announce_signing`)
- `SALES_WEEKLY_*`, `SALES_REP_LOST_TITLE`: haftalık satış özeti ve temsilci kayıp postası · `sales_rep_system.gd:245-316`, `inbox.gd`, `mail_pane.gd`
- `SALES_CLAUSE_*`: Kurumsal sunucu maddesi (posta metinleri, şerit) · `b2b_constants.gd:54` (`CLAUSE_MAILS`), `sales_tab.gd`, `mail_pane.gd`, `inbox.gd`
- `SALES_B2C_*`, `SALES_LOG_*`: B2C sayfası ve etkinlik günlüğü · `sales_system.gd`, `sales_tab.gd`
- `B2B_RISK_VOICE_*`, `B2B_COMPLAINT_<SEKTÖR>`, `B2B_CONTACT_<SEKTÖR>`, `FEATURE_LABEL_<ADIM>`: hesabın sesi, sektör üslubu, istenen özelliğin adı · `b2b_sales_system.gd:620`, `b2b_constants.gd:123-145` (`_derived`)
- `B2B_EV_*`, `B2B_CHOICE_*`, `B2B_LOCK_*`, `B2B_DISCOUNT_*`, `EV_CUSTOMER_*`: müşteri olay kartları · `data/events/cards/customer/*.json`
- `NEG_TITLE_*`, `NEG_PRICE_*`, `NEG_UNITS_*`, `NEG_LOCK_*`, `NEG_INSULT_*`: Perde 2 etiketleri (`b2b_deal` ve `series_a` için ayrı) · `negotiation_system.gd`
- `MEETING_ROLE_*`: karşı taraf unvanları · `counterpart_system.gd:22` (`ROLE_KEYS`), `meeting_panel.gd`, `term_sheet_table_scene.gd`
- `SUPPORT_RPT_*`, `REP_DROP_*`: destek raporu ve itibar düşüşü ipucu · `support_system.gd:320-345`, `mail_pane.gd`, `inbox.gd`
- Şirket adları, sektör köken adları ve soyadlar özel isimdir; çeviri anahtarı değil, `# LOC-DATA` işaretli literal (`company_catalog.gd`, `sales_name_pool.gd`)

## Testler
Hepsi `tools/smoke_run.sh <vaka>` ile (komutlar `project-unicorn/`'dan, `GODOT` ortam değişkeni şart; bkz. CLAUDE.md §12). Tam paket yalnız push öncesi; eşleşme tablosu `scripts/debug/endgame_smoke.gd` içindeki `match case_name`.
- Yaşam döngüsü: `b2b_lifecycle_and_countdown`, `b2b_onboarding_grace_floor`, `risk_reentry_hysteresis`, `risk_exit_stamps_day`, `recover_preserves_onboarding`, `b2b_ignore_then_churn`, `b2b_expansion_no_refire`
- Memnuniyet ve ürün uyumu: `b2b_account_reads_fit`, `account_uses_area_rule`, `fit_account_ref`, `bug_cost_b2b_account_lines`, `satisfaction_seam_emits`, `b2b_satisfaction_leaves_b2c_identical`
- Elde tutma: `b2b_retention_routes_seams`, `retention_gate_shared`, `discount_cap_two_uses`, `manual_retention_respects_cap`
- Söz: `b2b_promise_kept_on_ship`, `b2b_promise_broken_on_deadline`, `promise_relock_after_break`, `promise_extend_once`
- Sunucu maddesi: `enterprise_clause_timeline`
- Şelale: `sales_lead_expiry_and_return_lock`, `sales_faucet_guard_b2c`, `sales_star_mix_reads_fit`, `sales_sectors_all_produce_leads`
- Boru hattı: `b2b_prospect_dedup_excludes_signed`, `prospect_id_unique_after_removal`, `company_catalog_pool_integrity`
- Görüşme: `sales_meeting_reads_fit`, `sales_meeting_replays_identically`, `sales_check_replays_after_load`, `sales_loss_reason_from_asked`, `sales_weak_area_loss`
- Görüşme, devamı: `sales_inner_voice_reaches_view`, `sales_meeting_time_skip_founder_share`, `b2b_pitch_meeting_signs`
- Masa ve temsilci: `sales_desk_deal_runs_its_plan`, `sales_deal_plan_rule`, `sales_rep_close_die`, `sales_rep_selection_rule`, `sales_rep_loss_mail`
- Masa ve temsilci, devamı: `sales_weekly_report_is_a_message`, `hotfix_weekly_summary_rows`, `sales_seat_price_stamp_and_expansion`
- Müşteri masası: `cs_auto_assignment_capacity`, `cs_request_channel_gated_on_rep`, `cs_request_absorption_by_expertise`, `cs_request_kind_state_driven`
- Müşteri masası, devamı: `b2b_cs_escalation_refuse`, `account_ownership_round_trip`, `founder_owns_accounts_manually`
- Destek: `support_desk_rates_stack`, `support_inflow_is_bug_free`, `support_report_quiet_week`, `neglect_reputation_below_zero`
- Piyasa: `market_catalog_lint`, `market_value_deterministic`, `market_value_texture`, `market_price_band`, `market_listed_week_gating`, `market_year_end_follows_anchors`, `market_share_tracks_mrr`, `market_save_roundtrip`
- Kayıt: `sales_save_roundtrip_rev6`, `save_v17_market_ref`; yerelleştirme: `loc_sales_derived_keys`, `loc_b2b_derived_keys`, `loc_csv_integrity`
- Pazarlık için ayrı vaka yok; Perde 2 `b2b_pitch_meeting_signs` (`endgame_smoke.gd:3626`) içinde `NegotiationSystem.open/offer` ile ve ekran vakası `--negotiation-shot` ile gezilir
- Ekran: `--sales-shot=<pipeline|desk|picker|inbox|edge|edge_end|stretched|empty|b2c|b2c_live|b2b_pre|untyped|morning|evening|norep|discounted|frank|risk_stability|deals|returning|clause>` (`main.gd:1453`)
- Ekran: `--meeting-shot=<kind>` (`main.gd:4233`), `--negotiation-shot=<open|countered|insult|last|confirm>` (`main.gd:4345`), `--b2b-shot=<retention|retention_capped|escalation|expansion|deal|angel|chips>` (`main.gd:682`), `--inbox-shot=`
- Probe: `--run-log=<preset>:<hafta>:sim[:<seed>]` ile `b2b_solo`, `b2b_reps`, `b2b_risk`, `b2b_slip`, `b2b_book20`, `b2b_book330`, `full_run*` (`run_probe.gd:188-233`); kayıtlar `STATE`, `SIGN`, `CUST`, `PROMISE`, `DISCOUNT`, `RETAIN`
- Olay kapıları: `--event-lint`, `--why-fire=customer.retention` gibi kart kimliği, `--event-harness=`; bu kapılar `customer/*.json` kartlarını sınar

## Dikkat
- YAZMA YOLU: müşteri alanı yalnız `CustomerRegistry.set_*` ile; toplam MRR yalnız `SalesSystem.reflect_mrr()` ile (CLAUDE.md WRITE-THROUGH LAW).
- Kodda seam'siz doğrudan yazılan üç alan var: `retain_stalls` `b2b_sales_system.gd:404`, `cs_escalated` `:61`, `promise_broken_day` `:544`. Yeni yazıcı eklerken bunlara bakıp seam'e çevirmeyi düşün.
- `CustomerRegistry.reset()` ve `insert_raw` sinyal yaymaz, `remove` yayar `customer_registry.gd:113-128`; reset `remove` döngüsüne çevrilirse `PromiseRegistry.drop_open_for` N kez koşar ve yüklemede yarışır.
- Günlük sabitler tikte yedi kat uygulanır: `SAT_DRIFT_STEP`, `TRUST_OFFSET_DECAY_PER_DAY`, destek oranları `TimeModel.per_tick` ile çarpılır. "Günde 3 puan" demek haftalık tikte 21 puan demektir.
- `satisfaction_delta` kartı B2B'de bir tikte silinir: memnuniyet 21 puan/tik kayan hedefe geri çekilir (hafıza: satisfaction-delta-drift). Kalıcı iz yalnız `trust_offset` ile (`trust_delta` efekti, `effects.gd:430`).
- Sıra yüklüdür `B2BSalesSystem.daily_tick` `b2b_sales_system.gd:20`: söz vadesi, devir, hesap süpürmesi, müşteri masası, şelale, satış masası, lead ömrü.
- Aynı gün imzalanan hesap kendi imza gününde süpürülmez; öğlen imzası süpürmeden sonra gelir.
- `SalesFaucetSystem.market_open()` ve `SalesSystem.is_b2b_market()` iki kez sorulur (bilerek). B2C koşuda sıfır lead ve sıfır B2B yaşam döngüsü çıkmalı; vaka `sales_faucet_guard_b2c`, `b2b_market_gate_b2c_run`.
- RNG yok: şelale, kişi, rezerv, koltuk sayısı ve temsilci zarı `SalesConstants.mix`/`mix_seed`/`mix_unit` ile tohum+kimlikten türer (`sales_constants.gd:286-298`). Kimlik ya da tuz değişirse eski kayıttaki sonuçlar kayar.
- Tek zar `SalesMeetingSystem._resolve_by_check` `sales_meeting_system.gd:306`: anahtar koşu tohumu, gün, lead ve OYNANAN YOL. Yeniden yüklemek sonucu değiştirmez; yol kimliğini bozmak zarı yeniden atar.
- Oturum durumu (`SalesMeetingSystem._active`, `NegotiationSystem._reserve` …) static ve KAYDEDİLMEZ; yeni oturum alanı `reset()` içine de eklenmeli, yoksa bir önceki görüşmeden sızar.
- Gizli rezerv ve `tolerance` oyuncuya hiç gösterilmez (cetvel yalnız karşı teklifle açılır); UI'a rakam eklenirse bilgi oyunu ölür. Zar ipucu satırları sayı yazmaz (`SALES_MOD_*`).
- `rep_discount_requested` yayılır ama fiyat kırma kartı (`SalesConstants.PRICE_BREAK_CARD_ID`) `EventGate.request` ile istenmez; `signing_discount` bu yüzden hep 0 (`sales_finalizer.gd:84` DESIGN-PARKED notu).
- Kart gövdesinde yalnız `{slot}` ve `{seam:ns.ad}` çözülür; `customer/*.json` yazarken süslü parantezli başka belirteç ekrana olduğu gibi çıkar (hafıza: unresolvable-card-token-class).
- Bazı `EventBus` sinyallerinin kodda dinleyeni yok (`KALITE.md` "yarım sinyaller"); olay motoru yalnız `signals.gd:22` izin listesindekileri dinler, yeni tetik sinyali oraya da yazılmalıdır.
- `MarketCatalog` önbelleği `static var` ve bilerek `reset_all_owners` dışında (dosya verisi); `GameState.market_shocks` üretimde yazılmıyor, yalnız smoke yazıyor (`endgame_smoke.gd:24191`).
- `SalesNamePool._pools` `sales_name_pool.gd:61` de önbellektir ve geçersiz kılınmaz; `STEMS` ya da `COMPANIES` çalışma zamanında değişmez, kod değişikliği yeni süreç ister.
- `SalesArchetypes.TABLE` sektör sırası yüklüdür (`% size` çekimi, fikstürler `[0]` okur); yeni sektör sona eklenir. Sektör kimlikleri kayıtlıdır (`Customer.industry`), yeniden adlandırma göç ister (`LEGACY_SECTOR_IDS`).
- Kurucuya otomatik hesap verilmez (`CustomerRepSystem.ranked_reps` yalnız `employee` döner) ve bu MÜHÜRLÜ bir hükümdür; "boştaki kurucuya hesap ver" diye değiştirilmez.
- Doğrudan `Customer.new()` ile müşteri yaratmayın: `SalesSystem.add_b2b_customer` sayaçları, sunucu maddesini, atamayı, pazar referansını ve şirket adı hafızasını birlikte yazar (kayıt geri yükleme `insert_raw` kullanır).
- Çalışma ağacı kirli ve paralel oturum yazıyor olabilir: `sprint_system.gd:1499` gibi başka sistemdeki satır numaraları kayabilir; yeniden üretmeden önce `grep` ile doğrulayın.

## Bir değişiklik yaparken
- Müşteri/Prospect/Promise alanı eklersen: model dosyası + `SaveManager` göçü gerekiyorsa `SCHEMA_VERSION` + `Customer`'da `CustomerRegistry.set_*` seam'i + gerekirse `SaveCodec` kapsamı; varsayılan göçtür, sentinel koyma.
- Yeni Satış sayısı (eşik, ağırlık) eklersen: `SalesConstants` ya da `B2BConstants`'a "[ÇALIŞMA]" etiketiyle; başka dosyada literal bırakma. Hesap yaşam döngüsü sayısıysa `B2BConstants`, görüşme ve şelale sayısıysa `SalesConstants`.
- Yeni soru ya da cevap eklersen: `SalesProbes.CATALOGUE` satırı + türetilmiş CSV anahtarları (`SALES_PROBE_`, `SALES_ANS_`, `SALES_LOCK_`) iki dilde + `facts_for` içinde karşılığı olan gerçek; vaka `loc_sales_derived_keys`.
- Yeni kayıp nedeni eklersen: `SalesConstants.LOSS_*` + `SalesLedger._blocker_cleared` (`sales_ledger.gd:353`) + `SalesMeetingSystem._derive_loss_reason`/`_loss_target` + `SALES_LOSS_*` ve `SALES_MEMORY_*` anahtarları.
- Yeni arketip eklersen: `SalesArchetypes.TABLE` satırı, `SALES_ARCH_<ID>_LINE`, sektörleri `B2BConstants.SECTORS` ve `SalesNamePool.SECTOR_WORDS` içinde olmalı; sektör sırası kuralına dikkat.
- Hesap memnuniyeti ya da churn kuralı değişirse: `B2BSalesSystem._target_on`/`_drift`/`_tick_at_risk` + `B2BConstants` + olay seam'leri `musteri.*` (`seams_ported.gd`, `seams_sales.gd`) + `Inbox.risk_reason`.
- Aynı değişiklikte koşulacak vakalar: `b2b_lifecycle_and_countdown`, `risk_reentry_hysteresis`.
- Yeni müşteri olayı eklersen: kart `data/events/cards/customer/` + `signals.gd` izin listesi (sinyal tetikliyorsa) + `seams_*` (yeni koşul okuyorsa) + `EvEffects` (yeni fiil) + `--why-fire` ve `--event-lint`.
- Müşteri masası kapasitesi/talep türü değişirse: `CustomerRepSystem` + `B2BConstants.CS_*` + `musteri.request_kind` seam'i + üç `customer.request_*` kartı; `pick_request_kind` skorları RNG'siz kalmalı.
- Destek akışı ya da zarar formülü değişirse: `SupportSystem` sabitleri + `ProductState` bayrak adları (tek ev) + `ProductSystem.to_dict` kaydı + `support_*` ve `neglect_*` vakaları; destek raporu metni `SUPPORT_RPT_*`.
- Piyasa verisi değişirse: `data/market/*.json` + `meta.version` artır (`GameState.market_catalog_version` kayıtta karşılaştırılır) + vaka `market_catalog_lint`; sektör slotları `RivalCatalog` ile sıra kilitlidir.

## HARITA'da bayat
HARITA Satış bölümü (`docs/HARITA.md:201-226`) ile Görüşme, Fonlama, Dünya ve Kayıt satırlarının bu sisteme değen sembolleri (backtick'li sınıf.üye, sabit, vaka adı, dosya yolu) koda karşı tarandı. Kodda artık olmayan iddia bulunamadı.
- `InfraSystem.blocks_enterprise_signature`, `WHALE_COND_PROVIDER`, `probe_capacity`: HARITA:210'da "kalktı" diye geçer; kodda yok, doğru yazılmış (bayat sayılmadı).
- Bayat değil, eksik: HARITA:203 "Yer" satırı `counterpart_system`, `market_catalog`, `support_system`, `sales_probes`, `sales_name_pool`'u listelemez; ilk ikisi başka bölümlerde (Fonlama:254, Dünya:284), Destek Ürün bölümündedir (:142).
