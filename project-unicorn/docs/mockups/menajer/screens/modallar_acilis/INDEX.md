# Modallar, açılış ve son ekranı · A4 ekran maketleri (grup "modallar_acilis")

Ayarlar (beş bölüm, açılır listeler, kapalı ölçek satırları), sistem menüsü, kayıt/yükleme, onay (iki ve üç düğme),
açılış (dil kapısı, kurucu, köken ve beceriler, şirket, yükleme perdesi) ve son ekranı (gazete krem kalır, ray ve
düğmeler yeni dilde: demo, EA, iflas 1-3, kilometre taşı). Hepsi onaylı Menajer Masası diliyle, 1920×1080 mantıksal;
dördü ayrıca 1536×864'te (ölçek 1.25). Hepsi onay bekliyor. **r5:** 2026-10-02 eleştirisinin (`screens/_critique/
toplanti_modallar_acilis/`) bu gruba düşen S1 ve S2 maddeleri ve S3'lerin çoğu uygulandı; ne değiştiği her satırda
"r5" ile, açık kalanlar sorularda.

- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, A2 ikonları, kırpım kuralı, üst bar ızgarası.
  Sistemin eksiği `modallar.css`'te ("Yeni bileşenler"); sistem klasörüne hiçbir şey yazılmadı (kit kopyaları ve
  önbellekleri `tools/syskit/`'te, olaylar grubuyla aynı yol yamasıyla).
- Frank = aday A (`portraits/frank_cand_a.png`), yalnız son ekranının Frank şeridinde. Kurucular `portraits/founder_NN.png`
  (260×325 kart, sistemin 4:5 kırpımı). Yağlı boyalar yok.
- Marka: karar 14 (a) **bütün çerçevelerde**, olaylar grubuyla aynı sınıf ve renk (`.brand-sq`, `--brand-mark: #FFA028`):
  üst bar, dil kapısı ve açılış başlığı "turuncu kare + Project Unicorn". Oyuncunun logosu (a)'da yalnız şirket
  adımındaki kapı levhasında yaşar (r5: önizlemedeki (b) üst bar şeridi kalktı).
- **Kabuk (modalların altı) kabuk grubunun kendisidir (r5).** `tools/gen.py`, `screens/kabuk/tools/gen.py`'yi modül
  olarak yükler (`K`; `__pycache__` yazmadan) ve üst barı, rayı, şeridi, ofis plakasını, BuildHUD'u, bildirim yığınını,
  Ofisi taşı düğmesini ve toastı oradan çizer; sayfa `../../kabuk/kabuk.css`'i `modallar.css`'ten önce bağlar. Kopya
  yok, kayma yok: kabuk değişince bu grup yeniden üretilince aynısını çizer (kabuk derlenemezse bu derleme de kabuğun
  hatasıyla durur). Sonuç:
  - Plaka `art/office_safe_1920_noicons.png` + A2 kafa ikonları (koyu disk, krem glif; `office_safe_1920_heads.json`
    konumları); eski Lucide ikonlu plaka hiçbir çerçevede yok. 1536'da `office_safe_1536_noicons.png` + kafalar,
    (64, 64)'te 1472×760'a örtülü (soru 19).
  - BuildHUD tohumda Doğrulanmış 0: "Düzeltme başlat" kapalı, gerekçesi "Doğrulanmış hata yok." (`fix_run_refusal =
    no_confirmed_bugs`).
  - Bildirim yığını kabuğun tohum kutusu (`SEED_INBOX`): "Nordica · Bir ekip daha · 2 hafta", "Ege Sigorta · Risk
    altında", "Selin Kaya · Ayrılabilir"; karar beklerken de aynı (Frank'in teklifi hiçbir hatırlatıcıyla konu paylaşmaz).
  - Karar beklerken (kapılı her çerçeve): yuva "Cevap bekliyor · Frank Köseoğlu", saat kabuğun `GATE_CLOCK`'unda
    (08:00, kabuk soru 22), Olaylar'da amber nokta, **Ofisi taşı kapalı + "Cevap bekliyor"** (karar 5). Sistem menüsünün
    başlığındaki saat de 08:00.
  - Toast kabuğun tek toastı: ofisin ortasında (x 1052), şeridin 24 üstünde.
- Gerçek modal: perde `--scrim`, iki modal üst üste gelince iki perde (Godot'da her modalın kendi Dimmer'ı var); odak
  halkası yalnız en üstteki modalda.
- **Portreler yer tutucudur.** `portraits/founder_NN.png` ve Frank'in diski A3 çekimidir; karar 13'ün düzeltilecek
  dediği iki kusur hâlâ görünür: açık tenli yüzler `ink-2`'ye çok yakın (örnek #E2D4C4, `ink-2` #E9E4DA) ve
  founder_06'da (Elif) gözlük düz siyah çubuk. Düzeltilmiş Faz C çekimi (SPEC §3.5 pozlama kuralı) gelince kırpımlar
  aynı kuralla yeniden alınır; maket kırpımı değiştirmedi.
- Gazete metni `baseline/ending__*_gazete.png`'den (fikstür `main.gd _run_ending_shot`: PromptPilot, hafta 23, MRR $6,4K,
  3 çalışan) birebir yazıldı; EndingsCopy'nin bugünkü çıktısıdır.

Yeniden üretmek: `python tools/gen.py [ad ...]` (HTML'ler `build/`), `bash tools/render_par.sh <tur> [ad ...]` (dörtlü
paralel, `render_all.sh`'i çağırır; `_1536` ile biten çerçeve 1536 864 1.25 çizilir). PNG'ler bu klasöre, kopyası
`rounds/<tur>/`. Turlar: r1 (52 çerçeve, hepsi tam boy okundu: sınıf çakışması, ad hücresi taşması, kayıt künyesi
kesilmesi bulundu), r2 (düzeltmeler; ipucu popup'ın yanına, kayıt penceresi 760×660, odak yalnız en üst modalda), r3
(57 çerçeve: + 1536 ve EN, temas sayfaları ve 1:1 kırpımlar), r4 (popup açıkken Kapat odağı kalktı, EA rayı, boş liste
yüksekliği, EN gerekçe metni), r5 (eleştiri turu: kabuk modül olarak, 57 çerçevenin hepsi yeniden çizildi; değişen çerçeveler tam
boy ya da temas sayfasında, değişen bölgeler 1:1 ya da 2× okundu; F5 çerçevesinin kabuğun kapılı çerçevesiyle piksel
farkı yalnız kapı alt satırında). Kırpımlar ve temas
sayfaları `rounds/crops/` (r5'inkiler `r5_*`). `modallar.css` sistemin boşluk denetiminden (`system/tools/lint_spacing.py`,
bu dosyaya yöneltilerek) temiz geçer.

## Çerçeveler

Sütunlar: ne gösteriyor, veri kaynağı, yeni bileşen, yeni metin (EN / TR tam liste aşağıda), açık soru numarası.
"CSV" = `localization/strings.csv`; "yeni" = onay bekleyen yeni anahtar; "yeniden harf" = CSV değeri büyük harften
doğal yazıma iner, büyük harfi `Fmt.upper` verir (SPEC §1 kural 7).

### Ayarlar (SettingsModal, 640×820, perde üstünde)

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `ayarlar__ust.png` | Kaydırma başı: GÖRÜNTÜ (Pencere modu Kenarlıksız, Çözünürlük kapalı + gerekçe notu, Arayüz ölçeği %100, Dikey eşitleme açık), SES (Ana ses %100, müzik açık, Müzik %35, Efektler %70, odak kaybında sessiz açık), OYUN başı. Kapat odakta (bugünkü varsayılan odak). r5: yüzde sütunu sabit 48 px, kaydırıcıyla arası 20 (tutamak %100'de rayın 10 px dışına taşar; "%100" artık tutamağa yapışmıyor). | Baseline `modal__settings` değerleri; satırlar ve sıra `settings_modal.gd`; çözünürlük notu `SET_RESOLUTION_BORDERLESS`. | `.dlg-h/.dlg-body/.dlg-f`, `.set-sec/.set-row/.set-note`, `.vol` | | 7 |
| `ayarlar__alt.png` | Kaydırma sonu: SES sonu, OYUN (Her hafta, Her çeyrek, **Dil Türkçe**), ERİŞİLEBİLİRLİK (renk körü kapalı + not), VERİ (Kayıt klasörünü aç, Ayarları varsayılana döndür). İki çerçeve birlikte beş bölümün tamamı. r5: tek satırlık DİL bölümünün başlığı satır etiketini tekrarlıyordu ("Dil" / "Dil"); satır Oyun'a katıldı, `%LanguageHeader` emekli, satır etiketi `SETTINGS_LANGUAGE` kalır. | Aynı. | `.set-acts` | | 7, 16, 27 |
| `ayarlar__pencere_modu_acik.png` | Pencere modu açılır listesi: Tam ekran, Kenarlıksız (✓ şimdiki), Pencereli (üstünde kenar). | `DisplaySettings.MODE_ORDER/MODE_KEYS`. | `.pop` (seçimin altında, seçim genişliğinde PopupMenu) | | |
| `ayarlar__cozunurluk_acik.png` | Pencereli kipte Çözünürlük açık: 1280×720, 1366×768, 1600×900 (✓), 1680×1050, 1920×1080 (doğal). Kenarlıksız notu yok (pencerelide gizlenir). | `RESOLUTIONS` süzgeci 1920×1080 ekranda; pencereli varsayılan `default_resolution()`: görev çubuğu düşülmüş alana sığan en büyük 16:9 = 1600×900 (türetildi). | | | |
| `ayarlar__olcek_acik.png` | Arayüz ölçeği açık: %75 ve %90 kapalı, sağda kısa gerekçe "Burada okunmaz"; imleç %90'da (r5: üstünde kenarı var), tam ipucu popup'ın sağında, satırları örtmeden; %100 ✓, %110, %125 açık. r5: çerçeve kendi penceresini söyler: **Pencere modu Pencereli, Çözünürlük 1280 × 720**, kenarlıksız notu yok (1920×1080 kenarlıksız ekranda §8 her adımı açardı; eski çerçeve kendisiyle çelişiyordu). | Kural `display_settings.gd is_step_allowed` + SPEC §8 kapısı: çerçeve 1280×720 fiziksel pencereyi gösterir (mantıksal 1920×1080, germe 0,667): okunurluk tabanı 9 px'e göre %75 (12×0,75×0,667=6) ve %90 (7,2) kapalı; §8'in düzeltilmiş kapısında %110 ve %125 yasal. Türetildi. | `.menu-item.is-disabled .why` + `.tip` yan yana | `SET_UI_SCALE_BLOCKED_SHORT`; `SET_UI_SCALE_TOO_SMALL/LARGE` TR yüzde sırası düzeltmesi | 6 |
| `ayarlar__oto_kayit_acik.png` | Otomatik kayıt sıklığı açık: Kapalı, Her hafta (✓), Her ay. | `SaveManager.AUTOSAVE_FREQUENCIES`. | | | |
| `ayarlar__ozet_acik.png` | Özet sıklığı açık: Her hafta, Her ay, Her çeyrek (✓), Her yıl. | `SummarySystem.FREQUENCIES`. | | | |
| `ayarlar__dil_acik.png` | Dil açık (r5: satır Oyun bölümünde): "Türkçe" (✓), "English": her dil kendi adıyla. | `Localization.SUPPORTED`; adlar dil kapısıyla aynı kural. | | `LANG_TR`/`LANG_EN` değer değişikliği | 5 |
| `ayarlar__renk_koru_acik.png` | Renk körü paleti açık; bütün çerçeve `[data-palette=cb]`: üst barda Artıda mavi, ray rozetleri cıva turuncusu, bildirim noktası mavi. | `UiTokens.set_colorblind` + sistem CB paleti. | | | 7 |
| `ayarlar__sifirla_onay.png` | Ayarların üstünde onay: "Ayarlar sıfırlansın mı?", Vazgeç (odak) + tehlike "Sıfırla". İki perde, Ayarlar sönük. | `SET_RESET_CONFIRM_*`. | | | |
| `ayarlar__ust_en.png`, `ayarlar__alt_en.png` | Aynısı İngilizce (en uzun satır "Colourblind-friendly palette", "Reset settings to defaults"); taşma yok. | CSV EN. | | | |
| `ayarlar__ust_1536.png` | 1536×864 (ölçek 1.25): sıkışık üst bar (yalnız turuncu kare), ikon rayı, Ayarlar ortada 640×820 sığıyor (`ui_scale_ladder_fits_settings` ≤864). | r5: kabuğun `topbar(W=1536, compact=True)`, `rail(icons=True)`, `office1536()` ve yığını. | | | 19 |

### Sistem menüsü (Esc)

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `sistem__normal.png` | MENÜ başlığı + sağda tarih ve saat; Devam (tek birincil, odakta), Kaydet, Yükle, Ayarlar, Ana menüye dön kilitli + sağda "Yakında", Masaüstüne çık. r5: pencere SPEC §9'un 380'i (400'dü); "Masaüstüne çık" artık glifli: A2'de çıkış glifi olmadığı için aile kurallarıyla çizilmiş **taslak glif** (kapı %40 ton, çıkan ok dolu, 2,6 çizgi; `gen.py` `exit`), A2 sahibine öneri. | `system_menu_modal.gd`, `SYS_*`; tarih kabuğun tarih satırı. | `.sys-list` (kilitli satır gerekçesi düğmenin içinde sağda); taslak `exit` glifi | `SYS_SOON` yeniden harf | 4, 20 |
| `sistem__karar_bekliyor.png` | Karar beklerken (üst bar Cevap bekliyor · Frank Köseoğlu, saat 08:00'de tutulu, rayda amber nokta, Ofisi taşı kapalı): Kaydet kilitli, gerekçe "Karar beklerken kaydedilemez." Bu menüye karar etkinken ancak SPEC §6'nın 8. kuralı karar başına bir kez çalışırsa gelinir (soru 1, AD hükmü). | `SaveManager.cannot_save_reason_key()`; olaylar grubunun kapı alt satırı. | | `SAVE_ERR_DECISION_WAITING` | 1, 2 |
| `sistem__normal_en.png`, `sistem__karar_bekliyor_en.png` | İngilizce; kilitli Kaydet'in gerekçesi "Not while a decision is waiting." 380'lik pencerede (332 px düğme) etiketten 40 px aralı. r5: bu, anahtarın tek EN değeri; kabuğun F5 toastı da aynısını okur (`K.s("not_saved_sub")`), SPEC §13'ün uzun cümlesi bırakıldı (soru 2). | | | aynı anahtar | 2 |

### Kayıt / Yükle (SaveLoadModal, 760×660)

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `kayit__bos.png` | Kaydet kipi, hiç kayıt yok (pencere içeriğe göre kısalır, 420): "Yeni kayıt" yuvası (şimdiki koşunun künyesi + tek amber Kaydet), altında boş durum "Henüz kayıt yok." | `SAVE_NEW_SLOT`, `SAVE_EMPTY`; künye `_meta_line` biçimi (tohum). | `.slot.is-new`, `.sl-empty` | | 4 |
| `kayit__dolu.png` | Kaydet kipi, dört kayıt (yeni önce): Hızlı kayıt, Otomatik kayıt 1, Kayıt 1 (başka koşu, Series A), Kayıt 2 okunamıyor (uyarı kuyusu + gerekçe). Her satırda Sil (hayalet) + Üzerine yaz; zaman damgası başlık satırının sağında. Otomatik kayıt 1 üstünde. | Hızlı/otomatik: tohum hafta 14 değerleri (otomatik kayıt haftalık, tohumun değerleri sabit). Kayıt 1: bitiş fikstürü (hafta 23, $24.000, $6,4K, evre 3). Kayıt 2: `SAVE_ERR_TOO_OLD` (`MIN_LOADABLE_VERSION` kuralı). Gerçek saat damgaları bugünden (02.10.2026) türetildi, `SAVE_SLOT_TIMESTAMP` biçimi. | `.slot.is-bad`, `.sl-sec` | `SAVE_LIST_HEADER` | 4, 17 |
| `kayit__karar_bekliyor.png` | Seçenek B: Kaydet karar beklerken açılırsa: üstte şerit (amber nokta + "Karar beklerken kaydedilemez." + **"Frank Köseoğlu · Teklif"** + Karara dön), Kaydet ve Üzerine yaz kapalı; Sil ve liste okunur. r5: şerit olaylar grubunun `win-ro` şeridi gibi bekleyen mailin gönderen · konusunu taşır, "Karara dön" hangi maile döndüğünü söyler. | Olaylar şeridiyle aynı dil (`ekip__salt_okunur_karar_bekliyor`). | `.sys-gate` (+ `.from`) | `SAVE_ERR_DECISION_WAITING`; "Karara dön" (SPEC §13) | 2 |
| `kayit__f5_reddedildi.png` | Karar beklerken F5: kabuk kapılı, pencere yok, tek toast "Kaydedilmedi · Karar beklerken kaydedilemez." r5: kabuğun toastı ve yeri (ofisin ortası x 1052, şeridin 24 üstü), kayıt glifi `warn` renginde (`.toast.warn`), kafa ikonları A2. Kabuğun `ustbar__karar_bekliyor_3`'üyle piksel farkı yalnız kapı alt satırında. | SPEC §6 F5. | | aynı | |
| `yukle__bos.png` | Yükle kipi boş (340 yükseklik): yükleme glifi + "Henüz kayıt yok." | `SAVE_EMPTY`. | | | |
| `yukle__dolu.png` | Yükle kipi dolu: aynı dört kayıt, Sil + Yükle; okunamayan kayıtta Yükle kapalı, gerekçe künyede. Kayıt 1 üstünde. | Aynı. | | | |
| `yukle__sil_onay.png` | Yükle'nin üstünde silme onayı: "Kayıt silinsin mi?" / "Kayıt 1 geri getirilemez.", Vazgeç (odak) + tehlike Sil. | `SAVE_DELETE_*`. | | | |

### Onay

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `onay__iki_dugme.png` | İki düğme, birincil: "Turu bu fonla açmak", Vazgeç (odak, güvenli taraf) + amber Otur. | Gerçek çağıran `hunt_tab._confirm_seed_pitch`, `SEED_PITCH_CONFIRM_*`; fon adı Meridian Growth (sistem sayfası 13). Baseline'daki "Geliştirmeyi iptal et?" debug tohumu artık olmayan bir motora ait, kullanılmadı. | | | |
| (tehlike örnekleri) | `ayarlar__sifirla_onay.png` ve `yukle__sil_onay.png`: yıkıcı onayda amber yok, tehlike düğmesi. | | | | |
| `onay__uc_dugme.png` | Sistem menüsünün üstünde çıkış: "Kaydedilmemiş ilerleme var.", solda hayalet Vazgeç (odak), sağda **tehlike Çık** + amber Kaydet ve çık. r5: pencere 520 (SPEC §9 Onay 440-520; 540'tı). Çık son kayıttan beri oynananı siler: yıkıcı onay tehlike düğmesidir (SPEC §11 `ConfirmModal`), iki durumda da. | `system_menu_modal._on_quit`, `SYS_QUIT_*`. | | | 4, 26 |
| `onay__uc_dugme_karar_bekliyor.png` | Aynısı karar beklerken: Kaydet ve çık kilitli, gerekçe altında; birincil yok, tehlike Çık tek yol. | Bugünkü kod burada kaydetmeden çıkar (`_save_and_quit`), bkz. soru 3. | `.modal-f .locked-btn` | `SAVE_ERR_DECISION_WAITING` | 3 |
| `onay__uc_dugme_en.png` | İngilizce: "Save and quit" 520'de sığıyor. | | | | |

### Açılış

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `acilis__dil_kapisi.png` | Turuncu kare + Project Unicorn; iki eş seçenek (amber yok), işletim sistemi dili Türkçe odakta. | `language_gate.gd` (iki yaprak kendi dilinde, onaylı tek literal). | `.brand.lg`, `.gate-c` | alt satırlar "Oyuna Türkçe başla" / "Start the game in English" (literal, sistem sayfası 13) | |
| `acilis__dil_kapisi_ustunde.png` | Aynısı, fare English üstünde (kenar). | | | | |
| `acilis__kurucu.png` | Adım 1 varsayılan: 11 kurucu 260×325 kartta, 6+5 ve on ikinci hücrede ad alanı; founder_01 ön seçili (bugünkü prefill), ad boş ("Kurucu" yedek adı kartın altında ve önizlemede). Geri kapalı, İleri açık. | `character_step.gd`, `FounderConstants.PORTRAIT_IDS`; portreler `portraits/founder_NN.png`. | `.onb-head` + `.steps` (numaralı adım), `.onb-foot`, `.pgrid`, `.name-cell` | adım adları ve sayaç yeniden harf | 12 |
| `acilis__kurucu_dolu.png` | founder_05 seçili, ad "Deniz" yazılıyor (odak, 5/40), founder_02 üstünde; ad hücresinde 48 px disk önizleme. | Ad bitiş fikstüründen (Deniz). | | | |
| `acilis__kurucu_dolu_1536.png` | 1536×864: beş sütun, gövde başlık ile alt bar arasında kayar; ad alanı başlık satırına çıkar. r5: 48 px disk önizlemesi alanın solunda kalır (1920'deki ad hücresiyle aynı bilgi). | | `.onb-scroll` | | 18 |
| `acilis__koken.png` | Adım 2 boş: hiçbir köken seçili değil, Sıfırdan seçilebilir; Mirasyedi ve Kurumsal Firari kilitli (kilit + TAM SÜRÜMDE / ÇOK YAKINDA, tam mürekkep); huylar 0/2 0/1, Vizyoner üstünde; beceriler 0, kalan puan 6. İleri kilitli, solunda "Bir köken seç." r5: huy bölümünün adı **HUYLAR** (KARAKTER 1. adımın adıydı; Ekip penceresi de "Huy" der); beceri kartında tek sayı: stepper puanı (Kalan puan ile aynı birim), seviye 10 çentikli cetvelde okunur ("4/10" kalktı). | `origin_traits_step.gd`, `FounderConstants` (POINT_POOL 6, cap 3, cetvel ×2, huy formülü). Köken adları 2026-08-08 yerelleştirme hükmünden (Sıfırdan / Mirasyedi / Kurumsal Firari), CSV'nin TR sütunu hâlâ İngilizce. | `.ogrid`, `.tgrid/.tcol/.trow`, `.sgrid/.sstep .ctl/.pts` | gerekçe satırları (yeni) | 13 |
| `acilis__koken_negatif_eksik.png` | İki pozitif, negatif yok, puanlar bitti: pozitif sütunu dolu (öteki iki satır soluk), İleri kilitli "İki pozitif bir negatif ister." | `validate_traits` kuralı. | | | |
| `acilis__koken_dolu.png` | Sıfırdan + Vizyoner, Disiplinli, İnatçı; puanlar Ürün 2, Yazılım 1, Satış 2, Karizma 1 (cetvelde 4, 2... çentik), kalan 0 "Hepsi dağıtıldı"; + düğmeleri kapalı. İleri açık. | Dağılım örnek (kurala uygun). | | `ONB_POINTS_DONE` | |
| `acilis__koken_dolu_en.png` | Aynısı İngilizce; "Customer Success", "Corporate Refugee" sığıyor. | | | | |
| `acilis__koken_dolu_1536.png` | 1536×864: gövde kayar (sona kaydırılmış), beceriler 4×2 ızgaraya, kalan puan iki satırı kaplar. | | | | 18 |
| `acilis__sirket.png` | Adım 3 boş: ad yok, logo yok; dört logo kartı "?" harfiyle; önizlemede kesik kenarlı boş levha "?" ve "[Şirket adı]". "Kur ve başla" kilitli, "Şirketine bir ad ver." | `company_step.gd`, `LogoEmblem`, `ONB_COMPANY_EMPTY`. | `.lp/.lp-card`, `.emb` (LogoEmblem), `.pv/.pv-card/.plinth` | gerekçe (yeni) | 14 |
| `acilis__sirket_dolu.png` | "Unicorn Inc." yazılıyor (12/40), Oyuncul seçili (eski turuncu kareye en yakın stil), Tekno üstünde; önizleme yalnız kapı levhası: logo 96 mürekkep çizgili kaidede (`surface-1`, `line-3`), ad, kurucu diski + "Kurucu · 2026". r5: (b)'nin üst bar şeridi kalktı (karar 14 (a): üst barda oyunun markası durur, oyuncunun logosu kapıdadır); logo kartlarındaki amblem 32 (40'tı), 96'lık amblem kaide üstünde: turuncu dolgu kontrol gibi değil levha gibi okunur, amber "Kur ve başla" tek birincil kalır. | Tohum şirketi; kurucu founder_05/Deniz önceki adımdan. | | | 13, 14 |
| `acilis__sirket_dolu_en.png` | İngilizce. | | | | |
| `acilis__yukleniyor.png` | Yükleme perdesi: şirket logosu 64 + Unicorn Inc. + "Hazırlanıyor…" + ince belirsiz çubuk. | `onboarding_flow._commit` (1 s bekleme, gerçek ilerleme yok). | `.curtain` içi düzen | | 15 |

### Son ekranı (gazete krem, ray yeni dilde)

Ray her sonda: başlık = sonun adı (`END_META_*_TITLE`, bugün yükte var ama ekranda yok), altında "Bu oyun: N hafta ·
Normal mod". Demo: "Sırada ne var?" + iki kilometre taşı belgesi (kesik köşe, kilit, etiket) + tek amber "Wishlist'e
ekle"; **hemen altında** çizgiyle ayrılmış eylem satırı: Tekrar dene, kilitli "Zor mod · Yakında", Gazeteyi paylaş
(r5: eylemler rayın dibindeydi, ortada 450 px boşluk kalıyordu; ray artık yukarıdan aşağı tek okunur). Belgenin üst
satırı yalnız tür: "Kilometre taşı" (r5: "Kilometre taşı · Series B" altındaki başlığı tekrarlıyordu). Frank'in şeridi
(yalnız demo) gazetenin altında, paylaşılan görüntünün dışında: aday A 48 px disk + Source Serif 4 söz + ad + MENTOR
rozeti. **Tireden arındırılmış Frank satırları TASLAK'tır** (CLAUDE §3: yeni Frank satırı onaysız ekrana çıkmaz):
şerit kesik çizgiyle çevrili, ad satırının sağında "TASLAK · {anahtar} · onay bekliyor" (maket notu, oyun öğesi değil;
olaylar grubunun `olaylar__taslak_*` geleneği); işaret sözün sarılmasını değiştirmez.

| PNG | Gösterdiği | Veri kaynağı | Yeni metin | Soru |
|---|---|---|---|---|
| `son__series_a_demo.png` | Series A Kapandı (demo). Frank şeridi TASLAK (`END_META_SERIES_A_CLOSE_FRANK`). | baseline `ending__series_a_close_demo` | Frank satırı tire düzeltmesi (taslak) | 8, 10, 11 |
| `son__series_a_agresif_demo.png` | Agresif şartlar ($7,0M, %68, iki koltuk, veto). Frank şeridi TASLAK. | `ending__series_a_agg_demo` | aynı | 10 |
| `son__satis_demo.png` | Şirket Satıldı. | `ending__acquisition_demo` | | 21 |
| `son__marka_coktu_demo.png` | Marka Çöktü. | `ending__brand_collapse_demo` | | |
| `son__vc_ret_demo.png` | Üç Masa, Üç Ret. | `ending__vc_rejection_cascade_demo` | | |
| `son__ilgi_sondu_demo.png` | İlgi Söndü (hafta 104, Aralık 2027, sayı 104). | `ending__running_on_fumes_demo` | | |
| `son__kendi_paranla_demo.png` | Kendi Paranla demo sonu. | `ending__profitable_bootstrap_demo` | | |
| `son__iflas_1_demo.png` | İflas evre 1: gazete oyuncuyu manşete koymaz (genel haber + "Kısa Kısa" köşesi), ray aynı. Frank şeridi TASLAK (`END_META_BANKRUPTCY_FRANK`). | `ending__bankruptcy1` | Frank satırı tire düzeltmesi (taslak) | 10 |
| `son__iflas_2_demo.png` | İflas evre 2: "Umut Veren Çıkış Yarıda Kaldı". Frank şeridi TASLAK. | `ending__bankruptcy2` | aynı | 10 |
| `son__iflas_3_demo.png` | İflas evre 3: "Series A Kapısındaki ... Kepenk İndirdi". Frank şeridi TASLAK. | `ending__bankruptcy3` | aynı | 10 |
| `son__series_a_ea.png` | EA/tam sürüm sonu: Frank konuşmaz, Sırada ne var ve mağaza düğmesi yok. r5: Tekrar dene tek birincil, tam genişlik büyük düğme olarak künyenin altında (kilometre taşı rayındaki Devam et gibi); altında çizgiyle Zor mod · Yakında ve Gazeteyi paylaş. Rayın altı boş kalır (soru 22). | `ending_scene._build_rail` (`_demo` false) | | 9, 22 |
| `son__kilometre_tasi_ea.png` | Kilometre taşı (EA): KİLOMETRE TAŞI + Kendi Paranla + "Bu bir son değil..." + amber Devam et (odak); altta Ana menü. Künye yok (koşunun toplamı yok). | `_build_milestone_rail`, `ending__bootstrap_milestone(_ea)` | | |
| `son__kilometre_tasi_ea_kayit_engelli.png` | Ana menü kaydı tutamadığında: Devam et altında uyarı satırı "Karar beklerken kaydedilemez." | `main.gd _on_milestone_main_menu` → `show_notice` | `SAVE_ERR_DECISION_WAITING` | |
| `son__paylasildi_demo.png` | Gazeteyi paylaş sonrası: eylem satırının altında tek toast (onay glifi, "Gazete kaydedildi", dosya adı) ve **toastın içinde hayalet "Klasörü aç"**; imleç üstündeyken toast bekler (çerçeve düğmeyi üstünde çizer). Frank şeridi TASLAK. r5: düğme 2,4 s'lik toastın dışında başıboş duruyordu ve dosya adı kesiliyordu; ad önerisi `gazete_20261002-1142.png` (sonun kimliği ve saniye düşer) tam sığar. | `_on_share`; bugünkü ad `gazete_<ending_id>_<YYYYMMDD-HHMMSS>.png` (`_export_paper_png`), öneri soru 23. | `ENDING_SAVED_HEAD` (başlık/alt ayrımı), toast içi eylem (`.er-toast .btn`) | 23 |
| `son__series_a_demo_1536.png` | 1536×864: ray 520, kenar boşlukları 24; gazete kendi merdiveniyle sığıyor, gravür alanı küçülür. Frank şeridi TASLAK; söz tek satırda kalır. | | | 18 |

## Yeni bileşenler (`modallar.css`, sistem grameriyle)

Kabuğun parçaları (üst bar, ray, şerit, ofis plakası ve kafa ikonları, BuildHUD, yığın, Ofisi taşı, toast) bu grubun
bileşeni değildir: `screens/kabuk/tools/gen.py` ve `kabuk.css`'ten gelir, tarifleri kabuğun INDEX'inde.

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.brand`, `.brand.lg`, `.brand-sq` + `--brand-mark` | Turuncu kare + "Project Unicorn" yazı markası (dil kapısı, açılış başlığı, üst bar) | `LogoEmblem` sabit kipi; `D_BRAND_MARK` sahne sabiti, UI token'ı değil |
| `.emb.<stil>` | LogoEmblem: minimalist halka, tekno altıgen, oyuncul yuvarlak dolgu, ciddi kare; harf Barlow 700; turuncu = `--brand-mark`, krem = `ink-2`, koyu = `surface-1`. Harf kontrastı: turuncu üstünde `surface-1` 9,2:1, `surface-3` üstünde turuncu 8,4:1, krem üstünde `surface-1` 14,7:1 | `logo_emblem.gd _draw` renkleri |
| `.dlg-h`, `.dlg-body`, `.dlg-f` | Büyük diyalog çerçevesi: 72 px başlık (t-h1), kayan gövde, `surface-2` alt şerit | `WindowFrame` modal kipi (`frame_options`) |
| `.set-sec`, `.set-row`, `.set-note`, `.set-acts`, `.vol` | Ayar bölüm başlığı (çizgili), 48 px satır (etiket + 260 px kontrol), gerekçe notu (bilgi glifi), veri düğmeleri, kaydırıcı 192 + 20 aralık + sabit 48 px yüzde sütunu | `settings_modal._add_row`, `_note_label` |
| `.pop` | Açılır liste: seçimin altında, seçim genişliğinde `.menu`; ✓ şimdiki, üstündeki öğe kenarlı (kapalı öğe de), kapalı öğede sağda kısa gerekçe, uzun gerekçe ipucu olarak popup'ın sağında | `OptionButton` PopupMenu (`set_item_disabled`, `set_item_tooltip`) |
| `.sys-list` | Sistem menüsü (380): tam genişlik düğmeler, ikon sütunu hizalı; kilitli satırın gerekçesi düğmenin içinde sağda (`ink-3`); "Masaüstüne çık" taslak `exit` glifiyle | `system_menu_modal` VBox |
| `.sys-gate` (+ `.from`) | Diyalog içinde karar şeridi (olaylar `win-ro` dili): gerekçe, bekleyen mailin gönderen · konusu (`ink-3`), Karara dön | aynı şerit bileşeni |
| `.slot.is-new`, `.slot.is-bad`, `.sl-sec`, `.sl-empty` | Yeni kayıt yuvası (kesik kenar), okunamayan kayıt (uyarı kuyusu), liste başlığı, boş durum | `save_load_modal._build_row` |
| `.modal-f .locked-btn` | Kilitli düğme + altında gerekçe (onay içinde) | düğme + Label |
| `.onb-head`, `.steps/.st`, `.onb-title`, `.onb-foot` (+ `.why`), `.onb-k`, `.onb-scroll` | Açılış başlığı (marka + numaralı adımlar: bitti ✓, şimdiki 2 px mürekkep halka, sıradaki soluk), sayfa başlığı, alt şerit (sayaç, kilitli birincil yanında gerekçe), bölüm etiketi, 1536'da kayan gövde | `onboarding_flow._build_header`, Footer |
| `.gate-c` | Dil kapısı düzeni | `language_gate.gd` |
| `.pgrid`, `.pcard .cap`, `.name-cell` | 6×2 kurucu ızgarası (1536'da 5 sütun, ad alanı + 48 px disk başlık satırında), seçili kartın altında ad, ad hücresi (alan + yardım satırı + 48 px disk önizleme) | `character_step` GridContainer |
| `.ocard` eklentileri, `.tgrid/.tcol/.trow`, `.sgrid`, `.sstep .ctl`, `.pts` | Köken kartında kilit + etiket ya da ✓; huy listesi (onay kutusu, ad + etki, sayaç; tavan dolunca kalanlar soluk); beceri adımı (açıklama, 10 çentik cetvel, puan stepper'ı); kalan puan | `origin_traits_step` |
| `.lp`, `.lp-card`, `.pv`, `.pv-card`, `.plinth` (+ `.is-empty`) | Logo stili kartları (amblem 32); önizleme: kapı levhası, 96'lık amblem mürekkep çizgili kaidede (`surface-1`, `line-3`; boşken kesik kenar) | `company_step` |
| `.curtain` içi (`.brand`, belirsiz çubuk) | Yükleme perdesi | `LoadingOverlay` |
| `.end`, `.end-paper-col`, `.end-rail`, `.er-*`, `.tier`, `.frank-strip` | Son ekranı: koyu ray (`surface-1`), başlık, künye, kilometre taşı belgeleri, birincilin altında çizgili eylem satırı (`.er-cta + .er-acts`), içinde eylemi olan toast (`.er-toast`), uyarı satırı; Frank şeridi | `ending_scene` |
| `.frank-strip.is-draft`, `.draft-k` | **Maket notu, oyun öğesi değil:** onay bekleyen Frank satırının kesik çerçevesi ve "TASLAK · {anahtar}" işareti | yok |
| `.paper`, `.pp-*` | Gazete adası, SPEC §12 boyları: manşet 600/52, başlık 600/32, spot italik 16, gövde 15, rakam 600/44, alt yazı italik 12; künye ve etiketler Plex Sans Condensed 12 büyük harf +1 | `PaperPanel` ve `News*` varyasyonları |

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

SPEC §13'te zaten önerilenler, olaylar grubunun ve kabuğun listesi tekrar edilmedi ("Karara dön", "Devam et", marka
adı, "Doğrulanmış hata yok.", "Kaydedilmedi"). `SAVE_ERR_DECISION_WAITING` bu grubun ve kabuğun ortak satırıdır;
birleşik onay listesine bir kez girer.

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `SAVE_ERR_DECISION_WAITING` (SPEC §13'ün önerisi, EN kısaltıldı; **tek değer**) | Not while a decision is waiting. | Karar beklerken kaydedilemez. | sistem menüsü, onay, kayıt şeridi, F5 toastı (kabuk `toast__durumlar` aynı değer), kilometre taşı uyarısı; `SAVE_ERR_MODAL_OPEN` bunun için kullanılmaz. SPEC §13'ün "Saving is unavailable while a decision is waiting." cümlesinin yerine (352 px düğmede etiketle çakışıyordu) |
| `SAVE_LIST_HEADER` | Saves | Kayıtlar | Kaydet kipinde liste başlığı |
| `SET_UI_SCALE_BLOCKED_SHORT` | Unreadable here | Burada okunmaz | ölçek listesinde kapalı satır |
| `SET_UI_SCALE_TOO_SMALL` (TR düzeltme) | {pct}% is unreadable at this window size; it needs a wider display. | %{pct} bu pencere boyutunda okunmuyor; daha geniş bir ekran gerekiyor. | ipucu; TR'de yüzde işareti başa (bugün "{pct}%") |
| `SET_UI_SCALE_TOO_LARGE` (TR düzeltme) | (aynı) | %{pct} bu pencere boyutunda arayüzü kırpar; daha büyük bir ekran gerekiyor. | aynı hata |
| `LANG_TR` / `LANG_EN` (değer) | Türkçe / English | Türkçe / English | dil listesi, her dil kendi adıyla |
| `ONB_TRAITS_HEADER` (değer) | Traits | Huylar | köken adımında huy bölümü (bugün KARAKTER / CHARACTER, 1. adımın adı) |
| `ENDING_SAVED_HEAD` + `ENDING_SAVED_TOAST` (ikiye bölünür) | Paper saved · {file} | Gazete kaydedildi · {file} | paylaşım toastı (tam yol yerine dosya adı); toastın içinde `ENDING_OPEN_FOLDER` |
| `ENDING_WISHLIST` (TR onayı) | Add to wishlist | Wishlist'e ekle (bugünkü) · öneri: İstek listesine ekle | "Wishlist" izinli ödünç kelime değil (CLAUDE §5); çerçeve bugünkü değeri çizer, soru 24 |
| `ONB_POINTS_DONE` | All spent | Hepsi dağıtıldı | kalan puan 0 |
| `ONB_WHY_ORIGIN` | Choose an origin. | Bir köken seç. | İleri kilitliyken |
| `ONB_WHY_TRAIT` | Pick at least one strength. | En az bir pozitif seç. | (çerçevede yok, aynı yuva) |
| `ONB_WHY_FLAW` | Two strengths owe a flaw. | İki pozitif bir negatif ister. | |
| `ONB_WHY_POINTS` | Spend {n} more points. | {n} puan daha dağıt. | (çerçevede yok) |
| `ONB_WHY_NAME` | Give your company a name. | Şirketine bir ad ver. | Kur ve başla kilitliyken |
| `ONB_WHY_LOGO` | Choose a logo style. | Bir logo stili seç. | (çerçevede yok) |
| dil kapısı alt satırları (literal, kendi dilinde) | Start the game in English | Oyuna Türkçe başla | dil kapısı |
| köken adları (2026-08-08 hükmü, CSV'ye işlenmemiş) | Self-Made / The Heir / Corporate Refugee | Sıfırdan / Mirasyedi / Kurumsal Firari | köken kartları |
| Frank satırı, tire (Erdem'in külliyatı; **taslak**, ekranda TASLAK) | You signed. Now the real work starts. But that is another game's subject. | İmzaladın. Şimdi asıl iş başlıyor. Ama o başka bir oyunun konusu. | `END_META_SERIES_A_CLOSE_FRANK` |
| Frank satırı, tire (**taslak**, ekranda TASLAK) | You stayed in the red for {days} days. Numbers are not cruel; only patient. | {days} gün kırmızıda kaldın. Rakamlar kaba değildir; sadece sabırlıdır. | `END_META_BANKRUPTCY_FRANK` |

**Yeniden harf** (CSV değeri doğal yazıma iner; etiketler `Fmt.upper` ile büyük, düğmeler ve cümleler cümle düzeni):
`ONB_STEP_CHARACTER/ORIGIN/COMPANY` (Karakter, Köken, Şirket), `ONB_STEP_COUNTER` (Adım {step} / {total} · Step),
`ONB_START` (Kur ve başla · Found and begin), `ONB_NAME_LABEL` (Adın), `ONB_TRAITS_POSITIVE/NEGATIVE` (Pozitif, Negatif),
`ONB_POINTS_LEFT` (Kalan puan), `ONB_COMPANY_LABEL` (Şirket adı), `ONB_LOGO_LABEL` (Logo stili), `ONB_SLOGAN_LABEL`
(Slogan (opsiyonel)), `ONB_PREVIEW_LABEL` (Önizleme), `ONB_PREVIEW_FOUNDER_TAG` (Kurucu · {year}), `LOGO_STYLE_*`
(Minimalist, Tekno, Oyuncul, Ciddi), `ONB_ORIGIN_SM_CHIP_*` (Dayanıklı, Düşük sermaye, Basın sempatisi), `LOCK_FULL` /
`LOCK_SOON` (Tam sürümde, Çok yakında), `TRAIT_*_NAME` TR (Ağ kurucu, Mikro yönetici, Risk körü, Yalnız kurt), `SYS_SOON`
(Yakında · Soon), `ENDING_NEXT` (Sırada ne var? · What's next?), `ENDING_BADGE_EA` (Erken Erişim'de), `ENDING_WISHLIST`
(Wishlist'e ekle · Add to wishlist; TR değeri soru 24), `ENDING_RUN_META(_ONE)` (Bu oyun: {weeks} hafta · Normal mod ·
This run: {weeks} weeks · Normal mode), `ENDING_RETRY` (Tekrar dene · Try again), `ENDING_HARD_MODE` (Zor mod · Hard mode;
"Yakında" gerekçe olarak ayrılır, `ENDING_SOON_TOOLTIP` değeri), `ENDING_SHARE` (Gazeteyi paylaş · Share the paper),
`ENDING_OPEN_FOLDER` (Klasörü aç · Open folder), `ENDING_MAIN_MENU` (Ana menü · Main menu), `ENDING_MILESTONE_HEAD`
(Kilometre taşı · Milestone; kilometre taşı rayının başı ve demo belgelerinin üst satırı), `END_LEDGER_TITLE` (şirket
adı büyütülmez: "RAKAMLARLA PromptPilot", SPEC §12).

**Emekli olacak anahtarlar ve düğümler** (bu tasarımda okunmuyor): `ONB_PORTRAIT_HEADER`, `ONB_SELECTED_CHIP`,
`ONB_FOUNDER_TAG` (seçim kenarla ve adla okunur), `ENDING_FRANK_TAG` (ad + MENTOR rozeti), `LOCK_CHIP`,
`ENDING_CARD_SERIESB_TAG` ve `ENDING_CARD_IPO_TAG` (belgenin üst satırı `ENDING_MILESTONE_HEAD`, başlık kartın
`*_TITLE`'ı), Ayarlar'ın `%LanguageHeader` düğümü (Dil satırı Oyun bölümünde; etiket `SETTINGS_LANGUAGE` kalır).

## Açık sorular (Erdem)

1. **Sistem menüsüne karar beklerken nasıl gelinir?** AD hükmü (r5): SPEC §6'nın 8. kuralı karar başına bir kez çalışır;
   sonra Esc sistem menüsünü açar. Bu grup sistem klasörüne yazmaz; SPEC §6 için önerilen metin (sistem sahibine):
   "8. No window and a decision is active **that Esc has not reopened yet**: reopen Olaylar with the card selected
   (once per decision). 9. No window, and nothing active **or rule 8 already ran for the active decision**: system
   menu." `sistem__karar_bekliyor` bu yolun çerçevesidir.
2. **Kayıt engeli nerede okunur?** A (önerilen): menüde Kaydet kilitli, gerekçe yanında (`sistem__karar_bekliyor`).
   B: Kaydet açık kalır, kayıt penceresi şeritle açıklar, yükleme ve silme yine çalışır (`kayit__karar_bekliyor`).
   Gerekçe her yerde tek anahtar, tek değer (kabukla aynı).
3. **Karar beklerken "Kaydet ve çık" bugün kaydetmeden çıkıyor** (`system_menu_modal._save_and_quit`). Çerçevede kilitli;
   onaylanırsa davranış da değişir.
4. **Pencere ölçüleri ve SPEC §9.** r5'te Sistem 380 (§9: 380×430) ve üç düğmeli Onay 520 (§9: 440-520) sınıra çekildi.
   **Kayıt/Yükle 760×660 kalır** (§9: 660×580); ölçülen gerekçe: 660'ta künye satırı ("Hafta 14 · Nisan 2026 ·
   Bootstrap · Kasa $10.000 · MRR $4,0K") Sil + Üzerine yaz'ın yanında kesiliyor (r1'de görüldü) ve 580'de yeni yuva
   + dört kayıt kaydırma istiyor; 760×660 1536×864'e (alan 1424×712) sığar. Önerilen §9 satırı: "Kayıt 760×660 (künye
   satırı ve dört kayıt kaydırmasız)". §9'u değiştirmek sistem sahibinin işi.
5. **Dil listesi**: her dil kendi adıyla ("Türkçe", "English"), dil kapısıyla aynı kural; bugün TR arayüzde "İngilizce".
6. **Ölçek kapısı**: §8'in kapısıyla ladder'daki hiçbir adım "arayüzü kırpar" gerekçesine düşmüyor (en büyük adım %125 =
   1536×864); yalnız okunurluk tabanı kalıyor. Okunurluk tabanı yeni en küçük adıma (12 px) bağlanırsa 1920×1080'de hiçbir
   satır kapanmaz. Çerçeve artık 1280×720 pencereli kipi kendi satırlarında da gösterir. Kısa gerekçe "Burada okunmaz"
   uygun mu?
7. **Renk körü notu** ("Olumlu ve olumsuz renk çifti maviye ve turuncuya döner.") yeni palette uyarıyı açık sarıya,
   beceri 7-10'u maviye de çeviriyor; not genişlesin mi?
8. **Ray başlığı** sonun adı (`END_META_*_TITLE`, yükte var, bugün görünmüyor). Kalsın mı?
9. **EA sonunda** mağaza düğmesi olmadığı için "Tekrar dene" tek birincil, tam genişlik (kilometre taşı rayının Devam
   et'i gibi). Uygun mu?
10. **Frank'in iki satırında tire** (Series A ve iflas). Öneriler çerçevelerde TASLAK işaretiyle; satırlar senin
    külliyatın, onaylanana kadar ekrana çıkmaz.
11. **Gazete künyesi** "RAKAMLARLA PromptPilot": etiket büyük, şirket adı olduğu gibi (SPEC §12). Karışık durum kabul mü?
12. **Kurucu kartında numara yok**; seçim 2 px mürekkep kenar + kartın altında ad. Ad hücresi ızgaranın on ikinci yerinde.
13. **Köken adları** TR'de hükümle yerelleşti ama CSV hâlâ İngilizce; ayrıca kurucu huyu adları cümle düzenine iniyor
    (Ağ kurucu, Mikro yönetici...). Sayfa başlığı "Köken ve Karakter" (`ONB_P2_TITLE`) hâlâ 1. adımın adını taşıyor;
    bölüm "Huylar" oldu, başlık değişmedi (TR metni onaysız değişmez).
14. **Turuncu marka işareti amberin yanında**: r5 ile şirket adımında logo kartlarındaki amblem 32'ye indi ve 96'lık
    amblem mürekkep çizgili kaidede levha olarak okunur; perdede logo 64 yine "Kur ve başla"dan sonra tek başına. Logo
    turuncusu (#FFA028) marka sabiti olarak muaf mı? (b) bir gün seçilirse üst barın 184 px sütununda ad 108 px'te
    kısalır (40 harf tavanı); bu soru kabuğun varyant sayfasına taşındı.
15. **Yükleme perdesi** belirsiz çubuk (gerçek ilerleme yok, 1 s bekleme + kabuk kurulumu). Çubuk hiç olmasın mı?
16. **Haber şeridi aç/kapa** oyuncu ayarı (SPEC §10) Ayarlar'da satır değil; Görüntü'ye "Haber şeridi" satırı eklensin mi?
    (çerçeve yok, yeni ekran icat edilmedi)
17. **Kayıt künyesinde evre** bugün koddaki İngilizce sabitten (`phase_display_name`: "Series A Hunt"); çerçeve
    `FIN_PHASE_*` ("Series A") okur.
18. **1536'da açılış gövdesi kayar** (kurucu 5 sütun, köken sayfası yaklaşık 1000 px); alt şerit ve başlık sabit.
19. **1536 plakası** kabuğun `office_safe_1536_noicons.png`'si (184 px ray için çekilmiş, 1352×760); 1536'da ray ikon
    kipinde (64), plaka 1472×760'a örtülü. Yeniden çekim kabuk grubunun işi.
20. **"Masaüstüne çık" glifi**: A2'de çıkış glifi yok; r5 aile kurallarıyla bir taslak çizdi (`gen.py` `exit`: kapı %40
    ton, çıkan ok dolu). A2 sahibi benimser mi, yeniden mi çizer?
21. **Gazete fikstüründe** composer tuhaflıkları (B2B koşuda "0 ÖDEYEN" / "0 KİTLE", satışta "Satış bedeli $147,8K" ile
    "1 milyon dolar değerleme"). Maket metne dokunmadı.
22. **EA son rayının altı boş** (eylemlerin altında yaklaşık 800 px): Sırada ne var ve mağaza düğmesi olmayınca ray kısa.
    Kabul mü, yoksa EA'da blok dikey ortalansın ya da ray daralsın mı?
23. **Paylaşım dosya adı**: bugün `gazete_<ending_id>_<YYYYMMDD-HHMMSS>.png`; toastta kesiliyordu. Öneri
    `gazete_<YYYYMMDD-HHMM>.png` (`ending_scene._export_paper_png`; aynı dakikada ikinci paylaşım aynı gazeteyi yeniden
    yazar). Ya da ad kalır ve toast yalnız "Gazete kaydedildi" + "Klasörü aç" der.
24. **"Wishlist'e ekle"**: "Wishlist" izinli ödünç kelimeler arasında değil. Öneri "İstek listesine ekle" (Steam'in TR
    arayüzünün deyişi). Çerçeve bugünkü değeri çizdi.
25. **Kapı saati 08:00** kabuğun `GATE_CLOCK`'u ve kabuk soru 22'nin varsayımıdır; motor başka saatte tutarsa bu grubun
    kapılı çerçeveleri kabukla birlikte, yalnız yeniden üretilerek değişir.
26. **"Çık" iki durumda da tehlike düğmesi**: karar yokken amber "Kaydet ve çık" ile kırmızı kenarlı "Çık" yan yana
    durur (SPEC §11: yıkıcı = tehlike, en çok bir birincil). Kabul mü, yoksa tehlike yalnız Kaydet ve çık kilitliyken mi?
27. **Dil satırı Oyun bölümünde**: ayrı DİL bölümü kalsın istenirse satır etiketsiz (yalnız açılır liste) olur; hangisi?
