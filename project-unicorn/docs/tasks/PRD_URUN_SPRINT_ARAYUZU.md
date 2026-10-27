# PRD · Ürün penceresi · Sprint sekmesinin arayüzü (A4)

Durum: kapalı (geliştirme sırasında tasarım sorusu çıkmaz; kalan her şey §15'te "park" diye işaretli ve geliştirmeyi
bloklamaz). Tarih 2026-10-23, denetim 2026-10-23 (sonda "Denetimde değişenler"). Yazan: yardımcı yönetmenin iş akışı.
Okuyan: kod oturumu (Sonnet kodlar, Opus inceler, Haiku kapı ve kare).

A4 maketi Erdem'in A2 ve A3 geri bildirimlerini uygular; A4'ün kendisi Erdem'e henüz gösterilmedi (`ERDEM_KARARLAR`'da
A4 kaydı yok). Ekranı çizen adımlar (U2 ile U6) Erdem A4'ün karelerine baktıktan sonra başlar; U0, U1 ve U1s beklemez
(§13).

Kimlikler: bu belgenin kararları **KR1 ile KR27** (§3), kart ipuçları **KT1 ile KT11** (§11.2). Çıplak "K1, K2, K3"
yalnız kademe etiketidir (KR7 onları ekrandan kaldırır). D'nin soru kimlikleri (K4, K6, K7; U1 ile U7) "D'nin" diye
yazılır; bu belgenin adımları U0, U1, U1s, U2 ile U8'dir.

Kaynaklar (okuma sırası):
1. Bu belge.
2. Maket A4: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/1eb70ce4-b7b7-4a33-a29b-4043e7472f47/scratchpad/sprint_ui/A4.html`,
   üreticisi aynı klasörde `gen_A4.py`, 24 kare `a4_fix/f01.png` … `f24.png` (1920×1080). A3 gibi
   `docs/strateji/sprint_ekrani/A4.html`'e alınınca o yol geçerlidir. Piksel ölçüsü, renk ve çizim dili maketin CSS'inden
   (`gen_A4.py:2000-2565`) okunur ve token'a çevrilir; maketin sayıları (kişi, kart, efor) örnektir.
3. Erdem'in kararları: `docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md`, özellikle 2026-10-22 ve 2026-10-23 bölümleri.
4. D'nin planı: `docs/tasks/faz_cde/d_taslak/ADIM_TABLOSU_D_v2.md` (§0b, §0c), `docs/tasks/faz_cde/PRD_FAZ_D_EKIP_SPRINT.md`.
5. Kod haritası: `docs/kod_haritasi/README.md`, `sistemler/02_urun_sprint.md`, `08_sekmeler.md`, `09_arayuz_bilesen.md`,
   `01_cekirdek.md`.

Satır numaraları 2026-10-23 çalışma ağacına göredir (HEAD `4482d5f3` ve D1b'nin commit'siz farkı: `game_state.gd`,
`time_model.gd`, `sprint_system.gd` kaydı). Kod haritasının kuralı geçerli: düzenlemeden önce hedef satır kaynakta
doğrulanır.

CLAUDE.md'nin bütün kuralları geçerlidir; bu belgede özellikle bağlayanlar: §5 (metin anahtar olarak doğar, önce
İngilizce, tire yok, `{ad}` eksiz), §7 (UI/STYLE LAW: renk ve boyut `UiTokens`'ta, tema `build_theme.gd`'de), §8 (kısa
kod, eskisini aynı commit'te sil), §9 (her commit'ten önce kıdemli inceleme), §10 (yeni smoke yalnız çekirdek mantık),
§11 (görsel kabul, en çok 2 düzeltme turu). Push yok; Faz PRD'si repoya alınmaz.

---

## 1. Amaç ve oyuncu açısından ne değişir

Sprint ekranı, oyuncunun iki haftada bir verdiği kararın (hangi kartlar, kim, ne zaman biter) tek yeridir. Bugünkü
ekran kart yığını, açıklayıcı cümleler ve puan kutularıyla çalışıyor; Erdem bunu yoğun ve hiyerarşisiz buldu
(2026-10-22 M2 incelemesi). A4 maketi, Erdem'in A2 ve A3 üzerine verdiği kararlarla yeni dili kurar (A4'ün onayı §13
kapısıdır):

- Oyuncu sprinti bir **zaman ekseninde** görür: her kartın tasarım, geliştirme ve test çubuğu, kimin çalıştığı,
  nerede beklediği, sprint çizgisini nerede aştığı. Kural yazılmaz; kural çubuklardan okunur.
- **Kapasite** üç aşamada "Efor 9 / 24" biçiminde: işin ekibe sığıp sığmadığı tek bakışta, taşan pay turuncu.
- Sol sütun **Müşteri talepleri** (hangi müşteri hangi kartı istiyor, söz tarihi) ve **Modüller** (aday kartlar).
- Sağ sütun **Hazırlık** (PM) ve **sonraki sprint** (devreden iş, önden yapılan iş).
- **Kurucu sprintte** anahtarı: kurucunun sprintte çalışıp çalışmadığı oyuncunun planlama kararıdır; görüşme günleri
  kurucunun çubuğunda taralı, kartı yetişmeyecekse kırmızı.
- Sprint sürerken başlat düğmesi yerine **ilerleme** ("%46 bitti"), şimdiki an çizgisi ve çalışanların yüzleri.
- Yazı tipi **Archivo** olur ve bütün oyuna yayılır (ayrı adım U0).

## 2. Kapsam ve kapsam dışı

**Kapsam.**
- Ürün penceresinin SPRINT görünümü: pencere içi denetim şeridi (sekmeler ve anahtarlar), sol sütun, orta sütun
  (başlık, kapasite, kart listesi ve zaman ekseni, alt düğmeler), sağ sütun, bütün ipuçları; planlama ve koşan sprint
  hâlleri.
- ÇEYREK görünümünde yalnız zorunlu olanlar: sol sütunu (ÇEYREK `AreaPanel`'i dar kipte kullanıyor,
  `quarter_view.gd:55`) yeni sol sütunla değişir; hedef şeridi "Bu çeyrek: hedef yok" hâlini çizer (D8b'nin arayüz
  parçası, §12). ÇEYREK'in sütunları ve PM planları değişmez.
- Archivo'nun bütün oyuna yayılması (U0, §9).
- Modelin arayüze açılan okuma yüzeyi: `ProductModel.live()` yeni anahtarları, zaman ekseninin birinci üreticisi
  (§7.4), kurucu anahtarının seam'i ve görüşme defteri (§7.3).
- Eski çizimin silinmesi: kullanılmayan `SprintCard` görünümleri, `ProductFixtures` kaynağı, okuyucusu kalmayan model
  alanları ve CSV anahtarları (§11.3).

**Kapsam dışı.**
- GENEL BAKIŞ görünümü (yalnız yazı tipi U0 ile değişir).
- Ar-Ge penceresi (kilitli modüller ve dönem kilitleri orada görünür, bu görev oraya bir şey eklemez).
- Sürüm notu ve MVP kapısı görünümü (`sprint_panel.gd:229` `_release`): yerleşimi değişmez; orta sütunun yerini
  bugünkü gibi alır, yalnız yazı tipi ve yeni sütun genişliği gelir.
- Tür seçici (`type_picker.gd`).
- Sprint motorunun kuralları: atama, merdiven, PM hazırlığı, hata modeli, öneri algoritması D'nindir (§12). Bu görev
  motorun sonucunu çizer; motoru değiştirmez. Tek istisna §7.4'teki ölçüm kancasıdır (sonucu değiştirmez).
- Üst bar ve haber şeridi (yazı tipi dışında). Üst barda gün adı yok (park P2).
- Maketin oyunda karşılığı olmayan parçaları (park P3 ile P7): kompakt pano, çok sprintlik kart, mevzuat talebi, kartın
  taşma sayacı, 10 modül, kademe merdiveni.

## 3. Bağlayıcı kararlar

Her madde tarihli ve kaynaklıdır. "EK" Erdem'in kararlarının dosyası (`ERDEM_KARARLAR_2026-10-20.md`), "A4" maket.

| # | Karar | Tarih · kaynak |
|---|---|---|
| KR1 | Ekran dili A4'tür; maket birebir uygulanmaz: pencere, sekme çubuğu ve sekme yapısı oyunun bugünkü yapısıdır (GENEL BAKIŞ · SPRINT · ÇEYREK). | 2026-10-23 EK "A2 maket geri bildirimi"; A4 CHANGES 9 |
| KR2 | Yazı tipi Archivo; bütün oyuna yayılır. | 2026-10-22 EK "ekip kararları" Soru 4; 2026-10-23 A3 geri bildirimi |
| KR3 | Açıklayıcı cümle satırı yok; bilgi ya ekranda ya ipucunda ya hiç. Her yere minik bilgi koymak da istenmez. | 2026-10-22 EK Soru 4; D v2 §0c |
| KR4 | Ekranda "SP" yok; birim sözcüğü "efor", sayılar SP'nin sayılarıdır (dönüşüm yok). Değerler "Efor 3 / 15" biçiminde, Efor büyük harfle. | 2026-10-23 EK A2 devam; 2026-10-23 A3 geri bildirimi |
| KR5 | Kapasite bölümünün başlığı "Kapasite"; "Efor ekibe sığıyor mu" başlığı yok. | 2026-10-23 A3 geri bildirimi |
| KR6 | Sol üst bölüm "Müşteri talepleri": hangi müşteri hangi modülün kartını istiyor, küçük bir söz tarihi ("bu çeyrek"). | 2026-10-23 A3 geri bildirimi |
| KR7 | K1, K2, K3 (kademe) gösterimi hiçbir yerde yok; kilitler (dönem, Ar-Ge) sprint ekranında görünmez, Ar-Ge'de görünür. Kilitli modül ve kilitli aday kart listelenmez. | 2026-10-23 A3 geri bildirimi; 2026-10-23 A2 geri bildirimi |
| KR8 | "Kurucu sprintte" anahtarı "Geçmiş" anahtarının yanında, aynı türde; demoda varsayılan açık; kapalıyken kurucu kart almaz. Anahtar planlamanın kararıdır. | 2026-10-23 EK "kurucu yönü onayı"; 2026-10-23 "kurucu yönü" ("Sprint planında kurucuyu dahil et / etme düğmesi") |
| KR9 | Kart ipucunda kural ve sayım cümlesi yok ("hızı en çok kısan tavan", "ekipte iki tasarımcı…", "en zor işe en iyi kişiler atanır…", "kişi aşaması bitene kadar orada kalır"). Kartın durumu kalır ("tasarım önceki sprintte önden bitti", "sprint sonuna yetişmez"). | 2026-10-23 A3 geri bildirimi |
| KR10 | Sprint sürerken "Sprinti başlat" yok; yerine sprintin ilerlemesi (yüzde kaçı bitti). | 2026-10-23 A3 geri bildirimi |
| KR11 | Planlama gece 00:00'da değil, şirketin mesai başlangıcında (`WorkHoursSystem.start_hour()`; 8 ile 11 arası, varsayılan 9) görünür. Planın görünme anı bu görevde (U5) mesai başlangıcına taşınır (Erdem 2026-10-23: "onu düzeltelim"); haftanın sınırının (kapanış, kâğıt zarı, atama) taşınması D2a'nındır (§8.1, §8.2, P12). | 2026-10-23 A3 geri bildirimi ve aynı günün düzeltmesi ("sabit 08:00'de değil, şirketin mesai başlangıcında"); D v2 §0c D2a notu |
| KR12 | Görüşmeler kurucunun gününü yer: satış görüşmesi 1 gün, yatırımcı görüşmesi 1 gün, term sheet masası 2 gün [WORKING]. Kurucu sprintteyse kartının çubuğunda görüşme günleri taralı; kartı yetişmeyecekse kart kırmızı. | 2026-10-23 EK "kurucu yönü onayı" |
| KR13 | Sprint 2 haftadır, bütün kartlar biterse erken kapanır; erken kapanış planda önceden söylenir. | 2026-10-23 EK A2 geri bildirimi; 2026-10-22 EK Soru 2 |
| KR14 | Tasarım bir sprint önden yürür (merdivenin sonucu); kimi kartlar tasarımsızdır, geliştirici tasarımı beklemeden başlar. Önden yapılan iş kart sprinte alınınca o oranda dolu başlar ve görünür. | 2026-10-23 EK A2 devam; 2026-10-22 EK Soru 2 |
| KR15 | PM etkisi yazıyla değil biçimle: hazırlanan kartın çubuğu kısalır, kısalan pay çubuğun altında gölge; hata göstergesi daha az dolu. "%25 daha hızlı, hata ×0,60" yazılmaz. Sorulan soruyu o kartın PM'i getirir. | 2026-10-23 EK A2; 2026-10-22 EK Soru 3 |
| KR16 | Darboğaz tek vurgu; aşamalar bant; kişi ikon ve portreyle, beceri renkle. "Yardım" ve "hazırlık" için ayrı ikon yok. | 2026-10-22 EK Soru 4 |
| KR17 | Boşta hâli yok; eğitimdeki ya da araştırmadaki çalışan sprint havuzunda seçilemez görünür, nedeni kısa yazar ("eğitimde"). | 2026-10-22 EK Soru 2 |
| KR18 | Taşma yokken darboğaz satırı bir şey yazmaz; sorun sürüyorsa "bu sorun N sprinttir sürüyor" tonu. | 2026-10-20 EK Karar 22, 26 |
| KR19 | Çeyrek hedefi yokken "Bu çeyrek: hedef yok". Hedef PM'siz de seçilir; planlamayı devretmek PM ister. | 2026-10-20 EK Karar 27; PRD_FAZ_D Karar 12 (QCD D4) |
| KR20 | Atamayı sistem yapar, elle atama yok. | 2026-10-21 EK 18 = A |
| KR21 | Arayüz ölçeği ayarı baştan olur (1,25 karesi kabulün parçası). | 2026-10-22 EK Soru 4 |
| KR22 | Tire hiçbir oyuncu metninde yok; görsel tutarlılık ve göç sorulmaz, yapılır; ölü kod, anahtar, belge bırakılmaz. | 2026-10-20 EK 14, 15, genel kural |
| KR23 | Bu görevde verilen karar: ekranın her öğesi motordan gelen veriyle çizilir; verisi olmayan öğe çizilmez, yerine taklit hesap yazılmaz (§7.3). | yardımcı yönetmen, bu PRD |
| KR24 | Bu görevde verilen karar: oyunda hafta içinde gün kavramı yoktur (bir tik bir hafta); ipuçları gün adı yazmaz. Kart ipucu hafta işareti de yazmaz (Erdem A2'de "1. hafta / 2. hafta işaretleri neden var, belli değil" dedi): kartın durumu "Sprint sonuna yetişir" ya da "Sprint sonuna yetişmez"dir. Hafta yalnız eksende (sütun başlıkları), hafta rozetinde ve erken kapanış ipucunda yazar. Görüşme günleri çubukta gün uzunluğunda taranır (1 gün = haftanın beşte biri). | yardımcı yönetmen, bu PRD; A4 NOT_DONE 2; 2026-10-23 EK A2 ve A3 geri bildirimi |
| KR25 | Bu görevde verilen karar: koşan sprintin satırlarında düğme yok (A4 kare 10, 17, 24); sonraki sprintin kartlarında üstüne gelince "↑" ve "×" kalır (bugünkü işlev). | A4; bugünkü `ProductModel.BUTTONS` `product_model.gd:98` |
| KR26 | Bu görevde verilen karar: kartsız planda "Sprinti başlat" "0 kart" ekiyle açıktır ve basınca boş sprint başlar (`SprintSystem.skip`); "Bu sprinti boş geçir" düğmesi ve onay satırı kalkar. "Kartsız" = planda kapısı açık kart yok (`can_start`'ın kart şartı tutmuyor); kapısı sonradan kapanmış kartlar `skip` ile sonraki sütuna geçer (bugünkü `skip` davranışı). | A4 kare 16; D v2 §0c ("Bu sprinti boş geçir yeni yorumda kalkabilir") |
| KR27 | Bu görevde verilen karar: "Planlamayı devret" alt şeridin solundadır; sprint sürerken de basılabilir (devir sonraki planlamada işler). | D v2 §0c ("Sprinti başlat'ın yanında kalır"); A4 `foot` |

## 4. Ekran anatomisi

### 4.0 Izgara ve ölçüler

Pencere `WindowLayer.SPECS` Ürün 1424×928 (`window_layer.gd:38`), değişmez. Başlık 72 px (bugünkü KPI'lar: pazar ·
tür · ad, sürüm), denetim şeridi 56 px (`UiTokens.D_H_WIN_CTL`). Gövde: iç pay 16 / 24 / 20 px; üç sütun 288 | kalan
(746) | 300, aralık 20. Orta sütun çerçeveli kutudur (A4 `.cc`), sağ sütunun sonraki sprint kutusu kesikli çerçeveli
(bugünkü `SprintColumnNext` + `HRUiShared.D_dashed`).

Yeni ölçü token'ları (`UiTokens`, koyu aile, `D_` önekli): sol sütun 288, sağ sütun 300, kart bilgi sütunu 312, zaman
ekseni 396 (12 px kaydırma şeridi dahil), satır 56 (iki satırlı ad 74), kapasite satırı 56 (etiket 108 · iz kalan ·
sayı 124 · rozet 72), çubuk yüksekliği 30, alt şerit 68, sprint başlığı 52. Zaman ekseni 2,6 hafta gösterir: 1. hafta,
2. hafta, sonraki sprintin ilk 0,6 haftası. `D_W_AREAS` (430), `D_W_AREAS_NARROW` (280), `D_SPRINT_COLUMNS` okuyucusu
kalmazsa silinir.

### 4.1 Denetim şeridi (üst anahtarlar)

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| Sekmeler | GENEL BAKIŞ · SPRINT · ÇEYREK, bugünkü `D_seg_tabs` ve kilit kuralı (`product_tab.gd:219` `_build_ctl`) | ekran; kilitli sekmenin gerekçesi ipucunda (bugünkü) | hepsi |
| Kurucu sprintte | aç/kapa anahtarı, `SprintUiShared.switch` türü (`sprint_ui_shared.gd:251`); Geçmiş'in solunda | ekran; ipucu açıkken "Açık: kurucu sprint kartlarında çalışır", kapalıyken "Kapalı: kurucu sprint kartı almaz" | açık: 1, 3 ile 8, 10, 11, 14, 16 ile 21, 23, 24; kapalı: 2, 9, 12, 15, 22 |
| Kurucu sprintte (kilitli) | sprint sürerken soluk ve basılmaz | ipucu "Sonraki planlamada değişir" | 10, 17, 24 (A4 açık çiziyor; oyunda soluk, KR8) |
| Kurucu sprintte (Ar-Ge) | kurucu Ar-Ge işini tutuyorsa soluk ve basılmaz; anahtarın değeri saklanır | ipucu bugünkü `PRODUCT_TEAM_IN_RND` ("Kurucu Ar-Ge'de: {node}") | yok (KR8'in sonucu) |
| Geçmiş | bugünkü anahtar; açıkken sol sütunun başında sürüm geçmişi (bugünkü `area_panel.gd:47` `_add_history`) | ekran | hepsi (kapalı) |

"Planlamayı devret" anahtarı şeritten kalkar, alt şeride düğme olarak iner (KR27, §4.6).

ÇEYREK sekmesinin kilidi bugünkü gibi kalır: PM yokken kilitli, ipucu bugünkü `PRODUCT_QUARTER_NEED_PM` (ÇEYREK'in içeriği
PM'in planlarıdır). PM'siz hedef seçimi (KR19) ÇEYREK'i açmaz; hedef SPRINT başlığındaki seçiciden seçilir (§4.3). W2'nin
"`PRODUCT_QUARTER_NEED_PM` ölü anahtar olur" notu bu yüzden geçersizdir; anahtar kalır.

Tek kurucu anahtarı kapatırsa ekip boşalır: ekran bugünkü "Kimse çalışamıyor" hâlini gösterir (§4.5), ayrı uyarı yok.

### 4.2 Sol sütun: Müşteri talepleri ve Modüller

Sütun kendi içinde kayar (bugünkü `_areas_scroll`). ÇEYREK aynı sütunu kullanır (§2).

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| Başlık "MÜŞTERİ TALEPLERİ {n}" | açık talep sayısı; yalnız B2B'de (B2C'de bölüm yok, bugünkü `customers: null` kuralı) | ekran | 2 ile 24 (1'de MVP öncesi talep yok) |
| Talep satırı, 1. satır | bina ikonu + müşteri adı (kalın, taşarsa üç nokta) + söz tarihi çipi (kum saati + "bu çeyrek" / "gelecek çeyrek" / "{q}. çeyrek"); bu çeyrekse çip vurgulu | ekran | 3, 4, 15 |
| Talep satırı, 2. satır | modülün iki harfli işareti (mono kutu) + kartın adı | ekran | 3, 15 |
| Talep satırı, planlı | kartı bu sprintin planındaysa: zeminsiz, soluk; çipte tik + tarih; listenin sonunda | ekran; çip ipucu "Kartı bu sprintin planında" | 4, 15 |
| Talep satırının ipucu | "{müşteri} · {kart} ({modül}) · {değer}/yıl · söz: {tarih}" | ipucu | 3, 15 |
| "+{n} talep ▾" | 3'ten fazla talep varsa ilk üçü görünür (önce planlı olmayanlar, önce bu çeyrek), kalanı açılır | ekran | 15 |
| Başlık "MODÜLLER" | bugünkü alanlar (`SprintCatalog.areas_for`), sıra bugünkü | ekran | hepsi |
| Modül satırı | mono işaret + ad + "planda" (bu sprintte kartı varsa) + ok (› kapalı, ˅ açık). Kademe, seviye karesi, sözcük, alan cümlesi, hata satırı, uyarı üçgeni ve rakip satırı YOK (KR3, KR7) | ekran; ipucu "{modül} · Bu sprintte kartı var" (yalnız planda ise) | hepsi |
| Açık modül | tek açık modül (bugünkü akordeon kuralı); altında aday kartlar | ekran | 3 ile 8, 16, 18 |
| Aday kart | ad + efor + "+" düğmesi; ya da tik (bu sprintin planında) ya da damga "S{n}" (başka sprintte); altında aşama şeridi (tasarım · geliştirme · test payları, bant renkleriyle, oransal) | ekran; "+" ipucu "Plana ekle", kapalı "+" ipucu bugünkü `PRODUCT_ADD_CLOSED` / `PRODUCT_ADD_CLOSED_FULL`, tik ipucu "Bu sprintin planında", şerit parçası ipucu "{aşama} {efor}" | 3, 16 |
| Kilitli aday | listelenmez (KR7) | yok | yok |
| Aday düzeltme kartı | adın yanında efordan önce hata sayısı ("5 hata", bugünkü `PRODUCT_FX_BUGS`, `SprintUiShared.bugs_text`'in ilk parçası); modül satırının hat başına hata listesi kalktığı için hattın hatası burada görünür. Destek raporunun düğmesi en kötü hattın modülünü açar (bugünkü yol) ve oyuncu düzeltme kartını orada görür | ekran; ipucu `SprintUiShared.bugs_text` (bugünkü düzeltme metni) | 3 ile 7 (planlı hâli) |

Modülün iki harfli işareti veriden okunur: alanın ad anahtarına `_MONO` eklenmiş anahtar (§11.1).

Talep satırı talep başınadır (bugünkü `_customers`: her açık talep bir satır). Aynı kartı birden çok hesap istiyorsa her
hesap ayrı satırdır; "+{n} talep" katlaması kalabalığı taşır. Tek satırda "ve 13 hesap" gösterimi park (P15).

### 4.3 Orta sütun: sprint başlığı

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| "SPRINT {n}" | sprint numarası, geniş kalın (Archivo 800, genişlik 118) | ekran | hepsi |
| Çeyrek göstergesi | "{q}. ÇEYREK" + ürün çeyreğinin sprint sayısı kadar çentik (bugün 6: `quarter_weeks` 12 ÷ 2), geçmiş çentikler dolu, bugünkü vurgulu | ekran; ipucu "{yıl} · {q}. çeyrek · çeyreğin {pos}. sprinti · çeyrek sonuna {left} sprint" | 1 ile 24 |
| MVP rozeti | yalnız v1.0'dan önce: "v1.0" + "{done}/{need} kart" + "≈ Sprint {n}" | ekran; ipucu bugünkü `PRODUCT_MVP_RULE` | 1, 20, 21 |
| Hafta rozeti | yalnız sprint sürerken: iki küçük hafta çubuğu (geçen kısmı dolu) + "{w}. hafta" | ekran | 10, 17, 24 |
| Ekip rozeti | yalnız bir aşamanın kişi dizisi kümeye döndüğünde (§4.4): üç yüz yığını + toplam kişi | ekran; ipucu "Ekip: {n} kişi · sprintte … · eğitimde … · izinde … · araştırmada … · PM … · sprint dışı …" | 9 |
| Hedef seçici | "Bu çeyrek: {modül} ▾", "Bu çeyrek: Hatalar ▾" ya da "Bu çeyrek: hedef yok ▾" (W2 anahtarları `PRODUCT_QUARTER_GOAL`, `PRODUCT_QUARTER_BUGS`, `PRODUCT_QUARTER_NONE`); PM'siz de açık; v1.0'dan önce de aynı kural (A4'ün "v1.0'a kadar sabit Çekirdek" çizimi park, P14) | ekran; ipucu "Çeyrek hedefini değiştir" | 1 ile 24 (3, 19 "hedef yok") |

Hedef menüsü ÇEYREK'in bugünkü menüsüdür (`quarter_view.gd:111` `_open_goal_menu`, `HRPopover`); başına "Hedef yok"
satırı, alanlardan sonra "Hatalar" satırı (D8b'nin seçeneği, cümlesiz tek satır) eklenir; ortak kod tek yerde kalır
(ikinci menü yazılmaz). Menünün iki ev sahibi (SPRINT başlığı ve ÇEYREK şeridi) aynı işlevi çağırır.

### 4.4 Orta sütun: Kapasite

Başlık satırı: solda "KAPASİTE"; sağda yalnız planlamada ve devir kapalıyken öneri: "{n} efor daha sığar" +
"Öneriyi uygula" düğmesi (§7.2 "Öneri" satırı). Altında üç aşama satırı (Tasarım, Geliştirme, Test), her biri 56 px.
Oluğun, dolgunun ve iki taşmanın hesabı §7.3 E2'dedir.

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| Aşama etiketi | aşama ikonu (bant renginde) + ad | ekran; ipucu aşamanın özeti (§11.2 C1) | hepsi |
| Oluk | ekibin bu aşamada sprintin kalan haftalarında yapabileceği efor; ince çerçeve, sonunda açık renk kalın çizgi | ekran | hepsi |
| Dolgu | bu sprintin bu aşamadaki eforu (önden yapılmış iş ve büyük kartın devamı hariç) | ekran | hepsi |
| Yapılan | yalnız sprint sürerken: dolgunun içinde koyu kısım | ekran | 10, 17, 24 |
| Dış taşma | eforun oluğu aşan payı, oluğun bitişinden turuncu tarama | ekran | 4 ile 7, 12, 23 |
| İç taşma | ekip bir önceki aşamayı beklediği için oluk dolmadan taşan pay, dolgunun ucunda turuncu tarama | ekran | 4, 6, 12 |
| Aday hayaleti | imleç bir adayın "+"ındayken adayın bu aşamadaki eforu, dolgunun ardında kesikli | ekran | 3 |
| Boş aşama | eforu ve ekibi yoksa oluk yerine kesikli çizgi, etiket soluk | ekran | 2, 12 |
| Kişi dizisi | oluğun altında 24 px yüzler, sağ altta yıldız çipi; yüzün altında 3 px doluluk çizgisi (bant renginde); görüşme payı çizginin sağında ince tarama | ekran; ipucu "{ad} {yıldız} · efor {e} · doluluk {%}" | hepsi |
| Seçilemeyen kişi | eğitimde, izinde, araştırmada ya da o hafta bütün payı görüşmede: soluk gri yüz, yıldızsız, yanında "eğitimde" / "izinde" / "araştırmada" / "görüşmede"; rolünün satırında durur. Görevler matrisinde yalnız Destek'te olan kişi oyuncunun kararıyla sprint dışıdır: dizide görünmez, yalnız ekip rozetinin ipucunda "sprint dışı" sayısındadır. Kurucu anahtarı kapalıyken kurucu hiçbir satırda görünmez | ekran (KR17); ipucu "{ad} {yıldız} · {neden}" | 16, 9 |
| Yıldız kümesi | bir aşamada 9'dan çok kişi varsa yıldız başına tek temsilci yüz + "{s}★" + "×{n}"; seçilemeyenler nedenine göre ayrı küme | ekran; ipucu "{s}★ · {n} kişi" | 9, 12 |
| Tek kurucu | ekip yalnız kurucuysa üç satır tek kişiyi paylaşır: oluk sonları kesikli, üç satırı kuşatan köşeli parantez ve kurucunun tek yüzü Test satırının hizasında | ekran | 1 |
| Sayı | "Efor {iş} / {ekip}": "Efor" küçük, iş büyük kalın, "/ ekip" soluk; taşmada iş sayısı uyarı renginde | ekran | hepsi |
| Rozet | sığıyorsa tik; taşıyorsa "+{n}" turuncu kutu | ekran; ipucu "Sığıyor" ya da "{n} efor sonraki sprinte kalır" | hepsi |
| Süreklilik rozeti | aynı aşama art arda 2 ve daha çok sprint taşıyorsa "{n}." halka; en kötü aşamanın satırı hafif turuncu zemin | ekran; ipucu "Bu sorun {n} sprinttir sürüyor." (W2 `PRODUCT_NECK_STREAK`) | 7, 12 |
| Taşma ipucu | taşan aşamanın etiketine ya da rozetine gelince: başlık "{aşama} · Efor {iş} / {ekip}", "+{n} sonraki sprinte kalır", "{AŞAMA}DA KALIR" altında kart başına ad ve efor, varsa süreklilik satırı | ipucu | 7 |

### 4.5 Orta sütun: kart listesi ve zaman ekseni

Pano başlığı (sabit): solda "{n} KART" (erken kapanışta yanında bayrak + "SPRINT ERKEN BİTER"), sağda eksenin
etiketleri "1. HAFTA", "2. HAFTA", "SPRINT {n+1}". Pano gövdesi kayar; başlık ve alt şerit yerinde kalır.

Izgara: hafta ayracı ince çizgi; sprint sonu kalın çizgi; sonraki sprint bölgesi dikey çizgili soluk zemin; erken
kapanışta kapanış anından sprint sonuna taralı alan ve sol kenarında kesikli çizgi; sprint sürerken şimdiki an vurgu
renginde dikey çizgi ve tepesinde üçgen.

**Satır, bilgi sütunu (312 px).**

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| Tür ikonu | özellik, düzeltme, araştırma, talep (bugünkü `SprintUiShared.KIND_ICON`) | ekran | hepsi |
| Kart adı | kalın; 22 karakterden uzunsa iki satır (satır 74 px), yine taşarsa üç nokta | ekran; ipucu kart ipucu (§4.8) | hepsi; 14 iki satır |
| Hata göstergesi | hata ikonu + küçük çubuk: kartın beklenen hata riski; PM'in hazırladığı kartta çubuğun altında hazırlanmamış hâlinin taralı payı | ekran; ipucu "Hata riski {düzey}" ve hazırlandıysa "{PM} hazırladı: {önce} yerine {şimdi}" | 3 ile 24 |
| Efor | kartın görünen eforu (§7.3 E1), tam sayıya yuvarlanmış; ekranın bütün efor sayıları tam sayıdır, toplamlar yuvarlanmamış değerlerden alınıp sonra yuvarlanır | ekran; ipucu "efor {n}" | hepsi |
| 2. satır, modül | modülün kısa adı (`SprintCatalog.area_short`), 104 px | ekran; ipucu modülün tam adı | hepsi |
| 2. satır, düzeltme | düzeltme kartında modül yerine hata metni: "5 hata · 3 hesap · 120 kullanıcı" (bugünkü `SprintUiShared.bugs_text`) | ekran | 3 ile 7 |
| 2. satır, durum yuvası | sırayla ilk uyan: söz tarihi çipi (bina + "bu çeyrek" / "gelecek çeyrek", bu çeyrekse vurgulu); "devreden" (geri ok); "yetişmez" (kırmızı); boş. "Teknik" çipi park (P13: bugünkü katalogda tasarımsız özellik kartı yok; tasarımsız tek kart düzeltme kartıdır ve onun tür ikonu ve hata metni zaten var) | ekran; ipuçları §11.2 | 3 ile 8, 18, 23 |
| PM yuvası | kartı hazırlayan PM'in 24 px yüzü; karta bağlı bekleyen bir soru varsa soranın yüzü ve sağ üstte "?" | ekran; ipucu "{PM} {yıldız} hazırladı: efor {önce} yerine {şimdi}" ya da "{ad} bu kartla ilgili soruyor · aç" | 4, 5, 8, 10, 17 |
| Satır düğmeleri | yalnız planlamada, üstüne gelince: "→" (sonraki sprinte), "×" (çıkar); aday satırında hep görünen "+" | ekran | 3 (aday), 11 (üstüne gelince) |
| Satır vurgusu | üstüne gelince zemin açılır, sol kenarda 3 px çizgi | ekran | 11 |
| Kırmızı satır | kurucunun kartı yetişmiyorsa: ad ve sol kenar kırmızı, durum yuvası "yetişmez" | ekran | 23 |

**Satır, zaman ekseni (396 px).** Her aşama bir çubuktur (30 px yüksek, bant renginde, içinde aşama ikonu ve efor
sayısı); sığmayan yerde önce ikon, sonra sayı düşer.

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| Aşama çubuğu | aşamanın sprint içindeki başlangıcı ve bitişi | ekran; ipucu "{aşama} · efor {n}" + durum parçaları (§11.2 B1) | hepsi |
| Bekleme | aşamanın hazır olduğu andan başladığı ana noktalı çizgi; bir satırda ilk öğeden son öğeye boşluk kalmaz | ekran; ipucu "Bekliyor: {ad} ({kart} · {aşama})" ya da "Bekliyor: {rol çoğul}" | 2, 3, 4, 6, 16, 20 |
| Önden yapılmış iş | aşamanın sprint öncesinde yapılmış payı çubuğun başında dolu; sayı "{yapılan}/{toplam}" | ekran | 4, 18 |
| Önden bitmiş aşama | aşamanın tamamı önden bittiyse o aşamanın çubuğu çizilmez; sonraki aşamanın çubuğunun başında o aşamanın renginde tik kutusu | ekran; ipucu "{aşama} · önceki sprintte önden bitti" | 3, 4, 6, 11 |
| Sprint dışı pay | sprint çizgisini aşan pay, çizgiden itibaren turuncu tarama | ekran; ipucu "… · sonraki sprinte kalır" | 4 ile 7, 12, 13, 23 |
| PM gölgesi | hazırlanan kartın aşama çubuğunun altında, çubuğun başından hazırlanmasaydı biteceği yere uzanan 6 px soluk şerit | ekran; ipucu "{aşama}: hazırlanmasaydı efor {önce}, şimdi {şimdi}" | 4, 5, 8 |
| Görüşme günleri | kurucunun çalıştığı çubukta görüşme günlerinin taraması (gün başına haftanın beşte biri) | ekran; ipucu "{görüşme} · {w}. hafta · {n} gün" | 1, 6, 8, 23, 24 |
| Kurucunun yüzü | kurucunun çalıştığı kartta çubuğun ucunda 24 px yüz (planlamada) | ekran | 3, 4, 6, 8 |
| Koşan aşama | sprint sürerken: bitmiş aşama dolu ve tikli; süren aşama soluk zeminde yapılan kadar dolu, sayı "{yapılan}/{toplam}", şu an çalışanların yüzleri çubuğun içinde; başlamamış aşama yalnız çerçeve | ekran | 10, 17, 24 |
| Aday hayaleti | aday satırının çubukları kesikli çerçeve, dolgusuz | ekran | 3, 16 |
| Araştırma kartı | tek çubuk, nötr renk (`D_INK_3`), Ar-Ge ikonu; kapasite satırlarına sayılmaz | ekran; ipucu "Araştırma · efor {n} · {kişiler}" | yok (A4'te araştırma kartı yok; bu PRD'nin kuralı) |

- **Not (yardımcı yönetmen, 2026-10-27):** art arda önden (ya da koşan sprintin önceki haftasında) biten aşamalarda tek
  kutu, maket gereği: son biten aşamanın renginde; hangi aşamaların bittiği ipucundadır (U6). Koşan sprintte henüz
  başlamamış çubuk planlamadaki gibi eforu yazar; "{yapılan}/{toplam}" yalnız süren çubuktadır.

**Pano gövdesinin özel satırları.**

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| Boş sprint satırı | kart yokken tek hayalet satır: "+ Kart ekle" ve altında "← MODÜLLER" | ekran | 16 |
| "EKLENEBİLİR" bölümü | (a) planda kart yokken önerinin ilk üç adayı, her biri hayalet satır ve "+"; (b) imleç sol sütunda bir adayın "+"ındayken o aday, düşeceği yerde | ekran | 3, 16 |
| "aşağıda {n} kart daha" | gövde taşıyorsa altta yapışık hap; kaydırınca güncellenir | ekran | 13 |
| Kimse çalışamıyor | ekip yoksa bugünkü boş hâl (ekip glifi, not, çıkış düğmesi; `sprint_panel.gd:170` `_nobody`) gövdenin ortasında | ekran | yok (bugünkü hâl korunur) |

### 4.6 Orta sütun: alt düğmeler

68 px şerit, üstünde ince çizgi.

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| Planlamayı devret | solda: PM varken "{PM yüzü} Planlamayı devret: {PM}" (çeyreğin PM'i, `SprintCatalog.quarter_pm`); PM yokken kilit ikonu + "Planlamayı devret", basılmaz | ekran; kilitliyken ipucu "Planlamayı devretmek için ekipte bir ürün yöneticisi olmalı." (W2 `PRODUCT_DELEGATE_LOCKED`) | 3 ile 8, 10, 16 ile 19, 22, 23 (PM'li); 1, 2, 6, 11 ile 15, 20, 21, 24 (kilitli) |
| Devirdeyken | solda PM'in 32 px yüzü (5★ çipi) + "{PM} planlıyor"; ortada boşluk; sağda "Planlamayı geri al" ve "Kendiliğinden başlar" kutusu (başlat yerine) | ekran | 9 |
| Sprinti başlat | sağda, birincil (vurgu rengi), en az 204 px; kartsızsa yanında "0 kart" | ekran; ekip yokken basılmaz ve ipucu bugünkü gerekçe (`PRODUCT_TEAM_NOBODY_JOBS` ya da Ar-Ge cümlesi) | planlama kareleri; 16 "0 kart" |
| İlerleme | sprint sürerken başlat yerine: "SPRINT" etiketi + yatay çubuk + "%{n}" + "bitti" | ekran; ipucu "Efor {biten}/{toplam}" | 10, 17, 24 |

- **Not (yardımcı yönetmenin kararı, 2026-10-27, U5):** devir hâli iki kipte aynı okunur: sprint sürerken de solda PM'in
  32 px yüzü + "{PM} planlıyor" + "Planlamayı geri al", sağda ilerleme çubuğu. Ekip yokken kartlı planda "Sprinti başlat"ın
  solunda bugünkü çıkış bağlantısı ("Ekip'e git") durur; kartsız planda gövdedeki boş hâl çıkışı taşır, şeritte ikinci kez çıkmaz.
  Sprint sürerken devirde ilerleme çubuğu en uzun ada yer açmak için en az 90 px'e iner ("%{n} bitti" ve iç pay aynı), ad kesilmez. Devir açık,
  ekip yok (kapasite 0) ve planda kart varken sağda "Kendiliğinden başlar" yerine "Ekip'e git" durur; ekip dönünce kutu geri gelir.

### 4.7 Sağ sütun: Hazırlık ve sonraki sprint

| Öğe | Ne gösterir | Ekran / ipucu | A4 karesi |
|---|---|---|---|
| "HAZIRLIK" | başlık | ekran | hepsi |
| PM satırı | 32 px yüz + yıldız çipi, ad, "{n} kart hazırladı" ya da "hazırlıkta"; iki ve daha çok PM'de satırlar sıkışık | ekran; ipucu "{ad} {yıldız} · {kart adları}" | 3 ile 5, 8, 9, 16 ile 19 |
| PM yok | boş disk + soluk "PM yok" | ekran; ipucu "Ekipte ürün yöneticisi yok" | 1, 2, 6, 11 ile 15, 20, 21, 24 |
| Sonraki sprint kutusu başlığı | "SPRINT {n+1}" + "SONRAKİ" | ekran | hepsi |
| Aşama yükü | üç küçük satır: aşama ikonu, çubuk (devreden kısım taralı, planlı kısım dolu, ekip gücüne oranlı), "{devreden+planlı}/{ekip}" (aşarsa uyarı rengi) | ekran; ipucu "{aşama} · devreden {d} · planlı {p} · ekip {e}" | hepsi |
| "DEVREDEN" | bu sprintin planında sprint çizgisini aşan aşama payları: aşama ikonu + kart adı + efor, turuncu taralı kutu; 5'ten çoksa en büyük 4'ü ve "+{n} kart" | ekran; ipucu "{kart} · {aşama} · efor {n}" | 4 ile 8, 13, 18 |
| "KARTLAR" | sonraki sütunun kartları: tür ikonu + ad + efor; altında aşama şeridi (önden yapılan kısım dolu); önden çalışanların yüzleri kendi aşama parçasının altında; PM hazırlıyorsa yüz + kum saati "hazırlanıyor" ya da tik "hazır" | ekran; ipuçları §11.2 R1 ile R4 | 1, 3 ile 8, 10, 16 ile 19 |
| Kart düğmeleri | üstüne gelince "↑" (bu sprinte) ve "×" (çıkar) | ekran | yok (KR25) |
| Boş kutu | kart ve devreden yoksa yalnız başlık ve aşama yükü kalır; açıklama cümlesi yok | ekran | 2 |

- **Not (yardımcı yönetmenin kararı, 2026-10-27, U5):** KARTLAR'ın aşama şeridinde her aşama kendi payıdır, önden biten pay
  kendi aşama renginde dolar (tek kutu kuralı yalnız panonun zaman ekseninde, §4.5 notu). Ne kart hazırlamış ne hazırlıkta
  olan PM soluk "0 kart hazırladı" yazar. Sürüm notu kipinde devreden kartlar yalnız DEVREDEN'dedir; kart düğmesi sprint
  sürerken ve sürüm notunda yalnız "×"tır, kapısı kapanmış kartta da.

Sonraki sprint bayrakları (rakip çıkışı, son tarih; bugünkü `next.flags`) bu ekranda çizilmez: son tarih soldaki
talepte ve kartın durum yuvasındadır, rakip bilgisi haber şeridinde ve Piyasa'dadır (KR3).

### 4.8 Kart ipucu (zengin)

Kart adının ya da çubuklarının üstüne gelince açılan panel (Godot `_make_custom_tooltip`, varsayılan gecikme, koyu
`D_*` zemin, 288 px). Konumu Godot'nun ipucu kuralıdır (A4'teki ok çizilmez).

1. Başlık: tür ikonu + kart adı + sağda "Efor {n}".
2. Aşama ihtiyaçları: aşama başına küçük kutu (ikon + efor; önden bittiyse tik; gereksinim verisi varsa "≥{n}★").
3. Kim: aşama başına satır, o aşamada çalışan(lar)ın 24 px yüzü + "{ad} {yıldız}"; önden bitmiş aşamada "önceki
   sprintte önden bitti"; kurucunun görüşme satırları "{görüşme} · {n} gün" (hafta yazılmaz, KR24).
4. Son satır: "Sprint sonuna yetişir" ya da "Sprint sonuna yetişmez" (kurucunun yetişmeyen kartında kırmızı).
5. Künye: müşteri varsa "{müşteri} · {değer}/yıl", söz varsa "söz: {tarih}", sonra "{modül} · {PM durumu}" (PM durumu:
   "{PM} hazırladı" ya da "PM yok"), kurucunun kartıysa "kurucunun kartı".

Kural ve sayım cümlesi yok (KR9). "Özenli" ve "Aceleci" yok (D5b park, §15).

## 5. Durumlar

A4'ün her karesi bir durumdur. "Oyunda" sütunu, durumun bu görevle oyunda nasıl çıktığını söyler; "shot" türü
`--product-shot=live:<tür>` (motorla kurulan koşu, §13 U7) adıdır. Kareler oyunun kendi adlarıyla çekilir; maketin
kişi adları örnektir.

| Kare | Durum | Tetikleyici | Değişen öğeler | Oyunda | shot |
|---|---|---|---|---|---|
| 01 | Tek kurucu, v1.0 öncesi | ekip yalnız kurucu, ürün canlı değil | tek kurucu kapasitesi, MVP rozeti, hedef seçici ("hedef yok"; A4'ün kilitli hedefi P14), PM yok, görüşme taraması | tam | `a4_solo` |
| 02 | 3 geliştirici, kurucu kapalı | ekipte yalnız geliştirici; anahtar kapalı | boş tasarım ve test satırları, bekleme | kısmen: çok sprintlik kart ve "teknik" kartlar katalogda yok (P4, P13); büyük kart sprint dışı payla çizilir; testçi yokken testi geliştiriciler yarı hızla yapar (bugünkü motor), Test satırının oluğu onların Test'te ürettiği eforudur (§7.3 E2) | `a4_devs3` |
| 03 | 6 kişi, taşma yok, hedef yok, aday hayaleti | planlama, taşma yok, hedef seçilmemiş, imleç adayın "+"ında | öneri satırı, kapasite hayaleti, EKLENEBİLİR, kurucunun yüzü | tam | `a4_six_hover` |
| 04 | 6 kişi, iyi PM | PM 5★ iki kart hazırladı | PM yuvası, gölge, az dolu hata göstergesi, önden yapılmış tasarım, iç taşma, DEVREDEN | D4 ve D3 indikten sonra tam | `a4_six_pm5` |
| 05 | 6 kişi, zayıf PM | aynı plan PM 2★ | gölge kısa, gösterge dolu, taşma büyük | D4, D3 sonrası tam | `a4_six_pm2` |
| 06 | 11 kişi, taşmanın ilk sprinti | test sığmıyor; kurucuda term sheet masası | dış taşma, DEVREDEN, 2 günlük tarama | tam | `a4_eleven` |
| 07 | 11 kişi, taşma sürüyor | aynı aşama 3. sprint taşıyor | "3." rozeti, sıcak satır, taşma ipucu | D2b'nin sayacı indikten sonra tam | `a4_eleven_streak` |
| 08 | İki PM | 5★ ve 2★ PM aynı panoda | iki PM satırı, iki gölge boyu, satış görüşmesi taraması | D4 sonrası tam | `a4_two_pm` |
| 09 | 50 kişi, planlama PM'de | 50 kişilik ekip, devir açık | yıldız kümeleri, eğitim ve araştırma kümeleri, ekip rozeti, devir şeridi | kısmen: kompakt pano park (P3); pano kayan normal panodur (bugünkü katalog en çok 14 kart) | `a4_fifty` |
| 10 | Sprint sürerken | 2. haftanın açılışı | hafta rozeti, şimdiki an, koşan çubuklar, ilerleme, "?" yuvası, önden çalışan tasarımcı sağda | tam (önden geliştirme yok, P9) | `a4_run_w2` |
| 11 | Kart ipucu | imleç bir kartta | satır vurgusu, zengin ipucu | tam | `a4_eleven_tip` |
| 12 | Bir aşamada 12 kişi, üç aşama taşıyor | büyük geliştirme kadrosu | geliştirme kümeleri, üç rozet, iç taşma | tam | `a4_twelve_dev` |
| 13 | 14 kart, pano kayar | sprintte 14 kart | "aşağıda N kart daha", DEVREDEN "+N kart" | tam | `a4_fourteen` |
| 14 | İngilizce, uzun adlar | `--lang=en`, uzun kart adları, aynı adlı iki kişi | iki satırlı ad, EN metinler; aynı adlılar ipucunda tam adla ayrılır | tam | `a4_eleven_tip` + `--lang=en` + uzun ad fikstürü |
| 15 | Talepler ve modüller | ERP'de 4 açık talep (motorun kurabildiği en çok, U1s cevap 1) | "+N talep ▾", planlı talepler | kısmen: beşinci talep, mevzuat, çok sprintlik kart, 8 modül park (P4, P5) | `a4_requests` |
| 16 | Boş sprint | planda kart yok, bir geliştirici eğitimde | boş satır, EKLENEBİLİR (öneri ilk üç), seçilemeyen kişi, "0 kart" | tam | `a4_empty` |
| 17 | Sprint sonu | 2. haftanın sonu, tasarımcı işini bitirdi | %95, önden tasarım sağda dolu ve yüzlü | kısmen: geliştiricinin önden geçişi D2a'yla (P9) | `a4_run_end` |
| 18 | Önden yapılan iş dolu başlar | 17'nin sonraki planı | önden yapılmış paylar, tik kutusu, devreden kart, erken bayrak | tam (tasarım için) | `a4_next_prefilled` |
| 19 | Plan erken biter | bütün kartlar sprint bitmeden biter | bayrak, "SPRINT ERKEN BİTER", taralı alan | tam (kapanış hafta sınırında, §7.4 adım 9) | `a4_early` |
| 20 | Öneri: ilk sprint | 1 tasarımcı, 1 geliştirici, kurucu (testçi yok) | kurucu Test satırında, tasarım önden | kısmen: tasarım önden tam; kurucu bugün Geliştirme satırında durur (V4), Test hâli tasarımsız kartla gelir (P13, U1s cevap 2) | `a4_first_sprint` |
| 21 | Öneri: sonraki sprint | 20'nin sonraki planı | önden hazır tasarımlar | kısmen, 20 gibi | `a4_first_next` |
| 22 | Kurucu anahtarı kapalı | 04'ün planı, anahtar kapalı | kurucunun yüzü ve gücü yok, kurucunun kartı planda yok | tam | `a4_six_founder_off` |
| 23 | Kurucunun iki satış görüşmesi | 04'ün planı, kurucunun haftasında 2 satış görüşmesi | taramalar, geliştirme gücü düşük, kırmızı kart, ipucu | D1b indikten sonra tam | `a4_six_meetings2` |
| 24 | Sprint sürerken, term sheet önde | 1. hafta ortası, kurucuya term sheet masası düşmüş | ilerleme, şimdiki an, kurucunun 2. haftasında tarama | D1b sonrası tam | `a4_run_table` |

**A4'te olmayan ama ekranın taşıdığı durumlar** (bugünkü davranış korunur, yeni dil ve yazı tipiyle):

| Durum | Tetikleyici | Görünüm |
|---|---|---|
| Sürüm notu | `SprintSystem.mode() == "release"` | orta sütun bugünkü `_release`; sol ve sağ sütun yeni dilde |
| MVP kapısı | sürüm notunda `release.gate` | bugünkü kapı; saat tutulur (bugünkü) |
| Kimse çalışamıyor | `SprintSystem.capacity() == 0` | gövdede bugünkü boş hâl; başlat basılmaz |
| Tür seçilmedi | `SprintSystem.is_typed()` yanlış | bugünkü tür seçici |
| Karar kâğıdı bekliyor | kartın `decision` alanı dolu | kartın PM yuvasında soranın yüzü ve "?"; tıklanınca Olaylar açılır (bugünkü `decide` eylemi) |

## 6. Etkileşimler

**Tıklama.**
- Kurucu sprintte anahtarı: `SprintSystem.set_founder_in_sprint(on)` (§7.3 V1). Planlamada ve sürüm notunda açık,
  sprint sürerken ve kurucu Ar-Ge'deyken basılmaz.
- Geçmiş: bugünkü yerel durum (`product_tab.gd:242` `_set_ui`).
- Talep satırı: talebin modülünü açar (sol sütunda o modül açılır ve görünür kaydırılır, bugünkü `open_area` yolu).
- Modül satırı: akordeon (bugünkü `area_panel.gd:230` `_on_area_input`).
- Adayın "+"ı: `add` (bugünkü). Tik ve damga basılmaz.
- Plan satırının "→"ı: `send_next`; "×"ı: `remove` (bugünkü). Sonraki sprint kartının "↑"ı: `pull`, "×"ı: `remove`.
- PM yuvasındaki "?": `decide` (Olaylar kâğıdı seçili açar, bugünkü `product_tab.gd:277` `_act`).
- Hedef seçici: menü açar; seçim `pick_goal`; "Hedef yok" seçimi hedefi boşaltır, "Hatalar" D8b'nin hata hedefini seçer
  (D8b modeli, §12). PM'siz ve v1.0'dan önce de açıktır (P14).
- Öneriyi uygula: `apply_lead` (bugünkü). Önerinin adayı yoksa basılmaz.
- Planlamayı devret: `delegate {on: true}`; Planlamayı geri al: `delegate {on: false}` (bugünkü `set_delegate`).
- Sprinti başlat: kart varsa `start`; kart yoksa `skip` (KR26). Ekip yoksa basılmaz.
- "+{n} talep ▾": kalan talepleri açar, yeniden basınca kapanır (yerel durum, kayda girmez).

**Üstüne gelme.**
- Kart satırı: zemin vurgusu ve sol çizgi; planlamada "→" ve "×" görünür; zengin ipucu (§4.8).
- Adayın "+"ı: o adayın hayaleti panoda (EKLENEBİLİR altında) ve kapasitede belirir; imleç ayrılınca kalkar. Hesap
  üstüne gelme başına bir kez yapılır ve sayfanın bir sonraki kurulumuna kadar aday kimliğiyle saklanır (§7.5).
- Aşama çubuğu, bekleme, gölge, tarama, rozet, yüz, çip: §11.2'deki ipucu.

**Anahtarlar.** Kurucu sprintte ve Geçmiş `CheckButton`; Devret artık anahtar değil düğmedir.

**Klavye.** Yeni kısayol yok. Bütün yeni düğme ve anahtarlar `FOCUS_NONE` (Boşluk hız tuşudur; bugünkü kural).
Esc pencereyi kapatır (bugünkü `WindowLayer`).

**Kaydırma.** Sol sütun, pano gövdesi ve sağ sütun ayrı kayar. Sayfanın her yeniden kurulumunda üçünün
`scroll_vertical`'ı korunur (koşan sprint her gün ve her durum değişikliğinde yeniden kurulur).

**Saat akarken.** Sprint sürerken `EventBus.hour_changed` (`game_state.gd:377`) her oyun saatinde yalnız şimdiki an
çizgisini, koşan çubukların dolgusunu ve yüzlerini, kapasitenin "yapılan" dolgusunu ve ilerleme yüzdesini günceller;
sayfa yeniden kurulmaz (§7.4 adım 11).

## 7. Veri sözleşmesi

### 7.1 Sözleşmenin biçimi

Sekme yalnız `ProductModel.live()` (`product_model.gd:110`) Dictionary'sini çizer (bugünkü ilke). Bugünkü `center`,
`next`, `areas`, `customers` anahtarları bu görevde aşağıdaki biçime geçer; okuyucusu kalmayan alan aynı commit'te
silinir. Yeni biçimin başlığı `product_model.gd:16-91`'deki yorum bloğunun yerine yazılır.

```
model = {
  header, versions, ui, overview                       # bugünkü, değişmez
  quarter: {state, goal: {area_id ("" = hedef yok, "bugs" = Hatalar), area_name}, columns, q, year, pos, total}
           # goal, q, year, pos, total PM'siz de dolar; state ("locked_no_pm" | "open") yalnız ÇEYREK sekmesinin
           # kilidi ve columns'un varlığıdır (bugünkü `_quarter` `product_model.gd:420` PM yokken erken döner, düzelir)
  founder: {on, locked: "" | "running" | "rnd", rnd_text}
  requests: null (B2C) | [request]
  modules: [module]
  center: {mode, sprint, week, now_at, capacity: [stage_row] or null, crew: {...} or null, suggest: {...} or null,
           cards: [row], candidates: [row], close_at, progress: {done, total} or null, can_start, start_reason,
           delegate: {on, pm: person} or null, mvp: {...} or null, release (bugünkü), team_empty}
  prep: {pms: [{person, stars, cards: [ad], preparing}]}
  next: {sprint, load: [{stage, carried, planned, team}], carried: [{card, stage, effort}], cards: [next_card]}
}
```

Ayrıntılı alan listesi §7.2'nin "Model alanı" sütunudur. `person` = `{id, name, role_text, look, stars, founder}`.

### 7.2 Öğe başına veri kaynağı

| Öğe | Model alanı | Kaynak (sistem.fonksiyon, yol:satır) | Durum |
|---|---|---|---|
| Kurucu anahtarı | `founder.on` | `GameState.founder_in_sprint` `game_state.gd:190` (D1b) | D1b'de var, commit'siz |
| Anahtarın kilidi | `founder.locked` | `SprintSystem.mode()` `sprint_system.gd:564`; kurucunun Ar-Ge işi `CharacterRegistry.get_founder().assigned_job_ids.has(HRConstants.JOB_RESEARCH)` (bugünkü `product_model.gd:303`) | var |
| Talepler | `requests[]` {customer, card_id, card_name, module_id, value, due_text, soon, planned, tip} | `GameState.product.requests` (bugünkü `_customers` `product_model.gd:226`), müşteri adı `SprintCatalog.customer_name` `sprint_catalog.gd:805`, söz `SprintCatalog._promises_on` `sprint_catalog.gd:791` (açılır), kart adı `SprintCatalog.step_name` `:677` | var; tarih metni yeni (V2) |
| Modüller | `modules[]` {id, name, mono, planned, open, candidates[]} | `SprintCatalog.areas_for` `:41`, `SprintCatalog.candidates` `:194`, kilit `SprintCatalog.gate_reason` `:290` (kilitliler süzülür) | var |
| Adayın aşama şeridi | `candidates[].parts` [tasarım, geliştirme, test] | kartın `need` (`SprintCatalog.new_card` `:250`) | var |
| Sprint başlığı | `center.sprint`, `center.week` | `SprintSystem.sprint_number` `:586`, `SprintSystem.week` `:613` | var |
| Çeyrek göstergesi | `quarter.q`, `year`, `pos`, `total` | `GameState.product.quarter.start_sprint` (`sprint_system.gd:188-191`), `SprintSystem.sprints_in(cfg("quarter_weeks"))` `:608`; q ve yıl `GameState.get_date_dict` `game_state.gd:680` ile ürün çeyreğinin ilk haftasının tarihinden | var; hesap yeni (V3) |
| MVP rozeti | `center.mvp` | `SprintSystem.mvp_eta` `:795`, bugünkü `mvp_line` (`product_model.gd:329`) | var |
| Hedef | `quarter.goal` | `SprintCatalog.quarter_goal` `:541`; boş hedef ve PM'siz seçim D8b'nin modeli (§12) | D8b modeli |
| Kapasite satırı | `center.capacity[]` {stage, work, team, done, out, out_inside, streak, people[], cluster, away[]} | iş: zaman ekseninin aşama eforları (§7.4); ekip: §7.3 E2 (zaman ekseninin `people` parçaları ve `SprintSystem.team()` `:695` puanları); yapılan: koşan sprintte zaman ekseninin ara değeri; taşan: zaman ekseninin `out`'u; süreklilik: D2b'nin taşan aşama kaydı | iş, ekip var; satır aşaması ve uzakta listesi yeni (V4, V5); süreklilik D2b |
| Kişinin doluluğu | `people[].busy` | zaman ekseni `people` (§7.4 adım 12) | yeni (V6) |
| Kişinin yıldızı | `person.stars` | `HRConstants.stars_for(HRSystem.skill(c, alan))` `hr_constants.gd:263` (Atlas'ın okuduğu yer) | var |
| Seçilemeyen kişi | `away[]` {person, reason: training/leave/research/meetings} | eğitim: `Character.status == HRConstants.STATUS_TRAINING` (`character_registry.gd:152` `begin_training` yazar); izin: `STATUS_ON_LEAVE`; araştırma: `assigned_job_ids` içinde `HRConstants.JOB_RESEARCH`; görüşme: kurucu, `GameState.founder_sprint_pay == 0` (`game_state.gd:188`, D1b). Bugün `team()` eğitim ve izindekileri `get_active_employees` (`character_registry.gd:52`, yalnız `STATUS_ACTIVE`) ile, Ar-Ge ve yalnız Destek'tekileri `_share == 0` ile dışarıda bırakır | yeni okuma (V5) |
| Öneri | `center.suggest` {amount, cards: [{name, done, effort}], can_apply} | `SprintCatalog.lead_suggestion` `:477`; miktar = önerinin kartlarının `SprintSystem.plan_outcome(sprint + öneri)` `:765` içindeki `done` toplamı; aday yoksa miktar = planın boş puanı (`spare`) ve düğme kapalı | var; toplama yeni (V7) |
| Kart satırı | `cards[]` {id, kind, name, effort, raw_effort, module, fix_text, slot, pm, ask, risk, risk_raw, late, founder, buttons, stages[]} | kart `GameState.product.cards`; düğme `ProductModel.BUTTONS` (`:98`, KR25'e göre güncellenir); PM ve hazırlık D4; risk D3; kurucu ve geç §7.4 | §7.3 |
| Aşama çubukları | `cards[].stages[]` | §7.4 zaman ekseni | yeni (§7.4) |
| Erken kapanış | `center.close_at` | §7.4 adım 9 | yeni |
| Şimdiki an | `center.now_at` | §8.4 | yeni |
| İlerleme | `center.progress` | `SprintSystem.done_points` `:671` + zaman ekseninin ara değeri; toplam `SprintSystem.used` `:632` | var + ara değer |
| Başlat | `center.can_start`, `start_reason`, `start_skips` | `SprintSystem.capacity` `:623` > 0 ve kip `plan` (kartsız da açık, KR26); `start_skips` = `SprintSystem.can_start()` `:755` yanlış ama kapasite var; gerekçe bugünkü (`product_model.gd:306-309`, `PRODUCT_START_NEED_CARD` kolu silinir) | değişir (V8) |
| Devir | `center.delegate` | `GameState.product.delegate`, `SprintCatalog.quarter_pm` `:533`, `SprintSystem.delegated` `:582` | var |
| Hazırlık | `prep.pms[]` | D4'ün kart başına hazırlayan PM'i ve hazırlık ilerlemesi. D1 bu alanları açmadı (commit `d325f885`: "Yeni alan yok"); D4 kartın varsayılanlı alanı olarak yazar (D v2 §0 kuralı: `get` ile okunur, şema açmaz) | D4 |
| Sonraki sprint | `next.cards[]` {name, effort, parts, ahead: {stage: {done, people}}, prep: {pm, done}, start_ahead} | `GameState.product.next.cards`, `SprintSystem.ready_share` `:664`, zaman ekseninin `ahead`'i (§7.4) | var + yeni |
| Aşama yükü | `next.load[]` | devreden: zaman ekseninin `out`'u; planlı: sonraki kartların kalan aşama ihtiyacı (önden yapılan düşülür); ekip: kapasite satırının ekibi | yeni toplama (V9) |
| Kurucunun görüşme günleri | `stages[].meet[]` {from, to, kinds: [..], week} | `GameState.founder_sprint_pay` (D1b), görüşme defteri (V10) | D1b + V10 |
| Karar kâğıdı | `cards[].ask` {person, item} | kartın `decision` alanı, bugünkü `_decision()` (`product_model.gd`), konuşan `SprintSystem._speaker` `:1239` | var |

### 7.3 Eksik veri ve kimin yazacağı

**Bu görevin yazdıkları (U1).** Hepsi okuma yüzeyidir; motorun sonucunu değiştirmez.

| # | Ne | Nerede | Not |
|---|---|---|---|
| V1 | `SprintSystem.set_founder_in_sprint(on: bool)`: planlama ve sürüm notunda `GameState.set_founder_in_sprint` (`game_state.gd:439`, D1b) çağırır, `_changed()` ile `product_state_changed` yayar ve `sync_plan_hold` çalışır | `sprint_system.gd` | WRITE-THROUGH: arayüz `GameState`'e doğrudan yazmaz |
| V2 | Tarih metni: talebin ve sözün son sprinti, ürün çeyreğine göre "bu çeyrek" (son sprint ≤ çeyreğin son sprinti), "gelecek çeyrek" (sonraki çeyreğin içinde), yoksa "{q}. çeyrek" | `product_model.gd` | söz varsa sözün tarihi, yoksa talebin `due_sprint`'i |
| V3 | Çeyrek göstergesi: `pos = sprint − start_sprint + 1`, `total = sprints_in(quarter_weeks)`, q ve yıl ürün çeyreğinin ilk sprintinin başlangıç tikinin tarihinden | `product_model.gd` | tek çeyrek kavramı ekranda ürün çeyreğidir; hedef ve tarih metni de onu okur |
| V4 | Kişinin satır aşaması (yüzün durduğu satır): rolün ana alanı `sprint.json` `role_areas` tersinden (tasarım → Tasarım, mühendislik → Geliştirme, test → Test); ürün rolü (PM) kapasitede satır almaz, Hazırlık sütunundadır; kurucu: ekip yalnız kurucuysa paylaşılan satır, değilse zaman ekseninde en çok çalıştığı aşama, hiç çalışmıyorsa Geliştirme | `product_model.gd` | oluk E2'dedir (satırla değil işle hesaplanır) |
| V5 | Seçilemeyenler listesi: eğitimde, izinde ve Ar-Ge'deki çalışanlar nedeniyle; kurucu payı 0 ise ve anahtar açıksa kurucu "görüşmede". Yalnız Destek'teki kişi listeye girmez (sprint dışı, yalnız ekip rozetinin sayısı) | `SprintSystem.away()` (yeni, salt okur) | KR17 |
| V6 | Zaman ekseni üreticisi, birinci sürüm | `SprintSystem.timeline()` (yeni) + `_work`'e isteğe bağlı kayıt parametresi | §7.4; sonucu değiştirmez (kapı: probe bayt eşit) |
| V7 | Önerinin miktarı ve kart listesi | `product_model.gd` | `lead_suggestion` ve `plan_outcome` okur |
| V8 | Kartsız başlat: modelin `can_start`'ı kartsız planda da doğru (kip `plan` ve ekip varsa); başlat eylemi `start_skips` ise `skip`, değilse `start` | `product_model.gd`, `product_tab.gd:277` `_act` | `SprintSystem.can_start` (`:755`) değişmez; model kendi koşulunu kurar |
| V9 | Sonraki sprintin aşama yükü | `product_model.gd` | |
| V10 | Görüşme defteri: kurucunun oturduğu her görüşmenin türü (`sales`, `vc`, `table`) ve günü; donan payın kalemleri | `GameState` (iki alan: o haftanın görüşmeleri ve donan payın görüşmeleri). Yol bugün şudur: oturumu kapatan `TimeManager.advance_hours(n, true)`'yu çağırır (`time_manager.gd:172`), o da `GameState.add_founder_meeting_hours` (`game_state.gd:421`) yazar. Çağıranlar: `sales_meeting_system.gd:119` `close`; `vc_pitch_system.gd:135` (saati `_close_sitting` `:140` borçlanır, `:124` yarım oturum); `term_sheet_table_system.gd:574` (borç `_close_sitting` `:579`). Tür, `advance_hours`'un `meeting` parametresiyle (bool yerine tür adı, boş = görüşme değil) taşınır; ikinci bir yazma yolu kurulmaz. Haftalık liste `start_work_week` (`game_state.gd:430`) ve koşu sıfırlamasında (`:845`) boşalır, `freeze_founder_sprint_pay` (`:435`) donan listeye kopyalar | D1b bunları commit'inde taşıyorsa U1 yazmaz. Yeni alan anlamlı varsayılanla (boş dizi) okunur, şema açmaz (D v2 §0); `SaveCodec` GameState değişkenini kendisi bulur |
| V11 | Kartın sprint başındaki aşama ilerlemesi (`progress_at_start`, üç sayı): `_begin`'de yazılır, önden hazırlanıp sonraki sprinte giren kartta o anki ilerleme | `sprint_system.gd` `_begin` (`:141`) | koşan sprintte "önden yapılmış" payı ve "yapılan / toplam"ı kurar; eski kayıtta yoksa `progress` okunur |

**D'nin model adımlarından gelenler.** Veri gelmeden öğe çizilmez (KR23); arayüz adımı o veriyi okuyan kodu ancak veri
inince yazar.

| Öğe | Veri | Üretici |
|---|---|---|
| Kurucu anahtarı, donan pay, görüşme payının günü | `founder_in_sprint`, `founder_sprint_pay`, `TimeModel.MEETING_DAYS` | D1b (çalışma ağacında) |
| Süreklilik rozeti, sıcak satır, taşma ipucunun sayaç satırı | taşan aşama ve ardışık sayı (sürüm kaydı) | D2b ("taşan aşamanın kaydı") |
| Hata göstergesi | kartın beklenen hatası H, hazırlıksız hâli H0 | D3 ("beklenen hata işlevi", tohumsuz) |
| PM yuvası, gölge, Hazırlık satırları, sonraki kartın "hazırlanıyor / hazır"ı, görünen efor | kart başına hazırlayan PM, hazırlık ilerlemesi, PM hız kazancı g | D4 (kural A, hız %10 ile %25) |
| "Hedef yok", "Hatalar", PM'siz hedef, devretin PM şartı | `quarter_goal()` boş dönebilir, `pick_goal("")`, PM'siz `pick_goal`, hata hedefi | D8b'nin modeli (§12) |
| Önerinin sırası | `lead_suggestion()` | bugünkü; D8a inince onun altı basamağı (arayüz değişmez) |
| Gereksinim "≥{n}★", aşama kişi tavanı, adlı bekleme nedeni, gün düzeyinde zaman, merdivenin önden geliştirmesi | olay düzeyli motor | D2a (park; §7.4 ikinci sürüm) |

**Görünen efor (E1).** Kartın ekrandaki eforu ve aşama sayıları = kalan aşama ihtiyacı ÷ (1 + g); g, kart PM'in
hazırladığı kartsa D4'ün hız kazancı, değilse 0. Hazırlanmamış hâli (gölgenin ve "efor {önce} yerine {şimdi}"in
"önce"si) g = 0 ile aynı sayıdır. Kapasite dolgusu, taşma, devreden ve sonraki sprintin yükü aynı birimle yazılır.
Ekip gücü (oluk) kişilerin ham puanıdır. Bu bir gösterim kuralıdır; motorun hesabı değişmez. İlerleme yüzdesi ve
ipucu da bu birimle yazılır.

**Aşamanın oluğu ve taşmaları (E2).** Bugünkü motorda kişi kendi rolü dışındaki aşamada da çalışır (uymayan iş yarı
hızla, `no_role_speed` 0,5; testçi yokken testi geliştirici yapar; kurucu her aşamada çalışır; PM D4'e kadar ilk fazda
çalışır). Satır başına "o satırdaki kişilerin puanı" oluğu bu işleri yanlış satıra yazar. Kural:
- Oluk(s) = zaman ekseninde s aşamasına giden iş (bütün kişilerin s'deki parçalarının ürettiği efor, önden iş hariç) +
  satırı s olan kişilerin sprintin kalan haftalarında hiçbir karta harcanmayan puanı. Her kişinin kapasitesi böylece
  aşamalara bir kez bölünür; üç oluğun toplamı ekibin kapasitesini aşmaz.
- Dolgu(s) = sprintin kartlarının s'deki kalan ihtiyacı (E1 birimi; önden yapılan düşülür).
- Dış taşma = en çok 0 ile dolgu − oluk; iç taşma = zaman ekseninin s'deki `out` toplamı − dış taşma (bekleme yüzünden
  kalan pay). Rozetin "+{n}"i ikisinin toplamıdır, yani `out` toplamıdır (A20).
- Kişinin yüzü V4'ün satırında durur; doluluk çizgisi kişinin bütün aşamalardaki parçalarıdır (§7.4 adım 12).
- Araştırma kartının işi hiçbir satıra yazılmaz; onu yapanın o süresi oluklardan düşer (meşguldü).

**Hata göstergesi (R1).** Doluluk = H ÷ H_ref, H_ref = D3'ün formülüyle 40 eforluk, gereksinimi 5, Δ = 0, PM'siz,
TİTİZ'siz kartın beklenen hatası (standart bir kartın ulaşabileceği en yüksek değer; yeni sabit yok). Düzey sözcüğü
doluluğun üçte birlik dilimleri: düşük, orta, yüksek. Dilimler [WORKING]; görsel kabulde Erdem'e gösterilir, değişirse
yalnız bu sınırlar değişir.

**D1b ile birim uyuşmazlığı (bulgu, D'nin işi).** Erdem'in kararı satış görüşmesi 1 gün, yatırımcı 1 gün, term sheet
masası 2 gün; 1 gün haftanın beşte biridir (sprintin onda biri). Çalışma ağacındaki taslak `TimeModel.MEETING_DAYS =
{"sales": 0.25, "vc": 0.25, "table": 0.125}` (`time_model.gd:15`) iş gününün çeyreği ve sekizi olarak 2, 2 ve 1 saat
üretir; pay `founder_meeting_share` = saat ÷ 40 (`game_state.gd:426`, `TimeModel.WEEK_WORK_HOURS` `time_model.gd:12`)
olduğundan bir satış görüşmesi haftanın %5'ini yer, Erdem'in %20'sini değil. Arayüzün kuralı: haftanın görüşme günü =
(1 − `founder_sprint_pay`) × 5. Böylece arayüz hangi değer inerse onu doğru çizer; ama U1'in kapısı bir satış
görüşmesinin 1 günlük tarama çizdiğini sınar (§14 A17). Değer D1b commit'inden önce Erdem'in 1 / 1 / 2 gününe göre
düzeltilmezse U1 o kapıda durur ve yardımcı yönetmene gelir.

D1b'nin düzeltirken bilmesi gereken iki kod gerçeği (denetim, 2026-10-23):
- Aynı sabit iki iş yapar. `TimeModel.meeting_hours(kind)` (`time_model.gd:26`) hem oturumun saatte kapladığı süreyi
  (`advance_hours` saati o kadar ileri koşar) hem de kurucunun payından düşeni verir; `advance_hours` süreyi kurucunun
  mesai sonuna kırpar (`time_manager.gd:174-176`) ve `WorkHoursSystem.sitting_open(hours)` (`work_hours_system.gd:57`)
  oturumu ancak o kadar saat kalmışsa açar. `MEETING_DAYS`'i yalnız 1 / 1 / 2 güne çekmek (8, 8, 16 saat) term sheet
  masasını hiç açılmaz yapar ve satış görüşmesini yalnız mesai başında mümkün kılar.
- Ekrandaki saatin mesai penceresi (varsayılan 8 saat) bir haftadır; payın paydası 40'tır. Bir iş günü = mesai ÷ 5 saat.
Türetilen kural (D1b'nin işi, arayüz yalnız payı okur): pay kaybı defterdeki günlerden yazılır (gün ÷ 5, saatten değil),
oturumun saatteki uzunluğu bugünkü gibi kalır. Erdem'in kararı sprint zamanı içindir ("2 haftalık sprintten bir gün");
saatin bir gün atlaması kararlaştırılmadı.

### 7.4 Zaman ekseni: kaynak, sözleşme, geçiş

**Soru:** kartın aşamalarının başlangıcı, bitişi ve bekleme nedeni D'nin planlayıcısından mı, bugünkü `_play_out`
tahmininden mi gelecek?

**Cevap:** Tek bir sözleşme, iki üretici. Arayüz yalnız `SprintSystem.timeline()`'ın çıktısını okur. Birinci üretici
bu görevde bugünkü haftalık motorun oynatmasından (`_play_out` `sprint_system.gd:1162`) kurulur; D2a inince olay düzeyli
motor aynı çıktıyı doğrudan yazar ve birinci üreticinin yerleşim kodu D2a'nın commit'inde silinir. Arayüz iki üreticide
de değişmez.

**Neden şimdi D2a beklenmiyor:** D2a park (D'nin K4, K6, K7 soruları ve merdiven açık; D v2 §0b, §0c). Bugünkü motor tahmin ile
sonucu eşit tutar (`--sprint-probe` PRED = CLOSE) ve haftalık dökümü kişi kişi, kart kart ve aşama aşama bilir; çizim
için gereken bilgi oradadır. Eksik olan yalnız hafta içindeki konumdur; birinci üretici onu aşağıdaki kuralla, motorun
sonucunu değiştirmeden kurar.

**Sözleşme** (zaman birimi: sprintin başından hafta, kesirli; 2,0 sprint çizgisi):

```
timeline = {
  start: 0 | week-1,                    # planlamada 0; koşan sprintte haftanın başı
  close_at: float,                       # sprintin kapandığı an (< 2,0 ise erken)
  team: {stage: float},                  # satır başına haftalık puan (U1, 2026-10-24)
  outcome: {...} | null,                 # planlamada plan_outcome ile aynı oynatmanın sonucu
  cards: {card_id: {
    finishes: bool, founder: bool, late: bool,
    h, h0,                               # beklenen hata ve PM'siz hâli (R1; U1 cevap 9)
    prep: {by: id or "", gain, done},    # D4 hazırlığı
    stages: [{stage: "design"|"dev"|"test"|"product", fix: bool, need, need_raw, pre, in_sprint, out,
              start, end,                # -1: bu eksende aralığı yok
              before: bool,              # true: koşan sprintte eksenin başından önce bitti (start = end = -1)
              done0,                     # koşan sprintte eksenin başından önce yapılmış iş
              out_from, out_to,          # sprint dışı payın taralı alanı (adım 7)
              people: [id], waits: [{from, to, person: id or "", role, busy: {card, stage} or {}}],
              meet: [{from, to, kinds: [..], week}],
              pieces: [{from, to, work, people: [id]}]}]}},   # koşan sprintin ara değeri için
                                         # fix: true olan dördüncü girdi Test'ten sonra gelir (D3 düzeltme işi)
  ahead: {card_id: {prep: {by: id or "", done}, <stage>: {done, people: [id], start}}},   # prep: U1 cevap 10
  people: {id: {busy: 0..1, unspent, row, pieces: [{from, to, card, stage, ahead: bool}]}},   # ahead: önden iş, doluluktan düşer
}
```

**Birinci üretici: kural (adım adım).** Girdi bugünkü oynatmanın girdisidir: kartların kopyaları, sonraki sütunun
önden hazırlanan kopyaları (`_ahead_cards` `:1603`), `team()`, kalan haftalar (`weeks_left` `:618`).

1. Her hafta k için motorun kendi atamasını koş: `_assign(cards, people, ahead)` (`:1112`).
2. Harcamayı motorun kendi yoluyla yap: `_play_out`'un döngüsü aynen; tek fark `_work` (`:1145`) isteğe bağlı bir kayıt
   dizisine her faz için (aşama, iş, harcanan bütçe) ekler. Varsayılan çağrılar kayıtsızdır; motorun sonucu bayt
   bayt aynı kalır.
3. Kişinin hafta içi zamanı: kişinin her parçası, haftalık puanına oranla ardışık bir aralık alır
   ([t, t + harcanan ÷ puan], t sıfırdan başlar ve parça parça ilerler; harcama sırası motorun sırasıdır).
4. Kartın hafta içi aralığı: kartın o haftadaki parçalarının en erken başlangıcı ile en geç bitişi. Kartın aşamaları bu
   aralığa faz sırasıyla, o haftaki işleriyle orantılı genişlikte arka arkaya yerleşir. Böylece bir aşama, aynı
   kartın önceki aşaması bitmeden başlamaz ve satırda üst üste binme olmaz.
5. Aşamanın haftalar boyunca parçaları birleşir (bir haftanın sonu 1,0, ötekinin başı 0,0 ise bitişiktir).
6. Bekleme: aşamanın hazır olduğu an (ilk aşamada sprintin başı, sonra önceki aşamanın bitişi) ile başladığı an
   arasındaki boşluk. Neden: o aşamada sonradan çalışan ilk kişi ve o kişinin boşluğun başındaki parçası (kart ve
   aşama); o rolde kimse yoksa rolün çoğulu.
7. Sprint dışı pay: son haftadan sonra kalan aşama ihtiyacı `out`. Çizimi sprint çizgisinden (ya da aşamanın
   bitişinden, hangisi sonraysa) başlar; genişliği out ÷ (o aşamada son çalışanların haftalık puanı; kimse
   çalışmadıysa aşama satırının haftalık ekibi), en çok 0,6 hafta; ekip 0 ise 0,6'nın tamamı taralı.
8. Önden yapılmış iş (`pre`): planlamada kartın o anki aşama ilerlemesi, koşan sprintte `progress_at_start` (V11).
9. Erken kapanış: kartların hepsi k. haftada biterse motor o haftanın sonunda kapanır (`_end_week` `:1069`,
   `_finished` `:1609`); `close_at = start + k + 1`. Önden iş o haftadan sonra durur (motorun `ahead = []` kuralı).
10. Kurucunun görüşme günleri: k. haftanın günü (1 − o haftanın payı) × 5; planlamada ve tahminde bütün kalan haftalar
    donan payı alır (D1b kuralı 2). Tarama, kurucunun o haftaki ilk parçasının başından gün × 0,2 hafta uzunluğunda,
    hafta sonunda kesilir; kalemler görüşme defterinden (V10).
11. Koşan sprint: motor işi hafta sonunda döker; kartların ilerlemesi haftanın başındaki hâlidir. Zaman ekseni koşan
    sprintte de haftanın başından oynatılır (atama o haftanın atamasıdır, sonuç `_end_week`'in yapacağıyla aynıdır).
    Ekranın "yapılan"ı = haftanın başındaki ilerleme + `pieces`'tan şimdiki ana kadar düşen iş (parça içinde doğrusal).
    Aşamanın hâli: bitişi ≤ şimdi ise bitti; başlangıcı ≤ şimdi ise sürüyor; değilse bekliyor. Şu an çalışanlar:
    kişinin parçası şimdiki anı içeren kart ve aşama (kişi aynı anda tek yerdedir).
12. Kişinin doluluğu: kişinin sprintin kartlarındaki parçalarının toplam süresi ÷ kalan haftalar (önden iş hariç).
13. Kurucu ve geç: kart, kurucunun en az bir parçası varsa `founder`; `founder` ve sprintte bitmiyor ve sprintte
    kurucunun görüşme günü varsa `late` (kırmızı, KR12). Bitmeyen öbür kartlar normal taşmadır (turuncu).

**İkinci üretici: D2a.** D2a'nın olay düzeyli motoru (D v2 §1, D2a satırı) aynı sözleşmeyi yazar: aşamanın gerçek
başlangıç ve bitiş anı, kişi tavanı ve gereksinim, adlı bekleme nedeni, görüşmenin gerçek anı, merdivenin önden
geliştirmesi. Geçiş kuralları:
- D2a'nın commit'i birinci üreticinin 3., 4. ve 6. adımlarının yerleşim kodunu ve `_work`'ün kayıt parametresini siler.
- Sözleşmenin alan adları değişmez; D2a yeni bir alan isterse alan eklenir, arayüz adımı açılır.
- D2a'nın kapısına U8'in kareleri ve §14'ün zaman ekseni maddeleri (A10 ile A14) eklenir.
- D2a'nın haftanın sınırını şirketin mesai başlangıcına taşıması (§8) bu sözleşmeyi değiştirmez.

**Değişmezler** (smoke `sprint_timeline_matches_play_out`, falsification ile; §14):
- Z1 Kart başına sprint içi işlerin toplamı `plan_outcome(...).cards[id].done`'a eşit (EPS içinde).
- Z2 Aynı kartta aşama i+1'in başlangıcı aşama i'nin bitişinden önce değil (ihtiyacı 0 olan aşama hariç).
- Z3 Bir satırda ilk öğeden son öğeye kadar her boşluk bir beklemeyle kapalı.
- Z4 Hiçbir kişi şimdiki anda iki kartta değil.
- Z5 Koşan sprintte hafta sınırında ekranın "yapılan"ı motorun gerçek ilerlemesine eşit.
- Z6 `--sprint-probe` 1, 3, 6, 12, 25, 50 kişide `^SPRINTPROBE` satırları U1'den önceki HEAD ile bayt eşit.
- Z7 Üç aşamanın oluğu (E2) toplamı ekibin sprint kapasitesini aşmaz; testçisiz planda Test oluğu 0'dan büyüktür.

Yeni smoke vakası CLAUDE.md §10'un "yalnız çekirdek mantık" şartına şu gerekçeyle girer: ekranın her sayısı bu
üreticiden okunur ve üretici motorun oynatmasına bağlıdır; ayrılık oyuncuya yanlış plan gösterir ve görsel kabul onu
yakalayamaz (sayı doğru görünür).

### 7.5 Süre

- D'nin bütçesi geçerlidir (D v2 §0): oyuncunun tıklamasında plan ekranının tam kurulumu ≤ 100 ms, 50 kişilik dünyada.
  Ölçü `--sprint-probe=...:team=50:planms=1` `PLANMS` satırları; zaman ekseni ve öneri miktarı ölçünün içindedir.
- Adayın "+"ına gelince yapılan hayalet hesabı (bir `plan_outcome` ve zaman ekseni) ≤ 100 ms; sonuç aday kimliğiyle
  sayfanın bir sonraki kurulumuna kadar saklanır.
- Saatlik güncelleme (§6) yeniden hesap yapmaz; saklanan parçaları okur.
- Bütçe aşılırsa D'nin kuralı: önce hesap karelere bölünür (oynanış değişmez); o da yetmezse adım commit'ten önce durur.
  Neyin ertelendiği, bekleyen "+"ın çizimi ve ölçünün iki satırı U1 cevap 19'dadır (U2'de).
- Taban sıkışık: D0a'da 50 kişide ekranın tam kurulumu ortanca 68 ile 74 ms, en çok 96 ms; `mvp_eta` tek başına 36 ile
  45 ms (D v2 §5). Yeni yük (zaman ekseni, öneri miktarı) bu tabanın üstüne biner. Bu yüzden: (1) zaman ekseni
  `plan_outcome`'un oynatmasından ayrı ikinci bir oynatma koşmaz; `live()` kurulum başına tek oynatma yapar ve ikisi onu
  okur (`plan_outcome`'un sonucu bayt aynı kalır, Z6); (2) aşılırsa ilk çare D'nin notundaki gibi `mvp_eta`'dır
  (kurulum başına bir kez, durum değişmeden yeniden hesaplanmaz); (3) sonra karelere bölme. Ölçü U1'de önce (U1'siz
  HEAD) ve sonra alınır, ikisi de rapora girer.

## 8. Zaman

**8.1 Planlamanın göründüğü an (KR11).** Erdem'in kararı: plan şirketin mesai başlangıcında
(`WorkHoursSystem.start_hour()`, varsayılan 09:00) görünür. Bugün sprint gece 00:00'ın günlük tikinde kapanır
(`TimeManager._step_hour` `time_manager.gd:144` → `_dispatch_daily_tick` `:383` → `SprintSystem.daily_tick`
`sprint_system.gd:27`), gecenin kalanı tek toplu adımda 08:00'e (`TimeModel.WEEK_START_HOUR`) koşar (`skip_night`
`time_manager.gd:183`), planlama tutuşu toplu adım bitince alınır (`sync_plan_hold` `sprint_system.gd:1583`,
`clock_batch_ended`'e ertelenir). Oyuncu planı bugün 08:00'de, saat durmuşken görür; mesaisi 09:00'da başlayan şirkette
bu, kararın bir saat öncesidir. Erdem'in cevabı (2026-10-23, "onu düzeltelim"): planın görünme anı şimdi taşınır. U5'te planlama tutuşu (`sync_plan_hold`) gece toplu adımı 08:00'de bitince hemen değil, saat şirketin mesai başlangıcına (`WorkHoursSystem.start_hour()`) gelince alınır; 08:00 ile mesai başlangıcı arasında saat bugünkü gibi akar (ofis boş). Sprintin kapanışı, kâğıt zarı ve atama hesabı bu görevde değişmez; haftanın sınırının taşınması D2a'nındır (8.2). Mesai başlangıcı 08:00 olan şirkette davranış bugünküyle aynıdır.

**8.2 Bilinen kenar.** Gece bir acil durum kartı toplu adımı 08:00'den önce durdurursa (`hold_clock("incident")`) Ürün
penceresi o gece açılırsa planı gece saatinde gösterir. Çözümü D2a'dır: haftanın sınırı (kapanış, kâğıt zarı, atama)
şirketin mesai başlangıcına taşınır ve plan orada kurulur (D v2 §0c ve §1 D2a satırı, beş madde). Bu PRD bu kenarı
çözmez; D2a'nın kapsamıdır (P12).

**8.3 D1b'nin dondurma kuralıyla uyum.** Kurucunun sprint payı hafta dönerken donar
(`GameState.freeze_founder_sprint_pay` `game_state.gd:435`; çağıranlar `sprint_system.gd` `daily_tick` ve `_end_week`).
Arayüz yalnız donan payı okur: planlamada iki haftanın taraması aynı donan paydır (tahmin onu bütün kalan haftalara
uygular), hafta içinde oturulan görüşme o haftanın taramasını değiştirmez, sonraki hafta dönünce görünür. Kurucu payı
0 ise kurucu o hafta ekipte yoktur ve kişi dizisinde "görüşmede" görünür (D1b kuralı 3). D2a sınırı mesai başlangıcına
taşıyınca dondurma orada olur; arayüzün okuduğu alan aynıdır.

**8.4 Şimdiki an.** `now_at = (SprintSystem.week() − 1) + kesir`; kesir = (günün saati − şirketin mesai başlangıcı) ÷
(mesai bitişi − başlangıç), 0 ile 1 arasına kırpılır (`WorkHoursSystem.start_hour` `work_hours_system.gd:100`,
`workday_end` `:126`, günün dakikası `TimeManager.day_minute`). Mesai öncesi 0, gece 1.

**8.5 Gün.** Oyunda gün yoktur (KR24). Arayüzde 1 gün = 0,2 hafta yalnız görüşme taramasının uzunluğudur; ipuçları hafta
yazar. Üst barda gün adı park (P2).

## 9. Tipografi ve tema

### 9.1 Archivo bütün oyuna (U0, ayrı adım)

Erdem: "Sprint Ekranı A'nın fontu (Archivo) bütün oyuna yayılacak" (2026-10-22). U0 sprint ekranından bağımsızdır ve
önce iner; böylece U2 ile U6'nın kareleri son yazı tipiyle çekilir.

**Ne değişir.** Koyu ailenin (Menajer, `menajer_theme.tres`) iki sans ailesi Archivo'nun değişken yüzüyle (genişlik 62
ile 125, ağırlık 100 ile 900) değişir: Barlow Condensed (`build_theme.gd:30-31`) ve IBM Plex Sans ile Plex Sans
Condensed (`:25-29`). Source Serif 4 (`:22-24`) kalır.

Üst bar ve haber şeridi her ekranda görünür ve koyu aileden okumaz: krem temanın `Chrome*` varyasyonlarını okurlar
(`build_theme.gd:81-85`: `ChromeValue` Plex SemiBold, `ChromeClock` ve `ChromeAlert` JetBrains Mono). "Bütün oyun"
kararı (KR2) bunları da kapsar: U0 `Chrome*` varyasyonlarının yüzünü Archivo'ya çevirir (saat ve sayılar `d_num` gibi
`tnum` açık); renkleri ve boyutları değişmez. JetBrains Mono yalnız krem ailenin `Chrome*` dışındaki varyasyonlarında
kalır. Gazete (`PaperPanel`, `PAPER_*`) kendi yüzünü korur (CLAUDE.md §7 "tek ada"). Öbür ekranların ton işi (ikon,
renk, portre; Erdem 2026-10-23 "yalnız ton değişir") ayrı görevdir ve yazı tipini yeniden yapmaz: yazı tipinin tek
sahibi U0'dır. CLAUDE.md §7'nin yazı tipi cümlesi ve "JetBrains Mono yalnız krem ailede" cümlesi U0'ın commit'inde
güncellenir.

**Dosya.** `assets/fonts/archivo/Archivo[wdth,wght].ttf` (Google Fonts, OFL) ve `OFL.txt`; içe aktarma standardı
bugünkü (`ui_tokens.gd:31`).

**Eşleme** (FontVariation, `variation_opentype` anahtarları tamsayı etiket: `TextServerManager.get_primary_interface()
.name_to_tag("wght")` ve `"wdth"`; dize anahtar sessizce çalışmaz):

| Bugünkü yüz (`assets/fonts/variations/`) | Archivo ağırlık / genişlik | Kullanım (A4) |
|---|---|---|
| `d_cond_b` | 800 / 78 | pencere başlığı ("ÜRÜN") |
| `d_cond_b_caps` | 800 / 78, harf aralığı bugünkü | büyük başlık etiketleri |
| `d_cond_sb` | 650 / 84 | sekmeler |
| `d_cond_sb_caps` | 650 / 110, harf aralığı %10 | göz başlıkları ("KAPASİTE", "MODÜLLER") |
| `d_sans_reg` | 500 / 100 | gövde |
| `d_sans_med` | 500 / 100 | gövde (orta ve düz birleşir) |
| `d_sans_sb` | 650 / 100 | vurgulu gövde, kart adı |
| `d_sans_b` | 800 / 100 | sayı vurgusu |
| `d_sansc_reg` | 500 / 87 | dar sütun |
| `d_sansc_caps` | 650 / 87 | dar sütun etiketi |
| yeni `d_wide_b` | 800 / 118 | "SPRINT 14", sonraki sprint başlığı, mono işaret (112) |
| yeni `d_num` | 650 / 108, `tnum` açık | çubuk ve kapasite sayıları, rozetler |

Sayıların hizalı olması için `tnum` (tablo rakamı) bütün sayı yüzlerinde açıktır. Boyutlar bugünkü `D_FS_*`
merdiveninden (12, 13, 14, 15, 16, 18, 20, 22, 26, 30, 36, 40); maketin 17 px'i 16'ya, 11 px'i 12'ye yuvarlanır.

**Glif.** `glyph_audit` CSV'nin, literallerin ve `data/` metninin her karakterini Archivo'ya sorar. Eksik glif
(★, ×, ≈, ≥, ✓ adayları) için zincir: Archivo → bugünkü yüzün aynı ağırlığı (IBM Plex Sans) → bugünkü zincir. Denetim
Plex'e hiç düşmüyorsa Plex dosyaları silinir; düşüyorsa yalnız yedek olarak kalır.

**Kabul ölçütü (U0).**
- `UiTokens.THEME_STAMP` artar, iki tema yeniden üretilir ve commit'e girer (üretici `build_theme.gd`; editörün kaydettiği
  tema ya da `project.godot` farkı girmez, D v2 §2); `theme_check.gd` iki temada 0 ile çıkar.
- `--theme-contrast-audit` 0 ile çıkar; `glyph_audit` boş liste basar.
- `--tab-shot=<product|sales|hr|finance|piyasa|personal|rnd|events>`, `--modal-shot` (kaydet, ayarlar; kaydet kayıt yazdığı
  için ayrı `APPDATA` ile, CLAUDE.md §12 tuzakları), `--meeting-shot=probe`,
  `--negotiation-shot=open`, `--inbox-shot=flow`'un ilk karesi, `--menu-shot=empty` TR ve EN, ayrıca `--shot-scale=1.25`:
  hiçbir metin kesilmez ya da kutusundan taşmaz (CLAUDE.md §11, en çok 2 düzeltme turu). Taşan yerde önce sütun dar
  yüzüne (`d_sansc_*`) geçilir; yerleşim değiştirmek bu adımın işi değildir, düzelmiyorsa raporlanır.

### 9.2 Bu ekranın yeni token ve varyasyonları

- Renk: `D_ST_DESIGN #8E78BE`, `D_ST_DEV #6A9CCB`, `D_ST_TEST #A3D4B2` (aşama bantları; renk körü paletinde aynı renk,
  aşama ikonu ayırıcıdır) ve yardımcı `UiTokens.D_stage(stage)`; çubuk zemini bant renginin %62'si, koşan çubuk %12'si,
  gölge %30'u (yardımcı içinde). Uyarı: bugünkü `D_warn()`; uyarı zemini ve mürekkebi yoksa `D_WARN_BG #3A2616`,
  `D_WARN_INK #F6C48F`. Kırmızı (yetişmez) bugünkü tehlike rengi.
- Varyasyonlar (`build_theme.gd`): `SprintBoard` (orta çerçeve), `SprintRow`, `SprintRowHover`, `SprintRowLate`,
  `StageBar` ve hâlleri (`StageBarOut`, `StageBarGhost`, `StageBarRun`, `StageBarDone`), `CapTrack`, `CapBadgeOver`,
  `CapBadgeStreak`, `RequestRow`, `RequestRowPlanned`, `DueChip`, `DueChipSoon`, `ModuleRow`, `ModuleRowOpen`,
  `MonoBox`, `NextBox` (bugünkü `SprintColumnNext`), `CarriedRow`, `MoreHint`, `SprintTip`, `ProgressBar` koyu ikizi.
  Tarama ve noktalı çizgi stylebox ile çizilemediği yerde `_draw` kullanan tek bir küçük çizim sınıfı yazılır
  (`StagePaint`, renk ve ölçüyü token'dan okur); her öğe için ayrı çizim sınıfı yazılmaz.
- Doğrulayıcı yeni varyasyonları master temada da ister (bugünkü kural); master karşılığı koyu ölçülerle üretilir.

## 10. Portreler

Bütün yüzler oyunun 3B büstüdür: `SprintUiShared.avatar(person, px)` (`sprint_ui_shared.gd:206`) →
`UiFactory.make_person_avatar` (`ui_factory.gd:106`) → `PersonBust.texture(look, px)` (`person_bust.gd:38`, önbellek
görünüş ve boyutla, 2× örnekleme). Yalnız iki boyut kullanılır, ikisi de mevcut token:

| Boyut | Token | Nerede |
|---|---|---|
| 24 px | `D_AVATAR_ROW_SM` | kapasitenin kişi dizisi ve kümeleri, çubuğun ucundaki kurucu, koşan çubuktaki yüzler, PM yuvası ve "?" yuvası, sonraki kartın önden çalışanları ve hazırlayanı, kart ipucunun "kim" satırları, devret düğmesi |
| 32 px | `D_AVATAR_ROW` | Hazırlık'ın PM satırı, devirdeki PM |

Ekler (yüzün üstüne bindirilen, `SprintUiShared` içinde tek yardımcı):
- Yıldız çipi: yüzün sağ altında küçük kutu "{s}★" (`d_num` 12 px), 24'te sol 22, 32'de sol 29 px.
- Kurucu: yüzün çevresinde 2 px açık mürekkep halka.
- Seçilemeyen: `make_person_avatar(..., grey = true)` ve %38 opaklık, yıldız çipi yok.
- Soru: sağ üstte 14 px "?" diski.
- Bir karede aynı kişinin yüzü birden çok kez çıkabilir (dizide ve çubukta); 50 kişide küme temsilcisi yüzdür.
- Headless koşuda büst yoktur, baş harfler görünür (bugünkü davranış).

## 11. Metin

Kurallar: anahtar `localization/strings.csv`'ye bayt kesmeyle eklenir (asla yeniden yazılmaz); önce İngilizce; tire
yok; `{ad}` eksiz; satır başı etiket büyük harfle; büyük harf gösterimi `Fmt.upper` (SPRINT gövdesi Latin I'yı korur:
"SPRINT", maketteki "SPRİNT" yanlıştır). Sayı biçimi `Fmt` ve `SprintUiShared.points`. Hepsi "TR/EN onay bekliyor".
Tekil EN biçimi gereken sayımlar `_ONE` ikiziyle (`Fmt.count_key`).

Büyük harf (CLAUDE.md §5, sorulmaz yapılır): CSV değeri cümle içinde okunduğu gibi küçük başlar; kendi satırının başında
tek başına duran metin `Fmt.cap_first` ile okunur. Bu ekranda satır başında duranlar: "aşağıda {n} kart daha" hapı, PM
satırının ikinci satırı ("{n} kart hazırladı", "hazırlıkta"), sonraki kartın "hazır" / "hazırlanıyor"u. Yüzün ya da adın
yanında satır içinde duranlar ("eğitimde", "planda", "devreden", "yetişmez", söz çipi "bu çeyrek") küçük kalır.

**D'nin W2 metinleriyle birlik.** D'nin W2 dalgası (`faz_cde/d_taslak/W/W_METINLER.json`) plan ekranı için anahtar taslağı
yazdı; D6 bu göreve geçtiği için W2'nin plan ekranı (`plan.*`, `tip.*`, `card.*`) maddelerinden yalnız aşağıda adı geçenler
CSV'ye girer, öbürleri (darboğaz cümleleri, kişi satırı, kalır satırı, öneri cümleleri, kural satırı) girmez. Aynı anlam iki
anahtarla yazılmaz: W2'den aynen alınanlar `PRODUCT_QUARTER_GOAL` ("Bu çeyrek: {goal}"), `PRODUCT_QUARTER_BUGS`
("Hatalar"), `PRODUCT_QUARTER_NONE` ("Bu çeyrek: hedef yok"), `PRODUCT_DELEGATE_PLAIN`, `PRODUCT_DELEGATE_UNDO`,
`PRODUCT_DELEGATE_LOCKED`, `PRODUCT_NECK_STREAK`, `PRODUCT_SUGGEST_APPLY`, `PRODUCT_TIP_REQ` (D2a'nın verisi gelince,
P8). Metinleri W2'deki gibidir (§11.1'de yazılı). W2'nin `PRODUCT_DELEGATED` ve `PRODUCT_DELEGATE_ENDED` cümleleri bu
ekranda okunmaz (KR3); D8b PM ayrılınca oyuncuya ayrı bir ileti yazacaksa metni ve yeri D8b'nindir.

### 11.1 Yeni anahtarlar

| Anahtar | EN | TR |
|---|---|---|
| PRODUCT_FOUNDER_IN_SPRINT | Founder in sprint | Kurucu sprintte |
| PRODUCT_FOUNDER_ON_TIP | On: the founder works on sprint cards | Açık: kurucu sprint kartlarında çalışır |
| PRODUCT_FOUNDER_OFF_TIP | Off: the founder takes no sprint card | Kapalı: kurucu sprint kartı almaz |
| PRODUCT_FOUNDER_LOCKED_TIP | Changes at the next planning | Sonraki planlamada değişir |
| PRODUCT_QUARTER_ORD | Q{q} | {q}. çeyrek |
| PRODUCT_QUARTER_TIP | {year} · Q{q} · sprint {pos} of the quarter · {left} sprints to its end | {year} · {q}. çeyrek · çeyreğin {pos}. sprinti · çeyrek sonuna {left} sprint |
| PRODUCT_QUARTER_TIP_ONE | {year} · Q{q} · sprint {pos} of the quarter · {left} sprint to its end | {year} · {q}. çeyrek · çeyreğin {pos}. sprinti · çeyrek sonuna {left} sprint |
| PRODUCT_MVP_BADGE_CARDS | {done}/{need} cards | {done}/{need} kart |
| PRODUCT_MVP_BADGE_ETA | ≈ Sprint {n} | ≈ Sprint {n} |
| PRODUCT_WEEK_ORD | Week {w} | {w}. hafta |
| PRODUCT_QUARTER_GOAL (W2) | This quarter: {goal} | Bu çeyrek: {goal} |
| PRODUCT_QUARTER_BUGS (W2) | Bugs | Hatalar |
| PRODUCT_QUARTER_NONE (W2) | This quarter: no goal | Bu çeyrek: hedef yok |
| PRODUCT_GOAL_NONE_ITEM | No goal | Hedef yok |
| PRODUCT_GOAL_CHANGE_TIP | Change the quarter goal | Çeyrek hedefini değiştir |
| PRODUCT_CAPACITY | Capacity | Kapasite |
| PRODUCT_EFFORT | Effort | Efor |
| PRODUCT_EFFORT_TIP | effort {n} | efor {n} |
| PRODUCT_CAP_TIP | {stage} · effort {work} · team {team} | {stage} · efor {work} · ekip {team} |
| PRODUCT_CAP_TIP_DONE | done {n} | yapıldı {n} |
| PRODUCT_CAP_FITS | Fits | Sığıyor |
| PRODUCT_CAP_SPILL | {n} effort waits for the next sprint | {n} efor sonraki sprinte kalır |
| PRODUCT_CAP_WAITING | {n} of it while waiting on the previous stage | {n} efor önceki aşamayı beklerken |
| PRODUCT_STAYS_DESIGN | Stays in design | Tasarımda kalır |
| PRODUCT_STAYS_DEV | Stays in development | Geliştirmede kalır |
| PRODUCT_STAYS_TEST | Stays in testing | Testte kalır |
| PRODUCT_NECK_STREAK (W2) | This has been going on for {n} sprints. | Bu sorun {n} sprinttir sürüyor. |
| PRODUCT_SUGGEST | Room for {n} more effort | {n} efor daha sığar |
| PRODUCT_SUGGEST_APPLY (W2) | Apply the suggestion | Öneriyi uygula |
| PRODUCT_SUGGEST_NONE | No candidate card fits this gap | Bu boşluğa sığan aday kart yok |
| PRODUCT_AWAY_TRAINING | training | eğitimde |
| PRODUCT_AWAY_RESEARCH | researching | araştırmada |
| PRODUCT_AWAY_MEETINGS | in meetings | görüşmede |
| PRODUCT_AWAY_LEAVE | on leave | izinde |
| PRODUCT_PERSON_TIP | {name} {stars} · effort {effort} · {busy} busy | {name} {stars} · efor {effort} · doluluk {busy} |
| PRODUCT_CLUSTER_TIP | {stars} · {n} people | {stars} · {n} kişi |
| PRODUCT_CLUSTER_TIP_ONE | {stars} · {n} person | {stars} · {n} kişi |
| PRODUCT_TIMES | ×{n} | ×{n} |
| PRODUCT_CREW_TIP | Team: {n} people · in sprint {sprint} · training {training} · on leave {leave} · researching {research} · PM {pm} · outside the sprint {out} | Ekip: {n} kişi · sprintte {sprint} · eğitimde {training} · izinde {leave} · araştırmada {research} · PM {pm} · sprint dışı {out} |
| PRODUCT_EARLY_END | Sprint ends early | Sprint erken biter |
| PRODUCT_EARLY_END_TIP | All cards done in week {w} | Bütün kartlar {w}. haftada biter |
| PRODUCT_AVAILABLE | Available | Eklenebilir |
| PRODUCT_ADD_CARD | Add a card | Kart ekle |
| PRODUCT_MODULES | Modules | Modüller |
| PRODUCT_MORE_BELOW | {n} more cards below | aşağıda {n} kart daha |
| PRODUCT_MORE_BELOW_ONE | {n} more card below | aşağıda {n} kart daha |
| PRODUCT_RISK_TIP | Bug risk {level} | Hata riski {level} |
| PRODUCT_RISK_LOW | low | düşük |
| PRODUCT_RISK_MEDIUM | medium | orta |
| PRODUCT_RISK_HIGH | high | yüksek |
| PRODUCT_RISK_PREPARED | {name} prepared it: {now} instead of {before} | {name} hazırladı: {before} yerine {now} |
| PRODUCT_PREPARED_BY | {name} prepared it | {name} hazırladı |
| PRODUCT_PM_PREPARED | {name} {stars} prepared it: effort {now} instead of {before} | {name} {stars} hazırladı: efor {before} yerine {now} |
| PRODUCT_ASK_TIP | {name} has a question about this card · open | {name} bu kartla ilgili soruyor · aç |
| PRODUCT_CARRIED_SLOT | carried | devreden |
| PRODUCT_CARRIED_TIP | Carried over from the previous sprint | Önceki sprintten devreden iş |
| PRODUCT_LATE | late | yetişmez |
| PRODUCT_LATE_TIP | Not done by the sprint end | Sprint sonuna yetişmez |
| PRODUCT_TO_NEXT | To the next sprint | Sonraki sprinte |
| PRODUCT_TO_THIS | To this sprint | Bu sprinte |
| PRODUCT_ADD_TO_PLAN | Add to plan | Plana ekle |
| PRODUCT_STAGE_READY | {pct} ready: done ahead in the previous sprint | {pct} hazır: önceki sprintte önden yapıldı |
| PRODUCT_STAGE_RAW | effort {n} without the preparation | hazırlanmasaydı efor {n} |
| PRODUCT_STAGE_SHADOW | {stage}: effort {before} without the preparation, now {now} | {stage}: hazırlanmasaydı efor {before}, şimdi {now} |
| PRODUCT_STAGE_OUT | waits for the next sprint | sonraki sprinte kalır |
| PRODUCT_STAGE_NOW | now: {names} | şu an: {names} |
| PRODUCT_STAGE_RESEARCH | Research | Araştırma |
| PRODUCT_AHEAD_DONE | done ahead in the previous sprint | önceki sprintte önden bitti |
| PRODUCT_WAIT_FOR | Waiting for {name} | Bekliyor: {name} |
| PRODUCT_WAIT_DESIGN | Waiting for the designers | Bekliyor: tasarımcılar |
| PRODUCT_WAIT_DEV | Waiting for the developers | Bekliyor: geliştiriciler |
| PRODUCT_WAIT_TEST | Waiting for the testers | Bekliyor: testçiler |
| PRODUCT_MEETING_SALES | Sales meeting | Satış görüşmesi |
| PRODUCT_MEETING_VC | Investor meeting | Yatırımcı görüşmesi |
| PRODUCT_MEETING_TABLE | Term sheet table | Term sheet masası |
| PRODUCT_DAYS | {n} days | {n} gün |
| PRODUCT_DAYS_ONE | {n} day | {n} gün |
| PRODUCT_ON_TIME | Done by the sprint end | Sprint sonuna yetişir |
| PRODUCT_TIP_PROMISE | promised: {when} | söz: {when} |
| PRODUCT_NO_PM | No PM | PM yok |
| PRODUCT_NO_PM_TIP | No product manager on the team | Ekipte ürün yöneticisi yok |
| PRODUCT_FOUNDER_CARD | the founder's card | kurucunun kartı |
| PRODUCT_DELEGATE_PLAIN | Delegate planning | Planlamayı devret |
| PRODUCT_DELEGATE_ON | {name} is planning | {name} planlıyor |
| PRODUCT_DELEGATE_UNDO (W2) | Take planning back | Planlamayı geri al |
| PRODUCT_DELEGATE_LOCKED (W2) | You need a product manager on the team to delegate planning. | Planlamayı devretmek için ekipte bir ürün yöneticisi olmalı. |
| PRODUCT_AUTO_START | Starts on its own | Kendiliğinden başlar |
| PRODUCT_PROGRESS | Sprint | Sprint |
| PRODUCT_PROGRESS_TIP | Effort {done}/{total} | Efor {done}/{total} |
| PRODUCT_PREP | Preparation | Hazırlık |
| PRODUCT_PM_CARDS | prepared {n} cards | {n} kart hazırladı |
| PRODUCT_PM_CARDS_ONE | prepared {n} card | {n} kart hazırladı |
| PRODUCT_PM_PREPARING | preparing | hazırlıkta |
| PRODUCT_CARDS | Cards | Kartlar |
| PRODUCT_MORE_CARDS | +{n} cards | +{n} kart |
| PRODUCT_MORE_CARDS_ONE | +{n} card | +{n} kart |
| PRODUCT_NEXT_LOAD_TIP | {stage} · carried {carried} · planned {planned} · team {team} | {stage} · devreden {carried} · planlı {planned} · ekip {team} |
| PRODUCT_READY | ready | hazır |
| PRODUCT_PREPARING | preparing | hazırlanıyor |
| PRODUCT_PREPARING_TIP | {name} is preparing it | {name} hazırlıyor |
| PRODUCT_STARTS_AHEAD | starts ahead: week {w} | önden başlar: {w}. hafta |
| PRODUCT_DONE_AHEAD | done ahead | önden bitti |
| PRODUCT_REQUESTS | Customer requests | Müşteri talepleri |
| PRODUCT_MORE_REQUESTS | +{n} requests | +{n} talep |
| PRODUCT_MORE_REQUESTS_ONE | +{n} request | +{n} talep |
| PRODUCT_DUE_THIS_Q | this quarter | bu çeyrek |
| PRODUCT_DUE_NEXT_Q | next quarter | gelecek çeyrek |
| PRODUCT_DUE_Q | Q{q} | {q}. çeyrek |
| PRODUCT_REQUEST_PLANNED_TIP | Its card is in this sprint's plan | Kartı bu sprintin planında |
| PRODUCT_IN_PLAN | planned | planda |
| PRODUCT_IN_PLAN_TIP | Has a card in this sprint | Bu sprintte kartı var |
| PRODUCT_CAND_IN_PLAN_TIP | In this sprint's plan | Bu sprintin planında |
| PRODUCT_STAMP | S{n} | S{n} |
| PRODUCT_AREA_CORE_MONO | CO | ÇK |
| PRODUCT_AREA_ONBOARDING_MONO | ON | İK |
| PRODUCT_AREA_GROWTH_MONO | GR | BÜ |
| PRODUCT_AREA_INTEGRATIONS_MONO | IN | EN |
| PRODUCT_AREA_TRUST_MONO | TS | GÜ |
| PRODUCT_AREA_REVENUE_MONO | RV | GE |

Bugünkü anahtarlardan aynen kullanılanlar: PRODUCT_SPRINT_TITLE, PRODUCT_NEXT, PRODUCT_CARRIED_OVER, PRODUCT_HISTORY,
PRODUCT_DELEGATE, PRODUCT_START_SPRINT ("Sprinti başlat", mühürlü), PRODUCT_STATUS_CARDS (ve _ONE: "{n} kart"),
PRODUCT_STATUS_DONE ("bitti"), PRODUCT_REMOVE, PRODUCT_PHASE_DESIGN / _DEV / _TEST, PRODUCT_MVP_RULE (rozet ipucu),
PRODUCT_TEAM_IN_RND, PRODUCT_TEAM_NOBODY_JOBS, PRODUCT_ADD_CLOSED ve PRODUCT_ADD_CLOSED_FULL, PRODUCT_AREA_* adları ve
_SHORT'ları, PRODUCT_FX_BUGS / PRODUCT_FX_TOP / PRODUCT_ACCOUNT_COUNT / PRODUCT_USER_COUNT (düzeltme metni,
`SprintUiShared.bugs_text`), PRODUCT_QUARTER_NEED_PM (ÇEYREK'in kilidi), PRODUCT_THIS_SPRINT (ÇEYREK okur), HR_EMPTY_ROW,
PRODUCT_GO_* ve HR_SEARCH_START (boş hâl), sürüm notunun bütün anahtarları.

**Değeri değişen bugünkü anahtarlar** (KR4: birim sözcüğü "efor"; göç sorulmaz yapılır; TR/EN onay bekliyor). Aynı
pencerede okunan "puan" sözcüğü kalkar:

| Anahtar | Bugün (TR · EN) | Yeni EN | Yeni TR |
|---|---|---|---|
| PRODUCT_ADD_CLOSED_FULL | Bu sprintte boş puan kalmadı · No spare points left this sprint | No effort left to fill this sprint | Bu sprintte boş efor kalmadı |
| PRODUCT_EFFORT_POINTS ve _ONE (ÇEYREK'in kartı, `sprint_card.gd:306`) | {n} puan · {n} points | Effort {n} | Efor {n} |
| PRODUCT_VELOCITY_LINE ve _ONE (sürüm notu, `sprint_panel.gd:279`) | Ekip {total} puanın {done} tanesini bitirdi. · The team finished {done} of {total} points. | The team finished {done} of {total} effort. | Ekip {total} eforun {done} kadarını bitirdi. |

### 11.2 İpuçlarının tam listesi

Parçalar `SprintUiShared.SEP` (" · ") ile birleşir; bir ipucunda satır `\n`.

| # | Nerede | Metin |
|---|---|---|
| T1 | Kurucu sprintte | açık: PRODUCT_FOUNDER_ON_TIP · kapalı: PRODUCT_FOUNDER_OFF_TIP · sprint sürerken: PRODUCT_FOUNDER_LOCKED_TIP · Ar-Ge: PRODUCT_TEAM_IN_RND |
| T2 | Çeyrek göstergesi | PRODUCT_QUARTER_TIP |
| T3 | MVP rozeti | PRODUCT_MVP_RULE (ya da _NO_ETA) |
| T4 | Ekip rozeti | PRODUCT_CREW_TIP |
| T5 | Hedef seçici | PRODUCT_GOAL_CHANGE_TIP |
| C1 | Aşama etiketi ve sayısı | PRODUCT_CAP_TIP · (koşan: PRODUCT_CAP_TIP_DONE) · PRODUCT_CAP_FITS ya da PRODUCT_CAP_SPILL · (iç taşma varsa: PRODUCT_CAP_WAITING) |
| C2 | Rozet | PRODUCT_CAP_FITS ya da PRODUCT_CAP_SPILL |
| C3 | Süreklilik rozeti | PRODUCT_NECK_STREAK |
| C4 | Taşma ipucu paneli | başlık "{aşama} · PRODUCT_EFFORT {iş} / {ekip}", "+{n}" + PRODUCT_STAGE_OUT, Fmt.upper(PRODUCT_STAYS_*) altında "{kart} {efor}" satırları, varsa PRODUCT_NECK_STREAK |
| C5 | Kişi yüzü | PRODUCT_PERSON_TIP |
| C6 | Seçilemeyen kişi | "{ad} {yıldız}" · PRODUCT_AWAY_* |
| C7 | Küme | PRODUCT_CLUSTER_TIP |
| C8 | Öneri | önerinin kartları, satır başına "{kart} · {bu sprintte}/{efor}"; adaysızken düğme ipucu PRODUCT_SUGGEST_NONE |
| B1 | Aşama çubuğu | "{aşama} · PRODUCT_EFFORT_TIP" (koşan: "efor {yapılan}/{toplam}") · (önden: PRODUCT_STAGE_READY) · (hazırlandıysa: PRODUCT_STAGE_RAW) · (gereksinim verisi gelince, P8: PRODUCT_TIP_REQ) · (dış pay: PRODUCT_STAGE_OUT) · (koşan: PRODUCT_STAGE_NOW, değilse çalışanların adları) · (görüşme kalemleri) |
| B2 | Bekleme | PRODUCT_WAIT_FOR + varsa " ({kart} · {aşama})", ya da PRODUCT_WAIT_DESIGN / _DEV / _TEST |
| B3 | Önden bitmiş aşamanın tik kutusu | "{aşama} · PRODUCT_AHEAD_DONE" |
| B4 | PM gölgesi | PRODUCT_STAGE_SHADOW |
| B5 | Görüşme taraması | "{PRODUCT_MEETING_*} · PRODUCT_DAYS" (kalem başına; hafta eksende görünür, KR24) |
| B6 | Erken kapanış bayrağı ve taralı alan | PRODUCT_EARLY_END_TIP |
| B7 | Araştırma çubuğu | "PRODUCT_STAGE_RESEARCH · PRODUCT_EFFORT_TIP · {kişiler}" |
| KT1 | Kart adı ve çubuklar | zengin kart ipucu (§4.8) |
| KT2 | Hata göstergesi | PRODUCT_RISK_TIP + hazırlandıysa düzey değiştiyse PRODUCT_RISK_PREPARED, değişmediyse PRODUCT_PREPARED_BY |
| KT3 | Efor sayısı | PRODUCT_EFFORT_TIP |
| KT4 | Modül adı | modülün tam adı |
| KT5 | Söz çipi | "{müşteri} · {tarih}" |
| KT6 | devreden | PRODUCT_CARRIED_TIP |
| KT7 | yetişmez | PRODUCT_LATE_TIP + görüşme kalemleri |
| KT8 | (boş; "teknik" çipi P13) | yok |
| KT9 | PM yuvası | PRODUCT_PM_PREPARED |
| KT10 | "?" yuvası | PRODUCT_ASK_TIP (+ PM ise PRODUCT_PM_PREPARED) |
| KT11 | → / × / + / ↑ | PRODUCT_TO_NEXT / PRODUCT_REMOVE / PRODUCT_ADD_TO_PLAN (kapalıysa PRODUCT_ADD_CLOSED ya da PRODUCT_ADD_CLOSED_FULL) / PRODUCT_TO_THIS |
| F1 | Kilitli devret | PRODUCT_DELEGATE_LOCKED |
| F2 | Kapalı başlat | PRODUCT_TEAM_NOBODY_JOBS ya da PRODUCT_TEAM_IN_RND |
| F3 | İlerleme | PRODUCT_PROGRESS_TIP |
| R1 | PM satırı | "{ad} {yıldız}" · hazırladığı kartların adları |
| R2 | PM yok | PRODUCT_NO_PM_TIP |
| R3 | Aşama yükü | PRODUCT_NEXT_LOAD_TIP |
| R4 | Devreden satırı | "{kart} · {aşama} · PRODUCT_EFFORT_TIP"; "+{n} kart" satırında kalanlar "{kart} · {aşama} {efor}" |
| R5 | Sonraki kartın adı | "{kart} · PRODUCT_EFFORT_TIP" · (önden başlıyorsa PRODUCT_STARTS_AHEAD) |
| R6 | Sonraki kartın şerit parçası | "{aşama} · PRODUCT_EFFORT_TIP" · PRODUCT_DONE_AHEAD ya da PRODUCT_STAGE_READY'nin yüzdesi · çalışanlar |
| R7 | Hazırlık işareti | PRODUCT_PREPARING_TIP ya da PRODUCT_PM_PREPARED |
| L1 | Talep satırı | "{müşteri} · {kart} ({modül})" · PRODUCT_PER_YEAR'ın değeri · PRODUCT_TIP_PROMISE |
| L2 | Planlı talebin çipi | PRODUCT_REQUEST_PLANNED_TIP |
| L3 | Modül satırı | "{modül}" · (planda ise PRODUCT_IN_PLAN_TIP) |
| L4 | Adayın tiki | PRODUCT_CAND_IN_PLAN_TIP |
| L5 | Adayın şerit parçası | "{aşama} {efor}" |

Aynı adlı iki kişi: ipuçlarında kişinin tam adı (`character_name`) yazılır; böylece ayrılır (kare 14).

- **Not (yardımcı yönetmenin kararı, 2026-10-27, U6):** (1) Aşama çubuğunun üstünde yalnız B1'in düz ipucu açılır; zengin kart ipucu
  yalnız kart adındadır (KT1'in "ve çubuklar" kısmı düşer). (2) PRODUCT_STARTS_AHEAD haftasızdır: "önden başlar" / "starts ahead" (KR24).
  (3) R6'da önden tam bitmiş aşama PRODUCT_DONE_AHEAD, kısmen yapılmış aşama yalnız yüzdedir ("%40"). (4) Zengin ipucunda ve KT7'de aynı
  türden görüşmeler toplanır ("Satış görüşmesi · 4 gün"); B5 kalem başına kalır. (5) Künyede "PM yok" yalnız ekipte PM yokken yazılır;
  PM var ama kartı hazırlamamışsa künye yalnız "{modül}"dür. (6) Zaman eksenindeki dördüncü girdi (özellik kartında oynatmanın
  öngördüğü düzeltme işi, `fix: true`) zengin ipucunun efor kutularına ve "Kim" satırlarına girmez; panel üç aşamadır, o parçanın çubuğu
  B1 düz ipucunu korur (§7.3: test bitmeden öngörülen düzeltme sayı olarak görünmez; ilk "dördüncü kutu" kararı yanlış varsayıma dayanıyordu,
  geri alındı). (7) KT10'da konuşanı olmayan
  kâğıtta {name} kâğıdın göndericisidir ("Sunucu sağlayıcısı bu kartla ilgili soruyor · aç"). C8'in PRODUCT_SUGGEST_NONE'u yazılmaz
  (aday yokken öneri satırı çizilmez, U1 cevap 7). Kurucunun "Kim" satırındaki yıldız aşamanın alanındandır ("Kurucu 0★"). Kapısı
  kapanan kartın düz ipucu `gate_reason` + PRODUCT_GATE_MOVES ("Sprint başlayınca sonraki sütuna geçer" / "Moves to the next column
  when the sprint starts"); tek tik kutusu bu sprintte biten aşamayı PRODUCT_STAGE_DONE_NOW ile yazar ("bu sprintte bitti" /
  "done this sprint"). B2: kimsenin çalışmadığı araştırma aşamasının beklemesi PRODUCT_WAIT_PRODUCT ("Bekliyor: ürün yöneticisi ya da
  kurucu" / "Waiting for a product manager or the founder"); koşan sprintte önceki sprintte önden bitmiş aşama B3'le okunur.

### 11.3 Silinen anahtarlar

Arayüz değişikliğinden sonra okuyucusu kalmayan her anahtar aynı commit'te silinir; silmeden önce
`grep -rn "<ANAHTAR>" scripts scenes data tools` kanıtı rapora girer (`loc_product_derived_keys` türetilen adları
denetler). Beklenen liste:

PRODUCT_WEEK_OF, PRODUCT_IDLE, PRODUCT_IDLE_ONE, PRODUCT_IDLE_PLAN, PRODUCT_ROLE_MISSING,
PRODUCT_SKIP_SPRINT, PRODUCT_SKIP_CONFIRM, PRODUCT_START_NEED_CARD, PRODUCT_PLAN_HOLD, PRODUCT_OVER_CAPACITY ve _ONE,
PRODUCT_STATUS, PRODUCT_STATUS_RUNNING, PRODUCT_STATUS_QUEUED, PRODUCT_STATUS_DECISIONS ve _ONE, PRODUCT_STATUS_WAITING,
PRODUCT_AT_SPRINT_END, PRODUCT_NEXT_RELEASE, PRODUCT_IN_WEEKS ve _ONE, PRODUCT_LEAD_TIP, PRODUCT_LEAD_APPLY,
PRODUCT_LEAD_ONE, PRODUCT_LEAD_TWO, PRODUCT_LEAD_REQUEST, PRODUCT_EMPTY_SPRINT, PRODUCT_PM_STARTED, PRODUCT_NEXT_EMPTY,
PRODUCT_AREAS, PRODUCT_PERSON_SHARE, PRODUCT_AREA_NOTHING_LEFT, alanın sözcük ve cümle anahtarları
(PRODUCT_AREA_*_NONE / _WEAK / _ENOUGH / _STRONG, PRODUCT_AREA_RIVAL, PRODUCT_AREA_OVER_CAPACITY) ve hata satırının
ipucu anahtarları (PRODUCT_BUGS_TIP_*) yalnız sprint ekranı okuyorsa. Sürüm notu, Olaylar'ın destek raporu
(`mail_pane.gd` `bug_line`), ÇEYREK ve smoke'ların okuduğu anahtarlar kalır (PRODUCT_THIS_SPRINT `quarter_view.gd`'de,
PRODUCT_STATUS `sprint_card.gd`'de okunur: ÇEYREK'in görünümü kullanıyorsa kalır).

**Okuyucusu kalmayan kod** (aynı commit'te silinir, CLAUDE.md §8; adım U7, kendi parçası olan adımda daha önce):
- `SprintCatalog.lead_sentence` (`sprint_catalog.gd:483`; `release_lead_sentence` sürüm notunda kalır).
- SPRINT SONUNDA önizlemesi: `center.forecast`, `SprintCatalog.forecast` (`:343`), `SprintUiShared.forecast`
  (`sprint_ui_shared.gd:339`). A4'te yok, KR3. Okuyan smoke'lar: `sprint_fix_preview_matches_close` önizleme iddiasını
  (`endgame_smoke.gd:21238-21263`) ve `sprint_request_on_time_met` (`:21674`) önizleme satırını bırakır; iki vakanın
  motor iddiaları kalır.
- Modül satırının hat başına hata listesi: `ProductModel._bug_rows` (`product_model.gd:185`), `bug_row` (`:197`) ve
  alanın `bug_rows` alanı; `bug_row_of` (`:203`) Olaylar'ın destek raporu okuduğu için kalır. Okuyan smoke'un
  (`endgame_smoke.gd:21458` civarı, `areas[].bug_rows`) yerine aday düzeltme kartının hata sayısı sınanır ya da vaka
  silinir (görsel kabul bunu karşılar).
- Alanın sözcük ve cümle üreticileri (`PRODUCT_AREA_RIVAL` ve `PRODUCT_AREA_OVER_CAPACITY`'yi `sprint_catalog.gd`
  okur): yalnız sprint ekranı okuyorsa işlevleriyle birlikte.
- `ProductModel.BUTTONS`'ta ADAY satırının `send_next`'i (aday yalnız "+" taşır) ve SPRINT_AKTIF'in `remove`'u (KR25).
- `main.gd`'nin `live:plan` ikinci karesi `PRODUCT_SKIP_SPRINT` düğmesine basıyor (`main.gd:3742`): KR26 ile "0 kart"lı
  başlata döner.

## 12. D ile iş bölümü

**Park edilen arayüz adımları nereye gider.**

| D adımı | Karar | Gerekçe |
|---|---|---|
| D6 (plan ekranı) | **Bu göreve geçer, tamamı.** D'nin tablosundan silinir. | D6'nın park nedeni ekranın yeniden yorumuydu (D'nin U1 ile U7 soruları); A4 onu kapattı. |
| D8a (öneri) | **Model D'de kalır ve parktan çıkar; arayüzü bu görevde.** | Park nedeni Erdem'in "'X ve iki kart daha girer' değil 'şu kadar SP daha alınabilir'" sözüydü; A4'ün "{n} efor daha sığar" satırı cevaptır. D8a'nın altı basamağı `lead_suggestion()`'ı değiştirir; arayüz yalnız onu okur. |
| D8b (çeyrek şeridi) | **Model D'de, arayüz bu görevde.** Model: PM'siz `pick_goal`, `quarter_goal()` seçim yokken boş (PM planının en zayıf alan yedeği `pm_plans`'a taşınır), "Hatalar" seçeneği, devretin PM şartı (PM yokken açılmaz, PM ayrılınca kalkar). D8b'nin commit'i anahtar eklemez ve ÇEYREK'in PM kilidini değiştirmez (§4.1); metinleri bu görev W2'den alır (§11). "v1.0 öncesi sabit Çekirdek" A4'ün çizimidir, dayanağı yok: modele girmez (P14). Arayüz: sprint başlığının hedef seçicisi, ÇEYREK şeridinin "hedef yok" hâli, devret düğmesinin kilidi. | KR19; PRD_FAZ_D Karar 12. Model 1 sa 30 dk; arayüz U3 ve U5'in içinde. |
| D5a (Atlas ve Görevler metinleri) | **Bu göreve geçmez.** Ekip ekranıdır; Ekip maketiyle (`docs/strateji/ekranlar/ekip.html`) ayrı arayüz görevine. | Sprint ekranı değil. |
| D7'nin arayüz parçası (Destek kartı eşiği) | Bu göreve geçmez. | BuildBar'ın Destek kartıdır. |
| Devret önerisi satırı | Düşmüş kalır (D v2 §3). | |
| Kurucunun sprint payı satırı, kurucunun üç cümlesi (D6 listesi) | Düşer: ekranda cümle yok; bilgi kişi dizisinin doluluğunda, görüşme taramasında ve ipucunda (KR3, KR12). | |
| Darboğaz cümlesi ve sayacı (D6 listesi) | Cümle düşer; sayaç süreklilik rozeti olur (KR18). | |
| "Sırada" satırı (D6) | Düşer: sıradaki iş zaman ekseninde bekleme ve sonraki sprintin "önden başlar"ıdır. | Merdiven ve KR14 çekmeyi kaldırdı (D v2 §0c). |

**Çakışan dosyalar.** `sprint_system.gd`, `sprint_catalog.gd` (D8a, D8b), `product_model.gd`, `product_tab.gd`,
`quarter_view.gd` (D8b), `game_state.gd` (D1b), `time_model.gd` (D1b), `main.gd` (shot), `strings.csv` (bayt kesme),
`endgame_smoke.gd`, `sprint_probe.gd`, `run_probe.gd`, CLAUDE.md §6 ve §12, `docs/HARITA.md`, kod haritası sayfaları.
Aynı ağaçta aynı anda tek yazan; her commit öncesi `git log` ile D'nin son hâli okunur, yalnız kendi parçalar hunk
düzeyinde sahnelenir (D v2 §2).

**Sıra.**
1. U0 (Archivo) hemen başlayabilir: yalnız tema, font ve ekran kareleri; D'nin dosyalarına dokunmaz. Godot'u D ile
   sırayla kullanır ("kapı bende / bitti").
2. D'nin (a) listesi (D v2 §0c): D1b → D2b → D3 → D4 → D7m; ardından D8b'nin modeli ve D8a.
3. U1 ile U8: D1b, D2b, D3, D4 ve D8b'nin modeli commit'lenince. D8a beklenmez (arayüz `lead_suggestion` okur).
4. D2a geldiğinde (park çözülünce): zaman ekseninin ikinci üreticisi D2a'nın commit'inde; U8 kareleri D2a'nın kapısında
   yeniden çekilir.

D'nin herhangi bir (a) adımı gecikirse ilgili öğe çizilmeden U adımı ilerleyemez (KR23); bu durumda U1 ile U8 o adımı
bekler, taklit veri yazılmaz.

**D v2'de yardımcı yönetmenin düzeltmesi gereken satırlar** (bu PRD D'nin dosyasını değiştirmez; çakışma iki belgede de
aynı okunsun diye):
1. §1 D6 satırı silinir (bu göreve geçti); §0b (b) ve §0c "Yeni park" listesinden D6, D8a ve D8b'nin modeli çıkar, U1 ile
   U7'nin "sprint ekranının yeni yorumuna" notu bu PRD'ye bağlanır.
2. D8b satırının dosyaları `sprint_system.gd` ve `sprint_catalog.gd`'ye iner (`product_tab.gd`, `quarter_view.gd`,
   `strings.csv` bu görevin U2, U3 ve U5'indedir); "Metinler W2'den" cümlesi "metinleri U3 ve U5 yazar" olur.
3. D8a satırındaki "neden parçası W2'den gelir, ekrana D6'da çıkar" düşer: öneri satırında neden cümlesi yok (KR3); D8a
   yalnız `lead_suggestion()`'ı değiştirir.
4. M2 + W2 satırı: W2'nin plan ekranı metinlerinden CSV'ye girenler bu PRD'nin §11'indekilerdir.
5. D4'ün notu: D4'ten sonra PM sprint puanı üretmiyorsa (PRD_FAZ_D Karar 8) `team()`'den çıkar; çıkmıyorsa arayüz onu
   E2 kuralıyla çizer, iki durumda da arayüz değişmez.
6. D1b'ye §7.3'ün iki kod gerçeği (görüşme süresi ile payın aynı sabitten okunması; paydanın 40 olması) ve V10'un
   `advance_hours` tür parametresi; D1b taşırsa U1 yazmaz.

## 13. Adım tablosu

Her kod adımında akış: Sonnet kodlar → Haiku kapıları koşar ve kareleri çeker → Opus kıdemli gözle inceler (yalnız
diff, CLAUDE.md §9 soruları ve dokunulan sistem sayfasının "Dikkat" listesi), düzeltme hakkı vardır → commit
`Ürün arayüzü Un:` önekiyle, uyguladığı kararın numarasıyla (§3), metin varsa "TR/EN onay bekliyor". Commit başına en
çok 1 inceleme ve 1 düzeltme; düzeltmeden sonra kapı düşerse adım durur ve yardımcı yönetmene gelinir.

**Ortak kapılar (her commit).** `--event-lint` → `loc_residue` → `loc_csv_integrity` → `all_scripts_load`; dokunulan
sistemin smoke vakaları; görünür değişiklikte TR ve EN kare. `class_name` eklenen ya da silinen adımda önce
`--headless --import`.

| Adım | Ne | Dosyalar | Kapı (ortaklara ek) | Model (düşünme) | Süre |
|---|---|---|---|---|---|
| U0 | Archivo bütün oyuna (§9.1) | `assets/fonts/archivo/`, `build_theme.gd`, `ui_tokens.gd` (`THEME_STAMP`), iki tema, `assets/fonts/variations/`, CLAUDE.md §7 yazı tipi cümlesi, kod haritası 09 | `theme_check` iki tema, `--theme-contrast-audit`, `glyph_audit`; §9.1'in kare listesi TR, EN, 1,25 | Sonnet (xhigh) / Haiku / Opus | 5 sa |
| U1 | Model ve veri: V1 ile V11, `ProductModel.live()` yeni alanları (eski çizim bu adımda hâlâ çalışır; eski alan, son okuyucusunu değiştiren U adımının commit'inde silinir, CLAUDE.md §8), zaman ekseni birinci üreticisi (`plan_outcome` ile tek oynatma, §7.5), `SprintSystem.away()` | `sprint_system.gd`, `product_model.gd`, `game_state.gd` ve `time_manager.gd` (V10, D1b taşımıyorsa), `sales_meeting_system.gd`, `vc_pitch_system.gd`, `term_sheet_table_system.gd`, `endgame_smoke.gd` | yeni smoke `sprint_timeline_matches_play_out` (Z1 ile Z5; kasıtlı bozulmada düşer); `--sprint-probe` 1/3/6/12/25/50 kişide `^SPRINTPROBE` bayt eşit (Z6); `PLANMS` 50 kişide D8a tabanının en çok %10 üstü (U1 cevap 19); `sprint_save_roundtrip`, `save_v19_running_sprint_continues`; A17 (birim) | Sonnet (**max**) / Haiku / Opus | 7 sa |
| U1s | A4 kareleri için motorla kurulan dünyalar: §5'in `live:a4_*` türleri (`main.gd` `_seed_product_live`; kişi, yıldız, PM, görüşme, taşma sayacı, eğitim ve izin motorun kendi seam'leriyle kurulur, model alanı elle yazılmaz). Uzun ad için katalogun en uzun EN kart adları seçilir (veri değişmez); aynı adlı iki kişi işe alımın ad parametresiyle. Hover hayaleti modelin bugünkü `ui.hover_card` alanıyla. Her tür `PRODUCTSHOT` satırı basar (alanlar `kind=`, `cards=`, `people=`, `row_gaps=`) (A11'in sayacı) | `main.gd`, HARITA Ürün (tür listesi) | 23 türün her biri (kare 14, 11'in türünü EN'de kullanır) hatasız kurulur ve satırını basar (U2 ile U6 kapıları bu türleri kullanır); TR ve EN | Sonnet (xhigh) / Haiku / Opus | 3 sa |
| U2 | Denetim şeridi ve sol sütun: Kurucu sprintte anahtarı, devret anahtarının kalkışı, `AreaPanel` yeniden (Müşteri talepleri, Modüller, adaylar, hover hayaletinin olayı), ÇEYREK'in sol sütunu | `product_tab.gd`, `area_panel.gd`, `quarter_view.gd`, `sprint_ui_shared.gd`, `build_theme.gd`, `strings.csv` | Erdem A4'ün karelerine baktı (başlama şartı, belgenin başındaki not); kareler `a4_six_hover`, `a4_requests`, ÇEYREK `live:b2b_quarter`; TR, EN; adayların "+"ı karelere bölünür ve `PLANMS` ilk kare 50 kişide ≤ 100 ms (U1 cevap 19; sonraki her U adımında da) | Sonnet (xhigh) / Haiku / Opus | 5 sa |
| U3 | Orta başlık ve kapasite: sprint başlığı, çeyrek, MVP ve hafta rozetleri, hedef seçici (D8b arayüzü, ÇEYREK menüsünü paylaşır), kapasite satırları, kişi dizisi, kümeler, öneri satırı | `sprint_panel.gd` (yeniden), yeni küçük çizim sınıfı `StagePaint`, `quarter_view.gd` (menünün ortaklaşması), `ui_tokens.gd`, `build_theme.gd`, `strings.csv` | kareler `a4_solo`, `a4_six_pm5`, `a4_twelve_dev`, `a4_fifty`; `--theme-contrast-audit` | Sonnet (xhigh) / Haiku / Opus | 5 sa |
| U4 | Kart listesi ve zaman ekseni: satır, çubuklar, beklemeler, önden iş, gölge, tarama, sprint dışı pay, koşan hâl, hayaletler, boş satır, EKLENEBİLİR, "aşağıda N kart", kaydırmanın korunması, saatlik güncelleme | `sprint_panel.gd`, `StagePaint`, `build_theme.gd`, `strings.csv` | kareler `a4_six_hover`, `a4_eleven`, `a4_fourteen`, `a4_early`, `a4_run_w2`, `a4_six_meetings2`, `a4_empty`; satırda boşluk denetimi (A11) | Sonnet (**max**) / Haiku / Opus | 8 sa |
| U5 | Alt şerit ve sağ sütun: devret düğmesi ve devir hâli, başlat ve "0 kart", ilerleme, Hazırlık, sonraki sprint kutusu; planın görünme anının mesai başlangıcına taşınması (§8.1, yaklaşık 1 sa ek; yeni smoke vakası `plan_opens_at_work_start`: mesai 10:00'da plan 10:00'da, 08:00'de saat akar) | `sprint_panel.gd`, `product_tab.gd` (`_act`: başlatın `skip` kolu), `strings.csv` | kareler `a4_six_pm5`, `a4_two_pm`, `a4_fifty`, `a4_run_end`, `a4_next_prefilled`; `sprint_starts_only_with_consent`, `clock_resumes_only_by_player` | Sonnet (xhigh) / Haiku / Opus | 4 sa |
| U6 | İpuçları: zengin kart ipucu, taşma paneli, §11.2'nin bütün satırları | `sprint_panel.gd`, `sprint_ui_shared.gd`, `strings.csv` | kareler `a4_eleven_tip` TR ve EN (uzun adlar), `a4_eleven_streak` (taşma paneli); ipucu metinlerinde KR9 yasak listesinin aranması (A8) | Sonnet (xhigh) / Haiku / Opus | 4 sa |
| U7 | Temizlik, fikstür ve belgeler: `SprintCard`'ın WIDE / NARROW / LOW görünümleri, `ProductFixtures` ve `ProductTab.set_source` (statik fikstür kaynağı emekli; bütün Ürün kareleri `live:` türlerinden), hâlâ okuyucusu kalmayan model alanları, işlevler ve §11.3 anahtarları (önceki adımlar kendi parçalarını sildi); `--product-shot`'ın fikstür türleri (`c1..c5`, `cards`, `flow`, `edge:`) ve `main.gd`'nin fikstür yolu (`main.gd:3689` civarı); CLAUDE.md §12'nin Ürün shot listesi, HARITA Ürün, kod haritası 02 / 08 / 09 ve `uret.py` | `sprint_card.gd`, `product_fixtures.gd` (silinir; `class_name`'i yok, `game_shell.gd:18` sabitiyle yüklenir), `product_tab.gd`, `game_shell.gd`, `main.gd`, `product_model.gd`, `sprint_catalog.gd` (`lead_sentence`, `forecast`, alan cümleleri), `sprint_ui_shared.gd`, `strings.csv`, `endgame_smoke.gd` (§11.3'ün vakaları), belgeler | `loc_product_derived_keys`; silinen her ad için grep kanıtı; HARITA ve kod haritası satır denetimi (240 karakter) | Sonnet (xhigh) / Haiku / Opus | 5 sa |
| U8 | Görsel kabul turu: §5'in 24 durumu (oyunda karşılığı olanlar) TR; 06, 11, 14, 16 EN; 04 ve 12 renk körü; 06 ve 11 `--shot-scale=1.25`; sürüm notu ve MVP kapısı (`live:gate`); kareler maketin karesiyle yan yana tek görsel sayfada Erdem'e | kareler `%APPDATA%\Godot\app_userdata\Project Unicorn\`, sayfa yardımcı yönetmenin scratchpad'inde | CLAUDE.md §11 (en çok 2 düzeltme turu; sonra kareyle raporlanır) | Haiku koşar ve çeker / Opus karşılaştırır (yüksek) | 3 sa |

Toplam yaklaşık 50 saat (U0 5, U1 7, U1s 3, U2 ile U7 32, U8 3). Bağımlılık: U0 serbest; U1 → U1s → U2 → U3 → U4 → U5 →
U6 → U7 → U8, U1 ve sonrası §12'deki D adımlarından sonra; U2 ayrıca Erdem'in A4'e bakmasını bekler (başlıktaki not).
Her U adımı çizimini değiştirdiği öğenin eski model alanını, işlevini ve anahtarını kendi commit'inde siler (CLAUDE.md
§8); U7 yalnız en sona kalanı toplar.

## 14. Kabul ölçütleri

Her madde ✅ / ⚠️ / ❌ ve kanıtla (dosya:satır, test adı, kare adı) raporlanır.

**Yapı ve metin.**
- A1 Ekranın hiçbir yerinde "SP" yok; hiçbir yerde K1, K2, K3 gösterimi yok (kare metinleri ve `strings.csv`'nin
  bu ekranda okunan anahtarları taranır).
- A2 Kapasite başlığı "KAPASİTE"; değerler "Efor {iş} / {ekip}"; "Efor ekibe sığıyor mu" anahtarı ve metni yok.
- A3 Sol üst başlık "MÜŞTERİ TALEPLERİ {n}"; her satırda müşteri, kart, modül işareti ve söz tarihi; B2C'de bölüm yok.
- A4 Kilitli modül ve kilitli aday sol sütunda listelenmez (Ar-Ge kilidi olan bir fikstürle sınanır).
- A5 "Kurucu sprintte" anahtarı Geçmiş'in solunda, aynı türde; yeni koşuda açık; kapatınca planın ekibinde kurucu yok,
  kartlarda ve kişi dizisinde kurucunun yüzü yok (`a4_six_founder_off`); sprint sürerken ve kurucu Ar-Ge'deyken basılmaz.
- A5b Seçilemeyen kişi nedeniyle görünür: eğitimde (`a4_empty`), izinde ve araştırmada (`a4_fifty`); yalnız Destek'teki
  kişi dizide yok, ekip rozetinin ipucunda "sprint dışı" sayısında.
- A6 Sprint sürerken "Sprinti başlat" yok, yerine "SPRINT %{n} bitti"; yüzde ve ipucu E1 birimiyle; hazırlanmış kart
  yokken yüzde `done_points ÷ used` ile ±1 eşit.
- A7 Kartsız planda başlat "0 kart" ekiyle açık; basınca boş sprint başlar; "Bu sprinti boş geçir" yok.
- A8 Hiçbir ipucunda şu parçalar yok: "hızı en çok kısan", "en iyi kişiler atanır", "aşaması bitene kadar", "ekipte iki",
  "en zor işe", "kilitli", "%25 daha hızlı", "hata ×", ". hafta" (kart ipucu, KR24). Tarama `strings.csv`'nin TR ve EN
  değerlerinde, §11.1'in ve §11.2'nin okuduğu her anahtarda yapılır (U6; ipucu metni yalnız bu anahtarlardan kurulur).
- A9 Oyuncu metninde tire yok; bütün yeni anahtarlar TR ve EN; `loc_csv_integrity` ve `loc_residue` temiz.

**Zaman ekseni.**
- A10 Z1 ile Z5 smoke `sprint_timeline_matches_play_out`'ta yeşil; kasıtlı bozulmada (Z2'yi bozan yerleşim) düşer.
- A11 Her `live:a4_*` karesi modelin zaman ekseninden her satırın ilk öğesinden son öğesine boşluk kalmadığını sayar
  (A4'ün `check_row` kuralı, Z3'ün kare karşılığı) ve `PRODUCTSHOT` satırında `row_gaps=` basar; 0 olmalıdır.
- A12 Z6: `--sprint-probe` 1, 3, 6, 12, 25, 50 kişide `^SPRINTPROBE` satırları U1 öncesi HEAD ile bayt eşit.
- A13 Erken biten planda (`a4_early`) bayrak ve "SPRINT ERKEN BİTER" görünür ve motor o haftanın sonunda kapanır.
- A14 Koşan sprintte (`a4_run_w2`) şimdiki an çizgisi saatle ilerler (iki saat arayla iki kare); hafta sınırında
  ekranın "yapılan"ı motorun ilerlemesine eşittir (Z5).

**Kurucu ve görüşmeler.**
- A15 Kurucunun haftasına iki satış görüşmesi düşen planda (`a4_six_meetings2`) kurucunun çubuğunda iki günlük tarama,
  Geliştirme ekibinin gücü kurucunun 2 günü kadar düşük, kart bitmiyorsa kırmızı ve "yetişmez".
- A16 Term sheet masası (`a4_run_table`) iki günlük tarama çizer.
- A17 Birim: tek bir satış görüşmesi 1 günlük tarama (0,2 hafta) ve haftanın beşte biri kadar güç kaybı üretir
  (§7.3 bulgu); tutmazsa U1 durur.

**PM, hata, taşma.**
- A18 PM'in hazırladığı kartta gölge görünür ve gölgenin ucu hazırlanmamış hâlin bitişidir; 5★'ta 2★'tan uzun
  (`a4_six_pm5` ile `a4_six_pm2` yan yana).
- A19 Hata göstergesi PM'in hazırladığı kartta hazırlanmamış hâlinden az dolu.
- A20 Taşma: aşamanın "+{n}"i zaman ekseninin o aşamadaki sprint dışı paylarının toplamına eşit; DEVREDEN'in toplamı da
  (yuvarlamadan ±1). Testçisiz planda (`a4_devs3`) Test satırının oluğu geliştiricilerin Test'te ürettiği efordur (E2).
- A21 Aynı aşama art arda üçüncü sprint taşınca "3." rozeti ve sıcak satır (`a4_eleven_streak`).

**Ölçek ve dil.**
- A22 50 kişide (`a4_fifty`) 9'dan kalabalık aşama yıldız kümesi olur; eğitim ve araştırmadakiler soluk kümede, nedeni
  yazılı; ekip rozeti görünür.
- A23 EN karede (`a4_eleven_tip --lang=en`) uzun ad iki satıra kırılır, hiçbir metin kesilmez; aynı adlı iki kişi
  ipucunda tam adla ayrılır.
- A24 1,25 ölçekte (`--shot-scale=1.25`) 06 ve 11'de metin kesilmez, düğme taşmaz.
- A25 Renk körü paletinde (`--palette=cb`) 04 ve 12 okunur; `--theme-contrast-audit` 0 ile çıkar.

**Tema ve süre.**
- A26 Archivo bütün koyu yüzlerde; `THEME_STAMP` arttı; iki tema yeniden üretildi; `glyph_audit` boş.
- A27 50 kişide plan ekranının ilk karesi (`PLANMS`, adayların "+"ı ertelenmiş, U1 cevap 19) ≤ 100 ms; adayın "+"ına
  gelme ≤ 100 ms.
- A28 Planlama, normal haftada şirketin mesai başlangıcında (`WorkHoursSystem.start_hour()`) saat durmuşken görünür;
  08:00 ile mesai başlangıcı arasında saat akar (U5, §8.1). Mesai 10:00'da başlayan şirkette plan 10:00'da açılır.

**Temizlik.**
- A29 `SprintCard`'da yalnız ÇEYREK'in kullandığı görünüm kalır; `ProductFixtures` ve `set_source` yok; §11.3'ün
  okuyucusu kalmayan anahtarları silindi (grep kanıtı); kod haritası ve HARITA aynı commit'lerde güncel.

## 15. Açık kalan (park)

Hiçbiri geliştirmeyi bloklamaz: her biri için ekranın bu görevdeki davranışı yazılıdır.

| # | Konu | Neden park | Bu görevde ekran ne yapar |
|---|---|---|---|
| P1 | Modülün kademesiz ilerleme gösterimi (A4 NOT_DONE 5) | Kademe kalktı (KR7); yerine ne konacağı Erdem'in kararı | Modül satırı: işaret, ad, "planda". Seviye, sözcük, cümle yok |
| P2 | Üst barda gün adı ve gün düzeyinde zaman (A4 NOT_DONE 2) | Oyunda bir tik bir hafta; gün kavramı ayrı karar | İpuçları hafta yazar; görüşme günü yalnız tarama uzunluğu (KR24) |
| P3 | Kompakt pano (kare 9'un 32 px gruplu panosu) | Bugünkü katalog bir planda en çok 14 kart taşır (D v2 D2c satırı); kompakt pano tetiklenemez, yazılırsa ölü kod | Normal pano kayar, "aşağıda N kart daha" |
| P4 | Çok sprintlik büyük kart ("2/3", kesikli devam; kare 2, 15) | Kart türü yok (EK "büyük modül birkaç sprint sürebilir, ileride eklenecek") | Büyük kart sprint dışı payla çizilir |
| P5 | Mevzuat talebi, 10 modül ve beşinci açık talep (kare 15) | Pazar 2 ve C; bugün ERP'de talep alabilen hat 4 (Entegrasyonlar 1, Güven 2, Onboarding 1), Çekirdek talep almaz (U1s cevap 1) | Bugünkü alanlar ve talepler |
| P6 | Kartın taşma sayacı ("N. kez taşıyor", kare 15) | Karar 22 aşama sayacıdır; kart başına sayaç kararı yok | Yalnız aşamanın süreklilik rozeti |
| P7 | "Kurucu bir kart alır, başkası yardım etmez, bitince başka karta geçmez" kuralı (A4 NOT_DONE 3) | Atama kuralıdır, D2a ve kurucu araştırmasının; kartı kimin seçeceği de orada (KR20 gereği sistem) | Kurucu motorun atadığı her kartta görünür; kırmızı kural §7.4 adım 13 |
| P8 | Aşama kişi tavanı ve gereksinim "≥{n}★" (D'nin K4'ü) | D2a | Veri gelince ipucunda ve ihtiyaç kutusunda görünür (sözleşmede alan hazır) |
| P9 | Merdivenin 3. basamağının geliştirici ve testçi için önden geçişi (kare 17) | D2a | Bugün yalnız tasarımcı ve PM önden gider; sağ sütun veriyi neyse onu çizer |
| P10 | PM yokken hazırlığı bir geliştiricinin üstlenmesi | Erdem 2026-10-23: "fikir olarak not" | PM yok: hazırlık yok |
| P11 | "Özenli" ve "Aceleci" etiketi | D5b park (tanımı yok) | Kart ipucunun künyesinde yok |
| P12 | Haftanın sınırının (kapanış, kâğıt zarı, atama) mesai başlangıcına taşınması ve gece acil durumunda planın gece saatinde görünmesi | D2a'nın sınır taşıması (D v2 §1 D2a satırı) | Planın görünme anı U5'te mesai başlangıcına taşındı (§8.1); sınırın hesabı bugünkü gibi gece; gece acil durumu §8.2 |
| P13 | "Teknik" çipi ve tasarımsız özellik kartı (KR14'ün ikinci yarısı; A4 kare 2, 20, 21; kare 20 ve 21'de kurucunun Test satırı da bu karttan gelir, U1s cevap 2) | Bugünkü katalogda tasarımsız özellik kartı yok (`sprint.json` `need`: düzeltme dışında her profilin tasarımı var); çip yazılırsa ya ölü kod olur ya bütün düzeltme kartlarına çıkar | Durum yuvasında yok; düzeltme kartı tür ikonu ve hata metniyle ayrışır. Kart sistemi PRD'si tasarımsız kartı getirince çip ve `PRODUCT_TECH` anahtarı o adımda eklenir |
| P14 | v1.0'a kadar sabit "Bu çeyrek: Çekirdek" (A4 kare 1, 20, 21) | Dayanağı yok: ne Erdem'in kararı ne PRD_FAZ_D Karar 12 ne D8b; D'nin kuralı "dayanağı olmayan parça commit'e girmez" | Seçici v1.0 öncesi de açık, hedef yokken "Bu çeyrek: hedef yok" |
| P15 | Birden çok hesabın aynı kart talebinin tek satırda gösterimi ("ve 13 hesap"; A4 NOT_DONE 6) | A4'te açık | Her talep ayrı satır, "+{n} talep" katlaması |

Onay bekleyenler (park değil, bloklamaz): §11.1'in bütün metinleri (TR/EN onay bekliyor; "Kurucu sprintte" adı
dahil); hata göstergesinin üçte birlik düzey dilimleri [WORKING] (§7.3 R1); görüşme günlerinin değeri D1b'de Erdem'in
1 / 1 / 2 gününe göre (§7.3 bulgu); "puan" yerine "efor" yazan üç bugünkü anahtarın yeni değeri (§11.1 sonu); TR mono
işaretlerinden "İK" (İlk kullanım) ve "EN" (Entegrasyonlar) başka anlamlarla karışabilir (insan kaynakları, İngilizce):
metin turunda Erdem'e gösterilir, değişirse yalnız CSV değeri değişir.

---

### Ek: maketteki çizim kodunun yerleri (piksel başvurusu)

`gen_A4.py`: kapasite `cap_block` :273 ve `people_line` :226; zamanlama (D2a'nın davranış örneği) `schedule` :411,
`lay` :533; çubuk `stage_html` :648; satır `card_row` :870; pano `board` :956 ve `board_head` :927; sol sütun `left_col`
:1048; sağ sütun `next_col` :1124 ve `pm_row` :1108; alt şerit `foot` :1296; pencere `window` :1267; kart ipucu
`card_tip` :1564; CSS :2000-2565; kareler `STATES` :1969.

---

## Denetimde değişenler (2026-10-23)

Denetim Erdem'in kararlarına (`ERDEM_KARARLAR_2026-10-20.md`), koda (çalışma ağacı, HEAD `4482d5f3` + D1b farkı), D'nin
`ADIM_TABLOSU_D_v2.md`'sine ve CLAUDE.md'ye karşı yapıldı. Anılan dosya:satır'ların hepsi kaynakta doğrulandı; yanlış
çıkanlar aşağıda.

1. **A4 onayı.** "A4 onaylanan dil" ifadesi kaldırıldı: `ERDEM_KARARLAR`'da A4 kaydı yok (A2 ve A3 var). U2 ile U6, Erdem
   A4'ün karelerine baktıktan sonra başlar; U0, U1, U1s beklemez (başlık, §1, §13).
2. **KR11 (plan saati).** Erdem'in 2026-10-23 düzeltmesi ("sabit 08:00'de değil, şirketin mesai başlangıcında") PRD'de
   "pazartesi 08:00" diye yazılmıştı ve A28 08:00'i sınıyordu. Hedef mesai başlangıcı oldu; taşıma D2a'nın (park), o
   gelene kadar 08:00 (§3, §8.1, §8.2, A28, P12). Erdem'e soru gitti.
3. **Kart ipucunda hafta yok (KR24).** Erdem A2'de ipucundaki "1. hafta / 2. hafta"yı sorgulamıştı; PRD "Biter: {w}.
   hafta" ve görüşme satırına hafta yazıyordu. Son satır "Sprint sonuna yetişir / yetişmez" oldu (`PRODUCT_DONE_BY` yerine
   `PRODUCT_ON_TIME`), görüşme satırı haftasız (§4.8, B5, A8).
4. **Kimlik çakışması.** Kararlar K1 ile K27, kart ipuçları K1 ile K11, kademe etiketi K1 ile K3 ve D'nin K4, K6, K7
   soruları aynı adı taşıyordu (§7.4 ve P8 D'nin K4'ünü kastediyordu, bu belgenin K4'ü "SP yok"tu). Kararlar KR, kart
   ipuçları KT oldu; D'ninkiler "D'nin" diye yazılır. Kopuk iki atıf düzeldi (§7.2 S1, §7.2 E1).
5. **Kapasitenin oluğu (E2, yeni).** Bugünkü motorda kişi rolü dışındaki aşamada da çalışır (yarı hız; testçi yokken testi
   geliştirici yapar, kurucu her aşamada, PM D4'e kadar ilk fazda: `sprint_system.gd:1112-1158`). "Satırdaki kişilerin
   puanı" oluğu bu işleri yanlış satıra yazar ve testçisiz planda Test'i "Efor 8 / 0" gösterirdi. Oluk zaman ekseninin
   ürettiği işten kurulur; dış ve iç taşma bundan türer (§7.3 E2, V4, Z7, A20, kare 02).
6. **Seçilemeyen kişi.** İzindeki çalışan (`STATUS_ON_LEAVE`) eksikti ve `team()`'e girmediği için dizide nedensiz
   kayboluyordu: "izinde" eklendi; yalnız Destek'teki kişinin dizide görünmediği ve kurucu kapalıyken hiçbir satırda
   olmadığı yazıldı; kaynak satırları düzeldi (§4.4, §7.2, V5, `PRODUCT_AWAY_LEAVE`, `PRODUCT_CREW_TIP`, A5b).
7. **Görüşme defteri (V10) ve D1b bulgusu.** Görüşme saatini yazan yol `TimeManager.advance_hours(n, true)`
   (`time_manager.gd:172`) imiş, PRD'nin saydığı `_close_sitting`'ler değil; U1'in dosyalarına `time_manager.gd` girdi,
   tür bu parametreyle taşınır. Ayrıca `MEETING_DAYS` hem saatin ilerlemesini hem payı verdiği için 1 / 1 / 2 güne
   çekilince term sheet masası hiç açılmaz (`sitting_open`, `work_hours_system.gd:57`): D1b'ye türetilen kural yazıldı
   (§7.3, §12 madde 6).
8. **D'nin W2 metinleriyle çift anahtar.** PRD, W2'nin zaten yazdığı anlamlara yeni anahtar açıyordu (`PRODUCT_GOAL_LABEL`
   / `_NONE`, `PRODUCT_STREAK`, `PRODUCT_DELEGATE_BACK`, `PRODUCT_STAGE_REQ`, `PRODUCT_NO_PM_TIP` kilit ipucunda). W2'nin
   anahtarları alındı, "Hatalar" seçeneği eklendi, W2'nin bu ekranda okunmayacak maddeleri ayrıldı; ÇEYREK'in PM kilidi
   ve `PRODUCT_QUARTER_NEED_PM` kalır (W2'nin "ölü olur" notu geçersiz) (§4.1, §4.3, §11, §12).
9. **Dayanaksız ya da tetiklenemeyen öğeler park.** "v1.0'a kadar sabit Çekirdek" hedefi (dayanak yok, P14), "teknik" çipi
   (bugünkü katalogda tasarımsız özellik kartı yok; düzeltme kartlarının hepsine çıkardı, P13), çok hesaplı talebin tek
   satırı (P15). İlgili anahtarlar (`PRODUCT_GOAL_FIXED_TIP`, `PRODUCT_TECH*`) listeden çıktı.
10. **Veri sözleşmesinin eksikleri.** `quarter` PM'siz de dolar (bugünkü `_quarter` PM yokken erken dönüyordu, başlıktaki
    seçici boş kalırdı); başlatın `start_skips` alanı ve "kartsız"ın tanımı (kapısı açık kart yok); efor tam sayıya
    yuvarlanır; ilerleme E1 birimiyle; aday düzeltme kartında hata sayısı (modülün hata listesi kalkınca hattın hatası
    görünmez oluyordu, Destek raporunun düğmesi oraya iniyor); D1'in "yeni alan" iddiası düzeldi (`d325f885` alan açmadı,
    PM alanları D4'ün) (§4.2, §4.5, §7.1, §7.2, V8).
11. **CLAUDE.md uyumu.** KR4'e göre aynı pencerede "puan" yazan üç anahtar efora döndü; `PRODUCT_ADD_FULL` diye bir
    anahtar yokmuş (`PRODUCT_ADD_CLOSED_FULL`); satır başı büyük harf kuralı ekrana uygulandı; eski model alanları U7'ye
    bekletilmez, son okuyucusunu değiştiren adımda silinir (§8); U0 temaları commit'e girer, `project.godot` girmez;
    kaydeden `--modal-shot` ayrı `APPDATA` ister; Archivo üst bar ve haber şeridine de geçer (`Chrome*` krem temada,
    `build_theme.gd:81-85`), gazete hariç; yeni smoke'un §10 gerekçesi yazıldı.
12. **Silinecekler ve adım tablosu.** §11.3'e okuyucusu kalmayan kod eklendi (`lead_sentence`, SPRINT SONUNDA önizlemesi
    ve onu okuyan iki smoke iddiası, modülün hata satırları, `BUTTONS`'un iki kolu, `live:plan`'ın "boş geçir" karesi);
    `PRODUCT_THIS_SPRINT` silinecekler listesinden çıktı (ÇEYREK okuyor). `live:a4_*` dünyaları U7'de kuruluyordu ama U2
    ile U6'nın kapıları onlara bakıyordu: yeni U1s adımı (3 sa) onları U2'den önce kurar; U7 5 saate çıktı, toplam 49 saat.
    Plan ekranının süre tabanı 96 ms'ye yakın olduğu için zaman ekseni `plan_outcome` ile tek oynatmayı paylaşır (§7.5).
    D v2'de yardımcı yönetmenin düzeltmesi gereken altı satır §12'ye yazıldı.



## Erdem'in cevapları (2026-10-23)

1. A4 kod başlamadan Erdem'e gösterildi (görsel sayfa); U2'nin başlama şartı Erdem'in A4 cevabıdır.
2. Planın görünme anı şimdi mesai başlangıcına taşınır (KR11, §8.1, A28, U5 güncellendi; P12 yalnız sınırın taşınmasını tutar).

## U0 uygulama cevapları (yardımcı yönetmen, 2026-10-23)

1. Chrome*: master'ın `ChromeValue`, `ChromeClock`, `ChromeAlert` varyasyonlarına dokunulmaz. TopBar ve NewsTicker zaten
   `menajer_theme.tres` okuduğu için koyu yüzlerle Archivo olur. Okuyucusu olmayan Chrome* varyasyonları genel temizlik
   görevine not edilir. §9.1'in "krem temanın Chrome* varyasyonlarını okur" cümlesi bu cevapla geçersizdir.
2. `d_wide_b` ve `d_num` ilk okuyan adımda (U3) kurulur; U0 okuyucusuz varyasyon kurmaz (CLAUDE.md §8).
3. Archivo'nun bütün yüzlerinde `tnum` açık.
4. Harf aralığı: `d_cond_sb_caps` ve `d_sansc_caps` 1 px (bugünkü).
5. Yedek zincir: 800 yüzler Plex Bold, 650 Plex SemiBold, 500 ve dar sütun Plex Regular. Okuyucusu kalmayan Plex Medium,
   Plex Sans Condensed ve Barlow Condensed silinir; `data/credits.json` ve lisans ekranı aynı commit'te güncellenir
   (Archivo OFL eklenir, silinen yazı tipleri çıkar).
6. `d_sans_med.tres` silinir; okuyucuları `d_sans_reg`'e (Archivo 500/100) geçer.
7. Marka lock-up'ı: `tools/brand/make_lockup.py` Barlow Condensed Bold okuyor. Font ve OFL'i `tools/brand/`'e taşınır,
   `tools/brand/.gdignore` eklenir; lock-up ve logo değişmez, oyun Barlow taşımaz, lisans ekranından çıkar.
   `docs/design/ART_BIBLE.md` yazı tipi satırı "Archivo, Source Serif 4" olur.
8. Dar yüzler: PRD §9.1'in genişlik değerleri büyük harf etiketlerde Barlow'a göre %26 ile %69 genişliyor ve üst bar,
   Satış ve Ekip'te bitişme ve kesilme yapıyor (U0 kareleri). `d_cond_*` dört yüz Archivo genişlik 62'ye iner, ağırlıklar
   §9.1'deki gibi; öbür ekranların yerleşimi değişmez. Kalan taşmada önce o yüzün harf aralığı 0 olur; yine kalırsa
   yerleşime dokunulmaz, yardımcı yönetmene gelinir. A4'ün geniş yüzleri (göz başlığı 110, "SPRINT N" 118, pencere başlığı
   78) U3'te sprint ekranının kendi varyasyonlarıdır.

## U1 uygulama cevapları (yardımcı yönetmen, 2026-10-24)

Ürün arayüzü oturumunun U1 öncesi 11 sorusu (HEAD `10b2a27`) ve K02 iş bölümü.

1. **Aynı adlı, farklı biçimli beş alan** (`center.capacity`, `center.cards`, `center.delegate`, `next.cards`,
   `quarter.goal`): U1 bunları eklemez. Her biri onu çizen adımda yeni biçime geçer, eski biçim aynı commit'te silinir:
   `capacity` ve `quarter.goal` U3'te, `cards` U4'te, `delegate` ve `next.cards` U5'te. Geçici ad açılmaz. Bu alanların
   motordan okuduğu yüzeyler U1'de kurulur ve smoke ile sınanır: `timeline()`, `away()`, `progress_at_start`, H ile
   H0'ın okunuşu, kart başına hazırlık. U3, U4 ve U5 yalnız sözlüğü dizer. U1'in çakışmayan yeni alanları: founder,
   requests, modules, prep, quarter.q/year/pos/total, center.now_at/crew/suggest/candidates/close_at/progress/
   start_skips/team_empty/mvp, next.load/carried.
2. **Metin anahtarları:** U1 okuduğu §11.1 anahtarlarını `strings.csv`'ye bayt kesmeyle ekler. Commit "TR/EN onay
   bekliyor" der. Token'lar iki dilde aynıdır.
3. **`modules[].open`:** yoktur. Çizim `ui.open_area`'yı okur, çünkü sekmenin yerel durumudur.
4. **V3, çeyreğin başlangıcı:** çeyreğin döndüğü yerde ve `new_state`'te `quarter.start_day` yazılır. Varsayılanlı alandır,
   şema açmaz. Erken kapanan sprintler yüzünden türetme kesin değildir; türetme
   (`sprint.start_day − (pos − 1) × sprint_weeks`) yalnız alanı olmayan eski kayıtta kullanılır.
5. **V2'nin "{q}. çeyrek" kolu:** q, o ürün çeyreğinin ilk sprintinin tahmini başlangıcının takvim çeyreğidir. Tahmin:
   bugünkü sprintin `start_day`'i + aradaki sprint sayısı × `sprint_weeks`. Ekrandaki tek çeyrek kavramı ürün çeyreğidir
   (V3).
6. **Süreklilik rozetinin n'i:** okunuş (a). Plan o aşamada taşıyorsa n = kaydın `streak`'i + 1, taşımıyorsa rozet
   yoktur. Rozet yalnız n ≥ 2'de çizilir (§4.4: "art arda 2 ve daha çok sprint"). Koşan sprintte de aynı kural uygulanır,
   `out` zaman ekseninden okunur.
7. **Öneri satırı:** `center.suggest`, planlamada ve devir kapalıyken, öneri plana en az bir kart ekleyecekse doludur;
   n eklenecek eforun miktarıdır. Ekleyeceği kart yoksa `null`'dır ve satır çizilmez. Oyuncu bir kartı çıkarınca satır
   kendiliğinden geri gelir. `sprint.lead_applied` bayrağı bu kuralla gereksizleşir ve son okuyucusunu silen adımda (U3)
   silinir.
   - **Not (yardımcı yönetmen, 2026-10-26):** öneri büyük ekipte idempotent değil (6. basamağın kalkanı çağrı başına
     sayılır), bu yüzden bayrak kalır ve satır plan değişince döner. Bayrağı plan değişikliği (ekle, çıkar, "→", "↑"),
     Kurucu sprintte anahtarı ve hedef seçimi indirir; devir aç/kapa indirmez (2026-10-27). Ekip değişimi de indirir
     (kişi sayısı ya da sprint kapasitesi değişince; U5, 2026-10-27). Kapasite 0 iken `apply_lead` bayrağı yazmaz (U4).
8. **EKLENEBİLİR (a):** her aday boş plana tek başına eklenmiş gibi oynatılır, çünkü "+" tek kart ekler. Üretici "plan +
   bir aday" girdisini alır. Üç küçük oynatma PLANMS ≤ 100 ms kapısının içinde kalmalıdır, 50 kişide ölçülür.
9. **Hata göstergesi (R1):** H ve H0 oynatma kopyasından, atanan geliştiricilerin yıldızıyla okunur. H0, aynı kopyanın
   PM hazırlığı olmadan hesaplanan değeridir.
10. **Sonraki kartın `prep {pm, done}`'u:** `ready` ile aynı kural geçerlidir. Planlamada oynatmanın sprint sonu kullanılır,
    koşan sprintte ve sürüm notunda bugünkü değer.
11. **Tek kurucu (E2):** kurucunun harcanmayan puanı oluk hesabında V4'ün kurucu kuralıyla tek satıra yazılır: zaman
    ekseninde en çok çalıştığı aşamaya, hiç çalışmıyorsa Geliştirme'ye. Böylece Z7 tutar. Üç satırı saran parantez ve
    kesikli uçlar U3'ün çizimidir.

**K02 (C2):** iki parça da U1'de yapılır: `remove()` takip kartını (`follow`) reddeder, `ProductModel` o kart için
"Kaldır" düğmesini vermez. GOREV_TEMIZLIK C2'yi zaten dışarıda bırakıyordu. Bu bir hata düzeltmesidir: kâğıdın bedeli
bedavaya silinmez. Smoke vakası ve falsification şarttır.

12. **PLANMS ölçütü** (6e'nin erken uyarısı: `10b2a27`'de U1'siz team=12 ortanca 88, en çok 132 ms):
    - Kapı ortancadır: 50 kişide en az 9 ölçümün ortancası ≤ 100 ms. En çok değer rapora yazılır ama kapı değildir.
      Paylaşılan makinede tek aykırı değer bellek ve öbür oturumun koşusundan gelir.
    - Ölçüm sessiz makinede alınır: D'nin kapısı koşmazken, tek Godot. Önce ve sonra aynı koşulda alınır.
    - Taban (D8a'nın hash'i, U1'siz) zaten 100 ms'yi aşıyorsa U1'in hedefi iki şarttır: U1 tabanı en çok %10 artırır,
      ve §7.5'in çareleri sırayla denenir (önce `mvp_eta` kurulum başına bir kez, sonra karelere bölme). İkisinden sonra
      ortanca hâlâ 100 ms'nin üstündeyse adım commit'ten önce durur ve sayılarla yardımcı yönetmene gelir.
    - Adayın "+"ına gelme (hayalet) için de aynı ölçüt.

**U1 commit öncesi beş soru (2026-10-24):**

13. **Testin bulduğu hatanın düzeltme işi (D3).**
    - Veri: zaman ekseninde kartın dördüncü girdisi `{stage: "dev", fix: true}` yalnız düzeltme işi varsa, Test'ten sonra.
      Z2 gevşemez.
    - Kartın kendi eforu (`cards[].effort`, `suggest.cards[].effort`) bulunmuş düzeltmeyi sayar (E1: kalan ihtiyaç).
      Oynatmanın öngördüğü, henüz bulunmamış düzeltmeyi saymaz. Test bitip hata bulununca kartın eforu büyür; bunu
      oyuncu görür.
    - Aşama satırının dolgusu (E2) öngörülen düzeltmeyi de sayar. Satırın sayısı ve taşması oynatmanın yaptığı işle aynı
      kalır (tahmin = sonuç, Karar 9).
    - Gösterim (U4): planlamada ve test bitmeden dördüncü parça çizilir (kartın gerçek bitişi), ama ekranda da ipucunda
      da hata sayısı yazmaz. PRD_FAZ_D Karar 9: "plan sayıyı bulur ama göstermez". Sayı test bitince kartın "Test: N
      hata buldu" satırıyla gelir (D3).
14. **L1 talep ipucu:** (a). Değer var olan `PRODUCT_PER_YEAR` ile yazılır, `PRODUCT_TIP_VALUE` §11.1'den çıktı. L1
    satırı buna göre düzeldi.
15. **Görüşme kalemi:** sözleşmedeki biçim geçerlidir: `kinds: [..]`, o haftanın donan defterindeki türler. §7.2 düzeldi.
16. **Sürüm notu kipinde `next.load` ve `next.carried`:** (b). Sayıları planlamanın kullandığı aynı işlev hesaplar,
    ikinci bir formül olmaz. Sürüm notunda sağ sütun gelecek sprintin yükünü gösterir. Planlamada `plan_next`
    (`sprint_system.gd:189`) o sütunu sprintin kendisine taşır: aynı iş orta sütunun kapasite satırlarına geçer, sağ
    sütun yeni ve boş bir sonraki sütunla başlar.
17. **Zaman ekseni sözleşmesine eklenen alanlar:** kabul, §7.4'ün sözleşmesine yazıldı. -1'in anlamı "bu eksende aralığı
    yok" olarak genişledi. Koşan sprintte eksenden önce biten aşama `before: true` taşır, -1'e ikinci anlam yüklenmez.
    Alanlar D2a'nın da sözleşmesidir.

18. **Sözleşme düzeltmesi (2026-10-24):** `ahead: bool` kişinin parçalarındadır (`people[id].pieces[]`); sprint kartının
    aşama parçası önden iş olmaz. Sonraki kartın hazırlığı `ahead[card].prep {by, done}`; kart düzeyindeki `prep` ile
    aynı ad.

19. **PLANMS aşımı (2026-10-24).** 6e'nin sayıları: D8a `569c843` tabanı sessiz makinede 50 kişide ortanca 138,5 ms (en
    çok 155,6). Döküm: adayların `can_add`'i 12 × 5,4 ≈ 65, lider önerisi 21, `mvp_eta` 13, `plan_outcome` 2,7, kalanı
    modelin kurulumu. U1 ≈ 9 ms ekliyor (sessiz olmayan iki çiftte +%7). Aşım U1'den önce var. En büyük parçası sol
    sütunun "+"ıdır ve 100 ms'nin altına ancak o ertelenince inilir.
    - **U1 (b) ile commit edilir.** Kapısı: resmî "sonra" ölçüsü tabanın en çok %10 üstüdür, yani ortanca ≤ 152 ms. Ölçü
      D'nin son ölçümü bittikten sonra sessiz pencerede alınır (tek Godot, en az 9 ölçüm). Aşarsa adım durur. Rapor
      tabanı, sonrasını ve dökümü yazar; hayaletin (adayın "+"ına gelme) önce ve sonra sayısı da rapora girer.
    - **Çare 1 tutuyor** (`mvp_eta` kurulum başına bir kez). Kurulumlar arası önbellek şart değil. U3 (MVP rozeti) ancak
      ilk karenin kapısı için gerekirse yapar.
    - **≤ 100 ms kapısı U2'ye geçer** ve sonraki her U adımında sürer. Sol sütunu (`AreaPanel`: adaylar, Müşteri
      talepleri, "+") adım tablosunda U2 yeniden kuruyor, U3 değil. Karelere bölme sol sütunu kuran adımda yapılır;
      sol sütun iki kez yazılmaz.
    - **Karelere bölmenin tanımı (U2):**
      - Ertelenen yalnız adayların ve taleplerin `addable`'ıdır (`SprintSystem.can_add(id)`: kart başına bir
        oynatma). Kartsız `can_add()`, lider önerisi, `mvp_eta`, `plan_outcome` ve EKLENEBİLİR'in oynatmaları (cevap 8)
        kurulumda kalır.
      - `live()` ilk karede `addable: null` (bilinmiyor) verir. Panel değerleri sonraki karelerde ekrandaki sırayla,
        yukarıdan aşağı ister. Her karede en az bir kart hesaplanır ve kare 8 ms dolunca biter. 50 kişide on iki aday
        yaklaşık altı karede gelir (60 fps'de ≈ 0,1 sn).
      - Sonuç kart kimliğiyle sayfanın bir sonraki kurulumuna kadar saklanır. Yeni kurulum saklananı atar ve baştan
        başlar. Planlamada saat durduğu için durumu yalnız oyuncunun tıkı değiştirir, o da yeni kurulumdur.
      - Bilinmeyen "+" kapalı ve nötr çizilir: basılmaz, kilit görünüşü ve ipucu taşımaz. Değer gelince açık ya da
        kapalı hâline geçer.
      - Oynanış değişmez: değer aynı işlevden gelir, ikinci bir formül yoktur.
      - `PLANMS` iki satır basar: ilk kare (`live()`) ve toplam (ilk kare + bütün ertelenen `can_add`'ler). Koşu
        erteleme bitince her adayın ve talebin değerini `can_add(id)` ile karşılaştırır ve uyuşmazlıkta 1 ile çıkar.
        Yeni smoke vakası yok (CLAUDE.md §10).
      - Kapı ilk karenin ortancasıdır: ≤ 100 ms, 50 kişi, en az 9 ölçüm, sessiz makine. Toplam rapora yazılır, kapı
        değildir. Beklenen ilk kare ≈ 148 − 65 ≈ 83 ms. U2'de ilk kare yine 100'ü aşarsa adım durur ve sayılarla gelir.
## U1s uygulama cevapları (yardımcı yönetmen, 2026-10-24)

1. **Kare 15, açık talep sayısı.** Motor ERP'de en çok 4 açık talep kurar: her hesap tek talep açar, talep sektörün
   öncelikli alanındaki bir hattın sıradaki adımıdır, Çekirdek talep almaz, açık adım ikinci kez talep edilmez; ERP'nin
   bu alanlardaki hatları Entegrasyonlar 1, Güven 2, Onboarding 1. Kare 4 açık taleple kurulur, "+N talep ▾" katlanması
   yine okunur. Talep kaydı elle yazılmaz (U1s: model alanı elle yazılmaz). Beşinci talep katalog büyüyünce gelir (P5).
   Tür adı sayısız olur: `a4_requests` (U2 kapısı ve §5 buna göre).
2. **Kare 20, kurucunun satırı.** Kare bugün kurucuyu V4'ün söylediği satırda, Geliştirme'de gösterir. Maketin Test
   hâlinin sebebi tasarımsız teknik karttır (P13); kurucuyu Test'e itmek için yıldız ve kart boyu aranmaz: öyle bir
   fikstür bugünkü oyunun ilk sprintinin göstermediği bir hâli çizer ve pencereli koşu harcar. V4'ün kuralı U1'in
   birim kapısında. Tasarımsız kart katalogla gelince kare 20 ve 21 Test hâlini kazanır (P13 satırı).
3. **Kabul edilen okunuşlar.**
   - A23 ve kare 14: "aynı adlı iki kişi" adı aynı, soyadı farklı iki kişidir; ipucu tam adla ayırır.
   - Kapı 23 türdür; kare 14, 11'in türünü EN'de kullanır (adım tablosu düzeltildi).
   - Fikstür boyu: kartlar `card_need` ile kapasitenin katına ölçeklenir (6 kişi 1,15; 11 kişi 1,25; 12 geliştirici
     1,3; 14 kart 1,6). Düzeltme kartları `ProductState.add_bugs` ile açılır. Kare 01'in görüşmesi `vc`. Çarpanlar
     HARITA Ürün'ün tür listesine yazılır.
   - `SprintUiShared.effect_line`'ın sızıntısı U1s'te kapanır (dosya listesinin dışında ama "hatasız" kapısının şartı):
     etki yalnız hata satırıysa boş kap kurulmaz ya da serbest bırakılır, görünen değişiklik yok. Kanıt: düzeltme
     kartlı karelerde çıkıştaki `RID allocations ... leaked` satırı kaybolur. Commit mesajında ayrı cümle.
4. **Yüzler bitmeden kaydedilen kare (2026-10-24).** `a4_run_table` (TR, EN) ve `a4_twelve_dev` (EN) çıkışta yine RID
   sızıntısı basıyor ve PNG'de yüzlerin bir kısmı boş daire: `PersonBust` arka plan stüdyosunda karede bir yüz çiziyor,
   shot sıra bitmeden kaydedip kapanıyor. U1s'te düzelir: `PersonBust`'a salt okunur bir "sırada yüz var mı" sorgusu,
   `_product_a4_ready` yüzler bitene kadar bekler (üst sınır karelerle), sonra satırı basar ve kaydeder. Sınır dolarsa
   kare kaydedilmez, hata basılır ve koşu 1 ile çıkar (boş yüzlü kare sessizce geçmez). Sorguyu oyun kodu okumaz.
   İkinci inceleme yok; 46 koşu bir kez yeniden koşar. Yine düşen olursa ⚠️ ile commit'lenir ve raporlanır.

## Erdem'in A4 cevabı ve Faz D ekleri (yardımcı yönetmen, 2026-10-26)

Kaynak: `ERDEM_KARARLAR_2026-10-20.md`'nin 2026-10-26 bölümleri. **A4 onaylandı; U2 başlar.** Başlıktaki "U2, Erdem'in A4'e
bakmasını bekler" şartı karşılandı. Bu bölüm PRD'ye eklenir; PRD'nin geri kalanıyla çelişirse bu bölüm geçerlidir. Bir Opus
incelemesinin bulguları bu metne işlendi.

### Yeni adımlar

| Adım | Ne | Model (düşünme) | Süre |
|---|---|---|---|
| UD2 | Zayıf PM eşiği kalkar (Faz D kararı 4.10, Erdem'in vetosu) | Sonnet (xhigh) | 0,5 sa |
| UD1 | "Öneriyi uygula" sonraki sprint sütununu da doldurur (Faz D kararı 2 = B) | Sonnet (xhigh) | 2 sa |
| UM | Modül ve hat adları (Erdem: "Defter diye bir modül adı olmamalı") | Sonnet (high) | 1,5 sa + Erdem |
| UK | Kart başına aşama ve aşamanın yüzdesi (Erdem: "hangi proseste, testin yüzde kaçındayız, kart bazında") | Sonnet (xhigh) | 3 sa + Erdem |

Sıra: UD2 → UD1 → U2 → U3 → U4 → U5 → U6 → U7 → U8.
- UM, U2 ile paralel hazırlanır; onay gelince ayrı commit olur.
- UK'nin iki karesi U4'ün satırı çizilince Erdem'e gider. Cevap gelince UK, U4'ün ya da U6'nın commit'ine girer; beklerken
  U5'e geçilir.

### UD2: zayıf PM eşiği

- **Bugünkü kural:** Ürün **puanı** 3 ve altı olan PM'in (1★ ile 1,5★; puan 0–10, yıldız başına 2 puan) planı %20 daha az
  kart taşır. Kodda: `sprint_catalog.gd` `pm_plans`'taki `keep` çarpanı ve `data/product/sprint.json`'daki `pm.low_skill_cards`
  ile `pm.low_skill_max`.
- **Yapılacak:** çarpan, iki ayar ve "Ürün alanı zayıf PM'in planı daha az kart taşır" yorum cümlesi silinir. PM'in planı
  puandan bağımsız olarak tam kart taşır.
- **Kapı:**
  - `sprint_` ve `product_` öneki vakaları;
  - Z6 U1s HEAD'iyle bayt eş (sprint probe PM planını okumaz, fark beklenmez).
- **Değişikliğin kanıtı:** Ürün puanı 2 ya da 3 olan bir PM'le kurulan planda `SprintCatalog.pm_plans()`'ın sprint başına
  kart sayısı önce ve sonra rapora yazılır (ör. `product_pm_plan_opens_as_next_sprint`'in kurulumuyla).
- **Belgeler (aynı commit):** `GDDs/GUNCELLEMELER.md` ch03'e not: zayıf PM eşiği kalktı (Erdem 2026-10-26). Eşik cümlesi
  (`:243`) düşer. Kod haritası 02 de güncellenir.

### UD1: öneri sonraki sütunu da doldurur

**Bugün.**
- Sonraki sütunu yalnız oyuncunun "→"u ve **onaylanmış** PM planı (`plan_next`) dolduruyor. Onaysız `pm_plans()` hiçbir
  yere konmuyor.
- Planlama devredilmişken `_auto_start` bu sprinti `apply_lead()` ile dolduruyor.

**Kural (yardımcı yönetmenin kararları):**
1. **Bu sprint.** Öneri bu sprinti bugünkü gibi D8a'nın altı basamağıyla doldurur.
2. **Sütunun sırası.** Sütun için aynı `order` dizisi baştan dolaşılır ve bu sprinte giren kartlar atlanır. Bu sprintte
   sığmadığı ya da tavana takıldığı için atlanan kart sütunda yeniden denenir.
3. **Sütunun yerleşimi ve yükü.**
   - Yerleşim sütundaki kartlardır; oyuncunun ve onaylı PM planının kartları önde.
   - Alım sınaması aynı `SprintSystem.intake(placed, c, team())`'dir.
   - Başlangıç yükü: sütundaki kartlar artı bu sprintin oynatmasında sütuna devredecek iş. Bu, zaman ekseninin `out`'u,
     `ProductModel._carried`'ın okuduğu ve §4.7 "Aşama yükü"nün gösterdiği sayıdır.
   - Öneri, bu yükle birlikte ekibin kapasitesini **%100'ü** aşmayacak kadar kart ekler. %125'lik tavan sütunda kullanılmaz.
   - Kapasite bugünkü ekibinkidir: `SprintSystem.capacity_of`.
4. **Sınırlar.** D8a'nın sınırları sütun için ayrıca sayılır:
   - düzeltme payı kapasitenin yarısı;
   - art arda en çok 12 atlama;
   - sprintte düzeltme kartı yoksa ilk düzeltme kartı yine girer;
   - 6. basamağın kalkanı: yalnız bitecek kartlar, en çok bir devreden.
5. **Dönüş biçimi.**
   - `lead_suggestion()` iki liste döndürür: `{this, next}`.
   - `ProductModel._suggest` ve `_candidates` yalnız `this`'i okur.
   - `apply_lead` `next`'in kartlarını `_place(c, false)` ile sütuna koyar.
6. **Devirde de** öneri sütunu doldurur.
   - `_auto_start` bugünkü gibi `apply_lead()`'i çağırır; UD1'den sonra bu çağrı sütunu da doldurur.
   - Onaylanmış PM planı sütuna `plan_next`'te zaten girer ve oyuncunun koyduğu kart gibi kalır; öneri onun üstüne ekler.
   - Onaysız PM planı sütuna konmaz.
   - `set_delegate`'in yorumu "liderin önerisiyle başlar" diye düzeltilir.
7. **Öneri satırı.**
   - Satır, öneri bu sprinte **ya da** sütuna bir kart ekleyecekse görünür.
   - Sayı bugünkü tanımdır (U1 cevap 7, §7.2): önerinin **bu sprinte** ekleyeceği efor.
   - Öneri bu sprinte kart eklemiyor, yalnız sütuna ekliyorsa sayı ve "efor daha sığar" yazılmaz; yalnız "Öneriyi uygula"
     düğmesi durur.
8. **Kapı.**
   - Yeni smoke vakası `sprint_lead_fills_next_column`. Falsification: sütunu doldurmayan dalla düşmeli.
   - `apply_lead` ya da `lead_suggestion` çağıran bütün smoke vakaları koşulur; listeyi grep çıkarır. Beklentisi değişen vaka
     gerekçesiyle güncellenir.
   - `--run-log=full_run:104:sim:1` ve `full_run_b2c:104:sim:1` önce ve sonra koşulur (paralel olabilir, her süreç kendi APPDATA'sıyla). Rapora üç sayı yazılır:
     MVP haftası, son hafta, `PROBE PROMISE status=broken` sayısı. Bozulan söz sayısı artarsa adım commit'ten önce durur ve
     sayılarla yardımcı yönetmene gelir.
   - PLANMS 50 kişide ölçülür ve rapora yazılır. UD1'de kapı değildir; ≤100 ms kapısı U2'nindir ve önerinin sütun kısmını
     da kapsar (U1 cevap 19'un ertelemesi).
   - U1s'in 23 `live:a4_*` türü yeniden kurulur. Her türün `PRODUCTSHOT` satırı önce ve sonra rapora yazılır, `row_gaps=0`
     sürer. Karesinin anlattığı durumu kaybeden tür yalnız fikstür tarafında (`main.gd` `_A4_*`) düzeltilir.
9. **Belgeler (aynı commit):**
   - `GDDs/GUNCELLEMELER.md` ch03'e not.
   - CLAUDE.md §6 "PM hazırlığı" paragrafının "Sütun boşsa PM'in hazırlayacak kartı yoktur" cümlesi bugüne göre yazılır.
   - Kod haritası 02.

### UM: modül ve hat adları

1. Sayfa iki tablo taşır:
   - **Ekrandaki MODÜLLER, yani alanlar:** `PRODUCT_AREA_*` tam ad, `_SHORT` ve `_MONO`. ERP'de görünen dördü ve B2C'nin
     ikisi. §15'in "İK ve EN başka anlamlarla karışabilir" notu bu tabloyla Erdem'e gider.
   - **Hat adları:** `PROD_LINE_ERP_*`, `PROD_LINE_SHARED_*`, `PROD_LINE_HIDDEN_*`. Bunlar düzeltme kartının adında, olay
     çiplerinde ve Ar-Ge postasında okunur. "Defter" bu tablodadır. `note_tool` ve `video_clip` hatları dışarıda kalır;
     pazaryeri gelince silinecekler.
2. **Başlangıç önerisi** `docs/tasks/faz_cde/pazar2/out/SENTEZ_ERP_PAZARI.md` §3.1'in tablosudur (Erdem'in 26. kararı, 10 modül):
   - invoicing → Fatura; stock → Stok.
   - ledger ve cashflow tabloda "Finans ve Muhasebe" diye birleşir. Birleşme C'nin parktaki yapı işidir. UM anahtar
     değiştirmediği için ikisine ayrı ad önerir; ledger'ın adımları Ön Muhasebe, Hesap Planı, Otomatik Mutabakat'tır.
   - Tablo intake için "Satın Alma" der ama hattın adımları veri girişidir: iki seçenek sunulur.
   - Ortak hatlar tablodaki yazımla verilir: "&" yerine "ve".
   - Sayfa her satırda tabloya bağlı mı, sapıyor mu, onu söyler.
3. Ölçüt: kısa, ilk okuyuşta anlaşılır, gerçek bir ERP ürününde görülebilecek ad. TR ve EN birlikte.
4. Sayfa yardımcı yönetmene gider, Erdem'e o götürür.
5. **Onaydan sonra:** yalnız CSV değeri değişir, anahtar değişmez. Adın geçtiği öbür metinler aynı commit'te taranır:
   olay kartları, satış metinleri, düzeltme kartı adı. Eki ya da uyumu bozulan yer düzeltilir.
6. Kapı: `loc_csv_integrity`, `loc_residue`, glif denetimi.

### UK: kart başına aşama ve yüzde

1. Oyuncu koşan sprintte her kartın şimdi hangi aşamada olduğunu ve o aşamanın yüzde kaçının bittiğini görür
   (ör. "Test %40").
2. Önden yapılmış işi olan kart planlamada A4'teki gibi önden işi gösterir. Erdem'in "tasarım bitmiş görünüyor" sorusunun
   cevabı budur: tasarım önceki sprintte önden bitti.
3. **İki seçenek**, U4'ün satırı çizildikten sonra oyunun kendi arayüzünde, `live:a4_run_w2` dünyasında, TR karelerle:
   - **(a)** Yüzde kartın durum yuvasında. Koşan sprintte yuvanın sırası: "yetişmez" → "{aşama} %{n}" → söz tarihi çipi →
     "devreden". Planlamada sıra bugünkü gibi kalır.
   - **(b)** Yüzde, koşan aşamanın çubuğundaki "{yapılan}/{toplam}"ın yerine geçer. "{yapılan}/{toplam}" ipucunda
     (§11.2 B1) kalır.
4. Kareler yardımcı yönetmene gider, Erdem seçer.
5. Yüzdenin kaynağı modelin ilerlemesidir (Z5, E1 birimi); yeni hesap yazılmaz.

### A4 notlarının U adımlarına girişi

**N1. Mikro yazı çok (U2–U6).**
- Her adım ekrana koyduğu `D_FS_13` ve daha küçük her metin öğesini raporunda listeler: durum mu, açıklama mı.
- Açıklama ipucuna gider ya da silinir; durum kalır.
- Düzeltme kartının "5 hata · 3 hesap · 120 kullanıcı" satırı durumdur, kalır.

**N2. Çeyrek hiyerarşisi (U2, U3, U4).**
- "Bu çeyrek: {hedef}" başlık düzeyidir.
- Söz tarihi çipinin üç biçimi ("bu çeyrek", "gelecek çeyrek", "{q}. çeyrek"), sol sütunun talep satırında (§4.2, U2) ve
  kartın durum yuvasında (§4.5) aynı boydadır.
- `DueChip` ile `DueChipSoon` yalnız renkle ayrılır: "bu çeyrek" vurgu renginde, öbür ikisi normal mürekkeple.
- Maketteki küçük talep çipi örnek değildir (Erdem: "küçük yazılması kötü görünüyor").

**N3. "Teknik" etiketi.**
- P13 kapandı: "Teknik" çipi çizilmez.
- Kartın türünü (arayüz, backend, altyapı) gösteren alt etiket fikri kart yenileme turunun PRD'sine gider.

**N4. Taşma (U2–U8).**
- Oyunda hiçbir metin taşmaz ya da kesilmez; maketteki taşmalar örnek değildir.
- U8'in görsel sayfasında her kare için "taşma yok" satırı bulunur.
