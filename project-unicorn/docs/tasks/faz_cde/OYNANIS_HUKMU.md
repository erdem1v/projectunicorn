# Oynanış hükmü · Q, C, D
2026-10-18 · Kıdemli oyun tasarımcısı (yardımcı yönetmen turu, oturum 3ef3b847) · Kod `main` @ `889b9b8`; koda dokunulmadı.

Girdi: `QCD_GOREV_PAKETI.md`; araştırma `arastirma/R13_OVULEN.md`, `R14_KIZILAN.md`, `R15_BIZIM_DONGU.md`; tasarım
`OYUN_SISTEMLERI.md`, `KALITE_v2.md`, `C_ICERIK_v3.md` (yenileme için `C_ICERIK_v2.md` §2.6), `SPRINT_DUZENI.md`,
`D_MODEL_v3.md`, `D_SIM_v3.md`, `MEMNUNIYET_SIM.md`; Erdem `ERDEM_CDQ_CEVAP.md`, `ERDEM_CD_YORUM.md`.

Kaynak gösterimi: kod `dosya:satır` (`889b9b8`); belge `ad §`; araştırma `R13 Ders n`, `R14 Tnn` ya da `R14 §8 madde n`,
`R15 §n`. Sayıların hepsi bot ya da simülasyon sayısıdır; insan oturumu yoktur (R15 §1.5). Kaynaksız iddia [kanıtsız],
ölçülmemiş hedef [hedef önerisi] diye yazılır.

## 0. Hüküm
1. Q, C ve D doğru yönde. Görünmez modeli siliyor, memnuniyete neden yazıyor, sprint planının boşluğunu kapatıyor. Üçü
   birlikte okunur bir oyun kurar. Eğlenceli bir oyunu kendiliğinden kurmaz; §2'deki değişiklikler bunun için.
2. En büyük tehlike Game Dev Tycoon kalıbı: öneriyi uygula, başlat, bekle (R14 §9, risk yüksek). D, 50 kişide planı 2 ile 3
   tıka indirir ama tıkın içinde karar yoktur. Çözüm yeni sistem değil: bugün yalnız PM varken açılan çeyrek hedef alanı
   (`sprint_catalog.gd:570-573`, `quarter_view.gd:137`) herkese açılsın ve önerinin sırasını gerçekten değiştirsin.
3. İkinci tehlike Big Ambitions kalıbı: para akınca karar kalmıyor. Ürün uyumu imzaların %75'inde 100, bakımlı üründe
   yenilemelerin %100'ü zamla bitiyor (MEMNUNIYET_SIM §2.9, §2.10). Q'nun kalibrasyonu ile C'nin bantları bunu birlikte
   çözmek zorunda. Kapılar §3'te.
4. Demoya özel bir gerçek: ilk yenileme imzadan 44 hafta sonra açılır (C v2 §2.6.1, MEMNUNIYET_SIM §2.10); ilk imza 9.
   haftada (R15 §3.1), yani ilk yenileme yaklaşık 53. haftada. Bot Series A'yı 57 ile 71. haftada imzalıyor (R15 §3.3).
   Demoda yenileme neredeyse yok. Demonun orta oyununu satış, sprint, söz ve acil durum taşır; yenileme EA ve tam oyunun işi.
5. Kesinti bütçesi şart. B2B Traction'da bugün haftada 1,72 saat durması var (R15 §4.4); C ve D en kötü durumda +1,1
   ekliyor (R15 §7.4). Saati durduran kesinti haftada en çok bir olmalı, yenileme kâğıdı dahil.
6. Kesilecek ya da sadeleşecekler: bütçe kesintisinin kâğıdı (sahte seçim), istek kartlarının çoğu (haftada 1,1 boş tık),
   ağırlıksız gönder sorusu, EA takımı (ertelenir), iki ölü sektör.
7. Güçlenecekler: imza kapısının kayıp nedeni (oyunun ilk açıklanmış kaybı), darboğaz cümlesi, güncelleme yaşının vurgu
   alanlarına bakması, ofis kirasının masa sayısıyla gerçek bir karara dönmesi.
8. Erdem'e üç itiraz var: sunucu düğmesinin B2C'de angaryaya dönmesi, gönder sorusunun daraltılması, EA takımının
   ertelenmesi (§2.2). Hiçbiri sessizce uygulanmaz.
9. %90 için Q, C ve D yetmez: Series A doruğu, kayıp ekranı, saatin kararlardan sonra kendiliğinden sürmesi, ses ve ilk
   ekran, insan oturumu (§6).

## 1. Hedef çekirdek döngü

### 1.1 Katmanlar
Süreler 1× hızdadır: 1 hafta 22,5 sn, 3×'te 7,5 sn (`time_model.gd:43-45`; R15 §2.1). R13'ün ölçütü dakikada yaklaşık
bir anlamlı karar ve 90 saniyeyi geçmeyen boşluktur (R13 §6 madde 3, tahmin); 1×'te 90 saniye 4 haftadır.

| Katman | Süre (1×) | Oyuncunun 1 ile 3 anlamlı kararı | Sıklık hedefi | Geri bildirim |
|---|---|---|---|---|
| Hafta | 22,5 sn | (1) B2B: hangi adayla görüşeceği ve fiyat duruşu. (2) Gelen tek kesintiye cevap. (3) Uyarı varsa sunucu payı | Saati durduran kesinti haftada en çok 1. Görüşme oyuncunun kendi açtığı iştir, kesinti sayılmaz | TopBar kasa ve MRR, imza ya da kayıp nedeni cümlesi, ofis |
| Sprint | 1 ya da 2 hafta | (1) Planı onayla ya da değiştir. (2) Sprint süresi. (3) Gerekirse söz ya da gönder kararı | Sprintte bir plan. Devredilmiş plan saati durdurmaz | Aşama şeridi ve darboğaz cümlesi, "Test: 3 hata buldu, 2'si düzeltildi", sürüm notu, teşekkür notu |
| Ay ve çeyrek | 4 ile 13 hafta | (1) Çeyrek hedef alanı (ya da "Hatalar"). (2) Kimi işe alacağı. (3) Sunucu kademesi ve ofis. EA ve tam oyunda: yenileme raporu | Çeyrekte bir hedef. Yenileme kâğıdı ayda en çok bir, yalnız karar varsa | Çeyrek özeti (`summary_frequency` varsayılanı, CLAUDE.md §6), alan sözcükleri, Hesaplar tablosu |
| Koşu | 60 ile 104 hafta | (1) Pazar. (2) Hangi sektörlere satılacak. (3) Fon sırası ve Series A | Her evre bir yeni kural (R13 Ders 8) | Evre kartı, Frank, gazete |

Evrenin yeni kuralı (öneri; Q ve C'nin parçalarıyla kurulur, yeni sistem yok):
- **Bootstrap:** pazar yalnız Çekirdek bekler, MVP onu karşılar (KALITE_v2 §3.2). Kural: ilk sürüme yetiş.
- **Traction:** imza kapısı ve sektör vurgusu ilk kez ısırır, öteki alanlar 0,5 beklenir. İlk kayıp nedeni cümlesi gelir.
- **Series A Hunt:** beklenti Çekirdek 1,5, öteki alanlar 1 olur; yatırımcı sorgusu en zayıf alanı okur; 3★ hesap
  kurumsal madde ister.
- Evre geçişinde beklentinin 8 haftalık yükselişi önceden bir satırla duyurulur. Sessiz yükselen beklenti "iyi işim
  cezalandırıldı" diye okunur (R14 §8 madde 1).

### 1.2 İlk saat, orta oyun, son oyun
| | İlk saat (hf 1 ile 15) | Orta oyun (hf 15 ile 55) | Son oyun (hf 55 ile 104, EA) |
|---|---|---|---|
| Oyuncu ne yapıyor | Tür seçer, 3 sprintte MVP, yayın (bot hf 7), ilk görüşmeler (hf 8), ilk imza (hf 9) (R15 §3.1) | Ekibi 3'ten 13'e büyütür, çeyrek hedefini seçer, söz verir, acil durumlara cevap verir, Frank'in çeki ve seed | Series A, ilk yenilemeler, kurumsal madde, EA'da 25 ile 50 kişi |
| Anlamlı kararlar | Sprint süresi, ilk kartlar, kimle görüşmeli, ilk işe alım | Çeyrek hedefi, hangi sektöre satış, kimi işe almalı, söz verip vermemek, sunucu kademesi | Yenileme raporu, ofis ve kira, kademe, fon seçimi |
| Yeni kural | Pazar açılınca imza kapısı: ilk açıklanmış kayıp | Sektör vurgusu, söz olayı, acil durum, kâğıt | Beklenti 1,5, yenileme bantları, kurumsal madde |
| Bugünkü açık | Pazar 7 hafta kapalı, haftaların %30'unda karar yok (R15 §3.1); huylar etkisiz (`founder_constants.gd:41-43`) | Traction'da sonlu runway yalnız haftaların %5,9'unda (R15 §4.6); seed sonrası hedef satırı boş (`cheque_read.gd:15-23`) | Kapıdan imzaya 1 ile 5 hafta, 10 tohumda 9 imza, ret sonrası 40 hafta boş (R15 §3.3) |
| Q, C, D'nin payı | İmza kapısı ve kayıp cümlesi (Q, C) | Sprint arzı ve çeyrek hedefi (D), memnuniyet satırları (C) | Bantlar ve kademe (C). Doruk PRD dışı (§6) |

### 1.3 1 kişilik ve 50 kişilik şirket
| Konu | 1 kişi (Bootstrap) | 50 kişi (EA) |
|---|---|---|
| Sprint | Kurucu her aşamada çalışır; tek kartı ve süreyi seçer | Öneriyi onaylar ya da devreder; asıl kararı çeyrek hedefidir; sprintte 27 kart (OYUN_SISTEMLERI §2) |
| Satış | Kurucu haftada en çok 4 görüşme yapar, her biri sprint payından 2/40 götürür (R15 §3.2) | Temsilciler işler; kurucu yalnız 3★ adayı ve VC'yi oynar [öneri] |
| Hesaplar | 5 ile 20 hesap; ipucu satırları okunur | 330 hesap: başlıkla sıralanan tablo (Erdem), yenileme raporu tek kâğıt, kâğıtta yalnız kararı olan hesap adıyla |
| Ekip | İlk işe alım en büyük karar | İşe alım darboğaz cümlesinden okunur; karar rol karışımıdır |
| Kesinti | Haftada en çok 1 | Aynı bütçe; kesinti hesap ya da kişi sayısıyla doğrusal büyümez |
| Tık | Sprint başına 2 ile 3 | Sprint başına en çok 1 kişininkinin 3 katı (R13 Ders 5) |

Hedef: 50 kişide oyuncu kart seçmez, öncelik ve kadro seçer (SPRINT_DUZENI K4). Kanıt: Startup Company olumsuzlarının
%19'u ölçekte mikro yönetim (R14 T05).

## 2. Mekanik mekanik hüküm
Sınıflar R15 §6 ile aynıdır: S gerçek ödünleşim, T tek doğru cevap, B boş tık. "Kapı" sütunu §3'te toplanır.

### 2.1 Tablo
| # | Mekanik (faz) | Doğurduğu karar | Sıklık | Tek satır okunuş | Angarya, akış riski | Kanıt | Hüküm ve somut değişiklik |
|---|---|---|---|---|---|---|---|
| 1 | Ürün uyumu U ve Çekirdek tavanı (Q) | Hangi alana yatırım; hangi adayla görüşme | Her görüşme ve imza | "Ürün uyumu 46 · Çekirdek Zayıf" (KALITE_v2 §4) | Formül görünürse GDT'nin "gizli formül" şikâyeti (R14 T06); doyarsa karar yok | İmzaların %75'inde U = 100 (MEMNUNIYET_SIM §2.9) | **Tut, kalibre et.** Ekranda yalnız sözcük ve en zayıf alan; tavan kuralı tek cümle, sayı yok. Kapı: U = 100 imzaların en çok %25'i |
| 2 | Sektör vurgusu (Q) | Hangi sektörün adayına gidilir, hangi alan güçlenir | Her aday kartı | "Lojistik hesapları önce Çekirdek'e, sonra en çok Entegrasyonlar alanına bakar." | 13 sektörlük tablo ezber ister | R14 T06; Erdem: "daha ağırlıklı baktığı olmalı" | **Tut, sadeleştir.** Cümle aday kartında ve ipucunda hep yazar; sektör 11'e iner (§4 soru 1). Kapı: bir alan Zayıf iken onu vurgulayan sektörde imza oranı öbürlerinden en az 15 puan düşük |
| 3 | Pazar beklentisi (Q) | Yerinde saymak mı, alanı büyütmek mi | Evre geçişi (2 kez), rakip çıkışı | Alan sözcüğü; "Henüz beklenmiyor" | Sessiz yükselirse haksız ceza (R14 §8 madde 1) | Çıtayı ×2 yapmak bile tutumu %97 zamda bırakıyor (MEMNUNIYET_SIM §2.10) | **Güçlendir.** Yükseliş önceden duyurulur. Kalibrasyon: evre 2 imzalarında U ortancası 70 ile 85 (KALITE_v2 Soru 5) |
| 4 | Memnuniyet satırları (C) | Hangi sözü vermeli, hangi hattı düzeltmeli | Sürekli | İpucu satırları, toplam = memnuniyet (C v3 §5.8) | Satır çoğalırsa okunmaz | Nedensiz düşüş 0 (M1); Papers'ın sebepli ceza faksı (R13 Ders 2) | **Tut.** İpucu en çok 5 satır; tabloda memnuniyetin yanında en büyük olumsuz satırın adı |
| 5 | İmza kapısı (C, Q) | Önce ürünü güçlendir, sonra o sektöre sat | Görüşme başına | "Entegrasyonlar sizde henüz zayıf. O taraf güçlenince yeniden konuşalım." | Kapı görüşmeden önce sezilmezse oturum boşa gider | Görüşmeler %98 kazanılıyor (R15 §8.3); kapı `fix_worst`'te imzaların %13,6'sını çeviriyor (MEMNUNIYET_SIM §2.9) | **Güçlendir.** Oyunun ilk açıklanmış kaybı budur (R13 Ders 10). Aday kartı U sözcüğünü görüşmeden önce yazar. Kapı: bakımlı üründe ret %5 ile 20, bakımsızda en az %25 |
| 6 | Güncelleme yaşı (C) | Bugünkü tanımla yok: Çekirdek her hesabın alanı, her sürüm sayacı sıfırlar | Çalışan ekipte hiç | "Son güncelleme 22 hafta önce. 26 haftadan sonra her ay 1 puan düşer." | Yok, ama karar da yok | Bot 1,3 haftada bir sürüm çıkarıyor (C v3 §5.5) | **Güçlendir.** Sayaç Çekirdek'i saymaz, yalnız hesabın iki vurgu alanını sayar. Tek alana yüklenen oyuncu ihmal ettiği sektörün izini görür |
| 7 | Bütçe kesintisi (C) | Kâğıt: "30 koltukla yenile" ya da "ayrılmayı kabul et"; ikincisi her durumda kötü | 330 hesapta yılda 5,75 | Mailde neden | Sahte seçim (T); dayatılan şans (R14 T07) | Bakımlı üründe tam kayıp 0 (MEMNUNIYET_SIM §2.11); R14 §8 madde 5 | **Sadeleştir.** Olay kalır (Erdem istedi), kâğıt kalkar. Memnun hesap yarı koltukla yeniler, mail nedeni yazar; memnun olmayan ayrılır, kayıp ekranında "Bütçe kesintisi" |
| 8 | Yenileme bantları ve raporu (C) | Satışçı raporunu onayla ya da indirim isteyene aynı fiyatı teklif et; kurucu yolunda toplu teklif | Ayda en çok 1 kâğıt; ilk yenileme hf 53 civarı | "%10 indirim istiyor: Yelken Ofis." | Bakımlı üründe hep zam, kâğıt hiç gelmez; 330 hesapta her ay kâğıt | %100 "Zamma açık" (MEMNUNIYET_SIM §2.10); Big Ambitions kalıbı (R14 T04) | **Güçlendir.** Önce U kalibrasyonu, sonra bantlar (örnek "Zamma açık" ≥ 45, C v3 Soru 5). Satışçı ve kurucu kâğıdı ayda tek kâğıtta birleşir ve kesinti bütçesine sayılır |
| 9 | Sunucu yük ve kapasite düğmeleri (C) | Ne kadar boş pay: para mı, kesinti riski mi | Büyüme uyarısıyla | "Yük %80 · boş pay 650 koltuk, ayda 1.560 dolar" | %10 adımla 10 kat büyüyen ürün 24 tık (R15 §7.2); B2C MRR 4 binden 726 bine çıkıyor (R15 §8.6), yaklaşık 54 tık [hesap: ln 180 ÷ ln 1,1] | R13 Ders 5; R14 T05 | **Erdem'e itiraz (yumuşak), §2.2.** Elle düğme kalır. Uyarı satırında tek tık "Yükü %70'e indir"; aynı iş üçüncü kez yapılınca "Payı koru" anahtarı önerilir |
| 10 | Sunucu kademesi ve kurumsal madde (C) | Ekonomik ucuz ve riskli; Kurumsal pahalı ama 3★ hesabı açar | Koşuda 1 ile 3 kez; maddede 8 hafta süre | "Kurumsal'a geç: ayda +X dolar, kesinti ihtimali yarıya iner" | Düşük | Erdem C4; gerçek takas (R13 Ders 7) | **Tut.** Son oyunun en iyi stratejik kararlarından biri. Kapı: üç kademenin her biri en az bir bot senaryosunda en iyi sonuç |
| 11 | Giderler, kurucu satırı, ofis kirası, maaş ×1,5 (C) | Bugün yok: Finans salt okunur, ofis taşımak bedelsiz (R15 §8.8) | Sürekli | Beş kalemlik gider listesi | Para karar doğurmuyor; telafisiz ilk yıl kolaylaşır | Açık 41K'dan 13K'ya iner (MEMNUNIYET_SIM §4.1); ×1,5 dört kapının ikisini tutar (§5.4) | **Tut, güçlendir.** ×1,5 kabul. Ofisin masa sayısı işe alım tavanı olur (bugün yalnız gösterim, `office_map_card.gd:63`); kira ilk kez bir karar doğurur |
| 12 | Rol, yıldız ve uyum (D) | Kimi işe almalı: rol, yıldız, maaş | Koşuda 21 alım (R15 §4.2) | Plan ekranında "Mert · Geliştirme 12/hf" | Hata çarpanı okunmazsa yıldız hissedilmez; otomatik atamadan gelen eksi 2 moral haksız gelir | D_MODEL_v3 §3.3; Startup Panic moral angaryası (R14 §5) | **Tut.** Dosyada hata çarpanı sözcükle ("Özenli", "Aceleci") [öneri]. Uymayan iş yalnız kişi aksi hâlde boşta kalacaksa verilir ve plan ekranı adıyla yazar |
| 13 | Test ve gönder sorusu (D) | Tarih mi, kalite mi | Sprintlerin %4 ile 29'u (D_MODEL_v3 §3.7) | "Hesap Planı ve Stok Sayacı'nda 4 bilinen hata kaldı..." | Ölçülen fark küçük: teslim en çok %0,9, açık hata en çok %13,8 (D_SIM_v3 §0 madde 6). Ağırlıksız soru angaryadır | R13 Ders 5; R14 §8 madde 8 | **Sadeleştir. Erdem'e itiraz (hafif), §2.2.** Soru yalnız kart bir söze, isteğe ya da tarihe bağlıysa gelir; öbüründe "bırak" sessiz işler ve sürüm notu bir satır yazar. Test satırı her kartta kalır |
| 14 | PM hazırlığı (D) | PM almak mı, hangi yıldız | İşe alımda | "Hazır · Selin'in gözünden geçti"; plan: "Kartlar hazır geldi: aynı iş 12 puan az tuttu" | Kazanç görünmezse PM değersiz görünür | D_MODEL_v3 §3.8; Erdem D3 | **Tut.** Plan ekranı sprint başına hazırlık kazancını sayıyla yazar. Birden çok PM'de fayda en iyi PM'den (§4 soru 7) |
| 15 | Kurucu (D) | Kurucu satsın mı, kod mu yazsın; yanına kimi alsın | Her hafta | "Kurucu bu hafta 4 görüşmede: sprint payı %80" | 2★ tabanı görünmez (Erdem) ama hızı sayıyla görünür | Şirket teslimi 72 adımın hepsinde artıyor (D_SIM_v3 §6.1) | **Tut, güçlendir.** Görüşme ile sprint arasındaki takas kurucunun haftalık kararıdır; plan satırı bunu yazar. Düşüşün nedeni üç cümleden biri (§4 soru 8) |
| 16 | Darboğaz cümlesi ve plan ekranı (D) | Hangi rolü işe almalı, hangi kartı çıkarmalı | Her plan | "Test satırı dolu. Yeni kart sonraki sprinte kalır." | Birden çok cümle şerit olur, okunmaz | Erdem D6; R13 Ders 2 | **Tut, güçlendir.** Her zaman tek cümle, en büyük darboğaz; cümle öneri yazmaz (Erdem). 50 kişide aşama başına özet |
| 17 | Derinlik kartları (D) | Hangi alanı derinleştirmeli (çeyrek hedefiyle) | K3 bitince; hat başına en çok 8 | Kart adı işin kendisi; etki satırı azalan kazancı yazar | Jenerik ad grind hissi verir (R14 T01) | Arz kapısı tutuyor (D_SIM_v3 §11) | **Tut.** Ad şablonla değil, hat başına en az 6 elle yazılmış adla. 50 kişide tek tek seçilmez |
| 18 | İstek kartları (C, D) | "Söz ver" gerçek; "Listede" ve "Şimdi değil" boş | Haftada 1,1 kesinti, koşuda 113,8 | Planda hesabın kendi kartı: "Ege Sigorta isteği: aylık rapor aktarımı" | En büyük angarya kaynağı (R15 §8.2) | Bot 1.138 kartın 1.084'ünde "Listede" seçti (R15 §8.2) | **Sadeleştir.** Kesinti olarak yalnız 3★ ya da MRR'da ilk çeyrekteki hesaptan gelir ve yalnız söz sorar. Öbür istekler plandaki "İstekler" listesine sessiz düşer; yayına girerse +4, girmezse etkisiz (SPRINT_DUZENI K8) |
| 19 | Lider önerisi ve çeyrek hedefi (D) | Bugün yok (T): öneriyi uygula, başlat | Her plan | Planın başında "Bu çeyrek: Entegrasyonlar" | GDT kalıbı: öneri hep doğru (R14 §8 madde 2) | R15 §6 #8; hedef bugün yalnız PM'le açık (`sprint_catalog.gd:563-573`) | **Güçlendir, yeni sistem yok.** Çeyrek hedefi PM'siz de seçilir, önerinin 5. basamağını sürer; seçenekler alanlar ve "Hatalar". Aynı öneri üç sprint değişmeden onaylanınca ekran "Planlamayı devret" önerir; devredilen plan saati durdurmaz |
| 20 | Düzeltme kartı (D) | Hata mı, özellik mi | Hatta 5 hatada Öncelikli | "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı" | Sürekli hata sprinti (Erdem reddetti) | D_SIM_v3 §8.6 | **Tut.** Kart 2 × açık hata. "Hatalar" hedefinde öneri düzeltmeyi yarı kapasiteye kadar öne alır; tavan aynı |
| 21 | EA takımı (D) | Esneklik mi, lider kazancı mı | EA, 10 kişiden sonra | "Çekirdek takımı · lider Ayşe · 12 kişi · hız ×1,06 · boşta 2 kişi" | 3 takım takımsızın %81'i, 7 takım %61'i (D_MODEL_v3 §3.14); şişkinlik (R14 T02) | Software Inc. "massive feature creep" (R14 T02) | **Ertele. Erdem'e itiraz (hafif), §2.2.** EA'nın ilk sürümüne girmez; 50 kişi çeyrek hedefi ve devretle oynanır |

### 2.2 Erdem'e itirazlar
Her biri gerekçeli; Erdem'in kararı değişmeden PRD'ye yazılır, itiraz ayrıca "onay bekliyor" diye sorulur.

**İtiraz 1 · Sunucu kapasitesi (C1).** Erdem: "kapasite arttır, azalt ... oyuncuya bırakalım ... belki kullanıcı kendisi
hep orada bir gap bırakmak isteyebilir" (ERDEM_CDQ_CEVAP).
- Sorun: %10 adımlı düğme büyüyen üründe tekrar eden aynı cevaptır. B2C'de koşuda 50'yi aşan tık (tablo satır 9).
  Aynı cevabı üçüncü kez veren karar şablona dönmeli (R13 Ders 5); otomasyon görünür ve geri alınır olmalı (R13 Ders 6).
- Öneri (A): düğme oyuncuda kalır. Büyüme uyarısının yanında tek tık "Yükü %70'e indir". Oyuncu aynı işi üç kez yapınca
  blok "Payı %30'da tut" anahtarını önerir; oyuncu açar, her değişikliği gelen kutusu bir satırla yazar, kapatılabilir.
  Pay oyuncunun seçtiği sayıdır, yani "gap" kararı oyuncuda kalır.
- Alternatif (B): adım %10 yerine %25. Alternatif (C): Erdem'in hâli aynen, kapı tık sayısını ölçer ve sonucu getirir.

**İtiraz 2 · Gönder sorusu (D2).** Erdem: "Şu haliyle gönderelim mi yoksa ... bir sonraki sprinte mi atalım gibi bir şey
olabilir belki."
- Sorun: iki cevabın bedel farkı ölçümde çok küçük (tablo satır 13). Ağırlıksız soru akışı keser ve oyuncuya "her zaman
  vurgulu olana bas" öğretir; R15'in T sınıfı.
- Öneri: soru, cevabın gerçek bedeli olduğu yerde kalır: söz, istek ya da tarih. Öbür kartlarda sessiz "bırak" ve sürüm
  notu satırı. Testçinin değeri "Test: 3 hata buldu, 2'si düzeltildi" satırında görünmeye devam eder.
- Alternatif: v3'ün eşiği (bulunanın üçte biri) kalır ama soru kesinti bütçesinin en son sırasındadır.

**İtiraz 3 · EA takımı (D1).** Erdem: "ekip büyüdükçe bir verim kaybı ... her ekip bazında bir lider alabiliyoruz."
- Sorun: ölçümde takımlı düzen takımsızdan yavaş (tablo satır 21). Takımın tek kazancı planlama yüküdür (D_MODEL_v3 §3.14);
  bunu çeyrek hedefi ve devret zaten çözer. Yeni nesne, yeni ekran, yeni kural: Software Inc.'in şişkinlik şikâyeti.
- Öneri: EA'nın ilk sürümünde yok. İnsan oturumunda 25 kişiden sonra "planı yönetemiyorum" çıkarsa gelir.
- Alternatif: takım yalnız lider ve alan etiketidir; kişi takım dışına geçebilir, kayıp yoktur, lider çarpanı kalır.

Not, itiraz değil: uymayan işte eksi 2 moral (Erdem onayı) kalır. Atama otomatik olduğu için kural tek koşulla adil olur:
sistem uymayan işi yalnız kişi aksi hâlde boşta kalacaksa verir ve plan ekranı bunu kişinin adıyla yazar.

## 3. Paketteki 5 oynanış riski

### Risk 1 · Orta ve son oyunda karar kalmıyor
Ne yapılmalı:
- Q: pazar beklentisi botun ürününe göre kalibre edilir; evre geçişi duyurulur.
- C: yenileme bantları kalibrasyondan sonra kaydırılır; güncelleme yaşı vurgu alanlarını sayar; imza kapısı ret cümlesiyle.
- D: çeyrek hedefi önerinin sırasını değiştirir.
- Demo için: orta oyunun kararları satış, sprint, söz ve acil durumdadır; yenileme EA'nın işidir (§0 madde 4).

Sahip: Q (beklenti), C (bantlar, yaş, kapı), D (çeyrek hedefi).

Oynanış kapıları:
- İmzaların en çok %25'inde U = 100; evre 2 imzalarında U ortancası 70 ile 85 (Q).
- `fix_worst` kolunda yenilemelerin en çok %50'si "Zamma açık", en az %15'i "İndirim ister" ya da daha kötü (C).
- `fix_none` kolunda geç kayıp en az %10 (M5'in hedefi, bugün %1,4 ve %6,9; MEMNUNIYET_SIM §1) (C).
- Bakımlı üründe imza kapısı reddi imzaların %5 ile 20'si (Q, C).
- Traction ve Series A'da, B2B ve B2C'de her 10 haftalık pencerede en az 3 gerçek karar (R13 Ders 8). Gerçek karar: iki
  farklı bot politikasının farklı sonuç aldığı karar. Bakımlı üründe yılda en az 15 (Q, C, D) [hedef önerisi].
- Yalnız Çekirdek'e yüklenen bot kolunda 52. haftada vurgu alanı ihmal edilen hesapların en az yarısında yaş terimi en az
  eksi 3; dengeli kolda %10'dan azında (C).

### Risk 2 · Servis gideri kalkınca ilk yıl fazla kolay
Ne yapılmalı:
- Servis ve araç gideri kalkar (Erdem). Maaş ×1,5 kabul: ilk yılın biçimini korur (MEMNUNIYET_SIM §4.1: B2B en derin açık
  30 ile 32 bin, bugün 37 ile 41 bin).
- Orta oyunun parası maliyetle değil kararla çözülür. Bugün de servis gideri varken Traction'da runway %94 sonsuz
  (R15 §4.6): sorun gider değil, harcanacak yerin yokluğu. Kasa bir hıza dönüşmeli: işe alım, ofis masası, Kurumsal kademe,
  ileride pazarlama (E). "Kâr yeni bir seçim açmalı" (R14 §8 madde 3).
- Zorluk kadranı (bugün yalnız başlangıç nakdi, `founder_constants.gd:59,188`) PRD dışıdır (§6).

Sahip: C (gider, telafi, ofis kirası ve masa); E (pazarlama); PRD dışı (zorluk).

Oynanış kapıları:
- B2B `fix_worst`: ilk 40 haftada en derin kümülatif açık 25 ile 45 bin dolar (C).
- Evre 2'de en düşük runway en az bir kez 4 ayın altında (tohum 7'de bugün de A değişkeninde de 2,0 ay; tohum 11'de
  bugün 9,8, A değişkeninde 18,3 ay; MEMNUNIYET_SIM §4.1). Tohum 11 bu kapıyı bugün de tutmuyor (C).
- Bootstrap runway 6,7 ay korunur (C).
- Kasasını harcayan ve biriktiren iki bot politikası arasında Series A kapısına varış farkı en az 6 hafta (C, D)
  [hedef önerisi, ölçülmedi].
- İlk üç koşuda iflas oranı ve iflasın tek cümlelik nedeni insan oturumunda ölçülür (R14 §8 madde 6).

### Risk 3 · 50 kişide oyuncu ne yapıyor
Ne yapılmalı: kararın kart seçmekten öncelik ve kadroya kayması. Çeyrek hedefi; planlamayı devret; darboğaz cümlesinden
işe alım; yenileme raporunda tek kâğıt; Hesaplar tablosunda sıralama ve görünümler (Erdem); kurucu yalnız büyük adayları
oynar.

Sahip: D (hedef, devret, plan, darboğaz), C (Hesaplar, yenileme raporu, temsilci).

Oynanış kapıları:
- 50 kişide sprint başına oyuncu tıkı en çok 1 kişininkinin 3 katı (R13 Ders 5) (D).
- 50 kişi ve 330 hesapta saati durduran kesinti haftada en çok 6 kişi ve 20 hesaptakinin 1,5 katı (C, D).
- 50 kişilik EA koşusunda her 10 haftada en az 3 gerçek karar (risk 1 tanımı) (C, D).
- Öneri doluluğu en az %94 (D_SIM_v3 kapı 19), boşta payı en çok %15 (D).

### Risk 4 · Sistem kalabalığı
Ne yapılmalı: §2 tablosunun kes ve sadeleştir satırları. Kural: bir yüzeyde iki bot politikası aynı sonucu alıyorsa yüzey
kesilir ya da sessiz varsayılana döner. Her PRD'nin "Oynanışa etkisi" bölümü bu tablodaki satırı taşır.

Sahip: her PRD kendi mekaniğinin sahibi.

Oynanış kapıları:
- Q, C ve D'nin eklediği her karar yüzeyi R15 §6 sınıflamasında S; T ya da B yüzey 0.
- Her mekaniğin tek satır okunuşu oyunda bir yerde görünür; görünmeyen sayı ekonomiyi sürmez (paket §4).
- Bütçe kesintisi kâğıtsız, istek kesintisi koşuda en çok 25 (bugün 113,8), gönder sorusu sprintlerin en çok %10'unda.

### Risk 5 · Akış kesintileri aynı haftaya biniyor
Ne yapılmalı:
- Kesinti bütçesi: saati durduran kesinti haftada en çok 1, sprintte en çok 1 (B'nin kuralının uzantısı, CLAUDE.md §6).
- Sıra: acil durum (servis çöktü) > söz olayı > yenileme kâğıdı > sprint kâğıdı > gönder sorusu > istek kartı.
- Sıraya giremeyen: varsayılanı uygulanır (gönder: bırak; istek: listeye) ya da süresi izin veriyorsa sonraki haftaya kalır
  (yenileme kâğıdının 2 haftası var, C v2 §2.6.4). Mail ve not saati durdurmaz. Devredilen plan saati durdurmaz.
- Kararlardan sonra saatin kendiliğinden sürmesi PRD dışıdır (§6).

Sahip: D (sıra kuralı ve plan), C (yenileme kâğıdı ve istek kartının sıraya girmesi).

Oynanış kapıları:
- B2B Traction'da saat durması haftada en çok 1,2 (bugün 1,72, R15 §4.4).
- İki kesintili hafta en çok %2; çok kesintili sprint en çok %1 (bugün %1,1, R15 §4.1).
- B2C'de kartsız en uzun seri en çok 4 hafta, yani 1×'te 90 saniye (bugün 6 ile 11, R15 §3.2) (C sunucu kolu ve E).

## 4. Erdem'in 10 açık sorusu
| # | Soru (PRD) | Oynanış etkisi | Öneri | v3'e göre |
|---|---|---|---|---|
| 1 | Sektör ağırlıkları ve ölü sektörler (Q) | Aday seçimini ve alan yatırımını gerçek karar yapar; tablo görünmezse "neden kaybettim" | Ağırlıklar ve tavan aynı (Çekirdek %50, vurgu %25 ve %15, kalan %10, tavan 0,25); ekranda formül değil cümle. Sağlık eklensin, Tekstil ve Medya silinsin | **Değişir.** Her sektör ad, aday ve metin yüküdür. Çeşitliliği ad değil vurgu ikilisi verir; Sağlık'ın kanıtı en güçlü (KALITE_v2 Soru 4), öbür ikisinin ikilisi tablodaki ailelere çok yakın |
| 2 | Pazar beklentisi doyumu (Q) | Doyum kalırsa Big Ambitions kalıbı: satış ve yenileme kararsız | Kalibrasyon: evre 2 imzalarında U ortancası 70 ile 85 ve imzaların en çok %25'inde U = 100; evre geçişi duyurulur | Aynı, kapı sıkılaştı (%25) |
| 3 | Memnuniyet modeli (C) | Her düşüşün adı var (R13 Ders 2); yaş terimi bugünkü tanımla hiç işlemez | Satır toplamı, kayma yok, imzada gerçek değer, kapı eşik + 10, hata terimi 3 × yoğunluk. Değişiklik: yaş sayacı yalnız hesabın iki vurgu alanını sayar | **Değişir (yaş).** Çekirdek her hesabın alanı olduğu için her sürüm sayacı sıfırlıyor; karar doğmuyor |
| 4 | Giderler (C) | İlk yılın sıkışıklığı ve ofisin anlamı | Araç ve servis kalkar; kurucu satırı 1.500; ofis kirası; maaş ×1,5. Ek: ofisin masa sayısı işe alım tavanı | **Değişir (ek).** Kira masa tavanı olmadan yalnız giderdir, karar doğurmaz |
| 5 | Bütçe kesintisi (C) | Ürün dışı kayıp haksız gelebilir (R14 T07) | Olay ve oranlar aynı; kâğıt kalkar, mail kalır; memnun hesap yarı koltukla yeniler | **Değişir.** İki şıktan biri her durumda baskın; sahte seçim akışı keser |
| 6 | Test ve gönder sorusu (D) | Ağırlıksız soru angaryadır | Yalnız söz, istek ya da tarihli kartta; öbüründe sessiz "bırak" ve sürüm notu satırı | **Değişir.** İtiraz 2 |
| 7 | Birden çok PM (D) | PM eklemek teslimi düşürmemeli | Fayda en iyi PM'in yıldızından; ekranda "Selin'in gözünden geçti" | Aynı |
| 8 | Kurucunun %10 düşüşü (D) | "Tek başımayken daha hızlıydım" kaygısı | Kabul; şirket teslimi hep artıyor; plan ekranı düşüşün nedenini üç cümleden biriyle yazar | Aynı |
| 9 | Sprint düzeni ve tek kurucuda %6,6 hata sprinti (D) | Kurucunun ilk haftaları hata kovalamakla geçmemeli | Düzen aynı. Tek kurucuda varsayılan sprint 2 hafta (1 hafta seçilebilir); 2 haftada oran %0,4 (D_MODEL_v3 inceleme tablosu). Çeyrek hedefi herkese açık | **Değişir (küçük).** Varsayılan süre ve çeyrek hedefi |
| 10 | EA takımı (D) | 50 kişide plan yükü; şişkinlik riski | EA'nın ilk sürümünde yok; çeyrek hedefi ve devret yeter | **Değişir.** İtiraz 3 |
| ek | Yenileme bantları (C v3 Soru 5) | Bakımlı üründe yenileme kararsız ve sessiz | Önce U kalibrasyonu, sonra bantlar; hedef dağılım risk 1'in kapısı | Aynı, kapı eklendi |

## 5. %90 kontrol listesi
Durum: **var** (planlı ya da kodda), **eksik**, **risk** (var ama bozulabilir).

| Madde | Kaynak | Bizde | Durum | PRD |
|---|---|---|---|---|
| İlk 15 dakikada zafer, ilk saatte açıklanmış kayıp | R13 §6 madde 1 | MVP hf 7, ilk imza hf 9 (R15 §3.1); açıklanmış kayıp bugün yok, görüşme %98 kazanılıyor | Zafer var; kayıp eksik | Q, C (imza kapısı ve kayıp cümlesi) |
| Her sonucun tek cümlelik nedeni | R13 §6 madde 2 | Memnuniyet ipucu, kayıp nedeni, darboğaz planlı; VC reddi ve koşu sonu cümlesiz (R15 §5.4) | Risk | Q, C, D; VC ve son PRD dışı |
| Dakikada yaklaşık bir karar | R13 §6 madde 3 | B2B dolu; B2C haftaların %65'i kartsız (R15 §4.4) | Eksik (B2C) | C (sunucu kolu), E (fiyat) |
| Angarya yok | R13 §6 madde 4 | İstek kartı 113,8, plan 65 ile 88 kez, sunucu tıkı | Risk | C (istek, sunucu), D (devret, hedef) |
| Orta ve son oyunda yeni kural | R13 §6 madde 5 | Evre beklentisi, kurumsal madde, yenileme; demoda yenileme yok | Risk | Q, C; Series A PRD dışı |
| Şans oyuncunun elinde | R13 §6 madde 6 | Acil durum yük ve hataya bağlı, Yük % görünür; satış zarı çözülmüş | Risk | C; satış PRD dışı |
| Zorluk kadranı ve ucuz kayıp | R13 §6 madde 7 | Zorluk yalnız nakit; kayıp ekranında otopsi ve TEKRAR DENE yok (R15 §5.4) | Eksik | PRD dışı |
| Karakter ve güven | R13 §6 madde 8 | Kâğıdı o kartta çalışan kişi söyler, teşekkür notları; ses yok; şema 17 → 18 → 19 göçü | Risk | Q, C, D göç kapısı; ses PRD dışı |
| Açıklanamayan puan olmasın | R14 §8 madde 1 | U sözcükle, memnuniyet satırla | Var (planlı) | Q, C |
| Çözülmüş oyun olmasın | R14 §8 madde 2 | Öneri T (R15 §6 #8), görüşme %98, fon seçimi tek cevaba yakın (R15 §3.3) | Risk yüksek | D (çeyrek hedefi), Q (kapı); satış ve VC PRD dışı |
| Orta ve son oyunda karar kalsın | R14 §8 madde 3 | U doyumu, %100 zam | Risk yüksek | Q, C |
| Moral ve izin angaryası olmasın | R14 §8 madde 4 | Eksi 2 uymayan iş, eksi 10 gece düzeltmesi; moralin onarımı tanımsız | Risk orta | D (atama koşulu); ekip PRD dışı |
| Dayatılan şans olmasın | R14 §8 madde 5 | Bütçe kesintisi | Sadeleşiyor | C |
| Zorluğun iki ucu | R14 §8 madde 6 | Servis kalkıyor, ×1,5 öneri | Risk | C; zorluk PRD dışı |
| Şişkinlik olmasın | R14 §8 madde 7 | EA takımı, 13 sektör, bütçe kâğıdı | Kesiliyor | D, Q, C |
| Akış kesilmesin | R14 §8 madde 8 | Haftada 1,72 durma | Risk | C, D; saatin sürmesi PRD dışı |
| Çökme ve kayıt kaybı olmasın | R14 §8 madde 9 | Üç fazda üç şema göçü | Risk | Her PRD'de göç kapısı |
| Yapay zekâ şüphesi | R14 §8 madde 10 | Yazar ajanı, paket aset, açıklama kararı yok | Bilinmiyor | PRD dışı |

## 6. PRD dışı riskler (Erdem'e ayrıca)
Q, C ve D bunları çözmez ama %90 için şarttır. Sıra ağırlığa göredir.
1. **İnsan oturumu yok.** Bu belgedeki her oynanış kapısı bot sayısıdır. 7 Ekim'den beri 14. haftanın ötesini oynayan
   insan yok [kanıtsız, R15 §1.5]. Öneri: Q başlamadan 30 dakikalık bir oturum, hafta 1 ile 20 (R15 §9 madde 1).
2. **Doruk formalite.** Series A kapıdan imzaya 1 ile 5 hafta, masada 0 zorlama, ret sonrası 40 hafta boş; "Üçüncüde yol
   biter" metni yanlış (`strings.csv:831`, `endings_system.gd:155-175`), ret `faced_series_a` yazmıyor
   (`vc_pitch_system.gd:535-548`) (R15 §5.4).
3. **Orta oyunun hedefi.** Seed sonrası TopBar "Sıradaki" boş (`cheque_read.gd:15-23`); 40 hafta adlı hedef yalnız Finans'ta
   (R15 §8.1). Öneri: Series A'nın MRR barı ve kalan yolu aynı satırda.
4. **Satış görüşmesi çözülmüş.** İlk açık cevap %98 kazanıyor (R15 §8.3). İmza kapısı bir kısmını çözer; görüşmenin kendi
   zorluğu ayrı iş.
5. **Saat her karardan sonra elle başlıyor** (`time_manager.gd:358-361`). Öneri: ayar "karar verince saat sürsün",
   varsayılan açık. İstifa kartı tek düğmeyle saati tutuyor (koşuda 9,2): not olmalı (R15 §8.4).
6. **Kayıp ekranı.** "Ne öldürdü" cümlesi ve tek tık TEKRAR DENE yok; `ending_scene.gd` 7 Ekim'den beri değişmedi
   (R15 §5.4). R13 Ders 1.
7. **Zorluk kadranı** yalnız başlangıç nakdi (`founder_constants.gd:59,188`); R13 Ders 4 en az üç basamak ve rahat mod ister.
8. **Etkisiz yüzeyler.** Huylar (`founder_constants.gd:41-43`), kilitli iki köken, okuyucusuz dört Ar-Ge düğümü
   (`research_seam.gd:29,35,40,48`). Ofis C'nin kirası ve masa tavanıyla kısmen çözülür. İlk dakikada "seçim etkisiz"
   sinyali verir (R15 §8.8).
9. **B2C orta oyunu.** Fiyat kolu E'ye kadar yok (`sprint_bridges.gd:136-139`), satış sayfası salt okunur; C yalnız sunucu
   kolu ekler (R15 §8.6).
10. **Vitrin.** Ses tek MP3, SFX yok (`audio_manager.gd:41`); gazete sanatı yer tutucu (`ending_scene.gd:171`);
    `steam_appid` ve WISHLIST adresi yok (`ending_scene.gd:34`); 720p'de 9 px yazı (R15 §5.5).
11. **Yapay zekâ şüphesi ve Steam açıklaması.** İlk ekran, mağaza görseli ve açıklama uyumu; olay metninde yazar ajanı ve
    paket asetler. Açıklama lansmandan önce yazılmalı (R14 §6.3, §8 madde 10). Karar Erdem'in.
12. **Tam oyunun ilk 10 saati.** Olumsuz yorumların %46 ile 61'i ilk 10 saatte (R14 §2); demo 60 ile 90 dakika. Tam oyun ve
    EA için ayrı bir kapı ve kâğıt havuzunun tekrar ölçümü (40 kâğıt, koşuda en çok 3 kez).
13. **Rakip ve pazar şoku, kısa arklar.** Ark sayısı artmadı (R15 §5.3). Orta oyunun anlatılabilir anı (R13 Ders 3).
