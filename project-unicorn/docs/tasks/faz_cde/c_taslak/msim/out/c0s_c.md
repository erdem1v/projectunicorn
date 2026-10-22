### M7 Kesinti kademesi ve yük basamakları

104 hafta x 2.000 koşu; iki olay arası >= 4 hafta, v1.0'dan sonra ilk 3 hafta yok (`sprint.json` incident: base 0,1, p_max 0,3, min_gap 4, launch_quiet 3). Sayı: koşu başına olay (yalnız hazard, tür seçimi dışında). Kademe: Ekonomik 1,0 / Standart 0,5 / Kurumsal 0,25 (B'nin çarpanı). Yük basamakları C1: <= %90 1,0; %90-100 1,5; > %100 2,5. Üç biçim: **(a)** PRD'nin yazdığı (yük `load_mult()` olarak kırpmanın içinde, `incident_system.gd:75-78` bugünkü kod yapısı); **(b)** yük kırpmadan sonra (C0v E1 soru 2); **(c)** (b) + yük yalnız kesinti türünün payına (E1 soru 1; B2B'de kesintinin tür payı s = 0.86).

**Biçim (a)**

| açık hata | yük | haftalık ihtimal (Eko) | Ekonomik | Standart | Kurumsal | Std / Eko | Kur / Std | her basamak >= %25 az |
|---|---|---|---|---|---|---|---|---|
| 2 | %70 (x1.0) | 0.125 | 8.71 | 4.95 | 2.70 | 0.57 | 0.55 | evet |
| 2 | %95 (x1.5) | 0.188 | 11.48 | 6.90 | 3.88 | 0.60 | 0.56 | evet |
| 2 | %105 (x2.5) | 0.300 | 15.19 | 9.92 | 5.92 | 0.65 | 0.60 | evet |
| 6 | %70 (x1.0) | 0.175 | 10.98 | 6.60 | 3.72 | 0.60 | 0.56 | evet |
| 6 | %95 (x1.5) | 0.263 | 14.07 | 9.03 | 5.23 | 0.64 | 0.58 | evet |
| 6 | %105 (x2.5) | 0.300 | 15.17 | 9.92 | 5.81 | 0.65 | 0.59 | evet |
| 12 | %70 (x1.0) | 0.250 | 13.65 | 8.68 | 4.99 | 0.64 | 0.57 | evet |
| 12 | %95 (x1.5) | 0.300 | 15.16 | 9.87 | 5.81 | 0.65 | 0.59 | evet |
| 12 | %105 (x2.5) | 0.300 | 15.08 | 9.89 | 5.86 | 0.66 | 0.59 | evet |

Hücre sonucu: basamak koşulu bozuk hücre 0 / 9. Yük %95 ÷ %70 (Ekonomik, az hata) = 1.32 (hedef >= 1,3: geçti). Kurumsal olay, tavanda hata, %70 yük: 4.99 (hedef >= 4: geçti).

**Biçim (b)**

| açık hata | yük | haftalık ihtimal (Eko) | Ekonomik | Standart | Kurumsal | Std / Eko | Kur / Std | her basamak >= %25 az |
|---|---|---|---|---|---|---|---|---|
| 2 | %70 (x1.0) | 0.125 | 8.66 | 4.99 | 2.69 | 0.58 | 0.54 | evet |
| 2 | %95 (x1.5) | 0.188 | 11.54 | 6.93 | 3.90 | 0.60 | 0.56 | evet |
| 2 | %105 (x2.5) | 0.312 | 15.51 | 10.23 | 6.04 | 0.66 | 0.59 | evet |
| 6 | %70 (x1.0) | 0.175 | 11.07 | 6.63 | 3.74 | 0.60 | 0.56 | evet |
| 6 | %95 (x1.5) | 0.263 | 14.10 | 8.97 | 5.19 | 0.64 | 0.58 | evet |
| 6 | %105 (x2.5) | 0.438 | 18.21 | 12.67 | 7.85 | 0.70 | 0.62 | evet |
| 12 | %70 (x1.0) | 0.250 | 13.74 | 8.68 | 5.00 | 0.63 | 0.58 | evet |
| 12 | %95 (x1.5) | 0.375 | 16.99 | 11.49 | 6.96 | 0.68 | 0.61 | evet |
| 12 | %105 (x2.5) | 0.625 | 20.93 | 15.45 | 10.22 | 0.74 | 0.66 | evet |

Hücre sonucu: basamak koşulu bozuk hücre 0 / 9. Yük %95 ÷ %70 (Ekonomik, az hata) = 1.33 (hedef >= 1,3: geçti). Kurumsal olay, tavanda hata, %70 yük: 5.00 (hedef >= 4: geçti).

**Biçim (c)**

| açık hata | yük | haftalık ihtimal (Eko) | Ekonomik | Standart | Kurumsal | Std / Eko | Kur / Std | her basamak >= %25 az |
|---|---|---|---|---|---|---|---|---|
| 2 | %70 (x1.0) | 0.125 | 8.70 | 5.08 | 2.73 | 0.58 | 0.54 | evet |
| 2 | %95 (x1.5) | 0.179 | 11.05 | 6.68 | 3.83 | 0.60 | 0.57 | evet |
| 2 | %105 (x2.5) | 0.287 | 14.78 | 9.63 | 5.50 | 0.65 | 0.57 | evet |
| 6 | %70 (x1.0) | 0.175 | 11.05 | 6.57 | 3.72 | 0.59 | 0.57 | evet |
| 6 | %95 (x1.5) | 0.250 | 13.67 | 8.64 | 5.09 | 0.63 | 0.59 | evet |
| 6 | %105 (x2.5) | 0.401 | 17.50 | 11.89 | 7.42 | 0.68 | 0.62 | evet |
| 12 | %70 (x1.0) | 0.250 | 13.69 | 8.72 | 4.96 | 0.64 | 0.57 | evet |
| 12 | %95 (x1.5) | 0.358 | 16.53 | 11.17 | 6.71 | 0.68 | 0.60 | evet |
| 12 | %105 (x2.5) | 0.573 | 20.27 | 14.76 | 9.55 | 0.73 | 0.65 | evet |

Hücre sonucu: basamak koşulu bozuk hücre 0 / 9. Yük %95 ÷ %70 (Ekonomik, az hata) = 1.27 (hedef >= 1,3: kaldı). Kurumsal olay, tavanda hata, %70 yük: 4.96 (hedef >= 4: geçti).

**Haftalık ihtimalin yük ile gerçek artışı** (ipucu metni "kesinti ihtimali 1,5 / 2,5 katına çıkar" der; hücre: ihtimal(yük) ÷ ihtimal(yük <= %90), Ekonomik):

| açık hata | biçim (a) %90-100 | biçim (a) > %100 | biçim (b) %90-100 | biçim (b) > %100 |
|---|---|---|---|---|
| 0 | x1.50 | x2.50 | x1.50 | x2.50 |
| 2 | x1.50 | x2.40 | x1.50 | x2.50 |
| 6 | x1.50 | x1.71 | x1.50 | x2.50 |
| 8 | x1.50 | x1.50 | x1.50 | x2.50 |
| 12 | x1.20 | x1.20 | x1.50 | x2.50 |

**Kırpma yük çarpanını ne zaman yutar (biçim a):** ham ihtimal 0,1 x L x (1 + hata/8) 0,30'u aşınca L etkisiz. L = 1,5 için açık hata > 8; L = 2,5 için açık hata > 1. Botun `fix_worst` kolunda açık hata (haftalık, iki tohum) ortancası ve payı:

| Kol | ortanca açık hata | hata > 1 olan hafta | hata > 8 olan hafta |
|---|---|---|---|
| hiç düzeltmeyen (none) | 150 | 91% | 91% |
| en kötüsünü düzelten (worst) | 7 | 91% | 41% |
| vadesi gelen düzelten (due) | 6 | 91% | 18% |
| hata bedeli kapalı (off) | 7 | 91% | 39% |

### Sunucu politikaları: kesinti ve fatura (server_lean / server_wide / server_auto)

K9 `fix_worst` dünyası (gerçek haftalık açık hata ve MRR ÷ $50 koltuk), kademe Standart (bulut, x0,5), v1.0 sonrası. Yük = hizmet edilen birim ÷ satın alınan birim. Kesinti sayısı: haftalık ihtimal biçim (a) (yük kırpmanın içinde) ve (b) (yük kırpmadan sonra) ile 2.000 koşuda beklenen acil durum sayısı (tür seçimi dışında). Fatura: Standart $120 / 50 koltuk, 26-104. hafta toplamı; net fark: lean'e göre.

| Tohum | Politika | ortalama yük | yük > %90 hafta | beklenen kesinti (a) | beklenen kesinti (b) | sunucu faturası 26-104. hf | lean'e göre fark |
|---|---|---|---|---|---|---|---|
| 7 | lean | %87 | 73 | 8.56 | 9.02 | $77756 | $+0 |
| 7 | auto | %68 | 0 | 7.06 | 7.12 | $101640 | $+23884 |
| 7 | wide | %56 | 0 | 7.06 | 7.12 | $122360 | $+44604 |
| 11 | lean | %89 | 84 | 8.79 | 9.30 | $76160 | $+0 |
| 11 | auto | %68 | 0 | 7.08 | 7.08 | $99624 | $+23464 |
| 11 | wide | %57 | 0 | 7.08 | 7.08 | $119980 | $+43820 |
