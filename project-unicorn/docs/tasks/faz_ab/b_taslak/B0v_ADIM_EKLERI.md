# B0v · Adım brief'lerine ekler (Opus doğrulaması, 2026-10-17, HEAD `26b60da`)
Her kod ajanının brief'ine bu dosyanın kendi adımı ve "Bütün adımlar" bölümü eklenir. Kaynak: `B0_HARITA.md` (§13 B0v),
`B0_ESIKLER.md` (§6 B0v), `B0t_MAIL_SAATLERI.md` (B0v bölümü). Satırlar HEAD'e göredir. Bütün sabitler **onay bekliyor**.

## Bütün adımlar
- Koda başlama koşulu sağlandı: `RAPOR_A.md` var, B0'ın okuduğu taslakla bayt bayt aynı, son commit `26b60da`, raporda ❌
  yok (W1 kapandı).
- Slot bağlama için yeni seçici yazılmaz: konuşan, gönderen ve hesap `EventGate.request(id, {"employee": <id>})` /
  `{"customer": <id>}` ile verilir (`scope.gd:64-72`, örnek `hr_morale_system.gd:93`). `hr.job` (yalnız ilk iş) okunmaz.
- Onaylı metindeki örnek sayı ve adlar (çiplerdeki 58 → 52, "Deniz, Mert, Selin", 186 kişi, "4 hata, 2 puan") sınıf
  (a)'dır: kod gerçeği hesaplar, metin değişmez.
- Güven izi çiplerinde "to" değeri oyuncunun bir tik sonra göreceğidir (W17, B2'nin kuralı).
- B'nin bütün olay ve kâğıt koşulları hatanın bedel tarafını `ProductState.costed()`'tan okur (`product_state.gd:233`),
  A'nın `fix_off` kolu bozulmaz (W20).

## ⚠️ / ❌ ataması
| Bulgu | Adım | Bulgu | Adım |
|---|---|---|---|
| W1 | kapandı | W15 | B9 |
| W2 | B6b | W16 | B5 |
| W3 | B4 | W17 | B2 (+ R soru 2) |
| W4 | B7 (kaynak), R soru 5 | W18 | R soru 3; B4 uygular |
| W5 | B5 | W19 | R soru 4; B6a uykuda bağlar |
| W6 | B6b | W20 | B3 |
| W7 | B2 (+ R soru 1) | W21 | B3 |
| W8 | B4 | W22 | B4 |
| W9 | B3 | W23 | B4 |
| W10 | B3 (+ R soru 8) | W24 | B5 |
| W11 | B3 | W25 | B4 |
| W12 | B3 | W26 | B6a |
| W13 | B3 (+ R soru 6) | W27 | B4 |
| W14 | kapandı (sınıf a) | W28 | B7 |
| X1 `IncidentSystem` | B3 | X5 kâğıt sayacı, `urun.decision_*` | B5 |
| X2 mail saatleri | B1 | X6 yenileme günü | B6a |
| X3 fiiller | B2 (`amount_seam`, `trust_delta`, kişiye moral) | X7 prob | B3 |
| X4 `Promise` uzatma, bozma | B7 | X8 | B3 (`HOLD_LABELS`) |

X3'ün kalan fiilleri ilk gerektiği adımda doğar: `incident` B3, `sprint_fix_first` B4, `sprint_card_test`,
`promise_extend`, `promise_break` B7, `sprint_card_trim` ve bilgi çipi fiili B6a, `line_harden` ve hemen hata fiili B6b.
X8'in teşekkür sayaçları B8'de, `EFFECT_NAMES_MORE` B2'de doğar (X8'in parçaları; ana sahibi B3).

## B1 · Mail ve bildirim saatleri
1. Girdi `B0t_MAIL_SAATLERI.md` §5, "B0 tazelemesi" ve "B0v" bölümleri. A yeni üretici eklemedi (X2).
2. Günlük yoldan gelen kart **70**'tir (demo 84 kart: günlük 60, takvimli 4, sinyalli 6; istek 13, saatlik 1). PRD'nin
   "82 kart"ı eski.
3. Kuyruğun görünürlük süzgeci tek fonksiyonda: `EvQueue.next()` (`queue.gd:60`) ve `size()`. B3 gece kapısını (W21)
   aynı yere ekleyecek; süzgeci ona yer bırakacak biçimde yaz.
4. Varlık okumaları süzülmez: `_settle_decision` `sprint_system.gd:881-882` (B0t'deki 863-864 eski), `EvQueue.has/holds/ids`,
   `EvPapers.has/keys_of/is_empty/take_expired`, `engine.gd:254` ark adımı, `EventGate.instances_of`.
5. Salıverme anına taşınan yayınlar: `summary_ready` (`summary_system.gd:95`) ve `product_note_issued`
   (`rnd_system.gd:540`); dinleyen `main.gd:4237, 4243`. `weekly_sales_report_issued` oyunda dinlenmiyor
   (yalnız `endgame_smoke.gd:16322`), taşınmaz.
6. `MessageSystem.post` (`message_system.gd:14`) id döner; debug çekimi `main.gd:879` id'yi kullanır (`:870` yalnız
   yazar). Pencere dışında dış kutuya giden mesajın id'si salıvermede doğar: çekimler saati pencereye alır ya da acil geçer.
7. `MailClock.hourly_tick` `EventGate.hourly_tick` (`time_manager.gd:430`) öncesinde; 00:00 dilimi `advance_day`'den
   önce koşar (`:150-153`), o dilimde hiçbir şey yapmaz.
8. Ekran: `mail_pane.gd:122` şimdiki saat satırı silinir, `INBOX.date_text` (`inbox.gd:480`) `at` okur.
9. Şema 17: `SCHEMA_VERSION` (`save_manager.gd:16`), `if version < 17` (`:202-203` altına, göç yok); CLAUDE.md §6
   "16" → "17". Sonraki adımlar yeni şema almaz: yeni `GameState` alanları varsayılan taşır.
10. Mesai ≠ gece: `is_night()` `workday_end` ile 08:00 arası (`time_manager.gd:208-211`); teslim
    `WorkHoursSystem.company_window()` (`work_hours_system.gd:112-116`) okur.
11. `_sim_day` 160, `_sim_day_full` 43 çağıran (`endgame_smoke.gd:573, 581`): salıverme ya da pencere içi saat kararı
    B1'in, raporda.
12. Yayılım 4 saat, `expires_weeks: 1` kâğıt 1 saat [WORKING, onay bekliyor]. R10 kapsam dışı, R9 raporda ⚠️.
13. Kapı: `inbox_no_night_stamp` (08-17 ve 11-24, falsification: dış kutu kapalı → FAIL), etkilenen smoke önekleri,
    plausibility, `run_gate.sh`; görsel `--inbox-shot` "gece sonrası sabah" (00:00 ve mesai başı + 30 dk) TR/EN.

## B2 · Motor fiilleri
1. `amount_seam` (+ `amount_mult`): `EvEffects._amount` (`effects.gd:575-580`), `EvChips.describe` (`chips.gd:58`) ve
   bot `_cash_delta_of` (`run_probe.gd:710-720`) aynı yardımcıyı okur (W27'nin para yarısı).
2. `trust_delta`: yazan `CustomerRegistry.set_trust_offset` (`customer_registry.gd:219-226`, sınır −25/+10
   `b2b_constants.gd:266-267`). Hedef: slot hesabı, olayın verdiği hesap listesi, kararın hattını kullananlar
   (`SprintCatalog.line_accounts` `sprint_catalog.gd:386`).
3. Süren biçim burada tek yerde: `per_sprint` + `until: line_cleared(line) | step_live(step)`; B4'ün ertelemesi ve B6a'nın
   PAPER_TRUST_WAITING'i bunu kullanır, ikinci uygulama yazılmaz. Bitiş `EventBus.line_bugs_cleared` (`event_bus.gd:140`)
   ya da `ProductState.is_feature_live`.
4. W17: iz haftada 2,8 affedilir, satisfaction tikte en çok 21 yürür (`b2b_constants.gd:30, 268`,
   `b2b_sales_system.gd:48-54, 145-146`). Çipin "to"su = `from + iz + 2,8` (sürüklenme sınırıyla). −6 → "58 → 55",
   −8 → "58 → 53"; −3, −2, −1 sıfır görünür. Metin değişmez; görünmeyen izler R'de Erdem'e (soru 2).
5. Kişiye moral: tek fiil (B0'ın `morale_all {scope}` önerisi ya da ayrı ad), kapsam `incident_crew | card_crew |
   speaker`; her kişi `HRMoraleSystem.apply_delta` (`effects.gd:342-353` kalıbı).
6. Ödeyen kuralı (Karar 6) tek fonksiyonda: küme 1 = koşan sprintte olayın hattındaki kartların `assignees`'i ∩
   `not ahead` (`sprint_system.gd:534-549`); küme 2 = `team()` eksi kurucu (`founder: true`; Karar 7 kurucunun yolu);
   ikisi boş → kilit. Küme 2 harfiyen tasarımcı ve PM'i de içerir (varsayılan işleri Yapım, `hr_constants.gd:190-192`);
   W1 örneği içermiyor: R soru 1, cevaba kadar harfiyen (W7).
7. `EFFECT_NIGHT_CREW` (W1, bayt); dört kişiyi geçen listede ilk iki ad + `EFFECT_NAMES_MORE` "ve {n} kişi / and {n}
   more" (B0_ESIKLER; yeni metin, TR/EN onay bekliyor).
8. Çip anahtarı onu ilk kullanan adımda bağlanır: B2 yalnız kendi fiillerinin çiplerini (`EFFECT_TRUST_ACCOUNT(S)`,
   `EFFECT_NIGHT_CREW`, `EFFECT_TRUST_PER_SPRINT`) ekler; kullanılmayan anahtar bırakılmaz.
9. Yeni fiiller dört yere: `WRITER_VERBS` / `SYSTEM_VERBS` (`lint.gd:319-336`), `NEUTRAL_VERBS` / `ECONOMIC_VERBS`
   (`effects.gd:32-75`), `EvChips.describe`, `event_chip_coverage` (`endgame_smoke.gd:15201`); `--event-vocab`,
   `gen_signal_manifest.py`.
10. Kurucu verim izi bugün çalışıyor: `productivity_mod` `"scope": "founder"` (`customer/new_owner.json:117`); yeni yol
    yazılmaz.
11. Kapı: `event_amount_seam`, `event_trust_delta_lasting` (bir tik sonra iz durur, çipteki sayı görünen değer),
    `event_chip_coverage`; `--sprint-probe=hours=8:cards=2:ticks=12:events=1` PRED = CLOSE.

## B3 · Acil durum sistemi, gece, kesinti kartları
1. X1 `IncidentSystem`: durum `GameState`'te tek sözlük (SaveCodec bulur, şema B1'in 17'si); statik durum varsa
   `reset_all_owners` (`save_manager.gd:322`).
2. Tehlike `p = BASE 0,10 × TIER × load_mult() (=1) × (1 + min(costed(open_bugs), 12) / 8)`, **en çok `P_MAX` 0,30**
   (W13, B0_ESIKLER §6; onay bekliyor). `TIER` local 1,5 / cloud 1,0 / enterprise 0,6 `sprint.json` `incident.tier`,
   kademe `InfraSystem.provider()` (`infra_system.gd:125`). `MIN_GAP` 4; B_PLAN'ın `MIN_GAP_AFTER_S1`'i kodlanmaz.
   Zar `EvDice.unit` (`dice.gd:31`).
3. W20: hata terimi `ProductState.costed(ProductState.open_bugs())`.
4. Zar 00:00 günlük dilimde yalnız karar verir, istek yapmaz. Kesinti 00:30-04:30 başlar; istek o gecenin ilk tam
   saatinde saatlik dilimde (`time_manager.gd:426-430`). Damga = açılış saati (W1), parametre gerekmez.
5. Tutuş `hold_clock("incident")` yalnız `request` true dönerse; `HOLD_LABELS`'a (`time_manager.gd:32-37`) `incident`
   (X8). Bırakma `event_resolved`'da ve kart düşerse (başsız koşuda kabuk yok). Toplu adım `_can_step` (`:160`) ile
   kesilir, saat sürünce kalan gece koşar.
6. W21 gece kapısı: `EvQueue.next()` (`queue.gd:60-82`) mesai penceresi dışında yalnız olay kartını verir; olay kartı son
   uyarının (sıra 1) ve kepengin (sıra 0) önündedir. Son uyarı ve kepenk de mesai başına kadar bekler (R soru 10).
7. Kesinti kaydı: `GameState.product.interrupt = {sprint, kind}` (eski kayıtta `.get`); B3 yazar, B7 söz için, B5 kâğıt
   için yazar ve okur. Karar 12: kâğıt gelen sprintte yalnız "servis çöktü" türü (kesinti, ödeme) seçilir.
8. Gönderen (W9): Yapım işindeki ilk yazılımcı `{"employee": id}`; yoksa kartın masa anahtarı "Sunucu uyarısı / Server
   alert" (yeni CSV anahtarı, metin W1'den). `card_sender` masa dalı bugün hep `MAIL_SENDER_SUPPORT` yazar
   (`inbox.gd:383-384`) ve bağlanmamış slot kategoriye düşer (`:18-20`): kartta isteğe bağlı gönderen anahtarı.
9. Ödeyen ve kilit B2'nin fonksiyonu; "Kendin düzelt" kilidi kurucu dışında aktif çalışan > 2 (W1 kilit metni).
10. Bedeller: B2B kredi %10/%15/%25 (7 ve 12 saat) olay anındaki `mrr`'den, `apply_one_time_cost(t, "outage_credit")`
    (`finance_system.gd:188`; yeni etiket → `FIN_ONETIME_OUTAGE_CREDIT`, W10), `mrr` değişmez. Sabah yolu iz −0,6/saat en
    çok −8, kredide %85 silinir. B2C kitle %0,3 × saat en çok %4; ücretsiz ay = kişi × ödeyen ÷ kitle × fiyat
    (`sales_system.gd:279, 288`), etiket `refunds` (var).
11. Kartlar `product.incident_outage_b2b`, `_b2c` (W1 bayt; `system: true`, `tags` `critical`, `urgent`, `incident`,
    `tick: request`); `outage.json` ve `EV_PRODUCT_OUTAGE_*` silinir.
12. Prob (X7, W11, W12): `sprint_probe.gd:55-58` `market` ve `incident` dize dalı; `market=b2b` → `choose_type("erp", …)`
    (`:72`) ve fikstür B2B hesaplar; `run_probe.gd:743` `skip_night()` ardından `_answer()`; `PROBE LINES` (`_log_bugs`
    `:585` yanında) ve `PROBE SHIP … faulty=` (`:309`). Harness değişikliği ayrı raporlanır.
13. Brief düzeltmesi: PRD'nin rolleri (tasarımcı, geliştirici, testçi) **`team=4`** (`HIRES` `sprint_probe.gd:40-41`;
    işi `CharacterRegistry.add` verir `character_registry.gd:445-448`). `team=3` kurucu + geliştirici + tasarımcıdır.
14. Kapı: `incident_gap_and_spread` (300 hafta; `P_MAX` 0,30 ile local'de de ≥ %30), `incident_night_hold_resumes`
    (falsification), `incident_scale`, `incident_save_roundtrip`; `--why-fire` iki kart; plausibility. Görsel
    `--event-shot` iki kart TR/EN, `--inbox-shot` gece kartı, `--clock-shot=held`. B0_ESIKLER §0'ın 8 `PROBE LINES`
    koşusu eşikleri teyit eder.

## B4 · Kalan acil durum kartları, "Sprinti durdur", bot
1. Kartlar `customer.incident_month_close`, `product.incident_checkout`, `product.incident_regression`,
   `product.incident_review_storm` (W1 bayt). Damga açılıştan önce: `EventGate.request`'e damga parametresi burada eklenir.
2. W23 ay sonu haftası: ertesi tikin takvim ayı farklı (`GameState.get_date_dict`, `summary_system.gd:57-59`); hatlar
   `line_erp_invoicing/ledger/cashflow`, eşik `MONTH_CLOSE_LINE_BUGS` 3; slot `SprintCatalog.line_impact(line).top_id`
   (`sprint_catalog.gd:405-417`), `{"customer": id}`.
3. W9 ay sonu unvanı: gönderen `contact()` (`inbox.gd:422-428`) ama unvan sabit "Finans Müdürü / Finance Manager":
   kartta unvan anahtarı, `contact` dalı okur (yeni CSV anahtarı W1'den). B8'in teşekkürü bunu kullanmaz.
4. W22: fırtına yalnız 4 ortak hatta (`line_shared_*`), `STORM_LINE_BUGS` 7, kitle ≥ 2.000; B2C bozulma 4 ortak hat;
   B2B bozulma `REGRESSION_CRITICAL_LINES` 7 hat. Not hatları olay doğurmaz.
5. Bozulma yolu: `release.faulty` (`sprint_system.gd:1089`) ∩ kritik hatlar, `version_shipped` (`:1102`) sonrası ertesi
   mesai başı + 10-50 dk. W4: `faulty` bugün hiç dolmaz; smoke fikstürle (`c.faulty`) kurulur, §4.12'de ⚠️ (R soru 5).
6. W25 "Sprinti durdur": yeni fiil `sprint_fix_first {line}`; `fix_first` (`sprint_system.gd:211-225`) gövdesi "kartı
   sprintin başına taşı" yardımcısına ayrılır, B6a'nın yenileme kâğıdı istek kartını aynı yoldan taşır.
7. W3 kayan kart: önizleme `plan_outcome(ids)` (`:584-598`) iki kez okunur (bugünkü sıra / düzeltme kartı başta);
   `finishes` true → false düşen kartın adı `SprintCatalog.card_name` (`sprint_catalog.gd:283`). Sprintin son gecesinde
   gelen ay sonu kartı yeni sprintin kartlarını okur (W1 notu).
8. W8 ödeme: hattı yok → `ProductState.add_bugs(SprintCatalog.PAID_PLAN, 1)` + `sprint_fix_first(PAID_PLAN)` ("Ücretli
   plan düzeltmesi", efor 1; `candidates` `sprint_catalog.gd:237-242`). `cap_paid_plan` anahtarını okuyanlar
   doğrulanır: `rnd_system._demand_line` (`:597-606`) adı `cap_name` ile yazmalı; `account_bugs` yalnız B2B.
9. W18 "Ödeyen −7 · MRR −$56": ödeyen kitleden türer (`sales_system.gd:233, 288`), seam yok. R soru 3; cevaba kadar
   öneri (a): kitle −(ödeyen ÷ dönüşüm), çipe var olan kitle çipi.
10. Erteleme: B2'nin süren `trust_delta`'sı (B2B −6 + sprint başı −3), B2C kitle haftada −%2 IncidentSystem'de;
    `line_bugs_cleared` ya da düzeltme sürümüyle biter. `_close` önce `clear_line_bugs` (`:1032`) sonra `sprint_closed`
    (`:1103`) yayar: aynı kapanışta düzelen hat −3 almaz. Ay sonu sabah yolu −3 [onay bekliyor].
11. W27 bot: `_pick_choice` (`run_probe.gd:661`) olay dalı `customer.` dalından önce, fiile göre: `fix_none` → erteleme
    (kilitliyse ilk açık), öbür kollar → `sprint_fix_first`; "Sprinti durdur" hiç seçilmeyen ikinci koşu bayrağı.
12. §4.4: ortaya giren düzeltme kartı da düzeltme yüküdür; `PROBE FIX` yalnız sprint başında basılır
    (`run_probe.gd:317-329`): ayrı satır ya da kapanışta yük.
13. §4.11 A'nın 8 kolu (`run_probe.gd:94-101`) olaylar açık; A'nın kendi tutmayan iki hücresi (B2C erken düzeltme payı
    %50, RAPOR_A §1.2) taban olarak okunur. B2C ekonomisi A'dan sonra büyük (kitle ≈ 235 bin): oransal bedeller büyür,
    ekonomi kayması raporlanır.
14. Kapı: `--why-fire` dört kart, plausibility, `run_gate.sh`, §4.7 `--sprint-probe=…:events=1:incident=<tür>@<tik>`
    "Sprinti durdur" PRED = CLOSE. Görsel `--event-shot` dört kart TR/EN.

## B7 · B2B söz olayı
1. `product.promise_due` (W3 bayt): `_end_week`'in son haftasında (`sprint_system.gd:738-764`), koşan sprintteki karta
   `due_sprint == sprint_number()` açık söz (`PromiseRegistry.get_all` `promise_registry.gd:30`) ve kart yetişmiyor.
2. W28: `decision_card_late` ve `crunch_finishes` (`:652-682`) kart kimliği alır; karar kartı sürümü bunu çağırır.
3. Konuşan o aşamadaki atanan `{"employee": id}`; yoksa "Kendine not". Mesai içinde teslim (B1).
4. X3 `sprint_card_test {cut}`: kalan test işi yarıya iner; tek fonksiyon `SprintSystem.escape_chance(card)` = bugün
   `faulty_chance if c.faulty else 0` (yani 0), kesilince `max(önceki, sprint.json promise.cut_test_escape 0,15)`;
   `_close` zarı (`:1048`) ve çip `EFFECT_BUG_CHANCE` ondan okur (Karar 14). Bu, W4'ün bugünkü tek kaynağıdır.
5. Fazla mesai: `sprint_hours` ×1,25 (`set_hours_mult` `:349`) + B2'nin kişiye moral fiili (`card_crew`, −5); kilit:
   karttaki `crunch_finishes` yanlış.
6. X4: `Promise` (`scripts/data_models/promise.gd`) `@export var extended := false`; `promise_extend` `due_sprint += 1`,
   `extended = true`, `trust_delta` −6 (çip B2 kuralıyla "58 → 55"); kilit `extended`.
7. `promise_break`: `PromiseRegistry`'ye kamuya açık `break_promise(id)` (`_resolve(p, "broken")` `:164`); zincir
   `on_promise_resolved` (`b2b_sales_system.gd:391`) aynen; çip `EFFECT_PROMISE_RELOCK` (`PROMISE_RELOCK_WEEKS` 8,
   `b2b_constants.gd:153`).
8. Kesinti kaydına `kind: "promise"` (B3'ün alanı); sözlü kartta `product.sprint_late` gelmez.
9. Uzatılmış sözün ödülü (tam mı yarım mı) W3'ün Erdem sorusu; kod bugünkü `kept`'i (tam) kullanır.
10. `docs/ACIK_ISLER/ISLER.md`'ye W3 `rule.isler_b2c_promise` satırı.
11. Kapı: `--why-fire`, plausibility, `run_gate.sh`, `inbox_no_night_stamp`, var olan söz vakaları; §4.7 "Testi kısalt"
    B2B, `team=4` + söz fikstürü, PRED = CLOSE. Görsel `--event-shot=product.promise_due:customer=<fikstür>` TR/EN.

## B5 · Kâğıt motoru
1. `decision.rate` ve kart başı haftalık `hash()` zarı (`sprint_system.gd:852-873`) kalkar; sprint başına tek zar
   (`EvDice.unit`), sabit `decision.sprint_chance` [onay bekliyor], 1 ve 2 haftalık sprintte ayrı (≥ ⅓ boş).
2. W24: `decision.rate`'i okuyanlar güncellenir: `sprint_probe.gd:60-61`, `endgame_smoke.gd:5794, 5800, 18355-18398`.
3. X5: `product.decision_sprint` (`new_state` `:77-87`, eski kayıtta `.get(…, -1)`); B3'ün `interrupt` kaydı okunur:
   söz ya da acil durum gelen sprintte kâğıt yok, kâğıt gelince kayıt yazılır.
4. W16 konuşan isteğin anında: `_begin` 1 haftalık sprintte `_request_decision`'ı `_assign`'dan önce çağırır
   (`:166-169`), kartların `assignees`'i boştur → önce `_assign`, karar kurulunca yeniden. Karar kartının `assignees`'i
   sonraki `_assign`'da silinir (`:777-779`); smoke konuşanı `card_decision_requested` anında yakalar.
5. Konuşan `EventGate.request(event_id, {"employee": id})` (kurucu ise founder slotu), rol `role_of` (`:1287`) ve kişinin
   karakter rolü kâğıdın `speaker_role`'üne uyar: PM tasarım fazında da atanabildiği için (`_assign` `:783-784`)
   tasarımcı kâğıdını PM söylemez.
6. PM kâğıdı: `SprintCatalog.quarter_pm()` (`sprint_catalog.gd:495`) + sprintte planlı istek kartı (`open_requests`
   `:709`); PM yoksa gelmez. Karar 10'un "PM kart almaz"ı ile `_assign` çelişir: R soru 9; A'nın atamasına dokunulmaz.
7. Mandal 52 hafta + en çok 3, `latch_key: run`: `blocked_reason` ikisini birlikte uygular (`latches.gd:56-76`); yanlış
   yorum ("alternatives, not a stack", `:79`) düzeltilir. Ağırlık `1 / (1 + 2 × görülme)` (`EvLatches.fires`).
8. Payının tamamı Destek'te olan `team()`'de yoktur (`_share` `:1326-1328`) ✅.
9. Prob: `SPRINTPROBE PAPER|<seed>|<sprint>|<event_id>|<speaker>` ve boş sprint oranı; §4.5 ölçümü `team=4`.
10. Kapı: `paper_speaker_is_assignee` (falsification), `decision_one_per_sprint`, `decision_no_fourth_show`, §4.1 smoke
    yeniden, `inbox_no_night_stamp`. Görsel `--product-shot=live:decision_paper` TR/EN.

## B6a · Kâğıt içeriği 1
1. Bölme önerisi (brief'teki "20 + 20" yerine): **B6a = PM 6 + tasarımcı 7 + testçi 8 = 21**; B6b = yazılımcı 10 +
   testçisiz 3 + tek kurucu 6 = 19 + `sprint_late`. Bölme fiil bağımlılığına göre; B6a renk kâğıtlarını birleştirir
   (`sprint_hardcoded_colors` + `sprint_colors_again` → `sprint_design_customer_colors`, W2 `existing_tr`).
2. X3 `sprint_card_trim`: `{share}` kartın eforundan pay çıkarır; `{follow}` aynı işi +1 ile sonraki sütuna kart koyar.
   W26: `plan_next` kademesi tutan özellik/talep kartını siler (`sprint_system.gd:182-185`), takip kartı silinmemeli;
   `{bugs n[, line]}` kapanışta `pending_faulty`'ye (`:1062`) girer, `release.faulty`'ye değil.
3. W26 bilgi çipleri `EFFECT_CARD_LATE` / `EFFECT_CARD_ON_TIME`: etkisiz ama etiketli fiil, çip `plan_outcome`'tan;
   `SILENT_VERBS`'e girmez.
4. PAPER_TRUST_WAITING: B2'nin süren `trust_delta`'sı, `until: step_live`; çip `EFFECT_TRUST_UNTIL_SHIPS`.
5. X6 `SprintBridges.next_renewal_day(c)`: `tick_requests`'teki ifade (`sprint_bridges.gd:28-35`) tek yerde, iki yer onu
   okur; `RENEWAL_WINDOW` 12.
6. `pm_renewal` "Kartı başa al": B4'ün başa taşıma yolu, karar kartıyla. İndirim etiketi R soru 8 (öneri var olan
   `retention`).
7. W19 `pm_two_accounts`: `urun.decision_second_account` talep verisinden; bugün hiç dolmaz → uykuda bağlanır, R'de ⚠️.
8. `test_coupon`: tetik Entegrasyonlar hattından kart (W2'nin kendi geri dönüşü, W8); "Kuponları kapat" R soru 3'ün
   cevabıyla.
9. Slotlar: en büyük hesap `line_impact().top_id`; depo sektörleri `logistics, manufacturing, retail`; `SLOW_SEATS` 15;
   en yeni hesap `acquired_on_day`. Yeni seam'ler `urun.decision_second_account`, `urun.decision_request_votes` (B2C,
   C'ye kadar boş), `urun.cut_test_finishes`, `urun.decision_line_name` (`SprintCatalog.cap_name`).
10. Sabitler `sprint.json` `paper` bloğu [WORKING]. Kapı: `--why-fire` her kart, plausibility, metin eşliği
    (`textparity.py`), birkaç kâğıt TR/EN görsel.

## B6b · Kâğıt içeriği 2 ve ölçüm
1. Yazılımcı 10 + testçisiz 3 + tek kurucu 6 + sistem kâğıdı `product.sprint_late` (bugünkü `sprint_late.json`
   güncellenir). `sprint_rewrite_bugs/owner/reader` silinir; `sprint_two_paths` → `sprint_dev_shorter_path`;
   `decision.cards` 40 kimlikle.
2. X3 `line_harden {weeks}` + W6: `GameState.FLAG_TYPES`'a `mvp_line_harden` ({hat: bitiş tiki}); `line_blocked`
   (`product_state.gd:238`) okur. W2: `_land_faulty` (`sprint_system.gd:1126-1132`) da sorsun mu kararı B6b'nin, raporda.
3. Hemen hata (`EFFECT_NEW_BUGS`): `ProductState.add_bugs(line, n)` (`:208`) çağıran tek fiil; sözlükte kolsuz
   `damage_product` (`effects.gd:43`) bu kolu alabilir.
4. `dev_shorter_path`: `sprint_card_progress` + `amount_seam` `urun.decision_card_done`.
5. `founder_test_pile` B7'nin `sprint_card_test`'i; `untested_old_screens` kurucu varyantında kilitli seçenek.
6. `solo_license` `urun.decision_license_year`, etiket `build_commit` (lisans bugün bu etiketle, `sprint_system.gd:163`);
   `solo_server_bill` ve `test_devices` etiketi R soru 8.
7. `solo_backup` `line_tier("line_shared_durability") == 1`; `solo_signup_code` B4'ün `sprint_fix_first`'i.
8. Tek seferlik ölçüm: §4.1 (104 hf × 10 tohum; bot cloud'da), §4.5 (iki pazar, 1/2 haftalık ayrı, toplam kesinti),
   §4.11 (A'nın kolları, ikinci koşu), §4.12 (`fix_worst`'te tür ve rol sayıları; bozulma W4 nedeniyle ⚠️, PM'in botta
   istek kartı riski B0_ESIKLER §3.4).

## B8 · Sürüm anı
1. `customer.release_thanks` seçeneksiz **not kartı** (mesaj değil): `{"customer": id}`, gönderen `contact()`; mandal
   `latch_key: entity` ve açık cooldown (yoksa `DEFAULT_COOLDOWN_WEEKS` girer, `latches.gd:83-85`).
2. Tetikler: IncidentSystem "hızla kapandı" bayrağı; `promise_kept` (`promise_registry.gd:171`) yalnız `status ==
   "kept"` (partial aynı sinyal); `requests[].status == "met"` (`sprint_bridges.gd:60-64`).
3. X8 sayaçlar: hesap başına sürümde 1, sürümde 3, söz > istek > acil durum; kayıtta.
4. `{seam:musteri.met_feature}` (ad `PROD_STEP_*`).
5. B2C yorum satırı `_fill_actual` (`sprint_system.gd:1145-1153`) anında seçilir, sürüm kaydına id olarak; seam
   `urun.release_feature`; W22: olumsuz yorum 4 ortak hat + kimlik hatları grubu, eşik `RELEASE_REVIEW_NEG_LINE_BUGS` 5.
6. Koyu dil `D_*`; `--theme-contrast-audit`. Kapı: `--why-fire`, plausibility, `inbox_no_night_stamp`; her teşekkür türü
   bir vakayla. Görsel teşekkür maili ve yorum satırı TR/EN.

## B9 · Yatırımcı hazırlığının kalkması
1. Önce geçici kol: `full_run_vc_cautious` (`run_probe.gd:87`) her Series A görüşmesinden önce
   `VCPitchSystem.start_prep` (`vc_pitch_system.gd:871`); 10 tohum × 2 kol imza oranı, `PREP_BONUS` 2
   (`pitch_constants.gd:76`) ile ve onsuz geçme ihtimali. Kol B9'da silinir.
2. Silinecekler B0 §10 ve B0v ekleri: `hr_system.gd:150-155, 205, 224, 248-249`; yorumlar `seed_round_system.gd:83`
   (`prep_blocked_reason`'a atıf), `vc_pitch_system.gd:11, 16, 69-71`, `rnd_system.gd:163`; `_prep_focus` statik değişkeni
   (`vc_pitch_system.gd:38`); `seams_hr.gd` `founder.task_state` açıklaması.
3. W15: yükleyici `prep` ve `pitch_prep_active`'i her yüklemede düşürür (`_decode_flags` `save_codec.gd:218-240`
   bilinmeyeni korur); `save_manager.gd:693` v13 damgası.
4. `MEETING_CHIP_PREP` satışta kalır (`sales_meeting_adapter.gd:31-33`); VC satırı (`vc_meeting_adapter.gd:166-168`)
   gider. CSV byte-span: `HR_FOUNDER_STATE_PITCH_PREP`, `HUNT_PREP_*`, `HUNT_FOCUS_*`, `VC_PREP_*`.
5. Kapı: `--event-vocab`, VC smoke'ları, `run_gate.sh` (`full_run_vc_cautious` bir sonla biter); görsel Series A
   sekmesi, `--meeting-shot=open`.

## Brief taslağında düzeltilenler
- B1: 00:00 yolundaki kart 70; `weekly_sales_report_issued` taşınmaz; varlık okuması `sprint_system.gd:881-882`.
- B2: ödeyen küme 2'den kurucu çıkar, tasarımcı ve PM girer (harfiyen; R soru 1); çip "to" kuralı (W17).
- B3: `team=3` (tasarımcı, yazılımcı, testçi) yanlış → `team=4`; `P_MAX` 0,30 eklendi; gece kapısı `EvQueue.next()`.
- B4: "A'nın girişi" `SprintSystem.fix_first` + yeni fiil `sprint_fix_first`; ödeme kartı `cap_paid_plan` yolu; damga
  parametresi B4'te (B0t'deki "B3 ekler" eski).
- B5: konuşan isteğin anında yakalanır, `_begin` sırası değişir; seçici değil slot bağlama.
- B6: "20 + 20" yerine 21 + 19 (+ `sprint_late`) önerisi; takip kartının `plan_next` tuzağı.
- B7: geç kalma ve fazla mesai yüklemleri kart kimliği alır.
- B8: teşekkür `MessageSystem` mesajı değil, not kartı.
- B0 haritası: W1 ve W14 kapandı; W4 "hiç dolmuyor"a, W7 "küme 2 harfiyen"e döndü.

## Erdem'e sorular (R'ye girer)
1. **Gece düzeltmesinin bedelini kim öder (Karar 6, küme 2)?** PRD "Yapım ya da Test işine atanmış herkes" der; tasarımcı
   ve PM'in varsayılan işi Yapım, yani onlar da öder. W1 örneği yalnız yazılımcıyı saydı. Kod harfiyen uygular (kurucu
   hariç, onun yolu "Kendin düzelt"); yalnız yazılımcı ve testçi mi olsun?
2. **Küçük memnuniyet izleri görünmüyor.** İz haftada 2,8 affediliyor: −6 bir hafta −3, −8 bir hafta −5 görünür;
   Karar 8'in sprint başı −3'ü, kesintide "öbür hesaplar" −2'si ve kredili −1 hiç görünmez. "Ertelemeyi alışkanlık
   yapan kaybedebilir" bu sayılarla olmaz. (a) Sayılar C'de eşikle birlikte ölçülsün, çipler görünen değeri yazsın;
   (b) süren erteleme bedeli affedilmeyen ayrı bir izde dursun; (c) küçük izler en az −6 olsun. Öneri (a).
3. **"Ödeyen −7 · MRR −$56" yazılamıyor.** Ödeyen kitle × dönüşümden türüyor, yalnız ödeyeni düşüren bir yol yok (ödeme
   olayı ve kupon kâğıdı). (a) Kitle ödeyen ÷ dönüşüm kadar düşsün (7 ödeyen için yaklaşık 82 kişi), çipe var olan kitle
   çipi eklensin; (b) geçici bir dönüşüm cezası (yeni mekanik); (c) bedel kitle kaybı olarak yazılsın (metin değişir).
   Öneri (a).
4. **"İki hesap aynı kartı istedi" kâğıdı hiç gelmez.** Bugün bir kademeyi yalnız bir hesap isteyebiliyor. (a) Kâğıt
   bağlansın, C'nin talep verisine kadar uyusun (⚠️); (b) talep kuralı değişsin. Öneri (a).
5. **Sürüm sonrası bozulma bugün hiç gelmez.** Hatalı sürüm yalnız test aşamasını test bilmeyen biri yaparsa doğuyor,
   ama test aşamasında çalışabilen herkes (yazılımcı, testçi, kurucu) test biliyor. Olay D'ye kadar yalnız "Testi
   kısalt" ve "Ana akışları test et" seçimlerinden doğar. §4.12'de ⚠️ kabul mü, yoksa D'ye kadar geçici bir kaçma
   ihtimali mi?
6. **Olay tavanı `P_MAX` 0,30** (planda 0,6): local sunucu ve çok hatada aralıkların %30'unu 4-6 hafta dışında tutmak
   için. `BASE` 0,10 kalır, cloud ve enterprise etkilenmez. Onay?
7. **Olay türlerinin karışımı:** B2B'de olayların yaklaşık %95'i gece kesintisi (ay sonu koşuların %40'ında bir kez);
   B2C'de ödeme alınamıyor kesinti kadar sık (koşu başına yaklaşık 5'er). Ağırlıklar böyle kalsın mı?
8. **Finans satırı adları:** yenileme indiriminin "İndirim" satırı dalgada yazılmadı; var olan "Bağlılık primi /
   Retention bonus" mu kullanılsın, yeni "İndirim / Discount" mı? Sunucu faturası ve test telefonu giderlerine uyan var
   olan satır da yok: yeni satır mı, en yakın var olan mı? (Ücretsiz ay "İadeler", serbest çalışan "Dış kaynak ücreti",
   lisans "Özellik maliyeti" ile yazılır; yeni olan yalnız onaylı "Kesinti kredisi".)
9. **PM sprintte kart alıyor.** Kod PM'i sprint kartlarının tasarım aşamasına da atıyor; Karar 10 "PM sprintte kart
   almaz, önden gider" der. Bu yalnız kâğıt kuralı mı (öneri; atama değişmez), yoksa atama mı değişsin?
10. **Gece yalnız acil durum kartı (Karar 4):** son uyarı ve kepenk kartı da artık 08:00'de değil mesai başında açılır.
    Kabul mü?
11. **Dalgaların kendi soruları** R'ye aynen taşınır: B2C ücretsiz ay ucuz (W1 kesinti ve fırtına notları), ay sonu
    sabah yoluna −3 (W1), uzatılmış söz tutulunca ödülün tamamı mı yarısı mı (W3).
12. **Onay bekleyen yeni metin ve eşikler:** `EFFECT_NAMES_MORE` "ve {n} kişi / and {n} more"; B0 eşikleri (ay sonu 3,
    fırtına 7, olumsuz yorum 5, kök neden 3, yenileme penceresi 12 hafta, gece deneme payı %1,5/saat, sektör ve hat
    listeleri).
