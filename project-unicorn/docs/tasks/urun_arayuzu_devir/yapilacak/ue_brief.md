# UE prototipi: Erdem'e gidecek kareler için (KOD COMMIT'İ YOK)

S = /c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/cb69ca60-0d91-4669-bf47-f4c28dfeaca0/scratchpad
W = $S/wue/project-unicorn: U6'nın son hâlinin kopyası (.godot dahil, import'lu). YALNIZ burada düzenle. Bu kopya hiçbir zaman commit'lenmez;
prototip olduğu için değişiklikler bir ortam değişkeninin arkasında durur ki aynı ağaç hem "önce" hem "sonra" karesini çeksin.
Paylaşılan ağaca (`C:/Users/erdem/Desktop/Project Unicorn`) yazma, orada Godot koşma, git yazma yok. `$S/w8` ve `$S/b_u6`'ya dokunma.
Pencereli Godot koşusu YOK (kareleri oturum sahibi çeker); yalnız `--headless`.

## Bağlam
Erdem (oyunun sahibi) U5'in `live:a4_two_pm` TR karesine baktı. Yardımcı yönetmen üç soruyu kareyle Erdem'e götürecek; seçimi Erdem yapar.
Bu yüzden her değişken "önce" (bugünkü) ve "sonra" (öneri) karesiyle gösterilir. PRD: `C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md`
(N2, N4 ve U1 notları; maket CSS'i referans değildir, bu Erdem'in yeni isteği). CLAUDE.md'deki biçim kuralları (renk/boyut UiTokens'ta,
metin anahtar olarak) prototipte de geçerli; yeni metin gerekiyorsa CSV'ye bayt kesmeyle anahtar ekle (CSV yeniden yazılmaz).

## Ortam değişkeni
`UE` virgüllü liste (boşsa oyun bugünkü gibi). Godot'da `OS.get_environment("UE").split(",")`. Okuma tek bir yerde (ör. `UiTokens` ya da
`SprintUiShared`'de `static func ue(flag) -> bool`) olsun; değişikliklerin her biri bu bayrakla dallanır.
- `narrow`: madde 1. `icons`: madde 2. `a` / `b`: madde 3'ün iki seçeneği (ikisi birden verilmez).

## 1. `narrow`: sol sütun daralır, sprint kutusu genişler
Erdem: zaman eksenindeki aşama kutuları (7 · 9 · 4 gibi) sıkışık ve dar okunuyor. Sol sütun (`UiTokens.D_W_LEFT` = 288, talepler ve modüller)
daralsın, kazanılan genişlik sprint sütununa (orta, bugün 754 px), oradan da zaman eksenine geçsin. Sağ sütun 300 kalır, pencere aynı.
- Sol sütunun yeni genişliğini ölçerek seç: TR ve EN'de en uzun müşteri adı, kart adı ve modül adı kesilmeden sığmalı, gerekirse iki satıra
  inebilir (N4: ad kesilmez). Kesilme, "…" ya da taşma yok. Önerdiğin değeri ve neden o değer olduğunu (hangi ad sınırı koydu) yaz.
- Eksende bir haftanın px genişliğini bul (kodda nasıl türetildiğini yaz) ve önce/sonra iki sayıyı ölç: sol sütun genişliği, bir haftanın px'i
  (`a4_two_pm` ve `a4_fifty`, TR ve EN). Kart bilgi sütunu (`D_W_CARD_INFO` 312) değişmez; kazanç eksene gider.
- Uzun adlı kareler için iki yeni dünya: `a4_two_pm_long` ve `a4_fifty_long` (`main.gd` `_A4_WORLDS`): aynı dünyalar + en uzun EN adlar
  (var olan `"fill": "long"` ve uzun kişi/müşteri adı mekanizmalarına bak; yoksa en küçük ekle). Bu dünyalar `UE` olmadan da kurulur (önce karesi).

## 2. `icons`: modül kısaltmaları yerine ikon
Bugün modüller ve talepler iki harfli kısaltmayla (`ProductModel._mono`, `PRODUCT_AREA_*_MONO`: ÇK, İK, EN, GÜ …; `HRUiShared.D_mono`) işaretli.
- Projedeki ikon setinden (`res://assets/icons/**`: util, dept, world, rail, skill …), kart tür ikonlarıyla (`assets/icons/product/kind_*.svg`)
  aynı aileden (24 px, düz dolgulu beyaz SVG, aynı çizgi kalınlığı) her modüle bir ikon öner. Yeni SVG çizme; set dışından ikon alma.
- Tablo yaz: modül id → TR adı → bugünkü kısaltma → önerilen ikon dosyası → neden. Bütün pazarların modülleri (B2B ERP, B2C …:
  `SprintCatalog.areas_for`). İki modül aynı ikonu almasın; uygun ikon bulunamayan modül varsa açıkça yaz (uydurma yok).
- Ek olarak bir aday kâğıdı: önerilen ikonların hepsi adlarıyla tek PNG'de (Python/PIL ile, Godot'suz olabilir; svg okunamıyorsa Godot'da
  başsız bir döküm sahnesi).
- `icons` açıkken kısaltmanın çizildiği her yerde (talep satırı, modül satırı, panodaki modül adı varsa) aynı boyda ikon çizilir; ipucu adı söyler.

## 3. `a` / `b`: "planda" ve "gelecek çeyrek" hiyerarşisi (N2)
Erdem A4'te bu küçük yazıların kötü göründüğünü söyledi; karede hâlâ küçük, küçük harfli ve soluk (`area_panel.gd` `_module_row`'daki
PRODUCT_IN_PLAN "planda", `_request_row`'daki `SprintUiShared.due_chip` ve `_planned_chip`; PRODUCT_DUE_NEXT_Q "gelecek çeyrek" vb.).
- (a) Durum metni satır adıyla aynı boyda (satır adının yazı stili/boyutu) ve cümle başı büyük: "Planda", "Gelecek çeyrek" (EN "Planned",
  "Next quarter"). Büyük harfi koddan değil metinden ver: yeni anahtar gerekiyorsa `PRODUCT_IN_PLAN_UE` gibi ayrı anahtar ekle, bugünküne dokunma.
- (b) "planda" yazısı kalkar; durum biçimle okunur: adın yanında bir işaret (var olan ikon setinden, ör. tik) ve açıklaması ipucunda (var olan
  PRODUCT_IN_PLAN_TIP). Talebin son tarihi ("gelecek çeyrek", "bu çeyrek", "{q}. çeyrek", söz tarihi) ad boyunda bir çip olur.
- İkisi de N1'e uyar: ekrana açıklama cümlesi eklenmez.

## Kapılar (W'de, `--headless`)
- Her Godot koşusundan önce `ls /c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/kilit/sessiz`: varsa sahibi kim
  olursa olsun Godot başlatma, bekle. Godot'u `. $S/bin/env.sh; gd <ad> "$W" --headless --path . ...` ile koş (kendi APPDATA'sı).
- `UE` boşken oyun U6'yla aynı: `P=8 bash $S/bin/smoke.sh $W ue0 all_scripts_load loc_csv_integrity product_tab_renders` (vaka adları
  `$S/u6/smoke_list.txt`'ten) PASS; `UE=narrow,icons,a` ve `UE=narrow,icons,b` ile `--product-shot=live:a4_two_pm_long` ve `live:a4_requests`
  başsız koşuları SCRIPT ERROR'suz (save_png hariç).
- Başsız yerleşim dökümü (U6'nın aracı `$S/u6/tools/` ve `$S/u6/tools/fx`): `a4_two_pm_long`, `a4_fifty_long`, `a4_requests`, TR ve EN,
  UE boş / `narrow` / `narrow,icons,a` / `narrow,icons,b`: row_gaps=0, sağ 300, sol ve orta genişlik ölçüsü, adlarda TRIMMED/TRUNCATED/OUTSIDE 0.
  Geçici kanca/döküm sınıfı bitince silinsin (prototip olsa da kareler temiz çıksın).

## Dönüş (≤900 sözcük, düz metin)
1. Değişen dosyalar ve `UE` bayrağının okunduğu yer. 2. Madde 1: önerilen sol genişlik ve gerekçesi; önce/sonra sol sütun px ve bir haftanın px'i
(iki dünya, TR ve EN); taşma/kesilme sonucu. 3. Madde 2: modül → ikon tablosu, aday kâğıdının yolu, bulunamayanlar. 4. Madde 3: (a) ve (b)'de ne
değişti, yeni anahtarlar (TR/EN). 5. Kapı sonuçları. 6. Oturum sahibinin çekeceği pencereli kare listesi: her satır `UE=<değer> --product-shot=live:<tür> <dil>`
(önce ve sonra çiftleri: 1 için a4_two_pm_long ve a4_fifty_long TR ve EN; 2 için tek kare; 3 için a ve b ayrı kareler, uygun dünyada).
7. PRD'nin ya da bu notun sessiz kaldığı yerde verdiğin kararlar (numaralı).
