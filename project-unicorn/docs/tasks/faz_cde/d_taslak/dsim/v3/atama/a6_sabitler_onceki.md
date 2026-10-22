## 0. Sabit tablosu (hiçbir koşudan önce yazıldı; hepsi "onay bekliyor")

A7 incelemesi (Opus) bu tabloya üç işaretli ek yaptı, değer değiştirmedi: satır 10'a kalibrasyonun bulduğu değer (önceden §0.1'deydi), satır 9'a ve tavan örneklerine "simülasyonda R = 3 kart yok" notu. İşaretler `[A7: ...]`.

Kurulan model Erdem'in ilkesinin doğrudan okunuşu (Karar 19): hata işin karmaşıklığıyla ölçeklenir; gereksinimi karşılayan kişi karta tavanın bir oranı kadar hata sokar, gereksinimin üstündeki her 2 yıldız bu oranı yarıya indirir.

**Model, tek satırda.** Bir kartın Geliştirme aşamasında doğan beklenen hata:

`H = T × tür × (1 − PM hazırlığı) × Σ ( iş payı_k × m(Δ_k) × TİTİZ_k )`

- `T = c × büyüklük × R^p` kartın **hata tavanı** (en çok bu kadar hata çıkabilir).
- `m(Δ) = 0,20 × 0,5^(Δ/2)`, `Δ = kişinin Yazılım yıldızı − R` (kişi başına, kendi iş payıyla ağırlıklı).
- Bugünkü modelden **yalnız** "yapım kalitesi 1 ÷ √Y" terimi `m(Δ)` ile değişir; `0,04 × büyüklük` çarpanı `T`'ye dönüşür (bugünkü 0,04 yerine `c × R^p`).
- Gerçek hata sayısı yine ortalaması `H` olan Poisson çekimidir (bugünkü gibi, aynı tohum kuralı).

| # | Ad | Değer | Anlamı (tek cümle) | Nereden geldi | Durum |
|---|---|---|---|---|---|
| 1 | `M0` | 0,20 | Gereksinimi tam karşılayan kişi (Δ = 0) tavanın %20'sini hata olarak sokar. | Erdem'in örneği (karar 19: 100 tavanda 3★ → 20 hata) | onay bekliyor |
| 2 | `M_YARI` | 2 yıldız | Gereksinimin üstündeki her 2 yıldız hata oranını yarıya indirir: `m(Δ) = 0,20 × 0,5^(Δ/2)`; Δ = 1 → 0,141, Δ = 2 → 0,100, Δ = 3 → 0,071, Δ = 4 → 0,050. | Erdem'in örneği (Δ = 2 → 0,10: 5★ → 10 hata) + benim seçimim (iki noktadan geçen üstel eğri) | onay bekliyor |
| 3 | negatif Δ | aynı eğri uzatılır | Gereksinimin altındaki kişi (Erdem'in tarifinde atanmaz, bugünkü kuralda atanabilir) daha çok hata sokar: Δ = −1 → 0,283, Δ = −2 → 0,400. | benim seçimim (yeni sabit yok; kuralsız R kolunu haksız kayırmamak için) | onay bekliyor |
| 4 | `R` (gereksinim) | kartın **Geliştirme aşamasındaki** Yazılım kapısı, en az 1★, ekibin en iyi Yazılım yıldızını aşamaz | Kartın o aşamada istediği en az yıldız; hatların kilit verisinden (A3'ün `creq`'i). | Erdem'in örneği ("gereksinimi karşılayan") + A3 verisi | onay bekliyor |
| 5 | `R_TABAN` | 1★ | Kilidi olmayan kart (K1'in çoğu, düzeltme kartı) 1★ istiyormuş sayılır; yoksa tavan sıfır olurdu. | benim seçimim | onay bekliyor |
| 6 | `p` (gereksinim kuvveti) | 1 (doğrusal) | Tavan gereksinimle doğrusal büyür: 3★ isteyen iş, aynı büyüklükte 1★ isteyen işin 3 katı hata çıkarabilir. | benim seçimim; gerekçe: Erdem'in iki örneği (3 sprintlik iş 100, basit iş 5; oran 20) en yakın `p = 1` ile kurulur (K-E kalibrasyonunda 69,6 puanlık 3★ iş ile 15 puanlık 1★ iş oranı 13,9) | onay bekliyor |
| 7 | `büyüklük` | kartın puanı (K1 15, K2 25, K3 40; düzeltme kartı 2 × hata sayısı) | Tavan kartın toplam iş puanıyla büyür; bugünkü `0,04 × puan` ile aynı girdi. | bugünkü kalibrasyon | onay bekliyor |
| 8 | `c` (K-E) | **0,4789** | Erdem'in örneği birebir: "3 sprintlik iş" tavanı 100 olacak şekilde. | Erdem'in örneği; hesap §8'de | onay bekliyor |
| 9 | "3 sprintlik iş" tanımı | 69,6 puan, gereksinim 3★ | Bir 3★ kişinin (Y = 1,16 → 11,6 puan/hf) 3 sprintte (2 hf'lik sprint × 3 = 6 hf) yaptığı iş; bu iş 1,74 K3 kartı eder; `T(69,6; R = 3) = 100`. Bu tanımla K1 kartı (15 puan, R = 1) tavanı 7,2, K3 kartı (40, R = 3) 57,5. [A7: simülasyonun kapı verisinde Yazılım kapısı en çok 2★, R = 3 kart yok; gerçek K3 kartı R = 1'de 19,2, R = 2'de 38,3.] | benim tanımım (Erdem "bugünkü ekip ve kart ölçeğinde neye denk geliyorsa" dedi) | onay bekliyor |
| 10 | `c` (K-H) | **0,212** [A7: koşulardan önce "kalibrasyonla bulunacak" yazıyordu; bulunan değer ve denemeler §0.1 ve §6'da] | Hata hacmi nötr: 6 kişilik ekipte (S3), bugünkü R okumasıyla, 21-60. haftada 20 tohumun ortalama toplam **doğan** hatası bugünkü modelle aynı (tolerans ±%2). | Erdem'in görevi (ekonomi ve A'nın hata sınırları bozulmasın) | onay bekliyor |
| 11 | bugünkü gibi kalanlar | değişmez | Test yakalama `c_test = 0,57 × √Y(Test)` (kendi geliştirdiği kart ×0,6); TİTİZ hata ×0,5; düzeltme kartı türü ×0,3; ağır düzeltme olasılığı 0,18 (5,3 puan) / hafif 1,3 puan; hata sayısı Poisson; ekipte iş payı ağırlığı. | bugünkü kalibrasyon (PRD Karar 6, D0s) | değişmiyor |
| 12 | PM hazırlığının hata çarpanı | bugünkü: `1 − h`, `h = 0,10 + 0,075 × (PM yıldızı − 1)`, en az 0,05, en çok 0,40 (×0,90 → ×0,60) | PM hazırlığı hata çarpanını bu kadar küçültür; hız bonusu da bugünkü gibi. | bugünkü kalibrasyon | değişmiyor (kol 15 hariç) |
| 13 | PM karmaşıklığı `K` | `büyüklük × R^p` (= `T ÷ c`) | PM atamasında "en karmaşık kart" = en çok hata çıkarabilecek kart; "en basit" = en az. | benim seçimim (Karar 21'in "gereksinim × büyüklük" tarifi) | onay bekliyor |
| 14 | PM okuması (i) `basit` | karmaşıklık sırası ile PM kalitesi sırasını eşle | Kartlar K'ye göre büyükten küçüğe dizilir, PM'ler yıldıza göre iyiden zayıfa; her PM'e kendi hazırlık kapasitesiyle orantılı ardışık bir kart dilimi düşer: en karmaşık dilim en iyi PM'e, en basit dilim en zayıf PM'e. Kartın Ürün kapısını geçemeyen PM'in payı bir üstteki uygun PM'e kayar. | Karar 21 "en basit kart en zayıf PM" | onay bekliyor |
| 15 | PM okuması (ii) `zor` | zor karta en iyi PM, kalanları boştaki en iyi PM sırayla | Kartlar K'ye göre büyükten küçüğe; her kart, hazırlık zamanı kalan PM'ler içinde en yüksek yıldızlıya gider. | Karar 21, Erdem'in "fena bulmadığı" ikinci okuma | onay bekliyor |
| 16 | PM hata azaltması Δ_PM'e bağlı (kol) | `h = 0,10 + 0,075 × Δ_PM`, en az 0,05, en çok 0,40; `Δ_PM = PM yıldızı − kartın Ürün kapısı` (en az 1★) | PM'in hata azaltması mutlak yıldızından değil, kartın gereksinimini ne kadar aştığından gelir; Ürün kapısı 1★ olan kartta bugünküne eşittir, 2★ olan kartta 0,075 daha küçüktür. | benim seçimim (eğim ve sınırlar bugünkü `prep_h`'tan) | onay bekliyor |
| 17 | Kalan-büyükten-küçüğe kolu (`BK`) | tarifin 2. adımı yerine | En yüksek gereksinimli kart tarifteki gibi en iyilere gider (gereksinim ve "kart bitene kadar kalır" korunur); kalan kartlar o aşamadaki kalan işe göre büyükten küçüğe dizilir, her karta sıradaki en hızlı uygun kişi gider; artan kişi yardıma (tarifin 3. adımı). | A4 Soru 2 B | onay bekliyor |
| 18 | söz kartı | öne geçmez | Söz verilmiş kart atamada plan sırası dışında öncelik almaz (A3'ün ana okuması aynen); kaçma riski darboğaz satırında. | Erdem'in kararı 20 (B) | onay bekliyor |
| 19 | ölçüm düzeni | 20 tohum eşli; ekipler 1, 3, 6, 12, 25, 50 kişi (`S1`-`S6`); sınırsız arz 60 hf (pencere 21-60); kaynaklı arz ve söz `PR` (80 hf, pencere 21-80); sprint 2 hf | A3 ve D0s ile aynı pencere ve ekipler. | A3 | değişmiyor |
| 20 | ana ölçüm | K-H; K-E yan | Ekonomi ve A'nın hata sınırları bozulmasın diye ana tablo hacim-nötr kalibrasyonla; Erdem'in sayıları birebir hâli yanında. | Erdem'in görevi | onay bekliyor |

**Tavan örnekleri (K-E, c = 0,4789):** K1 kartı (15 puan, R = 1) T = 7,2; K2 kartı (25 puan, R = 2) T = 23,9; K3 kartı (40 puan, R = 3) T = 57,5; "3 sprintlik iş" (69,6 puan, R = 3) T = 100. Gereksinimi tam karşılayan kişi bunun %20'sini sokar (K3: 11,5; 3 sprintlik iş: 20); gereksinimin 2 yıldız üstündeki kişi %10'unu (10). [A7: R = 3 olan kartlar örnektir, simülasyonda yoktur. Simülasyonun en zor kartı 40 puanlık, 2★ Yazılım kilitli K3 kartı: K-E'de tavan 38,3, 2★ kişi 7,7, 4★ kişi 3,8 hata; K-H'de tavan 17,0, 2★ kişi 3,4, 4★ kişi 1,7.]
