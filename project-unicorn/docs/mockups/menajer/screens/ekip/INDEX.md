# Ekip · A4 ekran maketleri (grup "ekip")

Onaylı Menajer Masası diliyle Ekip sekmesinin bütün durumları: Kadro (5 ve 40 kişi, sıkı kip, boş), Görevler (matris
ve boş), satır menüsü, zam ve işten çıkarma (eksi kasa notuyla), çalışan ve kurucu dosyası, eğitim (seçili ve kilitli),
mesai (gündüz ve gece), Atlas arama ve aday dosyaları (1920 ve 1536 mantıksal). 28 kare: 21 TR, 2 renk körü (TR), 5 EN.
Hepsi onay bekliyor.

- Sistem olduğu gibi: `../../system/tokens.css`, `base.css`, ikonlar, kırpım kuralı, üst bar ızgarası, Ekip ızgarası
  (`kit.WID`, 1352 pencere). Sistemde olmayanlar `ekip.css`'te (aşağıda). Sistem klasörüne hiçbir şey yazılmadı; kit
  kopyaları ve önbellekleri `tools/syskit/`'te (yolları sistem klasörünü salt okunur gösterecek biçimde yamalı).
- Kabuk, kabuk grubuyla piksel-eş: üst bar, ray, şerit, BuildHUD ve bildirim yığını `ekip__kadro.png` ile
  `kabuk/kabuk__pencere_acik.png` arasında birebir aynı (PIL farkı boş). Marka bloğu karar 14'ün **(a) seçeneği**,
  turuncu kare (`#FFA028`) + "Project Unicorn"; kare kabuk gibi y 14'te (r3'te 13'tü). 1536'da yalnız kare.
- Frank bu grupta görünmez. Kurucu = `portraits/founder_01.png` (tohumun `portrait_id`'si). Yağlı boyalar yok.
- Ofis: `art/office_safe_1920.png` (184, 64)'te; boş kadro karelerinde `art/office_safe_1920_home.png` (kurucu tek başına
  masada). 1536 karelerinde ray ikon kipinde (64 px) olduğu için `art/office_safe_1536.png` 64..1536 aralığını kaplayacak
  biçimde ×1,089 büyütüldü (plates.json onu 184'e koyuyor).
- Oyuncu metni `localization/strings.csv`'den çerçevenin dilinde okunur (salt okunur); grubun eklediği ya da harfini
  değiştirdiği metinler `tools/gen.py`'nin `S` tablosunda, aşağıdaki listede.

Yeniden üretmek: `python tools/prep_assets.py` (aday yüzleri, bir kez), `python tools/gen.py` (HTML'ler `build/`,
`build/strings.md`, `build/sizes.txt`), `python tools/audit.py` (Godot genişlik geçişi ve float çakışma denetimi, aşağıda),
`bash tools/render_all.sh <tur>` (PNG'ler bu klasöre, kopyası `rounds/<tur>/`; 1536 kareleri `sizes.txt`'ten 1536 864 1.25
ile). Turlar: r1 (20 kare), r2 (katman sırası, perde, sıkı ızgara, dosya listesi, sütunlar), r3 (son düzeltmeler, Atlas
1536 arama), **r4** (Ekip ve Ürün incelemesinin Ekip bulguları; 28 karenin hepsi tam boy okundu, değişen her bölge 1:1 ya da
2× kırpımla; denetim 28/28 temiz).

## r4: incelemenin Ekip bulguları

| # | Bulgu | Yapılan | Kareler |
|---|---|---|---|
| 1 (S1) | Bildirim yığını yok | Kabuk'un yığını aynen (`kabuk/tools/gen.py notices()`, `.nstack`). Pencere dikdörtgeni yığınınkine bindiğinde gizli (SPEC §9), değilse görünür; perdeli diyaloglarda perdenin altında. Hangi karede neden: aşağıda "Bildirim yığını". | hepsi |
| 2 (S1) | BuildHUD "Düzeltme başlat" açık çizilmiş | Kabuk'un tohum hâli aynen: Doğrulanmış 0, düğme kapalı, yanında "Doğrulanmış hata yok." (`fix_run_refusal = no_confirmed_bugs`). Piksel-eş. | kadro, kadro_40, siki, gorevler, menu, egitim(+kilitli), zam, cikar(+eksi), renk körü, EN |
| 3 (S1) | Renk körü karesi yok | `ekip__kadro_renk_koru.png` (moral 22/38, AYRILABİLİR, risk şeridi, ray rozetleri, beceri 7-8 ve lejantta 9-10 maviye, yığın noktaları) ve `ekip__gorevler_renk_koru.png` (AŞIRI YÜK uyarı etiketi; Kadro'da o etiket yok, ikinci kare bu yüzden). `body.cb` (tokens.css). | 2 yeni |
| 4 (S1) | Gece mesaisinde üst bar taslağı gösteriyor | Üst bar uygulanmış günde kalır (08:00 ile 17:00, "Mesai bitimi · 9 saat"). Aynı mantıkla arkadaki Kadro'nun saat çipi ve satırları da taslağı göstermez (çip "09:00 ile 17:00 arası", satırlarda mesai notu yok). Baseline `hr__saatler` da böyle: çip 09:00-17:00. | mesai, mesai_gece, mesai_en |
| 5 (S1) | Sıkı kipte EN "Customer Success Manager" kırpılıyor | Izgara `measure.py` ile yeniden ölçüldü (Chrome × 1,08 + 2, TR ve EN): Rol 150 → **176** (12 + 159), Liderlik 64 → 80 ("LEADERSHIP" 78, eskisi taşıyordu), Huy 124 → 138 ("Takes Them Under" 4 + 20 + 6 + 108, eskisi taşıyordu). Yer ad sütunundan (168 → 136; bu kipte yalnız ad, en uzun kalabalık adı 109), beceri hücrelerinden (40 → 38), yüzden (40 → 36) ve görevden (178 → 170) geldi. Kanıt: `ekip__kadro_40_siki_en.png` ve denetim (eski ızgara EN'de 3 hata verir, yenisi 0). | siki, siki_en |
| 6 (S1) | Panel açıkken pencerenin amber düğmesi de yanıyor | PanelLayer paneli açıkken altındaki pencere `is-under`: pencere katmanı ofisin kendi `--dim`'i (0,84) ile kararır ve birincil düğmesi amberini bırakır (ikincil çizilir). Ekranda tek amber panelin. | egitim(+kilitli), mesai(+gece, en), atlas (hepsi) |
| 8 (S2) | Panel kenarları alttaki pencereyi kesiyor | Paneller alanın tepesine (y 88) oturur ve **onları açan pencerenin ortasına** hizalanır (alanın içinde kalarak). Atlas (1440, 1560) pencereyi tüm genişliğiyle örter; 1560 dosyalar paneli pencerenin boyunu da alır (88 ile 830), altında şerit kalmaz; 1536'da iki Atlas paneli de alanın tamamı (1424 × 712). Mesai ve Eğitim pencereden iki yanda eşit pay bırakır (eskiden sağda 8 px şerit). Kalan kesik çizgiler kararmış katmanda. | atlas (4), mesai (3), egitim (2) |
| 9 (S2) | TEMA ekonomisi kendi içinde çelişik | Düzeltilmedi, işaretlendi (aşağıda "Tohumlar" ve soru 1). Üst bar kabuk ve olaylar gruplarıyla ortak ve piksel-eş kalmalı; burn'ü burada bordrodan türetmek "Runway ≈ 1 hafta, kırmızı" gibi icat bir durum çizer ve grupları ayırır. Çerçevenin üstüne not yazılmadı (kare oyun ekranıdır). | |
| 10 (S2) | İzin hâli Görevler'e taşınmamış | `.mx-row.is-away`: gri yüz, ink-3 ad (SPEC §5). Mesai panelinde Mert'in Durum'u İZİNDE etiketi, moral okları yok ("1 / 4 çalışan mesaide" sayısına girmiyor). | gorevler, mesai (3) |
| 11 (S2) | Araştırma kilitlerinin gerekçesi yok | Lejantın sağ ucunda, Araştırma sütununun altında: kilit + "Araştırma ataması Ar-Ge sayfasında yapılır." (mevcut `HR_ASSIGN_RESEARCH_ELSEWHERE`, yeni anahtar yok). | gorevler (+renk körü) |
| 12 (S2) | Dosyada beceriler tablodan az | Çalışan dosyası altı alan + Liderlik (tablonun sırası), ana alan altı çizili, ikincil yarı kalın, ikisi de rol bandında; Liderlik tablodaki gibi çizgiyle ayrı. Kurucuda aynısı + Karizma. | dosya, dosya_kurucu |
| 13 (S2) | Menü metaları yanıltıcı | Zam: "Maaş $9.800" (`HR_ROW_SALARY` + tutar). Terfi: "→ Kıdemli Ürün Yöneticisi" (ok glif, unvan `HRConstants.job_title(rol, seviye + 1)`; yeni anahtar gerekmez). | menu, dosya, menu_en |
| 14 (S2) | Kilitli eğitimde gerekçe dört kez | Satırlar süresini (2 hafta) tutar; gerekçe bir kez, kapalı düğmenin yanında. | egitim_kilitli |
| 15 (S2) | Boş kadroda "ORTALAMA MORAL" taban çizgisinden kayıyor | Değer satırı boş ama yüksekliği korunur; anahtar KPI taban çizgisinde (kural 9). | kadro_bos, gorevler_bos |
| 16 (S2) | Boş kadroda ofiste insanlar | `office_safe_1920_home.png`: kurucu masada tek başına. Not: İK tohumunun ofisi iş hanı; iş hanının yalnız kurucu plakası yok (soru 8). | kadro_bos, gorevler_bos |
| 17 (S2) | EN kare ve %8 geçişi yok | 5 EN kare (kadro, kadro_40_siki, menu, mesai, atlas_dosyalar) aynı üreticilerden; `tools/audit.py` bütün karelerde %8 geçişi (aşağıda). | 5 yeni |
| 18 (S2) | Seçim kartlarında iki gramer | Atlas rol, seviye ve aday kartı Ürün'ün tür seçicisiyle aynı: surface-4 + kartın kendi sol kenarında 3 px işaret (8 içeride) + onay diski; 2 px mürekkep çerçeve kalktı. Aday kartının onayı kesik köşeye denk gelmesin diye künye satırında; künye satırı her kartta 20 px. | atlas (5) |
| 20 (S2) | TR'de izinsiz İngilizce listelenmemiş | Aşağıda "TR karelerinde mevcut İngilizce". | |
| 26 (S3) | Küçük düzeltmeler | Boşta satırına "Boşta" etiketi (`HR_BADGE_IDLE`, başlıktaki sayaçla aynı çizgi etiket). Durum'daki saat notu panelin rengini alır (mesai uyarı, kısa gün olumlu). Görevler lejantı başlık lejantının harfiyle ("ana, ikincil, alanı yok, kilitli"). Atlas bilgi satırı büyük harfle başlar. Eğitim başlığında tekrar eden künye kalktı; ÜCRET ve SÜRE sağa yaslı, sayılar da. Maliyetler maliyet glifiyle (zam farkı, kıdem tazminatı, moral düşümü, eğitim ücreti). Gece bandında 08:00 ve 00:00 bir kez. Aday kartında runway üst barın biriminde ("5 ay → 4 ay"; 21 hafta üst barda 5 ay). Kurucu dosyası "Kurucu / Unicorn Inc." ve "Yapımda görev alıyor". Aday yüzleri: soru 12. | çeşitli |

İnceleme sırasında bulunan ve düzeltilen: denetim EN Atlas karesinde yığın kartını kırptı ("Atlas Recruitment · 3 candidate
files ready", %8 geçişte üç nokta); yığının göndereni kısa ad "Atlas" oldu (`DESK_PAPER_TAG_ATLAS`, bugün de bu satırın
etiketi). EN menüde uzun eğitim gerekçesi metayı menünün dışına itiyordu; gerekçe artık etiket ile metanın altında satırın
tam genişliğinde.

## Tohumlar

| Ad | Kaynak | Üst bar |
|---|---|---|
| TEMA | `main.gd _seed_theme_surface` (hafta 14, 11:00), onaylı Ekip sayfası, `data/crowd40.json` | Kasa $10.000 · Net +$2,5K/ay · Runway Artıda · MRR $4,0K · Burn $1,5K/ay · Sıradaki "14:00 · Karadeniz Fabrika"; ray Satış 1, Ekip 1, Ar-Ge 2; BuildHUD "Unicorn Inc. v1" |
| İK | `main.gd _run_hr_shot` (gün 10, kasa 240.000 + bir finans tiki; çoğu hâlde gün 11), baseline `hr__*` | Kasa $229.304 · Net −$46K/ay (mürekkep, tehlike değil) · Runway 5 ay · MRR $0 · Burn $46K/ay · 08:00 · Sıradaki "Mesai bitimi · 9 saat"; BuildHUD yok (ürün yok) |
| İK-boş | aynı, kadro yok (`bos`, `gorevler-bos`) | Kasa $10.000 · Net −$1,5K/ay · Runway 7 ay · Burn $1,5K/ay |

**TEMA'nın ekonomisi kendi içinde çelişik (bulgu 9).** Üst bar Burn $1,5K/ay, Net +$2,5K/ay, Runway Artıda derken pencere
"Aylık maaş yükü $43.600" (40 kişide $130.000) gösterir; burn bordrodan küçük olamaz. Bugünkü oyunda da böyle (baseline
`tab__hr`): kusur `_seed_theme_surface`'ta, maketlerde değil. İK tohumu tutarlı: $43.600 bordro + $2.250 araç ≈ Burn $46K.
Kareler kabuk ve olaylar ile aynı üst barı korur; öneri soru 1'de.

**Bildirim yığını** (kabuk'un postası: gönderen · konu · kalan süre; hatırlatıcıda süre yok). TEMA: Nordica · Bir ekip
daha · 2 hafta, Ege Sigorta · Risk altında, Selin Kaya · Ayrılabilir. İK hafta 11: Atlas · 3 aday dosyası hazır (nötr
nokta, `DESK_PAPER_ATLAS_TITLE`), Selin Kaya · Ayrılabilir. İK hafta 10 (Atlas arama): yalnız Selin. İK-boş hafta 11:
yalnız Atlas. İK-boş hafta 10: bekleyen yok, yığın yok. Yığın 352 geniş, ticker'ın 24 üstünde (üç kart y 844, iki kart
y 904, bir kart y 964'ten 1016'ya).

## Çerçeveler

Yığın sütunu: görünür mü, gizliyse hangi dikdörtgen biniyor (`tools/audit.py` ölçer).

| PNG | Gösterdiği | Veri kaynağı | Yığın | Soru |
|---|---|---|---|---|
| `ekip__kadro.png` | Onaylı Kadro, 5 kişi: risk şeridi (Selin), Elif seçili, Mert izinde, Selin AYRILABİLİR, Müşteri İlişkileri boş grup; BuildHUD (kapalı düğme ve gerekçesi); Ofisi taşı. | TEMA, sistem sayfası 04/s1 | görünür | 1 |
| `ekip__kadro_renk_koru.png` | Aynı kare renk körü paletinde. | TEMA, `body.cb` | görünür | |
| `ekip__kadro_en.png` | Aynı kare EN. | TEMA | görünür | |
| `ekip__kadro_40.png` | 39 çalışan: liste kaydırılmış, başlık yapışık, Geliştirme kapalı (14), kaydırma çubuğu. Çalışan 39, Ortalama moral 50, Aylık maaş yükü $130.000. | `crowd40.json`. **Maaş türetildi:** `seed_staff` 34 kişinin maaşını 0 bırakıyor; rolün Orta bandının tabanı (yazılım $3.000, ürün ve test $2.700, tasarım, satış, müşteri $2.250). | gizli (pencere 88..1016) | 1, 9 |
| `ekip__kadro_40_siki.png` | Sıkı kip: 32 px satır, 24 px yüz, tek satır ad, Rol 176, Liderlik 80, Deneyim düşer (dosyada); liste sona kaydırılmış. | aynı | gizli | 2 |
| `ekip__kadro_40_siki_en.png` | Sıkı kip EN: "Customer Success Manager" Rol sütununda payıyla sığar; LEADERSHIP ve "Takes Them Under" da. | aynı | gizli | 2 |
| `ekip__satir_durumlari.png` | Belge sayfası (kabuksuz): Kadro satırının 11 hâli 1:1 (Boşta artık etiketli, mesai istisnası panelin rengiyle) ve dört şerit (risk, Atlas arayış, Atlas dosyalar, **saat çipi**: düz ve uygulanmış mesaiyle "1 çalışan mesaide"). | TEMA; eğitim hâlleri `egitim` fikstüründen; boşta `gorevler`'den; aşırı yük türetildi (Burak). | yok (kabuksuz) | 3 |
| `ekip__gorevler.png` | Görevler matrisi: "1 BOŞTA" ve "1 AŞIRI YÜK"; Selin iki işte, üçüncü hücre iş tavanıyla kilitli ve ipucu "En fazla iki iş."; Deniz Boşta etiketli; Mert izin hâlinde; Araştırma kilitleri ve gerekçesi lejantın sağında; lejant başlığın harfiyle. | TEMA + `gorevler` fikstürünün niyeti (Selin seçildi, r1 notu). | görünür | 3, 4 |
| `ekip__gorevler_renk_koru.png` | Aynı matris renk körü paletinde (AŞIRI YÜK uyarı etiketi). | aynı | görünür | |
| `ekip__gorevler_bos.png` | Kurucu yalnız: matrisin başlığı ve boş satır; ofiste kurucu tek. | İK-boş, hafta 10 | bekleyen yok | 6, 8 |
| `ekip__kadro_bos.png` | Kurucu yalnız: Atlas şeridi, dört boş bölüm; Ortalama moral değeri boş (anahtar taban çizgisinde); rayda Ekip nötr sayaç 1. | İK-boş, hafta 11 | görünür (Atlas) | 5, 6, 8 |
| `ekip__menu.png` | Elif'in satır menüsü: Dosyayı aç, Zam yap · Maaş $9.800, Terfi ettir · → Kıdemli Ürün Yöneticisi, Eğitime gönder kilitli (2 hafta, gerekçe altta tam genişlikte), İşten çıkar · kalıcı. | TEMA; `HRLedger._action_specs` | görünür | 13 |
| `ekip__menu_en.png` | Aynı menü EN ("The experience bar is not full yet." sığar). | TEMA | görünür | |
| `ekip__zam.png` | Zam yap (ModalLayer, perde): %3, kaydırıcı, Maaş $9.800 → $10.094 + maliyet glifiyle (aylık +$294), Moral 72 → 76, Aylık maaş yükü $43.600 → $43.894. Yığın perdenin altında. | baseline `hr__zam` | perde altında | 1, 14 |
| `ekip__cikar.png` | İşten çıkar: Kıdem tazminatı maliyet glifiyle $3.267 (0,3 ay), Nakit $10.000 → $6.733, bordro, araç, Ekip moral düşümü maliyet glifiyle −5; tehlike düğmesi. | baseline `hr__cikar` + TEMA kasası | perde altında | 1, 14 |
| `ekip__cikar_eksi.png` | Kasa $1.200 iken: Nakit → −$2.067 kırmızı + tehlike notu. | `cikar-eksi` kurulumu TEMA'ya | perde altında | 11 |
| `ekip__dosya.png` | Kadro + Elif'in dosyası (x 1576, 320): Şu an, huy, yedi beceri (ana altı çizili, rol bandı), Durum, eylemler (metalar menüyle aynı). BuildHUD gizli (dosya onun yerinde). | TEMA; `hr_dossier.gd` | gizli (dosya 88..911) | 7 |
| `ekip__dosya_kurucu.png` | Kurucu dosyası: "Kurucu / Unicorn Inc.", Şu an "Yapımda görev alıyor", altı alan + Liderlik + Karizma, Deneyim %0. | TEMA kurucusu (`crowd40.json` index 0) | görünür (dosya 621'de biter) | 7 |
| `ekip__egitim.png` | Eğitime gönder paneli (760, pencereye ortalı, y 88): ALAN · MEVCUT · HEDEF · ÜCRET · SÜRE (ücret ve süre sağa yaslı, ücretler maliyet glifiyle), Ürün seçili; arkadaki pencere kararmış ve amberi yok. | baseline `hr__egitim-modal`; seçilebilir hâl `egitim` fikstüründen | görünür | 10 |
| `ekip__egitim_kilitli.png` | Bar dolmadan: satırlar kilitli, süreler duruyor, gerekçe bir kez düğmenin yanında. | aynı | görünür | |
| `ekip__mesai.png` | Çalışma saatleri (1000, pencereye ortalı): Ofis günü bandı, kapsam tablosu (Mert İZİNDE, oksuz), bedel bloğu (Aylık burn $45.840 → $49.380, taslak). Arkadaki Kadro uygulanmış günü gösterir (çip mesaisiz). | İK + `saatler` | görünür | 9 |
| `ekip__mesai_en.png` | Aynı panel EN. | aynı | görünür | |
| `ekip__mesai_gece.png` | Gece sınırı taslağı (08:00, 16 saat, bitiş 00:00; $112.110); üst bar ve arkadaki Kadro uygulanmış günde (08:00 ile 17:00, "Mesai bitimi · 9 saat"); bantta 08:00 ve 00:00 bir kez. | İK + `saatler-gece` | görünür | 9 |
| `ekip__atlas_arama.png` | Atlas arama (1440, pencereyi örter): rol kutucukları (seçili: işaret + onay; Test Mühendisi üstünde; kilitliler gerekçeli), seviye Orta, büyük harfle başlayan bilgi satırı. | İK, hafta 10; seçim türetildi | görünür | 10 |
| `ekip__atlas_arama_1536.png` | Aynı panel 1536'da alanın tamamı (1424 × 712). | aynı | gizli (1536) | 10, 11 |
| `ekip__atlas_dosyalar.png` | Aday dosyaları (1560 × 742, pencereyi tamamen örter): üç belge kartı, kart 1 seçili (işaret + onay), kart 3 üstünde; runway "5 ay → 4 ay"; tek amber "İşe al · $3.850/ay". | İK, hafta 11 (`dosyalar`, baseline `hr__dosyalar`) | görünür | 12 |
| `ekip__atlas_dosyalar_en.png` | Aynı dosyalar EN. | aynı | görünür | |
| `ekip__atlas_dosyalar_1536.png` | Aynı dosyalar 1536'da alanın tamamı. | aynı | gizli (1536) | 11 |

## Yeni bileşenler (`ekip.css`, sistem grameriyle)

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.brand-sq` | Turuncu kare (karar 14 a), kabuk ile aynı yerde (20, 14) | `LogoEmblem` sabit renk, sahne sabiti |
| `.nstack`, `.notice` ekleri, `.bh-phase`, `.bh-act .why` | Kabuk'un bildirim yığını ve BuildHUD tohum hâli, `kabuk.css`'ten aynen | `office_notice_stack.gd`, BuildHUD |
| `.win.is-under` | PanelLayer açıkken altındaki pencere: `--dim` ile kararır, birincili ikincil çizilir | WindowLayer kök Control'ünün `modulate`'i `--dim`; birincil düğme `theme_type_variation` değişimi |
| katman kuralları | pencere 10 < menü ve ipucu 15 < kabuk 30 < perde 40 < modal 41; floatlar pencerelerin altında | WindowLayer < PanelLayer < kabuk < ModalLayer |
| `.nstrip`, `.mono.m32` | Kadro içi nötr şerit (Atlas arayışı ya da dosyalar), risk şeridinin biçimi | `HRUiShared` koyu `NoticeStrip` PanelContainer |
| `.tbl-view`, `.sb-track` | Yapışık başlığın altında kayan liste; 12 px kaydırma oluğu | bugünkü yapı; temalı ScrollBar |
| sıkı ızgara (`SM_W`), `.sk.sm`, `.cdata.role` | 32 px satır, Rol 176, Liderlik 80, Huy 138, Deneyim yok | `HRLedger` yoğunluk kipi |
| `.xp.is-full`, `.cdata.is-quiet`, `.row.is-anchor`, `.state .hn.warn/.pos` | Dolu deneyim barı; eğitimdekinin görevi ink-4; menüsü açık satır; Durum'daki saat notu panelin renginde | satır kiti |
| `.menu-who`, `.menu-item .meta` (`.ar`), `.menu-item.is-tall` (`.l1`) | Menü başlığı, sağda sonuç (ok ink-4), uzun gerekçe etiket ve metanın altında tam genişlikte | `HRPopover` + `HRLedger.action_list` (tek liste, menü ve dosya) |
| `.dos` ve parçaları, `.sk2-list`, `.sk2.is-role`, `.sk2.lead` | Belge pencere; yedi beceri, rol bandı, Liderlik çizgiyle ayrı | `hr_dossier.gd` + `WindowFrame` belge varyasyonu |
| `.mx-*`, `.jb.*`, `.mx-row.is-away`, `.mx-legend .lg/.why` | Görevler matrisi, izin satırı, başlığın harfiyle lejant, Araştırma kilidinin gerekçesi | `HRAssignments` |
| `.pnl-foot`, `.sec-h`, `.ttl-sub` | Panel alt barı, bölüm başlığı | PanelLayer pencere kiti |
| `.picks`, `.pick`, `.files`, `.afile` (`is-selected`, `is-locked`, `is-hover`), `.chk` | Seçim kartı: surface-4 + 3 px işaret + onay diski (Ürün tür seçicisiyle aynı); aday kartı belge | `hr_atlas_modal._card`, `_file_card` |
| `.who-line`, `.kvs`, `.kv`, `.pct`, `.slider.wide`, `.sl-ticks`, `.negnote`, `.fact`, `.cst` | İK diyalogları; `.cst` maliyet glifi + değer (kural 2) | `hr_action_modal.gd`, `training_modal.gd` |
| `.tr-row` | Eğitim alan tablosu (ücret ve süre sağa yaslı) | `training_modal._skill_row` |
| `.hrs`, `.stepper.sm`, `.rev`, `.hmor`, `.costs`, `.dayband` | Mesai tablosu, adımlayıcı, şirkete dön çipi, moral yönü, bedel bloğu, ofis günü bandı | `work_hours_modal.gd` + küçük `_draw` |
| `.sheet`, `.srow` | Yalnız belge sayfası | yok |

## Genişlik geçişi (bulgu 17)

`python tools/audit.py`: her metin %8 genişler (harf aralığına glif başına 0,04 em, Ürün'ün `overflow.py`'si gibi) ve
araç (a) kendi kutusunda üç noktaya düşen ya da kırpılan, (b) ızgara hücresinden taşan, (c) penceresinin, panelin,
dosyanın, menünün, modalın ya da float'ın dışına çıkan metni listeler. Kaydırılmış listede görünür alanın dışındaki satırlar
ve 1536'da alanla kesilen pencere atlanır. Aynı çalıştırma yığın ve BuildHUD dikdörtgeninin bir pencereye binip binmediğini
basar (yukarıdaki "Yığın" sütunu).

Sonuç r4: **28/28 temiz**, çizilen hiçbir float bir pencereye binmiyor. Sahtelik denemesi: EN sıkı karenin ızgarası eski
genişliklere (Rol 150, Liderlik 64, Huy 124) döndürülünce araç üç hata verir: "Customer Success Manager" kırpılır,
"LEADERSHIP" başlığı ve "Takes Them Under" hücreden taşar. Bu geçişte düzeltilen iki EN taşması yukarıda (yığın göndereni,
menü gerekçesi).

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

SPEC §13'te zaten önerilenler (Sıradaki şablonları, ana/ikincil, İzinde + {n} hafta, Seç, Vazgeç'in yeniden kullanımı,
huy etiketlerinin cümle düzeni) ve kabuk grubunun metinleri (Doğrulanmış {n}, Doğrulanmış hata yok., Bir ekip daha, Risk
altında; burada aynen) tekrar edilmedi. `build/strings.md` aynı tabloyu üretir.

| Anahtar (öneri) | EN | TR | Tür | Nerede |
|---|---|---|---|---|
| `TOPBAR_BRAND` | Project Unicorn | Project Unicorn | yeni | marka bloğu (olaylar ile aynı anahtar) |
| `HR_HOURS_WINDOW` değişikliği | {start} to {end} | {start} ile {end} arası | yeni değer | saat çipi (bugünkü değerde en dash var) |
| `HR_HOURS_CHIP_OVERTIME` bölünmesi | {n} on overtime | {n} çalışan mesaide | bölme | çipin ikinci parçası, uyarı renginde (yalnız uygulanmış mesaide) |
| `HR_SEARCH_START`, `_INLINE` | Start recruitment | İşe alım başlat | yeniden harf | artı bir ikon |
| `HR_CHIP_IDLE_COUNT`, `HR_CHIP_OVERLOAD_COUNT` | {n} idle / {n} overloaded | {n} boşta / {n} aşırı yük | yeniden harf | Görevler başlık etiketleri |
| `HR_BADGE_OVERLOADED_JOBS` | Overloaded | Aşırı yük | yeniden harf | Durum etiketi |
| `HR_BADGE_IDLE` | Idle | Boşta | yeniden harf | boştaki satırın Durum etiketi (r4) |
| `HR_STATE_TRAINING` bölünmesi | In training + {n} weeks | Eğitimde + {n} hafta | bölme | İzinde etiketinin ikizi |
| `HR_AGENCY_NAME` | Atlas Recruitment | Atlas Recruitment | yeniden harf | özel ad, büyük harf yok |
| `DESK_PAPER_TAG_ATLAS` | Atlas | Atlas | yeniden harf | bildirim yığınında gönderen (r4; tam ad EN'de kartı kırpıyor) |
| `HR_OPEN_FILES` | Open the files | Dosyaları aç | yeniden harf | şerit düğmesi |
| `HR_MENU_OPEN_DOSSIER` | Open file | Dosyayı aç | yeni | satır menüsünün ilk satırı |
| `HR_JOB_BUILD` (TR) | Build team | Yapım ekibi | TR değişikliği | "Build" TR metinde izinli ödünç kelime değil |
| `HR_LEGEND_NO_AREA` bölünmesi | no area | alanı yok | bölme | Görevler lejantı, başlık lejantının küçük harfiyle (r4) |
| `HR_LEGEND_LOCKED` | locked | kilitli | yeni | Görevler lejantı, küçük harf (r4) |
| `HR_ATLAS_START`, `HR_ATLAS_CANCEL` | Start search / Cancel | Arayış başlat / Vazgeç | yeniden harf | düğmeler |
| `HR_ATLAS_ARRIVAL` | Candidates arrive within {span} | Adaylar {span} içinde gelir | yeniden harf | bilgi satırı, büyük harfle başlar (r4) |
| `HR_ATLAS_FREE_NOTE` | The search is free · commission is paid on the hire | Arama ücretsiz · komisyon işe alımda ödenir | yeniden harf | bilgi satırı (r4) |
| `HR_SEARCH_CANCEL` | Cancel search | Arayışı iptal et | yeniden harf | arayış şeridi |
| `HR_ATLAS_HIRE` | Hire · {amount}/mo | İşe al · {amount}/ay | yeniden harf | seçili dosyanın tek amber düğmesi |
| `HR_ATLAS_FILE_N` | File {i}/{n} | Dosya {i}/{n} | yeniden harf | künye (`Fmt.upper`) |
| `HR_ATLAS_COMMISSION_ONCE` | one-off | tek seferlik | yeni | komisyon tutarının önünde |
| `HR_APPLY_RAISE_PCT` | Apply raise · +{pct} | Zammı uygula · +{pct} | yeniden harf | zam düğmesi |
| `HR_FIRE_CASH_NEGATIVE` | Cash goes below zero. The {n}-week shutter countdown starts. | Kasa eksiye düşer. {n} haftalık kepenk sayacı başlar. | yeni | çıkarma diyaloğu, `cash_after < 0` |
| `HR_TRAINING_CTA` | Send to training · {fee} | Eğitime gönder · {fee} | yeniden harf | eğitim düğmesi |
| `HR_HOURS_DAY_BAND` | Office day | Ofis günü | yeni | mesai bandının etiketi |
| `HR_COL_ROLE` | Role | Rol | yeni | sıkı kip sütun başlığı |
| `HR_FOUNDER_STATE_BUILD` | Working on the build | Yapımda görev alıyor | TR ve EN değişikliği | kurucunun Şu an'ı çalışanınkiyle aynı cümle (bugün "Bir yapımda çalışıyor" / "Working on a build") (r4) |

Anahtarsız değişiklikler (r4): zam metası `HR_ROW_SALARY` + tutar ("Maaş $9.800"); terfi metası ok glifi +
`HRConstants.job_title(rol, seviye + 1)` ("→ Kıdemli Ürün Yöneticisi"); Araştırma gerekçesi mevcut
`HR_ASSIGN_RESEARCH_ELSEWHERE`; boş kadro KPI'ı boş. r3'ün `HR_DOSSIER_FOUNDER_SUB` ("{role} · {company}") önerisi geri
çekildi: kurucu dosyasının alt satırı yalnız şirket adı.

## TR karelerinde mevcut İngilizce (bulgu 20)

İzinli ödünç kelimeler (Runway, Burn/burn, MRR), faz adı (Bootstrap, sözlükte kapı kararı 3) ve özel adlar (Project
Unicorn, Unicorn Inc., Atlas Recruitment, Nordica, Ege Sigorta, Karadeniz Fabrika, yayın adları) dışında, bugünkü CSV'den
gelen İngilizce:

| Metin | Anahtar | Nerede | Not |
|---|---|---|---|
| UX/UI Designer | `HR_ROLE_DESIGNER` (TR = EN) | rol satırları, Atlas rol kartı, Mesai | sözlük satırı "Tasarımcı" diyor (`localization_glossary.md` §4) |
| Junior | `HR_LEVEL_JUNIOR`, `HR_LEVEL_PREFIX_JUNIOR` | Atlas seviye kartı, unvan ön eki | `hr_constants.gd`: "§3.1: Junior iki dilde de Junior" (GDD kararı); izinli listede yok |
| B2B | `HR_ROLE_LOCK_SALES` ("Bu rol için B2B ürün gerekir.") | Atlas kilit gerekçesi | izinli listede yok |

r3'te listelenen "Build ekibi" önerisi (`HR_JOB_BUILD` → "Yapım ekibi") karelerde zaten uygulandı.

## Açık sorular (Erdem)

1. **TEMA ekonomisi** (bulgu 9): `_seed_theme_surface` burn'ü bordrodan türetsin mi (burn ≥ maaş yükü + araçlar ≈ $46K)?
   Türetilirse aynı kasayla runway yaklaşık bir haftaya düşer ve kabuk, olaylar, Ekip karelerinin üst barı birlikte
   değişir; tohum, örneğin kasayı büyüterek, "Artıda" anlatısını tutacak biçimde yeniden ayarlanabilir. Karar tohumun
   sahibinin; o zamana kadar kareler ortak üst barı tutar.
2. **Sıkı kip**: ne zaman? Oyuncu ayarı mı, kişi sayısı eşiği mi? Rol sütunu artık EN'de sığıyor (176); Durum kalır,
   yalnız Deneyim düşer.
3. **Aşırı yük etiketi** uyarı etiketi (SPEC §2.9 `ChipAmber`). Kadro'nun 142 px Durum sütunu iki rozet taşıyamaz
   (Ayrılabilir + Aşırı yük 162 px): Kadro'da yalnız en ağır rozet mi?
4. **Araştırma sütunu**: kilitlerin gerekçesi lejantta. Kişi araştırmadayken salt okunur işaretli hâl (kesikli kutuda
   mürekkep onay) eklensin mi? Karede yok.
5. **Boş kadro**: Ortalama moral boş (kural 9) mı, KPI hiç çizilmesin mi? Boş kadroda tablo başlığı kalsın mı?
6. **Ray rozeti**: `HRSystem.attention_count` kaçma riskini ve bekleyen dosyayı tek sayıda topluyor; kareler riskte
   kırmızı, yalnız dosyada nötr sayaç. Bölünsün mü?
7. **Dosya genişliği**: SPEC §9 "360 × fit, x 1576" 1936'da biter; kareler 320. 360 istenirse x 1536 olur, Ekip
   penceresine 24 px biner ve yığının dikdörtgenine daha erken girer. Hangisi? (Dosya açıkken yığın gizli: dosya 911'e
   iniyor.)
8. **Boş kadronun ofisi**: İK tohumunun ofisi iş hanı ama iş hanının yalnız kurucu olduğu bir plaka yok; kareler ev
   plakasını (`office_safe_1920_home.png`, kurucu masada tek) kullanıyor. Faz D iş hanı için yalnız kurucu plakası
   pişirsin mi, yoksa yalnız kurucu şirketi zaten evde mi açılır?
9. **Mesai taslağı**: panel açıkken üst bar, saat çipi ve Kadro satırları uygulanmış günü gösterir (baseline ile aynı);
   taslak yalnız panelde. Uygun mu?
10. **Panel yeri ve katman kararması** (bulgu 6 ve 8): PanelLayer paneli onu açan pencerenin ortasına hizalanır, alanın
    tepesine oturur; pencereyi tüm genişliğiyle örtüyorsa boyunu da alır. Alttaki pencere `--dim` (0,84) ile kararır ve
    amberini bırakır. SPEC §9 "centred" diyor; bu yorum ve kararmanın gücü (0,84 hafif; daha koyusu yeni bir token
    ister) onay bekliyor.
11. **Eksi kasa notu** kepenk süresini sabitten (`{n}` = 4) okur; metin ve süre onayı.
12. **Aday yüzleri** bugün yalnız aramada üretiliyor; karelerdeki yüzler baseline'ın 34 px avatarlarından büyütüldü,
    bulanık. Faz C'nin pişirme aracı aday görünüşünü de pişirmeli; Elif'in açık teni 32 px'te ink-2'ye yaklaşıyor
    (kırpım ve kenar halkası Faz C'de).
13. **Satır menüsünde "Dosyayı aç"** (klavyeyle dosyaya yol; sistem sayfası 03).
14. **Zam ve çıkarma** diyalogları kişiyi adlandırıyor (bugün başlıkta yalnız eylem var). Uygun mu?
15. **Ofis günü bandı** (Mesai paneli) yeni bir bileşen: tutulsun mu?
16. **1536**: Ekip penceresi 712'ye kırpılır ve gövde kayar (SPEC §8); ofis plakası 1536'da ikon raya göre büyütüldü,
    Faz D plakayı 64'ten başlatmalı mı?
17. Kaçma riski şeridinin oku kişinin dosyasını açar; gelen kutusunun "Dikkat" satırı ve yığındaki "Selin Kaya ·
    Ayrılabilir" aynı kişiyi gösterir. Üçü birden mi kalsın?
18. **Gruplar arası**: marka karesi kabuk ve olaylarda y 14, Ürün ve Satış-Finans karelerinde hâlâ y 13 (1 px). Bu grup
    kabuk'a hizalandı; diğer iki grubun sahibine iletilmeli.
