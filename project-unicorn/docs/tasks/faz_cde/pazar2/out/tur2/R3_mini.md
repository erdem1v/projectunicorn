# R3 · Mini araştırma: önerilen fiyat, YZ dönemi ve Ar-Ge tavanı, yıllık rapor ve modül ödülü

Erişim tarihi (tüm kaynaklar): 2026-10-21. Arama: 15 WebSearch (bütçe doldu, hata dönen yok). Ek olarak serbest WebFetch. Oyun koduna, CSV'ye, data/'ya yazılmadı; yeni simülasyon koşulmadı.
Etiketler: [BOŞLUK] kanıtsız yük taşıyan iddia ya da bulunamayan · [SIÇRAMA] kanıttan çıkmayan sonuç · [GÖRÜŞ] benim yargım · (varsayım) · (hesap) benim aritmetiğim · [WORKING] kalibrasyon girdisi.
`[S#]` bu belgenin sonundaki sicil; `[F1-S8]`, `[F2-S3]`, `[S1-S19]` gibi önekliler tur 2 belgelerinden devralındı (F1_fiyat_erp, F2_fiyat_oyun, S1_siralama_gercek, Y_bitis_yili).

---

## ÖZET

**A) Önerilen fiyat (Erdem 30)**
1. Fiyat kararını yoran şey hesap sayısı × modül sayısı çarpımıdır (Big Ambitions: 60-70 mağazada "kâbus" [F2-S7, F2-S8]); önerinin tek doğru cevaba çökmesi ise Software Inc'te gösterildi (bir oyuncu "ya ücretsiz ya önerilen fiyat" yazdı, tek koşu, Düşük; V2 rakamlara yaslanma dedi) [F2-S3]. Üç duruş + formülle hesaplanan öneri bu iki riskin ikisini de karşılar; yeni kaynak aramadım, F2 yeterli.
2. Modül ağırlıkları gerçek listelerden türüyor: ağır modül (Mikro Üretim %79, Logo e-Fatura %57) hafif modülün (Mikro Perakende %29, Logo e-Arşiv %20) yaklaşık 2,7-2,9 katı (hesap) [F1-S7, F1-S8]. Yeni: Microsoft SCM 210 $, Premium 300 $ (1,43 kat) [S6]; BC 80/110 (1,375 kat) [F1-S1]. Fiyat-kalite ilişkisi için iyi kaynaklı akademik/iktisat çalışması bulunamadı [BOŞLUK]; yalnız danışman blogları (Düşük) [S4, S5].
3. İndirimle kazanılan müşterinin churn'ü: yön tutarlı ("daha çok indirim, daha çok churn") ama büyüklükler (ChartMogul "%40 üstü indirimde 2,3 kat", Price Intelligently "LTV -%30", HubSpot "+%40") ikinci elden ve doğrulanamadı [S2]. McKinsey sayfası iki kez zaman aşımı verdi, yalnız arama özetinden okundu [S1]. Sayıyı koda yazma.
4. Fiyat artışı sonrası kayıp ve premium fiyatın kapanışı düşürme oranı için kaynaklı sayı bulunamadı [BOŞLUK]. Bulunanlar blog düzeyinde ve izlenemez ("%15 fazla fiyat dönüşümü yarıya indirir" Düşük, kaynaksız) [S3, S4].
5. Öneri formülü (yalnız belge, §A4): fiyat = P0 × (1 + Σ modül ağırlığı) × K̄; K̄ ağırlıklı kalite çarpanıdır, 0,75-1,25 arası. Ucuz/standart/premium = ×0,85 / ×1 / ×1,15 (kodda zaten var, değişiklik yok). 1 koltukta da 1.000 koltukta da birim fiyat aynıdır. Hacim indirimi gerekli değil (Erdem "sorun değil"); istenirse tek tablo olarak sonra eklenir (Logo: +10 blokta +2 bloğa göre -%28 [F1-S8]).
6. Rakibin fiyatı aynı formülle rakibin modül kalitelerinden çıkar: yeni veri yazmak gerekmez ve "kopyalama yok" ilkesiyle uyumludur (kodda rakip fiyat alanı yok [K2 §1.5]).

**B) YZ dönemi ve Ar-Ge tavanı**
7. "YZ furyası" iki aşamalıdır ve iki aşama da kaynaklı: ML/otomasyon duyuruları SAP Leonardo 18 Mayıs 2017 [S7, S8], Oracle Adaptive Intelligent Apps 2 Ekim 2017 [S9, S10], NetSuite "ilk akıllı bulut suit" 24-25 Nisan 2018 [S11], Microsoft Dynamics 365 AI 18 Eylül 2018 [S12, S13]; üretken YZ asistanı Mart 2023 (Copilot), Eylül 2023 (Joule) [B_bilinen_yol, A1]. 2019-2020'ye özgü bir kilometre taşı bulunamadı [BOŞLUK]; "2020 civarı" Erdem'in örneğidir, kaynağım onu 2017-2018 olarak gösteriyor.
8. İlk dalga olgunluktan çok duyurudur: Microsoft'un üç YZ modülü duyuru günü "önümüzdeki aylarda" gelecekti [S12]; Oracle'ın uygulamaları ayrı SKU, fiyat açıklanmamış [S9]; analist SAP'nin Leonardo'yu zayıf S/4HANA benimsemesinden dikkat dağıtmak için kullandığını yazdı [S7]; Gartner'ın 2017 gelişen teknolojiler döngüsünde ML ve derin öğrenme "abartılı beklenti zirvesi"ndeydi (ikincil aktarım) [S15]. Oyunda bu hat 2018'de açılır ama ilk kademe düşük kazançlıdır.
9. Ar-Ge'nin tavan yükseltmesi oyunlarda yerleşik bir kalıp: Virtonomica'da teknoloji seviyesi azami ürün kalitesini sınırlar, tabloyla gösterilir (seviye 10 = 19,95; seviye 25 = 65,66) ve yüksek seviye nitelikli personel ister [S16]; Capitalism Lab'de teknoloji yazılım ürünlerinin başarısını belirler ve geride kalan için yetişme çarpanı vardır [S17]; Civ'de son teknoloji tekrar araştırılabilir, oyun sonu boşluğu ve son teknolojilerin kartopu etkisi bilinen sorundur [S18]. Tavan kilidine "yapay engel" şikâyeti bulunamadı [BOŞLUK].

**C) Yıllık rapor ve modül ödülü**
10. Rozetin satın almaya etkisini ölçen bağımsız çalışma bulunamadı [BOŞLUK]. En yakın kanıt G2'nin kendi vaka çalışması: Leader durumunu LinkedIn'de tanıtan Looker'ın ücretli kanal lead'leri yıldan yıla 2 kat, dönüşüm %3 (baz yok, Düşük) [S21]. Yani ölçülmüş karşılık kapanış değil, aday akışıdır.
11. Gartner Customers' Choice eşiği: 12 ayda en az 50 yayımlanmış yorum, ortalama 4,2 ve üstü (v1.3), pazar başına en çok 7 satıcı, 50 milyon dolar altı şirket yorumları sayılmaz (v1.4) [S22]. G2 eşiği (tur 2): kategoride ürün başına en az 10 yorum [S1-S3].
12. Yıllık "en büyük + en hızlı büyüyen" listeleri: Inc. 5000 yüzdesel gelir büyümesiyle sıralar; 2026 listesi 2022-2025 büyümesi, 2022'de en az 100 bin dolar, 2025'te en az 2 milyon dolar gelir, ABD merkezli, özel, bağımsız [S23]. Deloitte Fast 500 (Kuzey Amerika, 2024): en az 4 yıl, taban yılı en az 50 bin dolar, cari yıl en az 5 milyon dolar, büyüme %75 ve üstü, gelirin %50'den fazlası kendi teknolojisinden [S26]. Forbes Cloud 100: yalnız özel ve bağımsız şirketler, CEO jürisi, 2021'de giriş için tahmini değerleme 1 milyar dolar üstü [S27, S28]. Büyüme listeleri küçüğe açık (gelir tabanı düşük), büyüklük listesi kapalı.
13. Yayın zamanı: Inc. 5000 Ağustos (2024 yayını 14 Ağustos civarı, ikincil) [S25], Cloud 100 2025 raporu 3 Eylül [S27], Bilişim 500 5 Ağustos 2026 [S1-S13], Gartner bulut ERP MQ'su 11 Kasım 2024 [S1-S1]. Deloitte Fast 500'ün duyuru ayı bulunamadı [BOŞLUK].

**Önerim tek cümlede:** fiyat öneri formülü + üç duruş (A), YZ iki aşamalı hat 2018 ve 2023 (B), ödül = o modülü isteyen adaylara 12 ay boyunca aday akışı çarpanı, rapor her yıl Kasım'da (C).

---

## Oyuna dersler

- **D-A1 Fiyat nasıl önerilsin:** oyuncuya tek "optimal" sayı değil, formülle hesaplanan piyasa duruşunun üç konumu gösterilir (ucuz/standart/premium), her konumun neyi değiştirdiği yazılı (kapanış şansı sözcükle, aylık toplam, hesabın bütçe aralığı, rakibin standart teklifi). Oyuncu her teklifte tek tık atar (sık), kolay. Neden: Software Inc'te tek sayı oyunu çözülür yaptı, Big Ambitions'ta ise hesap başı serbest fiyat angarya oldu [F2-S1, F2-S3, F2-S7].
- **D-A2 Kalite fiyata nasıl girer:** modül kalitesi fiyatı ağırlığıyla oranlı oynatır (ağır modülün zayıflığı daha çok ucuzlatır); oyuncunun kararı hangi modülü geliştireceği olur, ayrı fiyat kararı gerekmez. Sıklık: sürüm başına bir kez etkisi görünür. Kolay: tek formül, ≈30 satır [K2 §1.6].
- **D-A3 İndirim bedeli:** "ucuz"un bedeli MRR'ın düşük olmasıdır ve ekranda görünür. Churn'e gizli bağlama (kaynaklar zayıf ve Erdem'in "gizli ceza yok" kuralı). Karşılığında fiyat-değer farkı memnuniyette görünür bir gerekçe olabilir (pahalı teklif zayıf modüllerle: "bu fiyata göre eksik buluyor"). Sıklık: hesap başı, imzada ve yenilemede. Orta.
- **D-B1 İki aşamalı YZ hattı:** 2018 "Akıllı otomasyon" (ML, tahmin) ve 2023 "YZ yardımcısı". Her biri Ar-Ge kartı tamamlanınca seçili modüllerin kalite tavanını yükseltir. Oyuncunun kararı hangi araştırmayı ne zaman bitireceği: dönem başına 1-2 kez. Orta (veri satırı + tavan alanı).
- **D-B2 Tavan açık yazılsın:** "tavan şimdi X, bir sonraki Y, şu araştırmayla" (Virtonomica tablosu gibi); dönemin açtığını (dünya) ile oyuncunun açtığını (Ar-Ge) ayır. Kolay.
- **D-C1 Ödül tek karşılık:** o modülü isteyen adaylar için aday akışı çarpanı, 12 ay, ekranda süresiyle. Kapanış zarına dokunma (ölçülmüş etki yok). Yılda bir. Kolay.
- **D-C2 Rapor:** yılda bir, Kasım; B2B'de modül ödülleri aynı anda, B2C'de yalnız en büyük + en hızlı büyüyen. Demoda iki rapor (Kasım 2012 ve Kasım 2013). Küçük şirket için "en hızlı büyüyen" listesi ve segment bandı kapıdır; "en büyük" listesine girmesi beklenmez.

---

## A) Önerilen fiyat

### A1. Değer bazlı fiyatlama ve modül oranları

**Bulgular**
- Satıcı fiyatının nasıl türetildiğini anlatan resmî kaynak yok [BOŞLUK, F1 §3]. Bu turda eklenen tek resmî fiyat verisi Microsoft SCM sayfasıdır: Supply Chain Management 210 $/kullanıcı/ay, Premium 300 $ (kullanıcı başı, yıllık ödemeli), Intelligent Order Management 315 $/ay (kullanıcı başı değil, 1.000 sipariş satırı); Finance ve Commerce için sayfada fiyat yok; "attach" lisansı sayfada geçmiyor [S6]. Premium/standart = 300/210 = 1,43 (hesap); F1'deki Finance 1,43 ve BC 1,375 ile aynı aralık [F1-S1, F1-S16]. Yani kalıcı sürüm farkı bu üç Microsoft ürününde 1,38-1,43 kat.
- Acumatica sayfası hiç tutar vermiyor (kaynak/uygulama bazlı) [F1-S17]; Sage fiyat sayfası 403 [F1]; Odoo Standard-Custom farkı yaklaşık 1,9-2 kat (11,90→22,90; 14,90→27,90 €) [F1-S2]. Bu turda yeni Acumatica/Sage/Odoo kaynağı eklenmedi.
- Modül ağırlığı: ağır/hafif modül oranı 2,7-2,9 kat (hesap): Mikro Üretim 41.800 / Perakende 15.200 = 2,75; Logo e-Fatura 77.300 / e-Arşiv 26.800 = 2,88 [F1-S7, F1-S8]. Gerçekte bu tutarlar sabit tutardır, koltukla çarpılmaz; oyunda yüzde alınması "1 kişide de 50 kişide de kırılmaz" kuralı içindir [F1 §4].
- Fiyat-kalite ilişkisi: "iş müşterilerinin yaklaşık %40'ı yüksek fiyatı daha iyi kaliteyle ilişkilendirir (özellikle teknolojide)" iddiası McKinsey'e atfedilerek bir satıcı blogunda geçiyor; özgün rapora ulaşılamadı [S4, Düşük]. "Prestij fiyatı kurumsal alıcıda ve rakip karşılaştırması zor üründe işler; emtialaşmış kategoride ve self-servis akışta işlemez" görüşü de blog düzeyinde [S5, Düşük]. İyi kaynaklı iktisat ya da pazarlama çalışması (premium/parite/penetrasyon konumlandırması) bulunamadı [BOŞLUK].
- Premium kademe aboneleri daha düşük churn gösteriyor (%23 daha düşük, ChartMogul'a atfen) ama bu seçilim etkisi olabilir [S4, Düşük, [SIÇRAMA] uyarısı].

**Oyuna ders (A1):** modül ağırlığı için kaynağa yakın sayı "ağır = hafifin yaklaşık 3 katı"; kalite primi için kaynaklı bir büyüklük yok, bu yüzden prim aralığını (±%25) Microsoft'un sürüm farkı (1,38-1,43 kat) kadar dar tut ve [WORKING] bırak. Oyuncunun kararı fiyat primi değil, hangi modülü iyileştireceği.

### A2. Fiyatın kapanışa, memnuniyete ve churn'e etkisi

| İddia | Kaynak | Güven | Not |
|---|---|---|---|
| Ağır indirim LTV'yi düşürür, churn'ü artırır (McKinsey: LTV "sekiz kata kadar" düşük) | [S1] arama özeti | Orta-Düşük | Sayfa iki kez açılmadı, veri gösterilmediği yazılı |
| İndirimli kazanılan müşteri: Price Intelligently "uzun vadeli değer -%30"; ChartMogul "%40 üstü indirimde yenilemede 2,3 kat churn"; HubSpot "promosyon dönemi alıcıları %40 daha çok churn" | [S2] | Düşük | Hepsi ikinci el, özgün kaynak bulunamadı |
| Fiyat artışını değerle iletmek churn'ü azaltır (ProfitWell'e atfen -%70; 45 gün önceden haber -%30); churn edenlerin %40'ı "değerine göre pahalı" demiş (Paddle 2022'ye atfen) | [S3] | Düşük | Özgün çalışma bulunamadı, aynı blog |
| Mevcut müşteri yılda %8-12 zammı tolere eder | [S3] | Düşük | Kaynaksız |
| Fiyatı %15 fazla koymak deneme→ücretli dönüşümü yarıya indirir | [S4] CleverX atfı | Düşük | Kaynaksız pratik kural; kullanma |
| Kazanma oranı ortalama %22 (B2B SaaS), en iyi %10 için %35 üstü | [S4] PayPro Global atfı | Düşük | İkinci el |
| Premium fiyat kapanış oranını şu kadar düşürür | bulunamadı | | [BOŞLUK] |

Kayıp başarısızlık örneği: bir danışman örneği (win-rate %35→%22, kaybedilenlerin %63'ü "fiyat karmaşıklığı" demiş) gerçek veri değil, açıklayıcı vaka [S4, Düşük]; sayı alınmadı.

**Oyuna ders (A2):** yön tek: ucuz teklif daha çok kapanır, ucuza kazanılan hesap daha kırılgandır; büyüklük kaynaksız. Bu yüzden: (a) kapanış etkisi [WORKING] ve sözcükle gösterilir (ucuz: yüksek şans, premium: düşük şans), (b) churn'e doğrudan stance bağı kurma; gizli ceza kuralına ters, (c) "pahalı bulunuyor" yalnız fiyat-değer farkında (görünür gerekçe) ortaya çıksın. Neden: indirim-churn ilişkisi kanıtsız büyüklükte; oyunun adil ekonomi kuralı gizli bedeli yasaklar.

### A3. Oyunlarda "önerilen fiyat" ve çökme riskini azaltma

Bu turda yeni oyun kaynağı eklenmedi; F2 yeterli (arama bütçesini B ve C'ye ayırdım).
- Software Inc: önerilen fiyat gösteriliyor ve oyuncular kopyalıyor [F2-S1]; tek oyuncu testi kârın önerilen fiyatta tepe yaptığını söylüyor ama V2 bu rehberi açamadı (rakamlara yaslanma) [F2-S3].
- Big Ambitions: piyasa fiyatı + "önerilen fiyatları uygula" + Fiyat Müdürü; rehber körü körüne uygulamamayı söylüyor; iki yerde iki farklı rakam güveni kırdı [F2-S6, F2-S9].
- Two Point Hospital: yüzde kaydırıcı; oyuncu "%100 bırak" miti üretti, çünkü ret nedeni tek çubuğa bağlı ve görünmez [F2-S12, F2-S13].
- Capitalism Lab: fiyatın ağırlığı ürüne göre değişiyor (sigara %25, dondurulmuş et %40) [F2-S17].
- Fiyat-kalite ilişkisi kurulmuş bir "tycoon" oyununda oyuncu tepkisi: bulunamadı [BOŞLUK].

**Çökmeyi azaltma yolları** (kaynaklı kısmı F2'den; gerisi [GÖRÜŞ]):
1. Öneriyi tek sayı değil üç duruş yap ve "optimal" sözcüğünü kullanma (Software Inc dersi) [F2-S3].
2. Rakibin standart teklifini göster; formül rakip için de çalışır, yeni veri gerekmez [GÖRÜŞ, K2 §1.5].
3. Duruşun getirisi hesap profiline göre değişsin: fiyat duyarlı, kalite duyarlı, destek duyarlı arketip (Capitalism Lab ağırlık karışımı) [F2-S17].
4. Her kaybın nedeni satırda yazılı ("teklif bütçenin %X üstündeydi") [F2 D4].
5. Kapanış zarlı olsun: aynı duruş aynı sonucu garanti etmez; "tek doğru" kesin kâr yerine ihtimaldir [GÖRÜŞ].
6. Fiyat kararı hesap başına serbest sayı olmasın; üç tık yeter (Big Ambitions toplu uygulama düğmesini sonradan ekledi) [F2-S6].

### A4. Öneri formülü taslağı (yalnız belge, kod yok; hepsi [WORKING])

Girdiler: hesabın istediği modül kümesi M; her modülün ağırlığı w_m; her modülün kalitesi q_m; o yılın piyasa standardı q_std,m (dönem tablosunda var).

```
r_m   = q_m / q_std,m                     (1 = piyasa standardı)
k_m   = clamp( 1 + 0,5 × (r_m - 1) ; 0,75 ; 1,25 )
K̄     = Σ(w_m × k_m) / Σ(w_m)             (ağırlıklı ortalama kalite çarpanı)
standart koltuk fiyatı = P0 × (1 + Σ w_m) × K̄
ucuz = standart × 0,85 ;  premium = standart × 1,15
anlaşma (aylık) = koltuk × seçilen koltuk fiyatı
```
P0 = 30 $ (bugünkü bandın tabanı [K2 §1.1]); w: hafif 0,10 / orta 0,20 / ağır 0,30 (ağır = hafifin 3 katı, §A1 hesabı).

Örnekler (hesap, yuvarlanmış):

| Durum | Σw | K̄ | Standart | Ucuz | Premium |
|---|---|---|---|---|---|
| 2 modül (1 hafif, 1 orta), standart kalite | 0,30 | 1,00 | $39 | $33 | $45 |
| 5 modül (2 hafif, 2 orta, 1 ağır), standart kalite | 0,90 | 1,00 | $57 | $48 | $66 |
| Aynı 5 modül, ağır modül zayıf (r=0,5 → k=0,75) | 0,90 | 0,92 | $52 | $44 | $60 |
| Aynı 5 modül, hepsi zayıf (k=0,75) | 0,90 | 0,75 | $43 | $36 | $49 |
| Aynı 5 modül, hepsi iyi (k=1,25) | 0,90 | 1,25 | $71 | $61 | $82 |
| 10 modül (4 hafif, 4 orta, 2 ağır), standart kalite | 1,80 | 1,00 | $84 | $71 | $97 |

Özellikler:
- **Zayıf modül ucuzlatır, iyi modül pahalandırır:** K̄ ağırlıklı olduğu için ağır modülün kalitesi fiyatı hafif modülden 3 kat çok oynatır (tablo 3. satır: tek zayıf ağır modül -%8; hepsi zayıf -%25; hepsi iyi +%25).
- **1 koltukta da 1.000 koltukta da çalışır:** birim fiyat koltuk sayısından bağımsız; anlaşma = koltuk × fiyat. 5 modüllü standart hesap: 1 koltuk $57/ay, 1.000 koltuk $57.000/ay. "Koltuk artışı beklentiyi artırmaz" kuralıyla uyumlu (fiyat koltuğa bağlı değil).
- **Hacim indirimi gerekli mi:** Erdem 5★'ın yüksek gelirini sorun görmedi (K2: 1.000 × $50 = $50.000/ay [K2 §1.1]; yukarıdaki 5 modüllü hesap 1.000 koltukta $57.000, 10 modüllü $84.000). Gerçekte hacim indirimi var (Logo +10 blokta +2 bloğa göre -%28 [F1-S8]; NetSuite 3 yıllıkta %20-30, Düşük [F1-S12]) ama ilk sürümde eklenmez; SENTEZ G11 tavanı (tek 5★ ≤ 20.000 $) bu çarpımla çelişir ve ayrı karardır [K2 §1.1 madde 4]. Gerekirse tek tablo: ≥100 koltuk -%10, ≥300 -%20, ≥1.000 -%28 [WORKING, Logo'dan]; formül değişmez.
- **Bant:** bugünkü $30-70 tek bandı (`SEAT_PRICE_MIN/MAX`) formül çıktısına göre kalkar ya da genişler (üst uç ≈ $84 × 1,25 × 1,15 = $121); K2 bunu zaten "yıldız/modül bandına dönüşür" olarak yazıyor [K2 §1.6].
- **Üç duruş çarpanı:** ×0,85 / ×1 / ×1,15 bugünkü `STANCE_MULT`'tur [K2 §1.1]; gerçek pazarlıklı indirim daha geniş (%20-40, Düşük [F1-S12]) ama üç düğme için ±%15 yeterli; farkı etkiler yaratır (kapanış, MRR, fiyat-değer memnuniyeti). Alternatif ×0,80 / ×1 / ×1,20 sim sonrası denenebilir.
- **Eksik/belirsiz:** hesabın istediği modül kümesinin bir hesapta kaç modül olacağı (P_sektor_profil işi), q_std'nin dönemle nasıl yükseldiği (Erdem K3), kalite primi aralığının doğruluğu (kaynaksız).

**Oyuna ders (A4):** oyuncu için üç düğmelik teklif, altında formülün gerekçesi (modül listesi ve kalite durumu). Karar sıklığı: her teklifte bir tık. Kodda "kolay" (formül ≈30 satır), modül listesi hesapta hazırsa.

---

## B) YZ dönemi zamanlaması ve Ar-Ge tavanı

### B1. 2016-2022 ERP ve yazılımda ML/otomasyon öncüleri

| Tarih | Olay | Ne olduğu | Kaynak | Güven |
|---|---|---|---|---|
| 15-18 Mayıs 2017 (SapphireNow) | SAP Leonardo | ML, IoT, büyük veri, blockchain'i SAP Cloud Platform üstünde birleştiren çerçeve; TensorFlow'u seçti; yazılım uygulamalarını 5-7 yılda akıllı ve otomatik yapma hedefi; müşteri çalıştayları Q3'ten itibaren, ürün proje içinde ücretsiz | [S7, S8] | Orta |
| 2 Ekim 2017 (OpenWorld) | Oracle Adaptive Intelligent Apps | Finans, İK, tedarik, üretim, ticaret, müşteri hizmetleri, pazarlama, satış için mevcut bulut uygulamalarına gömülü YZ uygulamaları; ayrı SKU eklenti, fiyat açıklanmamış | [S9, S10] | Orta-Düşük |
| 24-25 Nisan 2018 (SuiteWorld18) | NetSuite "ilk akıllı bulut suit" | AI/ML'yi iş uygulamalarına gömme; finansta denetim riski analizi, nakit akışı tahmini; İK'da aday profili; üretimde tahmine dayalı bakım; kullanılabilirlik tarihi ve fiyat yazılmamış | [S11] | Orta |
| 18 Eylül 2018 | Microsoft Dynamics 365 AI (Satış, Müşteri Hizmetleri, Pazar İçgörüleri) | Hazır YZ uygulamaları; "önümüzdeki aylarda büyüyecek"; sonra Satış için GA ve kullanıcı başı 50 $ eklenti | [S12, S13, S14] | Orta (S14 Düşük) |
| 2017 (Gartner) | ML ve derin öğrenme "abartılı beklenti zirvesi"nde | Gelişen teknolojiler döngüsü, ikincil aktarım | [S15] | Orta-Düşük |
| 6 Mart 2023 / Eylül 2023 | Dynamics 365 Copilot / SAP Joule | Üretken YZ asistanı | [B_bilinen_yol, A1] | tur 2 |

**Eleştiri ve başarısızlık işaretleri (ayrı arama sorusu "olgunluk" değil, aynı sonuçların içinden):**
- Analist Holger Mueller: Leonardo, zayıf S/4HANA benimsemesinden dikkat dağıtan yeni bir hikâye ("yüksek teknoloji satıcılarının hileli numaralarından biri"); ERP paketi kurmak yıllar alır; Hadoop desteği eksikliği "uyarı işareti" [S7].
- The Register: Microsoft'un YZ modülleri duyuru günü hazır değil, "önümüzdeki aylarda"; müşteri hizmetinde bot "nadiren keyif verir" [S12].
- eWeek (arama özeti): Oracle uygulamaları ayrı eklenti SKU'su, fiyat açıklanmamış; kullanılabilirlik tarihi tutarsız [S9].
- Sonradan: NetSuite ödeme tarihi tahmini "ek ücretsiz" sunuluyor ama tarih belirsiz [arama özeti, kaynak olarak sayılmadı].

**Kanıtın söylediği:** "2018-2020 çizgisi" kaynaklı olarak 2017-2018 duyuru kümesidir (dört büyük satıcı 17 ay içinde). 2019 ve 2020'ye özgü kilometre taşı bu turun aramalarında çıkmadı [BOŞLUK]; 2019'da Gartner'ın kurumsal YZ benimseme anketi (%37) 403 verdi, kullanılmadı. RPA, Odoo ve Dynamics 365 ERP'ye özgü ML için ayrı arama yapılmadı [BOŞLUK]. Erdem'in "2020 civarı" sezgisi oyuna ilk dalga 2018 olarak girse tutar; ürün olgunluğu açısından 2020'ye kadar sürmüş olabilir (ikinci el sezgi, [GÖRÜŞ]).

**İki aşamalı dönem hattı önerisi** (tarih ± 2 çeyrek, SENTEZ §9.1 kuralı):

| Aşama | Ad | Açılış | Dayanak | Oyunda etkisi |
|---|---|---|---|---|
| 1 | Akıllı otomasyon (ML, tahmin, öneri) | 2018 (örn. Nisan 2018: NetSuite "ilk akıllı bulut suit") | [S7, S9, S11, S12] | Yeni hat; ilk kademe düşük kazançlı; Ar-Ge'de "Makine öğrenmesi" araştırması seçili modüllerin tavanını +1 kademe yükseltir |
| 2 | YZ yardımcısı (üretken) | 2023 (Mart-Eylül) | [B_bilinen_yol, A1] | Mevcut tur 2 satırı; Ar-Ge'de "Üretken YZ" tavanı yükseltir; ~2027'de 5★ için standart |
| 3 (isteğe bağlı) | Ajan YZ | 2027-2028 | Gartner: 2028'e kadar kurumsal yazılımın %33'ü ajan YZ içerecek [Y_bitis_yili §3] | 2030 sonu bitiş için son yükseltme; kaynak 2028'de bitiyor |

Not: Erdem 26-27: hat 10 modüllü, kademeler dönemle açılır, Ar-Ge ağacı tavanı sürekli yükseltir, "2-3 yılda ERP bitmesin". Aşama 1 ve 2 arası 5 yıl var; araştırma kartları bu boşluğu doldurur (ör. 2019-2022 arası "API/otomasyon", "bulut yerlisi" kademeleri; kaynak bulunamadı [BOŞLUK, A1 notu]).

**Oyuna ders (B1):** iki aşama tarihli kaynaklarla güvenle yazılır; "furya" yerine "duyuru dalgası" daha dürüst bir ad. Oyuncunun kararı: araştırmayı ne zaman bitireceği (dönem başına 1-2 kez); rakipler aynı Ar-Ge ağacıyla çalıştığı için aşama 1'de de erken davranmak avantaj verir, geç kalmak ceza değildir (Erdem 11).

### B2. Oyunlarda Ar-Ge ile geliştirme tavanı

| Oyun | Mekanik | Oyuncu tepkisi | Kaynak |
|---|---|---|---|
| Virtonomica | Teknoloji seviyesi azami ürün kalitesini sınırlar; tablo: seviye 10 → 19,95, seviye 25 → 65,66; araştırma seviyeyi yükseltir ya da seviye teknoloji/lisans satın almayla elde edilir; laboratuvar boyutu araştırılabilir seviyeyi sınırlar; yüksek seviye nitelikli personel ve ekipman ister | Şikâyet bu sayfada yok (yardım sayfası) | [S16] Orta-Düşük |
| Capitalism Lab (Digital Age) | Teknoloji araştırması yazılım ve internet şirketlerinin başarısını belirler; geride kalan için yetişme çarpanı: ek kazanç = baz kazanç × (en yüksek seviye − seviyen) / en yüksek seviye; sayfada azami seviye ya da kalite tavanı yazılmıyor | Bulunamadı | [S17] Düşük (geliştirici anlatımı) |
| Civilization ve tech tree | Araştırma birim/bina/yetenek açar; son teknoloji tekrar araştırılabilir (Civ IV: sağlık ve mutluluk, Civ V: skor); "oyunun sonunda yapacak yararlı iş kalmaması"; Rise of Nations'ta son dört teknoloji kartopu avantajı yaratıp oyunu çabuk bitirir | Akademik/topluluk eleştirisi bu sayfada yok | [S18] Orta |
| Game Dev Tycoon | R&D laboratuvarı "başka türlü yapamayacağı şeyleri" açar; Wikipedia ilerleme alımını değerlendirmiyor; Steam başlıkları: mekaniklerin çoğu gizli ("rehbersiz kör yürüyüş"), 2013'te "hangi etken birleşimi en iyisi tahmin et" oyunu; 2020'de güncelleme sonrası araştırma kaybı ("oynamak istemiyorum") | Açılımlardan keyif alanlar da var | [S19, S20] Orta / Düşük |
| Software Inc | Bu turda ayrı arama yapılmadı, bulunamadı | | [BOŞLUK] |
| "Tavan kilidi yapay engel" şikâyeti | Hiçbir kaynakta bulunamadı | | [BOŞLUK] |

**Oyuna ders (B2):**
1. **Tavan görünür olmalı** ve ne yükseltir yazılı: Virtonomica tablosu bunu yapıyor; Game Dev Tycoon'un gizli mekanikleri en çok şikâyet edilen şey [S16, S20].
2. **Geride kalana yetişme payı:** rakipler aynı Ar-Ge ağacıyla çalışıyor; Capitalism Lab'in yetişme formülü kartopu riskini azaltır [S17]. Kopyalama yok ilkesiyle çelişmez (kopya değil, kazanç oranı).
3. **Oyun sonu boşluğu:** son teknoloji araştırıldıktan sonra yapacak iş kalmaması bilinen sorun [S18]; Erdem "2-3 yılda ERP bitmesin" dedi: tavan basamakları 2030 sonuna yayılmalı, aşama 3 (ajan YZ) bunun için isteğe bağlı olarak durur.
4. **Dönem açar, Ar-Ge yükseltir ayrımı:** dönem yeni hat ve kademe açar (dünya olayı); Ar-Ge ağacı o hattın tavanını yükseltir (oyuncu emeği). Bu ayrım "yapay engel" algısını azaltır ama kaynakla doğrulanmadı [GÖRÜŞ].
5. **Kayıt güvenliği:** Game Dev Tycoon'da araştırma ilerlemesi güncelleme sonrası kaybolunca oyuncu bıraktı [S20]; Ar-Ge ilerlemesi kayıtta kalıcı olmalı (oyunun kayıt şeması zaten göç taşıyor).
Karar sıklığı: araştırma başına bir kez (dönem başına 1-2). Kolay: bir tavan alanı + araştırma kartı etkisi.

---

## C) Yıllık rapor ve modül ödülü kurgusu

S1/S2 tekrarlanmadı; yalnız boşluklar.

### C1. "En iyi X modülü" tipi ödül örnekleri ve satın almaya etkisi

| Ödül/liste | Eşik ve ölçüt | Etki kanıtı | Kaynak |
|---|---|---|---|
| Gartner Peer Insights Customers' Choice | Son 12 ayda en az 50 yayımlanmış yorum, ortalama genel puan 4,2 ve üstü (v1.3); sonraki sürümde pazar ortalamasının üstü ve PARC (müşteri tabanına göre yorum kapsamı) medyanın üstü; pazar başına en çok 7 satıcı; 50 milyon dolar altı şirketlerin yorumları sayılmaz; kategori ayrımı: kategoride en az 25 yorum ve pazar ortalamasının üstü | Etki ölçümü bulunamadı [BOŞLUK] | [S22] Orta-Düşük (sayfalar şimdi yönlendiriliyor, arama özeti) |
| G2 Grid Leader | Üç ayda bir; kategoride ürün başına en az 10 yorum; segmentler (≤50, 51-1.000, ≥1.001 çalışan); memnuniyet + pazar varlığı | Looker (G2'nin kendi vakası, 29 Haziran 2020): Leader durumunu LinkedIn'de tanıtan sponsorlu içerikle ücretli kanal lead'leri yıldan yıla 2 kat, dönüşüm %3, tıklama oranı ortalamanın 6 katı; baz verilmemiş, kapanış oranı ölçülmemiş | [S21] Düşük; eşikler [S1-S3] |
| G2 Leader oranı | "Ürünlerin yalnız %3'ü bir sezonda Leader rozeti alır" | Bir satıcı blogu | [arama özeti, kaynak sayılmadı, Düşük] |
| TrustRadius alıcı anketi (2026) | alıcıların %74'ü yorumu, %13'ü analist raporunu kullanıyor; %83'ü en çok 3 ürünü kısa listeye alıyor | Aday akışı/kısa liste mantığını destekler | [S1-S19] Orta |
| Capterra Shortlist, PCMag Business Choice, SAP/Oracle ortak ödülleri, Software 500 | Aranmadı / bulunamadı | | [BOŞLUK] |
| Ödüller kanıtlanmış mı? | "Rozetin kapanış oranını yükselttiğini gösteren bağımsız çalışma" bulunamadı | | [BOŞLUK] |

Başarısız/eleştirilmiş: rozet enflasyonu (bir satıcı sayfasında yıllık ~39-50 rozet) [S1-S25]; sahte yorum ve teşvik [S1-S21]; Customers' Choice'ta küçük şirket yorumlarının sayılmaması küçük satıcı için kapıyı daraltıyor [S22]. Rozet satışı gerçekten artırıyor mu sorusu açık.

### C2. Ödülün B2B'deki TEK görünür karşılığı ne olsun

| Seçenek | Kanıt | Karar kolaylığı | Risk |
|---|---|---|---|
| Aday akışı (inbound lead) çarpanı | Ölçülmüş tek sayı lead'dir (Looker 2×, ücretli kanal, Düşük) [S21]; alıcı kısa listesi ≤3 ürün [S1-S19] | Oyuncu ödülü modülü iyileştirerek kazanır, etkisi aday ekranında görünür | Büyüklük kaynaksız [WORKING] |
| 4-5★ kısa listeye girme | Kısa liste mantığı destekli [S1-S19] ama rakip kısa liste mekaniği oyunda yok | Orta-zor (yeni mekanik) | Rakip simülasyonu gerektirir |
| İtibar | Gerçek ama belirsiz; oyunda "itibar" zaten sürekli bir değişken | Kolay ama gizli | Etki görünmez, S2 dersi D3 (Software Inc: ödülün ne yaptığı bilinmedi) [S2-S10] |
| Kapanış zarını artırma | Kanıt yok [BOŞLUK] | | Zar 5 yerde okunuyor; yersiz karmaşa |

**Önerim:** aday akışı çarpanı. Sebepler: ölçüm olan tek şey bu, ekranda "şu tarihe kadar şu modülü isteyen adaylar %X daha sık geliyor" yazılabilir, kısa liste ve kapanış mekaniğine dokunmaz. Süre 12 ay (bir sonraki rapora kadar). Çarpan [WORKING]: ×1,3 (Looker'ın 2×'i ücretli reklam kanalında, ölçüsü başka, o yüzden daha temkinli). Kapsam: yalnız ödül verilen modülü isteyen adaylar; bir şirket bir modülde en çok bir ödül (rozet enflasyonu oyuna girmez). B2C'de modül ödülü yok (Erdem 29).

Ödül koşulu önerisi (tek cümle): o modülün kalitesi segmentinin en iyisi ve modülü kullanan en az N hesap (G2'nin 10 yorumu gibi alçak kapı); N için sim sonrası [WORKING]. Küçük şirket için kapı segment bandıyla (Erdem 6 bantları) açık kalır; Customers' Choice'taki gibi küçük müşteri yorumlarını saymamak küçüğü dışlar, oyun bunu yapmamalı [S22].

**Oyuna ders (C2):** ödülün tek görünür karşılığı olsun ve ekranda süreyle yazılsın; sıklık: yılda bir kez, modül başına en çok bir ödül; kolay.

### C3. Yıllık "en büyük + en hızlı büyüyen" listeleri

| Liste | Eşik | Sıralama | Küçük şirkete etki | Kaynak |
|---|---|---|---|---|
| Inc. 5000 (2026) | 2022'de ≥ 100.000 $, 2025'te ≥ 2 milyon $ gelir; 31 Mart 2022'de kurulmuş ve gelir üretiyor; 31 Ara 2025'te ABD merkezli, özel, kârlı amaçlı, bağımsız; bölgesel liste daha kısa pencere (2022-2024) ve 2024'te ≥ 1 milyon $ | 2022→2025 yüzdesel gelir büyümesi | Büyüme listesi; küçük (2 milyon dolar yıllık gelir) girebilir | [S23] Orta |
| Deloitte Technology Fast 500 (Kuzey Amerika, 2024) | ≥ 4 yıl; FY2020 ≥ 50.000 $, FY2023 ≥ 5 milyon $; büyüme ≥ %75; gelirin >%50'si kendi teknolojisinden; danışmanlık ve bayi dışlanır; başvuru ücretsiz, 2025 için 25 Temmuz son tarih | 3 yıllık gelir büyümesi | Büyüme listesi; küçük girebilir | [S26] Orta, [S29] Orta |
| Forbes Cloud 100 | Bessemer + Salesforce Ventures + Forbes; özel ve bağımsız; jüri çoğunlukla halka açık bulut CEO'ları; 2021'de giriş için tahmini değerleme 1 milyar dolar üstü; 2025 ortalama değerleme 11,2 milyar dolar | Değerleme, işletme metrikleri, pazar liderliği (2017 dönemi ağırlıkları %30/%20/%35 + %15 insan, Düşük) | Büyüklük listesi; küçük girmez | [S27, S28] Orta / Düşük |
| Software 500 | Aranmadı | | [BOŞLUK] |

Başarısız/eleştirilmiş: bu listelere özgü eleştiri bu turda bulunamadı [BOŞLUK]; Gartner "pay to play" tartışması tur 2'de [S1-S16].

**Oyuna ders (C3):** iki liste, iki dil: "en büyük" (mutlak, devler) ve "en hızlı büyüyen" (yüzdesel büyüme, gelir tabanıyla). Küçük şirket "en hızlı büyüyen" listesine girer; eşik bir gelir tabanı (Inc.: 2 milyon dolar/yıl ≈ 167 bin dolar/ay, yalnız referans) ve en az bir yıl varlıktır. Demo 104 hafta; 3 yıllık pencere imkânsız, bu yüzden büyüme penceresi 52 hafta alınır [GÖRÜŞ]. Oyuncunun kararı: büyüme mi büyüklük mü, hangi segmente yüklenmek; yılda bir kez bakılır. Eşik sayıları sim sonrası [WORKING].

### C4. Raporun yıl içinde ne zaman çıkacağı

| Kaynak | Ay | Hangi veriyi okur |
|---|---|---|
| Inc. 5000 | Ağustos (2024 yayını ~14 Ağustos, ikincil [S25]); ilk 500 Eylül sayısında [S24] | Önceki yılın 31 Aralık'ı (2026 listesi için 2025 geliri) [S23] |
| Bilişim 500 (Türkiye) | 5 Ağustos 2026 [S1-S13] | Önceki yılın net satışı |
| Forbes Cloud 100 | Eylül başı (2025: 3 Eylül) [S27] | Temmuz sonu değerleme [S27] |
| Gartner bulut ERP MQ | Kasım (11 Kasım 2024) [S1-S1] | MQ güncellemesi 1-2 yılda bir |
| G2 Grid | Üç ayda bir [S1-S3] | Yorumlar |
| Deloitte Fast 500 | Duyuru ayı bulunamadı [BOŞLUK]; başvuru Temmuz [S26] | FY2023 (2024 için) |

**Oyunda hangi ay:**
- Gerçek listeler ağırlıkla Ağustos-Eylül'de yayımlanır ve önceki yılın verisini okur (7-8 ay gecikme).
- Demo 104 hafta (28 Aralık 2013'te biter [Y_bitis_yili §1.4]). Ağustos'ta çıksa ilk rapor Ağustos 2012 (oyuncunun elinde bir yıl yok), ikinci Ağustos 2013'te olur; veri penceresi önceki takvim yılı ise Ağustos 2012'de veri yok. Ocak'ta çıksa demoda yalnız Ocak 2013 raporu olur (Ocak 2014 demo dışı). Kasım'da çıksa Kasım 2012 (oyunun ~46. haftası) ve Kasım 2013 (~98. hafta, demoden önce) iki rapor verir ve MQ'nun gerçek ayıyla örtüşür (hesap, 1 Oca 2012 Pazar'dan).
- **Önerim:** her yıl Kasım'da, o yılın ilk on ayına (1 Ocak-31 Ekim) dayanan rapor + B2B modül ödülleri aynı anda (Erdem 29). Demoda iki rapor, 2030 sonuna kadar 19 rapor. [GÖRÜŞ]; ay seçimi sim ve dengeye bağlı [WORKING].

**Oyuna ders (C4):** ay seçimi oyuncunun planını belirler (yıl sonu sprint kararları, aday akışı çarpanı 12 ay); Kasım, yılın son çeyreğinde bir büyük an yaratır ve demo bitmeden iki kez yaşanır. Kolay (takvim satırı).

---

## Boşluklar ve açılmayanlar

- Açılan ve okunan sayfalar: Microsoft SCM fiyat sayfası [S6], Constellation Research SapphireNow raporu [S7], CPA Practice Advisor NetSuite haberi [S11], The Register Dynamics 365 AI [S12], Wikipedia Technology tree [S18], Game Dev Tycoon [S19], Capitalism Lab Digital Age [S17], Virtonomica [S16], Inc. 5000 başvuru sayfası [S23], Wikipedia Inc. 5000 [S24], Wikipedia Deloitte Technology Fast 500 [S29], Bessemer Cloud 100 raporu [S27], G2 Looker vakası [S21].
- Açılamayan: McKinsey SaaS indirim sayfası (iki kez zaman aşımı) [S1], Inc.com/inc5000/2025 (403), Deloitte fast-500.html (404), G2 Best Software Awards (403), Gartner Peer Insights ana sayfası (403 ve yönlendirme), Gartner 2019 AI anketi basın bülteni (403), Wikipedia SAP Leonardo / Forbes Cloud 100 / NetSuite (404 ya da içerik yok), eWeek Oracle (403).
- Yalnız arama özetinden alınanlar: McKinsey, Monetizely blogları, Gartner Customers' Choice metodoloji sürümleri, Oracle OpenWorld 2017, Microsoft AI 2018 (TechCrunch, Licensing School), Deloitte eşik PDF'i, Inc. 2024 haberi, Cloud 100 ağırlıkları.
- Aranmadı ya da bulunamadı: RPA ve Odoo ML öncüleri; 2019-2020 ERP YZ olayları; iyi kaynaklı premium/parite/penetrasyon çalışması; premium fiyatın kapanışı düşürmesi için kaynaklı oran; fiyat artışı sonrası kayıp için birincil çalışma; yeni oyun "önerilen fiyat" örneği (Two Point Hospital, Big Ambitions, Capitalism Lab F2'den); Software Inc araştırma ağacı; tavan kilidi şikâyeti; Capterra/PCMag/SAP-Oracle ortak ödülleri; Software 500; Deloitte Fast 500 duyuru ayı; ödül rozetinin kapanışa bağımsız etkisi.
- Simülasyon koşulmadı; formüldeki tüm sayılar ve ×1,3 aday akışı çarpanı [WORKING], kalibrasyon girdisidir.

---

## Kaynak sicili

Erişim: hepsi 2026-10-21. "Özet" = yalnız arama özetinden alındı.

| S# | URL | Yayıncı | Yayın tarihi | Güven | Not |
|---|---|---|---|---|---|
| S1 | https://www.mckinsey.com/capabilities/growth-marketing-and-sales/our-insights/how-much-value-did-you-give-away-to-close-your-last-saas-deal | McKinsey | yok (görülmedi) | Orta-Düşük | Sayfa açılmadı; özet: ağır indirim LTV ve churn'e zarar, veri gösterilmemiş |
| S2 | https://www.getmonetizely.com/articles/churn-rate-analysis-in-saas-how-pricing-decisions-impact-customer-retention | Monetizely (danışmanlık blogu) | yok | Düşük | Price Intelligently, ChartMogul, HubSpot sayıları ikinci el; özet |
| S3 | https://www.getmonetizely.com/articles/price-increases-vs-retention-modeling-the-trade-off-for-saas-success | Monetizely | yok | Düşük | ProfitWell/Paddle atıfları izlenemedi; özet |
| S4 | https://www.getmonetizely.com/articles/premium-saas-pricing-strategy-benefits-and-drawbacks | Monetizely (aynı arama: CleverX, PayPro Global atıfları) | yok | Düşük | McKinsey "%40" atfı doğrulanamadı; özet |
| S5 | https://dodopayments.com/blogs/prestige-pricing-when-charging-more-wins | Dodo Payments (ödeme firması blogu) | yok | Düşük | Prestij fiyatı koşulları; özet |
| S6 | https://www.microsoft.com/en-us/dynamics-365/products/supply-chain-management/pricing | Microsoft (resmî fiyat sayfası) | güncel | Orta | SCM 210 $, Premium 300 $, Intelligent Order Management 315 $/ay; "yalnız bilgi amaçlı" |
| S7 | https://www.constellationr.com/blog-news/event-report-sap-sapphire-2017-all-leonardo-wait-there-more | Constellation Research (Holger Mueller) | 2017-05-19 | Orta | Leonardo duyurusu ve eleştiri; sayfa okundu |
| S8 | https://www.constellationr.com/index%2Ephp/research/blog/sap-machine-learning-plans-deeper-dive-sapphire-now | Constellation Research | 2017-05 (özet) | Orta-Düşük | 18 Mayıs 2017, 5-7 yıl hedefi, TensorFlow; özet |
| S9 | https://www.eweek.com/cloud/oracle-launches-major-ai-initiative-with-intelligent-cloud-apps | eWeek | 2017-10 (özet) | Orta-Düşük | Sayfa 403; ayrı SKU, fiyat açıklanmamış; özet |
| S10 | https://www.constellationr.com/research/blog/oracle-open-world-2017-9-announcements-follow-autonomous-ai | Constellation Research | 2017-10-09 (özet) | Orta-Düşük | 2 Ekim 2017 duyurusu, sonraki 3-6 ay; özet |
| S11 | https://www.cpapracticeadvisor.com/2018/04/25/netsuite-launches-first-intelligent-cloud-suite-with-ai-and-machine-learning/29721/ | CPA Practice Advisor (Oracle NetSuite basın bülteni aktarımı) | 2018-04-25 | Orta | Satıcı beyanı; kullanılabilirlik ve fiyat yok |
| S12 | https://www.theregister.com/2018/09/18/dynamics_365_ai/ | The Register | 2018-09-18 | Orta | Modüller "önümüzdeki aylarda"; şüpheci ton |
| S13 | https://techcrunch.com/2018/09/18/microsoft-launches-new-ai-applications-for-customer-service-and-sales | TechCrunch | 2018-09-18 | Orta-Düşük | Özet; "ilk Dynamics 365 AI çözümleri bir yıl önce" |
| S14 | https://www.licensingschool.co.uk/licensing-blog/2018/11/05/dynamics-365-ai-apps/ | Licensing School | 2018-11-05 | Düşük | Özet; AI for Sales kullanıcı başı 50 $ eklenti |
| S15 | https://voicebot.ai/2017/11/05/gartner-hype-cycle-suggests-another-ai-winter-near | Voicebot.ai | 2017-11-05 | Orta-Düşük | Gartner gelişen teknolojiler döngüsü ikincil aktarım; özet |
| S16 | https://virtonomica.ru/help/index.php/Science/en | Virtonomica (oyunun yardım sayfası) | yok | Orta-Düşük | Teknoloji seviyesi → azami kalite tablosu |
| S17 | https://www.capitalismlab.com/digital-age-dlc/technology-research/ | Capitalism Lab (geliştirici sitesi) | yok | Düşük | Yetişme formülü; kalite tavanı yazılı değil |
| S18 | https://en.wikipedia.org/wiki/Technology_tree | Wikipedia | güncel | Orta | Tech tree tanımı, Civ, oyun sonu boşluğu, kartopu |
| S19 | https://en.wikipedia.org/wiki/Game_Dev_Tycoon | Wikipedia | güncel | Orta | R&D lab "açar"; ilerleme alımı değerlendirilmemiş |
| S20 | https://steamcommunity.com/app/239820/discussions | Steam Topluluğu, Game Dev Tycoon (birkaç başlık) | 2013-2020 (özet) | Düşük | Gizli mekanik, "tahmin oyunu", güncelleme sonrası araştırma kaybı; arama özeti |
| S21 | https://sell.g2.com/case-studies/looker-increases-average-ctr-with-g2 | G2 (satıcının vaka çalışması, yazar Gina Carr) | 2020-06-29 | Düşük | Lead 2×, dönüşüm %3, CTR 6×; baz ve kapanış yok |
| S22 | https://blogs.gartner.com/reviews-pages/?p=4894 (ve ?p=4861, ?p=5159) | Gartner Peer Insights metodoloji sürümleri 1.3, 1.4, 1.4.1 | 2021 civarı (özet) | Orta-Düşük | Sayfa şimdi yönlendiriliyor; eşikler özetten |
| S23 | https://inc5000.secure-platform.com/ | Inc. (resmî başvuru sayfası) | 2026 listesi | Orta | Eşikler okundu; yayın tarihi yok |
| S24 | https://en.wikipedia.org/wiki/Inc._5000 | Wikipedia | güncel | Orta | 5.000 şirket, ilk 500 Eylül sayısı |
| S25 | https://bmf3d.com/news/inc-5000-2024-meet-the-companies-building-the-future/ | bmf3d (iş haberi) | 2024-08-14 civarı (özet) | Düşük | Ağustos yayını kanıtı |
| S26 | https://www2.deloitte.com/content/dam/Deloitte/us/Documents/technology-media-telecommunications/us-technology-fast-500-eligibility-requirements.pdf | Deloitte (resmî eşik belgesi, 2024) | 2024 | Orta | Özet; 2025 için kriterler güncellendi |
| S27 | https://www.bvp.com/atlas/the-cloud-100-benchmarks-report | Bessemer Venture Partners | 2025-09-03 | Orta | Liste ortağı, kendi listesi; Temmuz 2025 değerleme verisi |
| S28 | https://www.insidesales.com/xant-com-returns-forbes-cloud-100-list/ | XANT (liste üyesi satıcı PR'ı) ve diğer arama sonuçları | yok | Düşük | Jüri ve 2017 dönemi ağırlıkları; özet |
| S29 | https://en.wikipedia.org/wiki/Deloitte_Technology_Fast_500 | Wikipedia | güncel | Orta | 3 yıllık büyüme, 500 şirket; eşik yok |
| K2 | docs/tasks/faz_cde/pazar2/out/tur2/K2_kod_fiyat_icerik.md | iç belge | 2026-10-21 | Yüksek (kod) | Bugünkü fiyat zinciri, bant, STANCE_MULT |
| F1, F2, S1-, B_bilinen_yol, Y_bitis_yili, A1 | docs/tasks/faz_cde/pazar2/out/ altında | iç belgeler | 2026-10-20/21 | tur 2'deki güven | `[F1-S8]`, `[F2-S3]`, `[S1-S19]` gibi önekler o belgenin kendi sicilinden |
