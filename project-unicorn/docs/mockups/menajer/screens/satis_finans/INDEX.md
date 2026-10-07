# Satış ve Finans · A4 ekran maketleri (grup "satis_finans")

Satış penceresi (boru hattı, satış masası, müşteri portföyü, B2C hâli, temsilci seçici) ve Finans penceresi (Özet'in
altı durumu ve Yatırım'ın açık ve kapalı avı), onaylı Menajer Masası diliyle, tam kabuk içinde, 1920×1080 (ve 1536×864).
Dört çerçeve İngilizce de çizildi (SPEC §3.4 genişlik geçişi). Hepsi onay bekliyor.

- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, A2 ikonları, kırpım kuralı, üst bar ızgarası,
  `measure.py`. Sistemin eksiği `satis_finans.css`'te (aşağıda "Yeni bileşenler"); sistem klasörüne hiçbir şey yazılmadı
  (kit kopyaları ve önbellekleri `tools/syskit/`'te).
- **Kabuk kabuk grubunundur.** Ofis katmanı, BuildHUD, bildirim yığını, Ofisi taşı ve tohum başına kabuk durumu
  `../kabuk/tools/gen.py`'den kopyalandı (`office()`, `buildhud("seed")`, `SEED_INBOX` + `stack_row`, `B14`):
  - Ofis `art/office_safe_1920_noicons.png` / `office_safe_1536_noicons.png`, kafa ikonları A2'nin `icons/office/*.svg`
    sprite'ları plakanın `*_heads.json` konumlarında (kabuk INDEX madde 17); pencere açık olduğu için %84 karartmalı.
  - DESTEK kartı: "Düzeltme başlat" kapalı (ink-off), gerekçesi yanında "Doğrulanmış hata yok." (kilit kuralı). EN etiket
    CSV'den "Start a fix run" (`PROD_FIX_RUN_START`). Ürün yayında değilken kart yok (`finans__gider_dokumu`).
  - Bildirim yığını gelen kutusunun önizlemesi: gönderen · konu · kalan süre. Teklif hatırlatıcısı yuvası gibi: uyarı
    noktası ve uyarı süre, son haftada kırmızı.
  - Tema tohumu (H14 11:00) her grupta aynı: Sıradaki "14:00 · Karadeniz Fabrika" + 14:00 elması, rayda Satış 1, Ekip 1,
    Ar-Ge 2, yığında Nordica · Bir ekip daha · 2 hafta / Ege Sigorta · Risk altında / Selin Kaya · Ayrılabilir.
  - Kabuk kuralı üst barın para okumasında: runway yalnız 3 ayın altında kırmızı (Finans rozetiyle aynı eşik,
    `RUNWAY_ALERT_MONTHS[0]`); kasa artıdayken eksi NET mürekkep, kırmızı yalnız KEPENK'te; eksi kasa kırmızı. Aynı kural
    pencere başlığında ve Aylık akış kartında.
- Frank = aday A (`portraits/frank_cand_a.png`): Finans'ın mentor kartında 64 px disk, Yatırım şeridinde 40 px disk.
  Yağlı boyalar yok.
- Üst barın marka bloğu karar 14'ün **(a) seçeneği** (olaylar grubuyla aynı). Faz etiketi özel ad: EN yerel ayarıyla
  büyük harf (`lang="en"`), TR'de "SERİES A" noktalı İ'ye dönmüyor. **Kabuk grubuna:** üst bar onların; aynı düzeltme
  `brand_block`'ta gerekli.
- Olaylara bağlanan düğmeler (İlgilen, Değerlendir) mail ikonu taşır: tıklayınca Olaylar o maili seçili açar.

Yeniden üretmek: `python tools/gen.py` (HTML'ler `build/`, `*_en` adları İngilizce), `bash tools/render_all.sh <tur> [ad ...]`
(PNG'ler bu klasöre, kopyası `rounds/<tur>/`; `*__1536` adları 1536×864 ölçek 1.25 çizilir). Paralel: `ls build/*.html |
sed 's#build/##;s#\.html##' | xargs -P 8 -I{} bash tools/render_all.sh <tur> {}`.
Turlar: r1 ile r6 (ilk yapım ve düzeltmeler), **r7 (A4 incelemesinin S1, S2 ve S3 maddeleri; 19 çerçevenin hepsi tam boy
okundu, 1:1 ve 2× kırpımlar `rounds/crops/r7_*`, temas sayfası `rounds/crops/r7_contact.png`)**. Kabuk bölgeleri
`kabuk__normal` / `kabuk__pencere_acik` ile piksel karşılaştırıldı: üst bar, yığın ve Ofisi taşı aynı (fark yalnız
komşu Ekip penceresinin gölgesi).

## Çerçeveler

"Tema tohumu" = `data/screens.md` + kabuk (hafta 14, 11:00). "Satış dünyası" = `--sales-shot` tohumu (`_seed_sales_world`,
hafta 14, 08:00). "Finans tohumu" = `--finance-shot` (hafta 7, 08:00). "VC tohumu" = `--vc-shot=hunt|hunt_closed`
(PromptPilot, hafta 1). Pencere yüksekliği içeriğe göre, SPEC §9 tablosu üst sınır (Satış 760, Finans 720; 1536'da 712);
kaydırmalı gövdeler (masa ve portföy) tablo yüksekliğinde.

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `satis__boru_hatti.png` | Satış: başlıkta dört ölçü (Müşteri 3, %56, 0, 0), fiyat duruşu; boru hattında Karadeniz Fabrika'da "Görüşme · 14:00" satırı (Görüşmeye git yok, görüşme ayarlı), Efes Emlak; satış masası Burak Şahin; portföy Ege (risk, 25, İlgilen), Nordica (büyüme, 72, Değerlendir), Kuzey İnşaat. Değiştir her kartta temsilci satırının hemen yanında; eylem düğmesi sağda. Ayır, Temsilciye ver'le sağdaki kümede. Pencere içeriğe göre (788'de biter). | Tema tohumu + kabuk kabuğu. Görüşme kabuğun Sıradaki yuvasıyla aynı. | `.deal .work.meet`, `.acct-foot .act` | `SALES_LEAD_MEETING` | 1, 9, 10, 18, 22 |
| `satis__masa_ve_portfoy.png` | Satış dünyası: üç lead, Kerem Aydın Karadeniz Emlak'ı işliyor, portföy beş hesap kaydırmalı (Ege'de churn sayacı, Palmiye Burcu Çetin'de). Başlık: 5, %63, +1, −1. | Satış dünyası; Kerem'in bandı `SalesRepSystem.band_cap_options` (2,5 → 1, 2, kendi ligi). Yığın: Nordica (2 hafta) + Ege; bu tohumda kadroda riskte kimse yok (baseline'da Ekip rozeti yok). | | | 1, 14 |
| `satis__masa_ve_portfoy_en.png` | Aynısı İngilizce (genişlik geçişi): "Reserve / Give to a rep / Go to the meeting", "Account manager: Founder", "~2 weeks to churn", "Working band:", üst bar "Default Alive", "REPUTATION". Taşan kutu yok. | CSV EN değerleri; sayılar EN biçiminde. | | | |
| `satis__temsilci_secici.png` | Ege'nin Değiştir'i basılı (surface-2 dolgu + kenar), altında seçici: "Sorumlu ata", Burcu Çetin 1/9 (üstünde), çizgi, "Kurucu (kendim tutayım)" kapalı + "zaten sorumlu", 4/4. Menü düğmenin altına çapalanır. | Kapasite `B2BConstants.account_capacity` (4 + 2×yıldız): Burcu 2,5★ → 9, kurucu 4 (`founder_managed_count`). Menü genişliği TR ve EN'nin en geniş satırından, Godot payıyla (`measure.py`, × 1,08 + 2). | | | 1 |
| `satis__temsilci_secici_en.png` | Aynısı İngilizce: "Assign account manager", "Founder (keep it myself)" + "already assigned" (TR'den ~50 px geniş) yük çubuğuna değmiyor. | Aynı. | | | |
| `satis__b2c_bos.png` | B2C koşu: tek boş hâl, gövde boyunca: "Canlı B2B ürün yok." + "Kitleden gelen gelir MRR'da sayılır. Hesaplar ve adaylar B2B ürünle gelir."; B2B ölçü şeridi yok (müşteri sayısı B2C'de anlam taşımıyor). | Satış dünyası + `mvp_market_type b2c`. **Türetildi:** tohum B2C koşuya beş B2B hesap ekliyor (debug); çizilmedi. Üst bar tohumda tutuldu. | `.b2c.empty` | `SALES_B2C_NOTE` | 13 |
| `satis__renk_koru.png` | `satis__masa_ve_portfoy` renk körü paletinde. | Aynı. | | | |
| `satis__1536.png` | `satis__boru_hatti` 1536×864'te (ölçek 1.25): pencere 1280 × içerik (≤712), x 88; BuildHUD, yığın ve Ofisi taşı pencereye değdiği için gizli (SPEC §9). | Tema tohumu; ofis `office_safe_1536_noicons.png` + kafa ikonları. | | | |
| `finans__ozet.png` | Özet: Nakit $237.483, Aylık net (bedel glifi, mürekkep) −$44,0K, Runway 5 ay (mürekkep); Yatırım kilitli, gerekçe "Series A Avı'nda açılır". Kasa eğrisi 6 ay aralığında (bugün − 26 hafta ile ufuk): Eyl'den Oca'ya boş geçmiş, H1'den H7'ye gerçekleşen, mevcut gidiş projeksiyonu; "hedef tutarsa" çizgisi mevcut gidişin 2 px'inden yakın olduğu için çizilmiyor ve lejantta yok. Hafta 4'te ipucu. Aylık akış: "AYLIK AKIŞ" + "mevcut gidişle"; Gider ve Net bedel glifiyle mürekkep. Pazar payı çubuksuz; 3'ten 11'e atlamada kesik çizgi; Sen satırı mürekkep-1 + SEN etiketi (seçim grameri değil). | Finans tohumu ("ozet"). **Türetildi:** ara haftalar kuraldan (kasa += MRR×7/30 − burn×7, burn 1.528/gün). "Hedef tutarsa" eğimi = MRR + açık iki lead ($750/ay). | `.kpi-val .cst`, `.share .v.cst`, `.card-h .cap`, `.lg-gap`, `.lg-row` (çubuksuz) | `FIN_MONTHLY_FLOW` bölünür, `FIN_SUBTAB_LOCKED` TR | 2, 6, 7, 8, 19, 20, 21 |
| `finans__ozet_en.png` | Aynısı İngilizce: "Monthly flow at the current pace", "Expense" (akış etiket sütunu 60 px'e çıktı: Godot'ta 60 ister), mentor sözü üç satır, "YOU". Taşan kutu yok. | Aynı; EN değerleri CSV'den. | | | |
| `finans__artida.png` | Artıda: Net +$14,2K, Runway Artıda (yeşil), RUNWAY_PROFITABLE_NOTE, yalnız "hedef tutarsa" projeksiyonu (lejant örneği iki kesik gösterir). Mentor kartı yok, bu yüzden Hisse dağılımı Pazar payının altına geçer; pencere en uzun sütuna göre kısalır (741'de biter). "Yalçın Teknoloji Holding" tam adıyla (ad hücresi 196 px, Godot 164 ister). | Finans tohumu ("artida"). | | | 7 |
| `finans__uyari.png` | Runway 2 ay kırmızı (üst bar ve başlık), Finans rozeti 1; NET mürekkep; mevcut gidiş sıfırı H16'da keser: "Kasa sıfır · H16", kırmızı alan, lejantta "Sıfırın altı"; Frank'in mentor kartı. | Finans tohumu ("uyari"); sıfır 7 + 87.119 / 10.430 = 15,4 → ilk eksi hafta 16. | | | 2, 7 |
| `finans__kepenk.png` | Kepenk: KASA −$17.181, KEPENK 3 hafta, NET kırmızı (yalnız burada), başlıkta Kepenk 3 hafta, Aylık akış Net kırmızı; eğri H16'da sıfırı geçer (alan Kas'tan Haz'a); mentor kartı kepenk bandında. | **Türetildi:** "uyari" tohumu aynı akışla H17'ye sürdürüldü (H16 −$6.751 sayaç 4, H17 −$17.181 sayaç 3). | | | 3, 4 |
| `finans__sinyal.png` | Faz 2, **tutarlı türetilmiş durum**: Hafta 30 · Temmuz 2026, KASA $288.833, MRR $58,0K, NET +$12,2K, Runway Artıda; eğri Oca'dan Mar'a erir, sonra yükselir; notlar RUNWAY_PROFITABLE_NOTE + "Artıda · 4/6 ay"; hedef kartı "Series A'ya" + Yatırımcı iştahı Kapalı, "Gelir henüz çıtanın altında"; Pazar payı %3,9 (6.), Hisse dağılımı sağ sütunda. | **Türetildi** (`tools/gen.py signal_hist`): MRR H1 $1,1K → H10 $50,0K → H30 $58,0K, burn 10.696/hafta. Mart, Nisan, Mayıs, Haziran artıda kapanır (ay netleri +$4.443, +$7.653, +$7.803, +$9.296), Temmuz açık; kasa hiç eksiye düşmez. $58,0K, $120K çıtasının %50'sinin altında: iştah Kapalı (`series_a_signal`). Faz 2 hedef kartı oyunda yalnız başlık taşır (`finance_ozet_view.gd _refresh_goal`: göstergesi iştah, çıtanın rakamı basılmaz). Pay MRR'la orantılı: 4,0 × 58/60. | | | 5, 8, 9 |
| `finans__gider_dokumu.png` | Gider dökümü: on saatlik gün (hafta çubuğu 08:00'den 19:00'a, Sıradaki "Mesai bitimi · 11 saat"), Runway 3 ay mürekkep (3 ayın altı değil, Finans rozeti yok), Gider dağılımı üç kalem, Son işlemler "H10 · Mar 2026 · İşe alım · −$3.000"; ürün yayında değil: BuildHUD yok; Hisse dağılımı mentor kartının altında. Eğri: bugün H10, gerçekleşen yalnız bugünkü nokta, öncesi boş geçmiş (aralık H−16'dan H19'a). | `--hr-shot=gider` (`WorkHoursSystem.set_company_hours(10)`, başlangıç 09:00). Tohum kasayı doğrudan yazdığı için geçmiş yok (soru 5). | `.stackbar.thin` | | 5, 19 |
| `finans__1536.png` | `finans__ozet` 1536×864'te: pencere 1344 × içerik (≤712), üç sütun sığar. | Finans tohumu. | | | |
| `finans__yatirim_av_acik.png` | Yatırım açık: Series A Avı, Frank şeridi, Yatırımcılar (Kapanan masa 1/3, dört fon, lider ortak, durum etiketi; kilitli "2. kademe fonu"), Teklifler: Anchor ve Meridian belgeleri. Belgede kalan süre fonun adının altında uyarı renginde ("Teklifte 2 hafta kaldı", kırmızı yalnız son haftada, Sıradaki yuvasıyla tek eşik), Masadan kalk ve Masaya otur başlık satırının sağında, tahmin satırı düğmesiz; Tahmini pay bedel olarak dilim glifiyle. Bosphorus sırada. Bekleyen boşken tek satır. Yığın: Anchor Capital · Teklif · 2 hafta, Meridian Growth · Teklif · 3 hafta. | VC tohumu ("hunt"); aralıklar baseline'dan; lider ortaklar `art/busts/counterparts.json`. **Türetildi:** Kapanan masa 1 (Nexus reddi). | `.offer-who`, `.offer-h .acts`, `.card-h .empty-m` | `HUNT_TIER2_SLOT` | 6, 10, 11, 12 |
| `finans__yatirim_av_acik_en.png` | Aynısı İngilizce: "The Series A Hunt", "2 weeks left on the offer", "Est. valuation $12M to $17M", "Est. equity 20% to 28%", "Walk away / Sit down", "Tier 2 fund". Taşan kutu yok. | Aynı. | | | |
| `finans__yatirim_av_kapali.png` | Bütün fonlar kapalı (Reddetti kırmızı; Masadan kalktın ve Süresi doldu aynı nötr dolu etiket), "Series A için kapısı açık fon kalmadı."; Kapanan masa 2/3; pencere içeriğe göre. | VC tohumu ("hunt_closed"). **Türetildi:** 2 = iki ret (kalkmak ve süre dolması ret sayılmaz). | | | 5, 6 |

## Yeni bileşenler (`satis_finans.css`, sistem grameriyle)

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.brand-sq` + `--brand-mark` | Marka bloğunda 20 px turuncu kare, karar 14 (a); olaylar grubuyla aynı | `LogoEmblem` sabit renk, `D_BRAND_MARK` sahne sabiti |
| `.head-ic`, `.abs`, `.office-layer` | Kabuğun ofis katmanı: noicons plaka + A2 kafa sprite'ları, karartma katmanın kendisinde | `OfficeView`, `office_actor.gd` ICONS |
| `.bh-act .why`, `.notice .nwk(.is-warn/.is-neg)`, `.notice .dt.is-warn` | Kabuk.css'in aynısı: kapalı eylem + gerekçe; yığın satırının süre sütunu | `build_bar.gd`, `office_notice_stack.gd` |
| `.cols`, `.col`, `.col.scroll` | Pencere gövdesi sütunları; kaydırmalı sütun sistemin kaydırma çubuğunu taşır | HBox + ScrollContainer |
| `.card`, `.card-h`, `.card-b`, `.card-h .cap`, `.card-h .empty-m` | Mobilya kartı; başlık anahtarının yanında cümle düzeninde ink-3 açıklama; boş kartın tek satırı | `PanelContainer` koyu `CardInset` |
| `.kpi-val.neg/.pos/.dim`, `.kpi-val .cst` | Başlık ölçüsünün renk hâlleri; eksi net bedel glifiyle mürekkep | `frame_options` KPI renk anahtarı |
| `.seg-tab .ic`, `.seg-why` | Kilitli bölüm sekmesi: kilit ve etiket soluk, gerekçe yanında ink-3 (kural 4) | `SegTab` + gerekçe Label |
| `.chart-h`, `.chart-legend` (32 px örnek), `.segpick.sm` | Eğri kartı; lejant örneği çizginin kesik ritmini gösterir (4/4 mevcut gidiş, 12/6 hedef tutarsa) | `FinanceOzetView` yerleşimi |
| `.ch-proj2`, `.ch-proj.cur`, `.ch-today`, `.ch-hover` | İki projeksiyon renk yerine kesik ritmiyle; ikincisi ufukta birinciden 2 px'ten yakınsa çizilmez; ipucu kartın içinde kalacak yöne döner | `cash_curve.gd` `_draw` |
| `.share.flow` (60 / 1fr / 92), `.share .v.cst`, `.share.cost`, `.share .a`, `.stackbar.thin` | Aylık akış (gelir yeşil, gider ve eksi net bedel glifiyle); gider dağılımı tutar ve yüzdeyle | HBox satırları |
| `.lg`, `.lg-row` (sıra · ad · eğilim · pay), `.lg-row.is-you`, `.lg-gap`, `.lg-row.others` | Pazar payı merdiveni çubuksuz; sıra atlamasında kesik çizgi; oyuncu satırı mürekkep-1 + SEN etiketi | `_league_row` |
| `.goal-card`, `.goal-v`, `.appetite`, `.appetite.lead`, `.card-h .ph` | Faz hedefi ve altında Yatırımcı iştahı; faz adı yazıldığı gibi | `_build_goal_card` + `InvestorAppetiteUi` |
| `.cap-row`, `.txn` | Hisse satırı; işlem satırı (gider bedel glifiyle mürekkep, gelir yeşil) | Label satırları |
| `.fnote`, `.fnote.is-danger`, `.fstrip` | Frank'in notu (belge, 64 px portre, serif söz, Ertele) ve hunt şeridi | mentor kartı, `HuntTab` başlığı |
| `.deal .w`, `.deal .work`, `.deal .work.meet`, `.deal .acts` | Lead belgesi: kalan süre; temsilci işliyorsa satırı; ayarlı görüşme satırı; eylemler sağda tek küme (Ayır, Temsilciye ver, Görüşmeye git) | `_lead_card` |
| `.acct`, `.acct.is-risk`, `.acct.is-delegated`, `.acct-sat`, `.acct-foot`, `.acct-foot .act` | Hesap belgesi: memnuniyet ölçeri, churn kareleri, temsilci satırı + Değiştir hemen yanında, olaya giden düğme sağda | `_build_customer_card` |
| `.rep`, `.rep-top`, `.rep-band` | Satış masası: temsilci, altında bant seçici | `_rep_row` + `_band_cap_row` |
| `.menu.picker`, `.load`, `.menu-item .why` | Temsilci seçici: genişlik ölçülür (TR ve EN, Godot payı); Değiştir'in altına çapalı (açıkken Değiştir basılı: `is-pressed`) | `HRPopover` + `_steward_option` |
| `.b2c.empty` | B2C'nin tek boş hâli: gerekçe + gelirin nerede sayıldığı | boş hâl |
| `.hunt-top`, `.fund`, `.fund.is-closed`, `.fund.is-locked`, `.lockdisc` | Av başlığı; fon satırı; kapalı fonun yüzü gri | `_build_roster_card` |
| `.offer`, `.offer-h`, `.offer-who`, `.offer-h .acts`, `.offer-p`, `.queued` | Teklif belgesi: ad ve altında kalan süre, sağda iki eylem; altında tahmini değerleme ve pay | `_build_offer_card` |
| `.tables`, `.road-closed` | "Kapanan masa: n/3" + üç tehlike karesi; kapanan yolun tek cümlesi | `_refresh_counter`, `HUNT_ROAD_CLOSED` |

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

SPEC §13'te önerilenler tekrar edilmedi, kullanıldıkları yer yazıldı: "Kepenk / Shutter" (Finans başlığı ve üst bar),
"Workday ends · {n} h / Mesai bitimi · {n} saat", "{time} · {company}", "Offer · {n} weeks left / Teklif · {n} hafta
kaldı" (Sıradaki yuvası). Kabuk grubunun önerdiği ve burada kullanılanlar onların listesinde: `FIX_RUN_REFUSED_NO_BUGS`
(No confirmed bugs. / Doğrulanmış hata yok.), `BUILD_SUPPORT_CONFIRMED` yeniden harf (Confirmed {n} / Doğrulanmış {n}),
`DESK_PAPER_SHEET_SUBJECT` (Offer / Teklif), yığın konuları (One more team / Bir ekip daha, At risk / Risk altında).

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `TOPBAR_BRAND` | Project Unicorn | Project Unicorn | marka bloğu (olaylar ve kabukla ortak) |
| `FIN_CURVE_TODAY` | Today · W{n} | Bugün · H{n} | eğride bugün çizgisi |
| `FIN_CURVE_ZERO` | Cash hits zero · W{n} | Kasa sıfır · H{n} | eğride sıfır işareti (ilk eksi hafta) |
| `FIN_LEGEND_BELOW_ZERO` | Below zero | Sıfırın altı | lejant, yalnız eğri sıfırın altına indiğinde |
| `FIN_CURVE_TIP_CASH` | Cash {amount} | Kasa {amount} | eğri ipucu |
| `FIN_CURVE_TIP_FLOW` | Net {net}/mo · Runway {runway} | Net {net}/ay · Runway {runway} | eğri ipucu |
| `FIN_MONTHLY_FLOW` değişikliği | Monthly flow | Aylık akış | kart anahtarı (bugün "Aylık akış · mevcut gidişle", caps'te dört kelime, kural 7) |
| `FIN_MONTHLY_FLOW_PACE` | at the current pace | mevcut gidişle | anahtarın yanında ink-3 açıklama |
| `FIN_SUBTAB_LOCKED` TR değişikliği | Opens in the Series A Hunt (aynı) | Series A Avı'nda açılır | kilitli Yatırım sekmesinin gerekçesi; bugünkü TR "Series A Hunt'ta açılır" TR metinde İngilizce (`HUNT_PAGE_TITLE` zaten "Series A Avı"). `FIN_REQ_OPENS` aynı düzeltmeyi ister. |
| `HUNT_EST_VALUATION_KEY` | Est. valuation | Tahmini değerleme | teklif belgesi (`HUNT_TERMS` iki parçaya bölünür) |
| `HUNT_EST_EQUITY_KEY` | Est. equity | Tahmini pay | teklif belgesi |
| `HUNT_EST_VALUATION` değişikliği | ${lo}M to ${hi}M | ${lo}M ile ${hi}M | bugünkü kalıp aralığı en tireyle yazıyor |
| `HUNT_EST_DILUTION` değişikliği | {lo}% to {hi}% | %{lo} ile %{hi} | bugünkü kalıp aralığı en tireyle yazıyor |
| `HUNT_TIER2_SLOT` | Tier 2 fund | 2. kademe fonu | kilitli beşinci fon (sözlükte Tier = Kademe); bugünkü ad em tireyle başlıyor (`InvestorRegistry` locked_tier2) |
| `SALES_ACCOUNT_SATISFACTION` | Satisfaction | Memnuniyet | hesap belgesinde memnuniyet ölçerinin anahtarı (önceki turda listede yoktu) |
| `SALES_LEAD_MEETING` | Meeting · {time} | Görüşme · {time} | görüşmesi ayarlı lead'in satırı (Sıradaki yuvasıyla aynı görüşme) |
| `SALES_B2C_NOTE` | Consumer revenue counts in MRR. Accounts and leads come with a B2B product. | Kitleden gelen gelir MRR'da sayılır. Hesaplar ve adaylar B2B ürünle gelir. | B2C Satış'ın tek boş hâli, `SALES_LOCKED_NO_B2B`'nin altında |

**Onaylanacak metin değil, yer tutucu:** lead satırları (`SALES_ARCH_OPS_CAUTIOUS_LINE`, `_FINANCE_BRISK_LINE`,
`_TECH_EXACTING_LINE`) CSV'de hâlâ "PH:" önekli yer tutucular; çerçeveler öneki atıp gösteriyor. Bu satırlar kopya olarak
onaylanmamalı.

Metin değişmeden sunumu değişenler (onaya):
- Hesap kartında temsilci: kurucunun tuttuğu hesapta `HR_ROLE_FOUNDER` ("Kurucu"). Seçici kurucuyu "zaten sorumlu"
  işaretliyor (soru 1).
- `FIN_SNOOZE` düğmede cümle düzeni ("Ertele"). `SALES_ACTION_RETAIN/EXPAND`'ın " →" eki ikona döndü.
- `SALES_BAND_STAR` "{n}" + yıldız ikonu (SPEC §3.1). `HUNT_COUNTER_TABLES` Yatırımcılar başlığında anahtar + değer + kareler.
- `HUNT_VALIDITY` / `HUNT_VALIDITY_ONE` teklif belgesinde fonun adının altında; `HUNT_NONE_PENDING` boş Bekleyen'in tek satırında.
- Sayı biçimi: "+0" → "0", gelir "+$0" → "$0" mürekkep; eksi U+2212; Gider dağılımı başlığında toplam `FIN_PER_MONTH` ile.
- Faz adı büyütülmüyor ("Traction'a", "Series A'ya"); üst barın faz etiketi EN yerel ayarıyla büyük harf.

## Açık sorular (Erdem)

1. **Temsilci satırı**: kurucunun tuttuğu hesapta "Müşteri temsilcisi: Kurucu" mı, "Sen" mi, "atanmadı" mı? (Kod bu
   hesapları kurucuya sayıyor: `B2BSalesSystem.founder_managed_count`.)
2. **Runway kırmızısı** çerçevelerde artık kabuğun eşiğinde: yalnız 3 ayın altı (Finans rozetiyle aynı). Özet'in ve
   Frank'in uyarı eşiği `RUNWAY_WARN_MONTHS` 6 ayda kalır: 5 ayda mentor kartı görünür ama sayı kırmızı değil. Kabul mü?
3. **Kepenk çerçevesi**: tohumun üçlüsü kuralla erişilemediği için "uyari" tohumu H17'ye sürdürüldü. Kabul mü, tohum mu düzelsin?
4. **Kepenkte Özet**: üçüncü ölçü üst barla aynı "Kepenk 3 hafta"; bugün Özet "Runway 0 hafta" yazıyor.
5. **Bayat ya da imkânsız tohumlar** (Faz F görsel kabulünden önce düzelsin mi?): `--hr-shot=gider` kasayı doğrudan
   yazıyor (eğri geçmişi yok); `--vc-shot` fon durumlarını `vc_rejections`'ı artırmadan yazıyor (baseline "Kapanan masa:
   0") ve Series A evresini "Hafta 1 · Ocak 2026"da gösteriyor, oyunda erişilemez; `--finance-shot=signal` faz 2'yi
   hafta 7'de eksi net (−$44,7K/ay) ve "Artıda · 4/6 ay" ile kuruyor (çelişkili: maket yerine H30'da tutarlı bir faz 2
   türetti, yukarıda).
6. **Frank şeridi kapalı yolda** "Av açık…" diyor; bütün fonlar kapalıyken bu satır yanlış. Yeni bir Frank satırı (taslak
   gerekir) mı, şerit gizlensin mi? Ayrıca açık avda şerit "Kapanan masa: 1" diyor ve aynı sayı 70 px aşağıda sayaçta:
   Frank'in külliyatı olduğu için dokunulmadı.
7. **Projeksiyonlar**: kural önerisi "ikinci projeksiyon ufukta birincinin 2 px'inden yakınsa çizilmez ve lejantta yok"
   (Özet'te pipeline yalnız $750/ay ekliyor, çizgiler üst üste). İkinci projeksiyon hiç kalsın mı?
8. **Yatırımcı iştahı** hedef kartının altında (sinyal hedefin göstergesi); "Isınıyor" uyarı etiketi.
9. **Faz adı büyük harf**: üst barın faz etiketi EN yerel ayarıyla ("SERIES A"); kabuk grubunun `brand_block`'u da aynı
   düzeltmeyi ister.
10. **Birincil eylem yok**: Satış ve Yatırım'da her satırın eylemi ikincil (kural 1). İki teklif varken amber kimde olurdu?
11. **Teklif süresi rengi** artık tek eşik: uyarı, kırmızı yalnız son haftada (yuva, yığın ve belge aynı). Oyun bugün
    ≤ 2 haftada kırmızı (`WARNING_WEEKS`): bu sabit değişikliği onay ister.
12. **Lider ortak**: fon satırına yüz ve "Kerem Kaya · Kıdemli Ortak" eklendi (CounterpartSystem verisi). Kalsın mı?
13. **B2C Satış**: tek boş hâl + gelirin MRR'da sayıldığını söyleyen yeni satır, B2B ölçü şeridi yok. Yoksa sekme B2C'de
    kilitli mi görünsün?
14. **Büst yok**: Kerem Aydın ve Burcu Çetin için `art/`'ta render yok; yüklenme yer tutucusu çizildi.
15. **Pencere yüksekliği**: SPEC §9 tablosunu üst sınır, kuralı ("içeriğe göre") ölçü aldım. Chrome'da ölçülen:
    Satış tema tohumu 700 (1536'da da 700), B2C 354; Finans Özet 696, Artıda 653, uyarı 696, kepenk 703, faz 2 608,
    gider dökümü 682; Yatırım açık 706, kapalı 671. Kaydırmalı Satış dünyası 760'ta sabit. Tablo mu, kural mı?
16. **Görüşme ayarlı lead**: kabuğun "14:00 · Karadeniz Fabrika" yuvası yüzünden Karadeniz Fabrika'nın kartında
    "Görüşme · 14:00" satırı var ve Görüşmeye git yok. Oyunda istenen görüşmenin kartta karşılığı yok; satır kalsın mı?
17. **Eğri aralığı**: alan seçilen aralığı izler (6 ay = bugün − 26 hafta ile ufuk); genç koşuda geçmiş boş kalır
    (Özet'te Eyl'den Oca'ya). Bugün oyun alanı ilk örnekten başlatıyor (`cash_curve.gd`). Hangisi?
18. Lead kartı karşı tarafı göstermiyor (yalnız tema tohumunun iki lead'inin büstü var); her lead'e alıcının yüzü eklensin mi?
19. **Son işlemler** altı durumun beşinde boş (imza işlem değil, `FinanceSystem` kuralı). Boşken kart gizlensin mi?
20. **Pazar payı çubuksuz** (öneri): %0,1'lik 2 px çubuk bilgi taşımıyordu ve uzun adla çakışıyordu; sıra ve pay yazılı.
    Çubuk geri gelsin mi?
21. Kasa eğrisi ipucu (hafta, kasa, net ve runway) SPEC §11.2'den; iki yeni metin satırı ister.
22. **Finans başlığı üst barı tekrar ediyor**: Nakit, Aylık net, Runway üst barda da var. Başlıkta başka ölçüler mi
    (ör. faz hedefi, pazar payı), yalnız başlık mı?
23. **Hisse dağılımı sütun değiştiriyor**: sağ sütunda tek kart varken (Artıda, faz 2, gider dökümü) onun altına geçer,
    yoksa solda kalır. Sabit yer mi, bu kural mı?
