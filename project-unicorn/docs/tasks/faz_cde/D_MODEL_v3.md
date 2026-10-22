# Faz D · Ekip modeli v3
Hazırlayan: yardımcı yönetmenin alt ajanı (Opus), 17 Ekim 2026 gecesi. Repo kodu değişmedi, Godot koşturulmadı, commit yok.

**Kaynaklar.** Erdem'in birebir metinleri `ERDEM_CD_YORUM.md` ve `ERDEM_CDQ_CEVAP.md` (Ek dahil; çelişkide bunlar geçerli);
`D_MODEL_v2.md` (bundan sonra "v2"); `D_SIM.md`; `arastirma/R10_TEST_BILINEN_HATA.md`; `SPRINT_DUZENI.md`;
`arastirma/R4_GERCEK_PRATIK.md`; `../faz_ab/RAPOR_A.md`, `../faz_ab/PRD_FAZ_A_HATALAR.md`, `../faz_ab/PRD_FAZ_B_OLAYLAR.md`.

**Bu belge kendine yeterlidir.** Simülasyonu yazacak ajan modeli yalnız buradan kurar (§3 kurallar, §6 tanım). v2'den
aynen gelen bölümler buraya taşındı; yalnız oyun karşılaştırmaları (v2 §2) atıfla bırakıldı.

**Etiketler.**
- **Erdem (17 Ekim akşam):** `ERDEM_CDQ_CEVAP.md`'de açıkça kabul ettiği ya da istediği şey.
- **Onaylı (v2):** v2'de önerilip bu turda Erdem'in "okey" dediği madde.
- **Öneri:** bu belgenin önerisi; onay bekler. **[ÇALIŞMA]:** tasarım sabiti, onay bekler.
- Kod iddiası `dosya:satır`, dış iddia URL ya da araştırma raporu bölümü taşır. Tahmin "(tahmin)" diye yazılır.

**Ön hesap.** Bütün yeni tablolar §6'nın birebir uygulaması olan prototipten gelir:
`C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dmodel3/dsim3.py`
(v2 betiği `dsim/dsim.py` üstüne kuruldu; koşu betikleri aynı klasörde `big.py`, `curve.py`, `trig2.py`, `fnd.py`,
`nofix.py`, `c37.py`; ham sonuç `big.pkl`, `curve.pkl`, özet `rep_main.txt`, `rep_pol.txt`). 20 tohum, 60 hafta, 21 ile
60. haftaların medyanı; kişi ekleme eğrisi 10 tohum. Simülasyon ajanı bu dosyadan başlayabilir; bağlayıcı olan §6'dır.

---

## 0. Özet
1. v2'nin onaylı parçaları aynen kalır: kart kadrosu ve aşama sırası, şirket çapında ekip kaybı yok (D1), A'nın sabit
   sınırlarının oranlanması (D5), plan ekranının dört parçası (D6). Değişen dört konu: test ve bilinen hata (D2), PM
   hazırlığının yıldıza bağlanması (D3), kurucu tabanı (D4), sprint düzeninin modele işlenmesi (`SPRINT_DUZENI.md` §5.1).
2. **Test hatayı bulur, ekip aynı sprintte düzeltir.** Kartın hata sayısı test bittiği an belli olur. Bulunan hata kartın
   "Düzeltme" işine döner ve geliştiricilerin kapasitesinden gider. Sprint biterken düzeltilmemiş bulunan hata "bilinen
   hata"dır. Bulunamayan hata kart yayına çıkınca kartın hattına açık hata olarak düşer (A'nın tek deposu).
3. **Kartta yüzde yok.** "Hata ihtimali %35" kalkar. Sprint içinde kart satırı "Test: 3 hata buldu, 2'si düzeltildi" yazar.
4. **Yakalama yükselir.** Tek testçi 1★ %46, 3★ %61, 5★ %81 yakalar (v2'de %32, %43, %57). Kendi geliştirdiği kartı test
   eden kişi bunun %60'ı kadar yakalar. Hata yükü 0,03'ten 0,04'e çıkar; kaçan hata 6 ve 12 kişide v2'ye yakın kalır (0,68 ve 0,58; v2 0,57).
5. **Sprint sonu sorusu** yalnız bilinen hata o sprintte bulunanın üçte birine ulaştığında gelir (en az 1). Ön hesapta 3
   ile 25 kişilik ekiplerde sprintlerin %4 ile %29'u, yani en çok üç sprintte bir. Vurgulu cevap "Sonraki sprinte bırak".
   Ölçülen bedel küçük ve dürüst: hep gönderen oyuncu aynı teslimle 0,1 ile 0,2 hafta erken çıkar, açık hatası en çok %14
   artar.
6. **Testçinin değeri hissedilir:** aynı ekipte 1★ yerine 5★ testçi kaçan hatayı (100 teslim puanı başına) %57 ile %64
   azaltır ve bulunan hatayı 2,3 ile 2,7 katına çıkarır. Test kutulu geliştirici yerine aynı sayıda kişiyle testçi: teslim
   %9 ile %14 artar, kaçan hata %25 ile %36 azalır. v2'de testçinin ek değeri %2 ile %10'du, kalite farkı yoktu.
7. **PM:** hazırlık işi kartın %20'si (onaylı). Hazırlık hızı Erdem'in örneğiyle haftada 15 (1★) ile 25 (5★) hazırlık
   puanıdır; birimi bugünkü oyunun kart puanıyla aynı sayıdır (§3.8). Hazır kart 1★'da %10, 5★'da %30 hızlı biter, hata
   yükü ×0,90 ile ×0,60 arası. Bir PM yaklaşık 7 (1★) ile 12 (5★) kişiyi besler. Birden çok PM varsa fayda en iyi PM'in
   yıldızındandır; yoksa PM eklemek teslimi düşürüyordu.
8. **Kurucu** her aşamada en az 2★ (Y = 0,86) hızında çalışır, bu taban oyuncuya yazılmaz. Tek kurucunun MVP'si 6. haftada
   kalır (20 tohumun 3'ünde 7). Tek → +1 → +2 → +3 kişi: altı alım sırasının hiçbirinde şirketin teslimi düşmüyor, MVP
   gecikmiyor. Yeni kural: kurucu kendi güçlü alanında uzmanla aynı sıradadır; kural olmadan 4★ geliştirici kurucuya 1★
   geliştirici almak MVP'yi 4'ten 6. haftaya itiyordu. (inceleme) Kurucunun kendi işi en çok %10,1 düşer (5★ kurucu ve üç
   geliştirici; `D_SIM_v3.md` §6.1), %7 değil; her düşüşün nedeni üç koddan biridir ve plan ekranında yazar (§3.9).
9. **Sprint düzeni:** öneri planın kendi tavanına kadar doldurur, uymayan adayı atlayıp sıradakine bakar (inceleme), bot yalnız
   öneriyi kullanır; arz dört kaynaktan gelir (kademe, derinlik kartı, hesap isteği, EA modülü); düzeltme kartı hattın
   hatasına oranlanır (hata başına 2 puan; alt sınır 5 kalktı, inceleme); EA'da takım (ekip başına lider) takımın içinde
   kayıp ve lider çarpanı taşır.
10. **D5'in formülü:** A'nın mutlak sınırları k = en büyüğü (1; canlı hat ÷ 9; √(haftalık teslim ÷ 55)) ile çarpılır. Ölçüm:
    hiç düzeltmeyen oyuncu her ölçekte 14 ile 23 haftada itibar eşiğine varır, düzenli düzelten hiçbir ölçekte varmaz.
    Mutlak 30'da 50 kişilik ekip 4 haftada varıyordu.
11. **Ön hesap:** kişi başı teslim 1, 3, 6, 12, 25, 50 kişide 4,5 · 6,5 · 8,0 · 8,9 · 10,6 · 10,8. Düzeltme payı her ekipte
    A'nın hedefinde, hata sprinti 0 (tek kurucuda 3/507). Tahmin = sonuç farkı en çok 3,6e-15 (bulunan hata dahil). Kişi
    ekleme eğrisinde en kötü adım −1,0 (tolerans sınırında). (inceleme) 1 haftalık sprintte tek kurucu eski "en az 5 puan"
    kuralıyla sprintlerin %50'sinde hata sprinti yaşıyordu (`D_SIM_v3.md` §8.6); alt sınır kalkınca %6,6 (§3.12 c).
12. **Bedel:** uygulama yaklaşık 52 ile 58 saat (v2'nin 30 ile 35'i, sprint düzeninin 15'i, bu turun farkı 7 ile 8). EA
    takımı ayrıca 10 ile 14 saat. 4 soru.

---

## 1. Erdem'in bu turdaki sözleri ve karşılıkları
Sözler `ERDEM_CDQ_CEVAP.md`'den kısaltılmış alıntıdır.

| # | Erdem'in sözü | Karşılık | Nerede | Etiket |
|---|---|---|---|---|
| 1 | "D1'e gelince okey… PM değeri koordinasyon değil, önden hazırlık olsun… ekip büyüdükçe bir verim kaybı… her ekip bazında bir lider" | Kadro ve aşama sırası aynen; şirket çapında kayıp yok; takım içi kayıp ve lider EA'da | §3.4, §3.5, §3.14 | Onaylı (v2); takım öneri |
| 2 | "Kartın hata yükü işin büyüklüğüyle orantılı olması çok çok mantıklı" | Kalır: H = 0,04 × S × … | §3.6 | Onaylı (v2); 0,04 [ÇALIŞMA] |
| 3 | "En iyi testçinin bile %43'ünü kaçırması bana biraz iddialı" | 5★ testçi %81 yakalar, %19 kaçırır. Jones'un deneye dayalı test satırı (ort. %75, en çok %85) | §3.6 | Öneri |
| 4 | "Kart hata ihtimali %35 gibi bir şey yazmayalım" | Kartta, ipucunda ve plan ekranında yüzde yok | §3.10 | Erdem |
| 5 | "Testçiler şu kadar bug buldu… şu kadarı düzeltildi" | Kart satırı sprint içinde "Test: 3 hata buldu, 2'si düzeltildi" | §3.6, §3.10 | Erdem; metin öneri |
| 6 | "Bu haliyle gönderelim mi yoksa bir sonraki sprinte mi atalım" | Sprint kapanışında tek toplu soru; yalnız eşik üstünde; vurgulu cevap bırak | §3.7 | Erdem; kural öneri |
| 7 | "PM'in yıldızına göre… 1 yıldız %10 … 5 yıldız %30'a kadar" | Hız bonusu b = %10 (1★) … %30 (5★) | §3.8 | Erdem |
| 8 | "Önden hazırlanmış karttaki bug ihtimalinde bunu yıldızına bağlayabiliriz" | Hata çarpanı ×0,90 (1★) … ×0,60 (5★); 3★'da v2'nin onaylı ×0,75'i | §3.8 | Erdem; değerler öneri |
| 9 | "1 yıldız… 15 SP'lik işi… 5 yıldız 25 SP'lik… full lineer şekilde arttıramayız" | Hazırlık hızı 15 + 10 × √((s − 2) ÷ 8) puan/hafta: 15 · 20 · 22 · 24 · 25. Birim eşlemesi §3.8 | §3.8 | Erdem (uçlar); eğri öneri |
| 10 | "İki buçuk yıldız çok… İki yıldız gibi çalıştıralım ama oyuncunun görmemesi lazım" | Kurucu tabanı Y = 0,86; dosyada gerçek yıldız, tabanın adı hiçbir yerde yazmaz | §3.9 | Erdem |
| 11 | "Lan ben tek başımayken daha hızlı çalışıyordum sorusunu sordurtur mu?" | Ölçüldü (altı alım sırası, üç kurucu tipi); bir kural eklendi (kurucunun güçlü alanı) | §3.9, §4.7 | Öneri |
| 12 | "D5 okey… 50 kişiye ulaştığında… düzeltme payı %13" | Doğrusu %3 (v2 §4.2, `D_SIM.md` §3.2); v3'te de %3,0 | §4.2, §4.9 | Onaylı (v2) |
| 13 | "Aşama şeridi… darboğaz cümlesi her zaman görünür… Claude Design'da maketlenmesine gerek yok… oyunun UI'yla" | Kalır; gösterim Menajer diliyle (`docs/mockups/menajer/`) | §3.10 | Onaylı (v2) |
| 14 | "Çekirdek, güven ölçek, entegrasyonlar, onboarding… ürün kalitesini buna bağlamakta bir sakınca görmüyorum" | D eksen okumaz; derinlik kartının kazancı alanın puanına yazılır | §3.13, §5 X | Erdem (Q1) |
| 15 | "Kararlılığı… açık hata kesiminin başlığı olarak kalsın" | D'nin çıktısı açık hata ve bilinen hata; başlık C ve X'in | §5 C | Erdem (Q2) |
| 16 | "Müşteriler ayrılmasın zaten… amacımız oyuncuyu… aşırı zorlamak değil" | Gönder sorusunun bedeli küçük ve görünür; varsayılan güvenli seçenek | §3.7 | Erdem (C5) |
| 17 | "Ekip büyüdükçe… handle edebileceğimiz kart sayısı artar… bu düzen nasıl olmalı?" | `SPRINT_DUZENI.md` §5.1 maddeleri modelde | §3.12 ile §3.14 | Öneri |
| 18 | "Oyuncunun göremediği, yönetemediği bir şeyi… koymayalım" (gider için) | Aynı ilke modelde: her kural ekranda bir satıra düşer (§4.1 son sütun) | §4.1 | Erdem (C3) |

---

## 2. Oyun ve gerçek pratik karşılaştırması
v2 §2'nin sekiz tablosu (rol çıktısı, kartın ihtiyacı, karta kaç kişi, ekip büyüklüğü, test ve hata, ön hazırlık, darboğaz,
50 kişide yönetim) aynen geçerlidir. Bu turun eklediği karşılaştırma yalnız test ve bilinen hata içindir (R10 §3.6):

| Oyun | Oyuncuya sayı | Karar | Varsayılan | Bizim seçimimiz |
|---|---|---|---|---|
| Game Dev Tycoon | Hata baloncuğu; ceza puanın oranı | Oyun başına bir çıkış | Düzeltme sürer | Oranlı eşik (bulunanın üçte biri) |
| Software Inc. | Toplam gizli | Oyuncunun kendi kuralı | Yok | Gizli toplam almıyoruz: bulunan ve düzeltilen sayı görünür |
| Mad Games Tycoon 2 | Görünür sayı ve QA çubuğu | Dört seçenek, oyun başına | "Polish" sürer | Sayı adetle yazılır, yüzde yok |
| Game Dev Story | Adet | Oyuncu erken çıkar | Hata ayıklama sürer | Vurgulu varsayılan "bırak" |
| Scrum Guide | Done tanımı | Seçenek yok; bitmeyen iş backlog'a döner | Bırak | Bırak varsayılan; gönder oyuncunun bilerek seçtiği şey |

Ortak ders: sayı adetle yazılır; zorunlu ve sık bir "gönder mi" kapısı hiçbir referans oyunda yok, bu yeni bir kalıp ve
sıklığı sınırlanmalı (R10 §4.3; MGT2 oyuncularının tekrarlanan tekil karar şikâyeti).

---

## 3. Model
Her kuralın altında "Neden var" ve gerekiyorsa "Ölçekte" satırı vardır. (v2) işaretli kurallar v2'den aynen taşındı.

### 3.1 Birimler (v2)
- **Puan.** 2,5★ (alan puanı 5) bir kişi, 8 saatlik haftada, verimi 1 iken ana alanında haftada 10 puan üretir. Bugünkü
  ölçeğin 5 katı (Erdem 17 Ekim: "kişinin haftalık puanı ölçek falan okey").
- **Kart büyüklüğü (S).** K1 15, K2 25, K3 40; araştırma kartı 5; ücretli plan 15. Düzeltme kartı bu turda değişti (§3.12 c).
- **Sprint.** 1 ya da 2 hafta, oyuncu seçer. Toplam tavan sprintin işi ≤ 1,25 × kapasite; yanında aşama tavanı ve düzeltme
  payı tavanı (§3.12).
- Neden var: aşama ihtiyacı ve yarım yıldız farkı tam sayıyla okunur.

### 3.2 Kartın ihtiyacı (v2)
Her hattın veride bir **iş profili** alanı vardır (tasarım, geliştirme ya da test ağırlıklı). Kart üç aşama puanı ister:

| Kart (Tasarım / Geliştirme / Test) | Tasarım ağırlıklı | Geliştirme ağırlıklı | Test ağırlıklı |
|---|---|---|---|
| K1 · 15 | 5 / 7 / 3 | 2 / 10 / 3 | 2 / 8 / 5 |
| K2 · 25 | 9 / 11 / 5 | 4 / 16 / 5 | 3 / 13 / 9 |
| K3 · 40 | 14 / 18 / 8 | 6 / 26 / 8 | 4 / 22 / 14 |

- Araştırma kartı: yalnız Ürün, 5 puan. Ücretli plan: 2 / 10 / 3. Ar-Ge "Tasarım sistemi" tasarım ağırlıklı hatların
  kartlarına %20 indirim (v2 §3.2).
- **Yeni (v3): dördüncü alt aşama "Düzeltme".** Başlangıçta 0'dır; test bitince bulunan hataların işiyle dolar (§3.6).
  Geliştirme satırında sayılır, geliştirme kuralıyla atanır.
- Oyuncu kartta "Tasarım 9 · Geliştirme 11 · Test 5" görür. Profil adıyla görünmez.
- Neden var: rol kendi aşamasının puanını üretiyorsa kart her aşamadan ne istediğini söylemeli.

### 3.3 Kişinin katkısı (v2; kurucu tabanı değişti)
**Haftalık aşama hızı** = 10 × Y(s) × U × verim × saat × pay × huy

| Terim | Değer | Neden var |
|---|---|---|
| Y(s) | s = o aşamanın alanındaki puan (0 ile 10); Y = 0,5 + 0,05·s + 0,01·s² | Yıldız gerçekten fark eder |
| U, uyum | Ana alan 1,0 · ikincil 0,7 · uymayan 0,4 (Y × U en az 0,3) · kurucu her aşamada 1,0 | Erdem 17 Ekim: "0,7 çarpı yıldızı kadar", uymayan 0,4 ya da 0,3 |
| verim, saat | Bugünkü değerler | Verim eğrisi D'nin kapsamı dışında |
| pay | A K1: tek iş 1; Yapım ve Test 1; Yapım ve Destek 0,5; yalnız Destek ya da Ar-Ge 0 | Kimse iki yerde tam sayılmaz |
| huy | TİTİZ hız ×0,85; GÖZÜ YÜKSEKTE ×1,15 | Dosyada yazan huy sprintte de çalışır |
| Kurucu tabanı (v3) | Kurucunun Y'si her aşamada en az 0,86 (2★, puan 4) | §3.9 |

| Yıldız (puan) | 1★ (2) | 1,5★ (3) | 2★ (4) | 2,5★ (5) | 3★ (6) | 3,5★ (7) | 4★ (8) | 4,5★ (9) | 5★ (10) |
|---|---|---|---|---|---|---|---|---|---|
| Ana alan, puan/hafta | 6 | 7 | 9 | 10 | 12 | 13 | 15 | 18 | 20 |
| İkincil (×0,7) | 4 | 5 | 6 | 7 | 8 | 9 | 11 | 12 | 14 |
| Uymayan (×0,4, en az 3) | 3 | 3 | 3 | 4 | 5 | 5 | 6 | 7 | 8 |

**Kim hangi aşamada (Görevler matrisi aşama kapısıdır, v2):**

| Rol | Yapım kutusu | Test kutusu |
|---|---|---|
| Kurucu | Tasarım, Geliştirme, Düzeltme ×1,0 | Test ×1,0 |
| Ürün yöneticisi | Sprint puanı yok: hazırlık ve araştırma kartı | Test ×0,4 (uymayan) |
| Tasarımcı | Tasarım ×1,0; araştırma kartı ×0,7 | Test ×0,4 (uymayan) |
| Geliştirici | Geliştirme ve Düzeltme ×1,0 | Test ×0,7 (ikincil) |
| Testçi | Geliştirme ve Düzeltme ×0,7 (ikincil) | Test ×1,0 |

- Tasarım ile kod arasında uyum yok (Erdem 17 Ekim). Uymayan işte çalışılan her hafta sprint kapanışında −2 moral.
- Moral sprint içinde değişmez; tahmin bozulmaz.

### 3.4 Hafta: aşama sırası ve kadro (v2; kurucunun sırası değişti)
- **Kadro.** Kartın her aşamasının kadrosu = ⌈aşama ihtiyacı ÷ 8⌉, en az 1. Düzeltme alt aşamasının kadrosu test bittiği an
  aynı kuralla kurulur. Erdem D1: "her 8 puanlık işe en çok bir kişi".
- **Hafta.** 0 anında başlar, 1 anında biter. Kartın sıradaki aşaması açıktır; aşama bittiği an sonraki açılır (hafta
  içinde de). Boştaki kişi, açık aşaması olan ve kadrosu dolmamış ilk karta (sprint sırasıyla) geçer. Aşamadaki herkes
  kendi hızıyla aynı anda çalışır. Kişi aşama ya da hafta bitene dek orada kalır.
- **Aday sırası:** ana alanı o aşama olan çalışan (sınıf 0), sonra kurucu (sınıf 1), sonra ikincil alanlı (2), en son
  uymayan (3); eşitlikte hızlı olan, sonra kimlik.
- **Yeni (v3): kurucunun güçlü alanı.** Kurucunun gerçek puanı 5 ve üstü olan en güçlü alanında (Tasarım, Yazılım ya da
  Test) kurucu sınıf 0'dır; orada uzmanla hız yarışır. Öbür aşamalarda sınıf 1 kalır.
  - Neden var: kural olmadan, Yazılım 4★ kurucuya 1★ geliştirici alınca yavaş uzman kadrosu 1 olan geliştirme aşamasını
    kurucunun elinden alıyor, MVP 4'ten 6. haftaya kayıyordu (20 tohum, `fnd.py`). Kuralla MVP 4'te kalır.
  - Bedeli: 4★ kurucu ve 2,5★ geliştiricide kalıcı teslim 11,0'dan 10,4'e iner (%6), yine tek kurucunun 7,5'inin üstündedir.
  - Ölçekte: yalnız kurucuya dokunur; ekip büyüdükçe kurucunun payı küçülür.
- Boş kalan süre önden işlere gider: PM hazırlığa, tasarımcı sonraki sütunun tasarımına; kalanı "boşta" diye görünür.
- Neden var (kadro ve sıra): aynı işe sınırsız kişi koymak hızlandırmaz (R4 §2.4); tasarım bitmeden geliştirme başlamaz.
  Tavan işin büyüklüğünden geldiği için şirket büyüdükçe kaymaz (Erdem D1 onayı).

### 3.5 Ekip ve koordinasyon (v2, onaylı)
- Şirket çapında kayıp yoktur. Kayıp yalnız aynı kartta yaşar: kadro ve aşama sırası.
- PM'in değeri koordinasyon değil önden hazırlıktır (§3.8).
- Takım nesnesi demoda yoktur; EA'da isteğe bağlı gelir (§3.14).
- Neden var: kanıt kaybın aynı iş üzerindeki kalabalıkta doğduğunu söylüyor (R4 §2.5); ayrı kartlardaki 20 kişiyi
  cezalandıran şirket çapında kural reddedildi (ilke 6).

### 3.6 Test, bulunan hata, bilinen hata (yeni, D2)
**Akış (bir kart için):**
1. Kart Tasarım ve Geliştirme'den geçer.
2. Test aşaması bittiği an kartın **hata sayısı** n ve **bulunan** hata sayısı F belli olur.
3. F > 0 ise kartın Düzeltme alt aşaması açılır: bulunan her hata iş ekler. Düzeltme Geliştirme satırında yapılır.
4. Düzeltme bitince kart biter, yayına çıkar. Bulunamayan n − F hata kartın hattına açık hata olarak düşer.
5. Sprint kapanışında testi bitmiş ama düzeltmesi bitmemiş kartların düzeltilmemiş hataları **bilinen hata**dır (K). Ne
   olacağını §3.7 söyler.

**Hata yükü (beklenen hata sayısı).** H = 0,04 × S × tür × (1 − h × r) × yapım kalitesi

| Terim | Değer | Neden var |
|---|---|---|
| 0,04 | Puan başına hata [ÇALIŞMA]; v2'de 0,03 | Yakalama yükseldi; kaçan hata 6 ve 12 kişide v2'ye yakın kalsın (S3 0,68 ve S4 0,58; v2 0,57) |
| S | Kartın büyüklüğü | Hata potansiyeli işle orantılı (R4 §2.3 Jones). Erdem: "çok çok mantıklı" |
| tür | Özellik, istek, ücretli plan 1,0; düzeltme kartı 0,3; araştırma 0 | Düzeltme az da olsa yeni hata sokar (R10 §2.1, %3,5 ile %7) |
| h × r | Hazırlık: r hazırlık oranı (0 ile 1), h PM yıldızından (%10 ile %40) | §3.8 |
| yapım kalitesi | Geliştirme işini yapanların payla ağırlıklı 1 ÷ √Y(Yazılım); TİTİZ ×0,5 | İyi geliştirici az hata yazar (v2) |

**Yakalama.** Testi yapan her kişinin payı (yaptığı test işi ÷ kartın test ihtiyacı) ile:
C = Σ pay × c(kişi), en çok 1; c = 0,57 × √Y(Test puanı); kişi bu kartın Geliştirme aşamasında çalıştıysa c × 0,6.

| Testi yapan | 0★ | 1★ | 2★ | 2,5★ | 3★ | 4★ | 5★ |
|---|---|---|---|---|---|---|---|
| Başkasının kartı | %40 | %46 | %53 | %57 | %61 | %71 | %81 |
| Kendi geliştirdiği kart (×0,6) | %24 | %27 | %32 | %34 | %37 | %42 | %48 |
| v2 (karşılaştırma) | %28 | %32 | %37 | %40 | %43 | %50 | %57 |

- **Neden 0,57 × √Y.** v2'nin biçimi (kalite, hız eğrisinin karekökü) korunur, tek sabit büyür. 5★'ın %81'i Jones'un deneye
  dayalı test satırının içindedir (en az %60, ortalama %75, en çok %85; R10 §2.1, URL:
  https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Defect-Removal-Efficiency.pdf). Erdem'in "%43'ünü kaçırması
  iddialı" itirazı bununla karşılanır: en iyi testçi %19 kaçırır.
- **Neden ×0,6 (kendi kartı).** Kodu yazan kendi hatasını zor görür; ikinci göz bu yüzden vardır (Myers 1978, bağımsız
  testçi çifti en etkili yöntem; R10 §2.2). 0,6, Jones'ta masabaşı kontrolün (yazanın kendi okuması, ort. %45) deneye dayalı
  teste (ort. %75) oranıdır. Testçinin hissedilir değerinin ana kaynağı budur (§4.5). Kurucu dahil herkese uygulanır.
- Uyum (0,7, 0,4) hızı keser, kaliteyi kesmez; kalite yıldız ve bağımsızlıktır (v2 ilkesi, Erdem: "gerçek test yıldızı
  okunur. Tamam").
- **Küçük karta 5 testçi.** Kadro kuralı aynen: küçük kartın testine bir kişi girer. Öbürleri başka karta geçer ya da boşta
  görünür (S7: 5 testçili ekip boşta 5,5 kişi-hafta/hafta). Kalabalık kaliteyi artırmaz.
- **Testi yapacak kimse yoksa** (Test kutusu kimsede yok, kurucu Ar-Ge'de) kart testte bekler; plan ekranı "Testi yapacak
  kimse yok" yazar (bugünkü davranış, değişmez).

**Hata sayısı ve bulunan (deterministik).** Test bittiği an, kartın tohumu (koşu tohumu ve kart kimliği) ile:
- n = Poisson(H) ters dağılımdan, kartın ilk tohum sayısıyla;
- her hata i için iki tohum sayısı u, v: u < C ise bulunur; bulunan hatada v < 0,18 ise **ağır**, değilse **hafif**.
- Plan ekranı ve kapanış aynı oynatmayı koştuğu için ikisi de aynı n ve F'yi bulur (§3.11).

**Düzeltme işi.** Bulunan hafif hata 1,3 puan, ağır hata 5,3 puan (yeniden test dahil) [ÇALIŞMA]. Düzeltme sırası bulunuş
sırasıdır; sprint biterken iş, sıradaki hatanın toplam işine ulaşmamışsa o hata ve sonrakiler bilinen kalır.
- Neden var (maliyet): gerçek veride bir hatanın düzeltmesi medyan 8 ile 15 dakika, 90. yüzdelik 31 ile 126 dakika (Menzies
  ve diğerleri 2017, https://arxiv.org/abs/1609.04886): ucuz ve ağır kuyruklu. Ağır payı %18 Jones'un yüksek önem oranı
  (R10 §4.3). Ortalama 2,0 puan/hata; canlıda düzeltme kartı da hata başına 2 puan (§3.12 c), Menzies'in "geç düzeltme 1,1
  ile 1,5 kat" bulgusuna uygun. Geç bulmanın asıl bedeli müşteride (A ve C), puan şişirilmez.
- Neden kartı yapanlardan değil "Geliştirme satırından": kişi kimliğini karta bağlamak kadroyu kilitler, 50 kişide hiçbir
  şey kazandırmaz; Geliştirme kuralı zaten önce geliştiriciyi seçer. Testçi düzeltmez (ikincil 0,7 ile ancak Yapım kutusu
  varsa); test darboğazını büyütmez.
- Ölçekte: düzeltme işi bulunan hatayla, bulunan hata teslimle orantılı. Sprint içi düzeltme 3 ile 50 kişide kapasitenin
  %1,5 ile %3,5'i (§4.2).

**Kaçan hata.** E = H × (1 − C) beklenen; gerçek sayı n − F. Kart yayına çıkınca kartın hattına `ProductState.add_bugs`
ile yazılır. v1.0'dan önce A'nın bekleme listesinde durur. Bu, A Karar 3'ün tek istisnasıdır ("hatalı kapanan kartın hatası
kartın kendi hattına"; `PRD_FAZ_A_HATALAR.md` §2 Karar 3). Taban (kullanım) akışı rastgele hatta düşmeye devam eder.

**Ekranda (sayı, yüzde yok).**
- Testten önce kart hata hakkında hiçbir şey yazmaz; ipucu yalnız testi kimin yapacağını yazar.
  TR: "Test: Ayşe" · EN: "Test: Ayşe". Kendi kartıysa TR: "Test: Deniz (kartı kendisi yazdı)" · EN: "Test: Deniz (wrote
  this card)".
- Test bitince kart satırı: TR "Test: 3 hata buldu, 2'si düzeltildi." · EN "Test: found 3 bugs, fixed 2."
- Hata yoksa: TR "Test: hata bulunmadı." · EN "Test: no bugs found."
- Düzeltme sürerken: TR "Düzeltiliyor: 1 hata kaldı." · EN "Fixing: 1 bug left."
- Sprint özeti (sürüm notunun başı): TR "Bu sprintte testçiler 11 hata buldu. 9'u düzeltildi, 2'si bilinen hata olarak
  kaldı." · EN "Testers found 11 bugs this sprint. 9 were fixed, 2 remain known."
- Bulunamayan hata ekrana hiç çıkmaz; yayından sonra A'nın akışıyla "açık hata" olarak görünür (bugünkü A davranışı).
- Bütün metinler TR/EN onay bekliyor; tire yok.

**v2'den kalkanlar:** kart ipucundaki "Hata ihtimali %35"; test satırındaki "Beklenen hata 2"; kapanışta Poisson(E)
çekilişi (yerine test anında kart tohumu); C_REF 0,40.

### 3.7 Gönder ya da bırak sorusu (yeni, D2)
**Ne zaman gelir.** Sprint kapanışında, testi bitmiş ama düzeltmesi bitmemiş kartlarda toplam bilinen hata
K ≥ en büyüğü (1; ⌈bu sprintte bulunan hata ÷ 3⌉) ise. Sprint başına en çok bir soru, bütün bu kartlar tek tabloda.
- **Neden eşik oranlı.** "En az 1 bilinen hata varsa sor" 50 kişide sprintlerin %86'sında soru çıkarıyor (ön hesap; R10
  §4.3'te %71 ile %94). Oran her ölçekte aynı okunur.
- **Neden üçte bir.** 3 ile 25 kişilik dengeli ekiplerde sıklığı üç sprintte birin altında tutan en sade oran (ön hesap,
  20 tohum): S2 %4, S3 %21, S4 %29, S5 %18, S6 %4, S10 %12, iki 5★ testçili 12 kişi %33. Dörtte bir S4'te %37 veriyordu.
- **Söz ve istek.** Bilinen hatalı kartlardan biri verilmiş bir sözün ya da B2B isteğinin kartıysa ve tarihi bu ya da
  sonraki sprintteyse soru eşik tutmasa da gelir: cevabın gerçek bedeli vardır (R10 §4.3 madde 5). Simülasyonda yoktur.

**Kesintilerle sıra (B Karar 12'nin uzantısı; öneri).** Bir sprintte oyuncuya en çok bir kesinti gelir. Sıra: acil durum
(servis çöktü) > söz olayı > sprint ortası kâğıdı > gönder sorusu. Önceki üçünden biri geldiyse soru sorulmaz ve
varsayılan uygulanır; tek istisna söz kartıdır: söz olayında "Testi kısalt" ya da "fazla mesai" seçildiyse söz kartı
gönderilir, "ek süre iste" ya da "söz kaçsın" seçildiyse bırakılır. Neden: oyuncunun aynı konudaki ikinci kararı
istenmez; söz olayındaki cevap zaten "tarih mi kalite mi" sorusudur. B'nin kâğıt oranı (`data/product/sprint.json:40`,
`decision.rate` 0,35) ile sorunun etkin sıklığı yaklaşık üçte ikisine iner (tahmin).

**Seçenekler ve bedelleri.**
| | Gönder | Sonraki sprinte bırak (vurgulu) |
|---|---|---|
| Kart | Teslim sayılır: kademe ve alan puanı şimdi | Teslim olmaz; sonraki planın 3. basamağına kalan düzeltme işiyle girer (§3.12 b) |
| Bilinen hata | K hata kartın hattına açık hata olarak yazılır (hatalı kapanan kart kuralı) | Kartın içinde kalır, sonraki sprintte düzeltilir; yeniden test yok (düzeltme işine dahil) |
| Sonra | Açık hata B2B'de hesabın memnuniyetine "Açık hata" satırı olarak girer (inceleme: C v3 §5.2, canlı hat başına yoğunluk × 3, en çok 60; bugünkü `b2b_sales_system.gd:147` hedefi kalkar); düzeltme kartı hata başına 2 puan; B'nin "sürüm sonrası bozulma" ihtimaline bu sürümün hatası olarak girer | Söz ya da istek kartıysa tarih kayabilir; değilse bedeli bir sprintlik gecikme |

- **Soru gelmediğinde** varsayılan "bırak" uygulanır ve sürüm notuna tek satır düşer.
- **Neden varsayılan bırak.** Scrum'da Done olmayan iş yayınlanmaz, backlog'a döner (https://scrumguides.org/scrum-guide.html;
  R10 §2.3); referans oyunların üçünde varsayılan "düzeltme sürer" (R10 §3.6). Ön hesapta bırakmanın teslime bedeli yok
  (aşağıda). Erdem C5: "amacımız oyuncuyu aşırı zorlamak değil".
- **Ön hesap: oyuncu politikası** (20 tohum; teslim puan/hafta; kaçan ve gönderilen hata, 100 teslim puanı başına):

| Ekip | Teslim: hep bırak / hep gönder | Hata / 100 puan | Açık hata medyanı | Kartın bekleme süresi (hf) | Düzeltme payı |
|---|---|---|---|---|---|
| S3 · 6 | 48,0 / 48,0 | 1,70 / 2,00 | 8,0 / 8,5 | 3,98 / 3,83 | %6,6 / %7,8 |
| S4 · 12 | 107 / 108 | 1,46 / 1,71 | 9,5 / 9,25 | 4,09 / 3,91 | %5,1 / %5,4 |
| S5 · 25 | 265,5 / 266 | 1,09 / 1,38 | 12,0 / 13,0 | 3,90 / 3,73 | %3,4 / %4,0 |
| S6 · 50 | 539 / 540 | 1,09 / 1,24 | 17,0 / 18,5 | 3,70 / 3,58 | %3,0 / %3,4 |

  Eşikli politika (soru gelince ağır hata yoksa gönder, varsa bırak) ikisinin arasında kalır (S4 1,57). Hiçbir politikada
  hata sprinti yok. Okuma: gönder kartı 0,1 ile 0,2 hafta erken çıkarır, açık hatayı en çok %14 artırır (S10; S4'te
  fark yok). Değer kartın
  zamanında olduğu yerde (söz, istek, toplantı) gerçektir; bu yüzden söz ve istek kartında soru eşiksiz gelir.
- **Metinler** (TR/EN onay bekliyor, tiresiz):
  - Soru: TR "Hesap Planı ve Stok Sayacı'nda 4 bilinen hata kaldı. Bu haliyle gönderelim mi, sonraki sprinte mi
    bırakalım?" · EN "Account Plan and Stock Counter still have 4 known bugs. Ship them as they are, or leave them for the
    next sprint?"
  - Düğmeler: TR "Gönder" / "Sonraki sprinte bırak" · EN "Ship" / "Leave for next sprint".
  - Çipler: TR "Fatura hattına 4 açık hata yazılır." · EN "4 open bugs are added to Invoicing." TR "2 kart sonraki sprintte
    8 puanlık düzeltmeyle biter." · EN "2 cards finish next sprint after 8 points of fixing."
  - Sessiz varsayılanın sürüm notu satırı: TR "Stok Sayacı düzeltmede kaldı: 1 bilinen hata, sonraki sprintte biter." ·
    EN "Stock Counter stayed in fixing: 1 known bug, finishes next sprint."
- **"Sürekli hata sprinti yok" ile ilişkisi.** Bırakılan kartın kalan işi düzeltme kartı değildir, A'nın düzeltme payına
  girmez; özellik kartının işidir. Sprint içi düzeltme ile düzeltme kartlarının toplamı ("toplam hata işi") ayrı ölçülür ve
  2 kişi ve üstünde %20'yi geçmez (ön hesap en çok %11, S2). Hep gönderen oyuncu düzeltme kartı payını en çok 1,2 puan
  artırır; düzeltme payı tavanı (§3.12 c) aynen işler.
- **Testçinin değeriyle ilişkisi.** İyi testçi daha çok bulur, bu yüzden daha sık sorulur (iki 5★ testçili 12 kişi %33);
  ama bulduğunu müşteri bulmaz. Oyuncu bunu "Test: 5 hata buldu" satırında görür.

### 3.8 Hazırlık: PM (D3)
- **Hazırlık işi** = 0,20 × S (K1 3, K2 5, K3 8 puan). Onaylı (v2). Düzeltme ve araştırma kartı hazırlanmaz.
- **Hazırlık hızı** (puan/hafta) = P(s) × verim × saat × pay × huy, s = PM'in Ürün puanı:
  P(s) = 15 + 10 × √((s − 2) ÷ 8) (s ≥ 2); s < 2 ise 7,5 × s.

  | PM | 1★ | 1,5★ | 2★ | 2,5★ | 3★ | 3,5★ | 4★ | 4,5★ | 5★ |
  |---|---|---|---|---|---|---|---|---|---|
  | Hazırlık puanı/hafta | 15 | 18,5 | 20 | 21 | 22 | 23 | 24 | 24,5 | 25 |
  | Hazırladığı kart puanı/hafta | 75 | 93 | 100 | 106 | 111 | 115 | 118 | 122 | 125 |
  | Beslediği kişi (kişi başı ~10 puan) | ~7 | ~9 | ~10 | ~11 | ~11 | ~11 | ~12 | ~12 | ~12 |

  - **Birim eşlemesi.** Erdem'in "SP"si bugünkü oyunun kart puanıdır (K1 3, K2 5, K3 8; `data/product/sprint.json`
    `effort`). "Haftada 15 SP'lik işi hazırlar" ×5 ölçekte 75 puanlık kart demektir; hazırlık işi kartın %20'si olduğu için
    bu 15 hazırlık puanıdır. İki okuma aynı sayıyı verir. Öbür okuma ("×5 ölçekte 15 puanlık kart", haftada 3 hazırlık
    puanı) 1★ PM'i bir buçuk kişiyi besler hâle getirir; v2'nin 1★'ı bile 6,4'tü ve gerçek oran 5:1 ile 11:1'dir (R4
    §2.5, Pave). Bu yüzden ilk okuma.
  - **Neden karekök eğrisi.** Erdem: "full lineer şekilde arttıramayız… insan gibi". 1★'dan 2★'a +5, 4★'dan 5★'a +1:
    deneyim başta hızlı, sonra yavaş kazandırır. Uçlar Erdem'in sayıları.
- **Hazır kartın faydası** (yıldıza bağlı, Erdem):

  | PM | 1★ | 2★ | 3★ | 4★ | 5★ |
  |---|---|---|---|---|---|
  | Hız bonusu b (iş = ihtiyaç ÷ (1 + b r)) | %10 | %15 | %20 | %25 | %30 |
  | İşte azalma (tam hazır) | %9 | %13 | %17 | %20 | %23 |
  | Hata çarpanı 1 − h r | ×0,90 | ×0,825 | ×0,75 | ×0,675 | ×0,60 |

  b = 0,10 + 0,025 × (s − 2), en az 0,05, en çok 0,30; h = 0,10 + 0,0375 × (s − 2), en az 0,05, en çok 0,40 [ÇALIŞMA].
  - Erdem "üretme hızımızı %10 arttırır" dedi; hız olarak uygulanır. 3★'da iş %17 azalır (v2'nin onaylı %20'sine yakın),
    hata ×0,75 (v2'nin onaylı değeri).
  - Neden doğrusal: bonus hazırlığın kalitesidir (belgenin ne kadar iyi yazıldığı), hız eğrisinden ayrıdır; Erdem uçları
    verdi, ara değerleri eşit aralıkla bölmek en az varsayım.
- **Yarım hazırlık** orantılı fayda alır (v2, onaylı): r = yapılan ÷ gereken.
- **Birden çok PM (yeni kural).** Hazırlık işini ekipteki PM'ler paylaşır (hızlar toplanır); hazır kartın faydası (b ve h),
  sprintte payı olan PM'lerin en yüksek Ürün yıldızlısınınkidir. Ekranda: TR "Hazır · Selin'in gözünden geçti" · EN
  "Ready · reviewed by Selin" (onay bekliyor).
  - Neden var: fayda kartı hazırlayan PM'e bağlıyken, kart arzı zaten tam hazırken bir PM daha almak teslimi düşürüyordu:
    kişi ekleme eğrisinde 37. kişi (PM) −2,5 puan/hafta, 20 tohumun çoğunda aynı yön (`c37.py`). Sebep: yeni PM kuyruğun
    ilerisindeki kartları daha düşük yıldızla hazırlıyor, o kartlar en iyi PM'e hiç gelmiyor. Kuralla −0,5.
  - Gerçek karşılığı: kıdemli PM şablonu kurar ve belgeleri gözden geçirir (tahmin; R4 §2.1'deki keşif ekibi yapısıyla
    uyumlu).
  - Ölçekte: PM sayısı kapsamı, en iyi PM'in yıldızı kaliteyi belirler; ikisi de kişi sayısından bağımsız okunur.
- **Sıra, kuyruk, PM'siz ekip, tasarımcı** (v2 aynen): sonraki sprint sütunu, sonra Çeyrek kartları, sonra PM önerisi; bir
  kartı aynı haftada tek PM hazırlar; PM'siz ekibe ceza yok (Erdem 17 Ekim); tasarımcı sprintte çalışır, boş kalınca sonraki
  sprintin tasarımına geçer.
- **PM'in boşu.** Hızlı hazırlıkla küçük ekipte PM haftanın bir kısmında hazırlayacak kart bulamaz. Plan ekranı nedenini
  yazar: TR "Selin'in hazırlayacağı kart kalmadı." · EN "Selin has no cards left to prepare." Araştırma kartı bu boşluğu
  doldurur (bugünkü kural).

### 3.9 Kurucu (D4)
- **Hız:** Y = en büyüğü (0,86; Y(s)) her aşamada; 0,86 = 2★ (puan 4). Erdem: "iki yıldız gibi çalıştıralım".
- **Görünürlük:** kurucunun dosyası gerçek yıldızlarını gösterir; plan ekranı kurucunun aşama hızını puanla yazar
  (örnek: "Kurucu · Tasarım 9/hf"). "2★ tabanı" diye bir etiket, satır ya da ipucu yoktur (Erdem: "oyuncunun görmemesi
  lazım"). Taban ekonomiyi sürer ama oyuncu sonucu sayıyla görür; ilke 3 karşılanır.
- **Kalite:** Test ve Yazılım yıldızı gerçek değeriyle okunur (v2, onaylı). Kurucu kendi geliştirdiği kartı test ederse ×0,6
  (§3.6); tek kurucu her kartı kendisi yazdığı için 0★ Test'le %24 yakalar.
- **Sprint payı:** 1 − (o haftanın toplantı saati ÷ 40). Yenileme kurucuya saat yazmaz (Erdem C5).
- **Güçlü alan:** §3.4 (yeni kural).
- **Ön hesap, tek kurucu** (ürün 4, tasarım 0, yazılım 4, test 0): MVP 6. hafta (20 tohumun 17'sinde 6, 3'ünde 7); MVP
  sonrası teslim haftada 4,5 puan (v2 6,2; taban 1,0 olsaydı 5,6: farkın büyük kısmı 2★ tabanı); düzeltme payı %29;
  hata sprinti 3/507 (geç pencere %0,6; hedef ≤ %5).
- **"Tek başımayken daha hızlıydım" kapısı.** Ölçülen yollar:
  1. Kurucu başka aşamaya kayar: uzman gelince kurucu kendi güçlü alanını bırakıp tasarım ya da teste geçer. Yalnız güçlü
     alanı olan kurucuda görülür; 5★ geliştirici kurucuya 2,5★ geliştirici alınca kurucunun kendi işi 12,4'ten 11,6'ya
     iner (%7), şirketin teslimi 9,3'ten 11,0'a çıkar. Plan ekranı kişi yük şeridinde kurucunun aşamasını, darboğaz
     cümlesinde nedenini yazar: TR "Kurucu testte: ekipte testi yapacak başka kimse yok." · EN "Founder is testing: nobody
     else on the team can test."
  2. Yavaş uzman kurucunun işini alır: kurucunun güçlü alanı kuralıyla kapandı (MVP gecikmesi 2 haftadan 0'a).
  3. Kart bölününce bekleme: aşama sırası yüzünden boşta kalan süre plan ekranında "boşta" diye görünür; tek kurucuda bile
     %17 (sprint sonu boşluğu).
  4. PM hazırlığı: kurucunun işini azaltmaz, kartı kısaltır. Tek kurucuya PM alınca kurucunun işi 7,2'den 7,0'a iner (%2,5;
     kart kısaldığı için daha az puan); teslim 4,5'ten 5,4'e çıkar.
  5. Toplantı: işe alımla ilgisi yok; payı düşürür ve plan ekranında hafta satırında yazar.
  6. Sprint içi düzeltme: hata bulan testçi gelince kurucu düzeltme işi yapar; teslimi düşürmez (§4.7).
  - Sonuç (§4.7): altı alım sırası ve üç kurucu tipinde şirketin teslimi her adımda artar, MVP hiçbir alımla gecikmez,
    kurucunun kendi işi en çok %7 düşer ve düştüğü her durumda plan ekranı nedenini yazar. Ek kural gerekmedi.
  - (inceleme) Simülasyon dört kurucu tipi ve altı sırayla (72 adım) ölçtü: şirket teslimi 72 adımın hepsinde arttı, MVP
    gecikmedi; kurucunun kendi işi en çok %10,1 düştü (5★ kurucu, üç geliştirici: 12,4 → 11,1). %2'den büyük 16 düşüşün
    7'sinde aşama değişti, 8'inde kurucu aynı aşamada işi yeni gelenle paylaştı, 1'inde kart hazırlıkla küçüldü
    (`D_SIM_v3.md` §6.1, §8.1). Plan ekranı kurucunun satırına aşama payını yazar ve düşüşün nedenini üç cümleden biriyle
    söyler (TR/EN onay bekliyor): TR "Kurucu testte: ekipte testi yapacak başka kimse yok." · EN "Founder is testing:
    nobody else on the team can test."; TR "Kurucu Geliştirme'yi Mert ile paylaşıyor." · EN "Founder shares Development
    with Mert."; TR "Kartlar hazır geldi: aynı iş daha az puan tuttu." · EN "Cards came prepared: the same work took fewer
    points." Kapı 2'nin eşiği %12 olur (§6.12) [ÇALIŞMA].

### 3.10 Plan ekranı (D6, onaylı; içerik güncellendi)
- **Yerleşim** (onaylı): aşama şeridi ve darboğaz cümlesi her zaman; kart zinciri kartın üstüne gelince; kişi yükü avatar
  satırında. Gösterim oyunun kendi arayüz diliyle (Menajer, `docs/mockups/menajer/`); Claude Design maketi yok.
- **Aşama şeridi** (v2 Yön A): TASARIM / GELİŞTİRME / TEST satırları "iş · ekip"; Geliştirme satırının işi sprint içi
  düzeltme dahil hesaplanır, ayrı yazılmaz (bulunacak hata sayısını ele vermemek için; §3.11).
- **Darboğaz cümlesi** (v2 Yön B): aşama yükünün o aşamanın kapasitesine oranıyla seçilir (v2 inceleme kuralı). Cümle
  gözlem yazar, öneri yazmaz. Bu turun eklediği nedenler (TR/EN onay bekliyor):
  - Arz: TR "Planlanacak kart kalmadı: 6 kişi bu sprint boşta." · EN "No cards left to plan: 6 people are idle this sprint."
  - Aşama dolu: TR "Test satırı dolu. Yeni kart sonraki sprinte kalır." · EN "The Test row is full. New cards wait for the
    next sprint."
  - Rol uymuyor: TR "Mert boşta: geliştirmeye açık kart yok." · EN "Mert is idle: no card is open for development."
- **Kart üstünde ve ipucunda:** "Tasarım 2 · Geliştirme 10 · Test 7", kim çalışıyor, Hazır etiketi ve hazırlayan PM, testi
  kimin yapacağı. Yüzde yok. Test bitince §3.6'nın satırları.
- **Kart zinciri:** [Tas][Gel][Test] parçaları; test bitip hata bulunduysa [Düz] parçası o an eklenir. Testten önce zincir
  düzeltmeyi test parçasının içinde gösterir.
- **Kişi yükü:** avatar başına aşama ve boşta süresi; 50 kişide aşama başına özet (v2 Yön D).
- Ekranda ondalık yok: yapılan aşağı, kalan yukarı yuvarlanır.

### 3.11 Tahmin = sonuç
- Plan ekranı, "+" düğmesi, öneri, MVP tahmini ve kapanış aynı oynatma fonksiyonunu koşar (v2).
- **Sprint başında sabitlenenler:** kişilerin aşama hızları, kartların hazırlık oranı ve faydası, ihtiyaç, kadro, test
  ihtiyacı.
- **Yeni:** hata sayısı ve bulunanlar kart tohumuyla test anında belirlenir. Plan oynatması da aynı tohumu kullandığı için
  aynı n, F ve düzeltme işini bulur; tahmin bulunan hata dahil sonuçla aynıdır (ön hesapta en büyük fark 3,6e-15). Plan
  ekranı bu sayıyı **göstermez**; sayı test bittiği an kart satırında ortaya çıkar. v2'nin "çekiliş karşılaştırılmaz"
  istisnası kalkar.
- Kartın tohumu kart kimliğine bağlıdır; oyuncu planı değiştirirse (başka geliştirici, hazırlık) H değişir ve n buna göre
  değişir (ters dağılım, aynı tohum: daha çok yük, daha çok ya da aynı hata).
- Adlı uyuşmazlık nedenleri (v2 aynen): B'nin kararları, işe alım ya da ayrılık, izin ve eğitim, kurucu toplantısı. Gönder
  sorusu kapanıştadır, tahmini bozmaz.
- Probun PRED ve CLOSE satırlarına kart başına n, F, K ve düzeltme işi eklenir.

### 3.12 Sprint alımı ve öneri
**(a) Kart sayısı kural değil sonuç** (`SPRINT_DUZENI.md` K2). Sprint kartı şu üç şart tuttukça alır: toplam iş ≤ 1,25 ×
kapasite; her aşama satırında kalan iş ≤ 2 × o aşamanın kapasitesi (v2 §3.11 a; Düzeltme Geliştirme satırında sayılır);
yeni kart bu sprintte iş almalı. Sabit kart yuvası yok.
- Neden var: sabit yuva ölçekte ya boş kalır ya taşar. Ön hesapta sprintteki kart ekip büyüklüğüne yakınsıyor (12 kişi
  13; 50 kişi 55).

**(b) Tek öneri, aynı kural** (`SPRINT_DUZENI.md` K3). Öneri planın alım kuralıyla tavana kadar doldurur. Zorunlu sıra:
(1) verilmiş sözlerin kartları, son tarihi yakın önde; (2) son tarihi bu ya da sonraki sprint olan bütün talepler;
(3) bırakılan kartlar (§3.7) ve önceki sprintten devreden kartlar; (4) Öncelikli düzeltmeler, düzeltme payı tavanına kadar;
(5) en zayıf alanın en iyi kartı; (6) etki ÷ iş sırasıyla kalanlar. Bot öneriyi uygular, ek kuralı olmaz.
- (inceleme) **Uymayan aday atlanır.** Sıradaki aday (a) şartlarından birine takılırsa öneri durmaz; onu atlar ve sıradaki en
  çok 12 adaya bakar. Neden: "tutmazsa durulur" (§6.5 adım 4) ile "tavana kadar doldurur" çelişiyordu; 40 puanlık bir K3
  arkasındaki 15 puanlık kartları da eliyordu. Ölçüm: öneri doluluğu %77 ile %95'ten %97 ile %100'e çıkar, 3 kişide 1
  haftalık sprintte teslim +%26 (`D_SIM_v3.md` §8.4). Bedeli: 3 kişide düzeltme payı %10'dan %17'ye çıkar, A'nın sınırı
  içinde. Atlanan kartın yeri sırada kalır; atlama sabit sayı değil arama sınırıdır.
- Neden var: bugünkü öneri yalnız bu sprintte bitecek kartları ve en çok bir devreden kartı alıyor
  (`sprint_catalog.gd:820-862`); D'de kart ortalama iki sprint sürer (ön hesap 3,7 ile 4,1 hafta). "En çok bir talep"
  (`sprint_catalog.gd:836`) 330 hesapta tarihi geçen talep üretir. Bot ile oyuncunun kuralı aynı olmalı ki ölçtüğümüz oyun
  oynanan oyun olsun (`run_probe.gd:915-946`).
- Planlama eylemi: öneriyi uygula, istersen değiştir, başlat. 1 kişide de 50 kişide de 2 ya da 3 eylem.

**(c) Düzeltme kartı.** Kartın büyüklüğü = en büyüğü (5; 2 × hattın açık hatası) puan; pay 0 / 0,7 / 0,3 [ÇALIŞMA].
- (inceleme) **Alt sınır 5 kalkar: büyüklük = 2 × hattın açık hatası.** Neden: 1 haftalık sprintte tek kurucunun kapasitesi
  8,6 puandır; 2 hatalı hattın 5 puanlık kartı kapasitenin %58'i olur ve "ilk kart her zaman girer" kuralıyla sprintlerin
  %50'si hata sprintine döner (401/800; 2 haftalık sprintte 4/569). Planın kendiliğinden açtığı kart zaten en az 2 hatada
  açıldığı için oran tek başına yeter (en küçük kart 4 puan). Ölçüm (`D_SIM_v3.md` §8.6, `D3_FIXMIN=2.5` aynı kuraldır):
  tek kurucu 1 hf hata sprinti %50 → %6,6, düzeltme payı %43,6 → %34,9; 3 ve 6 kişide teslim +%9 ve +%2. Kalan %6,6
  tek kurucu ve 1 haftalık sprinte özgüdür, A'nın %5 hedefinin biraz üstündedir (Erdem'e soru). Aşağıdaki "A'nın bugünkü
  değerleri" karşılaştırması eski kural içindir.
- Neden var: v2'de en çok 10 puandı; büyük ekipte hatanın bedelini neredeyse sıfırlıyordu (v2 inceleme 10). 2 puan/hata,
  sprint içi düzeltmenin ortalaması (2,0) ile aynı: canlıda bulmanın puan bedeli şişirilmez, bedeli müşteridedir (§3.6).
- A'nın bugünkü değerleriyle (1 ile 4 hata 5 puan, 5 ve üstü 10 puan, ×5 ölçek; `sprint.json:7`) 1, 2 ve 5 hatada aynı,
  3 hatada 6, 4 hatada 8, 10 hatada 20.
- **Düzeltme payı tavanı** (v2 §3.11 b aynen): planın kendiliğinden aldığı düzeltme kartı işi kapasitenin yarısını aşmaz;
  sprintte henüz düzeltme kartı yoksa ilk kart her zaman girer. Öncelikli eşiği (hatta 5 hata) değişmez.
- Ön hesap: düzeltme payı (geç) S1 %29, S2 %9,5, S3 %6,6, S4 %5,1, S5 %3,4, S6 %3,0; hata sprinti ≥ 2 kişide 0.

### 3.13 Arz (`SPRINT_DUZENI.md` K7, K8)
**Hedef (oyun kuralı değil, içeriğin tutması gereken hedef):** plan anında açık aday kart ≥ 0,75 × ekip (8 kişinin
altında ≥ ekip). Ölçüm: 2 haftalık sprintte boşta payını %8'in altında tutan en küçük havuz (`SPRINT_DUZENI.md` §4.2).

**Dört kaynak:**
| Kaynak | Kural | Neden var | Ölçekte |
|---|---|---|---|
| A. Kademe (bugünkü) | Hat başına K1 → K2 → K3, zincirli | "Temel olmadan ileri özellik olmaz" bağımlılığı gerçek | Hat sayısıyla sınırlı; ilk 6 kişiye yeter |
| B. Derinlik kartı (yeni) | K3'ü biten hatta aynı anda açık derinlik kartı = 1 + ⌊hattı kullanan hesap ÷ 5⌋, en çok 8 (inceleme; v3 taslağı ÷ 10, en çok 4) (B2C: 1 + ⌊hattın kullanıcısı ÷ 2 500⌋, en çok 8, aynı oranla, ölçülmedi) [ÇALIŞMA]; boyut 15 / 25 / 40 sırayla döner; profil hattın profili | Gerçek üründe alan bitmez, iyileştirme işi birbirinden bağımsızdır | Kullanımla büyür, ekiple değil |
| C. Hesap isteği (değişen) | B2B'de istek, hesabın hattında açık kademe yoksa hesabın kendi kartı olur; boyut koltukla: 20'den az K1 15, 20 ile 99 K2 25, 100 ve üstü K3 40 [ÇALIŞMA]; hesap başına yılda bir | İş müşteri sayısıyla doğar | Hesap sayısıyla doğrusal |
| D. Modül (EA) | Yeni hat grubu (E'nin modülleri, ikinci ürün) | Büyük ekip geniş yüzey yapar | Hat sayısını büyütür |

- **Derinlik kartının kazancı** alanın puanına (Q1: ürünün tek kalitesi alanlardır) yazılır ve azalır: aynı alanda
  beklentinin üstünde biten k'inci derinlik kartının kazancı ilkinin 0,75^(k−1) katı (5. kart ilkinin 0,32'si) [ÇALIŞMA].
  Alan puanının ölçeği C ve X'in; D yalnız çarpanı verir. Kartın etki satırı azalan kazancı sayıyla yazar.
- Karşılanmayan hesap isteği düşer, memnuniyeti düşürmez (C6: "durup dururken düşmez"); söz verilmişse sözün kuralı işler.
- Kart adı işin kendisidir: TR "Toplu fatura: ikinci para birimi" · EN "Bulk invoicing: second currency".
- Bakım ya da teknik borç kartı önerilmez (reddedilen "sürekli hata sprinti"ne yakın).
- **Düzeltme:** v2'nin "50 kişilik ekip 60 haftada bugünkü kataloğu tüketir" cümlesi (`D_MODEL_v2.md:772`) yanlıştır;
  9 hatlı katalog 50 kişide 7, 25 kişide 9, 12 kişide 12 haftada biter (kapısız; v3 modeliyle `D_SIM_v3.md` §6.4;
  `SPRINT_DUZENI.md` §4.1'in v2 modeliyle 11'i, inceleme).
- (inceleme) **Neden ÷ 5 ve en çok 8.** Eski sınır (4 × 9 hat = 36) 50 kişinin hedefinin (37,5) altındaydı; arz kapısı 25
  kişide %80, 50 kişide %0 kaldı. ÷ 5 ve 8 ile 25 kişi %100 (teslim 217 → 246, boşta %15 → %8), 330 hesaplı 50 kişi %100
  (386 → 475, boşta %23 → %12), büyüme eğrisi değişmez (`D_SIM_v3.md` §8.3). Üst sınır kalktığında 330 hesapta 25 kişinin
  teslimi düştü (derinlik kartı isteğin yerini aldı); 8 bu yüzden durur. 0. haftadan 50 kişiyle başlayıp haftada 3 hesap
  alan şirket yine %65'te kalır; bu gerçek bir oyun durumu değil (ekip hesaplarla birlikte büyür).

### 3.14 Takım (EA; `SPRINT_DUZENI.md` K10)
- 10 kişiye kadar tek ekip, tek sütun; demoda takım yok. EA'da oyuncu isterse takım kurar: lider, kişiler, sahiplendiği
  alanlar. Takımsız kişi bugünkü gibi her karta gider.
- Takımdaki kişi yalnız takımının alanlarındaki kartlarda çalışır; takımın önerisini lider verir, oyuncu takım başına bir
  onay verir. Ritim, kapanış ve sürüm notu tektir.
- **Takım çarpanı** (takımdaki herkesin hızına) = lider çarpanı × (1 − büyüklük kaybı) [ÇALIŞMA]:
  - lider çarpanı = `HRConstants.coordination_for_lead(liderlik)`: Liderlik 0'da 0,85, tavanda 1,20
    (`hr_constants.gd:1011-1012`, `:1041`; bugün okuyucusu yok);
  - büyüklük kaybı = 0,02 × en büyüğü (0; takımdaki kişi − 8), en çok 0,20.
  - Takımsız kişinin çarpanı 1'dir (şirket çapında kayıp yok).
- Neden var: Erdem D1 "ekip büyüdükçe bir verim kaybı… her ekip bazında bir lider". Kayıp takımın içinde ve takımın
  büyüklüğüne oranlı; iyi lider 10 kişilik takımı takımsızdan hızlı yapar (Liderlik 6: 1,06 × 0,96 = 1,02), 15 kişilik
  takımı yavaşlatır (1,06 × 0,86 = 0,91). Oyuncu bedeli ve kazancı takım satırında görür: TR "Çekirdek takımı · lider Ayşe
  · 8 kişi · 6 kart · hız ×1,06" · EN "Core team · lead Ayşe · 8 people · 6 cards · speed ×1.06".
- (inceleme) **Kayıp yalnız 8. kişiden sonra gelenlerin hızına uygulanır** (marjinal kayıp): takımın 9. ve sonraki kişisi
  kendi hızının 0,02 × (sırası − 8) kadarını kaybeder, en çok 0,20; ilk sekiz kişi kayıp taşımaz. Neden: kayıp bütün takıma
  uygulanınca darboğaz olmayan bir kişi hiçbir şey eklemeden herkesi %2 yavaşlatıyordu; 7 takımda testçi eklemek teslimi
  2,9 puan düşürdü (kapı −1). Marjinal kayıpla en kötü −0,8; 3 takım 305 → 333 (`D_SIM_v3.md` §8.5).
- (inceleme) **Takım satırı boşta kişiyi de yazar.** Takımlı düzen takımsızdan geride kalır (50 kişi: 3 takım takımsızın
  %81'i, 7 takım %61'i); farkın %92 ile %100'ü hız çarpanı ve takıma bağlı arzdan doğan boşluktur. Oyuncu ikisini de
  görmeli: TR "Çekirdek takımı · lider Ayşe · 12 kişi · 6 kart · hız ×1,06 · boşta 2 kişi" · EN "Core team · lead Ayşe ·
  12 people · 6 cards · speed ×1.06 · 2 idle". Takımın kazancı planlama yüküdür (26 eylem yerine 2 ile 7); benzetim onu
  ölçmez.
- Kişi takım dışına geçmez: geçebilseydi takım yalnız etiket olurdu (`SPRINT_DUZENI.md` K10, soru 3 orada açık).
- Bir alanı iki takım paylaşabilir mi: öneri hayır (alan sahipliği tek); B2B'de 4, B2C'de 5 alan var
  (`sprint.json` `areas`), 7 takım için EA modülleri yeni alan getirir.

---

## 4. Ölçek güvencesi ve ön hesap
Kaynak: `dmodel3/rep_main.txt`, `rep_pol.txt` (20 tohum, 21 ile 60. hafta medyanı). Teslim = biten özellik kartlarının
hazırlıksız büyüklüğü, puan/hafta.

### 4.1 Her sabit neden ölçekte kırılmıyor
| Sabit | Değer | Neye bağlı | Neden kırılmaz | Oyuncu nerede görür |
|---|---|---|---|---|
| Puan tabanı ve yıldız eğrisi | 10; Y(s) | Kişi | Toplam kişiyle doğrusal | Avatar ipucu, aşama hızı |
| Uyum | 1,0 / 0,7 / 0,4 (en az 0,3) | Kişi × aşama | Kişiye ait | Kartta "TEST ×0,4" |
| Kadro | 8 puan | Aşamanın işi | Tavan iş büyüklüğünde | Kart ipucu "en çok 2 kişi" |
| Hata yükü | 0,04 / puan | Teslim edilen iş | Hata işle büyür, düzeltme kartı hatayla büyür, pay sabit kalır | Bulunan hata, açık hata |
| Yakalama | 0,57 × √Y; kendi kartı ×0,6 | Testi yapan | Kart başına, kişi sayısıyla birikmez; en çok %81 | "Test: N hata buldu" |
| Sprint içi düzeltme | 1,3 / 5,3 puan; ağır %18 | Bulunan hata | Bulunanla orantılı (%1,5 ile %3,5) | "M'si düzeltildi", Düzeltme parçası |
| Gönder sorusu eşiği | bulunanın üçte biri, en az 1 | O sprintin bulduğu | Oran; 3 ile 25 kişide en çok üç sprintte bir | Kapanış sorusu |
| Hazırlık | %20; 15 ile 25 puan/hafta | Kart, PM | PM oranı kendiliğinden çıkar | "Hazır" etiketi |
| Hazır faydası | %10 ile %30 hız; ×0,90 ile ×0,60 hata | En iyi PM'in yıldızı | PM eklemek faydayı düşürmez | Kart ipucu |
| Kurucu tabanı | Y ≥ 0,86 | Tek kişi | Kurucunun payı ekiple küçülür | Aşama hızı (etiketsiz) |
| Düzeltme kartı | 2 puan/hata (inceleme: alt sınır yok) | Hattın hatası | Hata ekiple büyürken bedeli de büyür; küçük kapasitede kart sprinti yutmaz | Kartın puanı |
| Aşama tavanı, düzeltme payı tavanı | 2 × aşama kapasitesi; kapasitenin yarısı | Ekibin kendi oranı | Oran | Darboğaz cümlesi |
| A'nın sınırları (D5) | × k, k = en büyüğü (1; hat ÷ 9; √(teslim ÷ 55)) | Ürün ve teslim | Hiç düzeltmeyen her ölçekte 14 ile 23 haftada varır | Destek kartı ipucu |
| Takım (EA) | lider 0,85 ile 1,20; 9. kişiden itibaren yalnız o kişinin hızına sırası başına %2, en çok %20 (inceleme) | Takım | Takım başına; takımsıza dokunmaz; kişi eklemek ötekileri yavaşlatmaz | Takım satırı (hız ve boşta) |

### 4.2 1, 3, 6, 12, 25 ve 50 kişide (v3; parantezde v2, `D_SIM.md` §3)
| Ekip | Teslim | Kişi başı | Kart / sprint | Kaçan / kart | Açık hata (medyan) | Düzeltme payı (geç) | Hata sprinti | MVP hf | Bulunan / sprint | Bilinen / sprint | Sprint içi düzeltme |
|---|---|---|---|---|---|---|---|---|---|---|---|
| S1 · 1 | 4,5 (6,2) | 4,5 | 0,37 | 0,78 (0,53) | 6,75 (6,0) | %29 (%25) | 3/507 | 6 | 0,08 | 0,00 | %0,6 |
| S2 · 3 | 19,6 (22,5) | 6,5 | 1,08 | 1,09 (0,78) | 8 (8) | %9,5 (%8) | 0 | 4 | 0,4 | 0,05 | %1,5 |
| S3 · 6 | 48 (55) | 8,0 | 2,4 | 0,68 (0,57) | 8 (8) | %6,6 (%5) | 0 | 4 | 1,4 | 0,28 | %2,7 |
| S4 · 12 | 107 (116) | 8,9 | 5,35 | 0,58 (0,57) | 9,5 (9,2) | %5,1 (%5) | 0 | 2 | 3,2 | 0,70 | %3,3 |
| S5 · 25 | 265,5 (256) | 10,6 | 13,3 | 0,44 (0,57) | 12 (13) | %3,4 (%4) | 0 | 2 | 8,3 | 1,4 | %3,5 |
| S6 · 50 | 539 (496,5) | 10,8 | 27,0 | 0,44 (0,57) | 17 (19) | %3,0 (%3) | 0 | 2 | 16,4 | 2,1 | %3,5 |

- **Küçük ekipte düşüş, büyükte artış.** 1 ile 12 kişide teslim v2'den %8 ile %27 düşük: 2★ kurucu tabanı (tek kurucuda
  5,6'dan 4,5'e), 3★ PM'in iş azaltması %20 değil %17, sprint içi düzeltme %1,5 ile %3,5. 25 ve 50 kişide %4 ile %9
  yüksek: hazırlık hızı arttı (hazır kart %64'ten %100'e), fayda en iyi PM'den.
- Kişi başı teslim S5'te S3'ün %133'ü, S6'da %135'i (kapı %70 ile %150; v2 %112 ve %108). Oran artmış ama kapı içinde;
  sebep küçük ekipte kurucu tabanı, büyükte hazırlık.
- Kaçan hata / kart 3 kişide 1,09: S2'de testçi yok, testi kurucu ve kendi kartını test eden geliştirici yapıyor. Testçi
  almanın değeri buradan başlar (§4.5).
- Toplam hata işi (düzeltme kartı + sprint içi) en çok %11 (S2); tek kurucuda %30.
- 25 ve 50 kişinin sonuçları sınırsız kart akışına dayanır; gerçek arzla sim ajanı yeniden ölçer (§3.13, §6.10).

### 4.3 Uç bileşimler (v3; parantezde v2 teslimi)
| Senaryo | Teslim | Boşta (kişi-hafta / hafta) | Kaçan / kart | Okunuş |
|---|---|---|---|---|
| S7 · küçük kartlara 5 testçi (8 kişi) | 22,1 (25,6) | 5,5 | 0,48 | Aynı ekip tek testçiyle 19,8 ve 0,68: dört testçi az teslim, belirgin kalite getirir; çoğu boşta |
| S8 · aynı rolde 10 geliştirici | 17,0 (18,8) | 9,1 | 0,78 | Tasarımı ve testi yalnız kurucu yapıyor |
| S8, 10 geliştiricide Test kutusu | 31,0 (37,0) | 7,5 | 0,84 | Test açılır; kendi kartını test edenler az yakalar |
| S9a · hepsi testçi, yalnız Test | 7,9 (11,2) | 7,8 | 0,32 | Yapımı yalnız kurucu yapıyor |
| S9b · hepsi testçi, Yapım ve Test | 19,6 (22,6) | 6,5 | 0,76 | Testçi ikincil hızla geliştirir, kendi kartını test eder |
| S10 · PM'siz 30 kişi | 283 (306) | 1,5 | 0,60 | Çökmez; bedeli hatada ve hızda |
| S11 · testçisiz 25 kişi, kutu yok | 36 (41) | 21,5 | 0,70 | "Testleri yetişmez" senaryosu; darboğaz Test |
| S11b · aynı, geliştiricilerde Test kutusu | 162 (160,5) | 8,6 | 0,56 | Test açılır |
| S12 · tek karta 12 kişi | 11,5 (11,8) | 10,8 | 0,31 | Kadro dolu, öbürleri boşta |

Hiçbirinde model çökmüyor; kırık bileşim boşta kişi ve darboğaz cümlesi olarak görünüyor.

### 4.4 Kişi eklemenin marjinal getirisi (puan/hafta)
| Taban | +3★ geliştirici | +3★ testçi | +3★ tasarımcı | +3★ PM | +1★ geliştirici |
|---|---|---|---|---|---|
| S2 · 3 (19,6) | +7,6 | +7,3 | +0,5 | +4,3 | +5,3 |
| S3 · 6 (48) | +17,0 | +6,0 | −1,0 | 0 | +10,0 |
| S4 · 12 (107) | +11,5 | +6,0 | 0 | 0 | +9,0 |
| S5 · 25 (265,5) | +16,5 | +6,0 | +1,0 | +1,5 | +11,5 |
| S6 · 50 (539) | +5,0 | +6,0 | +15,0 | +0,5 | +3,5 |

- En kötü hücre −1,0 (S3'e tasarımcı; tolerans sınırı, v2'de S4'te aynı aile). Kişi ekleme eğrisinin (1 ile 50 kişi, 49
  adım, 10 tohum) en kötü adımı −1,0 (37. kişi, PM; en iyi PM kuralı öncesinde −2,5 ve −3,0).
- Testçi her ölçekte +6 ile +7 getirir ve kaçan hatayı düşürür (S3 0,68 → 0,54, S4 0,58 → 0,52).

### 4.5 Testçinin değeri (yeni ölçüt)
**Yıldız: aynı ekip, bütün testçiler 1★, 3★, 5★.**
| Ekip | Teslim 1★ / 3★ / 5★ | Kaçan / 100 teslim puanı | Bulunan / sprint | Açık hata (medyan) |
|---|---|---|---|---|
| 6 kişi, 1 testçi (S3) | 45 / 49 / 50 | 2,05 / 1,48 / 0,88 | 0,95 / 1,6 / 2,5 | 8,0 / 8,5 / 7,25 |
| 12 kişi, 2 testçi | 92 / 108 / 114 | 1,60 / 1,33 / 0,63 | 2,4 / 3,8 / 5,5 | 9,0 / 9,0 / 8,0 |
| 25 kişi, 5 testçi | 189 / 267,5 / 275 | 1,45 / 1,08 / 0,53 | 4,4 / 8,4 / 11,7 | 11,5 / 12,0 / 9,5 |

**Testçi mi, Test kutulu geliştirici mi (aynı kişi sayısı).**
| Ekip | Teslim: testçisiz / 3★ testçi | Kaçan / 100 puan |
|---|---|---|
| 6 kişi | 45 / 49 (+%9) | 2,30 / 1,48 (−%36) |
| 12 kişi | 99 / 108 (+%9) | 1,80 / 1,33 (−%26) |
| 25 kişi | 234 / 267,5 (+%14) | 1,44 / 1,08 (−%25) |

- v2'de testçi yıldızı teslimi ve açık hatayı değiştirmiyordu, testçinin ek değeri %2 ile %10'du ve kalite aynıydı
  (`D_SIM.md` §13 g3, g6). v3'te iki kaynak: bağımsız göz (×0,6 kuralı) ve sprint içi düzeltmenin ucuzluğu.
- Açık hata az değişir (%9 ile %17): açık hatanın yarısından fazlası kullanım tabanından gelir ve düzeltme kartı hattı
  2 hatada temizler. Testçinin müşteriye etkisi C'nin memnuniyet modelinden geçer (inceleme: C v3 §5.2'nin "Açık hata"
  satırı, canlı hat başına yoğunluk; hedef ve kayma kalkıyor).
- Ölçüt (§6.12): 1★ → 5★ kaçan / 100 puan en az %40 düşer ve bulunan en az 2 katına çıkar; testçisiz yerine 3★ testçi
  teslimi düşürmez, kaçanı en az %20 azaltır.

### 4.6 PM'in yıldızı ve kaç kişiyi beslediği
| Ekip, tek PM | Teslim 1★ / 3★ / 5★ | Kaçan / kart | Hazır kart | PM'siz teslim |
|---|---|---|---|---|
| 6 kişi (S3) | 42,5 / 48 / 52 | 0,88 / 0,68 / 0,50 | %100 | 39 (kaçan 0,86) |
| 11 kişi | 95 / 107 / 117 | 0,67 / 0,58 / 0,45 | %78 / %100 / %100 | 89 (0,77) |
| 23 kişi | 217 / 229 / 241 | 0,60 / 0,58 / 0,48 | %34 / %47 / %51 | |

- 1★ PM bile PM'siz ekibi %7 ile %9 hızlandırır; 1★'dan 5★'a +%11 ile +%23, kaçan hata −%20 ile −%43.
- 23 kişide hazır kart oranı tablonun "beslediği kişi" sütunuyla tutarlı (75 / 110 / 125 puan, ekibin ihtiyacı ~230).
- Gerçek oran 5:1 ile 11:1 (R4 §2.5); 1★ 7, 5★ 12 kişi bu aralığın içinde.
- (inceleme) 23 kişide tek PM ekibin ancak yarısını hazırlar (hazır kart %34 ile %51); bu yüzden 1★ → 5★ farkı kaçan
  hatada −%20'de kalır. Kapı 11 tek PM'i besleyebildiği ekiple sınar; besleyen PM sayısıyla (25 kişi 3 PM, 24 kişi 2 PM)
  teslim +%21 ile +%22, kaçan / kart −%33 ile −%34 (`D_SIM_v3.md` §8.2). Model değişmez.

### 4.7 Kurucu: tek → +1 → +2 → +3
Şirketin teslimi / kurucunun kendi işi (puan/hafta) / MVP haftası. Alınan kişiler 2,5★ (1★ satırı ayrıca).
| Kurucu, alım sırası | Tek | +1 | +2 | +3 |
|---|---|---|---|---|
| Orta (ürün 4, yazılım 4), geliştirici → tasarımcı → testçi | 4,5 / 7,2 / 6 | 9,4 / 8,1 / 6 | 17,8 / 8,6 / 4 | 24,9 / 8,6 / 4 |
| Orta, testçi → geliştirici → tasarımcı | 4,5 / 7,2 / 6 | 7,3 / 8,0 / 6 | 13,6 / 8,3 / 4 | 24,9 / 8,6 / 4 |
| Orta, PM → geliştirici → tasarımcı | 4,5 / 7,2 / 6 | 5,4 / 7,0 / 6 | 10,6 / 8,3 / 4 | 21,5 / 8,6 / 4 |
| Orta, 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 4,5 / 7,2 / 6 | 7,5 / 7,2 / 6 | 13,6 / 8,6 / 4 | 17,8 / 8,5 / 4 |
| Güçlü (yazılım 4★), geliştirici → tasarımcı → testçi | 7,5 / 10,5 / 4 | 10,4 / 10,7 / 4 | 20,1 / 10,5 / 4 | 31,3 / 13,5 / 2 |
| Güçlü (yazılım 5★), aynı sıra | 9,3 / 12,4 / 4 | 11,0 / 11,6 / 4 | 21,5 / 11,4 / 4 | 35,0 / 16,1 / 2 |

- Şirketin teslimi her adımda artar; MVP hiçbir alımla gecikmez (kurucunun güçlü alanı kuralıyla; kuralsız güçlü kurucuya 1★
  geliştirici MVP'yi 4'ten 6'ya itiyordu).
- Kurucunun kendi işi yalnız güçlü kurucuda ve en çok %7 düşer; neden §3.9 madde 1. (inceleme) Dört kurucu tipi ve altı sırayla en çok %10,1 (5★ kurucu, üç geliştirici); nedenleri §3.9 sonundaki üç cümle.
- Tek kurucunun kendi işi (7,2) ekiptekinden (8,6) düşüktür: sprint sonu boşluğu tek kurucuda %17. "Tek başımayken daha
  hızlıydım" duygusunun tersine, kurucu ekip gelince daha dolu çalışır.

### 4.8 Gönder sorusunun sıklığı (bulunanın üçte biri, en az 1)
| Ekip | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S10 | S11b | 12 kişi, iki 5★ testçi |
|---|---|---|---|---|---|---|---|---|---|---|
| Sprintlerin | %1 | %4 | %21 | %29 | %18 | %4 | %16 | %12 | %8 | %33 |

- Soru gelen sprintte tipik tablo: 6 kişide 1 kart, 2 ile 3 bulunan, 1 ile 2 bilinen; 50 kişide 4 kart, 16 bulunan,
  6 bilinen.
- Tek kurucu neredeyse hiç sorulmaz: kendi kartını kendisi test ettiği için az bulur. Testçi alınca soru gelmeye başlar
  (kurucu + testçi %10).

### 4.9 D5: A'nın sınırları oranlı
- **Kural.** k = en büyüğü (1; canlı hat ÷ 9; √(son 8 haftanın haftalık teslimi ÷ 55)) [ÇALIŞMA]. A'nın mutlak sayıları k ile
  çarpılır: itibar eşiği (`support_system.gd:86`, `NEGLECT_BUGS` 30) ve ölçüm hedefleri (sürüm anında açık hata ≤ 8, sprint
  sonu tepesi ≤ 16, haftada yeni hata ≤ 4). Öncelikli eşiği (hat başına 5) zaten hat başınadır, değişmez.
- 55: 6 kişilik dengeli ekibin teslimi; A'nın hedefleri 1 ile 6 kişilik bot için doğruydu (v2 §5 A). 9: bugünkü hat sayısı.
- **Neden karekök.** Düzenli düzelten ekipte açık hata teslimle karekök gibi büyüyor (6 kişi 8, 50 kişi 17; teslim 11 kat),
  çünkü düzeltme kartı hattı toptan temizliyor. Hiç düzeltmeyen ekipte yığılma teslimle doğrusal. Karekök ikisini her
  ölçekte ayırıyor (`nofix.py`, 10 tohum, 80 hafta):

| Ekip | k ile eşik | Hiç düzeltmeyen eşiğe varır (MVP'den sonra hafta) | Düzenli düzelten tepe | Mutlak 30'da hiç düzeltmeyen |
|---|---|---|---|---|
| S1 | 30 | 22,5 | 11,5 | 22,5 |
| S2 | 30 | 17 | 13 | 17 |
| S3 | 30 | 14 | 14 | 14 |
| S4 | 43 | 18 | 16 | 12 |
| S5 | 67 | 16 | 18,5 | 8 |
| S6 | 94 | 14 | 25,5 | 4 |

- Doğrusal oran (teslim ÷ 110) 50 kişide 22 haftaya uzatıyor; karekök her ölçekte 14 ile 23 hafta (yaklaşık 4 ile 5 ay).
- Ekranda: eşik Destek kartı ipucunda sayıyla yazar (A K6), oyuncu formülü görmez, sayıyı görür.

---

## 5. Bağlar
### A · hatalar (koda girdi)
- **Tek depo.** Kaçan ve gönderilen bilinen hata `ProductState.add_bugs(kartın hattı, n)` ile yazılır; v1.0'dan önce
  `pending_faulty`'de bekler. Kartın `faulty` bayrağı ve `faulty_chance` (0,4) silinir (v2 aynen).
- **Yeni kod terimi** (`SupportSystem.reports_per_day`'in `INFLOW_NEWCODE_COEF` terimi) silinir; taban kalır (v2 aynen).
- **Düzeltme kartı:** büyüklük 2 puan/hata, alt sınırsız (§3.12 c, inceleme); A'nın `fix_effort` kademeleri (`sprint.json:7`) kalkar,
  yerine tek oran. Kartın kendi kaçışı A'nın hattı sıfırlamasından sonra yazılır (bugünkü sıra). A'nın sabiti, onay bekliyor.
- **Sürekli hata sprinti yok:** A'nın tanımı (sprint başındaki düzeltme kartı işi ÷ kapasite) korunur; sprint içi düzeltme
  ve bırakılan kartın işi bu paya girmez, "toplam hata işi" olarak ayrıca ölçülür (§3.7).
- **D5:** §4.9. A'nın sabitleri; Erdem D5'i onayladı, formül onay bekliyor.

### B · olaylar (başka oturumda uygulanıyor; B dosyalarına dokunulmadı)
- **"Testi kısalt":** test ihtiyacını düşürür; yakalamanın paydası sprint başındaki test ihtiyacı olduğu için C orantılı
  düşer (test yarıya inerse C yarıya). B'nin geçici %15 sabiti D gelince kalkar. B'nin çipi yüzde yazmamalı (Erdem D2):
  TR "Hesap Planı'nın testi yarıya iner." · EN "Account Plan's testing is cut in half." B'ye iletilecek not.
- **"Sürüm sonrası bozulma":** ihtimal girdisi "son sürümün hatalı çıkması" = o sürümle hatlara yazılan kaçan + gönderilen
  bilinen hata. Gönder seçeneğinin ikinci bedeli budur.
- **Karar kâğıdı ve kesinti sırası:** §3.7. B Karar 12 değişmez; gönder sorusu en alttadır.
- **Bedeli ödeyen kişiler:** Geliştirme, Düzeltme ve Test aşamalarında çalışanlar (v2'nin daraltması aynen; Düzeltme eklendi).
- **"Testi sen yap" (kurucu):** kurucu kartı geliştirdiyse ×0,6 uygulanır (§3.6). Seçenek kurucunun yakalaması ekiptekinden
  yüksekken açılmalı (v2 notu aynen).
- **Karar fiillerinin miktarları:** ×5 ve isteğe bağlı aşama alanı (v2 aynen).

### C · ürün sayfası ve B2B
- Gönderilen bilinen hata açık hata olur ve C'nin memnuniyet modeline oradan girer (bugün `b2b_sales_system.gd:147`, hata
  başına 0,3, tavan 20; inceleme: C v3 §5.2'de canlı hat başına yoğunluk × 3, en çok 60, kayma yok). C6'nın yeniden tasarımı
  (memnuniyet nedensiz düşmez) C'nindir; D yalnız hata sayısını hattıyla verir (C'nin terimi hattı alana çevirir).
- "Kararlılık" açık hata ve kesinti satırının başlığıdır (Q2); D'nin katkısı açık hata, bilinen hata ve sürüm notu satırı.
- Hesap isteği kartı (§3.13 C) C v3'ün istek akışıyla birlikte tasarlanır; karşılanan isteğin memnuniyete katkısı C'nin.

### X · eksenler
- D eksen okumaz; hattın iş profilini okur. Q1 kararıyla gizli eksenler (deneyim, inovasyon, kararlılık) ekonomiyi sürmez;
  D'nin sayıları değişmez. Derinlik kartının kazancı alanın puanına (§3.13).

### E · pazaryeri
- Yeni hatlar iş profili ve kademe büyüklüğü taşır; hat sayısı 14 olunca D5'in k'si en az 1,56.
- EA'da sonsuz koşu için arz (§3.13) E'nin modülleriyle birlikte tutmalı.

### Kayıt şeması
- B şemayı 17'ye taşıdı (`CLAUDE.md` §6). (inceleme) C v3 de memnuniyet defteri için 17 → 18 diyor (`C_ICERIK_v3.md`
  §5.10) ve sıra Kalite → C → D'dir: D, C'nin şemasından bir sonrakini alır (C 18 ise D 19). D'nin göçü:
  kartta `need` (4 sayı, Düzeltme dahil), `kadro` (4), `ready`,
  `prep_b`, `prep_h` (hazırlık faydası), `test_need0`, `tested`, `bugs_n`, `bugs_found`, `fix_costs` (bulunan hataların işi),
  `held` (bırakıldı), aşama bazında `assignees` ve `log`; üründe `prep` (kart → hazırlık puanı). Kartın `faulty`, `shares`,
  `effort_mod` alanları gider. Göç: saklı kartın ihtiyacı tablodan, ilerleme aşama payıyla ×5; yarım testli kart testi
  baştan alır (tahmin: göçte kaybı en çok bir kartın testi).

---

## 6. Simülasyon tanımı
Simülasyonu yazacak ajan içindir. Başlangıç betiği `dmodel3/dsim3.py`; bağlayıcı olan bu bölüm.

### 6.1 Kapsam
- Sprint motoru, hazırlık, hata yükü, test anında bulunan ve kaçan hata, Düzeltme alt aşaması, gönder sorusu ve oyuncu
  politikası, düzeltme kartları, taban hata akışı, öneri kuralı, arz kipleri, EA takım kipi.
- Dışarıda: olaylar (B), satış ve para, moralin hıza dönüşü (verim 1, saat 8), izin, eğitim, araştırma kartı, ücretli plan.
  Söz ve istek tarihleri yalnız arz kipinde istek kartı olarak var; sorunun "söz ve istek" tetiği simülasyonda yok.

### 6.2 Sabitler
| Ad | Değer |
|---|---|
| `BASE` | 10 |
| `Y(s)` | 0,5 + 0,05·s + 0,01·s² |
| `U` | ana 1,0 · ikincil 0,7 · uymayan 0,4 · kurucu 1,0 |
| `FOUNDER_FLOOR` | kurucuda Y = en büyüğü (0,86; Y(s)) |
| `FOUNDER_STRONG` | kurucu, puanı ≥ 5 olan en güçlü alanında (tasarım, yazılım, test) sınıf 0 |
| `SIZE` | K1 15 · K2 25 · K3 40 (K3'ten sonraki akış kartları 40) |
| `NEED` | §3.2 tablosu; dördüncü alt aşama (Düzeltme) başta 0 |
| `SLICE` | 8 |
| `H0` | 0,04 |
| `KIND_H` | özellik 1,0 · düzeltme kartı 0,3 |
| `C_REF` | 0,57 (c = C_REF × √Y(test)) |
| `SELF_TEST` | 0,6 (kişinin bu kartta Geliştirme işi > 0 ise) |
| `FIX_LIGHT`, `FIX_HEAVY`, `HEAVY_P` | 1,3 · 5,3 · 0,18 |
| `FIX_PER_BUG`, `FIX_MIN` | 2 · yok (inceleme; v3 taslağı 5; betikte `D3_FIXMIN=2.5` aynı sonucu verir) (düzeltme kartı büyüklüğü; pay 0 / 0,7 / 0,3) |
| `PREP_RATIO` | 0,20 |
| `PREP_RATE(s)` | 15 + 10 × √((s − 2) ÷ 8), s < 2 ise 7,5 s |
| `PREP_B(s)` | 0,10 + 0,025 (s − 2), [0,05; 0,30] |
| `PREP_H(s)` | 0,10 + 0,0375 (s − 2), [0,05; 0,40] |
| `PM_BEST` | fayda, sprintte payı olan PM'lerin en yüksek Ürün puanından |
| `CEIL` | 1,25 |
| `PHASE_K` | 2,0 |
| `FIX_SHARE_MAX` | 0,5 |
| `FIX_DUE_MIN` | 2 |
| `Q_RATIO` | 1/3 (soru: K ≥ en büyüğü (1; ⌈F ÷ 3⌉)) |
| `SPRINT_WEEKS` | 2 (ayrıca 1 haftalık kip) |
| `FLOOR_WEEK × USAGE` | 0,7 × 1,5 hata/hafta (canlı hatlara eşit olasılıkla) |
| `UNFIT_MORALE` | −2 / uymayan hafta |
| `K_D5` | en büyüğü (1; canlı hat ÷ 9; √(son 8 hafta teslim ÷ 55)) |
| `DEPTH_OPEN` | 1 + ⌊hattı kullanan hesap ÷ 5⌋, en çok 8 (inceleme; taslak ÷ 10, en çok 4) |
| `DEPTH_GAIN` | 0,75^(k−1) |
| `TEAM_LEAD` | 0,85 + 0,035 × Liderlik (0 ile 10) |
| `TEAM_LOSS` | takımın i'nci kişisinin (i > 8) kendi hızına 0,02 × (i − 8), en çok 0,20 (inceleme: marjinal; taslakta bütün takıma 0,02 × (n − 8)) |
| `WEEKS` | 60 (ana); 130 (büyüme eğrisi, arz); 80 (D5) · tohum 1 ile 20 · pencere 21 ile 60 |

### 6.3 Kişi
- Alanlar `product`, `design`, `eng`, `qa` (0 ile 10). Roller `founder`, `pm`, `des`, `dev`, `test`.
- Ana / ikincil: PM ürün / tasarım; tasarımcı tasarım / ürün; geliştirici yazılım / test; testçi test / yazılım.
- İş kutuları (varsayılan): kurucu Yapım ve Test; PM, tasarımcı, geliştirici Yapım; testçi Test.
- `fit(kişi, aşama)` → (U, sınıf) ya da uymaz:
  - kurucu: tasarım, geliştirme, düzeltme, test için (1,0; 1); `FOUNDER_STRONG` alanında sınıf 0;
  - test: Test kutusu yoksa uymaz; ana alan test (1,0; 0), ikincil (0,7; 2), değilse (0,4; 3);
  - tasarım, geliştirme, düzeltme (düzeltme = geliştirme alanı): Yapım kutusu yoksa uymaz; ana alan (1,0; 0), ikincil (0,7; 2),
    PM'in ikincil tasarımı sayılmaz; öbürü uymaz;
  - hazırlık: Yapım kutulu PM.
- Hız: `rate = BASE × Y × U × (0,85 TİTİZ)`; kurucuda Y tabanı; hazırlıkta `PREP_RATE(product)`.
- Kalite: `c(k) = C_REF × √Y(qa)` (en çok 1); `build_q(k) = 1 ÷ √Y(eng) × (0,5 TİTİZ)`.
- Kapasite: Σ kişi × en büyük aşama hızı × hafta (PM 0 katar). Aşama kapasitesi `pcap[i]` = Σ kişi × o aşamadaki hız ×
  hafta (Düzeltme Geliştirme satırında).

### 6.4 Kart ve akış
- 12 hat (0 ile 3 tasarım ağırlıklı, 4 ile 7 geliştirme, 8 ile 11 test). MVP kartları hat 0, 4, 8'in K1'i.
- **Arz kipleri:**
  - `sinirsiz` (v2): hatlar sırayla dolaşılır, sıradaki kademe, K3'ten sonra 40 puanlık kartlar.
  - `sonlu`: 9 hat, hat başına K1 → K2 → K3; sonraki kademe öncekinin kapanışından sonra aday (`SPRINT_DUZENI.md` `arz.py`).
  - `kaynakli`: `sonlu` + derinlik kartı (§3.13 B) + hesap isteği (§3.13 C). Hesap eğrisi (tahmin): MVP'den sonra haftada
    3 hesap (104. haftada ~300, `SPRINT_DUZENI.md`'nin 330'una yakın); her hesap tohumla 9 hattın 3'ünü kullanır; koltuk
    tohumla 5 ile 150 arası log düzgün; her hesap imzadan sonra 52 haftada bir istek (ilki tohumlu bir haftada).
  - `ea`: `kaynakli` + 60. haftada 4 yeni hat (modül).
- Kart alanları: `need[4]`, `base_need[3]`, `prog[4]`, `prep`, `prep_b`, `prep_h`, `ready`, `hcut`, `kadro[4]`, `t0`,
  `log` (kişi → [d, e, q, f]), `fixed`, `tested`, `n`, `F`, `costs[]`, `held`.
- `phase(c)`: `need[i] − prog[i] > 1e-6` olan ilk i (0, 1, 2); test bitmişse 3 (Düzeltme) ya da 4 (bitti).
- `fix_start(c)` (özellik kartı sprinte ilk girişinde bir kez): `ready = min(1, prep ÷ (0,20 S))`; `sb = prep_b ÷ (0,20 S)`;
  `hcut = prep_h ÷ (0,20 S)`; `need[0..2] = base_need ÷ (1 + sb)`. Her sprint başında `kadro[i] = max(1, ⌈need[i] ÷ 8⌉)`,
  `t0 = need[2]`.
- Hazırlık katkısı: PM'in her `w` hazırlık puanı için `prep += w`, `prep_b += w × PREP_B(s*)`, `prep_h += w × PREP_H(s*)`;
  s* = `PM_BEST` (sprintte payı olan PM'lerin en yüksek Ürün puanı).

### 6.5 Sprint planlama
1. Ürün canlıysa düzeltme kartları: açık hatası ≥ 2 olan her hat (devreden düzeltme kartı olan hat hariç); sıra hata azalan,
   eşitlikte hat numarası. Büyüklük en büyüğü (5; 2 × hata). `fl` = devreden düzeltme kartlarının kalan işi; `fl` > 0 ve
   `fl` + kart > 0,5 × kapasite ise kart açılmaz.
2. Bırakılan ve devreden kartlar, önceki sıralarıyla (öneri basamağı 3).
3. Hepsine `fix_start`. Düzeltme payı = düzeltme kartlarının kalan işi ÷ kapasite (kayıt).
4. Akıştan kart ekleme (öneri basamakları 5 ve 6; arz kipine göre aday listesi): sıradaki adayın kopyasına `fix_start`.
   Sprintte kart varsa şunlardan biri tutmazsa aday atlanır ve sıradaki adaya geçilir, art arda en çok 12 aday atlanınca
   durulur (inceleme; taslakta ilk uymayan adayda durulurdu): (a) kalan iş + kopya ≤ 1,25 × kapasite; (a2) kopyanın işi olan her
   satırda (Tasarım; Geliştirme + Düzeltme; Test) kalan + kopya ≤ 2 × `pcap`; (b) kopyalar 2 hafta (§6.6, önden işsiz)
   oynatılınca kopya > 0 iş alır. Duran neden kayda geçer (`stop_phase`, `arz`).
5. Tek kart kipi (S12): yalnız bir kart.
6. Önden işler: n = sprintteki özellik kartı (en az 1). Tasarımcı varsa sonraki sütun = sıradaki n aday; PM varsa hazırlık
   kuyruğu = sıradaki 3n aday.
7. EA takım kipinde 1 ile 6 her takım için kendi alanlarının kartlarıyla ayrı koşar; takımsız havuz takımsız kartları alır;
   kapasite ve tavanlar takım başına.

### 6.6 Hafta oynatma (zaman sıralı)
```
t = 0; ekipler = {}; açılış = {kart: 0}; meşgul = {kişi: 0}
döngü:
  boştakiler için, kart sprint sırasıyla:
    ph = phase(kart); ph = 4 ya da açılış[kart] > t ise geç
    ekip dolmadıkça (uzunluk < kadro[ph]): aday = boşta, fit(kişi, satır(ph)) olan, rate > 0
      seç = sınıf en küçük, sonra rate en büyük, sonra kimlik; sınıf 3 ise "uymayan" işaretle
  sonraki = min(1, her dolu ekip için t + (need[ph] − prog[ph]) ÷ Σ rate)
  her dolu ekip, her kişi: iş = min(rate × dt, kalan); prog[ph] += iş; log[kişi][ph] += iş; meşgul += dt
    aşama bittiyse: ekip boşalır; açılış[kart] = sonraki
      ph = 2 (Test) bittiyse test_bitti(kart)  (§6.7)
      phase = 4 ise bitiş zamanı kaydı
  t = sonraki; t ≥ 1 ise çık
hazırlık: PM'ler hazırlık hızı büyükten küçüğe; kuyruk sırasıyla; bu hafta başka PM'in aldığı ya da bitmiş kart atlanır
önden tasarım: v2 aynen
boşta += Σ kalan; uymayan her kişi moral −2
```
- TİTİZ ve GÖZÜ YÜKSEKTE çarpanları hızda (v2).
- EA takım kipinde kişinin hızı takım çarpanıyla çarpılır; kişi yalnız takımının kartlarına atanır.

### 6.7 Test anı ve kapanış
**`test_bitti(kart)`:**
- `q` = Σ log[k][eng] × build_q(k) ÷ Σ log[k][eng] (yoksa 1);
- `H = H0 × S × KIND_H × (1 − hcut) × q`;
- `C = min(1, Σ log[k][qa] ÷ t0 × c(k) × (SELF_TEST, log[k][eng] > 0 ise))` (t0 = 0 ise 0);
- kartın RNG'si `random.Random("<tohum>:<kart kimliği>")` (koşu RNG'sinden ayrı; plan oynatması ve kapanış aynı sayıyı
  çeker); `n` = Poisson(H) ters dağılım, ilk sayıyla; her hata için `u`, `v`: `u < C` ise bulunur, işi `v < HEAVY_P` ise
  `FIX_HEAVY`, değilse `FIX_LIGHT`; `F` = bulunan; `need[3] = Σ iş`; `kadro[3] = ⌈need[3] ÷ 8⌉`.

**Kapanış** (sprint, bir haftanın sonunda kartlarının hepsi bitmişse ya da 2 hafta dolmuşsa):
- Taban akış her haftanın sonunda (v2).
- Bitenler (phase 4) yayına çıkar. Testi bitmiş, düzeltmesi bitmemiş kartlar (phase 3) için `K` = düzeltilmemiş bulunan
  (bulunuş sırasıyla, kümülatif iş ≤ prog[3] olanlar düzeltilmiş).
- **Soru:** `K_toplam ≥ max(1, ⌈F_sprint ÷ 3⌉)` ise soru gelir (F_sprint = bu sprintte testi biten kartların F toplamı).
  Politika: `bırak` (soruya hep bırak), `gönder` (soruya hep gönder), `esikli` (soru geldiyse ağır bilinen hatası olmayan
  kartları gönder, öbürlerini bırak), `hep_gönder` (soru olmasa da phase 3 kartlarını gönder). Soru gelmezse bırakılır.
- **Yayına çıkış:** özellik kartında hattın kademesi = en büyüğü; düzeltme kartında önce hattın açık hatası 0; sonra
  `n − F` + (gönderildiyse `K`) hata kartın hattına (ürün canlı değilse bekleme listesine).
- MVP: üç MVP kartı da çıkınca ürün canlı; bekleme listesindeki her kayıt hattına 1 hata.
- RNG sırası (koşu RNG'si): haftalık taban akış. Kart RNG'leri ayrıdır.

### 6.8 Ölçümler (21 ile 60. hafta; 20 tohum medyanı)
v2 §6.8'in bütün ölçüleri (teslim, puan, kişi başı, kart/sprint, açık hata medyanı ve tepesi, düzeltme payı erken ve geç,
hata sprinti ve üst üste, boşta, darboğaz (kapasiteye oranla), hazır kart, MVP, marjinal getiri, moral), ve:
| Ölçü | Tanım |
|---|---|
| Kaçan / 100 puan | Hatlara yazılan kaçan + gönderilen hata ÷ teslim × 100 |
| Bulunan / sprint, bilinen / sprint | F_sprint; kapanıştaki K toplamı |
| Sprint içi düzeltme | Düzeltme alt aşamasına giden iş ÷ kapasite |
| Toplam hata işi | Düzeltme kartı payı + sprint içi düzeltme |
| Soru sıklığı | Soru gelen sprint ÷ sprint (B kesintisi olmadan) |
| Kurucunun kendi işi | Kurucunun log'una giren puan ÷ hafta |
| Bekleme | Özellik kartının sprinte girişinden çıkışına hafta |
| Arz | Plan anında açık aday ÷ ekip; "kart yok" ile duran sprint |
| D5 varış | Hiç düzeltmeyen kolda açık hatanın k × 30'a ilk vardığı hafta − MVP haftası |

### 6.9 Elle doğrulama
| Örnek | Beklenen |
|---|---|
| K2 (25), 2,5★ geliştirici (q = 1), hazırlıksız, testi tek kişi | H = 1,0; E: başkasının kartı 0★ 0,60 · 3★ 0,39 · 5★ 0,19; kendi kartı 3★ 0,63 |
| K1 geliştirme ağırlıklı, v2 §6.9 ekibi, tek kart | Kadro [1, 2, 1]; test 4★ testçide; C = 0,71 |
| K3 geliştirme ağırlıklı, 3★ tasarımcı ve testçi, 1 ile 6 3★ geliştirici | Süre (hata yokken) 3,45 · 2,33 · 1,95 · 1,77 · 1,77 · 1,77 hafta (v2) |
| Hazırlık süresi, tek PM | K1 (3 puan): 1★ 0,20, 3★ 0,14, 5★ 0,12 hafta · K3 (8 puan): 1★ 0,53, 3★ 0,36, 5★ 0,32 hafta |
| Hazır K2 (25), tam hazır | İhtiyaç ÷ 1,10 (1★), ÷ 1,20 (3★), ÷ 1,30 (5★); H × 0,90, × 0,75, × 0,60 |
| Kurucu 0★ tasarımda | 8,6 puan/hafta |
| Düzeltme kartı | 1 hata 5 · 3 hata 6 · 5 hata 10 · 12 hata 24 puan |
| Aynı kart, aynı ekip, iki oynatma | Aynı n, F, costs, bitiş zamanı |

### 6.10 Senaryolar
Puan 0 ile 10. Kurucu: ürün 4, tasarım 0, yazılım 4, test 0 (ayrıca §6.10 Kurucu satırları). "Dağılım" [6, 4, 8, 5, 3, 6, 7,
4, 5, 6] her rol grubunda baştan; PM'in tasarımı ana − 1, testi 2; tasarımcının ürünü ana − 1; geliştiricinin testi ana − 1;
testçinin yazılımı ana − 1.

| # | Ekip | Not |
|---|---|---|
| S1 ile S6 | v2 §6.10 aynen (1, 3, 6, 12, 25, 50 kişi) | Ölçek |
| S7, S7 tek testçi | v2 aynen | Küçük karta çok testçi |
| S8, S8 hepsi Test kutulu | v2 aynen | Aynı rolde 10 kişi |
| S9a, S9b | v2 aynen | Hepsi testçi |
| S10 | v2 aynen | PM'siz 30 kişi |
| S11, S11b, S11 + testçi | v2 aynen | Testçisiz |
| S12 | v2 aynen | Tek karta 12 kişi |
| Kurucu büyümesi | Kurucu; +1, +2, +3 kişi, 0. haftadan; sıralar: geliştirici → tasarımcı → testçi; tasarımcı → geliştirici → testçi; testçi → geliştirici → tasarımcı; PM → geliştirici → tasarımcı; aynı ilk sıra 1★ alımlarla; üç geliştirici. Alınanlar 2,5★. Üç kurucu tipi: orta (4, 0, 4, 0), güçlü geliştirici (4, 0, 8, 0) ve (4, 0, 10, 0), tasarım ve test bilen (4, 6, 4, 6) | D4 kapısı |
| Kurucu büyümesi, gerçek zaman | Aynı sıralar, alımlar 8, 14 ve 20. haftada (ekip 0. haftadan değil) | MVP ve alım anı |
| Testçi yıldızı | S3, 12 kişi (2 PM, 2 tasarımcı, 5 geliştirici, 2 testçi), 25 kişi (3, 4, 12, 5): bütün testçiler 1★, 3★, 5★; testçisiz (geliştiriciler Test kutulu, testçi yerine geliştirici) | Testçi değeri |
| PM yıldızı | S3, 11 kişi (1 PM, 2 tasarımcı, 5 geliştirici, 2 testçi), 23 kişi (1 PM, 4, 12, 5): PM 1★, 3★, 5★; PM'siz | D3 |
| Politika | S1, S3, S4, S5, S6, S10 × {bırak, gönder, esikli, hep_gönder} | Gönder sorusu |
| Kart sayısı ölçeği | S1 ile S6, `sonlu` ve `kaynakli` arz, 1 ve 2 haftalık sprint; büyüme eğrisi 0 ile 12. hafta 1, 12 ile 30 3, 30 ile 60 6, 60 ile 130 10 kişi (tahmin) | Sprint düzeni |
| EA takım | 50 kişi, `ea` arzı: takımsız; 3 takım (liderler Liderlik 4, 6, 8); 7 takım (Liderlik 2 ile 8); her biri lidersiz (Liderlik 0) | K10 |
| Marjinal | S2 ile S6'ya +3★ geliştirici, testçi, tasarımcı, PM, +1★ geliştirici; kişi ekleme eğrisi 1 ile 50 (S6 oranı) | Ekleme düşürmez |
| D5 | S1 ile S6, düzeltme kapalı ve `fix_due`, 80 hafta | §4.9 |
| Uç | S3 + PM'in Test kutusu; S3 PM'siz; S4 PM'siz; S5 tek PM | v2 aynen |

### 6.11 Beklenen sonuçlar
§4.2 ile §4.9 tabloları; ±%10 sapma (tohum ve uygulama farkı). Daha büyük sapmada önce bu tanımla uygulama karşılaştırılır.

### 6.12 Kapılar (model kırık sayılır)
| # | Ad | Hedef | Neden |
|---|---|---|---|
| 1 | `ekleme_dusurmez` | Bir kişi eklemek hiçbir senaryoda teslimi 1 puan/haftadan fazla düşürmez | Oyuncu işe alımın çıktıyı düşürmesini anlayamaz |
| 2 | `kurucu_buyume` | Kurucu büyümesinde şirket teslimi her adımda artar; MVP hiçbir alımla gecikmez; kurucunun kendi işi en çok %12 düşer (inceleme; taslak %10) ve düştüğü her sprintte nedeni üç koddan biriyle kayıtta: aşama değişti, iş yeni gelenle bölündü, kart hazırlıkla küçüldü | "Tek başımayken daha hızlıydım" (Erdem D4) |
| 3 | `mvp_tek_kurucu` | 6 ile 7. hafta | Erken oyunun temposu |
| 4 | `kisi_basi_olcek` | S5, S6 kişi başı S3'ün %70 ile %150'si | Büyük ekip ne çöker ne patlar |
| 5 | `darbogaz_rolu` | Darboğaz rolüne kişi eklemek teslimi artırır (S8 + Test kutulu geliştirici, S11 + testçi, S9a + geliştirici) | Darboğaz cümlesi doğru role yöneltmeli |
| 6 | `duzeltme_payi` | ≥ 2 kişide pay erken ≤ %30, geç ≤ %20; hata sprinti ≤ %5, üst üste yok; tek kurucu erken ≤ %50, geç hata sprinti ≤ %5; dört politikada da | A'nın hedefi, "sürekli hata sprinti yok" |
| 7 | `toplam_hata_isi` | Düzeltme kartı + sprint içi düzeltme ≥ 2 kişide ≤ %20, tek kurucuda ≤ %35 | Erdem'in "sürekli bug sprint koşarken görmeyelim" sözü sprint içi işi de kapsar |
| 8 | `acik_hata_sinirli` | `fix_due` ile son 20 haftanın eğimi ≤ 0,2 hata/hafta | Düzenli düzelten oyuncu kazanır |
| 9 | `testci_yildizi` | 1★ → 5★: kaçan / 100 puan ≥ %40 azalır, bulunan ≥ 2 katı; C hiçbir kartta en iyi testçisinin c'sini aşmaz | Erdem: testçinin değeri görünür olmalı |
| 10 | `testci_degeri` | Testçisiz yerine aynı sayıda kişiyle 3★ testçi (6, 12, 25 kişi): teslim düşmez, kaçan / 100 puan ≥ %20 azalır | v2'de testçi kaliteyi değiştirmiyordu |
| 11 | `pm_yildizi` | Ekibi besleyen PM sayısıyla (bir PM en çok 12 kişi; inceleme) 1★ → 5★: teslim ≥ %10 artar, kaçan / kart ≥ %25 azalır; PM'siz → PM: teslim artar, kaçan azalır | Erdem D3: yıldız oranları değiştirir |
| 12 | `soru_sikligi` | 3 ile 25 kişilik dengeli ekiplerde (S2 ile S5, S10) soru ≤ 1/3; 6 ve 12 kişide ≥ 1/20 | En çok üç sprintte bir; ama soru yaşasın |
| 13 | `soru_politikasi` | Dört politikada teslim farkı ≤ %2; hep gönder açık hata medyanını ≤ %20 artırır; hata sprinti yok | Seçim gerçek ama cezalandırıcı değil (Erdem C5) |
| 14 | `tahmin_sonuc` | Plan ile kapanış: kart başına aşama ilerlemesi, bitiş, n, F farkı ≤ 1e-6 | İlke 5 |
| 15 | `a_sinirlari_oranli` | Hiç düzeltmeyen her ölçekte (S1 ile S6) 10 ile 26 haftada k × 30'a varır; `fix_due` hiçbirinde varmaz | D5 |
| 16 | `arz_havuzu` | `kaynakli` arzda sprintlerin ≥ %90'ında açık aday ≥ 0,75 × ekip (8 kişinin altında ≥ ekip) | `SPRINT_DUZENI.md` K7 |
| 17 | `bosta_nedenli` | Boşta ≤ %10; değilse her sprintte nedeni (kart yok, aşama dolu, rol uymuyor, hazırlanacak kart yok) yazılı | Nedeni gösterilemeyen boşluk yok |
| 18 | `kart_yok_sprinti` | Büyüme eğrisi, 130 hafta: "planlanacak kart kalmadı" sprintleri ≤ %5 | Demo boyunca iş bitmesin |
| 19 | `oneri_dolulugu` | Önerinin aldığı iş ÷ planın alabileceği ≥ %95; bot ile öneri aynı küme | Bot = oyuncu |
| 20 | `derinlik_kazanci` | Aynı alana art arda 5 derinlik kartı: 5.'nin kazancı ilkinin ≤ 1/3'ü | Azalan getiri görünür |
| 21 | `istek_payi` | 100 ve 330 hesapta B2B arzında isteğin payı raporlanır (hedef yok) | Bilgi |
| 22 | `takim_bolme` (EA) | 50 kişi 3 ve 7 takım, liderli: teslim takımsızdan geri kalmaz ya da farkı takım satırında yazılı; lidersiz 7 takım takımsızdan yavaş; kişi eklemek düşürmez (−1) | K10 |
| 23 | `uymayan_moral` | S3 + PM'in Test kutusu: PM 60 haftada 60 ile 90 moral kaybeder | Bedel sayıyla görünür (v2) |

### 6.13 Çıktı
Senaryo başına bir satır (§6.8 ölçüleri) ve her kapı için GEÇTİ / KIRIK ve kanıt satırı. Betik, tohum ve komut listesi.

---

## 7. v2 → v3 değişiklik tablosu
| Konu | v2 | v3 | Neden |
|---|---|---|---|
| Yakalama | 0,40 × √Y; %28 ile %57 | 0,57 × √Y; %40 ile %81; kendi kartı ×0,6 | Erdem: %43 kaçırmak fazla; testçinin değeri |
| Hata yükü | 0,03 / puan | 0,04 / puan | Kaçan hata v2 düzeyinde kalsın |
| Kaçan hatanın çekilişi | Kapanışta Poisson(E), plan karşılaştırmaz | Test anında kart tohumuyla n ve F; plan ve kapanış aynı | Bulunan hata sprintin içinde iş doğurur |
| Bulunan hata | Yok | Düzeltme alt aşaması, hafif 1,3 / ağır 5,3 puan | Erdem D2 akışı |
| Bilinen hata ve soru | Yok | Kapanışta tek soru, eşik bulunanın üçte biri; varsayılan bırak | Erdem D2 |
| Kart ipucu | "Hata ihtimali %35", "Beklenen hata 2" | Yüzde yok; "Test: 3 hata buldu, 2'si düzeltildi" | Erdem D2 |
| Hazırlık hızı | 10 × Y (1★ 6,4 · 3★ 11,6 · 5★ 20) | 15 + 10 √((s − 2) ÷ 8) (15 · 22 · 25) | Erdem D3 |
| Hazır kart | İş −%20, hata ×0,75 | Hız +%10 ile +%30, hata ×0,90 ile ×0,60 (yıldızla) | Erdem D3 |
| Birden çok PM | Fayda sabit | Fayda en iyi PM'in yıldızından | PM eklemek teslimi düşürüyordu |
| Kurucu tabanı | Y ≥ 1,0 (2,5★) | Y ≥ 0,86 (2★), etiketsiz | Erdem D4 |
| Kurucunun sırası | Her aşamada uzmandan sonra | Güçlü alanında uzmanla aynı sırada | 1★ alım MVP'yi geciktiriyordu |
| Düzeltme kartı | 5 ya da 10 puan | 2 puan/hata, alt sınırsız (inceleme) | Büyük ekipte hatanın bedeli sıfırlanmasın; tek kurucuda kart sprinti yutmasın |
| Öneri | Bugünkü kural (bu sprintte bitecek kartlar) | Plan tavanına kadar, altı basamak, bot = öneri | `SPRINT_DUZENI.md` K3 |
| Arz | Sınırsız akış varsayımı | Dört kaynak, hedef 0,75 × ekip | `SPRINT_DUZENI.md` K7, K8 |
| A'nın sınırları | Mutlak (öneri: oranlansın) | k = en büyüğü (1; hat ÷ 9; √(teslim ÷ 55)) | D5 onaylı; ölçüm |
| Takım | Yok | EA'da lider ve büyüklük kaybı | Erdem D1, `SPRINT_DUZENI.md` K10 |
| Plan ekranı maketi | Claude Design | Oyunun Menajer diliyle | Erdem D6 |
| `D_MODEL_v2.md:772` | "60 haftada tüketir" | 7 haftada | `SPRINT_DUZENI.md` §4.1 |
| Kayıt şeması | 16 → 17 | C'den sonraki numara (B 17'yi, C 18'i alır; inceleme) | B, C |

Değişmeyen: kadro (8 puan), aşama sırası, uyum (0,7 / 0,4 / en az 0,3), yıldız eğrisi, uymayan moral −2, iş profili,
şirket çapında kayıp yok, aşama tavanı (2 ×), düzeltme payı tavanı (yarı), PM'siz ceza yok, tasarımcının yeri.

---

## 8. Onay bekleyen sabitler
| # | Sabit | Değer | Not |
|---|---|---|---|
| 1 | Yakalama | 0,57 × √Y(test); kendi kartı ×0,6 | Jones deneye dayalı test; Myers bağımsız göz |
| 2 | Hata yükü | 0,04 / puan; düzeltme kartı ×0,3 | Kaçan hata v2 düzeyinde |
| 3 | Sprint içi düzeltme | Hafif 1,3, ağır 5,3 puan; ağır %18 | Menzies, Jones |
| 4 | Soru eşiği | Bilinen ≥ en büyüğü (1; ⌈bulunan ÷ 3⌉); söz ve istek kartında eşiksiz | Sıklık §4.8 |
| 5 | Sorunun sırası | Acil durum > söz olayı > kâğıt > soru; söz olayının cevabı söz kartının yerine geçer | B Karar 12'nin uzantısı |
| 6 | Hazırlık hızı | 15 + 10 √((s − 2) ÷ 8) | Uçlar Erdem'in |
| 7 | Hazır faydası | b 0,10 ile 0,30, h 0,10 ile 0,40 (doğrusal) | Uçlar Erdem'in (b); h öneri |
| 8 | En iyi PM kuralı | Fayda sprintte payı olan en iyi PM'in yıldızından | §3.8 |
| 9 | Kurucu tabanı | Y ≥ 0,86 | Erdem D4 |
| 10 | Kurucunun güçlü alanı | Puan ≥ 5 olan en güçlü alanda sınıf 0 | §3.4 |
| 11 | Düzeltme kartı | 2 puan/hata, alt sınırsız (inceleme) | A'nın sabiti |
| 12 | D5 ölçek katsayısı | k = en büyüğü (1; canlı hat ÷ 9; √(teslim ÷ 55)) | A'nın sabitleri |
| 13 | Derinlik kartı | Açık 1 + ⌊hesap ÷ 5⌋ (en çok 8; inceleme); kazanç 0,75^(k−1) | `SPRINT_DUZENI.md` K8 |
| 14 | Hesap isteği kartı | Koltukla 15 / 25 / 40; yılda bir | `SPRINT_DUZENI.md` K8 |
| 15 | Takım (EA) | Lider 0,85 ile 1,20; 9. kişiden itibaren yalnız gelen kişiye sırası başına %2, en çok %20 (inceleme) | EA |
| 16 | v2'den onay bekleyenler | Kadro 8; iş profili payları; uymayan biçimi ve 0,3 tabanı; huyların sprintte okunması; aşama tavanı 2 ×; düzeltme payı tavanı; darboğaz ölçüsü | v2 §7, değişmedi |

Silinenler: C_REF 0,40; `faulty_chance` 0,4; kart ipucundaki ihtimal metni; v2'nin hazırlık hızı (10 × Y) ve sabit hazırlık
faydası; kurucu tabanı 1,0; A'nın `fix_effort` kademeleri.

---

## Erdem'e sorular
1. **Gönder sorusu ne zaman gelsin?** Öneri: yalnız bilinen hata o sprintte bulunanın üçte birine ulaşınca (en az 1) ya da
   bilinen hatalı kart bir sözün veya isteğin kartıyken; vurgulu cevap "Sonraki sprinte bırak"; o sprintte acil durum, söz
   olayı ya da kâğıt geldiyse soru gelmez ve varsayılan uygulanır. Ön hesapta 3 ile 25 kişide en çok üç sprintte bir.
   Gönder ve bırak arasındaki fark küçük ve görünür (kart bir sprint erken, açık hata %5 ile %14 fazla).
2. **Kendi kartını test eden daha az bulsun mu?** Öneri: evet, %60'ı kadar (kurucu dahil). Testçinin değeri büyük ölçüde
   buradan gelir (testçi teslimi %9 ile %14 artırır, kaçan hatayı %25 ile %36 azaltır). Bedeli: tek kurucu testte neredeyse
   hata bulamaz, kartlarının hatası canlıda çıkar (kart başı 0,78, v2'de 0,53); düzeltme payı %29 kalır.
3. **Birden çok PM'de hazır kartın faydası kimin yıldızından gelsin?** Öneri: ekipteki en iyi PM'in yıldızından ("gözden
   geçirdi"). Kartı hazırlayanın yıldızına bağlarsak, kart arzı zaten tam hazırken PM eklemek teslimi düşürüyor (37. kişide
   −2,5). Hazırlık hızı senin örneğinle 1★ 15, 5★ 25 puan/hafta; birim bugünkü kart puanı (bir PM 7 ile 12 kişiyi besler).
4. **Plan ekranı testin bulacağı hatayı bilsin mi?** Öneri: bilsin ama göstermesin. Hata sayısı kartın tohumundan test
   anında belli olur; plan aynı hesabı yaptığı için bitiş tahmini düzeltme dahil doğru çıkar (tahmin = sonuç tam tutar),
   sayı ancak test bitince kart satırında görünür. Öbür yol (plan hatayı hiç saymaz, test bulunca sprint gecikir ve
   "testte hata çıktı" diye adlı uyuşmazlık yazılır) 12 kişilik ekipte neredeyse her sprintte tahmini bozar.

---

## Hacim (saat)
| Dilim | Ne | Bedel |
|---|---|---|
| D0 | Ölçüm altyapısı: `--sprint-probe` ekip listesi, aşama satırı, kart başına n, F, K, düzeltme işi; Godot'ta 50 kişi 50 kart plan süresi | 2,5 |
| D1 | Ölçek ×5, kart ihtiyacı, iş profili, Düzeltme alt aşaması alanları, kayıt göçü (C'den sonraki şema; inceleme) | 3,5 |
| D2 | Hafta oynatması: zaman sıralı atama, kadro, hız, kurucu tabanı ve güçlü alan kuralı, aşama kapısı, tavanlar; tahmin = sonuç | 7 |
| D3 | Hata: yük, yakalama, kendi kartı kuralı, kart tohumu, bulunan ve kaçan, Düzeltme işi, A'ya yazış, yeni kod teriminin silinmesi | 4,5 |
| D3b | Gönder sorusu: kapanış akışı, eşik, varsayılan, B ile sıra, sürüm notu satırları, TR/EN metinler | 3,5 |
| D4 | Hazırlık: kuyruk, hız eğrisi, yıldızlı fayda, en iyi PM, kayıt | 3,5 |
| D5 | Ekip ekranları: Görevler matrisi, Atlas'ta aşama hızları, moral satırı | 2,5 |
| D6 | Plan ekranı (Menajer dili): aşama şeridi, darboğaz cümlesi ve yeni nedenler, kart zinciri, kişi yükü, test satırları | 4,5 |
| D7 | Düzeltme kartı oranı ve A'nın sınırlarının k ile ölçeklenmesi (A'nın sabitleri) | 2 |
| D8 | Sprint düzeni: öneri kuralı ve bot (S2 2,5), derinlik kartları (S3 5, yazım hariç), hesap isteği (S4 2, C ile), arz cümlesi (S5 1) | 10,5 |
| D9 | Ölçüm ve kalibrasyon raporu: bot kolları, dört politika, A hedefleri, 5★ ile 3★ (commit yok) | 2,5 |

- Toplam ~46 saat; kapılar, ekran çekimleri ve commit başına incelemelerle 52 ile 58 saat. Öncesinde simülasyon ajanının
  §6 koşusu (~3 saat; arz ve EA kipleri yeni).
- EA takımı (§3.14) ayrıca 10 ile 14 saat.
- Derinlik ve istek kartlarının adları (iki dil) içerik ajanının işidir; hacmi şablona bağlı.
- Bu belge: okuma, prototip ve ölçüm, yazım yaklaşık 3,5 saat.
- En büyük risk D2 ile D3'ün birleşimi: kart tohumlu hata ve sprint içi düzeltme tahmin = sonuç kapısının yükünü artırır.
  Önlem: D0'ın probu ve §6.12 kapı 14 D3'ün kapısıdır.

---

## İnceleme notu (Opus)
Kıdemli inceleme, 17 Ekim 2026 gecesi; `D_SIM_v3.md` ile karşılaştırıldı. Betiğin formülleri belgeyle aynı (`dsim3.py`:
`Y`, `prep_rate`, `prep_b`, `prep_h`, `on_test_done` içindeki H, C, kendi kartı ×0,6, kart tohumu; düzeltme kartı büyüklüğü;
derinlik kartı sayısı). Ne değişti, neden:
1. §0, §3.9, §6.12 kapı 2: kurucunun kendi işi en çok %10,1 düşer (taslak "%7"); düşüşün üç nedeni plan ekranında yazar,
   kapı eşiği %12. Model aynı; şirket teslimi 72 adımın hepsinde artıyor, MVP gecikmiyor.
2. §3.12 b ve §6.5 adım 4: öneri uymayan adayı atlar (en çok 12). Taslakta kural kendi içinde çelişiyordu.
3. §3.12 c: düzeltme kartının alt sınırı (5) kalktı, 2 puan/hata. Neden: 1 haftalık sprintte tek kurucuda %50 hata sprinti,
   reddedilen "sürekli hata sprinti".
4. §3.13 B: derinlik kartı 1 + ⌊hesap ÷ 5⌋, en çok 8. Neden: eski üst sınır 50 kişinin hedefinin matematiksel olarak altındaydı.
5. §3.14: takım kaybı marjinal; takım satırı hız ve boşta kişiyi yazar. Neden: kişi eklemek takımı 2,9 puan yavaşlatıyordu.
6. §4.6, kapı 11: PM kapısı besleyen PM sayısıyla okunur (bir PM en çok 12 kişi). Belgenin kendi tablosu kapıyla çelişiyordu.
7. §3.7, §4.5, §5 C: açık hatanın müşteriye etkisi C v3'ün yeni modeline (canlı hat başına yoğunluk, kayma yok) bağlandı;
   taslak bugünkü kaldırılacak hedefi anlatıyordu.
8. §5 kayıt şeması: C de 17 → 18 diyordu; D, C'den sonraki numarayı alır.
9. §3.13: 12 kişide katalog 12 haftada biter (v3 modeli), 11 değil.

**Dört kabulün birlikte ölçümü** (2, 3, 4 birlikte; `D3_DEPTHMAX=8 D3_DEPTHDIV=5 D3_FILLSKIP=12 D3_FIXMIN=2.5`, 20 tohum,
`scratchpad/dsim3/rv_inceleme.py`, ham sonuç `out/P_rv_birlesik.pkl`). Taban → birlikte:

| Senaryo | Açık aday ≥ hedef | Öneri doluluğu | Teslim (puan/hf) | Boşta payı | Düzeltme payı (geç) | Hata sprinti |
|---|---|---|---|---|---|---|
| S1 · 1 hf | %100 → %100 | %100 → %100 | 4,3 → 4,5 | %18 → %20 | %43,6 → %34,9 | 401/800 → 53/800 |
| S1 · 2 hf | %100 → %100 | %100 → %100 | 4,1 → 4,8 | %21 → %18 | %29,1 → %23,3 | 4/569 → 2/540 |
| S2 · 1 hf | %100 → %100 | %77,0 → %94,9 | 15,3 → 19,6 | %30 → %16 | %10,1 → %13,9 | 0/800 → 0/800 |
| S2 · 2 hf | %100 → %100 | %87,1 → %100 | 21,0 → 22,3 | %13 → %8 | %9,5 → %9,2 | 0 → 0 |
| S3 · 1 hf | %100 → %100 | %89,5 → %100 | 43,7 → 46,9 | %19 → %17 | %9,8 → %7,8 | 0 → 0 |
| S3 · 2 hf | %100 → %100 | %89,2 → %99,5 | 44,7 → 46,5 | %16 → %16 | %5,9 → %7,4 | 0 → 0 |
| S4 · 1 hf | %100 → %100 | %94,2 → %100 | 92,5 → 96,9 | %18 → %16 | %4,9 → %3,9 | 0 → 0 |
| S4 · 2 hf | %100 → %100 | %94,7 → %100 | 97,6 → 99,9 | %13 → %13 | %4,9 → %4,4 | 0 → 0 |
| S5 · 1 hf | %82,5 → %100 | %97,8 → %100 | 236,6 → 246,1 | %10 → %8 | %4,2 → %3,4 | 0 → 0 |
| S5 · 2 hf | %80 → %100 | %99,2 → %100 | 217,3 → 247,0 | %15 → %7 | %3,4 → %3,0 | 0 → 0 |
| S6 · 1 hf | %0 → %71 | %99,2 → %100 | 372,8 → 472,3 | %27 → %13 | %2,9 → %2,5 | 0 → 0 |
| S6 · 2 hf | %0 → %65 | %100 → %100 | 295,6 → 406,4 | %42 → %22 | %2,2 → %2,5 | 0 → 0 |
| S5 · 330 hesap | %100 → %100 | %100 → %100 | 228,1 → 230,3 | %11 → %11 | %3,6 → %3,6 | 0 → 0 |
| S6 · 330 hesap | %0 → %100 | %100 → %100 | 385,9 → 475,5 | %23 → %12 | %2,9 → %2,7 | 0 → 0 |
| Büyüme eğrisi 1 → 10 kişi, 130 hf | %100 → %100 | %85,9 → %99,4 | 66,6 → 67,5 | %7 → %6 | %5,7 → %4,5 | 0/1107 → 0/1106 |

- Kapı 16 (`arz_havuzu`): 1 ile 25 kişide ve 330 hesaplı 50 kişide %100; yalnız 0. haftadan tam 50 kişi ile haftada 3 hesap
  %65 ile %71'de kalır (gerçek oyunda ekip hesaplarla birlikte büyür; büyüme eğrisi %100).
- Kapı 19 (`oneri_dolulugu`): en düşük %94,9 (3 kişi, 1 hf; atlama tek başına %96,8 veriyordu, düzeltme kartının küçülmesi
  arkasındaki adayları değiştiriyor); öbürleri %99,4 ile %100. Sınırın 0,1 puan altı; sayı yön gösterir.
- Kapı 6 (`duzeltme_payi`): ≥ 2 kişide geç pay en çok %13,9, hata sprinti 0; tek kurucuda 2 hf %0,4, 1 hf %6,6 (kalan tek
  aşım, Erdem'e soru).
- Teslim hiçbir satırda düşmüyor; tahmin = sonuç en büyük fark 1,4e-14. EA takım kipi bu birleşimle yeniden koşulmadı
  (marjinal kayıp ayrı ölçüldü, `D_SIM_v3.md` §8.5).
