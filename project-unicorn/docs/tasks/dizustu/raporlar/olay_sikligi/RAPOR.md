# Olay sıklığı: kural mı, motorun çıktısı mı?

Karar kâğıdının sıklığı için araştırma raporu · 2026-10-28

Etiketler: [S#] kaynak (sicil §6'da). (varsayım) kaynağı olmayan ya da hesapla çıkan bilgi. [GÖRÜŞ] benim yargım.
[DEĞERLENDİREMEM] kanıtın yetmediği yer. S1–S63 dış kaynaklardır, S64–S74 bizim kod ve belgelerimizdir.

---

## 1. Kısa cevap

Sıklığı sabit bir kuralla yazmanı önermiyorum. Sıklık motorun mekanizmasından çıksın ve ölçülsün. İncelenen 20'den fazla
oyunun hiçbiri "turların %X'i" diye bir kural koymuyor [S1–S4, S18–S20, S33, S43, S47]. Hepsi aynı katmanları kuruyor:
olayın sorulduğu bir yuva (nabız, harita düğümü, hafta), bir zar ya da "olay yok" ağırlığı, duruma bağlı uygunluk, kart
başına bekleme ve tekrar sınırı, olaylar arasında asgari aralık. Sonra çıkan sıklığı ölçüp elle düzeltiyorlar
[S20, S22, S50]. Paradox bile EU4'teki "ortalama şu kadar sürede bir" (MTTH) yönteminden vazgeçti, çünkü yazılan sayı
gerçek sıklığı anlatmıyordu [S1, S3]. Bizim motor bu katmanların çoğuna zaten sahip [S64–S68]. Bugünkü cümle
("sprintlerin en az üçte biri kâğıtsız") hiçbir şeyi sınamıyor. Kâğıtsız sprint bugün %90 civarında, yani cümle hep
tutuyor [S70, S71]. "%7–10"u kural yapmak da yanlış olur, çünkü o sayı bir hedef değil, bugünkü ölçümün sonucu. Önerim
şu: cümle mekanizmayı anlatsın, ölçülen sıklık da tarihiyle birlikte ölçüm olarak yazılsın. Asıl dikkat sayıdan çok iki
şeye gitmeli. Birincisi, 1 haftada kapanan sprint zar hiç görmüyor. İkincisi, gelen kâğıtların çoğu tek rolden,
yazılımcıdan geliyor [S66, S70, S71]. [GÖRÜŞ]

---

## 2. Olay motorları sıklığı nasıl kuruyor

Altı mekanizma ailesi var. Oyunlar bunları üst üste koyuyor. Sıklık tek bir sayıdan değil, katmanların toplamından çıkıyor.

### 2.1 Yuva: olay ne zaman sorulur

Kaba sıklığı yuvanın kendisi belirler.

- **Crusader Kings III:** Olaylar kendiliğinden ateşlenmez. Nabızlar her 3 ayda, her yıl, 3 yılda ve 5 yılda bir
  sorar [S2]. Geliştirici bütün olayları "on_action" kancalarıyla ateşlediklerini söylüyor [S6]. Nabızlar herkes için
  aynı anda koşmaz, takılmayı önlemek için zamana yayılır [S15].
- **Game Dev Tycoon:** Rastgele olay varsayılan olarak "36 + 48 × rastgele" haftada bir gelir. Bu 36–84 hafta arası,
  ortalama yaklaşık 60 hafta eder [S33]. Bizim 2 haftalık sprintimizle bu, 18–42 sprintte bir demek (hesap, [S33]).
- **FTL:** Her atlama bir olaydır. Sektör başına 19–24 işaret var [S56]. Olay tiplerine sektör başına alt ve üst sayı
  verilir, motor bu aralıktan çeker [S55].
- **Slay the Spire:** Olay yalnız "?" düğümlerinde çıkar. Düğümlerin yaklaşık %22'si "?" düğümüdür [S45].
- **Darkest Dungeon:** Takım her seferden döndüğünde bir kasaba olayı çekilir. Wiki bunu "bir olay kartı destesi gibi"
  diye anlatır [S24].

### 2.2 Zar ve "olay yok" ağırlığı

Yuvaya bir zar eklenir. Çoğu oyunda "hiçbir şey olmasın" da çekilişte bir seçenektir.

- **Crusader Kings III:** Önce yüzde kapısı (`chance_to_happen`, örnekte 25) gelir. Sonra "olay yok" şansı, sonra
  ağırlıklı çekiliş. Çekilişte "100 = 0" satırı açıkça "olay yok" yuvasıdır [S2]. Forumdaki örnekte katmanlar çarpılınca
  olay şansı %6,25'e iniyor [S15].
- **Victoria 3:** Ağırlıklı listede "0" satırı "olay yok" demek. 10/5/5 ağırlıkta hiçbir şeyin olmama şansı %50 [S14].
- **RimWorld, Randy:** Günde 60 kontrol yapılır. Olaylar arası ortalama 1,35 gün. Büyük tehdidin ağırlığı toplam
  9,22'nin 1,4'ü [S19].
- **Darkest Dungeon:** "Her zaman bir kasaba olayı olmaz" [S24].
- **Uyarı örneği, EU4 MTTH:** Olay her ay belli bir ihtimalle ateşlenir, garanti yoktur. Wiki'ye göre 3 aylık MTTH
  gerçekte ortalama 6–7 ayda bir ateşliyor [S1]. Forumdaki eski bir rehber "MTTH o süre içinde ateşler" yanılgısını
  düzeltiyor [S17]. Stellaris wiki'si MTTH'nin artık kullanılmadığını yazıyor. Yerine rastgele gecikme geliyor: 200 gün
  + 0–100 gün [S3].

### 2.3 Uygunluk: olay kime ve hangi durumda uygun

Hangi olayın uygun olduğunu oyunun durumu seçer. Bu katman sıklığı en çok değiştiren katmandır.

- **Slay the Spire:** Olaylar koşula bağlı. Cleric için en az 35 altın, Knowing Skull için en az 13 HP, Moai Head için
  HP en çok %50, N'loth için en az 2 relic gerekir [S44].
- **Fallen London:** Kartları oyuncunun "quality" değerleri ve konumu açar. Örneğin Troubled Waters 7'ye gelince yeni
  kartlar desteye girer [S47]. Emily Short storylet modelini aynı şekilde anlatıyor: önkoşul, içeriğin ne zaman
  oynanacağını belirler [S49].
- **Out of the Park Baseball:** Hikâyeler çok geniş ya da çok dar koşullara bağlanır ve birbirine zincirlenir. Oyuncunun
  tek ayarı hikâyeleri açıp kapatmak [S34].
- **Victoria 3:** Geliştiriciler rastgele olayları yasa çıkarma, devrim saati ve aktif günlük girdisine bağladı [S8].
  1.3'te 40 yeni olay geldi, çoğu bağlama bağlı [S10]. Olayların çok azı açılır pencere olarak gelir [S9].
- **Reigns:** Geliştirici şöyle anlatıyor: "Each card has a certain probability to be drawn the next turn. That
  probability is evolving with the game state." [S51]
- **Stellaris, Situations:** Uzun krizlerde ayda bir ilerleyen bir sayaç var. Açık durumunda sayaç %25'te başlar,
  %75'te uyarı olayı, %100'de iflas gelir. Olaylar zarla değil eşikle gelir [S5].
- **Left 4 Dead:** Durum sıklığı değiştirir, zorluğu değil. Valve'ın cümlesi: "Amplitude (difficulty) is not changed,
  frequency (pacing) is." [S22]

### 2.4 Tekrar frenleri: aynı olay ne zaman dönebilir

- **Crusader Kings III:** Olay başına bekleme, örnekte 5 yıl [S2].
- **Victoria 3:** Olay başına bekleme, örnekte 3 yıl [S4].
- **Game Dev Tycoon:** `maxTriggers` olayın kaç kez gelebileceğini sınırlar, örnekte 1 [S33].
- **EU4:** `fire_only_once` olayı bütün oyunda bir kez ateşler. Wiki'de ayrı bir bekleme alanı yok [S1].
- **Slay the Spire:** Act olayları koşuda bir kez, shrine'lar Act başına bir kez gelir [S44].
- **Left 4 Dead:** Boss olayları deste gibidir: Tank, Witch ve "Hiçbiri" karıştırılır. Aynı boss art arda gelmez [S22].
- **Fallen London:** Elde aynı karttan iki tane olmaz. "High Urgency" kartlar her zaman önce çekilir [S47].
- **Darkest Dungeon:** Bazı olaylar belli haftaya bağlı ve bir kerelik: 3. hafta, 5. hafta, 7–10. hafta arası [S24].

### 2.5 Aralık korkulukları: asgari ve azami boşluk

Bu aile hem "art arda çok gelmesin" hem de "çok uzun sessizlik olmasın" sorusunu çözer.

- **RimWorld, Cassandra:** 4,6 gün açık, 6 gün kapalı. İlk açık evre 11. günde başlar. Her açık evrede 1 ya da 2 büyük
  tehdit gelir, aralarında en az 1,9 gün olur. Sonuç yılda yaklaşık 8,5 büyük tehdit (RimWorld yılı 60 gün) [S18].
- **RimWorld, Randy (azami aralık):** 13 gün büyük tehdit gelmezse sıradaki olay büyük tehdit olur [S19].
- **Left 4 Dead:** Tepeden sonra 3–5 saniye tam baskı sürer. Sonra 30–45 saniye dinlenme gelir, bu sırada yeni düşman
  yok. Normal zorlukta düşman dalgası 90–180 saniye arasında rastgele gelir [S22].
- **Slay the Spire (rampa):** "?" odasında gelmeyen türün şansı her seferinde artar, gelince tabana döner [S43, S44].
  Kesin yüzdeleri doğrulayamadım (varsayım).
- **The Banner Saga 2 (kota):** 9. bölümde 5 olaydan 3'ü, 10. bölümde 9 olaydan 4'ü gelir [S57].

### 2.6 Ölçüp düzeltme ve oyuncu düğmesi

Oyunlar çıkan sıklığı ölçüyor ve sayıyı vaat edilen deneyime göre elle düzeltiyor.

- **RimWorld sürüm notları:** Phoebe'nin yoğunluğu 0.14.1238'de düşürüldü, çünkü Cassandra'yla aynıydı ve "daha çok
  nefes" vaadiyle çelişiyordu. Randy 0.14.1241'de Cassandra'nın yaklaşık 1,5 katından onunla aynı seviyeye çekildi [S20].
- **Emily Short:** King of Chicago için binlerce rastgele oynanış koşup hiç tetiklenmeyen ve fazla kullanılan dizileri
  bulmayı anlatıyor [S50].
- **Valve:** "Survivor Intensity estimation is crude, yet the resulting pacing works." [S22]
- **Oyuncu düğmesi:** Darkest Dungeon'da kasaba olayı sıklığı ayarlanabiliyor [S24, S25]. RimWorld'de tehdit ölçeği
  %10 ile %220 arası [S20]. This War of Mine'da senaryo düzenleyicisi çatışma süresini, kışı ve suç seviyesini
  ayarlatıyor [S29, S30].

---

## 3. Oyuncular neyi övüyor, neye kızıyor

### 3.1 Övülenler

- **Ritim ve nefes.** Valve'ın gerekçesi: "Constant, unchanging combat is fatiguing", "long periods of inactivity are
  boring" [S22]. İncelemeler L4D'nin tekrar oynanabilirliğini övdü [S23]. Cassandra'nın düzenli ritmini oyuncular
  seviyor, kapalı evreye göre plan yapıyorlar [S18, S20]. Randy'yi seçenler sürprizi ve uzun sessizlikleri seviyor [S19].
- **Olayın mekaniğe bağlı olması.** Stellaris ekibi eski açılır pencere zincirlerinin takip edilmesinin zor olduğunu
  kabul etti ve onları sayaçla değiştirdi [S5]. Victoria 3 ekibi olayları mekaniklere bağlayarak düzeltti [S8].
- **Çeşitlilik hedefi.** Stellaris ekibinin hedefi: aynı imparatorlukla on kez oyna, on farklı hikâye yaşa [S13].
- **Kontrol.** Darkest Dungeon'da sıklık ayarının olması, oyuncuların olay yoğunluğunu kendileri seçmek istediğini
  gösteriyor [S24, S25].
- **Görülmemiş içerik önce.** Hades'in "aynı replik sonsuz tekrar" sorununu çözdüğü övülüyor. Kaynak zayıf, yalnız arama
  özeti var [S61, S62].

### 3.2 Başarısız örnekler

**a) Spam: koşulu doğru kalan olay durmadan gelir.**
- Stellaris: "every game I always end up swamped by events even at normal speed". Aynı gezegende "order restored"
  penceresi tekrar tekrar çıkıyor [S12].
- EU4 modları defalarca "event spam" düzeltmesi yayımladı [S16].
- Football Manager 2019: günde yaklaşık 80 gelen kutusu mesajı, %95'i ilgisiz. SI geliştiricisi motoru değil abonelik
  ayarını gösterdi [S35]. 2011'de her "devam"da 50'den fazla transfer haberi geliyordu [S36].

**b) Küçük havuz ve sık ritim: aynı olay yine gelir.**
- Crusader Kings III: yeni bir oyuncu "same handful of events over and over again" diyor [S7]. Oyunculara göre 20–30
  olaylık bir havuz bazen yılda birden çok kez dönüyor [S7, S63].
- Stellaris: "you'll have seen all of them within three, four playthroughs" [S12].
- Reigns: "cards get WAY too repetitive towards the end" [S52]. İncelemeler de aynı şeyi söylüyor [S53, S54].
- Sims 4: resmi bilinen sorunlar listesinde "Wants are very repetitive" yazıyor (2023-07-14) [S37]. Havuz yalnız temel
  oyun ve bir paketle sınırlı [S38].
- Football Manager 2017 basın toplantısı: haftadan haftaya 10'dan az soru dönüyor. Oyuncular toplantıyı yardımcı
  antrenöre devrediyor [S59, S60].

**c) Mekanikten kopuk olay: seçim anlamsızlaşır.**
- Victoria 3 geliştiricileri kendi olayları için şunu yazdı: "don't offer compelling choices, are too repetitive, or
  supersede rather than work alongside the game's mechanics" [S8].
- Big Ambitions: olaylar "repetitive and uninteresting" ve "don't change the narrative" diye eleştiriliyor [S40, S41].

**d) Sabit senaryo: her koşu aynı.**
- Frostpunk, The Last Autumn incelemesi: "every major event is scripted to happen at a certain time and there is nothing
  you can do to change that" [S27]. Steam'de ana oyun için "pre-recorded script" deniyor [S28].

**e) Korkuluksuz rastgelelik: haksızlık hissi.**
- Randy "could send multiple 1.5x size raids back-to-back" [S19]. Oyuncular aynı gün iki baskından yakınıyor [S31, S32].

**f) Opak olasılık: yazılan sayı yanlış okunur.**
- Fallen London'da 1 Standard ve 1 Frequent kart varken Frequent kart 2 değil 3 kat sık geliyor [S47]. Oyuncular
  desteyi "temizlemek" için rehber yazıyor [S48].
- EU4'te MTTH süresi "o süre içinde kesin gelir" diye yanlış okunuyor [S17].

**g) Fazla seyrek ya da hiç gelmeyen olay.**
- Crusader Kings III'te bir oyuncu, erken dönemde sık gelen bir olayın 1079'dan sonra hiç gelmediğini yazıyor [S7].
- Slay the Spire'da "?" odası kalmayan katlarda iki relic işe yaramaz kaldı. Geliştirici yamayla onları ödül havuzundan
  çıkardı [S46]. Ders: yuvası olmayan yerde olay beklenmez.

---

## 4. Bizim motorla karşılaştırma

### 4.1 Bugün bizde ne var

**Kâğıt yuvası.** Sprint 2 haftadır. Zar ilk haftanın sonunda atılır, ihtimal `decision.sprint_chance` = 0,5 [S64, S65].
Kodda sprint, haftanın işinden sonra kartları bitmişse kapanır. Kapanmazsa bir sonraki haftanın ataması yapılır ve kâğıt
o sırada istenir (`_staff_week(true)`) [S66]. Yani 1 haftada kapanan sprint kâğıt zarını hiç görmez [S66, S70].

**Seçim.** Havuzda 47 kâğıt var [S65]. Sıra `u ^ (1 + 2 × görülme)` anahtarıyla kurulur, görülmemiş kâğıt öne geçer
[S66, S69]. Motor sırayla ilk uygun kâğıdı ve konuşacak kişiyi arar [S66].

**Uygunluk.** Kâğıdın kendi koşulu tutmalı. Konuşan rol de o aşamada kartta çalışıyor olmalı [S64, S66].

**Mandal (latch).** 47 kâğıdın 43'ü 52 hafta bekler ve koşuda en çok 3 kez gelir. 2'si 26 hafta ve en çok 3 kez, 1'i
tek seferlik, 1'i 52 hafta ve tek seferlik [S73].

**Kesinti sırası.** Söz olayı ya da acil durum gelen sprintte kâğıt gelmez. Kâğıt gelen sprintte yalnız servisin çöktüğü
acil durum yaşanır, öbürü sonraki sprinte kalır [S64, S66].

**Aile frenleri.** Havuz kartlarında iki fren var: aynı aileden başka kart (varsayılan 6 hafta) ve aynı aile aynı kişi
[S67, S69]. Kâğıtlar ise `Origin.REQUEST` yoluyla gelir. Motor aile frenini yalnız havuz, sessiz taban, sinyal ve
zamanlama için sorar, istek için sormaz [S68]. 47 kâğıdın 41'i `family_subject` taşır (40'ı 26 hafta, 1'i 52 hafta).
Bu alan kâğıt yolunda fren olarak çalışmaz, yalnız kayıt tutulur [S68, S73].

**Havuzun öbür katmanları (kâğıt dışı olaylar).** Faza göre "olay yok" ağırlığı 1,5 / 1,0 / 0,6. Aynı kart 4 hafta,
aynı çalışan 2 hafta, aynı müşteri 4 hafta dönmez. Haftalık kategori kotası var. Haftada en çok 2 kesinti olur. 1 sessiz
haftadan sonra sessiz havuz devreye girer. İlk 3 haftada havuz konuşmaz [S67, S69].

**Acil durum zarı duruma bağlı.** Taban ihtimal 0,1, tavan 0,3. Açık hata ve sunucu kademesiyle değişir. İki acil durum
arasında en az 4 hafta var [S64, S65].

**Ölçüm hedefi.** §13.7 çapası normal hızda 2–3 dakikada bir karar yüzeyi ve 3 dakikada en çok 3 kesinti ister. Kod bunu
açıkça "ayar değeri değil, ölçüm hedefi" diye yazıyor [S67, S69]. §13.8'e göre tempo sayılarının hiçbiri ölçülmedi [S69].

**Ölçülen kâğıt sıklığı.**
- D son ölçümü (2026-10-27, `baa63da`, 88 koşu × 104 hafta). v1.0 sonrası kâğıt gelen sprint B2B'de %7,7–8,9, B2C'de
  %6,6–10,3. Koşu başına medyan 5–7 kâğıt. Koşu başına 69–80 sprint kapanıyor. 44 kâğıdın 18'i hiç gelmedi, 8 tasarımcı
  kâğıdının hiçbiri gelmedi [S71].
- Faz B ölçümü (yaklaşık 2026-10-17). 1.506 sprintte 147 kâğıt geldi (%9,8). 956 sprint 1 tikte kapandı ve kâğıt
  görmedi. 2 tikte kapanan sprintlerde oran %27,7. Konuşana göre yazılımcı 99, kurucu 34, testçi 5, PM 1, tasarımcı 0
  [S70].
- Gerçek zamanda: 1×'te bir hafta 22,5 saniye [S69]. 104 hafta yaklaşık 39 dakika eder. Koşuda 6 kâğıt, 1×'te yaklaşık
  6,5 dakikada bir, 4×'te yaklaşık 1,6 dakikada bir demek (hesap; modal duraklamaları hariç, varsayım).

### 4.2 Hangisi zaten endüstri kalıbı

| Kalıp | Endüstri örneği | Bizde | Durum |
|---|---|---|---|
| Yuva / nabız | CK3 nabızları [S2], GDT 36–84 hafta [S33], StS "?" düğümü [S43] | Sprint başına tek zar [S64] | Var. 1 haftalık sprintte yuva açılmıyor |
| Zar + "olay yok" | CK3 "100 = 0" [S2], V3 "0" satırı [S14] | `sprint_chance` 0,5; havuzda "olay yok" ağırlığı [S65, S67] | Var |
| Duruma bağlı uygunluk | StS kapıları [S44], FL quality [S47], V3 mekanik bağı [S8] | Kâğıt koşulu + konuşan kişi [S66] | Var. Endüstrinin iyi örneğine yakın |
| Görülmemişi öne alma | Hades öncelik [S61], StS koşu başına bir kez [S44] | `seen_weight` 2 [S65] | Var |
| Olay başına bekleme ve sınır | CK3 5 yıl [S2], V3 3 yıl [S4], GDT `maxTriggers` [S33] | 52 hafta, koşuda en çok 3 [S73] | Var |
| Asgari aralık / tek kesinti | Cassandra 1,9 gün [S18], L4D dinlenme [S22] | Sprintte tek kesinti, acil durumda 4 hafta [S64, S65] | Var |
| Aynı türün art arda gelmemesi | L4D boss destesi [S22] | Havuzda aile frenleri; kâğıtta yok [S68] | Kısmi |
| Azami aralık (pity) | Randy 13 gün [S19], StS rampası [S43] | Havuzda sessiz taban var; kâğıtta yok [S67] | Eksik |
| Sıklığın duruma bağlanması | L4D yoğunluk [S22], Stellaris sayacı [S5] | Acil durum zarında var; kâğıt zarı düz [S65] | Kâğıtta yok |
| Ölç ve düzelt | RimWorld [S20], Emily Short [S50] | Harness + §13.7 çapası + D son ölçümü [S67, S71] | Var |
| Oyuncuya sıklık düğmesi | DD [S24], RimWorld [S20], TWoM [S29] | Yok | Bilinçli seçim olabilir |

[GÖRÜŞ] Kural yazmaya gerek yok, çünkü sıklığı üreten katmanlar bizde zaten var. Amerika'yı yeniden keşfetmiyoruz.
Motorun iskeleti endüstrinin kalıbıyla aynı.

### 4.3 Eksik olanlar

1. **Yuva kaybı.** 1 haftada kapanan sprint zar görmüyor. Faz B'de sprintlerin yaklaşık %63'ü böyle kapandı (hesap,
   956 / 1.506) [S70]. Yazılan 0,5 ile görülen yaklaşık %8 arasındaki fark büyük. Bu, EU4'teki "3 aylık MTTH gerçekte
   6–7 ayda bir" sorununun bizdeki hali [S1]. [GÖRÜŞ] Bunu kimse seçmedi. Zarın ilk haftanın sonunda atılmasının yan
   etkisi.
2. **Azami aralık yok.** Kâğıtlar arasında uzun bir sessizlik olursa onu kapatan bir kural yok. D son raporunda
   "kâğıtlar arası en uzun boşluk" sütunu da yok [S71]. Randy'nin 13 gün kuralı ya da StS rampası gibi bir korkuluk
   bizde yok [S19, S43].
3. **Etkin havuz dar.** 44 kâğıdın 26'sı geliyor [S71]. Konuşan çoğunlukla yazılımcı: 139 kâğıdın 99'u (hesap, yaklaşık
   %71) [S70]. Koşuda yaklaşık 6 kâğıt ve 26 etkin kâğıtla oyuncu bütün kâğıtları 4–5 koşuda görür (hesap). Bu, Stellaris
   oyuncusunun "3–4 oynanışta hepsini gördüm" şikâyetinin aynısı [S12]. [GÖRÜŞ] Tekrar riski sıklıktan değil, bu darlıktan
   geliyor. GDD §13.1 de aynı şeyi söylüyor: sorun sayı değil, benzerlik [S69].
4. **Kâğıt sıklığı duruma bağlı değil.** Kâğıt zarı düz 0,5. Acil durum zarı ise hataya ve yüke bağlı [S65].
   [GÖRÜŞ] Bu bir eksik olmayabilir, çünkü kâğıdın uygunluğu zaten duruma bağlı. Ama "riskli sprint, daha çok kâğıt"
   gibi bir bağ yok.
5. **Aile freni kâğıtta çalışmıyor** (§4.1). [GÖRÜŞ] Koşuda 6 kâğıtla risk küçük. Kâğıt sayısı artarsa aynı aileden
   art arda kâğıt gelebilir. Yazılımcı kâğıtları zaten çoğunlukta.
6. **Oyuncuya düğme yok.** [GÖRÜŞ] Şimdilik gerekmez. Playtest'te sıklık tartışması çıkarsa ucuz bir çözüm olarak
   akılda kalsın.

---

## 5. Seçenekler ve önerim

### A. "%7–10"u kural olarak yaz

- **Oyuncu ne hisseder:** Bugünkünden fark yok.
- **Bedel:** Bir cümle. Ama sayı hedefe dönüşür. İçerik eklenince ya da sprint süresi değişince "kural bozuldu" alarmı
  çalar ve ajanlar sayıyı tutturmak için zarla oynar. Endüstride böyle bir kural örneği bulamadım [S1–S4, S18, S33].
  EU4'ün dersi de aynı yönde: yazılan sayı gerçeği anlatmayınca herkes onu yanlış okur [S1, S17].
- **Geri dönüş:** Kolay.

### B. İlkeyi yaz, sayıyı tarihli ölçüm olarak bırak (önerim, şimdi)

- **Ne değişir:** Cümle mekanizmayı anlatır. Sayı "ölçülen" etiketiyle, tarih ve commit'le yazılır. Harness her
  ölçümde iki sayı raporlanıyor: kâğıt gelen sprint oranı ve koşu başına kâğıt [S71]. Bunları ölçüm betikleri zaten çıkarıyor. Bunlara iki sütun eklenir:
  kâğıtlar arası en uzun boşluk ve konuşana göre dağılım.
- **Oyuncu ne hisseder:** Bugünkünden fark yok.
- **Bedel:** CLAUDE.md'de bir cümle, GDD §27.33 ve GÜNCELLEMELER'de aynı cümle [S69, S74], ölçüm betiğine iki
  sütun (varsayım: küçük iş).
- **Geri dönüş:** Kolay.
- **Neden:** RimWorld, Valve ve Emily Short'un yaptığı bu [S20, S22, S50]. Bizim §13.7 çapası da zaten böyle yazılmış:
  ölçüm hedefi, ayar değeri değil [S67].

### C. B'ye ek olarak mekanizmayı onar (playtest'ten sonra karar)

- **C1, yuva:** Zarı her sprint görsün, sprint başında ya da 1 haftada kapanan sprintte kapanıştan önce. Sonra
  `sprint_chance`'i bugünkü sıklığı koruyacak kadar düşür. Yazılan sayı gerçeğe yaklaşır.
- **C2, azami aralık:** "N sprint üst üste kâğıtsız geçerse sıradaki uygun sprintte kâğıt istenir" (Randy'nin 13 gün
  kuralı gibi [S19]) ya da StS rampası (gelmedikçe şans artar, gelince sıfırlanır [S43, S44]).
- **C3, içerik:** Hiç gelmeyen 18 kâğıdın, özellikle 8 tasarımcı kâğıdının, neden gelmediğini bul [S71]. Bu sıklık
  değil, içerik onarımı.
- **Oyuncu ne hisseder:** Kâğıtlar daha düzenli gelir. Uzun sessizlikler kısalır. Kâğıtlar daha çok kişiden gelir.
  Risk: sayı iyi ayarlanmazsa "her sprint aynı ekran" hissi, FM basın toplantısı gibi [S59], ya da spam [S12].
- **Bedel:** Kod, içerik ve D son ölçümü gibi 88 koşuluk yeni bir ölçüm. [DEĞERLENDİREMEM] Kesin iş boyutunu
  bilmiyorum. Zarın zamanını değiştirmek kayıt uyumunu ve zarı sınayan smoke vakalarını etkiler (varsayım).
- **Geri dönüş:** Orta. Sayılar tek dosyada durur ama zar zamanı kodda değişir.

### Önerim

[GÖRÜŞ] B'yi şimdi onayla. C3'ü hemen iş listesine al, çünkü sıklıktan bağımsız ve tekrar hissinin asıl kaynağı o.
C1 ve C2'yi playtest'ten sonra seç. Playtest'te iki şeye bak: kâğıtlar arasındaki sessizlik sana uzun geliyor mu, ve
kâğıtlar hep aynı kişiden mi geliyor? Koşuda 6 kâğıdın az olup olmadığına ölçüm cevap veremez, his cevap verir
[DEĞERLENDİREMEM].

### CLAUDE.md §6 için önerilen yeni yazım

Cevap: **ilke.** Sayı kural olarak değil, ölçüm olarak durur.

Bugünkü parça:

> …`decision.cards` havuzundan bir kâğıt istenir, yoksa sprint kâğıtsızdır ([WORKING]: sprintlerin en az üçte biri).

Önerilen parça:

> …`decision.cards` havuzundan bir kâğıt istenir, yoksa sprint kâğıtsızdır. Kâğıdın sıklığı bir kural değildir: zarın,
> kâğıtların koşullarının, mandalların ve kesinti sırasının çıktısıdır; ölçülür, elle hedeflenmez. Sıklık değişecekse
> zar, koşul ya da mandal değişir. Tam ölçüm raporu kâğıt gelen sprint oranını ve koşu başına kâğıdı yazar (son ölçüm
> 2026-10-27, `baa63da`, 88 koşu: v1.0 sonrası %6,6–10,3, koşu başına medyan 5–7). 1 haftada kapanan sprint zar görmez.

Aynı değişiklik GDD §27.33'teki ve GÜNCELLEMELER'deki "en az üçte biri kâğıtsız kalır" cümlesine de gider [S69, S74].

---

## 6. Kaynak sicili

Güven: Yüksek, Orta, Düşük. "Açıldı": sayfa okundu. "Özet": yalnız arama özeti görüldü.

### Dış kaynaklar

| S# | URL | Yayıncı | Tarih | Güven | Açıldı mı |
|---|---|---|---|---|---|
| S1 | https://eu4.paradoxwikis.com/Event_modding | EU4 resmi wiki (Paradox Wikis) | tarihsiz | Yüksek | Açıldı |
| S2 | https://ck3.paradoxwikis.com/Event_modding | CK3 resmi wiki | tarihsiz | Yüksek | Açıldı |
| S3 | https://stellaris.paradoxwikis.com/Event_modding | Stellaris resmi wiki | v3.6 (2022) | Yüksek | Açıldı |
| S4 | https://vic3.paradoxwikis.com/Event_modding | Victoria 3 resmi wiki ("potentially outdated") | 1.11 | Orta | Açıldı |
| S5 | https://devtrackers.gg/stellaris/p/5115b474-stellaris-dev-diary-245-we-have-a-situation | Paradox, Stellaris DD #245 (ayna) | 2022 | Yüksek | Açıldı |
| S6 | https://forum.paradoxplaza.com/forum/developer-diary/crusader-kings-3-dev-diary-30-event-scripting.1397140/ | Paradox, CK3 DD #30 | 2020 | Orta | Özet (tarayıcı doğrulaması) |
| S7 | https://steamcommunity.com/app/1158310/discussions/0/3838801919839423509 | Steam, CK3 oyuncu tartışması | 2023 | Düşük | Özet (yaş kapısı) |
| S8 | https://admin-forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-88-voice-of-the-people-narrative-content-improvements.1588003 | Paradox, V3 DD #88 | 2023 | Orta | Özet |
| S9 | https://admin-forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-31-journal-entries.1508059 | Paradox, V3 DD #31 | 2022 | Orta | Özet |
| S10 | https://admin-forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-80-law-enactment-and-revolution-clock-in-1-3.1577105/page-6 | Paradox, V3 DD #80 | 2023 | Orta | Özet |
| S11 | https://steamcommunity.com/workshop/filedetails/discussion/2889925770/604165686037630450 | Steam Workshop, V3 mod tartışması | tarihsiz | Düşük | Özet (raporda kullanılmadı) |
| S12 | https://steamcommunity.com/app/281990/discussions/0/1739964947814544772 | Steam, Stellaris başlıkları | tarihsiz | Düşük | Özet |
| S13 | https://admin-forum.paradoxplaza.com/forum/developer-diary/stellaris-dev-diary-361-the-vision.1712933/page-31 | Paradox, Stellaris DD #361 | 2024 | Orta | Özet |
| S14 | https://admin-forum.paradoxplaza.com/forum/threads/modding-event-frequency.1558563 | Paradox forum, V3 ağırlık örneği | tarihsiz | Düşük | Özet |
| S15 | https://forum.paradoxplaza.com/forum/threads/modding-quick-questions-and-answers.1414681/page-62 | Paradox forum, CK3 modding S&C | tarihsiz | Orta | Özet |
| S16 | https://steamcommunity.com/sharedfiles/filedetails/changelog/2185445645?p=2 | Steam Workshop, EU4 mod değişiklik notları | tarihsiz | Düşük | Özet |
| S17 | https://forum.paradoxplaza.com/forum/threads/event-scripting-tricks-and-traps-explained.140230/post-2766024 | Paradox forum, eski rehber | eski | Orta | Özet |
| S18 | https://rimworldwiki.com/wiki/Cassandra | RimWorld wiki (oyunun XML'ini alıntılar) | rev. 2026-10-01 | Orta-Yüksek* | Açıldı |
| S19 | https://rimworldwiki.com/wiki/Randy_Random | RimWorld wiki ("Unverified" etiketli) | tarihsiz | Orta | Açıldı |
| S20 | https://rimworldwiki.com/wiki/AI_Storytellers | RimWorld wiki | tarihsiz | Orta | Açıldı |
| S21 | https://rimworldwiki.com/wiki/Phoebe_Chillax | RimWorld wiki | tarihsiz | Orta | Özet |
| S22 | https://cdn.fastly.steamstatic.com/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf | Valve, Michael Booth, AIIDE | 2009 | Yüksek | Açıldı (PDF metni çıkarıldı) |
| S23 | https://en.wikipedia.org/wiki/Left_4_Dead | Wikipedia (inceleme özeti) | tarihsiz | Orta | Açıldı |
| S24 | https://darkestdungeon.wiki.gg/wiki/Town_Events | Darkest Dungeon wiki | tarihsiz | Orta | Açıldı |
| S25 | https://www.siliconera.com/not-even-hamlet-safe-everything-burns-update-darkest-dungeon/ | Siliconera | 2016 | Orta | Özet |
| S26 | https://frostpunk.fandom.com/wiki/Events | Frostpunk fandom wiki | tarihsiz | Düşük | Engellendi (402; raporda kullanılmadı) |
| S27 | https://primagames.com/featured/frostpunk-the-last-autumn-review-the-fall-is-here | Prima Games incelemesi | tarihsiz | Orta | Özet |
| S28 | https://steamcommunity.com/app/323190/discussions/0/1744480967009061229 | Steam, Frostpunk | tarihsiz | Düşük | Özet |
| S29 | https://techraptor.net/content/insert-yourself-into-the-war-in-this-war-of-mines-v1-3 | TechRaptor | 2015-04 | Orta | Özet |
| S30 | https://gamingnexus.com/News/35410/This-War-of-Mine-update-adds-new-locations2c-new-music2c-a-scenario-editor-and-the-long-awaited-character-creator | Gaming Nexus | 2015-04 | Orta | Özet |
| S31 | https://steamcommunity.com/app/294100/discussions/0/3160957541882594447 | Steam, RimWorld | tarihsiz | Düşük | Özet |
| S32 | https://steamcommunity.com/app/294100/discussions/0/1751276319488753100 | Steam, RimWorld | tarihsiz | Düşük | Özet |
| S33 | https://github.com/greenheartgames/gdt-modAPI/wiki/GDT.addEvent%28%29 | Greenheart Games, resmi mod API wiki | 2013–2014 | Yüksek | Açıldı |
| S34 | https://www.ootpdevelopments.com/newsletters/nl0094/ | OOTP Developments, resmi bülten | 2012 | Yüksek | Açıldı |
| S35 | https://steamcommunity.com/app/872790/discussions/0/3647273545685361167 | Steam, FM2019 (SI geliştirici cevabı) | 2019-08 | Orta | Açıldı |
| S36 | https://www.fmscout.com/q-2780-Too-much-transfer-news.html ve https://www.fmscout.com/q-5914-Agent-offers.html | FM Scout hayran forumu | 2011 ve FM2012 | Düşük | Özet |
| S37 | https://simscommunity.info/2023/07/14/the-sims-4-laundry-list-july-14-2023/ | SimsCommunity (resmi listeyi aktarır) | 2023-07-14 | Orta | Açıldı |
| S38 | https://simscommunity.info/2022/07/28/wants-and-fears-in-the-sims-4-are-very-limited/ | SimsCommunity | 2022-07-28 | Orta | Açıldı |
| S39 | https://www.magicgameworld.com/?p=23552 | Magic Game World, Two Point Hospital rehberi | tarihsiz | Düşük | Açıldı (raporda kullanılmadı) |
| S40 | https://backloggd.com/u/snackerfork/reviews/ | Backloggd, Big Ambitions incelemesi | tarihsiz | Düşük | Engellendi (bot kontrolü) |
| S41 | https://vaporlens.app/app/1331550/big_ambitions/stats/details | Vaporlens, Big Ambitions özeti | tarihsiz | Düşük | Özet |
| S42 | https://catalogue.smods.ru/archives/346476 | Software Inc. "Random Events" modu (ayna) | beta 1.7 | Düşük | Özet (raporda kullanılmadı) |
| S43 | https://slaythespire.wiki.gg/wiki/Map_Locations | Slay the Spire wiki | tarihsiz | Orta | Açıldı |
| S44 | https://slaythespire.wiki.gg/wiki/Events | Slay the Spire wiki ("ToUpdate") | tarihsiz | Orta | Açıldı |
| S45 | https://slaythespire.wiki.gg/wiki/Map_Generation | Slay the Spire wiki | tarihsiz | Orta | Özet |
| S46 | https://steamcommunity.com/app/646570/discussions/0/1617220671495467374 | Steam, Slay the Spire | tarihsiz | Düşük | Özet |
| S47 | https://fallenlondon.wiki/wiki/Card_Frequency | Fallen London wiki | tarihsiz | Orta | Açıldı |
| S48 | https://fallenlondon.wiki/wiki/User:Asarta/Deck_Optimisation_(Guide) | Fallen London wiki kullanıcı rehberi | tarihsiz | Düşük | Özet |
| S49 | https://emshort.blog/2019/11/29/storylets-you-want-them/ | Emily Short blogu | 2019-11-29 | Yüksek | Açıldı |
| S50 | https://emshort.blog/2016/04/12/beyond-branching-quality-based-and-salience-based-narrative-structures/ | Emily Short blogu | 2016-04-12 | Yüksek | Açıldı |
| S51 | https://gamingtrend.com/feature/interviews/one-night-with-the-king-reigns-developer-interviewed-on-games-success | GamingTrend, François Alliot röportajı | 2016 | Yüksek | Açıldı |
| S52 | https://steamcommunity.com/app/474750/discussions/0/355043117519621881 | Steam, Reigns | tarihsiz | Düşük | Özet |
| S53 | https://opencritic.com/game/3110/reigns/reviews | OpenCritic | tarihsiz | Orta | Özet |
| S54 | https://techraptor.net/content/reigns-review-addicted-death | TechRaptor incelemesi | tarihsiz | Orta | Özet |
| S55 | https://subsetgames.com/forum/viewtopic.php?p=18337 | Subset Games resmi forumu (modder bulgusu) | tarihsiz | Orta | Özet |
| S56 | https://ftl.fandom.com/wiki/Sectors | FTL fandom wiki | tarihsiz | Orta | Özet (402) |
| S57 | https://i2.trueachievements.com/game/The-Banner-Saga-2/walkthrough/7 | TrueAchievements hayran rehberi | tarihsiz | Orta | Özet |
| S58 | https://steamcommunity.com/app/718670/discussions/0/1728701877499867609 | Steam, Cultist Simulator | tarihsiz | Düşük | Özet (raporda kullanılmadı) |
| S59 | https://steamcommunity.com/app/482730/discussions/0/135512931347683702 | Steam, FM2017 | 2017-03-29 | Orta | Açıldı |
| S60 | https://whatculture.com/gaming/football-manager-2013-9-improvements-we-want-to-see | WhatCulture | 2013 | Düşük | Özet |
| S61 | https://steamcommunity.com/app/1145360/discussions/0/2987539784417139179 | Steam, Hades (hayran yorumu) | tarihsiz | Düşük | Özet |
| S62 | https://gdcvault.com/play/1026975/Breathing-Life-into-Greek-Myth | GDC Vault, Kasavin ve Korb | 2021 | Orta | Özet (üyelere kapalı) |
| S63 | https://vaporlens.app/app/2311920/crusader_kings_iii_tours_tournaments.md | Vaporlens, CK3 Tours & Tournaments | tarihsiz | Düşük | Özet |

\* İki araştırmacı S18'e farklı güven verdi: biri Yüksek (oyunun XML değerlerini alıntılıyor), biri Orta (topluluk
wiki'si). Sayılar iki okumada da aynı.

### Bizim kod ve belgelerimiz

Hepsi `/Users/tugbauysal/Desktop/project steam/Project Unicorn/project-unicorn/` altında, 2026-10-28 çalışma kopyasından
okundu. Güven: Yüksek (doğrudan okundu).

| S# | Yol | Ne için |
|---|---|---|
| S64 | `CLAUDE.md` §6, "Acil durum", "Söz olayı", "Karar kâğıdı" paragrafları (satır 103–150) | Kâğıt zarı, kesinti sırası, bugünkü cümle |
| S65 | `data/product/sprint.json`, `decision` ve `incident` blokları | `sprint_chance` 0,5, `seen_weight` 2, 47 kâğıt; acil durum sayıları |
| S66 | `scripts/systems/sprint_system.gd` (kapanış 1323–1328, `_staff_week` 1331–1335, `_request_decision` 1459–1496, `_paper_blocked` 1515–1518) | Zarın ne zaman atıldığı, seçim, engeller |
| S67 | `scripts/events/core/tuning.gd` (`EvTuning`) | Fren sayıları, "olay yok" ağırlığı, §13.7 ölçüm hedefi |
| S68 | `scripts/events/core/engine.gd` 313–341, `scripts/events/present/tempo.gd` 120–205, `scripts/events/gate/gate.gd` 195–200, `scripts/events/tools/plausibility.gd` 45–48 | Aile freninin yalnız havuz, taban, sinyal ve zamanlamada sorulduğu |
| S69 | `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` §11.5, §13 (Tempo), §27.33 | Fren katmanları, 22,5 sn/hafta, "ölçülmedi" notu, GDD'deki aynı cümle |
| S70 | `docs/tasks/faz_ab/RAPOR_B.md`, madde 4 | Faz B kâğıt ölçümü (1.506 sprint, %9,8, 956 tek tik, konuşan dağılımı) |
| S71 | `docs/tasks/faz_cde/d_taslak/olcum/D_SON_OLCUM.md`, K4 ve K4b (2026-10-27, `baa63da`) | Son kâğıt ölçümü, hiç gelmeyen kâğıtlar |
| S72 | `docs/tasks/DEVIR_DIZUSTU_2026-10-27.md`, madde 6 | "%7–10" önerisinin kaynağı |
| S73 | `data/events/cards/product/sprint_*.json` (47 kâğıt) | Mandal ve aile alanlarının sayımı |
| S74 | `GDDs/GUNCELLEMELER.md`, satır 376 | Aynı "en az üçte biri kâğıtsız" cümlesi |

### Açılamayan sayfalar

EU4 wiki On_actions (404), CK3 DD #30 (tarayıcı doğrulaması), CK3 Steam başlığı (yaş kapısı), Frostpunk ve This War of
Mine fandom (402), Subset forumu bir başlık (403), FTL fandom (402), Unwinnable (403), Backloggd (bot kontrolü). Hiçbirinin
aşılması denenmedi. Bunlardan gelen bilgi yalnız arama özetine dayanır ve tabloda "Özet" diye işaretli.

### Doğrulanmamış bilgi

- Slay the Spire "?" odasının kesin yüzdeleri (canavar %10, dükkân %3, hazine %2 ve artışları) araştırmacının hafızasından
  geldi, wiki'de doğrulanamadı. Raporda yalnız "rampa var" bilgisi kullanıldı.
- Phoebe'nin 8 gün açık, 8 gün kapalı döngüsü yalnız arama özetinden geliyor [S21]. Raporda kullanılmadı.
- EU4'ün MTTH'yi 20 günde bir yokladığı bilgisi doğrulanamadı. Raporda kullanılmadı.
