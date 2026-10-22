### Evre 3 aylık net: hangi "bugün"

Kapı: evre 3 aylık net <= 2 x bugün. Üç referans: Q0b (eski kod tabanı, `q0b_logs`), K9 (910ad1f, bugünkü kod) ve K9'un tekrarlayan neti (tek seferlik giderler hariç). K9 `fix_worst`'te evre 3 yalnız 6-16 haftadır ve içinde 48.000 ile 30.000 dolarlık tek seferlik gider (88-101. hf) vardır; bu yüzden K9'un evre 3 neti bugünkü ekonomiyi eksik temsil eder.

| Koşu | evre 3 hafta (K9) | Q0b evre 3 net | K9 evre 3 net | K9 tekrarlayan net | yeni (etkisiz) | yeni tekrarlayan | yeni ÷ Q0b | yeni ÷ K9 | yeni tekrarlayan ÷ K9 tekrarlayan |
|---|---|---|---|---|---|---|---|---|---|
| fix_worst_7 | 17 | 25K | 8K | 27K | 35K | 55K | x1.42 | x4.64 | x2.01 |
| fix_worst_11 | 9 | 26K | 13K | 22K | 30K | 38K | x1.17 | x2.28 | x1.77 |

### M12 öneri taraması: Standart birim fiyatı (kapasite politikası oyuncunun)

Hedef: Standart'ta 26-104. hafta sunucu payı %8-12. Fiyat = Standart birim (B2B 50 koltuk, B2C 1.000 kullanıcı); Ekonomik yarısı, Kurumsal iki katı. Hücre: B2B `fix_worst` iki tohum ortalaması; B2C `fix_worst`.

| Pazar | Standart fiyat | lean (pay %5) | auto (80 → 65) | wide (pay %40) | auto Ekonomik | auto Kurumsal | Sonuç (auto ve wide %8-12) |
|---|---|---|---|---|---|---|---|
| b2b | $120 | 5.6% | 7.4% | 8.9% | 3.7% | 14.8% | auto ve lean altında |
| b2b | $135 | 6.3% | 8.3% | 10.0% | 4.1% | 16.6% | geçti |
| b2b | $150 | 7.1% | 9.2% | 11.1% | 4.6% | 18.4% | geçti |
| b2b | $165 | 7.8% | 10.1% | 12.2% | 5.1% | 20.3% | geçti (auto) |
| b2c | $250 | 4.7% | 6.3% | 7.5% | 3.1% | 12.6% | auto ve lean altında |
| b2c | $300 | 5.7% | 7.5% | 9.0% | 3.8% | 15.1% | auto ve lean altında |
| b2c | $350 | 6.6% | 8.8% | 10.5% | 4.4% | 17.6% | geçti |
| b2c | $400 | 7.6% | 10.0% | 12.0% | 5.0% | 20.1% | geçti |

### Bootstrap runway ve ilk 40 hafta öneri taraması: İş hanı kirası x maaş bandı çarpanı

K9 `fix_worst` botunun kendi ilk işe alım haftasında (hf 15, çek sonrası) runway = kasa ÷ (kira + maaş + sunucu); ilk 40 haftada en derin kümülatif açık (etkisiz gelir; ekonomi tahmini). Hedef runway >= 6,7 ay; açık 25-45K ve hf > 30. Hücre: tohum 7 / tohum 11.

| İş hanı kirası | maaş x | runway (ay) | en derin açık, 40 hf | haftası | 52. hf kümülatif | Sonuç (runway / açık) |
|---|---|---|---|---|---|---|
| $1500 | x1.00 | 8.2 / 8.3 | 7K / 9K | 36 / 32 | 36K / 62K | geçti / kaldı |
| $1500 | x1.25 | 7.1 / 7.2 | 22K / 22K | 40 / 32 | 5K / 24K | geçti / kaldı |
| $1500 | x1.50 | 6.2 / 6.3 | 38K / 38K | 40 / 36 | -26K / -14K | kaldı / geçti |
| $2000 | x1.00 | 7.3 / 7.4 | 9K / 11K | 36 / 32 | 34K / 61K | geçti / kaldı |
| $2000 | x1.25 | 6.4 / 6.5 | 25K / 24K | 40 / 32 | 2K / 23K | kaldı / kaldı |
| $2000 | x1.50 | 5.7 / 5.8 | 41K / 40K | 40 / 36 | -29K / -15K | kaldı / geçti |
| $3000 | x1.00 | 6.0 / 6.1 | 14K / 15K | 36 / 32 | 28K / 57K | kaldı / kaldı |
| $3000 | x1.25 | 5.4 / 5.5 | 30K / 27K | 40 / 32 | -3K / 19K | kaldı / geçti |
| $3000 | x1.50 | 4.9 / 5.0 | 46K / 43K | 40 / 36 | -34K / -19K | kaldı / kaldı |
| $4000 | x1.00 | 5.1 / 5.2 | 19K / 18K | 36 / 32 | 23K / 54K | kaldı / kaldı |
| $4000 | x1.25 | 4.6 / 4.7 | 35K / 31K | 40 / 32 | -8K / 16K | kaldı / geçti |
| $4000 | x1.50 | 4.2 / 4.3 | 51K / 47K | 40 / 36 | -39K / -22K | kaldı / kaldı |

B2C `fix_worst` (en derin açık bugünkü kaydın en çok %50 fazlası; 101. hf net >= %80):

| İş hanı kirası | maaş x | en derin açık (bugün) | yeni | oran | 101. hf net oranı |
|---|---|---|---|---|---|
| $2000 | x1.0 | -11K / -26K | -1K / -15K | x0.11 / x0.59 | x1.16 / x1.15 |
| $2000 | x1.5 | -11K / -26K | -14K / -30K | x1.24 / x1.13 | x1.14 / x1.13 |
| $4000 | x1.0 | -11K / -26K | -13K / -27K | x1.12 / x1.04 | x1.15 / x1.14 |
| $4000 | x1.5 | -11K / -26K | -26K / -41K | x2.25 / x1.58 | x1.13 / x1.12 |
