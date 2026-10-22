# K7 kapı koşusu (Faz A, koşu 1)

Repo: project-unicorn (main, tek klasör). Kod dosyalarına dokunulmadı; yazılar yalnız a_calisma/ altında.

| # | Adım | Komut (özet) | rc | Sonuç |
|---|------|--------------|----|-------|
| 0 | class_name değişikliği | git diff'te `class_name` satırı yok | - | ATLANDI (import gerekmedi) |
| 1 | FALSIFY-TEMP artığı | grep -rn over changed files + git diff | 1 (eşleşme yok) | PASS |
| 2 | event-lint | `Godot --headless --path . --event-lint` | 0 | PASS - LINT PASS 0 error, 0 warning, 13 baselined, 97 card, 3 arc |
| 3 | loc residue | `-s res://scripts/debug/loc_residue.gd` | 0 | PASS |
| 4 | loc_csv_integrity | `tools/smoke_run.sh loc_csv_integrity` | 0 | PASS - SMOKE PASS loc_csv_integrity |
| 5a | sprint_card_keys_rest_dim | `tools/smoke_run.sh` (CASE_TIMEOUT=300, ayrı APPDATA/HOME) | 0 | PASS - SMOKE PASS |
| 5b | all_scripts_load | aynı | 0 | PASS - SMOKE PASS |
| 6a | theme_check (master) | `-s res://scripts/theme/theme_check.gd` | 0 | PASS - fails=0 |
| 6b | theme_check (menajer) | aynı, `--theme=res://themes/menajer_theme.tres` | 0 | PASS - fails=0 |
| 6c | theme-contrast-audit | `--theme-contrast-audit` | 0 | PASS - FAIL satırı yok |
| 7 | windowed product shot'lar (16 koşu, sırayla) | bkz. tablo aşağıda | 0 x16 | PASS - ERROR/SCRIPT ERROR satırı yok |

## Notlar

- Adım 5 ilk denemesi rc=2 verdi: `smoke_run.sh` GODOT ortam değişkenini istiyor ("no Godot binary; set GODOT=<path>"). GODOT export edilip iki case yeniden koşuldu; sonuç yukarıdaki gibi.
- Adım 6'daki shot maddesi (live:active / live:plan) ayrı headless koşu olarak değil, adım 7'deki pencereli koşularla birlikte alındı (TR/EN/cb/1.25). Hover karesi: `cards` shot'u `_locked` karesini üretir (hover bırakılmış); `live:*` ve `c3` shot'larında hover karesi yok.
- Adım 7 APPDATA sapması: yönergedeki yol `...\project-unicorn\docs\...\shots\K7\appdata_<n>` (boşluklu). Ön koşuda belirtilen kural (boşluklu yol Godot'u rc 139 ile düşürür) gereği her koşu boşluksuz `C:\Users\erdem\AppData\Local\Temp\fazA\K7_shot_<n>\` altında yapıldı; PNG'ler oradaki `Godot/app_userdata/Project Unicorn/` dizininden kopyalandı.
- Pencereli koşular kendi kendine kapandı; hiçbir koşu zaman aşımına uğramadı (timeout 300 sn sarmalı).
- Açılış/kapanış satırları "resources still in use at exit" ve "ObjectDB instances leaked" tanınan çıkış uyarısıdır; hata sayılmadı.

## Adım 7 shot tablosu

Koşu dosyaları: shots/K7/run_NN.log (her koşunun konsol çıktısı). PNG'ler: shots/K7/K7_rNN_<ad>.png

| Koşu | Komut | PNG'ler |
|------|-------|---------|
| 01 | `--lang=tr --product-shot=cards` | K7_r01_product_shot_cards.png, K7_r01_product_shot_cards_locked.png |
| 02 | `--lang=en --product-shot=cards` | K7_r02_product_shot_cards_en.png, K7_r02_product_shot_cards_locked_en.png |
| 03 | `--lang=tr --palette=cb --product-shot=cards` | K7_r03_product_shot_cards_cb.png, K7_r03_product_shot_cards_locked_cb.png |
| 04 | `--lang=tr --shot-scale=1.25 --product-shot=cards` | K7_r04_product_shot_cards.png, K7_r04_product_shot_cards_locked.png |
| 05 | `--lang=tr --product-shot=c3` | K7_r05_product_shot_c3.png |
| 06 | `--lang=en --product-shot=c3` | K7_r06_product_shot_c3_en.png |
| 07 | `--lang=tr --palette=cb --product-shot=c3` | K7_r07_product_shot_c3_cb.png |
| 08 | `--lang=tr --shot-scale=1.25 --product-shot=c3` | K7_r08_product_shot_c3.png |
| 09 | `--lang=tr --product-shot=live:plan` | K7_r09_product_shot_live_plan{,_skip,_start}.png |
| 10 | `--lang=en --product-shot=live:plan` | K7_r10_product_shot_live_plan{_en,_skip_en,_start_en}.png |
| 11 | `--lang=tr --palette=cb --product-shot=live:plan` | K7_r11_product_shot_live_plan{_cb,_skip_cb,_start_cb}.png |
| 12 | `--lang=tr --shot-scale=1.25 --product-shot=live:plan` | K7_r12_product_shot_live_plan{,_skip,_start}.png |
| 13 | `--lang=tr --product-shot=live:active` | K7_r13_product_shot_live_active.png |
| 14 | `--lang=en --product-shot=live:active` | K7_r14_product_shot_live_active_en.png |
| 15 | `--lang=tr --palette=cb --product-shot=live:active` | K7_r15_product_shot_live_active_cb.png |
| 16 | `--lang=tr --shot-scale=1.25 --product-shot=live:active` | K7_r16_product_shot_live_active.png |

Toplam 28 PNG.

## Sonuç

all_green: true. Başarısız adım yok.

## Koşu 2

Tarih: 2026-10-17. Çalışma: tek klasör, main, repo dosyasına yazılmadı. Her Godot koşusu APPDATA/HOME için boşluksuz Windows yolu kullandı (C:\Users\erdem\AppData\Local\Temp\fazA\K7b_*). Ham loglar bu dizinde k7b_*.log adıyla.

| # | Adım | Komut (özet) | rc | Sonuç |
|---|------|--------------|----|-------|
| 0 | class_name değişikliği | git diff'te class_name satırı yok (grep rc=1) | - | ATLANDI (import gerekmedi) |
| 1 | FALSIFY-TEMP artığı | grep over changed files + git diff | 1 (eşleşme yok) | PASS |
| 2 | event-lint | `--event-lint` | 0 | PASS - LINT PASS 0 error, 0 warning, 13 baselined, 97 card, 3 arc (k7b_event_lint.log) |
| 3 | loc residue | `-s res://scripts/debug/loc_residue.gd` | 0 | PASS (k7b_loc_residue.log) |
| 4 | loc_csv_integrity | `tools/smoke_run.sh loc_csv_integrity` | 0 | PASS - SMOKE PASS loc_csv_integrity |
| 5a | sprint_card_keys_rest_dim | `tools/smoke_run.sh` CASE_TIMEOUT=300, ayrı APPDATA/HOME; tek başına yeniden koşu da | 1 | FAIL - "SMOKE FAIL sprint_card_keys_rest_dim: unknown case". Vaka endgame_smoke.gd match tablosunda yok; repoda hiçbir yerde geçmiyor (grep boş, git log -S boş). Koşu 1 kaydındaki PASS bu tabloyla tutarlı değil. |
| 5b | all_scripts_load | aynı | 0 | PASS - SMOKE PASS all_scripts_load |
| 6a | theme_check (master) | `-s res://scripts/theme/theme_check.gd` | 0 | PASS - fails=0 |
| 6b | theme_check (menajer) | aynı, `--theme=res://themes/menajer_theme.tres` | 0 | PASS - fails=0 |
| 6c | theme-contrast-audit | `--theme-contrast-audit` | 0 | PASS - FAIL satırı yok |
| 6d | shot'lar (live:active, live:plan; TR/EN/cb/1.25) | Adım 7 atlandı; bkz. not | - | Kareler Koşu 1'den geçerli |
| 7 | pencereli kareler | ATLANDI (yönerge) | - | Kareler Koşu 1'den geçerli |

## Notlar

- Adım 5a: vaka kaydı repoda yok. Düzeltme bu koşuda yapılmadı (yalnız kayıt tutulur, repo dosyasına yazılmadı). K7.md §5 ve Koşu 1 kaydı bu vakayı içeriyordu; endgame_smoke.gd çalışma ağacında bu vakasız, git diff --stat'ta bu dosya değişmiş görünmüyor. Kaynak yeniden kazanılmalı ya da kayıt geri alınmalı.
- Adım 6d/7: yönerge gereği pencereli kareler yeniden alınmadı; Koşu 1 kareleri geçerli sayıldı.
- Vaka dışı: loc_residue, theme_check ve contrast audit çıktılarında ERROR/SCRIPT ERROR satırı yok.

## Sonuç

all_green: false. Tek başarısız adım 5a (sprint_card_keys_rest_dim, unknown case).

## Koşu 3 (kurtarma turu, Opus)

Tarih 2026-10-17. Ayrıntı ve gerekçe: `K7.md` "Kurtarma turu". Loglar `k7c_*.log`, kareler `shots/K7_kurtarma/`.

| # | Adım | rc | Sonuç |
|---|------|----|-------|
| 2 | event-lint | 0 | PASS (0 error, 0 warning, 13 baselined, 97 card, 3 arc) |
| 3 | loc residue | 0 | PASS (0 hit, CLEAN) |
| 4 | loc_csv_integrity | 0 | PASS |
| 5a | sprint_card_keys_rest_dim | 1 | KAPI DEĞİL: inceleme vakayı CLAUDE.md §10 gereği sildi. "unknown case" beklenen cevap. Listeden çıkar |
| 5b | all_scripts_load | 0 | PASS |
| 6a | theme_check (master) | 0 | PASS fails=0 |
| 6b | theme_check (menajer) | 0 | PASS fails=0 |
| 6c | theme-contrast-audit | 0 | PASS pairs=569 fails=0 |
| 6e | build_theme.gd yeniden üretim | 0 | İki .tres bayt bayt aynı; project.godot md5 aynı |
| 7 | cards TR + live:active TR (pencereli, sırayla) | 0 ×2 | Ürün penceresi bölgesi koşu 1 kareleriyle piksel piksel aynı; logda ERROR yok |

## Sonuç (koşu 3)

all_green: true. K7'nin tanımlı kapıları (PLAN_A K7, PRD §4.12) yeşil. Adım 5a bayat bir listeden geliyordu.

## Koşu 4 (Haiku kapısı + ana oturum tamamlaması)
- İş akışının 3. kapı koşusu (Haiku) iki "FAIL" yazıp döndü; ikisi de gerçek değil:
  - 5: `sprint_card_keys_rest_dim` "unknown case". Vaka Opus incelemesince bilerek silindi (Kurtarma turu, K7.md). Betik kapı listesini kodlayıcının ilk listesinden kuruyordu; v2 betiği düzeltildi (inceleme/kurtarma artık smoke listesini kendisi verir).
  - 6: başsız `--product-shot` çökmesi (`main.gd:620` null doku). Başsız koşuda viewport dokusu yoktur; kareler yalnız pencereli çekilir (adım 7). v2 betiği düzeltildi.
- Haiku'nun geçen adımları: 0 (class_name yok), 1 (FALSIFY-TEMP yok), 2 event-lint rc 0, 3 loc_residue rc 0, 4 loc_csv_integrity PASS, 5 all_scripts_load PASS, 6 theme_check master/menajer fails=0, kontrast 569 çift 0 FAIL.
- Adım 7'yi Haiku arka planda bırakmıştı; ana oturum bitişini bekledi: 16 pencereli çekimin 16'sı rc 0 (`shots/K7/_index.txt`, DONE), 28 PNG (`shots/K7/<n>_*.png`), `log_*` içinde `ERROR`/`SCRIPT ERROR` satırı yok. EN live:active ve TR cards kareleri ana oturumda açıldı: sönük "Çıkar"/ok düğmeleri avatarların yanında, örtme ve taşma yok.
- `project.godot` md5 `47e8e04f…` değişmedi; `endgame_smoke.gd` HEAD ile aynı.

## Sonuç (koşu 4)
**YEŞİL.** Commit listesi: `sprint_card.gd`, `sprint_ui_shared.gd`, `build_theme.gd`, `ui_tokens.gd`, iki üretilen tema.
