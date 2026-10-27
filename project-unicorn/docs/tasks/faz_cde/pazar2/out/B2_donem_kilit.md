# B2 · Yıla bağlı kilitler, uzun ilerleme, bitiş yılı, geç oyun ve geliştirmemenin cezası

Tarih: 2026-10-20. Erişim tarihi tüm kaynaklarda 2026-10-20. Oyun koduna ve repo dosyalarına dokunulmadı.
Arama: 18 WebSearch çağrısı (biri alan filtresi hatasıyla düştü, kalan 17 sonuç verdi); ek olarak serbest WebFetch.
Etiketler: [BOŞLUK] kaynak bulunamadı, [SIÇRAMA] kanıttan çıkmayan sonuç, [GÖRÜŞ] benim yargım, [DEĞERLENDİREMEM] bilmediğim yer,
(varsayım) kaynaksız kabul. `[S#]` kaynak sicilinin (en sonda) numarasıdır.

Bu araştırmanın sınırı baştan: oyunların çoğunun kuralları resmî belgede yok; kuralı bilen yerler oyuncu forumları ve
topluluk wiki'leri. Bu yüzden bir kuralı "oyuncular böyle anlıyor" diye yazdığımda öyle yazıyorum. Fandom wiki'lerine
(Game Dev Tycoon, Software Inc.) erişilemedi (HTTP 402), bu yüzden o iki oyunun iç sayıları (hangi yıl hangi özellik)
bu belgede YOK.

---

## 0. Özet (14 satır)

1. Sekiz oyunun beşinde "bitiş yılı" ya sabit ve duyurulu (Game Dev Tycoon 35 yıl, OpenTTD 2050) ya da yok (Mad Games Tycoon 2, Anno 1800, Football Manager); Software Inc. ve Capitalism Lab için bitiş yılı bulunamadı [BOŞLUK].
2. Bitiş yılı "oyun orada biter" demek değil: Game Dev Tycoon'da süre dolunca puan hesaplanır, platform çıkışı durur, ama oynamaya devam edilir [S1]; 301. yılda platformların kaybolabileceğini yapımcı kendisi yazdı [S5]. Bitiş yılı, içerik verisinin bittiği yerdir.
3. OpenTTD en temiz örnek: 1950'de başlar, 2050'de "yeni teknoloji" kesilir ve tüm modellerin azami güvenilirliği donar; oyun yine de oynanır [S18][S22]. Tavan sert duvar değil, dondurulmuş bir çizgi.
4. "Her şeyi açtım" anı en çok Civilization VI'da şikâyet edilir: ağaç bitince "Future Tech"i tekrar tekrar seçmek angaryadır [S26]; tek bir tekrar eden Ar-Ge kartı oyunun geç dönemini angaryaya çevirir.
5. En büyük başarısızlık Civilization VII: çağ geçişi (ağaçların ve uygarlığın sıfırlanması) ve "teknoloji ağacının erken (yaklaşık 1960'lar) bitmesi" eleştirildi; Steam'de %51 olumlu, 29.925 yorum [S27][S29]. Çağ sıfırlaması oyuncuya ceza gibi geldi.
6. Geliştirmeyi bırakmanın cezası en iyi OpenTTD'de modellenmiş ve en çok orada tepki doğurmuş: model önce güvenilirlik kazanır (1-2 yıl), uzun süre tepede kalır, sonra "on ya da yirmi yıl" düşer ve çekilir [S18]. Tepkinin kanıtı: oyuncular bu eskimeyi tamamen kapatan bir ayar yazmış ("Vehicles never expire") [S20].
7. Eskime cezasının görünmezliği en çok iki oyunda şikâyet konusu: Mad Games Tycoon 2'de puanlar yıldan yıla düşüyor ve oyuncu nedenini bulamıyor ("bir şey değişti, oyun zorlaştı") [S10]; Software Inc.'de satış 20 bin'den sıfıra düşüyor ve oyuncular "bug mı özellik mi ayırt edemiyoruz" diyor [S15].
8. Mad Games Tycoon 2'de oyuncu teorisi: dört puan alanı "her yıl artan gizli bir değere" göre ölçülüyor [S11]. Bu bir oyuncu varsayımı, geliştirici doğrulamadı [BOŞLUK]. Ama etkisi bizim kararımızla (sektör standardı) aynı, farkı: onlarda gizli, bizde gösterilecek.
9. Geç oyunun tekrar şikâyeti en sık "para anlamını kaybediyor, rakipleri satın almak kolay, menü yönetimi" biçimindedir (Mad Games Tycoon 2) [S12] ve "Anno'da kaynaklar için bütün adaları fethedersin" [S32]; bu, sonda oyuncuya yeni karar verilmediğinin işareti.
10. Football Manager'da bitiş yılı yok; oyuncuların kendi dediği: 2-5 sezonda bırakanlar var, kalanlar "son hedef" koyuyor [S39], 11 üst üste lig şampiyonluğu "sıkıcı" [S39]. Yani bitiş yılı olmayan oyunda oyuncu bitişi kendi icat ediyor.
11. Capitalism Lab'da geride kalana yetişme desteği var: rakibin teknoloji seviyesi 100'ü aşıp sen çok gerideysen kazancın "(en yüksek − seninki) ÷ en yüksek" oranında artıyor [S38]. Bu, "dev rakibi geçmek uzun sürer" kararına zıt bir ters-ceza (yetişme) örneği. [V uyarı: formülün AI rakiplere de uygulandığı kaynakta yazmıyor]
12. Zaman: Game Dev Tycoon 35 yıl yaklaşık 5 saat (oyuncu beyanı) [S3], OpenTTD 100 yıl yaklaşık 24 saat [S22]; her ikisinde de oyuncular geç dönemde "düşünmeden tıklıyorum" diyebiliyor [S3].
13. Kararımıza karşılık gelen en güçlü kanıt: yıl kilitlerinin düz tarih tablosu değil, rastgele payla (OpenTTD: model çıkış tarihine 0-511 gün eklenir [S21]) ve "prototip/deneme teklifi" ile verilmesi; erken deneyene riskli ama öne geçirici bir ürün, geç kalana olgun ürün [S18].
14. Bu bulguların ortak sonucu: eskime cezası (a) kademeli, (b) adlı ve görünür, (c) takvime değil standarda bağlı olmalı; aksi hâlde "haksız" ya da "bug" okunuyor.

---

## 1. Karşılaştırma tablosu

| Oyun | Bitiş yılı var mı? Neden? | "Hepsini açtım" anına kalan | Bırakana ceza | Ceza görünürlüğü |
|---|---|---|---|---|
| Game Dev Tycoon | Varsayılan 35 yıl (80'lerde başlar), ayarlanabilir (42 yıl seçeneği var), kayıtta değişmez; süre dolunca puan hesaplanır, platform çıkışı durur, oyun sürer [S1][S2][S3] | Oyuncular 35 yılın ardından "yapılacak çok şey var" (özel konsol, MMO, Ar-Ge, AAA) diyor [S3]; ama inceleme "çoğu zaman sayıların yükselmesini izlemek" diyor [S6] | Doğrudan eskime cezası kaynakta yok [BOŞLUK]; oyuncular "her zaman şimdiye kadarki en iyi oyununla ölçülürsün, ölçüt değişiyor" diyor [S4] | Oyuncu bunu forumda çıkarıyor, oyun söylemiyor (varsayım: ekrandan okunmuyor; kaynakta aksi yok) |
| Mad Games Tycoon 2 | Bitiş yılı yok: 1976-2020 arası başla, "bir yüzyıl ve ötesi" [S7] | Geç oyun tekrarlı, para anlamsız, rakipleri satın almak kolay [S12] (Düşük kaynak) | Eski motor/özellik puanı düşürür; puan karşılaştırması yıldan yıla artan gizli bir değere göre (oyuncu teorisi) [S9][S11] | Gizli; oyuncu "bir şey değişti, oyun zorlaştı" [S10] |
| Software Inc. | Bitiş yılı bulunamadı [BOŞLUK] | Oyuncu raporu: "endgame yaklaşık 16 saatte", tam oyun ~45 saat [S14] (Düşük) | Rakip sürüm ya da doygunluk satışı sıfırlıyor; OS/RPG ürünleri 4-5 yıl, antivirüs en kısa [S16] | "Bug mı özellik mi ayırt edemiyoruz" [S15]; "potansiyel müşteri kalmadı" mesajı var [S15] |
| Civilization (VI, VII) | VI: yıl/tur sınırı kaynakta doğrulanamadı [BOŞLUK]; VII: üç çağ, Atom Çağı 2027'de gelir ve takvim 2050'ye uzar [S27] | VI: tur 150'den sonra karar yok (oyuncu görüşü) [S25]; ağaç bitince Future Tech angaryası [S26] | VI: doğrudan eskime cezası yok (birimler değil teknoloji kaybı); VII: çağ sonu krizleri [S27] | VII: çağ geçişleri görünür ama "ani" bulundu [S27] |
| Anno 1800 | Bitiş yok; sandbox sonsuz, kampanya biter [S33] | Oyuncular "kendi hedefini koyuyorsun"; "oyunun koyduğu sert hedef isteyen için uygun değil" [S33] | Kaynaklar tükenir, adalar fethedilir [S32] | Görünür (kaynak ve nüfus) |
| OpenTTD | Varsayılan 1950-2050; 2050'den sonra yeni teknoloji yok, güvenilirlik donar; oynamaya devam edilir [S18][S22]. Neden: kaynak yok [BOŞLUK] | Tam seyir yaklaşık 24 saat [S22]; geç oyun şikâyeti kaynakta yok [BOŞLUK] | Güvenilirlik düşer, model çekilir; ayar ile kapatılabilir [S18][S20] | "Eskiyor" uyarısı yalnız araç depoya girerse gelir [S19] |
| Capitalism Lab | Bitiş yılı bulunamadı [BOŞLUK]; ürünler "belirli yıla kadar kilitli", Ar-Ge listesinde "açıldığı yıl" yazar [S37] | [BOŞLUK] | Geride kalana yetişme desteği [S38]; cezası kaynakta yok [BOŞLUK] | Ar-Ge listesi rakip icadını gösterir [S37] |
| Football Manager | Resmî bitiş yok; yıllık sürüm, veritabanı yılda iki kez güncellenir [S41] | Oyuncular 2-5 sezonda bırakır, kalanlar son hedef koyar; 2061-62 sezonuna kadar oynanmış kayıt var [S39] | Yoktur (bıraktığında kulüp seni kovar kaynakta yok) [BOŞLUK] | n/a |

---

## 2. Oyun oyun

### 2.1 Game Dev Tycoon

Olgu:
- Greenheart Games, 10 Aralık 2012'de çıkardı [S2]. Oyuncu 80'lerde başlar, "oyun endüstrisinin tarihini baştan oynar" [S1].
- Varsayılan süre 35 yıl; SSS'de: "normal oyun süresi dolunca puanın hesaplanır ve artık platform çıkışı olmaz", ama "oynamaya ve bir şeyleri açmaya devam edebilirsin" [S1]. Süre ayarlanabilir, kayıtlı oyunda değişmez [S1]. Oyuncular 42 yıllık seçeneği de anıyor [S3][S4].
- Yıllar konsolları getirir: oyuncu, yeni çıkan konsollar için lisans satın alır; konsol adları gerçek olanların parodisi [S2]. Açılışlar ise ilerleme ve Ar-Ge'ye bağlı: ilk oyunla motor kurulur, belli koşulda Ar-Ge laboratuvarı, MMO ve çevrimiçi mağaza açılır, sonra donanım laboratuvarı [S2]. Yani konular yıla değil ilerlemeye, platformlar yıla bağlı.
- Süre sonrası: Greenheart resmî hesabı 2017'de yazdı: "kodda bakınca 301. yıla varınca bütün platformların oyundan kaybolabilir" [S5]. Oyuncu 291. yılda, bir başkası ~150 yılda bırakmış: "7'nin üstünde oyun yapamıyordum, anlamı kalmadı" [S5].
- Süre ve tempo: 2013'te oyuncular "35 yıl ~5 saat" diyor ve "daha yavaşsa sıkıcı olurdu" ile "çok hızlı" diye bölünüyor [S3]. Bir oyuncu 20. yılda 40 oyun yapmış: "artık düşünmüyorum, sadece tıklıyorum" [S3].
- 2017: oyuncu 33. yılda 800 milyon kredi ve 2 milyon hayranla bitirmek üzere; zorluğun nedenini "her zaman şimdiye kadarki en iyi oyununla yargılanırsın, ölçüt değişiyor" diye anlatan bir yanıt var [S4].
- İnceleme (15 Eylül 2013): "çoğu zaman sayıların yükselmesini izlemek"; tarih sabit: "tarihin gittiği yerden ayrılamazsın" [S6].
- Puan: Metacritic PC 68, iOS 89, Switch 81 [S2].

Başarısız/eleştiri: tekrar. Güvenilir olan: inceleme "derin bir deneyim değil" [S6]; oyuncu "düşünmeden tıklıyorum" [S3].

[BOŞLUK] Hangi konunun hangi yıl açıldığı, platform çıkış/emeklilik yılları (wiki'ye erişilemedi). [BOŞLUK] "Eskime cezası" olarak doğrulanmış bir kural bulunamadı; oyuncu görüşü yalnız "ölçüt, senin en iyi oyununa göre" [S4] (tek oyuncu iddiası).

**Oyuna ders**
- Bitiş yılını yeni oyun ekranında bir kez oyuncu seçsin (35/42 gibi) ve kayıtta kilitlensin: karar sıklığı oyun başına 1 [S1]. 
- Bitişte puan hesapla, sonra serbest oyun sun; ama içerik (yeni dönem kartı, yeni rakip sürümü) bitiş yılından sonra üretmeye devam etme: kodun kendisi 301. yılda bozuluyor [S5] [GÖRÜŞ: bitişten sonra içerik dondurulur, OpenTTD gibi].
- "Ölçüt = senin en iyi işin" kuralından kaçın: oyuncu bunu "nedeni görünmeyen zorlaşma" diye yaşıyor [S4]. Ölçüt pazarın standardı olsun (K3).
- Yıl başına karar yoğunluğu: 20 yıllık seyirde oyuncu "tıklıyorum" noktasına geliyor [S3]; Unicorn'da yıllık tekrarlayan karar sayısı yıldan yıla artmamalı (en az "her yıl yeni bir şey" ya da kartlar azalmalı).

### 2.2 Mad Games Tycoon 2

Olgu:
- 1976-2020 arası herhangi bir yılda başlanır; "bir yüzyıl ve ötesi" oynanır; motor yapılır ya da rakipten lisanslanır ve "yeni teknolojilerle güncel tutulması gerekir" [S7]. Steam: %93 olumlu, 2.229 İngilizce yorum (erişim günü) [S7]. Erken erişim 21 Ocak 2021, tam sürüm 31 Mayıs 2023 [S7].
- Bitiş yılı: yok [S7]. Yıl başlangıcı mekaniği etkiler: geliştirici ağırlığı 1976'da ~20 stüdyo, zamanla 71'e çıkar [S8].
- Puan kuralı (oyuncu analizi, 18 Mart 2024, Düşük): motor özellikleri ne kadar yeniyse o kadar iyi; dört puan alanı (oynanış, grafik, ses, teknik) "her yıl artan gizli bir değerle" karşılaştırılıyor; son %2 rastgele [S11]. Başka bir oyuncu: motor "çağın gerisindeyse" puan düşer; ancak sayısal ceza gösterilmemiş [S9]. Bir oyuncu "yıl 1990'da B oyun ya da 2000'de B+ ile %70-80 alırsın" diyor [S9].
- Oyuncu deneyimi (10 Temmuz 2021): "Her yeni oyun daha düşük puan alıyor, %30-60... İnsanlar yıldan yıla daha iyi oyun istiyor gibi... zaman içinde bir şey değişti, oyun zorlaştı"; yanıt: "B sınıfı oyunlarla geç yıllarda %80-90 alıyorum"; asıl neden kalite kontrolünün ihmali, baş tasarımcının düşük yeteneği [S10].
- Geç oyunda %70'in altında puan almak zor: "tek yol eski motor ve az özellik"; "bu oyunun böyle çalışıyor" [S9]. Yani geç oyun cezası fiilen yok, oyuncunun gözünde tersine "kötü oyun yapamıyorum" şikâyeti var [S9].
- Motor satışı: yapay zekâ stüdyoları motor lisanslamada en yeni olanı rastgele seçiyor; 10 yıl boyunca kimse almadı; geliştirici "motorlardan kazanç çok az, dengelemek lazım" [S8].
- Özet site (Düşük, LLM toplayıcısı [S12]): şikâyetler: tekrar (0,25), öğretici yetersiz (0,22), geç oyun ilgi çekmiyor (0,13); geç oyun: menü yönetimi ve çubuk bekleme, para anlamsız, rakipleri satın almak kolay, 150 çalışan üstünde kasma. "Ağırlık" ham sayı değil. Güncelleme durdu (0,09).

**Oyuna ders**
- Geç oyunda "yeni karar yok, para anlamsız, rakip satın al" tablosu bizim 50 kişi + yüzlerce B2B hesap geç oyunumuz için doğrudan risk [S12 Düşük]: para harcama yeri (Ar-Ge dalı, yeni modül) geç yıllarda da gerçek karar doğurmalı.
- Motor analoğu: bizde "Ar-Ge ağacı + alan seviyesi" kararlıdır. MGT2'de "eski motor = puan düşüşü" ama cezanın büyüklüğü gösterilmiyor [S9][S11]; oyuncular forumdan öğreniyor. Bizde sektör standardı oyuncuya doğrudan "yıl X'te bu alanın standardı N, seninki M" olarak gösterilsin (karar sıklığı: her büyük standart kaymasında 1 uyarı, yılda ~1-2).
- "Gizli yıllık artış" modeli oyuncuda "bir şey zorlaştı" hissi doğuruyor [S10]; yılın artışı duyurulmalı (haber şeridi: "Standart yükseldi").

### 2.3 Software Inc.

Olgu:
- Steam: 1 Mayıs 2015'te erken erişim; %94 olumlu, 5.638 yorum; bitiş yılı mağaza sayfasında yok, yıla bağlı teknoloji kilidi sayfada yok [S13]. Bitiş yılı [BOŞLUK].
- Teknoloji seviyesi: tasarım belgesinde teknoloji seviyesini yükseltmek pazar ilgisini yükseltir; yıl başlıklı örnek: "1985 teknoloji seviyesi" yayın sonrası güncellemeyle satışı artırmış; "ilk olursan ucuz üstünlük" [S16] (oyuncu iddiası).
- Ürün ömrü (oyuncu): antivirüs en kısa, işletim sistemi ve macera/RPG 4-5 yıl [S16]. Sürekli güncellemeyle uzun yaşayan antivirüs: ~2 milyon adet, ayda ~100 bin [S16]. Pazar doygunluğu: "bu ürünün potansiyel müşterisi kalmadı" mesajı var [S15].
- Ani düşüş: 6 Nisan 2021: oyun ayda ~20 bin adetten fiilen 0'a; 15 Nisan: yeni oyun 10 bin'den 4'e. Açıklamalar: aynı ay aynı kategoride rakip çıktı. Oyuncunun yorumu: "muhtemelen tasarım ama bu kadar aşırı olması amaçlanmamıştır... bug olarak bildireceğim"; başka oyuncu: "mekanikleri bilmeden bug'ı özellikten ayırt edemezsin" [S15]. Fiyat indirimi bir yıldan eski oyunda adedi değiştirmedi [S15]. Satış sonradan neredeyse tepeye döndü [S15].
- Satıştan kaldırma: ürünü satıştan çıkaramıyorsun, oyun ilk antivirüsün "talep var" mesajını sürekli gösteriyor; "ürünü rafa kaldırmak zor" şikâyeti 2019-2022 arası sürdü [S17]. Arşiv kuralı: son alımdan 10 yıl (doğrulanmamış foruma dayalı iddia) [S17].
- Özet (Düşük [S14]): derin iş simülasyonu en güçlü yan; negatifler: karmaşıklık, kalabalık arayüz, tekrar (0,19), mikro yönetim; geç oyun performansı. Tam oyun ~45 saat, "endgame ~16 saat" oyuncu beyanı.

Başarısız/eleştiri: ceza görünmezliği ve "ölü ürünü kaldıramama" tamamen bu oyunda.

**Oyuna ders**
- Aynı mekanik (rakip çıkışı satışı sıfırlıyor) tasarım olarak doğru olabilir ama "bug mı özellik mi" yaşatıyor [S15]: Unicorn'da her büyük düşüşün adı olsun ("Rakip X sürümü: hesap Y'nin sektör standardı geçildi"), karar sıklığı: her yenilemede 1.
- Ürün ömrü sektöre göre farklı (4-5 yıl, antivirüs kısa) [S16]: ERP, not aracı, video türlerinin "yenileme döngüsü" farklı olabilir ama bu kaynaklar gerçek pazar değil oyuncu beyanı; sayıyı kalibrasyona bırak.
- Sürekli güncelleme ürünü uzun tutuyor [S16]: "geliştirmesem de olur" yorumunu önleyen kanıt (oyuncu beyanı; Düşük).
- Ölü ürünü rafa alma: Unicorn'da eski sürüm/alan için "bakımı kes" kararı gerekirse açık olmalı (aksi sürekli mesaj yağar [S17]).

### 2.4 Civilization (VI ve VII)

Olgu (VI):
- 20 Ekim 2016 çıkış; Steam %85 olumlu, 107.923 yorum (erişim günü) [S30]; Metacritic PC 88, 11 milyondan fazla satış (2023) [S23].
- Geç oyun: "tur 150'de kararlar verilmiş" yaygın görüş (oyuncu), "250 turda oynarım çünkü neredeyse her zaman o noktada karar verilmiş" [S25]. "Sanayi ya da modern çağdan sonra keyif düşer" [S25]. 2021 Şubat'ta 675 saatte "yalnız 3 oyun bitirdim" diyen var [S25].
- Ağaç bitince: oyuncu 2016: "turlar dakikalar alıyor... Future Tech ya da Globalization'ı sürekli yeniden seçmek zorundayım... teknoloji dolmadan kazanmaya itiliyorum" [S26].
- PCGamesN (22 Aralık 2021): ödüllendirdikçe oyuncu kartopu (snowball) olup yapay zekâyı yeniyor; baş tasarımcı Ed Beach: "Gelecek Çağı seçenekleri seni belirli bir zafere doğru itmek için çok dikkatli tasarlandı" [S24].
- Bitiş yılı/tur sınırı: bir forumda "ayar açık kalırsa oyun 2050'de biter" ve "500. turda biter" iddiaları var ama doğrulanmadı [BOŞLUK; tek forum, Düşük].

Olgu (VII): 
- Üç çağ (Antik, Keşif, Modern); çağ sonunda "kriz olayları" ve oyuncu yeni uygarlık seçer ya da aynısıyla sürer [S27]. Çıkış 11 Şubat 2025 (Steam sayfasında 10 Şubat, [S29]); Steam %51 olumlu, 29.925 yorum; Metacritic 79; fırlama haftası 80.000'den fazla eşzamanlı, Mayıs 2025'te 5.000'in altı [S27][S29].
- Eleştiri: "çağların ani oluşu ve uygarlık değiştirmenin sürükleyiciliği bozması"; ayrıca "teknoloji ağacının erken (yaklaşık 1960'lar) bitmesi" [S27]. Atom Çağı 2027'de gelir ve takvimi 2050'ye uzatır [S27]. 19 Mayıs 2026'da 1.4 güncellemesi tek uygarlıkla oynamaya izin veriyor [S27].
- Eleştirmen (Game File, 6 Şubat 2025): çağ başına "daha kısa vadeli hedefler" ve kurallar değişiyor (antik çağda yollar elle, keşifte otomatik); ilk çağın keyifli olduğu söylenirken oyun "birkaç yama uzakta" diyor [S28].

Başarısız: VII'nin çağ sıfırlaması en güçlü kanıt: bir oyunun ilerleme bölmesi oyuncunun elindekini siliyorsa (ya da öyle okunuyorsa) güvensizlik doğuyor. Gerekçe ayrıca doğrulanmış değil; VII'nin düşük puanı tek nedene bağlanamaz (arayüz, harita çeşitliliği vb.) [SIÇRAMA'ya dikkat].

**Oyuna ders**
- Ağaç bitince tekrar eden kart yok: "Future Tech tekrarı" angaryadır [S26]. Unicorn'da Ar-Ge'nin son basamağından sonra oyuncudan tekrar eden seçim istenmesin; son basamak bitiş yılına yakın açılsın, ağaç oyun bitmeden önce biter hâle gelmesin (K6: "erken yıllarda tavana varılamaz").
- Karar yoğunluğu: "ilk 150 tur" görüşü [S25] Unicorn'da "ilk 4-5 yıl sonrası karar yok" tehlikesini gösterir; yıl ortasında/yenilemede gelen İSTEK kartları (K1) geç dönemi canlı tutmanın aracı; sıklık: 50 kişilik ekipte yılda ~6-10 istek (varsayım, kalibrasyon).
- Çağ sıfırlaması yapma: sektör standardı yükselir ama oyuncunun elindeki ürün alanı silinmez; gerilik "farkın büyümesi" olarak görünür, "yeniden başla" olarak değil [S27][S29].
- Dönem geçişini oyuncu seçimine bağlayan Civ VII mekaniği (ve gördüğü tepki) kopyalanmasın [GÖRÜŞ].

### 2.5 Anno 1800

Olgu:
- Çıkış 16 Nisan 2019; Steam %78 olumlu, 12.144 yorum (erişim günü) [S31]. Metacritic PC 81, OpenCritic %95 öneri (63 yorum) [S35]. Aşırı fiyat/DLC şikâyeti en yaygın [S34] (Düşük).
- Bitiş yok: kampanya sandbox'a döner, "kampanya sabit başlangıçlı sandbox" [S33]. Oyuncular kendi hedeflerini koyuyor ("5.000 yatırımcılı şehir", "bir milyon yatırımcı"), "oyunun koyduğu sert hedef isteyen için uygun olmayabilir" [S33]. Dört yıl oynayan oyuncu: sandbox geç oyunda çok zor, sık yapay zekâ ve korsan saldırısı [S33].
- Geç oyun: "sonda kaynak için bütün adaları fethedersin çünkü mega şehri besleyecek yeterin yok" [S32]. Tükenen kaynak için yenileme düğmesi "sıkıcı tekrar eden iş" sayılıyor (1404'ten örnek) [S32].
- Özet (Düşük [S34]): "100+ saatten sonra yorgunluk", "elektronik tablo gibi geç oyun". Ağırlıklar çok düşük (0,01-0,06); güvenilmez.

**Oyuna ders**
- Geç oyunu zorluk/kıtlıkla canlı tutmak işe yarıyor (kaynak kıtlığı → fetih) [S32]; ancak "yenileme düğmesi" gibi angarya hâlini alıyor. Unicorn'da geç oyunda ölçeklenen tehdit "yenilemede şart" (K1) olarak gelir; bunun düğmeyle çözülmesi gerekmez.
- Hedefi oyun koymalı mı: "oyunun sert hedefi" isteyen oyuncu için sandbox yetmiyor [S33]. Unicorn'da bitiş yılı + puan, hedef işini görür [S1].

### 2.6 OpenTTD

Olgu:
- Varsayılan başlangıç 1950; bitiş 2050: 2050'den sonra yeni teknoloji yok ama oynanır; tam seyir yaklaşık 24 saat [S22]. Ray türleri sırayla: elektrikli, monoray, maglev [S22].
- Model ömrü: yeni model düşük azami güvenilirlikle başlar, "bir iki yıl" tırmanıp tepeye varır, uzun süre tepede kalır, model yaşlanınca güvenilirlik düşer, "on-yirmi yıllık düşüşten sonra" model satıştan çekilir; başlangıç, tepe, son değerler her oyunda rastgele atanır; 2050'de tüm modellerin azami güvenilirliği oyun sonuna kadar donar [S18].
- Prototip: düşük azami güvenilirlik, resmî çıkışta artar; deneme teklifini geri çevirir ve o tipi hiç kurmazsan 5 yıl teklif gelmez [S18].
- Çıkış tarihi: NewGRF kaydında taban tarihe her yeni oyunda 0-511 gün rastgele eklenir (oyunun ilk iki yılında rastgeleleştirilmez [V uyarı]); model ömrüne 31 ay-17 yıl eklenir [S21]. Araç ömrü ve model ömrü ayrı özellik; güvenilirlik azalma hızı bir özellik [S21].
- Bakım: depoda servis güvenilirliği modelin güncel azamisine sıfırlar; yaşlanma uyarısı yalnız araç depoya girerse gelir ("depoya girmeyen araç için eskiyor uyarısı almazsın") [S19].
- Oyuncuların eskimeye cevabı: "Vehicles never expire" ayarı eskimeyi kapatır: "eski bir buhar makinesi yeni bir monoray ile yan yana koşar" [S20]; sonradan açarsan yitenleri geri getirmez (komut: `resetengines`) [S20]. Neden eskitildiği sayfada yazmıyor [S20] [BOŞLUK].
- Resepsiyon: tamamı olumlu (2004 Amiga Games Awards oylaması, PC Gamer ve RPS sıralamaları) [S22]. Tek eleştiri başlığı: "Oyun hızı çok hızlı" [S22].

**Oyuna ders**
- Yıl kilidi: yıla rastgele pay ekle (OpenTTD ±511 gün) [S21]: "2016'da X çıkar" yerine "2016 ± 1,4 yıl". Karar sıklığı: yeni bir dönem teknolojisi başına oyuncu 1 kez "erken uygula" ya da bekle kararı verir.
- "İlk atılımı yapan şirket" fikri (K2) için hazır model: prototip (düşük güvenilirlik) → olgunlaşma. Erken uygulayan hata riskini alır; geç kalan olgun ürünü alır ama pazar payını kaybeder [S18] [GÖRÜŞ].
- Eskime eğrisi: 1-2 yıl yükseliş, uzun tepe, on-yirmi yıl düşüş [S18]: bizim "geliştirilmeyen ürünün cezası" için yavaş ve öngörülebilir bir eğri; ani çekilme (bir yıl sonra ürün yok) oyuncuyu "never expire" ayarını icat etmeye götürdü [S20]. Yavaş, görünür, her zaman geri kazanılabilir olmalı.
- Uyarının yalnız servise giren araca gelmesi [S19] bir tasarım zayıflığı: ceza, oyuncu bakmasa da kendini göstermeli (haber şeridi/özet).
- Tavanı 2050'de dondurup oynamayı sürdürme: Unicorn'da bitiş yılından sonra standart sabitlenir [S18][S22].

### 2.7 Capitalism Lab

Olgu:
- Çıkış 17 Aralık 2001 (Capitalism II); genişletilmiş Capitalism Lab 14 Aralık 2012; DLC'ler 2014 (Subsidiary), 2016 (City Economic Simulation), 2018 (Digital Age), 2020 (Banking and Finance) [S36]. Metacritic 82; PC Zone %52 [S36].
- Ürünler: "bazı ürünler belirli bir yıla kadar Ar-Ge için kilitli"; Ar-Ge listesinde "açıldığı yıl" sütunu, "başka şirket icat etti mi" sütunu ve ön koşul (akıllı telefon için kameralı telefon) var [S37].
- Teknoloji Ar-Ge (Digital Age DLC): Ar-Ge birimi, araştırmacı yetenekleri, süre seçilir; rakibin teknoloji seviyesi 100'ü aşınca ve sen çok gerideysen kazancın artar: ek kazanç = temel kazanç × (en yüksek − seninki) ÷ en yüksek; örnek: temel 30, seninki 50, rakip 500 → +27 → 57 [S38]. Teknolojiyi ürünlere uygulanır.
- Bırakmanın cezası: sayfa "önde tutar" diyor, ama araştırmazsan ne olduğunu yazmıyor [S38] [BOŞLUK]. Bitiş yılı [BOŞLUK]. Oyunun yıl aralığı kaynaklarda yok [BOŞLUK].

**Oyuna ders**
- Yetişme kuralı: geride kalan oyuncu için araştırma kazancını oranla artıran formül (rubber band) mevcut ve basit [S38]. [V düzeltme: sayfa yalnız oyuncu tarafı çarpanını anlatıyor; rakip ve oyuncunun aynı kart listesini yürüttüğü ve formülün AI rakiplere de uygulandığı kaynakta yazmıyor, bu bizim tasarım okumamız] K2'ye (dev rakip yüksek başlar, geçmek uzun sürer) uyumlu: geç kalan çok geride kalırsa yetişme kolaylaşır, ama asla öne geçirmez (örnekte +27 temel 30'a). Oyuncu "kendi hızımı artırabilirim" der. [GÖRÜŞ] Kullan, sabit değil oran olarak (1 ve 50 kişide kırılmaz).
- Ar-Ge listesinde "açıldığı yıl" + "rakip yaptı mı" sütunları [S37]: oyuncuya liderlik bilgisi verilip verilmeyeceği sorusuna kanıt: bu oyun rakip icadını gösteriyor. [GÖRÜŞ] Gösterim sadece "icat edilmiş mi" kadar; rakibin seviyesini değil.

### 2.8 Football Manager

Olgu:
- Seri yıllık, Ekim-Kasım'da çıkar; veritabanı çıkışta ve Şubat'ta güncellenir [S41]. FM 2024 en çok oynanan sürüm (19 milyon oyuncu, Eylül 2025); FM25 Şubat 2025'te iptal edildi [S41]. Kariyer uzunluğu sınırı sayfada yok [S41].
- Uzun kayıtlar: FM20'de 2061-62 sezonuna kadar [S39]. 2013 FM Scout: "birkaç sezon" ile "25+ yıl" arası; neden bırakılır: yeniden üretilen oyuncular (regen) çıkmaya başlayınca; "regen'lere duygusal bağ yok"; kendi kulübünün regen'leri ~10 sezon durmuş [S40].
- Passion4FM röportajı (28 Temmuz 2021): "Çoğu oyuncu iki-beş sezonda bırakıyor"; kalanlar için son hedef şart ("Ana şey için bir son hedef"); "11 üst üste Premier Lig şampiyonluğu sıkıcı olur"; "bir kere kazanmaya başlayınca kazanmaya devam edersin"; gelecek dünya "çok değişmiyor" [S39].

**Oyuna ders**
- Kazanç oyuncuya "kazanmaya devam" döngüsü kuruyor ve sonunda sıkıcı [S39]: Unicorn'da geç yıllarda sektör standardı yükselirken oyuncunun lider olduğu bir alan da standardı geride bırakmaya devam ederse "çözüldü" hissi olur; bu yüzden sektör standardının yükselişi her yıl yeni bir "ihtiyaç" getirsin (yıl ortası İSTEK). Bu bulgu tek röportaj ve forum, Düşük-Orta.
- Bitiş yılı olmayan oyunda oyuncu kendi bitişini icat ediyor [S39]; Unicorn zaten bitiş yılı koyuyor, doğru yönde.

---

## 3. Başarısızlar ve eleştirilenler (ayrı, derli)

1. Civilization VII çağ geçişi: "ani", "uygarlık değiştirmek sürükleyiciliği bozuyor", "ağaç erken bitiyor"; Steam %51 [S27][S29]. Sonradan tek uygarlıkla oynama güncellemesi (Mayıs 2026, 1.4) geldi [S27]. Ders: ilerlemeyi bölen sıfırlama.
2. Civilization VI geç oyun: kartopu, yapay zekâ yetişmiyor, tur 150'den sonra kararsızlık, Future Tech angaryası [S24][S25][S26]. Ders: "açtım" noktasından sonra tekrar kartı.
3. Mad Games Tycoon 2 geç oyun: tekrar, para anlamsız, rakip satın almak kolay (Düşük) [S12]; puanlar yıldan yıla düşüyor ve neden anlaşılmıyor [S10]; geç oyunda kötü oyun yapamama [S9].
4. Software Inc. görünmez satış çöküşü: "bug mı özellik mi" [S15]; ürün rafa kaldırılamıyor [S17].
5. OpenTTD eskime: oyuncular eskimeyi kapatan ayar yazmış [S20]; uyarı yalnız depoya girenlere [S19].
6. Game Dev Tycoon tempo/tekrar: "çok hızlı", "düşünmüyorum, sadece tıklıyorum" [S3]; inceleme "çoğu zaman sayıların yükselmesini izlemek" [S6].
7. Football Manager: bırakma 2-5 sezonda; "kazanmaya devam" [S39]; regen'lere bağ yok [S40].
8. Anno 1800: DLC/fiyat ve yorgunluk (Düşük) [S34]; yenileme düğmesi angarya [S32].
9. Capitalism Lab: PC Zone %52 [S36], nedeni bulunamadı [BOŞLUK].

Bulunamayanlar: Game Dev Story (Wikipedia sayfası 20 yıllık süre ve yıl kilidini yazmıyor [BOŞLUK]); Software Inc. ve Capitalism Lab'ın bitiş yılı; Mad Games Tycoon 2 ve Game Dev Tycoon'un resmî puan formülü; Civilization VI'nın tur sınırı ve neden-i.

---

## 4. Çapraz sonuçlar ve Unicorn kararlarına bağlama

Kararlar: Erdem K1-K9 (bu belgenin brief'inde özet). Sıklık: kabaca, oyuncu başına.

| Bulgu | Karar | Sıklık |
|---|---|---|
| Bitiş yılı duyurulu, ayarlı, kayıtta kilitli (GDT [S1]); bitişte puan; sonra serbest, içerik donuk (OpenTTD [S18]) | K6 bitiş yılı | Oyun başına 1 seçim, bitişe 2-3 yıl kala bildirim (varsayım) |
| Yıl kilidi rastgele payla (OpenTTD ±511 gün [S21]) | K6 yıla bağlı kilitler | Yeni dönem teknolojisi başına 1 "erken uygula / bekle" |
| Prototip → olgunluk (OpenTTD [S18]) | K2 "ilk atılımı yapan" | Büyük dönem başına ~1 (ör. YZ dönemi) |
| Eskime = kademeli, görünür, takvime değil standarda bağlı (OpenTTD [S18], MGT2 sorunu [S10], SoftInc sorunu [S15]) | K8 geliştirilmeyen ürünün cezası | Her yenilemede 1 görünür gerekçe; yılda 1-2 standart kayması duyurusu |
| Ağaç bitince tekrar eden kart yok (Civ VI [S26]) | K6 tavan | Son basamak sonrası 0 tekrar |
| Çağ sıfırlaması yok (Civ VII [S27][S29]) | K3 standart büyümesi | Hiç |
| Yetişme desteği oranla (CapLab [S38]) | K2 dev rakip | Sürekli (hız çarpanı), karar değil |
| Geç oyunda para harcama yeri (MGT2 [S12]) | K5 koltuk/modül, K6 | Yılda ≥ birkaç gerçek karar |
| Rakip icadını gösteren liste (CapLab [S37]) | K2 liderlik bilgisi sorusu | Pasif; oyuncu bakınca |

Kopya yok kuralı (K2) ile uyum: bu oyunların hiçbirinde "rakip senden kopyalar" mekaniği kaynaklarda görülmedi; Capitalism Lab'da rakipler icat eder [S37], OpenTTD'de modeller zamanla ortaya çıkar [S18]. Rakip = bağımsız kart listesi koşturuyor, oyundaki bu örnekler bununla uyumlu.

[SIÇRAMA uyarısı] Bu belge oyun mekaniklerini karşılaştırıyor; gerçek ERP pazarı bu belgenin konusu değil. "Dev rakip yüksek başlar" gibi ERP'ye özgü sayılar için diğer araştırmalara bakılmalı.

---

## 5. Boşluklar (özet)

- Game Dev Tycoon ve Software Inc. wiki'lerine erişim yok (HTTP 402): yıl-konu/özellik tabloları [BOŞLUK].
- Software Inc. ve Capitalism Lab bitiş yılı, Capitalism Lab oyun yılları [BOŞLUK].
- Civilization VI/V tur sınırı ve 2050 iddiası doğrulanamadı [BOŞLUK].
- OpenTTD'nin eskitmeyi neden koyduğu belgede yok [BOŞLUK]; ceza şikâyetinin boyutu (kaç oyuncu) bilinmiyor.
- MGT2 "yıllık artan gizli değer" tek oyuncu teorisi [BOŞLUK]; geliştirici doğrulamadı.
- Özet siteler (vaporlens) LLM toplayıcısı; ağırlıkları ham sayı değil [DEĞERLENDİREMEM].
- Oyunlarda "geç oyunu bitirenlerin oranı" (örn. Steam başarım yüzdeleri) aranmadı; arama bütçesi bitti [BOŞLUK].

---

## 6. Kaynak sicili

Güven: Yüksek/Orta/Düşük. Wikipedia sayfaları sürekli güncellenir, kesin yayın tarihi alınmadı ("güncel sürüm"). Forum yayını tarihi
görünen gönderi tarihidir. Erişim hepsinde 2026-10-20. Satıcı sayfası ve oyuncu forumu kural gereği Düşük; yapımcının resmî hesabının
yazdığı tek satır (S5) Orta.

| S# | URL | Yayıncı | Yayın tarihi | Güven |
|---|---|---|---|---|
| S1 | https://www.greenheartgames.com/app/game-dev-tycoon/ | Greenheart Games (yapımcı) | güncel | Düşük (kural cümleleri için kullanıldı) |
| S2 | https://en.wikipedia.org/wiki/Game_Dev_Tycoon | Wikipedia | güncel | Orta |
| S3 | https://steamcommunity.com/app/239820/discussions/0/864977564053270644 | Steam Topluluğu (oyuncular) | 29 Ağu - 12 Eyl 2013 | Düşük |
| S4 | https://steamcommunity.com/app/239820/discussions/0/1480982338955468057 | Steam Topluluğu | 28-31 Eki 2017 | Düşük |
| S5 | https://steamcommunity.com/app/239820/discussions/0/1489992080501169124 | Steam Topluluğu (Greenheart Games hesabı yanıtı) | 22-24 Kas 2017 | Orta (yapımcı yanıtı), Düşük (oyuncu kısmı) |
| S6 | https://gamechronicles.com/game-dev-tycoon-review-pcsteam | Game Chronicles, Grant Chen | 15 Eyl 2013 | Orta |
| S7 | https://store.steampowered.com/app/1342330/Mad_Games_Tycoon_2/ | Steam mağaza sayfası (Eggcode Games) | güncel | Düşük (satıcı); yorum oranı veridir |
| S8 | https://steamcommunity.com/app/1342330/discussions/0/3114770279403884600 | Steam Topluluğu (Eggcode Games yanıtları) | 22-23 Oca 2021 | Düşük-Orta |
| S9 | https://steamcommunity.com/app/1342330/discussions/0/3060745474558303053/ | Steam Topluluğu | 10-11 Ağu 2021 | Düşük |
| S10 | https://steamcommunity.com/app/1342330/discussions/3/3058491773346971759/ | Steam Topluluğu | 10 Tem 2021 | Düşük |
| S11 | https://steamcommunity.com/app/1342330/discussions/0/7607215340155700440 | Steam Topluluğu | 18 Mar 2024 - 5 Oca 2025 | Düşük |
| S12 | https://vaporlens.app/app/1342330/mad_games_tycoon_2.md | VaporLens (LLM toplayıcı özet) | güncel | Düşük |
| S13 | https://store.steampowered.com/app/362620/Software_Inc/ | Steam mağaza sayfası (Coredumping) | güncel | Düşük (satıcı); yorum oranı veridir |
| S14 | https://vaporlens.app/app/362620/software_inc.md | VaporLens (LLM toplayıcı özet) | güncel | Düşük |
| S15 | https://steamcommunity.com/app/362620/discussions/0/3079873787853220696/ | Steam Topluluğu | 6-26 Nis 2021 | Düşük |
| S16 | https://steamcommunity.com/app/362620/discussions/0/6664812048263024906/ | Steam Topluluğu | 17-26 Haz 2023 | Düşük |
| S17 | https://steamcommunity.com/app/362620/discussions/0/1743386743030347842/ | Steam Topluluğu | 3 Ara 2019 - 21 Kas 2022 | Düşük |
| S18 | https://wiki.openttd.org/en/Manual/Vehicles | OpenTTD wiki (proje) | güncel | Orta |
| S19 | https://wiki.openttd.org/en/Archive/Manual/Settings/Advanced%20Settings/Vehicles | OpenTTD wiki (arşiv) | güncel | Orta |
| S20 | https://wiki.openttd.org/en/Archive/Manual/Settings/Never%20expire%20vehicles | OpenTTD wiki (arşiv) | güncel | Orta |
| S21 | https://newgrf-specs.tt-wiki.net/wiki/Action0General | NewGRF spesifikasyonu (tt-wiki) | güncel | Orta |
| S22 | https://en.wikipedia.org/wiki/OpenTTD | Wikipedia | güncel | Orta |
| S23 | https://en.wikipedia.org/wiki/Civilization_VI | Wikipedia | güncel | Orta |
| S24 | https://pcgamesn.com/civilization-vi/strategy-game-endgame-design | PCGamesN, Joe Robinson | 22 Ara 2021 (güncelleme) | Orta |
| S25 | https://forums.civfanatics.com/threads/grinding-out-the-win.667370 | CivFanatics forumu | ~10-17 Şub 2021 | Düşük |
| S26 | https://steamcommunity.com/app/289070/discussions/0/282992562607266710/?l=czech | Steam Topluluğu | 2 Kas 2016 | Düşük |
| S27 | https://en.wikipedia.org/wiki/Civilization_VII | Wikipedia | güncel (19 Mayıs 2026 güncellemesini anıyor) | Orta |
| S28 | https://gamefile.news/p/civilization-vii-impressions | Game File, Stephen Totilo | 6 Şub 2025 | Orta |
| S29 | https://store.steampowered.com/app/1295660/Sid_Meiers_Civilization_VII/ | Steam mağaza sayfası (2K/Firaxis) | güncel | Düşük (satıcı); yorum oranı veridir |
| S30 | https://store.steampowered.com/app/289070/Sid_Meiers_Civilization_VI/ | Steam mağaza sayfası | güncel | Düşük (satıcı); yorum oranı veridir |
| S31 | https://store.steampowered.com/app/916440/Anno_1800/ | Steam mağaza sayfası (Ubisoft) | güncel | Düşük (satıcı); yorum oranı veridir |
| S32 | https://steamcommunity.com/app/916440/discussions/0/4343229540497289232 | Steam Topluluğu | 25 Şub - 6 Mar 2024 | Düşük |
| S33 | https://steamcommunity.com/app/916440/discussions/0/4203615689063593525 | Steam Topluluğu | 31 Oca - 12 Şub 2024 | Düşük |
| S34 | https://vaporlens.app/app/916440/anno_1800.md | VaporLens (LLM toplayıcı özet) | güncel | Düşük |
| S35 | https://en.wikipedia.org/wiki/Anno_1800 | Wikipedia | güncel | Orta |
| S36 | https://en.wikipedia.org/wiki/Capitalism_Lab | Wikipedia | güncel | Orta |
| S37 | https://www.capitalismlab.com/?p=7532 | Capitalism Lab resmî sitesi (Enlight/Trevor Chan) | güncel | Düşük (satıcı); mekanik tarifi için |
| S38 | https://www.capitalismlab.com/digital-age-dlc/technology-research/ | Capitalism Lab resmî sitesi | güncel | Düşük (satıcı); formül için |
| S39 | https://www.passion4fm.com/how-to-approach-long-term-saves-in-football-manager/ | Passion4FM | 28 Tem 2021 | Düşük-Orta (röportaj, tek oyuncu) |
| S40 | https://www.fmscout.com/q-7794-How-long-before-you-normally-ditch-your-save.html | FM Scout forumu | ~22-28 Oca 2013 | Düşük |
| S41 | https://en.wikipedia.org/wiki/Football_Manager_(series) | Wikipedia | güncel | Orta |

Not: Game Dev Tycoon'un "kısa ve tekrarlı" özeti (vaporlens.app/app/239820) açılmadı; bölüm 2.1'deki tekrar eleştirisi yalnız S3 ve S6'ya dayanır.
Açılmayan/erişilemeyen: Game Dev Tycoon ve Software Inc. Fandom wiki'leri (HTTP 402), Mad Games Tycoon 2 Wikipedia (404), Civilization V Fandom (402).
