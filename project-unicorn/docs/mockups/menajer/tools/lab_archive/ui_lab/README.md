# UI LAB

Tema laboratuvarı. Oyunun gerçek kabuğunu (TopBar, LeftTabs, NewsTicker, İş hanı ofisi, Ekip ve Satış
pencereleri, olay modalı) 1920×1080'lik bir sahnede örnekler ve temasını canlı değiştirir. Oyuna dokunmaz: saat
kilitlidir, sahneye girdi gitmez, laboratuvar yalnız `shots/` altına kare ve `docs/audits/UI_OVERRIDES.md` yazar.

## Açılış

- **Editör:** `UiLab.tscn` açıkken **F6** (Run Current Scene). F5 `Main.tscn`'i koşar. Bir yönün stil kartı tek
  başına: `themes/<yön>/StyleTile.tscn` açıkken F6.
- **MCP:** `editor-run`, sahne `res://sandbox/ui_lab/UiLab.tscn`. Kök `/root/UiLab`; metotlar aşağıda.
- **Batch** (`project-unicorn/` içinden, pencereli):

  ```
  "$GODOT" --path . res://sandbox/ui_lab/UiLab.tscn --ui-lab-shot=all --lang=tr --windowed --resolution 1280x720 --audio-driver Dummy
  ```

  `--ui-lab-shot=` değeri: `all` (baseline için ekip, satis, olay; sonra `theme.tres`'i olan her yön için ekip,
  satis, olay, style_tile), `baseline`, `audit` (yalnız override denetimi) ya da `themes/` altındaki bir klasörün
  adı (`evrak`, `dosya`, `gazete`). `all` içinde teması olmayan yön `SKIP` olur, adıyla istenen yönün teması yoksa
  hatadır; `StyleTile.tscn`'i olmayan yönün kartı `SKIP` olur. Başarısız kare ya da hata varsa çıkış kodu 1, yoksa
  0. Bayrak `--` ayracının önünde durur; arkasında görünürse laboratuvar 2 ile çıkar. Pencere boyu kareyi etkilemez,
  ama pencere küçültülmemelidir (Windows o zaman çizmez).

## Dosyalar

- `UiLab.tscn`, `core/ui_lab.gd`: sahne, ekran ve tema seçimi, bekleme, çekim, MCP yüzeyi.
- `core/override_audit.gd`: override denetimi. `core/build_direction.gd`: tema kurucusu. `core/style_tile.gd`: stil
  kartı.
- `shots/`: kareler (`.gdignore` ile içe aktarılmaz). `themes/<yön>/`: yönün sözleşme dosyası, teması, stil kartı,
  dokuları ve fontları.

## Tuşlar

| Tuş | İş |
|---|---|
| F1 | ekran ekip (Ekip penceresi) |
| F2 | ekran satis (Satış penceresi) |
| F3 | ekran olay (olay modalı) |
| F4 | ekran bos (yalnız çerçeve ve ofis) |
| 0 | tema mevcut (proje teması) |
| 1 | tema evrak |
| 2 | tema dosya |
| 3 | tema gazete |
| F12 | o anki tema ve ekranı `shots/`'a çek |

Numpad 0, 1, 2, 3 de çalışır. Başka her tuş ve her fare tıkı yutulur: hızlı kayıt (F5), hız tuşları (1 ile 4 arası,
Space), debug F tuşları ve tıklar oyuna ulaşmaz. Teması olmayan yönün tuşu hiçbir şeyi değiştirmez; HUD "tema yok"
der. Açılışta basılan satır tabloyla aynıdır:
`UI_LAB|KEYS|F1=ekip|F2=satis|F3=olay|F4=bos|0=mevcut|1=evrak|2=dosya|3=gazete|F12=çek`.

HUD sol üstte durur ve kareye girmez: tema, ekran, palet (renk körü ya da standart), gösterim ölçeği, durum
(meşgul, uyarı, son kare).

## MCP yüzeyi

`/root/UiLab` metotları argümansızdır ya da tek String alır. Her çağrı işi kuyruğa koyar ve hemen döner; sonuç
`status()`'tan okunur.

- `set_screen("ekip" | "satis" | "olay" | "bos" | "style_tile")`
- `set_theme("mevcut" | "<themes/ altındaki klasör>")`
- `shoot()`: o anki durumu çeker (F12 ile aynı). `shoot_all()`: `all` listesini sırayla çeker; laboratuvar son
  karenin tema ve ekranında kalır.
- `status()`: `{busy, theme, screen, last_path, last_size, last_error, clock_held, cb}`. `busy` false olduğunda
  ekran oturmuştur; teması olmayan yön `last_error`'da "tema yok: <yön>" yazar.
- `capture-viewport /root/UiLab/StageBox/Stage` o anki karenin PNG'sini verir; oturmuş ekranda batch karesiyle
  bayt bayt aynıdır.
- Tuşlar `inject-key` ile de sürülür (`F1`, `0`, `F12` …); hız tuşları yine yutulur.

## Ekranlar ve sahneler

Her ekranda aynı `scenes/main/GameShell.tscn` örneği durur: `TopBar.tscn`, `LeftTabs.tscn`, `NewsTicker.tscn`,
`BuildHUDPanel.tscn` ve merkezde `scenes/office/OfficeView.tscn`. Pencereleri oyunun kendi `WindowLayer`'ı açar.

| Ekran | Nasıl | Sahne |
|---|---|---|
| ekip | `EventBus.tab_changed.emit("hr")` | `scenes/tabs/HRTab.tscn`, pencere 1200×720, konum (100,70) |
| satis | `tab_changed("sales")` | `scenes/tabs/SalesTab.tscn`, pencere 1280×760 |
| olay | `tab_changed("")` ve ModalHost'a modal | `scenes/modals/EventModal.tscn`, kart `funding.frank_cheque` (`EventGate.render`, kapsamsız) |
| bos | `tab_changed("")` | yalnız kabuk ve ofis |
| style_tile | batch ya da `set_screen`, tuşu yok | `themes/<yön>/StyleTile.tscn`; kabuk gizlenir, kart kendi temasını taşır |

**Örneklenemeyen sahne yok:** hiçbir koşu `UI_LAB|INSTANCE_FAIL` satırı basmadı. Örneklenip ekrana gelmeyenler
PanelLayer ve ModalLayer sakinleridir (Ekip satır popover'ı, Atlas, mesai ve eğitim modalları, onay modalları):
yalnız tıkla açılırlar ve laboratuvar tık geçirmez. Açılsalar da CanvasLayer tema kalıtımını kestiği için
ThemeRoot'un temasını almazlardı.

## Veri, bekleme ve kare

- **Veri:** `main.gd`'nin `_seed_theme_surface` tohumu (424242, hafta 14, 5 çalışan, 3 müşteri, 2 aday), ağaca
  eklenmeyen tek bir `main.gd` örneğiyle bir kez kurulur. Ofis İş hanı (`ishani`), saat 11:00. Dil
  `TranslationServer.set_locale("tr")` ile gelir; ayara yazılmaz.
- **Palet:** renk körü paleti oyuncunun ayarını izler; laboratuvar ayara dokunmaz. Durum her `SHOT` satırında
  (`cb=`) ve denetim başlığında yazar.
- **Haber bandı** ilk karesinden x=0'da donuktur: her kare akışın aynı yerini gösterir.
- **Görüntü:** sahne ekrana piksel piksel çizilir; pencere küçükse sığacak kadar küçültülür, asla büyütülmez.
  Pencereye dokunulmaz. Kare her durumda 1920×1080'dir.
- **Bekleme:** her ekran ve tema değişiminde ve her çekimden önce. Kişiler yerleşmiş ve 60 ısınma karesi geçmiş
  olmalı; son değişiklikten beri 3 kare ve 0,4 sn, süren tween yok (döngülü tween hiç bitmez, kare zaman
  aşımına düşer), portre stüdyosu boş, Control dikdörtgenleri üç ardışık karede aynı. Sonra `frame_post_draw`
  beklenir. 10 sn'de karşılanmayan koşul adıyla `SHOT_FAIL` olur ve dosya yazılmaz.
- **Kare:** `Stage.get_texture().get_image()`; 1920×1080 ve tek renk değilse
  `shots/<baseline|yön>/<ekip|satis|olay|style_tile>.png` (tema mevcut `baseline`'a yazar).
- **Satırlar:** `UI_LAB|SHOT|<yol>|sha256=…|office_hash=<ofis SubViewport görüntüsünün sha1'i>|data_fp=<tohum,
  hafta, saat, ofis, kasa, MRR ve sıralı karakter, müşteri, aday id'lerinin sha1'i>|cb=<0|1>|theme=…|screen=…`;
  ayrıca `SHOT_FAIL`, `SKIP`, `THEME|<ad>|<n>/11` (11 ortak adın kaçı taban tipiyle tanımlı), `GLYPH|<ad>|<rol>|
  <font>|<k>/12` (başlık, gövde ve mono yüzünün temel font dosyasında `ığüşöçİĞÜŞÖÇ`), `AUDIT`, `AUDIT_FAIL`,
  `INSTANCE_FAIL`, `DONE|shots=|fails=|errors=`.
- **Sağlama:** oyunun kendi harness'i aynı veriyle aynı ekranı çeker. `--office-shot=ishani:11:hr` ve `:sales`
  kareleri `baseline/ekip.png` ve `satis.png` ile haber bandı (y ≥ 1046) dışında piksel eştir; bantta yalnız
  kayan metin farklıdır. Tema geri alınınca eski durum kalmaz: tek süreçte baseline, yön, yeniden baseline kareleri
  bayt bayt aynıdır.

## Güvenlik

- `TimeManager.hold_clock("ui_lab")` `_ready`'nin ilk satırıdır: saat ilerlemez, gün tiki ve otomatik kayıt olmaz.
  Koşulabilen her sandbox sahnesi (stil kartları dahil) aynı kuralı taşır.
- Sahnenin `SubViewport`'unda `gui_disable_input` açıktır: oyun düğümlerine tuş, tık, hover ulaşmaz. KeyRouter
  (kökün son çocuğu) her tuşu ve tıkı yutar. Olay seçeneği tıklanamaz; olay çözümü ve onun tetiklediği otomatik kayıt
  da olmaz.
- Settings, Localization, DisplaySettings, AudioManager ayarlayıcıları ve `UiTokens.set_colorblind` hiç çağrılmaz;
  `settings.json`'a ve kayıt yuvalarına dokunulmaz.
- Batch bayrağı `-shot` içerir: DisplaySettings pencereyi yönetmez, otomatik kayıt kapalıdır. F6 ve MCP koşusu
  harness sayılmaz (kayıtlı pencere ayarı uygulanır, otomatik kayıt açıktır); saat kilitli olduğu için yine de
  kayıt yazılmaz.
- Laboratuvarın yazdığı yerler yalnız `sandbox/ui_lab/shots/` ve `docs/audits/UI_OVERRIDES.md`'dir; kurucu yalnız
  `themes/<yön>/theme.tres` yazar.

## Override denetimi

Her açılışta (etkileşimli ya da batch) tema mevcut iken dört ekran sırayla gezilir, sonra ekip'e dönülür. Yalnız
oyun düğümleri sayılır: GameShell alt ağacı ve olay modalı, Window'lar dahil. Düğüm API'si override listesi
vermediği için her düğüme sınıf zincirinin varsayılan tema öğeleri, master temadaki bütün öğe adları ve `scripts/`
ile `scenes/` içindeki sabit override adları sorulur. Satır: sahne · düğüm yolu · tür · öğe · değer. `separation`,
`h_separation`, `v_separation` ve `margin_*` yerleşimdir (UI yasası izinli), gerisi görseldir (taşınacak).
Satırların ardından sahne başına sayım (görsel, yerleşim), toplam ve en çok override taşıyan üç sahne. Ekler:
tema dışı görünüm (`ColorRect`, `modulate`, BBCode rengi), temayı kodda okuyan yerler, bütün scriptlerde
`add_theme_*_override` çağrı sayımı. Zaman damgası yoktur, sıra kararlıdır; içerik değişmediyse dosya yazılmaz.

## Yön sözleşmesi ve tema kurucusu

**Sözleşme.** Her yön `themes/<yön>/` altında yaşar. `direction.gd`'de class_name yoktur; kurucu ve stil kartı onu
çalışma anında `load()` eder. Taşıdıkları:

- `const PALETTE`: 6 ile 8 adlı renk; stil kartı bu sırayla gösterir.
- `const TOKENS`: UiTokens renk adı → renk. Aynı değeri paylaşan grubun (ör. CARD_BG · SURFACE_HOVER ·
  TAB_ACTIVE_BG) tek üyesi bütün grubu taşır; bir grubun iki üyesi farklı değer alamaz, site bazında ayrım
  `adjust()`'ta yapılır. Dört değer özellik türüne göre ayrılır: `1B232B` dolgu BG_AVATAR, kenar SEPARATOR ·
  `F6F1E6` dolgu BG_BODY, yazı ON_INK · `E3DAC9` dolgu SURFACE_SUNKEN, çizgi DIVIDER_LIGHT · `E8EDF2` yazı CREAM,
  dolgu PORTRAIT_FRAME. Listelenmemiş alfa ikizi (SHADOW_SOFT, CARD_FLOATING_BG, AMBER_*, *_RULE,
  CREAM_DIM_DISABLED …) listelenen opak ebeveyni kendi alfasıyla izler; listelenen ikiz kazanır.
- `const FONTS`: 8 rol (`serif_reg serif_sb serif_it sans_reg sans_sb mono_reg mono_label mono_sb`; ek yüz serbest)
  → `{file, axes, features, spacing_glyph}`. `file` yön klasörüne göredir ya da `res://` yoludur. Eksen ve özellik
  metin etiketle yazılır (`{"wght": 600, "opsz": 24}`, `{"tnum": 1}`); kurucu INT etikete çevirir, desteklenen
  eksenlere karşı sınar, aralık dışını kırpar. opsz kendiliğinden ayarlanmaz, açık yazılır. `spacing_glyph`
  verilmezse master rolününki geçer (mono_label ve mono_sb: 1).
- `static func canonical(th, dir, fonts)`: 11 ortak adın öğelerini kurar; tabanları çekirdek koyar. Button:
  FolderTab, FolderTabSelected, FolderTabSoon, PrimaryButton, InkButton (normal, hover, pressed, disabled kutuları ve
  dört `font_*_color`). PanelContainer: FolderWindow, PaperCard (`panel`). Label: Stamp (`normal`, font,
  font_color), AttentionBadge (`normal`, font_color), DataMono ve TickerLabel (font, font_color); Stamp ile
  AttentionBadge'in kutusunu Label'ın kendi `normal`'ı çizer. `fonts` kurucunun rol başına kurduğu
  FontVariation'lardır (fallback NotoSansSymbols2).
- `static func adjust(th, dir, fonts)`: ROLE_MAP'ten sonra yalnız görünüme dokunur (ör. gazete kolon çizgisi,
  ModalCard'ın 40 px gölgesini geri koymak); paylaşılan bir kutuyu değiştirmeden önce çoğaltır.
- Ham `Color()` yalnız adlı sabitlerde yazılır, boyutlar UiTokens'tan gelir: benimsenirse `build_theme.gd`'ye UI
  yasasıyla taşınabilir.
- `StyleTile.tscn`: tam ekran kök Control, `core/style_tile.gd` ve `yon = "<yön>"`; theme.tres'e ext_resource
  yoktur. Kart palet ve hex, üç yüz satırı (rol, gerçekten çizen yüz ve değişken fontta çizilen eksen değerleri,
  dosya, 32 px glif satırı), üç kulak durumu ve seçili kulağın FolderWindow kenar bandını tam örten bindirmesi,
  PaperCard, döndürülmüş Stamp, AttentionBadge, PrimaryButton, InkButton ve haber bandında TickerLabel gösterir.

**Kurucu.** `project-unicorn/` klasöründen:

```
"$GODOT" --headless --path . -s res://sandbox/ui_lab/core/build_direction.gd --yon=<yön>
```

Master'a dokunmadan yeni bir Theme kurar: tam kopya (131 varyasyon, 480 öğe; sayı tutmazsa FAIL), token kimliğiyle
tek geçişte renk, rol takaslı fontlar, `canonical()`, ROLE_MAP, `adjust()`, birleşim, doğrulama. Yalnız
`themes/<yön>/theme.tres` yazar, o da hiç FAIL yoksa. Satırlar `UILAB <yön>` ile başlar; son satır
`UILAB <yön> RESULT PASS|FAIL fails=<n>`, FAIL'de çıkış kodu 1. Aynı girdiyle iki kurulum bayt bayt aynı dosya verir
(alt kaynak kimlikleri sabit, dosyanın uid'i korunur); `metadata/uilab_source_digest` kurucunun, master'ın,
`ui_tokens.gd`'nin, `direction.gd`'nin ve başvurulan her font ve dokunun sha256 özetidir. theme.tres üretilmiş
dosyadır; her çekimden önce yeniden kurulur. Kurucu içe aktarılmış dosya okur: yeni TTF, SVG ya da PNG önce
`--import` ister.

**Kimlik modu.** `--yon=_identity --identity` master'ı hiçbir token, kanonik, ROLE_MAP ve birleşim uygulamadan,
master'ın kendi 8 FontVariation'ıyla `themes/_identity/theme.tres`'e kopyalar; 11 ad denetimi dışında her denetim
koşar. Kopyanın sadakat kanıtıdır: `--ui-lab-shot=_identity` kareleri baseline ile bayt bayt aynıdır.

**ROLE_MAP.** Taban bağları değişmez; kanonik görünüm hedefe doğrudan yazılır (düzleştirme), çünkü hedefin kendi
öğeleri yeniden bağlanan bir tabanı gölgelerdi.

- FolderTab → TabButton, ChromeTabButton · FolderTabSelected → TabButtonActive, ChromeTabButtonActive
- FolderWindow → WindowPanel, ModalCard, ModalPanel
- PaperCard → CardPanel, CardPanelTight, LedgerRow, ChoiceCard, CardFloating. Hover ikizleri (CardPanelTightHover,
  LedgerRowHover, ChoiceCardHover) PaperCard kutusunu kendi kenar rengiyle ve en kalın kenarla alır.
- AttentionBadge (Label `normal`) → TabBadge (`panel`) · DataMono (yalnız yüz) → MetricValue, MetricValueInk,
  StepperValue, MeetingFigure, ConvictionValue
- PrimaryButton → CommitButton · InkButton → temel Button (WindowClose ve ActionRow onun yüzünü ve mürekkebini
  devralır) · TickerLabel → NewsRich (`font` → `normal_font`, `font_color` → `default_color`)
- FolderTabSoon ve Stamp'in gerçek ekranda hedefi yoktur, yalnız stil kartında görünür. Kalan her varyasyon yalnız
  renk ve rol fontu alır.

Hedef korur: etkin content margin (açık değer olarak yazılır), font_size, sabitler, ikonlar, focus kutusu, durum
kümesi. Kanonikten gelir: çizilen kutu, font ve yazı renkleri (yalnız hedefin tanımladığı anahtarlar); font
tanımlamayan Button kanoniği hedefin fontuna dokunmaz. Rol hedefe yalnız font ve renk ekleyebilir.

**Birleşim.** Sahip kararıdır ve çekirdekte, `adjust()`'tan sonra uygulanır: TabButtonActive'e
`expand_margin_right = 4`, WindowPanel'e `expand_margin_left = 16` (WindowLayer.EDGE); seçili kulak ile pencere
çerçevesi x=84'te buluşur. ChromeTabButtonActive ve ModalCard'a uygulanmaz; WindowPanel'i kullanan dosya penceresi
ve harita kartı da 16 px sola uzar.

**Doğrulayıcı.** FAIL:

- 11 addan biri eksik, yanlış tabanda ya da zorunlu öğesi eksik.
- Master tipi, tabanı ya da öğesi eksik; master sayıları beklenenden farklı.
- Etkin content margin, font_size, sabit ya da ikon boyutu master'dan farklı; master tipine stil, boyut ya da sabit
  eklenmiş.
- Rol eksik; temel fontun ilk rid'inde `ığüşöçİĞÜŞÖÇ` eksik (fallback ve sistem fontu sayılmaz); desteklenmeyen
  eksen; aynı değişken dosyayı farklı eksenle paylaşan roller eşit genişlikte.
- ProgressBar ya da BuildProgress dolgusu StyleBoxFlat değil (HR moral çubuğu yalnız düz dolguyu boyar).
- Bilinmeyen ya da çelişen token; palet 6 ile 8 renk dışında; null font, doku ya da kutu; `direction.gd`
  derlenmiyor ya da sözleşmesi eksik.

REPORT:

- Çözülmüş token tablosu (UiTokens sırasıyla eski > yeni, `listed` / `group:<üye>` / `alpha:<ebeveyn>`, site sayısı;
  laboratuvarda sitesi olmayanlar işaretli), eşlenmemiş tokenlar, token'sız renkler.
- Rol başına yüz adı, kullanıldığı boyutlarda satır yüksekliği (master > yön), örnek metnin genişlik oranı, `tnum`
  desteği, opsz yazılmamış değişken font.
- Sıcak noktalar: TopBar Kasa ve MRR 104 px (kırpar), tarih 210 px (büyür), ray kulağı 76 px (taşar), modal başlığı
  ve gövdesi.
- Expand margin'ler ve gölgeler; korunan margin'den geniş kenar ya da texture_margin; çizildiği boydan büyük 9-dilim.
- Kontrast (WCAG, master'la yan yana; `LOW` 4,5'in altında, `WORSE` master'dan kötü): BadgeLabel/TabBadge,
  NewsRich/NewsPanel, MetricValue/TopBarPanel, CommitButton, INK/CARD_BG, CREAM/DIALOGUE_BG; POSITIVE, NEGATIVE ve
  `_CB` ikizleri CARD_BG üzerinde; kodun çerçeveye boyadığı POSITIVE_BRIGHT, NEGATIVE_BRIGHT, `_BRIGHT_CB` ikizleri
  ve ACCENT_CHROME (NET, runway, kepenk, teklif, logo; bant kaynağı ACCENT_HEX) UiTokens değeriyle yönün BG_TOPBAR
  zemininde, `(code)` işaretli. Açık çerçevede CREAM/DIALOGUE ve VEIL uyarısı.
- Farksız hover ikizleri; düz olmayan LedgerRow uyarısı; `adjust()` farkı; master dışı ek tipler.

**Satır yüksekliği.** `Font.get_height` fallback dahil bütün yüzlerin en büyüğünü verir: Label yüksekliği
NotoSansSymbols2'nin metriğinin altına inmez, yön yüzü ondan yüksek değilse değişmez. RichTextLabel satırı ise
çizen yüzün metriğini izler; gövde yüzü değişince olay modalı gibi metne göre boylanan kutular kısalır ya da uzar.
Genişlikler her durumda değişir.

## Temanın ulaşamadıkları

ThemeRoot'a verilen tema şunlara ulaşmaz; hepsi kodda boyanır ya da temayı başka yerden okur:

- **TopBar:** logo kutusu (`ColorRect`); NET, runway, kepenk ve teklif renkleri; sabit sütun genişlikleri (Kasa ve
  MRR 104 px, tarih 210 px).
- **Ray:** sekme etiketi ve ikon renkleri; kilitli kulak (modulate 0,45 ve YAKINDA hapı), yani FolderTabSoon gerçek
  rayda görünmez.
- **Haber bandı:** kaynak adının rengi (BBCode, `ACCENT_HEX`).
- **Pencere:** iç boşluklar (`window_frame.gd`) ve boylar (`WindowLayer` SPECS). Başlık çerçevenin üst kulağına
  taşınamaz: çerçevede başlık düğümü yoktur, her sayfa başlığını kendi sol üstüne çizer; spec §7'deki "başlık
  pencerenin üst kulağında" bir düzen değişikliğidir.
- **Ekip:** çizgiler, KADRO ve GÖREVLER sekmeleri, mesai çipi, durum ve huy çipleri, moral çubuğu rengi (düğüm ağaca
  girmeden temadan okunur), avatarlar.
- **Satış:** etiket renk override'ları, rozetler, yıldızlar.
- **Olay modalı:** karartma, kaynak, etki, ilişki ve kilit çipleri, çizgiler, kilitli seçeneğin alfası.
- **Genel:** build ve Ar-Ge çubukları (`bar_kit.gd` proje temasını okur), CanvasLayer'daki popover'lar, 3B ofis
  (renkleri sahne verisidir).

Sonuç: Stamp gerçek ekranlarda hiç görünmez; çipler bugünkü düz hapları korur, yalnız yazı yüzleri ve altlarındaki
kâğıt değişir. Font değişimi iç boşluğu ve boyutu korur, glif metriklerini korumaz: kurucu raporlar, kırpılma karede
denetlenir.

## Benimseme yolu

Erdem bir yönü seçerse, ayrı bir görevde:

1. `scripts/theme/ui_tokens.gd`: çözülmüş token tablosunun yeni değerleri girilir; grup üyeleri ve alfa ikizleri
   kuralla gelir. `ACCENT_HEX` elle güncellenir, `_CB` ikizleri yeniden denetlenir, `THEME_STAMP` artar.
   `ON_ACCENT` ve `BADGE_FG` bugün `INK`'in değer grubundadır: yönün vurgu dolgusu koyuysa bu ikisi benimsemede
   ayrı (açık) değer alır, yoksa kodun boyadığı rozet ve düğme yazıları dolgunun üstünde kaybolur. Laboratuvarda
   CommitButton yazısı PrimaryButton kanoniğinden geldiği için etkilenmez.
2. `build_theme.gd` fontları: `FONT_*` yönün dosyalarına bağlanır (`res://assets/fonts/<aile>/` ve OFL.txt);
   `_mkfont` INT eksen ve özellik alır. `variations/*.tres` yeniden üretilir; el yapımı `sans_it.tres` elle bağlanır.
3. `build_theme.gd` biçimleri: 11 kanonik eklenir (`canonical()` UI yasasıyla taşınır; dokular `res://assets/ui/`'a,
   renkler UiTokens adlarına). ROLE_MAP hedefleri PAD_* korunarak yeniden türetilir, birleşim expand margin'leri
   eklenir; ROLE_MAP tablosu iş listesidir.
4. Satır içi override'lar `docs/audits/UI_OVERRIDES.md` iş listesiyle, ayrı bir kararla taşınır (çipler, HR
   çizgileri ve sekmeleri, mesai çipi, ray tonu).
5. Bütün yüzeylerde görsel kabul (koyu sahneler, gazete, ayar ikonları).

Bir `theme.tres`'i `gui/theme/custom` yapmak kodsuz bir önizlemedir, kalıcı değildir: `build_theme.gd` onu üretmez.

## Spec §12 kavramları laboratuvarda

- **Theme ve type variation:** tema `ThemeRoot.theme`'e verilir, alt ağaç kalıtımla alır. Godot bir öğeyi önce ata
  temalarında, varyasyon zincirinin tamamında (`CardPanel`, sonra `PanelContainer`) arar, ancak sonra proje temasına
  iner. Bu yüzden yalnız 11 yeni ad tanımlayan tema gerçek ekranda hiçbir şey değiştirmez, yalnız temel tipleri
  tanımlayan tema ise her varyasyonu ezer: yön teması master'ın 131 varyasyonunun tamamını taşır ve ROLE_MAP
  görünümü hedefe düzleştirir. Kalıtım CanvasLayer ve SubViewport'ta kopar; tema bu yüzden sahnenin içindeki bir
  Control'e verilir, modal da onun altına kurulur. `THEME|<ad>|11/11` satırı 11 adın tabanıyla tanımlı olduğunu
  gösterir.
- **StyleBoxTexture ve 9-dilim:** kulak ve kâğıt dokusunun kenarları `texture_margin` kadar sabit kalır, ortası
  esner. `svg/scale` 1 olmalı, dilim çizgisi kenar yumuşatmasını kesmemeli; içe aktarılmamış doku çerçeveyi sessizce
  siler. İç boşluk (`content_margin`) dokudan bağımsız yazılır; -1 kalırsa `texture_margin`'e düşer. Kurucu, kenar
  payı çizildiği en küçük boyu (kulak 76×64, Satış seçicisi 19 px, rozet 8×8, satır 40 px, birincil düğme 36 px)
  aşan dokuyu raporlar.
- **Override önceliği:** düğümdeki override her temayı ezer; sonra ata temalar, proje teması, Godot'un varsayılanı.
  Laboratuvar bunu gizlemez: tema değişip kutusu değişmeyen her şey `UI_OVERRIDES.md`'de bir satırdır.
- **Font dosyaları ve varyasyon:** `FontVariation` eksenleri INT etiketle alır (wght 2003265652, opsz 1869640570,
  wdth 2003072104); metin etiket sessizce varsayılan örneği çizer, opsz kendiliğinden ayarlanmaz. `Font.has_char`
  fallback'leri de sayar ve içe aktarma sistem fontuna düşebilir; `GLYPH` satırı ve kurucu bu yüzden temel font
  dosyasının kendi yüzüne sorar. Tabular rakam: sayı rolleri (DataMono) üç yönde de IBM Plex Mono'dur; `tnum`
  özelliği ancak font dosyası taşıyorsa açılır. Kullanılan sans dosyalarında yoktur: IBM Plex Sans'ın rakamları
  zaten eşit genişliktedir, Libre Franklin'inkiler orantılıdır (gazete'de DataMono dışındaki rakamlar).
- **Sandbox izolasyonu:** her şey `res://sandbox/ui_lab/` altındadır; oyun sahneleri örneklenir, kopyalanmaz;
  kapılar (`loc_residue`, `all_scripts_load`) bu klasörü görmez. Saat kilidi ve girdisiz sahne oyunun durumunu
  korur. Reddedilen yön klasörüyle birlikte silinir.

## Bilinen sınırlar

- Tema değişiminde oyunun kendi yenileme yayınları kullanılır: `palette_changed` (pencereler yeniden kurulur;
  TopBar, bildirim yığını ve Ekip yeniden boyanır) ve `news_stream_changed` (bant yeniden ölçülür); olay modalı ve
  stil kartı yeniden kurulur. Ofis yeniden örneklenmez.
- Tema dosyası her seçişte diskten okunur: laboratuvar açıkken yeniden kurulan tema, tuşuna yeniden basınca gelir.
- Kök düğüm düz bir Node'dur: MCP'nin `set_theme(String)`'i Control'ün kendi `set_theme(Theme)`'iyle çakışırdı.
