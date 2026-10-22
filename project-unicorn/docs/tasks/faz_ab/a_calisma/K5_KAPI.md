# K5 kapi (Faz A, koşu 1)

Tarih: 2026-10-17. Çalışma: tek klasör, main, repo dosyasına yazılmadı (yazılar yalnız docs/tasks/faz_ab/a_calisma/ ve fazA temp dizinleri).
Not: her Godot koşusu APPDATA/HOME için boşluksuz Windows yolu kullandı (C:\Users\erdem\AppData\Local\Temp\fazA\K5_*); kabuk logları a_calisma/ altında.

## Kapı tablosu

| # | Adım | Komut / kanıt | Sonuç |
|---|------|---------------|-------|
| 0 | class_name değişikliği var mı | `git diff` scripts/ içinde `class_name` satırı yok | PASS (import gerekmedi) |
| 1 | FALSIFY-TEMP artığı | grep -rn over changed files and git diff: 0 eşleşme | PASS |
| 2 | event-lint | `--event-lint` rc=0; `LINT PASS 0 error(s), 0 warning(s), 13 baselined, 97 card(s), 3 arc(s)` (K5_eventlint.log) | PASS |
| 3 | loc_residue | `-s res://scripts/debug/loc_residue.gd` rc=0 (K5_locres.log) | PASS |
| 4 | smoke loc_csv_integrity | rc=0, `SMOKE PASS loc_csv_integrity` (K5_smoke_loc_csv.log) | PASS |
| 5 | smoke, 42 vaka | k5_case.sh her vaka ayrı APPDATA/HOME; 42/42 rc=0; her logda SMOKE PASS (K5_smoke/reg/*.log). Yeniden koşu gerekmedi. | PASS 42/42 |
| 6a | sprint probe | `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` rc=0; `SPRINTPROBE SUMMARY|match=216/225|mvp_days=3x1`; 9 MISMATCH, hepsinde cause= var (adsız 0); causes: product.sprint_late 4, team 4, product.sprint_two_paths 1 — hepsi TABAN listesinde; ^ERROR 0 | PASS |
| 6b | plausibility_run.sh | `PLAUS SUMMARY runs=40 fires=482 fails=0`; `PLAUS LONG runs=4 fires=351 fails=0`; rc=0 | PASS |
| 6c | regenerate kontrolü | gen_signal_manifest.py (kopya dizinde, kartlar dahil): çıktı repo sürümüyle birebir aynı (diff 0). _vocabulary.md (EvVocabGen, hardlink'li kopyada, KEEP bloğu korunarak): cmp=0 | PASS |
| 6d | ölçüm, zamanlı tek koşu | full_run_fix_due:104:sim:7 rc=0, 35 s (K5_runs/timing_full_run_fix_due_7.log) | kayıt |
| 6e | ölçüm, 16 koşu | 8 preset × tohum 7/11, JOBS=4, timeout 1200; hepsi rc=0, her logda tek PROBE END, engine error 0 (K5_runs/*.log) | PASS |
| 6f | K5_OLCUM.md | `fix_tables.py K5_runs` → K5_OLCUM.md (40 hedef: 38 PASS, 2 MISS) | kayıt |
| 7 | pencereli kareler | 26 komut, sırayla; hepsi rc=0; 26 PNG; console'da ERROR/SCRIPT ERROR 0 | PASS |

## Kaydedilen gözlemler (kapı değil)

- Sprint probe sayıları tabana göre arttı: product.sprint_late 3→4, team 3→4 (K3 kuralıyla beklenen; A1d notu). Adsız uyuşmazlık yok.
- Ölçüm MISS'leri (E1 §9, hedef ≤ %30):
  - fix_worst B2C erken dönem düzeltme payı medyanı: %50.00 (n=25)
  - fix_due B2C erken dönem düzeltme payı medyanı: %50.00 (n=23)
  Bu iki MISS K5.md önceki turunda aynı yapısal sebeple görülmüştü (B2C erken kapasite 1 puan).
- Ölçüm tablosunda churn ölçütleri geçti: b2b tohum 7 fix_worst %4.62 vs off %3.76; b2c tohum 7 fix_worst %7.73 vs off %0.56 (fark +7.17, eşik +10).
- Pencereli kareler: 26 PNG `shots/K5/shot_<n>_*.png` olarak kaydedildi; n sırası aşağıda. Konsol logları `shots/K5/console_<n>.log`.

## Kare sırası

1 vc hunt_callback tr · 2 vc hunt_callback en · 3 vc hunt_callback tr cb · 4 vc hunt_callback tr scale 1.25
5 meeting callback tr · 6 meeting callback en · 7 meeting callback tr cb · 8 meeting callback tr scale 1.25
9 sales edge tr · 10 sales edge en · 11 sales edge tr cb · 12 sales edge tr scale 1.25
13 sales risk_stability tr · 14 sales risk_stability en · 15 sales risk_stability tr cb · 16 sales risk_stability tr scale 1.25
17 onboard 2:random tr · 18 onboard 2:random en · 19 onboard 2:random tr cb · 20 onboard 2:random tr scale 1.25
21 meeting probe tr · 22 meeting probe en · 23 meeting probe tr cb · 24 meeting probe tr scale 1.25
25 meeting locked tr · 26 meeting locked en

## Karar

Tüm kapılar geçti (adım 0–5, 6a–6e, 7). Ölçümdeki 2 MISS kapı hatası değildir ve kayda geçti. all_green = true.

## Koşu 2

Tarih 2026-10-17. Kapı koşucusu (Haiku), yalnız mekanik adımlar. Repo dosyası düzenlenmedi; yazılan yerler bu klasör ve geçici dizinler.

| Adım | Komut | Çıkış | Sonuç |
|---|---|---|---|
| 0 | `class_name` satırı diff'te | — | PASS: eklenen/silinen class_name yok, `--import` gerekmedi |
| 1 | `grep FALSIFY-TEMP` (değişen dosyalar + diff) | 1 (eşleşme yok) | PASS |
| 2 | `--event-lint` | 0 | PASS: 0 hata, 0 uyarı, 13 baselined, 97 kart, 3 arc. Log: `K5_r2_eventlint.log` |
| 3 | `-s res://scripts/debug/loc_residue.gd` | 0 | PASS: 0 isabet [CLEAN], csv_keys=3336. Kapanış "resources still in use" satırı yok sayıldı. Log: `K5_r2_locres.log` |
| 4 | `smoke_run.sh loc_csv_integrity` | 0 | PASS. Log: `K5_smoke2/loc_csv_integrity.log` |
| 5 | 42 vaka, tek tek `smoke_run.sh`, CASE_TIMEOUT=300, vaka başına APPDATA/HOME, xargs -P 2 (3 parça) | 0 hepsi | 42/42 SMOKE PASS. Motor hatası satırı yok. Loglar: `K5_smoke2/<vaka>.log` |
| 6a | `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | 0 | PASS: adsız uyuşmazlık 0. Summary `match=216/225 mvp_days=3x1`. Cause sayımı: product.sprint_late=4 (taban 3), team=4 (taban 3), product.sprint_two_paths=1 (taban listesinde VAR). Sayım artışı kayıt, FAIL değil. Log: `K5_r2_sprint_probe.log` |
| 6b | `tools/plausibility_run.sh` | 0 | PASS: `PLAUS LONG runs=4 fires=351 fails=0`. Log: `K5_r2_plausibility.log` |
| 6c | Regenerate: `--event-vocab` ve `gen_signal_manifest.py` (temp çıktı) | 0 / 0 | PASS: `_vocabulary.md` ve `EVENT_SIGNAL_MANIFEST.md` md5 öncesi/sonrası aynı; manifest üretimi repo kopyasıyla bayt bayt aynı. Manifest: 145 sinyal, 2 emitter'sız, 68 listener'sız. Md5: `K5_r2_regen_before.md5`, `K5_r2_regen_after.md5` |
| 6d | Ölçüm: zamanlı tek koşu `full_run_fix_due:104:sim:7` | 0 | Duvar saati 35 s. Log: `K5_runs/timing_full_run_fix_due_7.log` |
| 6e | Ölçüm: 16 koşu (8 preset × tohum 7, 11), JOBS=4, 1200 s zaman aşımı | 0 hepsi | PASS: her koşu tam 1 `PROBE END`, motor hatası 0. Loglar: `K5_runs/<preset>_<tohum>.log`. Tablo: `K5_OLCUM.md` (40 hedef, 38 PASS, 2 MISS: B2C erken dönem düzeltme payı medyanı fix_worst ve fix_due %50, hedef ≤ %30; kayıt, kapı hatası değil) |
| 7 | 26 pencereli kare, tek tek, vaka başına `shots/K5/appdata_<n>` | 0 hepsi | PASS: 26 PNG kopyalandı (`shots/K5/shot_<n>_*.png`), konsolda ERROR / SCRIPT ERROR satırı 0. Konsol logları: `shots/K5/appdata_<n>.console.log` |

Notlar (kapı hatası değil):
- Ölçüm koşuları Koşu 1 günlüklerini ezmesin diye eski `K5_runs` klasörü `K5_runs_kosu1` adıyla kenara alındı; yeni günlükler `K5_runs` içinde.
- Koşu 1'in kare kopyaları (`shot_1_` … `shot_9_`) `shots/K5/kosu1/` altına taşındı. Kare dizinleri (`appdata_<n>`) Koşu 1 ile aynıydı; Godot aynı adlı PNG'leri üzerine yazdı.
- Repo `git status` başlangıç anlık görüntüsüyle aynı; yeni değişen repo dosyası yok.

Kapı sonucu: tüm adımlar geçti. all_green = true.
