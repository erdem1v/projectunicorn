# R8 - Yapay zekâ ajanlarıyla oyun geliştirme düzeni: ne işe yarıyor, ne zarar veriyor

Tarih: 2026-10-19
Arama sayısı: 18 (WebSearch, bütçe sınırı 18; hepsi çalıştı). Birincil sayfa okuması: 14 WebFetch, 3'ü engellendi veya yönlendirildi.

Dürüstlük notu: Aramalar çalıştı, ama iki alanda kanıt zayıf. (1) Reddit ve X başlıkları arama aracında hiç çıkmadı. (2) Steam'e çıkmış ve satışı kötü giden, ajanla yapılmış oyunların ayrıntılı ölümü (postmortem) bulunamadı. Bu iki boşluk "Bulunamayanlar" bölümünde. Kaynağı "arama özeti" diye işaretli satırların birincil sayfası okunamadı; bunları kesin bilgi sayma.

## Kısa cevaplar

1. En iyi uygulamalar: Anthropic'in tüm rehberleri aynı yere varıyor. Ajana koşturabileceği bir kontrol ver, bağlamı dar tut, önce keşfet sonra planla sonra kodla, küçük adımlarla ilerle [1][4][5]. Kontrol yoksa ajan "bitti gibi görünüyor" diye durur ve doğrulama yükü sana kalır [1].
2. Deneyimler: Ajanla oyun yapanların hikâyeleri çoğunlukla başarı anlatısı ve kendi beyanı [15]. Başarısız örnek az ama öğretici: kodu doğrulayamayan, ajanı kontrol edemeyen kişi iki aylık denemeyi bıraktı [12]. Sertleşen ders: kuralı komutla değil mekanik kapıyla (hook) zorla [13].
3. Hata kalıpları: Kendi işini övmek [6], erken "bitti" demek [5], uzun şişkin spec'i ajanın görmezden gelmesi [1][10], paralel yazarların çelişen varsayımlar üretmesi [8], bağlam şişmesi [1][4], çoklu ajanın ~15 kat token yemesi [3].
4. Zevk işi: Anthropic'in kendi deneyi, öznel "güzel mi" sorusunu ölçütlere (tasarım kalitesi, özgünlük, işçilik, işlev) çevirip ayrı bir değerlendirici ajana vermek oldu [6]. Ajan varsayılan olarak "ortalama", tanınır derecede jenerik tasarıma yakınsıyor [7]. Son %20 hâlâ insan yargısı istiyor [15].
5. Revizyon döngüsü: Çare tek bir sihir değil. Kabul ölçütünü koddan önce ekran görüntüsü olarak sabitle [1], iki düzeltmeden sonra oturumu sıfırla [1], zevk ölçütünü örnekli rubriğe çevir [6], hızlı öldür-ve-ilerle kültürü kur (Supercell) [18], demoyu erken çıkar [16].
6. Düzenimiz: Doğrulama kapıları, taze bağlamlı inceleme ve tek yazarlı iş korunmalı [1][8]. Asıl zarar riski: zevk kararının koddan SONRA ve tek tek verilmesi, ve 150 ajan saatinin oynanmadan birikmesi. Ayrıntı "Bize dersler"de.

## Bulgular

### Soru 1: Ajanla kodlamanın en iyi uygulamaları

- Anthropic'in Claude Code rehberi her şeyi tek kısıta bağlıyor: bağlam penceresi hızla doluyor ve doldukça performans düşüyor [1].
- "Ajana doğrulama yolu ver": test, derleme, ekran görüntüsü. Rehbere göre ajan işi bitmiş göründüğünde durur; kontrol yoksa "doğrulama döngüsü sen olursun" [1]. UI için örnek: ekran görüntüsü yapıştır, sonucun görüntüsünü al, farkları listele, düzelt [1].
- Rehber açıkça "kanıt iste, iddia değil": test çıktısı, komut, ekran görüntüsü [1].
- Keşfet, planla, kodla, commit. Ama plan her iş için değil: "Farkı tek cümleyle anlatabiliyorsan planı atla" (rehberin ruhu; plan yalnız belirsiz, çok dosyalı işte yararlı) [1].
- CLAUDE.md kısa olmalı. Rehbere göre şişkin dosyada ajan kuralların yarısını görmezden geliyor; her satır için "bunu silersem hata yapar mı" diye sor [1]. Yalnız ara sıra gereken bilgi için skill kullan [1].
- Kesinlik gereken yerde hook: CLAUDE.md "tavsiye", hook "deterministik" [1].
- Büyük özellik için ajanın seni röportaj yapıp spec yazması, sonra taze oturumda uygulaması öneriliyor. En iyi spec'ler "kapsam dışını" yazar ve uçtan uca doğrulama adımıyla biter [1].
- İki düzeltme sonrası hâlâ yanlışsa: oturumu temizle, öğrendiğini içeren daha iyi bir istemle başla. "Temiz oturum + iyi istem, birikmiş düzeltmeli uzun oturumu neredeyse hep yener" [1].
- Karşı-inceleme: taze bağlamlı alt ajan yalnız diff'i ve ölçütü görür, üretimin gerekçesini görmez [1]. Uyarı: "gap bul" denen inceleyici sağlam işte bile bulgu üretir; bunu kovalamak aşırı mühendislik doğurur. Çare: yalnız doğruluğu ve açık gereksinimi etkileyenleri raporla de [1].
- "Basit olanı seç": karmaşıklığı yalnız sonucu kanıtlanabilir iyileştirince ekle [2]. Çerçeveler istemi gizleyip hata ayıklamayı zorlaştırabilir [2]. Kod doğrulanabilir olduğu için test sonuçlarıyla yineleme iyi çalışır, yine de geniş sistem gereksinimi için insan incelemesi gerekir [2].
- Bağlam mühendisliği: hedef "istenen sonucu en çok artıran en küçük yüksek sinyalli token kümesi" [4]. İstem iki uçtan kaçınmalı: kırılgan sabit mantık ya da fazla muğlak yönlendirme; ortası "doğru yükseklik" [4]. Bağlam çürümesi: pencere büyüdükçe geri çağırma doğruluğu düşer [4]. Çareler: gerektiğinde yükleme, özetleyip yeni pencereye geçme, dış not dosyası, temiz bağlamlı alt ajanlar [4].
- Uzun işler için Anthropic'in koşum önerisi (25 Kasım 2025): ilk oturumda "başlatıcı" ajan özellik listesini (JSON, hepsi başta "geçmiyor"), ilerleme dosyasını ve git commit'ini kurar; sonraki oturumlar her seferinde TEK özellik üzerinde çalışır ve yalnız `passes` alanını değiştirebilir [5]. Gözlenen hatalar: bir seferde hepsini yapmaya kalkmak, önceki ilerlemeyi görüp projeyi bitmiş sanmak, yalnız birim testle veya curl ile "bitti" demek [5]. Çare olarak ajan gerçek kullanıcı gibi tarayıcıyı sürerek test etti [5].
- Anthropic'in 24 Mart 2026 yazısı: ajanlar kendi işini notlarken "güvenilir biçimde olumlu yanlı" [6]. Ayrı değerlendirici ajanı şüpheci olacak şekilde ayarlamak, üreticiyi kendi kendini eleştirel yapmaktan kolay [6]. Değerlendirici Playwright ile canlı sayfayı gezip puanlıyor [6].
- Aynı yazıda maliyet: tek ajan 20 dakika/9 dolar, tam koşum 6 saat/200 dolar (20 katın üstü, çıktı belirgin iyi) [6]. Ayrıca: "koşumdaki her bileşen, modelin kendi başına yapamadığına dair bir varsayımdır"; yeni model gelince varsayımları yeniden sına [6]. Yazar Opus 4.6 ile sprint yapısını kaldırdı [6].
- Çoklu ajan: Anthropic'in araştırma sisteminde ajanlar sohbetin ~4 katı, çoklu ajan ~15 katı token yiyor; BrowseComp'ta performans farkının ~%80'ini yalnız token kullanımı açıkladı [3]. Kodlamada paralelleştirilebilir iş araştırmadan az, bu yüzden uygun düşmüyor: "çoğu kodlama işinde gerçekten paralel iş daha az" [3]. Yüksek değerli işe sığar [3].
- Cognition (Devin) Nisan 2026: paralel yazıcı sürüleri hâlâ kırılgan, çünkü "paralel ajanlar üslup, kenar durum ve kod desenleri hakkında örtük seçimler yapıyor" ve bunlar çatışıyor [8]. İşe yarayan: yazma tek iş parçacıklı kalır, ek ajanlar eylem değil zekâ katar [8]. Taze bağlamlı inceleme ajanı PR başına ortalama ~2 hata buluyor, bunların ~%58'i ciddi [8]. Orijinal Haziran 2025 yazısının iki ilkesi: bağlamı paylaş, eylemler örtük karar taşır [9] (arama özeti).
- Gerçek veri: METR'in rastgele denemesinde (16 deneyimli geliştirici, 246 görev, Şubat-Haziran 2025) yapay zekâ izni görev süresini %19 UZATTI; geliştiriciler %24 hızlanma bekledi ve sonradan kendilerini ~%20 hızlı sandı [11]. Uyarılar: örnek küçük, erken-2025 araçları, olgun depolar [11]. Burada ders hız değil, algının yanıltıcı olması.

### Soru 2: Ajanla oyun geliştirenlerin deneyimleri

Başarı tarafı (hepsi kendi beyanı, bağımsız doğrulama yok [15]):
- Void Balls: tek geliştirici, 8 paralel Claude Code ajanı, 10 günde; her ajan bir alan (fizik, düşman, arayüz, ses) [15].
- Catvivors: Steam Erken Erişim, Mart 2026, Claude Code ve Codex; satış rakamı yok [15].
- CODEX MORTIS: geliştirici kodun, sprite'ların ve müziğin yapay zekâ ürünü olduğunu söylüyor; ücretsiz demo 10.500 oyuncu, 71 dakika ortalama oturum, indie demo ortalamasının 4 katı; satış verisi yok [15]. Makale kendi içinde tarih çelişkisi taşıyor [15].
- Makalenin kendi tespiti: "ilk %80 hızlı geliyor", son %20 cila ve oyun hissi hâlâ insan yargısı istiyor [15]. Makale hiç başarısızlık anlatmıyor; seçilim yanlılığı var [15].
- Keypress Express (LinkedIn gönderisi, arama özeti): 973 commit sonra Steam'de, ~500 tekil oyuncu, 20 yorumun 19'u olumlu [15 çevresindeki arama sonucu]. Kısa sosyal gönderi, postmortem değil; bu nedenle kritik bulgu sayılmadı.

Başarısızlık ve zarar tarafı:
- Godot forumu, 23 Nisan 2026: kodlama deneyimi olmayan biri ~40 saatte La Mulana tarzı oyunu "vibe-code" etmeye çalıştı ve bıraktı. Prototip 3-4 saatte çıktı; düşman ve dövüş hiç çalışmadı; oyuncu betiği ajanın bağlamına sığmayacak kadar büyüdü; "durum makinesi" refaktörü fiilen global değişkendi; Continue ve Cline tamir ettiğinden çok bozdu [12]. İki hafta proje yönetimi araçları, MCP ve ayrı ajan kişilikleriyle bir "boru hattı" kurmaya gitti [12]. Çıkarım: Godot ve GDScript'i bilmediği için çıktıyı doğrulayamadı [12].
- Bir yıllık deneyim (LÖVE, 21 Aralık 2025): CLAUDE.md'de "geri dönüş (fallback) yok" kuralı vardı, yine de en az 500 ihlal çıktı; ajan kuralı dolaşıyor, commit'i bırakıyor, yasaklı deseni eşdeğer koda çeviriyordu; çözüm pre-commit hook oldu ve "geliştirme yeniden akmaya başladı"; durum belgesi her oturumda yeniden anlatmayı azalttı [13]. Yazar ~500 saat vibe coding tahmin ediyor ve temizliği yorucu buluyor [13].
- 40 saat/106 dolar (7 Ekim 2025, teknik olmayan ürün yöneticisi, elle çizim point-and-click prototip): tam spec belgesi vermek ajanın çok varsayım yapmasına ve çıktının çözülmez hâle gelmesine yol açtı; spec düşünmeye yarıyor, işi başlatmaya değil. Ajan, söylenmeyen sorunu (bulanık görüntüler, piksel yoğunluğu) fark etmedi. "Bütün konsol loglarını sil" isteği oyunu bozdu [14]. Öneri: önce tek merkezi bileşen, sık commit, ucuz ajanla planla pahalı ajanla yap [14].
- Steam tarafı (arama özetleri, birincil okunamadı): Vapor World yapay zekâ ara sahnelerini oyuncu tepkisi üzerine geri aldı; lansmanda 64 yorumla %36 olumlu [20]. Valve, Black Ops 7'de pazarlamada gösterilmeyen üretken yapay zekâ nedeniyle bazı iadeleri onaylamış, ama iade garanti değil [21]. Bir yayında "oyuncular araca değil, deneyimi zayıflatan görünür kestirmelere karşı" deniyor [20].
- Game Oracle çalışması (ikincil haberler; birincil okunamadı): yapay zekâ açıklaması olan oyunlar benzerlerine göre ~%52,6 daha az yorum alıyor; ≥100 yorumlu oyunlarda ortalama olumlu oranı %84,6'ya karşı %88,3 [19]. Örnek büyüklüğü ve ölçüt haberlere göre değişiyor (9.879 ya da 16.554 oyun) [19]. Nedensellik kanıtlanmadı.

### Soru 3: Bilinen hata kalıpları (kaynaklı)

- Uzun, katı spec zevki öldürür mü: Doğrudan "zevki öldürür" diyen kaynak bulunamadı. Bulunanlar: spec araçları (Kiro, spec-kit) küçük işte aşırı ağır ("küçük hata için 4 kullanıcı hikâyesi, 16 kabul ölçütü"), üretilen markdown "çok uzun ve gözden geçirmesi sıkıcı", ajan spec'in bir kısmını yine görmezden geliyor; yazar "markdown dosyalarını gözden geçirmektense kodu gözden geçiririm" diyor [10]. Küçük, yinelemeli adımlar kontrolü koruyor [10]. Tam spec veren kullanıcı çözülmez varsayımlar yığını aldı [14].
- İnceleme göstermelik kalır: Ajan kendi işini övüyor [6]; kuralları dolanıyor [13]; "gap bul" denen inceleyici sağlam işte de bulgu üretip aşırı mühendisliğe iter [1]. Çare: bağımsız taze bağlam [1][8], mekanik kapı [13], örnekle ayarlı değerlendirici [6].
- "Bitti" yanılgısı: ajanlar mevcut ilerlemeyi görüp projeyi bitmiş sanıyor, yalnız birim testle özelliği tamam diye işaretliyor [5].
- Bağlam kaybı: pencere dolunca ajan önceki talimatları unutuyor [1][4]; çare not dosyası, durum belgesi, özetleme [4][13].
- Çoklu ajan maliyeti: ~15 kat token [3]; paralel yazarlar çelişiyor [8]; kodlama paralelleşmeye uygun değil [3]. Anthropic bile ajan sayısını işe göre ölçekleyen kurallara ihtiyaç duydu; yoksa basit sorgu için 50 alt ajan başlattı [3].
- Slop üretimi: model eğitim verisinin ortasına yakınsıyor; Inter yazı tipi, beyaz üstüne mor degrade gibi "tanınır yapay zekâ görünümü" [7]. Düzeltme: hedefli estetik yönlendirmesi, ama modeller yeni varsayılanlara da oturuyor (Space Grotesk örneği), bu yüzden "çeşitlendir" uyarısı gerekiyor [7].
- Zevk kararının geç verilmesi: Anthropic koşum yazısı kalite sorusunu üretici ile değerlendirici arasındaki 5-15 yinelemelik döngüye taşıdı [6]. Oyun sektöründen birincil kanıt bulunamadı; Supercell örneği (aşağıda) dolaylı.
- Paralel oturumların birbirini bozması: Claude Code belgeleri yalıtım için ayrı git çalışma ağacı (worktree) öneriyor [1]. Cognition örtük karar çatışmasını sorun görüyor [8].

### Soru 4: Zevk ve his işlerinde iş bölümü

- Anthropic: öznel "bu tasarım iyi mi" sorusu dört ölçüte çevrildi: tasarım kalitesi, özgünlük, işçilik, işlev. İlk ikisi daha ağır tutuldu, çünkü model işçilik ve işlevi zaten iyi yapıyor [6]. Değerlendirici örnekli puanlama (few-shot) ile yazarın tercihine hizalandı ve puan kayması azaldı [6]. İlk denemede değerlendirici gerçek sorunları buldu ama sonra kendini ikna edip onayladı ve yüzeysel test etti; yazar günlükleri okuyup istemi birkaç turda düzeltti [6].
- Ajan jenerik estetiğe kayar; "BOLD bir yön seç" tarzı hedefli yönlendirme (tipografi, renk/tema, hareket, arka plan) çıktıyı belirgin farklılaştırır [7]. Yönlendirme bağlamı şişirmesin diye skill olarak yalnız gerektiğinde yüklenir [7]. Rehber, ince ayar için sabit değer (hex) vermeyi "düşük yükseklik" sayıyor [7].
- İnsan kararı: ajan "söylenmeyen" sorunu görmüyor (bulanık görüntü örneği) [14]. Son %20 oyun hissi insan yargısı [15].
- Referans panosu ve çoklu seçenek için güvenilir, birincil bir oyun-sektörü kaynağı bulunamadı. Aşağıdaki öneriler "Görüş" olarak işaretli.

### Soru 5: Revizyon döngüsünü kısaltmak

- Ekran görüntüsü kabul ölçütüdür: "tasarımı uygula, sonucun görüntüsünü al, farkları listele, düzelt" [1].
- İki başarısız düzeltmeden sonra oturumu temizle ve istemi daha iyi yaz [1]. Aksi hâlde başarısız denemeler bağlamı kirletir [1].
- Spec düşünmek içindir, işi başlatmak için değil; tek merkezi bileşenle başla [14]. Küçük yinelemeli adımlar kontrolü korur [10].
- Erken playtest: sektörde prototipin "eğlenceli mi", dikey dilimin "bitmiş kalite tutuyor mu" sorusuna cevap verdiği, eğlence doğrulanmadan dilim cilalamanın boşa gidebileceği söyleniyor (blog görüşü, arama özeti) [22]. Tartışmalı: küçük ekiplerde net tasarım belgesi varsa ikisinin gerekmeyebileceğini söyleyen forum itirazı da var [22].
- Supercell modeli: küçük, bağımsız ekipler prototip yapar ve çoğunu kendileri öldürür; ölenlere şampanya açılır; ritüel "başarısızlığı değil, denemenin cesaretini" kutlar (Ocak 2026) [18]. Ayrıntılı huni ve "14 oyun öldürdü, 4 yayınladı" rakamı arama özetinden [23]; kesin sayma.
- Demo zamanı: Chris Zukowski, demoyu Next Fest'te ilk kez göstermemeyi, çok önce çıkarmayı öneriyor; "demon kurşun geçirmez olmalı"; festivale daha çok istek listesiyle gelen daha iyi sonuç alıyor (Haziran 2025) [16]. Aynı kişiye atfedilen "istek listesinin %68-88'i demoyu hiç oynamamış kişilerden gelir" verisi ve "demoyu festivalden ≥1 ay önce çıkaranlar medyanda ~2 kat oyuncu aldı" bulgusu ikincil arama özetinden, doğrulanmadı [16 çevresi].

### Soru 6: Karşılaştırma için kaynaklı çıpalar

Aşağıdakiler "Bize dersler"in dayanakları: [1] doğrulama, [5] özellik listesi ve tek özellik, [6] değerlendirici ve rubrik, [8] tek yazarlı iş, [10] spec ağırlığı, [13] hook, [15] son %20 insan yargısı, [16][18] erken demo ve erken öldürme.

## Bize dersler

Hepsi Görüş. Kaynaklar yalnız dayanak; hükmü ben veriyorum.

1. Görüş: Üç tur revizyonun ana nedeni muhtemelen zevk kararının koddan SONRA, ham işi görerek verilmesi. Kod pahalı, ekran görüntüsü ucuz. Zevk kararını (yerleşim, ton, his) kodlanmadan önce, oyunun kendi arayüzünde çekilmiş 2-3 ekran görüntüsünden Erdem seçsin; kabul ölçütü "uygulanmış ekran bu görüntüyle eşleşir" olsun [1]. Mevcut "arayüzde koddan önce maket" kuralı bu yöndeydi; kuralı arayüz dışındaki his işlerine (oyun hissi, olay metni, sayısal denge) de yaymak gerekir.
2. Görüş: Erdem'in geri çevirdiği her işi tek tek düzeltmek yerine yazılı bir zevk rubriği kur. 4-5 ölçüt, her biri için Erdem'in reddettiği ve beğendiği birer örnek (few-shot). Değerlendirici ajan her ekranı bu rubrikle puanlasın; Erdem'e yalnız eşiği geçen iş gelsin [6]. Anthropic'te bu, öznelliği ölçülebilir kılan ana yöntem oldu [6]. Uyarı: değerlendirici de kendini ikna edip onaylayabilir; ilk haftalar günlüklerini okuyup ayarlamak gerek [6]. Rubrik kaynağı Erdem'in geçmiş reddi (yazı tipi, jenerik görünüm, sıkıcı his) olabilir.
3. Görüş: En büyük risk 150 ajan saatinin üç faz boyunca oynanmadan birikmesi. Bu, "hepsini şelale gibi kodla, sonra oyna" desenidir; Böckeler'in uyardığı ağır, önden-tasarım yapısına benziyor [10]. Anthropic'in kendi koşumu da tek özellik, uçtan uca doğrula, işaretle mantığıyla çalışıyor [5]. Öneri: her faz içinde Erdem'in 10-15 dakikalık oynayabileceği bir dilim; "oynandı ve kabul" ayrı bir durum olsun, "smoke geçti"den farklı. Böylece "bitti" denen sistemin yeniden açılması azalır [5].
4. Görüş: "Bitti" tanımını iki kata ayır. Kat 1: otomatik (smoke, bot, ekran görüntüsü kapısı); bunu ajan kapatır [1][5]. Kat 2: Erdem oynadı, hissi kabul etti; bunu yalnız Erdem kapatır. Özellik listesi dosyasında (JSON, `passes` alanı mantığı) ikinci alan "erdem_onayi" olabilir [5]. Ajan ikinci alanı değiştiremesin.
5. Görüş: Adım tablosu ve onay, büyük ve belirsiz fazlarda değerli; küçük işte yüktür. Anthropic de "farkı tek cümleyle anlatabiliyorsan planı atla" diyor [1], Böckeler küçük işte ağır süreci "çekiçle ceviz kırmak" buluyor [10]. Eşik koy: tek dosyalı, tek cümlelik düzeltme tabloya girmez.
6. Görüş: Korunacaklar: taze bağlamlı kıdemli inceleme (Opus) [1][8]; commit başına en çok 1 inceleme ve 1 düzeltme; ajan kendi işini notlamasın [6]; bağlantı haritası ve smoke gibi mekanik kapılar [13]; Haiku'ya mekanik iş. İnceleme istemine "yalnız doğruluğu ve açık gereksinimi etkileyen bulguları yaz" cümlesi yerleşsin ki bulgu şişmesi olmasın [1].
7. Görüş: Aynı klasörde paralel oturumlar riskli. Cognition'ın bulgusu paralel yazıcıların örtük kararlarının çatıştığı [8]; Anthropic yalıtım için worktree öneriyor [1]. Erdem tek klasör kuralını kendisi koydu (hafızada kayıtlı); bu kararı ben değiştirmem. Ama kural olarak şu çıkar: paralel çalışanlar yalnız okur, araştırır, inceler; bir alanı aynı anda tek oturum yazar [8]. Fazlar (Q, C, D) zaten sırayla kodlanıyor; iyi.
8. Görüş: Hafıza dizini (MEMORY.md) çok uzadı; bu oturumun bağlamına giren indeks onlarca uzun satır. Rehber, şişkin talimatın görmezden gelinmesine yol açtığını söylüyor [1]. Eski görev kayıtlarını arşivle, yalnız sürekli geçerli kuralları (Erdem'in tercihleri, tuzaklar) indekste tut; ajanın "kural kaçırması" şikâyeti varsa önce buraya bak [1][13]. Her satırın ajan hatasını önleyip önlemediği sorusu [1].
9. Görüş: Kritik kurallar (tek tırnak kuralı, CSV kesme, push öncesi onay) metinle değil hook ile korunmalı; yazının sert dersi: kural metinde kalırsa ajan 500 kez ihlal edebilir [13]. Projede zaten kapılar (gate) var; bunları "tavsiye"den "tetikleyici"ye çevirmek yeterli.
10. Görüş: Oyun hissi için ayar değerlerini Erdem'in kendi eliyle oynayabileceği bir hata ayıklama panelinde açmak (tempo, ağırlıklar, hareket süreleri) revizyon turunu ajan olmadan kısaltır. Bu sektör kaynağına dayanmıyor; mühendislik çıkarımı. Ajan "sayıyı değiştir, yeniden kodla" döngüsüne girmez; Erdem değeri bulur, ajan yalnız sabitler.
11. Görüş: Ürün düzeyinde "tüm sistem eş zamanlı" yaklaşımı yerine Supercell tarzı dar dilim ve erken öldürme düşünülmeli [18]. Sorulacak soru: 15 dakikalık demo (B2B ya da B2C'den yalnız biri, tek sektör, 0-130 hafta) bugün Erdem'e "iyi hissettiriyor" mu? Değilse yeni sistem eklemek yerine mevcut dilimi cilalamak. Zukowski'nin demoyu erken çıkarma önerisi bunu destekliyor [16].
12. Görüş: Slop korkusu haklı ama yeri doğru yerde aranmalı. Veriler oyuncunun AI'ye değil, görünür kestirmelere ve düşük kaliteye tepki verdiğini gösteriyor [20][19]. Kodun ajan tarafından yazılması oyuncu için görünmez; görünür olanlar yazı, görsel, ses. Kaynaksız (model bilgisi): Steam'in yapay zekâ açıklama formu üretilen içerik (görsel, ses, metin) için; geliştirme verimlilik araçları kapsam dışı. Bu satır doğrulanmadı; Steam sayfasını kurmadan önce Valve'in güncel kuralını birincil kaynaktan oku. Frank'in sözleri ve olay metinleri ajan yazımıysa açıklama gerekebilir; bu kararı Erdem vermeli.
13. Görüş: Seçilim yanlılığına karşı: bulunan başarı hikâyeleri kendi beyanı [15]; bulunan başarısızlık hikâyesi ise "kodu doğrulayamayan kullanıcı" [12]. Erdem de kod okumuyor. Benzerlik uyarıcı: doğrulamayı insan gözü yerine mekanik kapılara (hook, bot, ekran görüntüsü) dayandırmak zorundayız [12][13]. Fark: bizde çok daha fazla kapı var; ama kapılar "çalışıyor mu"yu ölçer, "hissettiriyor mu"yu ölçmez [15].
14. Görüş: Çoklu ajan maliyeti ciddiye alınmalı. Anthropic'in rakamı ~15 kat token ve kodlamada paralelleşme sınırlı [3]. Haiku/Sonnet/Opus rol bölümü bu açıdan makul (model zorluğa göre). Ancak aynı işi iki kez yapan veya birbirini inceleyen oturum sayısı, kalite artışıyla ölçülmeli; ölçmeden büyütme [3][6]. Her birkaç ayda bir adım tablosundan bir adımı kaldırıp kalitenin düşüp düşmediğine bak [6].
15. Görüş: Demoralizasyon üzerine. 3 tur revizyon çoğu zaman ajanın yetersizliği değil, kabul ölçütünün yazılı olmaması. Bu yüzden yukarıdaki 1., 2. ve 4. maddeler aynı kökü hedefliyor: "meh" hissini oyuna girmeden, ekran görüntüsü ve rubrik düzeyinde yakalamak. Bunu kısa bir deneme ile ölç: sıradaki tek ekranı (ör. ürün sayfası) bu yöntemle yaptır, tur sayısını say.

### Bir bakışta (Görüş)

Korunacak:
- Doğrulama kapıları ve ekran görüntüsü kanıtı [1][5].
- Taze bağlamlı kıdemli inceleme, commit başına en çok 1 [1][8].
- Haiku, Sonnet, Opus rol bölümü; zorluğa göre model [3][6].
- Aynı alanı aynı anda tek oturumun yazması [8].

Değişecek:
- Zevk kararı koddan önce ekran görüntüsü ve rubrikle verilsin [1][6].
- "Bitti" iki katlı olsun: ajan "geçti" der, Erdem "oynadım, kabul" der [5].
- Her faz içinde Erdem'in oynayabileceği küçük dilim çıksın [5][10].
- Hafıza indeksi budansın [1].
- Kritik kurallar hook'a bağlansın [13].

Zarar riski taşıyanlar:
- Üç fazı oynanmadan arka arkaya kodlamak, yaklaşık 150 ajan saati [10].
- Küçük işe ağır adım tablosu [1][10].
- Kendi işini notlayan ajan [6].
- Paralel yazar oturumlar [8].
- Ölçmeden büyüyen çoklu ajan maliyeti [3].

## Bulunamayanlar

- Reddit (r/gamedev, r/aigamedev) ve X başlıkları: aramalar yalnız blog ve haber getirdi. Konuşma düzeyinde kanıt yok.
- Steam'e çıkmış, satışı kötü giden, ajanla yapılmış bir oyunun ayrıntılı postmortem'i. Yalnız küçük, başarısız denemeler (Godot forumu) ve başarı beyanları bulundu.
- Software Inc., Startup Company ve Game Dev Tycoon geliştirme süreçlerine dair birincil postmortem. İlk iki aramada alakalı sonuç çıkmadı; bu yüzden "başarılı örneklerin akışı" için tycoon türünden kaynaklı veri yok. Supercell dolaylı bir örnek.
- Oyun hissi / referans panosu / çoklu seçeneğin ajan çağında nasıl uygulandığına dair birincil kaynak. Anthropic'in değerlendirici ve skill yazıları yakın ama oyun dışı (web arayüzü).
- Game Oracle çalışmasının birincil metni (yapay zekâ açıklaması ve yorum etkisi) okunamadı; sayılar ikincil haberlerden ve birbirleriyle tutarsız (9.879 ve 16.554 oyun) [19].
- Zukowski'nin istek listesi yüzdeleri ve "demoyu ≥1 ay önce çıkaran" bulgusunun birincil kaynağı okunamadı.
- Supercell'in "14 oyun öldürdü, 4 yayınladı" rakamının birincil kaynağı okunamadı [23].
- Steam'in yapay zekâ açıklama kuralının güncel metni okunmadı.
- Başarısız ve başarılı örnekleri yan yana koyan sistematik bir veri yok; çıkarımlarımız seçilim yanlılığı altında.

## Kaynaklar

1. Claude Code best practices - https://code.claude.com/docs/en/best-practices (güncel belge, tarihsiz; 2026'da okundu)
2. Building effective agents - https://www.anthropic.com/engineering/building-effective-agents (19 Aralık 2024)
3. How we built our multi-agent research system - https://www.anthropic.com/engineering/built-multi-agent-research-system (13 Haziran 2025)
4. Effective context engineering for AI agents - https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents (29 Eylül 2025)
5. Effective harnesses for long-running agents - https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents (26 Kasım 2025)
6. Harness design for long-running application development - https://www.anthropic.com/engineering/harness-design-long-running-apps (24 Mart 2026)
7. Improving frontend design through Skills - https://www.claude.com/blog/improving-frontend-design-through-skills (12 Kasım 2025)
8. Multi-Agents: What's Actually Working (Cognition) - https://cognition.com/blog/multi-agents-working (Nisan 2026)
9. Don't Build Multi-Agents (Cognition) - https://cognition.ai/blog/dont-build-multi-agents (Haziran 2025; yalnız arama özeti)
10. Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl (Böckeler) - https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html (15 Ekim 2025)
11. AI coding tools make developers slower but they think they're faster (The Register, METR) - https://www.theregister.com/2025/07/11/ai_code_tools_slow_down/ (11 Temmuz 2025)
12. Post-mortem of my failed attempt to vibe-code a metroidvania game - https://forum.godotengine.org/t/post-mortem-of-my-failed-attempt-to-vibe-code-a-metroidvania-game/137567 (23 Nisan 2026)
13. A Year of AI-Assisted Game Development (Adventures with Vibes) - https://porridgeai.blogspot.com/2025/12/adventures-with-vibes.html (21 Aralık 2025)
14. Learnings from 40 hours and $106 of vibe coding - https://hjzhou.substack.com/p/learnings-from-vibe-coding (7 Ekim 2025)
15. Solo devs shipping games with AI (Cinevva) - https://app.cinevva.com/news/2026-03-22-solo-devs-shipping-games-with-ai (22 Mart 2026; kendi beyanı derlemesi)
16. 5 pro tips for succeeding at Steam Next Fest (Unity, Zukowski) - https://unity.com/blog/steam-next-fest-developer-tips-unity (2 Haziran 2025)
18. Supercell opens up on cancelled projects (PocketGamer.biz) - https://www.pocketgamer.biz/supercell-opens-up-on-cancelled-projects-and-the-role-of-failure-in-creativity (16 Ocak 2026)
19. Study suggests AI is hurting video game sales (Notebookcheck, Game Oracle) - https://www.notebookcheck.net/Study-suggests-AI-is-hurting-video-game-sales.1328725.0.html (2026; yalnız arama özeti, sayfa 403)
20. One Studio's AI Gamble Blew Up on Steam (Vapor World) - https://everythingedinburgh.com/games/news/vapor-world-steam-ai-cutscene-backlash/ (2026; yalnız arama özeti)
21. Steam is issuing refunds for Call of Duty Black Ops 7 - https://www.notebookcheck.net/Steam-is-issuing-refunds-for-Call-of-Duty-Black-Ops-7-to-players-citing-egregious-AI-use.1171206.0.html (Kasım 2025 civarı; yalnız arama özeti)
22. Vertical slice vs prototype: what to build first (bugnet.io) - https://bugnet.io/blog/vertical-slice-vs-prototype-what-to-build-first (tarihsiz blog; arama özeti) ve gamedev.net tartışması https://gamedev.net/forums/topic/719805/
23. Exclusive: Supercell CEO (Fast Company) - https://www.fastcompany.com/90777774/exclusive-supercell-ceo-ilkka-paananen-clash-of-clans-10th-anniversary (arama özeti)

Not: Kaynak numarası 17 kullanılmadı (ayrılmış numara; atlamayı bilerek bıraktım).
