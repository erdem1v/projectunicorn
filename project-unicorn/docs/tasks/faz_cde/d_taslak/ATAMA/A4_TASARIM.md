# A4 · Atama ve verim tasarımı

20 Ekim 2026 · Faz D, adım A4 · Kıdemli oyun tasarımcısı (Opus) · Godot koşturulmadı; oyun koduna, `strings.csv`'ye,
`data/`'ya, `project.godot`'a dokunulmadı; git'te durum değişmedi.
Girdiler: `ATAMA/A1_OYUNLAR_1.md`, `A2_OYUNLAR_2.md` (araştırma), `A3_OLCUM.md` (ölçüm), `ERDEM_KARARLAR_2026-10-20.md`,
`PRD_FAZ_D_EKIP_SPRINT.md` §2-§3, `E1/e1_kararlar.json`, `D0s_SIM.md` §0 ve inceleme notu, `M/M_KARELER.md`,
co-director skill §4-§5.

**Okuma anahtarı.** `[S1]`-`[S30]` A1'in, `[S101]`-`[S132]` A2'nin kaynakları. "A3 §x" ölçüm tablosu (20 tohum ortancası;
"R" = D0s'un önerdiği bugünkü PRD okuması, "tarif" = Erdem'in tarifi). `[GÖRÜŞ]` benim yargım, `[DEĞERLENDİREMEM]` veri
yok. **Benim kararım** = makul bir uygulayıcının çözeceği küçük karar; iki yönlü kapı, Erdem görünce değiştirebilir.
Örnek adlar ve kart sayıları M karelerinin fikstüründendir [ÇALIŞMA]. Yeni oyuncu metinleri "TR/EN onay bekliyor".

---

## 0. Tek sayfalık özet

**Önerilen düzen.** Atamayı her ekip büyüklüğünde sistem yapar ve kural Erdem'in tarifidir; oyuncu atamayı yazmaz,
okur. Kartın iki ölçüsü vardır: **büyüklük** (aşama başına puan, bugünkü gibi) ve **gereksinim** (o aşamada en az kaç
yıldız). Gereksinim yeni bir veri alanı değildir: hatların bugünkü kilit verisinden (`requires.person`) okunur (A3 §1.1).
Plan başlayınca sistem gereksinimi en yüksek karta, gereksinimi karşılayan en iyi kişileri kartın kadro tavanı kadar
koyar. Kalan kartlara plan sırasıyla, o kartı bu sprintte bitirmeye yeten en düşük yıldızlı kişiyi verir (tek kişi
yetmezse yeten en düşük ikiliyi). Artan kişiyi en geç bitecek karta yardıma gönderir. Kişi aşaması bitene kadar
kartında kalır; sprint sınırı da bunu bozmaz. PM tarafı aynıdır. Oyuncu ekranda şunları görür:
- kart yüzünde kimin yaptığı ve kimin hazırladığı ("Deniz 4★ · Ece 3★", "Selin 5★ hazırladı · hız +%30"),
- ipucunda gereksinim ve kuralın tek cümlesi,
- aşama şeridinde yük,
- kişi satırında (8 kişiden büyük ekipte aşama özetinde) boşta olan, yalnız nedeniyle.

Darboğaz satırı yalnız planın oynatmasında bir kart bu sprintte bitmiyorsa yazar: o aşamayı ve orada kalan kartları
adlandırır. Taşma yokken boştur (Erdem 26). Boşta kalmak oyuncunun optimize edeceği bir şey değildir: sistem kimseyi
boş bırakmaz, bırakırsa nedenini söyler. Oyuncunun kararı atama değil ekibin bileşimidir: kimi işe alacağı, Görevler'de
kimin Yapım ya da Test tuttuğu, plana hangi kartın gireceği. Elle atama ilk sürümde yoktur. Ölçümde atama teslimi
ancak %3 kadar oynatıyor: aranan en iyi elle atama sistemin üstüne anlamlı çıkamıyor, kötüsü en çok %3 kaybettiriyor
(A3 §2.3). Açık hatada ise durum farklı: tarifin dağılımı rastgele atamadan da çok hata bırakıyor; yani tarifle elle
atama kaliteyi düzeltebilirdi (Soru 1 ve 2). Erdem'e beş soru §4'te.

| Ekip | Ekranda | Nasıl hissettirir (A3 sayılarıyla) |
|---|---|---|
| 1 | Her kartta tek isim (kurucu); şerit ve öneri | Atama görünmez. Sıradaki kart sığmayınca bugün %26 boşta (sınırsız arz) kalıyor; benim kararım (ölçülmedi): çekilen kart başlar ve devreder (§1b) |
| 3 | Her aşamada bir kişi; tasarımcının satırında sık sık "boşta: tasarıma açık kart yok" | Kural yine görünmez; boşta yapısal (kişi-haftanın R'de %16,6'sı, tarifte %18,8'i). ⚠️ Tarifte MVP 4. haftadan 6. haftaya kayıyor, kaynaklı arzda açık hata 14,0'tan 30,8'e çıkıyor (nedeni izlenmedi) |
| 6 | Kuralın ilk göründüğü ölçek: en zor kartta en iyi iki kişi, küçük kartta 2★ | Sprint başında 2,1 kişi yeni karta geçer, sprint içinde kimse yer değiştirmez; teslim R'nin %2,4 üstünde. ⚠️ Kaynaklı arzda kaçan söz %0'dan %9,5'e |
| 12 | Kart yüzünde kim, sprint boyunca sabit; Test şeridi her sprint taşar | 4,2 kişi yeni karta geçer (R'de 8,7); teslim −%2,5, MVP 2. haftadan 4. haftaya; darboğaz satırı her sprint "Test" der (Soru 5) |
| 25 | Aşama özeti ("TEST · 11 kişi · 2 boşta"), kompakt kart, atama ipucunda | 7,0 kişi yeni karta geçer (R'de 21,1); teslim −%2,3 (kaynaklı −%4,4); kimse boşta değil |
| 50 | Aşama özeti, plan çoğu zaman PM'de | 14,0 kişi (R'de 45,9); teslim −%3,3 (kaynaklı −%7,0); boşta yalnız kadro tavanından (%3-4) |

---

## 1. Tasarım önerisi

### 1(a) Kim atar ve hangi ölçekte

**Öneri: sistem atar; her ölçekte aynı kural, ölçeğe göre geçiş yoktur.** Ölçekle yalnız gösterim değişir: 8 kişiden
sonra kişi satırının yerini aşama özeti, kartın yerini kompakt kart alır (U1, U2). Planlamayı PM'e devretmek (Karar 12)
bugünkü gibi yalnız hangi kartların gireceğidir. Atama devirde de aynı kuralla yapılır.

**Kuralın sistemde çalışması.** Atama anları bugünküyle aynıdır: sprint başı, bir aşamanın açılışı, kişinin aşaması
bitince, kâğıt cevaplanınca, ekip değişince (`sprint_system.gd:1109-1120`, `_restaff`). Her aşama satırında (Tasarım,
Geliştirme ve Düzeltme, Test) şu sıra izlenir:

1. **Gereksinim.** Kademe kartında hattın kilit verisi kullanılır: Tasarım alanı Tasarım aşamasına, Yazılım Geliştirme ve
   Düzeltme'ye, Test Test'e, Ürün PM hazırlığına gider. Veride K1'de gereksinim neredeyse yok, K2'de ★1-2, K3'te ★2-3
   (A3 §1.1). Kilidi olmayan kartlar için **benim kararım** A3'ün kabulleridir: düzeltme kartı Yazılım ★1; derinlik
   kartı hattın K3 kilidi; hesap isteği koltuk kademesinin kilidi (koltuk 20'den az K1, 100'den az K2, sonra K3).
2. **Sıra.** Gereksinimi en yüksek kart başa alınır; eşitlikte büyük kart, sonra plan sırası. Bu karta gereksinimi
   karşılayan en iyi kişiler kadro tavanı kadar gider. Kadro tavanı ⌈aşama ihtiyacı ÷ 8⌉, en az 1'dir (K4).
3. **Kalan kartlar plan sırasıyla** alınır. Her birine o aşamayı sprintte bitirmeye yeten en düşük yıldızlı kişi gider;
   tek kişi yetmiyorsa ve kadro izin veriyorsa yeten en düşük ikili. Plan sırası korunur: kalan kartları gereksinim
   sırasıyla dizmek MVP'yi 25 ve 50 kişide 2. haftadan 6. haftaya itti (A3 §2.2, `E_gsira`).
4. **Kimse boşta kalmaz.** Artan kişi, aşaması en geç bitecek uygun karta yardıma gider (kadro tavanına kadar). Sonra
   sıradaki kartı çeker (Karar 11). Uymayan iş en sondadır (Karar 2'nin koşulu).
5. **Kart bitene kadar kalır.** Kişi aşaması bitmeden başka karta geçmez; hafta ve sprint sınırı bunu bozmaz. Böylece
   ileride gelecek çok sprintlik büyük modül kendiliğinden desteklenir.
6. **PM tarafı.** Gereksinimi (Ürün kilidi) en yüksek, sonra en büyük kartı, karşılayan en iyi PM hazırlar ve bitirir.
   Kalan kartlara, hazırlığı sprint sonuna kadar bitirmeye yeten en düşük yıldızlı PM bakar; birini bitirince
   sıradakine geçer. Kartı tek PM hazırlar ve hazırlayan değişmez. Fayda hazırlayanın yıldızından gelir (Karar 8).

**Tarifin sustuğu yerler: benim kararlarım.**

| Boşluk | Karar | Gerekçe |
|---|---|---|
| "Kart bitene kadar" | Aşama bitene kadar. Kartın aşamalarını farklı roller yapar; tasarımcı kartın Test'ini bekleyemez | A3 §1.4 madde 1; ölçülen okuma bu |
| "Kalır"ın istisnaları | (1) Kâğıt bekleyen kartın ekibi geçici olarak yardıma gider, cevap gelince karta döner (bugünkü `_clear_decision` aynısını yapıyor). (2) "Sprinti durdur" ile başa alınan düzeltme kartı (`put_first`). (3) İzin, ayrılık, Görevler değişikliği (`_restaff`) | Bunlar olmadan kalır kuralı kâğıt ve acil durumla çakışır. A3 bu olayları modellemedi [DEĞERLENDİREMEM] |
| Uymayan işte kalmak | Uymayan iş "kalır"ın dışındadır: kişi her hafta başında uyan iş açılmışsa ona döner | Karar 2'nin koşulu ("uymayan iş yalnız kişi aksi hâlde boşta kalacaksa") her atama anında okunur. Tarifin "kalır"ı uymayan işi tutunca PM'in 60 haftalık moral kaybı −28'den −39'a çıkıyor (A3 §2.6). P1'i de çözer |
| Gereksinimi karşılayan kişi meşgulse | Kart, karşılayan biri boşalana kadar o aşamada bekler; bu sırada başkası girmez. Gereksinim ekibin o aşamadaki en iyisini aşıyorsa en iyiye iner | Gereksinim kalitenin koruyucusu. Kalkınca açık hata 6 / 12 / 25 kişide +5,7 / +3,0 / +3,3 artıyor, teslim değişmiyor. Gereksinim yüzünden boşta kalma %0,1'in altında (A3 §2.2, §2.4) |
| Kurucunun yıldızı | Gereksinimde kurucunun gerçek yıldızı sayılır; 2★ tabanı yalnız hızdadır | Karar 5: taban yalnız hızda ve hiçbir metinde görünmez. A3 tabanı gereksinime de uyguladı; bu farkın etkisi ölçülmedi [DEĞERLENDİREMEM], gereksinim zaten nadiren bağlıyor |
| Testçi Geliştirme yapar mı (K6) | Testçi önce Test satırına girer. Geliştirme'ye (×0,7) yalnız 4. adımda, Test'te işi kalmayınca gider; Düzeltme'ye girmez (Karar 6) | Testçinin değeri korunur: D0s'ta testçi Geliştirme'ye düzenli girince 1★'tan 5★'a kaçan hata azalması %62'den %30'a iniyordu. Karar 2'nin ×0,7'si "kimse boşta kalmaz" adımında yaşar. Bu kol ölçülmedi [DEĞERLENDİREMEM] |
| PM'in "yeten"i | Sprint sonuna kadarki hazırlık kapasitesiyle okunur (K2 A) | Haftalık okuma PM eklemeyi düşürüyordu (D0s §0 madde 2) |

**Ekranda ne değişir.**
- Kart yüzü ve ipucu PRD §3.2'deki gibidir: hazırlık satırı, ekip satırı, ipucunda aşama satırları.
- Kural cümlesi değişir: TR "En zor işe en iyi kişiler, küçük işe onu bitirmeye yeten kişi atanır." · EN "The hardest
  job gets the best people; a small job gets whoever is enough to finish it." Bu, PRD'nin "En büyük işe en iyi kişi
  atanır." cümlesinin yerini alır. TR/EN onay bekliyor.
- **Benim kararım, yeni metin:** gereksinim ipucunun aşama satırında, yalnız sıfırdan büyükse yazılır. TR "Geliştirme ·
  en az 2★: Deniz 4★ ve Ece 3★" · EN "Development · 2★ or more: Deniz 4★ and Ece 3★". Gerekçe: tarifin ikinci ölçüsü
  görünmezse oyuncu "bu kişi neden orada" diye sorar. Kuralı görünmeyen boşluğu oyuncu forumda soruyor: Startup
  Company'de boşta çalışanlar için "neyi yanlış yapıyorum" sorusuna geliştirici üç gizli koşul saydı [S16]; Software
  Inc'de boşta tasarımcının nedeni faz sırasıydı ve oyuncu bunu kendisi çözemedi [S9]; MGT'de istenmeyen otomatik
  atama şikâyeti yalnız arama özetinden [S23, Düşük]. RimWorld'de ekmeyen çiftçinin nedenini bilmeyen oyuncu "bilmediğim
  daha iyi bir yol var mı" diye soruyor [S106]. Kart yüzüne girmez (kart iki satır kalır).

**Elle atama: neden ilk sürümde yok.**
- Ölçüm, atamanın teslimde küçük bir kol olduğunu söylüyor. Sprintin kesin önizlemesini kullanan usta arama teslimi
  tarife göre ±1 puan/hf içinde tutuyor (3-25 kişi). 11 kuraldan tohum başına en iyisini seçen bile R'nin üstüne en çok
  %6 (6 kişi) çıkıyor; 25 ve 50 kişide ≤ %0,4 (A3 §2.3). Bu arama gerçek bir üst sınır değildir: yalnız tek sprinti
  görür; 1 kişide teslimi tarifin altına (4,5 → 3,5), 6 kişide açık hatayı tarifin üstüne (+2,2) itti (A3 §2.3, `out/usta`).
- Kötü atamanın bedeli **R'ye göre** var: ters atama teslimde en çok −%3, açık hatada +%16 ile +%39 (A3 §2.3).
  **Tarife göre yok:** rastgele atama teslimde tarifle aynı (50 kişide +13,9 puan/hf iyi), açık hatada 3-50 kişide
  %5-22 daha iyi (eşli −0,5 ile −3,1; 20 tohumun 13-19'unda) [A5 hesabı, `out/main`]. Yani sistem tarifi uygularsa
  elle atama "yalnız kaybettiren" bir seçenek olmaz; kaliteyi düzeltebilir. Bu, tarifin dağılımının bir bedelidir
  (Soru 2), elle atamanın bir değeri değil [GÖRÜŞ].
- Yük olmayabilir: kalır kuralıyla sprint başında yeni karara bağlanacak kişi 6 / 12 / 25 / 50 kişide 2,1 / 4,2 / 7,0 /
  14,0 (A3 §2.6). Ama ölçekte "tek tek tıklama" en net şikâyet: Two Point Campus [S25], Software Inc [S3], mikro yönetim
  yüzünden iade [S17].
- Erdem'in ilk düşüncesi (orta ekipte elle güzel olabilir) ölçümle çelişmiyor ama ölçümle de desteklenmiyor. RimWorld'de
  oyuncular elle önceliği öğrenince tercih ediyor [S106] ve 5 koloniciden azında mikro yönetim kaçınılmaz [S105]; ama
  orada elle ayar sonucu değiştiriyor (tarlayı ekmeyen çiftçi koloniyi aç bıraktı [S106]). Bizde teslimi %3'ten fazla
  değiştirmiyor; açık hatayı değiştirebiliyor (yukarıda).
- Kontrol isteyen oyuncunun bugün de bir kolu var: **Görevler matrisi** (kimin Yapım, Test, Destek tuttuğu;
  `docs/HARITA.md:145` `team`). Bu, RimWorld ve ONI'nin kişi başına kalıcı öncelik tablosunun karşılığıdır [S101][S102].
  Yeni sistem değildir.
- Bugünkü oyunda elle atama zaten yok. `_assign` haftalık bir sıralamadır (`sprint_system.gd:1120`). Sabitleme sonradan
  eklenebilir (Soru 1 B); bu kolay geri dönülen bir kapıdır.

**PM'e devir.** PM'in yıldızına göre iyi ya da kötü atayan bir PM yeni bir sistem olur ve A3 bunu modellemedi
[DEĞERLENDİREMEM]. Ölçülen aralık (rastgele ile kural arası, teslimde ±%3) PM'in atama kalitesinin teslimde
görünmeyeceğini söylüyor. FM'de devir resmi çözüm ve kalite personelin özniteliğine bağlı [S112]; ama devirden sonra gelen
sürpriz kararlar ve onay uyarıları oyuncuyu kızdırıyor [S113][S115, Düşük]. Erdem "otomatik, sağlıklı, hatasız" dedi
(QCD Atama). Devirde atama değişmez; PM'in değeri hazırlıktadır (Karar 8).

### 1(b) Boşta kalma ve verim

**Görünür mü:** evet, ama yalnız nedeniyle ve kişinin yerinde: ≤ 8 kişide kişi satırında, > 8 kişide aşama özetinde.
Ceza, skor, KPI ya da "verim yüzdesi" yoktur. Darboğaz satırında yazmaz (Erdem 26: o satır taşma içindir).

**Oyuncuya ne söylenir** (W'nin taslak metinleri; yalnız yerleri değişir, **benim kararım**):
- Kişi satırı: "Mert · boşta" (`PRODUCT_PERSON_IDLE`); ipucunda neden: "Mert boşta: geliştirmeye açık kart yok."
  (`PRODUCT_NECK_IDLE_DEV`, Tasarım ve Test eşleri).
- Aşama özeti: "TEST · 9 kişi · 2 boşta" (`PRODUCT_STAGE_SUMMARY`); ipucunda kişiler ve nedenleri.
- Kart kalmadıysa: "Planlanacak kart kalmadı: 6 kişi bu sprint boşta." (`PRODUCT_NECK_NO_CARDS`). Bu cümle darboğaz
  satırının yerinden aşama özetinin altına iner.
- Uymayan iş: "Selin testte ×0,4 hızla çalışıyor; başka işi yok. Sprint sonunda 2 moral kaybeder." (PRD §3.1). Bu,
  "kimse boşta kalmaz"ın bedelidir ve görünür.

**Oyuncunun optimizasyonu mu: hayır.**
- Sistem zaten boş bırakmıyor. PM dışındaki boşta pay 6 kişide %2,1, 12 ve 25 kişide %0,1, 50 kişide %4,0 (kadro
  tavanı). Yalnız 1 kişide (%26,4: sıradaki kart sığmıyor) ve 3 kişide (%18,8: uyan iş yok) yapısal (A3 §2.1, §2.4).
- D0s'un ölçtüğü boşta payının neredeyse tamamı PM'in kendi boş zamanıdır (A3 §0 madde 6).
- Oyunlarda boşta kalan kişi bir arıza belirtisi olarak yaşanıyor, övülen bir optimizasyon olarak değil: ONI'de orta-geç
  oyunda boşta duplikant yığını ve mikro yönetim [S110]. Nedeni görünen boşluğu oyuncu kabul ediyor [S7]; görünmeyenin
  nedenini forumda soruyor [S9] ya da şikâyet ediyor [S8].
- "Ekibi %100 dolu tut" hedefinin zararlı olduğunu söyleyen gerçek dünya kaynakları var: DeMarco [S122], Kingman'ın
  formülü [S124]. Ama bunlar bilgi işçisine analojidir [SIÇRAMA].
- 1 ve 3 kişideki boşluk atamayla kapanmaz; plan ve işe alımla kapanır. Bunun söylenmesi yeter.

**Mekanik olmalı mı: hayır** [GÖRÜŞ]. Boşta kalmanın oyuncu kararı tek kolu var, o da işe alım (hangi rol). Bunu boşta
satırının nedeni zaten söylüyor. Ayrı bir mekanik, Erdem'in "gizli gider yok" kuralına bir ceza daha ekler, karar
eklemez.

**Tek kurucu (benim kararım, ölçülecek).** Tarif "kimse boşta kalmaz" diyor. Bugün tek kurucu, sıradaki kart çekme
kuralının (Karar 11: çekilen kart alım kuralına uyar) içine sığmadığı için %26 boşta kalıyor (sınırsız arz; kaynaklı arzda
%10,9, D0s inceleme notu). Öneri: biri boşta kalacaksa çekilen kart sığmasa da başlar ve sonraki sprinte devreder; PRD'nin
metni bunu zaten yazıyor ("Sırada: Stok uyarısı. 2. haftada başlar, sonraki sprinte devreder."). Alım şartı yalnız bu
durumda gevşer. Bu kol ölçülmedi [DEĞERLENDİREMEM]: teslim düşmemeli, tek kurucunun hata sprinti ≤ %5 kalmalı (D0s kapı 6).

**PM hazırlığı yetişmeyince.** PRD Karar 8 aynen kalır: kart kısmen ya da hazırlıksız girer, kimse beklemez, fayda
orantılı küçülür. Kart yüzünde "Can 2★ kısmen hazırladı · hız +%8" (`PRODUCT_CARD_PREP_PART`) görünür ya da hazırlık
satırı hiç çizilmez. "Hazırlıksız kart Geliştirmeye giremez" okuması kesilir:
- PM yeterliyken (PM başına 6-8 kişi) iki okuma aynı sonucu veriyor.
- 23 kişi 1 PM'de kapı okuması teslimi 234'ten 110'a indiriyor (−%53) ve kişi-haftanın %58'ini boşa çıkarıyor (A3 §2.4).
- Kapı okuması PRD'nin "PM'siz ekibe ceza yoktur" hükmüyle çelişir.

**PM'in kendi boş zamanı (benim kararım).** PM'in boş zamanı aşama özetinin "boşta" sayısına girmez. Sonraki sprintin
kartları hazırsa PM'in işi bitmiştir; kapısız kollarda girişteki hazırlık oranı 0,96-1,00 (A3 §2.4). PM'in satırının
ipucu "Selin için hazırlanacak kart kalmadı." der (`PRODUCT_NECK_NO_PREP`). 6-12 kişide PM zamanının %48-56'sı boş
(A3 §2.2). Oyuncu bunu "ikinci PM'e gerek yok" diye okur; bu doğru bir okuma.

**Verim.** Yeni verim kuralı yok. Kayıp yalnız aynı kartta yaşar (Karar 3). "Tek kişinin yetmediği işe iki kişi" kadro
tavanıyla sınırlıdır; bölünmeyen işe eklenen kişinin yardım etmediğini Brooks da söylüyor [S126, ikincil].

### 1(c) Darboğaz gösterimi

- **Kaynak: planın oynatması.** Plan ekranı, öneri ve kapanış aynı oynatmayı koşar (Karar 9). Oynatmada tahmin ile sonuç
  bire bir aynı çıkıyor (A3 §4: 3.548 koşuda en büyük fark 7,1e-15). Satır bunu okur, ayrı bir eşik okumaz.
- **Ne zaman yazar:** oynatmada plan kartlarından biri bu sprintte bitmiyorsa. Tek cümle, en çok işin kaldığı aşama ve
  orada kalan kartlar: TR "Test yetişmiyor: Hesap Planı ve Stok Sayacı testte kalır." (`PRODUCT_NECK_LATE_*`). Aşamayı
  yapacak kimse yoksa "Testi yapacak kimse yok." (`PRODUCT_NECK_NOBODY_*`).
- **Söz verilmiş ya da tarihli kart kalıyorsa listede başa yazılır** (benim kararım; yeni metin gerekmez). Bu, söz
  olayının plan anındaki erken hâlidir ve oyuncunun şimdi yapabileceği bir şeyi gösterir (kart çıkarmak, söz kartını öne
  almak).
- **Ne zaman yazmaz:**
  1. Taşma yokken (Erdem 26). W'nin `PRODUCT_NECK_FITS_*` cümleleri ve M'nin 1 kişi karesindeki "her aşama yetişiyor"
     cümlesi düşer.
  2. Yalnız ekibin sonradan çektiği kart devrediyorsa; bunu "Sırada" satırı söyler.
  3. Boşta ve kart arzı cümleleri hiç; onlar §1(b)'deki yerlerine iner.
- **"Zayıf planlama" gösterimi budur.** Oyuncu "+" ile kart ekledikçe oynatma yeniden koşar. Üç test ağırlıklı kart
  eklendiyse satır o kartları adlandırır; çıkarınca satır kaybolur. Ayrı bir uyarı sistemi gerekmez.
- **Kesilen: yük ÷ kapasite oranı uyarısı** (PRD Karar 10'un "en büyük oranı yazar" cümlesi). A3 §2.5:
  - isabetli (%95-100) ama 12 kişi ve üstünde sprintlerin %100'ünde çıkıyor,
  - 3-6 kişide geç yakalıyor (eşik 1,25'te %45 ve %18),
  - uyarıya bakıp bir kart değiştirmek teslimi %0,7'den az oynatıyor.

  Oynatma bundan üstün: hep doğru ve kartın adını söylüyor.
- **Öneri yazmaz** ("testçi al" yazmaz; Karar 10 aynen).
- **Bilinen sorun.** 12 kişi ve üstünde taşan aşama sprintlerin %100'ünde Test'tir (A3 §2.5). Satır her sprint aynı
  aşamayı yazar: gerçek bir alım sinyalidir, ama duvar kâğıdına dönebilir. Bu, Erdem'in zevk kararıdır (Soru 5).

### 1(d) PRD'nin hangi kararlarının yerine geçer

| PRD | Ne olur | Neden |
|---|---|---|
| Karar 4, "İşin büyüklüğü" | Kalır, bir ekle: kartın ikinci ölçüsü gereksinimdir ve hattın kilit verisinden okunur. "Kartta ayrı bir zorluk alanı yoktur ve D eklemez" cümlesi doğru kalır | Tarif; A3 §1.1 |
| Karar 4, "Eşleme" | **Yerine tarif** (§1a 1-5). "Kişi aşama ya da hafta bitene dek kartında kalır" yerine "aşama bitene dek". Eşitlik sırası: gereksinim, büyüklük, plan sırası, kimlik | Tarif; kalır kuralı sprint içindeki yer değişimini %33-89'dan %0'a indiriyor (A3 §2.6) |
| Karar 4, "PM" ve Karar 8'in son maddesi | **Yerine tarifin PM kuralı** (§1a 6; sprint ufkuyla) | Tarif; QCD Atama |
| Karar 4, "Bonus kartta okunur", "Sağlam kural" | Aynen. Kapı "daha iyi kişi ya da PM eklemek teslimi düşürmez" tarifle yeniden ölçülür | Tarifle ölçülmedi [DEĞERLENDİREMEM] |
| Karar 4, ipucu cümlesi (§3.2) | Yeni kural cümlesi ve gereksinim satırı (§1a) | Tarifin ikinci ölçüsü görünür olmalı |
| Karar 2, atama koşulu | Aynen; uymayan iş "kalır"ın dışında | §1a tablo |
| Karar 2 tablosu ile Karar 6 (testçi) | Testçinin ×0,7 Geliştirme'si yalnız yardım adımında; Düzeltme'ye girmez | K6, §1a tablo |
| Karar 3, son madde (boş süre) | Aynen, öne bir adım eklenir: artan kişi önce en geç bitecek karta yardıma gider | Tarif ("kimse boşta kalmaz") |
| Karar 10, darboğaz cümlesi | **Yerine** oynatmadan tek cümle; taşma yokken boş; boşta cümleleri kişi satırına ve özete iner. Aşama şeridi "her zaman görünür" aynen | Erdem 26; A3 §2.5 |
| Karar 11, çekme | Aynen; tek fark: biri boşta kalacaksa çekilen kart alım şartına sığmasa da başlar ve devreder | Tarif ("kimse boşta kalmaz"); §1b |
| Karar 8, hazırlık | Aynen (bonus orantılı, iş durmaz) | A3 §2.4 |
| Karar 12, devret | Aynen; devir yalnız planlamadır, atama aynı kuralla yürür | §1a |
| Karar 5 (kurucu), 9 (tahmin = sonuç), 1, 6, 7, 13-16 | Aynen | Atama tasarımı dokunmuyor |
| §3.1 metinleri | `NECK_FITS_*` düşer; `NECK_IDLE_*`, `NECK_NO_CARDS`, `NECK_NO_PREP` yer değiştirir | Erdem 26 |

### 1(e) Oynanış merceği

| Parça | Oyuncuya verdirdiği karar | Sıklık | Angarya mı | 1 kişide | 50 kişide | Hüküm |
|---|---|---|---|---|---|---|
| Sistem ataması (tarif) | Kimi işe alayım: "bir 4★ mı, iki 2★ mı" atamada anlam kazanır; atamanın kendisi karar değil | Her planda görünür; karar işe alımda (koşuda yaklaşık 21 alım, PRD Karar 1) | Hayır: oyuncu tıklamaz | Görünmez | Aşama özeti; ipucunda okunur | **Tut** |
| Gereksinim | Hangi yıldızı alayım (K3 kartı 2★ ister) | İşe alımda | Hayır | Kilit zaten şirket düzeyinde (kart açılmadıysa görünmez) | Nadiren bağlar, kaliteyi korur | **Tut** |
| Kalır | Yok; ekranın sprint boyunca sabit kalmasını sağlar | Her hafta | Azaltır: R'de 50 kişide 45,9 kişi yer değiştiriyordu, tarifte 14,0 | Görünmez | Ekran okunur kalır | **Tut** |
| "Küçük işe yeten en düşük" (kişi) | Yok; "1★ küçük kartı yapar" hikâyesi | Her plan | Hayır | Görünmez | Teslim −%1,9; açık hata 3-25 kişide +%22 ile +%28 (A3 §2.2, tarif ataması + R'nin PM'i); 3 ve 12 kişide MVP bir sprint geç | **Tut**, ölçerek (Soru 2); demo ölçeğindeki bedel izlenmeden koda girmez (§3) |
| PM'de "küçük karta düşük yıldızlı PM" | PM yıldızının farkını görürüm: Erdem'in istediği ("iyi PM'in modifier'ı farklı görünmeli") | Her kartta | Hayır | Görünmez (PM yok ya da tek PM) | 12 / 25 / 50 kişide teslim −%2,7 / −%1,8 / −%1,1, açık hata aynı (A3 §2.2, R ataması + tarifin PM'i); oyuncunun hissedemeyeceği büyüklükte | **Tut** (Soru 4). A3 bu yarıyı kesmeyi önerdi; ben kesmiyorum, çünkü kazancı görünürlüktür ve bedeli algılanmaz [GÖRÜŞ] |
| Elle atama | Teslimde sistemi geçemeyen bir seçim; tarifle açık hatada sistemden iyi olabilir (Soru 1, 2) | Sprintte 2-14 kişi | Ölçekte evet [S25][S3] | Anlamsız | Angarya | **Kes** (ilk sürüm; Soru 1) |
| Boşta gösterimi | Hangi rolü işe alayım | Boşta biri varken | Hayır: bilgi | Yok (çekme kuralıyla) | "2 boşta" özette | **Sadeleştir**: yalnız nedenle, cezasız |
| PM hazırlığı | Kaç PM, hangi yıldız | İşe alımda | Hayır | PM yok, ceza yok | Kısmi hazırlık kartta görünür | **Tut** (PRD) |
| Darboğaz satırı | Bu kartı bu sprintte bırakayım mı; hangi rolü alayım | Her plan, taşma varsa | 12 kişi ve üstünde tekrar riski (Soru 5) | Çoğu zaman boş | Her sprint "Test" | **Sadeleştir**: oynatmadan tek cümle, oran uyarısı kesildi |

---

## 2. E1'in açık soruları: tarif ve bu tasarımla durumları

| Soru | Durum | Nasıl ya da neden |
|---|---|---|
| K1 Kartın kaç kişi alacağını ne belirler | **Çözüldü** | Kişi sayısını kadro tavanı ve "yeten" belirler. Kimin gideceğini önce gereksinim (ilk kart), sonra plan sırası belirler. K1'in A'sının tarif hâlidir: küçük kart aç kalmaz |
| K2 Birden çok PM'de kim hazırlar | **Çözüldü** | Tarifin PM kuralı, "yeten" sprint sonuna kadar okunur (K2 A). Küçük kartın düşük yıldızlı PM'e gitmesi Soru 4'te |
| K3 "Yalnız bitecek kartlar, en çok bir devreden" | **Çözüldü** | Tarif "sprint planında bütün ekip kullanılır" diyor; kalkan planı %34-57'ye boşaltıyordu (D0s §0 madde 4). Kalkar, "sprintte en çok bir talep" kalır |
| K4 Kadro dilimi 8 mi 40 mı | **Çözüldü: 8** | Tarifin örneği "4★ karta en iyi 2 geliştirici" ve "tek kişinin yetmediği işe iki kişi" diyor; 40 her aşamaya tek isim koyar, tarifle çelişir. 8 ölçülen her ekipte daha iyi (D0s §0 madde 5) |
| K5 Söz verilmiş kart atamada önce mi | **Erdem'e: Soru 3** | Tarif sözü söylemiyor; tarifle 6 kişide kaçan söz %0'dan %9,5'e çıkıyor (A3 §2.1) |
| K6 Testçi Geliştirme yapar mı | **Çözüldü (benim kararım)** | Testçi önce Test'e; ×0,7 Geliştirme'ye yalnız "kimse boşta kalmaz" adımında; Düzeltme'ye girmez. Ölçülecek (§3) |
| K7 Kurucu birden çok aşamaya uyuyorsa | **Çözüldü: sınıf önce** | Erdem'in bağlayıcı "kurucunun işi en çok %10 düşer" kararını tutan tek okuma (D0s §3.4). Kurucu büyümesi kapısı ⚠️ olarak kalır |
| P1 Uymayan işin moral bandı | **Çözüldü** | Uymayan iş "kalır"ın dışında ve her hafta yeniden okunuyor; kapı koşullu kurala göre 20-35 bandıyla okunur [onay bekliyor: kapı değeri]. Tarifin "kalır"ı uymayan işi tutsaydı −39 bandın dışında kalırdı |
| P2 "Kişi eklemek teslimi düşürmez" nasıl okunsun | **Çözüldü (benim kararım; teknik, oyuncu bir şey görmez)** | Eşli ortalama fark ± 2 standart hata; A3 bütün tablolarını böyle okudu. Kapı tarifle yeniden ölçülür (§3 Yol 1) |
| T1 Söze bağlı kart "sonraki sprinte bırak"ılırsa | **Çözüldü (benim kararım)** | Bugünkü söz kuralı: söz bir kez uzar, aynı iz (`PromiseRegistry.extend`); ikinci kez bırakılırsa kırılır. Yeni kural yok |
| T2 Testi testçi değil başkası yaptıysa gönder sorusunu kim söyler | **Çözüldü (benim kararım)** | Kalır kuralıyla kartın Test'indeki kişi bellidir. Konuşan, o kartta en çok hatayı bulan kişidir; bugünkü kâğıt konuşanı kuralı da aynı (kartın `assignees`'inden fazı uyan kişi, CLAUDE.md §6) |
| U1 12 ve 50 kişide kompakt kart | **Çözüldü (benim kararım: 8 kişiden sonra)** | Kalır kuralıyla kartın ekibi sprint boyunca sabit; ekip satırı ipucuna iner, bilgi kaybolmaz. U2 ile aynı eşik. Görsel kabulde Erdem görür |
| U2 Kişi satırından aşama özetine | **Çözüldü (benim kararım: 8 kişiden sonra)** | Boşta sayısı ve nedeni özette (§1b) |
| U3 "Planlamayı devret" nerede | **Çözüldü (benim kararım: alt şerit, maketteki gibi)** | Devir yalnız planlamadır; sprinti başlatma kararının yanında durur. Atamayla ilgisi yok |
| U4 "Sırada" dar mı uzun mu | **Çözüldü (benim kararım: dar)** | Çekilen kart devrediyorsa bunu yalnız bu satır söyler (§1c). Dar biçim tek satır |
| U5 İpucu hangi işi yazsın | **Çözüldü (benim kararım: hazırlıktan sonraki)** | Aynı kartta iki sayı olmaz; "yeten" hesabı da hazırlıktan sonraki işle yapılır |
| U6 Kadro tavanı ipucunda | **Çözüldü (benim kararım: yalnız kartı en çok kısan aşama)** | Gereksinim aşama satırlarına girdiği için ihtiyaç satırı tek satır kalmalı |
| U7 "talebi zamanında" parçası | **Çözüldü (benim kararım: kalksın)** | Başlık zaten "{hesap} talebi: {konu}" (Erdem 25: konu istek kâğıdından); tekrar |
| P3 Puan başına dolar (Erdem'in) | **Tutarlı** | Tek örnek, kâğıdın dışarıdan iş seçeneği, Erdem 24 ile kalktı (`e22a065`). `data/`, `sprint_system.gd` ve `sprint_catalog.gd`'de `per_point` yok (grep, 0 sonuç). Atama dolar okumaz |
| T3 İstek kartının adı (Erdem 25: B) | **Tutarlı** | İsteğin gereksinimi koltuk kademesinden gelir, adından bağımsız |
| T4 Taşma yokken darboğaz satırı (Erdem 26: boş) | **Tutarlı** | §1(c) bunun üstüne kurulu. Değişen iki şey: M'nin 1 kişi karesi ve W'nin `NECK_FITS_*` anahtarları düşer |
| T5 Hedef yokken başlık (Erdem 27) | **Tutarlı** | Atamayla ilgisiz |
| T6 Bilinen hatayla çıkan kart (Erdem 28) | **Tutarlı** | Kalır kuralıyla kartı kimin yaptığı bilinir, ama not kişi adı yazmaz; Erdem'in tonu aynen |

---

## 3. Pre-mortem

**Varsayım.** Tarifle atama, kalır kuralı ve oynatmadan darboğaz satırı D'de koda girdi. Haziran 2027 Next Fest demosu
(EL_KITABI önerisi) sonrası Steam yorumlarında ve kapalı playtest'te sprint planı başarısız bulundu: oyuncular atamayı
"aptal" ve "değiştirilemez" buldu, 3 kişilik erken oyunda ilk sürüm geç ve hatalı çıktı.

**Yol 1 (kanıtı vurur): ölçülen demo ölçeği bedelleri gerçek çıktı ve nedeni bilinmiyor.**
- A3'te tarif üç yerde demo ölçeğinde görünür bir bedel buldu: 3 kişide MVP 4. haftadan 6. haftaya, kaynaklı arzda açık
  hata 14,0'tan 30,8'e, 6 kişide kaçan söz %0'dan %9,5'e. Üçünün de nedeni kart kart izlenmedi (A3 §3.1, §3.4 madde 7).
- Simülasyonda kâğıt, acil durum ve söz olayı yok [DEĞERLENDİREMEM]; kalır kuralının bunlarla etkileşimi ölçülmedi.
- Mekanizma: 3 kişilik ekipte en iyi iki kişi (geliştirici ve kurucu) en zor karta kilitlenince MVP'nin küçük kartları
  aşama bitene kadar bekliyor olabilir [GÖRÜŞ, izlenmedi].
- Büyüklük: ilk sürüm bir sprint geç çıkar; 60-90 dakikalık demoda ilk 15 dakikanın en önemli anı kayar.
- **En erken uyarı:** kod adımından önce A3 betiğinde kart kart iz. Eşik: 3 kişide MVP R'den geç (> 4. hafta) ya da
  kaynaklı açık hata R'nin 1,5 katından fazla. Kod adımında `--sprint-probe` (`PRED`/`CLOSE`) adsız uyuşmazlık verirse
  ya da "kalır değişmezi" kâğıt gelen sprintte bozulursa.

**Yol 2 (aktör tepkisi): oyuncu atamayı okuyamadı ya da beğenmedi.**
- Oyuncu iki şey görür: Ece 3★ yardımcı olarak kartlar arasında gezerken Cem 1★ söz verilmiş Stok Sayacı'nı tek başına
  yapıyor; Selin 5★ boşken Can 2★ küçük kartı hazırlıyor. Bunu bozuk yapay zekâ diye okur.
- Değiştiremez (elle atama yok). Kuralı görünmeyen otomatik katmanın nedenini forumda soran oyuncular: [S16][S9]; MGT'de
  istenmeyen otomatik atama şikâyeti [S23, Düşük, yalnız arama özeti].
- **Olumsuz Steam yorumunun tek cümlesi:** "Ekibi kendisi atıyor ama en kötü geliştiricimi müşteriye söz verdiğim
  karta neden koyduğunu anlamadım, değiştiremiyorum da."
- **En erken uyarı:** Erdem'in kendi oynayışı ve kapalı playtest'te "neden X bu kartta" sorusu ya da ipucunun açılıp
  kapanması. Eşik: 5 oyuncudan 2'si atamayı yanlış bulur ya da değiştirmeye çalışır.
- **Duvar kâğıdı riski:** 12 kişi ve üstünde darboğaz satırı her sprint "Test" diyor ve okunmaz oluyor. Eşik: playtest'te
  oyuncu satırı hiç anmıyor ya da "hep aynı" diyor.

**Yol 3 (bağımlılık): gereksinimin dayandığı veri ya da sıra değişti.**
- Gereksinim hatların kilit verisinden okunuyor. Pazar 2 araştırması ve C (yıldız ölçeği 5'e, modül × koltuk teklifi)
  hatları ve kilitleri yeniden yazabilir; E'nin yeni modülleri henüz yok.
- Kod sırası Q → C → D. D'nin kod adımları beklenti tasarımının ve Erdem'in onaylarının arkasında.
- Kilitler bir yıldız sertleşince sonuç değişmiyor (A3 §2.2 `E_sert`); bu, verinin değişmesine karşı bir sağlamlık.
- **En erken uyarı:** Pazar 2 sentezinde hatların `requires.person` kilitlerine dokunan bir öneri. Eşik: kilitlerin
  ortancası bir yıldızdan fazla kayarsa A3'ün gereksinim kolu yeniden koşulur.

**En hızlı ucuz risk azaltma hamlesi** (plana girer, D'nin kod adımından önce; Sonnet, A3 betiğinde, Godot'suz, tek koşu):
1. 3 kişide MVP ve açık hata farkını ve 6 kişide kaçan sözü kart kart izle.
2. Altı kol koş:
   - söz önce (Soru 3),
   - Karar 4'ün dağılımı + gereksinim + kalır (Soru 2 B),
   - testçi yalnız yardımda Geliştirme (K6),
   - tek kurucuda sığmayan çekilen kart (§1b),
   - gereksinimde kurucunun gerçek yıldızı,
   - uymayan iş haftalık (P1).
3. "Kişi ya da PM eklemek teslimi düşürmez" kapısını tarifle ölç.

Plana girdi mi: evet, önerilir. Soru 2 ve 3'ün cevabı hangi kolun ana okuma olacağını belirler. Yol 2 için ucuz hamle:
ipucundaki kural cümlesi ve gereksinim satırı (§1a). Elle sabitleme (Soru 1 B) geri dönüşü kolay yedek yol olarak durur.

**Kabul edilen riskler.**
- Tarifin teslim bedeli 12-50 kişide −%2,3 ile −%3,3; kaynaklı arzda 50 kişide −%7,0. Oyuncunun hissedeceği büyüklükte
  değil [GÖRÜŞ]; 50 kişi EA ölçeğidir.
- 1 ve 3 kişideki yapısal boşta.

**Mercek kontrolü.**
- Oyuncu deneyimi ve Steam: Yol 2.
- Kapsam ve zaman: Yol 3. Tasarım yeni sistem eklemiyor; tek yeni oyuncu metni gereksinim satırı ve kural cümlesi.
- Teknik: Yol 1 (kalır ile kâğıt ve acil durum). Kayıt: kartın `assignees`'i bugün de kartta (`sprint_system.gd:1124`);
  kalır bir sonraki atamada onu okur. Şema gerekip gerekmediğini D0t haritası kod adımında gösterir [DEĞERLENDİREMEM].
- Pazar: risk değil. Atama oyunun kancası değil, okunur olması yeter.
- Maliyet: ucuz hamle tek bir Sonnet koşusu (A3'ün 140 dakikasından kısa, aynı betik); Erdem'in saati yalnız beş soru.

---

## 4. ERDEM'E KARAR SORULARI

En önemlisi başta. Sayılar A3'ün ölçümünden; örnek adlar maket fikstüründen.

**Soru 1. Oyuncu bir çalışanı elle bir karta koyabilsin mi?**

*Oyuncunun ekranında:* 12 kişilik ekip, Sprint 14'ün planı. Sistem Hesap Planı'na (geliştirme en az 2★) Deniz 4★ ile Ece
3★'ı, Stok Sayacı'na tek başına bitirebilen Cem 1★'i koydu. Oyuncu Ece'yi Stok Sayacı'nda görmek istiyor. Bugün de bu
tasarımda da yapamaz; kolu yalnız işe alım ve Görevler matrisi.

- **A) Yalnız sistem atar.**
  - Oyuncu: atamayı kart yüzünde ve ipucunda okur, değiştiremez.
  - Ölçüm: elle atama teslimi sistemin üstüne anlamlı çıkaramıyor (±1 puan/hf); en kötüsü (ters atama) bugünkü PRD
    kuralına göre teslimde en çok −%3, açık hatada +%16 ile +%39. Ama sistem senin tarifinle atarsa, rastgele atama bile
    tariften %5-22 daha az açık hata bırakıyor (Soru 2 A seçilirse oyuncunun düzeltebileceği bir şey var demek).
  - Bedel: ek iş yok. Geri dönüş: kolay (B sonradan eklenir).
- **B) Sistem atar, oyuncu isterse bir kişiyi bir karta sabitler.** Kişi aşama bitene kadar orada kalır, gerisini kural
  dağıtır. MGT2'deki oda kilidine benzer; orada kilidi geliştirici anlatınca soran oyuncu teşekkür etti ve ayrıca
  çalışanların ne kadar gezeceğini ayarlayan bir kaydırıcı istedi [S21]. Senin "orta ekipte elle atama güzel olabilir"
  düşüncen bu seçenekte yaşar: küçük ve orta ekipte isteyen sabitler, büyük ekipte dokunmaz; ayrı bir ölçek eşiği
  gerekmez.
  - Oyuncu: "Ece'yi Stok Sayacı'na kilitledim." Teslim değişmez; tarifle küçük kartın hatası azalabilir; tercih onundur;
    plan tahmini sabitlemeyi de oynatır.
  - Bedel: kartın ekip satırına tıklanır bir yer, kayıtta yeni bir alan, görsel kabul. D'nin bir arayüz adımı kadar
    [süre ölçülmedi].
  - Geri dönüş: kolay.
- **C) Planlamayı devralan PM atamayı da yapsın; PM'in yıldızı atamanın ne kadar iyi olduğunu belirlesin.** Football
  Manager'ın sorumluluk ekranı gibi [S112].
  - Oyuncu: "Selin 5★ planlarken herkes yerinde; Can 2★ planlarken Cem zor karta düşüyor."
  - Bedel: yeni sistem; A3 bunu modellemedi. Ölçülen aralığa göre fark teslimde görünmez (±%3), açık hatada görünür.
  - Geri dönüş: orta; PM'in değeri bunun üstüne kurulursa sökmek zorlaşır.

**Soru 2. Kalan kartlara "onu bitirmeye yeten en düşük yıldızlı kişi" mi gitsin?**

*Oyuncunun ekranında:* aynı 12 kişilik ekip. En zor karta en iyiler gittikten sonra Toplu Fatura'yı Kaan 2★, Stok
Sayacı'nı Cem 1★ tek başına yapıyor. Ece 3★ ise yardımcı olarak en geç bitecek karta gidiyor. Bu dağılımda iyi yıldızlar
bir kartta toplanır, küçük kartlar zayıf ellerde kalır.

- **A) Tarif aynen.**
  - Oyuncu: "1★ küçük kartı yapar" hikâyesi açık okunur; o kartlardan daha çok hata çıkar.
  - Ölçüm (yalnız bu yarı, R'nin PM kuralıyla, R'ye göre): açık hata 3-25 kişide %22-28 fazla (50 kişide %6); 3 kişide
    MVP 4. haftadan 6. haftaya, 12 kişide 2. haftadan 4. haftaya; teslim 6-12 kişide R'den biraz iyi (+1,1 / +0,7
    puan/hf), 50 kişide −%1,9. Tam tarif, kişileri kartlara rastgele dağıtmaktan da %5-22 daha çok açık hata bırakıyor
    (3-50 kişi) [A5 hesabı]. Nedeni izlenmedi.
  - Bedel: yok. Geri dönüş: kolay (kural tek yerde).
- **B) En zor karta en iyiler (gereksinim ve "bitene kadar kalır" korunur); kalan kartlar büyükten küçüğe, sıradaki en
  iyi kişiye.** Bu bugünkü PRD'nin dağıtım sırasıdır.
  - Oyuncu: Ece Toplu Fatura'yı, Kaan Stok Sayacı'nı, Cem en küçük kartı yapar. Küçük işe yine az yıldızlı kişi düşer,
    ama yardımcı gezen kişi olmaz.
  - Ölçüm: bu bileşim tam olarak koşulmadı [DEĞERLENDİREMEM]. En yakın ölçülen kural (bugünkü PRD'nin dağıtımı; ama kişi
    her hafta yeniden dağıtılıyor ve gereksinim yok) açık hatada A'dan 3-25 kişide %18-22 az, MVP'de 3 ve 12 kişide A'dan
    bir sprint erken.
  - Bedel: kod öncesi bir ölçüm koşusu (§3). Geri dönüş: kolay.

**Soru 3. Müşteriye söz verilmiş kart en iyi kişileri önce mi alsın?**

*Oyuncunun ekranında:* 6 kişilik ekip, Ege Sigorta'ya bu sprint için söz verilmiş Toplu Fatura planda. Ama en yüksek
gereksinimli kart Hesap Planı, en iyi iki geliştirici oraya gidiyor; Toplu Fatura'ya yeten en düşük kişi düşüyor. Ölçümde
bu ekipte vadesi gelen sözlerin %9,5'i kaçıyor (R'de %0). Söz kaçınca hesap izi taşır ve saati durduran söz olayı gelir.

- **A) Söz verilmiş ve tarihli kart sıranın başına geçsin**, en zor karttan da önce.
  - Oyuncu: söz verdiği kartta en iyi kişileri görür; söz olayı seyrekleşir.
  - Bedel: zor kart biraz yavaşlayabilir. Bugünkü PRD kuralıyla yapılan ölçümde "söz önce" büyük kartın süresini
    değiştirmedi (12-50 kişide 4,0 hafta); senin tarifinle ölçülmedi [DEĞERLENDİREMEM].
  - Geri dönüş: kolay.
- **B) Tarif aynen:** söz kartı kalan kartlar arasında plan sırasıyla ilk gelir ve ona yeten en düşük kişi gider.
  - Oyuncu: sözün kaçma riski plan anında darboğaz satırında görünür (söz kartı listenin başında, §1c), oyuncu
    isterse başka kartı çıkarır.
  - Bedel: yok. Geri dönüş: kolay.

**Soru 4. Küçük kartları daha az yıldızlı PM mi hazırlasın?**

*Oyuncunun ekranında:* 25 kişi, 3 PM. Selin 5★ en zor kartı hazırlıyor ("Selin 5★ hazırladı · hız +%30"); küçük kartları
Can 2★ hazırlıyor ("Can 2★ hazırladı · hız +%15"). Selin'in bu sprint zamanının bir kısmı boş kalıyor; 25-50 kişide PM
zamanının %20-21'i (tarifle; bugünkü kuralla %23-26) kullanılmıyor.

- **A) Tarif aynen.**
  - Oyuncu: iyi PM ile zayıf PM'in farkını kart kart görür (senin 18 Ekim'deki isteğin).
  - Ölçüm: teslim 12 / 25 / 50 kişide −%2,7 / −%1,8 / −%1,1 (R'nin atamasına tarifin PM'ini koyan kol: −2,9 / −4,8 /
    −5,5 puan/hf). Açık hata değişmiyor.
  - Bedel: yok. Geri dönüş: kolay.
- **B) Yalnız tarifin ilk cümlesi:** zor karta en iyi PM; kalan kartları boşta olan en iyi PM sırayla hazırlar, Can
  yalnız Selin'in yetişemediğini alır.
  - Oyuncu: kartların çoğunda "Selin 5★" yazar, Can'ın satırı seyrek görünür; zayıf PM'in farkı daha az görünür.
  - Ölçüm: teslim R'ye eşit.
  - Bedel: yok. Geri dönüş: kolay.

**Soru 5. Test her sprintte yetişmiyorsa darboğaz satırı her sprintte aynı cümleyi mi yazsın?**

*Oyuncunun ekranında:* 12 kişilik ekip, 2 testçi. Plan bilerek kapasitenin biraz üstünde doldurulduğu için ölçümde 12
kişi ve üstünde her sprintin sonunda Test'te iş kalıyor. Satır her sprint "Test yetişmiyor: Hesap Planı ve Stok Sayacı
testte kalır." diyor.

- **A) Her sprint aynı cümle, o sprintin kartlarıyla.**
  - Oyuncu: hep doğru bilgi alır; tekrar ettikçe "testçi lazım" diye okur ya da okumaz olur.
  - Bedel: yok. Geri dönüş: kolay.
- **B) Üst üste ikinci sprintten itibaren sayıyla:** "3 sprinttir test yetişmiyor: …".
  - Oyuncu: tekrarın kendisi bilgi olur, bir alım sinyali gibi okunur.
  - Bedel: bir yeni metin ve son sprintlerin taşan aşamasını okuyan küçük bir sayaç (sürüm kaydından türetilebilir).
  - Geri dönüş: kolay.
- **C) Cümle yalnız söz verilmiş ya da tarihli kart taşıyorsa yazsın;** öbür taşmayı aşama şeridi zaten "6 puan sonraki
  sprinte kalır" diye gösteriyor.
  - Oyuncu: satır seyrek ama hep önemli olur; "zayıf planlama" uyarısı yalnız müşteriyi etkileyen durumda gelir.
  - Bedel: yok. Geri dönüş: kolay.

*Terimler:* **kadro tavanı**, bir kartın bir aşamasına girebilecek en çok kişi (aşama işi ÷ 8, en az 1). **Oynatma**, plan
ekranının sprinti iki hafta önceden oynatıp sonucu göstermesi; tahmin sonuçla aynı çıkar. **Kaynaklı arz**, kartların
oyundaki gibi hat, derinlik ve müşteri isteğinden geldiği ölçüm; sınırsız arzda kart hiç bitmez.

---

## 5. Ne yapmıyoruz

- **Elle atama temel mekanik değil.** Her kartın kişilerini oyuncu seçmez. Ölçek angaryası [S25][S3][S17] ve ölçümde
  teslim kazancı yok (A3 §2.3); açık hata kazancı yalnız tarifin dağılımına karşı var (Soru 2). Soru 1 B seçilirse yalnız isteğe bağlı sabitleme gelir.
- **Ölçeğe göre "kim atar" geçişi yok.** "Küçük ekipte elle, büyükte sistem" gibi bir eşik kuralı kurulmaz; kural 1 ile 50
  kişide aynı (Karar 4 "sağlam kural"). Ölçekle yalnız gösterim değişir.
- **PM'in yıldızına bağlı atama kalitesi yok** (Soru 1 C seçilmezse). PM'in değeri hazırlıkta kalır.
- **Boşta kalmaya ceza, skor, KPI yok.** Boşta yalnız nedeniyle görünür; "kimseyi boşta bırakma" oyuncu görevi değildir.
- **Hazırlıksız kartı durduran PM kapısı yok.** PM sayısı üretim tavanı olmaz.
- **Yük ÷ kapasite oranıyla darboğaz uyarısı yok.** Eşik okuması kesildi; satır oynatmadan gelir. Satır öneri yazmaz
  ("testçi al" yok).
- **Kartta yeni zorluk alanı yok.** Gereksinim hattın kilit verisinden ve kilitsiz kartlar için üç kuraldan okunur.
- **Şirket çapında yeni verim kaybı yok.** Kayıp yalnız aynı kartta kalır (Karar 3).
- **"Taşma yok" cümlesi yok.** `NECK_FITS_*` düşer (Erdem 26).
- **Seçilmeyen yolların bıraktığı:**
  - Elle atamayı seçen oyuncunun sahiplik duygusu (Soru 1 A seçilirse).
  - Tarifin "yeten en düşük" yarısının hata maliyeti (Soru 2 A seçilirse açık hata 3-25 kişide %22-28 fazla) ya da hikâyesinin
    keskinliği (B seçilirse).
  - Darboğaz satırının her sprintteki kesin bilgisi ya da sessizliği (Soru 5).

---

## İnceleme notu (Opus)

20 Ekim 2026 · Faz D, adım A5 · tek tur, düzeltme hakkıyla. Godot koşturulmadı; oyun koduna, `strings.csv`'ye, `data/`'ya,
`project.godot`'a ve git'e dokunulmadı. Yazılan yalnız bu belge ve `A3_OLCUM.md` §0 madde 4.

**Ne denetlendi.**
1. Yük taşıyan 12 kaynak iddiası A1/A2 siciline karşı; 6 sayfa WebFetch ile açıldı: S21 (MGT2 kilit), S16 (Startup
   Company boşta yönetici), S106 ve S105 (RimWorld), S9 (Software Inc boşta tasarımcı), S112 (FM devir).
2. A3'ün tasarımda kullanılan 15 sayısı ham çıktıdan (`dsim/v3/atama/out/{main,pr,usta}/*.pkl`) yeniden hesaplandı
   (`python -I`, betik incelemenin scratchpad'inde; `a3tab.py` içe alınmadı, formüller ayrıca yazıldı).
3. Tarifin kodlanışı `a3core.py` okumasıyla: `req_raw`, `creq`, `eligible`, `_alloc_erdem`, `_reseat`, `_pm_owners`,
   `_master` (usta arama).
4. §4'ün beş sorusu ve §1-§5'te yeni sistem eklenip eklenmediği.

**Doğru bulunanlar.**
- Kaynakların hepsi sicilde ve URL'li. Doğrulananlar: "5 koloniciden azında mikro yönetim kaçınılmaz" (S105, tek bir
  yanıt), ekmeyen çiftçi yüzünden açlık (S106, ilk ileti), "manuel ekranı otomatikten çok kullanırsın" (S106, tek
  yanıt), FM'de devir ve personeli "en uygun özniteliklerle" seçme (S112; yayıncının kendi sitesi, topluluk yazarı; tek
  başına yük taşımıyor, S113 ile birlikte).
- Tasarımın omurgası (sistem atar, elle atama yok, PM kapısı yok, darboğaz oynatmadan) kaynaklara değil A3'ün
  simülasyonuna yaslanıyor; kaynaklar yalnız oyuncu tepkisini çerçeveliyor. Omurga tek bir modele (dsim3 + a3core)
  bağlı: model yanlışsa sonuç da yanlış (A3 §5'teki sınırlar geçerli).
- Yeniden hesaplanan sayıların hepsi A3 ve A4 ile uyuşuyor: teslim tarif − R 12 / 25 / 50 kişide −%2,48 / −%2,31 /
  −%3,31; kaynaklı arzda −%4,36 / −%6,98; kaynaklı açık hata 3 kişide 14,0 → 30,75; kaçan söz 6 kişide %0 → %9,5; MVP
  3 kişide 4 → 6, 12 kişide 2 → 4; PM hariç boşta 26,4 / 18,8 / 2,1 / 0,1 / 0,1 / 4,0 (tarif); sprint başı karar 2,07 /
  4,17 / 7,02 / 14,00 (R 3,41 / 8,72 / 21,14 / 45,77); 23 kişi 1 PM kapısı 234 → 110, PM hariç boşta %58,2; tarifin PM'i
  12 / 25 / 50 kişide −%2,66 / −%1,82 / −%1,08; tarifin ataması + R'nin PM'i açık hatada 3-25 kişide +%22-28, 50 kişide
  +%6; ters atama R'ye göre teslimde en çok −%3,1, açık hatada +%16-39.
- Kodlama tarife uyuyor: gereksinim hattın `requires.person` kapısından, ekibin en iyisine kırpılarak (`creq`); en
  yüksek gereksinimli (eşitlikte en büyük) karta o gereksinimi karşılayan en hızlı kişiler kadro tavanı kadar
  (`_alloc_erdem` 1. adım); kalan kartlar plan sırasıyla, tek başına yeten en düşük hızlı kişi, yoksa toplamı en düşük
  yeten ikili (2. adım; ikili döngüsü doğru); artanlar kalan işi en geç bitecek karta, uymayan iş en son (3. adım);
  kalır hafta başında `_reseat` ile, aşama değişince kırılır; PM'de ilk kart en iyi PM'e, kalanlar sprint ufkunda yeten
  en düşük yıldızlıya (`_pm_owners`; `pm_order` yıldıza göre azalan, `dsim3.py:224`).
- Sorular: beşi de "Oyuncunun ekranında" örneğiyle başlıyor, 8 sınırının altında, soru içinde "önerim" etiketi yok,
  Erdem'in verdiği bir kararı (ERDEM_KARARLAR 1-30) yeniden sormuyor. Soru 2 ve 4 tarifin bir parçasını yeniden tartıya
  koyuyor; tarif belgede "araştırılacak" diye geçtiği ve ölçüm bir bedel bulduğu için bu meşru.
- Basitlik: tasarım yeni veri alanı ve yeni sistem eklemiyor. Eklediği kurallar (kalır'ın üç istisnası, uymayan işin
  haftalık okunması, tek kurucuda sığmayan çekilen kart) tarifin kendi cümlelerinin uygulanışı; gerekçeleri yazılı.
  Yeni oyuncu metni iki: kural cümlesi ve gereksinim satırı.

**Hatalar ve düzeltmeler (eski → yeni).**
1. *Elle atamanın "yalnız kaybettiren" olduğu (§0, §1a, §1e, Soru 1, §5).* Kötü atamanın bedeli (−%3 teslim, +%16-39
   hata) R'ye göre ölçülmüştü; sistem tarifi uygularsa karşılaştırma tarife yapılmalı. Ham çıktıdan: rastgele atama
   tarife göre teslimde aynı, açık hatada 3 / 6 / 12 / 25 / 50 kişide −1,45 / −0,53 / −1,50 / −3,08 / −2,12 (20 tohumun
   15 / 13 / 15 / 19 / 18'inde daha az hata), yani %5-22 daha iyi; ters atama tarifle aynı. "Elle atama bu modelde
   yalnız kaybettiren bir seçenek olur: en iyi hâli sistemin yaptığıdır" → "R'ye göre bedeli var, tarife göre yok;
   tarifle elle atama kaliteyi düzeltebilir; bu tarifin dağılımının bedelidir". Soru 1 A ve Soru 2 A'nın ölçüm satırı
   buna göre tamamlandı. A3 §0 madde 4'e aynı not eklendi.
2. *Usta aramanın üst sınır sayılması (§1a).* Arama yalnız tek sprinti görüyor (`_master`, sprint içi puan) ve kişi
   başına kimlik sırasıyla işleyen bir tercih listesinde arıyor; 1 kişide teslimi tarifin altına (4,5 → 3,5), 6 kişide
   açık hatayı tarifin üstüne (+2,25 ± 0,31, 20 tohumun 20'sinde) itti, rastgele atama ondan az hata bıraktı. Yani zayıf
   bir arama; gerçek üst sınır bilinmiyor. "İyi elle atamanın bir karar olmadığını söylüyor" → "atamanın teslimde küçük
   bir kol olduğunu söylüyor" + aramanın sınırı yazıldı.
3. *[S16][S9][S23] "oyuncunun hata sandığı üç oyun" (§1a, Yol 2) ve [S9] "hata sanıyor" (§1b).* Sayfalar: S16'da oyuncu
   "neyi yanlış yapıyorum" diye soruyor, hata demiyor; S9'da oyuncu "ne oluyor" diye soruyor, hata demiyor ve konu
   devredilen katman değil faz sırası; S23 yalnız arama özeti (Düşük). → "kuralı görünmeyen boşluğun nedenini forumda
   soruyor", S23 Düşük işaretiyle.
4. *[S106] "RimWorld'de gizli mantık aynı sorunu doğuruyor".* Sayfada bu açık değil; oyuncu "bir nedenle ekmedi" ve
   "bilmediğim daha iyi bir yol var mı" diyor. → bu cümleye indirildi.
5. *[S21] "oyuncular orada kilidi olumlu karşılamış" (Soru 1 B).* Sayfada tek oyuncu "I missed this, thanks!" diyor ve
   aynı oyuncu bir hareket kaydırıcısı istiyor; geliştirici kaydırıcıya cevap vermemiş. → "soran oyuncu teşekkür etti ve
   ayrıca kaydırıcı istedi".
6. *Soru 1'de Erdem'in kendi düşüncesi seçeneklerde yoktu.* Araştırma sorusu "ekip büyüklüğüne göre değişebilir mi"
   diyordu; §5 ölçek eşiğini kendi kararıyla kesmiş, Soru 1 bu yolu hiç anmıyordu. → B seçeneğine "orta ekipte elle"
   düşüncesinin isteğe bağlı sabitlemede yaşadığı ve ayrı eşik gerekmediği eklendi.
7. *Küçük düzeltmeler.* §0 tablo, 1 kişi: "önerim:" → "benim kararım (ölçülmedi):". §0 tablo, 3 kişi: "tarifte de R'de
   de aynı" → "R'de %16,6, tarifte %18,8". Soru 2 B: "PRD Karar 4'ün sırası", "R, kalırsız ve gereksinimsiz" → sade
   anlatım. Soru 3 A: "R'de ... (D0s §8)" → "bugünkü PRD kuralıyla yapılan ölçümde ... 12-50 kişide 4,0 hafta" (D0s §8,
   satır 283 ile doğrulandı). Soru 4: "%20-26" → "%20-21 (tarifle; bugünkü kuralla %23-26)".

**Değiştirilmeyen ama Erdem'in bilmesi gerekenler.**
- **Tarif bu ölçümde bugünkü PRD kuralından hem daha karmaşık hem daha kötü sonuç veriyor:** açık hata her ölçekte %15-37
  fazla, 12-50 kişide teslim %2-3 az, ve kişileri rastgele dağıtmaktan da çok hata. "Olabildiğince basit tut" kuralına
  göre Soru 2 bu tasarımın en önemli kararı; Soru 2 B koşulmadan koda girilmemeli (§3'ün ucuz hamlesi bunu zaten istiyor).
- Hata farkının nedeni ("iyiler bir karta toplanıyor") A3'te de burada da bir açıklama; kart kart izlenmedi.
- Kodlamada iki okuma tarifin cümlesinden biraz ayrılıyor, ikisi de makul: (a) "kart bitene kadar kalır" yalnız en zor
  kartın kişilerine değil herkese uygulandı; (b) "en düşük beceri" yıldızla değil o satırdaki hızla okundu (hız yıldızdan
  ve kişinin o işe uyumundan gelir); bu yüzden ikincil alanında çalışan yüksek yıldızlı biri "düşük" sayılabilir.
- A1 §0 madde 4 ve §5 madde 2'deki "[S9] bug mı / bug sanıldı" ifadesi de aynı abartıyı taşıyor; A1'e dokunulmadı.
- Simülasyonda kâğıt, acil durum ve söz olayı yok; darboğaz satırının "%100 doğru" olması modelin sonucudur, oyunda
  doğrulanması kod adımının işidir (§3 Yol 1).
