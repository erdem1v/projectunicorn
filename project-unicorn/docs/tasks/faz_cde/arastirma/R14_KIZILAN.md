# R14 · Kızılan ne?
2026-10-18 · Yardımcı yönetmen turu (QCD). Repo koduna dokunulmadı. Kaynaklar: Steam yorum API'si (doğrudan okundu), mağaza sayfaları, Steamworks belgesi.

## 0. Hüküm (altı satır)
1. Çok olumlu tycoon oyunlarında olumsuz yorumun ana konusu **çekirdek döngü**: tekrar (%19), sıkılma (%14), sığlık (%10), "neden böyle oldu" (%8), mikro yönetim (%8). Ham sayımdır, kesinlik düzeltmesi §3'te.
2. Zayıf oyunlarda ana konu **oyunun çalışması ve yaşaması**: hata/çökme (%41), terk edilmişlik (%16), içerik azlığı (%16). Çekirdek şikâyetleri yine var ama puanı bunlar indiriyor.
3. Olumsuz yorumcunun ortanca oyun süresi 7 ile 12 saat. İlk 10 saatte yazanlar %46 ile %61. "5 ile 10 saat sonra sıkıldım" tarifi örneklemde doğru.
4. Bize en yakın iki oyunun kaybettirdiği şey: **Startup Company** zorunlu kilometre taşı, tıklama ve boş son oyun; **Big Ambitions** orta ve son oyunda karar kalmaması. İkisi de %81 ile %92 arası olumlu. Bizim %90 hedefimize yetmiyor.
5. "AI slop" suçlamasının bu örneklemde üç tetikleyicisi var: **ilk ekran** (ana menü zemini, ilk ara sahne, mağaza görseli), **açıklama ile oyun arasındaki fark**, **aynı yapımcıdan çok sayıda ucuz oyun**. Üretken yapay zekâ tek başına puanı batırmadı: Big Ambitions son 350 İngilizce yorumda %86 olumlu.
6. Bizde en büyük kalıp riski: **Game Dev Tycoon kalıbı** (öneriyi uygula, başlat, bekle; çözülmüş oyun) ve **Big Ambitions kalıbı** (güzel ilk saatler, yenilemenin zamla bitmesi). §8.

## 1. Yöntem ve sınırlar
- Veri: `https://store.steampowered.com/appreviews/<APPID>?json=1&language=english&filter=all&day_range=9223372036854775807&review_type=negative&purchase_type=all&num_per_page=100&cursor=...` (yararlılığa göre ilk 200) artı `filter=recent` (son 100). AI bölümü için `filter=recent&review_type=all` (en çok 400). APPID'ler mağaza sayfasından ve `api/storesearch` ile doğrulandı.
- Not: `filter=all` tek başına `day_range` olmadan yalnız 4 yorum döndürüyor; bu yüzden `day_range` verildi.
- Örneklem yalnız **İngilizce olumsuz** yorum, 40 karakterden uzun. Toplam 1.740 yorum, 14 oyun. Yararlılık sıralaması uzun, gerekçeli yorumları öne çıkarır; kısa "çöp" yorumlar az temsil edilir.
- Tema sayımı anahtar kelime ile yapıldı, sonra her tema için rastgele 8 ile 20 eşleşme elle okunup **kesinlik** ölçüldü (§3 tablosu). Sayılar "ham eşleşme" ve "kesinlikle düzeltilmiş" olarak iki sütun verilir. Bir yorum birden çok temaya girer, toplam %100'ü aşar.
- Ayrıca her oyunun ilk 55 ile 60 yorumu (yararlılık sırasıyla) baştan sona okundu. Alıntılar oradan.
- Kapsam dışı kalanlar: Türkçe ve başka dil yorumları (çeviri şikâyeti büyük olasılıkla alt sayılıyor), Reddit ve forumlar, YouTube.
- Aday havuzu: 32 arama terimiyle 110 oyun tarandı. Ölçüt: en az 60 yorum, %80 altı olumlu, 2023 ve sonrası. 2023 sonrası **karışık ya da olumsuz işletme simülasyonu** havuzu ince: yalnız Moviehouse, Hotel Business Simulator, Parking Tycoon (1 ve 2) ve birkaç dükkân simülasyonu buldum. Startup Panic 2022 çıkışlı (istek üzerine dahil).
- Alıntılar en çok 15 kelime, tırnak içinde, `(oyun, yorumcunun yorum anındaki oyun saati)`. Alıntıların tamamı veri dosyalarıyla satır satır eşleştirildi.
- Kaynaksız ya da ikincil bilgi `[kanıtsız]` ya da `[ikincil]` işaretli.

### 1.1 Oyunlar (tüm dillerde puan, Steam API, 2026-10-18)
| Oyun | APPID | Çıkış | Olumlu | Örneklem (olumsuz, İng.) | Not |
|---|---|---|---|---|---|
| Game Dev Tycoon | 239820 | 2013 | %95,1 (38.406 / 1.973) | 240 | Overwhelmingly Positive |
| Mad Games Tycoon 2 | 1342330 | 2023 | %93,9 (6.932 / 447) | 144 | Very Positive |
| Software Inc. | 362620 | 2015, hâlâ EA | %94,3 (7.184 / 431) | 211 | Very Positive |
| Football Manager 2024 | 2252570 | 2023 | %91,2 (15.663 / 1.508) | 248 | Mağaza API'sinde fiyat yok |
| Startup Company | 606800 | 2020 | %81,0 (4.745 / 1.111) | 235 | Steam etiketi Very Positive |
| Big Ambitions | 1331550 | EA 2023, 1.0 28 Ağu 2026 | %92,1 (13.259 / 1.144) | 252 | Aşağıda "zayıf" değil |
| Startup Panic | 1045610 | 2022 | %54,9 (118 / 97) | 53 | Mixed |
| Hotel Business Simulator | 2738870 | 2024 | %46,4 (89 / 103) | 47 | Mixed, AI açıklaması var |
| Parking Tycoon 2 | 3743410 | 2026 (EA) | %39,3 (35 / 54) | 33 | Mostly Negative, AI açıklaması var |
| Parking Tycoon | 2475420 | 2023 | %64,0 (567 / 319) | 132 | Mixed |
| Moviehouse | 1576280 | 2023 | %31,6 (71 / 154) | 67 | Mostly Negative |
| Business Simulator 2026 | 3098060 | 2025 (EA) | %73,3 (132 / 48) | 20 | AI açıklaması var |
| Vending Machine Business Simulator | 2998750 | 2025 | %74,4 (145 / 50) | 26 | AI açıklaması var |
| Bakery Cafe Simulator | 3444080 | 2025 (EA) | %70,2 (271 / 115) | 32 | AI açıklaması var |

Ek: Farming & Supermarket Simulator (3070880, %79, AI açıklaması var) yalnız AI bölümünde, son 171 yorumla kullanıldı.
Üç grup: **A** çok olumlu (ilk altı, n=1.330), **B** zayıf ya da karışık (Startup Panic, Hotel, Parking Tycoon 1 ve 2, Moviehouse; n=332), **C** AI açıklamalı Mostly Positive (n=78).
Küçük örneklemler (Parking Tycoon 2: 33, Business Simulator 2026: 20, Vending: 26, Bakery: 32) 50 yorum şartının altında. Steam'de İngilizce olumsuz yorum o kadar yok. Bu oyunların yorumları tam okundu ama oranları yön gösterir, ölçü değil.

## 2. Zaman: kaçıncı saatte kızıyorlar
| Oyun | N | Ortanca oyun saati (yorum anı) | ≤5 saat | ≤10 saat | ≤20 saat |
|---|---|---|---|---|---|
| Game Dev Tycoon | 240 | 7 | %43 | %61 | %81 |
| Mad Games Tycoon 2 | 144 | 9 | %40 | %56 | %76 |
| Software Inc. | 211 | 9 | %41 | %52 | %63 |
| Startup Company | 235 | 8 | %43 | %60 | %74 |
| Big Ambitions | 252 | 12 | %36 | %46 | %66 |
| Football Manager 2024 | 248 | 97 | %7 | %11 | %19 |
| Moviehouse | 67 | 3 | %70 | %85 | %97 |
| Startup Panic | 53 | 5 | %53 | %72 | %89 |
- FM istisna: olumsuz yorumcuları 100 saatlik kıdemli oyuncular. Onların derdi "her yıl aynı oyun" ve lisans kaldırma. Tycoon'lara uymaz.
- "X saat sonra sıkıldım" diyen açık beyan: Game Dev Tycoon 20/240, Big Ambitions 20/252, Startup Company 11/235, Parking Tycoon 12/132.
- "It’s fun for about… 5 hours then it gets extremely boring, tedious, and repetitive." (Game Dev Tycoon, 46 saat)
- "the first 5-10 hours is filled with promise and hope" (Big Ambitions, 52 saat; kıdemli oyuncu eski tadı arıyor).
- Sonuç: tycoon'da vaat ilk 5 ile 10 saatte tükeniyor. Demomuz 60 ile 90 dakika, bu sınırın çok altında; **tam oyun** (104 hafta, birden çok koşu) sınırın içinde. Asıl sınav tam oyunda.

## 3. Tema sayımı
Sütunlar: kaç oyunda (en az 3 eşleşme, 14 oyundan), ham eşleşme / 1.740, ölçülen kesinlik, düzeltilmiş oran, A / B / C grubunda ham oran.

| # | Tema | Oyun | Ham | Kesinlik | Düzeltilmiş | A | B | C |
|---|---|---|---|---|---|---|---|---|
| T01 | Tekrar, grind | 14 | 320 (%18) | 14/14 | %18 | %19 | %15 | %17 |
| T02 | Şişkinlik, karmaşıklık | 6 | 50 (%3) | 7/8 | %2 | %4 | %1 | %1 |
| T03 | Sıkılma | 11 | 229 (%13) | 11/14 | %11 | %14 | %10 | %4 |
| T04 | Son oyunda karar kalmaması | 8 | 77 (%4) | 9/12 | %3 | %5 | %4 | %0 |
| T05 | Ölçekte mikro yönetim | 8 | 123 (%7) | 10/14 | %5 | %8 | %5 | %0 |
| T06 | Opak sayılar | 9 | 133 (%8) | 9/12 | %6 | %8 | %6 | %4 |
| T07 | Adaletsiz rastgelelik | 7 | 88 (%5) | 7/12 | %3 | %5 | %5 | %0 |
| T08 | Çok kolay | 6 | 64 (%4) | 5/8 | %2 | %4 | %2 | %1 |
| T08b | Çok zor, dengesiz | 10 | 145 (%8) | 3/8 | %3 | %9 | %7 | %5 |
| T09 | Hata, çökme, performans | 14 | 421 (%24) | 7/8 | %21 | %19 | %41 | %47 |
| T10 | Arayüz | 9 | 162 (%9) | 7/8 | %8 | %10 | %7 | %5 |
| T11 | Metin ve çeviri | 2 | 18 (%1) | 16/20 | %1 | %1 | %2 | %4 |
| T12 | Terk, EA, yapımcı güveni | 13 | 97 (%6) | 7/8 | %5 | %3 | %16 | %10 |
| T13 | Fiyat, içerik miktarı | 12 | 164 (%9) | 6/8 | %7 | %8 | %16 | %9 |
| T14 | Üretken yapay zekâ | 1 | 20 (%1) | ~%90 | %1 | %1 | %1 | %4 |
| T15 | Sığlık, "bu simülasyon değil, clicker" | 8 | 159 (%9) | 5/8 | %5 | %10 | %5 | %5 |
| T16 | Anlamlı karar yok, tek formül | 7 | 118 (%7) | 4/8 | %3 | %8 | %3 | %1 |

T15 ve T16 benim eklediğim temalar: listedeki on dört temadan sonra okurken en sık çıkan iki şikâyet bunlardı. T08b ve T16 düşük kesinlikli, yalnız yön gösterir. T04 sıkı kuralla sayıldı; alt sınırdır.

### 3.1 Oyun başına ham sayılar
Sütunlar: GDT Game Dev Tycoon (240), MGT2 (144), SI Software Inc. (211), FM (248), SC Startup Company (235), BA Big Ambitions (252), SP Startup Panic (53), HOT Hotel (47), PT2 (33), MOV Moviehouse (67), BS26 (20), VEN (26), BAK (32), PT1 (132).

| Tema | GDT | MGT2 | SI | FM | SC | BA | SP | HOT | PT2 | MOV | BS26 | VEN | BAK | PT1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| T01 tekrar | 48 | 18 | 30 | 10 | 67 | 84 | 16 | 8 | 3 | 10 | 3 | 7 | 3 | 13 |
| T02 şişkinlik | 6 | 5 | 23 | 4 | 5 | 4 | 2 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| T03 sıkılma | 37 | 18 | 26 | 15 | 49 | 47 | 8 | 9 | 4 | 4 | 0 | 2 | 1 | 9 |
| T04 son oyun | 8 | 5 | 12 | 3 | 11 | 26 | 1 | 4 | 1 | 0 | 0 | 0 | 0 | 6 |
| T05 mikro | 5 | 3 | 13 | 5 | 44 | 38 | 6 | 1 | 0 | 2 | 0 | 0 | 0 | 6 |
| T06 opak | 31 | 7 | 31 | 9 | 18 | 14 | 7 | 2 | 2 | 6 | 1 | 0 | 2 | 3 |
| T07 rastgele | 36 | 9 | 2 | 12 | 7 | 7 | 10 | 1 | 0 | 4 | 0 | 0 | 0 | 0 |
| T08 kolay | 3 | 7 | 11 | 6 | 11 | 19 | 2 | 1 | 0 | 2 | 0 | 0 | 1 | 1 |
| T09 hata | 42 | 19 | 29 | 79 | 36 | 42 | 6 | 13 | 19 | 25 | 10 | 6 | 21 | 74 |
| T10 arayüz | 17 | 15 | 39 | 10 | 26 | 29 | 5 | 2 | 1 | 11 | 1 | 2 | 1 | 3 |
| T12 terk | 3 | 4 | 11 | 8 | 7 | 4 | 4 | 9 | 7 | 11 | 4 | 0 | 4 | 21 |
| T13 fiyat, içerik | 19 | 14 | 11 | 27 | 17 | 15 | 8 | 8 | 6 | 11 | 1 | 4 | 2 | 21 |
| T15 sığlık | 32 | 4 | 11 | 3 | 37 | 52 | 2 | 5 | 0 | 7 | 1 | 2 | 1 | 2 |
| T16 formül | 46 | 16 | 10 | 15 | 14 | 6 | 0 | 0 | 0 | 10 | 1 | 0 | 0 | 0 |
| T14 üretken AI | 0 | 2 | 0 | 0 | 0 | 11 | 1 | 1 | 1 | 0 | 2 | 1 | 0 | 1 |

(T11 ve T08b tabloda yok: T11 toplam 18, T08b düşük kesinlik.) FM'nin T09 yüksekliği maç motoru hataları ve lisans yamasından; T14 FM'de 0 (ilk sayımda gelen 43 "AI yönetici" idi, üretken yapay zekâ değil, çıkarıldı).

## 4. Tema tema: kaç oyun, hangi karar, ne diyorlar

### T01 Tekrar ve grind (14/14 oyunda, %18)
Her oyunda var; en çok Big Ambitions (84/252), Startup Company (67/235), Game Dev Tycoon (48/240).
- "Select genre of game, publish, wait, repeat." (Game Dev Tycoon, 14 saat)
- "you're really just going around doing the same tasks over and over" (Big Ambitions, 12 saat)
- "Attribute employees to a task, send them to vacation, repeat." (Startup Panic, 9 saat)
- "Overly grindy game that wants you to micromanage your micromanagers early game" (Startup Company, 23 saat)
- **Doğuran karar:** her ürünün/kartın aynı döngüden geçmesi ve döngü sonunda yeni bir *karar* yerine yeni bir *sayı* gelmesi. Game Dev Tycoon'da proje = slider + bekle. Big Ambitions'ta dükkân = mağaza kur, personel al, mal doldur; on iki iş türü aynı kalıp ("re-skins of the same thing", 4 yorum aynı kökten).
- **Bizde karşılığı:** sprint döngüsü (plan, kapanış, sürüm notu) her hafta aynı üç eylem. Bu en riskli yer: §8.

### T02 Şişkinlik, özellik sürünmesi (6 oyunda, %2 ile %3; Software Inc.'de %11)
Yalnız Software Inc. belirgin: 23/211.
- "Ironically, given its subject matter, Software Inc has fallen to massive feature creep." (Software Inc., 2 saat)
- "I'm trying to run a company not a fridge." (Software Inc., 50 saat; klima, havalandırma, çöp kutusu eklenmesine)
- "they have added so much complexity it ruins the experience for me" (Software Inc., 48 saat)
- **Doğuran karar:** sekiz yıllık Erken Erişimde her güncellemede yeni sistem (ısı, hava, asansör); çekirdek (yazılım üretmek) geride kalıyor. Başka oyunlarda şişkinlik şikâyeti nadir; yani "az sistem" ceza getirmiyor, "çekirdekle ilgisiz sistem" getiriyor.
- **Bizde:** §8 madde 7.

### T03 Sıkılma (11 oyunda, %11)
- "once you get a proper office the game basically becomes an excel sheet" (Big Ambitions, 20 saat)
- "after 4 or 5 hours I feel like Ive done everything" (Game Dev Tycoon, 10 saat)
- **Doğuran karar:** büyüme sistemi bir noktadan sonra sayıyı büyütüyor, seçimi değil. Süre §2'de.

### T04 Son oyunda karar kalmaması (8 oyunda, %3 alt sınır; Big Ambitions %10)
- "there is absolutely no mid or end game" (Big Ambitions, 26 saat)
- "you quickly realise that you've already hit the end game" (Big Ambitions, 19 saat)
- "there is nothing in the game that can stop you, just the boredom" (Mad Games Tycoon 2, 11 saat)
- "literally watching paint dries" (Startup Company, 60 saat; Fortune 500 aşaması için)
- **Doğuran karar:** para bir kez akmaya başlayınca para da risk de anlamını yitiriyor ("Money is easy to come by", "you can just afk while the number goes up" gibi şikâyetler Big Ambitions'ta). Startup Company'de şirket büyüyünce yeni karar yok, yalnız bekleme.
- **Bizde:** Faz C ve D'nin ana riski; "ürün uyumu doyuyor, her yenileme zamla bitiyor" (QCD paketi §6, madde 1).

### T05 Ölçekte mikro yönetim (8 oyunda, %5; Startup Company %19, Big Ambitions %15)
- "the mind-numbing tedium of micromanagement and menu fatigue" (Startup Company, 33 saat)
- "micromanagement hell, and playing it quickly drains me of brain juice" (Software Inc., 140 saat)
- "Having to micro manage the vacations of workers is just annoying and tedious." (Startup Panic, 1 saat)
- **Doğuran karar:** her çalışanın tek tek atanması, izne yollanması, bileşen üretiminin tek tek tıklanması. Ölçek büyüyünce iş aynı oranda büyüyor, otomasyon geride (Software Inc. yorumcusu: otomasyonu kullanmazsan "micromanagement hell").
- **Bizde:** karta kişi atamayı sistem yapıyor (OYUN_SISTEMLERI.md:24) ve 50 kişide sprint başına 2 ya da 3 eylem (:68): doğru yönde. Ama moral ve izin (aşağıda SP) ayrı risk.

### T06 Opak sayılar, "neden bilmiyorum" (9 oyunda, %6)
En yoğun: Game Dev Tycoon 31/240, Software Inc. 31/211.
- "hidden, arbitrary rules and formulas which are impossible to keep track of" (Game Dev Tycoon, 30 saat)
- "I just don't understand what makes for a good game vs a bad one." (Game Dev Tycoon, 4 saat)
- "there are formulas you have no idea about working behind it" (Software Inc., 6 saat)
- "What do the numbers mean?" (Moviehouse, 3 saat)
- "Ambiguity in the feedback will have you scratching your head" (Game Dev Tycoon, 4 saat)
- **Doğuran karar:** sonuç puanı çok girdiye bağlı, rapor ise "daha çok şuna odaklan" kadar belirsiz. Game Dev Tycoon'da oyun puanı üç sliderın gizli bir oranına, hype'a ve bir önceki oyuna bağlı ve oyun bunları adlandırmıyor.
- **Bizde:** memnuniyet satırlarla yazılıyor (OYUN_SISTEMLERI.md:149), bu iyi. Ürün uyumu ve sektör vurgusu (:120-123) aynı biçimde okunmazsa aynı kalıba düşer.

### T07 Adaletsiz rastgelelik (7 oyunda, %3)
Game Dev Tycoon 36/240, Startup Panic 10/53.
- "The gameplay is too random and it's difficult to plan a solid strategy" (Game Dev Tycoon, 38 saat)
- "You seem to be punished for being innovative and experimenting." (Game Dev Tycoon, 5 saat)
- "it's stupidly unfair" ve "this create a fake difficulty" (Startup Panic, 6 ve 5 saat; rakibin ve RNG'nin zorluğu yükseltmesi)
- **Doğuran karar:** sonucu belirleyen girdi (RNG ya da gizli oran) oyuncunun hamlesinden bağımsız ve görünmez. Startup Panic'te rakip, "zorluk" olsun diye rastgele güçleniyor.
- **Bizde:** "durup dururken düşüş yok" kuralımız (QCD paketi §4) tam bu şikâyetin panzehiri. Ama bütçe kesintisi (OYUN_SISTEMLERI.md:169, "ürüne bağlı olmayan") bu kuralın dışına çıkıyor.

### T08 Çok kolay / T08b çok zor (6 ve 10 oyunda, %2 ve %3 düzeltilmiş)
Aynı oyunda ikisi birlikte çıkıyor: oyuncu "ilk saat çok zor, sonra çok kolay" diyor.
- "Impossible to fail, the game is really easy." (Big Ambitions, 57 saat)
- "This game is too easy." (Software Inc., 19 saat; "Impossible" zorlukta 500 milyon)
- "It gets way too easy even on the harder modes." (Mad Games Tycoon 2, 7 saat)
- "it's way too hard at the moment, even on the Easy Difficulty" (Startup Panic, 4 saat)
- "early game is IMPOSSIBLE to stay afloat" (Moviehouse, 3 saat): ilk yıllarda iflas yorumları.
- **Doğuran karar:** erken oyunda sermaye ya da kredi kuralı (Big Ambitions sınırsız kredi; Software Inc. ilk üründe ya iflas ya milyon). Zorluk eğrisi ters: başta dik, sonra düz.
- **Bizde:** QCD paketi §6 madde 2 (servis gideri kalkınca ilk yıl fazla kolay).

### T09 Hata, çökme, performans (14/14 oyunda, %21; B grubunda %41, C grubunda %47)
- "The game frankly isn't finished and is a buggy mess." (Football Manager 2024, 142 saat)
- "it crashes constantly" (Mad Games Tycoon 2, 5 saat)
- "unable to save, overflow error." (Software Inc., 154 saat; "then all is lost")
- Bakery Cafe Simulator: "All progress made during the day is lost" (4 saat); gün içi ilerleme çökmede siliniyor.
- **Doğuran karar:** küçük ekip, dar test; EA'da sürüm kaydı bozulabilir. Kayıp ne kadar uzun sürerse öfke o kadar büyüyor.
- **Bizde:** kayıt şeması 17 ve göç (CLAUDE.md §6). Hata bütçesi "kayıt kaybı" olarak sınırlanmalı: §8 madde 9.

### T10 Arayüz kalabalığı (9 oyunda, %8)
Software Inc. 39/211, Startup Company 26/235, Big Ambitions 29/252.
- "dated and clunky UI" (Mad Games Tycoon 2, 15 saat)
- "Can only open one window at each time" (Startup Company, 13 saat)
- "the UI is a mess, the whole layout is clunky" (Software Inc., 0 saat)
- Game Dev Tycoon: yeni ofis teklifi cevaptan sonra yeniden geliyor, "i said not yet" (41 saat).
- **Doğuran karar:** bilgi pencerelere gömülü, aynı anda yalnız bir pencere; popup'lar oyuncunun cevabından bağımsız tekrar ediyor.

### T11 Metin ve çeviri (2 oyunda ≥3, toplam 18 eşleşme, %1)
- "contains a good amount of spelling mistakes" (Startup Panic, 8 saat)
- Hotel Business Simulator: Almanca çeviri "malfunctioning AI" diye alay ediliyor (0 saat).
- Bakery Cafe Simulator: "The English translation is pretty bad in this game."
- Mad Games Tycoon 2: Arapça ve Çince çeviri istekleri.
- **Not:** örneklem İngilizce olduğu için çeviri şikâyetleri alt sayılıyor. Bizim oyun TR ve EN çıkıyor; Türkçe ve İngilizce okurun metin kalitesine duyarlılığı bu örneklemden ölçülemedi.

### T12 Terk edilen Erken Erişim, yapımcı güveni (13 oyunda, %5; B grubunda %16)
- "it has now been there for 5 years" (Software Inc., 46 saat)
- "devs took the money and ran" (Hotel Business Simulator, 5 saat)
- "3 MONTHS LATER AND NOT A SINGLE UPDATE" (Parking Tycoon 2, 1 saat)
- "Hasn't been updated in months." (Business Simulator 2026, 0 saat; yorumcu yapımcının birden çok oyuna dağıldığını yazıyor)
- **Doğuran karar:** satış sonrası yama ve iletişim yok. Yorum güncellenmeyi puana çeviriyor: B grubunda üç yorumdan biri bunu yazıyor.

### T13 Fiyat ve içerik miktarı (12 oyunda, %7; B grubunda %16)
- "basically paying 40£ for a database update" (Football Manager 2024, 83 saat)
- "More than a sequel this is hardly a paid update." (Mad Games Tycoon 2, 12 saat)
- "Estimated time to complete the game is 10 to 15 hours." (Hotel Business Simulator, 9 saat)
- "Literally within 6-8 hours you are already at the end of the game" (Hotel Business Simulator, 12 saat)
- Parking Tycoon 2: "This game appears to be a demo, more than a beta or early access version." (6 saat)
- **Doğuran karar:** fiyat/içerik oranı: "1 dolar = 1 saat" beklentisi, devam oyununun aynı oyun olması.

### T14 Yapay zekâ üretimi (§6)

### T15 Sığlık (8 oyunda, %5; Game Dev Tycoon %13, Big Ambitions %21)
- "A glorified Cookie Clicker." (Startup Company, 4 saat)
- "the game is basically just sleep simulator" (Big Ambitions, 7 saat)
- "90% of this game is walking from building to building" (Big Ambitions, 7 saat)
- **Doğuran karar:** iş yapmak yerine yürümek ve uyumak (Big Ambitions); iş yapmak yerine tıklayıp beklemek (Startup Company). "Simülasyon etiketi var, simülasyon yok" hissi.

### T16 Anlamlı karar yok, tek formül (7 oyunda, %3; Game Dev Tycoon %19)
- "the game rates your latest creation based on your previous creation" (Game Dev Tycoon, 5 saat) ve "your next game will 100% flop unless you pull out an A++".
- "straight-up puzzle strategy game with an optimal solution than anything" (Mad Games Tycoon 2, 23 saat).
- "surprisingly limited amount of meaningful decisions to make" (Software Inc., 15 saat).
- **Doğuran karar:** sonuç tek bir optimum ayara bağlı; oyuncu wiki'ye gidip oradan oynuyor. Yaratıcılık cezalanıyor.

## 5. Karışık ve olumsuz oyunlar: nerede battı
Her oyun için üç kök neden, yorumlara göre.

**Startup Company (%81, yakın komşu)**: (1) kilometre taşları zorunlu ve oyunu öğreticiye çeviriyor: "You must follow the "milestones" or lose the game" (1 saat); (2) bileşen üretiminde mikro yönetim ve tıklama ("A glorified Cookie Clicker", 4 saat); (3) orta ve geç oyun boş (T04/T05). 1.0 yeniden dengelemesi kampanya ve öğreticiyi eski oyuncu için oynanamaz yaptı (34 saat, özet). Mekanik dökümü R2'de, tekrar edilmedi.

**Big Ambitions (%92, yakın komşu, "zayıf" değil)**: iyi başlıyor ve çok seviliyor. Yorumlar: mikro yönetim (yürü, sür, uyu), orta oyunda iş yok, "unlimited loans" ile çok kolay. "no mid or end game" yorumu 47 beğeni almış. AI konusu §6.

**Startup Panic (%55, 2022)**: (1) **moral ve izin mekaniği** oyunu bozuyor: "from constantly micro-managing employees' morale" (10 saat), "Why does their motivation drop to 20 after a single task?" (1 saat). Moral 80'in altında iş kalitesi düşüyor, bu yüzden her projeden sonra tüm ekip izne gidiyor ("Fail task. Go on vacation." 2 saat, 84 beğeni). (2) Rakibin rastgele güçlenmesi ("fake difficulty"). (3) QoL eksikleri: "Select all" yok, eğitim ve izin tek tek; yapımcı terk etmiş, başarım hataları. **Bizim moral sistemi için doğrudan ders.**

**Moviehouse (%32, 2023)**: (1) erken oyunda iflas ("early game is IMPOSSIBLE to stay afloat", 3 saat); (2) eleştirmen puanına kilitlenme: "Heavily controlled by critic score" (33 saat); (3) "What do the numbers mean?" (3 saat) ve "click-a-ton" arayüz. Game Dev Tycoon kalıbının zayıf kopyası.

**Hotel Business Simulator (%46, 2024)**: (1) içerik azlığı: 6 ile 15 saatte bitiyor; (2) yapımcı iletişimi yok, tek güncelleme ("one update since release date"); (3) kontrol ve uyku mekaniği saati kesiyor; (4) AI açıklaması "Art assets generated by artificial intelligence" ve "bad asset flip" şikâyeti.

**Parking Tycoon 1 ve 2 (%64 ve %39)**: Devam oyunu, bir öncekinin yeniden boyanmış hâli ("a reskin with a few visual touchups"); EA'da NPC yol bulma hataları; "no updates". Parking Tycoon 2 yorumlarında "repaints and rereleases this slop constantly" yapımcı üretim tarzına işaret ediyor.

**Ortak desen.** Zayıf oyunların üçü de aynı üç şeyi birlikte yaşıyor: çekirdek döngü ilk saatlerde tükeniyor, hata yoğun, yapımcı sessiz. Çok olumlu oyunlar çekirdek şikâyetini taşıyor ama oyun sağlam ve yaşıyor. Yani **çekirdek döngü %90 için gerekli ama yetmez; çalışma ve yaşama zemini baştan şart.**

## 6. Yapay zekâ üretimi (c)
### 6.1 Steam'in kuralı
Steam mağaza sayfasında "AI Generated Content Disclosure" bölümü var; yapımcı kendi cümlesiyle yazıyor (Big Ambitions: "We only used AI to translate the game into more languages"). Steamworks anketi neyi kapsadığını yazıyor: "content such as artwork, sound, narrative, localization, etc." (https://partner.steamgames.com/doc/gettingstarted/contentsurvey). Verimlilik araçları dışarıda; **oyuncuya sunulan yazı ve çeviri içeride.**

### 6.2 Örneklem
Son İngilizce yorumlar, olumlu ve olumsuz birlikte (`filter=recent&review_type=all`):
| Oyun | Skor | N | Olumlu | Üretken AI anan yorum | Açıklama |
|---|---|---|---|---|---|
| Big Ambitions | %92 | 350 | %86 | 9 kesin (5 olumsuz, 4 olumlu); ham eşleşme 14 | Yalnız çeviri |
| Business Simulator 2026 | %73 | 108 | %81 | 5 gerçek (4 olumsuz) | Yapımcı: mağaza ve oyun görselleri AI yardımlı |
| Hotel Business Simulator | %46 | 90 | %46 | 2 (alay + "asset flip") | "Art assets generated by artificial intelligence" |
| Parking Tycoon 2 | %39 | 62 | %45 | 0 (olumsuz örneklemde 1 "slop") | "AI-generated artifacts" |
| Vending Machine BS | %74 | 112 | %77 | 1 ("asset flip") | var |
| Bakery Cafe Simulator | %70 | 159 | %79 | 2 (1 olumlu, 1 olumsuz) | var |
| Farming & Supermarket Sim | %79 | 171 | %75 | 3 (2 olumsuz) | Mağaza görselleri ve bazı oyun içi görseller AI |
Kural: yalnız "üretken AI, slop, asset flip, AI görseli/sesi" geçen yorum sayıldı; oyun içi yapay zekâ (NPC AI) çıkarıldı. Sayılar küçük: AI itirazı hiçbir oyunda yorumların %5'ini geçmiyor.

### 6.3 Oyuncu neye bakıp "AI slop" diyor
1. **İlk ekran.** "my eyes were assaulted by some of the worst AI art" ve "main screen background" (Farming & Supermarket Sim, 0 saat); "it uses AI within the first cutscene" (Business Simulator 2026, 0 saat); "change the game's title image, something not AI generated" (aynı oyun, 4 saat). İki yorumcu oyunu **hiç oynamadan** (0 saat) karar veriyor.
2. **Mağaza sayfası.** "I can feel a LOT more gAI in the game than just the 'steam capsule'" (Bakery Cafe Simulator, 9 saat): açıklamadaki "yalnız mağaza görselleri" ile oyundaki hissin uyuşmaması.
3. **Oyun içi yazı ve görsel öğeler.** Big Ambitions'ta billboard'lar, işletme logoları, sinema posterleri: "The other businesses in this game all have AI logos." (0 saat), "Undisclosed AI usage, particularly obvious in billboards." (1 saat), "AI assets used in cinemas with no disclosure." (1 saat).
4. **Açıklama zamanı.** En sert yorumlar açıklamasız satılıp sonradan eklenen için: "there was no disclaimer about the AI generated content" (37 saat); "adding the disclaimer is a scummy move" (aynı yorum); bir yorumcu üç yıl sonra iade alamadığını yazıyor. Burada öfke AI'ya değil **sürpriz**e.
5. **Yapımcı örüntüsü.** "the dev will promote their EIGHT!!! upcoming AI games of similar style" (Business Simulator 2026, 17 saat); "That's because the creator repaints and rereleases this slop constantly." (Parking Tycoon 2, 5 saat); "This developer uses AI slop now." (Mad Games Tycoon 2, 123 saat, yıllanmış oyuncu). "Slop" burada kalite sözcüğü: ucuz, çok, sessiz yapımcı.
6. **Jenerik his.** "Generic Assets AI ANIMATIONS low creativity" (Business Simulator 2026, 0 saat), "it just feels like a bad asset flip" (Hotel, 3 saat), "Just another asset flip" (Vending, 0 saat). Üretken AI olmasa da paket aset hissi aynı etiketi alıyor.

### 6.4 Puana etkisi
- Big Ambitions'ta AI itirazı son 350 yorumda %3 (9/350); olumsuz örneklemde (252) ham eşleşme 11, yani %4. Yamayla kaldırınca yorumcular değiştirdi: "AI removed" (36 saat), "so im happy to switch my review to positive" (44 saat), "they have all been completely removed with the September 10th patch" (71 saat). Yani **açıklama ve düzeltme puanı geri getirdi**.
- Big Ambitions son 350 yorumda %86 olumlu; AI şikâyeti puanı batırmadı.
- Düşük puanlı oyunlarda (Hotel, Parking Tycoon 2) AI alıntıları az; asıl yorum hata, terk, azlık (§5). **"AI slop" çoğu zaman terk edilmiş ve ucuz hissi veren oyunun üstüne yapışan etiket.**
- Sektör ölçeği: Lemmy'de aktarılan bir PC Gamer haberine göre AI açıklaması olan oyunlar ilk ayda daha az yorum alıyor (ortalama 4'e 7) ve puanı düşük `[ikincil, doğrulanamadı: https://lemmy.world/comment/24376934]`. Creative Bloq'a göre AI yapılmamış oyunlara da "AI slop" yazılıyor `[ikincil, sayfa gövdesi okunamadı: creativebloq.com/ai/ai-slop-has-become-a-harmful-insult-hurled-around-with-no-evidence-game-developers-claim]`.

## 7. Çıkarım: nereye bakıp kızıyorlar (yedi başlık)
1. Çekirdek döngü: aynı üç hareketin tekrarı ve bir noktada karar yerine bekleme.
2. Sayı okunmuyor: "neden" sorusuna oyun cevap vermiyor.
3. Ceza haksız hissi: gizli oran, RNG, başarıyı cezalandıran ölçüt.
4. Angarya: tıkla, izne yolla, yürü, uyu.
5. Zemin: çökme, kayıt kaybı, terk, az içerik.
6. İlk ekran ve açıklama: AI ya da jenerik his; açıklamayla oyun uyuşmuyor.
7. Zaman: vaat 5 ile 10 saatte tükeniyor.

## 8. Project Unicorn için kaçınılacaklar (10 madde)
Her maddede: kanıt, bizde hangi sisteme denk geliyor, bugünkü tasarımda durum (`OYUN_SISTEMLERI.md` satırı), kural. Nasıl çözüleceği OYNANIS_HUKMU'na ait; burada "ne olmasın" yazılır.

**1. Açıklanamayan ya da göreli puan.**
- Kanıt: T06 31/240 ve 31/211; "hidden, arbitrary rules and formulas" (Game Dev Tycoon); "the game rates your latest creation based on your previous creation"; "What do the numbers mean?" (Moviehouse).
- Sistem: memnuniyet, ürün uyumu, sektör vurgusu, kalite alanları, kapanış raporu.
- Durum: memnuniyet "görünen satırların toplamı" (:149) iyi. Ürün uyumu = 70 × uyum, sektör ağırlıkları, Çekirdek tavan kuralı (:111-123) tek cümlede okunmazsa Game Dev Tycoon kalıbı. "Plan hatayı hesaplar ama göstermez" (:78) kararı bekliyor; gizli kalırsa "neden hata çıktı" sorusu çıkar. Evre geçişinde pazar beklentisinin yükselmesi (:119) "iyi işimi cezalandırıyor" diye okunabilir.
- Kural: oyuncunun gördüğü her düşüş ve artış adı yazan bir satırla biter. "Neden" sorusuna ekranda cevap yoksa mekanik kesilir.

**2. Çözülmüş oyun, tek doğru cevap.**
- Kanıt: T16 46/240 ve 16/144; "straight-up puzzle strategy game with an optimal solution" (Mad Games Tycoon 2); wiki'den oynama.
- Sistem: sprint önerisi, Çekirdek baskın kuralı, sektör vurgu tablosu.
- Durum: plan "öneriyi uygula, istersen değiştir, başlat" (:24) ve 50 kişide kart seçmeden 2 ile 3 eylem (:68). Öneri sırası otomatik dolduruyor (:25-26). Çekirdek baskın (:121). Oyuncu önerinin hep doğru olduğunu keşfettiğinde "algoritma gibi oyna" kalıbına düşer.
- Kural: öneri her zaman bir takas bırakmalı (hız mı, hata mı, söz mü); en iyi hamle aynı kalıba oturmamalı; oyuncu önerinin dışına çıktığı için *kazanabilmeli*.

**3. Orta ve son oyunda karar kalmaması.**
- Kanıt: Big Ambitions "no mid or end game" (26/252 T04), Startup Company "watching paint dries", Mad Games Tycoon 2 "nothing ... can stop you".
- Sistem: yenileme, ürün uyumu, giderler, sunucu.
- Durum: QCD paketi §6 madde 1. "Bakımlı üründe hepsi zamma açık çıkıyor" (:167). Ürün uyumu imzaların %75'inde 100'e doyuyor (:111). Yani para akmaya başlayınca karar kalmıyor, Big Ambitions ile aynı.
- Kural: her evre yeni bir karar türü getirmeli; kâr artarken baskı da artmalı ya da kâr yeni bir seçim açmalı. Para fazlası "sayı büyüyor" olmamalı.

**4. Angarya moral, izin ve mikro yönetim.**
- Kanıt: Startup Panic moral/izin döngüsü ("Fail task. Go on vacation."); Startup Company "micromanage your micromanagers"; Big Ambitions yürü/sür/uyu.
- Sistem: ekip moral, destek payı, uyumsuz iş, acil durum bedeli, hesaplar tablosu, sprint planı.
- Durum: uyumsuz işte çalışan sprint kapanışında eksi 2 moral alır (:51); gece düzeltmesinde eksi 10 ya da eksi 7 (:221). Bu belgede izin ve destek payı yok; moral düşünce oyuncunun onu nasıl onaracağı tanımlı değil. Startup Panic'in kalıbı tam budur: moral düşer, onarmak için tur harcanır.
- Kural: moral yüzünden oyuncunun her sprint sonrası el ile yapacağı bir iş olmayacak. Moral düşüşü bir *seçim* sonucu olmalı, ayrı bir işin sonucu olmamalı. Hesaplar tablosunda 50 hesabın hepsinin ayrı yönetimi gerekmemeli.

**5. Dayatılan rastgelelik.**
- Kanıt: Startup Panic "fake difficulty"; Game Dev Tycoon "punished for being innovative"; FM "scripted".
- Sistem: acil durum (gece kesintisi), bütçe kesintisi, söz olayı, karar kâğıdı.
- Durum: acil durumun olasılığı yük, hata ve sürüm kalitesinden geliyor (:198, CLAUDE.md §6): iyi. **Bütçe kesintisi** (:169) ürüne bağlı olmayan, düşük ihtimalli: "durup dururken düşüş yok" kuralıyla çelişiyor ve T07 tanımının kendisi.
- Kural: her olumsuz olay oyuncunun görebileceği bir nedene ve oyuncunun etkileyebileceği bir ihtimale bağlı. Nedensiz olay yalnız olumlu ya da nötr olabilir.

**6. Zorluk eğrisinin iki ucu: erken batma ve erken kolaylık.**
- Kanıt: Moviehouse "IMPOSSIBLE to stay afloat"; Startup Panic "too hard ... even on the Easy Difficulty"; Software Inc. (ilk üründe ya iflas ya milyon, özet); Big Ambitions "Impossible to fail"; Mad Games Tycoon 2 "too easy even on the harder modes".
- Sistem: giderler, runway, fon merdiveni, servis gideri.
- Durum: servis gideri kalkınca ilk yılın en derin nakit açığı 41 binden 12 bine iniyor, seed'in nakit gerekçesi kalkıyor (:206); önerilen maaş ×1,5 (:207) karar bekliyor. Bootstrap runway'i kurucu satırından geliyor, 10.000 ÷ 1.500 = 6,7 ay (:205).
- Kural: ilk saatte oyuncu *neden battığını* bir cümlede söyleyebilmeli; ilk yılın kolaylığı da ölçülmeli. Kapı: ilk üç koşuda batma oranı ve ilk yılın en dar noktası.

**7. Sistem şişkinliği.**
- Kanıt: Software Inc. "massive feature creep", "I'm trying to run a company not a fridge", 23/211.
- Sistem: sprint, hata, test, PM, takım, sunucu, memnuniyet, yenileme, kurumsal madde, bütçe kesintisi, kâğıt, söz, sektör vurgusu, giderler.
- Durum: OYUN_SISTEMLERI.md'de on bölüm ve yaklaşık yirmi kural. Çekirdeğe (ekip, sprint, ürün) uzak olan: kurumsal madde (:170), bütçe kesintisi (:169), pazaryeri (E, :231), takım çarpanı (:69-70).
- Kural: her sistem tek satırla okunur ve bir karar doğurur. Doğurmuyorsa kesilir. Yeni sistem eklenmeden önce çekirdeğin orta/son oyun kararı yazılır (madde 3).

**8. Arayüz parçalanması ve akış kesintisi.**
- Kanıt: Startup Company "Can only open one window at each time"; Software Inc. "UI is a mess"; Game Dev Tycoon tekrarlayan ofis popup'ı; Moviehouse "click-a-ton".
- Sistem: Menajer arayüzü, Hesaplar tablosu, olay kartı, kâğıt, mail, gönder sorusu.
- Durum: kart ekranda iken her pencere salt okunur (CLAUDE.md §6). Haftada en çok bir kesinti kuralı var (sıra: acil durum, söz, kâğıt, gönder sorusu); iyi. Risk: aynı haftaya binen kesintiler (QCD paketi §6 madde 5).
- Kural: aynı bilginin iki yerde aranması yok; kart ne soruyorsa cevap için gereken bilgi kartın üstünde; tekrar eden popup yok.

**9. Çökme, kayıt kaybı, terk edilmişlik, içerik vaadi.**
- Kanıt: B grubunda hata %41, terk %16, içerik %16; Software Inc. "unable to save, overflow error"; Hotel "10 to 15 hours"; Parking Tycoon 2 "3 MONTHS LATER AND NOT A SINGLE UPDATE".
- Sistem: kayıt (şema 17), EA/demo/full ayrımı, olay havuzu, yama temposu.
- Durum: demo 60 ile 90 dakika (:15); kâğıt havuzu 40, aynı kâğıt 52 hafta dönmez, koşuda en çok 3 kez (:225). 104 haftada ve birden çok koşuda tekrar hissi (Game Dev Tycoon "same way every time") riski.
- Kural: kayıp en çok bir hafta; satış sayfası vaat ettiğinden fazlasını göstermeli; EA'da yol haritası ve düzenli yama sözü oyun içeriğinden önce gelir; içerik azsa fiyat bunu söyler.

**10. Yapay zekâ şüphesi: ilk ekran, açıklama uyumsuzluğu, metin.**
- Kanıt: §6.3. İlk ekran, mağaza görseli, logo ve billboard, açıklamasız satış, jenerik aset hissi, aynı yapımcıdan çok oyun.
- Sistem: ana menü zemini, mağaza görselleri, 3B ofis varlıkları, olay metni, TR ve EN çeviri.
- Durum: bu repoda *neyin üretken AI ile yapıldığı* bu çalışmada incelenmedi `[kanıtsız]`. Bildiğim: olay metinleri için bir yazar ajanı pilotu çalıştı (bellek notu: Yazar ajanı pilotu 2026-10-08), ofis 3B karakterleri paket asetlerinden, ve Steamworks "narrative, localization" kalemlerini açıklama kapsamına alıyor. Paket asetlerin "asset flip" etiketini alması da kanıtlı (Hotel, Vending).
- Kural: Steam açıklamasının içeriği oyundakiyle birebir olmalı. Ana menü, ilk ara sahne ve mağaza görseli özel el yapımı ve ilk saniyede okunur olmalı. Açıklama lansmandan önce yazılır, sonradan eklenmez. Karar Erdem'in: açıklamaya ne yazılacağını ben seçmiyorum.

## 9. Bizim tasarımın hangi kalıba düşme riski var
Kalıp adı = o kalıbı yaşayan oyun. Risk: **yüksek / orta / düşük** (benim yorumum; kanıt sütunu bu rapordan).

| Kalıp | Risk | Neden bizde | Kanıt |
|---|---|---|---|
| **Game Dev Tycoon**: slider, bekle, tek formül, göreli puan | **Yüksek** | Plan: öneriyi uygula, başlat, bekle (OYUN_SISTEMLERI.md:24, :68); 50 kişide 2 ya da 3 eylem; Çekirdek baskın ve sektör tablosu (:121-123) tek optimum üretir | T16 %19, T06 %13, T01 %20 |
| **Big Ambitions**: ilk 5 ile 10 saat güzel, sonra boş | **Yüksek** | Yenileme zamla bitiyor, ürün uyumu 100'e doyuyor, bakımlı üründe kayıp yok (:111, :167) | T04 %10, T15 %21 |
| **Startup Panic**: moral ve izin angaryası | **Orta** | Moral eksi 2/eksi 10 bedelleri (:51, :221), destek/izin taslağı; sprint sonu tablo | T05, SP alıntıları |
| **Startup Company**: zorunlu kilometre taşı ve tıklama | **Orta** | Series A kapısı tek yol (CLAUDE.md §1); sprint başına üç eylem | T05 %19, "milestones" şikâyeti |
| **Software Inc.**: özellik sürünmesi, EA'da uzayan yol | **Orta** | Yirmi kural, E pazaryeri, Erken Erişim planı | T02 %11 |
| **Moviehouse**: erken iflas, kilit puan | **Orta** | İlk yıl dengesi belirsiz (:206 servis kalkması) ve imza kapısı 10 puan (:142) | T08b, "IMPOSSIBLE" |
| **Hotel / Parking Tycoon**: az içerik, terk | **Düşük** | Demo ve içerik bütçesi var; kâğıt havuzu 40 tekrar riski | B grubu T12/T13 |
| **Üretken AI şüphesi** | **Bilinmiyor** | Yazar ajanı, paket asetler, TR çeviri; açıklama kararı Erdem'de | §6 |

## 10. Erdem'e sorular (yalnız bu rapordan çıkanlar, en çok 4)
1. **Bütçe kesintisi** (:169) "durup dururken düşüş yok" kuralıyla çelişiyor ve T07 tarifi. Öneri: ya bir nedene bağla (görünür bir şey) ya düşür. *Oynanışa etkisi:* nedensiz kayıp oyuncuya "haksız" gelir ve önlenemez.
2. **Steam AI açıklaması:** olay metninde yazar ajanı kullanıldı, çeviri ve ofis varlıkları paket aset. Hangisi açıklamaya girecek? Öneri: lansmandan önce yaz ve ana menü, ilk ara sahne, mağaza kapsülü el yapımı olsun. *Oynanışa etkisi:* dolaylı; mağaza yorumlarında ilk 0 saatlik "slop" yorumlarını önler.
3. **Ana menü ve ilk ara sahne** (§6.3, madde 1): oyuncu oyunu açmadan karar veriyor. Öneri: bu iki yüzeye özel iş zamanı ayrılsın.
4. **Tam oyun kapısı** (§2): olumsuz yorumların %46 ile %61'i ilk 10 saatte yazılıyor. Demo bu eşiğin altında kalıyor; öneri: satın alma sonrası ilk 10 saat için *ayrı* bir ölçüm ve kapı olsun. *Oynanışa etkisi:* demoda iyi görünen döngü tam oyunda tükenebilir.

## 11. Kaynaklar
- Steam yorum API'si: `https://store.steampowered.com/appreviews/<APPID>` (APPID'ler §1.1).
- Mağaza arama ve ayrıntı: `https://store.steampowered.com/api/storesearch/`, `https://store.steampowered.com/api/appdetails`, mağaza sayfaları (`AI Generated Content Disclosure` bölümü).
- Steamworks içerik anketi: https://partner.steamgames.com/doc/gettingstarted/contentsurvey
- İkincil, doğrulanamayan: https://lemmy.world/comment/24376934 ; creativebloq.com/ai/ai-slop-has-become-a-harmful-insult-hurled-around-with-no-evidence-game-developers-claim
- İç kaynaklar: `docs/tasks/faz_cde/OYUN_SISTEMLERI.md`, `QCD_GOREV_PAKETI.md`, `CLAUDE.md`.
