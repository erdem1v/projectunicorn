# C2 ön ölçümü: para (PLAN_C_E1 §4) · 2026-10-20

## Özet (6 satır)
1. İlk çalışan: botun kendi işe alımında runway 9,1 ve 9,2 ay (hedef 6,7 ve üstü: geçti). cash_spend hf 2 ve 2'te alıyor ve kasası 0,4 ile 1,3 bine iniyor, cash_hoard hf 14 ve 13'te alıyor; fark 12 ve 11 hafta (hedef 6 ve üstü: geçti), Series A Avı farkı f=0,5 ile 6,0 ve 5,5 hafta (kaldı).
2. İlk 40 haftada en derin açık: home 23,2 bin ve 23,8 bin (hedef 25 ile 45 bin; home bandın altında: geçmedi), seed 41,5 bin ve 41,2 bin (hafta 40 ve 32, bant içinde); 52. hafta net home 11,5 bin ve 34,6 bin, seed eksi 18,0 bin ve eksi 1,4 bin (hedef 80 bin ve altı: geçti).
3. Evre 3 aylık net home 43,0 bin ve 37,8 bin: Q0b referansının x1,74 ve x1,48 katı (geçti), K9 referansının x5,70 ve x2,89 katı (kaldı), K9 tekrarlayan referansın x2,30 ve x2,14 katı (kaldı); neden: araç ve servis giderinin kalkması evre 3'te aylık 52,6 bin ve 39,6 bin siler, maaş x1,5 ile yeni sunucu fiyatı ancak 17,1 bin ve 14,8 bin ekler.
4. Evre 2'de en düşük runway home 10,0 ve 6,5 ay, seed 6,9 ve 6,5 ay; hedef en az bir kez 4 ayın altına inmek: kaldı (kasa net açığın en az 6 katı kalıyor).
5. Seed kolu (kirasız gider tanımı): tohum 7 seed hf 29'de kasa 127,0 bin, gereken 110,4 bin; hf 29'de karar, hf 30'de varış, runway 5,6 aya iniyor. Tohum 11 seed hf 22'de kasa 154,8 bin, gereken 76,9 bin; varış hf 23, runway 9,5 ay. Kiralı gider tanımında tohum 7 seed haftasında taşınamıyor (kasa 127,0 bin, gereken 134,4 bin). Kadro masayı hf 53 ve 52'de aşıyor, Plaza'ya varış hf 82 ve 83 (6 aylık tutma kuralı Plaza'da 340,4 bin ve 376,4 bin ister).
6. B2C en derin açık home 2,5 bin ve 17,9 bin, seed 11,5 bin ve 28,7 bin (bugünkünün x1,00 ve x1,10 katı, hedef 1,5 ve altı: geçti); 101. hafta net bugünün %113 ve %112'i (hedef %80 ve üstü: geçti). M12 sunucu payı Standart auto B2B %7,4, B2C %6,3 (rapor).

## Kapı tablosu

Her satır: hedef | home | seed | durum | kanıt (bölümler bu dosyada, ham sayılar `out/c0s_econ_e1.json`). Hücre: tohum 7 / tohum 11. Durum yalnız her iki tohum ve ilgili kolda tutarsa `geçti`. Sabit değiştirilmedi.

| # | Ölçü | Hedef | home | seed | Durum | Kanıt |
|---|---|---|---|---|---|---|
| 1a | ilk işe alım haftasında runway (K9 botunun işe alımı) | >= 6,7 ay | hf 15: 9.1 ay / hf 15: 9.2 ay | hf 15: 9.1 ay / hf 15: 9.2 ay (seed'den önce, aynı) | geçti | bölüm 1, `first_hire.k9` |
| 1b | ilk işe alım runway, cash_hoard (k=6,7) | >= 6,7 ay | hf 14: 9.3 ay / hf 13: 9.2 ay | hf 14: 9.3 ay / hf 13: 9.2 ay (aynı) | geçti | bölüm 1 (kural gereği: k=6,7 eşiği runway kapısının kendisi) |
| 1c | ilk işe alım runway, cash_spend (k=2) | >= 6,7 ay | hf 2: 2.6 ay / hf 2: 2.6 ay | hf 2: 2.6 ay / hf 2: 2.6 ay (aynı) | kaldı (kural gereği) | bölüm 1 |
| 2 | ilk 40 haftada en derin kümülatif açık (hf > 30) | 25 ile 45 bin, hf > 30 | 23.2K (hf 40) / 23.8K (hf 32) | 41.5K (hf 40) / 41.2K (hf 32) | kaldı (home) | bölüm 2, `main.*.deep40` |
| 3 | 52. hafta kümülatif net | <= 80 bin | 11.5K / 34.6K | -18.0K / -1.4K | geçti | bölüm 2, `main.*.c52` |
| 4a | evre 3 aylık net, referans: Q0b (eski kod tabanı) | <= 2 x bugün (24.7K / 25.5K) | 43.0K (x1.74) / 37.8K (x1.48) | 35.0K (x1.42) / 29.8K (x1.17) | geçti | bölüm 2, `ref` |
| 4b | evre 3 aylık net, referans: K9 (bugünkü kod) | <= 2 x bugün (7.6K / 13.1K) | 43.0K (x5.70) / 37.8K (x2.89) | 35.0K (x4.64) / 29.8K (x2.28) | kaldı | bölüm 2, `ref` |
| 4c | evre 3 aylık net, referans: K9 tekrarlayan net (tek seferlik hariç) | <= 2 x bugün (27.2K / 21.6K) | 62.7K (x2.30) / 46.4K (x2.14) | 54.7K (x2.01) / 38.4K (x1.77) | kaldı | bölüm 2, `ref` |
| 5 | evre 2'de en düşük runway (en az bir kez < 4 ay) | < 4 ay | 10.0 ay (hf 30-33) / 6.5 ay (hf 18-21) | 6.9 ay (hf 30-33) / 6.5 ay (hf 18-21) | kaldı | bölüm 2, `main.*.mr2_blk` |
| 6a | cash_spend ile cash_hoard: ilk işe alım farkı | >= 6 hf | hf 2 vs 14: 12 hf / hf 2 vs 13: 11 hf | hf 2 vs 14: 12 hf / hf 2 vs 13: 11 hf (aynı) | geçti | bölüm 3 |
| 6b | cash_spend ile cash_hoard: Series A Avı farkı (tahmin) | >= 6 hf | f=1: 12, f=0,5: 6.0 hf / f=1: 11, f=0,5: 5.5 hf | f=1: 12, f=0,5: 6.0 hf / f=1: 11, f=0,5: 5.5 hf (aynı) | kaldı | bölüm 3 (kayma f varsayımı) |
| 7 | seed kolunda taşınma haftası, o haftanın runway'i, Plaza'ya varış | rapor | taşınmaz | tohum 7, seed hf 29: İş hanı kararı hf 29, varış hf 30, runway 7.4 → 5.6 ay; Plaza: kadro hf 53 aştı; para hf 81'de yetti (kasa 345.3K, gerekli 340.4K), varış hf 82, runway 6.4 → 5.7 ay // tohum 11, seed hf 22: İş hanı kararı hf 22, varış hf 23, runway 13.5 → 9.5 ay; Plaza: kadro hf 52 aştı; para hf 82'de yetti (kasa 380.1K, gerekli 376.4K), varış hf 83, runway 6.3 → 5.7 ay | rapor | bölüm 2, taşınma tablosu |
| 8a | B2C en derin açık | bugünkünün <= x1,5 (17.2K / 39.2K) | 2.5K (x0.22) / 17.9K (x0.69) | 11.5K (x1.00) / 28.7K (x1.10) | geçti | bölüm 5 |
| 8b | B2C 101. hf net | bugünkünün >= %80 (2601K / 2739K) | 3735K (115%) / 3896K (114%) | 3674K (113%) / 3833K (112%) | geçti | bölüm 5 |
| 9 | M12 sunucu payı (Standart, auto) | rapor (kapı değil, Karar 2) | 7.4% / 7.3% (B2B auto); B2C 6.4% / 6.2% | 7.4% / 7.3% (B2B auto); B2C 6.4% / 6.2% (aynı) | rapor | bölüm 6 |

### Tutmayan kapılar: tek cümle neden

- **1c ilk işe alım runway, cash_spend (k=2):** cash_spend kasa 2 aylık gider olunca işe aldığı için runway kapısını tanım gereği taşımaz; kapı yalnız cash_hoard'a uygulanır.
- **2 ilk 40 haftada en derin kümülatif açık (hf > 30):** home kolunda açık 23.2K / 23.8K: araç ve servis gideri kalkıp evde kira olmadığı için ilk yıl 25 binin 1.8K / 1.2K altında kalıyor (hafif fazla kolay, Risk 2); seed kolunda İş hanı peşini ve kirası açığı 41.5K / 41.2K'a çıkarıyor, bant içinde.
- **4b evre 3 aylık net, referans: K9 (bugünkü kod):** yeni evre 3 neti 43.0K (x5.70) / 37.8K (x2.89), referansın 2 katını (15.1K / 26.1K) aşıyor: araç (9.1K / 6.5K) ve servis (43.5K / 33.1K) gideri kalkınca evre 3 gideri aylık 35.5K / 24.8K düşüyor, maaş x1,5 ve yeni sunucu fiyatı yalnız 17.1K / 14.8K ekliyor; gelir aynı kaldığı için net bugünkünün çok üstünde.
- **4c evre 3 aylık net, referans: K9 tekrarlayan net (tek seferlik hariç):** yeni evre 3 neti 62.7K (x2.30) / 46.4K (x2.14), referansın 2 katını (54.4K / 43.3K) aşıyor: araç (9.1K / 6.5K) ve servis (43.5K / 33.1K) gideri kalkınca evre 3 gideri aylık 35.5K / 24.8K düşüyor, maaş x1,5 ve yeni sunucu fiyatı yalnız 17.1K / 14.8K ekliyor; gelir aynı kaldığı için net bugünkünün çok üstünde.
- **5 evre 2'de en düşük runway (en az bir kez < 4 ay):** en sıkı 4 haftalık blokta (home: kasa 125.2K, aylık net açık 12.5K / kasa 33.5K, aylık net açık 5.2K) kasa net açığın en az 6 katı kalıyor: araç ve servis gideri kalkınca gelir seed'den önce gideri yakalıyor, seed parası da kasayı tamponluyor (K9 kaydında bu değer 7,4 / 3,1).
- **6b cash_spend ile cash_hoard: Series A Avı farkı (tahmin):** ilk işe alım farkı 12 / 11 hafta ama Series A Avı'na yalnız yarısı yansırsa (f = 0,5) fark 6.0 / 5.5 hafta, tohum 11'de 6'nın altı; f = 1 ile 12 / 11 hafta: sonuç ölçülmemiş kayma varsayımına bağlı.


## 1. İlk işe alım: kasa, kural, runway

Ev kirasız. Kural: kasa >= k x (maaş x1,5 + sunucu), kira yok; arama 1 hafta. Nakit = K9 nakdi + yeni muhasebe farkı; gelir, Frank'in çeki ve seed K9'daki günlerinde (ekibin getirisi sayılmaz: iyimser). Hücre: işe alım haftası / o haftanın runway'i (ay, gelir hariç). `K9 kaydı` = botun kendi işe alımı (hf 15 / 21), aynı kasa ve giderle.

| Koşu | ilk işe alım maaşı (eski bant) | K9 kaydı | allin (k=1) | cash_spend (k=2) | bot (k=6) | cash_hoard (k=6,7) |
|---|---|---|---|---|---|---|
| fix_worst_7 | 2450 | hf 15 / 9.1 | hf 2 / 2.6 | hf 2 / 2.6 | hf 14 / 9.3 | hf 14 / 9.3 |
| fix_worst_11 | 2450 | hf 15 / 9.2 | hf 2 / 2.6 | hf 2 / 2.6 | hf 13 / 9.2 | hf 13 / 9.2 |
| b2c_fix_worst_7 | 2800 | hf 21 / 8.6 | hf 2 / 2.3 | hf 2 / 2.3 | hf 22 / 8.7 | hf 22 / 8.7 |
| b2c_fix_worst_11 | 2800 | hf 21 / 8.6 | hf 2 / 2.3 | hf 2 / 2.3 | hf 22 / 8.7 | hf 22 / 8.7 |
| fix_none_7 | 2450 | hf 15 / 9.1 | hf 2 / 2.6 | hf 2 / 2.6 | hf 14 / 9.3 | hf 14 / 9.3 |
| fix_none_11 | 2450 | hf 15 / 9.2 | hf 2 / 2.6 | hf 2 / 2.6 | hf 13 / 9.2 | hf 13 / 9.2 |
| fix_due_7 | 2450 | hf 15 / 9.1 | hf 2 / 2.6 | hf 2 / 2.6 | hf 14 / 9.3 | hf 14 / 9.3 |
| fix_due_11 | 2450 | hf 15 / 9.2 | hf 2 / 2.6 | hf 2 / 2.6 | hf 13 / 9.2 | hf 13 / 9.2 |
| fix_off_7 | 2450 | hf 15 / 9.1 | hf 2 / 2.6 | hf 2 / 2.6 | hf 14 / 9.3 | hf 14 / 9.3 |
| fix_off_11 | 2450 | hf 15 / 9.2 | hf 2 / 2.6 | hf 2 / 2.6 | hf 13 / 9.2 | hf 13 / 9.2 |
| b2c_fix_none_7 | 2800 | hf 20 / 8.5 | hf 2 / 2.3 | hf 2 / 2.3 | hf 21 / 8.8 | hf 21 / 8.8 |
| b2c_fix_none_11 | 2800 | hf 21 / 8.6 | hf 2 / 2.3 | hf 2 / 2.3 | hf 22 / 8.8 | hf 22 / 8.8 |

Kayıtların seed haftası: fix_worst_7 hf 29, fix_worst_11 hf 22; B2C b2c_fix_worst_7 hf 44, b2c_fix_worst_11 hf 42. İlk işe alım her k için seed'den önce olduğu için `home` ve `seed` kolunda aynıdır (kol yalnız seed haftasından sonra ayrılır).

## 2. Ana ölçüm: B2B `fix_worst`, K9 işe alımları aynen

Bot kararları K9 kaydındaki gibi (ilk çalışan hf 15), gelir K9'un geliri (etkisiz). Sunucu `auto`, Standart. Net = gelir - gider, dış fonlama (Frank'in çeki, seed) hariç; peşin kira gider sayılır. Hücre: tohum 7 / tohum 11.

| Ölçü | tohum | home | seed |
|---|---|---|---|
| en derin kümülatif açık, ilk 40 hf (haftası) | 7 / 11 | 23.2K (hf 40) / 23.8K (hf 32) | 41.5K (hf 40) / 41.2K (hf 32) |
| en derin kümülatif açık, tüm koşu (haftası) | 7 / 11 | 23.2K (hf 40) / 23.8K (hf 32) | 41.5K (hf 40) / 41.2K (hf 32) |
| 52. hf kümülatif net | 7 / 11 | 11.5K / 34.6K | -18.0K / -1.4K |
| evre 3 aylık net | 7 / 11 | 43.0K / 37.8K | 35.0K / 29.8K |
| evre 3 aylık net, tekrarlayan | 7 / 11 | 62.7K / 46.4K | 54.7K / 38.4K |
| evre 2 en düşük runway (ay; blok hafta aralığı) | 7 / 11 | 10.0 (hf 30-33) / 6.5 (hf 18-21) | 6.9 (hf 30-33) / 6.5 (hf 18-21) |
| en düşük nakit | 7 / 11 | 9.3K / 9.6K | 9.3K / 9.6K |
| 101. hf kümülatif | 7 / 11 | 519.1K / 510.8K | 409.3K / 395.4K |

Bugünkü kod referansı (K9 kaydı, 910ad1f): tohum 7: derin 43.1K (hf 40), 52. hf -31.6K, evre 3 net 7.6K, tekrarlayan 27.2K, evre 2 runway 7.4; tohum 11: derin 40.2K (hf 32), 52. hf -19.9K, evre 3 net 13.1K, tekrarlayan 21.6K, evre 2 runway 3.1. Q0b evre 3 net: 7: 24.7K, 11: 25.5K.

### `seed` kolu: taşınma kararı

Kural: seed haftasında kasa >= peşin + 6 x aylık gider. Gider = o haftanın maaşı (x1,5, K9 ise alımlarından) + sunucu + pazarlama + geçerli kira (kirasız tanım); `kiralı` tanım varış ofisinin kirasını giderin yerine koyar. Plaza / Loft: kadro (çalışan + kurucu) masayı aşınca, aynı kuralla.

| Koşu | tanım | seed haftası | kasa o hafta | gerekli (peşin + 6 ay) | taşındı mı | varış | runway (karardan önce / peşinden sonra, yeni gider) | Plaza | Loft |
|---|---|---|---|---|---|---|---|---|---|
| fix_worst_7 | kirasiz | 29 | 127.0K | 110.4K | evet (hf 29 karar) | hf 30 | 7.4 / 5.6 ay | kadro hf 53 aştı; para hf 81'de yetti (kasa 345.3K, gerekli 340.4K), varış hf 82, runway 6.4 → 5.7 ay | kadro masayı aşmadı |
| fix_worst_7 | kirasiz + her hafta yeniden dene | 29 | 127.0K | 110.4K | evet (hf 29 karar) | hf 30 | 7.4 / 5.6 ay | kadro hf 53 aştı; para hf 81'de yetti (kasa 345.3K, gerekli 340.4K), varış hf 82, runway 6.4 → 5.7 ay | kadro masayı aşmadı |
| fix_worst_7 | kirali | 29 | 127.0K | 134.4K | hayır | - | 6.0 ay (karar anı, gider 21.1K) | - | - |
| fix_worst_7 | kirali + her hafta yeniden dene | 29 | 338.4K | 332.4K | evet (hf 76 karar) | hf 77 | 6.3 / 5.7 ay | kadro hf 77 aştı; para hf 80'de yetti (kasa 376.4K, gerekli 364.4K), varış hf 81, runway 6.5 → 5.8 ay | kadro masayı aşmadı |
| fix_worst_11 | kirasiz | 22 | 154.8K | 76.9K | evet (hf 22 karar) | hf 23 | 13.5 / 9.5 ay | kadro hf 52 aştı; para hf 82'de yetti (kasa 380.1K, gerekli 376.4K), varış hf 83, runway 6.3 → 5.7 ay | kadro masayı aşmadı |
| fix_worst_11 | kirasiz + her hafta yeniden dene | 22 | 154.8K | 76.9K | evet (hf 22 karar) | hf 23 | 13.5 / 9.5 ay | kadro hf 52 aştı; para hf 82'de yetti (kasa 380.1K, gerekli 376.4K), varış hf 83, runway 6.3 → 5.7 ay | kadro masayı aşmadı |
| fix_worst_11 | kirali | 22 | 154.8K | 100.9K | evet (hf 22 karar) | hf 23 | 10.0 / 7.5 ay | kadro hf 52 aştı; para hf 86'de yetti (kasa 427.5K, gerekli 418.4K), varış hf 87, runway 6.4 → 5.8 ay | kadro masayı aşmadı |
| fix_worst_11 | kirali + her hafta yeniden dene | 22 | 154.8K | 100.9K | evet (hf 22 karar) | hf 23 | 10.0 / 7.5 ay | kadro hf 52 aştı; para hf 86'de yetti (kasa 427.5K, gerekli 418.4K), varış hf 87, runway 6.4 → 5.8 ay | kadro masayı aşmadı |
| b2c_fix_worst_7 | kirasiz | 44 | 147.4K | 78.5K | evet (hf 44 karar) | hf 45 | 12.5 / 8.8 ay | kadro masayı aşmadı | kadro masayı aşmadı |
| b2c_fix_worst_7 | kirasiz + her hafta yeniden dene | 44 | 147.4K | 78.5K | evet (hf 44 karar) | hf 45 | 12.5 / 8.8 ay | kadro masayı aşmadı | kadro masayı aşmadı |
| b2c_fix_worst_7 | kirali | 44 | 147.4K | 102.5K | evet (hf 44 karar) | hf 45 | 9.4 / 7.1 ay | kadro masayı aşmadı | kadro masayı aşmadı |
| b2c_fix_worst_7 | kirali + her hafta yeniden dene | 44 | 147.4K | 102.5K | evet (hf 44 karar) | hf 45 | 9.4 / 7.1 ay | kadro masayı aşmadı | kadro masayı aşmadı |
| b2c_fix_worst_11 | kirasiz | 42 | 170.7K | 78.8K | evet (hf 42 karar) | hf 43 | 14.5 / 10.3 ay | kadro masayı aşmadı | kadro masayı aşmadı |
| b2c_fix_worst_11 | kirasiz + her hafta yeniden dene | 42 | 170.7K | 78.8K | evet (hf 42 karar) | hf 43 | 14.5 / 10.3 ay | kadro masayı aşmadı | kadro masayı aşmadı |
| b2c_fix_worst_11 | kirali | 42 | 170.7K | 102.8K | evet (hf 42 karar) | hf 43 | 10.8 / 8.2 ay | kadro masayı aşmadı | kadro masayı aşmadı |
| b2c_fix_worst_11 | kirali + her hafta yeniden dene | 42 | 170.7K | 102.8K | evet (hf 42 karar) | hf 43 | 10.8 / 8.2 ay | kadro masayı aşmadı | kadro masayı aşmadı |

## 3. cash_spend ve cash_hoard

İlk işe alım haftası (bölüm 1) ve Series A Avı (MRR >= $120.000, K9 kaydında hf 86 / 95). Kaydırma tahmini: ilk işe alımın gecikmesi kadar (f = 1) ya da yarısı kadar (f = 0,5) sonraki akış kayar; bu bir varsayım, bot koşusu değil.

| Koşu | spend: ilk işe alım (hf) | hoard: ilk işe alım (hf) | fark (hf) | Series A Avı K9 | Series A farkı f=1 | Series A farkı f=0,5 |
|---|---|---|---|---|---|---|
| fix_worst_7 | 2 | 14 | 12 | 86 | 12 | 6.0 |
| fix_worst_11 | 2 | 13 | 11 | 95 | 11 | 5.5 |
| b2c_fix_worst_7 | 2 | 22 | 20 | 64 | 20 | 10.0 |
| b2c_fix_worst_11 | 2 | 22 | 20 | 63 | 20 | 10.0 |
| fix_none_7 | 2 | 14 | 12 | 89 | 12 | 6.0 |
| fix_none_11 | 2 | 13 | 11 | 87 | 11 | 5.5 |
| fix_due_7 | 2 | 14 | 12 | yok | 12 | 6.0 |
| fix_due_11 | 2 | 13 | 11 | 96 | 11 | 5.5 |
| fix_off_7 | 2 | 14 | 12 | 86 | 12 | 6.0 |
| fix_off_11 | 2 | 13 | 11 | 95 | 11 | 5.5 |

Her iki kolun ana ölçümü (ilk çalışan `spend`te hf, `hoard`ta hf'ye çekilir; sonraki işe alımlar K9 kaydındaki gibi; erken ilk çalışanın maaşı eklenir, gelir değişmez). Hücre: tohum 7 / tohum 11.

| Politika | kol | derin açık, ilk 40 hf (haftası) | 52. hf net | evre 2 en düşük runway | en düşük nakit |
|---|---|---|---|---|---|
| spend | home | 34.4K (hf 40) / 35.0K (hf 32) | 0.3K / 23.5K | 9.1 / 4.3 | 0.4K / 1.3K |
| spend | seed | 52.6K (hf 40) / 52.3K (hf 32) | -29.1K / -12.5K | 6.2 / 4.3 | 0.4K / 1.3K |
| hoard | home | 24.1K (hf 40) / 25.5K (hf 32) | 10.6K / 32.9K | 10.0 / 6.1 | 9.3K / 9.6K |
| hoard | seed | 42.3K (hf 40) / 42.9K (hf 32) | -18.8K / -3.1K | 6.8 / 6.1 | 9.3K / 9.6K |

## 4. Etkili gelir (bilgi): C kapısı ve yenileme sonuçlarıyla

C0s'in `income_delta`'sı (C modeli kapısı, yenileme, kayıplar) K9 gelirine eklenir; aynı yeni gider ve ofis kuralı. Bu ölçüm PLAN_C_E1 §4'ün girdisi değildir, yalnız duyarlılıktır (C0S_SONUC §3.4: tohum 7 için 91K, tohum 11 için 107K açık).

| Kol | derin açık, ilk 40 hf (haftası) | 52. hf net | evre 3 aylık net | evre 2 en düşük runway |
|---|---|---|---|---|
| home | 62.6K (hf 40) / 72.5K (hf 40) | -64.5K / -63.1K | 35.3K / 27.2K | 4.9 / 1.3 |
| seed | 80.9K (hf 40) / 97.3K (hf 40) | -94.0K / -99.1K | 26.1K / 23.2K | 3.5 / 1.3 |

## 5. B2C `fix_worst`

Hedef: en derin açık bugünkünün en çok x1,5 ve 101. hf kümülatif net bugünün en az %80'i; mutlak sayı da yazılır. Hücre: tohum 7 / tohum 11.

| Kol | en derin açık (haftası) | bugün (K9 kaydı) | oran | 101. hf net | bugün | oran | en düşük nakit |
|---|---|---|---|---|---|---|---|
| home | 2.5K (hf 45) / 17.9K (hf 45) | 11.5K / 26.1K | x0.22 / x0.69 | 3735K / 3896K | 3251K / 3424K | 115% / 114% | 9.2K / 9.5K |
| seed | 11.5K (hf 45) / 28.7K (hf 45) | 11.5K / 26.1K | x1.00 / x1.10 | 3674K / 3833K | 3251K / 3424K | 113% / 112% | 9.2K / 9.5K |

## 6. M12 sunucu payı (rapor, kapı değil)

Standart fiyat B2B $120 / 50 koltuk, B2C $250 / 1.000 kullanıcı (Karar 2). Pay = 26-104. hf sunucu faturası ÷ gelir. Politikalar: `lean` pay %5, `auto` anahtar açık, `wide` pay %40; Ekonomik ve Kurumsal `auto` ile.

| Koşu | lean | auto (Standart) | wide | auto Ekonomik | auto Kurumsal |
|---|---|---|---|---|---|
| fix_worst_7 | 5.7% | 7.4% | 8.9% | 3.7% | 14.8% |
| fix_worst_11 | 5.6% | 7.3% | 8.8% | 3.7% | 14.7% |
| b2c_fix_worst_7 | 4.8% | 6.4% | 7.6% | 3.2% | 12.7% |
| b2c_fix_worst_11 | 4.7% | 6.2% | 7.4% | 3.1% | 12.4% |
| b2c_fix_none_7 | 4.1% | 5.8% | 6.4% | 2.9% | 11.5% |
| b2c_fix_none_11 | 4.1% | 6.0% | 6.4% | 3.0% | 12.0% |

## Varsayımlar ve C0s'ten farklar

1. **Yöntem C0s'inki:** K9 (910ad1f) bot kayıtlarının aylık gider dökümü (`PROBE MONTH_BURN`) ve `STATE` üzerine muhasebe; bot kararları kayıttaki gibi (tahmin, oyun koşusu değil). Gelir K9'un geliri; C kapısı ve yenileme ana ölçümde yok (bölüm 4 yalnız duyarlılık).
2. **Kurucu maaşsız, araç ve servis yok:** `MONTH_BURN`'ün `salaries` alanı yalnız çalışan maaşıdır (kurucu satırı `tools` tabanındaydı); `tools` ve `service` düşer. Maaş, ek mesai ve işe alım primi x1,5 (prim farkı işe alım gününde, prim = maaşın yarısı).
3. **Sunucu:** Standart (bulut) $120 / 50 koltuk, B2C $250 / 1.000 kullanıcı, `auto` politikası (yük %80'e varınca yük %65'e inecek kadar büyür, küçültmez); hizmet edilen koltuk = MRR ÷ $50 (koltuk fiyat bandının ortası); sunucu MVP haftasından başlar. Aylık = 30/7 hafta.
4. **Ev:** kira 0, uzaktan çalışan sınırı yok (K9 işe alımları aynen). **Ofis kirası** İş hanı $4.000, Plaza $8.000, Loft $18.000; peşin = 2 x kira, karar haftasında bir kez gider yazılır ve nakit düşer; kira varış haftasından (karar + 1) başlar. Masa 12 / 38 / 70, kadro = çalışan + kurucu. Peşin kümülatif nete girer (gerçek nakit çıkışı).
5. **`seed` kolu:** seed haftasında (`PROBE PLAY seed signed` günü) kasa >= peşin + 6 x aylık gider ise İş hanı'na karar; tutmazsa taşınmaz (kural seed haftasında bir kez bakar). Ek duyarlılık: her hafta yeniden dene. Gider tanımı iki türlü (kirasız: geçerli ofisin kirası dahil, varış kirası hariç; kiralı: varış kirası dahil). Plaza / Loft: kadro masayı aşınca aynı kuralla. Aylık maaş toplamı K9 işe alımlarının maaşlarından (ise alım günü + 2'den beri; `payroll_monthly` 87. haftada tutuyor: 28.500), terfi ve ayrılmalar hesapta yok.
6. **Nakit** = K9 nakdi + (yeni kümülatif net - eski kümülatif net); Frank'in çeki ve seed K9'daki günlerinde kalır. Çek şartı yok ama çekin kendisi (MRR eşiği, tek karar) kalır.
7. **İlk işe alım kuralı** (`first_hire_policy`): ilk çalışan olmasaydı nakit = K9 nakdi + (yalnız sunucu ve pazarlama giderli kümülatif - eski kümülatif); gelir K9 gibi; tek seferlik gider (hf 10'daki $300 gibi, ise alım primi dışında) hesapta yok (C0s'in `nohire_cash`'iyle aynı, iyimser). Tetik: kasa >= k x (ilk çalışanın maaşı x1,5 + sunucu); işe alım tetikten 1 hafta sonra. İlk çalışan K9'un ilk çalışanı (geliştirici, eski bant 2.450).
8. **İlk çalışanı kaydırma (spend / hoard ana ölçümü):** ilk çalışanın maaşı K9'daki başlangıcı (işe alım + 2) ile yeni başlangıç arasındaki haftalara eklenir ya da çıkar; sonraki işe alımlar kayıttaki günlerinde, gelir değişmez. Series A Avı kayması f = 1 ve 0,5 ile iki uç tahmin; ölçülmüş değil.
9. **Evre 3** K9 `fix_worst`'te yalnız 17 ve 9 hafta ve tek seferlik giderler (48.000, 30.000) içeriyor; "bugün" üç referansla (Q0b, K9, K9 tekrarlayan net) yazılır. Yeni tekrarlayan net, tek seferlik gider, peşin kira ve işe alım primi hariç.
10. **Evre 2 en düşük runway:** C0s'in `agg` işlevi (4 haftalık bloklar, gider - gelir > 0 olan bloklarda kasa ÷ aylık net açık, en küçüğü). Net açık yoksa `açık yok`.
11. **C0s'ten farklar:** (a) V1 / V2 (Frank şartı) ayrımı kalktı; (b) ev kirasız, İş hanı ilk çalışanla gelmez, seed haftasında ve parayla gelir; (c) Plaza şartı yalnız kadro + para (10 kişi / marka / $45.000 yok); (d) peşin kira eklendi; (e) masa 12 / 38 / 70; (f) `bot` ve `allin` kolları korundu, kapı kararı `spend` ve `hoard` ile; (g) İş hanı runway'i kira içermez (ev); (h) 40 haftalık açık ve 52. hf net peşin kirayı içerir.
12. **Ölçülmeyenler:** masa tavanı yok, uzaktan debuff yok (C9b'ye açık iş); kredi yok; kasa eksiye düşünce kepenk/iflas hesaba girmedi (en düşük nakit yazılır); erken işe alımın ürün hızına etkisi yok.
