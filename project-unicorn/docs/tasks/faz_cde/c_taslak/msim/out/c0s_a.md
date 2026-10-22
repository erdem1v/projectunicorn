### M1 Nedensiz düşüş

| Kapsam | hesap-haftası | düşüş haftası (hepsi adlı) | nedensiz | Sonuç |
|---|---|---|---|---|
| 12 koşu (8 düzeltme kolu + masalı fix_worst + quality_core, tohum 7 ve 11) | 118449 | 28955 | 0 | geçti |

### M2 İlk 12 hafta (ürün ve hata sabit, olay yok)

`fix_worst` dünyasının her haftası (7-100) donduruldu, 3 yıldız x 13 sektör, iki tohum. 3★ satırında Kurumsal madde (-10, Karar 4) açıktır ve kapı toplamı okur.

| Yıldız | aday | kapı reddi | imzalayan | imza değerinin altına inen | imzada en küçük (memnuniyet - eşik) | Sonuç |
|---|---|---|---|---|---|---|
| 1★ | 2444 | 0 (0.0%) | 2444 | 0 | 32 | geçti |
| 2★ | 2444 | 362 (14.8%) | 2082 | 0 | 10 | geçti |
| 3★ | 2444 | 1452 (59.4%) | 992 | 0 | 10 | geçti |
| hepsi | 7332 | 1814 (24.7%) | 5518 | 0 | 10 | geçti |

### M3, M4, M5 Kayıp (A'nın tanımı: erken = v1.0'dan sonra 20 hafta, geç = sonrası)

Hata terimi tavanı 60 (hükmün sayısı), 62 ve 64. Her hücre: tohum 7 / tohum 11, kayıp % (adet). Kapı reddi: imza kapısının geri çevirdiği aday (kayıp sayılmaz).

| Tavan | Kol | Erken kayıp | Geç kayıp | Toplam kayıp | İmza (kapı reddi) |
|---|---|---|---|---|---|
| 60 | hiç düzeltmeyen (none) | 0.0 (0) / 0.0 (0) | 14.3 (10) / 34.2 (27) | 14.3 (10) / 34.2 (27) | 70 (181) / 79 (186) |
| 60 | en kötüsünü düzelten (worst) | 0.0 (0) / 0.0 (0) | 0.0 (0) / 1.2 (3) | 0.0 (0) / 1.2 (3) | 239 (11) / 250 (12) |
| 60 | vadesi gelen düzelten (due) | 0.0 (0) / 0.0 (0) | 0.4 (1) / 0.7 (2) | 0.4 (1) / 0.7 (2) | 233 (9) / 275 (10) |
| 60 | hata bedeli kapalı (off) | 0.0 (0) / 0.0 (0) | 0.4 (1) / 1.2 (3) | 0.4 (1) / 1.2 (3) | 242 (8) / 257 (5) |
| 62 | hiç düzeltmeyen (none) | 0.0 (0) / 0.0 (0) | 31.4 (22) / 87.3 (69) | 31.4 (22) / 87.3 (69) | 70 (181) / 79 (186) |
| 62 | en kötüsünü düzelten (worst) | 0.0 (0) / 0.0 (0) | 0.0 (0) / 1.2 (3) | 0.0 (0) / 1.2 (3) | 239 (11) / 250 (12) |
| 62 | vadesi gelen düzelten (due) | 0.0 (0) / 0.0 (0) | 0.4 (1) / 0.7 (2) | 0.4 (1) / 0.7 (2) | 233 (9) / 275 (10) |
| 62 | hata bedeli kapalı (off) | 0.0 (0) / 0.0 (0) | 0.4 (1) / 1.2 (3) | 0.4 (1) / 1.2 (3) | 242 (8) / 257 (5) |
| 64 | hiç düzeltmeyen (none) | 0.0 (0) / 0.0 (0) | 37.1 (26) / 92.4 (73) | 37.1 (26) / 92.4 (73) | 70 (181) / 79 (186) |
| 64 | en kötüsünü düzelten (worst) | 0.0 (0) / 0.0 (0) | 0.0 (0) / 1.2 (3) | 0.0 (0) / 1.2 (3) | 239 (11) / 250 (12) |
| 64 | vadesi gelen düzelten (due) | 0.0 (0) / 0.0 (0) | 0.4 (1) / 0.7 (2) | 0.4 (1) / 0.7 (2) | 233 (9) / 275 (10) |
| 64 | hata bedeli kapalı (off) | 0.0 (0) / 0.0 (0) | 0.4 (1) / 1.2 (3) | 0.4 (1) / 1.2 (3) | 242 (8) / 257 (5) |

| Tavan | M3 `fix_due` geç <= off + 2 | M4 `fix_worst` geç <= off + 3 ve toplam <= off + 10 | M5 `fix_none` geç >= %10 ve >= 2 x off |
|---|---|---|---|
| 60 | geçti | geçti | geçti (none geç: 14.3 / 34.2) |
| 62 | geçti | geçti | geçti (none geç: 31.4 / 87.3) |
| 64 | geçti | geçti | geçti (none geç: 37.1 / 92.4) |

### M10 İmza kapısı (MVP sonrası 26 hafta, hf 7-33)

K9 (910ad1f) imzaları, C kapısından geçirildi: imza değeri = U - hata terimi >= eşik + 10. Dönen aday sonradan imzalayabilir: oran alt sınırdır. "Eski kod" = Q0b taban kolu (`q_calisma/q0b_logs`) aynı penceredeki imza sayısı; Erdem'in hedefi MVP sonrası imza düşüşü eski kodun %55-65'i (E1).

| Kol | K9 imza | kapıdan dönen | kapıdan geçen | C ile imza ÷ eski kod | K9 (kapısız) ÷ eski kod | Sonuç (%55-65) |
|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | 110 | 26 | 84 (76.4%) | 48.8% | 64.0% | altında |
| en kötüsünü düzelten (worst) | 108 | 20 | 88 (81.5%) | 51.2% | 62.8% | altında |
| vadesi gelen düzelten (due) | 103 | 17 | 86 (83.5%) | 49.7% | 59.5% | altında |
| hata bedeli kapalı (off) | 108 | 11 | 97 (89.8%) | 56.7% | 63.2% | geçti |

| Kol (bilgi) | K9 imza | kapıdan geçen | geçen pay |
|---|---|---|---|
| full_run_fix_worst_desk | 110 | 86 | 78.2% |
| full_run_quality_core | 96 | 60 | 62.5% |
| full_run_quality_core_desk | 90 | 55 | 61.1% |

Kapı reddinin dağılımı (`fix_worst`, iki tohum, bütün 104 hafta): yıldıza göre ve reddin nedeniyle (U mu, hata terimi mi).

| Yıldız | imza | kapıdan dönen | dönen pay | U < eşik + 10 (hata terimi 0 olsa da döner) | yalnız hata terimi yüzünden döner |
|---|---|---|---|---|---|
| 1★ | 363 | 0 | 0.0% | 0 | 0 |
| 2★ | 142 | 17 | 12.0% | 8 | 9 |
| 3★ | 7 | 6 | 85.7% | 4 | 2 |

### RAPOR_Q §1 madde 1 (❌1): 2★+3★ imzalarda U = 100 payı, `CORE_2` 1,25 ve 1,5

Hedef (Q kapısı): `fix_worst` 2★+3★ imzalarında U = 100 payı en çok %25; Traction (evre 2) 2★+3★ imza U ortancası 70-85. Her satır kendi bot kayıtlarından: 1,25 = `910ad1f` (k9_trim), 1,5 = `bd9a5ed` (k9_trim_15). U, oyunun `PROBE FIT u=` değeridir (imza anında); "C kapısıyla" = kapıdan geçen imzalar (U - hata terimi >= eşik + 10) üzerinde pay.

| CORE_2 | Kol | 2★+3★ imza | U = 100 | pay (kapısız, Q'nun ölçümü) | kapıdan geçen 2★+3★ | U = 100 / geçen (C kapısıyla) | Traction ortanca U (kapısız → C kapısıyla) |
|---|---|---|---|---|---|---|---|
| 1,25 | en kötüsünü düzelten (worst) | 149 | 60 | 40.3% | 126 | 47.6% | 86 → 93 |
| 1,25 | hiç düzeltmeyen (none) | 193 | 79 | 40.9% | 21 | 4.8% | 88 → 66 |
| 1,25 | vadesi gelen düzelten (due) | 96 | 25 | 26.0% | 77 | 32.5% | 74 → 79 |
| 1,5 | en kötüsünü düzelten (worst) | 107 | 0 | 0.0% | 81 | 0.0% | 70 → 83 |
| 1,5 | hiç düzeltmeyen (none) | 121 | 0 | 0.0% | 11 | 0.0% | 77 → 60 |
| 1,5 | vadesi gelen düzelten (due) | 118 | 0 | 0.0% | 94 | 0.0% | 70 → 81 |
