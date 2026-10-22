# B0t · Faz B bağlantı haritası taslağı (PRD §6)
Salt okuma, `main` @ `1faeb82`. A henüz commit atmadı: A'dan beklenen her ad **[A/B]** ile işaretli ve §9'da sayılı; B0 bunları `RAPOR_A.md`'deki gerçek adlarla değiştirir. "DOĞRULANMADI" = kodda ya da belgede göremedim. Mail ve bildirim saatleri ayrı dosyada (`B0t_MAIL_SAATLERI.md`), burada yalnız atıf.

Sütunlar: **Nokta** · **Bugün (dosya:satır)** · **Yeniden kullan** · **B ekler / A'dan beklenen** · **Risk**.

## 1. Acil durum sistemi (B3, B4; B2 fiilleri)

### 1.1 A'nın hata deposu
| Nokta | Bugün | Yeniden kullan | B ekler / A'dan beklenen | Risk |
|---|---|---|---|---|
| Açık hata (toplam, hat başına) | `ProductState.bugs_confirmed()` (`seams_product.gd:90` `urun.bugs_confirmed`), canlı hata `ProductSystem.live_bug_count()`, bilet defteri `product.tickets` (`sprint_bridges.gd:19-62`) | — | **[A/B]** `ProductState.open_bugs()`, `open_bugs_by_line()`, `line_bugs(hat)`; seam `urun.open_bugs`, `urun.worst_line_bugs` (A_PLAN §5.2) | B kendi sayacını yazmaz (PRD §6); adlar değişirse B0'a kalır |
| Hatta hata ekleme | bugün `SprintBridges.add_faulty_ticket(line)` (`sprint_bridges.gd:58`), hatalı kapanış `_go_public` (`sprint_system.gd:1084-1106`) | — | **[A/B]** `ProductState.add_bugs(hat, n)` (aceleden hata, "sprint yolu"); B yazma noktası | Bu faz "gece düzeltmesinde %25 hata" bedelini kaldırdı (PRD §0 madde 2): `add_bugs`'ı B yalnız `regression` türünde çağırabilir. Çağıran var mı doğrulanmadı |
| Hattı yeni hataya kapatma | yok | — | **[A/B]** `ProductState.line_blocked(hat)` (A her zaman false döner, `SprintCatalog.bug_line()` sorar); `line_harden {weeks}` bitiş tiki **A'nın hat durumunda** (`{hat: gün}`) | `line_harden` PRD'de açıkça yok; B_PLAN §5.2'de var. Bu faza girecek mi, doğrulanmadı |
| "Hat temizlendi" sinyali | yok (düzeltme kartı kapanışı bilet siler: `sprint_system.gd:1007-1012`, `SprintBridges.close_tickets` :47) | — | **[A/B]** `ProductState.clear_line_bugs(hat)` + `EventBus.line_bugs_cleared(hat, n)` | Yeni EventBus sinyali: `tools/gen_signal_manifest.py` koşar (A yapar) |
| Hattı kullanan hesaplar, etkilenen hesap/kullanıcı | `SprintCatalog` bugün yok; `SalesArchetypes` sektör-arketip (`sprint_bridges.gd:83-88`) | `CustomerRegistry.get_by_market("b2b")`, `SalesSystem.b2c_audience()` | **[A/B]** `SprintCatalog.line_accounts(hat)`, `line_impact(hat) -> {accounts, seats, top_id, top_seats}`, `line_share(hat)` (B2C payı) | `top_star` yok (yürütücü notu 3). B2B gece vardiyalı sektör süzgeci (lojistik, üretim, sağlık [ÇALIŞMA]) B'nin işi |
| Hatalı sürüm | bugün `_close`'daki yerel `faulty` dizisi (`sprint_system.gd:1006,1027`) | — | **[A/B]** `release.faulty` (hatalı çıkan hatlar); "Sürüm sonrası bozulma" tetikleyicisi B'nin kendi seam'i | `release` sürüm kaydı `releases` dizisinde kalıcı (`:1059-1066`), `faulty` alanı yeni ve kayıtlı |
| Düzeltme kartını sprinte koyma / başa taşıma | yok. Kart yerleşimi `_place(c, this_sprint)` özel (`:1213`); koşan sprinte `add` yok (`can_add` yalnız `mode()=="plan"`, :536); koşan kart `_movable` değil (:1185); sıra `_assign` kart sırasına bağlı (:754) | `_assign`, `_restaff` (:932) | **[A/B]** ad bilinmiyor; B_PLAN `SprintSystem.insert_urgent_fix(hat)`. Kart zaten sprintteyse başa taşır, ikinci kart açmaz (Karar 9) | A_PLAN K4 "hattın kartını sprinte koyan ya da başa taşıyan giriş" diyor; adı RAPOR_A'dan. Koşan sprinte kart girince `capacity()`/`plan_outcome` yeniden okunmalı (§4.7) |

Eski sistemler (A silecek, B'nin kodu onlara bağlanmamalı): `product.bug_pile` (kart `data/events/cards/product/bug_pile.json`, `urun.bugs_confirmed ≥ 12` koşulu), `fix_run_start` fiili (`effects.gd:439`, `chips.gd:44`), `SupportSystem.start_fix_run`, `destek.can_start_fix_run`, `destek.fix_run_active` seam'leri. B_PLAN'da `bug_pile` silmesi B'ye de yazılı; **A silecek** (A_PLAN K2): iki yerde silinirse ikinci silme boşa gider.

### 1.2 Sunucu kademesi, Ar-Ge, doluluk
| Nokta | Bugün | Yeniden kullan | B ekler | Risk |
|---|---|---|---|---|
| Sağlayıcı | `InfraSystem.provider()` `infra_system.gd:125`; `PROVIDER_LOCAL/CLOUD/ENTERPRISE` :18-23; `set_provider` :229 | `IncidentSystem.tier_mult(kademe)` `sprint.json` `incident.tier` (1,5/1,0/0,6 B_PLAN; C 1,6/1,0/0,5) | `incident` bloğu `data/product/sprint.json` (bugün yok: üst anahtarlar `decision`, `urgent_tickets`…) | Çarpanın tek evi B; C bu sayıyı kopyalamaz |
| Doluluk | `InfraSystem.capacity_state()` :212; `outage.json` bunu okuyor | — | Karar 3: çarpan fonksiyonu 1 döner, `BASE` 0,10 [onay bekliyor]; "kapasitenin sınırında" cümlesi yazılmaz | `product.outage` kartı (`urun.capacity_state == over`, eşik `account_count ≥ 5` ya da B2C ≥ 2.000) B'nin yeni kartıyla yer değiştirir; eski kart silinmezse iki kesinti yolu birlikte çalışır |
| `incident_playbook` | Ar-Ge düğümü `data/techtree/rnd_tree.json:26`, etki `overage_satisfaction` (`infra_system.gd:64,287`) | `ResearchSeam.completed("incident_playbook")` | B_PLAN: araştırılmışsa kesinti süreleri ×0,75 [ÇALIŞMA]. **PRD'de yok**, "onay bekliyor" olarak sorulur | Düğümün açıklaması C'de değişecek; B yeni sabit eklerse bu ikinci tasarım sabiti |

### 1.3 Zaman yöneticisi
| Nokta | Bugün | Yeniden kullan | B ekler | Risk |
|---|---|---|---|---|
| Gece toplu adımı | `skip_night()` `time_manager.gd:179-186`: 08:00'e kadar `_run_batch` → `_step_hour`; saat 00'da `advance_day` + `_dispatch_daily_tick` (:150-153); `night_skipped` yalnız varışta | `_can_step()` :160 (`run_active and _holds.is_empty()`) | gece kesintisi: saatlik dilimde `EventGate.request(...)` true dönerse `hold_clock("incident")` | Tutuşlar kaydedilmez (`to_dict` :283-289 yalnız saat/hız), yükleme tutuşsuz döner; bekleyen kart kuyrukta kaydedilir ve `main.gd:4240` `pump` ile gösterilir |
| Kartın gösterimi | `EvEngine.pump` toplu adımda ertelenir (`engine.gd:536-538`); `clock_batch_ended` `_run_batch` sonunda (`time_manager.gd:199`), `EvSignals.install` buna `pump` bağlar (`signals.gd:53-54`); tutuşla kesilen toplu adım da bu sinyali yayar | `HOLD_LABELS` `time_manager.gd:32-37` | `"incident"` etiketi (yoksa `CLOCK_HELD`); kart gösterilince bırak | **Tutuş sızıntısı:** `pump` kartı `revalidate` ile sessizce düşürebilir (`engine.gd:554-566`, `dropped` satırı, sinyal yok); B_PLAN tutuşu `event_triggered`'da bırakıyor, düşen kart hiç tetiklemez ve saat sonsuza kilitli kalır. Çare: `clock_batch_ended` tek seferlik dinleyiciyle "etkin kart yoksa bırak" |
| Gece kuyruk kuralı | acil olmayan kart gece de kabul edilir (00:00 günlük tik) ve toplu adım sonunda gösterilir | — | Karar 4/21: acil olmayan öğe pencere içinde damgalanır ve oradan teslim edilir (`MAIL_SAATLERI` §5). Gece yalnız acil durum kartı gösterilir | `EvQueue.rank` merdiveni: `expiring`(1) `critical`(2) üstünde (`queue.gd:74-83`): kuyrukta son uyarı beklerken 03:00 acil kartı **ikinci kalır** (kabul 4.3 tam bunu sınıyor). Sıra `urgent` etiketini yukarı almalı |
| `hold_clock`/`release_clock` | `time_manager.gd:340-352`; kabuk `"event"` tutuşunu `modal_requested`'te alır (`main.gd:3752-3769`), cevapta bırakır (`:3772-3795`) | — | — | Kabuksuz harness'te yalnız B'nin kendi tutuşu vardır (bkz. §1.12) |
| Gün dönümü, oto kayıt | `day_tick_completed` `time_manager.gd:417`; `SaveManager._on_day_tick_completed` `save_manager.gd:405` | — | 00:00 adımında hiç istek yapılmaz (kabul 4.3) | Ay sonu 22:10-22:55 damga, kart 23:00 (Karar 20): saatlik dilimde `request` |

### 1.4 Olay kapısı
- **`EventGate.request(event_id, ctx) -> bool`** `event_gate.gd:16-17` → `EvEngine.request` `engine.gd:686-701`. `false`: koşu etkin değil; kapı reddetti (`EvGate.propose` Origin.REQUEST, G1/G2/G3/G5/G6/G7; **G4 pencere denetlenmez**, `gate.gd:170-173`, yani gece de kabul edilir); ya da `_admit` reddetti (aynı örnek kuyrukta/masada, :476). Masada aynı örneğin kâğıdı varsa isteği **o kâğıdı açar** (:692-693). Ret nedeni çağırana dönmez (`why.gd` aracı var); B3 "kilitli seçenek gerekçesi" için ayrı bir okuma ister.
- **Ret durumu:** `_admit` mandalı ve tempo kaydını yalnız kabulde harcar (`engine.gd:505-513`); ret bedelsizdir. Karar 2 ile uyumlu.
- **Tempo kotası:** kabul edilen istek `_today_admissions`'a girer ve `request()` hemen `_step_assign_classes()` koşar (:699): `EvTempo.assign` (`tempo.gd:46-86`) kartı pencereye **sayar** (`_record`, :84) ve kategori kotasına dahil eder; `interrupt` tavanı aşılırsa kâğıda indirir. `critical`, `terminal_warning` ya da ark kartı bütçeden muaftır ama yine de pencereye kaydolur (`:69-73`). İstek kartları aile frenine (Katman 1b/2b) ve havuz üç katmanına **sormaz** (`:120-124`, kökene göre muaf) ama `record_family` aileyi yazar.
- **Lint engeli:** `critical` yalnız `system: true` ya da `terminal_warning` kartta (C1, `lint.gd:463-464`); B_PLAN'ın `tags: ["critical"]` acil kartları `system: true` olmak zorunda (O2 de `system` kartta uygulanmaz). `sprint_card_*` fiilleri yalnız `tick: request` kartta (V3, :476-477). Yeni fiiller `WRITER_VERBS`'e (:319-327) girmeli, yoksa V1. `fix_run_start` hâlâ listede (A siler).
- **Mandal:** `EvLatches.blocked_reason` `latches.gd:58-76`: `one_shot`, sonra `max_fires`, sonra `cooldown_weeks`; **ikisi birlikte uygulanır** (`_cooldown_of` :82-89: `max_fires` varken `cooldown_weeks` açıkça yazılıysa cooldown devrede, yazılmadıysa 0). Varsayılan `latch_key` `run` (:23-24, `key_for` :37). Kâğıtlar `employee` slotu taşıdığı için `latch_key: "run"` açık yazılır (entity olursa sayaç kişi başına). `spend` kabulde (:94), `refund` yalnız kritik tek atımlıkta (:100, `engine.gd:563-565`). `max_fires` bugün hiçbir kartta yok; motor md §3.1 "alternatif" diyor, kod yığıyor: ayrılık md §27'ye yazılır.
- **Gece toplu adımı içinde gelen kart:** `_admit` toplu adımda kuyruğa yazar, `pump` ertelenir; adım bitince ya da tutuşla kesilince `clock_batch_ended` → `pump` gösterir (`engine.gd:536-571`). İstekle gelen kartta motor geceyi denetlemez; yalnız `hourly` kart `is_night()` ile süzülür (`gate.gd:203-207`).

### 1.5 Sunum, çip, etki fiilleri
| Nokta | Bugün | B ekler | Risk |
|---|---|---|---|
| Varyant (by_seam) | `presenter.gd:235-259` `_resolve_variant`: seam'in tamsayı değerinden büyük olmayan en büyük anahtar; boş sözlük `""`; kart gövdesinde yalnız `{slot}` ve `{seam:ns.ad}` çözülür (`SEAM_RE` :23) | hat başına tam cümle varyantları; `olay.variant` seam'i | `{belirti}` gibi belirteç ekrana süslü parantezle çıkar; kapı `card_body_tokens_resolve` |
| `EvChips.describe` | `chips.gd:59-183`; `morale_all` ham miktarı gösterir (`"EFFECT_TEAM"`, :86-97) ama uygulama kişi başına `HRMoraleSystem.scaled_delta` ile ölçeklenir (`hr_morale_system.gd:186-200`) | çip ile uygulama aynı fonksiyondan okumalı; "ödeyen kişileri adıyla" için yeni parça | Çip/uygulama eşitliği kabul 4.2'de; ölçek özelliği (trait çarpanı) farkı yaratır |
| `SILENT_VERBS` / kapsam | `chips.gd:20-25`; smoke `event_chip_coverage` `endgame_smoke.gd:15158` (her kart fiilinin çip ya da sessiz listesinde olması) | `incident`, `trust_delta`, `sprint_card_trim`, `sprint_card_test`, `line_harden`, `promise_extend`, `promise_break` için çip | `describe`'da bilinmeyen fiil `push_warning` basar (:178) |
| `effects.gd` fiilleri | `morale_all` :354 (kapsam yok, tüm çalışanlar); `productivity_mod` :358 (`scope: team` → `SprintSystem.team()`); `sprint_card_effort/progress/carry` :425-431; `sprint_hours` :432; `satisfaction_delta` :402 (`CustomerRegistry.set_satisfaction`); `add_cash` :221 (`FinanceSystem.apply_one_time_cost/income`); `audience_delta` :277 (`SalesSystem.add_b2c_audience`); `promise_create` :414; `_amount` :580 (`amount`/`delta`/`value`) | `morale_all {scope}`, `amount_seam` (+ `amount_mult`) tutarı seam'den okutur: `EvEffects._amount` ve `EvChips.describe` aynı yardımcıyı kullanmalı | `satisfaction_delta` bir tikte silinir (`B2BSalesSystem` hedefe çeker, `b2b_sales_system.gd:105-107`): kalıcı bedel `trust_offset` ile |
| Sınıf ekonomisi | `ECONOMIC_VERBS` `effects.gd:70-76`; ekonomik fiil `on_expire`'da yalnız negatif olabilir (`_is_negative`) | `incident` nötr; tutar fiilleri ayrı | `incident` `on_expire` ile `morale`+ekonomik karışırsa I2 reddi |

### 1.6 Sprint
| Nokta | Bugün | Yeniden kullan | B ekler | Risk |
|---|---|---|---|---|
| Acil kartın girişi, plan tahmini | `plan_outcome(ids)` `sprint_system.gd:566-588` (kapasite `team()` ile); `_play_out` :805; `capacity()` :446; `decision_card_late` :634 | `plan_outcome`, `_assign` | acil kart girince tahmin yeniden okunur (kabul 4.7) | A Karar 13 `team()`'i iş filtreli yapar; tahmin ile kapanış eşleşmesi `--sprint-probe` ile |
| Kapanış, sürüm notu | `_close` :986-1083, `release` :1059, `version_shipped` :1080 | `SprintBridges.on_release` :115 | sürüm anı tetikleyicileri §4 | — |
| Düzeltme kartı | `_refresh_fix_cards` :1192; `kind == "fix"`, `tickets` | — | **[A/B]** A kartı hata sayısına çevirir | — |

### 1.7 Kart ataması ve Görevler matrisi (bedeli ödeyen)
- `SprintSystem.team()` `sprint_system.gd:518-534`: aktif çalışanlar + aktif kurucu; Ar-Ge'dekiler dışarıda; `fits` = `role_areas` ile `HRConstants.can_hold_area` (`hr_constants.gd:253-260`); `ahead` = geliştirme ya da test rolüne uymayan. Puan `_points` :1290 `focus_mult` **okumaz** (`K0_KESIF` k1). **[A/B]** Karar 13: Yapım/Test işini tutanlar, `focus_mult` payı.
- `assignees` yalnız `_assign` içinde yazılır (:754-784); `role_of(person_id)` :1260 yalnız `mode()=="active"`da döner, önden hazırlanan kartı da sayar.
- **Bedeli ödeyen küme (Karar 6):** (1) olayın hattında koşan sprintte kartı olan geliştirici ve testçiler, (2) yoksa Yapım ya da Test işine atanmış herkes, (3) ikisi de boşsa seçenek kilitli. Okuma noktaları: `assignees` (kart başına), `role_of`, A'nın "kim sprintte, payı kaç" okuması **[A/B]** (RAPOR_A). Kullanılacak mevcut fonksiyon yok; `morale_all {scope: night_crew}` yeni.
- Hat ile kart ilişkisi: kartın `line` alanı (`c.line`, `sprint_system.gd:1016`); düzeltme kartı `kind == "fix"` `line` taşır.
- **PM doğrulaması (Karar 10):** `team()` PM'i alır (`fits` = ürün ve tasarım alanı, `hr_constants.gd:87` `product_manager: key product, secondary design`; `ahead: true`). `_assign` PM'i sprint kartlarının **ilk fazına** (tasarım) atayabilir. "PM sprintte kart almaz" bu okumayla uyuşmuyor; kâğıdın konuşanı için ayrı PM kuralı gerekir. Kodda koşturup doğrulanmadı.

### 1.8 B2B güven izi
`Customer.trust_offset` `customer.gd:58-61`; yazma `CustomerRegistry.set_trust_offset` `customer_registry.gd:219-226` (±: `TRUST_OFFSET_MIN -25`, `MAX 10`, `b2b_constants.gd:263-264`). Hedef `B2BSalesSystem._target_on` `b2b_sales_system.gd:129-142` (`axis_score + trust`, 0..100); affetme `_forgiven_trust` :145-146 (`TRUST_OFFSET_DECAY_PER_DAY 0,4` ×7 = 2,8/tik, :265). Söz sonucu izi aynı defterde (`on_promise_resolved` :401,412,422). B'nin `trust_delta` fiili `set_trust_offset` üstünden (WRITE-THROUGH). **Risk:** (1) −6 iki tikte −0,4'e iner; kapanış başına −3 B2 ölçümü. (2) A hedefe "hesap başına açık hata" terimi ekleyecek **[A/B]** `B2BSalesSystem.account_bugs(c)` × `B2B_BUG_SAT_PER` (A_PLAN): ertelenen olay çift sayılır, rapora girer. (3) C eşiği 30 + 3×(yıldız−1)+⌊sektör/2⌋ henüz yok; mevcut eşik `B2BConstants.seed_tolerance` (33, 42, 45, 51, 56).

### 1.9 B2C kitlesi
`SalesSystem.b2c_audience()`, `add_b2c_audience(n)` `sales_system.gd:289-295` (tek seferlik; stok, saatlik akış üstünde sürer: `_tick_b2c_audience` :168, saatlik); kayıtlı haftalık düşüş için hazır seam yok: B'nin `IncidentSystem` durumu günlük tikte `add_b2c_audience(-%2 × kitle)` çağırır. Ödeyen: `b2c_paying_users()`, kayıt `B2C_USERBASE_ID`. Memnuniyet `CustomerRegistry` B2C kaydı üzerinden. **Risk:** her saatlik akış `audience * WOM_COEF`… kitleyi geri çekebilir, haftalık %2 sürekli düşüş akışla birlikte okunur (bot ölçümü gerekir). Düşüş "hat kapanınca ya da düzeltme sürümle çıkınca biter": **[A/B]** `line_bugs_cleared`.

### 1.10 Finans
`FinanceSystem.apply_one_time_cost(amount, label)` `finance_system.gd:188-195` (ay gideri + işlem satırı + `set_cash`; `amount <= 0` boş), `apply_one_time_income` :198. Kredi `mrr`'ı değiştirmez, tek seferlik gider (Karar 5) → `add_cash` negatif `amount_seam` ile ya da doğrudan fiil. `label` anahtar mı metin mi: `record_transaction(label, ...)`; **DOĞRULANMADI** (kullanıcıya görünen etiket anahtara bağlanmalı).

### 1.11 Kayıt
- `SaveManager.SCHEMA_VERSION` 15 (`save_manager.gd:16`), `MIN_LOADABLE_VERSION` 10 (:23). Göç zinciri `read_slot` içinde (`:194-201`): `<11 → _migrate_sales_rev6`, `<13`, `<14`, `<15`. **[A/B]** A 16'yı ekler, B 17. Yükleyici `prep` ve `pitch_prep_active` anahtarlarını her yüklemede düşürür (PRD §8; sürüm numarasına bağlı değil): `GameState`'te `prep` bir `var` olduğundan SaveCodec onu kendiliğinden bulur; B9'dan sonra eski kayıttaki anahtar yoksayılır mı, hata mı verir, **DOĞRULANMADI** (`SaveCodec.apply_game_state`).
- `reset_all_owners` `save_manager.gd:320-355`: yeni statik durum (örn. `IncidentSystem`) burada listelenmeli; sistem bloğu `_capture_systems` :371-380 ve `_restore_systems` :383-398 (`"product"`, `"rnd"`, `"finance"`, `EvSave.BLOCK_KEY`, `"hr"`, `"time"`, `"rng"`). B_PLAN iki yol sunuyor: `"incident"` bloğu ya da durumu `GameState`'te sözlük (SaveCodec bulur). `GameState` yolu daha kısa.
- Statik durum tutan olay sistemleri: `EvSave` bloğu `BLOCK_VERSION 1` (`save.gd:17`), kuyruk/kâğıt/geçmiş/mandal/takvim/ark/bütçe/ticker/tempo/gecikme. `EvTicker._held` (`ticker.gd:15`) kayıtlı.

### 1.12 Bot
- `RunProbe` sim kipi `_run_sim` `run_probe.gd:671-692`: saat saat `advance_hours(1)` + `_answer()`; gece `skip_night()` ve **gece dalında `_answer()` yok**. `if TimeManager.is_clock_held(): print ERROR; break` (:686). Gece acil kartı (`hold_clock("incident")`) bu döngüyü `PROBE ERROR the clock is held` ile bitirir ya da kartı cevaplamadan gece adımını sürdürür. B4 `_run_sim` gece dalına `_answer()` eklemeli.
- Gerçek saat kipi `hour_changed` ile `_drain_modals()` (:734-738): toplu adım içinde de çalışır, kart cevaplanır.
- Cevap: `_drain_modals` :556-592 etkin kart ve `desk_papers(1)` kâğıtları sırayla açar; `_pick_choice` :606-640 "müşteri" kartlarında fiile göre (`RETAIN_PREFERENCE` :604) ve diğerlerinde ilk kilitsiz satırı, `_cash_delta_of` yalnız literal `add_cash` `amount` okur (:664-670): `amount_seam` tutarı bunu **görmez**; B4 botu fiile göre seçerken `incident {act}` fiilini okuyacak.
- Preset tablosu `PRESETS` :72-87; **[A/B]** `fix` kolu anahtarı (`fix_none`, `fix_worst`, `fix_due`, `fix_off`), `PROBE FIX` satırı, `PROBE B2C open_bugs=` (A_PLAN): `_fix_on_at` düzeltme koşusu kodu (:129-130,:1104-1121) A'da silinir.
- Hazırlık için geçici kol (B9): `full_run_vc_cautious` `{"subtype": "erp", "vc": "cautious"}` (:78); Series A öncesi hazırlığı başlatan kol `VCPitchSystem.start_prep` çağırır.
- `sprint_probe.gd`: `choose_type("note_tool", "Notly")` **sabit** (:72); `market=` parametresi yok (B5 ekler). `HIRES` (:40-41) geliştirici, tasarımcı, testçi, geliştirici, PM; `team=3` = kurucu + geliştirici + tasarımcı (testçi için `team=4`; PRD §4.5'in "tasarımcı, geliştirici, testçi" tarifi doğrulanmadı). Parametreler: `hours cards ticks start seeds seed events rate lead gate team weeks fill`; sayısal değerler `to_float`; `rate` yalnız `events=1`de `SprintCatalog.cfg("decision")`e yazılır (:60-61). B2B kolu için müşteri kadrosu yok (`SprintCatalog.line_accounts` boş kalır, müşteri kartları `musteri.scale ≥ 2` ister).
- Olayı belli tikte zorlayan `incident=<tür>@<tik>` parametresi yok; `events=1` döngüsü tik başına `advance_hours(1)`/`skip_night` koşar (:81-88): zorlama `IncidentSystem.force` benzeri bir çağrı ister (B3/B4 kararı).

## 2. Kâğıt motoru (B5, B6)
| Nokta | Bugün | Yeniden kullan | B ekler / A'dan beklenen | Risk |
|---|---|---|---|---|
| Kâğıt seçimi | `_request_decision` `sprint_system.gd:834-856`: her sürüyen kart için haftalık zar `hash([run_seed, c.id, sprint_number(), week()]) % 1000 < decision.rate×1000` (`rate` 0,35, `data/product/sprint.json:40`), kart başına `events[(roll+i) % n]`, ilk kabul eden kâğıt; `p.decision = {card_id, event_id}`, `c.decision = true`; aynı anda tek karar. Çağıranlar: `_end_week` :745, `_begin` :166 (1 haftalık sprint) | `EventGate.request` dönüşü | `week_chance`/`per_sprint` kural **kaldırılacak** (PRD §0 madde 11): "sprint başına en çok bir, bazı sprintte hiç" kabul 4.5'e göre yeniden seçilir; `decision.rate` ve kart başına zar silinir | Bugün sprint başına üst sınır yok: `p.decision` boşken her hafta sonu yeniden çekilir (yalnız aynı anda tek karar bekler); "en çok bir" ve "bazı sprintlerde hiç" sayacı yeni durum ister (`product.decision_sprint`) |
| Havuz | `decision.cards` 6 kart: `two_paths`, `late`, `contractor`, `hardcoded_colors`, `colors_again`, `unasked_rewrite` (`sprint.json:40`). 3 takip kartı `tick: scheduled`: `rewrite_bugs`, `rewrite_owner`, `rewrite_reader` (unasked_rewrite `schedule_event` ile). Aile `sprint_capacity` (two_paths, late, contractor), `sprint_scope_creep` (hardcoded_colors, colors_again), `sprint_rewrite` | — | PRD: 40 kâğıt. Mevcut 9 kart rol/aşama dağılımında yok; PRD'ye göre yeni havuz yazılır (W2) | `sprint_colors_again` silinir/`hardcoded_colors` ikinci geliş varyantı (B_PLAN §5.9) |
| Kapasite kâğıdı | `sprint_two_paths`, `sprint_late`, `sprint_contractor` `urun.decision_card_effort ≥ 5` ya da `decision_card_late` (`seams_product.gd:46-62`) | `urun.decision_card_*` seam'leri | — | `sprint_late` fazla mesai `sprint_hours` 1,25 (`CRUNCH_MULT` :24) one_person kartta yasak (O3) |
| Konuşan kişi | kartlarda `scope.employee` ile `where` yok; `sprint_rewrite_*` `hr.job == build` | `assignees`, `role_of` (§1.7); seçici örneği `decision_sheet` `scope.gd:260` | konuşan = kartın o aşamadaki `assignees`'i: ya `hr.role`/`hr.on_decision_card` seam'li `where` (B_PLAN) ya da yeni `employee` seçici (`decision_assignee`); ikincisi daha kısa | `hr.role` bugün yok (`hr.job` var, `seams_hr.gd:83`). `where` yalnız slotun `entity_seam` yapraklarını süzer (§27.16) |
| Mandal/tekrar | `EvLatches` (§1.4): `cooldown_weeks 52` + `max_fires 3` + `latch_key: run` | `blocked_reason`, `EvHistory.fire_count` | havuz ağırlığı `w/(1+2×görülme)` `EvLatches.fires(key)` ile | `max_fires` hiçbir kartta kullanılmıyor; kanıt vakası `decision_no_fourth_show` |
| Kesinti sırası (Karar 12) | yok. Acil durum ve söz olayı kartları ayrı akışlar | — | sprint başına ortak "kesinti sayacı" (örn. `product.decision_sprint` damgası); acil durum gelen sprintte kâğıt çekilmez | `_request_decision` yalnız `_end_week`/`_begin`'de koşar; acil durum saatlik/gece gelir: sayacın sahibi tek yer olmalı |
| Testi kısalt | `faulty_chance` 0,4 (`sprint.json`) yalnız test fazı Test rolü olmadan yapılırsa (`_work` :787-802 `c.faulty = true`); `_close` :1027 hash'li zar | — | `sprint.json`'a "kısaltılmış test hatalı çıkma ihtimali" (öneri %15 [onay bekliyor]); `SprintSystem.escape_chance(card)` D gelince | Bugünkü zar çip önceki/sonraki değeri okumuyor; çip için aynı fonksiyon şart |
| Sprint kâğıdı fiilleri | `sprint_card_effort/progress/carry` `sprint_system.gd:272-323`; `effort_change` :282 en az 1 puan ve yapılmış işin altına inmez | — | `sprint_card_trim`, `sprint_card_test` (`cut`/`covered`) | D ×5 ölçeği miktarları değiştirir (B listesi D'ye gider) |
| Plan tahmini / probe | `plan_outcome`, `--sprint-probe` (§1.12) | — | `SPRINTPROBE PAPER|<seed>|<sprint>|<event_id>|<speaker>` satırı, `market=` | `team=` anlamı (§1.12) |
| Kayıt | `product.decision` `{card_id, event_id}`, `c.decision`, `product.decision_sprint` yok | `GameState.product` sözlüğü | `decision_sprint` (varsayılan −1) | `SprintSystem.new_state` :76-89 yeni anahtarı almalı; yoksa eski kayıtta `KeyError` (`product[...]` doğrudan okuma) |

## 3. Söz olayı (B7)
| Nokta | Bugün | Yeniden kullan | B ekler | Risk |
|---|---|---|---|---|
| Promise modeli | `Promise` `promise.gd`: `id customer_id feature_id deadline_day due_sprint status` (`open|kept|broken|partial`); `due_sprint` = `plannable_sprint() + sprints_in(weeks) − 1` (`promise_registry.gd:70-72`) | `PromiseRegistry.create` :50-78, `tick_deadlines` :150, `_overdue` :158 (`last_closed() >= due_sprint` ve özellik canlı değil), `_resolve` :164 (`promise_broken` yayar) | `extended: bool` (Karar 14 "arayıp ek süre": `due_sprint +1`, bir kez); `source` alanı **gerekmez** (B2C ikizi kalktı) | `_resolve` özel görünümlü; "söz kaçsın" için kamuya açık bozma girişi yok (B ekler ya da `tick_deadlines` yoluyla) |
| Söz anı tespiti | `SprintSystem.fits_plannable(step)` :677-697 (söz kilidi: kademe planlanabilir sprintte yetişir mi); seam `urun.sprint_last_week` :40; `decision_card_late` :634 | `urun.sprint_running` | yeni seam `urun.decision_promise_due`; kâğıt sistemce ayrıca istenir (bütçeye sayılmaz, B_PLAN) | Karar 12 "söz olayı gelen sprintte kâğıt gelmez": sayaç etkileşimi |
| Seçenekler | fazla mesai `sprint_hours` ×1,25 (`CRUNCH_MULT`); ek süre yeni; test kısalt yeni; söz kaçsın `_resolve(p,"broken")` zinciri | `B2BSalesSystem.on_promise_resolved` :380-430 (brand, tolerans, `trust_offset`) | `promise_extend` güven bedeli −3 (`set_trust_offset`) | Söz zincirinin brand/tolerans etkisi kopyalanmaz, zincir kullanılır |
| B2B satış/memnuniyet | `B2BSalesSystem.accept_promise`, `_recover` | — | — | söz verildiği anın kartı `promise_create` fiili `effects.gd:414` |

## 4. Sürüm anı ve teşekkür (B8)
| Nokta | Bugün | Yeniden kullan | B ekler | Risk |
|---|---|---|---|---|
| Sürüm köprüsü | `_close` → `_go_public(n, new_code, faulty)` `sprint_system.gd:1084`; `EventBus.version_shipped(n)` :1080; `build_phase_changed("shipped")` ; `SprintBridges.on_release` :115 (açık talepleri `met` yapar); `SprintBridges.actual_sentence` :195 | `release` kaydı `releases` | teşekkür tetikleyicisi: üç tetikleyici | tek sürümde hesap başına 1, toplam en çok 3 (Karar 16) sayacı kayıtlı olmalı |
| Acil durum kapanışı | **[A/B]** `line_bugs_cleared`; B3 olayının "hızla kapandı" durumu `IncidentSystem` içinde | — | "aynı gece/aynı gün kapandı" bayrağı | 6. tetikleyici yok; kapanma anı ile sürüm anı farklı |
| `PromiseRegistry` | `_on_build_phase_changed("shipped")` `promise_registry.gd:133-148`: özellik canlıysa `kept`/`partial`; `promise_kept` sinyali | `EventBus.promise_kept` | "söz verilen özellik çıktı" teşekkürü bu sinyalde | `partial` da `promise_kept` yayar (tek sinyal, iki durum) |
| İstek verisi | `GameState.product.requests` `[{id, customer_id, line, step, created_sprint, due_sprint, value, status (open/met/late), card_id, day}]` (`sprint_bridges.gd:94-98`); `status` `on_release` :115 | `SprintBridges.tick_requests` :72 | "istenen özellik çıktı": `met` geçişi; C gelene kadar bugünkü `requests` | C `SprintCatalog.known_requests()` getirince okuma değişir |
| Gelen kutusu | `MessageSystem.post` (`message_system.gd:14`) ya da tek seçenekli etkisiz not kartı (`is_note`, `presenter.gd:128`): teşekkür 1-2 cümle, gönderen `contact` (B_PLAN §6.4 `customer.release_thanks`) | `sender` alanı (`EvPresenter.SENDERS`) | teslim saati kuralı | Not kartı **yalnız kuyruğa/masaya girmeden** geçmişe yazılır; kota harcamaz |
| B2C yorum | sürüm satırı: `release.actual` (`actual_sentence`), `fill_actual` `sprint_system.gd:1118` (sürümden bir tik sonra); yorum kaynağı mağaza E'de | — | "Sürüm sonrası öne çıkan yorumlar" 2-3 kısa yorum | Yorumun hangi gelen kutusu/sürüm notu yüzeyinde durduğu belgelenmemiş; PRD "kaynağıyla görünür" diyor, yüzey W3'te seçilir |

## 5. Yatırımcı hazırlığının kalkması (B9)
Silinecek yüzey (`grep` sayımı, hazırlıkla ilgili satırlar): 11 oyun dosyasında 82 satır (`vc_pitch_system.gd` 47, `hunt_tab.gd` 14, `pitch_constants.gd` 4, `hr_system.gd` 4, `game_state.gd` 3, `vc_meeting_adapter.gd` 3, `seams_hr.gd` 2, `seed_round_system.gd` 2 yorum, `rnd_system.gd` 1 yorum, `save_manager.gd` 1, `main.gd` 1), `endgame_smoke.gd` 20 satır (4 vaka), `strings.csv` 12 satır, 4 belge. Sayılar yorum satırlarını da içerir. Silinir (VC satırı), `MEETING_CHIP_PREP` anahtarı **kalır** (satış kullanımı `sales_meeting_adapter.gd:31-33`, VC adaptöründeki tek kullanım :167 silinir).
| Dosya | Yer | Ne |
|---|---|---|
| `scripts/autoload/game_state.gd` | :106 `"pitch_prep_active": TYPE_BOOL` (`FLAG_TYPES`), :247 `var prep: Dictionary`, :846 `prep.clear()` | alan, bayrak türü, reset |
| `scripts/systems/pitch_constants.gd` | :72 `FOCUS_KEYS`, :74-76 `PREP_WEEKS`, `PREP_MIN_WEEKS_BEFORE`, `PREP_BONUS` | sabitler |
| `scripts/systems/vc_pitch_system.gd` (47 satır) | :38 `_prep_focus`; :85 `_consume_prep` çağrısı (yalnız Series A); :804-806 `cancel_meeting`'in hazırlık temizliği; :829-857 `prep_blocked_reason`, `start_prep`, `_consume_prep`; :870 `_tick_prep()` çağrısı; :906-911 `_tick_prep`; :965-966 `on_pivot`; :1026 `prova`; :1248-1251 `_beat2_bonus`; :1267 `_beat3_bonus`; :1276 `_check_view`'in `prep` alanı (:1273-1277); :1347 yorum; :1357 `reset` | mantık; `_beat2_bonus`/`_beat3_bonus` 0 döner ya da çağrıdan kalkar (çağıranlar `_check_view(... bonus)` kollarında) |
| `scripts/systems/hr_system.gd` | :155 `is_busy`, :205 `FOUNDER_STATE_PITCH_PREP`, :224, :248 `founder_task_state` | kurucu meşguliyeti ve durumu |
| `scripts/events/seams/seams_hr.gd` | :182 `founder.task_state` açıklaması ("… pitch_prep …") | seam yorumu |
| `scripts/systems/rnd_system.gd` | :163 yorum | yorum |
| `scripts/tabs/hunt_tab.gd` (14 satır) | :344 `_prep_row` çağrısı, :376-388 `_prep_row`, :510-520 `_paint_pending`'in hazırlık satırı | Series A sekmesi hazırlık satırı |
| `scripts/ui/meeting/vc_meeting_adapter.gd` | :166-168 `chk.prep` etiketi | VC "HAZIRLIK" çipi |
| `scripts/autoload/save_manager.gd` | :691 `_stamp_keys(gs.get("prep", {}), ["done_day"], today)` (v13→v14 göçü) | göç satırı (eski kayıttan okuyan **göçün** parçası; silinirse v13 göçü `prep`'i damgalamaz, yükleyici anahtarı düşürür) |
| `scripts/main/main.gd` | :3544 fikstür `GameState.prep = {...}` | çekim fikstürü |
| `scripts/debug/endgame_smoke.gd` (20 satır) | :114 `prep_bonus_and_capacity` kaydı, :2566-2590 vakası; :2597-2606 `meeting_daylock` içindeki `prep_blocked_reason`/`start_prep` kolları; :10449-10465 `hr_read_catalogue` içinde `pitch_prep_active`/`FOUNDER_STATE_PITCH_PREP`; :14849 `split_bars_name_their_cause`'ın bayrak sıfırlaması | vakalar ve parçaları (`meeting_daylock` yalnız hazırlık kollarını kaybeder, vaka kalır) |
| `localization/strings.csv` | `HR_FOUNDER_STATE_PITCH_PREP` :449; `HUNT_PREP_RUNNING/REASON/PENDING/READY` :798-799,817-818; `HUNT_FOCUS_NUMBERS/STORY/REHEARSAL` :838-840; `VC_PREP_BUSY/NEED_MEETING/TOO_SOON/TOO_SOON_ONE` :1277-1280 (12 satır). **Kalır:** `MEETING_CHIP_PREP` :1923 | CSV (byte-span cerrahisi; hafıza: CSV'yi yeniden yazma) |
| Belgeler | `docs/content/events_draft/_vocabulary.md` :180,184,222 (`--event-vocab` üretir, KEEP bloğu elle); `GDDs/GDD — ZAMAN MODELİ.md` :293,706,744 (`PREP_*` satırı, `prep.done_day`); `GDDs/GUNCELLEMELER.md` :356 (VC görüşmesi cümlesi, hazırlıktan bahsediyor olabilir: **DOĞRULANMADI**); `docs/ACIK_ISLER/ACIK_KARARLAR.md` :1001, :1197 (hazırlık cümleleri, "ana oturuma not") | belge |
Notlar:
- **Series A'da hazırlık yalnız `series_a` iken tüketiliyor** (`vc_pitch_system.gd:85`): PRD tespiti doğru. `GameState.prep` hiç temizlenmezse seed görüşmesinde kalmaz.
- `vc_meeting_adapter.gd`: `chk.prep` boş string dönerse kol zaten çalışmaz; `_check_view`'in `prep` anahtarı kalkınca `chk.prep` okuması `KeyError` verir: iki dosya birlikte.
- Önce ölçüm (kabul 4.8): `full_run_vc_cautious` için geçici bot kolu; ölçüm sonrası silinir. Odaklanan sorunun geçme ihtimali `SkillCheck.breakdown(skill, diff, bonus)` ile (`vc_pitch_system.gd:1272-1276`).

## 6. Mail ve bildirim saatleri
Tamamı `B0t_MAIL_SAATLERI.md`: 12 başlığın doğrulaması, 5 yeni üretici, boğumlar, hatırlatıcı seçenekleri, alan/kuyruk/kayıt önerisi, riskler. HARITA'ya düşecek dokunuşlar orada §10'da.

## 7. Belgeler
| Belge | Neden | Not |
|---|---|---|
| `docs/HARITA.md` | Çekirdek (zaman: teslim kuralı), Kayıt (şema 17, yeni alanlar), Olay motoru (acil durum, kâğıt motoru, `urgent` etiketi, damga/süzgeç), Gelen kutusu mesajları (dış kutu, `at`), Ürün (acil kart girişi, kâğıt motoru), Fonlama (hazırlık kalkar), Araçlar (probe parametreleri, `inbox_no_night_stamp`) | bölüm başlıkları: Çekirdek 7, Kayıt 27, Olay motoru 295, Gelen kutusu 315 |
| `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` §27 | son bölüm §27.25; yeni **§27.26** (gece/teslim saati ve damga), gerekirse §27.27 (acil durum isteği, tutuş) | md'den ayrılık md'nin §27'sine (CLAUDE.md §2) |
| `docs/content/events_draft/_vocabulary.md` | yeni seam (`olay.*`, `urun.decision_*`, `hr.role`) ve fiiller | `--event-vocab` üretir, KEEP bloğuna dokunma |
| `docs/EVENT_SIGNAL_MANIFEST.md` | yeni EventBus sinyali varsa (`line_bugs_cleared` A'dan) | `python tools/gen_signal_manifest.py`; elle düzenlenmez |
| `GDDs/GUNCELLEMELER.md` | GDD'ye işlenmemiş sahip kararları (acil durum, kâğıt, söz, hazırlık, mail saatleri); bölümler GDD başına (`GDD v2 — 11 · Events & Narrative` :374, Zaman modeli md ayrı) | ek belge GDD'den üstündür |
| `GDDs/GDD — ZAMAN MODELİ.md` | "mesai penceresi içinde teslim" kuralı; PREP satırı (:293) siler | — |
| `CLAUDE.md` §5, §6 | §5 :63 "Gün sınırında ateşlenen kart saat yazmaz" + teslim kuralı cümlesi; §6 :107 "SCHEMA_VERSION 15" → 17; zaman paragrafında gece/teslim saati | — |
| `docs/ACIK_ISLER/ISLER.md` | Karar 15: B2C söz eşdeğeri için bir satır | PRD |
| `data/events/cards/_fixtures`, `tools/lint_baseline.json`, `lint_v3_frozen.json` | kart ekleri yeni lint bulgusu verirse | `--event-lint=baseline` yalnız kabul edilen bulguda |

## 8. Hat başına eşik girdisi (B0 için notlar)
B0, A'nın `fix_worst` ve `fix_none` kollarındaki hat başına açık hata dağılımını okuyup eşikleri yeniden seçer. Bugün bu dağılım **yok** (hata sayacı tek: `bugs_confirmed`; hat başına bilet `product.tickets[i].line`, `sprint_bridges.gd:19-62`). Okunacak yer **[A/B]** `PROBE B2C open_bugs=` ve `PROBE FIX` satırları. Eşikler "onay bekliyor" olarak önerilir.

## 9. A/B varsayımları (bu dosyada 16)
1. `ProductState.open_bugs()`, `open_bugs_by_line()`, `line_bugs(hat)`
2. `ProductState.add_bugs(hat, n)`
3. `ProductState.clear_line_bugs(hat)` ve `EventBus.line_bugs_cleared(hat, n)`
4. `ProductState.line_blocked(hat)` (+ `line_harden` bitiş tikinin A'daki yeri)
5. `SprintCatalog.line_accounts(hat)`, `line_impact(hat)`, `line_share(hat)`
6. `release.faulty`
7. Hattın düzeltme kartını sprinte koyan/başa taşıyan giriş (ad bilinmiyor)
8. `SprintSystem.team()` iş filtreli, `focus_mult` payı (Karar 13), `assignees`/`role_of` davranışı
9. "Kim sprintte, payı kaç" okuması (RAPOR_A adı)
10. Seam adları `urun.open_bugs`, `urun.worst_line_bugs`
11. Bot kolları `fix_none`, `fix_worst`, `fix_due`, `fix_off`; `PROBE FIX`; `PROBE B2C open_bugs=`
12. Şema 16 ve `_migrate_16`
13. `sprint.json` `fix_effort` (A_PLAN: `effort.fix`/`effort.fix_urgent` silinir)
14. `product.bug_pile` ve `fix_run_start`'ın A'da silinmesi
15. Bilet defteri (`product.tickets`, `SprintCatalog.tickets_by_line`) A'da silinir; `B2BSalesSystem.account_bugs(c)`
16. `time_manager.gd` dağıtım sırasının A'da değişmemesi (MAIL_SAATLERI AB-2)

## 10. Doğrulanmayanlar ve belge düzeltmeleri
- PRD §4.5 `team=3` tarifi (§1.12).
- PRD Karar 10 "PM sprintte kart almaz" (§1.7).
- PRD Karar 21 "82 kart", `team.demo_day` `_end_week`, sürüm notu mail değil (MAIL_SAATLERI §8).
- B_PLAN `incident_playbook` ×0,75 ve `line_harden` PRD'de açıkça yok: sahip onayı gerekebilir.
- Tutuş sızıntısı (§1.3) B_PLAN'da yok.
- Lint C1 (`critical` ⇒ `system`) B_PLAN'da yok.
- `FinanceSystem.record_transaction` etiketi (§1.10) ve eski kayıtta `prep` anahtarının davranışı (§1.11) doğrulanmadı.
