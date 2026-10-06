# PRD — Rakip Dünyası v6: Piyasa, Hafif Rakipler, Kalite Çıtası, Dönem

**Tek cümle.** Rakip dünyası bir çekirdek mekanik değil sostur: oyuncu 2012'de kurulan şirketini büyütürken
halka açık şirketlerin Piyasa listesini seyreder, liginin 6 rakip kişiliğini haberlerde ve satış masasında duyar,
ürün çıtasını takvim ile lig yayılımının birlikte sürdüğü tek bir beklenti modeli belirler; görev yoktur, hiçbir
zaman olmayacaktır.

## 0. Sürüm günlüğü

| Sürüm | Durum | İçerik |
|---|---|---|
| v4 | commit `c706349` (son dokunuş `c75d5d5`, çip yolu düzeltmesi) | 25 açık karar, Satış tek dikiş, ilk marka taraması |
| v5 | **rafa kalktı** (2026-10-06) | 5.812 satır; görevler (M1-M3), rakip ekonomisi/defteri, 42 karar. Sahip "çok ağır" dedi; görev fikri tümüyle reddedildi. Yedek: oturum scratchpad `rival_page/prd.md` |
| v6 | bu belge | Sahip kararları A-F üzerine yeniden kuruluş: sos, görevsiz. v5'ten yalnız Ek A yedek setleri ve sebepli haber disiplini taşındı (A.1 yöntemi karar G ile değişti). 2026-10-06: sahip v6'yı uygulama için onayladı ([ÇD] değerleri ve metin taslakları onay bekliyor kalır); parodi ad yönü (karar G) işlendi |

## 1. Sahip kararları defteri (2026-10-06, bağlayıcı; bu belge bunları kodlar, yeniden açmaz)

| Karar | Özü | Kodlandığı yer |
|---|---|---|
| **A · Sos** | Rakip dünyası baharattır, çekirdek mekanik değil. **Görev yok, hiç kimseden, hiçbir zaman.** Rakipler oyuncuyu boğmaz | tüm belge; şerit tavanı §8 |
| **B · Dönem** | Koşu Per 5 Oca 2012 başlar (kod herhangi bir Perşembe kabul eder, doğrulandı); demo 2012-13 dilimi, AI devrimi (2022-23) yalnız sezdirilir; tam oyunda perde 2+ kayıtlı `days_per_tick` kabalaşır; `start_date` kayıtlı olur, dönem içeriği takvimi, ekonomi tiki okur, `time.year` seam'i eklenir; 2009 "kriz başlangıcı" tek satır rezerv; dönem göçü kendi artırımıdır (I3) | §2 |
| **C · Piyasa** | Yeni ray sekmesi: yalnız **halka açık (IPO yapmış)** kurgusal şirketler ("daha gerçekçi olur, hem tüm rakipleri de o listeye sokmayız"); ~40 dev + sektör devi + 1-2 küçük yerleşik; özel şirketler listede yok, turları şerit haberi; fiyat VE değer, fiyat sabit `shares_outstanding`'den türetilir; grafikler 13H/1Y/5Y/Tümü + yıl sonu tablosu; oyuncu listede değil, Seed sonrası sabit karşılaştırma satırı; IPO sonraki perdelerin özlemi; değer = yazarlı çapalar + sektör endeksi + splitmix gürültü + ShockLog; Perde 3 alanları rezerve-atıl; **oyuncu eylemleri çapalara asla geri beslemez**; Kişiler sekmesi I4; her devin kurgusal kurucu/CEO'su var | §3 |
| **D · Hafif rakipler** | Alt-tür başına 6 kişilik (+ isteğe bağlı ikinci yerleşik), mevcut TEMPLATE slotlarına; ekonomi defteri yok, kişilik-tempolu deterministik takvim üreteci (çıkış, işe alım/çıkarma vuruşu, ShockLog); tek düzenli temas satış itirazı (aile başına toplantıda bir kez, MVP sonrası 12 hafta muafiyet, anılan özellik rakibin gerçek kademe tablosundan); kayıp anlaşma hattı kaydeder; özellik kararına etki ufak ("N rakipte var"); iki eski kart kalır, `rival.leader` ve `_rival_ahead()` lig liderine yeniden bağlanır | §4 |
| **E · Kalite çıtası** | Aday C "Saat + Yayılım": R(hat, kademe) yazarlı tarihli `market_bar.json`'dan; lig çoğunluğu (M = ceil(lig/2)) tarihi L = 12 hafta gecikmeyle en çok P_max = 26 hafta öne çeker; tek rakip tabanı oynatamaz; dönem yetenekleri G = 78 hafta çıta-muaf; her yükseliş 8 hafta telgraflı; Güçlü = tüm R + (seviye ≥ E+1 **ya da** her hatta lidere eşit/üstün); `sprint.json` faz tablosu ve `rival_bump*` emekli; B2C aşınma/WOM şimdi bağlanmaz; hiçbir şey kaydedilmez; tüm sayılar [ÇD] onay bekliyor | §5 |
| **F · Artırımlar** | I1 Piyasa salt-okunur (önce P3 maketleri) → I2 hafif rakipler + kalite çıtası → I3 dönem göçü (kendi işi) → I4 Kişiler + cila; I1 bugünkü 2026 başlangıcına karşı çıkar, çapalar veridir, I3'te yeniden çapalanır | §6 |
| **G · Parodi adlar** (2026-10-06) | Şirket ve kişi adları gerçek hayattan uyarlanmış **parodilerdir**: oyuncu kimin çağrıştırıldığını anlar ama ad birebir yazılmaz ("Jeff Bezos olduğunu anlasın, Jeff Bezos yazmasın"). Kapsam her şey: devler, kurucu/CEO'lar, sektör rakipleri (global emsaller parodilenir: erp SAP/Oracle çevresi, note_tool Evernote/Notion çevresi, video_clip CapCut çevresi; gerçek küçük yerel firmalar parodilenmez). Sektörler-arası devler ve dolgu yalnız global, Türk devi yok; liste kuyruğundaki sektör yerleşikleri (slot 1-2) bu kurala girmez. Tarz karışık, espri başına; adayları tuvalde sahip seçer; tarama seçimden sonra koşar, taranmamış ad kataloğa yazılmaz. GDD ch14 §6 gerçek marka yasağı bozulmaz: parodi gerçek marka değildir ve markayı alt dize olarak taşımaz (Ek A.1). Eski uydurma setler yedek | Ek A; §3.1; §9 P1 |

## 2. Dönem: 2012

### 2.1 Perşembe kısıtı ve başlangıç

`START_DATE` sabit `{2026,1,1}` [kod scripts/autoload/game_state.gd:8] ve her tik Perşembe'dir. Tarih
dönüşümü epoch + 7 günlük adımlarla çalışır [kod game_state.gd:624-630]; formül **herhangi bir Perşembe**
başlangıcını kabul eder. **Per 5 Oca 2012** bu yüzden sıfır formül değişikliğiyle geçerlidir; yalnız
"1 Ocak" estetiği gider.

### 2.2 Dilim ve sezdirme

- **Demo = 2012-13 dilimi.** Unicorn teriminin doğduğu, sosyal ağ IPO'sunun ve AlexNet kırılmasının yılları;
  Series-A sözlüğü oyunun mevcut sistemleriyle birebir örtüşür.
- **AI yalnız sezdirilir [I3]:** (1) GPU devinin Piyasa'da düz yatan grafiği; (2) Ar-Ge ağacında kilitli
  "2015+" dal etiketi (ağaç yapısına dokunulmaz; yalnız etiket); (3) demo sonlarına doğru tek AlexNet
  selamı şerit satırı (görüntü tanıma kırılması). Kilitli AI ürün tipleri tip ekranında yıl etiketiyle
  görünür (etiket **yeni**, I3; tipler [kod scripts/systems/product_catalog.gd:53-64]). Etiketin ve şerit
  satırının anahtar taslakları I3'te yazılır.
- **Tam oyun:** Perde 1'de 1 tik = 1 hafta kalır; perde 2+ kayıtlı `days_per_tick` skalarını kabalaştırır
  (2 hafta, sonra ~ay), 3-10. yıllar ~2,5-4 saate sıkışır ve AI ~10-11. yılda (2022-23 penceresi,
  pencere içinde rastgele, sert sıfırlama yok) gelir. Rakip benimsemesi kişiliğe kademeli: kopyacı
  haftalar içinde, lider bir çeyrekte, dev geç ama büyük, zorlanan şirketi ortaya koyar.
- **2009:** ileride tam oyun için "kriz başlangıcı" modu adayı. Bu belgede tek satırdır; başka hiçbir şey
  2009'u varsaymaz.

### 2.3 Mimari kural (hangi sistem neyi okur)

- `GameState.start_date` kayıtlı değişken olur (varsayılan `{2012,1,5}`), `days_per_tick` kayıtlı skalar
  (varsayılan 7). Sprint, maaş, söz, süre: **tik** okur. Dönem olayları, `market_bar.json` tarih ve
  `avail` alanları (§5.1), Piyasa çapaları: **takvim** okur.
- Takvim parçalıdır: kayıtlı `tick_epochs` `[{tick, date, days_per_tick}]` (**yeni**); `get_date_dict`
  son epoch'tan sayar. Tek kayıtlı skalar yetmez: `(t−1)×DAYS_PER_TICK` formülü skalar değişince geçmişi
  yeniden tarihler (yıl sonu tabloları, ShockLog haftaları, çıkış tarihleri kayar). Ay kapanışı
  [kod scripts/systems/summary_system.gd:58-59] ve yaz izni haftası takvim okuyan istisnalardır; I3
  tasarım notunda çözülür.
- `time.year` seam'i eklenir; bugün yalnız `time.week` ve `time.month` var [kod
  scripts/events/seams/seams_world.gd:48-55].

### 2.4 I3 kapsamı: bugün 2026 varsayan içerik (kod haritası raporundan)

| Parça | Değişiklik | Boy |
|---|---|---|
| `START_DATE` sabiti + `fmt.gd:62` yıl varsayılanı + `company_step.gd:119` | kayıtlı `start_date`; şema artışı + göç: eski kayıtta `start_date` yoksa `{2026,1,1}` yazılır (SaveCodec varsayılanı 2012 olacağından açık göç şart) | S |
| 2026'ya sabitlenmiş smoke'lar [kod scripts/debug/endgame_smoke.gd:1223, 1314, 8887, 10495] | 2012 tarihlerine yeniden sabitle | S |
| `subgenre = "ai"` varsayılanı [kod game_state.gd:13] | varsayılan `"saas"`; "ai" dönem kilidine girer | S |
| AI ürün tipleri [kod product_catalog.gd:11-45] | veride kalır, tip ekranı yıl etiketiyle kilitli gösterir | S |
| `"ai": true` hat adımları (note_tool.json:33,66,164 · video_clip.json:32,65 · erp.json:39,72) | yeniden adlandırılan düğüm kapısında kalır; AI kopyası dönem bayrağında (tam oyun) | M |
| `ai_engine` "Language model infrastructure" [kod localization/strings.csv:2084, anahtar `PROD_RND_NODE_AI_ENGINE_DESC`] | **"Data & ML infrastructure"** olur: aynı id, yeni kopya; 2012'de dürüst (AlexNet yılı), `requires.research` bağları bozulmaz. Taslak (onay bekliyor): EN "Data and ML infrastructure. Your product can learn from its data now." · TR "Veri ve makine öğrenmesi altyapısı. Ürününüz artık verisinden öğrenebilir." | S |
| AI haber havuzu 10 id [kod scripts/systems/news_feed_system.gd:81-86, 104-105, 114-115] | havuz girdilerine yıl etiketi (`from_year`); 2012 dönemi girdileri eklenir | S |
| AI çeşnili ses/özellik satırları (strings:922 vb.), creator/app-store kartları | denetim turu; çoğu dönem-güvenli ya da yıl etiketi alır | M |
| GDD ZAMAN MODELİ §5 (2026 metni) [GDDs/GDD — ZAMAN MODELİ.md:365-375] | yeniden yazım | S |
| Piyasa kataloğu | çapalar 2012'ye yeniden yazılır + sezdirme içerikleri | S (veri) |
| Rakip AI benimseme kartı (§4.5) | **yeni** kart, dönem bayrağına bağlı | S |

Toplam: geniş ama sığ etki alanlı, odaklı M-L boyunda **tek iş**. Yeni ekran yok; tip ekranına ve Ar-Ge
ağacına yalnız kilit etiketi. Yarım göçmüş takvim iki hâlden de kötü olduğu için bütün hâlde iner.

## 3. Piyasa penceresi [I1]

Tasarım araştırması ve kanıtlar: `piyasa_research/market_ui.md`, `market_model.md`, `real_timeline.md`
(oturum scratchpad'i; §10). Bu bölüm kararları yazar, kanıtı tekrar etmez.

### 3.1 Evren (~42 halka açık satır + liste dışı katman)

| Katman | Adet | Kim | Görünürlük |
|---|---|---|---|
| Sektörler-arası devler | ~40 | Gerçek zaman çizelgesi tablosunun analogları (cihaz devi, OS/bulut, e-ticaret/bulut, arama, sosyal, **GPU üreticisi**, EV, yayın, SaaS öncüsü, veritabanı dinozoru, petrol devi, eski CPU, çöken telefoncu, video-toplantı balonu) + banka/ilaç/telekom/perakende/havacılık dolgusu. Adlar gerçek analogların **parodileridir** (karar G; hedefler `real_timeline.md` §1'deki gerçek devler, arketip eşlemesi §6; §6'nın yer tutucu adları yalnız aday havuzudur); **her ad ve kişi Ek A taramasından geçmeden yazılmaz** (P1) | Halka açık: fiyat + değer + grafik |
| Sektör devi | 1 | SAP-benzeri "büyük rakip" = oyuncunun alt-türünün **mevcut dev slotu 0** [kod scripts/systems/rival_catalog.gd:22-31], listenin üstlerine terfi eder. Tek varlık, iki yüzey | Halka açık |
| Küçük sektör şirketleri | 1-2 | Yerleşik slotlar (1-2), kuyruğa yakın $30-300M; Seed oyuncusu **ulaşılabilir bir basamağın** hemen altına düşer | Halka açık, liste kuyruğu |
| Özel şirketler | — | Listede YOK. Fonlu girenin turu şerit haberidir; gizli özel, veri olarak var olup sonraki bir olayla yüzeye çıkar | Liste dışı |
| Oyuncu | — | Listede YOK; Seed sonrası sabit karşılaştırma satırı (§3.5). IPO sonraki perdelerin özlemidir | Karşılaştırma satırı |

**Dev katalog kapsaması** (adsız arketip planı; adlar P1 taramasından sonra yazılır, eğri biçimleri
`real_timeline.md` §1 ve §6'daki gerçek verinin yuvarlanmış hâlidir):

| Arketip | Adet | Eğri rolü (dönem hikâyesi) |
|---|---|---|
| Cihaz devi | 1 | 2011'de petrol devini geçip #1 olur; istikrarlı merdiven |
| OS/ofis/bulut devi | 1 | 2014 CEO değişimine kadar düz, sonra bulutla tırmanış |
| E-ticaret + bulut | 1 | güçlü büyüme, 2020 sivrilmesi, 2022 yarılanması |
| Arama/reklam | 1 | istikrarlı; 2023 "AI aramayı öldürür" düşüşü, 2025 sıçrama |
| Sosyal ağ | 1 | demo sırasında IPO (2012); kurucusu servet yarışının yüzü |
| **GPU üreticisi** | 1 | 2016'ya kadar DÜZ (demo sezdirmesi); 2023 sonrası hokey sopası |
| EV / gösterişçi CEO | 1 | aşırı oynak; 2020-21 roket, 2022 çöküş |
| Yayın platformu | 1 | büyüme, 2022 çöküşü, toparlanma |
| SaaS öncüsü | 1 | oyuncunun sektörünün barometresi; pürüzsüz SaaS tırmanışı |
| Veritabanı dinozoru | 1 | 13 yıl düz, 2023 sonrası veri merkezi sıçraması |
| Petrol devi | 1 | 2011'de tahtı kaybeden eski dünya kralı |
| Eski CPU devi | 1 | mobili ve AI'yı kaçıran yavaş solma |
| Çöken telefoncu | 1 | 2011'den itibaren çöküş; ibret hikâyesi |
| Video-toplantı | 1 | 2019 IPO, 2020 ×5, sonra sönme (tam oyun) |
| Özel AI laboratuvarı | 1 | Liste dışı (karar C); 2023 sonrası turları yalnız şerit haberi (tam oyun). Halka arzı yazarlı olaydır; olursa listeye o hafta girer |
| Dolgu: banka, ilaç, telko, perakende, havacılık, içecek | ~26 | sektör endeksini taşıyan sakin gövde; AI dalgasına beta ile katılır. Yalnız global parodiler; Türk devi yok (karar G) |

### 3.2 Veri modeli (◆ = şimdi rezerve, Perde 3'te kullanılır; hepsi **yeni**)

```
MarketCompany (Resource, Rival kalıbı; katalog veridir, kaydedilmez):
  id (sabit, yeniden kullanılmaz), name, ticker_symbol◆, sector_id,
  founder_person_id, ceo_person_id,
  status (private|public|acquired|defunct), listed_week, delisted_week◆, parent_company_id◆,
  anchors[] (yıl → değer anahtar kareleri), beta (sektör endeksi ağırlığı), sigma (gürültü genliği),
  shares_outstanding◆ (sabit tamsayı), free_float_pct◆,
  last_round {stage, post_money, week, lead}        # özel şirketler (liste dışı veri)
MarketPerson: id, name, role, birth_year, cash_hint◆
Ownership◆: {holder_kind: person|company|player|public, holder_id, company_id, shares}
ShockLog (kayıtlı): {week, company_id, kind, J, rho, tau, cause_ref}
```

- `Rival` bir alan kazanır: `company_id` (yedek `founder_name`/`notes` alanları MarketPerson'a eşlenir)
  [kod scripts/data_models/rival.gd:17-30].
- ◆ alanlar saklanır, gösterilmez ve Perde 3'e kadar hiçbir kurala girmez; tek istisna
  `shares_outstanding`, yalnız fiyat türetiminde bölendir (§3.3).
- Katalog veridir, kaydedilmez; kayda yalnız `market_catalog_version`, ShockLog, Ownership ve
  `status`/`delisted_week` değişiklikleri GameState değişkeni olarak girer (§3.7).
- Katalog başlığına yazılan kural (karar C): **oyuncu eylemleri çapalara asla geri beslemez.**

### 3.3 Değer dinamiği

```
ln V(c,h) = ln anchors_c(yıl(h))        # yazarlı anahtar kareler, log-interp + smoothstep
          + beta_c · ln S_sektör(h)     # ortak sektör/dönem endeksi (çöküşler, balonlar, AI dalgası)
          + sigma_c · N_c(h)            # pürüzsüz sınırlı gürültü, 4 haftada bir düğüm
          + ShockLog şokları            # kalıcı parça + sönen aşırı tepki
```

- **Deterministik ve tarihsiz:** `(run_seed, catalog_version, ShockLog)`'un saf fonksiyonu; tıpkı
  `RivalRegistry.get_market_snapshot` kalıbı [kod scripts/autoload/rival_registry.gd:145-176]. Grafikler
  yeniden hesaplanır; fiyat geçmişi asla kaydedilmez.
- **Grafik geçmişi:** grafikler koşu öncesini de çizer (son 52 hafta haftalık, öncesi aylık; çapalardan
  türetilir); ShockLog yalnız koşu içidir. Yıl sonu tablosu bu yüzden ilk haftadan doludur (§7).
- **Karıştırıcı:** repodaki `hash("%s|%d")` KULLANILMAZ; dosyanın kendi notu doku üretmediğini kaydediyor
  [kod rival_registry.gd:211-228]. `(run_seed, id_hash, düğüm)` üstünde splitmix tarzı tamsayı
  sonlandırıcı [ÇD data/market/companies.json meta.mixer].
- **Hisse fiyatı** (karar C): `fiyat = değer / shares_outstanding`; türetilir, asla saklanmaz.
- **Özel şirket ve oyuncu adımlarla:** değer = son açıklanan tur (CB-Insights kalıbı). Oyuncu: Seed
  post-money, sonra Series A `run_valuation_m` [kod game_state.gd:222]. Turlar arasında modele göre
  değerleme YOK.
- Ortak sektör endeksi listeyi birlikte oynatır: 50 rastgele yürüyüş değil, tek pazar okunur.
- Sektör rakiplerinin "hayatı" (çıkış, tur, işten çıkarma) ekonomi değil **ShockLog satırı** üretir
  (§4.2); reddedilen defter ölü kalırken liste görünür biçimde kıpırdar.

**ShockLog `kind` sözlüğü** (kapalı küme; her satır `cause_ref` ile sebep anahtarına bağlanır, §3.6):

| kind | Üreten | Etki biçimi |
|---|---|---|
| `earnings` | çeyrek takvimi [I4] | ±%5-15, kalıcı parça + sönen aşırı tepki |
| `launch` | rakip takvim üreteci (§4.2) | küçük kalıcı +J (yalnız büyük çıkışta) |
| `round` | özel şirket tur adımı | şerit haberi; halka açık değere dokunmaz |
| `layoff` / `hiring` | hamle vuruşu (§4.2) | küçük −J / +J ve manşet |
| `mna` | yazarlı katalog olayı [Perde 3] | şimdi üretilmez; açılınca hedef `delisted_week`, alan +J, tek manşet |
| `era` | dönem penceresi [I3+] | sektör endeksi kırılması (AI dalgası, çöküş) |

### 3.4 Ekran: liste ve detay (öğe tablosu)

| Öğe | İçerik | Kaynak |
|---|---|---|
| Liste satırı | `# · Δsıra(4h) · Ad · Kurucu/CEO · Değer · Fiyat · 4h % · 52h kıvılcım çizgisi` | değer fonksiyonu; sektör filtre çipidir, sütun değil |
| Detay paneli (satır tıklaması) | Grafik, aralıklar **13H / 1Y / 5Y / Tümü** (1G/5G yok; tik haftalık) · **yıl sonu değer tablosu** (dönem hikâyesini taşıyan tablo) · kurucu satırı · tek paragraf Hakkında · benzerler şeridi. Sektörler-arası devde "Ürünleri" bölümü yoktur | değer fonksiyonu + katalog |
| Sektör rakibi detayında ek: "Ürünleri" [I2] | Rakibin çıkmış 2-4 yetenek hattı; **satış itirazının andığı listeyle aynı** (§4.3) | birleşik `line_tiers` (I2) |
| Oyuncu karşılaştırma satırı | §3.5 | `seed_post_money_m` / `run_valuation_m` |
| "Sıradakiyle fark" satırı | Soluk tek satır, asla popup, asla hedef | değer fonksiyonu |
| Son bakıştan beri deltaları | Pencere kapanışında anlık görüntü; yeniden açılışta oklar | [I4] |

**Kadans** [ÇD tümü, §8]: haftalık değerlendirme (dev ±%0,5-2/h, küçük şirket %2-5); sıralar + Δsıra okları
4 haftada bir, en çok bir geçiş manşeti; çeyreklik kazanç şokları ±%5-15 sebep satırıyla [I4]; manşet
tetikleri haftalık |Δ| > ~%8, ilk 10'a giriş/çıkış.

**CSV taslak anahtarları** (onay bekliyor; EN önce, TR sonra; tire yok):

| Anahtar | EN | TR |
|---|---|---|
| `TAB_PIYASA` | Market | Piyasa |
| `PIYASA_COL_RANK` | # | # |
| `PIYASA_COL_COMPANY` | Company | Şirket |
| `PIYASA_COL_FOUNDER` | Founder/CEO | Kurucu/CEO |
| `PIYASA_COL_VALUE` | Market value | Piyasa değeri |
| `PIYASA_COL_PRICE` | Price | Fiyat |
| `PIYASA_COL_4W` | 4 wk | 4H |
| `PIYASA_RANGE_13W` | 13W | 13H |
| `PIYASA_RANGE_1Y` | 1Y | 1Y |
| `PIYASA_RANGE_5Y` | 5Y | 5Y |
| `PIYASA_RANGE_ALL` | All | Tümü |
| `PIYASA_EOY_TITLE` | End of year value | Yıl sonu değeri |
| `PIYASA_PRODUCTS_TITLE` | Products | Ürünleri |
| `PIYASA_SINCE_LAST` [I4] | Since your last look | Son bakışından beri |

Yayın (outlet) listesi değişmez: ekleme/silme `D_OUTLETS` + kontrast denetimine dokunur, yeniden
adlandırma yalnız CSV'dir (Ek A.5 kuralı); `piyasa` kaynağı mevcut yayınlardan gönderir.

### 3.5 Oyuncunun girişi ve değerleme dikişi

- `SeedRoundSystem.accept()` bugün yalnız miktar + hisse yazar [kod
  scripts/systems/seed_round_system.gd:169-184]. I1'de orada **`seed_post_money_m` kalıcılaşır**:
  milyon $ cinsinden `round(amount_m × 100.0 / equity_pct)` (float hesaplanır, en yakın tama yuvarlanır).
  Eski kayıtta Seed alınmış ve alan 0 ise yüklemede `run_seed_amount`/`run_seed_equity_pct`'ten aynı
  formülle doldurulur.
- `finance.valuation()` seam'i eklenir (`seams_finance.gd`); ACIK_KARARLAR maddesinin sahip onayıyla
  kapanması önerilir, `opening_terms` sorusu açık kalır [docs/ACIK_ISLER/ACIK_KARARLAR.md:1740-1748].
  Kişisel sekmesinin servet bölümü aynı değeri okur; `personal_tab.gd:203`'teki `run_valuation_m == 0`
  kontrolü `finance.valuation()`'a geçer [kod scripts/tabs/personal_tab.gd:200-205].
- `PER_NO_VALUATION` çelişkisi düzelir: bugünkü metin "Series A imzasında belirlenir" diyor [kod
  strings.csv:337], Seed artık değerleme yazıyor. Taslak (onay bekliyor):
  - `PER_NO_VALUATION` · EN "No valuation yet. Your seed round sets it." · TR "Değerleme henüz yok. Seed turunda belirlenir."
- Karşılaştırma satırı taslakları (onay bekliyor; sahibin sözünden):
  - `PIYASA_PLAYER_ROW` · EN "You · {value} valuation · would sit near #{rank} on the list" · TR "Sen · {value} değerleme · listedeki karşılığın ~#{rank}"
  - `PIYASA_GAP_NEXT` · EN "{company} is {gap} ahead" · TR "{company} {gap} önde"
- **Sıra tanımı:** sıra = 1 + değeri satırdan büyük halka açık satır sayısı; oyuncunun sanal sırası aynı
  formülle hesaplanır. Seed değerlemesi kuyruğun ($30M) altındaysa satır son sıranın bir altını söyler.

**Karşılaştırma satırının hâlleri:**

| Hâl | Görünen |
|---|---|
| Seed öncesi | satır yok; pencere yalnız listeyi gösterir (hedef iması yok, karar A) |
| Seed sonrası | sabit `PIYASA_PLAYER_ROW` + soluk `PIYASA_GAP_NEXT`; değer = `seed_post_money_m` |
| Series A sonrası | aynı satır; değer = `run_valuation_m` (imza anında adım) |
| Geçiş anı [I4] | oyuncunun sanal sırası bir şirketi geçerse soluk tek satır pencere içinde; asla popup, asla bildirim |

### 3.6 Şerit bağları

- `NewsFeedSystem`'e yeni `piyasa` kaynağı: `TARGET_*` + `_pick_source` dalı + `_emit_x` + `counts`
  anahtarı [kod news_feed_system.gd:26-34, 206-227]; eski kayıtların `counts` sözlüğü için backfill şart
  (`_ensure_state` yalnız boş sözlük tohumlar). `TARGET_PIYASA` ve mevcut kotaların yeniden kesimi §8'dedir.
- Nadir büyük tekil için `EventBus.ticker_live_line` [kod scripts/autoload/event_bus.gd:230].
- **Sebepli haber disiplini (v5'ten taşınan kural):** görünür tetiği ve sebep metni olmayan satır
  tabloya giremez; manşet ve sebep ayrı anahtardır, satır "{headline} ({why})" olarak kurulur. Örnek
  taslaklar (onay bekliyor): `PIYASA_NEWS_JUMP` · EN "{company} jumps {pct}" · TR "{company} {pct}
  yükseldi"; `PIYASA_WHY_DC` · EN "data centre order" · TR "veri merkezi siparişi".

### 3.7 Kabuk ve kayıt etkisi

- Ray sekmesi: `UiTokens.TABS` [kod scripts/theme/ui_tokens.gd:293-302] + `TAB_PIYASA` CSV satırı +
  `LeftTabs.tscn` düğmesi aynı sırada (sıra smoke'u `rail_tabs_match_scene_order` zorlar [kod
  endgame_smoke.gd:3663-3690]) + `window_layer.gd` `TAB_SCENES`/`SPECS` [kod
  scripts/ui/components/window_layer.gd:13-20, 36-39] + `frame_options` taşıyan sekme sahnesi +
  `main.gd` tab-shot listesi. Sekmenin raydaki yeri P3 maketiyle kararlaştırılır.
- Kayıt ayak izi: `market_catalog_version`, ShockLog, Ownership, `status` değişiklikleri,
  `seed_post_money_m`. Birkaç KB; fiyat geçmişi asla kaydedilmez. **I1 şema artırmaz:** yeni alanlar
  GameState değişkeni olarak anlamlı varsayılan taşır ve SaveCodec bulur; şema 15 kalır (artış I3'te,
  §2.4).

### 3.8 P3 maket durumu (Menajer kuralı: yeni ekran onaylı maketten kurulur)

| Maket | Ön koşul | Durum |
|---|---|---|
| Piyasa listesi (koyu Menajer dili, TR+EN, renk körü, 1.0 ve 1.25) + raydaki sekme düğmesi ve yeri + sektör filtre çipi + 4h % renk kuralı (düşüş kırmızı değil; SPEC kural 2) | I1 | **yok** |
| Detay paneli ×2: sektörler-arası dev (Ürünleri'siz) ve sektör rakibi (grafik + yıl sonu tablosu; "Ürünleri" bölümü [I2]) | I1 | **yok** |
| Oyuncu karşılaştırma satırı hâlleri (Seed öncesi / Seed sonrası / Series A sonrası; Geçiş anı [I4]) | I1 | **yok** |
| Ürün maketlerine ek (`urun/`): telgraf satırı, iki Zayıf hover çeşidi, lider dalından Güçlü, "N rakipte var" çipi | I2 | **yok** |
| Toplantı maketlerine ek (`toplanti/`): rakip soru satırı, beş cevap (kilitli güç gerekçesi dahil), RAKİP kayıp çipi | I2 | **yok** |
| Tip ekranı + Ar-Ge: "2015+" kilit etiketi, yıl kilitli AI tipleri | I3 | **yok** |
| Kişiler sekmesi | I4 | yok |

Maketler `docs/mockups/menajer/screens/` düzenindedir (SPEC: `docs/mockups/menajer/system/SPEC.md:101-130`;
çalışma ağacında, commit'lenmemiş). I2 görsel kabulü için `main.gd`'ye **yeni** `--meeting-shot=rival`
türü eklenir (bugünkü türler probe|locked|won|lost|handoff).

### 3.9 Perde 3 rezervleri (şimdi saklanır, şimdi atıl)

| Perde 3 özelliği | Bugünden duran |
|---|---|
| Hisse almak | `shares_outstanding`, `free_float_pct`, Ownership "public" satırı |
| Rakip satın almak | `status`, `parent_company_id`, `delisted_week`; TermSheet/Negotiation grameri iki masayı da sürüyor [kod scripts/systems/negotiation_system.gd:13-18] |
| NPC birleşmeleri | katalog alanları + `mna` ShockLog türü; Perde 3'te yazarlı olay olarak açılır |
| Kurucu zengin listesi | MarketPerson + pay × değer; Kişiler sekmesi I4 |
| Oyuncunun IPO'su | `listed_week` alanı; ayrı tasarım |

Perde 3 mekaniği burada tasarlanmaz; alanlar yalnız rezervdir.

## 4. Hafif sektör rakipleri [I2]

Kanıtlar: `rival_research/r1_synthesis.md` + `r1_critique.md`, `piyasa_research/objections.md` (§10).

### 4.1 Kadro: alt-tür başına 6 kişilik (ikinci yerleşikle 7 dolu slot), mevcut slotlara eşlenir

TEMPLATE/SHARE_SEED/`rivals.json` indeksleri hizalı ve kilitlidir [kod rival_catalog.gd:22-31, 41-58, 67];
adlar yerinde değişir, asla yeniden sıralanmaz.

**Lig tanımı (tek yer; A, M, "N rakipte var" ve {total} hep bu kümedir):** lig = oyuncunun alt-türündeki
görünür kişilikler: dev (0), lig lideri (1), yerleşik (2), kopyacı (5), niş (6) ve fonlu giren (3; turu
duyurulduktan sonra). Gizli özel (4) yüzeye çıkana dek lige, A sayımına, çiplere ve itiraza girmez; yedek
slot (7) hiç sayılmaz. M = ceil(lig/2); görünür lig 5-6 kişidir, iki hâlde de **M = 3**. Dev A sayımına
ağırlık 1 ile girer ama Güçlü kıyası ve itiraz öznesi olmaz. **Lig lideri** = slot 1 kişiliği (sabit);
Güçlü'nün lider dalı, `rival.leader`, `_rival_ahead()` ve iki eski kart onu okur. İtirazın öznesi
Piyasa'da detay paneli olan halka açık lig rakipleridir (slot 1-2; §4.3).

| Slot | Kişilik | Piyasa varlığı | Davranış | erp örneği (A.2 yedek adı) |
|---|---|---|---|---|
| 0 | **Dev** (SAP-benzeri) | Listenin üstlerinde | Momentum 0 kalır; seyrek yazarlı hamle (geç ama büyük AI benimsemesi; birleşme/veri merkezi manşeti + küçük +J, liste satırı silinmez). Çoğunluk sayımında tek oy; Güçlü kıyası ve itiraz öznesi değil | Bezistan |
| 1 | **Lig lideri** (yerleşik) | Liste kuyruğu, $30-300M halka açık | Düzenli çıkışlar; Güçlü tacının kıyası, itirazın en sık öznesi | Merivel |
| 2 | Yerleşik | Liste kuyruğu, halka açık | Sakin tempo | Kalemiye |
| 5 | **Kopyacı** | — (özel; tur = şerit haberi) | Çıkışları oyuncunun gönderilerini ≥3 sprint gecikmeyle izler (v5 adalet kuralı korunur; sert "oyuncu−1" tavanı korunmaz) | Stokdar |
| 6 | **Niş** | — | Tek hatta derin, gerisini umursamaz | Dirhem |
| 3 | **Fonlu giren** | Özel; turu duyurulunca görünür | Tur alır, hızlı büyür; "zorda rakip"/"çılgın bahis" kartlarının hedefi | Halvero |
| 4 | **Gizli özel** | Liste dışı | Veride var; yüzeye çıkana dek pay kartında, şeritte, çiplerde ve A'da yok (`get_market_snapshot` süzer [kod rival_registry.gd:152-158]); orta/geç oyunda yazarlı olayla yüzeye çıkar | Veznedar |
| 7 | yedek | — | arka planda uyur | Nolvik |

Not: tablodaki erp adları Ek A.2 **yedek** setindendir ve yalnız örnektir; üç oynanabilir alt-türün kadro
adları P1 parodi setleriyle yazılır (karar G), iyi hedefi olmayan slot yedek adında kalır. v5 Ek A'nın rol
sütunu (Lider = slot 3) bu tabloyla **değişti**; yedek tablolar v6 rolleriyle günceldir, rol veridir.
video_clip aynı düzende eşlenir (Ek A.3). Kalan tek slot (7) yedektir; `SHARE_SEED` payları ve 13×8
kurulum değişmez.

**Üreteç tempoları** [ÇD data/rivals/schedule.json tempo.*; tümü onay bekliyor, §8]:

| Kişilik | Çıkış temposu | Hamle vuruşu | AI kademesi (tam oyun) |
|---|---|---|---|
| Dev | ~2 yılda 1 yazarlı büyük hamle | seyrek; birleşme/veri merkezi | geç, büyük |
| Lider | 10-14 haftada 1 çıkış | çeyrekte ~1 işe alım/manşet | ~1 çeyrek |
| Yerleşik | 14-20 haftada 1 | yılda ~2 | 2-3 çeyrek |
| Kopyacı | oyuncunun gönderisi + ≥3 sprint | tur duyurusu | haftalar |
| Niş | ev hattında 8-12 haftada 1, başka hat yok | nadir | kendi hattında erken |
| Fonlu giren | tur sonrası yoğun, sonra seyrek | 18-30 ayda tur; zorda kalma kartının hedefi | şirketi ortaya koyar |
| Gizli özel | üretmez; yüzeye çıkana dek sessiz | tek yazarlı olay | — |

### 4.2 Takvim üreteci (ekonomi defteri yok)

İki rakip modeli birleşir: Model B'nin statik `rivals.json` çıkış takviminin [kod data/product/rivals.json]
yerini **kişilik-tempolu deterministik takvim üreteci** alır: `f(run_seed, kişilik, hat kataloğu, takvim
penceresi, oyuncu gönderi kaydı [yalnız kopyacı]) → çıkışlar`. Çıkışlar `Rival.line_tiers`'a yazılır
(**yeni** @export; restore'da katalog tohumunun üstüne serildiği için göç gerekmez)
[kod scripts/data_models/rival.gd:17-30]; `_rival_tier(slot, line)` buradan okur ve `rival_hits` slot
indeksine geçer (bugün `rivals.json` `tiers` + `rival_hits`, rakip = dizi konumu 0..2
[kod sprint_catalog.gd:622-627]). Şerit satırı mevcut `SprintBridges.tick_rivals` yolundan basılır
[kod scripts/systems/sprint_bridges.gd:125-134] ve büyük çıkış Piyasa eğrisi için ShockLog satırı düşer.
"Satıyor, işe alıyor, küçülüyor" yalnız aynı takvimde **yazarlı hamle vuruşudur** (işe alım satırı,
işten çıkarma satırı): çeşni + şok; kasa yok, kadro simülasyonu yok. AI döneminde takvimler kişiliğin
kademesinde AI çeşnili hatlara döner. Çıkışlar artık oyuncunun sprint sayısına değil takvime bağlıdır
(bugünkü kırık: `sprint_bridges.gd:128`).

### 4.3 İtiraz vuruşu: tek düzenli temas (dört cevap mevcut fiil; fiyat tek yeni cevap türü)

| Öğe | Tasarım | Dikiş |
|---|---|---|
| Ne zaman | Yeni olgu çifti `rival_ahead_line` / `rival_ahead_name` (detay paneli olan lig rakiplerinin — slot 1-2 — bir hattaki en yüksek kademesi > oyuncu; `_rival_tier` üstünden). Liste dışı rakipler itiraz öznesi olmaz [sahip gözü: alternatif, liste dışı rakip için "Ürünleri"ni çip hover'ında göstermek; yeni yüzey, maket ister]. Tek katalog satırı, aile `rival`; aile tekrarı yasağı toplantıda bir kezle sınırlar. Teknik/yüksek yıldız alıcıda hafif ağır [ÇD §8]; MVP sonrası 12 hafta muafiyet [ÇD §8] | `SalesProbes.facts_for` [kod scripts/systems/sales_probes.gd:46-91] + CATALOGUE satırı (**yeni**) |
| Anılan özellik | Rakibin GERÇEK `line_tiers` tablosundan argmax fark hattı; Piyasa detayındaki "Ürünleri" listesiyle aynı. Müşteri rakibin sahip olmadığı özelliği asla anamaz | birleşik `line_tiers` |
| Soru taslağı (onay bekliyor) | `PROBE_RIVAL_HAS_IT` · EN "{rival} already ships {line}. Why you?" · TR "{line} {rival} ürününde çoktan var. Neden siz?" | CSV (**yeni**) |
| Cevap: güç göster | Bedava; yalnız oyuncu başka bir hatta her rakibi geçiyorsa açık (yeniden çerçeveleme); kilitli hâl gerekçesi o hattı adlandırır | mevcut `show strength` fiili |
| Cevap: söz ver | Mevcut söz fiili; hedef `pick_pain_feature` yerine rakibin hattındaki sonraki adım [kod scripts/systems/b2b_sales_system.gd:406-428]; tek açık söz kilidi, `due_sprint`, tutuldu/kısmi/kırıldı bedelleri aynen; fark kapatan kart bayrağına da sayılır | `PromiseRegistry` |
| Cevap: fiyat | "Daha ucuz oluruz": **yeni** cevap türü `VERB_PRICE` (`sales_probes.gd` fiilleri bugün yalnız strength/admit/promise/charisma/reference [kod sales_probes.gd:32-36]); pazarlık çapasını ve tabanını düşüren küçük bayrak [ÇD scripts/systems/sales_constants.gd price_concession_pct], yenilemede hatırlanır | `NegotiationSystem` (**yeni bayrak**) |
| Cevap: referans/pilot | Mevcut referans fiili (aynı yıldızda aktif hesap varken açık); pilot aynı fiilin sunumudur, ayrı mekanik değildir | mevcut |
| Cevap: kabul et | Hep açık, küçük ibre | mevcut `admit` |
| Kayıp öğrenmesi | Rakip sorusunda kaybedilen toplantı hattı kaydeder: **yeni** `rival_gap` kayıp nedeni (kod neden id'sinden `SALES_LOSS_<NEDEN>`/`SALES_MEMORY_<NEDEN>` anahtarlarını kurar [kod sales_meeting_system.gd:402, 435; sales_meeting_adapter.gd:161]; `sales_ledger.gd:314` nedenle eşleşir) + `sales.rival_gap` katkısı (**yeni** seam, `seams_sales.gd`) + `CHIP_BY_SEAM` girişi [kod scripts/ui/meeting/sales_meeting_adapter.gd:28-37]. Prospect aynı soruyla döner; oyuncu hattı görevsiz hisseder | `_derive_loss_reason` (**yeni neden**) |

**Cevap ve kayıp metin taslakları** (onay bekliyor):

| Anahtar | EN | TR |
|---|---|---|
| `PROBE_RIVAL_ANS_STRENGTH` | Our edge is {line}. Nobody matches us there. | Bizim gücümüz {line}. Orada kimse bize yetişemiyor. |
| `PROBE_RIVAL_ANS_STRENGTH_LOCKED` | No capability of yours leads every rival yet. | Henüz hiçbir yetenekte bütün rakiplerin önünde değilsin. |
| `PROBE_RIVAL_ANS_PROMISE` | We will ship it. | Onu da çıkaracağız. |
| `PROBE_RIVAL_ANS_PRICE` | We will beat their price. | Fiyatta onların altına ineriz. |
| `PROBE_RIVAL_ANS_PILOT` | Try us for a month first. | Önce bir ay deneyin. |
| `PROBE_RIVAL_ANS_ADMIT` | They are ahead there today. | Orada bugün önden gidiyorlar. |
| `PROBE_RIVAL_HAS_IT_STANDARD` | Everyone ships {line} now. Why don't you? | {line} artık herkeste var. Sizde neden yok? |
| `SALES_LOSS_RIVAL_GAP` | Another vendor already has what we need. We will go with them. | Aradığımız şey başka bir firmada zaten var. Onlarla devam ediyoruz. |
| `SALES_MEMORY_RIVAL_GAP` | Last time another vendor had what we needed. | Geçen sefer aradığımız şey başka bir firmadaydı. |
| `MEETING_CHIP_RIVAL_GAP` | RIVAL | RAKİP |

`SALES_LOSS_*`/`SALES_MEMORY_*` yer tutucusuz: `:435` format'sız çevirir. Kilitli seçenek gerekçesi kendi
bilgeliğini söylemez (CLAUDE §5); yukarıdaki kilit satırı yalnız durumu adlandırır.

### 4.4 Özellik kararına etki (ufak kalır)

Mevcutlar korunur: "Rakip:" çipi, `_closes_rival_gap` kart bayrağı [kod sprint_catalog.gd:631-636], zorunlu
söz kartları. Tek ekleme: yetenek kartında **"N rakipte var"** sayısı (birleşik `line_tiers` üstünde tek
satır katlama). Taslaklar (onay bekliyor; `Fmt.count_key` tekil ikizi): `PRODUCT_CHIP_RIVAL_COUNT` ·
EN "{n} rivals have this" · TR "{n} rakipte var"; `PRODUCT_CHIP_RIVAL_COUNT_ONE` · EN "{n} rival has this"
· TR "{n} rakipte var". Başka hiçbir şey.

### 4.5 Yazarlı olay kancaları (2 yeni kart [I2] + 1 dönem kartı [I3]; sebepli, az, okunur)

| Vuruş | Taşıyıcı | Durum |
|---|---|---|
| Rakip müşterimizi kapıyor | `data/events/cards/rival/price_cut.json` | kalır; "{seam:rival.leader}" lig liderine yeniden hedeflenir |
| Rakip tur alıyor | `rival/funding_round.json` (price_cut'a zincirli) | kalır, lig liderine yeniden hedeflenir; ama lider halka açıkken tur manşeti karar C ile çelişir — kopya/hedef uyumu **onay bekliyor** (aday: fonlu girene hedefleme ya da yeni kopya; mühürlü TR, karar D yeniden açılmaz) |
| Rakip zorda / işten çıkarma | 1 şerit satır dizisi + 1 kart (yardım et / görmezden gel / müşterisini kap) | **yeni** [I2] |
| Rakibin çılgın Ar-Ge bahsi | Fonlu giren bir ay sonra kırılma manşetine ya da aşağı tura çözülen bahis duyurur | **yeni** [I2] |
| Rakip AI benimsiyor | Dönem bayrağı sonrası, kişiliğe kademeli; biri kart olur | **yeni**, dönem işi [I3] |

Gereken yerde yeni `rival.*` arketip seam'leri `seams_world.gd`'ye eklenir. Yeni kartların seçenekleri
("müşterisini kap", "yardım et") `EvChips.describe` kapsamına girer ya da taslakta `[VOCAB?]` kalır
(CLAUDE §5). Görev yok, rakip ekonomisi yok, karar listesi yok.

### 4.6 Tutulan ve emekli edilen bugünkü parçalar

| Parça | Hüküm |
|---|---|
| `Rival` + `RivalRegistry` kayıt kalıbı | **kalır, genişler** (`company_id`, kişilik, `line_tiers`) |
| Statik `rivals.json` çıkış takvimi | **emekli** — üreteç registry'ye yazar (iki modelin birleşmesi) |
| Finans pazar payı kartı | [sonra; ayrı iş — bu belge dokunmaz] Piyasa/registry verisine yeniden bağlanması adaydır |
| `MARKET_ACTORS` (yalnız-pay hayaletleri) [kod rival_catalog.gd:78-82] | [sonra; ayrı iş — bu belge dokunmaz] |
| `get_player_rank_in_startup_league` (çağıranı yok) [kod rival_registry.gd:75-84] | [sonra; ayrı iş — bu belge dokunmaz] |
| `_share_at` wobble hash'i [kod rival_registry.gd:211-228] | [sonra; ayrı iş — bu belge dokunmaz] Emekliliği pay kartını, düz hash'e kalibre "rakip" şerit eşiğini [kod news_feed_system.gd:39-50] ve `market_share_tracks_mrr` / `news_feed_weights_and_no_repeat` / endgame_smoke:7899-7949 vakalarını oynatır. Durumsuz saf-fonksiyon kalıbı Piyasa modelinin şablonudur |
| `rival.leader` seam'i [kod seams_world.gd:75-78] + `_rival_ahead()` [kod scripts/systems/vc_pitch_system.gd:1298-1303] | **kalır, lig liderine yeniden bağlanır.** Yeni yüklem: oyuncunun alt-türünde lider en az bir hatta oyuncudan yüksek kademede (`rival_ahead_line` olgusu boş değil). Her tipte DOMINANT dev olduğundan bugün hep true; VC sorusu bilgilendirici olur |
| 13×8 rakip kurulumu (`build_all`) [kod rival_catalog.gd:91-108] | **kalır**; yalnız oyuncunun alt-türü canlı kişilik katmanı alır |

## 5. Kalite çıtası: "Saat + Yayılım" [I2]

Kanıtlar ve işlenmiş karşılaştırma: `quality_bar/proposal.md` (üç aday + dürüst kıyas),
`code_quality_map.md` (F1-F12 teşhisleri), `games_expectation.md`, `product_theory.md` (§10). Bugünkü
kırıklar kısaca: faz basamağı başarıyı cezalandırır (F1), çıkış başına kalıcı +0,5 Güçlü'yü aritmetik
olarak kapatır (F3), hiçbir şey takvimi okumaz, Gelir asla Güçlü olamaz.

### 5.1 Formül

Yazarlı tarihli tablo: `data/product/market_bar.json` (**yeni**; alt-tür ve pazar başına
`{line, tier, date}` satırları). Her (hat ℓ, kademe k) için:

```
A(ℓ,k,t)   = lig içinde kademesi ≥ k olan rakip sayısı (lig tanımı §4.1; dev ağırlık 1, gizli özel yok)
pull_date  = A'nın M'ye (çoğunluk) ilk ulaştığı tarih + L (yayılım gecikmesi)
eff(ℓ,k)   = max( D(ℓ,k) − P_max,  min( D(ℓ,k), pull_date ) )
muafiyet   : `avail` alanı taşıyan satırda eff ≥ avail + G; `avail` yoksa ya da koşu başlangıcından
             önceyse muafiyet uygulanmaz (**yeni** alan, yalnız dönem yeteneklerinde bulunur)
R(ℓ,t)     = eff'i t'yi geçmiş en yüksek k        (mandal: tarihler yalnız geçer, geri dönmez)
E(alan)    = alanın hatlarındaki R ortalaması     (0-3 float; kelime hesabı §5.3)
```

Sözle: **takvim çıtanın yükseleceğine karar verir; rakipler ne zamana, en çok yarım yıl oynatarak karar
verir; tek rakip tabanı asla kıpırdatamaz, yalnız Güçlü tavanını; yepyeni bir dönem yeteneği kim çıkarırsa
çıkarsın muafiyet penceresi boyunca çıta-muaf memnun edicidir.** On yıllık toplam enflasyon yazarlı
tabloyla sabittir: rakipler üst üste bindiremez (koşu bandı yok), ölü rakip alanı donduramaz.

`market_bar.json` biçim örneği (**yeni** dosya; tarihler I2'de bugünkü takvime, I3'te 2012'ye yazılır):

```
{ "meta": { "majority": "ceil_half", "lag_weeks": 12, "pull_cap_weeks": 26,
            "grace_weeks": 78, "telegraph_weeks": 8 },
  "erp": { "b2b": [
    {"line": "line_shared_security@erp",     "tier": 1, "date": "start"},
    {"line": "line_erp_ledger",              "tier": 2, "date": "2013-01"},
    {"line": "line_shared_integrations@erp", "tier": 1, "date": "2013-07"},
    {"line": "line_shared_mobile@erp",       "tier": 1, "date": "2014-04"},
    {"line": "line_ai_assist@erp",           "tier": 1, "date": "2024-01", "avail": "2023-01"} ] },
  "note_tool": { "b2c": [ ... ] } }
```

(Son satır tam oyun dönem örneğidir: `avail` taşır, muafiyet penceresi oradan sayılır.) Pazar farkı aynı
dosyadadır (B2B'de güven/entegrasyon erken, B2C'de onboarding/mobil erken); alıcı tipi *ağırlıkları*
bulundukları yerde kalır (mühürlü toplantı eksen ağırlıkları, itiraz ağırlığı).

Hesap yeri: `SprintCatalog.expectation()` [kod sprint_catalog.gd:113-121] ve `word_for`/`area_word`
[kod :123-134]; girdiler `GameState.get_date_dict` [kod game_state.gd:624], birleşik rakip kademeleri,
`market_bar.json`. R türetilir, **hiçbir şey kaydedilmez**; şema 15 kalır, probe bayt-determinizmi korunur.

### 5.2 Kelime kuralları

| Kelime | Kural |
|---|---|
| Yok | alan seviyesi 0 |
| Zayıf | R ≥ 1 olan herhangi bir hat R'sinin altında; hover **bağlayıcı nedeni** adlandırır (iki cümleden büyük olanı; ikisi birden asla) |
| Yeterli | tüm R'ler karşılanmış |
| Güçlü | tüm R'ler karşılanmış **VE** (alan seviyesi ≥ E+1 **YA DA** oyuncu alanın her hattında lig liderine eşit ya da üstün). "İkisinden biri" (sahip kararı E) Güçlü'yü her yerde, tek kademeli Gelir dahil, yeniden ulaşılabilir kılar |

`word_for` kelime id'leri (`none/weak/enough/strong`) ve anahtarları değişmez; kayıtlı sürüm notlarının
tarihsel kelimeleri olduğu gibi kalır (bugün de öyle).

### 5.3 Okunurluk yüzeyleri ve telgraf (tek veri, üç yüzey)

| Yüzey | Metin taslağı (onay bekliyor) |
|---|---|
| Alan hover, tarih-bağlı | `PRODUCT_BAR_WHY_DATE` · EN "Expected: {step}. Sector standard since {year}." · TR "Beklenen: {step}. {year} yılından beri sektör standardı." |
| Alan hover, yayılım-bağlı | `PRODUCT_BAR_WHY_SPREAD` · EN "Expected: {step}. {n} of {total} rivals have it, so it is now the sector standard." · TR "Beklenen: {step}. {n}/{total} rakipte var, sektör standardı oldu." |
| Telgraf (8 hafta önce, Ürün sekmesi satırı + tek şerit satırı) | `PRODUCT_BAR_TELEGRAPH` · EN "Market expectation rising: {step} ({quarter})" · TR "Piyasa beklentisi yükseliyor: {step} ({quarter})" |
| Kart çipi | "N rakipte var" = A(ℓ,k) aynen (§4.4); R'ye yetiştiren kart mevcut fark-kapatma bayrağını alır |
| Satış itirazı | §4.3'teki vuruş slot 1-2 kıyasıdır; anılan hat R'nin de altındaysa soru sertleşir (`PROBE_RIVAL_HAS_IT_STANDARD`, §4.3) |

VC bağları [I2]: `_rival_ahead()` lig liderine (tanım §4.6); Series A zayıf ürün sorusu hiç geçilemeyen
ham-40 eksen kontrolü yerine en kötü R-fark hattına bağlanır [kod vc_pitch_system.gd:1262-1270 çevresi].
Term sheet `E_FIT_PRODUCT_DIMS` tabanı ayrı kalibrasyon kırığıdır; işaretlenir, bu işe bağlanmaz.

**Kelime hesabı ve tüketiciler.** Yeni Zayıf ve Güçlü kuralları hat bazındadır; skalar
`word_for(level, expect)` tek başına veremez. Kelime kuralları `area_word(area, tiers := {})` içinde
hesaplanır (`area_level`'ın `tiers` ezmesiyle aynı kalıp); `_shift`, `actual_sentence` ve
`product_model._area` "önce" kelimesini sürüm öncesi kademelerle aynı fonksiyondan alır [kod
sprint_catalog.gd:356, 589; sprint_bridges.gd:193-194; product_model.gd:136] — kural ayrılığı probe
kapısı 3'ün yasakladığı çevirmeleri üretirdi. `_weakest` önce Zayıf alanı, sonra en büyük R açığını seçer
[kod sprint_catalog.gd:730]; lead/PM'in zayıf alan seçimindeki davranış değişimi amaçlıdır. `_goal`
E = 0 iken bölmez, şeridi dolu gösterir [kod product_model.gd:346]. Alan cümleleri, kart etki satırı,
sprint öngörüsü ve sürüm notları aynı anahtarlarla kalır.

### 5.4 İşlenmiş örnek (kısa; tam tablolar `quality_bar/proposal.md`'de)

*erp (B2B), 5 Oca 2012 başlangıcı; adlar A.2 yedek setinden, yalnız örnek. Yazarlı: D(entegrasyon K1) =
2013-07 (h79), D(defter K2) = 2013-01 (h53), güvenlik K1 = başlangıçta. Lig (dev Bezistan, lider Merivel,
yerleşik Kalemiye, kopyacı Stokdar, niş Dirhem; M = 3): başlangıçta entegrasyon K1 kademeleri [dev 1, Merivel 1, Kalemiye 0, Stokdar 0,
Dirhem 1] → A = 3 ≥ M → çoğunluk zaten var → eff(K1) = h79 − 26 = h53. Satır `avail` taşımaz (başlangıçtan
önce kullanılabilir), muafiyet yok.*

| An | Olan | Oyuncunun gördüğü |
|---|---|---|
| H1 | R(entegrasyon)=0 | Faz sıçraması hiç olmaz; telgraf H45'te gelir |
| H30 | Merivel (lider) Entegrasyon K2 çıkarır; A(K2)=1 < M → **taban kıpırdamaz** | Şerit satırı; "Rakip:" çipi; Güçlü'nün lider dalı artık K2 ister (E+1 dalı açık kalır); sonraki toplantı K2 itirazını sorabilir. K1 oyuncusu Yeterli kalır |
| H53 | eff(K1) gelir (çoğunluk Temmuz'u Ocak'a çekti) | Entegrasyonu olmayan oyuncu **Zayıf**; hover yayılım cümlesi ("3/5 rakipte var"). Telgraf H45'te ateşlendi, sürpriz yok |

*note_tool (B2C):* rakip mobili erken çıkarır → çoğunluk + L + P_max tavanı → mobil Oca 2013'te
olmazsa-olmaz olur: B2B'nin 2014 tarihinden bir sezon erken, tam segment hikâyesi. Gelir: liderin ücretli
plan kademesi 1; oyuncu 1'deyse ve R karşılanmışsa **Gelir ilk kez Güçlü olabilir** (F3 regresyonunun
testi).

### 5.5 Emekli ve dokunulmayan

- **Emekli** (I2'de, aynı commit): `sprint.json` `expectation` faz tablosu [kod data/product/sprint.json:29],
  `rival_bump` :30, `rival_bump_max` :31. Testlerin emekliliği dahil onay sonrası (CLAUDE §3).
- **Kalır:** `rival_window_sprints` :32 (yalnız çip tazeliği), kelime id ve anahtarları, mühürlü toplantı
  sabitleri, `PHASE_BAR` [kod scripts/systems/quality_model.gd:145] bağımsız eksen tabanı olarak.
- **Şimdi dokunulmaz:** `_rival_relative_quality`, EROSION_THRESHOLD, WOM_*, CHURN_COEF kümesi (birlikte
  kalibre edilmiş; ACIK_KARARLAR :1326-1347). B2C aşınmasını "karşılanmamış olmazsa-olmaz sayısına"
  bağlamak doğru uzun vadeli birleşme, ama kendi artırımı (§6.2).

### 5.6 Probe kapıları (I2; harness değişikliği serbest, ayrı raporlanır)

Yeni `PROBE AREA` satırı (sprint başına alan: seviye, E, kelime, bağlayıcı neden). Kapılar:
1. **Kalıcı Zayıf yok:** `full_run*` preset'lerinde (seed 1-3) Zayıf'a düşen her alan, bot adlandırılan
   hattı kurduktan sonra N sprint içinde Yeterli'ye döner; hiçbir alan haftaların %40'ından çok Zayıf
   kalmaz [ÇD].
2. **Güçlü ulaşılabilir:** her alan için en az bir preset'te ilk-Güçlü süresi sonlu (Gelir dahil).
3. **Açıklanamayan çevirme yok:** faz geçişinde sıfır kelime değişimi (eski F1); her çevirmenin bağlayıcı
   nedeni loglu; takvim adımı ya da çıkış başına ≤ 1 alan çevrilir.
4. **Ayrışma:** `full_run_b2c_k1` ile `full_run_b2c` kelime profilleri ayrışır: alan başına kelime
   kademesi farkının toplamı haftayla monoton artar ve koşunun son çeyreğinde ≥ 2 kalır [ÇD].
5. **Ekonomi bantları:** B2B kazanma oranı, B2C kapı haftası, Series A zamanlaması, sonlar seed 1-3'te
   bugünkü bantlarda kalır (çıta ekonomiye yalnız lider kartından dokunur; sapma büyükse gerçek bulgudur).

## 6. Artırımlar ve sonrası

### 6.1 I1-I4

| # | İçerik | Boy | Gerekçe ve görsel kabul |
|---|---|---|---|
| **I1 · Piyasa salt-okunur** | Önce P3 maketleri → `MarketCompany`/`MarketPerson` kataloğu (~40 dev + sektör katmanı, P1 taramalı) + saf değer fonksiyonu ve karıştırıcı + ray sekmesi (TABS/LeftTabs/window_layer/SPECS + sıra smoke'u) + liste/detay/grafikler + `seed_post_money_m` + `finance.valuation` seam'i + `PER_NO_VALUATION` düzeltmesi + `piyasa` şerit kaynağı + kayıt girişleri + kadro yeniden adlandırması (P1 parodi setleri, Ek A) | M | İlk teslim edilebilir: saf ekleme, denge riski yok, sahibin çekirdek fantezisini anında verir. 2026 başlangıcına karşı çıkar; çapalar veridir. Görsel kabul: `--tab-shot=piyasa` TR+EN+cb, maketle karşılaştırma |
| **I2 · Hafif rakipler + kalite çıtası** | Model birleşmesi + takvim üreteci + kişilikler + itiraz vuruşu (olgu/soru/fiiller/kayıp nedeni) + çıta hesabı + kelime kuralları + lider tacı + VC yeniden bağı + `PROBE AREA`; `rival_bump` aynı commit'te emekli; rakip hamleleri → ShockLog → liste görünür tepki verir | M | I1 varlıklarının üstüne; pencerenin "yaşamaya" başladığı yer. Görsel kabul: itiraz vuruşlu toplantı `--meeting-shot=rival` (**yeni** tür), Ürün alan hover'ı, telgraf satırı |
| **I3 · Dönem göçü** | **Kendi işi.** Kayıtlı `start_date` (2012-01-05) + `days_per_tick`/`tick_epochs` + `time.year` seam'i + test yeniden sabitleri + `subgenre` varsayılanı "saas" + AI içeriği yıl etiketli + `ai_engine` yeniden çeşnisi + AI benimseme kartı + GDD ZAMAN MODELİ §5 yeniden yazımı + kayıt göçü + Piyasa kataloğu 2012'ye yeniden çapalı + sezdirme (düz GPU devi, kilitli "2015+" dal etiketi, AlexNet şerit selamı) | M-L | En geniş etki alanı (test, GDD, şema, ürün tipleri), sıfır yeni ekran; bütün inmek zorunda. Üçüncü sırada: I1/I2 görünür değeri önce gönderir, hiçbiri 2026'yı sert kodlamaz |
| **I4 · Kişiler + cila** | Kişiler servet listesi (servet = pay × değer; oyuncunun kurucusu Seed sonrası `equity% × post-money`) + son bakıştan beri deltaları + geçiş satırları + çeyreklik kazanç şokları | S | I1 verisi üstünde katkısal UI. Görsel kabul: Kişiler maketi (P3) + `--tab-shot` |

### 6.1.1 Kaba dokunuş listeleri (en kısa yol; tam harita `piyasa_research/code_map.md`)

**I1:** `data/market/companies.json` + `people.json` (**yeni**, P1 sonrası) · `scripts/systems/market_catalog.gd`
+ değer fonksiyonu (**yeni**; durumsuz saf-fonksiyon kalıbı, splitmix karıştırıcı) · GameState kayıt
değişkenleri (`market_catalog_version`, ShockLog, Ownership; katalog kaydedilmez, §3.7) · `ui_tokens.gd
TABS` + `TAB_PIYASA` CSV + `LeftTabs.tscn` düğmesi + `window_layer.gd TAB_SCENES/SPECS` + yeni sekme
sahnesi + `main.gd` tab-shot · `seed_round_system.gd accept()` + `game_state.gd` (`seed_post_money_m`) +
`seams_finance.gd` (`finance.valuation`) + `personal_tab.gd` okuma + `PER_NO_VALUATION` ·
`news_feed_system.gd` (`piyasa` kaynağı + `TARGET_*` yeniden kesimi + counts backfill) ·
`rival_catalog.gd` NAMES oynanabilir kadroların yeniden adlandırması (üç alt-tür de I1'de; P1 parodi
setleri, iyi hedefi olmayan slotta Ek A.2-A.4 yedek adı, A.4 adı taranmadan yazılmaz) + `rival.gd`
(`company_id`) + özel adları okuyan smoke vakaları önce bulunur (CLAUDE §12 tuzağı).

**I2:** `data/rivals/schedule.json` (**yeni**) + üreteç (`rival_registry` ya da yeni statik sistem) ·
`rival.gd` (`line_tiers` **yeni** @export) + `rival_catalog.gd` (kişilik verisi) · `rivals.json`
takviminin emekliliği + `sprint_bridges.tick_rivals` beslemesinin üretece dönmesi ·
`data/product/market_bar.json` (**yeni**) + `sprint_catalog.gd` (`expectation`/`area_word` yeniden
yazımı, `_weakest`, `_shift`, `rival_leader` [kod :514-521] lig liderine) + `product_model.gd` (`_area`,
`_goal`) + `sprint_bridges.gd` (sürüm notu kelimesi) + `sprint.json` emeklilikleri · `sales_probes.gd`
(olgu çifti + katalog satırı + `VERB_PRICE` + `RIVAL_GRACE_WEEKS`) + `sales_meeting_system.gd` +
`sales_ledger.gd` (kayıp nedeni) + `sales_meeting_adapter.gd` (çip) + `sales_constants.gd` (fiyat tavizi
bayrağı) + `negotiation_system.gd` (çapa okuması) + `seams_sales.gd` (`sales.rival_gap` **yeni**) ·
`vc_pitch_system.gd` (`_rival_ahead`, zayıf ürün sorusu) + `seams_world.gd` (`rival.leader`, `rival.*`) ·
2 kart retargeti + 2 yeni kart · `run_probe.gd` (`PROBE AREA`) + taban kayıtları.

**I3:** §2.4 tablosu aynen. **I4:** Kişiler görünümü (I1 verisi üstünde) + pencere kapanış anlık
görüntüsü + çeyrek şok takvimi + geçiş manşet tetikleri.

### 6.2 Sonra gelenler (bu belge tanımlamaz, yalnız listeler)

- Perde 3 rezervlerinin açılması (§3.9: hisse almak, satın almalar, NPC birleşmeleri, oyuncunun IPO'su).
- B2C aşınma/WOM kümesinin çıtaya bağlanması (kendi artırımı, probe kapılarıyla; §5.5).
- 2009 "kriz başlangıcı" modu (tam oyun; tek satırlık rezerv).
- Oynanamayan 10 alt-türün ad temizliği, o alt-türü oynanabilir yapan işte (Ek A kuralı).
- Finans pay kartının Piyasa verisine bağlanması + `MARKET_ACTORS`/`_share_at`/`get_player_rank`
  emeklilikleri (§4.6 [sonra] satırları; şerit eşiği ve smoke'larıyla birlikte kendi işi).

## 7. Doğrulama listesi (artırım etiketli)

1. [I1] Piyasa sekmesi rayda; sıra smoke'u `rail_tabs_match_scene_order` yeşil.
2. [I1] Liste `companies.json` halka açık satır sayısıyla birebir (~42); hepsi fiyat + değer + kıvılcım çizgisi basar.
3. [I1] Fiyat = değer / `shares_outstanding`; hiçbir fiyat serisi kayda yazılmaz (kayıt boyu ölçülür).
4. [I1] Grafik aralıkları 13H/1Y/5Y/Tümü; yıl sonu tablosu her devde ilk haftadan dolu (koşu öncesi geçmiş çapalardan).
5. [I1] Aynı seed + aynı ShockLog → bayt-aynı eğri (iki koşu karşılaştırması).
6. [I1] Karıştırıcı dokusu: haftalık log-delta dağılımının standart sapması eşiğin üstünde [ÇD] ve ardışık iki haftada aynı delta yok (eski `_share_at` kırığının testi).
7. [I1] Seed kabulünde `seed_post_money_m` yazılır; eski kayıtta Seed alınmışsa yüklemede türetilir; karşılaştırma satırı belirir, öncesinde yok.
8. [I1] `finance.valuation()` seam kayıtlı; Kişisel servet bölümü aynı değeri okur (`run_valuation_m == 0` kontrolü kalktı).
9. [I1] `PER_NO_VALUATION` yeni metni ekranda (TR+EN).
10. [I1] Özel şirket listede yok; gizli özel hiçbir yüzeyde görünmez.
11. [I2] Fonlu girenin turu yalnız şerit haberi.
12. [I1] `piyasa` şerit kaynağı kota yürüyüşünde; eski kayıt yüklenince `counts` backfill çalışır.
13. [I1] Her piyasa haber satırı sebep taşır ("{headline} ({why})").
14. [I1] Ek A: yazılan her ad ve kişi adının hükmü kanıtlı: parodi adlarda "temiz-parodi" (P1 tabloları), yedek uydurma adlarda "temiz" (Ek A.2-A.3); "çakışma" hükümlü ya da FORBIDDEN_TERMS içeren hiçbir ad katalogda yok.
15. [I1] Oyuncu eylemi hiçbir çapayı değiştirmez (katalog başlık kuralı + test: MRR değişimi → eğri aynı).
16. [I2] İki rakip modeli birleşik: `rivals.json` takvimi yok, üreteç `Rival.line_tiers` yazıyor.
17. [I2] Kişilik eşlemesi: lider slot 1'de, kopyacı çıkışları oyuncuyu ≥3 sprint gecikmeyle izliyor.
18. [I2] İtiraz vuruşu toplantıda en çok bir kez; MVP sonrası 12 hafta hiç gelmez.
19. [I2] Anılan özellik rakibin gerçek kademe tablosundan; Piyasa "Ürünleri" paneliyle aynı liste; özne yalnız slot 1-2.
20. [I2] Dört cevap mevcut fiillerle, fiyat cevabı tek yeni `VERB_PRICE` türüyle çalışır; söz `due_sprint` + tek açık söz kilidine uyar.
21. [I2] Fiyat tavizi bayrağı pazarlık çapasını düşürür ve yenilemede hatırlanır.
22. [I2] `rival_gap` kayıp nedeni (`SALES_LOSS_RIVAL_GAP` ekranda) + `sales.rival_gap` çipi kayıtta ve ekranda.
23. [I2] "N rakipte var" sayısı kartta; A(ℓ,k) ile birebir; tekil anahtar tekilde.
24. [I2] `rival.leader` ve `_rival_ahead()` lig liderini okuyor; `_rival_ahead` artık her koşuda true değil.
25. [I2] İki eski kart lig liderine hedefli; 2 yeni kart `--why-fire` ile ateşlenebilir.
26. [I2] R mandallı: hiçbir R azalmaz (probe taraması).
27. [I2] Tek rakip çıkışı tabanı oynatmaz; çoğunluk + L sonrası oynar (birim örneği).
28. [I2] Muafiyet: `avail` + G içinde hiçbir dönem yeteneği Zayıf üretmez; `avail` olmayan satırda muafiyet yok.
29. [I2] Her çıta yükselişi 8 hafta önce telgraflı (Ürün satırı + şerit).
30. [I2] Zayıf hover'ı bağlayıcı nedeni basar; iki cümle aynı anda asla.
31. [I2] §5.6 probe kapıları 1-5 yeşil: kalıcı Zayıf yok, Güçlü her alanda (Gelir dahil) en az bir preset'te sonlu, faz geçişinde sıfır çevirme, ayrışma metriği, ekonomi bantları.
32. [I2] `rival_bump*` ve faz tablosu repoda yok; `rival_window_sprints` duruyor; `PHASE_BAR` bayt-aynı.
33. [I3] `start_date`/`days_per_tick`/`tick_epochs` kayıtlı; eski kayıt göçle 2026 koşusunu bozulmadan yükler.
34. [I3] `time.year` seam'i kayıtlı; dönem içerikleri takvimden, ekonomi tikten okur (örnek çift test).
35. [I3] 2026 sabitli smoke'lar 2012'ye taşınmış; tam paket yeşil.
36. [I3] Sezdirme üçlüsü ekranda: düz GPU grafiği, "2015+" dal etiketi, AlexNet şerit satırı.
37. [I3] AI benimseme kartı `--why-fire` ile ateşlenebilir; dönem bayrağından önce hiç ateşlenmez.
38. [I4] Kişiler listesi: servet = pay × değer; oyuncunun kurucusu Seed sonrası doğru değerle.
39. [I4] Son bakıştan beri deltaları yalnız pencere kapat/aç döngüsünde değişir.

## 8. Açık [ÇD] değer tablosu (onay bekliyor; tek tablo)

| Değer | Çalışma değeri | Yol |
|---|---|---|
| M (çoğunluk) | ceil(lig/2); görünür lig 5-6 → M = 3 | [ÇD data/product/market_bar.json meta.majority] |
| L (yayılım gecikmesi) | 12 hafta | [ÇD market_bar.json meta.lag_weeks] |
| P_max (öne çekme tavanı) | 26 hafta | [ÇD market_bar.json meta.pull_cap_weeks] |
| G (muafiyet penceresi) | 78 hafta (18 ay) | [ÇD market_bar.json meta.grace_weeks] |
| Telgraf süresi | 8 hafta | [ÇD market_bar.json meta.telegraph_weeks] |
| Telgraf kısıtı | L ≥ telgraf süresi; eff koşu başlangıcından sonraki ilk 8 haftaya düşemez (yoksa yükseliş telgraflanamaz) | kural; market_bar doğrulayıcısı zorlar |
| market_bar tarih satırı sayısı | alt-tür başına 15-25 (demo dilimi 6-9) | [ÇD market_bar.json rows] |
| Üreteç tempoları | §4.1 tempo tablosu | [ÇD data/rivals/schedule.json tempo.*] |
| İtiraz muafiyeti | MVP sonrası 12 hafta | [ÇD sales_probes.gd RIVAL_GRACE_WEEKS (**yeni**)] |
| İtiraz toplantı ağırlığı | teknik/yüksek yıldız alıcıda hafif ağır | [ÇD sales_probes.gd CATALOGUE satırı] |
| Fiyat tavizi | çapa ve taban düşüşü, birkaç % | [ÇD sales_constants.gd price_concession_pct] |
| `TARGET_PIYASA` + yeniden kesim | mevcut `TARGET_*` ile toplam 1.0 | [ÇD news_feed_system.gd TARGET_*] |
| Rakip şerit tavanı | rakiple ilgili satır (rakip + piyasa + çıkış + hamle) haftada en çok N (karar A) | [ÇD news_feed_system.gd] |
| Dev haftalık gürültü | ±%0,5-2 | [ÇD data/market/companies.json noise.sigma_giant] |
| Küçük şirket haftalık gürültü | %2-5 | [ÇD companies.json noise.sigma_smallcap] |
| Çeyreklik kazanç şoku | ±%5-15 | [ÇD companies.json shocks.earnings_pct] |
| Manşet eşiği | haftalık \|Δ\| > %8; ilk 10 giriş/çıkış; geçişte en çok 1 | [ÇD companies.json news.*] |
| Sıra/Δsıra kadansı | 4 hafta | [ÇD companies.json news.rank_weeks] |
| Özel tur temposu | 18-30 ayda bir, ×1,5-3 ya da aşağı tur | [ÇD companies.json private_rounds.*] |
| Kalıcı Zayıf tavanı (probe kapısı 1) | haftaların %40'ı | [ÇD scripts/debug/run_probe.gd gate] |

## 9. Ön koşullar

- **P1 · Parodi ad kataloğu** (karar G; Ek A.1 parodi yasası). Akış: **üret → tuvalde sahip seçer →
  seçilenler taranır → Ek A'ya hüküm + kanıtla işlenir**; taranmamış ad kataloğa yazılmaz. Üretimde her
  hedef için 2-4 aday + tek satır espri gerekçesi; tarama seçimden sonra koşar (arama bütçesi), demo'da
  görünür adlarda ad başına ≥ 2, dolguda 1 sorgu. Kapsam:

  | Küme | Adet | Parodi hedefi |
  |---|---|---|
  | Adlı dev arketipleri (+ liste dışı özel AI laboratuvarı) + kurucu/CEO'ları | ~15 + ~15 | hedefler `real_timeline.md` §1'deki gerçek devler, arketip eşlemesi §6 (cihaz devi, GPU üreticisi…) |
  | Dolgu devleri + kurucu/CEO'ları | ~26 + ~26 | sektörlerinin tanınmış global örnekleri; Türk devi yok (karar C: her devin kurgusal kurucu/CEO'su var) |
  | Sektör kadroları (3 oynanabilir alt-tür × 8 slot) + halka açık slotların (0-2) kurucu/CEO'ları | 24 + ~9 | erp: SAP/Oracle çevresi; note_tool: Evernote/Notion çevresi; video_clip: CapCut çevresi; iyi hedef yoksa slot Ek A.2-A.4 yedek adını alır, A.4 adı önce P1'de taranır |
  | Fon adları (Ek A.7) | ≥ 8 | tanınmış VC, melek ağı ve hızlandırıcı parodileri serbest |

  Bir gerçek hedef yalnız bir parodiye gider (büyük liste ve sektör kadroları birlikte): Oracle veritabanı
  dinozoru olarak kullanılırsa erp kadrosu onu tekrar parodilemez. Çakışma alan ya da çağrışımı okunmayan
  ad tuvale geri döner; sahip o hedef için yeni aday seçer, tarama yalnız yeni seçime koşar. Yayın adları
  (Ekonomi Postası, TeknoGündem) ve Yalçın Teknoloji Holding v4 karar 24'te tutuluyor; I1'de değişmez
  (Ek A.5). Eski uydurma setler yedek olarak kalır (Ek A.2-A.3 taranmış ve temiz; A.4 doğrulanmamış).
- **P3 · Menajer maketleri** (yeni ekran onaylı maketten kurulur): §3.8 tablosu; I1 öncesi ilk üç satır,
  I2/I3/I4 öncesi kendi satırları. TR+EN, renk körü, 1.0 ve 1.25 ölçek, sahip onayı.
- **P4 · Taban ölçümü** (I2 öncesi): bugünkü kelime dağılımı, kayıp nedenleri dağılımı ve ekonomi
  bantları `full_run*` seed 1-3'te kayda alınır; `PROBE AREA` eklenince tüm probe taban kayıtları
  yeniden yazılır (harness serbest, ayrı rapor). Sos bekçisi: itiraz vuruşunun toplantıların yüzde
  kaçında geldiği ölçülür ve raporlanır (sabit değiştirmez, karar A).
- **Frank metni: GEREKMEZ — doğrulandı.** Görev yok (karar A); itiraz vuruşu, telgraf, hover ve kartlar
  sistem/dünya sesidir ve hüküm vermez (hüküm yalnız Frank'in ağzındadır, CLAUDE §5). Hiçbir artırım
  Frank satırı eklemiyor; ileride eklenirse yalnız taslak olarak doğar.

## 10. Kaynaklar

Oturum scratchpad kökü: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/bdb8d661-b2cc-40d3-a6eb-43f58d809039/scratchpad/`

- `piyasa_research/proposal.md` — dönem + Piyasa + hafif rakipler bütünleşik tasarımı.
- `quality_bar/proposal.md` — üç çıta adayı, işlenmiş örnekler, Aday C önerisi.
- `piyasa_research/market_ui.md` — liste/detay ekran kalıpları (companiesmarketcap, CB Insights, Capitalism Lab).
- `piyasa_research/real_timeline.md` — 2010-26 gerçek değer eğrileri, analog tablo, dönem olayları.
- `piyasa_research/objections.md` — rakip itirazı pratiği (Gong bulguları) ve tek dikiş tasarımı.
- `piyasa_research/era_games.md` — dönem ilerleyişi emsalleri (GDT takvimi, OpenTTD takvim/ekonomi ayrımı).
- `piyasa_research/market_model.md` — borsa modeli emsalleri (Software Inc kırıkları, RT3, Capitalism Lab).
- `piyasa_research/code_map.md` — takvim, kabuk, kayıt, haber, satış ve değerleme kod haritası.
- `quality_bar/code_quality_map.md` — beş çıta envanteri, F1-F12 teşhisleri, probe ölçüm planı.
- `quality_bar/games_expectation.md`, `quality_bar/product_theory.md` — koşu bandı/çıpa emsalleri; Kano
  göçü, Rogers eşikleri.
- `rival_research/r1_synthesis.md`, `r1_critique.md` — birinci tur sentez ve eleştirisi (Capsim eki).
- v5 taslağı (`rival_page/prd.md`, rafta) — yalnız Ek A yöntemi + temiz setler ve sebepli haber disiplini.

## Ek A — Ad kataloğu ve marka taraması (A.1 karar G ile yeni; yedek setler v5'ten)

### A.1 Yöntem ve hükümler (parodi yasası, karar G)

Adlar gerçek şirket ve kişilerin bilinçli parodileridir: çağrışım ret sebebi değil, **hedeftir**. Arama
bütçesi §9 P1'dedir: demo'da görünür adlarda ad başına en az iki, dolgu adlarında bir web araması ("<ad>"
+ pazar kelimeleri; Türkçe adlarda "<ad>" yazılım; kişi adlarında "<ad>" + rol kelimesi). Hüküm:
- **temiz-parodi** (hedef): hangi şirketi/kişiyi çağrıştırdığı belli; yazım güvenli mesafede (birebir
  değil, önemsiz harf farkı değil); parodi adın kendisi yaşayan başka bir marka, ürün ya da şirketle
  çakışmıyor.
- **çakışma** (ret): gerçek adın aynısı ya da karıştırılacak kadar yakını; ya da parodi ad başka canlı bir
  markayla çakışıyor.

Ek kurallar: gerçek kişinin adı birebir yazılmaz, dönüştürülmüş kelime oyunu serbesttir; logo ve görsel
benzetme yapılmaz (ikon işi ayrı karar); parodi, şirketi ya da kişiyi aşağılamaz, espri hafif kalır.
**Parodi ad gerçek markayı alt dize olarak taşımaz:** `scripts/events/tools/lint.gd` `FORBIDDEN_TERMS`
listesindeki [kod lint.gd:344-348] hiçbir terimi içermez; GDD v2 ch14 §6 "gerçek marka rakip ya da ürün
olarak asla" kuralı geçerlidir (motor GDD D6 ve §22.3: RivalCatalog dahil); ihlal "çakışma" hükmüdür.
Kanıt tabloya işlenmeden ad kataloğa yazılmaz. Tarama sahibin tuval seçiminden sonra, yalnız seçilen
adlara koşar (§9 P1); çakışma alan ya da çağrışımı okunmayan ad tuvale geri döner, sahip o hedef için yeni
aday seçer, tarama yalnız yeni seçime koşar (tuval: adayların hedef ve espri gerekçesiyle yan yana
sunulduğu sahip seçim belgesi). Yedek uydurma setlerde (A.2-A.4) eski hükümler kayıt olarak kalır:
**temiz** (ilgili yazılım ya da ünlü marka yok), **çağrışım** (bilinen bir teknoloji markasının yakın
varyantı), **çakışma** (aynı ya da önemsiz yazım farkıyla yaşayan bir marka); **yıldızlı** ad taranmamıştır,
temiz sayılmaz. Uydurma bir ad kazara çağrıştırmamalıdır; parodi yasası yalnız bilinçli parodi adlara
uygulanır. Oynanabilir olmayan 10 alt-türün adları I1'de olduğu gibi taşınır (ekrana çıkmazlar);
temizlikleri o alt-türü oynanabilir yapan işte.

### A.2 erp yedek seti (uydurma, tarandı, temiz; parodi seti P1 sonrası bu bölümde yedek tablonun üstüne yazılır; rol sütunu v6 eşlemesi, §4.1)

| Slot | Rol | Ad | Kayıt |
|---|---|---|---|
| 0 | Dev | Bezistan | TR |
| 1 | Lig lideri | Merivel | uluslararası |
| 2 | Yerleşik | Kalemiye | TR |
| 3 | Fonlu giren | Halvero | uluslararası |
| 4 | Gizli özel | Veznedar | TR |
| 5 | Kopyacı | Stokdar | TR |
| 6 | Niş (ev alanı entegrasyonlar) | Dirhem | TR |
| 7 | yedek | Nolvik | uluslararası |

Yerli seçenek: 1 Senedat, 3 Tacirhane, 7 Kesedar (temiz). Uluslararası yedekler: Varelo, Ulvano (temiz).
Bugünkü adlardan Defterdar, Muhasip, Ledgero, Sayman, Tezgâh **çakışma**; Kasa & Stok, Envanter, Faturacı
A.6 gereği kullanılmaz. Elenen aday listeleri v5 yedeğindedir (§10).

### A.3 video_clip yedek seti (uydurma, tarandı, temiz; parodi seti P1 sonrası bu bölümde yedek tablonun üstüne yazılır; rol sütunu v6 eşlemesi, §4.1)

| Slot | Rol | Ad | Kayıt |
|---|---|---|---|
| 0 | Dev | Mizansen | TR |
| 1 | Lig lideri | Pivotreel | uluslararası |
| 2 | Yerleşik | Tefrika | TR |
| 3 | Fonlu giren | Halftake | uluslararası |
| 4 | Gizli özel | Sahnecik | TR |
| 5 | Kopyacı | Shortlark | uluslararası |
| 6 | Niş (ev alanı onboarding, "telefonda kurgu") | Karecik | TR |
| 7 | yedek | Cutfinch | uluslararası |

Yerli seçenek: 1 Seyirlik, 3 Sinemacık, 5 Tadımlık, 7 Peşrev (temiz). Yedekler: Shotfern, Moxlet, Lumfold,
Takefold (temiz). Bugünkü adlardan Kesit, Klipsa, Makas, ShortForge, Reelo **çakışma**; Altyazıcı,
Montajcı **çağrışım**.

### A.4 note_tool yedek adayları (uydurma, doğrulanmadı; parodi seti P1 sonrası bu bölümde yedek tablonun üstüne yazılır)

Önerilen aday seti (tümü yıldızlı, temiz sayılmaz): 0 Mecmua · 1 Ideafold · 2 Satır Arası · 3 Derkenar ·
4 Margina · 5 Glyphnote · 6 Tezkire · 7 Corkline. Bugünkü adlardan Zihin Haritası, Notably, Bellek,
Fihrist, Karalama, Mürekkep **çakışma**; Kayıt ve Kâğıtsız A.6 gereği kullanılmaz. Set, P1 taraması bu eke
işlendikten sonra yazılır.

### A.5 Yayın kuralı

Yayın **eklemek ya da silmek** `D_OUTLETS`'e ve `--theme-contrast-audit`'e dokunur; **yeniden
adlandırmak** yalnız CSV'dir. Yayın adları ve Yalçın Teknoloji Holding I1'de değişmez (v4 karar 24).

### A.6 Ad kuralları (yeni adlar için; karar G ile güncellendi)

Parodi bilinçlidir (A.1), rastgele çağrışım ya da kazara çakışma değil; tire ve "&" yok; en çok iki
kelime; TR ve EN'de okunabilir; özellik ya da kategori adı gibi okunan çıplak sözlük kelimesi yok
("Envanter", "Zihin Haritası", "Kâğıtsız"); aynı pazarda aynı kökü taşıyan iki ad yok; özel ad çevrilmez.
Her yeni ad bu eke kanıtıyla eklenmeden kataloğa giremez.

### A.7 Fon adları (P1; tablo boş)

Yalnız özel tur şerit satırının `{fund}` yer tutucusu için (`data/market/companies.json`). Kural: en az
8 ad; A.6 kuralları; tanınmış girişim sermayesi fonlarının, melek ağlarının ve hızlandırıcıların
parodileri serbesttir (A.1 ve FORBIDDEN_TERMS kuralıyla: "sequoia", "a16z", "andreessen", "y combinator"
alt dize olarak bile geçemez); oyuncunun dört VC'sinin adı ve kökü kullanılmaz; TR ve EN'de aynı özel ad.
P1 sonucu
buraya Ad · Hüküm · Kanıt tablosu olarak işlenir; tabloya girmeyen ad yazılmaz.
