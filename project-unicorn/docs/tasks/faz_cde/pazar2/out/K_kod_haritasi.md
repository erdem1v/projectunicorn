# K · Kod haritası (Pazar 2): sektör, müşteri yıldızı ve koltuk, ERP hatları, rakip, satışçı, durgunluk

Kök: `project-unicorn/`. Okunan kod `HEAD` `e4e7e9b9` ile aynı çalışma ağacıdır (Q K10 takvimi 2012'ye aldı, K11 CSV temizledi). Hiçbir oyun dosyası yazılmadı.
Önceki harita `beklenti/R5_kod_haritasi.md`; onun satır numaraları `product_quality.gd`, `sales_*`, `b2b_*` için bugün de tutuyor (kontrol ettim), burada tekrar edilmedi.
Kısaltmalar: `pq` = `scripts/systems/product_quality.gd`, `b2bc` = `b2b_constants.gd`, `b2bs` = `b2b_sales_system.gd`, `sconst` = `sales_constants.gd`, `ss` = `sales_system.gd`,
`sfs` = `sales_faucet_system.gd`, `sc` = `sprint_catalog.gd`, `sb` = `sprint_bridges.gd`, `sled` = `sales_ledger.gd`, `srep` = `sales_rep_system.gd`, `smeet` = `sales_meeting_system.gd`.
"Hesap" yazan sayılar benim aritmetiğimdir. Görmediğim şey "bulunamadı" diye yazıldı.

---

## 0. Bir bakışta

1. **Sektör** bugün 13 ASCII kimliktir (`b2bc:83-85`); yalnız **sayı ve metin kanalı**dır: ürün alanı ağırlığı (`pq:48-62`), tolerans artışı (3 sektör, `b2bc:43-45`), lead'in şirket adı ve satış sorusu, şikâyet/iletişim cümlesi, 3 sektörde gece kesintisi. Oyuncu sektörü **hiçbir ekranda etiket olarak görmez**; dolaylı görür (şirket adı, görüşmede sorulan alan, şikâyet cümlesi).
2. **Hatlar modüle en yakın yapıdır**: ERP'de 5 kimlik hattı (Nakit Akışı, Veri Girişi, Defter, Stok, Fatura) + 4 paylaşılan hat, her hat 3 kademe = 27 kademe kartı. Ama sektör **alanla** bağlıdır (`pq:TABLE`), hatla değil; beklenti alan ortalamasındadır, hat başına beklenti yoktur.
3. **Müşteri yıldızı** `Prospect.star` / `Customer.scale` (int, kodek sınır koymaz), kodda 1-3 kilitli: `SalesConstants.STAR_MAX := 3` (`sconst:45`), `ProductQuality.STAR_MAX := 3` (`pq:21`), `SEAT_BAND` yalnız 1-3 (`sconst:115-119`), yıldız karışımı 3 elemanlı (`sconst:42-43`). 5'e çıkarmak ~30 dosya noktasına dokunur (§2.4).
4. **Koltuk** imzada yıldız bandından gelir ve yalnız `expand` ile artar (bir kez, `last_expansion_day` mandalı); **koltuk azalması ve yenilemede koltuk kararı bulunamadı**.
5. **Ar-Ge ve kart kataloğunda yıl ya da dönem kilidi bulunamadı.** Kilitler yalnız kişi yıldızı, Ar-Ge düğümü ve toplam yıldızdır (`data/product/lines/*.json`). Tavan `TIER_MAX = 3` hat başına (`product_lines.gd:20`), yani ERP'nin tüm tavanı 27 kademedir ve oyun 2-3 yılda (104 hafta yumuşak tavan) buna varabilir.
6. **Rakip iki ayrı model** (R5'teki gibi) ve ek bulgu: kayıtlı çıkış tablosundaki üç ERP rakibi **startup'lardır** (`rivals.json erp.rivals = [3,5,6]` → Ardenna, Raketenhaus, Sumpter); dev (Datenwald) ve yerleşikler (Pythia, Werktag) çıkış tablosunda **yoktur**. "Dev yüksek başlar, aynı yol haritasını izler" için kodda taşıyıcı yok.
7. **Satışçı yıldızı** üç şeyi etkiler: hangi yıldızdaki lead'e bakabileceği (kapı), anlaşma süresi (yıldız farkı başına yarım hafta), haberlik sayılma eşiği. Kapanış ihtimaline, fiyata, koltuğa **dokunmaz** (`srep:279-286`). "%60 tabanı" diye sabit kodda bulunamadı; en yakını `CLOSE_CURVE` (§5).
8. **Durgunluk**: sürüm çıkmazsa tek mekanik ceza `interest` sönümüdür (yarı ömür 30 gün = 4,29 tik; lead hızı ×0,8 tabanına, B2C büyüme çarpanına iner) ve hata akışı sürer. Beklenti hareket etmediği için **özellik bakımından eskime yoktur**; gecikmiş talebin cezası bulunamadı (§6).

---

## 1. Sektörler

### 1.1 Nerede tanımlı (dosya:satır)

| Ne | Yer |
|---|---|
| 13 kimlik: construction, health, logistics, insurance, manufacturing, retail, real_estate, textile, legal, technology, ecommerce, media, finance | `b2bc:83-85` |
| Fikstür sektörü `testing` (13'ün dışında; yalnız smoke/probe) | `b2bc:89` |
| Eski Türkçe ad göç tablosu | `b2bc:94-100`, `save_manager.gd:1039-1046` (`_migrate_sector_ids`) |
| Sektör → alan sırası [vurgu1, vurgu2, kalan] (ağırlık 0,25/0,15/0,10) | `pq:48-62` (`TABLE`), `pq:66-75` (`weights`), `pq:384-385` (`_row`; tanınmayan sektör ilk arketipin ilk sektörüne düşer) |
| Sektör → toleransa ek (yalnız construction/health +5, insurance +3) | `b2bc:43-45`, `b2bc:48-52` |
| Arketip → sektör listesi (ops_cautious 5, tech_exacting 4, finance_brisk 4; **sıra yükler**) | `sales_archetypes.gd:46`, `:64`, `:82`, `:118-119` |
| Şirket adı havuzu: sektör başına 5 elle ad + sektör sözcüğü soneki | `company_catalog.gd` (`COMPANIES`, 13×5), `sales_name_pool.gd:42-57` (`SECTOR_WORDS`), `:66-98` |
| CSV: `B2B_CONTACT_<ID>` (674-687), `B2B_COMPLAINT_<ID>` (701-715), `SECTOR_<ID>` (659-673) | `localization/strings.csv`; türetme `b2bc:109-134` |
| Gece kesintisi sektörleri (logistics, manufacturing, health) | `data/product/sprint.json:59`, okuyan `incident_system.gd:400-401` |
| Depo işi kâğıdı sektörleri (logistics, manufacturing, retail) | `sprint.json:44`, okuyan `sc:436` |
| Kayıtta: `Customer.industry`, `Prospect.industry` (@export String) | `customer.gd:19`, `prospect.gd:20`; `Customer.market_ref` anahtarı yıldız+sektör satırından kurulur (`customer.gd:79`) |

**Karışmasın:** `product_catalog.gd:10-42` her **ürün tipi** için bir `sectors` listesi taşır (`consumer`, `saas`, `enterprise`, ...) ve `type_sector_labels` (`:237-241`) `SECTOR_` önekini okur; bu ayrı bir sözlüktür (müşteri sektörüyle çakışan kimlikler: construction, logistics, health, insurance, manufacturing, retail, real_estate, media, finance). `type_sector_labels`'ın çağıranı kodda **bulunamadı** (yalnız smoke `endgame_smoke.gd:10952`, `:12149`). Piyasa'nın `sector_id`'si (`data/market/companies.json`: erp, notes, bank, ...) üçüncü bir taksonomidir (`piyasa_tab.gd:673-674`).

### 1.2 Kim okuyor

| Okuyucu | Ne yapıyor | Yer |
|---|---|---|
| Ürün uyumu | Aday/hesap bağlamında alan ağırlığı, rol (vurgu/kalan), beklenti; `market_ref_for(yıldız, sektör)`; `market_fit` 13 sektörün ortalaması | `pq:118-129`, `:206-212`, `:222-228`, `:246-252`, `:322-329`, `:359-360` |
| Hesap kullanımı | `used_areas(sektör)` = ağırlığı ≥ 0,15 olan alanlar (Çekirdek + 2 vurgu) → hesabın hata cezası ve etkilenen hat listesi | `pq:85-92`, `b2bs:171-178`, `sc:369-375` (`line_accounts`) |
| Tolerans tohumu | imzada `seed_tolerance(yıldız, sektör)` | `ss:368`, `b2bs:477` |
| Lead üretimi | arketip → sektör seçimi (hash'li), ad havuzu, `p.industry` | `sfs:204-224`, `sales_archetypes.gd:167-185` |
| Satış görüşmesi | `ProductQuality.emphasis(p.industry)[0]` → "emphasis" soru ailesi (`probe_emphasis_trust/integrations/onboarding`) | `sales_probes.gd:49`, `:144-170` |
| Yenileme/talep | hesabın vurgu 1 alanından talep edilecek kademe | `sb:41` |
| Kâğıt/olay | depo sektörü kâğıdın hesabı; gece kesintisi sektörü | `sc:436`, `incident_system.gd:400` |
| Metin | risk sesi → şikâyet cümlesi (`B2B_COMPLAINT_*`); olay seam'leri `musteri.complaint_voice`, `musteri.sector_contact` | `b2bs:563`, `seams_ported.gd:67-82`, `data/events/cards/customer/request_complaint.json:130,142` |
| Gelen kutusu | gönderen unvanı = sektör irtibatı, **yalnız** `acquisition_source` boş hesapta (fikstür); gerçek imzada alıcı kişi kullanılır | `inbox.gd:458-464` |
| Fikstür/probe | 13 sektörlü kitap dünyası | `main.gd:526-532`, `:688`, `:1542`, `:3434`, `:3867`, `:4137` |
| Smoke | `endgame_smoke.gd` 222 geçiş, `run_probe.gd` 21 geçiş (silme/bağlama işi buraya taşar) | |

### 1.3 Oyuncu nerede görüyor

- **Doğrudan sektör etiketi: hiçbir sekmede bulunamadı.** Aday kartı (`sales_tab.gd:337-347`) yıldız, ad, kalan hafta, kaynak etiketi ve arketip cümlesi (`SalesArchetypes.voice_line`) gösterir; hesap kartı (`:538-622`) yıldız, durum, `$/ay · koltuk · kıdem · koltuk fiyatı`, memnuniyet; sektör yok. Görüşme paneli kimlik bloğu (`meeting_panel.gd:399`, `sales_meeting_adapter.gd:68`) yıldız ve arketip cümlesi; sektör yok.
- **Dolaylı:** (a) şirket adı sektör sözcüğü taşır ("Deniz Lojistik", `sales_name_pool.gd:42`); (b) görüşmede sorulan ilk alan sektörün vurgusudur; (c) Risk'teki hesabın şikâyet cümlesi sektöre özeldir; (d) Piyasa penceresi ayrı taksonomiyle sektör etiketi gösterir (`piyasa_tab.gd:673`, "Sektörüm" filtresi `:107`).

### 1.4 Kaldırılırsa

Etkilenen: `TABLE` (13 satır) ve ona bağlı her ağırlık/rol/vurgu çağrısı (`pq` 31 geçiş), `market_fit` döngüsü (`pq:226`), tolerans artışı (3 sektör), `SalesArchetypes.sectors` + ad havuzu (sektör yoksa ad havuzu da yok; CompanyCatalog 65 ad), `emphasis` soru ailesi (3 katalog satırı), `sb:41` talep alanı, `sc:374`/`sc:436`, `b2bs:175`, `b2bs:563`, gece kesintisi `night_sectors`, 2 seam + 1 olay kartı, 40 CSV satırı (3 aile × 13 + yedekler), 243 smoke/probe geçişi. Kayıt: `industry` alanı varsayılan boşa düşer; **`market_ref` yeniden hesaplanır** (`save_manager.gd:984-988`, `_migrate_17` her `yıldız|sektör` çifti için bir kopya kurar, kayıt göçü gerekir). "Yalnız ad" kalacaksa en az dokunuş: `TABLE`'ı tek satıra indirmek ve tolerans artışını sıfırlamak; ad/CSV zaten ad görevi görüyor.

### 1.5 Modüle bağlanırsa (yalnız kodda neye oturur)

- **Doğal taşıyıcı hat kimliğidir.** `line_erp_*` zaten kimlik, ad (`PROD_LINE_ERP_*`, CSV 2124-2128), 3 kademe, kullanım ağırlığı, açık hata deposu (`ProductState.open_bugs_by_line`) taşır. Hesabın "hangi hatları kullandığı" bugün **alan üzerinden** türer (`sc:369-375`, `b2bs:171-178`): sektör alanı kullanıyorsa o alanın tüm hatlarını kullanır. Modül başına kullanım için `uses_area` yerine `uses_line(hesap, hat)` gerekir; bunun tüketicileri tam olarak `line_accounts`, `account_bugs`, ve `ProductQuality.expectation` (alan toplamı).
- Hesap başına modül listesi **kayıtta yok**: `Customer`'a `modules: Array` eklenir (@export varsayılanı göçtür, `customer.gd:12-90` örüntüsü); `Prospect` aynı şekilde (aday modülleri görüşmede söylenecekse). Koltuk ve modül, `Prospect.deal_seats` ile `deal_price`'ın yanına girer (`prospect.gd:48-52`).
- Görüşme bugün "koltuk pazarlık edilmez, bantla gelir" kuralındadır (`negotiation_system.gd:107-109`, `sconst:113`); müşterinin istediği modül ve koltuğu söylemesi yeni bir bölüm olur. Teklif tek eksendir (koltuk başı fiyat, `negotiation_system.gd:107-112`, `sled:141-144`); modül kombinasyonu fiyatı değiştirmez bugün.
- Beklenti tablosundaki "alan" ayrımı (Çekirdek / Onboarding / Entegrasyon / Güven) modülle çakışmaz: Çekirdek alanı zaten 5 ERP modülünün ortalamasıdır. Modül = hat olursa **Çekirdek beklentisi hat sayısına bölünür** (`pq:344-345`, `mvp_lines ÷ hat sayısı`) ve bu hücre hesaplanandır, modül başına eşik tabloda yok.
- Rakip çıkışı zaten hat bazlıdır (`rivals.json launches[].line`); modül bağlanırsa "o modüldeki rakip çıkışı" doğrudan ifade edilir (`sc:748-752`).

---

## 2. Müşteri yıldızı ve koltuk

### 2.1 Tanım

| Ne | Değer | Yer |
|---|---|---|
| Aday yıldızı | `Prospect.star: int = 1`, yorum "1..3 in the demo" | `prospect.gd:22-24` |
| Hesap yıldızı | `Customer.scale: int = 1`, yorum "1..5 stars; demo binds 1-3" | `customer.gd:39` |
| Yıldız aralığı | `STAR_MIN 1`, `STAR_MAX 3` ("demo ceiling MÜHÜRLÜ") | `sconst:44-45` |
| Yıldız karışımı | evre başına 3 elemanlı dizi [1★,2★,3★]; `_roll_star` döngüsü `for i in 3` | `sconst:42-43`, `sconst:228-232`, `sfs:171-177` |
| Üç basamaklı büyüklük kelimesi | `company_size` small/mid/enterprise; `SIZE_TO_STAR` | `customer.gd:20`, `sfs:30`, `ss:355`, `b2bc:198`, `save_manager.gd:622` |
| Koltuk bandı | 1★ 5-10, 2★ 15-30, 3★ 40-70; 1-3 dışı değer kenara kırpılır | `sconst:115-119`, `:235-236` |
| Koltuk fiyatı | $30-70 bandı, orta $50 × duruş (rekabetçi 0,85 / standart 1 / premium 1,15); **yıldıza bağlı değil** | `sconst:120-132`, `sled:141-144` |
| Anlaşma süresi tablosu | `DEAL_BASE_WEEKS` 1..5 yıldız için **zaten 5 giriş** (2, 3, 6, 8, 12 hafta) | `sconst:152-154` |
| Ürün beklentisi satırları | 3 yıldız satırı; `STAR_MAX := 3` (kişi yıldızıyla karışmasın: `HRConstants.STAR_MAX := 5`, `hr_constants.gd:31`) | `pq:21`, `pq:341-355` |
| Çizim | `UiFactory.D_stars` **5 glif** çizer (HR ölçeğinden) | `ui_factory.gd:399-405` |
| Koltuk kaydı | `Customer.seats: int`, `seat_price`, `signing_discount`, `mrr` | `customer.gd:24-25`, `:86-89` |
| Koltuk artışı | yalnız `B2BSalesSystem.expand` (`expansion_seats(company_size)`: 3/6/12) ve olay fiili `seats` | `b2bs:374-391`, `b2bc:198-202`, `effects.gd:259-267`, `:643-652`; mandal `last_expansion_day`, `can_offer_expansion` `b2bs:284-289` |
| Koltuk azalması | **bulunamadı** (kodda koltuğu düşüren yol yok; `seats` fiili negatif miktar alabilir ama böyle bir kart bulunamadı) | |

### 2.2 Yıldızı okuyan her yer

| # | Okuyucu | Ne yapıyor | Yer |
|---|---|---|---|
| 1 | Lead üretimi | evre karışımı, kalite kısması, `clampi(star, 1, 3)`, arketip yıldız aralığı | `sfs:148-177`, `:191-225`, `sales_archetypes.gd:48,66,84,122-124` |
| 2 | Ürün uyumu | `expectation({star})`, `market_ref_for`, `serves/next_star/next_ratio`, aday bağlamı | `pq:153-174`, `:206-228`, `:359-360` |
| 3 | İmza | koltuk bandı, fiyat damgası, `scale`, tolerans tohumu, pain feature seed, `market_ref`, ticker bayrakları | `ss:318`, `:355`, `:367-368`, `:383`, `:386`, `:396-403` |
| 4 | Tolerans | `33 + 9·(yıldız−1) + sektör` | `b2bc:39-52` |
| 5 | Kurucu masası | ibre: yıldız uyumsuzluğu cezası `[0; 0,14; 0,34]` (kurucu yıldızı ile aday farkı, 0-2'ye kırpılır), soru sayısı yıldıza göre (1/3/5) | `smeet:161-162`, `:220-225`, `sconst:87`, `:101-103` |
| 6 | Pazarlık | koltuk bandı (yıldız 1..3'e kırpılır), arketip profili | `negotiation_system.gd:98`, `:107-112` |
| 7 | Satışçı | band kapısı, öncelik sırası, anlaşma süresi, koltuk | `srep:69-79`, `:97-100`, `:111-136`, `:169-173`, `:282-286` |
| 8 | Anlaşma planı | `deal_halfweeks(müşteri yıldızı, satıcı yıldızı)` | `sconst:244-247`, `sales_finalizer.gd:61` |
| 9 | Satış defteri | haberlik imza (`scale > reach_band` ya da ilk 3★), haftalık kapanış satırı `star` | `sled:262-272`, `:399-400` |
| 10 | Muhatap kişiler | karşı masada yıldız kadar kişi: `PROSPECT_ROLES = [buyer, user_lead, finance]` (**3 rol**; 4-5 yıldız için rol yok) | `counterpart_system.gd:21`, `:55-57` |
| 11 | Görüşme soruları | "referans" kartı: bu yıldız ve üstü aktif hesap var mı | `sales_probes.gd:52`, `:87`, `:109-113` |
| 12 | Müşteri masası | talep zorluğu `+ (scale−1)` | `customer_rep_system.gd:235` |
| 13 | Talep seçimi | `pick_pain_feature(alt-tür, scale + gün)` (yıldız hash tohumu) | `b2bs:581` |
| 14 | Pipeline tahmini | `seat_band(prospect.star)` orta noktası × fiyat | `ss:318` |
| 15 | Olay seam'i | `musteri.scale` ("1-5, demo binds to 1-3") | `seams_sales.gd:46-47` |
| 16 | Olay kartları | `musteri.scale` eşikleri: `chargeback` ≤ 2, `new_owner` ≤ 2, `named_in_leak` ≥ 2, `security_review` ≥ 3 (iki yerde), `sprint_design_customer_colors` ≥ 2; `add_prospect` fiili `size` small/mid/enterprise kullanır (`frank_intro`, `trade_fair`, `analyst_guide`, `monthly_update`, `copycat`) | `data/events/cards/customer/*.json`, `data/events/cards/product/sprint_design_customer_colors.json:78`, `sfs:249-252` |
| 17 | Bant tavanı ayarı | `rep_band_cap` `clampi(cap, 1, 3)`, kayıtlı `GameState.sales_band_caps` | `sled:99-108`, `game_state.gd:212` |
| 18 | Ürün tabanı | `product_strength` = `market_fit(STAR_MAX)` ÷ 70 | `sfs:165-166` |

### 2.3 Ekranlar

- `sales_tab.gd:337` (aday adı + yıldız), `:538` (hesap adı + yıldız), `:770-775` (`_name_row`, `D_stars`), `:439` (satışçı kartı, kişi yıldızı).
- `meeting_panel.gd:399` (kimlik yıldızı), `sales_meeting_adapter.gd:68`, `:199`.
- `mail_pane.gd:657-661` (haftalık satış raporu: yıldız **tam sayı + tek ★ glifi**, 5'e kadar sorunsuz).
- Kimlik ve gelen kutusu başlıkları `acquisition_source` üzerinden `CounterpartSystem.buyer_of`.
- **HESAPLAR tablosu henüz yok** (C8).

### 2.4 5 basamağa çıkarmanın dokunacağı yerler

Sabit dizi/tabloları genişletecek olanlar (kırılan): `sconst:42-43` (karışım 3 → 5 eleman), `:45` (`STAR_MAX`), `:87` (`MISMATCH_PENALTY` 3 eleman, indeks 0..2 kırpılır), `:103-105` (`PROBES_*`, `_probes_for_star` `match 1/2/default`, `smeet:220-225`), `:115-119` (`SEAT_BAND` 1-3), `:152` (zaten 5), `:175` (`TICKER_NEWSWORTHY_STAR := 3`), `sfs:171-177` (`_roll_star` `for i in 3` ve `mix[2]`), `sfs:148-166` (kalite kısması yalnız üst bant = `mix[2]`), `sfs:30`/`ss:355` (3 kademeli `company_size`, `b2bc:198` `EXPANSION_SEATS` 3 anahtar), `pq:21`/`pq:153-174`/`pq:300-355` (beklenti satırları ve `serves/next_star`, `_star_value` match 3 yıldız; `PAGE_STAR`, `AUDIENCE_STARS`), `counterpart_system.gd:21`, `sales_archetypes.gd` `star_range` (3 arketip, [1,3] ve [1,2]), `negotiation_system.gd:98`, `sled:108`, 5 olay kartı eşiği, `seams_sales.gd:46` (zaten 1-5 yazıyor).
Zaten 5'e hazır: `D_stars`, `mail_pane` raporu, `DEAL_BASE_WEEKS`, `HRConstants.STAR_MAX`, `Customer.scale` yorumu, `seams`.
Karıştıracak ikinci anlam: `HRConstants.stars_for` kişinin yıldızı (0-5) aynı 5'li ölçekte `rep_star`/`founder_star` olarak müşteri yıldızıyla **doğrudan karşılaştırılır** (`srep:97`, `smeet:161`, `sled:88-90`); yıldız 5'e çıkınca satıcı ve müşteri aynı sayı çizgisinde kalır (bugün satıcı 5★ olsa da müşteri en çok 3★ olduğundan band kapısı hep açık).
Tolerans: `33 + 9·(yıldız−1)` 5★'ta 69 (`b2bc:40` yorumu "Tier-2 scale 5 → 69" bunu zaten not eder).

**Kayıt şeması:** `SCHEMA_VERSION 18` (`save_manager.gd:16`), `MIN_LOADABLE 10`. `Prospect.star` ve `Customer.scale` @export int'tir, `SaveCodec` değer aralığı doğrulamaz; eski kayıttaki 1-3 yeni ölçekte aynı sayıyla okunur (anlamı değişirse göç gerekir: yeniden eşleme `_migrate_*` kalıbı, `save_manager.gd:626-649` `_migrate_sales_rev6` ve `:969-995` `_migrate_17`). `market_ref` yıldız satırından kurulur ve kopya anında dondurulur (`ss:386`, `sb:35-36`); satır tanımı değişirse eski kopyalar eski dünyada kalır. Bayraklar: `sales_last_signed_star`, `sales_first_top_star_id` (`ss:396-403`). Şema 19 PLAN_C'de C3a'ya ayrılmış (R5 §8.1).

---

## 3. ERP'nin hatları, alanları, kart kataloğu ve Ar-Ge

### 3.1 "Modül" kavramına en yakın yapılar

| Yapı | Ne | Sayı | Yer |
|---|---|---|---|
| **Hat** (line) | ürünün bir yeteneği; 3 adlı kademe (K1..K3), iş profili (dev/test/design), kullanım ağırlığı, bazı kademelerde lisans ve Ar-Ge/kişi kapısı | ERP'de **9**: 5 kimlik + 4 paylaşılan | `data/product/lines/erp.json`, `shared.json`, `product_lines.gd:1-60` (`LINES_PER_SUBTYPE 9`) |
| ERP kimlik hatları | `line_erp_cashflow` Nakit Akışı (dev), `line_erp_intake` Veri Girişi (dev), `line_erp_ledger` Defter (test), `line_erp_stock` Stok (design), `line_erp_invoicing` Fatura (design) | 5 × 3 = 15 kademe | `erp.json`, CSV 2124-2128 |
| Paylaşılan hatlar | `line_shared_integrations` Entegrasyonlar, `_security` Güvenlik ve Yetki, `_durability` Dayanıklılık, `_mobile` Mobil ve Erişim (kimlik `…@erp`) | 4 × 3 = 12 kademe | `shared.json`, `product_lines.gd:159` (`@alt-tür`) |
| Gizli hat | `line_hidden_self_serve` "Kendi Kendine Servis" (Onboarding alanında), `test_automation` Ar-Ge düğümü açar; diğer 3 gizli hat **yazılmamış, kayıtsız** | 1 yazılı (3 kademe) | `data/techtree/rnd_tree.json` `hidden_lines`, `sprint.json areas[onboarding].lines` |
| **Alan** (area) | sektör ağırlığının ve beklentinin birimi; hatların kümesi | B2B'de 4: `core` (5 kimlik hattı), `onboarding` (mobile + gizli), `integrations` (shared_integrations), `trust` (security + durability); B2C'de `growth` ve `revenue` ek | `sprint.json:130-137`, `sc:41-81` |
| Ar-Ge düğümü | `data_model`, `ai_engine`, ... 20 düğüm, 4 aile × 5 | 20 | `rnd_tree.json nodes`, `research_seam.gd:25-` |
| Paylaşılan hattın K3 Ar-Ge bağı | integrations→`data_model`, durability→`scalable_backend`, security→`security_cert`, mobile→`design_system` | 4 | `research_seam.gd:55-` |

Beklenti **alan ortalaması**dır (`pq:96-104`): Çekirdek'te 5 hat ortalaması 1,25 ise "Yeterli", hangi hattın geride olduğu beklentiyi ayrıştırmaz. Hat bazlı bakış yalnız (a) açık hata etkisi alan üzerinden (`b2bs:171-178`), (b) rakip çıkışı hat bazlı (`rivals.json`), (c) talep kartı hat kademesi bazlı (`sb:40-56`) vardır.

### 3.2 Sprint kart kataloğu (ERP, B2B)

`SprintCatalog.candidates(alan)` (`sc:198-242`) alan başına dinamik kart kurar. Sabit liste yok:
- **feature**: her hattın bir sonraki kademesi, kademe başına 1 kart (ERP'de toplam 27 + gizli hat 3). `effort` K1 5-6, K2 7-8, K3 9-11 (`product_lines.gd:24`, `EFFORT_BANDS`).
- **request**: hesabın istediği kademe kartı (`sb:50-56`), son tarihi `deadline_weeks 8`.
- **fix**: hatta açık hata varsa 1 kart (`fix_effort`: adım 4, puan 1-2, öncelik eşiği 5).
- **research**: alan başına, her sprintte bir kez (`research_done`).
- **Sprint kâğıdı** (karar kartı): 46 kart kimliği (`sprint.json decision.cards`), sprint başına tek zar (1 haftalık 0,3, 2 haftalık 0,5), 52 haftada bir, koşuda en çok 3 kez.
- Kart etkisi: `sc:307-337`; PM planı ufku 3 sprint (`sprint.json pm`).
- Olay kartları toplam 168 JSON (`data/events/cards/`, 9 kategori).

### 3.3 Yıl ya da dönem kilidi

**Bulunamadı.** Kontrol ettiğim yerler: `product_lines.gd`, `sprint_catalog.gd`, `sprint_system.gd`, `sprint_bridges.gd`, `research_tree.gd`, `research_seam.gd`, `rnd_system.gd`, `product_state.gd`, `product_catalog.gd`, `line_gates.gd`, `product_system.gd`, `product_read.gd`, `module_locks.gd`; hiçbirinde `get_date_dict`/`START_DATE`/yıl alanı yok. Mevcut kapılar yalnız: kademe sırası (K1→K2→K3), Ar-Ge düğümü tamam, kişi yıldızı (`person`: bir kişide N yıldız; `total`: ekipte toplam), lisans nakdi (`license_cost`), `module_locks.gd` (sekme kilidi `"ea"`, ürünle ilgisiz).
Takvimi okuyan sistemler (`get_date_dict`) ürüne girmez: Piyasa (`market_catalog.gd:164-178`; çıpalar 2008-2025, 2025'ten sonrası son çıpaya kırpılır), İK izin yılı, ay kapanışı, özetler, `world.month` seam'i. **START_DATE bugün 2012** (`game_state.gd:8`), `SOFT_CAP_WEEK 104` (`endings_system.gd:38`) = Aralık 2013. Erdem'in "bitiş yılı 2030" 18 yıl ≈ 940 hafta demek; tools `run_gate.sh` varsayılanı 730.

### 3.4 Tavan

ERP için ürün tavanı **27 kademe + 3 gizli**; ürün tipi "ERP" tek hat setiyle sabit. K3 kademelerinin hiçbiri yıl kapılı değildir. Yeni kademe/hat eklemek: (a) `erp.json`'a hat (zorunlu 5 kimlik hattı doğrulaması `product_lines.gd:IDENTITY_LINE_COUNT 5`, profil şekli `IDENTITY_PROFILE_SHAPE 2 dev · 1 test · 2 design` — **hat sayısını 5'ten çıkarmak yükleyiciyi düşürür**), (b) `TIER_MAX := 3` (`product_lines.gd:20`) ve `steps.size() != TIER_MAX` doğrulaması (`:153-155`) 3'ten fazla kademeyi reddeder, (c) `register_runtime_line` (`product_lines.gd:365-383`) çalışma anında hat eklemeyi destekler (gizli hat yolu); bu yol yıl-kilitli açılış için zaten bir örnektir ve `mvp_hidden_lines` olarak kayda geçer.

---

## 4. Rakipler

### 4.1 Mevcut yapı (R5'e ek)

- **Model A** (`Rival`, 8 varlık/alt-tür: 1 dev + 2 yerleşik + 5 startup; `rival_catalog.gd:20-29`): ERP adları `Datenwald` (dev), `Pythia`, `Werktag` (yerleşik), `Ardenna`, `Tacita`, `Raketenhaus`, `Sumpter`, `Thymeworks` (startup) (`:117`, `NAMES` indeks sırası kilitli). `company_id` Piyasa satırı ile bağ (`rival_catalog.gd:237`; slot 0-2 = `datenwald`, `pythia`, `werktag`, `companies.json meta.sector_slots.erp`). Alanları: üç kalite boyutu, `momentum`, `status`, `tier`; **çalışan sayısı, büyüklük, hat kademeleri, Ar-Ge durumu yok** (`rival.gd:17-31`).
- **Model B** (`rivals.json erp`): `rivals = [3, 5, 6]` (NAMES indeksi: Ardenna, Raketenhaus, Sumpter = **üç startup**), başlangıç kademeleri 9 hat × 3 rakip (`tiers`), 11 sabit çıkış (sprint 4, 7, 10, 13, 17, 21, 25, 30, 35, 41, 47), çıkış başına tek hat kademesi.
- **Piyasa değeri** (`companies.json`): `datenwald` kuruluş 1988, değer 2012'de 85.000 → 2025'te 280.000 ($M), `pythia` 250 → 1.800, `werktag` 120 → 1.500; çıpalar yıl sonu, `meta.rule: "player actions never feed back into anchors"`. 2012'den sonrası boyunca 2025'e kadar var, 2026+ son çıpada sabit (`market_catalog.gd:164-178`). Yani dev ERP rakibinin "ilerleyişi" Piyasa'da yalnız değer eğrisi olarak var, ürün yetenekleri olarak yok.
- Okuyucular: `RivalRegistry.advance_all` (`time_manager.gd:406`), `get_market_snapshot` (Finans pazar payı, haber bandı), `VCPitchSystem._rival_ahead` (`vc_pitch_system.gd:1286-1291`, hep true), olay seam'leri `rival.status/momentum/leader` (`seams_world.gd:75-95`), `rnd_system.gd:574` (RivalCatalog.NAMES okur: Ar-Ge'de rakip adı), `presenter.gd:161`.

### 4.2 Rakiplerin aynı kart listesi ve Ar-Ge ağacını yürütmesi için gereken

1. **Rakip başına durum** (şimdi yok): hat başına kademe (şimdi yalnız Model B `tiers` + `rival_hits` toplamı, `sc:730-736` `_rival_tier`), Ar-Ge düğüm kümesi, çalışan/ekip dağılımı, sprint saati, kart kuyruğu. `Rival` (`@export` alanları kendiliğinden kaydolur, varsayılan göçtür, `rival.gd` başlığı) eklenebilir; `RivalRegistry.insert_raw` katalog üstüne bindirir (`rival_registry.gd:37-45`).
2. **Bir "rakip sprint" fonksiyonu**: `SprintSystem` oyuncunun `GameState.product` sözlüğüne bağlıdır (`_p()` statik); rakip için aynı kart mantığı (`candidates`, `step_effort`, `gate_reason`, `person`/`total` kapıları `line_gates.gd`) ayrı bir durum üstünde çalışmıyor. En kısa yol: kart havuzunu (`ProductLines`, `ResearchTree` verisi, saf veri) paylaşıp, ilerleme/seçim fonksiyonunu ince yazmak; `SprintCatalog` içindeki oyuncu durumuna bağlı kısım (`tier`, `polish`, `open_bugs`) rakip için değişir.
3. **Zaman ekseni**: çıkış tablosu sprint numarasına bağlı (oyuncunun sprint süresi 1 ya da 2 hafta seçilebilir, `sprint.json sprint_lengths`); rakip saatinin takvime (hafta) bağlanması gerekir (`SprintSystem.sprints_in`, `sc:748-752` pencere de sprint sayar).
4. **Taksonomi**: `rivals.json` hat kimliklerini `line_shared_x@erp` biçiminde taşır (`product_lines.gd:159`), hat veri modeliyle aynı; yani aynı kart listesi zaten adreslenebilir. Ar-Ge düğümü rakip için `ResearchSeam.completed` oyuncuya bağlı (`research_seam.gd`); rakip düğümü için ayrı durum şart.
5. **Okuyucuların bağlanması**: Model A kalite boyutları şimdi hiçbir ekonomiyi sürmüyor; yeni modelde bunların yerini hat kademesi toplamı alırsa `Rival.composite`, `COMPOSITE_AXES`, `QualityModel.grow`, `TIER_ASYMPTOTE`, `advance_all` ve `status` (momentum eşiği) yeniden tanımlanır ya da silinir (R5 §8.2). Pazar payı (`get_market_snapshot`) kaliteyi okumaz, tohum payı × momentum okur (`rival_registry.gd:127-158`): rakibin gerçek ilerleyişi payı etkilemez.
6. **Dev rakip**: Model B'de dev yok; `tiers` başlangıç değerleri 0-2 (dev için "yüksek başlar" ifadesi yok). Dev rakibi için başlangıç kademeleri, çalışan sayısı ve ilerleme hızı ayrı verilmeli. `Datenwald` Piyasa'da halka açık (`ipo_year 1988`); Piyasa değeri kayıtlı çıpadır, ürün ilerlemesiyle bağı yok.
7. **Yıl kapılı açılış** (ör. YZ dönemi): rakibin Ar-Ge'si de aynı kapıya tabi olmak zorunda; kilit kayıt yeri (3.3) bulunamadı, yani rakip ve oyuncu için tek ortak "dönem" sabiti/tablosu gerekir.
8. **Kayıt**: `rival_hits` zaten kayıtlı (`game_state.gd:294`); yeni rakip durumu `Rival` @export'u ya da `GameState.product`/yeni sözlük olarak SaveCodec'e girer; şema 18 göçü gerekmez, varsayılan boş = "katalog başlangıcı".
9. **Ölçek/maliyet**: `advance_all` her tik 8 × 13 alt-tür rakibi dolaşır (`rival_registry.gd:71-87`); hat bazlı karar eklenirse maliyet `capabilities` önbelleği gibi (`ProductLines.memo`, `sc:63-69`) bir önbellek ister. Tik bütçesi: 330 hesapta gece tiki 133,6 ms, kapı 148,2 (R5 §8.3).

---

## 5. Satışçı: yıldızı bugün neyi etkiliyor

Satışçı yıldızı = `HRConstants.stars_for(HRSystem.skill(rep, AREA_SALES))` tam sayıya kesik (`srep:77-78`, `HRConstants.stars_for` `hr_constants.gd:264-266`, 2 puan = 1 yıldız, tavan 5). Kurucunun yıldızı aynı biçimde (`sled:88-90`).

| # | Etki | Satışçı | Kurucu | Yer |
|---|---|---|---|---|
| 1 | **Hangi lead'e bakabilir**: `lead.star ≤ band_ceiling(rep)`; oyuncu tavanı düşürebilir (`rep_band_cap`), yükseltemez | evet (sert kapı) | masada: kapı yok, ibreye ceza | `srep:69-79`, `:97-100`, `:111-120`, `sled:99-108` |
| 2 | **Anlaşma süresi**: `max(taban(müşteri yıldızı) − 0,5 × (satıcı yıldızı − müşteri yıldızı)⁺, 1)` hafta; premium duruş +%30, böl `HRSystem.productivity(rep)` | evet | evet (`sales_finalizer.gd:61`) | `sconst:152-154`, `:244-247`, `srep:169-173`, `sales_finalizer.gd:58-80` |
| 3 | **Ulaşım bandı (`reach_band`)** = kurucu ve satışçıların en yükseği: üstündeki imza haberlik ve marka getirir; üstündeki lead "balina" koltuğu (kapanış şartı) olur | evet (en yüksek) | evet | `sfs:286-290`, `:257-262`, `sled:262-272`, `sales_meeting_system.gd:200-201` |
| 4 | **Masada ibre**: `W_FOUNDER_SALES 0,22 × (yıldız÷5 − 0,4)` + yıldız uyumsuzluğu cezası `[0; 0,14; 0,34]` (aday − kurucu yıldızı) | yok | **evet** | `smeet:145-147`, `:161-172`, `sconst:76-91` |
| 5 | **Lead akışı**: temsilci sayısı başına +2/hafta; **yıldızı hiç etkilemez** | sayı | — | `sfs:120-129`, `sconst:19-20` |
| 6 | **Kapanış ihtimali** (`close_chance`): adayın U'sundan, satışçı yıldızı **okunmaz** | yok | yok | `pq:233-241`, `srep:239-274` |
| 7 | **Fiyat**: "Temsilci kadrandan kapatır; yıldızı fiyata dokunmaz" | yok | — | `srep:259-262`, `sled:141-144` |
| 8 | **Koltuk sayısı**: müşteri yıldızı bandı + hash; satışçı yıldızı yok | yok | — | `srep:282-286` |
| 9 | Aday kartında satışçı bandı dışı gerekçesi: "SALES_BAND_ABOVE_REP / _CAP" | evet | — | `srep:96-101`, `sled:68-80` |
| 10 | Aday kabiliyeti sınırı (`CANDIDATE_STAR_CAP_RAW 7` = ★3,5) | İK | — | `sconst:200` |

`CLOSE_CURVE` (`pq:30`): U ≤ 40 → %30, 55 → %60, 70 → %85, ≥ 80 → %95, doğrusal; ama `fit.loss_area == ""` ise (müşterinin baktığı hiçbir alan beklentinin altında değil) **zar atılmaz, %100** (`pq:234-236`). Erdem'in K8'indeki "en az %60 tabanı" için kodda aynı adlı sabit **bulunamadı**; sayısal eşleşme yalnız eğrinin U=55 noktasıdır, eğrinin tabanı %30'dur. Tabanı kaldırmak = `CLOSE_CURVE` ve `loss_area == ""` kısa devresinin birlikte yeniden tanımlanması (zar şimdi yalnız bir alan eksikken atılıyor; RAPOR_Q §3: masalı koşuda 328 kapanışta 0 kayıp).
Satışçı yıldızının kapanış ihtimaline/süreye/fiyata bağlanabileceği doğal noktalar: `close_chance(lead)` (`pq:233`, argüman `Prospect`; satıcı yıldızı için `rep` eklenir, çağıran tek yer `srep:240-241`), `deal_halfweeks` (zaten yıldız farkı okuyor), `_seats_for` (`srep:282`), `seat_price_anchor(stance)` (`sled:141`).

---

## 6. Durgunluk: ürün güncelleme almazsa bugün ne oluyor

**Sürüm kuralı.** Yalnız en az bir `feature`/`request` ya da hatası olan `fix` kartı biten sprint "sürüm" çıkarır (`sprint_system.gd:1459-1463`: `public = is_live and ship.any(releases)`; `research` ve hatasız `fix` sürüm yapmaz). Boş sprint mümkündür (`SprintSystem.skip`, `:278-283`; "kartsız başlayan sprint boş sprint", `:138-141`). Sürüm çıkınca `refresh_on_publish` (`product_state.gd:266-270`) sürüm yaşını sıfırlar ve ilgiyi 100'e çeker.

**Bugünkü tüm cezalar ve etkiler**

| # | Mekanik | Ne olur | Yer |
|---|---|---|---|
| 1 | **İlgi sönümü**: `100 × 0,5^(sürüm yaşı ÷ 4,29 tik)` | lead akışı çarpanı 1,3'ten 0,8'e iner (`interest_mult`); B2C kitle büyümesi aynı çarpanı okur. Taban 0,8: "akış kurumaz" | `support_system.gd:82`, `:322-326`, `sconst:22-25`, `:217-220`, `sfs:125`, `ss:194` |
| 2 | **Hata akışı sürer**: GELEN/gün = `0,1` (Ar-Ge `self_service` ile 0,07) × `(1 + aktif B2B hesap ÷ 80)` (B2C `1 + kitle ÷ 10.000`) × altyapı çarpanı; yeni kod terimi `0,03 × yeni_efor × e^(−yaş÷3)` sürümle söner | doğrulanmazsa açık hata birikir; bu hata **yalnız sprint `fix` kartıyla** temizlenir | `support_system.gd:33-44`, `:150-165` |
| 3 | **Hesap memnuniyet hedefi** açık hata başına −0,3 (tavan −20) | hesabın kullandığı alanların hatları | `b2bs:149-161`, `:171-178`, `b2bc:58-59` |
| 4 | **Günlük memnuniyet zararı** −0,6/10 gelen, −0,3/10 doğrulanmış hata, günlük tavan −2,0, B2B'de aktif hesaplara eşit bölünür (C3a'da kalkacak) | | `support_system.gd:62-69`, `:240-285` |
| 5 | **İhmal**: ≥ 30 maliyetli açık hata 4 hafta sürerse itibar her hafta −1 | | `support_system.gd:49-53`, `:288-300` |
| 6 | **B2C erime**: ürün kalitesi terimi eşiğin (25) altındaysa kitle erir; her açık hata payı | | `ss:70`, `:87`, `:212-218` |
| 7 | **Talepler**: `due_sprint ≤ last_closed` olan açık talep `status "late"`; **"late"i okuyan ceza bulunamadı** (tek geçiş `sb:30`) | | `sb:14-30` |
| 8 | **Söz** (oyuncunun verdiği): kırılırsa güven izi −12, marka −3; kendi yapısı, durgunlukla ilgisiz | | `b2bc:138-153`, `:263-268` |

**Cezası olmayanlar (bulunamadı)**
- Beklenti **zamana bağlı değil** (R5 §1): sürüm çıkmayan ürünün hesapları "eskidi" diye düşmez; `market_ref` imzada/yenilemede aynı tablodan kopyalanır, tablo sabit (`pq:118-129`, `sb:35-36`).
- Rakip çıkışı beklentiyi yalnız **adaya** (`rivals:true`) ve B2C ekonomisine +0,5/çıkış (tavan +1,0, 6 hafta) ekler, imzalı hesaba ulaşmaz (`pq:123-125`, `pq:206-207`). Durgunlukta rakip hızlanmaz, oyuncunun geride kalması bir mekanik değildir.
- Sözleşme bitiminde otomatik yenileme/ayrılma/zam/koltuk kararı yok (R5 §2.4); yenileme penceresi yalnız `market_ref` kopyalar ve bir talep açar (`sb:35-56`).
- `version_age` ve `interest` satış görüşmesinin **olgu sözlüğüne** girer (`sales_probes.gd:67-68`) ama okuyan katalog satırı bulunamadı; olay kartlarında `urun.version_age` yalnız `repeat_reminders` (`version_age == 1`) tarafından okunur, `urun.weeks_since_launch` ilk yayından bu yana zamanı ölçer (durgunluk değil: `launch_leak`, `paid_tier`, `copycat`, `shutdown_notice`, `b2c_floor_signal`, `sprint_dev_unasked_rewrite`).
- Müşterinin "standardın altı" okuması, "rakiplerde olan alan zayıf" şartı, yenilemede ayrılma: kodda **yok** (Erdem K1/K6/K7 yeni mekanik).
- Durgunlukta oyuncuya gösterilen: sürüm yaşı rozeti ("sürüm yaşı", `product_model.gd`, `sales_tab`), ilgi yarım ömrü ekranda bir sayı olarak değil; hesap satırında hiçbir "ürün eskiyor" nedeni yok.

**Sonuç (kod okumasından hesap):** sürüm çıkmayan ama hatası da çıkmayan ürün (az hesap, doğrulayan kişi var) yalnız lead hızını %38'e kadar (1,3 → 0,8) ve B2C büyümesini aynı oranda düşürür; B2B hesapların memnuniyeti bu yüzden düşmez. Bu, Erdem'in K7'sindeki "geliştirmesem de olur" yorumunun kodda bugün **doğru** olduğunu gösteriyor (ölçmedim; hesaplanmış çıkarım).

---

## 7. Bulunamadı listesi

- Sektörü doğrudan etiket olarak gösteren satış/hesap ekranı.
- `ProductCatalog.type_sector_labels` çağıranı (yalnız tanım ve smoke).
- Koltuk azaltan yol, yenilemede koltuk/yıldız/fiyat kararı, sözleşme sonu sonucu.
- Ürün, kart ya da Ar-Ge için yıl/dönem/tarih kilidi ya da tablosu.
- Rakip için çalışan sayısı, hat kademesi (Model A'da), Ar-Ge durumu, kart kuyruğu; dev rakip için çıkış kaydı.
- Satışçı yıldızının kapanış ihtimaline, fiyata, koltuğa bağı; "en az %60" adlı sabit.
- Gecikmiş (`late`) talebin okuyucusu/cezası; `version_age` ve `interest` olgularını okuyan görüşme sorusu.
- Ay/yıl okuyan ürün beklentisi (R5 §6 ile aynı).
- Müşteri sektörü ile rakip/Piyasa sektörü arasında eşleme.
