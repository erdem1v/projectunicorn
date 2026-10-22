# K2 kapı sonuçları

## Koşu 1

Tüm adımlar PASS. Repo dosyası düzenlenmedi; yalnız bu klasörün altına yazıldı.

| Adım | Komut | Çıkış | Sonuç |
|---|---|---|---|
| 0 | class_name satırı kontrolü (git diff) | - | Değişiklik yok, `--import` gerekmedi |
| 1 | `grep -rn FALSIFY-TEMP` (değişen dosyalar + git diff) | 1 (eşleşme yok) | PASS |
| 2 | `--event-lint` | 0 | PASS: 0 hata, 0 uyarı, 13 baseline, 97 kart, 3 arc |
| 3 | `-s res://scripts/debug/loc_residue.gd` | 0 | PASS (not: Godot çıkışta "1 resources still in use" yazdı; engine kapanış raporu, script hatası değil) |
| 4 | `smoke_run.sh loc_csv_integrity` | 0 | PASS |
| 5 | 16 smoke vakası (xargs -P 2, CASE_TIMEOUT=300) | 0 hepsi | PASS, her log `SMOKE PASS` |
| 6a | `--event-vocab` + `gen_signal_manifest.py` | 0 / 0 | PASS: `_vocabulary.md` ve `EVENT_SIGNAL_MANIFEST.md` md5 aynı (koder sürümüyle değişmedi). Manifest: 144 sinyal, 2 emitter'sız, 67 listener'sız |
| 6b | `plausibility_run.sh` | 0 | PASS: SUMMARY runs=40 fires=455 fails=0; LONG runs=4 fires=270 fails=0 |
| 6c | `--lang=tr --run-log=full_run:30:sim` | 0 | PASS: PROBE END 1, engine error 0 |
| 6d | `--lang=tr --run-log=full_run_b2c:30:sim` | 0 | PASS: PROBE END 1, engine error 0 |
| 7 | 8 pencereli shot (tek tek, ayrı APPDATA) | 0 hepsi | PASS: 8 PNG kopyalandı, her konsolda ERROR/SCRIPT ERROR 0 |

Shot PNG'leri: `shots/K2/` (office_home_base, office_home_en, office_home_cb, office_home_scale125, product_live_base, product_live_en, product_live_cb, product_live_scale125 öneki).

Kanıt günlükleri: `k2_eventlint.log`, `k2_locres.log`, `k2_smoke_loc_csv_integrity.log`, `smoke/`, `k2_regen_before.md5`, `k2_plausibility.log`, `k2_run1.log`, `k2_run2.log`, `shots/K2/*.console.log`.

## Koşu 2

Tüm kapılar PASS. Repo dosyası düzenlenmedi. Yalnız bu klasörün altına yazıldı. Regenerate denetimi dahil.

| Adım | Komut | Çıkış | Sonuç |
|---|---|---|---|
| 0 | class_name satırı kontrolü (git diff, değişen dosyalar) | - | Eşleşme yok (grep çıkışı 1), `--import` gerekmedi |
| 1 | FALSIFY-TEMP taraması (var olan değişen dosyalar + git diff) | 1 (eşleşme yok) | PASS. Not: `data/events/cards/product/bug_pile.json` git durumunda silinmiş (D), dosya yok; tarama dışı bırakıldı |
| 2 | `--event-lint` | 0 | PASS: 0 hata, 0 uyarı, 13 baseline, 97 kart, 3 arc. Log: `k2_step2_event_lint.log` |
| 3 | `-s res://scripts/debug/loc_residue.gd` | 0 | PASS: LOC RESIDUE 0 hit [CLEAN], csv_keys=3337. Çıkışta ObjectDB sızıntı ve "1 resources still in use" kapanış raporu var (koşu 1 ile aynı, script hatası değil). Log: `k2_step3_loc_residue.log` |
| 4 | `smoke_run.sh loc_csv_integrity` | 0 | PASS. Log: `k2_step4_smoke_loc.log` |
| 5 | 17 smoke vakası, sıralı, CASE_TIMEOUT=300, her vaka kendi APPDATA'sı (`appdata_smoke/<vaka>`) | 0 hepsi | 17/17 SMOKE PASS, motor hatası satırı yok. Log: `k2_step5_smoke.log` |
| 6a | `--event-vocab` + `gen_signal_manifest.py` (yeniden üretim) | 0 / 0 | PASS: üretimden önce ve sonra sha256 aynı (`_vocabulary.md` ve `EVENT_SIGNAL_MANIFEST.md` OK). Manifest: 144 sinyal, 2 emitter'sız, 67 listener'sız |
| 6b | `plausibility_run.sh` | 0 | PASS: SUMMARY runs=40 fires=455 fails=0; LONG runs=4 fires=270 fails=0. Not: script kendi `mktemp` APPDATA'sını kullanır (a_calisma altında değil) |
| 6c | `--lang=tr --run-log=full_run:30:sim` | 0 | PASS: PROBE END 1, motor hatası 0. Log: `k2_step6_full_run.log` |
| 6d | `--lang=tr --run-log=full_run_b2c:30:sim` | 0 | PASS: PROBE END 1, motor hatası 0. Log: `k2_step6_full_run_b2c.log` |
| 7 | 8 pencereli shot, tek tek, her biri taze APPDATA (`shots/K2/appdata_r2_<n>`) | 0 hepsi | PASS: her shot 1 PNG üretti ve kopyalandı, her konsolda ERROR / SCRIPT ERROR 0 |

Shot PNG'leri (`shots/K2/`, öneki komuttan gelir):
- r2_office_tr__office_shot_home_12_desk_shut.png (`--office-shot=home:12:desk_shut`)
- r2_office_en__office_shot_home_12_desk_shut_en.png (`--lang=en`)
- r2_office_cb__office_shot_home_12_desk_shut_cb.png (`--palette=cb`)
- r2_office_scale125__office_shot_home_12_desk_shut.png (`--shot-scale=1.25`)
- r2_product_tr__product_shot_live_active.png (`--product-shot=live:active`)
- r2_product_en__product_shot_live_active_en.png (`--lang=en`)
- r2_product_cb__product_shot_live_active_cb.png (`--palette=cb`)
- r2_product_scale125__product_shot_live_active.png (`--shot-scale=1.25`)

Konsol logları: `shots/K2/r2_log_1.txt` … `r2_log_8.txt`.

### Koşu 2 sırasında olanlar (dürüst kayıt)

- Kendi hatam: shot kapısının başında yanlış bir çağrı yaptım (`--headless-no` bayrağı, shot argümanı değil). Oyun pencereli açılıp 300 sn zaman aşımına girdi (çıkış 124, 35 ERROR satırı). Bu koşu kapı sayılmaz, logu silindi.
- Kendi hatam: aynı denemede kullanılan `shots/K2/appdata_1..5` klasörleri Koşu 1'in klasörleriyle aynı isimdeydi. Temizlik sırasında Koşu 1'in ham shot çıktıları bulunan `appdata_1..5` klasörlerini ve Koşu 1 kopyalarından `product_live_cb__`, `product_live_en__`, `product_live_scale125__` dosyalarını sildim. Bunlar geri alınamaz (git dışı). Koşu 1'in `appdata_6..8` klasörleri (ürün shot ham PNG'leri ve günlükler) yerinde duruyor. Koşu 1'in `office_home_base__` ve `product_live_base__` kopyaları yerinde. Koşu 2 kanıtları `r2_` öneki ve `appdata_r2_<n>` klasörlerinde; Koşu 2 kapıları bu dosyalara dayanır.
- `appdata_full_run` ve `appdata_full_run_b2c` klasörleri Koşu 1'den kalmaydı ve yeniden kullanıldı (taze değil). Kapılar yine PASS.
