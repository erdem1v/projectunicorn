# B · "Bilinen yol" indirimi (Erdem soru 10, anlaşılmadı)

Tarih: 2026-10-20. Arama: 8/8 WebSearch kullanıldı (hepsi sonuç döndürdü; biri yalnız aday listesi verdi). Ayrıca yaklaşık 38 WebFetch (bir kısmı 402, 403, 404, 429 ile döndü) ve üç PDF'in yerelde metne çevrilmesi. Oyun koduna, CSV'ye, data/'ya yazılmadı.
Etiketler: [BOŞLUK] kanıtsız yük taşıyan iddia · [SIÇRAMA] kanıttan çıkmayan sonuç · [GÖRÜŞ] yazarın değerlendirmesi · (varsayım) kaynaksız sayı · [WORKING] kalibrasyon girdisi. Kaynaklar sonda, S# ile. "Devralınan" = bu klasördeki önceki dosyalardan (A1, B1, B2, V, SENTEZ, K) alınan, bu oturumda yeniden açılmamış olgu.

---

## ÖZET

**Kural ne?** Bir modülün bir kademesini kendisi hariç en az iki şirket yayımlamışsa, o kademeyi yapmak kartın eforunu ~%20 düşürür (20 puan 16 olur). İlk yapan tam bedel öder. Rakip senin özelliğini almaz; yalnız kartı kendi ekibiyle yürütür ve bedeli düşer.

**Bulgular (kaynaklı)**
1. Taklit gerçekten ucuzdur. Mansfield ve ark. (1981) ile iki benzer çalışmanın ortak okuması: taklit maliyeti yenilik maliyetinin 0,4 ile 0,9 katı, süresi 10 ay ile 2 yıl; başarılı patentli yeniliklerin %60'ı 4 yılda taklit edilmiş [S12, S13 üzerinden, ikincil]. "%65 ve %70" rakamı çok aktarılıyor ama birincil kaynakta doğrulanamadı [BOŞLUK]. Bu aralık "%20 ucuz"un gerçek dünyaya göre ihtiyatlı olduğunu söyler, ama örnek 1970'lerin kimya, ilaç, elektronik, makine ürünleridir, yazılım değil [SIÇRAMA].
2. Öncü olmak pahalı ve çoğu kez ödülsüz: 50 kategori, ~500 marka; öncülerin %47'si battı, ortalama pazar payı %10 (hayatta kalan öncüler %19), bugünkü lider öncü olanlar 36 kategorinin %11'i, erken liderler öncüden ortalama 13 yıl sonra girmiş [S9]. Dayanıklı mal kategorilerinde batış oranı iki katından fazla (teknoloji değişimi) [S9]. Öncü avantajı pazar ve teknoloji yavaş değişirken tutuyor [S10, S11].
3. ERP'de "fark yaratan" özelliğin "herkeste olan"a dönüşme hızı özelliğe göre yaklaşık 15 kat değişiyor: bulut NetLedger 1999 → SAP ByDesign duyurusu 19 Eylül 2007 [S20]; Panorama örneklemi SaaS payı %4 → %33 (iki ardışık rapor, örneklem farklı) [S16]. YZ asistanı: Microsoft 6 Mart 2023 [S17], Oracle ve SAP Eylül 2023 [S18]; üç büyük 6,5 ayda aynı çizgiye geldi.
4. Oyunlarda "bilinen şey ucuz" kuralı yaygın ve üç biçimi var: kaç kişi biliyor (Civ IV: bilen oranı × 0,30, en çok +%30 hız ≈ −%23 maliyet [S5, hesap]), ne kadar geridesin (Europa Universalis IV: geride kalınan her seviye −%5, en çok −%75 [S4]; Capitalism Lab: açık oranı kadar ek kazanç [S1]), yalnız başkasının bildiği şeyi seç (Victoria 3 teknoloji yayılımı [S2, S3]).
5. Karşı görüşler zayıf kaynakta: "catch-up kazanana haksızlık, bekleyen ödüllenir (sandbagging)" [S8, Düşük, 2011 forum]; oyuncu davranışını bozma riski genel olarak not edilmiş [S7]. Öncüye ceza şikâyeti için doğrudan kaynak bulunamadı [BOŞLUK].
6. Kural, tavanı kaldırmaz: yalnız "başkasının zaten yaptığı" kademeye uygulanır, sınırdaki kademe tam bedeldir [mantık, sim ile doğrulanacak].

**Oyuna ders**
- Soru 10'u üç seçenek olarak sor: (A) kural yok, geri kalan yalnız verimle yetişir; (B) bilinen yol (eşik); (C) Ar-Ge'de "piyasa bilgisi" düğümü (oyuncu seçer). Her birinin oyuncuya etkisi §3 tablosunda.
- Karar sıklığı: kural her kart açılışında iki fiyatı yan yana gösterir (20 yerine 16); oyuncu kararı "bu modülde yetişeyim mi, öncü mü olayım" modül başına, kademe başına, yani sprint başına birkaç kez. Çarpan olduğu için 1 kişide de 50 kişide de kırılmaz.
- Varsayılan ön hüküm [GÖRÜŞ]: sim'e kadar (A). Çünkü "olabildiğince basit", ve iç biçim denetimi (bicim7) kural olmadan istenen biçimi (dev geçilebilir ama geç) verebilen bir ayar buldu. (B) yalnız sim gerekçe gösterirse girer.
- Tut kriteri: kuralsız simde takipçi bot 104 haftada L'ye (ikinci en iyi seviye) yetişemiyor ve G2 düşüyorsa tut. Düşür: kuralsız G2 geçiyorsa, kuralla G1 (doygunluk) bozuluyorsa ya da "bekleyen bot" öncü botu geçiyorsa (§5).
- Tek uygulama seçimi: eşiği kimler doldurur. Öneri: oyuncu sayılmaz (SENTEZ §6.1 "oyuncu standarda girmez" ile aynı), yoksa oyuncunun yayımı rakibi ucuzlatıyor gibi okunur ve Erdem'in "kopyalama yok" kararıyla bulanır.
- Kod: eşik zaten hesaplanıyor (SENTEZ §6.1'in L(m)'si = "en az iki şirketin yaptığı seviye"). Kural tek satır çarpan: `efor × (kademe ≤ L(m) ? 0,8 : 1)`. Ayar tek sabit. Zor kısım gösterim (kartta iki fiyat, haber satırı).
- Oyuncunun görmesi gereken: gizli indirim olmaz. Kartta "Yaygın yol: 3 şirket yayımladı, −%20", 7. kademede "Henüz kimse yapmadı: tam efor, ilk sen olursan öncü haberi".
- Ar-Ge'deki mevcut efor düğümleriyle (ör. tasarım hattı −%20) çarpılarak birleşir (0,8 × 0,8 = 0,64). İki yol birden açıksa iç tutarlılık için üst sınır koy [GÖRÜŞ].

---

## 1. Gerçek dünya: taklit, yetişme, öncü avantajı

### 1.1 Taklit ne kadar ucuz

- Mansfield, Schwartz ve Wagner (1981), Economic Journal 91(364):907-918, "Imitation Costs and Patents: An Empirical Study" [S12]. Makalenin özetini (abstract) hiçbir açık kaynakta bulamadım (RePEc: "No abstract is available") [BOŞLUK].
- İkincil aktarım (Giménez 2011, Zaragoza working paper [S13]): "Mansfield ve ark. (1981), Levin ve ark. (1987), Harabi (1991) taklit maliyetinin yenilik Ar-Ge maliyetine oranının 0,4 ile 0,9 arasında olduğunu, ürünün karmaşıklığına ve patentli olup olmamasına göre değiştiğini; taklit süresinin 10 ay ile 2 yıl arasında olduğunu gösteriyor." Aynı çalışma Mansfield ve ark.'na atfen: "başarılı patentli yeniliklerin %60'ı 4 yıl içinde taklit ediliyor" [S13]. Bunlar üç makalenin birleşik okumasıdır, Mansfield'in tek başına sayısı değildir.
- Görev metnindeki "taklit maliyeti ~%65, süresi ~%70" rakamı: bir arama özeti "48 yeni ürün; kimya 19, ilaç 16, elektronik 10, makine 3" ve "%65 maliyet, %70 süre" diyor, ama bunu bir kitap-not sayfasına dayandırıyor ve ben o sayfayı açamadım; Japonca bir makale aynı örneği özetliyor ama metni metne çevrilemedi. Rakam makul ve 0,4-0,9 aralığının ortasında, **birincil kaynakta doğrulanamadı** [BOŞLUK]. Raporda "~%65" diye yazılırsa Düşük güvenle ve "çok aktarılan" notuyla yazılmalı.
- Mansfield (1985), Journal of Industrial Economics 34(2):217-223, "How rapidly does new industrial technology leak out?" yalnız künyeyle doğrulandı [S14]; içeriği (bilginin rakibe sızma süresi) bu oturumda okunamadı. Hafızadan yazmıyorum.
- Yazılım ve ERP için özgül bir "özellik taklit maliyeti" ölçümü bulunamadı [BOŞLUK]. 1970'lerin fiziksel ürün örneğinden yazılıma geçiş [SIÇRAMA]: yazılımda kopyalama bedelsizdir ama "ne yapılacağını bilmek" (spesifikasyon) maliyetin büyük kısmıdır; bu görüş bir hipotezdir, kaynağım yok.
- Emilim kapasitesi: Cohen ve Levinthal (1990), Administrative Science Quarterly 35(1):128-152: dışarıdan bilgiyi değerlendirmek için firmanın kendi ilgili birikimi ve Ar-Ge'si gerekir; yatırım biriktikçe kolaylaşır, bırakılırsa yetenek kaybolur [S15, Wikipedia özeti]. Oyuna etkisi: "bilinen yol"dan yararlanmak için o modülde zaten bir şey yapmış olmak (önceki kademe) şart koşulabilir; yani 6. kademe indirimi 5. kademeyi bitirmiş şirkete gelir. Bu zaten kademe sırasıyla sağlanır, ayrı kural gerekmez.

**Oyuna ders.** "Bilinen yol" gerçek dünyadaki taklit ucuzluğunu temsil eder; %20 literatürün alt ucundan ihtiyatlı. Ama yazılım için sayı kaynaksızdır, bu yüzden sabit [WORKING] olur ve sim'de ayarlanır. Oyuncunun kararını "bu kademeyi şimdi mi yapayım, beklesem mi" yönünde etkiler; bu yüzden kurala karşı "bekleyen oyuncu" testi şart (§5).

### 1.2 Öncü avantajı: ne zaman tutuyor, ne zaman tutmuyor

- Golder ve Tellis (1993), Journal of Marketing Research 30(2):158-170 [S9] (PDF'i yerelde metne çevirip okudum): tarihsel analiz, yaklaşık 500 marka, 50 ürün kategorisi; "failure" = ilk girdiği marka adıyla satışın bitmesi. Öncülerin batış oranı %47; ortalama pazar payı %10 (1945 sonrası kategorilerde %7); yalnız hayatta kalan öncülerde %19; bugünkü uzun ömürlü lider öncü olan kategori %11 (36 kategoride); erken liderler öncülerden ortalama 13 yıl sonra girmiş. Batış oranı dayanıklı mallarda dayanıksızdan iki kattan fazla, makale bunu "dayanıklı mallarda daha çok teknolojik değişim" ile açıklıyor. Önceki çalışmalarda %30'a yakın pay görülmesi, hayatta kalanlara bakıldığı için. Sınır: kategori tanımı keyfî (yazarlar kendileri söylüyor); pazarlama karması etkisi kontrol edilmedi.
- Lieberman ve Montgomery (1988), Strategic Management Journal 9(S1):41-58: üç öncü avantajı kaynağı (teknoloji liderliği, kıt kaynakları önceden tutma, alıcı geçiş maliyeti); dezavantajlar: öncü başlangıç maliyetini daha çok öder, teknoloji ilerledikçe eskiyebilir; pazar payı tek başına zayıf ölçüt, kâr bakılmalı [S10, UCLA Anderson Review aktarımı; Wiley sayfası 403 verdi, özet bu oturumda okunamadı].
- Suarez ve Lanzolla (2005 HBR; ayrıntılı çalışma 2007 AMR): öncüler pazar yavaş evrilirken ve önemli teknolojik ilerleme olmazken daha çok başarılı; "her öncü avantajını kanıtlayan çalışmaya karşı bir kanıtlamayan var" [S10 aktarımı, S11 yalnız giriş paragrafı açıldı]. Gomez, Lanzolla ve Maicas (2016, Long Range Planning): Avrupa'da 2G'den 3G'ye geçişte öncüler pazar payı ve kâr avantajını kaybetti [S10 aktarımı].
- Wikipedia'nın "first-mover advantage" sayfası bu çalışmaların sayılarını taşımıyor ve kendi bakım etiketleri var; kullanılmadı [S22].

**Oyuna ders.** Gerçek dünya "öncü hep kazanır" demiyor; ERP'de bulut ve YZ gibi hızlı teknoloji değişimi dönemlerinde öncü avantajı zayıf [S10, S11, GÖRÜŞ]. Öte yandan ERP'de alıcıyı kilitleyen yüksek geçiş maliyeti (Lieberman'ın üçüncü kaynağı) var; yani ödül "pazar payı" değil "bağlanmış hesaplar". Oyuna etkisi: öncüye verilecek ödül (haber, 4-5★ adayın ilgisi, hesap bağlılığı) sorusu kuralın parçası olarak tasarlanmalı; yalnız "takipçiye indirim" yazarsak öncülüğün bedeli var ama ödülü kalmaz. Ödül zaten SENTEZ §8.4'te tanımlı (ilk K1'e öncü haberi ve o hattı isteyen 4-5★ aday), kural bunu bozmamalı.

### 1.3 ERP'de "fark yaratan"dan "olmazsa olmaz"a dönüş süresi

| Özellik | İlk | Büyük satıcıların yanıtı | Alıcıda yayılma | Kaynak |
|---|---|---|---|---|
| Bulut ERP | NetLedger/NetSuite 1999-2002 (devralınan) | SAP ByDesign duyurusu 19 Eylül 2007; 2021'de ~10.000 şirket kullanıyor, 2022'de kapanış söylentisi ve SAP'nin yalanlaması | Panorama (562 yanıt): SaaS seçimi 2014 anketinde %4, 2015 raporunda %33; yerinde %85 → %56 [S16]. 2023'te bulut seçimi %65 (devralınan, A1-S35) | [S16, S20, A1] |
| YZ asistanı | Microsoft Dynamics 365 Copilot 6 Mart 2023 [S17] | Oracle Fusion HCM'de üretken YZ 28 Haziran 2023 (arama özeti, açılmadı); Oracle ~50 Fusion özelliği ve SAP Joule Eylül 2023; Joule S/4HANA Cloud'a 2024 başı (plan) [S18] | Panorama 2024'te YZ en az tercih edilen girişim, +%10,2 (devralınan, A1-S35) | [S17, S18] |

- Bulutta büyük satıcının ilk resmî yanıtı ilk çıkıştan ~8 yıl sonra; YZ'de ilk duyurudan ~6,5 ay sonra. Yaklaşık 15 kat fark (96 ay ÷ 6,5 ay). Not: duyuru ile ürünün müşteride çalışması aynı şey değil (Microsoft sayfası kullanılabilirliği söylemiyor, Joule S/4HANA'ya 2024'e planlı) [S17, S18].
- Maliyet tarafı: Panorama 2015'te bulut ERP uygulayanların %56'sı uygulama maliyetinde %41-60 tasarruf bildirdi; rapor, önceki yıllarda bu iddianın veriyle desteklenmediğini de yazıyor [S16]. Bu **alıcının** uygulama maliyetidir, satıcının geliştirme eforu değil, kural için doğrudan kanıt sayılmaz [SIÇRAMA]. Panorama danışmanlık satan bir şirket; örneklemi kendi web sitesi ve Mint Jutras anketi, seçilim yanlılığı olası [S16].
- Açık kaynak: ERPNext GPL-3.0 altında, lisans ücreti yok [S21]; Odoo gelir 282 M€ (2023), 2.200+ çalışan (devralınan, V #6 doğruladı). Bunlar alıcının lisans maliyetini düşürür; "açık kaynak satıcının özellik geliştirme eforunu düşürüyor" iddiası için kaynak bulunamadı [BOŞLUK].
- Dönem hattı örnekleri zaten B2 ve A1'de (e-fatura 2016 mevzuat geçişi; V #2'ye göre 2014 değil).

**Oyuna ders.** Yayılma hızı özelliğe göre çok değişiyor. Tek sabit %20 bunu yansıtmaz; ama basitliği korumak için ayrı bir "yayılma gecikmesi" kuralı eklemek şart değil: eşik zaten "iki şirket yayımladı" demektir, yayılmayı rakiplerin gerçek hızı belirler. Yani hızlı yayılan bir özellikte (YZ) indirim erken, yavaş yayılanda (bulut) geç devreye girer. Oyuncuya etkisi: dönem hattında (bulut/YZ) kural kendiliğinden "öncü bir süre yalnız" ve sonra "herkes yapabilir" hissini verir.

---

## 2. Oyunlarda benzer kurallar

| Oyun | Kural | Kime uygulanır | Sayı | Kaynak, güven |
|---|---|---|---|---|
| Civilization IV | "Bilen medeniyet oranı" çarpanı: 1 + 0,30 × (tekniği bilen yaşayan medeniyet sayısı ÷ başlayan medeniyet sayısı), aşağı yuvarlanır. Rehber bunu tekniğin maliyetine değil üretilen araştırma puanına uygular (bir forum başlığı tersini savunuyor) | Her takım için işliyor; yapay zekâya uygulandığı rehberde ayrıca yazılı değil | Hepsi bilirse ×1,30 = maliyette ≈ −%23 (hesap); yarısı bilirse ×1,15 = −%13; rehberin örneği 3/7 → ×1,12 | [S5] Orta-Düşük (topluluk rehberi, tarihsiz) |
| Europa Universalis IV | Komşu bonusu: sermayeye karadan komşu ya da aynı teknoloji grubundaki en ileri ülkenin gerisindeki her seviye için −%5 teknoloji maliyeti, en çok −%75. Ek: casusluk ağıyla seviye başına −%5, en çok −%30 (DLC). **Öncüye ceza:** tarihsel tarihinden erken olan ülkede sonraki teknolojinin maliyeti yıl başına +%10 | Ülke başına (oyuncu/yapay zekâ ayrımı sayfada yok) | −%5/seviye, tavan −%75; +%10/yıl | [S4] Orta (sayfa 1.30/1.31 için doğrulanmış, sayılar eskimiş olabilir) |
| Victoria 3 | Teknoloji yayılımı: her ağaçta bir teknoloji, yalnız en az bir başka ülkenin araştırmış olduğu teknolojiler arasından rastgele seçilir; hız = (25 + 0,2 × harcanmamış yenilik + 0,75 × okur yazarlık %) × çarpanlar × rastgele 0,5-1,5. En ileri ülkeler çoğu zaman yayılımdan kazanamaz çünkü bilinecek bir şey kalmamıştır. Ayrıca: önceki dönem teknolojisini atlayarak araştırmanın maliyet cezası (atlanan her teknoloji için 0,25 × dönem farkı × taban maliyet) | Tüm ülkeler | Yayılım "maliyet indirimi" değil yenilik puanı akışıdır [S2] | [S2] Orta (topluluk wiki), [S3] Orta-Düşük (TheGamer rehberi, 25 Ekim 2022) |
| Capitalism Lab (Digital Age DLC) | Ek teknoloji kazancı = temel kazanç × (en yüksek seviye − seninki) ÷ en yüksek seviye; yalnız rakibin seviyesi 100'ü aşınca ve seninki belirgin düşükken. Örnek 50 / 500 / 30 → +27 (toplam 57) | Sayfa yalnız oyuncu tarafını anlatıyor, yapay zekâya uygulandığı yazılı değil (V #18) | Seviyenin %10'una düşmüşken kazanç ≈ ×1,9 | [S1] Düşük-Orta (satıcı kendi belgesi) |
| Civilization VI | "Eureka": belirli bir işi yapınca ilgili teknoloji ilerler (Wikipedia'da örnek: barbar kampı yıkmak → Askeri Gelenek). Sayı bu oturumda doğrulanmadı | Oyuncu eylemine bağlı, başkasının bilmesine değil | Bulunamadı | [wiki: Civilization VI] Orta, sayı yok [BOŞLUK] |

Açılamayanlar: Civilization V/VI Fandom sayfaları 402 verdi; Alpha Centauri, Endless Legend, Stellaris'in yetişme kuralları aranmadı ya da doğrulanmadı [BOŞLUK]. "Alpha Centauri'de tech leakage" iddiasını doğrulayamadım; yazmıyorum.

**Genel kavram.** Rubber band (geride kalana yardım) bir tür dinamik zorluk ayarıdır; Mario Kart'ta öğe dağılımı, M.U.L.E.'de rastgele olayların lidere şanssız olması [S7]. Savunanlar: Crash Bandicoot tasarımcısı "zayıf oyunculara yardım et, iyi oyuncuların oyununu değiştirme"; Crawford "puan zamanla düzgün artan eğri olmalı" [S7].

### 2.1 Olumsuz ve eleştirilmiş örnekler (ayrı arama)

- Kaynaklar: Wikipedia "Rubber band AI" [S7]: parametre manipülasyonu "implausible situations" üretebilir, ölçülü kullanılmalı, oyuncular erken seviyelerde kötü oynayıp sonrasını kolaylaştırmayı öğrenmiş (Rollings ve Adams'tan), 2020'de EA'ya açılan toplu dava ve 2021'de geri çekilmesi **iddia**, bulgu değil.
- Board Game Design Forum (Ağustos 2011) "catch mechanics" başlığı [S8]: lideri vergilemek "kazanmanın anlamı ne" sorusunu doğurur; yetişme mekaniği kazananı "kandırılmış hissettirir"; "sandbagging'i (kasten geride kalmayı) teşvik eder, genel olarak eğlenceli değil"; çözüm önerileri: şartlı sübvansiyon (yalnız 1-2 kontrat gerideyken, yetişince biter), herkese birden verilen evrensel bonus, birden çok kazanma yolu. Kaynak Düşük (forum, masaüstü oyun tasarımcıları, dijital strateji oyuncusu değil).
- Civ IV forumunda (Apolyton, tarihi sayfada yok) tersi: "başkası bulunca ucuzlama" Civ III'te var, oyuncu "yeterince azaltmıyor" diyor; bir oyuncu "herkesin barutu var, ben yüzyıllar sonra araştırıyorum" diyor [S6]. Yani eleştiri "çok yardım" değil "çok az yardım". Kaynak Düşük.
- Victoria 3 modu yorumunda "baz yenilik 50'de tanınmayan ülkeler Batı'yı gerçekçi olmayacak kadar kolay yakalıyor" ifadesi yalnız arama özetinde, sayfa 429 verdi, açılamadı [BOŞLUK]. Kullanmıyorum.
- İki Stellaris Steam başlığı (Mart ve Nisan 2024) araştırma hızı kırpmasını tartışıyor, yetişme kuralıyla ilgisi yok; kanıt sayılmadı [S24].
- **Öncüye ceza şikâyeti:** doğrudan bulunamadı [BOŞLUK]. EU4'ün "ahead of time" cezasına dair şikâyet aramalarda çıkmadı (tek aramada, hedefli değil). Devralınan: Game Dev Tycoon'da "ölçüt senin en iyi işin" kuralı "nedeni görünmeyen zorlaşma" diye tepki aldı (Steam, Ekim 2017, B2-S4, Düşük, bu oturumda açılmadı).

**Oyuna ders.** Üç yetişme biçimi var ve oyuncuya hissettirdikleri farklı: (1) kaç kişi biliyor (Civ IV, Vic3): kaynağı dışarıdaki bilgi, "yalnız başkasının bildiğine uygulanır", lider zaten faydalanmaz; (2) ne kadar gerisin (EU4, Capitalism Lab): doğrudan geride kalana destek, liderin etkilediği; rubber band'e en yakını bu; (3) eylemle kazan (Eureka). "Kopyalama yok" ve "gizli ceza yok" kararlarına en uygun olanı (1): lideri hiç cezalandırmaz, geride kalanı gerisinden değil dışarıda zaten bilinenden destekler, her şey gösterilebilir. Risk: (2) gibi "geride kalmayı ödüllendiren" okunmasıdır; bunu doğrulamak için "bekleyen bot" testi (§5).

---

## 3. ERP oyunundaki karşılığı ve alternatifleri

Ortak varsayım: rakipler oyuncuyla aynı kart kataloğunu ve Ar-Ge ağacını kendi ekipleriyle yürütür; kademe eforu yumuşak artar (örnekte ×1,45, bicim7'den, [WORKING]); standart S(m) medyan, kısa liste L(m) "en iyi ikincisi" (SENTEZ §6.1).

| Seçenek | Ne yapar (oyuncu diliyle) | Hangi kararı etkiler | Sıklık | "Öncü olmanın bedeli" hissi | Kod / ayar | Risk ve kanıt |
|---|---|---|---|---|---|---|
| **A. Kural yok** | Geride kalan yalnız verimle yetişir: daha çok geliştirici, PM, Ar-Ge'nin efor düğümleri, odak | Hangi modüle ekip koyayım, hangi Ar-Ge düğümünü alayım | Sürekli, sprint başına | Öncü bedelini kartın tam eforu ve yeni kodun hata terimiyle öder (K §6: hata ∝ yeni efor). Ödülü haber ve 4-5★ ilgi | Hiç ek kod. Ayar: efor eğrisi (g), rakip kapasitesi, dönem açılımı | Biçim denetimi: dik efor + yalnız verimle "önde başlayan önde kalır" (bicim3/4: oyuncu devi ≤2/17 hatta geçti); yumuşak efor + oyun ölçeğinde rakip takımlarla (bicim7) dev 6-11/19 hatta geçildi. Sayılar uydurma dünyadan, gerçek kanıt değil |
| **B. Bilinen yol** (eşik) | Bir kademeyi kendin hariç ≥ 2 şirket yayımladıysa kartın eforu %20 düşük; kartta iki fiyat yan yana. İlk yapan tam bedel | "Şimdi yetişeyim mi, beklesem mi, yoksa ilk ben mi olayım" | Her kart açılışı; yetişilen modül başına bir dizi kart | Öncü tam bedel ödediği için bedeli açık: "20 puan, kimse yapmadı"; ödül aynı | Tek çarpan; eşik L(m)'den hazır. Gösterim: kartta iki fiyat, haber satırı | Sandbagging (bekleyen ödüllenir) riski [S7, S8]; Ar-Ge efor düğümleriyle üst üste biner; her şey herkes için aynı olduğundan gizli değil. Gerçek dünyada yön doğru, yazılım için sayı kaynaksız (§1.1) |
| **B′. Bilinen yol, oransal** | İndirim, yayımlayan şirket oranına ya da geride kalınan kademeye göre değişir (Civ IV ya da EU4 biçimi), ör. kademe başına −%5, tavan −%25 | Aynı | Aynı | Eşiksiz: ilk rakip yayımlayınca küçük indirim. Daha yumuşak ama açıklaması zor | İki parametre (oran, tavan) | Daha doğal ama "neden 17 değil 16" sorusu doğar. Erdem "olabildiğince basit" dediği için B′ B'nin üstüne çıkmaz |
| **C. Ar-Ge'de "piyasa bilgisi" düğümü** | Oyuncu parayla seçer: bilinen kademelerde (B'deki eşik) efor −%20. Rakipler de alabilir (aynı ağaç) | Ar-Ge parası bu düğüme mi, başka efor ya da özelliğe mi | Bir kez, belki iki (oyun başına) | Kimse bedava almaz: geride kalan bedel öder. Öncü hiç almaz | Bir düğüm, bir etki. Eşiğin hesabı aynı. Rakibin Ar-Ge seçim kuralına eklenmeli | Emilim kapasitesi mantığına (Cohen-Levinthal) en yakın: bilgiyi kullanmak için yatırım gerekir [S15]. Ar-Ge ağacında düğüm sayısı zaten sınırlı, bir düğüm daha |
| **D. Mevzuat ya da standart yükselince herkes için ucuz** | Dönem olayı: "E-belge standardı yayımlandı, e-Belge hattı K1-K2 herkes için ucuz". Oyuncu seçmez | Yok (tepki: hemen o hatta mı gireyim) | Dönemde 2-4 kez, hat bazlı | Öncüye bedel yok, ama dönem hattı öncülüğü zaten "bir süre yalnız" | Dönem tablosuna bir sütun | Gerçek dünyada standardın satıcı efor maliyetini düşürdüğüne kaynak yok [BOŞLUK]; Panorama bulut tasarrufu alıcıya ait [S16]. Mevzuat tarihi V #2'ye göre 2016 (454 sayılı tebliğ) |
| **E. A + yumuşak efor** (B yerine ayar) | Kural koyma; efor eğrisini yumuşat ve rakip kapasitesini oyun ölçeğine çek | Yok (oyuncu fark etmez) | Yok | Bedel zaten kartın eforu | Mevcut veri dosyasının ayarı | Aşırı yumuşatırsa herkes tavanda (bicim5: 2018'de K8). Frontier da kayar, tek başına ayrı bir kol |

Kural ile ayar arasındaki fark (kritik): B yalnız ikinci en iyi seviye L'ye kadar olan kademeleri ucuzlatır, L üstü ve sınırdaki kademe tam bedel kalır. Eforu genel yumuşatmak (E) tavan kademelerini de ucuzlatır. Yani B, geride kalanı sınıra yaklaştırır ama sınırı ileri itmez; ancak medyanı (standardı) sınıra yaklaştıracağı için G1 (medyan tavanın ≥ 1 kademe altında) kontrolü şart [mantık, sim ile doğrulanacak].

**Oyuna ders.**
- Karar yoğunluğu: B her kartta bir sayı farkı olarak görünür ama yeni karar eklemez; karar "yetiş mi, ilk mi ol" zaten vardı. C bir kez verilen yeni bir karar ekler. D hiç karar eklemez.
- Öncü bedeli hissi: B ve C'de öncünün bedeli (indirimsiz tam efor ve yeni kodun hata terimi) görünür kalır; A'da da var ama takipçi için yetişme yolu yalnız verim. D'de bedel öncüye düşmez.
- "Gizli ceza yok" kararına en uygun B (iki fiyat ve neden yazar), sonra C (oyuncu satın alır), sonra A, en son D (oyuncu etkileyemez).
- "Kopyalama yok" kararı: B, C, D'nin hiçbiri rakibe senin kartını vermez; yalnız bedel düşer.

---

## 4. Oyuncu örneği (Erdem'in anlayacağı dilde)

(Tüm sayılar varsayım; 20 puan örnek, ×1,45 bicim7'den.)

2016 Mart. Stok modülünün 6. kademesini Werktag, Pythia ve Datenwald yayımladı. Sen sprint planında 6. kademe kartını açtığında kart normalde 20 efor puanı tutuyor; ekranda "16 (yaygın yol: 3 şirket yayımladı)" yazıyor, 20 üstü çizili. Çünkü piyasada herkes nasıl yapılacağını biliyor: bu senin ekibine yaklaşık dörtte bir daha hızlı demek (16 puan 20 puanın %80'i; 1 ÷ 0,8 = 1,25).

7. kademeyi henüz kimse yapmadı: kart 29 puan (20 × 1,45), indirim yok. İlk sen yaparsan 29 puanın tamamını ödersin ve yeni kodun hata terimi büyük efordan dolayı daha yüksek çıkar; karşılığında haber şeridinde "Stok 7'yi ilk yayımlayan" olarak anılırsın ve Stok 7'yi isteyen 4-5★ aday seninle konuşur. Senin yayımın rakiplerin 7. kartını ucuzlatmaz, çünkü eşik yalnız rakipleri sayar. Werktag ve Pythia da 7'yi yayımlayınca, henüz yapmamış üçüncü şirketin (Ardenna) 7. kartı 29 yerine 23 puana iner, çünkü artık iki şirket nasıl yapılacağını biliyor.

Seçim: ya 6. kademeyi 16 puana yapıp yetişirsin, ya ekibi 7'ye kaydırıp 29 puanla ilk olursun, ya Ar-Ge'ye para koyarsın. Hiçbir rakip senin özelliğini kopyalamadı; yalnız yapılmış şeyin bedeli düştü.

Not: eşik "kendisi hariç, yalnız rakipler" sayıyor (§6). Oyuncu bir kademeyi ilk yayımlarsa rakipler hemen ucuzlamaz; iki rakip yayımlayınca üçüncü rakip ve henüz yapmamışsan sen ucuz yaparsın.

**Kural ne zaman gereksiz?** (a) kuralsız simde geride kalan bot L'ye yetişebiliyor; (b) efor eğrisi yumuşak ve rakip kapasitesi oyun ölçeğinde (bicim7 biçimi); (c) Ar-Ge'nin efor düğümleri geride kalana zaten %20-25 veriyor; (d) kartta iki fiyatı gösteremiyorsak gizli indirim olur; (e) oyuncular "bekle, sonra ucuz yap" stratejisine kayıyorsa.

---

## 5. Tut mu düşür mü: kriter

Kural için sim kolları (SIM2 G2 kolu sentezde eklenecek; burada beklemedim): B0 kuralsız · B1 eşik 2, %20, oyuncu sayılmaz · B2 eşik 2, %20, oyuncu sayılır · B3 eşik 1, %20 · B4 Ar-Ge düğümü.
Ölçüler (hepsi [WORKING], hedefler önce yazılır):

| # | Soru | Düşür | Tut |
|---|---|---|---|
| 1 | Kuralsız (B0) G2 geçiyor mu (odaklı ya da verimli bot 2018-2022'de ≥ 1 modülde lider)? | Geçiyorsa düşür (gereksiz) | Geçmiyorsa devam, 2'ye bak |
| 2 | Kuralsız takipçi bot, 3 kademe geride başlayıp 104 haftada L'ye yetişiyor mu? | Evet: düşür | Hayır: tut |
| 3 | Kuralla G1 (2014 sonrası medyan tavanın ≥ 1 kademe altında) bozuluyor mu? | Bozuluyorsa %20'yi %10'a indir; hâlâ bozuluyorsa düşür | Bozulmuyorsa tut |
| 4 | **Bekleyen bot**: her kademeyi ancak ≥ 2 rakip yaptıktan sonra yapan bot, öncü botu 104 haftada toplam gelirde > %10 geçiyor mu? | Geçiyorsa düşür ya da öncü ödülünü artır (aday ilgisi, hesap bağlılığı) | Geçmiyorsa tut |
| 5 | G3 (öncü bot dönem hatlarının ≥ %50'sinde ilk K1) bozuluyor mu? | Bozuluyorsa düşür | Bozulmuyorsa tut |
| 6 | Oyuncu sayılıp sayılmaması (B1 ve B2) sonuçları değiştiriyor mu? | Fark küçükse B1 (oyuncu sayılmaz, daha sade) | Fark büyükse nedenini yaz |
| 7 | Ar-Ge efor düğümleri ile birlikte (0,8 × 0,8) bir şirket L'ye bir yılda ulaşıyor mu? | Evet: bileşik tavan koy (örn. toplam indirim ≤ %30) | Hayır: serbest |

Kod notu: eşik zaten hesaplanıyor (SENTEZ §6.1), rakip durumu yoksa eklenecek (K §4.2). Kural, kart eforunu okuyan yerde tek çarpandır. Hata terimi `0,03 × yeni_efor × e^(−yaş÷3)` (K §6 madde 2): indirimin bu terimi de düşürüp düşürmeyeceği ayrı bir uygulama seçimi; "bilinen yolun daha az hatalı çıkması" hissine uyar, ama hataya ikinci bir ayar katar [GÖRÜŞ]. Çarpan bir oran olduğundan 1 kişide de 50 kişide de kırılmaz.

### 5.1 Soru 10'un yeni yazımı (yardımcı yönetmene, Erdem'e soru sormuyorum)

Durum: rakipler seninle aynı kartları yürütüyor. Stok 6'yı üç şirket yaptı, sen şimdi yapıyorsun.
- **A. Kural yok.** 6. kademe sana da onlara da 20 puan. Geride kalan yalnız daha çok adam ve Ar-Ge ile yetişir. Oyunda değişen: önde başlayan dev uzun süre önde kalabilir; sim'in verdiği biçimde (bicim7) devi geçmek mümkün ama geç. Karar sayısı artmaz.
- **B. Bilinen yol.** Aynı kart sana 16 puan, çünkü iki rakip yapmış. İlk yapan 20'yi öder. Oyunda değişen: geride kalan yetişebilir, öncülük hâlâ pahalı, kartta iki fiyat görürsün. Bekleme stratejisi çıkarsa düşer.
- **C. Ar-Ge düğümü.** 16 puan fiyatı Ar-Ge'de "piyasa bilgisi" düğümünü almana bağlı. Oyunda değişen: bir kez verilen yeni bir karar; almayan tam öder.
Ön hüküm [GÖRÜŞ]: A ile başla, sim G2 düşerse B.

---

## 6. Küçük kararlar (itiraz edilirse değişir)

1. Eşik rakipleri sayar, oyuncuyu saymaz (SENTEZ §6.1 ile aynı); sayma "kendisi hariç" yapılır.
2. Eşik 2 (Erdem'in "en az iki" cümlesi), %20 [WORKING].
3. Yalnız L(m) ve altı kademe indirimlidir; sınırdaki kademe tam bedel.
4. İndirim Ar-Ge efor düğümleriyle çarpılır; bileşik tavan sim 7 numaralı soruya bağlı.

---

## 7. Boşluklar ve açılmayanlar

- Mansfield ve ark. (1981) birincil metni ve özeti; "%65 / %70" rakamı; Mansfield (1985) sızma süresi: açılmadı [BOŞLUK].
- Lieberman ve Montgomery (1988) Wiley sayfası 403, Suarez ve Lanzolla (2005) HBR yalnız giriş paragrafı: içerik UCLA Anderson aktarımından.
- Yazılım/ERP özellik taklit maliyeti, satıcı geliştirme eforunda standart ya da açık kaynak etkisi, öncüye ceza şikâyeti: bulunamadı [BOŞLUK].
- Civ V/VI Fandom (402), Victoria 3 modu yorumu (429), Alpha Centauri, Endless Legend, Stellaris yetişme kuralı: doğrulanamadı ya da aranmadı.
- Oracle HCM 28 Haziran 2023 yalnız arama özeti; Panorama 2023/2024 yüzdeleri devralınan (A1-S35); SAP Joule duyuru ayı yalnız TechTarget aktarımı.
- Sim G2 kolu henüz yok; §5 hedefleri sentezde sayılarla doldurulacak.

---

## Kaynak sicili (erişim tarihi hepsi 2026-10-20)

| S# | URL | Yayıncı | Yayın tarihi | Güven |
|---|---|---|---|---|
| S1 | https://www.capitalismlab.com/digital-age-dlc/technology-research/ | Enlight Software (Capitalism Lab, Digital Age DLC) | belirtilmemiş | Düşük-Orta (satıcı, formül için; kapsam açılamadı) |
| S2 | https://vic3.paradoxwikis.com/Technology | Victoria 3 Wiki (topluluk) | güncel, sürümü belirtilmemiş | Orta |
| S3 | https://www.thegamer.com/victoria-3-technology-tree-eras-best-spread/ | TheGamer, Ryan Thompson-Bamsey | 2022-10-25 | Orta-Düşük |
| S4 | https://eu4.paradoxwikis.com/Technology | Europa Universalis 4 Wiki (topluluk) | güncel (bazı bölümler 1.30/1.31) | Orta |
| S5 | https://civfanatics.com/civ4/strategy/game-mechanics/technology-research-explained/ | CivFanatics (topluluk rehberi) | tarih yok | Orta-Düşük |
| S6 | https://apolyton.net/forum/civilization-iv/civilization-iv-general/153080-the-spread-of-technology-accross-the-lands | Apolyton forumu | tarih sayfada yok | Düşük |
| S7 | https://en.wikipedia.org/wiki/Rubber_band_AI | Wikipedia | güncel | Orta |
| S8 | https://bgdf.com/forum/game-creation/mechanics/catch-mechanics | Board Game Design Forum | 2011-08-16/25 | Düşük |
| S9 | http://www.jstor.org/stable/3172825 (PDF: https://people.duke.edu/~moorman/Marketing-Strategy-Seminar-2015/Session%205/Golder%20and%20Tellis.pdf) | Golder ve Tellis, Journal of Marketing Research 30(2):158-170 | 1993-05 | Yüksek (hakemli, birincil metin okundu) |
| S10 | https://anderson-review.ucla.edu/how-first-mover-advantage-once-unquestioned-lost-its-grip-on-entrepreneurs-and-business-researchers/ | UCLA Anderson Review (Lieberman 1988, Suarez-Lanzolla 2005/2007, Gomez-Lanzolla-Maicas 2016 aktarımı) | tarih alınmadı | Orta (ikincil) |
| S11 | https://hbr.org/2005/04/the-half-truth-of-first-mover-advantage | Harvard Business Review, Suarez ve Lanzolla | 2005-04 | Orta (yalnız giriş paragrafı açıldı) |
| S12 | https://ideas.repec.org/a/ecj/econjl/v91y1981i364p907-18.html | Mansfield, Schwartz, Wagner, Economic Journal 91(364):907-918 (RePEc künyesi) | 1981-12 | Yüksek (künye), içerik açılamadı |
| S13 | https://fecem.unizar.es/sites/fecem/files/archivos/repec/pdf/DT2011-03.pdf | Giménez, Universidad de Zaragoza, DT Econ. Z. 2011-03 | 2011 | Orta (ikincil aktarım; 0,4-0,9, 10 ay-2 yıl, %60/4 yıl) |
| S14 | https://ideas.repec.org/a/bla/jindec/v34y1985i2p217-23.html | Mansfield, Journal of Industrial Economics 34(2):217-223 (RePEc künyesi) | 1985 | Yüksek (künye), içerik açılamadı |
| S15 | https://en.wikipedia.org/wiki/Absorptive_capacity | Wikipedia (Cohen ve Levinthal 1990, ASQ 35(1):128-152 özeti) | güncel | Orta |
| S16 | https://www.panorama-consulting.com/wp-content/uploads/2016/07/2015-ERP-Report-3.pdf | Panorama Consulting Solutions + Mint Jutras, 2015 ERP Report (562 yanıt) | 2015 | Orta (danışmanlık, seçilim yanlılığı olası; PDF yerelde okundu) |
| S17 | https://blogs.microsoft.com/blog/2023/03/06/introducing-microsoft-dynamics-365-copilot/ | Microsoft | 2023-03-06 | Orta (satıcı duyurusu, yalnız tarih için) |
| S18 | https://www.techtarget.com/searcherp/podcast/Oracle-Salesforce-SAP-go-big-into-generative-AI-products | TechTarget (Eylül 2023 olayları; sayfada kesin tarih yok) | 2023-09 (içerikten) | Orta |
| S19 | https://seekingalpha.com/pr/19382419-oracle-introduces-generative-ai-capabilities-to-help-hr-boost-productivity | Oracle basın bülteni (arama özeti, açılmadı): HCM üretken YZ 28 Haziran 2023 | 2023-06-28 | Düşük (açılmadı) |
| S20 | https://en.wikipedia.org/wiki/SAP_Business_ByDesign | Wikipedia | güncel | Orta |
| S21 | https://en.wikipedia.org/wiki/ERPNext | Wikipedia | güncel | Orta (kendi bakım etiketi var) |
| S22 | https://en.wikipedia.org/wiki/First-mover_advantage | Wikipedia | güncel | Düşük (etiketli, sayı yok; kullanılmadı) |
| S23 | https://en.wikipedia.org/wiki/Civilization_VI | Wikipedia | güncel | Orta (Eureka için yalnız kavram, sayı yok) |
| S24 | https://steamcommunity.com/app/281990/discussions/0/7056649947873029973 ve .../4357871761804585109 | Steam Topluluğu, Stellaris | 2024-03-14, 2024-04-26 | Düşük (açıldı, yetişme kuralıyla ilgisiz; kanıt sayılmadı) |
| D1 | docs/tasks/faz_cde/pazar2/out/ A1, B1, B2, V_dogrulama, SENTEZ_ERP_PAZARI, K_kod_haritasi (devralınan) | iç | 2026-10-20 | iç belge; dış iddialar kendi sicillerindeki güvene bağlı |
