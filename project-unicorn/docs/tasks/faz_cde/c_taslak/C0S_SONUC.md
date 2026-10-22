# Faz C · C0s · Simülasyon ve ekonomi tahmini
2026-10-20 · Taban: Q'nun son commit'i `910ad1f` (K9c) · Görev: PRD §4.1, §4.3 Risk 1 ve 2, §5 · Yalnız `python -I`, Godot koşmadı, oyun dosyasına yazılmadı.
Betikler `c_taslak/msim/c0s_*.py`, ham çıktılar `c_taslak/msim/out/c0s_*.md` ve `.json`. Bu belge `c0s_build.py` ile `c0s_sonuc_template.md` + `out/` tablolarından kurulur.
Hepsi tek komutla: `cd c_taslak/msim && python -I c0s_run_all.py` (yaklaşık 25 sn, bayt-deterministik; iki koşu aynı md5).

## 0. E1 için özet (10 satır)
1. **Geçen:** M1, M2, M3, M4, M5 (hata tavanı 60 yeter), M6, M7 (a ve b biçimleri), M9, M13 (yenileyen %98,7). **Kalan:** M8'in bot ayağı, M10 (%51,2), M11 (ilk 40 hafta açığı 51K / 47K, Bootstrap runway 4,2 ay), M12 (Standart, oyuncu `auto`'da %7,4).
2. **Hata tavanı:** 60 M5'i zaten tutturuyor (`fix_none` geç kayıp %14,3 / %34,2). 62 ve 64 uçuruma götürüyor (%31 / %87 ve %37 / %92). Öneri: 60 kalsın.
3. **❌1 (CORE_2):** C'nin kapısı U = 100 payını düşürmez, yükseltir (2★+3★ `fix_worst`: %40,3 → %47,6). 1,5'te %0. Bu bot ürününde eşik kırılması 1,48'de: 1,25 ile 1,47 arası fark etmez. Öneri: Q'nun önerisi, 1,5. M5 1,5'te sınırda (%10,3 / %30,7), M10 iki değerde de aynı (~%50).
4. **❌2 (satışçı kaybı):** masalı `fix_worst`'te kapanışların yalnız %1,5'inde (2★+3★'ta %26'sında, n = 19) müşterinin baktığı bir alan eksik; zar yalnız orada atılır. Kapı eşiği ya da zar tabanı hedefi %5-15'e getirmez (taban 0 ile 0,60 arası aynı sonuç, kapı payı 10-20 aynı). Hedef bu bot için ulaşılamaz; 2★+3★ sütununda %5-10 için `CORE_2` 1,75-2,0 gerekir. `quality_core` masalı tarafında kayıp %84 (hedef >= %20 ✅).
5. **M10 (Erdem'in %55-65 hedefi):** K9 imzaları C kapısından geçince eski kodun %51,2'si (kapısız %62,8). En küçük öneri: imza payı 10 → 5 (%56,4); alternatifler: kapı hata terimini okumasın (%56,4), eşik v3 (%58,7). Oran alt sınırdır (dönen aday sonra imzalayabilir).
6. **Giderler (tahmin, bot kararları sabit; 6 ve 7 C9 kararına bağlı):** ilk çalışan K9 zamanında (hf 15, çek sonrası) runway **4,2 ay** (hedef 6,7). En derin açık ilk 40 haftada 51K / 47K (hedef 25-45K): bugünkü kayıt zaten 43K / 40K. 52. hf net -39K / -22K (≤ 80K ✅). Evre 3 net Q0b'nin x1,42 / x1,17'si (✅), K9'un kendi çok kısa evre 3'üne göre x4,6 / x2,3 (referans tartışmalı).
7. **Frank şartı:** iki hâl bot için aynı sonucu verir (işe alım hf 14 / 13, çek her koşuda önce gelir). Fark yalnız eldeki $10.000 ile hemen alım yapan oyuncuda: hf 2'de işe alım, runway 1,3 ay. Plaza şartları (10 kişi, $45.000, marka 40) İş hanı dolduğu hafta zaten tutuyor (bekleme 0 hf); yalnız `quality_core` kolunda marka 0 bağlıyor.
8. **cash_spend → cash_hoard:** ilk işe alım hf 14 → 28 (tohum 7) ve 13 → 23 (tohum 11); Series A Avı'na etkisi f = 1 ile 14 / 10 hafta, f = 0,5 ile 7 / 5 hafta (hedef >= 6; tohum 11 alt sınırda tutmuyor). Gerçek ölçüm E2'de.
9. **Yenileme sonuçları:** bakımlı üründe koltuk artışı kararların %37'si, mali azalış %4,7, başka ürüne geçiş %1,3, bütçe %2,0 (tamamı küçülme); tam kayıp %1,27 (M9 ✅). 13 sektörün eğilimi: 3 büyüyen, 7 istikrarlı, 3 durağan (§4; yalnız 5 sektör kaynaklı).
10. **Onay bekleyen sabitler için öneri:** sunucu fiyatı B2B Standart $135-150 (şimdiki $120'de `auto` %7,4; $150'de %9,2), B2C $350 (%8,8); imza payı 5; yük çarpanı kırpmadan sonra (M7 ihtimal x1,5 / x2,5 yazısı ancak böyle doğru); yaş sayacı "yalnız kademe" (M8 bot ayağı); koltuk artışı oranı (%37 baskın) E1'de gözden geçirilmeli. Kullanılan kod eşiği 33 / 42 / 51 (b2b_constants.gd:39-46); v3'ün 30 / 33 / 36'sı duyarlılıkta.

## 1. Kapı tablosu (PRD §4.1 ve §4.3)
Her satır: hedef | sonuç | geçti / kaldı | kanıt (betik › çıktı bölümü). Ayrıntı tabloları §3 ile §5 ve §8'de. **C9 kararına bağlı** satırlar işaretlidir: C9 askıda (Erdem evde 1-2 uzaktan çalışan istiyor; karar `docs/strateji/ANA_RESIM.md` üzerinden gelecek). Bu sonuçlar "ilk çalışan İş hanı'na taşınmayı gerektirir, masa = işe alım tavanı" kuralıyla ölçüldü; ev kuralı değişirse kira, ilk işe alım haftası, runway, Frank şartı ve Plaza sonuçları yeniden ölçülür.

| Kapı | Hedef | Sonuç | Durum | Kanıt |
|---|---|---|---|---|
| M1 Nedensiz düşüş | 0 | 118.449 hesap-haftasında 28.955 düşüş haftası, hepsi adlı, nedensiz 0 (**yapı gereği**: model kayma taşımıyor; gerçek ölçüm oyunda `PROBE UFLUX`, Q'da 0) | geçti | `c0s_m1.py` › M1 |
| M2 İlk 12 hafta | imza değerinin altına inmez; imza >= eşik + 10 | 7.332 aday, kapı reddi 1.814 (%24,7: 1★ 0, 2★ %14,8, 3★ %59,4), imzalayanda altına inen 0, en küçük pay 10 (1★ 32) | geçti | `c0s_m1.py` › M2 |
| M3 `fix_due` | geç kayıp <= off + 2 | %0,4 / %0,7 (off %0,4 / %1,2) | geçti | `c0s_m1.py` › M3, M4, M5 |
| M4 `fix_worst` | geç <= off + 3, toplam <= off + 10 | geç %0,0 / %1,2; toplam aynı | geçti | aynı |
| M5 `fix_none` (tavan 60) | geç >= %10 ve >= 2 x off | %14,3 / %34,2 (off %0,4 / %1,2) | geçti | aynı |
| M5 tavan 62 | aynı | %31,4 / %87,3 | geçti (uçurum) | aynı |
| M5 tavan 64 | aynı | %37,1 / %92,4 | geçti (uçurum) | aynı |
| M6 Söz | tutulmayan: uzaklık 8'de Risk, 20'de yok; iz 13 hf; temsilcide >= %20 kısa; tutulan +6 kalıcı | uzaklık 8 Risk ve ayrılma (hf 32), 20 Risk yok; iz 13 hf, temsilcide 10 hf (%23 kısa); tutulan +6 kalıcı | geçti | `c0s_m2.py` › M6 |
| M7 Kesinti kademesi | her basamakta >= %25 az; yük %95 >= 1,3 x %70; Kurumsal >= 4 (tavan hatada) | biçim (a): 9/9, x1,32, 4,99; biçim (b): 9/9, x1,33, 5,00; biçim (c): 9/9, **x1,27 (kaldı)**, 4,96 | geçti (a, b); (c) kaldı | `c0s_load.py` › M7 |
| M7 C0v bulgusu | p_max yük çarpanını yutuyor mu | **evet**: biçim (a)'da 12 hatada x1,5 -> x1,20; x2,5 -> x1,20; 6 hatada x2,5 -> x1,71. `fix_worst` haftalarının %91'inde açık hata > 1, %41'inde > 8 | bulgu | `c0s_load.py` › "Haftalık ihtimalin yük ile gerçek artışı" |
| M8 Güncellenmeyen ürün (Karar 7) | 26: 0; 52: -6; tavan -12; 52 hf kayıp 0 | yaş 0 / 6 / 12 (30. hf donması, 1★ ve 2★, 60. hf 3★); 20. hf donması 2 / 8 / 12; 52 hf kayıp 0 | geçti | `c0s_m2.py` › M8 |
| M8 yenileme tutumu | donmuş ürünün tutumu >= 2 basamak iner | **hiçbir senaryoda**: en çok 1 basamak (Zamma açık → Aynı fiyat). Q'da beklenti evreye bağlı değil, yükselmiyor; kapının koşulu (beklenti yükseldi) oluşmuyor | kapı anlamsız | aynı |
| M8 bot ayağı (PRD Risk 1) | `quality_core`: yaş <= -3 payı >= %50; dengeli kol < %10 | Karar 7'nin her kart sayması ile 0% / 0%; **yalnız kademe** sayılırsa `quality_core` %56,2, `fix_worst` %0,0 | kaldı (öneri: yalnız kademe) | `c0s_m2.py` › M8 (bot tablosu) |
| M9 Ürün dışı kayıp | tam kayıp <= %2,5 / yıl; olayların >= %50'si küçülme | bakımlı havuz %1,27; bütçe olayı 14, hepsi küçülme; 330 hesap: 4,5 tam kayıp / yıl (%1,38) | geçti | `c0s_m2.py` › M9 |
| M10 İmza kapısı (Erdem %55-65) | imza ÷ eski kod %55-65 | `fix_worst` %51,2; none %48,8; due %49,7; off %56,7 | **kaldı** | `c0s_m1.py` › M10; `c0s_m2.py` › M10 duyarlılık |
| M11 Bootstrap runway | ilk çalışanın haftasında >= 6,7 ay | 4,2 / 4,3 ay (B2B), 4,2 (B2C, hf 21) | **kaldı** (C9 kararına bağlı) | `c0s_econ.py` › Bootstrap runway |
| M11 en derin açık | ilk 40 hf'de 25-45K, hf > 30 | 51K (hf 40) / 47K (hf 36) etkisiz gelir; etkili gelirde 91K / 107K | **kaldı** (2-6K üstünde) (C9 kararına bağlı) | `c0s_econ.py` › M11 B2B |
| M11 52. hf | kümülatif net <= 80K | -39K / -22K (etkili -115K / -120K) | geçti (C9 kararına bağlı) | aynı |
| M11 evre 3 | aylık net <= 2 x bugün | Q0b'ye göre x1,42 / x1,17; K9'a göre x4,64 / x2,28; K9 tekrarlayan nete göre x2,01 / x1,77 | geçti (Q0b); kaldı (K9) (C9 kararına bağlı) | `c0s_econ2.py` › Evre 3 |
| M11 evre 2 runway | en az bir kez < 4 ay | tohum 7: 5,9 (kaldı), tohum 11: 2,9 (geçti) | karışık (C9 kararına bağlı) | `c0s_econ.py` › M11 B2B |
| M11 B2C | en derin açık bugünkünün <= x1,5'i; 101. hf net >= %80 | açık -26K / -41K (bugün -11K / -26K): x2,25 / x1,58; 101. hf net x1,13 | **kaldı** (açık), geçti (net) (C9 kararına bağlı) | `c0s_econ.py` › M11 B2C |
| M12 Fatura | Standart %8-12; Eko ~yarı; Kur ~iki kat | `recorded` (K9 otomatik büyüme) %9,0; `auto` %7,4; `lean` %5,6; `wide` %8,9. Eko %3,7 / Kur %14,8 (1 : 2 : 4) | `auto` ve `lean` **kaldı** | `c0s_econ.py` › M12 |
| M13 Yenileme | bakımlı yenileyen >= %90; koltuk artışı ve azalışı her 104 hf koşuda görülür | %98,7 (708 karar); artış 37-50, azalış 3-9 her koşuda | geçti | `c0s_m2.py` › M13 |
| Risk 1: kâğıtlı ay | yenileme kâğıdı ayda en çok 1 | bakımlı kollarda 24 ayın 0'ı (ilk yenileme dahil 2'si); `none`'da 20 ayın 19'u | geçti | `c0s_m2.py` › M13 (kâğıt) |
| Risk 2: cash_spend → hoard | Series A Avı'na varış farkı >= 6 hf | ilk işe alım farkı 14 / 10 hf (f = 1), 7 / 5 (f = 0,5) | geçti (f=1); tohum 11'de f=0,5'te kaldı (C9 kararına bağlı) | `c0s_econ.py` › Frank şartı |
| ❌1 U = 100 payı | <= %25 (2★+3★ `fix_worst`) | 1,25: %40,3 (kapılı %47,6); 1,5: %0 | 1,25 kaldı; 1,5 geçti | `c0s_m1.py` › RAPOR_Q §1 madde 1; `c0s_core2.py` |
| ❌2 satışçı kaybı | masalı `fix_worst` %5-15 | C kapısı + zar tabanı 0,60: bütün kapanışlarda %0,1, 2★+3★'ta %1,8 (n = 19); `quality_core` masalı 2★+3★ %84 | **kaldı** (§3.2) | `c0s_m2.py` › RAPOR_Q §1 madde 2 |

## 2. Girdi ve doğrulama
- **Kayıtlar:** Q'nun kapanış ölçümünün 30 bot koşusu (`910ad1f`, `CORE_2` 1,25) ve aynı ölçümün `bd9a5ed` hâli (1,5). Kaynak Q oturumunun scratchpad'idir (repo dışı); `c0s_trim.py` yalnız gereken PROBE satırlarını (STATE, AREAS, LINES, BUGS, SIGN, FIT, LEAD, MLOSS, REPLOSS, SPRINT, SHIP, PROMISE, CHURN, MONTH_BURN, FIRE, PLAY) `k9_trim/` ve `k9_trim_15/` altına kopyalar (6,6 MB ikisi de); betikler yalnız o kopyayı okur. Eski taban: `../../q_calisma/q0b_logs`. Eski betikler (`p1_bot.py` ... `build_report.py`) silinmedi, kullanılmadı.
- **Bot ürünü gerçek:** alan seviyeleri `PROBE AREAS`'tan, hat başına açık hata `PROBE LINES`'tan, canlı hat `PROBE SPRINT` kartlarından kuruldu. Eski betik kayıttan ürün serisini yeniden kuruyordu; burada oyunun kendi sayısı okunur.
- **U doğrulaması (`c0s_check.py`):** Python'un U'su `PROBE LEAD`'in 11.402 satırının 10.688'inde (%93,7), `PROBE FIT`'in 2.745 satırının 2.669'unda (%97,2) oyunun `u` ve `loss` değeriyle aynı. Sapan satırlar aynı haftada seviyenin sprint kapanışından önce ya da sonra okunduğu satırlar. Q'nun kapı sayıları birebir yeniden üretildi: U = 100 payı %40,3 (60/149) ve 1,5'te 0/107; satışçı kaybı masalı `fix_worst` 0/328 ve `quality_core` masalı 15/177 (2★+3★ 15/33); Q'nun "imzada U < eşik + 10" payı 3★'ta 4/7 (benim U'm 2★'ta 8/142, Q 12/142: fark adayın rakip penceresini okuması).
- **C modelinin sabitleri** (PLAN_C "E1'de onaya gelen sabitler"): söz zamanında +6 kalıcı, geç -3 (8 hf), tutulmadı -12 (13 hf); istek yayına girdi +4 (yalnız 3★); kesinti `0,6 x saat`, en çok 8, 13 hf; durum terimleri indirim +8, zam -2, gönülsüz -6, Kurumsal -10; hata terimi `min(3 H, 60)`; yaş 26 / 4 / -1 / -12; imza payı 10; zar tabanı %60; yenileme oranları Karar 8 (artış 25 / 20 / 15, azalış 5 / 4 / 3, geçiş 1,5 / 1 / 0,5, bütçe 2 / 1,5 / 1; sektör x1,25 / 1 / 0,75; eşik + 25 üstünde x1,5; koltuk %10-30 artar, %10-25 azalır).

## 3. Tutmayan kapılar: neden ve en küçük ölçülü öneri
Sabit değiştirilmedi; her öneri ayrı koşuda ölçüldü.

### 3.1 M10 (imza ÷ eski kod %51,2)
- **Neden:** MVP sonrası 26 haftada K9 imzalarının %18,5'i (`fix_worst`: 20 / 108) kapıdan dönüyor. 104 haftanın tamamında: 2★'ın %12'si (17 / 142; 8'i U yüzünden, 9'u hata terimi yüzünden) ve 3★'ın 6'sı 7'sinden; 1★ hiç dönmüyor. Kapısız oran %62,8'di.
- **En küçük öneri:** imza payı 10 → 5 (`SIGNING_SAT_OVER_TOL`): `fix_worst` %56,4; none %56,4; due %53,8; off %57,9. Pay 0: %58,7. Kapı hata terimini okumazsa %56,4. Eşik v3 (30 / 33 / 36) ile pay 10: %58,7. Kapı adayın U'sunu rakip penceresiyle okursa %48,8 (daha kötü).
- Not: ölçüm alt sınırdır; kapıdan dönen aday ürün iyileşince sonradan imzalayabilir (Q'nun geri dönüş kapısı).
#### M10 duyarlılık (imza ÷ eski kod, MVP sonrası 26 hafta)

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


### 3.2 ❌2 satışçı kapanış kaybı (hedef %5-15)
- **Neden:** zar yalnız müşterinin baktığı bir alan eksikken atılır (`product_quality.gd:233` `close_chance`, `loss_area` boşsa 1). Masalı `fix_worst`'te 328 kapanışın 5'inde (%1,5) alan eksik; 2★+3★'ta 19'un 5'inde. Zar eğrisi ya da C'nin zar tabanı bu paydan fazlasını kaybettiremez. C kapısı bu kolda hiçbir adayı geri çevirmiyor (0): ürün 2★ bandını doyuruyor.
- **Ölçülen oynaklar:** kapı payı 10 / 12 / 15 / 20 ve zar tabanı 0,60 / 0,45 / 0,30 / 0 her birleşimde `fix_worst` 2★+3★ %1,8 (bütün kapanışlar %0,1). `quality_core` masalı 2★+3★ %84-100 (hedef >= %20 ✅, hatta çok yüksek).
- **Tek işe yarayan düğme beklentidir:** `CORE_2` 1,75 → 2★+3★ kaybı %4,8, 2,0 → %10,4 (alan eksik 5 → 6 kapanış). Bütün kapanışlarda (n = 328) en iyi durumda bile %0,7. Yani %5-15 hedefi bütün kapanışlar sütununda bu bot için ulaşılamaz; 2★+3★ sütunu 19 kapanışa dayanır ve gürültülüdür.
- **Öneri:** hedefi kapı olarak değil gösterge olarak oku (zar bakımsız üründe çalışıyor: `quality_core` %84); C'nin kapısına ve zar tabanına dokunma.
#### RAPOR_Q §1 madde 2 (❌2): satışçı kapanış kaybı oranı

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

#### Zar için gereken beklenti (❌2'nin tavan sorusu)

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


### 3.3 M8 bot ayağı (yaş sayacı)
- **Neden:** Karar 7 "herhangi bir kart (kademe, cila, istek, düzeltme)" der. `quality_core` kolu düzeltme ve araştırma (cila) kartlarını tutar ve onlar vurgu alanlarına dokunur; sayaç hiç işlemez (yaş 0). Kolu "ihmal eden oyuncu" yapan şey kademe kartının yokluğudur.
- **En küçük öneri:** sayacı yalnız kademe (`feat`) kartı sıfırlasın: `quality_core` yaş <= -3 payı %56,2, `fix_worst` %0,0 (hedef >= %50 / < %10 ✅). Kademe + cila ile hâlâ 0%. Bu, Erdem'in 18 Ekim kararına ("herhangi bir kart") aykırıdır; E1'e açık soru.
- `req:` (istek) kartları hangi hatta düştüğü kayıtta olmadığı için dokunuş sayılmadı (sayacı geciktirme yönünde sapma).

### 3.4 M11 (giderler)
- **İlk çalışan runway'i 4,2 ay:** kasa $34K (çek dahil) ÷ aylık gider $8.0K (kira $4.000 + ilk çalışan $2.450 x 1,5 + sunucu). Çek alındığı hafta işe alan bot 6,7'ye varamaz; çekten sonra bekleyen (hoard) bot hf 28'de 7,4 ay ile varır. Kira x maaş taraması: runway kapısı yalnız (kira $1.500, maaş x1,0 ya da x1,25) ve (kira $2.000, maaş x1,0) hücrelerinde tutar, ama o hücrelerde 40 haftalık açık 7-22K'ya iner (25K'nın altı): iki kapı birlikte hiçbir hücrede tutmaz.
- **En derin açık (51K / 47K):** K9'un bugünkü kaydı 43K / 40K; yeni giderler +8K / +7K ekliyor. Kira $2.000 ve maaş x1,5: 41K / 40K (✅) ama runway 5,7. Kira $3.000 ve maaş x1,25: 30K / 27K (✅), runway 5,4.
- **Etkili gelir:** C kapısı (tohum 7'de 11 reddedilen aday, toplam $15,6K MRR), yenileme ve kayıplar K9 gelirinden 40-50. haftada yaklaşık $12-14K MRR götürüyor; açık 91K / 107K'ya iniyor. Bu sınır aşağıdadır (reddedilen aday sonradan imzalayabilir).
- **B2C:** mutlak açık küçük (-26K / -41K) ama bugünkü kayıt da küçük (-11K / -26K); "x1,5" göreli hedefi bu tabanda kırılgandır. Kira $2.000 ve maaş x1,5 ile oranlar x1,24 / x1,13 (✅). Mutlak bir hedef (örnek: B2B ile aynı 45K) daha anlamlı.
- **Evre 3 referansı:** K9 `fix_worst`'te evre 3 yalnız 17 ve 9 hafta, içinde $48.000 ve $30.000 tek seferlik gider var; "bugün" bu yüzden eksik temsil edilir. Q0b (eski kod, evre 3 39-40 hafta) ile oran x1,42 / x1,17.
#### Evre 3 aylık net: hangi "bugün"

Kapı: evre 3 aylık net <= 2 x bugün. Üç referans: Q0b (eski kod tabanı, `q0b_logs`), K9 (910ad1f, bugünkü kod) ve K9'un tekrarlayan neti (tek seferlik giderler hariç). K9 `fix_worst`'te evre 3 yalnız 6-16 haftadır ve içinde 48.000 ile 30.000 dolarlık tek seferlik gider (88-101. hf) vardır; bu yüzden K9'un evre 3 neti bugünkü ekonomiyi eksik temsil eder.

| Koşu | evre 3 hafta (K9) | Q0b evre 3 net | K9 evre 3 net | K9 tekrarlayan net | yeni (etkisiz) | yeni tekrarlayan | yeni ÷ Q0b | yeni ÷ K9 | yeni tekrarlayan ÷ K9 tekrarlayan |
|---|---|---|---|---|---|---|---|---|---|
| fix_worst_7 | 17 | 25K | 8K | 27K | 35K | 55K | x1.42 | x4.64 | x2.01 |
| fix_worst_11 | 9 | 26K | 13K | 22K | 30K | 38K | x1.17 | x2.28 | x1.77 |

#### Bootstrap runway ve ilk 40 hafta öneri taraması: İş hanı kirası x maaş bandı çarpanı

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


### 3.5 M12 (sunucu payı)
- **Neden:** eski kapasite büyümesi yükü ortalama %56-57'de tutuyordu (boş pay %43-44); oyuncu `auto`'da yükü %68, `lean`'de %87 tutar. Fatura payı politikaya göre %5,6 ile %8,9 arasında; tek fiyatla üçü birden %8-12'ye giremez.
- **En küçük öneri:** Standart B2B $135 (auto %8,3, wide %10,0, lean %6,3) ile $150 (%9,2 / %11,1 / %7,1); B2C $350 (auto %8,8, wide %10,5). 1 : 2 : 4 oranı korunur (Ekonomik yarısı, Kurumsal iki katı). `lean` hiçbir fiyatta %8'e gerek kalmadan makul: o oyuncu bilerek kesinti riskini alıyor (§3.6).
#### M12 öneri taraması: Standart birim fiyatı (kapasite politikası oyuncunun)

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


### 3.6 Sunucu politikaları (Risk 1: "server_auto her yerde en iyiyse elle yönetim boş tıktır")
- `lean` (pay %5): sunucu faturası 78 hafta için $24K ucuz, ama yük 73-84 hafta %90'ın üstünde: beklenen kesinti 8,56-8,79 (auto 7,06-7,08). Yani `lean` ile `auto` farklı sonuç alır (kesinti, net) ✅.
- `wide` (pay %40): `auto` ile kesinti aynı (7,06 / 7,08), fatura $20K pahalı: **`wide` `auto`'ya baskındır, boş pay para kaybıdır.** İki politika gerçekten farklı kalıyor: lean ile auto. Elle yönetim yalnız lean'i seçen oyuncu için karardır.
#### Sunucu politikaları: kesinti ve fatura (server_lean / server_wide / server_auto)

K9 `fix_worst` dünyası (gerçek haftalık açık hata ve MRR ÷ $50 koltuk), kademe Standart (bulut, x0,5), v1.0 sonrası. Yük = hizmet edilen birim ÷ satın alınan birim. Kesinti sayısı: haftalık ihtimal biçim (a) (yük kırpmanın içinde) ve (b) (yük kırpmadan sonra) ile 2.000 koşuda beklenen acil durum sayısı (tür seçimi dışında). Fatura: Standart $120 / 50 koltuk, 26-104. hafta toplamı; net fark: lean'e göre.

| Tohum | Politika | ortalama yük | yük > %90 hafta | beklenen kesinti (a) | beklenen kesinti (b) | sunucu faturası 26-104. hf | lean'e göre fark |
|---|---|---|---|---|---|---|---|
| 7 | lean | %87 | 73 | 8.56 | 9.02 | $77756 | $+0 |
| 7 | auto | %68 | 0 | 7.06 | 7.12 | $101640 | $+23884 |
| 7 | wide | %56 | 0 | 7.06 | 7.12 | $122360 | $+44604 |
| 11 | lean | %89 | 84 | 8.79 | 9.30 | $76160 | $+0 |
| 11 | auto | %68 | 0 | 7.08 | 7.08 | $99624 | $+23464 |
| 11 | wide | %57 | 0 | 7.08 | 7.08 | $119980 | $+43820 |


### 3.7 M7 (kapsam)
- Kademe çarpanı bugünkü kodda kırpmadan sonra (`incident_system.gd:75-78`); bu yüzden 9/9 geçiyor. Yük çarpanı `load_mult()`'a girerse kırpmanın içine düşer ve ipucundaki "kesinti ihtimali x1,5 / x2,5" yazısı 12 açık hatada x1,2'ye düşer. Öneri: yük çarpanı kırpmadan sonra (biçim b): her hücrede x1,5 / x2,5 tam; 9/9 ve yük oranı x1,33.
- Biçim (c) (E1 soru 1, yük yalnız kesinti türünün payına, s = %86): yük %95 / %70 oranı x1,27 (hedef 1,3'ün altı). Kesinti payı için kapıyı yükseltmek gerekir ya da (b) seçilir.
#### M7 Kesinti kademesi ve yük basamakları

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


## 4. Yenileme: sonuç dağılımı ve 13 sektörün eğilimi
- **Politika:** satışçı raporunun 1. seçeneği (tutumun en iyi fiyatı), ikna +2. Sonuç zarı sırası (bütçe, geçiş, mali azalış, koltuk artışı) benim varsayımım; PRD sırayı yazmıyor.
- **Okuma:** bakımlı üründe tutumun tamamı "Zamma açık" (Erdem: normal). Çeşitliliği koltuk sonuçları veriyor: kararların %37'sinde koltuk artışı, %4,7'sinde mali azalış. Artış/azalış oranı 8:1; sağlıklı büyüme tutumuyla uyumlu ama koltuk artışı %10-30 ile birlikte yenilenen hesabın MRR'ını yılda yaklaşık %14-15 büyütüyor (zam %8 + artış - azalış). E1'de oran onayı ayrıca istenmeli; ölçülmedi: etkisi MRR eğrisine.
- **Cevapsız kâğıt (aynı fiyat):** bakımlı kollarda fark yok; `none`'da yenileyen %98,2 → %75,2 (82 gönülsüz yenileme, 26 ayrılan).
#### Yenileme sonuç dağılımı (Karar 8 ve 9 oranlarıyla; tohum 7 ve 11 birleşik)

Her satır yenileme dönemi açılan hesap (imzadan 44 hafta sonra, <= 104. hafta). Tutum: Zamma açık / Aynı fiyat / İndirim ister / Ayrılmayı düşünüyor / Yenilemeyecek. Sonuç zarı: bütçe > başka ürüne geçiş > mali azalış > koltuk artışı (sıra varsayım). Politika: satışçı raporunun 1. seçeneği (tutumun en iyi fiyatı).

| Kol | karar | yenileyen | Zamma açık | Aynı | İndirim | Ayrılmayı düşünüyor | Yenilemeyecek | koltuk artışı | mali azalış | başka ürüne geçiş | bütçe: küçülme | bütçe: ayrılma |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hiç düzeltmeyen (none) | 113 | 111 (98.2%) | 0 (0%) | 3 | 82 | 27 | 1 | 0 | 0 | 1 | 0 | 0 |
| en kötüsünü düzelten (worst) | 234 | 232 (99.1%) | 234 (100%) | 0 | 0 | 0 | 0 | 92 | 10 | 2 | 6 | 0 |
| vadesi gelen düzelten (due) | 231 | 226 (97.8%) | 231 (100%) | 0 | 0 | 0 | 0 | 75 | 12 | 5 | 2 | 0 |
| hata bedeli kapalı (off) | 243 | 241 (99.2%) | 243 (100%) | 0 | 0 | 0 | 0 | 95 | 11 | 2 | 6 | 0 |

#### M13 Yenileme kapısı (bakımlı kol = worst + due + off)

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

#### M9 Ürün dışı kayıp

Hedef (öneri): bütçe kesintisi ve başka ürüne geçişle tam kayıp yılda hesapların <= %2,5'i; bütçe olaylarının >= %50'si küçülme. Birinci satır bot kollarından gözlenen karar havuzu (iki tohum); ikinci satır 330 hesaplık deftere ölçeklenmiş beklenen değer (yıldız karışımı ve "memnun" payı havuzdan, 1.000 deneme).

| Havuz | karar | bütçe olayı | küçülme payı | başka ürüne geçiş | tam kayıp (bütçe ayrılma + geçiş) | tam kayıp / yıl-hesap | 330 hesap: tam kayıp / yıl | küçülme / yıl | Sonuç |
|---|---|---|---|---|---|---|---|---|---|
| bakımlı (worst+due+off) | 708 | 14 | 100% | 9 | 9 | 1.27% | 4.54 (1.38%) | 6.24 | geçti |
| bakımsız (none) | 113 | 0 | - | 1 | 1 | 0.88% | 11.28 (3.42%) | 0.00 | geçti |


### 4.1 13 sektörün eğilim önerisi
Ölçüt: sektörün gerçek dünya büyüme hızı; >= %6 büyüyen, %3-6 istikrarlı, < %3 durağan. Koltuk artışı x1,25 / x1 / x0,75, mali azalış durağanda x1,5. **Yalnız 5 sektör kaynaklı;** gerisi [kanıtsız] (model bilgisi, E1'de Erdem'in zevk kararı).

| Sektör | Öneri | Gerekçe | Kaynak |
|---|---|---|---|
| Sağlık | büyüyen | Sağlık BT pazarı 2025-2030 yıllık %11,8-15,2 | https://tools.prnewswire.com/en-us/live/20813/release/20251215EN47317 |
| E-ticaret | büyüyen | 2025-2029 yıllık %6,2 (ResearchAndMarkets), %7,2 (Ken Research); tek uç değer %17,1 | https://www.businesswire.com/news/home/20260107672024/en |
| Teknoloji | büyüyen | [kanıtsız] | yok |
| İnşaat | istikrarlı | küresel inşaat çıktısı yılda %3,6-3,9 (Oxford Economics; tarih 2015-2021, eski) | https://www.pbctoday.co.uk/news/planning-construction-news/global-construction-expected-see-massive-growth-2030/21127/ |
| Tekstil | istikrarlı | yıllık %4,2-4,4 (Ken Research 2025, Grand View); eski %7 tahmini daha eski | https://www.kenresearch.com/global-textile-market |
| Lojistik, Finans, Hukuk, Perakende, Emlak | istikrarlı | [kanıtsız] | yok |
| Sigorta | durağan | küresel prim büyümesi yılda yaklaşık %2,6-3 (Swiss Re sigma 2024) | https://insurance-portal.ca/article/global-insurance-premiums-set-to-grow-three-per-cent-annually-in-2025-and-2026 |
| Üretim, Medya | durağan | [kanıtsız] | yok |

Arama tek tur yapıldı (3 WebSearch); pazar araştırma sayfaları satıcı basın bültenidir ve tahminler yayıncıya göre iki katı oynar (örnek e-ticaret %6,2 ile %17,1). Bu tablo yönü gösterir, ölçmez.

## 5. Ekonomi tablolarının geri kalanı (hepsi C9 kararına bağlı)
#### M12 Sunucu faturasının gelire payı (Standart, 26-104. hafta)

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

#### M11 Gider ve runway, B2B (K9 `fix_worst` ve diğer kollar, tahmin)

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

#### Bootstrap runway: ilk çalışanın başladığı hafta

Kasa ÷ aylık gider (kira $4.000 + ilk çalışanın maaşı x1,5 + sunucu; gelir hariç), hedef >= 6,7 ay. Kasa = K9 kasası + yeni giderlerin farkı (Frank'in çeki dahil). K9 botunun kendi ilk işe alımı:

| Koşu | işe alım haftası | maaş (eski bant) | kasa | aylık gider (yeni) | runway (ay) | bugünkü aylık gider (K9, hesapta) |
|---|---|---|---|---|---|---|
| fix_none_7 | 15 | 2450 | 33916 | 8035 | 4.2 | 3480 |
| fix_worst_7 | 15 | 2450 | 33916 | 8035 | 4.2 | 3480 |
| fix_worst_11 | 15 | 2450 | 35228 | 8155 | 4.3 | 4140 |
| b2c_fix_worst_7 | 21 | 2800 | 35263 | 8450 | 4.2 | 2010 |
| b2c_fix_worst_11 | 21 | 2800 | 35482 | 8450 | 4.2 | 1980 |

#### İş hanı'nın Frank şartı iki hâliyle ve cash_spend / cash_hoard

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

#### Plaza'nın şartları (10 kişi sen dahil, nakit $45.000, marka 40)

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

#### M11 B2C (`fix_worst`)

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

- **Plaza notu:** `quality_core` kolunda marka 0 (STATE `brand=0`, hf 40-70): marka şartı yalnız ürünü zayıf kolda bağlar. Diğer kollarda marka 53-58 ve nakit $94K-138K; yani Plaza'nın nakit ($45.000) ve marka (40) şartları bu bot için gevşek, tek bağlayıcı şart 10 kişi.
- **Frank şartı:** İş hanı'nın çek şartı kalsın ya da "kasada $6.500 yeter" olsun, bot (k = 2, 6, 6,7) aynı haftada işe alıyor: çek hf 12-13'te geliyor ve hiçbir kural çekten önce işe alım getirmiyor. Şartı kaldırmak yalnız kasasıyla hemen işe alan oyuncuya yol açıyor (`allin`, hf 2, runway 1,3 ay): gerçek bir risk kararı doğuruyor. Öneri: C9'daki ilk işe alım kapısı için E1'in cevabı "şart kalkar, kasada $6.500 yeter" ise bot politikalarına `allin` kolu eklenmeli.

## 6. Varsayımlar ve kodla ayrılan yerler
Python yaklaşımı kodun kopyası değildir. Hepsi `910ad1f`'ya göre.

| # | Varsayım ya da ayrılık | Kod |
|---|---|---|
| 1 | **Eşik** kodda 33 + 9 x (yıldız - 1) + sektör eki (inşaat ve sağlık 5, sigorta 3): 33 / 42 / 51. PRD "ayrılma eşiği formülü kalır" der ve C0_HARITA §7 bunu "korunur" okur; v3'ün 30 / 33 / 36'sı kodda yok. Birincil koşular kod eşiğiyle; v3 yalnız M10 duyarlılığında | `b2b_constants.gd:39-46` |
| 2 | **U** `ProductQuality` satır satır: ağırlıklar 0,50 / 0,25 / 0,15 / 0,10, oran tavanı 1,5, Çekirdek + 0,25 tavanı, `FIT_SCALE` 70, 2★ 1,25 / 1,0, 3★ 2,0 / 1,5 / 1,0, 1★ Çekirdek 3 ÷ 5 | `product_quality.gd:12-18`, `:37-48`, `:268-300`, `:341-357` |
| 3 | **Hesap U'su** rakipsiz (`market_ref_for`), aday U'su rakip penceresiyle; rakip artışı `PROBE AREAS`'ın üçüncü sayısı x 0,5, en çok 1,0. `top` kırpması (alanın hatlarının en yüksek kademesi) 3 alındı | `product_quality.gd:118`, `:206`, `:246`, `:359` |
| 4 | **Hata terimi:** alan başına açık hata ÷ canlı hat, Çekirdek + iki vurgu alanı, ağırlıklar yeniden ölçeklenir; canlı hat = en az K1 yayınlanmış hat (SPRINT kartlarından). Oyunda `account_bugs` ve Q'nun `uses_area`'sı farklı sayabilir | PRD Karar 5; `product_quality.gd:27` |
| 5 | **İmza kapısı** hesabın toplamını okur (U - hata + durum terimleri, defter boş, yaş 0); 3★'ta Kurumsal -10 dahil (Karar 4 + 5). Kurumsal -10 kapıda yok sayılırsa 3★ reddi %59,4'ten %44,7'ye düşer (M2 ızgarası) | PRD Karar 6; `sales_system.gd:371-373` (bugünkü taban) |
| 6 | **Kurumsal madde** yalnız 3★ ve sağlayıcı Kurumsal değilken; bot hiç Kurumsal'a geçmez; 8 hf sonra memnuniyet - eşik < 20 ise fesih bildirimi, 4 hf sonra ayrılma (ay başı ~4 hf) | PRD Karar 4 |
| 7 | **Söz olayları** gerçek kayıttan (`PROBE PROMISE resolved`), yalnız 3★ hesaplara (istek kartı yalnız 3★'tan geliyor, Karar 11). Kesinti olayı `PROBE FIRE incident_outage_b2b` günlerinde, saat 3-8 tekdüze (logda saat yok), bütün hesaplara aynı satır. `satisfaction_delta` kartları, iyi niyet kartları, genişleme, kurumsal geçiş modellenmedi | `run_probe.gd` PROBE satırları |
| 8 | **Sahip** kurucu (`cs_dampen` 1,0); M6'da temsilci 0,725 | `b2b_constants.gd` (CS yavaşlatma) |
| 9 | **Yenileme zarı:** tek zar, sıra bütçe > geçiş > mali azalış > artış (sıra PRD'de yok); memnun = memnuniyet >= eşik + 12; zayıf vurgu alanı sözcüğü yenileme anında seviye / beklentiden (Zayıf ve Yok x2, Güçlü x0,5); koltuk değişimi tekdüze aralıkta; ikna +2 | PRD Karar 8 ve 9 |
| 10 | **Ürün ve satış dışsal:** bot kararları (işe alım, sprint, satış, sunucu) kayıtta olduğu gibi. C'nin kapısı hesapları eksiltince botun gelir akışı, işe alımı ve ürün hızı değişir; bu yansımıyor. E2 gerçek koşu | `run_probe.gd:1410-1434` |
| 11 | **Koltuk** = MRR ÷ $50 (koltuk fiyat bandı $30-70, ortası); `PROBE STATE mrr` toplam | `sales_ledger.gd:141-144`, `sales_constants.gd:120-121` |
| 12 | **Sunucu:** Standart (bulut) fiyatı eski $45 / $55'in yerine yeni $120 / $250; `recorded` = K9 satırı x oran. `lean` ceil(hizmet ÷ 0,95), `wide` ÷ 0,60, `auto` yük >= 0,80 olunca ceil(hizmet ÷ 0,65), küçültme yok (C0r). Yük çarpanı ve ağır kademe yükü (`load_factor`) dikkate alınmadı | `infra_system.gd:26`, `:28`, `:30-31` |
| 13 | **Ofis / gider:** kurucu satırı, araç, servis çıkarıldı; maaş, ek mesai ve işe alım primi x1,5 (prim farkı işe alım haftasında); kira: ilk çalışanın geldiği haftada İş hanı $4.000, Plaza $8.000 (10 kişi sen dahil, nakit >= $45.000, marka >= 40), Loft'a varılmıyor. Taşınma 1 hf, arama 1 hf, ikisi aynı anda. Masa tavanının botun 10.-13. işe alımını geciktirmesi hesaba girmedi: bekleme zaten 0 hf | `office_constants.gd:9`, `:28-33`, `:40-47`; `hr_constants.gd:591-598`, `:717` |
| 14 | **Nakit** = K9 nakdi + (yeni kümülatif net - eski kümülatif net); çek ve seed K9'daki günlerinde. İlk işe alım değişkenlerinde (spend / hoard) çek ve seed aynı günde kalır, gelir K9'daki gibi akar (ekibin getirisi sayılmaz: iyimser). Series A Avı = MRR >= $120.000; kaydırma f = 1 ve 0,5 ile iki uç | `sales_system.gd:46`, `phase_gate_system.gd:56` |
| 15 | **Botun işe alım kuralı** (`k = 6`) bugünkü `daily_burn x 30 + 6000 - mrr` ve çek şartı değil: yeni giderle k x (kira + maaş x1,5 + sunucu). Bu bir model, C9'da yazılacak kuralın taslağı değil | `run_probe.gd:1410-1434` |
| 16 | **Kesinti Monte Carlo:** gün sayacı hafta, iki olay arası >= 4, v1.0 sonrası 3 hafta sessiz (v1 = hf 7); tür seçimi dışında; biçim (c)'de s = 1 - f + f / 2,5 (f = ay sonu payı 1 / 4,35) | `incident_system.gd:75-78`; `sprint.json` incident |
| 17 | **M1** yapı gereği 0 (terimler değişmedikçe memnuniyet değişmez, defter satırı yalnız yukarı söner). Gerçek ölçüm Q'nun `PROBE UFLUX`'u ve C3a'nın smoke'u | PRD §4.4 m.1 |
| 18 | **Hız ve ölçek:** 330 hesap ölçeği M9'da havuzdan örnekleme (1.000 deneme); 330 hesaplı gece tiki ölçülmedi (Godot gerektirir) | PRD §4.1 M9 |

## 7. Çalıştırma
```
cd docs/tasks/faz_cde/c_taslak/msim
python -I c0s_trim.py        # yalnız Q'nun scratchpad'i varsa; k9_trim/ ve k9_trim_15/ zaten repoda
python -I c0s_run_all.py     # check, m1, m2, load, econ, econ2, core2 (out/c0s_*.md)
python -I c0s_build.py       # ../C0S_SONUC.md
```
Modüller: `c0s_data.py` (kayıt ayrıştırma, dünya), `c0s_model.py` (Q'nun U'su + C'nin memnuniyeti), `c0s_core.py` (boru hattı), `c0s_m1.py` (M1-M5, M10, ❌1), `c0s_m2.py` (M6, M8, yenileme, M9, M13, ❌2, M10 duyarlılık, CORE_2 paneli), `c0s_load.py` (M7, sunucu politikaları), `c0s_econ.py` ve `c0s_econ2.py` (ekonomi, öneri taramaları), `c0s_core2.py` (❌1 taraması).

## 8. Ek tablolar (ham)
#### M2 İlk 12 hafta (ürün ve hata sabit, olay yok)

`fix_worst` dünyasının her haftası (7-100) donduruldu, 3 yıldız x 13 sektör, iki tohum. 3★ satırında Kurumsal madde (-10, Karar 4) açıktır ve kapı toplamı okur.

| Yıldız | aday | kapı reddi | imzalayan | imza değerinin altına inen | imzada en küçük (memnuniyet - eşik) | Sonuç |
|---|---|---|---|---|---|---|
| 1★ | 2444 | 0 (0.0%) | 2444 | 0 | 32 | geçti |
| 2★ | 2444 | 362 (14.8%) | 2082 | 0 | 10 | geçti |
| 3★ | 2444 | 1452 (59.4%) | 992 | 0 | 10 | geçti |
| hepsi | 7332 | 1814 (24.7%) | 5518 | 0 | 10 | geçti |

#### M3, M4, M5 Kayıp (A'nın tanımı: erken = v1.0'dan sonra 20 hafta, geç = sonrası)

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

#### M10 İmza kapısı (MVP sonrası 26 hafta, hf 7-33)

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

#### RAPOR_Q §1 madde 1 (❌1): 2★+3★ imzalarda U = 100 payı, `CORE_2` 1,25 ve 1,5

Hedef (Q kapısı): `fix_worst` 2★+3★ imzalarında U = 100 payı en çok %25; Traction (evre 2) 2★+3★ imza U ortancası 70-85. Her satır kendi bot kayıtlarından: 1,25 = `910ad1f` (k9_trim), 1,5 = `bd9a5ed` (k9_trim_15). U, oyunun `PROBE FIT u=` değeridir (imza anında); "C kapısıyla" = kapıdan geçen imzalar (U - hata terimi >= eşik + 10) üzerinde pay.

| CORE_2 | Kol | 2★+3★ imza | U = 100 | pay (kapısız, Q'nun ölçümü) | kapıdan geçen 2★+3★ | U = 100 / geçen (C kapısıyla) | Traction ortanca U (kapısız → C kapısıyla) |
|---|---|---|---|---|---|---|---|
| 1,25 | en kötüsünü düzelten (worst) | 149 | 60 | 40.3% | 126 | 47.6% | 86 → 93 |
| 1,25 | hiç düzeltmeyen (none) | 193 | 79 | 40.9% | 21 | 4.8% | 88 → 66 |
| 1,25 | vadesi gelen düzelten (due) | 96 | 25 | 26.0% | 77 | 32.5% | 74 → 79 |
| 1,5 | en kötüsünü düzelten (worst) | 107 | 0 | 0.0% | 81 | 0.0% | 70 → 83 |
| 1,5 | hiç düzeltmeyen (none) | 121 | 0 | 0.0% | 11 | 0.0% | 77 → 60 |
| 1,5 | vadesi gelen düzelten (due) | 118 | 0 | 0.0% | 94 | 0.0% | 70 → 81 |

#### ❌1 taraması: CORE_2 değeri (sabit dünya)

Bot ürünü 1,25 koşusundan (910ad1f) sabit; yalnız 2★ Çekirdek beklentisi değişir. 2★+3★ imzaların U'su (aday bağlamı, rakip penceresi dahil) yeniden hesaplanır; C kapısı hesabın kendi referansıyla (rakipsiz). Hedef (Q kapısı): U = 100 payı <= %25 (`fix_worst`), Traction ortanca U 70-85; Erdem'in M10 hedefi %55-65. "Kapısız" = Q'nun ölçümü, "kapılı" = C kapısından geçenler.

| CORE_2 | 2★+3★ imza (worst) | U=100 payı kapısız | U=100 payı kapılı | Traction ortanca U kapısız → kapılı | M10 imza ÷ eski kod (worst, kapılı) | M5 none geç kayıp (7 / 11) |
|---|---|---|---|---|---|---|
| 1.25 | 149 | 40.9% | 48.4% | 85 → 93 | 51.2% | 14.3 / 34.2 |
| 1.30 | 149 | 40.9% | 48.8% | 84 → 94 | 50.6% | 11.8 / 33.3 |
| 1.35 | 149 | 36.9% | 44.4% | 83 → 93 | 50.6% | 9.1 / 32.5 |
| 1.40 | 149 | 36.9% | 44.4% | 81 → 91 | 50.6% | 9.1 / 31.6 |
| 1.45 | 149 | 36.9% | 44.4% | 79 → 90 | 50.6% | 7.7 / 30.7 |
| 1.46 | 149 | 36.9% | 44.4% | 79 → 89 | 50.6% | 7.7 / 30.7 |
| 1.47 | 149 | 36.9% | 44.4% | 79 → 89 | 50.6% | 7.7 / 30.7 |
| 1.48 | 149 | 0.0% | 0.0% | 79 → 89 | 50.6% | 6.2 / 30.7 |
| 1.49 | 149 | 0.0% | 0.0% | 78 → 88 | 50.6% | 6.2 / 30.7 |
| 1.50 | 149 | 0.0% | 0.0% | 78 → 88 | 50.6% | 6.2 / 30.7 |

#### CORE_2 karşılaştırması: 1,25 (bugün, 910ad1f) ve 1,5 (bd9a5ed kayıtları)

Aynı C modeli iki kayıt kümesinde (her biri kendi bot ürün hızıyla). Gate satırları: M3-M5 geç kayıp (tohum 7 / 11), M10, M13.

| Kapı | CORE_2 1,25 | CORE_2 1,5 |
|---|---|---|
| M3 (due geç <= off + 2) | geçti | geçti |
| M4 (worst) | geçti | geçti |
| M5 (none geç kayıp %, tohum 7 / 11) | geçti (14.3 / 34.2) | geçti (10.3 / 30.7) |
| M10 imza ÷ eski kod (worst / none / due / off) | 51.2% / 48.8% / 49.7% / 56.7% | 49.4% / 44.8% / 45.7% / 53.2% |
| M13 bakımlı yenileyen | 98.7% (708 karar) | 98.6% (693 karar) |

#### M6 Söz (tek hesap, 2★ lojistik, dünya sabit, 20. haftada söz sonuçlanır)

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

#### M8 Güncellenmeyen ürün (Karar 7: yaş yalnız iki vurgu alanına dokunan yayından sayılır)

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

