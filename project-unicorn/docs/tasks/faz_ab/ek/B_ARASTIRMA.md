# Faz B web araştırması
Arama sayısı: 18 (WebSearch çalıştı, hata yok; ayrıca 4 WebFetch). Not: birçok aramanın özeti dolaylı kaynak verdi; birincil kaynak okunamayanlar işaretli. "(kaynak yok, model bilgisi)" = doğrulanmadı.

## 1. SaaS SLA kredi oranları

### Bulgular
- Atlassian (resmi, Premium, taahhüt %99,9): aylık uptime <%99,9 ve >=%99,0 -> %10; <%99,0 ve >=%95,0 -> %25; <%95,0 -> %50. Kredi, etkilenen ürünün aylık ücretinin yüzdesi. https://www.atlassian.com/legal/sla/service-credits
- Atlassian Enterprise (taahhüt %99,95): ek basamak: <%99,95 ve >=%99,9 -> %5; sonrası Premium ile aynı (%10 / %25 / %50). Aynı URL.
- AWS S3 (resmi, eski sürüm): <%99,9 ve >=%99,0 -> %10; <%99,0 ve >=%95,0 -> %25; <%95,0 -> %100. Seyrek erişim sınıfında eşikler bir kademe gevşek (%99,0/%98,0/%95,0). https://aws.amazon.com/s3/sla/historical/
- AWS talep kuralı: müşteri kendisi başvurmalı, olaydan sonraki ikinci fatura döngüsü sonuna kadar, log ve tarih/saat ile; eksik bilgi talebi düşürür; $1 altı kredi verilmez. Aynı URL. (Yani kredi otomatik değil, sürtünmeli.)
- Google Cloud Identity SLA: kredi yüzde değil, ek hizmet günü: <%99,9 -> 3 gün, <%99,0 -> 7 gün, <%95,0 -> 15 gün; müşteri talep etmeli. https://cloud.google.com/terms/identity/sla
- commercetools: %99,9 taahhüt; %99,9-%99,0 arası aylık ücretin %10'u, %99,0-%95,0 arası %25, altı %50; aynı ay birden çok kredi toplamda aylık ücretin %100'ü ile sınırlı. https://docs.commercetools.com/offering/sla-connect.md
- Slack: %99,99 taahhüt (Business+/Enterprise), ölçüm aylık değil çeyreklik, kredi gelecek kullanım için talep edilir. https://slack.com/intl/en-au/terms/service-level-agreement
- Zendesk: %99,95 hedef, %10 aylık kredi (2021 tablosu, eski olabilir). https://www.jitbit.com/news/saas-sla/
- Dakika karşılığı (kaynak yok, model bilgisi; 30 günlük ay = 43.200 dk): %99,9 = ~43 dk; %99,0 = ~7,2 saat; %95,0 = ~36 saat.
- Aylık uptime (sektör kalıbı): %99,9 -> %10 / %99,0 -> %25 / %95,0 -> %50 (üç kaynakta aynı iskelet, https://stackshare.io/docs/stack-monitor/sla-credits üzerinden de genel örnek olarak geçer).

### Oyun için çıkarım
- "Telafi et" B2B seçeneği için üç basamaklı tablo: kesinti <=43 dk -> kredi yok; 43 dk-7 saat -> aylık ücretin %10'u; 7-36 saat -> %25; >36 saat -> %50 (üst sınır %50, 100 değil). Bedel olayın süresinden türer, sabit sayı olmaz.
- Gerçekçilik hissi: kredi oyuncuya "otomatik" verilmez; sektörde müşteri talep eder. Oyunda "telafi öner" = oyuncunun proaktif hamlesi, memnuniyet düzeltmesi ile; talep beklemek ucuz ama güveni düşürür (tasarım seçimi, kaynak yok).
- Kredi hesabın aylık ücreti üzerinden okunur; büyük hesap daha büyük mutlak TL/$ kaybettirir, böylece "kilit müşteri" doğal olarak pahalıdır.
- Çeyreklik ölçüm (Slack) üst kademe hesaplar için "tek kötü haftayı yutar" kuralına ilham olabilir.

## 2. E-ticarette kesinti/ödeme hatası telafisi

### Bulgular
- Coupang (Kore, yakın tarihli yükseltme hatası): iptal olan siparişe 5.000 won Coupang Cash, hiç geçmeyen siparişe 1.000 won kupon; satıcılara ayrı telafi; küçük işletmeler bunu gerçek zararın çok altında buldu. https://biz.heraldcorp.com/article/10898786
- Cabela's: kesinti sonrası kupon yalnız 1 gün geçerliydi, çoğu müşteriye ulaştığında süresi dolmuştu; "telafi başarısızlığı" diye eleştirildi. https://www.alertra.com/blog/cabelas-offers-discount-compensation-fail/
- Target 2014: ödeme kesintisinde mağazada "özür kuponu"; müşteri çoğunlukla olumlu, ama kurallar esnetildi. https://couponsinthenews.com/2014/06/16/target-glitch-triggers-coupon-bonanza
- Danışmanlık önerisi (satıcı blogu, standart değil): 1 günlük %10-%20 indirim kodu ya da 50$ alışverişte 10$ indirim. https://www.alertra.com/blog/making-amends-episode-website-downtime/
- Akademik: telafi büyüklüğü eşiği otelde ortalama ~%80'i rezervasyon fiyatı (1.204/1.500 SEK) çıktı; 633 SEK (~%42) verilenler hâlâ daha az memnun, 1.774 SEK (~%118) daha memnundu. Bağlama özgü. https://www.emerald.com/insight/content/doi/10.1108/JSTP-02-2023-0029/full/html (özet arama sonucundan; makale gövdesi okunmadı)
- Online hizmette "recovery paradox" yalnız küçük "memnun edilmiş" grupta görülüyor; yazarlar üstün telafiyi hatasız hizmetin yerine koymamayı söylüyor. https://wrap.warwick.ac.uk/68253
- Hatasız olay sonrası satış: ölçek sabit değil; Coupang örneğinde telafi etkilenen sipariş değerinin düşük bir kısmı (5.000 won ~ 3-4 USD) (kaynak yok, model bilgisi: kur yaklaşık).

### Oyun için çıkarım
- B2C "Telafi et": kupon büyüklüğü = etkilenen kullanıcı sayısı x kişi başı küçük kupon. Kişi başı aralık: etkilenen siparişin %10-%20'si (hasarsız) ile tam iade (iptal olduysa). Sabit $4.000 yerine `affected_users * ort_sepet * 0.10..0.20`.
- Süreli kupon tuzağı: çok kısa geçerli kupon "geri tepme" olarak modellenebilir (ör. 24 saatlik kupon etkisi yarıya iner).
- Olumlu sürpriz sınırlı: aşırı telafi (>%100) yalnız en kârlı müşteri segmentinde anlamlı; genel kitlede kayıp azalması azalan getirili olmalı.
- Satıcı tarafı (E fazına bağlı) ayrı telafi gerektirir; kapsam dışı, yalnız not.

## 3. Kesinti/hata yorumlarının B2C kullanıcı kaybı

### Bulgular
- Anket (Kinsta, vendor): büyük alışveriş etkinliğinde yavaşlama/kesinti yaşayanlar %49,7; çöken siteye "bir daha dönmem" diyen %31,7. https://kinsta.com/?p=220915 (beyan edilen niyet, ölçülmüş davranış değil)
- Ödeme hatası: hata mesajı alınca sepeti bırakacağını söyleyen %49; hemen rakibe geçecek %17 (Black Friday alıntısı). https://retailtouchpoints.com/features/news-briefs/costco-thanksgiving-day-site-outages-cost-an-estimated-11-million
- Costco Şükran Günü kesintisi tahmini 11 milyon $ kayıp; aynı kaynak.
- Satıcı blogu iddiaları (doğrulanamadı): kesintide rakipten alma 3x, olumsuz yorum 2,5x, dönüşüm %10-20 düşüş. https://ecommercefastlane.com/the-hidden-cost-of-website-downtime-thats-quietly-crushing-shopify-stores/
- Karşı görüş: kesinti nadirse ve site normalde güvenilirse etki söylenenden çok daha küçük. https://unixdaemon.net/online/non-intuitive-downtime-and-possibly-not-lost-sales
- Uygulama puanı: 4,0 yıldız altında indirmelerde keskin düşüş, kabaca yarıya; yöntem belirsiz. https://unstar.app/blog/how-negative-reviews-affect-app-downloads-data-study (arama özeti, sayfa okunmadı)
- Aramalarda kesintiye özgü hakemli kalıcı kayıp yüzdesi bulunamadı; tüm sayılar yön gösterici (belirtildi).

### Oyun için çıkarım
- Kaba bölme önerisi (kalibrasyon başlangıcı, doğrulanmadı): tam kesintide anlık kitle kaybı etkilenen aktif kullanıcının %3-%8'i; ödeme hatasında %5-%15 sepet kaybı (o gün); kalıcı iz küçük (%1-%3), niyet anketlerindeki %17-%32 gerçek davranışa ~1/5-1/10 oranında inmeli (model bilgisi, anketler beyan niyeti).
- Zamanla düzeltilebilen hata için "düzelene kadar haftada %2" kararınla uyumlu: kümülatif kayıp süresine orantılı; üst sınır koy (ör. 8 hafta).
- Yorum fırtınası: puan eşiği ~4,0 yıldız (yalnız vendor iddiası) "keskin eşik" olarak kullanılabilir; yeni kullanıcı edinme düşüşü ile kalıcı kayıp ayrı sayaç olsun.
- Nadir olay kuralı: oyuncunun geçmiş güvenilirliği yüksekse (uzun süre kesintisiz) kayıp katsayısı düşsün (karşı görüşle uyumlu).

## 4. Olay sıklığı tasarımı

### Bulgular
- RimWorld Wiki (eski sürüm değerleri, B18 öncesi olabilir): Cassandra minDaysPassed 11, on/off fazları 4,6 ve 6 gün, minSpacingDays 1,9, Misc mtbDays 4,8; yılda ~8,5 büyük tehdit. Randy mtbDays 1,35, maxThreatBigIntervalDays 13, ThreatBig ağırlık 1,4, ThreatSmall 0,6, raid boyutu çarpanı 0,5-1,5. Phoebe on/off 8/8 gün, mtbDays 4,8, minDaysPassed 13. https://www.rimworldwiki.com/wiki/Cassandra, https://www.rimworldwiki.com/wiki/Randy, https://rimworldwiki.com/wiki/Phoebe_Chillax (arama özeti; forum uyarısı: eski alan adları artık yok, yetkili dosya Storytellers.xml)
- Girdiler: koloni zenginliği, bina zenginliği, nüfus, son büyük olaydan beri geçen süre, son ölüm/ağır yaralanma. https://rimworldwiki.com/wiki/Storyteller
- Zorluk ölçeği ayrı: tehdit puanı %10 ... %220; adaptasyon hızı %0-%100; "adaptation" hasar alınca düşer (koruma/pity). Başlangıçta sabit "intro threats" (tek erken koruma). https://rimworldwiki.com/wiki/Storyteller_settings
- Nüfus niyet eğrisi: 0 kişide 8,0; 1'de 2,0; 5'te 1,0; 9'da 0,4; 12'de 0; 20'de -1 (ters orantılı: küçük koloni yardım olaylarını çok alır). Aynı sayfa. (kullanıcı analizi, kesin değil)
- Wealth-independent mod: azami tehdide 12 yılda gelinir (1-20 ayarlı). Aynı sayfa.
- Crusader Kings: birincil dokümana ulaşılamadı. Forum: yıllık pulse (`on_yearly_pulse`) tetikler, olaylara cooldown ve rastgele gecikme eklenerek aynı anda iki olay engellenir; MTTH (mean_time_to_happen) olay başına ortalama süre. https://admin-forum.paradoxplaza.com/forum/threads/how-to-handle-maintenance-events.1255362 ; modcu notu: https://steamcommunity.com/sharedfiles/filedetails/changelog/2975514448?p=15 (MTTH ayrıntısı doğrulanamadı; model bilgisi: MTTH üstel dağılımdır, olasılık = 1 - 0,5^(gün/MTTH) gibi, kaynak yok.)
- Frostpunk: arama yapılmadı, doğrulama yok (kaynak yok, model bilgisi: ölçekli "hope/discontent" eşiklerine bağlı senaryo olayları).

### Oyun için çıkarım
- Önerilen model: "taban + rastgele + hamle": min boşluk 4 hf (sert), sonra her hafta tehlike olasılığı p_hf = base x (1 + katsayılar); rastgele aralığı sapma için `gap = 4 + Exp(mean ~4)` ile 8-10 hf de çıkar. RimWorld'deki Cassandra "min spacing + on/off faz" ile eşdeğer.
- Girdiler zaten bizdeki tasarım ile eşleşiyor (sunucu kademesi, doluluk, açık hata, hatalı sürüm) -> RimWorld "zenginlik/nüfus" gibi; ters yön eşlemesi (küçük şirkette yardım, büyükte baskı) için nüfus-eğrisi benzeri tablo.
- Pity/koruma: son olay ağır hasar verdiyse (kasa/memnuniyet düşük) bir sonraki aralığı +%50 uzat ("adaptation hasar alınca düşer"); ilk 20 hf için sabit "tanıtım" olayı ya da hiç olay yok.
- Aynı anda iki olay olmasın (CK modcu rastgele gecikmeleri); küçük olayları ayrı kategori yap (ThreatSmall/Big benzeri ağırlık) ama aynı min boşluğu paylaşsın.

## 5. Uzun koşuda kart tekrarı

### Bulgular
- Reigns (ikincil kaynak): "çanta" modeli: önce duruma uymayan kartlar (ör. evlilik yoksa kraliçe kartı), sonra yakın zamanda oynanmış kartlar elenir. 500+ kart, açıldıkça desteye kalıcı eklenir; yine de oyuncular aynı kartlara çarptığını söylüyor (tekrar hissi). https://www.construct.net/en/users/344891/moonpunk/forum-posts/page-27 ; https://techraptor.net/content/reigns-review-addicted-death ; https://indie-hive.com/reigns/ (birincil Gamasutra yazısı okunmadı)
- Slay the Spire: olaylar perde başına havuzlu, bazıları birden çok perdede; "shrine" (nadir) ve "one-time" havuzları ayrı; one-time olay koşu başına en fazla bir kez; shrine perde değişince yeniden gelebilir. https://slaythespire.wiki.gg/wiki/Events (seçim ağırlıkları kaynakta yok)
- Genel teknik: az görülene ağırlık verme, art arda aynı kartı dışlama, 1 kartlık dejenere desteye dikkat. https://help.boomlearning.com/support/solutions/articles/16000040506-what-cards-do-the-students-see- ; https://answers.launchpad.net/mnemosyne-proj/+question/72233 (flashcard örnekleri, oyun değil)
- Crusader Kings: olay başına cooldown ve zincir/koşul bayrakları (forum, bkz. B4); ayrıntı doğrulanamadı.
- Alexander/Nerial röportajı bulunamadı; yalnız Gaming Trend'de yazım yaklaşımı: karakter başına temel kart seti, genişleterek. https://gamingtrend.com/interviews/one-night-with-the-king-reigns-developer-interviewed-on-games-success/

### Oyun için çıkarım
- Katman 1: koşu boyu "görülme sayacı" (kayıtta); ağırlık = `base / (1 + 2 x seen)`; 3. gösterimden sonra çok seyrek (`w x 0,1`), "tekrar kapısı" havuz boyu ile ölçeklenir.
- Katman 2: aynı kart için cooldown süresi = havuz boyuna göre (örn. havuz N kart, hafta başı 0,35 olasılık; ~20 yılda ~364 olay-tetik olasılığı -> havuz >= 120 kart ya da kart başına varyantlar, ortalama <=3 gösterim); hedef: 4. görünüm yok.
- Katman 3: yapısal çeşitlilik: rol x aşama x hat varyantı (Reigns durum-süzgeci + shrine/one-time ayrımı gibi); "tek seferlik" kartlar (one-time) ve "tekrarlanabilir" kartlar ayrı havuz.
- Kayıt: görülme sayacı, son görülme haftası ve one-time bayrağı kayıtta tutulmalı (resume sonrası tekrar tetikleme riski; kaynak yok, tasarım gereği).
