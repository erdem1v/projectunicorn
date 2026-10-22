# C fazı web araştırması

Arama sayısı: 18 (WebSearch; biri alan filtresi hatasıyla düştü) + 9 WebFetch. WebSearch çalıştı.

Sınırlar (dürüstlük notu):
- Startup Company wiki sayfası (startupcompany.fandom.com/wiki/Servers) WebFetch'te HTTP 402 verdi; içeriği yalnız arama özetinden ve Steam tartışmalarından aldım. Wiki tablosundaki rakamlar özet düzeyinde, sürümü belirsiz (forum 2018-2020).
- Software Inc. sunucu/barındırma mekaniği için hiçbir kaynak bulunamadı. Aşağıda uydurma yok.
- Kurumsal barındırma şartları (SOC2 maliyeti, ayrılmış ortam fiyatı) için güvenilir kaynak zayıf; bulunanlar satıcı blogları.

---

## 1. Startup Company sunucu sistemi (Software Inc. ve benzerleri)

### Bulgular
- Oyunun mağaza açıklaması sunucuyu büyümenin şartı yapar: trafik büyüdükçe sanal sunuculardan kendi barındırma merkezine geçilir; "kararlı sunucu olmadan web sitesi yok". Maliyet, kapasite sınırı ya da kesinti ayrıntısı verilmiyor. https://store.steampowered.com/app/606800/Startup_Company/
- Wiki özeti (arama sonucu): 3 sunucu türü (web, database, cache), her biri 3 boyutta. Tabloda çıktı, raf boşluğu (U), alış bedeli, kurulum bedeli ve aylık güç maliyeti var. Örnek: küçük web sunucusu 10.000 alış, 375 güç; 8U web sunucusu 800.000 alış, 2.100 güç. https://startupcompany.fandom.com/wiki/Servers (doğrudan açılamadı, arama özeti)
- Wiki örnek kurulumu: iki raf yaklaşık günlük 175 dolar işletme gideri; benzer çıktı için barındırma (hosted) seçeneği günlük yaklaşık 900 dolar. Yani kendi sunucuna geçmek gün başına ucuz, ama başta büyük sermaye ister. Aynı kaynak (arama özeti).
- Çıktı ekseni "CU" (üretilen kapasite birimi). Geliştirici Jonas Hovgaard doğruluyor: "Lowest value sets the produced CU." Web, database ve cache'in en düşüğü CU'yu belirler. https://steamcommunity.com/app/606800/discussions/0/1727575977542193508/
- En zayıf halka örneği: 10k web + 10k cache ama 100 database kapasitesi, her üçünde yaklaşık 100 üretir; kalan israf. Raf başına sunucu ve soğutucu yuvası sınırlı; büyük sunucu daha çok üretir, daha pahalı. https://steamcommunity.com/app/606800/discussions/0/3216031607500510540/
- Arayüz: sunucu odası görünümünde alt şeritte üç değer (web/database/cache) ve her tür için "yeşil/sarı/ünlem" durumu; sarı olan geride, en büyük yeşile eşitlenmeli. Raf sayfası her sunucunun gelirini gösterir. https://steamcommunity.com/app/606800/discussions/0/1750106661698897815/ ve https://steamcommunity.com/app/606800/discussions/0/1744521326156951129/
- Oyuncu raporlu örnekler: 4 büyük raf soğutuculu kurulumda web/db/cache 20.000'er, fiyat 2.584.000, 380.000 CU, 181.000 W; küçük kurulum 5.000'er, fiyat 611.500, 70.000 CU, 44.000 W. https://steamcommunity.com/app/606800/discussions/0/1741090651244950115/
- Saat hızı (overclock) %100/125/140/200 seçilebilir; yük arttıkça sıcaklık (22-42 derece) yükselir; soğutucu rafa yer kaplar. 4U/8U/"fusion" (üçü bir arada) sunucu seçenekleri var; fusion "en kolay" yol diye anılıyor. https://steamcommunity.com/app/606800/discussions/0/1744521326156951129/
- Oyuncu çözümü: dengeli bir kule kur, "duplicate" ile çoğalt (Shift ile bol bol). Yani oyuncu karar yükü: oran bulmak bir kez, sonra kopyalamak. https://steamcommunity.com/app/606800/discussions/0/3216031607500510540/
- Bulunamayan: kullanıcı sayısının sunucuya nasıl eşlendiği, kesinti/aşım cezası. Forum dizileri yalnız denge ve soğutmayı konuşuyor; kesinti hiç geçmiyor. (Kaynak yok, eksik.)
- Software Inc.: sunucu mekaniği hakkında kaynak bulunamadı. Mağaza verisi: 94% olumlu, ~7.700 yorum. https://edge-test.steampulse.org/game/362620 (yalnız puan)
- Gerçek dünya karşılığı: kapasite "en kötü durum yükü ölçülerek" belirlenir; Amazon GameLift hesaplayıcısı bilinmiyorsa örnek başına 20 oturum varsayar. https://docs.aws.amazon.com/gameliftservers/latest/developerguide/gamelift-calculator.html

### Oyun için çıkarım
- Startup Company'nin sade çekirdeği: tek sayı (CU) ve üç bileşenin en düşüğü. Bizde 3 kademe + doluluk + autoscale bunun yanında ağır. Öneri: tek "kapasite" sayısı (kademe başına sabit kullanıcı/istek), tek kademe yükseltme düğmesi.
- Oyuncuya her zaman "darboğaz hangisi" gösterilsin (yeşil/sarı); kararı veren bu tek bakış. Doluluk çubuğu tek, ölçekleme otomatik değil oyuncu eylemi.
- Kesinti Startup Company'de yok; bizde aşım bedeli olacaksa tek net mekanik gerekir (örn. doluluk %100 üstü haftada memnuniyet düşüşü / kesinti olasılığı), çünkü referans oyun bu konuda bize örnek vermiyor.
- Sermaye (alış) mi aylık gider mi ikilemi oyunun asıl kararı: hosted pahalı-esnek, kendi sunucu ucuz-sermayeli. Bunu tek seçim olarak koruyabiliriz.

---

## 2. Gerçek SaaS barındırma maliyeti birimi ve kurumsal şartlar

### Bulgular
- Mimari: paylaşımlı (pool) müşteri başına kabaca 50-500 dolar/ay, ayrılmış (silo) 500-5.000 dolar/ay, hibrit (bridge) 100-1.000 dolar/ay. Tek satıcı sayfası, yöntem yok; kaba say. https://www.perfectiongeeks.com/comparison/multi-tenant-vs-single-tenant-saas
- Yaygın düzen: standart müşteri paylaşımlı altyapıda, kurumsal müşteri ayrılmış yığında. https://www.techloy.com/multi-tenant-vs-single-tenant-saas-which-one-fits-your-product/
- Tek kiracılı kurulum özelleştirme, veri yerleşimi ve uyumluluk (HIPAA, GDPR, SOC 2 Type II) isteyen kurumsal uygulamalara uygun, daha pahalı. https://virima.com/blog/single-tenant-vs-multi-tenant
- SOC 2 Type II denetimi tipik olarak yaklaşık 15.000 dolar civarında (özet kesik, tam aralık doğrulanamadı). Aynı arama sonucundaki satıcı sayfası (perfectiongeeks).
- Barındırmanın gelire oranı: olgun SaaS'ta kabaca %5-10; hesaplama-ağır üründe %20 üstü "fiyat çok düşük" işareti; küçük ölçekte %12-22 iddiası (doğrulanamadı, düşük güven). https://www.saastr.com/is-there-a-benchmark-for-of-revenue-that-an-enterprise-saas-business-should-spend-on-systems-infrastructures-like-aws-or-the-equivalent ve https://skalingventures.substack.com/p/benchmark-your-saas-firm-with-a-few
- Brüt marj hedefi %70-80+; COGS barındırma, destek ve hizmetleri içerir. https://www.alexanderjarvis.com/what-is-gross-margin-in-saas-how-to-improve-it/
- SLA: %99,9 = ayda yaklaşık 43 dk kesinti hakkı, %99,99 = yaklaşık 4,4 dk. %99,9 çok bölgeli yedeklilik ve 7/24 uyarı ister; %99,99 otomatik yük aktarımı ister. https://pingping.io/guides/uptime-sla-explained
- Tipik SLA kredisi: %99,9 altı aylık ücretin %10'u, %99 altı %25, %95 altı %50. Hak talebi zahmetli olursa müşteri kredisini alamaz. Aynı kaynak.
- Birim notu: bulunan kaynakların hiçbiri koltuk/istek başına barındırma birimi için otoriter sayı vermedi. İstek başına maliyet, AWS Partner Network'ün kiracı başına maliyet yazısında tartışılıyor ama sayı çıkarmadım. https://aws.amazon.com/blogs/apn/calculating-tenant-costs-in-saas-environments

### Oyun için çıkarım
- Gerçekçi ve sade birim: müşteri (kiracı) başına aylık sabit pay + ölçek payı. Paylaşımlı B2C/küçük müşteri için kullanıcı/istek, kurumsal için "ayrılmış ortam" tek kalem (müşteri başına yüksek aylık bedel).
- Kurumsal şart akışı için gerçekçi üçlü: SOC2 (tek seferlik büyük harcama + yıllık), ayrılmış ortam (müşteri başına aylık bedel), SLA (kesintide aylık ücretin %10/25/50'si kredi). Şart yerine gelmezse bedel = kredi veya yenilememe, rakamlar hazır.
- Hedef oran referansı: barındırma gelirin %5-10'u olgun, %12-22 erken. Oyun dengesi bu bandı izlerse gerçekçi görünür.

---

## 3. B2B yıllık sözleşme, MRR/ARR, yenileme ve sahiplik

### Bulgular
- ARR sözleşme değerinin yıllıklandırılmasıdır; üç yıllık sözleşme yılda üçte bir sayılır. Yıllık peşin nakit ARR değildir: peşin 1.200 dolar yine ayda 100 dolar MRR'dir. https://cut-the-saas.com/guides/mrr-vs-arr ve https://dodopayments.com/blogs/mrr-vs-arr
- Karışık faturalamada MRR x 12 aşırı raporlar; yalnız herkes aylık faturalanıyorsa doğru. https://chargeover.com/blog/mrr-vs-arr
- ChartMogul 2025: yıllık faturalamanın ARR payı 3-8 milyon dolar ARR bandında en yüksek (~%47), 15-30 milyon bandında ~%28. Yıllık planlar daha iyi tutundurma ile ilişkili. https://chartmogul.com/reports/saas-billing-report/
- Fiyat artışı: tipik %3-5 yıllık (sabit yüzde ya da CPI); satıcı varsayılanları daha yüksek: Salesforce %8-10, "yüzde 80'den çok kurumsal satıcı" %7-15 (metodoloji yok). Tavan: "en düşüğü: liste artışı (en çok %5) ya da CPI, azami %3". Sözleşmelerin yalnız %29'unda otomatik yenileme zam tavanı var. https://redresscompliance.com/workday-renewal-cost-increase.html ve https://www.cloudnuro.ai/blog/saas-price-protection (hepsi alıcı danışmanlığı/satıcı içeriği, denetlenmiş veri değil)
- Bileşik etki örneği: %8 tavansız artış 5. yılda 10 milyonluk sözleşmeyi 14,7 milyona, %3 tavan 11,3 milyona çıkarır. https://redresscompliance.com/sap-uplift-cap-benchmark-what-buyers-get
- Yenileme sahibi tek standart yok; üç model: (1) satışı kapatan AE yenilemeyi ve genişlemeyi sahiplenir, CSM günlük değeri; (2) özel account manager (en yaygın model, SaaS'ta "modal"); (3) CSM sahiplenir (en az tercih edilen; yalnız erken aşamada). CS ekiplerinin yalnızca %11,8'i yenilemeden tek başına sorumlu, ~üçte ikisi bir ölçüde sorumlu. https://www.customersuccesscollective.com/who-owns-customer-renewals/ ve https://inmoment.com/blog/who-should-own-renewal-customer-success-experts-share-the-pros-cons-of-3-different-models/
- Dördüncü model: yüksek hacimli küçük müşteri için "renewal manager"; eşik üstü sözleşmeler için account manager. https://revengine.substack.com/p/who-should-own-the-renewal
- AM ticari tarafı (gelir, yenileme), CSM sonucu ve kullanımı sahiplenir; CSM benimseme ve genişleme sinyallerini AM'e verir. AE sahipliğinde AE'lerin CSM'yi hesaptan "engellemesi" riski anılır. https://churnzero.com/blog/how-to-optimize-your-renewal-process-when-sales-owns-it/
- Yenileme bildirim süresi (örn. 90 gün) için piyasa normu kaynağı bulunamadı.

### Oyun için çıkarım
- Gösterim: yıllık sözleşme için panelde MRR (= yıllık / 12) birincil, ARR ikincil; yıllık peşin nakdi ayrı "nakit" satırında ("sözleşme değeri / yenileme tarihi" sütunu). Böylece gelir ile nakit karışmaz.
- Yenileme sahibi öneri: küçük hesap CSM/otomatik, büyük hesap (eşik üstü) account manager = oyunda mevcut satış temsilcisi kartı; yıldız seviyesi pazarlık (artış tavanı, indirim) etkisine bağlanır. Gerçekçi ve sade bir kural: satışçı yıldızı ne kadar yüksekse yenilemede kabul edilen zam payı o kadar yüksek (%3-5 bandı baz, tavan %8-10).
- Yenileme penceresi (ör. bitişten 8-12 hafta önce) mail/kart olarak düşsün; zam teklifi tek seçim: tavanlı %3 / standart %5 / agresif %8-10 (agresifte kayıp riski).

---

## 4. Rakip analizi: oyunlarda ve gerçek PM'de

### Bulgular
- Big Ambitions rakip ekranı karara bağlı bilgi verir: rakip başına işletme sayısı, haftalık gelir, ana mahalle, işletme başına haftalık gelir, sahip olunan gayrimenkul, rekabet durumu. Örnekler: 28 işletme / ~6,05 milyon dolar/hafta (Midtown); 21 işletme / ~1,8 milyon. https://www.whisperofthehouse.com/big-ambitions/rivals-guide
- Tetikleyici: oyuncu rakibin bölgesine girince uyarı (yalnız bilgi), baskıyı bilerek artırınca "Active Rivalry". Etki yavaş: bir mağaza 25+ işletmeye karşı sınırlı. Rakip binası satın almayı engelleyebilir; devralma pazarlığı örneği: 139-180 bin dolar ilan, 150/155 bin reddedildi, 160 bin kabul. Aynı kaynak.
- Karar kuralları (oyuncu stratejisi): her seferinde tek rakip hamle ekle, hedefin gelirini ve kendi kârını karşılaştır; kendi kaybın rakibin kaybından büyükse geri çekil (rakibi 5.000 azaltıp kendi 30.000 kaybetmek kazanç değil). Aynı kaynak.
- Big Ambitions rakipleri sektöre bağlı: bir sektörde ana rakip, oyuncu o sektörde üç mağaza açmadan aktif olmaz. https://gameshorizon.com/guides/big-ambitions-1-0-rivals-explained-how-they-work-how-to-beat-them/ (arama özeti)
- Startup Company, Software Inc., Game Dev Tycoon için rakip-ekran mekaniği hakkında kaynak bulunamadı. Software Inc. mağaza tanımı: "simüle edilmiş rekabeti yenip işletmelerini devral". https://alternativeto.net/software/software-inc (arama özeti)
- Gerçek PM: rekabet analizi birkaç somut karara iner: fiyatlandırma ve konumlandırma, yol haritası (rakipte olup bizde olmayan boşluklar), satış battlecard'ları, giriş/devralma kararları. https://www.launchrock.com/library/expert-advice/competitive-analysis
- Win/loss görüşmeleri ana girdi: kaybedilen anlaşmalarda alıcıya kimleri değerlendirdiği ve karar ölçütleri sorulur (satışçının dediğinden farklı çıkabilir). Battlecard yalnız kayıp analizinde, RFP'de ya da müşteri konuşmasında geçen birkaç rakip için. Aynı kaynak ailesi: https://skills.cat/skills/alirezarezvani/claude-skills/competitive-intel
- Başarısızlık kalıpları: kimsenin okumadığı kapsamlı belge, bayat veri, yankı odası; öneri: üç aylık güncellenen canlı belge. Aynı kaynak.

### Oyun için çıkarım
- Rakip ekranı "iş" olmasın, karar tetiklesin: her rakip satırı yalnız iki-üç sayı (fiyat, kalite/özellik seviyesi, tahmini müşteri payı) + bir eylem sonucu bağlansın: fiyatı değiştir, özellik/ürün kartı aç, hedef müşteriyi seç, kampanya.
- Bilgi bedelli ve bildirimli olsun (Big Ambitions gibi): rakip ancak aynı segmente girince ya da kaybedilen bir müşteriden sonra "neden kaybettik" kartı (win/loss) düşsün; sürekli açık bir tablo değil olay tabanlı sinyal.
- Her sinyal bir tek karara bağlansın: fiyat boşluğu görülürse yenileme/fiyat teklifi, özellik boşluğu görülürse sprint önceliği. Sinyalin karşılığı yoksa göstermeyin.
- Geri çekilme kuralı oyuna yansıtılabilir: fiyat savaşı kendi marjını rakibinkinden çok yiyorsa panelde uyarı.
