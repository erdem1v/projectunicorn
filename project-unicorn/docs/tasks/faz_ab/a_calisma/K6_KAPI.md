# K6 kapı koşuları

## Koşu 1

Tarih: 2026-10-17. Dal: main (tek klasör). Repo dosyalarına yazılmadı; çıktılar `docs/tasks/faz_ab/a_calisma/` altında.

| Adım | Komut | Sonuç |
|---|---|---|
| 0 | `git diff` içinde `class_name` satırı ekleme/silme/yeniden adlandırma | Yok, `--import` gerekmedi. PASS |
| 1 | `grep -rn FALSIFY-TEMP` (değişen dosyalar + `git diff`) | 0 eşleşme. PASS |
| 2 | `--headless --event-lint` | rc=0, `LINT PASS 0 error(s), 0 warning(s), 13 baselined, 97 card(s), 3 arc(s)`. Log: `K6_eventlint.log`. PASS |
| 3 | `-s res://scripts/debug/loc_residue.gd` | rc=0, `LOC RESIDUE: 0 hit(s) [CLEAN] (csv_keys=3326)`. Log: `K6_locres.log`. PASS |
| 4 | `tools/smoke_run.sh loc_csv_integrity` | `SMOKE PASS loc_csv_integrity`, rc=0. PASS |
| 5 | 22 smoke vakası, `xargs -P 2`, `CASE_TIMEOUT=300`, vaka başına APPDATA/HOME | 22/22 `SMOKE PASS`, hepsi rc=0. Loglar `K6_smoke/<vaka>.log`. Ayrıca `loc_csv_integrity` bağımsız PASS. Yeniden koşu gerekmedi. PASS |
| 6a | `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | rc=0. `SPRINTPROBE SUMMARY|match=216/225|mvp_days=3x1`. 9 MISMATCH satırının 9'u `cause=` taşıyor (adsız yok). Nedenler: `product.sprint_late`=4, `team`=4, `product.sprint_two_paths`=1. Üçü de A1d_TABAN.md taban listesinde (`product.sprint_late`, `product.sprint_two_paths`, `team`). PASS. Sayılar tabanın üstünde (A1d: 3/3; K3 kuralına göre 4/4 beklenirdi; `two_paths` 1 ek kayıt) — bilgi amaçlı, başarısızlık değil. Log: `K6_sprintprobe.log` |
| 6b | Glif denetimi (`glyph_audit.gd`) | rc=0. `GLYPH|CHARS|129`; 107 `GLYPH|MISS` satırı (kayıt amaçlı). Yeni görünen: `→` (U+2192) `csv:HR_HOURS_SPRINT_POINTS` (strings.csv diff'inde 2 eklenmiş `→`), ayrıca `∧`, `▲`, `▼`, `★`, `✓`, `✗` ve benzerleri. Log: `K6_glyph.log`. PASS (çıkış kodu kapısı) |
| 6c | `--theme-contrast-audit` | Tema varyasyonu eklenmediği için çalıştırılmadı (`themes/*.tres` diff'inde `variation` eklenmemiş; yalnız 8 satır değişmiş). Gereksiz. |
| 7 | 24 pencereli gölge koşusu (sıra ile, her biri kendi APPDATA'sı) | 24/24 rc=0; ERROR / SCRIPT ERROR satırı 0. 57 dosya: 24 koşu logu + 33 PNG. PNG'ler `shots/K6/shot_<nn>_<komut>_*.png` adıyla kopyalandı. |

### Notlar (kayıt)

- Shot komutlarının listesi 24 satır (görev metnindeki sayım 28 yazdı; liste gerçekte 24 komut içeriyor, hepsi çalıştı).
- Shot APPDATA'ları: görev metni `shots/K6/appdata_<n>` (boşluklu yol) istiyordu. Boşluklu yol APPDATA'da rc 139 riski taşıdığı için her koşu `C:\Users\erdem\AppData\Local\Temp\fazA\K6_shot_<nn>` altında yapıldı. PNG'ler oradan kopyalandı.
- `K6_smoke/` klasöründe koşudan önce var olan eski dosyalar (F1–F17 ve `final_*`, `last_*` logları) duruyor; bu koşuda üretilmedi, dokunulmadı. Bu koşunun logları üzerine yazılan dosyalar: 22 vaka logu + `loc_csv_integrity.log`.
- `K6.md` (slice tanımı) bu klasörde yok; yalnız kapı dosyası yazıldı.

### Sonuç

Tüm adımlar PASS. Hiçbir adım başarısız değil.

## Koşu 2

Tarih 2026-10-17. Kapı koşucusu (Haiku, mekanik). Repo dosyalarına dokunulmadı; yazılan yer yalnız bu klasör ve fazA geçici dizinleri. APPDATA/HOME her koşuda boşluksuz `C:\Users\erdem\AppData\Local\Temp\fazA\...` altında.

| Adım | Komut | Sonuç |
|---|---|---|
| 0 | class_name satırı diff taraması (`git diff` + grep) | PASS, eşleşme yok (rc=1); import yapılmadı |
| 1 | `grep -n FALSIFY-TEMP` değişen dosyalar + `git diff` | PASS, hiçbir yerde yok. Not: `assets/icons/product/voices.svg.import` silinmiş durumda, grep için atlandı |
| 2 | `--event-lint` | PASS rc=0, `LINT PASS 0 error(s), 0 warning(s), 13 baselined, 97 card(s), 3 arc(s)` (`K6_eventlint.log`) |
| 3 | `-s res://scripts/debug/loc_residue.gd` | PASS rc=0, `LOC RESIDUE: 0 hit(s) [CLEAN] (csv_keys=3326)` (`K6_locres.log`) |
| 4 | `smoke_run.sh loc_csv_integrity` | PASS rc=0, `SMOKE PASS loc_csv_integrity` |
| 5 | 23 smoke vakası, `xargs -P 2`, CASE_TIMEOUT=300 | PASS 23/23, her logda `SMOKE PASS`, `SMOKE FAIL` yok (`K6_smoke/<vaka>.log`) |
| 6a | `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | PASS rc=0. `SPRINTPROBE SUMMARY|match=216/225|mvp_days=3x1`. 9 MISMATCH, hepsinin `cause=` var, adsız 0 |
| 6a | Neden sayıları | `product.sprint_late`=4, `team`=4, `product.sprint_two_paths`=1. Üçü de A1d_TABAN.md:126'daki taban listesinde. Sayı artışı (A1d 3/3) K3 kaymasıdır, FAIL değil |
| 6b | Glif denetimi `glyph_audit.gd` | PASS rc=0 (`K6_glyph_audit.log`). Kayıt: zincirlerde eksik glif satırları var (d_serif_reg missing=3, d_serif_sb missing=3); kayıt amaçlı, kapı değil |
| 6b | `--theme-contrast-audit` | Çalıştırılmadı: değişen dosya listesinde tema yok, tema varyasyonu eklenmedi |
| 7 | 24 pencereli vitrin koşusu, tek tek | PASS 24/24, hepsi rc=0, konsolda ERROR satırı 0. PNG'ler `shots/K6/<n>_*.png` (n = komut sırası 1..24) |

Kayıtlar: `K6_smoke/shots_run.sh` ve `K6_smoke/run_case.sh` koşu betikleri; `shots/K6/log_<n>.txt` konsol çıktıları.

Notlar:
- İlk smoke denemesi `GODOT` ihracı eksik olduğu için rc=2 ile düştü (`no Godot binary`). Harness hatasıydı, vaka FAIL değildi; GODOT ayarlanıp yeniden koşuldu, sonuçlar yalnız yeniden koşudan alındı.
- Adım 7'deki APPDATA yolu (`docs/.../shots/K6/appdata_<n>`) boşluklu yol olduğu için kullanılmadı; ön talimattaki boşluksuz fazA dizinleri kullanıldı. PNG'ler oradan kopyalandı.
- Bir önceki yanlış genişletmeden kalan `fazA$W` ve `fazA$d` dizinleri (yalnız bu koşuya ait geçici çöp) silindi.
- `shots/K6/` içinde Koşu 1'den kalan dosyalar (`opus_*`, `shot_NN_*`) dokunulmadan duruyor; bu koşunun dosyaları `<n>_` önekiyle ayrı.

Sonuç: tüm adımlar PASS. all_green = true.
