### M6 Söz (tek hesap, 2★ lojistik, dünya sabit, 20. haftada söz sonuçlanır)

Eşiğe uzaklık 8 ve 20 (söz öncesi sabit memnuniyet - eşik). Sahip: kurucu (`cs_dampen` 1,0) ya da temsilci (Müşteri İlişkileri çıktısı 5, 0,725). Tutulan söz eşiği 5 indirir, tutulmayan 5 yükseltir (tavan +10) [`on_promise_resolved` kodda kalır, C0_HARITA §7].

| söz | sahip | uzaklık | hf 29 | hf 40 | en düşük | Risk | sonuç | iz kaç haftada sıfırlandı | hf 100 |
|---|---|---|---|---|---|---|---|---|---|
| tutulmadı | kurucu | 8 | 99 | None | 87 | Risk | ayrıldı (hf 32) | - | - |
| tutulmadı | kurucu | 20 | 99 | 97 | 87 | - | - | 13 | 99 |
| geç tutuldu | kurucu | 8 | 99 | 99 | 96 | - | - | 8 | 99 |
| geç tutuldu | kurucu | 20 | 99 | 99 | 96 | - | - | 8 | 99 |
| tutuldu | kurucu | 8 | 99 | 100 | 99 | - | - | 1 | 100 |
| tutuldu | kurucu | 20 | 99 | 100 | 99 | - | - | 1 | 100 |
| tutulmadı | temsilci | 8 | 99 | None | 87 | Risk | ayrıldı (hf 32) | - | - |
| tutulmadı | temsilci | 20 | 99 | 99 | 87 | - | - | 10 | 99 |
| geç tutuldu | temsilci | 8 | 99 | 99 | 96 | - | - | 6 | 99 |
| geç tutuldu | temsilci | 20 | 99 | 99 | 96 | - | - | 6 | 99 |
| tutuldu | temsilci | 8 | 99 | 100 | 99 | - | - | 1 | 100 |
| tutuldu | temsilci | 20 | 99 | 100 | 99 | - | - | 1 | 100 |

Tutulmayan sözün izi: kurucuda 13 hafta, temsilcide 10 hafta, temsilcide %23 kısa (hedef >= %20). Uzaklık 8: Risk ve ayrılma; uzaklık 20: Risk yok.

### M8 Güncellenmeyen ürün (Karar 7: yaş yalnız iki vurgu alanına dokunan yayından sayılır)

Hesap 12. haftada imzalar (3★ ürün hazır olduğu 60. haftada); ürün 30. ya da 20. haftada donar (hiçbir alana dokunulmaz), açık hata 3 (Çekirdek, vurgu 1, vurgu 2'de birer). Yaş terimi donmadan 26 / 52 / 104 hafta sonra; hedef 0 / -6 / -12, 52 haftada kayıp 0. Yenileme tutumu: yaş terimsiz / yaş terimli.

| Donma haftası | Yıldız | Yaş (26 / 52 / 104 hf) | Memnuniyet (26 / 52 hf) | Ayrılma | 1. yenileme tutumu (yaşsız → yaşlı) |
|---|---|---|---|---|---|
| 30 | 1★ | 0 / 6 / 12 | 99 / 91 | - | Zamma açık → Zamma açık |
| 30 | 2★ | 0 / 6 / 12 | 73 / 65 | - | Zamma açık → Zamma açık |
| 20 | 1★ | 2 / 8 / 12 | 96 / 88 | - | Zamma açık → Zamma açık |
| 20 | 2★ | 2 / 8 / 12 | 64 / 58 | - | Zamma açık → Aynı fiyat |
| 60 | 1★ | 0 / 6 / 12 | 97 / 91 | - | Zamma açık → Zamma açık |
| 60 | 2★ | 0 / 6 / 12 | 97 / 91 | - | Zamma açık → Zamma açık |
| 60 | 3★ | 0 / 6 / 12 | 76 / 70 | - | Zamma açık → Aynı fiyat |

Bot kollarında yaş (52. haftada hayatta olan, 20. haftadan önce imzalamış hesaplar). Hedef (PRD §4.3 Risk 1): yalnız Çekirdek'e yüklenen kolda yaş terimi <= -3 olan hesapların payı >= %50, dengeli kolda < %10. Sütunlar: hangi yayınlar sayacı sıfırlar (Karar 7: kademe + cila + düzeltme = hepsi).

| Kol | sayaç sıfırlayan yayın | hayatta hesap (52. hf) | yaş <= -3 | pay | yaş <= -1 | pay | Sonuç |
|---|---|---|---|---|---|---|---|
| quality_core | kademe + cila + düzeltme (Karar 7) | 32 | 0 | 0.0% | 0 | 0.0% | kaldı |
| quality_core | kademe + cila | 32 | 0 | 0.0% | 0 | 0.0% | kaldı |
| quality_core | yalnız kademe | 32 | 18 | 56.2% | 32 | 100.0% | geçti |
| fix_worst | kademe + cila + düzeltme (Karar 7) | 33 | 0 | 0.0% | 0 | 0.0% | geçti |
| fix_worst | kademe + cila | 33 | 0 | 0.0% | 0 | 0.0% | geçti |
| fix_worst | yalnız kademe | 33 | 0 | 0.0% | 0 | 0.0% | geçti |
| fix_due | kademe + cila + düzeltme (Karar 7) | 35 | 0 | 0.0% | 0 | 0.0% | geçti |
| fix_due | kademe + cila | 35 | 0 | 0.0% | 0 | 0.0% | geçti |
| fix_due | yalnız kademe | 35 | 0 | 0.0% | 0 | 0.0% | geçti |
| quality_core masalı | kademe + cila + düzeltme (Karar 7) | 32 | 0 | 0.0% | 0 | 0.0% | kaldı |
| quality_core masalı | kademe + cila | 32 | 0 | 0.0% | 0 | 0.0% | kaldı |
| quality_core masalı | yalnız kademe | 32 | 18 | 56.2% | 32 | 100.0% | geçti |
| fix_worst masalı | kademe + cila + düzeltme (Karar 7) | 33 | 0 | 0.0% | 0 | 0.0% | geçti |
| fix_worst masalı | kademe + cila | 33 | 0 | 0.0% | 0 | 0.0% | geçti |
| fix_worst masalı | yalnız kademe | 33 | 0 | 0.0% | 1 | 3.0% | geçti |

### Yenileme sonuç dağılımı (Karar 8 ve 9 oranlarıyla; tohum 7 ve 11 birleşik)

Her satır yenileme dönemi açılan hesap (imzadan 44 hafta sonra, <= 104. hafta). Tutum: Zamma açık / Aynı fiyat / İndirim ister / Ayrılmayı düşünüyor / Yenilemeyecek. Sonuç zarı: bütçe > başka ürüne geçiş > mali azalış > koltuk artışı (sıra varsayım). Politika: satışçı raporunun 1. seçeneği (tutumun en iyi fiyatı).

| Kol | karar | yenileyen | Zamma açık | Aynı | İndirim | Ayrılmayı düşünüyor | Yenilemeyecek | koltuk artışı | mali azalış | başka ürüne geçiş | bütçe: küçülme | bütçe: ayrılma |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | 113 | 111 (98.2%) | 0 (0%) | 3 | 82 | 27 | 1 | 0 | 0 | 1 | 0 | 0 |
| en kötüsünü düzelten (worst) | 234 | 232 (99.1%) | 234 (100%) | 0 | 0 | 0 | 0 | 92 | 10 | 2 | 6 | 0 |
| vadesi gelen düzelten (due) | 231 | 226 (97.8%) | 231 (100%) | 0 | 0 | 0 | 0 | 75 | 12 | 5 | 2 | 0 |
| hata bedeli kapalı (off) | 243 | 241 (99.2%) | 243 (100%) | 0 | 0 | 0 | 0 | 95 | 11 | 2 | 6 | 0 |

### M13 Yenileme kapısı (bakımlı kol = worst + due + off)

Hedef: bakımlı üründe yenileyen >= %90; 104 haftalık B2B koşusunda (tohum 7 ve 11 ayrı) koltuk artışı da mali azalış da en az birer kez; her sonucun adlı nedeni var.

| Koşu | karar | yenileyen | koltuk artışı | mali azalış | başka ürüne geçiş | bütçe küçülme | bütçe ayrılma | Zamma açık payı |
|---|---|---|---|---|---|---|---|---|
| fix_worst_7 | 104 | 100.0% | 45 | 5 | 0 | 3 | 0 | 100% |
| fix_worst_11 | 130 | 98.5% | 47 | 5 | 2 | 3 | 0 | 100% |
| fix_due_7 | 98 | 99.0% | 38 | 3 | 1 | 0 | 0 | 100% |
| fix_due_11 | 133 | 97.0% | 37 | 9 | 4 | 2 | 0 | 100% |
| fix_off_7 | 106 | 100.0% | 45 | 5 | 0 | 3 | 0 | 100% |
| fix_off_11 | 137 | 98.5% | 50 | 6 | 2 | 3 | 0 | 100% |

Toplam: 708 karar, yenileyen 98.7% (hedef >= %90: geçti); koltuk artışı ve mali azalış her koşuda en az birer kez: geçti.

Kâğıt (Karar 8: yalnız satışçı yolunda en az bir hesap "İndirim ister" ya da kötüyse, kurucu yolunda Yenilemeyebilir etiketli hesap varsa; ayda en çok 1):

| Kol | yenileme olan ay (4,35 hf) | kâğıtlı ay | kâğıtlı ay, ilk yenileme dahil |
|---|---|---|---|
| hiç düzeltmeyen (none) | 20 | 19 (95%) | 20 (100%) |
| en kötüsünü düzelten (worst) | 24 | 0 (0%) | 2 (8%) |
| vadesi gelen düzelten (due) | 24 | 0 (0%) | 2 (8%) |
| hata bedeli kapalı (off) | 24 | 0 (0%) | 2 (8%) |

Cevapsız kâğıt (2 hafta, herkese aynı fiyat; tutumun bir basamak üstü gönülsüz kabul -6, iki ve fazlası yenilemez):

| Kol | karar | yenileyen (en iyi fiyat) | yenileyen (aynı fiyat) | gönülsüz yenileme | aynı fiyatta ayrılan |
|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | 113 | 98.2% | 75.2% | 82 | 26 |
| en kötüsünü düzelten (worst) | 234 | 99.1% | 99.1% | 0 | 0 |
| vadesi gelen düzelten (due) | 231 | 97.8% | 97.8% | 0 | 0 |
| hata bedeli kapalı (off) | 243 | 99.2% | 99.2% | 0 | 0 |

### M9 Ürün dışı kayıp

Hedef (öneri): bütçe kesintisi ve başka ürüne geçişle tam kayıp yılda hesapların <= %2,5'i; bütçe olaylarının >= %50'si küçülme. Birinci satır bot kollarından gözlenen karar havuzu (iki tohum); ikinci satır 330 hesaplık deftere ölçeklenmiş beklenen değer (yıldız karışımı ve "memnun" payı havuzdan, 1.000 deneme).

| Havuz | karar | bütçe olayı | küçülme payı | başka ürüne geçiş | tam kayıp (bütçe ayrılma + geçiş) | tam kayıp / yıl-hesap | 330 hesap: tam kayıp / yıl | küçülme / yıl | Sonuç |
|---|---|---|---|---|---|---|---|---|---|
| bakımlı (worst+due+off) | 708 | 14 | 100% | 9 | 9 | 1.27% | 4.54 (1.38%) | 6.24 | geçti |
| bakımsız (none) | 113 | 0 | - | 1 | 1 | 0.88% | 11.28 (3.42%) | 0.00 | geçti |

### RAPOR_Q §1 madde 2 (❌2): satışçı kapanış kaybı oranı

Q kapısı: masalı `fix_worst` kolunda satışçı kapanışlarının %5-15'i kaybedilir (2★+3★ sütunundan okunur); masalı `quality_core` kolunda >= %20. Kapanış = `PROBE FIT by=rep` (imzalanan) + `PROBE REPLOSS` (zarla kaybedilen). Beklenen kayıp (ex-ante): C kapısından düşen aday = kesin kayıp (zarsız); geçen aday için kayıp ihtimali 1 - p, p = `CLOSE_CURVE(U)` (kapıda loss_area boşsa 1) ve C ile birlikte p >= zar tabanı. Gerçekleşen REPLOSS yalnız Q'nun zarıdır.

| Kol | Küme | kapanış | gerçekleşen REPLOSS (Q zarı) | Q zarı ex-ante | yalnız C kapısı | C kapısı + zar (taban 0,60) | C kapısı + Q zarı (taban yok) | Q kapısı |
|---|---|---|---|---|---|---|---|---|
| fix_worst_desk | bütün | 328 | 0 (0.0%) | 0.4 (0.1%) | 0 (0.0%) | 0.4 (0.1%) | 0.4 (0.1%) | %5-15 |
| fix_worst_desk | 2★+3★ | 19 | 0 (0.0%) | 0.4 (1.8%) | 0 (0.0%) | 0.4 (1.8%) | 0.4 (1.8%) | %5-15 |
| quality_core_desk | bütün | 177 | 15 (8.5%) | 16.8 (9.5%) | 25 (14.1%) | 27.8 (15.7%) | 27.8 (15.7%) | >= %20 |
| quality_core_desk | 2★+3★ | 33 | 15 (45.5%) | 16.8 (50.8%) | 25 (75.8%) | 27.8 (84.2%) | 27.8 (84.2%) | >= %20 |

Zarın erişebileceği tavan: kapanışın yalnız müşterinin baktığı bir alan eksikken (loss_area dolu) zar atılır. Bu paylar bir zar eğrisinin ulaşabileceği en çok kayıp oranının üst sınırıdır.

| Kol | CORE_2 | kapanış | loss_area dolu | pay | 2★+3★ kapanış | loss_area dolu | pay |
|---|---|---|---|---|---|---|---|
| fix_worst_desk | 1,25 | 328 | 5 | 1.5% | 19 | 5 | 26.3% |
| quality_core_desk | 1,25 | 177 | 33 | 18.6% | 33 | 33 | 100.0% |
| fix_worst_desk | 1,5 | 312 | 11 | 3.5% | 60 | 11 | 18.3% |
| quality_core_desk | 1,5 | 168 | 31 | 18.5% | 31 | 31 | 100.0% |

Öneri taraması (masalı `fix_worst`, 2★+3★ ve bütün; beklenen kayıp %): kapı payı (eşik + x) ve zar tabanı. Kırmızı çizgi: hedef %5-15.

| kapı payı x | zar tabanı | fix_worst bütün | fix_worst 2★+3★ | quality_core 2★+3★ (>= %20) |
|---|---|---|---|---|
| 10 | 0.60 | 0.1% | 1.8% (n=19) | 84.2% (n=33) |
| 10 | 0.45 | 0.1% | 1.8% (n=19) | 84.2% (n=33) |
| 10 | 0.30 | 0.1% | 1.8% (n=19) | 84.2% (n=33) |
| 10 | 0.00 | 0.1% | 1.8% (n=19) | 84.2% (n=33) |
| 12 | 0.60 | 0.1% | 1.8% (n=19) | 86.2% (n=33) |
| 12 | 0.45 | 0.1% | 1.8% (n=19) | 86.2% (n=33) |
| 12 | 0.30 | 0.1% | 1.8% (n=19) | 86.2% (n=33) |
| 12 | 0.00 | 0.1% | 1.8% (n=19) | 86.2% (n=33) |
| 15 | 0.60 | 0.1% | 1.8% (n=19) | 98.0% (n=33) |
| 15 | 0.45 | 0.1% | 1.8% (n=19) | 98.0% (n=33) |
| 15 | 0.30 | 0.1% | 1.8% (n=19) | 98.0% (n=33) |
| 15 | 0.00 | 0.1% | 1.8% (n=19) | 98.0% (n=33) |
| 20 | 0.60 | 0.1% | 1.8% (n=19) | 100.0% (n=33) |
| 20 | 0.45 | 0.1% | 1.8% (n=19) | 100.0% (n=33) |
| 20 | 0.30 | 0.1% | 1.8% (n=19) | 100.0% (n=33) |
| 20 | 0.00 | 0.1% | 1.8% (n=19) | 100.0% (n=33) |

### Zar için gereken beklenti (❌2'nin tavan sorusu)

Sabit dünya: masalı `fix_worst` (910ad1f) kapanışlarının ürünü; yalnız 2★ beklentisi değiştirilir (`CORE_2`, `EMPHASIS_2`). Satır: kapanışların kaçında baktığı alan eksik (zar atılır) ve C kapısı + zar (taban 0,60) ile beklenen kayıp. Hedef %5-15 (bütün kapanışlar; 2★+3★ sütunu n küçük).

| CORE_2 | EMPHASIS_2 | kapanış | alan eksik | C kapısı + zar kaybı (bütün) | 2★+3★ kapanış | alan eksik | kayıp (2★+3★) |
|---|---|---|---|---|---|---|---|
| 1.25 | 1.0 | 328 | 5 | 0.1% | 19 | 5 | 1.8% |
| 1.25 | 1.5 | 328 | 7 | 0.1% | 19 | 7 | 2.4% |
| 1.50 | 1.0 | 328 | 5 | 0.2% | 19 | 5 | 2.6% |
| 1.50 | 1.5 | 328 | 7 | 0.2% | 19 | 7 | 3.2% |
| 1.75 | 1.0 | 328 | 6 | 0.3% | 19 | 6 | 4.8% |
| 1.75 | 1.5 | 328 | 8 | 0.3% | 19 | 8 | 5.3% |
| 2.00 | 1.0 | 328 | 6 | 0.6% | 19 | 6 | 10.4% |
| 2.00 | 1.5 | 328 | 8 | 0.7% | 19 | 8 | 11.4% |

### M10 duyarlılık (imza ÷ eski kod, MVP sonrası 26 hafta)

Erdem'in hedefi %55-65. Satır: kapının hangi biçimi. Tohum 7 ve 11 birleşik, kol `fix_worst` (ve parantezde `fix_none`, `fix_due`, `fix_off`).

| Kapı biçimi | worst | none | due | off | Sonuç (worst) |
|---|---|---|---|---|---|
| Kapı yok (K9 olduğu gibi) | 62.8% | 64.0% | 59.5% | 63.2% | geçti |
| C kapısı: U - hata >= eşik + 10 (Karar 6) | 51.2% | 48.8% | 49.7% | 56.7% | altında |
| kapı adayın U'sunu okur (rakip penceresi dahil), pay 10 | 48.8% | 40.7% | 47.4% | 53.8% | altında |
| pay 5 | 56.4% | 56.4% | 53.8% | 57.9% | geçti |
| pay 0 (eşiğin altına inmesin) | 58.7% | 59.3% | 55.5% | 60.2% | geçti |
| kapı hata terimini okumaz, yalnız U >= eşik + 10 | 56.4% | 59.3% | 52.6% | 56.7% | geçti |
| eşik v3 (30 / 33 / 36), pay 10 | 58.7% | 58.7% | 55.5% | 60.2% | geçti |

### CORE_2 karşılaştırması: 1,25 (bugün, 910ad1f) ve 1,5 (bd9a5ed kayıtları)

Aynı C modeli iki kayıt kümesinde (her biri kendi bot ürün hızıyla). Gate satırları: M3-M5 geç kayıp (tohum 7 / 11), M10, M13.

| Kapı | CORE_2 1,25 | CORE_2 1,5 |
|---|---|---|
| M3 (due geç <= off + 2) | geçti | geçti |
| M4 (worst) | geçti | geçti |
| M5 (none geç kayıp %, tohum 7 / 11) | geçti (14.3 / 34.2) | geçti (10.3 / 30.7) |
| M10 imza ÷ eski kod (worst / none / due / off) | 51.2% / 48.8% / 49.7% / 56.7% | 49.4% / 44.8% / 45.7% / 53.2% |
| M13 bakımlı yenileyen | 98.7% (708 karar) | 98.6% (693 karar) |
