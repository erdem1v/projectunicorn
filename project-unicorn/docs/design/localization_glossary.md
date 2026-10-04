# Lokalizasyon Sözlüğü — TR ↔ EN terim kanonu (2026-08-10, kapı kararları işlenmiş)

**BILINGUAL BIRTH LAW'un bağlayıcı eşlik dosyası** (CLAUDE.md). Bir terimi bu
tablo yönetiyorsa, o terim bir daha ad-hoc çevrilmez — her yüzeyde buradaki karşılık kullanılır.
Dokuz kapı kararı (2026-08-08) işlenmiştir. Yeni terim ekleyen task bu dosyaya satırını da ekler.

**Register:** EN, İngilizce yazılmış oyunun kendi sesi — kuru, düşük ateşli, satış-katı/haber-odası
kayıtları yerinde. Makine-çeviri kokusu ve pazarlama İngilizcesi yasak. ALL-CAPS yüzey EN'de de
ALL-CAPS; uzun çip = daha kısa kelime, asla daha geniş konteyner. INTEGRITY-law loanword seti
(`pitch, startup, demo, momentum, MRR, runway, churn, burn` + `laptop, mail, VC` + özel adlar) iki
dilde aynıdır. `[WORKING]` = yönetmen F5'te revize edebilir.

## 1. Kilit & erişilebilirlik grameri (her yüzeyde bağlayıcı)

| TR | EN | Not |
|---|---|---|
| KİLİTLİ | LOCKED | Kilitli her şeyin TEK kelimesi (event seçimi, slot, rol). Asla UNAVAILABLE/DISABLED. |
| ÇOK YAKINDA | COMING SOON | Bağımsız telegraf. |
| · YAKINDA | · SOON | Yalnız `·` sonrası kısa biçim (`HARD MODE · SOON`). |
| TAM SÜRÜMDE | IN THE FULL GAME | **Kapı kararı 1** — eski shipped "IN FULL RELEASE" revize edildi. |
| İNŞA EDİLİYOR · SEÇİM KİLİTLİ | BUILD IN PROGRESS · CHOICES LOCKED | |
| CANLI | LIVE | `CANLI V{n}` → `LIVE V{n}`. |
| YENİ | NEW | Müşteri çipi + HR rozeti ortak. |

## 2. Şirket yayı & finans durumu

| TR | EN | Not |
|---|---|---|
| Bootstrap · Traction · Series A | *aynı* | **Kapı kararı 3 — sonsuza dek kapalı.** Yayın özel adları, iki dilde İngilizce. |
| Faz kapısı | Phase gate | |
| KEPENK: {n} HAFTA | SHUTTER: {n} WEEKS | Kepenk imgesi korunur, fiction'ın kendi metaforu. Tekil: SHUTTER: 1 WEEK (`_ONE`). |
| Artıda | Default Alive | Örnek çift: EN yerlisi tür terimi. |
| Brüt Runway | Gross Burn Runway | Kanon. |
| KASA | CASH | TopBar; TR tarafı yeni. |
| BURN | BURN | **Kapı kararı 4** — whitelist'te; TR TopBar BURN kalır. |
| NET / MRR | NET / MRR | Aynı. |
| MARKA / İTİBAR | BRAND / REPUTATION | |
| TUR AÇ | OPEN ROUND | |
| Toplanan | Raised | |
| Ay kapanışı | Month close | |
| Pazar payı | Market share | |
| Değerleme / Hisse / Koltuk | Valuation / Equity / Seat(s) | Koltuk iki anlamda da (lisans + yönetim kurulu) seat. |
| Yatırımcı iştahı | Investor appetite | Series A kapısının tek oyuncu-yüzü; rakam asla basılmaz. |
| KAPALI · ISINIYOR · AÇIK *(iştah çipi)* | CLOSED · WARMING · OPEN | Üç durum; çip ALL-CAPS iki dilde. |
| Gelir çıtası | Revenue bar | Kapının gelir koşulunun RAKAMSIZ adı (`altında` / `aşıldı` ↔ `below` / `cleared`). |
| Araçlar | Tools | Gider dökümünün yazılım, lisans ve donanım kalemi (`FIN_BURN_TOOLS`); işten çıkarma onayında "Aylık araç gideri ↔ Monthly tools". TR/EN onay bekliyor. |
| Servis maliyeti | Service costs | Müşteriyle ölçeklenen gider kalemi (`FIN_BURN_SERVICE`); "Sunucular ↔ Servers" faturasından ayrı. TR/EN onay bekliyor. |
| Brüt marj | Gross margin | MRR − sunucu faturası − servis maliyeti. Bugün ekranda yok. |
| Kesinti gideri · Güvenlik denetimi · Bağlılık primi · Dış kaynak ücreti · Tanıtım kampanyası · İadeler · Yan iş · Topluluk buluşması · Sponsorluk · Alan adı · Kullanıcı denemesi · Fuar standı | Incident costs · Security audit · Retention bonus · Contractor fee · Outreach campaign · Refunds · Side contract · Meetup · Sponsorship · Web address · User tests · Trade fair | İşlem listesinde olay kartlarının tek seferlik satırları (`FIN_ONETIME_*`). TR/EN onay bekliyor. |

## 3. Build & ürün

| TR | EN | Not |
|---|---|---|
| TASARIM / GELİŞTİRME / TEST / BETA | DESIGN / DEVELOPMENT / TEST / BETA | Build fazları + HR bölümleri ortak. |
| GELİŞTİR → | BUILD → | Türün fiili build. |
| Yayınla → | Ship → | Founder'lar ship eder; "Publish" app-store kaydı. |
| Sürüm / İlk sürüm | Release / First release | |
| Özellik | Feature | |
| Hata / hata riski | Bug / bug risk | TR ekranda asla "bug" demez. |
| Kararlılık *(monitör)* | Stability | Pitch KARARLILIK'ından AYRI anlam — anahtar paylaşılmaz. |
| Teknik borç | Tech debt | |
| Geliştirme bekleniyor | Awaiting development | |
| sprint | sprint | `PRODUCT_SPRINT_TITLE` ve ürün ekranı; CSV cümle düzeninde, büyük hâli `Fmt.upper` ile SPRİNT. "sprint" izinli ödünç kelimelerde yok: TR onay bekliyor. |
| PM | PM | `PRODUCT_PM`, Ürün Yöneticisi'nin çip kısaltması. "PM" izinli ödünç kelimelerde yok: TR onay bekliyor. |
| ticket | ticket | `PRODUCT_CUSTOMER_TICKETS`, `PRODUCT_FX_TICKETS_*`. "ticket" izinli ödünç kelimelerde yok: TR onay bekliyor. |
| puan *(efor)* | points | Tekil: point (`_ONE`). |
| alan *(ürün)* | area | ALANLAR / AREAS. |
| yetenek | capability | Alanın altındaki yapılmış iş. |
| ses *(kullanıcı)* | voice | SESLER / VOICES; kart fiili "ses kapatır" ↔ "settles {n} voices". |
| talep | request | Müşterinin ürün talebi; satıştaki "aday ↔ lead" ile karışmaz. |
| lider *(build)* | lead | LİDERİN ÖNERİSİ / LEAD'S PICK. Satıştaki "aday ↔ lead"den ayrı anahtar ailesi. |
| devreden | carried over | Kart damgası küçük harf: devreden / carried. |
| sürüm notu | release note | |
| hız *(sprint)* | velocity | HIZ / VELOCITY. Kişi ekseni "Hız ↔ Pace"ten ayrı anlam. |
| düzeltme koşusu | fix run | DESTEK'in doğrulanmış hataları eriten koşusu; olay çipi "Düzeltme başlar ↔ A fix run starts" (`EFFECT_FIX_RUN_STARTS`). TR/EN onay bekliyor. |

## 4. İnsanlar — eksenler, roller, bölümler, bantlar, HR

| TR | EN | Not |
|---|---|---|
| Uzmanlık / Hız / Uyum | Expertise / Pace / Rapport | Eksen id'leri zaten `expertise/pace/rapport`. |
| **Deneyim** | **Experience** | Terminal UI deltası (`HR_COL_EXPERIENCE` shipped) — kanon. |
| **Eğitim / Eğitim ücreti** | **Training / Training fee** | Terminal UI deltası; `hr_constants COST_LABEL_TRAINING` B2'de anahtarlanır. |
| Kurucu | Founder | |
| Ürün Yöneticisi / Tasarımcı / Yazılımcı | Product Manager / Designer / Developer | |
| Test Uzmanı | Tester | Yedi kişilik ekipte "QA Engineer" org-şeması kaçağı olur. |
| Satış Uzmanı | Sales Rep | |
| Müşteri Temsilcisi | Account Manager | Shipped (`SALES_STEWARD`). |
| Operating Partner | *aynı* | **BYTE-EXACT, çevrilmez** (`hr_constants.gd` şerhi). |
| Ürün Geliştirme / Satış / Müşteri *(bölümler)* | Product Development / Sales / Customer Success | CS, sistemlerin kendi terimi; çip uzunluğu görsel geçitte ölçülür. |
| ekonomik / dengeli / üst segment *(maaş bantları)* | budget / balanced / premium | Küçük harf TR gibi. |
| Kaçma riski / Tükeniyor / Aşırı yüklü / Yeni | Flight risk / Burning out / Overloaded / New | |
| İzinde / Yarın başlıyor | On leave / Starts tomorrow | |
| İzin / Tatil | Leave / Holiday | İki ayrı durum: HR_NEWS_ON_LEAVE ve HR_NEWS_ON_HOLIDAY. |
| EK MESAİ · {n}. GÜN | OVERTIME · DAY {n} | |
| 3 gün / 1 hafta / 2 hafta | 3 days / 1 week / 2 weeks | Mesai blokları. |
| ARAYIŞ BAŞLAT / ARAYIŞI İPTAL ET | START SEARCH / CANCEL SEARCH | Üç ayrı yazımın tek anahtar ailesi. |
| Aday dosyası | Candidate file | |
| Ekip dosyası | Team dossier | Kişinin ayrıntı penceresi (`hr_dossier`). |
| İşe alım / Kıdem tazminatı | Hiring / Severance | |
| ZAMMI UYGULA | APPLY RAISE | |
| İK | HR | Rayda ve ticker'da: TR İK der, EN HR. |

## 5. Satış, B2B, pitch, VC

| TR | EN | Not |
|---|---|---|
| Müşteri | Customer | |
| aday | lead | Sayımlar ve akış (`{n} leads`). |
| prospect | prospect | Panodaki varlık. Kural: **lead gelir, prospect panoda oturur** — shipped ayrım kanonlaştı. |
| Memnuniyet | Satisfaction | |
| Churn'e ~{n} hafta | ~{n} weeks to churn | Tekil: ~1 week to churn (`_ONE`). |
| Söz / Söz teslimi | Promise / Promise due | |
| söz verildi | promised | Sözlü sprint kartının damgası (`PRODUCT_PROMISED`), küçük harf. TR/EN onay bekliyor. |
| Söz: {müşteri} / sözü tutulur | Promise: {customer} / promise kept | Kartın etki satırı ve sprint öngörüsü (`PRODUCT_FX_PROMISE`, `PRODUCT_FX_PROMISE_KEPT`). TR/EN onay bekliyor. |
| Sprint {n} sonuna kadar | by the end of sprint {n} | Sözün son tarihi (`SALES_PROMISE_OPEN_SPRINT`); tür seçilmeden verilen söz hafta okur. TR/EN onay bekliyor. |
| yer yok | no room | Sığmayan sözün kilidi: "Bir sonraki sprintte buna yer yok." ↔ "There is no room for it in the next sprint." (`SALES_LOCK_PROMISE_NO_ROOM`). TR/EN onay bekliyor. |
| VC görüşmesi | VC meeting | |
| Teklif / TEKLİF · {n} HAFTA | Offer / OFFER · {n} WEEKS | Tekil: OFFER · 1 WEEK (`_ONE`). |
| SABIR | PATIENCE | Term-sheet kolu. |
| MASADAN KALK | WALK AWAY | Kısa ve soğuk; "LEAVE THE TABLE" değil. |
| SOĞUK / ILIK / KAZANILDI | COLD / WARM / WON | Pipeline sıcaklık kaydı. |
| KARARLILIK *(pitch radarı)* | RESOLVE | Monitör "kararlılık·stability"den ayrı anahtar. |
| İlgilen | Check in | **Kapı kararı 2** — shipped "Attend" revize edildi. |
| Değerlendir / Görüşmeye git | Evaluate / Go to meeting | Shipped. |
| NÖTR *(ilişki pili)* | NEUTRAL | Etiket tablosunun ilk satırı; bugün ham enum basılıyor. |

## 6. Dünya, haber, ending

| TR | EN | Not |
|---|---|---|
| Ekonomi Postası · TeknoGündem · Girişim Bülteni · Sektör Telgrafı | *aynı* | Mastheadler çevrilmez; gazetenin alt başlıkları/gövdesi lokalize olur. |
| SAYI {n} | No. {n} | Broadsheet kaydı ("ISSUE" dergi kaydı). |
| Rakip / Sektör | Rival / Sector | |
| ZOR MOD / GAZETEYİ PAYLAŞ | HARD MODE / SHARE THE PAPER | Shipped. |
| İlgi Söndü | Interest Faded | Yumuşak tavan bitişinin (running_on_fumes) başlığı `[WORKING]`. |
| KİLOMETRE TAŞI | MILESTONE | 2026-09-25: EA / tam build'de koşuyu bitirmeyen gazetenin ray başlığı (tekil; çoğulu ray etiketindeki "Kilometre Taşları"). |
| iki yılı aşkın sürede | in over two years | 2026-09-25: yalnız kilometre taşından sonra 730. günü geçen koşunun gazetesi (`END_SPAN_OVER_TWO_YEARS`). |

## 7. Chrome & ortak UI

| TR | EN | Not |
|---|---|---|
| Ürün / İK / Finans / Satış / Operasyon / Ar-Ge / Kişisel / Olaylar *(ray)* | Product / HR / Finance / Sales / Ops / R&D / Personal / Events | Tek `TAB_*` anahtar seti, iki İngilizce kaynak emekli. |
| Ayarlar | Settings | Rayın 9. etiketi de `TAB_SETTINGS`e girer. |
| Tamam / İptal / Vazgeç | OK / Cancel | TR iç kural: akıştan çıkış **Vazgeç**, koşan şeyi öldürme **İptal**. |
| DEVAM ET | CONTINUE | Kilometre taşı gazetesi de aynı anahtarı (`UI_CONTINUE`) okur. |
| ANA MENÜ | MAIN MENU | 2026-09-25: kilometre taşı gazetesinin ikinci butonu. Sistem menüsündeki cümle hâli: "Ana menüye dön" / "Return to main menu". |
| Geri / İleri | Back / Next | Shipped. |
| Hafta {n} / H{n} *(tarih)* | Week {n} / W{n} | Tam biçim DATE_LINE'da, kısa biçim TopBar ve işlem listesinde. |
| Çeyrek / {n}. Çeyrek | Quarter / Q{n} | |
| Özet sıklığı · Her hafta / Her ay / Her çeyrek / Her yıl | Summary frequency · Every week / month / quarter / year | |
| bu hafta / gelecek hafta | this week / next week | Göreli hafta; "önümüzdeki hafta" ya da "haftaya" kullanılmaz. "Hafta sonu" yazılmaz (hafta sonu yok; `SUMMARY_AUTO_WEEK` "haftanın sonunda" der). |
| Bildirim yığını | Notice stack | Ofisin sağ altı: Frank'in son notu ve masadaki kâğıtlar. |
| Kilometre Taşları / SIRADA NE VAR? / KURUCU | Milestones / WHAT'S NEXT? / FOUNDER | Shipped. |
| Sıfırdan | Self-Made | **Kapı kararı 5 `[WORKING]`** — TR adı lokalize edildi (eski: Self-Made aynı). |
| Mirasyedi | The Heir | **Kapı kararı 5 `[WORKING]`** (eski TR: Varis). |
| Kurumsal Firari | Corporate Refugee | **Kapı kararı 5 `[WORKING]`** (eski TR: Kurumsal Mülteci). |
| Frank'ten not | A note from Frank | Shipped. |
| FK *(avatar)* | FK | Aynı; dört hardcode tek anahtara iner. |

## 8. Ofis

| TR | EN | Not |
|---|---|---|
| Ofis | Office | Merkez görünüm ve kademesi. |
| Ev *(ofis)* | Home | Kademenin ilki, kurucunun dairesi. |
| İş hanı | Business block | |
| Plaza katı | Plaza floor | |
| Depo loft | Warehouse loft | |
| Masa | Desk | Kart hücresi MASA / DESKS. |
| KİRA / AY | RENT / MO | Harita kartı hücresi. |
| Taşınma | Move | Kart hücresi TAŞINMA / MOVE. |
| Şartlar | Requirements | Kart başlığı ŞARTLAR / REQUIREMENTS. |
| Kademe | Tier | Ürün hattının kademesi (K1–K3) de aynı çift. |
| Taşınabilir | Can move | Kartın durum çipi. |
| Ofisi taşı | Move the office | Ofisin sol altındaki düğme. |
| VP odaları | VP offices | `OFFICE_ROOM_VP_OFFICES`. "VP" izinli ödünç kelimelerde yok: TR onay bekliyor. |

## Shipped blok notları

- `SET_*` (35) · `SYS_*` (13) · `SAVE_*` (27) · `HR_*` yeni 26 anahtar: SaveLoad + Terminal UI
  task'ları tarafından çift dilli doğdular (2026-08-08/10) — shipped kanon; 9'u printf taşıyor,
  Step 1 migrasyonunda `{x}`e döner.
- Para biçimi: **kapı kararı 6, full flip** — TR `$1.234.567` / EN `$1,234,567`; `Fmt` uygular.
