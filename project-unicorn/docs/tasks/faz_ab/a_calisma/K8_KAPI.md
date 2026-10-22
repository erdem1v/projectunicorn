# K8 kapı (Faz A)
## Koşu 1

Ağaç: HEAD 1d5ad5f, main, tek klasör. Kapı ajanı yalnız koştu ve kaydetti; repo dosyalarına dokunmadı.

| Adım | Komut | rc | Sonuç |
|---|---|---|---|
| 0 | class_name satırı diff taraması | 1 (eşleşme yok) | PASS, `--import` gerekmedi |
| 1 | grep FALSIFY-TEMP (değişen dosyalar + git diff) | 1 | PASS, artık yok |
| 2 | --event-lint | 0 | PASS: LINT PASS 0 error(s), 0 warning(s), 13 baselined, 97 card(s), 3 arc(s) |
| 3 | loc_residue.gd | 0 | PASS: 0 hit(s) [CLEAN] (csv_keys=3318) |
| 4 | smoke_run.sh loc_csv_integrity | 0 | PASS: SMOKE PASS |
| 5 | 15 vaka, xargs -P 2, CASE_TIMEOUT=300, her vakaya ayrı APPDATA/HOME | 0 (hepsi) | PASS: 15/15, günlükler K8_smoke/<vaka>.log |
| 6a | §4.1 grep (K8.md §3 deseni) | — | 52 isabet: save_manager.gd 12 (göç 15/16, izinli), endgame_smoke.gd 38 (v13/v14/v15 eski şema fikstürleri, izinli), strings.csv 2 ("tickets" EN içerik/konferans bileti, izinli). Tümü izinli yer: PASS |
| 6b | tools/run_gate.sh | 0 | PASS: RUN OK full_run (day 104), RUN OK full_run_b2c (day 104), RUN OK full_run_vc_cautious (day 68); RUN SUMMARY 3/3 ok |
| 6c | tools/plausibility_run.sh | 0 | PASS: PLAUS SUMMARY runs=40 fires=482 fails=0 |
| 6d | glyph_audit.gd | 0 | PASS (GLYPH\|CHARS\|129; MISS satırları K6 kümesiyle aynı kabul, kayıt olarak) |
| 6e | --sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1 | 0 | PASS: unnamed=0; SUMMARY match=216/225 |
| 6f | gen_signal_manifest.py ve --event-vocab | 0, 0 | PASS: ilgili üretilmiş dosyalarda diff yok (git status'ta vocab/MANIFEST yok) |
| 7 | pencereli kareler | — | Adım 6'da adı geçen kare yok: atlandı, PNG ve konsol taraması yok |

Kayıt notları:
- Run gate günlüğü: K8_smoke/run_gate.log (RUNGATE_EXIT=0).
- Plausibility: K8_smoke/plausibility.log.
- Glyph MISS satırları (ör. U+2192 BarlowCondensed-SemiBold, csv:HR_HOURS_SPRINT_POINTS) K8 değişikliğinden değil, glif kapsamı gözlemi.
- Harness notu: smoke_run.sh GODOT ister; ilk denemede rc=2 (GODOT boş) oldu, GODOT ihraç edilip yeniden koşuldu.

all_green: true
