# E_ARASTIRMA: Pazaryeri ekonomisi web araştırması

Arama sayısı: 12 (WebSearch çalıştı; hepsi "standard" mod. WebFetch ile doğrulama yapılmadı.)

Uyarı: Bulguların çoğu satıcı blogu ve araç sağlayıcı sayfalarından geliyor. Resmî oran tablosu değiller ve kendi aralarında çelişiyorlar. Oyunda sayıları "aralık" olarak kullanın, tek nokta olarak değil. Sayısal Türkiye verileri özellikle zayıf.

---

## 1. Komisyon oranları

Bulgular
- Trendyol (üçüncü taraf blog): Giyim %28, Ev-Yaşam %28, Elektronik %6-25, Ayakkabı-Çanta %21-23, Süpermarket %8-17. Oran satıcı performansına, geçmiş satışa ve yeni/marka satıcıya göre değişiyor. Genel aralık bir kaynakta %10-25, başka bir kaynakta %8-20 (çelişkili).
  https://www.tsoft.com.tr/blog/current-trendyol-commission-rates ,
  https://www.tsoft.com.tr/blog/what-you-need-to-know-about-selling-on-trendyol ,
  https://ecosire.com/blog/trendyol-odoo-integration-turkey
- Hepsiburada: genel %5-22, üç kademe. Düşük %5-10 (elektronik, beyaz eşya, telefon, bilgisayar, kitap, konsol). Orta %10-16 (ev, otomotiv, hırdavat, spor). Yüksek %16-22 (moda, ayakkabı, çanta, kozmetik, bebek giyim). Kampanyalarda indirimli oran olabilir. KDV (%20), hizmet bedeli ve kargo üstüne ekleniyor, yani gerçek maliyet komisyondan yüksek.
  https://www.tsoft.com.tr/blog/hepsiburada-commission-rates-2024 , https://ecosire.com/blog/hepsiburada-odoo-integration-guide
- Amazon referral fee: kategoriye göre %6-45 (kaynak ortalaması ~%15; tipik %8-15). Giyim ~%17, evcil hayvan ~%25 bir kaynakta, cihaz aksesuarı %45 bir tabloda. Bazı kategorilerde fiyata göre kademeli. FBA dahil etkin maliyet 30 USD'lik üründe ~%36.
  https://www.saasant.com/blog/what-is-amazon-referral-fee/ , https://litcommerce.com/blog/amazon-seller-fees/ , https://ecomcalctools.com/amazon-vs-etsy-fee-calculator/
- eBay final value fee ~%10,9-14,9 (bir kaynakta %13,25). Etsy işlem ücreti %6,5 + 0,20 USD ilan ücreti + ödeme işleme %3 + 0,25 USD. Aynı 30 USD'lik örnekte etkin maliyet Etsy ~%11, eBay ~%13.
  https://ecomcalctools.com/blog/category/platform/ , https://craftybase.com/blog/why-etsy-fees-are-so-high
- Genel sezgi (tek blog): sağlıklı take rate %10-30; çok düşükse iş modeli yürümez, çok yüksekse satıcı rakibe gider.
  https://upgrowth.in/?p=50581
- Mercado Libre: aramada işe yarar kaynak çıkmadı. (kaynak yok, model bilgisi) Kategoriye göre kabaca %10-20 bandı + sabit ücret.
- Yeni/küçük pazaryerinin başlangıç oranı için doğrudan kaynak bulunamadı. (kaynak yok, model bilgisi) Yeni platformlar genelde %0-8 ile başlar veya ilk dönem muaf tutar; kademeli oran (satıcı sattıkça düşen oran) satıcıyı tutmak için yaygın: https://dev.to/mercur/marketplace-commission-structure-types-and-how-to-set-them-428p
- Steam örneği (oyun mağazası): ilk 10M USD'de %30, sonra %25, 50M üstünde %20. Epic: ilk 1M USD'de %0, sonra %12. Yani hacimle düşen kademe standart. https://respawn.outlookindia.com/gaming/gaming-news/epic-launches-web-based-stores-challenging-app-store-economics

Oyun için çıkarım
- Kategoriye göre taban oran tablosu kullan: düşük marjlı (elektronik, market) %5-10, orta (ev, spor) %10-16, yüksek (moda, kozmetik) %16-28. Oyuncunun kaydırıcısı bu tabanın üstünde bir çarpan ya da doğrudan oran olabilir.
- Başlangıç önerisi: v1 öncesi/yeni pazaryerinde varsayılan %5-8, "sektör ortalaması" çizgisi %12-15 olarak önizlemede gösterilsin.
- Etkin maliyeti (komisyon + sabit ücret + ödeme işleme) satıcı memnuniyetine bağla, yalnızca başlık komisyonuna değil.
- Hacimli mağazaya kademeli indirim, "tutma" kolu olarak eklenebilir.

---

## 2. Komisyon artışına tepki

Bulgular
- Etsy 2022: işlem ücreti %5 -> %6,5 (11 Nisan 2022, 2018'den beri ilk artış, oran olarak +%30). Hafta süren grev: 14.000+ satıcı dükkân kapattı (TechCrunch), organizatör bunun ~5,3 milyon aktif satıcının küçük bir kısmı olduğunu kabul etti; 48.000+ imzalı dilekçe.
  https://techcrunch.com/2022/04/11/etsy-strike-sellers-transaction-fees , https://www.npr.org/2022/04/11/1091123928/etsy-strike-2022 , https://retailbrew.com/stories/2022/04/15/etsy-sellers-on-the-platform-s-transaction-fee-hikes
- Sonuç (Etsy Q2 2022): aktif satıcı 7,4 milyon (+%41,5 yıllık), aktif alıcı 93,9 milyon (+%3,8), pazaryeri GMS -%6, gelir +%10,6 ve artışın nedeni olarak ücret artışı gösterildi. Take rate %17,4 -> %19,3 (+190 baz puan). Yani satıcı kaybı görülmedi, ancak satıcı sayısı artışında başka etkenler (Depop/Elo7 ve organik büyüme) karışıyor, nedensellik kanıtlanmış değil.
  https://investors.etsy.com/news-events/press-releases/detail/54/etsy-inc-reports-second-quarter-2022-results , https://www.fool.com/investing/2022/08/02/is-it-too-late-to-buy-etsy-stock
- Amazon: Marketplace Pulse 2026 satıcı anketi (181 satıcı): %49'u marj kaygısı olarak pazaryeri ücretlerini, %46'sı reklam harcamasını gösteriyor. Ücretlerden en çok şikâyet edenlerin yalnızca %24'ü Amazon payını azaltıyor, %42'si artırıyor ("paradoxical dependence"). Aktif satıcı sayısı Ocak 2025 584.000 -> Mart 2026 500.000 (Amazon bu verinin bir kısmına itiraz etti).
  https://www.marketplacepulse.com/articles/the-paradoxical-dependence-of-amazon-its-sellers , https://www.modernretail.co/technology/why-2024-was-the-year-sellers-became-less-loyal-to-amazon/
- Çok kanallı satış: 2022 Capterra anketinde yalnızca Amazon'da satanların %99'u 2023'te çeşitlendirmeyi planlıyor (küçük örneklem). https://www.modernretail.co/technology/why-more-amazon-sellers-are-looking-to-bring-their-products-to-rival-marketplaces-in-2023
- Kaba esneklik çıkarımı (bu rapor yorumu, ölçülmüş değer değil): trafiği güçlü platformda +%30 oran artışı hemen çıkışa değil, protestoya ve çok kanallılığa yol açıyor; satıcı kaybı yavaş (aylar-yıllar) ve ilan/kâr azalması şeklinde geliyor. Zayıf trafikli platformda esneklik çok daha yüksek olmalı. (model bilgisi)

Oyun için çıkarım
- Tepki iki katmanlı olsun: anlık memnuniyet düşüşü (protesto, "grev" olayı) + gecikmeli çıkış/ilan düşüşü. Çıkış eşiği platformun alıcı trafiğiyle ölçeklensin (trafik güçlüyse satıcı katlanır).
- Küçük/yeni pazaryerinde komisyon artışı keskin cezalandırılsın, büyük trafikte yumuşak; "bağımlılık paradoksu" oyuncuya ters bir ödül verir ama sınırı olmalı (memnuniyet çok düşerse çıkış).
- Artış hızı ceza belirlesin: tek seferde +%30 ayrı bir olay tetikler, kademeli +1-2 puan daha az tepki alır. Önizleme "tahmini ayrılacak mağaza" ve "memnuniyet etkisi"ni göstermeli.
- Satıcı değer algısı: artışa karşılık reklam/araç yatırımı (Etsy argümanı) varsa ceza azalsın.

---

## 3. Üyelik programları

Bulgular
- Amazon Prime: Prime üyeleri yılda ~1.100-1.200 USD, üye olmayanlar ~500-600 USD harcıyor (CIRP). Fark sepet büyüklüğünden değil sıklıktan geliyor: ortalama işlem tutarı neredeyse aynı. Eski Morgan Stanley verisi çok daha uçta (2.486 USD vs 544 USD). Fiyat uzun süre 99 USD/yıl, aylık 10,99 USD (eski veri); sonraki kaynak 139 USD yıllık. ABD'de 196 milyon üye (CIRP, Mart 2025 çeyreği; üye olarak alışveriş yapan kişi, ödeyen abone değil).
  https://cirpamazon.substack.com/p/amazon-prime-shoppers-outspend-the , https://cirpamazon.substack.com/p/amazon-prime-member-shopping-power , https://tinuiti.com/blog/amazon/amazon-prime/ , https://cirpamazon.substack.com/p/latest-figures-for-amazon-prime-and
- Walmart+: yıllık ~98 USD (Prime'dan ucuz); ABD'de ~21,4 milyon üye, ~%17 hane penetrasyonu (Morgan Stanley 2023), CIRP 25 milyon (2025, tahmin). https://investing.com/news/stock-market-news/morgan-stanley-survey-points-to-record-215m-walmart-members-432SI-3113514 , https://en.wikipedia.org/wiki/Walmart%2B
- Hepsiburada Premium: CEO'ya göre iki yılda 3 milyon abone. Fiyat Şubat 2026 zammıyla aylık 49,90 -> 69,90 TL, yıllık 360 -> 538 TL (bir kaynak 2026 olarak etiketledi, tarih doğrulanmadı). https://shiftdelete.net/hepsiburada-premium-kullanici-sayisi?amp=1 , https://www.donanimhaber.com/hepsiburada-premium-a-yuzde-49-zam-geldi--202234 , https://webrazzi.com/2022/07/04/hepsiburada-premium-uyelik-modelini-resmi-olarak-duyurdu/
- Trendyol Plus: aylık 75 TL (aynı haber); üye sayısı bulunamadı. https://www.donanimhaber.com/hepsiburada-premium-a-yuzde-49-zam-geldi--202234
- Türkiye programlarında alışveriş sıklığı etkisi için veri bulunamadı.
- İlke doğrulaması: Prime'ın etkisi "kilitleme" olarak değil sıklık artışı olarak görünüyor; üye olmayan kitle de yılda ~500-600 USD harcıyor. Yani üyelik temel alışverişi kilitlemiyor, ilkemizle uyumlu. (Aynı veride seçilim yanlılığı olabilir: sık alışveriş yapan kişi zaten üye olur; nedensellik kanıtlanmış değil.)

Oyun için çıkarım
- Üyelik etkisi = sipariş sıklığı çarpanı (~1,5-2x); sepet ortalaması aynı kalsın. Üye olmayan alıcı tam fiyatla alışverişe devam etsin.
- Fiyat önizlemesi: üye oranı (penetrasyon) fiyatla düşsün, ücretsiz kademede dönüşüm ~%15-20 civarı ayar aralığı olabilir (ABD Walmart+ %17 hane). Bu aralık oyun ayarı önerisidir, Türkiye verisi değil.
- Üyelik geliri küçük başlar, GMV'ye kıyasla ikincil kalır; asıl değer sıklık artışıyla komisyon gelirini büyütmesidir.
- Fiyat zammı (örnek: %40 artışı) üye kaybı olayı üretebilir, ama kaybolan alıcı pazaryerini bırakmaz, ücretsiz kademeye düşer.

---

## 4. Pazaryeri metrikleri

Bulgular
- Temel metrikler: GMV, take rate (gelir = take rate x GMV), aktif alıcı/satıcı, sepet ortalaması, tekrar alım. GMV tek başına yanıltıcı: sübvansiyonlu işlemler GMV'yi şişirir. 90 günlük tekrar alım oranı erken sağkalım göstergesi. https://www.lowcode.agency/blog/marketplace-analytics-kpis-full-guide , https://upgrowth.in/?p=50613 , https://www.infosysbpm.com/blogs/digital-business-services/key-metrics-to-measure-marketplace-management-services.html
- Likidite: ilk yılda aktif alıcı/ilan oranı büyüme rakamlarından önemli; tohum yatırımcıları eşleşme oranı ve kohort tekrar alımına bakıyor. İkincil bloglarda geçen eşikler (doğrulanmadı): işlem başarısı %90, arama->doluluk %60. https://hub.causo.ai/guides/raising-seed-marketplace-startup-2026
- Soğuk başlangıç: tek tarafı seç, sübvanse et veya elle doldur, dar bir coğrafya/kategoride likiditeyi kanıtla, sonra genişle. Önce arz sonra talep hibriti (Meesho). Uber'in sürücü garantisi arz sübvansiyonuna örnek. https://www.raftlabs.com/blog/two-sided-marketplace-cold-start , https://xplainerr.substack.com/p/how-uber-and-airbnb-cracked-the-marketplace
- Referans büyüklük: Etsy ~7,4 milyon satıcı / 93,9 milyon alıcı (yaklaşık 1:13), take rate ~%19 (ücret + reklam + hizmet dahil). Amazon.com ~500.000 aktif satıcı (Marketplace Pulse). Kaynaklar yukarıda.
- Erken evre tipik sayılar (kaynak yok, model bilgisi): ilk 12 ayda yüzlerce satıcı, binlerce alıcı; sipariş/alıcı/yıl 2-4; sepet ortalaması kategoriye göre.

Oyun için çıkarım
- Gösterilecek çekirdek: aktif mağaza, aktif alıcı, sipariş/alıcı, sepet ort., GMV = siparişler x sepet, take rate = gelir/GMV. Take rate %10-20 aralığında sağlıklı olarak işaretlensin.
- Likidite göstergesi ekle (mağaza başına alıcı veya ilan/alıcı eşleşmesi): düşükse alıcı tekrar alımı düşsün, mağaza memnuniyeti düşsün (sipariş azalır).
- Soğuk başlangıç: önce mağaza (arz) çekmek için düşük komisyon/muafiyet kolu, alıcı tarafı için kampanya; iki taraf eşik değerini geçince geri besleme döngüsü açılsın (v1 öncesi ve sonrası aşama farkı).
- Tekrar alım oranı hem kalite hem üyelik bağlantısı olarak kullanılabilir.

---

## 5. Tycoon/yönetim oyunlarında platform ekonomisi

Bulgular
- Big Ambitions ve Startup Company için pazaryeri/platform mekaniği içeren kaynak bulunamadı; iki arama da ilgisiz sonuç verdi. Resmî wiki veya yama notlarına bakılmadı. (kaynak yok, model bilgisi) Her iki oyun da tek şirket işleten simülasyonlardır; üçüncü taraf satıcılı iki taraflı pazaryeri kurma mekaniği yok.
- Gerçek dünya benzeri: oyun mağazalarında komisyon kademeleri (Steam %30/25/20, Epic %0/12). https://respawn.outlookindia.com/gaming/gaming-news/epic-launches-web-based-stores-challenging-app-store-economics
- Oyun içi ekonomi tasarım kolları (Texas A&M ders materyali): sabit fiyatlı mağaza, açık artırma, rastgele ganimet, işlem ücretleri, bilgi şeffaflığı. https://aggiecollaborate.tamu.edu/game-economics
- MMO oyuncudan oyuncuya ticaret pazarlarında işlem ücreti gelir kolu (araştırma özeti). https://www.disei.unifi.it/upload/sub/pubblicazioni/repec/pdf/wp22_2021.pdf (yalnız arama özetinden; doğrudan okunmadı)
- Tycoon türünde tipik oyuncu kolları (kaynak yok, model bilgisi): fiyat/oran, pazarlama bütçesi, kalite/destek yatırımı, kapasite/personel, araştırma ağacı. Oyuncu genellikle talep ve kalite arasındaki dengeyi yönetir.

Oyun için çıkarım
- Rakip örnek bulunmadığı için bu mekanik görece özgün olur; riski kendi dengelemenle yönet (önizleme ve ayar penceresi şart).
- Kollar: komisyon oranı (kademeli), alıcı üyelik ücreti, satıcı değer yatırımı (araçlar, reklam), alıcı edinimi (kampanya), kalite/güven (dolandırıcılık denetimi, destek).
- Her kolun net bir bedeli olsun: komisyon yukarı = gelir artar ama memnuniyet ve çıkış; üyelik fiyatı yukarı = üye geliri artar ama penetrasyon ve sıklık düşer.
- Önizleme kutusu iki yönlü sonucu göstersin (gelir değişimi ve mağaza/üye kaybı); Steam tarzı kademe, ilerleyen aşamada "sözleşme/kademe" kilidi olarak açılabilir.

---

## Kaynak güvenilirliği notu
- Güçlü: SEC/investor.etsy.com (Etsy Q2 2022), TechCrunch, NPR, Marketplace Pulse, CIRP.
- Zayıf: satıcı blogları, hesap makinesi siteleri, vendor rehberleri (komisyon oranları; birbirine ters düşebiliyor).
- Doğrulanmadı: Trendyol Plus üye sayısı, Türkiye üyelik sıklık etkisi, Mercado Libre oranları, oyunların iç mekanikleri.
