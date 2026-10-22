# Faz A planı · Hatalar ve hata gösterimi ("Açık hata")

Planlayıcı: Sonnet (xhigh). Tarih: 2026-10-16. Repo: `main` `1faeb82`; çalışma ağacında yalnız editörün yeniden kaydettiği
`project.godot` ve iki tema kirli (bu plan onlara dokunmaz, K7'de tema yeniden üretimi bunları ezer, bkz. Riskler).
(inceleme) Kıdemli inceleme notları `A_INCELEME.md`'de; bu dosyadaki her inceleme değişikliği "(inceleme)" işaretlidir.
Araştırma yok: her sayı kod okumasından ya da `--run-log` ölçümünden gelir. Ölçümler repoya dokunmadan, scratchpad'teki
bir kopyada (`scratchpad/ap_work/proj`) yapıldı; kopyadaki prototip yamaları 4.5'te listeli.

## 0. Özet
1. **Oyuncu tek bir sayı görür: "Açık hata".** Hatalar hat hat dağılır. Hat satırı: "Fatura · 6 açık hata · 3 hesap ↑".
   Düzeltme kartı: "6 hata · 3 hesap · 140 kullanıcı", efor 1, 2 ya da 3. Kart kapanınca **kendi hattının** hataları anında düşer.
2. **Hotfix, düzeltme koşusu, "Kaçırıldı", "Hotfix yayınla" ve bilet başına "ses" gider.** Hatayı yalnız sprintteki düzeltme
   kartı çözer.
3. **Hata satışı ve yatırımcıyı etkilemez.** Dönüşüm, toplantı ihtimali, ana kapı yıldız karışımı, tohum ve Series A sorgusu,
   Meridian uyumu, geri dönüş koşulu hata okumaz. Hata yalnız üç yoldan bedel öder: B2B hesabın memnuniyet hedefi (hesap ayrılır),
   B2C kitle kaybı, ve yavaş, tabanı 0 olan itibar düşüşü (+ var olan DESTEK memnuniyet zararı).
4. **İki sayaç, bilet defteri ve aşınma, hat başına tek bir hata deposuna iner.** Diğer fazlar için adlı tek okuma noktası var
   (5.2). Aşınmada 24 kat fazla sayım **yok** (ölçtüm: haftada +0,336 = 168 × 0,002; karmaşıklık gerçek oyunda zaten hep 0).
   Aşınmayı kaldırmayı öneriyorum: tek işi bildirim akışını beslemekti ve her sürümde sıfırlanıyordu.
5. **Hata nerede doğar:** haftanın tek bir hattında (son iki sürümde kademesi çıkan hatlara 3 kat ağırlık) ve hatalı kapanan
   kartın kendi hattında. B2B'de açık hata ortalamasını yarıya indirdi (45 → 25); fix kartı daha az hat gezer.
6. **Ölçüm (bot, 60 hafta, tohum 7 ve 11):** Hotfix'siz bugünkü motorda B2B gönderimdeki açık hata ortalaması 8 → 35–38'e çıkıyor;
   yeni modelde 25 (küme + yeni hat ağırlığı). B2C'de 5 → 18–21. Önerilen sabitlerle, lider planıyla düzelten botun B2B MRR'ı −%13 /
   −%7, hiç düzeltmeyende −%47; B2C kitlesi −%17 / −%15, hiç düzeltmeyende çöküş. Sabitler "onay bekliyor".
   (inceleme) **Bu, oyuncunun gördüğü sayının üç katına çıkması demek; Erdem'in ilk şikâyeti tam olarak buydu ("o kadar
   fazla ticket geliyor").** Geç B2B'de akış hesap sayısıyla doğrusal büyüyor (170 hesapta ×18, haftada ≈ 25 hata) ve
   düzeltme kartı ancak sprint başında planlanabildiği için kusursuz oyuncu bile sprint başına bir iki haftalık akışı
   açık görür. Bu yüzden plan akışı da yumuşatır: B2B kullanım çarpanının böleni 10 → 25 (tek sabit, gerekçe: aynı
   hatayı çok hesap bildirir, ayrı hata sayısı hesapla doğrusal artmaz). Hedef: botta B2B gönderimdeki açık hata
   ortalaması bugünkünün en çok 1,5 katı (≤ 12). K5'in ölçümü bunu kapılar (8. soru 6).
7. **8 commit** (K1–K8), push yok. Yaklaşık 15 saat ajan süresi (Sonnet kod ≈ 8 saat, Haiku kapı ≈ 3,5 saat, Opus inceleme ≈ 2 saat,
   düzeltmeler ≈ 1 saat). Kayıt şeması 15 → 16 (göç var). ≈ 30 smoke vakası dokunulur, 5 yeni ya da yeniden yazılan vaka.
8. **Dilim sırası, görev yazısındakinden bir noktada ayrılıyor:** Hotfix kalkışı (K2) tek depodan (K3) önce gelir. Sebep: düzeltme
   koşusu eski sayaca yazıyor; önce kalkarsa tek depo işi koşuyu bir daha uyarlamak zorunda kalmaz.
9. **B/C/D/E için arayüz (5.2, 5.7):** açık hata toplamı, hat dökümü, en kötü hat, haftalık değişim ve hattın etkilediği hesap ya da
   kullanıcı sayısı; iki olay seam'i; sürüm kaydında son kapanışın hatalı hatları.
10. **6 açık soru** (8. bölüm, inceleme ile güncellendi). En önemlisi: akışın yumuşatılması (soru 6). "Hata yığını" kartının
    K2'de silinmesi artık soru değil: kartın tek işi düzeltme koşusunu başlatmak, koşu A5 kararıyla kalkıyor (inceleme).

---

## 1. Bugünkü akış

Oyuncunun gördüğü ve yaptığı:

- **İki ayrı hata sayısı vardır ve Hotfix yalnız birini düşürür.** Destek kartında (ofis, sağ üst) "Doğrulanmış N · Gelen M"
  yazar; Hotfix bu N'yi eritir. Satışın, yatırımcının, Kararlılık okumasının ve B2C memnuniyetinin okuduğu öteki sayı, gizli
  "canlı hata", yalnız her sürümde sıfırlanır. Yani Hotfix satışı ya da yatırımcıyı düzeltmez; sürüm çıkarmak hepsini bedava siler.
- **"Hotfix yayınla · 5 düzeltildi" düğmesi sürüm çıkarmaz.** Yalnız koşuyu kapatır; kart, haber, memnuniyet, bildirim akışı
  değişmez. Düzeltme koşusunu başlatan "Hata yığını" olay kartı da var.
- **Sprint ekranında her hata bir bilettir.** Alan satırında "N açık ticket", açık alanda bilet başına "Sesler" satırı (üç kalıp
  başlık), yeteneklerden birinde 3 bilet olunca "!" ve "Acil" kartı. Kart "N ticket kapatır" der; sayılar haftada bir
  güncellenir (bir Hotfix'ten sonra kart hâlâ eski sayıyı söyler).
- **Hotfix hangi hattı düzelttiğine bakmaz:** defterin en eskisini siler. Yeni hata, tohumlu rastgelelikle, kullanım ağırlıklı
  bir hatta düşer (dokunulmamış hatta da düşer).
- **Hatalı kapanan kart:** yayındaysa o hatta bir hata açar. Ürün yayında değilse ve kapanış MVP kapısı değilse hata sessizce
  yok olur (oyuncu hiçbir şey görmez).
- **Hiçbir hatta canlı kademe yokken** (tüm hatlar 0) hasar sürer ama ne bilet ne kart görünür.
- **Kurucu iki yerde sayılır:** sprint kartı olan kurucu, işi olmadığı için aynı anda destek masasında da doğrulama yapar ve
  "müşterilerle ilgileniyor" okunur.
- **Kart düğmeleri** ("+", "→", "çıkar") yalnız fareyle üstüne gelince görünür.

Neden yetersiz: Erdem'in iki şikâyeti kodda bire bir karşılığıyla duruyor: "iki ayrı sayaç" ve "hangi hattın düzeltildiği
bilinmiyor". Üstüne, hata satışı ve yatırımcıyı dolaylı etkiliyor (5.1'deki tablo: 20 okuyucu), itibar/churn/memnuniyet
yoluyla değil.

Ölçülen bugünkü durum (bot, 60 hafta, tohum 7 ve 11): B2C'de açık doğrulanmış hata ortalaması 5,0 ve 4,6 (azami 19 ve 17);
B2B'de gönderim anında ortalama 8,2 ve 7,7 (azami 38 ve 36). Hotfix'i çıkarıp başka hiçbir şeyi değiştirmeyince B2B
gönderim ortalaması 38,1 ve 35,1'e (azami 74 ve 93) çıkıyor.

---

## 2. Hedef akış

Örnek sayılar [ÇALIŞMA]. Ürün adları gerçek hat adlarıdır (ERP: Nakit Akışı, Veri Girişi, Defter, Stok, Fatura; B2C not
uygulaması: Yakalama, Bağlantı, Eşitleme, Editör, Arama; ortak: Entegrasyonlar, Güvenlik & Yetki, Dayanıklılık, Mobil & Erişim).

### 2.1 Hat paneli (Ürün penceresi, SPRINT görünümü, sol sütun)
Alan satırının cümlesi "N ticket" yerine "N açık hata" der. Açık alanda, YAPILANLAR'ın altında, **yalnız hatası olan hatlar** için
tek satır; hatası yoksa bölüm hiç çizilmez (sakin ekran). "Sesler" bölümü ve sayacı tümden kalkar.

```
ALANLAR
┌ Çekirdek                                      ⚠  ˅
│ ■■□ Yeterli
│ Kullanıcılar temel işi yapabiliyor · 9 açık hata
│ YAPILANLAR
│   Nakit Akışı ■□□     Defter ■■□     Stok ■■□     Fatura ■■□
│ AÇIK HATALAR
│   Fatura · 6 açık hata · 3 hesap ↑
│   Stok · 3 açık hata · 1 hesap ↓
│ YAPILABİLECEKLER
│   Fatura düzeltmesi   [Acil]                                  3
│   6 hata · 3 hesap · 140 kullanıcı                         + →
```
- Sayı her zaman yazılır; "↑/↓" o hattın açık hatasının bir önceki haftalık tikin başına göre arttığını ya da azaldığını
  gösterir (eşitse hiçbir şey). Ok bir metin karakteri değil küçük bir ikondur.
- (inceleme) Alan cümlesi bugün "Temel iş sorunsuz yürüyor" ve "Ürün güvenilir çalışıyor" diyebiliyor; yanına "9 açık hata"
  gelince mantık çelişkisi olur. İki cümle yeniden yazılır (6. bölüm: `PRODUCT_AREA_CORE_ENOUGH`, `PRODUCT_AREA_TRUST_ENOUGH`).
- B2B satırı "hesap", B2C satırı "kullanıcı" der: "Eşitleme · 5 açık hata · 300 kullanıcı ↑".
- **Hover ipucu** (kalıcı açıklama yok): B2B "3 hesap ve 140 kullanıcı etkileniyor. En büyük hesap 3★." B2C "300 kullanıcı etkileniyor."
- **En büyük, gözde hesap:** adla gösterilmez. Gerekçe: Erdem "müşteri adı değil sayı" dedi; adı göstermek oyuncuyu "şu müşteriyi
  kurtar" diye el tutmaya kaydırır ve Satış sekmesinde Risk rozeti zaten var. İpucundaki "en büyük hesap 3★" yıldızı yeter
  (bedel: S, yeni durum yok).

### 2.2 Düzeltme kartı
- Ad aynı kalır ("Fatura düzeltmesi"). Etki satırı: B2B "6 hata · 3 hesap · 140 kullanıcı", B2C "5 hata · 300 kullanıcı".
- **Efor hata sayısına bağlı:** 1–2 hata 1 puan, 3–5 hata 2 puan, 6 ve üstü 3 puan (Erdem'in tur 2 önerisi; D gelince rol puanı
  modeline uyarlanır). 3 ve üstü hata "Acil" etiketi ve alan "!" uyarısı verir (eşik bugünkü 3).
- Kartın sayısı **her zaman canlı defterden** okunur: kopya yok, bayat sayı yok. Kart sprinte alındıktan sonra efor, sprint
  başlarken bir kez yenilenir ve koşarken kilitlenir.
- **Kapanışta kendi hattının o andaki bütün hatası düşer**, kartın eforu belirlendikten sonra gelen yeniler dahil (sprint 1–2 hafta
  olduğundan sızıntı küçük; alternatif "yalnız kartın yazdığı sayı düşer" daha karmaşık ve oyuncuya "neden hâlâ 2 hata var" sorusu
  doğurur). Başka hatta dokunmaz. Kartı olmayan hat kendiliğinden temizlenmez.
- SPRINT SONUNDA önizlemesi: "6 hata kapanır" ve kalkan "!" çipi.

### 2.3 Sürüm notu
Düzeltme kartının satırı: "Fatura düzeltmesi · 6 → 0 açık hata". Sonuç cümlesi "6 hata kapandı" (şimdiki "6 ticket kapandı"nın
yerine). Hatalı kapanış sonrası hat 0'a inmediyse sağ taraf gerçek sayıyı yazar ("6 → 1").

### 2.4 Destek kartı (ofis, sağ üst; "Hotfix düğmesi" gidince)
```
▣ Notly v1.4
⛨ DESTEK   7 açık hata ›
```
- Tek sayı. Satıra tıklayınca Ürün penceresi Sprint görünümünde, en çok açık hatası olan hattın alanı **açık** olarak açılır.
  Hover: "En çok açık hata: Eşitleme".
- Düğme, yüzde çubuğu, gerekçe satırı, "Doğrulanmış", "Gelen" ve "kaçırıldı" kalkar. 0 hata: "0 açık hata" (sönük).
- "Gelen bildirim" sayısı **oyuncudan gizlenir** (doğrulama bir saat içinde: ölçülen B2C'de 54 haftalık örnekte gelen yığın yalnız masa kurulmadan önceki 8. ve 9. haftada
  4 ve 7, sonrasında hep 0). Birikmesi hâlâ memnuniyet zararını ve ısınma bandını besler; "Yetişemedim: N cevapsız" satırı C'nin haftalık
  raporundadır (gelen yığınını okur, adlar 5.7). Ucuz yedek: gelen ≥ 20 (ısınma bandı) olunca soluk bir
  ek satır (8. soruya konmadı, gerek çıkarsa).
- Kartın üst satırı ("Notly v1.4"), "Ekip iki işte" notu ve "kendiliğinden başladı" satırı olduğu gibi kalır.

### 2.5 Hata nasıl doğar (oyuncu diline)
- **Kullandıkça:** ürün yayındayken kullanıcılar bildirim yollar; bir hafta içinde doğrulanan **bütün yeni hatalar aynı
  hatta** düşer. Hat, kullanıcı kullanımı ağır olan ve son iki sürümde kademesi çıkan hatlar öne çıkacak biçimde seçilir
  ("yeni yazdığın kod bozulur"). Haftalık raporda (C) "en çok sorun çıkan hat" bu yüzden bir anlam taşır.
- **Testsiz kapanış:** test aşamasını testçi olmayan kişi yapan kart %40 ihtimalle hatalı kapanır (D bunu testçiye bağlayacak);
  hata kartın **kendi hattına** düşer. Ürün henüz yayında değilse hata saklanır ve v1.0'da o hatta düşer (bugünkü sessiz
  yok oluş kalkar).
- Hata kendiliğinden çözülmez ve kendiliğinden artmaz (aşınma yok); yığılma, düzeltmemekten ve kullanıcı/kod büyümesinden gelir.

### 2.6 Hatanın hayata etkisi
- **B2B:** her hesabın memnuniyet hedefinden, hesabın kullandığı hatlardaki açık hata × 0,5 (en çok 20 puan) düşer. Hedef
  hesabın saklı toleransının altına inerse bugünkü Risk → sayaç → ayrılma makinesi çalışır. İlk 4 hafta onboarding tabanı
  korur. Risk kartı sebebi "sık kesinti şikayeti" olur (hesabın kendi hatları 6'yı geçince).
- **B2C:** kitle her saat, açık hatanın 3'ü geçen kısmı (en çok 40) kadar çok küçük bir oranla erir (haftada hata başına ≈ %0,03;
  ödeyen kullanıcı da eridiği için MRR düşer; katsayı 5.4). DESTEK memnuniyet zararı (doğrulanmış −0,3 / 10 / gün) olduğu gibi kalır; eski "5'i geçince −7" itişi kalkar.
- **İtibar:** haftalık tikte açık hata 10'u geçiyor ve o hafta hiç düşmediyse itibar −1 (tabanı 0). Üst barda sayı olarak görünür.
  (inceleme) İtibar oyunda yalnız olay kartlarıyla ±1–4 oynuyor ve çoğu koşuda 0 civarında duruyor; tabanı 0 olan kural yalnız
  kazanılmış itibarı siler, çoğu koşuda hiç işlemez. Taban 0 kalmak zorunda: itibar 0'ın altına inerse yatırımcı "itibar"
  sorusunu sorar (`vc_pitch_system.gd:1145, 1193`). Ihmalin asıl genel bedeli memnuniyettir (B2C'de ağızdan ağıza büyüme,
  B2B'de hesap hedefi). 8. soru 5.
- **Satış ve yatırımcı etkilenmez:** dönüşüm, toplantı ihtimali, yıldız karışımı, VC sorgusu, term sheet uyumu hata okumaz.

Örnek (bot, [ÇALIŞMA], tablo 4.3): lider planıyla düzeltilen B2B ürünü MRR'ı %7–13 az bitirir, hiç düzeltilmeyen %47 az; B2C kitlesi
sırasıyla %15–17 az ve çöküş. Kısa ihmalde (1–2 sprint) yalnız eşiği ince olan hesaplar Risk'e girer.

### 2.7 Kart düğmeleri
"+", "→", "↑", "çıkar" tuşları sprint, sonraki sprint ve devreden kartlarda **hep görünür, sönük**; fare kartın üstüne gelince
kartın hover kenarı gibi parlar. Aday kartlar (tuşları zaten hep açık) değişmez.

### 2.8 Kalkanlar
Destek kartının eylem düğmesi ve gerekçe satırı, "Hotfix yayınla" etiketi, "hata düzeltmeyi başlat" önerisi (Sprint ekibi satırı
"2 kişi boşta · hata düzeltmeyi başlat"), "Kaçırıldı" cümlesi, bilet başına "ses", "N ticket" metinleri, "Hata yığını" kartı,
"Düzeltme başlar" olay çipi.

**Dokunulmayan:** "Ekip boşken saat boşa akıyor" (karar 9: Erdem onayı bekleniyor); kurucunun destek masası sayımına dair düzeltme
(K1) bu maddeyle karıştırılmasın, o saat değil sayımdır. **Kapsam dışı:** acil durum olayları (B), Genel Bakış ve haftalık rapor (C),
testçi ve hatalı kapanış ihtimali (D), pazaryeri (E).

---

## 3. İzlenebilirlik

| Madde | Nasıl karşılandı | Yer |
|---|---|---|
| Defter A1 · İki sayaç birleşir | hat başına tek hata deposu; ikinci sayaç, bilet defteri ve aşınma silinir | 5.2, K3 |
| A1 · Hata satış dönüşümünü ve yatırımcıyı etkilemez | hatayı okuyan 20 yer tek tek (kes / kalsın / churn) | 5.1, K5 |
| A1 · Churn'ü etkiler (B2B hesap, B2C kullanıcı) | B2B hesap memnuniyet cezası; B2C kitle kaybı | 2.6, 5.3, K5 |
| A1 · İhmal edilen ürünün memnuniyeti ve itibarı düşer | destek memnuniyet zararı (var) + itibar kuralı (taban 0); katsayılar onay bekliyor | 5.3, 5.4, 4.2 |
| A2 · Kart kendi hattının hatasını siler, liste her kapanışta güncel | kapanışta hat sıfırlanır; kartlar defterden canlı okunur | 2.2, 5.3, K3, K4 |
| A2 · Yeni hata bozulan hatta düşer | haftanın hattı + yeni kod ağırlığı; hatalı kapanış kartın hattına | 2.5, 5.3, K3 |
| A3 · Kurucu çift sayılmaz | destek masası sayımı sprint kartını okur; kurucunun durumu "ürün yapıyor" okunur | K1 |
| A4 · Karmaşıklık hesabı ve ölü kodu silinir | karmaşıklık hesabı, hata riski ve sabitleri silinir; 24 kat sayım doğrulandı: yok | 4.1, 5.6, K8 |
| A5 · Hotfix düğmesi, düzeltme koşusu kodu, "Kaçırıldı", "Hotfix yayınla" | tümü silinir (Hata yığını kartı dahil) | 2.8, 5.6, K2 |
| A6 · Kart sayı yazar, müşteri adı değil | "6 hata · 3 hesap · 140 kullanıcı"; B2C "5 hata · 300 kullanıcı"; "%4 sipariş" yok | 2.2 |
| A6 · Gözde hesap | adla gösterilmez, ipucunda "en büyük 3★" (öneri) | 2.1, 8. soru 3 |
| A6 · Efor 1/2/3 | hata sayısına göre basamaklar ayar dosyasında | 2.2, 5.3 |
| A7 · Hat başına tek satır, sayı her zaman yazılır | "AÇIK HATALAR" satırları | 2.1 |
| A8 · Kart düğmeleri sönük, hover'da parlar | K7, yeni tema varyasyonları | 2.7 |
| A9 · Ekip boşken saat akar: dokunma | dokunulmadı | 2.8 |
| A10 · Liste kısa kalması | hata artık hat başına deponun kendisi; "hatta canlı kademe yok" durumu ortadan kalkar | 5.2 |
| A10 · Yayında olmayan hatalı kart sessiz düşmesin | yayın öncesi saklanır, v1.0'da düşer | 2.5, 5.3, K4 |
| Görev §5.1 · Etkilenen hesap/kullanıcı kuralı | alıcı tipi ekseni; kitle payı | 4.4, 5.3 |
| Görev §5.2 · Etki zinciri tablosu, itibar çelişkisi | 5.1 ve 4.2 | |
| Görev §5.3 · Hotfix sonrası birikim ölçümü | tablo 4.3 | |
| Görev §5.4 · Destek satırı | tek sayı + tıkla | 2.4 |
| Görev §5.5 · Sesler | tümden kalkar, araştırma cümlesi alan cümlesine taşınır | 2.1, 6 |
| Görev §5.6 · 24 kat doğru mu | hayır, oran takvim saati başına doğru kalibre; ayrıca kaldırılıyor | 4.1 |
| Görev §5.7 · Kayıt şeması | şema 16 göçü | 5.5 |
| Görev §7 · Adlı tek okuma noktası | iki adlı işlev (toplam ve hat dökümü) | 5.2 |
| ORTAK · Sesler sınırı | A bilet başına sesi ve bölümü kaldırır; C kendi "Sesler"ini kurar | 2.1 |
| ORTAK · Hatalı kapanan kart | A hatayı bozulan hatta düşürür; sürüm kaydı B için hatalı hatları taşır | 2.5, 5.7 |
| Erdem · "satış dönüşümü ve yatırımcı etkilenmemeli" | okuyucu tablosu ve yeni bir smoke vakası (0 ve 50 hatada aynı sonuç) | 5.1, 7 |
| Erdem · "rastgele hataları silmemeliyiz" | düzeltme kartı yalnız kendi hattını siler | 2.2 |
| Erdem · "ölü kod temizlenebilir" | K8 | 5.6 |
| (inceleme) Erdem tur 1 · "o kadar fazla ticket geliyor ki bug çözme işi anlamsız kalıyor" | yüzey: bilet başına 6 yer → 1 sayı + hat satırı; düzeltme "6 → 0" görünür; hacim: B2B akış böleni 25, K5 kapısı ≤ 12 | 0 (madde 6), 4.3, 8. soru 6 |

Karşılanamayan madde yok. Görev yazısının "bot Hotfix kullanıyor, kart'a çevirmek gerekecek" notu: bot zaten sprint
önerisi (lider) üzerinden düzeltme kartı alıyor; Hotfix bloğu çıkarılır (5.8).

---

## 4. Araştırma bulguları (kod ve ölçüm)

### 4.1 Aşınma ve karmaşıklık (görev §5.6)
- `ProductSystem._post_ship_wear_hourly` oranı **takvim saati başınadır** (dosya başlığı, `product_system.gd:9-11`; ACIK_KARARLAR
  45: "1.000 kullanıcı haftada ~0,3"). Saatlik tik yedi takvim saati taşır, `per_tick` ×7 uygular; 24 saatlik tik × 7 × oran =
  haftada 168 × oran. Ölçüm (prototipte aşınma geri açılıp izlendi): haftalık artış **+0,336** = 168 × 0,002 (taban). 24 kat fazla sayım yok.
- Karmaşıklık: aynı ölçümde her örnekte `cplx=0` (`mvp_components` yalnız debug'da yazılıyor), oran her örnekte `WEAR_FLOOR`
  0,002, QA uzmanlığı 0,00. Karmaşıklık terimini silmek bugünkü oyunu **değiştirmez**. Test uzmanlığı bugünkü gerçek oyunda
  yalnız 20 bin kitleli B2C'de aşınmayı düşürür (0,04 → 0,01); aşınma kalkınca Test'in canlı etkisi D'ye (testçi hata ihtimalini
  düşürür) kadar yoktur.
- Aşınma ve `0,05 × canlı hata` taşınan terimi: GDD §9 formülündeki "taşınan hata", sprint motorunda **0'dır** ("sprintte gizli
  hata devri yoktur", `sprint_system.gd:1092`); aşınma sonradan bu terime kaynak olsun diye eklendi (ACIK 45). Ben terimi
  kaldırıyorum: açık hata sayısı akışı beslerse hata hata doğurur (geri besleme: 0,05 × hata × kullanım çarpanı, 11 kat kullanımda
  hata sayısı iki günde ikiye katlanırdı). Ölçümde terimsiz akış 20 bin kitlede günde 1,8–6 bildirim (bugün 2,8–10,5), küçük
  kitlede (hafta 11–35) bugünküyle aynı: 0,2–1.
- Bildirim akışı kaldırılan terimle birlikte `(0,2 + 0,03 × yeni kod × e^(−yaş/3)) × kullanım × altyapı` olur (GDD §9'un
  taşınan hata terimi 0'lanmış hâli).

### 4.2 İtibar okuyucuları (görev §5.2)
`GameState.reputation` (−10..100) yalnız şuralarda okunur: B2C kitle büyümesi `sales_system.gd:188` (itibar × 0,01 / saat, yani
itibarın her puanı haftada ≈ 1,7 kullanıcı), VC sorgusu `vc_pitch_system.gd:1145, 1193` (`itibar < 0` ise "itibar" sorusu),
olay seam'i `finance.reputation`. **Satış dönüşümü ve B2B hesap hedefi okumaz.** VC sorgusu önemli: 3. perdede sorgu "temiz" ise
zorluk Kolay'dır, aksi hâlde duruşa göre zor (`vc_pitch_system.gd:1258`), yani anlatı odaklı fonda `itibar < 0` toplantı ihtimalini düşürür.
Çözüm: itibar düşüşünün **tabanı 0** (negatife olay iter, ihmal itmez); B2C büyümesi itibar kadar yavaşlar (küçük, üst barda
görünür). Bu, "dolaylı etkiyi küçük ve görünür tut" seçeneğidir; itibarı okuyuculardan ayırmayı gerekli bulmadım.

### 4.3 Hata birikimi (görev §5.3); bot, 60 hafta, tohum 7 / 11

| Senaryo | Açık hata ort. (azami) | Sonuç |
|---|---|---|
| **B2C bugün (Hotfix var)** | 5,0 (19) / 4,6 (17) | kitle 20,2k / 20,1k |
| B2C yeni model, hata etkisi kapalı | 19,4 (79) / 21,2 (74) | kitle 15,6k / 19,1k |
| **B2C yeni model, önerilen sabitler** | 18,2 (57) / 18,5 (67) | kitle 13,0k / 16,2k (−%17 / −%15) |
| B2C hiç düzeltme yok | 63,8 (118) / 57,7 (107) | kitle 0,5k / 0,4k |
| **B2B bugün** (gönderimde) | 8,2 (38) / 7,7 (36) | 173 / 163 hesap, MRR 114,6k / 133,3k, ayrılma 7 / 24 |
| B2B yalnız Hotfix kalkar | 38,1 (74) / 35,1 (93) | 166 / 146 hesap, MRR 109,7k / 94,9k |
| B2B yeni model, hata etkisi kapalı | 27,1 (97) / 27,2 (64) | 178 / 164 hesap, MRR 106,2k / 124,2k, ayrılma 11 / 21 |
| **B2B yeni model, önerilen sabitler** | 25,0 (97) / 24,9 (64) | 162 / 156 hesap, MRR 92,0k / 115,0k (−%13 / −%7), ayrılma 30 / 35 |
| B2B hiç düzeltme yok | 138 (422) / 168 (519) | 104 / 113 hesap, MRR 56,2k / 65,7k (−%47 / −%47), ayrılma 81 / 79 |

Okuma:
- Düzeltme kartı tek yoldur ve ölçek bakımından yeterlidir: kart eforu hat başına en çok 3, yani bir hattaki 60 hata da 3
  puana temizlenir. Birikim sorunu "hata sayısı" değil "hattı seçmek"tir; bu yüzden hataları haftalık tek hatta kümeledim.
  B2B'de küme + yeni hat ağırlığı açık hata ortalamasını 41–46'dan 22–26'ya indirdi (ölçüldü, aynı kod, kümesiz).
- **Sayılar okunur kalıyor.** Lider planı (varsayılan öneri) altında hat başına tipik 3–15 hata; hiç düzeltilmezse yüzlere çıkar
  ama o durumda zaten kasıtlı ihmaldir ve satır "Fatura · 142 açık hata · 120 hesap" diye okunur.
- **Doğrulamanın anında olması sorun değil:** gelen yığın ölçülen 54 haftanın 52'sinde 0 (yalnız masa kurulmadan önceki 8. ve 9. haftada 4 ve 7); doğrulama okurları (masa + kartsız
  herkes) bir saat içinde işliyor. Sonuç: "bildirim" aşaması oyuncuya görünmeyen bir ara adım olur. Yığın ancak herkes
  sprint kartındayken birikir, o durum C'nin "Yetişemedim" satırıdır.
- Bu tablo sabitleri seçmek için; botun düzeltme politikası insan değildir (lider planının kapasiteye sığdırdığını alır).
  ~~Gerçek oyuncu özenliyse ortalama açık hata 5 civarı kalır ve etki ihmal edilebilir.~~ (inceleme) Bu iddia ölçümle
  desteklenmiyor ve akış hesabıyla çelişiyor: düzeltme kartı yalnız sprint başında planlanır, kapanışta hattı sıfırlar; sprint
  sürerken gelen hatalar bir sonraki sprinte kadar açık kalır. Kusursuz oyuncunun alt sınırı "haftalık akış × sprint uzunluğu"dur;
  geç B2B'de bu 25–50'dir. Bot acil kartları zaten zorunlu alıyor (eşik 3, kümelemeyle her haftanın hattı acile döner), yani
  ölçülen 25 ortalaması ihmalden değil akıştan geliyor. Kalibrasyon turunda bot özenli oyuncuyu da taklit etmeli (5.8).
- ~~Ucuz önlem **gerekmedi**.~~ (inceleme) **Ucuz önlem gerekli.** Geç B2B'de bildirim akışı `1 + hesap/10` çarpanıyla büyür
  (170 hesapta ×18, haftada ≈ 25 hata). Önlem: `SupportSystem.USAGE_DIV_B2B` 10 → 25 (GDD §9 sabiti, tek satır; 170 hesapta
  ×7,8, haftada ≈ 11). Açık hata ortalaması akışla orantılı olduğu için 25 → ≈ 12 beklenir [ÇALIŞMA]; K5 ölçümü doğrular. B2C
  çarpanına (`USAGE_DIV_B2C` 2000) dokunulmaz: E pazaryerinde B2C kitlesini yeniden kuruyor ve çarpanı orada gözden geçiriyor (5.7).
  Önemsiz hatanın sayılmaması ya da doğrulamanın yavaşlatılması önerilmez: ikisi de yeni durum ister ve sayıyı değil yalnız
  görünümü küçültür.

### 4.4 Etkilenen hesap ve kullanıcı kuralı (görev §5.1)
- **Veri:** `Customer` sektörü (`industry`), koltuk (`seats`) ve yıldız (`scale`) taşır; modül/talep verisi hesapta yok
  (`pain_feature_id` tek istek). Hat başına sektör ilgisi yazılmış içerik yok; eklemek yeni içerik demek.
- **Kural (öneri):** `SalesArchetypes` zaten üç alıcı tipinin eksen ağırlığını taşıyor (ops: Kararlılık 0,55 · Deneyim 0,30;
  teknik: Yenilik 0,50 · Kararlılık 0,30; finans: Deneyim 0,45 · Kararlılık 0,40) ve hatların ekseni var (ERP: Defter
  Kararlılık, Stok/Fatura Deneyim, Nakit Akışı/Veri Girişi Yenilik). Hesap bir hattı **sektörünün tipi o eksene ≥ 0,25 ağırlık
  veriyorsa** kullanır. 13 sektör eşit olasılıkla çıkarsa: Defter tüm hesaplar, Stok/Fatura ≈ %77, Nakit Akışı/Veri Girişi ≈ %23.
  Deterministik, yeni içerik yok, hat ile sektör arasında anlam taşıyor. "Kullanıcı" = o hesapların koltuk toplamı.
- **B2C:** kullanıcı = kitle × (1 + hattın canlı kademesinin kullanım ağırlığı) / Σ(1 + ağırlık) (bugünkü bilet dağıtım ağırlığı).
  9 canlı hatta ortalama %11: 2.700 kitle → hat başına ≈ 300.
- Tür tablosunda sektörü arketiplerde olmayan hesaplar (sağlık, tekstil, medya) varsayılan arketipe (`ops_cautious`) düşer; bu
  zaten `SalesArchetypes.DEFAULT_ID`.

### 4.5 Ölçüm yöntemi ve prototip yamaları
Repo'ya dokunulmadı; `scratchpad/ap_work/proj` kopyasında `--run-log=full_run_b2c:60:sim:<tohum>` ve `full_run:60:sim:<tohum>`
(tohum 7 ve 11; ayrı APPDATA). Yamalar (harness/prototip, commit'e girmez): bot Hotfix bloğu çıkarıldı; `start_fix_run` hep false;
`live_bug_count` = doğrulanmış sayaç; aşınma kapalı; bildirim akışında taşınan terim yok; dönüşüm hata çarpanı 1; `shipped_composite`
ham eksenler; `axis_reading` −2/hata yok; B2B hedef: ham Kararlılık − min(0,5 × hesabın hatları, tavan); B2C kitle kaybı terimi;
yeni hata hattı = haftanın hattı (ağırlık × 3 son iki sürüm); düzeltme eforu 1/2/3. Not: acil eşiğini oynatmak ve bota ek düzeltme
kartı eklettirmek sonucu değiştirmedi (lider zaten acil düzeltmeleri alıyor, ek kart kapasite kuralına takılıyor); "özenli oyuncu"
senaryosu bot ile üretilemedi, 5.8'de açık iş.

### 4.6 Diğer bulgular
- `product.bug_pile` yalnız düzeltme koşusunu başlatıyor (`bug_pile.json` seçenek `fix_now` → `fix_run_start`); koşu giderse
  kart çalışmaz (inceleme: K2'de silinir, A5'in parçası). Ölçümde botun olay cevabı 0 ("Düzeltmeye başla") olduğundan kart koşuyu kendiliğinden başlattı; bot
  koşuyu bitirmediği için ilk Hotfix'siz B2C ölçümlerim geçersizdi ve `start_fix_run`'ı prototipte kapatıp yeniden ölçtüm.
- Destek kartı ve HUD saatlik yenilemeyi **aşınmanın `build_progress_changed` sinyalinden** alıyor (tek saatlik emitter). Aşınma
  gidince sinyalin emitter'ı `ProductState.add_bugs / clear_line_bugs` olur; Ürün penceresi de bu sinyali dinlemeli (şimdi yalnız
  `product_state_changed`).
- Ar-Ge `cicd` (`bug_rate_ceil`) ve `test_automation` (`beta_decay`) düğümlerinin etkileri kodda bağlı değil; `bug_tracker`
  (doğrulama katsayısı) ve `self_service` (akış tabanı) bağlı ve kalır. Hiçbiri aşınmaya bağlı değil.
- `ProductSystem.health_state`, `bug_trend`, `product_bug_risk`, `mvp_bug_history` gerçek oyunda çağrılmıyor (yalnız smoke).
- `PRODUCT_CUSTOMER_TICKETS` dalı (`area_panel.gd:236`) ölü: müşteri satırı yalnız açık talebi olanı listeliyor.
- Sprint probe bugün `match=245/251`, tüm uyuşmazlıkların adı var (`product.sprint_late`, `team`); kapı sıfır adsız uyuşmazlık ister.

---

## 5. Model

### 5.1 Hatayı bugün okuyan her yer ve yeni durumu
(L = `mvp_live_bug_count`, C = `mvp_bugs_confirmed`, O = yeni açık hata)

| # | Okuyan (dosya:satır) | Bugün | Yeni | Gerekçe |
|---|---|---|---|---|
| 1 | `support_system.gd:172` bildirim akışı | L × 0,05 | **kalkar** | hata hata doğurmaz; GDD §9'da bu terim sprintte 0 |
| 2 | `support_system.gd:273` günlük memnuniyet zararı | C × −0,3/10 | **kalır**, O | B2C genel memnuniyet kanalı. B2B'de hesap sayısına bölünür (100 hesapta hesap başı ≈ −0,07), yani B2B'nin asıl kanalı satır 7. (inceleme) B2C memnuniyeti ağızdan ağıza büyümeyi sürer (`sales_system.gd:197-199`): bu yeni kullanıcı gelişini yavaşlatır, dönüşüm oranına dokunmaz. Erdem'in "memnuniyet ve itibar düşebilir" cümlesinin karşılığıdır; satış dönüşümü sayılmaz |
| 3 | `sales_system.gd:33,424` B2C memnuniyet itişi | L > 5 → −7/tik | **kalkar** | uçurum; memnuniyet 54'ten 47'ye inince ağızdan ağıza bileşimi (puan − 30) ≈ %30 kısalır; zarar (2) zaten orantılı |
| 4 | `sales_system.gd:106,467` dönüşüm çarpanı | L × %2 | **kalkar** | "satış dönüşümü etkilenmez" |
| 5 | `quality_model.gd:109-112` `economy_dims` Kararlılık erimesi → kitle büyümesi (`sales_system.gd:184`), ürün değeri/fiyat (`:439`), rakip sıralaması, imza açılış memnuniyeti (`:410`), B2C tohumu (`:243`) | L × 0,8 | **kalkar** (ham eksenler) | pazar yüzü hata okumaz; ayrıştı: hata B2B'de satır 7'ye, B2C'de satır 8'e gider |
| 6 | `quality_model.gd:233` `axis_reading` Kararlılık −2/C → toplantı ihtimali (`sales_meeting_system.gd:141`), ana kapı kalitesi (`sales_faucet_system.gd:171`), `urun.axis_stability` olayları | C × −2 | **kalkar** | aynı gerekçe. Yan etki: `b2c_floor_*`, `launch_leak` olayları hata duyarlılığını kaybeder (B isterse `urun.open_bugs` okur) |
| 7 | `b2b_sales_system.gd:136` B2B hesap memnuniyet hedefi | L (eriyen Kararlılık) | **yeni:** ham Kararlılık − min(0,5 × hesabın hatları, 20) | B2B churn kanalı; onboarding tabanı üstte |
| 8 | `sales_system.gd:204` B2C kitle büyümesi/kaybı | — | **yeni:** saatlik `2e-6 × min(max(0, O − 3), 40) × kitle` | B2C churn kanalı |
| 9 | `b2b_sales_system.gd:504`, `inbox.gd:211` risk sebebi | C ve L (ACIK 39: iki kural) | hesabın kendi hatları > 6 (`COMPLAINT_BUG_GATE`) | tek kural |
| 10 | `product_system.gd:177,184` sağlık, hata riski | L | **silinir** | çağıranı yok |
| 11 | `vc_pitch_system.gd:1149` tohum sorgusu "nasıl büyür" | L > 0 | yalnız en zayıf eksen | yatırımcı etkilenmez |
| 12 | `vc_pitch_system.gd:1199` Series A ürün sorgusu | L > 0 → "hata kaynıyor" | **silinir** | sorgu "temiz" kalır (Kolay) |
| 13 | `vc_pitch_system.gd:493,503,1291` geri dönüş koşulu "Aktif hata < 3" | L | **"En zayıf eksen > 40"** (8. soru 4) | hata koşulu yatırımcıya dönmez |
| 14 | `term_sheet_table_system.gd:62,549` Meridian ±6 | L | **silinir** | |
| 15 | `sales_probes.gd:62,135,145`, `sales_meeting_system.gd:340`, `sales_ledger.gd:338` satış sorusu "açık hata", kayıp nedeni, yeniden sunum kapısı | C | **silinir** (satır `probe_stability_bugs`, kapı terimleri; kayıp nedeni yalnız eksen) | satış etkilenmez |
| 16 | `build_bar_model.gd:50` Destek kartı | C | O | tek sayı |
| 17 | `sprint_bridges.gd:19-61` bilet defteri, `sprint_catalog.gd` bilet okuyucuları | C + bilet satırları | **silinir**, hat sözlüğü | tek depo |
| 18 | `rnd_system.gd:595-603` Ar-Ge notunun talep satırı | hat başına bilet sayısı | `open_bugs_by_line()` | aynı oy kuralı |
| 19 | `product_read.gd:37,154`, `seams_product.gd:90`, `b2c_refunds.json:39` | C | `urun.open_bugs` | aynı eşik (8) |
| 20 | itibar | — | **yeni yazar:** `SupportSystem.daily_tick` (haftalık) | 4.2. (inceleme) İtibarın okuyucuları doğrulandı: B2C kitle büyümesi (`sales_system.gd:188`), VC sorgusu (yalnız `< 0`, `vc_pitch_system.gd:1145, 1193`); `finance.reputation` seam'ini okuyan kart yok. Taban 0 ile yatırımcıya sızıntı yok |
| 21 | (inceleme) `vc_pitch_system.gd` kayıtta bekleyen `bugs_under` geri dönüşü | L | `_migrate_16` bekleyen `bugs_under` koşulunu yeni eksen koşuluna çevirir | eski kayıt silinen türü okumasın |

Hata sayısına **hiç bağlanmayan** ve dokunulmayanlar: marka (`brand`), Ar-Ge düğümleri, `urun.bugs_unconfirmed` seam'i, sunucu aşım
zararı (`InfraSystem.satisfaction_delta_per_day`).

### 5.2 Depo ve okuma noktası
- **Durum:** `GameState.flags["mvp_open_bugs"]` (`TYPE_DICTIONARY`, `{hat_kimliği: int}`, yalnız n > 0) ve
  `mvp_open_bugs_prev` (önceki haftalık tikin başındaki hâl, okların tek kaynağı). JSON'da sayılar float döner; okuma `int()` ile.
- **Okuma (ProductState, ürünün tek canlı okuma evi):**
  - `open_bugs() -> int` (toplam)
  - `open_bugs_by_line() -> Dictionary`
  - `worst_bug_line() -> String` (en çok hata; eşitlikte etkilenen kullanıcı, sonra hat kimliği; yoksa "")
  - `open_bugs_delta(line := "") -> int` (şimdi − önceki)
  - `ProductRead.open_bugs()` olay yüzeyi (bugünkü `confirmed_open`'ın adı); seam `urun.open_bugs`, yeni `urun.worst_line_bugs`.
- **Yazma (tek kapı, WRITE-THROUGH):** `ProductState.add_bugs(hat, n)`, `ProductState.clear_line_bugs(hat) -> int`,
  `ProductState.snapshot_open_bugs()` (`ProductSystem.daily_tick` çağırır; mevcut `mvp_bug_history` örneğinin yerini alır). Yazma
  `build_progress_changed` yayar.
- **Etki okumaları:** `SprintCatalog.line_impact(hat) -> {accounts, seats, top_star}` (B2B) ya da `{users}` (B2C);
  `B2BSalesSystem.account_bugs(hesap)`; ortak yüklem `SalesArchetypes.uses_axis(sektör, eksen)` (≥ 0,25). `tick_requests`taki
  arketip döngüsü aynı yüklemden geçer (kopya kod yok).
- (inceleme) **B, C ve E'nin ihtiyacı olan dört küçük ek** (her biri birkaç satır; yoksa her faz aynı türetmeyi kendisi yazar):
  - `ProductState.line_bugs(hat) -> int` (tek hattın açık hatası; B `open_bugs(line)` diye arıyor).
  - `SprintCatalog.line_accounts(hat) -> Array[Customer]` (hattı kullanan hesaplar; `line_impact` sayılarını bundan türetir.
    B'nin kesinti ve güven bedeli hesap listesine yazar, sayıya değil).
  - `SprintCatalog.line_share(hat) -> float` (B2C kitle payı, `(1 + ağırlık) / Σ(1 + ağırlık)`; E'nin `MarketplaceSystem.affected`
    bu payı okur).
  - `EventBus.line_bugs_cleared(hat: String, n: int)`: `clear_line_bugs` yayar (B'nin açık olayı hattın düzeltmesi çıkınca kapanır).
  - `SprintCatalog.bug_line()` hattı seçerken `ProductState.line_blocked(hat)` yüklemini sorar; A'da hep false döner, B'nin
    `line_harden` fiili onu doldurur (aşınma kalktığı için B'nin "aşınmadan yeni hata düşmez" cümlesi buna bağlanır).
  - Hat satırının metni, ipucu ve oku tek fonksiyonda kurulur (`ProductModel.bug_row(hat) -> {text, tip, delta}`); C'nin Genel
    Bakış'ı ve haftalık raporu aynı fonksiyonu çağırır.
- **Silinen depolar:** `mvp_bugs_confirmed`, `mvp_live_bug_count`, `mvp_live_bug_progress`, `mvp_bug_history`, `product.tickets`,
  `product.ticket_seq`, `product.voices_seen`. `product.gate_faulty` → `product.pending_faulty` (anlamı genişler).

### 5.3 Formüller
1. **Organik doğum:** her saat doğrulanan her bildirim bir açık hata olur (`SupportSystem.hourly_tick`). Hat: `SprintCatalog.bug_line()`
   = canlı hatlar arasında ağırlıkla seçim, `r = hash(run_seed, hafta) % toplam`, ağırlık = (1 + kullanım ağırlığı) × (3 eğer hat son
   iki sürümde kademe yükseltmişse). Aynı hafta içindeki bütün yeni hatalar aynı hatta düşer. Kod: yaklaşık 15 satır.
2. **Hatalı kapanış:** `_go_public` kartın hattına `add_bugs(hat, 1)`. Ürün yayında değilse `pending_faulty`'ye yazılır; `publish()`
   v1.0'da düşürür (her sessiz yok oluş kalkar).
3. **Düşüş:** düzeltme kartı `_close`'ta `clear_line_bugs(hat)` ile hattı sıfırlar; kartın `bugs_before` / `bugs_after` alanı sürüm
   notuna yazılır. Kart biletsiz ("0 hata") artık sürüm çıkarmaz.
4. **Efor:** `fix_effort(n)`: n 1–2 → 1, 3–5 → 2, ≥ 6 → 3 (`sprint.json` `fix_effort`: `{"steps": [3, 6], "points": [1, 2, 3]}`).
   Başlamamış (aday, planlı, devreden) kartlar her günlük tikte ve kapanışta defterden yenilenir; 0 hataya düşen kart silinir;
   sprint başlarken bir kez daha yenilenir. Koşan kartın eforu kilitlidir.
5. **Acil eşiği:** hat başına 3 açık hata ("!" ve "Acil"); `sprint.json` `urgent_tickets` → `urgent_bugs`.
6. **Etki puanı** (lider önerisi): düzeltme kartı `ticket × n + alert` → `bug × n + alert` (aynı ağırlıklar, `sprint.json` `impact`).
7. **B2B hesap hedefi:** `hedef = clamp(ham Kararlılık skoru + güven defteri − min(0,5 × b, 20), 0, 100)`, `b` = hesabın kullandığı
   hatlardaki açık hata toplamı. Onboarding tabanı (`max(sağlık, tolerans + 2)`) cezadan sonra uygulanır.
8. **B2C kitle:** `kitle_delta/saat −= BUG_CHURN_COEF × min(max(0, O − 3), 40) × kitle`.
9. **İtibar:** her haftalık tikte (SupportSystem.daily_tick), `O > 10` ve `O ≥ önceki hafta O` ise `set_reputation(max(0, itibar − 1))`.
10. **Satış/yatırımcı:** hiçbiri hata okumaz (5.1 satır 4–6, 11–15).

### 5.4 Sabitler (hepsi "onay bekliyor"; [ÇALIŞMA] işaretli olanlar ölçümle seçildi)
| Sabit | Değer | Yer | Not |
|---|---|---|---|
| `fix_effort` basamakları | 3 / 6 → 1 / 2 / 3 puan | `sprint.json` | Erdem'in tur 2 önerisi; D uyarlar |
| `urgent_bugs` | 3 | `sprint.json` | bugünkü eşik |
| Yeni hat ağırlığı | 3 (son 2 sürüm) | `SprintCatalog` | [ÇALIŞMA] ölçüldü |
| Haftalık kümeleme | açık | kural | ölçüldü (45 → 25) |
| `USE_AXIS_MIN` | 0,25 | `SalesArchetypes` | |
| `B2B_BUG_SAT_PER` / `_CAP` | 0,5 / 20 puan | `B2BConstants` | [ÇALIŞMA] 0,5/12 hafif, 1/15 sert denendi |
| `COMPLAINT_BUG_GATE` | 6 (artık hesap başına) | `B2BConstants` | var olan değer |
| `B2C_BUG_CHURN_COEF` / izin / tavan | `2e-6` / 3 / 40 | `SalesSystem` | [ÇALIŞMA] 1e-6, 2e-6, 4e-6 denendi |
| `NEGLECT_BUGS` / itibar adımı | 10 / −1 hafta, taban 0 | `SupportSystem` | ölçülmedi |
| VC geri dönüş eşiği | En zayıf eksen > 40 | `PitchConstants.CALLBACK_AXIS_MIN` | `_weakest_dimension`'ın 40'ıyla aynı |
| (inceleme) `USAGE_DIV_B2B` | 10 → 25 | `SupportSystem` | B2B akışı; hedef: bot B2B gönderim açık hata ortalaması ≤ 12. K5 ölçer; hedef tutmazsa sayı Erdem'e rapor edilir, sessizce oynatılmaz |

Davranış kuralları da onay bekliyor: hatlara kümeleme, kartın kapanışta hattın tamamını silmesi, yayın öncesi hatalı kapanışın
saklanması, aşınmanın kalkması, gelen bildirimin oyuncudan gizlenmesi.

**Silinen sabitler:** `SATISFACTION_BUG_PUSH_PER_DAY`, `SATISFACTION_BUG_GATE`, `BUG_CONV_COEF`, `BUG_CONV_FLOOR`, `BUG_STABILITY_COEF`,
`CONFIRMED_BUG_READING_COST`, `INFLOW_CARRIED_COEF`, `WEAR_AUD_COEF`, `WEAR_CPLX_COEF`, `WEAR_TECH_REDUCER`, `WEAR_FLOOR`,
`FOUNDER_EXPERTISE_WEIGHT`, `BUG_HISTORY_WEEKS`, `TREND_*`, `HEALTH_EFF_STAB_RATIO`, `BUG_RISK_*`, `FIX_COEF`, `E_FIT_PRODUCT_BUGS`,
`CALLBACK_BUGS_UNDER`, `effort.fix_urgent`.

### 5.5 Kayıt şeması
`SaveManager.SCHEMA_VERSION` 15 → **16**, `MIN_LOADABLE_VERSION` 10 aynı. `_migrate_16(state)`:
- `mvp_open_bugs` ← `product.tickets` satırlarını `line`'a göre say; `mvp_bugs_confirmed` satır sayısından fazlaysa fazlayı canlı
  hatlara sırayla (hat sırasıyla) dağıt; sonra `mvp_bugs_confirmed`, `mvp_live_bug_count`, `mvp_live_bug_progress`, `mvp_bug_history`,
  `mvp_fix_run_*`, `mvp_reports_week_net` anahtarlarını sil.
- `mvp_open_bugs_prev` ← aynı sözlük; `product.tickets`, `ticket_seq`, `voices_seen` sil; `gate_faulty` → `pending_faulty`.
- Göç zinciri sırayla çalışır (… 14, 15, 16). `_migrate_15`'in kurduğu ürün durumunda bilet yoktur (`SprintSystem.new_state` artık
  bilet alanı taşımaz); v10–14'ten gelen kayıtta 16 yalnız `mvp_bugs_confirmed` sayısını dağıtır.
- `GameState.FLAG_TYPES`: silinen anahtarlar kalkar, `mvp_open_bugs` ve `mvp_open_bugs_prev` `TYPE_DICTIONARY` eklenir.
- Kayıt etkisi: eski bir kayıtta gizli canlı hata (L) **taşınmaz** (oyuncuya görünmeyen sayaç, her sürümde sıfırlanıyordu).
- (inceleme) Göç K3'te kurulur (C, bilet defteri, ses kayıtları). L anahtarları (`mvp_live_bug_*`, `mvp_bug_history`) ve bekleyen
  VC `bugs_under` geri dönüşleri K5'te **aynı** `_migrate_16`'ya eklenir: push'tan önce tek şema numarası, ara commit'ler yayına
  çıkmaz. D şemayı 17 alır.

### 5.6 Silinecek kod ve ölü kod
- **K2 (Hotfix):** `SupportSystem.start_fix_run/end_fix_run/fix_run_refusal/can_start_fix_run/fix_per_day`, `REFUSAL_*`, `FIX_COEF`, koşunun `_drain`
  çağrısı; `ProductState.FIX_RUN_*`, `fix_run_active/fixed`, `REPORTS_WEEK_NET`, `reports_missed`; `EventBus.fix_run_started/finished`;
  `effects.gd` `fix_run_start` fiili (`:43,439`), `chips.gd:44`, `lint.gd:323,341`; seam'ler `destek.can_start_fix_run`,
  `destek.fix_run_active`; `data/events/cards/product/bug_pile.json` (+ `tools/lint_v3_frozen.json` satırı, 5 `EV_PRODUCT_BUG_PILE_*`
  anahtarı); `build_bar.gd` düğme/yüzde/gerekçe, `build_bar_model.gd` `fill/percent/decision*/refusal_key/fix*/missed`;
  `product_model.gd:254` `PRODUCT_IDLE_FIX` dalı; bot `_run_the_company` düzeltme bloğu; `main.gd` `fix_run` ve `desk_shut` çekimleri;
  dizgiler `PROD_FIX_RUN_START/END`, `FIX_RUN_REFUSED_NO_BUGS`, `PRODUCT_IDLE_FIX`, `BUILD_SUPPORT_CONFIRMED/INCOMING/MISSED`,
  `EFFECT_FIX_RUN_STARTS`, `PROD_TIP_BUGS` (zaten ölü).
- **K3 (tek depo):** `ProductState.BUGS_CONFIRMED`, `bugs_confirmed`, `adjust_confirmed`;
  `SprintBridges.sync_tickets/close_tickets/add_faulty_ticket/_next_ticket_id`; `SprintCatalog.tickets_by_line`, `ticket_title`,
  `voices` içindeki bilet döngüsü; `_refresh_fix_cards` bilet kopyası. (inceleme) C'yi okuyan ve K5'te kesilecek yerler
  (`b2b_sales_system.gd:504`, `support_system.gd:273`, `quality_model` `axis_reading` çağrıları) K3'te `ProductState.open_bugs()`'a
  döner; böylece her commit kendi başına derlenir ve oynanır.
- (inceleme) **Aşınma ve L K3'ten K5'e taşındı:** `ProductSystem._post_ship_wear_hourly`, `live_bug_count`, `hourly_tick`
  (+ `TimeManager:427` çağrısı), `_is_free/_founder_on_build/_team_area_avg`, `mvp_live_bug_*`, `_go_public` içindeki L sıfırlaması
  ve akışın taşınan terimi K5'te, L'nin bütün okuyucularıyla birlikte silinir. Sebep: L'yi K3'te silmek, okuyucuları K5'te
  kesileceği için K3'e geçici bir köprü ister ve K3'ü (≈ 25 dosya) daha da büyütür; L'nin okuyucuları ile yazarı aynı commit'te
  gider. K3 ile K5 arasındaki ara durum bugünkü oyundur (L ayrı, aşınmayla yürür).
- **K5 (etki zinciri):** (inceleme) yukarıdaki aşınma/L listesi; `USAGE_DIV_B2B` 25; `QualityModel.effective_stability/economy_dims_from_flags/CONFIRMED_BUG_READING_COST` (ve `shipped_composite`
  ham eksenlere geçer), `SalesSystem` L okuyan dallar, satır 11–15 kesimleri ve ilgili dizgiler (`VC_Q_BUGS*`, `HUNT_CB_BUGS`,
  `SALES_PROBE_PROBE_STABILITY_BUGS`, `SALES_ANS_PROBE_STABILITY_BUGS_*`, türev kilit satırları).
- **K6 (görünüm):** `SprintCatalog.voices`, `PRODUCT_VOICES*`, `PRODUCT_NEW_*`, `PRODUCT_FX_VOICES_*`, `PRODUCT_TICKET_0..2`,
  `PRODUCT_RIVAL_VOICE`, `PRODUCT_AREA_TICKETS*`, `PRODUCT_FX_TICKETS_*`, `PRODUCT_CUSTOMER_TICKETS*`, `AreaPanel` Sesler bölümü ve
  müşteri kartı bilet dalı, `ProductModel` `voices`/`tickets`, `SprintUiShared.VOICES/BUG` sabitleri ve `voices.svg` varlığı, sekmenin
  `voices_open`/`voices_seen` yolu, `SprintSystem.voices_seen`.
- **K8 (ölü kod):** `ProductSystem.bug_trend/health_state/product_bug_risk` ve sabitleri, `_shipped_total_complexity`; `ProductState.is_feature_live`'ın
  `mvp_components` okuması DOKUNULMAZ (söz kaydı ve 11 smoke vakası bağımlı); `b2b_sales_system.gd:446` düz havuz yolu (yalnız çizgisiz
  alt-türlerde çalışır) aynı sebeple DOKUNULMAZ ve K8 raporunda "ölü olabilir, ayrı iş" diye notlanır. `PRODUCT_IDLE` dizgi ailesi kalır.
  (inceleme) T2_2 B5'e göre `:446` gerçek oyunda "hiçbir şey canlı değil" görüyor ve zaten çıkmış bir yeteneği söz olarak
  verebiliyor; bu bir oyun hatası. Rapor notu yetmez: K8 bunu `ACIK_KARARLAR`'a madde olarak yazar.

### 5.7 Diğer fazlara arayüz
| Faz | A'dan okuyacağı | Not |
|---|---|---|
| B | `ProductState.open_bugs()`, `open_bugs_by_line()`, `worst_bug_line()`, seam `urun.open_bugs`, `urun.worst_line_bugs`; `release.faulty` (son kapanışın hatalı hatları); hatalı kapanış zaten kartın hattına açık hata yazar. (inceleme) Ayrıca `ProductState.line_bugs(hat)`, `ProductState.add_bugs(hat, n)`, `SprintCatalog.line_impact(hat)` / `line_accounts(hat)`, `EventBus.line_bugs_cleared(hat, n)`, `ProductState.line_blocked(hat)` (B'nin `line_harden`'ı doldurur) | "Sürüm sonrası bozulma" tetikleyicisi: B kendi seam'ini ekler. `product.bug_pile` A'da (K2) silinir (inceleme: soru değil, A5'in parçası) |
| C | aynı okuma noktaları, `open_bugs_delta()`, `SprintCatalog.line_impact()`; Genel Bakış'taki Destek bloğu Destek kartının "N açık hata" satırına bağlanır, yeniden yazmaz; "Yetişemedim" `reports_incoming()`. (inceleme) Hat satırı `ProductModel.bug_row(hat)`; hesap başına terim `B2BSalesSystem.account_bugs(c)` × `B2BConstants.B2B_BUG_SAT_PER`, tavan `_CAP` (C'nin `target_terms` 2. terimi); 1. terim artık ham Kararlılık | Destek kartının tıklama davranışı (`ProductTab.open_area(hat_alanı)`) C'nin "Sprint'te düzelt" bağı için de kullanılır. (inceleme) C kendi `product_view_requested` sinyalini kurunca bu tıklama o sinyale taşınır |
| D | düzeltme kartı eforu tamsayı `effort` olarak kalır (1/2/3); rol puanı modeli onu yeniden ifade edebilir. (inceleme) Basamaklar `sprint.json` `fix_effort` (`effort.fix` ve `effort.fix_urgent` silinir); hatalı kart `_go_public`'te `add_bugs(kart.hattı, 1)` ya da v1.0 öncesi `pending_faulty` | `faulty_chance` 0,4 A'da değişmez; D testçiye bağlar. (inceleme) Smoke `sprint_faulty_ticket_deterministic` K3'te `sprint_faulty_bug_on_card_line` olur; D bunu `sprint_escape_by_tester`'a çevirir. Şema: A 16, D 17 |
| E | `SprintCatalog.line_impact` B2C kolu bugün `SalesSystem.b2c_audience()` okur; E pazaryeri kitlesini yazınca bu satır E'nin sayısına bağlanır. (inceleme) E'nin "A'nın payı" `SprintCatalog.line_share(hat)`'tır; hat başına sayı `ProductState.line_bugs(hat)` | `urun.usage` çarpanı (`1 + kitle/2000`) E ile birlikte gözden geçirilir. (inceleme) B2B böleni A'da 25'e çıkar, B2C'ninki E'ye kalır |

### 5.8 Bot ve harness (ayrı raporlanır)
`scripts/debug/run_probe.gd`: `_run_the_company`'deki düzeltme koşusu bloğu (`:1104-1122`) ve `_fix_on_at/_fix_off_at/_fixer_id` silinir;
`PROBE B2C` satırında `live_bugs=`/`confirmed=` yerine `open_bugs=`; `PROBE SHIP` satırında `bugs=` kalkar, `tickets=` → `open_bugs=`.
Bot düzeltme kartlarını zaten lider önerisiyle alıyor (acil olanlar zorunlu). Kalibrasyon turunda eklenmesi önerilen tek bot
değişikliği: sprint planında açık hatası olan her hat için düzeltme kartı eklemeyi dene (özenli oyuncu kolu; bugünkü `FIXBOT`
denemem sığmayan karta `add` reddedildiği için etkisizdi, kapasite kuralı bot tarafında gevşetilmeli).

---

## 6. Metin taslakları (TR/EN onay bekliyor; önce EN, tire yok, `Fmt.count_key` ile `_ONE` ikizleri)

| Anahtar | EN | TR | Yer |
|---|---|---|---|
| `PRODUCT_BUGS` | Open bugs | Açık hatalar | Sprint hat paneli bölüm başlığı |
| `PRODUCT_BUG_COUNT` / `_ONE` | {n} open bugs / {n} open bug | {n} açık hata | hat satırı, alan cümlesi, Destek kartı |
| `PRODUCT_ACCOUNT_COUNT` / `_ONE` | {n} accounts / {n} account | {n} hesap | hat satırı, kart |
| `PRODUCT_USER_COUNT` / `_ONE` | {n} users / {n} user | {n} kullanıcı | hat satırı, kart |
| `PRODUCT_FX_BUGS` / `_ONE` | {n} bugs / {n} bug | {n} hata | düzeltme kartı etki satırı |
| `PRODUCT_FX_BUGS_CLOSED` / `_ONE` | {n} bugs close / {n} bug closes | {n} hata kapanır | SPRINT SONUNDA |
| `PRODUCT_FX_BUGS_FIXED` | {from} → {to} open bugs | {from} → {to} açık hata | sürüm notu kart satırı |
| `PRODUCT_BUGS_TIP_B2B` | (inceleme) {accounts} and {users} are affected. The largest account is {stars}★. | {accounts} ve {users} etkileniyor. En büyük hesap {stars}★. | hat satırı ipucu |
| `PRODUCT_BUGS_TIP_B2C` | (inceleme) {users} are affected. | {users} etkileniyor. | hat satırı ipucu |
| (inceleme) `PRODUCT_AREA_CORE_ENOUGH` (değişir) | Users can get the basic job done | Kullanıcılar temel işi yapabiliyor | alan cümlesi; eski "sorunsuz yürüyor" açık hata sayısıyla çelişiyordu |
| (inceleme) `PRODUCT_AREA_TRUST_ENOUGH` (değişir) | Backups and access control are in place | Yedek ve yetki yerinde | alan cümlesi; eski "güvenilir çalışıyor" açık hata sayısıyla çelişiyordu |
| `BUILD_SUPPORT_TIP` | Most open bugs: {capability} | En çok açık hata: {capability} | Destek kartı satırı ipucu |
| `PRODUCT_RESULT_BUGS_EXPECTED` / `_ONE` | {n} bugs should close / {n} bug should close | {n} hata kapanmalı | sürüm sonucu |
| `PRODUCT_RESULT_BUGS_ACTUAL` / `_ONE` | {n} bugs closed / {n} bug closed | {n} hata kapandı | sürüm sonucu |
| `HUNT_CB_AXIS` | Weakest axis > {n} | En zayıf eksen > {n} | Series A geri dönüş koşulu |

Değişmeyen: `PRODUCT_FIX_CARD` ("{capability} düzeltmesi"), `BUILD_PHASE_SUPPORT`, `PRODUCT_URGENT`, `PRODUCT_RESEARCH_VOICE_*` (artık alan cümlesinin
sonuna, araştırmadan sonraki iki hafta boyunca eklenir; Sesler bölümü yok).

**Silinen anahtarlar (K2/K5/K6):** `PROD_FIX_RUN_START`, `PROD_FIX_RUN_END`, `FIX_RUN_REFUSED_NO_BUGS`, `PRODUCT_IDLE_FIX`, `BUILD_SUPPORT_CONFIRMED`,
`BUILD_SUPPORT_INCOMING`, `BUILD_SUPPORT_MISSED`, `EFFECT_FIX_RUN_STARTS`, `PROD_TIP_BUGS`, `EV_PRODUCT_BUG_PILE_TITLE/FIX/LATER/LOCK_FIX/EXPIRED`,
`PRODUCT_AREA_TICKETS(_ONE)`, `PRODUCT_TICKET_0..2`, `PRODUCT_VOICES`, `PRODUCT_VOICES_COUNT(_ONE)`, `PRODUCT_NEW_COUNT`, `PRODUCT_NEW_STAMP`,
`PRODUCT_FX_TICKETS_CLOSE(_ONE)/CLOSED(_ONE)`, `PRODUCT_FX_VOICES_CLOSE(_ONE)/CLOSED(_ONE)`, `PRODUCT_RIVAL_VOICE`, `PRODUCT_CUSTOMER_TICKETS(_ONE)`,
`PRODUCT_RESULT_TICKETS_EXPECTED/ACTUAL(_ONE)`, `HUNT_CB_BUGS`, `VC_Q_BUGS`, `VC_Q_BUGS_MONO`, `SALES_PROBE_PROBE_STABILITY_BUGS`,
`SALES_ANS_PROBE_STABILITY_BUGS_A_ADMIT/A_PROMISE/A_REFERENCE` (ve türev kilit satırları, varsa).
"ticket" kelimesi oyuncu metninden tümden çıkar (izinli ödünç listesinde yoktu; glossary satırı da silinir).

Glossary (`docs/design/localization_glossary.md`): satır 68 (ticket), 78 (düzeltme koşusu), 79 (hata düzeltme/hotfix), 80 (kaçırılan
bildirim) silinir; "açık hata ↔ open bug", "hesap ↔ account" satırı eklenir.

---

## 7. Uygulama dilimleri

Her commit öncesi sıra: `--event-lint` → `loc_residue` → `smoke_run.sh loc_csv_integrity` → aşağıdaki hedefli vakalar → (varsa) görsel kabul.
~~Tam smoke yalnız push öncesi (kural).~~ (inceleme) Tam smoke koşulmaz: Erdem 2026-10-06, "push et" doğrudan push demektir,
öncesinde tam smoke yok; push yalnız Erdem'in sözüyle. Yeni vakalar falsification ile kanıtlanır (rapora yazılır). Metni değişen dilimlerin (K2, K4, K5, K6)
commit mesajı "TR/EN onay bekliyor" taşır; tasarım sabitleri raporda "onay bekliyor" altında listelenir.

| Dilim | Ne | Dokunulan dosyalar | Kapı |
|---|---|---|---|
| **K1** Kurucu çift sayılmaz | `founder_passive_care` sprint kartı olan kurucuyu dışlar; `founder_task_state` kartlı işsiz kurucuyu BUILD okur (aksi hâlde "Boşta" yalanı çıkar) | `support_system.gd`, `hr_system.gd`, smoke | `hotfix_founder_takes_support_desk` (genişler), `support_desk_rates_stack`, `hotfix_account_count_excludes_base`, `destek_empty_desk_piles_up`, `sales_meeting_time_skip_founder_share`; yeni `founder_on_sprint_not_on_desk` |
| **K2** Hotfix kalkışı | düzeltme koşusu, düğme, "Kaçırıldı", `bug_pile`, seam/fiil/çip/sinyal, dizgiler, bot bloğu; Destek kartı eylem satırı olmadan "Doğrulanmış N · Gelen M" gösterir (K3'te tek sayıya iner) | 5.6 K2 listesi; `_vocabulary.md` (`--event-vocab`), `EVENT_SIGNAL_MANIFEST.md` (`gen_signal_manifest.py`), motor md §27 notu | `--event-lint`, `loc_*`, `destek_survives_ship`, `destek_empty_desk_piles_up`, `product_read_catalogue`, `save_v10_product_state`, `event_beat_freezes_seams`, `event_chip_coverage`; `fix_run_ships_subset` silinir; `--run-log` B2B/B2C 30 hafta; `plausibility_run.sh`; `--office-shot=home:12:desk_shut` (yeniden yazılı: düğmesiz kart) |
| **K3** Tek hata deposu | `mvp_open_bugs` + okuma/yazma + `snapshot` (inceleme: + 5.2'deki dört ek); bildirim → hat; hatalı kapanış → kartın hattı; kart kapanışı hattı sıfırlar; C ve bilet defteri silinir, C okuyucuları `open_bugs()`'a döner (inceleme: aşınma ve L K5'e taşındı); şema 16; sinyal emitter'ı; Destek kartı tek sayı (tıklama K6'da); `SprintCatalog` okuyucuları sayıya geçer (metinler eskisi gibi, K6'ya kadar); `rnd_system` oyu; seam yeniden adı | `product_state.gd`, `product_system.gd`, `support_system.gd`, `sprint_bridges.gd`, `sprint_system.gd`, `sprint_catalog.gd`, `game_state.gd`, `save_manager.gd`, `rnd_system.gd`, `product_read.gd`, `seams_product.gd`, `b2c_refunds.json`, `build_bar(_model).gd`, `time_manager.gd`, `run_probe.gd`, `main.gd` tohumları, `product_fixtures.gd`, ≈ 20 smoke vakası | `sprint_*`, `save_v14_*`, `save_v10_product_state`, `rnd_note_author_and_lines`, `destek_*`, `b2b_*` fikstürleri; yeni `save_v15_tickets_become_open_bugs`, `sprint_fix_card_clears_its_line` (eski `sprint_fix_card_closes_tickets`'ın yerine); `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` (adsız uyuşmazlık 0); ~~`--run-log` 60 hafta ×2 pazar ×2 tohum, açık hata ve MRR bu plandaki tabloyla karşılaştırılır~~ (inceleme) `--run-log` B2B ve B2C 30 hafta, tek tohum, yalnız hatasız bitiş; ölçüm karşılaştırması bir kez, K5'te (Erdem'in 2026-10-11 kuralı: ölçüm turu tekrarlanmaz). `time_manager.gd` ve `main.gd`'nin L tohumları K5'e geçer |
| **K4** Düzeltme kartı | efor basamakları, canlı sayı, etkilenen hesap/kullanıcı (`line_impact`, `uses_axis`), kart etki satırı, SPRINT SONUNDA, sürüm notu kartı ("6 → 0"), `pending_faulty`, `release.faulty`, `bugs_before/after`, `area_alert`/`impact`/`forecast` hat sayısına geçer, `fix_effort` | `sprint_catalog.gd`, `sprint_system.gd`, `sprint_bridges.gd`, `sales_archetypes.gd`, `sprint.json`, `product_model.gd`, `sprint_ui_shared.gd`, `product_fixtures.gd` | `sprint_*`, `line_*`, `product_*`; yeni `sprint_faulty_pre_launch_lands_at_v1`; `--sprint-probe` (plan = kapanış, adsız uyuşmazlık 0); `--product-shot=edge:bugs` (yeni fikstür) |
| **K5** Etki zinciri | 5.1 tablosu satır 1–9, 11–15, 20, 21: kesimler, B2B hesap cezası, B2C kayıp, itibar, kalite okuması; (inceleme) aşınma ve L'nin silinmesi (K3'ten taşındı), `USAGE_DIV_B2B` 25, `_migrate_16`'ya L anahtarları ve `bugs_under` | (inceleme) `product_system.gd`, `time_manager.gd`, `main.gd` L tohumları, `save_manager.gd`, `quality_model.gd`, `sales_system.gd`, `b2b_sales_system.gd`, `b2b_constants.gd`, `support_system.gd`, `vc_pitch_system.gd`, `term_sheet_table_system.gd`, `pitch_constants.gd`, `sales_probes.gd`, `sales_meeting_system.gd`, `sales_ledger.gd`, `inbox.gd`, `run_probe.gd`, ≈ 15 smoke vakası, dizgiler | `b2b_lifecycle_and_countdown`, `b2b_onboarding_grace_floor`, `b2b_ignore_then_churn`, `b2b_satisfaction_leaves_b2c_identical`, `b2c_satisfaction_drifts_to_experience`, `b2b_v1_lands_mid_band`, `risk_exit_stamps_day`, `callback_contract`, `pitch_bug_interrogation` (yeniden yazılır), `sales_loss_reason_from_asked`, `coupling_cs_dampen_axis`, `b2b_cs_absorbs_routine`, `conversion_bug_penalty` silinir; **yeni `bugs_leave_sales_and_vc_alone`** (0 ve 50 hata: dönüşüm, toplantı ihtimali, yıldız karışımı, VC sorgusu ve term sheet uyumu eşit); (inceleme) yeni `save_v15_callback_bugs_under`; `--run-log` ölçümü (60 hafta ×2 pazar ×2 tohum, tek sefer) ve kalibrasyon raporu; **kapı: B2B gönderim açık hata ortalaması ≤ 12** (tutmazsa sayılar Erdem'e gider, sabit sessizce oynatılmaz) |
| **K6** Hat paneli ve Destek kartı görünümü | "AÇIK HATALAR" satırları (inceleme: tek `ProductModel.bug_row`), ipucu, ok ikonları, alan cümlesi (inceleme: iki `_ENOUGH` cümlesi yeniden yazılır), Sesler bölümü ve sayacı silinir, Destek kartı tıklaması, Ürün penceresi `build_progress_changed` dinler | `area_panel.gd`, `product_model.gd`, `product_tab.gd`, `sprint_catalog.gd`, `sprint_ui_shared.gd`, `build_bar(_model).gd`, `sprint.json`, `strings.csv`, `product_fixtures.gd`, `main.gd` çekimleri | `product_*`, `loc_*`; görsel kabul (aşağıda) |
| **K7** Kart düğmeleri | tuşlar hep görünür, sönük; hover'da parlar. Tema: `IconKeyIdle`, `CardKeyTextIdle`, `CardKeysIdle` varyasyonları, `THEME_STAMP` artar, iki tema yeniden üretilir | `sprint_card.gd`, `sprint_ui_shared.gd`, `build_theme.gd`, `ui_tokens.gd`, `themes/*.tres` | `theme_check.gd`, `--theme-contrast-audit`, `--theme-audit=product`; görsel kabul |
| **K8** Ölü kod ve belgeler | 5.6 K8 listesi; `HARITA.md` (Ürün, Satış, Olay, Araçlar), `CLAUDE.md` §6 ve §8, `GUNCELLEMELER.md` (§8.4 maddesi değişir, yeni "Tek hata sayısı" maddesi), motor md §27, ZAMAN MODELİ md tablosu (`bug_pile` satırı), glossary; ACIK_KARARLAR 39 ve 45 kapanır, 99 notlanır (onay sonrası); `docs/audits` dokunulmaz | belgeler, `endgame_smoke.gd` artık vakalar | `loc_residue`, `glyph_audit.gd`, `bash tools/run_gate.sh` (3 koşu, tam), `plausibility_run.sh`, `gen_signal_manifest.py` |

### Görsel kabul senaryoları (CLAUDE.md §11; fikstürle, oyunu baştan oynamadan)
Hepsi `APPDATA` ayrı; ekranlı koşular sırayla.
1. **Hat paneli B2B:** yeni `--product-shot=live:b2b_bugs` (ERP, iki hesap, Fatura 6 ve Stok 3 açık hata tohumlu, Çekirdek açık). Beklenen: "AÇIK HATALAR" iki satır, ok ikonu, alan cümlesinde "9 açık hata", kart "6 hata · 3 hesap · 12 kullanıcı" (tohumlu iki hesap), efor 3.
2. **Hat paneli B2C:** yeni `--product-shot=live:b2c_bugs` ve `--product-shot=edge:bugs`. Beklenen: "Eşitleme · 5 açık hata · N kullanıcı".
3. **Sürüm notu:** yeni fikstür `--product-shot=edge:bugs_release` (düzeltme kartı kapanmış sürüm notu): "Fatura düzeltmesi · 6 → 0 açık hata",
   sonuç satırı "6 hata kapandı". Fikstürler: `edge:bugs` (hat paneli + kart), `edge:bugs_release`; motorla kurulan gerçek koşular `live:b2b_bugs`, `live:b2c_bugs`.
4. **Destek kartı:** `--office-shot=home:12:bugs` (yeni ek; `desk_shut` ve `fix_run` ekleri silinir): "7 açık hata ›", tıkla → Ürün penceresi alan açık (`--office-shot ... :bugs_open` ikinci kare).
5. **Düğmeler:** `--product-shot=live:active` ve `live:plan`: sprint ve sonraki sütun kartlarında sönük tuşlar, hover karesi (`ui.hover_card`).
6. Hepsi `--lang=en`, `--palette=cb`, `--shot-scale=1.25` ile; kontrol: öğe yerinde mi, taşma/kesilme, dil, log hatası. En çok 2 düzeltme turu.

### Riskler
1. **K3 büyük** (≈ 25 dosya, ≈ 20 smoke vakası fikstürü): L/C'yi kuran fikstürler yeni depoya taşınır. `SMOKE PASS` tek başına yetmez (bellek notu): runner motor `ERROR:` ve parse hatası da kapılar; yeni vakalar falsification ile kanıtlanır; ~~K3 inceleme turu iki kez döner~~ (inceleme) commit başına tek Opus incelemesi
   (düzeltme hakkıyla) ve en çok bir düzeltme turu (Erdem 2026-10-11). Aşınma ve L K5'e taşındığı için K3 ≈ 18 dosyaya iner.
2. **Kalibrasyon:** sabitler bot ile seçildi; bot insan değil (düzeltmeyi kapasiteye göre alıyor). Hotfix gidince bot ortalaması 5 → 18–21 açık hata olur; bugünkü bota göre B2C kitlesi 20,2k → 13,0k / 16,2k (−%36 / −%20), bunun bir kısmı hata etkisi kapalıyken bile görünür (15,6k / 19,1k: Hotfix'in gitmesi ve var olan destek zararı). Erdem sabitleri K5 raporunda görür; onaylanana dek commit'e "[ÇALIŞMA]" olarak girer ve kalibrasyon turu özenli oyuncu koluyla yinelenir.
3. **İçerik kesimleri B/D/Erdem alanına temas eder:** `bug_pile` silinir (B'nin kapsamı; inceleme: B planı "A bıraktıysa B siler" diyor, çakışma yok), VC geri dönüş koşulu ve satış sorusu değişir (8. soru 4). Onay çıkmazsa K5'te VC/satış kesimleri ayrı commit'e bölünür.
4. **Test uzmanlığı boşluğu:** aşınma kalkınca Test alanının canlı etkisi (yalnız 20 bin kitleli B2C'de) D'ye kadar yok. Düşük risk, notlu.
5. **Tema yeniden üretimi (K7)** çalışma ağacındaki editör farkını (`project.godot`, iki tema, uid satırları) ezer; commit öncesi sahibin farkı ayrıştırılır (CLAUDE.md: editör farkı onaysız commit'lenmez). K7 yalnız üretilen iki temayı ve ilgili dosyaları sahneler (kısmi staging).
   (inceleme) Ayrıştırma üretimden **önce** yapılır, sonra değil: üretim iki `.tres`'i diskte baştan yazar ve sahipsiz farkı geri
   dönülmez siler. K7'nin ilk adımı: `git diff -- themes/ > <scratchpad>/k7_unowned_themes.patch` ve iki dosyanın kopyası. Bugünkü
   fark yalnız editörün eklediği `uid` satırlarıdır (doğrulandı); editör onları bir sonraki açılışta yeniden ekler. Rapor bunu
   Erdem'e söyler. `project.godot`'a dokunulmaz ve sahnelenmez. `git checkout --` yasak (bellek: paylaşılan ağaçta geri alma).
6. **Seam yeniden adı** (`urun.bugs_confirmed` → `urun.open_bugs`) olay lint'i ve `_vocabulary.md`'yi etkiler; K3 `--event-lint` ve `--event-vocab` ile kapanır.
7. **Olay tabanı sinyalleri:** `b2c_floor_*` ve `launch_leak` Kararlılık okumasının hata terimini kaybeder (5.1 satır 6); `plausibility_run.sh` K2 ve K8'de koşar.
8. **`ProductSystem` küçülür** (aşınma, sağlık, risk, `_is_free` ailesi gider): `coupling_wear_team_average` ve `_is_free` kullanan smoke vakası (`endgame_smoke.gd:2581-2590`)
   kaldırılır ya da yeniden yazılır; Ekip GDD'sindeki "canlı aşınma Test alanının işi" cümlesi K8'de GUNCELLEMELER'e not düşer.

---

## 8. Açık sorular (her biri kapalı uçlu; öneri koyu)

1. **Aşınma (yayındaki ürünün kendiliğinden biriken gizli hatası) kalksın mı?** Kalkarsa bildirim akışı yalnız yeni kodla ve kullanımla gelir; ihmal, düzeltilmeyen açık hata yığını olarak görünür; ACIK_KARARLAR 45 kapanır; Test uzmanlığının canlı etkisi D'ye kadar yok. **Evet, kalksın.**
2. **Yeni hatalar nerede doğsun:** haftanın tek hattında (son iki sürümde kademe çıkan hatlar 3 kat ağırlıkla) mı, her hata ayrı hatta mı? Ölçüm: B2B açık hata ortalaması 45 → 25, düzeltme daha az hat gezer. **Haftanın hattı.**
3. **Etkilenen hesap kuralı:** hesap, sektörünün alıcı tipi hattın eksenine ≥ %25 ağırlık veriyorsa o hattı kullanır; gözde hesap adla değil "en büyük hesap 3★" ipucuyla. Alternatif: tüm hesaplar tüm hatları kullanır (sayı her hatta aynı, bilgi taşımaz). **Sektör kuralı + yıldız ipucu.**
~~4. `product.bug_pile` kartı A'da silinsin mi?~~ (inceleme) Soru değil: kartın tek işi düzeltme koşusunu başlatmak; koşu A5
kararıyla kalkıyor, kart K2'de silinir. B'nin acil durum olayları yerine geçer.
4. **Yatırımcı ve satış:** ürün fonunun "Aktif hata < 3" geri dönüş koşulu yerine "En zayıf eksen > 40" gelsin, "ürünün hata kaynıyor" sorgusu ve satış toplantısındaki "açık hatalarınız var" sorusu silinsin (hata yatırımcıya ve satışa dönmesin)? **Evet.**
5. (inceleme) **İtibar:** "ihmal edilen ürünün itibarı düşer" kuralı tabanı 0'la kalsın mı? İtibar oyunda yalnız olaylarla ±1–4
   oynuyor ve çoğu koşuda 0 civarında; kural yalnız kazanılmış itibarı siler. Taban 0'ın altına inerse yatırımcı "itibar" sorusunu
   sorar, bu da "hata yatırımcıyı etkilemez" kararını deler. Seçenekler: (a) taban 0'la kalsın, nadiren görünür; (b) kalksın,
   ihmalin genel bedeli yalnız memnuniyetten gelsin. **(a): sözünüz karşılanır, yatırımcıya sızmaz, bedeli bir kural.**
6. (inceleme) **Hata akışı yumuşasın mı?** Hotfix gidince botta B2B'de gönderimdeki açık hata ortalaması 8'den 25'e çıkıyor;
   geç oyunda haftada ≈ 25 yeni hata geliyor ve kusursuz düzelten oyuncu bile sprint arasında 25–50 açık hata görür. Bu ilk
   şikâyetinizdeki seldir. Öneri: B2B'de akışın hesap sayısıyla büyümesi yarıdan fazla yavaşlar (bölen 10 → 25; aynı hatayı
   çok hesap bildirir). Beklenen ortalama ≈ 12, K5 ölçer. Alternatifler (önemsiz hatayı saymamak, bildirimi geç doğrulamak) yeni
   durum ister ve sayıyı değil yalnız görünümü küçültür. **Evet, bölen 25.**

---

## 9. Uygulama adım tablosu

Sıralı yürür (tek klasör, tek ağaç). Her dilimde: Sonnet kodlar → Haiku kapıları ve ekranı koşar → Opus kıdemli inceleme (yalnız diff, CLAUDE.md §9) → gerekirse Sonnet/Opus düzeltir → commit. Push yalnız Erdem'in sözüyle.

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| 0 | Planı Opus'a incelet (kod gerçekleri, 5.1 tablosu eksiksiz mi, ölçüm tablosu, dilim sırası); 8. soru cevapları | ana / Opus | Opus | yüksek | 25 dk | Erdem'in kuralı. (inceleme) Yapıldı: `A_INCELEME.md` |
| 0b | Erdem onayı: 6 soru (inceleme), 5.4 sabitleri, 6. metinler | ana | Opus (ana) | orta | Erdem'e bağlı | Karar onun |
| 1a | K1 kod + vaka | alt ajan | Sonnet | xhigh | 20 dk | küçük, iki işlev |
| 1b | K1 kapılar | alt ajan | Haiku | düşük | 10 dk | komut koşusu |
| 1c | K1 inceleme, commit | alt ajan | Opus | yüksek | 10 dk | |
| 2a | K2 kod (Hotfix kalkışı, olay/seam/sinyal/dizgi) | alt ajan | Sonnet | xhigh | 60 dk | çok dosya, mekanik silme |
| 2b | K2 kapılar + `desk_shut` çekimi | alt ajan | Haiku | düşük | 25 dk | event-lint, plausibility, smoke, çekim |
| 2c | K2 inceleme + düzeltme | alt ajan | Opus | yüksek | 25 dk | olay motoru sözleşmesi |
| 3a | K3 kod (depo, kaynaklar, göç, fikstürler; inceleme: aşınma/L hariç, 5.2'deki dört ek dahil) | alt ajan | Sonnet | max | 105 dk | en büyük dilim, çekirdek mantık |
| 3b | K3 kapılar (smoke, sprint-probe, (inceleme) 30 haftalık hatasız bitiş koşusu) | alt ajan | Haiku | düşük | 25 dk | |
| 3c | K3 inceleme + düzeltme (inceleme: tek inceleme, en çok bir düzeltme turu) | alt ajan | Opus | yüksek | 35 dk | kayıt ve write-through riski |
| 4a | K4 kod (düzeltme kartı) | alt ajan | Sonnet | xhigh | 60 dk | |
| 4b | K4 kapılar + `edge:bugs` çekimi | alt ajan | Haiku | düşük | 25 dk | |
| 4c | K4 inceleme | alt ajan | Opus | yüksek | 15 dk | |
| 5a | K5 kod (etki zinciri; inceleme: + aşınma/L silinmesi, `USAGE_DIV_B2B`, göç eki) | alt ajan | Sonnet | xhigh | 90 dk | ≈ 19 dosya, VC/satış içeriği |
| 5b | K5 kapılar + kalibrasyon koşuları (tablo 4.3 yeniden üretilir; inceleme: B2B ≤ 12 kapısı) | alt ajan | Haiku | düşük | 45 dk | koşu toplama |
| 5c | K5 inceleme + sabit raporu | alt ajan | Opus | yüksek | 25 dk | tasarım sabitleri "onay bekliyor" |
| 6a | K6 kod (hat paneli, Destek kartı) | alt ajan | Sonnet | max | 90 dk | UI kanunu, çok yüzey |
| 6b | K6 kapılar + 8 görsel kabul karesi (TR/EN/cb/1.25) | alt ajan | Haiku | düşük | 40 dk | ekran sırayla |
| 6c | K6 inceleme + 1–2 düzeltme turu | alt ajan | Opus | yüksek | 30 dk | |
| 7a | K7 kod + tema (inceleme: önce sahipsiz tema farkının yedeği, risk 5) | alt ajan | Sonnet | xhigh | 25 dk | küçük |
| 7b | K7 kapılar + çekimler | alt ajan | Haiku | düşük | 20 dk | |
| 7c | K7 inceleme | alt ajan | Opus | yüksek | 10 dk | |
| 8a | K8 ölü kod + belgeler | alt ajan | Sonnet | xhigh | 40 dk | |
| 8b | K8 tam kapı (`run_gate.sh`, plausibility, glyph, theme) | alt ajan | Haiku | düşük | 25 dk | |
| 8c | K8 inceleme | alt ajan | Opus | yüksek | 15 dk | |
| 9 | Sonuç raporu: ✅/⚠️/❌ + kanıt, onay bekleyen sabitler ve metinler, ayrı bot/harness raporu | ana | Opus (ana) | orta | 15 dk | CLAUDE.md rapor kuralı |

Toplam ≈ 15 saat ajan süresi; tek tek dilim arası insan bekleyişi yok, Erdem yalnız adım 0b'de karar verir.
