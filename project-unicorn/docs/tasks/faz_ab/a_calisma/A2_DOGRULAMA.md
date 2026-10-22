# A2 · Haritanın doğrulanması (Opus, HEAD 1faeb82, 2026-10-16)
Girdi: A1a (155 satır), A1b (126 satır), A1c (200 satır), K0_KESIF, PLAN_A, PRD. Çıktı: birleşik `A1_HARITA.md`
(başta dilim dizini, sonra üç katman, her katmanın sonunda A2 ekleri) ve bu not. Repo'da yalnız `a_calisma/` yazıldı.

## 1. Ne denetlendi
- **Satır başvuruları.** 353 dosya:satır başvurusu betikle açıldı ve satırın iddia edilen tanımlayıcıyı taşıyıp taşımadığı
  sınandı (K1, K3, K5 satırlarının hepsi; K2, K4, K6 ve arayüz satırlarının çoğu). Sapmaların hepsi ±1-3 satır
  aralığındaydı; yanlış dosya ya da yanlış fonksiyon yoktu.
- **Fonksiyon tanımları.** `sprint_system.gd`, `support_system.gd`, `product_state.gd`, `product_system.gd`,
  `sprint_catalog.gd`, `sprint_bridges.gd` tanım listesi haritayla karşılaştırıldı.
- **Smoke vakaları.** Haritada adı geçen 70 vakanın ve 10 yardımcının tanım satırı doğrulandı (hepsi doğru).
- **CSV.** Haritada geçen 36 anahtarın satır numarası doğrulandı (hepsi doğru).
- **Elle okunan kod yolları.** `team()`, `_assign`, `_work`, `_play_out`, `_end_week`, `_close`, `_go_public`,
  `_refresh_fix_cards`, dinleyiciler; Destek akışı, `_drain`, masa sayımı; `effective_skill`, `founder_task_*`,
  `_validate_shape`, `_founder_start_area`; kalite okuması; satış, B2B hedefi, `risk_voice`, `risk_reason`; VC geri dönüşü,
  `_weakest_dimension`, `series_a_road_closed`; `RngStreams`; göç zinciri ve `reset_all_owners`; bot B2C kolu ve Hotfix
  bloğu; ofisin açılış toplantısı.
- **Tamlık süpürmesi.** İstenen bütün aileler (`bugs_confirmed`, `BUGS_CONFIRMED`, `live_bug`, `mvp_bug`, `ticket`,
  `voices`, `fix_run`, `FIX_RUN`, `bug_pile`, `gate_faulty`, `urgent_tickets`, `_post_ship_wear`, `wear`/aşınma,
  `reports_missed`, `REPORTS_WEEK_NET`, `founder_passive_care`, `focus_mult`, `team()`, `capacity()`, `role_of`,
  `assignees`, `week_points`, `_validate_shape`, `axis_stability`, `effective_stability`, `economy_dims`, `bugs_under`,
  `CALLBACK_BUGS`, `VC_Q_BUGS`, `STABILITY_BUGS`) ve yakınları (`founder_roles`, `faulty`, `desk_roster`,
  `desk_staffed`, `validation_per_day`, `reports_per_day`, `warmth_band`, `bug_confirmed`, `build_progress_changed`,
  `sync_tickets`, `tickets_by_line`, `is_urgent`, `area_alert`, `COMPLAINT_BUG_GATE`, `risk_reason`, `risk_voice`)
  `scripts/ scenes/ data/ tools/ localization/strings.csv docs/` (docs/tasks ve docs/mockups hariç) ile `GDDs/*.md`
  ve `sandbox/` üzerinde arandı. Her eşleşme bir harita satırının aralığına ya da adı haritada geçen fonksiyona
  düşmüyorsa elle bakıldı. Smoke'ta eşleşme, içinde bulunduğu `_case_` vakasına bağlandı.
- **Dinamik anahtarlar.** `"PRODUCT_*%s"`, `"+ area.to_upper()"`, `"HR_FOUNDER_STATE_%s"`, seam adı birleştirme
  (`"urun." +` yok) arandı. A1c'nin §11-B listesi tamdır; `PROD_RND_NODE_%s_*` aileleri ayrıca bulundu (A ekleri).
  `scenes/` ve `sandbox/` içinde aile eşleşmesi yok.

## 2. Yapılan düzeltmeler (16)
1. **A1b `founder_roles` satırı:** "Kurucu Test'e uyduğu için zar atılmıyor" eksik. Zarı geliştirici ve test uzmanı da
   engeller (aşağıda §3).
2. **A1b §8 K1 satırı:** "Karar 13'ten sonra zarın atılıp atılmadığı değişir" yanlış. Değişmez.
3. **A1b §10 madde 4:** "Kurucu Destek'e geçip ekipte tester yoksa zar ilk kez atılır" yanlış. Geliştirici `test`'e uyar.
4. **A1b B2C kolu satırı:** "Yalnız bu kol etkilenir" yanlış. Hotfix bloğu (`run_probe.gd:1111-1117`) iki pazarda da
   geliştiriciye Destek'i ikinci iş verir; K1 sonrası `full_run` (B2B) da kayar.
5. **A1a B2C bot satırı:** aynı bulgu eklendi.
6. **A1a doğrulama satırı:** "`VALIDATION_BANK_MAX` 60" satır numarasıydı; değer 1,0'dır (`support_system.gd:60`).
7. **A1a `_validate_shape`:** "kayıt yüklemede ve kayıtta" değil, yalnız `add()` ve `insert_raw()`'da koşar.
8. **A1a `_validate_shape`:** yorum satırı 496-497 değil 498-499.
9. **A1a hatalı hatlar kuyruğu:** sessiz düşüş yalnız "canlı değil ve kapı değil" hâlinde değil; canlı üründe kapanış
   sürüm çıkarmıyorsa da (yalnız araştırma ya da bileti boşalmış düzeltme kartı) olur (`sprint_system.gd:1032-1042`).
10. **A1a Risk 8:** "eski kayıtta akış yok" sorun değil. `RngStreams.from_dict` kayıtta olmayan akışı `run_seed`'den
    kurar (`rng_streams.gd:67-70`); yeni akış kayıt uyumludur. Ek: bugünkü zar `run_seed` okumaz.
11. **A1a Kaçırılan bildirim satırı:** `main.gd:1292-1304` → `desk_shut` 1289-1294, `fix_run` 1295-1306.
12. **A1a Risk 9, §8 satırı; A1b VC göç satırı ve §10.8:** "40" eşitliği değil **ölçek** sorunu (PLAN ETKİSİ, §5.1).
13. **A1a sprint dinleyicileri:** `employee_hired` ve `training_started` de `_on_assignment_changed`'e bağlı (901-902).
14. **A1a pasif ilgi satırı ve A1c §0-1:** oyuncu kurucunun işini yalnız Yapım ↔ Ar-Ge değiştirebilir; işsiz kurucu da
    Yapım+Destek kurucu da oyuncuda doğmaz (yalnız bot, debug, eski kayıt).
15. **PLAN_A K1 "Kurucu":** "Başlangıç işi Test olabilir (`game_state.gd:978-983`, QA en yüksekse)" yanlış.
    `_founder_start_area` yalnız Ürün, Tasarım, Yazılım'a bakar (`game_state.gd:576-584`); başlangıç her zaman Yapım.
    (A1a §0.2 bunu bulmuştu; plan düzeltilmemişti.)
16. **PLAN_A K2:** `fix_run` çekimi `main.gd:1295-1304` değil 1295-1306.

Satır numarası sapmaları dışında A1a, A1b ve A1c'nin dilim atamalarında yanlış bulunmadı. Çok dilimli kalemlerde (ör.
C'yi okuyan satış satırları: K3 ara geçiş, K5 silme) atama haritada zaten iki dilimlidir.

## 3. PRD §6 "Bilinen gerçek": %40 hatalı kapanış zarı K1'den sonra atılmaya başlar mı?
**Cevap: HAYIR.** Zar bugün de atılmaz, K1'den sonra da atılmaz. PRD'nin gerekçesi ("kurucu her rolü tutuyor") tek
sebep değildir; kurucu sprintten çıksa da sonuç aynıdır. Kanıt zinciri:
1. Kart ancak Test fazı (faz 2) `test` rolüne uymayan biriyle yarı hızda yapılırsa hatalı işaretlenir:
   `sprint_system.gd:791` (`speed = 1.0 if _role(c, at) in person.fits else no_role_speed`) ve 795-796.
2. Zar yalnız işaretli kartta atılır: `sprint_system.gd:1027` (`faulty_chance` 0,4, sprint.json:28).
3. Test fazına kimin girdiği: `_assign`'ın süzgeci `(at == 0 or not p.ahead)` (765-766) ve `_work`'ün döngüsü
   `(at == 0 or not person.ahead)` (790). `ahead = not (fits.has("dev") or fits.has("test"))` (530). Yani Test fazını
   yalnız `dev` ya da `test` rolüne uyan biri yürütebilir.
4. `fits` işlerden değil rol alanlarından gelir: `_fits` (1272-1276), `role_areas` (sprint.json:19: dev = engineering,
   test = qa), `ROLE_AREAS` (hr_constants.gd:86-95): geliştirici {engineering, qa} → dev + test; test uzmanı
   {qa, engineering} → test + dev; tasarımcı ve PM → `ahead`; satış ve müşteri temsilcisi → `fits` boş, `team()` dışı
   (527). Kurucu `founder_roles` ile dört role uyar (sprint.json:23).
5. Sonuç: `dev`'e uyan herkes `test`'e de uyar. Test fazına girebilen hiç kimse `test` rolsüz değildir; `faulty`
   hiç true olmaz.
6. K1 yalnız `team()`'i işe göre süzer ve pay uygular; `_fits`, `founder_roles`, `no_role_speed` PRD Karar 13 sınırıyla
   değişmez. Kurucu sprintten çıkarsa geriye geliştirici/test uzmanı kalır, onlar da `test`'e uyar. Ekipte yalnız
   tasarımcı/PM kalırsa Test fazını kimse yürütemez: kart hatalı değil, tıkalı kalır (A1a Risk 3).
7. Ters kanıt: `sprint_faulty_ticket_deterministic` (endgame_smoke.gd:17447-17478) zarı çalıştırmak için kurucu rollerini
   `["product","dev"]`'e indirir (17451), tasarımcı alır (17449) ve "ekipte Test rolü olan var" ise fikstürü reddeder
   (17453). Zar yalnız test sabiti değişince atılır.

**K1 raporu için:** Zar ekonomi kayması sebebi değildir. K1'in kayması pay (0,5) ve bot kollarından gelir. Koruma olarak
K1, `_fits`'in işten bağımsız kaldığını mevcut vakalarla doğrular; zarı D değiştirir.

## 4. Haritada olmayan, eklenen eşleşmeler (34 satır)
Ayrıntı ve satırlar `A1_HARITA.md`'de, her katmanın sonundaki "A2 · Bu katmana eklenen satırlar" tablosunda.
- **Katman A (11):** `product_catalog.gd` `complexity` alanı ve `get_feature_by_id` (karmaşıklıkla ölür; yorum yanlış);
  `event_bus.gd:137` yorumu; `game_state.gd:300-301` yorumu; satış yorumları (`sales_system.gd` 27-30, 100-105, 180,
  434-436, 455-457); B2B hedef yorumu (`b2b_sales_system.gd:130-132`); Meridian'ın ürün geri dönüşü ve
  `series_a_road_closed`; `PROD_RND_NODE_CICD_*` karşılıksız vaat metni; hata trendi zincirinin 8 CSV anahtarı;
  kurucunun iş değiştirme yolu; hatsız canlı ürün fikstürleri; canlıdaki sessiz hatalı kart düşüşü.
- **Katman B (11):** `axis_readings` hata parametresi (`product_state.gd:254-256`, `quality_model.gd:239-245`);
  PROBE CUST `health` (`run_probe.gd:505`); `run_probe.gd:1711` yorumu; Hotfix bloğunun iki pazarda çalışması;
  `sprint_solo_mvp_by_week_six`; `cs_renewal_floor`; `series_a_road_closed_when_all_funds_close`;
  `b2c_value_reads_live_lines`; `destek_empty_desk_piles_up` falsifikasyon yorumu; 22 K1 regresyon vakası (tek satır);
  `_migrate_15` açıklaması (805-810).
- **Katman C (12):** ACIK_KARARLAR 96 alt maddeleri, 97, 99, 44, 59, 1569-1573; ISLER 56-58 ve 118-119; HARITA:168;
  `main.gd:3125-3129` yorumu; ofiste kurucunun masa animasyonu (`office_people.gd:666-672`); `docs/audits/` tarihçesi
  (arama dışı, yalnız kayıt için).

Gürültü olarak elenenler: "invoice/voices", "taşınma/aşınma", "wear" (görünüş), `desk_papers`, "bug fix" yorumları,
`EV_TEAM_CONFERENCE_*` ("bilet"), `B2B_EV_REQ_COMPLAINT_EXPIRED` ("ticket" = kayıt), `PROD_FEAT_SAAS_BILL_PRORATION_VOICE`.

## 5. Onaylı planı değiştiren bulgular

### 5.1 PLAN ETKİSİ · VC geri dönüş koşulunun ölçeği (K5, E1)
- PRD §4.7 ve A_PLAN §5.1 satır 13: ürün fonunun geri dönüşü "En zayıf eksen > 40". A_PLAN:407 bunu
  `_weakest_dimension`'ın 40'ıyla aynı sayar.
- `_weakest_dimension` (`vc_pitch_system.gd:1300-1308`) **ham** eksenleri (`QualityModel.dims_from_flags`) okur.
  ACIK_KARARLAR 59 (`:738-760`) bunu açık madde olarak kaydetmiş: hat modelinde ham eksen "tek haneden ~20'lere"
  uzanır, 40'a ancak bir eksenin üç hattı da K3'teyken varılır; 760 haftalık üç probe'da en yüksek ham eksen 31,6 /
  27,9 / 33,3.
- Sonuç: koşul bu ölçekle kodlanırsa Meridian'ın (ürün alanlı tek fon, `investor_registry.gd:61-65`) geri dönüşü
  pratikte hiç karşılanmaz. Kapı `callback_unmet` ile kilitli kalır (`:716-719`) ve `series_a_road_closed` (`:742`)
  "callback" statüsünü açık saydığı için Series A yolu hiç kapanmış sayılmaz (sonlar etkilenir). Bugünkü `bugs_under`
  koşulu (L < 3) her sürümde L sıfırlandığı için ulaşılabilirdi.
- **Plan değişikliği:** E1'e bir soru eklenir: koşul hangi ölçekle okunur? Seçenekler ACIK 59'dakilerle aynıdır: (A)
  §11.3 eksen okuması (`ProductState.axis_readings`, 0-120, çıtaya göre), (B) tabanın ham aralığa göre yeniden
  ölçeklenmesi, (C) bugünkü ham ölçek ve hiç açılmayan kapının kabulü. K5 bu satırı E1 cevabına göre kurar ve "onay
  bekliyor" işaretler. `save_v15_callback_bugs_under` ve `series_a_road_closed_when_all_funds_close` buna göre yazılır.

### 5.2 PLAN ETKİSİ · Kurucunun başlangıç işi Test olamaz (K1)
PLAN_A K1 "Kurucu" maddesindeki "başlangıç işi Test olabilir" senaryosu kodda yoktur (§2 madde 15). K1 bunun için
vaka ya da fikstür yazmaz. Test tutan kurucu yalnız bot/debug ile doğar; `founder_task_state` onu "Destekte" etiketler
(`hr_system.gd:260`), K1 bunu "sprintte kartı olan kurucu Boşta görünmez" kuralıyla birlikte düzeltir.

### 5.3 PLAN ETKİSİ · Karar 13'ün kurucu hâlleri oyuncuya kapalı (K1, E1)
Görevler matrisinde kurucu satırı yoktur (`hr_assignments.gd:42`, başlık 7-8; Ekip GDD §12 paragraf 779;
`gorevler_has_no_founder` 13235). Oyuncu kurucunun işini yalnız Ar-Ge'ye oturtarak değiştirir; araştırma bitince Yapım
geri gelir (`rnd_system.gd:292, 304, 360`; `character_registry.gd:261-285`). Yani "Yapım ve Destek tutan kurucu" ve
"işi olmayan kurucu" oyunda doğmaz; yalnız bot (B2C kolu), debug ve eski kayıtta vardır.
- **K1 değişikliği:** A yalnız motor bağını kurar (PRD bunu ister). Matrise kurucu satırı eklemek Ekip GDD'sini
  değiştirir; A'nın işi değildir. `gorevler_has_no_founder`'ın "satır yok" iddiası kalır, "tam bir iş" iddiası
  (13253-13255) gevşer.
- **E1'e not:** "Kurucuyu Destek'e oyuncu atayabilsin mi?" sorusu Erdem'e bilgi olarak gider; cevap A'yı bloklamaz.

### 5.4 PLAN ETKİSİ · K1 ekonomi kayması iki koşuda ölçülür (K1)
PLAN "A1d tabanına karşı `full_run_b2c` ekonomi kayması notu" diyor. Hotfix bloğu B2B'de de bir geliştiriciye Destek'i
ikinci iş verdiği için (`run_probe.gd:1111-1117`), K1 sonrası o geliştirici koşu boyunca sprintte 0,5 sayılır. K1 raporu
`full_run` ve `full_run_b2c`'nin ikisini de A1d tabanıyla karşılaştırır (`A1d/full_run_7.log`,
`A1d/full_run_b2c_7.log`). Ek iş yoktur, A1d iki tabanı da koştu.

### 5.5 PLAN ETKİSİ · Pay tek yardımcıda (K1)
PLAN "`week_points` bu bağı `team()` üzerinden alır" diyor. Almaz: `week_points` (`sprint_system.gd:507-512`) `team()`
üyelerini gezer ama puanı `_points(c, saat)` ile yeniden hesaplar. Pay yalnız `team()`'in `points` alanına konursa mesai
modalı (`work_hours_modal.gd:217-218`) eski değeri gösterir. K1 payı `team()` ve `week_points`'in birlikte okuduğu tek
yardımcıya koyar. `points_for` (işe alım dosyası, `hr_atlas_modal.gd:343`) aday atanmamış olduğu için paysız kalır;
`crunch_finishes` `t.points`'u okuduğu için ek iş istemez.

### 5.6 PLAN ETKİSİ · K3'ün smoke fikstürleri hatsız canlı ürün kurar (K3, K5)
`_seed_support_fixture` (`endgame_smoke.gd:13377-13395`, `LINE_TIERS {}`) ve `_seed_live_product` (697-709, ai_assistant
düz havuz) canlı ama hiç canlı hattı olmayan ürün kurar. `destek_*` ve `product_read_catalogue` bu fikstürlerle C'yi
sayar. K3'te doğrulanan hata düşecek hat bulamaz. Run_probe'un B2B fikstürleri ve `b2c_neglect` de hatsızdır
(`run_probe.gd:108-109`).
- Oyunda canlı ürün en az üç kimlik hattıyla yayına girer (`mvp_cards_left() == 0`), yani PRD Karar 3'ün "yayında hat
  yokken doğan hata" dalı oyunda yalnız yayın öncesi hatalı kapanışla oluşur; organik hata canlıyken doğar.
- **K3 değişikliği:** fikstürler bir hat kademesi kurar ki vakalar hat dağılımını ölçsün. PRD gereği hatsız hâlde hata
  `pending_faulty`'ye yazılır, ayrı bir organik "v1.0'a sakla" yolu kurulmaz. K5 probe fikstürlerini hatlı yeniden kurar.

### 5.7 PLAN ETKİSİ · K8'in belge listesi genişler
PRD ve PLAN K8 yalnız ACIK_KARARLAR 39 ve 45'i sayıyor. Faz A ayrıca şunları değiştirir: 96'nın (4), (5), (9), (16),
(21), (29), (45), (49), (50), (52) alt maddeleri; 97 (`founder_roles`, `WEAR_AUD_COEF`, `bug_pile`,
`EFFECT_FIX_RUN_STARTS`); 99 (seçenek C'yi Faz A uygular; ölçüm K5'ten); 43 ve 44 (aşınma, hata tohumu); 1569-1573
(`bug_pile`). ISLER.md:56-58 (hata trendi zinciri, sahibin "yeniden yuva" listesi) ve 118-119 (probe kurucusu notu);
HARITA:168. Açık maddelere dokunulmaz (CLAUDE.md §3): K8 yalnız "Faz A Kn ile değişti" notunu düşer; karar Erdem'indir.
- Hata trendi zinciri (`bug_trend`, `health_state`, `product_bug_risk`, `mvp_bug_history`) ve 8 CSV anahtarı
  (`PROD_RISK_*`, `PROD_HEALTHY`, `PROD_RISKY`, `PROD_FLAT`, `PROD_TREND_*`) sahibin listesinde durur. Girdileri (L,
  `effective_stability`, karmaşıklık) K5'te silindiği için zincir çalışamaz; silme R'de gerekçeyle yazılır.
- `product_catalog.gd`'nin `complexity` anahtarları ve `get_feature_by_id` karmaşıklıkla ölür.

### 5.8 PLAN ETKİSİ · K3 kapanış yüklemi (K3)
`_close`'un `releases` yüklemi (`sprint_system.gd:1032-1033`) "bileti boşalmış düzeltme kartı sürüm yapmaz" der. Bilet
kalkınca yüklem yeniden tanımlanır (hattında hata kalmamış düzeltme kartı). Canlı üründe sürüm çıkmayan kapanışta hatalı
kartın hatası bugün sessizce kaybolur (1037-1042); Karar 3 onu kartın hattına düşürür.

### 5.9 Plan değişmeyen ama E1 ve R'ye giden notlar
- Zar K1'de değişmez (§3); PRD §6'nın beklediği "K1 raporunda zar kaynaklı kayma" satırı "yok" diye yazılır.
- Karar 13'ün "sprintte kimse yoksa saat akar" kuralı bugün de doğrudur: `awaits_plan` `capacity() > 0` ister
  (`sprint_system.gd:400`), `_auto_start` sıfır kapasitede başlamaz (970). K1 yalnız metni ve Ekip bağını ekler.
- Yalnız tasarımcı/PM'den oluşan sprint ekibi geliştirme fazını yürütemez (kapasite > 0, kart tıkalı). Bugün de kurucu
  Ar-Ge'deyken oluşabilir; K1'in yeni getirdiği bir hâl değildir. PRD sessiz; raporlanır.
- Masanın "herkes mail okur" dalı (`support_system.gd:234-237`) plan/sürüm kipinde Yapım'daki herkesi de okur sayar.
  Bu, roster'a (`desk_roster`) girmez ve taban 2,0 ile sayılır; Kabul 4.9 `desk_roster`/`desk_staffed` ile ölçülür. K1
  dala dokunmaz, raporda yazar.
- `PROD_RND_NODE_CICD_UNLOCK` ("geliştirmeden daha az hata çıkıyor") karşılıksız bir vaattir (`bug_rate_ceil`
  okunmuyor). Karar 12 saymıyor; A dokunmaz, R'de not.
- Meridian'ın term sheet uyumundan `E_FIT_PRODUCT_BUGS` (±6) silinince ürün fonunun isteklilik tabanı kayar; bu bir E
  modeli sabitidir, R'de "onay bekliyor" altına girer.
