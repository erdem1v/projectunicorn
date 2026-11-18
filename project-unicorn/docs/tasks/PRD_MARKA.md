# PRD · Marka (Marka ve İtibar tek çatıda)

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Üç incelemecinin (URUN, DUZELTME, OLAYLAR) notları işlendi. 1. adım Erdem'in
cevabını beklemez; sonraki adımlar §13'teki cevapları bekler (yardımcı yönetmen, 18 Kasım).
**Durum:** taslak 4, 2026-11-18, PAZARYERI oturumu. Erdem'in beş cevabı işlendi (§0, §13). Bir Opus incelemesinden geçti (on iki şartın hepsi işlendi; model
yeniden kuruldu, §15); DUZELTME'nin iki okuması, ARAYUZ'un notları, URUN'un incelemesi ve OLAYLAR'ın kart incelemesi (iki şart,
beş cevap, beş ek bulgu) işlendi; yeni iniş sırasını yardımcı yönetmen onayladı, OLAYLAR kabul etti (18 Kasım 04:50). 1. adımın
kodu geçici klasörde yazıldı ve incelendi; Godot'ta henüz koşmadı. Sahiplik yardımcı yönetmenin 18 Kasım kararıdır (§11). Kaynak okuması, dört kollu kaynaklı araştırma ve bot kayıtlarıdır;
prototip ve kare yok. Her sayı başlangıç değeridir ve "onay bekliyor" diye iner (§10); sayı ayarı botla ve playtest'tedir.
**Tek cümle:** Üst bardaki iki sayı (Marka ve İtibar) tek bir Marka olur; Marka adlı kaynaklarının toplamına yavaş yavaş yürür
(ürünün kalitesi, müşterinin memnuniyeti, basın ve ödüller, ofis), haberlerin ve yayınların izi hemen yazar ve söner; hepsi
ipucunda satır satır okunur ve Marka yeni müşteriyi getirir: ERP'de aday, pazaryerinde kendiliğinden gelen ziyaret.
**Çıktı:** main'e 8 commit (§11: yedi adım ve olay fiilinin pazaryeri kolu), her biri kendi kapısı, §9 incelemesi ve (görünenlerde) görsel kabulüyle.
**Kapsam:** ERP ve pazaryeri. İşe alıma etki ve rakiplerle karşılaştırma bu PRD'de değil (§14).
**Erdem'in sözü (2026-11-18 ~01:15, yardımcı yönetmenin aktarımı):** "şu anda oyundaki bu bizim marka itibar muhabbetimiz. Zaten
bunu değiştirelim. ... O ikisini tek bir çatı altında birleştirelim. Ya marka yazalım, ya itibar yazalım, ya da daha uygun
olduğunu düşündüğüm bir şey varsa ve bir şeyler etkilemeli bu. Nereden beslenmeli, neyi etkilemeli, oyuncu marka brandingini
yukarıda tutmaya vakit harcamalı ve bunu mesela bir sabit olmaktan çıkarmalıyız. Yani ürünün kalitesine, müşteri memnuniyetine
göre sallıyorum, haftalık değişen bir yapıya getirmek lazım. Yani işte hani EU4'te income'ın artması, azalması gibi."
**Dayanak belgeler** (`docs/tasks/marka/arastirma/`): `1_paradox.md` (S1–S29), `2_spor.md` (S30–S49), `3_sirket_oyunlari.md` (S50–S79), `4_gercek_marka.md`
(S80–S119). Bu PRD'deki `[S#]` o sicillerin numarasıdır; yük taşıyanlar Ek'te. Depo dosyaları bu belgelere atıf yapmaz.

## Erdem için kısa özet

- **Senin cevaplarınla kurulan hâl (18 Kasım):** tek sayı, adı Marka, 0 ile 100 arası.
- **Nereden beslenir (önem sırasıyla, en çok kaç puan):** Ürün kalitesi 35 · Müşteri memnuniyeti 30 · Basın ve ödüller 17,5 ·
  Pazarlama 10 · Ofis 7,5. Kaybedilen müşteri Marka'ya ayrıca yazmaz.
- **Yavaş yürür.** Kaynakların toplamı Marka'nın gideceği yerdir; Marka her hafta aradaki farkın sekizde birini kapatır (bir
  çeyrekte büyük kısmını). Kaynak değişince yönü aynı hafta görünür: kart kaynakların toplamını ve Marka'nın oraya ne kadar
  vardığını yan yana yazar, üst barda haftalık değişim işaretiyle durur.
- **Haber ve yayın beklemez.** Lansman, büyük imza, ödül, kötü haber ve TV ya da radyo yayını Marka'ya o hafta yazar, sonra
  söner (beş haftada yarıya iner). TV yayınının etkisi yavaş yürüyüşte kaybolmaz.
- **Para Marka'yı almaz.** Parayla alınan tek şey yayındır ve en küçük paydır (en çok 10 puan); ofis oturdukça küçük bir pay
  verir (en çok 7,5). Kalan 82,5 puan ürünün, müşterinin ve basının hâlidir.
- **Ne getirir:** ERP'de aday (Marka 50'de haftada +2; bugünkü İtibar'ın işi). Pazaryerinde kendiliğinden gelen ziyaret: Marka
  0'da ×0,7, 25'te ×1, 50'de ×1,3, 100'de ×1,9. Arama reklamının yeri Marka'yla büyür. Yatırımcı görüşmeleri aynı sayıyı okur.
- **Oyuncu ne yapar:** yeni kademe çıkarır (ürün kalitesi), hatayı ve desteği ihmal etmez (memnuniyet), tek pazarlama yerini
  reklama ya da basına verir, büyük imzayı ve lansmanı haber yapar, seed'den sonra isterse yayın alır.

## 0. Kararlar

- **Erdem (18 Kasım, ilk söz):** iki sayı tek çatıda; bir yerden beslenir, bir şeyi etkiler; sabit değil, haftalık değişir; oyuncu
  onu yukarıda tutmak için emek harcar; değişim EU4'ün gelir dökümü gibi okunur.
- **Erdem (18 Kasım, beş cevap; yardımcı yönetmenin aktarımı):** ad: "Marka olsun." Hız: "Bence B" (yavaş yürüsün). Para:
  "parayla işimiz olmamalı. Yani burada en önemli şey basın bizi nasıl görüyor? Müşteri memnuniyeti en önemlisi bence. ...
  Basın, aldığımız ödüller ... ve marketing. Parayla alakası olmaması lazım." Sıra: "Bir, en önemlisi ürünün kalitesi. İki,
  müşteri memnuniyeti. Üç, pazarlama. Marketing en ufak payı. Maksimum %10'luk payı hatta %5'lik payı ya da %7,5'luk payı
  ofisten gelsin." Kayıp: "Kaybedilen müşteri markaya yazmasın. Zaten müşteri kaybediyorsak ya ürün negatif bir şey alıyordur."
- **Yardımcı yönetmen (18 Kasım):** ağırlık sırası ürün kalitesi > memnuniyet > basın ve ödüller > pazarlama; ofis küçük ve
  kalıcı bir kaynak, oturdukça, en çok 7,5; "para payı" kavramı kalkar; kayıp hesap kaynağı silinir; hız yavaş, yine de kaynak
  değişince yönü görünür; TV yayınının etkisi yürüyüşte kaybolmaz.
- **Benim kararlarım (inceleme ve Erdem değiştirebilir):**
  1. Tek sayı; iki ayaklı (bilinirlik ve itibar) değil (§12).
  2. Marka birikmez: gideceği yer (kaynakların toplamı) her hafta kaynaklardan yeniden hesaplanır ve Marka ona yürür. Saklanamaz,
     "hep 100" olmaz (§1 K7).
  3. Memnuniyetin zaten saydığı şey ikinci kez sayılmaz. Açık hata, cevapsız destek, söz ve bekleyen talep bugün hesabın ve
     kullanıcının memnuniyetine yazıyor; Marka'ya memnuniyet üzerinden girer, ayrı satır olmaz (§2.2).
  4. Tek seferlik iz yalnız seyrek ve herkesin duyduğu anlar içindir (lansman, büyük imza, yatırım haberi, ödül, olay kartı) ve
     haber izlerinin toplamı +12,5'i geçmez (§2.3). Tekrarlayan şey (hata, söz, kayıp) iz yazmaz: kaynaklardan girer.
  5. Okuyanlar oyuncunun gördüğü tam sayıyı okur (§2.1).
  6. İşe alıma etki bu pakette yok (§14).
  7. Var olan sayılar korunur: büyük imzanın +3'ü; yatırımcı reddinin −3'ü; olay kartlarının Marka'ya yazdıkları. Ofisin
     puanları küçülür (2,5; 5; 7,5).
  8. İki sayıyı birden oynatan seçenek tek sayıya inmez: gürültü yarısı Marka izi, güven yarısı memnuniyettir (OLAYLAR'ın
     şartı; §7).
- **Onay bekleyenler:** §10'daki bütün sabitler, §9'daki TR ve EN metinler, §3'teki eşik çevirileri.

## 1. Kurallar (araştırmadan; her biri bir tasarım kararını bağlar)

- **K1 Her değişimin adı vardır.** Software Inc.: "every time no matter what I get a massive loss of reputation with literally
  no info as to why." [S54]; geliştirici sonradan neden etiketi ekledi [S61]. Tavern Tycoon geliştiricisi aynı şikâyete "shows
  exactly why the guest is leaving" ile cevap verdi [S74]. Football Manager'da kulüp itibarının nedenini gösteren bir ekran
  bulunamadı ve soru 2008'den beri soruluyor [S38]: "why isnt my reputation going up ?" (2023) [S37]. EU4'te görüşün nedenleri her
  yerde ipucunda: "Reasons for a nation's opinion of another are displayed in tooltips wherever opinion is shown." [S6].
  → Marka'nın her puanı bir satırdır; haftalık değişimin nedeni başlıkta yazar (§4).
- **K2 Etkisi görünmeyen sayı umursanmaz.** Two Point Hospital: "there is no punishment for NOT having reputation so why
  care" [S69]. FM'in dinamik lig itibarı (FM11, 2011): "It doesn't appear to do much." [S34]. → Marka'nın getirdiği, etkinin
  olduğu yerde sayıyla yazılır (Satış başlığı, Pazaryeri › Genel) ve en iyi ile en kötü Marka arasında fark büyüktür (ziyarette
  2,7 kat).
- **K3 Erime oyuncunun araçlarından hızlı olamaz.** Tropico 6'da döküm (Almanac) olduğu hâlde şikâyet sürüyor: "They're not as
  fast as the approval decay." [S71]. → Marka'da erime vergisi yok. Sönen yalnız yayının ve haberin izidir; kalan değeri kartta
  yazar ve yenisi alınabilir.
- **K4 Çok yapışkan sayı da küstürür.** FM: altı şampiyonluk, hâlâ 3 yıldız; moderatör: "It takes a long time for your
  reputation to catch up with your performances unfortunately." [S37]. → Erdem yavaş yürüyüşü seçti (18 Kasım); şikâyetin kaynağı
  "neden oynamadı" sorusuydu, bu yüzden gidilecek yer ve varılan yer kartta yan yana yazar, haber ve yayın hemen yazar (§2, §4).
- **K5 Parayla ya da tek tıkla alınan değer anlamsızdır.** EU4 istikrarı: "you can just 'boost' stability ... buy it with magic
  is very lackluster" [S25, yalnız arama özeti]; EU5: "trivially easy to keep Stability and Legitimacy high as both are simple
  functions of money" [S27, arama özeti]. Capitalism Lab'ın çözümü: bilinirliği reklam yükseltir, sadakat tutarlı kalite ister
  ("Loyalty also requires consistent quality, not merely high quality once.") [S50]. → Parayla alınan tek kaynak yayındır ve en küçük paydır (10); ofis 7,5'i geçmez (Erdem, 18 Kasım).
- **K6 Tek bir olay bütün değeri çökertemez.** Old Market Simulator: tek stok kalemi bitince itibar 103'ten 20'ye [S75]; RCT'de
  park puanı bir ayda 999'dan 400'ün altına, nedeni oyuncu elle buluyor [S67]. → Tek kart en çok 8 puan yazar ve her iz söner;
  haber izlerinin toplamı +12,5'i geçmez; her kaynağın aralığı bellidir (§2).
- **K7 Birikip tavanda kalan sayı ölür.** CK3: "when you have lots of it without trying ... prestige and piety are useless at
  best and a nuisance at worst" [S26, arama özeti]; Software Inc.'te itibar bir yılda tavana varıyor [S56]. → Marka birikmez:
  gideceği yer her hafta yeniden hesaplanır. Pazaryerinde kitle büyüdükçe "Ürün kalitesi"nin ölçüldüğü beklenti de büyür; ERP'de yukarıda
  tutmanın emeği kademe ve memnuniyettir.
- **K8 Gerçekte marka yeni müşteriyi getirir.** B2B alıcılarının %86'sının araştırmaya başlamadan aklında bir satıcı listesi
  var ve %92'si o listeden alıyor (Google ve Bain 2022, ABD, n=1.208; sponsorlu içerik, güven düşük) [S91]; Bain 2026 aynı
  yönde "yaklaşık %90" diyor [S92]. Etsy'de satışın %80'i organik kanallardan (2020 faaliyet raporu) [S108]. → Etki: ERP'de
  aday, pazaryerinde kendiliğinden gelen ziyaret.
- **K9 Beslenmeyen marka yavaş söner, sarsılan marka çeyreklerde toparlanır.** Reklamı kesen markada satış bir yılda %16, iki
  yılda %25, üç yılda %36 düşüyor (Ehrenberg-Bass, 41 bira ve elma şarabı markası, 20 yıl; hızlı tüketim malı için) [S82].
  Sonos 2024 uygulama krizi: yıllık gelir −%8,3, son çeyrek −%16,3 [S98]. CrowdStrike Temmuz 2024: müşteri kaybı küçük (brüt
  tutundurma %97 [S100]), genişleme yavaşladı (net tutundurma %119'dan %112'ye; düşük güven [S101]). → Yayının ve olayın izi
  her hafta sekizde bir söner (beş haftada yarıya iner); 104 haftalık oyunda bir çeyreğe sığar.

## 2. Model

### 2.1 Değer
- `Marka = taban + izler`. **Taban**, kalıcı kaynakların toplamına (gidilecek yer) her hafta aradaki farkın sekizde biri kadar
  yürür. **İzler** (haber ve yayın) hemen yazar ve her hafta sekizde biri söner. Toplam 0 ile 100 arasına kesilir, tam sayıya
  yuvarlanır ve `GameState.brand`'e yazılır (bugünkü alan, tam sayı; tek kapı `GameState.set_brand`, WRITE-THROUGH).
- Okuyan her yer (§3) bu tam sayıyı, yani oyuncunun üst barda gördüğünü okur; ondalık hiçbir eşiğe girmez.
- Ürün yayına çıkmadan (`ProductState.is_live()` yanlışken) Marka 0'dır: kaynak ve iz işlemez, kart tek satır yazar ("Ürün
  yayına çıkınca oluşur"). Yayın günü taban 0'dan başlar ve kaynaklarına yürür; lansmanın haberi o hafta yazar. Yeni oyun 0'dan
  başlar (bugün 50).
- **Hız (Erdem: yavaş).** Fark 8 puansa ilk hafta 1 puan kapanır; farkın yarısı beş haftada, onda dokuzu on yedi haftada kapanır.
  Yürüyüş iki yönde aynıdır: bozulan kaynak Marka'yı da aynı hızla indirir.

### 2.2 Kalıcı kaynaklar (toplamları tabanın gideceği yerdir)
Her kaynak bir seviyeyi okur ve puan verir. Hepsi `Brand.lines()`'ta; aynı liste kartı, haftalık hesabı ve botu besler.

| Kaynak | Okuduğu | Puan | Aralık |
|---|---|---|---|
| Ürün kalitesi | `ProductQuality.market_position()`, rakip penceresi olmadan: ERP'de 1★, 2★ ve 3★ alıcıya uyumun ortalaması; pazaryerinde kitleye uyum | ERP: (ortalama − 55) × 0,78. Pazaryeri: (uyum − 70) × 1,17 | ERP 0 … +35; pazaryeri −35 … +35 |
| Müşteri memnuniyeti | ERP: hesapların MRR ağırlıklı memnuniyeti. Pazaryeri: kullanıcı memnuniyeti × 0,7 + mağaza memnuniyeti × 0,3 | (memnuniyet − 50) × 0,6 × ses | −30 … +30 |
| Basın ve topluluk | Bütçesiz pazarlama satırı koşuyor mu (yükü %50: kurucunun tek pazarlama yeri) | koşarken +5, yoksa 0 | 0 … +5 |
| Ofis | Bulunulan ofis | Ev 0, İş hanı +2,5, Plaza +5, Loft +7,5; oturdukça | 0 … +7,5 |

- **Ağırlık sırası Erdem'indir:** ürün kalitesi (35) > müşteri memnuniyeti (30) > basın ve ödüller (17,5: bu satırdaki 5 puan
  ile haber izlerinin 12,5'i) > pazarlama (10: yayın izi, §2.3) > ofis (7,5). Hepsi tamken 100 eder.
- **Ses:** müşterisi az şirketin memnuniyeti az duyulur. ERP'de hesap sayısı ÷ 10, pazaryerinde aktif kullanıcı ÷ 1.000, en çok
  1. Hesap ya da kullanıcı yokken kaynak 0'dır (sıfıra bölme de olmaz).
- **Ürün kalitesi neden kademeyi okur, hatayı değil:** uyum (U) ürünün alanlarının pazarın beklentisine oranıdır; kademe çıktıkça
  yükselir. Açık hata, cevapsız destek, söz ve bekleyen talep bugün memnuniyete yazıyor (ERP'de `b2b_sales_system.gd`
  `_target_on`; Destek'in günlük zararı; pazaryerinde defter satırları) ve Marka'ya oradan girer. Aynı neden iki kez sayılmaz.
  Kart, memnuniyet satırının altında onu en çok düşüren nedeni adıyla yazar (§4).
- **Ölçünün üç kuralı (URUN'un incelemesi, 18 Kasım):** (1) Rakip penceresi okunmaz: `market_fit` rakibin her çıkışında
  beklentiyi altı hafta yükseltir (`rivals: true`); Marka'ya girseydi rakibin her çıkışı Marka'yı üç sprint düşürürdü ve
  rakiple karşılaştırma bu PRD'de yok. (2) Uyumda beklentiyi tam karşılayan ürün 70 alır (`FIT_SCALE`), 50 değil:
  pazaryerinde sıfır noktası 70'tir. (3) ERP'de üç yıldızın ortalaması okunur, tek yıldız değil: ürün bir yıldızı tamamlayınca
  ölçü üst yıldıza geçip düşmesin. 1★ uyumu yayından kısa süre sonra 100'e yapıştığı için ortalamanın sıfır noktası, yayın
  şartını yeni karşılamış ürünün ortalamasıdır (ilk tahmin 55; 1. adımda botla ölçülür) ve kaynak ERP'de eksiye düşmez.
- **Pazaryerinde açık hata** bugün memnuniyete yalnız dolaylı yazar (teslim adımını düşürürse "geç teslimat" satırı,
  cevaplanmazsa "cevapsız bildirim" satırı); sepet ve ödeme hatası siparişi düşürür, memnuniyeti düşürmez. Marka da aynısını
  okur; pazaryeri defterine açık hata satırı eklemek ayrı iştir (§14).
- **Kaybedilen müşteri Marka'ya yazmaz (Erdem).** Müşteri gidiyorsa nedeni ürün ya da memnuniyettir ve Marka onu oradan okur.
  Bilinen sonucu: defterin en mutsuz hesabı ayrılınca kalanların ortalaması yükselir ve Marka birkaç hafta içinde biraz
  toparlanır; hesap sayısı 10'un altındaysa ses de küçüldüğü için bu toparlanma azalır. Bugünkü sabit puanlar (İtibar −3,
  Marka −2) kalkar.
- **Kademe yayını, hata ihmali, kaçan hata, tutulan ve bozulan söz bugünkü sabit puanlarını yitirir** (İtibar +1, −1, −1, +2,
  −3; Marka −3): hepsi yukarıdaki iki kaynaktan girer. Söz modeli PRD_TALEPLER taslak 3'te değişti: bozulan söz yok, geciken söz
  hesabın memnuniyetine her ay adlı bir iz yazar; söz Marka'ya yalnız o hesabın memnuniyetiyle, gelirdeki payı kadar girer.

### 2.3 İzler (hemen yazar, her hafta sekizde biri söner; tabanın yürüyüşüne girmez)
- **Haber izi (basın ve ödüller):**

  | Olay | Marka | Bugün |
  |---|---|---|
  | v1.0 yayını | +8 | yeni |
  | Haber olan büyük imza (`SalesLedger.is_newsworthy_signing`) | +3 | aynı (`PRESTIGE_SIGNING_BRAND`) |
  | Seed turunun imzası | +5 | yeni |
  | Yatırımcının reddi | −3 | aynı (`REJECT_BRAND_COST`) |
  | Acil durum ve olay kartlarının seçenekleri (ödül, haber, sızıntı ...) | kartın `add_brand` ile yazdığı (bugün −4 … +5) | 38 kart: 24'ünde `add_brand`, 24'ünde `add_reputation`, 10'unda ikisi; İtibar yarısı memnuniyete gider (§7) |

  Haber izlerinin toplamı +12,5'i geçmez: artı yazan yeni haber kalan yer kadar yazılır ve seçeneğin çipi o sayıyı gösterir (iyi
  haber yığılmaz; K6, K7). Eksi iz kırpılmaz: kırpılsaydı bedeli yalnız Marka olan seçenek kötü bir çeyrekte bedavaya gelirdi
  (OLAYLAR'ın şartı; olay seçeneği kuralı: bedava çıkış yok). Eksi toplamı olayın sıklığı tutar (§6). Yarım puanın altına inen
  iz silinir. Ödül, kartla gelen bir haberdir: ayrı mekanik açılmaz, ödül kartı `add_brand` yazar (kartlar OLAYLAR'da).
- **Yayın izi (pazarlama; PRD_PAZARLAMA M10'un yayını):** yayın başladığı hafta kademenin puanı yazılır ve yayın sürdükçe tam
  kalır: Radyo (bir haftalık yayın) +4; TV (iki haftalık yayın) üç kademesiyle +5, +7,5, +10. Yayın bitince iz her hafta sekizde
  bir söner (beş haftada yarı). İzler toplanmaz: yeni yayın izi kendi kademesinin puanına tamamlar, en çok 10. Güçlü bir yayın
  sürerken gelen zayıf yayın iz yazmaz (güçlünün puanı ve son haftası kalır). Müşteri memnuniyeti 50'nin altındayken yayın yarı
  puan yazar (tasarım kararı; varsayım A2).
- **Yavaş yürüyüşle uzlaşma:** iz tabanın yürüyüşüne girmez, üstüne biner. İki haftalık TV yayını Marka'yı o hafta 10 puan
  yükseltir; yürüyüşe girseydi iki haftada ancak 2 puan oynatırdı (DUZELTME'nin uyarısı).
- **Sönmeyen iz türü yoktur.** Doğası kalıcı olan olayın (sızıntı ailesi, basına düşen açık, analist rehberi; altı kart) kalıcı
  yarısı memnuniyete ya da aday akışına yazılır, sönen yarısı izdir (6. adım, OLAYLAR).
- **Acil durumun zarı ayrı Marka bedeli yazmaz:** kesinti memnuniyetten girer; izi kartın seçeneği ve cevapsız kâğıdın
  `on_expire`'ı yazar.
- Her iz kartta adıyla ve bugünkü kalan değeriyle durur (EU4'ün süreli görüş satırları gibi [S6]); düşüş haber şeridine düşer.
  Olay kartının izinin adı kartın başlığı değildir (başlıkların bir kısmı yuva taşıyor ya da bağlamsız): kart kısa bir iz adı
  taşır (kartın metin bloğunda `text.tr.brand_note` ve `text.en.brand_note`; ör. "Sızıntı haberi" / "Leak story"); kart başına
  bir addır, 38 kart için OLAYLAR yazar (6. adım). İz kayıtta kartın kimliğini taşır (`card:<kart kimliği>`); ad gösterilirken
  o dildeki `brand_note`'a çözülür, dil değişince ad da değişir.

### 2.4 Tik ve kayıt
- **Haftalık tik:** `OfficeSystem.daily_tick`'ten sonra, `PhaseGateSystem.daily_tick`'ten önce (`time_manager.gd`: kapı kilitleri
  markayı oturmuş okur; memnuniyet ve pazaryeri defteri `SalesSystem`'in yuvasında kapanmıştır). Sıra: izler söner, kaynaklar
  okunur, taban kaynakların toplamına farkın sekizde biri kadar yürür, Marka yazılır.
- **Haber ve yayın:** iz o an yazılır ve Marka hemen yeniden hesaplanır (oyuncu kararın sonucunu aynı anda görür).
- **Seam'ler:** yazan iki kapı var. `Brand.note(tür, puan, argüman)` haber izini yazar (olay fiili, haber olan imza, seed
  imzası, yatırımcı reddi, lansman); `Brand.on_air(kanal, puan, son hafta)` yayın izini yazar (Pazarlama, yayın başlarken).
  Basın satırını `Brand` haftalık tikte `MarketingSystem.runs_channel("press")`'ten okur. Okuyucular: `GameState.brand` (sayı),
  `Brand.lines()` (kaynak satırları: kimlik, okunan değer, puan; tavan ve en çok düşüren neden 4. adımda kartla gelir),
  `Brand.target()` (kaynakların toplamı), `Brand.base()` (tabanın bugün vardığı yer), `Brand.traces()` (izler ve kalan
  değerleri), `Brand.change()` (geçen haftadan fark ve en çok oynayan satır), `Brand.leads()` ve `Brand.visits_mult()` (türün
  etkisi; kart ve etki satırları aynı sayıyı okur). `note` yazdığı puanı döndürür: `add_brand`'in çipi artı tarafta kalan yeri
  ondan okur; `add_brand` kolu kartın kimliğini `{"note": "card:<kart kimliği>"}` olarak geçirir.
- **Kayıt:** yeni alanlar `brand_base` (tabanın vardığı yer, ondalıklı), `brand_traces` (iz listesi: tür, argüman, değer,
  hafta), `brand_lines` (son iki haftanın puanları; kartın "ne değişti" başlığı için); 1. adımda ayrıca `brand_shadow` (gölge
  değer; 2. adımda yerini `GameState.brand` alır). Şema kırılmaz: eski kayıtta hepsi boş başlar, taban ilk tikte kaynakların
  toplamından başlar (eski kayıt yürüyüşü baştan beklemez); `reputation` anahtarı okunmaz.

## 3. Etkiler (Marka'yı okuyanlar)

| Yer | Kural | Bugün |
|---|---|---|
| ERP aday akışı | Marka'nın payı = 2,0 × min(Marka ÷ 50; 1) aday/hafta (tam Marka 50: URUN; erken oyunda bugünkü İtibar 9'un +0,6'sını korur) | İtibar 30'da +2 (`FLOW_REP_MAX`, `REP_FULL`) |
| Pazaryeri, kendiliğinden gelen ziyaret | Taban ilgi × (0,7 + 0,012 × Marka): 0'da 0,7; 25'te 1,0; 50'de 1,3; 100'de 1,9 | yok |
| Pazarlama, arama reklamının yeri | Arama satırının haftalık yeri = kategorinin araması × (1 + 0,3 × Marka ÷ 100) (DUZELTME'nin kararı, 18 Kasım; 7b) | yok |
| Seed görüşmesi | (Marka − taban) × 0,3, ±6 ile sınırlı; taban ilk tahmin 30 | (Marka − 50) × 0,3 |
| Series A görüşmesi | (Marka − taban) × 0,4, ±12 ile sınırlı; taban ilk tahmin 45 | (Marka − 50) × 0,4 |
| Yatırımcının zor sorusu (seed ve Series A) | Marka görüşmenin tabanının yarısının altında (ilk tahmin 15 ve 22) | İtibar 0'ın altında (`vc_pitch_system.gd:1117`, `:1163`) |
| Term sheet masasında anlatı uyumu | Marka görüşmenin tabanında ya da üstündeyse +6, altındaysa −6 (taban seed 30, Series A 45) | aynı kural, taban 50 |
| Satın alma teklifinin çarpanı | bantlar 20, 40, 60 | 30, 50, 70 |
| "Marka çöküşü" sonu | dokunulmaz | bugün yalnız debug'da: `active_scandal` ister, sistemi yok; GDD ch13 erken erişime bırakıyor |

- **P'ye bağlılık:** pazaryeri satırı P indikten sonra yazılır (P indi: c141b10a). Taban ilgi verisi P'nin değerinde kalır;
  Marka'nın çarpanı yalnız kendiliğinden gelen ziyaretin "taban ilgi" toplananına uygulanır (`marketplace_model.gd` `_visits`).
  Tavsiye terimi (memnun kullanıcının getirdiği kullanıcı) ve kategorinin payı Marka'yı okumaz: onlar içerideki kullanıcının işi.
- **Arama yeri:** markalı şirketi daha çok kişi arar; aynı bütçe daha düşük doyumda ve daha ucuza harcanır, tavan da yükselir.
  Arama satırının haftalık yeri = pazaryerinin reklam yeri (açık kategorilerin `ad_pool × seçenek` toplamı; kanallar
  kategoriye hedeflenmez, DUZELTME) × (1 + yayının doğrudan artışı) × (1 + 0,3 × Marka ÷ 100).
- **Yayının iki etkisi vardır ve ikisi de kalır** (yardımcı yönetmen, 18 Kasım). (1) Pazarlama etkisi, doğrudan: yayının ilk
  haftasından son haftasının iki hafta sonrasına dek arama yeri TV'de %10, %20, %30, Radyo'da %5 büyür (7b; [WORKING]).
  (2) Marka izi: Radyo +4; TV +5, +7,5, +10; o hafta yazar, sonra söner (§2.3). Çift sayım değildir: biri yayın haftalarının
  arama hacmi, öbürü markanın kendisidir. Toplam, en büyük TV'de ve Marka 30'ken: yayınsız yer × 1,09; yayın haftalarında
  × 1,30 × 1,12 = × 1,456, yani yayın arama yerini %33,6 büyütür (%30'u doğrudan, %2,75'i Marka'dan) ve kendiliğinden gelen
  ziyaretin taban ilgisini %11 artırır (çarpan 1,06'dan 1,18'e). Doğrudan artış bitince yalnız Marka'nın sönen payı kalır:
  yayının son haftasından beş hafta sonra iz 5 puan, arama yeri +%1,4, taban ilgi +%5,7.
- Mağazanın kendiliğinden gelişi Marka'yı okumaz: 16 Kasım ölçümünde mağaza kazanımını 2 ile 5 katına çıkarmak geliri
  değiştirmedi (darboğaz kullanıcı).
- Eşik kaymaları yeni ölçeğe çeviridir (yeni Marka 0'dan başlar, eskisi 50'den), zorlaştırma ya da kolaylaştırma amacı
  taşımaz. Bugünkü taban oyunun başlangıç değeriydi (50: olağan oyunda terim sıfıra yakın). Yeni taban aynı işi görsün diye
  varsayılan botun o görüşmedeki Marka'sının ortancasına çekilir (küçük ERP'de ses yüzünden Marka düşük başlar); ölçü §8'in 6.
  ölçütüdür.

## 4. Görünüm (ARAYUZ'un notlarıyla; 4. adım ARAYUZ'de)

- **Üst bar:** bugünkü ızgara MRR'ın altında MARKA, BURN'ün altında İTİBAR taşıyor (`top_bar.gd:309-312`). İtibar gidince ızgara
  KASA ve NET kalıbına döner: MRR'ın altına BURN gelir (aylık giren, aylık çıkan); MARKA sağ sütunun üst hücresidir ve altında
  geçen haftadan değişimi işaretiyle durur ("32", altında "+1"), NET gibi. Ok karakteri yok. Yayından önce "0", altı boş.
- **Renk NET'in kuralıdır** (`UiTokens.D_net_ink`): artı `D_pos`, eksi işaretli düz mürekkep; kırmızı yalnız tehlikede. Tehlike:
  Marka sıradaki turun soru eşiğinin altında (seed imzalanana kadar seed'in, sonra Series A'nın eşiği; §3).
- **Kart (üst bardaki Marka hücresinin üstüne gelince).** İki sütun: ad solda, puan sağda sabit sütunda, kaynağın tavanı puanın
  yanında soluk mürekkeple. Satırın kendi ipucu yok (kart zaten üstüne gelinerek açılıyor). Yavaş yürüyüşün yönü iki sayıyla
  okunur: kaynakların toplamı (gidilecek yer) ve tabanın bugün vardığı yer. Örnek, sayılar birbiriyle tutar:
  ```
  MARKA 32                        geçen haftadan +1: Müşteri memnuniyeti
  Kaynaklar 37                    varılan 33
    Müşteri memnuniyeti 76                     +16 / 30
      en çok düşüren: açık hata
    Ürün kalitesi: alıcıya uyum 73             +14 / 35
    Basın ve topluluk                           +5 / 5
    Ofis: İş hanı                             +2,5 / 7,5
  Haberler ve yayın
    Büyük imza: Akın Lojistik                   +2
    Yatırımcının reddi                          −3
  Haftada 1,3 aday getiriyor
  ```
  Marka = varılan (33) + izler (−1). Sıra işaretli değere göredir: önce artılar büyükten küçüğe, sonra eksiler. Puanı 0 olan
  satır yazılmaz. Başlık, geçen haftadan bu yana en çok oynayan satırı adıyla yazar; hiçbir satır oynamadıysa (yalnız taban
  yürüdüyse) neden yazmaz, değişim tek başına durur ("geçen haftadan +1"). "Kaynaklar" ile "varılan" arasındaki fark
  Marka'nın önündeki yoldur; açıklama cümlesi taşımaz (göster, anlatma). "Haberler ve yayın" başlığı da açıklama taşımaz:
  sönen iz her hafta küçülen değeriyle görünür. Son satır türün etkisidir: ERP'de aday, pazaryerinde ziyaret ("Haftada 518
  ziyaret getiriyor").
- **Etkinin olduğu yerde:** Satış başlığının ipucu bugünkü cümleyle ("Haftada 4,3 aday: yayındaki ürün 1,0, Marka (32) +1,3,
  satış ekibi 2,0"). Pazaryeri › Genel'de ziyaret çubuğunun "Organik" parçasının ipucu etkiyi çarpanla değil ziyaretle yazar:
  "Marka 32: haftada +518 ziyaret" (yalnız Moda açık ve dolu: taban ilgi 1.350 × 0,012 × 32). Sayı, Marka'nın 0,7 tabanının
  üstüne kazandırdığıdır ve eksiye düşmez. Çarpan yazılmaz, çünkü Marka "Organik"in yalnız taban ilgi toplananını çarpar,
  tavsiyeyi çarpmaz. Ekranın sözcüğü "Organik"tir (`MP_VISITS_ORGANIC`; Pazarlama'nın satırı da öyle).
- **Haber şeridi:** eksi iz yazan olay, ya da bir kaynağın bir haftada 3 puandan çok düşmesi, nedeniyle tek satır.
- **Dönem özeti:** bugünkü "Marka" satırı kalır (eski → yeni).
- Yeni sekme, yeni pencere ve Pazarlama başlığında yeni hücre yok (kart üst barda bir bakış uzakta). Kareler 4. adımda, TR ve
  EN, en dar dokta (`--shot-scale=1.25`).

## 5. Oyuncunun kaldıraçları (emek nereye gider)

| Karar | Sıklık | Marka'ya yolu | Bedeli |
|---|---|---|---|
| Yeni kademe çıkar | her sprint | Ürün kalitesi (en çok 35 puan) | sprint kapasitesi; beklenti şirketle büyür |
| Hatayı düzelt, desteği cevapla, sözü tut, talebi karşıla | her hafta, her sprint | Müşteri memnuniyeti (en çok 30 puan) | sprint kapasitesi, bir kişinin haftası |
| Tek pazarlama yeri: reklam mı, Basın ve topluluk mu | kurucu tekken sürekli | koşarken +5; reklam ise bu hafta ziyaret | kurucunun pazarlama payının tamamı |
| Lansman, büyük imza, yatırım, ödül | geldiğinde | haber izi (toplamda en çok +12,5; beş haftada yarıya iner) | o işin kendi emeği |
| Acil durumda cevap | geldiğinde | kartın yazdığı iz ve memnuniyet | kartın bedeli |
| Yayın al (Radyo, TV) | seed'den sonra | o hafta +4 ile +10; yayın bitince beş haftada yarıya iner | yayının bedeli ve Pazarlama Müdürü (M10) |
| Ofis | koşuda üç kez | +2,5, +5, +7,5, oturdukça | kira |

Marka'yı "tıklayıp yükselten" düğme yoktur; her kaldıraç oyunun zaten var olan bir kararıdır ve Marka onların ortak sonucudur.
Kalıcı kaynaklar yavaş yürür: bu çeyrekte çıkan kademe Marka'yı gelecek çeyrekte taşır. Hemen sonuç isteyen oyuncunun elinde
haber ve yayın vardır; ikisi de söner.

## 6. Ölçek (1, 3, 6, 12, 25, 50 kişi)

- Kaynakların hepsi oran, ortalama ya da durumdur: ürün kalitesi (uyum), memnuniyet (ortalama), basın satırı, ofis. Kişi ve
  hesap sayısıyla büyümez. Ses 10 hesapta ya da 1.000 kullanıcıda dolar; ondan sonra ölçek etkisizdir.
- Artı izler sınırlıdır: haberlerin toplamı +12,5, yayın en çok 10. Haftada beş büyük imza atan şirket de +12,5'i geçemez. Eksi
  izi olayın sıklığı tutar: kâğıt şirketin boyuyla çoğalmaz, tek kart en çok 8 puan yazar ve iz beş haftada yarıya iner (dört
  haftada bir −4 yazan şirketin eksi toplamı −6 ile −10 arasında gidip gelir).
- 330 hesaplı defterde tek bir geciken söz ya da tek bir kayıp Marka'yı oynatmaz; sözlerini geciktiren, çok hesap kaybeden
  şirketin memnuniyeti düşer. Kayıp Marka'ya ayrıca yazmadığı için küçük defterde en mutsuz hesabın gidişi ortalamayı yükseltir
  (§2.2); 5 hesaplı şirkette bu, ses küçüldüğü için 1 ile 2 puanı geçmez.
- Beklenen aralıklar (ölçülecek): 1 kişi 5 ile 30 · 6 ile 12 kişi 25 ile 55 · 25 ile 50 kişi 40 ile 80. 100'e ancak her şey
  tamken varılır (35 + 30 + 5 + 7,5 + 12,5 + 10).
- Uç bileşim: herkes satışçı olan 12 kişilik şirkette hata ve cevapsız bildirim birikir, kademe çıkmaz; memnuniyet ve ürün
  kalitesi düşer, Marka 10'lara yürür ve aday akışının Marka payı azalır; satış ekibinin getirdiği adaylar sürer (o pay
  Marka'yı okumaz).

## 7. Bugünkü iki sistemden geçiş

**Bugün (HEAD f798a5e9):**
- Marka: `GameState.brand` (int, 50'den başlar). Yazanlar: olay fiili `add_brand` (`effects.gd:264`), kaybedilen hesap −2
  (`b2b_sales_system.gd:352`), bozulan söz −3 (`:646`), ofise ilk varış +3, +6, +10 (`office_system.gd:88`; `brand_jump`,
  `reached`, `offices_reached` bayrağı), haber olan imza +3 (`sales_ledger.gd:281`), yatırımcı reddi −3
  (`vc_pitch_system.gd:546`). Okuyanlar: çöküş sonu (`endings_system.gd:103`, `:139`), satın alma çarpanı (`:263`), Series A ve
  seed görüşmesi (`vc_pitch_system.gd:171`, `:227`), term sheet masasının anlatı uyumu (`term_sheet_table_system.gd:542`), üst
  bar (`top_bar.gd:301`), dönem özeti, `finance.brand` seam'i, ofis kartı ve bildirimi (`office_map_card.gd:90`,
  `office_hud.gd`; metinler `OFFICE_CARD_BRAND` "Buraya taşınmak markanı bir kez {n} puan yükseltir.", `OFFICE_TOAST_BRAND`).
- İtibar: `GameState.reputation` (int, −10..100, 0'dan başlar). Yazanlar: `Reputation` (`reputation.gd`: kademe +1, söz +2,
  +1, −3, kayıp −3, kaçan hata −1), olay fiili `add_reputation` (`effects.gd:267`), hata ihmali haftada −1
  (`support_system.gd:288`). Okuyanlar: aday akışı (`sales_faucet_system.gd:127`), seed ve Series A'nın zor sorusu
  (`vc_pitch_system.gd:1117`, `:1163`), üst bar (`top_bar.gd:303`), Satış başlığının ipucu (`sales_tab.gd:741`),
  `finance.reputation` seam'i.
- İkisini de okuyan eski tüketici kitlesi formülü `sales_system.gd:206` (Marka) ve `:207` (İtibar). İtibar'ın öbür okuyanları
  (URUN'un sayımı): `sales_tab.gd:742`, `:758`, `:762`; `seams_finance.gd:35`; `main.gd:502`; debug yazanlar `main.gd:2058`,
  `:5681`.
- Kaybın tek yayın yeri `B2BSalesSystem.remove_lost` (`b2b_sales_system.gd:358`): `customer_churned` yayılırken hesabın
  `Customer.mrr`'ı hâlâ okunur; bütün kayıp yolları (pasif, fesih bildirimi, sunucu maddesi, kart fiili) oradan geçer. Bugünkü
  Marka −2 yalnız pasif yolda, İtibar −3 her yolda yazılıyor.
- Olay kartlarının koşullarında iki seam'i okuyan yok (sayım 0). Fikstür dışı 38 kart iki sayıdan birini fiille oynatıyor:
  24'ü Marka'yı, 24'ü İtibar'ı, 10'u ikisini birden (kategoriler: ürün 9, bağlanmamış 8, müşteri 6, rakip 5, dünya 5, kurucu 3,
  ekip 2). Sözün "marka −3"ü bir metin değil, hesaplanan bir çiptir: `break_plan` söz sayısı × −3 (`effects.gd:1036`),
  `promise_due.json` ve `promise_made.json` kartlarında `EFFECT_BRAND` (`chips.gd:570`); kartlar ve efektler OLAYLAR'ın.
- Memnuniyete yazan olay yolları: ERP'de `trust_delta` hesabın güven defterine yazar (−25 ile +10; defter haftada 2,8 puan
  affeder: `TRUST_OFFSET_DECAY_PER_DAY`). Kartlardaki 52 kullanımın 37'si −4 ile −8 arasıdır; `add_reputation` ise −1 ile −3
  arasını kullanır (iki kartta −8). Pazaryerinde olayın memnuniyet satırı defterde 8 hafta durur (`ledger.rows.decision.weeks`);
  yazan seam `MarketplaceSystem.add_satisfaction` var, onu çağıran olay fiili yok.

**Geçiş (sıra §11'de; her commit derlenir):**
1. `Reputation` sınıfının yerine `Brand` gelir: kaynak listesi, izler, haftalık hesap, kayıt ve satır metni tek evde.
2. Geçiş commit'i tek seferde döner: `GameState.brand` yeni değeri taşır; İtibar'ı okuyan yerler Marka'ya döner; eski yazanlar
   (kayıp −2, söz −3, ofis sıçraması, `Reputation`'ın dinleyicileri, hata ihmali) kalkar ya da ize döner; eşikler aynı commit'te
   çevrilir (yoksa 0'dan başlayan Marka seed görüşmesine −6 yazardı). `GameState.reputation`, `set_reputation`,
   `reputation_changed`, `reputation_log`, `mvp_bug_drop_day` ve `finance.reputation` bu commit'te silinir (CLAUDE.md §8).
   `sales_system.gd:207`'nin İtibar terimi ve `main.gd`'nin iki debug yazanı aynı commit'te kalkar. Kaybın bugünkü
   Marka −2'si yerine bir şey konmadan kalkar (Erdem). Sözün `:646`'daki −3'ü, `break_plan`'ın marka çipi ve
   iki kartın `EFFECT_BRAND`'i yeni söz modeliyle kalkar (PRD_TALEPLER taslak 3; OLAYLAR'ın Talepler 6. adımı). Marka'nın 2.
   adımı önce inerse `:646`'yı bu commit siler, çipleri OLAYLAR.
3. `add_reputation` takma adla yaşamaz ve iki sayı tek sayıya inmez (OLAYLAR'ın şartı). İki fiili birden yazan 13 seçeneğin
   10'unda işaretler zıttır (`rival.copycat` `press_release`: Marka +4, İtibar −2); tek sayıda takas silinir, iki seçenek
   bedelsiz kalır. Kural: seçeneğin gürültü yarısı Marka izidir (`add_brand`), güven yarısı memnuniyete yazar: ERP'de hesapların
   güven defterine (`trust_delta`), pazaryerinde kullanıcı ya da mağaza defterine süreli satır (`satisfaction_delta`
   `accounts: all`; mağaza için `side: stores`). İki oyunda da çalışacak seçenek iki efekti birlikte taşır; her biri öbür oyunda
   sessizdir. Güven yarısı güvenin ölçeğinde yazılır (İtibar −2, güven −2 değildir: defter onu bir haftada affeder); kalıcılık
   `per_sprint` sızıntısıyla verilir (OLAYLAR). Aynı işaretli çift fiilde (cevapsız kâğıdın
   bedeli) toplanmaz, büyük olan kalır. Yalnız `add_reputation` yazan 14 kartta OLAYLAR karta göre seçer: güvense memnuniyet,
   haberse iz. Kartlar geçişten önce taşınır (6. adım; bugünkü modelde de geçerlidir: `add_brand` bugünkü sayıya,
   `trust_delta` hesaba yazar); geçiş commit'i fiili, `EFFECT_REPUTATION` çipini ve lint'teki adını siler.
4. Ofis oturdukça küçük bir kaynaktır (yardımcı yönetmenin Erdem'e önerisi, en çok 7,5): `brand_jump`, `reached`,
   `offices_reached` ve iki metin silinir, kart "Burada oturdukça markan {n} puan yüksek durur" yazar; puanlar 2,5, 5 ve 7,5
   (`OfficeConstants.CATALOG`'un `brand` alanı).
5. Metin: `EFFECT_REPUTATION`, `REPUTATION_*` silinir; `SALES_FLOW_TIP` Marka ile yazılır (§9).
6. Test: İtibar'ı sabitleyen smoke vakaları (dosyada 83 anış) yeni modelin vakalarıyla değişir; çekirdek için ölçüm betiği
   (kaynakların toplamı, ses, iz sönüşü ve sınırı, yayının tamamlama kuralı, yayından önce 0, eski kayıt). `market_position()`
   için tek satırlık vaka: kademe çıkınca okuyucu azalmaz (URUN'un şartı).

## 8. Bot ve kabul ölçütleri

- Bot Marka'yı oynamaz, sonucunu basar: `PROBE STATE`'in `brand=` alanı ve yeni `PROBE BRAND day= value= base= target= quality= sat= press= office= traces= leads= visits= delta= moved=`.
- **Kabul (hepsi botla, 3 tohum, 104 hafta):**
  1. Pazaryeri varsayılan kolu yardımcı yönetmenin eşiğini tutar: çek en geç 40. hafta, seed en geç 75. hafta, iflas yok.
     Bugünkü ölçü (P ve K2 ile, Marka'sız): çek 22, seed 48 ile 49.
  2. Marka canlıdır: varsayılan kolda yayından 104. haftaya en düşük ile en yüksek değeri arasında en az 20 puan vardır ve
     son çeyrekte tavanda (100) ya da tabanda (0) durmaz.
  3. Yavaş ve okunur: haber ve yayın olmayan haftalarda Marka haftada 3 puandan çok oynamaz; kaynakların toplamı 10 puan
     değiştiğinde Marka'nın yarı yola varması beş hafta sürer (yürüyüşün kendisi; ölçüm betiği sınar).
  4. Emek karşılık bulur: hatayı ve desteği ihmal eden kol, varsayılan koldan çeke en az 4 hafta geç varır.
  5. Para Marka'yı almaz: yalnız yayın alan, kademeyi, hatayı ve desteği ihmal eden kolun Marka'sı varsayılan kolun 10 puandan
     fazla üstüne çıkamaz ve yayın bitince altına iner (5. adımda, yayın inince).
  6. ERP: `full_run` ve `full_run_vc_cautious` görüşme sonuçları eski koşuyla aynı bantta kalır (eşik kaymaları çeviridir).
- Marka'nın 104 haftalık eğrisi ve kaynakların payı incelemeye tabloyla gider; sayı ayarı oradan.

## 9. Metinler (taslak; önce İngilizce, TR ve EN onay bekliyor)

| Anahtar | EN | TR |
|---|---|---|
| `TOPBAR_BRAND_KEY` | BRAND | MARKA |
| `BRAND_CHANGE` | {delta} since last week: {reason} | geçen haftadan {delta}: {reason} |
| `BRAND_SOURCES` | Sources {n} | Kaynaklar {n} |
| `BRAND_REACHED` | reached {n} | varılan {n} |
| `BRAND_SRC_SATISFACTION` | Customer satisfaction {n} | Müşteri memnuniyeti {n} |
| `BRAND_SRC_WORST` | pulled down most by: {reason} | en çok düşüren: {reason} |
| `BRAND_SRC_QUALITY` | Product quality: fit for buyers {n} | Ürün kalitesi: alıcıya uyum {n} |
| `BRAND_SRC_QUALITY_USERS` | Product quality: fit for shoppers {n} | Ürün kalitesi: kitleye uyum {n} |
| `BRAND_SRC_PRESS` | Press and community | Basın ve topluluk |
| `BRAND_SRC_OFFICE` | Office: {office} | Ofis: {office} |
| `BRAND_NEWS` | News and broadcasts | Haberler ve yayın |
| `BRAND_TRACE_BROADCAST` | On air: {channel} | Yayın: {channel} |
| `BRAND_TRACE_LAUNCH` | Launch | Lansman |
| `BRAND_TRACE_SIGNING` | Big signing: {company} | Büyük imza: {company} |
| `BRAND_TRACE_SEED` | Seed round signed | Seed turu imzalandı |
| `BRAND_TRACE_REJECTED` | Investor said no | Yatırımcının reddi |
| `BRAND_BRINGS_LEADS` | Brings {n} leads a week | Haftada {n} aday getiriyor |
| `BRAND_BRINGS_VISITS` | Brings {n} visits a week | Haftada {n} ziyaret getiriyor |
| `MP_VISITS_BRAND` | Brand {brand}: {n} visits a week | Marka {brand}: haftada {n} ziyaret |
| `BRAND_PRELAUNCH` | Forms once the product is live | Ürün yayına çıkınca oluşur |
| `SALES_FLOW_TIP` | {n} leads a week: live product {live}, Brand ({brand}) {brand_part}, sales team {sales} | Haftada {n} aday: yayındaki ürün {live}, Marka ({brand}) {brand_part}, satış ekibi {sales} |
| `MKT_KIND_PRESS` | Press and community | Basın ve topluluk |
| `OFFICE_CARD_BRAND` | While you sit here your brand stands {n} higher. | Burada oturdukça markan {n} puan yüksek durur. |

Tire yok, yer tutucular adlı, araya giren değer ek almıyor. Olay kartının iz satırı kartın iz adını yazar (`brand_note`; OLAYLAR, 6. adım). Kaynağın
tavanı metin değil sayıdır ("+21 / 40"); `MP_VISITS_BRAND`'in sayısı işaretiyle gelir ("+567").

## 10. Tasarım sabitleri (hepsi [WORKING]; onay bekliyor)

Ağırlıklar (Erdem'in sırası): ürün kalitesi 35, müşteri memnuniyeti 30, basın ve ödüller 17,5 (basın satırı 5 + haber izleri
12,5), pazarlama 10 (yayın izi), ofis 7,5 · ürün kalitesi: ERP sıfır noktası 55 ve katsayı 0,78, pazaryeri sıfır noktası 70 ve
katsayı 1,17 · memnuniyet katsayısı 0,6, pazaryerinde 0,7 ile 0,3 payı, ses eşiği 10 hesap ve 1.000 kullanıcı · basın satırı
+5, yük %50 · ofis 2,5; 5; 7,5 · tabanın haftalık yürüyüşü farkın 1/8'i · izin haftalık sönüşü 1/8, silinme eşiği 0,5 · haber
izlerinin üst sınırı +12,5 (eksi tarafta sınır yok); lansman 8, seed imzası 5 · yayın puanları 4; 5; 7,5; 10 ve sevilmeyen
ürün yarısı · aday payı 2,0 ve tam Marka 50 · ziyaret çarpanı 0,7 ve 0,012 · arama yeri 0,3 (DUZELTME) · seed tabanı 30, Series
A tabanı 45 (ikisi de ölçümle), soru eşiği tabanın yarısı, satın alma bantları 20, 40, 60. Taşınanlar (değişmiyor): büyük
imza +3; yatırımcı reddi −3.

## 11. Commit sırası ve adım tablosu (onaydan sonra)

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| 0 | Üç incelemenin ve Erdem'in beş cevabının işlenmesi; PRD taslak 4 | PAZARYERI | ana oturum | yüksek | 2 saat | kapsam kilitlenir |
| 1 | `Brand` çekirdeği gölgede: hesaplar ve `PROBE BRAND` basar, `GameState.brand`'e yazmaz, kimse okumaz; ölçüm betiği. Taslak 3'e göre yazılan kod taslak 4'e çevrilir (yürüyüş, yeni ağırlıklar, kayıp kaynağı yok) ve yeniden incelenir | PAZARYERI | Opus | en yüksek | 3 saat | model botla sınanır; oyuncu bir şey görmez |
| 2 | Geçiş: Marka yeni değeri taşır, İtibar'ın okuyanları ve eşikler döner, eski yazanlar ve `reputation` silinir; üst bar ızgarası tam kurulur (§4; karesini ARAYUZ inceler: TR, EN ve EN 1,25); yatırımcı eşiklerinin çevirisi; smoke vakaları | PAZARYERI; Satış kısmını URUN inceler | Opus | en yüksek | 5 saat | iki sayı tek olur; oyuncu ilk kez görür |
| 3 | Pazaryeri taban ilgisi Marka'yı okur; bot ölçümü (§8 ölçüt 1 ile 4) | PAZARYERI | Opus | en yüksek | 3 saat | P'nin kalıcı hâli |
| 4 | Kart ve etki satırları; kareler TR ve EN | ARAYUZ (okuyucuları PAZARYERI verir) | Sonnet | yüksek | 3 saat | oyuncunun okuduğu döküm; görsel kabul |
| 5 | Pazarlama: yayın izi, Basın ve topluluk satırı, arama yeri; bot ölçümü (ölçüt 5) | DUZELTME (7b ile) | Sonnet | yüksek | 3 saat | paranın ve zamanın kaldıracı |
| 6 öncesi | Olay fiilinin pazaryeri kolu: `satisfaction_delta` `accounts: all` pazaryeri oyununda kullanıcı defterine, `side: stores` ile mağaza defterine süreli satır yazar (`MarketplaceSystem.add_satisfaction`; PRD_PAZARYERI §3.8); çipi "Kullanıcılar: memnuniyet 71 → 67" | PAZARYERI; olay motoru kısmını OLAYLAR inceler | Opus | yüksek | 1,5 saat | 6. adımın pazaryeri kartları buna yazar |
| 6 | 38 kart: İtibar yarısı memnuniyete (`trust_delta`; pazaryerinde defter satırı), sönen yarı `add_brand` izi; iz adları (`brand_note`); kartlarda `add_reputation` kalmaz. 2. adımdan önce iner | OLAYLAR | Sonnet | yüksek | 3 ile 4 saat | takas korunur; geçişte takma ad gerekmez |
| 7 | Ofis (oturdukça, 2,5; 5; 7,5), dönem özeti, kalan temizlik; ERP bot ölçümü (ölçüt 6) | PAZARYERI | Opus | yüksek | 2 saat | geçiş kapanır |
| her commit | fark incelemesi (tek tur) ve tek düzeltme turu | ayrı ajan | Opus | yüksek | 20 dk | CLAUDE.md §9 |

Sahiplik ve zamanlama yardımcı yönetmenin 18 Kasım kararıdır: 0. adımda üç inceleme işlenir ve PRD `docs/tasks/`'e iner; 1.
adım incelemeler işlenince başlar; 2. adım Erdem'in beş cevabını bekliyordu, cevaplar 18 Kasım'da geldi (§13). İniş sırası 1 → olay
fiilinin pazaryeri kolu → 6 → 2 → 3 → 4 → 5 → 7'dir: kartlar geçişten önce taşınır (§7 madde 3) ve 4. adımın "Haberler ve yayın" bölümü
6. adımın iz adlarını okur (sıra: yardımcı yönetmenin onayı, 18 Kasım 04:50; OLAYLAR kendi belgelerinde bu adıma "M6" der,
Talepler'in 6. adımıyla karışmasın diye). Modeller yardımcı yönetmenin "serbest Opus" kararıyladır. Yatırımcı görüşmesinin
metnine dokunulursa OLAYLAR'a gösterilir. 2. adım inmeden 4. adımın karesi çekilmez. 5. adım DUZELTME'nin 7b'sine bağlıdır; gecikirse Marka kalan kaynaklarla işler ve yayın
satırının puan yeri boş kalır (DUZELTME, 18 Kasım).

## 12. Seçenekler, öneri ve pre-mortem

| | Oyuncu ne görür | Bedel | Geri dönüş |
|---|---|---|---|
| **1. Tek Marka, kaynaklarının toplamına yürür (Erdem'in seçimi)** | Tek sayı, EU4'ün gelir dökümü gibi kaynak satırları, haftalık değişim ve nedeni | 7 commit, dört oturumun işi | Kolay: sabitler; kayıt şeması kırılmıyor |
| 2. İki ayaklı Marka (Bilinirlik × İtibar) | İki çubuk ve çarpımları; reklam yalnız bilinirliği, ürün yalnız itibarı oynatır | Aynı iş + iki döküm; çarpım ipucunda okunmuyor | Orta |
| 3. Yalnız birleştir | Tek sayı, bugünkü gibi olay oldukça oynar; pazaryerine okuyucu eklenir | 3 ile 4 commit | Kolay |

- **Önerim 1:** Erdem'in dört isteğini (tek çatı, besleyen, etkileyen, haftalık ve nedenli) birlikte karşılayan tek seçenek.
  2 gerçeğe en yakını (Capitalism Lab'ın modeli [S50]) ama iki sayıyı tek çatıda toplama isteğini iki çubukla geri getirir. 3
  ucuzdur ve dürüst bir "şimdilik bu kadar" seçeneğidir; ama sayı yine olay olmadıkça durur, yani "sabit" kalır.
- **Ne yapmayacağız (1 seçilirse):** ayrı bilinirlik çubuğu, kategori ya da sektör başına marka, rakiplerle aranma payı yarışı,
  hata ve söz için ayrı Marka cezaları.

**Pre-mortem: "yaptık ve tutmadı; ne öldürdü?"**
1. **Kart okunmadı, Marka yine üst barda bir sayı kaldı** (kanıt yolu). Erken uyarı: Erdem 30 dakikalık oturumdan sonra
   "Markam en son neden oynadı" sorusuna cevap veremez. Önlem: başlık nedeni kendisi yazar; en çok yedi satır; etkisi Satış ve
   Pazaryeri'nde kendi yerinde. En ucuz hamle: bu PRD'nin örnek kartı 1. adımdan önce Erdem'e gösterilir.
2. **Oyuncu tek baskın yolu buldu** (aktör yolu): ya yalnız yayın alıp ürünü bıraktı, ya Marka'yı hiç umursamadı çünkü etkisi
   küçüktü. Erken uyarı: §8'in 4. ve 5. ölçütü tutmaz. Önlem: yayının payı 10, ziyaret çarpanında 2,7 kat fark; ikisi de botla
   inişten önce ölçülür.
3. **Marka memnuniyetin gölgesi gibi okundu** (model yolu): en büyük iki kaynak ürün kalitesi ve memnuniyet; kalite seyrek
   oynarsa (kademe sprint ister) iki sayı birlikte hareket eder ve oyuncu "neden iki sayı" der. Erken uyarı: 3. adımın
   ölçümünde Marka'nın haftalık değişiminin yüzde 80'inden çoğu memnuniyet satırından gelir. Önlem: memnuniyetin katsayısı
   0,6'dan 0,5'e iner, ürün kalitesininki yükselir (toplam yine 100).
4. **"Yaptım, neden oynamadı"** (hız; Erdem'in seçtiği yavaş yürüyüşün bedeli): oyuncu kademe çıkarır, Marka o hafta 1 puan
   oynar. Erken uyarı: Erdem oturumdan sonra "Markam nereye gidiyor" sorusuna cevap veremez. Önlem: kart gidilecek yeri ve
   varılanı yan yana yazar, üst barda haftalık değişim durur; yetmezse yürüyüş sekizde birden altıda bire çıkar (tek sabit).
5. **Yarım indi** (bağımlılık yolu): yayın (DUZELTME 7b) ya da kartların taşınması (OLAYLAR) gecikti. Erken uyarı: Erdem'in
   cevaplarından iki gün sonra 6. adım inmemiş. Önlem: kartların taşınması bugünkü modelde de geçerlidir ve cevaplar
   beklenirken hazırlanır; o inince 2. adım kendi başına tamdır (yayın izi olmadan da Marka beş kaynakla işler). Takma adla
   geçiş yok: zıt işaretli on seçeneği bozar.

## 13. Erdem'in cevapları (18 Kasım; yardımcı yönetmenin aktarımı) ve PRD'ye işlenişi

| Soru | Cevap | İşlenişi |
|---|---|---|
| Ad | "Marka olsun." | Üst barda tek sayı: MARKA |
| Hız | "Bence B" (yavaş yürüsün) | Taban kaynakların toplamına haftada farkın sekizde biri kadar yürür; haber ve yayın hemen yazar (§2.1, §2.3) |
| Para | "parayla işimiz olmamalı ... Parayla alakası olmaması lazım." | "Para payı" kavramı kalktı; paralı tek kaynak yayın, en küçük pay (10) |
| Sıra | "Bir, en önemlisi ürünün kalitesi. İki, müşteri memnuniyeti. Üç, pazarlama. Marketing en ufak payı." | 35, 30, basın ve ödüller 17,5, pazarlama 10 (§2.2, §10) |
| Ofis | "Maksimum %10'luk payı hatta %5'lik payı ya da %7,5'luk payı ofisten gelsin." | Oturdukça, en çok 7,5 (yardımcı yönetmenin önerisi) |
| Kayıp hesap | "Kaybedilen müşteri markaya yazmasın." | Kaynak silindi; bilinen sonucu §2.2'de |

Açık kalan ve onay bekleyen yalnız sayılardır (§10) ve TR, EN metinler (§9). Yardımcı yönetmenin bakması gereken iki yorum:
"basın ve ödüller"in pazarlamadan büyük tutulması (Erdem pazarlamayı üçüncü ve en ufak pay saydı; basını ve ödülü ayrıca
önemsedi) ve ödülün ayrı bir mekanik değil, olay kartıyla gelen bir haber olması.

## 14. Ayrı işler (bu PRD'de değil)

- İşe alıma etki. Öneri hazır ama dayanağı zayıf: kötü itibarlı işverenin en az %10 fazla ödediğini söyleyen tek kaynak bir
  satıcı araştırması [S94]; hakemli çalışma yalnız yönü veriyor (daha az ve daha düşük nitelikli başvuru) [S95]. Marka
  oturduktan sonra ayrı küçük iş.
- Rakiplerle aranma payı ve Piyasa penceresinde marka sıralaması. Kategori ya da sektör başına marka.
- Çalışanların markaya etkisi (işten çıkarma haberi, moral). Mağazanın kendiliğinden gelişine etki (ölçüm tutarsa).
- Ödül kartları (yılın girişimi, sektör ödülü ...): haber izi yazan olay kartlarıdır; içerik OLAYLAR'da, bu PRD kapıyı verir.
- Pazaryeri defterine "açık hata" satırı (sepet ve ödeme hatası bugün memnuniyete yazmıyor).
- "Marka çöküşü" sonunun kendisi (erken erişim; GDD ch13).
- Belgeler, iniş sırasında yardımcı yönetmence: CLAUDE.md §6'nın ofis cümlesi ("ofisin ödülü marka sıçramasıdır") ve
  WRITE-THROUGH satırı ("marka, itibar"); GDD ch09 ("ret markaya mal olur": kural kalıyor) ile ayrılıklar `ACIK_KARARLAR.md`'ye.
- Söz düğmesindeki "marka −3" metni yeni söz modeliyle kalkar (PRD_TALEPLER taslak 3): OLAYLAR.

## 15. Araştırmanın ve incelemenin özeti

| | İşleyen | Şikâyet alan |
|---|---|---|
| Döküm | EU4 görüşü: nedenler her ipucunda [S6]; Tropico Almanac [S72]; FM23 taraftar güveni dört alan [S30] | Software Inc. "no info as to why" [S54]; FM itibarı [S37]; MGT2 yorum puanı [S63] |
| Etki | Capitalism Lab: marka ürün puanının %20'si (dondurulmuş et) ile %60'ı (sigara) [S51]; CK3 ün basamakları [S15] | Two Point Hospital "why care" [S69]; OOTP ilgi 37'den 51'e, seyirci +%3,1 [S49c, arama özeti] |
| Hız | EU4 prestiji yılda %5 erir [S1]; CK3 korkusu tabana ayda 0,5 yürür [S17] | Tropico "approval decay" [S71]; FM "catch up" [S37] |
| Kaldıraç | Capitalism Lab: reklam bilinirliği, kalite sadakati [S50] | EU4 istikrarı "buy it with magic" [S25]; CK3 meşruiyeti "pay2win" [S27] |

- **Şüpheci doğrulama turu (18 Kasım, bu oturum):** yük taşıyan on kaynak yeniden açıldı ve alıntılar harfi harfine tuttu:
  [S1], [S30], [S37], [S50], [S54], [S69], [S71], [S82], [S89], [S91]. Düzeltmeler: [S82]'de ülke yazmıyor ve "hızlı tüketim
  malı için" kaydı yazarın yorumu; [S91] Google sponsorlu içerik. Açılamayanlar metinde "arama özeti" diye işaretli
  ([S25], [S26], [S27], [S49c], [S61]); bunlar tek başına karar taşımıyor, her biri açılmış bir kaynakla aynı yönde.
- **En büyük uyarı:** oyun örneklerinin şikâyet tarafı forum yazılarıdır (düşük güven); sayı değil yön verir. EU4 ve CK3
  ipuçlarının satır satır metni bulunamadı; kartın biçimi (§4) kendi tasarımımızdır, kopya değil.
- **Bulunamayanlar:** bilinirlik ve NPS'in çeyrekte kaç puan oynadığı; markanın B2B kapanış oranına etkisi; Trendyol ve
  Amazon'un pazarlama oranı; sevilen bir "erime" örneği.
- **Varsayımlar:** A1 izin beş haftada yarıya inmesi 104 haftalık oyuna uyar (duyarlılık orta; §8). A2 sevilmeyen ürünün
  yayını yarı etkilidir (kaynak yok; duyarlılık düşük). A3 pazaryerinde Marka'nın payı taban ilgide 0,7 ile 1,9 arasıdır
  (Etsy'nin %80 organik payı yön verir [S108], sayı vermez; duyarlılık yüksek). A4 ses 10 hesapta ve 1.000 kullanıcıda dolar
  (kaynak yok; küçük marka hem az alıcıya hem az sadakate sahiptir bulgusu yön verir [S116]; duyarlılık orta).
- **Taslak 1'den taslak 2'ye (Opus incelemesi ve DUZELTME):** (1) Açık hata, cevapsız bildirim, söz ve talep kaynak
  olmaktan çıktı: memnuniyet onları zaten sayıyordu. (2) Tekrarlayan olayların sabit puanları kalktı; kayıp orana döndü, iz
  toplamı sınırlandı: haftalık olay büyük şirkette Marka'yı kalıcı kaydırıyordu. (3) Yürüyüş kalktı: iki haftalık yayın yavaş
  yürüyen değeri ancak 3 puan oynatıyordu (DUZELTME); yayın ve olay artık hemen yazan, sönen iz. (4) "Kaybedilen hesaplar"
  kaynağı eklendi: mutsuz hesabı bırakmak ortalamayı yükseltiyordu. (5) Pazarlama tavanı kuralı kalktı (hiç devreye girmiyordu);
  paranın payı kaynakların aralığından okunuyor. (6) Commit sırası derlenecek biçimde yeniden kuruldu. (7) Çöküş sonu yanlış
  anlatılmıştı (bugün yalnız debug'da). (8) Atlanan okuyanlar eklendi: seed'in zor sorusu, ofis kartı ve bildirimi, eski kitle
  formülü. (9) Tik yeri, yuvarlama, eski kayıt, hesapsız ERP yazıldı. (10) Marka araması çarpanı yerine arama yeri (DUZELTME). (11) Pazardaki yer rakipsiz okunur, sıfır noktası uyumun kendi
  ölçeğine çekildi; aday payının tam Marka'sı 60'tan 50'ye indi (URUN). (12) Görünüm ARAYUZ'un notlarıyla yeniden yazıldı:
  KASA ve NET kalıbında üst bar, satır içi ipucu yerine tavan sayısı, pazaryerinde etki çarpanla değil ziyaretle.
- **Taslak 2'den taslak 3'e (OLAYLAR'ın kart incelemesi ve 1. adımın yazımı):** (1) İki sayıyı birden oynatan seçenek tek
  sayıya inmez: İtibar yarısı memnuniyete yazar; takma adla geçiş kalktı, kartlar geçişten önce taşınır. (2) Olay izinin sınırı
  yalnız artıda: eksi sınır bedelli seçeneği bedavaya getiriyordu. (3) İzin adı kartın başlığı değil, kartın kendi alanı.
  (4) Söz yeni söz modeline bağlandı; beşinci soru kaybedilen hesaba indi. (5) Kaybedilen gelirin −15 tavanı kalktı: gelirinin
  üçte birinden fazlasını kaybeden şirkette mutsuz hesabı bırakmak Marka'yı yükseltiyordu. (6) Güçlü yayın sürerken gelen zayıf
  yayın iz yazmaz. (7) Doğası kalıcı altı kartın kalıcı yarısı ize değil memnuniyete yazar; acil durum zarı ayrı Marka bedeli
  yazmaz.
- **Taslak 3'ten taslak 4'e (Erdem'in beş cevabı, 18 Kasım):** (1) Hız: Marka kaynakların toplamına yavaş yürür; haber ve
  yayın izi yürüyüşe girmez, hemen yazar (TV'nin etkisi kaybolmasın). (2) Ağırlıklar: ürün kalitesi 35, memnuniyet 30, basın ve
  ödüller 17,5, pazarlama 10, ofis 7,5; "pazardaki yer" kaynağının adı "ürün kalitesi" oldu ve en büyük pay ona geçti.
  (3) "Para payı" kavramı kalktı; yayın 20'den 10'a, ofis 10'dan 7,5'e indi. (4) Kaybedilen hesap kaynağı silindi. (5) Basın
  satırının kendi haftalık sayacı kalktı (yürüyüş zaten yavaşlatıyor): koşarken +5. (6) Kart gidilecek yeri ve varılanı yan
  yana yazar.

## Ek. Yük taşıyan kaynaklar (tam siciller dört araştırma dosyasında; erişim 2026-11-18)

| ID | Kaynak | Güven |
|---|---|---|
| S1, S6, S17 | EU4 Wiki: Prestige, Relations; CK3 Wiki: Dread (eu4.paradoxwikis.com, ck3.paradoxwikis.com) | Yüksek |
| S15 | CK3 Wiki: Resources (ün ve bağlılık basamakları) | Yüksek |
| S25, S26, S27 | Paradox forumu, Reddit ve Steam yazıları (EU4 istikrarı, CK3 prestiji ve meşruiyeti) | Düşük; yalnız arama özeti |
| S30 | footballmanager.com/features/supporter-confidence (Sports Interactive, 2022-09-30) | Yüksek |
| S34, S37, S38 | FM-Base ve FM Scout forumları (lig itibarı, 2011; "team Reputation", 2023; itibar, 2008) | Düşük |
| S49c | OOTP forumları | Düşük; yalnız arama özeti |
| S50, S51 | capitalismlab.com: marka ve oyunun temelleri (Enlight Software) | Yüksek |
| S54, S56, S61 | Steam: Software Inc. tartışmaları; yama notları | Düşük; S61 yalnız arama özeti |
| S63, S67, S69, S71, S74, S75 | Steam tartışmaları: Mad Games Tycoon 2, RCT2, Two Point Hospital, Tropico 6, Tavern Tycoon, Old Market Simulator | Düşük; S74 geliştirici cevabı içerir |
| S72 | Gamepressure: Tropico 6 onay rehberi | Orta |
| S82 | Ehrenberg-Bass Institute: reklamı kesen markalar (JAR 2021) | Yüksek |
| S89 | Spiegel Research Center: çevrimiçi yorumlar ve satış | Yüksek |
| S91, S92 | Marketing Dive (Google sponsorlu; Bain ile 2022 anketi); Bain 2026 | Düşük; Orta |
| S94, S95 | LinkedIn araştırması (HPC aktarımı); Turban ve Cable 2003 | Düşük; Yüksek (ayrıntısız) |
| S98, S100, S101 | Sonos 8-K (Kasım 2024); CrowdStrike FY25 sonuçları (IT Brief aktarımı); Latka | Yüksek; Orta; Düşük |
| S108, S116 | Etsy 10-K FY2020; Ehrenberg-Bass: B2B'de çifte tehlike yasası | Yüksek; Orta (arama özeti) |
