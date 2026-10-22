# Faz C içerik v3 · Sunucu, giderler, memnuniyet
Yazan: Opus planlayıcı · 2026-10-17 akşam · Kaynak: Erdem'in cevabı (`ERDEM_CDQ_CEVAP.md` ve Ek, birebir), ilk yorum
(`ERDEM_CD_YORUM.md`), `C_ICERIK_v2.md`, `KALITE_v2.md` (bu turun eşi), araştırma R6, R7, R8, R9, R11. Kod `f4a623b`
(B2) üstünde okundu; koda dokunulmadı, Godot koşmadı. Sayı hesapları `python -I` ile A'nın K5 bot kayıtlarından
(`docs/tasks/faz_ab/a_calisma/K5_runs/`) yapıldı.

Etiketler:
- **Erdem'in kararı (17 Ekim akşam):** cevapta açıkça onayladığı ya da istediği şey.
- **Öneri:** benim önerim, onay bekliyor.
- **[ÇALIŞMA]:** sayı, onay bekliyor; ölçümle kesinleşir.
- **v2:** `C_ICERIK_v2.md`'deki hâli geçerli, burada tekrar yazılmadı.
- **tahmin:** bot kararları sabit tutularak yapılan muhasebe hesabı; oyun koşusu değil.

Ürün uyumu U'nun tanımı yalnız `KALITE_v2.md` §3'tedir. Bu belge U'yu oradaki anlamla kullanır, yeniden tanımlamaz.

---

## 0. Erdem'e özet

**"Memnuniyet niye 70'ten 45'e iniyor?"**
Kodda memnuniyet iki ayrı sayıdan geliyor. İmzada hesap "eşik + 10, en az 50" ile açılıyor (`sales_system.gd:367-368`).
Sonra her hafta en çok 21 puan, oyuncunun hiçbir yerde görmediği bir hedefe yürüyor: ürünün gizli Kararlılık puanı, eksi
açık hata cezası, artı söz defteri (`b2b_sales_system.gd:87-125`, `:140-153`). İlk 4 hafta bir taban hedefi eşiğin 2
puan üstünde tutuyor; taban kalkınca hesap gizli puana iniyor. 45 bir örnekti; gerçek sayı gizli puana göre 0 ile 63
arası değişir. Bot kaydından gerçek bir hesap: imza 50, bir hafta sonra 35, beşinci haftada 24, eşik 33, 16. haftada
ayrıldı; o hesabın hatlarında tek açık hata yoktu (`full_run_fix_worst_7.log`, `co_lead_8_1`).
Yeni modelde hedef ve kayma yoktur. Memnuniyet, ipucunda yazan satırların toplamıdır; imzada o günkü gerçek değeriyle
açılır (beklentiyi karşılayan üründe 70 civarı) ve yalnız adı yazan bir olayla değişir.

Kısa özet:
1. **Sunucu (C1):** Kapasite oyuncudadır; otomatik büyüme yoktur. Tek gösterge "Yük %", yanında boş payın koltuğu ve
   parası. Artır ve azalt düğmesi mevcut kapasitenin %10'u kadar oynatır, hemen işler. Yük %90'ı geçince kesinti ihtimali
   ×1,5, %100'ü geçince ×2,5; başka ceza yoktur. Büyüme yükü 4 hafta içinde %90'a taşıyacaksa blokta bir satır uyarır.
2. **Giderler (C3):** "Geçim ve araçlar" ile "Servis maliyeti" kalkar. Servis bugün bütün giderin yarısıdır (%47 ile %57).
   Kalan liste: Maaşlar (kurucu satırı dahil), Ek mesai, Sunucular, Ofis, Pazarlama. Sunucu Standart'ta gelirin yaklaşık
   %9'una oturur. Telafisiz kalırsa B2B'de nakit açığı 41 binden 12 bine iner ve seed gereksizleşir; öneri telafinin
   görünür kalemle, maaş bantlarıyla yapılması (Soru 1). (inceleme) Simülasyon ×1,5'in dört gider kapısının ikisini
   tutturduğunu ölçtü (`MEMNUNIYET_SIM.md` §5.4); karar Erdem'in (Soru 1).
3. **Bütçe kesintisi (C5 ek):** Yenilemede düşük ihtimal (1★ %2, 2★ %1,5, 3★ %1). Memnun hesap koltuğunu yarıya indirip
   kalmayı teklif eder; memnun olmayan ayrılır. Mail nedeni yazar.
4. **Memnuniyet (C6):** R9'un olay defteri ailesi seçildi. İmzada gerçek değer, kayma yok, her değişim adlı bir satır.
   Ürün uyumu hesabın imzasındaki pazar beklentisiyle okunur, yenilemede bugünküyle yeniden okunur; ürün iyileşince hemen
   artar. Uzun süre güncelleme almayan ürün 26. haftadan sonra ayda 1 puan kaybettirir.
5. **Hacim:** 11 dilim, yaklaşık 41 saat (v2: 27,5).

---

## 1. Erdem → karşılık

| # | Erdem (kısa alıntı) | Karşılık | Yer |
|---|---|---|---|
| 1 | "Tek bir yük yüzdesi görünsün. Yük %90'ı geçince kesinti ihtimali artsın." | Tek "Yük %" satırı; %90 ve %100 eşikleri; başka gizli etki silinir. Erdem'in kararı. | §2.1, §2.3 |
| 2 | "kapasite arttır, azalt ... oyuncuya bırakalım ... bir gap bırakmak isteyebilir ... doğru wordinglerle" | Otomatik büyüme yok (v2'nin S2'si kalktı). Artır ve azalt düğmesi, boş payın koltuğu ve parası görünür. | §2.2 |
| 3 | "Kesinti çarpanını okey ... 1, 0.5, 0.25" | Kademe çarpanı 1,0 / 0,5 / 0,25; evi B'nin ayarı. Erdem'in kararı (B'ye iletildi). | §2.5 |
| 4 | "%8, %15 arasında ... Kademeler 1, 2, 4 bence okey" | Standart'ta gelirin yaklaşık %9'u; 1 : 2 : 4. | §3.2 |
| 5 | "tool'u koymamalıyız ... göremediği, yönetemediği bir şeyi oraya gider olarak koymayalım ... toplam gider değişmesin demişsin ya" | Araç gideri ve servis maliyeti kalkar; "toplam değişmesin" yaklaşımı geri gelmez. Etki sayıyla ve telafi seçenekleriyle. | §3.3 - §3.5 |
| 6 | "C4, okey." | Kurumsal madde v2 §2.3 olduğu gibi. Erdem'in kararı. | §6 |
| 7 | "C5, okey." | Yenileme akışı v2 §2.6 olduğu gibi. Erdem'in kararı. | §6 |
| 8 | "müşteriler ayrılmasın zaten ... düşük de bir ihtimal olsa ... harcamalarımızı azaltmaya gidiyoruz" | Ürün dışı yenilememe: düşük oran, mailde neden, memnun hesap küçülerek kalır. | §4 |
| 9 | "isteklerini yapıp ürünü sıçmadığı sürece memnuniyet durup dururken niye düşsün" | Kayma kalkar. Düşüren yalnız: açık hata, kesinti, tutulmayan söz, uzun süre güncellenmeme, yenilemede pazarla yeniden okuma, fiyat. | §5 |
| 10 | "70'ten başlayan müşteri hedefi niye 45 olsun? ... direkt o şekilde başlasın" | Cevap §0'da. İmza değeri gerçek ve satırlarıyla okunur; "70 tabanı" ve sönüm (v2) kalkar. | §0, §5.4 |
| 11 | "uzun süredir güncelleme almayan bir üründe belki memnuniyet düşebilir" | Güncelleme yaşı: 26 hafta sessiz, sonra her 4 haftada −1, en çok −12; sayaç ipucunda görünür. | §5.5 |
| 12 | "araştırılmalı ... ölçümlenip doğru düzgün bir şekilde bana sunmanız lazım" | R9 okundu; seçim gerekçeli; simülasyon kapıları §7'de. | §5.1, §7 |
| 13 | Q1, Q3 (ürün kalitesi alanlardır; çekirdek ağır basar, sektör ek ağırlık) | U'yu `KALITE_v2.md` tanımlar; C memnuniyette ve ipucunda onu okur. | §5.6 |
| 14 | "faz B'ye de ilgili mesajı sen gönderebilirsin" | B'yi etkileyen değişiklikler gönderilmeye hazır not olarak §8'de (inceleme: dört maddeye simülasyonun kesinti sırası, defterin sönme hızı ve D v3'ün üç notu eklendi, yedi madde). | §8 |

---

## 2. C1 · Sunucu kapasitesi oyuncuda

### 2.1 Birim ve gösterge
- **Birim:** B2B'de 50 koltuk, B2C'de 1.000 kullanıcı (bugünkü birim, `infra_system.gd:30-31`). Gerçekte kapasite eşzamanlı
  yükle ölçülür; koltuk ve kullanıcı bunun insan cinsinden karşılığıdır (R6 §2.5). Oyuncu sunucu adedi görmez, koltuk ya da
  kullanıcı görür (v2 §2.2.2).
- **Kapasite** etkin kapasitedir: satın alınan birim × birim boyutu ÷ yük katsayısı (`infra_system.gd:174-178`). Ağır kademe
  yayınlamak aynı birimle daha az koltuk taşır. Bu yüzden yayın sonrası kapasite değişebilir; sürüm notu bunu yazar (§2.4).
- **Yük %** = hizmet edilen koltuk (B2C'de canlı kitle) ÷ kapasite (`infra_system.gd:180-195`). Tek gösterge budur.
- **Boş pay:** kapasite − hizmet edilen, koltuk ve aylık para olarak. Neden var: Erdem oyuncunun bilerek pay bırakmak
  isteyebileceğini söyledi. Payın bedeli görünürse bu bir karardır, görünmezse kayıptır. Boş kapasite de fatura öder (R6 §5:
  Software Inc'te boşta sunucunun bedava olması istismar üretti).

```
┌ SUNUCU ─────────────────────────────────────────────┐
│ [Ekonomik │ Standart │ Kurumsal]                    │
│ Kapasite 6.500 koltuk · ayda $15.600                │
│ Yük %80 · boş pay 1.300 koltuk · ayda $3.120        │
│ [ Azalt · 650 koltuk ]   [ Artır · 650 koltuk ]     │
│ Bu büyüme hızıyla yük 3 hafta sonra %90'ı geçer.    │   ← yalnız koşulu tutarsa
│ Kurumsal sunucu bekleyen 1 hesap                    │   ← v2 §2.2.6
└─────────────────────────────────────────────────────┘
```
B2C'de "koltuk" yerine "kullanıcı" yazar; madde satırı çizilmez.

### 2.2 Artır ve azalt
- **Adım:** mevcut birimin %10'u, en az 1 birim [ÇALIŞMA]. Neden oran: 6 hesaplık ürün de 330 hesaplık ürün de tek tıkla
  anlamlı bir adım atar; sabit "1 birim" 330 hesapta 13 tık ister.
- **Ne zaman işler:** hemen. O haftanın gece zarı yeni kapasiteyle okunur. Fatura bir sonraki tikten haftalık payla işler.
  Neden: Erdem kapasiteyi basit istedi; kademe başına teslim gecikmesi ayrı bir kural ve ayrı bir metin demektir.
- **Maliyet değişimi** düğmenin ipucunda önceden yazar:

| | TR | EN |
|---|---|---|
| Artır ipucu | `650 koltuk ekle · ayda $15.600 → $17.160 · yük %80 → %73` | `Add 650 seats · $15,600 → $17,160 a month · load 80% → 73%` |
| Azalt ipucu | `650 koltuk çıkar · ayda $15.600 → $14.040 · yük %80 → %89` | `Remove 650 seats · $15,600 → $14,040 a month · load 80% → 89%` |
| Azaltma yükü %100'ün üstüne taşırsa (kırmızı) | `Yük %112 olur. Kapasite yetmez.` | `Load becomes 112%. Capacity falls short.` |

- Azaltma her zaman açıktır; oyuncu kararıdır. Taban 0 birimdir (bugünkü kural, `infra_system.gd:51`).
- **MVP:** kademe seçimiyle birlikte 1 birim açılır (bugünkü `SUGGESTED_START_UNITS`, `infra_system.gd:54`).
- **Silinen:** sürümde kendiliğinden büyüme (`sprint_bridges.gd:64`). Erdem otomatik ölçeklemeyi reddetti.

### 2.3 Yük ve kesinti
- **Yük çarpanı** (kesinti ihtimaline): %90'a kadar ×1; %90'ın üstü ile %100 arası ×1,5; %100'ün üstü ya da kapasitesiz canlı
  ürün ×2,5 [ÇALIŞMA]. v2 §2.2.1'deki değerler korundu. Neden korundu: R6 §5 %80-100 arasında ×3-5 önerir, ama B'nin
  olasılık tavanı (0,30, `sprint.json:42`) ve 4 haftalık en kısa aralık zaten frenler; ×1,5 basamağı oyuncuya "%90'ın
  üstü risklidir" demeye yeter. Eşik %90'dır çünkü Erdem öyle onayladı; kapasite artık oyuncuda olduğu için v2'nin "haftalık
  ölçekleme %80'i hep aşar" gerekçesi düştü, eşik yalnız kararla durur.
- **Gizli ceza yok.** Bugünkü aşım etkileri silinir: memnuniyet günde −0,8, bildirim akışı ×1,5, B2C kazanımı ×0,6
  (`infra_system.gd:66-69`, `:286-314`). Yükün tek sonucu görünür kesinti ihtimalidir. Neden: oyuncunun görmediği ceza R8
  §4'teki Startup Company şikâyetinin kaynağıdır.
- Ekonomik'in görünür iki bedeli kalır ve kademe ipucunda yazar: bildirim akışı ×1,25 (`infra_system.gd:35`) ve kurumsal
  hesap imzalayamaz (`infra_system.gd:323-324`). v2.
- Gösterim: %90'ın üstünde sarı, %100'ün üstünde kırmızı (renk token'ı, renk körü ikizi helper'da).

| Durum | TR | EN |
|---|---|---|
| Yük %90'ın üstü | `Yük %94. %90'ın üstünde kesinti ihtimali 1,5 katına çıkar.` | `Load 94%. Above 90%, the chance of an outage is 1.5 times higher.` |
| Yük %100'ün üstü | `Yük %104. Kapasite yetmiyor; kesinti ihtimali 2,5 katına çıkar.` | `Load 104%. Capacity falls short; the chance of an outage is 2.5 times higher.` |

### 2.4 Büyümeyi haber veren satır
- **Kural:** son 4 haftanın haftalık büyümesiyle yük 4 hafta içinde %90'ı geçecekse blokta tek satır çıkar
  [ÇALIŞMA]. Hesap: hafta = (0,9 × kapasite − hizmet edilen) ÷ haftalık ortalama artış; 1 ile 4 arasındaysa yazar. Yük
  zaten %90'ın üstündeyse bu satır yerine §2.3 satırı yazar.
- **Sürüm satırı:** ağır kademe kapasiteyi düşürürse sürüm notuna bir satır girer.
- Neden: otomatik büyüme kalkınca oyuncu büyümeyi önceden görmeli; aksi hâlde ilk haberi kesinti olur. R9 §4.8: oyuncu
  "kaybı fark edememe"den şikâyet etti.

| Satır | TR | EN |
|---|---|---|
| Büyüme | `Bu büyüme hızıyla yük 3 hafta sonra %90'ı geçer.` | `At this growth rate, load passes 90% in 3 weeks.` |
| Sürüm | `v1.7 ile kapasite 7.000 koltuktan 6.300 koltuğa indi. Yük %78 → %87.` | `With v1.7, capacity fell from 7,000 seats to 6,300. Load 78% → 87%.` |

Bugünkü kapasite uyarı kartı (`infra_system.gd:333-341`) hiç bağlanmadı; bu satır onun yerini alır ve kart silinir.

### 2.5 Kademe, fiyat, çarpan
- Üç kademe (v2). Geçiş anında ve bedavadır (v2).
- **Kademe çarpanı** 1,0 / 0,5 / 0,25: Erdem'in kararı. Evi B'nin ayarı (`sprint.json:42` `incident.tier`, bugün
  1,5 / 1,0 / 0,6); C sayıyı kopyalamaz, ipucu oradan okur.
- **Fiyat oranı** 1 : 2 : 4: Erdem'in kararı. Değerler §3.2'de.

Kademe ipucu (Standart, B2B):
```
Standart                                  Standard
50 koltuk başına ayda $120                $120 a month per 50 seats
Kesinti ihtimali ×0,5                     Outage chance ×0.5
Kurumsal sözleşme şartını karşılamaz      Does not meet the enterprise contract clause
```

### 2.6 B'nin okuduğu tek doluluk sözleşmesi
- B bugün `IncidentSystem.load_mult()`'u okur ve o 1 döner (`incident_system.gd:43-45`). C onu doldurur: gövde
  `InfraSystem.outage_load_mult()` çağırır, sayı tek yerde durur.
- Sözleşme: `outage_load_mult() -> float`: canlı ürün yoksa 1,0; yük ≤ 0,90 ise 1,0; 0,90 < yük ≤ 1,00 ise 1,5; yük > 1,00
  ya da kapasitesiz canlı ürün 2,5. Yük gece zarının okunduğu andaki değerdir. Basamaklar `InfraSystem`'de tek sabit dizide
  [ÇALIŞMA].
- Çarpan yalnız "kesinti" türüne uygulanır (bugün tek tür odur, `incident_system.gd:21`). Yeni tür gelirse B karar verir.
- B'nin `p_max` 0,30'u kalır: hata yığan oyuncuda yükün etkisi tavanda kesilir, az hatalı oyuncuda görünür (v2 §2.2.5).
- (inceleme) **Kademe çarpanı tavandan sonra uygulanır:** p = en küçüğü (0,10 × yük × hata; 0,30) × kademe. Neden: bugün
  kademe tavandan önce çarpılıyor (`incident_system.gd:48-53`); yük ve hata yüksekken Ekonomik ile Standart aynı 0,30'a
  dayanıyor ve Erdem'in 1,0 / 0,5 / 0,25 kararı 9 durumun 3'ünde bozuluyor (Standart ÷ Ekonomik 0,84, 0,76, 1,00). Sıra
  değişince 9 durumun 9'unda her basamak tam yarı (`MEMNUNIYET_SIM.md` §3, §5.2). B'nin kodu; §8 madde 5.

### 2.7 Silinenler (kod)
`sprint_bridges.gd:64` (sürümde büyüme), `infra_system.gd:66-69` ve okuyucuları (aşım memnuniyeti, akış, kazanım),
`infra_system.gd:333-341` (bağlanmamış uyarı kartı), `units_for_occupancy` (tek çağıranı silinen satır).

---

## 3. C3 · Giderler

### 3.1 Bugünkü liste ve paylar
Kaynak: A'nın K5 bot kayıtları, `PROBE MONTH_BURN` satırları, 104 hafta, `fix_worst` (tahmin değil, ölçüm).

| Kalem (`FinanceSystem.BURN_IDS`, `finance_system.gd:38`) | Oyuncunun gördüğü ad | Nereden | Bütün giderdeki pay (B2B / B2C) |
|---|---|---|---|
| salaries | Maaşlar | çalışanlar | %24-29 / %16 |
| overtime | Ek mesai | çalışma saatleri | 0 |
| tools | Geçim ve araçlar (`strings.csv:3015`) | evreye göre taban + çalışan başına (`finance_system.gd:13-14`, `:219-222`) | %8-9 / %8-9 |
| marketing | Pazarlama | olay kartının kampanyası | 0 |
| office | Ofis | yazarı yok, hep 0 (`finance_system.gd:28`) | 0 |
| servers | Sunucular | birim × fiyat (`infra_system.gd:256-259`) | %4 / %6 |
| service | Servis maliyeti (`strings.csv:3016`) | hesap başına $45 + koltuk başına $8, B2C 1.000 kullanıcı başına $700, yeni hesabın ilk haftalarında MRR'ının evreye göre 0 / 0,25 / 3 katı (`infra_system.gd:87-92`, `:267-277`) | **%47-52 / %55-57** |

Kalan pay tek seferlik giderlerdir (%11-15: işe alım primi, kesinti kredisi). Okuma: oyunun asıl gider kalemi oyuncunun ne olduğunu bilmediği "Servis maliyeti"dir. Evre 3'ün daralmasını büyük ölçüde
onun yeni hesap çarpanı (MRR × 3) yapıyor.

### 3.2 Sunucu fiyatı
- **Hedef:** Standart'ta 26. haftadan sonra gelirin %8 ile 12'si; Ekonomik yarısı, Kurumsal iki katı. Erdem'in kararı: band
  %8-15, oran 1 : 2 : 4. Dayanak: a16z ile Bessemer'in birleşimi gelirin %14-17'si (https://a16z.com/the-cost-of-cloud-a-trillion-dollar-paradox/,
  https://www.bvp.com/atlas/scaling-to-100-million, hesap R6 §2.5); satıcı rehberi düşük hesaplı SaaS için %8-15
  (https://wring.co/blog/cloud-costs-for-saas-companies, doğrulanmamış).
- Standart'ı bandın alt yarısına koymamın nedeni: Kurumsal iki katıdır. Standart %9 iken Kurumsal %18 olur; bu, 3★ maddesi
  için "geçmeli miyim" sorusunu gerçek bir para kararı yapar ama ürünü batırmaz.

| [ÇALIŞMA] | Ekonomik | Standart | Kurumsal |
|---|---|---|---|
| B2B, 50 koltuk başına ayda | $60 (bugün $30) | $120 (bugün $45) | $240 (bugün $70) |
| B2C, 1.000 kullanıcı başına ayda | $125 (bugün $35) | $250 (bugün $55) | $500 (bugün $85) |

Gelir payı, Standart, bot kaydına göre (tahmin; bugünkü oran × yeni fiyat ÷ eski fiyat):

| Dönem | B2B | B2C |
|---|---|---|
| MVP öncesi | 0 (canlı ürün yok) | 0 |
| MVP sonrası ilk ay (tek birim, gelir küçük) | %10-11 | gelirden büyük (tek birim $250, gelir $70-560) |
| Evre 2, 15.-25. hafta | %4-8 | %12-22 |
| Evre 2, 26. haftadan sonra | %8-10 | %8-10 |
| Evre 3 | %9 | %9-10 |

- B2C'nin ilk haftaları bilerek pahalıdır: ilk birim gelirden önce gelir, gerçekte de altyapı ilk müşteriden önce ödenir.
- B2C fiyatı E'ye kadar [ÇALIŞMA]: pazaryeri komisyonla kazanır; E 101. haftada Standart'ın gelir payını ölçer, %8-12
  dışındaysa birim fiyatı Erdem'e gider (v2 §3'teki not, oran güncellendi).
- v2'nin B2C $150'si bu turda yetmiyor: A sonrası B2C geliri büyüdü (A'nın raporu §1), bugünkü oran %2,2 ile $150 %6'da kalır.

### 3.3 Kalkan kalemler
**Araç gideri ("Geçim ve araçlar").** Erdem'in kararı: kalkar.
- Kod: `TOOLS_BASE_MONTHLY`, `TOOLS_PER_EMPLOYEE_MONTHLY` (`finance_system.gd:13-14`), başlangıç kalemi (`:26`), tik çekişi
  (`:136`), `monthly_tools_for` (`:219-222`), `BURN_IDS`'teki "tools" (`:38`).
- HR önizlemeleri: işe alım (`hr_search_system.gd:251-256`, `burn_after` formülünden "tools" iki kez çıkar) ve işten
  çıkarma (`hr_actions.gd:247-248`, satır tümden kalkar).
- Metin anahtarları: `FIN_BURN_TOOLS` (`strings.csv:3015`), `HR_ROW_TOOLS` (`strings.csv:3026`).
- Debug: `run_probe` `MONTH_BURN` ve `GATE` satırlarındaki tools alanı, smoke'taki tools vakaları (20 satır, `scripts/debug/`).
- Taban kısmının bir anlamı vardı: kurucunun geçimi. Bootstrap'ın runway'i (10.000 ÷ 1.500 = 6,7 ay) ondan gelir. Öneri:
  bu para görünür bir satıra taşınır, §3.4.

**Servis maliyeti.** Öneri: kalkar.
- Ne: büyüyen müşteri defterinin "bakım" bedeli (`infra_system.gd:82-86` yorumu). Gerçekte buna karşılık gelenler destek
  ekibi, kurulum ekibi, üçüncü taraf hizmetleri ve kullanım bazlı altyapıdır (R6 §2.5). Oyunda destek ve kurulum işini
  maaşlı Müşteri Temsilcisi yapıyor; kullanım bazlı altyapı ise sunucu faturasının içindedir (§3.2 bu yüzden fiyatı
  büyüttü). Yani kalem ya iki kez sayıyor ya da oyuncunun yönetmediği bir şeyi sayıyor.
- Yönetilebilir mi: hayır. Oyuncunun tek kolu "daha az müşteri"dir.
- Kod: `SERVICE_PER_*`, `ONBOARDING_MRR_MULT`, `SERVICE_BURN_CATEGORY` (`infra_system.gd:87-93`), `monthly_service`
  (`:267-277`), `daily_tick`'teki ikinci satır (`:349`), `gross_margin_monthly` yalnız sunucuyu düşer (`:280-282`), `BURN_IDS`'teki
  "service", `FIN_BURN_SERVICE` (`strings.csv:3016`), smoke'taki servis vakaları (`endgame_smoke.gd:2825-2860`).

### 3.4 Kalan liste
| Kalem | Ne | Oyuncunun kolu |
|---|---|---|
| Maaşlar | çalışanlar ve **kurucu satırı** ayda $1.500 [ÇALIŞMA] | işe alım, işten çıkarma, zam |
| Ek mesai | 8 saati aşan çalışma | çalışma saatleri |
| Sunucular | kapasite × kademe fiyatı | kademe, kapasite |
| Ofis | **kira** [ÇALIŞMA]: Ev $0, İş hanı $1.500, Plaza $8.000, Loft $18.000 | taşınma kararı (`office_constants.gd:16-58`) |
| Pazarlama | kampanya sürerken | kampanya kartı; ileride E |

- **Kurucu satırı neden var:** kurucu gerçekten yaşamak zorunda; Bootstrap'ın 6,7 aylık runway'ini bu satır taşır. Maaşlar
  ipucunda "Kurucu (sen) $1.500" diye yazar. Satır olmazsa tek başına kurucunun gideri sıfırdır ve runway sonsuz görünür.
- **Ofis kirası neden var:** taşınma bugün bedavadır (`office_constants.gd:6`), "Ofis" gider satırı hiç dolmaz. Kira hem
  gerçek hem yönetilebilir bir kalemdir: büyük ofise ne zaman geçileceği oyuncunun kararıdır. Ev kirası sıfırdır, çünkü
  kurucunun evi kurucu satırının içindedir.
- **Pazarlama** bugünkü kampanya kartıyla kalır; büyüme harcamasının asıl kalemi olarak E ya da sonrası açar.

### 3.5 Ekonomiye etkisi ve telafi
Hesap (tahmin): K5 kayıtlarının aylık gider dökümünde araç ve servis çıkarıldı, sunucu yeni fiyatla, kurucu satırı ve kira
(ofis çalışan sayısından: 1-11 İş hanı, 12-34 Plaza) eklendi. Bot kararları sabittir; gerçek koşu bu sayılardan sapar.
Betik: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/cv3/econ2.py`
(repoda değil).

B2B `fix_worst`, tohum 7 / 11:

| Varyant | En derin nakit açığı (hafta) | 52. hafta kümülatif net | 101. hafta kümülatif net | Evre 3 aylık net |
|---|---|---|---|---|
| Bugün | −$41K (36) / −$37K (36) | +$9K / +$43K | +$316K / +$534K | +$29K / +$44K |
| A · telafisiz | −$12K (19) / −$10K (23) | +$124K / +$162K | +$1,00M / +$1,45M | +$91K / +$117K |
| B · A ve sunucu %12 | −$12K (19) / −$11K (23) | +$110K / +$147K | +$938K / +$1,38M | +$86K / +$111K |
| **C · A ve maaş bantları ×1,5** | **−$30K (36) / −$29K (32)** | **+$34K / +$73K** | **+$752K / +$1,21M** | **+$76K / +$102K** |
| D · A ve maaş bantları ×2 | −$69K (45) / −$62K (45) | −$55K / −$16K | +$504K / +$961K | +$62K / +$88K |

B2C `fix_worst` tohum 7: bugün en derin açık −$11K (49), 101. hafta +$1,64M; A'da −$10K ve +$2,03M; C'de −$21K ve +$1,95M.
B2C ekonomisi A'dan beri gelir tarafından taşınıyor; gider değişikliği onu az oynatıyor.

Okuma:
- **Telafisiz (A)**, B2B'nin ilk yılını kökten açar: en derin açık 41 binden 12 bine iner, bu Frank'in çekiyle kapanır;
  seed'in nakit gerekçesi kalkar. CLAUDE.md §1'in "her evre runway'i yeniden daraltır" kuralı bozulur.
- **Sunucuyu bandın üstüne itmek (B)** yetmez: sunucu gelirin yüzdesi olduğu için açığı büyütmez.
- **Maaş bantları ×1,5 (C)** ilk yılın biçimini bugüne döndürür (açık 30 bin, 36. hafta). Maaş gerçek, görünür ve
  yönetilebilir kalemdir. Gerekçe: botun gelir/çalışan oranı gerçekçi (yıllık yaklaşık $170K), maaşı ise düşük; bot hep
  junior alıyor ve junior bandı ayda $1.500-3.000 (`hr_constants.gd:591-598`). Gerçek SaaS'ta maaş giderin en büyük kalemidir;
  bizde onun yerini servis tutuyordu. Kurucu satırı çarpılmaz (Bootstrap değişmez).
- **Evre 3 her varyantta gevşer** (aylık net 29 binden 76 bine, C'de). Sebep: evre 3'ü bugün görünmez "yeni hesap kurulum
  bedeli" (MRR × 3) daraltıyordu. Görünür karşılığı büyüme harcamasıdır (satışçı, pazarlama). Series A büyüme ister; büyümek
  isteyen oyuncu para harcar, harcamayan büyümez. Bu "karar kalmadı" değildir, ama bot bunu sınamaz. M11 kapısı ölçer;
  ölçüm kötü çıkarsa Erdem'e evre 3 için pazarlama (E) önerisiyle gider.
- Erdem'in sağlıklı büyüme tutumuyla birlikte: amaç oyuncuyu sıkıştırmak değil, harcamanın nedenini görünür kılmaktır. C
  varyantında ilk yıl bugünkü kadar zordur, sonrası daha rahattır.
- (inceleme) **Simülasyonun ölçümü bu tablodan biraz farklı** (`MEMNUNIYET_SIM.md` §4.1, §5.4; tahmin, bot kararları sabit).
  Fark ofis kirasından: simülasyon taşınmayı oyunun koşullarıyla (marka, nakit) yaptı, Plaza daha geç açıldı. Tohum 7 / 11:
  A en derin açık −13K (19. hf) / −12K (23. hf), 52. hafta +143K / +188K; ×1,5 −32K (36) / −30K (32), 52. hafta +54K /
  +99K, evre 3 +74K / +105K (sınır 2 × bugün: 55K / 89K). Yani ×1,5 açığın biçimini bugüne döndürür ama 52. hafta (tohum
  11) ve evre 3 kapısını tutmaz. Dört kapıyı ancak ×2,2 tutar, bedeli ilk yılın −87K / −73K'ya derinleşmesidir. Servisin
  gerçek karşılığı Müşteri Temsilcisi maaşıdır: 304 hesapta 38 temsilci ayda yaklaşık $71K (tahmin), kalkan servisin evre
  3 ortalamasıyla ($69K ile $81K) aynı büyüklük. Bu, telafiyi kural yerine oyuncu kararına bırakan seçeneğin gerekçesidir
  (Soru 1). Not: "toplam gider değişmesin" reddedildi; burada amaç toplamı korumak değil, gerçek ve yönetilebilir
  kalemlerin (maaş, temsilci) gerçekçi büyüklükte olmasıdır.

### 3.6 Simülasyona devredilen ölçütler
M11 ve M12 kapıları (§7.4): Bootstrap runway, en derin nakit açığı ve haftası, 52. hafta kümülatif net, evre 3 aylık net,
Standart'ta sunucunun gelir payı. Uygulamadan sonra bot gerçek koşuyla yeniden ölçülür (muhasebe tahmini yetmez, çünkü bot
nakde göre işe alır). VC ve yatırım masası burn ve runway okur; aynı koşu `run_gate` ile seed ve Series A günlerini de yazar.

---

## 4. C5 ek · Ürün dışı yenilememe (bütçe kesintisi)

**Erdem'in isteği:** ürüne bağlı olmayan bütçe kesintisiyle yenilememe olabilir, ama düşük ihtimalle; nedeni mailde yazar.
Genel tutum: müşteriler ayrılmasın.

- **Olasılık** [ÇALIŞMA], yenileme dönemi açılınca (bitişe 8 hafta, v2 §2.6.1) hesap başına bir kez: 1★ %2, 2★ %1,5,
  3★ %1. Dayanak: yıllık logo kaybı KOBİ %10-14, orta pazar %5-8, kurumsal %2-5; gönüllü iptal nedenlerinde
  kapanma/küçülme/bütçe payı %8 (Recurly/ChartMogul alıntısı) ile %34 (n=38) arasında
  (https://stealthagents.com/research/saas-churn-rate-statistics-2026,
  https://visionary-marketing.co.uk/blog/saas-churn-benchmarks-2026). Çarpım KOBİ'de %0,8-4,8, kurumsalda %0,2-1,7 verir;
  Erdem "düşük" dediği için bandın alt yarısı seçildi.
- **Kimde olur:** her hesapta, memnuniyetinden bağımsız. Ürünle ilgisiz olduğu için memnuniyete dokunmaz.
- **Oyuncunun yapabileceği:** memnun hesap (memnuniyeti eşiğinin en az 12 puan üstünde; v2'deki "Aynı fiyat" tutumunun
  sınırı) ayrılmak yerine koltuğunu yarıya indirip kalmayı teklif eder. Daha az memnun hesap doğrudan ayrılır. Yani zar
  ürün dışıdır, sonucun ağırlığı oyuncunun elindedir. Gerçek pratikte daralma (koltuk ya da paket azaltma) yaygındır: 38
  şirketlik çalışmada net tutmaya etkisi −10 puan (aynı Visionary sayfası).
- **Kâğıt:** teklif varsa kurucunun önüne bir kâğıt gelir (iki seçenek). Teklif yoksa yalnız mail. Satışçı yolunda satışçının
  aylık raporuna bir satır olarak girer (v2 §2.6.3).
- **Takvim:** sözleşme bitişine kadar ödeme sürer (v2). Küçülme yenilemeyle işler.
- **Ölçek:** 330 hesapta yılda yaklaşık 5 olay, yarısından fazlası küçülme (tahmin, M9 ölçer). 20 hesaplık erken şirkette
  yılda 0,3. (inceleme) Ölçüm: bakımlı üründe yılda 5,75 olay, hepsi küçülme, tam kayıp 0; bakımsız üründe tam kayıp %1,7
  (`MEMNUNIYET_SIM.md` §2.11). Erdem'in "müşteriler ayrılmasın" tutumuyla uyumlu; M9 kapısı buna göre okunur (§7.4).
- **Kayıp ekranında** ayrı neden: "Bütçe kesintisi". Neden: R9 §7 madde 8, "iyi oynadım yine de kaybettim" hissi ancak
  nedeni ürün dışı diye ayrıca yazılırsa yumuşar.

Mail (teklifli hâl):
```
Gönderen: Deniz Aras · Kuzey Lojistik
Konu: Sözleşme yenileme

Bu yıl bütçemizi küçültüyoruz ve yazılım harcamalarımızı azaltıyoruz. Karar ürününüzle
ilgili değil; ekibimiz ürünü kullanmaktan memnundu. Sözleşmemizi Mart sonunda bu hâliyle
yenilemeyeceğiz. Koltuk sayısını 60'tan 30'a indirirsek devam edebiliriz.

1  30 koltukla yenile           Aylık $2.100 → $1.050
2  Yenilememeyi kabul et        Kuzey Lojistik Mart sonunda ayrılır · aylık −$2.100
```
```
From: Deniz Aras · Kuzey Lojistik
Subject: Contract renewal

We are cutting our budget this year and spending less on software. This is not about
your product; our team liked using it. We will not renew the contract as it stands at
the end of March. We could continue if we cut our seats from 60 to 30.

1  Renew with 30 seats            Monthly $2,100 → $1,050
2  Accept that they will not renew  Kuzey Lojistik leaves at the end of March · monthly −$2,100
```
Teklifsiz hâlin son cümlesi: TR `Bu dönemde devam edemeyeceğiz. Sözleşme Mart sonunda bitiyor.` EN `We cannot continue
this year. The contract ends at the end of March.`

---

## 5. C6 · Yeni memnuniyet modeli

### 5.1 Seçim: olay defteri (R9 ailesi ii), iki uyarlamayla
R9 üç aile karşılaştırdı (§5.3):
- (i) gizli hedefe kayma: bugünkü kod. Tek "olaysız düşüş" üreten aile; imza değeri ile hedef iki ayrı yerden gelir.
  Erdem'in itirazının kendisi. **Reddedildi.**
- (iii) çapa ve olay: ürün emeğini 52 hafta bekletir; ürününü iyileştiren oyuncu "hesaplar neden aynı" der (R9 §5.2 gözlem 4).
- (ii) olay defteri: her puan tarihli bir satırdır, toplam satırların toplamıdır. Açıklaması en kolay olanı. Zayıf yanı faz
  geçişindeki uçurum (R9 gözlem 3: tek haftada −47).

**Seçim: (ii), iki uyarlamayla.**
1. **Pazar beklentisi hesaba iki anda okunur:** imzada ve yenileme dönemi açılınca. Arada ürünün kendisi değiştikçe
   (sürüm) uyum hemen değişir, ama pazarın beklentisi o hesap için sabittir. Bu, (ii)'nin faz uçurumunu kaldırır ve
   (iii)'ün tek iyi yanını alır: müşteri piyasayla kıyaslamayı yenileme masasında yapar. Gerçekte de sözleşme ortasında
   ayrılmak esaslı ihlal ister, yeniden değerlendirme yenilemededir (R7 §2.2).
2. **Uzun süre güncellenmeyen ürün** ayrı ve görünür bir satırdır (R9 §5.4). Aksi hâlde tavana çıkmış ürün sonsuza dek
   memnun tutar (R9 gözlem 5).

Neden kayma tamamen kalkıyor: kayma, değişimi olaydan ayırır. Olay bu hafta olur, düşüş gelecek hafta yazılır ve oyuncu
ikisini bağlayamaz. Startup Company'deki "fark ettiğimde çoktan kaybediyordum" şikâyeti bu türdendir (R9 §4.3,
https://steamcommunity.com/app/606800/discussions/0/1734336452589045402/). Oyunlarda ortak desen memnuniyeti nedenler
listesi olarak göstermektir (R9 §4.8: Cities: Skylines II, https://cs2.paradoxwikis.com/Happiness ; Football Manager,
https://www.fmscout.com/confidence.htm).

### 5.2 Formül
Bir B2B hesabın memnuniyeti, her tikte yeniden toplanan satırlardır:

```
Memnuniyet = Ürün uyumu
           − Açık hata terimi
           + Defter satırlarının toplamı
           + Durum terimleri
           − Güncelleme yaşı terimi              (0 ile 100 arasında kırpılır)
```

| Terim | Tanım | Ne zaman değişir | Neden var |
|---|---|---|---|
| Ürün uyumu | U(hesap), `KALITE_v2.md` §3; pazar beklentisi hesabın referans anındaki değer | sürümde alan seviyesi değişince; yenileme dönemi açılınca | Hesap ürünün ona uyduğu kadar memnundur. |
| Açık hata terimi | min(3 × H, 60) [ÇALIŞMA]; H = Σ alan ağırlığı × (alandaki açık hata ÷ alandaki canlı hat); canlı hattı olmayan alan atlanır, ağırlıklar yeniden ölçeklenir | sprint kapanışında hata düşünce ya da düzeltilince | Bozuk ürün memnuniyetsizliktir; yoğunluk olduğu için ekip ve ürün büyüklüğünden bağımsız (Erdem'in D5 kararıyla aynı ölçü). |
| Defter satırları | adlı olaylar, §5.3 | olay anında; olumsuz satır adı yazan süreyle söner | Söz, kesinti, istek, ertelenen hata kalıcı ve okunur iz bırakır. |
| Durum terimleri | indirim +8, zam −2, gönülsüz yenileme −6 (yenilemeye kadar), kurumsal madde −10 (madde açık ve hak saklıyken) | olayın kendisiyle | Fiyat ve sözleşme şartı ilişkiyi sözleşme dönemi boyunca etkiler (v2 §2.3, §2.6.1). |
| Güncelleme yaşı | §5.5 | ayda bir adım, güncellemeyle sıfır | Ürünü bırakılan müşteri unutulmuş hisseder (R9 §3.1). |

- **Kayma yok.** Memnuniyet hedefe yürümez; terimler değiştiği tikte değişir.
- **Açık hata terimi neden 3 ve 60:** `fix_worst` geç dönemde canlı hat başına yaklaşık 1,2 açık hata taşır, terim −4; hiç
  düzeltmeyen kol 60. haftada hat başına 18'dir, terim tavana dayanır (K5 kayıtları, `open_bugs` 11 ve 167, 9 hat). Arada
  kalan oyuncu (hat başına 5-7) −15 ile −21 alır: hesabı kaybetmez, yenilemede indirim ister (v2 §2.5.2'nin niyeti).
  Tavan 40'tan 60'a çıktı, çünkü ürün uyumu artık 100'e kadar çıkabilir. Hiç düzeltilmeyen üründe en iyi uyumdaki hesap
  (100 − 60 = 40) sözleşme ortasında en seçici eşiğin (38) hemen üstünde kalır, uyumu 85'in altındaki her hesap eşiğin altına
  iner; yenilemede pazarla yeniden okununca en iyisi de kaybedilir.
- (inceleme) **M5 kaldı:** hiç düzeltmeyen kolda geç kayıp %1,4 / %6,9 (hedef ≥ %10). Neden: botun ürünü U = 100'de doyuyor,
  100 − 60 = 40 her eşiğin (30 ile 38) üstünde. Simülasyonun önerisi tavan 64 (kayıp %35 / %59; 62'de %13 / %12); düzelten
  kollar değişmiyor (`MEMNUNIYET_SIM.md` §5.1). Tavan şimdilik 60 kalır: sonuç bir eşik bandına yaslanan uçurumdur ve asıl
  neden U doyumudur (`KALITE_v2.md` §3.5). Tavan, beklenti tablosunun kalibrasyonundan sonra yeniden ölçülür.
- **Ölçek:** her terim oran ya da olay başınadır. 1 hesapta da 330 hesapta da, 3 kişide de 50 kişide de aynı çalışır. D'nin
  50 kişilik düzenli düzelten ekibi 17 açık hata ile hat başına 2'nin altındadır (`D_MODEL_v3.md` §4.2; inceleme, taslakta
  v2'nin 19'u): −6.

### 5.3 Defter satırları
Tutarlar [ÇALIŞMA]. "Kalıcı" satırlar olumludur ve toplamları en çok +10'dur (bugünkü `TRUST_OFFSET_MAX`,
`b2b_constants.gd:267`). Olumsuz satır, yazdığı süre boyunca doğrusal söner (affedilir); sönen satır listeden düşer.

| Olay | Satır | Süre | Bugün |
|---|---|---|---|
| Söz zamanında tutuldu | +6 | kalıcı | hedefe +6, 2 haftada söner, ayrıca anlık +15 |
| Söz geç tutuldu | −3 | 8 hafta | hedefe −2, 1 haftada söner, ve anlık −5 |
| Söz tutulmadı | −12 | 13 hafta | −12, 4,3 haftada söner, ayrıca anlık −20 |
| İsteği yayına girdi | +4 | kalıcı | etkisi yok |
| Kesinti (B) | B'nin sayısı: saat × 0,6, en çok −8 | 13 hafta | aynı sayı, en çok 3 haftada söner |
| Ertelenen hata (B "sonraki sprinte bırak") | B'nin sayıları: −6, düzelene kadar her sprint sonunda −3 | her biri 8 hafta | aynı sayılar, defterde söner |
| Olay kartının `satisfaction_delta`'sı | kartın sayısı | 8 hafta | bir tikte silinir (15 kart) |

- **Sahip etkisi:** olumsuz satırın süresi hesabın sahibinin Müşteri İlişkileri çıktısıyla kısalır: süre × `cs_dampen`
  (0,4 ile 1,0, `b2b_constants.gd:184-190`). İpucu satırın yanına kalan süreyi yazar. Neden: bugün sahip aşınmayı
  yavaşlatıyor; aşınma kalkınca sahibin değeri "ilgilenilen hesap daha çabuk affeder" olur. Aynı sayı, görünür etki.
- **Neden olumlu satır sönmez:** sönen olumlu satır, olaysız bir düşüştür. Tavan (+10) şişmeyi sınırlar.
- **Neden olumsuz satır söner:** Erdem'in "ertelemeyi alışkanlık yapan kaybeder, bir kez erteleyen kaybetmez" (B Karar 8)
  ilkesi. Sönme yukarı yöndür; Erdem'in itirazı nedensiz düşüşe.
- **Tutma kartları:** "İndirim ver" yenilemeye kadar +8 durum terimi yazar (kalıcı tavana sayılmaz; fiyattır, iyi niyet değil).
  "Söz ver" puan yazmaz; risk sayacı durur ve söz süresince hesap Risk'e yeniden girmez. "Oyala" değişmez.

### 5.4 İmza
- **İmza değeri gerçektir:** imza anında aynı formül, defter boş ve güncelleme yaşı 0. Beklentiyi karşılayan, hatası az
  üründe 65-70; beklentiyi aşan üründe 70'in üstü. Erdem'in kararı: "direkt o şekilde başlasın".
- **İmza kapısı** [ÇALIŞMA]: aday, imzada memnuniyeti kendi ayrılma eşiğinin en az 10 puan üstünde olmayacaksa imzalamaz.
  Görüşme ya da temsilcinin kapanışı bu nedenle kaybedilir ve kayıp nedeni hesabın en çok baktığı zayıf alanı söyler
  (`KALITE_v2.md` §6). Neden: kapı olmazsa zayıf ürün imzaladığı hesabı ilk hafta "Ayrılabilir" yazar; gerçekte de ürüne
  uymayan müşteri satın almaz. v2'nin "70 tabanı"na gerek bırakmayan kural budur.
- İmza maili ve ipucu değeri satırlarıyla yazar:

| | TR | EN |
|---|---|---|
| İmza satırı | `Memnuniyet 68 ile başlıyor: ürün uyumu 72, açık hata −4.` | `Satisfaction starts at 68: product fit 72, open bugs −4.` |
| Kayıp nedeni | `Entegrasyonlar sizde henüz zayıf. O taraf güçlenince yeniden konuşalım.` | `Your Integrations are still weak. Let us talk again once they are stronger.` |

### 5.5 Uzun süre güncelleme almama
- **Ölçü:** hesabın baktığı alanlara (Çekirdek ve sektörünün iki vurgu alanı, `KALITE_v2.md` §2) dokunan son yayından bu
  yana geçen hafta. Dokunmak: o alanların bir hattında yayına giren herhangi bir kart (kademe, cila, istek, hata düzeltme).
  Sayaç imzadan ya da son dokunuştan başlar.
- **Terim** [ÇALIŞMA]: 26 haftaya kadar 0; sonra her tam 4 haftada −1; en çok −12 (74. haftada). Dokunan ilk yayın terimi
  sıfırlar ve defterde bir kez yazar.
- **Neden 26:** bot ortalama 1,3 haftada bir sürüm çıkarıyor (`fix_worst_7`: 104 haftada 83 sürüm). 26 hafta, çalışan bir
  ekibin asla görmeyeceği, ürünü bırakan ekibin mutlaka göreceği uzunluktur. R9'un simülasyonu da 26/4/15 kullandı; tavan
  bir eşik basamağından küçük kalsın diye 12'ye indi.
- **Neden "dokunan her kart":** yalnız kademe sayılsaydı, Erken Erişim'de bütün alanlar en üst kademeye çıkınca herkes
  cezalanırdı (R9 §5.4). Hata düzeltmesi de güncellemedir.
- **Gösterim:** sayaç 20. haftadan itibaren ipucunda yazar, terim başlamadan 6 hafta önce. Genel Bakış'ın Sürüm bloğu
  "Son sürüm 3 hafta önce" yazar (v2 §2.1).

| Durum | TR | EN |
|---|---|---|
| Uyarı (20.-26. hafta) | `Son güncelleme 22 hafta önce. 26 haftadan sonra her ay 1 puan düşer.` | `Last update 22 weeks ago. After 26 weeks it drops 1 point a month.` |
| Terim işlerken | `Son güncelleme 34 hafta önce  −2` | `Last update 34 weeks ago  −2` |
| Sıfırlanınca (defter) | `v3.2 yayınlandı; güncelleme bekleyişi bitti  +2` | `v3.2 shipped; the wait for an update is over  +2` |

### 5.6 Ürün uyumu nerede okunur
- **İmza:** adayın U'su bugünkü pazar beklentisiyle (rakip çıkışı dahil) okunur ve imza kapısına girer.
- **Sözleşme süresince:** hesabın U'su, alan seviyeleri bugünkü, beklenti hesabın referansındaki değerle okunur. Ürün
  iyileşince hemen yükselir, pazar yükselince bu hesap için değişmez.
- **Yenileme dönemi açılınca** (bitişe 8 hafta): referans bugünkü pazar beklentisine güncellenir. Değişim defterde adıyla
  yazar ve tutum (v2 §2.6.1) bu değerle okunur. Oyuncu bunu önceden görür: ipucu son satırında "Bugünkü pazar
  beklentisiyle ürün uyumu 58; yenilemede bu okunur" yazar (fark 3 puandan büyükse).
- **Geride kalma** ayrı bir terim değildir. Pazarın gerisinde kalan ürün bunu yenilemede yaşar; arada sürüm çıkarmayan
  ürün güncelleme yaşı terimiyle yaşar.
- Rakip çıkışı yalnız adayın U'sunu etkiler (`KALITE_v2.md` §3.3). Sözleşmeli hesap rakibi yenilemede görür.

### 5.7 Eski parçalar: tut, değiştir, sil
| Parça | Karar | Neden |
|---|---|---|
| Kayma (`SAT_DRIFT_STEP`, `ONBOARDING_AMP`, `_drift`; `b2b_constants.gd:30-31`, `b2b_sales_system.gd:87-125`) | **Sil** | Nedensiz düşüşün kaynağı. |
| Gizli Kararlılık hedefi (`_target_on`, `:140-153`) | **Sil** | Görünmez model (Q1). Yerine U. |
| İmza değeri "eşik + 10, en az 50" (`sales_system.gd:367-368`, `b2b_constants.gd:19-20`) ve eksen tohumu (`sales_system.gd:415-419`) | **Sil** | İmza gerçek değerle açılır. |
| Onboarding tabanı (`ONBOARDING_GRACE_*`, `b2b_constants.gd:15-16`; `onboarding_floor_until`, `onboarding_ends_under_bar`) ve v2'nin 70 tabanı ile sönümü | **Sil** | Kayma yokken taban gerekmez; imza kapısı ilk haftayı korur. |
| Hata cezası (`B2B_BUG_SAT_PER` 0,3, `CAP` 20, `:58-59`; v2: 40) | **Değiştir** | Adet yerine canlı hat başına yoğunluk, katsayı 3, tavan 60. Hangi hesabın hangi hatayı saydığı eksen üyeliği yerine alan ağırlığıyla (`account_bugs`, `:162-169`). |
| Ayrılma eşiği 30 + 3 × (yıldız − 1) + sektör ekinin yarısı (v2) | **Tut** | Ürün uyumu beklentide 70 iken eşiğe 32-40 puan pay bırakır. Eşiğin söz cırcırı (+5, en çok +10) kalır ve ipucunda nedeniyle yazar. |
| Güven defteri (`trust_offset`, tek sayı, günde 0,4 affeder) | **Değiştir** | Adlı satır listesi; her satır kendi süresiyle. Tek sayı ipucunda neden söyleyemez. |
| B'nin çipleri ("Ege Sigorta: memnuniyet 38 → 35") | **Tut** | Kaynak fonksiyon değişir: "bir tik sonra" yerine satır eklenmiş hâlin toplamı. Sayı artık bir tik sonra değil hemen doğrudur. |
| B'nin kalıcı izi (`trust_drains`, `b2b_sales_system.gd:188-209`) | **Tut** | Sayılar aynı, deftere satır olarak yazar. |
| Anlık memnuniyet sıçramaları (`PROMISE_KEPT_SAT` +15, `PROMISE_BROKEN_SAT` −20, `PROMISE_PARTIAL_SAT`, `RETAIN_SAT_BUMP` +8) | **Sil** | Toplam formülde "şimdiki değer" yoktur; etkileri §5.3'teki satırlardır. |
| Sahip etkisi (`cs_dampen`, huy `satisfaction_bonus`) | **Değiştir** | Aşınmayı yavaşlatmak yerine olumsuz satırın süresini kısaltır. |
| Risk makinesi (eşik altı 1 hafta, 2 haftalık sayaç, 3 haftalık yeniden giriş) | **Tut** | Ayrılma hep görünür sayaçla olur. |

### 5.8 İpucu
```
Memnuniyet 61 · ayrılma eşiği 36                                   Satisfaction 61 · leaves under 36
  Ürün uyumu (Çekirdek Yeterli, Entegrasyonlar Zayıf)   66        Product fit (Core Solid, Integrations Weak)   66
  Açık hata (baktığı alanlarda 9)                        −4        Open bugs (9 in the areas it uses)            −4
  Kesinti 12 Mar, 5 saat                                 −2        Outage 12 Mar, 5 hours                        −2
      9 Nis'te silinir                                                 gone by 9 Apr
  Söz tutuldu: Stok Sayacı                               +4        Promise kept: Stock Count                     +4
  Son güncelleme 3 hafta önce                             0        Last update 3 weeks ago                        0
Bugünkü pazar beklentisiyle ürün uyumu 58;                         Against today's market, product fit is 58;
yenilemede bu okunur.                                              the renewal reads this.
```
- Terim listesi tek fonksiyondan gelir (`KALITE_v2.md` §5.2 sözleşmesi); ekran kendi hesabını yapmaz.
- Sıfır olan terim çizilmez; güncelleme yaşı yalnız 20. haftadan sonra çizilir. Örnekteki 0 satırı yalnız gösterim içindir.
- "Kurumsal sunucu maddesi −10" yalnız hakkı saklı tutan hesapta (v2 §2.3). "Zam −2" ve "Gönülsüz yenileme −6" bir
  sonraki yenilemeye kadar (v2 §2.6.1).

### 5.9 Uzun koşuda riskler (Erken Erişim, yıllar)
- **Donma:** bütün alanlar en üst kademede ve pazar beklentisi alanın tavanında olunca U 70'te sabitlenir. Memnuniyeti
  bundan sonra hata, olay ve güncelleme yaşı oynatır. Hata düzeltmesi yaşı sıfırladığı için çalışan ekip donmaz. Yeni
  kademe içeriği EA'nın konusudur (X §9; bu belge çözmez).
- **Sonsuz memnuniyet:** olumlu satır tavanı +10; U en çok 100; yenileme pazarla yeniden okur. Bakımlı ürünün hesapları
  çoğunlukla "Zamma açık" olur; bu sağlıklı büyümenin ödülüdür (Erdem'in tutumu). Yenilemeyi anlamlı tutan başka kanallar:
  pazar beklentisi, bütçe kesintisi, fiyat basamakları.
- **İstismar:** (1) Yenileme öncesi tek büyük sürüm: U sürekli okunduğu için ayrı bir pencere yok; yenileme bugünkü ürünü
  okur, bu doğru davranıştır. (2) Söz yağdırma: söz hesabın isteğinden doğar ve aralıklıdır; olumlu tavan +10. (3) İndirim:
  hesap başına 2 kez (bugünkü kural). (4) Kapasiteyi gece zarından önce düşürmek: zar oyuncuya önceden görünmez, kazancı yok.
- **Defterin büyümesi:** sönen satır silinir, kalıcılar tek "Tutulan sözler ve istekler" satırında birleşebilir; hesap
  başına en çok 6-8 satır. 330 hesapta tik başına toplama ucuzdur.
- **`satisfaction_delta` kartları sertleşir:** bugün bir tikte silinen 15 kartın sayısı artık 8 hafta kalır. B'nin ve
  içeriğin ayarı M13 ile ölçülür.
- **Risk sayacı ve olaylar:** kayma yokken bir kesinti, eşiğe yakın hesabı aynı hafta Risk'e sokabilir. Sayaç 2 hafta
  olduğu için oyuncunun düzeltme zamanı vardır.

### 5.10 Kod değişiklik haritası
| Gider | Gelir |
|---|---|
| `B2BSalesSystem._tick_satisfaction`, `_drift`, `satisfaction_target`, `_target_on`, `_forgiven_trust`, `onboarding_floor_until`, `onboarding_ends_under_bar`, `satisfaction_next_tick` | `B2BSatisfaction.terms(c) -> Array` ({etiket, değer, not}), `B2BSatisfaction.total(c) -> int`, `B2BSatisfaction.preview(c, satır) -> int`; her tik `CustomerRegistry.set_satisfaction(c.id, total(c))` (sinyal sözleşmesi aynı) |
| `Customer.trust_offset` (`customer.gd:61`), `CustomerRegistry.set_trust_offset`, `TRUST_OFFSET_DECAY_PER_DAY` | `Customer.ledger: Array` ({tür, tutar, gün, hafta, ad argümanları}), `Customer.market_ref: Dictionary` (alan → beklenti), `Customer.last_touch_day`; seam `CustomerRegistry.add_ledger_entry`; şema 17 → 18, göç: `trust_offset` 4 haftalık tek satır olur |
| `SalesSystem.signing_satisfaction_seed` (`sales_system.gd:415`), imza tabanı (`:367-368`) | imza `total(c)`; imza kapısı `SalesFinalizer` ve `SalesRepSystem`'in kapanışında |
| `B2B_BUG_SAT_PER`, `B2B_BUG_SAT_CAP`, `account_bugs`'ın eksen üyeliği | `B2BSatisfaction.bug_term(c)` (alan ağırlığı × hat başına yoğunluk), sabitler `B2BConstants` |
| anlık sıçramalar (`_recover`'ın puanı, söz tutarları) | §5.3 satırları; `_recover` yalnız risk makinesini sıfırlar |
| `IncidentSystem._trust_rows` ve `EvEffects` `trust_delta` / `satisfaction_delta` (`effects.gd:416-430`, `:621`) | aynı tutarlar `add_ledger_entry` ile; çip `preview` okur |
| (yeni) | `B2BSatisfaction.update_age_term(c)`, yenileme dönemi açılınca `market_ref` güncellemesi, bütçe kesintisi zarı (`RngStreams`'te ayrı akış) |

---

## 6. v2'nin değişmeyen kısımları
- **C2 kesinti çarpanı:** 1,0 / 0,5 / 0,25 (Erdem'in kararı; v2 §2.2.5 tablosu ve gerekçesi).
- **C4 Kurumsal madde:** v2 §2.3 olduğu gibi (8 hafta, 20 puan kuralı, 4 haftalık bildirim, saklı hakta −10, geçiş
  bildirimi geri aldırır, mailler). Erdem'in kararı. v2'nin "8. haftada memnuniyet 60" örneği artık gerçek değerden okunur.
- **C5 yenileme ana akışı:** v2 §2.6 olduğu gibi (tutum bantları, basamaklar, satışçı raporu, kurucunun mail teklifi, tek
  karşı teklif turu, saat yok, cevapsız kâğıt aynı fiyat). Erdem'in kararı. Ek kanal §4.
  (inceleme) Akış aynı kalır, ama tutum bantlarının sayıları (≥ 25 Zamma açık ...) yeni memnuniyet dağılımına göre yeniden
  ölçülmeli [ÇALIŞMA]: bakımlı üründe yenilemede fark 53 ile 72, tutumun %100'ü "Zamma açık", kâğıt hiç gelmiyor ve her
  yenileme %8 zamla kapanıyor (`MEMNUNIYET_SIM.md` §2.10). Bu, CLAUDE.md §1'in "kasa artıyor, karar kalmadı" uyarısına
  yakındır. Önce U kalibre edilir (`KALITE_v2.md` §8), sonra bantlar ölçülür; örnek seçenek Zamma açık ≥ 45 (Soru 5).
- **HESAPLAR tablosu:** v2 §2.4 (sütunlar, sıralama, dört görünüm, arama, Durum etiketleri, aylık para hücresi).
- **Haftalık destek raporu ve "Yetişemedim" tanımı:** v2 §2.7.
- **Gelir gösterimi, "Onboarding" adları, rakip kapsam dışı:** v2 §2.8 - §2.10. v2 §2.9'daki "Yeni müşteri: en az 70"
  satırı kalktı (§5.7).
- **Genel Bakış:** v2 §2.1. Q2'ye göre Destek bloğunun başlığı "Kararlılık" olur: `Kararlılık · 7 açık hata ▲2 · son 4
  haftada 1 kesinti` (EN `Stability · 7 open bugs ▲2 · 1 outage in the last 4 weeks`). Sürüm bloğu `KALITE_v2.md` §5.1'in
  durum satırlarını çizer.
- **Ekranlar:** Erdem D6'da Claude Design maketi yerine oyunun kendi arayüzünü (Menajer, `docs/mockups/menajer/`) istedi.
  Öneri: C'nin ekranları da aynı yolla gösterilir. v2 §5'in ekran listesi içerik olarak geçerli.
- **v2'den kalkanlar:** S2 kendiliğinden ölçekleme (§2), servis gideri bölüşümü ve "toplam gider aynı" (§3), 70 başlangıcı,
  70 tabanı, sönüm ve 20 → 40 tavanı (§5), v2 Soru 5'in "şimdilik hayır" önerisi (§4).

---

## 7. Simülasyon tanımı
Amaç: kodlamadan önce modelin şeklini ve kapılarını ölçmek. Yalnız Python (`python -I`), standart kitaplık.

### 7.1 Memnuniyet modeli
Hafta adımlı, hesap başına.

Girdiler:
- **Hesaplar:** imza haftası, yıldız, sektör ve aylık ücret K5 kayıtlarının `PROBE SIGN` satırlarından (`star=`, `mrr=`; sektör
  `PROBE CUST`'tan değil tohumlu rastgele, KALITE_v2 §2 tablosundan). Ayrıca tek hesaplı sentetik senaryolar.
- **Ürün:** alan seviyeleri haftaya göre. Bot kolları için R9 §5.1'in A (düzenli), B (donmuş), C (hızlı, özensiz), D
  (40. haftada durur, 120'de döner) şekilleri, dört alana ayrılmış: Çekirdek 5 hat, Güven 2, Entegrasyonlar 1, Onboarding 1.
- **Açık hata:** K5 kayıtlarının `PROBE STATE` `open_bugs` serisi (kollar `fix_none`, `fix_worst`, `fix_due`, `fix_off`),
  alanlara canlı hat sayısıyla orantılı dağıtılır. Canlı hat sayısı ürün şekline göre.
- **Kesinti:** B'nin formülü, hafta başına p = 0,10 × kademe × yük çarpanı × (1 + min(açık hata, 12) ÷ 8), en çok 0,30, iki
  olay arası en az 4 hafta, v1.0'dan sonra ilk 3 hafta yok (`incident_system.gd:8`, `sprint.json:42-43`). Süre 3-8 saat
  tekdüze [varsayım], tutar saat × 0,6, en çok 8.
- **Söz:** S5/S6 senaryolarında 20. haftada bir söz, 2 hafta süre.

Hesap, her hafta ve her hesap için:
1. r_a = min(seviye_a ÷ beklenti_ref_a, 1,5); U = min(100, 70 × min(Σ w_a r_a, r_Çekirdek + 0,25)) (`KALITE_v2.md` §3).
2. H = Σ w_a × (açık_a ÷ canlı_hat_a); hata = min(3 × H, 60).
3. defter = Σ olumsuz satır × max(0, 1 − geçen ÷ (süre × sahip_katsayısı)) + min(10, Σ olumlu kalıcı).
4. yaş = son dokunuştan geçen hafta W; terim = 0 (W ≤ 26), değilse min(12, ⌊(W − 26) ÷ 4⌋).
5. S = clamp(U − hata + defter + durum − yaş, 0, 100).
6. Risk: S < eşik bir hafta → Risk, 2 haftalık sayaç, S ≥ eşik olunca sayaç kalkar, 3 hafta yeniden girmez; sayaç biterse ayrılır.
7. Yenileme (imzadan 52 hafta sonra, dönem 8 hafta önce açılır): beklenti_ref = bugünkü; bütçe zarı; tutum v2 bantları;
   bot satışçı raporunda 1. seçeneği seçer.
8. Eski model kolu: aynı girdilerle bugünkü formül (gizli eksen yerine aynı U, hedefe günde 3 kayma, ilk 4 hafta ×1,5, taban
   eşik + 2, imza max(eşik + 10, 50), defter günde 0,4 affeder, ceza 0,3 × adet en çok 20).

"Adlı olay" tanımı (M1 için): o hafta sürüm (seviye değişimi), hata sayısı değişimi, kesinti, söz sonucu, istek teslimi,
yenileme dönemi açılışı, güncelleme yaşı adımı, durum terimi değişimi.

### 7.2 Ekonomi modeli
- K5 kayıtlarının `PROBE MONTH_BURN` aylık dökümü üstüne muhasebe (§3.5'in betiği): araç ve servis çıkar; sunucu ×
  (yeni Standart ÷ eski Standart); kurucu satırı $1.500; kira ofisi çalışan sayısından; maaş × bant çarpanı.
- Çıktılar: Bootstrap runway (tek kurucu), en derin kümülatif açık ve haftası, 52. ve 101. hafta kümülatif net, evre
  başına aylık net ortalaması, Standart'ta sunucunun gelir payı.
- Uygulamadan sonra aynı ölçütler bot gerçek koşusuyla (`--run-log=full_run_fix_worst:730:sim`, tohum 7 ve 11) yeniden alınır.

### 7.3 Sabitler ve kodda yerleri
| Sabit | Değer | Yeri (bugün ya da yeni) |
|---|---|---|
| Alan ağırlıkları, tavan payı, beklenti | KALITE_v2 §2-3 | yeni, `sprint.json` alan bloğu |
| Hata katsayısı, tavan | 3, 60 | `b2b_constants.gd:58-59` yerine |
| Olumlu tavan | +10 | `b2b_constants.gd:267` |
| Defter tutarları ve süreleri | §5.3 | `b2b_constants.gd:139-142`, `:263-268` yerine |
| Kesinti satırı | saat × 0,6, en çok 8 | `sprint.json:48` (B) |
| Güncelleme yaşı | 26 / 4 / −1 / −12 | yeni, `B2BConstants` |
| İmza payı | 10 | `b2b_constants.gd:19-20` yerine |
| Eşik | 30 / 3 / sektör ÷ 2 | `b2b_constants.gd:39-45` |
| Bütçe kesintisi | %2 / %1,5 / %1; küçülme eşiği eşik + 12; ×0,5 koltuk | yeni, `B2BConstants` |
| Sunucu fiyatı | §3.2 | `infra_system.gd:26`, `:28` |
| Yük basamakları | 0,90 → 1,5; 1,00 → 2,5 | yeni, `InfraSystem` |
| Kapasite adımı | %10, en az 1 birim | `infra_system.gd:50` yerine |
| Kademe çarpanı | 1,0 / 0,5 / 0,25 | `sprint.json:42` (B) |
| Kurucu satırı | $1.500 | `finance_system.gd:13` yerine, `FinanceSystem` |
| Ofis kirası | 0 / 1.500 / 8.000 / 18.000 | `office_constants.gd:16-58`, yeni `rent` alanı |
| Maaş bandı çarpanı | ×1,5 (Soru 1) | `hr_constants.gd:591-598` |

### 7.4 Senaryolar ve kapılar
Her kapı tek turdur. Ölçüm kötü çıkarsa değer değiştirilmez, rapor Erdem'e gider (v2 §4 kuralı).

| Ad | Senaryo | Hedef | Neden |
|---|---|---|---|
| M1 Nedensiz düşüş | bütün senaryolar, bütün hesaplar | adlı olay olmayan haftada 1 puan ya da fazla düşüş: 0 (eski kolda sayılır ve yazılır) | Erdem'in C6 kuralı |
| M2 İlk 12 hafta | her imza haftası, olay yok (hata sabit) | memnuniyet imza değerinin altına inmez; imza değeri eşiğin en az 10 üstünde | "70'ten başlayıp 45'e düşmesin" |
| M3 Hatasını düzelten | `fix_due` | geç dönem (53-104) kaybı ≤ `fix_off` + 2 puan | düzenli bakım cezasız |
| M4 En kötüyü düzelten | `fix_worst` | geç kaybı ≤ `fix_off` + 3 puan; toplam ≤ `fix_off` + 10 (A'nın kapısı) | A'nın hedefi korunur |
| M5 Hiç düzeltmeyen | `fix_none` | geç kaybı hesapların ≥ %10'u ve ≥ 2 × `fix_off` | hata bedeli yaşıyor |
| M6 Söz | tek hesap, 20. hafta söz; tutulan ve tutulmayan; eşiğe uzaklık 8 ve 20 | tutulmayan: uzaklık 8'de Risk, 20'de değil; iz 13 haftada kalkar; temsilcili hesapta en az %20 kısa. Tutulan: +6 kalıcı | söz kalıcı ve okunur |
| M7 Kesinti kademesi | 104 hafta × 2.000 koşu; üç kademe × yük %70 / %95 / %105; az hata ve tavanda hata | kademe başına olay her basamakta ≥ %25 az; Kurumsal ≥ 4 olay (inceleme: yalnız tavanda hata satırında, bilgi); yük %95 ≥ 1,3 × yük %70 (Ekonomik, az hata) | Erdem'in çarpanı ve yükün görünür etkisi. (inceleme) Kaldı; kademe çarpanı tavandan sonra uygulanınca 9 / 9 geçer (§2.6) |
| M8 Güncellenmeyen ürün | tek hesap, ürün 30. haftada donar; 26, 52, 104 hafta | 26: 0 düşüş; 52: −6; tavan −12; 52 haftada hesap kaybı 0 (eşik ≤ 38). Yenilemede donmuş ürünün tutumu en az iki basamak iner (beklenti yükseldiyse) | ceza var ama yumuşak; asıl bedel yenilemede |
| M9 Bütçe kesintisi | 330 hesap, 3 yıl, `fix_worst` | (inceleme) ürün dışı tam kayıp yılda hesapların ≤ %1,5'i (taslakta %0,5-1,5); olayların ≥ yarısı küçülmeyle kalır | düşük ihtimal, memnun hesap kalır. Alt sınır kalktı: bakımlı üründe tam kayıp 0, Erdem'in "müşteriler ayrılmasın" tutumunun sonucudur, kusur değil |
| M10 İmza kapısı | `fix_worst`, MVP sonrası 26 hafta | imza sayısı bugünün ≥ %80'i; kapının reddettiği aday payı yazılır | kapı ekonomiyi boğmasın |
| M11 Gider ve runway | B2B ve B2C `fix_worst`, tohum 7 ve 11, Soru 1'in seçilen varyantı | Bootstrap tek kurucu runway 6,7 ay; B2B en derin açık ≥ $25K ve 30. haftadan sonra; 52. hafta kümülatif net ≤ $80K; evre 3 aylık net ≤ 2 × bugünkü | CLAUDE.md §1 |
| M12 Fatura | aynı koşular | Standart'ta 26-104. haftalarda sunucu B2B gelirin %8-12'si; Ekonomik yaklaşık yarısı, Kurumsal yaklaşık iki katı | Erdem'in %8-15 bandı |
| M13 Eski modelle karşılaştırma | aynı girdiler, iki model | kayıp sayısı kol başına; ortalama memnuniyet; M1 sayısı; `satisfaction_delta` kartlarının ortalama izi | değişimin bedeli görünür olsun |

---

## 8. Faz B'ye not (gönderilmeye hazır)
B'nin dosyalarına dokunulmadı. Erdem gönderme iznini verdi; metin:

> C v3'ten ve D v3'ten B'yi etkileyen yedi şey var, hepsi Erdem'in onayını bekliyor (kademe çarpanının değerleri 1,0 / 0,5 /
> 0,25 Erdem'in kararıdır ve daha önce iletildi; 5. madde yalnız uygulama sırasıdır).
> 1. Doluluk çarpanı: `IncidentSystem.load_mult()` C'de `InfraSystem.outage_load_mult()` olur: yük %90'a kadar 1,0,
>    %90-100 arası 1,5, üstü ya da kapasitesiz canlı ürün 2,5. Yalnız kesinti türüne. `p_max` 0,30 kalır. Yük sebep cümlesi
>    ("Sunucular kapasitenin sınırındaydı") yalnız yük %90'ın üstündeyken yazılabilir.
> 2. Kapasite artık oyuncuda; sürümde kendiliğinden büyüme (`sprint_bridges.gd:64`) silinecek.
> 3. Memnuniyet kayması kalkıyor. `trust_offset` tek sayı yerine adlı satırlar defteri olacak. B'nin sayıları (kesinti saat
>    × 0,6 en çok 8; ertelenen hata −6 ve sprint başına −3) aynı kalır; satırlar 13 ve 8 haftada söner. Çip "bir tik sonra"
>    yerine satır eklenmiş hâlin toplamını okur, sayı hemen doğrudur.
> 4. `satisfaction_delta` fiili artık 8 hafta kalan bir satır yazar; bugün bir tikte siliniyor. Bu fiili kullanan 15 kartın
>    etkisi büyür, B'nin ölçümünde not edilmeli. Ölçüm: olumsuz kartın izi 1,1 haftadan 4,9 haftaya uzuyor (yaklaşık 4,5 kat).
> 5. (inceleme) Kesinti olasılığında kademe çarpanı `p_max`'tan sonra uygulanmalı: p = en küçüğü (0,10 × yük × hata;
>    0,30) × kademe (`incident_system.gd:48-53`). Bugünkü sıra yük ve hata yüksekken Ekonomik ile Standart'ı aynı tavana
>    dayatıyor ve 1,0 / 0,5 / 0,25 kararı 9 durumun 3'ünde bozuluyor; yeni sırayla 9 / 9 (`MEMNUNIYET_SIM.md` §5.2).
> 6. (inceleme) Karar 8'in "haftada yaklaşık 3 puan affedilir" kuralı defterde "8 haftada doğrusal söner" olur (−6 satırı
>    haftada 0,75 söner); tutarlar aynı. Bir kez ertelenen hata hesabı kaybettirmez; bu sonuç Karar 8'in niyetidir.
> 7. (inceleme) D v3'ün B'ye üç notu aynı mesajla gider (`D_MODEL_v3.md` §5 B): "Testi kısalt" çipi yüzde yazmaz ("Hesap
>    Planı'nın testi yarıya iner"), "sürüm sonrası bozulma" ihtimali o sürümle yazılan kaçan ve gönderilen hatayı okur,
>    gönder sorusu Karar 12'nin sırasının en altındadır.

---

## Erdem'e sorular

1. **Giderler.** "Geçim ve araçlar" ile "Servis maliyeti" kalksın; yerine kurucu satırı ($1.500, Maaşlar'da), ofis kirası
   (İş hanı $1.500, Plaza $8.000, Loft $18.000) ve sunucu Standart'ta gelirin yaklaşık %9'u gelsin. Servis bugün bütün
   giderin yarısı olduğu için telafisiz kalırsa ilk yılın nakit açığı 41 binden 12 bine iner ve seed'in gerekçesi kalkar.
   **Öneri:** telafi maaş bantlarıyla olsun, bantlar ×1,5 (junior geliştirici $3.000-4.500). Böylece ilk yılın biçimi bugünkü
   gibi kalır, sonrası biraz rahatlar. Alternatif: telafisiz bırakmak ve ölçmek.
   (inceleme) Ölçüm (tahmin): ×1,5 ilk yılın açığını bugüne döndürür (−32K / −30K, 36. ve 32. hafta) ama 52. hafta ve evre 3
   bugünkünden rahat kalır (evre 3 aylık net +74K / +105K, bugün +27K / +45K). Dört gider kapısını ancak ×2,2 tutar, ilk yılı
   −87K'ya derinleştirerek. Üçüncü yol: telafisiz bırakıp büyüyen hesap defterinin işini görünür Müşteri Temsilcisi maaşına
   bağlamak (304 hesapta 38 temsilci, ayda yaklaşık $71K). Öneri değişmez: ×1,5, evre 3'ün gevşemesi E'nin pazarlama
   harcamasıyla karşılanır ve uygulamadan sonra gerçek bot koşusuyla yeniden ölçülür.
2. **Memnuniyet modeli.** Memnuniyet ipucundaki satırların toplamı olsun; kayma olmasın; imzada gerçek değerle açılsın;
   müşteri, memnuniyeti eşiğinin 10 puan üstünde olmayacaksa imzalamasın; ürün iyileşince hemen artsın, pazarın
   beklentisini hesap yalnız imzada ve yenilemede okusun. **Öneri:** evet.
3. **Hata ve güncelleme.** Açık hatanın bedeli adet yerine canlı hat başına hata sayısından gelsin (hat başına 3 puan, en çok
   60). Ürün 26 hafta güncelleme almazsa sonra her ay 1 puan düşsün (en çok 12); hata düzeltmesi de güncelleme sayılsın.
   **Öneri:** evet.
4. **Bütçe kesintisi.** Yenilemede 1★ %2, 2★ %1,5, 3★ %1 ihtimalle müşteri bütçe kesintisi bildirsin; memnun müşteri
   koltuğunu yarıya indirip kalmayı teklif etsin, memnun olmayan ayrılsın. **Öneri:** evet.
5. (inceleme) **Yenileme hep zamla bitiyor.** Ölçümde bakımlı üründe hesapların hepsi yenilemede "Zamma açık" çıkıyor ve
   her yenileme %8 zamla kapanıyor; kâğıt hiç gelmiyor. Neden: ürün uyumu çoğu hesapta 100'e doyuyor (`KALITE_v2.md`
   §3.5). **Öneri:** önce pazar beklentisi bot ürününe göre kalibre edilsin (imzada ürün uyumu ortancası 70 ile 85), sonra
   tutum bantları yeni dağılıma göre kaydırılsın (örnek: Zamma açık ≥ 45). Hiç düzeltmeyen oyuncunun bedeli (hata terimi
   tavanı) da bundan sonra ölçülür.

---

## Hacim (saat)
| Dilim | İçerik | Saat |
|---|---|---|
| C1 | Kapasite düğmeleri, yük ve boş pay satırı, büyüme ve sürüm satırları, aşım etkilerinin ve sürüm büyümesinin silinmesi, `outage_load_mult` | 4 |
| C1b | Sunucu fiyatı, araç ve servis giderinin silinmesi, kurucu satırı, ofis kirası, HR önizlemeleri, metin anahtarları, smoke | 4 |
| C1c | Maaş bandı çarpanı (Soru 1 onaylanırsa) ve gider ölçümü (M11, M12) | 2 |
| C2 | Kurumsal madde (v2) | 3 |
| C3a | Memnuniyet defteri: terimler, satırlar, şema 18 ve göç, B'nin çipi ve satırları | 6 |
| C3b | İmza değeri ve imza kapısı, kayıp nedeni, güncelleme yaşı, yenilemede beklenti okuma; kapılar M1-M10, M13 | 4,5 |
| C4 | Genel Bakış kâğıdı ve Kararlılık satırı | 3 |
| C5 | İstekler ve B2C alıntılar (v2) | 1,5 |
| C6 | Haftalık destek raporu (v2) | 2 |
| C7 | HESAPLAR tablosu (v2) | 4,5 |
| C8 | Yenileme: satışçı ve kurucu yolu (v2), bütçe kesintisi kanalı | 6,5 |
| | **Toplam** | **yaklaşık 41** |

- Simülasyon (§7) koddan önce, ayrı: yaklaşık 4 saat; hacme dahil değil.
- Sıra: Kalite fazı (U) → C1, C1b → C3a → C3b → C2 → C8 → C4 → C5 → C6 → C7 → C1c. C3a/b, U olmadan başlayamaz.
- v2'ye göre artış: defterin yeniden yazılması, gider değişikliği, bütçe kanalı; azalış: sönümlü taban, kendiliğinden ölçekleme.

---

## İnceleme notu (Opus)
Kıdemli inceleme, 17 Ekim 2026 gecesi; simülasyon raporu `MEMNUNIYET_SIM.md` ile karşılaştırıldı. Ne değişti, neden:
1. §3.5 ve Soru 1: gider varyantlarının sayıları simülasyonla farklıydı (ofis kirası varsayımı). Simülasyonun ölçümü ve
   "×1,5 dört kapının ikisini tutar" sonucu eklendi; öneri aynı kaldı, karar Erdem'in.
2. §2.6, §7.4 M7, §8 madde 5: kademe çarpanı `p_max`'tan sonra uygulanır. Neden: Erdem'in 1,0 / 0,5 / 0,25 kararı
   bugünkü sırayla 9 durumun 3'ünde bozuluyor; yeni sırayla 9 / 9. Değerler değişmedi, yalnız sıra.
3. §4 ve §7.4 M9: bütçe kesintisi kapısının alt sınırı (%0,5) kalktı. Neden: bakımlı üründe kesintilerin hepsi küçülme
   oldu (tam kayıp 0); bu Erdem'in "müşteriler ayrılmasın zaten" tutumudur. Model değişmedi.
4. §5.2: M5 (hiç düzeltmeyen) kaldı; tavan 60'ta bırakıldı, nedeni ve simülasyonun 64 önerisi yazıldı. 50 kişilik ekibin açık
   hatası D v3'ün 17'si oldu.
5. §6 ve Soru 5: yenileme tutum bantları yeniden ölçülecek; bakımlı üründe yenilemelerin %100'ü zamla bitiyor.
6. §8: B'ye not dört maddeden yediye çıktı (kesinti sırası, defterin sönme hızı, D v3'ün üç notu); gönderilmeye hazır.
Tutarlılık kontrolü: U yalnız `KALITE_v2.md` §3'teki tanımla okunuyor ve simülasyonun `fit()`'i aynı formülü uyguluyor;
kademe çarpanı 1,0 / 0,5 / 0,25 dört yerde aynı (§1, §2.5, §6, §7.3); B'nin çipi ve kalıcı izi defter satırı olarak tutuluyor
(§5.7). Kayıt şeması: C 17 → 18 alır, D bir sonrakini alır (`D_MODEL_v3.md` §5). Reddedilenlerden hiçbiri dönmedi
(otomatik ölçekleme, araç gideri, "toplam gider değişmesin", yenilemede kurucu saati, rakip fiyat satırı). Simülasyonun
formülleri belgeyle karşılaştırıldı (`msim/model.py`: `fit`, `bug_term`, defterin doğrusal sönmesi, yaş terimi): aynı.
