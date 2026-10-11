# Ana menü · NOTES

## Konsept (5 satır)
1. Kimlik şehirdir: oyunun gerçek şehir çekimi (`office_safe_1920_city.png`) ×1,75 büyütülüp akşama çevrilmiş, kareyi dolduruyor; kulelerde seyrek yanık pencere.
2. Menü solda yaslı tek sütun: logo kilidi (turuncu kare solda, sağında iki satır Project / Unicorn; S 96), altında Barlow 700/30 kalemler. Kurucu, büst, slogan, künye yok.
3. Tek amber iş: açık yüzeyin birincilinin altındaki 48×3 çizgi (kayıt yoksa Yeni oyun, varsa Devam kartı).
4. Dönen oyuncuda Devam bir karttır: şirket amblemi, adı, hafta, kasa, son oynama. Yükle yalnız kayıt varken.
5. Köşeler sessiz: sol altta yalnız "Demo · Sürüm"; dil otomatik, Ayarlar'da değişir; açılış wordmark → Godot kartı → menü.

## Yeniden kullanılan / yeni
- **Aynen:** `system/tokens.css`, `base.css`, `modallar.css` (marka karesi `--brand-mark`, `modal`/`dlg-*` kromu). Ayarlar penceresi (06) dün geceki 07'nin bloğu birebir. Oyun içi onay (09) dün geceki 11'in HTML'i birebir. Yükle penceresi (05) dün geceki 06'nın bloğu; dün geceki `menu_final/menu.css` yalnız bu listenin sınıfları için bağlı.
- **Yön B'den:** kalem tipi ve amber çizgi kuralı, sabit üst (Devam eklenince marka yerinde kalır), kesik köşe `doc-sm`.
- **YENİ:** akşam plakası (`tools/bake_evening.py`), sola yaslı sütun, Devam kartı, Godot kartı, sade Jenerik, düz Lisanslar, logo kilidi (tek satırlı marka ve yığılı kilit atıldı), Yükle'de kurucusuz grup başlığı.
- **Atılan (sahip):** büst + kaide + künye, slogan, sağ alt Dil · Discord · Wishlist, Jenerik'in Teşekkür / Müzik / bekletme notu / sekmesi, Lisanslar'ın 104 bileşenlik katlı dizini, dil kapısı.

## Akşam plakası
- Kaynak gerçek motor çekimi (gündüz). Gök, kenara bağlı düz bölge olarak ayıklanır (B'nin `bake_city.py` yöntemi); şehir `#161310 → #5E5449` sıcak kömür bandına eşlenir, kendi renginin %16'sı kalır (kiremit, su, park okunur: "bizim şehir"), gölgeler hafif maviye kayar.
- Yanık pencere: cam kulelerin parlak-mavi pencere pikselleri, 7×6 hücre karmasıyla %17'si sıcak (`#D8B072`) yakılır, sönükler 0,62'ye kararır, hafif pişmiş hale. Amber token kullanılmadı; pencere ışığı sanattır, UI rengi değil.
- Sol %24'e kadar `surface-0`'a %85 solar, %64'te tamamen açılır; alt %14 hafif kararır (sürüm satırı zeminde durur).
- **Oyunda:** tek `TextureRect`, pişmiş PNG (1920 ve 1536 ayrı ya da 1920 tek + `STRETCH_KEEP_ASPECT_COVERED`); shader gerekmez. Asıl kaynak `--office-shot=city:<akşam saati>` ile alınırsa motorun kendi gece ışığı gelir ve pencere karması gereksiz kalır (denenmedi; Godot koşulmadı). Pişirme adımı kaynağa bağımlı değil, aynı betik çalışır.

## Jenerik: yayınlanmış oyunlar nasıl yapıyor (kısa)
- Godot belgesi (lisans sayfası) Godot MIT için tek şart koyar: lisans metni oyunda bir yerde bulunsun. Yöntemlerden biri yeter: jenerik ekranının sonu, ayrı "Third-party Licenses / Open Source Licenses" ekranı (çoğu ayarlarda), çıktı günlüğü, kurulumda yanında dosya ya da `godotengine.org/license` bağlantısı. Üçüncü taraf bileşenler için `COPYRIGHT.txt`'yi `GODOT_COPYRIGHT.txt` adıyla dağıtmayı önerir.
- Menü araştırması: Software Inc., Big Ambitions, Manor Lords, Frostpunk 2 Jenerik'i ana listede tutuyor; ayrı bir "Lisanslar" öğesi hiçbir ana menüde yok. Jenerik ekranı rol → ad listesi + motor/araç logoları; yasal metin ya jeneriğin sonunda ya ayrı alt sayfada.
- Bu set o kalıbı izler: Jenerik tek pencere (roller, sürüm, telif, Godot satırı), lisanslar bir alt sayfa (tek düz metin), aynı metinler exe yanında `LICENSES/` klasöründe (DENETİM §2.4).

## Godot fizibilitesi
- **Açılış:** `boot_splash/image` = 01'in PNG'si, `bg_color #100E0B`, `minimum_display_time 0`, `show_image true`; motor yüklenirken görünür. 01b ilk sahnedir (`Splash.tscn`): logo `TextureRect` (Godot'un `icon.svg`'sinden arka karesiz SVG; Godot SVG'yi içe aktarımda raster'lar, 132 px için 2× içe aktar) + `Label`; `Timer` 1,5 sn, herhangi bir tık/tuş atlar, oturumda bir kez. Menüye geçiş 200 ms solma (`--dur-base`).
- **Menü:** kök `Control` + `menajer_theme.tres` elle atanır. `TextureRect` (plaka) → `VBoxContainer` (sol üst sabit; logo kilidi → kalemler). Logo kilidi metin değil `lockup.svg` varlığıdır (`TextureRect`, S 96; 1536'da 76); `MenuWordmark` varyasyonu gerekmez. Kalem `Button` `flat` + `MenuItem` varyasyonu; amber çizgi düğmenin altında 48×3 `ColorRect`, yalnız birincilde.
- **Devam kartı:** `Button` (flat) içinde `PanelContainer` (`doc-sm` StyleBox: corner_detail 1, sağ üst `cut-sm`) → `VBox` [Devam `Label` + amber `ColorRect`, `HSeparator`, `HBox` (amblem + üç `Label`)]. Veri: `SaveManager` son okunabilir yuvanın meta'sı: şirket adı, hafta, kasa, `unix` zamanı ("2 saat önce" göreli biçim yeni bir `Fmt` yardımcısı ister) ve **amblem tohumu** (onboarding setinin yeni logo sistemi; meta'da yoksa amblem şirket adından yeniden üretilir, sistem deterministikse ek alan gerekmez).
- **Yükle (05):** mevcut SaveLoadModal; grup başlığından kurucu kalkar (bugün meta'da kurucu zaten yok, DENETİM S2: iş azalır).
- **Ayarlar (06):** menünün kendi `ModalLayer`'ında mevcut `SettingsModal`. Dil satırı zaten var.
- **Dil otomatik:** ilk açılışta `Settings.language` boşsa: Steamworks varsa `Steam.getCurrentGameLanguage()` ("turkish" → tr, diğerleri → en), yoksa `OS.get_locale_language()` ("tr" → tr, diğerleri → en). Seçim kaydedilir; sonra yalnız Ayarlar'dan değişir. Bugünkü dil kapısı ilk açılıştan kalkar (davranış değişikliği, onay bekliyor).
- **Jenerik / Lisanslar:** onaylı `modal` kromu; Jenerik `GridContainer`; Lisanslar `ScrollContainer` + tek `Label` (autowrap) ya da `RichTextLabel` (bold başlıklar için). Metin çalışma anında birleştirilir: `Engine.get_license_text()`, `Engine.get_copyright_info()` (bileşen adı + telif + lisans kimliği), `Engine.get_license_info()` (lisans metinleri, tekilleştirilmiş), paketlenmiş `OFL.txt`'ler ve `LICENSE-lucide.txt` (`include_filter`). Uzun metin tek `Label`'da yavaşlarsa bölüm başına bir `Label`.
- **Godot logosu Jenerik'te tek renk** (`ink-3`, gözler pencere zemini): Godot basın kitinde tek renk varyantlar var; renkli logo yalnız 01b'de.
- **1536:** sütun 88, kilit S 76, kalem 56; plaka 0,8 ölçekte aynı pişirme. Arayüz ölçeği %125'te (1920 fiziksel) bu kare çizilen kare olur.

## Açık sorular (sahip)
1. Devam kartında "2 saat önce oynandı" mı, tarih-saat (02.10.2026 11:42) mı? Göreli biçim yeni yardımcı ister.
2. Jenerik rolleri ve adlar: beş satır taslak (Oyun tasarımı ve yapım, Programlama, Yazı, 3B ofis ve karakterler, Arayüz); müzik kaynağı (L3) çözülünce satır eklenir mi?
3. Telif satırındaki tüzel kişi / ad (DENETİM soru 9) ve sürüm biçimi ("Demo · Sürüm 0.4.0").
4. Quaternius (CC0) satırı: atıf zorunlu değil; şimdi yalnız Lisanslar'da duruyor. Jenerik'e "3B karakterler: Quaternius (CC0)" satırı istenir mi?
5. (Kapandı) Logo kilidi: kare solda, iki satır yazı sağda; açılış (01), menü, Jenerik ve onboarding şeridi aynı kilidi kullanır.
6. Godot kartı süresi (1,5 sn önerisi) ve atlanabilirlik.
7. Akşam plakası pişmiş mi kalsın, motorun gece çekiminden mi yeniden üretilsin (`--office-shot=city:20`)? İkincisi daha sadık, ama bu sette Godot koşulmadı.
8. Amblem sistemi onboarding setinde tasarlanıyor; buradaki U altıgen (dolu, `#5FA8A2`) ve PP daire (çizgi, `#D9825F`) o sistemin yer tutucu örnekleridir, palet ve şekil kümesi oradan bağlanmalı.
