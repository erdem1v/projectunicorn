# Lokalizasyon Sözlüğü — TR ↔ EN terim kanonu (2026-08-10, kapı kararları işlenmiş)

**BILINGUAL BIRTH LAW'un bağlayıcı eşlik dosyası** (CLAUDE.md, Content & Language Laws). Bir terimi bu
tablo yönetiyorsa, o terim bir daha ad-hoc çevrilmez — her yüzeyde buradaki karşılık kullanılır.
Kaynak ve gerekçeler: `docs/audits/localization_phase1_2026-08-07.md` §3; dokuz kapı kararı
(2026-08-08) işlenmiştir. Yeni terim ekleyen task bu dosyaya satırını da ekler.

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
| KEPENK: {n} GÜN | SHUTTER: {n} DAYS | Kepenk imgesi korunur — fiction'ın kendi metaforu. |
| Artıda | Default Alive | Örnek çift: EN yerlisi tür terimi. |
| Brüt Runway | Gross Burn Runway | Kanon (ENDGAME §Package 5). |
| KASA | CASH | TopBar; TR tarafı yeni. |
| BURN | BURN | **Kapı kararı 4** — whitelist'te; TR TopBar BURN kalır. |
| NET / MRR | NET / MRR | Aynı. |
| MARKA / İTİBAR | BRAND / REPUTATION | |
| TUR AÇ | OPEN ROUND | |
| Toplanan | Raised | |
| Ay kapanışı | Month close | |
| Pazar payı | Market share | |
| Değerleme / Hisse / Koltuk | Valuation / Equity / Seat(s) | Koltuk iki anlamda da (lisans + yönetim kurulu) seat. |

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

## 4. İnsanlar — eksenler, roller, bölümler, bantlar, HR

| TR | EN | Not |
|---|---|---|
| Uzmanlık / Hız / Uyum | Expertise / Pace / Rapport | Eksen id'leri zaten `expertise/pace/rapport`. |
| **Deneyim** | **Experience** | Terminal UI deltası (`HR_COL_EXPERIENCE` shipped) — kanon. |
| **Eğitim / Eğitim ücreti** | **Training / Training fee** | Terminal UI deltası; `hr_constants COST_LABEL_TRAINING` B2'de anahtarlanır. |
| Kurucu | Founder | S2-42 çifti. |
| Ürün Yöneticisi / Tasarımcı / Yazılımcı | Product Manager / Designer / Developer | |
| Test Uzmanı | Tester | Yedi kişilik ekipte "QA Engineer" org-şeması kaçağı olur. |
| Satış Uzmanı | Sales Rep | |
| Müşteri Temsilcisi | Account Manager | Shipped (`SALES_STEWARD`). |
| Operating Partner | *aynı* | **BYTE-EXACT, çevrilmez** (`hr_constants.gd` şerhi). |
| Ürün Geliştirme / Satış / Müşteri *(bölümler)* | Product Development / Sales / Customer Success | CS, sistemlerin kendi terimi; çip uzunluğu görsel geçitte ölçülür. |
| ekonomik / dengeli / üst segment *(maaş bantları)* | budget / balanced / premium | Küçük harf TR gibi. |
| Kaçma riski / Tükeniyor / Aşırı yüklü / Yeni | Flight risk / Burning out / Overloaded / New | |
| İzinde / Yarın başlıyor | On leave / Starts tomorrow | |
| EK MESAİ · {n}. GÜN | OVERTIME · DAY {n} | |
| 3 gün / 1 hafta / 2 hafta | 3 days / 1 week / 2 weeks | Mesai blokları. |
| ARAYIŞ BAŞLAT / ARAYIŞI İPTAL ET | START SEARCH / CANCEL SEARCH | Üç ayrı yazımın tek anahtar ailesi. |
| Aday dosyası | Candidate file | |
| İşe alım / Kıdem tazminatı | Hiring / Severance | |
| ZAMMI UYGULA | APPLY RAISE | |
| İK | HR | Rayda ve ticker'da: TR İK der, EN HR (S3-30 kapanışı). |

## 5. Satış, B2B, pitch, VC

| TR | EN | Not |
|---|---|---|
| Müşteri | Customer | |
| aday | lead | Sayımlar ve akış (`{n} leads`). |
| prospect | prospect | Panodaki varlık. Kural: **lead gelir, prospect panoda oturur** — shipped ayrım kanonlaştı. |
| Memnuniyet | Satisfaction | |
| Churn'e ~{n} gün | ~{n} days to churn | |
| Söz / Söz teslimi | Promise / Promise due | |
| VC görüşmesi | VC meeting | |
| Teklif / TEKLİF: {n} GÜN | Offer / OFFER: {n} DAYS | |
| SABIR | PATIENCE | Term-sheet kolu. |
| MASADAN KALK | WALK AWAY | Kısa ve soğuk; "LEAVE THE TABLE" değil. |
| SOĞUK / ILIK / KAZANILDI | COLD / WARM / WON | Pipeline sıcaklık kaydı. |
| KARARLILIK *(pitch radarı)* | RESOLVE | Monitör "kararlılık·stability"den ayrı anahtar. |
| İlgilen | Check in | **Kapı kararı 2** — shipped "Attend" revize edildi. |
| Değerlendir / Görüşmeye git | Evaluate / Go to meeting | Shipped. |
| NÖTR *(ilişki pili)* | NEUTRAL | S3-20 etiket tablosunun ilk satırı; bugün ham enum basılıyor. |

## 6. Dünya, haber, ending

| TR | EN | Not |
|---|---|---|
| Ekonomi Postası · TeknoGündem · Girişim Bülteni · Sektör Telgrafı | *aynı* | Mastheadler çevrilmez; gazetenin alt başlıkları/gövdesi lokalize olur. |
| SAYI {n} | No. {n} | Broadsheet kaydı ("ISSUE" dergi kaydı). |
| Rakip / Sektör | Rival / Sector | |
| ZOR MOD / GAZETEYİ PAYLAŞ | HARD MODE / SHARE THE PAPER | Shipped. |

## 7. Chrome & ortak UI

| TR | EN | Not |
|---|---|---|
| Ürün / İK / Finans / Satış / Operasyon / Ar-Ge / Kişisel / Olaylar *(ray)* | Product / HR / Finance / Sales / Ops / R&D / Personal / Events | S2-34: tek `TAB_*` anahtar seti, iki İngilizce kaynak emekli. |
| Ayarlar | Settings | Rayın 9. etiketi de `TAB_SETTINGS`e girer. |
| Tamam / İptal / Vazgeç | OK / Cancel | TR iç kural: akıştan çıkış **Vazgeç**, koşan şeyi öldürme **İptal**. |
| DEVAM ET | CONTINUE | |
| Geri / İleri | Back / Next | Shipped. |
| ODAYA DÖN | BACK TO ROOM | Shipped. |
| Kilometre Taşları / SIRADA NE VAR? / KURUCU | Milestones / WHAT'S NEXT? / FOUNDER | Shipped. |
| Sıfırdan | Self-Made | **Kapı kararı 5 `[WORKING]`** — TR adı lokalize edildi (eski: Self-Made aynı). |
| Mirasyedi | The Heir | **Kapı kararı 5 `[WORKING]`** (eski TR: Varis). |
| Kurumsal Firari | Corporate Refugee | **Kapı kararı 5 `[WORKING]`** (eski TR: Kurumsal Mülteci). |
| Frank'ten not | A note from Frank | Shipped. |
| FK *(avatar)* | FK | Aynı; dört hardcode tek anahtara iner. |

## Shipped blok notları

- `SET_*` (35) · `SYS_*` (13) · `SAVE_*` (27) · `HR_*` yeni 26 anahtar: SaveLoad + Terminal UI
  task'ları tarafından çift dilli doğdular (2026-08-08/10) — shipped kanon; 9'u printf taşıyor,
  Step 1 migrasyonunda `{x}`e döner.
- Para biçimi: **kapı kararı 6, full flip** — TR `$1.234.567` / EN `$1,234,567`; `Fmt` uygular.
