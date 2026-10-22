# Yürütücü notu · Faz A
Her kod ajanı bunu okur. Çakışmada PRD (`../PRD_FAZ_A_HATALAR.md`) geçerlidir; A2 bu dosyayı genişletir.

Bu not her Sonnet istemine eklenir; A2 genişletir. Çakışmada PRD geçerlidir.
1. **`desk_shut`:** yeniden kurulur. Yalnız `fix_run` çekimi silinir.
2. **İtibar:** `max(0, …)` tabanı yoktur. `GameState.set_reputation`'ın −10 alt sınırı geçerlidir
   (`game_state.gd:346-348`).
3. **En büyük hesap:** kartta adıyla ve koltuk sayısıyla gösterilir. `top_star` ve `{stars}★` kalkar.
   A_INCELEME §2'deki B ve C ad tablolarında hâlâ `top_star` yazıyor; geçersizdir.
4. **Dağılım:** Her hata bağımsız, eşit olasılıklı ve tohumlu düşer. "Haftanın hattı" ve ×3 ağırlık yoktur.
   Tek istisna, hatalı kapanan kartın hatasının kendi hattına düşmesidir.
5. **K5 kapısı:** "B2B ≤ 12" geçersizdir. Yerine §2.11'deki iki ölçü ve §4.4–4.5 gelir. `USAGE_DIV_B2B` 25 sabit
   değildir; değeri A0 ve E1'den gelir ve onay bekler.
6. **Bot kolları:** `fix_all` geçersizdir. Dört kol vardır; preset anahtarı `fix`'tir. `policy` olay cevabı
   anahtarı olarak kalır.
7. **Şema:** A 16, B 17. "D 17" geçersizdir.
8. **K1:** A_PLAN'ın K1 içeriğinin yerini Karar 13 alır.
9. **Kurucunun sprint payı:** A kimin sprintte olduğunu ve payını kurar. Rol puanı D'nindir.
10. **B2C kayıp yeri:** A_PLAN §5.1 satır 8, `sales_system.gd:184/204`'ü gösteriyor. Orası bugünkü kalite aşınması
    terimidir. Hata terimi onun **yanına eklenir**, onun yerine geçmez.
11. **Bilet defteri:** `SprintBridges.sync_tickets` defteri her gün C'den yeniden kuruyor. Göç, bilet satırlarının
    C'nin gerisinde kalabileceğini hesaba katar.

## A2 ekleri (2026-10-16, Opus; kanıt `A2_DOGRULAMA.md`, satırlar `A1_HARITA.md`)
12. **Kurucunun başlangıç işi her zaman Yapım'dır** (`game_state.gd:576-584, 981`). PLAN_A K1'deki "başlangıç işi Test
    olabilir" geçersizdir; bunun için vaka ya da fikstür yazılmaz.
13. **%40 zarı K1'den sonra da atılmaz.** Test fazına yalnız `dev`/`test` rolüne uyanlar girer ve geliştirici, test
    uzmanı ve kurucu hepsi `test`'e uyar (`sprint_system.gd:530, 765-766, 790-796`). `_fits`, `founder_roles`,
    `no_role_speed`'e dokunulmaz. K1 raporu zarı ekonomi kayması sebebi saymaz. A1b'nin "kurucu Destek'e geçince zar
    atılır" cümlesi yanlıştır.
14. **Sprint payı tek yardımcıdadır.** `team()`'in `points` alanı ve `week_points` (`sprint_system.gd:507-512`, mesai
    modalı) aynı yardımcıdan okur; `week_points` bugün puanı `_points` ile yeniden hesaplıyor. `points_for` (işe alım
    dosyası) paysız kalır. `crunch_finishes` `t.points`'u okuduğu için ek iş istemez.
15. **K1'in ekonomi kayması iki koşuda yazılır.** Hotfix bloğu K2'ye kadar B2B'de de bir geliştiriciye Destek'i ikinci iş
    verir (`run_probe.gd:1111-1117`); o geliştirici sprintte 0,5 sayılır. `full_run` ve `full_run_b2c` A1d tabanıyla
    karşılaştırılır.
16. **Kurucu Görevler matrisine eklenmez.** Ekip GDD §12 ve `gorevler_has_no_founder` bunu kilitler; K1 yalnız motor
    bağını kurar. Vakanın "tam bir iş" iddiası (`endgame_smoke.gd:13253-13255`) gevşer, "satır yok" iddiası kalır.
    İki işli ve işsiz kurucu oyunda doğmaz (oyuncunun tek yolu Ar-Ge); yalnız bot, debug ve eski kayıtta vardır.
17. **"Sprintte kimse yoksa saat akar" bugün zaten doğrudur.** `awaits_plan` `capacity() > 0` ister
    (`sprint_system.gd:400`), `_auto_start` sıfır kapasitede başlamaz (970). K1 yalnız metni ve Ekip bağını ekler;
    `product_model.gd:263` bugün yalnız metin verir.
18. **Masanın "herkes mail okur" dalına dokunulmaz** (`support_system.gd:234-237`). Kabul 4.9 `desk_roster` ve
    `desk_staffed` ile ölçülür. `_area_sum`'ın 2,0 tabanı (257) yüzünden 0,5 payı puanla değil roster üyeliğiyle
    sınanır; dal raporda yazılır.
19. **K3'ün tohumu:** önerilen yol yeni bir `RngStreams` akışıdır (`STREAM_IDS`'e eklenir). Eski kayıt uyumu hazırdır:
    `from_dict` kayıtta olmayan akışı `run_seed`'den kurar (`rng_streams.gd:67-70`). Hash seçilirse `GameState.run_seed`'i
    içerir (`sprint_system.gd:842` örnek); bugünkü zar hash'i (1027) `run_seed` içermez ve örnek alınmaz.
20. **"Yayında hat yokken" hâli yalnız fikstürdedir.** Oyunda canlı ürün en az üç kimlik hattıyla yayına girer.
    `_seed_support_fixture` (`endgame_smoke.gd:13384`, `LINE_TIERS {}`) ve `_seed_live_product` (697) K3'te bir hat
    kademesi kurar; run_probe'un B2B fikstürleri ve `b2c_neglect` K5'te hatlı kurulur. Hatsız hâlde hata
    `pending_faulty`'ye yazılır (PRD Karar 3); organik hata için ayrı bir "v1.0'a sakla" yolu kurulmaz.
21. **K3 `_close`:** `releases` yüklemi (`sprint_system.gd:1032-1033`) bilet yerine hattın hata sayısıyla yeniden yazılır.
    Canlı üründe sürüm çıkmayan kapanışta da hatalı kartın hatası kartın hattına düşer; bugün sessizce kayboluyor
    (1037-1042).
22. **VC geri dönüşü ham eksenle kodlanmaz.** `_weakest_dimension` (`vc_pitch_system.gd:1300-1308`) ham ekseni okur ve
    ham eksen 40'a varmaz (ACIK_KARARLAR 59). Koşul bu ölçekle kurulursa Meridian'ın kapısı ve `series_a_road_closed`
    kilitlenir. K5 bu satırı E1'de seçilen ölçekle kurar ve "onay bekliyor" işaretler.
23. **K8'in belge kapsamı genişler.** ACIK_KARARLAR 96 (alt maddeler 4, 5, 9, 16, 21, 29, 45, 49, 50, 52), 97, 99, 43,
    44, 1569-1573; ISLER.md:56-58 ve 118-119; HARITA:168. Açık maddelerin metni değişmez: yalnız "Faz A Kn ile değişti"
    notu düşülür, karar Erdem'in.
24. **Hata trendi zinciri ve karmaşıklık birlikte silinir.** `bug_trend`, `health_state`, `product_bug_risk`,
    `_shipped_total_complexity`, `mvp_bug_history`; 8 CSV anahtarı (`PROD_RISK_*`, `PROD_HEALTHY`, `PROD_RISKY`,
    `PROD_FLAT`, `PROD_TREND_*`); `product_catalog.gd`'nin `complexity` anahtarları ve `get_feature_by_id` (tek okuyucu
    `product_system.gd:152`). ISLER.md:56-58 bu zinciri sahibin listesinde tutar; gerekçe (girdileri K5'te silinir) R'de.
25. **`hotfix_*` smoke önekleri** (`endgame_smoke.gd:241-248`, HARITA:213) 2026-08 yama turunun adıdır; K2 bunları
    silmez. `hotfix` izinli ödünç kelimesi (CLAUDE.md:53) yalnız sahip kararıyla listeden çıkar.
26. **Kurucu açılış toplantısına sprint üyeliğinden bağımsız yürür** (`office_people.gd:454`; kurucu sunar, 440-446).
    K1 bunu değiştirmez, raporda yazar. `hr.job` seam'i yalnız ilk işi okur (`seams_hr.gd:83-87`); K1 değiştirmez,
    B'nin seçicileri için raporda listelenir.
27. **Satır kaymaları:** PLAN_A K2'nin `main.gd:1295-1304`'ü bugün 1295-1306'dır. `_validate_shape`'in kurucu kuralı
    500-502'dir (yorum 498-499); kural yalnız `add()` ve `insert_raw()`'da koşar.
28. **Probe kurucusunun Müşteri İlişkileri'si 0'dır** (ISLER.md:118). K2'den sonra B2C kolundaki kurucu masada yalnız
    tabanla (2,0) doğrular ve düzeltme yapmaz; Destek'i ikinci iş olarak alması pratikte `desk_staffed`'i değiştirir.
