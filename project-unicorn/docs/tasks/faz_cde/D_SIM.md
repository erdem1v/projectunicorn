# Faz D · Ekip modeli simülasyon raporu
Hazırlayan: simülasyon alt ajanı, 17 Ekim 2026. Repo kodu değişmedi. Kaynak: `D_MODEL_v2.md` §6 ("Simülasyon tanımı"), birebir uygulandı.

Betik: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dsim/dsim.py` (sonuç toplama `collect.py` ve `collect2.py`, §6.9 doğrulaması `check69.py`, rapor üretimi `x_rapor.py`; hepsi aynı klasörde, `python -I dsim.py exec <dosya>` ile koşar).

## 0. Özet
1. §6 uygulandı: 145 senaryo × 20 tohum = 2900 koşu, her koşu 60 hafta. Ölçüm penceresi 21-60. hafta, ölçüler 20 tohumun medyanı.
2. Belgenin 5 tohumluk ön hesabı 20 tohumla yeniden üretildi. S1-S6 teslimi: 6,2 / 22,5 / 55 / 116 / 256 / 496,5 (belge 6,1 / 21,9 / 55 / 116 / 257 / 498). Uç bileşimlerde teslim ve boşta belgeyle uyumlu (en büyük fark S9a, %8).
3. §6.9'un elle doğrulama örneklerinin hepsi tutuyor (kadro, bitiş süresi, E, hazırlık süresi).
4. 10 kırılma ölçütünden 9'u GEÇTİ, **1'i KIRIK**: kişi ekleme eğrisinde 48. kişi (geliştirici) teslimi 470'ten 467'ye düşürüyor (-3,0 puan/hafta, tolerans -1; teslimin %0,6'sı; 20 tohumun 16'sında aynı yön). Neden atama değil sprint alımı: kapasite tavanı yeni kişiyle büyüyor, sprint daha çok kart alıyor, yarım kalan kart yığını büyüyor.
5. Tek kurucuda A'nın hata sprinti hedefi tutmuyor: geç pencerede %5,6 (hedef ≤ %5), 20 tohumun 2'sinde üst üste iki hata sprinti var. Belgenin 5. ölçütü tek kurucuyu bu hedefe bağlamıyor; ayrı not olarak Kırılmalar'da.
6. Baskın rol karışımı yok. Testçisiz (kutu işaretsiz), hepsi testçi ve hepsi geliştirici karışımları 12 kişide bile teslimin büyük kısmını kaybediyor ve 50 kişiye çıkınca teslim artmıyor (tasarımı ve testi yalnız kurucu yapıyor). Geliştiricilere Test kutusu verip testçi almamak ref karışımdan %2 (12 kişi) ile %10 (25 kişi) geride kalıyor: testçi rolünün ek değeri küçük.
7. Hata ve düzeltme payı ölçekle patlamıyor, küçülüyor: kart başı kaçan hata 6 ile 50 kişi arasında 0,52-0,63 (S3-S6'da hep 0,57), düzeltme payı %5 → %3. Açık hata ekiple büyüyor (8 → 19 medyan); 50 kişide 400 kapanışın 6'sında ≥ 30, yani A'nın mutlak itibar eşiğine yakın.
8. Tek kurucunun MVP'si 20 tohumun hepsinde 6. haftada. Tahmin = sonuç denetimi 115 senaryo × 20 tohumda en çok 3,6e-15 fark verdi.
9. Düzeltme turu (aynı gün): iki kırılma modelde düzeltildi, bütün koşu yeniden yapıldı; 10 ölçütün 10'u geçiyor, tek kurucu A'nın hedefini tutuyor. Ayrıntı §15. §1-§14 düzeltme öncesi modelin ölçümüdür.

## 1. Yöntem ve yorumlar
- **Tohum ve pencere.** Tohum 1-20; her koşu 60 hafta (son sprint 61. haftaya taşabilir); ölçü penceresi kapanışı 20. haftadan sonra olan sprintler. Ölçüler tohum medyanı; hata sprinti oranı ve üst üste denetimi 20 tohum toplanarak.
- **Süre.** 2900 koşu 12 çekirdekte yaklaşık 4 dakika; S6 (50 kişi) tek tohumda yaklaşık 2 saniye.
- **Uygulama.** `fit`, `rate`, kadro, zaman sıralı hafta, planlama adım 1-7, kapanış, Poisson çekilişi, MVP bekleme listesi ve RNG sırası §6'daki gibi. Kod modelin kopyasıdır, motor kodu değildir.

**Yorumlar** (§6'nın tek anlamlı olmadığı yerlerde seçilen en makul okuma):
1. PM'in hazırlık yapması için Yapım kutusunun açık olması gerekir (§6.3 hazırlığı 'PM ana alan' diye tanımlıyor, kutu söylemiyor). Bu, 'S3'te Selin'e Test kutusu' senaryosunun belge sonucuyla (hazırlık %70'e iner, teslim 55'ten 50'ye) uyumlu.
2. Planlama 5(b) 'kopya > 0 iş alır': kopyanın o 2 haftalık oynatmada aldığı ilerleme artışı sayılır. Tasarımcının önden yaptığı tasarım ilerlemesi sayılmaz.
3. Darboğaz: her kapanışta devreden kartların bekledikleri aşamadaki kalan işi aşama başına toplanır, pencere sprintleri üzerinden sprint başına ortalaması alınır, tohum medyanı en büyük olan aşama darboğazdır; hiçbiri 1 puanı geçmezse 'yok'.
4. Düzeltme payı penceresi: 'erken' = MVP haftasında ya da sonra başlayıp MVP'den sonraki ilk 20 haftada başlayan sprintler; 'geç' = kapanışı 20. haftadan sonra olanlar. Hata sprinti: pay > 0,5. Üst üste denetimi MVP sonrası bütün sprintlerde.
5. Dağılım listesi [6,4,8,5,3,6,7,4,5,6] 10 kişiden uzun rol grubunda başa sarar (S5'te 12, S6'da 25 geliştirici).
6. Eşitlikte 'kimlik' = takım listesindeki sıra. Taban hata akışı hatlara `rng.choice` ile (canlı hatlar numara sırasıyla) dağılır.
7. Kişi ekleme eğrisi: S6'nın oranı (6 PM, 8 tasarımcı, 25 geliştirici, 10 testçi) sabit karışımdır. Kurucudan sonra her yeni kişi hedef orandan en çok geri kalan rolden seçilir (eşitlikte geliştirici, testçi, tasarımcı, PM sırası). Her n bir öncekinin üstüne bir kişi ekler; eğri tek bir büyüyen ekibin tarihçesidir. 50. kişide S6 ile aynıdır.
8. Marjinal getiri = ekip+1 ile ekibin tohum medyanlarının farkı. Eklenen kişiler: 3★ = ana puan 6, ikincil 5 (PM: tasarım 5, test 2); 1★ geliştirici = yazılım 2, test 1.
9. K4 deneyleri: 'S8'e Test kutulu geliştirici' = ek 1 geliştirici (3★, Yapım+Test); ayrıca bütün 10 geliştiricinin Test kutusu işaretli hâli. 'S11'e testçi' ve 'S9a'ya geliştirici' = 1 kişi, 3★.
10. K8 için S4'e hem 1 PM (dağılım başı, puan 6) hem 2 PM (belgenin S4'ü) eklendi. 'S5'te tek PM' = 3 PM yerine 1.
11. K7 deneyi: S3'te Ayşe'nin test puanı 2/4/6/8/10 (yazılım = test-1); S4 benzeri ekipte (2 PM, 2 tasarımcı, 5 geliştirici) iki testçi de aynı puanda.
12. Genel ölçütler için eklenenler (§6'da yok): rol karışımı karşılaştırması (12/25/50 kişide 10 karışım, kurucu hep var, oran en büyük kalan kuralıyla yuvarlanır), 12/25/50 kişide tüm testçilerin 1★ ya da 5★ olduğu deneyler, akış ölçüleri (sprintteki kart sayısı ve bekleme süresi).
13. Tahmin = sonuç (§6.13): kopya önden tasarım ve hazırlık kuyruğuyla birlikte oynatılır; kapanışta kart başına aşama ilerlemesi, bitiş zamanı (kesirli hafta) ve E karşılaştırılır.

## 2. §6.9 elle doğrulama
| Örnek | Beklenen (§6.9) | Bulunan |
|---|---|---|
| K1 geliştirme ağırlıklı (2/10/3), S7 ekibi, tek kart | kadro [1,2,1]; 1. haftada biter; testi 4★ testçi; E≈0,22; boşta ≈6,7 kişi-hafta | kadro [1, 2, 1]; biter 0,86 hf; test: T4 3,00; E=0,218; boşta 6,68 |
| K3 test ağırlıklı (4/22/14), S7 ekibi, tek kart | kadro [1,3,2]; 2. haftada biter; test 4★ ve 3★ testçide; E≈0,64 | kadro [1, 3, 2]; biter 1,61 hf; test: T4 7,99, T1 6,01; E=0,637 |
| K3 geliştirme ağırlıklı (6/26/8), 3★ tasarımcı ve testçi, 1-6 adet 3★ geliştirici (kartın süresi, hafta) | [3,45, 2,33, 1,96, 1,77, 1,77, 1,77] | [3,45, 2,33, 1,95, 1,77, 1,77, 1,77] |
| K2 (25 puan), 2,5★ geliştirici, hazırlıksız, testi tek kişi: kaçan hata E | yok 0,75; kurucu 0★ 0,54; 3★ 0,43; 5★ 0,33 | yok 0,75; kurucu 0★ 0,54; 1★ 0,51; 2★ 0,47; 3★ 0,43; 4★ 0,38; 5★ 0,33 |
| Hazırlık süresi, 3★ PM | K1 0,26 hafta; K3 0,69 hafta | K1 0,26 hafta; K3 0,69 hafta |

S7 testçileri: T1 = 3★, T2 = 2,5★, T3 = 2★, T4 = 4★, T5 = 1,5★.

Hepsi tutuyor. Tek ince fark: 3. dizide 3 geliştiricide 1,95 çıktı (belge 1,96; yuvarlama).

## 3. Senaryo tabloları (§6.8, 21-60. hafta, 20 tohum medyanı)
Teslim = biten özellik kartlarının büyüklükleri toplamı ÷ hafta. Boşta = kişi-hafta/hafta. Kaçan hata = biten özellik kartı başına E. 'Açık hata' her kapanıştan sonraki toplam açık hatanın medyanı; 'açık max' pencerede görülen en yüksek değerin tohum medyanı.

### 3.1 Hız ve boşta
| Senaryo | Kişi | Teslim/hf (en az-en çok) | Puan/hf | Kişi başı | Kart/sprint | Boşta | Darboğaz | Hazır kart | MVP hf |
|---|---|---|---|---|---|---|---|---|---|
| S1 · kurucu | 1 | 6,2 (4,9-7,4) | 8,9 | 6,22 | 0,5 | 0,1 | Test | 0% | 6 |
| S2 · 3 kişi | 3 | 22,5 (20,9-23,5) | 21,2 | 7,50 | 1,2 | 0,5 | Geliştirme | 0% | 4 |
| S3 · 6 kişi | 6 | 55,0 (54,0-56,0) | 39,6 | 9,17 | 2,8 | 0,3 | Geliştirme | 100% | 4 |
| S4 · 12 kişi | 12 | 116,0 (114,0-118,0) | 93,7 | 9,67 | 5,8 | 0,2 | Geliştirme | 87% | 2 |
| S5 · 25 kişi | 25 | 256,0 (255,0-258,0) | 224,4 | 10,24 | 12,8 | 0,5 | Geliştirme | 69% | 2 |
| S6 · 50 kişi | 50 | 496,5 (494,0-500,0) | 443,4 | 9,93 | 24,8 | 2,6 | Geliştirme | 64% | 2 |
| S7 · küçük kartlara 5 testçi (8) | 8 | 25,6 (24,6-26,9) | 28,7 | 3,20 | 1,3 | 5,4 | Geliştirme | 0% | 4 |
| S7 karşılaştırma · tek testçi (4) | 4 | 22,1 (20,5-23,5) | 25,4 | 5,53 | 1,2 | 1,6 | Geliştirme | 0% | 4 |
| S8 · 10 geliştirici (11) | 11 | 18,8 (17,8-20,8) | 22,1 | 1,70 | 1,1 | 9,1 | Test | 0% | 4 |
| S8 + 1 geliştirici (Yapım+Test) | 12 | 26,9 (25,2-27,9) | 30,3 | 2,24 | 1,4 | 9,2 | Geliştirme | 0% | 4 |
| S8 · 10 geliştiricinin hepsinde Test kutusu | 11 | 37,0 (36,0-39,0) | 41,1 | 3,36 | 1,9 | 7,1 | Geliştirme | 0% | 4 |
| S9a · 8 testçi, yalnız Test (9) | 9 | 11,2 (10,4-11,4) | 13,8 | 1,24 | 0,8 | 7,7 | Geliştirme | 0% | 4 |
| S9a + 1 geliştirici | 10 | 20,8 (19,8-20,8) | 23,1 | 2,08 | 1,1 | 8,0 | Geliştirme | 0% | 4 |
| S9b · 8 testçi, Yapım+Test (9) | 9 | 22,6 (22,0-23,6) | 25,7 | 2,51 | 1,3 | 6,4 | Geliştirme | 0% | 4 |
| S10 · PM'siz 30 kişi | 30 | 306,0 (303,0-308,0) | 266,3 | 10,20 | 15,3 | 0,3 | Geliştirme | 0% | 2 |
| S11 · 2 PM, 2 tasarımcı, 20 geliştirici, 0 testçi (25) | 25 | 41,0 (40,0-43,0) | 50,0 | 1,64 | 2,0 | 17,2 | Test | 93% | 2 |
| S11 + 1 testçi | 26 | 95,0 (94,0-97,0) | 99,8 | 3,65 | 4,8 | 15,5 | Test | 84% | 2 |
| S11b · S11, geliştiricilerde Test kutusu | 25 | 160,5 (156,0-164,0) | 146,6 | 6,42 | 8,0 | 8,0 | Geliştirme | 63% | 2 |
| S12 · tek karta 12 kişi | 12 | 11,8 (9,8-14,0) | 9,9 | 0,98 | 0,5 | 10,7 | yok | 100% | 4 |
| S3 PM'siz (5) | 5 | 43,0 (42,0-45,0) | 38,6 | 8,60 | 2,1 | 0,5 | Geliştirme | 0% | 4 |
| S3 + PM'e Test kutusu (6) | 6 | 50,0 (48,0-52,0) | 39,3 | 8,33 | 2,5 | 0,5 | Geliştirme | 68% | 4 |
| S4 PM'siz (10) | 10 | 95,0 (94,0-98,0) | 83,3 | 9,50 | 4,8 | 0,1 | Geliştirme | 0% | 2 |
| S4 tek PM (11) | 11 | 106,5 (105,0-108,0) | 92,5 | 9,68 | 5,3 | 0,2 | Geliştirme | 53% | 2 |
| S5 tek PM (23) | 23 | 233,5 (232,0-235,0) | 220,9 | 10,15 | 11,7 | 0,3 | Geliştirme | 24% | 2 |

### 3.2 Hata
| Senaryo | Kaçan hata/kart | Açık hata (med) | Açık max | Düzeltme payı erken | geç | Hata sprinti erken | geç | Üst üste (tohum) | Eğim/hf | Moral |
|---|---|---|---|---|---|---|---|---|---|---|
| S1 · kurucu | 0,53 | 6,0 | 11 | 25% | 25% | 13/218 | 28/497 | 2 | -0,00 | 0 |
| S2 · 3 kişi | 0,78 | 8,0 | 13 | 8% | 8% | 0/200 | 0/400 | 0 | 0,01 | 0 |
| S3 · 6 kişi | 0,57 | 8,0 | 13 | 5% | 5% | 0/200 | 0/400 | 0 | 0,03 | 0 |
| S4 · 12 kişi | 0,57 | 9,2 | 16 | 4% | 5% | 0/200 | 0/400 | 0 | 0,03 | 0 |
| S5 · 25 kişi | 0,57 | 13,0 | 20 | 3% | 4% | 0/200 | 0/400 | 0 | -0,10 | 0 |
| S6 · 50 kişi | 0,57 | 19,0 | 28 | 3% | 3% | 0/200 | 0/400 | 0 | -0,07 | 0 |
| S7 · küçük kartlara 5 testçi (8) | 0,60 | 8,0 | 12 | 3% | 3% | 0/200 | 0/400 | 0 | 0,09 | 0 |
| S7 karşılaştırma · tek testçi (4) | 0,66 | 8,0 | 13 | 6% | 6% | 0/200 | 0/400 | 0 | -0,06 | 0 |
| S8 · 10 geliştirici (11) | 0,68 | 7,5 | 13 | 2% | 2% | 0/200 | 0/400 | 0 | 0,05 | 0 |
| S8 + 1 geliştirici (Yapım+Test) | 0,68 | 7,5 | 13 | 2% | 2% | 0/200 | 0/400 | 0 | 0,02 | 0 |
| S8 · 10 geliştiricinin hepsinde Test kutusu | 0,67 | 8,0 | 13 | 2% | 2% | 0/200 | 0/400 | 0 | 0,06 | 0 |
| S9a · 8 testçi, yalnız Test (9) | 0,47 | 7,0 | 12 | 3% | 3% | 0/200 | 0/400 | 0 | -0,06 | 0 |
| S9a + 1 geliştirici | 0,55 | 7,8 | 12 | 2% | 2% | 0/200 | 0/400 | 0 | 0,01 | 0 |
| S9b · 8 testçi, Yapım+Test (9) | 0,53 | 7,0 | 12 | 2% | 3% | 0/200 | 0/400 | 0 | -0,04 | 0 |
| S10 · PM'siz 30 kişi | 0,67 | 16,0 | 24 | 3% | 4% | 0/200 | 0/400 | 0 | 0,02 | 0 |
| S11 · 2 PM, 2 tasarımcı, 20 geliştirici, 0 testçi (25) | 0,59 | 7,5 | 13 | 1% | 1% | 0/200 | 0/400 | 0 | -0,00 | 0 |
| S11 + 1 testçi | 0,53 | 9,0 | 14 | 1% | 2% | 0/200 | 0/400 | 0 | 0,01 | 0 |
| S11b · S11, geliştiricilerde Test kutusu | 0,57 | 11,0 | 17 | 2% | 3% | 0/200 | 0/400 | 0 | -0,03 | 0 |
| S12 · tek karta 12 kişi | 0,32 | 6,0 | 12 | 0% | 0% | 0/376 | 0/632 | 0 | -0,00 | 0 |
| S3 PM'siz (5) | 0,77 | 8,0 | 13 | 5% | 5% | 0/200 | 0/400 | 0 | 0,00 | 0 |
| S3 + PM'e Test kutusu (6) | 0,64 | 8,5 | 14 | 5% | 5% | 0/200 | 0/400 | 0 | -0,01 | -73 |
| S4 PM'siz (10) | 0,73 | 9,5 | 16 | 4% | 5% | 0/200 | 0/400 | 0 | 0,09 | 0 |
| S4 tek PM (11) | 0,63 | 10,0 | 16 | 4% | 5% | 0/200 | 0/400 | 0 | 0,07 | 0 |
| S5 tek PM (23) | 0,65 | 13,5 | 21 | 4% | 4% | 0/200 | 0/400 | 0 | 0,03 | 0 |

Moral = uymayan işte çalışanların 60 haftalık toplamı (-2/hafta). Yalnız 'S3 + PM'e Test kutusu'nda anlamlı: PM tek başına -73 kaybediyor (belge: yaklaşık -76). Öbür senaryolarda testi geliştirici (ikincil, uymayan sayılmaz) ya da kurucu yaptığı için moral kaybı yok.

### 3.3 Belgenin ön hesabıyla fark
| Ekip | Teslim: belge / bu koşu | Kart başı hata: belge / bu koşu | Açık hata: belge / bu koşu |
|---|---|---|---|
| S1 · kurucu | 6,1 / 6,2 (+2%) | 0,49 / 0,53 | 6,5 / 6,0 |
| S2 · 3 kişi | 21,9 / 22,5 (+3%) | 0,78 / 0,78 | 8,0 / 8,0 |
| S3 · 6 kişi | 55,0 / 55,0 (+0%) | 0,57 / 0,57 | 8,0 / 8,0 |
| S4 · 12 kişi | 116,0 / 116,0 (+0%) | 0,57 / 0,57 | 8,5 / 9,2 |
| S5 · 25 kişi | 257,0 / 256,0 (-0%) | 0,57 / 0,57 | 13,5 / 13,0 |
| S6 · 50 kişi | 498,0 / 496,5 (-0%) | 0,57 / 0,57 | 19,0 / 19,0 |

| Uç bileşim | Teslim: belge / bu koşu | Boşta: belge / bu koşu |
|---|---|---|
| S7 · küçük kartlara 5 testçi (8) | 25,9 / 25,6 (-1%) | 5,4 / 5,4 |
| S8 · 10 geliştirici (11) | 19,4 / 18,8 (-3%) | 9,1 / 9,1 |
| S9a · 8 testçi, yalnız Test (9) | 10,4 / 11,2 (+8%) | 7,8 / 7,7 |
| S9b · 8 testçi, Yapım+Test (9) | 22,6 / 22,6 (+0%) | 6,4 / 6,4 |
| S10 · PM'siz 30 kişi | 307,0 / 306,0 (-0%) | 0,3 / 0,3 |
| S11 · 2 PM, 2 tasarımcı, 20 geliştirici, 0 testçi (25) | 41,0 / 41,0 (+0%) | 17,2 / 17,2 |
| S11b · S11, geliştiricilerde Test kutusu | 160,0 / 160,5 (+0%) | 7,9 / 8,0 |
| S12 · tek karta 12 kişi | 11,8 / 11,8 (-0%) | 10,7 / 10,7 |
| S3 + PM'e Test kutusu (6) | 50,0 / 50,0 (+0%) | 0,5 / 0,5 |

Hepsi belgenin ±%10 payı içinde. Küçük sayılı ölçülerde (S1 kart/sprint, kaçan hata) göreli fark büyük görünse de mutlak fark küçüktür.

## 4. Kişi ekleme eğrisi (1-50 kişi, sabit rol karışımı)
Karışım S6'nın oranı (kurucu + %12 PM, %16 tasarımcı, %51 geliştirici, %20 testçi). Her satır bir öncekinin üstüne tek kişi ekler. Sprint çıktısı = sprint başına biten özellik kartlarının puanı. Marjinal = bir önceki satıra göre sprint çıktısı farkı (haftalık hâli yarısıdır).

| Kişi | Eklenen | Teslim/hf | Sprint çıktısı | Marjinal (puan/sprint) | Kişi başı | Kaçan hata/kart | Boşta | Açık hata | Düzeltme payı | Darboğaz | Hazır kart |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | kurucu | 6,2 | 10,4 | - | 6,22 | 0,53 | 0,1 | 6,0 | 25% | Test | 0% |
| 2 | geliştirici | 11,3 | 22,1 | +11,7 | 5,67 | 0,66 | 0,7 | 7,0 | 12% | Geliştirme | 0% |
| 3 | testçi | 17,8 | 35,5 | +13,4 | 5,92 | 0,63 | 1,1 | 8,0 | 8% | Geliştirme | 0% |
| 4 | geliştirici | 21,8 | 43,5 | +8,0 | 5,44 | 0,68 | 1,6 | 7,8 | 6% | Geliştirme | 0% |
| 5 | tasarımcı | 44,0 | 88,0 | +44,5 | 8,80 | 0,74 | 0,5 | 8,0 | 5% | Geliştirme | 0% |
| 6 | PM | 56,0 | 112,0 | +24,0 | 9,33 | 0,55 | 0,3 | 8,2 | 5% | Geliştirme | 100% |
| 7 | geliştirici | 71,0 | 142,0 | +30,0 | 10,14 | 0,55 | 0,5 | 8,5 | 6% | Geliştirme | 82% |
| 8 | geliştirici | 74,0 | 148,0 | +6,0 | 9,25 | 0,56 | 1,1 | 8,0 | 5% | Geliştirme | 78% |
| 9 | testçi | 79,0 | 158,0 | +10,0 | 8,78 | 0,57 | 1,4 | 9,0 | 6% | Geliştirme | 73% |
| 10 | geliştirici | 83,0 | 166,0 | +8,0 | 8,30 | 0,59 | 1,9 | 9,0 | 5% | Geliştirme | 70% |
| 11 | tasarımcı | 106,5 | 213,0 | +47,0 | 9,68 | 0,63 | 0,2 | 10,0 | 5% | Geliştirme | 53% |
| 12 | geliştirici | 110,0 | 220,0 | +7,0 | 9,17 | 0,63 | 1,0 | 9,5 | 4% | Geliştirme | 52% |
| 13 | PM | 120,0 | 240,0 | +20,0 | 9,23 | 0,57 | 1,0 | 10,0 | 4% | Geliştirme | 84% |
| 14 | testçi | 129,0 | 258,0 | +18,0 | 9,21 | 0,52 | 1,5 | 9,5 | 4% | Geliştirme | 78% |
| 15 | geliştirici | 132,0 | 264,0 | +6,0 | 8,80 | 0,52 | 2,4 | 10,0 | 3% | Geliştirme | 76% |
| 16 | geliştirici | 136,0 | 272,0 | +8,0 | 8,50 | 0,53 | 3,1 | 10,0 | 3% | Geliştirme | 74% |
| 17 | tasarımcı | 174,0 | 348,0 | +76,0 | 10,24 | 0,57 | 0,2 | 11,5 | 4% | Geliştirme | 58% |
| 18 | geliştirici | 188,0 | 376,0 | +28,0 | 10,44 | 0,59 | 0,0 | 11,8 | 4% | Geliştirme | 53% |
| 19 | testçi | 194,0 | 388,0 | +12,0 | 10,21 | 0,59 | 0,6 | 12,0 | 4% | Geliştirme | 52% |
| 20 | geliştirici | 198,0 | 396,0 | +8,0 | 9,90 | 0,58 | 1,3 | 12,2 | 4% | Geliştirme | 51% |
| 21 | PM | 213,0 | 426,0 | +30,0 | 10,14 | 0,53 | 1,2 | 12,0 | 4% | Geliştirme | 83% |
| 22 | geliştirici | 215,0 | 430,0 | +4,0 | 9,77 | 0,53 | 2,2 | 12,0 | 4% | Geliştirme | 82% |
| 23 | tasarımcı | 241,0 | 482,0 | +52,0 | 10,48 | 0,56 | 0,0 | 13,0 | 4% | Geliştirme | 73% |
| 24 | geliştirici | 244,0 | 488,0 | +6,0 | 10,17 | 0,56 | 0,6 | 13,0 | 4% | Test | 71% |
| 25 | testçi | 256,0 | 512,0 | +24,0 | 10,24 | 0,57 | 0,5 | 13,0 | 4% | Geliştirme | 69% |
| 26 | geliştirici | 262,0 | 524,0 | +12,0 | 10,08 | 0,56 | 1,5 | 13,5 | 3% | Geliştirme | 67% |
| 27 | testçi | 266,0 | 532,0 | +8,0 | 9,85 | 0,55 | 2,2 | 13,5 | 4% | Geliştirme | 66% |
| 28 | geliştirici | 270,0 | 540,0 | +8,0 | 9,64 | 0,56 | 3,0 | 13,0 | 4% | Geliştirme | 66% |
| 29 | tasarımcı | 298,0 | 596,0 | +56,0 | 10,28 | 0,57 | 0,9 | 14,5 | 4% | Geliştirme | 59% |
| 30 | geliştirici | 299,0 | 598,0 | +2,0 | 9,97 | 0,58 | 1,4 | 14,0 | 3% | Geliştirme | 59% |
| 31 | PM | 308,0 | 616,0 | +18,0 | 9,94 | 0,56 | 1,4 | 14,2 | 3% | Geliştirme | 73% |
| 32 | geliştirici | 312,0 | 624,0 | +8,0 | 9,75 | 0,55 | 2,3 | 14,2 | 3% | Geliştirme | 73% |
| 33 | testçi | 319,0 | 638,0 | +14,0 | 9,67 | 0,54 | 2,9 | 14,0 | 3% | Geliştirme | 71% |
| 34 | geliştirici | 320,5 | 641,0 | +3,0 | 9,43 | 0,54 | 4,1 | 14,2 | 3% | Geliştirme | 70% |
| 35 | tasarımcı | 364,0 | 728,0 | +87,0 | 10,40 | 0,56 | 0,7 | 16,0 | 4% | Geliştirme | 62% |
| 36 | geliştirici | 365,5 | 731,0 | +3,0 | 10,15 | 0,57 | 1,3 | 15,8 | 3% | Geliştirme | 61% |
| 37 | PM | 374,0 | 748,0 | +17,0 | 10,11 | 0,55 | 1,3 | 15,8 | 3% | Geliştirme | 70% |
| 38 | geliştirici | 375,0 | 750,0 | +2,0 | 9,87 | 0,55 | 2,2 | 16,2 | 3% | Geliştirme | 70% |
| 39 | testçi | 381,0 | 762,0 | +12,0 | 9,77 | 0,55 | 2,6 | 16,2 | 3% | Geliştirme | 69% |
| 40 | geliştirici | 382,5 | 765,0 | +3,0 | 9,56 | 0,55 | 3,5 | 15,8 | 3% | Geliştirme | 69% |
| 41 | tasarımcı | 417,0 | 834,0 | +69,0 | 10,17 | 0,57 | 0,3 | 17,0 | 3% | Test | 62% |
| 42 | geliştirici | 418,5 | 837,0 | +3,0 | 9,96 | 0,57 | 1,4 | 17,0 | 3% | Test | 62% |
| 43 | testçi | 439,0 | 878,0 | +41,0 | 10,21 | 0,57 | 1,1 | 17,5 | 3% | Geliştirme | 60% |
| 44 | geliştirici | 441,5 | 883,0 | +5,0 | 10,03 | 0,58 | 1,8 | 17,8 | 3% | Geliştirme | 59% |
| 45 | geliştirici | 444,0 | 888,0 | +5,0 | 9,87 | 0,57 | 3,0 | 18,0 | 3% | Geliştirme | 59% |
| 46 | PM | 456,0 | 912,0 | +24,0 | 9,91 | 0,55 | 3,1 | 17,5 | 3% | Geliştirme | 70% |
| 47 | tasarımcı | 470,0 | 940,0 | +28,0 | 10,00 | 0,56 | 1,3 | 18,0 | 3% | Test | 67% |
| 48 | geliştirici | 467,0 | 934,0 | -6,0 | 9,73 | 0,56 | 2,3 | 18,0 | 3% | Test | 67% |
| 49 | testçi | 495,0 | 990,0 | +56,0 | 10,10 | 0,56 | 2,0 | 18,8 | 3% | Geliştirme | 64% |
| 50 | geliştirici | 496,5 | 993,0 | +3,0 | 9,93 | 0,57 | 2,6 | 19,0 | 3% | Geliştirme | 64% |

Eklenen role göre ortalama marjinal getiri (puan/hafta):

| Eklenen rol | Adım sayısı | Ortalama | En küçük | En büyük |
|---|---|---|---|---|
| tasarımcı | 8 | +28,7 | +14,0 | +43,5 |
| PM | 6 | +11,1 | +8,5 | +15,0 |
| testçi | 10 | +10,4 | +4,0 | +28,0 |
| geliştirici | 25 | +3,6 | -3,0 | +15,0 |

49 adımın 48'si artı, 0'si sıfır, 1'si eksi. Eksiler: 48. kişi -3,0. Kişi başı teslim n ≥ 5 için 8,3 ile 10,5 arasında; 1-4 kişide (tasarımcısız) 5,4-6,2.

Eğri düzgün değil, merdiven: tasarım aşamasını yalnız tasarımcılar (ve kurucu) yapıyor, bu yüzden tasarımcı adımları (n = 5, 11, 17, 23, 29, 35, 41, 47) haftada +14,0 ile +43,5 puan getiriyor (ortalama +28,7); geliştirici ve testçi adımları ortalama +5,5 (en büyüğü 49. kişi, +28,0: 48. kişideki kaybı geri alan testçi). Marjinal getiri 48. kişi dışında hiçbir yerde eksi değil. Basamak yüksekliği ekip büyüdükçe küçülmüyor, 50 kişide de tasarımcı eklemek en çok kazandıran adım.

## 5. Marjinal getiri tablosu
Taban ekibe bir kişi eklenince teslim farkı (puan/hafta); parantezde ekli ekibin kart başı kaçan hatası. Her hücre: bu koşu / belge §4.4.

| Taban | +3★ geliştirici | +3★ testçi | +3★ tasarımcı | +3★ PM | +1★ geliştirici |
|---|---|---|---|---|---|
| S2 · 3 kişi | +11,5 / +12,1 (0,80) | +9,5 / +9,1 (0,70) | +0,4 / +0,6 (0,78) | +6,8 / +7,4 (0,60) | +8,1 / +8,8 (0,88) |
| S3 · 6 kişi | +12,0 / +12,0 (0,59) | +7,0 / +6,0 (0,54) | +0,0 / +0,0 (0,57) | +0,0 / +0,0 (0,57) | +9,0 / +9,0 (0,62) |
| S4 · 12 kişi | +4,0 / +4,0 (0,57) | +4,5 / +5,0 (0,55) | -1,0 / +0,0 (0,57) | +2,0 / +3,0 (0,55) | +1,5 / +2,0 (0,59) |
| S5 · 25 kişi | +4,0 / +2,0 (0,57) | +5,5 / +5,0 (0,56) | +5,0 / +4,0 (0,57) | +13,0 / +12,0 (0,54) | +2,0 / +2,0 (0,58) |
| S6 · 50 kişi | +2,5 / +0,0 (0,56) | +7,0 / +7,0 (0,56) | +17,5 / +14,0 (0,57) | +14,5 / +12,0 (0,55) | +1,0 / -1,0 (0,57) |

En düşük hücre -1,0 (S4'e 3★ tasarımcı), tolerans sınırında; belgedeki tek eksi (S6'ya 1★ geliştirici -1) bu koşuda +1,0 çıktı. Fark en çok 3,5 puan/hafta (S6 +3★ tasarımcı: +17,5 ve +14), teslimin %0,7'si. Sıfır getiri, o rolün darboğaz olmadığını gösteriyor (S3'e tasarımcı ve PM). 1★ geliştirici hız getiriyor, kart başı hatayı artırıyor (S2: 0,78 → 0,88; S3: 0,57 → 0,62).

## 6. Rol karışımı karşılaştırması (baskın strateji var mı)
Kurucu hep var. Sayılar: PM / tasarımcı / geliştirici / testçi. 'Ref'e göre' teslimin aynı kişi sayısındaki ref karışıma oranı.

| Kişi | Karışım | PM/Tas/Gel/Test | Teslim/hf | Ref'e göre | Kaçan hata/kart | Boşta | Darboğaz | Açık hata |
|---|---|---|---|---|---|---|---|---|
| 12 | ref (PM12 Tas16 Gel51 Test20) | 1 / 2 / 6 / 2 | 110,0 | +0% | 0,63 | 1,0 | Geliştirme | 9,5 |
| 12 | PM'siz | 0 / 2 / 6 / 3 | 109,0 | -1% | 0,65 | 1,5 | Geliştirme | 10,0 |
| 12 | testçisiz, geliştirici Yapım+Test | 1 / 2 / 8 / 0 | 108,0 | -2% | 0,64 | 0,0 | Geliştirme | 9,5 |
| 12 | testçisiz, kutu yok | 1 / 2 / 8 / 0 | 41,0 | -63% | 0,65 | 6,6 | Test | 8,0 |
| 12 | çok testçi (%50) | 1 / 1 / 3 / 6 | 79,0 | -28% | 0,49 | 5,0 | Geliştirme | 8,8 |
| 12 | hepsi testçi, Yapım+Test | 0 / 0 / 0 / 11 | 22,6 | -79% | 0,53 | 9,4 | Geliştirme | 7,0 |
| 12 | hepsi geliştirici, Yapım+Test | 0 / 0 / 11 / 0 | 37,5 | -66% | 0,66 | 8,0 | Geliştirme | 7,5 |
| 12 | çok tasarımcı (%40) | 1 / 5 / 3 / 2 | 83,0 | -25% | 0,57 | 4,1 | Geliştirme | 9,0 |
| 12 | çok PM (%30) | 3 / 1 / 5 / 2 | 88,0 | -20% | 0,53 | 3,5 | Geliştirme | 9,0 |
| 12 | eşit dört rol | 2 / 3 / 3 / 3 | 94,0 | -15% | 0,47 | 3,0 | Geliştirme | 9,0 |
| 25 | ref (PM12 Tas16 Gel51 Test20) | 3 / 4 / 12 / 5 | 256,0 | +0% | 0,57 | 0,5 | Geliştirme | 13,0 |
| 25 | PM'siz | 0 / 4 / 14 / 6 | 233,0 | -9% | 0,67 | 3,1 | Geliştirme | 13,5 |
| 25 | testçisiz, geliştirici Yapım+Test | 3 / 4 / 17 / 0 | 231,0 | -10% | 0,58 | 0,0 | Geliştirme | 12,5 |
| 25 | testçisiz, kutu yok | 3 / 4 / 17 / 0 | 41,0 | -84% | 0,63 | 18,0 | Test | 7,8 |
| 25 | çok testçi (%50) | 3 / 3 / 6 / 12 | 161,0 | -37% | 0,47 | 9,8 | Geliştirme | 10,8 |
| 25 | hepsi testçi, Yapım+Test | 0 / 0 / 0 / 24 | 23,0 | -91% | 0,50 | 22,5 | Geliştirme | 7,2 |
| 25 | hepsi geliştirici, Yapım+Test | 0 / 0 / 24 / 0 | 38,0 | -85% | 0,60 | 21,4 | Geliştirme | 8,0 |
| 25 | çok tasarımcı (%40) | 3 / 10 / 7 / 4 | 183,0 | -29% | 0,49 | 7,8 | Geliştirme | 11,0 |
| 25 | çok PM (%30) | 7 / 3 / 10 / 4 | 224,0 | -12% | 0,50 | 4,6 | Geliştirme | 12,0 |
| 25 | eşit dört rol | 6 / 6 / 6 / 6 | 161,0 | -37% | 0,49 | 9,7 | Geliştirme | 10,2 |
| 50 | ref (PM12 Tas16 Gel51 Test20) | 6 / 8 / 25 / 10 | 496,5 | +0% | 0,57 | 2,6 | Geliştirme | 19,0 |
| 50 | PM'siz | 0 / 8 / 29 / 12 | 454,0 | -9% | 0,67 | 6,7 | Geliştirme | 19,8 |
| 50 | testçisiz, geliştirici Yapım+Test | 6 / 8 / 35 / 0 | 451,0 | -9% | 0,59 | 0,0 | Geliştirme | 18,5 |
| 50 | testçisiz, kutu yok | 6 / 8 / 35 / 0 | 41,0 | -92% | 0,65 | 39,5 | Test | 8,0 |
| 50 | çok testçi (%50) | 5 / 7 / 12 / 25 | 297,5 | -40% | 0,47 | 22,3 | Geliştirme | 13,0 |
| 50 | hepsi testçi, Yapım+Test | 0 / 0 / 0 / 49 | 23,0 | -95% | 0,50 | 47,5 | Geliştirme | 7,2 |
| 50 | hepsi geliştirici, Yapım+Test | 0 / 0 / 49 / 0 | 38,0 | -92% | 0,57 | 46,5 | Geliştirme | 8,0 |
| 50 | çok tasarımcı (%40) | 6 / 20 / 15 / 8 | 358,0 | -28% | 0,52 | 15,3 | Geliştirme | 15,0 |
| 50 | çok PM (%30) | 15 / 6 / 20 / 8 | 411,0 | -17% | 0,50 | 12,1 | Geliştirme | 15,8 |
| 50 | eşit dört rol | 12 / 12 / 12 / 13 | 302,5 | -39% | 0,47 | 21,6 | Geliştirme | 13,0 |

Baskın strateji (bütün boyutlarda ref'ten teslim ≥ ve hata ≤): **yok**. Okuma:
- Hepsi testçi (Yapım+Test kutulu): 12 kişide teslim ref'in %21'i, 50 kişide %5'i; 12 ile 50 kişi arasında teslim değişmiyor (22,6 → 23,0): tasarımı yalnız kurucu yapıyor. Hata ise kart başı 0,50 (ref 0,57-0,63). Çökmüyor, darboğaz görünüyor.
- Hepsi geliştirici (Yapım+Test) aynı sebeple 38'de takılıyor. Testçisiz ve kutusuz karışım 41'de takılıyor (test yalnız kurucuda; 50 kişide 39,5 kişi-hafta/hafta boşta).
- Çok testçi (%50) kaçan hatayı en çok düşüren karışım (0,47-0,49) ama teslimi ref'in %72 ile %60'ına indiriyor. Hızla kalite arasında gerçek bir takas var.
- Testçisiz ama geliştiricilere Test kutusu: ref'ten 12 kişide %2, 25 kişide %10, 50 kişide %9 geride, kart başı hata aynı (0,58-0,64 ve 0,57-0,63). Yani ek bir uzman testçi alma kararı yalnız %2-%10 teslim kazandırıyor; belirgin ama baskın değil.
- PM'siz: kişi sayısı büyüdükçe aradaki fark açılıyor (12 kişide -%1, 25'te -%9, 50'de -%9); kaçan hata 0,57 → 0,67.
- Çok PM, çok tasarımcı ve eşit dört rol ref'ten düşük teslim veriyor (50 kişide -%17, -%28, -%39) ve boşta kişi var; ref'e göre kaybettiği tek şey teslim, hata bakımından (0,47-0,52) daha iyi.

## 7. Testçi yıldızı ve PM'in değeri
### 7.1 Testçi yıldızı (K7)
| Testçi | S3: kaçan hata/kart | S3: teslim | S4 benzeri: kaçan hata/kart | S4 benzeri: teslim |
|---|---|---|---|---|
| 1★ | 0,62 | 50,0 | 0,62 | 101,0 |
| 2★ | 0,59 | 53,0 | 0,60 | 113,0 |
| 3★ | 0,54 | 56,0 | 0,55 | 117,0 |
| 4★ | 0,49 | 58,0 | 0,49 | 120,0 |
| 5★ | 0,43 | 59,0 | 0,42 | 122,0 |

Kaçan hata yıldızla tek yönde azalıyor: 1★ 0,62 → 5★ 0,43 (yaklaşık -%30). Yakalama oranının üst sınırı hiçbir kartta aşılmadı (0 ihlal).

Aynı deney ölçekte (eğrinin 12, 25 ve 50 kişilik ekipleri; bütün testçiler 1★ ya da 5★):

| Kişi | Testçiler | Kaçan hata/kart | Teslim/hf | Açık hata (med) | Açık max | Düzeltme payı | Düzeltme kartı/sprint |
|---|---|---|---|---|---|---|---|
| 12 | 1★ | 0,68 | 93,0 | 9,5 | 16 | 5% | 2,1 |
| 12 | 5★ | 0,47 | 121,0 | 9,2 | 15 | 4% | 2,0 |
| 25 | 1★ | 0,62 | 188,5 | 12,0 | 19 | 3% | 3,2 |
| 25 | 5★ | 0,43 | 269,0 | 12,2 | 19 | 3% | 3,1 |
| 50 | 1★ | 0,62 | 338,0 | 16,2 | 24 | 3% | 4,7 |
| 50 | 5★ | 0,42 | 513,5 | 16,0 | 23 | 2% | 4,7 |

Kart başı hata yaklaşık %32 iniyor (0,62 → 0,42 / 50 kişide) ve teslim %52 artıyor (50 kişide), ama **açık hata sayısı ve düzeltme payı değişmiyor** (50 kişide açık hata 16,2 ve 16,0; düzeltme kartı sprint başına 4,7 ve 4,7). Sebep: 5★ testçi aynı zamanda daha hızlı, ekip daha çok kart teslim ediyor; haftalık toplam kaçan hata iki durumda da aynı kalıyor. Bu kırılma değil, gözlem olarak 13. bölümde.

### 7.2 PM'in değeri ve uymayan iş
| Ekip | Kişi | Teslim/hf | Kişi başı | Kaçan hata/kart | Hazır kart | Boşta |
|---|---|---|---|---|---|---|
| S3 PM'siz (5) | 5 | 43,0 | 8,60 | 0,77 | 0% | 0,5 |
| S3 · 6 kişi | 6 | 55,0 | 9,17 | 0,57 | 100% | 0,3 |
| S3 + PM'e Test kutusu (6) | 6 | 50,0 | 8,33 | 0,64 | 68% | 0,5 |
| S4 PM'siz (10) | 10 | 95,0 | 9,50 | 0,73 | 0% | 0,1 |
| S4 tek PM (11) | 11 | 106,5 | 9,68 | 0,63 | 53% | 0,2 |
| S4 · 12 kişi | 12 | 116,0 | 9,67 | 0,57 | 87% | 0,2 |
| S5 tek PM (23) | 23 | 233,5 | 10,15 | 0,65 | 24% | 0,3 |
| S5 · 25 kişi | 25 | 256,0 | 10,24 | 0,57 | 69% | 0,5 |
| S10 · PM'siz 30 kişi | 30 | 306,0 | 10,20 | 0,67 | 0% | 0,3 |

PM eklemek her yerde hem kaçan hatayı düşürüyor hem teslimi artırıyor (K8 geçti). 25 kişide tek PM kartların %24'ünü, üç PM %69'unu hazırlıyor (belgedeki sayılar). PM'in Test kutusu işaretlenirse (S3): teslim 55 → 50, hazırlık %100 → %68, PM'in 60 haftalık moral kaybı medyan -73 (en az -82, en çok -66); kural 'bu böyle çalışmaz'ı sayıyla söylüyor.

## 8. A'nın hedefleri (E1 §9)
Hedefler: düzeltme payı erken ≤ %30 (tek kurucu ≤ %50), geç ≤ %20; hata sprinti erken ≤ %15, geç ≤ %5; üst üste iki hata sprinti yok.

| Ekip | Düzeltme payı erken | geç | Hata sprinti erken | geç | Üst üste (tohum) | Hedef |
|---|---|---|---|---|---|---|
| S1 · kurucu | 25% | 25% | 13/218 (6,0%) | 28/497 (5,6%) | 2 | TUTMUYOR |
| S2 · 3 kişi | 8% | 8% | 0/200 (0,0%) | 0/400 (0,0%) | 0 | tutuyor |
| S3 · 6 kişi | 5% | 5% | 0/200 (0,0%) | 0/400 (0,0%) | 0 | tutuyor |
| S4 · 12 kişi | 4% | 5% | 0/200 (0,0%) | 0/400 (0,0%) | 0 | tutuyor |
| S5 · 25 kişi | 3% | 4% | 0/200 (0,0%) | 0/400 (0,0%) | 0 | tutuyor |
| S6 · 50 kişi | 3% | 3% | 0/200 (0,0%) | 0/400 (0,0%) | 0 | tutuyor |
| S10 · PM'siz 30 kişi | 3% | 4% | 0/200 (0,0%) | 0/400 (0,0%) | 0 | tutuyor |

Eğri dahil, n ≥ 2 olan bütün 143 senaryoda: en yüksek erken pay 8%, en yüksek geç pay 12%, en yüksek hata sprinti oranı 0,7%, üst üste hata sprinti yok. Yani A'nın hedefleri ≥2 kişide ölçekle bozulmuyor; payı ölçek küçültüyor (12% → 3%).
Tek kurucu hedefi tutmuyor (yukarıdaki satır): düzeltme payı sabit %25 (20 puanlık sprintte 5 puanlık düzeltme kartı) ve bir hat için ikinci bir 5 puanlık kart daha gelince sprint yarıdan fazla düzeltmeye gidiyor.

## 9. MVP haftası
| Ekip | MVP haftası (medyan) | 20 tohumda aralık |
|---|---|---|
| S1 · kurucu | 6 | 6-6 |
| S2 · 3 kişi | 4 | 4-4 |
| S3 · 6 kişi | 4 | 4-4 |
| S4 · 12 kişi | 2 | 2-2 |
| S5 · 25 kişi | 2 | 2-2 |
| S6 · 50 kişi | 2 | 2-2 |
| S7 · küçük kartlara 5 testçi (8) | 4 | 4-4 |
| S8 · 10 geliştirici (11) | 4 | 4-4 |
| S9a · 8 testçi, yalnız Test (9) | 4 | 4-4 |
| S10 · PM'siz 30 kişi | 2 | 2-2 |
| S11 · 2 PM, 2 tasarımcı, 20 geliştirici, 0 testçi (25) | 2 | 2-2 |
| S12 · tek karta 12 kişi | 4 | 4-4 |

Tek kurucu her tohumda 6. haftada (üç K1 kartı 45 puan, sprint 1,5 + 2 + 2 hafta). Ekipler 4 ve 2. haftada; bunlar tam ekiple 0. haftadan başlayan yapay senaryo, oyunda ekip MVP'den sonra büyür.

## 10. Akış: sprintteki kart, bekleme
Sprintteki kart = sprint başında planlanan toplam kart (devredenler ve düzeltme dahil). Bekleme = bir özellik kartının sprinte girişinden bitişine geçen hafta. Bir kartın en kısa süresi 3★ ekiple K1 için yaklaşık 1 hafta, K3 için 1,8 hafta (§3.4).

| Ekip | Sprintteki kart | Biten kart/sprint (düzeltme dahil) | Ortalama bekleme (hf) | Açık max |
|---|---|---|---|---|
| S2 · 3 kişi | 3,8 | 2,4 | 4,2 | 13 |
| S3 · 6 kişi | 6,6 | 4,3 | 3,7 | 13 |
| S4 · 12 kişi | 12,4 | 7,9 | 3,6 | 16 |
| S5 · 25 kişi | 26,3 | 16,5 | 3,5 | 20 |
| S6 · 50 kişi | 49,5 | 30,3 | 3,5 | 28 |
| S10 · PM'siz 30 kişi | 32,6 | 20,0 | 3,7 | 24 |
| S8 · 10 geliştirici (11) | 4,0 | 2,2 | 5,1 | 13 |
| S11 · 2 PM, 2 tasarımcı, 20 geliştirici, 0 testçi (25) | 64,5 | 3,4 | 27,7 | 13 |
| Eğri · 47 kişi | 58,5 | 28,8 | 4,5 | 26 |
| Eğri · 48 kişi | 62,4 | 28,8 | 4,8 | 26 |

Sağlıklı ekiplerde bekleme 3,5 hafta (yaklaşık iki sprint) ve sprintteki kartların yaklaşık üçte biri yarım kalıp sonraki sprinte devrediyor. Testçisiz S11'de bekleme 27,7 hafta: kartlar test aşamasında birikiyor, plan ekranının göstermesi gereken şey bu.

## 11. Kırılma ölçütleri
### 11.1 Belgenin ölçütleri (§6.12)
| # | Ölçüt | Durum | Kanıt |
|---|---|---|---|
| 1 | Bir rol eklemek teslimi düşürür (tolerans -1 puan/hafta) | **KIRIK** | Marjinal tablo (25 hücre) en düşük -1,0; eğri (49 adım) en düşük -3,0 (n=48). |
| 2 | Tek kurucunun MVP haftası 6-7 | GEÇTİ | S1 MVP haftası: medyan 6, 20 tohumun en küçüğü 6, en büyüğü 6. |
| 3 | S5 ve S6 kişi başı teslim S3'ün %70-%150'si | GEÇTİ | Kişi başı: S3 9,17, S5 10,24 (%112), S6 9,93 (%108). |
| 4 | Darboğaz rolüne kişi eklemek teslimi artırır | GEÇTİ | S8'e Test kutulu geliştirici: 18,8 → 26,9; S11'e testçi: 41,0 → 95,0; S9a'ya geliştirici: 11,2 → 20,8. |
| 5 | ≥2 kişilik ekipler: düzeltme payı ilk 20 hafta ≤ %30, sonra ≤ %20; hata sprinti ≤ %5; üst üste iki hata sprinti yok; tek kurucu ilk 20 hafta ≤ %50 | GEÇTİ | ≥2 kişilikte en kötü: erken pay 8% (S2 +3★ PM), geç pay 12% (eğri 2 kişi), hata sprinti geç 0,7% (eğri 2 kişi), erken hiçbirinde yok, üst üste: yok. Tek kurucu erken pay 25%. |
| 6 | Açık hata sınırsız büyümez (son 20 hafta eğimi ≤ 0,2 hata/hafta) | GEÇTİ | Bütün senaryolarda en büyük medyan eğim +0,13 hata/hafta (50 kişi, testçiler 5★). |
| 7 | Kart başı kaçan hata testçi yıldızıyla azalır; yakalama en iyi testçisininkini aşmaz | GEÇTİ | S3 (1★→5★ testçi): 0,62 → 0,59 → 0,54 → 0,49 → 0,43; S4: 0,62 → 0,60 → 0,55 → 0,49 → 0,42; yakalama tavanı aşımı: 0 kart (bütün koşular). |
| 8 | PM'siz ekibe PM eklemek kaçan hatayı düşürür ve teslimi artırır | GEÇTİ | S3 PM'siz (5) → S3: teslim 43,0 → 55,0, kaçan hata 0,77 → 0,57; S4 PM'siz (10) → S4 tek PM (11): teslim 95,0 → 106,5, kaçan hata 0,73 → 0,63; S4 PM'siz (10) → S4: teslim 95,0 → 116,0, kaçan hata 0,73 → 0,57. |
| 9 | Boşta > %10 ise darboğaz ya da kart arzı sınırı görünür | GEÇTİ | Boşta > %10 ve darboğaz 'yok' olan tek senaryo: S12 (boşta 10,7/12). S12 tek kart kipidir, kart arzı sınırı senaryonun tanımıdır. |
| 10 | Tahmin = sonuç (fark ≤ 1e-6) | GEÇTİ | Her sprintte planlama anında alınan 2 haftalık kopya, kapanıştaki gerçek sonuçla kart-aşama ilerlemesi, bitiş zamanı ve E bakımından karşılaştırıldı; 115 senaryo × 20 tohumda en büyük fark 3,6e-15. |

### 11.2 Genel ölçütler
| # | Soru | Sonuç | Kanıt |
|---|---|---|---|
| G1 | Kişi eklemek çıktıyı düşürüyor mu | EVET, tek yerde (48. kişi) | Eğrinin 49 adımının 48'i ≥ 0; 48. kişi -3,0. Marjinal tabloda en düşük -1,0 (S4 + tasarımcı, tolerans sınırında). Ayrıntı 12. bölüm K1. |
| G2 | Bir rol karışımı baskın strateji mi | HAYIR | 10 karışım × 3 büyüklük; hiçbiri ref'ten hem teslimde hem hatada iyi değil (6. bölüm). Hepsi testçi, testçisiz ve hepsi geliştirici karışımları tasarım ya da test aşamasında kurucuya takılıp 12 kişiden sonra büyümüyor. |
| G3 | Hata oranı ya da düzeltme payı ölçekle patlıyor mu | HAYIR | Kart başı kaçan hata n ≥ 6 için 0,52-0,63 arasında; düzeltme payı 8% (3 kişi) → 3% (50 kişi); en yüksek hata sprinti oranı ≥2 kişide %0,7. Açık hata ekiple doğrusal büyüyor (8 → 19, 50 kişide pencere maksimumunun medyanı 27,5). Detay 13. bölüm g4. |
| G4 | Bir sayı 50 kişide anlamsız mı | KISMEN (kırılma sayılmadı) | Anlamsızlaşan sayı yok; iki sayı işlevini yitiriyor: düzeltme payı %3 (testçi yıldızı açık hatayı ve düzeltme payını değiştirmiyor, 7,1) ve MVP haftası 2 (yapay senaryo). Gözlem g3, g8. |
| G5 | Tek kurucunun MVP'si 6-7. haftadan kayıyor mu | HAYIR | 20 tohumun hepsinde 6. hafta (K2). |

## 12. Kırılmalar
**K1 · 48. kişiyi eklemek teslimi düşürüyor** (belge ölçütü 1; genel ölçüt 'kişi eklemek çıktıyı düşürüyor mu')
- Ne: kişi ekleme eğrisinde 47 → 48. kişi (eklenen: 2,5★ geliştirici, yazılım 5, test 4). Teslim 470,0 → 467,0 puan/hafta (-3,0; tolerans -1). 20 tohumun 16'sinde 48. kişi, aynı tohumdaki 47. kişinin altında. Kayıp, teslimin %0,6 oranı.
- Ölçülen sebep: sprintteki kart sayısı 58,5 → 62,4, bir kartın sprinte girişinden bitişine geçen süre 4,45 → 4,78 hafta, sprint başına biten özellik kartı 23,5 → 23,4, düzeltme kartı 5,2 → 5,5. Ek deney (5 tohum): 48 kişilik ekibe 47 kişinin planlama kapasitesi (890,4) verilince teslim 469'a dönüyor; 47 kişilik ekibe 48 kişinin kapasitesi (910,4) verilince 467'ye iniyor. Yani atama kuralı değil, planlamanın kapasite tavanı: §6.3 kapasite her kişinin en iyi aşamasının hızını topluyor, yeni geliştirici darboğaz olmayan aşamaya kapasite katıyor, tavan (1,25 × kapasite) yükseliyor, sprint daha çok kart alıyor ve yarım kalan kartlar test kuyruğunda birikiyor.
- Boyut ve yer: yalnız bu bileşimde; 48 dışında bütün eğri adımları ≥ 0. Marjinal tabloda benzer ama tolerans içinde bir hücre var (S4 + 3★ tasarımcı, -1,0). Belgenin kendi 'S6 + 1★ geliştirici -1' bulgusu bu koşuda çıkmadı (+1,0); aynı ailenin farklı bir örneği.
- Çözüm yönü (denenmedi): tavanı darboğaz aşamasının kapasitesine ya da devreden kart sayısına bağlamak. Model değişikliği olduğu için onay gerektirir.

**K2 · Tek kurucuda A'nın hata sprinti hedefi tutmuyor** (belge ölçütü 5 tek kurucuyu bu hedefe bağlamıyor; A'nın E1 §9 hedefi 'her ekip' diyor, bu yüzden listede)
- Ne: S1, geç pencerede 28/497 sprint hata sprinti (%5,6; hedef ≤ %5), erken pencerede 13/218 (%6,0; hedef ≤ %15, tutuyor). 20 tohumun 2'sinde üst üste iki hata sprinti var; 10 tohumda geç oran tek başına %5'i aşıyor.
- Sebep: tek kurucuda kapasite 20 puan ve düzeltme payı zaten %25. Bir hatta ≥ 5 hata birikince 10 puanlık, başka bir hatta ≥ 2 hata birikince 5 puanlık kart açılıyor: 15 puan = pay 0,75 (28 hata sprintinin 25'i) ya da iki 10 puanlık kart = pay 1,0 (3'ü). Eşik 0,5'i geçince sprint düzeltmeye gidiyor.
- Belgenin §4.2 tablosu bunu '1 / 28' (5 tohum) diye yazıyordu; 20 tohumda oran %5'in biraz üstünde. Büyük bir sapma değil ama A'nın hedefi tek kurucu için yapısal olarak sıkı.

## 13. Kırılma sayılmayan gözlemler
1. **g1 Merdiven eğrisi.** Teslim, tasarımcı eklenince sıçrıyor; geliştirici ve testçi adımları çoğunlukla küçük (4. bölüm). Bu bir ekip dengesi göstergesi, hata değil; ama oyuncuya 'şimdi hangi rol?' sorusunun cevabı yalnız darboğaz satırında. Tasarımcı sayısı 50 kişide hâlâ en değerli ek kişi (S6 + 3★ tasarımcı +17,5).
2. **g2 Sprintteki kartların üçte biri yarım kalıyor.** Sağlıklı ekiplerde sprintteki kartların yaklaşık üçte biri devrediyor ve bir kart ortalama 3,5 hafta (iki sprint) sürüyor. Plan ekranının 'bu sprintte biten' ile 'bu sprintte çalışılan'ı ayırması gerekir (10. bölüm).
3. **g3 Kalite kaldıracı açık hatada görünmüyor.** Bütün testçiler 1★'dan 5★'a çıkınca kart başı hata %32 iniyor, ama açık hata (6, 12, 25, 50 kişide sırasıyla 8→8, 9,5→9,2, 12→12,2, 16,2→16,0) ve düzeltme payı (%5→%4 … %3→%2) değişmiyor. İki sebep: iyi testçi ekibi hızlandırıp daha çok kart teslim ettiriyor (haftalık toplam kaçan hata aynı kalıyor); düzeltme kartı bir hattaki hata sayısından bağımsız 5-10 puan (A'nın kuralı). Kalite kararı kart ipucunda (%35 → %28) görünür, sonuç ekranında görünmez. Erdem'in '%2 çok düşük' itirazının görünür tarafı bu.
4. **g4 Açık hata 50 kişide A'nın itibar eşiğine yaklaşıyor.** S6'da medyan 19, pencere maksimumunun medyanı 27,5; 400 kapanışın 6'sında ≥ 30, 48'inde ≥ 25 (en yüksek 33). Eşik 4 hafta üst üste 30 olduğu için bu koşularda tetiklenmedi, ama marj dar (S5'te en yüksek 26). Belge de aynı riski yazmıştı; ölçüm doğruluyor.
5. **g5 Testçisiz bileşimde kart bekleme süresi 27,7 hafta.** S11 (testçisiz 25 kişi): sprintte 64 kart, sprint başına 2 kart bitiyor; kartlar test aşamasında bekliyor. Model çökmüyor, ama 'darboğaz cümlesi'nin yakalaması gereken durum bu: kartın bekleme süresi.
6. **g6 Testçinin ek değeri küçük.** Geliştiricilere Test kutusu işaretleyip testçi almamak ref karışımdan %2 (12 kişi) ile %10 (25 kişi) geride kalıyor, kaçan hata aynı. Testçi, uzman olduğu için kaliteyi artırmaktan çok yapımdan boşalttığı zamanla değer katıyor; bu amaçlandıysa sorun yok, 'testçi şart' hissi için hatanın görünürlüğü gerekir (g3).
7. **g7 Hazırlık oranı ölçekle düşüyor.** Hazır kart S3'te %100, S4'te %87, S5'te %69, S6'da %64: ekip oranı sabit tutulunca (S6'nın %12'si PM) PM'in hazırlık kapasitesi ekibin tükettiği kartın gerisinde kalıyor. Kırılma ölçütü yok; 'PM oranı' yine de 50 kişide hazırlığı tam yapmıyor.
8. **g8 MVP haftası 2 (ekip ≥ 5).** Tam ekiple 0. haftadan başlayan yapay senaryo; ölçü olarak anlamsız (belge de uyarıyor). Oyunda MVP'den sonra büyüyen ekip için ayrı ölçüm gerekir.

## 14. Yeniden üretim
Klasör: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dsim/`
```
python -I dsim.py exec collect.py     # 139 senaryo x 20 tohum -> results.pkl (yaklasik 4 dk, 12 cekirdek)
python -I dsim.py exec collect2.py    # olcekte testçi deneyi (TS12/25/50)
python -I dsim.py exec check69.py     # 6.9 elle dogrulama
python -I dsim.py exec x_rapor.py     # D_SIM.md uretimi
python -I dsim.py quick S3 S6         # tek senaryo, tohum 1
```
Parametreler `dsim.py` başındaki sabitlerdedir (§6.2 ile birebir). Senaryo tanımları `SCEN` sözlüğünde.

## 15. Düzeltme sonrası
Düzeltme turu, 17 Ekim 2026. Repo kodu değişmedi. Model değişikliği `D_MODEL_v2.md` §3.11'de, "(simülasyon sonrası)" işaretli.

### 15.1 Ne değişti
| Kırılma | Modeldeki düzeltme | Betikte |
|---|---|---|
| K1 · 48. kişi teslimi düşürüyor | **Aşama tavanı.** Plan sprinte kart eklerken her aşama satırını ayrıca sınar: yeni kartın işi olan aşamada, sprintin o aşamada kalan işi + yeni kartınki ≤ 2 × ekibin o aşamadaki kapasitesi. Aşama kapasitesi = o aşamada çalışabilen herkesin o aşamadaki hızı × 2 hafta. Toplam tavan (1,25 × kapasite) kalır. | `PHASE_K = 2.0`, `Team.pcap`, `Sim.plan` adım 5'e (a2) koşulu |
| K2 · tek kurucuda hata sprinti %5,6 | **Düzeltme payı tavanı.** Plan düzeltme kartlarını (en çok hatalı hat önce) alırken devreden ve yeni düzeltme işinin toplamı kapasitenin yarısını aşacaksa o kartı açmaz; sprintte düzeltme kartı yoksa ilk kart her zaman girer. | `FIX_SHARE_MAX = 0.5`, `Sim.plan` adım 1 |

- Koşu: düzeltme öncesiyle aynı, 145 senaryo × 20 tohum (ve 6 ölçek testçi senaryosu), 60 hafta; yaklaşık 4,5 dakika.
- §6.9 elle doğrulama değişmedi (`check69.json` bayt bayt aynı): kurallar yalnız sprint alımına dokunuyor.
- İki anahtar kapatılınca (`DSIM_PHASE_CEIL=0 DSIM_FIX_SHARE_MAX=0`) betik düzeltme öncesi sonuçları birebir verir (S1, eğri 47 ve 48, S11, S4 + 3★ tasarımcı; 20 tohum; teslim, kaçan hata, açık hata, hata sprinti ve bekleme alanlarında 0 fark).
- Aşama tavanı için 1,25 ve 1,5 kat da denendi (20 tohum; S1-S6, eğri 40-50, S8, S10, S11):

| Aşama tavanı | S2 | S4 | S5 | S6 | Eğri 47 → 48 | Okuma |
|---|---|---|---|---|---|---|
| yok (önce) | 22,5 | 116,0 | 256,0 | 496,5 | 470,0 → 467,0 (-3,0) | K1 kırık |
| 1,25 kat | 20,5 | 111,0 | 244,0 | 477,0 | 452,0 → 454,5 (+2,5) | K1 kalkıyor ama teslim S2, S4, S5 ve S6'da %4-%9 düşüyor; test satırı neredeyse her sprintte bağlıyor |
| 1,5 kat | 21,9 | 116,0 | 256,0 | 495,5 | 469,5 → 468,5 (-1,0) | Tolerans sınırında; S2 -%3 |
| **2 kat (seçilen)** | 22,5 | 116,0 | 256,0 | 496,5 | 470,0 → 470,0 (0,0) | K1 kalkıyor, S1-S6 birebir aynı |

### 15.2 Kırılma ölçütleri
| # | Ölçüt | Önce | Sonra | Kanıt (sonra) |
|---|---|---|---|---|
| 1 | Bir rol eklemek teslimi düşürür (tolerans -1) | **KIRIK** | GEÇTİ | Eğri (49 adım) en düşük 0,0 (n = 48), eksi adım yok. Marjinal tablo en düşük -1,0 (S4 + 3★ tasarımcı, değişmedi; 15.6). |
| 2 | Tek kurucunun MVP haftası 6-7 | GEÇTİ | GEÇTİ | 20 tohumun hepsinde 6. |
| 3 | S5 ve S6 kişi başı teslim S3'ün %70-%150'si | GEÇTİ | GEÇTİ | S3 9,17, S5 10,24 (%112), S6 9,93 (%108); değişmedi. |
| 4 | Darboğaz rolüne kişi eklemek teslimi artırır | GEÇTİ | GEÇTİ | S8'e Test kutulu geliştirici 18,8 → 26,9; S11'e testçi 42,0 → 98,0; S9a'ya geliştirici 11,2 → 20,8. |
| 5 | ≥ 2 kişide düzeltme payı ve hata sprinti (A'nın hedefleri) | GEÇTİ | GEÇTİ | En kötü erken pay %8, geç pay %12 (eğri 2 kişi); hata sprinti ≥ 2 kişide hiçbir senaryoda yok (önce eğri 2 kişide 3/407 = %0,7). |
| 6 | Açık hata sınırsız büyümez (eğim ≤ 0,2) | GEÇTİ | GEÇTİ | En büyük medyan eğim +0,13 (50 kişi, testçiler 5★). |
| 7 | Kaçan hata testçi yıldızıyla azalır; yakalama tavanı aşılmaz | GEÇTİ | GEÇTİ | S3 0,62 → 0,43; S4 0,61 → 0,42; 0 ihlal. |
| 8 | PM eklemek hatayı düşürür, teslimi artırır | GEÇTİ | GEÇTİ | S3 PM'siz → S3 43,0 → 55,0, 0,77 → 0,57; S4 PM'siz → S4 95,0 → 116,0, 0,73 → 0,57. |
| 9 | Boşta > %10 ise neden görünür | GEÇTİ | GEÇTİ | Darboğazı 'yok' olan tek boşta senaryo yine S12 (tek kart kipi). |
| 10 | Tahmin = sonuç | GEÇTİ | GEÇTİ | 115 senaryo × 20 tohumda en büyük fark 3,6e-15. |
| A | Tek kurucu: hata sprinti geç ≤ %5, üst üste yok (A'nın E1 §9 hedefi) | **TUTMUYOR** | tutuyor | Geç 0/506, erken 0/221, üst üste 0 tohum (önce 28/497, 13/218, 2 tohum). |

### 15.3 Ana senaryolar, önce / sonra
Teslim puan/hafta; bekleme = kartın sprinte girişinden bitişine hafta; sprintteki kart = sprint başında planlanan kart. 20 tohum medyanı, 21-60. hafta.

| Senaryo | Teslim | Bekleme (hf) | Sprintteki kart | Kaçan hata/kart | Açık hata (med) | Açık max | Hata sprinti geç | Boşta | Darboğaz |
|---|---|---|---|---|---|---|---|---|---|
| S1 · kurucu | 6,2 / 6,4 | 3,24 / 3,29 | 1,6 / 1,7 | 0,53 / 0,53 | 6,0 / 6,5 | 11 / 11,5 | 28/497 / 0/506 | 0,1 / 0,1 | Test / Test |
| S2 · 3 kişi | 22,5 / 22,5 | 4,18 / 4,18 | 3,8 / 3,8 | 0,78 / 0,78 | 8,0 / 8,0 | 13 / 13 | 0 / 0 | 0,5 / 0,5 | Geliştirme / Geliştirme |
| S3 · 6 kişi | 55,0 / 55,0 | 3,69 / 3,69 | 6,6 / 6,6 | 0,57 / 0,57 | 8,0 / 8,0 | 13 / 13 | 0 / 0 | 0,3 / 0,3 | Geliştirme / Geliştirme |
| S4 · 12 kişi | 116,0 / 116,0 | 3,57 / 3,57 | 12,4 / 12,4 | 0,57 / 0,57 | 9,2 / 9,2 | 16 / 16 | 0 / 0 | 0,2 / 0,2 | Geliştirme / Geliştirme |
| S5 · 25 kişi | 256,0 / 256,0 | 3,53 / 3,53 | 26,3 / 26,3 | 0,57 / 0,57 | 13,0 / 13,0 | 20 / 20 | 0 / 0 | 0,5 / 0,5 | Geliştirme / Geliştirme |
| S6 · 50 kişi | 496,5 / 496,5 | 3,55 / 3,55 | 49,5 / 49,5 | 0,57 / 0,57 | 19,0 / 19,0 | 27,5 / 27,5 | 0 / 0 | 2,6 / 2,6 | Geliştirme / Geliştirme |
| S8 · 10 geliştirici | 18,8 / 18,8 | 5,12 / 4,98 | 4,0 / 3,9 | 0,68 / 0,68 | 7,5 / 7,5 | 13 / 12,5 | 0 / 0 | 9,1 / 9,1 | Test / Test |
| S9a · 8 testçi, yalnız Test | 11,2 / 11,2 | 4,84 / 4,84 | 2,9 / 3,0 | 0,47 / 0,47 | 7,0 / 7,0 | 12 / 12,5 | 0 / 0 | 7,7 / 7,8 | Geliştirme / Geliştirme |
| S10 · PM'siz 30 kişi | 306,0 / 306,0 | 3,67 / 3,67 | 32,6 / 32,6 | 0,67 / 0,67 | 16,0 / 16,0 | 24 / 24 | 0 / 0 | 0,3 / 0,3 | Geliştirme / Geliştirme |
| S11 · testçisiz 25 kişi | 41,0 / 42,0 | 27,73 / 4,29 | 64,5 / 5,9 | 0,59 / 0,57 | 7,5 / 7,8 | 13 / 12,5 | 0 / 0 | 17,2 / 20,8 | Test / Test |
| S11 + 1 testçi | 95,0 / 98,0 | 10,66 / 4,32 | 33,4 / 12,6 | 0,53 / 0,54 | 9,0 / 9,0 | 14 / 15 | 0 / 0 | 15,5 / 15,9 | Test / Test |
| S12 · tek karta 12 kişi | 11,8 / 11,8 | 1,50 / 1,50 | 1,2 / 1,2 | 0,32 / 0,32 | 6,0 / 6,0 | 12 / 12 | 0 / 0 | 10,7 / 10,7 | yok / yok |
| Eğri · 47 kişi | 470,0 / 470,0 | 4,45 / 4,34 | 58,5 / 56,9 | 0,56 / 0,56 | 18,0 / 18,0 | 26 / 26 | 0 / 0 | 1,3 / 1,5 | Test / Test |
| Eğri · 48 kişi | 467,0 / 470,0 | 4,78 / 4,42 | 62,4 / 57,5 | 0,56 / 0,56 | 18,0 / 18,0 | 26 / 27 | 0 / 0 | 2,3 / 2,7 | Test / Test |

145 senaryonun 129'unda teslim birebir aynı. Değişen 16 senaryoda teslim farkı -%2,9 ile +%3,2 arasında. Aşama tavanı 32 senaryoda en az bir kez bağladı: çoğunda Test satırı; tasarımı yalnız kurucunun yaptığı ekiplerde (S7, S8, hepsi geliştirici karışımı) Tasarım; S9a ve çok testçili karışımda Geliştirme. S1-S6, S10 ve dengeli ekiplerin hiçbirinde bağlamadı. Düzeltme payı tavanı yalnız 3 senaryoda bağladı: S1 (33 kez, 20 tohumda), eğri 1 kişi (S1 ile aynı ekip, 33) ve eğri 2 kişi (2).

### 15.4 Kişi ekleme eğrisi
Değişen yalnız üç satır: 1 kişi (6,2 → 6,4, düzeltme payı tavanı), 24 kişi (244,0 → 242,0) ve 48 kişi (467,0 → 470,0). Öbür 47 satır birebir aynı.

| Kişi | Eklenen | Teslim önce | Teslim sonra | Marjinal önce | Marjinal sonra |
|---|---|---|---|---|---|
| 2 | geliştirici | 11,3 | 11,3 | +5,1 | +4,9 |
| 24 | geliştirici | 244,0 | 242,0 | +3,0 | +1,0 |
| 25 | testçi | 256,0 | 256,0 | +12,0 | +14,0 |
| 46 | PM | 456,0 | 456,0 | +12,0 | +12,0 |
| 47 | tasarımcı | 470,0 | 470,0 | +14,0 | +14,0 |
| 48 | geliştirici | 467,0 | 470,0 | **-3,0** | 0,0 |
| 49 | testçi | 495,0 | 495,0 | +28,0 | +25,0 |
| 50 | geliştirici | 496,5 | 496,5 | +1,5 | +1,5 |

49 adımın 48'i artı, 1'i sıfır (48. kişi), hiçbiri eksi. 48. kişi tohum tohum: 20 tohumun 7'sinde aşağı, 4'ünde eşit, 9'unda yukarı (önce 16 / 2 / 2). Ölçülen sebep kalktı: 47 → 48 kişide sprintteki kart 56,9 → 57,5 (önce 58,5 → 62,4), bekleme 4,34 → 4,42 hafta (önce 4,45 → 4,78).

### 15.5 Marjinal getiri tablosu
Taban ekibe bir kişi eklenince teslim farkı (puan/hafta), önce / sonra. 25 hücrenin 22'si değişmedi.

| Taban | +3★ geliştirici | +3★ testçi | +3★ tasarımcı | +3★ PM | +1★ geliştirici |
|---|---|---|---|---|---|
| S2 · 3 kişi | +11,5 / +10,5 | +9,5 / +9,5 | +0,4 / +0,4 | +6,8 / +6,8 | +8,1 / +7,4 |
| S3 · 6 kişi | +12,0 / +12,0 | +7,0 / +7,0 | 0,0 / 0,0 | 0,0 / 0,0 | +9,0 / +9,0 |
| S4 · 12 kişi | +4,0 / +4,0 | +4,5 / +4,5 | -1,0 / -1,0 | +2,0 / +2,0 | +1,5 / +1,5 |
| S5 · 25 kişi | +4,0 / +4,0 | +5,5 / +5,5 | +5,0 / +5,0 | +13,0 / +13,0 | +2,0 / +2,0 |
| S6 · 50 kişi | +2,5 / +2,5 | +7,0 / +7,0 | +17,5 / +16,5 | +14,5 / +14,5 | +1,0 / +1,0 |

S2'ye geliştirici eklemek 1 puan az getiriyor (34 → 33): ekipte testçi yok ve geliştiricilerin Test kutusu kapalı, testi yalnız kurucu yapıyor; 4 kişilik ekipte test satırı tavana değiyor ve plan kart almayı erken bırakıyor. Getiri yine artı.

### 15.6 Kalan ve yan etkiler
1. **S4 + 3★ tasarımcı -1,0 (değişmedi, tolerans içinde).** Sistematik: 20 tohumun 16'sında aşağı. Aşama tavanı bu ekipte hiç bağlamıyor, bu yüzden düzeltme dokunmadı. Ek deney (10 tohum): iki ekibe aynı planlama kapasitesi verilince fark yine -1 (10 tohumun 7'sinde aşağı); tasarımcıların önden tasarımı iki ekipte de kapatılınca tasarımcı eklemek +11 getiriyor ve hiçbir tohumda düşürmüyor. Kayıp önden tasarım kuralının içinde. Gözlem: önden yapılan tasarımın bir kısmı, kart sonradan PM'den hazırlık alıp tasarım ihtiyacı küçülünce ihtiyacın üstünde kalıyor (10 tohum medyanı, 60 haftada S4'te 125, S4 + tasarımcıda 469 tasarım puanı); kaybın sebebinin bu olduğu ölçülmedi. Ölçüt 1'in sınırında olduğu için D2'nin ölçümü izlemeli.
2. **Testi yetişmeyen bileşimlerde yığın kalktı.** Testçisiz karışımlarda kartın bekleme süresi 23-39 haftadan 4,3 haftaya, sprintteki kart 30-139'dan 5,9'a indi; teslim 41'den 42'ye çıktı, darboğaz yine Test. §13 g5'in ("testçisiz bileşimde bekleme 27,7 hafta") yerini "test satırı dolu, plan kart almıyor" alıyor; boşta kişi aynı (S11 17,2 → 20,8 kişi-hafta/hafta) ve darboğaz satırında görünüyor. Ölçeklenen testçi deneylerinde (bütün testçiler 1★) bekleme 6,6-10,4'ten 4,4-4,6 haftaya indi, teslim biraz arttı (12 kişi 93 → 95, 25 kişi 188,5 → 192, 50 kişi 338 → 341).
3. **Tek kurucunun bedeli.** Düzeltme payı tavanı 20 tohumda, MVP sonrasındaki 651 sprintte 33 kez bir düzeltme kartını sonraki sprinte bıraktı. Açık hata medyanı 6,0 → 6,5, pencere maksimumu 11 → 11,5, son 20 haftanın eğimi -0,00 → +0,07 hata/hafta (sınır 0,2). Medyan düzeltme payı erken ve geç %25 (değişmedi). MVP 6. hafta.
4. **Tahmin = sonuç** etkilenmedi: plan sprint başında kurulur, iki kural da yalnız kart alımını sınar.

### 15.7 Yeniden üretim
```
python -I dsim.py exec collect.py     # 145 senaryo x 20 tohum -> results.pkl (duzeltme sonrasi)
python -I dsim.py exec collect2.py    # olcekte testci deneyi
python -I dsim.py exec xafter.py      # 10 olcut, sonra
python -I dsim.py exec xcmp.py        # once / sonra karsilastirmasi (results_before.pkl, results_after.pkl)
python -I dsim.py exec xk1.py         # asama tavani denemesi (DSIM_PHASE_K=1.25 | 1.5 | 2.0)
python -I dsim.py exec xdes.py        # S4 + tasarimci: ayni kapasite, onden tasarim kapali
DSIM_PHASE_CEIL=0 DSIM_FIX_SHARE_MAX=0 python -I dsim.py exec xrepro.py   # duzeltme oncesi birebir
```
Düzeltme öncesi sonuçlar `results_before.pkl`, betiğin düzeltme öncesi kopyası `dsim_before.py`. `x_rapor.py` §1-§14'ü yeniden yazar; düzeltme sonrası sonuçlarla koşulursa bu bölüm silinir, o yüzden koşulmadı.

## İnceleme notu
Kıdemli inceleme, 17 Ekim 2026 (Opus). Repo kodu değişmedi. Bu bölüm dışında rapora dokunulmadı; düzeltmeler
`D_MODEL_v2.md`'de "(inceleme)" işaretiyle.

1. **Betik modelle aynı.** `dsim.py` okundu: sabitler §6.2 ile, `fit` sınıfları ve kurucu tabanı §6.3 ile, hafta oynatma
   §6.6 ile, kapanış ve Poisson §6.7 ile, iki tavan §3.11 ile birebir. §2'nin elle doğrulaması ve §3'ün ön hesapla farkı
   (en çok %8) tutarlı.
2. **"Darboğaz" sütunu yanıltıcı.** Ölçü (yorum 3) devreden kartların kalan işini mutlak puanla topluyor; Geliştirme her
   kartta en büyük pay olduğu için hep öne çıkıyor. İnceleme ölçümü (aynı betik, 5 tohum, kalan iş ÷ aşama kapasitesi):
   S2 Test, S3 Geliştirme, S4 Test, S5 Test, S6 Test, S10 Geliştirme, S8 Test, S11 Test, S11b Tasarım, S9a Geliştirme.
   §15.5'in marjinal getirisi de bunu destekliyor (50 kişiye geliştirici +2,5, testçi +7, tasarımcı +16,5). §3.1, §4 ve
   §15.3'ün darboğaz sütunları oranla yeniden basılmalı; ek betik `scratchpad/inceleme_d/darbogaz.py`.
3. **A'nın hedeflerinin yalnız düzeltme payı kısmı ölçüldü (§8).** A'nın E1 §9 tablosundaki açık hata (sürüm anında ≤ 8,
   tepe ≤ 16) ve haftalık yeni hata (≤ 4) hedefleri §3.2'nin sayılarıyla 25 kişide aşılıyor (13 / 20; ~4,7 yeni hata).
   §8'in "her ekipte tutuyor" hükmü yalnız düzeltme payı ve hata sprinti için geçerlidir.
4. **25 ve 50 kişinin teslimi sonsuz kart akışına dayanır** (§6.4: K3'ten sonra 40 puanlık kartlar). Oyunun bugünkü
   kataloğunda K3'ten sonra kart yok; bu satırlar EA'nın içerik koşuluyla geçerli.
5. **Açık kalan gözlemler** (§13 g3, g6, g7 ve §15.6 madde 1) `D_MODEL_v2.md` inceleme notunun 10. ve 11. maddesine taşındı.
