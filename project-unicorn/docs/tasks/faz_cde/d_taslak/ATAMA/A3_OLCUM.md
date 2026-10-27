# A3 · Erdem'in atama tarifinin simülasyonla ölçümü
20 Ekim 2026 · D'nin A3 alt ajanı (Sonnet 5.5) · Godot koşturulmadı; oyun koduna (`scripts/`, `scenes/`, `themes/`), `strings.csv`'ye, `data/`'ya ve `project.godot`'a dokunulmadı; git'te durum değiştirilmedi. Yeni kod yalnız `d_taslak/dsim/v3/atama/` altında; `dsim3.py` değişmedi. Bağlayıcı girdi: `ERDEM_KARARLAR_2026-10-20.md` "Atama" bölümü; yöntem: `D0s_SIM.md`. Sayıların hepsi koşulardan gelir, tahmin yazılmadı. Toplam 3.548 kayıtlı koşu, yaklaşık 140 dakika, en çok 2 işçi.

## 0. Erdem için özet

1. **Tarifi koda döktüm ve ölçtüm.** Kartın iki ölçüsü: büyüklük ve gereksinim (gereksinim oyunun kapı verisinden türedi). En yüksek gereksinimli karta gereksinimi karşılayan en iyi kişiler gider, kalan kartlara o aşamayı sprintte bitirmeye yeten en düşük hızlı kişi (yetmezse en düşük yeten ikili), artanlar yardıma ya da sıradaki karta gider, kişi kart bitene kadar kalır; PM tarafı aynı. 1, 3, 6, 12, 25, 50 kişide 20 tohumla, D0s'un önerisi R ve eski kuralla yan yana koştum. R ve eski kural D0s'un tablolarını aynen yeniden üretiyor.
2. **Tarif küçük ekipte teslimi değiştirmiyor, büyük ekipte biraz düşürüyor.** R'ye göre 12 / 25 / 50 kişide −%2,5 / −%2,3 / −%3,3 (haftada −2,7 / −6,1 / −17,0 puan), 6 kişide +%2,4, 1 ve 3 kişide fark yok. Kaynaklı arz ve sözlü senaryoda büyük ekipte daha kötü: 25 / 50 kişide −%4,4 / −%7,0.
3. **Açık hata her ekipte %15-37 artıyor** (25 kişide 10,8 → 14,0); kaynaklı arzda 3 kişide iki katından fazla (14,0 → 30,8); 6 kişide kaçan söz %0 → %9,5. Kayıp iki ayrı yerden: **teslim kaybı PM kuralından** ("küçük karta yeten en düşük yıldızlı PM": PM zamanı bol, düşük yıldızlı PM hazırlığın faydasını küçültüyor), **hata artışı atama kuralından** (iyiler bir karta toplanıp kalan kartlar zayıf ellere kalıyor; toplam yıldız dağılımı aynı, kartlara dağılımı kötü).
4. **Elle atama bu modelde bir karar değil.** Sprint içi kesin önizlemeyi deneyen bir usta arama teslimi ve açık hatayı tarifin ve R'nin üstüne çıkaramadı (±1 puan/hf); 11 kuraldan tohum başına en iyisini seçen usta bile R'nin üstüne en çok %6 (6 kişide) çıkıyor, 25 ve 50 kişide ≤ %0,4. Kötü atama da küçük bedelli: R'ye göre rastgele ve ters atama teslimde en çok −%3, açık hatada (ters atama) +%16-39 kaybettiriyor. Tarife göre ise rastgele atama teslimde aynı, açık hatada 3-50 kişide %5-22 daha iyi (eşli −0,5 ile −3,1; A5 incelemesinin hesabı, §3.4 madde 3 ile aynı yön). Oyuncunun hata yapma alanı dar; elle atama teslim kararı değil, kalite ve anlatı konusu.
5. **Elle atama ancak "kart bitene kadar kalır" kuralıyla taşınabilir.** R'de her hafta başı, aşaması süren kişilerin %33 (6 kişi), %50-58 (12), %76-89 (25, 50) kadarı başka karta geçiyor ve sprint başında oyuncunun yeniden karar vermesi gereken kişi 3,4 / 8,7 / 21,1 / 45,9 (6 / 12 / 25 / 50 kişi). Tarifte hafta içi değişim %0, sprint başı karar 2,1 / 4,2 / 7,0 / 14,0.
6. **Boşta kalma bir optimizasyon problemi değil.** D0s'un boşta payı neredeyse tamamen PM'in kendi boş zamanı (PM'ler zamanlarının %48-56'sını 6-12 kişide, %20-26'sını 25-50 kişide kullanmıyor). PM hariç boşta 12 ve 25 kişide ≈ %0, 6 kişide %2-3, 50 kişide %3-4 (kadro tavanı); yapısal boşta yalnız 1 kişide (%26: sıradaki kart sığmıyor) ve 3 kişide (%17-19: uyan iş yok). Nedeniyle yazılması yeter.
7. **PM hazırlığı iki okuma.** Bugünkü PRD (hız bonusu ver, durdurma) ile "hazırlıksız kart Geliştirmeye giremez". PM yeterliyse (PM başına 6-8 kişi) iki okuma aynı sonucu veriyor. PM başına 11 kişi sınır; 23 kişide 1 PM'de kapı okuması teslimi 234 → 110'a (−%53), PM hariç boşta payını %0 → %58'e çıkarıyor (kapı okumasında teslim tavanı = PM hazırlık kapasitesi ÷ 0,2). [GÖRÜŞ] PRD okuması kalsın.
8. **Darboğaz.** Bu ekip karışımlarında taşan aşama %89-100 Test (12 kişi ve üstünde her sprint); "taşma yokken yazmaz" kuralı pratikte hep "Test" yazar. Plan anındaki yük ÷ kapasite uyarısı isabetli (%95-100) ama ya her sprint çıkıyor ya geç yakalıyor; oynatma (tahmin = sonuç) %100. Uyarıya bakıp bir kart değiştirmek teslimi %0,7'den az oynatıyor. [GÖRÜŞ] Darboğaz uyarısı alım sinyali olarak anlamlı, plan aracı olarak değil.
9. **Gereksinim kuralı zararsız ve faydalı.** Veri kapıları (≤ ★3) 5★ ölçeğindeki ekiplerde nadiren bağlıyor (boşta nedeni %0,1'in altı) ama kaliteyi koruyor: kalkınca açık hata 6 / 12 / 25 kişide +5,7 / +3,0 / +3,3, teslim aynı. Kapıları bir yıldız sertleştirmek hiçbir şeyi değiştirmiyor. "Kalır" kuralının yan etkisi: uymayan işte çalışan PM'in 60 haftalık moral kaybı −28'den −39'a çıkıyor.
10. **Erdem'e dört sade soru §3.5'te:** elle atama ayar mı kalsın, hazırlık yetmezse kart dursun mu, küçük kartlara en düşük yıldızlı PM mi, "kalır" kuralı uymayan işi de tutsun mu. Sınırlar §5'te: usta arama yerel ve sprint ölçüsüyle sınırlı, PM'e devir modellenmedi, kapı verisi yalnız ERP alt türü.

## 1. Tarifin kodlanışı ve her belirsiz yerde seçilen okuma

### 1.1 Kartın iki ölçüsü

- **Büyüklük** = kartın o aşamadaki ihtiyacı (Tasarım, Geliştirme, Test, Düzeltme puanı). D0s ile aynı; kadro tavanı da aynı (aşama ihtiyacı ÷ 8, en az 1 kişi).
- **Gereksinim** = kartın o aşamada kimlerin çalışabileceğini söyleyen en düşük yıldız. Oyunun gerçek hat verisinden türedi: `data/product/lines/erp.json` ve `shared.json` içindeki her kademenin `requires.person` listesi (`scripts/systems/line_gates.gd` bu listeyi "şirkette bu alanda en az şu yıldızda bir kişi" diye okur). Dosyalar `910ad1f`'te ve çalışma ağacında bayt bayt aynı (git blob özetleri aşağıda, §4); kopyaları `atama/veri/` altında. Eşleme: Tasarım alanı → Tasarım aşaması; Yazılım → Geliştirme ve Düzeltme; Test → Test; Ürün → PM'in hazırlığı. Kartın tek sayısı (sıralama için) aşamalardaki en büyük gereksinimdir.
- Kapının öbür iki türü atamayı değil kartın açılmasını belirler ve modelde "geçilmiş" sayıldı: `total` (şirket toplamı, ör. Yazılım toplamı ★4) ve `research` (Ar-Ge düğümü). Hatta göre eşleme: sim hatları 0-2 tasarım, 3-5 geliştirme, 6-8 test ağırlıklı; ERP'nin dokuz hattı aynı profil dağılımına sahip (3 + 3 + 3), sırayla eşlendi (tabloda).

Verilerden çıkan gereksinim tablosu (yıldız; sıra: Tasarım, Yazılım, Test, Ürün):

| Hat (profil) | K1 | K2 | K3 |
|---|---|---|---|
| erp_stock (tasarım) | 0 0 0 0 | 1 2 0 0 | 2 2 0 0 |
| erp_invoicing (tasarım) | 1 0 0 0 | 1 0 0 0 | 1 0 0 0 |
| shared_mobile (tasarım) | 1 0 0 0 | 1 0 0 0 | 3 0 0 0 |
| erp_cashflow (geliştirme) | 0 0 0 0 | 0 2 0 1 | 0 2 0 1 |
| erp_intake (geliştirme) | 0 0 0 0 | 0 2 0 1 | 0 0 0 2 |
| shared_integrations (geliştirme) | 0 0 0 0 | 0 0 0 2 | 0 0 0 2 |
| erp_ledger (test) | 0 0 0 0 | 0 0 1 2 | 0 0 2 0 |
| shared_security (test) | 0 0 0 0 | 0 0 2 0 | 0 0 2 0 |
| shared_durability (test) | 0 0 0 0 | 0 2 1 0 | 0 0 2 0 |

Yani veride gereksinim K1'de neredeyse yok, K2'de ★1-2, K3'te ★2-3. Verinin yıldızları bugünkü 1-3 ölçeğindedir; kişilerin yıldızı ise simülasyonda 5 yıldız ölçeğinde (puan ÷ 2). Bu yüzden iki okuma var: **veri aynen** (ana) ve **sert** (`E_sert`): sıfırdan büyük her kapı bir yıldız yukarıda (5★ ölçeğine geçilince kapıların da yukarı çekileceği varsayımı).

Kapısı olmayan kartlar için **[VARSAYIM]** kurallar: düzeltme kartı = Yazılım ★1; derinlik kartı = hattın K3 kapısı; müşteri isteği kartı = hesabın koltuk boyutuna göre kademesinin kapısı (koltuk < 20 K1, < 100 K2, ≥ 100 K3; sim bunu zaten böyle kuruyor). Kurucu gereksinimde her alanda en az ★2 sayılır (Y ≥ 0,86 tabanıyla tutarlı: "iki yıldız gibi çalışır"). Ekibin o aşamadaki en iyi kişisini aşan gereksinim ekibin en iyisine iner ("kart sprinte alınırken kapı şirket çapında zaten geçilmiştir", `line_gates.gd` başlığı; kapı tam olarak bunu ölçer, atamanın işi değil).

### 1.2 Atama kuralı (bir satırda, bir atama anında)

Atama anları D0s ile aynı: hafta başı, bir aşamanın açılışı, bir kişinin aşaması bitince, çekilen kartın gelişi. "Kim hangi satıra (Tasarım, Geliştirme, Test) girer" iskeleti de aynı (aday sınıfı, hız, kimlik; uymayan iş yalnız boşta kalacak kişiye). Değişen yalnız satır içi dağıtım:

1. Satırın açık kartları **gereksinim (azalan), kalan iş (azalan), plan sırası** ile dizilir. İlk uygun karta (gereksinimi karşılayan en az bir kişi var) **gereksinimi karşılayan en iyi kişiler** gider, kadro tavanı kadar. Ana okumada kişi aşama bitene kadar orada kalır.
2. **Kalan kartlar plan sırasıyla** (planı sıralayan söz, istek, devreden, düzeltme önceliği korunur) kendi sırasında: o aşamayı sprint içinde bitirmeye yeten **en düşük hızlı** kişi (gereksinimi karşılayan); kimse tek başına yetmiyorsa kadro iki kişiye izin veriyorsa **en düşük yeten ikili**. "Yeten" = kalan iş ≤ hız × kartın sprintte bitmesi için bu aşamaya ayrılan süre (kalan sprint süresi × aşamanın kalan işteki payı).
3. Tek başına ya da ikiliyle yetmeyen kart yardım adımına kalır.
4. **Kimse boşta kalmaz** (artanlar): artan kişi, aşamayı **en geç bitecek** (kalan iş ÷ eldeki hız en büyük) uygun karta yardımcı olur, kadro tavanı dolana kadar. Uymayan iş (sınıf 3) en sonda ve yalnız yer varsa. Kimsenin giremediği yerde kalan kişi için D0s'un çekme kuralı çalışır ("sıradaki kartı çek", Karar 11): bu, "kuraldan çıkan yerleşim"in ikinci yarısıdır; kart da yoksa kişi gerçekten boştadır ve neden yazılır.
5. **Kart bitene kadar kalır**: ana okumada kişi, aşaması bitmeden başka işe geçmez; hafta ve sprint sınırı bunu bozmaz (D0s'un kuralı hafta başında herkesi yeniden dağıtıyordu). Kart bir sonraki aşamaya geçince o aşamanın kişileri o aşamanın rolleridir.

### 1.3 PM tarafı

Hazırlanacak kartlar (bir sonraki sprintin girişi, D0s ile aynı küme) **PM gereksinimine (Ürün kapısı), sonra büyüklüğe** göre dizilir. En yüksek gereksinimli (ve büyük) kartı gereksinimi karşılayan en iyi PM alır ve hazırlığı **bitene kadar** (kartın hazırlayanı kalıcıdır, D0s Karar 8) hazırlar. Kalan kartlara, o kartın hazırlığını sprint ufkunda bitirmeye yeten **en düşük yıldızlı** PM bakar; bir kartı bitirince sıradakine geçer. Fayda yine kartı hazırlayan PM'in yıldızından gelir. Tek PM varsa bu kural R'nin kuralıyla aynı sonucu verir; birden çok PM varsa ve PM zamanı boşsa (ölçülen durum), kural küçük kartları daha az yıldızlı PM'e verdiği için o kartların faydası küçülür (§2.2).

### 1.4 Tarifin belirsiz olduğu yerler: ana okuma, alternatif kol, gerekçe

| # | Belirsizlik | Ana okuma (neden) | Alternatif (kol) |
|---|---|---|---|
| 1 | "Kart bitene kadar kalır" | Aşama bitene dek; hafta ve sprint sınırını aşar. Kartın aşamalarını farklı roller yapar, kişi kendi aşamasında kalır | Her hafta yeniden dağıtım (`E_np`) = D0s'un hafta başı yeniden dağıtımı |
| 2 | "En iyi kişiler" kaç kişi | Kadro tavanı kadar (kartın o aşamada alabileceği en çok kişi); örnekteki "4★ karta en iyi 2 geliştirici" tavan 2 olan karttır | Aşamayı sprintte bitirmeye yetecek en az sayıda en iyi kişi, gerisi başka karta (`E_min`) |
| 3 | "Bitirmeye yeten" | Kartın sprintte bitebilmesi için o aşamaya düşen süre payı (kart Tasarım + Geliştirme + Test zinciridir, her aşama sprintin tamamını harcayamaz) | Aşama için sprintin kalan süresinin tamamı (`E_asama`) |
| 4 | Kalan kartların sırası | Plan sırası (planı öneri ve söz sıralar). İlk deneme gereksinim, sonra büyüklük sırasıydı: küçük ve ilk sıradaki kartlar aç kaldı, MVP 25 kişide 6., 50 kişide 8. haftaya kaydı | Gereksinim, sonra büyüklük (`E_gsira`) |
| 5 | Artan kişi | Kalan işi en geç bitecek karta yardımcı; sonra çekme; uymayan iş son | Ölçülmedi (tarif "kimse boşta kalmaz" der, yolunu söylemez) |
| 6 | Gereksinim ekibin en iyisini aşarsa | En iyiye iner (kapı şirket düzeyinde zaten geçilmiş sayılır) | Sert kapılar (`E_sert`), gereksinimsiz (`E_gyok`) |
| 7 | PM hazırlığı geç kalırsa | Bugünkü PRD: hazırlık hız bonusu verir, işi durdurmaz | Hazırlıksız kart Geliştirmeye giremez (`E_gate`, `R_gate`) |

### 1.5 Kollar ve ölçüm düzeni

- **Kollar:** `L` eski kural (`D3_LEGACY=1`); `R` D0s'un önerisi (`D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h`); `E` tarif ana okuma (atama + PM); tarifin kolları `E_np`, `E_min`, `E_asama`, `E_gsira`, `E_sert`, `E_gyok`; atama ile PM'i ayıran `E_pmr` (tarif atama + R'nin PM'i) ve `R_pme` (R atama + tarifin PM'i); PM kapısı `E_gate`, `R_gate`; kötü el `RND` (rastgele), `REV` (tersine: en zayıflar en büyük karta); `USTA` (arama); uyarıyı dinleyen `R_uyari`, `E_uyari` (eşik 1,5 ve 1,25: `*_uyari2`).
- **Ekipler** S1 ile S6 = 1, 3, 6, 12, 25, 50 kişi (dsim3 `BASES`). Tablolar tohum ortancasıdır (tohum 1-20) ve D0s ile aynı pencere: sınırsız arz 60 hafta, 21-60. hafta; kaynaklı arz `PR` senaryoları (80 hafta, söz yoğunluğu D0s'unki) ve `DEP` (104 hafta).
- **Boşta payı** iki yazılır: D0s ölçüsü (PM'in artan hazırlık zamanı dahil) ve **PM hariç** (PM dışındaki kişi-haftanın boş kalan payı). Bunun nedeni §3'te: D0s ölçüsündeki boşta payının neredeyse hepsi PM'in kendi boş zamanıdır.
- **Eşli fark** tablolarında her hücre aynı 20 tohumun ortalama farkı ± standart hata, parantezde farkın eksi çıktığı tohum sayısıdır (tek tohumun gürültüsü D0s'ta ±1-3 puan/hf idi).

## 2. Tablolar

Her tablo tohum ortancasıdır (20 tohum), aksi yazılmadıkça. Sütunlar S1 ile S6 = 1, 3, 6, 12, 25, 50 kişi. "Eşli fark" tablolarında hücre = aynı tohumların ortalama farkı ± standart hata (eksi çıkan tohum / tohum sayısı). Tüm ham tablolar `out/a3_tablolar.md`'de (62 tablo); burada okumaya yetenler var.

### 2.1 Ölçü 1: tarif, R ve eski kural yan yana

**Teslim (puan/hf), sınırsız arz, 60 hafta**

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 5.1 | 20.1 | 48.0 | 108.0 | 267.5 | 540.0 |
| R (D0s önerisi) | 4.5 | 21.1 | 49.0 | 109.0 | 264.0 | 514.0 |
| Tarif (ana okuma) | 4.5 | 20.8 | 50.5 | 106.0 | 258.5 | 498.0 |

**Eşli fark, tarif − R (teslim, puan/hf)**

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| E − R | 0.0 ± 0.0 (0/20) | -0.3 ± 0.2 (11/20) | 1.2 ± 0.3 (2/20) | -2.7 ± 0.5 (17/20) | -6.1 ± 0.7 (19/20) | -17.0 ± 0.6 (20/20) |

Okuma: 1 ve 3 kişide fark yok (1 kişide tek kişi tek kural; 3 kişide −0,3 ± 0,2). 6 kişide tarif +1,2 ± 0,3 (+%2,4) ile R'nin üstünde. 12, 25, 50 kişide tarif R'nin altında: −2,7 / −6,1 / −17,0 puan/hf (−%2,5 / −%2,3 / −%3,3); 12, 25 ve 50 kişide 20 tohumun 17'si, 19'u ve 20'si eksi. Eski kuralın 50 kişideki 540,0'ı R'nin 514,0'ına, tarifin 498,0'ına inmiş durumda (D0s'un "sabit 2 hafta" bedeli üstüne tarifin payı).

**Açık hata (medyan)**

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 6.0 | 8.0 | 8.0 | 9.5 | 12.0 | 16.2 |
| R (D0s önerisi) | 6.0 | 8.8 | 8.0 | 9.5 | 10.8 | 13.2 |
| Tarif (ana okuma) | 6.0 | 10.8 | 10.0 | 12.0 | 14.0 | 15.0 |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| E − R | 0.0 ± 0.0 (0/20) | 2.5 ± 0.2 (0/20) | 1.9 ± 0.3 (0/20) | 2.7 ± 0.3 (1/20) | 4.0 ± 0.3 (0/20) | 2.0 ± 0.4 (2/20) |

Okuma: tarif her ölçekte (1 kişi hariç) R'den daha çok açık hata bırakıyor: +2,5 / +1,9 / +2,7 / +4,0 / +2,0 (3, 6, 12, 25, 50 kişi), yani %15 ile %37 fazla; 20 tohumluk eşli sınamada tarifin daha az hata bıraktığı tohum 0-2/20. Nedeni §2.2 ve §3'te.

**Boşta payı: D0s ölçüsü ve PM hariç**

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 13.7% | 16.6% | 15.8% | 9.5% | 2.1% | 2.7% |
| R (D0s önerisi) | 26.4% | 16.6% | 11.6% | 8.5% | 2.8% | 5.4% |
| Tarif (ana okuma) | 26.4% | 18.8% | 10.8% | 8.1% | 2.5% | 6.0% |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 26.4% | 16.6% | 2.7% | 0.1% | 0.0% | 2.6% |
| Tarif (ana okuma) | 26.4% | 18.8% | 2.1% | 0.1% | 0.1% | 4.0% |

Okuma: D0s ölçüsündeki boşta payı 6 ile 25 kişide neredeyse tamamen PM'in kendi boş zamanıdır (PM hariç boşta 6 kişide %2,7, 12 kişide %0,1, 25 kişide %0,0). 50 kişide yarıya yakını kadro tavanıdır. Tarif boşta payını neredeyse değiştirmiyor (D0s ölçüsünde eşli fark −0,7 ile +2,2 puan; 3 kişide +2,2 pp, 50 kişide +0,6 pp). 1 ve 3 kişide boşta yapısal ve her kuralda aynı: tek kurucu için sıradaki kart sprinte sığmıyor (%26), 3 kişide "uyan iş yok" (%17-19): kurucu, geliştirici ve tasarımcıdan biri, kartın sırası kendisine gelene kadar bekliyor.

**MVP haftası ve plan doluluğu**

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 | 2.0 |
| R (D0s önerisi) | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 | 2.0 |
| Tarif (ana okuma) | 6.0 | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 81.1% | 99.6% | 97.5% | 115.9% | 121.3% | 123.2% |
| R (D0s önerisi) | 70.1% | 99.8% | 110.9% | 116.6% | 121.1% | 123.3% |
| Tarif (ana okuma) | 70.1% | 98.8% | 108.4% | 115.8% | 121.2% | 123.2% |

Okuma: MVP tarifte 3 kişide 4 yerine 6., 12 kişide 2 yerine 4. hafta; 25 ve 50 kişide aynı (2). Plan doluluğu her kuralda aynı düzeyde (1 kişide %70,1; 3 kişide %98,8; 6 kişide %108,4; 12'den büyükte %115,8 ile %123,2): doluluk plan kuralının, atama kuralının değil.

**Kaynaklı arz ve söz (PR senaryosu: hat başına K1-K3 + derinlik + istek, B2B hesapları, söz yoğunluğu D0s'unki, 80 hafta)**

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 4.8 | 22.5 | 47.0 | 98.8 | 246.2 | 420.6 |
| R (D0s önerisi) | 5.5 | 19.7 | 47.2 | 100.8 | 242.5 | 426.5 |
| Tarif (ana okuma) | 5.8 | 21.1 | 47.8 | 97.7 | 231.6 | 396.2 |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| E − R | 0.1 ± 0.1 (6/20) | 1.4 ± 0.3 (4/20) | 0.5 ± 0.2 (9/20) | -2.8 ± 0.4 (18/20) | -10.6 ± 0.7 (20/20) | -29.8 ± 1.2 (20/20) |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 6.0 | 6.8 | 7.0 | 8.0 | 10.8 | 15.0 |
| R (D0s önerisi) | 8.0 | 14.0 | 9.0 | 8.5 | 8.2 | 12.0 |
| Tarif (ana okuma) | 8.0 | 30.8 | 9.2 | 12.0 | 14.0 | 17.2 |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| E − R | -0.3 ± 0.3 (10/20) | 21.0 ± 2.7 (0/20) | 0.6 ± 0.4 (6/20) | 3.5 ± 0.4 (0/20) | 5.6 ± 0.5 (0/20) | 5.0 ± 0.5 (0/20) |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Eski kural (D3_LEGACY) | 100.0% | 84.5% | 66.7% | 37.2% | 0.0% | 0.0% |
| R (D0s önerisi) | 79.3% | 21.6% | 0.0% | 0.0% | 0.0% | 0.0% |
| Tarif (ana okuma) | 81.8% | 23.2% | 9.5% | 0.0% | 0.0% | 0.0% |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| E − R | 1.1 pp ± 3.1 pp (5/20) | 3.5 pp ± 2.2 pp (7/20) | 9.6 pp ± 1.6 pp (0/20) | 0.7 pp ± 0.4 pp (0/20) | 0.5 pp ± 0.4 pp (0/20) | 0.7 pp ± 0.4 pp (0/20) |

Okuma: kaynaklı arzda tarifin kaybı sınırsız arzdan büyük: teslim 12 / 25 / 50 kişide −%2,8 / −%4,4 / −%7,0 (−2,8 / −10,6 / −29,8 puan/hf); açık hata 3 kişide 14,0 yerine 30,8 (eşli +21,0 ± 2,7; 20 tohumun 20'sinde kötü), 12, 25, 50 kişide +3,5 / +5,6 / +5,0. Kaçan söz 6 kişide %0 yerine %9,5 (eşli +9,6 pp ± 1,6; eksi tohum 0/20); 12 kişi ve üstünde iki kuralda da 0; 1 ve 3 kişide sözlerin %80'i ve %22'si iki kuralda da kaçıyor (kapasite sorunu, atama değil). 104 haftalık derinlik koşusunda (DEP) aynı yön: 12 ve 25 kişide tarif −3,1 ± 0,3 ve −9,8 ± 0,5 puan/hf (`out/a3_tablolar.md` t2_dep_fark).

### 2.2 Tarifin kollarına ayrılışı: kayıp nereden geliyor

Tarif iki parçadır: dağıtım kuralı (kim hangi karta) ve PM kuralı (kim hangi kartı hazırlar). `E_pmr` tarifin atamasını R'nin PM'iyle, `R_pme` R'nin atamasını tarifin PM'iyle koşar.

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| E_pmr − R | 0.0 ± 0.0 (0/20) | -0.3 ± 0.2 (11/20) | 1.1 ± 0.3 (2/20) | 0.7 ± 0.4 (5/20) | -1.1 ± 0.4 (15/20) | -9.8 ± 0.7 (20/20) |
| R_pme − R | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | 0.1 ± 0.1 (0/20) | -2.9 ± 0.4 (19/20) | -4.8 ± 0.5 (20/20) | -5.5 ± 0.5 (20/20) |
| E_np − E | 0.0 ± 0.0 (0/20) | -0.8 ± 0.3 (13/20) | -0.2 ± 0.4 (9/20) | 0.6 ± 0.6 (7/20) | -0.2 ± 0.7 (8/20) | 0.9 ± 0.5 (5/20) |
| E_min − E | 0.0 ± 0.0 (0/20) | 0.0 ± 0.2 (5/20) | -0.4 ± 0.5 (10/20) | 0.4 ± 0.5 (4/20) | -0.9 ± 0.8 (11/20) | 0.8 ± 0.5 (5/20) |
| E_asama − E | 0.0 ± 0.0 (0/20) | -0.1 ± 0.0 (1/20) | 0.0 ± 0.4 (9/20) | 0.3 ± 0.6 (8/20) | 0.9 ± 0.7 (7/20) | 7.8 ± 0.8 (0/20) |
| E_gsira − E | 0.0 ± 0.0 (0/20) | -0.1 ± 0.2 (5/20) | 0.2 ± 0.4 (7/20) | 0.7 ± 0.5 (6/20) | -0.7 ± 0.9 (12/20) | 0.1 ± 0.6 (8/20) |
| E_sert − E | 0.0 ± 0.0 (0/20) | -0.2 ± 0.2 (8/20) | -0.2 ± 0.4 (8/20) | -1.2 ± 0.6 (13/20) | -0.8 ± 0.9 (10/20) | 2.8 ± 0.5 (0/20) |
| E_gyok − E | 0.0 ± 0.0 (0/20) | -0.4 ± 0.3 (10/20) | 1.4 ± 0.4 (5/20) | -0.1 ± 0.7 (10/20) | -2.6 ± 0.9 (14/20) | -1.3 ± 0.6 (10/20) |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| E_pmr − R | 0.0 ± 0.0 (0/20) | 2.5 ± 0.2 (0/20) | 1.9 ± 0.3 (1/20) | 2.1 ± 0.4 (2/20) | 2.9 ± 0.3 (0/20) | 0.8 ± 0.3 (5/20) |
| R_pme − R | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | 0.1 ± 0.1 (0/20) | 0.1 ± 0.3 (9/20) | 0.1 ± 0.2 (8/20) | -0.3 ± 0.3 (10/20) |
| E_np − E | 0.0 ± 0.0 (0/20) | -0.1 ± 0.3 (7/20) | -0.1 ± 0.3 (9/20) | -0.5 ± 0.4 (11/20) | -1.4 ± 0.4 (14/20) | -1.2 ± 0.4 (14/20) |
| E_min − E | 0.0 ± 0.0 (0/20) | -0.6 ± 0.2 (9/20) | -0.3 ± 0.2 (12/20) | -0.7 ± 0.4 (10/20) | -0.8 ± 0.4 (13/20) | -1.1 ± 0.4 (14/20) |
| E_asama − E | 0.0 ± 0.0 (0/20) | -0.1 ± 0.1 (2/20) | -0.0 ± 0.2 (5/20) | -0.1 ± 0.4 (9/20) | 0.4 ± 0.5 (6/20) | 0.5 ± 0.5 (8/20) |
| E_gsira − E | 0.0 ± 0.0 (0/20) | -0.2 ± 0.2 (5/20) | 0.8 ± 0.4 (7/20) | 0.4 ± 0.4 (8/20) | 1.6 ± 0.6 (4/20) | 1.1 ± 0.4 (6/20) |
| E_sert − E | 0.0 ± 0.0 (0/20) | -0.9 ± 0.3 (11/20) | 0.0 ± 0.3 (10/20) | 0.5 ± 0.5 (7/20) | -0.1 ± 0.6 (10/20) | -0.7 ± 0.5 (12/20) |
| E_gyok − E | 0.0 ± 0.0 (0/20) | 1.0 ± 0.3 (5/20) | 5.7 ± 0.4 (0/20) | 3.0 ± 0.4 (1/20) | 3.3 ± 0.5 (2/20) | -0.6 ± 0.4 (12/20) |

Okuma (teslim): **kaybın büyük kısmı PM kuralındadır.** R'nin atamasına tarifin PM'ini koymak (`R_pme − R`) 12 / 25 / 50 kişide −2,9 / −4,8 / −5,5 puan/hf (20 tohumun 19, 20 ve 20'sinde eksi); tarifin atamasını R'nin PM'iyle koşmak (`E_pmr − R`) 6 / 12 kişide +1,1 / +0,7, 25 kişide −1,1, 50 kişide −9,8 puan/hf. Yani 12 ve 25 kişide kayıp PM'den (atamanın katkısı sıfıra yakın), 50 kişide ikisi birlikte (PM −5,5; atama −9,8; toplam −17,0). PM kuralının neden kaybettirdiği ölçüldü ve basit: PM zamanı kıt değil (PM'in kendi boş zamanı 6 ve 12 kişide %48-56, 25 ve 50 kişide %20-26, tablo aşağıda); "yeten en düşük yıldızlı PM" kuralı küçük kartı daha az yıldızlı PM'e veriyor ve hazırlığın faydası (hız +%10 ile +%30, hata ×0,90 ile ×0,60) küçülüyor, bedava olan en iyi PM'i kullanmamak bir kayıptır.

| Kol | S3 | S4 | S5 | S6 |
|---|---|---|---|---|
| R (D0s önerisi) | 56% | 50% | 23% | 26% |
| Tarif (ana okuma) | 54% | 48% | 20% | 21% |

Okuma (hata): **atama kuralı hata artışının kaynağı** (`E_pmr − R` +0,8 ile +2,9; `R_pme − R` −0,3 ile +0,1). Gereksinim kaldırılınca (`E_gyok`) hata daha da artıyor (6 / 12 / 25 kişide +5,7 / +3,0 / +3,3 hata) ve teslim değişmiyor: gereksinim kuralı kaliteyi koruyan parçadır.

Kolların geri kalanı (hepsi tarife göre, eşli): kişi her hafta yeniden dağıtılsa (`E_np`) teslim ve hata değişmiyor (±1 puan; hata 25 ve 50 kişide −1,4 ve −1,2, yani kalıcılık hatayı biraz artırıyor); "en iyiler yetecek kadar" (`E_min`) fark yok; "yeten = sprintin tamamı" (`E_asama`) 50 kişide +7,8 puan/hf (teslim biraz daha iyi, MVP aynı); kalan kartları gereksinim sırasıyla dizen okuma (`E_gsira`) teslimi değiştirmiyor ama MVP'yi 25 ve 50 kişide 2. haftadan 6. haftaya itiyor (küçük ve ilk sıradaki kartlar açta kalıyor); kapıları bir yıldız sertleştirmek (`E_sert`) fark yaratmıyor (−1,2 ile +2,8 puan/hf).

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 4.5 | 21.1 | 49.0 | 109.0 | 264.0 | 514.0 |
| Tarif (ana okuma) | 4.5 | 20.8 | 50.5 | 106.0 | 258.5 | 498.0 |
| Tarif, kişi hafta başı yeniden | 4.5 | 19.8 | 50.0 | 106.5 | 257.5 | 498.0 |
| Tarif, en iyiler: yetecek kadar | 4.5 | 20.8 | 50.0 | 107.0 | 257.0 | 498.0 |
| Tarif, yeten = sprintin tamamı | 4.5 | 20.8 | 50.5 | 106.0 | 258.0 | 505.5 |
| Tarif, kalan kartlar gereksinim sırasıyla | 4.5 | 20.4 | 51.0 | 107.0 | 257.0 | 497.0 |
| Tarif, kapılar 1★ sert | 4.5 | 20.1 | 50.0 | 105.0 | 256.5 | 500.0 |
| Tarif, gereksinim yok | 4.5 | 19.8 | 52.5 | 106.0 | 255.5 | 495.0 |
| Tarif atama + R'nin PM'i | 4.5 | 20.8 | 50.5 | 109.0 | 262.5 | 505.0 |
| R atama + tarifin PM'i | 4.5 | 21.1 | 49.0 | 106.0 | 259.0 | 508.0 |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 6.0 | 8.8 | 8.0 | 9.5 | 10.8 | 13.2 |
| Tarif (ana okuma) | 6.0 | 10.8 | 10.0 | 12.0 | 14.0 | 15.0 |
| Tarif, kişi hafta başı yeniden | 6.0 | 10.5 | 10.0 | 12.0 | 13.0 | 14.0 |
| Tarif, en iyiler: yetecek kadar | 6.0 | 10.0 | 10.0 | 12.0 | 13.5 | 14.8 |
| Tarif, yeten = sprintin tamamı | 6.0 | 10.5 | 10.0 | 12.5 | 14.5 | 16.0 |
| Tarif, kalan kartlar gereksinim sırasıyla | 6.0 | 10.5 | 11.0 | 12.8 | 16.0 | 16.0 |
| Tarif, kapılar 1★ sert | 6.0 | 10.0 | 10.0 | 12.5 | 14.5 | 14.8 |
| Tarif, gereksinim yok | 6.0 | 12.0 | 15.8 | 15.0 | 17.5 | 15.0 |
| Tarif atama + R'nin PM'i | 6.0 | 10.8 | 10.0 | 11.8 | 13.0 | 14.0 |
| R atama + tarifin PM'i | 6.0 | 8.8 | 8.0 | 10.0 | 10.8 | 13.0 |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 | 2.0 |
| Tarif (ana okuma) | 6.0 | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 |
| Tarif, kişi hafta başı yeniden | 6.0 | 6.0 | 6.0 | 4.0 | 2.0 | 2.0 |
| Tarif, en iyiler: yetecek kadar | 6.0 | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 |
| Tarif, yeten = sprintin tamamı | 6.0 | 6.0 | 6.0 | 4.0 | 2.0 | 2.0 |
| Tarif, kalan kartlar gereksinim sırasıyla | 6.0 | 6.0 | 4.0 | 4.0 | 6.0 | 6.0 |
| Tarif, kapılar 1★ sert | 6.0 | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 |
| Tarif, gereksinim yok | 6.0 | 6.0 | 6.0 | 6.0 | 2.0 | 2.0 |
| Tarif atama + R'nin PM'i | 6.0 | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 |
| R atama + tarifin PM'i | 6.0 | 4.0 | 4.0 | 2.0 | 2.0 | 2.0 |

**Neden hata artıyor?** Toplam iş yıldız dilimlerine aynı dağılıyor (tablo: 25 kişide Geliştirme işinin ≤2★ / 2,5-3,5★ / ≥4★ kişilere düşen payı R'de %26 / %62 / %13, tarifte %27 / %61 / %12; Test işi %36 / %37 / %27 ve %35 / %38 / %27; 50 kişide de aynı), yani tarif "çok yıldızlıya az iş" vermiyor. Fark işin **kartlara dağılımında**: tarif en iyi kişileri bir karta toplayıp kalan kartlara tek tek en düşük yeteni veriyor; R en iyi kişiyi en büyük karta, sıradakini sıradaki karta veriyor (boyuta orantılı). Hata modeli bir kartın hatasını o karttaki geliştiricilerin ve testçilerin ortalama yıldızından okuyor (yapım kalitesi 1 ÷ √Y, yakalama c = 0,57 × √Y); aynı toplam yıldız bir kartta toplanınca öbür kartlar daha zayıf ellerde kalıyor ve beklenen hata artıyor. Bu açıklama tahmindir [GÖRÜŞ]; kart kart izlenmedi, tutarlı kanıt rastgele atamanın (`RND`) hata açısından tariften iyi çıkması (aşağıda).

| Ölçek | Kol | Geliştirmede ≤2★ payı | 2,5-3,5★ | ≥4★ | Testte ≤2★ | 2,5-3,5★ | ≥4★ |
|---|---|---|---|---|---|---|---|
| S3 | R | 45% | 55% | 0% | 49% | 51% | 0% |
| S3 | E | 48% | 52% | 0% | 28% | 72% | 0% |
| S4 | R | 31% | 39% | 30% | 54% | 46% | 0% |
| S4 | E | 32% | 40% | 29% | 54% | 46% | 0% |
| S5 | R | 26% | 62% | 13% | 36% | 37% | 27% |
| S5 | E | 27% | 61% | 12% | 35% | 38% | 27% |
| S6 | R | 23% | 60% | 18% | 27% | 60% | 14% |
| S6 | E | 23% | 60% | 17% | 26% | 60% | 14% |

### 2.3 Ölçü 2: elle atamanın üst sınırı ve kötü elin bedeli

Usta oyuncu kolu (`USTA`, `USTA1`): her sprintin başında plan (ve kesin önizleme: tahmin = sonuç, fark 1e-14) hazırken kişi → kart öncelik listeleri üzerinde rastgele yeniden başlamalı tepe tırmanma (S1-S4'te 80-120, S5'te 60, S6'da 30 yineleme; sprint başına 33-123 oynatma). Başlangıç tarifin kendi izidir; sprint sonunda tarifin otomatik ataması, R'nin otomatik ataması ve bulunan elle atama arasında ölçüsü en iyi olan seçilir (yani sonuç ikisinden kötü olamaz). İki ölçü denendi: `USTA` net iş (aşama ilerlemesi eksi doğan hata bedeli eksi kaçan hata bedeli) ve `USTA1` teslim ağırlıklı (bitirilen kart + yarım kartın yarısı − kaçan hata). Arama seçtiği ölçüde tarifin planını sprint başına iyileştiriyor (`USTA1`: 3 kişi 4,7; 6 kişi 11,5; 12 kişi 14,3; 25 kişi 24,6 birim; bir sprintin işi 3 kişide ~42, 6 kişide ~101, 12 kişide ~212, 25 kişide ~517 birim, yani %5 ile %11) **ama 60 haftalık sonuç değişmiyor**:

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 4.5 (n=20) | 21.1 (n=20) | 49.0 (n=20) | 109.0 (n=20) | 263.0 (n=8) | 513.0 (n=4) |
| Tarif (ana okuma) | 4.5 (n=20) | 20.8 (n=20) | 50.5 (n=20) | 106.0 (n=20) | 256.5 (n=8) | 496.0 (n=4) |
| Usta oyuncu, net iş ölçüsü | 3.5 (n=20) | 21.5 (n=20) | 51.0 (n=20) | 107.0 (n=20) | 257.5 (n=8) | 509.0 (n=4) |
| Usta oyuncu, teslim ölçüsü | 3.5 (n=20) | 21.1 (n=20) | 50.0 (n=20) | 106.0 (n=20) | 257.5 (n=8) | 506.0 (n=4) |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| USTA − E | -0.3 ± 0.1 (8/20) | 0.8 ± 0.3 (6/20) | 0.6 ± 0.5 (7/20) | 0.6 ± 0.7 (8/20) | 1.0 ± 1.6 (2/8) | 12.2 ± 1.2 (0/4) |
| USTA − R | -0.3 ± 0.1 (8/20) | 0.5 ± 0.2 (4/20) | 1.8 ± 0.4 (3/20) | -2.1 ± 0.5 (17/20) | -5.4 ± 0.8 (8/8) | -5.8 ± 1.9 (4/4) |
| USTA1 − E | -0.3 ± 0.1 (8/20) | 0.6 ± 0.2 (3/20) | -0.4 ± 0.4 (9/20) | 0.1 ± 0.5 (12/20) | 0.8 ± 1.4 (2/8) | 9.5 ± 1.0 (0/4) |
| USTA1 − R | -0.3 ± 0.1 (8/20) | 0.3 ± 0.1 (2/20) | 0.8 ± 0.3 (3/20) | -2.5 ± 0.3 (20/20) | -5.6 ± 0.7 (8/8) | -8.5 ± 3.2 (4/4) |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 6.0 (n=20) | 8.8 (n=20) | 8.0 (n=20) | 9.5 (n=20) | 9.8 (n=8) | 12.8 (n=4) |
| Tarif (ana okuma) | 6.0 (n=20) | 10.8 (n=20) | 10.0 (n=20) | 12.0 (n=20) | 14.2 (n=8) | 14.2 (n=4) |
| Usta oyuncu, net iş ölçüsü | 6.2 (n=20) | 11.0 (n=20) | 12.8 (n=20) | 13.5 (n=20) | 13.2 (n=8) | 12.2 (n=4) |
| Usta oyuncu, teslim ölçüsü | 6.2 (n=20) | 10.8 (n=20) | 11.0 (n=20) | 12.0 (n=20) | 12.8 (n=8) | 14.5 (n=4) |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| USTA − E | 0.2 ± 0.1 (2/20) | -0.2 ± 0.3 (10/20) | 2.2 ± 0.3 (0/20) | 1.1 ± 0.3 (6/20) | -1.2 ± 0.7 (6/8) | -3.4 ± 1.5 (4/4) |
| USTA − R | 0.2 ± 0.1 (2/20) | 2.3 ± 0.3 (0/20) | 4.1 ± 0.3 (0/20) | 3.8 ± 0.3 (0/20) | 3.4 ± 0.5 (0/8) | -0.6 ± 0.4 (3/4) |
| USTA1 − E | 0.2 ± 0.1 (2/20) | -0.1 ± 0.3 (8/20) | 0.7 ± 0.5 (6/20) | -0.5 ± 0.3 (10/20) | -1.8 ± 0.6 (6/8) | -1.6 ± 1.4 (2/4) |
| USTA1 − R | 0.2 ± 0.1 (2/20) | 2.4 ± 0.3 (0/20) | 2.6 ± 0.3 (0/20) | 2.2 ± 0.4 (2/20) | 2.9 ± 0.4 (0/8) | 1.1 ± 0.4 (0/4) |

Okuma: usta oyuncunun teslimi tariften (aynı PM kuralıyla) 3-25 kişide −0,4 ile +1,0 puan/hf aralığında (3 kişide +0,6-0,8 ± 0,2-0,3, yani 2-3 standart hata ama %3-4; ötekilerde standart hatanın içinde) (`USTA − E`: +0,8 ± 0,3, +0,6 ± 0,5, +0,6 ± 0,7, +1,0 ± 1,6; `USTA1 − E`: +0,6 ± 0,2, −0,4 ± 0,4, +0,1 ± 0,5, +0,8 ± 1,4); 50 kişide arama çoğunlukla R'nin otomatik atamasını seçiyor (`USTA` sprintlerin %100'ünde, `USTA1`'de bulduğu elle atama yalnız %33'ünde en iyi) ve 496'dan 506-509'a çıkıyor. R'nin atamasına tarifin PM'ini koyan `R_pme` kolu aynı yerde: 12 / 25 / 50 kişide 106,0 / 259,0 / 508,0; usta 107,0 / 257,5 / 509,0. Yani **usta oyuncu R'nin atamasından da iyi değil.** Açık hata: tarife göre 6 ve 12 kişide +2,2 / +1,1 (`USTA`) ya da +0,7 / −0,5 (`USTA1`), 25 ve 50 kişide −1,2 ile −3,4 (8 ve 4 tohum, standart hata 0,6-1,5). Tek kurucuda (1 kişi) arama teslimi 4,5'ten 3,5'e düşürdü: sprint içi ölçü yarım işi ve sırayı iyi gösterip uzun vadede kartı bitirmeyi bozabiliyor.

Bu sınır **yerel bir arama**; gerçek en iyi ondan iyi olabilir. Arama bir kazanç bulamadı; ayrıca ek bir üst sınır kondu: aynı tohumda 11 kuraldan (R, tarif ve dokuz kolu, rastgele, ters) en iyisini seçmek (seçim yanlılığı taşıyan, kural seçen bir usta):

| Ölçü | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| R ortancası | 4.5 | 21.1 | 49.0 | 109.0 | 264.0 | 514.0 |
| Tarif (E) ortancası | 4.5 | 20.8 | 50.5 | 106.0 | 258.5 | 498.0 |
| Seed başına en iyi kural (11 kuraldan) | 4.5 | 21.8 | 52.0 | 110.0 | 265.0 | 514.0 |

| Ölçü | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| R ortancası | 6.0 | 8.8 | 8.0 | 9.5 | 10.8 | 13.2 |
| Tarif (E) ortancası | 6.0 | 10.8 | 10.0 | 12.0 | 14.0 | 15.0 |
| Seed başına en az hatalı kural (11 kuraldan) | 6.0 | 8.5 | 8.0 | 9.0 | 10.5 | 12.2 |

Okuma: teslimde kuralları tohum başına seçebilen oyuncu R'nin üstüne 3 kişide +0,7 (%3), 6 kişide +3,0 (%6), 12 kişide +1,0, 25 kişide +1,0, 50 kişide 0 çıkıyor; açık hatada 0 ile −1,0 (%0-%8). Sınır küçük; seçim yanlılığı (en iyiyi seçmek gürültüyü de seçer) olduğundan gerçek kazanç bundan küçüktür.

**Kötü elle atama (rastgele, ters) tarife ve R'ye göre:**

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| Tarif (ana okuma) | 4.5 | 20.8 | 50.5 | 106.0 | 258.5 | 498.0 |
| Rastgele atama | 4.5 | 20.4 | 50.0 | 106.0 | 257.0 | 512.0 |
| Ters atama | 4.5 | 20.1 | 51.0 | 106.0 | 257.0 | 498.5 |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| RND − R | 0.0 ± 0.0 (0/20) | -0.3 ± 0.2 (12/20) | 0.8 ± 0.3 (2/20) | -3.1 ± 0.5 (19/20) | -6.8 ± 0.5 (20/20) | -3.0 ± 0.6 (16/20) |
| REV − R | 0.0 ± 0.0 (0/20) | -0.4 ± 0.2 (13/20) | 1.0 ± 0.3 (6/20) | -3.0 ± 0.4 (18/20) | -7.2 ± 0.5 (20/20) | -16.1 ± 0.6 (20/20) |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| RND − R | 0.0 ± 0.0 (0/20) | 1.0 ± 0.2 (1/20) | 1.4 ± 0.3 (3/20) | 1.2 ± 0.4 (4/20) | 0.9 ± 0.2 (2/20) | -0.1 ± 0.4 (9/20) |
| REV − R | 0.0 ± 0.0 (0/20) | 2.1 ± 0.3 (0/20) | 1.8 ± 0.3 (0/20) | 2.6 ± 0.3 (0/20) | 4.2 ± 0.2 (0/20) | 2.1 ± 0.3 (0/20) |

Okuma: tersine ve rastgele atamak teslimi R'nin altına 12 / 25 / 50 kişide −3,0 / −7,2 / −16,1 (ters) ve −3,1 / −6,8 / −3,0 (rastgele) indiriyor, yani en kötü atama bile −%3 teslim ve +%16-39 açık hata (ters atama) ile sınırlı. Tarife göre fark küçük ya da yok (rastgele 50 kişide tariften +13,9 iyi). Oyuncunun hata yapma alanı dar.

### 2.4 Ölçü 3: boşta kalmanın nedenleri

Boşta kişi-haftası, sprint içinde işsiz kalan zaman parçalarına göre nedene bölünür (D0s'un nedenlerinin ince hali; PM'in kendi zamanı ayrı satır). Payda kişi × pencere haftası.

**R**

| Neden (kişi-hafta payı) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| (a) uyan iş yok | 0.00% | 16.62% | 2.21% | 0.00% | 0.00% | 0.00% |
| (a) kart bitti | 26.35% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (b) PM hazırlığı | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (c) gereksinim | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (d) kadro tavanı | 0.00% | 0.00% | 0.00% | 0.05% | 0.01% | 2.31% |
| (e) kural/diğer | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| PM'in kendi boş zamanı | 0.00% | 0.00% | 9.27% | 8.39% | 2.75% | 3.07% |

**Tarif**

| Neden (kişi-hafta payı) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| (a) uyan iş yok | 0.00% | 18.66% | 1.72% | 0.00% | 0.00% | 0.00% |
| (a) kart bitti | 26.35% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (b) PM hazırlığı | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (c) gereksinim | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.08% |
| (d) kadro tavanı | 0.00% | 0.18% | 0.02% | 0.07% | 0.13% | 3.38% |
| (e) kural/diğer | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| PM'in kendi boş zamanı | 0.00% | 0.00% | 9.04% | 8.03% | 2.42% | 2.48% |

**Tarif, sert kapılar**

| Neden (kişi-hafta payı) | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| (a) uyan iş yok | 0.00% | 18.35% | 1.70% | 0.00% | 0.00% | 0.00% |
| (a) kart bitti | 26.35% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (b) PM hazırlığı | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (c) gereksinim | 0.00% | 0.59% | 0.13% | 0.47% | 0.16% | 2.03% |
| (d) kadro tavanı | 0.00% | 0.00% | 0.05% | 0.26% | 0.16% | 1.35% |
| (e) kural/diğer | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| PM'in kendi boş zamanı | 0.00% | 0.00% | 8.96% | 8.09% | 2.43% | 2.44% |

Okuma: 1 kişide tek neden "kart bitti" (%26,4): kurucunun sıradaki kartı 40 puanlık K3 ve 1,25 × 17 tavanına sığmıyor (D0s §4). 3 kişide "uyan iş yok" (%16,6 R, %18,7 tarif): üç kişi zincirin aşama sırasını bekliyor. 6 kişide %1,7-2,2. 12 ve 25 kişide boşta yok. 50 kişide kadro tavanı (%2,3 R, %3,4 tarif). **Gereksinim yüzünden giremeyen** veri kapılarında (tarif) hiçbir ölçekte %0,1'i geçmiyor; kapılar bir yıldız sertleşince (`E_sert`) %0,1-2,0 (50 kişide en yüksek). **PM hazırlığı nedeniyle boşta** PRD okumasında yok (PM hazırlığı işi durdurmuyor).

**PM hazırlığı iki okuma: bugünkü PRD (hız bonusu, işi durdurmaz) ve kapı ("hazırlıksız kart Geliştirmeye giremez")**

Kapı okumasında haftanın başında PM'ler sprintteki hazırlıksız kartları plan sırasıyla önce hazırlar, kartın Geliştirmesi hazırlık bitince açılır; PM zamanı bu iş için harcanır. Ek olarak PM'i az ekipler koşuldu: 11 kişi 1 PM (`S4_1PM`), 23 kişi 1 PM (`S5_1PM`), 46 kişi 2 PM (`S6_2PM`).

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) | S4_1PM (11 kişi) | S5_1PM (23 kişi) | S6_2PM (46 kişi) |
|---|---|---|---|---|---|---|---|---|---|
| R (D0s önerisi) | 4.5 | 21.1 | 49.0 | 109.0 | 264.0 | 514.0 | 109.0 | 234.0 | 463.0 |
| R + PM kapısı | 4.5 | 21.1 | 49.0 | 109.0 | 264.0 | 517.0 | 108.0 | 110.0 | 210.0 |
| Tarif (ana okuma) | 4.5 | 20.8 | 50.5 | 106.0 | 258.5 | 498.0 | 109.0 | 234.0 | 450.0 |
| Tarif + PM kapısı | 4.5 | 20.8 | 51.0 | 106.5 | 257.5 | 502.0 | 108.5 | 111.0 | 210.5 |

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) | S4_1PM (11 kişi) | S5_1PM (23 kişi) | S6_2PM (46 kişi) |
|---|---|---|---|---|---|---|---|---|---|
| R (D0s önerisi) | 26.4% | 16.6% | 2.7% | 0.1% | 0.0% | 2.6% | 0.1% | 0.0% | 2.5% |
| R + PM kapısı | 26.4% | 16.6% | 2.8% | 0.1% | 0.0% | 2.7% | 0.6% | 58.2% | 60.2% |
| Tarif (ana okuma) | 26.4% | 18.8% | 2.1% | 0.1% | 0.1% | 4.0% | 0.1% | 0.1% | 4.6% |
| Tarif + PM kapısı | 26.4% | 18.8% | 2.0% | 0.1% | 0.1% | 3.5% | 1.0% | 57.9% | 60.0% |

| Fark (a − b) | S1 | S2 | S3 | S4 | S5 | S6 | S4_1PM | S5_1PM | S6_2PM |
|---|---|---|---|---|---|---|---|---|---|
| R_gate − R | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | 0.1 ± 0.2 (4/20) | 0.3 ± 0.3 (5/20) | 0.8 ± 0.4 (6/20) | 2.9 ± 0.5 (1/20) | -1.0 ± 0.3 (13/20) | -124.2 ± 0.5 (20/20) | -253.1 ± 0.4 (20/20) |
| E_gate − E | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | 0.1 ± 0.4 (9/20) | 0.3 ± 0.6 (9/20) | 0.2 ± 0.8 (7/20) | 4.2 ± 0.7 (1/20) | -0.1 ± 0.4 (7/20) | -123.8 ± 0.4 (20/20) | -239.4 ± 0.6 (20/20) |

| Neden (kişi-hafta payı) | S1 | S2 | S3 | S4 | S5 | S6 | S4_1PM | S5_1PM | S6_2PM |
|---|---|---|---|---|---|---|---|---|---|
| (a) uyan iş yok | 0.00% | 18.66% | 1.57% | 0.00% | 0.00% | 0.00% | 0.00% | 9.54% | 9.32% |
| (a) kart bitti | 26.35% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| (b) PM hazırlığı | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.15% | 45.67% | 47.97% |
| (c) gereksinim | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.08% | 0.12% | 0.21% | 0.04% |
| (d) kadro tavanı | 0.00% | 0.18% | 0.05% | 0.06% | 0.09% | 3.01% | 0.64% | 0.00% | 0.00% |
| (e) kural/diğer | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.01% | 0.04% |
| PM'in kendi boş zamanı | 0.00% | 0.00% | 8.96% | 7.94% | 2.40% | 2.40% | 0.00% | 0.00% | 0.00% |

Okuma: PM yeterliyse (PM başına 6-8 kişi) **kapı okuması hiçbir şeyi değiştirmiyor**: teslim farkı 12 ve 25 kişide R'de +0,3 / +0,8, tarifte +0,3 / +0,2 (eşli, gürültü), 50 kişide +2,9 / +4,2 puan/hf (kapı lehine); PM hariç boşta farkı ±0,5 puanın içinde; çünkü kartlar bir önceki sprintte hazırlanıp giriyor (kapısız kollarda girişte hazırlık oranı 0,96-1,00). PM yetersizse çöküyor: 23 kişi 1 PM'de teslim 234,0 → 110,0 (−%53), PM hariç boşta %0,0 → %58, kişi-haftanın %46-48'i PM hazırlığını bekliyor; 46 kişi 2 PM'de 463,0 → 210,0 (−%55), %60 boşta. Kural: kapı okumasında ekibin teslim tavanı = PM'lerin hazırlık kapasitesi ÷ 0,2 (23 kişi 1 PM: 22 puan/hf ÷ 0,2 = 110). 11 kişi 1 PM'de (PM başına 11 kişi; PM kapasitesi 110 puan/hf, ekip 109) kapı tam sınırda: fark R'de −1,0 ± 0,3, tarifte −0,1 ± 0,4. İlk kapı denemesinde PM sprintteki kartları büyükten küçüğe hazırlıyordu: PM'i az ekiplerde MVP'nin küçük K1 kartları sürekli geride kalıp 60 haftada MVP hiç gelmedi; plan sırasına çevirince düzeldi (`out/_gate_v1/` ilk denemenin ham çıktısı).

### 2.5 Ölçü 4: darboğaz uyarısı

"Taşan aşama" = sprint sonunda o aşamada kalan iş ≥ aşama kapasitesinin %25'i (D0s'un darboğaz ölçüsü); tahmin: plan anında aşamanın yükü ÷ kapasitesi eşiği aştı.

| Ölçek | Taşma yok | Tasarım | Geliştirme | Test | Plan anındaki en yüklü satır = gerçekte taşan satır |
|---|---|---|---|---|---|
| R S2 | 4% | 0% | 0% | 96% | 90% |
| R S3 | 0% | 0% | 11% | 89% | 72% |
| R S4 | 0% | 0% | 0% | 100% | 100% |
| R S5 | 0% | 0% | 0% | 100% | 100% |
| R S6 | 0% | 0% | 0% | 100% | 100% |
| E S2 | 1% | 0% | 0% | 99% | 98% |
| E S3 | 1% | 0% | 2% | 97% | 82% |
| E S4 | 0% | 0% | 0% | 100% | 100% |
| E S5 | 0% | 0% | 0% | 100% | 100% |
| E S6 | 0% | 0% | 0% | 100% | 100% |

**Plan anında yük ÷ kapasite uyarısı (R'nin planı; tarifin planı `out/a3_tablolar.md` t9_plan_E)**

| Ölçek | Eşik (yük ÷ kapasite) | İsabet (precision) | Yakalama (recall) | Uyarı çıkan sprint | Gerçek taşma olan satır payı |
|---|---|---|---|---|---|
| S2 | > 1.00 | 99% | 79% | 85% | 43% |
| S2 | > 1.10 | 100% | 63% | 75% | 43% |
| S2 | > 1.25 | 100% | 45% | 58% | 43% |
| S2 | > 1.40 | 100% | 33% | 42% | 43% |
| S2 | > 1.60 | 100% | 18% | 24% | 43% |
| S3 | > 1.00 | 98% | 69% | 90% | 55% |
| S3 | > 1.10 | 100% | 44% | 69% | 55% |
| S3 | > 1.25 | 100% | 18% | 29% | 55% |
| S3 | > 1.40 | 100% | 2% | 4% | 55% |
| S3 | > 1.60 | - | 0% | 0% | 55% |
| S4 | > 1.00 | 99% | 90% | 100% | 39% |
| S4 | > 1.10 | 100% | 86% | 100% | 39% |
| S4 | > 1.25 | 100% | 86% | 100% | 39% |
| S4 | > 1.40 | 100% | 81% | 94% | 39% |
| S4 | > 1.60 | 100% | 21% | 24% | 39% |
| S5 | > 1.00 | 100% | 94% | 100% | 36% |
| S5 | > 1.10 | 100% | 94% | 100% | 36% |
| S5 | > 1.25 | 100% | 94% | 100% | 36% |
| S5 | > 1.40 | 100% | 94% | 100% | 36% |
| S5 | > 1.60 | 100% | 21% | 22% | 36% |
| S6 | > 1.00 | 100% | 100% | 100% | 33% |
| S6 | > 1.10 | 100% | 100% | 100% | 33% |
| S6 | > 1.25 | 100% | 100% | 100% | 33% |
| S6 | > 1.40 | 100% | 100% | 100% | 33% |
| S6 | > 1.60 | 100% | 19% | 19% | 33% |

**Oynatma uyarısı (tahmin = sonuç)**

| Ölçek | Eşik (yük ÷ kapasite) | İsabet (precision) | Yakalama (recall) | Uyarı çıkan sprint | Gerçek taşma olan satır payı |
|---|---|---|---|---|---|
| S2 | > 0.25 | 100% | 100% | 96% | 43% |
| S3 | > 0.25 | 100% | 100% | 100% | 55% |
| S4 | > 0.25 | 100% | 100% | 100% | 39% |
| S5 | > 0.25 | 100% | 100% | 100% | 36% |
| S6 | > 0.25 | 100% | 100% | 100% | 33% |

Okuma: (1) Taşan aşama 3 ve 6 kişide %89-99, 12 kişi ve üstünde %100 **Test**'tir; "taşma yok" sprintlerin %0-4'ünde. Yani "taşma yokken darboğaz satırı yazmaz" kuralı bu ekip karışımlarında satırı hep Test için yazdırır. Bunun nedeni plan kasten 1,25 × kapasite doludur (D0s) ve test kapasitesi dar kalır. (2) Plan anındaki yük ÷ kapasite uyarısı çok isabetli (eşik > 1,00: %95-100) ama yakalaması ölçeğe göre değişiyor (eşik > 1,25'te 3 kişide %45, 6 kişide %18, 12 ve 25 kişide %86-94, 50 kişide %100) ve 12 kişi ve üstünde zaten her sprintte çıkıyor. (3) Oynatma (planı iki hafta oynatıp kalan işe bakmak) bu çalışmada tahmin = sonuç olduğundan %100 isabet ve %100 yakalama verir; gerçekte tahmini bozabilecek olaylar (kâğıt, acil durum, söz olayı) simülasyonda yok [DEĞERLENDİREMEM].

**Uyarıyı dinleyen oyuncu:** en yüklü satır eşiği aşarsa o satırı en çok yükleyen yeni kartı çıkarıp o satırda en az yükleyen adayı al (sprint başına en çok bir takas). Eşik 1,5: uyarı 3 kişide %25 (tarif %48), 6 kişide %0 (%2), 12 kişide %52 (%62), 25 kişide %84 (%92), 50 kişide %93 (%93); takas 12-50 kişide %20-93. Eşik 1,25: uyarı %23-100, takas 3 ve 6 kişide %0, 12-50 kişide %68-100.

| Fark (a − b) | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|
| R_uyari − R | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | -0.7 ± 0.2 (13/20) | -1.8 ± 0.5 (13/20) | 0.1 ± 0.7 (7/20) |
| R_uyari2 − R | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | -0.1 ± 0.2 (7/20) | -1.2 ± 0.4 (13/20) | 0.2 ± 0.5 (10/20) |
| E_uyari − E | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | 0.7 ± 0.5 (7/20) | -0.3 ± 0.8 (9/20) | 0.7 ± 0.6 (7/20) |
| E_uyari2 − E | 0.0 ± 0.0 (0/20) | 0.0 ± 0.0 (0/20) | -0.8 ± 0.6 (13/20) | -0.2 ± 0.9 (10/20) | 1.3 ± 0.6 (5/20) |

Okuma: bir kart değiştirmek teslimi −1,8 ile +1,3 puan/hf (%0,7'den az) değiştiriyor, MVP'yi hiç değiştirmiyor; açık hata ±0,7. Uyarıyı dinlemek gürültüden ayrılan bir kazanç sağlamıyor.

### 2.6 Ölçü 5: ekrandaki atama ne sıklıkla değişiyor

Hafta sonunda aşaması süren bir kartta çalışan kişinin ertesi hafta başında başka karta geçme payı (aynı sprintin içinde / sprint sınırında):

| Kol | S1 | S2 | S3 | S4 | S5 | S6 |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 0% / 0% | 0% / 0% | 33% / 35% | 50% / 58% | 76% / 78% | 88% / 89% |
| Tarif, kişi hafta başı yeniden | 0% / 9% | 3% / 39% | 26% / 67% | 61% / 75% | 82% / 88% | 92% / 94% |
| Tarif (ana okuma) | 0% / 0% | 0% / 0% | 0% / 0% | 0% / 0% | 0% / 0% | 0% / 0% |

Sprint başında oyuncunun yeniden karar vermesi gereken kişi sayısı (kartında devam edenler hariç, ortalama):

| Kol | S1 (1 kişi) | S2 (3 kişi) | S3 (6 kişi) | S4 (12 kişi) | S5 (25 kişi) | S6 (50 kişi) |
|---|---|---|---|---|---|---|
| R (D0s önerisi) | 0.6 | 1.2 | 3.4 | 8.7 | 21.1 | 45.9 |
| Tarif, kişi hafta başı yeniden | 0.6 | 2.1 | 4.7 | 10.0 | 22.9 | 47.7 |
| Tarif (ana okuma) | 0.6 | 1.3 | 2.1 | 4.2 | 7.0 | 14.0 |

Okuma: R'de (D0s) her hafta başı yeniden dağıtım var: 6 kişide üçte biri, 12 kişide yarısı, 25 ve 50 kişide %76-89'u bir önceki haftanın kartından ayrılıyor, aşaması bitmediği halde. Tarifte "kart bitene kadar kalır" bunu **sıfıra** indiriyor (kişi aşaması bitmeden başka işe geçmiyor); sprint başında yeniden karar gereken kişi sayısı R'de 3,4 / 8,7 / 21,1 / 45,9'dan (6 / 12 / 25 / 50 kişi) tarifte 2,1 / 4,2 / 7,0 / 14,0'a iniyor (50 kişide %28'i). Kişi başına sıklık: 1 kişide 0,6, 3 kişide 1,3 karar.

**Uymayan iş ve moral (S3 + PM'in Test kutusu, 60 hafta):**

| Kol | Medyan en düşük moral (60 hf) | En az | En çok | Teslim |
|---|---|---|---|---|
| R (D0s önerisi) | -28 | -34 | -22 | 50.0 |
| Tarif (ana okuma) | -39 | -48 | -28 | 50.5 |

Okuma: "kalır" kuralı uymayan işte çalışan PM'i de orada tutuyor: PM'in 60 haftada kaybettiği moral R'de −28 (en çok −34), tarifte −39 (en çok −48). Kapı (D0s kapı 23) bandı 60 ile 90 koşulsuz içindi; koşullu için önerilen 20-35 bandının üstünde.

## 3. Yorumlar ve [GÖRÜŞ]

Ölçüm ayrı, görüş ayrı: aşağıda "Ölçüm" satırları §2'den sayıdır, "[GÖRÜŞ]" satırları benim okumamdır ve karar Erdem'indir.

### 3.1 Soru 1: atamayı kim yapar?

| Ekip | Atamanın teslime etkisi | Atamanın açık hataya etkisi | Sprint başında yeniden karar gereken kişi (tarif) | Kötü elle atamanın bedeli (R'ye göre) |
|---|---|---|---|---|
| 1 kişi | yok (tek kişi) | yok | 0,6 | yok |
| 3 kişi | −0,3 ± 0,2 puan/hf (tarif − R) | +2,5 (+%28) | 1,3 | rastgele −0,3, ters −0,4 puan/hf; hata +1,0 / +2,1 |
| 6 kişi | +1,2 ± 0,3 (+%2,4) | +1,9 (+%24) | 2,1 | rastgele +0,8, ters +1,0; hata +1,4 / +1,8 |
| 12 kişi | −2,7 ± 0,5 (−%2,5), tamamı PM kuralından | +2,7 (+%28) | 4,2 | rastgele −3,1, ters −3,0 (−%2,8); hata +1,2 / +2,6 (+%13 / +%27) |
| 25 kişi | −6,1 ± 0,7 (−%2,3) | +4,0 (+%37) | 7,0 | −6,8 / −7,2 (−%2,6-2,7); hata +0,9 / +4,2 (+%8 / +%39) |
| 50 kişi | −17,0 ± 0,6 (−%3,3) | +2,0 (+%15) | 14,0 | −3,0 / −16,1 (−%0,6 / −%3,1); hata −0,1 / +2,1 (−%1 / +%16) |

**Ölçüm.** (1) Elle atamanın teslime kazandırabileceği pay ölçülebilir değil: usta oyuncu araması tarife ve R'ye göre ±1 puan/hf içinde kalıyor ve R'yi geçemiyor (§2.3); kural seçen usta (11 kuraldan tohum başına en iyisi) R'nin üstüne en çok %6 (6 kişide) çıkıyor, çoğunlukla %0-1. (2) Kötü elle atamanın bedeli de küçük: teslimde en çok −%3, açık hatada +%16 ile +%39. (3) Atamanın asıl etkisi açık hata ve kartların hangi sırayla bittiği; toplam iş zaten korunuyor (aynı kişi-hafta, aynı kart havuzu, boşta yok). (4) R'nin kuralında (hafta başı yeniden dağıtım) elle atama sürdürülemez: 50 kişide 45,9 kişiyi her sprint başında yeniden karara bağlamak gerekir. "Kart bitene kadar kalır" bu sayıyı 14,0'a (50 kişi), 7,0'a (25), 4,2'ye (12), 2,1'e (6) indiriyor: elle atama ancak bu kuralla taşınabilir hâle geliyor.

**[GÖRÜŞ].** Atama kararı bu modelde **teslimi değil kaliteyi ve anlatıyı** belirliyor: kim hangi kart üzerinde çalışıyor oyuncunun gördüğü ve hissettiği bir şey, ama 12-50 kişide verimi %3'ten fazla oynatmıyor. Bu, (a) varsayılan olarak sistemin atamasını (tarifin "kalır" kuralıyla), (b) isteyen oyuncu için elle düzeltmeyi (kişiyi bir karta sabitlemek) ve (c) 25 kişiden büyükte PM'e/sisteme devri destekleyen bir tablo; ama tersini de kanıtlayan yok: Erdem'in "orta ekipte (6-12 kişi) elle atama güzel olabilir" düşüncesi ölçümle çelişmiyor, sprint başına 2-4 karar yük değil, kötü elle atamanın bedeli de küçük (oyuncu hata yaparak batmaz). Ancak "elle atama bir **karar**" demek için ölçümde dayanak yok: iyi elle atama bile teslimi artırmıyor. Yani oyuncuya "bu atama stratejik" demek yanlış bir söz verir [GÖRÜŞ]. PM'e devir (PM yıldızının atama kalitesini belirlemesi) bu çalışmada modellenmedi [DEĞERLENDİREMEM]; ölçülen aralık (rastgele ile tarif/R arası: teslimde ±%3, hatada ±%40) PM'e devrin kazancının üst sınırını da verir.

Küçük ekiplerde: 1 kişide atama yok. 3 kişide her rolde tek kişi var (kurucu, geliştirici, tasarımcı): kural farkı ±0,3 puan/hf; burada tarifin tek görünür etkisi kaynaklı arzda açık hata sıçraması (30,8 yerine 14,0 gibi, §2.1); nedeni olarak "yeten en düşük" kuralının küçük kartları 2★ hızındaki kurucuya vermesinden şüpheleniyorum [GÖRÜŞ, kart kart doğrulanmadı].

### 3.2 Soru 2: boşta kalma ve verim

**Ölçüm.** (1) D0s'un boşta payının (örn. 12 kişide %8,5; 25 kişide %2,8) neredeyse tamamı **PM'in kendi boş zamanıdır**; PM hariç boşta 6 kişide %2-3, 12 ve 25 kişide ≈ %0, 50 kişide %2,6-4 (kadro tavanı), 1 kişide %26 (kart bitti) ve 3 kişide %17-19 (uyan iş yok). (2) Erken biten kart: yalnız 1 ve 3 kişide; 6 kişi ve üstünde kart bitmesi boşluk yaratmıyor (plan %108-123 dolu, çekme neredeyse hiç devreye girmiyor). (3) PM hazırlığı yetişmediğinde, bugünkü PRD okumasında (hız bonusu verir, işi durdurmaz) kimse boşta kalmaz, yalnız bonus küçülür (girişte hazırlık oranı 0,955 ile 1,0). Kapı okumasında PM yeterliyse (PM başına 6-8 kişi) bir şey değişmiyor; PM yetersizse (23 kişide 1 PM, 46 kişide 2 PM) üretim yarıdan fazla düşüyor ve kişi-haftanın %46-48'i boşa gidiyor. (4) Gereksinim yüzünden girememe: veri kapılarında ≈ %0, kapılar bir yıldız sertleşince 50 kişide %2,0; kadro tavanı: 50 kişide %3,4.

**[GÖRÜŞ].** (a) Boşta kalma 6-25 kişide bir optimizasyon problemi değil: otomatik kurallar zaten boş bırakmıyor. Oyuncuya "kimseyi boşta bırakma" diye bir mekanik vermek yapay iş yaratır. Boşta payı bir **ekip kompozisyonu belirtisi** olarak değerli (3 kişide "uyan iş yok", 50 kişide "kadro tavanı", PM'in boş zamanı = fazla PM); plan ekranında nedeniyle yazılması yeter (PRD zaten böyle yazıyor). (b) 1 ve 3 kişideki yapısal boşta atamayla kapanmaz, planın büyüklüğü ve alım kararıyla kapanır. (c) Kapı okuması ("hazırlıksız kart Geliştirmeye giremez") yapay bir tavan koyuyor: ekibin teslimi PM sayısının ÷ 0,2'si ile sınırlı (22 puan/hf PM = 110 puan/hf ekip). PM başına 11 kişiden fazla düşen bir koşuda (23 kişide 1 PM) oyun "PM yoksa kod yok" olur; PRD'nin "PM'siz ekibe ceza yok" hükmüyle çelişir. PRD okuması (bonus ver, durdurma) kalmalı [GÖRÜŞ]. (d) Çalışanın kartı erken bitirdiğinde ne olduğu önemli: çekme kuralı (Karar 11) 6 kişi ve üstünde sprint başına en çok 0,05 kart çekiyor (plan zaten %108-123 dolu); yani "erken bitti" yalnız tek kurucu ve 3 kişide yaşanıyor.

### 3.3 Soru 3: darboğaz

**Ölçüm.** Bu ekip karışımlarında (D0s'un S3-S6'sı) taşan aşama neredeyse hep **Test**'tir (12 kişi ve üstünde %100, 3-6 kişide %89-99). Plan 1,25 × kapasiteye kadar kasten doldurulduğundan Test'te her sprint kalan iş var; "taşma yok" sprint %0-4. Plan anındaki yük ÷ kapasite uyarısı isabetli (precision %95-100) ama ya hep çıkıyor (12-50 kişi: sprintlerin %100'ü) ya da ölçeğe göre geç yakalıyor (3-6 kişide eşik 1,25'te %45 ve %18 yakalama). Uyarıya bakıp bir kart değiştirmek teslimi %0,7'den az oynatıyor.

**[GÖRÜŞ].** (a) Bugünkü haliyle "taşma yokken yazmaz" kuralı (Erdem 26) pratikte hep "Test" yazar; bilgi taşımaz. (b) Darboğaz uyarısı sprint planı aracı değil **alım sinyali** olarak anlam kazanır: "Test aşamasında üç sprinttir iş kalıyor: bir testçi" (12-50 kişide tek kalıcı darboğaz ekip karışımından geliyor; atama onu kapatmıyor). (c) Plan ekranının gösterebileceği ve %100 doğru olan şey oynatma: "bu kart bu sprintte bitmeyecek, Test'te bekliyor" (tahmin = sonuç); eşik uyarısından üstündür. (d) Uyarı eşiği, planın bilerek bıraktığı payı (0,25) görmemeli: satır yükü ÷ kapasite > plan toplam doluluğu + sabit pay gibi göreli bir eşik gerekir; bunu bu çalışmada koşmadım.

### 3.4 Tarifin kendisi için yorumlar (E1)

1. **Tarif R'ye göre teslimde 12 kişide −%2,5, 25'te −%2,3, 50'de −%3,3; kaynaklı arz ve sözde 25 ve 50 kişide −%4,4 ve −%7,0** kaybettiriyor ve her ölçekte açık hata artırıyor (+%15-37, 3 kişide kaynaklı arzda iki katından fazla). Teslim kaybı PM kuralından (12-25 kişi), hata artışı atama kuralından geliyor (§2.2). Ölçüm kanıtı: `E_pmr` (tarif atama + R'nin PM'i) teslimi 12 kişide R'ye eşitliyor (+0,7), `R_pme` hata eklemiyor.
2. **PM tarafında "yeten en düşük yıldızlı PM" kısmı kaybettiriyor ve kazanç getirmiyor**, çünkü PM zamanı kıt değil (kendi boş zamanları %20-56). "Gereksinimi yüksek karta en iyi PM" kısmı R'nin kuralıyla aynı sonucu veriyor. [GÖRÜŞ] PM tarafında yalnız bu ilk cümle kalsın; "küçük kartlara düşük yıldızlı" cümlesi, PM zamanı gerçekten kıtsa (PM başına 11 kişiden az düşen ekiplerde) anlamlıdır.
3. **Atama tarafında hata artışının nedeni "yeten en düşük" kuralının işi kartlara eşitsiz dağıtması** (aynı yıldız toplamı, farklı dağılım) [GÖRÜŞ, kart kart doğrulanmadı]. `E_min` (en iyiler yetecek kadar) hatayı 0,3-1,1 azaltıyor; rastgele atama tariften 0 ile 3,0 daha az hata bırakıyor (R'ye göre +0,9 ile +1,4). Kalıcılık (`E_np` ile karşılaştırma) hatayı 25 ve 50 kişide 1,4 ve 1,2 artırıyor ama teslimi değiştirmiyor.
4. **"Kart bitene kadar kalır"** ekrandaki değişimi R'deki %33-89'dan %0'a indiriyor ve sprint başı karar sayısını üçte birine (50 kişi: 45,9 → 14,0) düşürüyor; teslime etkisi ölçülemiyor (E_np − E: −0,8 ile +0,9). Bedeli: uymayan işte (örn. Test kutusu verilmiş PM) çalışan kişi o işte kalıyor ve moral kaybı 60 haftada −28'den −39'a çıkıyor. [GÖRÜŞ] kuralın istisnası: uymayan iş yalnız hafta sonuna kadar.
5. **Gereksinim** veri kapılarıyla (≤ ★3) ekibin 5★ ölçeğinde nadiren bağlıyor (boşta nedeni %0,1'in altı), ama kaliteyi koruyor: gereksinim kalkınca açık hata 6 / 12 / 25 kişide +5,7 / +3,0 / +3,3 artıyor (teslim aynı). Kapıları bir yıldız sertleştirmek teslimi de hatayı da değiştirmiyor (50 kişide boşta nedeni gereksinim %2,0'a çıkıyor). Gereksinim kuralı zararsız, faydalı.
6. **Küçük ve ilk sıradaki kartlar** (söz, istek, MVP kartları) plan sırasından uzaklaşıldığında aç kalıyor: kalan kartları gereksinim/büyüklük sırasıyla dizen okuma 25 ve 50 kişide MVP'yi 2. haftadan 6. haftaya itiyor. Tarifin "kalan kartlar" cümlesi plan sırasını korumalı; bunu tarifin açık cümlesine eklemek gerekir [GÖRÜŞ].
7. **Kaynaklı arzda 6 kişide kaçan söz %0 → %9,5** (eşli +9,6 pp ± 1,6): söz kartı plan sırasında önde olsa da en yüksek gereksinimli kartın en iyi kişileri toplaması söz kartının kişisini geciktiriyor olabilir; nedeni kart kart izlenmedi [DEĞERLENDİREMEM].

### 3.5 Erdem'e kalan sorular (sade)

1. **Elle atama:** 12 kişilik ekibin planında her çalışanı elle bir karta koyabilsen ve istemezsen "otomatik"e bırakabilsen yeterli mi? (Ölçüm: elle koymak teslimi artırmıyor; kötü koymanın bedeli %3 teslim, %16-39 daha çok açık hata.) Seçenekler: (A) varsayılan otomatik, elle düzeltme isteğe bağlı; (B) elle atama hiç olmasın, atamayı hep sistem yapsın; (C) elle atama temel mekanik olsun (ölçüm bu seçeneği desteklemiyor).
2. **Hazırlık yetmezse kart dursun mu?** Bugünkü hüküm: dursun demiyor, hız bonusu küçülüyor. Dursaydı: 23 kişilik ekipte 1 PM varken üretim yarıya iner. (A) durmasın, bonus küçülsün (öneri); (B) dursun, PM sayısı üretim tavanı olsun.
3. **Küçük kartlara en düşük yıldızlı PM:** bunu istiyor musun? Ölçüm: teslim %1-3 düşüyor, kazanç yok (PM zamanı bol). (A) PM tarafında yalnız "yüksek gereksinimli karta en iyi PM" kalsın; (B) tarif olduğu gibi kalsın.
4. **"Kart bitene kadar kalır" uymayan işi de tutsun mu?** Tutarsa Test kutulu PM'in morali 60 haftada −28 yerine −39 olur. (A) uymayan iş yalnız haftalık; (B) tutsun.

## 4. Doğrulama

| Doğrulama | Beklenen | Bulunan | Sonuç |
|---|---|---|---|
| `dsim3.py` değişmedi | dosya D0s incelemesinden beri aynı | son yazım 18 Ekim 23:04:35 (bu çalışmadan önce), md5 `42968e2e3a470411e3cfc1cfd1b96f6b`; `dsim3_orig.py` md5 `0b6a76f85a6b60ce53ccd1027c4f0e27`. (`out/dsim3.md5` içindeki `ff16e234…`, D0s'un inceleme yamasından önceki kaydıdır, bayat.) | GEÇTİ |
| `D3_LEGACY=1` altında `dsim3.py` = `dsim3_orig.py` | 0 fark | S1, S3, S4, A\|S3\|kaynakli\|2, GC\|kaynakli, EA3 × 2 tohum: 660 metrik, 0 fark (`out/a3_dregress_leg.txt`) | GEÇTİ |
| `week3` (kancalı kopya) = `D.week2` (R ayarı) | 0 fark | 17 senaryo × 3 tohum: S1-S6, PR\|S3, PR\|S4, DEP\|S3, A\|S4\|kaynakli\|2, GC\|kaynakli, HUY\|S4, S3_PM_testkutulu, S8, S12, EA3, S5_1PM: 3.774 metrik, 0 fark (`out/a3_regress.txt`) | GEÇTİ |
| Eski ve R kolları D0s tablolarıyla aynı | D0s §12'nin satırları | teslim (eski: 5,1 / 20,1 / 48,0 / 108,0 / 267,5 / 540,0; R: 4,5 / 21,1 / 49,0 / 109,0 / 264,0 / 514,0), açık hata, boşta, MVP, plan doluluğu birebir | GEÇTİ |
| Tarifin mikro testleri (elle hesaplı) | 9/9 | 9/9: gereksinim 4★ karta en iyi iki; kalan kartlar plan sırasıyla yeten en düşük; tek yetmeyince en düşük yeten ikili; artan yardıma; uymayan iş son; ters kip; en iyiler yetecek kadar; kalan kartlar gereksinim sırasıyla (`out/a3_micro.txt`) | GEÇTİ |
| Aynı girdi aynı atama | kişi listesi düz, ters, karışıkken aynı atama satırları ve teslim | tarif ve R, S3 / S4 / S5, 16 hafta: 6/6 aynı | GEÇTİ |
| Tahmin = sonuç | ≤ 1e-6 | 3.548 kayıtlı koşunun hepsinde en büyük fark 7,1e-15; ayrıca 14 kol × 6 senaryo × 3 tohum = 252 koşu ve USTA / kapı kolları 18 koşu | GEÇTİ |
| PM kapısı değişmezi | hazırlığı bitmemiş özellik kartının Geliştirme ilerlemesi 0 | 18.476 kontrol, 0 ihlal. **Sınama:** aynı denetim kapısız kollarda (`E`, `R`) 588 ihlal yakalıyor: denetim boş değil (`out/a3_gate_degismez.txt`) | GEÇTİ |
| "Kalır" değişmezi | hafta sonunda aşaması süren kişi ertesi hafta başında aynı kartta | tarif: 0 değişim (tüm ölçekler); `E_np` kolunda 6-50 kişide %26-94 (denetim değişimi görüyor) | GEÇTİ |
| Ustalık sonucu tariften ve R'nin otomatik atamasından kötü olamaz | sprint ölçüsünde kazanç ≥ 0 | her ölçekte `gain_e`, `gain_r` ≥ 0 (yapıdan gelir: üç aday arasından en iyisi seçilir) ve elle atamalı oynatma da tahmin = sonuç veriyor | GEÇTİ |

**Veri kaynağı.** `data/product/lines/erp.json` `e68e19fe9bf6a66c2f212578a8383f415c1293ba`, `shared.json` `c6e74592113402f3e5be17dba6e178350f5f99f4`, `note_tool.json` `d543a18a6cb48c6f801aa18339ab71c865ea85a3`, `video_clip.json` `602eb21e6c324f28e3e2d2b0ebb8681c1e2dd22f` (git blob özetleri; `910ad1f`'te ve çalışma ağacında aynı); `line_gates.gd` md5 `595f58b77b54cb12b0dc19fb00c3329d` (iki yerde aynı). Gereksinim yalnız ERP + paylaşılan hatlardan türedi; B2C alt türlerinin kapıları aynı biçimde (K2 ★1-2, K3 ★2-3) ama koşulmadı.

**Çalışma sırasında bulunan ve düzeltilen yanlış okumalar (ilk denemelerin ham çıktıları saklı):**
1. İlk "yeten" okuması aşama ufkuydu ve kalan kartları gereksinim/büyüklük sırasıyla dizdi: küçük ve ilk sıradaki kartlar aç kaldı, MVP 25 kişide 6., 50 kişide 8. haftaya kaydı (teslim 257,0 ve 497,0; açık hata 17,0 ve 16,0). Ana okuma: kartın sprintte bitmesi için aşamaya düşen süre payı ve plan sırası. İki alternatif kol olarak duruyor (`E_asama`, `E_gsira`).
2. İlk PM kapısı sprintteki hazırlıksız kartları büyükten küçüğe hazırlıyordu: PM'i az ekiplerde MVP'nin küçük kartları hiç hazırlanmadı (60 haftada MVP gelmedi). Plan sırasına çevrildi (`out/_gate_v1/` ilk denemenin ham çıktısı).
3. Usta aramanın ilk ölçüsü teslim ağırlıklıydı ve beklenen değil gerçek hata zarını görüyordu, ayrıca tercih listelerinde çekilen kartlar yüzünden 3-12 kişide çöktü; ölçü beklenen hataya çevrildi ve ikinci bir ölçüyle (`USTA` / `USTA1`) iki kez koşuldu.
4. Mikro testlerden biri kartların kimlik hatırlamasını (kalır kuralı) görmeden aynı kartlarda ikinci kez koşuyordu; yeni kartlarla yeniden kuruldu.

## 5. Bitmeyenler ve sınırlar

- **PM'e devir** modellenmedi (PM yıldızının atama kalitesini belirlemesi) [DEĞERLENDİREMEM]. Yalnız dolaylı: rastgele ile tarif/R arası aralık üst sınırdır.
- **Usta oyuncu yerel bir arama:** tek sprintlik ufuk, iki sprint içi ölçü (net iş ve teslim ağırlıklı); çok sprintli planlama yok; 25 ve 50 kişide 8 ve 4 tohum, sprint başına 63 ve 33 oynatma. Gerçek en iyi bundan iyi olabilir; ama iki ölçü de, 11 kurallı seçici sınır da aynı yönde. 1 kişide arama teslimi 4,5'ten 3,5'e düşürdü: sprint içi ölçü uzun vadeyi iyi göstermiyor.
- **Kural seçen usta** tohum başına en iyiyi seçtiği için seçim yanlılığı taşır; gerçek kazanç bundan küçüktür.
- **Gereksinim verisi** yalnız ERP + paylaşılan hatlardan; yıldız ölçeği bugünkü 1-3, kişiler 5★ ölçeğinde. `total` ve `research` kapıları atamaya girmedi ("geçilmiş" sayıldı). 5★ ölçeğine geçişte kapıların yeniden yazılacağı varsayımı tek kol (`E_sert`, +1★).
- **Kaynaklı arz** (`PR`: 80 hf, `DEP`: 104 hf) yalnız R, tarif ve eski kural için; DEP yalnız 6 / 12 / 25 kişi; EA takım kipi ölçülmedi (kapsam dışı). Kaynaklı arzdaki üç sonucun nedeni kart kart izlenmedi: 3 kişide açık hata 14,0 → 30,8, 6 kişide kaçan söz %0 → %9,5, büyük ekipte −%4,4 / −%7,0 teslim [DEĞERLENDİREMEM].
- **Kapı okumasında** PM'in sprint içi hazırlığı haftalık ayrıntıda: PM zamanı haftanın başında dağıtılır, kartın Geliştirmesi hazırlık bittiği anda açılır; hafta ortasında çekilen kart ertesi hafta başına kadar kapalı kalır (çekilen kart seyrek).
- **Dinleyen oyuncu** tek bir takas kuralı (en yüklü satırı en çok yükleyen yeni kartı çıkar, o satırda en az yükleyeni al); başka tanımlar denenmedi.
- **Darboğaz uyarısının eşiği** planın bilerek bıraktığı 1,25 payını görmüyor; göreli eşik koşulmadı. Kâğıt, acil durum, söz olayı gibi tahmini bozacak olaylar simülasyonda yok.
- **Atamanın hata etkisinin nedeni** (aynı yıldız toplamı, farklı kart dağılımı) bir açıklama; kart kart izlenmedi.
- **Plan hesabının süresi** (Godot'ta) ölçülmedi. D0s'un koşulmayan anahtarları (çeyrek hedefi, ücretli plan) simülasyonda yok.

## 6. Yeniden üretim

Klasör: `docs/tasks/faz_cde/d_taslak/dsim/v3/atama/`. Hepsi `python -I`; ortam değişkenleri komuttan önce; en çok 2 işçi; her `chain.sh` çağrısı 420 sn bütçeyle bitip eksik işi önbellekten tamamlar. R okuması `a3core.py` içinde varsayılır (`D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h`); eski kural için `D3_LEGACY=1`.

```
bash chain.sh main R,E,E_np,E_min,E_sert,E_pmr,R_pme,E_gate,R_gate,E_gsira,E_asama,RND,REV S1,S2,S3,S4,S5,S6 20
D3_LEGACY=1 bash chain.sh main L S1,S2,S3,S4,S5,S6 20
bash chain.sh main E_gyok S1,S2,S3,S4,S5,S6 20
bash chain.sh main R,R_gate,E,E_gate S4_1PM,S5_1PM,S6_2PM 20          # PM'i az ekipler (kapı okumasının sınavı)
bash chain.sh main R_uyari,E_uyari,R_uyari2,E_uyari2 S2,S3,S4,S5,S6 20
bash chain.sh main R,E S3_PM_testkutulu 20
bash chain.sh pr R,E "PR|S1,PR|S2,PR|S3,PR|S4,PR|S5,PR|S6" 20 ;  D3_LEGACY=1 bash chain.sh pr L "PR|S1,..,PR|S6" 20
bash chain.sh dep R,E "DEP|S3,DEP|S4,DEP|S5" 20 ;  D3_LEGACY=1 bash chain.sh dep L "DEP|S3,DEP|S4,DEP|S5" 20
bash chain.sh kal R,E S3,S4,S5,S6 20                                   # işin yıldız dilimlerine dağılımı
bash chain.sh usta R,E,USTA,USTA1 S1,S2,S3,S4 20 ; bash chain.sh usta R,E,USTA,USTA1 S5 8 ; bash chain.sh usta R,E,USTA,USTA1 S6 4
python -I a3test.py micro | det | gate "S3,S4,S5_1PM" 2 | pred "S1,S2,S3,S4,S5,PR|S3" 3 R,E,... | regress "<senaryolar>" 3
python -I a3tablolar.py > out/a3_tablolar.md                           # 62 ham tablo
python -I a3rapor.py                                                   # bu belge (ATAMA/A3_OLCUM.md)
```
(`run_rest.sh` … `run_rest7.sh` yukarıdaki sırayı kaydeder; `D3_LEGACY=1` sonuçlarının ayrı süreç olması gerekir.) Dosyalar: `a3core.py` (tarif, PM kuralı, kapı, ustalık, `week3`, `A3Sim`), `a3run.py` (kollar `ARMS`, koşucu), `a3test.py` (doğrulama), `a3tab.py` ve `a3tablolar.py` (tablolar), `a3rapor.py` (belge), `veri/` (kapı verisinin git kopyaları), `out/` (ham sonuçlar, günlükler).
