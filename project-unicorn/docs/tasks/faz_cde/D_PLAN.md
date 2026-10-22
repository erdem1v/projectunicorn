# Faz D planı · Ekip modeli (role göre puan, yıldız, uyum, testçi, PM)
Planlayıcı: Opus (yüksek), 2026-10-16. Repo dosyası değişmedi; yalnız okuma ve başsız probe koşuları yapıldı.
A ile B bu plandan önce koda girecek. Onlara dayanan her varsayım **"A/B varsayımı"** diye işaretli. Uygulamadan önce
plan güncel koda karşı tazelenir.

---

## 0. Özet
- **Ne değişiyor:** Ekip tek tür "puan" üretmiyor. Geliştirici geliştirme, tasarımcı tasarım, testçi test puanı üretir.
  Her kart her aşama için ayrı ihtiyaç söyler ("Tasarım 9 · Geliştirme 11 · Test 5"). Bir aşamanın fazlası öbürünü
  kapatmaz.
- **Yıldız:** Onaylı tablo (1★ ×0,64 … 5★ ×2,0) her aşamada kişinin o alandaki puanıyla çalışır. Bugün 4, 5 ve 6 puanlık
  kişiler aynı puanı üretiyor; bu biter.
- **Uyum:** Ana alan ×1,0, ikincil ×0,7, uymayan ×0,4. Uymayan iş yalnız oyuncu bilerek atarsa olur, atama anında
  hız ve moral bedeli yazar.
- **Ekip büyüklüğü:** 3 kişiye kadar kayıp yok, sonra her kişi %1 (5 kişide %2, 20 kişide %17, tavan %25). PM bunu
  8 kişiye kadar yarıya indirir.
- **Testçi:** Kart başına hata ihtimali testçisiz yaklaşık %11–14, 3★ testçiyle %7, 5★ testçiyle %2. Ekranda sayı olarak
  yazar. (inceleme) Dikkat: bugün oyunda pratikte hiçbir kart hatalı çıkmıyor (§1). Yeni modelde testçisiz ekip
  bugünden **daha çok** hata görür; testçi bu yüzden ilk kez gerçekten fark eder.
- **PM:** Sprint puanı üretmez. Sprint koşarken sonraki kartları "Hazır" eder. Hazır kart %20 daha az iş tutar ve hata
  ihtimali dörtte bir azalır. PM'siz ekipte ceza yoktur, yalnız bu kazanç yoktur.
- **Oyuncu ne hisseder:** Plan ekranında hangi aşamanın darboğaz olduğu tek bakışta görünür. 3★ geliştirici almak
  1★ almaktan gerçekten farklıdır. Testçi almanın, PM almanın karşılığı sayıyla görünür. Tek başına kurucunun hızı ve
  MVP'nin 6. hafta civarı değişmez.
- **Bedel:** Büyük (çekirdek mekanik). 7 commit, uygulama yaklaşık 14 saat, incelemeler ve kapılarla 18–20 saat.
  (inceleme) Gerçekçi takvim 20–24 saat: D2a ve D5 tahmin = sonuç kapısında bir tur kaybedebilir.

---

## 1. Bugünkü akış
**Oyuncu ne görüyor:**
- Plan ekranında tek bir kapasite çubuğu var ("27/34"). Kartta tek bir efor sayısı var (K1 3, K2 5, K3 8 puan).
- Kartın üstüne gelince kim kaç hafta çalışacak yazıyor. Hangi aşamanın darboğaz olduğu hiçbir yerde görünmüyor.
- Ekipte testi yapabilecek kimse yoksa tek bir uyarı satırı çıkıyor: "Ekipte Test yok · kartlar hatalı çıkabilir".
  İhtimal yazmıyor. (inceleme) Kurucu ve geliştirici teste "uyan" sayıldığı için bu satır yalnız kurucu yokken ve
  ekipte geliştirici ya da testçi yokken çıkar; o durumda kart testte bekler, hatalı çıkmaz.
- İşe alım dosyasında "Sprintte haftada 2 puan" yazıyor. Bu sayı 1★ ile 3★ arasında neredeyse hiç değişmiyor.

**Arka planda:**
- Herkes haftada 2 puan × beceri bandı üretir. Bant üç basamaklı: 0–3 puan ×0,75, 4–6 ×1,0, 7–10 ×1,25.
  Sonuç: 2★, 2,5★ ve 3★ aynı hızdadır. 5★ kişi 3★ kişiden yalnız %25 hızlıdır.
- PM ve tasarımcı da 2 puan üretir. PM, tasarım aşamasında tasarımcı gibi çalışır.
- Herkes rolüne uyan her aşamada tam hızla, uymayanda yarı hızla, kendiliğinden çalışır. Oyuncu bunu seçmez, görmez.
- ~~Testçisiz test edilen kart sürümde %40 ihtimalle hata doğurur. Testçili kart hiç hata doğurmaz.~~
  (inceleme) Kâğıt üstünde: testi rolü teste uymayan kişi yaparsa kart %40 ihtimalle hatalı çıkar. Pratikte: kurucu
  her role, geliştirici ikincil alanıyla teste uyar; PM ve tasarımcı tasarım aşamasının ötesinde hiç çalışmaz. Yani
  oyunda hiçbir kart hatalı işaretlenmez, gerçek ihtimal **%0**'dır. %40'lık zar yalnız smoke vakasında, kurucunun
  rolleri elle kısılınca tetikleniyor (`endgame_smoke.gd` `_case_sprint_faulty_ticket_deterministic`). Erdem'in "testçi
  yokken %40 fazla" yorumu kâğıttaki sayıya; oyuncu bu bedeli hiç yaşamadı.
- Ekip büyüdükçe hiçbir kayıp yok. 12 kişi, 3 kişinin dört katını üretir.
- **Bulunan iki açık:**
  1. Ekip › Görevler matrisi sprinti etkilemiyor. Destek'e de atanan geliştirici sprintte yine tam çalışıyor; iki yerde
     birden sayılıyor.
  2. Kurucunun satış toplantısı ve yatırımcı hazırlığı sprint puanından hiçbir şey düşmüyor. Bunu bugün yalnız Ar-Ge
     sayıyor. (inceleme, doğrulandı) Toplantı saati zaten tutuluyor: `GameState.founder_meeting_share()` (haftanın
     toplantı saati ÷ 40); Ar-Ge onu okuyor (`rnd_system.gd:116`), `SprintSystem.team()` okumuyor. Yatırımcı hazırlığı
     kurucuyu `HRSystem.is_busy` yapıyor, sprint ekibi bu kapıyı da okumuyor.

**Neden yetersiz:** Erdem'in sorusu "Tasarımcı, PM, geliştirici, testçi aynı puanı mı üretmeli?" Bugün evet. Yıldız
neredeyse fark etmiyor. Oyuncu kartın neye ihtiyaç duyduğunu ve ekibinin nerede zayıf olduğunu göremiyor.

**Bugünkü ölçüm** (başsız `--sprint-probe=hours=8:cards=2:ticks=40:fill=1:seeds=3`, ayrı APPDATA):

| Ekip | Eşleşme | MVP günü | Sprint | Planlanan / biten kart | Boşta kişi-hafta |
|---|---|---|---|---|---|
| Kurucu | 144/144 | 7 | 66 | 144 / 135 | 0 |
| 3 kişi | 294/294 | 3 | 93 | 294 / 261 | 78 |
| 6 kişi | 336/336 | 3 | 105 | 336 / 315 | 336 |

---

## 2. Hedef akış

### 2.1 Puan birimi
- Ölçek beş katına çıkar: **2,5★ bir kişi 8 saatlik haftada 10 puan üretir.** K1 kart 15, K2 25, K3 40 puan.
- Neden: Aşama ihtiyaçları tam sayı olarak okunur ("Tasarım 2 · Geliştirme 10 · Test 3"). Bugünkü ölçekte aynı kart
  "0,6 · 1,8 · 0,6" yazardı.
- Oranlar değişmez. Tek başına kurucu bugün 2 hafta × 2 = 4 puanla 3 puanlık K1'i bitiriyordu; yeni ölçekte 20 puanla
  15 puanlık K1'i bitirir.

### 2.2 Kart ihtiyacını nasıl söyler
Her kart üç aşama için ayrı puan ister. Payı ürünün özelliğinden gelir: **deneyim** özellikleri tasarım ağırlıklı,
**inovasyon** özellikleri geliştirme ağırlıklı, **kararlılık** özellikleri test ağırlıklıdır. Erdem'in "özelliğe
tasarım karmaşıklığı" fikri budur. Yeni veri yazılmaz; her kademenin ekseni bugün veride var.

| Kart | Deneyim (Tas / Gel / Test) | İnovasyon | Kararlılık |
|---|---|---|---|
| K1 · 15 | 5 / 7 / 3 | 2 / 10 / 3 | 2 / 8 / 5 |
| K2 · 25 | 9 / 11 / 5 | 4 / 16 / 5 | 3 / 13 / 9 |
| K3 · 40 | 14 / 18 / 8 | 6 / 26 / 8 | 4 / 22 / 14 |

- **Düzeltme kartı** (A'nın eforu, A/B varsayımı): 1 → 0 / 3 / 2, 2 → 0 / 7 / 3, 3 → 0 / 10 / 5.
- **Araştırma kartı** ("5 kullanıcıyla görüş"): yalnız Ürün aşaması, 5 puan.
- **Ücretli plan kartı:** 2 / 10 / 3.
- Örnekler: "Toplu Fatura" (ERP, deneyim, K2) 9 / 11 / 5 ister. "Nakit Öngörüsü" (inovasyon, K3) 6 / 26 / 8 ister.

### 2.3 Kim hangi aşamada, ne hızla çalışır
**Kişinin haftalık aşama puanı** = 10 × yıldız çarpanı × uyum × verim × saat × (1 − koordinasyon kaybı).
Yıldız çarpanı kişinin **o aşamanın alanındaki** puanından okunur: Tasarım → Tasarım, Geliştirme → Yazılım,
Test → Test, Ürün → Ürün.

| Yıldız (alan puanı) | 1★ (2) | 1,5★ (3) | 2★ (4) | 2,5★ (5) | 3★ (6) | 3,5★ (7) | 4★ (8) | 4,5★ (9) | 5★ (10) |
|---|---|---|---|---|---|---|---|---|---|
| Çarpan | 0,64 | 0,74 | 0,86 | 1,00 | 1,16 | 1,34 | 1,54 | 1,76 | 2,00 |
| Haftada (puan) | 6,4 | 7,4 | 8,6 | 10 | 11,6 | 13,4 | 15,4 | 17,6 | 20 |
| Bugün (aynı ölçekte) | 7,5 | 7,5 | 10 | 10 | 10 | 12,5 | 12,5 | 12,5 | 12,5 |

**Kim nerede çalışır: Ekip › Görevler matrisi.** Matris bugün var ama sprinti etkilemiyor. Artık etkiler:

| Rol | "Yapım ekibi" kutusu | "Test" kutusu |
|---|---|---|
| Kurucu (matriste yok) | Her aşama ×1,0 | (her aşama) |
| Ürün yöneticisi | Hazırlık ×1,0 (sprint dışı, §2.7), araştırma kartı ×1,0 | Test ×0,4 (uymayan) |
| Tasarımcı | Tasarım ×1,0, araştırma kartı ×0,7 | Test ×0,4 (uymayan) |
| Geliştirici | Geliştirme ×1,0 | Test ×0,7 (ikincil) |
| Testçi | Geliştirme ×0,7 (ikincil) | Test ×1,0 |

- Varsayılan iş bugünkü gibidir: herkes ana işinde. Geliştirici yalnız Yapım'da, testçi yalnız Test'tedir.
- Oyuncu geliştiriciye Test kutusunu işaretlerse geliştirici geliştirmeden artan zamanında ×0,7 ile test eder.
  Testçiye Yapım kutusunu işaretlerse testçi test işi yokken ×0,7 ile geliştirir.
- **Uymayan iş (×0,4):** Yalnız PM'in ve tasarımcının Test kutusu. Bugün bu kutu kesikli ve kapalı; açılır ve uyarı
  stiliyle çizilir.
- **Tasarım ile Geliştirme arasında uymayan iş yoktur:** geliştirici tasarım yapmaz, tasarımcı kod yazmaz. Matriste
  ikisini ayıran kutu yok; tasarımcısız ekipte tasarımı kurucu yapar.
- Motor uymayan işi kimseye kendiliğinden vermez. Aynı aşamada önce ana alanlı, sonra ikincil, en son oyuncunun
  bilerek koyduğu uymayan kişi çalışır.
- **Moral:** Uymayan işte geçen her hafta o kişinin morali −2 olur [ÇALIŞMA]. İkincil işin moral bedeli yoktur.
  (inceleme) Bedel sprint kapanışında topluca yazılır (uymayan işte çalıştığı hafta × −2). Sprint içinde moral, dolayısıyla
  verim değişmez; plan ekranının tahmini bozulmaz.
- **İki işli kişi:** Sprint dışı bir iş de tutan (Destek, Hesap, Satış) kişi sprinte haftasının yarısını verir.
  Ekip modülünün §12.1 "iki iş odağı böler" kuralı budur. Bugünkü çift sayım biter.

### 2.4 Ekip büyüklüğü (koordinasyon)
- **n** = sprintte puan üreten kişi sayısı, kurucu dahil. PM yalnız Test'e konduysa sayılır.
- **Kayıp** = %1 × (n − 3), n 3'ten büyükse; tavan %25 [ÇALIŞMA].
- **PM kapsamı:** Her PM 8 kişiyi kapsar; kapsanan kişilerin kaybı yarıya iner [ÇALIŞMA].

| n | 3 | 4 | 5 | 6 | 8 | 10 | 12 | 15 | 20 | 28+ |
|---|---|---|---|---|---|---|---|---|---|---|
| Kayıp | %0 | %1 | %2 | %3 | %5 | %7 | %9 | %12 | %17 | %25 |
| 1 PM ile | %0 | %0,5 | %1 | %1,5 | %2,5 | %4,2 | %6 | %8,8 | %13,6 | %21,4 |

- Ekibe kişi eklemek toplam çıktıyı her zaman artırır; kayıp 28 kişide %25 tavanına varır. "Kişi başı %5" ve
  "3'ü aşana −%6" gibi sert bir uçurum yoktur.

### 2.5 Kartın süresi
- Kart her aşamadan tam olarak ihtiyacı kadar puan alır. Aşamalar sırayla biter: tasarım bitmeden geliştirme,
  geliştirme bitmeden test başlamaz. Aynı hafta içinde bir aşamadan ötekine geçebilir.
- **Süre, plan ekranının haftalık oynatmasıdır.** Bugünkü motor bunu zaten yapıyor; yalnız puanlar aşamaya göre
  ayrılır. Kabaca: Tasarım ihtiyacı ÷ tasarımcının haftası + Geliştirme ÷ geliştiricilerin haftası + Test ÷ testçinin
  haftası.
- **Örnek:** "Nakit Akış Tablosu" (K2, inovasyon, 4 / 16 / 5). 3★ tasarımcı 0,3 haftada, 3★ ve 1,5★ iki geliştirici
  (11,6 + 7,4 = 19) 0,85 haftada, 2,5★ testçi 0,5 haftada bitirir. Kart 2. haftanın içinde biter. Tek başına kurucu
  aynı kartı 25 ÷ 10 = 2,5 haftada, yani 3. haftada bitirir.

### 2.6 Testçi ve hata ihtimali
- Biten her kart, kapanışta bir kez hata zarına girer. Hata çıkarsa A onu kartın hattına yazar (A/B varsayımı).
- **Hata ihtimali** = %2 + %12 × (1 − test kalitesi) [ÇALIŞMA]. Kart Hazır ise × 0,75.
- **Test kalitesi:** testi kim yaptıysa onun etkinliğinin, yaptığı test puanıyla ağırlıklı ortalaması.
  Etkinlik = Test yıldız çarpanı × uyum ÷ 2, en çok 1. Payda kartın ilk test ihtiyacıdır: test kısaltılırsa kalite
  düşer.
- %2'lik taban bilinçlidir: testler hatanın hepsini yakalamaz (araştırma §4).

| Testi kim yaptı | Etkinlik | Hata ihtimali | Hazır kartta |
|---|---|---|---|
| Kimse (test atlandı) | 0 | %14 | %10,5 |
| PM 1★, uymayan ×0,4 | 0,13 | %12,4 | %9,3 |
| Kurucu, Test 0★ | 0,25 | %11 | %8,3 |
| Geliştirici 2★, ikincil ×0,7 | 0,30 | %10,4 | %7,8 |
| Testçi 2★ | 0,43 | %8,8 | %6,6 |
| Testçi 3★ | 0,58 | %7,0 | %5,3 |
| Testçi 4★ | 0,77 | %4,8 | %3,6 |
| Testçi 5★ | 1,00 | %2,0 | %1,5 |

- Bugün: testçisiz %40, testçili %0. Tur 2'nin önerisi %19 ve %11 idi. Yeni oranlar ikisinden de düşüktür.
- **Gösterim:** Plan ekranının Test satırında sprintin kart başı ortalaması, kartın ipucunda kartın kendi sayısı yazar
  (açık soru 4).

### 2.7 PM önden gider: Hazırlık
**Cevaplar (Erdem'in soruları):**
- **Gerçekçi mi?** Evet. Gerçek ekiplerde ürün tarafı teslim ekibinin 1–2 sprint önünde çalışır ve sprinte "hazır"
  iş getirir (dual track, backlog refinement). Araştırma §4'te.
- **Bu oyun için fazla mı?** Ayrı bir ekran ve takvimle sayılan "iki aylık" iş fazladır. 6 kişilik ekip, büyük bir
  özelliği oyunda 1–2 haftada bitiriyor; PM aynı özelliği 8 haftada hazırlasaydı ekip boş beklerdi. Sade hâli fazla
  değildir: yeni ekran yok, var olan sonraki sprint sütunu ve Çeyrek kullanılır.
- **Nasıl harmanlanır?** PM'in haftası "hazırlık puanı"dır ve sprint kapasitesine girmez. Sprint koşarken sıradaki
  kartlara dökülür.
- **Gerek var mı?** Evet. PM sprint puanı üretmeyince başka bir değeri olmalı. Çeyrek tek başına bir maaşı
  karşılamaz.
- **PM'siz ekip:** Hazırlık yok, ceza da yok. Tek başına kurucu bugünkü hızındadır. Oyun kilitlenmez.

**Kural:**
- Kartın **hazırlık ihtiyacı** kademesine ve eksenine bağlıdır. 3★ PM haftada 11,6 hazırlık puanı üretir.

| | Kararlılık | Deneyim | İnovasyon |
|---|---|---|---|
| K1 | 2 (3★ PM ile ~1 gün) | 3 | 4 (~2 gün) |
| K2 | 4 | 5 | 6 (~3 gün) |
| K3 | 8 | 10 | 14 (~1,2 hafta) |

  Erdem'in örneğindeki oran ("küçük iş bir hafta, büyük iş iki ay", 1'e 8) korunur: en küçük iş 2, en büyük iş 14
  puandır (1'e 7). Mutlak süre oyunun zamanına sıkıştırılmıştır (açık soru 3).
- **Sıra:** Önce sonraki sprint sütunundaki kartlar, sonra onaylı Çeyrek planlarının kartları, sonra PM'in önerdiği
  plan. Düzeltme ve araştırma kartı hazırlanmaz. Başlamış kart hazırlanmaz.
- **Hazırlık yalnız sprint koşarken ilerler.** PM'in haftası önce Test'te işi varsa oraya, kalanı hazırlığa gider.
- **Hazır kart:** sprint başlarken sabitlenir. Her aşamanın ihtiyacı %20 azalır (tam sayıya yuvarlanır) ve hata ihtimali
  × 0,75 olur [ÇALIŞMA]. Örnek: Toplu Fatura 9 / 11 / 5 → 7 / 9 / 4.
- Bir PM yaklaşık 5 üreten kişinin işini hazırlayabilir. 12 kişilik ekipte 2 PM gerekir.

### 2.8 Kurucunun payı ve yıldızı
- **Hız:** Kurucunun her aşamadaki çarpanı en az 1,0'dır; alanında 2,5★ üstündeyse yıldızı geçerlidir
  (3★ Yazılım → geliştirmede ×1,16). Uyum her yerde ×1,0 [ÇALIŞMA].
- Neden: Kurucu her şeyi yapar. Taban olmasaydı Satış'a puan veren kurucuyla MVP 6. haftadan 9. haftaya kayardı.
- **Kalite:** Hata ihtimalinde kurucunun gerçek Test yıldızı okunur (Test 0★ → %11). Test bilmeyen kurucu hızlı test
  eder ama iyi test etmez.
- **Kurucunun sprint payı:** 1 − (o haftaki toplantı saati ÷ 40). Yatırımcı hazırlığı haftasında pay 0'dır.
  B'nin "Kendin bak" gibi seçenekleri kurucuya verim satırı yazar; o da bu formülün verim çarpanından geçer
  (A/B varsayımı).
  (inceleme) B yatırımcı hazırlığını kaldırmayı öneriyor (B sahip sorusu 1). Kalkarsa "hazırlık haftası 0" terimi yoktur;
  pay yalnız toplantı saatidir. C'nin sözleşme yenileme görüşmeleri de kurucuya saat yazar (C: hesap başına 2 saat,
  haftada en çok 24); o hafta kurucunun sprint payı %40'a kadar iner. Bu bilinçlidir: kurucu masadayken kod yazmaz.
- (inceleme) Kurucunun tek işi (bot Destek'e geçirebiliyor) sprint payını değiştirmez: kurucu Ar-Ge, izin ve eğitim
  dışında her zaman sprint ekibindedir (bugünkü gibi). A K1 yalnız pasif ilgiyi kapatıyor; açık Destek işi olan kurucunun
  hem masada hem sprintte sayılması yalnız botta oluşur (`run_probe.gd:1089`) ve bu fazın kapsamı dışında bırakılır.

### 2.9 Dört ekip için örnek (2 haftalık sprint)
Simülatör motorun atama ve oynatma kuralının kopyasıdır: `scratchpad/dprobe/sim.py`. Sayılar [ÇALIŞMA].
Kurucu her örnekte aynıdır: Ürün 2★, Yazılım 2★, Tasarım ve Test 0★ (debug kurucusu).

**1) Tek kurucu.** Her aşamada haftada 10. Kapasite 20.

| Kart | İhtiyaç (Tas/Gel/Test) | Sonuç | Hata |
|---|---|---|---|
| Hızlı Not (K1, inovasyon) | 2 / 10 / 3 | 2. hafta biter | %11 |
| Bulut Eşitleme (K1, kararlılık) | 2 / 8 / 5 | 5/15 devreder | - |

Bugünkü modelle aynı. MVP 6–7. hafta değişmez. (inceleme) Hız aynı; fark hatada: bugün kart hiç hatalı çıkmıyor,
yeni modelde kurucunun test ettiği her kart %11 taşır. MVP'nin 3 K1 kartında ortalama 0,3 hata v1.0'da açılır (A'nın
`pending_faulty` yolu); sonrasında her özellik kartı ~0,1 hata getirir.

**2) Kurucu + Deniz (Geliştirici 3★) + Ece (Tasarımcı 2★).** Haftada: Ece Tasarım 8,6, Deniz Geliştirme 11,6, kurucu
her aşamada 10. n = 3, kayıp yok.

| Kart | İhtiyaç | Kim | Sonuç | Hata |
|---|---|---|---|---|
| Metin Editörü (K1, deneyim) | 5 / 7 / 3 | Ece, Deniz, kurucu test | 1. hafta | %11 |
| Not Bağlantısı (K1, inovasyon) | 2 / 10 / 3 | Kurucu, Deniz | 2. hafta | %11 |
| Bulut Eşitleme (K1, kararlılık) | 2 / 8 / 5 | Ece, Deniz, kurucu test | 2. hafta | %11 |

45/60 puan iş, 1,7 kişi-hafta boş. Bugün de üç kart biter. Fark: testi kurucu yapıyor, her kartta %11 ihtimal
görünür. Deniz'e Test kutusu işaretlenirse ihtimal %9,8'e iner.

**3) 6 kişi:** kurucu, Selin (PM 3★), Ece (Tasarımcı 3★), Deniz (Geliştirici 3,5★), Mert (Geliştirici 1,5★),
Ayşe (Testçi 2,5★). n = 5, kayıp %2, Selin ile %1. Haftada: Tasarım 11,5 + kurucu, Geliştirme 13,3 + 7,3 + kurucu,
Test 9,9 + kurucu.

| Kart | İhtiyaç | Hazırlıksız | Selin ilk 3'ünü hazırladıysa |
|---|---|---|---|
| Toplu Fatura (K2, deneyim) | 9 / 11 / 5 → 7 / 9 / 4 | 1. hafta, %8 | 1. hafta, %6 |
| Nakit Akış Tablosu (K2, inovasyon) | 4 / 16 / 5 → 3 / 13 / 4 | 2. hafta, %8 | 1. hafta, %6 |
| Hesap Planı (K2, kararlılık) | 3 / 13 / 9 → 2 / 10 / 7 | devreder (21/25) | 2. hafta, %6 |
| Stok Sayacı (K1, deneyim) | 5 / 7 / 3 | devreder (12/15) | 2. hafta, %11 |
| Faturalama düzelt · 4 hata | 0 / 7 / 3 | devreder (7/10) | devreder (9,8/10) |
| **Biten kart** | | **2** | **4** |

Selin iki haftada 23 hazırlık puanı üretir; üç K2 kartın hazırlığı 5 + 6 + 4 = 15'tir. Bugünkü model aynı ekiple
4 kart bitiriyor (Selin bugün tasarımda 2 puan üretiyor, Deniz ve Mert test de yapıyor). **Hazırlık yapan PM, puan
üreten PM'in yerini tutar; hazırlık yapmayan PM boşa maaştır.**

**4) 12 kişi:** kurucu, 2 PM (3★, 2★), 2 tasarımcı (3★, 2★), 5 geliştirici (4★, 3★, 3★, 2★, 1,5★), 2 testçi (3★, 2★).
n = 10, kayıp %7, 2 PM ile %3,5. PM'ler sprint başına 40 hazırlık puanı üretir. İlk altı kartın 43 puanlık hazırlığı
önceki sprintlerde bitti; Mobil sıraya yetişmedi.

| Kart | İhtiyaç (hazır) | Sonuç | Hata |
|---|---|---|---|
| Nakit Öngörüsü (K3, inovasyon) | 5 / 21 / 6 | 1. hafta | %5,3 |
| Tahsilat Döngüsü (K3, deneyim) | 11 / 14 / 6 | 1. hafta | %6,6 |
| Depo ve Raf (K2, deneyim) | 7 / 9 / 4 | 1. hafta | %5,3 |
| Tablo İçe Aktarma (K2, inovasyon) | 3 / 13 / 4 | 2. hafta | %5,3 |
| Hesap Planı (K2, kararlılık) | 2 / 10 / 7 | 2. hafta | %6,6 |
| Güvenlik (K2, kararlılık) | 2 / 10 / 7 | 2. hafta | %5,3 |
| Stok düzelt · 7 hata | 0 / 10 / 5 | devreder (14,99/15) (inceleme: simülatör 0,01 eksik bırakıyor; sınır vakası) | - |
| Mobil (K1, deneyim, hazır değil) | 5 / 7 / 3 | devreder (12/15) | - |

Darboğaz Test'tir: iki testçi 39 puan yapar, ihtiyaç 42. Plan ekranı bunu Test satırında gösterir. Bugünkü model
aynı ekiple 6 kart bitiriyor.

**Toplam çıktı karşılaştırması (sprint başına puan, aynı ölçekte):**

| Ekip | Bugün kapasite | Yeni kapasite | Yeni, hazırlıkla eşdeğer |
|---|---|---|---|
| Tek kurucu | 20 | 20 | 20 |
| Kurucu + 2 | 60 | 60 | 60 |
| 6 kişi (PM'li) | 120 | 104 | ~130 |
| 12 kişi (2 PM) | 240 | 203 | ~250 |

### 2.10 Ekranlar
**T1 · Plan ekranı, orta sütun (§2.9'un 6 kişilik ekibi, Selin üç kartı hazırlamış).** Tek kapasite çubuğu yerine üç
aşama satırı gelir. Sayılar: sprintte yapılacak / ihtiyaç.
```
BU SPRINT 7                                  [1 hafta | 2 hafta]
TASARIM      ████████████████████   17/17
GELİŞTİRME   ████████████████████   46/46
TEST         ███████████████████░   20/21   1 devreder · hata %7
Koordinasyon −%1 · 5 kişi
(Kurucu) (Ece) (Deniz) (Mert) (Ayşe)
────────────────────────────────────────────────────────────────
┌ Toplu Fatura                                          HAZIR ┐
│ Tasarım 7 · Geliştirme 9 · Test 4                            │
│ Ece ▸ Deniz ▸ Ayşe                               1. hafta    │
└──────────────────────────────────────────────────────────────┘
┌ Stok Sayacı                                                 ┐
│ Tasarım 5 · Geliştirme 7 · Test 3                            │
│ Ece ▸ Kurucu                                     2. hafta    │
└──────────────────────────────────────────────────────────────┘
┌ Faturalama düzelt · 4 hata · 3 hesap           devreder 9/10 ┐
│ Geliştirme 7 · Test 3                                        │
└──────────────────────────────────────────────────────────────┘
```
Aynı ekipte oyuncu Selin'e Test kutusunu işaretlemişse ve Ayşe yetişemiyorsa kartta uyarı etiketi çıkar:
```
┌ Hesap Planı                                    TEST ×0,4  ⚠ ┐
│ Tasarım 2 · Geliştirme 10 · Test 7                           │
│ Ece ▸ Deniz ▸ Ayşe, Selin                        2. hafta    │
└──────────────────────────────────────────────────────────────┘
```
- (inceleme) **Gösterim kuralı:** ekranda ondalık yok. Yapılan puan aşağı, kalan yukarı yuvarlanır (0,2 eksik kalan
  kart "1 devreder" der, "bitti" demez); yüzde tam sayıdır. Motor tam sayı tutmaz, yalnız gösterim yuvarlar (bugünkü
  kural). ×5 ölçeğin asıl getirisi budur: yarım yıldızların haftalık puanı 6 · 7 · 9 · 10 · 12 · 13 · 15 · 18 · 20 olur,
  her basamak tam sayıyla ayrılır.
- Satırın ipucu ekibin o aşamadaki gücünü verir: "Geliştirme · haftada 30: Deniz ★★★½ 13 · Mert ★½ 7 · Kurucu
  10".
- Koordinasyon satırı yalnız kayıp varken çıkar. İpucu formülü söyler.
- "TEST ×0,4" etiketi kartı uymayan birinin test edeceğini söyler. İpucu: "Selin (Ürün yöneticisi) testte ×0,4 hızla
  çalışır, haftada 2 moral kaybeder."
- Bir aşamayı yapacak kimse yoksa (kurucu Ar-Ge'deyken tasarım gibi) satır uyarı rengindedir: "Tasarım yapacak kimse
  yok".
- "Ekipte Test yok · kartlar hatalı çıkabilir" satırı kalkar; yerine Test satırındaki sayı gelir.

**T2 · Kartın üstüne gelince (efor kutusu).**
```
Hazır · 25 → 20 puan · hata %8 → %6          (inceleme: "hata ¾" yerine sayı)
Ece       Tasarım 7      1 hafta
Deniz     Geliştirme 9   1 hafta
Ayşe      Test 4         1 hafta
```

**T3 · Sonraki sprint sütunu (dar kart) ve PM.**
```
SONRAKİ SPRİNT 8                                   (Selin) Hazırlık
┌ Depo ve Raf          25 ┐   ┌ Tablo İçe Aktarma     25 ┐
│ Hazır · Tasarım %40     │   │ Hazırlık %50             │
└─────────────────────────┘   └──────────────────────────┘
```
- "Hazırlık %50": PM'in işi sürüyor. "Hazır": bitti.
- Tasarımcının önden yaptığı iş bugün "%40 hazır" ve "Geliştirmeye hazır" yazıyor. İki "hazır" karışmasın diye bu
  etiket "Tasarım %40" ve "Tasarımı bitti" olur.
- PM'in avatarının ipucu: "Selin hazırlıyor: Tablo İçe Aktarma (3/6). Sırada: Hesap Planı."
- Çeyrek görünümündeki küçük kartlarda yalnız "Hazır" işareti çıkar.

**T4 · Ekip › Görevler matrisi.**
```
                     Yapım ekibi   Test    Destek   Hesap   Satış   Araştırma
Selin · Ürün yön.        ■          ⬚ ×0,4    ⬚        ⬚       ⬚        ◌
Ece · Tasarımcı          ■          ⬚ ×0,4    ⬚        ⬚       ⬚        ◌
Deniz · Geliştirici      ■          □         □        ⬚       ⬚        ◌
Ayşe · Testçi            □          ■         ⬚        ⬚       ⬚        ◌
```
- "⬚ ×0,4" yeni uyarı kutusudur. İpucu: "Bu kişinin alanı değil: ×0,4 hızla çalışır, haftada 2 moral kaybeder."
- İkincil kutunun ipucu: "İkincil alan: ×0,7 hızla çalışır."
- Destek'e de atanmış kişinin sprint avatarının ipucu: "Destek ile paylaşıyor: sprintte haftanın yarısı."

**T5 · İşe alım dosyası (Atlas).** "Sprintte haftada 2 puan" yerine aşama aşama:
```
MAAŞ                                   $4.200 /ay
▣ Haftada: Geliştirme 12 · Test 7
```
- Örnek: Yazılım 3★, Test 2,5★ geliştirici. PM'de "Haftada: Hazırlık 12", tasarımcıda "Haftada: Tasarım 12",
  testçide (Test 3★, Yazılım 2,5★) "Haftada: Test 12 · Geliştirme 7" yazar (inceleme: tam sayı). İkincil sayı ×0,7'li hâlidir ve yalnız
  o kutu işaretlenince işler.

**T6 · Mesai penceresi.** "Haftalık sprint puanı 52 → 60" satırı kalır; sayı herkesin ana aşamasındaki haftalık puanının
toplamıdır.

---

## 3. İzlenebilirlik

| Karar ya da görev maddesi | Planda nerede |
|---|---|
| Geliştirici geliştirme, tasarımcı tasarım, testçi test puanı üretir | §2.3, §5.1 |
| Kart ihtiyacını nasıl söyler, aşama başına puan mı | §2.2: evet, üç ayrı puan; tablo |
| Ekibin aşama kapasitesi kartın süresine nasıl çevrilir | §2.5, §2.9 |
| Oyuncu bunu nasıl görür | §2.10 T1–T3 |
| GDT, Software Inc., MGT2, Startup Company araştırması | §4 |
| Yıldız tablosu ×0,64 … ×2,0, 5'e kadar, yarım yıldız ara değer | §2.3 tablosu; Y(s) formülü §5.1 |
| 5★ ×2,0 kalibrasyonda bakılır | §7 D6 ölçümü, §5.3 onay listesi |
| Uyum 1,0 / 0,7 / 0,4 | §2.3 |
| ×0,3 ya da hiç çalışamama değerlendirilir | §2.3: Test'te ×0,4 korunur; Tasarım ile Geliştirme arasında hiç çalışamaz. Açık soru 2 |
| Atama anında verim kaybı ve moral görünür | §2.10 T1 etiketi, T4 kutu ve ipucu; moral −2/hafta §2.3 |
| Ekip cezası kademeli, kişi başı %5 fazla, "5 kişiye kadar %2" | §2.4: %1 × (n − 3), 5 kişide %2 |
| Kalibrasyonla ayar | §7 D6 |
| Testçi hata ihtimalini düşürür; %19/%11 ve %40 yüksek | §2.6: %2–%14 |
| Test yıldızı olan ikincil rolde test eder; test yıldızı olmayan uymayana düşer | §2.3 tablo (geliştirici ×0,7, PM ×0,4) |
| Oranlar oyuncuya gösterilsin mi | §2.6 gösterim; açık soru 4 |
| PM puan üretmez | §2.3: PM sprint puanı üretmez; yalnız araştırma kartı ve oyuncu Test'e koyarsa |
| PM koordinasyon kaybını azaltır | §2.4 PM kapsamı |
| PM Çeyrek'i açar | Değişmez (bugün öyle); §2.10 T3'te Hazır işareti |
| PM karar kâğıtlarına PM sorusu ekler | B'nin işi; D seam'i verir (§5.4, A/B varsayımı) |
| PM önden gider; küçük iş 1 hafta, büyük iş 2 ay; tasarım karmaşıklığı; ayrı akış mı | §2.7, §2.2 |
| Gerçekçi mi, fazla mı, nasıl harmanlanır, gerek var mı | §2.7 cevaplar |
| PM'siz ekip, erken oyunda kilitlenmemeli | §2.7 son madde, §2.9 örnek 1–2 |
| Bedel kabul, ucuz yedek yok | §7: yedek önerilmedi; PM hazırlığı ayrı commit (D5) |
| Plan ekranındaki tahmin sonuçla aynı | §5.5 |
| Kurucunun sprint payı ve yıldızı | §2.8; açık soru 1 |
| İşe alım dosyasında puan gösterimi | §2.10 T5 |
| Kayıt şeması ve eski kayıt | §5.6 |
| Bot koşusuyla bugün ve önerilen karşılaştırma; MVP ~6. hafta | §1 ölçüm, §2.9, §7 D0 ve D6 |
| 4, 5 ve 6 puanlık kişi aynı puanı üretiyor | §2.3 tablosu |
| A: düzeltme kartı eforu (1, 2, 3) aşama modeline uyar | §2.2: 1 → 0/3/2, 2 → 0/7/3, 3 → 0/10/5 |
| B: "Sürüm sonrası bozulma" D'nin hata ihtimalini kullanır | §5.4 okuma noktası |
| Ürün karmaşıklığı A'da silinir; özelliğe tasarım karmaşıklığı D'ye | §2.2 eksen payı, §2.7 hazırlık ihtiyacı |
| Verim eğrisi yeniden tasarlanmaz, yalnız okunur | §2.3 formülünde "verim × saat" olduğu gibi |
| Kurucunun zamanı: olay bedeli B'nin, sprint payı D'nin | §2.8 |

Karşılanmayan madde yok.

---

## 4. Araştırma bulguları
Kaynaklar `D_ARASTIRMA.md` ve `../sprint/T2_3_games.md`'de. Kısa:

- **Game Dev Tycoon:** Üretim Design ve Technology puanı olarak ikiye ayrılır; her geliştirme alanının bir
  Design/Technology oranı vardır (örn. motor 180 D + 720 T, diyalog 810 D + 90 T). (gamedevtycoon.fandom.com/wiki/Training,
  steamcommunity 239820) **Etkisi:** Kartın aşama payı eksene göre değişir (§2.2).
- **Mad Games Tycoon 2:** Oyunun her istatistiği ayrı asgari puan ister, biri ötekini kapatmaz; QA odasında yalnız
  tester iyi iş yapar; efsanevi çalışan ~2–2,5 kat iş yapar. (steamcommunity 1342330, topluluk, doğrulanmamış)
  **Etkisi:** Aşamalar birbirini kapatmaz; 5★ ×2,0 makul aralıkta; uymayan iş cezalı ama yasak değil.
- **Software Inc.:** Tür ve yıl başına önerilen tasarımcı / programcı / sanatçı sayısı açıkça yazılır; lider becerisiz
  rolde yarı kapasiteyle çalışır; takım için öneri 10–12 kişi. (softwareinc.coredumping.com/wiki/index.php/Teams)
  **Etkisi:** Plan ekranı ekibin aşama gücünü açıkça yazar (T1); PM kapsamı 8 kişi.
- **Startup Company ve Big Ambitions:** Formül düzeyinde kaynak bulunamadı. Karar etkisi yok.
- **Brooks yasası:** İletişim kanalı n(n−1)/2; her kişinin kanal sayısı n−1'dir, yani kişi başı yük n ile doğrusal
  büyür. (en.wikipedia.org/wiki/The_Mythical_Man-Month) **Etkisi:** Kayıp %1 × (n − 3), doğrudan n² ceza değil.
  Eşik 3: Scrum'un 3–9 kişilik ekip sezgisi.
- **Dual track ve backlog refinement:** Keşif teslimin 1–2 sprint önünde gider; 1–2 sprintlik "Ready" iş bulundurmak
  yaygın öneridir, Scrum Guide kuralı değildir. (radar.zurb.com dual-track, scrum.org backlog refinement)
  **Etkisi:** PM'in sırası sonraki sütun ve Çeyrek (ufuk 3 sprint); "Hazır" etiketi.
- **Defect removal efficiency (Capers Jones):** ABD ortalaması ~%85; tüm testler birlikte nadiren %85'i aşar. Hata
  potansiyelinin yaklaşık %45'i gereksinim ve tasarımdan doğar (5 hata/FP içinde 1,00 + 1,25). (ppi-int.com DRE pdf)
  **Etkisi:** Hata ihtimalinin %2 tabanı (test her şeyi yakalamaz) ve Hazır kartın hata ihtimalini dörtte bir düşürmesi.
- **QA'lı ve QA'sız ekip karşılaştıran güvenilir kaynak bulunamadı.** Oranlar mutlak değil sıralı tasarlandı: test yok >
  kurucu > ikincil geliştirici > testçi > iyi testçi + hazır kart.

---

## 5. Model

### 5.1 Formüller
```
Y(s)        = 0,5 + 0,05·s + 0,01·s²                       s = kişinin o aşamanın alanındaki puanı (0–10)
U(rol, a)   = 1,0 ana · 0,7 ikincil · 0,4 uymayan          kurucu her aşamada 1,0
P(kişi, a)  = 10 · Y · U · verim · saat · (1 − K) · iş payı
  kurucu:   Y = max(1,0; Y(s)),  iş payı = 1 − toplantı saati/40 (yatırım hazırlığı haftası 0)
  çalışan:  iş payı = sprint işleri / tuttuğu sürekli işler (Yapım+Destek → 0,5)
K(n)        = min(0,25; 0,01·max(0; n − 3))
K_etkin     = K(n) · (1 − 0,5 · min(1; 8·PM_sayısı / n))
İhtiyaç     = tablo[kademe, eksen] (düzeltme: tablo[A'nın eforu]); Hazır kartta her aşama round(×0,8), en az 1
Hazırlık    = PM'in haftası: 10 · Y(Ürün) · verim · saat · (Test'te kalmayan zaman payı)
Etkinlik    = min(1; Y(Test puanı) · U / 2)                kurucuda da gerçek Test puanı
t           = Σ(test puanı_i · etkinlik_i) / kartın ilk test ihtiyacı,  en çok 1
p(hata)     = (0,02 + 0,12·(1 − t)) · (0,75 Hazır ise)
Zar         = hash(kart, sprint) % 1000 / 1000 < p         bugünkü gibi deterministik
```
- Kişinin haftası bir **zaman bütçesidir** (1 hafta). Motor her aşamaya kişinin o aşamadaki hızıyla döker. Bugünkü
  `_work` "bütçe × hız" ile aynı işi yapar; değişen, hızın aşamaya ve kişiye göre okunmasıdır.
- Atama sırası: kartın sıradaki aşamasında önce uyumu yüksek kişi, sonra zamanı çok kalan, sonra kimlik sırası.
- Tasarımcı bugünkü gibi önden gider (sonraki sütunun tasarımı). PM'in önden gitmesi ayrı bir havuzdur (hazırlık).
- (inceleme) Kurucunun toplantı payı yeni bir sayaç değildir: `1 − GameState.founder_meeting_share()` (Ar-Ge'nin bugün
  okuduğu fonksiyon). Gün tiki hafta başı sıfırlamasından önce koştuğu için `_end_week` biten haftanın payını okur.
- (inceleme) `t`'nin paydası: kartın sprint başındaki test ihtiyacı, karar fiillerinin efor değişiklikleri dahil, B'nin
  "Testi kısalt" kesintisi hariç. Kesinti `need_mod`'a değil ayrı bir alana yazılır (örn. `test_cut_pts`); yoksa payda da
  küçülür ve kısaltma kaliteyi düşürmez.
- (inceleme) `decision_progress` bugün `_work`'e sahte bir kişi verir (`fits` = kartın rolleri, hız 1). Yeni `_work`'te bu
  kişi her aşamada hız 1,0 taşır; miktar puan olarak doğrudan düşer.

### 5.2 Sabitler (`data/product/sprint.json`)
| Anahtar | Değer | Yerine geçtiği |
|---|---|---|
| `point_base` | 10 | `person_points_week` 2 |
| `star_curve` | [0,5; 0,05; 0,01] | `skill.low_max/mid_max/mult` |
| `fit` | {key 1,0, sec 0,7, none 0,4} | `no_role_speed` 0,5 |
| `founder_floor` | 1,0 | `founder_mult` 1,0 |
| `need` | kademe × eksen tablosu, `fix` 1/2/3, `research`, `paid_plan` | `effort`, `shares` |
| `coord` | {free 3, per 0,01, cap 0,25, pm_reach 8, pm_cut 0,5} | yok |
| `escape` | {floor 0,02, span 0,12, ready 0,75} | `faulty_chance` 0,4 |
| `prep` | K1 [2,3,4], K2 [4,5,6], K3 [8,10,14] (kararlılık, deneyim, inovasyon) | yok |
| `ready_cut` | 0,8 | yok |
| `unfit_morale` | −2 / hafta | yok |

### 5.3 Onay bekliyor
1. Ölçek ×5: kişi haftada 10, K1 15, K2 25, K3 40 (açık soru 5).
2. Kart ihtiyaç tablosu ve eksen payları (deneyim 35/45/20, inovasyon 15/65/20, kararlılık 10/55/35).
3. Düzeltme kartı ihtiyacı 0/3/2, 0/7/3, 0/10/5.
4. Kurucu tabanı Y ≥ 1,0 (açık soru 1).
5. Uymayan iş yalnız Test'te, ×0,4, moral −2/hafta (açık soru 2).
6. Koordinasyon: eşik 3, kişi başı %1, tavan %25; PM 8 kişiyi kapsar, kaybı yarıya indirir.
7. Hata ihtimali: taban %2, açıklık %12, Hazır × 0,75.
8. Hazırlık tablosu ve Hazır kartta %20 az iş (açık soru 3).
9. 5★ ×2,0: D6'da 5★ ile 3★ geliştiricinin maaş başına puanı karşılaştırılır.
10. Ekip modülünün Destek ve Ar-Ge'deki ikincil katsayısı (`HRConstants.SECONDARY_AREA_MULT` 0,8) değişmez; sprint
    0,7 kullanır. İkisinin tek sayıya inmesi ayrı bir karardır.

### 5.4 Fazlar arası okuma noktaları
- **A (A/B varsayımı):** Düzeltme kartı eforunu 1, 2 ya da 3 olarak taşır (`sprint.json` `effort.fix*` ya da kartta
  seviye). D bunu `need.fix` tablosuna çevirir. Hatalı kapanan kartın hattı A'nın `_close` içindeki yazımıyla gider;
  D yalnız zarı ve ihtimali değiştirir.
- **B (A/B varsayımı):**
  - Karar kâğıtlarının `sprint_card_effort` ve `sprint_card_progress` miktarları bugünkü ölçekte yazılır. D bunları ×5
    yapar ve fiile isteğe bağlı `phase` alanı ekler. Alan yoksa miktar kartın o anki aşamasına düşer (kâğıdı o aşamadaki
    kişi konuşur).
  - "Testi kısalt" test ihtiyacını düşürür. Kalite paydası ilk test ihtiyacı olduğu için hata ihtimali kendiliğinden
    artar; B ayrı bir ihtimal eki yazmaz.
  - "Kendin bak" kurucuya `productivity_mod` yazar; §2.8 bunu okur.
  - "Sürüm sonrası bozulma" D'nin `SprintSystem.escape_chance(card)` okumasını ve kapanıştaki hatalı hat listesini
    okur.
  - PM sorusu için seam: `urun.card_ready(kart)` ve `urun.has_pm` (`seams_product.gd`).
  - B yatırımcı hazırlığını kaldırırsa §2.8'in "hazırlık haftası 0" terimi düşer.
  - (inceleme) Dış geliştiricinin "puan başı $1.000"u ×5 ölçekte $200 olur (B §5.6 listesi).
  - (inceleme) K6 "Testi sen yap" (`covered`, kurucu verimi −%20): D'de testi yapanın gerçek Test yıldızı okunur. Test 0★
    kurucu %11 verir, ikincil rolde test eden 2★ geliştirici %10,4. Kurucunun Test yıldızı yoksa bu seçenek bedel öder,
    karşılık almaz ("bedava çıkış yok" kuralının tersi: bedelli boş seçenek). D tazelemesinde B'ye geri döner: seçenek
    yalnız kurucunun test etkinliği geliştiricininkinden yüksekken açılır ya da başka bir karşılık taşır.
  - (inceleme) "Hazırlık" sözcüğü bugün yatırımcı hazırlığında da kullanılıyor (`HUNT_PREP_*`). B'nin önerisiyle hazırlık
    kalkarsa çakışma yok; kalırsa PM'in kelimesi "Hazırlık" yerine başka bir sözcük olur (öneri: "Ön çalışma").
- **C (inceleme: C varsayımı):** C, D'den önce uygulanır ve ürün penceresini üç kâğıda böler (`ProductTab.VIEW_KEYS`,
  yeni `overview_view.gd`). D4'ün dokunduğu plan ekranı C'den sonra SPRINT kâğıdıdır; dosya adları tazelemede okunur.
  C'nin `founder_hours` fiili `GameState.add_founder_meeting_hours`'a yazar, D o sayıyı okur (§2.8).

### 5.5 Tahmin = sonuç
- `plan_outcome`, `_end_week`, `mvp_eta`, `_takes` aynı `_play_out` ve `_work`'ü kullanır (bugün de öyle). Yeni girdiler
  ve sabitlenme anları:
  - Kişinin aşama hızları `team()`'de bir kez hesaplanır: yıldız, uyum, iş payı, koordinasyon. Koordinasyon sprint
    boyunca ekip değişmedikçe sabittir.
  - Hazır bayrağı ve Hazır ihtiyacı `_begin`'de karta yazılır, sprint boyunca değişmez.
  - Kurucunun toplantı payı: plan, bilinmeyen toplantıyı 0 sayar. O haftanın tikinde gerçek pay okunur.
  - Hata ihtimali: oynatma, test puanını kimin yaptığını kopyada biriktirir; plan ile kapanış aynı `t`'yi bulur.
- `--sprint-probe`:
  - `PRED` satırına kartın hata ihtimali eklenir; `CLOSE` aynı sayıyı karşılaştırır (EPS içinde).
  - Yeni adlı neden: `cause=founder_time` (sprintin haftalarında kurucunun toplantı ya da yatırımcı hazırlığı payı > 0).
  - Adsız uyuşmazlık yine çıkış 1'dir.
- `_takes` ("+"): eklenen kartın oynatmada puan alması şart olur. Bugün yalnız sprintin boş puanı soruluyor; aşama
  ayrılınca boş puan başka bir aşamada olabilir.
- (inceleme) **Kurucu payı yalnız içinde bulunulan haftaya uygulanır.** `_play_out` bugün bütün haftaları tek ekiple
  oynar; payı `team()`'e katmak bu haftanın toplantısını sprintin bütün haftalarına yayar. `_play_out` ilk hafta için
  ayrı bir ekip alır (paylı), sonraki haftalar paysız. `mvp_eta` mesai çarpanını nasıl ayıklıyorsa (`plain`) gelecek
  sprintlerde kurucu payını da öyle ayıklar.
- (inceleme) **Beşinci girdi, moral:** uymayan işin moral bedeli hafta hafta yazılsaydı verim sprint içinde değişir,
  tahmin ile sonuç ayrılırdı (probe bunu `cause=team` diye adlandırıp geçirirdi, oyuncunun ekranı yine yanlış kalırdı).
  Bu yüzden bedel kapanışta yazılır (§2.3).
- (inceleme) **Liderin ve PM'in önerisi** (`SprintCatalog._suggest`, `lead_suggestion`, PM planları) bugün tek sayılık
  kapasiteyle doldurur. Aşamalar ayrılınca bu, darboğaz aşamayı taşıran öneri üretebilir. D2a'da `_suggest` her adayı
  `_takes` ile (oynatarak) sınar; dosya D2a listesine eklendi.
- (inceleme) **PM'in sprintteki görünümü:** PM `team()`'den çıkınca `role_of(pm)` "" döner. Bunu üç yer okur: ofis
  (`office_people.gd:667`, PM kahvede görünür), Destek'in mail okuyanları (`support_system.gd:236`, PM Destek'e sayılır) ve
  deneyim (`hr_system.gd:84` `SprintSystem.worked`). Hazırlığı süren PM için `role_of` "product" döner (ofiste "plan"
  animasyonu zaten var) ve `worked` listesine girer; hazırlık kuyruğu boşsa "" döner.

### 5.6 Kayıt şeması
Şema numarası A ve B'nin kullandığından sonraki ilk sayıdır (A/B varsayımı: 16 ya da 17 alınmış olabilir).
(inceleme) Planlara göre kesin sıra: A 15 → 16 (`_migrate_16`); B ve C şemayı artırmaz (C planındaki "15 kalır" A'dan
önceki numarayı yazıyor, anlamı "artmaz"); **D 16 → 17** (`_migrate_17`); E sonra 17 → 18 ve, sahip sorusu onaylanırsa,
`MIN_LOADABLE_VERSION := 18` ile eski kayıtları kapatır. Yani D'nin göçü yalnız D ile E arasındaki kayıtlarda yaşar.
- **Kart:** `need` [3 tam sayı] ve `need_mod` [3 tam sayı] gelir; `shares`, `effort_mod`, `faulty` gider. `effort` taban
  toplam olarak kalır (sıralama okuyor). `ready` (bool) ve `test_q` (float) gelir, varsayılanı false ve 0.
- **Ürün:** `product.prep` {kart kimliği: hazırlık puanı} gelir, varsayılanı {}.
- **Göç:** Her saklı kartın ihtiyacı tablodan kurulur. Eski ilerleme aşama oranıyla taşınır:
  yeni ilerleme_a = (eski ilerleme_a ÷ eski pay_a × eski efor) × yeni ihtiyaç_a. `effort_mod` × 5 kartın o anki
  aşamasına yazılır. `sprint.capacity` ve `releases[*].velocity` × 5.
- **Davranış farkı (eski kayıtta):** Görevler matrisi artık sprinti etkiler. Test'i olmayan geliştirici test etmez;
  Yapım'ı olmayan testçi geliştirmez. Kayıt yüklenince ilk plan ekranı bunu satırlarla gösterir; ek göç yok.
- Karakterde yeni alan yok.

### 5.7 Silinecek kod
- `sprint.json`: `person_points_week`, `skill`, `founder_mult`, `no_role_speed`, `faulty_chance`, `effort`, `shares`.
- `SprintSystem.points_for` → `rates_for(rol, alanlar, saat)` ({aşama: haftalık puan}); `_points` aynı fonksiyondan.
- Kartın `faulty` bayrağı ve `_work`'teki "testçisiz test → faulty" dalı.
- `PRODUCT_ROLE_MISSING` (yerine Test satırı ve `PRODUCT_PHASE_NOBODY`), `HR_ATLAS_WEEK_POINTS`
  (yerine `HR_ATLAS_WEEK_RATES`).
- `team()`'in `ahead` tanımı "tasarım ya da ürün rolü" olmaktan çıkar: yalnız Tasarım aşaması olan kişi önden gider.
  PM `ahead` değildir; hazırlık havuzundadır.
- Smoke: `sprint_capacity_from_team`, `sprint_faulty_ticket_deterministic`, `sprint_card_effort`,
  `sprint_ceiling_125_blocks_add`, `sprint_departure_restaffs_card`, `sprint_save_roundtrip` ve `endgame_smoke.gd`
  17196, 18339 satırlarındaki vakalar yeni modele göre yazılır. `sprint_solo_mvp_by_week_six` değişmeden geçmeli.
  (inceleme, A/B varsayımı) A'nın yeni vakaları `sprint_faulty_pre_launch_lands_at_v1` ve `sprint_fix_card_clears_its_line`
  da D3'te `escape_chance`'e göre yeniden yazılır. Düzeltme kartının kendi kaçışı: A'nın kapanışı önce hattı sıfırlar,
  D'nin zarı sonra o hatta 1 hata yazar (sıra tersine dönerse kaçış silinir).

---

## 6. Metin taslakları
Önce İngilizce, Türkçe yeniden yazımdır. Tire yok. Hepsi "TR/EN onay bekliyor".

| Anahtar | EN | TR |
|---|---|---|
| `PRODUCT_PHASE_PREP` | Prep | Hazırlık |
| `PRODUCT_PHASE_PRODUCT` | Product | Ürün |
| `PRODUCT_PHASE_NEED` | {phase} {n} | {phase} {n} |
| `PRODUCT_PHASE_LEFT` | {n} carries over | {n} devreder |
| `PRODUCT_PHASE_SPARE` | {n} spare | {n} boş |
| `PRODUCT_PHASE_ESCAPE` | bug chance {pct} | hata ihtimali {pct} |
| `PRODUCT_PHASE_NOBODY` | Nobody on the team can do {phase} | Ekipte {phase} yapacak kimse yok |
| `PRODUCT_PHASE_TIP` | {phase} · {n} a week: {people} | {phase} · haftada {n}: {people} |
| `PRODUCT_COORDINATION` | Coordination {pct} · {n} people | Koordinasyon {pct} · {n} kişi |
| `PRODUCT_COORDINATION_TIP` | Up to three people work without overhead. Each person after that adds 1%. A product manager halves it for up to eight people. | Üç kişiye kadar koordinasyon kaybı yok. Sonraki her kişi %1 ekler. Ürün yöneticisi sekiz kişiye kadar bunu yarıya indirir. |
| `PRODUCT_CARD_FIT` | {phase} ×{mult} | {phase} ×{mult} |
| `PRODUCT_CARD_FIT_TIP` | {name} ({role}) works at ×{mult} here and loses 2 morale a week. | {name} ({role}) burada ×{mult} hızla çalışır ve haftada 2 moral kaybeder. |
| `PRODUCT_CARD_ESCAPE` | Bug chance {pct} | Hata ihtimali {pct} |
| `PRODUCT_CARD_PREP_PCT` | Prep {pct} | Hazırlık {pct} |
| `PRODUCT_CARD_PREPPED` | Ready | Hazır |
| `PRODUCT_CARD_PREPPED_TIP` (inceleme: sayı) | Prepared: {from} → {to} points, bug chance {p_from} → {p_to}. | Hazırlandı: {from} → {to} puan, hata ihtimali {p_from} → {p_to}. |
| `PRODUCT_CARD_READY` (değişir) | Design done | Tasarımı bitti |
| `PRODUCT_CARD_READY_PCT` (değişir) | Design {pct} | Tasarım {pct} |
| `PRODUCT_PREP_TIP` | {name} is preparing {card} ({done}/{need}). Next: {next}. | {name} hazırlıyor: {card} ({done}/{need}). Sırada: {next}. |
| `PRODUCT_SHARED_JOB` | Shares the week with {job}: half of it goes to the sprint. | {job} ile paylaşıyor: haftanın yarısı sprinte gider. |
| `HR_ASSIGN_UNFIT` | Not this person's area: works at ×0.4 and loses 2 morale a week. | Bu kişinin alanı değil: ×0,4 hızla çalışır, haftada 2 moral kaybeder. |
| `HR_ASSIGN_SECONDARY` | Secondary area: works at ×0.7. | İkincil alan: ×0,7 hızla çalışır. |
| `HR_ATLAS_WEEK_RATES` | {rates} a week | Haftada: {rates} |
| `HR_MORALE_UNFIT_WORK` | Worked outside their area | Alanı dışında çalıştı |

- "×" glifi koyu yüzlerde denetlenir (`glyph_audit.gd`). Sayılar `Fmt` ile dile göre ("×0,4" / "×0.4", "%7" / "7%").
- `{name} ({role})` yer tutucuları ek almaz (CLAUDE.md §5).

---

## 7. Uygulama dilimleri
Her commit: lint → `loc_residue` → `loc_csv_integrity` → hedefli smoke → probe → görsel kabul (UI varsa) → Opus
incelemesi → commit. ~~Tam smoke yalnız push öncesi.~~ (inceleme) Push öncesi tam smoke koşulmaz (Erdem 2026-10-06:
"push et" doğrudan push'tur); push yalnız Erdem'in sözüyle.

**D0 · Ölçüm tabanı (harness).**
- Ne: `--sprint-probe`'a `roster=` alanı (ör. `roster=dev:7,dev:3,des:6,test:5,pm:6`; rol:ana alan puanı), işe alınana
  varsayılan iş (`HRConstants.default_job_for_role`) ve sprint başına `PHASE` satırı (aşama ihtiyacı, yapılan, ekip
  puanı, kart başı hata ihtimali). Bugünkü modelle tablo kaydedilir.
- Dosyalar: `scripts/debug/sprint_probe.gd`, `docs/HARITA.md` (probe alanları).
- Kapı: `team=1,3,6` ve 4 roster eşleşmesi %100; çıktı raporda.

**D1 · Ölçek ve kart ihtiyacı.**
- Ne: Ölçek ×5; kart `need`/`need_mod`; `remaining`, `phase`, `total` ihtiyaçtan; düzeltme tablosu; karar fiillerinde
  `phase` alanı ve ×5 miktarlar; kayıt göçü. Roller ve hızlar henüz değişmez.
- Dosyalar: `data/product/sprint.json`, `scripts/systems/sprint_system.gd`, `sprint_catalog.gd`,
  `scripts/events/core/effects.gd`, `scripts/events/present/chips.gd`, `data/events/cards/product/sprint_*.json`,
  `scripts/autoload/save_manager.gd`, `scripts/debug/endgame_smoke.gd`.
- Kapı: D0'ın aynı tohumlu çıktısı (puanlar ×5) bayt bayt eşleşmeli, MVP günü aynı; `sprint_*` vakaları,
  `sprint_solo_mvp_by_week_six`, `sprint_save_roundtrip`; `--event-lint`.
- Görsel: `--product-shot=live:plan` ve `live:active` (yalnız sayılar değişir).

**D2a · Rol puanı motoru.**
- Ne: `team()` aşama hızlarını hesaplar (yıldız eğrisi, uyum, Görevler matrisinden izin, iş payı, kurucu tabanı ve
  payı, koordinasyon, PM kapsamı); PM sprint puanından çıkar; `_assign` uyuma göre sıralar; `_work` aşama hızıyla
  döker; `_takes` ekleneni oynatır; `rates_for`; `week_points`; probe'a `cause=founder_time`.
- Dosyalar: `sprint_system.gd`, `sprint.json`, `hr_constants.gd` (Test işinde ürün tarafına 0,4), `sprint_probe.gd`,
  `endgame_smoke.gd`, (inceleme) `sprint_catalog.gd` (`_suggest` adayı `_takes` ile sınar, §5.5).
- Kapı: probe `team=1,3,6`, `roster=` dörtlüsü, `weeks=1` ve `weeks=2`: adsız uyuşmazlık 0; tek kurucu MVP günü D0 ile
  aynı; yeni smoke `sprint_role_points` (yıldız, uyum, koordinasyon, kurucu payı tablosu; ekonomi çekirdeği olduğu
  için).

**D2b · Ekip ekranları.**
- Ne: Görevler matrisinde PM ve tasarımcının Test kutusu açılır (yeni `JobBoxUnfit` varyasyonu), kutu ipuçları,
  uymayan işin moral bedeli, Atlas dosyasında aşama hızları, avatar ipucunda iş paylaşımı.
- Dosyalar: `scripts/tabs/hr/hr_assignments.gd`, `hr_atlas_modal.gd`, `scripts/autoload/character_registry.gd`
  (atama kapısı), `scripts/systems/hr_morale_system.gd`, `scripts/theme/build_theme.gd` + `UiTokens.THEME_STAMP` +
  iki tema, `localization/strings.csv`.
- Kapı: `theme_check.gd`, `--theme-contrast-audit`, `glyph_audit.gd`; hedefli HR smoke'ları.
- Görsel: `--hr-shot=gorevler`, `--hr-shot=atlas-secili`, `--hr-shot=saatler-sprint`; TR ve EN, 1920 ve 1536.

**D3 · Hata ihtimali.**
- Ne: `_work` test kalitesini biriktirir; `_close` yeni ihtimalle zar atar; `escape_chance(card)`; probe `PRED`/`CLOSE`
  ihtimali karşılaştırır.
- Dosyalar: `sprint_system.gd`, `sprint.json`, `sprint_probe.gd`, `endgame_smoke.gd`
  (`sprint_faulty_ticket_deterministic` → `sprint_escape_by_tester`).
- Kapı: probe adsız uyuşmazlık 0; 3 tohum × 40 hafta beklenen ve gerçekleşen hatalı kart sayısı aynı büyüklükte
  (rapor, kapı değil).

**D4 · Plan ekranı.**
- Ne: Üç aşama satırı (T1), koordinasyon satırı, kartta ihtiyaç satırı ve uyum etiketi, efor kutusu (T2), "kimse yok"
  uyarısı.
- Dosyalar: `scripts/tabs/product/product_model.gd`, `sprint_panel.gd`, `sprint_ui_shared.gd`, `sprint_card.gd`,
  `localization/strings.csv`.
- Görsel: `--product-shot=live:plan`, `live:week1`, `live:active`, `live:solo15`, `live:solo12_active`; TR ve EN,
  1920 ve 1536 (`--shot-size`). Kontrol: üç satır sığıyor mu, uzun kart adı etiketle çakışıyor mu.

**D5 · PM hazırlığı.**
- Ne: Hazırlık tablosu, kuyruk, `_end_week`'te dökme, `_begin`'de sabitleme, `plan_outcome`'ta sprint sonu hazırlık
  tahmini, `product.prep`, sonraki sütun ve Çeyrek etiketleri (T3), tasarımcı etiketinin yeni adı, PM avatarının
  ipucu, B için seam.
- Dosyalar: `sprint_system.gd`, `sprint_catalog.gd`, `sprint.json`, `product_model.gd`, `sprint_card.gd`,
  `quarter_view.gd`, `scripts/events/seams/seams_product.gd`, `save_manager.gd`, `strings.csv`.
- Kapı: probe `roster=` PM'li ve PM'siz; yeni smoke `sprint_prep_ready` (hazır kart sabitlenir, ihtiyaç %20 iner,
  kayıt gidiş dönüşü).
- Görsel: `--product-shot=live:delegate`, `live:plan` (sonraki sütun), Çeyrek görünümü.

**D6 · Ölçüm ve kalibrasyon raporu (commit yok).**
- `--sprint-probe` D0 ile aynı spec'lerle: sprint başına aşama puanı, biten kart, boşta kişi-hafta, MVP günü, hata
  sayısı; bugün ile yeni yan yana.
- `bash tools/run_gate.sh` 3/3 (her koşu bir sonla bitmeli, sıfır `ERROR`); B2B ve B2C'de MVP haftası ve ilk 20 haftanın
  sprint puanı.
- 5★ ile 3★ geliştiricinin maaş başına puanı.
- (inceleme) Açık hata: 60 haftada B2B ve B2C açık hata sayısı A'nın ölçüm tablosuyla yan yana. Bugün kart kaçışı %0;
  D yeni bir hata kaynağı açıyor ve A'nın bildirim akışındaki "yeni kod" terimi de aynı gerçeği sayıyor. Toplam fark
  raporlanır; sabit değişmez.
- (inceleme) B2B bot koşusunda kurucunun haftalık toplantı payı (C'nin yenileme saatleri dahil) ve sprint puanına etkisi.
- **MVP ölçütü:** Tek kurucu MVP günü D0 ile aynı (bugün 7). Bot koşularında MVP haftası 1 haftadan fazla kayarsa
  rapor edilir, sabit değiştirilmez (CLAUDE.md §3).

**Riskler**
1. **Tahmin = sonuç kırılması.** Aşama hızı, iş payı, Hazır sabitlenmesi ve kurucu payı dört yeni girdi. Önlem:
  hepsi `team()` ve `_begin`'de tek yerde; D1'in bayt eşleşme kapısı ölçeği motordan ayırır; her dilimde probe.
  (inceleme) Beşinci girdi test kalitesi (`t`), altıncı uymayan işin morali. Kurucu payı yalnız ilk oynatma haftasına,
  moral kapanışa yazılır (§5.5); ikisi de `--sprint-probe`'un `cause=team` adlandırmasıyla gizlenebileceği için D2a'nın
  smoke'u bunları adsız sınar.
2. **Kalibrasyon kayması.** PM puan üretmiyor, testçi kendiliğinden geliştirmiyor, geliştirici kendiliğinden test
  etmiyor. Orta oyunda ekip bugünden ~%13 yavaş, hazırlıkla eşit (§2.9). Bot koşularının runway'i değişebilir.
  Önlem: D6 ölçümü; sabitler onay listesinde.
3. **Kayıt ve içerik göçü.** ×5 ölçek saklı kartlara, sürüm geçmişine ve B'nin yeni karar kâğıtlarına dokunur; A ve
  B'nin şema numaralarıyla çakışabilir. Önlem: tek göç fonksiyonu, `sprint_save_roundtrip` ve eski kayıtla yükleme
  denemesi; B'nin kâğıtlarının miktarları bir listede ×5.
4. **Ekran yoğunluğu.** 1536 genişlikte üç satır, koordinasyon satırı ve etiketler. Önlem: koordinasyon yalnız kayıp
  varken; boş ve hata yalnız sıfırdan farklıyken.
5. **Görevler matrisinin anlamı değişiyor.** Oyuncu matrisi bugün süs gibi görüyor olabilir; artık sprinti
  belirliyor. Önlem: plan ekranının "1 kişi boşta" satırı ve kutu ipuçları.

---

## 8. Açık sorular
1. **Kurucu tabanı:** Kurucunun her aşamadaki hızı en az 2,5★ gibi mi olsun (öneri), yoksa gerçek yıldızı mı okunsun?
   Öneri: taban. Gerçek yıldızla debug kurucusu MVP'ye 6. hafta yerine ~9. haftada varır; Satış'a puan veren kurucu
   cezalanır.
2. **Uymayan iş:** ×0,4 yalnız Test'te ve yalnız oyuncu atarsa; geliştirici tasarım, tasarımcı geliştirme yapamaz.
   Öneri: evet. Kimseyi sessizce ×0,4'le çalıştırmamak "bu böyle çalışmaz" bedelini görünür kılar.
3. **PM hazırlığı:** Puanla mı (öneri: 3★ PM büyük işi ~1 haftada, küçük işi ~1 günde hazırlar, Hazır kart %20 az
  iş), yoksa takvimle mi (büyük iş 8 hafta, aynı anda 3 iş)? Öneri: puanla. Takvimle 6 kişilik ekip hazır kart
  bulamaz, PM darboğaz olur.
4. **Hata ihtimali ekranda sayı olarak yazsın mı?** Öneri: evet, Test satırında ve kartın ipucunda. Zar seyrek
  atıldığı için %2 ile %14 arasındaki fark sayı yazmadan hissedilmez; testçi ve PM kararının karşılığı bu sayıdır.
5. **Ölçek ×5:** Kişi haftada 10, K1 15 puan olsun mu? Öneri: evet. Aşama ihtiyacı tam sayı okunur; bugünkü ölçekte
  kart "Tasarım 0,6" yazardı.

(inceleme) Erdem'e giden birleşik soru listesi `D_INCELEME.md` §3'tedir (6 soru; 4 ile 5 birleşti, iki yeni soru eklendi).

---

## 9. Uygulama adım tablosu

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| 0 | Planı A ve B'nin commit'lerine karşı tazele (A/B varsayımları, şema numarası, B'nin kâğıt listesi) | Alt ajan | Sonnet | yüksek | 15 dk | Fark kontrolü |
| 1 | D0 probe genişletmesi ve bugünkü ölçüm | Alt ajan | Sonnet | xhigh | 45 dk | Harness kodu; ölçümün kendisi D1–D6'nın kapısı |
| 1k | D0 probe koşuları (4 spec × 2 süre) | Alt ajan | Haiku | düşük | 15 dk | Mekanik koşu |
| 1i | D0 incelemesi, commit | Ana / alt ajan | Opus | yüksek | 15 dk | Commit başına bir inceleme |
| 2 | D1 ölçek, kart ihtiyacı, göç, fiil `phase` alanı | Alt ajan | Sonnet | max | 2 sa | Motorun temsili değişiyor; göç hatası kayıt bozar |
| 2m | B'nin kâğıt miktarlarını ×5 (liste veriliyse) | Alt ajan | Haiku | düşük | 15 dk | Mekanik veri değişikliği |
| 2k | D1 kapıları: bayt eşleşme, smoke, lint, iki çekim | Alt ajan | Haiku | düşük | 25 dk | Koşu ve ekran |
| 2i | D1 incelemesi (düzeltme hakkıyla), commit | Alt ajan | Opus | yüksek | 25 dk | Kıdemli inceleme |
| 3 | D2a rol puanı motoru | Alt ajan | Sonnet | max | 2,5 sa | Çekirdek; tahmin = sonuç |
| 3k | D2a kapıları: probe dörtlüsü, yeni smoke, MVP günü | Alt ajan | Haiku | düşük | 25 dk | Koşu |
| 3i | D2a incelemesi, commit | Alt ajan | Opus | yüksek | 30 dk | En riskli dilim |
| 4 | D2b Ekip ekranları ve tema | Alt ajan | Sonnet | xhigh | 1,5 sa | UI ve tema üretimi |
| 4k | D2b tema kapıları ve 3 çekim × 2 dil × 2 boyut | Alt ajan | Haiku | düşük | 30 dk | Ekran sırayla |
| 4i | D2b incelemesi, commit | Alt ajan | Opus | yüksek | 20 dk | |
| 5 | D3 hata ihtimali | Alt ajan | Sonnet | xhigh | 1 sa | Küçük, iyi tanımlı |
| 5k | D3 probe ve smoke | Alt ajan | Haiku | düşük | 15 dk | |
| 5i | D3 incelemesi, commit | Alt ajan | Opus | yüksek | 15 dk | |
| 6 | D4 plan ekranı | Alt ajan | Sonnet | xhigh | 2,5 sa | En görünür ekran |
| 6k | D4 çekimleri (5 tür × 2 dil × 2 boyut) | Alt ajan | Haiku | düşük | 40 dk | Ekran sırayla |
| 6i | D4 incelemesi ve görsel kabul kararı, commit | Alt ajan | Opus | yüksek | 30 dk | ~~En fazla 2 düzeltme turu~~ (inceleme) Commit başına en çok 1 inceleme ve 1 düzeltme (Erdem kuralı 2026-10-11) |
| 7 | D5 PM hazırlığı | Alt ajan | Sonnet | max | 2,5 sa | Yeni durum, kuyruk, tahmin |
| 7k | D5 kapıları ve çekimler | Alt ajan | Haiku | düşük | 30 dk | |
| 7i | D5 incelemesi, commit | Alt ajan | Opus | yüksek | 25 dk | |
| 8 | D6 ölçüm koşuları: probe, `run_gate.sh` 3/3 | Alt ajan | Haiku | düşük | 1 sa | Uzun mekanik koşu |
| 9 | D6 raporu: bugün ile yeni, MVP, 5★, onay listesi | Ana | Opus | orta | 20 dk | Erdem'e giden sentez |

**Paralellik:** Adımlar sırayla gider; her dilim bir öncekinin motoruna dayanır. Tek istisna: 4 (D2b, yalnız HR
ekranları) 5 (D3, yalnız motor) ile aynı anda yazılabilir; commit'ler sırayla atılır.
**Toplam:** Kod yazımı ~12 saat, kapı ve çekim ~4 saat, inceleme ~3 saat. Gerçekçi takvim 18–20 saat.
(inceleme) Gerçekçi takvim 20–24 saat (bkz. §0). Push yalnız Erdem'in sözüyle; push öncesi tam smoke yok. Paralel
yazılan 4 ve 5 aynı klasörde çalışır; ikisi de `endgame_smoke.gd`'ye vaka ekler, commit'ler kısmi staging ile ayrılır.
