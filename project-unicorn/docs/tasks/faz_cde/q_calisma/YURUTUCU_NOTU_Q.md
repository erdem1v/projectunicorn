# Faz Q · Yürütücü notu
Her adım ajanı bunu ÖNCE okur. Bağlayıcı sıra: Erdem'in kararları (§1) > `PRD_FAZ_Q_KALITE.md` > onaylı plan
(`q_calisma/PLAN_Q.md`) > bu not > `Q0_HARITA.md` (gerçek adlar ve satırlar, HEAD `fc6b392`). Çelişkide dur ve `blocked` dön.

## 1. Erdem'in kararları (18 Ekim, adım tablosu onayı)
1. Onay bekleyen sayılar (yıldız beklenti tablosu, B2C kitle eşikleri, satışçı zar eğrisi, karışım eşikleri, taban eşikleri,
   Tekstil ve Medya satırları, oran kesiği, B2C dönüşüm katsayısı, rakip penceresi) PRD'nin önerdiği değerlerle **geçici**
   yazılır: her biri tek ayar sabitinde ya da `data/` bloğunda, yanında `[WORKING]` / "onay bekliyor". Sessizce oynatılmaz.
2. Karar 1'deki gerçekleşme damgası ve kapı üstü bonusu: "PRD ne diyorsa onu yap" → K7'de silinir, raporda "onay bekliyor".
3. `ProductCatalog.QUALITY_AXES` üründen silinir; rakip bileşkesinin ağırlıkları rakip modeline taşınır, rakip sayıları
   değişmez (K7). RAPOR_Q'da "rakip modeli de elden geçmeli" yazılır.
4. ACIK_KARARLAR #59 (VC ham eksen tabanı) ve #10'un "En zayıf ekseni bulacak" metni K4'te, #52'nin konusu K7'de kapanır; K9
   ACIK_KARARLAR'a kapanış satırlarını yazar.

## 2. Plan varsayılanları (onaylı)
1. Ürün sayfasında `serves` ve alan sözcüğü HAM seviyeyi okur; ekran yarıma yuvarlanmışı gösterir.
2. Gelir alanı U'ya girmez; satırı ve dört cümlesi kalır, sözcüğü B2C vurgu sütunuyla okunur (yalnız gösterim).
3. Rakip artışı bugünkü gibi çıkış kaydı başına; pencere `_recent_hit`'in penceresi (`rival_window_weeks`).
4. `market_fit(3)` 13 sektör üzerinden.
5. Satışçının kaybettiği aday kurucunun kaybıyla aynı yola girer; satışçının aday seçimi de geri dönüş kapısına bakar.
6. `quality_core` = ERP, `fix: worst`, lider yalnız Çekirdek kartı alır; `fix` ve `research` kartları süzgeçten muaf; B2C kolu yok.
7. §4.1 kapısı PRD'nin on belirteci + `push_axes` + JSON eksen alanları; geniş desen (117/32) raporda ayrıca.
8. `SALES_REASON_STABILITY` (`strings.csv:145`) yalnız metin olarak K3a'da yeniden yazılır; mekanizması C'nin.
9. Profil verisinin JSON anahtarı `profile` (`design` | `dev` | `test`), okuyucusu `ProductLines.work_profile(line)`; K1'de doğar.

## 3. Ağaç ve commit
- Tek klasör, `main`. Adım ajanları **commit atmaz, `git add` yapmaz**; `git checkout -- <yol>` YASAK; worktree yok.
- Yalnız adımın dosyalarına dokun. Sahipsiz farklar dokunulmaz: `project.godot`, `themes/*.tres`, `Godot/`, `tools/__pycache__/`,
  `docs/mockups/`, `docs/tasks/` (yalnız `docs/tasks/faz_cde/q_calisma/` notları yazılabilir, o da commit'lenmez).
- Aynı ağaçta C ve D oturumları açık, yalnız docs altında yazıyorlar. Godot'u yalnız Q koşturur.
- Commit'i ana oturum yapar: `Faz Q Kn: <ne değişti, oyuncu ne görür>`; sabit taşıyorsa "sabitler onay bekliyor", metin
  taşıyorsa "TR/EN onay bekliyor".

## 4. Godot
- `export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/`'dan.
- Her koşu ayrı `APPDATA` (ve `HOME`) dizini: `<scratchpad>/appdata_<adım>_<ad>`; gerçek kayıtlara dokunma.
- Bellek dar (16 GB, ~4 GB boş): aynı anda en çok BİR Godot süreci; bot ölçümünde en çok iki paralel koşu; `xargs -P` ile paralel
  smoke yok. Ekranlı koşular sırayla.
- `class_name` eklenince, silinince ya da adı değişince önce `"$GODOT" --headless --path . --import`.
- Bayrak `--` ayracının arkasına konmaz. `static func` içinde `tr()` çalışırken ölür.

## 5. Kapı sırası (CLAUDE.md §12)
`"$GODOT" --headless --path . --event-lint` → `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` →
`bash tools/smoke_run.sh loc_csv_integrity` → hedefli smoke (`bash tools/smoke_run.sh <vaka> ...`). Tam smoke (`--all`) yok.
Smoke PASS tek başına yetmez: çıktıyı `Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR|ERROR:` için tara.
Yeni smoke vakası falsification ile kanıtlanır (kuralı bozunca vaka düşmeli). `CASE_TIMEOUT=300` uzun vakalarda.

## 6. Bilinen tuzaklar (Q0'dan)
- `endgame_smoke.gd`'nin ortak fikstürü `_seed_b2b` (:692) 82 çağıranlı; sektörü `testing` (`B2BConstants.SECTOR_FIXTURE`,
  `b2b_constants.gd:86-89`); 22 yerde elle kurulan aday da `testing`. `ProductQuality` tanınmayan sektörde
  `sales_archetypes.gd:139-146`'daki `DEFAULT_ID` kuralına düşer; `testing` için ayrı tablo satırı YAZILMAZ.
- Masa kapanışı vakaları `ai_vector_search` alt türüyle, hat kademesi kurmadan yazılmış; U hat kademesinden okununca Çekirdek 0
  olur. K3a ortak "beklentiyi karşılayan ürün" fikstürünü kurar.
- `strings.csv`: dosyayı yeniden yazma, bayt düzeyinde ekle/değiştir; yer tutucular iki dilde aynı ve `[a-z_]+`; CSV değerinde
  `{seam:...}` olmaz (kart gövdesine satır içi yazılır). Oyuncu metninde tire yok; `{area}`, `{sector}`, `{company}` ek almaz.
- `^PROBE` satırları aynı tohum, aynı binary ve `--lang=tr` ile bayt-deterministik kalmalı.
- `lint_v3_frozen.json` üretilmez, elle tutulur; yeniden yazılan kart listeden çıkar.
- Sektör listesi uzayınca `(mix_seed + offset) % sectors.size()` kayar; yeni sektörler listenin SONUNA eklenir
  (`sectors("tech_exacting")[0]` üç vakada `technology` bekliyor).
- Heredoc'ta `\` ve backtick bozulur; büyük yamayı dosyaya yaz.
