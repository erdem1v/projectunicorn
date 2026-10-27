# R13: Ovulen ne? Steam'de %90 üstü yönetim oyunları ve yorumlarda övgü

Tarih: 2026-10-18. Konu: eğlence ve akış. Mekanik dökümü yok; mekanik için R1, R2, R3'e bak.
Kullanım: `OYNANIS_HUKMU.md` ve Faz Q, C, D PRD'lerinin oynanış bölümleri bu belgeden beslenir.

## 0. Okuma notu (önce bunu oku)

**Ne yapıldı.**
- 11 oyunun APPID'si Steam mağaza API'sinden doğrulandı (`appdetails`). Hiçbiri değişmedi.
- Her oyun için Steam `appreviews` API'sinden İngilizce yorumlar okundu: en yeni 300 olumlu ve en yeni 300 olumsuz yorum (olumsuz 300'den azsa hepsi: MGT2 163, Two Point Hospital 99).
- Özet sayılar (toplam olumlu, olumsuz) aynı API'nin `query_summary` alanından, 2026-10-18'de alındı. Yalnız İngilizce yorumları sayar.
- Temalar iki yolla sayıldı: (1) her oyundan 36 ile 50 olumlu ve 18 ile 25 olumsuz uzun yorumu (20 kelime ve üstü) tek tek okudum (Reigns'te yalnız 12 ve 14); (2) bu okumada çıkan 14 olumlu ve 8 olumsuz tema için anahtar sözcük kalıbı yazıp 300 yorumun hepsine uyguladım. Sayılar "300 yorumdan kaçında bu tema geçiyor" demektir.
- Alıntılar en çok 15 kelime ve tırnak içindedir. Her alıntının sonunda `[appid/yorumid]` vardır; EK C'de her birinin Steam adresi, tarihi ve oynama süresi durur.
- Dış kaynak: 3 WebFetch, 1 WebSearch (aşağıda adreslerle). Steam API'ye yaklaşık 250 HTTP isteği gitti (bir kısmı 429 hız sınırına takılıp yeniden denendi).

**Sayıların sınırları (dürüst olmak için).**
- Anahtar sözcük sayımı kaba. "Anlamlı zor karar" teması `decision`, `choice`, `challenge`, `difficult` gibi sözcükleri toplar; bu yüzden şişkindir. Sıralamaya güven, mutlak yüzdeye güvenme.
- Olumlu yorumların çoğu kısa. Ortanca uzunluk: GDT 11 kelime, FM24 5 kelime, Papers 6,5 kelime, STS 7 kelime. Bu yüzden FM24'te 300 yorumun yalnız 45'i herhangi bir temaya düştü (GDT 99, ATS 184). Payları alt sınır say.
- "En yeni" örneklem güncel olaylara kayıyor: RimWorld olumlu örneği yalnız 10 günü kapsıyor (2026-10-09 ile 10-18) ve 1.7 motor güncellemesinden sonra (300'ün 45'i motor veya 1.7'yi anıyor). FM24'te 300'ün 41'i FM26 ile kıyaslıyor ("son iyi FM"). STS olumsuzlarında 16 yorum oyun dışı tartışmalara (yapımcının danışmanı, devam oyunu) değiniyor. Bunları temaların içinde ayrı gösterdim.
- Olumsuz yorumlar çoğunlukla ilk saatlerde yazılır (EK A). Bu, "ilk saat" bölümleri için iyi kanıt, "son oyun" bölümleri için zayıf kanıt.
- Dakika dakika döngü, karar yoğunluğu, tik sayısı, ses ve animasyon satırlarının büyük kısmı model bilgisidir. Yorumla ya da dış kaynakla desteklenmeyen her satırda `[kanitsiz]` yazar. Saatte karar sayıları `[tahmin]`.
- Tik tanımı: bizim oyunda 1 tik = 1 hafta. Başka oyunda "tik" = o oyunun oyuncuya sunduğu en küçük tekrar birimi (gün, tur, başvuru).

**Dış kaynaklar.**
- RimWorld resmî sayfası: https://rimworldgame.com/ (hikâye anlatıcı, döngü).
- Papers, Please: https://en.wikipedia.org/wiki/Papers,_Please (gün yapısı, ceza, 20 son, sonsuz mod, tasarım gerekçesi).
- Against the Storm: https://en.wikipedia.org/wiki/Against_the_Storm_(video_game) (koşu uzunluğu, meta ilerleme, Metacritic 91).
- Slay the Spire GDC 2019 konuşması (özet, ikinci el): https://www.gamedeveloper.com/design/learn-i-slay-the-spire-i-s-metrics-driven-approach-to-game-balancing-at-gdc-2019 ve https://gdconf.com/news/learn-slay-spires-successful-metrics-driven-approach-game-balancing-gdc-2019 . Konuşmanın kendisi üye girişli, okunmadı.
- Önceki döküm: `R1_SOFTWARE_INC.md`, `R2_STARTUP_COMPANY.md`, `R3_GDT_MGT2.md`. Oradan alıntı yapıldığında dosya adı yazılı.
- Bizim oyun: `CLAUDE.md` (satır numaraları: zaman 80, acil durum 100, söz olayı 107, karar kâğıdı 113, sürüm anı 122, gelir 146).

**Tur dışı iki oyunun seçimi.**
- Slay the Spire: %97,4. Karar döngüsü en akıcı örnek. Karar başına geri bildirim anlık, koşu kısa, ölünce yeniden başlamak bir tık. Bizde "bir sprintte ne yapacağım" kararının akışı bu.
- Papers, Please: %97,2. Masa başı iş. "Yönetici masasında kâğıt ve kural kontrolü" bizim satış, hesap ve sprint kâğıdı ekranlarına en yakın tür dışı örnek. Aynı zamanda "angarya gibi görünen işin neden eğlenceli olduğunun" en açık örneği.
- Reigns önerilmişti: APPID 474750 doğrulandı, ama puanı %83,3. Çıta altında kaldığı için bölüm vermedim. Karşı örnek olarak EK B'de kısa durur; neden düştüğü öğretici.

## 1. Özet tablo (Steam İngilizce yorumlar, 2026-10-18)

| Oyun | APPID | Olumlu | Olumsuz | Toplam | % olumlu | Steam etiketi |
|---|---|---|---|---|---|---|
| Game Dev Tycoon | 239820 | 23.914 | 1.387 | 25.301 | 94,5 | Very Positive |
| Mad Games Tycoon 2 | 1342330 | 2.189 | 163 | 2.352 | 93,1 | Very Positive |
| Software Inc. | 362620 | 5.483 | 331 | 5.814 | 94,3 | Very Positive |
| Football Manager 2024 | 2252570 | 10.800 | 852 | 11.652 | 92,7 | Very Positive |
| RimWorld | 294100 | 140.426 | 2.952 | 143.378 | 97,9 | Overwhelmingly Positive |
| Against the Storm | 1336490 | 20.362 | 1.132 | 21.494 | 94,7 | Very Positive |
| Two Point Hospital | 535930 | 15.306 | 1.293 | 16.599 | 92,2 | Very Positive |
| Frostpunk | 323190 | 43.255 | 3.377 | 46.632 | 92,8 | Very Positive |
| Slay the Spire | 646570 | 89.928 | 2.404 | 92.332 | 97,4 | Overwhelmingly Positive |
| Papers, Please | 239030 | 42.696 | 1.213 | 43.909 | 97,2 | Overwhelmingly Positive |
| (karşı örnek) Reigns | 474750 | 2.366 | 475 | 2.841 | 83,3 | Very Positive (alt sınırda) |

Not: Çıta %90 ise bu tür için gerçekçi bantta çoğunluk %92 ile %95 arası. %97 ve üstündeki üç oyun (RimWorld, STS, Papers) ya sonsuz tekrar oynanır ya da çok kısa tur ve çok net bir kimlik taşıyor (gözlem, kanıt değil). %92 civarındakiler (TPH, Frostpunk, FM24) en çok tekrar, çökme ve lisans şikâyeti alıyor (bölüm 3).

## 2. Oynama süresi ve şikâyet zamanı (EK A'nın özeti)

| Oyun | Olumlu ortanca saat | Olumsuz ortanca saat | Olumsuzların kaçı 5 saatten az |
|---|---|---|---|
| GDT | 13 | 6 | %41 |
| MGT2 | 37 | 8 | %36 |
| Software Inc. | 77 | 8 | %43 |
| FM24 | 691 | 252 | %9 |
| RimWorld | 344 | 84 | %18 |
| Against the Storm | 75 | 7 | %44 |
| TPH | 27 | 10 | %34 |
| Frostpunk | 24 | 6 | %45 |
| STS | 27 | 18 | %22 |
| Papers | 9 | 2 | %74 |

Okuma: Software Inc., ATS, Frostpunk, GDT ve Papers'ın olumsuz yorumlarının yaklaşık yarısı ilk beş saatte yazılmış. FM24 ve RimWorld'ün olumsuzu geç ve sahipli (yayıncı, DLC, güncelleme). Yani %90'ı bozan iki farklı hastalık var: ilk saatte vazgeçirme (anlaşılmazlık, haksız ölüm, angarya) ve geç saatte güven kaybı (fiyat, güncelleme, kırık build).

## 3. Oyun bölümleri

### 3.1 Game Dev Tycoon (239820)

- **Steam:** %94,5, 25.301 İngilizce yorum, 2026-10-18. Çıkış 2013-08-29 (mağaza API).
- **Çekirdek döngü, dakika dakika [kanitsiz, R3 §2 ile uyumlu]:** Oyuncu garajı, bir çalışanı ve üstte tarih/para satırını görür. Bir proje başlatır: konu, tür, platform, hedef kitle. Üç aşamada üç kaydırıcı (9 alan, R3 §2.1). Geliştirme sırasında puan ve hata balonları yükselir. Çıkışta dört eleştirmenin puanı gelir, sonra satış eğrisi. Bir proje birkaç dakika. Kanıt: standart 35 yıllık döngüyü 9 saatte bitiren oyuncu var «Finished the standard 35-year cycle in 9 hours.» [239820/228474315]. İlk oyun 5 saatin altında bitebiliyor [239820/225909447].
- **Tik:** Bir proje birkaç oyun ayı. Oyuncunun tıkladığı "tur" proje başına yaklaşık 15 ila 20 seçim [kanitsiz].
- **Karar yoğunluğu:** Saatte 30 ila 45 seçim, anlamlı olanı 6 ila 10 [tahmin]. Çoğu "doğru kombinasyon" aramasıdır.
- **İlk saat:** Hedef net (garajdan stüdyoya). Öğretim minimum; bir oyuncu «Only reliable way to play is to open a wiki and follow the guide» [239820/202334316] diyor. İlk çıkış büyük olasılıkla kötü puan alır; olumlu yorumlarda bu bir keşif olarak yaşanıyor: «The mistakes you make on your very first run will help you» [239820/228213188]. Aynı ilk koşu olumsuz yorumlarda şikâyet: kılavuza bakmadan oynanmıyor.
- **Orta oyun baskısı:** Kasa ve yeni teknoloji araştırması. Rastgele olay aralığı "36 + 48 × rastgele hafta" (R3 §2.1, resmî mod API). Fazla baskı yok; kasa sıfıra inerse iflas.
- **Son oyun:** Önleyemiyor. «progression feels way to easy on Normal mode» [239820/225909447]. Oyun 35 yılda bitiyor; kısa olması can sıkıntısını sınırlıyor, ama «Weak Replay Value» [239820/154890578] başlıklı yorum gibi şikâyetler var (olumsuz örneklemde 28/300 "sığ, az içerik").
- **Ölçek ve otomasyon:** Ekip alan sayısıyla tavanlı (9 alan, R3 §1). Otomasyon yok; karar kaymıyor, oyun zaten kısa.
- **Geri bildirim:** Ana ödül anı eleştirmen puan ekranı ("Watch the reviews come in" [239820/237532429]). Aynı yer en büyük şikâyet: «reviews seem to be random no matter how much i try to balance» [239820/199419813]. Yani hem dopamin hem öfke aynı ekrandan. Bir oyuncu puan ekranının atlanabilmesini istiyor «skip animations like the game score reveal» [239820/234737239]: animasyon ilk sefer ödül, yüzüncü sefer angarya.
- **En çok övülen 5 tema (n/300):** bir proje daha, saat nasıl geçti 34 · anlamlı karar ve gerilim 21 · büyüme hissi 18 · rahat, doyurucu his 17 · tekrar oynanır 14 (geliştirici desteği ve mod de 14; öğrenmesi kolay 13). «something incredibly satisfying about starting in a tiny garage with almost nothing» [239820/230380753] ve «Man I just can't stop failing restarting winning» [239820/225143809].
- **En çok şikâyet 3 tema (n/300):** tekrar ve sıkıcılık 62 · şans, haksızlık, deneme yanılma 58 · hata, çökme, performans 39 (Windows 11 bellek sızıntısı). Dördüncü: arayüz, açıklama, öğretim 27.

### 3.2 Mad Games Tycoon 2 (1342330)

- **Steam:** %93,1, 2.352 İngilizce yorum. Çıkış 2023-05-31 (mağaza API).
- **Çekirdek döngü [kanitsiz, R3 §2.4]:** Oyuncu 1976'da bir garaj, odalar (geliştirme, araştırma, QA, grafik, ses) ve çalışanlar görür. Oyun tasarlar (tür, konu, kaydırıcılar), çalışanlara oda atar, çıkarır, satış ve inceleme izler. Oyun gerçek zamanlı akar, oyuncu istediği an bina kurar. Hızı yorumda: «sit down at 9am and it will be 8pm» [1342330/235510802]; «I'll release one more game then I'll quit» [1342330/230599393].
- **Tik:** Oda ve proje başına karar. Saatte tahmini 30 ila 60 seçim, ağırlığı bina ve işe alım [tahmin].
- **Karar yoğunluğu:** Orta, GDT'den yüksek (bina ve kadro ekleniyor) [tahmin].
- **İlk saat:** Çok sayıda oda ve araştırma var, hedef açık ama yol değil: «This game is very hard to understand, but the end goal is clear.» [1342330/232360450] Olumsuzda en sık şikâyet açıklama eksikliği (32/163). Örnek: «You have no clue why your 94% game not sold but 77% like crazy.» [1342330/156104946].
- **Orta oyun baskısı:** Rakip stüdyolar, konsol yarışı, kasa. Büyüme zorunlu, küçük kalmak cezalı: «You must become a large studio» [1342330/140953189]. MMO'nun aşırı güçlü olması yorumlarda tekrar ediyor (R3 ile uyumlu).
- **Son oyun:** Kısmen önleyemiyor: «The core gameplay loop is basically the same as in MGT 1» [1342330/140943244] (olumsuzda tekrar 37/163, %23).
- **Ölçek ve otomasyon:** Oyun otomasyonu seviyor ve kullanıcılar ona minnettar: «I'm glad it can auto decorate the rooms» [1342330/222806962]. Ama otomasyonun kötü tarafı da var: «my automatic research reasearched AAAA games in 1979» ve 100 milyon dolar kaybı [1342330/156137930]. Ders: otomasyon korkulukla verilmeli.
- **Geri bildirim:** Satış düşüşü nedensiz görünüyor: «sales just plummet for literally no reason» [1342330/163243899]. Sayı var, neden yok.
- **En çok övülen 5 tema (n/300):** bir proje daha 36 · derinlik 27 · anlamlı karar 26 · büyüme hissi 25 · sanat, müzik, atmosfer 22.
- **En çok şikâyet 3 tema (n/163):** tekrar ve sıkıcılık 37 · arayüz ve açıklama eksikliği 32 · şans, haksızlık 31 (fiyat 27 hemen arkada).

### 3.3 Software Inc. (362620)

- **Steam:** %94,3, 5.814 İngilizce yorum. Erken erişimde 2015'ten beri (mağaza API).
- **Çekirdek döngü [kanitsiz, R1 §2 ile uyumlu]:** Oyuncu boş bir bina, bir kurucu ve kasa görür. Oda çizer, masa koyar, ürün tasarlar (özellik seçer), çalışan işe alır, ürünü çıkarır, pazarlar, destek yapar. Gerçek zamanlı, hız ayarlı. Bir ürün oyun ayları sürer.
- **Karar yoğunluğu:** Saatte 40 ila 80 mikro karar (bina, masa, işe alım, özellik), anlamlı olanı 8 ila 15 [tahmin]. Yorumlarda «can easily delete an entire afternoon» [362620/214586959] ve «in the first 48h after buying the game i played for 33h» [362620/228670069].
- **İlk saat:** En büyük zayıf nokta. Olumsuz 300 yorumun 96'sı (%32) arayüz ve açıklama eksikliği: «dont explain vital parts of the game» [362620/51475930]; «refunded it after an hour of confusion» [362620/82351786]. Ama sevenler bunu kabul ediyor ve ödüllendiriyor: «your first company will always fail» [362620/227295859]. Yani ilk iflas beklenen ritüel ama öğretici değil.
- **Orta oyun baskısı:** Rakip, bina, çalışan memnuniyeti ve sektör. Olumlu yorumda sistemlerin birbirine bağlı olması öne çıkıyor: «a believable, interlocking model of running a software company» [362620/217731941].
- **Son oyun:** Kısmen önleyemiyor: «after you get the first successful software its basically over» [362620/92628727]. Üstüne denge sorunu: «You go bankrupt and loose the game» ya da ilk üründen milyonlar [362620/72612505]. Güncellemelerle kayıt uyumsuzluğu da şikâyet (olumsuz örnekte 21/300).
- **Ölçek ve otomasyon [R1]:** 20 ila 30 kişi civarı verim tavanı; geç oyunda lider, İK ve proje yönetimi devrediliyor. Tartışmalı (R1 §1 madde 6).
- **Geri bildirim:** Sayılar çok, açıklama az. Küçük ayrıntılar sevildi: «security guard station shows what the connected cameras see» [362620/218169295]. Çalışanın kişiliği güçlü: «employees have opinions, needs, burnout» [362620/218117498].
- **En çok övülen 5 tema (n/300):** derinlik, bağlı sistemler 46 · geliştirici desteği ve güncelleme 44 · bir proje daha 29 · tekrar oynanır 22 · büyüme hissi 21 (fiyatına değer 18). Önemli: geliştirici desteği yorumların %15'i. «a game that gets solid updates for over 10 years is worth a recognition» [362620/220104827].
- **En çok şikâyet 3 tema (n/300):** arayüz, açıklama, öğretim 96 · tekrar, sıkıcılık 56 · hata, çökme 38 (fiyat 29, kayıt/güncelleme 21).

### 3.4 Football Manager 2024 (2252570)

- **Steam:** %92,7, 11.652 İngilizce yorum. Çıkış 2023-11-06. Mağaza API fiyat vermiyor; olumsuz yorum «removed licenses from this game» [2252570/182035065] satıştan kaldırıldığını söylüyor (doğrulanmadı, yorum iddiası).
- **Çekirdek döngü [kanitsiz]:** Masa başı. Oyuncu gelen kutusu, kadro ekranı, taktik tahtası ve takvim görür. "Devam" tuşuna basar; gün geçer; transfer, basın toplantısı, antrenman, maç. Maç günü taktik ve değişiklik. Bir sezon 300 küsur gün; kararlar "Devam" aralarında.
- **Tik:** 1 gün; "Devam" bir tıkla birden çok güne atlayabilir [kanitsiz]. Bir sezon bir iki saat ile yirmi saat arasında (oyuncu stiline göre).
- **Karar yoğunluğu:** Saatte 15 ila 40 anlamlı karar (transfer, taktik, dizilim, sözleşme), maç günü yoğun [tahmin]. Çok boş "Devam" aralığı.
- **İlk saat:** Ağır. «the learning curb can be hard if its your first time playing the franchise» [2252570/232586960]. Ama çıkış yolu var: «i recommend delegating most tasks until you learn the ropes» [2252570/232586960] ve «if you want to play casually, the game is very approachable» [2252570/236431955]. Yani delege etmek öğretim aracı olarak çalışıyor.
- **Orta oyun baskısı:** Sezon hedefi, kadro yaşlanması, transfer penceresi: «how much the transfer windows can determine your season» [2252570/236573355]. Karar kaymıyor, baskı yıllık takvimden geliyor.
- **Son oyun:** Oyuncular çok geç doyuyor: «Gets a bit dull after 20 seasons or so» [2252570/231472201] (8043 saatlik oyuncu). Önleme: bitmeyen kariyer ve veri güncellemesi.
- **Ölçek ve otomasyon:** Asistan yönetici, personel ve scout devrediliyor. Ama devredilmeyen angarya şikâyet: «WAY to many boring press questions you have to click through» [2252570/197444360].
- **Geri bildirim:** Maç özeti (xG, kareler) var. Şikâyet: «Not ONE SINGLE highlight from the 35th to 90th minute» [2252570/199436285] ve sebep görünmüyor: «zero chance to check on the impact that these things have» [2252570/196190442]. Yani sayı var, "oyuncum neden kötü oynadı" cevabı yok.
- **En çok övülen 5 tema (n/300, kapsam düşük):** bir proje daha / zaman kayboluyor 18 · derinlik 13 · tekrar oynanır 7 · plan ve optimizasyon 6 · sanat, atmosfer 5. Oyunda belirleyici tema FM26 ile kıyas ("son iyi FM") 41/300. Hikâye üretimi: «celebrating a second tier french league victory» [2252570/227790810]; «saves on this that have lasted longer than my relationships» [2252570/225232128].
- **En çok şikâyet 3 tema (n/300):** yayıncı, lisans, güncelleme 44 · hata, çökme 35 · şans ve "scripted" maç şikâyeti 30.

### 3.5 RimWorld (294100)

- **Steam:** %97,9, 143.378 İngilizce yorum, çıkış 2018-10-17.
- **Çekirdek döngü (resmî sayfa):** Hikâye anlatıcı AI olayları "kart gibi" dağıtır; oyuncu ruh hâli, sağlık ve ihtiyaçları yönetir, inşa eder, ekin yetiştirir, araştırır, ticaret ve savaş yapar (https://rimworldgame.com/). Dakika dakika [kanitsiz]: durdur, iş önceliği ver, hız aç, olay gelince durdur ve tepki ver.
- **Tik:** Oyun içi saat, gün [kanitsiz]. Oyuncu kararı olay anında (baskın, hastalık, yolcu, kriz) ve planlama anında.
- **Karar yoğunluğu:** Saatte 20 ila 40 karar, ama kararlar olayla bölünüyor, olay yoksa izleme [tahmin].
- **İlk saat:** Zor, şikâyetli: «no story and there is basically no guidance» [294100/224053739]. Hedef: koloniyi büyütüp gemi yapıp gezegenden ayrılmak (resmî sayfa); oyuncu bunu «to win you must build a ship and get out from there» [294100/237596553] diye anlatıyor.
- **Orta oyun baskısı:** Anlatıcı zorluğu ayarlıyor: Randy (rastgele), Cassandra (artan gerilim), Phoebe (rahat). Oyuncu seçiyor (resmî sayfa). Yorumda zorluk kadranı: «chill experience or pure hell depending on what difficulty» [294100/237500155].
- **Son oyun:** Önleyemiyor ama modla çözüyor: olumlu yorumlarda en sık geçen tema geliştirici ve mod (59/300). 50 kişilik koloni oynanıyor: «Endgame colony with 50 pawns» [294100/237640024].
- **Ölçek ve otomasyon:** İş önceliği tablosu, bölgeler, siparişler (bills) ve çizelge; oyuncu elle yapmak yerine kural yazıyor [kanitsiz]. Karar bireyden kurala kayıyor.
- **Geri bildirim:** Olay günlüğü, ruh hâli sebep listesi, uyarı mektupları [kanitsiz]. Övülen şey sebep ve sonucun hikâyeye dönmesi: «Started alone, naked. A 'friend' arrived, I have been stabbed.» [294100/237464542]; «died in the hundreds because of a bug breach. absolute cinema.» [294100/237748064]; «Always new stories and new characters to make» [294100/237820386].
- **En çok övülen 5 tema (n/300):** geliştirici ve mod 59 · tekrar oynanır 27 · bir proje daha 16 · hikâye ve unutulmaz an 15 · anlamlı karar 14 (fiyatına değer 13).
- **En çok şikâyet 3 tema (n/300):** fiyat ve DLC 99 (tek başına %33) · tekrar, sıkıcılık 48 · şans, haksızlık 37. Ders: %97,9 olan oyunda bile olumsuzun üçte biri fiyat. Örnek: «you can't have kids if you don't buy the biotech DLC» [294100/219106829].

### 3.6 Against the Storm (1336490)

- **Steam:** %94,7, 21.494 İngilizce yorum, çıkış 2023-12-08. Metacritic 91 (Wikipedia).
- **Çekirdek döngü (Wikipedia + yorumlar):** Bir koşu bir yerleşim; yaklaşık bir saat (Rock Paper Shotgun'a atıf, Wikipedia), oyuncular 1 ila 2 saat diyor: «you progress through settlements in 1-2 hours» [1336490/234056267]. Dakika dakika: harita açılır, kaynak ve bina seçilir, işçi atanır, mevsim akar, fırtına yaklaşır, krallığın sabırsızlık göstergesi dolar. Ödül: yerleşim sonunda kalıcı meta ilerleme.
- **Tik:** Mevsim ve olay [kanitsiz]. Karar noktası bina ve takas seçimi.
- **Karar yoğunluğu:** Yüksek: saatte 60 ila 100 anlamlı karar (bina tercihi, işçi, takas) [tahmin]. Yorum: «every decision matters» [1336490/236841979].
- **İlk saat:** Mixed. Eğitim bölümü bazı oyuncuları kaybettiriyor: «onboarding is overloaded and unclear» [1336490/217467789]. Olumsuz yorumların %28'i 2 saatin altında (EK A).
- **Orta oyun baskısı:** 24 zorluk ayarı: «24 difficulty settings» [1336490/237408086]; her yerleşimde yeni sınır, mühür tamir etme hedefi.
- **Son oyun:** Çok iyi önlüyor: «Practically never hits that wall you usually get in city-builder type games» [1336490/233563283]. Yöntem: her koşu sıfırlanıyor, kalıcı gelişim meta katmanda.
- **Ölçek ve otomasyon:** Her yerleşim küçük (onlarca işçi); ölçek sınırlı olduğu için otomasyon gerekmiyor. Ama bir şikâyet: «overwhelming micromanagement rather than meaningful strategy» [1336490/215961088] ve «waiting for new settlers to arrive become excessively boring» [1336490/215483474].
- **Geri bildirim:** Ses, müzik ve görsel anlatım; ödül ve ceza kaynak çubuklarında anlık [kanitsiz]. Arayüz övülüyor: «The UI is designed so well» [1336490/237360276].
- **En çok övülen 5 tema (n/300):** anlamlı karar, gerilim 76 · sanat, müzik, atmosfer 59 · büyüme, ilerleme 51 · tekrar oynanır 46 · plan, optimizasyon 44 (rahat, doyurucu his 43). «easy to pick up and hard to master» [1336490/235599415].
- **En çok şikâyet 3 tema (n/300):** tekrar ve sıkıcılık 101 · şans, haksızlık 86 («Settlements can fail because RNG shafted you» [1336490/212765395] tipi) · arayüz, açıklama, öğretim 73. Meta bağlamında ayrıca: «your city is reset every level meaning you have zero investment» [1336490/201057498] ve «not fully sure of what i accomplished» [1336490/224455446].

### 3.7 Two Point Hospital (535930)

- **Steam:** %92,2, 16.599 İngilizce yorum, çıkış 2018-08-29.
- **Çekirdek döngü [kanitsiz]:** Boş bir hastane; oyuncu oda çizer, doktor işe alır, hastalar gelir, teşhis ve tedavi görür; hedef: bir ila üç yıldız. Hedef listesi her seviyede yeniden başlar.
- **Tik:** Bir hasta, bir oda, bir hedef; gerçek zaman [kanitsiz].
- **Karar yoğunluğu:** Saatte 20 ila 30 karar [tahmin]. Kayma: ilk saatte oda yerleşimi, sonra ayar ve personel.
- **İlk saat:** Kolay; «silly, easy to understand and as deep as you want it to be» [535930/230267234].
- **Orta oyun baskısı:** Her hastane yeni hastalık seti ve hedef; sıcaklık ve temizlik tedium oluşturuyor: «fun slows down and tedium sets in» [535930/177011084].
- **Son oyun:** Önleyemiyor: seviye seviye aynı iş. «You set up the rooms, copy and paste some more and wait.» [535930/223220699] ve «Even at max speed, reaching the objectives takes simply too long» [535930/223220699].
- **Ölçek ve otomasyon:** Eksik otomasyon şikâyet: «can't make a blueprint of a room» [535930/200947166]; aynı odayı tekrar tekrar kurmak angarya.
- **Geri bildirim:** Anons sesi ve animasyon ana kanal. Mizah geri bildirimin taşıyıcısı: «same crazy, wacky sense of humour» [535930/230089951]; «it's interesting just watching the patients» [535930/237372726]. Kötü yanı: ölümün sebebi okunmuyor: «no way to know how to handle unsuccessful treatments and deaths» [535930/202226006].
- **En çok övülen 5 tema (n/300):** sanat, mizah, atmosfer 65 · nostalji (Theme Hospital) 58 · bir proje daha 28 · anlamlı karar 26 · rahat his 25.
- **En çok şikâyet 3 tema (n/99):** tekrar, sıkıcılık 37 · fiyat ve DLC 24 · hata, çökme 15.

### 3.8 Frostpunk (323190)

- **Steam:** %92,8, 46.632 İngilizce yorum, çıkış 2018-04-24.
- **Çekirdek döngü [kanitsiz]:** Şehir inşası, ısı ve yiyecek dengesi, gün başına saat saat akış, kanun seçimi, fırtınalar. Oyuncu kaynak, işçi ve kanun arasında seçim yapar. Senaryo birkaç saat: «A run through of a scenario takes a few hours» [323190/237802427].
- **Tik:** Oyun içi saat ve gün [kanitsiz]. Karar ağırlığı kanun ve kriz anında.
- **Karar yoğunluğu:** Saatte 30 ila 60 [tahmin]; ağır kararlar seyrek ama etkisi büyük.
- **İlk saat:** Zor ve bazen haksız: «Horrible tutorials and intro, but once you get the idea. It's a 10/10» [323190/236077056]. Olumsuzların %45'i 5 saatin altında.
- **Orta oyun baskısı:** Dışarıdan soğuk dalgası ve kriz, içeriden umut ve hoşnutsuzluk çubukları [kanitsiz]. Yorum özü: «Frostpunk just wants me to make the Least Worst decision in the moment» [323190/235248780].
- **Son oyun:** Kısa senaryo, tekrar oynanır zayıf: olumlu yorumda tekrar teması 28/300; şikâyet «this game has no real replayability» [323190/206887787].
- **Ölçek ve otomasyon:** Büyük nüfus; otomasyon az, elle yönetim: olumsuzda «micromanagment and lack of automatization» [323190/225747942].
- **Geri bildirim:** Ses, müzik, kar üstünde yürüyen insanlar: «watching people make footpaths in the snow» [323190/234732174]; «if some days i am not dreadful enough, i boot this game up» [323190/236161711]. Haksız hissi: «Frostpunk pretends to give you choices. There is in fact, a correct path.» [323190/222760023]; «scripted loss of 80% of my hope» [323190/222832277].
- **En çok övülen 5 tema (n/300):** anlamlı zor karar, ahlaki ikilem 67 · sanat, müzik, atmosfer 41 · hikâye 31 · tekrar oynanır 28 · büyüme hissi 18 (rahat 17, plan 17). «the most miserable city builder you will ever play, and it is wonderful» [323190/234583483].
- **En çok şikâyet 3 tema (n/300):** hata, çökme, performans 56 · şans, "tek doğru yol" 53 · tekrar, sıkıcılık 47.

### 3.9 Slay the Spire (646570) [tür dışı]

- **Steam:** %97,4, 92.332 İngilizce yorum, çıkış 2019-01-23. GDC 2019 konuşmasına göre ilk yıl 1 milyondan fazla satış, balans metrikle yönetildi, ascension seviyeleri zorluk basamağı verdi (özet kaynaklar bölüm 0).
- **Çekirdek döngü [kanitsiz]:** Haritada bir yol seç; savaşta 3 enerjiyle kart oyna; savaş sonunda 3 karttan birini al ya da atla; kamp, mağaza, olay. Bir koşu yaklaşık yarım saat ile bir saat arası; ölünce yeni koşu bir tık.
- **Tik:** Tur (kart oynama), düğüm (harita). Her düğümde 1 ila 3 karar [kanitsiz].
- **Karar yoğunluğu:** Saatte 100'ün üstünde küçük ve anlamlı karar [tahmin]. En yüksek yoğunluk bu bölümdeki oyunlarda.
- **İlk saat:** Kolay öğrenilir: «Easy to learn, challenging to master» [646570/236278611]. Kötü yan: ilk koşular yavaş: «the first 20 minutes of every run is a slog» [646570/233079496].
- **Orta oyun baskısı:** Her perdede daha sert düşman ve seçtiğin kartların birbirini tamamlaması gerekir [kanitsiz]. Ascension seviyeleri zorluk kadranı verir (GDC özeti).
- **Son oyun:** Koşu tekrar ediyor ama kombinasyonlar yeni: «Every time you fail a run you want to jump back on» [646570/236508548]; «Good balance of skill and RNG» [646570/237589415].
- **Ölçek ve otomasyon:** Ölçek yok; deste büyüdükçe karar "eklemek" yerine "eklememek" olur [kanitsiz].
- **Geri bildirim:** Anlık: hasar sayısı, görünür niyet (düşman ne yapacak), ses. Oyuncu neden öldüğünü bilir [kanitsiz].
- **En çok övülen 5 tema (n/300):** plan, kart ve optimizasyon 33 · bir tur daha, bağımlılık 31 · tekrar oynanır 25 · anlamlı karar 21 · sanat, müzik 17.
- **En çok şikâyet 3 tema (n/300):** şans, haksızlık (RNG) 110 (%37) · tekrar, sıkıcılık 50 · arayüz, öğretim 20. Oyun dışı 16 yorum (yapımcı tartışması, devam oyunu). Uyarı: RNG şikâyeti en büyük, ama puan %97,4. Çünkü şans içinde oyuncu etkisi var: «Good balance of skill and RNG» [646570/237589415]. Şikâyet edenin ortanca oyun süresi 18 saat, olumsuzun %22'si 5 saatin altı.

### 3.10 Papers, Please (239030) [tür dışı]

- **Steam:** %97,2, 43.909 İngilizce yorum, çıkış 2013-08-08.
- **Çekirdek döngü (Wikipedia):** Her gün giriş kuralları; sınırlı gerçek zamanlı vardiya; başvuru belgelerini kurallarla karşılaştır; kabul, ret ya da tutuklama; protokol ihlalinde faksla ceza gelir; gün sonu maaş, kira, yemek, ısıtma bütçesi; borç oyunu bitirir. 20 son. Sonsuz mod var (Wikipedia).
- **Tik:** Başvuru. Gün başına yirmi civarı başvuru [kanitsiz].
- **Karar yoğunluğu:** Saatte yüzlerce mikro karar, çok az "ahlaki" karar [kanitsiz/tahmin].
- **İlk saat:** Vardiya gerçek zamanlı ve kısa, her gün yeni bir kural (Wikipedia). Ama olumsuzların %74'ü 5 saatin altında, %48'i 2 saatin altında. Tutan şikâyet: «Completely and utterly unhelpful tutorial» [239030/130604314] ve «got warned or penalized for every action I took» [239030/130604314].
- **Orta oyun baskısı:** Her gün yeni kural, yeni alet; hikâye (EZIC), aile bütçesi. Yorum: «slowly gets more complicated» [239030/236479664]; «towards the end you get into a good groove» [239030/234833218].
- **Son oyun:** Sonsuz mod, hikâyeyle ilgilenmeyen oyuncular için eklendi, hata sayısıyla sınırlı (Wikipedia). Olumsuzda: «stamping papers gets tiresome after about ten days» [239030/163522708]; «you don't have any choices in the game beyond…» [239030/163522708].
- **Ölçek ve otomasyon:** Ölçek yok. Zorluk kural ve alet sayısıyla artıyor: kurallar zamanla zorlaşır, yeni aletler gelir (Wikipedia).
- **Geri bildirim:** Ceza faksı: anında ve sebepli. Gün sonu aile ekranı sade, duyguyu itmiyor (Wikipedia, tasarım gerekçesi). Ustalaşma geri bildirimi: «I can rip through applications now» [239030/235084048].
- **En çok övülen 5 tema (n/300):** hikâye ve atmosfer 33 · sanat, müzik 31 · anlamlı ahlaki karar 27 · tekrar oynanır (20 son) 15 · bir tur daha 14. «a mundane desk job that shouldn't be engaging but is» [239030/233947236].
- **En çok şikâyet 3 tema (n/300):** tekrar, sıkıcılık 83 (%28) · arayüz ve öğretim 32 · şans, haksız ceza 26.

## 4. Çapraz okuma: en çok övülen ve en çok şikâyet edilen

**En çok övülen (oyun başına n/300 sayımının oyunlar arası okuması).**
1. Anlamlı zor karar ve gerilim: Frostpunk 67, ATS 76, Papers 27, Reigns 45 (karşı örnek). Bu tema "hikâye" teması ile iç içe.
2. Zaman kayboluyor, "bir tur daha": GDT 34, MGT2 36, STS 31, TPH 28. Uzun oturumları anlatan tema; Software Inc. 29, RimWorld 16 ile de güçlü.
3. Tekrar oynanır, her koşu farklı: RimWorld 27, ATS 46, STS 25, Frostpunk 28.
4. Sanat, müzik, mizah, atmosfer: TPH 65, ATS 59, Frostpunk 41, Papers 31.
5. Geliştirici desteği ve güncelleme: RimWorld 59, Software Inc. 44. Anahtar: yıllarca güncellenen oyun güven kazanıyor.
6. Büyüme hissi (garajdan imparatorluğa): ATS 51, GDT 18, MGT2 25.
7. Derinlik, bağlı sistemler: Software Inc 46, MGT2 27, ATS 35.

**En çok şikâyet edilen (aynı yöntem).**
1. Tekrar, sıkıcı, grind: ATS 101, Reigns 124, Papers 83, GDT 62, Software Inc 56. En yaygın tek tema.
2. Şans, haksızlık, deneme yanılma: STS 110, ATS 86, GDT 58, Frostpunk 53.
3. Arayüz, açıklama, öğretim: Software Inc 96, ATS 73, MGT2 32, Papers 32.
4. Fiyat ve DLC: RimWorld 99 (en yüksek), ATS 39, Reigns 35.
5. Hata, çökme, performans: Frostpunk 56, GDT 39, FM24 35.
6. Yayıncı ve lisans güveni: FM24 44.

Bir cümleyle: Övgü "karar ve hikâye, uzun oturum ve güven"; şikâyet "tekrar, açıklanmayan şans ve öğretim".

## 5. Project Unicorn için dersler (10 madde)

Her derste oyun kanıtı, bizdeki karşılık ve ölçüt var. Bizdeki zaman: 1 tik = 1 hafta, 1× hızda mesai penceresinde 22,5 sn, 3× hızda 7,5 sn (CLAUDE.md:80). Demo 60 ila 90 dakika, tavan 104 hafta (CLAUDE.md:11), yani oyuncu ortalama dakikada 1,2 ile 1,7 hafta geçirir (hesap: 104 / 60..90). Karar tikte değil, tikler arasındaki kesintilerde olmalı (sprint, kâğıt, olay, görüşme).

**Ders 1. Başarısızlık hızlı, okunur ve ucuz olmalı** (STS, ATS, GDT, Software Inc.)
- Kanıt: STS «Every time you fail a run you want to jump back on» [646570/236508548]; ATS yerleşim 1 ila 2 saat [1336490/234056267]; Software Inc. «your first company will always fail» [362620/227295859] ama bu oyunun olumsuzlarının %43'ü 5 saatin altında ve %29'u 2 saatin altında (EK A): iflas kabul görüyor, ama nedeni okunmayınca vazgeçirme oluyor.
- Bizde: koşu sonu (kepenk, iflas, Series A kaybı) ekranı. 60 ila 90 dakikalık demoda bir kayıp bir saatten ucuza yeniden başlatılabilmeli.
- Ölçüt: Kayıp ekranı "ne öldürdü" cümlesini 1 satırda, hesap ve ekip adıyla yazar. "Yeniden başla" tek tık.

**Ders 2. Her sonucun okunur bir nedeni olsun** (GDT, MGT2, FM24, Papers)
- Kanıt: GDT «reviews seem to be random no matter how much i try to balance» [239820/199419813]; MGT2 «sales just plummet for literally no reason» [1342330/163243899]; FM24 «zero chance to check on the impact» [2252570/196190442]. Karşı örnek Papers: ceza faksı anında ve sebepli; «I can rip through applications now» [239030/235084048].
- Bizde: B2B memnuniyet düşüşü (zaten "durup dururken düşüş yok" kuralı), sprint kapanış raporu, satış görüşmesi sonucu, VC reddi.
- Ölçüt: Her ekrana gelen sonuç "çünkü X" cümlesi taşır; "neden" göstermeyen hiçbir sonuç ekranı yok.

**Ders 3. Olay "anlatılabilir an" üretsin, istatistik değil** (RimWorld, Frostpunk, Papers)
- Kanıt: RimWorld «absolute cinema» [294100/237748064], «Started alone, naked…» [294100/237464542]; Frostpunk «Least Worst decision» [323190/235248780]. RimWorld resmî sayfası oyunu "hikâye üreticisi" olarak satıyor.
- Bizde: acil durum kartı, söz olayı, teşekkür notu, Frank satırı. Her kartın öznesi isimli (müşteri adı, çalışan adı).
- Ölçüt: Olay kartı oyunculara yüksek sesle okunduğunda tek cümleyle anlatılabilir ("Ege Sigorta bana teşekkür etti, çünkü sözü tuttum").

**Ders 4. Zorluk kadranı ve rahat mod şart** (RimWorld, ATS, STS)
- Kanıt: RimWorld «chill experience or pure hell depending on what difficulty» [294100/237500155]; ATS «24 difficulty settings» [1336490/237408086]; STS ascension (GDC özeti).
- Bizde: Erdem'in "gerçek hayat gibi aşırı zorlamak değil" kuralı. Kadran = başlangıç kasası, olay sıklığı, zar şansı ya da hata sıklığı.
- Ölçüt: En az 3 zorluk basamağı; en rahat basamakta bot %90+ Series A'ya varır, en zorda %30 civarı varır [hedef önerisi, kanitsiz].

**Ders 5. Angarya: aynı cevabı üçüncü kez veren karar şablona ya da otomatiğe dönsün** (FM24, TPH, Papers, MGT2)
- Kanıt: FM24 basın toplantısı «WAY to many boring press questions» [2252570/197444360]; TPH oda şablonu yok [535930/200947166]; Papers «tiresome after about ten days» [239030/163522708]; MGT2 otomatik dekor memnuniyeti [1342330/222806962].
- Bizde: sprint planı ("geçen sprintin aynısı" tek tuş), tekrar eden destek ve hata kararları, kâğıt/mail akışı.
- Ölçüt: 50 kişide bir sprintte oyuncunun tıkladığı satır sayısı 1 kişidekinin 3 katından fazla olmaz [hedef önerisi].

**Ders 6. Otomasyon görünür, geri alınır ve sınırlı olsun** (MGT2, Software Inc., Startup Company)
- Kanıt: MGT2 otomatik araştırma 1979'da AAAA oyun araştırdı, 100 milyon kayıp [1342330/156137930]; Software Inc. proje yöneticisi tartışması (R1 §1 madde 6); Startup Company'de 180 kişiyle ikramiye tıklama (R2 §1 madde 7).
- Bizde: CS delegasyonu, PM, tekrarlayan sprint.
- Ölçüt: Her otomasyon "ne yaptı" satırını gelen kutusuna yazar; kasaya ya da memnuniyete etki eden otomatik harcamada üst sınır vardır.

**Ders 7. Gerçek takas, gizli "doğru yol" yok** (Frostpunk)
- Kanıt: övgü teması ağır kararlar (67/300, Frostpunk'ın en büyük olumlu teması) ve şikâyet «there is in fact, a correct path» [323190/222760023], «building or doing the right thing in the exact order» [323190/216537148].
- Bizde: satış görüşmesi pazarlığı, VC term sheet, acil durum şıkları ("bedelsiz çıkış yok" kuralı).
- Ölçüt: Bot, her kart için en az iki farklı seçeneğin kazanan yola gittiğini göstermeli. Bir şık tüm koşullarda dominant olamaz.

**Ders 8. Baskı sayıyla değil yeni kural ve yeni evreyle gelsin** (Papers, ATS, Software Inc., GDT)
- Kanıt: Papers her gün yeni kural (Wikipedia, «slowly gets more complicated» [239030/236479664]); ATS yeni koşu yeni bina seti, sürekli sıfırlama «never hits that wall» [1336490/233563283]; Software Inc. «after you get the first successful software its basically over» [362620/92628727]; GDT «way to easy on Normal mode» [239820/225909447].
- Bizde: Bootstrap, Traction, Series A Hunt evreleri; 50 kişide sprint 2 ya da 3 tik (Faz D). Her evre yeni bir baskı kuralı getirmeli: örneğin Traction'da yenileme, Series A'da yatırımcı ağırlıkları.
- Ölçüt: Ortadaki 30 haftada oyuncunun "kasa artıyor, karar yok" sözünü kuracağı bir pencere olmamalı (CLAUDE.md:6 zaten bunu yasaklıyor); bot ölçümü: her 10 haftalık pencerede en az 3 gerçek karar.

**Ders 9. Şans oyuncunun etkisi içinde kalsın** (STS ile GDT, FM24, Reigns karşılaştırması)
- Kanıt: STS'te RNG şikâyeti en büyük (110/300) ama puan %97,4: «Good balance of skill and RNG» [646570/237589415], çünkü oyuncu hazırlıkla olasılığı değiştirir. GDT'de «reviews seem to be random…» [239820/199419813] ve FM24 "scripted" (30/300) sonuç oyuncu kontrolü dışında hissettiriyor. Reigns %83'te: olumsuzun %41'i tekrar, %22'si şans (EK B).
- Bizde: satış görüşmesi zarı, VC zarı, acil durum zarı, karar kâğıdı zarı.
- Ölçüt: Her zarın etkileyicileri çipte görünür (ekip kalitesi, hazırlık, ilişki); kötü sonuç kartı "kontrol edebileceğin şeyi" söyler.

**Ders 10. İlk saatin sözü: bir hedef, bir ilk zafer, bir açıklanmış kayıp** (Software Inc., ATS, Papers, Frostpunk)
- Kanıt: Software Inc. olumsuzunun %32'si arayüz ve açıklama; ATS «onboarding is overloaded and unclear» [1336490/217467789]; Papers «unhelpful tutorial» [239030/130604314]. Bu dört oyunda olumsuzların %41 ile %74'ü ilk 5 saatte yazılmış (EK A).
- Bizde: Açılış PRD'si (PRD_ANA_MENU_ONBOARDING), Bootstrap'ın ilk 10 haftası.
- Ölçüt: İlk 15 dakikada ilk sürüm (ilk ürün çıkışı) ve ilk müşteri; ilk karar kâğıdında tek cümlelik "bunu yaptın, şu oldu".

## 6. %90 için olmazsa olmaz 8 şey

Çıta Steam'de %90 üstü. Aşağıdaki sekiz madde yukarıdaki dersleri ve sayımları tek listede toplar; her madde en az iki oyundaki kanıta dayanır. Bu bir derlemedir, nedensellik iddiası değildir.
1. **İlk 15 dakikada zafer, ilk saat içinde açıklanmış ilk kayıp.** (Ders 10, 1.)
2. **Her sonucun tek cümlelik nedeni.** "Neden"siz sayı şans gibi okunur ve en büyük ikinci şikâyeti verir. (Ders 2.)
3. **Dakikada yaklaşık bir anlamlı karar, 90 saniyeyi geçmeyen boşluk** [tahmin, ölçülmedi; gözlem: yüksek yoğunluklu STS %97,4 ve ATS %94,7, saatte 15 ila 40 karar tahmin edilen FM24 %92,7]. (Bölüm 5 girişi, Ders 8.)
4. **Angarya yok.** Aynı cevabı üçüncü kez veren karar şablona gider. (Ders 5, 6.)
5. **Orta ve son oyunda yeni kural.** Sayı büyümesi tek başına baskı sayılmaz. (Ders 8.)
6. **Şans oyuncunun elinde.** Etki eden şeyler görünür, sonuç sebebini söyler. (Ders 9, 7.)
7. **Zorluk kadranı ve ucuz kayıp.** Rahat oynayan da zor oynayan da kendi dozunu bulur. (Ders 4, 1.)
8. **Karakter ve güven.** İsimli insanlar, mizah, anlatılabilir olaylar; çökme yok, adil fiyat, güncelleme sözü. Gerekçe: hata ve performans şikâyeti Frostpunk 56, GDT 39, FM24 35; fiyat RimWorld 99; geliştirici desteği Software Inc. ve RimWorld'ün en büyük olumlu temalarından. (Ders 3.)

## 7. Bu belgenin bilinmeyenleri

- Her oyunun saatte anlamlı karar sayısı tahmindir; ölçüm yok. Ölçmek için oyun başına bir oturum gerekir.
- Slay the Spire GDC konuşmasının içeriği ikinci el özetten alındı.
- Anahtar sözcük sayımı eğri olabilir; tam sınıflandırma için elle etiketleme gerekir. İlk 36 olumlu ve 18 olumsuz örneğin elle okunması sıralamayı doğruladı (Ekler tablosu aynı sırayı veriyor).
- "Son oyun" kanıtı olumsuz yorumların ilk-saat ağırlığı yüzünden zayıf.
- Fiyat bilgisi (indirim) mağaza API'sinde güne göre değişir; belgede fiyat kullanılmadı.

---

## EK A. Yorum örneklemi ve oynama süresi

| Oyun | Olumlu n | Olumsuz n | Olumlu aralık | Olumsuz aralık | Ol. ortanca saat | Olsz. ortanca saat | Olsz. <2s | Olsz. <5s | Olsz. ≥100s | Ol. ≥100s |
|---|---|---|---|---|---|---|---|---|---|---|
| GDT | 300 | 300 | 2026-04..10 | 2022-02..2026-10 | 13 | 6 | %22 | %41 | %2 | %6 |
| MGT2 | 300 | 163 | 2025-05..2026-10 | 2021-01..2026-10 | 37 | 8 | %23 | %36 | %6 | %19 |
| Software Inc. | 300 | 300 | 2025-12..2026-10 | 2016-08..2026-08 | 77 | 8 | %29 | %43 | %14 | %39 |
| FM24 | 300 | 300 | 2026-05..10 | 2024-11..2026-09 | 691 | 252 | %7 | %9 | %66 | %89 |
| RimWorld | 300 | 300 | 2026-10-09..18 | 2025-12..2026-10 | 344 | 84 | %10 | %18 | %45 | %76 |
| ATS | 300 | 300 | 2026-08..10 | 2025-06..2026-10 | 75 | 7 | %28 | %44 | %7 | %41 |
| TPH | 300 | 99 | 2026-03..10 | 2024-08..2026-08 | 27 | 10 | %16 | %34 | %8 | %20 |
| Frostpunk | 300 | 300 | 2026-08..10 | 2025-05..2026-10 | 24 | 6 | %25 | %45 | %3 | %12 |
| STS | 300 | 300 | 2026-09-21..10-18 | 2026-03..2026-10 | 27 | 18 | %12 | %22 | %11 | %15 |
| Papers | 300 | 300 | 2026-08..10 | 2022-12..2026-10 | 9 | 2 | %48 | %74 | %0 | %0 |
| Reigns | 300 | 300 | 2022-05..2026-10 | 2018-06..2026-10 | 5 | 3 | %44 | %77 | %0 | %0 |

Kapsam (herhangi bir olumlu temaya düşen olumlu yorum): GDT 99, MGT2 112, Software Inc. 134, FM24 45, RimWorld 111, ATS 184, TPH 150, Frostpunk 130, STS 97, Papers 81, Reigns 108 (hepsi /300).
Kapsam (herhangi bir olumsuz temaya düşen): GDT 172, MGT2 103/163, Software Inc. 189, FM24 120, RimWorld 187, ATS 211, TPH 74/99, Frostpunk 169, STS 165, Papers 143, Reigns 206 (hepsi /300 ya da belirtilen).

## EK B. Reigns karşı örneği (474750, %83,3)

- Olumlu 2.366, olumsuz 475. Ortanca oynama 5 saat (olumlu), 3 saat (olumsuz). Olumsuzların %77'si 5 saatin altı.
- Olumlu temalar (n/300): anlamlı karar 45 · sanat, müzik 39 · hikâye 26 · fiyatına değer 21 · plan 18.
- Olumsuz temalar (n/300): tekrar, sıkıcı 124 (%41) · şans, haksızlık 66 · fiyat 35.
- İki alıntı: «Quickly gets repetitive and boring» [474750/209802212]; olumluda bile: «you have to go through the same cards a lot of times» [474750/221064410]. Yorumlardan biri «Mostly random» [474750/209802212].
- Ders: tek eksenli ikili karar (sağa ya da sola) ilk saat için çok akıcı ama kart havuzu sınırlı olunca tekrar teması %41'e çıkıyor. Bizim kâğıt ve olay havuzu için sonuç: kart tekrarı çok seyrek olmalı (Erdem 2026-10-16 kuralı ile uyumlu).

## EK C. Alıntı kaynak anahtarı

Biçim: `[appid/yorumid]` → Steam adresi `https://steamcommunity.com/profiles/<steamid>/recommended/<appid>/`, tarih, oynama süresi.

Toplam 90 yorum. Yorum metni Steam API'den (`appreviews`, filter=recent) alındı; adreste yazarın o oyun için yorumu açılır, yazar sonradan silmiş ya da değiştirmiş olabilir.

| Anahtar | Oyun | Tarih | Oyun süresi | Olumlu? | Adres |
|---|---|---|---|---|---|
| 239030/130604314 | Papers | 2023-01-11 | 0 sa | hayır | https://steamcommunity.com/profiles/76561198874390940/recommended/239030/ |
| 239030/163522708 | Papers | 2024-04-24 | 7 sa | hayır | https://steamcommunity.com/profiles/76561198009274979/recommended/239030/ |
| 239030/233947236 | Papers | 2026-08-29 | 13 sa | evet | https://steamcommunity.com/profiles/76561197974782524/recommended/239030/ |
| 239030/234833218 | Papers | 2026-09-09 | 57 sa | evet | https://steamcommunity.com/profiles/76561198023894481/recommended/239030/ |
| 239030/235084048 | Papers | 2026-09-12 | 7 sa | evet | https://steamcommunity.com/profiles/76561198121971195/recommended/239030/ |
| 239030/236479664 | Papers | 2026-09-29 | 21 sa | evet | https://steamcommunity.com/profiles/76561199383784695/recommended/239030/ |
| 239820/154890578 | GDT | 2023-12-31 | 37 sa | hayır | https://steamcommunity.com/profiles/76561198332613981/recommended/239820/ |
| 239820/199419813 | GDT | 2025-07-10 | 2 sa | hayır | https://steamcommunity.com/profiles/76561198318320358/recommended/239820/ |
| 239820/202334316 | GDT | 2025-08-17 | 1 sa | hayır | https://steamcommunity.com/profiles/76561197971686497/recommended/239820/ |
| 239820/225143809 | GDT | 2026-05-09 | 58 sa | evet | https://steamcommunity.com/profiles/76561199101201281/recommended/239820/ |
| 239820/225909447 | GDT | 2026-05-19 | 14 sa | evet | https://steamcommunity.com/profiles/76561198202916790/recommended/239820/ |
| 239820/228213188 | GDT | 2026-06-18 | 29 sa | evet | https://steamcommunity.com/profiles/76561198148291689/recommended/239820/ |
| 239820/228474315 | GDT | 2026-06-21 | 9 sa | evet | https://steamcommunity.com/profiles/76561198944509429/recommended/239820/ |
| 239820/230380753 | GDT | 2026-07-13 | 34 sa | evet | https://steamcommunity.com/profiles/76561198699109477/recommended/239820/ |
| 239820/234737239 | GDT | 2026-09-08 | 8 sa | evet | https://steamcommunity.com/profiles/76561198160342829/recommended/239820/ |
| 239820/237532429 | GDT | 2026-10-12 | 19 sa | evet | https://steamcommunity.com/profiles/76561198123407004/recommended/239820/ |
| 294100/219106829 | RimWorld | 2026-02-24 | 18 sa | hayır | https://steamcommunity.com/profiles/76561199007983179/recommended/294100/ |
| 294100/224053739 | RimWorld | 2026-04-25 | 1454 sa | hayır | https://steamcommunity.com/profiles/76561198032485012/recommended/294100/ |
| 294100/237464542 | RimWorld | 2026-10-11 | 78 sa | evet | https://steamcommunity.com/profiles/76561198144154067/recommended/294100/ |
| 294100/237500155 | RimWorld | 2026-10-12 | 414 sa | evet | https://steamcommunity.com/profiles/76561199059352420/recommended/294100/ |
| 294100/237596553 | RimWorld | 2026-10-13 | 82 sa | evet | https://steamcommunity.com/profiles/76561199201378443/recommended/294100/ |
| 294100/237640024 | RimWorld | 2026-10-13 | 2055 sa | evet | https://steamcommunity.com/profiles/76561198006001749/recommended/294100/ |
| 294100/237748064 | RimWorld | 2026-10-15 | 300 sa | evet | https://steamcommunity.com/profiles/76561199215848293/recommended/294100/ |
| 294100/237820386 | RimWorld | 2026-10-16 | 1222 sa | evet | https://steamcommunity.com/profiles/76561198009658820/recommended/294100/ |
| 323190/206887787 | Frostpunk | 2025-10-17 | 38 sa | hayır | https://steamcommunity.com/profiles/76561198049331274/recommended/323190/ |
| 323190/216537148 | Frostpunk | 2026-01-22 | 35 sa | hayır | https://steamcommunity.com/profiles/76561197980619237/recommended/323190/ |
| 323190/222760023 | Frostpunk | 2026-04-07 | 13 sa | hayır | https://steamcommunity.com/profiles/76561198034888699/recommended/323190/ |
| 323190/222832277 | Frostpunk | 2026-04-08 | 13 sa | hayır | https://steamcommunity.com/profiles/76561198122169458/recommended/323190/ |
| 323190/225747942 | Frostpunk | 2026-05-17 | 2 sa | hayır | https://steamcommunity.com/profiles/76561198857745134/recommended/323190/ |
| 323190/234583483 | Frostpunk | 2026-09-06 | 20 sa | evet | https://steamcommunity.com/profiles/76561198840166855/recommended/323190/ |
| 323190/234732174 | Frostpunk | 2026-09-08 | 121 sa | evet | https://steamcommunity.com/profiles/76561198269453360/recommended/323190/ |
| 323190/235248780 | Frostpunk | 2026-09-14 | 10 sa | evet | https://steamcommunity.com/profiles/76561197990527890/recommended/323190/ |
| 323190/236077056 | Frostpunk | 2026-09-24 | 8 sa | evet | https://steamcommunity.com/profiles/76561198034588317/recommended/323190/ |
| 323190/236161711 | Frostpunk | 2026-09-25 | 23 sa | evet | https://steamcommunity.com/profiles/76561198846085918/recommended/323190/ |
| 323190/237802427 | Frostpunk | 2026-10-15 | 19 sa | evet | https://steamcommunity.com/profiles/76561198064014029/recommended/323190/ |
| 362620/51475930 | Software Inc. | 2019-06-26 | 10 sa | hayır | https://steamcommunity.com/profiles/76561198029818396/recommended/362620/ |
| 362620/72612505 | Software Inc. | 2020-07-13 | 16 sa | hayır | https://steamcommunity.com/profiles/76561198191223291/recommended/362620/ |
| 362620/82351786 | Software Inc. | 2020-12-14 | 1 sa | hayır | https://steamcommunity.com/profiles/76561199070109821/recommended/362620/ |
| 362620/92628727 | Software Inc. | 2021-05-26 | 142 sa | hayır | https://steamcommunity.com/profiles/76561199095300825/recommended/362620/ |
| 362620/214586959 | Software Inc. | 2025-12-30 | 190 sa | evet | https://steamcommunity.com/profiles/76561198131348650/recommended/362620/ |
| 362620/217731941 | Software Inc. | 2026-02-07 | 131 sa | evet | https://steamcommunity.com/profiles/76561198019041918/recommended/362620/ |
| 362620/218117498 | Software Inc. | 2026-02-12 | 23 sa | evet | https://steamcommunity.com/profiles/76561198026224126/recommended/362620/ |
| 362620/218169295 | Software Inc. | 2026-02-12 | 118 sa | evet | https://steamcommunity.com/profiles/76561197984756350/recommended/362620/ |
| 362620/220104827 | Software Inc. | 2026-03-07 | 28 sa | evet | https://steamcommunity.com/profiles/76561198063717488/recommended/362620/ |
| 362620/227295859 | Software Inc. | 2026-06-06 | 15 sa | evet | https://steamcommunity.com/profiles/76561199146492486/recommended/362620/ |
| 362620/228670069 | Software Inc. | 2026-06-23 | 33 sa | evet | https://steamcommunity.com/profiles/76561198450807884/recommended/362620/ |
| 474750/209802212 | Reigns | 2025-11-22 | 0 sa | hayır | https://steamcommunity.com/profiles/76561198373924597/recommended/474750/ |
| 474750/221064410 | Reigns | 2026-03-19 | 5 sa | evet | https://steamcommunity.com/profiles/76561199006180781/recommended/474750/ |
| 535930/177011084 | TPH | 2024-10-14 | 54 sa | hayır | https://steamcommunity.com/profiles/76561198036327604/recommended/535930/ |
| 535930/200947166 | TPH | 2025-07-29 | 2 sa | hayır | https://steamcommunity.com/profiles/76561197971275585/recommended/535930/ |
| 535930/202226006 | TPH | 2025-08-16 | 14 sa | hayır | https://steamcommunity.com/profiles/76561198122627921/recommended/535930/ |
| 535930/223220699 | TPH | 2026-04-14 | 8 sa | hayır | https://steamcommunity.com/profiles/76561198057467425/recommended/535930/ |
| 535930/230089951 | TPH | 2026-07-10 | 141 sa | evet | https://steamcommunity.com/profiles/76561198025106791/recommended/535930/ |
| 535930/230267234 | TPH | 2026-07-12 | 8 sa | evet | https://steamcommunity.com/profiles/76561198311701937/recommended/535930/ |
| 535930/237372726 | TPH | 2026-10-10 | 244 sa | evet | https://steamcommunity.com/profiles/76561198031228200/recommended/535930/ |
| 646570/233079496 | STS | 2026-08-18 | 20 sa | hayır | https://steamcommunity.com/profiles/76561199396253783/recommended/646570/ |
| 646570/236278611 | STS | 2026-09-27 | 300 sa | evet | https://steamcommunity.com/profiles/76561197987892974/recommended/646570/ |
| 646570/236508548 | STS | 2026-09-30 | 65 sa | evet | https://steamcommunity.com/profiles/76561197991852167/recommended/646570/ |
| 646570/237589415 | STS | 2026-10-13 | 125 sa | evet | https://steamcommunity.com/profiles/76561197976305750/recommended/646570/ |
| 1336490/201057498 | ATS | 2025-07-30 | 11 sa | hayır | https://steamcommunity.com/profiles/76561198017499197/recommended/1336490/ |
| 1336490/212765395 | ATS | 2025-12-07 | 11 sa | hayır | https://steamcommunity.com/profiles/76561198043199357/recommended/1336490/ |
| 1336490/215483474 | ATS | 2026-01-08 | 4 sa | hayır | https://steamcommunity.com/profiles/76561198090512008/recommended/1336490/ |
| 1336490/215961088 | ATS | 2026-01-14 | 2 sa | hayır | https://steamcommunity.com/profiles/76561197961550081/recommended/1336490/ |
| 1336490/217467789 | ATS | 2026-02-03 | 0 sa | hayır | https://steamcommunity.com/profiles/76561198991646005/recommended/1336490/ |
| 1336490/224455446 | ATS | 2026-04-30 | 7 sa | hayır | https://steamcommunity.com/profiles/76561197989330817/recommended/1336490/ |
| 1336490/233563283 | ATS | 2026-08-24 | 280 sa | evet | https://steamcommunity.com/profiles/76561199171786288/recommended/1336490/ |
| 1336490/234056267 | ATS | 2026-08-30 | 1167 sa | evet | https://steamcommunity.com/profiles/76561198021401339/recommended/1336490/ |
| 1336490/235599415 | ATS | 2026-09-19 | 59 sa | evet | https://steamcommunity.com/profiles/76561198043981641/recommended/1336490/ |
| 1336490/236841979 | ATS | 2026-10-04 | 30 sa | evet | https://steamcommunity.com/profiles/76561198746107625/recommended/1336490/ |
| 1336490/237360276 | ATS | 2026-10-10 | 465 sa | evet | https://steamcommunity.com/profiles/76561198045436195/recommended/1336490/ |
| 1336490/237408086 | ATS | 2026-10-11 | 174 sa | evet | https://steamcommunity.com/profiles/76561197989264499/recommended/1336490/ |
| 1342330/140943244 | MGT2 | 2023-06-30 | 27 sa | hayır | https://steamcommunity.com/profiles/76561198052540498/recommended/1342330/ |
| 1342330/140953189 | MGT2 | 2023-06-30 | 19 sa | hayır | https://steamcommunity.com/profiles/76561198035795606/recommended/1342330/ |
| 1342330/156104946 | MGT2 | 2024-01-16 | 95 sa | hayır | https://steamcommunity.com/profiles/76561198056808379/recommended/1342330/ |
| 1342330/156137930 | MGT2 | 2024-01-17 | 18 sa | hayır | https://steamcommunity.com/profiles/76561198020889999/recommended/1342330/ |
| 1342330/163243899 | MGT2 | 2024-04-20 | 101 sa | hayır | https://steamcommunity.com/profiles/76561198019014829/recommended/1342330/ |
| 1342330/222806962 | MGT2 | 2026-04-08 | 20 sa | evet | https://steamcommunity.com/profiles/76561198072257785/recommended/1342330/ |
| 1342330/230599393 | MGT2 | 2026-07-16 | 33 sa | evet | https://steamcommunity.com/profiles/76561198008397026/recommended/1342330/ |
| 1342330/232360450 | MGT2 | 2026-08-08 | 15 sa | evet | https://steamcommunity.com/profiles/76561198080937054/recommended/1342330/ |
| 1342330/235510802 | MGT2 | 2026-09-18 | 19 sa | evet | https://steamcommunity.com/profiles/76561198320586000/recommended/1342330/ |
| 2252570/182035065 | FM24 | 2024-12-06 | 356 sa | hayır | https://steamcommunity.com/profiles/76561198051833193/recommended/2252570/ |
| 2252570/196190442 | FM24 | 2025-06-01 | 72 sa | hayır | https://steamcommunity.com/profiles/76561197965094796/recommended/2252570/ |
| 2252570/197444360 | FM24 | 2025-06-17 | 1258 sa | hayır | https://steamcommunity.com/profiles/76561198010875870/recommended/2252570/ |
| 2252570/199436285 | FM24 | 2025-07-10 | 79 sa | hayır | https://steamcommunity.com/profiles/76561199849010305/recommended/2252570/ |
| 2252570/225232128 | FM24 | 2026-05-11 | 1405 sa | evet | https://steamcommunity.com/profiles/76561198136556486/recommended/2252570/ |
| 2252570/227790810 | FM24 | 2026-06-12 | 176 sa | evet | https://steamcommunity.com/profiles/76561199819637033/recommended/2252570/ |
| 2252570/231472201 | FM24 | 2026-07-28 | 8043 sa | evet | https://steamcommunity.com/profiles/76561198112933368/recommended/2252570/ |
| 2252570/232586960 | FM24 | 2026-08-11 | 584 sa | evet | https://steamcommunity.com/profiles/76561198143768890/recommended/2252570/ |
| 2252570/236431955 | FM24 | 2026-09-29 | 1392 sa | evet | https://steamcommunity.com/profiles/76561198107201657/recommended/2252570/ |
| 2252570/236573355 | FM24 | 2026-09-30 | 303 sa | evet | https://steamcommunity.com/profiles/76561197979008305/recommended/2252570/ |
