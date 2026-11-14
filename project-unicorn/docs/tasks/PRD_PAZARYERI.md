# PRD · Pazaryeri

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_PAZARYERI.md dosyasını oku ve
uygula." Erdem uygulamayı 14 Kasım gecesi başlattı ("İmplementasyon başlasın"): §12'deki açık sorularda bu belgenin önerisi uygulanır,
commit mesajı "Erdem'in cevabı bekleniyor; PRD önerisiyle (soru N)" yazar; cevap gelince belge ve kod yeni commit'le güncellenir.
**Durum:** taslak 2, 2026-11-13 gece, PAZARYERI oturumu; bir Opus incelemesinden geçti ve bulguları işlendi (§14). Tur 4 ekran turunun ve Erdem'in 13 Kasım akşam yorumunun
(`tur4_ekranlar_2026-11-13/ERDEM_YORUMU_TUR4.md`) sonucudur. Kaynak okumasıdır: oyun, smoke ve probe koşulmadı; kareler commit'siz
bir prototipten çekildi ve kod kaynağı sayılmaz. Her sayı başlangıç değeridir ve "onay bekliyor" diye iner (§9); sayı ayarı
playtest'tedir.
**Tek cümle:** Oyunun B2C ürünü iki taraflı bir pazaryeri olur: oyuncu gerçek ana kategorileri istediği zaman açar, her
kategoriye mağaza kazanmak için emek harcar, kategori başına komisyonu ve dört alışveriş kuralını ayarlar, ziyaretin siparişe
dönüştüğü yolu modül modül onarır ve Premium üyeliği kurar; gelir komisyon ve üyeliktir, kapılar aylık gelire bakar.
**Çıktı:** main'e yaklaşık 109 commit (93 ile 128; push yok), §11'deki paket sırasıyla; her commit kendi kapısı, §9 incelemesi ve görsel
kabulüyle. Not ve video ürünleri oyundan kalkar.
**Yerini aldığı:** `PRD_URUN_DERINLIK.md` §3'ün (Faz 2 · Pazaryeri) ve tur 3 planının (`pazar_tasarim_2026-11-12/tur3/`)
pazaryeri tarifi. Çelişkide bu belge geçerlidir (yardımcı yönetmenin onayıyla).
**Dayanak belgeler** (aynı klasör ağacında, `tur4_ekranlar_2026-11-13/pazaryeri/`): `TEKNIK_KESIF.md` (dokunma noktaları,
kayıt, testler; HEAD `f4307fb9`), `ORTAK_ARAYUZLER.md` (Pazarlama, Talepler ve ERP ile adlar ve iniş sırası), `kareler/`
(yenilenen kareler), `arastirma/` (kaynak sicilleri). Depo dosyaları bu belgelere atıf yapmaz.

## Erdem için kısa özet

- **Oyuncu altı gerçek ana kategoriyle çalışır:** Moda, Elektronik, Ev ve Yaşam, Kozmetik ve Kişisel Bakım, Anne ve Bebek, Spor
  ve Outdoor. Kategoriyi istediği zaman açar; kategori boş açılır ve mağazayı emekle kazanır (kurucu ya da satışçı).
  "Bekleyen mağaza", "İlk raf" olayı, kategori kartı ve "raf" sözü yoktur.
- **Kategoride gördüğü:** mağaza, haftalık sipariş, satış hacmi, iade ("bizde %22, sektör ortalaması %20"), reklam doyumu,
  komisyon ve o kategoriye mağaza kazanan kişi. Tanıtım cümlesi yok.
- **Genel sayfası** ziyaretin siparişe dönüştüğü beş adımı gösterir; her yüzde neye göre olduğunu söyler ("önceki adımdan
  geçen"). En zayıf adımın ipucu ne yapılırsa haftada kaç sipariş kazanılacağını yazar.
- **Politikalar dört kuraldır:** kargo ücreti, iade süresi, iade kargosu, mağaza kabulü. "Yük kimde" gösterimi, kargoya verme
  süresi ve ödeme vadesi yok. Seçenek seçilince sonucu önizlenir, Uygula ile dört hafta kilitlenir.
- **Premium:** ücret ve dört ayrıcalık (kargo bedava, hızlı teslimat, adresten iade, üyelere özel indirim). Her ayrıcalık o ay
  kaç siparişte kullanıldığını ve kaça mal olduğunu yazar. "30 gün iade" yok.
- **Ürün penceresinde "Çekirdek" yok:** özellikler işlev modüllerine ayrılır (Ürün Yükleme, Vitrin, Sepet ve Ödeme, Siparişler,
  Yorum ve Güvence ve öbürleri). Yayın şartı ilk dört modülün ilk kademesidir.
- **Senden beklenen:** §12'de on soru (komisyonun siparişe etkisi, iade kargosunda hukuk, ilk mağazalar, aylık gelirin
  okunuşu, adlar, başlangıç sayıları).

## 0. Kararlar

### 0.1 Erdem'in kararları
| Tarih | Karar | Bu PRD'de |
|---|---|---|
| 12 Kasım | Platform şirketi; tek tip mağaza ve tek tip kullanıcı; politikalar oyuncunun; yoğun etiketli yazı yok | §1, §4 |
| 13 Kasım | Kapılar pazaryerinde de aylık gelire bakar | §3.6 |
| 13 Kasım | Oyuncu bazı özellikleri Premium'a alabilmeli | §3.10 |
| 13 Kasım | Sayfanın sayıları Aktif kullanıcı, Mağaza, Haftalık sipariş; "Alıcı" ve "Satıcı" başlığı yok (karar 9) | §1, §4.1 |
| 13 Kasım | Sayı ayarı playtest'te; tasarım mekaniği ve bağlarını anlatır | §9; başlangıç değerleriyle kurulmasının onayı §12 soru 10 |
| 13 Kasım akşam | Not ve video ürünleri oyundan kalkar; demoda Pazaryeri ve ERP | §2.5, §11 |
| 13 Kasım akşam | Ödeme vadesi yok; kargoya verme süresi yok; "Yük kimde" her ekrandan kalkar; Premium'da "30 gün iade" yok | §3.9, §3.10, §4 |
| 13 Kasım akşam | "Raf" kavramı oyundan çıkar; "bizi bekleyen mağaza" yok; "İlk raf" olayı reddedildi | §3.2, §3.4 |
| 13 Kasım akşam | Kategoriler 5 ile 6 gerçek ana kategoridir; oyuncu istediği zaman açar, mağaza kazanmak için emek harcar; iade sektöre göre ("sektör ortalaması şu, bizde bu"); uydurma açıklama yok | §3.2, §4.3 |
| 13 Kasım akşam | "Yeni mağazaya ilk 8 hafta yarı komisyon" ekranda değil, bir olay olarak gelir | §5.1 |
| 13 Kasım akşam | Yayın şartı şeridi kalır; "tahmin … hafta" yazısı kalkar; "Çekirdek" gruplaması kalkar, özellikler işlev modüllerine ayrılır | §2.2, §2.3 |
| 13 Kasım akşam | Dokuz ortak kural (`ERDEM_YORUMU_TUR4.md` §3) | §1 |

### 0.2 Yardımcı yönetmenin kararları (13 Kasım; adlar Erdem'in onayında)
- Taraf adları her ekranda "kullanıcı" ve "mağaza". Kategoriler'in kullanıcı tarafı göstergesi "Reklam doyumu" (sahibi Pazarlama).
- Frank'in çek listesi pazaryerinde bugünkü beş adımdır; yalnız dördüncüsünün metni "İlk sipariş" olur.
- Satış rolünü pazaryerinde bu PRD açar, mağaza kazanımıyla birlikte (§3.4).
- Aylık gelirin okunuşu (son dört haftanın net komisyonu) öneridir ve Erdem'in onayına gider (§3.6, §12 soru 4).

### 0.3 Öbür oturumlarla uzlaşılanlar
`ORTAK_ARAYUZLER.md` (bu PRD ile aynı gece hizalandı) adları ve iniş sırasını taşır: sistemler birbirinin durumunu yazmaz,
okur (Pazarlama `channel_visits`, `return_lift`, `impression_share`, `active_campaign`; Pazaryeri `channel_read`,
`source_revenue`, `policy_value`, `request_topics`); tek şema artışı bu PRD'nin sistem paketindedir; iniş sırası yedi
dalgadır. İkisi ayrışırsa bu PRD geçerlidir. Modül şeması URUN'undur (`erp_tasarim_2026-11-12/MODUL_SEMASI.md`): modül bugünkü
hattın kendisidir, üstünde grup yoktur.

## 1. Kurallar

`CLAUDE.md`'nin kuralları aynen geçerlidir (WRITE-THROUGH, BILINGUAL BIRTH, UI/STYLE, kod yazımı, her commit'e inceleme ve
görsel kabul). Bu PRD'ye özgü olanlar:
1. **Sözcükler.** Taraflar "kullanıcı" ve "mağaza"dır; "alıcı", "satıcı", "müşteri" yazılmaz. "Raf" ve "bekleyen mağaza"
   sözleri ile "Yük kimde" gösterimi hiçbir ekranda yoktur. Ödeyen taraf Politikalar'da "biz"dir ("Biz öderiz"; §12 soru 3).
   Gelirin adı pencerede "Aylık gelir"dir.
2. **Tanıtım cümlesi yok.** Kategorinin, modülün, kuralın altında kendi yazdığımız açıklama durmaz. Tanım gerekiyorsa ipucundadır.
3. **Oyuncunun bilemeyeceği bilgi gösterilmez.** Sektör ortalaması gibi herkesin bilebileceği sayı gösterilir; mağazanın niyeti
   gibi bilinemeyecek şey gösterilmez.
4. **"Kilitli" yazılmaz, şart yazılır** ("Kullanıcı Koruması çıkınca", "1★ tasarımcı gerekli", "v1.0 yayınlanınca başlar").
5. **Her sayı neye göre olduğunu söyler:** birim, sütun başlığı ya da karşılaştırma ("sektör ortalaması %20") ile. Anlatılamayan
   sayı ekrana konmaz.
6. **Önizleme yalnız tartılan seçeneğindir.** Oyuncu seçmediği seçeneklerin sonucunu tablo olarak görmez; bir seçeneği
   seçince sonucu çiplerle önizlenir, Uygula ile yürürlüğe girer.
7. **Kilit düğmenin yanında söylenir.** Uygula'nın yanında kilit glifi ve tek satır durur: "Dört hafta değişmez".
8. **Angarya yok.** Bir ayar ekranı bir karar taşır; aynı karar iki yerde verilmez; haftalık bakım isteyen ayar yoktur.
9. **Sabitlerin yeri bellidir** (§9: kategori sabitleri `categories.json`, modüller `lines/marketplace.json`, öbürleri
   `marketplace.json`) ve her biri [WORKING] işaretlidir.
10. **Metinler taslaktır:** TR ve EN anahtar olarak doğar, commit mesajında "TR/EN onay bekliyor" diye işaretlenir. Frank'in
    satırı bu PRD'de yoktur.

## 2. Ürün: tür, modüller, yayın şartı

### 2.1 Tür
- Kimliği `marketplace`; `ProductCatalog`'da B2C pazarında oynanabilir tür (`product_catalog.gd:8-62`). `market_type` değeri
  "b2c" kalır: "b2c" okuyan yerler ve kartların `market: "b2c"` koruması değişmeden çalışır (`gate.gd:250-257`). Not ve video
  kalktığı için "b2c" tek bir ekonomiyi gösterir.
- Bilinmeyen tür kimliği bugün sessizce "b2c" okunuyor (`product_catalog.gd:198`); bu PRD'yle hata verir.
- Tür seçim ekranı ARAYUZ'undur; tür ona kimliğini ve metin anahtarlarını verir. Pencerenin ve rayın adı "Pazaryeri"dir
  (`left_tabs.gd:144-147`).

### 2.2 Modüller
Modül, işleviyle adlandırılmış tek bir özellik ailesidir: bugünkü hattın kendisi, üç adlı kademesiyle. Üstünde grup yoktur;
Ürün penceresinin sol sütunu modülleri düz liste olarak, bu sırayla gösterir. Veri `data/product/lines/marketplace.json`.

| # | Modül | 1. kademe · 2. kademe · 3. kademe | Yayın şartı | Ne işe yarar |
|---|---|---|---|---|
| 1 | Ürün Yükleme | Tek Tek Ürün Ekleme · Toplu Yükleme · Katalog Eşleme | evet | Mağaza kazanımı ve mağazanın kalışı (§3.4) |
| 2 | Vitrin | Kategori Sayfası · Arama ve Filtre · Kişisel Öneri | evet | Sepete ekledi |
| 3 | Sepet ve Ödeme | Kartla ve Kapıda Ödeme · Tek Sayfa Ödeme ve Taksit · Kayıtlı Kart | evet | Sipariş verdi |
| 4 | Siparişler | Sipariş Kaydı · İade Talebi · Stok Eşitleme | evet | Teslim edildi |
| 5 | Yorum ve Güvence | Yorum ve Puan · Kullanıcı Koruması · Sahte Avı | | İade oranını düşürür (§3.6); Kullanıcı Koruması kademesi Mağaza kabulü kuralını açar |
| 6 | Mobil | Duyarlı Arayüz · Mobil Uygulama · Çevrimdışı Mobil | | Ödemeye geçti |
| 7 | Entegrasyonlar | Tekil Bağlantı · Çoklu Entegrasyon · Açık API & Webhook | | Teslim edildi; Premium'da kargo ve hızlı teslimat |
| 8 | Kullanıcılar ve Yetki | Hesap & Oturum · Roller ve İzinler · Denetim İzi & Şifreleme | | Yokken 1.000 kullanıcıdan sonra "Hesap güvenliği zayıf" satırı yazılır (§3.8) |
| 9 | Yedekleme | Otomatik Kayıt · Sürüm Geçmişi · Çevrimdışı Çalışma | | Kesintide kaçan siparişi azaltır (§3.8) |
| 10 | Üyelik | Üyelik Programı (tek kademe) | | Premium sayfasını açar |

- 6 ile 9 arası paylaşılan veridir (bugünkü paylaşılan hatlar; adları URUN'un şemasındaki yeni adlarla). 10, bugünkü Gelir
  alanındaki "Ücretli plan" kartıdır (`cap_paid_plan`); kimliği kalır, adı ve işi değişir.
- Modülün ek özellikleri vardır: kademe olmayan, Talepler'den plana alınan küçük kartlar (§3.11; demodaki liste
  `TALEPLER_ICERIK.md` §3). Her ek özellik bir modüle bağlıdır ve o modülün satırında durur.
- "Siparişler" modülünün adı açık sorudur (§12 soru 8).

### 2.3 Yayın şartı
- v1.0, ilk dört modülün ilk kademesidir (`sprint.json` `mvp_named`; 1★ beklentisi de bu listedir). Sprint ekranında dört parçalı
  şerit olarak durur: bitti, bu sprintte, bekliyor. Şerit ERP'nin ortak bileşenidir; pazaryeri kendi parçalarını veri olarak verir.
- Şeritte yayın tahmini ("tahmin … hafta") ve mağaza notu yoktur.
- Pazaryerinde yayın günü mağaza sayısı sıfırdır; mağaza kazanımı yayınla başlar (§3.4, §12 soru 5).
- Mobil ve Entegrasyonlar yayın şartında değildir; yokken ilgili adım düşük çarpanla çalışır (§3.5).

### 2.4 Kapılar
Kademe başına, bugünkü gibi: ilk kademe kapısız; ikinci kademe ilgili rolün 1★'ını ister; üçüncü kademe 2★ ve bir Ar-Ge
düğümü ister. Kapıya takılan sıradaki kademe şartını yazar (kural 4). Yalnız sıradaki kademe görünür.

### 2.5 Not ve video ürünleri
Oyundan kalkar (Erdem, 13 Kasım). Sıra §11'dedir: önce test dünyaları ERP'ye çevrilir ve pazaryeri türü veriye eklenir; sistem
paketiyle birlikte not ve video tür seçiminden kalkar ve kayıtları reddedilir (§7); verileri ve metinleri okuyan paketinden
sonra silinir.

## 3. Ekonomi: `MarketplaceSystem`

Yeni statik sistem (`scripts/systems/marketplace_system.gd`). Bugünkü B2C kitle ekonomisinin yerini alır (`sales_system.gd`
`_tick_b2c_audience`, fiyat ailesi ve dört `b2c_*` bayrağı kalkar; `TEKNIK_KESIF.md` paket 2). Formüller önce saf işlev olarak
yazılır; arayüzün her önizlemesi aynı saf işlevi çağırır (§3.13). Bu bölümdeki her sayı §9'daki sabitin başlangıç değeridir.
`sınırla(x; a; b)` x'i a ile b arasına çeker.

### 3.1 Durum ve sahiplik
`GameState.marketplace` sözlüğü (anahtarlar metin; §7). Tek yazarı `MarketplaceSystem`'dir; arayüz, olay kolu ve öbür sistemler
onun işlevlerini çağırır. Her değişiklik `EventBus.marketplace_changed` yayar. Sözlük sistemin ilk yazışında ya da ilk
kapanışında dolar; okumak onu doldurmaz ve pazaryeri koşusu olmayan oyunda (ERP) boş kalır.

| Anahtar | İçerik |
|---|---|
| `users`, `members` | Aktif kullanıcı ve içindeki Premium üyesi |
| `sources[kaynak]` | Son on iki haftada o kaynaktan gelen yeni kullanıcı, hafta hafta (kaynak: `organic` ya da Pazarlama'nın kanal ve kampanya kimliği) |
| `cats[kimlik]` | `open`, `open_day`, `commission` (yüzde), `commission_day`, `stores`, `joined` (son sekiz haftada katılan mağaza, hafta hafta), `terms` (yeni mağaza şartı: alınan pay ve hafta; yoksa boş), `week` (geçen haftanın sayıları: organik ve kanal ziyareti, sepet, ödeme, sipariş, teslim, iade, net komisyon) |
| `assign` | Kişi kimliği → `cat` (kategori) ve `live` (atama bir kapanıştan geçti) |
| `policy[kural]` | `pick` (seçenek), `day` (son değişikliğin günü) |
| `premium` | `open`, `fee`, `fee_day`, `trial`, `joined` (son dört haftada katılan üye), `perks[ayrıcalık]` (`pick`, `day`, son dört haftanın kullanımı ve bedeli) |
| `ledger` | `users` ve `stores`: adlı satırlar (`key`, `arg`, `points`, `weeks`) |
| `revenue_weeks` | Son dört haftanın net komisyonu |
| `topics[kimlik]` | `tickets` (son dört haftanın bileti, hafta hafta), `since_day` (ilk isteğin haftası), `status` (`waiting`, `planned`, `shipped`), `source` (`tickets` ya da `report`); rapordan açılan konuda `affected` (raporun verdiği haftalık etkilenen sipariş) |
| `lost` | `users` ve `stores`: kaybedilen kullanıcının ve ayrılan mağazanın birikmiş toplamı |
| `waive` | Komisyonun alınmayacağı kalan hafta sayısı (acil durumun "bir hafta komisyon almamak" şıkkı; §5.2) |
| `outage` | Bekleyen kesinti: `points` (kullanıcı defterine yazılacak düşüş) ve `cost` (net komisyondan düşecek tutar); izleyen kapanış uygular ve sıfırlar |
| `latches` | Olay 5.1'in geldiği kategoriler |

- İki kalabalık `CustomerRegistry`'de iki toplu kayıttır: kullanıcılar ve mağazalar. Memnuniyetleri bu kayıtlarda durur
  (`set_satisfaction`). **Komisyon geliri mağazalar kaydının, üyelik geliri kullanıcılar kaydının MRR'ına yazılır**
  (`set_mrr`); toplam gelir bugünkü gibi `SalesSystem.reflect_mrr()` ile yansır. Kayıtlar yayından sonraki ilk kapanışta
  doğar ve yalnız kapanışta güncellenir. Koltuk, mağazalar kaydında açık kategorilerin mağaza toplamı, kullanıcılar
  kaydında ücret ödeyen üyedir (denemedeki üye ödemez). Net komisyon eksiye düşerse mağazalar kaydının MRR'ı sıfırda
  durur; `revenue_weeks` eksiyi saklar. İki kayıt hesap sayılmaz: `CustomerRegistry.account_count()` bireysel
  (`individual`) toplu kayıtları saymaz.
- Her şey haftalıktır: sistemin tek tiki haftalık kapanıştır ve günlük dağıtımın Satış yuvasında çalışır
  (`time_manager.gd:409`; sprint kapanışından ve Pazarlama tikinden sonra, Finans'tan önce). Saatlik tiki yoktur.
- Sınırlar: komisyon %1 ile %30 arası tam sayı; Premium ücreti $1 ile $15 arası tam sayı.

- Saf çekirdek (`MarketplaceModel`) oyun durumundan bağımsız koşsun diye sözlükte üç alan daha durur: `sat` (iki memnuniyet),
  `burn` (haftalık `pazaryeri` gider kalemleri) ve `premium.orders` (üye siparişi). Sistem `sat`'ı iki kaydın memnuniyetine
  yansıtır.
  Çekirdek oyunun geri kalanını `world` sözlüğünden okur; onu her kapanışta sistem kurar: hafta, ürünün yayında olup
  olmadığı, modül kademeleri ve açık hataları, yayındaki ek özellikler (`features`) ve sprint planındaki konular (`planned`;
  ikisi de konu kataloğunun kimliğiyle: sistem ürünün kartını bu kimliğe eşler), Pazarlama'nın değerleri ve cevapsız
  bildirimin payı. Kesinti dünyadan gelmez: acil durum onu duruma yazar (`outage`), izleyen kapanış uygular.

### 3.2 Kategoriler
- Altı kategori, veri `data/product/categories.json`. Tanıtım metni yoktur.
- **Açma:** `open_category(kimlik)`; bedelsiz, anında, yayından önce de yapılabilir; demoda geri kapatılmaz. Açılan kategori
  boş başlar: mağaza 0, komisyon kategorinin başlangıç oranı.
- **Seçenek:** `seçenek = min(1; mağaza ÷ seçenek için gereken mağaza)`. Ayrı bir gösterge olarak çizilmez; mağaza sayısından
  ve "Sepete ekledi" adımından okunur.

| Kategori | Sepet | Ziyaret sıklığı | Kâr payı | Sektör iade ortalaması | Seçenek için mağaza | Başlangıç komisyonu | Taban ilgi (haftalık ziyaret) | Büyük sepet payı | Reklam havuzu (haftalık arama) |
|---|---|---|---|---|---|---|---|---|---|
| Moda | $38 | 0,30 | %22 | %20 | 30 | %10 | 450 | 0,25 | 82.000 |
| Elektronik | $95 | 0,14 | %13 | %9 | 30 | %6 | 250 | 0,80 | 46.000 |
| Ev ve Yaşam | $32 | 0,27 | %19 | %12 | 17 | %9 | 210 | 0,20 | 38.000 |
| Kozmetik ve Kişisel Bakım | $22 | 0,35 | %25 | %5 | 20 | %11 | 150 | 0,10 | 27.000 |
| Anne ve Bebek | $28 | 0,40 | %18 | %8 | 20 | %8 | 120 | 0,15 | 22.000 |
| Spor ve Outdoor | $45 | 0,15 | %20 | %12 | 25 | %9 | 120 | 0,40 | 22.000 |
- Sepet, sıklık, kâr payı ve gereken mağaza ilk üç satırda kâğıt simülasyonunun ayar adayıdır
  (`tur4_ekranlar_2026-11-13/pazaryeri/sim/pazaryeri_sim.py` `CATS`); son üç satır ve son üç sütun varsayımdır. "Reklam havuzu" Pazarlama'nın reklam doyumunu hesapladığı sayıdır (o
  kategorideki haftalık arama; Pazarlama okur). Adlar
  pazaryerlerinin 2012 ve bugünkü menülerinden (`arastirma/d_kategori_iade.md`). İade sıralaması kaynaklı, sayılar düşük
  güvenlidir (Moda için Türkiye 2024 verisi yüzde 19,84; Anne ve Bebek için kaynak bulunamadı). "Büyük sepet payı", kargo
  kuralındaki eşiğin ($50) üstünde kalan siparişin payıdır.
- **Her kategoriyi birden açmanın bedeli:** emek kategori başına bölünür (§3.4), pazarlama bütçesi kategori başına ayrıdır ve
  mağazası az olan açık kategori kullanıcı defterine satır yazar (§3.8, "Seçenek az").

### 3.3 Haftalık kapanış (sıra bağlayıcıdır)
1. Mağaza akışı (§3.4). 2. Ziyaret ve dört adım, kategori kategori (§3.5). 3. İade (§3.6). 4. Kullanıcı (§3.7). 5. Gelir ve
giderler (§3.6). 6. Premium üyeleri ve ayrıcalıkların kullanımı (§3.10). 7. Defter ve iki memnuniyet (§3.8). 8. Talepler'in
biletleri (§3.11). 9. Olay 5.1'in isteği. 10. `marketplace_changed`. Pazarlama'nın değerleri okunur, yazılmaz (§3.12).
Kapanış yalnız ürün yayındayken koşar; kategori açmak yayından önce de serbesttir.

### 3.4 Mağaza: payı, bölgesi, kazanımı ve kaybı
- **Mağazaya kalan** (sepetin payı olarak), kategori başına:
  `kalan = kâr payı − komisyon − kargo payı − iade kargosu payı + fiyata yansıyan`.
  - Kargo payı: kargo ücreti kuralı "Kullanıcı öder" ise 0; "Büyük sepette mağaza öder" ise `büyük sepet payı × 3 ÷ sepet`;
    "Hep mağaza öder" ise `3 ÷ sepet`. Kampanya kargoyu bedava yapmışsa 0 (biz öderiz).
  - İade kargosu payı: "Mağaza öder" ise `iade oranı × 3 ÷ sepet`; "Biz öderiz" ise 0.
  - Fiyata yansıyan: `0,5 × max(0; komisyon − başlangıç komisyonu)`. Mağaza komisyon artışının yarısını fiyatına ekler.
- **Bölge:** `kalan ÷ kâr payı` 0,40 ve üstü rahat; 0,33 ve üstü zorlanır; altı ayrılır. Kategoriler'deki aralık çubuğunun iki
  sınırı, öbür kurallar bugünkü hâliyle dururken bölgenin değiştiği komisyon oranlarıdır (tam sayıya aşağı yuvarlanır). Kargo
  ve iade kargosu kuralı değişince çubuk kayar.
- **Mağazanın kazancı** çipi `kalan`'ın yüzde değişimidir (Moda'da %12'den %13'e: −%5).
- **Kazanım** ürün yayınlanınca başlar; yayından önce mağaza sıfırdır. Bir kişi bir kategoriye atanır (`assign`). Atanan,
  kurucu ya da Satış Temsilcisi olabilir; bir kategoride birden çok kişi çalışabilir. Atamanın bedeli bir haftalık
  kazanımdır: yeni atanan ya da kategorisi değişen kişi ilk kapanışta mağaza kazandırmaz (taşınan kişi eski kategorisinde
  de kazandırmaz), sonraki kapanışlarda kazandırır. Yalnız işten ayrılanın ataması silinir; izne çıkan ya da eğitime giden
  kişi atamasını korur ama işbaşında olmadığı kapanışta mağaza kazandırmaz. İki kural onay bekliyor; ikisi de atama
  yapılırken ekranda görünür (§4.3). Kurucunun ataması bugünkü Satış işi gibi sprint payından yer. Satış rolü pazaryerinde
  açılır: `hr_constants.gd:374-378`, `hr_assignments.gd`'deki hücre kilidi ve `hr_system.gd:304-306` üçü birlikte değişir.
  Kişi başına haftalık kazanım:
  `taban(yıldız) × bölge çarpanı × kabul çarpanı × Ürün Yükleme çarpanı × şart çarpanı`.
  Taban 1★ 2, 2★ 3, 3★ 4, 4★ 6, 5★ 8 mağaza (kurucu 1★ sayılır). Bölge: rahat 1; zorlanır 0,6; ayrılır 0,2. Kabul: "Yalnız
  vergi levhalı" 0,6. Ürün Yükleme: 1. kademe 1; 2. kademe 1,5; 3. kademe 2. Şart: olay 5.1'in şıkkına göre 1,4 ya da 1,8.
- **Kendiliğinden gelen mağaza:** haftada `aktif kullanıcı × 0,0004 × kategorinin ziyaret payı` (ziyaret payı: kategorinin
  geçen haftaki ziyareti ÷ bütün ziyaret; ziyaret yoksa açık kategoriler arasında eşit).
- **Ayrılan mağaza**, kategori başına haftada:
  `mağaza × (0,008 × kalış çarpanı + (bölge ayrılır ise 0,03) + 0,07 × sınırla(1 − mağaza başına sipariş ÷ 1,2; 0; 1)
  + 0,0015 × max(0; 60 − mağaza memnuniyeti))`.
  Mağaza başına sipariş, kategorinin geçen haftaki siparişi ÷ mağazasıdır. Kalış çarpanı Ürün Yükleme kademesinden: 1; 0,9; 0,8.
- `joined` her hafta kaydırılır: yeni katılan başa yazılır, sekizinci hafta düşer.

### 3.5 Ziyaretten teslimata (kategori başına)
- `geri gelen = (aktif − üye + üye × 1,4) × ziyaret sıklığı × (1 + MarketingSystem.return_lift())`
- `organik = aktif × 0,065 × memnuniyet katsayısı × seçenek × ilgi payı + taban ilgi × seçenek`
  Memnuniyet katsayısı `sınırla((kullanıcı memnuniyeti − 55) ÷ 45; 0; 1)`. İlgi payı, kategorinin taban ilgisi ÷ açık
  kategorilerin taban ilgisi toplamı.
- `kanal = MarketingSystem.channel_visits(kategori)`; `ziyaret = geri gelen + organik + kanal`. Organik ve kanal ayrı saklanır.
- Dört adım:

| Adım | Formül |
|---|---|
| Sepete ekledi | `ziyaret × 0,15 × Vitrin çarpanı × seçenek × fiyat çarpanı × ek özellik çarpanı`; fiyat çarpanı `(1 + fiyata yansıyan)^−1,5` |
| Ödemeye geçti | `sepete ekleyen × 0,70 × kargo çarpanı × Mobil çarpanı × ek özellik çarpanı` |
| Sipariş verdi | `ödemeye geçen × 0,88 × Sepet ve Ödeme çarpanı × hata çarpanı` |
| Teslim edildi | `sipariş × 0,97 × Siparişler çarpanı × Entegrasyonlar çarpanı × hata çarpanı` |
- **Kademe çarpanı.** Yayın şartının modülleri (Vitrin, Sepet ve Ödeme, Siparişler): 1. kademe 0,83; 2. kademe 0,96; 3. kademe
  1. Yayın şartında olmayan destek modülleri (Mobil, Entegrasyonlar): hiç yokken 0,90; 1. kademe 0,95; 2. kademe 0,98; 3. kademe 1.
- **Hata çarpanı:** `1 − 0,027 × min(10; adımın modüllerindeki açık hata)`.
- **Ek özellik çarpanı.** Kullanıcı tarafındaki ek özellik (§3.11) yayında değilken bağlı olduğu adımı çarpar: Beden tablosu
  "Sepete ekledi" adımını 0,97; Favoriler "Sepete ekledi" adımını 0,99; Üyeliksiz alışveriş "Ödemeye geçti" adımını 0,95.
  Yayına çıkan özelliğin çarpanı 1'dir. Mağaza tarafındaki ek özellik adım çarpanı taşımaz.
- **Kargo çarpanı:** "Kullanıcı öder" 0,83; "Büyük sepette mağaza öder" `0,83 + 0,17 × büyük sepet payı`; "Hep mağaza öder" ya
  da kampanya kargoyu bedava yapmışsa 1.
- Çarpanların hepsi 1 olduğunda adım **ulaşılabilir oranındadır** (%15, %70, %88, %97). Teslim edilmeyen sipariş iptaldir.
- **En zayıf adım**, oranının ulaşılabilir orana bölümü en küçük olan adımdır.
- **"Sipariş" sözü.** Haftalık sipariş (pencerenin başlığı, mağaza başına sipariş, üye siparişi, `gain`, önizleme çipi, kargo ve
  iade sayıları) teslim edilen sipariştir; dönüşümdeki "Sipariş verdi" satırı verilen siparişi gösterir. Teslim edilmeyen
  sipariş gelir, kullanıcı ya da gider yazmaz.
- **Kazanılabilir sipariş** bir saf işlevdir: `gain(kategori, değişiklik)` o değişiklik bugün yürürlükte olsaydı haftalık
  siparişin kaç artacağını döndürür (bir modülün sıradaki kademesi, bir modülün açık hatalarının düzelmesi, bir kural seçeneği,
  bir ek özelliğin yayına çıkması).
  Genel'in ipucu, Talepler'in "etkilenen sipariş" sütunu ve önizleme çipleri onu okur.

### 3.6 İade, gelir, giderler ve kapı
- `iade = teslim × iade oranı`. İade oranı ("bizde"): `sektör ortalaması × süre çarpanı × iade kargosu çarpanı × kabul çarpanı
  × Yorum ve Güvence çarpanı`. Süre: 7 gün 1; 14 gün 1,08; 30 gün 1,2. İade kargosu: "Biz öderiz" 1,05. Kabul: "Yalnız vergi
  levhalı" 0,9. Yorum ve Güvence: yokken 1; kademeleriyle 0,95; 0,92; 0,90.
- Haftalık net komisyon, kategori başına: `(teslim − iade) × sepet × komisyon − yeni mağaza şartının indirimi − şirketin
  karşıladığı indirim ve kupon`. Yeni mağaza şartının indirimi: `brüt komisyon × (şart süresi içindeki katılan mağaza ÷ mağaza)
  × (1 − şartta alınan pay)`. Şirketin karşıladığı indirim ve kupon Pazarlama'nın kampanyasından ve "Üyelere özel indirim"den gelir.
  Net komisyon sınırlanmaz: şirketin büyük indirim karşıladığı haftada eksiye düşebilir.
  Komisyonun alınmadığı haftada (`waive`; §5.2) brüt komisyon bütün kategorilerde 0'dır; yeni mağaza şartının indirimi
  brütle orantılı olduğundan o da 0'dır, şirketin karşıladığı indirim yine düşer. Kesintinin bedeli (§5.2) o haftanın
  toplam net komisyonundan bir kez düşer; kategori satırlarına dağıtılmaz.
- **Aylık gelir** (öneri, onay bekliyor; §12 soru 4):
  - komisyon geliri = `revenue_weeks` toplamı × 4,33 ÷ 4; mağazalar kaydının MRR'ına yazılır (yayının ilk dört haftasında
    sayı bu yüzden haftadan haftaya dolar);
  - üyelik geliri = `(üye − deneme süresindeki üye) × ücret`; kullanıcılar kaydının MRR'ına yazılır.
  Reklam gideri gelirden düşülmez. B2B'de MRR bugünkü gibi brüt kalır. Kapı çıtaları değişmez (`angel_round_system.gd:27`
  2.500; `seed_round_system.gd:72`'nin okuduğu `SeedConstants.DOOR_MRR` 20.000; `phase_gate_system.gd:49-57` 120.000).
- **Giderler** Finans'ta yeni bir kalemde toplanır (`pazaryeri`; `finance_system.gd:15-27`'ye altıncı kalem) ve her hafta
  `FinanceSystem.set_burn_category("pazaryeri", haftalık tutar × 4,33)` ile yeniden yazılır: "Biz öderiz" iade kargosu
  (`iade × 3`), kampanyanın bedava kargosu (`sipariş × 3`; Premium'un "Kargo bedava"sı açıksa üye siparişi o satıra, kalanı buraya
  yazılır) ve Premium'un ayrıcalık giderleri (§3.10). Kalemin ipucu bu
  kalemleri adlarıyla listeler.
- Finans özetine gelir dökümü kartı gelir: kategori başına komisyon ve üyelik (`finance_ozet_view.gd:350-382`).

### 3.7 Kullanıcı
- `yeni kullanıcı = Σ teslim × (organik + kanal) ÷ ziyaret` (kategoriler toplamı; organik ve kanal ziyaretinden doğan,
  teslim edilen sipariş; iptal edilen sipariş kullanıcı kazandırmaz).
- `elde tutma = sınırla(0,94 + 0,0005 × (kullanıcı memnuniyeti − 70) + süre katkısı + 0,03 × üye ÷ aktif; 0,85; 0,99)`. Süre
  katkısı iade süresinden: 7 gün 0; 14 gün 0,005; 30 gün 0,01.
- `aktif(h+1) = aktif × elde tutma + yeni kullanıcı`. Yeni kullanıcı kaynağına göre `sources`'a yazılır (organik; kanal
  ziyaretinden doğanlar Pazarlama'nın verdiği kanal ve kampanya kimliğiyle); on üçüncü hafta düşer.
- "Geri dönen kullanıcı" göstergesi: `geri gelen ziyaretten doğan sipariş ÷ sipariş`.
- Kaybedilen kullanıcı (`aktif × (1 − elde tutma)`) ve ayrılan mağaza her kapanışta `lost`'a eklenir (§3.1). `add_users(n)` bir
  olayın kullanıcı eklemesi ya da çıkarmasıdır: kullanıcı sıfırın altına inmez, üye kullanıcıyı aşmaz, `sources`'a yazılmaz.

### 3.8 Memnuniyet defteri
İki defter: kullanıcılar ve mağazalar. Hedef `70 + satırların toplamı` (0 ile 100 arası); memnuniyet hedefe haftada en çok 5
puan yaklaşır. "Sürdükçe" yazan satır koşul sürdüğü her kapanışta yeniden yazılır ve koşul bitince düşer; süreli satır
yazıldığı haftadan sayılır ve süresi dolunca düşer.

| Satır | Taraf | Puan | Süre | Ne zaman |
|---|---|---|---|---|
| Komisyon artışı: {kategori} | mağaza | artan puan başına −2 | 8 hafta | Her artışta |
| Zorlanıyor: {kategori} | mağaza | −4 | sürdükçe | Kategori "zorlanır" bölgesinde ve mağazası var |
| Kazancı yetmiyor: {kategori} | mağaza | −10 | sürdükçe | Kategori "ayrılır" bölgesinde ve mağazası var |
| İade süresi | mağaza | 14 gün −3; 30 gün −6 | sürdükçe | Kural o seçenekteyken |
| İade süresi | kullanıcı | 14 gün +2; 30 gün +4 | sürdükçe | Kural o seçenekteyken |
| İade kargosunu biz ödüyoruz | mağaza | +5 | sürdükçe | "Biz öderiz" |
| Vergi levhalı mağazalar | kullanıcı | +3 | sürdükçe | "Yalnız vergi levhalı" |
| Seçenek az: {kategori} | kullanıcı | −3 | sürdükçe | Yayındaki ürünün açık kategorisinde seçenek 0,2'nin altında |
| Geç teslimat | kullanıcı | −4 | sürdükçe | Teslim edilen ÷ sipariş 0,90'ın altında |
| Destek yığını | kullanıcı | cevapsız bildirimin payı × −20, en çok −10 | sürdükçe | Destek'te cevapsız bildirim varken |
| Hesap güvenliği zayıf | kullanıcı | −3 | sürdükçe | Aktif kullanıcı 1.000'i geçmiş ve Kullanıcılar ve Yetki modülü yokken |
| Karşılandı: {konu} | konunun tarafı | +3 | 8 hafta | Konunun özelliği yayına çıkınca |
| Geciken talep: {konu} | konunun tarafı | −4 | sürdükçe | Taraf başına tek satır: sekiz haftayı geçmiş en eski konunun adıyla; planda olan konu da yayına çıkana kadar sayılır |
| İndirim günlerinde zarar | mağaza | −4 | 6 hafta | Kampanya bitince, katılan mağazaların kazancı eksiye düştüyse |
| Hızlı teslimat yalnız üyeye | kullanıcı | −3 | 8 hafta | Hızlı teslimat "Herkese"den "Premium'a" alınınca |
| Hızlı teslimat | kullanıcı | +3 | sürdükçe | Hızlı teslimat "Herkese" |
| Adresten iade | kullanıcı | +2 | sürdükçe | Adresten iade "Herkese" |
- Kesinti acil durumu bugünkü gibi `IncidentSystem`'den gelir; kullanıcı memnuniyetine yazdığı düşüş izleyen kapanışta deftere
  "Kesinti" adıyla 4 haftalık satır olarak girer (tutarı olayın planından; `note_outage`). Yedekleme modülü kesintide kaçan
  siparişi azaltır: yokken × 1; kademeleriyle × 0,7; × 0,5; × 0,3 (`backup_mult`).
- Genel sayfası iki satırın yanında en ağır olumsuz satırın kısa adını gösterir ("Geciken talep", "Geç teslimat"; konunun ve
  kategorinin adı ipucunda); ipucu bütün satırları tam adıyla ve puanıyla listeler.
- Etkisi: kullanıcı memnuniyeti organik ziyareti ve elde tutmayı (§3.5, §3.7), mağaza memnuniyeti mağazanın kalışını (§3.4) oynatır.

### 3.9 Kurallar (Politikalar)
Dört kural. `set_policy(kural, seçenek)` kuralı değiştirir ve dört hafta kilitler; kilit içindeki çağrı reddedilir.
`preview_policy(kural, seçenek)` aşağıdaki çiplerin dört hafta sonraki farkını döndürür (önizleme kuralı §3.13).

| Kural | Seçenekler (ilki varsayılan) | Etkilediği yer | Önizleme çipleri |
|---|---|---|---|
| Kargo ücreti | Kullanıcı öder · Büyük sepette mağaza öder · Hep mağaza öder | Kargo çarpanı (§3.5); mağazanın kargo payı ve bölgesi (§3.4) | Haftalık sipariş · Mağazanın kazancı · Aylık gelir |
| İade süresi | 7 gün · 14 gün · 30 gün | İade oranı (§3.6); elde tutma (§3.7); iki defter (§3.8) | Geri dönen kullanıcı · İade oranı · Mağaza memnuniyeti · Aylık gelir |
| İade kargosu | Mağaza öder · Biz öderiz | Mağazanın iade kargosu payı ve bölgesi (§3.4); iade oranı; `pazaryeri` kalemi; mağaza defteri | Mağaza memnuniyeti · İade oranı · Aylık gider |
| Mağaza kabulü | Herkese açık · Yalnız vergi levhalı | Mağaza kazanımı (§3.4); iade oranı; kullanıcı defteri | Mağaza kazanımı · İade oranı · Kullanıcı memnuniyeti |
- İade süresinde "Aylık gelir" çipinin ipucu nedenini yazar: "İade edilen siparişten komisyon alınmaz." 7 gün 2012'nin yasal
  alt sınırıdır.
- Mağaza kabulü, Yorum ve Güvence modülünün Kullanıcı Koruması kademesi çıkınca açılır; o zamana kadar satır şartını yazar.
- Süreli kampanya kuralı ezer: `policy_value(kural)` önce `MarketingSystem.active_campaign().overrides`'a bakar. Demoda tek
  ezme, indirim günlerinin "Kargo: Bedava" ayarıdır: kampanya süresince kargo çarpanı 1 olur, mağazanın kargo payı 0 olur ve
  kargoyu biz öderiz (§3.6). Saklı seçim ve kilit sayacı değişmez; kampanya bitince saklı seçim yürürlüktedir.
- İade kargosunda "Kullanıcı öder" seçeneği yoktur: 2012'de cayma hakkında masraf tüketiciye yüklenemiyordu (§12 soru 2).

### 3.10 Premium
- Üyelik Programı çıkınca açılır. Ücret başlangıçta $4'tür; ücret ve her ayrıcalık değişikliği dört hafta kilitlenir.
  `preview_premium(değişiklik)` çipleri aynı önizleme kuralıyla (§3.13) döndürür: Üye, Haftalık sipariş, Aylık gelir ve değişikliğe göre Ayrıcalık gideri ya
  da Kullanıcı memnuniyeti.
- **Üye:** `hedef = aktif × 0,012 × çekim ÷ (1 + 0,25 × (ücret − 4))`; her hafta `üye += (hedef − üye) × 0,10`. "30 gün
  ücretsiz dene" açıkken oran 0,20 olur ve son dört haftada katılan üye ücret ödemez (`premium.joined`). Çekim, aşağıdaki
  tablodaki puanların toplamıdır.
- **Üye siparişi:** `sipariş × üye × 1,4 ÷ (aktif − üye + üye × 1,4)`. Üyenin ziyaret sıklığı 1,4 kattır; sepeti büyümez.
- **"Bu ay"** son dört haftadır (aylık gelirle aynı pencere). Her ayrıcalık son dört haftanın kullanımını ve bedelini saklar.

| Ayrıcalık | Seçenekler (ilki varsayılan) | Çekim | Etkisi ve bedeli | Şartı |
|---|---|---|---|---|
| Kargo bedava | Kapalı · Premium'a | 3 | Kargosunu kullanıcının ödeyeceği üye siparişi başına $3 `pazaryeri` kalemine ("Büyük sepette mağaza öder" kuralında büyük sepetli sipariş sayılmaz). Kural "Hep mağaza öder" ise çekimi ve bedeli 0'dır; satır "Kural zaten veriyor" yazar. Kampanya kargoyu bedava yaptığı haftalarda da satıra saklı kurala göre yazılır (kalan siparişin kargosu kampanyanın satırına); çekim değişmez | Entegrasyonlar · Tekil Bağlantı |
| Hızlı teslimat | Kapalı · Herkese · Premium'a | Premium'a iken 2 | "Herkese": kullanıcı defterine +3. "Premium'a": üyeye özel; "Herkese"den alındıysa defterdeki −3 satırı | Entegrasyonlar · Çoklu Entegrasyon |
| Adresten iade | Kapalı · Herkese · Premium'a | Premium'a iken 1 | İade başına $3 `pazaryeri` kalemine: "Herkese" iken her iade, "Premium'a" iken üyenin iadesi (`iade × üye siparişi ÷ sipariş`). "Herkese": kullanıcı defterine +2 | Siparişler · İade Talebi |
| Üyelere özel indirim | Kapalı · Premium'a | 2 | Üye siparişinde sepetin %5'i şirketin karşıladığı indirimdir; gelirden düşer (§3.6) | yok |
- Premium'a alınabilen özellikler Hızlı teslimat ve Adresten iade'dir; oyuncu önce herkese açıp sonra üyeye özel yapabilir.
  Modül ya da kademe Premium'a alınmaz.
- Varsayılan "Kapalı" olduğu için Premium açılmadan hiçbir ayrıcalık gider yazmaz.

### 3.11 Talepler
- `request_topics()` satırları döndürür: konu, taraf, modül, son dört haftanın bileti, haftada etkilenen sipariş, neden,
  durum, konunun yaşı, kaynak. Demodaki konu kataloğu ve bilet oranları `tur4_ekranlar_2026-11-13/pazaryeri/
  TALEPLER_ICERIK.md` §2 ve §3'teki on iki konudur; katalog `data/product/marketplace.json`'a girer (konu, taraf, modül, sıradaki
  kademe ya da ek özellik, bağlı adım, bilet oranı; kullanıcı tarafındaki ek özellikte eksikken adım çarpanı).
- **Kullanıcı bileti** (haftalık): konunun bağlı olduğu adımda kaybedilen sayı × konunun bilet oranı (Sepete eklemeyen
  ziyaretin binde 1'i; ödemeye geçmeyen sepetin %1'i; tamamlanmayan ödemenin %4'ü; siparişin %2'si; iade edilen siparişin
  %8'i; siparişin %1'i). **Mağaza bileti:** derdi olan mağazaların payı × konunun oranı (50'den çok ürünü olan mağazaların
  %8'i; haftada 10'dan çok sipariş alanların %6'sı; mağazaların %2'si). Derdi olan mağazaların payı sabittir: mağazaların
  0,34'ünün 50'den çok ürünü vardır, 0,22'si haftada 10'dan çok sipariş alır. Konunun özelliği yayındaysa bilet gelmez: kademe
  konusu modül o kademeye varınca, ek özellik çıkınca yayındadır. Haftanın bileti kapanıştan sonra yazılır; konunun yaşı ilk
  biletin haftasından sayılır. Hata bileti talep değildir.
- **Etkilenen sipariş:** kullanıcı konusunda konu yayına çıkınca kazanılan haftalık sipariştir (`gain`, §3.5: sıradaki kademe
  ya da ek özellik); Yorum ve Puan'da kademe çıkınca haftada iade edilmeyecek sipariştir (`teslim × (bugünkü iade oranı −
  kademeyle iade oranı)`); mağaza konusunda derdi olan mağazaların siparişi × o hafta ayrılma olasılığıdır (§3.4; sipariş
  mağaza payıyla orantılı sayılır). Yayındaki konuda 0'dır. Gösterilen sayı, konu çıkınca gerçekleşen sayıdır.
- "Plana al" konunun kartını bugünkü sprint yolundan ekler. Kapanış konunun durumunu okur (bekliyor, planda, yayında):
  kademe konusunda modülün kademesinden, ek özellikte ürünün yayındaki ek özelliklerinden, plandaki konuda sprint planından.
  İsteği gelmiş bir konu yayına çıkınca tarafına bir kez "Karşılandı: {konu}" yazılır; isteği hiç gelmemiş konu satır yazmaz.
  "Geciken talep" taraf başına tek satırdır (§3.8): ilk isteğinden bu yana sekiz haftadan çok geçmiş, yayında olmayan en eski
  konu.
- `open_topic(kimlik, etkilenen)` satırı henüz açılmamış bir konuyu rapordan açar: kaynağı `report`, ilk isteği o hafta,
  haftalık etkilenen siparişi raporun verdiği sayıdır. Konu katalogda yoksa ya da satırı zaten açıksa reddedilir.
  Pazarlama'nın kupon raporundaki "Ürüne doğrulama ekle" düğmesi bunu `coupon_abuse` konusuyla çağırır. Bu konu kataloğun on
  üçüncü kaydıdır (kullanıcı tarafı, Ödeme modülü): bilet oranı ve adım çarpanı yoktur, bilet almaz, yalnız rapordan açılır.
  Rapordan açılan konu yayına çıkınca öbür konular gibi "Karşılandı" yazar ve etkilenen siparişi 0 olur; sekiz haftayı
  geçerse "Geciken talep"e girer.

### 3.12 Pazarlama ile arayüz
`ORTAK_ARAYUZLER.md` §1. Pazaryeri kapanışta `channel_visits`, `return_lift`, `impression_share` ve `active_campaign`'i okur.
Pazarlama'ya `channel_read(kategori)` verir: ziyaretten siparişe dönüşüm, bir kullanıcının aylık komisyonu, organik ziyaret,
kategorinin kâr payı, taban ilgisi ve reklam havuzu. `source_revenue(kaynak)`, son on iki haftada o kaynaktan gelen
kullanıcıların son dört haftada bıraktığı net komisyonu döndürür (`sources` × elde tutma × kullanıcı başına net komisyon);
Pazarlama'nın kanal satırındaki gelir katkısı budur. Kampanyanın etkisi `preview_campaign(ayar)` saf işlevidir: mağazanın katılımı (indirim
derinliğinin `kalan`'a oranı ve şirketin payı), sipariş artışı, sonraki haftaların çukuru, katılıp zarar eden mağazanın defter
satırı; kapanış aynı işlevi uygular. Formülün sayıları Pazarlama'nın PRD'siyle birlikte yazılır. Pazarlama inene kadar
`channel_visits` ve `return_lift` 0, `active_campaign` boştur; Pazarlama'ya bağlı üç gösterge iki işten sonra inenin
commit'inde bağlanır, yedek dal yazılmaz.

`channel_read`'in tanımları: dönüşüm, bugünkü durumla bir ziyaretin teslim edilen siparişe dönme oranıdır (dört adımın
çarpımı; mağazası olmayan kategoride 0). Bir kullanıcının aylık komisyonu `ziyaret sıklığı × 4,33 × dönüşüm × (1 − iade oranı)
× sepet × komisyon` çarpımıdır (üyenin sıklığı, yeni mağaza şartı ve indirim hesaba girmez). `source_revenue`'da i hafta önce
gelen kullanıcı `elde tutma^i` ile küçülür; kullanıcı başına net komisyon, son dört haftanın net komisyonu ÷ aktif kullanıcıdır.
Kullanıcı o dört haftanın yalnız burada olduğu kadarıyla sayılır (`min(i + 1; 4) ÷ 4`: bu hafta gelen dörtte bir, dördüncü
haftasından itibaren tam); yeni açılan kanalın satırı bu yüzden küçük başlar. Organik kaynak da aynı formülle hesaplanır
(Pazarlama ile uzlaşma, 14 Kasım).

### 3.13 Kod öncesi: saf işlevler ve probe
Arayüzden önce §3'ün formülleri saf işlev olarak yazılır ve başsız bir probe ile koşulur (`-s res://scripts/debug/marketplace_probe.gd -- --marketplace-probe=weeks=<n>`;
haftalık satır: ziyaret, dört adım, sipariş, mağaza, kullanıcı, aylık gelir, iki memnuniyet). Probe mekaniği sınar, sayıyı
değil: boş kategoride sipariş yoktur; "ayrılır" bölgesinde mağaza her hafta azalır; kural kilidi içindeki değişiklik
reddedilir; sipariş bir hafta iki katına çıkınca aylık gelir en çok %25 artar; kampanya ezmesi bitince saklı kural yürürlüktedir.

**Önizleme kuralı** (`preview_commission`, `preview_policy`, `preview_premium`; benim kararım, onay bekliyor): kapanışın saf
işlevleri durumun bir kopyasında dört hafta ileri koşar, bir kez değişiklikle, bir kez değişikliksiz; çip ikisinin dördüncü
haftadaki farkıdır. Dört hafta kuralın kilit süresidir: oyuncu, kararını yeniden verebileceği hafta ne göreceğini okur.
Anında değişen büyüklükte (mağazanın kazancı, mağaza fiyatları, defter puanı) bu fark bugünkü farkla aynıdır; yavaş
değişende (üye, aktif kullanıcı) dört haftada birikeni gösterir. Pazarlama'nın değerleri bu koşuda geçen haftaki hâliyle
sabit tutulur; olay ve acil durum koşulmaz. Çiplerin ortak ipucu: "Dört hafta sonraki fark." `gain` (§3.5) ayrı kalır: o
değişiklik bugün yürürlükte olsaydı geçen haftanın siparişinin kaç artacağını söyler.

## 4. Ekranlar

Kareler `tur4_ekranlar_2026-11-13/pazaryeri/kareler/` altında; her bölümün karesi başlıkta yazılıdır. Metinler §8'de.

### 4.1 Pencere (bütün kareler)
- Satış yuvasında açılır; adı "Pazaryeri". Yayından önce de açıktır (`sales_tab.gd:174-198`; bugünkü B2C çizimi kalkar).
- Başlıkta üç ölçü: AKTİF KULLANICI, MAĞAZA, HAFTALIK SİPARİŞ. Alt sayfalar: GENEL, KATEGORİLER, POLİTİKALAR, PREMIUM. Premium
  açılmadıysa sekme şartını yazar: "Üyelik Programı çıkınca".
- Ortak bileşenler yeni bir dosyada toplanır: adım düğmesi, "eski → yeni", ipuçlu sonuç çipi, bekleyen seçim, adım çubuğu,
  taralı gösterge, kilit satırı (`TEKNIK_KESIF.md` paket 4).

### 4.2 Genel (PY4a, PY4b, PY5a, PY5b)
- **DÖNÜŞÜM** bölümü. Başlık satırının sağında tek cümle: "Geçen hafta ziyaretin %4,7 kadarı sipariş verdi".
- Sütun başlıkları: "GEÇEN HAFTA" (sayı) ve "ÖNCEKİ ADIMDAN GEÇEN" (yüzde ve çubuk). Beş satır: Ziyaret, Sepete ekledi,
  Ödemeye geçti, Sipariş verdi, Teslim edildi. Ziyaret satırı iki renklidir (Organik, Kanal) ve yüzdesi yoktur.
- Çubuğun tam boyu adımın ulaşılabilir oranıdır; dolu kısmı bugünkü oran; kalanı taralıdır. En zayıf adımın taraması ve
  yüzdesi uyarı rengindedir. Çubuk sütununun sağ ucunda tek soluk etiket: "ulaşılabilir".
- Altında iki küçük oran: Geri dönen kullanıcı, İade.
- **Adımın ipucu** en çok dört satırdır ve her satır neye göre olduğunu söyler: adımın payı ve en çok ne olabileceği
  ("Sipariş verdi · ödemeye geçenin %67 kadarı · en çok %88"); taşıyan modül ve bugünkü kademesi ("Sepet ve Ödeme · Kartla ve Kapıda
  Ödeme"); sıradaki kademenin kazancı ("Tek Sayfa Ödeme ve Taksit çıkarsa haftada +110 sipariş"); açık hatanın kazancı ("3
  açık hata düzelirse haftada +60 sipariş"). Daha uzak kademe yazılmaz. Sayılar `gain`'den gelir.
- **MEMNUNİYET:** Kullanıcılar ve Mağazalar; sayı, çubuk ve en ağır olumsuz satırın kısa adı.
- **TALEPLER:** bekleyen konu sayısı ve "Talepleri aç" (`SprintUiShared.open_requests`); sayı sıfırsa bölüm çizilmez.

### 4.3 Kategoriler (PY3, PY6)
- Sol: altı kategorinin listesi; ad, durum (AÇIK ya da KAPALI), MAĞAZA, SİPARİŞ, KOMİSYON. Kapalı satırda sayılar boştur.
- **Kapalı kategorinin paneli:** ad ve durum; tek olgu İADE ("sektör ortalaması %9"); birincil düğme "Kategoriyi aç".
- **Açık kategorinin paneli:**
  1. Ad ve durum.
  2. İki olgu: İADE (değer, altında "sektör ortalaması %20") ve SATIŞ HACMİ ("$70K / hafta"; teslim edilen × sepet).
  3. REKLAM DOYUMU göstergesi: Pazarlama'nın sayısı (`impression_share`); pahalanan bölüm taralı. İpucu: "Bu kategorideki ucuz
     reklam yerlerinin ne kadarını kullandın; doldukça yeni kullanıcı pahalanır."
  4. KOMİSYON: adım düğmesi (bir puan), "eski → yeni", üç bölgeli aralık çubuğu (rahat, zorlanır, ayrılır; iki sınırın
     altında oranı), sonuç çipleri, Uygula ve kilit satırı. Çipler sırayla: Mağazanın kazancı, Mağaza fiyatları, Haftalık
     sipariş, Aylık gelir (`preview_commission`; §12 soru 1). "Mağazanın kazancı"nın ipucu: "Mağazaya komisyon ve kargodan
     sonra kalan."
  5. MAĞAZA KAZANIMI: atanan her kişi (yüz, ad, rol, Satış yıldızı, "haftada 6 mağaza", "Değiştir") ve boş bir "Ata" yuvası.
     Kazandırmayan atama nedeniyle görünür (yardımcı yönetmenin şartı, adil ekonomi): ilk kapanışını bekleyen kişinin
     satırında "haftada 6 mağaza" yerine kazanımın gelecek hafta başladığı, işbaşında olmayan (izinli, eğitimde) kişinin
     satırında o hafta kazandırmadığı yazar; "Ata" ve "Değiştir" seçiminde ilk haftanın kazandırmadığı seçimden önce
     okunur. Biçimi (çip ya da ipucu) ARAYUZ'la, metinleri arayüz paketinde; TR ve EN onay bekliyor.
     Ürün yayınlanmadıysa tek satır: "v1.0 yayınlanınca başlar".

### 4.4 Politikalar (PY7a, PY7b)
- İki grup, dört satır: ALIŞVERİŞ (Kargo ücreti, İade süresi, İade kargosu) ve MAĞAZA KURALLARI (Mağaza kabulü). Satır: kuralın
  adı ve seçenekleri. Sağda başka sütun yoktur.
- Bir seçenek seçilince satırın altında sonuç satırı açılır: §3.9'daki çipler, Uygula ve kilit satırı. Uygulanan kural kalan
  haftayı çip olarak yazar ("3 hafta").
- Kampanyanın ezdiği satır ne olduğunu yazar: "İndirim günleri · 2 hafta kargo bedava"; seçenekleri soluktur.
- Kartını bekleyen kural şartını yazar ("Kullanıcı Koruması çıkınca").

### 4.5 Premium (PY8a, PY8b)
- Üstte dört ölçü: ÜYE; ÜYE SİPARİŞİ (son dört haftada üyelerin verdiği sipariş: "500", altında "bu ay"); ÜYELİK GELİRİ;
  AYRICALIK GİDERİ (aşağıdaki satırların toplamı; son dört hafta).
- ÜCRET: adım düğmesi, sonuç çipleri (Üye, Haftalık sipariş, Aylık gelir, Ayrıcalık gideri), Uygula ve kilit satırı; "30 gün
  ücretsiz dene" anahtarı.
- Tek bölüm başlığı AYRICALIKLAR ve dört satır: ad, seçenekler, sağda "BU AY" sütunu ("500 üye siparişi · $1,5K"). Açık
  olmayan ayrıcalıkta sütun boştur; şartı bekleyen ayrıcalık şartını yazar ("Çoklu Entegrasyon çıkınca").
- Bir seçenek seçilince satırın altında sonuç satırı açılır.

### 4.6 Ürün penceresi (PY1a, PY1b, PY1c, PY1d)
- Yayın şartı şeridi ve düz modül listesi ERP'nin ortak işidir (`MODUL_SEMASI.md`; `ORTAK_ARAYUZLER.md` dalga 2). Pazaryeri
  yalnız verisini verir: dört adlı modül ve §2.2'nin listesi.
- Sıradaki kademe kapıya takılıyorsa satır şartını yazar ("Arama ve Filtre · 1★ tasarımcı gerekli").

### 4.7 Açık kategori yokken
Ürün yayınlandığında hiç açık kategori yoksa bildirim yığınına bir hatırlatıcı düşer ("Açık kategori yok"); tıklanınca
Pazaryeri › Kategoriler açılır. Hatırlatıcı bugünkü masa hatırlatıcılarının kalıbıdır (`MailClock`, `desk_arrivals`).

## 5. Olaylar ve kâğıtlar

Yazım `CLAUDE.md` §5'e ve olay yazım kurallarına uyar: gövde gözlemler, hüküm vermez; şık somut bir hamledir ve bedeli sonuçla
yazılır; adlar sistemden gelir; gövdede "kart" sözü yoktur; araya giren değer ek almaz. Yeni fiilin adı `marketplace_` ile
başlar, kartıyla tek commit'te iner; kol yalnız `MarketplaceSystem`'in işlevini çağırır (OLAYLAR'ın kuralı).

### 5.1 Yeni mağazalar komisyonu soruyor (`marketplace.new_store_terms`; kare PY2)
- **Ne zaman:** kapanışta, bir kategoride (a) en az dört haftadır bir Satış Temsilcisi atanmışsa, (b) kategori "rahat"
  bölgede değilse ve (c) mağaza sayısı seçenek için gerekenin altındaysa istenir. Kategori başına koşuda bir kez
  (`latches`). Konuşan o temsilcidir (birden çoksa Satış yıldızı en yüksek olan).
- **Gövdedeki sayılar modelden gelir:** görüşülen = temsilcinin o haftaki kazanımı ÷ bölge çarpanı (yuvarlanır); kayıt olmayan
  = görüşülen − kazanım.
- **Metin (taslak).** Başlık TR "Yeni mağazalar komisyonu soruyor", EN "New stores ask about the commission". Gövde TR:
  "{konuşan} bu hafta {kategori} için {n} mağazayla görüştü. Kayıt olmayan: {m}. Satış başlamadan komisyonu yüksek buluyorlar.
  Yeni gelen mağazadan ilk sekiz hafta yarı komisyon almayı öneriyor." EN: "{speaker} spoke with {n} stores for
  {category} this week. Did not sign up: {m}. They find the commission high before any sale. The suggestion: take half
  the commission from a new store for its first eight weeks."
- **Şıklar** (fiil `marketplace_store_terms`; `MarketplaceSystem.set_store_terms(kategori, pay, hafta)`):
  1. TR "Yeni mağazadan ilk sekiz hafta yarı komisyon al", EN "Take half commission from a new store for eight weeks": şart
     çarpanı 1,4; `terms` = pay 0,5, 8 hafta. Çipler: "{kategori}: haftada +{n} mağaza", "Aylık gelir {tutar}".
  2. TR "Yeni mağazadan ilk sekiz hafta komisyon alma", EN "Take no commission from a new store for eight weeks": şart çarpanı
     1,8; `terms` = pay 0, 8 hafta. Çipler aynı kalıpla. Bedeli de kazanımı da birincinin iki katıdır.
  3. TR "Oranı değiştirme", EN "Keep the rate": konuşanın morali düşer (var olan moral fiili, −4). Çip:
     "{konuşan}: moral −4". Bugünkü moral çipi yalnız adı yazar ("Emre −4", `chips.gd:170-172`) ve neyin düştüğü okunmuyor.
     Adlı hâl oyundaki bütün moral çiplerini değiştirir; çipin sahibi OLAYLAR'dır, metin onay bekler.
- Çipteki mağaza sayısı ve tutar `MarketplaceSystem`'in saf işlevinden gelir; tutar, bugünkü kazanım hızıyla aylık gelirden
  eksilecek paradır. Şart koşu boyunca o kategoride geçerli kalır; indirimi §3.6'daki formülle her hafta düşülür.

### 5.2 Var olan kartlar ve acil durumlar
- 29 B2C kartı: 16'sı kalır (8'inin bağı kullanıcıya döner), 10'u pazaryerinin diliyle yeniden yazılır, 3'ü emekli olur
  (`product.paid_tier`, `world.app_placement`, `world.newsletter_slot`). Liste `pazar_tasarim_2026-11-12/tur3/E_KART_AYIKLAMA.md`;
  o listedeki "alıcı" ve "satıcı" sözleri yeniden yazımda "kullanıcı" ve "mağaza" olur. Yeniden yazılan her kartın TR metni onay
  bekler.
- Acil durumlar: eşikler ve bedel kitleden değil siparişten türer (kaçan sipariş × sepet × komisyon; Yedekleme çarpanı §3.8).
  "Ücretsiz ay" şıkkı "bir hafta komisyon almamak" olur (`incident_system.gd:115, 167-169, 246-248, 521, 536, 638-660`; çip
  `chips.gd:591-593`).
  Kaçan siparişin komisyonu açık kategorilerin geçen haftaki teslim payıyla ağırlıklı `sepet × komisyon`dur (teslim yoksa
  eşit ağırlık; iade düşülmez; `lost_commission`) ve izleyen kapanışın net komisyonundan düşer. "Bir hafta komisyon
  almamak" izleyen kapanışta brüt komisyonu sıfırlar (`waive_commission`). İkisi aynı kapanışa düşerse kesintinin bedeli
  ayrıca düşülmez: o hafta kaçan siparişin komisyonu da alınmayacaktı; "Kesinti" satırı yine yazılır (onay bekliyor).
  Önizleme bekleyen kesintiyi ve komisyonsuz haftayı saymaz (§3.13).
- Üç PM kâğıdı Talepler'in bilet sayısını okur.

## 6. Kitleyi okuyan öbür yerler

| Yer | Bugün | Olacak |
|---|---|---|
| `cheque_read.gd:34-40` | Dördüncü adım "İlk ödeyen müşteri" | Pazaryerinde "İlk sipariş" (ilk teslim edilen sipariş); öbür dört adım aynı |
| `endings_copy.gd:384-426`, `game_state.gd:736-738` | Son kâğıdında kitle ve ödeyen; 12 cümle | Aktif kullanıcı, mağaza, haftalık sipariş; cümleler yeniden yazılır (onay bekler) |
| `sprint_bridges.gd:298-333`, `sprint.json` yorum bloğu | Sürüm notunun yorumları (28 metin, yarısı not uygulaması dili) | Pazaryeri yorumları (onay bekler) |
| `infra_system.gd:126`, `support_system.gd:164-167`, `product_quality.gd:198, 287` | Kitle | Aktif kullanıcı |
| `vc_pitch_system.gd:511, 522` | Kayıp sorusu kitle kaybını okur | Kullanıcı ve mağaza kaybını okur |
| `effects.gd:291-305`, `seams_sales.gd:155-162`, `seams_product.gd:239-245, 320-323` | Kitle seam'leri | Kullanıcıya bağlanır; adlar değişmez |
`olay.payers` seam'i ödeyen kullanıcı değil, bedeli ödeyen ekip üyesidir; dokunulmaz.

## 7. Kayıt

- `SCHEMA_VERSION` 19'dan 20'ye, sistem paketinde, tek başına bir commit'te çıkar. O commit: `GameState.marketplace`
  sözlüğü (boş doğar; yeni alan göç istemez) ve eski not ve video kaydının reddi. `b2c_audience`, `b2c_price` ve
  `b2c_users_lost` bayrakları ile `b2c_audience_history`, onları okuyan eski ekonominin silindiği commit'te `RETIRED_FLAGS`'e
  girer; `b2c_paid_tier_open` Üyelik modülünün kademesi olarak kalır.
  (`ORTAK_ARAYUZLER.md`'nin "numara PRD'ye yazılmaz" kuralı öbür ekiplerin sonradan alacağı numaralar içindir; 20 bu PRD'nindir.)
- Artışın nedeni: artış olmazsa eski bir sürüm pazaryeri kaydını reddetmez ve sessizce eski ekonomiyle açar
  (`_read_file`, `SAVE_ERR_NEWER`). Sonraki paketler sözlüğe anahtar ekler; okuyan `.get(anahtar, varsayılan)` kullanır; yeni
  artış gerekmez. `MIN_LOADABLE_VERSION` 10 kalır.
- Sözlüğün anahtarları metindir (sayı anahtar JSON'dan geri gelmez). Durum `GameState`'te durduğu için `reset_all_owners`'a
  ek gerekmez; sistem önbellek tutarsa o önbellek sıfırlanır.
- Ret: `_read_file`'da göçlerden sonra, kayıttaki ürün türü `note_tool` ya da `video_clip` ise kayıt yuva listesinde hata
  satırıyla reddedilir (yeni `SAVE_ERR_*` anahtarı; metni §8'de); tür seçilmemiş kayıt açılır. Not kaydı kuran üç test
  (`save_v10_product_state`, `save_v14_*`, `save_retired_product_flags`) aynı commit'te yeniden kurulur.

## 8. Metinler (taslak; TR ve EN onay bekliyor)

Anahtar öneki `MP_`. Araya giren değer ek almaz; bu yüzden cümleler değeri sona ya da ayraçla koyar.

| Yer | TR | EN |
|---|---|---|
| Pencere | Pazaryeri · Aktif kullanıcı · Mağaza · Haftalık sipariş · Genel · Kategoriler · Politikalar · Premium · Üyelik Programı çıkınca | Marketplace · Active users · Stores · Weekly orders · Overview · Categories · Policies · Premium · After Membership Programme ships |
| Genel, başlık | Dönüşüm · Geçen hafta ziyaretin {oran} kadarı sipariş verdi · Geçen hafta · Önceki adımdan geçen · ulaşılabilir | Conversion · Last week {rate} of visits placed an order · Last week · Passed from the previous step · reachable |
| Genel, adımlar | Ziyaret · Organik · Kanal · Sepete ekledi · Ödemeye geçti · Sipariş verdi · Teslim edildi · Geri dönen kullanıcı · İade | Visits · Organic · Channels · Added to cart · Reached checkout · Placed an order · Delivered · Returning users · Returns |
| Genel, ipucu | Sepete ekledi · ziyaretin {oran} kadarı · en çok {tavan} · Ödemeye geçti · sepete ekleyenin {oran} kadarı · en çok {tavan} · Sipariş verdi · ödemeye geçenin {oran} kadarı · en çok {tavan} · Teslim edildi · siparişin {oran} kadarı · en çok {tavan} · {modül} · {kademe} · {kademe} çıkarsa haftada +{n} sipariş · {n} açık hata düzelirse haftada +{m} sipariş | Added to cart · {rate} of visits · at most {cap} · Reached checkout · {rate} of carts · at most {cap} · Placed an order · {rate} of checkouts · at most {cap} · Delivered · {rate} of orders · at most {cap} · {module} · {tier} · Ship {tier} for +{n} orders a week · Fix {n} open bugs for +{m} orders a week |
| Genel, sağ | Memnuniyet · Kullanıcılar · Mağazalar · Talepler · {n} konu bekliyor · Talepleri aç | Satisfaction · Users · Stores · Requests · {n} topics waiting · Open requests |
| Kategoriler | Kategori · Açık · Kapalı · Sipariş · Komisyon · İade · sektör ortalaması {oran} · Satış hacmi · {tutar} / hafta · Reklam doyumu · Kategoriyi aç · Mağaza kazanımı · haftada {n} mağaza · Değiştir · Ata · v1.0 yayınlanınca başlar | Category · Open · Closed · Orders · Commission · Returns · sector average {rate} · Sales volume · {amount} / week · Ad saturation · Open category · Store acquisition · {n} stores a week · Change · Assign · Starts when v1.0 ships |
| Kategori adları | Moda · Elektronik · Ev ve Yaşam · Kozmetik ve Kişisel Bakım · Anne ve Bebek · Spor ve Outdoor | Fashion · Electronics · Home and Living · Beauty and Personal Care · Mother and Baby · Sports and Outdoors |
| Reklam doyumu ipucu | Bu kategorideki ucuz reklam yerlerinin ne kadarını kullandın; doldukça yeni kullanıcı pahalanır. | How much of this category's cheap ad space you have used; as it fills a new user costs more. |
| Komisyon | Mağazanın kazancı {v} · Mağaza fiyatları {v} · Haftalık sipariş {v} · Aylık gelir {v} · Uygula · Dört hafta değişmez · rahat · zorlanır · ayrılır · Mağazaya komisyon ve kargodan sonra kalan. | Store earnings {v} · Store prices {v} · Weekly orders {v} · Monthly revenue {v} · Apply · Locked for four weeks · comfortable · strained · leaving · What the store keeps after commission and shipping. |
| Politikalar | Alışveriş · Mağaza kuralları · Kargo ücreti · Kullanıcı öder · Büyük sepette mağaza öder · Hep mağaza öder · İade süresi · 7 gün · 14 gün · 30 gün · İade kargosu · Mağaza öder · Biz öderiz · Mağaza kabulü · Herkese açık · Yalnız vergi levhalı · {n} hafta · İndirim günleri · {n} hafta kargo bedava · Kullanıcı Koruması çıkınca | Shopping · Store rules · Shipping fee · User pays · Store pays on large baskets · Store always pays · Return window · 7 days · 14 days · 30 days · Return shipping · Store pays · We pay · Store admission · Open to all · Registered businesses only · {n} weeks · Sale days · free shipping for {n} weeks · After User Protection ships |
| Kural çipleri | Geri dönen kullanıcı {v} · İade oranı {v} · Mağaza memnuniyeti {v} · Kullanıcı memnuniyeti {v} · Mağaza kazanımı {v} · Aylık gelir {v} · Aylık gider {v} · İade edilen siparişten komisyon alınmaz. · Dört hafta sonraki fark. | Returning users {v} · Return rate {v} · Store satisfaction {v} · User satisfaction {v} · Store acquisition {v} · Monthly revenue {v} · Monthly cost {v} · No commission is taken on a returned order. · The difference four weeks from now. |
| Premium | Üye · Üye siparişi · Üyelik geliri · Ayrıcalık gideri · Ücret · {tutar}/ay · 30 gün ücretsiz dene · Ayrıcalıklar · Bu ay · Kapalı · Herkese · Premium'a · Kargo bedava · Hızlı teslimat · Adresten iade · Üyelere özel indirim · {n} üye siparişi · {tutar} · {n} iade · {tutar} · Kural zaten veriyor | Members · Member orders · Membership revenue · Perk cost · Fee · {amount}/mo · 30-day free trial · Perks · This month · Off · Everyone · Premium only · Free shipping · Fast delivery · Doorstep returns · Member-only discount · {n} member orders · {amount} · {n} returns · {amount} · The rule already grants it |
| Defter satırları | §3.8'in tablosundaki adlar: Komisyon artışı: {kategori} · Zorlanıyor: {kategori} · Kazancı yetmiyor: {kategori} · İade süresi · İade kargosunu biz ödüyoruz · Vergi levhalı mağazalar · Seçenek az: {kategori} · Geç teslimat · Destek yığını · Hesap güvenliği zayıf · Karşılandı: {konu} · Geciken talep: {konu} · İndirim günlerinde zarar · Hızlı teslimat yalnız üyeye · Hızlı teslimat · Adresten iade · Kesinti | Commission raised: {category} · Strained: {category} · Earnings too thin: {category} · Return window · We pay return shipping · Registered stores only · Thin selection: {category} · Late delivery · Support backlog · Weak account security · Delivered: {topic} · Overdue request: {topic} · Loss on sale days · Fast delivery now members only · Fast delivery · Doorstep returns · Outage |
| Olay 5.1 çipleri | {kategori}: haftada +{n} mağaza · Aylık gelir {tutar} · {konuşan}: moral {v} | {category}: +{n} stores a week · Monthly revenue {amount} · {speaker}: morale {v} |
| Öbür | İlk sipariş (çek adımı) · Açık kategori yok (hatırlatıcı) · Bu kayıt oyundan kalkan bir ürünle yapılmış. (kayıt reddi) | First order · No open category · This save was made with a product that is no longer in the game. |
Olayın metni §5.1'de. Modül ve kademe adları §2.2'de (EN: Listing, Storefront, Cart and Checkout, Orders, Reviews and
Protection, Membership; kademelerin EN taslakları prototip yamasının CSV satırlarında, `kareler/fikstur/`). Tür seçim ekranının
metinleri ARAYUZ'un PRD'sindedir.

## 9. Tasarım sabitleri (hepsi [WORKING]; onay bekliyor; ayar playtest'te)

Kategori sabitleri `data/product/categories.json`'da (§3.2'nin tablosu), modüller `data/product/lines/marketplace.json`'da,
öbür bütün sabitler ve konu kataloğu `data/product/marketplace.json`'da durur. §12 soru 10 bu değerlerle kurulmasının onayıdır.
- **Ziyaret ve kullanıcı:** organik oran 0,065; memnuniyet katsayısının tabanı 55 ve aralığı 45; elde tutma tabanı 0,94,
  memnuniyet puanı başına 0,0005, üye payı katsayısı 0,03, sınırları 0,85 ve 0,99; üyenin sıklık çarpanı 1,4.
- **Adımlar:** ulaşılabilir oranlar %15, %70, %88, %97; yayın şartı modüllerinin kademe çarpanı 0,83, 0,96, 1; destek
  modüllerinin 0,90, 0,95, 0,98, 1; açık hata başına 0,027 (en çok 10); en zayıf adım tanımı §3.5'te.
- **Mağaza:** kazanım tabanı 2, 3, 4, 6, 8; bölge çarpanı 1, 0,6, 0,2; bölge eşikleri 0,40 ve 0,33; fiyata yansıma 0,5; kabul
  çarpanı 0,6; Ürün Yükleme kazanım çarpanı 1, 1,5, 2 ve kalış çarpanı 1, 0,9, 0,8; kendiliğinden gelen 0,0004; ayrılma tabanı
  0,008, "ayrılır" bölgesinde +0,03, sipariş azlığı katsayısı 0,07 ve eşiği mağaza başına 1,2 sipariş, memnuniyet 60'ın altında
  puan başına 0,0015.
- **Kurallar:** kilit 4 hafta; kargo çarpanı 0,83 ve 1; büyük sepet eşiği $50; kargo bedeli $3; iade süresi çarpanı 1, 1,08,
  1,2 ve elde tutma katkısı 0, 0,005, 0,01; "Biz öderiz" iade çarpanı 1,05; kabulün iade çarpanı 0,9; Yorum ve Güvence iade
  çarpanı 0,95, 0,92, 0,90.
- **Komisyon:** bir puanlık adım; sınırlar %1 ve %30; fiyat esnekliği 1,5.
- **Premium:** başlangıç ücreti $4, sınırlar $1 ve $15; hedef katsayısı 0,012; ücret duyarlılığı 0,25; haftalık yaklaşma 0,10
  (denemede 0,20); çekim puanları 3, 2, 1, 2; üyelere özel indirim %5.
- **Memnuniyet:** taban 70; haftada en çok 5 puan; §3.8'in tablosundaki puanlar, süreler ve eşikler; Yedekleme'nin kesinti
  çarpanı 0,7, 0,5, 0,3.
- **Gelir:** ay 4,33 hafta; pencere 4 hafta. **Önizleme:** 4 hafta ileri.
- **Talepler:** §3.11'deki bilet oranları ve derdi olan mağaza payları (0,34; 0,22; 1); bilet penceresi 4 hafta; geciken talep
  eşiği 8 hafta; ek özellik çarpanları 0,97; 0,99; 0,95 (§3.5).
- **Olay 5.1:** en az 4 hafta atanmış temsilci; şart çarpanları 1,4 ve 1,8; paylar 0,5 ve 0; süre 8 hafta; moral −4.

## 10. Test ve kapılar

- Kapı sırası `CLAUDE.md` §12'deki gibidir. Yeni smoke vakası yalnız çekirdek mantık içindir; arayüz görsel kabulle doğrulanır.
- **Önce test hazırlığı:** bugünkü B2C test dünyaları altı yardımcıdan geçer (`endgame_smoke.gd` `_seed_b2c`,
  `_seed_save_world`, `_seed_support_fixture`, `_incident_world_b2c`, `_seed_sprint`, `_seed_sprint_live`); varsayılanları ERP'ye
  çevrilir. Oyun aynı kalır, kapılar yeşil kalır.
- **Yeni vakalar** (çekirdek mantık): boş kategoride sipariş yok; mağaza kazanımı yayından önce çalışmaz; "ayrılır" bölgesinde
  mağaza her hafta azalır; kural kilidi içinde değişiklik reddedilir; kampanya ezmesi bitince saklı kural yürürlüktedir; sipariş
  bir hafta iki katına çıkınca aylık gelir en çok %25 artar; komisyon mağazalar kaydına, üyelik kullanıcılar kaydına yazılır;
  Premium ayrıcalığının bedeli `pazaryeri` kalemine yazılır ve Premium kapalıyken hiçbir ayrıcalık gider yazmaz; kampanyanın bedava kargo haftasında
  kargo gideri iki kez yazılmaz; önizlemenin gösterdiği fark, değişiklik uygulanıp dört hafta koşulunca görülen farkla aynıdır
  (olay ve kampanya yokken); konusu yayına
  çıkan taraf "Karşılandı" satırı alır; pazaryeri kaydı yazılıp okununca aynı kalır; not ve video kaydı reddedilir; bilinmeyen
  tür kimliği hata verir.
- **Var olan vakalar:** B2C'ye bağlı 145 vakanın 91'i taşınır, 49'u yeniden yazılır, 5'i emekli olur (`TEKNIK_KESIF.md` §3 ve
  `kesif/K5.md`). Eski kural ve onu sınayan vaka aynı commit'te gider.
- **Bot ve kapılar:** `tools/run_gate.sh`'in `full_run_b2c` koşusu pazaryerini oynar; makullük defterinin B2C koşuları ve tempo
  probunun dünyası pazaryerine geçer (§11).

## 11. Commit sırası ve bağımlılıklar

Sıra "önce ekle, sonra sil"dir; hiçbir commit'te kapı kırmızıya dönmez. Ortak dosyalarda sıra `ORTAK_ARAYUZLER.md` §3'tedir
(ERP'nin kilitli satırı, adlı kapısı ve şeridi pazaryeri verisinden önce iner; ortak commit yok).

| Paket | İş | Commit (kaba) |
|---|---|---|
| 0 | Erdem'in cevapları ve PRD güncellemesi; iki sabit dosyası (`marketplace.json`, `categories.json`); §3.13'ün saf işlevleri ve probe'u | 5 |
| 8a | Test hazırlığı | 4 |
| 1 | Veri: tür ve on modül (eklenir, silinmez; tür henüz seçilemez), rakip ve Piyasa verisi | 3 |
| 2 | Sistem: §3'ün tamamı, şema commit'i, Finans kalemi ve gelir dökümü. Aynı pakette not ve video tür seçiminden kalkar, kayıtları reddedilir, eski B2C ekonomisi ve onu sınayan vakalar gider; `full_run_b2c` ön ayarı pazaryerine döner ve bot en küçük oyununu oynar (bir kategori açar, kurucuyu atar) | 16 |
| 3 | Kitleyi okuyan yerler ve içerik (§5.2, §6) | 20 |
| sil | Not ve video ürünlerinin verisi, metinleri, rakipleri ve ön ayarları silinir | 3 |
| 4 | Pencere: Genel, Kategoriler, hatırlatıcı; mağaza kazanımı ve Satış rolü. Bu paketin ilk kullanılabilir commit'iyle pazaryeri tür seçiminde görünür | 18 |
| 5 | Politikalar; olay 5.1 | 8 |
| 6 | Premium | 9 |
| 8 | Botun tam oyunu, ön ayarlar, makullük, probe ve kare türleri, kod haritası | 12 |
| | Eski vakaların yeniden yazımı (paketlerin içinde) | 11 |
| | **Toplam** | **yaklaşık 109 (93 ile 128)** |
- **Arada oynanabilir B2C ürünü yoktur:** paket 2 ile paket 4'ün ilk commit'i arasında tür seçiminde yalnız ERP görünür. Bu
  bilerek seçildi: iki B2C ekonomisini aynı anda ayakta tutmak her okuyan yeri iki kez yazdırır (`TEKNIK_KESIF.md` §8).
- Paket 2 bitmeden 3 ile 6 başlamaz. Pazarlama'ya ve Talepler'e bağlı dört gösterge (Ziyaret çubuğunun Kanal payı, kampanya
  çipi, reklam doyumu, Talepler'in düğmesi) iki işten sonra inenin commit'inde bağlanır.
- **En küçük demo kümesi (kesme sırası):** önce olay 5.1, sonra Premium'un iki ayrıcalığı (adresten iade, üyelere özel
  indirim), sonra bir kategoride birden çok satışçı.
- Sayım kabadır; hiçbir satır ölçüm değildir.

## 12. Erdem'e sorular

1. **Komisyon artınca sipariş düşsün mü?** Sen sordun: "Komisyonu artırmamız haftalık siparişi neden düşürsün?" Araştırma
   kısmen destekliyor: Amazon üzerine bir çalışmada mağaza ücretlerinin yaklaşık yarısı fiyata yansımış; Rekabet Kurumu
   anketinde mağazaların yüzde 63'ü pazaryerinde daha pahalı sattığını, bunların yüzde 63'ü nedenin komisyon olduğunu söylüyor.
   Ters örnek: Etsy 2022'de ücreti artırınca mağazalar fiyat artırmadı, bir hafta grev yaptı (`arastirma/e_komisyon_fiyat.md`).
   Örnek: Demet Moda'da komisyonu %12'den %13'e çıkarıyor.
   - A (karelerde böyle, önerim): artışın yarısı fiyata yansır. Ekran sırayla yazar: "Mağazanın kazancı −%5", "Mağaza fiyatları
     +%0,5", "Haftalık sipariş −14", "Aylık gelir +$2,1K".
   - B: sipariş düşmez; komisyon yalnız mağazanın kazancını ve kalışını oynatır. Ekranda "Mağaza fiyatları" ve "Haftalık
     sipariş" çipleri olmaz; kural sadeleşir, ama komisyonu artırmanın kullanıcı tarafında hiçbir bedeli kalmaz.
2. **İade kargosunda "Kullanıcı öder" olsun mu?** "Müşteri öder eklenebilir" dedin. 2012'de yasa buna izin vermiyordu: cayma
   hakkında satıcı bedeli "tüketiciye hiçbir masraf yüklemeksizin" iade ederdi (2011 Yönetmeliği, madde 8).
   - A (karelerde böyle, önerim): iki seçenek, "Mağaza öder" ve "Biz öderiz".
   - B: oyun hukuku birebir izlemesin; üçüncü seçenek "Kullanıcı öder" eklensin (iade azalır, kullanıcı memnuniyeti düşer).
   - C: "Kullanıcı öder" yalnız yasal 7 günün ötesindeki gönüllü iade günlerinde geçerli olsun (kural karmaşıklaşır).
3. **"Biz öderiz" mi, "Şirket öder" mi?** Karelerde senin önerinle "Biz öderiz" yazıyor. Kalsın mı? Pazaryeri iade kargosuna
   hiç karışmasın mı diye de sordun; önerim kuralın kalması: mağazayı rahatlatmanın kasaya bedeli olan tek kural bu.
4. **Aylık gelir nasıl okunsun?** Örnek: Demet yatırımcı görüşmesinden önceki hafta büyük bir indirim kampanyası yapıyor ve
   sipariş o hafta iki katına çıkıyor.
   - A (önerim): aylık gelir son dört haftanın net komisyonu ve üyeliktir. Sıçrama geliri en çok dörtte bir oynatır, sonraki
     haftaların düşüşü de sayılır; kapıyı açmak için geliri bir ay taşımak gerekir. Reklam gideri gelirden düşülmez, yalnız
     şirketin ödediği indirim düşülür.
   - B: aylık gelir bu haftanın siparişinden okunur (hafta × 4,33). Daha hareketli bir sayı; tek haftalık kampanya kapıyı açabilir.
   B2B'de MRR iki seçenekte de bugünkü gibi brüt kalır.
5. **İlk mağazalar ne zaman?** "Bizi bekleyen mağaza" kalktı. Örnek: Demet ürünü 10. haftada yayınlıyor.
   - A (karelerde böyle, önerim): mağaza kazanımı yayınla başlar; yayın günü mağaza sıfırdır, ilk sipariş birkaç hafta sonra
     gelir (ERP'de satışın yayınla başlaması gibi).
   - B: kurucu yayından önce de emek verip mağazalarla anlaşabilir (sprintten zaman çalar); yayın günü o mağazalar ürün yükler.
6. **Altı kategorinin adları** doğru mu: Moda, Elektronik, Ev ve Yaşam, Kozmetik ve Kişisel Bakım, Anne ve Bebek, Spor ve
   Outdoor? (Yedinci aday Süpermarket.)
7. **Öncelikli destek Premium'da olsun mu?** Emin değildin. Karelerde yok. Önerim olmaması: destek masası herkese aynı çalışır,
   liste dört ayrıcalıkla sade kalır.
8. **İki ad.** Üst barda "MRR" mi, "Aylık gelir" mi yazsın (pencerede "Aylık gelir")? "Siparişler" modülünün adı "Sipariş
   Takibi" olsun mu (dönüşümdeki "Sipariş verdi" adımıyla karışmasın diye)?
9. **Mağaza kalitesi demoya girsin mi (önceki turdan açık)?** Örnek: Demet'in pazaryerinde sahte ürün şikâyetleri çıkıyor;
   mağazalara puan verip düşük puanlıyı listeden düşürmek, geç kargolayana yaptırım uygulamak ve iyi mağazaya rozet vermek
   istiyor.
   - A (önerim): demoya girmez; bu PRD'nin kapsamı zaten yaklaşık 109 commit. Erken Erişim'in ilk işi olur.
   - B: girer; yaklaşık 9 commit ekler ve Politikalar'a iki satır getirir (`DERINLIK.md` 1 ile 3).
10. **Başlangıç sayıları.** §9'daki değerlerle kurulmasını onaylıyor musun? Hepsi tek dosyada duracak ve playtest'te ayarlanacak.

## 13. Demo dışı

Kategoriyi kapatmak; yedinci kategori (Süpermarket) ve ötesi; iki dünya kâğıdı (kargo firmasının zammı, rakibin bedava kargo
kampanyası: tetiği, tutarı ve şıkları ayrı bir PRD güncellemesinde tanımlanır); kapıda ödemenin kategori başına kuralı; mağaza
araçları ve mağazanın karşıladığı kupon; mağazaya reklam satmak; taksitte vade farkı; ödeme vadesi ve kargoya verme süresi
(Erdem kaldırdı); "30 gün iade" ayrıcalığı (Erdem kaldırdı); adlı tek mağaza ve mağazaya söz; kategori açıldıktan sonraki on iki
haftada artış yasağı (tur 4 taslağındaydı, sadelik için çıktı; sömürü görülürse playtest'ten sonra geri gelir).

## 14. İnceleme kaydı

Taslak 1 bir Opus incelemesinden geçti (13 Kasım gece): beş engelleyen, on dört önemli, altı küçük bulgu. Hepsi bu taslağa
işlendi: formüllerin tanımsız terimleri (§3.4 ile §3.7), defter satırlarının puanı ve süresi (§3.8), kural başına çipler
(§3.9), Premium'un varsayılanları ve üye siparişi (§3.10), bilet oranları (§3.11), olayın sayıları ve üçüncü şıkkı (§5.1),
komisyonun mağazalar kaydına yazılması (§3.1), paket sırası (§11), sorular (§12). İki dünya kâğıdı tanımlanamadığı için demo
dışına alındı (§13).

İncelemeden sonra, kareler çekilirken (13 Kasım gece) örnek sayılar formüllerle yeniden hesaplandı ve şunlar netleşti:
önizleme çipleri dört hafta sonraki farkı gösterir (§3.13); Premium'un "Kargo bedava"sı kampanya haftasında da kendi
satırına yazılır (§3.10); yeni kullanıcı teslim edilen siparişten doğar (§3.7); "Geç teslimat" eşiği 0,90 oldu ve planda
olan konu da yayına çıkana kadar geciken sayılır (§3.8); olayın ikinci şıkkı "ilk sekiz hafta komisyon alma" oldu, çünkü "dört hafta komisyon
alma" birinci şıkla aynı bedele daha çok mağaza getiriyordu (§5.1); "Üyelere özel indirim"in şartı kalktı, çünkü indirim
günleri Pazarlama'da bir şablondur, ayrıca açılmaz. İki sabit karelerdeki örneğe göre ayarlandı (2. kademe çarpanı 0,96;
açık hata başına 0,027). Karelerdeki sayılar örnektir: aynı ekranda birbirine bağlı olanlar (çarpım, toplam, defter puanı,
birim bedel) bu PRD ile tutar; modelin kendi çıktısı §3.13'ün probe'undan gelir.

Çekirdek Talepler'in ve Pazarlama'nın okumalarıyla genişlerken (14 Kasım sabahı; bir Opus incelemesi, tek tur) şunlar netleşti:
kullanıcı tarafındaki ek özellik bağlı adımı gerçekten oynatır ve "etkilenen sipariş" o özelliğin kazancıdır, yani gösterilen
sayı konu çıkınca gerçekleşir (§3.5, §3.11); Yorum ve Puan'ın etkilenen siparişi iade farkıdır; konu kataloğu on iki konudur;
kayıp sayaçları birikir (§3.1); "Karşılandı" yalnız isteği gelmiş konuya yazılır (§3.11). Hepsi PAZARYERI oturumunun kararıdır,
onay bekliyor.
