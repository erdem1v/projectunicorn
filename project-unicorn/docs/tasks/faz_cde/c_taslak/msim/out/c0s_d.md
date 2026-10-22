### M12 Sunucu faturasının gelire payı (Standart, 26-104. hafta)

Hedef: Standart'ta %8-12; Ekonomik yaklaşık yarısı, Kurumsal yaklaşık iki katı. Fiyat B2B 50 koltuk başına $120 (yeni), B2C 1.000 kullanıcı başına $250. Kapasite politikası artık oyuncunun: `recorded` = K9 botunun eski otomatik büyümesi (bugünkü kod), `lean` = elle, pay %5; `wide` = elle, pay %40; `auto` = anahtar açık (yük %80'e varınca yük %65'e inecek kadar büyür, küçültmez). Hizmet edilen koltuk = MRR ÷ $50 (koltuk fiyatı bandının ortası; varsayım).

| Pazar | Kayıt | recorded | lean | wide | auto | auto Ekonomik | auto Kurumsal |
|---|---|---|---|---|---|---|---|
| b2b | fix_none_7 | 6.9% | 5.7% | 9.0% | 7.5% | 3.7% | 14.9% |
| b2b | fix_none_11 | 7.0% | 5.6% | 8.9% | 7.4% | 3.7% | 14.9% |
| b2b | fix_worst_7 | 9.0% | 5.7% | 8.9% | 7.4% | 3.7% | 14.8% |
| b2b | fix_worst_11 | 9.1% | 5.6% | 8.8% | 7.3% | 3.7% | 14.7% |
| b2b | fix_due_7 | 8.9% | 5.7% | 8.9% | 7.4% | 3.7% | 14.8% |
| b2b | fix_due_11 | 9.0% | 5.6% | 8.9% | 7.4% | 3.7% | 14.7% |
| b2b | fix_off_7 | 9.0% | 5.7% | 8.9% | 7.4% | 3.7% | 14.8% |
| b2b | fix_off_11 | 9.1% | 5.6% | 8.8% | 7.3% | 3.7% | 14.7% |
| b2c | b2c_fix_worst_7 | 6.6% | 4.8% | 7.6% | 6.4% | 3.2% | 12.7% |
| b2c | b2c_fix_worst_11 | 6.3% | 4.7% | 7.4% | 6.2% | 3.1% | 12.4% |
| b2c | b2c_fix_none_7 | 6.9% | 4.1% | 6.4% | 5.8% | 2.9% | 11.5% |
| b2c | b2c_fix_none_11 | 7.3% | 4.1% | 6.4% | 6.0% | 3.0% | 12.0% |

### M11 Gider ve runway, B2B (K9 `fix_worst` ve diğer kollar, tahmin)

"Bugün" = K9 kaydı olduğu gibi (910ad1f koduyla, araç ve servis var, kurucu araç tabanı $1.500). "Yeni" = C'nin giderleriyle muhasebe, sunucu `auto` politikasıyla (anahtar açık), kira botun taşınmasıyla. Gelir yeni satırda iki hâlli: etkisiz (K9 geliri) ve etkili (C kapısı, yenileme sonuçları, kayıplar: ΔMRR). Net: gelir - gider; dış fonlama (Frank'in çeki, seed) hariç.

| Koşu | Varyant | en derin kümülatif açık (hf) | 52. hf kümülatif | 101. hf kümülatif | evre 3 aylık net | evre 2 en düşük runway (ay) | en düşük nakit |
|---|---|---|---|---|---|---|---|
| fix_none_7 | bugün (K9 kaydı) | -37K (40) | -20K | 226K | 12K | 4.3 | 6K |
| fix_none_7 | yeni, etkisiz gelir | -44K (40) | -28K | 389K | 37K | 4.0 | 9K |
| fix_none_7 | yeni, etkili gelir | -733K (104) | -158K | -633K | -78K | -8.1 | -596K |
| fix_none_7 | yeni, recorded sunucu | -43K (40) | -27K | 390K | 41K | 4.2 | 9K |
| fix_none_11 | bugün (K9 kaydı) | -41K (36) | -26K | 216K | 6K | 3.1 | 7K |
| fix_none_11 | yeni, etkisiz gelir | -49K (40) | -32K | 404K | 34K | 2.9 | 10K |
| fix_none_11 | yeni, etkili gelir | -816K (104) | -166K | -714K | -83K | -7.0 | -643K |
| fix_none_11 | yeni, recorded sunucu | -50K (40) | -34K | 404K | 34K | 3.0 | 10K |
| fix_worst_7 | bugün (K9 kaydı) | -43K (40) | -32K | 189K | 8K | 7.4 | 6K |
| fix_worst_7 | yeni, etkisiz gelir | -52K (45) | -39K | 377K | 35K | 5.9 | 9K |
| fix_worst_7 | yeni, etkili gelir | -118K (54) | -115K | 177K | 27K | 1.6 | 5K |
| fix_worst_7 | yeni, recorded sunucu | -53K (45) | -42K | 349K | 34K | 5.9 | 9K |
| fix_worst_11 | bugün (K9 kaydı) | -40K (32) | -20K | 210K | 13K | 3.1 | 7K |
| fix_worst_11 | yeni, etkisiz gelir | -47K (36) | -22K | 362K | 30K | 2.9 | 10K |
| fix_worst_11 | yeni, etkili gelir | -120K (52) | -120K | 117K | 19K | 0.7 | 10K |
| fix_worst_11 | yeni, recorded sunucu | -47K (36) | -27K | 333K | 31K | 3.0 | 10K |
| fix_due_7 | bugün (K9 kaydı) | -39K (40) | -27K | 146K | - | 2.5 | 6K |
| fix_due_7 | yeni, etkisiz gelir | -45K (45) | -38K | 228K | - | 1.9 | 9K |
| fix_due_7 | yeni, etkili gelir | -95K (62) | -93K | 84K | - | 0.1 | 0K |
| fix_due_7 | yeni, recorded sunucu | -45K (45) | -39K | 206K | - | 2.0 | 9K |
| fix_due_11 | bugün (K9 kaydı) | -35K (32) | -14K | 230K | 19K | 2.9 | 7K |
| fix_due_11 | yeni, etkisiz gelir | -41K (36) | -17K | 374K | 31K | 2.8 | 10K |
| fix_due_11 | yeni, etkili gelir | -104K (52) | -104K | 168K | 23K | 0.8 | 10K |
| fix_due_11 | yeni, recorded sunucu | -42K (40) | -22K | 346K | 34K | 2.9 | 10K |
| fix_off_7 | bugün (K9 kaydı) | -44K (40) | -32K | 189K | 7K | 7.4 | 6K |
| fix_off_7 | yeni, etkisiz gelir | -52K (45) | -39K | 377K | 35K | 5.9 | 9K |
| fix_off_7 | yeni, etkili gelir | -104K (54) | -102K | 208K | 29K | 1.6 | 5K |
| fix_off_7 | yeni, recorded sunucu | -53K (45) | -42K | 349K | 34K | 5.9 | 9K |
| fix_off_11 | bugün (K9 kaydı) | -40K (32) | -20K | 211K | 13K | 3.1 | 7K |
| fix_off_11 | yeni, etkisiz gelir | -47K (36) | -22K | 364K | 30K | 2.9 | 10K |
| fix_off_11 | yeni, etkili gelir | -69K (40) | -61K | 268K | 28K | 1.4 | 10K |
| fix_off_11 | yeni, recorded sunucu | -47K (36) | -27K | 335K | 31K | 3.0 | 10K |

Kapı okuması (B2B `fix_worst`, tohum 7 / 11; "yeni, etkili gelir" ve "yeni, etkisiz gelir" ayrı):

| Kapı | hedef | tohum 7 etkisiz | tohum 11 etkisiz | tohum 7 etkili | tohum 11 etkili | Sonuç |
|---|---|---|---|---|---|---|
| ilk 40 haftada en derin kümülatif açık, hf > 30 | 25-45K | 51K (hf 40) | 47K (hf 36) | 91K (hf 40) | 107K (hf 40) | kaldı |
| 52. hafta kümülatif net | <= 80K | -39K | -22K | -115K | -120K | geçti |
| evre 3 aylık net (yeni / bugün) | <= 2 x bugün | 35K / 8K (x4.64) | 30K / 13K (x2.28) | 27K / 8K (x3.62) | 19K / 13K (x1.47) | kaldı |
| evre 2'de en düşük runway < 4 ay en az bir kez | < 4 ay | 5.9 ay | 2.9 ay | 1.6 ay | 0.7 ay | geçti |

### Bootstrap runway: ilk çalışanın başladığı hafta

Kasa ÷ aylık gider (kira $4.000 + ilk çalışanın maaşı x1,5 + sunucu; gelir hariç), hedef >= 6,7 ay. Kasa = K9 kasası + yeni giderlerin farkı (Frank'in çeki dahil). K9 botunun kendi ilk işe alımı:

| Koşu | işe alım haftası | maaş (eski bant) | kasa | aylık gider (yeni) | runway (ay) | bugünkü aylık gider (K9, hesapta) |
|---|---|---|---|---|---|---|
| fix_none_7 | 15 | 2450 | 33916 | 8035 | 4.2 | 3480 |
| fix_worst_7 | 15 | 2450 | 33916 | 8035 | 4.2 | 3480 |
| fix_worst_11 | 15 | 2450 | 35228 | 8155 | 4.3 | 4140 |
| b2c_fix_worst_7 | 21 | 2800 | 35263 | 8450 | 4.2 | 2010 |
| b2c_fix_worst_11 | 21 | 2800 | 35482 | 8450 | 4.2 | 1980 |

### İş hanı'nın Frank şartı iki hâliyle ve cash_spend / cash_hoard

V1 = şart kalır (Frank'in çeki alınmış ve kasa >= $6.500); V2 = yalnız kasada $6.500 yeter. İlk işe alım kuralı: kasa >= k x aylık gider (kira + maaş x1,5 + sunucu), k = 1 (`allin`: eldeki kasayla bir aylık gider), 2 (`cash_spend`), 6 (botun bugünkü kuralı, `bot`), 6,7 (`cash_hoard`, runway kapısının kendisi). Hücre: işe alım haftası / o haftanın runway'i (ay). Kasa, ilk işe alımdan sonraki K9 gelir akışının işe alım olmadan sürdüğü varsayımıyla (iyimser: ekibin getirisi sayılmaz). Series A Avı = MRR >= $120.000 (`SalesSystem.TRACTION_MRR_TARGET`); K9 kaydında varış haftası ve kaydırma tahmini: tüm sonraki akış işe alımın gecikmesi kadar kayar (f = 1) ya da yarısı kadar (f = 0,5).

| Koşu | Frank şartı | allin (k=1) | spend | bot | hoard | spend → hoard fark (hf) | Series A Avı K9 | Series A farkı f=1 / f=0,5 |
|---|---|---|---|---|---|---|---|---|
| fix_none_7 | V1 | 14 / 4.5 | 14 / 4.5 | 25 / 6.4 | 28 / 7.2 | 14 | 89 | 14 / 7.0 |
| fix_none_7 | V2 | 2 / 1.3 | 14 / 4.5 | 25 / 6.4 | 28 / 7.2 | 14 | 89 | 14 / 7.0 |
| fix_none_11 | V1 | 13 / 4.5 | 13 / 4.5 | 23 / 20.2 | 23 / 20.2 | 10 | 87 | 10 / 5.0 |
| fix_none_11 | V2 | 2 / 1.3 | 13 / 4.5 | 23 / 20.2 | 23 / 20.2 | 10 | 87 | 10 / 5.0 |
| fix_worst_7 | V1 | 14 / 4.5 | 14 / 4.5 | 25 / 6.2 | 28 / 7.4 | 14 | 86 | 14 / 7.0 |
| fix_worst_7 | V2 | 2 / 1.3 | 14 / 4.5 | 25 / 6.2 | 28 / 7.4 | 14 | 86 | 14 / 7.0 |
| fix_worst_11 | V1 | 13 / 4.5 | 13 / 4.5 | 23 / 20.2 | 23 / 20.2 | 10 | 95 | 10 / 5.0 |
| fix_worst_11 | V2 | 2 / 1.3 | 13 / 4.5 | 23 / 20.2 | 23 / 20.2 | 10 | 95 | 10 / 5.0 |
| b2c_fix_worst_7 | V1 | 21 / 4.4 | 22 / 4.5 | 37 / 6.5 | 39 / 7.1 | 17 | 64 | 17 / 8.5 |
| b2c_fix_worst_7 | V2 | 2 / 1.2 | 22 / 4.5 | 37 / 6.5 | 39 / 7.1 | 17 | 64 | 17 / 8.5 |
| b2c_fix_worst_11 | V1 | 21 / 4.5 | 22 / 4.5 | 36 / 6.4 | 39 / 7.3 | 17 | 63 | 17 / 8.5 |
| b2c_fix_worst_11 | V2 | 2 / 1.2 | 22 / 4.5 | 36 / 6.4 | 39 / 7.3 | 17 | 63 | 17 / 8.5 |

### Plaza'nın şartları (10 kişi sen dahil, nakit $45.000, marka 40)

İş hanı dolu = K9'daki çalışan sayısı + kurucu >= 10 (9. çalışan). Plaza koşulları: nakit (yeni giderlerle) >= $45.000 ve marka >= 40. Bot tavan yüzünden 10. çalışanı Plaza'ya taşınana kadar bekletir. Bekleme = İş hanı dolduktan sonra şartların tuttuğu ilk hafta - dolduğu hafta.

| Koşu | 9. çalışan (İş hanı dolu) | marka o hafta | kasa o hafta (yeni) | Plaza şartları tuttu | bekleme (hf) | engelleyen şart |
|---|---|---|---|---|---|---|
| fix_none_7 | 38 | 53 | 102029 | 38 | 0 | - |
| fix_none_11 | 30 | 53 | 127972 | 30 | 0 | - |
| fix_worst_7 | 37 | 58 | 93865 | 37 | 0 | - |
| fix_worst_11 | 30 | 53 | 128505 | 30 | 0 | - |
| fix_due_7 | 38 | 58 | 99009 | 38 | 0 | - |
| fix_due_11 | 30 | 55 | 132749 | 30 | 0 | - |
| fix_off_7 | 37 | 58 | 93865 | 37 | 0 | - |
| fix_off_11 | 30 | 53 | 128505 | 30 | 0 | - |
| fix_worst_desk_7 | 35 | 58 | 97930 | 35 | 0 | - |
| fix_worst_desk_11 | 28 | 53 | 137641 | 28 | 0 | - |
| quality_core_7 | 58 | 0 | 75911 | tutmadı | - | marka |

### M11 B2C (`fix_worst`)

Hedef (PRD Risk 2, öneri): en derin açık bugünkünden en çok %50 derin; 101. hafta net bugünün %80'inden az değil; 20 koşuda iflas sayısı ve nedeni (bu muhasebe iflası ölçmez: kasanın en düşüğü yazılır).

| Koşu | Varyant | en derin kümülatif açık (hf) | 52. hf | 101. hf | en düşük nakit |
|---|---|---|---|---|---|
| b2c_fix_worst_7 | bugün (K9 kaydı) | -11K (45) | 10K | 3251K | 6K |
| b2c_fix_worst_7 | yeni, auto | -26K (45) | -11K | 3660K | 9K |
| b2c_fix_worst_7 | yeni, lean | -25K (45) | -10K | 3721K | 9K |
| b2c_fix_worst_7 | yeni, wide | -27K (45) | -12K | 3618K | 9K |
| b2c_fix_worst_11 | bugün (K9 kaydı) | -26K (45) | -0K | 3424K | 6K |
| b2c_fix_worst_11 | yeni, auto | -41K (45) | -21K | 3821K | 10K |
| b2c_fix_worst_11 | yeni, lean | -41K (45) | -20K | 3884K | 10K |
| b2c_fix_worst_11 | yeni, wide | -42K (45) | -23K | 3777K | 10K |
