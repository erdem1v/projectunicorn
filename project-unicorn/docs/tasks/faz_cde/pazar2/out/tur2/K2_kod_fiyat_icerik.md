# K2 · Kod ve içerik maliyeti: fiyat, modül içeriği, ekran yükü, sektör, bilinen yol, sıralama (Pazar 2, tur 2)

Kök: `project-unicorn/`. Hiçbir oyun dosyası yazılmadı. Yöntem: K_kod_haritasi.md (HEAD e4e7e9b9) yeniden okundu; burada kullanılan her dosya:satır bugünkü çalışma ağacından yeniden bulundu.
Ağaç durumu: HEAD `3bc600f2`; ağaçta başka oturumların işlenmemiş değişiklikleri var (Faz C C4 "Kurumsal sunucu maddesi": `customer.gd`, `b2b_constants.gd`, `b2b_sales_system.gd`, `sales_meeting_adapter.gd`, `meeting_ruler.gd`, `inbox.gd`, `sprint.json`, `strings.csv` ve ~40 dosya daha). Satır numaraları bu yüzden kayıyor; her satır "dosya:sembol:satır" olarak verildi, satır en fazla birkaç onluk oynar.
Etiketler: (hesap) benim aritmetiğim · (kod) kodda okunan · (ölçülmedi) çalıştırılıp ölçülmedi · "bulunamadı" kodda ya da veride yok.

---

## ÖZET

1. **Bugünkü B2B fiyatı tek bir sabitten çıkıyor:** bant $30-70 (`sales_constants.gd:120-121`), orta $50 × duruş (rekabetçi 0,85 / standart 1 / premium 1,15; `STANCE_MULT` `:128`) = çapa $43 / $50 / $58 (`SalesLedger.seat_price_anchor`, `sales_ledger.gd:141`). Fiyat yıldıza, sektöre, modüle, koltuk sayısına, ürün seviyesine bağlı değil (kod).
2. **Oyuncu fiyatı neye göre belirliyor: hiçbir göstergeye göre.** Ekranda piyasa referansı, rakip fiyatı, ürün değeri yok; yalnız duruşun ipucu cümlesi ve cetvelde karşı tekliflerin ele verdiği gizli rezerv var (`negotiation_system.gd:128`). Rakip fiyatı veride yok (`rivals.json`, `companies.json`, `rival.gd` içinde fiyat alanı bulunamadı).
3. **Fiyat kararı üç yerde:** Satış sekmesi "Fiyat duruşu" düğmesi (`sales_tab.gd:219`, her zaman açık, bedelsiz), kurucunun kazandığı her görüşmenin 2. perdesi (cetvel, 2-4 sabır kutusu, `sales_constants.gd:136-137`), temsilcide karar yok (duruş işlem başında damgalanır, `sales_rep_system.gd:156`). Yenilemede, genişlemede, koltuk eklemede fiyat kararı yok.
4. **MRR = koltuk × imzadaki koltuk fiyatı, imzada damgalanır** (`sales_system.gd:359`); sonradan yalnız `expand` (aynı fiyatla koltuk, `b2b_sales_system.gd:437`) ve indirim (-%15, `apply_discount :410`) değiştirir. 5★ 1.000 koltuk × $50 = $50.000/ay (hesap): SENTEZ G11 tavanı (tek 5★ ≤ 20.000 $) bu çarpımla çelişir; hacim indirimi ya da bant yeniden kurulması gerekir.
5. **B2C fiyatı farklı:** ürün değerinden türer (`product_value`, `sales_system.gd:448`: 4 + 0,12·kalite + 0,75·açık hat + 0,375·kullanım ağırlığı, × eğilim) ve Ücretli plan kartı bir kez bu "optimal"i koyar (`sprint_bridges.gd:130`); sonrasında oyuncunun fiyat değiştireceği ekran bulunamadı (`estimate_price_change :500` çağıranı yok). B2C'de talep fiyata tepki verir (dönüşüm, büyüme); B2B'de kapanış ihtimali fiyata bağlı değil.
6. **Modül eki + hacim indirimi maliyeti:** 13 kod dosyası, ~140-190 satır, 8 CSV satırı, ~35 smoke noktası; zorluk **orta**. Fiyat formülünün kendisi kolay (≈30 satır); pahalı olan hesap kaydında modül listesi (zaten modül tasarımının önkoşulu), teklif panelinde 4. satır (`meeting_ruler.gd` 3 sabit etiket) ve şema 19 göçüdür.
7. **İçerik bedeli (bir kademe):** 2 CSV satırı (ad + açıklama; TR ve EN aynı satırda) + 1 JSON step kaydı (~10 satır). Kademe kartı dosya olarak yok, `SprintCatalog.candidates` türetir. Yeni Ar-Ge düğümü gerekmez; smoke'ta kademe başına kayıt 0, ama 9 yerde "27 kademe / 3 kademe / profil 3-3-3" sabiti kodlu.
8. **Bir modül (K kademe) = 1 + 2K satır.** Hepsi yeni yazılırsa (TR = EN satır sayısı): **N=5: 105 (K10) / 125 (K12); N=7: 147 / 175; N=10: 210 / 250.** TR sözcük ≈ 133,5·N (K10) / 159,9·N (K12); EN ≈ 187,4·N / 224,6·N. Stok ve Fatura'nın bugünkü 3 kademe metni aynen kalırsa her sayıdan 14 satır düşer. Bugün ERP için 59 satır var (35 kimlik hattı + 24 paylaşılan).
9. **Kademe kartı sayısı:** bugün 27 (15 + 12); N×K: N5 50/60, N7 70/84, N10 100/120 (+ platform 4 hat: 12 sabit, ya da 40/48 uzarsa).
10. **Doğrulayıcı üç sabiti kırar:** `TIER_MAX := 3` (`product_lines.gd:20`), `EFFORT_BANDS` yalnız k1-k3 (`:23`), "Ar-Ge düğümü her K3'te ve yalnız K3'te" (`:246`); ayrıca `IDENTITY_LINE_COUNT 5`, `IDENTITY_PROFILE_SHAPE 2/1/2`, `LINES_PER_SUBTYPE 9` (`:39-41`) ve `steps_raw.size() != TIER_MAX` (`:155`). `step_effort` `cfg("effort.k%d")` ile k4'te hata verir (`sprint_catalog.gd:175`). TIER_MAX küresel kalırsa not_tool ve video_clip için ek **196 (K10) / 252 (K12)** CSV satırı gerekir; kademe sayısı hat başına değişken yapılırsa 0.
11. **Ar-Ge:** 19 düğümün yalnız 12'si kök/dal (kademe kapısı olabilir: `research_seam.gd:87-89`); 14 K3 (10 modül + 4 platform) 12 uygun düğüme düşer, ERP bugün 7'sini kullanıyor ve iki çift paylaşıyor. Yeni düğüm şart değil; her yeni düğüm = 1 JSON + 2 CSV.
12. **GDD mühürü:** "9 hat × 3 kademe = 27" ve "hat başına 3/3/3 profil" GDD ÜRÜN rev 6 §12.1-12.2 olarak smoke'ta sabit (`endgame_smoke.gd:14983-14991`, `:15978`); değişiklik GDD'ye yazılmalı, CLAUDE.md §2 gereği sahibin kararı.
13. **Ekran yükü:** 4 ekran sığar (Ürün sekmesi, hesap listesi, aday listesi, haber şeridi; kaydırma var), 2 ekran kod değişikliği ister: **teklif paneli** (3 sabit etiket, `meeting_ruler.gd:20-22,119-122`) ve **hesap kartı** (tek metin satırı, 5-10 modül çipi sığmaz, ayrı HFlow satırı gerekir). **HESAPLAR tablosu henüz yok**; hesap kartı listesi sayfalamasız ve sınırsız.
14. **Ürün sekmesi:** Çekirdek alanı 10 modülde ≤21 aday kart (10 özellik + 10 düzeltme + 1 araştırma) gösterir; 430 px'lik sütun dikey kaydırır (`product_tab.gd:64-66`); Çeyrek görünümü (280 px) yalnız alan satırı gösterir, etkilenmez. Sprint başına kart sayısı ekibe bağlı, modüle değil.
15. **GENEL BAKIŞ kâğıdının sol sütunu boş** (`overview_view.gd`: yalnız sağ sütun Sunucu bloğu çizer); modül/standart tablosu için hazır yer.
16. **Sektör:** 13 kimliği 16 dosya okur (~40 çağrı noktası, 156 smoke çağrısı). `ProductQuality.TABLE` sektör ağırlığını kaldırmak `product_quality.gd`'nin ~12 fonksiyonunu (394 satırın ~%40'ı) yeniden yazar; metin kanalı (13 ad havuzu, 39 CSV satırı SECTOR/B2B_CONTACT/B2B_COMPLAINT, gece kesintisi, depo kâğıdı) etkilenmez. Sektör profili tablosu (7×10 = 70 hücre) veridir, metin gerektirmez.
17. **Performans riski:** hesap başına `account_fit` her tik her hesap için çağrılır (`b2b_sales_system.gd:151-159`); C1 commit'inde gece tiki 146,36 ms, kapı 148,2 ms (marj 1,84 ms, %1,2). Modül bazlı uyum hesabı alan sayısından (4) modül sayısına (5-10) çıkarsa kapıya çarpabilir (ölçülmedi).
18. **Bilinen yol (soru 10):** tek giriş var: `SprintCatalog.step_effort` (`sprint_catalog.gd:171`); ~15 satır. Tuzaklar: (a) kart eforu `new_card` ile damgalanır ve saklı kart eski eforda kalır (`candidates :233`); (b) efor tamsayı: K1 3 → ×0,8 → 2 (-%33), K2 5 → 4 (-%20), K3 8 → 6 (-%25); (c) `design_system` -%20'si kartta hiçbir gerekçe satırıyla gösterilmiyor (`sprint_card.gd:306-315`), bilinen yol indirimi de gösterilmeli.
19. **Rakip yayın bilgisi bugün erişilebilir ama dar:** yalnız `rivals.json` (3 startup) + `GameState.product.rival_hits`; `_rival_tier` özel (`sprint_catalog.gd:708`). `RivalRegistry` (Model A) hat/kademe taşımaz. "En az iki şirket" hesabı bugün 3 rakipte 2 demektir; dev ve yerleşikler çıkış tablosunda yok.
20. **Sıralama kancaları:** (a) haber şeridi: `EventBus.headline_added` (Biz satırı, %20 sert kapı) ve `ticker_live_line` (kotasız, tek satır); haftalık akış 3-5 satır (`news_feed_system.gd:40-41`), canlı pencere 6 (`news_ticker.gd:51`). (b) Gelen kutusu: `MessageSystem.post`, kapasite 50 (`message_system.gd:14`); yeni posta türü 3 dosya ister (`message_system`, `mail_pane :134`, `inbox :17,:280`). (c) yıllık: `SummarySystem.begin_day :57` "yearly" yalnız oyuncunun seçtiği sıklıksa; sabit yıllık rapor için `month_turned and month == 1` ayrıca dinlenmeli. (d) ayın öne çıkanı `submit_month_highlight :429` (öncelik 50). (e) puanın yazılacağı yer: sürüm kaydı `release` sözlüğü (`sprint_system.gd:1493-1499`), `GameState.product.releases` içinde kaydolur, anahtar eklemek şema göçü istemez.
21. **Marka ve itibar B2B lead akışını bugün sürmüyor:** `lead_rate_per_week` yalnız temsilci sayısı × ilgi (`interest_mult` 0,8-1,3) × evre okur (`sales_faucet_system.gd:120-126`); `GameState.brand/reputation` B2C kitle büyümesini (`sales_system.gd:191-192`), VC dönüşümünü ve sonları sürer. "Yılın ürünü" B2B lead'ine etki edecekse çarpan `lead_rate_per_week` içine tek satır girer.
22. Bulunamadı: B2B fiyatına bağlı kapanış zarı, piyasa/rakip fiyat verisi, hesap başına modül listesi, yenilemede fiyat/koltuk kararı, B2C fiyat değiştirme ekranı, kademe başına smoke kaydı, sektör etiketini gösteren ekran (K haritası ile aynı).

---

## 1. FİYAT (Erdem soru 8)

### 1.1 Bugünkü B2B fiyatı: zincir

| Halka | Ne yapıyor | Yer |
|---|---|---|
| Bant | Koltuk fiyatı bandı $30-70, tek bant, yıldıza/sektöre/modüle bağlı değil | `sales_constants.gd:120-121` (`SEAT_PRICE_MIN/MAX`) |
| Orta ve duruş | Çapa = orta ($50) × `STANCE_MULT` {rekabetçi 0,85, standart 1,0, premium 1,15} → $43 / $50 / $58 (yuvarlanmış) | `sales_constants.gd:128-132`, `:239 stance_mult`; `sales_ledger.gd:141-144 seat_price_anchor` |
| Duruşun sahibi | Tek bayrak `sales_price_stance`; yazar `SalesLedger.set_price_stance` (olay `price_stance_changed`) | `sales_ledger.gd:126-135`, `game_state.gd:93`, `event_bus.gd:226` |
| Okuyanlar (5) | (1) kurucu masası cetveli çapası, (2) temsilcinin kapanış fiyatı, (3) hat tahmini (`pipeline_optimistic_mrr`), (4) görüşme iğnesine ±0,10 (`W_PRICE_SIGNAL`), (5) kayıp nedeni "fiyat" engeli yalnız duruş rekabetçiyse açılır | `negotiation_system.gd:111`; `sales_rep_system.gd:265`; `sales_system.gd:309-319`; `sales_meeting_system.gd:150-154` + `sales_constants.gd:80`; `sales_ledger.gd:361-362` |
| Masada | Çapa bant içine sıkıştırılır; gizli rezerv = çapa × arketip hassasiyeti (0,82-1,18) × tohum (0,94-1,06), balina ×0,9; hakaret eşiği rezerv × (1 + 0,28); karşı teklif adımı %6-16 | `negotiation_system.gd:111-134,183-185`, `sales_constants.gd:138-142` |
| Koltuk | Pazarlık edilmez; yıldız bandı: 1★ 5-10, 2★ 15-30, 3★ 40-70, içinde hash'li yer | `sales_constants.gd:115-119`, `negotiation_system.gd:103-107`, `sales_rep_system.gd:282-286` |
| İmza | `add_b2b_customer(prospect, seats, seat_price, ...)`: `c.seat_price = seat_price`, `c.mrr = seats × seat_price` | `sales_system.gd:343-359` |
| Yazan yollar | Masa: `SalesFinalizer._open_deal` terimleri lead'e yazar (`deal_seats`, `deal_price`), plan bitince `sign_deal`; temsilci: `_close` | `sales_finalizer.gd:66-81,84-108`; `sales_rep_system.gd:258-274` |

Temsilcide duruşun tek yan etkisi: premium işleme süresini +%30 uzatır (`PROCESS_PREMIUM_PENALTY`, `sales_constants.gd:156`, `sales_rep_system.gd:171-172`) ve duyarlı arketipte fiyat kırma olayı (`:220-233`). Kapanış ihtimali (`close_chance`) duruşu okumaz (`product_quality.gd:233`): temsilcide rekabetçi fiyat ek kapanış getirmez. Masada duruş yalnız çapayı ve iğneyi (±0,10) oynatır.
Hesap (kod sabitlerinden): temsilci işlem süresine bölünmüş fiyat: premium 1,15/1,30 = 0,885, standart 1,0, rekabetçi 0,85; yani süre kısıtında standart baskındır. Bunu bir bulgu olarak yazıyorum, ölçmedim.

### 1.2 Oyuncu nerede, ne sıklıkta karar veriyor

| Ekran | Karar | Sıklık (kod) |
|---|---|---|
| Satış sekmesi, "Fiyat duruşu" 3'lü seçici + ipucu cümlesi (`sales_tab.gd:219-227`) | 3 konum | İstediğinde; bedelsiz, kilitsiz, bekleme yok (`set_price_stance :131-135`) |
| Görüşme paneli, 2. perde cetveli (`sales_meeting_adapter.gd:194-216 _open_table`, `meeting_ruler.gd`) | $30-70 arası serbest fiyat, sabır kutusu kadar teklif (2-4; balinada -1), karşı teklifi kabul/ret | Kurucunun kazandığı her görüşme |
| Temsilci planı | Karar yok: duruş işlem başında damgalanır, temsilci o duruşun çapasından kapatır (`sales_rep_system.gd:156,265`) | Lead başına 0 karar |
| Genişleme / yenileme / koltuk | Karar yok: hesabın kendi `seat_price`'ı (`b2b_sales_system.gd:437-455`); yenilemede fiyat/koltuk sonucu yok (K haritası §2.1 ile aynı) | 0 |
| Retention indirimi | "İndirim ver": MRR -%15, hesap başına en çok 2 (`b2b_constants.gd:79,81`, `apply_discount`) | Risk'teki hesapta olay kartı |

Oyuncu telemetrisi/sıklık verisi bulunamadı; yukarıdaki "sıklık" kodun izin verdiğidir.

### 1.3 MRR ve kayıt

- Toplam: `CustomerRegistry.get_total_mrr` aktif hesapların `mrr` toplamı (`customer_registry.gd:58-63`); `SalesSystem.reflect_mrr` onu `GameState.mrr`'a yazar (`sales_system.gd:166-169`). Yazan tek kapı `CustomerRegistry.set_mrr` (`:131-140`).
- Müşteri kaydı: `Customer.seats`, `mrr`, `seat_price` (imza damgası), `signing_discount` (şu an bağlı değil: finalizer yorumu "DESIGN-PARKED", `sales_finalizer.gd:85-90`; ekranda "imza indirimi %N" `sales_tab.gd:574-575` var) (`customer.gd:24-25,86-89`).
- Hesap kartı fiyatı: `mrr / koltuk` olarak yeniden hesaplanır (`sales_tab.gd:565-578 _meta_line`), yani indirim görünür.
- `B2BConstants.EXPANSION_PER_SEAT_MRR := 120` (`:210`) yalnız `seat_price == 0` olan eski kayıt/fikstür içindir (`expand :437`, `effects.gd` b2b_expand fiili, `chips.gd:227`).

### 1.4 B2C karşılaştırma

| | B2B | B2C |
|---|---|---|
| Fiyat kaynağı | duruş × $50 bandı, oyuncu cetvelde oynar | ürün değeri: `(4 + 0,12·kalite + 0,75·açık hat + 0,375·kullanım ağırlığı) × eğilim (premium 1,35 / nötr 1 / hacim 0,8)` (`sales_system.gd:98-105,448-457`) |
| Kim koyar | oyuncu, her görüşmede | Ücretli plan kartı bir kez `product_value().optimal` (`sprint_bridges.gd:130-132`) |
| Sonradan değiştirme | yeni imzada serbest, eski hesap sabit | ekran bulunamadı; `apply_b2c_price :516` yalnız `open_paid_plan` çağırıyor, `estimate_price_change :500` çağıranı yok |
| Talebin tepkisi | rezerv + sabır (masada); kapanış zarında fiyat yok | dönüşüm `0,35 × optimal/fiyat`, [0,02; 0,60]; büyüme çarpanı [0,4; 1,8]; zam tepkisi (`sales_system.gd:109-124,467,479,490`) |
| MRR | koltuk × fiyat, imzada sabit | ödeyen × fiyat, her saat türetilir (`:227-234`) |

Soru 8 için çıkarım: ürün değerini fiyata bağlayan mekanik kodda B2C'de zaten var ve `product_value` formülü kademe genişliği/derinliği (`lines_open`, `usage_weight_total`) okuyor; B2B "referans koltuk fiyatı" için aynı fikir yeniden kullanılabilir, ama sabitler B2C'ye kalibre ($4-13 bandı), B2B için yeniden kalibre edilmeli.

### 1.5 Rakip fiyatı ve referans fiyat

- `rivals.json`: hat kademeleri ve çıkış tablosu var, **fiyat alanı yok**. `rival.gd`, `rival_catalog.gd`, `companies.json` (Piyasa: hisse fiyatı/değer; `piyasa_tab.gd:309` "price" şirket değeridir, ürün fiyatı değil) içinde ürün fiyatı **bulunamadı**.
- Oyuncuya piyasa referans koltuk fiyatı gösteren ekran **bulunamadı**. Sales sekmesi ve cetvel yalnız kendi çapasını ve karşı teklifleri gösterir.

### 1.6 Modül başına fiyat satırı (taban paket + modül eki) ve hacim indirimi: dokunulan yerler

Varsayım: hesapta/adayda modül listesi (başka iş) bulunur; burada yalnız fiyat için gereken.

| # | Dosya:sembol | Değişiklik | Satır (yaklaşık) |
|---|---|---|---|
| 1 | `sales_constants.gd:115-133` | `MODULE_ADD` (taban paketin yüzdesi ya da $), `VOLUME_TIERS` (koltuk eşikleri → iskonto), 2 yardımcı; 4-5★ için `SEAT_BAND` genişler (bu zaten yıldız 5'e geçişin işi) | +20 |
| 2 | `sales_ledger.gd:141 seat_price_anchor` | `(stance, modules, seats)`; 4 çağıran (`negotiation_system.gd:111`, `sales_system.gd:314`, `sales_rep_system.gd:265`, `main.gd:1419`) | +10 |
| 3 | `negotiation_system.gd:91 open / :237 view_state` | bağlama `modules`; `confirm` bloğuna taban, modül eki, iskonto | +20 |
| 4 | `sales_meeting_adapter.gd:302 _deal` | modül/iskonto satırı | +4 |
| 5 | `meeting_ruler.gd:20-22,102-105,119-122` | **4. etiket**: bugün üç sabit etiket (MRR, kapasite, C4'ün "madde" satırı) | +5 |
| 6 | `sales_system.gd:343-413 add_b2b_customer` | `modules`, iskonto; `:359` MRR formülü; `:309 pipeline_optimistic_mrr` | +12 |
| 7 | `sales_finalizer.gd:66-108`, `sales_rep_system.gd:258-274` | modül listesini terimlere taşı | +8 |
| 8 | `customer.gd` (+2 alan), `prospect.gd:48-52` (+1-2 alan) | `modules`, `volume_discount` (ya da mevcut `signing_discount`'ı iskonto olarak kullan) | +6 |
| 9 | `b2b_sales_system.gd:437 expand` + yeni `add_module` | koltuk eşik geçince fiyat düşer; "yeni modül = genişleme" yeni fonksiyon | +30 |
| 10 | `effects.gd:255-267,643-652` (b2b_expand fiili), `chips.gd:227` | modül ekleyen fiil ve çip önizlemesi | +14 |
| 11 | `sales_tab.gd:323-372 _lead_card`, `:565 _meta_line` | modül satırı, iskonto | +8 |
| 12 | `save_manager.gd` (şema 18 → 19) | eski hesaplara modül listesi türet, `_migrate_*` kalıbı (`:626,:969`) | +20 |
| 13 | `strings.csv` | NEG/SALES fiyat satırı şablonları, duruş ipucu (`SALES_STANCE_HINT_*` "bandın ortasında" 3 satır güncellenir) | 8 satır |

Toplam: **13 kod dosyası + CSV, ~140-190 satır, smoke'ta ~35 nokta** (bugün fiyat/duruş/bant/`add_b2b_customer`/`NegotiationSystem` için `endgame_smoke.gd` 15 + 8 + 3 + 3 + 9, `run_probe.gd` 5 + 4 geçiş). Zorluk: **kolay** (yalnız formül, ≈30 satır) / **orta** (modül listesi hazırken, 13 dosya) / **orta-zor** (modül listesi ve şema göçü birlikte).

Eski fiyat kodundan silinen/değişen: `SEAT_PRICE_MIN/MAX` tek bandı (yıldız/modül bandına dönüşür); `seat_price_anchor`'ın "orta × duruş" gövdesi; "kadran B2B fiyatının TEK kaynağıdır" yorumları (`sales_constants.gd:123`, `sales_ledger.gd:123,138`, `sales_system.gd:310-312`, `game_state.gd:93`); `pipeline_optimistic_mrr` band-orta × çapa formülü; `SALES_STANCE_HINT_*` 3 metin. `STANCE_MULT`, `EXPANSION_PER_SEAT_MRR` (eski kayıt) ve `apply_discount` kalır.

### 1.7 Soru 8'in "oyuncu neye göre belirler" kısmı için kod maliyeti

| Seçenek | Ne gerekir | Maliyet |
|---|---|---|
| A. Bugünkü gibi (referans yok) | 0 | 0 |
| B. Ürün-değeri referansı (B2C `product_value` kalıbı) | `reference_seat_price(modules, star)` + teklif panelinde 1 satır "Ürününüzün referans değeri" + CSV 2-3 satır | ~25 satır, 3 dosya (orta-kolay); sabit kalibrasyonu sim işi |
| C. Rakip/piyasa fiyatı referansı | `rivals.json` ya da dönem tablosuna fiyat alanı (yeni veri, kaynak sorunu), ekran satırı | veri yazımı + ~20 satır; veri kaynağı **bulunamadı** (Faz C araştırmasında B2B ERP koltuk fiyatı için yalnız Business Central 80/110/8 $ doğrulanmıştı [V #9], 2012 dönemi fiyatı yok) |
| D. Fiyatın kapanışa bağlanması (temsilcide) | `close_chance(p)` imzasına duruş/fiyat; çağıran tek yer `sales_rep_system.gd:241` | ~10 satır (kolay); masada fiyat zaten rezervle etkili |

---

## 2. İÇERİK BEDELİ (Erdem soru 2: 5 / 7 / 10 modül)

### 2.1 Bugün bir hat kademesi neye mal oluyor (örnek: `line_erp_stock`)

| Parça | Say | Yer |
|---|---|---|
| Tanım | 3 step kaydı (`id`, `effort`, `usage_weight`, `requires`; ~10 JSON satırı/step) | `data/product/lines/erp.json` (170 satır, 15 step); step eforu 5-6 / 7-8 / 9-11, `EFFORT_BANDS` (`product_lines.gd:23`) |
| Hat adı | 1 CSV anahtarı | `PROD_LINE_ERP_STOCK` ("Stok" / "Stock") |
| Kademe adı | 3 | `PROD_STEP_ERP_STOCK_K1..K3` (Stok Sayacı, Depo ve Raf, El Terminali) |
| Kademe açıklaması | 3 | `PROD_STEP_ERP_STOCK_K1..K3_DESC` |
| Kart | 0 dosya | kart `SprintCatalog.candidates` ile her kademe için türetilir (`sprint_catalog.gd:198`); efor `sprint.json` `effort {k1:3, k2:5, k3:8}` (`:6`, `step_effort :171`) |
| Ar-Ge | K3'te 1 düğüm referansı (`design_system`); yeni düğüm gerekmez | `erp.json` step `requires.research`; 19 düğüm `research_seam.gd:22-42` |
| Kağıtlar (opsiyonel) | satıra özel karar kâğıdı: 3 (`sprint_test_stock_transfer`, `sprint_design_gloves`, `sprint_dev_import_tool`...) | JSON, kâğıt başına ~6 metin × 2 dil |
| Rakip tablosu | `rivals.json` `tiers` 1 satır + çıkış satırları | `rivals.json:65,77`; SENTEZ §8 bunu rakip simülasyonuyla değiştirir |
| Fikstür/smoke | `line_erp_stock` ağaçta 13 smoke, 2 `main.gd` geçişi; **kademe başına yeni kayıt 0** | generik döngüler (`product_lines_catalog_loads :14961`, `loc_product_line_keys_resolve :15892`) |
| Diğer listeler | `sprint.json` `incident.regression.b2b` (7 hat), `month_close.lines` (3 hat), `storm`, `areas[].lines` | `sprint.json:64,67-68,73,131-137` |

**27 kademe kartı bugün hangi dosyalarda:** tanım `erp.json` (15) + `shared.json` (12; her alt-tür aynı iskeleti kullanır, kapı farkı `shared_gate_overrides`); metin `strings.csv` `PROD_STEP_ERP_*` (30 satır) + `PROD_STEP_SHARED_*` (ad 12 + ERP açıklaması 12; not_tool ve video_clip için 12'şer açıklama daha); kart yok. 2 yan alt-tür ayrıca 30'ar kademe taşır.

Ortalama metin uzunluğu (strings.csv'den ölçüldü): kademe adı TR 2,2 / EN 2,2 sözcük; kademe açıklaması TR 11,0 / EN 16,4 (ERP kimlik), TR 10,5 / EN 17,8 (paylaşılan); hat adı TR 1,5 / EN 1,35.
Yani bir kademe: TR 13,2 sözcük, EN 18,6 sözcük.

### 2.2 Formül

- Bir kimlik modülü (K kademe), hepsi yeni: **R(K) = 1 + 2K** CSV satırı (1 hat adı, K ad, K açıklama). Her satır bir TR ve bir EN metni taşır; TR ve EN yazım sayısı eşit, ayrı adımlardır (CLAUDE.md §5: önce EN, TR ayrı).
- Sözcük: TR ≈ 1,5 + 13,2·K, EN ≈ 1,4 + 18,6·K (modül başına).
- Toplam (A, hepsi yeni): **N × (1 + 2K)**.
- B: bugünkü Stok ve Fatura'nın 3 kademe metni aynen kalırsa (diğer üç hat anlam değiştirdiği için yeniden yazılır): A − 2 × (1 + 2·3) = **A − 14**.
- Kademe kartı sayısı (kod türetir, içerik değil): N × K.
- Platform hatları (4) K'ya uzarsa yalnız ERP için: 4 × (K−3) × 2 = **56 (K10) / 72 (K12)** satır (ad paylaşılan, açıklama ERP'ye özgü).
- `TIER_MAX` küresel kalırsa (hat başına değişken yapılmazsa) not_tool ve video_clip için: 2 × 14 × (K−3) = **196 (K10) / 252 (K12)** satır, ve bunlar ERP'ye değer katmaz.

### 2.3 Sayılar (yeni CSV satırı; TR satır = EN satır)

| | K=10 A | K=10 B | K=12 A | K=12 B |
|---|---|---|---|---|
| N=5 | **105** | 91 | **125** | 111 |
| N=7 | **147** | 133 | **175** | 161 |
| N=10 | **210** | 196 | **250** | 236 |

Sözcük (A, TR / EN):

| | K=10 | K=12 |
|---|---|---|
| N=5 | 668 / 937 | 800 / 1.123 |
| N=7 | 935 / 1.312 | 1.119 / 1.572 |
| N=10 | 1.335 / 1.874 | 1.599 / 2.246 |

Karşılaştırma: bugün ERP 59 satır (35 kimlik + 24 paylaşılan); strings.csv toplam 3.344 satır.
Kademe kartı (türetilen): N5 50 / 60, N7 70 / 84, N10 100 / 120 (K10 / K12); platform 4 hat için +12 (K3'te kalırsa) ya da +40 / +48.
JSON: N × K step kaydı, ~10 satır her biri: N7/K10 ≈ 700 satır `erp.json`.

### 2.4 Kademe dışı ek içerik (çoğu varsayım, etiketli)

| Kalem | Say | Dayanak |
|---|---|---|
| Hat adı + kademe adı/açıklama | formülde | |
| Görüşme "önemli modül" sorusu | N soru satırı ya da 1 şablon `{module}` (bugün 3 soru: `SALES_PROBE_PROBE_EMPHASIS_TRUST/INTEGRATIONS/ONBOARDING`, cevaplar 3 ortak anahtar `SALES_ANS_PROBE_EMPHASIS_A_*`), katalog satırı N × ~8 kod satırı (`sales_probes.gd:141 CATALOGUE`) | kod |
| "İstediği modüller" etiket seti | 4 durum sözcüğü + "önemli" + satır başlığı = **6** | SENTEZ §3.2 |
| Profil adı (aday kartında profil gösterilecekse) | 0 ya da 7 (13 sektör adı `SECTOR_*` zaten var) | |
| Satıra özel kâğıt (opsiyonel) | modül başına 1 kâğıt ≈ 6 TR + 6 EN metin; bugün 17 / 44 kâğıt satıra bağlı, 7'si ERP kimlik hattına (`sprint_design_color_blind`, `sprint_design_gloves`, `sprint_dev_import_tool`, `sprint_dev_multi_currency`, `sprint_test_after_midnight`, `sprint_test_readonly_delete`, `sprint_test_stock_transfer`) | `data/events/cards/product/` |
| İstek/şart cümlesi (`{module}` şablonu) | 4-8 | SENTEZ §7 |
| Rakip sürüm haberi | şablon zaten genel (`PRODUCT_NEWS_RIVAL_LAUNCH_%d`, `{rival}`, `{capability}`; 2 varyant, `sprint.json:80`) → modül başına 0; çeşitlilik için +2 | `sprint_bridges.gd:82-91` |
| Sektör raporu maili (yıllık) | ≈ 6 | SENTEZ §15 soru 4 B |
| Medya puanı / yılın ürünü / liste | puan sözcüğü 5 kademe × 2 yayın varyantı = 10, ödül 2-3, liste 4-6 → **≈ 16-19** | tahmin |

Ek içerik toplamı (sektör profili 6-13 + haber/sıralama 24-27 + istek 4-8 + opsiyonel kâğıt N × 12 metin): **yaklaşık 45-60 satır + (0 .. 12·N metin)**, hepsi tahmin; N, K'ya bağlı değildir.

### 2.5 Doğrulayıcı ve smoke sabitleri (içerik büyürken kırılan yerler)

| Yer | Sabit | Yapılacak |
|---|---|---|
| `product_lines.gd:20` | `TIER_MAX := 3` | hat başına kademe sayısı (3-12) |
| `product_lines.gd:23`, `:215` | `EFFORT_BANDS` yalnız k1-k3; `_validate_step` `EFFORT_BANDS[kano]` k4'te çöker | bant tablosu genişler ya da formül |
| `product_lines.gd:246` | "Ar-Ge düğümü her K3'te ve yalnız K3'te" | kapı kuralı yeniden yazılır |
| `product_lines.gd:39-41,107,119,133` | `IDENTITY_PROFILE_SHAPE {dev 2, test 1, design 2}`, `IDENTITY_LINE_COUNT 5`, `LINES_PER_SUBTYPE 9` | N modüle göre |
| `product_lines.gd:191-198` | paylaşılan hat K3 bağı `step_ids[2]` | K3 indeksi |
| `sprint_catalog.gd:175` | `cfg("effort.k%d")`; `sprint.json:6` yalnız k1-k3 (+research) | k4..k12 anahtarı ya da formül |
| `sprint_catalog.gd:652`, `sprint_system.gd:1446` | `max_tier` = `TIER_MAX`, "tier >= TIER_MAX → hat tamamlandı" sinyalleri | hat başına |
| `product_state.gd:90` | `clampi(tier, 0, TIER_MAX)` | hat başına |
| `endgame_smoke.gd:14983,14988,14991` | profil 3/3/3, `[1,2,3]` döngü, `steps != 27` | yeniden yaz |
| `endgame_smoke.gd:15260,15267,15303,15908,15966,15978` | `[1,2,3]` kademe döngüleri, `visible != 27` | yeniden yaz |
| `run_probe.gd:1548` | `range(1, TIER_MAX + 1)` | uyumlu |
| Ar-Ge bağı | 19 düğümün yalnız 12'si kök/dal ve kademe kapısı olabilir (`research_seam.gd:87-89`: capability 3, platform 3, practice 3, design 3). 14 K3 (10 modül + 4 platform) bu 12 düğüme düşer; ERP bugün 7 düğüm kullanıyor (`analytics_engine`, `semantic_index`, `bug_tracker`, `design_system` ×2, `scalable_backend` ×2, `data_model`, `security_cert`). Yeni düğüm = 1 `rnd_tree.json` girdisi + 2 CSV satırı (`PROD_RND_NODE_*_DESC/_UNLOCK`, TR ~10 / EN ~14 sözcük) + `research_seam` eşlemesi | |
| Kayıt | `line_tier` anahtarları hat kimliğiyle saklanır; hat adı değişir/birleşirse (Defter+Nakit Akışı → Finans) eski kayıt için şema 19 göçü şart | `save_manager.gd` |
| GDD | "9 hat × 3 kademe = 27", "3 hat/profil" GDD ÜRÜN rev 6 §12.1-12.2'ye atıfla smoke'ta mühürlü | sahip kararı, GDD'ye yazılmalı |
| Fikstürler | `line_erp_*` adı: `endgame_smoke.gd` 46 geçiş, `main.gd` 12, `run_probe.gd` 1; `sprint.json` 3 liste; 7 kâğıt koşulu | hat yeniden adlanırsa toplu düzeltme |

Doğrudan hat sözleşmesini okuyan 19 vaka: `product_lines_catalog_loads`, `line_ladder_rules`, `line_k3_locked_without_research`, `gate_scope_and_halves`, `loc_product_line_keys_resolve`, `product_fit_table`, `product_quality_sector_table`, `product_line_profiles`, `fit_star_context`, `fit_account_ref`, `fit_scale`, `save_v17_market_ref`, `product_area_row`, `rival_composite_table`, `research_node_map_binds`, `rnd_tree_loads_and_validates`, `card_math_matches_gdd_example`, `save_v10_product_state`, `type_screen_matches_line_content` (`endgame_smoke.gd:432-465`).

---

## 3. EKRAN YÜKÜ

| Ekran | Bugünkü kapasite / sınır | 5 / 7 / 10 modül + 4 platform | Yeniden düzen? |
|---|---|---|---|
| **Ürün sekmesi, hat listesi ve sprint kart seçici** (`area_panel.gd:79 _add_area_row`, `:136 _add_open_body`) | 430 px sütun (`ui_tokens.gd:702`), dikey ScrollContainer (`product_tab.gd:64-66`); tek açık alan akordeonu; B2B'de 4 alan; Çekirdek = 5 kimlik hat → ≤ 5 özellik + ≤ 5 düzeltme + 1 araştırma kartı = ≤ 11; "YAPILANLAR" 2 sütunlu ızgara, satır sınırı yok; aday sayısı sınırsız (sıra: öncelik, kilitsiz, etki/efor; `sprint_catalog.gd:232-239`) | 10 modül Çekirdek'te ≤ 21 kart (10 + 10 + 1); sığar (kaydırır), ama uzun | Alan = gruplama olarak korunursa (SENTEZ §3.1) modüller alanlara dağılır: gerek yok. Modüller tek alandaysa kart listesi 21 kartı aşar: alt gruplama/süzgeç gerekir. Efor dökümü ve sprint kapasitesi (`lead.small_team_cards 2`, `sprint.json:28`) kart sayısını modülden bağımsız sınırlar |
| **Ürün sekmesi, çeyrek görünümü** (`quarter_view.gd`, 280 px) | alan satırları, gövde yok (`compact`) | etkilenmez | hayır |
| **Aday kartı** (`sales_tab.gd:323-372 _lead_card`) | satırlar: ad + yıldız, arketip cümlesi (autowrap), anlaşma, balina şartı, lig; sektör ve modül yok; liste sınırsız, gövde kaydırılır (`sales_tab.gd:147`) | sığar, kart +1-2 satır | evet: "İstediği modüller" için HFlow çip satırı (`_line` yalnız metin, autowrap `:786`) |
| **Hesap kartı** (`sales_tab.gd:532 _account_card`, `:565 _meta_line`) | ad, durum etiketi, madde etiketi, tek metin satırı "$/ay · koltuk · kıdem · koltuk fiyatı [· imza indirimi]" (` · ` ile birleşik, autowrap), söz, memnuniyet, sorumlu | 5-10 modül adı o satıra sığmaz | evet: ayrı HFlow satırı (modül çipleri) ya da yalnız HESAPLAR tablosunda göster |
| **HESAPLAR tablosu** | **yok** (C8). Bugün `for c in custs: lane.add_child(_account_card(c, off))` sınırsız, sayfalamasız | 330 hesap × kart ≈ 330 kart (ölçülmedi) | modül sütunları buraya doğal sığar; kart listesi yüzlerce hesapta tablo gerektirir |
| **Görüşme paneli, kimlik bloğu** (`meeting_panel.gd` `_frame`: yıldız, tek satır arketip cümlesi, 1 rozet; `sales_meeting_adapter.gd:68`) | 1 cümle + 1 rozet | sığar: modül satırı ya da rozet ekler | küçük |
| **Görüşme paneli, zar paneli** | `MODIFIER_LINES_MAX := 4` (`sales_constants.gd:110`); fazlası "Ve daha fazlası" satırına katlanır (`EvDice.modifier_lines`) | modül uyumu 1 satır olarak girer, 4 sınırı kalır | hayır (sınır motor kuralı) |
| **Teklif paneli** (`meeting_ruler.gd`) | 3 sabit etiket: `_deal` (MRR), `_capacity`, `_clause` (C4'ün işlenmemiş eklemesi); `show_instrument` `deal[0..2]` okur | modül + iskonto satırı için 4. etiket | **evet**: etiket ekle ya da `deal` dizisini döngüyle çiz |
| **Haber şeridi** (`news_ticker.gd:51`, `news_feed_system.gd:40-42,148-170`) | haftalık 3-5 satır, akış 30, canlı pencere 6; "Biz" payı sert kapıda %20; rakip sürümü `ticker_live_line` ile kotasız tek satır | N modül × 8 rakip sürümü haftada çok satır üretir | evet (kural): sürüm haberi birleştirilmeli (SENTEZ: haftada en çok bir satır) |
| **Gelen kutusu** (`message_system.gd:14`) | 50 posta, eskiden okunmuş silinir | yıllık sektör raporu/ödül postası 50'yi zorlamaz | yeni posta türü 3 dosya (`message_system.gd:57`, `mail_pane.gd:134`, `inbox.gd:17,:280`) |
| **GENEL BAKIŞ kâğıdı** (`overview_view.gd`) | iki sütun (3:2); bugün yalnız sağ sütunda Sunucu bloğu | sol sütun boş ("C6'ya boş"); modül/standart tablosu için hazır | hayır, yer var |

IDENTITY_LINE_COUNT (`product_lines.gd:40`) ekran sınırı değil, yükleyici doğrulamasıdır.
Kart yüksekliği ve gerçek sığma ölçülmedi; "sığar" kaydırma var demektir. Kabul için `--product-shot`, `--sales-shot` kareleri gerekir.

---

## 4. SEKTÖR

### 4.1 13 kimliği kim okuyor (güncel)

| Okuyucu | Ne | Yer |
|---|---|---|
| Kimlik listesi | 13 ASCII kimlik; `testing` fikstür | `b2b_constants.gd:97`, `:103` |
| Ürün uyumu alan ağırlığı | `TABLE` 13 satır, `weights`, `emphasis`, `used_areas`, `uses_area`, `_role`, `_row`, `market_fit` (13'ün ortalaması) | `product_quality.gd:48,66,79,85,91,322,384,222` |
| Hesabın kullandığı hatlar | `account_bugs` (`used_areas`) ve `line_accounts` (`uses_area`) | `b2b_sales_system.gd:173-177`; `sprint_catalog.gd:371` |
| Talep alanı | hesabın vurgu 1 alanından talep | `sprint_bridges.gd:41` |
| Görüşme sorusu | `emphasis` soru ailesi | `sales_probes.gd:49,141` |
| Lead üretimi | arketip → sektör listesi, ad havuzu | `sales_faucet_system.gd:224`, `sales_archetypes.gd:46,64,82,118`, `sales_name_pool.gd:42`, `company_catalog.gd:17` (13×5 ad) |
| Tolerans | 3 sektör ek (construction/health +5, insurance +3) | `b2b_constants.gd:43` |
| Şikâyet/irtibat | `B2B_COMPLAINT_*`, `B2B_CONTACT_*`, `SECTOR_*` | `b2b_constants.gd:123,127`, `seams_ported.gd:69-81`, `inbox.gd:482`, `b2b_sales_system.gd:626` |
| Gece kesintisi, depo kâğıdı | `night_sectors` (3), `warehouse_sectors` (3) | `incident_system.gd:423`; `sprint_catalog.gd:436`; `sprint.json:44,60` |
| Kayıt | `Customer.industry`, `Prospect.industry`; `market_ref` | `customer.gd:19`, `save_manager.gd:988 _migrate_17`, `:1039 _migrate_sector_ids` |

### 4.2 "7 profil × 10 modül tablosu" eklemek

- Veri: yeni dosya (ör. `data/market/sector_profiles.json`): 7 profil × 10 modül hücresi (hiç/sık/her zaman) + 13 sektör → profil eşlemesi; metin yok. ~40 satır yükleyici + doğrulayıcı (hücre ⊂ modül listesi).
- Aday/hesap: modül listesi türetilir (deterministik hash, `SalesFaucetSystem.spawn :191-250` içinde, `p.industry` yanında); hesapta ömür boyu sabit olduğu için `Customer.modules` kayıt alanı (varsayılan göç) ve imzada kopya.
- Sektör ağırlığı yerine modül uyumu: `ProductQuality` aday/hesap bağlamında "istenen her modülün seviye/istenen oranı" ortalaması olur.

### 4.3 `ProductQuality.TABLE` sektör ağırlığını kaldırmak

- `product_quality.gd` içinde silinen/yeniden yazılan: `TABLE` (`:48-62`), `W_B2B` (`:18`), `USE_AREA_MIN` (`:27`), `weights` B2B dalı (`:72-75`), `emphasis` (`:79`), `used_areas`/`uses_area` (`:85-92`), `_role` sektör kolu (`:327-329`), `_row` (`:384-385`), `market_fit` 13 sektör döngüsü (`:222-228`), `fit_from_levels` içindeki `weakest_emphasis`/`note` (`:288-293`), `weakest_area` (`:179`), `_candidate_ctx` sektör bağlamı. ~12 fonksiyon, dosyanın ~%40'ı.
- Dış çağıran: `b2b_sales_system` (`:177`), `sprint_catalog` (`:371-374` ve `:323,667-690,799,819-824`), `sprint_bridges` (`:36,41,109,147`), `sales_probes` (`:48-49,64`), `sales_ledger` (`:356`), `sales_meeting_system` (`:91-92`), `sales_faucet_system` (`:166` `market_fit(3)`), `sales_rep_system` (`:241`), `term_sheet_table_system` (`:548`), `vc_pitch_system` (`:1128,1178`), `product_read` (`:101`, B2C), `sprint_system` (`:1425,1486`), `product_model` (`:176`), `sales_system` (`:385,421`), `save_manager` (`:988`): **16 dosya, ~40 çağrı noktası**. Smoke: `endgame_smoke.gd` 156, `run_probe.gd` 12 `ProductQuality.` çağrısı; vaka grubu `product_fit_table`, `product_quality_sector_table`, `fit_*`, `product_area_row`.
- Kayıt: `Customer.market_ref` (alan → beklenti kopyası) anlamı değişir; `_migrate_17` benzeri göç ve şema 19 gerekir.
- Metin kanalı etkilenmez (13 sektör adı havuzu, 39 CSV satırı `SECTOR_*`, `B2B_CONTACT_*`, `B2B_COMPLAINT_*`, gece kesintisi, depo kâğıdı).
- Performans: `account_fit` her hesap her tik (`b2b_sales_system.gd:151-159`); alan seviyesi bugün hat ortalaması (`product_quality.gd:96-104`), modül bazlı hesap ek maliyet getirir (marj 1,84 ms, madde 17).

---

## 5. BİLİNEN YOL (soru 10)

| Soru | Cevap |
|---|---|
| Kart eforu nerede hesaplanıyor | `SprintCatalog.step_effort(step_id)` (`sprint_catalog.gd:171-178`): `cfg("effort.k<kademe>")` (3 / 5 / 8), tasarım profilli hat + `design_system` Ar-Ge ise `roundi(efor × 0,8)`. Çağıran: `candidates` (`:208,:216,:222`) ve plan ihtiyacı `sprint_system.gd:1051`. Satırın JSON eforu (`erp.json` 5-11) kart eforu değil, yeni kod (hata akışı) içindir (`ProductLines.effort_of :341`, `sprint_system.gd:1449,1574`) |
| Tek giriş var mı | Evet: çarpan `step_effort` içinde tek satır; tek ek: "kademeyi pazarda ≥ 2 şirket yayımlamış mı" yardımcısı (~15 satır) |
| Rakip yayın bilgisi erişilebilir mi | Kısmen. `SprintCatalog.rival_table()` (`:598`, `rivals.json` `tiers` + `launches`), `GameState.product.rival_hits` ({rival, line, sprint}; yazan `sprint_bridges.gd:82-87`), `_rival_tier(rival, line)` özel (`:708`). `RivalRegistry` (Model A) hat/kademe taşımaz. Rakip sayısı 3 (hepsi startup: Ardenna, Raketenhaus, Sumpter; `rivals.json:60`); dev ve yerleşikler çıkış tablosunda yok. Oyuncu zaten sayılmıyor. SENTEZ §8'in "şirketler aynı katalogu yürütür" modeli gelirse bilgi `RivalRegistry`'ye taşınır |
| Damgalama tuzağı | Kart `new_card` ile eforu damgalar (`:248`); saklı kart `candidates` içinde saklı hâliyle döner (`:233 stored.get`). Çarpan rakip yayımlarıyla değişirse sprinte alınmış/ilerlemiş kart eski eforda kalır. Karar: ilerlemesi 0 olan kartta yeniden damgala, ya da sprinte girdiği anda dondur |
| Tamsayı | efor tamsayı: -%20 uygulanınca K1 3 → 2 (-%33), K2 5 → 4 (-%20), K3 8 → 6 (-%25); K4-K12 için `effort.k*` anahtarı da henüz yok. İki çarpan (`design_system` ve bilinen yol) tek `roundi` ile birleştirilmeli |
| Görünürlük | `design_system`'in -%20'si kartta gerekçesiz (`sprint_card.gd:306-315` efor dökümü yalnız puan ve kişi başı kısım); bilinen yol indirimi de gerekçe satırı ister ("pazarda iki şirket yaptı"), yoksa gizli indirim olur. +1 `_effort_parts` girişi ve 1-2 CSV satırı |
| Eski koddan silinen | yok (ek çarpan); `rival_bump` (adaya +0,5/çıkış) kalır |
| Tahmin | 3 dosya (`sprint_catalog.gd`, `sprint_card.gd`, CSV), ~30 satır + 1 smoke (falsification: çarpanı kaldır → vaka düşer); kolay-orta |

---

## 6. SIRALAMA (soru 4): kancalar

| Hedef | Bugünkü kanca | Yer |
|---|---|---|
| Medyadan puan (sürüm çıkınca) | Sürüm kapanışı `_close` `release` sözlüğünü kurar (`number`, `shipped`, `changed_areas`, `press`, `thanks`, `reviews`...) ve `release.press = SprintBridges.press_line(release)` yazar; `_go_public` sürüm geçmişi (`mvp_version_history` bayrağı) | `sprint_system.gd:1409-1505`, `:1519-1532`; `sprint_bridges.gd:96-118` |
| Puanın yazılacağı yer | `release` sözlüğüne yeni anahtar (`score`, `outlet`, `rank`); `p.releases.append(release.duplicate(true))` kayıtla saklanır, anahtar eklemek şema göçü istemez (`.get` varsayılanı) | `sprint_system.gd:1499,1505` |
| Haber şeridi satırı | `EventBus.headline_added(outlet, line)` → "Biz" kaynağı, akışın %20'siyle sınırlı (`BIZ_HARD_CAP`), tampon 10 (`BIZ_BUFFER_CAP`; dolunca yeni düşer); `EventBus.ticker_live_line` kotasız, tek satır (rakip sürümü, ay kapanışı, runway bunu kullanır) | `news_feed_system.gd:39-43,172-195`; `sprint_bridges.gd:89`; `summary_system.gd:88,92` |
| Dört kurgusal yayın adı | `NewsFeedSystem.OUTLET_KEYS` (Ekonomi Postası, Teknogündem, Girişim, Sektör) | `news_feed_system.gd:75-76` |
| Gelen kutusu | `MessageSystem.post(kind, key, args, urgent)` (`:19`), kapasite 50 (`:14`); türler `summary`, `sales_week`, `sales_loss`, `clause`, `rnd_note`, `rnd_discovery`, `intro`; yeni tür için `message_system.gd:57` eşleme, `mail_pane.gd:134-150` gövde, `inbox.gd:17,:280` konu ve satır önizlemesi | |
| Yıllık/ay kapanışı | `SummarySystem.begin_day :57`: periyot "yearly" ise `month_turned and month == 1` (`:70`) ama yalnız Ayarlar'da `summary_frequency` yıllıkken; ay kapanışı her koşuda `_close_month :103` + `EventBus.month_ended`. Yıllık sektör raporu sıklık ayarından bağımsız olmalıysa `month_ended`'i dinleyip Ocak'ta tetikler. Payload sözlüğü `_build_summary_data :175` (mrr, cash, team, brand, highlight) | |
| Ayın öne çıkanı | `GameState.submit_month_highlight(key, args, priority)` (`:429`); sürüm 50 ile bunu kullanır (`sprint_system.gd:1527`); "yılın ürünü" daha yüksek öncelikle girebilir | |
| İtibar ve marka yazarları | `GameState.set_brand` (`:352`, 0-100), `set_reputation` (`:356`, -10..100). Marka yazanlar: churn (`b2b_sales_system.gd:299`), söz kırma (`:548`), prestij imza +3 (`sales_ledger.gd:281`), VC reddi (`vc_pitch_system.gd:546`); itibar: ihmal (`support_system.gd:284`) | |
| Marka/itibar okuyanlar | B2C kitle büyümesi (`sales_system.gd:191-192`), VC dönüşümü (`vc_pitch_system.gd:171,227`), son koşulları (`endings_system.gd:103-143,265`). **B2B lead akışı okumaz** | |
| Lead akışı çarpanı | `SalesFaucetSystem.lead_rate_per_week`: `(3 + 2 × temsilci) × interest_mult(0,8-1,3) × phase_mult`, taban `ONE_STAR_FLOOR_PER_WEEK`; yıldız karışımı `star_mix_now :148` ürün gücüne (`product_strength :165` = `market_fit(3)/70`) bağlı | `sales_faucet_system.gd:120-126,148-165`; `sales_constants.gd:19-25,42-43` |
| Rakip sıralaması için veri | `RivalRegistry.get_market_snapshot` pay sıralaması (tohum pay × momentum; kaliteyi/hat kademesini okumaz) | `rival_registry.gd:127`, `news_feed_system.gd:154` |
| "En çok kullanıcılı ERP, küresel" listesi | Rakip kullanıcı/hesap sayısı modelde yok (`rival.gd` alanlarında bulunamadı); liste için pay modelini bu sayıya bağlamak gerekir | |

Oyuncunun yıllık sıralama/ödül sunumunu hangi kancaya koymanın en ucuz olduğu: (hesap) sürüm anında puan = `release` anahtarı + 1 `headline_added` satırı: 2 dosya, ≈ 25 satır; yıllık rapor = `month_ended` dinleyicisi + yeni posta türü: 4 dosya, ≈ 60 satır + CSV.

---

## 7. Bulunamadı listesi

- B2B ürün/piyasa/rakip koltuk fiyatı verisi; piyasa referansını gösteren ekran.
- B2B kapanış zarında fiyat ya da duruş terimi.
- B2C fiyat değiştirme ekranı (`estimate_price_change` çağıranı).
- Hesap/aday kaydında modül listesi; sektör etiketini gösteren ekran (K haritası ile aynı).
- Yenilemede fiyat/koltuk/yıldız kararı.
- Kademe başına smoke kaydı (vakalar jeneriktir; sabitler 9 yerde).
- Rakip için kullanıcı/hesap sayısı, hat kademesi (Model A'da), dev ve yerleşikler için çıkış tablosu.
- HESAPLAR tablosu (C8).
- Ekran yüksekliği ölçümü (kart piksel boyu): kod okuması, ölçülmedi.

## 8. K_kod_haritasi.md ile farklar (yeniden doğrulama)

- `b2b_sales_system.gd` `expand`: K `:374-391` yazıyor, bugün `:437-455` (C4 ve başka işlenmemiş eklemeler dosyayı büyüttü). `apply_discount :410`.
- `sprint_catalog.gd` rakip bölümü (`rival_table`, `max_tier`, `_rival_tier`) K'dan ~22 satır yukarıda (`:598`, `:652`, `:708`).
- `sales_finalizer.gd` `_open_deal` `:66`, `sign_deal :84`.
- Kâğıt havuzu `sprint.json decision.cards`: bugün 44 (K'da 46; Q K14 ve başka oturumların silmeleri). Satıra özel koşullu kâğıt 17 / 44; ERP kimlik hattı kimliği taşıyan 7.
- K'nın "teklif tek eksendir" ve "koltuk pazarlık edilmez" iddiaları doğrulandı (`negotiation_system.gd:102-112`).
- `meeting_ruler.gd` bugünkü HEAD'de 2 etiket; çalışma ağacında C4 işlenmemiş değişikliği 3. etiketi ekliyor; hesaplarım 3 etiketi esas alır.
