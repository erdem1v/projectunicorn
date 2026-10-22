# Faz D planının incelemesi · Ekip modeli
İnceleyen: Opus (kıdemli), 2026-10-16. Repo main @ 1faeb82, hiçbir repo dosyası değişmedi. Okunan: `ERDEM_TUR2_YORUM.md`,
karar defteri (Faz D ve sınırlar), `ORTAK.md`, `D_GOREV.md`, `D_ARASTIRMA.md`, `D_PLAN.md`, `dprobe/sim.py` (koşuldu),
`A_PLAN.md`, `B_PLAN.md`, `B_INCELEME.md`, `C_PLAN.md`, `E_PLAN.md`; kodda `sprint_system.gd`, `hr_constants.gd`,
`hr_system.gd`, `game_state.gd`, `time_manager.gd`, `sprint_probe.gd`, `sprint_catalog.gd`, `product_model.gd`,
`support_system.gd`, `office_people.gd`, `endgame_smoke.gd` ilgili vakalar.
Düzeltmeler `D_PLAN.md`'ye doğrudan işlendi ve "(inceleme)" diye işaretlendi.

## 0. Kısa hüküm
Plan Erdem'in sorularına somut cevap veriyor: kart aşama başına puan ister, ekip aşama aşama puan üretir, süre plan
ekranının haftalık oynatmasıdır, ekranda sayı yazar. Simülatör plandaki tabloları birebir üretiyor (tek sapma:
12 kişilik örnekte düzeltme kartı 15/15 değil 14,99/15, devreder). İki kod açığı doğrulandı. En önemli bulgu planın
**bugünü yanlış anlatması**: bugün kart kaçışı pratikte %0, %40 yalnız kâğıtta. Yeni model testçisiz ekibe bugünden fazla
hata getirir; Erdem'e bu açıkça söylenmeli (soru 5).

## 1. Bulgular

| # | Bulgu | Nerede | Düzeltme | Uygulandı mı |
|---|---|---|---|---|
| 1 | **Bugün kart kaçışı %0, %40 değil.** `_work` kartı yalnız teste uymayan kişi test ederse `faulty` yapar (`sprint_system.gd:793-796`). Kurucu her role uyar (`founder_roles`), geliştirici ikincil alanıyla teste uyar (`hr_constants.gd:86-95`), PM ve tasarımcı `ahead` olduğu için tasarımdan öteye geçmez. Bayrak oyunda hiç kalkmıyor; tek kanıtı, kurucunun rollerini elle kısan smoke vakası (`endgame_smoke.gd:17447`). A planı (satır 139) ve tur 2 hata listesi de aynı yanlışı taşıyor. | §0, §1, §2.9 örnek 1 | Bugünkü akış düzeltildi; yeni modelin testçisiz ekibe hata **eklediği** yazıldı; tek kurucuda MVP'de ortalama 0,3 hata. | Evet; sahip sorusu 5 |
| 2 | "Ekipte Test yok" satırı yalnız kimse teste uymadığında çıkar (`product_model.gd:248`), yani kurucu yokken ve ekipte geliştirici ya da testçi yokken; o durumda kart hatalı çıkmaz, testte bekler. | §1 | Satırın koşulu doğru yazıldı. | Evet |
| 3 | Kurucunun toplantı payı için yeni sayaç gerekmez: `GameState.founder_meeting_share()` var, Ar-Ge okuyor (`rnd_system.gd:116`). Gün tiki hafta başı sıfırlamasından önce koşar (`time_manager.gd:149`, `:384`), `_end_week` biten haftanın payını okur. | §1 açık 2, §5.1 | Var olan fonksiyon adıyla bağlandı. | Evet |
| 4 | **Tahmin = sonuç açığı:** `_play_out` bütün haftaları tek ekiple oynar. Kurucu payı `team()`'e katılırsa bu haftanın toplantısı bütün sprint haftalarına yayılır; `mvp_eta` de gelecek sprintlere taşır. | §5.5 | İlk oynatma haftası paylı, sonrakiler paysız; `mvp_eta` payı mesai çarpanı gibi ayıklar. | Evet |
| 5 | **Beşinci girdi, moral:** uymayan işin −2/hafta morali hafta hafta yazılırsa verim sprint içinde değişir. Probe bunu `cause=team` diye adlandırıp geçirir (`sprint_probe.gd:205-211`), oyuncunun ekranı yine yanlış kalır. | §2.3, §5.5, risk 1 | Moral bedeli sprint kapanışında topluca yazılır; D2a smoke'u adsız sınar. | Evet |
| 6 | Test kalitesinin paydası "ilk test ihtiyacı"; B'nin "Testi kısalt" kesintisi `need_mod`'a yazılırsa payda da küçülür ve kısaltma kaliteyi düşürmez. | §5.1 | Payda tanımlandı; kesinti ayrı alana yazılır. | Evet |
| 7 | Liderin ve PM'in önerisi (`SprintCatalog._suggest`, `sprint_catalog.gd:790-820`) tek sayılık kapasiteyle doldurur; aşamalar ayrılınca darboğaz aşamayı taşıran plan önerir. Plan bu dosyayı D2a'da saymıyordu. | §5.5, D2a dosyaları | `_suggest` adayı `_takes` ile sınar. | Evet |
| 8 | PM `team()`'den çıkınca `role_of(pm)` "" döner. Üç okuyucu etkilenir: ofis (`office_people.gd:667`, PM kahvede görünür), Destek'in mail okuyanları (`support_system.gd:236`, PM Destek'e sayılır), deneyim (`hr_system.gd:84`). | §5.5 | Hazırlığı süren PM için `role_of` "product" (ofisteki "plan" animasyonu var) ve `worked` listesi. | Evet |
| 9 | Şema numarası belirsizdi ("16 ya da 17"). | §5.6 | A 15→16, B ve C artırmaz, **D 16→17**, E 17→18 (eski kayıtları kapatabilir). | Evet |
| 10 | Ekranda ondalıklar ("20,8/21", "0,2 devreder", "11,6", "9,8/10"); Erdem'in sakin ekran ve sayı kuralına ve planın kendi "tam sayı okunur" gerekçesine ters. | §2.10 T1, T2, T5 | Gösterim kuralı: ondalık yok, yapılan aşağı, kalan yukarı yuvarlanır. Örnekler tam sayıya çevrildi. | Evet |
| 11 | Kelimeyle anlatım: "hata ¾", "dörtte bir düşük". | T2, §6 `PRODUCT_CARD_PREPPED_TIP` | "25 → 20 puan · hata %8 → %6". | Evet |
| 12 | 12 kişilik örnekte "Stok düzelt · sınırda, 15/15, %8,4": simülatörde kart 14,99/15'te devreder. | §2.9 | Düzeltildi; sınır vakası olarak işaretlendi. | Evet |
| 13 | "Tam smoke yalnız push öncesi": Erdem'in kuralı tersini söylüyor ("push et" doğrudan push, öncesinde tam smoke yok). | §7 | Düzeltildi; push yalnız Erdem'in sözüyle. | Evet |
| 14 | 6i "En fazla 2 düzeltme turu": kural commit başına en çok 1 inceleme ve 1 düzeltme. | §9 | Düzeltildi. | Evet |
| 15 | Süre 18–20 saat iyimser: D2a ve D5 tahmin = sonuç kapısında bir tur kaybedebilir; Ekip verim/destek fazı 6 commit için 13,5 saat sürmüştü. | §0, §9 | 20–24 saat. | Evet |
| 16 | **K6 "Testi sen yap"** (B, kurucu verimi −%20, `covered`): D'de testi yapanın gerçek Test yıldızı okunur. Test 0★ kurucu %11, ikincil rolde test eden 2★ geliştirici %10,4. Seçenek bedel öder, karşılık almaz. | §5.4 | B tazelemesine not: seçenek yalnız kurucunun test etkinliği geliştiricininkinden yüksekken açılır ya da başka bir karşılık taşır. | Kısmen (B'nin işi) |
| 17 | "Hazırlık" sözcüğü bugün yatırımcı hazırlığında kullanılıyor (`HUNT_PREP_*`). | §5.4 | B'nin önerisiyle hazırlık kalkarsa çakışma yok; kalırsa PM'in sözcüğü değişir (öneri: "Ön çalışma"). | Kısmen (B'nin sorusuna bağlı) |
| 18 | C varsayımı yoktu: C, D'den önce ürün penceresini üç kâğıda böler ve `founder_hours` fiilini kurar; plan "C'nin dokunduğu yer yok" diyordu. | §5.4 | C varsayımı yazıldı; D4 dosyaları tazelemede okunur; yenileme saatleri kurucu payına girer. | Evet |
| 19 | Dış geliştiricinin "puan başı $1.000"u ×5'te $200 olmalı; plan yalnız miktarları sayıyordu. | §5.4 | Eklendi. | Evet |
| 20 | A'nın yeni vakaları (`sprint_faulty_pre_launch_lands_at_v1`, `sprint_fix_card_clears_its_line`) D3'te yeniden yazılmalı; düzeltme kartının kendi kaçışı için sıra (önce hattı sıfırla, sonra kaçışı yaz) kodda bugün doğru, korunmalı. | §5.7 | Eklendi. | Evet |
| 21 | D6 açık hatayı ölçmüyordu; D yeni bir hata kaynağı açıyor ve A'nın bildirim akışındaki "yeni kod" terimi aynı gerçeği sayıyor (çift kaynak). C'nin yenileme saatlerinin sprint etkisi de ölçülmüyordu. | §7 D6 | 60 haftalık açık hata A'nın tablosuyla yan yana; B2B'de kurucu payı. | Evet |
| 22 | Koordinasyon "%1 × (n − 3)" doğrusal; Erdem "kademeli" ve "3 çok basit bir sayı" dedi. Tablo 5 kişide %2 (onun örneği) veriyor ve uçurum yok, ama Erdem'in kelimesi basamaklı bant da olabilir. | §2.4 | Değiştirilmedi. | Hayır; sahip sorusu 6 |
| 23 | Kurucunun tek işi: bot kurucuyu Destek'e geçiriyor (`run_probe.gd:1089`); kurucu hem masada hem sprintte sayılıyor. A K1 yalnız pasif ilgiyi kapatıyor. | §2.8 | Kurucu bugünkü gibi her zaman sprintte; botun çift sayımı kapsam dışı notu. | Evet (not) |
| 24 | ×5 ölçek: gereksiz mi? Hayır. Aşama ihtiyaç tablosu `shares × effort`'un yerine geçtiği için kartların ilerleme göçü zaten gerekiyor; ×5'in ek bedeli B'nin ~12 sayısı, bir fiyat, `capacity` ve `velocity`. Getirisi: yarım yıldızların haftalık puanı 6 · 7 · 9 · 10 · 12 · 13 · 15 · 18 · 20, her basamak tam sayıyla ayrılır. | §2.1, §2.10 | Gösterim kuralına gerekçe olarak yazıldı. | Evet; sahip sorusu 4'e birleşti |
| 25 | Kurucu tabanı sorusu doğru kurulmuş ama "taban = bugünkü kurucu hızı" demiyordu. Taban `founder_mult` 1,0'ın kendisidir; tek kurucunun hızı ve MVP 6–7. hafta değişmez. | §8 soru 1 | Soru 1 bu cümleyle yeniden yazıldı (aşağıda). | Evet (§3'te) |
| 26 | Uymayan iş: "yalnız Test'te, yalnız oyuncu atarsa, ×0,4" Erdem'in "0,4 gayet iyi; hiç çalışamaz mı, 0,3 mü" sorusuyla tutarlı: 0,4 korunur, tasarım ile kod arasında yasak. | §2.3 | Değişiklik yok. | Gerek yok |
| 27 | Düzeltme kartı eforu: A 1/2/3 → D 0/3/2, 0/7/3, 0/10/5 = toplam 5/10/15, bugünkü ×5 ve bugünkü 0,7/0,3 payıyla uyumlu. Örnekler (4 hata → 2, 7 hata → 3) A'nın basamaklarıyla aynı. | §2.2 | Değişiklik yok. | Gerek yok |
| 28 | Açık 1 doğrulandı: `team()` Görevler matrisini okumuyor, yalnız Ar-Ge'yi (`sprint_system.gd:518-533`). Açık 2 doğrulandı: yatırımcı hazırlığı kurucuyu `is_busy` yapıyor (`hr_system.gd:155`), sprint bu kapıyı okumuyor. | §1 | Doğrulama notu. | Evet |

## 2. Fazlar arası liste (tam uyuşmazlıklar)

**A**
- Şema: A 15 → 16. D 16 → 17 olmalı (planda "16 ya da 17" yazıyordu; düzeltildi).
- A'nın metni (satır 139) testsiz kapanışı %40 diye canlı sayıyor; gerçekte %0. A'nın 60 haftalık açık hata tablosu D'siz
  dünyayı ölçer; D gelince kaçış yeni bir kaynak olur.
- A'nın bildirim akışındaki `0,03 × yeni kod` terimi ile D'nin kart kaçışı aynı gerçeği (yeni kod hata getirir) iki kez
  sayar. D6 toplamı ölçer; sabit değişmez.
- A'nın `pending_faulty` ve `release.faulty` listeleri kalır; D yalnız kartın `faulty` bayrağını ve `faulty_chance`'i
  siler, `_close`'taki koşul `escape_chance`'e döner.
- A'nın iki yeni vakası D3'te yeniden yazılır.
- Düzeltme kartı eforu eşleşmesi tutarlı (bulgu 27).

**B**
- ×5 listesi (B §5.6): K1 +2 → +10, K2 +1 → +5, K3 +1 → +5, K4 +2 → +10, K5 −3 ve −2 → −15 ve −10, K7 +2 ve +1 → +10 ve +5,
  K8 +2 ve +4 → +10 ve +20, `sprint_card_trim {points}` ×5, dış geliştirici $1.000 → $200 puan başı.
- "Testi kısalt" (`sprint_card_test {cut}`): ihtimal `escape_chance`'ten okunur, B ayrı ek yazmaz (iki plan uyumlu). B'nin
  örneği "%7 → %10" D'nin formülüyle %7 → %10,5 çıkar; uyumlu. Kesinti `need_mod`'a değil ayrı alana yazılır (bulgu 6).
- K6 `covered`: D'de testi gerçekten yapanın yıldızı okunur (B inceleme 22 ile uyumlu), ama "Testi sen yap" Test 0★
  kurucuda boş seçenek olur (bulgu 16). K6'nın konuşmacısı "testi yapan geliştirici" koşulu D'de değişir: geliştirici
  yalnız Test kutusu işaretliyse test eder; varsayılanda testi kurucu yapar.
- "Kendin bak" ve K6/K9 kurucu verimi `productivity_mod` ile yazılır; D bunu `HRSystem.productivity` üstünden zaten okur.
- Yatırımcı hazırlığı: B kaldırmayı öneriyor; D'nin "hazırlık haftası 0" terimi o zaman düşer. Kalırsa "Hazırlık"
  sözcüğü çakışır (bulgu 17).
- B şemayı artırmaz; çakışma yok.

**C**
- C planı "Şema 15 kalır" diyor; A'dan sonra numara 16'dır, anlamı "C artırmaz". D 17 alır.
- C'nin `founder_hours` fiili `add_founder_meeting_hours`'a yazar; yenileme ayında kurucu haftada 24 saate kadar
  masada, sprint payı %40'a iner. D bunu okur ve D6 ölçer.
- C ürün penceresini üç kâğıda böler; D4'ün plan ekranı dosyaları C'den sonra tazelenir (C varsayımı eklendi).

**E**
- `--sprint-probe` ve D0'ın `roster=` ölçümü not uygulamasını (`note_tool`) kurar; E not ve video uygulamasını siliyor.
  E2 probe'u pazaryeri ürününe taşımalı.
- E şemayı 18'e çıkarıp eski kayıtları kapatmayı öneriyor (E sahip sorusu 2). Onaylanırsa D'nin göçü yalnız D ile E
  arasında yaşar (ana oturuma not).

## 3. Erdem'e sorular (kapalı uçlu, önerili; planın 5 sorusuyla birleşik)
1. **Kurucunun hızı:** Kurucu her aşamada en az bugünkü hızında çalışsın (haftada 10 puan, 2,5★ eşdeğeri), alanında daha
   iyiyse kendi yıldızı geçsin mi? Hata ihtimalinde gerçek Test yıldızı okunur. **Öneri: evet.** Bu bugünkü kurucu
   hızıdır; tek kurucunun MVP'si 6–7. haftada kalır. Gerçek yıldız okunursa Tasarım ve Test'i 0★ olan kurucu MVP'ye ~9.
   haftada varır.
2. **Uymayan iş:** Yalnız Test'te, yalnız oyuncu işaretlerse, ×0,4 hız ve sprint sonunda çalıştığı hafta başına −2 moral;
   geliştirici tasarım, tasarımcı kod yapamaz. **Öneri: evet.**
3. **PM hazırlığı puanla:** 3★ PM küçük işi ~1 günde, büyük işi ~1 haftada hazırlar (küçük ile büyük arası 1'e 7, senin
   1 hafta ile 2 ay örneğinin oranı); hazır kart %20 az iş ve %25 düşük hata ihtimali taşır. Takvimle (büyük iş 8 hafta)
   değil. **Öneri: puanla.** Takvimle 6 kişilik ekip hazır kart bulamaz, PM darboğaz olur.
4. **Plan ekranı sayı yazsın:** Aşama ihtiyaçları ve ekibin aşama gücü tam sayı ("Tasarım 9 · Geliştirme 11 · Test 5";
   bunun için puan ölçeği ×5: kişi haftada 10, K1 15 puan) ve kartın hata ihtimali yüzde olarak. **Öneri: evet.**
5. **(Yeni) Testçisiz ekibin hatası:** Bugün oyunda hiçbir kart hatalı çıkmıyor; %40 yalnız kâğıtta, çünkü kurucu ve
   geliştirici teste "uyan" sayılıyor. Yeni modelde testçisiz her kart %11–14, 2★ testçiyle %9, 3★ testçiyle %7, 5★
   testçiyle %2 taşır. Yani testçisiz ekip bugünden çok hata görür, testçi ilk kez fark eder. **Öneri: kabul.** Ölçüm
   diliminde 60 haftalık açık hata sayısı A'nın tablosuyla karşılaştırılır.
6. **(Yeni) Ekip büyüklüğü eğrisi:** 3 kişiye kadar kayıp yok, 5 kişide %2, 10'da %7, 20'de %17, tavan %25; PM 8 kişiye
   kadar yarıya indirir. Kişi eklemek toplam çıktıyı hiç düşürmez. Bu düzgün eğri mi, yoksa basamaklı bant mı (örnek
   [ÇALIŞMA]: 4–5 kişi %2, 6–10 %6, 11–20 %12, 21+ %20)? **Öneri: eğri.** Bantta 6. kişiyi alınca herkes bir anda yavaşlar.

## 4. Ana oturuma not (Erdem kararı değil)
- ×5 ölçek gereklidir, kalsın (bulgu 24).
- E'nin "eski kayıtlar açılmasın" sorusu D başlamadan onaylanırsa D göç yazmaz, kırılma D'ye taşınır (`MIN_LOADABLE_VERSION`
  17); ~45 dakika ve bir risk az. Onaylanmazsa D göçü yazar.
- B tazelemesine: K6 "Testi sen yap" seçeneği ve konuşmacı koşulu; "Hazırlık" sözcüğü.
- E tazelemesine: `--sprint-probe` not uygulamasına bağlı.
- Botun kurucuyu Destek'e geçirip sprintte de saydırması A ile D'nin dışında kalan bir harness meselesi.

## 5. Adım tablosu
- Model seçimi kurala uyuyor: Sonnet kodlar (D1, D2a, D5 max; D0, D2b, D3, D4 xhigh), Haiku kapı ve çekim (düşük), Opus her
  commit öncesi kıdemli inceleme (yüksek, düzeltme hakkıyla), adım 0 tazeleme Sonnet yüksek. En ucuz yeterli model.
- Düzeltildi: push öncesi tam smoke yok, push yalnız Erdem'in sözüyle; commit başına en çok 1 inceleme ve 1 düzeltme;
  takvim 20–24 saat.
- Paralel 4 ile 5 tek klasörde ve ikisi de `endgame_smoke.gd`'ye yazar; kısmi staging gerekir (not eklendi).

## 6. Hüküm
Uygulanabilir ve Erdem'in kararlarına sadık; 21 düzeltme plana işlendi. "Bugün kaçış %0" gerçeği ve koordinasyon eğrisi
iki yeni soruyla birlikte Erdem'e sunulabilir.
