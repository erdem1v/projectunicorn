# Ürün rev 7 · A4 ekran maketleri (grup "urun")

Ürün rev 7 sprint ekranının görsel kabulü bu yeniden tasarımda yapılır (karar 11). Bu klasör PRD'nin C1 ile C5 ekranlarını,
fikstürün kart galerisini ve uç durumlarını, canlı koşu çekimlerini (`product__live_*`) onaylı Menajer Masası diliyle, tam
kabuk içinde 1920×1080'de (bir çerçeve 1536×864, ölçek 1.25) gösterir. Hepsi onay bekliyor.

- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, ikonlar (A2), kırpım kuralı, üst bar ızgarası. Sistemin
  eksiği `urun.css`'te (aşağıda "Yeni bileşenler"). Sistem klasörüne ve başka grubun klasörüne hiçbir şey yazılmadı; kit kopyaları
  ve önbellekleri `tools/syskit/`'te (olaylar grubunun kopyasıyla aynı, yol düzeltmeli).
- Pencere SPEC §9'daki ölçüde: 1424 × 928, (208, 88); 1536'da 1424 × 712, (88, 88), gövde kayar. BuildHUD ve bildirim yığını
  pencereyle çakıştığı için gizli (SPEC §9).
- Marka bloğu karar 14 (a): eski turuncu kare + "Project Unicorn", olaylar grubuyla aynı bileşen. (b) kabuk grubunun işi.
- Frank yok (Ürün'de konuşmuyor). Kurucu = `portraits/founder_01.png`. Yağlı boya yok.
- Metin: CSV'den (`localization/strings.csv`, salt okunur) ya da fikstürün TR/EN çiftlerinden (`scripts/debug/product_fixtures.gd`).
  Yeni metinler aşağıda, hepsi onay bekliyor. Fikstürün dört metni maket için değişti; fikstür dosyası bu turda düzenlenmedi
  (aşağıda "Fikstür metni değişiklikleri").

Yeniden üretmek: `python tools/gen.py` (HTML'ler `build/`), `bash tools/render_all.sh <tur>` (PNG'ler bu klasöre, kopyası
`rounds/<tur>/`; `_1536` ile biten 1536 864 1.25 çizilir). `python tools/overflow.py` her metni %8 genişletip (Godot payı, SPEC
§3.4) kesilen öğeleri listeler; `python tools/lint_spacing.py` sistemin boşluk denetimini `urun.css`'e uygular (temiz).
`python tools/crop.py <png> x y w h [ölçek]` inceleme kırpımı. Turlar: r1 (19 çerçeve, hepsi tam boy + 1:1 kırpım), r2
(düzeltme + 2 yeni çerçeve), r3, r4 (alan satırı, başlat gerekçesi, taşma denetimi), r5 son (temiz derleme), **r6 eleştiri
turu** (Ekip ve Ürün incelemesinin Ürün bulguları, aşağıda "Eleştiri yanıtı"; 21 çerçeve yeniden çizildi, değişen her çerçeve
tam boy ve `rounds/r6/crops/`'taki 1:1 ve 2-3× kırpımlarla okundu). r6 denetimleri: boşluk denetimi temiz; taşma denetimi
yalnız kutu önizleme satırlarının bilinçli üç noktasını ve olaylar başlığının Kime değerini buldu (soru 27).

## Eleştiri yanıtı (r6)

Ekip ve Ürün incelemesinin (27 bulgu) bu gruba düşenleri. Ekip'e ait bulgular (1-6, 8-17) ekip grubunun.

| # | Bulgu | Ne değişti | Çerçeve |
|---|---|---|---|
| 7 (S1) | Sprint kağıdı beklerken Sıradaki yedek gösteriyordu | Yuva "Sprint kararı · bu hafta son" (`warn`, SPEC §10 önceliği: yedeğin üstünde). Elmas yok: elmas bir saati işaretler, kağıdın saati yok, hafta bitene kadar sürer. SPEC §10'un "{time}" kalıbı için değişiklik önerisi soru 25'te (sistem klasörü bu grubun değil). | `urun__sprint_suruyor`, `urun__sprint_otomatik_basladi`, `urun__mvp_oncesi_karar`, `olaylar__sprint_karari_kagit` |
| 18 (S2) | Seçim kartında iki seçili dil | SPEC §5: yüzey-4 + 3 px işaret + tik (`util/check`, ink-1, sağ üst); çerçeve rengi boşta kalır. Atlas kartları aynı dile geçerse (ekip grubu) tek dil olur. | `urun__tur_secici` |
| 19 (S2) | "SPRİNT 7" etiket, "SPRINT" başlık | Tek yol `Fmt.upper`: CSV'de elle büyük yazılmış dört anahtar (`PRODUCT_SPRINT_TITLE`, `_VIEW_SPRINT`, `_THIS_SPRINT`, `_AT_SPRINT_END`) cümle düzeninden çizildi, TR'de her yer SPRİNT. Seçim soru 24'te. | Ürün çerçevelerinin hepsi |
| 20 (S2) | TR'de izinsiz İngilizce | Aşağıda "TR'de var olan İngilizce" listesi (sayılarıyla). Metin değişmedi. | |
| 21 (S2) | Gerçek marka "Excel" | "Tablo dışa aktarma (Palmiye)" / "Spreadsheet export (Palmiye)"; ses "Muhasebeci her ay tablo istiyor". Fikstürde de değişmeli (soru 28). | `urun__b2b_talepler` |
| 22 (S2) | Üç ödeyen hesap, MRR $0 | MRR ekrandaki sözleşmelerden: $12.000/yıl + $4.000/yıl = $1.333/ay → $1,3K; Net = $1.333 − $1.500 = −$167/ay; Runway = $10.000 / $167 = 60 ay. Beykoz'un bedeli fikstürde yok, sayılmadı. Kasa ve burn harness'ın. | `urun__b2b_talepler` |
| 23 (S2) | Kağıt maili olaylar gramerinde değildi | Olaylar'ın çalışan maili: "Merhaba," (`MAIL_GREETING_TEAM`) + gövde + yapısal imza, kapanış satırı yok; tarih Kime satırının sağında sabit sütunda (`DATE_W` 242). Yığın satırı kalan süreyi taşır: "bu hafta" `warn` (kabuk'un dili). Gövde hâlâ kartın bugünkü metni (soru 23). | `olaylar__sprint_karari_kagit` |
| 24 (S2) | Aynı not için iki glif | Ürün `util/play`'de kaldı (kıvılcım ve `product/kind_feature` özellik kartının glifi gibi okunur). Kabuk'un BuildHUD notu `kind_feature` kullanıyor; tek glif için kabuk'un değişmesi gerek (soru 26). | `urun__sprint_otomatik_basladi` |
| 25 (S2) | Boş sütun, gerekçe iki kez | Sütun gövdesinde sistemin boş durumu: ekip glifi 32, "Henüz kimse yok" (`HR_EMPTY_ROW`), ikincil "İşe alım başlat" (`HR_SEARCH_START`, SPEC §13 harf düzeltmesiyle, artı glif). Başlıktaki uyarı satırı kalktı; gerekçe ("Bu sprintte çalışacak kimse yok") yalnız kapalı Sprinti başlat'ın yanında. | `urun__ekip_yok` |
| 27 (S3) | Hedef menüsü solda açılıyordu | Menü şeridin sağ kenarına, okun altına açılır. | `urun__ceyrek_hedef_menusu` |
| 27 | Menü ikinci satırları küçük harfle | Menüde tek başına duran cümlenin ilk harfi büyür (TR i → İ, Godot'ta `Fmt` yardımcısı); şeritte satır içinde CSV'deki gibi küçük. | aynı |
| 27 | "B2C · ÜRÜN TİPİNİ SEÇ" dört kelime caps | Adım başlığı: cümle düzeni, `t-subhead`, kural çizgisiyle ("B2C · Ürün tipini seç"). | `urun__tur_secici` |
| 27 | Çeyrekte Onayla kartlardan 350 px uzak | Sütunlar en uzun sütunun içeriği kadar uzar, Onayla düğmeleri kartların hemen altında aynı hizada; Hepsini onayla sütunların altında. | `urun__ceyrek`, `urun__ceyrek_hedef_menusu` |
| 27 | Bütün B2B son tarihleri uyarı rengi | Uyarı yalnız bu ya da sonraki sprintte biten son tarihte (Nordica, Sprint 8); Palmiye'ninki (Sprint 10) mürekkep, saat glifi ink-4. | `urun__b2b_talepler`, `urun__kart_durumlari` |
| 27 | Kaydırma başlığı kesiyordu | Sesler çerçevesi açık alanın kendi satırından başlar (Onboarding & Erişim üstte). B2B çerçevesinde bütün alanlar kapalı ve kaydırma yok: Müşteriler satırı tam görünür (açık Güven & Ölçek onu panelin dışına itiyordu; SSO kartı sprint sütununda okunur). | `urun__sesler_acik`, `urun__b2b_talepler` |
| 27 | Kilitli kartta → açık | Kilitli kart iki sprinte de gidemez: + ve → kapalı. | `urun__kart_durumlari` |
| 27 | "Gerçekleşen: İlk hafta: …" | Sonuç satırı geçmiş satırıyla aynı: CSV'nin anahtar parçası ink-3, cümle ink-2; fikstür cümlesi iki noktasız ("10 yeni kullanıcıdan 6'sı ilk hafta kaldı (önce 4)."). | `urun__surum_notu`, `_en`, `_beta` |
| 27 | Tür seçicide ÇEYREK açık, Geçmiş görünür | Tür seçicide kontrol şeridi yok: ürün yokken gösterilecek sprint, planlanacak çeyrek, sürüm geçmişi yok (soru 22). | `urun__tur_secici` |
| 27 | Karar satırının konusu cümle | Satır "gönderen · konu": c2'de konu kağıdın başlığı "İki yol var" (`EV_PRODUCT_SPRINT_TWO_PATHS_TITLE`); fikstürün cümlesi mailin gövdesidir (soru 20). | `urun__sprint_suruyor`, `urun__sprint_otomatik_basladi`, `urun__kart_durumlari` |

## Dil kararları (sistemin bu ekrana uygulanışı)

| Konu | Bugün (krem) | Maket | Neden |
|---|---|---|---|
| Alan renkleri (`UiTokens.area_color`, 5 yuva) | kartın sol şeridi, kapasite dilimleri, hedef karesi, talep çipi | **kalktı**: alan adı, üç kare ve kelime taşır; kapasite dilimleri tek renk, 2 px aralıklı | SPEC §2.1 veri renkleri kategorik ton taşımaz; amber ve kırmızı dışında anlam ikinci kanalla okunur. Plan B4'teki `area_color` koyu ikizi gereksizleşir (soru 2). |
| Seviye kelimesi | Zayıf kırmızı | Güçlü `pos`, Yeterli `ink-3`, Zayıf `warn`, Yok `ink-4` | Kırmızı yalnız tehlike (kural 2). Zayıf bir dikkat durumu. |
| "!" alan uyarısı, kırmızımsı satır | rozet + satır zemini | yalnız uyarı üçgeni (`warn`), satır zemini yok | İkinci kanal şekil (kural 5). |
| Kapasite aşımı | kırmızı | `warn` dilim, `warn` sayı, kapasite çizgisinde 2 px işaret | Taşan kart devreder; tehlike değil (soru 3). |
| Amber | BU SPRINT, bölüm başlıkları, devreden, karar düğmesi, faz halkası | yalnız ekranın tek birincil eylemi (Sprinti başlat, Sprint N planına geç, Hepsini onayla, Onayla ve başlat, kutuda Cevapla) | Kural 1. Bölüm başlıkları `ink-3` caps etiket, süren faz `ink-1` nokta. |
| Pencere başlığı | serif ürün adı + CANLI çipi + tür | `ÜRÜN` başlığı + iki KPI: tür anahtarıyla ürün adı, "Sürüm" anahtarıyla sürüm | Pencere çerçevesi `frame_options` başlığı (plan F). Özel ad büyük harfe çevrilmez. |
| SPRİNT / ÇEYREK | bölmeli seçici, kilit ipucuda | sistemin segment sekmesi; kilitli sekmede kilit + etiket `ink-off`, gerekçe yanında `ink-3`. Tür seçicide şerit yok. | Kural 4: gerekçe her zaman görünür. |
| "SPRINT" büyük harfi | CSV'de elle "SPRINT" (noktasız), kart etiketi `Fmt.upper` ile "SPRİNT" | tek yol `Fmt.upper`: TR'de her yerde SPRİNT | Kural 7: caps yalnız `Fmt.upper` ile (soru 24). |
| Geçmiş | anahtar | sistemin switch'i, kontrol şeridinin sağında | |
| Sprint kartı | kâğıt kart, sol renk şeridi | sistemin `.sc` belgesi (kesik köşe); biten kart BİTTİ damgası taşır | Masa dili (kural 10). |
| Karar satırı | kartta "Karar ver" amber, modal açar | kartta "gönderen · konu" + "Karara git" ikincil + "Olaylar'da bekliyor · bu hafta" (`warn`); Olaylar'ı kağıt seçili açar | Sprint kararları `class: paper` (1 hafta süreli): gelen kutusunda kağıt, saat ancak Cevapla'da durur. Amber kapı noktası yalnız gerçek kesme kararında (soru 7). |
| Sıradaki yuvası, sprint kararı | üst barda sprint notu; SPEC §10 "Sprint kararı · 15:00" + elmas | bekleyen sprint kağıdı varken "Sprint kararı · bu hafta son" (`warn`), elmas yok | Kağıdın saati yok, hafta bitene kadar sürer; teklifin "bu hafta son" biçimiyle aynı (soru 25). |
| Sürüm notu saat tutması | sessiz | II etkin, üst barda kapı çerçevesi yok; notun altında duraklama satırı | Karar kapısı değil, ekran tutması (SPEC §6 "kilit olmayan duraklama"). |
| Liderin önerisi | satırın tamamı tıklanır | "Uygula" ikincil düğmesi | Görünmez tık alanı yerine açık eylem (soru 14). |
| Seçim kartı (tür seçici) | amber çerçeve | yüzey-4 + 3 px işaret + tik; çerçeve boşta kalır | SPEC §5 seçili durumu; Atlas kartlarıyla tek dil (eleştiri 18). |
| Kimse çalışamıyor | başlıkta uyarı, boş sütun | sütun gövdesinde sistemin boş durumu + ikincil "İşe alım başlat"; gerekçe yalnız kapalı CTA'nın yanında | Kural 4 tek yerde; boş durum çıkış yolunu gösterir (soru 29). |
| Faces | baş harf çipi, kurucuda amber | 32 px (ekip) ve 24 px (atanan, karar) yüz diski | Ekip penceresiyle aynı kişi dili; kurucunun amber halkası kalktı (SPEC §2.9). |

## Çerçeveler

"Fikstür" = `scripts/debug/product_fixtures.gd` (baseline `product__*`). "Canlı" = `--product-shot=live:*` (tema tohumunun kadrosu
gerçek SprintSystem'le). Fikstür ekonomi kurmaz: üst bar değerleri harness'ın (Kasa $10.000, MRR $0, Burn $1,5K, Net −$1,5K,
Runway 7 ay, Marka 50, İtibar 0); **B2B çerçevesi hariç**: orada üç ödeyen hesap göründüğü için MRR sözleşmelerden türetildi
(eleştiri 22). Tarih sprint kuralından türetildi: sprint 1 1. tikte başladıysa sprint n 2n−1. tikte planlanır, yani Sprint 7 =
Hafta 13 · Mart 2026; sürüm notu Sprint 7 kapanınca Hafta 15. Sıradaki yuvası: bekleyen sprint kağıdı olan dört çerçevede "Sprint
kararı · bu hafta son" (`warn`), ötekilerde SPEC'in yedeği ("Mesai bitimi · n saat").

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `urun__sprint_planlama.png` | C1: Notly B2C, Sprint 7 planlama. Onboarding & Erişim açık (Yapılanlar, Yapılabilecekler, Sesler kapalı), üç kart, Kısa kayıt üstünde (efor dökümü + → / Çıkar), Sprint sonunda öngörüsü, Liderin önerisi, Beta kanalı, Sprinti başlat; ÇEYREK kilitli "PM işe alınca". | Fikstür c1 (`ui.hover_card = kisa_kayit`). Hafta 13 · 08:00, II. | alan satırı, seviye kareleri, etki satırı, kapasite çubuğu, ekip satırı, öngörü çipleri, lider satırı, kilitli sekme gerekçesi | Sürüm, Uygula, Liderin önerisi (bölündü), Çıkar (yeniden harf) | 2, 5, 10, 11, 14, 19 |
| `urun__sprint_planlama_en.png` | Aynısı İngilizce. | Fikstürün EN çiftleri, CSV EN. | | Version, Apply, Lead's pick, Remove | |
| `urun__sprint_suruyor.png` | C2: Sprint 7 Hafta 1/2. Faz noktaları ve haftanın atananları, biten kart BİTTİ damgalı, Filtreli arama'da karar satırı ("Deniz · İki yol var", Karara git, Olaylar'da bekliyor · bu hafta), Durum satırı, Sonraki sürüm v1.5 · 1 hafta sonra. Sıradaki "Sprint kararı · bu hafta son" (uyarı). Rayda Olaylar sayacı 1 (süreli kağıt). | Fikstür c2; karar satırının konusu `product.sprint_two_paths`'in başlığı (`EV_PRODUCT_SPRINT_TWO_PATHS_TITLE`), gönderen kartın kişisi (PM yok, SENDERS.md). Hafta 13 · 11:00, 1x. | karar satırı, durum satırı, sonraki sürüm satırı, faz adımı + atanan yüzleri | Karara git, Olaylar'da bekliyor, Sprint kararı · bu hafta son | 7, 20, 25 |
| `urun__sprint_otomatik_basladi.png` | C2'nin otomatik başlamış hâli: başlığın altında "Sprint otomatik başladı" notu (`util/play`). Sıradaki sprint kararı. | Fikstür c2 + `PRODUCT_AUTO_STARTED` (PRD §3.11; SPEC §2.9 notu üst bardan Ürün'e taşır). Durumu fikstür kurmaz, kuraldan türetildi. | not satırı | | 8, 26 |
| `urun__sesler_acik.png` | Onboarding'in Sesler bölümü açık: dört ses, ilki YENİ etiketli; panel açık alanın kendi satırından başlar (ad üstte), Sesler panelin dibinde. | Fikstür `edge:voices_open`. | ses katlaması, YENİ etiketi | | |
| `urun__surum_notu.png` | C3: v1.5 sürüm notu, CANLI damgası, Çıkanlar, Devreden (3/5 kare → Sprint 8), Hız, Sonuç ("Gerçekleşen:" ink-3 + cümle), Basın (yayın adı yayın renginde), Lider satırı; solda Onboarding "Zayıf → Yeterli" oklu; sağda devreden kart üstte. Saat tutuluyor. | Fikstür c3; sonuç cümlesi iki noktasız (fikstür değişikliği, soru 28). Hafta 15 · 08:00, II. | sürüm notu (sürüm + damga, satır listesi, anahtar/değer ızgarası), devreden ilerleme kareleri | Sürüm notu açıkken oyun durur | 9 |
| `urun__surum_notu_en.png` | Aynısı İngilizce. | | | Paused while the release note is open | |
| `urun__surum_notu_beta.png` | Beta açık sürüm: CANLI damgası yok, "Beta kanalında · bir sonraki sprintte yayına girer", Beta kanalı Açık; başlık sürümü v1.4. | Fikstür `edge:beta_open`. | | | |
| `urun__ceyrek.png` | C4: Bu çeyrek şeridi (Onboarding · yeni kullanıcıların yarısı kalsın · 10 kare, hedef çizgisi 5'te, şu an 10 üzerinden 4), dar alan paneli, altı sütun (7 bu sprint, 8 ile 10 PM önerisi, 11 ve 12 boş) en uzun sütunun içeriği kadar, Onayla / Düzenle kartların hemen altında, tek birincil Hepsini onayla sütunların altında. | Fikstür c4. İlerleme metni CSV'den (`PRODUCT_GOAL_PROGRESS`), fikstürün "şu an 10'da 4" sabiti değil. | hedef ölçeri, çeyrek sütunu, mini kart | | 12, 16, 30 |
| `urun__ceyrek_hedef_menusu.png` | C4 + hedef menüsü açık, şeridin sağına (okun altına) hizalı: beş alan, her birinin altında kendi hedef cümlesi (ilk harf büyük), seçili Onboarding'de tik, Güven & Ölçek üstünde. | Fikstür c4; menü öğeleri alanlar + `PRODUCT_GOAL_*`. Bugün shot bayrağı yok (baseline INDEX). | hedef menüsü (sistemin `.menu`'sü, iki satırlı öğe) | | 15 |
| `urun__ceyrek_kilitli_pm_yok.png` | PM yokken ÇEYREK kilitli, gerekçesi yanında; akordeon kapalı, beş alan bir bakışta. (Her fikstür çerçevesi aynı kilitli sekmeyi taşır; bu çerçeve onu yalın gösterir.) | Fikstür `edge:quarter_no_pm`. | | | |
| `urun__gecmis.png` | Geçmiş açık: sürüm listesi (v1.2 · Sprint 3 · 2 kart · Gerçekleşen …, v1.4 · Beklenen …) alanların üstünde; switch açık. | Fikstür c1'in `versions`'ı + oyuncunun anahtarı (akordeon kapalı). | geçmiş listesi | | 13 |
| `urun__tur_secici.png` | Tür seçici, kontrol şeridi yok: Yolunu seç, B2C seçili (yüzey + işaret + tik, amber yok), "B2C · Ürün tipini seç" adım başlığı (cümle düzeni), B2C tipleri (Not & Bilgi Aracı seçili, tikli; Video Klip Aracı), Ürün adı "Notly" + Öner, Onayla ve başlat. Başlık "SÜRÜM · MVP · yayında değil". | Canlı `live:pick`, TypePicker'ın kod yolu açık hâliyle (pazar, tip, ad); tipler `ProductCatalog.TYPE_SCREEN` b2c `playable`. Ad canlı koşunun adı. | seçim kartı, adım başlığı | Öner, Onayla ve başlat (yeniden harf) | 22 |
| `urun__mvp_oncesi_karar.png` | MVP öncesi Sprint 1 Hafta 2/2, 15/15, gerçek kadro yüzleri (Kurucu, Elif Demir, Deniz Arslan, Selin Kaya); Metin Editörü'nde Elif Demir · Dışarıdan destek karar satırı; Sonraki sürüm v1.0 · 1 hafta sonra · 3 kart kaldı; orta sütun kayar. Sıradaki sprint kararı. | Canlı `live:active` (baseline'dan okunan kartlar, fazlar, atananlar). Hafta 2 · 08:00. Rayda Ekip 1, Olaylar 1. | | | 7, 25 |
| `urun__b2c_mvp_surum.png` | İlk sürüm: CANLI v1.0 notu, üç çıkan kart, iki devreden (1/3 ve 0/3 → Sprint 2), Hız 10/15, Beklenen: Çekirdek Zayıf olmalı, Lider Elif Demir; solda Çekirdek "Yok → Zayıf" yarım kareyle; sağda iki devreden kart. | Canlı `live:b2c_mvp`. Sonuç ve lider cümlesi CSV şablonlarından (`PRODUCT_RESULT_LEVEL_EXPECTED`, `PRODUCT_LEAD_CARRIED`). Hafta 3. | yarım seviye karesi | | |
| `urun__b2b_talepler.png` | C5: Fatura B2B. Bütün alanlar kapalı, kaydırma yok; Müşteriler satırı tam görünür (Nordica · SSO, Palmiye · Tablo dışa aktarma, Beykoz · 2 ticket; son tarih yalnız bu ya da sonraki sprintteyse `warn` saat ikonuyla, Palmiye'nin Sprint 10'u mürekkep; yıllık bedel, alan çipi); orta sütunda talep kartları; sağda "Nordica · SSO · son tarih" bayrağı (uyarı). Üst bar MRR $1,3K, Net −$167/ay, Runway 60 ay. | Fikstür c5; "Excel" → "Tablo" (fikstür değişikliği, soru 28); ekonomi ekrandaki sözleşmelerden türetildi (eleştiri yanıtı 22). | müşteri talep kartı, büyük harfsiz bayrak, son tarih uzaklığı | | 17, 18 |
| `urun__kapasite_asimi.png` | 16/12: iki kart DEVREDER etiketli, çubukta kapasite çizgisinden sonrası uyarı renginde, "Kapasite aşıldı · 2 kart devreder" ve "%125'in üstünde kart eklenmez" notları, adaylarda + kapalı; orta sütun kayar. | Fikstür `edge:over_125` (iki kart sprinte alınmış; öngörü fikstürün, yeniden hesaplanmadı). | aşım notu | Kapasite aşıldı · {n} kart devreder; %125'in üstünde kart eklenmez | 3 |
| `urun__ekip_yok.png` | Kimse çalışamıyor: 0/0 boş çubuk, ekip satırı yok; sütun gövdesinde sistemin boş durumu (ekip glifi, "Henüz kimse yok", ikincil "İşe alım başlat"); kartlar adaylara dönmüş ve + kapalı; Sprinti başlat kapalı, gerekçesi ("Bu sprintte çalışacak kimse yok") yalnız yanında. | Fikstür `edge:cap_zero`. Başlat gerekçesi bugün "En az bir kart ekle"; makette kapanan koşulun kendi metni (var olan `PRODUCT_TEAM_NOBODY`). Boş durumun iki metni Ekip'in boş satırınınki (`HR_EMPTY_ROW`, `HR_SEARCH_START`). | sütunu dolduran boş durum, kapalı birincil + gerekçe satırı | | 9 (alt madde), 29 |
| `urun__sprint_planlama_1536.png` | C1 1536×864 mantıksal (1.25): simge ray, sıkışık üst bar (yalnız turuncu kare, kısa tarih), pencere 1424 × 712, alan paneli ve orta sütun kayar, başlık ve alt şerit sabit. | Fikstür c1. Ofis plakası `office_safe_1536.png` 1472 genişliğe yayıldı (plaka 184'lük ray için çekilmiş). | | | |
| `urun__kart_durumlari.png` | Kabuksuz durum sayfası: ADAY, ADAY · acil, ADAY_ALINMIS, KILITLI (+ ve → kapalı), SPRINT_PLAN üstünde, SPRINT_PLAN devreder, SPRINT_AKTIF, SPRINT_AKTIF karar ("Deniz · İki yol var"), BITTI, PLANLANAN, DEVREDEN, BETA_BEKLIYOR, çeyrek mini kartları, adaysız alan, B2B talep kartı (yakın son tarih uyarı renginde). Her kart gerçek sütun genişliğinde (aday 362, bu sprint 550, sonraki 282, çeyrek 150). | Fikstür `cards` + c2 kartları. Sayfa başlığı ve etiketleri yalnız bu sayfanın (oyunda yok; durum adları `SprintCard.State` kod adları). | dar kart (başlık iki satır, etiketler ayrı satırda) | | |
| `olaylar__sprint_karari_kagit.png` | "Karara git"in açtığı yer: Olaylar, `product.sprint_contractor` kağıdı mail olarak seçili (Elif Demir, Ürün Yöneticisi; konu "Dışarıdan destek"; Kağıt · Bu hafta son; "Merhaba," + gövde + yapısal imza; tarih Kime satırının sağında; portre kuyusu; Cevabın altında "Bu hafta son" + Cevapla). Liste: bu kağıt + Hafta 1'de Frank'in tanışması. Yığında "Elif Demir · Dışarıdan destek · bu hafta" (uyarı). Sıradaki sprint kararı. BuildHUD yok: ürün henüz yayında değil (kabuk soru 20: kart ancak yayındayken var). | Canlı `live:active` dünyası, Hafta 2. Mail grameri olaylar grubunun (`../olaylar/olaylar.css` bağlantıyla okunur, kopyalanmadı; `DATE_W` olaylar'ın ölçüsüyle); gönderen SENDERS.md kuralı (Ürün Yöneticisi). Gövde kartın bugünkü TR metni, `{seam:urun.decision_card}` = Metin Editörü; tam mail dönüşümü yapılmadı (DRAFTS'ta değil). Tanışma satırı olaylar grubunun taslağı. | yığın satırında kalan süre (`.notice .nwk`, kabuk'unki) | (olaylar grubunun: Kağıt, Kime, Cevabın, Merhaba) | 23, 27 |

## Yeni bileşenler (`urun.css`, sistem grameriyle)

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.brand-sq` | Marka bloğunda 20 px turuncu kare (olaylar grubuyla aynı) | `LogoEmblem` sabit renk, sahne sabiti |
| `.kpi-val.is-text`, `.ctl-why`, `.switch-k` | Yazı değerli KPI (MVP · yayında değil), kilitli segment sekmenin gerekçesi, switch'in önündeki etiket | `frame_options` KPI yuvası; `SegTab` + gerekçe Label; CheckButton + Label |
| `.pb`, `.pa`, `.pcol` (`.is-center`, `.is-next`, `.is-pick`), `.pcol-h/-s/-f`, `.ph` | Üç sütun: alanlar listesi, iç sütun (`surface-2`), kesikli sonraki sütun; başlık ve alt şerit sabit, yığın kayar | `ProductTab` HBox, `SprintPanel.Column` (PanelContainer + ScrollContainer); kesik çerçeve bugünkü `RnDUiShared.draw_dashed_rect` |
| `.sec` (`.is-title`) | Caps etiket + çizgi (ALANLAR, YAPILANLAR, SPRİNT SONUNDA); `.is-title` cümle düzeninde adım başlığı + çizgi | `HRUiShared.section_header` koyu sürümü |
| `.sl`, `.w-*`, `.lv` | Üç seviye karesi (dolu = kelimenin rengi, yarım = cila) ve kelime | `SprintUiShared.Slices` `_draw`, `word_color` koyu ikizi |
| `.fxl` (`.p.due`, `.is-soon`) | Kartın etki satırı: parçalar 12 px aralıklı, ayraç glifi yok (sarılan satır noktayla başlamaz, bitmez); talep son tarihi yakınsa `warn`, uzaksa mürekkep | HFlowContainer `h_separation 12` |
| `.ar-row` (`.is-open`, `.is-compact`), `.ar-chips`, `.vc`, `.flg` (`.warn`), `.built`, `.vfold`, `.voice` | Alan akordeonu (açık = `surface-4` + işaret), ses sayacı, büyük harfsiz bayrak (rakip, son tarih), yetenek ızgarası, ses katlaması | `AreaPanel` |
| `.sc` uzantıları: `.kind`, `.pts`, `.acts`, `.hacts`, `.is-taken`, `.is-locked .lk`, `.sc-why`, `.narrow`, `.sc-tags`, `.sc-who`, `.sc-dec`, `.sc-dec2`, `.mini`, `.on-raised`, başlıkta BİTTİ damgası | Tek kart sahnesinin bütün durumları | `SprintCard.tscn` |
| `.capr`, `.capb` (`.s`, `.done`, `.over`, `.tick`, `.is-empty`), `.capv` | Kapasite çubuğu: kart başına tek renk dilim, biten kısım `bar-emph`, aşım `warn`, kapasite çizgisi | `SprintUiShared.CapacityBar` `_draw` |
| `.team`, `.note` (`.warn`, `.neg`) | Ekip yüzleri + uyarı cümlesi (büyük harfsiz) | HBox + TextureRect + Label |
| `.empty.is-col` | Sistemin boş durumu sütun gövdesini doldurur, ikincil eylemiyle | sistemin boş durum sahnesi, `size_flags_vertical = EXPAND_FILL` |
| `.fc` | Öngörü: sistemin `.fx` parçası, kazanç glifiyle | `EvChips` dilindeki parça |
| `.lead`, `.frow`, `.st`, `.nv`, `.empty-l` | Lider satırı, alt şerit, durum satırı, sonraki sürüm, boş satır | |
| `.rn-ver`, `.rn-sub`, `.rl`, `.prog-sq`, `.kvg` (`.v .rk`), `.o-*` | Sürüm notu: sürüm + damga, satır listesi, devreden ilerleme kareleri, anahtar/değer ızgarası (sonuçta CSV'nin anahtar parçası ink-3), yayın rengi | `SprintPanel._release`; yayın renkleri SPEC §2.7 token'ları |
| `.goal` uzantısı, `.gm`, `.qv`, `.qb`, `.qa`, `.qr`, `.qcols`, `.qc` (`.is-current`, `.is-empty`), `.qc-h/-t/-s/-f`, `.qfoot`, `.gmenu` | Çeyrek: hedef şeridi + on kare ölçer (hedef çizgisi), en uzun sütunun içeriği kadar altı sütun, iki satırlı menü öğesi (şeridin sağına hizalı) | `QuarterView.GoalMeter` `_draw`, PopupMenu yerine sistem menüsü sahnesi (iki satır için) |
| `.pk`, `.choice` (`.is-selected`), `.pk-ck`, `.pk-name`, `.pk-foot` | Tür seçici; seçili kart = yüzey-4 + işaret + tik | `TypePicker` |
| `.hist`, `.hv` | Geçmiş listesi | `AreaPanel._add_history` |
| `.notice .nwk` (`.is-warn`) | Bildirim yığını satırında kalan süre (kabuk'un dili, bu grupta kopyası) | `office_notice_stack.gd` |
| `.sheet`, `.sg` | Yalnız durum sayfası | yok |

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

SPEC §13'te zaten önerilenler (Sıradaki, Mesai bitimi, damga Bitti, Cevapla, Bu hafta son, `HR_SEARCH_START` harf düzeltmesi) ve
olaylar grubununkiler (Kağıt, Kime, Cevabın, `MAIL_GREETING_TEAM` "Merhaba,") tekrar edilmedi. Var olan ve yeniden kullanılanlar:
`HR_EMPTY_ROW` (Henüz kimse yok), `EV_PRODUCT_SPRINT_TWO_PATHS_TITLE` (İki yol var, karar satırının konusu).

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `TOPBAR_NEXT_SPRINT_FINAL` | Sprint decision · final week | Sprint kararı · bu hafta son | Sıradaki yuvası, bekleyen sprint kağıdı varken; SPEC §13'ün "Sprint decision · {time}" kalıbının yerine (soru 25) |
| `PRODUCT_VERSION_KEY` | Version | Sürüm | pencere başlığı KPI anahtarı |
| `PRODUCT_DECISION_IN_INBOX` | Waiting in Events | Olaylar'da bekliyor | kartın karar satırı (sekme adı değişirse bu da) |
| `PRODUCT_GO_DECISION` | Go to the decision | Karara git | kartın karar satırı düğmesi (`PRODUCT_DECIDE` "Karar ver" yerine) |
| `PRODUCT_LEAD_APPLY` | Apply | Uygula | liderin önerisi |
| `PRODUCT_RELEASE_HOLD` | Paused while the release note is open | Sürüm notu açıkken oyun durur | sürüm notu alt şeridi |
| `PRODUCT_OVER_CAPACITY` (+ `_ONE`) | Over capacity · {n} cards carry over / Over capacity · {n} card carries over | Kapasite aşıldı · {n} kart devreder | kapasite aşımı |
| `PRODUCT_ADD_CLOSED` | Adding closes above 125% | %125'in üstünde kart eklenmez | yük %125'i geçince |
| bölme `PRODUCT_LEAD_TIP` | Lead's pick + {name} | Liderin önerisi + {name} | caps etiket ve özel ad ayrı (özel ad büyük harfe çevrilmez) |
| bölme `PRODUCT_LEAD_LINE` | Lead + {name} | Lider + {name} | sürüm notu lider satırı |
| yeniden harf `PRODUCT_URGENT` | Urgent | Acil | "!" uyarı glifi olur, metin etikette |
| yeniden harf `PRODUCT_REMOVE` | Remove | Çıkar | düğme cümle düzeni |
| yeniden harf `PROD_NAME_SUGGEST` | Suggest | Öner | düğme |
| yeniden harf `PROD_CONFIRM_START` | Confirm and start | Onayla ve başlat | düğme |
| yeniden harf (caps stilden gelsin) | `PRODUCT_SPRINT_TITLE` ("Sprint {n}"), `_VIEW_SPRINT` ("Sprint"), `_THIS_SPRINT` ("This sprint"), `_AT_SPRINT_END` ("At sprint end") | "Sprint {n}", "Sprint", "Bu sprint", "Sprint sonunda" | CSV bunları elle noktasız "SPRINT" yazıyor; `Fmt.upper` ile TR'de **SPRİNT** okunur, kart etiketiyle aynı (eleştiri 19, soru 24). Ekranda değişir. |
| yeniden harf (caps stilden gelsin) | `PRODUCT_AREAS`, `_BUILT`, `_POSSIBLE`, `_VOICES`, `_NEW_STAMP`, `_NEXT`, `_STATUS`, `_NEXT_RELEASE`, `_RELEASE_NOTE`, `_LIVE`, `_SHIPPED`, `_CARRIED_OVER`, `_VELOCITY`, `_RESULT`, `_PRESS`, `_VIEW_QUARTER`, `_THIS_QUARTER`, `_APPROVED`, `PROD_PATH_B2C/B2B`, `PROD_TYPE_*_CATEGORY` | aynı, cümle düzeninde | CSV caps saklıyor; kural 7: caps yalnız `Fmt.upper` ile. Bunlarda ekranda değişiklik yok (CSV'deki büyük harf zaten Türkçe İ'li). |

Kullanılmaz hâle gelenler (onaya bağlı): `PRODUCT_PLANNED` (kesikli çerçeve "planlanan"ı söylüyor), `PRODUCT_DECISION_SPEAKER`
("{speaker}:" yerine "ad · konu"), `PRODUCT_DECIDE`, `PROD_LIVE_VERSION_LC` (başlık çipi KPI'ya döndü).

### Fikstür metni değişiklikleri (`scripts/debug/product_fixtures.gd`, bu turda düzenlenmedi)

Fikstür izlenen bir repo dosyası; maket değişikliği orada da yapılmazsa `--product-shot` çekimleri maketten ayrılır (soru 28).

| Satır (bugün) | TR bugün → maket | EN bugün → maket | Neden |
|---|---|---|---|
| `_deck` `excel` (≈454) | Excel dışa aktarma (Palmiye) → Tablo dışa aktarma (Palmiye) | Excel export (Palmiye) → Spreadsheet export (Palmiye) | gerçek marka (CLAUDE §5) |
| `_customer("Palmiye", …)` (≈313) | Excel dışa aktarma → Tablo dışa aktarma | Excel export → Spreadsheet export | aynı |
| `_heard` (≈298) | Muhasebeci her ay Excel istiyor → Muhasebeci her ay tablo istiyor | Our accountant asks for Excel every month → Our accountant asks for a spreadsheet every month | aynı |
| c3 `result` (≈275) | İlk hafta: 10 yeni kullanıcıdan 6'sı kaldı (önce 4). → 10 yeni kullanıcıdan 6'sı ilk hafta kaldı (önce 4). | First week: 6 of 10 new users stayed (4 before). → 6 of 10 new users stayed the first week (4 before). | CSV'nin "Gerçekleşen: " öneki ile çift iki nokta |
| c2 `decision.text` (≈416) | Filtreli aramayı iki şekilde yapabiliriz. → konu `EV_PRODUCT_SPRINT_TWO_PATHS_TITLE` ("İki yol var") | We can build filtered search two ways. → "Two ways through" | satır "gönderen · konu"; cümle mailin gövdesi (soru 20) |

### TR'de var olan İngilizce (onay listesi, eleştiri 20)

İzinli ödünç kelimeler (pitch, startup, demo, momentum, MRR, runway, churn, burn, laptop, mail, VC, özel adlar) dışında Ürün
çerçevelerinin TR metninde görünen İngilizce. Hepsi var olan CSV ya da fikstür metninden; bu grup hiçbirini eklemedi, hiçbirini
değiştirmedi. Sayılar r6 TR çerçevelerinin görünen metninden (`build/*.html`, `_en` hariç).

| Kelime | Nerede | Kaynak | Sayı / çerçeve |
|---|---|---|---|
| Sprint | sütun başlıkları, sekme, kart etiketi, son tarih, Sprinti başlat, sürüm notu | `PRODUCT_SPRINT_TITLE`, `_VIEW_SPRINT`, `_THIS_SPRINT`, `_AT_SPRINT_END`, `_TAG_SPRINT`, `_DUE_SPRINT`, `_SPRINT_END`, `_START_SPRINT`, `_PLAN_SPRINT`, `_AUTO_STARTED`, `PRODUCT_TEAM_NOBODY`; glossary "TR onay bekliyor" | 137 / 18 |
| Onboarding | alan adı ve kısa adı | `PRODUCT_AREA_ONBOARDING`, `_SHORT` (Ar-Ge'de `PROD_RND_NODE_ONBOARDING_FLOW`) | 68 / 17 |
| ticket | etki satırı, müşteri satırı, sonuç | `PRODUCT_FX_TICKETS_*`, `PRODUCT_CUSTOMER_TICKETS*`, `PRODUCT_AREA_TICKETS*`, `PRODUCT_RESULT_TICKETS_*` | 37 / 13 |
| PM | çeyrek kilidi, çeyrek sütunu etiketi | `PRODUCT_PM`, `PRODUCT_QUARTER_NEED_PM` | 19 / 15 |
| Beta | beta kanalı, kart etiketi, beta sürüm notu | `PRODUCT_BETA_CHANNEL`, `PRODUCT_BETA_WAITING`, `PRODUCT_RELEASE_BETA` | 17 / 15 |
| SSO | fikstür kartı "SSO (Nordica)", yetenek "SSO", alan cümlesi, bayrak | fikstür | 6 / 2 |
| MVP | sürüm KPI'ı | `PRODUCT_MVP_NOT_LIVE` | 2 / 2 |
| SaaS | B2B tür etiketi "Faturalama SaaS'ı" | fikstür (katalogda oynanabilir B2B türü ERP, soru 18) | 1 / 1 |
| UX/UI Designer | yalnız yüz ipucunda (çizilmiyor), canlı kadronun Deniz Arslan'ı | rol unvanı (CSV, SPEC §3.3 "Role titles: CSV case") | 0 görünür |

## Açık sorular (Erdem)

1. **Marka bloğu**: çerçeveler (a) turuncu kare + "Project Unicorn" ile (olaylar grubuyla aynı); (b) kabuk grubunda.
2. **Alan renkleri** kalksın mı? Alan kimliği ad, kareler ve kelimeden okunuyor; kapasite çubuğu tek renk. Kalırsa SPEC'e beş
   alan token'ı ve renk körü ikizleri eklenir, kategorik ton kuralı Ürün için istisna olur.
3. **Kapasite aşımı** `warn` mı (maket), bugünkü gibi kırmızı mı? Kural 2'ye göre aşım tehlike değil.
4. **Zayıf** `warn` (maket); "!" yalnız üçgen, satır zemini boyanmıyor.
5. **Başlık**: ürün adı KPI değeri olarak (`Notly`), tür anahtarı caps etiket ("B2C · NOT & BİLGİ ARACI"); serif başlık emekli.
   "Sürüm" anahtarı uygun mu, yanında CANLI etiketi de istenir mi?
6. **"Planlanan" damgası** kalksın mı (sonraki sütunun kesikli çerçevesi aynı şeyi söylüyor)?
7. **Sprint kararı** kartta kağıt olarak: "Karara git" Olaylar'ı kağıt seçili açar, saat Cevapla'da durur; satırda amber nokta
   yok, kalan süre `warn`. Kağıt beklerken üst barın Sıradaki yuvası "Sprint kararı · bu hafta son" (r6). Sistem sayfası 12'deki
   amber nokta bu yüzden değişti.
8. **Otomatik başlama notu** yalnız Ürün'ün orta sütununda (SPEC §2.9 BuildHUD'a da koyar; BuildHUD Ürün açıkken gizli).
9. **Sürüm notunun saat tutması** üst barda kapı gibi görünmüyor (II etkin, çerçeve yok); notun altındaki satır yeter mi? Alt
   madde (r6'da uygulandı): başlat kapalıyken gerekçe kapanan koşulu söyler (kimse yoksa "Bu sprintte çalışacak kimse yok", kart
   yoksa "En az bir kart ekle"); bugün hep ikincisi.
10. **Fikstür kişileri**: Ece ve Kaan'ın görünüşü yok; yüzler crowd40'tan aynı adlı kişilerden (Ece Doğan, Kaan Polat), Deniz
    `bust_deniz`'den (tohumdaki Deniz Arslan tasarımcı, fikstürdeki Deniz yazılımcı). Oyunda yüzler gerçek büstlerden gelir.
11. **Fikstür üst barı** ekonomi taşımıyor (Hafta 13'te Kasa $10.000, Net −$1,5K): harness değerleri tutuldu, yalnız tarih
    kuraldan. B2B çerçevesinde MRR sözleşmelerden türetildi (r6); Beykoz'un bedeli fikstürde yok. Fikstür `GameState`'e ekonomi
    yazsın mı?
12. Fikstürün "şu an 10'da 4"ü ile CSV'nin "şu an 10 üzerinden 4"ü farklı; maket CSV'yi (canlı yol) gösteriyor.
13. Geçmiş listesi model sırasında (eskiden yeniye); en yeni üstte mi olsun?
14. **Liderin önerisi** "Uygula" düğmesiyle (bugün satırın tamamı tıklanıyor).
15. Çeyrek hedef menüsü her alanın hedef cümlesini ikinci satırda gösteriyor (var olan `PRODUCT_GOAL_*`, ilk harfi büyütülmüş);
    uygun mu?
16. Çeyrekte sütun "Onayla" düğmeleri ikincil, tek birincil "Hepsini onayla" (kural 1).
17. B2B'de Müşteriler satırı listenin sonunda (oyun sırası); talepler önemliyse alanların üstüne alınsın mı? (r6: B2B çerçevesi
    bütün alanları kapalı gösteriyor ki satır tam görünsün; bir alan açıkken satır panelin dışına düşer.)
18. Fatura'nın türü fikstürde "Faturalama SaaS'ı"; katalogda oynanabilir tek B2B türü ERP.
19. Kartın üstünde düğmeleri (→, Çıkar) etki satırının sağ ucunda (bugün sağ üstte, rol ikonlarını ve puanı örtüyordu).
20. ~~Karar satırının konusu~~ r6'da uygulandı: satır "gönderen · konu", konu kağıdın başlığı (c2'de "İki yol var"). Olaylar'ın
    `subject` alanı gelince satır onu okur. Fikstürün c2 cümlesi değişmeli (soru 28).
21. EN: "Lead's pick", "Waiting in Events" (sekme adı değişirse bu metin de değişir).
22. ~~Tür seçicide ÇEYREK~~ r6'da uygulandı: tür seçilene kadar kontrol şeridi hiç yok. Seçenek: SPRİNT etkin + ÇEYREK kilitli,
    gerekçe yeni metinle ("Ürün seçilince açılır"). Hangisi?
23. Kutudaki sprint kağıdı r6'da olaylar'ın mail gramerinde (Merhaba, gövde, yapısal imza); gövdenin kendisi kartın bugünkü
    metni, Ürün Yöneticisi'nin sesiyle yeniden yazımı olaylar grubunun tam dönüşüm adımı.
24. **SPRİNT mi SPRINT mi?** Maket tek yolu seçti: `Fmt.upper`, TR'de her yerde SPRİNT (kural 7). Glossary'de "sprint" izinli
    ödünç kelimelerde değil (TR onay bekliyor). "Sprint" Türkçe kabul edilirse büyük hâli SPRİNT'tir; İngilizce terim olarak
    kalacaksa noktasız SPRINT için `Fmt.upper`'a istisna listesi gerekir (önerilmez). Hangisi olursa olsun başlık, sekme ve
    etiket aynı okunur.
25. **SPEC §10 değişikliği (sistem sahibine):** sprint kararları kağıt (bir hafta) olduğundan Sıradaki önceliğindeki "Sprint
    kararı · 15:00" + elmas biçimi artık oluşmaz. Öneri: kalıp "Sprint kararı · bu hafta son" (`warn`, yeni anahtar
    `TOPBAR_NEXT_SPRINT_FINAL`), elmas yalnız saati olan şeyde (görüşme). Kabuk'un `ustbar__durumlar` satırı da buna uyar. Bu
    grup sistem klasörüne yazmadı.
26. **Otomatik başlama glifi:** Ürün `util/play`; kabuk'un BuildHUD notu (`ustbar__sprint_otomatik`, `.bh-auto`) `product/
    kind_feature` kullanıyor, özellik kartının glifiyle karışıyor. Tek glif `util/play` olsun mu (kabuk'un değişikliği)?
27. **Olaylar mail başlığı (olaylar grubuna):** portre kuyusu olan mailde Kime değeri 242 px'lik tarih sütununun yanında Godot
    payıyla (+%8) kısalır: "Kurucu · Unicorn Inc." Chrome'da 132 px ile ancak sığıyor, Godot'ta ~145 px ister (`overflow.py`
    %8 genişletmede kesildi; tarih sütunu 242 + 12 px). Olaylar'ın
    belgelediği davranış ("2. satırda önce Kime değeri kısalır"); kabul mü, tarih sütunu saatsiz tarihte daralsın mı?
28. **Fikstür metinleri:** yukarıdaki beş satır `product_fixtures.gd`'de de değişmeli (izlenen dosya, bu tur dokunulmadı).
    Değişmezse `--product-shot=c2/c3/c5` çekimleri maketten ayrılır ve "Excel" oyunda görünmeye devam eder.
29. **Boş sprint sütunu:** "Henüz kimse yok" + "İşe alım başlat" (Ekip'in boş satırının iki metni). Kapasite 0, kurucu başka
    işteyken de olabilir; o durumda doğru çıkış "Ekip'e git" (atama) olabilir. Düğme işe alım mı, Ekip'e geçiş mi?
30. **Çeyrek boşluğu:** sütunlar artık içerik kadar; 1080'de sütunların altında ~290 px boş kalıyor (Ürün penceresi SPEC §9'da
    sabit 928). Pencere çeyrekte içeriğe göre kısalsın mı, boşluk kalsın mı?
