# Ürün, sprint ve Ar-Ge

Dizin git sha: f3113fa4 (DIZIN.md başlığı, 2026-10-22). Satır numaraları o dizine göredir; düzenlemeden önce hedef satırı kaynakta doğrula.

Ne yapar: ürün tek bir ürün satırıdır: alt-tür başına 9 hat × 3 kademe (JSON), 2 haftalık sprint motoru kartları haftalık atar, kapanışta sürüm çıkarır. Hata deposu, kalite, sunucu, acil durum ve Ar-Ge bunu besler.
Ar-Ge 19 düğümlü ağaçtır; tamamlanan düğüm hat kapılarını ve katsayıları açar. LineGates ve ModuleLocks "bu kademe/sayfa şimdi açık mı" sorusunun tek cevap yeridir.
Kaynak: Ürün için PRD rev 7 (GUNCELLEMELER "Ürün rev 7"), GDD ch03 ve ch06; Ar-Ge için GDD Ar-Ge modülü.
Sahipler (Ürün): `SprintSystem` (`GameState.product`'ın tek yazarı), `SprintBugs` (kartın hata modeli), `SprintPrep` (PM'in önden hazırlığı), `SprintTimeline` ve `SprintCatalog` (salt okur),
  ↳ `SprintBridges` (ürün durumunda yalnız `requests`, `rival_hits`, `thanks`), `ProductSystem`, `ProductState`, `ProductRead`, `ProductLines`, `ProductQuality`, `ProductCatalog`, `LineGates`, `InfraSystem`, `SupportSystem`;
  ↳ arayüz `ProductModel`, `TypePicker`, `AreaPanel`, `SprintPanel`, `SprintHead`, `CapacityView`, `SprintBoard`, `BoardRow`, `StagePaint`, `SprintFoot`, `SprintNext`, `QuarterView`, `SprintCard`, `SprintUiShared` (08_sekmeler.md).
Sahipler (Ar-Ge): `RnDSystem`, `ResearchTree`, `ResearchSeam`; arayüz `RnDUiShared`, `RnDTreeView`, `RnDDetailPanel`, `RnDAssignPanel`.

## Dosyalar

- `scripts/systems/sprint_system.gd` (2009): sprint motoru: tür seçimi, plan eylemleri, haftalık atama/ilerleme, kapanış ve sürüm, karar kâğıdı, söz olayı, plan tutuşu, kişiyi karta kilitleme; `GameState.product`'ın tek yazarı
- `scripts/systems/sprint_bugs.gd` (176): `SprintBugs` (RefCounted), kartın hata modeli: beklenen hata yükü, testin yakalama oranı, testi biten kartın tohumlu zarı, sürüme bırakılan hata;
  ↳ sayılar `data/product/sprint.json` `bugs` bloğunda [WORKING]
- `scripts/systems/sprint_prep.gd` (134): `SprintPrep`, PM'in sonraki sütunu önden hazırlaması: hazırlık işi, PM hızı, kart sahipliği (kural A), hız ve hata kazancı; sayılar `sprint.json` `prep` bloğunda [WORKING]
- `scripts/systems/sprint_catalog.gd` (929): salt okur katalog: alanlar, aday kartlar, kilit gerekçesi, etki/öngörü satırları, lider ve PM planı, rakipler, `cfg("a.b")` ile sprint.json
- `scripts/systems/sprint_timeline.gd` (326): sprint ekranının zaman ekseni: motorun oynatma günlüğünden aşama yerleşimi, bekleme, kurucunun görüşme taraması, kişi parçaları, kapasite satırı kuralı; yalnız okur
- `scripts/systems/sprint_bridges.gd` (369): B2B talepleri (günlük doğan ve olayın açtığı), rakip çıkışları, basın satırı, MVP/ücretli plan ekonomisi, sürüm notu cümleleri, teşekkür notu ve B2C yorumları
- `scripts/systems/product_state.gd` (341): `mvp_*` bayraklarının evi: kimlik, hat kademeleri, açık hata deposu, sürüm yaşı/ilgi, sunucu sağlayıcı ve kapasite yazma yolu
- `scripts/systems/product_system.gd` (53): koşu sınırı (reset/to_dict/from_dict), haftalık açık hata görüntüsü, saat damgası okumaları
- `scripts/systems/product_read.gd` (172): olay motoruna açılan salt okuma yüzeyi; B2C taban merdiveni; `emit_edges` kenar sinyalleri
- `scripts/systems/product_lines.gd` (432): hat/kademe tablosunu `data/product/lines/*.json`'dan yükler, doğrular; Ar-Ge katsayıları (lisans, tasarım eforu, AI ağırlığı); gizli hat kaydı
- `scripts/systems/product_quality.gd` (394): ürünün tek kalitesi: alan seviyesi, beklenti, sözcük, uyum U (0-100), satışçı kapanış ihtimali, hesap uyumu
- `scripts/systems/product_catalog.gd` (241): alt-tür tablosu, demo tür ekranı (hangi tür oynanır/kilitli), eski düz özellik havuzları
- `scripts/systems/line_gates.gd` (130): kademe gereksinim doğrulayıcı (Ar-Ge düğümü, kişi ★, şirket toplamı ★); kart, tooltip ve satış aynı fonksiyonu okur
- `scripts/systems/module_locks.gd` (35): sekme/modül sayfası bu yapıda açık mı; `UiTokens.TABS` satırındaki `lock` adı kilitler
- `scripts/systems/incident_system.gd` (664): gecenin acil durumları: zar, tür, damga, kart isteği, saat tutuşu, cevabın bedeli (`plan`) ve uygulaması (`resolve`)
- `scripts/systems/infra_system.gd` (290): sunucu sağlayıcı kademesi, kapasite birimi, yük yüzdesi, otomatik ayar, fatura, olayların fiyat çarpanı ve sözleşme kilidi; durumu `ProductState`'te tutar
- `scripts/systems/rnd_system.gd` (814): Ar-Ge motoru: başlat/duraklat/vazgeç, atananlar, birikim, donma, tamamlama, gizli hat, aylık ürün notu, kayıt
- `scripts/systems/research_tree.gd` (427): `rnd_tree.json` yükleyici ve doğrulayıcı: efor/nakit/yıldız bantları, çapraz koşul, 8 katsayı, gizli hat profilleri
- `scripts/systems/research_seam.gd` (100): Ürün tarafının Ar-Ge'ye açılan kapısı: 19 düğüm kimliği tablosu, `completed()`, yerleşim ve aile
- `data/product/sprint.json` (140): tüm sprint/acil durum/kâğıt/rapor sayıları ve alan tanımları ([WORKING] değerler)
- `data/product/rivals.json` (86): alt-tür başına 3 rakip ve çıkış takvimi
- `data/product/lines/{erp,note_tool,video_clip,shared}.json` (169, 158, 160, 128): alt-tür hatları ve 4 paylaşılan platform hattı
- `data/techtree/rnd_tree.json` (57): düğüm başına efor, nakit, alan, yıldız, ebeveyn, çapraz koşul, etki; 4 gizli hat
- Yakın, kapsam dışı (yalnız yol): `scripts/tabs/product_tab.gd` (347), `scripts/tabs/product/*.gd` (13 dosya, en büyüğü `product_model.gd` 1142), `scripts/tabs/rnd_tab.gd` (273), `scripts/tabs/rnd/*.gd` (5 dosya)
- Yakın: `scripts/ui/components/{research_bar,research_bar_model,build_bar,build_bar_model,build_hud_panel}.gd`, `scripts/events/seams/{seams_product,seams_incident}.gd`, `scripts/systems/support_system.gd` (424)
- Yakın: `scripts/debug/product_fixtures.gd` (699, `--product-shot` fikstürü), `scripts/debug/sprint_probe.gd` (425, `--sprint-probe`); çalışma günlüğü tohumları `scripts/main/main.gd` `_seed_product_live` (3839)

## Giriş noktaları

- `TimeManager._dispatch_daily_tick()` `scripts/autoload/time_manager.gd:383`: sıra Product(391) → Sprint(394) → Support(395) → Infra(396) → ProductRead.emit_edges(397) → RnD(399) → … → IncidentSystem(419)
- `TimeManager._dispatch_hourly_tick()` `time_manager.gd:437`: `InfraSystem.auto_adjust()`(445) sonra `IncidentSystem.hourly_tick()`(449); `SupportSystem.hourly_tick` hata düşürür
- `SprintSystem.daily_tick()` `scripts/systems/sprint_system.gd:27`: her günlük tik = bir oyun haftası; moda göre `_end_week` (active), `_auto_start` (plan/release) · TimeManager
- `SprintSystem.choose_type()` `sprint_system.gd:51`: tür/pazar/ad yazar, Sprint 1'i planlamada açar · `scripts/tabs/product_tab.gd:105`, `main.gd:504`
- `SprintSystem.new_state()` `sprint_system.gd:74`: `GameState.product` ilk durumu · `choose_type`, `scripts/autoload/save_manager.gd:888` (v14→v15 göçü)
- `SprintSystem.add()/send_next()/remove()` `sprint_system.gd:95`/`:103`/`:114`: "+", "→", kartı adaya döndür · `ProductTab._act` `product_tab.gd:305`
- `SprintSystem.pin_card()` `sprint_system.gd:135`: kişiyi sprintin kartına `until_day` gününe dek kilitler (`c.pinned`), koşan sprintte haftayı yeniden atar · `effects.gd:578` (`assign_to`)
- `SprintSystem.start()` `sprint_system.gd:134` (`_begin` :158): sprinti başlatır, lisansı keser, plan tutuşunu kaldırır · `begin_planned`, probe'lar
- `SprintSystem.begin_planned()` `sprint_system.gd:145`: alt şeridin "Sprinti başlat"ı (KR26): başlayacak kart varsa `start`, yoksa `skip` (boş sprint); ekip yokken bir şey yapmaz · `ProductTab._act` `product_tab.gd:311`
- `SprintSystem.plan_next()` `sprint_system.gd:209`: sürüm notundan sonraki sprinte geçer, çeyrek döner · `product_tab.gd:313`, `_auto_start`
- `SprintSystem.publish()` `sprint_system.gd:376`: MVP kapısında ürünü CANLI v1.0 yapar · `product_tab.gd:314`
- `SprintSystem.skip()/set_delegate()/apply_lead()` `sprint_system.gd:333`/`:342`/`:391`: boş sprint (`begin_planned` kartsız planda çağırır: planın kartları sonraki sprinte geçer, sprint kartsız başlar),
  ↳ PM'e devret (devirde sprint liderin önerisiyle başlar), liderin önerisini uygula (bu sprint ve sonraki sütun; kapasite 0 iken bir şey yapmaz, bayrak yazılmaz) · `product_tab.gd`
- `sprint.lead_applied` (`apply_lead` kaldırır; plan değişikliği `remove` `:114` ve `_place` `:1936`, Kurucu sprintte anahtarı `set_founder_in_sprint` `:349`
  ve hedef `pick_goal` `:622` düşürür, devir `set_delegate` düşürmez): bayrak yüksekken `apply_lead` plana dokunmaz ve `center.suggest` null olur · `ProductModel.live`
  ↳ Ekip değişimi de düşürür (`_crew_changed`): `_on_team_changed` her HR gününde ve karakter ayrılınca, `_on_assignment_changed` iş değişince, işe alınca ve eğitime gidince çağrılır; bayrak yalnız oturan kişi sayısı ya da
  ↳ `capacity()`, `apply_lead`in yazdığı `lead_crew`dan (`_crew_mark`) farklıysa düşer: moral ve izin gibi sık değişimler kapasiteyi oynatmadıkça satırı geri getirmez
  ↳ Karşılaştırma `_same_crew` `sprint_system.gd:1596`: kişi sayısı tam sayı, kapasite `EPS` içinde (kayıttan dönen işaret JSON'dan kayan noktalı ve kısalmış gelir)
- `SprintSystem._auto_start()` `sprint_system.gd:1558`: oyuncuyu beklemeyen sprinti başlatır; `apply_lead` bu sprinti ve sonraki sütunu doldurur, kart yoksa boş sprint · `daily_tick`, `plan_next` (devirde)
- `SprintSystem.approve()/approve_all()/edit()/pick_goal()` `sprint_system.gd:532`/`:539`/`:548`/`:555`: çeyrek PM planı ve hedef alan · `product_tab.gd:317-320`
- `SprintSystem.fix_first()/put_first()` `sprint_system.gd:224`/`:239`: hattın düzeltme kartı sprintin başına · olay fiili `sprint_fix_first` `scripts/events/core/effects.gd:497`. Sprintteyse başa taşınır,
  ↳ sonraki sütundaysa ya da adaysa sprinte alınır; sürüm notundayken ve koşan sprintin son gecesi (mesai bittikten sonra) sonraki sprintin başına girer;
  ↳ kapanış devredenleri sonraki sütunun başına dizdiği için kartın kimliği `product.next.first` listesine yazılır (son çağrılan önde) ve `_close` onu devredenlerin önüne koyar (`_next_column` `:312`).
  ↳ Koşan sprintte duran düzeltme kartı sonraki sütuna geçmez, yalnız bu sırayı alır; `fix_first_bumps` ve `first_bumps` `:252`/`:264` sonraki sprinti kapanışın devrettikleriyle,
  ↳ son haftanın işi dökülmüş hâlleriyle oynar (`_closing_carry` `:302`)
- `SprintSystem.decision_effort/progress/carry/trim/first()` `sprint_system.gd:342`-`:457`: karar kâğıdının kart fiilleri · `effects.gd:476-514` (`sprint_card_*`)
- `SprintSystem.cut_test()/set_hours_mult()` `sprint_system.gd:932`/`:512`: testi kısalt, fazla mesai · `effects.gd:485`, `:489` (`sprint_card_test`, `sprint_hours`)
- `SprintBugs.expected()/catch_rate()/settle()` `scripts/systems/sprint_bugs.gd:43`/`:61`/`:80`: kartın beklenen hata yükü {h, h0}, testin yakalama oranı, testi biten kartın zarı · `SprintSystem._work` `sprint_system.gd:1384` (`settle`),
  ↳ `SprintTimeline` `sprint_timeline.gd:208` (`expected`)
- `SprintBugs.record()/worked()/gate()/requirement()` `sprint_bugs.gd:35`/`:30`/`:14`/`:24`: yapılan işin kartta kişiye yazımı ve okuması, kademenin kişiden istediği yıldız ve Yazılım kapısı
  ↳ · `SprintSystem._work` `sprint_system.gd:1379` (`record`), `SprintPrep` `sprint_prep.gd:52`, `:100` (`requirement`, `gate`)
- `SprintBugs.known()/sent()/leaving()/tally()` `sprint_bugs.gd:109`/`:123`/`:128`/`:133`: bulunmuş ama düzeltilmemiş hata, gönderilmiş ve testi bitmiş kart, sürüme bırakılan hata, `[n, F, K, düzeltme işi]`
  ↳ · `SprintSystem._close` `:1685` (`leaving`), `plan_outcome` `:947` (`tally`); `known` yalnız `leaving`in içinde okunur
- `SprintPrep.week()/need()/rate()/rate_for()` `scripts/systems/sprint_prep.gd:40`/`:34`/`:27`/`:18`: PM'lerin haftalık hazırlık işi, kartın hazırlık ihtiyacı, PM hızı P(s) · `SprintSystem.team` `sprint_system.gd:780` (`rate`),
  ↳ `_end_week`, `_play_out`, `prep_gains` (`week`)
- `SprintSystem._request_decision()` `sprint_system.gd:1202`: sprint başına tek zar, karar kâğıdı isteği · `_staff_week(true)` ← `_end_week` (:1064)
- Kâğıt sözleşmesi: kartın JSON'unda `speaker_role` (rol ya da rol listesi: `product_manager | designer | developer | tester | founder`), `stage` (`any | design | dev | test`),
  ↳ `pool_group` (`pm | designer | developer | tester | no_tester | solo | system`; motor okumaz) · `SprintSystem._speaker` `:1465`. Konuşan `EventGate.request(kimlik, {"employee": id})` ile (kurucuysa `{"founder": id}`) bağlanır:
  ↳ kartın scope'unda o türden slot şarttır (lint §17.7). PM kâğıdında konuşan `SprintCatalog.quarter_pm()` `sprint_catalog.gd:653`, konu sprintteki müşteri isteği kartıdır (`kind == "request"`), `customer` slotu isteğin hesabıdır;
  ↳ PM yoksa gelmez. Öbürlerinde `_speaker`: kartın o haftaki `assignees`'inden rolü `speaker_role` olan ve (`stage` `any` değilse) kart o fazdayken çalışan ilk kişi; hafta ataması kâğıttan önce yapılır (konuşan istek anında yakalanır),
  ↳ payı Destek'te kalan kişi atanmadığı için konuşmaz, tasarımcı kâğıdını kartta atanmış PM söylemez; `speaker_role` yoksa kâğıt konuşansızdır (yalnız fikstürler);
  ↳ kâğıdın `customer` slotu `select` kipidir (`SprintCatalog.paper_account` `:469`: `line_top`, `line_newest`, `line_slow`, `line_warehouse`, `request`), `employee` slotu `sprint_dev`; seçilemeyen zorunlu slot kâğıdı o kartta getirmez
- `SprintSystem._ask_promise()` `sprint_system.gd:976`: son haftada yetişmeyen söz için `product.promise_due` · `_begin`, `_end_week`
- `SprintSystem._close()` `sprint_system.gd:1406`: kartları çıkarır, hata/kademe/sürüm kaydı yazar, `sprint_closed` yayar · `_end_week`
- `SprintSystem.sync_plan_hold()` `sprint_system.gd:1858`: plan beklerken ve saat şirketin mesai başlangıcına (`WorkHoursSystem.start_hour()`) gelmişken `TimeManager.hold_clock("sprint_plan")` ·
  ↳ `scripts/main/game_shell.gd:28`, `_changed`; gece kapanan sprintin planı 08:00'de saati tutmaz, 08:00 ile mesai başlangıcı arasında saat akar ve `_on_hour` (`hour_changed`) o saatte tutuşu alır;
  ↳ toplu adımda `clock_batch_ended`e ertelenir
- `SprintSystem.record_interrupt()` `sprint_system.gd:563`: sprintin kesinti kaydı (incident|promise|paper) · `IncidentSystem._ask` `incident_system.gd:272`
- `SprintSystem.timeline(extra)` `sprint_system.gd:847`: planlamada plan (artı `extra` aday) ya da koşan sprintin kalanı tek oynatmayla `SprintTimeline.build`e girer; planlamada `outcome` = `plan_outcome` biçimi · `ProductModel.live`
- `SprintSystem.prep_gains(weeks)` `sprint_system.gd:867`: sonraki sütunun kartlarının `weeks` hafta sonraki hazırlık kazancı (kopyalarda yalnız PM'lerin haftaları) · `ProductModel._next`
- `SprintSystem.away()` `sprint_system.gd:748`: ekip dışı kişiler [{id, reason}]: `training`, `leave`, `research`, kurucu `meetings` · `ProductModel._crew`
- `SprintSystem.set_founder_in_sprint()` `sprint_system.gd:310`: kurucu sprint kartı alır mı (planlamada ve sürüm notunda yazılır) · smoke `sprint_away_lists_who_cannot_work`
- `SprintTimeline.build()/done_at()/row_gaps()/capacity_rows()/row_power()` `scripts/systems/sprint_timeline.gd:39`/`:66`/`:76`/`:143`/`:162`: günlükten eksen; aşamanın `at` anına dek yaptığı iş;
  ↳ kart satırının bekleme ya da çubukla kapanmayan boşlukları (smoke Z3 ve `live:a4_*` `row_gaps`); ekibin kapasite satırı kuralı ve satır başına sprint puanı (sürüm notunda da) · `SprintSystem.timeline`, `ProductModel._progress`, `_next`
- `SprintSystem.capacity()/capacity_of()` `sprint_system.gd:651`/`:656`: ekibin ya da verilen `team` satırlarının sprint boyunca puanı; ekip ve satır toplamları yalnız buradan okunur (`SprintTimeline.capacity_rows`/`row_power`,
  ↳ smoke `sprint_timeline_matches_play_out`) · `SprintCatalog.lead_suggestion`, `ProductModel._center`
- `SprintCatalog.row_of()/due_sprint()` `sprint_catalog.gd:120`/`:317`: çalışanın kapasite satırı; kartın söz ya da talep son tarihi · `SprintTimeline`, `ProductModel._row`
- `SprintSystem.plan_outcome()/mvp_eta()/team()/payers()` `sprint_system.gd:772`/`:802`/`:703`/`:725`: plan önizlemesi, MVP tahmini, ekip, bedel ödeyenler · ProductModel, effects.gd
- `SprintCatalog.cfg()` `scripts/systems/sprint_catalog.gd:29`: sprint.json okuması (yoksa yükler) · yaklaşık her sistem; `load_data()` :23 → `main.gd:4694`
- `SprintCatalog.candidates()` `sprint_catalog.gd:194`: alanın aday kartları (feat:/req:/plan:/fix:/res:) · ProductModel, `SprintSystem`
- `SprintCatalog.lead_suggestion()/pm_plans()` `sprint_catalog.gd:526`/`:677`: lider `{this, next}` (bu sprint, sonraki sütun) ve PM planı (`_suggest` :1007); PM planı Ürün puanından bağımsız tam kart taşır · `apply_lead`, ÇEYREK
- `SprintCatalog._lead_picks()` `sprint_catalog.gd:549`: iki sütunun ortak alım döngüsü; sütunda tavan `room` = kapasite − sütunun kalanı − `SprintSystem.carried_points` `sprint_system.gd:817` · `lead_suggestion`
- `SprintCatalog.gate_reason()` `sprint_catalog.gd:290`: kilitli kademenin gerekçesi (`LineGates.unmet_parts`) · `_begin`, `product_model.gd:574`
- `SprintBridges.tick_requests()` `scripts/systems/sprint_bridges.gd:22`: B2B talep doğurur/düşürür · `SprintSystem.daily_tick` :33
- `SprintBridges.request_step()/open_request()` `sprint_bridges.gd:55`/`:66`: hesabın bir hattın sonraki kademesi için açabileceği talep ve onu açan işlev; kaydı `tick_requests` ile aynı `_append_request` yazar · `effects.gd:585` (`queue_card`, `scope`lu)
- `SprintBridges.promise_cards()` `sprint_bridges.gd:86`: koşan sprintte hesabın en eski açık sözünün kademesini yapan kartlar (kademeden, çünkü hesabın istediği kademe `req:<istek>` kartıdır) · `effects.gd` `pin_plan`, `seams_sales.gd` `musteri.promise_late`
- `SprintBridges.on_mvp()/on_release()` `sprint_bridges.gd:124`/`:71`: MVP'de sunucu açar; sürümde talebi karşılar · `SprintSystem._go_public` (sprint_system.gd:1516)
- `SprintBridges.thank()/pick_reviews()` `sprint_bridges.gd:189`/`:263`: sürüm teşekkür notu ve B2C yorumları · `SprintSystem._close`
- `ProductState.add_bugs()/clear_line_bugs()` `scripts/systems/product_state.gd:199`/`:207`: açık hata deposunun tek yazarları · `support_system.gd:128`, `_close`, `effects.gd:525`
- `ProductState.worst_bug_line()/lines_by_bugs()` `product_state.gd:178`/`:165`: en çok hatalı hat (eşitlikte en çok kullanıcıyı etkileyen hat, o da eşitse küçük kimlik; `defter` varsayılan olarak şimdiki depo)
  ↳ · `IncidentSystem._worst` `incident_system.gd:351` ve `SprintBridges._unhappy` `sprint_bridges.gd:311` kritik hat süzgecinden sonra bunu çağırır
- `ProductState.set_line_tier()` `product_state.gd:92`: kademe yazma (merdiveni sormaz) · `SprintSystem._close` :1430
- `ProductState.set_infra_provider()/set_infra_units()/set_infra_price()/set_infra_lock()` `product_state.gd:299`/`:306`/`:350`/`:364`: sunucu durumu yazma, `infra_changed` yayar · `InfraSystem` tek çağıran
- `ProductSystem.daily_tick()/reset()` `scripts/systems/product_system.gd:29`/`:11`: açık hata görüntüsü; koşu sınırı · TimeManager, `save_manager.gd:347`
- `ProductRead.emit_edges()` `scripts/systems/product_read.gd:144`: bug/uyarı/taban kenar sinyalleri · `time_manager.gd:397`
- `ProductRead.step_unlockable()` `product_read.gd:78`: kademe şimdi alınabilir mi · seam `urun.*` (`seams_product.gd:8`)
- `ProductLines.ensure_loaded()/reload()` `scripts/systems/product_lines.gd:58`/`:66`: tembel yükleme/sıfırlama · her erişimci; `ProductSystem.reset`
- `ProductLines.register_runtime_line()` `product_lines.gd:366`: Ar-Ge'nin gizli hattını tabloya ekler · `RnDSystem._open_hidden_line_for` (rnd_system.gd:490)
- `ProductLines.sum_license_cost()/effort_of()/usage_weight_of()` `product_lines.gd:394`/`:341`/`:352`: Ar-Ge katsayılı lisans, efor, kullanım · `_begin`, `_close`
- `ProductQuality.fit()/close_chance()/account_fit()` `scripts/systems/product_quality.gd:261`/`:233`/`:246`: uyum U ve kapanış ihtimali · `b2b_sales_system.gd:157`, `sales_system.gd:222`
- `ProductQuality.lowest(alanlar, oranlar)` `product_quality.gd:389`: `alanlar` içinde oranı en düşük alan (eşitlikte öndeki, oranı olan alan yoksa "") · `weakest_area`, `fit_from_levels`, `ProductRead.worst_floor`
- `LineGates.evaluate()/is_unlocked()/unmet_parts()` `scripts/systems/line_gates.gd:65`/`:88`/`:95`: kademe kapısı · `product_read.gd:79`, `sprint_catalog.gd:296`, `b2b_sales_system.gd:597`
- `ModuleLocks.is_open()/ids()` `scripts/systems/module_locks.gd:21`/`:17`: sekme açık mı · `left_tabs.gd:258`, `events/core/delays.gd:108`, `seams_world.gd:148`
- `InfraSystem.daily_tick()` `scripts/systems/infra_system.gd:244`: faturayı "servers" burn kalemine yazar, hizmet edilen geçmişini tutar · `time_manager.gd:396`
- `InfraSystem.set_provider()/adjust_capacity()/auto_adjust()` `infra_system.gd:178`/`:204`/`:214`: oyuncu kararları ve otomatik ayar · `product_tab.gd:321-325`, `time_manager.gd:445`
- `InfraSystem.is_economy()` `infra_system.gd:83`: seçili sağlayıcı Ekonomik mi; satış masasının `provider_not_economy` olgusunun, kayıp engelinin ve `report_inflow_multiplier`'ın tek okuması · `sales_probes.gd`,
  ↳ `sales_meeting_system.gd`, `sales_ledger.gd`
- `InfraSystem.scale_price()/lock()/lock_reason()/lock_weeks_left()/capacity_floor()` `infra_system.gd:225`/`:236`/`:242`/`:246`/`:251`: olay fiilleri `server_price` / `server_lock` ve onların kuralı · `effects.gd:745-753`, `mail_pane.gd:159`, `run_probe.gd` (`_run_the_servers`, `_answer_the_clause`)
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

- `sprint_planned`: yayan `sprint_system.gd:62`,`:205` · top_bar.gd:124
- `sprint_started`: yayan `sprint_system.gd:175` · top_bar.gd:125, office_people.gd:93
- `sprint_closed`: yayan `sprint_system.gd:1511` · `scripts/main/game_shell.gd:27`
- `card_phase_changed`, `card_done`: yayan `sprint_system.gd:1091`, `:1095` · dinleyen yok
- `card_carried_over`: yayan `sprint_system.gd:401`,`:1505` · dinleyen yok
- `card_decision_requested`: yayan `sprint_system.gd:1235` · yalnız smoke/probe
- `sprint_auto_started`: yayan `sprint_system.gd:1659` · dinleyen yok
- `product_state_changed`: yayan `sprint_system.gd:1850` (`_changed`) · product_tab.gd:114, build_bar.gd:46
- `version_shipped`: yayan `sprint_system.gd:316`,`:1508` · left_tabs.gd:132, top_bar.gd:126; olay motoru `scripts/events/core/signals.gd:30`
- `build_phase_changed("shipped")`: yayan `sprint_system.gd:315`,`:1507` · promise_registry.gd:15, left_tabs.gd:125; olay tetiği (`funding.frank_v1`)
- `line_upgraded`, `line_completed`, `delighter_shipped`: yayan `sprint_system.gd:1442`, `:1444`, `:1445` · dinleyen yok
- `build_progress_changed`: yayan `product_state.gd:203`,`:213` · product_tab.gd:115, build_bar.gd:44, build_hud_panel.gd:52
- `line_bugs_cleared`: yayan `product_state.gd:214` · yalnız smoke/run_probe
- `infra_changed`: yayan `product_state.gd:303`,`:311`,`:322`,`:353`,`:367` · product_tab.gd:118
- `bug_confirmed`, `unconfirmed_threshold_crossed`: yayan `product_read.gd:155`, `:158` · yalnız smoke
- `axis_floor_warning`, `axis_floor_crossed`: yayan `product_read.gd:165`, `:167` · olay motoru (`signals.gd:37-38`; `b2c_floor_signal`, `b2c_floor_churn`)
- `research_started`: yayan `rnd_system.gd:279` · left_tabs.gd:118, research_bar.gd:49
- `research_completed`: yayan `rnd_system.gd:462` · left_tabs.gd:119, research_bar.gd:50
- `research_frozen`, `research_resumed`: yayan `rnd_system.gd:145`, `:147` · left_tabs.gd:120-121, research_bar.gd:51-52
- `node_revealed`, `hidden_line_unlocked`: yayan `rnd_system.gd:481`, `:502` · dinleyen yok
- `product_note_read`: yayan `rnd_system.gd:659` · left_tabs.gd:123; `product_note_issued` MessageSystem'den (`message_system.gd:60`) · main.gd:4711
- `research_progress_changed`: yayan `time_manager.gd:400` · research_bar.gd:48, build_hud_panel.gd:53
- `headline_added`, `ticker_live_line`, `mentor_advisory_changed`: yayan `sprint_bridges.gd:117`, `:89`, `:134` · haber bandı ve Frank satırı
- `module_unlocked`: yayan `scripts/events/core/engine.gd:270` (`EvDelays.module_openings`, ModuleLocks'u okur) · olay motoru `signals.gd:41`
- Dinlenenler: `sprint_system.gd:1290-1308` (`event_resolved`, `hr_day_processed`, `character_removed`, `assignment_changed`, `employee_hired`, `training_started`, `TimeManager.speed_changed`)
- Dinlenenler: `incident_system.gd:313-314` (`event_resolved`, `clock_batch_ended`); `sprint_system.gd:1864` (`clock_batch_ended`, tek seferlik)

## Durum ve veri

- `GameState.product` `scripts/autoload/game_state.gd:302`: sprint, next, mode(plan|active|release), cards, release, releases, requests, rival_hits, quarter, decision, delegate… (`new_state` sprint_system.gd:74-84)
- `GameState.product` ek alanlar: `interrupt` {sprint, kind} (sprint_system.gd:564), `promise_due` {card, step, promises}, `type_draft`, `pending_faulty`, `empty_sprint`, `decision_sprint`
- Koşan kartta `progress_at_start`: sprintin başındaki `progress` (`_begin`, `put_first`; eski kayıtta `progress` okunur)
- Çeyrekte `quarter.start_day`: çeyreğin başladığı gün (`new_state`, `plan_next`; eski kayıtta sprintin başından geri sayılır)
- Kart `SprintCatalog.new_card` `sprint_catalog.gd:250`: id, kind(feature|request|fix|research), line, step, target_tier, area, need[3], progress[3], state, assignees, bugs, decision, cut
- Kart kimlik önekleri `sprint_catalog.gd:194-222`: `feat:<kademe>`, `req:<talep>`, `plan:cap_paid_plan`, `fix:<hat>`, `res:<alan>`; kart `need`/`progress` sırası [Tasarım, Geliştirme, Test]
- Sürüm kaydı `sprint_system.gd:1490-1484`: number, sprint, shipped, carried, velocity, expected, actual, press, gate, day, changed_areas, alerts_cleared, faulty (+ `thanks`, `reviews`)
- `GameState.incident` `game_state.gd:329`: last_day, pending, shifted, open, drains, forced (şema başlığı `incident_system.gd:32-34`)
- `GameState.flags` `mvp_*` (`FLAG_TYPES` `game_state.gd:48-91`; adlar `product_state.gd:11-39`): mvp_shipped, mvp_version, mvp_line_tiers, mvp_open_bugs, mvp_infra_*, mvp_interest…
- `GameState.trust_drains` `game_state.gd:325` (B2BSalesSystem yazar): `IncidentSystem.resolve` "per_sprint" bedelini oraya ekler (`B2BSalesSystem.add_trust_drain`)
- Ar-Ge durumu `rnd_system.gd:40-49` (kayıt `to_dict` :759, `systems.rnd`): states, progress, active, assignees, paid, freeze_job, note_*; `_was_frozen` kayıt dışı (:53)
- Kayıt: `SCHEMA_VERSION` 19 (`save_manager.gd:16`), `MIN_LOADABLE_VERSION` 10 (:23); göçler `_migrate_15` :825, `_migrate_16` :911, `_migrate_18` :977 (v17 → v18 `market_ref`), `_migrate_19` :1010 (sprint puanı ×5)
- Kayıt sistem blokları `save_manager.gd:379-380`: `systems.product` ({support}) ve `systems.rnd`; ürün/sprint/incident `game_state` bloğunda
- `data/product/sprint.json` blokları: effort :5, need :7, roles :16, request :40, pm :41, decision :42, paper :43, incident :50, paid_plan :79, impact :80, thanks :82, reviews :83, areas :132
- `data/product/lines/*.json`: `subtype`, `lines[]` (id, profile design|dev|test, 3 kademe: effort, usage_weight, license_cost, requires{research,person,total}); `shared.json` 4 hat
- `data/techtree/rnd_tree.json`: `k_arge` :7, `report_period_weeks` :8, `nodes` :10 (19 düğüm), `hidden_lines` :38 (4 hat, yalnız `line_hidden_self_serve` yazılı)
- Sabitler: `SprintSystem` :14-24 (`HOLD_PLAN`, `CRUNCH_MULT`, `MVP_HORIZON`); `ProductQuality` :10-44 (`FIT_SCALE`, `RATIO_CAP`, `CLOSE_CURVE`, `AUDIENCE_STARS`)
- Sabitler: `InfraSystem` :15-68 (`LOAD_AMBER` 90, `LOAD_OVER` 100, `AUTO_EDGE` 80, `AUTO_TARGET` 65); `ProductLines` :17-41; `ResearchTree` :22-56 (`CASH_TABLE`, `STARS_BY_PLACE`)
- Statik, kayıt dışı: `ProductLines.memo` (:53), `ProductRead._prev_*` (:132), `IncidentSystem.rolls` (:51), `ProductState.bugs_free` (:220), `ModuleLocks._override` (:12)
- Hata modeli (`SprintBugs`): kartın beklenen hata yükü h0 = c × kartın puanı × R × tür × Σ iş payı × m(Δ) × TİTİZ, h = h0 × (1 − PM hazırlığı `prep_cut`); R kartın Geliştirme aşamasındaki Yazılım kapısı (kilitsiz kart 1★),
  ↳ Δ = kişinin Yazılım yıldızı − R; m(Δ) = `rate` × 0,5^(Δ ÷ `half_stars`) (0,20 ve 2; gereksinimin altında aynı eğri sürer); tür çarpanı özellik, istek ve ücretli plan 1,0, düzeltme kartı 0,3, araştırma 0; TİTİZ `bug_rate_mult` 0,5;
  ↳ Geliştirmeyi kimsenin yapmadığı iş (ör. karar kâğıdının ilerlemesi) Δ = 0 sayılır, ayrılmış çalışanın payı sayılmaz. Örnek: 40 puanlık, 2★ Yazılım kapılı kartı 2★ kişi yaparsa h 3,392, 4★ kişi yaparsa 1,696.
  ↳ Yakalama C = testi yapanların iş payıyla ağırlıklı 0,57 × √Y(Test) (Y `SprintSystem.skill_y`; kendi geliştirdiği kartı test eden ×0,6; kurucuya 2★ tabanı uygulanmaz); payda gereken testtir (`need` + `cut`);
  ↳ `settle(kart, rolled := true)`: n kartın tohumundan (koşu tohumu, sürüm numarası, kart kimliği; yerel RNG, `RngStreams` ilerlemez) Poisson(h) çekilir,
  ↳ her hata C olasılıkla bulunur ve ağır (5,3 puan, olasılık 0,18) ya da hafif (1,3) düzeltme işi taşır. Karta `born` (n), `found` (F) ve `fix` (bulunanların işi) yazılır,
  ↳ iş Geliştirme ihtiyacına eklenir (`phase` Geliştirme'ye döner) ve `tested` yazılır; `rolled` yanlışsa zar atılmaz (arayüzün tohumsuz okuması): n = h, F = h × C, iş = F × 2,02;
  ↳ `_close` kartın bıraktığı hatayı kartının hattına yazar (`pending_faulty`, sonra `_land_faulty`) ve sürüm kaydına `escaped` yazar; düzeltmesi bitmemiş kart sessizce sonraki sprinte devreder,
  ↳ gönderilmiş ve testi bitmiş kart düzeltmesi bitmeden çıkar
- PM hazırlığı (`SprintPrep`): PM sprint puanı üretmez (`team()`'de `points` 0, kapasiteye girmez, hiçbir karta atanmaz; araştırma kartını tasarımcı ya da kurucu yapar);
  ↳ haftasını sonraki sütundaki (`_ahead_cards`) hiç koşmamış (`state` `planned`) karar beklemeyen özellik ve istek kartlarını hazırlamaya verir. Devreden, düzeltme ve araştırma kartı hazırlanmaz; sütun boşsa PM'in haftası boşa gider.
  ↳ Hazırlık işi `need(kart)` = `share` (0,2) × kartın puanı; hız P(s) = 15 + 10 × √((s − 2) ÷ 8) puan/hafta (s Ürün puanı; 1★ 15, 3★ 22, 5★ 25, 1★ altında 7,5 × s) çarpı çalışma saati, verim, huy ve sprint payı (`SprintSystem.paced`).
  ↳ Kural A (`week`, `_own`, `_prepare`): kartlar K = puan × Yazılım kapısı büyükten küçüğe (eşitte sütun sırası), PM'ler Ürün puanından aza (eşitte kimlik) dizilir;
  ↳ PM'in payı sprintin sonuna dek kalan hazırlık kapasitesidir (hızı × (1 + kalan hafta), sahibi olduğu kartların kalan işi düşülmüş).
  ↳ Sahibi olmayan kartlar K sırasıyla payların oranında ardışık dilimlenir (en karmaşık dilim en iyi PM'e);
  ↳ kartın Ürün kapısını (`SprintBugs.gate(kart, product)`) geçemeyen ya da payı kalmayan PM'in kartı en yakın uygun PM'e (eşitte daha yıldızlıya) kayar, hiçbiri uygun değilse sahipsiz kalır; bir kartı tek PM hazırlar,
  ↳ hazırlayan (`prep_by`) ekipte durdukça değişmez. Fayda hazırlayan PM'in yıldızındandır ve hazırlığın biten oranıyla orantılıdır: `prep_done` (0..1), `prep_gain` = Σ pay × hız kazancı (1★ %10, 5★ %25, doğrusal),
  ↳ `prep_cut` = Σ pay × (1 − hata çarpanı) (1★ ×0,90, 5★ ×0,60); hız `SprintSystem._work`'te kartın her aşamasında (1 + `prep_gain`) katıdır (`need` ham kalır), hata yükü `SprintBugs.expected`te (1 − `prep_cut`) katıdır.
  ↳ Plan oynatması (`_play_out`) ve gerçek hafta (`_end_week`) aynı işlevi çağırır, hazırlayan PM o hafta `worked` sayılır; alanlar varsayılanla okunur, şema artmaz.
  ↳ Vakalar `sprint_skill_assignment` (kural A) ve `sprint_pm_prep_benefit` (hız, hata, yarım hazırlık)

## Metin anahtarları

- `PRODUCT_*` (80 aile, 278 anahtar): Ürün sayfası, sprint kartı, sürüm notu, sunucu bloğu; okuyanlar `scripts/tabs/product/*.gd`, `product_tab.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`, `sprint_system.gd`
- `PRODUCT_SERVER_*` (37 anahtar): sunucu/kapasite arayüzü: `overview_view.gd`, `product_model.gd`, `main.gd`
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
- Lider: `sprint_lead_fills_next_column` (öneri sonraki sütunu da doldurur: tavan, sıra, onaysız PM planı, devir), `sprint_lead_fills_to_ceiling`, `sprint_lead_row_until_plan_changes` (bayrak ve satır;
  ↳ işe alım satırı geri getirir, kayıttan dönen sprintte değişimsiz HR günü getirmez)
- Plan tutuşu: `plan_opens_at_work_start` (gece kapanan sprintin planı mesai başlangıcında saati tutar: 10:00 mesaisinde 08:00 ve 09:00'da saat akar, 08:00 mesaisinde hemen; adım adım ve toplu adımda);
  ↳ `sprint_starts_only_with_consent`, `delegate_needs_pm` ve `sprint_team_follows_job_matrix` saati `_at_work_start` ile mesai başlangıcına koyar
- Sprint ekranı sözleşmesi (`ProductModel`): `center.capacity` aşama başına {stage, work, team, done, out, out_inside, streak, hot, shared, stays, people, away,
  cluster}; ayrıca `center.suggest`, `crew`, `team_empty`, `delegate` {on, pm (yüz ya da null: devret kilitli)}, `progress` {done, total, known} (koşarken; saatlik güncelleme `ProductModel.progress_at(aşama listeleri, known, an)`),
  ↳ `can_start` (planlamada ve ekip varken; kartsız da açık), `start_skips` (başlatılacak kart yok: "0 kart", başlat `skip` çağırır), `start_reason` (ekip yokken gerekçe); `quarter.goal` {area_id, area_name, meter}.
- Sağ sütun sözleşmesi (`ProductModel`): `prep.pms` [{person, stars, cards, preparing}]; `next` {sprint, cards, load, carried}; `next.cards` {id, kind, name, effort (aşama paylarının toplamı),
  ↳ parts [{stage, effort, done, people}], prep {pm, done} ya da null, buttons}; sürüm notunda devredenler kartlarda değil `carried`tadır, kapısı kapanan kart yalnız "×" alır; `next.flags` yoktur.
  ↳ `SprintNext` HAZIRLIK'ı ve sonraki sprint kutusunu, `SprintFoot` alt şeridi çizer; ÇEYREK'in mini kartı `ProductModel._next_minis` ve `_card`tan gelir.
- Pano sözleşmesi (`ProductModel`): `center.cards` kart satırıdır {id, kind, name, effort, raw_effort, module, fix_text, slot ({kind: due|carried|late} ya da {}), pm, ask, risk, risk_raw, late, founder, buttons, stages}
  ↳ (`_row`; `stages` zaman ekseninin aşamalarıdır, kapısı sonradan kapanıp başlamayacak kartta boş); `effort` kartın sprintteki yükü ÷ hazırlık kazancı, `risk` = H ÷ H_ref (`SprintBugs.ceiling`), `risk_raw` hazırlanmamış hâli;
  ↳ `center.candidates` kartsız planın ilk üç önerisi (aynı satır biçimi, her biri tek başına eklenmiş gibi oynatılır), `center.people` panonun yüzleri {kimlik: kişi + parçaları}, `center.close_at`, `center.now_at`;
  ↳ `ProductModel.now_at(mode)` şimdiki an (sprint başından hafta), `stage_done(aşama listeleri, an)` Kapasite'nin "yapılan"ı, `ghost_row(kart)` imlecin adayının satırı (sayfayı kurmadan panoya girer),
  ↳ `desk_stamp()` sayfanın saat içinde sinyalsiz okuduğu masa ve ekip hâli (sekme saatlik `desk_changed`ta karşılaştırır). `PLAN_KEYS` ve `NEXT_KEYS`: koşarken kartta düğme yok.
- Silinenler: `SprintCatalog.lead_sentence`, `PRODUCT_LEAD_ONE/TWO/REQUEST/TIP/APPLY`, `PRODUCT_WEEK_OF`, `_IDLE*`, `_ROLE_MISSING`, `_OVER_CAPACITY*`,
  `_EMPTY_SPRINT`, `_PM_STARTED`, `_PERSON_SHARE`; eski `center.{team,warning_text,idle_text,lead_tip,pm_started,empty,can_add}`.
- Silinenler (pano): eski `center.cards` biçimi, `center.forecast`, `center.status`; kart alanları `phases`, `phase_pts`, `assignees`, `queued`, `decision`, `effort_split`, `spills`, `no_start`, `planned_done`;
  ↳ `SprintCatalog.forecast` ve `_on_time`, `SprintUiShared.forecast` ve `phase_dot`, `SprintCard`ın geniş kipi (`Look.WIDE`: faz satırı, karar satırı, efor kutusu); anahtarlar `PRODUCT_STATUS`, `_STATUS_RUNNING/QUEUED/DECISIONS/WAITING`,
  ↳ `PRODUCT_AT_SPRINT_END`, `PRODUCT_FX_BUGS_CLOSED`, `_FX_ON_TIME`, `_FX_PROMISE_KEPT`, `PRODUCT_EFFORT_POINTS`, `_EFFORT_PERSON`, `PRODUCT_WEEKS`,
  ↳ `PRODUCT_CARD_SPILLS_PTS`, `_CARD_NO_START`, `PRODUCT_DECISION_HALTED`, `_DECISION_IN_INBOX`,
  ↳ `PRODUCT_GO_DECISION`, `PRODUCT_QUEUED`; smoke `sprint_fix_preview_matches_close` önizleme iddiasını bırakıp `sprint_fix_close_matches_note` oldu, `sprint_request_on_time_met` önizleme satırını bıraktı.
- Silinenler (alt şerit ve sağ sütun): `SprintCard`ın sonraki sütun görünümü (`Look` enum'u, etki satırı, etiketler, kilit satırı, tuşlar), `SprintUiShared.effect_line`, `_part`, `word_color`, `LEVEL_KEYS`, `key_button`, `key_variation`,
  ↳ `KEY_GLYPHS`; model: `center.plan_hold`, `center.next_version`, `next.flags`, kart alanları `roles`, `effect`, `locked_node`, `locked_rnd`, `ready`, `priority`, `buttons` (ÇEYREK kartı `{id, name, kind, effort, state, remaining}`),
  ↳ `BUTTONS`, `_locked_rnd`; `SprintPanel`ın `Column` kaydırması, `_next`, `_way_out`, "Bu sprinti boş geçir" ve onay satırı, `UiTokens.D_SPRINT_COLUMNS`, `CardKeyText(+Idle)`, `SprintCard(+Hover)` varyasyonları
  ↳ (`SprintCardPlanned` kalır: kayıt listesinin yeni yuvası okur);
  ↳ anahtarlar `PRODUCT_SKIP_SPRINT`, `_SKIP_CONFIRM`, `_START_NEED_CARD`, `_PLAN_HOLD`, `_NEXT_RELEASE`, `_IN_WEEKS(_ONE)`, `_NEXT_EMPTY`, `_CARRIED`, `_PRIORITY`, `_PROMISED`, `_CARD_READY(_PCT)`,
  ↳ `PRODUCT_FX_HOLDS`, `_FX_ALERT_CLEARS`, `_FX_REQUEST`, `_FX_RESEARCH`, `_FX_PROMISE`; fikstürün `fix_long_name` ve `b2b_no_requests` edge'leri. `SprintCatalog.card_effect` smoke okuduğu için kalır.
- Kâğıt/karar/söz: `sprint_decision_blocks_progress`, `decision_one_per_sprint`, `paper_interrupt_order`, `paper_card_trim`, `paper_line_harden`, `promise_due_fires_when_late`, `promise_extend_once`, `promise_cut_test_escape`
- Acil durum/sunucu: `incident_gap_and_spread`, `incident_night_hold_resumes`, `incident_scale`, `incident_save_roundtrip`, `incident_gates`, `infra_capacity_moves_both_ways`, `auto_capacity_grows_only`, `capacity_step_immediate`, `infra_price_lock`
- Hat/kalite: `product_lines_catalog_loads`, `line_k3_locked_without_research`, `product_fit_table`, `product_quality_sector_table`, `product_line_profiles`, `product_area_row`
- Ar-Ge: `research_node_map_binds`, `rnd_tree_loads_and_validates`, `research_freezes_and_resumes`, `research_abandon_keeps_progress`, `rnd_note_author_and_lines`
- Kayıt: `sprint_save_roundtrip`, `save_v14_build_becomes_sprint_plan`, `save_v19_running_sprint_continues`, `save_v10_product_state`, `save_retired_product_flags`
- Harness: `--sprint-probe=hours=<h>:cards=<1|2>:ticks=<t>[:market=…][:incident=<tür>@<tik>][:promise=1][:team=<n>]` (`main.gd:258`, `sprint_probe.gd:3`) basar `SPRINTPROBE` satırları
- Harness: `--sprint-probe` (`scripts/debug/sprint_probe.gd`, sınıf adı yok, `main.gd`'de `SPRINT_PROBE`) kurucunun `note_tool` koşusunu tohum tohum oynar; bilinmeyen anahtar
  ↳ `SPRINTPROBE ERROR` basıp 1 ile çıkar. Anahtarlar: `hours=<h>` şirketin çalıştığı saat, `start=<saat>` başlangıcı (yoksa oyunun varsayılanı),
  ↳ `cards=<1|2>` plana alınan kart sayısı (devredenler kalır, açık Çekirdek K1'ler efor sırasıyla `add` ile), `ticks=<t>` koşu süresi; `seeds=<n>` ve `seed=<n>` tohum `seed`, `seed+1`, … üzerinde n koşu;
  ↳ `events=0|1` (0: yalnız sprintin günlük adımı, karar kâğıdı yok; 1: bütün saat toplu adımlarla koşar, kart geceyi durdurur, masayı `RunProbe` cevaplar, kâğıt ihtimali `decision.sprint_chance`, `rate=<r>` onu ezer);
  ↳ `lead=1` liderin planını alır;
  ↳ `gate=publish|more` MVP kapısında yayınlar (varsayılan) ya da ilk kapıda Bir sprint daha der; `fill=1` her açık kartı "+" gibi alır (`SprintCatalog.open_cards`, `cards=` okunmaz);
  ↳ `team=N` kurucuya N-1 orta becerili çalışan ekler (1 ile 6: `RunProbe.SMALL_CREW` sırasıyla, `team=4` geliştirici, tasarımcı ve testçi; 12, 25, 50: `RunProbe.seed_crew` karışımı, yıldızlar tohumdan;
  ↳ başka sayı `SPRINTPROBE ERROR` basıp 1 ile çıkar); `market=b2c|b2b` (b2b erp'yi seçer, ürün canlı olunca ikisi gece vardiyalı dört hesap imzalar); `incident=<tür>@<tik>` (`outage`, `month_close`, `checkout`, `regression`,
  ↳ `storm`) o tikin zarını o türün olayı yapar, türün ihtiyacı olan hata, ücretli plan ya da kitleyi bir tik önce kurar (ürün canlı ve lansman sonrası sessiz haftalar geçmiş olmalı:
  ↳ `fill=1` ile koşu o kadar sürer; MVP kartları tek başına 4. tikte biter); "Sprinti durdur" cevabı planı yeniden okutur (`REPRED`); `promise=1` (`market=b2b`,
  ↳ hesaplar imzalanınca) bitmeye en yakın kartın kademesine en büyük hesaptan o sprint için söz verir: kart söz olayını getirir, cevabı planı yeniden okutur; `tstar=` ve `pmstar=` (1 ile 5) bütün testçilerin ve PM'lerin yıldızı;
  ↳ `plus=<rol>@<yıldız>` bir kişi daha; `founder=0` kurucuyu sprint ekibinden çıkarır (`GameState.set_founder_in_sprint(false)`); `meetings=<n>` (`events=1`) kurucu her haftanın ilk saatinde giriş kapısının izin verdiği kadar,
  ↳ en çok n satış görüşmesine oturur; `queue=<n>` her sprint planlanınca n açık kartı sonraki sütuna gönderir (PM'ler hazırlar);
  ↳ `fixture=iz1|iz1b|iz2` küçük ekibi elle kurar (iz1: 4, 3, 3 yıldızlı üç geliştirici, kurucusuz, bir büyük ve iki küçük kart, `ticks=4`; iz1b büyük kart sonda; iz2 kurucu, 3★ geliştirici, 2★ tasarımcı, 4 kart);
  ↳ `build=demo|ea|full` o yapının kartları ve sonları; `planms=1` tik oynamaz, `SPRINTPROBE PLANMS|team=|cards=|what=|n=|median_ms=|max_ms=` basar: `what` `plan_outcome`, `can_add` (açık aday başına), `mvp_eta`, `lead`,
  ↳ `screen` (`ProductModel.live`, "+" ertelenmiş), `screen_total` (ilk kare ve ertelenen bütün `can_add`'ler), `ghost` (aday başına `timeline([aday])`). İlk çağrı ısınma, sonra 9 çağrı;
  ↳ ertelenen her değer `can_add(id)` ile karşılaştırılır, uyuşmazlıkta `PLANMS|ADDABLE` basılır ve çıkış 1; `fill=1` en dolu plan
- Harness: `SPRINTPROBE` kayıtları: `PRED` ve `CLOSE` kartın testinin hatasını `bugs=<n>/<F>/<K>/<düzeltme işi>` taşır (testi bitmemişse `-`); `SKIP` (`full|ceiling|empty`), `MVP`,
  ↳ `LOAD` (kapanan sprint: planlanan, biten kart, boşta kalan kişi-hafta, planın durduğu yer `ceiling|full|pool|cards|lead`), `SUMMARY` (`match=`, `mvp_days=`),
  ↳ `LOADSUM` (koşunun `LOAD` toplamı; `team=` oturan sprint ekibi), `PAPER|<tohum>|<sprint>|<kâğıt>|<konuşan>` (istenen karar kâğıdı; konuşansız kâğıtta `-`) ve
  ↳ `PAPERSUM|weeks=|sprints=|papers=|empty=|empty_rate=` (kâğıtsız sprint oranı); `CLOSE` `MATCH|MISMATCH`;
  ↳ olayla değişen girdide `cause=<olay kimliği>`, `cause=team`, yalnız kurucunun payı değiştiyse `cause=founder_meeting`, başlatma düzeltme kartının boyutunu hata deposundan yeniden okuyup planı değiştirdiyse `cause=bugs`;
  ↳ kapısı kapanıp başlatmada sonraki sütuna geçen kart için başlatılır başlatılmaz tek `CLOSE` basılır ("puan almaz" doğrulanır). Kapanıştaki `CLOSE` satırları sonuçtan önce `out=<tasarım>/<geliştirme>/<test>|streak=<…>` taşır:
  ↳ sürüm kaydının `overflow`'u, sprintin bilgisi olduğu için sprintin her kartının satırında aynıdır, karşılaştırılmaz; `mvp_eta` yalnız `PRED`'in son alanında basılır, gerçek MVP tiki `MVP` satırındadır; adsız uyuşmazlıkta çıkış 1
- Harness: `--product-shot=<c1..c5|flow|edge:<ad>|live:<tür>>` (`main.gd:257`), `--rnd-shot=<tür>` (:264), `--inbox-shot=rnd_note` (:252), `--event-shot=<sprint kâğıdı>`
- `--product-shot=<c1..c5|flow|edge:<ad>>` debug fikstürüyle (`scripts/debug/product_fixtures.gd`; kaynak sol sütuna `modules` ve `requests` vermez: sol sütun kareleri `live:a4_*` türlerindendir); `flow` başlat,
  ↳ ilerlet ve sonraki plan karelerini sırayla çeker; bu sprintin kartları fikstürde yalnız Kapasite'nin yükünü kurar, pano çizilmez (U7'de fikstür emekli olur); `edge:` adları: `quarter_no_pm`, `history`, `history_empty`,
  ↳ `goal_menu` (hedef menüsü açık), `approved` (çeyrekte onaylanmış sütun), `cap_zero`,
  ↳ `team_none` (kadro var ama sprint ekibi boş: kartlar planda, başlatma kapalı, gerekçenin yanında Ekip'e git); `over_100`, `over_125`, `empty_start`, `no_release` (MVP öncesi sürüm notu),
  ↳ `gate` (MVP kapısı; fikstürün `publish`'i v1.0 notuna çevirir), `mvp`,
  ↳ `release_fix` (sürüm notunda "Kesinti düzeltmesi · 9 → 0 açık hata" ve "6 → 1");
  ↳ `release_reviews` (B2C güncellemesinin sürüm notunda "Sürüm sonrası öne çıkan yorumlar": adlı yeni özellik, düzeltme ve güncellemeyi suçlayan olumsuz yorum, kaynaklarıyla).
- `--product-shot=live:<tür>` sprint motoruyla kurulan koşuda (`main.gd` `_seed_product_live` `:3902`): `pick`, `pick_named`, `pick_relang`, `plan`, `active`, `decision_paper`, `b2c_mvp`, `b2c_live`, `b2c_goal`, `b2b_mvp`, `b2b_mature`,
  ↳ `b2b_quarter`, `b2b_requests`, `gate`, `delegate`, `delegate_rehire`, `rnd`, `solo15`, `solo15_tip`, `solo12_active`, `overview_pre`, `server_*`, `a4_*`; `pick*` ürünü türsüz bırakır (tür seçici); `pick_named` B2C, tür ve adla;
  ↳ `pick_relang` aynısı, sonra koşu İngilizceye geçer ve yeniden kurulan seçici seçimi korur (`<kök>_rebuilt`). Tek kurucunun dünyaları (09:00'dan yalnız kurucu):
  ↳ `solo15` ve `solo15_tip` 15 saatte Sprint 1 planı (`solo15` liderin planı uygulanmış; `solo15_tip` yalnız önerilmiş), `solo12_active` 12 saatte liderin iki kartı koşarken (30/28, biri Sırada).
  ↳ Kalan türler HR shot kadrosuyla kurulur (`gate` ve `rnd` kurucu tek): `plan` Sprint 1 planlaması, liderin planı uygulanmış ve sonraki sütunda ilk açık kart (tasarım ona önden gider, PM hazırlar),
  ↳ karesi Sprinti başlat sonrasını (`<kök>_start`) da çeker; `active` aynı kart koşarken;
  ↳ `decision_paper` ikinci haftada masada bir sprint kâğıdı (ihtimal 1, konuşan kartta çalışan yazılımcı), kartın "?" yuvasıyla açılan Olaylar (`decision_paper:<kart id>` gerçek bir kâğıdı ister);
  ↳ `gate` MVP kapısı ve Yayınla sonrası v1.0 notu (`<kök>_publish`); `rnd` kurucu Ar-Ge'deyken planlama ve Ar-Ge'ye git sonrası düğümü seçili Ar-Ge (`<kök>_go`); `b2c_mvp` yayınlanan CANLI v1.0 sürüm notu; `b2c_live` aynısı,
  ↳ dört hafta oynanır (kitle saat saat akar, her sprint kendiliğinden başlar), Geçmiş açık, `SHOT|b2c users=<n> paying=<n>` ekrandaki sayılara eşit; `b2c_goal` yayından sonraki planlama: lider önerisi sunulmuş,
  ↳ öneri hedefsiz uygulanmış (`<kök>_lead`), liderin kartları geri alınıp hedef Güven seçilince yeniden uygulanmış (`<kök>_trust`); `delegate` devirle PM'in başlattığı Sprint 2; `delegate_rehire` o PM yayından sonra ayrılmış,
  ↳ yerine yeni PM gelmiş: devret anahtarı kapalı, Sprint 2'nin planlaması oyuncuyu bekler; `b2b_mvp` ERP'nin v1.0 notu (Çekirdek Zayıf okunur, cümlesi 1★ şirketlere yettiğini söyler);
  ↳ `b2b_mature` bütün hatları ikinci kademeye çıkarıp sonraki planlamayı açar (her alan 3★ cümlesini okur); `b2b_quarter` `delegate`'in ERP'deki hâli,
  ↳ ÇEYREK açık (MVP'den hemen sonra PM'in hedef şeridi: sıradaki yıldızın beklentisine oran, boş alanlarda 0 kare); `b2b_requests` iki hesap imzalanır, bir sprint daha oynanır, sonraki planlama talep kartlarını taşır;
  ↳ `overview_pre` v1.0 öncesi planlama, imleç kilitli GENEL BAKIŞ sekmesinde (`<kök>_tip`); `server_*` v1.0'dan sonra ERP'nin GENEL BAKIŞ'ı (`_seed_server`: tek hesap, 20 birim, Standart): `server_80`, `server_94`, `server_104` yük %80,
  ↳ %94, %104 (imleç Artır ya da Azalt'ta, `<kök>_tip`), `server_growth` büyüme satırı, `server_auto` anahtar açık ve son otomatik büyüme, `server_tier` Kurumsal önizlemesi açık (imleç Standart'ta),
  ↳ `server_final` Kurumsal'dayken alt kademeler kilitli (imleç Ekonomik'te), `server_clause` tek hesap 3★ ve sözleşmesinde sunucu maddesi açık (bloğun altında "Kurumsal sunucu bekleyen 1 hesap" etiketi),
  ↳ `server_lock` 10 haftalık sunucu sözleşmesi sürüyor (kademeler ve Azalt kapalı, ipucu sözleşmenin gerekçesi; imleç Azalt'ta), `server_b2c` not uygulaması,
  ↳ 12.400 kullanıcı 13 birimde (%96)
- `live:a4_*` sprint ekranının kare dünyalarıdır (27 tür; `_seed_product_a4` `main.gd:4070`, tablo `_A4_WORLDS` `:4036`): kurucu tek başına ERP'yi v1.0'a oynar, kadro sonra işe alınır, hesaplar imzalanır, önceki sprintler oynanır;
  ↳ her tür kurulunca `PRODUCTSHOT|kind=|cards=|people=|row_gaps=|now=` basar; `row_gaps` zaman ekseninin bütün kart satırlarındaki boşluk sayısıdır (`SprintTimeline.row_gaps`, smoke'un Z3'üyle aynı işlev),
  ↳ `now` koşan sprintte şimdiki an (sprint başından hafta, değilse 0);
  ↳ plan kartları `SprintCatalog.card_need` ile ekibin kapasitesinin bir katına büyütülür (`load`: altı kişide 1,15, on bir kişide 1,25, on iki geliştiricide 1,3, on dört kartta 1,6),
  ↳ çünkü katalogun açık kartları (yaklaşık 195 efor) on bir kişiyi kendiliğinden taşırmaz; `a4_solo` v1.0 öncesi Sprint 1, yalnız kurucu, haftasında bir görüşme (1 gün tarama); `a4_devs3` üç geliştirici (3, 4, 2★),
  ↳ kurucu anahtarı kapalı; `a4_six_hover` kurucu, tasarımcı, iki geliştirici, testçi ve 5★ PM, taşmayan 5 kartlık plan, hedef yok, imleç bir adayın "+"ında; `a4_six_pm5` ve `a4_six_pm2` aynı altı kişi, PM 5★ ve 2★;
  ↳ (önceki sprintte PM iki kartı hazırladı, tasarımcı önden çalıştı, plan kapasitenin %115'i, bir düzeltme kartı); `a4_eleven` 11 kişi (kurucu, 2 tasarımcı, 6 geliştirici, 2 testçi), kurucuya term sheet masası, plan %125: test sığmaz;
  ↳ `a4_eleven_streak` aynı ekip, iki taşan sprint oynanmış, üçüncüsü de taşar; `a4_two_pm` 11 kişi, iki PM (5★ ve 2★) kartları paylaşıp hazırladı, kurucuya satış görüşmesi;
  ↳ `a4_fifty` 50 çalışan (3 PM, 5 eğitimde, 1 izinde, 1 araştırmada, 6 yalnız Destek'te), kurucu anahtarı kapalı, planlama PM'e devredilmiş; `a4_run_w2` `a4_six_pm5`'in ekibi, düzeltme kartsız planı başlamış, 2. haftanın açılışı,
  ↳ bir kartta karar kâğıdı; ikinci kare `<kök>_02` iki oyun saati sonra (şimdiki an 1,00 → 1,25; `PRODUCTSHOT` ikinci kez basılır, ikisi `now=` taşır);
  ↳ `a4_eleven_tip` 11 kişi, aynı adlı (soyadları farklı) iki geliştirici, en uzun İngilizce adlı altı kart (dördü talep kartı), imleç konmaz (kare 14 `--lang=en` ile); `a4_twelve_dev` 12 geliştirici,
  ↳ 2 tasarımcı, 2 testçi, kurucu kapalı, plan %130: üç aşama taşar; `a4_fourteen` 11 kişi, dört düzeltme kartı, 14 kartlık plan (%160); `a4_requests` beş kişi, kurucu kapalı,
  ↳ dört hesabın dört açık talebi (motor bir hat için bir talep verir, bu ERP'de en çok dört); `a4_empty` altı kişi, bir geliştirici eğitimde, boş plan; `a4_run_end` aynı ekibin düzeltme kartsız sprinti 2.
  ↳ haftanın sonunda (sonraki sütunda iki kart), tasarımcı sonraki sütunun kartında önden; `a4_next_prefilled` onun sonraki planlaması: devreden test, önden yapılmış tasarım, plan erken biter; `a4_early` altı kişi, iki kartlık plan,
  ↳ sprint 1. haftanın sonunda kapanır; `a4_first_sprint` v1.0 öncesi Sprint 1: tasarımcı, 5★ geliştirici, kurucu (en çok çalıştığı Geliştirme satırında), sonraki sütunda iki kart; `a4_first_next` onun ardından Sprint 2 planı;
  ↳ `a4_six_founder_off` `a4_six_pm5`'in planı, kurucu anahtarı kapalı; `a4_six_meetings2` aynı plan, kurucunun haftasında iki satış görüşmesi; `a4_run_table` `a4_eleven`'ın sprinti 1. haftanın ortasında, masa 2 gün tarar;
  ↳ `a4_run_delegate` `a4_run_end`'in sprinti, planlama PM'e devredilmiş (şeritte "{PM} planlıyor" ve ilerleme); `a4_cards_noteam` tasarımcı, geliştirici, testçi ve 5★ PM,
  ↳ kurucu kapalı, üç kartlık plan, plandan sonra PM dışında herkes izinde (`away`; şeritte "Ekip'e git"); `a4_delegate_noteam` aynısı, planlama devredilmiş;
  ↳ `a4_run_delegate_long` `a4_run_delegate`, PM'in adı havuzların en geniş adı (`pm`: "Jordan Bennett"; şeridin en dar hâli)
- `--event-shot=<bir sprint kâğıdı>` kâğıdı canlı bir ürünün bir kartlı sprintinde kurar (`main._seed_paper_world` `:1036`; kartı bir özellik kartı, B2B pm ve geç kalan sprint kâğıtlarında Marmara Lojistik'in talebi,
  ↳ kök neden kâğıdında hatalı hattın düzeltme kartıdır)
- Probe kayıt türleri (Ürün): `SPRINT` (her kapanış: sprint, etiket, çıkanlar, devredenler, hız), `SHIP` (sürüm çıkaran kapanış: kapanıştan sonra açık hata, `escaped=` testten kaçan hata sayısı),
  ↳ `FIX` (her sprint başı: düzeltme kartlarının kalan puanı, kapasite, pay, hata sprinti mi), `BUGS` (haftalık: gelen yeni hata, açık hata, kapanıştan hemen önceki açık hata);
  ↳ `BUGS`'ın yanında `LINES` (hat başına açık hata) ve `AREAS` (pazarın her alanı: yuvarlanmamış `ProductQuality.level` / hat sayısı / rakip penceresi içindeki çıkış), `FIXTURE`, `STATE` içinde `open_bugs=`,
  ↳ `q=` ve `lost=` (kaybedilen hesap); `PLAY` (`_plan_the_sprint`: tür seçimi, MVP kapısında `publish`, liderin önerisi ve başlatma). Bot sprintte yalnız öneriyi kullanır (söz kartları ve ücretli plan önerinin basamaklarıdır),
  ↳ düzeltme kolları ve `k1_only` onu düzenler; başlatma satırı sonunda `actions=` planlama eylemleri (öneriyi uygula, kolların her ekleme ve çıkarması, başlat); `_run_the_company` Destek masası, araştırma ve kadro bakımı.
  ↳ Plan tutuşu hata değildir: `_run_sim` planı bekleyen sprinti oynanan koşuda `_plan_the_sprint`, öbür preset'lerde `_start_on_lead` (kapıda `publish`, sonra `plan_next`, `apply_lead`, `start`; `--tick-probe` de çağırır) ile başlatır;
  ↳ başlatamazsa `PROBE ERROR day=<n> plan unstartable`; `full_run*` alt-türü preset'in `subtype` alanıdır (`RunProbe.PRESETS`); `--tempo-probe`'un haftalık yolunu bir sprint besler (`TEMPO STATE` içinde `sprint=`, `mode=`, `done=`);
  ↳ haftalık destek raporu `PROBE END` `support_reports=<rapor gelen hafta>/<canlı üründe temsilcisi olan hafta>` ve `support_news=worst:n,cleared:n,shipped:n,priority:n,behind:n` basar (`RunProbe._count_support_report`)
- Probe kayıt türleri (Ar-Ge): `PLAY ... research` (`_run_research`); görsel `--rnd-shot=<tür>` Ar-Ge'nin zaman çizelgesinde (`main._seed_rnd`: dört araştırma bitmiş, Test Otomasyonu %36'da, 14. haftanın notu); `tree`,
  ↳ `detail` (AI Engine seçili), `detail_cash` (aynısı, kasa bedelinin altında), `assign` (atama paneli, Elif seçili), `frozen` (15. hafta, Selin ayrılmış, araştırma donmuş, Mert izinde),
  ↳ `detail_frozen` (Selin test işine geçmiş: donmuş araştırmanın kartı, sebebi, Vazgeç'i ve notu),
  ↳ `assign_founder` (sprint koşarken AI Engine'in ataması açık, kurucu işaretli, kart sonuna kaydırılmış: kurucu uyarısı; `RNDSHOT|assign_founder|mode=…`);
  ↳ `stars` (zaman çizelgesi yok, Ürün Yöneticisi ve tasarımcı kadroda yok, Tasarım Sistemi seçili: yıldız reddi ve işe alım bağlantısı; `rnd_shot_stars_hr` açılan Ekip penceresini çeker, `RNDSHOT|stars|window=…`), `history`,
  ↳ `history_empty`, `read_only` (karar beklerken), `closed` (v1 öncesi). Pencere yokken araştırma kartı: `card`, `card_frozen`, `card_build`, `card_none`, `card_gate`, `discovery` (16. hafta, keşif not yığınında),
  ↳ `discovery_design` (Tasarım Sistemi kimse yokken tamamlanır, kurucunun kendi keşfi not yığınından açılır) ve `first_note` (koşunun ilk aylık notu motordan gelir ve kutuda kendiliğinden açılır);
  ↳ `--inbox-shot=rnd_note|rnd_note_demand|rnd_discovery`
- Harness: `bash tools/run_gate.sh` presetleri `full_run_fix_{none,worst,due,off}` ve `full_run_b2c_fix_*` (`PROBE FIX/BUGS/STOP` satırları); `--why-fire=<kart>`, `--event-lint`
- Fikstürler: `scripts/debug/product_fixtures.gd`, `data/events/cards/_fixtures/paper_{dev,design,pm,founder,plain,crunch}.json`; smoke acil durum zarını kapatır (`endgame_smoke.gd:71`)

## Dikkat

- Oynatma tek yoldur: `plan_outcome`, `timeline`, `intake` ve `first_bumps` `_replay`i okur
- `_assign` kartın `pinned` alanını ({person, until}) okur: gün < until ve kart bitmemişse kişi yalnız o karta gider, onda ilk gelir, çalışamıyorsa kart o hafta kimsesiz; yazarı Olaylar'ın `pin_card`'ı, `_play_out` haftanın gününü verir.
  ↳ Kişi başına tek kilit vardır: `pin_card` kişinin başka karttaki kilidini kaldırır; sprintte olmayan ya da biten karta kilit yazmaz ("" döner). Alan kart sözlüğünde durur, kayıt sürümü artmaz
  ↳ Kilit kartla gider: sprintten çıkan kartın `pinned`ı silinir: `remove` `:125`, `decision_carry` `:470` ve kartı bu sprintten sonrakine gönderen `_place` `:1913` (`send_next` onun üstünden); smoke `sprint_pin_leaves_with_card`
  ↳ İleriki sprintleri sınayan `intake` (MVP tahmini, liderin sütunu) kilidi bugünün günüyle okur: sonraki bir sprintte biten kilidi o sprintin tahmini sürüyor sayar
- `_work`/`_play_out`/`_finish_sprint`in `log` parametresi yalnız `timeline` içindir; kapalıyken sonuçlar bayt eşit kalır (`--sprint-probe` `^SPRINTPROBE`)
- Zaman ekseni: testten sonra Geliştirmeye dönen düzeltme işi ayrı aşamadır (`fix: true`, sonda): testin bulduğu da, oynatmanın öngördüğü de oradadır (kartın gerçek bitişi); sayılar görünen efordur (kalan ihtiyaç ÷ hazırlık kazancı)
- Kartın eforu (`ProductModel._effort`: satırın `effort`ı, önerinin `effort`ı) oynanmamış karttan okunur: testin bulduğu düzeltmeyi sayar, oynatmanın öngördüğünü saymaz; aşama yükleri (`next.load`, `next.carried`,
  ↳ oluk) öngörüleni de Geliştirme'de sayar
- Gösterim kuralı: planlamada ve kartın testi bitmeden dördüncü parça çizilir ama ekranda da ipucunda da hata sayısı yazmaz (plan sayıyı bulur, göstermez); sayı test bitince kartın "Test: N hata buldu" satırıyla gelir.
  ↳ Hiçbir model alanı öngörülen hata sayısı taşımaz (`h`/`h0` göstergedir)
- Koşan sprintte eksen bu haftanın başındandır: önceki haftaların işi `done0`dır; eksenden önce biten aşama `before: true` ile gelir ve start = end = -1 olur, -1 tek başına "bu eksende aralığı yok" demektir
- Sonraki sütunun yükü her kipte aynı işlevlerden çıkar (`ProductModel._load`, `_carried`): planlamada ve koşarken devreden zaman ekseninin `out`u, sürüm notunda sonraki sütunun devreden kartlarının kalan ihtiyacı;
  ↳ planlı pay planlamada ve koşarken kartın sprint sonundaki kalan ihtiyacıdır (önden iş düşülmüş, `SprintSystem.prep_gains`in kazancıyla), sürüm notunda bugünkü;
  ↳ ekip satırları `SprintTimeline.row_power`dan (her satırın kişileri `SprintSystem.capacity_of`a)
- `remove()` kâğıdın takip kartını (`follow`) reddeder; `ProductModel._row` ve `_next_card` ona Kaldır düğmesi vermez
- Sol sütun `live()`ın `requests` ve `modules` alanlarını okur; `areas` yalnız çeyrek hedef menüsünün listesidir (`{id, name, goal_text}`), `customers` ve hat başına hata listesi yoktur (`bug_row_of` Destek raporunundur)
- Adayın `addable`ı `live()`da `null`dır: `ProductModel.resolve_addable` her karede en az bir `can_add` (8 ms) ister, `ghost` imleç "+"a gelince `timeline([aday])` kurar; ikisinin önbelleği her `live()`da atılır
- `area_sentence` ve türevleri (`_standing`, `_recent_hit`) ekranda okunmaz: tek okuyucusu `ProductQuality.area_row` (Genel Bakış'ın ürün durumu satırı için hazır, bağlı değil)
- İki ayrı efor tablosu: hat JSON `effort` (bant 5-7/7-9/9-12, `ProductLines.effort_of`, yalnız yeni-kod terimi ve doğrulama) ile sprint.json `effort` k1 15·k2 25·k3 40 (`SprintCatalog.step_effort` :171, kart eforu). Karıştırma
- `SprintCatalog.cfg()` (:29) eksik anahtarda sert hata verir (`v[key]`); sprint.json bozuksa `JSON.parse_string` null döner. Yeni anahtar eklerken okuyan her çağrı yerini birlikte ekle
- Tik sırası bir sözleşmedir (`time_manager.gd:383-432`): Ar-Ge bir tik gecikmeli okur (`rnd_system.gd:94-100`); IncidentSystem EventGate'ten sonra koşar; sırayı değiştirme
- Tek yazıcı: `GameState.product` → SprintSystem (SprintBridges yalnız `requests`, `rival_hits`, `thanks`); açık hata → `add_bugs`/`clear_line_bugs`; `GameState.incident` → IncidentSystem; sunucu → `ProductState.set_infra_*`
- Sunucu fiyatı olay çarpanlarından geçer: `unit_price` (`scale` parametresi çipin vaat ettiği faturayı önizler) tek çarpma noktasıdır, `monthly_bill`, ipuçları, posta ve bot ondan okur;
  ↳ `server_price` çarpanları üst üste bindirir (`mvp_infra_price_mult` her kademeye, `mvp_infra_tier_mult` yalnız adlı kademelere). `server_lock` sözleşmesi sürerken (`lock_reason() != ""`)
  ↳ `set_provider` Kurumsal dahil her kademeyi reddeder ve `set_capacity` imzadaki birimin altına inmez (`capacity_floor()`), büyütmek ve Otomatik ayar serbesttir; sözleşme `mvp_infra_lock_until`
  ↳ tikinde kendiliğinden biter. Kilidin gerekçesi `PRODUCT_SERVER_LOCK_REASON`dır, `{weeks}`i çağıran `Fmt.weeks(lock_weeks_left())` ile doldurur; sözleşmeyi imzalatan kart canlı üründedir (MVP'deki
  ↳ `set_provider` kilitten önce olur)
- Sunucu kapasitesini yalnız oyuncu ve Otomatik ayar değiştirir; `SprintBridges.on_release` ona dokunmaz (`sprint_bridges.gd:71`); dolu sunucunun tek bedeli kesinti ihtimalidir (`IncidentSystem.load_mult` incident_system.gd:75)
- Saat tutuşları: `sprint_plan` (`sprint_system.gd:22`), `incident` (`incident_system.gd:48`), `product_release_note` (`product_tab.gd:18`); toplu adımda `clock_batch_ended`'e ertelenir; harness zarı kapatmazsa saat takılır
- Kesinti sırası: söz olayı veya acil durum gelen sprintte kâğıt gelmez; kâğıtlı sprintte yalnız `SERVICE_DOWN` (outage, checkout) gelir, öbürü `incident.shifted`'e kalır (`sprint_system.gd:1258`)
- Reddedilen acil durum başlamamış sayılır: `last_day` yazılmaz, tutuş yok (`incident_system.gd:254`); zar yalnız karar verir, kart bir sonraki tam saatte istenir
- Ar-Ge ile Ürün kapıları farklı soru sorar: `LineGates` ham `HRSystem.skill` (izindeki de sayılır), `RnDSystem.area_has_star` etkin çıktı (:387); tek fonksiyona birleştirme
- `ResearchSeam.completed()` adı sözleşmedir (yeniden adlandırma); bilinmeyen kimlik `push_error` + false. `RnDSystem._complete` (:437) önce DONE yazar: gizli hat kaydı yeniden girebilir
- Yükleme sırası: `ProductSystem.from_dict` sonra `RnDSystem.from_dict`; gizli hatlar `ProductState.subtype()`'a bakar (`save_manager.gd:395-398`); çalışma anı hatları kayıt dışıdır
- Gizli hat: yalnız `line_hidden_self_serve` yazılı; öbür üçü `mvp_hidden_lines`'a işlenir ama tabloya kaydolmaz (`rnd_system.gd:490`); `ProductLines` hata metni "twenty" der, düğüm 19'dur (:233)
- Kodda okuyucusu olmayan: `cicd` (`bug_rate_ceil`) ve `test_automation` (`beta_decay`) etkileri; `LineGates.speed_bonus_for` (:126), `ProductCatalog.type_sector_labels` (:237), `RnDSystem.family_root_done` (:707)
- Eski/yalnız smoke: `ProductLines.ladder_refusal` (:420), `ProductCatalog.FEATURE_POOLS` düz havuzu (kalan okuyucu `b2b_sales_system.gd:561`); `ProductRead` işlevlerinin `_product_id` parametresi kullanılmaz
- `fix:<hat>` kartının hata sayısı ve eforu saklı değildir; `_refresh_fix_cards` (sprint_system.gd:1913) her tikte depodan okur, hattında hata kalmayan kart silinir; koşan kartınki başlatmada kilitlenir
- Paylaşılan hat kimliği ürün içinde `id@alt-tür`dür; kart verisi alt-türden bağımsız yazılır, `SprintCatalog.in_product` (:421) çevirir
- Göç adı ve koşulu aynı N'dir (`_migrate_18` `version < 18`, `_migrate_19` `version < 19`, `save_manager.gd:204-207`); sprint kartı şeması değişirse yeni göç ve `save_v*` vakası şart

## Bir değişiklik yaparken

- sprint.json sayısını/bloğunu değiştirirsen: okuyan `cfg("…")` çağrılarına, `sprint_probe.gd`, `product_fixtures.gd`, CLAUDE.md "[WORKING]" bölümüne ve bu sayfanın Durum ve veri bölümündeki hata modeli,
  ↳ PM hazırlığı ve probe satırlarına bak; puan birimi değişirse `SaveManager` göçü şart
- `GameState.product`'a alan eklersen: `new_state` (`sprint_system.gd:74`) + eski kayıt için varsayılan/göç (`save_manager.gd`) + `save_v19_running_sprint_continues`, `sprint_save_roundtrip` vakaları
- Yeni hat/kademe/alt-tür: `data/product/lines/*.json` + `PROD_LINE_*`/`PROD_STEP_*` (strings.csv) + `ProductCatalog.TYPE_SCREEN` + `rivals.json` + `ProductQuality.TABLE`; `loc_product_line_keys_resolve` koş
- Ar-Ge düğümü: `ResearchSeam.NODES` + `rnd_tree.json` (iki yönlü küme denetimi) + `PROD_RND_NODE_*` + `RND_*` metni; etkisini sahibi sistemde uygula (`ResearchSeam.completed`); `research_node_map_binds`
- Acil durum türü: `IncidentSystem.CARDS` (:37), `_allows` (:161), `_schedule` (:182), `plan`/`resolve` + sprint.json `incident` + kart JSON + `effects.gd:300` + `seams_incident.gd`; `incident_*` vakaları
- Kart/olay fiili (`sprint_*`, `line_harden`, `damage_product`): `effects.gd` liste (:43-48) ve uygulama (:476-525) + `--event-vocab` + `--event-lint` + çip (`events/present/chips.gd`)
- Yeni `mvp_*` bayrağı: sabit `product_state.gd` + `FLAG_TYPES` `game_state.gd:48` (yoksa kayıt tipini yitirir) + gerekiyorsa göç
- EventBus sinyali eklersen/silersen: `python tools/gen_signal_manifest.py`; olay tetikleyicisi olacaksa `scripts/events/core/signals.gd` BINDINGS (:23-41)
- Günlük tik sırası ya da yeni sistem: `time_manager.gd:385-434`, `rnd_system.gd:94-100` yorumu ve 01_cekirdek.md'deki dağıtım sırası maddesi; `incident_*` ve `sprint_*` vakalarını koş
