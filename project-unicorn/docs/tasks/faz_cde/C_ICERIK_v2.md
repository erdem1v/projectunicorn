# Faz C içerik v2 · Ürün sayfası ve B2B hesaplar
Yazan: Opus planlayıcı · 2026-10-17 · Kaynak: Erdem'in 17 Ekim yorumu (`ERDEM_CD_YORUM.md`, birebir), eski plan
`C_PLAN.md`, araştırma raporları R1, R2, R6, R7, R8 (Tamamlama bölümleri öncelikli). Kod `26b60da` (A K8) üstünde okundu.

Etiketler:
- **Erdem'in kararı (17 Ekim):** yalnız yorum metninde açıkça kabul ettiği şey.
- **Erdem'in isteği (17 Ekim):** istediği yön; ayrıntısı bu belgede öneri.
- **Öneri:** benim önerim, onay bekliyor.
- **[ÇALIŞMA]:** deneme sayısı, onay bekliyor ve ölçümle kesinleşir.
- **Değişmedi:** `C_PLAN.md`'deki hâli geçerli, burada tekrar yazılmadı.
- Araştırma dayanağı rapor ve bölümle yazılır ("R6 §7.1"). Kaynaksız model bilgisi ayrıca işaretlenir.

Bu belge uygulama dilimi vermez. İçerik, oyuncunun gördüğü ve kurallar içindir. Yeni ya da değişen her ekran koddan önce
Claude Design'da maketlenir; burada yalnız ekranın içeriği ve kaba ASCII taslak vardır.

---

## 0. Özet

1. **Sunucu:** Üç kademe kalır. Önerilen model: kapasite kendiliğinden ölçeklenir ama hızı kademeye bağlıdır (Ekonomik
   ayda bir, Standart ve Kurumsal her hafta). Ekranda tek bir "Yük %" sayısı görünür; yük yüksekse kesinti olasılığı artar.
   Aşımın gizli cezaları (memnuniyet, bildirim, kazanım) kalkar.
2. **Sunucu fiyatı:** Bugün gelirin %3'ü; gerçek pratikte %8 ile %17 arası (R6 §1, §2.5). Fiyat Standart'ta yaklaşık 2,7 kat
   artar, aynı tutar servis giderinden düşülür; Standart'taki toplam gider değişmez. Kademe oranı 1 : 2 : 4 olur.
3. **Kesinti çarpanı:** Erdem'in 1,0 / 0,8 / 0,5 ile R6'nın 1,0 / 0,4 / 0,15'i olay sayısıyla karşılaştırıldı. Öneri
   1,0 / 0,5 / 0,25.
4. **Kurumsal madde:** 8 hafta süre; süre dolunca müşteri hakkını memnuniyetine göre kullanır (zarsız kural). Geçiş her an
   tek tıktır ve bildirimi geri aldırır.
5. **HESAPLAR tablosu:** Sütunlar kalır. Her başlık tıklanınca sıralar. Dört görünüm ve firma araması eklenir. Para
   hücresi aylık kalır; sözleşme bedeli ipucuna gider.
6. **Memnuniyet:** Yeni hesap 70'ten başlar. Eşik formülü kalır. (inceleme) Memnuniyet hedefe haftada 21 puana kadar
   kaydığı için yalnız başlangıç değeri ilk hafta silinir; Erdem'in "70'ler" isteği bu yüzden hedefe yazılır: "İlk 4 hafta
   tabanı" kalkmaz, eşik + 2 yerine 70 olur ve sonraki 8 haftada sönümlenir (öneri). A'nın hata bedelinin B2B'de ölmemesi
   için ceza tavanı 20'den 40'a çıkar; kapı ölçümle doğrular.
7. **Yenileme:** Zar ve yıldız karşılaştırması kalkar. Her hesabın bir "yenileme tutumu" vardır ve görünür sayılardan
   okunur (memnuniyetin eşiğe uzaklığı). Satışçı tutumları öğrenip rapor getirir; satışçı yoksa kurucu mailden teklif
   gönderir, müşteri kabul eder, karşı teklif verir ya da "yenilemeyeceğiz" der. Kurucu saati yazılmaz.
8. **Haftalık destek raporu** kalır; "Yetişemedim" satırı açık bir tanım ve oran kuralı alır.
9. **Rakip analizi kapsam dışı;** fiyat ipucundaki rakip satırı çıkar.
10. **Hacim:** 10 commit, yaklaşık 27,5 saat; maketler bunun dışında.

---

## 1. Erdem'in C yorumu → nasıl karşılandı

| # | Erdem (kısa alıntı) | Karşılık | Yer |
|---|---|---|---|
| 1 | "açık hata sayısı 2 yükseldiği anlamındaysa okey kalabilir" | Evet, ▲2 son haftalık tike göre değişimdir. İpucu "Geçen haftaya göre +2" der. Erdem'in kararı (17 Ekim). | §2.1 |
| 2 | "İstekler kısmı okey" | Değişmedi. Erdem'in kararı (17 Ekim). | §2.1 |
| 3 | "Sunucu tarafı, gösterim şekli okey" | Blok kalır; önerilen modelde içine "Yük %" satırı girer. | §2.1, §2.2 |
| 4 | "iş kısmı okey" | Değişmedi. Erdem'in kararı (17 Ekim). | §2.1 |
| 5 | "BTC'de temsilci yokken 1-2 kullanıcı alıntısı okey" | Kalır. Alıntı metinleri E'nin; not ürünü siliniyor. Erdem'in kararı (17 Ekim). | §2.1, §3 |
| 6 | "ekonomik standart kurumsal gayet iyi" | Üç kademe kalır. Erdem'in kararı (17 Ekim). | §2.2 |
| 7 | "kapasite kendiliğinden büyür küçülür ... kalkar dedik ama ... araştırmamız gerekiyor" | Üç model R6 ile karşılaştırıldı; öneri kademeye bağlı ölçekleme ve görünür yük. Soru 1. | §2.2.1 |
| 8 | "fiyatlar gerçekçi mi ... ne alakalan der mi" | Sunucu payı gerçeğin 3 ile 5 katı ucuz; servis gideri ise pahalı. Toplam gerçekçi. Öneri yeniden bölüştürme. Soru 3. | §2.2.3 |
| 9 | "1000 kullanıcı başına ya da 50 koltuk başına ... kapasite neye göre ölçülüyor" | Gerçekte eşzamanlı yük; fatura kullanım bazlı. Oyuncu kullanıcı ya da koltuk sayısını, faturayı ve yükü görür. | §2.2.2 |
| 10 | "1.5 belki biraz fazla ... ekonomikte 1 standartta 0.8 kurumsalda 0.5'lara 0.4'lere" | İki seçenek ve bir ara öneri olay sayısıyla karşılaştırıldı. Soru 2. | §2.2.5 |
| 11 | "iki ay boyunca biz kurumsala geçmezsek sözleşmeyi feshetme hakkı doğar" | Süre 8 hafta [ÇALIŞMA]; hakkın kullanılma kuralı zarsız ve görünür. Soru 4. | §2.3 |
| 12 | "Adaylar ve hesaplar gayet okey ... sütunları okey" | Değişmedi. Erdem'in kararı (17 Ekim). | §2.4 |
| 13 | "aylık mı yazmalıyız? Yoksa toplam sözleşme bedeli yazıp MRR'ı kenarda" | Aylık kalır; sözleşme bedeli sıralamayı değiştirmediği için sütun olmaz, ipucuna gider. | §2.4.2 |
| 14 | "durum sütununda ayrılabilir, yenilemeyebilir, yenilemeyecek ... fena değil" | Kalır. İki gerekçeli olgu eklenir: sunucu maddesi ve fesih bildirimi. | §2.4.1 |
| 15 | "330 hesap ... sütun isimlerinin üzerine bastığımız zaman filtreleme" | Başlığa tıklayınca sıralama, dört görünüm, firma araması. Erdem'in isteği (17 Ekim). | §2.4.3 |
| 16 | "Memnuniyet ipucu ... bunlar okey ... ürün kararlılığı kısmından emin değilim" | İpucu kalır. Kararlılık satırı paralel eksen kararına bağlı; iki hâl yazıldı. | §2.5.3 |
| 17 | "Direkt böyle mi sormalı yoksa ... patron müşteriyle görüştüm ... bu zam istiyor, bu indirim" | Üç akış karşılaştırıldı; öneri satışçı raporu. Soru 5. | §2.6 |
| 18 | "Satışçı yoksa kurucuya kağıt gelir o da çok okey" | Kalır. Erdem'in kararı (17 Ekim). | §2.6.4 |
| 19 | "Sözleşme tabii ki 12 ay evet" | Kalır. Erdem'in kararı (17 Ekim). | §2.6 |
| 20 | "%8 zam, aynı fiyat, %10 indirim güzel. Ama UI'da nasıl göstereceğiz?" | Seçenek mantığı kalır; görünüm Claude Design maketiyle gelir. | §2.6, §5 |
| 21 | "Sonuç zarsız demişiz bunu anlamadım ... sizi kullanmak istemiyoruz diyen olmayacak mı?" | Sonuç tablosu ve yıldız karşılaştırması kalkar. Yerine tutum basamakları gelir. "Yenilemeyeceğiz" diyen müşteri bilinçli olarak var. (inceleme) "Zarsız" şu demektir: sonucu şans değil, oyuncunun gördüğü memnuniyet ve eşik belirler. Erdem zar istemediğini söylemedi; zarsızlık bir öneridir. Bakımlı üründe yenilemede ayrılan neredeyse olmaz; bu açık bırakıldı (Soru 5). | §2.6.1 |
| 22 | "bedel başına 2 saat biraz fazla ... mail üzerinden offer ... counter offer" | Kurucu saati yok. Mail teklifi, tek karşı teklif turu. Erdem'in isteği (17 Ekim). | §2.6.4 |
| 23 | "Kağıt cevapsız kalırsa satışçı aynı fiyattan yeniler mantıksız değil" | Kalır. Satışçı yolunda Erdem'in kararı (17 Ekim); (inceleme) kurucu yoluna uzatılması öneridir, eski planda kurucu yolunun cevapsız kuralı farklıydı. | §2.6 |
| 24 | "rakip kısmını şu an için out of scope tutalım" | Kapsam dışı; fiyat ipucundaki rakip satırı ve rakip fiyat verisi çıkar. Erdem'in kararı (17 Ekim). | §2.10 |
| 25 | "Haftalık destek raporu evet ... yeni bir şey yoksa gelmez" | Kalır. Erdem'in kararı (17 Ekim). | §2.7 |
| 26 | "Temsilci yetişemediden kastın nedir?" | Tanım yazıldı: o hafta gelen bildirimlerin beşte biri ya da fazlası cevapsız kaldıysa. | §2.7 |
| 27 | "Okunmamış eski rapor yenisi girince kutudan düşer. Okey." | Kalır. Erdem'in kararı (17 Ekim). | §2.7 |
| 28 | "MRR ortak dil ... koltuk aylık ... 12 ay ... nakit aylık ... gayet iyi" | Kalır. Erdem'in kararı (17 Ekim). | §2.8 |
| 29 | "Onboarding tarafındaki önerini kabul ediyorum" | "İlk Kullanım ve Erişim" ve "İlk Açılış Akışı". Erdem'in kararı (17 Ekim). | §2.9 |
| 30 | "memnuniyet başlangıcını yukarıdan ... %70'ler ... %50'den başlamasın" | Başlangıç 70. Eşik formülü kalır. (inceleme) Başlangıç değeri ilk haftada hedefe kaydığı için 70 hedefin tabanına da yazılır ve sönümlenir. A'nın hata bedeliyle çatışma ve kapısı yazıldı. Soru 6. | §2.5 |

---

## 2. Bloklar

### 2.1 Genel Bakış (Ürün penceresi)
**Değişmedi** (C_PLAN §2.1): üç kâğıt GENEL BAKIŞ | SPRINT | ÇEYREK, Genel Bakış v1.0'dan önce kilitli, beş blok, açıklama
satırı yok, Destek satırı tıklanınca Sprint'te o hattın düzeltme kartı vurgulanır, İstekler yalnız temsilci varken, İş satırı
tek satır.

Değişenler:
- **Destek:** "Açık hata 7 ▲2". ▲ son haftalık tike göre değişimdir. İpucu: "Geçen haftaya göre +2". A'nın "Acil" etiketi
  "Öncelikli" oldu; hat satırı A'nın biçimini okur, C yeniden yazmaz.
- **Sunucu bloğu** yeni modele göre (§2.2.6).
- **Sürüm bloğu** eksen kararına bağlıdır (paralel belge `X_URUN_EKSENLERI.md`):
  - Eksenler kalırsa ve oyuncuya gösterilirse: sürüm, yaşı, sonraki sürüm ve X'in "ürün durumu satırları" (X §8.1).
    (inceleme) Çıplak eksen sayısı ("Kararlılık 61") yazılmaz; X §8.4 bunu yasaklar. Satır kelime ve kareyle çizilir.
  - Eksenler kalkarsa: sürüm, yaşı ve sonraki sürüm kalır; eksen satırının yerine X'in ürün ölçüsü yazar ya da satır
    kalkar. C bu satırı kendi icat etmez.
  - (inceleme) İki hâlde de C, X §8.1'deki sözleşmeyi okur ve 3 ile 5 arası satır çizebilmelidir.
- **B2C alıntılar** (temsilci yokken "Sesler"): kalır. A K6'da eski "Sesler" listesi silindi; bu yeni bir bileşendir. Not
  ürünü E'de silindiği için alıntı metinleri yalnız E'nin hatları için, E'de yazılır.

### 2.2 Sunucu

#### 2.2.1 Model seçenekleri
| | S1 · Doluluksuz | S2 · Kademeye bağlı ölçekleme (öneri) | S3 · Elle kapasite |
|---|---|---|---|
| Oyuncunun kararı | Yalnız kademe | Kademe | Kademe ve birim sayısı |
| Ekranda | Fatura | Fatura ve "Yük %" | Fatura, birim, doluluk çubuğu |
| Kapasite | Her hafta kendiliğinden | Ekonomik ayda bir, Standart ve Kurumsal her hafta | Oyuncu ekler ve çıkarır |
| Kesinti olasılığı | Kademe × açık hata | Kademe × yük × açık hata | Kademe × yük × açık hata |
| Dayanak | GDT, MGT ve MGT2'de doluluk yok, yalnız yinelenen gider var (R6 §2.3) (inceleme: Startup Company dayanak değildir, onda doluluk vardır, R6 §7.1) | Hiçbir oyunda otomatik ölçekleme yok, oyuncular istiyor; R6 §5 "otomatik ölçekleme kademe özelliği olsun" | Startup Company Hosting sekmesi: Used/Free CU, kadran, Critical/Unstable/Stable (R2 §7.7 görüntü 8) |
| Zayıf yanı | Kademe bir kez seçilir, unutulur. Erdem: "emin değilim". | Bir sayı daha | Oyuncular otomatik denge istiyor; geliştirici elle dengeyi bilerek tutuyor ama fazlasının "can sıkıcı bir işe" döneceğini kabul ediyor (R6 §2.4) (inceleme); 330 hesapta sürekli birim ekleme |
| Bedel | Küçük | Orta | Büyük |

**Öneri: S2.** Gerekçe:
- Erdem'in 16 Ekim sezgisi "kesinti olasılığını sunucu kalitesi ve doluluk üzerinden hesaplayabiliriz, daha sağlıklı
  olabilir" bu modelde gerçekleşir, angarya olmadan: oyuncu birim almaz. (inceleme) Erdem aynı cevapta "direkt bence
  doluluğu kaldırmalıyız ... ya da bilmiyorum", önceki turda da sunucuyu "overkill" bulduğunu söyledi. S2 bu yüzden tek
  sayıyla kalır; yükü göstermek bile fazla gelirse S1 hazırdır.
- Kademe kararı tek seferlik olmaktan çıkar. Ekonomik küçük ve yavaş büyüyen üründe yeter; hızlı büyüme döneminde (B2C
  sıçrama, B2B'de büyük hesap imzası) yük yükselir ve olay sıklaşır. Oyuncu bunu ekranda görür ve kademeyi yükseltir.
- Gerçekte de böyledir (kaynaksız, model bilgisi): ucuz paylaşımlı sunucu elle büyütülür, bulut kendiliğinden ölçeklenir.
- Kural orandır (yük = hizmet edilen ÷ kapasite). 1 hesapta da 330 hesapta da, 3 kişide de 50 kişide de aynı çalışır.
- Bugünkü bot ölçümünde doluluk hiç %100'ü aşmadı, çünkü kapasite her sürümde büyüyordu (C_PLAN §1). S2'de Ekonomik'in
  ölçeklemesi aya bağlandığı için yük gerçekten oynar.

**S2'nin kuralları**
- Kapasite hedefi: yük %80 [ÇALIŞMA] (bugünkü sürüm kuralının değeri). Ölçekleme kapasiteyi bu hedefe getirir, aşağı da
  iner.
- Ölçekleme sıklığı: Ekonomik ay kapanışında, Standart ve Kurumsal her haftalık tikte.
- **Yük çarpanı** (kesinti olasılığına): yük %90'a kadar ×1; %90 ile %100 arası ×1,5; %100 üstü ×2,5 [ÇALIŞMA]. Eşik
  %90'dır, %80 değil: haftalık ölçeklenen Standart, hafta içi büyümeyle %80'i hep biraz aşar ve çarpan anlamsız sabit
  olurdu. R6 §5 daha sert bir eğri önerir (%80-100 ×3-5); B'nin 4 haftalık en küçük aralığı yüzünden yumuşatıldı.
- Yükün başka etkisi yoktur. Bugünkü aşım etkileri (memnuniyet günde −0,8, bildirim ×1,5, B2C kazanımı ×0,6) silinir.
  Gerekçe: oyuncunun görmediği ceza (R8 §4, Startup Company'nin "gizli ceza" dersi). Yükün tek sonucu görünür olaydır.
- Ekonomik'in bugünkü öbür iki etkisi değişmedi: bildirim ×1,25 ve satış görüşmesinde güven eksi (C_PLAN §2.3).
- Kademe geçişi anında ve bedavadır; Ekonomik'ten yukarı geçince ölçekleme o hafta yapılır.

Erdem S1'i seçerse: yük satırı ve yük çarpanı yoktur, ölçekleme her kademede haftalıktır, öteki her şey aynıdır.

#### 2.2.2 Birim: kapasite neyle ölçülür
- Gerçekte kapasite eşzamanlı yükle (saniyedeki istek, işlemci, bellek) ölçülür. "1.000 kullanıcı" da "50 koltuk" da
  insan sayısıdır; etkin oran ve tepe katsayısıyla yüke çevrilir (R6 §2.5, kaynaksız model bilgisi olarak işaretli).
- Fatura gerçekte makine sayısından çok kullanımdan oluşur (veritabanı, depolama, trafik). Sektörde ölçü "kullanıcı ya da
  müşteri başına aylık altyapı maliyeti"dir (R6 §2.5, wring rehberi: KOBİ müşteri başına $3-8, orta ölçek $15-50).
- Oyunlarda: Software Inc'te özellik başına "aktif kullanıcı başına Mbps" (R6 §7.2, resmi wiki); Startup Company'de tek
  birim CU, özellik başına CU yükü (R6 §7.1). İkisinde de özellik eklendikçe aynı kapasite daha az kullanıcı taşır. Bizim
  bugünkü yük formülümüz (ağır hat yayınlamak yükü artırır) aynı fikirdir ve kalır.
- **Öneri:** Oyuncu sunucu adedi görmez. Sunucu bloğu kullanıcı ya da koltuk sayısını, aylık faturayı ve yükü yazar.
  Birim fiyat ipucundadır: "1.000 kullanıcı başına ayda $150", "50 koltuk başına ayda $120".
- Sunucu adedini göstermemenin nedeni: gerçekçi bir kullanıcı/sunucu oranıyla fatura gerçekçi çıkmaz. 1.000 kullanıcıya
  bir sunucu derseniz 280.000 kullanıcılık B2C ürün 280 sunucu çalıştırır ("ne alaka"). 20.000 kullanıcıya bir sunucu
  derseniz bir sunucu ayda $3.000 tutar (yine "ne alaka"). Fark, faturanın makine dışı kısmıdır (kaynaksız, model bilgisi).

#### 2.2.3 Fiyat
**Bugünkü durum** (bot, 101. hafta, A öncesi; C_PLAN §4.2):
- Sunucu faturası MRR'ın yaklaşık %3'ü (B2B $5.642 / $181.790; B2C $4.662 / $159.152).
- Ayrı "servis gideri" kalemi MRR'ın %30-37'si (B2B hesap başına $45 ve koltuk başına $8; B2C 1.000 kullanıcı başına $700).
- Toplam %33-40.

**Gerçek dünya** (R6 §2.5):
- a16z ve Bessemer birleşimiyle (hesap): maliyet kalemi gelirin %28-35'i, bunun yaklaşık yarısı bulut. Bulut payı gelirin
  %14-17'si.
- Wring rehberi (satıcı blogu, doğrulanmamış): düşük hesaplı SaaS %8-15, standart B2B %12-20.

**Sonuç:** Sektörden biri sunucu satırına "ne alaka" der (gelirin %3'ü çok ucuz), ama toplam gider gerçekçidir. Sorun
bölüşümdedir; toplam doğrudur.

**Öneri:**
- Standart'ta sunucu payı gelirin yaklaşık %8'ine çıkar. Bu, bandın alt ucudur; servis gideri ayrıca durduğu için yeterlidir.
- Aynı tutar servis giderinden düşülür. Standart'ta toplam gider bayt bayt aynı kalır, runway ve tur kalibrasyonu bozulmaz.
- Kademe oranı 1 : 2 : 4 (bugün 1 : 1,6 : 2,4). Dayanak: Heroku'da paylaşımlıdan ayrılmışa 10 kat (R6 §2.5); Google SRE "her
  ek güvenilirlik basamağı öncekinden çok pahalı"; R6 §5 Kurumsal için 2,5-4 kat önerir. Oyun hissi için yumuşatıldı.
- (inceleme) R6 §5 B2B fiyatını "büyük ölçüde koruyun", yalnız B2C'yi 4-8 kat artırın der; R6 bunu birim fiyatın koltuk
  ücretine oranından hesaplar. Bu belge B2B'yi de artırır, çünkü botun 101. haftasında B2B faturası da gelirin yaklaşık
  %3'üdür ve hesaplarımız KOBİ ile orta ölçek arasındadır (wring: orta ölçekte müşteri başına gelirin %3-10'u, R6 §2.5).
  Bu ayrılık bilinçlidir ve Soru 3'e girer.

| [ÇALIŞMA] | Ekonomik | Standart | Kurumsal |
|---|---|---|---|
| B2C, 1.000 kullanıcı başına ayda | $75 (bugün $35) | $150 (bugün $55) | $300 (bugün $85) |
| B2B, 50 koltuk başına ayda | $60 (bugün $30) | $120 (bugün $45) | $240 (bugün $70) |
| Gelir payı (101. hafta, hesap) | ~%4 | ~%8 | ~%16 |
| Servis gideri (Standart'taki artış kadar düşer) | B2C 1.000 kullanıcı başına $700 → $605; B2B koltuk başına $8 → $6,5; hesap başına $45 değişmez | | |

Etkisi:
- Ekonomik bugünden biraz ucuzlar, Kurumsal belirgin pahalılaşır. Kademe farkı ilk kez bir para kararıdır.
- Kurumsal'a geçmek B2B ürünün bütün faturasını ikiye katlar. 3★ hesabın maddesi için geçiş artık düşünülecek bir
  karardır: 3★ hesapların getirdiği gelir, faturadaki artışla karşılaştırılır. İlk 3★ hesap geldiğinde ürün küçük olduğu
  için geçiş ucuzdur; 300 hesapta pahalıdır. Oran kuralı olduğu için bu karar ölçekle kendiliğinden değişir.
- Ölçek indirimi ayrıca kurulmaz. Gerçekte büyük şirkette altyapı payı düşer (R6 §5, wring: tohumda %20-35, halka açıkta
  %8-12). Oyundaki karşılığı bugünkü Ar-Ge düğümüdür (ölçeklenebilir arka uç yük bölenini artırır); o kalır.
- B2C fiyat artışı pazaryeri ekonomisini etkiler. E bunu kendi ölçümünde görmelidir (§3).

#### 2.2.4 Doluluğun gösterimi
- Sunucu bloğunda tek satır: "Yük %86". %90 üstünde sarı, %100 üstünde kırmızı (renk tokenleri, renk körü ikizi helper'da).
- İpucu, Ekonomik'te: "Yük %94 · Kapasite ay başında büyür · %90'ı geçince kesinti olasılığı ×1,5, %100'ü geçince ×2,5".
- İpucu, Standart'ta: "Kapasite her hafta yüke göre büyür ve küçülür".
- Dayanak: Startup Company tek kadran ve gecikme sayısı gösterir (R2 §7.7 görüntü 2: "Server Usage %39", "Response Time
  204ms"). Biz gecikmeyi değil sonucu (kesinti olasılığı) yazarız, çünkü gecikmenin oyunda başka karşılığı yoktur.

#### 2.2.5 Kesinti çarpanı
Çarpanın tek evi B'nin olay ayarıdır; C'nin ipucu oradan okur, sayı kopyalanmaz. Olay modeli B0'dandır
(`b_taslak/B0_ESIKLER.md` §4): haftalık olasılık = 0,10 × kademe × açık hata çarpanı, iki olay arasında en az 4 hafta, v1.0'dan
3 hafta sonra başlar. Aşağıdaki sayılar bu modelle 80 canlı haftalık bir koşuda benim simülasyonumdur (hesap, 20.000 koşu).
"Hata tavanda" A'dan sonraki bot gerçeğidir (açık hata çarpanı çoğu hafta tavanda, B0 §4); "az hata" titiz oyuncudur.

| Seçenek | Ekonomik | Standart | Kurumsal |
|---|---|---|---|
| Bugün B'de (1,5 / 1,0 / 0,6) | 14,3 olay · ort. 5,6 hafta arayla | 11,6 · 6,8 | 8,3 · 9,1 |
| Erdem (1,0 / 0,8 / 0,5) | 11,6 · 6,8 | 10,1 · 7,7 | 7,3 · 10,2 |
| Erdem (1,0 / 0,8 / 0,4) | 11,6 · 6,8 | 10,1 · 7,7 | 6,2 · 11,6 |
| R6 (1,0 / 0,4 / 0,15) | 11,6 · 6,8 | 6,2 · 11,7 | 2,7 · 19,3 |
| **Öneri (1,0 / 0,5 / 0,25)** | **11,5 · 6,8** | **7,3 · 10,2** | **4,2 · 15,3** |
| Öneri, az hata | 8,3 · 9,1 | 4,9 · 13,8 | 2,7 · 19,2 |

Oyun hissi:
- **Erdem'in sayıları:** Ekonomik'ten Standart'a geçen oyuncu 104 haftada yalnız 1,5 olay az görür; ortalama aralık 6,8'den
  7,7 haftaya çıkar. Fark hissedilmez. R6 §5 de aynı şeyi söyler: %20 azalma gerçekte neredeyse fark değildir. Kurumsal'daki
  0,5 ya da 0,4 ise hissedilir. Olumlu yanı: Ekonomik 1,0 tabanı, B0'ın bulduğu "Ekonomik koşu başına 14-15 olayla bandın
  üstünde" sorununu çözer.
- **R6'nın sayıları:** Gerçeğe en yakın (SLA kademeleri arasında 5 ile 10 kat, Heroku Postgres'te kademe başına 4 kat; R6
  §2.5). Ama Kurumsal'da 19 haftada bir olay kalır. B2B'de olayların %95'i kesintidir (B0 §4) ve 3★ maddesi oyuncuyu geç
  oyunda Kurumsal'a iter. Sonuç: B'nin B2B içeriği satın alınabilir bir "kapat" düğmesine döner ve B'nin koşu başına 4-14 olay
  bandının altına düşer.
- **Öneri 1,0 / 0,5 / 0,25:** Her basamak olayları yaklaşık %35-40 azaltır; oyuncu farkı hisseder. Kurumsal B'nin bandının
  alt ucunda kalır. Kademe farkının kalanı yükten gelir: Ekonomik'te yük sürekli %90 üstündeyse olay sayısı 14'e, %100
  üstündeyse 17'ye çıkar (aynı simülasyon). Kademe farkı sabitle değil büyümeyle açılır.
- (inceleme) Bu simülasyon B0'ın haftalık olasılık tavanını (0,6) kullanır. B0v aynı tavanı 0,30'a indirmeyi önerdi (onay
  bekliyor, `B0_ESIKLER.md` §6). O kabul edilirse açık hata tavandayken Ekonomik'in olasılığı zaten 0,25'tir ve yük
  çarpanı onu en çok 0,30'a taşır: yükün etkisi hata yığan oyuncuda kesilir, az hatalı oyuncuda görünür. 17 olay B'nin
  koşu başına 4-14 bandının dışındadır; tavan bunu sınırlar. Yük çarpanının yalnız kesinti türüne mi, bütün acil durumlara
  mı uygulanacağı B'nin kararıdır; öneri yalnız kesinti, çünkü ay sonu kapanışı ya da ödeme hatası sunucu yükünden doğmaz.
- **B'ye ek öneri:** Kurumsal yedekli çalıştığı için kesinti süresi de kısa olsun (örnek ×0,5). B'nin B2B kredisi süreye
  göre %10-25 olduğundan Kurumsal'daki kesinti alt kademeden kredi yazar. R6 §5 "kesinti süresi ayrıca kısalsın" der. Bu,
  B'nin kararıdır.
- B'ye ara not olarak giden Erdem sayıları [onay bekliyor] durumundadır; bu tablo o notun yerine geçmeye adaydır (Soru 2).

#### 2.2.6 Sunucu bloğu ve kademe ipucu
```
┌ SUNUCU ──────────────────────────────┐
│ [Ekonomik │ Standart │ Kurumsal]     │
│ Ayda $15.000 · 5.190 koltuk          │
│ Yük %78                              │
│ Kurumsal sunucu bekleyen 1 hesap     │   ← maddesi açık hesap varsa
└──────────────────────────────────────┘
```
B2C'de ikinci satır "Ayda $12.750 · 85.000 kullanıcı" olur, madde satırı çizilmez.
Kademe ipucu (Standart örneği, B2B):
```
Standart
50 koltuk başına ayda $120
Kapasite her hafta yüke göre büyür ve küçülür
Kesinti olasılığı ×0,5
Kurumsal sözleşme şartını karşılamaz
```
Kademe değiştirme önizlemesi değişmedi (C_PLAN §2.3: "Standart → Kurumsal · ayda $15.000 → $30.000 [Geç] [Vazgeç]").
Kurumsal'dan inerken maddeli hesap varsa önizleme olgu satırı ekler: "2 hesabın sözleşmesindeki sunucu maddesi karşılanmaz
olur." Değişmedi.

### 2.3 Kurumsal sunucu maddesi
**Erdem'in kararı (17 Ekim):** 3★ ve üstü hesap imzalanır, şart sözleşmeye yazılır, belli bir süre içinde Kurumsal'a
geçilmezse müşterinin fesih hakkı doğar. Sürenin değeri ("iki ay") örnektir.

**Gerçek pratik** (R7 §2.2): Esaslı ihlalde standart, yazılı bildirimden sonra 30 günlük düzeltme süresidir (Salesforce
MSA 11.3, ikincil alıntı). Barındırma şartına özgü gerçek sözleşme örneği bulunamadı. En yakın mekanik SLA kredisi ve
"kronik ihlal" fesih hakkıdır (örnek: 9 ayın 3'ünde kötü performans). Erdem'in iki ayı bunun oyunlaştırılmış hâlidir.

**Önerilen akış**
1. **Pazarlık onay şeridi:** "Sözleşme maddesi: kurumsal sunucu · 8 hafta içinde · ayda $15.000 fazla". Yalnız 3★ ve üstü
   hesapta ve kademe Kurumsal değilken. Değişmedi, yalnız süre eklendi.
2. **İmza:** Toplantı çıkışında düğme ya da (satış masasının kapattığı anlaşmada) müşterinin bilgi işlem sorumlusundan
   mail. Değişmedi (C_PLAN §2.4); mail süreyi tarihle yazar.
3. **Süre:** 8 hafta [ÇALIŞMA]. Tabloda Durum: "Sunucu maddesi · 12 Mar". Genel Bakış'ta "Kurumsal sunucu bekleyen 1 hesap".
   Hatırlatma maili yok.
4. **Süre dolunca** müşteri hakkını şu kurala göre kullanır (zarsız, görünür sayılardan):
   - Memnuniyeti eşiğinin 20 puandan az üstündeyse [ÇALIŞMA]: **fesih bildirimi** gönderir. Sözleşme 4 hafta sonra biter
     (R7'deki 30 günlük bildirim süresinin oyun karşılığı). Bu 4 hafta içinde Kurumsal'a geçilirse bildirim geri alınır.
     Durum: "Fesih bildirimi · 9 Nis".
   - Memnuniyeti eşiğinin en az 20 puan üstündeyse: feshetmez, hakkını saklı tutar. Memnuniyet hedefine "Kurumsal sunucu
     maddesi −10" terimi girer [ÇALIŞMA] ve ipucunda görünür. Her ay başında aynı kural yeniden işler. Yenilemede hesabın
     tutumu en iyi ihtimalle "indirim ister" olur (§2.6.1): müşteri açık maddeyi pazarlıkta koz yapar.
   - (inceleme) Terim birikmez: madde açık kaldıkça −10'dur, her ay yeniden eklenmez. Yeni müşteri tabanının (§2.5.1)
     üstüne yazılır, güven defteri gibi; tabanın içinde eriyip kaybolmaz.
   - Gerekçe: Fesih hakkının ilişki zayıfken kullanıldığı, memnun müşterinin onu pazarlıkta koz yaptığı R7 §6'nın tasarım
     önerisidir; gerçek pratikten ölçülmüş bir bulgu değildir (inceleme). Zar yoktur; oyuncu tablodaki memnuniyet ve
     ipucundaki eşikle sonucu önceden okur.
   - Sonuç: Hiç geçmeyen oyuncu yeni bir 3★ hesabı (8. haftada memnuniyet örneğin 60, eşik 36, fark 24) yaklaşık 4 ayda
     kaybeder: 8 hafta süre, saklı hak ve −10, bir sonraki ay başında fark 20'nin altında olduğu için bildirim, sonra 4
     hafta. Çok memnun hesap (fark 30 ve üstü) hakkını saklı tutarak kalır. Erken davranan hiçbir şey kaybetmez. (inceleme:
     örnek 70 başlangıcından değil 8. haftanın memnuniyetinden hesaplandı, §2.5.1)
5. **Kurumsal'dan inilirse** maddeli hesapların süresi yeniden 8 haftadan başlar.
6. Güvenlik sertifikası araştırması maddeyi karşılamaz; madde sunucu kademesidir. Değişmedi.

Fesih bildirimi maili (taslak, metin onay bekliyor):
```
Gönderen: Deniz Aras · Kuzey Lojistik, Bilgi İşlem
Konu: Sözleşmedeki sunucu maddesi

Sözleşmemizdeki kurumsal sunucu maddesi 12 Mart'tan beri karşılanmıyor. Bu yüzden
sözleşmemizi 9 Nisan'da sonlandırıyoruz. O tarihe kadar verilerimiz kurumsal sunucuya
taşınırsa kararımızı geri alırız.

                         [Kurumsal sunucuya geç · ayda $15.000 → $30.000]
```
Hakkını saklı tutan müşterinin maili: "Sözleşmemizdeki kurumsal sunucu maddesi hâlâ karşılanmıyor. Şimdilik devam
ediyoruz, ancak sözleşmeyi feshetme hakkımızı saklı tutuyoruz." Aynı düğme.

### 2.4 Satış · HESAPLAR tablosu
**Değişmedi** (C_PLAN §2.5): ADAYLAR | HESAPLAR kâğıtları, sütunlar (Firma ★, Koltuk, Aylık, Memnuniyet, Durum, Yenileme,
İstek, Temsilci), Satışçı Yenileme ipucunda, "İlgilen" yalnız Ayrılabilir ve Yenilemeyebilir satırlarında, başlık ve alt
toplam satırı sabit, kaydırma çubuğu hep görünür, "Onboarding", "Risk", "Büyümeye açık", hafta sayısı yok.

#### 2.4.1 Durum sütunu
| Etiket | Ne zaman | Değişti mi |
|---|---|---|
| Ayrılabilir | Memnuniyet eşiğin altında | Değişmedi |
| Yenilemeyebilir | Yenileme dönemi içinde (bitişe 8 hafta ya da daha az) ve memnuniyeti eşiğinin 12 puandan az üstünde (iknasız tutum "indirim ister" ya da daha kötü, §2.6.1). (inceleme) Etiket yalnız görünür iki sayıdan türer, görüşmeyi yapanın iknasını katmaz; kurucu yolunda tutumu açık etmez. | Tanım tutuma bağlandı |
| Yenilemeyecek · Mar | Yenileme kaybedildi; sözleşme sonunda ayrılır | Değişmedi |
| Sunucu maddesi · 12 Mar | Kurumsal madde açık; tarih sürenin sonu | Yeni |
| Fesih bildirimi · 9 Nis | Müşteri maddeye dayanıp fesih bildirdi | Yeni |

Yeni iki etiketin gerekçesi: ikisinin de tarihli ve geri alınabilir bir sonucu var. Görünmezse oyuncu 3★ hesabını sağlıklı
sanır. Tek hücrede birden çok olgu olursa en ağırı yazar. (inceleme) "Tablodaki sıra" iki yönlü okunabiliyordu; öneri
sıra: Yenilemeyecek, Fesih bildirimi, Ayrılabilir, Yenilemeyebilir, Sunucu maddesi (kesin ve tarihli kayıp önce, risk
sonra).

#### 2.4.2 Para sütunu: aylık mı, sözleşme bedeli mi
**Öneri: Hücrede aylık (MRR) kalır. Sözleşme bedeli sütun olmaz, ipucuna gider. Toplam MRR alt satırda ve başlıkta.**
- Bütün sözleşmeler 12 aydır. Toplam sözleşme bedeli = 12 × aylık. Sütun olsa sıralamayı hiç değiştirmez, yalnız aynı
  sayıyı 12 ile çarpar.
- Oyunun ortak dili MRR'dır (Erdem'in kararı, 17 Ekim). Satış başlığı, üst bar ve Finans aylık okur.
- R7 §5 de ana sütunu aylık gelir önerir, sözleşme bedelini yan sütun olarak (CRM pratiği, kaynaksız model bilgisi).
  Bu belge onu sütun yerine ipucuna alır (inceleme: R7 "yan bilgi" değil "yan sütun" der).
- Anlamlı olan sözleşme bedeli değil **kalan** sözleşme değeridir. Yenileme hücresinin ipucunda yazar: "Kalan 5 ay ·
  $10.500 · Yenilemeyi Ayşe Kaya yürütür."

#### 2.4.3 Sıralama, görünüm, arama (330 hesap)
**Erdem'in isteği (17 Ekim):** sütun başlığına basınca artan ya da azalan sıralama.

- **Her başlık sıralar.** İlk tık oyuncunun en çok bakacağı yönü verir, ikinci tık tersine çevirir. Etkin sütunun yanında
  ▼ ya da ▲ durur.

| Sütun | İlk tık | Neden bu yön |
|---|---|---|
| Firma | A'dan Z'ye | Ad ile bulma |
| Koltuk | Büyükten küçüğe | En büyük hesaplar |
| Aylık | Büyükten küçüğe | En çok para getiren (Erdem'in örneği) |
| Memnuniyet | Düşükten yükseğe | Kaybedilecek olanlar |
| Durum | En ağır olgu önce | Bakılması gerekenler |
| Yenileme | En yakın tarih önce | Sıradaki yenilemeler |
| İstek | İsteği olanlar önce, istenen değerine göre | Sprint kararı |
| Temsilci | Temsilcisizler önce, sonra ada göre | Atama |

- **Varsayılan sıra** değişmedi: önce durum taşıyanlar, sonra açık sözü olanlar, sonra aylık. "Durum" başlığına tıklamak
  buna döner.
- **Görünümler** (tablonun üstünde tek sıra): Tümü 330 · Durumu olan 7 · Yenilemesi yakın 54 · Temsilcisi olmayan 120.
  "Yenilemesi yakın" bitişe 8 hafta ya da daha az kalan hesaplardır. Bunlar süzgeçtir, öneri değildir; sayıları yazar.
- **Firma araması:** bir olay ya da mail bir firma adı verdiğinde 330 satırda bulmanın tek hızlı yolu. Yazdıkça süzer.
- Sıra ve görünüm pencere kapanıp açılınca hatırlanır; kayda yazılmaz.
- Yıldız süzgeci kurulmaz: Firma sütununda yıldız görünür ve Aylık sıralaması büyük hesapları zaten üste alır.

```
 Tümü 330 │ Durumu olan 7 │ Yenilemesi yakın 54 │ Temsilcisi olmayan 120        [ Firma ara          ]
 FİRMA              KOLTUK  AYLIK ▼  MEMNUNİYET   DURUM                   YENİLEME  İSTEK                 TEMSİLCİ
 Kuzey Lojistik ★★★    60  $2.268   66 ▮▮▮▮▮▮▮                            Eki 2027  e-Defter dışa aktar   Selin K. [Değiştir]
 Yelken Ofis ★★★       60  $2.100   41 ▮▮▮▮░░░   Sunucu maddesi · 12 Mar  Mar 2027  Toplu fatura onayı    Selin K. [Değiştir] [İlgilen]
 Poyraz Lojistik ★★    32  $1.150   50 ▮▮▮▮▮░░   Yenilemeyebilir          Mar 2027                        [Değiştir]
 ...                                                                                                         ▐
 330 hesap · 5.190 koltuk · ayda $181.790
```

### 2.5 Memnuniyet

#### 2.5.1 Başlangıç ve eşik
- **Erdem'in kararı (17 Ekim):** Yeni hesap 70'ler civarından başlar, 50'den değil.
- **Eşik formülü kalır:** 30 + 3 × (yıldız − 1) + sektör ekinin yarısı (1★ 30, 2★ 33, 3★ 36, en çok 38). (inceleme) Erdem
  formülü andı, itiraz etmedi ve buna bağlı olarak başlangıcın yukarı çekilmesini istedi; formülün kendisi için açık bir
  "kabul" cümlesi yok. Bu yüzden "Erdem'in kararı" değil, itirazsız öneri olarak işaretlendi.
- **Öneri:** İmza memnuniyeti 70 [ÇALIŞMA], her hesapta aynı. Bugün başlangıç "eşik + 10, en az 50"dir, yani hemen her hesap
  50'den başlar.
- **(inceleme) Kod gerçeği, eski gerekçeyi düzeltir.** Memnuniyet hedefine günde en çok 3 puan kayar; haftalık tik yedi
  günü birden işler, yani haftada en çok 21 puan, imzadan sonraki 4 haftada 35 puan (`B2BConstants.SAT_DRIFT_STEP`,
  `ONBOARDING_AMP`). Eski metin "haftada 3 puan" diyordu. Sonuç: 70 başlangıcı ilk tikte hedefe iner, "balayı" oluşmaz.
  Bugün yeni hesabı ilk 4 hafta koruyan tek şey "İlk 4 hafta tabanı"dır (hedef en az eşik + 2). Taban ölü değildir;
  silinirse zayıf v1 döneminde imzalanan hesap ilk haftada eşiğin altına inebilir ve erken kayıp artar.
- **Öneri (inceleme): 70 hedefin tabanına yazılır.** İlk 4 hafta hedefin tabanı eşik + 2 yerine 70'tir [ÇALIŞMA]; sonraki 8
  haftada her hafta eşit adımla hesabın kendi hedefine iner [ÇALIŞMA]. İpucunda tek satır görünür: "Yeni müşteri: en az 70,
  12 Mar'dan sonra azalır". Neden var: Erdem'in istediği yalnız açılış sayısı değil, yeni müşterinin bir süre memnun
  kalmasıdır; kayma hızı bunu ancak hedef üzerinden yapmaya izin verir. Neden sönüm: 4. haftanın sonunda 70'ten hedefe tek
  haftada düşen hesap, oyuncuya nedensiz bir uçurum gibi görünür. Gerçekte de yeni müşterinin ilk 90 günü ayrı ölçülür (R7
  §2.3); sayısal norm bulunamadı, 70 sağlık skorlarının yeşil eşiğine (70-71) denk gelir (R7 §1.5). R7 §5 72-78 arası
  rastgele önerir; sabit seçildi çünkü değer bir taban ve oyuncu onu ipucunda okuyor.
- Ölçek: kural hesap başınadır ve imza tarihine bakar; 1 hesapta da 330 hesapta da aynı çalışır. X (c) seçilirse
  beklentiyi karşılayan üründe ürün terimi zaten 70'tir (X §6.3); taban o zaman yalnız zayıf ürünün imzalarını korur.
- **Alternatif (Soru 6):** kaymayı günde 3 yerine haftada 3 yapmak. O zaman yalnız 70 başlangıcı balayı yaratır ve B'nin
  olay kartlarının memnuniyet etkisi de bir tikte silinmez. Ama A'nın K5 ayarı, B'nin bedelleri ve kayıp hızı baştan
  yeniden ölçülür; C'nin kapsamını aşar.

#### 2.5.2 A'nın "hata churn'ü etkiler" kararı B2B'de hâlâ işliyor mu
**Kısa cevap: Hayır, tek başına değil. Tavan değişmeden eşik ve 70 birlikte gelirse B2B'de hata ayrılmaya hiç yol açmaz.**

A'nın ölçümü (`a_calisma/K5_OLCUM.md`, bugünkü eşikle, 104 hafta):

| B2B kolu | Erken kayıp | Geç kayıp | Toplam |
|---|---|---|---|
| Hiç düzeltmeyen (tohum 7 / 11) | 26 / 22 hesap | 36 / 57 hesap | %17,6 / %22,5 |
| En kötüsünü düzelten | 16 / 23 | 0 / 1 | %4,6 / %6,8 |
| Hata bedeli kapalı | 11 / 14 | 2 / 1 | %3,8 / %4,3 |

Mekanizma: hesabın hedefi = ürün terimi − (kullandığı hatlardaki açık hata × 0,3, en çok 20) + güven defteri. Geç dönemde
memnuniyet 59-67 bandında (C_PLAN §2.11, A öncesi). Hiç düzeltmeyen kolun geç dönemde 189 açık hatası var (K5 b1), ceza
tavanda: hedef 39-47.
- Bugünkü eşikte (33 / 42 / 51) bu 2★ ve 3★ hesapları eşiğin altına iter: kayıp gerçekleşir.
- Yeni eşikte (30 / 33 / 36, en çok 38) 39-47 her eşiğin üstündedir: **geç kayıp sıfıra iner.**
- Erken kayıplar (bütün kollarda %19-44, zayıf v1 dönemi) yeni eşik ve 70'lik sönümlü tabanla azalır. (inceleme) Eski
  metin bunu yalnız 70 başlangıcına bağlıyordu; başlangıç ilk tikte silindiği için azalmayı taban yapar (§2.5.1). Taban
  12 hafta sürdüğü için zayıf v1'in kaybı ertelenir, tamamen kalkmaz. Bu istenen bir sonuçtur, ama A'nın kolları arasındaki
  erken farkı da küçültür.

**Öneri:** Eşik ve başlangıçla aynı değişiklikte A'nın ceza tavanı 20'den 40'a çıkar [ÇALIŞMA]; hata başına 0,3 değişmez.
- Neden 40: hiç düzeltilmeyen ürün en iyi ürün terimindeki hesabı bile eşiğin altına itebilmeli. 67 − 40 = 27, en düşük
  eşik olan 30'un altında.
- Düzelten oyuncu etkilenmez: en kötüsünü düzelten kolun geç dönem medyanı 10 açık hata, ceza 3 puan.
- Arada kalan oyuncu (40-60 açık hata, 12-18 puan) hesap kaybetmez ama yenilemede "aynı fiyat" ya da "indirim ister"
  tutumuna iner (§2.6.1). Hata artık iki katmanda bedel öder: hafif ihmal fiyattan, ağır ihmal hesaptan.
- Ölçek uyarısı (Erdem'in 1-50 kişi kuralı): ceza açık hata **adedine** bağlıdır. Ekip 50 kişiye çıkınca açık hata da
  büyüyorsa ceza ölçekte kırılır. Bu A'nın modelidir; C yalnız tavanı önerir. Kapıya büyük ekip kolu D gelince eklenir.
  (inceleme) D_MODEL_v2 §5'in ön hesabı düzenli düzelten 50 kişilik ekipte açık hata medyanını 19 bulur: ceza 6 puan,
  tavanın çok altında; kırılma riski düzeltmeyen büyük ekiptedir ve orada ceza zaten tavana dayanır.
- (inceleme) X (c) seçilirse ürün terimi beklentiyi karşılayan üründe 70 olur (X §6.3) ve "hangi hesap hangi hatta bakar"
  kuralı değişir (X §6.5). 70 − 40 = 30, en düşük eşiğe eşittir; tavan 40 o modelde de iş görür ama §4.1 kapısı X'ten
  sonra yeniden koşulur.
- ORTAK gereği eşik değişikliği, A'nın cezasının ayarıyla aynı commit'te girer. Kapı §4.1'dedir.

#### 2.5.3 Memnuniyet ipucu
**Erdem'in kararı (17 Ekim):** nedenleri yazan ipucu kalır.

Terimler (hedefin toplamı; ekran kendi hesabını yapmaz):
```
Memnuniyet 41, hedef 38
  Ürün kararlılığı                          58      ← eksen kararına bağlı, aşağıda
  Kullandığı hatlarda açık hata            −12
  Söz ve kesintiler (Stok K2 kaçtı)         −8
Ayrılma eşiği 36
```
- (inceleme) "İlk 4 hafta tabanı" satırı kalkmaz, "Yeni müşteri: en az 70, 12 Mar'dan sonra azalır" olur ve yalnız taban
  işlerken çıkar (§2.5.1). "Kurumsal sunucu maddesi −10" yalnız hakkı saklı tutan hesapta çıkar (§2.3). Yenilemede
  yazılan "Gönülsüz yenileme" ve "Zam" terimleri (§2.6.1) bir sonraki yenilemeye kadar görünür.
- (inceleme) Terim listesi X §8.2'deki tek fonksiyondan gelir; ilk terimin etiketi ("Ürün kararlılığı" ya da "Ürün
  uyumu") C'de sabitlenmez.
- **"Ürün kararlılığı" satırı** (Erdem: "oyuncu hiçbir yerde görmüyor"):
  - Eksenler kalır ve Ürün penceresinde görünür olursa: satır aynen kalır; adı ve değeri Ürün penceresinde görülenle aynı.
  - Eksenler kalkarsa: hedefin taban terimi X'in koyacağı ürün ölçüsünden okunur ve satır o ölçünün adını taşır. Tek koşul:
    o ölçü Ürün penceresinde de görünmeli. Oyuncunun başka yerde göremediği bir terim ipucuna yazılmaz.
  - İki hâlde de C yalnız terimin adını ve değerini çizer; terimi X sağlar.

### 2.6 Sözleşme yenileme

#### 2.6.1 Temel model: yenileme tutumu
**Bilinçli kararlar** (inceleme: üçü de öneridir, Erdem'in kararı değil)
- **Sonuç zarsız ve yıldız karşılaştırmasız.** Eski "görüşen hesaptan bir yıldız yüksekse %8, eşitse %5" tablosu kalkar.
  Zarsız: sonucu şans değil, oyuncunun gördüğü memnuniyet ve eşik belirler.
- **"Artık sizi kullanmak istemiyoruz" diyen müşteri vardır.** Gerçekte B2B ayrılması böyle olur: sözleşme kendiliğinden
  yenilenir, müşteri bitişten önce yenilememe bildirimi verir (R7 §1.4; Salesforce 30 gün, alıcı rehberleri 90-120 gün).
  Gerçek yıllık kayıp hesabın büyüklüğüne göre %2 ile %14 arasıdır (R7 §2.1); bu kapıda ölçü olarak kullanılır (§4.3).
- **Sözleşme ortasında ayrılma ("Ayrılabilir") kalır.** Gerçekte 12 aylık sözleşmeden ortada çıkmak yalnız esaslı ihlalle
  olur (R7 §2.2). Oyunda bu, ürün kötüleşince (eşiğin altı) hızlı geri bildirimdir; yalnız yenilemeye bağlansa oyuncu
  hatanın bedelini bir yıl sonra görürdü. Ayrım: ağır memnuniyetsizlik ortada, hafif memnuniyetsizlik yenilemede bedel öder.

**Tutum** (her hesap için, yenileme dönemi açılınca):
- Fark = memnuniyet − hesabın ayrılma eşiği. İkisi de oyuncunun gördüğü sayılardır (tablo ve ipucu).
- Görüşmeyi yapanın Satış yıldızı ikna eder: farka (yıldız − 1) × 2 puan eklenir, en az 0 [ÇALIŞMA]. Kurucu yolunda
  kurucunun Satış yıldızı sayılır. Bu yetenek kuralıdır, karşılaştırma değildir. (inceleme) Satış becerisi bugün kurucuda
  ve çalışanda vardır ve kurucuda 0★ olabilir; "en az 0" eklenmeseydi 0★ kurucu farkı 2 puan düşürürdü. D_MODEL_v2 Satış'ı
  modellemez; kural bugünkü beceriyi okur. Yarım yıldız yarım adım verir (2,5★ +3).

| Fark (iknayla) [ÇALIŞMA] | Tutum | Kabul ettiği en iyi fiyat |
|---|---|---|
| 25 ve üstü | Zamma açık | %8 zam |
| 12-24 | Aynı fiyat ister | Aynı fiyat |
| 5-11 | İndirim ister | %10 indirim |
| 0-4 | Ayrılmayı düşünüyor | %15 indirim |
| 0'ın altı | Yenilemeyecek | Kurtarılamaz |

- **Basamak kuralı (teklif tutumun üstündeyse):** Basamaklar +%8, aynı, −%10, −%15. Teklif kabul edilen fiyattan bir
  basamak yüksekse müşteri gönülsüz kabul eder ve hedefine "Gönülsüz yenileme −6" yazılır [ÇALIŞMA]. İki ya da daha çok
  basamak yüksekse yenilemez. (inceleme) Kurucu yolunda ilk teklif bu kurala girmez: tutumunun üstünde teklif alan müşteri
  önce karşı teklif verir (kendi en iyi fiyatı); basamak kuralı karşı teklif kâğıdının cevabında işler (§2.6.4).
  "Yenilemeyecek" tutumundaki müşteri karşı teklif vermez. Satışçı yolunda karşı teklif turu yoktur, kural rapordaki
  seçimde işler.
- **Zam kabul edilince** hedefe "Zam −2" yazılır [ÇALIŞMA]: fiyat artışı ilişkiyi biraz yorar (R7 §2.1: fiyat, ayrılma
  nedenlerinin %11-26'sı). Zam bedava değildir; gelecek yılın tutumunu bir parça aşağı çeker.
- (inceleme) Eski metin bu iki bedeli güven defterine yazıyordu. Güven defteri tik başına 2,8 puan affeder
  (`TRUST_OFFSET_DECAY_PER_DAY` 0,4 × 7): −2 bir haftada, −6 iki haftada silinir ve "gelecek yılın tutumu" iddiası
  tutmazdı. Öneri: ikisi de hedefte, bir sonraki yenilemeye kadar sabit duran ve ipucunda görünen terimdir; yenilemede
  silinir, birikmez.
- Zam ve indirim koltuk fiyatına da işler (değişmedi).
- Neden bu bantlar: Erdem'in sevdiği üç seçenek (%8, aynı, %10) birebir basamaktır; %15 "son şans" basamağıdır. Bantlar
  hesabın kendi eşiğine görelidir; 1 hesapta da 330 hesapta da aynı çalışır. Sınırlar [ÇALIŞMA]; bot dağılımıyla ayarlanır.
- Gerçeklik notu: müzakerede gerçekleşen zam, istenenin %40-60'ıdır ve tavansız sözleşmede yıllık artış %8-12'dir (R7
  §2.1, satıcı ve danışman iddiası). %8 bu bandın alt ucudur; ikna kuralı gerçekleşme payının oyun karşılığıdır.
- **(inceleme) "Kimse ayrılmıyor" sorusu ne kadar çözüldü.** Bu modelde yenilemede ayrılan üç tür hesap vardır: ürünü
  kötüleşmiş olan (fark 0'ın altı), tutumunun iki basamak üstünde teklif alan ve "ayrılmayı düşünüyor"ken indirim
  verilmeyen. Bakımlı üründe geç dönem memnuniyeti eşiğin 20-35 puan üstündedir; bu oyuncuda yenilemede ayrılan neredeyse
  olmaz. Gerçekte ürün iyi olsa da hesapların bir kısmı bütçe, kapanma ya da değişen ihtiyaç yüzünden yenilemez (R7 §2.1:
  gönüllü iptal nedenleri arasında değişen ihtiyaç %28, rakibe geçiş %14, kapanma ve bütçe %8; yıllık kayıp KOBİ'de
  %10-14). Ürün dışı neden bu modelde yoktur.
  Erdem "gerek de yok" dedi ama "düşünülmeyen alan kalmasın" istedi; açık bırakıldı, §4.3 ölçer, Soru 5 sorar.
- Tutumun gösterimi: sayı ya da olasılık değil, söz (R7 §8.1: Startup Company karşı tarafın sabrını yüz ifadesiyle
  gösterir; FM tutum göstergesiyle). Bizde satışçının raporundaki cümle ve müşterinin cevabıdır.

**Takvim:** Her ayın ilk haftası, sözleşmesi iki ay sonra biten hesaplar toplanır (bitişe yaklaşık 8 hafta; R7 §5 60 gün
önerir). Teklif o hafta gider, cevap ertesi hafta gelir, yeni fiyat sözleşme bitişinde işler. "Yenilemeyecek" hesap bitişe
kadar öder ve sonra ayrılır.

#### 2.6.2 Akış seçenekleri
| | A · Soru kâğıdı (eski) | B · Satışçı raporu (öneri) | C · Hesap hesap mail müzakeresi |
|---|---|---|---|
| Kurgu | Satışçı sorar: "Fiyatı artıralım mı?" Kurucu politika seçer, sonuç sonra gelir. | Satışçı görüşür ve rapor getirir: "Bu zam kabul eder, bu indirim istiyor, bu yenilemeyecek." Kurucu raporu onaylar ya da tek bir noktada değiştirir. | Kurucu her hesaba ayrı teklif gönderir, her müşteri ayrı cevaplar. |
| Dayanak | Eski C_PLAN §2.6 | R7 §6 Alternatif A ve C; FM'de oyunun teklif önermesi | R7 §6 Alternatif B; FM teklif, tutum, yeniden müzakere; Startup Company müzakere ekranı (R2 §7.7 görüntü 7) |
| Artısı | Kısa | Oyuncu kararı bilgiyle verir; 330 hesapta da tek kâğıt | En çok müzakere hissi |
| Eksisi | Oyuncu körlemesine karar verir; sonucu zar ya da gizli tablo belirler | Rapor "Tamam" düğmesine dönebilir; bu yüzden seçenekler gruba göre değişir | Ayda 27 yenilemede 27 mail; 330 hesapta yapılamaz |

**Öneri: B, satışçı yolunda. C'nin hafifletilmiş hâli kurucu yolunda** (grup teklifi, tek cevap maili, tek karşı teklif
turu). İkisi aynı tutum modelini kullanır; fark bilgidedir. Satışçı tutumları önceden bilir; kurucu onları müşterinin
cevabından öğrenir.

**Satışçının değeri** (oyuncunun satışçı tutması için gerçek bir neden): tutumları önceden söyler, yani körlemesine teklif ve
karşı teklif turu olmaz; ikna eder (yıldızı farkı büyütür); rutin aylarda kurucunun önüne kâğıt koymaz (§2.6.5).

#### 2.6.3 Satışçı yolu (önerilen akış, adım adım)
Hesabın satışçısı Satış işinde çalışıyorsa bu yol işler. Birden çok satışçı varsa bütün satışçı hesapları tek raporda
toplanır, gönderen en yüksek yıldızlı satışçıdır; ikna her hesabın kendi satışçısının yıldızıyla hesaplanır. Ölçekte de ayda
tek kâğıttır.

Örnek: Ayşe Kaya Satış 3★ (ikna +4). Koltuk fiyatı ayda $35.

| Firma | Aylık | Memnuniyet / eşik | Fark + ikna | Tutum |
|---|---|---|---|---|
| Kuzey Lojistik ★★★ | $2.100 | 66 / 36 | 34 | Zamma açık |
| Lale Klinik ★★ | $840 | 64 / 35 | 33 | Zamma açık |
| Nehir Tekstil ★ | $420 | 61 / 30 | 35 | Zamma açık |
| Poyraz Lojistik ★★ | $1.120 | 50 / 33 | 21 | Aynı fiyat |
| Yelken Ofis ★★★ | $2.100 | 41 / 36 | 9 | İndirim ister (%10) |
| Doruk İnşaat ★★ | $700 | 33 / 35 | 2 | Ayrılmayı düşünüyor (%15) |
| Ege Gıda ★ | $350 | 24 / 30 | −2 | Yenilemeyecek |

1. **Ay başı:** Ayşe görüşmeleri yapar. Masa hesap başına 0,25 hafta dolar [ÇALIŞMA]. Görüşme sayısı masanın ayını aşarsa
   artan hesaplar kurucu yoluna düşer ve rapor bunu söyler. Gerekçe: satışçının yenileme yükü yeni satışla yarışır, hesap
   sayısıyla ölçeklenir; çok hesap daha çok satışçı ister.
   - (inceleme) Ölçek hesabı: 330 hesapta ayda yaklaşık 27 yenileme, yani 6,9 haftalık masa; bir satışçının ayı yaklaşık
     4,3 haftadır. Bu sayıda iki satışçı yalnız yenileme yapar ve yeni satış durur. 0,25 hafta her hesapta aynıdır; 1★
     küçük hesapla 3★ hesap aynı emeği ister. Bu sabit büyük ölçekte kırılmaya en açık kuraldır; §4.3 ölçer, sonuç
     Erdem'e gider.
2. **Rapor (karar kâğıdı)** ertesi gün gelir:
```
Gönderen: Ayşe Kaya · Satış 3★
Konu: Mart yenilemeleri

Mart'ta yedi sözleşme bitiyor, hepsiyle görüştüm.
%8 zamla devam ediyorlar: Kuzey Lojistik, Lale Klinik, Nehir Tekstil.
Aynı fiyattan devam etmek istiyor: Poyraz Lojistik.
%10 indirim istiyor: Yelken Ofis.
%15 indirim olursa kalıyor: Doruk İnşaat.
Yenilemeyecek: Ege Gıda. Sözleşmesi Mart sonunda bitiyor.

1  Konuştuğun gibi yenile                       Zam ayda +$269 · indirim ayda −$315
                                                 · Ege Gıda ayrılır
2  İndirim isteyenlere aynı fiyatı teklif et     Zam ayda +$269 · Yelken Ofis ile ilişki gerilir
                                                 · Doruk İnşaat ve Ege Gıda ayrılır
```
   - Çipteki sonuç önceden kesindir; tutum ve basamak kuralı zarsız olduğu için. 1. seçenek: zam +$269, indirim −$315 (Yelken $210,
     Doruk $105); Ege'nin $350'si her iki seçenekte gider. 2. seçenek: Yelken bir basamak yukarıda gönülsüz kabul
     eder (güven −6), Doruk iki basamak yukarıda yenilemez ve $700'ü gider. Bu ayda 1 daha iyidir; Doruk daha küçük
     bir hesap olsaydı 2 daha iyi olurdu.
   - Her seçenek bir durumda en iyisidir: 1, ayrılmayı düşünen hesaplar değerliyse; 2, indirim isteyenler büyük ve
     ayrılmayı düşünenler küçükse (büyük hesaba indirim verilmez, gönülsüz kalır; küçük hesap gider).
   - Seçenekler gruba göre değişir. İndirim ya da ayrılmayı düşünen hesap yoksa kâğıt hiç gelmez (§2.6.5).
3. **Cevapsız kalırsa** (2 hafta): Erdem'in kararı (17 Ekim), aynı fiyat. Herkese aynı fiyat teklif edilir; basamak kuralı
   işler (zamma açıklar aynı fiyattan yeniler, indirim isteyen gönülsüz kalır, ayrılmayı düşünen ayrılır).
4. **Sonuç maili** sözleşmeler yenilenince (değişmedi biçim, C_PLAN §2.6): Firma · Eski · Yeni · Değişim; yenilemeyenler
   "Yenilemeyecek. Sözleşmesi Mart ayında bitiyor." Rapordan sonra sürpriz yoktur, mail yalnız kayıttır.

#### 2.6.4 Kurucu yolu (satışçı yok)
**Erdem'in kararı (17 Ekim):** kurucuya kâğıt gelir. **Erdem'in isteği:** saat bedeli yok ya da çok az, mailden teklif,
belki karşı teklif. **Öneri:** kurucu saati yazılmaz. Bedel, körlemesine teklifin riskidir.

1. **Ay başı, kâğıt** (kurucunun notu):
```
Konu: Mart'ta biten sözleşmeler

Şu müşterilerle sözleşmemiz Mart ayında bitiyor. Yenileme tekliflerini bu hafta göndermemiz gerekiyor.

  Kuzey Lojistik ★★★   ayda $2.100   memnuniyet 66 · eşik 36
  Poyraz Lojistik ★★   ayda $1.120   memnuniyet 50 · eşik 33
  Yelken Ofis ★★★      ayda $2.100   memnuniyet 41 · eşik 36   Yenilemeyebilir
  Ege Gıda ★           ayda $350     memnuniyet 24 · eşik 30   Ayrılabilir

1  Hepsine %8 zamlı yenileme teklifi gönder
2  Hepsine aynı fiyatla yenileme teklifi gönder
3  Yenilemeyebilir olanlara %10 indirim, ötekilere aynı fiyat teklif et
```
   - Kurucu tutumları görmez ama memnuniyeti ve eşiği görür; kararını bu sayılardan verir. Satışçının sağladığı bilgi
     budur.
   - Gövde en çok 6 satır hesap yazar; fazlası tek satırdır: "Diğer 21 hesabın hepsi eşiğinin en az 12 puan üstünde."
   - (inceleme) Bu kâğıt 2 hafta içinde cevapsız kalırsa herkese aynı fiyat teklifi gider ve akış sürer: cevaplar maili ve
     gerekirse karşı teklif kâğıdı yine gelir. Eski metin yalnız karşı teklif kâğıdının cevapsız kuralını yazıyordu.
     Takvim sığar: kâğıt 2 hafta, cevap 1 hafta, karşı teklif 2 hafta, bitişe yaklaşık 8 hafta.
2. **Ertesi hafta, cevaplar maili** (kurucu 1★ Satış, ikna 0; 1. seçenek gönderildi; tutumunun üstünde teklif alan
   karşı teklif verir, §2.6.1):
```
Konu: Mart yenileme cevapları

  Kuzey Lojistik    %8 zamla yeniledi.
  Poyraz Lojistik   "Aynı fiyat olursa imzalarız."
  Yelken Ofis       "%10 indirim olursa devam ederiz."
  Ege Gıda          "Sözleşmemizi yenilemeyeceğiz. Mart sonuna kadar kullanmaya devam edeceğiz."
```
3. **Karşı teklif kâğıdı** (yalnız karşı teklif varsa):
```
1  Karşı tekliflerin hepsini kabul et                Poyraz aynı fiyat · Yelken %10 indirim
2  Aynı fiyat isteyeni kabul et, indirim isteyene     Poyraz aynı fiyat · Yelken aynı fiyatla kalır, ilişki gerilir
   aynı fiyatı teklif et
3  Teklifimizde ısrar et                              Poyraz %8 zamla kalır, ilişki gerilir · Yelken ayrılır
```
   - Tek tur vardır (R7 §6: 1-2 tur önerir; FM'de "biri çekilene kadar"). İkinci karşı teklif yoktur.
   - Cevapsız kalırsa aynı fiyat (Erdem'in kararı, 17 Ekim): karşı teklif verenlere aynı fiyat; basamak kuralı işler.
4. Kurucu yolunda ayrı sonuç maili gelmez; cevaplar maili ve karşı teklif kâğıdının sonucu kaydı tutar.
5. **Satışçıya devret** seçeneği (Satış işinde biri varsa) değişmedi (C_PLAN §2.6): bu hesapların satışçısı o olur.

#### 2.6.5 Sıklık ve tekrar
- Kâğıt yalnız grupta bir karar varsa gelir: en az bir hesap "indirim ister" ya da daha kötü tutumdaysa (satışçı yolu) ya da
  Yenilemeyebilir etiketliyse (kurucu yolu, oyuncunun gördüğü etiket). Öteki aylarda son seçim uygulanır ve yalnız sonuç
  maili gelir. Kurucu yolunda ilk yenileme her durumda kâğıtla gelir.
- Ayda en çok üç kâğıt (inceleme: eski cümle "en çok iki ... artı bir" diyordu): satışçı raporu, masası taşınca artan
  hesaplar için kurucu kâğıdı ve varsa bir karşı teklif kâğıdı. Kâğıdın gövdesi her ay başka adlar ve sayılar taşır;
  seçenek kümesi gruba göre değişir.
- Öneri (inceleme: eski metin bunu olgu gibi yazıyordu, B'nin onayı gerekir): bu kâğıtlar B'nin sprint ortası kâğıt
  sınırına (sprint başına en çok bir) sayılmaz; ay başına bağlıdır. Ölçümde ayrıca sayılır (§4.3).
- (inceleme) Ölçek uyarısı: 330 hesapta hemen her ay en az bir hesap "indirim ister" ya da daha kötü tutumdadır; kâğıt
  büyük şirkette pratikte her ay gelir. Erdem'in "kart tekrarı çok seyrek" kuralıyla gerilim §4.3'te yılda kâğıt gelen
  ay sayısıyla ölçülür.
- Bugünkü "yenileme sinyali" talep kâğıdı kalkar (değişmedi).

### 2.7 Haftalık destek raporu
**Değişmedi** (C_PLAN §2.8): temsilci gönderir, yeni bir şey yoksa gelmez, okunmamış eskisi yenisi gelince düşer, B2B ve B2C
örnekleri, düğme en kötü hattın düzeltme kartını açar. Erdem'in kararı (17 Ekim).

Değişenler:
- "Yeni" listesindeki hat eşiği A'ya göre: bir hat **Öncelikli** eşiğine (5 açık hata) ulaştı ya da sıfırlandı. Eski metin
  "Acil, 3" diyordu.
- **"Yetişemedim" tanımı:** Temsilci o hafta gelen bildirimlerin hepsine bakamadı. Satır, hafta sonunda cevapsız kalan
  bildirim o hafta gelenlerin beşte biri ya da fazlasıysa çıkar [ÇALIŞMA]. Eski "en az 5" sabiti oran olur: 330 hesapta
  haftada yüzlerce bildirim gelirken 5 anlamsızdı.
- Metin sayıyı söyler: "Yetişemedim: bu hafta 23 bildirim geldi, 15'ine bakabildim." Oyuncunun bunu görme nedeni: destek
  kapasitesinin darboğaz olduğunu söyler; cevabı ikinci bir temsilcidir.
- Birden çok temsilci varsa rapor tektir, gönderen en iyi temsilcidir (değişmedi); "bakabildim" hepsinin toplamıdır.

### 2.8 Gelir gösterimi
**Erdem'in kararı (17 Ekim):** MRR ortak dil kalır; B2B koltuk fiyatı aylık söylenir; sözleşme 12 aydır; nakit aylık tahsil
edilir.

**Değişmedi, öneri olarak kalır** (C_PLAN §2.9): yıllık gelir (MRR × 12) ikincil sayı olarak Satış başlığında, Genel Bakış'ın
İş satırında ve üst barın MRR ipucunda. Erdem bölüme "gayet iyi" dedi; yıllık gelir satırlarını ayrıca anmadı.

### 2.9 "Onboarding" adları
**Erdem'in kararı (17 Ekim):** ürün alanı "İlk Kullanım ve Erişim", kısa "İlk kullanım"; Ar-Ge düğümü "İlk Açılış Akışı";
Satış kartındaki "Onboarding" etiketi ve "Onboarding gelecek hafta bitiyor" satırı kalkar. İç kod adları kalır. Değişmedi
(C_PLAN §2.10). (inceleme) "İlk 4 hafta tabanı" ipucu satırı kalkmaz, "Yeni müşteri: en az 70" satırına dönüşür (§2.5.1).

### 2.10 Kapsam dışı
- **Rakip analizi** (Erdem'in kararı, 17 Ekim). Fiyat duruşu ipucundaki "Rakiplerin koltuk fiyatı" satırı ve rakip fiyat
  verisi planlanmaz. Var olan rakip olayları, haber satırı ve Piyasa penceresi olduğu gibi kalır.
- Pazaryeri sekmesi ve ekonomisi (E), acil durum olayları (B), ekip modeli (D), pazarlama, ERP modülleri.

---

## 3. Bağımlılıklar ve eskiyenler

**A (hatalar, büyük ölçüde koda girdi)**
- "Öncelikli" eşiği 5 açık hata: haftalık raporun "yeni" koşulu bunu okur (§2.7).
- Düzeltme kartı eforu 1 ya da 2 puan: Genel Bakış ve rapor yalnız kartı açar, eforu yazmaz. Etkisi yok. (inceleme)
  D_MODEL_v2 §5 bu eforu ×5 ölçeğe taşır (5 ve 10); C eforu yazmadığı için yine etkisi yok.
- Sesler A K6'da silindi: B2C alıntı bileşeni yenidir; metinleri E'de.
- Bot kolları (`fix_none`, `fix_worst`, `fix_due`, `fix_off` ve B2C eşleri): C'nin kapıları bunları kullanır (§4).
- **A'nın B2B ceza tavanı** (20 → 40 önerisi) eşik ve 70 başlangıcıyla aynı commit'tedir (§2.5.2).
- (inceleme) A'nın churn kapısı ("`fix_worst` kaybı `fix_off`'tan en çok %10 fazla; `fix_none` en az 2 katı") toplam kayba
  bakar. Taban erken kaybı küçülttüğünde `fix_off`'un kaybı sıfıra yaklaşır ve "2 katı" kolayca tutar; bu yüzden C'nin
  kapısı (§4.1) geç dönem kaybını ve yüzdeyi ayrıca ister. A'nın düzeltme payı hedefleri C'den etkilenmez.

**B (olaylar, koda başlıyor)**
- Kesinti çarpanının evi B'nin sprint ayarındaki kademe alanıdır; değer Soru 2'nin cevabıdır. Ekonomik 1,0 tabanı B0'ın
  "Ekonomik bandın üstünde" bulgusunu kapatır.
- Yük çarpanı: B'nin bugün 1 döndüren doluluk fonksiyonunu C doldurur (S2 seçilirse). S1 seçilirse 1 kalır.
- S2 seçilirse "Sunucular kapasitenin sınırındaydı" gibi bir yük sebep cümlesi artık yazılabilir; yalnız yük %90'ı
  geçmişken.
- Öneri: Kurumsal'da kesinti süresi kısalsın (§2.2.5). B'nin kararı.
- B'nin "sonraki sprinte bırak" bedeli (hemen −6, sprint başına −3) yeni eşik ve 70 başlangıçla yeniden ölçülür (B'nin kendi
  notu). (inceleme) Memnuniyete doğrudan yazılan her bedel haftada 21 puanlık kaymayla bir tikte hedefe geri döner
  (§2.5.1); B'nin bedeli kalıcı olacaksa hedefe ya da güven defterine yazılmalıdır. Yeni müşteri tabanı da hedeftedir:
  B'nin bedeli tabanın üstüne yazılmazsa ilk 12 haftanın hesaplarında görünmez.
- (inceleme) B0v'nin olasılık tavanı önerisi (0,30) yük çarpanının Ekonomik'teki etkisini sınırlar (§2.2.5).
- B, istek verisini C'den okur (değişmedi).

**D (ekip)**
- Kurucu saati: C artık yenileme için kurucuya saat yazmaz. D'nin "kurucu sprint payı" hesabındaki C yenileme saatleri
  ifadesi düşer.
- Satış yıldızı: ikna kuralı (§2.6.1) satışçının ve kurucunun Satış yıldızını okur. (inceleme) Bu beceri bugün oyunda
  vardır; D_MODEL_v2 yalnız üretim rollerini (geliştirme, tasarım, test, PM) modeller ve Satış'a dokunmaz. Bağ yoktur.
- Satışçı masasının yenileme yükü (hesap başına 0,25 hafta) bugünkü satış masasının üstüne kurulur (masa aynı anda tek iş
  yürütür). (inceleme) D satış masasını modellemiyor; eski "D'nin satış masası modeline uymalı" cümlesinin karşılığı yok.

**E (pazaryeri)**
- B2C alıntı metinleri E'nin; not ve video ürünleri siliniyor.
- B2C sunucu fiyatı Standart'ta 1.000 kullanıcı başına $55 → $150, servis gideri $700 → $605. Standart'ta toplam aynıdır,
  ama Ekonomik ve Kurumsal'da değişir. E pazaryeri ekonomisini bu fiyatla ölçmeli. E'nin yükü (alıcı sayısı) değişmez.
- (inceleme) B2C'nin "%8" hedefi bugünkü not ve video ürünlerinin kullanıcı başına gelirinden hesaplandı; E bu iki ürünü
  siliyor. Pazaryerinin geliri komisyondur (E_PLAN: varsayılan %10), bin alıcı başına geliri bugünkü abonelikten çok farklı
  olabilir. Bin kullanıcı başına sabit fiyat oranla değil adetle ölçeklendiği için pazaryerinde sunucunun gelir payı %8
  çıkmayabilir: düşük komisyonda sunucu pahalı, yüksekte ucuz kalır. Bu yüzden B2C fiyatı E'nin ölçümüne kadar [ÇALIŞMA]
  sayılır; E, 101. haftada Standart'ta sunucu ve servis giderinin gelire oranını raporlar ve oran %6-10 dışındaysa B2C
  birim fiyatı Erdem'e gider. Ekonomik ile Kurumsal arasındaki 4 kat fark pazaryerinin kâr marjına doğrudan girer.
- E'nin Dayanıklılık metni ("Sunucular kimse uyandırılmadan iki katına çıkar") S2'nin Standart ölçeklemesiyle tutarlı.

**X (ürün eksenleri, paralel belge)**
- Genel Bakış Sürüm bloğunun eksen satırı ve memnuniyet ipucunun "Ürün kararlılığı" terimi X'in kararına bağlıdır (§2.1,
  §2.5.3). B2B memnuniyet hedefinin taban terimi bugün kararlılık eksenidir; eksenler kalkarsa X yerine bir ölçü vermelidir.
- (inceleme) C, X §8.1 (ürün durumu satırları) ve §8.2 (hesap başına kalite terimi) sözleşmelerini okur. X §6.3 "ilk 4
  hafta tabanı"nı korunan terim sayıyordu; eski C metni onu siliyordu. Düzeltilmiş C tabanı korur ve 70'e çıkarır, X ile
  uyumludur. X §8.2'nin "imza anı ve taban aynı terimi okusun" isteği: imza 70 sabittir, taban da 70'tir; X (c)'de ürün
  terimi beklentide 70 olduğundan ikisi örtüşür.

**Eski C_PLAN'da eskiyenler**
- Doluluğun tamamen kalkması: yerine S2 (soru).
- Fiyatların aynen kalması: yerine yeniden bölüşüm.
- Kesinti tablosu (×1,5 / ×1,0 / ×0,6): yerine Soru 2.
- Şart karşılanmazsa yalnız −10: yerine süre ve fesih kuralı.
- Yenileme sonuç tablosu (yıldız karşılaştırması), kurucu saati (hesap başına 2, en çok 24), kurucu kâğıdının "cevapsızsa
  eşiğin altı yenilemez" kuralı: yerine tutum modeli.
- "İlk 4 hafta tabanı": (inceleme) kalkmaz; değeri eşik + 2'den 70'e çıkar ve 8 haftada sönümlenir.
- Yenileme bedellerinin güven defterine yazılması: (inceleme) hedef terimine taşındı (§2.6.1).
- Rakip fiyat satırı ve `price_cut` bağı: kapsam dışı.
- "Acil" eşiği 3: "Öncelikli" 5. "Yetişemedim" 5 sabiti: oran.
- Sesler 28 (ya da 8) satır: E'ye.

---

## 4. Ölçüm kapıları
Her kapı tek turdur (Erdem 2026-10-11 kuralı). Bot cevap politikaları harness değişikliğidir, ayrı raporlanır. Ölçüm
kötü çıkarsa değer değiştirilmez, rapor Erdem'e gider.

### 4.1 Memnuniyet, eşik, A'nın hata bedeli
Koşu: B2B `fix_none`, `fix_worst`, `fix_off`; tohum 7 ve 11; 104 hafta; yeni eşik, başlangıç 70, 70'lik sönümlü taban
(inceleme), tavan 40.
- **Hiç düzeltmeyen kol hesap kaybeder:** geç dönem kaybı hesapların en az %10'u ve `fix_off`'un en az 2 katı.
- **En kötüsünü düzelten kol kaybetmez:** geç dönem kaybı `fix_off` + 3 puanı geçmez.
- **Erken kayıp düşer:** `fix_worst` erken dönem kaybı %10'un altında (bugün %27-40). (inceleme) Taban 12 hafta sürdüğü
  için kaybın 13-20. haftalara kaymadığı da raporlanır: imzadan 13-20 hafta sonra ayrılan hesap sayısı ayrıca yazılır.
- Bilgi için: geç dönemde hesapların memnuniyet dağılımı ve tutum bantlarına düşen pay.
- Tavan 40 ile ilk iki koşul tutmazsa iki yol Erdem'e gider: tavan daha da artar ya da eşik daha az iner (33 + 4×).

### 4.2 Sunucu
Koşu: B2B ve B2C `fix_worst`, her kademe için bir kol (sabit kademe; yeni preset anahtarı), tohum 7 ve 11.
- **Olay sayısı kademeyle iner:** Ekonomik > Standart > Kurumsal, her basamakta en az %25 az; Kurumsal koşu başına en az 4.
- **Fatura:** 101. haftada sunucu faturası Standart'ta MRR'ın %6-10'u; Standart'ta sunucu + servis toplamı bugünkünden en
  çok 1 puan farklı.
- **Yük oynuyor (S2):** Ekonomik koşuda yükün %90'ı geçtiği hafta sayısı sıfırdan büyük; Standart'ta %100'ü geçen hafta en
  çok 2.
- (inceleme) Olay sayısı B'nin olasılık tavanıyla birlikte okunur; Ekonomik koşu başına 14'ü geçerse B'nin bandı dışıdır
  ve Erdem'e gider.
- (inceleme) B2C kolu bugünkü not ürünüyle koşar; fatura oranı E'den sonra pazaryeriyle yeniden ölçülür (§3 E).
- `bash tools/run_gate.sh`: üç koşu sonla biter, sıfır hata.

### 4.3 Yenileme
Koşu: B2B `fix_worst` ve `fix_none`, 104 hafta. Bot satışçı raporunda 1. seçeneği, kurucu kâğıdında 3. seçeneği seçer ve
karşı teklifleri kabul eder. Ek kol: kâğıtları hiç cevaplamayan bot (aynı fiyat kuralı).
- **Kâğıt yükü:** ayda en çok 2 yenileme kâğıdı artı 1 karşı teklif kâğıdı; yılda kâğıt gelen ay sayısı raporlanır.
- **Tutum dağılımı:** `fix_worst`'te her bant boş değil; "Yenilemeyecek" payı küçük.
- **Yıllık yenilememe oranı yıldıza göre**, R7 §2.1 bantlarıyla yan yana (KOBİ %10-14, orta %5-8, kurumsal %2-5). Bilgi
  amaçlıdır; tutmazsa bant ayarı önerisiyle Erdem'e gider (inceleme: eski metin "bantlar ayarlanır" diyordu, bu bölümün
  "değer değiştirilmez" kuralıyla çelişiyordu). Not: gerçekte büyük hesap daha az ayrılır, bizim eşiğimiz 3★'ı biraz daha
  seçici yapar. Ölçüm bu ters yönü gösterirse Erdem'e gider. (inceleme) `fix_worst`'te oran sıfıra yakın çıkarsa bu
  Soru 5'in ikinci yarısının (ürün dışı yenilememe) kanıtıdır.
- **Fiyat etkisi:** ikinci yılın yenilemelerinden net MRR değişimi. R7 §2.1'e göre fiyat artışının net gelir tutmaya
  (NRR) katkısı +4 ile +6 puan arası (38 şirketlik küçük bir çalışma; inceleme).
- **Satış masası:** ikinci yılın yeni imza sayısı yenilemeli ve yenilemesiz koşuda karşılaştırılır; kayıp %10'u geçerse masa
  yükünü düşürme önerisiyle Erdem'e gider (inceleme: eski metin değeri kendisi düşürüyordu). 330 hesaba yaklaşan kolda
  satışçı başına yenileme haftası ayrıca raporlanır (§2.6.3).
- `fix_none` kolunda yenilemede "indirim ister" ve "yenilemeyecek" payı `fix_worst`'ten belirgin büyük: hata fiyattan da
  bedel ödüyor.

### 4.4 Kurumsal madde
Koşu: B2B, iki bot kolu: maddeyi hemen karşılayan ve hiç karşılamayan.
- Hiç karşılamayan kol 3★ hesaplarının çoğunu 20 hafta içinde kaybeder.
- Hemen karşılayan kol maddeden hesap kaybetmez.
- İki kolun MRR farkı ve Kurumsal faturasının farkı yan yana raporlanır: geçişin kâr ettiği ve etmediği nokta görünür.

### 4.5 Haftalık rapor
- 20 haftalık koşuda gelen rapor sayısı; en az %30'u sessiz hafta olmalı.
- "Yetişemedim" satırı temsilci sprint kartındayken ya da tek temsilci 100'den çok hesaba bakarken çıkar, öteki haftalarda
  seyrek.

---

## 5. Arayüz çalışması (Claude Design maketleri, koddan önce)
Her ekran için oyuncunun görmesi gereken bilgi. Görsel tasarım maketten gelir.

1. **Genel Bakış, B2B ve B2C** (temsilcili ve temsilcisiz): beş blok; Destek'te açık hata ve haftalık değişim, iki kötü hat;
   Sunucu bloğu §2.2.6; İş satırı; B2C'de alıntılar.
2. **Sunucu bloğu ve kademe değiştirme:** kademe seçici, fatura, kullanıcı ya da koltuk, yük ve renkleri, kademe ipucu
   (birim fiyat, ölçekleme, kesinti çarpanı, madde), geçiş önizlemesi ve madde uyarısı.
3. **Kurumsal madde:** pazarlık onay şeridi (süreli), toplantı çıkışı düğmesi, imza maili, fesih bildirimi maili, hakkı saklı
   tutma maili; tablodaki iki yeni Durum etiketi.
4. **HESAPLAR tablosu:** sekiz sütun, sıralama oku, dört görünüm sayılarıyla, firma araması, sabit başlık ve alt satır, 330
   satır kaydırma, satır eylemleri; Yenileme ipucu (kalan sözleşme, satışçı).
5. **Memnuniyet ipucu:** terim listesi, eşik, hakkı saklı tutan hesapta madde terimi; eksen kararının iki hâli.
6. **Yenileme, satışçı raporu:** tutum grupları, her grubun firmaları, seçenekler ve kesin sonuç çipleri. Erdem'in sorusu
   "UI'da nasıl gösterilecek" burada cevaplanır: Startup Company'nin müzakere ekranı (R2 §7.7 görüntü 7) ve FM'nin tutum
   göstergesi (R7 §3) referanstır.
7. **Yenileme, kurucu yolu:** ay başı kâğıdı (hesap satırları: aylık, memnuniyet, eşik, etiket), cevaplar maili, karşı
   teklif kâğıdı ve çipleri.
8. **Yenileme sonuç maili:** Firma · Eski · Yeni · Değişim tablosu.
9. **Haftalık destek raporu:** B2B ve B2C; "Yetişemedim" satırı; düğme.
10. **Satış başlık ölçüleri ve üst bar MRR ipucu:** hesap, MRR, yıllık, bu ay kazanılan ve kaybedilen.

Sıra önerisi: 4 ve 6 önce (en büyük ve en yeni iki yüzey), sonra 1-2, sonra öbürleri.

---

## 6. Onay bekleyen sabitler
| Sabit ya da kural | Değer | Not |
|---|---|---|
| Sunucu modeli | S2: kademeye bağlı ölçekleme, görünür yük | Soru 1 |
| Ölçekleme hedefi | yük %80 | bugünkü sürüm kuralının değeri |
| Ölçekleme sıklığı | Ekonomik ayda bir; Standart, Kurumsal haftada bir | |
| Yük çarpanı | %90'a kadar ×1 · %90-100 ×1,5 · %100 üstü ×2,5 | |
| Aşım etkilerinin silinmesi | memnuniyet, bildirim, kazanım | kural |
| Sunucu fiyatı, B2C 1.000 kullanıcı | $75 / $150 / $300 | Soru 3 |
| Sunucu fiyatı, B2B 50 koltuk | $60 / $120 / $240 | Soru 3 |
| Servis gideri | B2C $700 → $605; B2B koltuk $8 → $6,5 | Standart toplamı aynı |
| Kesinti çarpanı | 1,0 / 0,5 / 0,25 | Soru 2; evi B |
| Kurumsal madde süresi | 8 hafta | Soru 4 |
| Fesih kuralı eşiği | memnuniyet, eşiğin 20 puan üstünün altında | Soru 4 |
| Fesih bildirim süresi | 4 hafta | |
| Saklı hak terimi | −10, her ay yeniden kontrol | |
| Yeni hesap başlangıcı | 70 | Erdem'in kararı "%70'ler"; sayı onay bekliyor |
| Yeni müşteri tabanı (inceleme) | ilk 4 hafta hedef en az 70; sonraki 8 haftada eşit adımla kalkar | "Tabanın silinmesi" yerine; Soru 6 |
| Eşik formülü (inceleme) | 30 + 3 × (yıldız − 1) + sektör ekinin yarısı | Erdem itiraz etmedi; açık kabul yok |
| A'nın ceza tavanı | 20 → 40 (hata başına 0,3 aynı) | Soru 6 |
| Tutum bantları | 25 / 12 / 5 / 0 | |
| Basamaklar | +%8 · aynı · −%10 · −%15 | %8, aynı, %10 Erdem'in beğendiği |
| İkna | Satış yıldızı başına (yıldız − 1) × 2, en az 0 (inceleme) | |
| Basamak kuralı | bir basamak üstü: gönülsüz kabul, hedefte −6; iki basamak: yenilemez; kurucu yolunda önce karşı teklif (inceleme) | |
| Zam bedeli | hedefte −2, bir sonraki yenilemeye kadar (inceleme: güven defterinden taşındı) | |
| Yenileme takvimi | bitişe yaklaşık 8 hafta, ay başı grupları | |
| Satışçı masası yükü | hesap başına 0,25 hafta | |
| Kâğıt süresi | 2 hafta, cevapsızsa aynı fiyat | cevapsız kuralı satışçı yolunda Erdem'in kararı; kurucu yolunda öneri (inceleme) |
| Kâğıt sıklığı | yalnız karar isteyen ayda; ilk kurucu yenilemesi her zaman | Soru 5 |
| "Yetişemedim" | cevapsız ≥ gelenin beşte biri | |
| Tablo görünümleri | Tümü, Durumu olan, Yenilemesi yakın, Temsilcisi olmayan, arama | |
| Yeni Durum etiketleri | Sunucu maddesi · tarih; Fesih bildirimi · tarih | |

---

## 7. Açık sorular

1. **Sunucu kapasitesi:** Kapasite kendiliğinden büyüyüp küçülsün ama ucuz Ekonomik sunucu ayda bir, Standart ve Kurumsal
   her hafta büyüsün mü? Ekranda tek bir "Yük %" sayısı görünür, yük %90'ı geçince kesinti olasılığı artar, başka gizli
   ceza olmaz.
   **Öneri:** Evet. Kademe kararı büyüme dönemlerinde yeniden önem kazanır, oyuncu birim almaz. Hayır dersen yük
   kalkar, kapasite her kademede haftalık büyür, kesinti yalnız kademeye ve açık hataya bakar.

2. **Kesinti çarpanı:** Ekonomik 1,0 · Standart 0,5 · Kurumsal 0,25 olsun mu? Senin 1,0 / 0,8 / 0,5'inde Standart'a geçen
   oyuncu 104 haftada yalnız 1,5 olay az görür. Araştırmanın 1,0 / 0,4 / 0,15'inde Kurumsal'da olay 19 haftada bire düşer
   ve büyük müşteri maddesi yüzünden geç oyunda B2B olayları neredeyse biter.
   **Öneri:** 1,0 / 0,5 / 0,25. Her basamak hissedilir, Kurumsal'da da olay kalır.

3. **Sunucu fiyatı:** Sunucu faturası bugün gelirin %3'ü (gerçekte %8-17), servis gideri ise %30-37. Standart'ta sunucu
   fiyatı 2,7 kat artsın, aynı tutar servis giderinden düşsün, kademeler 1 : 2 : 4 olsun mu? Toplam gider Standart'ta
   değişmez.
   **Öneri:** Evet. Fatura satırı gerçekçi olur, Ekonomik ve Kurumsal arasındaki fark ilk kez bir para kararı olur.
   (inceleme) Araştırma B2B fiyatına dokunmamayı önerdi; bu öneri B2B'yi de artırır, çünkü oyunda B2B faturası da gelirin
   %3'ü. Tüketici ürünün fiyatı pazaryeri gelince yeniden ölçülür.

4. **Kurumsal madde:** Süre 8 hafta olsun; süre dolunca müşteri, memnuniyeti eşiğinin 20 puandan az üstündeyse 4 haftalık
   fesih bildirimi göndersin, daha memnunsa hakkını saklı tutup memnuniyetine −10 alsın ve her ay yeniden baksın mı?
   Bildirim süresinde Kurumsal'a geçmek fesih kararını geri aldırır.
   **Öneri:** Evet. Zarsız ve önceden okunur; hiç geçmeyen oyuncu 3★ hesabı 3 ile 5 ayda kaybeder.

5. **Yenileme akışı:** Satışçı müşterilerle görüşüp rapor getirsin ("bu zam kabul eder, bu indirim istiyor, bu
   yenilemeyecek"), sen raporu onaylayasın ya da indirim isteyenlere aynı fiyatı teklif ettiresin mi? Satışçı yoksa sen
   toplu teklifi mailden gönderesin, cevaplar bir hafta sonra gelsin, karşı teklif varsa tek turda karar veresin; saat
   harcanmasın. Kâğıt yalnız karar gerektiren aylarda gelsin.
   **Öneri:** Evet. Sonuç zar ve yıldız karşılaştırması yerine müşterinin memnuniyetinden okunur; "yenilemeyeceğiz" diyen
   müşteri gerçekten vardır.
   (inceleme) İkinci yarı: bu modelde hataları düzenli düzelten oyuncunun müşterisi yenilemede neredeyse hiç ayrılmaz;
   gerçekte iyi üründe de her yıl birkaç küçük müşteri bütçe ya da kapanma yüzünden yenilemez. Bunu da ekleyelim mi (az
   sayıda, şansa bağlı, mailde nedeni yazan)? **Öneri:** Şimdilik hayır; ölçüm bakımlı oyunda yenilememeyi sıfıra yakın
   gösterirse ayrıca sorulur.

6. **Yeni müşteri memnuniyeti ve hatanın bedeli** (inceleme: iki soru birleşti). Memnuniyet bugün hedefe çok hızlı
   yaklaşıyor; 70'ten başlayan müşteri ertesi hafta hedefine iner. "70'ler" isteğin ancak şöyle tutar:
   (a) İlk 4 hafta memnuniyet 70'in altına inmez, sonraki 8 haftada bu sınır yavaşça kalkar; ipucunda görünür.
   (b) Memnuniyet her yerde yavaş değişir; 70 başlangıcı kendiliğinden birkaç ay sürer, ama hata ve olay ayarlarının
   hepsi yeniden ölçülür.
   Ayrıca eşik 30'a inince hiç hata düzeltmeyen oyuncu bile B2B'de hesap kaybetmiyor; hata cezasının tavanı 20'den 40'a
   çıksın mı? Düzelten oyuncu etkilenmez (3 puan), hiç düzeltmeyen kaybeder.
   **Öneri:** (a) ve tavan 40, aynı değişiklikte ve ölçüm kapısıyla.

---

## 8. Kaba hacim
| Dilim | İçerik | Yaklaşık |
|---|---|---|
| C1 | Sunucu modeli (S2), aşım etkilerinin silinmesi, fiyat ve servis gideri bölüşümü, B'nin yük fonksiyonu | 3,5 sa |
| C2 | Kurumsal madde: süre, fesih kuralı, üç mail, düğmeler, iki Durum etiketi | 3 sa |
| C3a | Memnuniyet terim listesi (değer değişmez) | 1 sa |
| C3b | Eşik, başlangıç 70, 70'lik sönümlü taban ve ipucu satırı (inceleme), A'nın tavanı; kapı §4.1 (onaydan sonra) | 2,5 sa |
| C4 | Genel Bakış kâğıdı | 3,5 sa |
| C5 | İstekler ve B2C alıntı bileşeni (metinler E'de) | 1,5 sa |
| C6 | Haftalık destek raporu | 2 sa |
| C7 | HESAPLAR tablosu: sıralama, görünümler, arama, ipucu, gelir gösterimi, adlar | 4,5 sa |
| C8a | Yenileme modeli ve satışçı yolu, sonuç maili, bot cevabı | 3,5 sa |
| C8b | Kurucu yolu: teklif kâğıdı, cevaplar maili, karşı teklif kâğıdı | 2,5 sa |

- **10 commit, yaklaşık 27,5 saat** (kod, kapılar ve incelemeler birlikte; eski plan 9 commit, 22 saat). Gerçekçi takvim 4
  iş günü. (inceleme) C3b tabanı silmek yerine değiştirdiği için yarım saat arttı.
- Artışın kaynakları: yük modeli, tablo sıralama ve arama, yenilemenin iki yolu, sönümlü taban. Azalış: rakip satırı,
  kurucu saati.
- Claude Design maketleri bu sürenin dışındadır (§5'teki 10 ekran; Erdem'le birlikte).
- Sıra: C1 → C3a → C2 → C4 → C5 → C6 → C7 → C3b → C8a → C8b. C3b onay bekler, en geç C8a'dan önce girer.

---

## İnceleme notu
Kıdemli inceleme, 2026-10-17. Bu belgede yerinde düzeltildi; her değişiklik "(inceleme)" ile işaretli. Okunanlar:
`ERDEM_CD_YORUM.md`, `X_URUN_EKSENLERI.md`, `D_MODEL_v2.md`, R2, R6, R7, R8, `B0_ESIKLER.md`, `K5_OLCUM.md`, ilgili kod
(`b2b_sales_system.gd`, `b2b_constants.gd`, `sales_system.gd`).

1. **En ağır bulgu, düzeltildi:** Belge memnuniyetin haftada 3 puan kaydığını varsaydı; kodda günde 3, tikte 21 (ilk 4
   haftada 35). 70 başlangıcı ilk tikte silinir, "balayı" oluşmaz, "İlk 4 hafta tabanı" ölü değildir. Taban korunup 70'e
   çıkarıldı ve 8 haftalık sönüm önerildi (§2.5.1); §0, §1, §2.5.2, §2.5.3, §2.9, §3, §4.1, §6, §8 buna göre değişti.
2. Aynı nedenle güven defterine yazılan yenileme bedelleri (−2, −6) bir iki haftada siliniyordu; hedef terimine taşındı.
3. Sadakat: eşik formülü "Erdem'in kararı" diye yazılmıştı, metinde açık kabul yok; itirazsız öneri oldu. "Zar
   istenmediği için" ifadesi Erdem'e ait değildi, çıkarıldı; "zarsız" sade dille açıklandı. Cevapsız kâğıt kararı yalnız
   satışçı yolu için Erdem'indir. Reddedilen fikirlerden (rakip fiyat satırı, yıldız karşılaştırmalı sonuç, kurucu saati)
   hiçbiri geri gelmemiş.
4. Araştırma (13 iddia denetlendi, 8'i doğru, 5'inde sorun): S1'in dayanağı Startup Company değildi (onda doluluk var); "geliştirici
   angarya diyor" yanlış okumaydı; R7 §6'nın tasarım önerisi gerçek pratik gibi sunulmuştu; R6'nın "B2B fiyatını koruyun"
   önerisinden ayrılış yazılmamıştı; R7 §5 "yan sütun" der. Hepsi düzeltildi.
5. Yenileme akışı tek anlamlı değildi: kurucu yolunda karşı teklif ile basamak kuralının sırası, ilk kâğıdın cevapsız
   kalması, "Yenilemeyebilir" etiketinin kurucuya tutumu sızdırması ve Durum önceliğinin yönü yazıldı.
6. "Kimse ayrılmıyor": model ürünü bozulan, fazla zam alan ve indirimi verilmeyen hesabı kaybettirir; bakımlı üründe
   yenilemede ayrılan neredeyse yok, ürün dışı neden yok. Açık bırakıldı, Soru 5'e eklendi, §4.3 ölçer.
7. Ölçek: 0★ kurucuda ikna eksiye düşüyordu (en az 0 eklendi). Satışçı başına 0,25 haftalık yenileme yükü 330 hesapta iki
   satışçıyı tamamen yer; açık risk, §4.3 ölçer. Yenileme kâğıdı büyük şirkette her ay gelir; ölçülür.
8. Fazlar arası: B0v'nin olasılık tavanı (0,30) yük çarpanını Ekonomik'te keser, 17 olay B'nin bandı dışındaydı; B'nin
   memnuniyete doğrudan yazdığı bedeller de bir tikte silinir; B'nin kâğıt sınırı muafiyeti B onayı isteyen öneri oldu.
9. D ile: D Satış'ı ve satış masasını modellemiyor; "D sağlamalı" cümleleri düzeltildi. D'nin efor ×5 ölçeği C'yi etkilemez.
10. X ile: Sürüm bloğu ve ipucu X §8.1 ve §8.2 sözleşmelerine bağlandı; çıplak eksen sayısı kalktı; X'in koruduğu taban
    artık C'de de korunuyor.
11. E ile: B2C'nin %8'i silinecek not ve video gelirinden hesaplanmıştı; pazaryeri komisyonla kazandığı için oran ve fiyat
    E'nin ölçümüne kadar çalışma değeri sayıldı, E'ye ölçüm ve eşik yazıldı.
12. Açık kalanlar: simülasyon tablosu (§2.2.5) yeniden koşulmadı, yalnız tavan farkı not edildi; sönüm süresi (8 hafta),
    taban değeri ve tavan 40 ölçümle kesinleşir; Soru 6'daki (b) yolu C'nin kapsamını aşar. Sorular 6'da kaldı; 6 numara
    iki soruyu birleştirdi.
