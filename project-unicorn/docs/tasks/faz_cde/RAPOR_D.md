# RAPOR D · Faz D sonuç raporu (ekip modeli ve sprint düzeni)

2026-10-24 · Yazan: Opus (workflow'un R adımı). Kapsam: `main` @ `baa63da` (Faz D D8b ek). Satır numaraları `baa63da`'ya
göredir; ortak ağaçta sonradan inen Ürün arayüzü U1'i (`29ae999`) ve commit'siz farklar satırları kaydırabilir.
Kaynaklar: `PRD_FAZ_D_EKIP_SPRINT.md` §4, `d_taslak/ADIM_TABLOSU_D_v2.md` §0b, §0c, §5, `git log --grep "Faz D"`,
`d_taslak/olcum/D0b_TABAN.md`, `d_taslak/olcum/D_SON_OLCUM.md`, workflow'un adım raporları, `ERDEM_KARARLAR_2026-10-20.md`.
Bu dosya izlenmez ve commit'lenmez.

## 1. Özet

- ✅ **Biten:** 12 commit `main`'de, hiçbiri push'lu değil (`origin/main` = `cf45252`, HEAD 35 commit ileride; Erdem "push et"
  deyince). Sıra: D0a, D1, D1b, D2b, D2b ek, D3, D4, D4 ek, D7m, D8b, D8a, D8b ek. Hepsi adım tablosu §0c'nin daralan (a)
  listesidir: model ve motor. Ekrana yeni metin ya da düzen girmedi; yalnız eski öğeler kalktı (süre seçicisi, PM adayının
  Atlas'taki puan satırı).
- ✅ **Yeni oyuncu metni yok.** Hiçbir Faz D commit'i `localization/strings.csv`'ye dokunmadı; "TR/EN onay bekliyor" listesi boş.
- ⚠️ **Park:** D2a (yeni hafta motoru, merdiven, mesai başlangıcı), D2c (proaktif plan ve süre kapısı), D3b (gönder sorusu),
  D5a, D5b, D6 (Ürün arayüzü görevine geçti), D7'nin, D8a'nın ve D8b'nin arayüz parçaları, D8c ve D8d (kart yenilemesi), D9
  (ölçüm). Ayrıntı §5.
- ❌ **Kabul ölçütlerinin çoğu ölçülmedi:** PRD §4.1'in 23 kapısı ve §4.3'ün kapıları D9'undur, D9 park. Ölçülebilen her şey
  §3'te; tutmayanlar: kâğıt gelen sprint oranı, tasarımcı kâğıtları, A §4.2'nin 7 hedefi, B2B Traction saat durması, acil durum
  sayısının sapması.
- **Oyuncu ne fark eder (oyun içinden örneklerle):**
  - Plan ekranında süre seçicisi yok; sprint hep 2 hafta, bütün kartlar biterse erken kapanır. Puanlar beş kat: K1 kartı 15 puan,
    orta bir geliştirici haftada 10 puan.
  - Yıldız hızı büyütür: 2 puanlı geliştirici haftada 6,4, 10 puanlı 20 puan yapar; TİTİZ çalışan ×0,85, GÖZÜ YÜKSEKTE ×1,15.
  - Kurucu bu hafta bir satış görüşmesi yaparsa ertesi hafta sprintte işinin beşte birini kaybeder (pay 0,8); haftada dört
    görüşmede pay 0,2. Görüşme ekranda ve oyun saatinde eskisi kadar sürer.
  - "+" artık kartın bu sprintte gerçekten puan alıp almadığına bakar: yazılımcı doluyken yazılımdan başlayan düzeltme kartının
    "+"sı kapalıdır. Testçi ayrılınca kapısı kapanan kart planda "Bu sprint başlamaz" der.
  - Testin kaçırdığı hata sürümde kartın hattında açık hata olur; "sürüm sonrası bozulma" acil durumu artık gelir. Testin bulduğu
    hata kartı Geliştirme'ye geri döndürür.
  - Ürün yöneticisi sprint puanı üretmez; sonraki sütundaki kartları hazırlar, hazırlanan kart daha hızlı biter ve daha az hata
    çıkarır. Atlas'ta PM adayının "Sprintte haftada N puan" satırı yok.
  - Düzeltme kartı hata başına 2 puandır (6 hata 12 puan). Büyük ekipte itibar daha geç düşmeye başlar (eşik 30 × k).
  - PM varken ÇEYREK'te seçilen hedef liderin önerisini de sürer. Liderin önerisi kartları basamak sırasıyla koyar; ikinci büyük
    düzeltme yarı kapasite tavanına takılır.
  - PM ayrılıp yenisi gelince "Planlamayı devret" kapalıdır; oyuncu yeniden devreder.

## 2. Commit'ler

| sha | adım | dayanak | oyuncu ne görür | kapılar |
|---|---|---|---|---|
| `8038c42` | D0a | PRD §8 D0, §4.1, §4.3 madde 3 ve 7; yardımcı yönetmen 2026-10-22 açık 6 | Hiçbir şey (yalnız harness: `team=12/25/50`, `tstar`, `pmstar`, `plus`, `founder=0`, `fixture=iz1/iz1b/iz2`, `planms=1`, `build=ea`, `full_run_staff25/50`, `b2b_book20/330`, `--tick-probe team=`) | loc_residue 0, all_scripts_load, 3 vaka; sekiz eski preset'in `^PROBE` ve beş prob komutunun `^SPRINTPROBE` satırları bayt eş; prob 1 ile 50 kişi exit 0 |
| `d325f88` | D1 | PRD Karar 1 (×5), 3 (iş profili), 11 (sabit 2 hafta), 14 (düzeltme payları), §4.6; şema kuralı (adım tablosu §0) | Süre seçicisi yok; puanlar ×5; atamalar Karar 3'ün tablosuyla değişir (104. hafta B2B aynı, B2C tohuma göre −%5,5 ile +%6,9) | lint 0/0 (146 kart), loc 0, 100 vaka, prob 1/3/6/12/25/50, run_gate 3/3, plausibility 40×16 ve 4×60 fails=0, kareler TR+EN |
| `a397dcf` | D1b | PRD Karar 1 (Y(s), huy), Karar 5 (kurucu payı); Erdem 2026-10-23 (1/1/2 gün, "Kurucu sprintte"); yardımcı yönetmen 2026-10-23 (dondurma, seçenek a, defter V10, bir görüşme bir kez) | Atlas ve çalışma saati penceresi yeni eğri; görüşmenin ertesi haftası kurucu daha az iş çıkarır | lint, loc, 117/117 vaka, prob 1 ile 50, run_gate 3/3, `--hr-shot=dosyalar` TR+EN |
| `f79a6a0` | D2b | yardımcı yönetmen 2026-10-22 açık 5; D_PLAN §5.5; adım tablosu §0c satır 5 | "+" yalnız puan alacak kartı alır; kapısı kapanan kart "Bu sprint başlamaz" | lint, loc, 21 vaka, prob 7/7 (B2B `meetings=2` dahil), run_gate 3/3 |
| `edbee46` | D2b ek | Erdem cevabı 22; PRD Karar 10; yardımcı yönetmen 2026-10-23 tanım kararı ve D2b'nin iki görünür farkının onayı | Ekranda değişiklik yok; sürüm kaydına aşama başına `overflow {out, streak}` | lint, loc, 20 vaka, prob 7/7, run_gate 3/3, `edge:plus_closed` ve `edge:start_shut` TR+EN |
| `ee9e799` | D3 | Erdem cevabı 19 ve 24; PRD Karar 6 ve 7; yardımcı yönetmen (K-E, K-H, c = 0,212) | Kaçan hata hattında açık hata; sürüm sonrası bozulma gelir; bulunan hata Geliştirme'ye iş ekler | lint, loc, 36 vaka, prob 7/7, run_gate 3/3, plausibility fails=0 |
| `0b3c213` | D4 | PRD Karar 8 ve Karar 4'ün PM paragrafı; Erdem cevabı 21, 2026-10-22 Soru 3; yardımcı yönetmen 2026-10-22 (kural A), 2026-10-23 (doğrusal ara değerler) | PM kapasiteye girmez, karta atanmaz; hazırlanan kart hızlı ve az hatalı | lint, loc, 136 vaka, prob 7/7, run_gate 3/3, plausibility fails=0, `live:plan` ve `live:active` TR+EN |
| `82fc3d2` | D4 ek | yardımcı yönetmen 2026-10-23 (D4 sorusu 2 (b)) | Atlas'ta PM adayının puan satırı yok; öbür rollerde var | lint, loc, 26 vaka, prob 7/7, `dosyalar-pm`, `dosyalar-tasarim`, `dosyalar` TR+EN |
| `4816edb` | D7m | PRD Karar 14 ve 15 (Erdem 17 Ekim "D5 okey"); adım tablosu §0c satır 8 | Düzeltme kartı 2 × açık hata; itibar eşiği 30 × k (eşik ekranda yazmaz) | lint, loc, 42/42 vaka, prob 7/7, `edge:fix_long_name` TR+EN; run_gate ve plausibility koşulmadı |
| `10b2a27` | D8b | PRD Karar 12; adım tablosu §0c satır 9 | PM varken çeyrek hedefi liderin önerisini sürer; arayüzde yeni seçenek yok | lint, loc, 23/23 vaka, prob 7/7, `live:b2c_goal` TR+EN; run_gate ve plausibility koşulmadı |
| `569c843` | D8a | PRD Karar 12 (altı basamak, 12 aday, bot yalnız öneri) ve Karar 14 (pay tavanı); adım tablosu §0c satır 10 | Öneri basamak sırasıyla doldurur; ikinci büyük düzeltme tavana takılır | lint, loc, 81/81 vaka, prob 7/7, run_gate 3/3, `live:b2c_goal` TR+EN; plausibility atlandı |
| `baa63da` | D8b ek | PRD Karar 12; yardımcı yönetmen 2026-10-24 okunuşu | PM ayrılıp yenisi gelince devret kapalı; izindeki PM dönünce devir geri gelir | lint, loc, 11/11 vaka, prob 7/7, `live:delegate_rehire` TR+EN; run_gate koşulmadı |

Prob eşleşmeleri (`--sprint-probe` 1/3/6/12/25/50 kişi ve 3 kişi B2B `meetings=2`): D1b 136/138, 188/202, 58/65, 37/37, 37/37,
37/37; D2b ve D2b ek ek olarak B2B 157/178; D3 129/133, 182/192, 51/56, 54/54, 85/86, 84/85, 136/149; D4 6 kişide 192/198;
D7m'den D8b ek'e kadar 129/133, 164/172, 193/197, 54/54, 122/123, 99/100, 126/137. Hepsinde adsız uyuşmazlık 0.

## 3. Kabul ölçütleri (PRD §4)

**"Her kural 1, 3, 6, 12, 25 ve 50 kişide sınanır":** ✅ Her commit'in kapısında `--sprint-probe team=1,3,6,12,25,50` PASS
(adsız uyuşmazlık 0); D2b'den beri 3 kişi B2B `meetings=2` de. Kural başına ölçek ölçümleri: Y(s) için MVP 1 ile 50 kişide
değişmedi (D1b); k 1/3/6/12/25/50 kişide 1,00/1,00/1,04/1,48/2,13/3,02 (D7m); öneri döngüsü süresi 1 ile 50 kişide (D8a);
PM eklemenin yönü 4, 5, 12, 25 kişide (D4; 12 ve 25 kişide ölçüm duyarsız, §7).

### 3.1 Modelin Godot'taki ölçümü (§4.1, D9)
Bütün madde park: D9. Neden: D9 adım tablosu §0b'de park, D2a (atama) ve D2c (P) olmadan kapıların çoğu ölçülemez.
Ölçülebilenler bilgi olarak:
1. `ekleme_dusurmez`, `pm_ekleme`, `atama_sirasi`: ⚠️ park D9 ve D2a. D4'ün yön kapısı (sprint probu, 40 saat, 6 tohum): sütun
   boşken PM eklemek teslimi değiştirmez (0,0); sütun doluyken 4 kişide 1★/3★/5★ PM +1,2/+0,4/+1,0, 5 kişide −1,3/−1,6/−0,9
   (yaklaşık %0,3). D_SIM_v3 §5.2'nin −2,5'i ile yan yana: Godot'ta en kötü −1,6 (5 kişi, 3★). Atama sırası D2a'nın.
2. `kurucu_buyume`: park D9. `mvp_tek_kurucu`: ✅ smoke `sprint_solo_mvp_by_week_six` (tek kurucu, liderin önerisi, türden
   sonra en geç 6 tik); botta MVP haftası 100 koşuda 7 (D_SON_OLCUM K7).
3. `duzeltme_payi`: ⚠️ bot koşularında (A kolları, D_SON_OLCUM K8): `fix_due` B2B erken pay %12,2 ✅, geç %6,1 ✅, erken hata
   sprinti %16,4 ❌ (≤ %5), üst üste var ❌; B2C erken pay %11,3 ✅, erken hata sprinti %16,1 ❌, geç %3,6 ✅, geç üst üste %0,33
   ❌. `toplam_hata_isi` ✅: düzeltme işi `due` kolunda koşunun tamamladığı işin yaklaşık %1'i (D3 ölçümü, tohum 1 ile 6).
4. `testci_yildizi`, `testci_degeri`, `pm_yildizi`: park D9. `kendi_karti` ×0,6 kodda (`sprint.json:38` `self_test`,
   `SprintBugs.catch_rate`, `sprint_bugs.gd:53`), kapısı ölçülmedi.
5. `soru_sikligi`, `soru_politikasi`: park D3b (gönder sorusu yok).
6. `arz_havuzu`, `kart_yok_sprinti`, `oneri_dolulugu`, `bosta_nedenli`: park D8c, D8d (kart yenilemesi) ve D9.
7. `a_sinirlari_oranli`: ⚠️ k kodda (`SprintCatalog.limit_k`, `sprint_catalog.gd:173`; smoke `support_neglect_scales_with_k`).
   Bot koşularında `fix_none` sprint sonu açık hata medyanı B2B 83, B2C 61, yani 30 × k'yi geçiyor; kaçıncı haftada vardığı
   ölçülmedi. `fix_due` medyanı 7 ile 8; en büyük değeri ölçülmedi. Park D9.
8. `uymayan_moral`: park D2a (Erdem P1: "60 ile 90 moral" kural değil, asıl sorun bir ay sonra istifa).
9. ✅ Hiçbir sabit sessizce değiştirilmedi: c ölçeklenmedi (sapma −%23,5, eşik %30), öbür sayılar §4'te.

### 3.2 A'nın hedefleri olaylar açıkken (§4.2)
Ölçüm D_SON_OLCUM K8 ve `D_SON_a42_tablolar.txt:323-379` (100 koşu, tohum 1 ile 11, `_free` ikizleri 7 ve 11).
- `fix_due` B2C erken düzeltme payı ≤ %30: ✅ %11,3 (D0b %33,3).
- `fix_due` B2C erken hata sprinti ≤ %15: ❌ %16,1 (D0b %25,2).
- `fix_due` B2C erken üst üste iki ≤ %1: ❌ %4,4 (D0b %10,7).
- `fix_due` B2B erken hata sprinti ≤ %15: ❌ %16,4 (D0b %6,0; PASS'ten MISS'e).
- `fix_due` B2B erken üst üste iki ≤ %1: ❌ %4,8 (D0b %0).
- `fix_worst` B2C erken payı ≤ %30: ✅ %20 (D0b %50).
- Kalan hedefler ve churn: ⚠️ 76 hedefin 7'si MISS (D0b 9). Yukarıdakilere ek MISS: `fix_worst` B2B erken üst üste iki (%8,2),
  `fix_worst` B2C erken üst üste iki (%1,7), `fix_due` B2C geç üst üste iki (%0,33). Üç churn hedefi (tohum 3, 4, 8) MISS'ten
  PASS'e geçti. Onay bekliyor altında (§4 sonu); nedenleri ayrı ölçülmedi (model ve bot birlikte değişti, §6.3).

### 3.3 Oynanış kapıları (§4.3)
1. Sprint dolu ve tam: doluluk medyanı ölçülmedi (park D9). "Erken kapanan sprint 0" şartı düştü: Erdem 2026-10-23, sprint
   bütün kartlar bitince erken kapanır. Ölçülen: kapanan sprintlerin %62,3'ü 1 haftada kapandı (D0b %72,8). "Sırada" satırı
   park D6.
2. Karar kayması: ⚠️ düz bot sprint başına 2 eylem (öneriyi uygula, başlat; `full_run`, `full_run_b2c`, `full_run_staff25`,
   D8a ölçümü); 50 kişide sayılmadı. ✅ Aynı durumda farklı çeyrek hedefi PM'siz de farklı kart seçer: smoke
   `quarter_goal_without_pm` (Çekirdek, Güven ve "Hatalar" öneriye farklı kart sokar).
3. Kesinti: ❌ B2B Traction'da cevaplanan kart haftada 1,70 ile 1,91 (hedef ≤ 1,2; D0b'de aynı tanımla 1,69 ile 1,74, PRD'nin
   "bugün 1,72"sine yakın);
   sprint başlatma dahil durma 2,41 ile 2,68 (D_SON_OLCUM K7b). ❌ 2 ve daha çok durmalı hafta %73 ile %78 (sprint başlatma
   dahil; hedef ≤ %2, tanım D9'da eşlenmeli). ✅ 50 kişi ve 330 hesapta haftalık durma 1,62, 6 kişi ve 20 hesapta 1,50
   (1,08 kat, sınır 1,5 kat; K10).
4. Kâğıt yaşıyor:
   - ❌ kâğıt gelen sprint (v1.0 sonrası) B2B %7,7 ile %8,9, B2C %6,6 ile %10,3 (hedef %30 ile %67; D0b %3,6 ile %9,6).
   - ✅ en az üçte biri kâğıtsız (%90'ın üstü kâğıtsız).
   - ❌ tasarımcı kâğıtları 0/8 geldi (hedef ≥ 4/8). ✅ PM kâğıtları 3/8 geldi (`sprint_pm_phone_too`, `sprint_pm_scope_grew`,
     `sprint_pm_spec_unclear`; hedef ≥ 3/7, havuzda bugün 8 PM kâğıdı; D0b 0/8).
   - ⚠️ hiç gelmeyen 18 kâğıt adıyla listeli (D_SON_OLCUM K4b), nedenleri ölçülmedi (D9).
   - ✅ `promise_due` 18 ve `sprint_late*` 10 kez geldi, hepsi B2B (D0b 0 ve 0).
5. Plan okunurluğu: park D6 (Ürün arayüzü görevi).
6. Görünmez sayı yok, boş yüzey yok: ⚠️ park arayüz görevi ve D3b. Tablo §4.2.
7. Ölçekte boşta ve karar: park D9 (50 kişide boşta payı ve `PROBE DECISION` sayımı koşulmadı).
8. B'nin olayları: ❌ acil durum/koşu medyanı B2B 7 ile 8 (D0b 3 ile 7), B2C 6 ile 8 (D0b 4 ile 7); birçok kolda sapma %30'un
   üstünde. Sürüm sonrası bozulma 0'dan koşu başına 2 ile 5'e çıktı. Onay bekliyor (§4 sonu).

### 3.4 Tahmin ile sonuç (§4.4)
1. ✅ Taban koşusu D1'den önce (D0b, `5d3ea000`): testçisiz 190/198, testçili 198/207, uyuşmazlıkların hepsi adlı
   (`team.burnout` baskın). ✅ Her dilimden sonra adsız uyuşmazlık 0. Not: D1b'nin ölçümünde 3 kişi B2B `meetings=2` probunda
   9. sprintte bir adsız uyuşmazlık vardı (planlandıktan sonra kapısı kapanan kart); D2b `starting()` ile kapattı ve o prob o
   günden beri kapı listesinde.
2. ⚠️ `PRED` ve `CLOSE` kart başına `bugs=<n>/<F>/<K>/<düzeltme işi>` taşır ve karşılaştırır (D3). Atanan kişiler ve çekilen
   kartlar yazılmadı: park D2a (atama) ve D2a (çekme). Ekip fikstürleri 1 ile 50 kişi ✅ (D0a). 50 kişi ve 50 kartta süre:
   ⚠️ 50 kişi ve 14 kartta ölçüldü; sentetik 50 kartlık fikstür kurulmaz (yardımcı yönetmen, adım tablosu D2c satırı).

### 3.5 Smoke vakaları (§4.5)
- ✅ `sprint_test_seed_deterministic`, `sprint_escaped_bug_on_card_line` (D3; falsification 26 bozmanın 26'sı).
- ❌ park D3b: `sprint_ship_question_order`.
- ⚠️ `sprint_skill_assignment`: yalnız PM kolu (D4; en karmaşık kart 5★ PM'e, ters sıra düşer). Kişi ataması kolu park D2a.
- ❌ park D2a: `sprint_two_weeks_pull` (çekme park; erken kapanış Erdem'in kararıyla kalır).
- ❌ park (kurucu kararı Erdem'de): `sprint_founder_floor_silent`.
- ✅ `sprint_lead_fills_to_ceiling` (D8a): bot sprintte yalnız öneriyi uygular, yani bot ile öneri aynı küme.
- ✅ `quarter_goal_without_pm` (D8b), `delegate_needs_pm` (D8b ve D8b ek).
- Ek vakalar (her biri falsification ile): `sprint_speed_curve_y`, `sprint_founder_share_frozen`, `sprint_founder_switch_off`
  (D1b); `sprint_intake_uses_applied_plan` (D2b); `sprint_overflow_phase_recorded` (D2b ek); `sprint_bug_ceiling_formula`,
  `sprint_expected_bug_no_rng`, `sprint_plan_done_counts_fix_work`, `sprint_escaped_pre_launch_lands_at_v1` (D3);
  `sprint_pm_prep_benefit` (D4); `sprint_fix_card_double`, `support_neglect_scales_with_k` (D7m); `save_v19_cards_scale_and_shape`,
  `save_v19_running_sprint_continues` (D1).

### 3.6 Kayıt (§4.6)
✅ Göç `_migrate_18` (`save_manager.gd:206`, `:1008`): saklı kartın ihtiyacı tablodan, ilerleme aşama payıyla ×5, yarım testli
kart testi baştan alır, `shares`, `effort`, `effort_mod`, sprintin `weeks`'i gider, koşan 1 haftalık sprint 2 haftaya uzar; D3
`faulty`'yi `escaped`'a çevirir. Kanıt `save_v19_cards_scale_and_shape`, `save_v19_running_sprint_continues`, `save_v14_*`,
`save_v15_*`. ⚠️ PRD "19'dan 20'ye" diyor; D ilk inen adım olarak 19'u aldı (adım tablosu §0 şema kuralı), `SCHEMA_VERSION` 19
(`save_manager.gd:16`). D1'den sonra şema açılmadı; yeni alanlar varsayılanla okunur (§8).

### 3.7 Kapılar ve görsel kabul (§4.7)
- ✅ `--event-lint` (0 hata, 0 uyarı, 7 baseline, 146 kart), `loc_residue` 0, `loc_csv_integrity` her commit'te.
- ✅ plausibility `fails=0`: D1, D3, D4 (40 × 16 hafta, 377 atış; uzun 4 × 60 hafta, 304 atış). D7m'den sonra koşulmadı.
- ✅ `run_gate` 3/3: D1, D1b, D2b, D2b ek, D3, D4, D8a. D8b ek'ten sonra koşulmadı (bot devri kullanmaz). Son ölçümde `baa63da`
  ağacında 102 oyun hatasız bitti (§6.1).
- ⚠️ "Oyun her commit'ten sonra açılır ve oynanır": yalnız headless bot ve kareler; elle oynanış kaydı yok.
- ⚠️ Görsel kabul TR ve EN her görünür değişiklikte yapıldı; renk körü (`--palette=cb`) ve 1,25 ölçek kareleri hiçbir adımda
  çekilmedi.
- Yeni fikstürler: `edge:plus_closed`, `edge:start_shut`, `live:b2c_goal`, `live:delegate_rehire`, `--hr-shot=dosyalar-pm` ve
  `dosyalar-tasarim` (HARITA'da). PRD'nin listesindeki öbürleri (plan 1/6/12/50 kişi, darboğaz, kart yüzü, "Sırada", test
  satırı, gönder sorusu, sürüm notu, PM'siz ÇEYREK, kilitli devret, Atlas hızları): park D6, D3b, D5a ve U3/U5.
- Tam smoke (`--all`) koşulmadı (CLAUDE.md §10).

## 4. [WORKING] sabitler ve "Erdem onayı bekliyor"

### 4.1 Erdem onayı bekliyor
| Ad | Değer | Yer (`baa63da`) | Commit | Kaynak |
|---|---|---|---|---|
| m(Δ) = rate × 0,5^(Δ ÷ half_stars) | rate 0,2, half_stars 2 | `data/product/sprint.json:34`, `:35` | D3 | Erdem cevabı 24 (biçim K-E), [WORKING] |
| Y(s) = a + b·s + c·s² | [0,5, 0,05, 0,01] | `sprint.json:25` `skill_curve` | D1b | PRD Karar 1 |
| PM hazırlık hızı | 1★ %10, 5★ %25, arası doğrusal (`prep.speed` [0,1, 0,25]) | `sprint.json:41` | D4 | Erdem 2026-10-22 Soru 3 (uçlar), yardımcı yönetmen 2026-10-23 (doğrusal ara değerler), [WORKING] |
| PM hazırlık hata çarpanı | ×0,90 ile ×0,60, doğrusal (`prep.bugs`) | `sprint.json:41` | D4 | aynı |
| PM hazırlık eğrisi ve payı | P(s) = 15 + 10 × √((s − 2) ÷ 8) (`prep.rate` [15, 10]); hazırlık kartın %20'si (`prep.share` 0,2) | `sprint.json:41` | D4 | PRD Karar 8 ve D_MODEL_v3 §3.8 |
| k formülü | k = en büyüğü(1; canlı hat ÷ 9; √(son 8 haftanın haftalık teslimi ÷ 55)) (`limit_k` 9 / 55 / 8) | `sprint.json:7` | D7m | PRD Karar 15 [onay bekliyor] |
| Düzeltme kartı puanı | açık hata × 2 (`fix_effort.per_bug`) | `sprint.json:6` | D7m | PRD Karar 14 [onay bekliyor] |
| `decision.sprint_chance` | 0,5 | `sprint.json:51` | D1 | 1 haftalık sprint kalkınca uzunluk sözlüğü tek sayıya indi (PRD Karar 11); kural "sprintlerin en az üçte biri kâğıtsız" |
| Önerinin pay tavanı ve atlama sınırı | `lead.fix_share` 0,5, `lead.skip` 12 | `sprint.json:31` | D8a | PRD Karar 12 ve 14 |
| Zayıf PM eşiği | `pm.low_skill_max` 3 (silinen `skill.low_max`'tan aynı değerle taşındı) | `sprint.json:50` | D1b | Y(s) ile yeniden tanımı karar bekliyor |

Sayıyla değil kuralla bekleyenler (Erdem'e): A §4.2'nin 7 MISS'i (§3.2) ve acil durum sayısının D0b'ye göre sapması, sürüm
sonrası bozulmanın gelmeye başlaması (§3.3 madde 8; Erdem 2026-10-16 acil durum sıklığı kuralı açısından).

### 4.2 [WORKING], onay gerekmeyen ya da kabul edilmiş
- c = 0,212 (`sprint.json:33`): geçici, §6.4.
- A6'nın öbür sayıları (`sprint.json:36-39`): tür 1 / 1 / 0,3 / 0, yakalama katsayısı 0,57, kendi kartı ×0,6, düzeltme işi 5,3
  (olasılık 0,18) ya da 1,3. D3 incelemesi bunları Erdem cevabı 24'ün K-E sayıları saydı, "onay bekliyor" diye işaretlemedi.
- `TimeModel.MEETING_DAYS` satış 1, yatırımcı 1, masa 2 gün (`time_model.gd:18`): Erdem 2026-10-23 verdi; ölçüm sonrası
  "kabul, sabitler kalır". `SITTING_HOURS` 2 / 2 / 1 saat (`:17`) bugünkü değerlerdir, taşındı.
- Huy çarpanları `speed_mult` 0,85, `output_mult` 1,15, `bug_rate_mult` 0,5 (`hr_constants.gd:442`, `:452`, `:441`): değer
  değişmedi, sprint ilk kez okuyor (PRD Karar 1 ve 24).
- `NEGLECT_BUGS` 30 ve botun `DUE_BUGS` 2 değişmedi; ikisi × k okunur.
- Kodlanmayan [WORKING]'ler (adım tablosu R satırı): planner bloğu (D2c), kadro tavanı 8 (D2a), Özenli/Aceleci eşikleri (D5b).
- `LineGates.speed_bonus_for`: D'de bağlanmadı, hâlâ çağıranı yok (ACIK_KARARLAR 41 açık; Y(s) onu okumaz).

### 4.3 "Her sabitin görünen satırı" (§4.3 madde 6)
| Sabit | Oyuncunun gördüğü yer | Durum |
|---|---|---|
| Y(s), huy | Atlas aday dosyası ve çalışma saati penceresi haftalık puan | ✅ görünür. ⚠️ Atlas dosyası huyu saymaz (TİTİZ aday 10 görünür, 8,5 çalışır), karar bekliyor |
| Kurucu payı (`MEETING_DAYS`) | yok (Ürün arayüzü PRD'si V10, A17) | ⚠️ arayüz görevi |
| m(Δ), c, yakalama | kartın "Test: n hata buldu" satırı | ⚠️ park D3b ve D6; bugün yalnız açık hata ve sürüm sonrası bozulma görünür |
| PM hazırlık faydası | kart yüzü | ⚠️ arayüz görevi; Erdem: "%25 daha hızlı, hata ×0,60" yazısı olmaz, başka biçimde |
| k ve itibar eşiği | Destek kartının ipucu | ⚠️ park, arayüz görevi (`SupportSystem.neglect_threshold()` hazır) |
| Düzeltme kartı puanı | kartın puanı | ✅ görünür |
| Pay tavanı, atlama sınırı | önerinin içeriği | ✅ sonuç görünür, neden cümlesi yok (arayüz PRD'si KR3) |
| `decision.sprint_chance` | kâğıdın gelişi | ✅ sonuç görünür |

## 5. Park listesi

| Adım | Ne | Neden | Ne bekleniyor |
|---|---|---|---|
| D2a | Yeni hafta motoru ve reaktif P; işi biten çalışanın merdiveni; haftanın sınırının mesai başlangıcına taşınması (dondurma, kâğıt zarı, son gece kuralı, gece oto kaydı, süre bütçesi); tek tasarımcı boşluğu (Erdem: tasarım bir sprint önden yürür, kimi kart tasarımsız); K4, K6, K7; istifa araştırması | Atama kuralı kadro tavanı, boşta kalanın işi ve kurucunun yeri kararlarını ister | Ekip PRD'si (Erdem'in kurucu araştırması dahil) |
| D2a | D2b'den: çekme, "en çok bir devreden" kalkanının kalkması, `put_first` `carried_out` | Erdem'in merdiveniyle çelişiyor (adım tablosu §0c, 2026-10-23) | Ekip PRD'si |
| D2a | D3'ten: testçinin düzeltme işini yapması. Adım tablosu §0b "testçi bugün yalnız Test'e uyar" diyor, kod öyle değil (testçinin ikincil alanı Yazılım); düzeltme işinin B2B'de %13'ünü, B2C'de %24'ünü testçi yaptı | Atama ve uyum kararı (K6, K7) | Ekip PRD'si |
| D2a | Prob `PRED`/`CLOSE`'a atanan kişiler ve çekilen kartlar | Motor D2a'da | D2a |
| D4 | PM'in hazırlık sütununun kaynağı. Sütunu yalnız oyuncunun "→"su ve onaylanan PM planı dolduruyor; öneri ve bot doldurmuyor; sütun boşken PM'in haftası boşa gidiyor (D4 probu: katkı 0). Yardımcı yönetmen 2026-10-23'te Erdem'e götürdü: A PM önerinin sığmayan sıradaki kartlarını hazırlar, B öneri sonraki sütunu da doldurur, C böyle kalır | `ERDEM_KARARLAR`'da cevap yok; D8a'ya girmedi | Erdem'in cevabı |
| D4 | PM'in boşunun araştırma kartına gitmesi; 1★ altı PM'in faydası; izne çıkan hazırlayanın kartı; aday sütununa dönen kartın hazırlığının kaybolması; `mvp_eta` ve `plan_outcome`'un hazırlığı oynatmaması | PRD sessiz ya da atama kuralı ister | Ekip PRD'si, U1 isterse arayüz |
| D2c | Proaktif P ve süre kapısı | D2a'nın motoruna bağlı | D2a |
| D3b | Gönder sorusu (bağlı kip), eşikli kip ayarı, sürüm notunun yeni satırları, "Test: n hata buldu", kâğıt konuşanı kuralı (kartın sorumlu PM'i söyler; PM yoksa kurucuya ek bilgisiz), PM'siz çeyrekte PM kâğıdı | T1, T2, eşikli kip (Soru 6) | Erdem'in cevabı ve arayüz PRD'si |
| D5a | Atlas aşama hızları, Görevler matrisi uyarısı, kurucu dosyasının yıldızları, PM'in hazırlık hızı satırı, Atlas'ın huyu sayıp saymaması | Ekip ekranının arayüz görevi (adım tablosu §0c) | Ekran tonu görevi ve Erdem |
| D5b | Özenli ve Aceleci etiketi | Karar 24 modelinde tanımı yok; soru M2 sayfasında (OA) | Erdem |
| D6 | Plan ekranı | Ürün arayüzü görevine geçti (`docs/tasks/GOREV_URUN_ARAYUZU.md`, oturum 6e) | 6e |
| D7 arayüzü | Destek kartının k'li eşik satırı | Arayüz görevi | 6e |
| D8a arayüzü | Öneri satırının metni ve neden cümlesi | Arayüz PRD'si KR3 | 6e |
| D8b arayüzü | ÇEYREK'in PM kilidi, hedef menüsü ("Hatalar", "Hedef yok"), devret düğmesinin kilidi ve nedeni, PM ayrılınca ileti; `ProductModel._goal()` "bugs" hedefini çizemez; "v1.0 öncesi sabit Çekirdek" (P14) | U3, U5 | 6e |
| D8b ek | "Sprint <PM> tarafından başlatıldı" satırı o anki PM'in adını okur; izindeki PM'de devret anahtarı gizli | Ayrı karar, arayüz | 6e |
| D8c, D8d | Derinlik kartı, hesap isteği kartı | Pazar 2 kart arzını yeniden kuruyor | Kart yenilemesi |
| D9 | §4.1, §4.2, §4.3 ölçümü | D2a ve D2c'ye bağlı | D2a, D2c |
| Erdem'de | Demo günü kartı 2. haftada gelsin mi (D1'de 1 haftalık sprint kalkınca istenmiyor, kart veride); kurucunun 2★ tabanı ve güçlü alanı; eğitim ve dinlenmenin seçtirilmesi; U1 ile U7 ve eşikli kip | Kurucu ve arayüz kararları | Erdem |
| D1b | "Kurucu sprintte" anahtarı sprint ortasında değişirse ekip yeniden atanmıyor (`_restaff` yok); yalnız bayrak, setter ve `team()` okuyucusu var | Arayüzü kuran PRD yapacak | Ürün arayüzü PRD'si |

Park listesine girmeyenler:
- **D8a'nın K1 kolu** (`_k1_only`, `run_probe.gd:294`; preset `full_run_b2c_k1`, `:201`). Yardımcı yönetmen 2026-10-24: kalır,
  bir ölçüm aracıdır; Erdem'in kuralı ileride ajanların kullanabileceği aracı silmez. Preset ve belgeler olduğu gibi. **Kolu
  kullanacak olana not:** Ürün arayüzü U1'i (`29ae999`, `baa63da`'nın üstünde) `SprintSystem.remove()`'u takip kartını
  (`follow`) reddedecek biçimde değiştirdi (K02). K1 kolu kesme kâğıdından gelen takip kartını artık sprintten çıkaramaz, bot da
  çıkaramaz. K1 ve çekirdek kolları (`full_run_b2c_k1`, `full_run_quality_core[_desk]`) `29ae999`'dan sonra ölçülürse fark
  K02'den gelebilir; kâğıt gelen koşularda taban oynayabilir. Bu rapordaki ölçüm U1'den öncedir (§6.2).
- **D8b'nin devret bayrağı:** yardımcı yönetmen 2026-10-24 Karar 12'yi okudu (son PM ayrılınca bayrak silinir, izin ayrılmak
  değildir); D8b ek'te yazıldı (`baa63da`).

### 5.1 Yorumu teyit bekleyenler (yardımcı yönetmen)
Kodlayıcı ya da inceleyici şu yerlerde PRD'nin ya da görev yazısının bir okumasını uyguladı; varsayılan değil, ama teyit ister:
- D2b ek: `out` yalnız kapanışta devreden kartlardan okunur, karar kâğıdının çıkardığı kart sayılmaz; araştırma kartının işi
  hiçbir aşamaya yazılmaz (PRD_URUN_SPRINT_ARAYUZU §7.3 E2). Tersi tek satır.
- D2b: probun yeni adlı nedeni `cause=bugs` (plan çizimiyle Başlat arasında bayatlayan düzeltme kartı boyutu; D2a kapatır).
- D3: kimsenin yapmadığı Geliştirme işi (karar kâğıdının ilerlemesi) Δ = 0 sayılır ve testte yakalanmaz; ayrılan çalışanın işi
  yakalama paydasından düşer; geri alınan testin yeniden yapılan işi paydaya girer; D1 ile D2b arasında yazılmış şema 19
  kayıtları için göç yok; kart tohumu (koşu | sürüm | kart) nadiren çakışabilir.
- D4: düzeltme işi de hazırlık hızını alır (etkisi puanların %0,25'inden az; sim yalnız üç aşamayı böler).
- D4 ek: Ürün'ün "N kişi boşta" satırı hazırlayacak kartı olmayan PM'i boşta sayar.
- D7m: "son 8 hafta" son 4 sürüm kaydıyla okunur (erken kapanan sprintlerde pencere 4 ile 8 hafta); teslim `velocity.done`'dır
  (yarım iş dahil, sim'de biten kartlar). **Erdem'e:** Erdem 2026-10-17 "buglar feature kartları kadar fazla SP'ye sahip
  olmamalı" dedi (GUNCELLEMELER ch03 §8.4); Karar 14 ile 8 hatalı kart K1'i (15), 20 hatalı kart K3'ü (40) geçer, kart tavansız
  (30 hata 60 puan). PRD'nin kararı uygulandı; pay tavanı (D8a) kartın büyüklüğünü değil plandaki payı sınırlar.
- D8a: atlama sınırı art arda sayılır (D_MODEL_v3 §6.5; D0s toplamı sayar); pay tavanı yerleşimdeki bütün düzeltme işini sayar
  ("+" ve devreden dahil). Bugünkü katalogda fark görünmüyor.

## 6. Ölçüm

### 6.1 Son ölçümün sayımı
- Ağaç `baa63da`, 106 koşu (`C:/unicorn_d1/dson_logs`, ağaç `scratchpad/wf/tree_son`). **102 oyun `PROBE END`'le bitti, 0
  SCRIPT ERROR** (log klasöründe yeniden sayıldı: `PROBE END` = 1 olan 102 dosya, `SCRIPT ERROR` toplamı 0). Oyunlar: A kolları
  88, `_free` ikizleri 12, `b2b_book20` ve `b2b_book330`. Bitiş: 100 koşunun hepsi `running_on_fumes`, hafta 104.
- Kalan 4 koşu oyun değil, prob: `sprint_team3` ve `sprint_team3_tester` (`--sprint-probe`) `SPRINTPROBE SUMMARY` basar;
  `tick_team6_acc20` ve `tick_team50_acc330` (`--tick-probe`) `TICK` satırı basar. Dördü de satırını bastı (log: SUMMARY 1 ve 1,
  TICK 13 ve 13). Seed'leri yok; takılan ya da süre sınırına düşen oyun yok.
- ⚠️ `D_SON_OLCUM.md:9` dördünü oyun sayımına katıyor: "106 koşu, … hepsi `rc=0`, `PROBE END` sayısı 1" yazıyor; dört probun
  logunda `PROBE END` yok. Doğrusu 102 oyunda 1. Envanter (`D_SON_OLCUM.md:299-300`) 100 ana koşuyu doğru sayıyor.
- `tick_team50_acc330`'ın ilk denemesi kayıt taşıyan `APPDATA` yüzünden reddedildi (`.refused.log`); temiz `C:/dson_tick50` ile
  yeniden koşuldu.
- İlk deneme (06:41–08:00) yarım içe aktarılmış ağaç yüzünden boşa gitti. Logları silindi, sonuçlara girmez.

### 6.2 Ölçüm U1'den önce
6e'nin U1'i `29ae999`'da, `baa63da`'nın üstüne commit'lendi. İçindeki K02 düzeltmesiyle takip kartı sprintten çıkarılamıyor, bot
da çıkaramıyor. K1 ve çekirdek kolları `29ae999`'dan sonra yeniden ölçülürse fark K02'den gelebilir; kâğıt gelen koşularda taban
oynayabilir. Yeni ölçüm koşulmadı, yalnız not (K1 kolunun notuyla aynı, §5).

### 6.3 D0b tabanı ile son durum (koşu medyanı, tohum 1 ile 11)
D0b `5d3ea000` (kod `0616245f` + D0a `8038c424`); son `baa63da`. İki şey birden değişti: oyun modeli (D1 ile D8b ek) ve ölçüm
botu (D8a'dan sonra bot sprinti yalnız önerisiyle kurar; `due` kolunun eşiği `DUE_BUGS × k`). Hiçbir fark tek commit'e
atfedilemez; ayırmak için ayrı koşu gerekir, koşulmadı.

| pazar | kol | hata/koşu | açık hata (sprint sonu) | acil durum/koşu | kâğıt gelen sprint (v1.0 sonrası) | MVP haftası | MRR (hafta 103) |
|---|---|---|---|---|---|---|---|
| B2B | none | 267 → 171 | 146 → 83 | 7 → 8 | %3,6 → %7,7 | 7 → 7 | $159.524 → $148.890 |
| B2B | worst | 227 → 175 | 8 → 8 | 5 → 7 | %6,0 → %7,8 | 7 → 7 | $164.579 → $152.583 |
| B2B | due | 225 → 174 | 7 → 7 | 4 → 8 | %5,0 → %8,0 | 7 → 7 | $161.250 → $153.767 |
| B2B | off | 226 → 175 | 8 → 7,5 | 3 → 8 | %6,0 → %8,9 | 7 → 7 | $159.759 → $151.576 |
| B2C | none | 267 → 115 | 43 → 61 | 7 → 8 | %5,2 → %6,6 | 7 → 7 | $308.148 → $19.284 |
| B2C | worst | 413 → 338 | 15 → 9 | 6 → 8 | %6,7 → %9,1 | 7 → 7 | $1.396.632 → $1.613.028 |
| B2C | due | 456 → 358 | 9 → 8 | 5 → 7 | %9,6 → %10,3 | 7 → 7 | $1.673.808 → $1.778.544 |
| B2C | off | 483 → 370 | 17 → 8 | 4 → 6 | %6,7 → %9,9 | 7 → 7 | $2.211.324 → $2.151.936 |

Öbür değişenler (D_SON_OLCUM Özet ve K2, K5, K6, K12):
- Sürüm sonrası bozulma 0'dan koşu başına B2B 4 ile 5, B2C 2 ile 4'e çıktı; B2B'de kesinti 3 ile 6'dan 2 ile 4'e indi.
- `promise_due` 0 → 18, `sprint_late*` 0 → 10 (100 koşu toplamı, hepsi B2B); B2B'de verilen söz medyanı 2 ile 5'ten 8 ile 11'e.
- Erken kapanan sprint %72,8 → %62,3.
- ⚠️ B2C `fix_none` çöktü: MRR $308K → $19K, kasa $2,14M → $0,27M; teslim edilen kartların düzeltme kartı payı 0,325 → 0,010.
  Örnek koşu `full_run_b2c_fix_none_s1`: hafta 100'de açık hata 118, memnuniyet 10. Nedeni model mi bot mu ayrılamadı.
- B2B kasa (hafta 103) %4 ile %18 düştü ($0,62–0,72M → $0,59–0,60M).
- Tick probu 50 kişi ve 330 hesap: saat adımı p95 49,5 → 24,9 ms, en çok 82,1 → 30,8 ms, 16 ms üstü kare 21 → 9; gece yine
  ölçülemedi (`night n=0`). Tek koşu, gürültü payı ölçülmedi.

### 6.4 Hata katsayısı c
- c = 0,212 [WORKING] (`sprint.json:33`). "Onay bekliyor" altında değil (yardımcı yönetmen 2026-10-23; Erdem 2026-10-23 öğle:
  "şimdilik D'nin kalibrasyonuyla kalır, onay sorusu yok").
- Kalibrasyon ölçümü (D3): A kolları `full_run[_b2c]_fix_{none,worst,due,off}`, 104 hafta, tohum 1 ile 6, 48 koşu, D0b'nin aynı
  tohumlarıyla. Koşu başına canlı hatlara inen hata (`PROBE BUGS new=`) B2B 177,1 (D0b 243,1), B2C 317,1 (403,2), iki pazar
  247,1 (323,2). **Sapma −%23,5**, %30 eşiğinin içinde; c ölçeklenmedi. D3'ün düzeltmesinden sonra yeniden koşulan iki koşunun
  `^PROBE` satırları kodlayıcınınkiyle bayt eş, yani ölçüm son kod için geçerli.
- c geçici; Erdem kartları sıfırdan yenileyecek (daha büyük kartlar), hata katsayısı o turda kartın puanına bağlanacak.

### 6.5 Canlı hatlara inen hata, kaynağına göre
Ölçülen satır `PROBE BUGS new=` (koşu toplamı, yalnız v1.0'dan sonra). Kaçan hata `PROBE SHIP escaped=` toplamı (D0b'de bu alan
`faulty=` idi, hattına hata yazılan kart sayısı, 100 koşuda hep 0). Log hata başına kaynak yazmaz: "kaçan dışı" Destek masasının
doğruladığı bildirim (`support_system.gd`), olay ve kâğıt etkileri (`effects.gd`) ve kâğıdın `leaks`'idir. Koşu başına medyan;
"kaçan dışı" her koşunun farkının medyanıdır (`d0b_per_kosu.tsv`, `d_son_per_kosu.tsv`).

| pazar | kol | D0b toplam | D0b kaçan | D son toplam | D son kaçan (Karar 24) | D son kaçan dışı (Destek + olay + kâğıt) | kaçanın payı |
|---|---|---|---|---|---|---|---|
| B2B | none | 267 | 0 | 171 | 17 | 155 | %9,7 |
| B2B | worst | 227 | 0 | 175 | 15 | 160 | %8,1 |
| B2B | due | 225 | 0 | 174 | 15 | 160 | %8,6 |
| B2B | off | 226 | 0 | 175 | 14 | 161 | %8,6 |
| B2C | none | 267 | 0 | 115 | 20 | 95 | %17,4 |
| B2C | worst | 413 | 0 | 338 | 25 | 307 | %7,3 |
| B2C | due | 456 | 0 | 358 | 24 | 325 | %7,4 |
| B2C | off | 483 | 0 | 370 | 25 | 351 | %5,8 |

D3'ün ayrı ölçümü (kod içi sayaçla, tohum 1 ile 6, kol ortalaması, koşu başına): B2B Destek taban akışı 158 + kaçan 20; B2C 303
+ kaçan 23 + olay kartı 2. D0b'deki fazlalık Destek akışının "yeni kod" terimiydi (B2B yaklaşık 85, B2C yaklaşık 100 hata/koşu);
D3 onu sildi. Doğan / bulunan / kaçan hata koşu başına B2B 28,6 / 8,9 / 19,8, B2C 34,4 / 10,5 / 23,9.

### 6.6 Görüşme maliyetinin Ar-Ge ve destek üstündeki etkisi
D1b ölçümü (`--run-log=full_run:104:sim:1 --lang=tr`, 103. hafta; HEAD / D1b / pay 1,0'a sabit): Ar-Ge 12 / 12 / 12; destek
raporu gelen hafta / temsilcili hafta 67/86 / 53/84 / 67/86. Ar-Ge ve destek kodları değişmedi, saat defterini
(`founder_meeting_hours`, oturum saati) okumaya devam ediyor; gün bedeli (`MEETING_DAYS`) yalnız sprint payına girer. Pay 1,0'a
sabitlenince destek de HEAD'e döner: destekteki fark, kurucu payının yavaşlattığı gidişle birlikte geliyor.

### 6.7 Satış haftasının sprinti yavaşlatması (istenen takas)
Bir satış görüşmesi sonraki haftanın kurucu payını tam 0,8 yapar (yaptığı haftaya dokunmaz), masa iki gün (0,6), beş görüşme
günü 0 (kurucu o hafta ekipte yok). Smoke `sprint_founder_share_frozen`. Bot haftada 4 satış görüşmesi yapıyor; kurucunun payı 104
haftanın 93'ünde 0,2 (ortalama 0,263). Y(s) tek başına B2B koşusunu değiştirmez; farkın tamamı kurucu payından. B2C'de MRR
$1.481.532 → $1.466.316.

### 6.8 Kurucunun satış görüşmeleri (kayıt için, açık soru değil)
Görüşme 1 / 1 / 2 gün olunca B2B botunda seed 10 hafta geç imzalanıyor (gün 24 → 34), 103. haftada sürüm 77 → 67, MRR −%12
($161.250 → $142.299), kasa $719K → $442K (−%38) (D1b ölçümü, `wf/d1b_report2.md`). Bot haftada 4 satış görüşmesi yapıyor,
kurucunun payı 104 haftanın 93'ünde 0,2.
"Erdem 2026-10-23: kabul, sabitler kalır."
Para dengesine pazarlama modülü gelince yeniden bakılacak.

### 6.9 Plan süresi (`PLANMS`, ortanca ms, bu makine)
Bütçe: oyuncunun tıklamasında ve sprint sınırında ≤ 100 ms, 50 kişilik dünyada (yardımcı yönetmen; D2c'nin kapısı).
- D0a tabanı, 50 kişi 14 kart: ekranın tam kurulumu aday kartlarla 217 (en çok 246); aday kalmayan dolu planda 68 ile 74; öneri
  64; aday başına `can_add` 8; `mvp_eta` 13.
- Ekranın tam kurulumu (`fill=0`, B2B): D2b'den önce → D2b 6 kişi 60,6 → 57,8, 25 kişi 93,2 → 92,2, 50 kişi 143,4 → 144,6;
  D3 6 kişi 57,0 → 64,7, 25 kişi 92,3 → 100,3, 50 kişi 144,3 → 153,1; D4 25 kişi 100,2 → 102,0, 50 kişi 154,6 → 155,3.
- Öneri döngüsü (D8a): 1 kişi 1,46, 6 kişi 8,05, 25 kişi 12,62, 50 kişi 20,90 (en çok 24,9); önceki kural 50 kişide 42,70.
- ❌ 50 kişide ekran 155 ms, 25 kişide 102 ms: bütçenin üstünde. Ek maliyetin büyüğü `SprintBugs.record`'un her iş parçasında
  çalışması (D3). D2c'nin süre kapısının girdisi; ilk çare hesabı karelere bölmek, ilk aday `mvp_eta`.

### 6.10 104. hafta yumuşak tavanı
Bot 104. haftada yumuşak tavana takılıyor (`running_on_fumes`, `endings_system.gd` `_check_soft_cap`; bütün yapılarda). Son
ölçümde 100 koşunun 100'ü hafta 104'te bu sonla bitti (D0b'de de). Tohum 424242 ile `full_run_staff25/50` ve `build=ea` 22
kişide bitiyor; 25 ve 50 kişilik ölçümler yalnız `b2b_book20/330` fikstürüyle yapılır (yardımcı yönetmen 2026-10-22). Bulgu
ekonomi PRD'sine girdi.

## 7. Kart yenilemesinde yeniden ölçülecekler
- **c ve hata katsayısı:** kartın puanına bağlanacak; hacim yeniden kalibre edilir. Log hata başına kaynak yazmadığı için Destek
  akışı ile kaçan hata yalnız toplamdan ayrılıyor (§6.5).
- **İlke etkisi:** ilke yer değişimi 3 ile 5★ gereksinimli kartlarla yeniden ölçülür (adım tablosu §5).
- **Süre:** kart sayısı artınca `PLANMS` ve D2c'nin süre kapısı (bugün en çok 14 kart).
- **Arz kapıları** (§4.1 madde 6): derinlik ve istek kartıyla (D8c, D8d).
- **PM eklemenin yönü 12 ve 25 kişide:** bugünkü katalog ilk sprintlerde bitiyor, ölçüm duyarsız (D4).
- **k'nin teslim terimi:** bugün çoğu sprintte k = 1 (`full_run_staff50` 78 `PROBE FIX` satırının 76'sında); teslim haftada 55'i
  geçince devreye girer (D7m).
- **Kâğıtlar:** tasarımcı kâğıtlarının hiç gelmemesi ve kâğıt oranı.

## 8. Şema el sıkışması ve C ile ortak dosyalar
- **Şema:** D1 19'u aldı (`SCHEMA_VERSION` 19, kol `if version < 19: _migrate_18`, `save_manager.gd:16`, `:206`, `:1008`). C3a
  sıradakini alır: 20, kol `if version < 20: _migrate_19`, vakalar `save_v20_*`. D1'den sonra şema açılmadı. Varsayılanla okunan
  yeni alanlar: `GameState.founder_sprint_pay` (1,0), `founder_booking_charged` (false), `founder_in_sprint` (true),
  `founder_meetings_week` ve `founder_meetings_frozen` (boş); kartta `by`, `born`, `found`, `fix`, `tested`, `send`, `cut`,
  `prep_by`, `prep_done`, `prep_gain`, `prep_cut`; sürüm kaydında `escaped`, `overflow`, `velocity.weeks`.
- **C'ye sözleşmeler** (adım tablosu §4 madde 5):
  - Kesinti sırası: D3b `sprint.json`'da tek veri satırı olacak, C5 devralır. D3b park, satır yazılmadı.
  - B2B hata terimi: D7m `B2B_BUG_SAT_*` ve `COMPLAINT_BUG_GATE`'i ölçeklemedi; C3a terimi `SprintCatalog.limit_k()`
    (`sprint_catalog.gd:173`) ile kurar. RAPOR_A'nın "SLIP_BUGS 24"ü sabit değil, `run_probe.gd` `b2b_slip` fikstürünün `bugs`
    değeri.
- **C ve E için adlı okumalar:** hattıyla açık hata `ProductState.open_bugs`; sürümde kaçan hatanın hatları sürüm kaydının
  `escaped`'i (`SprintSystem._close`, `sprint_system.gd:1454`); hat profili `sprint.json` `need` tablosu (Karar 3); k
  `SprintCatalog.limit_k()`; itibar eşiği `SupportSystem.neglect_threshold()` (`support_system.gd:285`); taşan aşama sürüm
  kaydının `overflow`'u. İstek kartının teslimi ve arz kaynakları yok (D8c, D8d).
- **D'nin dokunduğu ortak dosyalar:** `sprint_system.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`, `data/product/sprint.json`,
  `save_manager.gd`, `run_probe.gd`, `sprint_probe.gd`, `endgame_smoke.gd`, `main.gd`, `product_model.gd`, `product_tab.gd`,
  `incident_system.gd`, `support_system.gd`, `hr_constants.gd` (yalnız yorum tablosu), `hr_atlas_modal.gd`, `effects.gd`,
  `seams_product.gd`, `product_fixtures.gd`, `data/events/cards/product/` (D1'in ×5 miktarları), HARITA, CLAUDE.md §6 ve §12,
  GUNCELLEMELER, GDD ZAMAN MODELİ, OLAY MOTORU md. Dokunmadıkları: `strings.csv`, `customer_rep_system.gd`,
  `b2b_sales_system.gd`.
- **B'nin satırları** (PRD §9): `escape_chance` ve `faulty_chance` silindi (D3); `payers` hazırlayan PM'i de sayar (D4); `_speaker`
  değişmedi (D3b park); kâğıt zarı tek sayı 0,5, ilk haftanın sonunda (D1); `team.demo_day` istenmiyor, kart veride (D1, park).
  Kapanan B soruları: 13 (PM'in yapım kutusu yok: PM sprint puanı 0, D4) ve 4 (kaçan hata sürüm kaydına yazılır, D3).
- **Bayat açık maddeler** (yardımcı yönetmenin kod denetimi turuna; `docs/ACIK_ISLER/` dokunulmadı): ACIK_KARARLAR 96'nın (4),
  (6), (21), (23), (25), (51) cümleleri D1, D1b ve D3'ten sonra bayat.

## 9. İstisnalar ve süreç notları
1. **D1'in ikinci, yalnız test düzeltmesi** (yardımcı yönetmenin izni, 2026-10-23): inceleme göçteki imkânsız durum
   varsayılanlarını kaldırınca `save_v15_tickets_become_open_bugs` düştü; ortak `_as_v18_card` yardımcısı eklendi. Oyun koduna ve
   göçe dokunulmadı.
2. **"Ek" commit'leri:** D2b ek, D4 ek, D8b ek, yardımcı yönetmenin sonradan verdiği bir karar için ayrı commit'tir (tanım kararı;
   D4 sorusu 2 (b); Karar 12'nin okunuşu). Her biri kendi inceleme turuyla.
3. **D1b:** inceleme yardımcı yönetmenin Ek 4 madde 2 kararını yazdı (ertelenen yatırımcı randevusu payı bir kez düşürür), yeni
   bool `founder_booking_charged` ile.
4. **D3:** inceleme commit mesajını yeniden yazdı: c'den "onay bekliyor" çıktı (yardımcı yönetmen 2026-10-23), Co-Authored-By
   satırı düzeltildi. Ayrıca `_outcome`'daki tahmin = sonuç hatasını buldu ve düzeltti (planın puanı kalanın azalmasından
   okunuyordu; keşif vakası "plan 2,80, kapanış 20,00"; yeni vaka `sprint_plan_done_counts_fix_work`).
5. **D8b ek:** kodlayıcının kareleri commit'e girmeyen geçici bir `main.gd` senaryosuyla çekilmişti; inceleme kalıcı
   `live:delegate_rehire` fikstürünü ekledi.
6. **PRD'den bilinçli farklar:** şema 20 değil 19 (§3.6); Karar 11'in "erken kapanış kalkar" parçası düştü (Erdem 2026-10-23);
   PM hız ucu %25 (Erdem 2026-10-22 Soru 3; Karar 8'in +%30'u eski sayı).
7. **Araç tuzakları:** `gates.sh prep` liste yolu göreli verilince `files=0` ile salt HEAD kopyası kurup PASS yazar (D3 incelemesi
   not etti; D7m'de sahte PASS verdi, mutlak yolla yeniden koşuldu). `prep`'in `--import`'u bir kez font dosyasında segfault verdi ve yine PASS yazdı (D4 ek). Ortak ağacın `.godot`
   sınıf önbelleği bayat olduğu için headless koşular ortak ağaçta "SprintPrep/SprintBugs not declared" ile düşüyor; kapılar
   ayrık kopyada koşuldu.
8. Tam smoke koşulmadı; push yok.

**Silinemeyen APPDATA ve kopyalar** (güvenlik denetimi `rm -rf`'i reddetti; Erdem elle siler): `C:/dg_D1b*`, `C:/dg_D2b*`,
`C:/dg_D2bek*` (12 kare dizini dahil), `C:/dg_D2bhead*`, `C:/dg_D3`, `C:/dg_D3rev`, `C:/dg_D4*`, `C:/dg_D4ek*`, `C:/dg_D4rev`,
`C:/dg_D7m*`, `C:/dg_D8a*`, `C:/dg_D8b*`, `C:/dg_d8bek*`, `C:/dg_D8bek_shot_*`, `C:/dg_son`, `C:/dg_test`, `C:/dp_d3c`,
`C:/dp_d8afinal`, `C:/dp_d8ahead`, `C:/dp_d8anew`, `C:/d1b_appdata_*` (149 dizin), `C:/d0b_appdata`, `C:/d0b_tick50`,
`C:/dson_tick50`, `C:/unicorn_d0a`, `C:/unicorn_d1b` (1,9 GB). `C:/unicorn_d1` (2,4 GB) D0b ve son ölçümün loglarını
(`d0b_logs`, `dson_logs`) ve `base` anlık görüntüsünü taşır: D9 aynı logları okuyacaksa kalır. Ayrık kopyalar
`scratchpad/wf/tree_*`.

## 10. d_taslak'ta kalması gerekenler (tek liste)
Kök `docs/tasks/faz_cde/d_taslak/`. "Kalır" yanında onu okuyacak açık iş yazılıdır.

| Yol | Karar | Gerekçe ve açık iş |
|---|---|---|
| `ADIM_TABLOSU_D_v2.md` | kalır | D2a, D2c, D3b, D5, D9 satırları ve §5 notları; ana oturumun; arayüz PRD'si atıf yapar |
| `D0s_SIM.md` | kalır | D9'un beklenen değerleri (PRD §4.1 "D0s tablosu") |
| `D0t_G0.md` | kalır | g₀ önerisi; kart yenilemesi (D8c), adım tablosu §3 "saklanır" |
| `D0t_HARITA.md` | kalır | D2a'nın P portu: `_assign`'in çağrı noktaları ve "kalır" istisnaları (satırları `8038c424`'e göre, yeniden bulunur) |
| `ATAMA/A1_OYUNLAR_1.md`, `A2_OYUNLAR_2.md` | kalır | Ekip PRD'si ve kurucu araştırması; SENTEZ_ERP_PAZARI atıf yapar |
| `ATAMA/A3_OLCUM.md`, `A4_TASARIM.md` | kalır | Ekip PRD'si, D2a (K4, K6, K7) |
| `ATAMA/A6_HATA_MODELI.md` | kalır | Kart yenilemesinde c ve hata katsayısı |
| `ATAMA/A8_PROAKTIF_PLAN.md` | kalır | D2c ve D9'un referans tablosu |
| `E1/e1_kararlar.json` | kalır | 27 karar (K1–K7, G1–G4, P1–P3, T1–T6, U1–U7); M2 bunların yalnız 11'ini taşır. G1–G4 kart yenilemesine (D8c), K'ler ekip PRD'sine |
| `E1/e1.html`, `e1_sablon.html`, `build_e1.py` | silinir | Geçmiş karar sayfası; içerik json'da |
| `M/` (betikler, `M_KARELER.md`, `png/` 8,9 MB) | silinir | Eski plan ekranı maketi; Erdem M2'de arayüzün dışarıda yeniden yorumlanacağını söyledi, M2 kareleri yeniden çekilmez (§0c); arayüz PRD'si atıf yapmıyor |
| `M2/m2_sorular.json` | kalır | OA (Özenli/Aceleci, D5b) ve GK (eşikli gönder kipi, D3b) soruları burada; adım tablosu §0c eşikli kipi arayüz PRD'sine bağlıyor ama `PRD_URUN_SPRINT_ARAYUZU.md`'de "eşik" geçmiyor |
| `M2/m2.html`, `m2_sablon.html`, `build_m2.py`, `m2_files.json` | silinir | Cevaplanmış sayfa; cevaplar ERDEM_KARARLAR ve §0c'de; `M/png`'ye bağlı |
| `W/W_METINLER.json`, `W_METINLER.md` | kalır | D'nin oyuncu metinleri; arayüz PRD'si atıf yapar (`PRD_URUN_SPRINT_ARAYUZU.md:761`), D3b, D5a |
| `W/Wa_ADLAR.json`, `Wa_ADLAR.md` | kalır | Derinlik kartı adları; kart yenilemesi (D8c), adım tablosu §3 |
| `araclar/wavecheck_d.py` | kalır | W metinlerinin denetimi (D3b, D5a) |
| `araclar/` öbürleri (`faz_b_*.js`, `int_gate.sh`, `ledger.py`, `adim_briefleri.md`, `csv_splice.py`, `build_review.py`, `review_template.html`, `wavecheck.py`, `stage_step.py`, `stage_csv.py`, `xref_check.py`, `textparity.py`, `__pycache__/`) | silinir | Faz B'nin araçları ve brief'leri; D'nin iş akışı kullanmadı (scratchpad `wf/`'de araç atfı yok). `stage_step.py`'nin bir kopyası `c_taslak/araclar/`'da |
| `dsim/` kökü (`dsim.py`, `dsim_before.py`, `x*.py`, `rep_*.py`, `collect*.py`, `check69*`, `*.pkl`) | silinir | v2 simülasyonu; `dsim/v3` ve D_SIM_v3 yerini aldı; açık iş okumaz |
| `dsim/v3/dsim3.py`, `dgates.py`, `gates.py`, `an_common.py`, `an_*.py`, `mkd0s.py`, `d0s_rapor.py`, `mkreport.py` | kalır | D9'un 23 kapısı ve D0s tabloları; `dgates.py` k'nin formülünü taşır |
| `dsim/v3/atama/a3core.py`, `hata2.py`, `a8plan.py` | kalır | D2a ve D2c'nin P portu (zincir `a8plan` → `hata2` → `a3core` → `dsim3`) |
| `dsim/v3/atama/a6*.py`, `a7*.py` ve öbür `*.py` | kalır | Kart yenilemesinde hata modelinin yeniden ölçümü, D9 |
| `dsim/v3/atama/out*/` (36 MB), `a8_parcalar/`, `rapor_parcalar/`, `a6_metin.md`, `a8_metin.md` | silinir | Koşu çıktıları ve rapor parçaları; parçalar ATAMA/*.md'de (örnek denetim: `kural4.md` A8'de, `p2.md` A3'te) |
| `dsim/v3/g0/` | kalır | g₀, kart yenilemesi (D8c) |
| `dsim/v3/out/` küçük tablolar (`d0s_tablolar*.md`, `dgates_*`, `gates*.json/txt`, `dcheck*`, `ddet*`) | kalır | D9'un referansı |
| `dsim/v3/out/` koşu dizinleri (`R`, `R5`, `R6`, `_prio2`, `R_frow`, `L*`, `P`, `R*_…`; 228 MB'ın neredeyse tamamı) | silinir | Ham koşu çıktısı; tabloları md'lerde |
| `dsim/v3/dbg*.py`, `exp*.py`, `t_*.py`, `tb*.py`, `qk.py`, `trfix.py`, `patch*.py`, `dsim3_orig.py`, `dsim3_batch1.py`, `dsim_v2_base.py`, `dregress.py`, `inceleme_*`, `rv_inceleme.py`, `rapor_*.md`, `proto/`, `__pycache__/` | silinir | Hata ayıklama, prototip ve D0s regresyonu; `dsim3.py` bunları içe almaz |
| `olcum/D0b_TABAN.md`, `D_SON_OLCUM.md`, `d0b_taban.py`, `d_son_karsilastir.py`, `analyze.py`, `fix_tables_fixed.py`, `*_per_kosu.tsv`, `*_a42_tablolar.txt` | kalır | D9'un tabanla yan yana okuması ve kart yenilemesinin yeniden ölçümü (`d0b_taban.py` `analyze` ve `fix_tables_fixed`'i içe alır) |
| `olcum/logs_A`, `logs_B_free`, `logs_B_open`, `logs_D`, `tables_free/` (55 MB) ve 10-18 tarihli `analysis.txt`, `came.py`, `econ2.py`, `extra.py`, `inter.py`, `join_targets.py`, `probe_sum.py`, `runset.sh`, `sprintprobe.sh`, `fixed_*.txt`, `tables_*.txt`, `orig_k5_regen.txt`, `__pycache__/` | silinir | Faz B'nin (B6m) ölçümü; D0b tabanı yerini aldı; `d0b_taban.py` log yolunu argümanla alır |
| `sprint_duzeni/arz.py`, `arz_out.txt` | kalır | Arz kapıları, kart yenilemesi |
