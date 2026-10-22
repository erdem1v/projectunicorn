# Faz B planı · Olaylar (acil durum, sprint ortası kâğıtlar, söz olayı, sürüm anı)
Planlayıcı: Opus, 2026-10-16. Girdiler: `ORTAK.md`, `B_GOREV.md`, `B_ARASTIRMA.md`, `ERDEM_TUR2_YORUM.md`, karar defteri,
`TUR2_SUNUM.md`, `../sprint/T2_*`, repo `main` @ `1faeb82` (okuma). A planı henüz yazılmadığı için A'nın vereceği
fonksiyonlar **"A/B varsayımı"** diye işaretli; uygulamadan önce A'nın commit'lerine karşı tazelenir (adım 0).

---

## 0. Özet

- **Hotfix'in yerine beş acil durum olayı gelir:** Gece kesintisi (B2B ve B2C), Ay sonu kapanışı (B2B, müşteriden 23:40
  maili), Ödeme alınamıyor (B2C), Sürüm sonrası bozulma (ikisi), Yorum fırtınası (B2C). İki olay arası en az 4 hafta;
  sonrası haftalık bir zarla gelir, aralık 5 de olabilir 20 de. Olasılığı sunucu kademesi, doluluk, açık hata ve hatalı
  sürüm belirler.
- **Her bedel olayın ölçeğinden türer:** kesinti kredisi hesabın aylık ücretinin araştırmadaki kademesi (%10 / %25 / %50),
  B2C telafisi etkilenen kullanıcı sayısıyla, kitle kaybı kesinti saatiyle, gece mesaisinin süresi ekibin yıldızıyla.
  Seçenek metni sorunun kaç saatte kapanacağını söyler.
- **Gece olayı gece gelir:** 02:10'da başlayan kesinti, ondan sonraki ilk saat adımında (03:00) saati durdurur; oyuncu
  kararı gecenin içinde verir (inceleme: saat yalnız tam saatte durabiliyor, kart başlama anından önce açılamaz).
- **Sprint ortası kâğıtları:** kâğıdı o kartta o aşamada çalışan kişi konuşur. Havuz 6'dan 40 kâğıda çıkar. Kâğıt sprint
  başına en çok bir kez gelir; aynı kâğıt en erken 52 hafta sonra döner ve bir koşuda en çok 3 kez görünür.
- **Söz olayı:** B2B hâli onaylı biçimiyle girer (Testi kısalt / Fazla mesai / Ara, bir sprint iste / Söz kaçsın).
  B2C ikizi yeniden kuruldu: kullanıcılara duyurulan tarih ("Ne zaman geliyor?" sorusuna verilen cevap).
- **Sürüm anı:** B2B'de isteği karşılanan hesaptan, işi gerçekten kullandıktan sonra gelen teşekkür maili; B2C'de sürüm
  notunda "Sürüm sonrası öne çıkan yorumlar" (2–3 yorum, sürümün içeriğinden ve hatasından türer).
- **Yatırımcı hazırlığı kalkar** (öneri; açık soru 1).
- **Oyuncu ne hisseder:** Kriz seyrek ve gerçek gelir, her seçenek kime neye mal olacağını sayıyla söyler; sprintte
  ekibin sesi duyulur ve aynı cümleyi aylarca görmez; sürüm çıkınca biri teşekkür eder ya da şikâyet eder.
- **9 commit**, yaklaşık 17–19 saat (yazım dahil). Sıra: A bittikten sonra.

---

## 1. Bugünkü akış

**Acil durum.** Hata yığılınca oyuncu Build bar'daki düğmeyle "düzeltme koşusu" başlatır ve bitirir; düğme bir şey
yayınlamaz, yalnız sayaç düşer. Tek kesinti kartı vardır ve yalnız sunucu taşınca gelir: üç seçeneği her koşuda
aynıdır ("Herkesi bu işe çek", "Kesintiyi telafi et" sabit $6.000, "Yamala, bir şey söyleme"). Gece yoktur, müşteri
yoktur, kaç kişinin etkilendiği yazmaz. "Hata yığını" kartı düzeltme koşusunu başlatır; koşu A'da kalktığı için bu kart
B'de ölür.
**Neden yetersiz:** Kriz hissi yok; bedeller olaydan kopuk sabit sayılar; B2B ile B2C aynı kâğıdı görür; sıklığı tek
kartın 26 haftalık bekleme süresidir.

**Sprint ortası kararlar.** Koşan her kart için her hafta %35 ihtimalle bir kâğıt gelir; havuzda 6 kâğıt vardır,
ikisi ("Kendi renkleri", "Yine renkler") neredeyse aynıdır. Kâğıdı kimse konuşmaz. Üç kartlı bir sprintte haftada
%70'e yakın kâğıt gelir; aynı kâğıt birkaç sprintte bir döner.
**Neden yetersiz:** Erdem'in sözüyle "her 6 haftada bir benzer kartı görmek midemi bulandırır". Kâğıtta konuşan bir
insan yok; tester, tasarımcı, PM'in ağzından bir şey çıkmıyor.

**Söz.** B2B'de hesaba verilen söz sprint sayar; sprint kapanınca özellik çıkmamışsa söz bozulur (memnuniyet −20,
marka −3, kalıcı güven izi). Arada oyuncuya bir şey sorulmaz; "Sprint yetişmeyecek" kâğıdı sözü bilmez. B2C'de söz yok.

**Sürüm anı.** Sürüm notu çıkar: kapanan işler, basın satırı, ertesi gün tek "sonuç" cümlesi. Müşteri ya da kullanıcı
sesi yoktur.

**Kurucu.** Series A görüşmesinden önce "Hazırlık" satırında üç düğme vardır (Rakamlar / Hikâye / Prova). Birine basınca
kurucu bir hafta sprintte yoktur; karşılığı görüşmede tek bir soruda +%20 şans, yalnız oyuncu o soruda doğru açıyı
seçerse. Oyuncu ne kazandığını görmez.

---

## 2. Hedef akış

### 2.1 Acil durumların ortak kuralı
- **Ağırlık:** "Servis çöktü" (kesinti, ödeme) ve "Tek akış ya da önemli müşteri tıkandı" (ay sonu, sürüm sonrası
  bozulma, yorum fırtınası). Küçük sorun olay olmaz; yalnız o hattın "Açık hata" sayısına yazılır (A).
- **Sıklık:** Bir acil durumdan sonra en az 4 hafta hiçbir acil durum gelmez ("Servis çöktü"den sonra 6). Sonrası her
  hafta bir zar: ucuz sunucu, dolu sunucu ve çok açık hata zarı büyütür. Ortalama ürün için iki olay arası tipik olarak
  8–14 hafta; ihmal edilmiş ürün için 5–7; kurumsal sunucu ve temiz ürün için 20 ve üstü [ÇALIŞMA]. Aralık hiçbir zaman
  düzenli değildir.
- **Sürüm sonrası bozulma da bu 4 haftalık kurala tabidir.** Pencere kapalıyken hatalı çıkan kart yalnız o hattın açık
  hatasına yazılır, olay gelmez. Gerekçe: Erdem aralığı oyuncu bunalmasın diye istedi; sürüm haftası zaten yoğun.
- **v1.0'dan sonraki ilk 3 hafta** acil durum yok (sürüm sonrası bozulma hariç). Yeni ürünün ilk haftaları yayının
  kendisine aittir.
- **Saat:** Gece olayı gece gelir. Olay 02:10'da başlar; saat bir sonraki tam saatte (03:00) durur, ofis gece
  ışığındadır, kart açılır. Mailin saati 02:10'dur, saat çubuğu 03:00'ü gösterir; metin olanı geçmiş zamanla anlatır.
  Karar verilince oyuncu saati yeniden başlatır, gece kaldığı yerden geçer. (inceleme: gece toplu adımı tam saatlerle
  ilerliyor, `skip_night` adımı 02:00'de dakikasız durur; "02:10'da açılan kart" saat çubuğuyla çelişirdi.)
- **Seçenekler olaya göre değişir.** Aşağıdaki tabloda hangi olayda hangi seçenek var:

| Seçenek | Kesinti B2B | Kesinti B2C | Ay sonu | Ödeme | Sürüm sonrası | Yorum fırtınası |
|---|---|---|---|---|---|---|
| Ekip gece (ya da bu akşam) çalışsın | var | var | var | yerine "Ekibi hemen başına al" | "bu akşam kalsın" | "bu akşam kalsın" |
| Kendin bak (ekip en fazla 2 kişiyken) | var | var | var | var | var | var |
| Sprinti durdur, şimdi düzelt | yok | yok | var | var (inceleme) | var | "açıklama yap" ile |
| Sabah ekiple düzelt | var | var | yok | yok | yok | yok |
| Telafi et | kesinti kredisi | ücret iadesi | yok | yalnız pazaryerinde (E): sepet indirimi | yok | indirim + sonraki sprint |
| Sonraki sprinte bırak | yok | **kilitli** | var | **kilitli** | var | "bir şey söyleme" ile |

**Seçeneklerin bedeli (hepsi [ÇALIŞMA], "onay bekliyor" §5.6):**
- **Ekip gece çalışsın:** Süre metindedir ve ekibin en iyi geliştiricisinin yıldızından türer (3★ ile 3 saatlik iş
  yaklaşık 3 saat, 1★ ile 3,5 saat, 5★ ile 2 saat). Bedel: gece nöbetine kalan geliştirici ve testçinin morali
  −(6 + saat), en çok −10. Ayrı bir verim düşüşü **yok**: moral zaten çıktıyı düşürüyor; ikisini birden yazmak aynı
  geceyi iki kez cezalandırır. Aceleden %25 ihtimalle o hatta 1 yeni açık hata.
- **Kendin bak:** Yalnız ekipte en fazla 2 çalışan varken açık; değilse satır kilitli görünür ("Ekip iki kişiyi
  geçti"). Süre kurucunun yazılım yıldızından türer ve tek başına olduğu için 1,5 kat uzundur. Bedel: kurucunun
  önümüzdeki haftaki verimi −%15 (uykusuz gece ve ertesi gün; %40 yerine). Uzun süren kesintinin müşteri bedeli de
  ayrıca düşer.
- **Sabah ekiple düzelt:** Moral ve kasa bedeli yok; kesinti uzar. B2B'de sabah 08:30'da işe başlayan bütün hesaplar
  etkilenir, B2C'de kitle kaybı büyür.
- **Telafi et:** B2B'de araştırmadaki kesinti kredisi kademesi: kesinti süresi aylık 43 dakikanın altındaysa kredi
  yok; 43 dakika ile 7,2 saat arası aylık ücretin %10'u; 7,2 ile 36 saat arası %25; üstü %50. Kredi kasadan bir kez
  çıkar ("Kesinti kredisi" satırıyla) ve hesapların memnuniyet kaybının çoğunu siler. B2C'de etkilenen ödeyen
  kullanıcılara bir aylık ücret iadesi; kitle kaybını üçte bir azaltır. Pazaryeri (E) gelince aynı satır etkilenen sepete
  sepet ortalamasının %15'i kadar indirim olur.
- **Sonraki sprinte bırak:** B2B'de o hesabın memnuniyeti −6 düşer ve düzeltilmeden geçen her sprint kapanışında −3
  daha. B2C'de düzeltme kartı çıkana kadar kitle haftada −%2 (en çok 8 hafta). B2C'de servis tamamen çöktüyse satır
  kilitli: "Uygulama şu anda kimseye açılmıyor." (inceleme: gerekçe yalnız olguyu söyler) Zorunlu düzeltmenin üstüne kesintinin saatiyle orantılı anlık
  kitle kaybı her seçenekte vardır.
- **Sprinti durdur, şimdi düzelt:** O hattın düzeltme kartı koşan sprintin en başına girer ve ilk o yapılır.
  Sprintin kapasitesi taşarsa henüz başlanmamış en sondaki kart sonraki sprinte kayar; seçenekte hangi kartın kayacağı
  yazar. B2B'de iş bir gün gecikir (memnuniyet −3); B2C'de düzelene kadar kayıp yarı hızda sürer.
  (inceleme) O hattın düzeltme kartı zaten sprintte ya da plan sütunundaysa yeni kart açılmaz, var olan kart başa
  taşınır; A'nın düzeltme kartı hat başına tektir.

**B2B memnuniyet bedeli neden kalıcı?** Olay kartının bugünkü memnuniyet düşüşü bir haftada hedefe geri çekiliyor. Bu
fazdaki bütün B2B bedelleri, sözün kullandığı kalıcı iz üzerinden yazılır: hesabın memnuniyet hedefi düşer ve bu iz
haftada yaklaşık 3 puan affedilir. Oyuncu "58 → 52" görür ve hesap gerçekten orada durur.

### 2.2 Olay olay

Örnek şirketler [ÇALIŞMA]:
- B2B: ERP, 9 hesap, 3'ü gece vardiyasıyla çalışıyor (lojistik, üretim, sağlık), toplam aylık gelir $14.200, iki
  geliştirici (3★ ve 2★), bir testçi, kurucu.
- B2C: not uygulaması, kitle 12.400, ödeyen 1.050, aylık ücret $8, bir geliştirici, bir tasarımcı.

#### Olay 1 · Gece kesintisi (B2B)
Kart saat 03:00'te açılır; mail 02:10 damgalıdır (inceleme). Gönderen nöbetçi geliştirici (Deniz · Geliştirici); ekip
yoksa "Sistem uyarısı" olarak kurucunun kendisine.

```
02:10 · Servis durdu                                         Deniz · Geliştirici
Servis saat 02:10 sularında durdu, o zamandan beri cevap vermiyor. Gece vardiyasıyla
çalışan 3 hesap sisteme giremiyor; ilk arayan Ekol oldu. Öbür hesaplar 08:30'da işe başlıyor.
Barındırma sağlayıcısı bölgedeki makinelerini yeniden başlattı; bizimkiler geri
açılmadı.

[ Ekibi uyandır; servis yaklaşık 3 saatte açılır ]
    Deniz, Mert, Selin: moral −9 · 3 hesap: memnuniyet −2 · %25 aceleden yeni hata
[ Kendin bak; servis 06:40 sularında açılır ]                       (kilitli: Ekip iki kişiyi geçti)
[ Sabah ekiple düzelt, hesaplara kesinti kredisi tanımla ]
    Kasa −$3.550 (aylık ücretlerin %25'i) · 9 hesap: memnuniyet −1
[ Sabah ekiple düzelt ]
    9 hesap: memnuniyet −7
```
Neden her seçenek bir durumda en iyisi: moral yüksek ekip gece çalışır; tek kurucu kendi bakar; kasası rahat şirket
krediyle hesapları korur; hesapları sağlam, ekibi yorgun şirket sabahı bekler.

#### Olay 2 · Gece kesintisi (B2C)
Olay 01:30'da başlar, kart 02:00'de açılır; aynı kalıp. "Sonraki sprinte bırak" görünür ama kilitlidir.
```
01:30 · Uygulama açılmıyor
Uygulama saat 01:30 sularında açılış ekranında takılı kalmaya başladı. Şu anda 372 kişi
girmeye çalışıyor; sosyal medyada şikâyetler başladı. Barındırma sağlayıcısı bölgedeki
makinelerini yeniden başlattı; bizimkiler geri açılmadı.   (inceleme: "yük" sebebi C doluluğu
kaldırırsa düşer, örnek sağlayıcı sebebine çevrildi)

[ Ekibi uyandır; uygulama yaklaşık 3 saatte açılır ]   Deniz: moral −9 · Kitle −%1,4
[ Kendin bak; uygulama 06:00 sularında açılır ]        Kurucu: verim −%15 · 1 hafta · Kitle −%2,3
[ Sabah düzelt; etkilenen ücretli kullanıcılara bir aylık ücretlerini iade et ]   Kasa −$1.128 · Kitle −%3,0
[ Sabah düzelt ]                                       Kitle −%4,6
[ Sonraki sprinte bırak ]   kilitli: Uygulama şu anda kimseye açılmıyor.          (inceleme)
```

#### Olay 3 · Ay sonu kapanışı (B2B, müşteriden akşam geç saatte mail)
(inceleme) Mail 22:10 ile 22:55 arasında damgalanır, kart 23:00'te açılır. 23:40 damgası kartı 00:00 adımına iterdi;
o adım gün dönümü, ay kapanışı ve oto kayıtla aynı adımdır ve "gün sınırında ateşlenen kart saat yazmaz" kuralına
takılır. Yalnız ayın son haftasında, fatura, defter ya da nakit tarafında en az 2 açık hatası olan ve bu tarafları kullanan en
büyük hesaptan gelir. Gönderen hesabın yetkilisidir (Ekol · Finans Müdürü). Metin hattına göre değişir (§6.1).
```
Ay sonu kapanışını yapamıyoruz                          Ekol · Finans Müdürü · 22:40
İyi akşamlar. Toplu fatura onayı öğleden sonradan beri hata veriyor. Muhasebe ekibimiz
ay sonu kapanışını yarın sabah 09:00'da yapacak ve bu adım olmadan başlayamıyor. Bu
gece bakabilecek biri var mı?

[ Ekip bu gece başına otursun; yaklaşık 3 saatte biter ]   Deniz, Selin: moral −9 · %25 aceleden yeni hata
[ Kendin bak; 04:10 sularında biter ]                      (kilitli)
[ Sprinti durdur, düzeltmeyi sprintin başına al ]          Ekol: memnuniyet 58 → 55 · "Stok sayımı" sonraki sprinte kayar
[ Bu ay kapanışı elle yapmalarını rica et; düzeltmeyi sonraki sprinte al ]   Ekol: memnuniyet 58 → 52
```

#### Olay 4 · Ödeme alınamıyor (B2C, ücretli plan açıkken)
Gündüz gelir. Etkilenen kişi sayısı son saatlerdeki abone olma ve yenileme akışından türer. Pazaryeri (E) gelince aynı
kart "212 sepet ödeme adımında kaldı" der.
```
Ödeme alınamıyor
Kart ödemeleri saat 14:20 sularından beri son adımda reddediliyor. Son 2 saatte 5 kişi
aboneliğini başlatmak ya da yenilemek istedi ama yapamadı. Ücretsiz kullanım etkilenmiyor.

[ Ekibi hemen başına al; yaklaşık 2 saatte düzelir ]   Ekip: verim −%5 · 1 hafta · Kitle −%0,8
[ Kendin bak; 19:20 sularında düzelir ]                Kurucu: verim −%15 · 1 hafta · Kitle −%1,0
[ Sprinti durdur, düzeltmeyi sprintin başına al ]      "Paylaşılan Not" sonraki sprinte kayar · Kitle −%1,6   (inceleme)
[ Sonraki sprinte bırak ]   kilitli: Şu anda kimse ödeme yapamıyor.               (inceleme)
```
(inceleme) Sprint satırı eklendi: ekip ikiden büyükken "Kendin bak" kilitli olduğundan kartta tek açık seçenek
kalıyordu; bu, "bedava çıkış yok, her seçenek bir durumda en iyisi" kuralına göre seçim değildir. Sprint yolu ekibin
haftasını korur, kesinti uzar.
Abonelik ürününde etkilenen sayısı küçüktür (ödeyen 1.050 → günde ≈60 ödeme denemesi); telafi satırı burada
bedelsiz denecek kadar ucuz olacağı için her durumda en iyi seçenek olurdu. Bu yüzden telafi satırı yalnız pazaryerinde
(E) gelir: "Hemen düzelt; ödeme adımında kalan 212 sepete sepet ortalamasının %15'i kadar indirim tanımla" (Kasa
−$1.270 [ÇALIŞMA]).

#### Olay 5 · Sürüm sonrası bozulma (ikisi)
Sürüm çıktığında kritik bir hatta hatalı kart varsa (A'nın "bozulan hatta hata"sı) ve 4 haftalık pencere açıksa,
ertesi sabah gelir. Gönderen testçi, yoksa geliştirici. Metin hatta göre yazılmıştır (§6.1).
```
v1.4 sonrası bir şey bozuldu                                  Selin · Testçi
v1.4 çıktığından beri stok sayımında bazı ürünler eksi adetle görünüyor. Önceki
sürümde böyle bir şey yoktu. Stok ekranını her gün 6 hesap kullanıyor.

[ Sprinti durdur, düzeltme sprintin başına geçsin ]   6 hesap: memnuniyet −3 · "Toplu fatura" sonraki sprinte kayar
[ Ekip bu akşam kalsın; yaklaşık 4 saatte düzelir ]   Deniz, Selin: moral −10 · %25 aceleden yeni hata
[ Kendin bak ]                                         (kilitli)
[ Sonraki sprinte bırak ]                              6 hesap: memnuniyet −4, her sprint kapanışında −3 daha
```
B2C'de son satır "Düzelene kadar kitle haftada −%2" olur.

#### Olay 6 · Yorum fırtınası (B2C)
Kitle 2.000'i geçmiş ve bir hatta en az 6 açık hata varken. Paylaşım sayısı kitlenin %2,5'i [ÇALIŞMA]. Alıntı hatta
göre yazılmıştır.
```
Bir gönderi 310 kez paylaşıldı                                 (inceleme: başlık tam cümle)
Senkron hakkındaki bir gönderi sabahtan beri 310 kez paylaşıldı: "Telefonda sildiğim
not bilgisayarda geri geldi. Bilgisayarda sildim, bu sefer telefonda geri geldi."
Altına yazanların çoğu aynı şeyi yaşadığını söylüyor.

[ Açıklama yap, düzeltmeyi sprintin başına al ]   Marka −1 · Düzelene kadar kitle haftada −%1
[ Ekip bu akşam kalsın; yaklaşık 3 saatte düzelir ]   Deniz: moral −9 · Marka −1
[ Özür dile, etkilenen ücretli kullanıcılara bir ay yarı fiyat tanımla; düzeltmeyi sonraki sprinte bırak ]   Kasa −$520 · Kitle haftada −%1   (inceleme)
[ Bir şey söyleme, sonraki sprinte bırak ]   Marka −2 · Düzelene kadar kitle haftada −%2
```

**Kalanlar:** "Satıcıların ödemesi" ikizi yok. Var olan "Destek taşıyor", "Müşteri temsilcisi yükseltti", "B2C iadeler"
ve sızıntı kartları olduğu gibi kalır. "Hata yığını" kartı silinir.

### 2.3 Sprint ortası kâğıtlar
**Kim konuşur:** O hafta kartın o aşamasında çalışan kişi. Tasarım aşamasında tasarımcı, geliştirmede geliştirici,
testte testçi; testçi yoksa testi yapan geliştirici. PM kartın kendisi hakkında konuşur (müşterinin istediği ile bizim
eklediğimiz). Kurucu tekken kâğıt kurucunun kendine notudur.
```
Üçü de aynı yerden                                         Deniz · Geliştirici
Bu karttaki Fatura hatalarının üçü aynı yerden çıkıyor: ilk sürümden beri kimsenin
dokunmadığı bir kod parçası. Üçünü ayrı ayrı yamayabilirim ya da o kısmı baştan
yazabilirim. Baştan yazarsam bir daha dönmezler.

[ Altını baştan yaz ]                        Kart +2 puan · Fatura'ya 26 hafta yeni hata düşmez
[ Üçünü yamala, devam et ]                   Çıkışta Fatura: 1 açık hata
[ Yeniden yazımı dışarıdan birine yaptır ]   Kasa −$2.000 · Fatura'ya 26 hafta yeni hata düşmez
```
**Sıklık:** Bir sprintte en çok bir kâğıt. Her hafta %45 [ÇALIŞMA]: iki haftalık sprintte yaklaşık %70, bir haftalıkta
%45. Demo süresinde (104 hafta) koşu başına 30–38 kâğıt; bugün 70'e yakın. İlk 6 haftada yaklaşık 2 kâğıt (bugün 3–4;
açık soru 3).
**Tekrar:** Aynı kâğıt 52 hafta geçmeden dönmez; bir koşuda en çok 3 kez görünür (4. hiç yok). Seçimde hiç görülmemiş
kâğıt önce gelir. Havuz bittiğinde kâğıt gelmez; sessizlik tekrardan iyidir.
**Havuz:** 40 kâğıt (dağılım §5.4). Kâğıtların bedeli beş para biriminden birine düşer: kartın puanı (zaman), çıkışta
açık hata (kalite), kişinin morali, kasa, hesabın memnuniyeti.
"Sprint yetişmeyecek" kâğıdı kalır; kartta açık söz varsa onun yerine söz olayı gelir.

### 2.4 Söz olayı
**B2B (onaylı).** Sprintin son haftasında, kartın üstünde bu sprinte söz verilmiş bir hesap varsa ve kart bu hızla
yetişmeyecekse gelir. Sprint başına kâğıt sınırına sayılmaz.
```
Ekol bu sprint sonunu bekliyor                               Selin · Testçi
Ekol ekibine Toplu Fatura özelliğinin bu sprintin sonunda çıkacağını söyledik. Bu
hızla yetişmeyecek. Kart testte; testi kısaltırsak yetişir.

[ Testi kısalt ]                         Hata ihtimali %7 → %10   (inceleme: D'nin hesabı, sabit +30 yok)
[ Ekipten fazla mesai iste ]             Sprint saati ×1,25 · Ekip: moral −4
[ Arayıp bir sprint ek süre iste ]       Ekol: memnuniyet 58 → 55        (bir kez; sonra kilitli)
[ Söz kaçsın ]                           Söz bozulur · Ekol: memnuniyet −20 · Marka −3
```
**B2C ikizi (yeniden kuruldu): duyurulan tarih.** "Kasım indirimleri" kurgusu çıkarıldı. B2C'de söz bir müşteriye değil
kamuya verilir. İki adım:
1. **"Ne zaman geliyor?"** Kitle 1.000'i geçmiş, sonraki sprinte bir özellik kartı planlanmış ve ekipte müşteri
   temsilcisi varken gelir; konuşan temsilcidir (inceleme: karar defteri "istekler yalnız müşteri temsilcisi bulunca
   ortaya çıkar" diyor; temsilcisiz soru sayısını kimse saymaz): "Bu ay en çok sorulan şey Paylaşılan Not: yorumlarda ve mesajlarda 140 kişi ne zaman geleceğini
   sordu. Sonraki sprinte planlı. Tarih verirsek beklerler; vermezsek sormaya devam ederler." Seçenekler: "Sonraki
   sprintin sonu diye duyur" (Marka +1; tarih kamuya açık söz olur) / "Yakında de, tarih verme" (bir şey olmaz).
2. **"Duyurduğumuz tarih"** B2B kartının ikizi: Testi kısalt / Fazla mesai / "Güncelleme paylaş, tarihi bir sprint ileri
   al" (Marka −1; bir kez) / "Tarih sessizce geçsin" (bekleyenlerin %40'ı gider: 140 kişi bekliyorsa Kitle −56;
   Marka −2) (inceleme: kayıp olaydaki bekleyen sayısından türer, kitleden sabit % değil).
Neden bu: Gerçek B2C şirketinin sıkıştığı tarih, kendi kullanıcılarına verdiği tarihtir; dışarıdan uydurulmuş bir
kampanya değil. Söz sisteminin aynısı kullanılır, yeni ekran yok.

### 2.5 Sürüm anı
**B2B teşekkür maili.** Bir hesabın isteği zamanında çıkınca, hesap onu gerçekten kullandıktan sonra gelir: ay sonuna
bağlı işlerde (toplu fatura, mutabakat) ilk ay sonu haftasında, öbürlerinde bir hafta sonra. Bu zamanlama metnin
çelişmesini önler: mail ancak yaşanmış bir şeyi anlatır. Gönderen hesabın yetkilisidir; mail karar istemez, gelen
kutusunda okunur. Hesabın memnuniyet hedefi +4 [ÇALIŞMA] (haftalar içinde affedilen iz). Örnek:
```
Toplu fatura                                              Ekol · Finans Müdürü
Toplu faturayı bu ayın kapanışında ilk kez kullandık. Geçen ay faturalar iki kişinin
neredeyse bütün gününü almıştı; bu sefer öğleden önce tek seferde çıktı. Ekibinize
teşekkür ederiz.
```
Bir sürümde en çok 3 mail; aynı hesaptan en çok 1.

**B2C "Sürüm sonrası öne çıkan yorumlar".** Sürüm notunda basın satırının altında yeni bir satır; toplam 2–3 yorum.
Puan yıldızı yok (sahip kararı). Hangi yorumun çıkacağı sürümün içinden türer:
- çıkan en etkili özellik → olumlu bir yorum o özellik hakkında,
- bu sürümde hatalı çıkan hat ya da 3'ten fazla açık hatası olan hat → olumsuz bir yorum o hat hakkında,
- yalnız düzeltme sürümüyse → düzelen hat hakkında olumlu yorum,
- en çok istenen şey çıkmadıysa (C'nin istek verisi gelince) → "hâlâ yok mu" yorumu.
Kaynak etiketi: "Sosyal medya" ya da "Uygulama mağazası"; pazaryeri (E) gelince "Mağaza" da (inceleme: E'nin sözlüğünde
taraflar "Alıcı" ve "Mağaza"; "Satıcı" yerine "Mağaza"). Karar defterinin "son kullanıcıdan ve mağazadan birer ikişer"
kuralının mağaza yarısı ancak E ile gelir; o zamana dek yorumların hepsi son kullanıcıdandır.
```
SÜRÜM SONRASI ÖNE ÇIKAN YORUMLAR
  Sosyal medya       "Telefonda yazdığım not artık bilgisayarı açtığımda orada oluyor."   (inceleme)
  Uygulama mağazası  "Güncellemeden beri arama dünkü notları bulmuyor. Lütfen bakın."
```

### 2.6 Kurucunun zamanı
- Müşteri görüşmesi eklenmez.
- **Yatırımcı hazırlığı kalkar (öneri).** Gerekçe: (1) Oyuncunun yaptığı tek şey üç düğmeden birine basmak; yanlış
  seçim diye bir şey yok. (2) Karşılığı görünmez: görüşmede tek bir soruda +%20, yalnız o soruda eşleşen açı seçilirse.
  (3) Bedeli yalnız küçük ekipte hissedilir: kurucunun bütün haftası. (4) Asıl kararlar görüşmenin kendisinde (açı,
  duruş) zaten var. (5) Seed görüşmesinde hazırlık hiç yok; yalnız Series A'da var. Derinleştirmek (hazırlığı
  görüşmede görünen bir hazırlık kartına çevirmek) VC modülünün yeniden tasarımıdır, bu fazın işi değil. Bot hazırlık
  kullanmadığı için koşu kapıları etkilenmez.
- Sürüm duyurusu pazarlama modülüne ertelendi; bu fazda yok.

---

## 3. İzlenebilirlik

| Karar defteri / görev maddesi | Planda karşılığı |
|---|---|
| Ağırlık seviyeleri: servis çöktü / tek akış ya da önemli müşteri / küçük sorun olay olmaz | §2.1, §5.1 `severity` |
| İki olay arası en az 4 hafta, aralık rastgele, 8 ya da 10 da olabilir | §2.1, §5.1 tehlike modeli (taban + haftalık zar) |
| Olasılık: sunucu kademesi, doluluk, açık hata, hatalı sürüm | §5.1 formül; C sınırı §5.1 |
| Sürüm sonrası bozulma 4 hafta kuralına tabi mi | Tabi (§2.1, gerekçeli) |
| Kalan olaylar: 02:10 kesinti, ay sonu 23:40, ödeme, sürüm sonrası bozulma, yorum fırtınası | §2.2 olay 1–6. (inceleme) Ay sonu maili 22:10–22:55 damgalı, kart 23:00'te; 23:40 gün dönümü adımına düşerdi |
| B2C sürüm yorumları son kullanıcıdan ve mağazadan (inceleme) | Son kullanıcı yarısı B'de; mağaza yarısı E ile ("Mağaza" etiketi) |
| İstekler yalnız müşteri temsilcisiyle görünür (C sınırı) (inceleme) | "Ne zaman geliyor?" temsilci koşuluna bağlandı, konuşan temsilci |
| Satıcı ödemesi ikizi silinir | §2.2 "Kalanlar"; hiçbir kart yazılmaz |
| Seçenekler olaya göre değişir; "Sprinti durdur" duruma göre | §2.1 tablo |
| Ekip gece: süre metinde, ölçeğe göre | §2.1, §5.1 `hours_*`; seçenek metninde `{saat}` |
| Moral −6'dan büyük olabilir | −(6 + saat), en çok −10 (§5.6) |
| Verim düşüşü gerekli mi | Gerekmez, gerekçe §2.1 (moral çıktıyı zaten düşürür) |
| Kendin bak: yalnız tek ya da ≤2 kişi; bedel ne | §2.1: kurucu verimi −%15, 1 hafta; süre 1,5 kat |
| Sonraki sprinte bırak: bedel üstte yazar; B2B hesabın memnuniyeti | Seçenek çipleri "58 → 52"; kalıcı iz §5.3 |
| Ayrılma eşiği 30 civarı; iki senaryo karşılaştırması | §5.5 |
| B2C bırak: tam kesintide anında kayıp, düzeltilebilir hatada haftada %2 | §2.1, §5.1 |
| B2C tam kesinti: bırak kilitli + anlık bedel | Olay 2 ve 4: kilitli satır ve gerekçe; anlık kitle kaybı her seçenekte |
| Telafi B2B: SLA kredisi araştırmayla | %10 / %25 / %50, süreye göre (§4.1) |
| Telafi B2C: etkilenen kullanıcıyla orantılı, sabit $4.000 yok | Etkilenen ödeyen × aylık ücret; E'de sepet × %15 (§5.1) |
| Bedel olayın ölçeğinden türer | §5.1 bütün bedeller türetilir; sabitler katsayıdır |
| Kâğıt karta ve role özgü, o aşamadaki kişi konuşur | §2.3, §5.4 (`where` ile konuşmacı) |
| Yazım baştan; "Nadir ama para" yok; "yarısını önümüzdeki sprinte atarsak" | §6.2 kâğıtlar K2 ve K3 |
| PM ve testçi üslubu reddedildi | K3 (PM) ve K2, K7 (testçi) yeniden yazıldı |
| Geliştiricinin "altını yeniden yazayım" kâğıdı beğenildi | K1, liste başı |
| Kart sayısı artar, tekrar inanılmaz seyrek; koşu boyu hafıza; varyant | §5.4: 40 kâğıt, 52 hafta + en çok 3, görülmemiş önce, hat ve pazar varyantı |
| Söz olayı B2B onaylı 4 seçenek | §2.4, §6.3 |
| B2C ikizi yeniden tasarlanır | §2.4 "duyurulan tarih", §6.3 |
| Sürüm anı B2B teşekkür, çelişki yok | §2.5 zamanlama kuralı, §6.4 |
| Sürüm anı B2C 2–3 yorum, içerik ve kaliteye bağlı | §2.5 seçim kuralı, §6.5 |
| Müşteri görüşmesi eklenmez | §2.6 |
| Yatırımcı hazırlığı: kaldır / koru / derinleştir | Kaldır (§2.6), açık soru 1 |
| Sürüm duyurusu yok | §2.6 |
| TR ve EN, tire yok, taslak | §6 tamamı; commit'ler "TR/EN onay bekliyor" |
| Görev §5: olasılık modeli, motorun özellikleri, yeni bir şey gerekir mi | §5.1, §5.2 (motor: aile freni ve gecikme penceresi var ama zarı sistem atar; neden) |
| Görev §5: "Sprinti durdur" fiili, kapasite taşarsa | §5.2 `insert_urgent_fix` |
| Görev §5: erteleme izi: güven izi mi sayaç mı | Güven izi + sprint kapanışında ek düşüş (§5.3) |
| Görev §5: havuz büyüklüğü, varyant, seçenek sayısı, hafıza kayıtta mı | §5.4; hafıza motorun mandal kaydında (kayıtta zaten var) |
| Görev §5: en az 8 kâğıdın tam metni | §6.2: 9 kâğıt; kalan 31'in konu listesi §6.2 sonu |
| Görev §7: A'nın "Açık hata"sı, bozulan hat, C'nin sunucusu ve istek verisi | §5.7 A/B ve C varsayımları |
| Görev §8: kapılar dilimlere | §7 |

Karşılanmayan madde yok.

---

## 4. Araştırma bulguları
Kaynaklar `B_ARASTIRMA.md`'dedir; burada yalnız kararı etkileyenler.
1. **Kesinti kredisi (SLA).** Atlassian, AWS S3 ve commercetools aynı iskeleti kullanıyor: aylık erişilebilirlik %99,9
   altı → %10, %99,0 altı → %25, %95 altı → %50 (AWS'de %100). 30 günlük ayda %99,9 ≈ 43 dakika, %99,0 ≈ 7,2 saat,
   %95 ≈ 36 saat. Kredi otomatik değil, müşteri talep eder.
   → B2B "Telafi et" kademesi bu tablodur ve kesinti süresinden türer. Erdem'in "%10–20" tahmini kısa kesintide %10'a
   denk gelir; sabaha bırakılan gece kesintisi (≈8–9 saat) %25'e düşer (açık soru 5). Krediyi oyuncunun proaktif
   hamlesi olarak sunmak gerçekçi: müşteri istemeden verilen kredi güveni korur.
2. **E-ticaret telafisi.** Coupang iptal edilen siparişe yaklaşık 3–4$ değerinde bakiye verdi; Cabela's'ın tek günlük
   kuponu "telafi başarısızlığı" sayıldı; danışmanlık önerisi %10–20'lik tek seferlik indirim. Akademik bulgu:
   telafi kaybı azaltır, sıfırlamaz.
   → B2C telafisi etkilenen kişi sayısıyla orantılı ve kaybı yalnız üçte bir azaltır [ÇALIŞMA]; E'de sepet ortalamasının
   %15'i.
3. **Kesintinin B2C kaybı.** Anketlerde "bir daha dönmem" diyen %17–32 (beyan, davranış değil); kalıcı kayıp
   bunun beşte biri ile onda biri; nadir kesintide etki daha küçük.
   → Tam kesintide anlık kitle kaybı saat başına %0,5, en çok %8; düzeltilebilir hatada haftada %2 (karar defteri).
4. **Olay sıklığı.** RimWorld'ün anlatıcıları "en az aralık + ortalama süreli zar" kullanıyor (Cassandra: min 1,9 gün
   aralık, faz başına zar); Crusader Kings olay başına bekleme ve ortalama süreli üstel zar (MTTH). Koruma: ağır
   hasardan sonra bir sonraki aralık uzar; başlangıçta "tanıtım" koruması.
   → Taban 4 hafta + haftalık zar (geometrik aralık: hiç düzenli değil), "Servis çöktü"den sonra 6 hafta, v1.0'dan
   sonra 3 hafta koruma. Zar kayıt-güvenli hash'le atılır (yeniden yükleme sonucu değiştirmez).
5. **Kart tekrarı.** Reigns "çanta" modeli: önce duruma uymayanlar, sonra yakında görülenler elenir; 500 kartla bile
   tekrar hissi şikâyeti var. Slay the Spire'da "tek seferlik" olay koşu başına bir kez.
   → Durum süzgeci (rol, aşama, pazar, hat) + görülen kâğıda düşük ağırlık + 52 haftalık bekleme + koşu başına en
   çok 3. Havuz bitince kâğıt gelmez.

---

## 5. Model

### 5.1 Acil durum modeli (`IncidentSystem`, yeni statik sistem)
Neden yeni sistem: Olay motorunun aile freni sabit aralık verir ve havuz zarı haftalık "hiçbir şey" ağırlığıyla bütün
kartları birlikte çeker; girdilere (sunucu, doluluk, hata) göre değişen olasılık ve olayın ölçeği (etkilenen hesap,
saat, kredi) motorun işi değil. Kart sistem tarafından adıyla istenir (`EventGate.request`), CLAUDE.md §6 kuralı.
Durum: son olayın tiki ve ağırlığı, açık (ertelenmiş) olaylar listesi.
(inceleme) **Bedel ve neden var olan bir sisteme eklenmiyor:** orta; yeni durum evet (olay kaydı), yeni ekran yok. Aday
evler SupportSystem (A yeniden yazıyor) ve InfraSystem (C doluluğu ve aşımı söküyor). İkisine eklemek A ve C ile aynı
dosyalarda çakışma demek; ayrı dosya üç fazın dilimlerini birbirinden ayırır. Dosya küçük tutulur: tehlike, tür,
ölçek, tutuş, açık olaylar; metin ve bedel kartlarda kalır.

**Haftalık tehlike (günlük tikte):**
```
uygun        = canlı ürün ∧ (gün − son_olay) ≥ MIN_GAP (S1 sonrası 6, öbür 4) ∧ v1.0'dan ≥ 3 hafta
p_hafta      = BASE × TIER[kademe] × LOAD[doluluk] × (1 + min(açık_hata_toplam, 12) / 8), en çok P_MAX
zar          = EvDice benzeri hash(run_seed, hafta, "incident") ∈ [0,1)
olay         = uygun ∧ zar < p_hafta
```
- `TIER`: local 1,5 · cloud 1,0 · enterprise 0,6. `LOAD`: normal 1,0 · amber 1,6 · over 3,0.
- **C sınırı:** C sunucu kademesini kurar. Doluluk kalırsa okunur; kalkarsa `LOAD` düşer ve `BASE` 0,08 → 0,10'a
  çıkar (ortalamayı korumak için). C gelene kadar `InfraSystem.provider()` ve `capacity_state()` okunur.
  (inceleme) C planı doluluğu tamamen kaldırıyor (bot ölçümünde 97 haftada hiç aşılmadı). Öneri: B doluluğu hiç
  okumasın, `BASE` baştan 0,10, "yük" sebep cümlesi yazılmasın; C'nin sileceği kodu ve metni B yazmamış olur (sahip
  sorusu). Doluluk okunursa tek fonksiyonda (`_load_mult()`) durur ve C'nin dilimi yalnız onu siler.
  (inceleme) **Kademe çarpanının tek evi B'dir:** `TIER` tablosu `sprint.json` `incident.tier`'da durur ve
  `IncidentSystem.tier_mult(kademe)` ile okunur. C'nin sunucu ipucu bu fonksiyonu okur, sayıyı kopyalamaz. C planındaki
  ×1,6 / ×1,0 / ×0,5 ile B'nin 1,5 / 1,0 / 0,6'sı farklı; C tazelemesinde C'nin tablosu B'ye bağlanır.
  (inceleme) **Ar-Ge `incident_playbook`:** bugün aşım cezasını yumuşatıyor; C aşımı kaldırınca etkisi ölür. B onu
  devralır: araştırılmışsa bütün `hours_*` ×0,75 [ÇALIŞMA] (kesinti kısalır, bütün süreye bağlı bedeller küçülür).
  Ar-Ge metni C'de "kesintiye hazırlık" diye güncellenir.
- Beklenen aralık: 4 + 1/p. Örnek: cloud, normal yük, 6 açık hata → p = 0,14 → ortalama 11 hafta; local, aşım,
  12 hata → p = 0,60 (tavan) → 5,7 hafta; enterprise, 1 hata → p = 0,054 → 22 hafta.

**Hangi olay (ağırlıklı, hash'le):**
| Tür | Pazar | Koşul | Ağırlık |
|---|---|---|---|
| `outage` | ikisi | — | 1,0 × TIER × LOAD |
| `month_close` | B2B | ayın son haftası ∧ fatura/defter/nakit hattında ≥2 açık hata olan, o hatları kullanan hesap var | 1,5 |
| `checkout` | B2C | ücretli plan açık | 1,0 × (1 + ödeme ve çekirdek hatlarının açık hatası / 4) |
| `review_storm` | B2C | kitle ≥ 2.000 ∧ bir hatta ≥ 6 açık hata | 1,5 |
| `regression` | ikisi | yalnız sürüm yolundan (aşağı) | — |
Uygun tür yoksa o hafta olay olmaz (zar harcanmış sayılır).

**Sürüm yolu:** Sürüm kapanışında A'nın "bu sürümde hatalı çıkan hatlar" listesi kritik bir hat içeriyorsa ve pencere
uygunsa `regression` ertesi sabah 09:00'da istenir. Kritik hatlar `sprint.json` `incident.critical_lines` listesindedir
[ÇALIŞMA]: ERP Fatura, Defter, Stok, Nakit, ortak Güvenlik ve Dayanıklılık; not uygulamasında Senkron, Düzenleyici,
Yakalama; video'da Kurgu, Dışa aktarma hattı, Zaman çizelgesi.

**Saat:** Olaya bir başlama saati çekilir: kesinti 00:30–04:30, ay sonu 22:10–22:55 (inceleme), ödeme ve yorum
fırtınası 10:00–16:00 (inceleme: 17:00 ve sonrası gece toplu adımına düşer), sürüm sonrası bozulma 09:00. Başlama
dakikasından sonraki ilk saat adımının saatlik tikinde sistem kartı ister (inceleme: `skip_night` tam saatle ilerler,
dakikasız durur; kart başlama anından önce açılamaz). İstek kabul edilirse (`EventGate.request` true) aynı adımda
`TimeManager.hold_clock("incident")` alınır; adım bitince toplu adım `_can_step` false görüp durur, `clock_batch_ended`
kartı gösterir ve `main` kendi `"event"` tutuşunu alır. IncidentSystem kendi tutuşunu kart gösterilince bırakır
(`event_triggered`); istek reddedilirse tutuş hiç alınmaz (inceleme). 00:00 adımı kullanılmaz: o adımda gün dönümü, ay
kapanışı ve oto kayıt koşar. Karar verilince oyuncu saati başlatır, `skip_night` kaldığı saatten sürer (kodda var:
"an interrupted skip resumes once the hold is released"). RunProbe botunun gece kartını cevaplayıp saati yeniden
başlattığı B2'nin kapısında doğrulanır.

**Ölçek (seam'ler `olay.*`, hepsi türetilir):**
```
crew_factor   = 0,75 + 0,125 × en_iyi_geliştirici_yıldızı           (0★ yoksa seçenek kilitli)
hours_base    = {outage 3, month_close 3, checkout 2, regression 4, review_storm 3}
hours_night   = hours_base / crew_factor                              (yuvarlanmış, metinde)
hours_founder = 1,5 × hours_base / (0,75 + 0,125 × kurucu_yazılım_yıldızı)
hours_morning = (08:00 − başlama) + hours_base / crew_factor          (yalnız gece olayları)
downtime(act) = act'ın süresi; "sprint" için 1 hafta (B2B'de yalnız etkilenen hat), "defer" için düzeltilene kadar
B2B etkilenen  = gece ve kurucu yolunda yalnız gece vardiyalı hesaplar (sektör: lojistik, üretim, sağlık [ÇALIŞMA]);
                 sabah yolunda bütün hesaplar; S2'de A'nın hattı kullanan hesapları (A/B varsayımı)
B2B güven     = −min(10, round(0,8 × downtime_saat)) her etkilenen hesaba
B2B kredi     = Σ etkilenen hesap aylık ücreti × SLA_TIER(downtime): ≤0,72 sa 0 · ≤7,2 sa %10 · ≤36 sa %25 · üstü %50
                kredi seçilirse güven bedelinin %85'i silinir
B2C anlık kayıp = −min(%8, %0,5 × downtime_saat) × kitle   (checkout'ta %0,2 × saat)
B2C etkilenen  = kitle × ACTIVE_SHARE(0,35) × min(1, downtime_saat / 24); ödeyen payı = ödeyen / kitle
B2C iade       = etkilenen × ödeyen payı × aylık ücret; kaybı × (1 − 0,35)
checkout etkilenen = (ödeyen / 30 + yeni_ödeyen_günlük) × saat / 24      (E'de: saatlik sepet × saat)
checkout telafisi = yalnız E: etkilenen sepet × sepet ortalaması × 0,15
storm paylaşım = kitle × 0,025
storm etkilenen = A'nın hat etkilenen kullanıcısı (A/B varsayımı); özür seçeneği = etkilenen × ödeyen payı × ücret × 0,5
gece nöbeti moral = −min(10, 6 + round(hours_night)) geliştirici ve testçiye
gündüz ekibi    = ekip verimi −round(100 × hours_now / 40), 1 hafta
aceleden hata  = hash < 0,25 → o hatta +1 açık hata (A'nın ekleme fonksiyonu)
erteleme       = B2B güven −6 şimdi, her sprint kapanışında hat düzelmediyse −3; B2C kitle haftada −%2, en çok 8 hafta
sprint yolu    = B2B güven −3; B2C düzelene kadar kitle haftada −%1
```
Açık olay, hattın düzeltme kartı çıkınca kapanır (A'nın kart kapanışı sinyali); kanama durur.

### 5.2 Yeni fiil, seam ve motor eklentileri
**Fiiller** (`EvEffects`, çipleri `EvChips`; çip ve uygulanan değer aynı fonksiyondan okunur):
| Fiil | Ne yapar | Sahip seam'i |
|---|---|---|
| `incident {act}` (nötr; ekonomik bileşenler aşağıda ayrı fiillerle) | Açık olayı `act` ile kapatır ya da erteler: `night`, `now`, `founder`, `morning`, `sprint`, `defer`; süre, güven, kitle, moral, verim ve aceleden hata `IncidentSystem.apply(act)`'ta; çip `IncidentSystem.terms(act)` | `IncidentSystem` |
| `trust_delta {amount, accounts}` (nötr) | Hesabın kalıcı memnuniyet izi; `accounts`: slot (varsayılan), `decision_line` (kâğıdın hattını kullananlar), `incident` | `CustomerRegistry.set_trust_offset` |
| `sprint_card_trim {points | share, bugs, follow}` | Bekleyen kararın kartından puan çıkarır; kart çıkınca o hatta `bugs` açık hata yazılır; `follow` true ise hattın düzeltme kartı sonraki sütuna konur | `SprintSystem` |
| `sprint_card_test {mode: cut | covered}` | `cut`: kalan test işinin yarısı silinir ve kart `test_cut` işaretlenir; ihtimal sabit bir sayıya çıkmaz, `SprintSystem.escape_chance(card)` ne diyorsa odur (D gelene kadar bugünkü model kısaltılmış testi testsiz sayar; D gelince test kalitesi düşer, örnek %7 → %10). Çip önce ve sonrayı aynı fonksiyondan okur (inceleme). `covered`: D gelene kadar test uyan rolle yapılmış sayılır; D gelince testi gerçekte kim yaptıysa onun yıldızı okunur (inceleme: D'nin kalite modeliyle çakışmasın) | `SprintSystem` |
| `line_harden {weeks}` | Hatta `weeks` boyunca aşınmadan yeni hata düşmez | A/B varsayımı: A'nın hat seçim fonksiyonu |
| `promise_extend` / `promise_break` | Sözün sprintini +1 yapar (bir kez; B2B'de güven −3, B2C'de marka −1) / sözü şimdi bozar (var olan bozulma zinciri) | `PromiseRegistry` |
| `morale_all {scope}` (var olan fiile parametre) | `team` (koşan sprintin ekibi), `night_crew` (geliştirici + testçi) | `HRMoraleSystem.apply_delta` |
| `productivity_mod` (var olan fiil, değişmez) (inceleme) | Kurucu verimi ("Kendin bak" −%15, K6 −%20, K9 −%10) ve gündüz ekip verimi (`scope: team`) bu fiille yazılır; yeni fiil yok. D'nin kurucu payı formülü bunu okur | `HRSystem.add_productivity_mod` |

**Motor eklentisi:** `amount_seam` (+ isteğe bağlı `amount_mult`): ekonomik fiilin tutarı bir seam'den okunur
(`add_cash`, `audience_delta`). `EvEffects._amount` ve `EvChips.describe` aynı yardımcıyı kullanır; bağlamla
okunur. Bedelin olayın ölçeğinden türemesinin motor tarafı budur.

**Seam'ler:** `olay.clock`, `olay.cause` (load/provider/code), `olay.variant`, `olay.line_name`, `olay.night_accounts`,
`olay.affected_accounts`, `olay.affected_users`, `olay.active_now`, `olay.hours_night`, `olay.hours_now`,
`olay.end_founder`, `olay.hours_so_far`, `olay.credit_cost`, `olay.refund_cost`, `olay.shares`, `olay.crew_size`,
`olay.ask_count`; `urun.decision_phase`, `urun.decision_kind`, `urun.decision_line`, `urun.decision_line_name`,
`urun.decision_has_tester`, `urun.decision_line_bugs` (A), `urun.decision_contract_cost`, `urun.decision_license_year`,
`urun.decision_tester_week`, `urun.decision_promise_due`, `urun.decision_promise_public`, `urun.cut_test_finishes`,
`urun.ask_step_name`; `hr.role` (entity), `hr.on_decision_card` (entity); `musteri.promise_extended` (entity),
`musteri.met_step` (entity). `--event-vocab` yeniden üretilir.

**Kart sınıfı:** Olay kartları `class: interrupt`, `tags: ["critical"]` (bütçe tarafından kâğıda düşürülmez),
`tick: request`, `delay_weeks: [0, 0]`, `delay_reason: request`, `family: incident`, `expires_weeks: 1`,
`on_expire`: `incident {act: morning}` ya da `defer` (cevapsız kalırsa en pahalı yavaş yol).

### 5.3 Erteleme izi
Güven izi (`trust_offset`) kullanılır, yeni sayaç yok. Sebep: memnuniyet hedefi = ürün kararlılığı + güven izi; iz
haftada ≈2,8 puan (günde 0,4) affedilir (inceleme: kodda doğrulandı, `b2b_sales_system.gd` `_target_on` ve
`_forgiven_trust`; iz −25 ile +10 arasında kırpılır ve söz izini de taşır).
(inceleme) **Sınır notları:** (1) Aynı defter sözü de taşıdığı için C'nin memnuniyet ipucu bu terimi "söz" diye
adlandırmamalı; "güven (söz ve kesintiler)" yazar. (2) A hesap başına açık hata terimini hedefe ekleyecek; ertelenen
olayın hatası açık kaldıkça A'nın terimi zaten düşürür. B'nin −6 ve kapanış −3'ü bunun üstüne biner; B3 sonundaki
ölçüm bu çift sayımı ayrıca raporlar. −6'lık iz 2 haftada −0,4'e iner; bu yüzden düzelmeyen her sprint kapanışında
−3 eklenir (`IncidentSystem` sprint kapanışını dinler). Böylece "ertelemeyi alışkanlık yapan" oyuncunun hesabı gerçekten
riske girer, bir kez erteleyen affedilir.

### 5.4 Sprint ortası kâğıt motoru
- **Bütçe:** `sprint.json` `decision`: `{"week_chance": 0.45, "per_sprint": 1, "cooldown_weeks": 52, "max_fires": 3}`.
  `_request_decision` kart başına değil haftada bir zar atar; sprintte kâğıt geldiyse (`product.decision_sprint`
  damgası) bir daha atmaz. Zarı geçen haftada kâğıdın kartı, o hafta en çok işin yapılacağı koşan karttır.
- **Sıra:** Havuzdaki her kâğıda ağırlık `w / (1 + 2 × görülme)`; görülme sayısı motorun mandal kaydından okunur
  (`EvLatches.fires`, kayıtta zaten var). Hash'le ağırlıklı sıra kurulur, ilk kabul edilen gelir. Kabul etmeyen
  (role, aşamaya, pazara uymayan) motorun kendi kapısında elenir.
- **Mandal:** Her havuz kâğıdı `latch: {"cooldown_weeks": 52, "max_fires": 3}` ve `latch_key: "run"` (inceleme: `entity`
  anahtarında sayaç kişi başına tutulur, aynı kâğıt her konuşmacıyla yeniden 3 kez gelirdi; varsayılan zaten `run`,
  ama kâğıtlar `employee` slotu taşıdığı için açık yazılır ve lint'e kural olarak eklenir). `max_fires` bugün hiçbir
  kartta kullanılmıyor; `decision_no_fourth_show` vakası ilk kullanımın kanıtıdır. Kod ikisini birlikte zaten uyguluyor
  (`EvLatches.blocked_reason` önce `max_fires`, sonra bekleme); motor md §3.1 "alternatif" diyor → ayrılık motor md
  §27'ye yazılır.
- **Konuşmacı:** Kâğıdın `employee` slotu `where` ile seçilir: `hr.role == developer ∧ hr.on_decision_card`. Test
  aşamasında testçi yoksa `hr.role != tester ∧ hr.on_decision_card`. PM kâğıdı yalnız `hr.role == product_manager`.
  Kurucu tekken kâğıt slotsuzdur, gönderen kurucunun kendisidir (`sender: self`).
- **Söz kâğıdı** sistem tarafından ayrıca istenir (bütçeye sayılmaz): son hafta, karta bu sprinte söz verilmiş ve kart
  yetişmiyor. Varken "Sprint yetişmeyecek" gelmez (`urun.decision_promise_due == false` koşulu).
- **Havuz dağılımı (demo, 40):**

| Konuşan / aşama | B2B | B2C | İkisi | Toplam |
|---|---|---|---|---|
| PM (kart kapsamı, müşteri isteği) | 2 | 1 | 3 | 6 |
| Tasarımcı · tasarım | 2 | 2 | 4 | 8 |
| Geliştirici · geliştirme ve düzeltme | 2 | 2 | 6 | 10 |
| Testçi · test | 2 | 2 | 3 | 7 |
| Testçisiz test (testi yapan geliştirici) | 0 | 0 | 3 | 3 |
| Kurucu yalnız | 0 | 0 | 6 | 6 |
Var olan 6 kâğıt bunun içindedir ("Kendi renkleri" ile "Yine renkler" tek kâğıtta birleşir, ikinci kez gelişi gövde
varyantıdır). Kâğıt başına 2–4 seçenek; her seçenek beş para biriminden birine mal olur (kart puanı, çıkışta açık hata,
moral, kasa, hesabın memnuniyeti) ve en az iki farklı birim kullanılır.
- **Beklenen görünme:** Demo'da 30–38 kâğıt; durum süzgecinden geçen havuz herhangi bir anda ≈12–15 kâğıt; ilk yıl
  neredeyse hiç tekrar yok, ikinci yılda bir kâğıt en çok bir kez daha. EA'da havuz 100+ hedeflenir; havuz biterse
  kâğıt seyrekleşir.

### 5.5 Ayrılma eşiği · iki senaryo
Bugünkü eşik: 33 + 9 × (yıldız − 1) + sektör (sigorta +3, sağlık ve inşaat +5) → 33 · 42 · 45 · 51 · 56.
C'nin eşiği henüz yok; tablo "C varsayımı" [ÇALIŞMA] olarak 26 + 4 × (yıldız − 1) + sektör/2 → 26 · 30 · 32 · 34 · 38.
(inceleme) C planı artık yazıldı: 30 + 3 × (yıldız − 1) + ⌊sektör / 2⌋ → 1★ 30 · 2★ 33 · 2★ sigorta 34 · 3★ 36 ·
3★ sağlık 38. Aşağıdaki "C eşiği" sütunu bu sayılarla güncellendi; sonuç değişmiyor: ürün 45 ve tek ertelemede (39)
bütün hesaplar eşiğin üstünde, iki ertelemede (45 − 12 − 3 = 30) 2★ ve üstü riske girer.
Hesap memnuniyeti hedefinde duruyor; ürün kararlılığı iyi (55) ya da zayıf (45):

| Hesap | Bugünkü eşik | Ürün 55, D=6 → 49 | Ürün 55, D=3 → 52 | Ürün 45, D=6 → 39 | C eşiği | Ürün 55, D=6 | Ürün 45, D=6 |
|---|---|---|---|---|---|---|---|
| 1★ | 33 | güvende | güvende | güvende | 30 (inceleme) | güvende | güvende |
| 2★ | 42 | güvende | güvende | **risk** | 33 (inceleme) | güvende | güvende |
| 2★ sigorta | 45 | güvende | güvende | **risk** | 34 (inceleme) | güvende | güvende |
| 3★ | 51 | **risk** | güvende | **risk** | 36 (inceleme) | güvende | güvende |
| 3★ sağlık | 56 | zaten riskte | zaten riskte | zaten riskte | 38 | güvende | güvende (39); iki ertelemede **risk** (inceleme) |

Sonuç: (A) **Eşik iner, düşüş 6 kalır:** tek erteleme sağlam ürünü yakmaz; ikinci erteleme (−12 + kapanış −3) seçici
hesabı riske sokar. Ödünleşim okunur. (B) **Eşik kalır, düşüş 3'e iner:** iyi üründe ertelemenin neredeyse bedeli
kalmaz (bedava çıkış riski), zayıf üründe hesaplar zaten riskte olduğu için erteleme fark etmez. **Öneri: A** (D=6,
C'nin eşiği). Eşik inmezse D=4 (açık soru 4). Nihai değer ana oturumda C ile seçilir; çelişkide C'nin sayıları esastır.

### 5.6 Onay bekleyen sabitler (hepsi [ÇALIŞMA]; tek evleri `sprint.json` `incident` ve `decision` blokları)
`MIN_GAP` 4 · `MIN_GAP_AFTER_S1` 6 · `LAUNCH_QUIET` 3 · `BASE` 0,08 · `TIER` 1,5/1,0/0,6 · `LOAD` 1,0/1,6/3,0 ·
hata çarpanı payda 8, üst 12 · `P_MAX` 0,6 · tür ağırlıkları · `hours_base` · `crew_factor` 0,75 + 0,125/★ ·
kurucu süresi 1,5 kat · gece moral −(6 + saat) en çok −10 · aceleden hata %25 · kurucu verimi −%15 1 hafta ·
gece vardiyalı sektörler · güven −0,8/saat en çok −10 · kredi tablosu %10/%25/%50 · kredi güveni %85 siler ·
B2C anlık kayıp %0,5/saat en çok %8 · ACTIVE_SHARE 0,35 · iade kaybı %35 azaltır · checkout kayıp %0,2/saat ·
paylaşım %2,5 · erteleme B2B −6 ve kapanışta −3 · B2C −%2/hafta en çok 8 · sprint yolu B2B −3, B2C −%1/hafta ·
`decision.week_chance` 0,45 · `per_sprint` 1 · `cooldown_weeks` 52 · `max_fires` 3 · görülme ağırlığı 1/(1 + 2n) ·
~~`CUT_TEST_FAULTY` 0,7~~ (inceleme: silindi; Erdem testçisiz %40'ı bile fazla buldu, D'nin modeli %2–%14 arası.
"Testi kısalt" yalnız test işini yarıya indirir, ihtimal D'nin fonksiyonundan gelir) · söz uzatma güveni −3 · fazla
mesai moral −4 · teşekkür güveni +4 · B2C duyuru marka +1, güncelleme −1, kaçış bekleyenlerin %40'ı kitleden ve marka −2
(inceleme) · `incident_playbook` süre ×0,75 (inceleme) · yorum fırtınası eşiği kitle
2.000 ve 6 hata · ay sonu eşiği 2 hata · kâğıt bedelleri: dış geliştirici puan başı $1.000, lisans B2B koltuk başı yılda
$6, B2C kullanıcı başı yılda $0,30, dış testçi haftalığı orta seviye testçi maaşının 1/4,3'ü × 1,5.

(inceleme) **D'nin ×5 ölçeği:** Bu plandaki bütün puan miktarları bugünkü ölçektedir: kâğıt seçeneklerinin
`sprint_card_effort` / `sprint_card_progress` miktarları (K1 +2, K2 +1, K3 +1, K4 +2, K5 −3 ve −2, K7 +2 ve +1, K8 +2 ve
+4), `sprint_card_trim {points}` ve dış geliştiricinin "puan başı $1.000"u. Hepsi kart JSON'unda yazılır ve B5/B6'da bu
listeye satır olarak eklenir; D bu listeyi ×5 yapar ve puan başı fiyatı /5'e indirir. Çipler miktarı fiilin kendisinden
okuduğu için metin değişmez.

### 5.7 Varsayımlar
- **A/B varsayımı:** A şunları verir; adları A'nın commit'inden tazelenir: `ProductState.open_bugs(line)`,
  `open_bugs_total()`, `add_bugs(line, n)` (inceleme: A'nın görev yazısı ve C planı `ProductSystem.open_bugs()` ve
  `open_bugs_by_line()` adlarını kullanıyor; B0 tek ada bağlar), `affected(line) → {accounts, seats, users}`, sürüm kaydında hatalı çıkan
  hatlar listesi, düzeltme kartı kapanınca hattın hatasını silen kapanış (sinyal ya da çağrı). A düzeltme koşusunu ve
  `fix_run_start` fiilini silmediyse B'nin ilk commit'i siler; `product.bug_pile` B'de silinir.
- **C varsayımı:** Sunucu kademesi `InfraSystem.provider()`; doluluk kalırsa `capacity_state()`. Teşekkür maili ve B2C
  "hâlâ yok mu" yorumu istek verisini okur; C gelene kadar `GameState.product.requests` (B2B) okunur, B2C istek yorumu
  yazılmaz. (inceleme) C gelince okuma `SprintCatalog.known_requests()` ve `b2c_asks()` olur (C planı §5.7). C,
  B'den `founder_hours` fiili bekliyor; B'nin bedelleri `productivity_mod` ile yazıldığı için B bu fiili kurmaz, C kurar.
- **D varsayımı:** Hatalı çıkma ihtimali D'de testçiye bağlanır; ~~"Testi kısalt" o ihtimale sabit +30 puan ekler~~
  (inceleme) "Testi kısalt" yalnız test ihtiyacını düşürür, ihtimal D'nin `SprintSystem.escape_chance(card)`
  fonksiyonundan gelir (D planı §5.4). PM'in "önden gitmesi" kâğıdın PM rolünü değiştirmez.
- **E varsayımı:** Pazaryeri gelince Ödeme kartının sepet varyantı ve "Mağaza" (inceleme) yorum kaynağı E'nin
  sayılarını okur (`orders_in_hours`, `aov`, `sales.mkt_checkout_live`). (inceleme) E abonelik planını ve not ile video
  uygulamasını siliyor: B2C kesinti iadesi ve özür indirimi "ödeyen × aylık ücret" yerine E'de "üye × üyelik ücreti"
  okur; not ve video hatlarına yazılan belirti, alıntı ve yorumlar E2'de silinir (sahip sorusu 3).

### 5.8 Yeni durum (kayıt)
- `IncidentSystem`: `{last_day, last_severity, pending: {kind, hour, context}, open: [{kind, line, account_ids,
  since_day, act}]}`; `to_dict` / `from_dict`, `SaveManager.reset_all_owners`'a girer. Eski kayıtta boş açılır.
  (inceleme) Statik durum kaydın sistem bloğuna da elle girer (`save_manager.gd` ~373 ve ~389'daki `"product"`,
  `"rnd"` satırlarının yanına `"incident"`). Daha basit yol: durumu `GameState`'te tek bir sözlükte tutmak (SaveCodec
  kendisi bulur); uygulayıcı ikisinden birini seçer, ikisini birden değil.
- (inceleme) `line_harden` için hat başına bitiş tiki: `{hat: gün}`. Sahibi A'nın hat durumu (`ProductState`); planın
  ilk hâlinde yeni durum listesinde yoktu.
- (inceleme) B2C kamu sözü `PromiseRegistry.create` üstünden açılır; müşterisi olmadığı için `customer_id` sabit bir
  değer taşır (`"public"`), aksi hâlde `has_open_for("")` bütün boş kimlikli sorgulara true döner.
- `GameState.product.decision_sprint` (int, varsayılan −1).
- `Promise.source` (`account` | `public`, varsayılan `account`), `Promise.extended` (bool, varsayılan false).
- Kart: `card.trim_bugs` (int), `card.test_cut` (bool).
- `SCHEMA_VERSION` değişmez: yeni alanların hepsi anlamlı varsayılan taşır.

### 5.9 Silinecek ve değişen kod
- `data/events/cards/product/outage.json` → `incident_outage_b2b.json` + `incident_outage_b2c.json`; `EV_PRODUCT_OUTAGE_*`
  anahtarları silinir.
- `data/events/cards/product/bug_pile.json` ve `EV_PRODUCT_BUG_PILE_*`; A bıraktıysa `fix_run_start` fiili, çipi,
  `EFFECT_FIX_RUN_STARTS`, `destek.can_start_fix_run`.
- `sprint_colors_again.json` silinir, `sprint_hardcoded_colors.json` ikinci geliş varyantını taşır.
- `sprint_system.gd` `_request_decision`'ın kart başına zarı; `sprint.json` `decision.rate`.
- Yatırımcı hazırlığı (onaylanırsa): `VCPitchSystem.start_prep`, `prep_blocked_reason`, `_consume_prep`, `_tick_prep`,
  `_prep_focus` ve bonus dalları, `GameState.prep`, `pitch_prep_active` bayrağı ve okuyanları (`hr_system.gd` meşgul ve
  kurucu durumu, `rnd_system.gd`), `PitchConstants.PREP_*` ve `FOCUS_KEYS`, `hunt_tab.gd` `_prep_row` ve satırları,
  `HUNT_PREP_*`, `HUNT_FOCUS_*`, `VC_PREP_*` anahtarları, `founder.task_state`'in `pitch_prep` değeri, `main.gd` fikstür
  satırı, smoke vakaları (`endgame_smoke.gd` hazırlık vakaları). ACIK_KARARLAR 77'deki hazırlık cümlesi ana oturuma not.

---

## 6. Metin taslakları
Önce İngilizce, Türkçe yeniden yazımdır. Tire yok. Gerçek marka yok. Hepsi "TR/EN onay bekliyor". Kart metinleri
kartın `text.en` / `text.tr` bloklarında; tekrar kullanılan cümleler `strings.csv`'de. Belirteçler: `{customer}`,
`{employee}` slot adıdır; `{seam:...}` seam okur; belirtecin ardına ek gelmez.

### 6.1 Acil durumlar
**Olay 1 · `product.incident_outage_b2b`**
- Başlık: EN `{seam:olay.clock} · The service is down` · TR `{seam:olay.clock} · Servis durdu`
- Gövde, gece vardiyalı hesap var (`olay.variant` 0–2) / yok (3–5); sonuna sebep cümlesi (üç sebep). Altı varyant
  aşağıdaki parçaların birleşimi olarak tam cümle yazılır:
  - Gece var · EN: "The service went down at around {seam:olay.clock} and has not answered since.
    {seam:olay.night_accounts} accounts run a night shift and cannot get in; {customer} called first. The rest start at
    08:30." TR: "Servis saat {seam:olay.clock} sularında durdu, o zamandan beri cevap vermiyor. Gece vardiyasıyla
    çalışan {seam:olay.night_accounts} hesap sisteme giremiyor; ilk arayan {customer} oldu. Öbür hesaplar 08:30'da işe
    başlıyor." (inceleme: "itibarıyla" resmî yazı dili; "deposundan" sağlık sektöründeki hesapta yanlış olurdu)
  - Gece yok · EN: "The service went down at around {seam:olay.clock} and has not answered since. Nobody uses it at this
    hour, but every account starts at 08:30." TR: "Servis saat {seam:olay.clock} sularında durdu, o zamandan beri cevap
    vermiyor. Bu saatte sistemi kullanan yok, ama bütün hesaplar 08:30'da işe başlıyor." (inceleme)
  - Sebep, yük · EN: "The servers had been running at the edge of their capacity since the evening." TR: "Sunucular
    akşamdan beri kapasitelerinin sınırında çalışıyordu."
  - Sebep, sağlayıcı · EN: "The hosting provider restarted its machines in our region, and ours did not come back up."
    TR: "Barındırma sağlayıcısı bölgedeki makinelerini yeniden başlattı; bizimkiler geri açılmadı."
  - Sebep, kod · EN: "Since the last release the {seam:olay.line_name} service has been filling its memory and falling
    over." TR: "Son sürümden beri {seam:olay.line_name} servisi belleği doldurup çöküyor." (inceleme: "doldurup
    duruyor" iki anlama okunuyordu)
  - (inceleme) "Yük" sebebi yalnız doluluk okunursa yazılır; C doluluğu kaldırınca bu varyant silinir.
- Seçenekler (`EV_INCIDENT_*` ortak anahtarlar):
  - `EV_INCIDENT_NIGHT`: EN "Wake the team; the service is back in about {seam:olay.hours_night} hours" · TR "Ekibi
    uyandır; servis yaklaşık {seam:olay.hours_night} saatte açılır"
  - `EV_INCIDENT_FOUNDER`: EN "Handle it yourself; back up around {seam:olay.end_founder}" · TR "Kendin bak; servis
    {seam:olay.end_founder} sularında açılır"
  - `EV_INCIDENT_MORNING_CREDIT`: EN "Fix it with the team in the morning and credit the accounts for the outage" ·
    TR "Sabah ekiple düzelt, hesaplara kesinti kredisi tanımla"
  - `EV_INCIDENT_MORNING`: EN "Fix it with the team in the morning" · TR "Sabah ekiple düzelt"
  - Kilit gerekçeleri: `EV_INCIDENT_LOCK_NO_CREW` EN "Nobody on the team can fix it" · TR "Ekipte bunu düzeltebilecek
    kimse yok"; `EV_INCIDENT_LOCK_TEAM_SIZE` EN "The team is larger than two people" · TR "Ekip iki kişiyi geçti"
  - Süre doldu notu: EN "Nobody answered; the team fixed it when they came in." · TR "Cevap gelmedi; ekip sabah gelince
    düzeltti."

**Olay 2 · `product.incident_outage_b2c`**
- Başlık: EN `{seam:olay.clock} · The app will not open` · TR `{seam:olay.clock} · Uygulama açılmıyor`
- Gövde: EN "Since {seam:olay.clock} the app has been stuck on its opening screen. About {seam:olay.active_now} people
  are trying to get in right now, and the complaints have started on social media." + sebep cümlesi.
  TR: "Uygulama saat {seam:olay.clock} sularında açılış ekranında takılı kalmaya başladı. Şu anda
  {seam:olay.active_now} kişi girmeye çalışıyor; sosyal medyada şikâyetler başladı." + sebep cümlesi. (inceleme)
- Seçenekler: `EV_INCIDENT_NIGHT` (EN "...the app is back in about {h} hours" / TR "...uygulama yaklaşık {h} saatte
  açılır" varyantı), `EV_INCIDENT_FOUNDER`, `EV_INCIDENT_MORNING_REFUND`: EN "Fix it in the morning and refund a
  month to the paying users it hit" · TR "Sabah düzelt; etkilenen ücretli kullanıcılara bir aylık ücretlerini iade
  et" (inceleme); `EV_INCIDENT_MORNING`; `EV_INCIDENT_DEFER` EN "Leave it to the next sprint" · TR "Sonraki sprinte
  bırak", kilitli, gerekçe `EV_INCIDENT_LOCK_APP_DOWN` EN "Right now the app opens for nobody." · TR "Uygulama şu anda
  kimseye açılmıyor." (inceleme: "bekleyecek bir şey yok" gerekçenin kendi hükmüydü; CLAUDE.md §5 kilit gerekçesi
  yalnız olguyu söyler)

**Olay 3 · `customer.incident_month_close`** (`sender: contact`)
- Başlık: EN "We cannot close the month" · TR "Ay sonu kapanışını yapamıyoruz"
- Gövde, hatta göre:
  - Fatura · EN: "Good evening. Batch approval of invoices has been failing since the afternoon. Our accounting team
    closes the month tomorrow at 09:00 and cannot start without this step. Is there anyone who can look at it
    tonight?" TR: "İyi akşamlar. Toplu fatura onayı öğleden sonradan beri hata veriyor. Muhasebe ekibimiz ay sonu
    kapanışını yarın sabah 09:00'da yapacak ve bu adım olmadan başlayamıyor. Bu gece bakabilecek biri var mı?"
  - Defter · EN: "Good evening. Since the afternoon the ledger no longer matches the bank, and the difference grows with
    every entry. Our accounting team closes the month tomorrow at 09:00 and cannot start with the books like this. Is
    there anyone who can look at it tonight?" TR: "İyi akşamlar. Öğleden sonradan beri defter bankayla tutmuyor; her
    yeni kayıtla fark büyüyor. Muhasebe ekibimiz ay sonu kapanışını yarın sabah 09:00'da yapacak ve defter bu hâldeyken
    başlayamıyor. Bu gece bakabilecek biri var mı?"
  - Nakit · EN: "Good evening. The cash table is counting this month's collections twice, so the month looks better
    than it is. Our accounting team closes tomorrow at 09:00 and presents these figures to the owners. Is there anyone
    who can look at it tonight?" TR: "İyi akşamlar. Nakit tablosu bu ayın tahsilatlarını iki kez sayıyor; ay olduğundan
    iyi görünüyor. Muhasebe ekibimiz kapanışı yarın sabah 09:00'da yapacak ve bu rakamları şirket sahiplerine sunacak.
    Bu gece bakabilecek biri var mı?"
- Seçenekler: `EV_INCIDENT_TONIGHT` EN "Put the team on it tonight; done in about {seam:olay.hours_night} hours" · TR
  "Ekip bu gece başına otursun; yaklaşık {seam:olay.hours_night} saatte biter"; `EV_INCIDENT_FOUNDER_DONE` EN "Handle
  it yourself; done around {seam:olay.end_founder}" · TR "Kendin bak; {seam:olay.end_founder} sularında biter";
  `EV_INCIDENT_SPRINT` EN "Stop the sprint and put the fix at the top" · TR "Sprinti durdur, düzeltmeyi sprintin başına
  al"; `EV_INCIDENT_DEFER_CLOSE` EN "Ask them to close by hand this month; fix it next sprint" · TR "Bu ay kapanışı
  elle yapmalarını rica et; düzeltmeyi sonraki sprinte al".

**Olay 4 · `product.incident_checkout`**
- Başlık: EN "Payments are failing" · TR "Ödeme alınamıyor"
- Gövde (abonelik): EN "Card payments have been declined at the last step since {seam:olay.clock}. In the last
  {seam:olay.hours_so_far} hours, {seam:olay.affected_users} people tried to start or renew a subscription and could
  not. Free use is unaffected." TR "Kart ödemeleri saat {seam:olay.clock} sularından beri son adımda reddediliyor.
  Son {seam:olay.hours_so_far} saatte {seam:olay.affected_users} kişi aboneliğini başlatmak ya da yenilemek istedi ama
  yapamadı. Ücretsiz kullanım etkilenmiyor." (inceleme)
- Gövde (pazaryeri, E gelince): EN "Checkout has been stuck at card approval since {seam:olay.clock}. In the last
  {seam:olay.hours_so_far} hours, {seam:olay.affected_users} baskets were left at the payment step." TR "Ödeme adımı
  saat {seam:olay.clock} sularından beri kart onayında takılıyor. Son {seam:olay.hours_so_far} saatte
  {seam:olay.affected_users} sepet ödeme adımında kaldı." (inceleme)
- Seçenekler: `EV_INCIDENT_NOW` EN "Pull the team onto it; fixed in about {seam:olay.hours_now} hours" · TR "Ekibi
  hemen başına al; yaklaşık {seam:olay.hours_now} saatte düzelir"; `EV_INCIDENT_FOUNDER_FIXED` EN "Handle it yourself;
  fixed around {seam:olay.end_founder}" · TR "Kendin bak; {seam:olay.end_founder} sularında düzelir";
  yalnız pazaryerinde (E) `EV_INCIDENT_NOW_COUPON` EN "Fix it now and give the {seam:olay.affected_users} baskets a
  discount worth 15% of an average order" · TR "Hemen düzelt; ödeme adımında kalan {seam:olay.affected_users}
  sepete sepet ortalamasının %15'i kadar indirim tanımla"; (inceleme) `EV_INCIDENT_SPRINT` (Olay 3'teki anahtar; bedel
  çipte: kayan kart ve süren kayıp); `EV_INCIDENT_DEFER` kilitli, `EV_INCIDENT_LOCK_NO_PAY` EN "Right now nobody can
  pay." · TR "Şu anda kimse ödeme yapamıyor." (inceleme)

**Olay 5 · `product.incident_regression`**
- Başlık: EN "Something broke in {seam:urun.version_label}" · TR "{seam:urun.version_label} sonrası bir şey bozuldu"
- Gövde: EN "Since {seam:urun.version_label} went out, {belirti}. It was not there in the previous version. {son}"
  TR "{seam:urun.version_label} çıktığından beri {belirti}. Önceki sürümde böyle bir şey yoktu. {son}"
  (inceleme) `{belirti}`, `{son}`, `{ekran}` motor belirteci DEĞİLDİR; kart gövdesinde yalnız `{slot}` ve
  `{seam:ns.ad}` çözülür, gerisi ekrana süslü parantezle çıkar. Gövde, hat ve pazar başına TAM cümle olarak yazılır ve
  var olan `{"by_seam": "olay.variant", "variants": {...}}` biçimiyle seçilir (`presenter.gd` `_resolve_variant`). Aynı
  kural Olay 6'daki `{alıntı}` için de geçerlidir.
  - Son cümle B2B · EN "{seam:olay.affected_accounts} accounts use the {ekran} screen every day." TR "{ekran} ekranını
    her gün {seam:olay.affected_accounts} hesap kullanıyor." B2C · EN "{seam:olay.affected_users} people use it every
    day." TR "Her gün {seam:olay.affected_users} kişi kullanıyor."
  - Belirtiler (hat başına bir varyant; ERP ve not uygulaması tam, video ve ortak B2C hatları yazım adımında):

| Hat | EN | TR |
|---|---|---|
| ERP Stok | some products show a negative count in the stock take | stok sayımında bazı ürünler eksi adetle görünüyor |
| ERP Fatura | the same invoice is going out twice to some customers | bazı müşterilere aynı fatura iki kez gidiyor |
| ERP Defter | period balances no longer match the bank statements | dönem bakiyeleri banka ekstresiyle tutmuyor |
| ERP Nakit | receivables that fall due show up a day late in the table | vadesi gelen alacaklar tabloda bir gün geç görünüyor |
| ERP Veri Girişi | the last row of every imported spreadsheet is skipped | içe aktarılan her tablonun son satırı atlanıyor |
| Ortak Entegrasyon (ERP) | bank transactions land in the ledger twice | banka hareketleri deftere iki kez düşüyor |
| Ortak Güvenlik (ERP) | warehouse staff without the right can see the cost column | yetkisi olmayan depocular maliyet sütununu görebiliyor |
| Ortak Dayanıklılık (ERP) | saved changes revert when the page is reloaded | kaydedilen değişiklikler sayfa yenilenince geri dönüyor |
| Ortak Mobil (ERP) | the approve button falls off the screen on phones | telefonda onay düğmesi ekranın dışında kalıyor |
| Not Yakalama | the quick note box closes without saving what was typed | hızlı not kutusu yazılanı kaydetmeden kapanıyor |
| Not Bağlantı | links between notes open onto a blank page | notlar arasındaki bağlantılar boş sayfaya açılıyor |
| Not Senkron | a note deleted on one device comes back on the other | bir cihazda silinen not ötekinde geri geliyor |
| Not Düzenleyici | in long notes the cursor jumps to the start of the paragraph | uzun notlarda imleç paragrafın başına sıçrıyor |
| Not Arama | search no longer finds notes from the last two days | arama son iki günün notlarını bulmuyor |

- Seçenekler: `EV_INCIDENT_SPRINT_FIX` EN "Stop the sprint; the fix goes to the top" · TR "Sprinti durdur, düzeltme
  sprintin başına geçsin"; `EV_INCIDENT_EVENING` EN "Have the team stay tonight; fixed in about {seam:olay.hours_night}
  hours" · TR "Ekip bu akşam kalsın; yaklaşık {seam:olay.hours_night} saatte düzelir"; `EV_INCIDENT_FOUNDER_FIXED`;
  `EV_INCIDENT_DEFER`.

**Olay 6 · `product.incident_review_storm`**
- Başlık: EN "A post shared {seam:olay.shares} times" · TR "Bir gönderi {seam:olay.shares} kez paylaşıldı" (inceleme:
  virgüllü başlık slogan gibi duruyordu)
- Gövde: EN "A post about {seam:olay.line_name} has been shared {seam:olay.shares} times since this morning: {alıntı}
  Most of the replies say the same thing happened to them." TR "{seam:olay.line_name} hakkındaki bir gönderi sabahtan
  beri {seam:olay.shares} kez paylaşıldı: {alıntı} Altına yazanların çoğu aynı şeyi yaşadığını söylüyor."
- Alıntılar (hat başına; yorum satırıyla ortak, §6.5):
  - Not Senkron · EN "“I deleted a note on my phone and it came back on my laptop. I deleted it on the laptop and now
    it is back on my phone.”" TR "“Telefonda sildiğim not bilgisayarda geri geldi. Bilgisayarda sildim, bu sefer
    telefonda geri geldi.”"
  - Not Arama · EN "“Search cannot find anything I wrote this week. I have gone back to mailing notes to myself.”"
    TR "“Arama bu hafta yazdığım hiçbir şeyi bulmuyor. Notlarımı yine kendime mail atarak tutmaya başladım.”"
  - Video Altyazı · EN "“The captions turn every ğ and ş into a question mark. I have been fixing them by hand for a
    week.”" TR "“Altyazılarda her ğ ve ş soru işaretine dönüyor. Bir haftadır elle düzeltiyorum.”"
- Seçenekler: `EV_INCIDENT_STATEMENT` EN "Reply publicly and put the fix at the top of the sprint" · TR "Açıklama yap,
  düzeltmeyi sprintin başına al"; `EV_INCIDENT_EVENING`; `EV_INCIDENT_APOLOGY` EN "Apologise, give the paying users it
  hit a month at half price, and fix it next sprint" · TR "Özür dile, etkilenen ücretli kullanıcılara bir ay yarı
  fiyat tanımla; düzeltmeyi sonraki sprinte bırak" (inceleme: yüklemsiz bitiyordu); `EV_INCIDENT_SILENT` EN "Say nothing and leave it to the next sprint" · TR "Bir şey
  söyleme, sonraki sprinte bırak".

**Çip anahtarları (yeni):** `EFFECT_TRUST_ACCOUNT` "{customer}: memnuniyet {from} → {to}" / "{customer}: satisfaction
{from} → {to}"; `EFFECT_TRUST_ACCOUNTS` "{n} hesap: memnuniyet {v}" / "{n} accounts: satisfaction {v}";
`EFFECT_AUDIENCE_NOW` "Kitle {v}" / "Audience {v}"; `EFFECT_AUDIENCE_WEEKLY` "Düzelene kadar kitle haftada {v}" /
"Audience {v} a week until fixed"; `EFFECT_NIGHT_CREW` "{names}: moral {v}" / "{names}: morale {v}";
`EFFECT_RUSH_BUG` "%{p} ihtimalle aceleden yeni hata" / "{p}% chance of a new bug from the rush";
`EFFECT_SPRINT_BUMP` "{card} sonraki sprinte kayar" / "{card} moves to the next sprint"; `EFFECT_SHIP_BUGS` "Çıkışta
{line}: {n} açık hata" / "{line} ships with {n} open bugs"; `EFFECT_LINE_HARDEN` "{line} hattına {weeks} hafta yeni hata
düşmez" / "No new bugs on {line} for {weeks} weeks"; `EFFECT_FOLLOW_FIX` "Kalan iş sonraki sprintte" / "The rest goes
to next sprint"; `EFFECT_FAULTY_CHANCE` "Hata ihtimali %{from} → %{to}" / "Bug chance {from}% → {to}%";
`EFFECT_PROMISE_BREAKS` "Söz bozulur" / "The promise breaks"; `EFFECT_CREDIT` "Kesinti kredisi" / "Outage credit"
(Finans satırı).

### 6.2 Sprint ortası kâğıtlar (9 tam metin)
Her kâğıt `family: sprint_*`, `tick: request`, `class: paper`, `expires_weeks: 1`, mandal 52 hafta + en çok 3.

**K1 · `product.sprint_dev_root_cause`** · Geliştirici · düzeltme kartı · hatta ≥3 açık hata · ikisi
- Başlık EN "Three bugs from the same place" · TR "Üç hata aynı yerden çıkıyor" (inceleme: kâğıt başlıkları mail konusu
  gibi tam cümle; kesik başlıklar slogan gibi duruyordu)
- EN: "Three of the {seam:urun.decision_line_name} bugs on this card come from the same place: a piece of code nobody
  has touched since the first version. I can patch the three of them one by one, or rewrite that part from the ground
  up. If I rewrite it, they stop coming back."
- TR: "Bu karttaki {seam:urun.decision_line_name} hatalarının üçü aynı yerden çıkıyor: ilk sürümden beri kimsenin
  dokunmadığı bir kod parçası. Üçünü ayrı ayrı yamayabilirim ya da o kısmı baştan yazabilirim. Baştan yazarsam bir
  daha dönmezler."
- Seçenekler: EN "Rewrite it from the ground up" / TR "Altını baştan yaz" → kart +2, `line_harden 26` ·
  EN "Patch the three and move on" / TR "Üçünü yamala, devam et" → `sprint_card_trim {points 0, bugs 1}` ·
  EN "Have a contractor do the rewrite" / TR "Yeniden yazımı dışarıdan birine yaptır" → kasa −`decision_contract_cost`,
  `line_harden 26`
- Süre doldu: EN "No answer came, so the three were patched." / TR "Cevap gelmedi; üçü yamalandı."

**K2 · `product.sprint_test_tax_discount`** · Testçi · test · B2B · Fatura ya da Nakit hattı
- Başlık EN "Tax on discounted invoices is wrong" · TR "İskontolu faturada KDV yanlış hesaplanıyor" (inceleme)
- EN: "When an invoice carries a discount, the tax is worked out on the full amount instead of the discounted one. On a
  single invoice the difference is tiny, but once a year of invoices adds up, it is the first thing an audit will
  catch."
- TR: "Faturada iskonto varsa KDV, indirimli tutar yerine tam tutar üzerinden hesaplanıyor. Tek bir faturada fark çok
  küçük; ama bir yılın faturaları toplanınca denetimde ilk göze batacak şey bu olur." (inceleme: son cümle vurgu
  cümlesi gibi ayrı duruyordu)
- Seçenekler: EN "Fix it before it ships" / TR "Çıkmadan düzelt" → kart +1 (inceleme: "bir gün geç" haftalık tik
  modelinde karşılığı olmayan bir birimdi; bedel çipte puan olarak yazar) ·
  EN "Ship with discounts switched off on invoices" / TR "Faturada iskontoyu bu sürüm için kapatıp çık" →
  `trust_delta −2, accounts: decision_line` · EN "Log it as a known issue and ship" / TR "Bilinen sorun olarak
  kaydet, çık" → `sprint_card_trim {bugs 1}`
- Süre doldu: EN "No answer came; it shipped as it was." / TR "Cevap gelmedi; olduğu gibi çıktı." (→ bugs 1)

**K3 · `product.sprint_pm_scope`** · PM · tasarım ya da geliştirme · müşteri isteği kartı · B2B
- Başlık EN "What {customer} asked for" · TR "{customer} ne istemişti"
- EN: "{customer} asked for this card, and we grew it while we were drawing it. What they asked for was a single list
  screen; we added filters and an export on top. Those two are our idea. If we push them to next sprint, this card
  finishes this sprint."
- TR: "Bu kartı {customer} istedi; biz çizerken büyüttük. Onların istediği tek bir liste ekranıydı, biz üstüne filtre
  ve dışa aktarma ekledik. Bu ikisi bizim fikrimiz. Onları önümüzdeki sprinte atarsak kart bu sprintte biter."
- Seçenekler: EN "Push the filters and export to next sprint" / TR "Filtreyle dışa aktarmayı önümüzdeki sprinte at" →
  `sprint_card_trim {share 0.4, follow true}`; ertelenen iş sonraki sprinte kesilen puan + 1 puanlık yeniden açma
  payıyla döner [ÇALIŞMA] (inceleme: ilk hâlinde `bugs 2` vardı; kapsamı ertelemek hata üretmez, metinle çelişiyordu.
  Bedelsiz kalmasın diye yeniden açma payı eklendi; çip "Kalan iş sonraki sprintte · +1 puan") · EN "Build it as drawn" / TR "Çizildiği gibi yap" → statüko
  (kapasiteyi kullanır; sprint yetişmezse "Sprint yetişmeyecek" gelir) · EN "Show {customer} the drawing and let them
  decide" / TR "Çizimi müşteriye göster, kararı onlar versin" → kart +1, `trust_delta +3` ({customer})
- Süre doldu: EN "Nobody decided; the card stayed as drawn." / TR "Karar verilmedi; kart çizildiği gibi kaldı."

**K4 · `product.sprint_design_first_screen`** · Tasarımcı · tasarım · B2C · Onboarding alanı
- Başlık EN "Two versions of the first screen" · TR "İlk ekranın iki hâli var" (inceleme)
- EN: "I have two versions of the first screen. One asks three questions before letting people in; the other lets them
  straight in and asks later, one question at a time. The second keeps more people, but every screen behind it has to
  change."
- TR: "İlk ekranın iki hâli var. Biri içeri almadan önce üç soru soruyor; öteki hemen içeri alıyor, soruları sonra
  teker teker soruyor. İkincisi daha çok kişiyi tutar ama arkasındaki her ekranın değişmesi gerekiyor."
- Seçenekler: EN "Let them straight in" / TR "Hemen içeri alan hâli yap" → kart +2 · EN "Go with the three questions" /
  TR "Üç soruyla çık" → tek seferlik kitle kaybı: haftalık yeni kullanıcının %10'u × 8 hafta, `audience_delta` +
  `amount_seam` [ÇALIŞMA] (inceleme: ilk hâlinde `bugs 1` vardı; bir tasarım seçimi hata değildir ve gövde "daha
  çok kişiyi tutar" diyor, bedel tutulamayan kişilerdir. Alan adı C'de "İlk kullanım" olur)
- Süre doldu: EN "No answer came; it shipped with the three questions." / TR "Cevap gelmedi; üç soruyla çıktı."

**K5 · `product.sprint_dev_component`** · Geliştirici · geliştirme · kart ≥5 puan · ikisi
- Başlık EN "There is a ready-made component for this" · TR "Bu iş için hazır bir bileşen var" (inceleme)
- EN: "There is a ready-made component that does what this card needs. It is licensed per user; at our size a year
  costs {seam:urun.decision_license_year}. There is also a free version, but nobody has maintained it for two years.
  Writing it ourselves takes most of what is left of the sprint."
- TR: "Bu kartın ihtiyacını karşılayan hazır bir bileşen var. Kullanıcı başına lisanslanıyor; bizim büyüklüğümüzde bir
  yılı {seam:urun.decision_license_year} tutuyor. Ücretsiz bir sürümü de var ama iki yıldır kimse bakmıyor. Kendimiz
  yazarsak sprintin kalanının çoğu gider."
- Seçenekler: EN "Buy the licence" / TR "Lisansı al" → kasa −`decision_license_year`, kart −3 · EN "Use the free
  version" / TR "Ücretsiz sürümü kullan" → kart −2, `sprint_card_trim {bugs 1}` · EN "Write it ourselves" / TR
  "Kendimiz yazalım" → statüko
- Süre doldu: EN "No answer came; the team kept writing it." / TR "Cevap gelmedi; ekip yazmaya devam etti."

**K6 · `product.sprint_untested`** · Testi yapan geliştirici · test · testçi yok · ikisi
- Başlık EN "Testing my own code" · TR "Kendi kodumu test etmek"
- EN: "There is no tester on this card, so I am testing it myself. I wrote this code, and the cases I did not think of
  while writing it are the same ones I will not think of while testing it."
- TR: "Bu kartta testçi yok, testi ben yapıyorum. Bu kodu ben yazdım; yazarken aklıma gelmeyen durumlar test ederken
  de aklıma gelmeyecek."
- Seçenekler: EN "Test it yourself" / TR "Testi sen yap" → kurucu verimi −%20, 1 hafta; `sprint_card_test {covered}` ·
  EN "Hire an outside tester for a week" / TR "Bir haftalığına dışarıdan testçi tut" → kasa −`decision_tester_week`;
  `sprint_card_test {covered}` · EN "Let {employee} test it" / TR "{employee} test etsin" → statüko. (inceleme)
  Gövdede ihtimal yazmıyordu; her seçeneğin çipi `EFFECT_FAULTY_CHANCE` ile önce ve sonrayı gösterir (D'nin
  fonksiyonu). D gelince "Testi sen yap" kurucunun gerçek Test yıldızıyla hesaplanır; Test 0★ kurucu, ikincil rolde
  test yapan geliştiriciden iyi değildir (D tablosu %11 ve %10,4). Bu seçenek o durumda çipte dürüstçe kötü görünür.
- Süre doldu: EN "No answer came; {employee} tested it." / TR "Cevap gelmedi; testi {employee} yaptı."

**K7 · `product.sprint_test_sync_clash`** · Testçi · test · B2C not uygulaması · Senkron hattı
- Başlık EN "An edit made on two devices gets lost" · TR "İki cihazda yazılan değişiklik kayboluyor" (inceleme)
- EN: "When the same note is edited on two devices in the same minute, one of the edits quietly disappears. It only
  happens to people who use two devices and type on both at once, and they are the ones who use the app most."
- TR: "Aynı not iki cihazda aynı dakika içinde düzenlenince değişikliklerden biri sessizce kayboluyor. Yalnız iki
  cihaz kullanıp ikisinde aynı anda yazanların başına geliyor; uygulamayı en çok kullananlar da onlar." (inceleme:
  "en sadık" bir değerlendirmeydi; olgu "en çok kullananlar")
- Seçenekler: EN "Fix it before it ships" / TR "Çıkmadan düzelt" → kart +2 · EN "Keep both versions when they clash" /
  TR "Çakışınca iki sürümü de sakla" → kart +1, `sprint_card_trim {bugs 1}` · EN "Hold the card until next sprint" /
  TR "Kartı sonraki sprinte bırak" → `sprint_card_carry`
- Süre doldu: EN "No answer came; it shipped with the clash." / TR "Cevap gelmedi; çakışmayla çıktı." (→ bugs 2)

**K8 · `product.sprint_design_customer_colors`** (iki renk kâğıdının birleşimi) · Tasarımcı · tasarım · B2B
- Başlık EN "Their own colours" · TR "Kendi renkleri" (var olan anahtar)
- EN (ilk): "{customer} wants the screens in their own colours. The colours are written into the code screen by
  screen, so changing them means going through every screen by hand. If I gather them into one file first, next time
  it is a single change."
- TR (ilk): "{customer} ekranları kendi renklerinde istiyor. Renkler kodun içine ekran ekran yazılmış; değiştirmek her
  ekranı tek tek elden geçirmek demek. Önce hepsini tek dosyaya toplarsam bir dahaki sefere tek bir değişiklik olur."
- EN (ikinci geliş): "The {customer} team wants their own colours too. Last time we changed them by hand, so this time
  will take just as long."
  TR: "{customer} ekibi de ekranları kendi renklerinde istiyor. Geçen sefer renkleri elle değiştirdik; bu sefer de
  aynı süreyi alacak." (inceleme: "{customer} da" belirtecin ardına ünlü uyumlu ek getiriyordu, "Ekol da / Lale de";
  token kuralı ihlali. "ekibi de" uyumu sabitler)
- Seçenekler (var olan anahtarlar): elle → kart +2 · tek dosya → kart +4, ikinci geliş bir daha olmaz · serbest
  çalışan → kasa −`decision_contract_cost` · "Renkler değişmeyecek de" → `trust_delta −4` ({customer}) (bugünkü
  `satisfaction_delta −5` yerine)

**K9 · `product.sprint_solo_rushed_code`** · Kurucu yalnız · geliştirme · kart ≥3 puan · ikisi (`sender: self`)
- Başlık EN "A note to yourself" · TR "Kendine not"
- EN: "Writing this card, you see that the {seam:urun.decision_line_name} code was put together in a hurry for the first
  version. Tidying it would take an evening each week for the next two weeks. Left as it is, it will keep throwing up
  small faults."
- TR: "Bu kartı yazarken {seam:urun.decision_line_name} kodunun ilk sürüm için aceleyle kurulduğunu görüyorsun.
  Toparlamak önümüzdeki iki hafta her hafta bir akşamını alır. Böyle kalırsa küçük hatalar çıkarmaya devam edecek."
- Seçenekler: EN "Give it your evenings" / TR "Akşamlarını buna ver" → kurucu verimi −%10, 2 hafta; `line_harden 26` ·
  EN "Make a note and keep going" / TR "Not al, devam et" → `sprint_card_trim {bugs 1}`
- Süre doldu: EN "No answer came; the code stayed as it was." / TR "Cevap verilmedi; kod olduğu gibi kaldı." (inceleme:
  "Not, not olarak kaldı" kelime oyunu, kesik vurgu)

**Kalan 31 kâğıdın konu listesi** (yazım adımında tam metin; konuşan · aşama · pazar · bedel birimleri):
1. PM · B2B · iki hesap aynı ekranı farklı istiyor (güven / puan)
2. PM · ikisi · kart planlanırken başka bir kartın verisine bağlı çıkıyor (taşıma / puan)
3. PM · B2C · en çok sorulan şey ile planlanan kart farklı (puan / marka)
4. PM · ikisi · kabul ölçütü yazılmamış; ekip farklı anlıyor (puan / açık hata)
5. PM · ikisi · rakibin aynı özelliği çıktı; bizimki ona benziyor (puan / marka) [var olan rakip kaydı]
6. Tasarımcı · B2B · muhasebeci tabloları kâğıttan alışık olduğu sırada istiyor (puan / güven)
7. Tasarımcı · ikisi · telefonda tablo dağılıyor (puan / açık hata)
8. Tasarımcı · B2C · koyu renk tema isteği (puan / kitle yok; marka)
9. Tasarımcı · ikisi · aynı düğme üç ekranda üç farklı yerde (puan / açık hata)
10. Tasarımcı · B2C · video: kadraj önizlemesi yavaş (puan / açık hata)
11. Tasarımcı · ikisi · erişilebilirlik: renk körü için durum renkleri (puan / güven ya da marka)
12. Tasarımcı · B2B · depocu eldivenle dokunuyor, düğmeler küçük (puan / güven)
13. Geliştirici · ikisi · "İki yol var" (var olan, konuşmacı eklenir)
14. Geliştirici · ikisi · "Dışarıdan destek" (var olan, konuşmacı eklenir)
15. Geliştirici · ikisi · "Arayüz baştan yazılmış" (var olan, ekip ≥3)
16. Geliştirici · B2B · eski müşteri verisi yeni alanla uyuşmuyor; taşıma betiği (puan / güven)
17. Geliştirici · B2C · video dışa aktarma telefonda pili bitiriyor (puan / açık hata)
18. Geliştirici · ikisi · bağımlılığın güvenlik güncellemesi geldi (puan / açık hata)
19. Geliştirici · ikisi · veritabanı sorgusu büyük hesapta yavaşlıyor (puan / sunucu kademesi okunur)
20. Geliştirici · B2C · not: arama dizinini yeniden kurmak (puan / açık hata)
21. Geliştirici · ikisi · testler yavaş, herkes atlıyor (puan / hata ihtimali)
22. Testçi · B2B · fatura numarası yıl dönümünde sıfırlanmıyor (puan / açık hata / güven)
23. Testçi · ikisi · eski tarayıcıda ekran boş (puan / açık hata)
24. Testçi · B2C · video: altyazı uzun cümlede taşıyor (puan / açık hata)
25. Testçi · B2B · stok: iki depo arası transfer iki kez sayılıyor (puan / güven)
26. Testçi · ikisi · gerçek veriyle test için müşteriden örnek veri istemek (güven / hata ihtimali)
27. Testçisiz test · ikisi · tasarımcı test ediyor (kurucu / kasa / statüko)
28. Testçisiz test · ikisi · kurucu kendi kodunu test ediyor (kasa / statüko)
29. Kurucu yalnız · ikisi · gece yarısı aklına daha iyi bir çözüm geliyor (verim / puan)
30. Kurucu yalnız · ikisi · bir arkadaşın kodu inceleme teklifi (kasa ya da güven / açık hata)
31. Kurucu yalnız · B2B · ilk hesabın yöneticisi bir ekranı canlı izlemek istiyor (verim / güven)
(Kurucu yalnız 6 kâğıdın kalan 3'ü ve B2C, B2B dengesi yazım adımında bu listeden tamamlanır; marketplace varyantları
E'ye ertelenir. Erdem'in beğendiği "indirim kodu ve taksit" fikri pazaryeri testçi kâğıdı olarak E'de yazılır.)

### 6.3 Söz olayı
**`product.promise_due` (B2B, onaylı)** · konuşan kartta çalışan kişi; yoksa kurucunun notu
- Başlık EN "{customer} expects it this sprint" · TR "{customer} bu sprint sonunu bekliyor"
- Gövde, kart testteyse · EN: "We told {customer} that {seam:urun.decision_card} would ship at the end of this sprint.
  At this pace it will not. The card is in testing; if we shorten the tests, it makes it." TR: "{customer} ekibine
  {seam:urun.decision_card} özelliğinin bu sprintin sonunda çıkacağını söyledik. Bu hızla yetişmeyecek. Kart testte;
  testi kısaltırsak yetişir."
- Gövde, kart testte değilse · EN: "...At this pace it will not, and the card has not reached testing yet." TR: "...Bu
  hızla yetişmeyecek; kart daha teste gelmedi."
- Seçenekler: EN "Shorten the tests" / TR "Testi kısalt" → `sprint_card_test {cut}`; kilit `cut_test_finishes`
  EN "Even a shorter test does not get it out this sprint" / TR "Test kısalsa da bu sprintte çıkmıyor" ·
  EN "Ask the team for overtime" / TR "Ekipten fazla mesai iste" → saat ×1,25, `morale_all {team} −4`; kilit
  `crunch_finishes` (var olan gerekçe) · EN "Call them and ask for one more sprint" / TR "Arayıp bir sprint ek süre
  iste" → `promise_extend`; kilit EN "This date has already been moved once" / TR "Bu tarih bir kez ertelendi" ·
  EN "Let the promise slip" / TR "Söz kaçsın" → `promise_break`
- Süre doldu: EN "No answer came; the sprint closed without it." / TR "Cevap gelmedi; sprint onsuz kapandı."

**`customer.b2c_roadmap_ask` (B2C)** · PM, yoksa kurucunun notu
- Başlık EN "When is it coming?" · TR "Ne zaman geliyor?"
- Konuşan: müşteri temsilcisi; koşul ekipte temsilci olması (inceleme).
- EN: "{seam:urun.ask_step_name} is what people asked about most this month: {seam:olay.ask_count} people asked in
  comments and messages when it is coming. It is planned for the next sprint. If we give a date, people will wait for
  it; if we do not, they will keep asking."
- TR: "Bu ay en çok sorulan şey {seam:urun.ask_step_name}: yorumlarda ve mesajlarda {seam:olay.ask_count} kişi ne
  zaman geleceğini sordu. Sonraki sprinte planlı. Tarih verirsek beklerler; vermezsek sormaya devam ederler."
  (inceleme: "en çok sorulan soru Paylaşılan Not" dil bilgisi olarak yanlıştı, soru özelliğin kendisi değil)
- Seçenekler: EN "Announce it for the end of next sprint" / TR "Sonraki sprintin sonunda çıkacağını duyur" (inceleme) → kamuya söz,
  marka +1 · EN "Say it is coming soon, without a date" / TR "Yakında de, tarih verme" → statüko
- `ask_count` C gelene kadar kitlenin %1,1'i [ÇALIŞMA]; C gelince istek verisi.

**`product.b2c_roadmap_due` (B2C ikizi)**
- Başlık EN "The date we announced" · TR "Duyurduğumuz tarih"
- EN: "We announced {seam:urun.decision_card} for the end of this sprint, and {seam:olay.ask_count} people are waiting
  for it. At this pace it will not make it. The card is in testing; if we shorten the tests, it does."
- TR: "{seam:urun.decision_card} için bu sprintin sonunu duyurduk; {seam:olay.ask_count} kişi bekliyor. Bu hızla
  yetişmeyecek. Kart testte; testi kısaltırsak yetişir."
- Seçenekler: Testi kısalt · Fazla mesai · EN "Post an update and move the date by one sprint" / TR "Güncelleme
  paylaş, tarihi bir sprint ileri al" → `promise_extend` (marka −1; bir kez) · EN "Let the date pass quietly" / TR
  "Tarih sessizce geçsin" → `promise_break` (kitle −`ask_count` × 0,4, marka −2) (inceleme: kayıp bekleyen sayısından)

### 6.4 B2B teşekkür maili · `customer.release_thanks` (not kartı, `sender: contact`, gövde `musteri.met_step`'e göre)
Kural: Mail yalnız yaşanmış şeyi anlatır. Ay sonuna bağlı kademeler ilk ay sonu haftasında, öbürleri bir hafta sonra
gelir. Takvimi öne alan cümle ("kapanışı iki gün erken yaptık") yazılmaz; iş yükü ve el emeği anlatılır.
- Başlık: kademenin adı (`{seam:musteri.met_step_name}`).
- Fatura K2 · Toplu Fatura (ay sonu) · EN: "We used batch invoicing for the first time at this month's close. Last
  month the invoices took two people most of a day; this time they went out in one run before lunch. Our thanks to
  your team." TR: "Toplu faturayı bu ayın kapanışında ilk kez kullandık. Geçen ay faturalar iki kişinin neredeyse
  bütün gününü almıştı; bu sefer öğleden önce tek seferde çıktı. Ekibinize teşekkür ederiz."
- Stok K2 · Depo ve Raf (bir hafta) · EN: "We have two warehouses, and we used to phone each other to find out which
  shelf a box was on. Since the update, the system tells us. Last week's count was done without a single call. Thank
  you." TR: "İki depomuz var; bir kolinin hangi rafta olduğunu öğrenmek için birbirimizi arardık. Güncellemeden beri
  sistem söylüyor. Geçen haftaki sayım tek bir telefon açılmadan bitti. Teşekkürler."
- Defter K3 · Otomatik Mutabakat (ay sonu) · EN: "Reconciling with the bank used to take the last two days of every
  month. This month we came in to find only the three entries that did not match. Thank you for this one in
  particular." TR: "Banka mutabakatı her ayın son iki gününü alırdı. Bu ay sabah geldiğimizde önümüzde yalnız tutmayan
  üç kayıt vardı. Bunun için ayrıca teşekkür ederiz."
- Yazım adımında kalan 15 kademe: Fatura K3 · Stok K3 · Defter K2 · Nakit K2, K3 · Veri Girişi K2, K3 · ortak
  Entegrasyon, Güvenlik, Dayanıklılık, Mobil K2 ve K3 (ERP varyantları).

### 6.5 B2C "Sürüm sonrası öne çıkan yorumlar"
- Satır başlığı `PRODUCT_RELEASE_REVIEWS`: EN "Top comments after the release" · TR "Sürüm sonrası öne çıkan yorumlar"
  (inceleme: EN "öne çıkan"ı karşılamıyordu)
- Kaynak etiketleri: `REVIEW_SOURCE_SOCIAL` "Sosyal medya" / "Social media"; `REVIEW_SOURCE_STORE` "Uygulama mağazası" /
  "App store"; `REVIEW_SOURCE_SHOP` "Mağaza" / "Store" (E) (inceleme: E'nin sözlüğüyle aynı ad; "Satıcı" değil).
- Hat başına 2 olumlu, 2 olumsuz kısa yorum (`REVIEW_<HAT>_POS_1..2`, `_NEG_1..2`); olumsuzlar olay 6'nın alıntılarıyla
  ortaktır. Örnekler:
  - Not Senkron, olumlu · EN "“What I write on my phone is now there when I open my laptop.”" TR "“Telefonda yazdığım
    not artık bilgisayarı açtığımda orada oluyor.”" (inceleme)
  - Not Arama, olumsuz · EN "“Since the update, search does not find yesterday's notes. Please take a look.”" TR
    "“Güncellemeden beri arama dünkü notları bulmuyor. Lütfen bakın.”"
  - Düzeltme sürümü, olumlu (`REVIEW_FIXED_1..2`, hat adıyla) · EN "“{line} works again. Thank you for listening.”"
    TR "“{line} yine çalışıyor. Dinlediğiniz için teşekkürler.”"
  - İstek (C gelince, `REVIEW_ASK_1..2`) · EN "“Still no way to {ask}?”" yerine istek başına tam cümle yazılır (ek
    almayan belirteç kuralı).
  - Mağaza (E) (inceleme) · EN "“Bulk listing saved my week: 400 products in ten minutes.”" TR "“Toplu ilan yükleme haftamı
    kurtardı: 400 ürünü on dakikada girdim.”"
- Yazım yükü: not 5 + video 5 + ortak B2C 4 hat × 4 = 56 kısa yorum + düzeltme 2 + kaynak 3.
  (inceleme) E not ve video uygulamasını siliyorsa (E planı, açık soru 1) bunun 40'ı E2'de çöpe gider. Öneri: B yalnız
  ortak B2C hatlarının 16 yorumunu ve not uygulamasının çalışan bir asgarisini (hat başına 1 olumlu, 1 olumsuz = 10)
  yazar; video yorumları, video belirtileri ve video alıntısı yazılmaz. Pazaryeri hatlarının yorumları, alıntıları ve
  belirtileri E'de yazılır (sahip sorusu 3).

### 6.6 Silinen metinler
`EV_PRODUCT_OUTAGE_*` (6), `EV_PRODUCT_BUG_PILE_*` (5), `EV_PRODUCT_SPRINT_COLORS_AGAIN_*`, `EFFECT_FIX_RUN_STARTS` (A
bıraktıysa), hazırlık onaylanırsa `HUNT_PREP_RUNNING`, `HUNT_PREP_REASON`, `HUNT_PREP_PENDING`, `HUNT_PREP_READY`,
`HUNT_FOCUS_NUMBERS`, `HUNT_FOCUS_STORY`, `HUNT_FOCUS_REHEARSAL`, `VC_PREP_BUSY`, `VC_PREP_NEED_MEETING`,
`VC_PREP_TOO_SOON`, `VC_PREP_TOO_SOON_ONE` (ve hazırlığın görüşme panelindeki iz satırları, uygulamada grep ile).

---

## 7. Uygulama dilimleri
Her dilimde kapı sırası (CLAUDE.md §12): `--event-lint` → `loc_residue` → `smoke_run.sh loc_csv_integrity` → hedefli
smoke → dilimin probu → görsel kabul (ekranlı, sırayla) → Opus incelemesi → commit ("TR/EN onay bekliyor" metin
taşıyanlarda). (inceleme) Tam smoke koşulmaz: Erdem 2026-10-06'da "push et" doğrudan push demek dedi, öncesinde tam
smoke yok. Push yalnız Erdem'in sözüyle.

**B0 · Tazeleme (kod yok).** A'nın commit'lerinden §5.7'deki adlar okunur; plan bu adlarla güncellenir.
- **A'nın ad listesi:** `A_INCELEME.md`'deki "B için yeniden adlandırma" listesi uygulanır.
- **E incelemesinin notu:**
  - Pazaryerindeki kupon seçeneği E'nin ölçeğinde yaklaşık $310 tutuyor ve neredeyse bedava görünüyor. Bedeli E
    gelince yeniden kontrol edilir.
  - İade ve özür bedeli "üye × üyelik ücreti" üzerinden hesaplanır.

**B1 · Motor ve fiil altyapısı**
- Ne: `amount_seam`; `trust_delta`; `morale_all {scope}`; `sprint_card_trim`, `sprint_card_test`, `line_harden`;
  `hr.role`, `hr.on_decision_card`, `urun.decision_*` seam'leri; çip anahtarları; `bug_pile` silinir (ve A bıraktıysa
  `fix_run_start` ailesi); `--event-vocab`.
- Dosyalar: `scripts/events/core/effects.gd`, `present/chips.gd`, `seams/seams_product.gd`, `seams/seams_hr.gd`,
  `seams/seams_sales.gd`, `scripts/systems/sprint_system.gd` (trim, test, kapanışta `trim_bugs`), A'nın hat dosyası
  (`line_harden`), `localization/strings.csv`, `docs/content/events_draft/_vocabulary.md`, `data/events/cards/product/bug_pile.json`.
- Kapılar: yeni smoke `event_amount_seam` (çip ve uygulanan tutar aynı), `event_trust_delta_lasting` (bir tik sonra iz
  durur); var olan `event_chip_coverage`; `--sprint-probe=hours=8:cards=2:ticks=12:events=1` (PRED = CLOSE).

**B2 · Acil durum sistemi + kesinti kartları**
- Ne: `IncidentSystem` (tehlike, tür, ölçek, saat ve tutuş, açık olaylar, kayıt), `incident` fiili ve çipi,
  `SprintSystem.insert_urgent_fix`, `olay.*` seam'leri, `incident_outage_b2b` ve `_b2c` (eski `outage` silinir),
  `sprint.json` `incident` bloğu, TimeManager dağıtımına saatlik ve günlük yuva.
- Dosyalar: yeni `scripts/systems/incident_system.gd`, yeni `scripts/events/seams/seams_incident.gd`,
  `effects.gd`, `chips.gd`, `sprint_system.gd`, `time_manager.gd`, `save_manager.gd`, `data/product/sprint.json`,
  iki kart JSON, `strings.csv`; `class_name` eklendiği için `--headless --import`.
- Kapılar: smoke `incident_gap_and_spread` (sabit girdiyle 300 hafta: en küçük aralık ≥4, aralıkların standart sapması
  >2, ortalama formülün ±%20'si), `incident_scale` (kredi = kademe × aylık ücret; iade ∝ etkilenen), `incident_save_roundtrip`;
  `--why-fire=product.incident_outage_b2b`; `--event-harness=random:seeds=10:weeks=104` (koşu başına olay sayısı ve
  aralıklar raporlanır); görsel: `--event-shot=product.incident_outage_b2b:customer=<fikstür>` TR ve EN,
  `--inbox-shot` yeni `incident_night` durumu (saat 02:10'da tutulu, kart açık, karar sonrası gece sürer;
  `--clock-shot=held` ile tutuş doğrulanır).
- Risk: gece tutuşu toplu adımı durdurur, kaldığı yerden sürmesi doğrulanmalı (`_can_step`).
- (inceleme) Ek smoke `incident_night_hold_resumes`: 02:10 başlangıçlı olay 03:00 adımında kartı açar, saat 03:00'te
  durur, karar sonrası `skip_night` 08:00'e varır ve `night_skipped` bir kez yayılır; 00:00 adımında hiç istek yapılmaz.
  Falsification: tutuş alınmazsa kart 08:00'de açılmalı (vaka FAIL vermeli).

**B3 · Dört acil durum kartı**
- Ne: `incident_month_close`, `incident_checkout`, `incident_regression` (sürüm yolu), `incident_review_storm`; hat
  belirtileri ve alıntılar.
- Dosyalar: 4 kart JSON, `incident_system.gd` (sürüm yolu, sprint kapanışı kanaması), `sprint_system.gd` (`_close`
  sonrası çağrı), `strings.csv`.
- Kapılar: `--why-fire` her kart; `bash tools/plausibility_run.sh` (fails=0); `bash tools/run_gate.sh` (üç koşu sonla
  bitiyor, sıfır ERROR; olay sayıları ve kasa, hesap kaybı raporlanır); görsel `--event-shot` dört kart TR/EN.

**B4 · Sprint ortası kâğıt motoru**
- Ne: haftalık zar, sprint başına bir, görülmemiş önce sıralama, mandal 52 + 3; var olan 6 kâğıda konuşmacı ve rol
  koşulu; renk kâğıtları birleşir; motor md §27 notu (mandal yığını).
- Dosyalar: `sprint_system.gd` (`_request_decision`), `data/product/sprint.json`, `data/events/cards/product/sprint_*.json`,
  `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` §27, `strings.csv`.
- Kapılar: smoke `decision_one_per_sprint`, `decision_no_fourth_show`; `--sprint-probe=...:events=1` (PRED = CLOSE,
  karar haftaları raporlanır); `--event-harness=random:seeds=10:weeks=104` (koşu başına kâğıt 25–40, 104 haftada aynı
  kâğıt en çok 2); görsel `--product-shot=live:decision_paper` (konuşmacının adı ve rolü başlıkta).

**B5 · Kâğıt içeriği, dalga 1 (20 kâğıt: §6.2'nin 9'u + 11)**
- Dosyalar: `data/events/cards/product/sprint_*.json`, `strings.csv`.
- Kapılar: lint, loc_residue, `--why-fire` her kâğıt (rol ve aşama koşulu), plausibility_run, görsel `--event-shot` 4
  örnek (biri kurucu yalnız) TR/EN.

**B6 · Kâğıt içeriği, dalga 2 (20 kâğıt)** · aynı kapılar.

**B7 · Söz olayı (B2B) + B2C duyurulan tarih**
- Ne: `promise_due`, `b2c_roadmap_ask`, `b2c_roadmap_due`; `promise_extend`, `promise_break`; `Promise.source`,
  `extended`; B2C söz çözümü (`B2BSalesSystem.on_promise_resolved` pazar dalı → `SalesSystem`); söz kâğıdının sistem
  isteği.
- Dosyalar: `promise_registry.gd`, `data_models/promise.gd`, `b2b_sales_system.gd`, `sales_system.gd`,
  `sprint_system.gd`, `sprint_catalog.gd` (B2C söz parçasının etiketi: "Duyuru"), `effects.gd`, `chips.gd`, 3 kart,
  `strings.csv`.
- Kapılar: smoke `promise_extend_once`, var olan söz vakaları; `--why-fire` üç kart; plausibility_run; `run_gate.sh`;
  görsel `--event-shot=product.promise_due:customer=<fikstür>`, B2C ikizi, `--product-shot=live:b2b_requests` (söz
  parçası).

**B8 · Sürüm anı**
- Ne: `customer.release_thanks` (not kartı, sürümden sonra zamanlanır; güven +4); B2C yorum seçimi (sürüm kaydına id ve
  argüman olarak), sürüm notunda yeni satır.
- Dosyalar: `sprint_bridges.gd` (`on_release`: karşılanan istek → zamanlama), `sprint_system.gd` (`_close`: yorum
  seçimi), `tabs/product/sprint_panel.gd` (`_release`: yorum satırı, koyu dil `D_` token'ları), kart JSON,
  `strings.csv`.
- Kapılar: `--why-fire=customer.release_thanks`; görsel `--product-shot=live:b2c_live` sürüm notu karesi (yorum satırı,
  taşma yok, TR/EN), `--inbox-shot` teşekkür maili (`--event-shot=customer.release_thanks:customer=<fikstür>`);
  `--theme-contrast-audit`.

**B9 · Yatırımcı hazırlığının kalkması (onaylanırsa)**
- Dosyalar: §5.9 listesi.
- Kapılar: `--event-vocab` (founder.task_state değeri), hedefli smoke (VC vakaları; hazırlık vakaları silinir),
  `run_gate.sh` (`full_run_vc_cautious`), görsel: Av sekmesi çekimi (HARITA'daki Series A sekmesi türü) ve
  `--meeting-shot=open`.

**Riskler**
1. **A'ya bağımlılık:** Etkilenen hesap ve kullanıcı, hat başına açık hata, bozulan hat ve düzeltme kapanışı A'nın
   arayüzüdür. A farklı kurarsa B2 ve B3 yeniden bağlanır (B0 bunun için var).
2. **Yazım hacmi ve kalitesi:** ≈40 kâğıt, 6 olay, 19+ belirti, 18 teşekkür, 56 yorum: TR ve EN birlikte ≈300 cümle.
   Erdem'in en sert eleştirisi burada. Önlem: yazım Opus'ta, dalga dalga; her dalga commit'ten önce Erdem'e toplu
   gider; Sonnet yalnız bağlar.
3. **Ekonomi kayması:** Acil durumlar güven, kitle ve kasa düşürür; kâğıt sıklığı düşer; B2B ayrılma C'nin eşiğine
   bağlı. `run_gate` koşuları farklı sonla bitebilir. Önlem: B3 ve B7 sonunda ölçüm, sabitler "onay bekliyor".
4. **Gece tutuşu:** Toplu adımın tutuşta durup sürmesi ve otomatik kayıt; B2'de `--inbox-shot=incident_night` ve
   `--tick-probe` ile doğrulanır.

---

## 8. Açık sorular
1. **Yatırımcı hazırlığı kaldırılsın mı?** Öneri: **evet** (§2.6). Derinleştirmek VC modülünün işi.
2. **B2C söz ikizi "kullanıcılara duyurulan tarih" olsun mu?** Öneri: **evet** (§2.4). Alternatif, kampanya tarihi
   kurgusunun yeniden yazımı; gerçek B2C sıkışması kendi verdiğin tarihtir.
3. **Kâğıt sıklığı sprint başına en çok bir olsun mu?** Bugün koşu başına ≈70 kâğıt, ilk 6 haftada 3–4; öneriyle
   30–38 ve ilk 6 haftada ≈2. Öneri: **evet**; tekrar yasağı ancak böyle tutar.
4. **Erteleme düşüşü:** C eşiği 30'a doğru inerse 6; inmezse 4. Öneri: **6 ve C'nin eşiği** (§5.5).
5. **B2B kesinti kredisi kademesi:** Araştırma tablosu (%10 / %25 / %50) mi, %20 tavanlı mı? Sabaha bırakılan gece
   kesintisi ≈8–9 saat sürer ve %25'e düşer. Öneri: **araştırma tablosu**; kredi ayda bir kez, kesinti süresiyle
   orantılı ve sektördeki kalıp bu.

(inceleme) İnceleme iki soru daha ekledi; ayrıntı `B_INCELEME.md`: doluluğu B'de hiç okumamak (C kaldırıyor) ve not ile
video hatlarına özel metni yazmamak (E siliyor).

---

## 9. Uygulama adım tablosu

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| 0 | A'nın commit'lerinden §5.7 adlarını oku, planı tazele | Alt ajan | Sonnet | yüksek | 15 dk | Fark kontrolü, tasarım değil |
| 1a | B1 kodu | Alt ajan | Sonnet | xhigh | 60 dk | Motor dokunuşu, dar ama hassas |
| 1b | B1 kapıları ve çip çekimi | Alt ajan | Haiku | düşük | 15 dk | Mekanik koşu |
| 1c | B1 kıdemli inceleme, düzeltme, commit | Alt ajan | Opus | yüksek | 20 dk | Commit başına bir inceleme |
| 2w | Olay 1–6 metinlerinin son yazımı (EN önce, TR yeniden), belirti tablosunun video ve ortak B2C satırları | Alt ajan | Opus | yüksek | 45 dk | Erdem'in en sert eleştirisi yazım |
| 2a | B2 kodu (sistem, fiil, gece tutuşu, iki kart) | Alt ajan | Sonnet | max | 180 dk (inceleme: 120 dk yeni sistem + kayıt + saat tutuşu + `insert_urgent_fix` + iki kart için az) | Yeni sistem, kayıt, saat etkileşimi |
| 2b | B2 kapıları, harness, gece çekimi | Alt ajan | Haiku | düşük | 25 dk | Mekanik |
| 2c | B2 inceleme ve commit | Alt ajan | Opus | yüksek | 25 dk | Kayıt ve saat riski |
| 3a | B3 kodu (dört kart, sürüm yolu, kanama) | Alt ajan | Sonnet | xhigh | 90 dk | Kart bağlama ve sistem dalları |
| 3b | B3 kapıları, plausibility, run_gate | Alt ajan | Haiku | düşük | 40 dk | Uzun koşular |
| 3c | B3 inceleme ve commit | Alt ajan | Opus | yüksek | 20 dk | Ekonomi kayması okunur |
| 4a | B4 kodu (kâğıt motoru, var olan kâğıtlar, GDD §27 notu) | Alt ajan | Sonnet | xhigh | 75 dk | Seçim ve mandal mantığı |
| 4b | B4 kapıları, sprint-probe, harness | Alt ajan | Haiku | düşük | 25 dk | Mekanik |
| 4c | B4 inceleme ve commit | Alt ajan | Opus | yüksek | 20 dk | — |
| 5w | Dalga 1 yazımı: 11 kâğıt (9'u planda), Erdem'e toplu sunum | Ana + alt ajan | Opus | yüksek | 70 dk | Yazım kalitesi; onay sonrası bağlanır |
| 5a | Dalga 1 bağlama (JSON, anahtarlar, koşullar) | Alt ajan | Sonnet | xhigh | 50 dk | Kart verisi |
| 5b | Dalga 1 kapıları ve çekimler | Alt ajan | Haiku | düşük | 25 dk | Mekanik |
| 5c | Dalga 1 inceleme ve commit | Alt ajan | Opus | yüksek | 15 dk | — |
| 6w | Dalga 2 yazımı: 20 kâğıt | Alt ajan | Opus | yüksek | 80 dk | Aynı |
| 6a–c | Dalga 2 bağlama, kapılar, inceleme | Alt ajanlar | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 50 + 25 + 15 dk | Aynı |
| 7w | Söz ve B2C ikizi metinlerinin son yazımı | Alt ajan | Opus | yüksek | 25 dk | Yazım |
| 7a | B7 kodu | Alt ajan | Sonnet | xhigh | 90 dk | Söz kaydı ve pazar dalı |
| 7b | B7 kapıları, run_gate | Alt ajan | Haiku | düşük | 35 dk | Uzun koşu |
| 7c | B7 inceleme ve commit | Alt ajan | Opus | yüksek | 20 dk | — |
| 8w | 15 teşekkür maili, 56 yorum | Alt ajan | Opus | yüksek | 60 dk | Yazım |
| 8a | B8 kodu (mail zamanlaması, yorum seçimi, sürüm notu satırı) | Alt ajan | Sonnet | xhigh | 80 dk | UI + seçim mantığı |
| 8b | B8 kapıları ve görsel kabul | Alt ajan | Haiku | düşük | 30 dk | Çekimler |
| 8c | B8 inceleme ve commit | Alt ajan | Opus | yüksek | 20 dk | — |
| 9a | B9 kodu (hazırlık silinir; yalnız onay gelirse) | Alt ajan | Sonnet | xhigh | 45 dk | Silme işi geniş ama mekanik değil |
| 9b | B9 kapıları ve çekim | Alt ajan | Haiku | düşük | 20 dk | — |
| 9c | B9 inceleme ve commit | Alt ajan | Opus | yüksek | 15 dk | — |
| 10 | Faz sonu raporu (✅ / ⚠️ / ❌, kanıt), onay bekleyen sabitler ve metinler | Ana | Opus | orta | 15 dk | Sentez |

**Paralellik:** Yazım adımları (2w, 5w, 6w, 7w, 8w) bir önceki dilimin kodu yazılırken koşabilir; kod dilimleri aynı
klasörde sırayla. Ekranlı çekimler sırayla.
**Toplam:** kod ve kapı ≈ 13 saat, yazım ≈ 5 saat; paralelle ≈ 17–19 saat duvar saati.
(inceleme) 2a'nın +60 dakikasıyla ≈ 18–20 saat; yazım dalgalarının Erdem onayını bekleme süresi buna dahil değildir.
Sahip sorusu 3 "evet" çıkarsa 8w ≈ 30 dakika kısalır. **Push:** hiçbir adım push etmez; push yalnız Erdem'in sözüyle,
tam smoke koşulmadan yapılır.
