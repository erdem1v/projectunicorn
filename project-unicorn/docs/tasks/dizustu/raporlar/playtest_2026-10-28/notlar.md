# Project Unicorn — OLAYLAR playtest (B2B / ERP, kurucu tek başına)

- Başlangıç: 2026-10-28 20:58 (gerçek saat). Hedef: 30. hafta ya da 2 saat (en geç 22:58).
- Oyun kopyası: scratchpad/play/project-unicorn, 1920×1080 pencere, `--menu --lang=tr`.
- Etiketler: [GÖRÜŞ] = oyuncu olarak kendi izlenimim; geri kalanı ekranda gördüğüm.

## Kart / karar kağıdı günlüğü
(her kart: hafta + oyun tarihi | başlık | gönderen | gövde | seçenekler + çipler | seçimim | neden | görülen etki | Türkçe | kafa karıştıran)

## Teknik not (sürüş)
- Pencere bu Mac'te 1920×1080 değil: kök Window boyutu 2880×1800 (retina), tuval (canvas) 1920×1200. inject-mouse-* koordinatları PENCERE pikseli: tuval × 1.5 = 960×600 ekran görüntüsü × 3.
- Tıklama protokolü: motion+press aynı anda, release ayrı çağrıda. press ile release paralel gönderilince tıklama tutmuyor.
- Ad alanına inject-key ile yazı yazılamıyor (unicode yok) → ad boş, "Kurucu" kullanıldı.

## Onboarding (20:59–)
- Adım 1/3 Karakter: portre 4 (kahverengi saçlı, lacivert kapüşonlu). Ad boş → "Kurucu". Zorluk NORMAL ($10.000). "Frank'le rehberli başla" kapalı ("Rehber yazılıyor." notu var).
- Adım 2/3 Köken: Sıfırdan (tek açık köken; Mirasyedi ve Kurumsal Firari "TAM SÜRÜMDE" kilitli). Pozitif: Ağ Kurucu (B2B satışta tanıdık işe yarar diye). Negatif yok.
  Yetenek (6 puan, her + 2 kademe): Ürün 2, Yazılım 4, Satış 4, Müşteri Başarısı 2. Kare: kareler/01_onboarding_koken_yetenek.png
  [GÖRÜŞ] "Satış: 2 yıldızlı hesaplara uzanırsın · adayı okursun" satırı seviye artınca değişiyor, güzel geri bildirim. Her + tıklamasının 2 kademe artırması ilk bakışta şaşırtıcı (puan 1 düşüyor, değer 2 artıyor) ama sağ panelde anlaşılıyor.
- Adım 3/3 Şirket: ad "Defterix" (inject-key yazamadığı için LineEdit.insert_text_at_caret ile girildi), logo: sarı altıgen "D". Logolar ad girildikten sonra ilk tıklamada baş harfle yeniden üretildi.
  [GÖRÜŞ] Onboarding'de ürün tipi / B2B-B2C seçimi YOK; oyun içinde "Sıradaki: Ürün tipini seç" olarak geliyor.

## Kartlar
### K1 — H1 (Ocak 2012) 08:00 · "İlk sabah" · MENTOR etiketli Mesaj, gönderen "Kurucu · Kendine not"
- Gövde: istifadan sonraki ilk sabah; Frank (eski şirketten danışman) arıyor, "fikir mi çalışan bir şey mi?", "ilk sürümü sen yazacaksın".
- Seçenek: tek düğme "Hadi başlayalım" (çip yok). Karar değil, anlatı.
- Türkçe doğal, akıcı. [GÖRÜŞ] Gönderen "Kurucu / Kendine not" ama konuşan Frank: başlıkta MENTOR rozeti var, kişi kartında Kurucu'nun portresi. Hafif kafa karıştırıcı (mentor mesajı mı, kendime not mu?).
- Kare: kareler/02_h1_ilk_sabah_mentor.png
- H1 08:00 Ürün sekmesi "Yolunu seç": B2C (Not & Bilgi Aracı, Video Klip Aracı) / B2B (ERP: "Ön muhasebe · stok · fatura tek defterde"). ERP seçildi. Ürün adı alanı da inject-key ile yazılamıyor; insert_text_at_caret metni koyuyor ama "Onayla ve başlat" açılmıyor (text_changed sinyali gelmiyor) → emit_signal("text_changed") ile açıldı. Ürün adı: "Defterix Fatura".
- Sprint ekranı açıldı (kare: kareler/03_h1_ilk_sprint_plani.png): SPRINT 1, 1. ÇEYREK, v1.0 0/3 kart ≈ Sprint 3. Hazır kart: "Kasa Hareketleri" (Çekirdek) 2 tasarım + 10 geliştirme + 3 test = 15. Kapasite: Tasarım 2/2, Geliştirme 10/15, Test 3/3. Sağda SPRINT 2 önizleme: "Elle Giriş" 15. Toast: "Frank'in çeki · 1/5 Sıradaki: İlk sprinti başlat".

## Sprint ekranı gözlemleri
- S1: Hazır gelen kartın yanında 5 geliştirme boştu (10/15). Çekirdek modülünü açınca kartlar: Kasa Hareketleri 15 ✓, Elle Giriş 15 (S2 rozeti), Stok Sayacı 15, Ön Muhasebe 15, "5 kullanıcıyla görüş" 5 (gri çubuk = araştırma). Görüşmeyi ekleyince Geliştirme kapasitesinin paydası 15→10'a düştü (kurucunun zamanı bölünüyor). [GÖRÜŞ] Bunun nedeni ekranda yazmıyor; "kapasite neden azaldı?" diye durdum.
- H3 00:00 Sürüm notu (Sprint 1 sonu): "v1.0 = 3 Çekirdek kartı · 1/3 bitti · tahmin Sprint 3 sonu (Hafta 6)". HIZ 20/20. SONUÇ: "Beklenen: Görünür bir değişiklik beklenmiyor". KENDİ NOTUN: "Çekirdek sırada." [GÖRÜŞ] 5 kullanıcıyla görüşme bitti ama ne öğrendiğim hiçbir yerde söylenmedi; araştırmanın getirisini göremedim.
- S2 planı: "Öneriyi uygula" düğmesi çıktı; ne yapacağı yazmıyor. Tıklayınca S2'ye değil SPRINT 3 önizlemesine "Stok Sayacı"nı koydu ve düğme kayboldu. [GÖRÜŞ] Öneri metni/ipucu olmadan basmak kumar gibi.
- "İlk Kullanım ve Erişim" modülünde tek kart var: "5 kullanıcıyla görüş" (5). Her modülün kilidi bir görüşme kartıyla açılıyor gibi. S2'ye ekledim (Elle Giriş + İK görüşmesi).
- Sprint başlatınca saat DURDU'da kalıyor; Boşluk ile sürdürmek gerekiyor.
- Satış sekmesi v1.0 öncesi: "Canlı B2B ürün yok. v1.0 yayınlanınca adaylar gelir." + "Ürün'e git" düğmesi. Net.
- H5 00:00 Sürüm notu (Sprint 2 sonu): v1.0 2/3 bitti, "v1.0 için 1 kart kaldı". SONUÇ: "Beklenen: Çekirdek Zayıf olmalı". Bu sürüm notundan sonra modül listesinden "İlk Kullanım ve Erişim" KAYBOLDU (yalnız Çekirdek, Entegrasyonlar, Güven & Ölçek kaldı). [GÖRÜŞ] Görüşmesini yaptığım modül neden listeden çıktı, anlamadım; açıklama yok.
- S3: Stok Sayacı (5 tasarım/7 geliştirme/3 test). Entegrasyonlar modülü: "Tekil Bağlantı" 15 + "5 kullanıcıyla görüş" 5 → görüşmeyi ekledim (haber bandı "entegrasyon vaadi satış kapatıyor" diyor). "Öneriyi uygula" yine S4'e "Ön Muhasebe" koydu.

### K2 — H6 (Şubat 2012) 10:00 · "Alan adı" · GÜNDEM · Kağıt · gönderen "Kurucu · Kendine not" · süre "Bu hafta son"
- Gövde: "Ürün için istediğin kısa alan adı, onu satmaya hazır bir aracının elinde. Araya bir kelime daha alan uzun adres ise boşta."
- Seçenekler: "Kısa adresi satın al" [Nakit -$900] · "Uzun adresle devam et" [Marka -2] · "Kenara koy (ESC)".
- Seçimim: Uzun adresle devam et. Neden: kasa $10.000, gelir 0; B2B ERP'de müşteri toplantıyla geliyor, alan adının kısa olması 900$ (kasanın %9'u) etmez.
- Görülen etki: üst bardaki MARKA 50 → 48. Kasa değişmedi.
- Türkçe doğal. [GÖRÜŞ] Kağıt H6 10:00'da geldi ama oyun DURMADI; ben H7 08:00'de OLAYLAR rozetini (1) görünce fark ettim. "Cevapla"ya basınca "Seçim kalıcıdır · Oyun duraklatıldı" diyor ve üst barda "CEVAP BEKLİYOR · Kurucu" çıkıyor. Kağıdın gelişi daha görünür olabilir.
- Hata adayı: kağıt açıkken sol altta küre düğmesinin yanında serif (fallback) yazı tipinde küçük "Cevap bekliyor" yazısı beliriyor (kare 04). Yazı tipi tutarsız.
- Kare: kareler/04_h7_alan_adi_kagit.png
- Liste (H7): H1 İlk sabah [MENTOR], H3 09:00 "Tek kişilik şirket" [GÜNDEM] (önizleme: "3. hafta. Şirketteki her iş hâlâ sana düşüyor: kod da, ta…"), H4 10:00 "Çalışan parçalar" [ÜRÜN] ("Ürünün bir parçası artık baştan sona çalışıyor…"), H6 Alan adı [GÜNDEM, Kağıt]. Hepsinin göndereni "Kurucu".

- H7 08:00 Sürüm notu Sprint 3 sonu: "v1.0 hazır — Çekirdek kartları bitti. Yayınlarsan kullanıcılar bu hafta gelmeye başlar. Bir sprint daha beklersen ürün sonraki kapanışa kadar kapalı kalır." [Bir sprint daha] / [Yayınla]. → Yayınla (burn 0 olsa da satış ancak v1.0 canlıyken açılıyor). Sonuç: v1.0 CANLI, "Ar-Ge açıldı · Ar-Ge'ye git", toast "Frank'in çeki · 3/5 Sıradaki: İlk ödeyen müşteri". "İlk Kullanım ve Erişim" modülü listeye geri döndü.
- H8 08:30 Satış: Boru hattında 3 aday: Erciyes Arsa ★, Tuna Arsa ★, Borealis Arsa ★ — üçünün de açıklaması aynı: "Hızlı konuşur, düşük rakam ister." Süre 1 hafta, "Temsilci yok". Düğmeler: Ayır / Temsilciye ver (pasif) / Görüşmeye git. Üst bar: KASA $9.972, NET -$120/ay, RUNWAY 83 ay, BURN $120/ay. [GÖRÜŞ] Üç aday da "… Arsa" ve aynı cümle: kopya gibi duruyor, ayırt edemedim.

### K3 — H8 (Şubat 2012) 09:00 · "Eski bir dost" · MENTOR · Karar · gönderen Frank Köseoğlu (Operating Partner) → Kime: Kurucu · Defterix
- Gövde: "Ürün yayında. Telefon çalıyor, arayan Frank. 'Eski bir dostuma senin ürününden bahsettim… Bir görüşme ayarladım. Hazırlıklı git.' Kapatıyor."
- Seçenek: tek düğme "Satış'a git" [Yeni aday] [Seni oraya götürür]. Oyun bu kez kendiliğinden durdu ("Seçim kalıcıdır · Oyun duraklatıldı"); üst barda "CEVAP BEKLİYOR · Frank Köseoğlu".
- Gövde serif/mektup yazı tipinde (tasarım gereği gibi). Türkçe doğal.
- Kare: kareler/05_h8_eski_bir_dost_frank.png

## Satış görüşmesi 1 — H8 09:00 · Bakırçay Tekstil ★★ (FRANK'İN TANIŞTIRDIĞI) · "Ölçülü bir alıcı. Acele etmez, her rakamı tartar."
- Akış: Satış > Görüşmeye git → ofiste kurucunun üstünde telefon simgesi → tık → "İstenen görüşme · 09:00 Bilge Polat, Satın Alma Sorumlusu … görüşmeye hazır." [Kabul et]/[Ertele] → yürüme ("Yolu geçmek için tıkla ya da Esc'ye bas") → toplantı odası.
- Masada Bilge Polat (Satın Alma) + Selin Güneş (Ekip Yöneticisi). Tutum SOĞUK, İkna %14. İlk karede büyük portre dairesi bir an boş göründü, sonra doldu; alt satırda "Bilge Polat — Aç" diye yarım cümle bir an göründü (yazı animasyonu).
- Bilge: "Açık konuşayım, Entegrasyonlar tarafınız bize yetmiyor… programlarımızla konuşabiliyor mu?" Anlatıcı: "Kimse acele etmiyor. Bu iyiye de kötüye de gidebilir."
  - Kilitli: "Entegrasyonlar tarafı hazır. Size gösterebilirim." (Entegrasyonlar bunu henüz desteklemiyor.)
  - [1] "Entegrasyonlar tarafı henüz eksik. Bugünkü hâlini olduğu gibi gösteririm." ← seçtim (dürüst, tek açık seçenek). İkna %14→%23.
- Selin: "Veri nerede duruyor? Altyapıyı kimden alıyorsunuz?" [1] "Veri bir bulut sağlayıcısında duruyor. Kurulumu gösterebilirim." ← seçtim (doğru ve güven veriyor) · [2] "Henüz kurumsal bulutta değiliz…" · [3] "Teklife geç" (Tehlikeli). → TEMKİNLİ, İkna %31.
- Bilge: "Geçiş ne kadar sürer? İki kere sistem değiştirdik, ikisi de uzadı."
  - Kilitli: "Ürün kolay öğreniliyor…" (İlk kullanım bunu henüz desteklemiyor.)
  - [1] "Verinizi görmeden tarih vermek istemem." (zar simgesi) ← seçtim
  - Kilitli: "İmzalarsanız ihtiyacınız olan kademeyi bir sonraki sprintimize yazarım." (Bir sonraki sprintte buna yer yok.) [GÖRÜŞ] S5 boş (0/20) görünürken "yer yok" demesi kafa karıştırdı.
  - [2] "Teklife geç" (Tehlikeli). → ILIK, İkna %40. Bilge: "Bu kadar soru yeter. Rakamı konuşalım."
- Rakam: kaydırıcı $30–$70 (üst uç kırmızı), koltuk $50: "25 koltuk × $50 = $1.250 MRR · Kapasite 25/50", SABIR 3 kutu. Teklif $50 → karşı $48 → Kabul et.
- Sonuç: "Şartlarda anlaşıldı · ANLAŞILDI — 25 koltuk × $48 = $1.200 MRR · İmza 3 hafta sonra · İlişki: Bilge Polat soğuk → ılık". Kareler: kareler/06_h8_satis_gorusmesi_bakircay.png, kareler/07_h8_bakircay_anlasma.png
- [GÖRÜŞ] Görüşme çok iyi hissettiriyor: kilitli seçenekler ürünün eksiklerini (Entegrasyon, İlk Kullanım) doğrudan gösteriyor; sprint ekranıyla bağ net. Türkçe doğal.
- H8 sonrası Satış: Bakırçay "Sen · Teklif aşaması · 0/3 hafta", düğmeler pasif, "Bu şirketle anlaşma sürüyor." Erciyes Arsa ★ ile Görüşmeye git'e bastım → hiçbir şey olmadı (pano kapandı, ofiste telefon simgesi yok, SIRADAKİ yine "İlk ödeyen müşteri"). [GÖRÜŞ] Tıklanıp sessizce hiçbir şey yapmayan düğme; muhtemelen kurucu aynı anda tek anlaşma yürütüyor ama bu söylenmiyor.
- H8 15:50 kurucu karakterine tıklayınca kişi kartı: Şu an "Yapımda görev alıyor", Yetenekler Ürün 2/Tasarım 0/Yazılım 4/Test 0/Satış 4/Müşteri İlişkileri 2/Liderlik 0/Karizma 0, Denetim %100, Verim "%100 → %86 Günde 8 saat · %14".
- H9 00:00 Sürüm notu Sprint 4 sonu: v1.1 CANLI (Ön Muhasebe). HIZ 15/20 ("Ekip 20 puanın 15 tanesini bitirdi" — görüşmeye gittiğim saatler düşmüş olabilir). SONUÇ "Beklenen: Çekirdek Zayıf olmalı".
- S5 planı (sprint ekranı takıldığım yer): Modül panelindeki "+" kartı sprinte EKLEMİYOR, yalnızca orta listede "EKLENEBİLİR" satırını vurguluyor; ikinci kez ortadaki satırın "+"sına basmak gerekiyor. Önceki sprintlerde de modül "+"sı bazen doğrudan ekledi (S1'de 5 kullanıcıyla görüş), bazen eklemedi. [GÖRÜŞ] İki ayrı "+" kafa karıştırıcı. Boş sprintte "15 efor daha sığar" ipucu iyi.
- S5: Tekil Bağlantı (Entegrasyonlar) 2/10/3 — Bakırçay'ın "entegrasyon yetmiyor" itirazına cevap. Kapasite Geliştirme 10/11.

## Hafta 9–11
- H11 08:00 Sürüm notu Sprint 5 sonu: v1.2 CANLI (Tekil Bağlantı). HIZ 15/16. SONUÇ "Beklenen: Entegrasyonlar Yeterli olmalı". BASIN: TeknoGündem "Defterix Fatura Entegrasyonlar tarafında toparlandı" (aynı satır haber bandına da düştü — güzel bağ). Kendi notun: "Güven sırada."
- Bakırçay imzaladı: MRR $1,2K, NET +$1,1K/ay. SIRADAKİ hedef "Aylık gelir $2,5K".
- S6: "İlk Kullanım ve Erişim" modülünde yine yalnız "5 kullanıcıyla görüş" var (S2'de bu görüşmeyi yapmıştım!). Tekrar ekledim + Güven & Ölçek > Otomatik Kayıt (2/8/5). Güven modülü: Otomatik Kayıt 15, Hesap & Oturum 15, 5 kullanıcıyla görüş 5. [GÖRÜŞ] S2'de yaptığım İK görüşmesi kartları açmamış görünüyor; aynı görüşme tekrar istenince "ilki boşa mı gitti?" diye düşündüm.
- Görüşme kartını ekleyince "EKLENEBİLİR" listesi kayboldu ve "SPRINT ERKEN BİTER" uyarısı çıktı; Otomatik Kayıt'ı bulmak için modül paneline geri dönmek gerekti.
- Sol menüde bir panel açıkken başka sekmeye tek tık panelı KAPATIYOR, açmıyor; ikinci tık açıyor (Ürün→Olaylar, Olaylar→Satış hep iki tık). [GÖRÜŞ] Her geçişte bir boş tık.
- Olaylar H11: yeni bir şey yok (H8'den beri sessiz). Liste "Alan adı"nı "Hafta 7 · 08:00" altında gösteriyor; kartın kendisi "Hafta 6 · Şubat 2012 · 10:00" diyor (liste cevap zamanına göre, kart geliş zamanına göre) — tutarsız.
- Ledger H11: cash 10.168, mrr 1.200, customers_active 1, employees 0, brand 48, product_version 3.
- Satış H11: Bakırçay ONBOARDING, memnuniyet 52, "$1,2K/ay · 25 koltuk · yeni müşteri · $48/koltuk", Müşteri temsilcisi: atanmadı [Değiştir]. Yeni adaylar: Sultanahmet Konfeksiyon ★★ (Ölçülü), Çukurova Poliçe ★ (Hızlı konuşur), Lumen Tekstil ★ (Ölçülü), Gediz Konfeksiyon ★ (Ölçülü). Kişilik cümleleri yalnız iki kalıp.

### K4 — H11 (Mart 2012) 11:00 · "İlk ödeme" · MENTOR · Karar · gönderen Frank Köseoğlu (Operating Partner) → Kurucu · Defterix
- Gövde: "Frank'ten mesaj. 'İlk ödemen gelmiş. Ben ilk satışımı yaptığımda çerçevelemiştim o banknotu. Artık işler ciddi, daha çok müşteri, daha çok iş.'"
- Seçenek: tek düğme "Tamam" [Yeni evre başlar]. Seçtim (tek seçenek). Oyun kendiliğinden durdu, "CEVAP BEKLİYOR · Frank Köseoğlu".
- Görülen etki: sol üst evre etiketi BOOTSTRAP → TRACTION oldu. Başka değişiklik görmedim.
- Türkçe doğal. [GÖRÜŞ] "Karar" rozeti var ama karar yok; tek düğmeli mektuplar "Karar" yerine "Mesaj" olarak etiketlenebilir. Tamam'a basınca ekran ~1 sn tepkisiz göründü, sonra "CEVAPLANDI H11" damgası geldi.
- Satış H11: Sultanahmet Konfeksiyon ★★ için "Görüşmeye git"e bastım; pano kapandı, kurucu uyuyor (saat 08:00), SIRADAKİ değişmedi — görüşme sırada mı belli değil.

### K5 — H12 (Mart 2012) 09:00 · "Sunucu faturası iki katına çıktı" · ÜRÜN · Kağıt · gönderen "Kurucu · Kendine not" · süre "Bu hafta son"
- Gövde: "Sunucu faturan bu ay iki katına çıktı. Sebebi yazdığın Otomatik Kayıt kodu: her açılışta aynı veriyi baştan çekiyor." ({seam:urun.decision_card} doğru çözüldü → "Otomatik Kayıt", sprintteki kartın adı.)
- Seçenekler: "Kodu düzelt" [Otomatik Kayıt +5 puan] · "Faturayı öde, kodu sonraki sprintte düzelt" [Nakit -$120] [Sonraki sprinte 10 puanlık iş kalır] · Kenara koy (ESC).
- Seçimim: Kodu düzelt. Neden: $120 küçük ama ikinci seçenek 10 puanlık işi bir sonraki sprinte itiyor; tek başımayım, kapasite nakitten değerli; sprint zaten %50'de, 5 puan bu sprintte erimez ama sorunu kökten kapatır.
- Görülen etki: hemen değişiklik görmedim (kasa $10.420 aynı). [Seçimden önce panelde gördüğüm, bkz. aşağıdaki hata] 
- Türkçe doğal, net. Çip "Otomatik Kayıt +5 puan" anlaşılır.
- HATA ADAYI (önemli): Kağıt geldiğinde (H12 09:00, ben 16:00'da fark ettim) Ürün > Sprint ekranında, ben henüz karar VERMEMİŞKEN, Otomatik Kayıt'a ait +5/+5 efor turuncu çizgili "DEVREDEN" olarak Sprint 7'ye iki kez yazılmış görünüyordu: Geliştirme 5/10 "+5", Test 5/0 "+5", sağda "DEVREDEN: Otomatik Kayıt 5 · Otomatik Kayıt 5", Sprint 7 önizlemesi Geliştirme 5/20, Test 5/0. Yani cevapsız kağıdın olası sonucu (ya da önizleme) sprint planına önceden yansıyor; kartın üzerinde de "?" işaretli kurucu simgesi var. Kare: kareler/09_h12_sprint_devreden_onizleme.png. [GÖRÜŞ] Bu bir önizleme ise etiket yok; oyuncu "karar vermeden iş mi kaydı?" diye şaşırır. Test kapasitesi "5/0" garip (payda 0).
- Kağıt akışı: "Cevapla" ilk tıklamada açılmadı (yalnız toast "Sunucu faturası…" kayboldu); ancak Olaylar panelini kapatıp yeniden açınca ikinci "Cevapla" çalıştı. Seçeneğe tıklayınca satır genişleyip "Vazgeç / Seç" çıkıyor (iki adım onay) — iyi.
- Kare: kareler/08_h12_sunucu_faturasi_kagit.png
- K5 sonrası sprint: Otomatik Kayıt 15→20 puan; Test 7/2 "+5"; Sprint 7'ye "DEVREDEN Otomatik Kayıt 5" (artık tek satır). Yani "Kodu düzelt" de işi kısmen sonraki sprinte itiyor; iki seçeneğin farkı küçülüyor ($120 + 10 puan vs 5 puan). Karar öncesi gösterilen iki satırlık DEVREDEN, karar sonrası teke indi → karar öncesi ekran iki seçeneğin toplamını birden göstermiş olabilir.
- H12 18:00 F5 hızlı kayıt.

## Hafta 13
- H13 08:00 Sürüm notu Sprint 6 sonu: "Bu sprint sürüm çıkmadı". Çıkanlar: 5 kullanıcıyla görüş ✓5. DEVREDEN: Otomatik Kayıt → Sprint 7. HIZ 20/20. Kendi notun: "Otomatik Kayıt bir sprint daha ister." İK görüşmesi bitince "İlk Kullanım ve Erişim" modülü listeden YİNE kayboldu (S2'deki gibi). Görüşmenin ne kazandırdığı yine söylenmedi.
- S7: Otomatik Kayıt (devreden 5, test) + Hesap & Oturum 15 (2/8/5). Kurucu rozeti test şeridinde "0★" (Test yeteneği 0) — kurucunun test yapamadığı burada görünüyor.
- Ekip > İşe alım (Atlas Recruitment): roller Ürün Yöneticisi, Tasarımcı, Yazılım Mühendisi, Test Mühendisi, Satış Temsilcisi, Müşteri Temsilcisi; Pazarlama & İK "Tam sürümde gelecek". Seviye: Junior aylık $3.000–4.500 · komisyon $1.500–2.250; Orta $4.500–9.000 · $2.250–4.500; Kıdemli $9.000–15.000 · $4.500–7.500. "Adaylar bir hafta içinde gelir · Arama ücretsiz · komisyon işe alımda ödenir".
  - Karar: Junior Yazılım Mühendisi'ni seçtim ama Vazgeç'e bastım. Neden: MRR $1,2K, kasa $10,6K; junior ~$3,5K/ay + ~$1,8K komisyon → net ~-$2,4K/ay, runway ~4 aya iner. Önce 1–2 müşteri daha kapatıp MRR'yi ~$2,5K'ya çıkarmak istiyorum. [GÖRÜŞ] En ucuz çalışan bile tek müşterinin 3 katı; B2B'de ilk işe alım eşiği yüksek hissettiriyor.

## Satış görüşmesi 2 — H13 08:00 · Sultanahmet Üretim ★★ ("Ölçülü bir alıcı…")
- Satış H13: adaylar Çukurova Üretim ★★★ ("Yazılı bir hizmet sözü istiyor."), Altınyol Teknoloji ★★★ ("Teknik taraf soruyor… Kapalı bir kademeyi şart koşuyor."), Sultanahmet Üretim ★★, Zeytin Üretim ★★; ★★★ olanlarda "Bu masa liginin üstünde." Akış 4,4/hafta. Fiyat duruşu: Rekabetçi / Standart (seçili) / Premium. Bakırçay memnuniyet 44 (52'den düştü), ONBOARDING; "Müşteri temsilcisi: atanmadı [Değiştir]" → açılır: "Kurucu (kendin tutayım) · zaten sorumlu 1/6" — tıklayınca hiçbir şey değişmedi (zaten sorumluysa neden "atanmadı" yazıyor?). [GÖRÜŞ] Tutarsız etiket.
- Masada Zeynep Güneş (Satın Alma) + Baran Aksoy (Ekip Yöneticisi). TEMKİNLİ %29.
- Zeynep: "Güven tarafınız bize yetmiyor." + "Geçiş ne kadar sürer?" → seçenekler: [1] "Ürün kolay öğreniliyor…" (bu kez AÇIK; İK görüşmesi sonrası) ← seçtim · [2] "Verinizi görmeden tarih vermek istemem." · kilitli "İmzalarsanız … sonraki sprintimize yazarım." (yine "Bir sonraki sprintte buna yer yok"). → %37.
- Baran: "Veri nerede duruyor?" [1] bulut sağlayıcı ← seçtim · [2] kurumsal bulutta değiliz · [3] "Aynı soruyu soran bir müşterimiz var. Onunla konuşun." (referans) · [4] Teklife geç (Tehlikeli). → ILIK %45.
- Zeynep: "programlarımızla konuşabiliyor mu?" [1] "Entegrasyonlar tarafı hazır." (zar) ← seçtim (S5'te Tekil Bağlantı'yı çıkardım, artık açık) · [2] "henüz eksik" (zar) · [3] Teklife geç (Riskli). → %53, "Bu kadar soru yeter."
- Rakam: 15 koltuk, $50 → karşı $44; $47 → yine $44 (SABIR 3→1). $44 kabul. "ANLAŞILDI 15 koltuk × $44 = $660 MRR · İmza 3 hafta sonra · İlişki: Zeynep Güneş temkinli → ılık".
- [GÖRÜŞ] Sprintte yaptığım iş (Tekil Bağlantı, İK görüşmesi) görüşmede seçenek açtı: oyunun en tatmin edici bağı. "Tehlikeli"/"Riskli" etiketleri net. Sabır kutuları sarıya dönünce uyarı iyi.

### R1 — H14 (Nisan 2012) 10:00 · "1. Çeyrek 2012" · GÜNDEM · Rapor · gönderen "Muhasebe · Defterix" → Kime: Kurucu · Defterix
- Gövde: "Hafta 1–13 · Traction". MRR $0 → $1,2K (+$1,2K) · Kasa $10K → $11K (+$672) · Ekip · kurucu dahil 1 → 1 (±0) · Marka 50 → 48 (-2). ÇEYREĞİN OLAYI: "Yeni faza geçildi: Traction". İmza "Muhasebe · Defterix". "Otomatik özet · her çeyrek sonu". Tek düğme: Devam et.
- Karar değil (rapor). Oyun kendiliğinden durdu, Olaylar paneli kendiliğinden açıldı. Türkçe doğal. Gönderen ilk kez "Kurucu/Frank" dışında biri: "Muhasebe".
- [GÖRÜŞ] Kasa satırı $10K → $11K ama ekranda $10.924 var; "+$672" farkı yuvarlanmış başlıkla çelişiyor gibi (10.000+672 = 10.672 ≠ 11K). Küçük ama göze batıyor.

### K6 — H14 (Nisan 2012) 12:00 geldi · "Çeyrek bülteni: işletmeler yazılımı nasıl seçiyor" · GÜNDEM · Kağıt · gönderen "Sektör Telgrafı" (ST) → Kime: Kurucu · Defterix · süre "Bu hafta son"
- Gövde: "Bir ticaret odası altı yüz üyesine yazılım seçerken neye baktıklarını sormuş. İlk sırada kurulumda yanlarında olunması var, fiyat üçüncü sırada."
- Seçenekleri GÖREMEDİM: H15 00:00'da "Cevapla"ya bastım → toast "Bu kâğıdın konusu kalmadı" ve kâğıt listeden SİLİNDİ (TÜMÜ 9 → 8, BEKLEYEN 1 → 0). [Kart dosyasından: tek seçenek "Bu çeyrek satış görüşmelerinde kurulum desteğine ağırlık veririm" (pitch_focus onboarding 13 hafta), expires_weeks 2.]
- HATA (önemli): Kâğıdın koşulu `time.quarter_start == true` (yalnız çeyreğin ilk günü doğru). Kâğıt 2 hafta süreli ve "Bu hafta son" diye bekliyor, ama ertesi gün açılınca koşul yeniden denetleniyor ve düşüyor. Yani oyuncu bu kâğıdı ancak geldiği gün açarsa cevaplayabilir; ben H14'te Q1 raporunu kapattıktan sonra hiç durmadan H15'e geçti. Kareler: kareler/10_h15_ceyrek_bulteni_kagit.png (kâğıt duruyor, Cevapla düğmesi), kareler/11_h15_kagidin_konusu_kalmadi_BUG.png (toast + kâğıt yok).
- Ayrıca üst bar SIRADAKİ "Çeyrek bülteni: i… · bu hafta son" — başlık "i…" ile kesik (kesilme noktası çok erken, okunmuyor).
- [GÖRÜŞ] Oyuncu açısından: bir kâğıt elimden alındı ve neden alındığı anlaşılmadı. Gövde "fiyat üçüncü sırada" diyerek kurulum desteğine yönlendiriyordu — tam da İK görüşmesi yaptığım için almak istediğim bir karardı.
- Not: H12'deki "Sunucu faturası" kâğıdında da ilk "Cevapla" tıklaması hiçbir şey yapmamıştı (toast'u o an göremedim); aynı yeniden-denetim mekanizması olabilir ama o kâğıt ikinci denemede açıldı.

## Hafta 15–16 (sprint ekranı)
- H15 S8 planı: Çekirdek'te yeni kartlar çıktı: Nakit Akış Tablosu 25, Tablo İçe Aktarma 25, 5 kullanıcıyla görüş 5. Entegrasyon görüşmesi sprintteyken 25'lik kartların "+"sına basmak HİÇBİR ŞEY yapmadı (ne EKLENEBİLİR satırı ne uyarı). Kapasite şeridinde Tasarım/Geliştirme kesikli (kapasite yok) görünüyordu; neden eklenemediği yazmıyor. [GÖRÜŞ] Sessiz no-op; "bu sprintte yer yok / görüşme kurucuyu dolduruyor" gibi bir ipucu gerekli.
- H16 00:00 Sürüm notu Sprint 8 sonu: v1.4 CANLI (Hesap & Oturum 15 + Entegrasyon görüşmesi 5). HIZ 7/20 ("Ekip 20 puanın 7 tanesini bitirdi" — sprint erken bitti diye mi düşük?). SONUÇ "Beklenen: Güven Yeterli olmalı". BASIN Sektör Telgrafı "Defterix Fatura Güven tarafında toparlandı". Entegrasyonlar modülü görüşmeden sonra yine listeden kalktı.
- S9: Tablo İçe Aktarma (4 tasarım / 16 geliştirme / 5 test). Test 5/0 "+5" → testin tamamı Sprint 10'a DEVREDEN. Kurucunun Test yeteneği 0 → her kartın testi bir sonraki sprinte kayıyor gibi. [GÖRÜŞ] Test mühendisi işe almak için güçlü bir sinyal; ama ekranda "test kapasiten 0 çünkü…" diye açıklanmıyor.
- MRR $1,9K (Sultanahmet imzaladı), NET +$1,7K/ay, kasa $11.582.
- H16 00:00 DESTEK "1 açık hata" (sağ üst ürün kutusu, ok simgeli) → tıklayınca Ürün > Sprint açıldı, Güven & Ölçek altında "Güvenlik & Yetki düzeltmesi · 1 hata · 2" kartı. Güzel bağ; ama sprint zaten başladığı için "+" pasif — hatayı ancak 2 hafta sonra alabiliyorum. [GÖRÜŞ] Hata sprint başladıktan hemen sonra gelince oyuncu çaresiz kalıyor; ipucu yok.
- H16 Satış: Bakırçay SAĞLIKLI (memnuniyet 44), Sultanahmet ONBOARDING 52; ORT. MEMNUNİYET %48. Yeni adaylar Efes Dokuma ★★, Safir Portföy ★★ ("Teknik taraf soruyor…"), Orion Konfeksiyon ★, Safir Dokuma ★. Akış 4,9/hafta. Hepsinde "Mesai bitiyor. Bu hafta yeni bir masaya oturulmaz." ve Görüşmeye git pasif — ama saat Pazartesi 00:00, hafta yeni başlıyor! [GÖRÜŞ/HATA ADAYI] "Mesai bitiyor" metni haftanın başında yanlış; muhtemelen gece saatinde "bugün" yerine "bu hafta" diyor.
- KARAR (H16): Junior Yazılım Mühendisi araması başlattım (Atlas Recruitment, "dosyalar gelecek hafta gelir"). Neden: MRR $1,9K, net +$1,7K/ay, kasa $11,6K; ürün kartları 25 puanlık oldu ve tek başıma 20 puan/sprint yapıyorum, satış görüşmeleri de kurucu saatini yiyor. Junior ~$3,5K/ay ile net ≈ -$1,8K/ay, runway ≈ 6 ay — 2 müşteri daha kapatırsam başa baş.

### K7 — H16 (Nisan 2012) 09:46 · "v1.4 sonrası bir şey bozuldu" · ÜRÜN · Karar · gönderen Zeynep Güneş (Satın Alma Sorumlusu · Sultanahmet Üretim) → Kurucu · Defterix
- Gövde: "v1.4 çıktığından beri yetkisi olmayan kullanıcılar maliyet sütununu görebiliyor. Etkilenen tek hesap Sultanahmet Üretim (15 kullanıcı)."
- Seçenekler:
  1. "Sprinti durdur, şimdi düzelt" [Sorun 16:00 sularında çözülür]
  2. KİLİTLİ "Ekip bu akşam kalsın" — "Ekipte yazılım ya da test yapan kimse yok."
  3. "Kendin düzelt" [Senin verimin -%15 · 1 hafta] [Sorun 16:00 sularında çözülür]
  4. "Sonraki sprinte bırak" [Sultanahmet Üretim: memnuniyet 52 → 46] [Düzelene kadar her sprint sonunda memnuniyet -3]
- Seçimim: Kendin düzelt. Neden: yetki sızıntısı yeni (onboarding'deki) müşteride, bekletilemez; 1. seçeneğin bedeli yazmıyor (sprint durunca Tablo İçe Aktarma ilerlemesi gider mi?), 3.'nün bedeli açık ve küçük (1 hafta -%15).
- Oyun kendiliğinden durdu, "CEVAP BEKLİYOR · Zeynep Güneş". Cevap damgası "CEVAPLANDI H16", saat 10:01.
- Türkçe doğal; müşteri ağzından yazılmış, çok iyi. Kilitli seçeneğin nedeni yazıyor — iyi. [GÖRÜŞ] "Sprinti durdur" seçeneğinin olumsuz çipi yok; bedeli gizli olduğu için en iyi seçenek gibi duruyor, oyuncu yanılabilir. Kare: kareler/12_h16_v14_bir_sey_bozuldu_karar.png
- Bu kart, sağ üstteki "DESTEK 1 açık hata" ile aynı hata (Güvenlik & Yetki düzeltmesi). [GÖRÜŞ] Hata önce Destek'te belirdi, ~10 saat sonra karar kartı olarak geldi: güzel zincir.
- Gönderen: İLK KEZ bir müşteri (Zeynep Güneş). Önceki kâğıtlar Kurucu (x3), Frank (x3), Muhasebe, Sektör Telgrafı.

## Satış görüşmesi 3 — H16 10:00 · Safir Portföy ★★ ("Teknik taraf soruyor. Ürünün nereye kadar gittiğini bilmek ister.") — KAYIP
- Masada Tolga Güneş (Satın Alma) + Nehir Tekin (Ekip Yöneticisi). TEMKİNLİ %33. [GÖRÜŞ] "Güneş" soyadı üçüncü kez (Selin Güneş, Zeynep Güneş, Tolga Güneş) — isim havuzu dar.
- Tolga: "Çekirdek tarafınız bize yetmiyor. İhtiyacımız olan kademe listede var ama kapalı görünüyor." (Her cevap not ediliyor.) [1] "O kademe kapalı. Henüz açamıyoruz." · [2] "Bir sonraki sprintte sizin için yapacağımız kademeyi yazılı veririm." (zar: TEHLİKELİ %40; HAZIRLIK − Ürün uyumu · Çekirdek Zayıf, + Sağlayıcı kademesi; ODA + Verdiğin cevaplar; BECERİ + Senin satış tarafın, +1 etken daha) ← seçtim (söz vermek riskli ama S9'da Çekirdek kartı yapıyorum). → ILIK %40.
- Nehir: "verinin güvende olması ve sistemin ayakta kalması…" Kilitli "Güven tarafı hazır" ("Güven bunu henüz desteklemiyor." — v1.4'te Hesap & Oturum çıktı, ama Güven hâlâ Zayıf). [1] "Güven tarafı henüz eksik…" ← seçtim · [2] Teklife geç (Tehlikeli). → %43.
- Tolga: "Geçiş ne kadar sürer?" [1] "Ürün kolay öğreniliyor…" (zar) ← seçtim · [2] "Verinizi görmeden…" · [3] "İmzalarsanız … sonraki sprintimize yazarım." (bu kez AÇIK, zar) · [4] Teklife geç (Riskli).
- Sonuç: Tolga "Çekirdek sizde henüz zayıf. O taraf güçlenince yeniden konuşalım." → "Anlaşma olmadı · MASAYA ETKİSİ: 4 hafta bu şirkete dönülemez · İLİŞKİ: Tolga Güneş temkinli → ılık · HAFIZAYA YAZILAN: Geçen sefer Çekirdek konuşulmuştu." İkna %51 iken bitti. Kare: kareler/14_h16_safir_anlasma_olmadi.png, zar ipucu: kareler/13_h16_safir_zar_ipucu.png
- [GÖRÜŞ] Kayıp adil hissettirdi; nedeni (Çekirdek Zayıf) açık ve sprint kararıma geri bağlanıyor. Zar ipucunun etkenleri göstermesi çok iyi. Ama "Teklife geç" basmadan görüşmenin bitmesi sürpriz oldu: bir sonraki adımın son soru olduğunu bilmiyordum.

## Hafta 17–18
- H18 00:00 Sürüm notu Sprint 9 sonu: "Bu sprint sürüm çıkmadı", Tablo İçe Aktarma DEVREDEN (5 test + 4 geliştirme) → Sprint 10. HIZ 16,5/20 (Kendin düzelt -%15 verim ile uyumlu). "Kendi notun: Tablo İçe Aktarma bir sprint daha ister."
- S10 planı: Geliştirme kapasitesi 4/4, Test 5/17 (test kapasitesi bu kez 17 göründü; önceki sprintlerde 0'dı). "2 efor daha sığar" yazıyor ama Nakit Akış Tablosu'nun (25) "+"sı hiçbir şey yapmadı. [GÖRÜŞ] Kart sığmıyorsa "+" gri olmalı ya da neden yazmalı.
- Ofis toast'ları: "ATLAS · 3 aday dosyası hazır" (H17 12:00), "Bilge Polat · Büyümek istiyor" (H17 11:00, MÜŞTERİ · Dikkat).
- "Büyümek istiyor" bir ön-kart: Bilge Polat BÜYÜMEK İSTİYOR · MRR $1,2K/ay · Koltuk 25 · Memnuniyet 44 · 1 aydır · "Başka departmana yaymak istiyor." · "Müşteri temsilcisi: atanmadı" → [Değerlendir] düğmesi kâğıdı açtı:

### K8 — H18 (Nisan 2012) 10:00 · "Büyüme fırsatı" · MÜŞTERİ · Kağıt · gönderen Bilge Polat (Satın Alma Sorumlusu · Bakırçay Tekstil) · "Bu hafta son"
- Gövde: "Bakırçay Tekstil sistemi bir ekibe daha açmak istiyor. Aynı fiyattan koltuk istiyorlar."
- Seçenekler: "Koltukları ekle" [Koltuk +6 · MRR +$288] · "Şimdi değil" [Değişiklik yok] · Kenara koy (ESC).
- Seçimim: Koltukları ekle. Neden: bedelsiz gelir; memnuniyeti 44 olan müşterinin genişlemek istemesi iyi işaret, reddetmek için neden yok.
- Görülen etki: MRR $1,9K → $2,1K, NET +$1,7K → +$2,0K/ay. Damga "CEVAPLANDI H18". Saat 00:00'da açtım ama kâğıt "10:00" diyor (Değerlendir'e basınca zamanı geleceğe yazılmış — liste "Hafta 18 · 00:00" diyor).
- Türkçe doğal. [GÖRÜŞ] Kolay, tek doğru cevaplı bir kâğıt — "karar" hissi zayıf. Memnuniyet 44 (turuncu) olan bir müşterinin büyümek istemesi de biraz çelişkili.
- Gönderen: Bilge Polat (müşteri, 2. farklı müşteri sesi).
- H18 İŞE ALIM (Atlas Recruitment, 3 aday dosyası): Selin Yıldız (Yazılım 5/Test 1/Liderlik 0, "Çabuk kapar", $4.100/ay, 10 puan, komisyon $2.050, runway 5 ay) · Kerem Polat (3/2/2, "Sadık", $4.500, 7,4 puan, $2.250, 4 ay) · Arda Güneş (5/0/1, "Hayır diyemez: Hesapları daha memnun, ama üzerinde daha çok söz birikir.", $3.550, 10 puan, $1.775, 7 ay).
  - Seçimim: Arda Güneş. Neden: aynı 10 puanı en ucuza veriyor, runway 7 ay en uzun; "Hayır diyemez" huyu müşteri memnuniyetine yarar (Bakırçay 44'te). Uyarı satırı: "Bu maaş nakit akışını eksiye çevirir, kasa erimeye başlar."
  - Etki: kasa $12.394 → $10.619 (komisyon $1.775 düştü). Ekip: 1 çalışan, ort. moral 75, maaş yükü $3.550. Arda "YENİ", görev "Defterix Fatura v1.5 üzer…" (kesik), %0. NET üst barda hâlâ +$2,0K/ay görünüyor (maaş henüz yansımadı?).
  - [GÖRÜŞ] Aday kartları çok net (puan, runway, komisyon). "Hayır diyemez" gibi huylar karakter katıyor. Soyadı yine "Güneş" (4. Güneş).

## Hafta 19
- H19 00:00 Sürüm notu Sprint 10 sonu: v1.5 CANLI (Tablo İçe Aktarma 25). HIZ 8,5/20. BASIN Ekonomi Postası "Defterix Fatura yeni sürümünü çıkardı: Tablo İçe Aktarma". Not artık "LİDER Arda Güneş: Çekirdek sırada." (kendi notun → ekip lideri notu; güzel).
- Üst bar değişti: KASA $10.269 · NET -$1,6K/ay · RUNWAY 7 ay · BURN $3,7K/ay. (Maaş ilk kez yansıdı.)
- S11 planı: v1.5'ten sonra Çekirdek'te 3 HATA KARTI belirdi: "Nakit Akışı düzeltmesi 4 hata · 8 (4 hata · 2 hesap · 46 kullanıcı)", "Veri Girişi düzeltmesi 3 hata · 6", "Defter düzeltmesi 1 hata · 2". [GÖRÜŞ] Hata kartları etkiyi "2 hesap · 46 kullanıcı" diye yazıyor; çok iyi, önceliklendirmeyi kolaylaştırıyor. Ama yeni sürüm 8 hata getirdi ve hiçbir kart/uyarı bunu söylemedi (DESTEK kutusu "1 açık hata" demeye devam ediyordu).
- Sprint ekranı: hata kartlarında modül panelindeki "+" DOĞRUDAN ekledi; orta listedeki EKLENEBİLİR "+" hata kartında hiçbir şey yapmadı (normal kartlarda tersi). İki "+" davranışı tutarsız.
- S11: 3 hata düzeltmesi (16) + Nakit Akış Tablosu (25). Kapasite: Tasarım 4/4, Geliştirme 27/27, Test 10/8 (+2 → Sprint 12'ye DEVREDEN). Ekip: kurucu (2★) + Arda (2,5★).

## Hafta 19–21
- H19 15:05 ofis: DESTEK "10 açık hata" (v1.5 sonrası). Toast "Zeynep Güneş · Teşekkürler". Ofiste yalnız kurucu görünüyor — yeni alınan Arda Güneş masada görünmedi. [GÖRÜŞ] İşe alınan çalışanın ofiste belirmemesi (en azından o gün) tuhaf.
- (Bilgi kartı, karar yok) H19 10:00 "Teşekkürler" · MÜŞTERİ · gönderen Zeynep Güneş: "Sorunu bu kadar hızlı çözdüğünüz için teşekkürler." — K7'deki "Kendin düzelt" kararımın geri bildirimi. Güzel kapanış.
- H21 00:00 Sürüm notu Sprint 11 sonu: v1.6 CANLI. Nakit Akışı düzeltmesi 4→0, Veri Girişi düzeltmesi 3→0, Defter düzeltmesi 1→0 açık hata. Nakit Akış Tablosu DEVREDEN. HIZ 39/40. SONUÇ "Beklenen: 8 hata kapanmalı". DESTEK artık "2 açık hata".
- Ledger H21: KASA $9.569, NET -$1,5K/ay, RUNWAY 6 ay, MRR $2,1K, BURN $3,7K/ay.

### K9 — H20 (Mayıs 2012) 11:00 geldi · "Yazım hatasına kadar" · GÜNDEM · Kağıt · gönderen "Kurucu · Kendine not" · "Bu hafta son" — H21 00:00'da cevapladım
- Gövde: "Daha geçen ay bir milyon dolar yatırım alan bir ekip, senin son üç özelliğini yazım hatasına kadar aynen yayına aldı. Duyuruları seninkinden daha çok okundu. İlk müşterilerini adlarıyla anıyorlar." (Kartta büyük kurucu portresi var.)
- Seçenekler: "Hukuk bürosu aracılığıyla ihtarname çek" [Nakit -$3,0K] [Marka +2] · "Basın bülteni yayınla" [Marka +4] [İtibar -2] · "Onların ilk müşterilerini bizzat ara" [Yeni aday] [Senin verimin -%20 · 2 hafta] · Kenara koy (ESC).
- Seçimim: Onların ilk müşterilerini bizzat ara. Neden: kasa $9,6K ve net eksi; $3K ihtarname runway'i ~2 ay kısaltır. B2B'de marka yerine somut aday işe yarar; Arda geliştirmeyi taşıdığı için kurucunun 2 hafta -%20 verimi katlanılabilir.
- Türkçe doğal ve sert, iyi yazılmış. [GÖRÜŞ] Rakip ekibin adı yok ("bir ekip") — haber bandında Tacita, Raketenhaus, Sumpter gibi rakipler dönüyor; bunlardan birinin adı geçse bağ kurulurdu. Kare: kareler/15_h21_yazim_hatasina_kadar_kagit.png
- Gönderen yine "Kurucu · Kendine not" (4. kurucu kâğıdı).
- S12 planı (H21): Çekirdek'te yalnız devreden Nakit Akış Tablosu (2) + görüş; Güven'de 2 hata kartı (Dayanıklılık düzeltmesi 1 hata · 2, Güvenlik & Yetki düzeltmesi 1 hata · 2) + görüş; Entegrasyonlar'da yalnız görüş; İK'da görüş. Eklenecek ÖZELLİK KARTI YOK. Plan: Nakit Akış Tablosu + 2 hata + Güven görüşmesi → Geliştirme 3/28 (ekibin %90'ı boşta), "5 efor daha sığar".
  [GÖRÜŞ] ÖNEMLİ: İki kişilik ekip ile Sprint 12'de doldurulacak iş kalmadı; yeni kartlar ancak görüşme bitince açılıyor gibi, ama her modülde aynı anda yalnız 1 görüşme var ve kurucunun saatini yiyor. Maaş ödenen mühendis boşta kalıyor ve oyun bunu söylemiyor. Ayrıca "5 efor daha sığar" ile "Geliştirme 3/28" çelişik görünüyor. Kare: kareler/16_h21_sprint12_kapasite_bos.png
- Ayrıca bu kez Güven hata kartında sol "+" yalnız vurguladı (önceki sprintte Çekirdek hata kartlarında sol "+" doğrudan eklemişti) — davanış kartın listede ilk olup olmamasına göre değişiyor olabilir.

## Hafta 21–22
- 3× hızda bir hafta ~7 sn sürüyor; tıklama başına ~3 sn gecikmeyle gündüz saatinde satış görüşmesi yakalamak zor (H21 10:55'te Satış'ı açarken H22 00:00 oldu). Her seferinde Satış'ta "Mesai bitiyor. Bu hafta yeni bir masaya oturulmaz." görüyorum — gece 00:00'da da bu yazıyor.
- H22 00:00 Sürüm notu Sprint 12 sonu (sprint 1 haftada erken bitti): v1.7 CANLI — Nakit Akış Tablosu 25, Dayanıklılık düzeltmesi 1→0, Güvenlik & Yetki düzeltmesi 1→0, Güven görüşmesi ✓5. HIZ 11/36. BASIN Girişim Bülteni. Güven & Ölçek modülü görüşmeden sonra listeden kalktı.
- Satış H22: Sultanahmet ★★ "BÜYÜMEK İSTİYOR" (memnuniyet 67) · Bakırçay SAĞLIKLI 56 · ORT. MEMNUNİYET %62. Adaylar: Alaçatı Beton ★★, Çukurova Beton ★★, Erciyes Legal ★, Haliç Beton ★. "Yazım hatasına kadar" kâğıdındaki "Yeni aday" çipinin hangi aday olduğu belirtilmemiş; listede ayırt edici bir etiket göremedim. [GÖRÜŞ] Kâğıtla kazanılan adayın listede "rakipten" gibi bir rozeti olsa iyi olurdu.

### K10 — H22 (Mayıs 2012) 00:00 · "Büyüme fırsatı" · MÜŞTERİ · Kağıt · gönderen Zeynep Güneş (Satın Alma · Sultanahmet Üretim) · "2 hafta içinde"
- Ön-kart "Büyümek istiyor" (MRR $660/ay, Koltuk 15, Memnuniyet 67, 1 aydır, "Başka departmana yaymak istiyor.", temsilci atanmadı) → [Değerlendir] → kâğıt.
- Gövde: "Sultanahmet Üretim sistemi bir ekibe daha açmak istiyor. Aynı fiyattan koltuk istiyorlar." Seçenekler: "Koltukları ekle" [Koltuk +6 · MRR +$264] · "Şimdi değil" [Değişiklik yok] · Kenara koy.
- Seçimim: Koltukları ekle (bedelsiz MRR). Etki: MRR $2,1K → $2,4K, NET -$1,5K → -$1,3K/ay, runway 6 → 7 ay.
- K8 ile birebir aynı şablon (yalnız şirket/kişi değişti). Süre bu kez "2 hafta içinde" (K8'de "Bu hafta son"). [GÖRÜŞ] İkinci kez aynı kâğıt geldiğinde karar hissi tamamen kayboluyor; "Şimdi değil"in hiçbir anlamlı nedeni yok.

### K11 — H22 (Mayıs 2012) 09:38 · "v1.7 sonrası bir şey bozuldu" · ÜRÜN · Karar · gönderen Arda Güneş (Yazılım Mühendisi · Defterix) → Kurucu · Defterix
- Gövde: "v1.7 çıktığından beri kasa bakiyesi gün sonunda yanlış çıkıyor. 2 hesap etkileniyor, en büyüğü Bakırçay Tekstil (31 kullanıcı)." Kartta büyük Arda portresi.
- Seçenekler: "Sprinti durdur, şimdi düzelt" [Sorun 13:50 sularında çözülür] · "Ekip bu akşam kalsın" [Arda: moral -7] [Sorun 20:50 sularında çözülür] (bu kez AÇIK, çünkü ekipte yazılımcı var) · "Kendin düzelt" [Senin verimin -%15 · 1 hafta] [Sorun 16:00 sularında çözülür] · "Sonraki sprinte bırak" [2 hesap: memnuniyet -6 · Bakırçay Tekstil 56 → 50] [Düzelene kadar her sprint sonunda memnuniyet -3].
- Seçimim: Sprinti durdur, şimdi düzelt. Neden: S13 neredeyse boş (3 geliştirme + görüşme), sprintin durmasının kaybı küçük; en hızlı çözüm; Arda'nın moralini ve benim verimimi korur.
- Görülen etki: kart "CEVAPLANDI H22", saat 10:00. Kasa/moral değişmedi. Sprint ekranında gözle görülür bir "durdu" işareti aramadım (aşağıda).
- Türkçe doğal. Aynı şablonun 2. kez gelmesi (K7: Zeynep/v1.4, K11: Arda/v1.7) — ama bu kez gönderen kendi çalışanım ve "Ekip bu akşam kalsın" açılmış: ekibin büyümesi kartı değiştiriyor, güzel. [GÖRÜŞ] "Sprinti durdur"un bedeli yine yazmıyor.
- Kare: kareler/17_h22_v17_bir_sey_bozuldu_arda.png
- Not: Bu kart açıldığında Satış paneli "Karar bekliyor. Bu pencere yalnız okunur." bandı ile kilitlendi, [Karara dön] düğmesi var — iyi tasarım.

## Satış görüşmesi 4 — H22 10:00 · Alaçatı Beton ★★ ("Ölçülü bir alıcı…") — KAZANILDI
- Gündüz yakalamak için 1× hıza indim, 08:40'ta durdurdum. Masada Selin Çetin (Satın Alma) + Zeynep Yıldız (Ekip Yöneticisi). TEMKİNLİ %26.
- Selin: "İlk kullanım tarafınız bize yetmiyor. Ekibimiz sahada ve telefonda çalışıyor…" Kilitli "İlk kullanım tarafı hazır" → [1] "İlk kullanım tarafı henüz eksik…" ← seçtim (zar: TEHLİKELİ %35; − Ürün uyumu · İlk kullanım Yok). → %35.
- Zeynep Y.: "Veri nerede duruyor?" → [3] "Aynı soruyu soran bir müşterimiz var. Onunla konuşun." (referans) ← seçtim (artık 2 müşterim var). → ILIK %40.
- Selin: "Geçiş ne kadar sürer?" → "Ürün kolay öğreniliyor…" bu kez KİLİTLİ ("İlk kullanım bunu henüz desteklemiyor."). [HATA ADAYI/TUTARSIZLIK] Aynı seçenek H13 (Sultanahmet) ve H16 (Safir) görüşmelerinde AÇIKTI; H22'de kilitli. Ürün sürümü arttı, ama İlk Kullanım modülünde hiç kart yapılmadı; değişen şey yalnız İK görüşmesinin üzerinden zaman geçmesi. Oyuncu açısından "yetenek kaybettim" hissi, açıklamasız.
  → [1] "Verinizi görmeden tarih vermek istemem." ← seçtim. → %48, "Bu kadar soru yeter."
- Rakam: 25 koltuk, $50 → karşı $48 → Kabul. "Şartlarda anlaşıldı · 25 koltuk × $48 = $1.200 MRR · İmza 3 hafta sonra · İlişki: Selin Çetin temkinli → ılık".
- H22 F5 hızlı kayıt. Ledger H22: cash 9.219, mrr 2.412, customers_active 2 (customers_expanded 2), employees 1, brand 48, phase 2, product_version 8. (Not: ledger'daki "day" alanı aslında hafta numarası: H11'de 11, H22'de 22.)

## Hafta 23 (sprint ekranı)
- H23 00:00 Sürüm notu Sprint 13 sonu: v1.8 CANLI — Nakit Akışı düzeltmesi 2→0, Çekirdek görüşmesi ✓5. HIZ 9/36. "Kendi notun: İlk kullanım sırada." Çekirdek modülü listeden kalktı.
- S14 planı: modüllerde (İK, Entegrasyonlar, Güven) YALNIZ "5 kullanıcıyla görüş" kartları var; hiçbir özellik/hata kartı yok. Arda Güneş "İzinde" (kapasite şeridinde ikonunun yanında; neden izinde olduğu hiçbir yerde söylenmedi — kart/mesaj gelmedi). Geliştirme kapasitesi 0/16 → 0/6. İki görüşme ekledim (İK + Entegrasyonlar).
- "Sprinti başlat" ilk tıklamada yine tepki vermedi, ikinci tıklamada başladı (S13'te de aynı oldu).
- [GÖRÜŞ] ÖNEMLİ: 23. haftada ürün planlaması "görüşme yap → kart aç" döngüsüne kilitlendi; maaşlı mühendis iki sprinttir neredeyse boşta (HIZ 11/36, 9/36). Oyun bunu ne uyarıyor ne de açıklıyor. Kare: kareler/18_h23_sprint14_yalniz_gorusme_arda_izinde.png
- Ekip H23: Arda Güneş · görev "Defterix Fatura v1.9 üzer…" (kesik) %94 · DURUM "İZİNDE 2 hafta" · moral 75. İzne çıkışı için bir kart, toast ya da onay görmedim; ilk işe alımından 5 hafta sonra 2 haftalık izin sessizce başladı. DESTEK "0 açık hata".

## Satış görüşmesi 5 — H24 14:45 · Lumen Dokuma ★★ — KAZANILDI
- H24: Alaçatı Beton "Sen · İmza aşaması · 2/3 hafta · Bu şirketle anlaşma sürüyor." Lumen Dokuma'ya "Görüşmeye git" (14:45'te mesai açıktı).
- Masada Deniz Koç (Satın Alma) + Nehir Arslan (Ekip Yöneticisi). TEMKİNLİ %31. Anlatıcı: "Sorular hazırlanmış. Bu görüşmeye çalışmışlar."
- Deniz: "İlk kullanım tarafınız bize yetmiyor." + "Veri nerede duruyor?" → [1] bulut ← seçtim. → %39.
- Nehir: "programlarımızla konuşabiliyor mu?" → [1] "Entegrasyonlar tarafı hazır." (bu kez zar YOK, kesin) ← seçtim. → ILIK %47.
- Deniz: "Geçiş ne kadar sürer?" → kilitli "Ürün kolay öğreniliyor…" (İlk kullanım…) · [1] "Verinizi görmeden…" ← seçtim · kilitli "İmzalarsanız … sonraki sprintimize yazarım." — gerekçe "Bir sonraki sprintte buna yer yok." [HATA ADAYI] O an S14'te yalnız iki 5'lik görüşme vardı (Geliştirme 0/6, sprint neredeyse boş) ve Sprint 15 bomboş; "yer yok" gerekçesi ekrandaki duruma uymuyor. Kare: kareler/19_h24_sprintte_yer_yok_ama_sprint_bos.png
- Rakam: 27 koltuk, "Kapasite 79/50" (! kapasiteyi aşıyor; ne demek olduğu açıklanmıyor, kırmızı/uyarı yok). $50 → karşı $43 (SABIR 3→2) → Kabul. "27 koltuk × $43 = $1.161 MRR · İmza 3 hafta sonra · İlişki: Deniz Koç temkinli → ılık".
- [GÖRÜŞ] "Kapasite 79/50" görünce durdum: koltuk kapasitesi mi, sunucu mu? Aşınca ne olacağı yazmıyor.

## Hafta 25 — Ar-Ge keşfi (önemli)
- H25 00:00 Sürüm notu Sprint 14 sonu: "Bu sprint sürüm çıkmadı" (yalnız İK + EN görüşmeleri). HIZ 10/16. LİDER Arda Güneş: "Çekirdek sırada." Kasa $8.617, MRR $3,6K (Alaçatı imzaladı), NET -$60/ay, RUNWAY 144 ay. Haber bandı: "İK Arda Güneş izinden döndü".
- S15: yine yalnız görüşme kartları (Çekirdek + Güven). İkisini ekleyip başlattım.
- SONRA Ar-Ge'yi açtım (sol menüde "1" rozeti v1.0'dan, yani H7'den beri duruyordu; H7 sürüm notunda "Ar-Ge açıldı · Ar-Ge'ye git" de yazmıştı). AR-GE TAMAMLANAN 0/19. Ağaç: İŞLEV (Ürün alanı) kök "Veri Modeli"; PLATFORM (Yazılım) kök "Ölçeklenebilir Arka Uç"; SÜREÇ (Test) kök "Hata Takip Sistemi"; TASARIM kök "Tasarım Sistemi". Veri Modeli: "Verinin ortak şeması. Her kayıt aynı dilden konuşur. AÇTIĞI ŞEY: Entegrasyonlar hattının son kademesi." Ürün ★1 · ~4 hafta (Kurucu).
- [GÖRÜŞ] ÖNEMLİ: H19–H25 arasında sprintlerin boş kalmasının nedeni muhtemelen buydu: yeni kartlar Ar-Ge ile açılıyor. Ama sprint ekranı "kart kalmadı → Ar-Ge'ye git" demiyor; 18 hafta duran "1" rozeti tek ipucu. Oyuncu olarak bunu ancak 25. haftada, maaşlı mühendis 3 sprint boşa döndükten sonra buldum. Kare: kareler/20_h25_arge_agaci_veri_modeli.png
- KARAR: Veri Modeli araştırmasını Kurucu ile başlattım. Uyarı: "Kurucu sprintten çıkar; dönene kadar sprint durur." Neden: kasa güvende (runway 144 ay), tek yol yeni kart açmak; Arda'nın Ürün yeteneği 0 olduğu için araştırmayı yalnız kurucu yapabiliyor. Bedel: S15'teki iki görüşme durur, satış görüşmeleri etkilenebilir (göreceğiz). Üstte "ARAŞTIRMA Veri Modeli %0 ~4 hafta kaldı · duraklat · ata".

### K12 — H25 (Haziran 2012) 12:00 · "Frank'in teklifi" · MENTOR · Karar · gönderen Frank Köseoğlu (Operating Partner) → Kurucu · Defterix
- Gövde: "Ürün para kazandırmaya başladı. Arayan yine Frank. 'Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?' Cevap bekliyor." (büyük Frank portresi, mektup yazı tipi)
- Seçenekler: "Kabul et" [Nakit +$25K] [Frank'e %4 hisse] · "Reddet" KİLİTLİ — "Zor modda açılır."
- Seçimim: Kabul et (tek açık seçenek). Neden (oyuncu olarak da kabul ederdim): $25K / %4 → $625K değerleme, 3,6K MRR'lık bir şirket için çok iyi; runway'i uzatır, ikinci işe alımı mümkün kılar.
- Etki: KASA $8.617 → $33.617, RUNWAY 144 → 560 ay. SIRADAKİ "Seed turu: aylık gelir $2,5K" (yeni hedef). Damga "CEVAPLANDI H25".
- Türkçe çok iyi ("Pazarlık yok. Bir kere soruyorum"). [GÖRÜŞ] "Karar" diye etiketli ama Normal zorlukta tek seçenek var; "Reddet — Zor modda açılır" kilidi oyuncuya "aslında seçimin yok" diyor. Ya etiket "Mesaj" olmalı ya da Reddet Normal'de de açık olmalı. Kare: kareler/21_h25_frankin_teklifi_reddet_kilitli.png
- Gönderen: Frank (4. Frank kartı: H1 notu sayılmazsa H8, H11, H25 + H1'deki dolaylı).
- Ayrıca Olaylar listesinde H23 12:00 "Teşekkürler · Bilge Polat — Hızlı müdahaleniz için teşekkürler, her şey yeniden ç…" (K11 "Sprinti durdur" kararının teşekkürü; karar istemeyen bilgi kartı) gördüm; geldiğinde fark etmemiştim.
- H25 KARAR: Junior Ürün Yöneticisi araması başlattım (Atlas; junior $2.700–4.050/ay, komisyon $1.350–2.025). Neden: Frank'in $25K'sı ile kasa $33,6K; darboğaz artık Ar-Ge (Ürün yeteneği isteyen işler yalnız kurucuda) ve görüşmeler. Ekip ekranında Arda moral 90 (izinden dönmüş), görevi "Defterix Fatura v1.9 üzer…" %100.

## Hafta 26–27
- (Space ile durdurmam tutmadı, H27'ye geçti.) H27 00:00 Sürüm notu Sprint 15 sonu: "Bu sprint sürüm çıkmadı" (Çekirdek + Güven görüşmeleri ✓). HIZ 10/38. LİDER Arda: "İlk kullanım sırada." Not: Kurucu Ar-Ge'deyken S15 görüşmeleri yine bitti — "Kurucu sprintten çıkar; dönene kadar sprint durur" uyarısı gerçekleşmedi gibi.
- MRR $4,8K (Lumen imzaladı), NET +$1,1K/ay, kasa $33.862. SIRADAKİ "Seed turu: aylık gelir $20K".
- S16: Kurucu Ar-Ge'de (kapasite şeridinde yalnız Arda 2,5★). Yalnız İK görüşmesini ekledim → Arda'ya atandı (görüşmeyi çalışan da yapabiliyor).
- Ar-Ge Veri Modeli: H27'de %70, ~1 hafta kaldı.
- İŞE ALIM H27 (Atlas, Junior Ürün Yöneticisi): Selin Güneş (Ürün 5/Tasarım 1/Liderlik 0, "Çabuk kapar", $3.450, komisyon $1.725, runway 14 ay) · Kerem Çetin (3/2/2, "Sadık", $3.850, 12 ay) · Arda Tekin (5/0/1, "Tat kaçıran: Ekibinin morali normalden hızlı erir", $2.850, 19 ay).
  - Seçimim: Selin Güneş. Neden: Ürün 5 (Ar-Ge'nin İşlev dalı için), "Tat kaçıran" huyu Arda'nın 90 moralini riske atardı; $600 fark kasada önemsiz.
  - Etki: kasa $33.862 → $32.137, ekip 2, ort. moral 83, maaş yükü $7.000. Ekip rozetinde "1" (yeni).
  - [GÖRÜŞ] İsim havuzu dar: "Selin Güneş" (5. Güneş), "Kerem Çetin" (önceki adayda Kerem Polat, müşteride Selin Çetin), "Arda Tekin" (çalışanım Arda Güneş). Aynı isimler sürekli dönüyor.

### R2 — H27 (Temmuz 2012) 09:00 · "2. Çeyrek 2012" · GÜNDEM · Rapor · gönderen "Muhasebe · Defterix"
- "Hafta 14–26 · Traction". MRR $1,2K → $3,6K (+$2,4K) · Kasa $11K → $34K (+$23K) · Ekip kurucu dahil 1 → 2 (+1) · Marka 48 → 48 (±0) · Runway 560 ay. ÇEYREĞİN OLAYI: "Frank çeki yazdı: melek turu kapandı". Tek düğme Devam et. Oyun durdu, panel kendiliğinden açıldı.
- Not: Q1 raporu H14 10:00'da, Q2 raporu H27 09:00'da geldi (13 hafta arayla, tutarlı). DESTEK kutusu bu sırada "5 açık hata" diyor.

## Hafta 28 — Ar-Ge sonrası sprint doldu
- H28 00:00 Sürüm notu Sprint 16 sonu: sürüm yok (İK görüşmesi ✓). HIZ 5/22. LİDER Arda: "Çekirdek sırada." Üst bar: NET -$2,3K/ay, RUNWAY 14 ay, BURN $7,1K/ay (Selin'in maaşı girdi).
- Haber bandı: "İK Selin Güneş 2 hafta izinde" — YENİ işe aldığım Ürün Yöneticisi ilk haftasında 2 haftalık izne çıktı (Arda da H23'te izne çıkmıştı). [HATA ADAYI/DENGE] İşe alımdan hemen sonra açıklamasız izin; HAZIRLIK panelinde hâlâ "PM yok". Oyuncu olarak "neden maaş ödüyorum?" hissi.
- Ürün sekmesinde yeni bölüm: "MÜŞTERİ TALEPLERİ 1 · Bakırçay Tekstil · ⌛ gelecek çeyrek · EN Çoklu Entegrasyon". Ar-Ge Veri Modeli bitince Entegrasyonlar'da "Çoklu Entegrasyon (Bakırçay Tekstil)" 25 kartı açıldı. Ar-Ge → kart → müşteri talebi zinciri çok iyi; ama bunu ancak tesadüfen keşfettim.
- v1.8 sonrası Çekirdek'te 3 hata kartı daha (Nakit Akışı 1 hata, Defter 1 hata, Stok 3 hata · "4 hesap · 104 kullanıcı").
- S17: Nakit Akışı düz. 2 + Defter düz. 2 + Stok düz. 6 + Çoklu Entegrasyon 25 → Tasarım 4/4, Geliştirme 23/30, Test 8/8, "2 efor daha sığar". İlk kez sprint dolu. Kare: kareler/22_h28_sprint17_dolu_coklu_entegrasyon.png
- Sprint ekranı "+": modül panelindeki "+" bazen ekliyor bazen yalnız vurguluyor; vurgulandıktan sonra orta listedeki "+" ekliyor. Orta "+"ya vurgu olmadan basmak hiçbir şey yapmıyor (hata kartlarında defalarca).

## Hafta 29–30
- H28 Satış (13:05): 4 müşteri, ORT. MEMNUNİYET %57, "BU AY KAZANILAN +1". Alaçatı Beton memnuniyet 49 (turuncu, ONBOARDING), Lumen 56. Adaylar Thalassa Lojistik ★★, Mercan Pazar ★★, Safir Pazar ★, Efes Danışmanlık ★. 1× hızda bile 13:05'te "Görüşmeye git"e bastıktan ~2 sn sonra saat 18:50 oldu ve "Mesai bitiyor…" ile görüşme kaçtı. [GÖRÜŞ] Satış görüşmesi açma penceresi gerçek zamanda çok dar; "Görüşmeye git" basınca oyunun durması/kendiliğinden toplantıya gitmesi beklenirdi.
- H30 00:00 Sürüm notu Sprint 17 sonu: v1.9 CANLI — Nakit Akışı 1→0, Defter 1→0, Stok 3→0 açık hata. DEVREDEN: Çoklu Entegrasyon (Bakırçay Tekstil) → Sprint 18. HIZ 21/42. LİDER Arda: "Çoklu Entegrasyon bir sprint daha ister." HAZIRLIK: artık "Selin Güneş 2,5★ · 1 kart hazırladı" (PM işe başladı).
- Ledger/üst bar H30: KASA $30.499 · NET -$2,3K/ay · RUNWAY 13 ay · MRR $4,8K · BURN $7,1K/ay · MARKA 48. SIRADAKİ (turuncu): "Sahibi değişti · bu hafta son" (bekleyen kâğıt).

### K13 — H29 (Temmuz 2012) 11:00 geldi, H30 00:00'da cevapladım · "Sahibi değişti" · MÜŞTERİ · Kağıt · gönderen Bilge Polat (Satın Alma · Bakırçay Tekstil) · "Bu hafta son"
- Gövde: "Bakırçay Tekstil, kırk şirketli bir gruba satıldı. Grubun bütün satın almaları tek ekipten geçiyor, o ekip de yalnız kendi sözleşmesini imzalıyor. Sözleşme geldi: 31 koltuk için doksan sayfa. Fiyat hanesi boş bırakılmış. İndirim hanesi dolu."
- Seçenekler: "Avukat parasını fiyata yansıt" [Nakit -$2,5K] [Müşteri MRR +$400] · "Kendin oku, fiyatı yükselt" [Senin verimin -%30 · 2 hafta] [Müşteri MRR +$200] · "İndirime karşılık logolarını iste" [Müşteri MRR -$150] [Marka +3] · Kenara koy (ESC).
- Seçimim: Avukat parasını fiyata yansıt. Neden: $2,5K tek seferlik, +$400/ay ile ~6 ayda geri döner ve net yakımı kalıcı azaltır; kurucunun zamanı Ar-Ge ve satış için en kıt kaynak; B2B'de +3 marka MRR kaybına değmez.
- Görülen etki: KASA $30.499 → $27.999, MRR $4,8K → $5,2K, NET -$2,3K → -$1,9K/ay, RUNWAY 13 → 14 ay. Tam yazdığı gibi.
- Türkçe çok iyi, somut ("31 koltuk için doksan sayfa. Fiyat hanesi boş bırakılmış. İndirim hanesi dolu."). Üç seçenek de gerçek bir ödünleşim — bu oyundaki en iyi kâğıtlardan biri. Kare: kareler/23_h30_sahibi_degisti_kagit.png
- (Bilgi kartı) H28 12:00 "Veri Modeli" · ÜRÜN · Keşif · Kurucu · Kendine not: "Aynı müşteri üç ayrı tabloda üç ayrı isimle duruyordu. Perşembe akşamı üçü tek satırda birleşti. Ertesi sabah kimse hangi tablodan bakacağını sormadı." AÇTIĞI ŞEY: "Entegrasyonlar hattının son kademesi. Açtığı iki devam yuvası adlandı." Düğmeler [Ar-Ge'ye git] [Ürün sayfasına git]. Karar yok. Güzel yazılmış; ama geldiği an fark etmedim (toast'ta "Kurucu · Veri Modeli" olarak kaldı).
- Haber bandında H30'da "İÇERİDEN · Cevap gelmedi, eski kayıtlar boş kaldı." satırı geçti — bir kâğıdın süre dolması notu gibi; listede süresi dolmuş kâğıt göremedim (kayıt dosyasından bakılmalı).

### K14 — H30 (Temmuz 2012) 09:00 · "Muhasebecileri" · MÜŞTERİ · Kağıt · gönderen "Destek · Defterix" → Kurucu · "2 hafta içinde"
- Gövde: "Sultanahmet Üretim şirketinin muhasebecisi son iki kart ödemesini bankadan geri çektirdi. Bazı koltukları kimsenin kullanmadığını söylüyor. Patronları bankaya yazdı: ekip ürünü her gün kullanıyor. Banka muhasebeciden yana çıktı."
- Seçenekler: "Bırak, para onda kalsın" [Nakit -$1,8K] · "Kullanılan koltukları yeniden faturala" [Nakit -$400] [Koltuk -4] [Müşteri MRR -$200] · "Avukata ihtarname çektir" [Nakit -$500] [Memnuniyet -20] [İtibar -2] · Kenara koy.
- Seçimim: Bırak, para onda kalsın. Neden: tek seferlik $1,8K; 2. seçenek $400 + ayda $200 MRR kaybı → ~7 ayda daha pahalı ve koltuk kaybı; 3. seçenek memnuniyeti 68'den ~48'e düşürür (churn riski). Kasa $28K, kaldırır.
- Etki: KASA $27.999 → $26.199, RUNWAY 14 → 13 ay. MRR $5,2K değişmedi.
- Türkçe doğal, net. [GÖRÜŞ] "Bırak" seçeneği yalnız maliyet gösteriyor; memnuniyet/itibar açısından hiçbir artısı yazmıyor — tercih nedenini oyuncu kendisi kurmak zorunda (iyi de olabilir). Kare: kareler/24_h30_muhasebecileri_kagit.png
- Gönderen "Destek" (yeni bir ses; karta müşteri kategorisi ama gönderen şirketin destek ekibi).

### Kayıp kâğıt (görmediğim) — H29 · product.sprint_dev_backfill · gönderen Arda Güneş (kayıttan) · SÜRESİ DOLDU (H30)
- Kayıt dosyası event_engine/rows: day 30, resolution "expired", entities employee char_emp_18_0 (Arda), delta sprint_card_trim req:co_lead_8_4.13 (Çoklu Entegrasyon, Bakırçay talebi), bugs 1. Haber bandında "İÇERİDEN · Cevap gelmedi, eski kayıtlar boş kaldı." olarak göründü.
- Olaylar listesinde bu kâğıdı HİÇ görmedim: H29'da gelmiş, H30 00:00 sprint kapanışında süresi dolmuş; H30'da açtığım listede de yoktu (süresi dolan kâğıt listede görünmüyor). [HATA/TASARIM] Oyuncu cevaplama fırsatı bulamadan kâğıt düştü ve yan etkisi (1 hata) uygulandı.

---------------------------------------------------------------------------------------------------
# ÖZET BÖLÜMLER (oyun sonu, H30 · 22:04 gerçek saat; oyun kapatıldı, ekran kilidi bırakıldı)

## Son durum (H30, get_run_ledger + üst bar)
cash $26.199 (kâğıttan sonra) · MRR $5.173 · NET -$1,9K/ay · RUNWAY 13 ay · BURN $7,1K/ay · müşteri 4 aktif (Bakırçay Tekstil, Sultanahmet Üretim, Alaçatı Beton, Lumen Dokuma), 0 kayıp, 2 genişleme · ekip: kurucu + Arda Güneş (Jr Yazılım) + Selin Güneş (Jr Ürün Yöneticisi) · marka 48 · faz TRACTION · ürün v1.9 (10 sürüm) · Frank melek: $25K / %4.

## Araştırma sorusu 1 — kâğıtlar arası sessizlik (hafta listesi)
Kaynak: oyunda gördüklerim + kayıt dosyası event_engine/rows ("day" alanı = hafta).
Karar isteyen kartlar (tek düğmeli "Karar"lar dahil), geliş haftası:
  H6 Alan adı · H8 Eski bir dost · H11 İlk ödeme · H12 Sunucu faturası · H14 Çeyrek bülteni (düştü) · H16 v1.4 bozuldu · H18 Büyüme fırsatı · H20 Yazım hatasına kadar · H22 Büyüme fırsatı · H22 v1.7 bozuldu · H25 Frank'in teklifi · H29 sprint_dev_backfill (görmedim, süresi doldu) · H29 Sahibi değişti · H30 Muhasebecileri
Aralar (hafta): 6→8:2 · 8→11:3 · 11→12:1 · 12→14:2 · 14→16:2 · 16→18:2 · 18→20:2 · 20→22:2 · 22→25:3 · 25→29:4 · 29→30:1. H1–H6 arası yalnız not/anlatı (İlk sabah H1, Tek kişilik şirket H3, Çalışan parçalar H4).
Yalnız GERÇEK seçimli (≥2 açık seçenek) kâğıtlar: H6, H12, H16, H18, H20, H22, H22, (H29 görülmedi), H29, H30 → en uzun sessizlik H22→H29 = 7 hafta (arada yalnız tek seçenekli Frank H25, Q2 raporu H27, Veri Modeli keşif notu H28). İlk 5 hafta da gerçek kararsız.
Ara bilgi kartları: Q1 raporu H14, Teşekkürler H19 (Zeynep) & H23 (Bilge), Q2 raporu H27, Veri Modeli keşif H28.
Log: "[EvEngine] the floor has found nothing N times running — the quiet pool is too thin (§13.6)" uyarısı 11 kez, N=3→13 (sayaç hiç sıfırlanmadı).
[GÖRÜŞ] Oyuncu olarak sessizlik en çok H22–H29 arasında hissedildi; aynı dönemde sprintler de boştu (Ar-Ge'yi bulamamıştım), oyun "bekleme" gibi geçti.

## Araştırma sorusu 2 — kim gönderiyor
Karar kartları (14): Kurucu/Kendine not ×3 (H6, H12, H20) · Frank Köseoğlu ×3 (H8, H11, H25 — üçü de tek seçenekli) · Sektör Telgrafı ×1 (H14) · Zeynep Güneş/Sultanahmet ×2 (H16, H22) · Bilge Polat/Bakırçay ×2 (H18, H29) · Arda Güneş (çalışan) ×2 (H22, H29-görülmedi) · Destek ×1 (H30).
Notlar/raporlar: Kurucu ×4 (H1 "İlk sabah" [MENTOR rozetli ama gönderen Kurucu], H3, H4, H28) · Muhasebe ×2 (H14, H27) · Zeynep ×1, Bilge ×1 (teşekkür).
[GÖRÜŞ] İlk 12 hafta tamamen Kurucu + Frank (8/8 kart). Müşteri ve çalışan sesi H16'dan sonra geliyor; ondan sonra dağılım iyi. Frank'in üç kartı da "seçimsiz karar".

## Sprint ekranı — takıldığım yerler (özet)
1. İki ayrı "+": modül panelindeki "+" bazen doğrudan ekliyor, bazen yalnız orta listede "EKLENEBİLİR" satırını vurguluyor; orta "+" vurgu yokken hiçbir şey yapmıyor (özellikle hata kartlarında H19, H22, H28 defalarca).
2. Sığmayan kartın "+"sı sessizce no-op (H15 Nakit Akış Tablosu, H18) — "neden eklenemiyor" yazmıyor; "N efor daha sığar" ile çelişiyor.
3. Görüşme kartı eklenince kapasite paydası düşüyor (S1 15→10) — nedeni yazmıyor.
4. "Öneriyi uygula" ne yapacağını söylemiyor; S2'de bir sonraki sprinte kart koydu.
5. Görüşme bitince modül listeden kayboluyor, sonra yeniden aynı "5 kullanıcıyla görüş" kartıyla geliyor (İK: S2 ve S6); görüşmenin ne kazandırdığı hiçbir yerde söylenmiyor.
6. H19–H25 sprintleri neredeyse boş (HIZ 11/36, 9/36, 10/16, 10/38) çünkü yeni kartlar Ar-Ge ile açılıyor; sprint ekranı Ar-Ge'ye yönlendirmiyor. Ar-Ge "1" rozeti H7'den H25'e kadar durdu.
7. Karar öncesi DEVREDEN önizlemesi (H12): cevapsız kâğıdın efor etkisi plana iki satır halinde yazılmış göründü; Test kapasitesi "5/0".
8. "Sprinti başlat" ve "Cevapla" bazen ilk tıklamada tepkisiz (S13, S14, S17; H12 Cevapla).
9. Ar-Ge başlatırken "Kurucu sprintten çıkar; dönene kadar sprint durur" uyarısı çıktı ama sprint durmadı (görüşmeler bitti).

## Kesik / taşan / karışık metinler
- H14 üst bar SIRADAKİ: "Çeyrek bülteni: i… · bu hafta son" (çok erken kesilme) — kare 10.
- Ekip > Görev sütunu: "Defterix Fatura v1.8 üzer…", "v1.9 üzer…" (H23, H25, H27) — kesik.
- Kâğıt açıkken küre düğmesi yanında serif (yedek yazı tipi) "Cevap bekliyor" — kare 04, 21, 23.
- TR/EN karışık etiketler: faz adları "BOOTSTRAP", "TRACTION" (sol üst), "MRR", "BURN", "RUNWAY", "Seed turu", "PM yok", "Operating Partner" (Frank'in unvanı). Ham anahtar (KEY_…) görmedim.
- Q1 raporu: "Kasa $10K → $11K (+$672)" — yuvarlanmış başlık farkla çelişiyor.
- Satış teklifinde "Kapasite 79/50" açıklamasız ve uyarısız (kare yok; H24 Lumen).
- Liste/kart saat tutarsızlığı: Alan adı kartta H6 10:00, listede H7 08:00; Büyüme fırsatı kartta 10:00, listede 00:00.

## Hatalar (game.log)
- "ERROR" / "SCRIPT ERROR" ile başlayan satır: 0.
- WARNING (11 benzersiz satır, aynı mesaj): "[EvEngine] the floor has found nothing N times running — the quiet pool is too thin (§13.6)" N=3,4,…,13; backtrace: _step_floor (scripts/events/core/engine.gd:402) ← daily_tick (engine.gd:83) ← event_gate.gd:172 ← time_manager.gd:419/157/202/189/124/97. Oyun boyunca dağılmış (log satırı 650 → 2742).

## Haftalık günlük (kısa)
- H1: Onboarding, ERP seçimi, S1 Kasa Hareketleri + görüşme. Kasa $10.000, MRR 0.
- H2–H6: S2 Elle Giriş + İK görüşmesi, S3 Stok Sayacı + EN görüşmesi. H6 Alan adı kâğıdı (uzun adres).
- H7: v1.0 yayınlandı. S4 Ön Muhasebe.
- H8: Frank'in tanıştırdığı Bakırçay ile ilk görüşme → $1.200 MRR.
- H9–H11: v1.1, v1.2 (Tekil Bağlantı). İlk ödeme → TRACTION. Ledger H11: kasa $10.168, MRR $1.200.
- H12: Sunucu faturası (kodu düzelt). F5.
- H13: Sultanahmet görüşmesi → $660. İşe alımı erteledim.
- H14–H15: Q1 raporu; çeyrek bülteni düştü (hata). v1.4.
- H16: v1.4 bozuldu (kendin düzelt); Safir görüşmesi kaybedildi; Jr Yazılımcı araması.
- H18: Bakırçay genişledi (+$288); Arda Güneş işe alındı ($3.550).
- H19–H21: v1.5, 8 hata → v1.6. Yazım hatasına kadar (rakibin müşterilerini ara).
- H22: Sultanahmet genişledi; v1.7 bozuldu (sprinti durdur); Alaçatı görüşmesi → $1.200. Ledger H22: kasa $9.219, MRR $2.412. F5.
- H23–H24: Sprintler boş, Arda izinde; Lumen görüşmesi → $1.161.
- H25: Ar-Ge'yi keşfettim (Veri Modeli). Frank'in çeki +$25K/%4. Jr PM araması.
- H27: Selin Güneş işe alındı; Q2 raporu. Kasa $33.862, MRR $4,8K.
- H28: Ar-Ge bitti → Çoklu Entegrasyon kartı; ilk dolu sprint. Selin hemen izinde.
- H29–H30: v1.9 (8 hata kapandı). Sahibi değişti (avukat parası fiyata), Muhasebecileri (bırak). Arda'nın kâğıdı görülmeden düştü. Son: kasa $26.199, MRR $5.173, 4 müşteri. F5.

## Kareler (kareler/)
01_onboarding_koken_yetenek · 02_h1_ilk_sabah_mentor · 03_h1_ilk_sprint_plani · 04_h7_alan_adi_kagit · 05_h8_eski_bir_dost_frank · 06_h8_satis_gorusmesi_bakircay · 07_h8_bakircay_anlasma · 08_h12_sunucu_faturasi_kagit · 09_h12_sprint_devreden_onizleme · 10_h15_ceyrek_bulteni_kagit · 11_h15_kagidin_konusu_kalmadi_BUG · 12_h16_v14_bir_sey_bozuldu_karar · 13_h16_safir_zar_ipucu · 14_h16_safir_anlasma_olmadi · 15_h21_yazim_hatasina_kadar_kagit · 16_h21_sprint12_kapasite_bos · 17_h22_v17_bir_sey_bozuldu_arda · 18_h23_sprint14_yalniz_gorusme_arda_izinde · 19_h24_sprintte_yer_yok_ama_sprint_bos · 20_h25_arge_agaci_veri_modeli · 21_h25_frankin_teklifi_reddet_kilitli · 22_h28_sprint17_dolu_coklu_entegrasyon · 23_h30_sahibi_degisti_kagit · 24_h30_muhasebecileri_kagit
