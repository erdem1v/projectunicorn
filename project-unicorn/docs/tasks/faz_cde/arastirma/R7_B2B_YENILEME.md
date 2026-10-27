# R7 — B2B sözleşme yenileme, sözleşme şartları ve hesap tablosu (Faz C)

Tarih: 2026-10-17. Hazırlayan: araştırma ajanı.

**Okuma notu (önce bunu okuyun).** Bu raporun gerçek dünya yarısı (yenileme fiyat artışı, GRR/churn, SLA, cure period, sağlık skoru) ikincil kaynaklara dayanıyor. Çoğu satıcı ve danışmanlık blogu. Birincil kaynak olarak yalnızca AWS EC2 SLA sayfası ve Salesforce MSA'nın alıntılandığı yazılar okunabildi. Oyun yarısı ise zayıf: Football Manager için yalnızca yüzeysel rehber metinleri okunabildi; Software Inc, Big Ambitions ve Motorsport Manager'ın wiki sayfalarına erişilemedi (Fandom 402 verdi, wiki.gg 401, Steam rehberleri 429 hız sınırı). Bu yüzden oyun bölümlerinde "kaynaksız, model bilgisi" işaretli kısımlar çok. Sayı uydurmadım; bulunamayanlar 6. bölümde. WebSearch bütçesi (8) tamamen kullanıldı; arama sonuçlarından çıkan sayfalar WebFetch ile okundu.

---

## 1. Özet

1. **Fiyat artışı normu.** Kaynaklara göre sınırsız (tavansız) yenilemede yıllık artış %8–12, tavanlı sözleşmede %5–8 civarı. Müzakere sonunda gerçekleşen artış, satıcının açılış talebinin %40–60'ı kadar. Tavan müzakeresinde yaygın hedef %3–5 veya TÜFE. Bunlar satıcı/danışman iddiası, bağımsız ölçüm değil (bkz. 2.2).
2. **Tutma oranı segmente göre keskin farklı.** GRR: küçük (SMB) %71–88, orta pazar %81–94, kurumsal %92–96 (iki kaynak, aralıklar çelişiyor). Yıllık logo kaybı SMB %10–14, orta pazar %5–8, kurumsal %2–5 (ChartMogul 2025 alıntısı). Sahibin "20–50 çalışanlı şirkette sabit sayı kırılır" endişesi burada somutlaşıyor: kayıp oranı hesabın büyüklüğüne bağlı olmalı, şirkete değil.
3. **Gerçek sözleşmelerde fesih standardı: 30 gün cure period.** Salesforce MSA 11.3 (ikincil alıntı): esaslı ihlal yazılı bildirimden 30 gün sonra düzeltilmemişse fesih. SLA ihlali ise ayrı yoldan gider: kredi (örnek AWS: %10/%30/%100) ve "kronik ihlal" (ör. 9 ayın 3'ünde kötü performans) fesih hakkı doğurur. Sahibin "iki ay sonra fesih hakkı" fikri, gerçek pratikte "kronik ihlal penceresi"ne karşılık geliyor; 60 gün cure period'a değil.
4. **Yenileme otomatiktir; müşteri "artık kullanmak istemiyoruz" demek için bildirim vermek zorundadır.** Salesforce'ta yıllık otomatik yenileme, bitişten en az 30 gün önce bildirimle durdurulur. Alıcı tarafı rehberleri 90–120 gün ister. Yani "ayrılma" gerçekte "yenilememe bildirimi" olarak olur; oyunda böyle modellenmeli.
5. **Sağlık skoru.** Üç kaynakta ortak eşik: yeşil ≥70–71, sarı 40/31–69/70, kırmızı <40/31. Yeni müşteri için ayrı "onboarding skoru" (ilk 0–90 gün, kilometre taşı bazlı) kullanılıyor; sayısal başlangıç değeri hiçbir kaynakta yok. Sahibin "%70'lerden başlasın" isteği yeşil eşiğin hemen üstü demek ve savunulabilir.
6. **Oyun referansı.** Football Manager'da yenileme "teklif gönder, oyuncunun tutumuna bak, onaylayana kadar yeniden müzakere et; kopunca oyuncu sözleşme bitene kadar kalır" akışı (FMScout, okundu). Teklifin kabul olasılığı tutum göstergesiyle gösteriliyor. Diğer üç oyun için mekanik bulunamadı.
7. **Öneri.** Satışçı raporu + istisna maili hibriti (Alternatif C, bölüm 6): satışçı kurucuya hesap bazlı "öneri" getirir; küçük hesaplar otomatik, büyükler kurucunun mail teklifiyle. Hesap tablosunda ana sütun aylık gelir (MRR), toplam sözleşme değeri yan sütun; tüm sütunlar tıklanıp sıralanır.

---

## 2. Mekanik döküm

### 2.1 Gerçek yenileme pratiği (Soru 1)

**Sahiplik ve zamanlama.**
- Alıcı tarafı müzakere takvimi: yenilemeden 6 ay önce araştırma, 4 ay önce rakip teklifler, 3 ay önce müzakere, 120 gün önce otomatik yenilemeyi engelleme için son tarih, 1 ay önce imza. "Başarılı yenileme müzakerelerinin %83'ü en az 120 gün önce başlar" iddiası kaynaksız. https://www.softwareseni.com/how-to-negotiate-better-saas-contracts-and-lock-in-lower-prices
- Alıcı uyarısı takibi: yenileme bildirim son tarihinden 120, 90, 60 gün önce uyarı. https://www.cloudnuro.ai/blog/saas-price-protection
- Standart bildirim penceresi 30 gün; bir rehber bunu "yetersiz" bulup 90–120 gün istemeyi öneriyor. https://www.softwareseni.com/how-to-negotiate-better-saas-contracts-and-lock-in-lower-prices
- Salesforce: abonelikler bir yıl için yenilenir, iki taraftan biri bitişten en az 30 gün önce bildirim verirse yenilenmez; e-posta bildirimi kabul. https://www.redresscompliance.com/salesforce-negotiations-contract-terms-faqs
- Yenilemenin sahibi (AE mi, AM mi, CSM mi): **hiçbir okunan kaynakta bulunamadı.** Genel bilgi (kaynaksız, model bilgisi): küçük hesapta yenileme çoğu zaman CS/otomasyon havuzunda; orta pazarda AM veya CSM; kurumsalda AE/AM, CSM destekler. Bunu kesin diye kullanmayın.

**Fiyat artışı normları.**
- Tavansız sözleşmede yıllık artış %8–12; düzgün yazılmış tavanlı sözleşmede %5–8; 3 yıllık tavansız dönemde etkin artış %30–40 (isim kullanıcı kayması dahil). https://www.redresscompliance.com/genai-uplift-cap-clause-redline (yazarın kendi 90–110 yenileme incelemesi; metodoloji yayımlanmamış)
- Müzakere sonucu gerçekleşen artış, açılış talebinin %40–60'ı. Aynı kaynakta modül örnekleri: ITSM %17 istendi, %9 gerçekleşti; CSM %18 istendi, %10 gerçekleşti. https://www.redresscompliance.com/genai-uplift-cap-clause-redline
- Sözleşmelerin yalnızca %29'unda herhangi bir otomatik yenileme fiyat tavanı var (kaynak: Common Paper benchmark, bu sayfada alıntı). BT yöneticilerinin %79'u son yenilemede zam kabul etmiş. Aynı sayfa.
- Salesforce: MSA yenileme yüzdesi belirlemiyor, sipariş formu yazmalı; tavansız sözleşmelerde yenileme artışı %9–23, tavanlı olanlarda %0–7 (sayfanın iddiası). 1 Ağustos 2025 liste fiyatı artışı bazı bulutlarda ortalama %6. Gartner tavsiyesi: yenilemede en fazla %3–5 net artış. https://www.redresscompliance.com/salesforce-negotiations-contract-terms-faqs ve https://www.nutshell.com/blog/salesforce-contracts-explained
- Yaygın tavan dili: "yıllık artış %3–5 veya TÜFE, hangisi düşükse"; kabul edilebilir %5–7; %10 üstü zayıf koruma. Çok yıllı sözleşmede tavanın dönem uzunluğuyla çarpılması (%3 × 3 yıl = %9) yeni bir hile olarak anılıyor. https://www.cloudnuro.ai/blog/saas-price-protection ve https://upperedge.com/contract-negotiations/hidden-renewal-clause-that-could-inflate-your-saas-costs/
- Fiyat artışının NRR'ye katkısı: 2022'de +4 puan, 2026'da +6 puan (38 şirketlik küçük bir çalışma). https://visionary-marketing.co.uk/blog/saas-churn-benchmarks-2026
- Tavan varken bile paket/kademe geçişi gerçekleşen artışın %20–40'ını getiriyor (aynı Redress sayfası). Oyun için ders: "fiyat artışı" yalnızca yüzde değil, kademe yükseltme de olabilir.
- Alıcı itirazı: Vendr'in Gainsight sayfasında tek tek anekdotlar var (önerilen %10 artışın %3'e indirilmesi, otomatik yenilemeyi kaldırma karşılığında %5 tavan). Ortalama değil. Arama sonucundan; sayfa kendisi okunmadı.

**Müzakere akışı (teklif, karşı teklif, satın alma).** Bulunan kaynaklar alıcı tarafı taktik listesi veriyor: alternatif değerlendirdiğini söyle, tek seferde tek şartı müzakere et, otomatik yenilemeyi çıkar, kullanım bazlı fiyat iste (https://vendr.com/blog/contract-negotiation). Satıcının adım adım iç süreci (teklif, onay, indirim yetkisi) okunan sayfalarda yok.

**Sonuç dağılımı (aynı fiyat / zam kabul / koltuk azaltma / ayrılma).** Tek bir kaynakta dört kovaya bölünmüş dağılım **bulunamadı.** Kısmi veriler:
- 38 şirketlik çalışmanın NRR ayrışımı 2026: fiyat artışı +6, upsell/cross-sell +18, daralma (contraction, yani koltuk/paket azaltma) −10 puan. https://visionary-marketing.co.uk/blog/saas-churn-benchmarks-2026
- Aylık sözleşmede yıllık logo kaybı %28–35, yıllık sözleşmede %6–10; çok yıllı kurumsal sözleşmede ek %30–50 azalma (Recurly 2025 alıntısı). https://stealthagents.com/research/saas-churn-rate-statistics-2026

**Segmente göre tutma.** İki bağımsız-görünüm kaynak, ama aralıklar çelişiyor; ikisini de yazıyorum.

| Segment (ACV) | GRR (stealthagents, ChartMogul/OpenView/KeyBanc alıntısı) | GRR (Visionary, n=38) | Yıllık logo kaybı (ChartMogul 2025 alıntısı) |
|---|---|---|---|
| ~<$5K SMB | %80–87 | %71 ($480–2.400) | SMB ($1–10K): %10–14 |
| $5–25K | %87–92 | %81–87 | Orta pazar ($10–50K): %5–8 |
| $25–100K | %90–94 | %93 ($50–120K) | Kurumsal ($50–200K): %2–5 |
| $100K+ | %92–96 | %96 | |

Kaynaklar: https://stealthagents.com/research/startup-gross-retention-benchmarks, https://visionary-marketing.co.uk/blog/saas-churn-benchmarks-2026, https://stealthagents.com/research/saas-churn-rate-statistics-2026. Visionary'nin SMB yıllık kaybı kendi içinde tutarsız (%31 başlıkta, %74 tabloda); güvenmeyin. Bessemer rehberi: genel brüt tutma %85–90, HubSpot IPO öncesi SMB odaklıyken %70–80. https://www.bvp.com/atlas/scaling-to-100-million

**Ayrılma nedenleri.**
- Gönüllü iptal nedenleri (Recurly/ChartMogul 2025 alıntısı): ürün-pazar uyumsuzluğu/değişen ihtiyaç %28, düşük kullanım %24, fiyat/değer algısı %21, rakibe geçiş %14, kapanma/küçülme/bütçe %8, onboarding başarısızlığı %5. Fiyatın belirtilen neden olma payı: SMB %26, orta pazar %18, kurumsal %11. https://stealthagents.com/research/saas-churn-rate-statistics-2026
- Başka bir çalışma: bütçe kesintisi %34, ürün beklenen değeri vermiyor %24, daha iyi alternatif %18, yapay zekâ aracı %11, ekip değişikliği %8. https://visionary-marketing.co.uk/blog/saas-churn-benchmarks-2026
- Yenilemeden 60 gün önce kullanım çeyreğinin en alt diliminde olan müşteri, üst dilime göre 4–6 kat daha çok ayrılıyor. Yenileme öncesi kullanım değerlendirmesi/CS görüşmesi yapan şirketlerde fiyat hassasiyeti beyanı %30–40 düşüyor ("fiyat" çoğu kez düşük algılanan değeri maskeliyor). Aynı stealthagents sayfası (ChartMogul 2025 alıntısı).

**Küçük hesapta mail, büyük hesapta toplantı.** Okunan kaynaklarda doğrudan veri yok. Yüksek temaslı / dijital segment ayrımı var: sağlık skoru sayfası "high-touch" için CSM duyarlılığı, yönetici etkileşimi, QBR sıklığı; "digital" için uygulama içi etkinlik ve bilgi bankası kullanımı öneriyor. https://www.gainsight.com/customer-success/customer-health-scores/ Yani ayrım gerçek pratikte "ACV ve temas modeli"ne göre. Kesin eşik (ör. $X üstü toplantı) bulunamadı.

### 2.2 Sözleşme şartları (Soru 2)

**Esaslı ihlalde fesih ve cure period.**
- Salesforce MSA 11.3 (Nutshell'in alıntısı): "A party may terminate this Agreement for cause (i) upon 30 days written notice to the other party of a material breach" — ihlal 30 günde düzeltilmezse fesih. İptal edilemeyen ücretler; kolaylık feshi yok; sözleşme sonunda 30 gün veri dışa aktarma. https://www.nutshell.com/blog/salesforce-contracts-explained ve https://www.redresscompliance.com/salesforce-negotiations-contract-terms-faqs. Ana MSA PDF'ine erişilemedi (404); kendi okumam değil, ikincil alıntı.
- Slack kullanıcı koşullarında cure süresi yok, ticari şartlar ayrı "Contract"ta. https://www.slack.com/terms-of-service/user (okundu, bu yönden boş).
- Alıcı tarafı rehberi: fesih ücretini sıfırla, kaçınılmazsa kalan sözleşme değerinin %25'inin altında tut; kaçış kapıları: esaslı ihlal, SLA ihlali, satıcı devralınması. https://www.softwareseni.com/how-to-negotiate-better-saas-contracts-and-lock-in-lower-prices
- 60 ve 90 günlük cure period örnekleri: **okunan kaynaklarda yok** (kaynaksız, model bilgisi: kurumsal ve kamu sözleşmelerinde görülür).

**SLA ihlali ve kredi.**
- Tipik SaaS hedefi %99,9 aylık erişilebilirlik ≈ ayda 44 dakika kesinti. Örnek kredi şeması: hedefin altında her %0,1 için aylık ücretin %5'i, tavan %50. https://contracko.com/clause-library/service-level-agreement
- AWS EC2 (birincil kaynak): bölge düzeyi hedef %99,99, aylık uptime %99,0–99,99 arası → %10 kredi; %95,0–99,0 → %30; <%95 → %100. Kredi talebi olay sonrası ikinci fatura döneminin sonuna kadar yapılmalı; kredi gelecek faturalara uygulanır. https://aws.amazon.com/compute/sla/
- Kredi tek çözüm mü? Sağlayıcılar kredinin "tek çare" olmasını ister; alıcılara "kronik ihlal"i fesih sebebi yapmaları öneriliyor. Kronik ihlal örnekleri: 6 ayda belirli bir tutarı aşan kredi birikmesi; 9 ayın herhangi 3'ünde "kötü" performans. Krediler "ceza" değil "tasfiye edilmiş zarar" diye yazılmalı. https://www.thompsoncoburn.com/insights/why-service-level-agreements-are-key-for-provider-longevity-and-customer-satisfaction/ ve Contracko sayfası.
- Garanti ihlali bildirim+düzeltme yolunu izler; SLA ihlali ise bu yolu atlayıp krediye gider (Thompson Coburn).

**Güvenlik/barındırma şartı (ör. "kurumsal sunucu").** Sözleşmeye "dedicated/kurumsal barındırma" yazıp sağlanmazsa fesih hakkı doğmasına dair gerçek sözleşme örneği **bulunamadı.** Bulunan en yakın mekanik: SLA metriği + kredi + kronik ihlalde fesih (yukarısı). Veri taşınabilirliği ve güvenlik ihlali alıcı müzakere maddesi olarak anılıyor ama ayrıntısı yok. https://cloudeagle.ai/blogs/negotiating-software-contracts

**Sahibin kuralıyla karşılaştırma.** "Sunucu şartı sağlanmazsa iki ay sonra müşteri fesih hakkı" = gerçek dünyada iki parçalı: (a) bildirim sonrası 30 günlük cure period (standart), (b) tekrarlayan ihlalde kronik ihlal hakkı (ör. 9 ayın 3'ünde). Oyunda "iki ay" parametresi kabul edilebilir bir oyun sadeleştirmesi; gerçekle birebir değil.

### 2.3 Müşteri sağlık skoru (Soru 3)

**Bileşenler.**
- Gainsight (Scorecards): ölçüt başına ağırlık; öznel (yönetici ilişkisi) ve nesnel (giriş sayısı, NPS) ölçütler; 0–100, A–F veya KSY (kırmızı-sarı-yeşil); geçerlilik süresi bayat skoru işaretler. Sayfa ağırlık/eşik vermiyor. https://www.gainsight.com/blog/scorecards-quantifying-customer-health/
- Gainsight blog örneği (örnek, varsayılan değil): kullanım %40, destek eğilimi %25, duygu %20, yönetici etkileşimi %15; 4–6 ölçüt öner. Eşikler: Sağlıklı 71–100, Riskli 31–70, Kritik 0–30. Segmente göre ayrı kartlar: Onboarding (kilometre taşı, giriş aktivasyonu, destek hacmi), Olgun (ROI, ürün derinliği, NPS, upsell), High-touch, Digital. https://www.gainsight.com/customer-success/customer-health-scores/
- ChurnZero (ChurnScores): hesap nitelikleri, etkileşim, ürün kullanımı, yolculuk ilerlemesi, lisans kullanımı, destek geçmişi (bilet hacmi, SLA sorunları, önem), sadakat (kıdem, NPS/CSAT/CES). Ağırlık/eşik yok; SMB, orta pazar, kurumsal için ayrı skor öneriyor. https://www.churnzero.com/blog/customer-health-score/
- Totango: sayfa ağırlık/eşik içermiyor (ürün duyurusuna dönmüş). Bulunamadı.
- GitLab el kitabı: sağlık skoru sayfasının gövdesi okunamadı (navigasyon çıktı). Arama özetinde GitLab'ın Gainsight kurulumu için yeşil 75–100, sarı 50–74, kırmızı 0–49 yazıyordu; bu özet sayfayı doğrulamıyor, sadece arama alıntısı.
- Pratikçi örnek model (dev.to, yazarın kendi önerisi): ürün kullanımı %40 (35–45), destek ve etkileşim %15 (açık hata dahil), ödeme geçmişi %10, duygu %20, ilişki ve ticari %15 (yenilemeye kalan süre dahil). Eşikler: yeşil 70–100, sarı 40–69 (2 hafta içinde aksiyon), kırmızı 0–39 (48 saat); bir ayda 20+ puan düşüş alarm. Düşüş yapanlar ~2,5 kat daha çok ayrılıyor (Recurly alıntısı). https://dev.to/insightlab/the-customer-health-score-framework-that-predicts-churn-60-days-early-55je
- Saber sözlüğü: kullanım %40, etkileşim kalitesi %25, destek sağlığı %20, mali sinyaller %10, ilişki %5; renk eşikleri 80/60. https://www.saber.app/glossary/health-score
- HubSpot blog: sayısal ağırlık yok; ilke: yenileme sinyalleri yenileme tarihi yaklaştıkça ağırlık kazanmalı, şiddetli destek sorunu küçük dalgalanmadan çok eksiltmeli, ağırlıklar yenileme/kayıp sonuçlarıyla korelasyondan çıkmalı. https://blog.hubspot.com/customer-success/customer-health-score

**Yeni müşterinin başlangıç sağlığı.** Hiçbir kaynak sayısal başlangıç değeri vermiyor. Ortak yön: ilk 0–90 gün için ayrı, kilometre taşı bazlı onboarding skoru (Saber; Gainsight onboarding segmenti), yeni hesapta düşük kullanım olgun hesapla aynı anlama gelmez (HubSpot). Sahibin "%70'ler" isteği, bu kaynaklarda yeşil eşiğin (70–71) hemen üstüne denk geliyor; sayısal olarak makul, ama kaynaklı bir "norm" değil, tasarım kararı.

### 2.4 Hesap tablosu (Soru 4)

**Okunabilen kaynak yok.** HubSpot, Salesforce ve Gainsight dokümantasyon sayfalarına erişilemedi (404 veya JS ile yüklenen boş sayfa). Aşağıdaki hepsi **(kaynaksız, model bilgisi)**:
- CRM hesap listeleri tipik sütunlar: hesap adı, sahibi, aşama/durum, ARR veya yıllık değer, yenileme tarihi, sağlık, son temas. CS araçlarında (Gainsight Renewal Center benzeri) ana para sütunu çoğunlukla ARR, yenileme tarihi ve sağlık yanında; MRR daha çok abonelik faturalama araçlarında (Stripe, ChartMogul) öne çıkar; TCV/ACV sözleşme (opportunity) kaydında yer alır. Bunu kendi gözünüzle doğrulayın.
- Başlığa tıklayarak sıralama, çok sütunlu filtre, kayıtlı görünüm ve sütun seçici bu araçların tümünde standart. Ekran görüntüsü URL'si toplanamadı.

Sağlık skoru sayfasından doğrulanabilen tek parça: skorlar yüzde, renk, harf notu veya "sıralama" olarak gösterilebiliyor (HubSpot blog).

### 2.5 Oyun referansları (Soru 5)

**Football Manager.**
- Okundu (FMScout): sezon başında son sözleşme yılındaki oyuncular bildiriliyor. Oyuncu/menajeri asgari şartlarını söylüyor. Haftalık maaş, süre, imza parası, bonuslar ayarlanıyor. "Suggest Terms" ile teklif gönderilir, oyuncu tutumunu gösterir; memnunsa "Confirm Deal"; değilse yeniden müzakere; görüşme kopsa oyuncu sözleşme bitene kadar kulüpte kalır. Menajer ücreti artırılarak anlaşma kolaylaştırılabilir; iyi ilişkideki menajer daha az şikâyet eder. Panelde "Original Demands" ve "Original Contract" arasında geçiş var. Oyuncunun talebi kişiliğini ele veriyor (bazıları "demand", bazıları "require"). https://www.fmscout.com/offer_new_contract.htm
- Arama özeti (FM2011 incelemeleri): birkaç tur teklif/karşı teklif, biri çekilene kadar; menajerler farklı mizaçta (bazısı ilk adımı senden bekler, bazısı abartılı ister, azınlık makul); makul olmayan teklifler yıldız oyuncunun imzalamamasına yol açabilir. FM2020 rehberi: ilk teklifi kabul etme, çünkü hep pahalı; karşı teklif makul olsun yoksa oyuncu gider. https://www.magicgameworld.com/?p=123866 (okundu) ve https://bit-tech.net/reviews/gaming/football-manager-2011-review/1/ (yalnızca arama özeti).
- FM24 rehberi (arama özeti): oyuncunun yanıtı kabul, ret veya değişiklik talebi olabilir; "Suggest Terms" oyunu senin yerine yapar. https://afkgaming.com/gaming/general/how-contract-negotiations-work-in-football-manager-2024 (sayfa yönlendirdi, gövdesi okunamadı).
- Kaynaksız, model bilgisi: kabul olasılığı sayı olarak değil, maddenin yanında yeşil/sarı/kırmızı gibi tutum işaretiyle ve oyuncunun yazılı cevabıyla ("maaşı yetersiz buluyor") gösterilir; ardışık ret sonrası oyuncu bir süre görüşmeyi reddedebilir. Mail akışı: teklifler gelen kutusuna iletilerek cevap bekler. Kesin değil, doğrulanmadı.
- Sıralanabilir ve özel görünümlü oyuncu tablosu: **kaynak bulunamadı** (kaynaksız, model bilgisi: FM'de görünüm = sütun seti, sütun başlığına tıklayarak sıralama, filtre ve kayıtlı görünüm var).

**Motorsport Manager sponsor yenilemeleri.** Wiki ve rehber erişilemedi (Fandom 402, Steam 429). Bulunamadı. Kaynaksız model bilgisi: sponsor boşlukları dönemsel olarak birkaç teklif sunar (süre, aylık/yarış başı ödeme, hedef), süre bitince yenileme teklifi gelir. Doğrulanmadı.

**Software Inc sözleşmeleri.**
- Steam sayfası: "contract work", pazar, anlaşmalar ve borsa var; sözleşme şartları anlatılmıyor. https://store.steampowered.com/app/362620/Software_Inc/
- 2017 tarihli, artık Steam'den kaldırılmış bir başlangıç rehberi (eski sürüm sayıları): sözleşmeler ~8.000–12.000, ayda ~2 sözleşme hedefi, "hata başına ceza" ("smallest per/bug penalty" olanı seç), tamamlanan sözleşme itibarı (yıldız) artırıyor, itibar daha iyi sözleşme getiriyor. Destek sözleşmesi ve yenileme anlatılmıyor. https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114
- Bu bizim kart kapanış hata mekaniğiyle paralel: hata, sözleşme ödemesinden ceza olarak düşüyor. Güncel (Beta) mekanik doğrulanamadı.

**Big Ambitions B2B.** Steam sayfası B2B sözleşme anlatmıyor; yalnızca ithalat/depo/Purchasing Agent geçiyor. https://store.steampowered.com/app/1331550/Big_Ambitions/ Bulunamadı.

---

## 3. Oyuncuya gösterim

- **Football Manager (okundu):** sözleşme panelinde şart alanları (maaş, süre, imza parası, bonus); "Suggest Terms" ve "Confirm Deal" düğmeleri; oyuncunun tutum göstergesi; "Original Demands / Original Contract" karşılaştırma düğmeleri. https://www.fmscout.com/offer_new_contract.htm
- **Sağlık skoru gösterimi:** 0–100 sayı, KSY renk, A–F harf veya sıralama; skor değişince kural motoru uyarı verebilir. https://www.gainsight.com/blog/scorecards-quantifying-customer-health/ ve https://blog.hubspot.com/customer-success/customer-health-score
- **SLA:** kredi talep süreci kullanıcıya dosyalanan vaka olarak gösteriliyor (AWS). Oyunda bu otomatik olabilir (oyuncu hak talep etmesin).
- **Ekran görüntüsü URL'leri.** Aranan oyun ekranları (sözleşme paneli) için doğrulanmış ekran görüntüsü URL'si **bulunamadı.** Yalnızca Steam mağaza sayfasındaki etiketsiz özellik görselleri alındı; sözleşme ekranı olup olmadıkları bilinmiyor:
  - Software Inc: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/362620/extras/911f24a3de539eaf964976d85609146a.avif ve .../ec77ca492eeb11fc6916d63aad44644a.avif (sayfadaki 6 görselden ikisi)
  - Big Ambitions: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1331550/extras/7a6e800b401589817d50c3da0bb4d4d0.avif (9 görselden biri)
  - CRM/CS ekran görüntüleri: toplanamadı.

---

## 4. Ölçek ve sorunlar

**Sabit sayının ölçekte kırılması (sahibin endişesi).** Kaynakların ortak sonucu: tüm oranlar **hesap büyüklüğüne (ACV) bağlı**, şirket büyüklüğüne değil.
- Logo kaybı ve GRR, ACV kademesine göre 3–5 kat değişiyor (2.1 tablosu). "Hesap başına %5 kayıp" tek sayı olarak SMB hesabı için fazla düşük, kurumsal hesap için fazla yüksek.
- Fiyat hassasiyeti büyüdükçe düşüyor: fiyat nedeni SMB %26, orta pazar %18, kurumsal %11.
- Aylık sözleşme yıllığa göre ~4 kat fazla ayrılıyor; çok yıllı sözleşme kurumsalda kaybı %30–50 azaltıyor. Sözleşme süresi, kayıp olasılığına doğrudan bağlanabilir bir çarpan.
- Büyük hesapta tek hesap kaybı gelirin büyük parçası: bu yüzden kurumsal için ayrı insan temaslı akış (CSM, yönetici ilişkisi) uygulanıyor. Yenileme sahibi olarak hangi rolün gerektiği bulunamadı.
- Gainsight yazısı: ağırlıkları tarihsel veriden çıkarmak, sürekli yeniden doğrulamak gerek. Yani sabit ağırlık zamanla kayar. https://www.gainsight.com/customer-success/customer-health-scores/

**Oyuncu şikâyetleri ve istismarlar.** Okunabilen oyun toplulukları (Steam tartışmaları) sözleşme yenilemesiyle ilgili şikâyet vermedi (Reddit engelli). Bulunamadı. Gerçek dünyadan tek istismar benzeri: kurumsal satıcıların tavansız yenilemede, paket/kademe geçişiyle tavanı delmesi (Redress) ve tavanı dönem uzunluğuyla çarpan yeni hileler (UpperEdge). Oyun içi muadili: oyuncunun "kademe yükselt" ile zam tavanını delmesi; bunu açıkça sınırlamak gerekir.

**Sonradan yapılan değişiklikler (patch).** Okunan oyun patch notu yok. Gerçek dünyada: fiyat artışı katkısı 2022'den 2026'ya +4'ten +6 puana çıktı, yani zam daha sık kullanılıyor.

**Kaynak kalitesi uyarısı.** Redress, CloudNuro, Visionary ve Stealthagents sayfalarında metodoloji yok veya kaynaklar üstü kapalı. Rakamları "yön gösterici" sayın. Visionary içinde bile tutarsızlık var. Doğrulanmış birincil rakam: AWS SLA kredi tablosu.

---

## 5. Bizim için: alınacak, alınmayacak, uyarlanacak

**Alınacak.**
1. **Yenileme otomatik, ayrılma bildirimle.** Sözleşme bitişten önce bildirim penceresi (öneri: 60 gün; gerçek standart 30, alıcılar 90–120 ister). Müşteri "artık kullanmak istemiyoruz" bildirimini bu pencerede verir. Sahibin "hiç ayrılan olmayacak mı" sorusuna cevap: gerçekte ayrılma bu biçimde görünür; oyun bunu bir olay/mail olarak göstermeli. Gerekçe: Salesforce 30 gün (Redress), alıcı rehberleri 90–120 gün.
2. **Tavan müzakeresi hesap bazlı.** Yenilemede zam talebi yüzdesi oyuncu tarafından seçilir; müşterinin kabul sınırı (kabul tavanı) sağlık, kullanım, ACV ve rakip varlığından çıkar. Referans bant: tavansız %8–12, tavanlı %5–8, gerçekleşen/istenen oranı %40–60 (kaynak: Redress, uyarılarla).
3. **Sağlık skoru ve eşik.** Üç bileşenli yeterli (kullanım/ürün hataları, destek, ilişki+fiyat memnuniyeti). Eşikler 70/40 (dev.to ve Gainsight blogu yakın). 20 puan/ay düşüş alarmı (dev.to).
4. **Kronik SLA ihlali.** Kredi + tekrarlayan ihlalde fesih hakkı (AWS tarzı basamaklı kredi, Thompson Coburn tarzı kronik tetik).
5. **Fiyat hassasiyeti = değer algısı.** Yenileme öncesi kullanım/destek incelemesi (CS görüşmesi) ret ihtimalini düşürür (%30–40 hassasiyet azalması, kaynak: stealthagents).

**Alınmayacak.**
1. 60/90 gün cure period: gerçek standart 30; kaynak yok. Oyuncuyu gereksiz hukuk terimiyle yormaz.
2. Karmaşık çok yıllı tavan çarpımı (UpperEdge): tek sözleşme süresi (12 ay) yeterli; bu hile Faz C kapsamı dışı.
3. Salesforce'ın "kolaylık feshi yok" hükmünü birebir: oyunda müşteri her ay çıkamasın ama cezasız çıkış yolu "fesih hakkı" doğunca (sunucu şartı) olsun.

**Uyarlanacak.**
1. **"İki ay sonra fesih hakkı"** → iki kademe: (a) ihlal başlar, oyun "çözülmemiş ihlal sayacı" tutar; 8 hafta (≈2 ay) dolunca müşteri fesih hakkı kazanır; (b) hak kazandıktan sonra müşteri otomatik ayrılmaz, sağlığına göre bildirim verir. 1 tik = 1 hafta olduğundan 8 tik. Gerçek cure 30 gün (~4 hafta); sahibin 8 hafta kararı oyun tasarımı olarak yumuşatma, bunu açıkça belirtin.
2. **Oran kaynağı = ACV bandı, tablo değil sabit.** Yıllık logo kaybı bantlarını (SMB %10–14, orta pazar %5–8, kurumsal %2–5) yalnızca **taban** olarak kullanın; çarpanlar: sağlık, memnuniyet, açık hata, sözleşme süresi (çok yıllı = ×0,5–0,7), fiyat artışı oranı. Haftalık tik olduğundan yıllık orana değil, yenileme anında bir kez çekilen olasılığa çevirin; oyun 130 haftalık ve sonsuz modda çalışacağı için yenileme olayı sözleşme sonunda 1 kez tetiklenir. (Bu bir tasarım önerisi; kaynak veri yok.)
3. **Yeni müşteri başlangıç sağlığı %70'ler** (sahibin isteği). Önerim: 72–78 arasında rastgele; onboarding kilometre taşları (kurulum, ilk dönem hatasız çıkış) ilk 12 haftada ±; SMB'de dalgalanma geniş, kurumsalda dar (ChurnZero segmentli skor önerisi). Bu kaynaksız tasarım önerisi; yeşil eşik 70–71 ile uyumlu.
4. **Hesap tablosu.** Ana sütun "Aylık gelir (MRR)" — oyunun kendi para dili aylık olduğu ve CRM'de ARR/MRR'nin standart olması (kaynaksız) nedeniyle; yan sütunlar: koltuk, koltuk başı fiyat, sözleşme sonuna kalan hafta, toplam sözleşme değeri (TCV = 12 × MRR), sağlık (renk + sayı), açık hata, son temas, yenileme durumu. Tüm sütun başlıkları tıklayınca sıralar (330 hesapta şart); filtre (yenilemesi 8 hafta içinde olanlar, kırmızılar) ve kayıtlı görünüm. Kaynak: yalnızca "skor sayı, renk, harf veya sıralama olabilir" (HubSpot) ve genel CRM pratiği (kaynaksız).

---

## 6. Yenileme akışı için üç alternatif kurgu (Soru 6) ve modelleme

Her alternatifin sağında kaynak/emsal verilmiştir; oyun emsalleri sınırlı olduğundan FM dışında zayıf.

### Alternatif A — "Satışçı raporu": kurucu karar verir, satışçı önerir

**Akış.** Yenilemeye 8–12 hafta kala satışçı (rol: satışçı, "Satış" işi) hesapla görüşür ve kurucuya toplu bir yenileme raporu getirir: "Bu hesap zam kabul eder (+%X), bu indirim ister (−%Y), bu aynı fiyattan kalır, bu riskli." Kurucu satır satır onaylar, değiştirir veya toplu "satışçının önerisini uygula" der. Satışçının tahmin kalitesi becerisine bağlıdır (yıldız); düşük beceride rapor yanlış sınıflandırır.

**Emsal.** Gerçek: yenileme tahmin kovaları ve CS'in hesap bazlı öneri sunması (sağlık skoru sayfalarındaki "yenilemeyi önceliklendir" kullanımı: ChurnZero blogu "prioritizing renewals"). Oyun: FM'de "Suggest Terms" ile oyunun senin yerine teklif önermesi (FM24 rehberi, arama özeti).

**Sahibin ilk sorusu (zam yapalım mı / bu kabul eder).** Bu alternatif ikincisine yakın; ilk biçim ("zam yapalım mı?") yalnızca satışçı beceri çok düşükse görünür.

**Artı.** 330 hesapta oyuncu yükü düşük; hızlı. **Eksi.** Müzakere hissi az; oyuncu aslında bir "Tamam" düğmesi basar.

### Alternatif B — "Mail teklifi": kurucu toplantıya girmeden teklif çıkarır, müşteri yanıtlar

**Akış.** Kurucu bir hesaba şart seti seçer (zam %, süre, indirim, sunucu şartı) ve "Teklif gönder" der. Teklif posta kutusundan gider. N hafta sonra müşteri yanıt verir: kabul / karşı teklif (örn. "%4 zam olur, %8 değil") / sessizlik / yenilememe bildirimi. Karşı teklifi kurucu kabul eder, değiştirir veya reddeder; en çok 2 tur. Kopunca (FM'deki gibi) sözleşme bitene kadar mevcut şartlar sürer, bitince müşteri ayrılır.

**Emsal.** Oyun: Football Manager teklif → tutum → yeniden müzakere → kopma akışı (https://www.fmscout.com/offer_new_contract.htm); "ilk teklifi kabul etme, karşı teklif makul olsun" (https://www.magicgameworld.com/?p=123866). Gerçek: alıcının zam talebini %10'dan %3'e çektiği anekdotlar (Vendr), açılış talebinin %40–60'ı gerçekleşir (Redress).

**Sahibin sorusuna.** Doğrudan "mail üzerinden teklif, karşı teklif" isteğiyle örtüşüyor. **Belirsizlik gösterimi:** FM gibi kesin olasılık yüzdesi gösterme; tutum ifadesi göster ("fiyatla ilgili çekinceleri var", "uzun süredir kullanıyor, rahat"). Gerekçe: FM'de oyuncu tutumu göstergesi ve davranıştan okunan kişilik.

**Artı.** En çok oyunculuk ve hikâye; karşı teklif doğal. **Eksi.** 330 hesapta tek tek yapılamaz: sadece büyük/riskli hesaplara. Küçükler toplu veya otomatik olmalı.

### Alternatif C — Hibrit: otomatik yenileme + istisna maili (önerilen)

**Akış.** Varsayılan: sözleşme bitince aynı şartlarla 12 ay uzar (otomatik yenileme, Salesforce MSA gibi); müşteri bildirim penceresinde (60 gün önce) yenilememe bildirimi verebilir. Kurucu isterse yenilemeden 12 hafta önce bir hesap grubu için "zam teklifi" mailini toplu çıkarır (küçük hesaplarda tek tıkla %X). Büyük hesaplar (ACV eşiğinin üstü) için satışçı kurucuya "toplantı" önerir; kurucu mail yerine toplantı seçebilir (Alternatif B akışı). Karşı teklif yalnızca eşiğin üstündeki hesaplarda; küçüklerde yalnız kabul/ret.

**Emsal.** Gerçek: otomatik yenileme + 30 gün bildirim (Salesforce); yüksek temaslı/dijital segment ayrımı (Gainsight). Oyun: FM'in "sözleşmesi biten oyuncu" bildirimleri + teklif akışı (FMScout).

**Neden önerilir.** Sahibin kısıtlarını (330 hesapta tablo, 20–50 kişide ölçek) en iyi karşılayan: oyuncu bütün hesapları değil istisnaları yönetir; satışçı sayısı arttıkça büyük hesaplar satışçıya devredilir. "Tablo + rapor + mail" üçlüsü birbirini bütünler.

### Karşı teklif ve ayrılmanın modeli (kısa şema, tasarım önerisi)

- **Müşteri kabul tavanı (hesap bazlı gizli değer).** `kabul_tavanı = taban_zam(ACV bandı) + f(sağlık, memnuniyet, kullanım, rakip_varlığı) − g(açık hata, SLA ihlali)`. Taban zam bandları kaynaktan: SMB düşük tolerans, kurumsal yüksek tolerans (fiyat nedeni %26/%18/%11). Teklif ≤ tavan → kabul; tavanın %0–%X üstü → karşı teklif (tavan civarı bir sayı); çok üstü → ret veya yenilememe bildirimi. Eşikler kaynaktan çıkmaz; kalibrasyon gerekir.
- **Karşı teklif sayısı** her hesap için 1–2 tur (FM'deki gibi "biri çekilene kadar" yerine sınırlı).
- **Ayrılma türleri (dört):** (1) yenilememe bildirimi (normal, pencerede), (2) yenilemede koltuk azaltma (daralma; NRR'de −10 puan), (3) fesih hakkı kullanımı (esaslı ihlal: sunucu şartı sağlanmadı, 8 hafta sayaç dolunca), (4) kronik SLA ihlali (ardışık/tekrarlı). Dördü de ekranda "Bildirim" mailleriyle görünür.
- **Hızlı çıkış koruması (sahibin "düşünmediğimiz alan kalmasın").** Gerçekte ayrılma ardışık bir sürecin sonu: düşük sağlık → bildirim → pencere → ayrılma. Oyuncu pencerede kurtarma teklifi (indirim, sunucu yükseltme, destek) verebilir; başarı kaynaklara göre yenileme öncesi kullanım/CS görüşmesiyle artar (bottom-quartile 4–6 kat risk).
- **Sunucu şartı.** Sözleşme alanı "gerekli kademe: Kurumsal". Sağlanmazsa hesap sayacı başlar; sayaç 8 hafta dolunca "fesih hakkı doğdu" olayı; müşteri sağlık ve memnuniyete göre kullanır ya da pazarlık ister (indirim). Kronik varyantı: son N dönemde yinelenirse bekleme olmaksızın hak.

---

## 7. Bulunamayanlar

1. **Yenilemenin sahibi (AE/AM/CSM) ve kaç gün önce başladığı** — satıcı tarafı süreç kaynağı yok; yalnızca alıcı tarafı takvimleri bulundu. Gerekirse Gainsight/ChurnZero/Gong/SaaStr'ın yenileme rehberlerini elle bulup okuyun.
2. **Yenileme sonuç dağılımı** (aynı fiyat / zam kabul / koltuk azaltma / ayrılma) — tek kaynakta dört kovalı oran yok.
3. **Küçük hesapta mail, büyük hesapta toplantı eşiği** — ACV eşiği kaynaklı bulunamadı.
4. **60 ve 90 günlük cure period örneği; barındırma/güvenlik şartı gerçek sözleşme örneği.**
5. **Salesforce MSA birincil metni** — PDF 404 verdi; ikincil alıntılar kullanıldı.
6. **Totango ve (GitLab dışında) ChurnZero sağlık skoru ağırlık ve eşikleri**; GitLab el kitabı sağlık sayfası gövdesi okunamadı.
7. **Yeni müşteri başlangıç sağlığı için sayısal norm.**
8. **CRM/CS hesap listesi sütunları (Salesforce, HubSpot, Gainsight) ve ekran görüntüleri** — dokümantasyon sayfalarına erişilemedi.
9. **Football Manager:** kabul/ret olasılığının nasıl gösterildiğine dair ayrıntı, mail akışı, ret sonrası kilit süresi, oyuncu tablosu görünümleri.
10. **Motorsport Manager sponsor yenilemeleri, Software Inc destek/sözleşme yenilemeleri ve güncel mekanik, Big Ambitions B2B sözleşmeleri.** Fandom 402, wiki.gg 401, web.archive.org engelli, Steam 429, Reddit engelli.
11. **Oyuncu topluluğu şikâyet ve istismarları, patch notları** (yenileme/sözleşme konusunda).

**Kullanılan erişim yöntemi notu.** WebSearch 8/8 kullanıldı. Aramalar kısmen boş döndü; ardından bilinen URL'ler ve aramadan çıkan sayfalar WebFetch ile okundu. Çok sayıda tahmini URL 404 verdi.


---

## 8. Tamamlama (2026-10-17, başsız Chrome)

(Bu raporda 7 numaralı bölüm zaten "Bulunamayanlar" olduğu için tamamlama 8 olarak numaralandı.) Kaynak durumu: Startup Company wiki'si ve mağaza ekran görüntüleri, Software Inc resmi wiki'si ve Steam rehberleri okundu. Motorsport Manager wiki'si bulunamadı (tahmin edilen iki Fandom adı "wiki yok" döndü), Big Ambitions wiki.gg üç denemede boş/401 döndü, Football Manager için yalnız bir ikincil rehber okunabildi. Bu bölüm, §7'deki 10 ve 9 numaralı boşluklara kısmi yanıt verir.

### 8.1 Startup Company: sözleşme müzakeresi ekranı (kapanan boşluk: "yenileme akışı için gösterim örneği", kısmen)

Startup Company'de yenileme kavramı yok; reklam sözleşmeleri belirli süreli ve süre sonunda yeni sözleşme aranıyor. Yine de müzakere ekranı bizim "yenileme müzakeresi" kurgusuna doğrudan örnek.
- Ekran (satış yöneticisi penceresi): https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_8b07098ae4dfbdc86c9caebf44c498bf8b5bf71f.1920x1080.jpg?t=1727681373 Sol "TERMS" sütunu: Website, Type (reklam türü), Time slot, "Impressions yesterday" (dünkü gösterim; 31.202.833), "Guaranteed impressions" kaydırıcısı (22.000.000), "Contract length" kaydırıcısı (10 days), "Offer" ($6,60/CPM), "Penalty Fee" (%20), "Daily Payment" ($145.200). Düğmeler: CANCEL, ACCEPT CONTRACT, NEGOTIATE. Sağ "NEGOTIATION" sütunu sohbet biçiminde: karşı tarafın her teklifi bir balonda ("MeetyMe offered $7.30/CPM" ...) ve her teklifin yanında bir yüz ifadesi (yeşil gülen yüz, en son tekliflerde nötr yüz, yani sabrı azalıyor); oyuncunun teklifleri mavi balon ("You offered $9.40/CPM"); altta teklif kaydırıcısı ($9.30/CPM), günlük karşılığı ($204.600/day) ve "Cheap / Average / Expensive" yeşil-sarı-kırmızı şerit; "ACCEPT OFFER" düğmesi karşı teklifin yanında; "LEAVE NEGOTIATION" ve "SEND OFFER". Ret/kabul olasılığı sayı olarak verilmiyor; yüz ifadesi ve fiyat şeridi onun yerine geçiyor.
- Wiki, Sales Executive: her satış yöneticisi aynı anda yalnız bir sözleşmeyi yönetir; filtreyle gösterim aralığı verilir; sözleşme süresi kaydırıcısını uzatmak müşterinin ilk teklifini yükseltir ama yeni sözleşme için beklemek gerekir; garantili gösterim sayısını azaltmak ilk teklifi düşürür; müşteri karşı teklifinde oyuncunun indirimine orantılı karşılık verir (örnek: teklif $14,00'dan $13,00'a inerse müşteri yaklaşık $0,80-1,00/CPM artırır; yalnız $13,80'e inerse en çok $0,20); oyuncu "CPM başına $4 ve üstü" ek gelir elde edebilir; güvenilir bir kalıp: ana ekranda $8,40/CPM ya da üstü gösteren bir sözleşmeyle başla, süreyi 10 güne çıkar, $15,00 karşı teklifle başla, $12,50/CPM ve üstü elde et. Sayfa kendi başına "eksik, sayı ve denklem yok" diye işaretli. Kaynak: https://startupcompany.fandom.com/wiki/Sales_Executive
- Wiki, Negotiation (işe alım müzakeresi, aynı mekanik): aday ekranı teklif edilen maaş ve imza ikramiyesinden oluşur; aday kabul eder ya da karşı teklif yapar; adayın yanındaki yüz ifadesi kötüleştikçe pazarlığa isteği azalır, çok düşerse "gider"; teklifi düşürmek adayı kırar, yükseltmek karşı teklifi indirir; "güvenli karşı teklif iki teklifin ortasıdır, sürekli ortalarsan ortada bitirirsin"; uzun pazarlık mutluluğu düşürür; ikramiye düşük maaşı telafi edebilir. Kaynak: https://startupcompany.fandom.com/wiki/Negotiation . Bu, "red sonrası ne olur" için tek veri: ret yok, "adayın sabrı biter ve gider".
- Cezalı kapanış (ceza oranı) ve garantili hacim: "Penalty Fee %20" ve "Guaranteed impressions", yani sözleşme garantilenen hacmi tutturamazsa ceza işliyor (ceza hesabının ayrıntısı yazılı değil). Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_8b07098ae4dfbdc86c9caebf44c498bf8b5bf71f.1920x1080.jpg?t=1727681373

### 8.2 Software Inc: deal'ler, itibar ve ceza (kapanan boşluk: "destek/sözleşme yenilemeleri", kısmen)

- Resmi wiki, Deals (sürüm Alpha 10.5.1, son düzenleme 1 Mayıs 2018): altı deal türü: Design, Development, Support, Marketing, Hosting, Print Job. Deal almak için Reception Desk ve Receptionist gerekir; deal'ler şirket itibarından etkilenir, itibar sözleşme tamamlayarak artar. Hosting ödemesi "Mbps başına $2,00 ile $5,00 arası"; internet faturası yaklaşık $2,00/Mbps. Sayfanın ipuçları: hosting deal'lerini her zaman kabul et (sürekli gelir, günlük itibar); çok fazla destek ve baskı deal'i personeli bunaltır; pazarlamada bütçe koy. Yenileme, ceza ya da süre sayısı sayfada yok. Kaynak: https://softwareinc.coredumping.com/wiki/index.php/Deals
- Resmi wiki, Contract Work: "eksik sayfa"; yalnız dört kategori (Logistics Application, Website, Game Assets, Embedded System). Kaynak: https://softwareinc.coredumping.com/wiki/index.php/Contract_Work
- Oyuncu rehberleri: deal'ler sözleşmeden daha kazançlı ve daha az elle iş ister; ilk deal olarak Office Software, 2D System veya Antivirus seç; süresi 24 ay olanları seç; iki deal'den ayda $40-50 bin kazanılır; işletim ve oyun sistemleri en çok öder ve en uzun sürer; "dördüncü iterasyona kadar götür ki itibar yıldızları artsın"; deal'i eğitim için kullanıyorsan hata ayıklamaya 2-3 ay ayır. Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=1971495059 (LatN, oyuncu). Sözleşmelerde hata başına ceza var, en küçük cezalı sözleşmeyi seç, hızlı yayınla: https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114 (oyuncu).
- Hosting deal'inde ödeme iş itibarına bağlı; erken oyunda zarar, geç oyunda kâr (Steam hata raporu, moderatör açıklaması): https://steamcommunity.com/app/362620/discussions/1/3016815718822912355/

### 8.3 Football Manager ve diğerleri

- FM (ikincil rehber, fmscout "induction" yazısı, sürüm FM24): sözleşmeden önce oyuncuyla "kariyerine yön verecek vaatler" ve "oynama süresi seviyesi" kararlaştırılır; teklifin temel öğeleri statü, sözleşme türü ve süresi, başlangıç tarihi; maaş oyuncunun kadrodaki önemini işaret eder; "imza parası" ya da "ajan ücreti" ve "maç primi" ikna etmek için eklenir; "ilk denemede nadiren anlaşılır", anlaşma yoksa "bir şey olmaz", oyuncu masadan kalkılabilir; bozulan vaatler mutsuz oyuncu yaratır. Kabul olasılığının nasıl gösterildiği, ret sonrası kilit süresi, kadro tablosu görünümleri yazıda YOK. Kaynak: https://www.fmscout.com/a-football-manager-2024-induction-hints-and-tips.html
- Motorsport Manager sponsor yenilemeleri: wiki bulunamadı (arama sonucunda yok; tahmin edilen iki Fandom adı "wiki yok" döndü). Big Ambitions B2B sözleşmeleri ve işletme puanı: wiki.gg üç denemede açılmadı (HTTP 401 ve boş sayfa). Two Point Hospital itibar kırılımı R8 §7'de.

### 8.4 Bu tamamlamanın §7 listesine etkisi

- Kapandı (kısmen): ekran örneği olarak Startup Company sözleşme müzakeresi; Software Inc deal türleri ve hosting ödeme aralığı; FM'de vaat ve teklif unsurları.
- Hâlâ bulunamadı: yenilemeyi kimin ve kaç gün önce başlattığı, yenileme sonuç dağılımı, ACV eşiği, cure period örnekleri, sağlık skoru ağırlıkları, CS/CRM listeleri (oyun dışı kaynaklar, bu turun kapsamı dışında kaldı), FM kabul olasılığı gösterimi, Motorsport Manager ve Big Ambitions içerikleri, oyuncu istismarları ve yama notları.
