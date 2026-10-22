# Faz E planının incelemesi · Pazaryeri
İnceleyen: Opus (kıdemli inceleme), 2026-10-16. Okunanlar: `ERDEM_TUR2_YORUM.md`, karar defteri (Faz E ve sınırlar),
`ORTAK.md`, `E_GOREV.md`, `E_ARASTIRMA.md`, `E_PLAN.md`; `A_PLAN.md`, `B_PLAN.md`, `B_INCELEME.md`, `C_PLAN.md`,
`D_PLAN.md`; GDD ch01, ch03 (§3, §8, §10, §12.9–§12.11), ch13, Ar-Ge ve Satış GDD'leri (docx metni); `CLAUDE.md` §2, §5;
repo `1faeb82` (`left_tabs.gd`, `endgame_smoke.gd`, `game_state.gd`, `endings_copy.gd`, olay kartları, `time_model.gd`).
Repoda hiçbir dosya değişmedi. Uygulanan düzeltmeler `E_PLAN.md`'de "(inceleme)" işaretli (43 yer).

**Hüküm:** Plan sağlam ve kapsamı tam; ama ekonomi formülünde komisyonun uzun vadede geliri hiç değiştirmediği bir
yapı hatası vardı ve B'nin E'ye bıraktığı metinler planda yoktu. İkisi düzeltildi; 6 sahip sorusuyla onaya hazır.

---

## 1. Kapsam kontrolü (görevdeki 6 madde)
| Madde | Sonuç |
|---|---|
| Satış → "Pazaryeri" etiketi, yeni anahtar ve ikon, sıra aynı | ✔ `TAB_MARKETPLACE`, `rail/marketplace.svg`, sahne anahtarı `TAB_SALES` kalır, `rail_tabs_match_scene_order` yeşil kalır (vaka sahne yazısını okur, `_paint` değil). Eksik: adı değiştiren kolu tutan vaka yoktu → eklendi |
| Tek sayfa: mağazalar (aktif, katılan, ayrılan, memnuniyet), komisyon önizleme + Uygula | ✔ §2.4–§2.6. Kurgunun ana mekanizması formülde çalışmıyordu (bulgu 1, 2) → düzeltildi |
| Alıcılar (aktif, üye, ücretsiz), üyelik önizlemesi, üye oranı kaliteye bağlı | ✔ §2.7, §5.3; sayılar kendi içinde tutarlı (8,5 → 7,3; +$768 / −$343) |
| Gelir: komisyon, üyelik, toplam; bu ay, geçen ay, değişim; GMV; sepet ortalaması | ✔ §2.5, §5.5 |
| Satıcı istekleri ayrı | ✔ C'nin verisi; satıcı formülü eksikti → eklendi |
| Demo komisyon + üyelik; EA premium mağaza, reklam, paketler; mağaza puanı yok; lojistik yok | ✔ §5.9, §3.3 |
| Ekonomi ve tempo | Alıcı başına gelir eşleme makul (bulgu 4); %65 kuralı sessizce düşüyordu → soru 5 |
| Kapsam riski (not/video silme, şema) | Sorular var, bedelleri eksikti → eklendi; GDD girdileri eksikti → eklendi |
| Fazlar arası | §3 aşağıda; 14 uyuşmazlık, 11'i planda düzeltildi |
| Oyuncu metni | Tire yok, gerçek marka yok, araya giren değer ek almıyor, hüküm yok. Rakip adları ad taramasına bağlı (plan söylüyor) |
| Adım tablosu | Model seçimi doğru; Opus düzeltme hakkı ve yazım adımı eksikti → eklendi |

## 2. Bulgular
| # | Bulgu | Nerede | Düzeltme | Uygulandı mı |
|---|---|---|---|---|
| 1 | **Komisyon uzun vadede geliri değiştirmiyor.** `fee_mult = C_REF / c` (esneklik 1) dengede mağazayı komisyonla ters orantılı yapar; sipariş mağazayla orantılı olduğu için `c × fee_mult(c)` sabittir. %8–25 arası her oran aynı komisyon gelirini verir; artış yalnız büyümeyi ve memnuniyeti düşürür, "hasat" ~6 haftalık geçiştir. Erdem'in istediği "detaylı kurgu"nun takası yok | §5.2, §0, §2.6 | `fee_mult = (C_REF / c) ^ FEE_ELAST`, `FEE_ELAST` 0,5 [ÇALIŞMA]: %16'da dengede ~%26 fazla gelir, ~%21 az mağaza, daha yavaş büyüme. Önizleme sayıları yeniden hesaplandı (+%67 → +%29, −%17 → −%9, 3 ayda 14 mağaza korunur). E3 kapısına esneklik iddiası: `fee_high` 52. haftada komisyon geliri ≥ varsayılan +%10 | Evet |
| 2 | **Trafik toleransı modelde yok.** Plan toleransı "Satışlar" terimine yüklüyor; ama `sel_raw` < 1,2 iken mağaza başına sipariş yapı gereği ~68'de sabit. Büyük ve küçük pazaryeri aynı artışa aynı tepkiyi verir; araştırmanın ana bulgusu (Etsy, "paradoxical dependence") modele girmemiş | §5.2 madde 5, §2.6 | `tol(alıcı)` = clamp(1,6 − 0,2 × log2(alıcı/500), 0,6, 1,6); komisyon cezası ve sarsıntı `tol` ile çarpılır. 500 alıcıda 1,6, 12.400'de 0,67. §2.6 örnekleri yeniden yazıldı | Evet |
| 3 | Önizlemenin gelir satırı ("+$10.060") yalnız anlık farktır; 3 ay sonra mağaza kaybıyla yarısı geri gider. Tek sayı kalıcı kazanç gibi okunur; E5 kapısı da yalnız anlık sayıyı sınıyordu | §2.6, §6.5, E5 | İki sayı: "şimdi +$10.060, 3 ay sonra +$5.400"; `MKT_PREV_REVENUE` iki yer tutucu; E5 kapısı 13 haftalık akışla ±%10 | Evet |
| 4 | Tempo eşlemesi sağlam ama metin iki sayıyı eşit sanıyor ($4,4 ve $4,8). Ölçüye göre pazaryeri $4,65 (sel 0,965), bot tabanı $4,4: 52. haftada ~%5–15 fazla gelir; pencere kapısı bunu tutar | §0, §4 | §0 "$4,6–4,8 [ÇALIŞMA]" | Evet |
| 5 | İlan dönemi yolu hiç ölçülmüyor: bot Sepet ve Ödeme'yi hep MVP'ye koyar; "İlk gelir" ve Frank çeki o yolda geç kalabilir | §7 E3 | Yeni preset `full_run_b2c_listing` tohum 1–4, Frank çeki ≤ +6 hafta | Evet |
| 6 | `orders_in_hours` böleni ("ayın saati") tanımsız; örnek "3 saatte 225 sepet" kendi "saatte ~17" hesabıyla çelişiyor (17 × 3 = 52) | §2.9, §5.10 | Bölen 730; örnek 52 sepet. B'nin 212 sepetinin ~12 saate denk geldiği not edildi | Evet |
| 7 | **%65 kuralı planlayıcı kararıyla kalkıyor.** Görev yazısı ve eski PRD kuralı listeliyor; plan demoda %75–92 komisyon payını hedef yapıyor. Gerekçe makul (araştırma 3) ama sahip kararı | §4 sonu, §3.1 | Soru 5'e taşındı, bedeliyle | Evet |
| 8 | B'nin E'ye açıkça bıraktığı metinler planda yok: 5 hattın 20 yorumu ("Mağaza" kaynağı dahil), belirtiler, alıntılar, sprint ortası kâğıtların pazaryeri varyantları ve Erdem'in beğendiği "indirim kodu ve taksit" testçi kâğıdı | §6, §7 E6, §9 | Yeni §6.8; adım 6w (Opus, yüksek, 45 dk) yazar, E6 bağlar; E6 kapısına olay çekimi | Evet |
| 9 | Reddedilen "satıcı ödeme ikizi" Hakediş hattının belirtisiyle geri sızabilir | §6.8 | Açık yasak: Hakediş belirtisi ekran düzeyinde kalır | Evet |
| 10 | GUNCELLEMELER girdisi eksik: ch01 (2 B2C alt tip; Traction "paid tier live with paying users"), ch03 §3/§10 fiyatın tek evi, monitör alanları, §12.9 örneği, §12.10 çapası, ch13 B2C nüfusu, Ar-Ge GDD K3'leri ve ×1,15 dönüşüm | §7 E2, E3 | Liste E2 ve E3'e eklendi. CLAUDE §2: silme bağlı koda dokunuyor ve GDD'yi değiştiriyor; sahip kararı (S1, 2026-10-11) var, soru 1 teyit ister | Evet |
| 11 | `card_math_matches_gdd_example` ve §12.10 çapa vakası `line_note_tool_*` hatlarına sabit; E1 kapısında yeşil, E2 silmesinde kırılır, plan adlandırmıyor | §5.8, E2 | E2 iki vakayı pazaryeri hattına taşır (Siparişlerim K2 efor 8 Deneyim) | Evet |
| 12 | Son kâğıdı (ch13) B2C'de `paying_users` okur; pazaryerinde mağaza ve üye eksik kalır | §5.10 | Defterde `members`, `stores`; `endings_copy` B2C satırı; E3 | Evet |
| 13 | Ray etiket değişimini tutan vaka yok (sıra kilidi sahne yazısını okur) | E4 | `rail_label_follows_market`, falsifikasyonlu | Evet |
| 14 | `license_cost` ve öbür kademe alanları belirtilmemiş; yazılmazsa B2C servis gideri kalibrasyonu (ACIK 96) düşer | §5.8 | Not aracının kademe alanları aynı sırayla taşınır | Evet |
| 15 | Silme sonrası hedefli smoke listesi "sprint_* fikstür vakaları" gibi glob'la sayılıyor; parse hatasında ilgisiz vakaların PASS basma tuzağı (hafıza) | E1, E2, 0b | 0b vaka ad listesini çıkarır; E2'de `rg note_tool|video_clip` 0 satır kapısı | Evet |
| 16 | Adım tablosunda Opus'un düzeltme hakkı ve commit sahibi yazmıyor; "≤1 inceleme, ≤1 düzeltme" kuralı E3r'nin ayar turuyla ilişkilendirilmemiş | §9 | Not eklendi; Opus süresi 2,5 → 3,3 sa | Evet |
| 17 | Mağaza ayrılma eşiği `SAT_LEAVE` 40. Erdem B2B'de 40'ı "iddialı, 30 olmalı" buldu; mağaza aynı sistem değil ama aynı sezgi geçerli olabilir | §5.12 | Yalnız not: sabit zaten "onay bekliyor"; Erdem'e sunumda 35 alternatifi gösterilsin | Hayır (sahip) |
| 18 | E1 büyük (L, ~25 fikstür + 5 "core" okuması + ~100 anahtar). Bölmek mümkün ama E1→E2 sırası (önce taşı, sonra sil) güvenli ve E2'yi bayt-eş kapılı saf silme yapıyor | §7 | Değişiklik yok; risk planda yazılı | — |
| 19 | Üyelik ücreti değişince üye sayısı anında değişir (sürtünme yok). Araştırma "zam → üye kaybı olayı" diyor; demoda kabul edilebilir | §5.3 | Değişiklik yok; EA notu | — |

## 3. Fazlar arası uyuşmazlıklar
**A**
- A'nın okuma noktası `SprintCatalog.line_impact(hat) -> {users}` (B2C); E ayrı bir `MarketplaceSystem.affected(hat, pay)`
  öneriyordu ve "A'nın payı" diye olmayan bir şeyi varsayıyordu. → E, `line_impact`'in B2C kolunu besler; satıcı hattında
  `{stores}` döner. Yeni anahtar `PRODUCT_BUGS_TIP_STORES` (A'nın `PRODUCT_BUGS_TIP_B2C` ikizi). **Düzeltildi.**
- Hat başına açık hata `ProductState.open_bugs_by_line()` adıyla var; E §5.2 adlandırmıyordu. **Düzeltildi.**
- A, `urun.usage` çarpanını (1 + kitle/2000) "E ile gözden geçirilir" diye bıraktı; E sessizdi. → Alıcıda kalır. **Düzeltildi.**
- A şemayı 16 yapıyor (K3). E2'nin `MIN_LOADABLE_VERSION := SCHEMA_VERSION` kararı A'nın `save_v15_tickets_become_open_bugs`
  göçünü ve vakasını emekli eder. Soru 2'nin bedeline yazıldı.
- A'nın `PROBE B2C` satırına koyduğu `open_bugs=`, E3'ün `PROBE MKT`'sinde korunmalı. **Düzeltildi.**

**B**
- Ödeme olayı örnekleri tutmuyor: E "225 sepet / 3 saat", B "212 sepet"; E'nin akışında 12.580 sipariş/ay ≈ 17/saat.
  E düzeltildi (52). **B tazelemesine:** bu ölçekte kupon telafisi (52 × $40 × %15 ≈ $310) bedavaya yakın; B'nin kendi
  "bedava çıkış yok" gerekçesi geri döner. B seçenek bedelini `orders_in_hours` ile yeniden ölçmeli.
- B'nin iade ve özür formülü E'de "üye × üyelik ücreti" (B incelemesi notu); E §5.10'da satırı yoktu. **Düzeltildi.**
  Üyelik açılmamışsa iade seçeneği çıkmaz; B o durumda seçenek setini değiştirmeli.
- "Mağaza" yorum kaynağı, pazaryeri yorumları, belirtiler, alıntılar, pazaryeri sprint ortası kâğıtları ve testçi
  "indirim kodu ve taksit" kâğıdı B'den E'ye devredildi; E'de yoktu. **Düzeltildi (§6.8, adım 6w).**
- B'nin olaylarındaki gönderen şirket adları ("Ekol", "Arkas") gerçek; B incelemesi uydurma adlara çevrilmesini istedi.
  E planında gerçek şirket adı yok.

**C**
- İş satırı: C "Satış hacmi $193K · 184 mağaza", E "12.400 alıcı · 184 mağaza · Aylık gelir $57.650". Sayılar çelişiyor
  (184 mağazada E'nin hacmi $503K) ve C §2.9 MRR'yi ortak dil tutuyor. → E önerisi "MRR $57.650 · 12.400 alıcı · 184
  mağaza ›"; biçim C'nin. **E'de düzeltildi; C tazelemesinde C'nin örneği değişmeli.**
- C'nin `OV_BIZ_B2C` metni "MRR · dönüşüm %" pazaryerinde anlamsız; C'nin örneğindeki "dönüşüm %5" botun bugünkü %48–60
  ölçüsüyle de uyuşmuyor. → E6 metni değiştirir. **Düzeltildi.**
- Satıcı isteği birimi mağaza; formülü yoktu. → `mağaza × SELLER_ASK_RATE (0,15) × pay`, C'nin `b2c_asks()` ikizi. **Düzeltildi.**
- C "Onboarding" alanını "İlk Kullanım ve Erişim", Ar-Ge düğümünü "İlk Açılış Akışı" yapıyor; E'nin metinleri bu adları
  kullanmalı. **Not düşüldü.**
- Sunucu: C doluluğu ve aşımı kaldırıyor, birim 1.000 kullanıcı; E alıcıyı hizmet sayısı tutuyor. Uyumlu.
- Sprint kâğıdı C'nin; E iki kimlik alanı (Alıcı, Satıcı) ekliyor. C varsayımı olarak işaretli; C'nin düzeni iki kimlik
  alanını taşımalı.

**D**
- D kart puanını kademe × eksen tablosundan okur (×5: K1 15, K2 25, K3 40) ve `effort`/`shares`'i kaldırır. E §5.8'deki
  efor bantları D öncesi biçim. → "D varsayımı" eklendi; `marketplace.json` D'nin bıraktığı biçime uyar; Üyelik programı
  D'nin `need.paid_plan` (2/10/3) satırını kullanır. **Düzeltildi.**
- Yeni pazaryeri karar kâğıtlarının miktarları ×5 ölçekte yazılır. **Düzeltildi (§6.8).**
- D'nin göçü de E2'nin şema kırılmasıyla emekli olur (soru 2).

**Diğer**
- `sales.b2c_audience` okuyan dört kart E'nin metin taramasında yoktu (`portfolio_vendor`, `launch_leak`,
  `shutdown_notice`, `wiped_table`). **Düzeltildi.**
- Son kâğıdı (ch13) ve GDD girdileri: bulgu 10 ve 12.

## 4. Sahibe sorular (kapalı uçlu, önerili; planınkilerle birleşik, en çok 6)
1. **Not ve video uygulaması silinsin mi?** (Teyit: 11 Ekim'de "silinir" demiştin.) Bedeli: beş GDD güncellemesi, ~30
   smoke vakası taşınır, 112 metin anahtarı gider, B2C'de tek oynanabilir tür kalır. Evet ise B not/video'ya özel ~40
   metni yazmaz (B incelemesi soru 7). **Öneri: evet.**
2. **Eski kayıtlar açılmasın mı?** Bedeli: test kayıtların (ERP dahil) açılmaz; A ve D'nin aynı turda yazdığı göçler
   emekli olur. Alternatif yalnız not/video kayıtlarını reddetmek, ama ölü göç zincirini yaşatır. **Öneri: evet.**
3. **İlan dönemi kalsın mı?** (v1.0 Sepet ve Ödeme olmadan çıkabilir; komisyon o hat gelince başlar.) Bot bu yolu yeni
   preset'le ölçer. **Öneri: evet.**
4. **Komisyon artışında anında mağaza kaybı olmasın mı?** (Sarsıntı + giriş düşüşü + 40'ın altında hızlanan ayrılma;
   küçük pazaryerinde sert, büyükte yumuşak.) **Öneri: evet, anında kayıp yok.**
5. **"Tek gelir türü toplamın %65'ini geçmez" kuralı demoda kalksın mı?** Komisyon ~%87; üyelik ~%25'i geçemez. EA'da
   dört akımla geri gelir. **Öneri: evet.**
6. **Kara Cuma ve sezonlar Erken Erişim'e mi?** **Öneri: evet.**

## 5. Tek satır hüküm
Onaya hazır: düzeltilmiş komisyon esnekliği ve trafik toleransıyla ekonomi gerçek bir takas sunuyor; uygulamadan önce
0b tazelemesi A–D'nin gerçek adlarını ve B'nin kupon ölçeğini doğrulamalı.
