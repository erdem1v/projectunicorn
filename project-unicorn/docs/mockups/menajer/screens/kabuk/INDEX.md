# Kabuk ve ofis katmanı · A4 ekran maketleri (grup "kabuk")

Üst bar, ray, haber şeridi, pencere çerçevesi, ofis karartması ve hale, BuildHUD, araştırma kartı, bildirim yığını,
tek toast, Ofisi taşı, kişi ipucu, şehir haritası ve ofis kartı, kurucunun yolculuğu. Onaylı Menajer Masası diliyle,
tam kabuk içinde 1920×1080 (ayrıca 1536×864 ve 1536×960 mantıksal, 2560×1080). Hepsi Erdem'in onayını bekliyor.

- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, A2 ikonları, kırpım kuralı, üst bar ızgarası
  (`kit.tb_layout`, `kit.week_bar`, `kit.ekip_window`). Sistemin eksiği `kabuk.css`'te; sistem klasörüne hiçbir şey
  yazılmadı (kit kopyaları ve önbellekleri `tools/syskit/`'te, yollar dört üst klasörden `system/`'e bakar). Kopyadaki
  `common.py` `start_fix` EN değeri CSV'ye çekildi ("Start a fix run", `PROD_FIX_RUN_START`).
- Frank = aday A (`portraits/frank_cand_a.png`), kurucu = `founder_01`. Yağlı boyalar yok.
- Ofis plakaları `art/office_safe_*_noicons.png` (184, 64)'te; kafa ikonları A2'nin yeni `icons/office/*.svg`
  sprite'ları, plakanın `*_heads.json` konumlarında (plakalara pişmiş eski Lucide ikonları yerine).
- Marka bloğu: bütün çerçeveler şimdilik (a) seçeneğiyle (olaylar grubu da öyle); (b) `marka__b_kabukta.png`'de ve
  karşılaştırma `marka__secenekler.png`'de.
- Gelen kutusuna bağlanan yerler olaylar grubunun mail gramerini izler: kapı yuvası alt satırı gönderen ("Frank
  Köseoğlu"), bildirim yığını satırı **gönderen · konu · kalan süre**.
- **BuildHUD tek kaynaktır:** `tools/gen.py buildhud(x, y, state)`; tohumda `state="seed"` = Doğrulanmış 0, "Düzeltme
  başlat" kapalı ve gerekçesi "Doğrulanmış hata yok." (`SupportSystem.fix_run_refusal = no_confirmed_bugs`). Etiket
  ve gerekçe `S` tablosunda (EN "Start a fix run" CSV'den), öteki grupların kopyasına bağlı değil.
- **Bildirim yığını = gelen kutusunun önizlemesi** (plan, "Mail dönüşümü"). Bütün yığınlar tek listeden ve tek satır
  kurucudan çıkar (`gen.py`: `SEED_INBOX`, `stack_row`, `notices`):
  - Sıra kutunun sırası: süreli kağıtlar kalan süreye göre (eşitlikte yenisi önde), sonra hatırlatıcılar.
  - Etkin karar yığında satır değildir (kapı yuvasında); kuyruktakiler yuvada sayıdır. Etkin kararla aynı konudaki
    hatırlatıcı gizlenir; Nordica'nın büyüme hatırlatıcısı kağıdı masadayken gizlidir (olaylar kuralı).
  - **Tohum yığını (H14 11:00, bütün kabuk çerçevelerinde aynı):** "Nordica · Bir ekip daha · 2 hafta",
    "Ege Sigorta · Risk altında", "Selin Kaya · Ayrılabilir". Olaylar grubu aynı ana bu üç satırı aynı sırayla
    çizmeli (karar beklerken de: Frank'in teklifi hiçbir hatırlatıcıyla konu paylaşmaz).
  - Süre rengi: kağıt ink-3, son haftasında uyarı ("bu hafta"); teklif sayacı yuvasıyla aynı: uyarı noktası ve
    uyarı süre, son haftada kırmızı.
- **Tohum ekonomisi yeniden hesaplanmadı.** Üst bar tohumun kendi değerleri: BURN $1,5K/ay başlangıç değeri, NET
  +$2,5K/ay, RUNWAY Artıda. Ekip penceresinin AYLIK MAAŞ YÜKÜ $43.600'ü burn'e yansımaz (saat tutulduğu için tik yeniden
  hesaplamadı, `data/screens.md` notu). Yan yana göründükleri yerler: `kabuk__pencere_acik`, `ustbar__2560`.
  Maaş yükünden hesaplanırsa burn ~$45,1K/ay, net ~−$41,1K/ay ve runway bir haftanın altına iner (bütün tohum
  çerçeveleri alarmda olur); bu yüzden tohum korunup not düşüldü.

Yeniden üretmek: `python tools/gen.py` (HTML'ler `build/`), `bash tools/render_all.sh <tur> [ad ...]` (PNG'ler bu
klasöre, kopyası `rounds/<tur>/`; boyut ve ölçek `python tools/gen.py --sizes`'tan). Paralel: `python tools/gen.py
--sizes | awk '{print $1}' | xargs -P 6 -I{} bash tools/render_all.sh <tur> {}`. Taşma geçişi: `python tools/gen.py
--overflow` (yuva metinleri kutularına karşı, TR ve EN, Godot genişliğiyle: Chrome × 1,08 + 2).

Turlar: r1 (29 kare, hepsi tam boy okundu), r2 (14 kare düzeltildi: büyütme kutularının konumu, bildirimdeki `.wk`
sınıf çakışması, odak halkası, toast renkleri, 1536 pencere kuralı), r3 (29 kare yeniden; temas sayfası ve 1:1 /
2× kırpımlarla okundu), r4 (teklif bildiriminin konusu kısaldı), r5 (olaylar + kabuk incelemesinin S1/S2/S3 bulguları:
tek yığın kurucusu ve tohum yığını, `_en` sayfa dili, kapı saati, 1536×960, yapıya göre ray, 2560 üst bar, taşınma
etiketi ve toastı, nefes, araştırma bağı, taşma geçişi; 31 kare yeniden, değişen her kare tam boy, yığın, üst bar ve
ray 1:1 / 2×–3× kırpımla okundu).

"Tohum" = `docs/mockups/menajer/data/screens.md` (`_seed_theme_surface`, hafta 14, İş hanı, 11:00).

## Çerçeveler

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen (`kabuk.css`) | Yeni metin (EN / TR) | Soru |
|---|---|---|---|---|---|
| `kabuk__normal.png` | Pencere yok: üst bar Sıradaki "14:00 · Karadeniz Fabrika" (14:00 elmas), ray rozetleri, BuildHUD (Doğrulanmış 0, Düzeltme başlat kapalı ve gerekçesi), tohum yığını (3), Ofisi taşı, şerit. Ofis kararmamış. | Tohum. Sıradaki görüşme tohumdaki Karadeniz Fabrika lead'i. Kapalı düğme: `SupportSystem.fix_run_refusal` = `no_confirmed_bugs`. Yığın `SEED_INBOX`. | kafa ikonu katmanı (`.head-ic`), BuildHUD kapalı eylem + gerekçe (`.bh-act .why`) | No confirmed bugs. / Doğrulanmış hata yok. | 14 |
| `kabuk__pencere_acik.png` | Ekip penceresi açık: ofis 0,84 kararmış, pencerenin halesi; BuildHUD görünür (Ekip 1560'ta biter, kart 1576'da başlar); yığın (üstü y 844, pencere 770'te biter) ve düğme pencereye değmediği için görünür. | Tohum; Ekip penceresi sistem kitinden. BURN ile maaş yükü yan yana: yukarıdaki tohum ekonomisi notu. | | | |
| `ustbar__karar_bekliyor.png` | Tek karar, Olaylar kapalı (Esc ile): kapı yuvası amber çerçeve, "Cevap bekliyor · Frank Köseoğlu", saat **08:00**'de tutulu (hafta çubuğu başta), hız tuşları kapalı, rayda Olaylar amber nokta. Space'e basılmış: "Saat kilitli · Önce bekleyen kararı cevapla." toastı. Ofisi taşı kapalı, gerekçesi "Cevap bekliyor". Tohum yığını aynen. | Tohum + Frank'in teklifi (`funding.frank_cheque`, `tick: daily`): kart gece adımının içinde 00:00 gün dönümünde ateşlenir (`TimeManager._step_hour`); çerçeve gece adımının hafta başına (08:00) varıp kapının orada tuttuğunu varsayar (soru 22). Plaka 11:00 çekimi. | kapalı yüzen düğme + gerekçe (`.fbtn.is-disabled .why`) | (SPEC'teki anahtarlar) | 2, 3, 22 |
| `ustbar__karar_bekliyor_3.png` | Üç karar: alt satır "3 karar bekliyor", saat 08:00'de tutulu. F5'e basılmış: "Kaydedilmedi · Karar beklerken kaydedilemez." | Tohum; kuyruk yalnız sayı (plan). Kapı saati yukarıdaki gibi. | | | 22 |
| `ustbar__kepenk.png` | Kasa eksi: KASA −$4.200 kırmızı, RUNWAY hücresi KEPENK "3 hafta" kırmızı, NET −$3,1K/ay kırmızı, BURN $7,1K/ay; Finans rozeti 1; Sıradaki yedek "Mesai bitimi · 6 saat". | Değerler onaylı sistem sayfası 07'nin alarm satırından (MRR $4,0K − burn $7,1K = net −$3,1K). Kepenk `EndingsSystem.SHUTTER_WEEKS` 4'ten sayar; 3 hafta kaldı. Finans rozeti `left_tabs.gd` (runway < 3 ay). | | Shutter / Kepenk, {n} weeks / {n} hafta (SPEC) | 5 |
| `ustbar__runway_ay.png` | Hafta 1 · 11:00, ev: runway "7 ay" mürekkep, MRR $0, NET −$1,5K/ay mürekkep (tehlike değil), BuildHUD yok (ürün yayında değil), ray rozetsiz, yığın boş, Sıradaki "Mesai bitimi · 6 saat". | Koşu başı (olaylar grubuyla aynı): kasa $10.000, burn $1,5K/ay, runway 10.000 / 50 / 30 = 6,7 → 7 ay (`net_runway_parts` yuvarlar). | | | 5 |
| `ustbar__runway_kirmizi.png` | Runway "2 ay" kırmızı; Finans rozeti 1; şeridin başında canlı satır "İçeriden · Runway 3 ayın altına indi". | **Türetildi**: kepenk çerçevesiyle aynı akış (net −$3,1K/ay), kasa $6.200 seçildi → 6200 / 103,3 / 30 = 2,0 ay. Eşik `FinanceSystem.RUNWAY_ALERT_MONTHS[0]` = 3: Finans rozeti ve `RUNWAY_CROSS_TICKER` satırı aynı eşikte düşer. | şeritte iç kaynak (`.tk-pub.internal`) | Internal / İçeriden (yeniden harf) | 4, 5 |
| `ustbar__teklif_sayaci.png` | Sıradaki "Teklif · 2 hafta kaldı" uyarı renginde; evre Traction; yığının başında "Anchor Capital · Teklif · 2 hafta", nokta ve süre uyarı renginde (yuvayla aynı), altında tohum yığını (4 kart, `MAX_CARDS`). | **Türetildi**: tohum değerleri, evre 2, Anchor Capital'den bir term sheet (fon `art/busts/counterparts.json`). Bugünkü amber teklif çipi (`top_bar.gd`) yuvaya taşındı (SPEC §2.9). | uyarı noktası ve süresi (`.notice .dt.is-warn`, `.nwk.is-warn` / `.is-neg`) | Offer / Teklif (yığın konusu; `DESK_PAPER_SHEET_TITLE` konu + `DESK_PAPER_WEEKS` olarak bölünür) | 9 |
| `ustbar__sprint_otomatik.png` | Üst barda not yok; BuildHUD'ın altında ink-3 satır "Sprint otomatik başladı". Tohum yığını. | Tohum + sprint otomatik başlamış (`PRODUCT_AUTO_STARTED`, `top_bar.gd _refresh_auto_start`). | BuildHUD not satırı (`.bh-auto`) | | |
| `ustbar__yolculuk.png` | Yolculuk perdesi altında: şehir haritası, yol (kasa + kesik çizgi), kurucunun 48 px diski (avatar merdiveni, halka ink-1), "Mevcut · İş hanı" çipi (taç), varış çipi "Karadeniz Fabrika · Elif Yıldız". Üst bar: yuva "Şimdi · 14:00 · Karadeniz Fabrika", saat 14:00, tuşlar kapalı, amber yok. BuildHUD, yığın, düğme gizli; ofis kararmaz. Alt ortada geçme ipucu. | Tohumdaki 14:00 görüşmesi; alıcı `counterparts.json` (lead_14_2, Elif Yıldız). Çip `MEETING_TOWER_CHIP`. Yol ve kule konumu `baseline/travel__ishani_20.png` ile plakadan okundu. Tıkla ya da Esc yolu geçer, Space ve 1-4 bir şey yapmaz (`office_travel.gd`). | tutulan saat (`.topbar.is-held`, `.nx-s.now`), yol (`.road`), kurucu diski (`.road-disc`), varış çipi (`.mchip.is-dest`), geçme ipucu (`.skip`) | Now / Şimdi; Click or press Esc to skip the trip. / Yolu geçmek için tıkla ya da Esc'ye bas. | 6 |
| `ustbar__1536.png` | 1536×864 mantıksal (ölçek 1,25): sıkışık bar (yalnız kare, "H14 · Nis", 30 px tuşlar, yuva 216, hafta çubuğu 252), simge ray, BuildHUD (1192, 88), tohum yığını, düğme (88, 756). | Tohum. | | | 16 |
| `ustbar__1536x960.png` | 1536×960 mantıksal (1920×1200 fiziksel, ölçek 1,25): 1536×864'ün sıkışık barı ve simge rayı, ofis 96 px daha uzun (1472×856), BuildHUD (1192, 88), tohum yığını, düğme (88, 852). | Tohum. Plaka 1536 plakası, örtüyle ×1,126 (1536 plakası sorusu 16 burada da geçerli). | | | 16 |
| `ustbar__1536_pencere.png` | 1536'da Ekip açık (88 ile 1440): BuildHUD, yığın ve Ofisi taşı pencereye değdiği için gizli; ofis kararmış, hale. | Tohum. | | | 16 |
| `ustbar__2560.png` | 2560×1080: pencere solda kalır, ofis sağa genişler, BuildHUD ve yığın sağ kenarda. Üst bar: hafta çubuğu 720'de durur, **Sıradaki yuvası ve saat bloğu gün bloğunun hemen ardından gelir**, artan 274 px saat bloğundan sonra boş bar (saat bloğu ince çizgiyle kapanır). | Tohum. BURN ile maaş yükü yan yana: tohum ekonomisi notu. | saat bloğunun sağ kenarı (`.tb-time.has-slack`) | | 21 |
| `ustbar__durumlar.png` | Üst barın bütün durumları 1:1 alt alta (16 satır): üç Sıradaki türü (görüşme, sprint kararı 15:00 elmas, yedek), tek ve çok karar (saat 08:00'de tutulu), kepenk, runway ay, runway < 3 ay, runway < 1 ay (hafta), teklif (uyarı), teklif son hafta (kırmızı), yolculuk, sıkışık 1536, **sıkışık 1536 Cevap bekliyor**, **en uzun gerçek şirket adı 1920 ve 1536'da** ("14:00 · Metrekare Danışma…", "14:00 · Metrekare Danış…"). | Yukarıdaki çerçevelerle aynı; runway hafta: kasa $2.200 → 0,71 ay → `floor(0,71 × 30 / 7)` = 3 hafta (türetildi). En uzun ad `company_catalog.gd`'nin 65 adından; o iki satır Godot genişliğiyle çizildi (kutu (kutu − 2) / 1,08'e daraltılır), oyunda olacağı gibi kısalır. Taşma geçişi aşağıda. | | Offer · final week / Teklif · bu hafta son (SPEC) | 4, 23 |
| `ustbar__durumlar_en.png` | Aynısı İngilizce, sayfa dili `en` (REPUTATION, TRACTION noktasız I ile); genişlik denetimi (Default Alive, Answer needed, Workday ends · 6 h, 3 wk). | Aynı; EN değerleri CSV'den, sayı EN biçiminde. | | | |
| `marka__secenekler.png` | Karar 14, yan yana: (a) eski turuncu kare + "Project Unicorn" (1:1 bar, 3× blok, sıkışık kare, bugünkü barın kırpımı); (b) LogoEmblem + şirket adı: Minimalist (varsayılan), Tekno, Oyuncul 2× ve 1:1, sıkışık amblem; başka ad "Synaptik" Ciddi stilde. | (a) `top_bar.gd` `LogoSquare` = `ACCENT_CHROME` #FFA028, `baseline/office__ishani_11.png`. (b) `logo_emblem.gd` (r = boy/2 − 2, harf r × 1,05, renkler ACCENT_CHROME / CREAM / DIALOGUE_BG), `FounderConstants.LOGO_STYLES`, `GameState.company_name` "Unicorn Inc.", "Synaptik" `ONB_COMPANY_PLACEHOLDER` örneği. | marka karesi (`.brand-sq`, `--brand-mark`), amblem SVG'si (`.emblem`, `--emblem-cream`, `--emblem-ground`) | Project Unicorn (TOPBAR_BRAND, olaylar ile ortak) | 1 |
| `marka__b_kabukta.png` | (b) seçeneği tam ekranda (Minimalist, "Unicorn Inc."), tohum yığını. | Tohum. | | | 1 |
| `ray__durumlar.png` | Etiketli ray: tohum (Ekip etkin), karar bekliyor + Finans'ta kenar (Finans rozeti yok: tohum runway'i Artıda), klavye odağı (F6); simge kipi: tohum ve karar + ad ipucu ("Satış"); satır durumları 2× (boşta, kenar, etkin, odak, kilitli "Yakında", nötr sayı, amber nokta). | Rozet kaynakları `left_tabs.gd` (HR ve Satış dikkat sayısı, Ar-Ge sayısı, Finans runway < 3 ay, Olaylar). Finans rozeti `ustbar__kepenk` ve `ustbar__runway_kirmizi`'de. Pazarlama `UiTokens.TABS` lock "ea". | klavye odağı satırı (`.rr.kfocus`), simge kipi ipucu (`.rail-tip`) | | 15 |
| `ray__yapilar.png` | Yapıya göre Pazarlama: demo bugün (kilitli, "Yakında"), demo öneri (kilitli, "Erken Erişim'de"), EA boşta (kapı açık, satır öteki sekmeler gibi), EA etkin; simge kipi demo (12 px kilit köşe ikonu) ve EA (kilitsiz); Pazarlama satırı 2× dört halde. | `UiTokens.TABS` lock "ea" ("Early Access scope, never opens in the demo"), `LeftTabs._is_locked`; `--build=ea` (CLAUDE §12). Öneri gerekçe `ENDING_BADGE_EA` (ERKEN ERİŞİM'DE / IN EARLY ACCESS), cümle düzeninde. EA sayfası plan madde 13'ün yer tutucusu. | | In Early Access / Erken Erişim'de (yeniden harf, öneri) | 15 |
| `serit__kapali.png` | Şerit kapalı: 57×40 düğme sol altta, ray ekranın altına iner (Ayarlar 40 px yukarı), ofis 40 px kazanır, Ofisi taşı ve tohum yığını aşağı iner. | Tohum; plaka 1736×1016 alana örtü olarak oturdu (×1,041). | | | 7 |
| `serit__durumlar.png` | Açık şerit, aç/kapa üstünde, canlı satırlar önde ("İçeriden · Runway 3 ayın altına indi", "Elif Demir · Nasıl geçti?"), kapalı (bağlamda ve 2× üstünde), açık 2×, EN. | Akış `TICKER_04..09` (tohum sırası); canlı satırlar `RUNWAY_CROSS_TICKER` + `TICKER_SRC_INTERNAL`, `MEETING_BACK_ASK` (`office_travel.gd _ask`, kaynak kişinin adı). | kapalı düğmenin üstünde hali | | 18 |
| `buildhud__durumlar.png` | DESTEK kartı: tohum (kapalı + gerekçe), Doğrulanmış 3 (Düzeltme başlat açık, üstünde), koşu sürüyor (%40 çubuk, Koşuyu bitir), bölünmüş odak ("Ekip iki işte."), sprint notu; altında araştırma kartı sürüyor ("duraklat · ata", ata üstünde) ve duraklamış ("Ekip yapımda.", **yalnız "ata"**). Pencere kuralı notu. | Tohum; "Doğrulanmış 3" ve koşu **türetildi** (5 hatanın 2'si çözüldü: dolum = çözülen / (açık + çözülen), `build_bar_model.gd`). Araştırma **türetildi**: Veri Modeli (`rnd_tree.json`, efor 40), Elif Demir atanmış, ürün 7 × 8/8 saat × 7 gün = 49/hafta; %35'te 26 efor → ~1 hafta (`RND_WEEKS_LEFT`). Duraklama `RND_PAUSED_BUILD`; duraklatılmışken duraklat bağı gizli (`research_bar.gd`: `_pause_link.visible = not m.paused`). | aşama satırında yüzde + ilerleme (`.bh-phase`), araştırma kartı (`.rb`, bağlar `.rb-ft .lk`, duraklamış `.rb.is-paused`) | | 14, 19 |
| `bildirim__yigin.png` | Yığın 4 kart + "+1": Frank'in son satırı (yüz + serif söz), sonra tohum yığını aynı sırayla: "Nordica · Bir ekip daha · 2 hafta" (üstünde kenar), "Ege Sigorta · Risk altında", "Selin Kaya · Ayrılabilir" ve son kartta "+1" (gizli: Atlas). | Tohum yığını + **türetilmiş iki öğe**: Frank'in satırı `FRANK_ADVISORY_MEETING_SET` (14:00 görüşmesi ayarlı), gizli beşinci öğe Atlas aday dosyaları. `MAX_CARDS` 4 (`office_notice_stack.gd`). | yığın satırının süre sütunu (`.notice .nwk`), Frank kartı (`.notice.frank`), üstünde (`.notice.is-hover`) | One more team / Bir ekip daha (olaylar); At risk / Risk altında (`SALES_CHIP_RISK` cümle düzeni) | 8, 9 |
| `toast__durumlar.png` | Tek toast, TR ve EN: Kaydedildi, Kaydedilmedi (karar beklerken; EN "Not while a decision is waiting."), Yüklendi, Saat kilitli, Taşınma başladı, Ertelendi (satış), Ertelendi (VC). EN sütunu `lang="en"`. | `MEETING_POSTPONED`, `MEETING_POSTPONED_VC`, `OFFICE_TOAST_MOVED` (yerine öneri), `SAVE_QUICK_SLOT`, `SAVE_ERR_DECISION_WAITING` (modallar_acilis ile aynı EN), SPEC §6 ve §13. | toast konumu ve renkleri (`.toast.at`, `.toast.warn`, `.toast.hold`) | aşağıdaki liste | 3, 25 |
| `ofis__tasi_dugmesi.png` | Ofisi taşı: boşta, üstünde, nefes tepesi (ölçek 1,04 + üstünde kenarı, **opaklık 1**), karar beklerken kapalı + "Cevap bekliyor", taşınırken **"TAŞINIYOR" etiketi + "1 hafta" düz metin**; 1:1 ofis üstünde ve 2×. | `office_hud.gd` (PULSE_SCALE; PULSE_ALPHA 0,8 yüzen öğe opak kuralı için atıldı), `OFFICE_MOVING_BADGE` ikiye bölündü (Ekip ızgarasındaki İzinde gibi), `OfficeConstants.MOVE_WEEKS` 1. | nefes tepesi (`.fbtn.is-breath-peak`), düğmedeki süre (`.fbtn .left`) | aşağıdaki liste | |
| `ofis__tasinma_sayaci.png` | Ev, ilk taşınma başladı: düğmede "TAŞINIYOR · 1 hafta" (etiket + metin), toast "Taşınma başladı · İş hanı", **KASA $35.000**. | **Türetildi**: tohum değerleri + Frank'in çeki (`AngelRoundSystem.CASH_AMOUNT` $25.000), ofis ev, kurucu tek (ev planı, yığın boş). KASA düşmez: `OfficeSystem.move_to` para taşımaz, kira, depozito ve nakliye ACIK_KARARLAR 60'ta açık. Bedel bağlanırsa kart "Taşın · $6,5K" dediği için KASA $28.500 okur (soru 24). | | Move started / Taşınma başladı + {name} | 24, 25 |
| `ofis__kisi_ipucu.png` | Ofiste Selin'in üstünde imleç: 32 px yüz, "Selin Kaya", "Test Mühendisi · Test ediyor", tehlike satırı "Moral 22 · ayrılabilir". Tohum yığını. | Tohum; iş `OFFICE_ACT_TEST` (heads json durumu `test`), unvan CSV. | ipucu tehlike satırı (`.ptip .risk-l`), imleç (yalnız gösterim) | Morale {n} · at risk of leaving / Moral {n} · ayrılabilir | 11 |
| `ipucu__cesitleri.png` | Kişi ipucunun üç hali: riskte (Selin), normal (Deniz, "UX/UI Designer · Çizim yapıyor"), telefonda (Burak, "Müşteriyle görüşüyor"). | Tohum; `OFFICE_ACT_*`. | | | 11 |
| `harita__ofis_karti.png` | Şehir haritası: çipler (Mevcut · İş hanı tacıyla, Ev, Plaza katı ve Depo loft kesik kenar), Plaza seçili, belge köşeli kart (Orta, Şartlar karşılanmadı, Masa 36 · Kira $18,0K · Taşınma $45,0K, depozito notu, getirdikleri, şartlar ✗ ✗ ✓, Vazgeç + kapalı "2 şart karşılanmadı"), Depo loft'un üstünde kartı, Ofis seç paneli. BuildHUD ve yığın gizli, ofis kararmaz. | `OfficeConstants.CATALOG`, `OfficeSystem.requirement_state` tohumla (ekip 5, kasa $10.000, marka 50); küçük resim `assets/art/office/thumb_plaza.jpg`; çip konumları `office_safe_1920_city_chips.json`. | kart başlığı, oda çipleri, bölüm başlıkları (`.mcard .head/.rooms/.sec`), panel (`.mpanel`), üstünde kartı (`.mhover`) | Current · {name} / Mevcut · {name} (yeniden harf) | 10, 12, 13 |
| `harita__kart_durumlari.png` | Kart halleri: İş hanı mevcut (Buradasınız), evden ilk taşınma (Taşınabilir, amber "Taşın · $6,5K"), taşınma sürerken ("Taşınıyor · 1 hafta", düğme metni cümle düzeninde kalır), Depo loft üç şart tutmuyor; üstünde kartları (Plaza, İş hanı, Ev). | Aynı tablolar; "taşınabilir" ve "taşınıyor" **türetildi**: ev, Frank'in çeki alınmış, kasa $35.000. | | | 11, 12, 13, 24 |

## Taşma geçişi (`python tools/gen.py --overflow`)

Godot genişliği = Chrome × 1,08 + 2. Kutular: Sıradaki metni 1920'de 208, 1536'da 184; kapı alt satırı 186 / 164;
kapı etiketi 186 / 164.

| Metin | Gerekli | 1920 | 1536 |
|---|---|---|---|
| 14:00 · Karadeniz Fabrika | 180 | sığar | sığar (4 px pay) |
| 14:00 · Metrekare Danışmanlık (en uzun gerçek ad) | 216 | **kısalır** | **kısalır** |
| Sprint decision · 15:00 | 159 | sığar | sığar |
| Cevap bekliyor / Answer needed | 133 | sığar | sığar |
| 3 decisions waiting | 135 | sığar | sığar |
| Metrekare Danışmanlık (kapı alt satırında gönderen) | 163 | sığar | sığar (1 px pay) |

Kural önerisi: Sıradaki metninde saat kalır, şirket adı üç noktayla kısalır (Label `OVERRUN_TRIM_ELLIPSIS`); tam ad
yuvanın ipucunda (soru 23).

## Yeni bileşenler (`kabuk.css`, sistem grameriyle)

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.brand-sq`, `--brand-mark` | (a) 20 px turuncu kare, #FFA028 marka sabiti (olaylar.css ile aynı değer) | `LogoSquare` ColorRect; `D_BRAND_MARK` sahne/marka sabiti, UI token'ı değil |
| `.emblem`, `--emblem-cream`, `--emblem-ground` | (b) LogoEmblem'in dört şekli SVG'de, bugünkü renklerle | `LogoEmblem` (`_draw`), Faz B renk eşlemesi açık |
| `.topbar.is-held`, `.nx-s.now` | Saat yolculukta tutulu: tuşlar kapalı, amber çerçeve yok; yuva "Şimdi" | TopBar MetricGrid durumu |
| `.tb-time.has-slack` | 1920'den geniş barda saat bloğu yuvanın ardında, sağ kenarı ince çizgi | TopBar MetricGrid: gün bloğu en çok 720 + pay, artan sağda |
| `.rr.kfocus`, `.rail-tip` | Raya klavye odağı (2 px halka, 2 px boşluk, satırın içinde); simge kipinde ad ipucu | LeftTabs odak StyleBox, `tooltip_text` |
| `.tk-pub.internal`, `.tk-pub.person` | Şeritte yayın olmayan kaynak (İçeriden, kişi adı) ink-1 | `news_ticker.gd _part` kaynağa göre renk |
| `.bh-phase .pct/.prog`, `.bh-act .why`, `.bh-hd .note`, `.bh-auto` | BuildHUD: koşu yüzdesi ve çubuğu, kapalı eylemin gerekçesi, bölünmüş odak notu, sprint otomatik notu | `build_bar.gd` |
| `.rb` (+ `.rb-hd`, `.rb-nm`, `.rb-ft .lk`, `.is-paused`) | Araştırma kartı (sayfa 11'in kartı + oyunun duraklat · ata bağları; duraklamışken yalnız ata) | `research_bar.gd` |
| `.notice .nwk` (+ `.is-warn`, `.is-neg`), `.notice .dt.is-warn`, `.notice.frank`, `.notice.is-hover` | Yığın satırı: süre sütunu (kağıdın son haftası uyarı; teklif sayacı uyarı, son haftası kırmızı), teklifin uyarı noktası; Frank'in satırı (gönderen + serif söz); üstünde kenar | `office_notice_stack.gd`, `DeskPapers.make_row` |
| `.fbtn.is-disabled .why`, `.fbtn.is-breath-peak`, `.fbtn .left` | Ofisi taşı kapalı + gerekçe; nefes tepesi (ölçek + üstünde kenarı, opak); taşınma süresi düz metin | `office_hud.gd` |
| `.toast.at`, `.toast.warn`, `.toast.hold` | Toast konumu; uyarı ikonu; saat kilidi ikonu amber (zaman durumu) | tek toast bileşeni (D6) |
| `.skip` | Yolculukta geçme ipucu (klavye ikonu + cümle) | `office_travel.gd` yanında Label |
| `.road`, `.road-disc`, `.mchip.is-dest` | Yol (sahne renkleri: kasa #15120F, kesik #F1ECE2), kurucu diski 48 px, ink-1 halka, varış çipi | `office_city.gd _build_road` (ROAD_CASING, ROAD_DASH sahne sabiti; halka `UiTokens.ACCENT` yerine ink-1) |
| `.mpanel`, `.mhover`, `.mcard .head/.nm/.ds/.mv/.sec/.rooms/.acts` | Harita paneli, üstünde kartı, ofis kartının tam içeriği | `office_city.gd`, `office_map_card.gd` |
| `.ptip .risk-l` | Kişi ipucunda tek tehlike satırı | `office_view.gd` ipucu |
| `.head-ic`, `.cursor` | Plaka üstünde A2 kafa ikonları; gösterim imleci (oyun öğesi değil) | `office_actor.gd` ICONS |
| `.sheet`, `.sh-*`, `.zoom`, `.cell-box` | Yalnız sayfa düzeni | yok |

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

SPEC §13'te önerilenler (Cevap bekliyor, {n} karar bekliyor, Sıradaki ve kalıpları, Kepenk, Saat kilitli, kayıt
toastları, "Önce bekleyen kararı cevapla.", "Karar beklerken kaydedilemez.") burada tekrar edilmedi; çerçeveler onları
kullanır.

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `TOPBAR_BRAND` | Project Unicorn | Project Unicorn | marka bloğu (a); olaylar grubuyla ortak |
| `TOPBAR_NOW` | Now | Şimdi | yolculukta yuva etiketi |
| `TRIP_SKIP_HINT` | Click or press Esc to skip the trip. | Yolu geçmek için tıkla ya da Esc'ye bas. | yolculuk |
| `FIX_RUN_REFUSED_NO_BUGS` | No confirmed bugs. | Doğrulanmış hata yok. | BuildHUD kapalı eylem gerekçesi (etiket `PROD_FIX_RUN_START` "Start a fix run" CSV'de var) |
| `SAVE_ERR_DECISION_WAITING` (SPEC önerisi, EN kısaldı) | Not while a decision is waiting. | Karar beklerken kaydedilemez. | F5 toastının alt satırı; modallar_acilis ile aynı değer |
| `OFFICE_TOAST_MOVE_STARTED` (`OFFICE_TOAST_MOVED`'un yerine) | Move started · {name} | Taşınma başladı · {name} | taşınma başında toast başı + alt; bugünkü "Yeni ofis: {name}" başlangıçta varış gibi okunuyor |
| `OFFICE_MOVING_TAG` + `DESK_PAPER_WEEKS` (`OFFICE_MOVING_BADGE` ikiye) | Moving · {n} weeks (tag + text) | Taşınıyor · {n} hafta (etiket + metin) | Ofisi taşı düğmesi; harita kartının kapalı düğmesi bugünkü anahtarla cümle düzeninde kalır |
| `MEETING_POSTPONED` ikiye | Postponed · The phone keeps ringing. | Ertelendi · Telefon çalmaya devam ediyor. | toast başı + alt (VC: alt `MEETING_POSTPONED_VC` olduğu gibi) |
| `SAVE_TOAST_LOADED` | Loaded · {slot} · {date} | Yüklendi · {slot} · {date} | F9 toastı (slot `SAVE_QUICK_SLOT`) |
| `OFFICE_TIP_ROLE_LINE` | {role} · {status} | {role} · {status} | kişi ipucu ikinci satır |
| `OFFICE_TIP_RISK` | Morale {n} · at risk of leaving | Moral {n} · ayrılabilir | kişi ipucu tehlike satırı (sistem s3'ün metni, anahtarı yok) |
| `DESK_PAPER_SHEET_SUBJECT` | Offer | Teklif | yığında term sheet hatırlatıcısının konusu; süre `DESK_PAPER_WEEKS` / `DESK_PAPER_THIS_WEEK` |
| `RAIL_LOCK_EA` (öneri, `ENDING_BADGE_EA` yeniden harf) | In Early Access | Erken Erişim'de | demo rayında Pazarlama'nın gerekçesi (bugün `SYS_SOON`) |
| yeniden harf | Internal | İçeriden | `TICKER_SRC_INTERNAL` (İÇERİDEN) |
| yeniden harf | Current · {name} | Mevcut · {name} | `OFFICE_CHIP_CURRENT` (MEVCUT · {name}) |
| yeniden harf | Confirmed {n} | Doğrulanmış {n} | `BUILD_SUPPORT_CONFIRMED` (sistem sayfası 07 de böyle) |
| yeniden harf | At risk | Risk altında | yığın konusu (`SALES_CHIP_RISK` büyük harfli) |

## Açık sorular (Erdem)

1. **Marka bloğu (karar 14):** (a) mı (b) mi? (b) seçilirse amblem renkleri bugünkü kodla mı kalsın (ACCENT_CHROME,
   CREAM, DIALOGUE_BG), Faz B'de koyu sözlüğe mi bağlansın? Oyuncul (dolu turuncu) ve Ciddi (dolu krem) stilleri amber
   birincil düğmeyle yarışan büyük lekeler.
2. **Kapı yuvası alt satırı** göndereni yazar (olaylar grubu, soru 2), SPEC kart başlığını yazıyordu.
3. **Saat kilidi toastı:** SPEC'in "Önce {başlık} cevapla." kalıbı Türkçede çalışmaz: kart başlığı ("Frank'in
   teklifi") yükleme eki alamaz, yer tutucu ek almaz kuralı. Öneri: genel cümle "Önce bekleyen kararı cevapla."
4. **Runway kırmızısı** 3 ayın altında (Finans rozeti ve şerit satırıyla aynı eşik, `RUNWAY_ALERT_MONTHS[0]`). Yoksa
   yalnız 1 ayın altında mı kırmızı, arada uyarı turuncusu mu?
5. **NET eksi ama kasa artıdayken** mürekkep (öneri: gider tehlike değil); bugün `delta_color_bright` kırmızı boyar.
   Kepenkte NET kırmızı (sistem 07).
6. **Yolculuk:** yuva "Şimdi" + tuşlar kapalı + geçme ipucu (yeni) kabul mü? Kurucu diskinin halkası amber yerine ink-1
   (kurucu zaman durumu değil; ofisteki kurucu halkası onay noktası 7 ile aynı soru). Kulenin tacı 3B ışıktır, maket
   onu göstermez.
7. **Şerit kapalıyken** ray ekranın altına iner ve Ayarlar 40 px yukarı çıkar; düğme rayın köşesinde. SPEC bu yerleşimi
   söylemiyor.
8. **Yığın sınırı:** oyun `MAX_CARDS` 4 (Frank'in satırı + 3 kağıt, sonra +N); SPEC "en çok 3". Çerçeveler 4'ü izledi
   (teklif çerçevesi 4 kart).
9. **Yığın mail grameriyle:** satır gönderen · konu · kalan süre; Frank'in satırı söz olarak kalır. Term sheet
   hatırlatıcısının göndericisi fon (Anchor Capital) ve konusu "Teklif" mi? Frank'in danışma satırı
   (`FRANK_ADVISORY_*`) kutuya mail olarak düşmüyorsa (plan madde 6 saymıyor) yığında durmaya devam eder mi?
10. **Harita odak kaydırması:** oyunda seçilen bina yakınlaşır (`FOCUS_ZOOM` 2,1); plaka sığdırılmış görünüm olduğu için
    maket yakınlaşmayı göstermiyor.
11. **Kişi ipucu** bugün tek satır ("{ad} · {iş}"); sistem s3'ün yüz + unvan + tehlike satırı önerisi kabul mü?
12. **Ofis kartı:** bugünkü anahtarlar kullanıldı (etikette "Şartlar karşılanmadı", kapalı düğmede "2 şart
    karşılanmadı"); sistem s3 sayıyı etikete, "Taşın"ı düğmeye koymuştu. Ev kartı (geri dönüş yok) bugün "0 şart
    karşılanmadı" ve "Taşınabilir" basar: çizilmedi, motorda düzeltilmeli.
13. Kademe etiketi CSV'de tek kelime ("Orta", "Yüksek"); sistem s3 "Orta kademe" yazmıştı.
14. **Düzeltme koşusunun öteki ret gerekçeleri** (`desk_shut`, `not_live`) için de metin gerekir; çerçevede yalnız
    `no_confirmed_bugs`.
15. **Pazarlama kilidi:** demo gerekçesi "Yakında" mı kalsın, kapının adını söyleyen "Erken Erişim'de" mi olsun
    (`ray__yapilar`)? EA yapısında Pazarlama sayfası yalnız yer tutucuysa satır EA'da açık mı (çerçeve öyle çizdi),
    yoksa EA'da da kilitli mi?
16. **1536 plakası** `plates.json`'da 184 px rayın altına çekilmiş; 1536'da ray 64 px, maket plakayı 1472×760 güvenli
    alana ×1,089, 1536×960'ta 1472×856 alana ×1,126 örtüyle oturttu. Faz D'de doğru kadrajla yeniden çekilmeli.
17. Plakalardaki kafa ikonları eski Lucide sprite'larıydı; çerçeveler `noicons` plakaları ve A2 sprite'larını kullanır.
    Plakadaki kurucu halkası hâlâ amber (onay noktası 7).
18. Şerit kapalıyken gelen canlı satır (ör. runway eşiği) nereye düşer? Bugün yalnız şeritte.
19. Karar beklerken yüzen kartların düğmeleri (Düzeltme başlat, araştırma bağları) da kapanır mı? Karar 5 pencereleri
    ve taşınmayı söylüyor.
20. Sprint otomatik notu BuildHUD'da yalnız ürün yayındayken görünebilir (kart ancak o zaman var); yayın öncesi
    otomatik başlayan sprint için yeri Ürün penceresi.
21. **2560 üst barı:** hafta çubuğu 720'de durur; yuva ve saat bloğu artık gün bloğunun hemen ardında, artan 274 px saat
    bloğundan sonra (`ustbar__2560`). Saat ve tuşların sağ kenarda kalması mı tercih (o zaman boşluk gün bloğunda)?
22. **Kapı saati:** günlük tikli kart (`funding.frank_cheque`) gece adımının içinde 00:00'da ateşlenir. Plan
    `hold_clock("event")`'i main'in işleyicisinde alıyor; tutuş gece adımının ortasında alınırsa `_can_step` adımı
    00:00'da durdurur ve kurucu kararı gece, boş ofiste okur. Çerçeveler gece adımının 08:00'e varıp kapının orada
    tuttuğunu varsaydı (yuva 08:00, çubuk başta). Motor hangisini yapacak? Olaylar grubunun kapı çerçeveleri aynı saati
    göstermeli.
23. **Uzun şirket adı:** Sıradaki yuvasında saat kalır, ad kısalır; tam ad yuvanın ipucunda mı? 1536'da "Karadeniz
    Fabrika" 4 px, kapı alt satırında "Metrekare Danışmanlık" 1 px payla sığıyor: daha uzun bir ad eklenirse kısalır.
24. **Taşınma bedeli:** kart "Taşın · $6,5K" diyor ama bugün para düşmüyor (ACIK_KARARLAR 60). Bağlanırsa taşınma
    başında KASA $35.000 → $28.500 okur; bağlanmazsa düğmedeki tutar oyuncuya yanlış söz verir.
25. **Taşınma toastları:** başlangıçta "Taşınma başladı · {ad}" öneri. Varışta (bir hafta sonra, `office_changed`) da
    "Yeni ofis · {ad}" toastı çıksın mı? Bugün varışta toast yok.
