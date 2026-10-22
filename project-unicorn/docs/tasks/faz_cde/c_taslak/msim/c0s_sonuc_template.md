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
@@c0s_b.md#M10 duyarlılık@@

### 3.2 ❌2 satışçı kapanış kaybı (hedef %5-15)
- **Neden:** zar yalnız müşterinin baktığı bir alan eksikken atılır (`product_quality.gd:233` `close_chance`, `loss_area` boşsa 1). Masalı `fix_worst`'te 328 kapanışın 5'inde (%1,5) alan eksik; 2★+3★'ta 19'un 5'inde. Zar eğrisi ya da C'nin zar tabanı bu paydan fazlasını kaybettiremez. C kapısı bu kolda hiçbir adayı geri çevirmiyor (0): ürün 2★ bandını doyuruyor.
- **Ölçülen oynaklar:** kapı payı 10 / 12 / 15 / 20 ve zar tabanı 0,60 / 0,45 / 0,30 / 0 her birleşimde `fix_worst` 2★+3★ %1,8 (bütün kapanışlar %0,1). `quality_core` masalı 2★+3★ %84-100 (hedef >= %20 ✅, hatta çok yüksek).
- **Tek işe yarayan düğme beklentidir:** `CORE_2` 1,75 → 2★+3★ kaybı %4,8, 2,0 → %10,4 (alan eksik 5 → 6 kapanış). Bütün kapanışlarda (n = 328) en iyi durumda bile %0,7. Yani %5-15 hedefi bütün kapanışlar sütununda bu bot için ulaşılamaz; 2★+3★ sütunu 19 kapanışa dayanır ve gürültülüdür.
- **Öneri:** hedefi kapı olarak değil gösterge olarak oku (zar bakımsız üründe çalışıyor: `quality_core` %84); C'nin kapısına ve zar tabanına dokunma.
@@c0s_b.md#RAPOR_Q §1 madde 2@@
@@c0s_b.md#Zar için gereken beklenti@@

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
@@c0s_e.md#Evre 3 aylık net@@
@@c0s_e.md#Bootstrap runway ve ilk 40 hafta@@

### 3.5 M12 (sunucu payı)
- **Neden:** eski kapasite büyümesi yükü ortalama %56-57'de tutuyordu (boş pay %43-44); oyuncu `auto`'da yükü %68, `lean`'de %87 tutar. Fatura payı politikaya göre %5,6 ile %8,9 arasında; tek fiyatla üçü birden %8-12'ye giremez.
- **En küçük öneri:** Standart B2B $135 (auto %8,3, wide %10,0, lean %6,3) ile $150 (%9,2 / %11,1 / %7,1); B2C $350 (auto %8,8, wide %10,5). 1 : 2 : 4 oranı korunur (Ekonomik yarısı, Kurumsal iki katı). `lean` hiçbir fiyatta %8'e gerek kalmadan makul: o oyuncu bilerek kesinti riskini alıyor (§3.6).
@@c0s_e.md#M12 öneri taraması@@

### 3.6 Sunucu politikaları (Risk 1: "server_auto her yerde en iyiyse elle yönetim boş tıktır")
- `lean` (pay %5): sunucu faturası 78 hafta için $24K ucuz, ama yük 73-84 hafta %90'ın üstünde: beklenen kesinti 8,56-8,79 (auto 7,06-7,08). Yani `lean` ile `auto` farklı sonuç alır (kesinti, net) ✅.
- `wide` (pay %40): `auto` ile kesinti aynı (7,06 / 7,08), fatura $20K pahalı: **`wide` `auto`'ya baskındır, boş pay para kaybıdır.** İki politika gerçekten farklı kalıyor: lean ile auto. Elle yönetim yalnız lean'i seçen oyuncu için karardır.
@@c0s_c.md#Sunucu politikaları@@

### 3.7 M7 (kapsam)
- Kademe çarpanı bugünkü kodda kırpmadan sonra (`incident_system.gd:75-78`); bu yüzden 9/9 geçiyor. Yük çarpanı `load_mult()`'a girerse kırpmanın içine düşer ve ipucundaki "kesinti ihtimali x1,5 / x2,5" yazısı 12 açık hatada x1,2'ye düşer. Öneri: yük çarpanı kırpmadan sonra (biçim b): her hücrede x1,5 / x2,5 tam; 9/9 ve yük oranı x1,33.
- Biçim (c) (E1 soru 1, yük yalnız kesinti türünün payına, s = %86): yük %95 / %70 oranı x1,27 (hedef 1,3'ün altı). Kesinti payı için kapıyı yükseltmek gerekir ya da (b) seçilir.
@@c0s_c.md#M7 Kesinti kademesi@@

## 4. Yenileme: sonuç dağılımı ve 13 sektörün eğilimi
- **Politika:** satışçı raporunun 1. seçeneği (tutumun en iyi fiyatı), ikna +2. Sonuç zarı sırası (bütçe, geçiş, mali azalış, koltuk artışı) benim varsayımım; PRD sırayı yazmıyor.
- **Okuma:** bakımlı üründe tutumun tamamı "Zamma açık" (Erdem: normal). Çeşitliliği koltuk sonuçları veriyor: kararların %37'sinde koltuk artışı, %4,7'sinde mali azalış. Artış/azalış oranı 8:1; sağlıklı büyüme tutumuyla uyumlu ama koltuk artışı %10-30 ile birlikte yenilenen hesabın MRR'ını yılda yaklaşık %14-15 büyütüyor (zam %8 + artış - azalış). E1'de oran onayı ayrıca istenmeli; ölçülmedi: etkisi MRR eğrisine.
- **Cevapsız kâğıt (aynı fiyat):** bakımlı kollarda fark yok; `none`'da yenileyen %98,2 → %75,2 (82 gönülsüz yenileme, 26 ayrılan).
@@c0s_b.md#Yenileme sonuç dağılımı@@
@@c0s_b.md#M13 Yenileme kapısı@@
@@c0s_b.md#M9 Ürün dışı kayıp@@

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
@@c0s_d.md#M12 Sunucu faturasının@@
@@c0s_d.md#M11 Gider ve runway, B2B@@
@@c0s_d.md#Bootstrap runway@@
@@c0s_d.md#İş hanı'nın Frank@@
@@c0s_d.md#Plaza'nın şartları@@
@@c0s_d.md#M11 B2C@@
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
@@c0s_a.md#M2 İlk 12 hafta@@
@@c0s_a.md#M3, M4, M5@@
@@c0s_a.md#M10 İmza kapısı@@
@@c0s_a.md#RAPOR_Q §1 madde 1@@
@@c0s_f.md#❌1 taraması@@
@@c0s_b.md#CORE_2 karşılaştırması@@
@@c0s_b.md#M6 Söz@@
@@c0s_b.md#M8 Güncellenmeyen ürün@@
