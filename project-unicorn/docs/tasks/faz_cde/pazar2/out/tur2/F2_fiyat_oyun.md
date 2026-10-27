# F2: Oyunlarda oyuncunun fiyat koyması (Erdem soru 8)

Erişim tarihi: 2026-10-20. Yöntem: 8 WebSearch (hepsi kullanıldı) + çok sayıda doğrudan sayfa açma. Etiketler: [BOŞLUK] kanıtsız yük taşıyan iddia, [SIÇRAMA] kanıttan çıkmayan sonuç, [GÖRÜŞ], (varsayım).

## ÖZET

Bulgular (kaynaklı)
1. Software Inc'te oyun, ürün fiyatı girilirken bir "önerilen fiyat" gösteriyor (tek kaynakta Bilgisayar İşletim Sistemi için 150 $) [S3]. Oyuncular onu kullanıyor, hatta "78,34 öneriyorsa 79,99 yaparım" diye yuvarlıyor [S1]. Bir oyuncu testinde (her fiyat için tek kayıt) kâr önerilen fiyatta tepe yaptı: 150 $ → 45,7 M$ kâr; 75 $ → 13,9 M$; 1 $ → -12,2 M$; 0 $ → -13,7 M$ [S3]. Yazarın sonucu: "ya ücretsiz ya önerilen fiyat, arası yok" [S3]. Yani bilgi verilince karar tek doğru cevaba çöküyor (tek yazar, tek koşu, Düşük güven). [V2 uyarı, AÇILAMADI: deney tablosunun rehberi 404/429 verdi; yalnız "önerilen fiyat gösterilir" ve "fiyat çıkışta değiştirilemez" oyuncu anekdotu olarak doğrulandı (Steam 2018). 150 $ / 45,7 M$ sayılarına tasarım dayanağı olarak yaslanma.]
2. Software Inc'te fiyat yayından önce ürün başına bir kez konuyor; çıkıştan sonra "birim fiyat değiştirilemiyor" diye oyuncu yazıyor [S1] ve tasarım belgesindeki fiyatı yükseltince satış sert düşüyor (75 $ plan, 80 $ ve üstü çıkışta) [S3]. İki yorumcu 2025'te hâlâ aynı davranışı bildiriyor [S3]. (Oyunun sürümleri arasında değişmiş olabilir; kanıt yok.)
3. Big Ambitions'ta fiyat mağaza × ürün başına ve sürekli yeniden koyuluyor; oyuncu mağaza sayısı büyüyünce "5-6 mağazada kolay, 60-70'te kâbus" diyor, 693 saatlik bir oyuncu mahalle düzeyi fiyat editörü gelene kadar bırakacağını yazıyor, geliştirici "çözüm gelecek" ve "tek tek değiştirmek biraz angarya" diyor (Haziran 2024) [S7, S8]. Çözüm sonradan "Fiyat Müdürü" rolü + "Önerilen fiyatları uygula" düğmesi oldu [S6].
4. Big Ambitions'ın fiyat göstergesi karışıklık yarattı: sarı/kırmızı arka plan, "bölgedeki en düşük fiyat" kendi dükkânın olabiliyor, kırmızının varlığını bilmeyen oyuncu fiyat kırıp gelir kaybetti [S7]. Yama ile müşteri fiyat duyarlılığı değişince "en ucuz bile olsam müşteri şikâyet ediyor" ve kâr yarıya indi [S8]. Rakip fiyatı dükkân içi balonla, "piyasa fiyatı" iş ekranıyla gösterilince iki rakam uyuşmadı ve oyuncu güveni kırıldı (Mart 2023) [S9].
5. Two Point Hospital'da tedavi fiyatı yüzde kaydırıcısı; oyuncular "fiyat itibarı" ile hastanın ödemeyi reddetmesini ve danışman uyarısını tartışıyor, tavsiyeler çelişiyor ("hep %100 bırak", "mutlu fazla fiyat", "-%10 itibar kazandırır") [S12, S13]. Seçilmiş çözüm: uyarıyı kapat ya da yok say, kaydırıcıyı bir kez bırak [S13].
6. RollerCoaster Tycoon'da giriş ücreti ve yolculuk başı fiyat var; topluluk "giriş en çok 50, çünkü en yoksul misafirin parası ~55" gibi tavan kuralları ve "heyecan puanının onda biri, aşağı yuvarla" gibi formüllerle "bir kere ayarla" çözümü üretmiş [S20, Düşük].
7. Capitalism Lab'de ürün puanı fiyat, kalite ve marka ağırlıklarının ürüne göre değişen karışımı: sigarada %60 marka, %15 kalite, %25 fiyat; dondurulmuş ette %20 marka, %40 kalite, %40 fiyat [S17]. Fiyatın "doğru" ağırlığı ürün kimliğine bağlı.
8. OpenTTD ve Offworld'de oyuncu fiyat koymuyor: OpenTTD'de gelir = oran × miktar × mesafe × zaman çarpanı [S15], Offworld'de fiyat arz-talep ve oyuncunun alımlarıyla oluşuyor [S16].
9. Fiyat angaryası oyunu öldürmedi: Big Ambitions %91 olumlu (6.256 yorum) [S11], Two Point Hospital %93 (12.743) [S14], Software Inc %94 (5.638) [S4]. [SIÇRAMA] Bu oranlar fiyat angaryasının oyunu tek başına öldürmediğini gösterir, ne kadar puan götürdüğünü göstermez; Big Ambitions'ın %91'i %90 çıtasının sınırındadır.
10. Bulunamayan: Game Dev Tycoon, Mad Games Tycoon 2, Startup Company, Football Manager fiyat mekaniği ve Software Inc sözleşme fiyatı (açılış yolları engelli ya da bütçe bitti). Aşağıda "belirsiz (kanıtsız)".

Oyuna ders
- D1 (neye göre): Oyuncuya "önerilen/optimal fiyat" verirsen karar tek doğru cevaba çöker (Software Inc, her satışta, her oyuncuda) [S1, S3]. Piyasa REFERANSI ver (Big Ambitions'ın "piyasa fiyatı") ama öneri verme; karar hesabın bütçesi ile marj/kapanış şansı arasında olsun. Etkisi: fiyat kararını her tekliften hesap başına bir kez, kolay.
- D2 (sıklık): Fiyatı hesap başına ya da dükkân/ürün başına sürekli koydurmak oyuncuyu kaçırıyor (Big Ambitions 60-70 birimde kâbus) [S7, S8]. Liste fiyatı bir kez (katalog), yeniden koyma yalnız olayla (rakip sürümü, yenileme, ürün sürümü). Hesap başına tek duruş seçimi yeter; 1 hesapta da 400 hesapta da aynı yük.
- D3 (modül satırı): Modül başına fiyat satırı, satır sayısı sabit kaldığı (5-10) ve hesap sayısıyla çarpılmadığı sürece yormaz. Yoran şey n hesap × m modül çarpımıdır [S7, S8]. Koltuk başı + modül eki tek kez katalogda dursun; hesapta yalnız "duruş".
- D4 (bilgi): Kayıp ve ret nedeni her zaman satırda yazılı olsun; iki ekranda iki farklı rakam asla (Big Ambitions M00nshine tartışması) [S9]; gizli duyarlılık değişimi yok [S8]. Hesabın bütçesi aralığı ve rakibin liste fiyatı verilmeli; sunucu maliyeti fiyat kararının girdisi olarak ancak "marj" satırında görünür ([GÖRÜŞ], kanıt yok).

---

## 1. Oyun × mekanik tablosu

Sütunlar: fiyatın birimi · oyuncuya verilen bilgi · sıklık · otomasyon · karar gerçek mi · şikâyet/çözülmüş strateji.

| Oyun | Fiyatın birimi | Bilgi | Sıklık | Otomasyon | Gerçek karar mı | Şikâyet / çözülmüş strateji |
|---|---|---|---|---|---|---|
| Software Inc | Ürün birim fiyatı (tasarım belgesinde), ücretsiz seçeneği var [S3] | "Önerilen fiyat" gösterilir [S1, S3]; pazar büyüklüğü (2,8 M kullanıcı / 130 M potansiyel) [S1]; rakip 200-300 $ [S1] | Yayından önce bir kez; sonra "birim fiyat değiştirilemiyor" [S1] | Önerilen fiyat öneri olarak; "varsayılanı kullan, çok kârlı" [S1] | Çoğu oyuncu için tek doğru: önerilen ya da ücretsiz [S3] | "$1 en kötü fiyat" [S3 yorum]; "$10 OS başarısız oldu" [S3 yorum]; fiyatı belgeden sonra yükseltmek satışı çökertiyor [S3] |
| Game Dev Tycoon | Belirsiz (kanıtsız): Wikipedia gelirin nasıl üretildiğini anlatmıyor [S19] | Belirsiz | Belirsiz | Belirsiz | Belirsiz | Bulunamadı |
| Mad Games Tycoon 2 | Belirsiz | Belirsiz | Belirsiz | Belirsiz | Belirsiz | Mağaza kimliği tahmini yanlış çıktı; sayfa bulunamadı |
| Big Ambitions | Mağaza × ürün/hizmet fiyatı [S6, S7] | Piyasa fiyatı, en düşük bölge fiyatı, sarı/kırmızı zemin, Insight "Pricing %" puanı [S6, S7] | Sürekli; mağaza sayısıyla çarpılıyor [S7, S8] | "Fiyat Müdürü" (merkez rolü) + "Önerilen fiyatları uygula" [S6]; mahalle editörü sözü [S7, S8] | Gerçek ama okunması zor; "tatlı nokta sarı aralıkta" [S7] | 60-70 mağazada kâbus [S7]; yama ile duyarlılık değişince kâr yarıya [S8]; flyout/piyasa tutarsızlığı [S9] |
| Capitalism Lab | Ürün fiyatı; puan = marka/kalite/fiyat karışımı (ürüne göre) [S17] | Ürün puanı (rating), alış maliyeti, nakliye [S17] | Düşük puan olunca hemen fiyat indir [S17] | COO mağazada neyi hangi fiyatla satacağını kontrol edebilir (insan yönetici, otomasyon değil) [S17] | Ürünün marka/kalite/fiyat ağırlığına göre değişir [S17] | Bulunamadı (şikâyet aranmadı/bulunamadı) |
| Offworld Trading Company | Oyuncu fiyat koymaz; kaynak fiyatı arz-talepten [S16] | Dinamik piyasa fiyatı [S16] | Sürekli, oyuncu alımıyla oynar [S16] | Yok (fiyat zaten otomatik) | Karar: ne zaman al/sat | Wikipedia'da fiyat eleştirisi yok [S16] |
| Startup Company | Belirsiz | Belirsiz | Belirsiz | Belirsiz | Belirsiz | Arama (8. bütçe) konuyla ilgisiz sonuç verdi |
| Two Point Hospital | Tedavi fiyatı, standardın yüzdesi [S13] | Danışman uyarısı, fiyat itibarı çubuğu, hastanın ödeme reddi [S12, S13] | Çoğu oyuncu bir kez; krizde ayarlıyor [S13] | Yok (danışman bildirimi kapatılır) [S13] | Kâğıt üzerinde gerçek, pratikte "%100 bırak" [S13] | Danışman dırdırı [S13]; çelişen tavsiye [S12, S13] |
| RollerCoaster Tycoon | Giriş ücreti + yolculuk başı bilet [S20] | Misafir düşünceleri ("fiyat pahalı", "ucuz"), heyecan puanı [S20] | Tepkiyle: şikâyet olunca 0,20 düş [S20] | Yok | Çözülmüş: heyecan/10 yuvarlak aşağı [S20] | "Giriş 50'yi aşma" [S20] |
| OpenTTD | Oyuncu fiyat koymaz; kargo oranı sabit [S15] | Gelir formülü açık [S15] | Yok | Tam otomatik | Karar fiyat değil; rota, mesafe, hız | Belirsiz (şikâyet aranmadı) |
| Transport Fever | Açılmadı | | | | | Bu turda araştırılmadı |
| Football Manager | Açılmadı | | | | | Bu turda araştırılmadı (bütçe bitti) |

## 2. Software Inc (ürün/abonelik fiyatı, optimal fiyat göstergesi)

Okunan: Steam genel tartışma konusu (Nisan 2018) [S1], 2015 konusu [S2, oyunun kendi satış fiyatı, mekanik değil], WangYat2007'nin fiyat esnekliği rehberi (10-11 Haziran 2024) [S3], mağaza sayfası [S4], rehber listesi [S5].

- Fiyat girişi: ürün tasarım belgesinde fiyat var; fiyat değiştirirken oyun önerilen fiyatı gösteriyor (örnekte 150 $) [S3]. 2018'de bir oyuncu: oyun, özellik ekleyip fiyat girince önerilen fiyatı gösterir [S1].
- Esneklik testi (Bilgisayar OS, her fiyat için ayrı kayıt, tek koşu) [S3]:

| Fiyat | Çıkışta adet | 1 yıl sonra kâr | Tanınırlık |
|---|---|---|---|
| 0 $ | 163.627 | -13.713.232 $ | ~2,9 kalp |
| 1 $ | 37.034 | -12.222.404 $ | ~0,9 kalp |
| 75 $ | 53.813 | 13.880.946 $ | ~1,25 kalp |
| 150 $ | 50.289 | 45.714.742 $ | ~1,3 kalp |

- Yazar, 10-70 $ aralığında yüksek fiyatın yüksek satışla geldiğini ve bunu algılanan kaliteyle ("prestij fiyatlaması") açıkladığını yazıyor; satış tepe noktası önerilenin ~%80'inde (120 $), kâr tepe noktası önerilen fiyatta [S3]. Sonuç: "ya ücretsiz ya önerilen fiyat, arası yok" [S3]. Güven: Düşük; tek yazar, kayıt başı tek koşu, tanınırlık gözle tahmin, rehberin Steam tarafından kaldırıldığı ve yalnız yazara göründüğü yazıyor [S3].
- Çıkıştan sonra: 2018'de oyuncu "birim fiyat çıkıştan sonra değiştirilemiyor" diyor [S1]; geliştirici 2015'te "ürün fiyatını değiştirme yeteneği eklenince" fiyatı artıracağını söylemiş [S2]; yazar 75 $'lık tasarım fiyatını 80 $ ve üstüne çıkarınca satışın sert düştüğünü, fiyatın tüketiciye "söz" gibi davrandığını düşünüyor [S3]. 2025 yorumları: "belgede fiyatı düşürünce kimse almıyor", "ürün yaşlanınca fiyat düşürmek satışı çökertiyor" [S3 yorum]. Hangi sürümde değiştiği (varsayım) bilinmiyor.
- Sözleşme/anlaşma: bir strateji rehberi "iki anlaşmadan ayda kırk-elli bin kazanabilirsin" yazıyor, fiyat/pazarlık yok [S5b, Düşük]; bir yorumcu "sözleşme önce, başta düşük fiyatla" öneriyor [S3 yorum]. Sözleşme fiyatı mekaniği: bulunamadı (wiki erişimi 402 verdi).
- Abonelik: bir yorumcu "ücretsiz OS aboneliği + ücretli OS'a özel yazılım" soruyor, cevap yok [S3 yorum]. Abonelik fiyatı mekaniği: bulunamadı.

Oyuna ders: "önerilen fiyat" göstermek bu oyunu tek doğru cevaba çevirdi; oyuncular onu kopyalıyor. ERP'de bir "optimal fiyat" etiketi koyma. Çıkış sonrası değişmeyen fiyat ise oyuncuya "söz" hissi veriyor ve ceza yaratıyor; ERP'de fiyat değişince etkisi (yenileme anında) açık gösterilmeli, "gizli ceza" olmamalı.

## 3. Big Ambitions (mağaza ürün fiyatı, rakip fiyatı, otomasyon)

Okunan: üç Steam konusu [S7, S8, S9], hayran rehberi (30 Ağustos 2026 güncel) [S6], rakip rehberi (1 Eylül 2026) [S10], mağaza sayfası [S11].

- Bilgi: ekranda mevcut fiyat, piyasa fiyatı, önerilen fiyat; Insight "Pricing" puanı; yeni mağazada piyasaya yakın başla [S6]. Zemin rengi: sarı = fiyat bölgedeki en düşük ya da varsayılandan yüksek; kırmızı = ne olursa olsun çok yüksek; "sarı kötü değil, tatlı nokta sarı aralıkta" (geliştirici, 6 Haz 2024) [S7].
- Sıklık: rehber "bir sebep olunca yeniden bak" (yeni mahalle, yeni rakip) diyor ve değişiklikten sonra aynı sayıyı hemen oynamamayı öneriyor [S6]. Oyuncu gerçeği: mağaza başına tek tek [S7, S8].
- Otomasyon: Pricing Manager = merkez rolü, mahalleye atanır, Mevcut/Önerilen/Piyasa karşılaştırır; "Önerilen fiyatları uygula"; rehber körü körüne uygulamamayı söylüyor (yeni, stoksuz, bozulmuş piyasa) [S6]. Oyuncu önerisi: yöneticinin becerisi kaç mağazada tatlı noktayı tutturduğunu belirlesin [S7, Bamser 20 Haz 2024].
- Şikâyetler: 60-70 mağazada kontrol "kâbus" [S7]; rakip batınca tüm dükkânlar yeniden fiyatlanıyor (693 saatlik oyuncu bırakacağını yazdı) [S7]; yama sonrası kâr yarıya, "yama notu oyuncu tarafını söylemedi, uyarı olsun" [S8]; "en ucuzum ama müşteri şikâyet" [S8]; yapay zekâ dükkânları daha pahalı olduğu hâlde müşteri çekiyor gibi görünüyor, hata mı kural mı belirsiz [S8, S9].
- Rakip tepkisi: rakip fiyat kırarsa eşitle (geçici), sonra yavaşça artır, ya da hafif altına in ve depo ile tedarik avantajı kur [S10, Düşük].

Oyuna ders: fiyatın hesap/dükkân başına ölçeklenmesi angarya doğurdu ve ürün sonradan "yönetici + toplu uygula" ile onardı: ERP'de başlangıçtan toplu/katalog düzeyi kur. Bilgi iki yerden iki farklı rakamla verilince güven bitti. Oyuncu gizli yama değişiminden zarar gördü: "gizli ceza yok" kuralı doğrudan geçerli.

## 4. Capitalism Lab, Offworld, OpenTTD (fiyatın oyuncu kararı olmadığı ya da ağırlık karışımı olduğu oyunlar)

- Capitalism Lab: puan = marka + kalite + fiyat ağırlıklı karışım ve ağırlıklar ürüne göre değişiyor [S17]. Düşük puanda ilk çare fiyat indirmek; marka ve kalite yavaş [S17]. Gelir iki tarafı da var: rakiplere satış ancak "düşük fiyat, yüksek kalite" ile [S17]. COO mağaza fiyatını yönetebilir [S17]. Sayfa geliştirici/satıcı anlatımı (Düşük).
- Offworld: oyuncu fiyat koymuyor; fiyat arz-talep, oyuncunun büyük alımı rakibe fırsat yaratıyor, karaborsa alımla fiyat artıp rakibi uyarıyor [S16].
- OpenTTD: gelir = taşıma oranı × miktar × Manhattan mesafesi × teslim süresi çarpanı [S15]. Oyuncu "oran" koymuyor; rota ve hız seçiyor.

Oyuna ders: fiyatı ürün kimliğine bağlayan ağırlık (Capitalism Lab) tek doğru cevabı kırmanın bir yolu: ERP'de bazı sektörler (profil) fiyata, bazıları modül uyumuna ya da destek kalitesine daha duyarlı olsun; ama bu kural 1 hesapta da 50 hesapta da aynı kalır. Fiyatın hiç oyuncu kararı olmadığı oyunlar da var; ERP'de bu "duruş" seçimine (rekabetçi/standart/premium) denk gelir.

## 5. Two Point Hospital ve park oyunları (bilet fiyatı sürgüsü, değer algısı)

- Two Point Hospital: oyuncu raporlarına göre fiyat yüzde kaydırıcı (+100, +0, -10) [S13]; fiyat itibarı ayrı bir ölçü ve "-%10 ve altı itibarı bir puan artırır, %10 ve üstü bir puan düşürür" gibi gözlemler çelişkili [S12, S13]. Oyun hastanın kalite/personel eğitimi arttıkça daha yüksek fiyatı kabul ettiğini söylüyor gibi: "+%100'de ret yok, odalar kaliteli ve personel eğitimli" [S13]. Danışman "fiyat düşür" diye sürekli uyarıyor; çözüm bildirim seviyesini düşürmek [S13]. Bir oyuncu %10 fiyat artışının %10'dan fazla ödememeye yol açtığını söyledi [S12].
- RollerCoaster Tycoon Deluxe (2017 konusu, 57 yorumdan 15'i görüldü): giriş en çok 50 [S20]; oyuncu şikâyet gelene kadar 5 artırır, "fiyat övgüsü" kesilince durur (~45) [S20]; yolculuklarda şikâyet olunca 0,20 düşür [S20]; "bir kere ayarla" formülü heyecan puanının onda biri aşağı yuvarlanır [S20].
- Aynı aramanın özetinden (açılmadı, Düşük): RCT World'de bir tuvaletin geliri fiyat düşünce arttı; oyunun dengesi gevşek, tek coaster'lı parkta 25 alınabilir [S21].

Oyuna ders: kaydırıcı "gerçek" karar sunmuyor gibi görünüyor çünkü ret nedeni tek bir çubuğa bağlı ve oyuncular birbirini yalanlıyor [S12, S13]. ERP'de her kayıp "teklif %X bütçenin üstündeydi" diye yazılırsa oyuncu öğrenir; yoksa "%100 bırak" gibi bir mit doğar.

## 6. Başarısız/eleştirilmiş örnekler

Not: Bütçe sınırlı olduğu için "başarısızlar" ayrı bir WebSearch'le değil, aynı konuların şikâyet ve başarısız deneme yorumları doğrudan okunarak toplandı (Steam konuları ve rehber yorumları). Ayrı, genel bir başarısızlık araması yapılmadı.

- Software Inc: "$10 OS en iyiydi ama batırdı" (21 Şub 2025), "$1 en kötü fiyat" (6 Eyl 2025), "belgede fiyat düşürünce kimse almıyor" (14 Ağu 2025) [S3 yorum].
- Big Ambitions: fiyat kırınca gelir düşüyor ve sarı kalıyor (yanlış beklenti) [S7]; "en ucuzum ama müşteri şikâyet" [S8]; hover fiyatı ile iş ekranı tutarsız [S9].
- Two Point Hospital: bir oyuncu geç oyunda fiyat artamıyor, kâr başa baş, genişleme yok diyerek bırakma noktasından söz etti [S13].
- Bırakma: Big Ambitions'tan bir oyuncu (693,2 saat) mahalle editörü gelene kadar oynamayacağını yazdı [S7]. [SIÇRAMA] bu yalnız bir oyuncu.
- Ayrı arama (Startup Company): ilgisiz sonuçlar; Startup Company için bulunamadı.

## 7. ERP satışına en yakın mekanikler (pazarlıklı B2B teklif/kota/indirim, sözleşme, duruş)

- Software Inc sözleşme/anlaşma: tek rehber "iki anlaşma ayda 40-50 bin" diyor, pazarlık mekaniği yok [S5b]; wiki 402 verdi. Bulunamadı.
- Capitalism Lab: rakibe satış için "düşük fiyat + yüksek kalite", sözleşmeyi bitirmek için fiyatı "çok yükselt" [S17]. Sözleşme fiyatı tek sayı, pazarlık yok (rehber özeti).
- Big Ambitions: rakip fiyat savaşı "eşitle/altına in" [S10].
- "Fiyat duruşu" (kademeli seçim) olan bir oyun bulunamadı. [BOŞLUK] ERP'deki mevcut 3 duruş (rekabetçi/standart/premium) için doğrudan oyun kanıtı yok; en yakını Capitalism Lab'ın marka/kalite/fiyat karışımı ve Two Point Hospital yüzde kaydırıcısı.

Oyuna ders: kademeli duruş seçimi sürekli yeniden koyma angaryasını ortadan kaldırır (Big Ambitions'ın merkez rolü bunun yamadır). Ancak "tek doğru cevap" riskini azaltmak için duruşun getirisi hesabın bütçesine ve sektörün fiyat duyarlılığına göre farklı olmalı (Capitalism Lab ağırlık karışımı).

## 8. Erdem'in soru 8'i için seçenekler (yardımcı yönetmene; ben soru sormuyorum)

Soru 8, SENTEZ §15: A = koltuk başına tek fiyat, B = temel paket + sektör modülü koltuk eki. Aşağıda her seçeneğin oyunda neyi değiştirdiği ve kanıt bağı. [GÖRÜŞ] işaretli satırlar yorumdur.

| Seçenek | Oyuncunun kararı | Sıklık | Kolaylık | Tek doğru cevaba dönme riski | Kanıt |
|---|---|---|---|---|---|
| A) Tek koltuk fiyatı | Her teklifte duruş seçimi | Teklif başına | Çok kolay | Düşük (duruş + bütçe) | OpenTTD/Offworld'de fiyat ya yok ya otomatik [S15, S16] |
| B1) Modül liste fiyatı katalogda bir kez, hesapta yalnız duruş | Katalogda 5-10 satırı bir kez; sonra olay tetikli | Yılda birkaç kez | Kolay; 1 kişi de 50 kişi de aynı | Orta: "önerilen fiyat" yoksa düşük | Big Ambitions toplu/merkez çözümü [S6] |
| B2) Hesap başına modül fiyatı pazarlığı | Her hesap × modül | Her teklifte | Zor; hesap sayısıyla çarpılır | Düşük ama angarya | Big Ambitions 60-70 mağaza kâbusu [S7, S8] |

[GÖRÜŞ] Kanıt B1'i destekliyor, B2'ye karşı. Önerilen/optimal fiyatı oyuna koyma (Software Inc dersi) [S3].

---

## Kaynak sicili

| S# | URL | Yayıncı | Yayın tarihi | Erişim | Güven |
|---|---|---|---|---|---|
| S1 | https://steamcommunity.com/app/362620/discussions/0/3288067088115504970 | Steam Topluluğu, Software Inc oyuncuları | 20 Nis 2018 | 2026-10-20 | Düşük (oyuncu anekdotu) |
| S2 | https://steamcommunity.com/app/362620/discussions/0/535152276584759835 | Steam Topluluğu; geliştirici yanıtı | 29 Tem - 3 Ağu 2015 | 2026-10-20 | Düşük (oyunun kendi satış fiyatı; mekanik değil) |
| S3 | https://steamcommunity.com/sharedfiles/filedetails/?id=3256150569 | WangYat2007, Steam rehberi ve yorumlar (Steam'e göre kaldırılmış) | 10-11 Haz 2024; yorumlar Haz 2024 - Ara 2025 | 2026-10-20 | Düşük (tek yazar, tek koşu) |
| S4 | https://store.steampowered.com/app/362620/Software_Inc/ | Valve (Steam mağazası) | güncel | 2026-10-20 | Orta (yorum sayıları); Düşük (geliştirici anlatımı) |
| S5 | https://steamcommunity.com/app/362620/guides/ | Steam Topluluğu rehber listesi | güncel | 2026-10-20 | Düşük |
| S5b | https://steamcommunity.com/sharedfiles/filedetails/?id=1971495059 | LatN's Strategy (Steam rehberi, kaldırılmış uyarısı) | belirsiz | 2026-10-20 | Düşük |
| S6 | https://www.whisperofthehouse.com/big-ambitions/pricing-guide | Whisper of the House (hayran sitesi) | 30 Ağu 2026 (güncelleme) | 2026-10-20 | Düşük |
| S7 | https://steamcommunity.com/app/1331550/discussions/0/4336483289195964575 | Steam Topluluğu; geliştirici yanıtı içeriyor | 6 Haz - 28 Eyl 2024 | 2026-10-20 | Orta (geliştirici yanıtı) |
| S8 | https://steamcommunity.com/app/1331550/discussions/0/4339861623043791608 | Steam Topluluğu; geliştirici yanıtı içeriyor | 11-12 Haz 2024 | 2026-10-20 | Orta |
| S9 | https://steamcommunity.com/app/1331550/discussions/0/3790381090378813413 | Steam Topluluğu | 14-15 Mar 2023 | 2026-10-20 | Düşük |
| S10 | https://gameshorizon.com/guides/big-ambitions-1-0-rivals-explained-how-they-work-how-to-beat-them/ | GamesHorizon (Pranshu Aryan) | 1 Eyl 2026 | 2026-10-20 | Düşük |
| S11 | https://store.steampowered.com/app/1331550/Big_Ambitions/ | Valve (Steam mağazası) | güncel | 2026-10-20 | Orta |
| S12 | https://steamcommunity.com/app/535930/discussions/0/1737715419909396845 | Steam Topluluğu, Two Point Hospital | Eyl 2018 | 2026-10-20 | Düşük |
| S13 | https://steamcommunity.com/app/535930/discussions/0/1770385542765130889 | Steam Topluluğu, Two Point Hospital | Mar - Ağu 2019 | 2026-10-20 | Düşük |
| S14 | https://store.steampowered.com/app/535930/Two_Point_Hospital/ | Valve (Steam mağazası) | güncel | 2026-10-20 | Orta |
| S15 | https://wiki.openttd.org/en/Manual/Game Mechanics/Cargo income | OpenTTD wiki (topluluk) | belirsiz | 2026-10-20 | Orta |
| S16 | https://en.wikipedia.org/wiki/Offworld_Trading_Company | Wikipedia | güncel | 2026-10-20 | Orta (fiyat formülü yok) |
| S17 | https://www.capitalismlab.com/beginners-guide-gameplay-basics/ | Capitalism Lab (Enlight/geliştirici sitesi) | belirsiz | 2026-10-20 | Düşük (satıcının kendi ürünü) |
| S18 | https://www.capitalismlab.com/resources/gameplay-faq/ ; https://www.capitalismlab.com/resources/strategy-tips/ | Capitalism Lab | belirsiz | 2026-10-20 | açıldı, fiyat bilgisi yok |
| S19 | https://en.wikipedia.org/wiki/Game_Dev_Tycoon ; https://en.wikipedia.org/wiki/Capitalism_Lab | Wikipedia | güncel | 2026-10-20 | Orta; fiyat bilgisi yok |
| S20 | https://steamcommunity.com/app/285310/discussions/0/133257636766778445 | Steam Topluluğu, RollerCoaster Tycoon Deluxe | Şub - Mar 2017 | 2026-10-20 | Düşük |
| S21 | https://steamcommunity.com/app/282560/discussions/0/208684375413705191 | Steam Topluluğu, RCT World (yalnız arama özeti, açılmadı) | belirsiz | 2026-10-20 | Düşük |

Açılamayan/engelli: Software Inc ve Two Point Hospital Fandom wikileri (HTTP 402), Big Ambitions wiki.gg (401), Software Inc wiki.gg (401), Wikipedia "Software Inc." ve "Mad Games Tycoon" (404), Steam arama (429). Game Dev Tycoon, Mad Games Tycoon 2, Startup Company, Football Manager, Transport Fever ve Software Inc sözleşme fiyatı için olgu bulunamadı; model bilgisiyle doldurulmadı.
