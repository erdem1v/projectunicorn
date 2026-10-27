# U6 düzeltme turu (tek tur): Opus, W'de

S = /c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/cb69ca60-0d91-4669-bf47-f4c28dfeaca0/scratchpad
W = $S/w8/project-unicorn (yalnız burada düzenle), taban $S/b_u6/project-unicorn (dokunma). Paylaşılan ağaçta yazma, Godot koşma, git yazma yok.
Kodlayıcının raporu `$S/u6/coder_report.md`, görev tanımı `$S/u6/brief.md`, inceleme `$S/u6/review.md`.
PRD: `C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md` (§4.8, §11.1, §11.2 ve altındaki U6 notu, KR24).
CLAUDE.md kuralları (W'deki): renk/boyut UiTokens'ta, tema build_theme.gd'de, eskisini aynı adımda sil, metin anahtar olarak doğar,
`strings.csv` yeniden yazılmaz (bayt aralığını değiştir; Python ile `open(...,'rb')`, yalnız hedef satırın baytları; satır sonları ve tırnaklar aynı kalır).
Kodun çevresine benzesin (yorum yoğunluğu, adlandırma). Geçici kanca/döküm bırakma; bitince `grep -rn "U6TEMP\|u6_dump" W/scripts` boş olmalı.

## A. Yönetmenin kararları (2026-10-27; PRD §11.2'nin altındaki U6 notu)
1. Aşama çubuğunun (B1) üstünde yalnız B1'in düz ipucu açılır; zengin kart paneli (CardTip) YALNIZ kart adında açılır. KT1'in "ve çubuklar" kısmı düşer;
   çubuktaki `tip_panel`/zengin panel yolu kalkar, panelin en üstüne yazılan soluk B1 satırı da kalkar (artık gereksiz). B2–B7 düz ipuçları aynen.
   Kart adının fare olayları (satır hover'ı, "→"/"×" düğmeleri, tıklama, tekerlek) bozulmamalı.
2. PRODUCT_STARTS_AHEAD haftasız: TR "önden başlar", EN "starts ahead". `{w}` iki dilde birden çıkar; çağıran `{w}` geçirmesin.
3. R6: önden tam bitmiş aşama PRODUCT_DONE_AHEAD; kısmen yapılmışsa YALNIZ yüzde (PRODUCT_STAGE_READY'nin tam cümlesi değil): kodun STAGE_READY'ye
   `{pct}` olarak geçirdiği değerin aynısı (Fmt.percent ile, TR "%40", EN "40%"). Panodaki B1'in STAGE_READY kullanımı (önceki sprintte önden) aynen kalır.
4. Zengin panelde ve KT7'de ("yetişmez" ipucu) kurucunun aynı türden görüşmeleri toplanır: "Satış görüşmesi · 4 gün" (PRODUCT_MEETING_* · PRODUCT_DAYS,
   gün toplamı). B5 (taramanın kendi ipucu) kalem başına kalır.
5. Künye: "PM yok" yalnız ekipte PM yokken. PM var ama bu kartı hazırlamamışsa künye satırı yalnız "{modül}"; hazırladıysa "{modül} · {PM} hazırladı".
6. Düzeltme kartında panelin efor kutularına ve "Kim" satırlarına düzeltme işi dördüncü girdi olarak girer, B1'in kullandığı etiketle (yeni anahtar yok);
   kutuların toplamı kartın eforuna eşit olmalı. Hata sayısı ipucuna girmez.
7. KT10: konuşanı olmayan kâğıtta gönderici adı kalır (değişiklik yok).
8. PRODUCT_STAGE_DONE_NOW EN metni "done this sprint" (CSV'de yalnız o hücrenin baytları).
Kabul (değişiklik yok): C8 SUGGEST_NONE yazılmaz, "Kurucu 0★" kalır, erken kapanışın taralı alanı yalnız satır altı boşlukta.

## B. İnceleme bulguları (`$S/u6/review.md`)
1. YANLIŞ: koşan sprintte önceki sprintte önden biten aşama "bu sprintte bitti" okunuyor (board_row.gd `_tick`, card_tip.gd `_who`; `s.before` iki durumu
   ayırmıyor). `SprintUiShared`'e tek yardımcı: `s.need <= EPS and s.pre > EPS` → PRODUCT_AHEAD_DONE, değilse PRODUCT_STAGE_DONE_NOW; iki yer onu çağırsın.
   Önce a4_run_w2 dökümünde yanlışı göster (ipucu metnini döküme bas), sonra düzelt ve doğruyu göster.
2. ZAYIF: araştırma aşamasının (rol "product") beklemesinde ipucu boş (board_row.gd WAIT_KEYS). Yönetmenin kararı (2026-10-27): yeni anahtar
   PRODUCT_WAIT_PRODUCT, TR "Bekliyor: ürün yöneticisi ya da kurucu", EN "Waiting for a product manager or the founder"; WAIT_KEYS'e "product" rolüyle
   girer. CSV'de öbür PRODUCT_WAIT_* satırlarının yanına bayt kesmeyle tek satır (öbür baytlar aynı kalır).
3. TEMİZLİK: `_names`/`_wait_tip` ad için `ProductModel.stage_face` yerine `CharacterRegistry.get_character(id).character_name` (aynı adlı iki kişi kuralı
   zaten tam ad).
4. TEMİZLİK: sprint_board.gd `_early_tip(c)` yalnız erken kapanış varken ve bir kez; sprint_next.gd `_load_row`'daki gereksiz `mouse_filter = PASS` satırı.
İnceleyicinin karar notları (uygula):
- N-a: zengin panel kart adında: ad Label'ı özel ipucu kuran küçük bir Label alt sınıfı (ya da var olan bir desen), MOUSE_FILTER_PASS kalır (STOP satır
  hover'ını, "→ ×"ı ve tekerleği kırar). Satırın kendi `tooltip_text`'i boşalır; kapısı kapanan kartın düz ipucu (gate_reason + PRODUCT_GATE_MOVES) adda
  ya da satırda kalabilir, ama ad üstünde panel + düz metin ikilisi çıkmasın: kapısı kapanan kartta adın üstünde ne açılacağını raporda yaz.
- N-b: çubuğun B1 ipucu açılış anında hesaplansın (`StagePaint._get_tooltip()` ve `_bar_tip(entry)`), kurulumda yazılmasın (koşan sprintte bayatlar).
  `tip_panel` ve `CardTip.panel`'ın artık ölü `part` parametresi silinir.
- N-c: karar 2'den sonra `_next_card`'ın `ahead_week`/`started` hesabı yalnız bir bayrağa insin; `product_fixtures.gd`, `product_model.gd` başlık yorumu ve
  08 belgesindeki `ahead_week` atıfları aynı değişiklikte.
- N-d: `_product_tip_shot` "card" hedefinde imleci ad Label'ının ortasına koysun (sabit nokta kısa adda dışarı düşer).

## C. Kanıt kareleri için ipucu hedefleri (`main.gd` `_product_tip_shot` ve `_A4_WORLDS`, küçük hunk)
Bugün `tip` alanı "card" (söz çipli ilk satırın adı) ve "cap" (taşan aşamanın etiketi). Görsel kabul için şu hedefleri ekle; her biri YENİ bir dünya
kimliğiyle, var olan bir dünyanın alanlarını kopyalayıp yalnız `"tip"` ekleyerek (var olan dünyaların kendi davranışı değişmesin):
- `a4_run_w2_bar`: a4_run_w2 + tip "bar": koşan sprintte ilk satırın koşan aşama çubuğunun ortası (B1 düz ipucu: "efor {yapılan}/{toplam} · şu an: …").
- `a4_fix_tip`: düzeltme kartı olan bir A4 dünyası + tip "fix": ilk düzeltme kartının ADI (zengin panel, karar 6'nın dört kutusu ve "Kim" satırları).
- `a4_meet_tip`: kurucunun iki haftada aynı türden görüşmesi olan dünya (a4_six_meetings2 ya da benzeri) + tip "founder": kurucunun kartının ADI
  (zengin panel, karar 4'ün toplanmış görüşme satırı); aynı dünyada KT7 için ayrı hedef gerekmez.
- `a4_next_tip`: sağ sütunda önden çalışılan sonraki kartı olan dünya (a4_run_end ya da a4_next_prefilled) + tip "next": KARTLAR'daki ilk kartın
  şerit parçası (R6: karar 3'ün yüzdesi ya da "önden bitti").
- Künye için (karar 5): ekipte PM var ama kartı hazırlamamış bir kartın adı; uygun dünyada "card" hedefi bunu gösteriyorsa yeni tür gerekmez, göstermiyorsa
  `a4_pm_tip` (PM'li dünya + tip "plain": PM'in hazırlamadığı ilk kartın adı).
Hedef bulunamazsa koşu `SHOT|tip_missing|<tür>` basıp normal kareyle bitsin (sessizce yanlış yere imleç koyma). main.gd'deki yorumu güncelle.
02 sayfasında (kod haritası) yeni türler ve tip değerleri tek satırda.

## D. Kapılar (hepsi W'de, son değişiklikten SONRA)
- Her Godot koşusundan önce `ls /c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/kilit/sessiz`: varsa sahibi kim olursa
  olsun Godot başlatma, bekle. `class_name` eklersen/silersen önce `--import` (sıra: import → ısınma → kapı). Varsayılan APPDATA yok (`gd` kullan).
- Smoke: `P=8 bash $S/bin/smoke.sh W fx6 @$S/u6/smoke_list.txt` (75 vaka) + dokunduğun vakalar. Hepsi PASS, loglarda SCRIPT ERROR / Parse Error /
  Compile Error 0.
- `--event-lint` PASS, `loc_residue` [CLEAN]; CSV'de `{token}`'lar iki dilde aynı (STARTS_AHEAD'de iki dilde de token yok).
- PLANMS probu (`--sprint-probe=hours=40:cards=2:ticks=60:team=50:market=b2b:planms=1`): çıkış 0, MISMATCH 0; ilk kare kodlayıcının ölçüsüyle aynı bant.
- Z6: `bash $S/bin/z6.sh W fx6`, sonra `$S/z6_b6/lines_*.txt` ile `cmp` (287f6f5'in kendi koşusu; z6_hd ve z6_u5f f7a878c'den eski) → 7 dosya bayt eş.
- Tema değiştiyse (UiTokens'a yeni sabit) `build_theme`, theme_check iki tema, kontrast denetimi (THEME_STAMP'e dokunma).
- Başsız döküm (kodlayıcının aracı `$S/u6/tools/a4dump6.sh`, `add_hook6.py`, `u6_dump.gd.keep`): bütün live:a4_* türleri + C'nin yeni türleri, TR ve EN:
  SCRIPT ERROR yalnız save_png, row_gaps=0, sağ sütun 300, orta 754, panelde TRIMMED/TRUNCATED/OUTSIDE 0; yeni hedeflerde `SHOT|tip_missing` yok.
  Kanca ve döküm sınıfı teslimden önce silinir.
- Pencereli koşu YOK (kareleri ben çekeceğim).

## Dönüş (≤1000 sözcük)
Değişen dosyalar (tabana göre yeni/silinen dahil), her A/B/C maddesi için ne yaptın + kanıt (komut ve sonuç), kırma sınamaları (bulgu bir davranış
iddiasıysa: değişikliği geri alıp dökümün/smoke'un yanlışı gösterdiğini, sonra düzelttiğini göster), kapı sonuçları sayılarla, C'deki her türün
hangi dünyadan kurulduğu ve imlecin hangi Control'ün üstüne gittiği, kalan şüpheler.
