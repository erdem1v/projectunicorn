# Kişisel, Ar-Ge, araştırma kartı, Pazarlama · A4 ekran maketleri (grup "kisisel_arge")

Onaylı Menajer Masası diliyle, tam kabuk içinde. Hepsi onay bekliyor.

## Kaynaklar

- **Sistem olduğu gibi kullanıldı:** `../../system/tokens.css`, `base.css`, A2 ikonları, kırpım kuralı ve üst bar ızgarası.
  - Sistem klasörüne hiçbir şey yazılmadı.
  - Kit kopyaları ve önbellekleri `tools/syskit/`'te.
  - Sistemin eksikleri `kisisel_arge.css`'te (aşağıda "Yeni bileşenler").
- **Kabuk "kabuk" grubundan, canlı (r5'ten beri):**
  - `tools/gen.py`, `../kabuk/tools/gen.py`'yi her çerçeve dilinde yeniden yükler (yalnız okunur, kabuk klasörüne bytecode
    yazılmaz) ve `../kabuk/kabuk.css`'i bağlar.
  - Kabuktan gelenler: üst bar (karar 14 (a)), ray, haber şeridi, `noicons` ofis plakaları ve A2 kafa sprite'ları
    (`*_heads.json` konumlarında), BuildHUD (tohumda "Düzeltme başlat" kapalı + "Doğrulanmış hata yok."), bildirim yığını
    (`SEED_INBOX`: Nordica · Bir ekip daha · 2 hafta, Ege Sigorta, Selin Kaya), Ofisi taşı (boşta / tutulu), tohum değerleri
    (`SEED`, `V_CHEQUE`, `V_WEEK1`), araştırma kartının bileşeni (`.rb`).
  - Kabuk değişince çerçeveler `python tools/gen.py` ile kendiliğinden izler.
- **Mail grameri "olaylar" grubundan (anlık kopya):**
  - `tools/mail_gen.py`: `../olaylar/tools/gen.py`'nin anlık kopyası (md5 c296f1c6, 20:39).
  - `mail.css`: `../olaylar/olaylar.css`'in kopyası.
  - Kopyadan kullanılanlar: Olaylar penceresi, mail başlığı, gövde, imza, kutu satırları. Üst bar ve ray artık kabuktan.
  - Olaylar grameri değişirse iki dosya yeniden kopyalanır.
- **Portreler ve oyuncu metni:**
  - Kurucu: `portraits/founder_01.png`.
  - Çalışan büstleri: `art/bust_*.png`.
  - Yağlı boyalar yok.
  - Mevcut her oyuncu metni üretim anında `localization/strings.csv`'den okunur (yalnız okunur). Önerilen CSV değişiklikleri
    `gen.py`'de `CSV_CHANGE`'te ve aşağıdaki tabloda.

**Yeniden üretmek:**
1. `python tools/gen.py` (HTML'ler `build/`'e).
2. `bash tools/render_all.sh <tur>` (PNG'ler bu klasöre, kopyaları `rounds/<tur>/`'e).
   - `_1536` çerçeveleri 1536×864 mantıksal, ölçek 1.25 ile çizilir.

**Turlar:**
- **r1:** 18 çerçeve, hepsi tam boy okundu.
- **r2:**
  - kutucuk adları bölünüyordu;
  - detay kartı pencereden taşıyordu;
  - Kişisel'de sağ sütun taşıyordu;
  - atama satırında ad kesiliyordu.
- **r3:**
  - kilometre taşı notu tam genişliğe alındı;
  - EN bildirim TR kalmıştı, düzeltildi;
  - Ar-Ge kapalı penceresi içeriğe göre kısaldı.
- **r4:** parçalar sayfası, çapraz işaret.
- **r5 (A4 incelemesi, `../_critique/satis_finans_kisisel_arge/`):** 18 çerçevenin hepsi yeniden üretildi, tam boy ve 1:1
  kırpımlarla okundu.
  - Kabuk canlı içe alındı: kafa ikonları, kapalı DESTEK eylemi, Ofisi taşı, yığın, Sıradaki, araştırma kartı (bulgu 1, 2, 3,
    15, 16).
  - `kisisel__1536`'da BuildHUD, kart ve yığın göründü (bulgu 4).
  - Ağaç anahtarı pencere başlığından ağacın ayağına indi (bulgu 11).
  - Frank sonrası kasa $35.000 (bulgu 12).
  - Keşif kutusu tek zaman çizelgesinden yeniden kuruldu (bulgu 13).
  - Mert'in izin satırı (bulgu 14).
  - Karar beklerken yüzen öğeler (bulgu 17), H15/H16 değerleri (bulgu 26), keşif mailinde tekrar eden satır (bulgu 27),
    Sıfırdan ve Series A Avı (bulgu 28).
  - S3: ağaç penceresi içeriğe göre (31), atama seçim imi ve tek görev metni (35), huylarda YAKINDA (36), kılavuz çizgisi (39),
    Pazarlama yalnız harness yüzeyi (41).

1:1 kırpımlar ve temas sayfası `rounds/crops/`'ta (r4'e kadar).

## Veri: neyin nereden geldiği

**Tohum (`main.gd _seed_theme_surface`, hafta 14, 11:00, İş hanı), kabuk grubunun değerleriyle:**
- üst bar `kabuk.SEED`; hız tuşu II (tohumda saat tutulu);
- Sıradaki "14:00 · Karadeniz Fabrika", 14:00 elması;
- ray rozetleri `kabuk.B14` (Satış 1, Ekip 1); Ar-Ge rozeti aşağıdaki kuralla (soru 21); Olaylar rozeti yok
  (`EventGate.queue_size()` = 0);
- bildirim yığını `kabuk.SEED_INBOX`;
- BuildHUD `kabuk.buildhud(..., "seed")`.

**Ar-Ge rozeti (`RnDSystem.attention_count()` = okunmamış not + donmuş araştırma; koşan araştırma sayılmaz):**
- dal A, H14: 1 (14. hafta aylık notu okunmamış);
- dal B, H15: 2 (not okunmamış + donmuş araştırma);
- H16: 0 (not okundu; keşif bugünkü kuralla sayılmaz, soru 3).

**Kurucu:**
- `_debug_payload`: beceri dağılımı ürün 1, yazılım 2, satış 2, karizma 1. `RULER_SCALE` 2 ile ekrandaki değerler 2 / 0 / 4 / 0
  / 4 / 0 / 0 / 2 olur.
- Köken `self_made`, portre `founder_01`.
- `founder_name` boş. Ad `HR_ROLE_FOUNDER` ("Kurucu") olur.
- Görev `HR_TASK_ON_JOB_BUILD` (çalışanlarla aynı metin, soru 22), deneyim %0.
- Eğitim düğmesi açık; baseline'da da açık.

### Ar-Ge zaman çizelgesi

Tohumda araştırma yok (baseline 0/20). Çizelge motor kurallarından türetildi.

**Hız** (`RnDSystem.research_per_day`, tik başına ×7):
- Formül: `effective_skill × saat/8 × K_ARGE(1,0)`.
- `effective_skill` = ham puan × alan katsayısı × odak × moral bandı × huy.

| Kişi | Hesap | Tik başına |
|---|---|---|
| Elif Demir · ürün | 7 × 1,0 | 49 |
| Deniz Arslan · tasarım | 6 × 0,85 (moral 38) | 35,7 |
| Selin Kaya · test | 5 × 0,85 (moral 22) × 0,85 (Titiz) | 25,3 |
| Kurucu · ürün | 2 | 14 |
| Kurucu · yazılım | 4 | 28 |

**Varsayım:**
- v1 **6. haftada** yayınlandı (Şubat 2026).
- Bu hafta, `user_research` 10. haftada bitsin ve ilk aylık not olaylar grubunun 14. hafta notuna denk gelsin diye seçildi.
- Not kuralı: bitişten 4 tik sonra, ilk PM ya da tasarımcının ağzından. Not satırları o çerçeveden aynen alındı.

**Sıra** (aynı anda tek araştırma, §5.1):

| Araştırma | Kim | Süre | Bitiş |
|---|---|---|---|
| `design_system` | Deniz | 50 / 35,7 → 2 tik | H8 |
| `user_research` | Deniz | 70 / 35,7 → 2 tik | H10 |
| `data_model` | Elif | 40 / 49 → 1 tik | H11 |
| `bug_tracker` | Selin | 40 / 25,3 → 2 tik | H13 |
| `test_automation` | Selin | H13'te başladı | H16 |

`test_automation`'ın 14. haftadaki hali:
- 25,3 / 70 = %36;
- kalan 44,7 / 25,3 = 1,77 → "~2 hafta kaldı";
- 3. tikte, 16. haftada biter.

**Dal A** (Selin kalır): ağaç, detay, atama, geçmiş, salt okunur, 1536, EN, keşif.

**Dal B** (Selin 14. haftada ayrılır; olaylar `calisan_ayrilik` ve `ayrilmis_gonderici`):
- 15. hafta tikinde atamadan düşer. Araştırma %36'da donar, gerekçe `BUILD_BUSY_NOBODY`.
- Mert izinde ve 1 hafta kaldı. Etkin becerisi 0 olduğu için `area_has_star` tutmaz ve atama `REFUSE_STARS` ile reddedilir.
- Ar-Ge rozeti 2, Ekip rozeti yok (Selin gitti).

**Tahminler:**
- `ai_engine` tek başına kurucuyla 90 / 14 = 6,4 → "~7 hafta (Kurucu)".
- Elif'le 90 / 49 = 1,84 → "~2 hafta".
- Bedeli $600. `PROD_RND_NODE_AI_ENGINE_COST` CSV'de yok, bu yüzden çıplak tutar görünür.

### H14'ten sonra tek zaman çizelgesi (H15, H16)

- **Frank'in teklifi H14'te kabul edildi.** Reddet kilitli ("Zor modda açılır.", olaylar `frank_teklif`), yani tek yol bu: kasa
  +$25.000, Melek %4. H16 kutusunda teklif "Cevaplandı · Seçimin: Kabul et" satırı.
- **Burak'ın H15 raporu** H14'te kapanan Karadeniz Fabrika ve Efes Emlak'ı yazıyor (+$1.620/ay): MRR $4.000 → $5.620 ($5,6K),
  NET +$4,1K/ay.
- **Kasa, tik kuralıyla** (`FinanceSystem.daily_tick`): gelir round(5.620 / 30) = 187 × 7 = 1.309, gider 50 × 7 = 350, tik
  başına +959.
  - H15: 35.000 + 959 = **$35.959**.
  - H16: **$36.918**.
- **BURN tohumdaki $1,5K'da tutuldu.** Tohum saati tuttuğu için maaş yükünü ($43.600) yansıtmıyor; ilk tik onu yeniden
  hesaplardı. Olaylar ve kabuk grupları da tohumun burn'ünü tutuyor.
- **Nordica'nın kağıdı:** H14'te 2 hafta, H15'te "bu hafta" (uyarı), H15 sonunda süresi doldu. H16'da yığında ve kutuda yok
  (süresi dolan kağıdın satırı olaylar grubunun kuralı, soru 23).
- **Gün sınırında ateşlenen mesaj saat yazmaz.** Tarihler `get_date_dict` kuralıyla (olaylar grubunun `date()`'i).

### Kişisel

**Kilometre taşları:**
- İlk sürüm "Şubat 2026", yukarıdaki varsayımdan.
- Tohum `mvp_shipped` yazıyor ama `mvp_launch_day` yazmıyor. Bu yüzden baseline'da taş kazanılmamış görünüyor (soru 10).
- İlk yatırım yalnız `run_investment_amount` ile kazanılır (Series A). Frank'in çeki saymaz (soru 9).
- Frank'ten sonra:
  - `run_angel_equity_pct` = 4;
  - kurucu payı 100 − 4 = %96;
  - etiket `ANGEL_CAP_ROW` "Melek · %4".

## Çerçeveler

Pencere kuralı (SPEC §9): BuildHUD, araştırma kartı, bildirim yığını ve Ofisi taşı açık pencerenin dikdörtgenine değerse
gizlenir. Her çerçevede hesap aşağıda.

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `kisisel__normal.png` | Kişisel penceresi (1000×680, x 208 ile 1208). Sütunlar: (1) 256×320 portre kuyusu, görev, deneyim, Eğitime gönder; (2) ad, köken etiketi SIFIRDAN, köken sözü (serif), beceriler, huylar (başlıkta YAKINDA etiketi + sekiz nötr yuva); (3) kilometre taşları, nerede duruyorum (Bootstrap, Traction, Series A Avı), net servet. Başlık KPI'ı "Kıdem 14. hafta". Sağda BuildHUD + araştırma kartı, yığın; sol altta Ofisi taşı (pencere 768'de biter, düğme 972'de). | Tohum (kabuk) + kurucu yükü + çizelge | `.per`, `.fsk`/`.meter`, `.trslot`, `.ms`, `.phl`, `.goalbox`, `.capbar` | Kıdem, {n}. hafta; evre adları; iki tiresiz yeniden yazım | 9, 10, 11, 12, 13, 22 |
| `kisisel__normal_en.png` | Aynısı İngilizce (SELF-MADE, Series A Hunt, TRAITS · SOON). | Aynı; EN değerleri CSV'den | | Tenure, Week {n} | |
| `kisisel__frank_sonrasi.png` | Frank'in çeki kabul edildikten sonra: KASA $35.000 (`kabuk.V_CHEQUE`; NET, RUNWAY, MRR değişmez), pay çubuğu Kurucu %96 + Melek %4. İlk yatırım hâlâ kazanılmamış (kod öyle). | Olaylar `frank_teklif` (+$25K, %4) + `get_investor_equity_pct` | `.capbar` iki dilim | | 9 |
| `kisisel__1536.png` | 1536×864 mantıksal: simge rayı, sıkışık üst bar (yalnız turuncu kare), pencere x 88 ile 1088, y 88 ile 768. BuildHUD (1192) + araştırma kartı ve yığın (1160) pencerenin sağında kalır, görünür. Ofisi taşı (88, 756) pencerenin altında kalır, gizli. | Aynı | | | |
| `arge__agac.png` | Ar-Ge, seçim yok. Pencere içeriğe göre 1280×522: başlıkta KPI ("Tamamlanan 4 / 20"), kontrol şeridinde Ağaç / Geçmiş ve koşan araştırma satırı (bağlar "duraklat · ata"), 4 aile sütunu, kafes kuralı, ayakta ağaç anahtarı ve "Araştırdıkça açılır." Ayrılmış boş kart şeridi yok. | Çizelge, dal A | `.rfoot`, `.rcol-h`, `.rn` (ayak, `.rp`, `.lk`), `.rline` | Ağaç, Geçmiş, Tamamlanan, {done} / {total} | 1, 2, 16 |
| `arge__detay.png` | AI Engine seçili; pencere 1280×820'ye uzar (ağaç yerinde kalır). Kılavuz çizgisi dal kutucuğunun koridora bakan yanından çıkar, koridordan karta iner (ink-2, kendi devam kenarının üstünden geçmez). Detay kartı iki sütun genişliğinde, kesik köşeli belge: tanım, Açtığı şey, gereksinim çipleri (Ürün ★2 · ~7 hafta (Kurucu) · $600), geçiş notu, amber Başlat. | Çizelge; düğüm metinleri CSV | `.rdp`, `.req-p`, `.rdp-line`, `.re-guide`, `.rn.is-selected` | "Başlatınca {node} durur; ilerlemesi korunur." | 6, 7 |
| `arge__detay_en.png` | Aynısı İngilizce (en uzun sütun başlıkları, düğüm adları ve anahtar; ayak satırı 1036'da biter, ipucu 1316'da başlar). | Aynı | | Starting this stops {node}. Its progress is kept. | |
| `arge__atama.png` | Atama paneli kartın içinde: alan grubu "Ürün (3)" + KARŞILANDI; satırlar onay kutusu, 24 yüz, ad, rol · iş, alan becerisi sabit sayı sütununda (ramp). Elif seçili: dolgu + 3 px im. Kurucu ve çalışanlar aynı görev metniyle ("Yapımda görev alıyor"). Alt şerit "Ürün alanı · ~2 hafta", Geri, Başlat. | Havuz `eligible_assignees`; hız yukarıda | `.asg`, `.asg-g`, `.asg-r` (+ im), `.asg-f` | (yeniden harf) Geri | 19, 22 |
| `arge__donmus.png` | Dal B, H15: Test Otomasyonu donmuş (kutucuk "dal · ‖ donmuş", şerit ve kart "Kimse üzerinde değil.", yalnız "ata" bağı). Mert'in satırı izin satırı: gri yüz, ad ink-3, ad hücresinde İZİNDE + "1 hafta", sayı sütunu kurucununkiyle aynı hizada (7, sayılar değişmez). Kapalı Uygula'nın altında: "Mert Yıldız izinde · katkı yok" + "Test ★2 gerekiyor." Üst bar H15 ($35.959, MRR $5,6K, NET +$4,1K), yığında Nordica "bu hafta" (uyarı) + Ege. Ekip rozeti kalktı, Ar-Ge 2. | Dal B türetmesi; H15 zaman çizelgesi | `.rn.is-frozen`, `.rline.is-frozen`, `.rb.is-paused` (kabuk), `.asg-r.is-away`, `.asg-why` | {name} izinde · katkı yok; (yeniden harf) Uygula | 18 |
| `arge__gecmis.png` | Ar-Ge'nin kendi geçmiş görünümü (1280×780): solda notlar ve keşifler tarih sırasıyla (gün ayraçlı kutu satırları; konu hapı yok), sağda aynı mail okuma bölmesi. Seçili 14. hafta aylık notu (okunmamış); tek düğme "Ürün sayfasına git". | Not = olaylar `arge_notu`; keşif gövdeleri `PROD_RND_NODE_*_DISCOVERY` | `.hist`, sağda "keşif" türü | keşif (satır türü) | 2, 5 |
| `arge__salt_okunur.png` | Karar beklerken Ar-Ge: pencere 860'a uzar (şerit 40), "Karar bekliyor. Bu pencere yalnız okunur. Frank Köseoğlu · Teklif" + Karara dön. Kapalı: şeritteki bağlar, Başlat ("Önce bekleyen kararı cevapla."). Yüzen öğeler: BuildHUD tohumdaki gibi kendi gerekçesiyle kapalı; araştırma kartının bağları kapalı + "Cevap bekliyor"; Ofisi taşı tutulu + "Cevap bekliyor" (kabuğun `ustbar__karar_bekliyor`'u gibi). Kutucuklar seçilebilir. | Tohum + olaylar kapısı | `.rb-ft .lk.is-disabled`, `.rb-ft .why` | (SPEC) | 20 |
| `arge__kapali.png` | v1 öncesi (H1 10:00, ev): tek satır "Ar-Ge, ilk sürümünü yayınladıktan sonra açılır."; pencere içeriğe göre 1280×320. BuildHUD ve yığın yok, Ofisi taşı var (kabuğun `ustbar__runway_ay`'ı gibi). | `RnDSystem.tree_open()` false; üst bar `kabuk.V_WEEK1` | `.wait` | | 16 |
| `arge__1536.png` | 1536'da Ar-Ge 1280×712: gövde kayar (kaydırma çubuğu), başlık, kontrol şeridi ve ağacın ayağı sabit; AI Engine seçili. Pencere (88 ile 1368) BuildHUD'a, yığına ve Ofisi taşına değer: üçü gizli. | Dal A | | | |
| `arge__parcalar.png` | Parça sayfası (kabuksuz, 1:1): araştırma kartının beş hali (sürüyor ve ata üstünde, donmuş: kimse yok / ekip yapımda, atanmış ama katkı yok, karar beklerken), BuildHUD ile istif, kontrol şeridi satırı (sürüyor, donmuş), yedi düğüm hali, boş geçmiş, ağacın ayağı. | Aynı türetmeler | `.sheet` | "Henüz bir şey yok. Notlar ve keşifler burada toplanır." | 1, 8 |
| `olaylar__arge_kesif.png` | Keşif mail olarak kutuda (H16): Selin Kaya'dan "Test Otomasyonu", künye ÜRÜN · Keşif, gövde = keşif beat'i, belge kutusu "Açtığı şey" (açılış satırı, adlanan devam yuvası; açılış satırı hattın adını zaten söylediği için ayrı "Yeni özellik hattı açıldı" satırı yok), imza, Ar-Ge'ye git + Ürün sayfasına git. Ekonomik çip yok (§5.8). Liste tek zaman çizelgesinden (aşağıda); kayar. Üst bar H16. Pencere (88 ile 988) Ofisi taşının dikdörtgenine (972) değer: düğme gizli. | Dal A, `test_automation` H16'da biter; metin CSV | `.disc-box`, künye türü Keşif, liste kaydırma çubuğu | Keşif / Discovery | 3, 4, 23 |
| `ofis__kesif_bildirimi.png` | Pencere yokken H16: araştırma kartı kayboldu (%100), yığında en üstte "Selin Kaya · Test Otomasyonu" (bilgi noktası), sonra Ege ve Selin hatırlatıcıları. Ofisi taşı görünür. | Aynı | | | 3 |
| `ofis__arastirma_cubugu.png` | Pencere yokken H14: BuildHUD + araştırma kartı sağ üstte, yığın, Ofisi taşı, ofis karartmasız. | Dal A | | | |
| `pazarlama__yer_tutucu.png` | **Yalnız harness yüzeyi:** hiçbir yapıda açılmaz (ray satırı kilitli, tıklanmaz); `--tab-shot=marketing` çizer. Bu yüzden ray satırı etkin değil, kilitli kalır. Pencere 720×400: başlıkta YAKINDA etiketi, gövdede ikon + "İçerik yolda". Yüzen öğeler görünür. | `WIN_PAGE_PLACEHOLDER`, `SYS_SOON` | `.wait` | | 15 |

**H16 kutusu, yeniden kurulan liste** (yeniden en eskiye; dikkat satırları olaylar grameriyle en üstte):
1. Ege Sigorta · Risk altında (dikkat).
2. Selin Kaya · Ayrılabilir (dikkat; dal A'da kalıyor, Ekip rozeti 1).
3. H16: Selin Kaya · Test Otomasyonu (keşif, okunmamış, seçili).
4. H15: Burak Şahin · Haftanın satışları (rapor).
5. H14: Frank Köseoğlu · Teklif (Cevaplandı · Seçimin: Kabul et), Elif Demir · Aylık ürün notu (okundu), Muhasebe · 2. Çeyrek 2026.
6. H13: Selin Kaya · Hata Takip Sistemi (keşif).
7. H11: Elif Demir · Veri Modeli (keşif).
8. H10: Deniz Arslan · Kullanıcı Araştırması (keşif).
9. H8: Deniz Arslan · Tasarım Sistemi (keşif).
10. H1: Frank Köseoğlu · Ben Frank.

Süzgeç sayıları satırları sayar: Tümü 12, Bekleyen 0, Okunmamış 1. Pencere 1. ile 6. arasını gösterir; H11 ile H1 arası kaydırma
çubuğunun altında kalır.

Aylık notun kutudaki hali olaylar grubunun `olaylar__arge_notu.png`'sidir; bu grup aynı maili Ar-Ge geçmişinde gösterir (tek okundu
durumu: `RnDSystem.mark_note_read`).

## Yeni bileşenler (`kisisel_arge.css`, sistem grameriyle)

Araştırma kartı artık kabuğun bileşenidir (`../kabuk/kabuk.css` `.rb`, `kabuk/buildhud__durumlar.png`): ad + alan, ilerleme,
oyunun bağları "duraklat · ata" (CSV'deki gibi küçük harf). Duraklamış hallerde dolgu `line-3`, gerekçe `ink-2` ve duraklat bağı
gizli (`research_bar.gd`: `_pause_link.visible = not m.paused`). Bu grubun eski kartı (altıgen, atanan yüz, Barlow düğmeler)
kaldırıldı.

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.floatcol` | BuildHUD ve araştırma kartı aynı 320 px sütunda, 8 aralık | `BuildHUDPanel` VBox |
| `.rb-ft .lk.is-disabled`, `.rb-ft .why` | Kabuk kartına ek (öneri, kabuğa): karar beklerken bağlar kapalı ve gerekçe ("Cevap bekliyor"); pencere içindeki şeritte gerekçe yazılmaz, salt okunur şerit söylüyor | `research_bar.gd` |
| `.rfoot` | Ağaç anahtarı pencerenin ayağında (bugünkü oyundaki yer), sağda "Araştırdıkça açılır." | `rnd_tab` alt satırı, `RnDUiShared.Swatch` |
| `.hex` | Düğüm kimliği altıgen; çizgi kalınlığı mertebe (2 / 1,5 / 1) | `RnDUiShared.HexGlyph` (`_draw`) |
| `.rcol-h` | Aile başlığı parçalı: AİLE (grup), "{alan} alanı", sağda n/5 | üç Label |
| `.rn` ekleri | Ad üstte tam genişlik (2 satır), ayakta altıgen + mertebe + ✓ ya da çapraz işaret; `.rp` koşan/donmuş ilerleme kutucuğun alt kenarında 3 px; `.is-frozen` kesik kenar + duraklat glifi + "donmuş" (ink-2); `.is-selected` mürekkep + 3 px im; `.lk` kilitli yuva yazısı | `rnd_tree_view.gd` karoları |
| `.re-guide` | Seçili kutucuktan karta kılavuz, ink-2 2 px; dal kutucuğu koridora bakan yanından, devam kutucuğu ayağından, kök 6 px yandan çıkar | `_draw_guide` |
| `.rline` | Kontrol şeridindeki araştırma satırı (koşuyor / donmuş), bağlar kartınkiyle aynı (`.rb-ft`) | `rnd_tab._build_bar` |
| `.rdp` (+ `-h`, `-desc`, `-kv`, `-line`, `-acts`) | Düğüm kartı: iki sütun genişliğinde, 286 px sabit yükseklik, kesik köşeli belge | `RnDDetailPanel` |
| `.req-p` | Gereksinim çipi (alan + ★N, süre, bedel glifiyle nakit; nakit engelinde `.is-neg`) | HBox çip |
| `.asg` (+ `-g`, `-r`, `-f`, `-why`) | Atama: alan grubu + KARŞILANDI/EKSİK etiketi; 32 px satır, sabit sütunlar (onay, yüz, ad hücresi, beceri sayısı); seçili satır dolgu + 3 px im; izin satırı `.is-away` (ad ink-3, İzinde etiketi ve kalan hafta ad hücresinde); ret satırı gerekçe + neden sayılmadığı yan yana | `RnDAssignPanel` |
| `.per`, `.fsk`, `.meter` | Kurucu sayfası üç sütun; beceri satırı: ikon, etiket, beş çift hücre (bir çift = bir yıldız, ★N = ham ≥ 2N), sayı (ramp) | `personal_tab.gd`, `_draw` metre |
| `.trslot`, `.sec .tag` | Nötr huy yuvası (kesik kenar); bölüm başlığında YAKINDA etiketi | bugünkü `_frame` + `make_tag` |
| `.ms` | Kilometre taşları: dikey defter, kazanılan taşta `world/milestone` glifi, kazanılmayan boş halka | VBox |
| `.phl`, `.goalbox` | Evre merdiveni (etkin evre mürekkep + çubuk) ve evre hedefi kutusu | VBox |
| `.capbar`, `.caplg`, `.nw-note` | Pay çubuğu (kurucu `bar-emph`, ortak `bar-fill`) ve etiketi | `finance_ozet_view` pay tablosunun eşi |
| `.hist` | Ar-Ge geçmişi: kutu satırları + mail bölmesi; konu hapı gizli | olaylar sahneleri, süzülmüş |
| `.disc-box` | Keşif mailinde "Açtığı şey" belge kutusu (+ hattın adı açılış satırında yoksa yeni hat satırı) | mail gövdesi |
| `.wait` | Tek satırlık bekleme/yer tutucu gövdesi | `UiFactory.make_placeholder_column` koyu hali |

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `PER_TENURE_KEY` | Tenure | Kıdem | Kişisel başlık KPI'ı (`PER_TENURE` ikiye bölünür) |
| `PER_TENURE_VALUE` | Week {n} | {n}. hafta | aynı |
| `PER_NO_VALUATION` (yeniden yazım, tire) | No valuation yet. It is set at the first funding round. | Değerleme henüz yok. İlk yatırım turunda hesaplanır. | net servet |
| `PERSONAL_MS_SHIP_NOTE` (yeniden yazım, tire) | The product hit the shelves. Now the world plays too. | Ürün raflara çıktı. Artık dünya da oynuyor. | İlk sürüm notu |
| `PHASE_NAME_BOOTSTRAP` | Bootstrap | Bootstrap | Nerede duruyorum (bugün `GameState.phase_display_name` literal'i) |
| `PHASE_NAME_TRACTION` | Traction | Traction | aynı |
| `PHASE_NAME_SERIES_A_HUNT` | Series A Hunt | Series A Avı | aynı (`HUNT_PAGE_TITLE` ile aynı ad) |
| `RND_VIEW_TREE` / `RND_VIEW_HISTORY` | Tree / History | Ağaç / Geçmiş | Ar-Ge segment sekmeleri |
| `RND_TREE_DONE_KEY` / `_VALUE` | Completed / {done} / {total} | Tamamlanan / {done} / {total} | Ar-Ge KPI'ı (`RND_TREE_PROGRESS` ikiye bölünür) |
| `RND_SWITCH_NOTE` | Starting this stops {node}. Its progress is kept. | Başlatınca {node} durur; ilerlemesi korunur. | düğüm kartı, başka araştırma koşarken |
| `RND_NEED_AREA_AWAY` | {name} is on leave · no contribution | {name} izinde · katkı yok | atama reddinin yanında, alanın sayısı neden sayılmıyor |
| `MAIL_KIND_DISCOVERY` | Discovery | Keşif | mail künyesi (`RND_DISCOVERY_TITLE` cümle düzeni) |
| `MAIL_ROW_DISCOVERY` | discovery | keşif | kutu satırı sağı (`MAIL_ROW_REPORT` "rapor" gibi) |
| `RND_HISTORY_EMPTY` | Nothing yet. Notes and discoveries gather here. | Henüz bir şey yok. Notlar ve keşifler burada toplanır. | Ar-Ge geçmişi boşken |

**Mevcut CSV değerinde değişiklik:**
- `ONB_ORIGIN_SELF_MADE_NAME` TR "Self-Made" → **"Sıfırdan"** (EN "Self-Made" kalır). Bağlayıcı sözlük (kapı kararı 5) böyle
  diyor; CSV henüz değişmedi.

**Yeniden harf ya da bölme (CSV):**
- `RND_ACTION_BACK` → "Geri" / "Back". `RND_ACTION_APPLY` → "Uygula" / "Apply". Bunlar düğme.
- `RND_BAR_PAUSE` ("duraklat") ve `RND_ASSIGN_TITLE` ("ata") **CSV'deki gibi kalır**: kabuğun kartı ve şerit onları bağ olarak
  çizer (r4'teki "Duraklat" / "Ata" önerisi geri çekildi).
- `RND_UNLOCKS_PREFIX` iki noktasız kısa etiket olur: "Açtığı şey" / "What it opens".
- `RND_COL_HEADER(_SHORT)` parçalanır: `RND_FAMILY_*`, `RND_AREA_OF` ve "{done}/5".
- `RND_CROSS_MARK`'ın "⇠" glifi hiçbir yüzde yok. `util/chevron_left` ikonu olur, değer "{area}" kalır (SPEC §3.1).
- `RND_REQ_STARS` ve `RND_NEED_AREA`'daki ★ yıldız ikonu olur. ★ kural birimi olarak kalır (plan Faz F).
- `HR_TRAINING_SEND` ("EĞİTİME GÖNDER") yerine var olan `HR_TRAINING_PICK_TITLE` "Eğitime gönder" kullanıldı.

**TR çerçevede İngilizce kalan mevcut değerler (onay listesine, sessizce geçmesin):**
- `PROD_RND_NODE_AI_ENGINE` TR "AI Engine" (Ar-Ge ağacı, detay kartı, geçiş notu).
- `PROD_RND_NODE_ONBOARDING_FLOW` TR "Onboarding Akışı" (ağaç).
- Sözlükte izinli olanlar (değişiklik önerilmiyor): Bootstrap, Traction, Series A (evre özel adları), rol unvanı "UX/UI Designer"
  (CSV yazımı, SPEC §3.3).

**Kullanılmayan (öneri):**
- `PER_HEADER_META`: köken etiket oldu, kıdem KPI oldu.
- `PER_FOUNDER`.
- `PER_EQUITY`, `PER_VALUATION`, `PER_PEAK_VALUE`.
- `RND_LEGEND_COUNT`: KPI ağacın boyunu zaten söylüyor.
- `RND_NOTE_FIRST_HINT`: olaylar grubu da attı.
- `RND_OK`: keşif artık mail, Tamam düğmesi yok.
- `RND_HIDDEN_LINE_OPENED`: açılış satırı hattın adını zaten söylüyorsa çizilmez (bugün tek kullanıcısı `test_automation`).
- r4'teki `NOTICE_MESSAGE_LINE` ("{kind} · {subject}") geri çekildi: yığın kabuğun gramerini izler (gönderen · konu).

Parça sayfasındaki açıklama satırları belgedir, oyuncu metni değildir.

## Açık sorular (Erdem)

1. **Çifte çubuk.** 1920'de Ar-Ge açıkken araştırma kartı pencerenin yanında görünür kalıyor (SPEC §9 yalnız çakışmada
   gizler). Pencerenin kontrol şeridi aynı bilgiyi taşıyor (GDD §5.6 iki yeri de ister). Ar-Ge açıkken kart gizlensin mi?
2. **Ar-Ge geçmişi.**
   - Notlar ve keşifler mail olur ama Ar-Ge kendi geçmişini tutar: "Ağaç / Geçmiş" segmenti, Olaylar'la aynı okuma bölmesi.
   - Okundu durumu tektir.
   - Ad "Geçmiş" mi, "Notlar" mı?
3. **Keşif mail olarak** (onay noktası 10):
   - Gönderen tamamlanma anındaki atanan olsun; birden çoksa en büyük katkı. Motor bunu `_release_assignees`'tan önce yakalamalı.
   - Kurucu tek başına araştırdıysa "Kendine not" (olaylar SELF).
   - Kendiliğinden açılmaz: okunmamış mail + bildirim yığınında bilgi satırı (`ofis__kesif_bildirimi`).
   - **Kabukla çatışma:** kabuğun yığın kuralı "yığın = kutunun bekleyen mailleri (kağıt + hatırlatıcı)". Keşif beklemez,
     o kurala göre yığına girmez; o zaman keşif ofiste hiç görünmez (bugün modal açılıyor). Öneri: okunana dek bir bilgi
     satırı. Kabuk kuralına mı eklensin, keşif yalnız kutuda mı kalsın?
   - Ar-Ge rozeti bugünkü kurala göre okunmamış keşfi saymaz.
4. **Keşif mailinde tekrar.**
   - Yapısal olan düzeltildi: açılış satırı hattın adını zaten söylüyorsa `RND_HIDDEN_LINE_OPENED` satırı çizilmez.
   - Metin olarak kalan (onay ister): beat'in son cümlesi açılış satırının ikinci cümlesini tekrarlıyor. Test Otomasyonu:
     "Beta'da hata bulma temposu günler geçtikçe eskisi kadar düşmüyor." (beat) ve "Ayrıca Beta'da hata bulma temposu günler
     geçtikçe eskisi kadar düşmüyor." (`PROD_RND_NODE_TEST_AUTOMATION_UNLOCK`). Tasarım Sistemi ve Hata Takip Sistemi'nde de
     aynı.
   - Öneri: beat sahneyi anlatsın, son cümlesi düşsün; etki açılış satırında kalsın. Yoksa açılış satırının ikinci cümlesi mi
     düşsün?
5. **İlk aylık not** (§6.1 "ilk rapor bir kez modal"). Mail düzeninde kendiliğinden açılsın mı (tanışma gibi), yoksa yalnız
   gelsin mi? Çerçeveler olaylar grubu gibi "gelir, okunmamış".
6. **Detay kartı genişliği.**
   - Kart tek sütun (bugün ~290) değil iki sütun (604).
   - Atama satırı böylece tek satıra sığar.
   - Çapa kuralı aynı: kutucuğu örtmez, sabit yükseklik. Tasarım sütunu seçilince kart sola, Süreç'in üstüne dayanır.
7. **Geçiş notu** ("Başlatınca {node} durur; ilerlemesi korunur.") §5.7'nin kuralını Başlat'tan önce yazıyor. Kabul mü?
8. **Kutucuk düzeni.**
   - Altıgen ve mertebe ayağa indi. Ad tam genişlik aldı, "Ölçeklenebilir" bölünmüyor.
   - Çapraz işaretli devam düğümünde mertebe sözcüğünün yerini "‹ {alan}" alır: satır zaten "devam" diyor, EN'de sığması için.
9. **İlk yatırım taşı.**
   - Yalnız Series A ile kazanılıyor (`run_investment_amount`). Demoda koşu imzada bittiği için hiç kazanılmış görülmüyor; EA
     devam ekranında görülür.
   - Frank'in çeki (melek) saymıyor; oysa normal modda reddedilemediği için her koşuda H14 civarında yazılıyor.
   - `PERSONAL_MS_FUNDING_NOTE` ("İlk çek yazıldı...") melek çekini anlatıyor gibi. Melek de sayılsın mı?
10. **Tohum çelişkisi.** `mvp_shipped` yazılı, `mvp_launch_day` yazılı değil. Baseline'da İlk sürüm kazanılmamış görünüyor
    ama ağaç açık. Çerçeveler 6. haftayı varsaydı.
11. **Kurucu huyları.**
    - Bugün katalog boyu (8) boş nötr yuva gösteriliyor, çünkü huy etkileri bağlı değil.
    - Yuvalar artık başlıktaki YAKINDA etiketiyle (`SYS_SOON`, Pazarlama rayı gibi) "bozuk" değil "henüz yok" okunuyor.
    - Oyuncu açılışta iki huy seçti (Vizyoner, İnatçı). Seçilen iki huy adıyla görünsün mü?
12. **Net servet.**
    - Değerleme, net servet ve zirve değer satırları atıldı; demoda hiç dolmuyorlar.
    - Hisse pay çubuğu etiketinde: "Kurucu · %96 · Melek · %4".
    - Not satırı kaldı. Kabul mü?
13. **Beceri gösterimi.** 0-10 sayı (ramp rengiyle), beş çift hücre (bir çift = bir yıldız). Plan "beceri okuması sayıya
    döner" diyor. Uygun mu?
14. **Köken adı:** sözlüğe göre "Sıfırdan" uygulandı (yukarıdaki CSV değişikliği). CSV değişikliği onaylansın mı?
15. **Pazarlama yer tutucusu** hiçbir yapıda açılmıyor (`_is_locked` her kilidi kapalı sayar; ray satırı tıklanmaz). Çerçeve
    yalnız harness yüzeyi olarak işaretlendi. Yer tutucu harness yüzeyi olarak mı kalsın, EA'da açılsın mı (kabuk soru 15)?
16. **Ar-Ge penceresinin yüksekliği içeriği izler** (SPEC §9 "yükseklik içeriği izler"):
    - seçim yokken 1280×522 (ağaç + ayak), düğüm seçilince kartla 1280×820'ye uzar (aşağı doğru; ağaç kıpırdamaz);
    - geçmiş görünümü 780, karar beklerken 860, v1 öncesi 320, 1536'da 712 (gövde kayar);
    - SPEC tablosundaki 1280×780 sabit mi kalsın, yoksa bu davranış mı?
17. **Dal A'da Selin araştırmada.** Ekip tohum çerçevesinde görevi "Test ediyor"; araştırırken "Araştırma" okunur. Kabuğun
    plakasındaki kafa ikonu da tohumdaki durumdan (test). Çerçeveler ayrı durumlardır.
18. **Donmuş araştırmanın gerekçesi** kabuğun kartıyla aynı kurala bağlandı: `ink-2`, duraklat glifi, uyarı rengi yok
    (kutucuk, şerit, kart). Kabul mü?
19. **Atama satırındaki beceri sayısının sütun başlığı yok.** Grup başlığı alanı adlandırıyor. Yeterli mi?
20. **Karar beklerken yüzen öğeler** (kabuk soru 19 ile aynı soru, tek karar gerekiyor). Bu çerçevede: BuildHUD tohumda zaten
    kendi gerekçesiyle kapalı; araştırma kartının bağları kapalı + "Cevap bekliyor"; Ofisi taşı tutulu + "Cevap bekliyor".
    Olaylar grubunun `ekip__salt_okunur_karar_bekliyor`'u BuildHUD'ı açık çiziyor; kabuğun BuildHUD'ını içe alınca o da kapanır.
21. **Ar-Ge rozeti.** `RnDSystem.attention_count()` H14'te 1 verir (okunmamış not; koşan araştırma sayılmaz). Kabuk ve
    olaylar 2 çiziyor (sistem sayfasının örneği). Bu grup 1'i tuttu; kabuğun `B14`'ü 1'e inerse tek kaynak tamamlanır.
22. **Kurucunun görev metni.** Aynı durum iki metinle okunuyordu: kurucu "Bir yapımda çalışıyor"
    (`HR_FOUNDER_STATE_BUILD`), çalışan "Yapımda görev alıyor" (`HR_TASK_ON_JOB_BUILD`). Çerçeveler ikisinde de
    `HR_TASK_ON_JOB_BUILD`'i kullanıyor (Kişisel, atama, donmuş). `HRSystem.founder_task_label` karşılığı olan her durumda
    `HR_TASK_ON_JOB_*`'u okusun mu?
23. **Süresi dolan kağıt.** Nordica'nın kağıdı H15 sonunda doldu. H16 kutusunda satırı ne olur (geçmiş satırı ve damga mı,
    hiç mi)? Olaylar grubunun kuralı yok; çerçeve satırı çizmedi.

## Öteki gruplara notlar (tek zaman çizelgesi)

- **kabuk:** `B14`'te Ar-Ge rozeti 1 (soru 21). Araştırma kartına karar beklerken kapalı bağ ve gerekçe eklentisi
  (`.rb-ft .lk.is-disabled`, `.rb-ft .why`, bu grubun css'inde) kabuğun bileşenine alınabilir. Kartın ad + alan hali bu grupta
  Test Otomasyonu / Test alanı ile kullanılıyor; kabuğun örneği (Veri Modeli, %35) H11'de biten bir araştırma.
- **olaylar:** H14 listelerine keşifler (H13 Hata Takip Sistemi, H11 Veri Modeli, H10 Kullanıcı Araştırması, H8 Tasarım
  Sistemi) eklenmeli. H15 çerçevelerinin üst barı bu çizelgede MRR $5,6K, NET +$4,1K/ay ve kasa $35.959 (Frank'in çeki H14'te
  zorunlu kabul, Burak'ın kapanışları H14'te). H15 ve sonrası listelerde Frank'in teklifi "Cevaplandı" satırı olarak durur.
  `ekip__salt_okunur_karar_bekliyor` BuildHUD'ı kabuktan alırsa "Düzeltme başlat" kapanır (soru 20).
- **A3 (portreler):** `arge__gecmis`'teki 256×320 Elif Demir kuyusu (`art/bust_elif.png`) A3'ün gözlük kusurunu hâlâ taşıyor.
  Sanat paylaşılan dosya; bu grupta düzeltilemez.
