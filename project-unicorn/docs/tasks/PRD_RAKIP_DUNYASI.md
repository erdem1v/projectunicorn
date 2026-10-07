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
| v6 | bu belge | Sahip kararları A-F üzerine yeniden kuruluş: sos, görevsiz. v5'ten yalnız Ek A yedek setleri ve sebepli haber disiplini taşındı (A.1 yöntemi karar G ile değişti). 2026-10-06: sahip v6'yı uygulama için onayladı ([ÇD] değerleri ve metin taslakları onay bekliyor kalır); parodi ad yönü (karar G) işlendi. 2026-10-07: karar H (sektör kurgusu: teknoloji + 5 finans), Ek A parodi kataloğu (tur 2 + teknoloji dolgusu) ve taraması; P3 Piyasa maketleri onaylandı (V1 liste + rapor kartı; §3.4, §3.5, §3.8) |

## 1. Sahip kararları defteri (2026-10-06, bağlayıcı; bu belge bunları kodlar, yeniden açmaz)

| Karar | Özü | Kodlandığı yer |
|---|---|---|
| **A · Sos** | Rakip dünyası baharattır, çekirdek mekanik değil. **Görev yok, hiç kimseden, hiçbir zaman.** Rakipler oyuncuyu boğmaz | tüm belge; şerit tavanı §8 |
| **B · Dönem** | Koşu Per 5 Oca 2012 başlar (kod herhangi bir Perşembe kabul eder, doğrulandı); demo 2012-13 dilimi, AI devrimi (2022-23) yalnız sezdirilir; tam oyunda perde 2+ kayıtlı `days_per_tick` kabalaşır; `start_date` kayıtlı olur, dönem içeriği takvimi, ekonomi tiki okur, `time.year` seam'i eklenir; 2009 "kriz başlangıcı" tek satır rezerv; dönem göçü kendi artırımıdır (I3) | §2 |
| **C · Piyasa** | Yeni ray sekmesi: yalnız **halka açık (IPO yapmış)** kurgusal şirketler ("daha gerçekçi olur, hem tüm rakipleri de o listeye sokmayız"); ~40 dev + sektör devi + 1-2 küçük yerleşik; özel şirketler listede yok, turları şerit haberi; fiyat VE değer, fiyat sabit `shares_outstanding`'den türetilir; grafikler 13H/1Y/5Y/Tümü + yıl sonu tablosu; oyuncu listede değil, Seed sonrası sabit karşılaştırma satırı; IPO sonraki perdelerin özlemi; değer = yazarlı çapalar + sektör endeksi + splitmix gürültü + ShockLog; Perde 3 alanları rezerve-atıl; **oyuncu eylemleri çapalara asla geri beslemez**; Kişiler sekmesi I4; her devin kurgusal kurucu/CEO'su var. **P3 düzeltmesi 2026-10-07:** karşılaştırma satırı yerine üçüncü KPI karosu, oyuncuya sıra yok; fiyat listede kalır (§3.4, §3.5, §3.8) | §3 |
| **D · Hafif rakipler** | Alt-tür başına 6 kişilik (+ isteğe bağlı ikinci yerleşik), mevcut TEMPLATE slotlarına; ekonomi defteri yok, kişilik-tempolu deterministik takvim üreteci (çıkış, işe alım/çıkarma vuruşu, ShockLog); tek düzenli temas satış itirazı (aile başına toplantıda bir kez, MVP sonrası 12 hafta muafiyet, anılan özellik rakibin gerçek kademe tablosundan); kayıp anlaşma hattı kaydeder; özellik kararına etki ufak ("N rakipte var"); iki eski kart kalır, `rival.leader` ve `_rival_ahead()` lig liderine yeniden bağlanır | §4 |
| **E · Kalite çıtası** | Aday C "Saat + Yayılım": R(hat, kademe) yazarlı tarihli `market_bar.json`'dan; lig çoğunluğu (M = ceil(lig/2)) tarihi L = 12 hafta gecikmeyle en çok P_max = 26 hafta öne çeker; tek rakip tabanı oynatamaz; dönem yetenekleri G = 78 hafta çıta-muaf; her yükseliş 8 hafta telgraflı; Güçlü = tüm R + (seviye ≥ E+1 **ya da** her hatta lidere eşit/üstün); `sprint.json` faz tablosu ve `rival_bump*` emekli; B2C aşınma/WOM şimdi bağlanmaz; hiçbir şey kaydedilmez; tüm sayılar [ÇD] onay bekliyor | §5 |
| **F · Artırımlar** | I1 Piyasa salt-okunur (önce P3 maketleri) → I2 hafif rakipler + kalite çıtası → I3 dönem göçü (kendi işi) → I4 Kişiler + cila; I1 bugünkü 2026 başlangıcına karşı çıkar, çapalar veridir, I3'te yeniden çapalanır | §6 |
| **G · Parodi adlar** (2026-10-06) | Şirket ve kişi adları gerçek hayattan uyarlanmış **parodilerdir**: oyuncu kimin çağrıştırıldığını anlar ama ad birebir yazılmaz ("Jeff Bezos olduğunu anlasın, Jeff Bezos yazmasın"). Kapsam her şey: devler, kurucu/CEO'lar, sektör rakipleri (global emsaller parodilenir: erp SAP/Oracle çevresi, note_tool Evernote/Notion çevresi, video_clip CapCut çevresi; gerçek küçük yerel firmalar parodilenmez). Sektörler-arası devler ve dolgu yalnız global, Türk devi yok; liste kuyruğundaki sektör yerleşikleri (slot 1-2) bu kurala girmez. **Düzeltme 2026-10-07:** devlerde, kişilerde ve fonlarda Türkçe karakter, Türkçe kelime ve Türkçe isim KULLANILMAZ; ad önce gerçek bir şirket ya da kişi adı gibi okunur (haber başlığı testi), espri ikinci bakışta; TR mizahı yalnız yerel dokuda (yedek uydurma setler). Tarz karışık, espri başına; adayları tuvalde sahip seçer; tarama seçimden sonra koşar, taranmamış ad kataloğa yazılmaz. GDD ch14 §6 gerçek marka yasağı bozulmaz: parodi gerçek marka değildir ve markayı alt dize olarak taşımaz (Ek A.1). Eski uydurma setler yedek | Ek A; §3.1; §9 P1 |
| **H · Sektör kurgusu** (2026-10-07) | Piyasa listesi sektöre göre kurulur ("sektör aware"): teknoloji şirketleri + IPO perdesi için 3-5 finans kurumu; ilaç, telekom, perakende, havacılık, petrol ve holding dolgusu YOK. Finans: evrensel banka, iki yatırım bankası (biri 2012 sosyal ağ halka arzının aracısı), perakende banka, ödeme ağı. 2012'de halka açık olmayan teknoloji şirketleri halka arz yılında listeye girer (`listed_week`, dönem olayı); liste Nasdaq-100 gibi okunur | §3.1; Ek A |

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

### 3.1 Evren (~50 halka açık satır, 2012'de ~35'i listede + liste dışı katman)

| Katman | Adet | Kim | Görünürlük |
|---|---|---|---|
| Teknoloji devleri ve dolgusu + finans | ~48 | Gerçek zaman çizelgesi tablosunun analogları (cihaz devi, OS/bulut, e-ticaret/bulut, arama, sosyal, **GPU üreticisi**, EV, yayın, SaaS öncüsü, veritabanı dinozoru, eski CPU, çöken telefoncu, video-toplantı balonu) + teknoloji dolgusu (çip ve ağ, donanım, internet 1.0, Asya devleri, dönem halka arzları, kurumsal yazılım, teknoloji komşuları) + 5 finans kurumu (karar H). Adlar gerçek analogların **parodileridir** (karar G; hedefler `real_timeline.md` §1'deki gerçek devler, arketip eşlemesi §6; §6'nın yer tutucu adları yalnız aday havuzudur); **her ad ve kişi Ek A taramasından geçmeden yazılmaz** (P1) | Halka açık: fiyat + değer + grafik |
| Sektör devi | 1 | SAP-benzeri "büyük rakip" = oyuncunun alt-türünün **mevcut dev slotu 0** [kod scripts/systems/rival_catalog.gd:22-31], listenin üstlerine terfi eder. Tek varlık, iki yüzey | Halka açık |
| Küçük sektör şirketleri | 1-2 | Yerleşik slotlar (1-2), kuyruğa yakın $30-300M; Seed değerlemesi kuyruğun altında kalır; ölçek karolardan okunur, sıra yok (§3.5) | Halka açık, liste kuyruğu |
| Özel şirketler | — | Listede YOK. Fonlu girenin turu şerit haberidir; gizli özel, veri olarak var olup sonraki bir olayla yüzeye çıkar | Liste dışı |
| Oyuncu | — | Listede YOK; Seed sonrası üçüncü KPI karosunda değerlemesi (§3.5), sıra yok. IPO sonraki perdelerin özlemidir | KPI karosu |

**Dev katalog kapsaması** (adsız arketip planı; adlar P1 taramasından sonra yazılır, eğri biçimleri
`real_timeline.md` §1 ve §6'daki gerçek verinin yuvarlanmış hâlidir):

| Arketip | Adet | Eğri rolü (dönem hikâyesi) |
|---|---|---|
| Cihaz devi | 1 | koşu başında #1; istikrarlı merdiven |
| OS/ofis/bulut devi | 1 | 2014 CEO değişimine kadar düz, sonra bulutla tırmanış |
| E-ticaret + bulut | 1 | güçlü büyüme, 2020 sivrilmesi, 2022 yarılanması |
| Arama/reklam | 1 | istikrarlı; 2023 "AI aramayı öldürür" düşüşü, 2025 sıçrama |
| Sosyal ağ | 1 | demo sırasında IPO (2012); kurucusu servet yarışının yüzü |
| **GPU üreticisi** | 1 | 2016'ya kadar DÜZ (demo sezdirmesi); 2023 sonrası hokey sopası |
| EV / gösterişçi CEO | 1 | aşırı oynak; 2020-21 roket, 2022 çöküş |
| Yayın platformu | 1 | büyüme, 2022 çöküşü, toparlanma |
| SaaS öncüsü | 1 | oyuncunun sektörünün barometresi; pürüzsüz SaaS tırmanışı |
| Veritabanı dinozoru | 1 | 13 yıl düz, 2023 sonrası veri merkezi sıçraması |
| Eski CPU devi | 1 | mobili ve AI'yı kaçıran yavaş solma |
| Çöken telefoncu | 1 | 2011'den itibaren çöküş; ibret hikâyesi |
| Video-toplantı | 1 | 2019 IPO, 2020 ×5, sonra sönme (tam oyun) |
| Özel AI laboratuvarı | 1 | Liste dışı (karar C); 2023 sonrası turları yalnız şerit haberi (tam oyun). Halka arzı yazarlı olaydır; olursa listeye o hafta girer |
| Dolgu: teknoloji | 30 | çip ve ağ (3), donanım (4), internet 1.0 (4), Asya devleri (2), dönem halka arzları (9), kurumsal yazılım (4), teknoloji komşuları (4); 2012'de halka açık olmayan HER satır (kategoriden bağımsız: sosyal ağ 2012, Alibaba 2014, Xiaomi 2018, Zoom 2019, Palantir 2020…) halka arz yılında `listed_week` ile girer (Ek A.8 "Listede (yıl)"); sektör endeksini taşıyan gövde; AI dalgasına beta ile katılır. Yalnız global parodiler; Türk devi yok (karar G, H) |
| Finans | 5 | evrensel banka, iki yatırım bankası, perakende banka, ödeme ağı; IPO perdesinin aracı bankaları (karar H); sektör endeksine düşük beta |

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

### 3.4 Ekran: liste ve rapor kartı (öğe tablosu)

| Öğe | İçerik | Kaynak |
|---|---|---|
| KPI karoları (pencere üstü, üç koyu karo) | **Liste değeri** (toplam + 4h %, 13 haftalık mini çubuk) · **Lider** (değer + 4h %, "ad · sektör · son 13 hafta", 13 çubuk) · **Senin değerlemen** (§3.5; sıra YOK) | değer fonksiyonu; `seed_post_money_m` / `run_valuation_m` |
| Filtre çipleri (listenin üstü, her durumda) | Tümü · Teknoloji · Finans · Sektörüm; seçili ink kenar, amber değil | katalog `sector_id` |
| Liste satırı (sol sütun 460 px; 1920'de 11 satır, 1536'da 8 + "ve N şirket daha") | `# (ink-4) · Ad + altında sektör · Değer · Fiyat`; ilk 3 satır büyük punto; Δsıra, 4h %, kıvılcım ve kurucu sütunu YOK (P3 kararı 2026-10-07: bilgi yoğunluğu); halka arz haftasında yeni satır "Yeni" etiketi | değer fonksiyonu; fiyat = değer / `shares_outstanding` (karar C) |
| Rapor kartı (sağ sütun; liste kapanmaz, satır tıklaması kartı değiştirir) | Ad + sektör etiketi + Kurucu/CEO + "Halka arz {y}" · kahraman değer + "dört haftada" % · yıl sonu etiket:değer (5 satır) + "{y} sonundan beri" · yarım daire kadran **Listedeki payı** · **13H / 1Y / 5Y / Tümü** + tek grafik (yıl sonu çapaları işaretli; 1G/5G yok, tik haftalık) · Hakkında 2 cümle. Yeni halka arzda yıl sonu listesi boş, "Halka arz {month}" satırı | değer fonksiyonu + katalog |
| Sektör rakibi kartında ek: "Ürünleri" [I2] | Rakibin çıkmış 2-4 yetenek hattı; **satış itirazının andığı listeyle aynı** (§4.3); listedeki payı %0,1'in altında "<%0,1" | birleşik `line_tiers` (I2) |
| Son bakıştan beri deltaları | Pencere kapanışında anlık görüntü; yeniden açılışta oklar | [I4] |

Onaylı maketler: `docs/mockups/menajer/screens/piyasa/` (9 çerçeve + INDEX.md; çalışma ağacında, izlenmez). Yön
sahip seçimidir: 37 referans ekrandan beğenilen ikisi (Startup Company "Website Stats" rapor kartı, Plutocracy
"Finances" karo panosu) → "liste + rapor kartı" (V1). İlk 11 karelik tablo seti ve dört yön eskizi reddedildi
(`rounds/`).

**Kadans** [ÇD tümü, §8]: haftalık değerlendirme (dev ±%0,5-2/h, küçük şirket %2-5); sıralar 4 haftada bir
yeniden kesilir (listede Δsıra oku yok, P3 karar 6), en çok bir geçiş manşeti; çeyreklik kazanç şokları ±%5-15 sebep satırıyla [I4]; manşet
tetikleri haftalık |Δ| > ~%8, ilk 10'a giriş/çıkış.

**CSV taslak anahtarları** (onay bekliyor; EN önce, TR sonra; tire yok):

| Anahtar | EN | TR |
|---|---|---|
| `TAB_PIYASA` | Market | Piyasa |
| `PIYASA_COL_RANK` (liste başlık satırı yok; COL_* yalnız sütun adı, erişilebilirlik) | # | # |
| `PIYASA_COL_COMPANY` | Company | Şirket |
| `PIYASA_COL_VALUE` | Market value | Piyasa değeri |
| `PIYASA_COL_PRICE` | Price | Fiyat |
| `PIYASA_KPI_LIST_VALUE` | List value | Liste değeri |
| `PIYASA_KPI_LEADER` | Leader | Lider |
| `PIYASA_KPI_YOUR_VALUATION` | Your valuation | Senin değerlemen |
| `PIYASA_KPI_LIST_DESC` | {c} companies · last 13 weeks | {c} şirket · son 13 hafta |
| `PIYASA_KPI_LEADER_DESC` | {name} · {sector} · last 13 weeks | {name} · {sector} · son 13 hafta |
| `PIYASA_KPI_POST_SEED` | Post seed · {month} | Seed sonrası · {month} |
| `PIYASA_KPI_SERIES_A` | Series A · Week {w} | Series A · Hafta {w} |
| `PIYASA_FILTER_ALL` | All | Tümü |
| `PIYASA_FILTER_TECH` | Technology | Teknoloji |
| `PIYASA_FILTER_FIN` | Finance | Finans |
| `PIYASA_FILTER_MINE` | My sector | Sektörüm |
| `PIYASA_LIST_MORE` | and {c} more | ve {c} şirket daha |
| `PIYASA_LIST_ABOVE` | {c} more above | {c} şirket yukarıda |
| `PIYASA_TAG_NEW` | New | Yeni |
| `PIYASA_LISTS_IN` | {name} · listing {month} | {name} · halka arz {month} |
| `PIYASA_LISTED_YEAR` | Listed {y} | Halka arz {y} |
| `PIYASA_FOUNDER_KEY` | Founder | Kurucu |
| `PIYASA_CEO_KEY` | CEO | CEO |
| `PIYASA_CARD_VALUE_DATE` | Market value · {month} | Piyasa değeri · {month} |
| `PIYASA_FOUR_WEEKS` | over four weeks | dört haftada |
| `PIYASA_EOY_FIRST` | Year end {y} | Yıl sonu {y} |
| `PIYASA_SINCE_EOY` | Since end of {y} | {y} sonundan beri |
| `PIYASA_SHARE` | Share of the list | Listedeki payı |
| `PIYASA_SHARE_LT` | <{p} | <{p} |
| `PIYASA_VALUE_TITLE` | Value | Değer |
| `PIYASA_ABOUT_TITLE` | About | Hakkında |
| `PIYASA_IPO_MARK` | listed | halka arz |
| `PIYASA_CTX_2012` (aile `PIYASA_CTX_<yıl>`; I3 dönem tablosundan yıla göre seçilir, §2.3) | {month} · The smartphone wave carries the list | {month} · Akıllı telefon dalgası listeyi taşıyor |
| `PIYASA_CTX_2013` | {month} · The year of mobile ads | {month} · Mobil reklam yılı |
| `PIYASA_RANGE_13W` | 13W | 13H |
| `PIYASA_RANGE_1Y` | 1Y | 1Y |
| `PIYASA_RANGE_5Y` | 5Y | 5Y |
| `PIYASA_RANGE_ALL` | All | Tümü |
| `PIYASA_EOY_TITLE` (ekranda başlık yok; bölüm adı, erişilebilirlik) | End of year value | Yıl sonu değeri |
| `PIYASA_PRODUCTS_TITLE` | Products | Ürünleri |
| `PIYASA_SINCE_LAST` [I4] | Since your last look | Son bakışından beri |

Yayın (outlet) listesi değişmez: ekleme/silme `D_OUTLETS` + kontrast denetimine dokunur, yeniden
adlandırma yalnız CSV'dir (Ek A.5 kuralı); `piyasa` kaynağı mevcut yayınlardan gönderir.

### 3.5 Oyuncunun girişi ve değerleme dikişi

- `SeedRoundSystem.accept()` bugün yalnız miktar + hisse yazar [kod
  scripts/systems/seed_round_system.gd:169-184]. I1'de orada **`seed_post_money_m` kalıcılaşır**:
  milyon $ cinsinden `amount_m × 100.0 / equity_pct` (float hesaplanır; çözünürlük [ÇD], §8: önerilen 0,1M).
  Eski kayıtta Seed alınmış ve alan 0 ise yüklemede `run_seed_amount`/`run_seed_equity_pct`'ten aynı
  formülle doldurulur.
- `finance.valuation()` seam'i eklenir (`seams_finance.gd`); ACIK_KARARLAR maddesinin sahip onayıyla
  kapanması önerilir, `opening_terms` sorusu açık kalır [docs/ACIK_ISLER/ACIK_KARARLAR.md:1740-1748].
  Kişisel sekmesinin servet bölümü aynı değeri okur; `personal_tab.gd:203`'teki `run_valuation_m == 0`
  kontrolü `finance.valuation()`'a geçer [kod scripts/tabs/personal_tab.gd:200-205].
- `PER_NO_VALUATION` çelişkisi düzelir: bugünkü metin "Series A imzasında belirlenir" diyor [kod
  strings.csv:337], Seed artık değerleme yazıyor. Taslak (onay bekliyor):
  - `PER_NO_VALUATION` · EN "No valuation yet. Your seed round sets it." · TR "Değerleme henüz yok. Seed turunda belirlenir."
- **Oyuncu için sıra YOK (P3 kararı 2026-10-07):** "oyuncu o sıralamada değil"; sanal sıra hesaplanmaz, hiçbir
  yüzeyde yazılmaz. Oyuncu yalnız üçüncü KPI karosunda görünür (`PIYASA_KPI_YOUR_VALUATION`); ölçek üç karonun yan
  yana durmasından okunur, "önündeki şirket" satırı yoktur.
- **Yuvarlama [ÇD]:** formül kalır (P3 kararı); `seed_post_money_m` tam milyona yuvarlanırsa erken Seed
  ($130K / %16 = $0,81M) karoda "$1M" okunur. Öneri: alan 0,1M çözünürlükle tutulur, karo "$0,8M" basar
  (maket böyle çizildi).

**Oyuncu karosunun hâlleri:**

| Hâl | Görünen |
|---|---|
| Seed öncesi | etiket var, değer BOŞ (kural 9), açıklama `PER_NO_VALUATION` ("Değerleme henüz yok. Seed turunda belirlenir."); hedef iması yok (karar A) |
| Seed sonrası | değer = `seed_post_money_m`; açıklama `PIYASA_KPI_POST_SEED` ("Seed sonrası · {month}") |
| Series A sonrası | değer = `run_valuation_m` (imza anında adım); açıklama `PIYASA_KPI_SERIES_A` |
| Geçiş anı | **emekli**: sıra kavramı gerektirir; [I4] "son bakıştan beri" yalnız liste satırlarına uygulanır |

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
  `main.gd` tab-shot listesi. Sekmenin raydaki yeri P3 ile kararlaştırıldı: Finans'ın altı, Kişisel'in üstü (§3.8).
- Kayıt ayak izi: `market_catalog_version`, ShockLog, Ownership, `status` değişiklikleri,
  `seed_post_money_m`. Birkaç KB; fiyat geçmişi asla kaydedilmez. **I1 şema artırmaz:** yeni alanlar
  GameState değişkeni olarak anlamlı varsayılan taşır ve SaveCodec bulur; şema 15 kalır (artış I3'te,
  §2.4).

### 3.8 P3 maket durumu (Menajer kuralı: yeni ekran onaylı maketten kurulur)

| Maket | Ön koşul | Durum |
|---|---|---|
| Piyasa listesi + rapor kartı (koyu Menajer dili, TR+EN, renk körü, 1.0 ve 1.25) + raydaki sekme (Finans'ın altı, A2 `rail/rivals.svg`) + filtre çipleri + 4h % renk kuralı (düşüş kırmızı değil) | I1 | **onaylı 2026-10-07** (`screens/piyasa/`: liste, liste_en, renk_koru, 1536, filtre_sektor, ipo) |
| Rapor kartı ×2: sektörler-arası dev (Ürünleri'siz) ve sektör rakibi (kadran, yıl sonu, "Ürünleri" [I2]); yeni halka arz kartı | I1 | **onaylı 2026-10-07** (liste, detay_sektor, ipo) |
| Oyuncu karosu hâlleri (Seed öncesi boş / Seed sonrası / Series A sonrası) | I1 | **onaylı 2026-10-07** (seed_oncesi, liste, series_a) |
| Ürün maketlerine ek (`urun/`): telgraf satırı, iki Zayıf hover çeşidi, lider dalından Güçlü, "N rakipte var" çipi | I2 | **yok** |
| Toplantı maketlerine ek (`toplanti/`): rakip soru satırı, beş cevap (kilitli güç gerekçesi dahil), RAKİP kayıp çipi | I2 | **yok** |
| Tip ekranı + Ar-Ge: "2015+" kilit etiketi, yıl kilitli AI tipleri | I3 | **yok** |
| Kişiler sekmesi | I4 | yok |

Maketler `docs/mockups/menajer/screens/` düzenindedir (SPEC: `docs/mockups/menajer/system/SPEC.md:101-130`;
çalışma ağacında, commit'lenmemiş).

**P3 sahip kararları (2026-10-07):** (1) yön V1 "liste + rapor kartı" (referanslar: Startup Company rapor kartı,
Plutocracy finans panosu); (2) **fiyat listede kalır** (karar C'nin fiyat maddesi aynen); (3) filtre çipleri her karede; (4) Seed
formülü kalır, karo küçük sayıyı gösterir; (5) oyuncuya sıra yok; (6) liste satırında Δsıra, 4h %, kıvılcım ve
kurucu yok; (7) ayrı "Liste" sayfası yok, liste sol sütundur. Maket kurgusu: halka arz yılları, yıl sonu değerleri
ve Hakkında metinleri parodi dünya taslağıdır (TR/EN onay bekliyor); Facewall H20'de "Yeni", Werktag Ekim 2012.

I2 görsel kabulü için `main.gd`'ye **yeni** `--meeting-shot=rival` türü eklenir (bugünkü türler probe|locked|won|lost|handoff).

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
| **I1 · Piyasa salt-okunur** | Önce P3 maketleri → `MarketCompany`/`MarketPerson` kataloğu (~48 halka açık satır + sektör katmanı, karar H; P1 taramalı) + saf değer fonksiyonu ve karıştırıcı + ray sekmesi (TABS/LeftTabs/window_layer/SPECS + sıra smoke'u) + liste/rapor kartı/grafikler + `seed_post_money_m` + `finance.valuation` seam'i + `PER_NO_VALUATION` düzeltmesi + `piyasa` şerit kaynağı + kayıt girişleri + kadro yeniden adlandırması (P1 parodi setleri, Ek A) | M | İlk teslim edilebilir: saf ekleme, denge riski yok, sahibin çekirdek fantezisini anında verir. 2026 başlangıcına karşı çıkar; çapalar veridir. Görsel kabul: `--tab-shot=piyasa` TR+EN+cb, maketle karşılaştırma |
| **I2 · Hafif rakipler + kalite çıtası** | Model birleşmesi + takvim üreteci + kişilikler + itiraz vuruşu (olgu/soru/fiiller/kayıp nedeni) + çıta hesabı + kelime kuralları + lider tacı + VC yeniden bağı + `PROBE AREA`; `rival_bump` aynı commit'te emekli; rakip hamleleri → ShockLog → liste görünür tepki verir | M | I1 varlıklarının üstüne; pencerenin "yaşamaya" başladığı yer. Görsel kabul: itiraz vuruşlu toplantı `--meeting-shot=rival` (**yeni** tür), Ürün alan hover'ı, telgraf satırı |
| **I3 · Dönem göçü** | **Kendi işi.** Kayıtlı `start_date` (2012-01-05) + `days_per_tick`/`tick_epochs` + `time.year` seam'i + test yeniden sabitleri + `subgenre` varsayılanı "saas" + AI içeriği yıl etiketli + `ai_engine` yeniden çeşnisi + AI benimseme kartı + GDD ZAMAN MODELİ §5 yeniden yazımı + kayıt göçü + Piyasa kataloğu 2012'ye yeniden çapalı + sezdirme (düz GPU devi, kilitli "2015+" dal etiketi, AlexNet şerit selamı) | M-L | En geniş etki alanı (test, GDD, şema, ürün tipleri), sıfır yeni ekran; bütün inmek zorunda. Üçüncü sırada: I1/I2 görünür değeri önce gönderir, hiçbiri 2026'yı sert kodlamaz |
| **I4 · Kişiler + cila** | Kişiler servet listesi (servet = pay × değer; oyuncunun kurucusu Seed sonrası `equity% × post-money`) + son bakıştan beri deltaları + liste içi geçiş satırları (oyuncu değil; §3.5 Geçiş anı emekli) + çeyreklik kazanç şokları | S | I1 verisi üstünde katkısal UI. Görsel kabul: Kişiler maketi (P3) + `--tab-shot` |

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
2. [I1] Liste `companies.json` halka açık satır sayısıyla birebir (~48 + sektör devi + 1-2 yerleşik; 2012'de ~35'i listede, gerisi `listed_week`'te girer); hepsi fiyat + değer basar; satırda kıvılcım, Δsıra ve 4h % yok (P3 karar 6). Liste satırı `# · ad/sektör · değer · fiyat`, fiyat her satırda; filtre çipleri (Tümü/Teknoloji/Finans/Sektörüm) her karede, Sektörüm = oyuncunun `sector_id`'si, henüz girmemiş rakip `PIYASA_LISTS_IN` satırıyla; üç KPI karosu: Liste değeri = halka açık satırların toplamı, Lider = #1, Senin değerlemen = `finance.valuation`.
3. [I1] Fiyat = değer / `shares_outstanding`; hiçbir fiyat serisi kayda yazılmaz (kayıt boyu ölçülür).
4. [I1] Grafik aralıkları 13H/1Y/5Y/Tümü; yıl sonu tablosu her devde ilk haftadan dolu (koşu öncesi geçmiş çapalardan).
5. [I1] Aynı seed + aynı ShockLog → bayt-aynı eğri (iki koşu karşılaştırması).
6. [I1] Karıştırıcı dokusu: haftalık log-delta dağılımının standart sapması eşiğin üstünde [ÇD] ve ardışık iki haftada aynı delta yok (eski `_share_at` kırığının testi).
7. [I1] Seed kabulünde `seed_post_money_m` yazılır; eski kayıtta Seed alınmışsa yüklemede türetilir; oyuncu karosu değer kazanır, öncesinde değer hücresi boş + `PER_NO_VALUATION`; hiçbir yüzeyde oyuncu sırası yok.
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
| Sıra yeniden kesimi (manşet tetiği) | 4 hafta | [ÇD companies.json news.rank_weeks] |
| Özel tur temposu | 18-30 ayda bir, ×1,5-3 ya da aşağı tur | [ÇD companies.json private_rounds.*] |
| Kalıcı Zayıf tavanı (probe kapısı 1) | haftaların %40'ı | [ÇD scripts/debug/run_probe.gd gate] |
| `seed_post_money_m` çözünürlüğü | 0,1M (karo "$0,8M"; tam milyon "$1M" okutur) | [ÇD seed_round_system.gd accept() + game_state.gd] |

## 9. Ön koşullar

- **P1 · Parodi ad kataloğu** (karar G; Ek A.1 parodi yasası). Akış: **üret → tuvalde sahip seçer →
  seçilenler taranır → Ek A'ya hüküm + kanıtla işlenir**; taranmamış ad kataloğa yazılmaz. Üretimde her
  hedef için 2-4 aday + tek satır espri gerekçesi; tarama seçimden sonra koşar (arama bütçesi), demo'da
  görünür adlarda ad başına ≥ 2, dolguda 1 sorgu. Kapsam:

  | Küme | Adet | Parodi hedefi |
  |---|---|---|
  | Adlı dev arketipleri (+ liste dışı özel AI laboratuvarı) + kurucu/CEO'ları | 14 (13 listede) + ~22 | hedefler `real_timeline.md` §1'deki gerçek devler, arketip eşlemesi §6 (cihaz devi, GPU üreticisi…); petrol devi karar H ile çıktı |
  | Teknoloji dolgusu + 5 finans + kurucu/CEO'ları | 30 + 5 + ~21 | karar H: çip ve ağ, donanım, internet 1.0, Asya devleri, dönem halka arzları, kurumsal yazılım, teknoloji komşuları; finans yalnız IPO perdesinin bankaları; Türk devi yok; kişi yalnız efsane kurucu/CEO'da |
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
  markayla çakışıyor. Eşik: **aynı sektörde (yazılım, teknoloji, finans, medya) yaşayan ve iz bırakmış ad =
  çakışma; ilgisiz sektör, kapanmış şirket, yalnız soyadı/yer adı kullanımı ya da izsiz küçük tescil = temiz**; kanıt
  notu hangisi olduğunu tek cümleyle söyler, eşiği geçemeyen aynı-sektör küçük adlar "belirsiz (sahip kararı)"dır.

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

### A.2 erp parodi seti (P1 2026-10-07; rol sütunu v6 eşlemesi, §4.1)

Slot 0 Piyasa listesine terfi eden sektör devidir (tek varlık, iki yüzey; §3.1 "Sektör devi"; A.8'de satırı yoktur).
Slot 1 hedefi NetSuite'tir: 2012'de bağımsız halka açık, Oracle onu 2016'da alır (büyük listedeki Oracle parodisi
Vatic Systems ayrı kalır; §9 P1 tek-parodi kuralı). Pythia'nın kehanet teması Vatic Systems'la komşudur (A.9 sahip notu).

| Slot | Rol | Hedef (gerçek) | Parodi ad | Kişi | Hüküm | Kanıt ve not |
|---|---|---|---|---|---|---|
| 0 | dev | SAP | Datenwald | Hasso Plattner: Hanno Blattner [temiz-parodi] | temiz-parodi | http://datenwald.com/ · Görünür. Almanca 'veri ormanı' deyimi; aynı adla Leipzig'de küçük, bölgesel bir Jedox BI danışmanlığı (datenwald.com) canlı. Yazılım/veri sektöründe olduğu için not düşülür, ama tanınır bir marka değil, ERP değil; SAP ile yazım çakışması yok. Alternatif istenirse 'Datenhain' / 'Datenforst' düşünülebilir. |
| 1 | lig lideri | NetSuite (2012'de bağımsız halka açık; 2016'da Oracle alır) | Pythia |  | temiz-parodi | https://en.wikipedia.org/wiki/Pythia_(disambiguation) · Görünür. Delphi kâhini → Oracle göndermesi okunuyor. Ad çok kullanılıyor ama tek bir tanınır şirket/ürüne ait değil: küçük firmalar (Pythia Technologies/Ohio sensör, Pythia Labs/biyoteknoloji, kapanmış Tel Aviv veri ambarı), EleutherAI'nin açık kaynak 'Pythia' LLM süiti, CERN PYTHIA fizik simülatörü. Not: Pythian Group (Oracle DB servisleri) ad olarak yakın ama farklı yazım; ERP alanında çakışan marka yok. |
| 2 | yerleşik | Workday | Werktag |  | belirsiz (sahip kararı) | https://werktag.app/ · werktag.app yaşıyor. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Doğrulama: werktag.app doğrudan okundu — Deep5 GmbH'nin esnaf/zanaat (Handwerk) için zaman takibi + bordro dosyası SaaS'ı; müşteri sayısı/ekip açıklanmamış, özel fiyat, demo 94 kişilik işletme → Almanya'da butik, tanınırlığı olmayan niş ürün. Werktag.ch (Zürih IoT) sertifika hatasıyla açılamadı, zaten ilgisiz sektör. 'Werktag' ayrıca sıradan bir Almanca kelime (iş günü), tek bir markanın sahipliği yok. Ek A.1'e göre küçük/tanınmaz kullanım çakışma SAYILMAZ; Workday→Werktag çevirisi parodi olarak net. Hüküm belirsiz→temiz-parodi'ye çevrildi; arama bütçesi bittiği için (oturum limiti) web araması yapılamadı, kanıt doğrudan site okumasına dayanıyor. |
| 3 | fonlu giren | Odoo | Ardenna |  | temiz-parodi | https://ondas.com/ (site 'Rail Inspection' AI alanını listeliyor ama Ardenna adını hiç anmıyor); ardenna.com ve ardenna.com/about-us bugün ECONNREFUSED ile erişilemiyor · Doğrulama: ilk taramanın kanıt URL'si (ardenna.com/about-us) artık yanıt vermiyor (3 denemede bağlantı reddi); Ondas Holdings'in ana sitesi ve rail sayfaları Ardenna/Rail-Inspector adını geçirmiyor — marka 2022 satın alımından sonra Ondas çatısına soğurulmuş görünüyor, bağımsız yaşayan bir marka değil. Kaldı ki yaşıyor olsa bile demiryolu görüntü işleme nişinde, yazılım genel pazarında tanınır değil → Ek A.1'e göre çakışma SAYILMAZ. Hüküm çakışma→temiz-parodi'ye çevrildi. Ayrı mesele (çakışma değil, parodi kalitesi): ad Odoo'yu çağrıştırmıyor; ilk taramanın 'Uduu' benzeri sesli türev önerisi hâlâ geçerli ama yeniden adlandırma zorunlu değil. Arama bütçesi bittiği için web araması yapılamadı; kanıt doğrudan site okumalarına dayanıyor. |
| 4 | gizli özel | — | Tacita |  | temiz-parodi | https://en.wikipedia.org/wiki/Tacita_(disambiguation) · Hedef yok; ad Latince 'sessiz' (Dea Tacita). Küçük kullanımlar var: tacita.io (GDPR danışmanlığı), gettacita.com (gizli AI sohbet, mikro), tacita.com.au (fon diligence aracı), Tacita Motorcycles (İtalyan elektrikli motosiklet). Hiçbiri tanınır ERP/yazılım markası değil; çakışma sayılmaz. |
| 5 | kopyacı | Rocket Internet (klon kültürü) | Raketenhaus |  | temiz-parodi | https://www.kapitalmarktexperten.de/europas-ruestungssektor-setzt-auf-marschflugkoerper-laser-und-satelliten/ · Bu adda şirket yok. Almanca basında MBDA için gayriresmi lakap, SpongeBob'da bir ev, Hombroich'ta eski füze üssü, Wildstar ön sipariş evi. Rocket Internet'e güvenli mesafede. |
| 6 | niş (ev alanı: entegrasyonlar) | Zapier / MuleSoft (entegrasyon nişi) | Sumpter |  | temiz-parodi | https://en.wikipedia.org/wiki/Sumpter · Eski İngilizce 'yük hayvanı'; soyadı (Tika Sumpter, oyuncu) ve yer adı (Sumpter, Oregon). Yalnız küçük yerel işletmeler (Sumpter Solutions inşaat, Sumpter Technology alarm). Yazılım/entegrasyon markası yok. |
| 7 | yedek | Sage / Zoho | Thymeworks |  | temiz-parodi | https://www.thyme.co.uk/ · Birebir sonuç yok. 'Thyme' köklü küçük yazılımcılar var (Thyme Software Avustralya golf kulübü yazılımı, Thyme YC finansal danışman OS, Thyme Care sağlık) ama 'Thymeworks' hiçbiriyle karışmaz. Sage/Zoho'ya mesafe yeterli. |

Yedek uydurma set (v5'ten, tarandı, temiz; yalnız parodi seti düşerse): 0 Bezistan · 1 Merivel · 2 Kalemiye · 3 Halvero
· 4 Veznedar · 5 Stokdar · 6 Dirhem · 7 Nolvik; yerli seçenek 1 Senedat, 3 Tacirhane, 7 Kesedar; uluslararası Varelo,
Ulvano. Bugünkü adlardan Defterdar, Muhasip, Ledgero, Sayman, Tezgâh **çakışma**; Kasa & Stok, Envanter, Faturacı A.6
gereği kullanılmaz.

### A.3 video_clip parodi seti (P1 2026-10-07; rol sütunu v6 eşlemesi, §4.1)

Slot 2 satırı büyük listedeki Apple parodisinin ürünüdür (tek varlık, iki yüzey); sahip kararı A.9'da.

| Slot | Rol | Hedef (gerçek) | Parodi ad | Kişi | Hüküm | Kanıt ve not |
|---|---|---|---|---|---|---|
| 0 | dev | ByteDance (CapCut) | Bitwaltz | Zhang Yiming: Zheng Yiran [temiz-parodi] | temiz-parodi | https://www.youtube.com/@bitwaltz · Şirket/ürün olarak sonuç yok; yalnız bir YouTuber/Twitch takma adı. Yakın adlar Bitwala (kripto banka) ve Bitvavo farklı yazım, farklı sektör. ByteDance çağrışımı (Byte→Bit, Dance→Waltz) okunur. |
| 1 | lig lideri | KineMaster | — (tuvalde yeni seçim bekler) |  | çakışma | B2: tarama "belirsiz" demişti, aynı pazarda yaşayan ürün kanıtıyla §9 incelemesinde çakışma sayıldı · sonuç yok — https://kinomeister.de/ueber-uns/ ve https://www.kinomeister.de/ bağlantı reddetti (ECONNREFUSED), Facebook sayfası okunamadı; arama bütçesi tükendi · İlk taramanın 'yaşayan Alman sinema portalı' kanıtı bu turda doğrulanamadı (site cevap vermiyor; kapanmış olabilir ya da geçici kesinti). Hükümden bağımsız olarak ad hedef KineMaster'a fonetik olarak çok yakın (Kino-meister / Kine-Master), 'önemsiz harf farkı' sınırında; portal yaşıyorsa çakışma, yaşamıyorsa bile güvenli mesafe şüpheli. Yeniden adlandırma öneririm; bütçe yenilenince 1 arama ile kapatılabilir. |
| 2 | yerleşik | Apple (iMovie) | Malus (büyük liste) · ürün: — (sahip kararı) |  | belirsiz (sahip kararı) | Pomelo çakışma alınca "Pomelo Films" ürün adı dayanaksız kaldı; aday Clipwright ya da yeni ad. Ayrıca slot 2 "yerleşik, liste kuyruğu" tanımı Apple ile çelişir (A.9 sahip notu) |
| 3 | fonlu giren | Filmora (Wondershare) | Wunderreel |  | temiz-parodi | https://x.com/wundereel?lang=en · Birebir 'Wunderreel' şirketi yok. Yakınlar: 'Wundereel' (düğün GoPro kurgu servisi, X hesabı 2015, görünürde atıl) ve 'Wonderreel' (NY, 2010, çocuk medyası, küçük). Wondershare/Filmora mesafesi yeterli. |
| 4 | gizli özel | InShot | Inset |  | belirsiz (sahip kararı) | https://apps.apple.com/us/app/inset-preview-any-screen-area/id6759235673 · App Store'da aynı adlı uygulama. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Jenerik sözcük; küçük bağımsız kullanımlar var: Inset (Mac ekran-önizleme aracı), INSET (coğrafya oyunu), inset-rs (Rust UI çerçevesi), ArcGIS 'Insets' şablonu. Hiçbiri tanınır büyük marka değil. InShot ile yazım farkı yeterli (In-Set / In-Shot). |
| 5 | kopyacı | Klon kültürü (filigranlı editör çöplüğü) | Watermarkt |  | temiz-parodi | https://watermarkt.hu/ · Birebir ad yalnız Macar mutfak/evye e-ticaret sitesi (Watermarkt Business Kft., 2011) — ilgisiz sektör, çakışma sayılmaz. 'Watermark' jenerik sözcük; Watermark Terminal Solutions vb. farklı yazım, farklı alan. |
| 6 | niş (ev alanı: onboarding, telefonda kurgu) | Splice | Joinery |  | belirsiz (sahip kararı) | https://getjoineryapp.com/ ; https://joinery.vip/ · getjoineryapp.com yaşıyor. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: 'Joinery' jenerik marangozluk terimi. Aynı adla küçük ürünler var: Joinery (mobilya atölyeleri için CRM, $29/ay), JOINERY (doğrulamalı flört uygulaması), Joinerysoft (İngiltere ahşap doğrama yazılımı). Hiçbiri video/klip sektöründe ve tanınır ölçekte değil; Splice'a yeterli mesafede. Not: flört uygulaması joinery.vip büyürse yeniden bakılmalı. |
| 7 | yedek | — | Cutaway |  | temiz-parodi | https://cutaway-one.vercel.app/ ; https://www.lightreading.com/eurobites-fastweb-boosts-its-enterprise-appeal-with-cutaway-acquisition/d/d-id/761440 · Doğrulama araması koşulamadı (bütçe tükenmiş); ilk taramanın kendi kanıtı üzerinden hüküm ÇEVRİLDİ. Ek A.1'e göre küçük, ilgisiz sektördeki ya da satın alınıp kapanmış kullanımlar çakışma değildir: Cutaway S.r.l. ilgisiz sektör (BT danışmanlığı) ve Fastweb'e satılmış; Cutaway Tech/Security ilgisiz; aynı pazardaki tek örnek tanınırlığı olmayan bir Vercel hobi projesi. 'Cutaway' jenerik film terimi, tescilli tanınır marka değil. Not: hedef '—' olduğundan parodi değil dolgu adı gibi davranıyor; isteğe bağlı 'Kutaway' yedeği tutulabilir. |

Yedek uydurma set (v5'ten, tarandı, temiz): 0 Mizansen · 1 Pivotreel · 2 Tefrika · 3 Halftake · 4 Sahnecik · 5 Shortlark
· 6 Karecik · 7 Cutfinch; yerli seçenek 1 Seyirlik, 3 Sinemacık, 5 Tadımlık, 7 Peşrev; yedekler Shotfern, Moxlet,
Lumfold, Takefold. Bugünkü adlardan Kesit, Klipsa, Makas, ShortForge, Reelo **çakışma**; Altyazıcı, Montajcı **çağrışım**.

### A.4 note_tool parodi seti (P1 2026-10-07)

Slot 0 satırı büyük listedeki Microsoft parodisinin ürünüdür (tek varlık, iki yüzey; listede ikinci bir Microsoft yoktur).

| Slot | Rol | Hedef (gerçek) | Parodi ad | Kişi | Hüküm | Kanıt ve not |
|---|---|---|---|---|---|---|
| 0 | dev | Microsoft (OneNote) | Fenstra (büyük liste) · ürün: Unonote |  | temiz-parodi | https://apps.apple.com/us/app/unotes/id6477337434 · Birebir sonuç yok. Yakın adlar: uNotes (öğrenci geçmiş sınav kağıtları platformu, küçük), Unote.ai (AI sesli günlük, mikro), Unoteam Software (Hindistan CAD lisanslama). OneNote'a fonetik olarak çok yakın (Uno=One) ama yazım farklı; sınırda temiz, hedef bellidir. |
| 1 | lig lideri | Evernote | Elephanta | Phil Libin: Pavel Lubin [temiz-parodi] | temiz-parodi | https://www.crunchbase.com/organization/elephanta-ai · Ad öncelikle Mumbai'deki UNESCO Elephanta Mağaraları/adası. Elephanta AI (Hyderabad, kurumsal AI) Tracxn'e göre artık aktif değil → kapanmış kullanım, çakışma sayılmaz. Evernote fil logosuna gönderme güvenli. |
| 2 | yerleşik | Notion | Surmise | Ivan Zhao: Ian Zhou [temiz-parodi] | belirsiz (sahip kararı) | https://surmise.io/ · tarama notu aynı sektörde yaşayan küçük bir ad anıyor (surmise.io). Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: İngilizce sözcük. surmise.io diye küçük, fon bilgisi bulunamayan bir 'karar/tahmin altyapısı' girişimi var (not-alma değil, tanınır değil); Surmise Solutions Ltd (UK IT danışmanlık) 2015'te kapanmış; Wild Surmise Music ses eklentisi. Notion'a mesafe yeterli; surmise.io büyürse yeniden bakılmalı. |
| 3 | fonlu giren | Roam Research | Meander |  | belirsiz (sahip kararı) | https://meander.software/ ; https://uk.linkedin.com/company/meander-hq · tarama notu aynı sektörde yaşayan küçük bir ad anıyor. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Birkaç küçük canlı kullanım var: Meander Software (Hindistan, dev shop, 2014), meander.so (Londra, kariyer yazılımı, 2022), mëander (sesli tur uygulaması). Hiçbiri tanınır marka değil, not-alanında değil. Roam ile ilişkisi okunur (meander=kıvrılmak/roam). |
| 4 | gizli özel | Bear | Ursa |  | belirsiz (sahip kararı) | https://ursa-notes-lite.soft112.com/ursa-notes-lite-alternatives.html ; https://ursainc.com/ · "Ursa Notes Lite" not uygulaması, aynı pazar. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: 'Ursa Notes Lite' (Ursaware) diye bir not uygulaması vardı ama mağazadan kaldırılmış (2026-05). Diğer Ursa'lar ilgisiz/küçük: URSA Software (kanaviçe tasarımı), URSA Inc (siber/UAS), Ursa Health. Kapanmış/ilgisiz → çakışma değil. |
| 5 | kopyacı | Notion klon kültürü | Dittofy |  | belirsiz (sahip kararı) | https://www.crunchbase.com/organization/dittofi ; https://tracxn.com/d/companies/dittofi/__-zECKTO4nJEeR9gCHAWkhV78FfdcePCTVCJ5l_mGcEg · tarama notu yakın yazımlı yaşayan bir ad anıyor (Dittofi). Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Hüküm ÇEVRİLDİ. 'Dittofi' yaşıyor (Bristol, 2020, hibrit no-code; CEO James Virgo) ama Tracxn'e göre 6 çalışan, 2 melek yatırımcı: tanınır marka değil, küçük niş firma. Ek A.1'e göre küçük kullanım çakışma sayılmaz; not olarak kalır. @dittofy X hesabı bireysel, marka değil. Hedef (Notion klon kültürü) hâlâ okunuyor. |
| 6 | niş (ev alanı: gizlilik) | Obsidian / Standard Notes | — (tuvalde yeni seçim bekler) |  | çakışma | B2: tarama "belirsiz" demişti, aynı pazarda yaşayan ürün kanıtıyla §9 incelemesinde çakışma sayıldı · sonuç yok (oturum arama bütçesi tükendi; ilk taramanın kanıtı: https://apps.apple.com/us/app/basalt-ai-notes/id6754186830 ; https://github.com/erikjuhani/basalt) · Yeniden arama YAPILAMADI (bütçe sınırı). İlk taramanın kanıtları küçük/bağımsız ürünler (indie iOS not uygulaması, hobi TUI, erken aşama SF startup'ları): hiçbiri 'tanınır marka' eşiğini açıkça geçmiyor, ancak aynı not-aracı pazarında birebir ad olduğu için temiz-parodiye de indiremiyorum. Bütçe yenilenince 'Basalt notes' + 'getbasalt' ile tek arama yeter. |
| 7 | yedek | Simplenote | Monoline |  | belirsiz (kanıtsız) | sonuç yok (arama bütçesi tükenmiş) · Model bilgisine dayalı hüküm. 'Monoline' yaygın bir sigortacılık terimi (tek branş sigortacı) ve tipografi/çizim terimi (tek çizgi fontlar); bu adla yaşayan tanınır bir not/yazılım/teknoloji markası hatırlanmıyor. Küçük tasarım stüdyosu ya da font adı kullanımları ilgisiz-sektör sınıfında, çakışma sayılmaz. Simplenote çağrışımı zayıf ('tek satır' = sade not) ama kabul edilebilir. Görünür ad olduğundan arama açılınca 2 sorgu ile kapatılmalı; ilk 'belirsiz' temiz-parodiye çevrildi. |

Yedek uydurma adaylar (v5, doğrulanmadı, temiz sayılmaz): 0 Mecmua · 1 Ideafold · 2 Satır Arası · 3 Derkenar · 4 Margina
· 5 Glyphnote · 6 Tezkire · 7 Corkline. Bugünkü adlardan Zihin Haritası, Notably, Bellek, Fihrist, Karalama, Mürekkep
**çakışma**; Kayıt ve Kâğıtsız A.6 gereği kullanılmaz.

### A.5 Yayın kuralı

Yayın **eklemek ya da silmek** `D_OUTLETS`'e ve `--theme-contrast-audit`'e dokunur; **yeniden
adlandırmak** yalnız CSV'dir. Yayın adları ve Yalçın Teknoloji Holding I1'de değişmez (v4 karar 24).

### A.6 Ad kuralları (yeni adlar için; karar G ile güncellendi)

Parodi bilinçlidir (A.1), rastgele çağrışım ya da kazara çakışma değil; tire ve "&" yok; en çok iki
kelime; TR ve EN'de okunabilir; özellik ya da kategori adı gibi okunan çıplak sözlük kelimesi yok
("Envanter", "Zihin Haritası", "Kâğıtsız"); aynı pazarda aynı kökü taşıyan iki ad yok; özel ad çevrilmez.
Devler, kişiler ve fonlar (karar G düzeltmesi 2026-10-07): yalnız ASCII; Türkçe karakter, Türkçe kelime,
Türkçe isim ve Türkçeye çeviri esprisi yok; ad önce gerçek bir şirket ya da kişi adı gibi okunur (haber
başlığı testi), espri ikinci bakışta. Her yeni ad bu eke kanıtıyla eklenmeden kataloğa giremez.

### A.7 Fon adları (P1 2026-10-07)

Yalnız özel tur şerit satırının `{fund}` yer tutucusu için (`data/market/companies.json`). Kural: A.6; tanınmış girişim
sermayesi fonlarının parodileri (FORBIDDEN_TERMS kuralıyla: "sequoia", "a16z", "andreessen", "y combinator" alt dize
olarak bile geçemez); oyuncunun dört VC'sinin adı ve kökü (Anchor, Nexus, Bosphorus, Meridian) kullanılmaz; TR ve EN'de
aynı özel ad.

| Hedef (gerçek) | Parodi fon adı | Hüküm | Kanıt ve not |
|---|---|---|---|
| Sequoia Capital | Redgrove Capital | belirsiz (sahip kararı) | https://radientanalytics.com/firm/adv/redgrove-capital-llc-166142 · SEC kayıtlı yatırım danışmanı, fon parodisiyle aynı sektör. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Redgrove Capital LLC (Pinole, CA, 2012) tek kişilik, ~7M$ AUM'lu küçük RIA — tanınır değil, çakışma sayılmaz; yine de finans alanında aynı ad var, dolgu adı olarak kabul edilebilir, görünür listeye çıkarsa yeniden değerlendir. Redwood Grove Capital farklı ad. Sequoia çağrışımı güvenli. |
| Andreessen Horowitz (a16z) | Ammersen Berkowitz | temiz-parodi | sonuç yok (yalnız soyadı Berkowitz taşıyan ilgisiz kişiler: https://en.wikipedia.org/wiki/Berkowitz) · a16z çağrışımı korunuyor, yazım güvenli mesafede; ad+soyad birebir eşleşen tanınmış kişi ya da fon yok. |
| Y Combinator | Batchworks | belirsiz (sahip kararı) | https://www.crunchbase.com/organization/batch-works · Crunchbase/PrivCo fon kaydı. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Batch.Works adlı küçük Londra 3B baskı/üretim şirketi var (ilgisiz sektör, ~1 M$ fon); YC ile çakışmıyor. Not: Piyasa'da fon olarak kalacaksa sorun yok. |
| Accel | Celerity Ventures | belirsiz (sahip kararı) | https://www.privco.com/company/celerity-ventures · Crunchbase/PrivCo fon kaydı. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Aynı adlı küçük bir gayrimenkul şirketi (Alexandria VA, 2008) var; ayrıca 'Celerity Partners' adlı az bilinen LA VC var (farklı sonek). Accel çağrışımı zayıf ama güvenli. |
| Benchmark | Yardstick Capital | temiz-parodi | sonuç yok (yalnız Yard Stick PBC toprak-karbon startup'ı ve Yardstick yazılım şirketleri: https://pitchbook.com/profiles/company/462158-83) · 'Yardstick Capital' adlı fon bulunamadı; Benchmark eşanlamlısı temiz. |
| Kleiner Perkins | Feiner Jenkins | temiz-parodi | sonuç yok (https://en.wikipedia.org/wiki/Feiner yalnız soyadı) · Kleiner Perkins çağrışımı net, yazım güvenli; birebir eşleşen kişi ya da firma yok. |
| Tiger Global | Amur Global | temiz-parodi | https://finance.yahoo.com/news/amur-capital-surpasses-1-billion-170000051.html · 'Amur Global' yok; 'Amur Capital' adlı Kanadalı ipotek fonu (1 Mlr $) var, farklı sonek ve farklı alan (hedge/VC değil). Tiger Global çağrışımı (Amur kaplanı) korunuyor. |
| SoftBank Vision Fund | Velvetbank | belirsiz | sonuç yok — oturumun WebSearch bütçesi (200) tükenmiş, doğrulama araması yapılamadı · Arama koşulamadı; kanıt URL'si verilemiyor. Bilgim dahilinde 'Velvetbank' adlı tanınır bir banka/fon/fintech yok; 'Velvet' tek başına birçok kart/fintech ürününde geçiyor ama bu Ek A.1'e göre çakışma sayılmaz. Eğilim temiz-parodi; bütçe yenilenince 1 arama ile kapatılmalı. |
| Index Ventures | Folio Ventures | belirsiz (sahip kararı) | https://www.crunchbase.com/organization/folio-ventures · Crunchbase/PrivCo fon kaydı. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Aynı adlı Delaware şirketi 2008'de kurulmuş ve KAPANMIŞ; 'Folius Ventures' adlı HK kripto VC yakın ama farklı yazım. Index Ventures çağrışımı temiz. |
| Founders Fund | Zeroth Capital | belirsiz | sonuç yok — oturumun WebSearch bütçesi tükenmiş, doğrulama araması yapılamadı · Arama koşulamadı. Bilgim dahilinde yaşayan yakın ad: Zeroth.ai (Hong Kong merkezli AI hızlandırıcı/erken aşama yatırımcı). 'Zeroth Capital' birebiri bilgimde yok, ancak fon alanında aynı kök adlı yaşayan bir yatırımcı olduğundan karıştırma riski var; görünmez (dolgu) ad olsa da bütçe yenilenince doğrulanmalı. Alternatif hazır tutulabilir (ör. 'Nullth Capital', 'Zeroeth Partners'). |

### A.8 Büyük liste kataloğu (P1 2026-10-07; karar H kurgusu)

Gerçek hedef adları, gerçek kurucu/CEO adları ve bu tablonun kategori etiketleri yalnız bu belgede durur;
`companies.json` ve CSV yalnız parodi adı taşır. I1, A.8'in Hedef ve Kurucu/CEO sütunlarından türetilen bir yasak-liste
lint'i ekler (FORBIDDEN_TERMS devler için yetersiz: apple, oracle, intel… listede yok). "Listede (yıl)": 2012'de halka
açık olmayan satır gerçek halka arz haftasının analoğunda listeye girer (`listed_week` hafta çözünürlüklüdür; demo
diliminin ikisi hafta ile yazıldı, sonraki yıllar I3'te haftaya çevrilir; §3.1). Kişi sütunu MarketPerson kayıtlarıdır.
49 satır; liste dışı özel AI laboratuvarı dahil.

| Kategori | Hedef (gerçek, yalnız bu belgede) | Parodi ad | Kurucu/CEO parodisi | Listede (yıl) | Hüküm | Kanıt ve not |
|---|---|---|---|---|---|---|
| Adlı devler | Apple | Malus | Jobs: Stephan Laborde [temiz-parodi]; Cook: Timo Koch [temiz-parodi] | 2012'den | belirsiz (sahip kararı) | https://getmalus.com/en/download (Malus VPN/hızlandırıcı, yurtdışı Çinliler için, ~500k kullanıcı) · https://gigazine.net/gsc_news/en/20260313-malus-open-source/ (malus.sh, Mart 2026 hicivli AI 'clean-room' servisi) · https://find-and-update.company-information.service.gov.uk/company/06964493 (Malus Limited, 2025'te kapandı) · Malus VPN (~500k kullanıcı, yazılım) yaşıyor. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Belirsiz → temiz-parodi. Latince elma cinsi (Malus) parodiyi taşıyor. Aynı adlı yaşayanlar küçük/niş: Çin pazarına dönük VPN, Hindistan'da küçük IT firmaları, 2026'da basın gören ama tek seferlik hicivli malus.sh projesi. Tanınır büyük teknoloji/finans markası yok; malus.sh yazılım alanında olduğu için not olarak izlensin. |
| Adlı devler | Microsoft | Fenstra | Gates: Willard Yates [temiz-parodi]; Ballmer: Stefan Kugler [temiz-parodi]; Nadella: Raja Candella [temiz-parodi] | 2012'den | temiz-parodi | https://www.fenstra.com/ → https://fenstro.com/en (Fenstro®, Altaterra Kft., Macaristan merkezli çatı penceresi üreticisi; marka adı Fenstra değil Fenstro) · Belirsiz → temiz-parodi. Tek bulunan yakın ad 'Fenstro' inşaat/pencere sektöründe küçük-orta Avrupa üreticisi: ilgisiz sektör + farklı yazım, A.1'e göre çakışma değil. Teknoloji/finansta Fenstra markası bulunamadı. WebSearch bütçesi tükendi; doğrudan alan adı okumasıyla doğrulandı. |
| Adlı devler | Amazon | Orinoco | Bezos: Jeffrey Bezier [temiz-parodi] | 2012'den | temiz-parodi | https://en.wikipedia.org/wiki/Orinoco_(disambiguation) · Asıl anlam Güney Amerika nehri. Aynı adlı şirketler küçük/ilgisiz: Orinoco Systems LLC (küçük yazılım, Illinois), Orinoco Partners (küçük yatırım), Orinoco Coffee & Tea, Tokyo'daki Orinoco (PeaTiX, eski Amazon Japan ekibi, 2009). ORiNOCO Wi-Fi markası (Lucent/Proxim) kapanmış sayılır. Tanınır büyük marka çakışması yok; Amazon nehir çağrışımı hoş. |
| Adlı devler | Google | Gogol | Page: Harlan Sage [temiz-parodi]; Brin: Sergei Brunov [temiz-parodi]; Pichai: Sundeep Pillai [temiz-parodi] | 2012'den | temiz-parodi | https://en.wikipedia.org/wiki/Gogol_(disambiguation) · Baskın anlam yazar Nikolai Gogol; teknolojide yalnız küçük kullanımlar (Gogoľ Development s.r.o. Slovakya, Haskell 'gogol' SDK, Tayvan'daki Gogolook farklı ad). Yaşayan tanınır marka yok. |
| Adlı devler | Facebook | Facewall | Zuckerberg: Marcus Sugarhill [temiz-parodi] | 2012 · H20 (Mayıs) | temiz-parodi | https://github.com/HubSpot/facewall · İki yaşayan yazılım kullanımı var ama ikisi de küçük: HubSpot'un açık kaynak dahili 'Facewall' (Gravatar ızgarası, pazarlanan ürün değil) ve RANA UNITED'ın Japonya'daki FACEWALL çalışan rehberi. Tanınır marka değil; yine de ürün tescili gerekirse en zayıf halka bu. |
| Adlı devler | Nvidia | Graphyne | Huang: Jansen Leder [temiz-parodi] | 2012'den | temiz-parodi | https://en.wikipedia.org/wiki/Graphyne · Ad bir karbon allotropu (bilimsel terim), bu adla şirket yok. Yakın adlar: Graphine (Unity 2019'da aldı, kapandı), Graphyte (Gates destekli karbon tutma, farklı sektör), Graphcore (farklı yazım). Nvidia ile birebirlik yok. |
| Adlı devler | Tesla | Galvani Motors | Musk: Eldon Musgrave [temiz-parodi] | 2012'den | temiz-parodi | https://www.galvanimotors.com.br/ — Campinas (Brezilya) merkezli küçük yerel ikinci el araç bayisi (2011, Galvani Motors Ltda). · Aynı adlı küçük yerel bir otomobil galerisi var (otomotiv sektöründe ama tanınır marka değil); Tesla ile karışma riski yok. İstenirse 'Galvani Motorworks' gibi varyant düşünülebilir. |
| Adlı devler | Netflix | Seriatim | Hastings: Reeve Hastwick [temiz-parodi] | 2012'den | temiz-parodi | https://www.crunchbase.com/organization/seriatim — Seriatim Inc (NY, organizasyon/lojistik danışmanlığı, 1999); ayrıca küçük mobil uygulamalar (Seriatim Reader, parlamento prosedürü uygulaması) ve Seriatim s.a.s (HR analitik). · Latince 'sırayla' anlamında yaygın hukuk terimi; küçük, ilgisiz sektörlerde birkaç kullanım var, medya/streaming alanında tanınır marka yok. |
| Adlı devler | Salesforce | Venditor | Benioff: Matteo Benvolio [temiz-parodi] | 2012'den | temiz-parodi | https://en.wiktionary.org/wiki/venditor — Latince 'satıcı'; aynı adlı yazılım şirketi bulunamadı (yakın adlar Vendini, Vendita, Vend farklı). · Salesforce→'satıcı' çağrışımı temiz; sözlük sözcüğü, canlı marka yok. |
| Adlı devler | Oracle | Vatic Systems | Ellison: Lorenzo Galleoni [temiz-parodi] | 2012'den | temiz-parodi | https://www.vaticlabs.ai/ (ilk taramanın kanıtı; bu turda yeni arama yapılamadı: oturumun WebSearch bütçesi tükenmiş, 3 deneme reddedildi) · Doğrulayıcı yorumu: ilk taramanın gerekçesi kanıt eksikliği değil, hüküm tereddüdüydü. 'Vatic Systems' birebir mevcut değil; 'Vatic' köklü firmalar (Vatic Labs - küçük NYC prop-trading, Vatic - sahne bileti fiyatlama, Vatic Outsourcing - telekom danışmanlık) ya ilgisiz sektör ya da geniş tanınırlığı olmayan niş şirketler; A.1'e göre bunlar çakışma sayılmaz. 'Systems' eki ayrıştırıyor, Oracle hedefiyle harf benzerliği yok. UYARI: bu hüküm yalnız ilk tarama kanıtı üstüne verildi, bağımsız yeni arama yapılamadı; Erdem isterse bütçe tükenmişnca tek arama ('Vatic Systems') ile teyit edilmeli. Yedek ad: 'Auspex Systems'. |
| Adlı devler | Intel | Silicore | Grove: Andor Grover [temiz-parodi]; Moore: Graydon Heath [temiz-parodi] | 2012'den | belirsiz (sahip kararı) | https://en.silicore.com.cn/about.html (Shaoxing Silicore Technology, 2003, küçük fabless analog IC) · https://www.silicore.co/ (veri merkezi kredisi, küçük) · https://silicore.cloud/ · https://silicoreinnovations.com/ · Shaoxing Silicore çip şirketi, Intel parodisiyle aynı sektör. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: İlk hüküm ÇEVRİLDİ. Adı taşıyan 5-6 küçük şirket var (Çin'de analog IC tasarımcısı, Hindistan/Nepal'de VLSI ve yazılım butikleri, bir veri merkezi kredi firması) ama hiçbiri tanınır marka değil; Ek A.1'e göre küçük/ilgisiz kullanımlar çakışma sayılmaz. Tek dikkat noktası: Shaoxing Silicore aynı sektörde (yarı iletken) ve yaşıyor; parodi 'Intel' boyutunda bir dev olduğu için karıştırılma ihtimali düşük. Intel'den yazım mesafesi güvenli. İstenirse alternatif yazım (Silicor, Siliqore) risk sıfırlar. |
| Adlı devler | BlackBerry | Bramblewire | Lazaridis: Mikis Laskaris [temiz-parodi]; Balsillie: Jerome Balsam [temiz-parodi] | 2012'den | temiz-parodi | https://dotd.fandom.com/wiki/Glossary (yalnız bir oyun yeteneği 'Bramblewire Trap'; şirket/ürün yok) · Şirket ya da marka olarak kullanım bulunamadı. |
| Adlı devler | Zoom | Mutely | Yuan: Eric Krone [temiz-parodi] | 2019 | temiz-parodi | https://mutely.com/ → GoDaddy 'for sale' park sayfası (alan adı satılık, aktif marka yok) · Belirsiz → temiz-parodi. Ana alan adı boş/satılık; yaşayan tanınır bir Mutely ürünü yok. App store'da küçük bir uygulama olasılığı kontrol edilemedi (WebSearch bütçesi tükendi), olsa da küçük kullanım sayılır. |
| Adlı devler | OpenAI | Ajar Labs | Altman: Samuel Oldman [temiz-parodi] | liste dışı (özel) | temiz-parodi | https://www.bizprofile.net/ca/sacramento/ajar-labs-llc · Yalnız Mart 2026'da kurulmuş, bilinmeyen Sacramento LLC'si var (tanınır marka değil, not düşülür). Benzer adlı Ayar Labs (silikon fotonik) ve AJR Labs (ilaç) ayrı yazım/sektör; OpenAI'ye çağrışım yazımla kurulmuyor, yalnız 'Labs' ekiyle; hedefin adıyla birebirlik yok. |
| Banka/Finans | JPMorgan Chase | JL Morrow | Jamie Dimon: Jeremy Diamant [temiz-parodi] | 2012'den | temiz-parodi | https://finance.yahoo.com/quote/MORROW.ST/ · 'JL Morrow' diye bir şirket yok; dikkat: 'Morrow Bank' (eski Komplett Bank, Nasdaq Stockholm'de kote İskandinav dijital banka) yaşıyor. 'JL' öneki ayırıyor ama finans alanında soyadı örtüşmesi var, Erdem bilsin. Ayrıca William Morrow (yayınevi) ilgisiz sektör. |
| Banka/Finans | Goldman Sachs | Gallman Saxe |  | 2012'den | temiz-parodi | https://www.genealogy.com/forum/surnames/topics/gallman/238/ · Sonuçlar yalnız 18. yy Güney Carolina 'Saxe Gotha' yerleşimi ve Gallman soyadı soy kütüğü; yaşayan şirket/marka yok. Goldman Sachs'a çağrışım açık, yazım güvenli. |
| Banka/Finans | Visa | Visto |  | 2012'den | temiz-parodi | https://pitchbook.com/profiles/company/52984-27 · Doğrulama: 'Visto' adlı yaşayan kullanımlar var ama hepsi küçük/niş: eski Collective Media'nın adtech platformu (2017'de ad değiştirdi, sektörde ikinci sıra), visto.ai (Kanada göçmenlik yazılımı startup'ı), São Paulo'daki fonsuz Visto App, Visto Corp (mobil e-posta, Good/BlackBerry'ye katılıp kapandı). Hiçbiri Ek A.1'in 'tanınır marka' eşiğinde değil; finans/ödeme alanında Visto yok. Visa→Visto farkı birebir ya da önemsiz harf farkı sayılmaz (a→to, iki harf, ayrı sözcük okunuşu). Dolgu adı (visible=false) olduğundan ilk taramanın 'değiştirilmesi önerilir' notu zorunlu değil; istenirse 'Vesa' yedeği hazır. Not: oturumun arama bütçesi tükendiğu için ikinci arama (payments/fintech) yapılamadı; hüküm ilk taramanın 2 araması + bu 1 arama üzerinden verildi. |
| Banka/Finans | Citibank | Urbigroup |  | 2012'den | temiz-parodi | https://www.urbgroup.com/ · Birebir 'Urbigroup' yok. Yakın adlar: URB Group (Romanya rulman üreticisi, ilgisiz sektör), Urbi (Meksika konut geliştiricisi, ilgisiz). Citigroup'a çağrışım yapıyla kurulu, yazım güvenli; finans alanında çakışma yok. |
| Banka/Finans | Morgan Stanley | Margrave Stanfield |  | 2012'den | temiz-parodi | sonuç yok (yalnız 'Marlo Stanfield' – The Wire karakteri ve 'margrave' unvanı çıkıyor): https://en.wikipedia.org/wiki/Marlo_Stanfield · Ad olarak yaşayan hiçbir şirket/marka yok; Morgan Stanley'den yazım mesafesi güvenli. |
| Çip ve ağ | Cisco | Frisco Systems |  | 2012'den | temiz-parodi | http://friscosystems.com/ · Frisco, TX'te tek kişilik IT danışmanlık firması var (friscosystems.com); küçük ve tanınmaz, çakışma sayılmaz. Cisco'dan mesafe güvenli. |
| Çip ve ağ | Qualcomm | Dragonwell Semiconductor |  | 2012'den | temiz-parodi | https://en.wikipedia.org/wiki/Dragonwell → Longjing (çay/yer adı) yönlendirmesi; şirket yok · Belirsiz → temiz-parodi. 'Dragonwell' yalnız çay/yer adı olarak var; yarı iletken alanında bu adlı şirket izi yok. Dolgu adı, tek doğrudan okuma yeterli. |
| Çip ve ağ | AMD | Amber Microdevices | Lisa Su: Lena Hsu [temiz-parodi] | 2012'den | temiz-parodi | https://www.crunchbase.com/organization/amber-solutions-inc · 'Amber Semiconductor / AmberSemi' adlı küçük bir fabless çip startup'ı var (60M$ fon, 2016); ad farklı, çakışma sayılmaz ama aynı sektörde olduğu için not edildi. 'Amber Microdevices' birebir yok. |
| Donanım | HP | Hewitt Packer | Meg Whitman: Meg Whitlock [temiz-parodi] | 2012'den | temiz-parodi | https://www.indeed.com/cmp/Hewitt-Packer · Şirket olarak yok; ikinci el ilanlarında HP'nin yaygın yanlış yazımı olarak geçiyor (Indeed sayfası da boş kabuk). Çağrışım net, yazım güvenli. |
| Donanım | Dell | Dalton Technologies | Michael Dell: Mitchell Dalton [temiz-parodi] | 2012'den | temiz-parodi | https://www.dnb.com/business-directory/company-profiles.dalton_technologies_inc.d814e5f1067b80d6d0ab7a8789fd0e04.html · Birkaç küçük/kapanmış homonim var (Kansas City yazılım, Spokane – markası 2024'te terk, UK Ltd 2011'de feshedildi, Vancouver 1-50 kişi); hiçbiri tanınır değil, çakışma sayılmaz. |
| Donanım | Nokia | Nordlund Mobile | Stephen Elop: Stewart Eloff [temiz-parodi] | 2012'den | temiz-parodi | https://www.superyachttimes.com/companies/nordlund-boat-company-inc (ilgisiz sektör: yat yapımcısı) · 'Nordlund Mobile' diye şirket yok; Nordlund soyadı/yat tersanesi olarak var, çakışma sayılmaz. |
| Donanım | Xiaomi | Shaomu Technology | Lei Jun: Lei Chun [temiz-parodi] | 2018 | temiz-parodi | sonuç yok (yalnız akademisyen 'Shaomu Tan' ve oyun karakteri 'Xiaomu' çıktı) · Bu adda şirket bulunamadı; Xiaomi'den yazım farkı belirgin. |
| İnternet 1.0 | Yahoo | Huzzah | Marissa Mayer: Larissa Mayhew [temiz-parodi] | 2012'den | temiz-parodi | https://www.zoominfo.com/c/huzzah-media/359472009 (11-50 kişilik küçük KOBİ pazarlama ajansı) · Küçük kullanımlar var: Huzzah Media (KOBİ pazarlama), Huzzah! Studios (Londra web ajansı), açık kaynak 'Huzzah' AI editörü (2026, hobi projesi) ve Adafruit HUZZAH geliştirme kartı. Hiçbiri tanınır büyük marka değil; sözcük yaygın ünlem. Ek görünürlük istenirse 'Huzzah Media' notu dosyaya düşülsün. |
| İnternet 1.0 | eBay | Bidwell |  | 2012'den | belirsiz (sahip kararı) | https://bidwell.app/blog/bid-management-software (küçük İngiliz ihale-takip SaaS'ı, £15/ay) · tarama notu aynı sektörde yaşayan küçük bir ad anıyor. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Birebir ad küçük kullanımlarda var: bidwell.app (UK inşaat ihale SaaS'ı, küçük), Bidwell & Company (Portland merkezli küçük aracı kurum, 1984), Bidwell Consulting. Hiçbiri tanınır marka değil, Bidwell yaygın soyadı/yer adı; eBay'e mesafe güvenli. Görünür listeye alınırsa yeniden bakılmalı. |
| İnternet 1.0 | PayPal | Chequemate |  | 2015 | temiz-parodi | https://chequemate.com/ → GoDaddy 'for sale' park sayfası (alan adı satılık) · Belirsiz → temiz-parodi. Ana .com alan adı satılık; yaşayan tanınır fintek markası yok. Küçük yerel çek/fatura hizmetleri ya da masa oyunu adı olarak kullanımlar olabilir, çakışma sayılmaz. WebSearch bütçesi tükendi; tek doğrudan okuma. |
| İnternet 1.0 | Baidu | Baiyun | Robin Li: Robin Luo [temiz-parodi] | 2012'den | belirsiz (sahip kararı) | https://en.wikipedia.org/wiki/Baiyun_District,_Guangzhou (Guangzhou'nun ilçesi) · https://en.wikipedia.org/wiki/Guangzhou_Baiyun_International_Airport (havalimanı; işletmeci Guangzhou Baiyun International Airport Co. Ltd., havacılık) · Guangzhou Baiyun Havalimanı A.Ş. Şanghay'da kote (havacılık). Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Belirsiz → temiz-parodi. Ad yer adı (ilçe, dağ, havalimanı); şirket kullanımı yalnız havalimanı işletmecisi (havacılık, teknoloji/finans dışı) — A.1'e göre yer adı/ilgisiz sektör, çakışma değil. Dolgu adı. |
| Asya devleri | Alibaba | Sindbad Holdings | Jack Ma: Jake Mu [temiz-parodi] | 2014 | temiz-parodi | https://www.hktdc.com/event/hkfoodexpo/en/exhibitor/1S005NNMJ ; https://en.wikipedia.org/wiki/Sindbad_(company) · Birebir 'Sindbad Holdings' yok. Yakın kullanımlar ilgisiz sektörlerde: Sindbad Group Holdings (HK konserve gıda), Al Sindbad Group (BAE yalıtım), Sindbad S.A. (Polonya otobüs), Sinbad Holding Ltd (UK küçük danışmanlık). Teknoloji/finans alanında tanınır marka yok. Not: Alibaba çağrışımı Binbir Gece Masalları üzerinden dolaylı; oyuncu bağlantıyı 'Jake Mu' ile kurar. |
| Asya devleri | Tencent | Tenpenny Holdings | Pony Ma: Pony Mun [temiz-parodi] | 2012'den | temiz-parodi | https://tenpennyholdings.com/ (alan adı çözümlenmiyor: getaddrinfo ENOTFOUND) · Çevrildi: belirsiz → temiz-parodi. İlk taramanın tek dayanağı olan site bugün DNS'te bile yok; ölü/boş landing page tanınır yaşayan marka değildir. Diğer Tenpenny kullanımları ilgisiz küçük yerel işler (peyzaj, emlak, mobilya) → hüküm gereği çakışma sayılmaz. Tencent'e güvenli mesafede. İhtiyaten 'Tenpence Holdings' alternatifi not olarak kalsın, zorunlu değil. |
| Dönem halka arzları | LinkedIn | Cufflink | Reid Hoffman: Royce Hoffner [temiz-parodi] | 2012'den | temiz-parodi | https://www.cufflinkos.com/ · Çevrildi: çakışma → temiz-parodi. Cufflink, Mountain Vector Energy'nin enerji/fatura analitiği ürünü: ~100 kurum (okul bölgesi, çimento, hastane), niş B2B. Yazılım olsa da LinkedIn'in sektörüyle (profesyonel sosyal ağ) ilgisiz ve tanınır marka değil; Cufflink.io kapanmış, Cufflinks RNA-seq akademik araç. 'Küçük, ilgisiz sektör' muafiyeti uygulanır. Not: ad genel sözcük (kol düğmesi) olduğundan tescil riski düşük. |
| Dönem halka arzları | Twitter | Warbler | Jack Dorsey: Jacob Dorsett [temiz-parodi] | 2013 | belirsiz (sahip kararı) | https://www.cbinsights.com/company/warbler-labs · Warbler Labs yaşıyor. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Hüküm ÇEVRİLDİ. Tek yaşayan çakışma adayı 'Warbler Labs' (SF, 2020, a16z/Coinbase destekli DeFi geliştirici). Ama kamuya dönük markaları Goldfinch ve Heron; 'Warbler' tek başına tüketicinin tanıdığı bir ürün/marka değil, küçük bir geliştirici kabuğu. Hindistan/Teksas 'Warbler Software Technology' küçük IT hizmeti, ilgisiz. 'Warbler' sözcüğü kamuda kuş adı olarak okunuyor; Twitter kuşu parodisi olarak güvenli mesafede. Not: 'Warbler Labs' yaşıyor; ihtiyat istenirse 'Warblr' varyantı hâlâ masada. (Arama bütçesi tükendi; 2. ve 3. arama yapılamadı, hüküm ilk aramanın sonuçlarıyla verildi.) |
| Dönem halka arzları | Zynga | Zengara |  | 2012'den | temiz-parodi | https://zengara.store/ · Yalnız moda/ayakkabı markaları (Antonio Zengara ayakkabı, zengara.store minimalist giyim) ve bir müzik grubu; ilgisiz sektör, teknoloji/oyun alanında kullanım yok. |
| Dönem halka arzları | Groupon | Dealflock |  | 2012'den | temiz-parodi | https://dealflock.com/sample-page/ · dealflock.com yalnız boş bir WordPress 'Sample Page'; aktif şirket yok. Yakın ad Dealflo (Londra fintek, 2018'de OneSpan'e satıldı) farklı yazım ve bağımsız marka olarak yaşamıyor. |
| Dönem halka arzları | Snap | Blipframe | Evan Spiegel: Ethan Spiegler [temiz-parodi] | 2017 | belirsiz | Arama yapılamadı: WebSearch bütçesi tükenmiş; 2 sorgu reddedildi ("Blipframe" ve "Blipframe" company app). Kanıt URL'si yok. · Doğrulanmamış ön bilgi: tanınır bir marka hatırlanmıyor; küçük bir uygulama/stüdyo adı olabilir. Bütçe açılınca doğrulanmalı. |
| Dönem halka arzları | Spotify | Jukewave | Daniel Ek: Dag Ekman [temiz-parodi] | 2018 | temiz-parodi | Şirket/yazılım/startup araması: birebir eşleşme yok (yalnız Juke, Juke Solutions, Jukedeck, Zywave gibi farklı adlar) — https://www.crunchbase.com/organization/juke , https://en.wikipedia.org/wiki/Jukedeck . Çıplak arama: 2011'de XXYYXX adlı müzisyenin tarzını tanımlamak için kullanılmış bir tür etiketi — https://earmilk.com/2011/12/15/xxyyxx-fields/ · Yaşayan marka, şirket ya da ürün yok. Tek kullanım 2011 tarihli bir müzik-blog tür etiketi (chillwave türevi) — ticari değil, çakışma sayılmaz. Hedef Spotify ile de hiçbir harf/sözcük benzerliği yok. |
| Dönem halka arzları | Uber | Hailway | Travis Kalanick: Trevor Kalinich [temiz-parodi] | 2019 | temiz-parodi | https://occult-world.com/hailway/ (Navajo şifa töreni) + https://www.made-in-china.com/showroom/hbshiyi/product-detailSvlnUKaHsQYI/China-Hailway-Used-Fence-Mesh.html (Çinli tel örgü ürünü) · Teknoloji/finansta yaşayan marka yok; yalnız tören adı, İskoç soyadı ve ilgisiz tel-örgü ürünü. Uber çağrışımı (hail a ride) korunuyor. |
| Dönem halka arzları | Airbnb | Airnest | Brian Chesky: Byron Chesley [temiz-parodi] | 2020 | temiz-parodi | https://pitchbook.com/profiles/company/118436-86 (drone yazılımı Airnest, 2018'de Measure tarafından satın alındı) + https://www.linkedin.com/company/airnesthomes (Kanarya Adaları tatil evi yönetimi) · Not: 2014 kurulumlu drone yazılım startup'ı 2018'de satın alınıp markası emekli oldu (kapanmış sayılır); küçük AirNest tatil-evi/charter işletmeleri ilgisiz sektör. Airbnb çağrışımı net, yazım güvenli. Görünür listeye alınırsa ikinci arama önerilir. |
| Dönem halka arzları | Dropbox | Dropcrate | Drew Houston: Drake Hewston [temiz-parodi] | 2018 | temiz-parodi | https://www.zoominfo.com/c/dropcrate-inc/433352919 (Brooklyn, 5-9 kişilik takviye-gıda mağazası) + https://github.com/dawbro/DropCrate (hobi Java OS projesi) · Yalnız küçük/ilgisiz kullanımlar: Brooklyn takviye dükkânı, Teksas aile işletmesi (silah aksesuarı), Singapur oyuncak perakendesi (2025), tanınmayan GitHub projesi. Dropbox çağrışımı net. |
| Kurumsal yazılım | ServiceNow | Instanter Systems |  | 2012 · H26 (Haziran) | belirsiz (sahip kararı) | Birebir 'Instanter Systems' yok. Yakın adlar: 'Instanter' (Catonsville, Maryland'de küçük bir hukuki e-dosyalama yazılımı) — https://instanter.io/ ; çeşitli küçük 'Instant Systems' firmaları (İsveç depo otomasyonu, ABD biyoproses, Fremont yazılım kuluçkası) — https://www.instantsystems.se/ , https://instantsystems.com/about/ , https://instantsys.com/ · tarama notu aynı sektörde yaşayan küçük bir ad anıyor. Tarama hükmü temiz-parodi idi; A.1 eşiği (aynı sektörde yaşayan ad) sahip kararına çevirdi. Tarama notu: Yaşayan tanınır marka yok. 'Instanter' (hukuk e-dosyalama, niş/küçük) ve 'Instant Systems' (farklı sektörler, küçük) kayıt altına alınır; ikisi de ServiceNow'un kurumsal BT-hizmet yönetimi alanında değil ve 'Instanter Systems' tam adı hiçbirine ait değil. Hedefle harf benzerliği yok. |
| Kurumsal yazılım | Palantir | Farsight Data | Alex Karp: Alec Karpell [temiz-parodi] | 2020 | temiz-parodi | https://www.domaintools.com/products/farsight-dnsdb/ (sayfa 'Farsight' adını hiç geçirmiyor; www.farsightsecurity.com DNS'te çözülmüyor) ; farsight-data.com DNS'te çözülmüyor (ENOTFOUND) ; www.farsight.ai 404 · İlk taramanın üç kanıtından ikisi düştü: Farsight Security 2021'de DomainTools'a yutuldu, markası ürün sayfasında bile anılmıyor (kapanmış/soğurulmuş kullanım → çakışma sayılmaz); 'farsight-data.com dolu' iddiası yanlış, alan adı çözülmüyor. Kalan tek aday 'Farsight' (NYC, finansal veri, Seri A) — Crunchbase 403 verdi, arama bütçesi bitti, doğrulanamadı; adı yalnız 'Farsight' olan küçük bir startup, 'Farsight Data' tam adıyla eşleşmiyor ve 'farsight' sıradan İngilizce sözcük. Hüküm ÇEVRİLDİ: temiz-parodi, Palantir göndermesi (uzağı görme taşı) güçlü. Şerh: arama bütçesi açılınca 'Farsight fintech' bir kez bakılsın. |
| Kurumsal yazılım | Shopify | Shopstead | Tobi Lutke: Toby Luedecke [belirsiz (kanıtsız)] | 2015 | temiz-parodi | https://www.shopstead.com/ ; https://shopstead.us/ · İki küçük ilgisiz kullanım var: Colorado'da ev-hizmetleri lead danışmanlığı (shopstead.com) ve perakende sarf malzemesi satıcısı (shopstead.us); tanınır marka değil. Ayrıca 'shopstead' İngilizce'de sözlük kelimesi. Shopify ile karışmaz. |
| Kurumsal yazılım | Square | Tapworth |  | 2015 | belirsiz | Arama yapılamadı: WebSearch bütçesi tükenmiş; 2 sorgu reddedildi ("Tapworth" ve "Tapworth" company software payments). Kanıt URL'si yok. · Doğrulanmamış ön bilgi: Tapworth bir İngiliz soyadı olarak kullanımda; tanınır bir ödeme/fintech markası hatırlanmıyor. Soyadı taşıyan gerçek kişilerle çakışma riski (karar G: kişi adı yok) bütçe açılınca kontrol edilmeli. |
| Teknoloji komşuları | Sony | Sonimoto | Akio Morita: Akio Moriyama [temiz-parodi] | 2012'den | temiz-parodi | https://nanocuetech.com/request-a-quote · Yalnız 'Sonimoto Laboratory' (Michigan, AFM mikroskop tamiri, küçük/ilgisiz) ve benzer sesli Sonomotion/Sonokong çıkıyor; tanınır marka yok. Sony'ye yeterli mesafe. |
| Teknoloji komşuları | Samsung | Samdal |  | 2012'den | temiz-parodi | https://samdalassociates.com/ ; https://en.wikipedia.org/wiki/Welcome_to_Samdal-ri · Samdal & Associates (Washington, bina denetimi) ve Samdal Engineering (tekne tasarımı) küçük/ilgisiz; Samdal Norveç soyadı ve 'Welcome to Samdal-ri' Kore dizisinde yer adı. Elektronik/teknoloji alanında çakışma yok. |
| Teknoloji komşuları | IBM | Cerulean | Thomas J. Watson: Thomas Watkins [temiz-parodi] | 2012'den | temiz-parodi | https://www.cerulean.com/en/about-us · Dolgu, gizli. 'Cerulean' bir renk adı; aynı adlı birkaç küçük/ilgisiz firma var (Coesia'nın tütün test cihazı üreticisi, İngiliz İK danışmanı, Atlanta sigorta holdingi, Bengaluru'da küçük yazılımcı). Hiçbiri tanınır teknoloji markası değil; IBM 'Big Blue' göndermesi güvenli mesafede. |
| Teknoloji komşuları | Adobe | Adorno |  | 2012'den | temiz-parodi | https://www.crunchbase.com/organization/adorno-ae8e · Dolgu, gizli. Theodor Adorno (filozof) yalnız soyadı olarak var. Aynı adlı canlı firmalar küçük ve ilgisiz: Adorno ApS (Kopenhag, koleksiyon tasarım pazar yeri, 11–50 kişi) ve Adorno (Polonya, dekoratif metal). Adobe ile yazım mesafesi güvenli. |

### A.9 Tarama özeti ve açık işler (2026-10-07; ilk tur `wf_b2b4a971-985`, yeniden deneme `wf_954d64c8-fe0`, yeni aday `wf_60ecdd08-5e0`)

**⭐** = sahibin tuval seçimi; bu turda sahip kataloğu "gayet hoş" bulup fazı devrettiği için ⭐'lar üreticinin
önerisidir ve aşağıdaki taşımalar sahip onayı bekler. Hükümler (tablolardaki ⭐ adlar, 127 benzersiz): belirsiz 4 · belirsiz (kanıtsız) 2 · belirsiz (sahip kararı) 17 · temiz-parodi 102 · çakışma 2. İlk turda
129 ad web aramasıyla tarandı (111 temiz, 15 çakışma, 3 belirsiz; ad başına 1-2 arama, çakışma ikinci ajanla
doğrulandı). **Yeniden deneme ve yeni aday turları oturumun WebSearch bütçesi tükendikten sonra koştu:** hükümler
doğrudan alan adı okumaları (kanıt URL'li) ya da yalnız model bilgisiyle verildi; kanıtsız hüküm A.1'e göre temiz
sayılmaz ("belirsiz (kanıtsız)"), bütçe yenilenince yeniden taranır. **Çakışma alan ad kataloğa yazılmaz; sahip
tuvalde o hedef için yeni aday seçer, tarama yalnız yeni seçime koşar (A.1).**

- **⭐ taşınan hedefler (sahip onayı bekliyor):** Apple: Pomelo → Malus; Microsoft: Winmill → Fenstra; Zoom: Loupe → Mutely; Qualcomm: Quillcom → Dragonwell Semiconductor; PayPal: Paybuddy → Chequemate; Baidu: Baisou → Baiyun; Spotify: Dotify → Jukewave; ServiceNow: Nowdesk → Instanter Systems; Splice: Tenon → Joinery; —: Montara → Cutaway.
- **Geçici ⭐ (kanıtsız; taşındı ama temiz sayılmaz):** Snap: Glimpse → Blipframe; Shopify · Kurucu (Tobi Lutke): Tobias Lutkens → Toby Luedecke; Square: Rhombus → Tapworth; Simplenote: Plainly → Monoline; SoftBank Vision Fund: Reverie Fund → Velvetbank; Founders Fund: Fountainhead Fund → Zeroth Capital.
- **Çakışma (tabloda ad yok; tuvalde yeni seçim bekler):** Kinomeister (KineMaster); Basalt (Obsidian / Standard Notes).
- **Belirsiz (yeniden tarama bekler):** Blipframe (Snap); Tapworth (Square); Velvetbank (SoftBank Vision Fund); Zeroth Capital (Founders Fund); Toby Luedecke (Shopify); Monoline (Simplenote).
- **Belirsiz (sahip kararı; aynı sektörde yaşayan küçük ad, A.1 eşiği):** Malus (Apple); Silicore (Intel); Bidwell (eBay); Baiyun (Baidu); Warbler (Twitter); Instanter Systems (ServiceNow); Redgrove Capital (Sequoia Capital); Batchworks (Y Combinator); Celerity Ventures (Accel); Folio Ventures (Index Ventures); Werktag (Workday); Inset (InShot); Joinery (Splice); Surmise (Notion); Meander (Roam Research); Ursa (Bear); Dittofy (Notion klon kültürü).
- **Sahip notları:** Fenstra (Microsoft) iki eleştirmende zayıf, tarama temiz (Fenstro ilgisiz sektör); Malus (Apple)
  tanınırlıkta zayıf + canlı VPN markası; ikisi de "sahip onayıyla kaldı" damgası ister. video_clip slot 2 "yerleşik,
  liste kuyruğu $30-300M" tanımı Apple'ın ürünüyle çelişir: ya slot Apple dışı orta boy bir hedefe geçer ya §4.1 slot
  2'yi "devin ürünü" diye istisnalar. Sindbad Holdings + Tenpenny Holdings aynı kategoride iki "Holdings". Ön adı
  birebir kalan kişiler (Pony Mun, Meg Whitlock, Robin Luo, Akio Moriyama, Lei Chun, Thomas Watkins, Eric Krone) A.1'e
  uyar; Pony Ma→Pony Mun ve Lei Jun→Lei Chun "önemsiz harf farkı" sınırında. Odoo→Ardenna çağrışımı okunmuyor.
  Sektör kadrolarının hedeflerinin çoğu 2012 sonrası kurulmuştur (Notion 2016, Roam 2019, Obsidian 2020, CapCut 2019);
  sektör kadroları dönem-bağımsızdır, I3 bunu değiştirmez. Pythia (NetSuite) ile Vatic Systems (Oracle) ikisi de
  kehanet temalı: 2012 listesinde iki kâhin adı yan yana, sahip tartsın. "Systems" eki üç adda (Vatic, Frisco,
  Instanter) jenerik sayıldı (A.6), "Holdings" ikisi gibi.
- **Açık işler:** halka açık sektör slotlarının (0-2) kurucu/CEO'ları A.2-A.4'te 4 kişiyle sınırlı (§9 P1 ~9
  bekler) → I4 Kişiler'de tamamlanır; kataloğun aday açığı bayrakları (AMD, Nokia, Xiaomi, Palantir, Square, Morgan
  Stanley ikinci aday; Lei Chun romanizasyon yakınlığı) tuvalde; A.9 listeleri kapanmadan I1 veri dosyası yazılmaz.
