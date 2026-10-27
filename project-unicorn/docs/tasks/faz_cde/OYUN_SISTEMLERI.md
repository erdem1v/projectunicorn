# Oyun sistemleri rehberi
Planlanan son hâl, 17 Ekim 2026 akşamı. Bugünkü koddan değil, bu turun belgelerinden anlatılır. Koda dokunulmadı.
- **(Erdem)** Erdem'in söylediği ya da onayladığı kural. **(karar bekliyor)** henüz onaylanmamış kural ya da seçim.
- İşaretsiz satır: bu ikisinin ayrıntısı. İçindeki sayılar ayar değeridir, kalibrasyonda oynayabilir.
- **ölçüm** simülasyon ya da bot kaydı. **tahmin** muhasebe hesabı (bot kararları sabit).
- Durum: A uygulandı. B uygulanıyor (B1 ve B2 commit'li). Kalite, C ve D kodlanmadı. E taslak.

## Oyun bir bakışta
- Oyuncu bir teknoloji girişimi kurar ve Series A'ya taşır. Üç evre: Bootstrap, Traction, Series A Hunt. Her evre runway'i yeniden daraltır.
- Bir tik bir oyun haftasıdır. Ekip, ürün, satış ve olaylar haftada bir yürür.
- Bootstrap'ta kurucu tek başınadır. Ürün türünü seçer (B2B hesaplar ya da B2C kitle) ve sprintlerle ilk sürüme (MVP) gider.
- Ürün canlı olunca müşteri, hata, sunucu faturası ve acil durumlar başlar. Ana iş ekip, sprint planı ve müşteri ilişkisidir.
- Para: gelir MRR olarak okunur. Giderler maaş, ek mesai, sunucu, ofis ve pazarlamadır. Fon sırası: kurucunun birikimi, Frank'in tek çeki, seed, Series A.
- Kazanma: Series A imzası. Kaybetme: kasa eksiye düşünce 4 haftalık kepenk sayacı başlar, sıfıra inerse iflas.
- Yumuşak süre 104 hafta. Demo, Series A kararına kadar sürer ve 60 ile 90 dakikadır.
- Ürünün tek kalitesi alanlardır. Müşteri memnuniyeti görünür satırların toplamıdır ve nedensiz düşmez.

## 1. Ürün ve sprint
- **Hatlar ve alanlar.** Ürün hatlardan kurulur; hat bir özelliktir ve bir alana bağlıdır. B2B ürünü 9 hatlıdır: Çekirdek 5, Güven & Ölçek 2, Entegrasyonlar 1, Onboarding & Erişim 1. Onboarding alanının adı planda "İlk Kullanım ve Erişim" olur (Erdem); kodda bugün "Onboarding & Erişim" (strings.csv:2915).
- B2C alanları: Çekirdek, Onboarding, Büyüme, Güven & Ölçek, Gelir. Gelir kaliteye girmez, fiyatın konusudur.
- **Kademeler.** Her hat üç kademelidir: K1 15 puan, K2 25, K3 40. Sıra zincirlidir; K3 bir araştırma kapısına bağlıdır. Araştırma kartı 5, B2C ücretli plan kartı 15 puandır.
- Puan ölçeği: 2,5 yıldızlı bir kişi, kendi alanında, haftada 10 puan üretir.
- Her kart sırayla tasarım, geliştirme, test ister; test hata bulursa dördüncü iş olarak düzeltme eklenir. Örnek: K2 geliştirme ağırlıklı kart 4 tasarım, 16 geliştirme, 5 test puanıdır.
- **Plan.** Sprint 1 ya da 2 haftadır, oyuncu seçer. Şirkette tek ritim vardır: tek planlama, tek kapanış, tek sürüm notu. Planlama üç eylemdir: öneriyi uygula, istersen değiştir, başlat. Oyuncu karta kişi atamaz, atamayı sistem yapar.
- Kart sayısı sonuçtur, sabit yuva yoktur. Kart şu üç şart tuttukça girer: toplam iş en çok 1,25 × kapasite, her aşamada kalan iş en çok 2 × o aşamanın kapasitesi, yeni kart bu sprintte iş almalı.
- Öneri bu kurala göre tavana kadar dolar. Sıra: verilen sözler, tarihi yaklaşan talepler, bırakılan kartlar, öncelikli düzeltmeler, en zayıf alanın en iyi kartı, kalanlar. Sığmayan kart atlanır, sıradaki en çok 12 adaya bakılır.
- Koşan sprintte kart eklenmez. Plan ekranındaki tahmin kapanış sonucuyla aynı çıkar (Erdem). Kapanışta biten kartlar yayına girer, sürüm numarası 0,1 artar, sürüm notu yazılır.
- **MVP ve v1.0.** MVP, Çekirdek'in beş hattından üçünün K1'idir. Bitince oyuncu yayınlar ya da bir sprint daha ister. Yayın ürünü canlı yapar ve bir sunucu birimi açılır.
- **Kart nereden gelir.** Dört kaynak: kademe kartları, K3'ü biten hattın derinlik kartları, B2B'de müşteri isteği kartı, Erken Erişim'de (EA) modüller.
- Derinlik kartları birbirine bağlı değildir: aynı hatta 1 + (hattı kullanan hesap ÷ 5, aşağı yuvarlı) kart açıktır, en çok 8. Boyut 15, 25, 40 sırayla döner. Kazanç alan puanına yazılır ve azalır; beşinci kart ilkinin yaklaşık üçte biri kadar getirir.
- İstek kartı: hesabın istediği alanda açık kademe yoksa hesabın kendi kartı olur. Boyutu koltuğa göre 15, 25 ya da 40; hesap başına yılda bir.
- Neden dört kaynak: 9 hat 720 puandır; ölçüm 12 kişi bunu 12 haftada, 50 kişi 7 haftada bitirir. Tasarım hedefi: plan anında açık aday en az 0,75 × ekip (8 kişinin altında ekip kadar). Bakım kartı yoktur, çünkü sürekli hata sprinti reddedildi (Erdem).

Kaynak: SPRINT_DUZENI §3 K1 ile K8; D_MODEL_v3 §3.1, §3.2, §3.12, §3.13; KALITE_v2 §1; PRD_FAZ_A_HATALAR §4.

## 2. Ekip
- **Roller.** Kurucu, Ürün yöneticisi (PM), Tasarımcı, Geliştirici, Testçi. Satış ve Müşteri Temsilcisi sprinte kart almaz. Alanlar 0 ile 10 puan (1 ile 5 yıldız); rol ana alanı belirler. Tasarımcı kod yazmaz, geliştirici tasarım yapmaz (Erdem).
- **Yıldızın etkisi.** Değerler öneridir (karar bekliyor); uçlar Erdem'in: PM hazırlığı 15 ile 25 puan, hazır kartta hız %10 ile %30.

| Yıldız | Ana işte hız, puan/hafta | Yazdığı kodun hatası | Test yakalama, başkasının kartı | Kendi kartı | PM hazırlığı, puan/hafta | Hazır kartta hız | Hazır kartta hata |
|---|---|---|---|---|---|---|---|
| 1 | 6 | ×1,25 | %46 | %27 | 15 | %10 hızlı | ×0,90 |
| 2 | 9 | ×1,08 | %53 | %32 | 20 | %15 | ×0,825 |
| 3 | 12 | ×0,93 | %61 | %37 | 22 | %20 | ×0,75 |
| 4 | 15 | ×0,81 | %71 | %42 | 24 | %25 | ×0,675 |
| 5 | 20 | ×0,71 | %81 | %48 | 25 | %30 | ×0,60 |

- 5 yıldızlı geliştirici 2,5 yıldızın iki katı iş çıkarır ve aynı kartta yaklaşık %29 daha az hata yazar. Hata sütunu hesaptır: hız çarpanının karekökü ile ters orantılı, 2,5 yıldız 1,0.
- Geliştirici hızı yıldızla hızlanarak artar. PM hazırlığı başta çok, sonra az kazandırır: 1'den 2 yıldıza artı 5, 4'ten 5'e artı 1 puan (Erdem: "tam doğrusal arttıramayız").
- Test yakalama 0 yıldızda %40'tır. En iyi testçi hatanın beşte birini kaçırır (Erdem'in %43 itirazına karşılık). Kendi yazdığı kartı test eden normal yakalamanın %60'ını yakalar (karar bekliyor).
- **Uyum.** Ana alan 1,0, yan alan 0,7, uymayan iş 0,4 (hız en az 3 puan). Uymayan işte çalışan, sprint kapanışında eksi 2 moral alır. Kurucu her aşamada çalışır; güçlü alanında (en az 5 puan) uzmanla aynı sıradadır.
- **Kadro ve sıra.** 8 puanlık işe en çok bir kişi girer (Erdem). Küçük karta 5 testçi girmez; biri girer, ötekiler başka kartta ya da boşta olur. Aşamalar sırayla akar: tasarım, geliştirme, test, düzeltme; biri bittiği anda sonraki açılır. Şirket çapında ekip büyüklüğü cezası yoktur (Erdem).
- **PM.** PM sprint puanı üretmez, kartı önceden hazırlar (Erdem). Hazırlık kartın %20'sidir (K1 3, K2 5, K3 8 puan). Bir PM 1 yıldızda yaklaşık 7, 5 yıldızda yaklaşık 12 kişiyi besler.
- Birden çok PM'de hazırlık paylaşılır, hazır kartın faydası en iyi PM'in yıldızından gelir (karar bekliyor). PM'siz ekibe ceza yoktur (Erdem).
- **Kurucu.** Kurucu her aşamada en az 2 yıldız gibi çalışır ve oyuncu bunu görmez (Erdem); dosyada gerçek yıldızları yazar. Ölçüm: tek kurucunun MVP'si 6. haftada biter; ekibe 1, 2, 3 kişi eklenince şirketin teslimi 72 adımın 72'sinde arttı.
- Kurucunun kendi işi en çok %10 düşebilir (iş yeni gelenle paylaşıldığı için). Plan ekranı nedenini yazar: "Kurucu testte", "Mert ile paylaşıyor", "Kartlar hazır geldi".
- **Darboğaz.** Aşama şeridi ve darboğaz cümlesi plan ekranında hep görünür; cümle gözlem yazar, öneri yazmaz (Erdem). Örnek: "Test satırı dolu. Yeni kart sonraki sprinte kalır." Başka örnekler: "Mert boşta: geliştirmeye açık kart yok.", "Planlanacak kart kalmadı: 6 kişi bu sprint boşta."
- Aşama zinciri kartın üstüne gelince, kişi yükü avatar satırında görünür. Ekranlar oyunun kendi Menajer diliyle yapılır (Erdem).
- **Ekip büyüyünce** (ölçüm):

| Ekip | 1 | 3 | 6 | 12 | 25 | 50 |
|---|---|---|---|---|---|---|
| Haftalık iş, puan | 4,5 | 19,6 | 48 | 107 | 265,5 | 539 |
| Kişi başı | 4,5 | 6,5 | 8,0 | 8,9 | 10,6 | 10,8 |
| Sprintte kart | 0,4 | 1,1 | 2,4 | 5,4 | 13 | 27 |

- Kişi eklemenin en kötü adımı eksi 1 puan/hafta (ölçüm). Uç bileşimler çökmez (hepsi testçi, aynı rolde 10 kişi, PM'siz 30, testçisiz 25, tek karta 12 kişi); sorun boşta kişi ve darboğaz cümlesi olarak görünür.
- 50 kişide oyuncu kart seçmez: öneri, değiştir, başlat; sprint başına 2 ya da 3 eylem.
- **Takım (EA, karar bekliyor).** Oyuncu isterse takım kurar, 10 kişiden sonra anlamlıdır. Takımdaki kişi yalnız takımının alanlarında çalışır ve takım dışına geçemez. Takımsız kişinin çarpanı 1'dir.
- Takım çarpanı = lider çarpanı (Liderlik 0'da 0,85, tavanda 1,20) × büyüklük kaybı. Kayıp 9. kişiden başlar, yalnız o kişiye uygulanır: sıra başına %2, en çok %20. Satır hız ve boşta kişiyi yazar: "Çekirdek takımı, lider Ayşe, 12 kişi, hız ×1,06, boşta 2 kişi".

Kaynak: D_MODEL_v3 §3.3 ile §3.9, §3.14, §4.1 ile §4.4, §4.6, §4.7; SPRINT_DUZENI §3 K4, K5, K10; ERDEM_CDQ_CEVAP (D1 ile D4).

## 3. Hata ve test
- **Doğuş.** İki kaynak: kullanım tabanı (canlı ürün, rastgele bir canlı hatta haftada birkaç hata düşürür; hatlar eşit olasılıklıdır, kümeleme yoktur, Erdem) ve kart (testte yakalanamayan hata kartın kendi hattına düşer). B2B'de hesaplar arttıkça akış daha yavaş büyür.
- **Bir kartın hatası.** Beklenen hata = 0,04 × kart puanı × yazanın kalitesi × hazırlık çarpanı. Örnek: 25 puanlık kart, 2,5 yıldızlı geliştirici, hazırlıksız: bir hata. Test bitince hata sayısı ve bulunanlar belli olur; sayı kartın kendi tohumundan çıkar, plan ve kapanış aynısını bulur.
- **Bulunan hata** kartın düzeltme işine döner: hafif hata 1,3 puan, ağır hata (%18) 5,3 puan. Düzeltme geliştirme işi sayılır; testçi Yapım işi almadıkça yapmaz.
- Kart satırı yüzde yazmaz (Erdem). Test bitince yazar: "Test: 3 hata buldu, 2'si düzeltildi." Hata yoksa "Test: hata bulunmadı." Plan hatayı hesaplar ama göstermez (karar bekliyor).
- **Testçinin değeri** (ölçüm).
  - 1 yıldız yerine 5 yıldızlı testçi, 100 puanlık teslimde kaçan hatayı %57 ile %64 azaltır, bulunanı 2,3 ile 2,7 katına çıkarır.
  - Test kutulu geliştirici yerine aynı sayıda kişiyle 3 yıldızlı testçi: teslim %9 ile %14 artar, kaçan hata %25 ile %36 azalır.
  - Tek kurucu kendi kartını test ettiği için az bulur.
- **Üç hata türü.** Bulunan: testte yakalanan. Bilinen: sprint bitince düzeltilmemiş bulunan. Kaçan: yakalanamayan; yayında açık hata olur.
- **Sprint sonu sorusu** (Erdem istedi, kuralı karar bekliyor):
  - "Hesap Planı ve Stok Sayacı'nda 4 bilinen hata kaldı. Bu haliyle gönderelim mi, sonraki sprinte mi bırakalım?"
  - Soru yalnız bilinen hata, o sprintte bulunanın üçte birine ulaşınca gelir (en az 1). Söz ya da istek kartıysa eşiksiz gelir.
  - Ölçüm: 3 ile 25 kişide en çok üç sprintte bir.
- Vurgulu cevap "Sonraki sprinte bırak". Gönder: bilinen hata kartın hattına açık hata olur. Bedel küçük ve görünür (ölçüm): kart 0,1 ile 0,2 hafta erken çıkar, açık hata en çok %14 artar. Sprintte en çok bir kesinti gelir; sıra acil durum, söz olayı, kâğıt, bu soru (karar bekliyor).
- **Açık hata** tek sayıdır (A, uygulandı). Hat satırı yazar: "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı"; en büyük hesap adıyla öne çıkar.
- **Düzeltme kartı** yalnız kendi hattını temizler. Büyüklüğü 2 × hattın açık hatası puandır, alt sınır yoktur. Hatta 5 açık hata varsa "Öncelikli" olur. Öneri düzeltme kartlarını kapasitenin yarısına kadar alır. Kart yalnız canlıda bulunan ve kaçan hata içindir.
- Sürekli hata sprinti yoktur (Erdem). Hata sprinti, kapasitenin yarısından fazlasının düzeltmeye gittiği sprinttir; ölçümde 2 kişi ve üstünde hiç yok.
- **Sınırlar ölçekle büyür** (D5, Erdem).
  - A'nın sabit sınırları k ile çarpılır; k = en büyüğü (1; canlı hat ÷ 9; karekök(haftalık teslim ÷ 55)).
  - İtibar eşiği 6 kişide 30 açık hata, 50 kişide yaklaşık 94 olur.
  - Hiç düzeltmeyen oyuncu her ölçekte 14 ile 23 haftada eşiğe varır, düzenli düzelten varmaz (ölçüm).
- **İtibar.** Eşikte 4 hafta üst üste kalan üründe itibar haftada 1 düşer, en çok eksi 10. Negatif itibarı yatırımcı sorgular.

| Ekip (ölçüm) | 1 | 3 | 6 | 12 | 25 | 50 |
|---|---|---|---|---|---|---|
| Açık hata, ortanca | 6,8 | 8 | 8 | 9,5 | 12 | 17 |
| Düzeltme payı | %29 | %9,5 | %6,6 | %5,1 | %3,4 | %3,0 |

- Tek aşım: tek kurucu 1 haftalık sprintte hata sprinti oranı %6,6 (hedef %5); Erdem'e soruldu (karar bekliyor).

Kaynak: D_MODEL_v3 §3.6, §3.7, §3.12 c, §4.5, §4.8, §4.9; PRD_FAZ_A_HATALAR §2 Karar 1 ile 11; RAPOR_A §3.

## 4. Ürün kalitesi
- **Alanlar.** Ürünün tek kalitesi alanlardır: Çekirdek, Onboarding, Entegrasyonlar (B2B), Büyüme (B2C), Güven & Ölçek (Erdem). Deneyim, İnovasyon, Kararlılık eksenleri ekonomiyi sürmez.
- Alan seviyesi kart kademelerinden gelir ve kelimeyle okunur: Yok, Zayıf, Yeterli, Güçlü. Beklenmeyen alan "Henüz beklenmiyor" yazar.
- **Kararlılık** alan değildir. Genel Bakış'ta açık hata ve kesinti satırının başlığıdır: "Kararlılık · 7 açık hata ▲2 · son 4 haftada 1 kesinti" (Erdem).
- **Pazar ne bekler** (karar bekliyor; ölçümle kalibre edilecek, çünkü botun ürünü bunu aşıyor ve imzaların %75'inde ürün uyumu 100'e doyuyor):

| Evre | Çekirdek | Öteki alanlar |
|---|---|---|
| Bootstrap | MVP seviyesi | beklenmez |
| Traction | 1 | 0,5 |
| Series A Hunt | 1,5 | 1 |

- Evre geçişinde beklenti 8 haftada yükselir. Rakip çıkışı yalnız yeni adayın gözünde beklentiyi yükseltir.
- **Ürün uyumu.** Her alanın seviyesinin beklentiye oranıdır (en çok 1,5). Ağırlıklar: Çekirdek %50, sektörün birinci vurgusu %25, ikincisi %15, kalan %10. Ürün uyumu = 70 × uyum, en çok 100; beklentiyi tam karşılayan ürün 70 alır.
- Çekirdek her sektörde baskındır (Erdem). Kural: öteki alanlar uyumu Çekirdek oranının en çok 0,25 üstüne taşır (karar bekliyor). Çekirdek oranı 0,4 olan ürün, Güven ve Entegrasyonlar ne kadar iyi olursa olsun 46'yı geçemez; Çekirdek 0 ise en çok 17,5.
- Hesap uyumu pazarla iki anda karşılaştırılır: imzada ve yenileme döneminde. Arada ürün değişince uyum hemen değişir.
- **Sektör vurgusu** (karar bekliyor). Sektör yalnız ek ağırlık verir, Çekirdek'in yerini almaz:

| Sektör | Birinci vurgu | İkinci vurgu |
|---|---|---|
| Lojistik, sigorta, teknoloji, üretim, hukuk | Entegrasyonlar | Güven & Ölçek |
| Sağlık, finans, elektronik ticaret, perakende | Güven & Ölçek | Entegrasyonlar |
| İnşaat | Onboarding | Güven & Ölçek |
| Emlak | Onboarding | Entegrasyonlar |
| Tekstil | Entegrasyonlar | Onboarding |
| Medya | Güven & Ölçek | Onboarding |

- Bugünkü eşleme alıcı tipine göredir ve yanlış bulundu: lojistik Güven'e değil Entegrasyonlar'a, teknoloji Çekirdek'e değil Entegrasyonlar'a bakar. Kanıtı zayıf satırlar tasarım tahminidir. Ekranda cümle yazar: "Lojistik hesapları önce Çekirdek'e, sonra en çok Entegrasyonlar alanına bakar."
- Sağlık, Tekstil ve Medya bugün hiç aday üretmiyor; eklensin mi, silinsin mi (karar bekliyor).
- **Kullanım.** Satış görüşmesi, imza kapısı ve aday yıldız karışımı adayın uyumunu okur. Kayıp nedeni zayıf alanı söyler. Yatırımcı sorgusu en zayıf alanın adını okur (Zayıf ya da Yok ise).

Kaynak: KALITE_v2 §1 ile §5; C_ICERIK_v3 §5.6.

## 5. B2B müşteri
- **Satış.** Hesap, kurucunun oynadığı satış toplantısı ve pazarlıkla ya da atanmış satışçının işlediği adayla kazanılır. Sözleşme 12 aydır, nakit aylık tahsil edilir, ortak dil MRR'dır (Erdem). Rakip fiyat satırı ve rakip analizi kapsam dışıdır (Erdem).
- Aday, imzada memnuniyeti kendi ayrılma eşiğinin en az 10 puan üstünde olmayacaksa imzalamaz (karar bekliyor). Neden: kapı olmazsa zayıf ürünle imzalanan hesap ilk hafta ayrılabilir yazardı.
- Ayrılma eşiği = 30 + 3 × (yıldız eksi 1) + sektör ekinin yarısı, en çok 38. 1 yıldızlı hesap 30, 3 yıldızlı 36.
- **Hesaplar tablosu.**
  - Sütunlar: firma ve yıldız, koltuk, aylık, memnuniyet, durum, yenileme, istek, temsilci. Her başlığa basınca sıralar (Erdem).
  - Görünümler: tümü, durumu olan, yenilemesi yakın, temsilcisi olmayan; ayrıca firma araması.
  - Durumlar: Ayrılabilir, Yenilemeyebilir, Yenilemeyecek, Sunucu maddesi, Fesih bildirimi.
- Haftalık destek raporunu temsilci gönderir; yeni bir şey yoksa gelmez, eski rapor yenisi gelince düşer (Erdem).
- **Memnuniyet** (karar bekliyor). İpucunda görünen satırların toplamıdır; gizli hedefe kayma yoktur. Bugünkü kodda hesap 50 civarı açılıp bir iki haftada gizli puanına iniyordu; Erdem bunu açıklanamaz buldu.
- Memnuniyet = ürün uyumu, eksi açık hata, artı defter satırları, artı ya da eksi durum terimi, eksi güncelleme yaşı. Hiçbir terim sessiz değişmez; her değişim adlı bir satırdır.
- Açık hata terimi: 3 × hat başına açık hata yoğunluğu, en çok 60; ekip ve ürün büyüklüğünden bağımsızdır. İmza değeri gerçek değerdir: beklentiyi karşılayan, hatası az üründe 65 ile 70.
- Güncelleme yaşı: hesabın baktığı alanlara 26 hafta dokunulmazsa, sonra her 4 haftada 1 puan düşer, en çok 12. Hata düzeltmesi de güncellemedir.

| Defter satırı | Değer | Süre |
|---|---|---|
| Söz zamanında tutuldu / geç tutuldu / tutulmadı | artı 6 / eksi 3 / eksi 12 | kalıcı / 8 / 13 hafta |
| İsteği yayına girdi | artı 4 | kalıcı |
| Kesinti | saat × 0,6, en çok eksi 8 | 13 hafta |
| Ertelenen hata | eksi 6, sonra her sprint eksi 3 | 8 hafta |

- Olumsuz satır süresince doğrusal söner; hesabın sahibi (müşteri ilişkileri) süreyi kısaltır. Kalıcı olumlu satırların toplamı en çok artı 10.
- Durum terimleri: indirim artı 8, zam eksi 2, gönülsüz yenileme eksi 6 (yenilemeye kadar), kurumsal madde eksi 10 (madde açıkken).
- Ölçüm: nedensiz düşüş 0 (250 bin hesap haftası). Eşiğin altı 1 hafta sürerse Risk başlar, 2 haftalık sayaç biterse hesap ayrılır, 3 hafta yeniden girmez. Sözleşme ortasında yalnız eşiğin altında ayrılır; hafif memnuniyetsizlik yenilemede bedel öder.
- **Yenileme** (akış Erdem'in, bantlar karar bekliyor). Bitişe 8 hafta kala başlar.
  - Fark = memnuniyet eksi eşik, artı ikna payı ((Satış yıldızı eksi 1) × 2).
  - Bantlar: 25 ve üstü zamma açık (%8 zam), 12 ile 24 aynı fiyat, 5 ile 11 %10 indirim, 0 ile 4 %15 indirim, 0'ın altı yenilemez.
  - Bakımlı üründe hepsi "zamma açık" çıkıyor; bantlar yeniden ölçülecek.
- Satışçı varsa müşterilerle görüşür, rapor getirir; oyuncu raporu onaylar ya da bir noktada değiştirir. Satışçı yoksa kurucu mailden toplu teklif gönderir, karşı teklif tek turda kapanır, saat harcanmaz; cevapsız kâğıt aynı fiyatla yenilenir (Erdem).
- **Bütçe kesintisi** (karar bekliyor). Ürüne bağlı olmayan, düşük ihtimalle: 1 yıldız %2, 2 yıldız %1,5, 3 yıldız %1. Memnun hesap koltuğu yarıya indirip kalmayı teklif eder; neden mailde yazar. Ölçüm: bakımlı üründe yılda yaklaşık 5,75 olay, hepsi küçülme, tam kayıp yok.
- **Kurumsal madde** (Erdem).
  - 3 yıldız ve üstü hesap, sunucu Kurumsal değilken imzalanır; maddede 8 hafta yazar.
  - Süre dolunca memnuniyeti eşiğe 20 puandan yakın hesap 4 haftalık fesih bildirimi gönderir. Bu sürede Kurumsal'a geçiş bildirimi geri aldırır.
  - Daha memnun hesap hakkını saklar, eksi 10 alır ve her ay yeniden bakılır.

Kaynak: C_ICERIK_v3 §4, §5, §6; C_ICERIK_v2 §2.3, §2.4, §2.6, §2.7; MEMNUNIYET_SIM §0.

## 6. B2C
- Kitle her oyun saatinde iki yönlü değişir. MRR, ödeyen kullanıcı × fiyat olarak türetilir.
- Kalite alanları B2C ağırlığıyla okunur: Çekirdek %50, kalanı Onboarding, Büyüme ve Güven eşit böler; Gelir girmez. Rakip baskısı pazar beklentisinden gelir.
- Açık hata kitleyi yavaşça eritir; satış dönüşümünü ve memnuniyeti bastırmaz (A). A sonrası botun B2C MRR'ı 159 binden 1,13 milyona çıktı; yeni denge D ve E fazlarında kurulur (karar bekliyor).
- Sunucu birimi 1.000 kullanıcıdır; kesintiyi B2C'de de yük ve kademe belirler. B2C'de söz olayı yoktur, çünkü şirketler sürüm çıkmadan tarih vermez. Tek ürün pazaryeridir (bölüm 10).

Kaynak: C_ICERIK_v3 §2.1, §3.2; KALITE_v2 §3.4; RAPOR_A §1; PRD_FAZ_B_OLAYLAR §2 Karar 15.

## 7. Sunucu
- **Kademeler** (oran ve band Erdem'in, dolar değerleri ayar). Ekonomik, Standart, Kurumsal:

| | B2B, 50 koltuk başına ayda | B2C, 1.000 kullanıcı başına ayda | Kesinti çarpanı |
|---|---|---|---|
| Ekonomik | 60 dolar | 125 dolar | 1,0 |
| Standart | 120 dolar | 250 dolar | 0,5 |
| Kurumsal | 240 dolar | 500 dolar | 0,25 |

- Fiyat oranı 1 : 2 : 4. Standart'ta sunucu gelirin yaklaşık %9'una oturur (ölçüm: B2B %9,1, B2C %9,8). Kademe geçişi anında ve bedavadır. Ekonomik'te bildirim akışı ×1,25 ve kurumsal hesap imzalanamaz. B2C fiyatı E'ye kadar geçicidir.
- **Kapasite oyuncudadır** (Erdem). Otomatik ölçekleme yoktur. "Artır" ve "Azalt" kapasiteyi mevcudun %10'u kadar (en az 1 birim) oynatır; etki hemen işler, fatura ertesi tikten akar.
- Blokta tek gösterge "Yük %" olur; yanında boş payın koltuğu ve parası yazar, çünkü oyuncu bilerek pay bırakabilir. Düğme ipucu önceden yazar: "650 koltuk ekle · ayda 15.600 → 17.160 dolar · yük %80 → %73". Azaltma yükü %100'ü aşırtıyorsa kırmızı yazar: "Yük %112 olur. Kapasite yetmez."
- Büyüme yükü 4 hafta içinde %90'ın üstüne taşıyacaksa blokta bir satır uyarır: "Bu büyüme hızıyla yük 3 hafta sonra %90'ı geçer." Sürüm kapasiteyi düşürürse sürüm notu yazar.
- **Yük ve kesinti.** %90'dan sonra kesinti ihtimali artar (Erdem): %90 ile %100 arası ×1,5, üstü ×2,5. Başka gizli ceza yoktur.
- Haftalık kesinti ihtimali = en küçüğü (0,10 × yük çarpanı × açık hata çarpanı; 0,30) × kademe çarpanı. Kademe tavandan sonra uygulandığı için her basamak ihtimali tam yarıya indirir (ölçüm; sıra B'nin kararı). İki kesinti arası en az 4 hafta.

Kaynak: C_ICERIK_v3 §2.1 ile §2.6, §3.2; MEMNUNIYET_SIM §1 (M7, M12).

## 8. Para
- **Giderler** (Erdem: yalnız görünen ve yönetilen kalem). Kalan liste: Maaşlar, Ek mesai, Sunucular, Ofis, Pazarlama. Araç gideri ve servis maliyeti kalkar; "toplam gider değişmesin" fikri reddedildi.
- Maaşlar kurucu satırını da taşır, ayda 1.500 dolar (karar bekliyor); Bootstrap runway'i bu satırdan çıkar (10.000 ÷ 1.500 = 6,7 ay). Ofis kira olur: Ev 0, İş hanı 1.500, Plaza 8.000, Loft 18.000 dolar (karar bekliyor). Pazarlama kampanya kartıyla gelir, ileride E açar.
- **Servis kalkınca** (tahmin, B2B). Servis bugün bütün giderin yarısıdır. Telafisiz kalırsa ilk yılın en derin nakit açığı 41 binden 12 bine iner, evre 3 aylık net 29 binden yaklaşık 90 bine çıkar ve seed'in nakit gerekçesi kalkar.
- Önerilen telafi: maaş bantları ×1,5 (karar bekliyor). Açık yine 30 bin civarına döner ama 52. hafta ve evre 3 kapıları tutmaz.
- Dört kapıyı ancak ×2,2 tutar ve ilk yılı 87 bine kadar derinleştirir. Üçüncü yol: telafisiz bırakıp işi müşteri temsilcisi maaşına bağlamak.
- Seçim Erdem'in; uygulamadan sonra bot koşusuyla yeniden ölçülür.
- **Gelir gösterimi** (Erdem). MRR ortak dildir. B2B koltuk fiyatı aylık söylenir. Hesap ipucunda kalan sözleşme değeri yazar: "Kalan 5 ay · 10.500 dolar" (karar bekliyor).
- Acil durumun telafisi tek seferlik giderdir: B2B kredisi aylık ücretin %10 ile %25'i olur, MRR değişmez.

Kaynak: C_ICERIK_v3 §3, Soru 1; MEMNUNIYET_SIM §0 madde 8; ERDEM_CDQ_CEVAP (C3).

## 9. Olaylar (B)
B uygulanıyor; sabitlerin hepsi onay bekliyor.
- **Acil durumlar.** Beş olay: gece kesintisi (B2B, B2C), ay sonu kapanışı yapamıyoruz (B2B mail), ödeme alınamıyor (B2C), sürüm sonrası bozulma, yorum fırtınası (B2C). İki olay arası en az 4 hafta, sonrası rastgele (Erdem); koşu başına hedef 4 ile 14 olay.
- Olasılığı sunucu kalitesi, açık hata, yük ve son sürümün hatalı çıkması belirler. Gece olayı kartı ilk tam saatte açılır ve geçmiş zamanla anlatır; gece yalnız acil durum kartı açılır, öbürleri mesai başına bekler.
- Bedel olayın ölçeğinden türer; sabit dolar ya da yüzde yoktur. Çip, geçmiş satırı ve bot aynı sayıyı okur.
- Seçenekler:
  - Ekip hemen düzeltsin: moral bedeli servis çöktüyse eksi 10, tek akış tıkandıysa eksi 7; bedeli ödeyenler adla yazar.
  - Kendin bak: yalnız kurucu ya da ekip en çok 2 kişiyken; kurucunun gelecek haftaki verimi %15 düşer.
  - Sonraki sprinte bırak: B2B'de hesap memnuniyeti hemen eksi 6, her sprint eksi 3.
  - Sprinti durdur: düzeltme kartı sprintin başına girer.
- **Sprint ortası kâğıtları.** Konuşan, o kartta o aşamada gerçekten çalışan kişidir (PM kâğıdında ekipteki PM). Havuz 40 kâğıt. Sprint başına en çok bir kâğıt gelir, bazı sprintlerde hiç gelmez; aynı kâğıt 52 hafta dönmez, koşuda en çok 3 kez görünür.
- **Söz olayı** (B2B): arayıp ek süre iste, testi kısalt, ekipten fazla mesai iste, söz kaçsın. B2C'de yoktur. Sürüm sonrası B2B'de kısa teşekkür maili, B2C'de 2 ya da 3 yorum gelir.
- Yatırımcı hazırlığı oyundan kalktı (Erdem). **Mail saatleri:** mail, kâğıt, hatırlatıcı ve haber satırı gece yarısı düşmez; şirketin mesai penceresinde çekilmiş bir geliş saati alır. Yalnız acil olanlar üretildiği anda gelir.

Kaynak: PRD_FAZ_B_OLAYLAR §2 Karar 1 ile 21; D_MODEL_v3 §3.7; C_ICERIK_v3 §8.

## 10. Pazaryeri (E, taslak, Erdem yorumu bekliyor)
Bu bölümün tamamı karar bekliyor. E planı eski eksen adlarını taşıyor; Q1 kararına göre uyarlanacak.
- B2C'nin tek ürünü pazaryeri olur; not ve video uygulaması silinir. İki taraf vardır: alıcı (Keşif, Sepet ve Ödeme, Siparişlerim) ve satıcı (Ürün Yükleme, Satıcı Paneli).
- Gelir ikidir: komisyon (satış hacmi × oran) ve üyelik (üye × aylık ücret). Alıcı kitlesi bugünkü motorla büyür. Mağaza, mağaza memnuniyeti, sipariş ve satış hacmi yeni kavramlardır.
- Oyuncu iki kolu çevirir. Her değişiklik önizlemeyle gelir: gelirin şimdiki ve 3 ay sonraki farkı, mağaza memnuniyeti, yeni mağaza girişi. Küçük pazaryerinde komisyon artışı sert, büyükte yumuşaktır.
- Üyelik temel alışverişi kilitlemez; üye daha sık alışveriş yapar (ayda 1,6 sipariş, ücretsiz alıcı 1,0).
- Mağaza memnuniyeti ipucunda nedenleri yazar: "Araçlar artı 8 · Satışlar artı 3 · Komisyon 0 · Açık hata eksi 4". Satıcı hattında düzeltme kartı mağaza sayar: "Ürün Yükleme düzelt · 3 hata · 14 mağaza".
- Demoda yalnız komisyon ve üyelik vardır; premium mağaza, reklam ve sezon tepeleri EA'dadır. Frank'in çeki, seed ve Series A haftaları bugünkü pencerede kalmalıdır.

Kaynak: E_PLAN §0, §2.1 ile §2.9, §5.

## Karar bekleyenler (özet)
1. Giderler: kurucu satırı, ofis kirası, telafi yolu (C Soru 1). Memnuniyet modeli ve imza kapısı (Soru 2), hata terimi ve güncelleme yaşı (Soru 3), bütçe kesintisi (Soru 4), yenileme bantları (Soru 5).
2. Sektör vurgusu, Çekirdek tavan kuralı, pazar beklentisi tablosu, ölü sektörler, beklenti kalibrasyonu (KALITE Soru 1 ile 5).
3. Gönder sorusunun zamanı, kendi kartını test edenin payı, birden çok PM'de fayda, planın hatayı bilmesi (D Soru 1 ile 4); tek kurucuda hata sprinti %6,6.
4. K3'ten sonra derinlik kartları, lider önerisinin D'ye göre değişmesi, EA takımında kişinin takım dışına geçmemesi (SPRINT_DUZENI Soru 1 ile 3).
5. B ve A sabitleri, RAPOR_A §1 soruları, B2C ekonomisinin yeni dengesi. Pazaryerinin tamamı.
