# A2 · Gerçek ERP satışı ve hesap yaşam döngüsü, müşteri büyüklüğüne göre

Tarih: 2026-10-20. Arama bütçesi: 22 WebSearch kullanıldı (bütçe bitti), ayrıca WebFetch ile birincil sayfalar okundu. Oyun koduna ve repo dosyalarına dokunulmadı.
Önceki "Pazar merdiveni" araştırması (beklenti/R1-R6, SENTEZ) yalnız oyun mekaniğiydi; bu belge gerçek ERP pazarına bakar ve onu tekrar etmez.

Gösterim: `[S#]` kaynak sicilindeki kaynak. `(varsayım)` kaynağı olmayan, benim kurduğum kabul. Etiketler: `[BOŞLUK]` aradım, bulamadım ya da yalnız zayıf kaynak buldum; `[SIÇRAMA]` kanıttan bir adım öteye geçen sonuç; `[GÖRÜŞ]` benim yargım; `[DEĞERLENDİREMEM]` elimdeki veriyle yargılayamam.

## 0. Özet ve dürüstlük notu

Bu konuda iyi veri azdır ve çoğu satıcı blogunda ya da arama özetinde kalıyor. Aşağıdaki bulgulardan hangisinin sağlam, hangisinin zayıf olduğu her satırda güven etiketiyle görünür. Kısaca:

1. **Sağlam çekirdek (Orta-Yüksek):** Satış döngüsü fırsat yaşıyla ölür: açık kalan fırsat o büyüklüğün ortalama döngüsünün 2 katını aşınca kapanma şansı %3'e iner; "altın dönem" küçük anlaşmada 31-60 gün, orta 61-90 gün, büyükte 150-180 gün [S10]. Satışçıların çoğu kotasını tutturmuyor (2022 son çeyrek %29 tutturdu [S10]; 2024 ikinci çeyrek %75 kaçırdı, %25 aştı, gelirin %83'ünü satışçıların %16'sı getirdi [S11]). Kota, ACV 250 bin dolar üstü satışçıda 25 bin altı satışçıya göre yaklaşık 2,5 kat büyük [S6].
2. **Yenilemede ve kilitlenmede veri zayıf:** Koltuğun yenilemede ne sıklıkla ve ne kadar değiştiğini gösteren birincil bir veri bulamadım `[BOŞLUK]`. Elde medyan net gelir elde tutma %100, brüt %90 (1.400 özel B2B SaaS, 2020 [S12]) ve ERP'nin değişim maliyetini dolaylı gösteren veriler var: sistem yaşı 11 yıl civarı [S30], "memnun olmasa da kalma" nedeninin başı iş kesintisi korkusu (%39,1, satıcı anketi [S25]).
3. **Başarısızlar çok belgeli:** Waste Management / SAP (100 milyon dolar dava, 2008) [S20], Sunshine Mills / Ross (61,4 milyon dolar jüri kararı, "ayarlanmış demo") [S21], ScanSource / Avanade (17 milyon dolar ve 11 ay bütçe, 66 milyon dolara çıkan tahmin) [S22], National Grid / Wipro (75 milyon dolar uzlaşma) [S23]. Ortak desen: satış anında söylenen ile teslimat arasındaki fark.
4. **Satışçı yıldızı için doğrudan ERP verisi yok `[BOŞLUK]`;** genel satış verisi (kıdem, kota, ramp) var. §4'teki yıldız etkileri bu verinin yönünü kullanır, büyüklükleri (varsayım)dır.
5. Koltuk bantları (§1.3): 3-10 / 10-30 / 30-100 / 100-300 / 300-1000, AB KOBİ sınıfı ve ERP kullanıcısının çalışana oranından türetilmiş (varsayım, üç halka da kaynaklı).

Bu araştırmada Steam yorumu aranmadı: konu ERP satışıydı, oyun yorumları başka kollara ait.

---

## 1. Müşteri büyüklüğü ve koltuk sayısı

### 1.1 Büyüklük sınıfları (resmî tanım)
- AB tanımı: mikro <10 çalışan, küçük <50, orta <250 (ciro tavanları 2 / 10 / 50 milyon avro) [S17].
- Eurostat 2023 AB verisi: ERP kullanan işletme oranı küçüklerde (10-49 çalışan) %38, büyüklerde (250+) %86 [S18]. Yani küçük işletmenin yarısından fazlası ERP almıyor; "ERP satmak" büyüdükçe daha olağan.

### 1.2 Kaç koltuk?
- ERP kullanan çalışan oranı ortalama yaklaşık %26: NetSuite'in istatistik sayfasına atfedilen, arama özetinde gördüğüm bir sayı; sayfayı açamadım (403) ve satıcı kaynağıdır. Güven Düşük `[S19]`. Yöntem bilinmiyor `[BOŞLUK]`.
- Başka hiçbir kaynakta "şu büyüklükteki şirket şu kadar ERP koltuğu alır" tablosu bulamadım `[BOŞLUK]`; Gartner/Nucleus tabloları ücretli.
- Koltuk türleri fiyatla ayrışıyor: Dynamics 365 Business Central'ta tam kullanıcı (Essentials) ayda 80 dolar, Premium 110 dolar, Team Member (sınırlı: okuma, onay, seçili kayıt güncelleme) 8 dolar [S15]. Yani gerçek ERP'de koltuk tek tip değil; tam kullanıcıya göre sınırlı kullanıcı yaklaşık onda bir fiyat.
- Gerçek dünyada büyük müşteri bin kullanıcıya varır ama bunu da doğrulayan birincil kaynak bulamadım `[BOŞLUK]`.

### 1.3 Beş basamaklı bant önerisi (varsayım, üç halkalı türetme) [V uyarı: gerçek ERP verisiyle doğrulanamıyor, türetilmiş sabit]
Türetme: AB sınıfı [S17] × ERP kullanan çalışan oranı yaklaşık %26 [S19, Düşük] + Erdem'in kararındaki uç değerler (KOBİ 3-10, dev 100-1000). Sonuç ×3 basamaklı bir merdiven:

| Yıldız | Ad | Koltuk | Çalışan karşılığı (varsayım) | Dayanak |
|---|---|---|---|---|
| 1★ | Mikro | 3-10 | 3-30 | AB mikro/küçük alt yarı [S17]; küçüklerde kullanıcı oranı yüksek olur (varsayım) |
| 2★ | Küçük | 10-30 | 30-100 | AB küçük üst yarı + orta alt [S17], %26 [S19] |
| 3★ | Orta | 30-100 | 100-400 | AB orta üst, büyük alt [S17, S19] |
| 4★ | Büyük | 100-300 | 400-1.200 | %26 [S19] |
| 5★ | Dev / kurumsal | 300-1.000 | 1.200-4.000 | %26 [S19]; Erdem'in "dev 100-1.000" alt ucu 4★ ile örtüşür, 5★'ı 300'den başlatmak öneridir |

`[GÖRÜŞ]` Basamak içi koltuk sayısı sabit değil, aralıkta rastgele ve müşteri büyüdükçe aralığın içinde kayar; aralığı aşınca yıldız yükselir (Erdem kararı 5: yıldız yenilemede değişebilir).

**Oyuna ders (§1):**
- Her satış görüşmesinde oyuncu bir koltuk sayısı duyar. Sıklık: her yeni aday. 1★ hesaba aylık yüzlerce, 5★ hesaba onbinlerce dolar demek; bu aralık oyuncunun "kimin peşine düşeceğim" kararını doğurur.
- Koltuk türü (tam / hafif) gerçek ERP'de fiyatı bölüyor [S15]; oyunda tek tip koltukla başlamak yeterli, sonra "hafif koltuk" ek mekanik olabilir `[GÖRÜŞ]`.

---

## 2. Teklif nasıl kurulur: modül × koltuk, kademe, kurulum bedeli

- Fiyat omurgası: platform tabanı + kullanıcı lisansı + modül. NetSuite için üçüncü taraf planlama tahminleri: taban ayda 999 dolardan, tam kullanıcı ayda 99-199 dolar, modül ayda 199-999+ dolar; 10 kullanıcılı çekirdek ERP yılda yaklaşık 12.000-60.000 dolar; kurulum küçükte 25.000-40.000, ortada 40.000-80.000 dolar, karmaşıkta 100.000+; kurulum çoğu zaman yıllık lisansın 1-2 katı; üç yıllık sözleşmede yıllık bedelde %20-30 indirim; yenilemede kullanıcı ya da modül artmışsa fiyat artabilir [S16]. Hepsi iş ortağı/danışman blogu: Düşük, fiyatlar satıcı listesi değil `[BOŞLUK]`.
- Microsoft'un resmî fiyat sayfası: Essentials 80, Premium 110, Team Member 8 dolar/kullanıcı/ay, yıllık faturalı [S15]. Premium'un farkı hizmet yönetimi ve üretim modülleri [S41]: yani "modül" gerçekte kademeye (sürüme) de gömülü.
- Kurulum işin büyük bölümü: Panorama 2010 çalışmasına göre proje bütçesinin yaklaşık dörtte üçü uygulama, donanım yükseltme, özelleştirme ve diğer ihtiyaçlara gidiyor, lisansa değil [S4, Orta].
- Danışmanların SAP için aktardığı destek ücreti: Enterprise Support lisans bedelinin %22'si, eski Basic Support %17 (2008, SAP yeni müşteriler için Basic'i kaldırdı) [S27]. Forrester'ın 215 kişilik anketi: katılımcıların %57'si adil ücretin %16'nın altı olduğunu söylüyor, ama ortalama yaklaşık %26 ödüyor [S27, Orta; 2008 verisi, bugün için kanıt değil].
- Danışman bloglarına göre kullanılmayan ("shelfware") lisans tipik olarak lisans değerinin %15-35'i [S28, Düşük, satan taraf] ve SAP denetim aralığı için 24 ay talebi vakaların yaklaşık %75'inde kabul edilmiş [S29, Düşük].

### 2.1 Oyuna uyarlanabilir teklif biçimi (varsayım / görüş)
- Teklif = seçilen modüller × koltuk × birim fiyat − indirim + bir defalık kurulum bedeli. Birim fiyat koltuk bandıyla kademeli düşer (hacim indirimi gerçek: çok yıllık sözleşmede %20-30 [S16, Düşük]).
- Yıllık yenileme bedeli lisans değerinin bir oranı olarak okunabilir (SAP'ta %17-22 [S27]); bu, "yenileme = gelir" ve "memnun olmasa da öder" hissini verir.
- Kurulum bedeli ilk yıl gelirinin 1-2 katına kadar (S16, Düşük). Kurulum süresi büyüklükle büyür (§3.3) ve ilk değer görme gecikir; gerçek dünyada bu aralık müşterinin en kırılgan dönemidir (§6).

**Oyuna ders (§2):**
- Oyuncu teklifte üç şeyi oynar: hangi modüller, kaç koltuk, indirim. Sıklık: her anlaşma. İndirim, yıl ortası "kapanış ihtimali" ile "ilk yıl geliri" arasında takas.
- Modül sayısı oyuncuyu ürün kararına bağlar: sattığın modül ürününde zayıfsa (Erdem kararı 1) müşteri itiraz eder; bu, ürün-satış bağıdır.

---

## 3. Satış döngüsü, RFP, demo, kazanma oranı

### 3.1 Satış döngüsü büyüklüğe göre
- **Sağlam (Orta, 3,2 milyon fırsat, 364 şirket, 37 milyar dolar boru hattı, Ebsta/Pavilion 2023):** "Altın dönem" kapanışa en yakın zaman: küçük anlaşma 31-60 gün, orta 61-90 gün, büyük 150-180 gün. Altın dönemde kapananların kazanma oranı %165 daha yüksek. Ortalama döngünün 2 katından uzun açık kalan fırsatın kapanma şansı %3; döngüyü aşan fırsatta bir ay içinde şans %60'a, iki ayda %90'a kadar düşer. Anlaşmaların %37'si kaydı (2022) [S10].
- 2024 ilk yarı güncellemesi: kazanma oranları 2023'e göre %7 düştü, döngüler %20 uzadı, anlaşmadaki paydaş sayısı 5'ten 8'e çıktı, 4,7 milyon fırsat, 566 şirket [S11]. Bir ay üstü kayma kazanma oranını %67 daha düşürüyor [S11].
- Satıcı blogu tablosu (Düşük): ACV 50-100 bin dolar için yaklaşık 120 gün, 100-250 bin için 170, 250-500 bin için 220, 500 bin üstü için 270 gün [S38]. İkincil kaynakta 84 gün "Ebsta/Pavilion"a atfedilen enterprise medyanı da var, birbirleriyle çelişiyor [S38].
- ERP'ye özgü seçim süresi (danışman rehberi, Düşük): orta pazar 3-6 ay, kurumsal 6-12 ay [S36]. ERP'ye özgü satış döngüsü verisi bulunamadı `[BOŞLUK]`; Panorama/Gartner seçim süresi raporları ücretli.
- Kurulum süresi (proje bu ölçekte sözleşmeden sonra): küçük 3-6 ay, orta 6-12 ay, kurumsal 12-24 ay, medyan 9 ay [S3, S37, Düşük]. Panorama'nın 2026 raporuna atıfla medyan 9 ay (170 katılımcı) bir rehberde geçiyor; rapor tam metnini açamadım [S3, Düşük]. [V uyarı: AÇILAMADI; Panorama bülteni 9 ay ve 170 yanıtı içermiyor, gerçeklik dayanağı olarak kullanılmamalı]

### 3.2 RFP ve demo süreci
- Danışman rehberi: 6-10 satıcı uzun liste, 3-5 kısa liste, 2-3 demo finalisti; uzun liste 2-3 hafta, RFP puanlama 3-5 hafta, demo ve referans 4-6 hafta, yani sözleşme öncesi yaklaşık 2-3 ay [S36, Düşük]. Senaryolu demo (müşterinin gerçek iş akışıyla) öneriliyor [S36].
- Alıcı komitesi: Gartner (Mayıs 2025 satış anketi) "beş ila 16 kişi, dört işlev kadar" [S35, ikincil aktarım, Orta-Düşük]; Forrester 2026: 13 iç paydaş + 9 dış etkileyici [S35]; eski Gartner "6-10 karar verici" cümlesi sayfadan 2023 sonunda kaldırılmış [S35]. Orta pazarda kazanılmış fırsatta paydaş 10'a çıkmış (2022) [S10].
- Güvenlik incelemesi gecikme kaynağı: yazılım alıcılarının %39'u, kurumsal alıcıların %50'si (G2, 2026) [S35, ikincil].
- İlişki sayısı ve kazanma (Ebsta 2023): küçük anlaşmada 1-3 ilişki en iyi (kazanma %29); orta anlaşmada 7-9 ilişki %48, 4-6 ilişkiye göre %39 iyi; kurumsalda 10-12 ilişki %42, döngü en kısa 7-9 ilişkide; 16+ ilişkide kazanma oranı %87 düşüyor [S10]. Üst yönetim geç girince kazanma %42 düşüyor, ekonomik alıcı çözüm sunulmadan önce devredeyse top performanslar %241 daha olası [S11].

### 3.3 Kazanma oranı
- Genel B2B SaaS: 2022'de %23, 2024'te %19 (Bridge Group 2024 raporunun podcast özeti, Düşük) [S7]; Gong'dan %21 medyan (Starr Conspiracy üzerinden, Düşük) [S9]. Bunlar farklı şeyleri ölçüyor, karşılaştırılamaz.
- Büyüklüğe göre (Düşük): orta pazar %22-28, kurumsal %15-20 (RepVue/HubSpot toplaması, ikincil); 100 bin dolar üstü %12-18, 500 bin üstü %8-15 [S38]. Bunlar tutarlı yönde: büyüdükçe düşüyor. Doğrulanmadı.
- Hedefe uyum: ICP'ye (ideal müşteri profili) uyan fırsatta kazanma 3,1 kat yüksek; 2024 boru hattının yalnız %18'i ICP'ye uyuyor [S11].

### 3.4 Önerilen oyun döngüsü (varsayım) [V uyarı: yıldız başına kapanış % ve döngü aralıkları doğrulanamadı, yalnız bir hücre Ebsta'dan]

| Yıldız | Satış döngüsü (hafta=tik) | Temel kapanış ihtimali | Dayanak |
|---|---|---|---|
| 1★ | 3-6 | %30 | küçük en iyi %29 [S10]; altın dönem 31-60 gün [S10] |
| 2★ | 6-10 | %27 | orta pazar üst aralığı [S38] |
| 3★ | 8-14 | %24 | orta anlaşma altın dönem 61-90 gün [S10]; orta pazar %22-28 [S38] |
| 4★ | 16-26 | %20 | büyük altın dönem 150-180 gün [S10]; 100K+ %12-18 [S38] |
| 5★ | 26-52 | %16 | ERP kurumsal seçim 6-12 ay [S36]; %8-15 [S38] |

Zaman cezası (kaynaklı): döngünün 2 katı geçince ihtimal %3'e iner [S10]; oyunda açık bekleyen fırsat her hafta çürür. Tavan-taban: %60 tabanı kalkıyor (Erdem kararı 9); önerim ihtimal [%3, %90] aralığında kalır `[GÖRÜŞ]`.

**Oyuna ders (§3):**
- Satış döngüsü uzadıkça oyuncuya "bu aday için bir kaynak tahsis et mi" kararı doğar: 5★ aday 26-52 hafta boyunca satışçıyı bağlar. Sıklık: her aday açıldığında.
- Zaman kendi başına ceza olduğundan "geciktirme" ödülsüz: 2 kat süreyi aşan fırsat fiilen ölür [S10]. Oyuncu hangi adayı bırakacağına karar verir.
- Alıcı komitesi büyüdükçe "kaç kişiyle görüş" kararı kurulabilir: 5★ komitede 10-12 ilişki en iyi, 16+ kötü [S10]. Bu, tek toplantı yerine birkaç temas gerektirir; hafif tutmak için tek "temas sayısı" göstergesi yeter `[GÖRÜŞ]`.

---

## 4. Satışçı: kıdem, kota, ramp ve yıldız etkileri

### 4.1 Bulgular
- Bridge Group 2017 (384 yönetici, medyan ACV 25 bin dolar, medyan döngü 60 gün): ortalama satışçı kıdemi 2,4 yıl ve 2010'dan beri değişmemiş, toplam devir yaklaşık %30; ortalama yıllık kota 770 bin dolar; kota/OTE oranı 5,3 [S5].
- Bridge Group 2024 (170+ şirket): medyan yıllık ACV kotası 800 bin dolar (2022: 740 bin); ACV 25 bin altı satışçının kotası 250 bin üstü satışçıdan yaklaşık 2,5 kat küçük; OTE medyanı 190 bin dolar (2022: 167 bin); taban:değişken 53:47 [S6]. Tutturma ve ramp oranları sayfada yok `[BOŞLUK]`.
- Kota tutturma (ikincil): Bridge Group verisi olduğu söylenen 2022 %66 → 2024 %51 [S45, Düşük], başka kaynaklar %45-48 diyor [S45]; Ebsta: 2022 son çeyrek %29 [S10], 2024 ikinci çeyrek %75 kaçırdı, %25 aştı, satışçıların %16'sı gelirin %83'ünü getirdi, "hız farkı" 10,2 kat [S11]. Doğrusu: ölçüt şirketten şirkete değişiyor, sayılar tutarsız; yön tutarlı (az sayıda satışçı çoğu geliri getiriyor).
- Ramp (ikincil, Düşük): SMB/inside yaklaşık 1-3 ay, orta pazar 3-6, kurumsal 6-12 ay [S8]; B2B SaaS ortalama ramp 2024'te 7,2 ay (2020: 5,3) [S9]; bir başka sayfa 4,7 ay [S45]. Çelişkili, tanım farkı var `[BOŞLUK]`.
- Tutturma segmentte (Düşük): SMB %50-65, orta %40-55, kurumsal %35-50 [S8].
- Hakemli: satışçı performansının belirleyicileri üzerine meta-analiz (Verbeke ve ark. 2011, aktaran arama özeti): satışla ilgili bilgi β=0,28, uyum yeteneği 0,27, rol belirsizliği -0,25, bilişsel yetenek 0,23, işe bağlılık 0,23; "deneyim" bu beş arasında değil `[S33]`. Yani kıdem tek başına güçlü kanıtlanmış bir belirleyici değil; bilgi ve uyum daha güçlü. Orta-Düşük: sayfa içi doğrulamadım.

### 4.2 Oyuna uyarlanabilir yıldız etkileri (1-5★) (hepsi varsayım; yön kaynaklı) [V uyarı: AÇILAMADI, satışçı yıldızı etkisini ölçen çalışma yok]
Kural: satışçı yıldızı s_r, aday/hesap yıldızı s_a. Fark d = s_r − s_a.

| Etki | d = 0 | d > 0 (satışçı üstte) | d < 0 (satışçı altta) | Kaynak yönü |
|---|---|---|---|---|
| Kapanış ihtimali | temel (§3.4) | her yıldızda ×1,10, en çok ×1,25 | her yıldızda ×0,60 (2 yıldız altı ×0,35) | büyük hesabı sıradan satışçı kapatamaz: kota 2,5× [S6]; hız farkı 10× [S11] |
| Kapanış süresi | temel | her yıldızda −%5 | her yıldızda +%20 | döngü altın dönemi aşınca ölür [S10] |
| İndirim ihtiyacı | temel | küçülür (varsayım) | büyür (varsayım) | `[BOŞLUK]` kanıt yok; `[GÖRÜŞ]` |
| Ramp (yeni işe giriş) | tam verim ramp(s_a) hafta sonra | ramp aynı | ramp aynı ama başta ×0,5 | ramp 1-3 / 3-6 / 6-12 ay [S8, Düşük] |
| Aynı anda yürütebileceği aday sayısı | ~ | + | − | Ebsta: satışçı başına 49 fırsat [S10] |
| Söz verme riski (abartı) | düşük | düşük | yüksek: yetersiz satışçı abartı ile kapatır | Sunshine Mills / Avanade vakaları [S21, S22] |

ramp(s_a) önerisi (varsayım, haftaya çevrilmiş): 1★ 4-13, 2★ 8-18, 3★ 13-26, 4★ 26-39, 5★ 39-52 hafta.

**Yıldız yükselmesi (varsayım):** yıldız kıdemle değil, "o büyüklükte kapatılan anlaşmalarla" yükselir; kanıt kıdemin tek başına zayıf belirleyici olması [S33] ve kıdem ortalamasının 2,4 yıl, devrin %30 olması [S5]. Oyunda bu "satışçı kaybetme" (rakip işe alma) olayını da doğurur ve oyuncuyu elde tutma kararına götürür.

**Hangi büyüklükte işe yarar:** 1-2★ hesapta yıldız farkı küçük etki (kanıt: küçük anlaşmalar 1-3 ilişki ve kısa dönemle kapanıyor [S10]); 4-5★ hesapta belirleyici (çok paydaş, uzun süre [S10, S35]). Bu, "yıldızlı satışçıyı küçük hesaba harcama" kararını doğurur `[GÖRÜŞ]`.

**Oyuna ders (§4):**
- Oyuncu satışçıyı hangi hesaba atayacağını seçer (sıklık: her yeni aday). Yıldız uyumsuzluğu cezalı ama görünür: "bu hesabın yıldızı 4, satışçın 2, kapanış ihtimali %X'ten %Y'ye".
- İşe alma: yıldızı yüksek satışçı pahalı (OTE 105 bin dolar SMB ile 247 bin kurumsal arasında, [S45, Düşük]) ve ramp süresi uzun (6-12 ay) olduğundan, "şimdi işe al, yıl sonu fayda" kararı kurulur.

---

## 5. Yenileme, koltuk değişimi, genişleme, ayrılma, kilitlenme

### 5.1 Elde tutma verisi
- 1.400 özel B2B SaaS (SaaS Capital, 2020): medyan net gelir elde tutma %100, brüt %90; ACV yükseldikçe net elde tutma artıyor, brüt tutma en yüksek ACV'liler dışında yatay [S12, Orta]. ACV bandı değerleri grafik içinde, sayfadan okunamadı `[BOŞLUK]`.
- KeyBanc/Sapphire özel SaaS anketi (2024 özeti): brüt yaklaşık %90, net yaklaşık %101; başka özet 2023'te brüt %86 [S13, Orta].
- Büyüklüğe göre brüt elde tutma: kurumsal odaklı SaaS (ACV >50 bin dolar) %92-96, SMB odaklı (ACV <5 bin dolar) %80-88 [S14, Düşük, yöntem belirsiz]. Yön SaaS Capital ile uyumlu, sayılar doğrulanmadı.
- Yıllık küçülme (contraction) "sağlıklı" %5-8, %12 üstü ciddi sorun (SaaS Capital'e atfedilen, ikincil) [S43, Düşük]. "Takım ürünlerinde hesapların %25-40'ı iptalden önce koltuk küçültür" iddiası birincil kaynaktan doğrulanamadı; kullanılmıyor `[BOŞLUK]`.

### 5.2 Yenilemede koltuk ve genişleme
- **Koltuğun yenilemede ne sıklıkla, ne kadar değiştiği:** ERP'ye özgü birincil veri yok `[BOŞLUK]`. Dolaylı: net tutma %100 ve brüt %90 [S12] birlikte, ortalama hesapta tutma kayıplarının genişlemeyle dengelendiğini söylüyor (yaklaşık %10 kayıp, yaklaşık %10 genişleme, dağılımı bilinmiyor).
- **Yeni modül alma (genişleme):** sıklığına dair ERP'ye özgü bir veri bulamadım `[BOŞLUK]`. Panorama 2012 raporunda ilk uygulanan modüller muhasebe/finans, satış-sipariş-stok ve bordro/İK; CRM, depo, üretim, ileri planlama sonra geliyor, yüzdeler yok [S40, Orta-Düşük]. Aynı rapor: "büyük patlama" geçişi %34, modül modül %24 [S40]. Bu "ilk modülle gir, sonra genişle" sırasını destekler ama sıklığı vermez.
- Kullanıcı artınca fiyat artar; yenilemede yeni kullanıcı ve modül fiyatı artırabilir [S16, Düşük].
- Küçülme çoğu zaman iptalden 1-2 yenileme önce görülür; yenilemeden 60-90 gün önce kullanım düşüşü işaret [S43, Düşük, ikincil].

### 5.3 Ayrılma nedenleri
- Satıcı anketleri (Düşük): 2016 SYSPRO anketi (ABD üretim/dağıtım): ankete katılanların %50,7'si büyüme ya da değişimin mevcut sistemin eksiklerini açığa çıkarmasını, yaklaşık dörtte biri düşük performans ya da zayıf desteği neden gösteriyor; memnun olmasa da kalanlar için iki nedenin toplamı %74, başta iş kesintisi korkusu %39,1 [S25]. 2013 NetSuite/YouGov (531 İngiliz karar verici): %36 BT maliyeti ve bakım azaltma, %28 daha iyi ya da ucuz alternatif, %24 elle işi otomatikleştirme, %19 sistemin büyümeyi kaldırmaması [S26]. İkisi de satıcı sponsorlu, algı anketi, gerçek geçiş kaydı değil.
- Büyüklüğe göre ayrılma nedeni dağılımı: bulunamadı `[BOŞLUK]`.
- İlk dönem kaybı (onboarding): 74.871 B2B abonelik sözleşmesi, küresel bir SaaS sağlayıcı (Steinhoff, Kim, Kanuri, Palmatier, JAMS 2025): yalnız %82'si onboarding sonuna kadar elde kalmış, yani yaklaşık 13.500 sözleşme müşteri verimli olmadan kaybolmuş [S32, ikincil aktarım, Orta-Düşük; makalenin kendisi erişim dışı kaldı].

### 5.4 Değişim maliyeti ve kilitlenme
- Sistem yaşı: Avrupa Trovarit çalışması, kullanımdaki sistemin ortalama yaşı 2018'de 11,7 yıl, 2020'de 11,3 yıl [S30, Orta]. Aberdeen (Jutras): 50 milyon dolar altı şirketlerde ortalama yaş sekize yakın, 100 milyon dolara gelince 10 yılda duruyor; 313 orta ölçekli şirketlik 2009 örneğinde yaklaşık yedi yıl [S31, arama özeti, Orta-Düşük]. Bir ERP danışmanlığı blogu (anekdot, Düşük): çoğu üretici en az 10 yıl, geçiş yapanlar çoğu 15. yıl civarı [S45b].
- Memnuniyetsizliğe rağmen kalma: Panorama 2010'da 1.600 kurumun yarıdan fazlası beklenen faydanın en çok %30'unu almış, ama %72 "oldukça memnun" demiş [S4, Orta]. `[SIÇRAMA]` Bunu "faydayı alamasa da kalıyor" diye okuyorum; çalışma kilitlenmeyi doğrudan ölçmüyor.
- Gerekçe: iş kesintisi korkusu (%39,1) [S25], projelerin yüzde 51,4'ü bütçeyi aşmış [S4]; yani geçiş pahalı ve riskli.
- Yenileme pazarlığı: müşteri fiyat artışına karşı sınır (0-2% gibi) ister, denetim aralığı ister, kullanılmayan lisans için indirim ister [S28, S29, Düşük, satan taraf]. Güvenilir alternatif varsa (üçüncü taraf bakım) SAP'ın %22'nin altına indiği iddiası [S29, Düşük].
- Hangi şartı koşar: "özellik şartı" konusunda ERP'ye özgü kanıt bulamadım `[BOŞLUK]`; yukarıdaki pazarlık maddeleri fiyat ve sözleşme şartları, özellik değil.

### 5.5 Oyuna uyarlama (varsayım / görüş)
- Yenilemede koltuk: memnun ve büyüyen hesap + (kademeli), kararsız 0, memnun olmayan − ya da ayrılır (Erdem kararı 5: her müşteri büyümez, 1★ sürekli koltuk almaz). Büyüklükle brüt tutma farkı gerçek [S12, S14]: küçük hesabın yenilemede kaybı büyük hesaptan çok olur (yaklaşık %12-20 vs %4-8, S14'ten türetilmiş, Düşük).
- Kilitlenme: ayrılma olasılığı büyük hesapta düşük, ama ayrıldığında MRR kaybı büyük. Memnuniyetsiz büyük hesap kalır ve baskı yapar (şart koşar) ayrılmadan önce; küçük hesap sessizce gider. `[GÖRÜŞ]`

**Oyuna ders (§5):**
- Yenileme anında oyuncuya kararlar: indirim ver mi, istenen modülü ver mi, fiyat artışı yap mı. Sıklık: hesap başına yılda bir (büyük hesap yıl ortası da "şuna ihtiyacımız var" der, Erdem kararı 1).
- İlk dönem (kurulum + 6-12 ay) en kırılgan: %18 kayıp onboarding'de [S32]. Oyuncunun "yeni müşterinin ilk haftalarına destek ayır" kararı buradan doğar.
- Küçük hesapla büyük hesabın farkı: küçük hesap çok, hızlı, ucuz; büyük hesap az, yavaş, kalıcı. Bu iki oyun biçimi doğurur.

---

## 6. Başarısızlar: batan ERP projeleri ve abartılı satış

### 6.1 Genel oranlar
- Panorama 2010 (1.600 kurum): %51,4 bütçeyi aştı, %35'ten fazlası takvimi aştı, yarıdan fazlası beklenen faydanın en çok %30'unu aldı, %72 yine de "oldukça memnun" [S4, Orta]. Bütçe aşımı katmana göre: Tier I %53, Tier II %33, Tier III %59 [S4].
- Panorama 2026 raporu (yayın 4 Mart 2026): "dörtte birden fazlası" bütçeyi aştı, neden olarak ek teknoloji ihtiyacı birinci [S1, Orta]; TechTarget'ın aktarımıyla %30 [S2, Orta]. 2026 raporundan başka sayı çıkaramadım `[BOŞLUK]`.
- ECSS (ABD Hava Kuvvetleri ERP): 2005-2012, beklenen maliyet 1,1 milyar dolar, iptal [S24, Düşük-Orta]. İsveç Försäkringskassan SAP: 2008-2013, yaklaşık 10 milyar SEK, iptal [S24].

### 6.2 Dava ve vakalar (satıştaki söz ile teslimat arasındaki fark)
| Vaka | Yıl | Tutar | İddia | Sonuç |
|---|---|---|---|---|
| Waste Management / SAP | 2008 | 100 milyon dolar dava | Satıcı yazılımın hazırlığını ve yeteneğini yanlış anlattı; satış iddiaları yanıltıcı | Yıllarca süren davadan sonra mahkeme dışı uzlaşma; SAP, müşterinin süreç uyumsuzluğu ve kötü proje yönetimini savundu [S20] |
| Sunshine Mills / Ross Systems | 2005 başlangıç; karar Aralık 2010 | 61,4 milyon dolar jüri kararı (16,4 tazminat + 45 cezai) | Depo ve dağıtım maliyetini %50'ye kadar düşüreceği söylendi; demolar her adaya uyacak biçimde ayarlandı (iç şaka adı "Murrayware"); sistem yanlış müşteriye sevk etti, fatura çıkaramadı | Ross dolandırıcılığı reddediyor, temyiz edecek [S21] |
| ScanSource / Avanade (Dynamics AX) | 2009 sözleşme; dava Ocak 2013 | Bütçe 17 milyon dolar ve 11 ay; tahmin yaklaşık 66 milyon dolar, 3 yıl sonra canlı değil | Tecrübeli kadro vaadi tutulmadı; demolar gerçeği yansıtmayan simülasyondu; maliyet birkaç ay içinde sert artırıldı ("bait and switch") | Avanade reddediyor; 500 bin satırdan fazla özel kod [S22] |
| National Grid / Wipro (SAP) | 2012 canlı; dava 2017 | Yaklaşık 140 milyon dolar ücret + yüz milyonlarca dolar onarım | Wipro SAP yetkinliğini yanlış anlattı; hatalı tasarım, yetersiz test | Wipro 75 milyon dolar ödeyerek uzlaştı (Ağustos 2018); devlet denetimi National Grid'in yönetimini de eleştirdi [S23] |
| Bridgestone / IBM (SAP tabanlı) | 2012 canlı; dava 2013 | 600 milyon dolar talep; 78 milyon dolarlık sistem | Hatalı sistem | İki taraf davadan çekildi, IBM'in bir şey ödemediği bildirildi; IBM erken yayına geçişi suçluyor [S23] |

Not: Davalar iddia üzerine; mahkeme hükmü yalnız Sunshine Mills'te. Bazı vakalarda hata satıcıdan çok sistem entegratörüne (Deloitte, Avanade, Wipro, IBM) atfediliyor `[SIÇRAMA]` "ERP satıcısı abarttı" diye genellemek doğru olmaz.

### 6.3 Ortak desen (desenler kaynaklı, sonuç benim)
- Satış anında "hazırlık/uyum" abartısı (Waste Management, Sunshine Mills), demo ayarı (Sunshine Mills, ScanSource) ve bütçe sapması (ScanSource: 17 → 66 milyon) [S20, S21, S22].
- Müşteri tarafı da suçlanıyor: erken yayına geçiş (IBM [S23]), süreç uyumsuzluğu (SAP [S20]), kötü proje yönetimi.
- Sorumluluk dağılımı çoğunlukla bulanık: mahkemeler bunu kolay çözmüyor; kasıt kanıtı büyük engel (Panorama'nın tavsiyesi olarak arama özetinde geçti; sayfa içi doğrulanmadı).

**Oyuna ders (§6):**
- "Abartı" satıcının elindeki bir kaldıraç: oyuncu satış toplantısında kapanış ihtimalini artırmak için sözü şişirebilir; bedel, onboarding'de ve ilk yıl içinde müşterinin memnuniyetinin daha çabuk düşmesi, hatta davası/sözleşme feshi. Gizli ceza değil: oyuncu söz anında seçimi görür, sonucu "söz defteri"nde izler (mevcut PromiseRegistry fikriyle uyumlu `[GÖRÜŞ]`).
- Sık değil, ender: büyük (4-5★) hesapta yılda bir-iki karar; bu sistemin ağırlık merkezi büyük hesap.
- Proje yürürken maliyet artışı (17 → 66 milyon) oyuncuya "ek kurulum bedeli iste / yut" kararı doğurabilir `[GÖRÜŞ]`, ama bu kapsamı büyütür; ancak basit tutulursa sevimli.

---

## 7. Erdem'in kararlarına karşı bulguların haritası

| Karar | Bu araştırmanın bulgusu |
|---|---|
| 1 İstek olarak beklenti, yenilemede şart | Gerçek dünyada yenilemede şart fiyat/sözleşme şartları (artış sınırı, denetim, kullanılmayan lisans) [S28, S29]; özellik şartı için kanıt yok `[BOŞLUK]`. Büyük hesabın yıl ortası istek göndermesi için birincil kanıt yok, ama alıcı komitesi (5-16 kişi) ve uzun döngü bunu makul kılıyor `[GÖRÜŞ]`. |
| 4 Modül × koltuk, görüşmede teklif | Gerçek teklif modül × koltuk × kademe + kurulum [S15, S16]; ilk modüller finans, satış/stok, bordro/İK [S40]. |
| 5 Koltuk büyüklük ve memnuniyetle değişir; 5 basamak | Bant önerisi §1.3; brüt tutma büyüklükle değişir [S12, S14]; küçülme iptalden önce gelir [S43]. |
| 8 Geliştirilmeyen ürünün cezası | Gerçek karşılığı: büyüme "mevcut sistemin eksiklerini açığa çıkarıyor" (%50,7) [S25]. Ürün yerinde sayarken müşteri büyür ve sistem yetmez olur; ceza bu yolla oyuncuya gösterilebilir. `[GÖRÜŞ]` |
| 9 Satışçı yıldızı | §4.2 tablosu. |

---

## 8. Boşluklar (aradım, bulamadım)
1. ERP'ye özgü satış döngüsü ve kazanma oranı büyüklüğe göre: genel B2B SaaS verisi var, ERP'ye özgü yok. Panorama/Gartner/Nucleus raporları ücretli.
2. Koltuk sayısı tablosu (büyüklük → kaç koltuk): hiçbir kaynakta yok; §1.3 türetmedir.
3. Yenilemede koltuk değişim sıklığı ve büyüklüğü: yok. "Genişleme sıklığı" yok.
4. Büyüklüğe göre ayrılma nedeni dağılımı: yok.
5. Satışçı kıdeminin büyük hesap kapanışına ERP düzeyinde etkisi: yok; Bridge Group 2024'ün tutturma/ramp bölümü sayfada yok, yalnız ikincil aktarım var.
6. Müşterinin yenilemede özellik şartı koşması: ERP'ye özgü kanıt yok.
7. Birincil kaynağı açılamayanlar: Gartner (403), BusinessWire SYSPRO (403), NetSuite ERP statistics (403), Springer JAMS (kimlik doğrulama), Controleng Jutras (403). Bu kaynaklardan gelen sayılar arama özetinden alındı ve öyle etiketlendi.
8. 2026 Panorama ERP raporu tam metni: erişilemedi.

---

## 9. Kaynak sicili
Erişim tarihi hepsi için 2026-10-20 (arama veya WebFetch). "Güven" kuralı: satıcının kendi sayfası Düşük; satıcı sponsorlu anket Düşük; resmî kurum Yüksek; bağımsız analiz Orta-Yüksek.

| # | URL | Yayıncı | Yayın | Güven |
|---|---|---|---|---|
| S1 | https://panorama-consulting.com/panorama-consulting-group-releases-latest-study-of-erp-implementation-outcomes-across-the-globe | Panorama Consulting Group (basın bülteni, 2026 ERP Report) | 2026-03-04 | Orta |
| S2 | https://www.techtarget.com/enterprise-software/feature/Explaining-the-hidden-costs-of-ERP-implementations | TechTarget (Panorama raporundan aktarma) | 2026-09-10 (sayfa tarihi) | Orta |
| S3 | https://resources.rework.com/guides/choosing-software/erp-implementation-guide | Rework (rehber; Panorama 2026'ya atıf) | belirsiz | Düşük |
| S4 | https://www.computerworld.com/article/1516480/widespread-discontent-persists-with-erp-projects.html | Computerworld (Panorama 2010 çalışması, 1.600 kurum) | 2010-03-17 | Orta |
| S5 | https://forentrepreneurs.com/2017-saas-ae-metrics-report | The Bridge Group / For Entrepreneurs (384 yönetici) | 2017 (sayfa tarihsiz) | Orta-Yüksek |
| S6 | https://blog.bridgegroupinc.com/2024-ae-metrics-compensation-benchmark | The Bridge Group (170+ şirket) | 2024 | Orta |
| S7 | https://vi.player.fm/1BgNWMC | Podcast özeti, Bridge Group 2024 raporu | 2024 | Düşük |
| S8 | https://getboomerang.ai/glossaries/quota-attainment-benchmarks-2026 | Boomerang (sözlük; ramp ve tutturma aralıkları; arama özetinde birkaç kaynak karışık, sayfa içi doğrulanmadı) | 2026 | Düşük |
| S9 | https://www.thestarrconspiracy.com/insights/benchmarks/b2b-go-to-market-strategy-benchmarks-2024 | The Starr Conspiracy (ramp 7,2 ay; Gong %21 medyan) | 2024 | Düşük |
| S10 | https://www.ebsta.com/wp-content/uploads/2023/02/2023-B2B-Sales-Benchmark-Report.pdf | Ebsta ve Pavilion (3,2 milyon fırsat, 364 şirket) | 2023 | Orta |
| S11 | https://ebsta.com/wp-content/uploads/2024/07/H1-Update-2024-B2B-Sales-Benchmarks.pdf | Ebsta (4,7 milyon fırsat, 566 şirket) | 2024-07 | Orta |
| S12 | https://www.saas-capital.com/blog-posts/new-retention-data-and-the-impact-on-valuation/ | SaaS Capital (1.400 özel B2B SaaS) | 2020-06-26 | Orta |
| S13 | https://www.barchart.com/story/news/36109511/private-saas-company-survey-reveals-ai-driven-transformation-and-sustained-operational-excellence | KeyBanc Capital Markets ve Sapphire Ventures anketi (basın bülteni) | 2024 | Orta |
| S14 | https://stealthagents.com/research/startup-gross-retention-benchmarks | Stealth Agents (ikincil blog, yöntem belirsiz) | 2026 | Düşük |
| S15 | https://www.microsoft.com/en-us/dynamics-365/products/business-central/pricing | Microsoft (resmî fiyat sayfası; ürünü anlatan kısım Düşük, fiyat listesi olgu olarak alındı) | güncel | Orta |
| S16 | https://redresscompliance.com/oracle-netsuite-pricing-guide.html ve https://closeloop.com/blog/netsuite-pricing-and-implementation-costs/ ve https://epiqinfo.com/netsuite-pricing/ | İş ortağı/danışman blogları | 2025-2026 | Düşük |
| S17 | https://single-market-economy.ec.europa.eu/smes/sme-definition_en | Avrupa Komisyonu | güncel | Yüksek |
| S18 | https://ec.europa.eu/eurostat/web/products-eurostat-news/w/ddn-20240516-2 | Eurostat | 2024-05-16 (veri 2023) | Yüksek |
| S19 | https://netsuite.com/portal/resource/articles/erp/erp-statistics.shtml | NetSuite (satıcı; yalnız arama özeti, sayfa 403) | belirsiz | Düşük |
| S20 | https://www.panorama-consulting.com/the-hidden-costs-of-erp-failure/ | Panorama Consulting (Bill Baumann) | 2025-07-02 | Orta |
| S21 | https://www.computerworld.com/article/1547747/jury-awards-61m-to-sunshine-mills-over-botched-erp-project.html | Computerworld | 2010-12-06 | Orta-Yüksek |
| S22 | https://www.networkworld.com/article/667719/erp-microsoft-accenture-joint-venture-avanade-sued-over-alleged-erp-project-failure.html | Network World (dava dilekçesi iddiaları) | 2013-01-03 | Orta |
| S23 | https://spectrum.ieee.org/these-lawsuits-expose-it-failures-many-fathers | IEEE Spectrum | 2018-08-17 | Orta-Yüksek |
| S24 | https://en.wikipedia.org/wiki/List_of_failed_and_overbudget_custom_software_projects | Wikipedia | güncel | Düşük-Orta |
| S25 | https://www.businesswire.com/news/home/20160225005106/en/3718917/New-Study-Companies-Replace-ERP-Vendor-Software | SYSPRO SNAP anketi (satıcı; yalnız arama özeti, sayfa 403) | 2016-02-25 | Düşük |
| S26 | https://techmonitor.ai/?p=120491 | Tech Monitor (NetSuite/YouGov 2013 anketi; arama özeti) | 2013 | Düşük |
| S27 | https://www.cio.com/article/276860/enterprise-resource-planning-sap-raises-software-maintenance-fees-for-new-customers.html | CIO.com (Forrester anketi, 215 kişi) | 2008-04-10 | Orta |
| S28 | https://redresscompliance.com/sap-license-renewal-the-complete-guide.html | Redress Compliance (SAP danışmanlığı satar) | 2026 | Düşük |
| S29 | https://saplicensingexperts.com/blog/sap-price-increase-negotiation-guide | SAP Licensing Experts (danışmanlık satar) | 2026 | Düşük |
| S30 | https://www.organisator.ch/en/?p=7297 | organisator.ch (Trovarit çalışması) | 2020 verisi | Orta |
| S31 | https://www.controleng.com/cindy-jutras-have-we-entered-the-era-of-disposable-erp/ | Control Engineering (Cindy Jutras, Aberdeen; yalnız arama özeti, sayfa 403) | belirsiz | Orta-Düşük |
| S32 | https://www.valuecase.com/articles/impact-of-bad-customer-onboarding | Valuecase (JAMS 2025 çalışmasını aktarıyor; çalışma: https://link.springer.com/article/10.1007/s11747-025-01088-3, erişilemedi) | 2025 | Orta-Düşük |
| S33 | https://pure.eur.nl/en/publications/drivers-of-sales-performance-a-contemporary-meta-analysis-have-sa/ ve https://core.ac.uk/works/8229186 | Verbeke, Dietz, Verwaal (JAMS 2011) sonuçları arama özetinden; sayfa içi doğrulanmadı | 2011 / 2022 | Orta-Düşük |
| S35 | https://www.thestarrconspiracy.com/insights/benchmarks/b2b-buying-committee-benchmarks-2025 | The Starr Conspiracy (Gartner, Forrester, G2 aktarımı) | 2025 | Orta-Düşük |
| S36 | https://www.erpresearch.com/en-us/erp-evaluation-selection | ERP Research (danışman rehberi) | 2026-07 güncel | Düşük |
| S37 | https://erpresearch.com/en-us/blog/erp-implementation-time | ERP Research | belirsiz | Düşük |
| S38 | https://prospeo.io/s/sales-cycle | Prospeo (satıcı blogu; Focus Digital ve Ebsta/Pavilion aktarımı; ayrıca win rate aralıkları) | 2026 | Düşük |
| S40 | https://www.lemondeinformatique.fr/actualites/lireamp-les-entreprises-plutot-satisfaites-de-leur-erp-selon-un-rapport-de-panorama-48115.html | Le Monde Informatique (Panorama 2012 raporu) | 2012 | Orta-Düşük |
| S41 | https://en.wikipedia.org/wiki/Microsoft_Dynamics_365 | Wikipedia (Business Central / F&O segmentleri) | güncel | Düşük |
| S43 | https://www.getmonetizely.com/articles/understanding-contraction-revenue-a-critical-metric-for-saas-growth-and-retention | Monetizely (satıcı blogu; SaaS Capital atfı doğrulanmadı) | belirsiz | Düşük |
| S45 | https://stealthagents.com/research/cost-of-hiring-an-account-executive-2026 | Stealth Agents (Bridge Group/RepVue atfı ikincil; OTE ve tutturma aralıkları) | 2026 | Düşük |
| S45b | https://e2btek.com/?p=2215 | e2btek (ERP danışmanı/satıcı blogu, anekdot) | belirsiz | Düşük |

Not: S34 ve S39, S42, S44 numaraları kullanılmadı (ön listeden çıkarıldı).
