# B1. Oyunlarda rakiplerin oyuncuyla AYNI kurallarla çalışan şirketler olarak simüle edilmesi

Hazırlayan: araştırma ajanı (B1), 2026-10-20. WebSearch: 18 (biri alan adı engeli yüzünden hata verdi, yine de sayıldı; bütçe bitti). WebFetch serbest, yaklaşık 45 sayfa denendi. Oyun koduna ve repoya yazılmadı; yalnız bu dosya yazıldı.

Etiketler: [S#] kaynak sicilindeki kaynak. (varsayım) kanıtsız ama makul. [BOŞLUK] bulunamadı. [SIÇRAMA] kanıttan çıkmayan sonuç. [DEĞERLENDİREMEM] bilmediğim yer. [GÖRÜŞ] benim yargım.

Önceki araştırma (R2, "Pazar merdiveni") altı oyunu zaten "rakip oyuncunun payını nasıl değiştiriyor" sorusuyla taramıştı. Bu rapor onu tekrarlamaz; soruyu değiştirir: rakip, oyuncuyla AYNI kurallara tabi bir ŞİRKET mi, yoksa senaryo mu? Büyüklüğü, ekibi, bütçesi gelişimini nasıl belirliyor? Oyuncu neyi nereden görüyor? Dev rakibi geçmek ne kadar sürüyor? Bedeli ne? Yeni olarak Football Manager ve Big Ambitions eklendi; Software Inc., Capitalism Lab, Motorsport Manager, Offworld, Startup Company ve Mad Games Tycoon 2 yeni kaynaklarla derinleştirildi. R2'den yalnız iki kaynak (rubber band yazıları, MM sıralama başlığı) aktarıldı ve işaretli.

Önemli sınır: arama motoru oyun mekaniğinde zayıf. En iyi kanıt Steam tartışma sayfalarını doğrudan açmaktan ve geliştirici satırlarından geldi. Reddit'e erişim yok. Hiçbir oyunun rakip yapay zekâ kaynak koduna ya da tasarım belgesine ulaşılamadı; "aynı kurallar" sorusunun cevabı çoğunlukla geliştirici beyanı ya da oyuncu gözlemi düzeyinde.

---

## 0. Kısa hüküm

1. İncelenen sekiz oyunun HİÇBİRİNDE "rakip, oyuncunun kullandığı aynı arayüz komutlarını aynı kurallarla çalıştırıyor" diye doğrulanmış bir kaynak bulunamadı. En yakın kanıtlar üç tane ve üçü de kısmi: Motorsport Manager'ın geliştiricisi güvenilirlik düşüşünün "AI takımlarında da oyuncuda da" olduğunu yazdı [S16]; Football Manager'da küçük kulübe para tek başına yetmiyor, hem oyun içi hem editör itibar eşiğine bağlı [S11]; Offworld'de AI'nin taramalarınızı göremediği geliştirici ağzından geliyor [S20]. Kalan her yerde ya hiçbir şey söylenmiyor ya da AI açıkça farklı kurala tabi [S24]. [BOŞLUK]
2. Rakibi "oyuncuyla aynı şirket" yapmak en çok iki yerde çökmüş: Startup Company'de dinamik rakipler 10 milyar+ kullanıcıya ve negatif kullanıcıya gitti, geliştirici onları donmuş bıraktı [S22]; Motorsport Manager'da AI kendi bütçesini yönetemedi, pahalı sürücü tutan takımlar parça geliştiremedi [S17]. Ders: "aynı kurallar" tek başına yetmez; rakibin KARARLARI da makul olmalı, yoksa kural aynı, sonuç saçma çıkar.
3. Tersi de başarısız: rakip senaryolu, pasif ya da dekorsa oyuncu geç oyunda tavana varıyor. Software Inc.: "rakipler orada durup bir şeyler yapıyor, sonra istediğini satın alıyorsun" [S27]; Big Ambitions: zor kipte bile rakipler "tehdit değil", oyun "strateji değil kum havuzu" [S6]; Mad Games Tycoon 2: varsayılan rakip etkisi hissedilmiyordu, geliştirici "tough" ayarı ekledi [S32].
4. Oyuncunun rakibe karşı "hile" şüphesi hem gizli avantaj hem de açıklanamayan sonuçtan doğuyor: Big Ambitions'ta rakip mağaza oyuncunun benzerinden 7 kat kâr etti, geliştirici "olmamalı" dedi ve "büyük bir etken" buldu [S5]; Football Manager'da bir oyuncu sonuçların önceden yazıldığını iddia etti, geliştirici yalanladı, ama oyuncu inanmadı [S10]. Ders: rakibin davranışının NEDENİ görünür olmalı.
5. Dev rakibi geçmek "ayar"la ölçülüyor, tek sayıyla değil. Capitalism Lab'de "AI Tech Head Start" ve "AI Expertise" oyuncunun baştan seçtiği düğmeler [S1]; MM'de bir oyuncunun kariyerinde podyum 7 sezon aldı [S18]. FM'de küçük kulübe para tek başına yetmiyor çünkü itibar eşiği var [S11].
6. Başarım maliyeti için tek sert sayı yok. FM'de topluluk "yüklü lig ve oyuncu sayısı hız belirler" diyor, resmî açıklama yok [S12][S13]. Capitalism Lab, MGT2 için üst sınırlar (68 ve 100 rakip) var, hız ölçümü yok [S1][S33]. [BOŞLUK]
7. Liderlik bilgisi oyunlarda üç yoldan veriliyor: tablo/sıralama (FM, MM), rakip hisse/değerleme (Software Inc., BA, Offworld), ya da hiç (BA'da rakip değeri yalnız satın alma anında görünüyor [S4]). Capitalism Lab bunu bir ayar yapmış: "Rakip ticari sırlarını göster: evet/hayır" [S1].

---

## 1. Software Inc. (Coredumping)

Steam'de %94 olumlu / 5.638 İngilizce inceleme; 1 Mayıs 2015, hâlâ erken erişim [S29].

**Aynı kurallar mı, senaryo mu.** AI şirketler gerçek simülasyon (ürün çıkarıyor, hisse alıyor) ama oyuncuyla aynı kurala tabi değil. Geliştirici (11 Oca 2016): AI şirketler hisseyi sermaye ya da büyüme için kullanmaz, "yalnız iflastan kurtulmak için" kullanır; bir şirkette çok hissesi olan şirket onu satın almaya çalışır [S24]. Aynı yazıda: "oyun yalnız 'başarılı' şirketleri simüle ediyor", yani AI şirketler normalde parasız kalmıyor [S24]. [V uyarı: bu 2016 alfa dönemi söylemi, oyun 2025'te hâlâ yama alıyor; kural bugün aynı olmayabilir] Bu açık bir tasarım kararı: rakipler kendi sermaye kuralına sahip, oyuncu kuralına değil.

**Büyüklük, ekip, bütçe nasıl belirleniyor.** Bulunamadı: AI'nin çalışan sayısı, maaş, Ar-Ge bütçesi [BOŞLUK]. Mağaza sayfası rakipten "yetenekli tasarımcı çalmayı" söylüyor, yani rakibin çalışanı var [S29]. Piyasa rastgele dolduruluyor ("simulated and randomly populated"; satıcı sayfası, Düşük) [S31]. Oyuncular AI yayıncıların ürünü zararına sattığını, milyonluk pazarlama yapıp altı haneli gelir elde ettiğini yazıyor [S28]; bu oyuncu gözlemi, "AI akıllı bütçe yönetiyor" demek için kanıt değil.

**Oyuncu rakibi nereden görüyor.** 1.8.31 (20 Kas 2025) ile ürün kalite/yaratıcılık etiketlerinin yerine "dinamik müşteri yorum sistemi" geldi [S30]. Bir oyuncu özellik seçiminde "İnovasyon" göstergesinin rakiplerin o özelliği zaten sunup sunmadığını gösterdiğini yazıyor ve %100 "ilgi"ye ulaşmanın yettiğini söylüyor [S26]. Bu, "sektör standardı oyuncuya özellik seviyesinde gösterilir" fikrine en yakın emsal; ancak tek oyuncu anlatımı, resmî belge değil.

**Dev rakibi geçmek ne kadar sürüyor.** Kısa. Bir oyuncu 2013'te yaklaşık 70 milyon dolardaydı ve "küçük, kötü satan şirketleri satın almaktan sıkıldım"; 2020'de 300 milyon dolar hisse değeri ve "kimse kalmadı" yazdı (alfa sürümü, 2015 tartışması) [S25]. Başka bir oyuncu 2023'te en zor kipte bile geç oyunun kolay olduğunu, rakiplerin değerinin, ürün çıkışının, hayran sayısının ve satın almalarının tavanlı göründüğünü yazdı; yanıtlayan "sonunda rakipleri aşıyorsun, istediğin şirketi alabiliyorsun" dedi, geliştirici yanıtı yok [S27].

**Başarısızlık.**
- Rakipler pasif ("kinda just stay there and make some software") [S27].
- Pazar kuruyor: bir oyuncu 2009 oyun yılında "5 şirket kaldık", rakiplerin değeri 100 bin doların altında [S25]. Yeni AI şirketlerin türetilip türetilmediği tartışmada "evet, 1980'lerde başladılar" cevabıyla belirsiz kaldı [S25].
- Kalite/fiyat etkisiz: bir oyuncu (27 Tem 2016) daha ucuz, daha kaliteli ürününü AI'nin geçtiğini, "fiyat ve kalite birim sayısını pek değiştirmiyor" olduğunu yazdı; tek kayıt dosyasından, geliştirici yanıtı yok [S26].
- Ekonomi kolay: AI yayıncının zararına satışı oyuncunun gelirini şişiriyor, 2021'de "oyunda başarısız olamazsın" [S28].

**Başarım maliyeti.** Bulunamadı [BOŞLUK].
**Liderlik bilgisi.** Rakip hisse fiyatı ve satın alma teklifi üzerinden; "ben liderim" mesajı ayrıca yok (bulunamadı) [BOŞLUK].

**Oyuna ders.**
1. Rakip şirketlerin kendi sermaye ve büyüme kuralı olabilir, ama oyuncu o kuralı görebilmeli; Software Inc.'te "AI neden böyle" cevabı yok, şüphe doğuyor [S26][S28]. Karar: oyuncu her yenilemede/teklifte "rakip neden kazandı" cevabını arar; sıklık: her kaybedilen büyük hesapta bir kez.
2. "Yalnız başarılı şirketler simüle edilir" [S24] pazar kurutuyor [S25]. Bizde rakip listesi sabit değil, giriş ve çıkış (yeni kurulan, iflas eden, satın alınan) olmalı; yoksa 2020'de "kimse kalmadı". Karar sıklığı: yılda 1–2 yeni rakip girişi/çıkışı haberi.
3. Rakibin tavanı ve pasifliği aynı hatadan doğuyor: sınırsız büyümeyi engellemek için tavan koymak rakibi dondurur [S27]. Bkz. Startup Company.

---

## 2. Capitalism Lab / Capitalism II (Enlight, Trevor Chan)

Capitalism Lab, Capitalism II'nin genişletilmiş sürümü, 14 Aralık 2012 [S36]. Steam'de değil, kendi sitesinde satılıyor (arama özeti); inceleme sayımı yok.

**Aynı kurallar mı, senaryo mu.** Resmî betik sayfası AI'nin oyuncuyla aynı kurallara tabi olup olmadığını söylemiyor [S1]. [BOŞLUK] Ama oyunun yapısı "rakip bir şirket": AI şirketlerin işletme odağı var (çeşitlendirilmiş, perakende, hisse, emlak, teknoloji, medya, bankacılık, sigorta), emlak odaklı AI şirketler yalnız başlangıç sermayesi "Yüksek/Çok Yüksek" iken çıkıyor çünkü "var olmak için sermaye gerekir" [S1][S3]. Yani rakibin türü, sermayesine bağlı: bütçe rakibin kimliğini belirliyor.

**Büyüklük, ekip, bütçe nasıl belirleniyor.** Oyuncu baştan düğmelerle seçiyor [S1]: rakip sayısı (0–68), başlangıç sermayesi (Çok Düşük … Devasa, 6 basamak), genişleme ve fiyatlama agresifliği, "AI uzmanlık seviyesi" (Yok/Düşük/Orta/Yüksek), "AI Teknoloji Önceliği" (aynı 4 basamak), yerel rakiplerin yetkinliği, "AI strateji değiştirebilir" (sürüm 12+), "AI dostane birleşme", "rakip ticari sırlarını göster". Sayfa seviyelerin sayısal karşılığını vermiyor [S1]. Aynı sayfa (başka bir arama özeti) 1–65 yazıyordu; açılan sayfa 0–68 diyor; sürüm farkı (varsayım).

**Oyuncu rakibi nereden görüyor.** "Rakip ticari sırlarını göster" bir ayar [S1]. Yani bilgi seviyesi oyuncunun kararı, zorluk düğmesi ile birlikte.

**Dev rakibi geçmek ne kadar sürüyor.** İki araç var. (a) "AI Tech Head Start": rakibe baştan teknoloji öncülüğü verilir [S1]. (b) Digital Age DLC'de GEÇ GİRENE bir yetişme kuralı: bir rakibin teknoloji seviyesi 100'ü aşmışsa ve sizinki belirgin düşükse, Ar-Ge kazancı artar. Formül: Ek kazanım = Temel kazanım × (En yüksek seviye − Sizin seviyeniz) ÷ En yüksek seviye. Örnek: sizin 50, en yüksek 500, temel kazanım 30 → ek 27, toplam 57 [S2]. Bu, dev rakibi geçmeyi bir kurala bağlı yapıyor (formülün rakiplere de uygulandığı kaynakta YAZMIYOR; sayfa yalnız oyuncu tarafı yetişme çarpanını anlatıyor [V düzeltme]) ama "kopyalama" ya da "rubber band" ile sınırı kolay bulanıyor [GÖRÜŞ].

**Küçük/büyük ölçek.** Rakip sayısı arttıkça "daha yoğun rekabet, daha çok birleşme ve satın alma fırsatı" [S3]. Sayısal ölçek kanıtı yok [BOŞLUK].

**Başarısızlık.** Bu oturumda Capitalism Lab'e özgü olumsuz oyuncu yorumu bulunamadı (satış Steam dışında; arama spam siteleri döndürdü) [BOŞLUK]. R2'de bulunan "yüksek teknolojide Ar-Ge kaliteye etki etmiyordu" ve "zorluk dışarıdan ayarla geliyor" notları geçerli, burada tekrarlanmıyor.

**Başarım maliyeti.** Bulunamadı (arama "yavaşlama" sonucu getirmedi) [BOŞLUK].

**Oyuna ders.**
1. Rakibin gücünü oyuncu açık düğmelerle seçiyor ve düğmeler SAYISAL KARŞILIĞI olmayan basamaklar ("Orta") [S1]. Bizde "rakip sert" seçeneği varsa basamağın ne demek olduğu ekranda yazılmalı (başlangıç sermayesi, kaç kişi, hangi yıl). Karar: oyun başında bir kez.
2. Yetişme formülü [S2] tek satır; "öndekiyle aranızdaki orana göre" büyüyen bir kural, oyuncunun hızına bakmıyor. Bizde bu "sektör bilgisi yayılır" olarak her şirkete (rakiplere de) aynı uygulanabilir (GÖRÜŞ) [V uyarı: Capitalism Lab'in rakiplere de uyguladığına dair kanıt yok]. Dikkat: Erdem'in "kopyalama yok" kararına sınırda; bkz. §10.
3. Rakibin kimliği bütçeye bağlı (emlak AI yalnız yüksek sermayede çıkıyor) [S3]. Bizde "dev rakip" = yüksek başlangıç sermayesi + yüksek ekip, özel kod değil (GÖRÜŞ).

---

## 3. Mad Games Tycoon 2 (Eggcode Games)

Steam'de %93 olumlu / 2.229 İngilizce inceleme; erken erişim 21 Ocak 2021, çıkış 31 Mayıs 2023 [S33]. Mağaza metni: "100'e kadar rakip şirket", satın alıp yönetebilir ya da IP'lerini alarak kapatabilirsiniz; rakiplerden oyun motoru lisanslayabilirsiniz (satıcı sayfası, Düşük) [S33].

**Aynı kurallar mı, senaryo mu.** Bulunamadı; geliştirici yazısı yok [BOŞLUK]. Geliştirici (Panda, 1 Haz 2023) tek bir şey söyledi: rekabet güncellemesinden sonra "tough" ayarına alırsanız rakip oyunların daha etkili sonuçlarını görmelisiniz [S32]. Bunu tetikleyen oyuncu (21 May 2023): "oyunlarda normal rakiplerle çok fark hissetmedim" [S32]. Yani varsayılan rekabetin etkisi zayıftı; geliştirici etkiyi ayara bağlayarak büyüttü.

**Büyüklük, ekip, bütçe.** Bulunamadı [BOŞLUK]. **Rakibi görme.** Bulunamadı. **Dev rakibi geçme.** Bulunamadı. **Başarım maliyeti.** Bulunamadı. Bu oyunda aranan her soru için geliştirici açıklaması yok; yalnız ayar ve oyuncu izlenimi [S32].

**Başarısızlık.** "Rekabet" varsayılan hâlde hissedilmiyor; sonradan ayar olarak getirildi [S32]. R2'deki oyuncu notları (rakip konsollar oyuncunun kullanıcısını çalmıyor) bu oturumda yeniden açılmadı, tekrarlanmıyor.

**Oyuna ders.**
1. Varsayılan etki zayıfsa geliştirici sonradan ayar ekliyor [S32]. Bizde rakip etkisi baştan hissedilir olmalı; yenilemede/teklifte görünür.
2. Karar sıklığı: oyuncu her yeni satış görüşmesinde rakibi tek satırda görüyor mu? (GÖRÜŞ) Bu oyun bize bunun gerekliliğini gösteriyor, yöntemini değil.

---

## 4. Big Ambitions (Hovgaard Games)

Steam: çıkış 28 Ağustos 2026 (erken erişim 10 Mart 2023); %91 olumlu / 6.254 İngilizce inceleme [S7]. Mağaza sayfası rakipleri anlatmıyor [S7].

**Aynı kurallar mı, senaryo mu.** KISMEN SENARYO. Rakip, oyuncunun genişlemesine bağlı tetikleniyor: bir sektörün büyük rakibi, o sektörde üç ya da daha fazla mağaza açınca aktif oluyor; üç taktiği var: fiyat kırma, çalışan çalma (daha yüksek maaşla), yakına mağaza açma [S4]. Ders: "rakip" burada kendi başına yürüyen bir şirket değil, oyuncunun büyümesine tepki veren bir mekanik [S4] (rubber band'e yakın; yazar bunu açıkça söylemiyor, (varsayım)). Küçük rakipler oyuncunun ve özel rakiplerin fiyatlarına tepki veriyor; geliştirici: oyuncu fiyatı düşük tuttuğu için küçük rakip onu taklit ediyor [S5].

**Büyüklük, ekip, bütçe nasıl belirleniyor.** Geliştirici (4 Tem 2024): rakip mağazalar oyuncununkinden "biraz daha optimize" olabilir ama oyuncu 7 kat fark beklememeli; değerleme varlık + son haftaların kâr tahmini [S5]. Bir oyuncu rakip mağazanın haftada ~951 bin dolar kazandığını, kendi benzer mağazasının 145 bin kazandığını yazdı [S5]. 11 Tem: ekip "büyük bir etken" buldu ve EA 0.6'da ayarlayacak [S5]. Aynı sayfada bir oyuncu (12 Tem): devralınan rakip mağazalar çalışan ve ekipman şartlarını karşılamadığı hâlde yüksek kâr ediyor; "rakipler oyuncuyla aynı şartlara ve sonuçlara tabi olmalı" [S5].

**Oyuncu rakibi nereden görüyor.** Rakip değerlemesi kâr düşünce düşüyor ve satın alma fırsatı doğuyor [S4]. Rakip için ayrı arayüz anlatılmıyor [S4]. Fiyat geri yükselince rakip de hafifçe yükseliyor ama altında kalıyor (oyuncu gözlemi) [S5]; fiyatlar her gece gece yarısı ayarlanıyor [S5].

**Dev rakibi geçmek ne kadar sürüyor.** Bir oyuncu 200+ gün ve 40+ işletmede dört rakibin "50. günden beri savaş ilan ettiğini", rakipleri tutmanın sorun olmadığını yazdı; bir diğeri zor kipte bile rakiplerin "tehdit etmediğini" ve oyunun "strateji değil kum havuzu" olduğunu söyledi [S6]. Oyuncu rakibi iflasa sürükleme taktiğini (boşalttıkları binaları kiralamak, yeni işletme açmak) birkaç saat sonra sıkıcı buldu [S6].

**Başarım maliyeti.** Bulunamadı [BOŞLUK].
**Liderlik bilgisi.** Oyuncuya "lider" bilgisi verildiğine dair kayıt yok; rakip değerlemesi satın alma bağlamında görülüyor [S4]. [BOŞLUK]

**Başarısızlık.** Üç ayrı biçim: (1) rakip haksız kârlı [S5], (2) rakip şartlara tabi değil [S5], (3) rakip geç oyunda önemsiz ve yinelenen iş [S6]. Oyun yine de %91 olumlu [S7]; rakip sorunu oyunu batırmıyor ama geç oyun şikâyetinin parçası.

**Oyuna ders.**
1. Rakibi oyuncunun büyümesine "tetiklemek" gerçek rekabet yaratmıyor: oyuncu "üç mağazadan fazlasını açmam" taktiği kuruyor [S4]. Bizde rakip oyuncunun hareketinden bağımsız yürümeli (Erdem kararı 2 ile uyumlu).
2. Rakip oyuncudan kolay para kazanıyorsa oyuncu bunu "hile" okuyor ve geliştirici bunu bir hata kabul ediyor [S5]. Bizde rakibin geliri ve maliyeti oyuncununkiyle AYNI hesaptan çıkmalı (kuralın kendisi: gider/gelir). Karar: oyuncu haftalık raporda rakibin sürümünü görürse kendi kararını (hız, destek) buna göre yapar; sıklık: her sürüm.
3. Rakipten satın alma/devralma, rakip ancak zayıfken makul [S4]. Bizde "zayıf düşen rakibi satın alma" Erdem'in kapsamında değil; (GÖRÜŞ) not olarak burada.

---

## 5. Football Manager (Sports Interactive)

Kaynakların çoğu topluluk; resmî makale pazarlama dilinde (Düşük) [S8].

**Aynı kurallar mı, senaryo mu.** Karışık, doğrulanamaz. Resmî FM24 yazısı (19 Eyl 2023): "AI yöneticilerin karar ve kadro seçimi yeteneklerini önemli ölçüde geliştirdik"; AI yöneticiler transferde form ve itibara daha çok bakıyor, taktik tarzlarına göre kadrodaki boşluğu dolduruyor, yedek oyuncuda mevcut yetenekten çok potansiyele bakıyor [S8]. Aynı yazıda bütçe kuralları (kırmızıya düşen kulüp mesaj alır, yönetim bütçeyi devralır, FFP yaptırımı) oyuncu cümleleriyle anlatılıyor; AI kulüplerin de aynı kurala tabi olduğu yazıda geçmiyor [S8]. [BOŞLUK] Topluluk deneyi (arama özeti, açılmadı): FM26'da AI transferleri pozisyon önceliği, kadro rol boşluğu, itibar eşiği ve uzun vadeli plana bağlı kalıplar izliyor, biraz rastgelelik var [S14].

**Büyüklük, ekip, bütçe nasıl belirleniyor.** İTİBAR. Bir blog yazarı (7 Ara 2024): itibar sistemi AI'nin kulüpleri yönetmesini güçlü etkiliyor; küçük kulübe para yığmak "çoğunlukla hiçbir sonuç vermiyor"; oyun editörü, bir takıma büyük para eklemek için önce itibarı yükseltmenizi şart koşuyor; mantık: ani bir para girişi medya ilgisi çeker, yani itibar da yükselmeli [S11]. Yazar mekaniğin tam işleyişini bilmediğini söylüyor [S11]. Bir FM Scout konusunda bir oyuncu 9. ligden Premier Lig'e çıkardığı kulübe, itibar çoğu ikinci lig takımının altında kaldığı için oyuncuların hâlâ gelmediğini bildirdi (arama özeti, açılmadı) [S43]. İtibar, "kulüp büyüklüğünü" tek sayıya indiriyor ve hem oyuncu hem AI için bir sınır.

**Veri ölçeği.** FM 2006'nın Xbox 360 sürümü 250 bin oyunculuk bir veri tabanı ve 50 lig sistemi taşıyordu [S15]. Veri tabanı çoğunlukla gönüllü araştırmacılarla kuruluyor [S15].

**Oyuncu rakibi nereden görüyor.** Lig tabloları, maç sonuçları, transfer haberleri (varsayım; bu oturumda kaynaklanmadı) [BOŞLUK]. AI yöneticinin oyuncuya tepkisi itibar, lig sırası ve forma göre: "beklentinin üstünde oynayan takıma rakipler daha temkinli oynar"; geliştirici Neil Brock: "AI taktikleri çözmez" [S9]. Match odds, AI'nin sizi nasıl gördüğünün göstergesi olarak anılıyor [S9].

**Dev rakibi geçmek ne kadar sürüyor.** Tek sayı yok. Bir FM2024 oyuncusu "AI yeterince akıllı olmadığı için birkaç sezonda ligi domine edebilirsiniz" yazdı (tek görüş, arama özeti, Düşük) [S41]. Yeni çıkan kulübün tutunmasında zorlanması anılıyor (arama özeti) [S44]. İtibar kulüp sonuçlarının gerisinde kalıyor: küçük kulüp başarıya ulaşsa da oyuncu transferi hâlâ reddedebiliyor [S43]. Kesin süre: bulunamadı [BOŞLUK].

**Başarım maliyeti.** Resmî açıklama yok. Topluluk: yüklü oyuncu sayısı hızı lig sayısından fazla etkiler (bir FM Scout kullanıcısı ~75 bin oyuncu ve hızlı ilerleme bildirdi); seçilmemiş liglerin maçlarının da gün ilerlerken işlendiği bir Steam kullanıcısınca gözlendi ve "Lig Ekle/Kaldır" ile kapatma önerildi [S12][S13] (arama özetleri, açılmadı, Düşük). Bu, oyunun yükü "ne kadar şirket yüklü" ile ölçeklediğini gösteriyor ama resmî sayı yok.

**Liderlik bilgisi.** Lig sıralaması her zaman görünür (varsayım, kaynaklanmadı) [BOŞLUK].

**Başarısızlık.** Eskiden beri "oyun hile yapıyor" şikâyeti. 2017'de bir oyuncu sonuçların sezon başında yazıldığını, yeni transferlerin hemen yeteneğini kaybedip AI takımlarının etkilenmediğini iddia etti; geliştirici Neil Brock (5 Haz 2017): sonuçlar önceden belirlenmiyor, maç motoru oyuncu seçimi, taktik, hatta hava gibi birçok etkeni tartıyor; bir kullanıcı "kaydet, yılı atla, birkaç kez yükle" testini önerdi [S10]. 2016'da başka bir oyuncu AI'nin itibar yükseldikçe "canavarlaştığını" yazdı (arama özeti) [S42]; FM Scout makalesi (Stam, 12 Eyl 2018) bunu "AI taktiği çözmüyor, itibarınıza göre ayarlanıyor" diye açıklıyor [S9]. Dolayısıyla "AI sizin durumunuza göre ayarlanıyor" algısı yaygın ve geliştirici bunu bile kısmen doğruluyor (itibara göre tutum) [S9].

**Oyuna ders.**
1. Rakibin büyüklüğü TEK sayıda (itibar) toplanabilir ve bu hem rakibin neye gücü yettiğini hem oyuncunun neyi çekebileceğini sınırlar [S11]. Bizde şirketin "ağırlığı" (MRR, müşteri sayısı, çıkarılmış sürüm listesi) tek bir "saygınlık" bileşenine bağlanabilir (GÖRÜŞ). Karar: oyuncu hangi hesabın kendi büyüklüğüne açık olduğunu bir bakışta görür; sıklık: her yeni satış görüşmesi.
2. Para tek başına büyüklük satın almıyor [S11]. Bizde "dev rakip" kasa ile değil geçmişle (yıllar, sürüm sayısı, müşteri) büyür; oyuncu parası olunca da hemen dev olamaz. Bu Erdem'in "dev rakip yüksek başlar ve geçmesi uzun sürer" kararına uyuyor.
3. Oyuncu rakibin "durumuna tepki verdiğini" hile olarak okuyor [S10][S42]. Bizde rakibin tepkisi (fiyat indirimi, aynı müşteriye teklif) hep NEDENİ ile gösterilmeli: "X sizin müşterinize teklif verdi çünkü sözleşmesi bitiyor".
4. Yükleme ölçeği: FM yüklü varlık sayısını oyuncuya bıraktı [S12]. Bizde rakip sayısı ve ayrıntı düzeyi sabit olsun (aşağıda §9).

---

## 6. Motorsport Manager (Playsport Games)

Masaüstü sürümü Kasım 2016'da Sega tarafından yayımlandı [S40]. Eski mobil sürümler 2014'ten beri var [S40]. Bu başlık için tüm kanıt oyuncu forumları ve tek bir geliştirici satırı; AI mekanik belgesi yok.

**Aynı kurallar mı, senaryo mu.** KISMEN AYNI: geliştirici (10 Kas 2016): parçaların güvenilirliği sezon başında düşüyor ve "bunların hepsi AI takımlarında da oyuncuda da oluyor"; parçalar yeni sezona performans değerleriyle taşınıyor, oyuncu "gridin geri kalanına göre performans kaybı görmemeli" [S16]. Yani sezon sıfırlama kuralı tüm takımlara. Ama AI'nin parça geliştirmesi oyuncuyla aynı kural mı: yazılmamış [S16]. [BOŞLUK] Topluluk modunun değişiklik listesi (arama özeti, Düşük): AI'nin "aynı parçadan çok sayıda yapıp çok para harcadığı" bir hata düzeltilmiş, AI'nin parça yapma biçimi yeniden yazılmış [S39].

**Büyüklük, ekip, bütçe nasıl belirliyor.** BÜTÇE rakibin gelişimini sınırlıyor. 2017 başlığı: iki sürücüye yarışta bir milyon ve üstü ödeyen AI takımları "parça geliştirmeye hiç gücü yetmeyecek" gibi görünüyor; yanıtlar: "AI vanilya oyunda finansını yönetmekte beceriksiz" (Coal!); sürücü maaşı her takım değiştirmede artıyor (Fritz); pazarlanabilirlik de önemli (tullaian); geliştirici yanıtı yok [S17]. Bir oyuncu "AI'nin kırmızıya düşen takımlara indirim" gibi basit çözümün sorunu çözmediğini yazdı: takımlar zaten kırmızıdaydı [S17]. Not: bu oyunda AI'nin kendi bütçesi, kendi gelişimini doğrudan bozuyor; yani "aynı kurallar" gerçek sonuç doğurdu ama AI kuralı akıllıca kullanamadı.

**Oyuncu rakibi nereden görüyor.** Sıralama; R2'de bulunan notla sıralama farkın büyüklüğünü gizliyor ("yükseltmen +20 veriyor ama 9.'nun 100 gerisindeysen 10. kalıyorsun") [S38] (R2'den aktarıldı, bu oturumda yeniden açılmadı).

**Dev rakibi geçmek ne kadar sürüyor.** Oyuncu forumu (29–30 Haz 2017): ilk sezonda orta sıra normal; "orta sınıf araba birkaç sezon" alır; bir oyuncunun önceki kariyerinde podyum yarışabilecek araba 7 sezon sürdü; "kısa vadeli düşünüyorsun" (B✪✪tsy) [S18]. En iyi iki parçanın bir sonraki sezona taşınması, güvenilirliğin ~%40'a düşmesi ve parçaların farkın ~%80'ini oluşturması da oyuncu raporu [S18] (resmî değil).

**Başarım maliyeti.** Bulunamadı [BOŞLUK].
**Liderlik bilgisi.** Sıralama var; fark görünmüyor [S38].

**Başarısızlık.** (1) AI finansta beceriksiz → rakip gelişemiyor [S17]. (2) Sıralama farkı saklıyor [S38]. (3) AI'nin gelişimi sezon sıfırlamada hissedilmiyor (R2'den, tekrarlanmadı).

**Oyuna ders.**
1. Rakibin gelişimini rakibin bütçesine bağlamak doğru sezgi, ama rakibin HARCAMA KARARLARI test edilmeli: MM'de "pahalı sürücü → parça yok" döngüsü oyunu bozdu [S17]. Bizde rakip "kasa yetiyorsa kart al, yetmiyorsa bekle" kuralından fazlasını yapmamalı (GÖRÜŞ). Karar: yok (oyuncu görmez), ama test (haftalık simülasyon) şart.
2. Gelişim kuralı sezon/yıl sınırında herkese aynı uygulanmalı ve duyurulmalı [S16]. Bizde "yıl kilidi açıldı" (Erdem kararı 6) rakibe de aynı anda açılır; oyuncu bunu haber olarak görür.
3. Sıralama tek başına farkı gizliyor [S38]: puan farkı ya da "kaç sürüm geride" gösterilmeli.

---

## 7. Offworld Trading Company (Mohawk Games)

Steam: %78 olumlu (Karışık/"Mostly Positive") / 2.691 İngilizce inceleme; 28 Nisan 2016; mağaza sayfası tek oyunculu kampanya ve 8 kişiye kadar çok oyunculu anlatıyor, AI sınır modunu anlatmıyor [S21].

**Aynı kurallar mı, senaryo mu.** Aynı kural, bilgi sınırlı. Geliştirici Soren Johnson (18 Oca 2015): AI "taramalarınızı göremez" [S20]. Bir oyuncu (20 Nis 2019) Soren'in konuşmasında AI'nin tek oyunculu oyunda "hologram" kullanmaması için özellikle engellendiğini aktarıyor ("oyuncular şikâyet etmesin diye") ve "AI'ler bu oyunda hile yapmaz" diyor (ikinci elden, doğrulanmadı) [S19]. Bir oyuncu AI'nin patent laboratuvarı olmadan patent aldığını iddia etti; cevaplar: kanıt yok, hologram olabilir, tekrar oynatma dosyası lazım; geliştirici yanıtı yok [S19]. Yani "hile" şüphesi doğdu, çözümü kanıtla bırakıldı.

**Büyüklük, ekip, bütçe.** Her oyuncunun (AI dahil) başlangıcı eşit, hedef rakibin hissesini satın almak (varsayım; R2'den, bu oturumda kaynaklanmadı). Rakip bütçesi/ekibi değil, kaynak ve fiyat piyasası belirliyor (R2'de).

**Oyuncu rakibi nereden görüyor.** Oyuncular rakibin parası ve hisse fiyatı üzerinden tartışıyor [S20]; Soren'in yazılarında bu konu yok [S20]. Yani rakip finansı oyuncunun görebildiği bir bilgi (hisse fiyatı oyunun ana skoru).

**Dev rakibi geçmek ne kadar sürüyor.** Maç kısa (bir oyun yaklaşık yarım saat; (varsayım), bu oturumda kaynaklanmadı) [BOŞLUK]. Oyuncu "kaybetmeye başlayınca oyun senden kaçıyor" (mok, 18 Oca 2015) [S20]: maç içi snowball şikâyeti.

**Başarım maliyeti.** Bulunamadı [BOŞLUK].

**Başarısızlık.** Oyun %78: bu raporda oranı okunan beş oyunun en düşüğü [S21][S7][S23][S29][S33]; ancak puanın nedenini rakip AI'ye bağlayacak kanıt yok [SIÇRAMA uyarısı]. R2'deki "AI'nin göremediğim fırsatları kullandığını düşündüm, oyunu sildim" notu tekrarlanmıyor.

**Oyuna ders.**
1. "AI bilgisi sınırlı" geliştirici ağzından söylenince güven doğuyor [S20]. Bizde rakip oyuncunun iç durumunu (kasa, ekip, hesap listesi) bilmemeli; yalnız oyuncunun görünür bilgisini (yayımlanan sürümler, haberler) görmeli. Oyuncu bunu bir satırda bilmeli ("rakipler gizli bilgi kullanmaz").
2. Kanıt ihtiyacı: hile şüphesi tekrar oynatma dosyasıyla çözülüyor [S19]. Bizde "rakip neden kazandı" cevabı ekranda: yenilemede kaybedilen müşteri için "X'in sürümü şu alanı getirdi".

---

## 8. Startup Company (Hovgaard Games)

Steam: %80 olumlu / 2.898 İngilizce inceleme; 10 Nisan 2020. Mağaza sayfası: devlerle yarışın, çalışanlarınızı "rakipleriniz teklif göndermeden önce" mutlu tutun; rakipleri satın alıp birleştirerek ya da onları geçerek en büyük site olun (satıcı sayfası, Düşük) [S23].

**Aynı kurallar mı, senaryo mu.** SENARYO (donmuş), ama bu bilinçli bir geri çekilme. Geliştirici Jonas (14 Kas 2019): önce hisseler dinamik bir piyasayla geldi; oyuncular daha fazla özellik istedi, sürüm 2 planlandı; kullanıcılar şirketlerin 10 milyar+ kullanıcıya ve bazılarının negatif kullanıcıya ulaştığını bildirdi; "hızlı düzeltme" şirketleri durağan yaptı; Beta 28 için hisse v2 başladı. Ek: hızlı düzeltme yüzünden kayıt dosyasının yaşına göre farklı hisse piyasası davranışı görülüyor [S22]. Başka bir oyuncu (13 Kas 2019) tüm rakip hisselerinin düştüğünü, sonra 0 olduğunu yazdı; bir moderatör rekabetin "şu an durağan: her şirketin fiyatı ve kullanıcıları sabit" olduğunu, Beta 28 ile değişeceğini söyledi [S22]. Bugünkü durum bulunamadı [BOŞLUK].

**Büyüklük, ekip, bütçe.** Bulunamadı; rakip sabit sayı olduğu için bütçe yok [S22].

**Oyuncu rakibi nereden görüyor.** Rakip sekmesi ve hisse alma (R2'den; mağaza sayfası "satın alıp birleştirin" diyor [S23]).

**Dev rakibi geçmek ne kadar sürüyor.** Rakipler sabit olduğu için ölçülemez [S22]. Bir oyuncu teorisi: finiti kullanıcı havuzunda oyuncu büyüdükçe rakip kaybeder ("Bill", 13 Kas 2019) [S22]; geliştirici bunu doğrulamadı.

**Başarım maliyeti.** Bulunamadı [BOŞLUK].

**Başarısızlık.** Rakip simülasyonu sınır koymadan açıldı → saçma sayılar → donduruldu [S22]. İnceleme oranı (%80) bu raporda oranı okunan beş oyunun ikinci en düşüğü; rakibin payı kanıtlanmadı [S23].

**Oyuna ders.**
1. Rakip, kullanıcı/müşteri havuzunu oyuncuyla PAYLAŞIYORSA (finit havuz) toplamlar korunmalı: bir şirkete eklenen müşteri bir yerden gelir. Bizde müşteri havuzu (sektördeki hesap sayısı, koltuk) sabit ve toplam korunur; rakipler ve oyuncu aynı havuzdan çeker (GÖRÜŞ). Aksi hâlde "10 milyar kullanıcı" hatası [S22].
2. Sınırları rakip KARAR kuralına değil MUHASEBEYE koy (müşteri sayısını, kasa=gelir−gider): rakibe "azami büyüklük" koymak dondurur [S22][S27].
3. Karar: yok (oyuncu müdahale etmez); test: 52 haftalık, 20 yıllık simülasyonda hiçbir rakip sayı negatif/sınırsız olmasın.

---

## 9. Çapraz karşılaştırma

| Oyun | Aynı kural kanıtı | Rakip büyüklüğünü belirleyen | Oyuncu ne görüyor | Dev rakibi geçmek | Başarım maliyeti | Lider bilgisi |
|---|---|---|---|---|---|---|
| Software Inc. | Hayır; AI'nin hisse kuralı farklı [S24] | Bilinmiyor; yalnız "başarılı" şirketler [S24] | Yorum sistemi, hisse; "inovasyon" göstergesi (oyuncu) [S30][S26] | Hızlı; 2013'te 70 M$ ve sıkılmış [S25] | Bulunamadı | Hisse değeri [S25] |
| Capitalism Lab | Belirtilmemiş [S1] | Başlangıç sermayesi, uzmanlık, teknoloji önceliği düğmeleri [S1] | "Ticari sırları göster" ayarı [S1] | Yetişme formülü [S2]; öncelik ayarı [S1] | Bulunamadı | Ayar [S1] |
| MGT2 | Bilinmiyor [BOŞLUK] | 100'e kadar şirket [S33] | Bulunamadı | Bulunamadı | Bulunamadı | Bulunamadı |
| Big Ambitions | Kısmen senaryo: 3 mağaza tetikli [S4] | "Biraz optimize", 7 kat fark hata sayıldı [S5] | Rakip değerlemesi (satın alma anında) [S4] | Geç oyunda tehdit değil [S6] | Bulunamadı | Yok [BOŞLUK] |
| Football Manager | İtibar sınırı hem oyuncu hem editör için [S11]; AI bütçe kuralı belirtilmemiş [S8] | İtibar [S11] | Tablo (kaynaksız) | Birkaç sezon (tek görüş) [S41] | Topluluk: yüklü oyuncu sayısı [S12] | Tablo (kaynaksız) |
| Motorsport Manager | Sezon sıfırlama AI'ya da [S16] | Bütçe: pahalı sürücü → parça yok [S17] | Sıralama, fark gizli [S38] | Podyum 7 sezon (tek kariyer) [S18] | Bulunamadı | Sıralama |
| Offworld | AI taramayı göremez [S20]; hile iddiaları kanıtsız [S19] | Eşit başlangıç | Hisse, para (oyuncu tartışması) [S20] | Maç içi snowball [S20] | Bulunamadı | Hisse |
| Startup Company | Hayır; donduruldu [S22] | Sabit sayı [S22] | Rakip sekmesi (R2) | Ölçülemez | Bulunamadı | Hisse |

---

## 10. Bize dersler (Erdem'in 2026-10-20 kararlarına göre)

Karar numaraları görev metnindeki sıra.

**A. "Rakipler bizim gibi şirket, aynı kart ve Ar-Ge listesini kendi büyüklükleriyle yürütür" (karar 2).**
1. Hiçbir oyun bunu birebir yapmıyor [S16][S20][S11 kısmi]; yani bu bizim için ilk. Risk iki yönlü: (a) rakip sınırsız dinamikse sayılar saçmalar [S22]; (b) rakip akılsız harcarsa gelişmez [S17]. Çözüm yönü (GÖRÜŞ): rakibin geliri bizdeki gelir hesabından, gideri bizdeki gider hesabından çıksın; "kart seçme" kuralı küçük ve tek: yeterli kasa varsa sıradaki kartı al, ekibin hızı kadar. Böylece MM'deki "pahalı sürücü" benzeri kendini kilitleme (S17) bizde "ekip maaşı gelirini aşarsa kart alamaz" olur; bu zaten oyuncunun da tabi olduğu kural.
2. Ölçek: 1 kişilik ve 50 kişilik şirket aynı kural. Rakip büyüklüğü sayıdan çok ORAN ile (ekip/gelir), (varsayım). MM'de AI'nin hız/maaş dengesi bozuk [S17]; bu yüzden harcama oranı üst sınır ile: gelirinin belli bir oranı Ar-Ge'ye (örnek oran sayı vermeden: karar tablosunda "Ar-Ge payı" olarak sabit sütun).
3. Karar sıklığı: oyuncu bunu oynanışta "sektör haberi" olarak görür (sürüm çıktı, fiyat değişti): kabaca ayda 1–3 satır.

**B. Dev rakip yüksek başlar, aynı yol haritasını izler, geçmesi uzun sürer (karar 2, 3).**
4. FM'de büyüklük itibar ile ve para tek başına satın almıyor [S11]; Capitalism'de teknoloji önceliği düğmesi var [S1]; MM'de 7 sezon [S18]. Bizde dev = çok müşteri + çok sürüm + büyük ekip + iyi itibar, ama aynı kart listesinden. Geçme süresini kodda ayar, oyuncuya ekranda ise "kaç sürüm geride" olarak gösterilir.
5. Yetişme kuralı (Capitalism, [S2]): "öndekiyle fark büyükse ek kazanım" herkese uygulanırsa, dev rakibi geçmek mümkün ama uzun; ancak bu bir yayılma kuralıdır ve "kopyalama" ile sınırı bulanıktır. Karar Erdem'in: açık sınır koymadan uygulanmamalı. Seçenek A: yetişme kuralı yok, yalnız yüksek başlangıç. Seçenek B: herkes için aynı formül. (GÖRÜŞ: B daha oynanabilir ama kural karmaşık; A'da dev rakibi geçmek hız/verim/satış/destek avantajıyla olur, tam Erdem'in dediği gibi.)

**C. Sektör standardı rakip sürümlerinden doğar (karar 3).**
6. Oyuncuya standart nasıl gösterilir? Emsal: Software Inc.'te "inovasyon" göstergesi rakiplerin bir özelliği zaten sunup sunmadığını söylüyor (oyuncu anlatımı) [S26]. Bizde standart = sektörde en az X rakibin sunduğu alan seviyesi; gösterim: "sektör standardı: Fatura 3, İK 2" tek satır, ürün ekranında. Karar sıklığı: her çeyrek, yılda 1–2 yeni standart.
7. Standart rakip sürümlerinden çıkıyorsa rakip sürüm listesi haber olarak düşer (Software Inc.'te benzeri istenmişti, R2'den). Oyuncu "rakip ne çıkardı" yerine "standart ne oldu" satırı görür; böylece rakip sayısı arttıkça ekran büyümez.

**D. Liderlik bilgisi (karar 2 son cümle).**
8. Üç emsal: tablo (FM), hisse/değerleme (Software Inc., Offworld, BA), ayar (Capitalism: "sırları göster") [S1][S25][S4]. Hiçbiri "ben öndeyim" diye açık bir mesaj vermiyor; oyuncu sıralamadan ve rakamdan çıkarıyor. MM'de sıralama farkı gizlediği için tepki aldı [S38]. Öneri (GÖRÜŞ): tek bir göstergede (örnek: sektörde müşteri payı sıralaması) farkı SAYI ile göster; "lider" etiketi ayrı karar. Oynanışa etkisi: oyuncu geride olduğunu görünce destek/Ar-Ge'ye yatırır; öndeyken risk alma isteği düşebilir (varsayım).
9. Sıklık: ayda bir pazar özeti; her haftada değil.

**E. Başarım maliyeti (görev metni).**
10. Kaynaklı sayı yok; FM topluluğu yüklü varlık sayısının hızı belirlediğini söylüyor [S12]. Bizde (repo kaydı, web kaynağı değil): 330 hesaplı gece tikinin 134,8 ms'ye indiği commit mesajında yazılı (9221d004). Bu bütçeye rakip şirketleri eklerken, her rakibi hesap listesi gibi değil "az sayıda sayı + kart kuyruğu" olarak tutmak maliyeti düşük tutar (GÖRÜŞ). Rakip adedi: adlı 6–12 rakip + toplu "küçük oyuncular" havuzu; emsal: Capitalism 68, MGT2 100 rakibe çıkıyor ama hız ölçümü paylaşmıyor [S1][S33].

**F. Geliştirilmeyen ürünün cezası (karar 8) ve rakip.**
11. En iyi emsal rakibin standardı yükseltmesi: oyuncu ürünü yerinde dursa bile standart onu "eksik" kılar. Bunun oyuncu için görünür olması şartı BA'daki gibi "neden" göstermeye bağlı [S5]. Karar: standart yükselince yenilemede istek (karar 1) olarak gelir; sıklık: müşteri yenilemesi başına en çok bir.

---

## 11. Başarısızlar (ayrı arama ve sayfalarla bulunan)

1. **Pasif rakip → geç oyun kolay.** Software Inc. 2023 [S27], 2015 [S25]; BA 2024 [S6]; MGT2 2023 [S32].
2. **Sınırsız dinamik rakip → saçma sayı → dondurma.** Startup Company 2019 [S22].
3. **Rakibin finans kararı bozuk → gelişemiyor.** MM 2017 [S17].
4. **Rakip haksız kâr ediyor / şartlara tabi değil.** BA 2024 [S5].
5. **Rakip oyuncuya tepki veriyor, hile algısı.** FM 2017 [S10], FM 2016 [S42], Offworld 2019 [S19].
6. **Rakip oyuncunun hareketine bağlı tetikleniyor, oyuncu bunu atlatıyor.** BA (üç mağaza eşiği) [S4].
7. **Fiyat/kalite rakibe karşı işlemiyor.** Software Inc. 2016 [S26].
8. **Fark gizli, sıralama yetmiyor.** MM [S38].
9. **Kanıt sınırı:** Steam olumsuz inceleme sayımı alınamadı; inceleme oranları (mağaza sayfaları, erişim 2026-10-20): Software Inc. %94 (5.638), MGT2 %93 (2.229), BA %91 (6.254), Startup Company %80 (2.898), Offworld %78 (2.691) [S29][S33][S7][S23][S21]. Rakip tek başına oran açıklamıyor.

---

## 12. Boşluklar (dürüstçe)

- "Rakip birebir aynı komutları çalıştırıyor" diyen hiçbir kaynak bulunamadı (sekiz oyun) [BOŞLUK].
- Software Inc., MGT2, Startup Company için rakibin ekip/bütçe/maaş modeli: bulunamadı.
- Big Ambitions rakibinin kurallarının tam açıklaması: geliştirici yalnız "daha optimize" ve "büyük bir etken" diyor [S5].
- FM'de AI kulüplerin finansal kurallara tabi olduğuna dair doğrudan kaynak: bulunamadı [S8]. FM 2006 veri tabanı boyutu dışında güncel sayı yok [S15].
- MM'de AI parça geliştirme kuralı: bulunamadı.
- Başarım maliyeti sayıları (hiçbir oyun için ms, bellek): bulunamadı. Yalnız FM topluluğunun niteliksel gözlemi [S12][S13].
- Offworld'de AI'nin "hologram kullanmadığı" ikinci el [S19]; Soren Johnson röportajı/GDC konuşması bulunamadı.
- Startup Company'nin Beta 28 sonrası rakip durumu: bulunamadı.
- Steam toplu olumsuz inceleme metni ve Reddit: erişilemedi.
- Arama bütçesi (18) tükendi; FM, MM, BA için sonraki sorular model bilgisiyle yazılmadı.

---

## Kaynak sicili

Erişim tarihi hepsi için 2026-10-20. "Açılmadı" = yalnız arama sonucu özeti okundu; "açıldı" = WebFetch ile sayfa okundu. Satıcının kendi ürününü anlatan sayfası Düşük; geliştirici satırı Yüksek (geliştirici kimliği işaretliyse).

| S# | URL | Yayıncı | Yayın tarihi | Güven |
|---|---|---|---|---|
| S1 | https://www.capitalismlab.com/?p=473 | Enlight Software, "Script – Competitors" ayar sayfası (açıldı) | belirtilmemiş | Düşük-Orta (satıcı belgesi, ayar listesi) |
| S2 | https://www.capitalismlab.com/digital-age-dlc/technology-research/ | Enlight Software, Digital Age DLC (açıldı) | belirtilmemiş | Düşük-Orta (formül oyunun kendi belgesi) |
| S3 | https://www.capitalismlab.com/?p=429 | Enlight Software, "Improved AI" (açıldı) | belirtilmemiş (telif 2026) | Düşük (tanıtım) |
| S4 | https://gameshorizon.com/guides/big-ambitions-1-0-rivals-explained-how-they-work-how-to-beat-them/ | GamesHorizon (Pranshu Aryan), rehber (açıldı) | 1 Eyl 2026 | Orta-Düşük |
| S5 | https://steamcommunity.com/app/1331550/discussions/0/4416424806092527106 | Steam, Big Ambitions "Rival profits on businesses"; geliştirici David Estes Creations yanıtları (açıldı) | 4–12 Tem 2024 | Yüksek (geliştirici satırı), Orta (oyuncu) |
| S6 | https://steamcommunity.com/app/1331550/discussions/0/5796774472375037038 | Steam, Big Ambitions "200+ days bored" (açıldı) | 25 May–21 Kas 2024 | Orta |
| S7 | https://store.steampowered.com/app/1331550/Big_Ambitions/ | Steam mağaza, Hovgaard Games (açıldı) | çıkış 28 Ağu 2026; EA 10 Mar 2023 | Yüksek (sayılar) |
| S8 | https://www.footballmanager.com/features/smarter-transfers-squad-building-and-finance | Football Manager (Sports Interactive) FM24 özellik yazısı (açıldı) | 19 Eyl 2023 | Düşük (satıcı) |
| S9 | https://www.fmscout.com/a-can-the-football-manager-ai-figure-out-your-tactic.html | FM Scout (Stam), geliştirici Neil Brock alıntılı (açıldı) | 12 Eyl 2018 | Orta |
| S10 | https://steamcommunity.com/app/482730/discussions/0/1291817837631653819 | Steam, Football Manager 2017 "Cheating"; geliştirici Neil Brock yanıtı (açıldı) | 4 Haz–1 Tem 2017 | Orta (geliştirici satırı Yüksek) |
| S11 | https://fmprojects.substack.com/p/reputation | Football Manager Projects (Daniel Evensen) (açıldı) | 7 Ara 2024 | Orta-Düşük (blog; yazar mekaniği bilmediğini söylüyor) |
| S12 | https://www.fmscout.com/q-3717-Leagues-and-Databases.html | FM Scout forum, lig ve veri tabanı (açılmadı, arama özeti) | belirtilmemiş | Düşük |
| S13 | https://steamcommunity.com/app/624090/discussions/0/1483235412217619521 | Steam, Football Manager 2018 (açılmadı, arama özeti) | belirtilmemiş | Düşük |
| S14 | https://sortitoutsi.net/content/76014/fm26-which-transfers-do-ai-always-make | Sortitoutsi, FM26 deneyi (açılmadı, arama özeti) | belirtilmemiş | Düşük |
| S15 | https://en.wikipedia.org/wiki/Football_Manager_(series) | Wikipedia (açıldı) | erişim anı | Orta |
| S16 | https://steamcommunity.com/app/415200/discussions/0/217691032427110448 | Steam, Motorsport Manager; "Motorsport Manager" geliştirici hesabı (açıldı) | 10 Kas 2016 | Yüksek (geliştirici satırı) |
| S17 | https://steamcommunity.com/app/415200/discussions/0/1519260397777880664 | Steam, Motorsport Manager "AI teams that hire expensive drivers…" (açıldı) | 28 Eyl–2 Eki 2017 | Orta |
| S18 | https://steamcommunity.com/app/415200/discussions/0/1368380934271347543 | Steam, Motorsport Manager "Perfect setup still losing?" (açıldı) | 29–30 Haz 2017 | Orta |
| S19 | https://steamcommunity.com/app/271240/discussions/0/1679189548056399798 | Steam, Offworld Trading Company, AI patent iddiası (açıldı) | 18–20 Nis 2019 | Orta-Düşük (geliştirici yanıtı yok; Soren alıntısı ikinci el) |
| S20 | https://forum.quartertothree.com/t/offworld-trading-company-from-mohawk-games/74837?page=11 | Quarter to Three forum; SorenJohnson yanıtları (açıldı) | 18–19 Oca 2015 | Orta (geliştirici satırı Yüksek) |
| S21 | https://store.steampowered.com/app/271240/Offworld_Trading_Company/ | Steam mağaza, Mohawk Games (açıldı) | çıkış 28 Nis 2016 | Yüksek (sayılar) |
| S22 | https://steamcommunity.com/app/606800/discussions/0/1638676181986210763 | Steam, Startup Company; geliştirici Jonas (Hovgaard Games) yanıtı (açıldı) | 13–14 Kas 2019 | Yüksek (geliştirici satırı) |
| S23 | https://store.steampowered.com/app/606800/Startup_Company/ | Steam mağaza, Hovgaard Games (açıldı) | çıkış 10 Nis 2020 | Yüksek (sayılar), Düşük (açıklama) |
| S24 | https://steamcommunity.com/app/362620/discussions/0/451850468372809165/ | Steam, Software Inc. "How the stock market works"; geliştirici Coredumping (açıldı) | 11 Oca 2016 | Yüksek (geliştirici satırı) |
| S25 | https://steamcommunity.com/app/362620/discussions/0/530647080134369375 | Steam, Software Inc. "YEAR 2009 – No more competition?" (açıldı) | 13 Tem 2015 | Orta (alfa sürümü) |
| S26 | https://steamcommunity.com/app/362620/discussions/0/353915309334499343 | Steam, Software Inc. "Market Recognition" (açıldı) | 27–28 Tem 2016 | Düşük-Orta (tek kayıt dosyası) |
| S27 | https://steamcommunity.com/app/362620/discussions/0/6664812048258268104 | Steam, Software Inc. "Suggestion: More Competitor depth" (açıldı) | 16–19 Haz 2023 | Orta |
| S28 | https://steamcommunity.com/app/362620/discussions/0/3154186375137737807/ | Steam, Software Inc. "Game is too easy to make money" (açıldı) | 9–18 May 2021 | Orta |
| S29 | https://store.steampowered.com/app/362620/Software_Inc/ | Steam mağaza, Coredumping (açıldı) | çıkış 1 May 2015 (erken erişim) | Yüksek (sayılar), Düşük (açıklama) |
| S30 | https://coredumping.itch.io/software-inc/devlog/1119376/patch-notes-for-beta-1831 | Coredumping, itch.io devlog (açıldı) | 20 Kas 2025 | Yüksek |
| S31 | https://coredumping.itch.io/software-inc | Coredumping, itch.io mağaza (açıldı) | belirtilmemiş | Düşük (satıcı) |
| S32 | https://steamcommunity.com/app/1342330/discussions/0/3825289852121656306 | Steam, Mad Games Tycoon 2; geliştirici Panda yanıtı (açıldı) | 21 May ve 1 Haz 2023 | Yüksek (geliştirici satırı) |
| S33 | https://store.steampowered.com/app/1342330/Mad_Games_Tycoon_2/ | Steam mağaza, Eggcode Games (açıldı) | çıkış 31 May 2023 | Yüksek (sayılar), Düşük (açıklama) |
| S36 | https://en.wikipedia.org/wiki/Capitalism_(video_game) | Wikipedia (açıldı) | erişim anı | Orta |
| S38 | https://steamcommunity.com/app/415200/discussions/0/1842367319512870168 | Steam, Motorsport Manager, sıralama farkı (R2'den aktarıldı; bu oturumda açılmadı) | 10–11 Ara 2016 | Orta |
| S39 | https://steamcommunity.com/sharedfiles/filedetails/changelog/2827485583 | Steam Atölyesi, MM topluluk modu değişiklik listesi (açılmadı, arama özeti) | belirtilmemiş | Düşük |
| S40 | https://en.wikipedia.org/wiki/Motorsport_Manager | Wikipedia (açıldı) | erişim anı | Orta |
| S41 | https://steamcommunity.com/app/2252570/discussions/0/4635988522932666110 | Steam, Football Manager 2024 (açılmadı, arama özeti) | belirtilmemiş | Düşük |
| S42 | https://steamcommunity.com/app/378120/discussions/0/405692224231632649 | Steam, Football Manager 2016 (açılmadı, arama özeti) | belirtilmemiş | Düşük |
| S43 | https://www.fmscout.com/q-21445-Successful-LLM.html | FM Scout forum (açılmadı, arama özeti) | belirtilmemiş | Düşük |
| S44 | https://steamcommunity.com/app/2252570/discussions/0/603020257754366795 | Steam, Football Manager 2024, terfi (açılmadı, arama özeti) | belirtilmemiş | Düşük |

Not: S34, S35, S37 numaraları kullanılmadı (taslakta çıkarılan kaynaklar); numaralar kaynak sicilindeki kimliklerle eşleşir. Rubber band yazıları (Game Developer, Dave Mark, 2 Haz 2010 https://www.gamedeveloper.com/design/rubber-banding-as-a-design-requirement ; MCV, 17 Ağu 2009 https://www.mcvuk.com/development-news/black-rock-studio-blasts-arubber-bandinga/) bu raporda kullanılmadı; R2'de yer alıyor.
